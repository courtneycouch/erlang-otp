%%% -*- erlang-indent-level: 2 -*-
%%% $Id$

-module(hipe_ppc_frame).
-export([frame/1]).
-include("hipe_ppc.hrl").
-include("../rtl/hipe_literals.hrl").

frame(Defun) ->
  Formals = fix_formals(hipe_ppc:defun_formals(Defun)),
  Temps0 = all_temps(hipe_ppc:defun_code(Defun), Formals),
  MinFrame = defun_minframe(Defun),
  Temps = ensure_minframe(MinFrame, Temps0),
  CFG0 = hipe_ppc_cfg:init(Defun),
  Liveness = hipe_ppc_liveness:analyse(CFG0),
  CFG1 = do_body(CFG0, Liveness, Formals, Temps),
  hipe_ppc_cfg:linearise(CFG1).

fix_formals(Formals) ->
  fix_formals(hipe_ppc_registers:nr_args(), Formals).

fix_formals(N, [_|Rest]) when N > 0 -> fix_formals(N-1, Rest);
fix_formals(_, Formals) -> Formals.

do_body(CFG0, Liveness, Formals, Temps) ->
  Context = mk_context(Liveness, Formals, Temps),
  CFG1 = do_blocks(CFG0, Context),
  do_prologue(CFG1, Context).

do_blocks(CFG, Context) ->
  Labels = hipe_ppc_cfg:labels(CFG),
  do_blocks(Labels, CFG, Context).

do_blocks([Label|Labels], CFG, Context) ->
  Liveness = context_liveness(Context),
  LiveOut = hipe_ppc_liveness:liveout(Liveness, Label),
  Block = hipe_ppc_cfg:bb(CFG, Label),
  Code = hipe_bb:code(Block),
  NewCode = do_block(Code, LiveOut, Context),
  NewBlock = hipe_bb:code_update(Block, NewCode),
  NewCFG = hipe_ppc_cfg:bb_add(CFG, Label, NewBlock),
  do_blocks(Labels, NewCFG, Context);
do_blocks([], CFG, _) ->
  CFG.

do_block(Insns, LiveOut, Context) ->
  do_block(Insns, LiveOut, Context, context_framesize(Context), []).

do_block([I|Insns], LiveOut, Context, FPoff0, RevCode) ->
  {NewIs, FPoff1} = do_insn(I, LiveOut, Context, FPoff0),
  do_block(Insns, LiveOut, Context, FPoff1, lists:reverse(NewIs, RevCode));
do_block([], _, Context, FPoff, RevCode) ->
  FPoff0 = context_framesize(Context),
  if FPoff =:= FPoff0 -> [];
     true -> exit({?MODULE,do_block,FPoff})
  end,
  lists:reverse(RevCode, []).

do_insn(I, LiveOut, Context, FPoff) ->
  case I of
    #pseudo_call{} ->
      do_pseudo_call(I, LiveOut, Context, FPoff);
    #pseudo_call_prepare{} ->
      do_pseudo_call_prepare(I, FPoff);
    #pseudo_move{} ->
      {do_pseudo_move(I, Context, FPoff), FPoff};
    #pseudo_ret{} ->
      {do_pseudo_ret(I, Context, FPoff), context_framesize(Context)};
    #pseudo_tailcall{} ->
      {do_pseudo_tailcall(I, Context), context_framesize(Context)};
    _ ->
      {[I], FPoff}
  end.

%%%
%%% Moves, with Dst or Src possibly a pseudo
%%%

do_pseudo_move(I, Context, FPoff) ->
  Dst = hipe_ppc:pseudo_move_dst(I),
  Src = hipe_ppc:pseudo_move_src(I),
  case temp_is_pseudo(Dst) of
    true ->
      Offset = pseudo_offset(Dst, FPoff, Context),
      mk_store('stw', Src, Offset, mk_sp(), []);
    _ ->
      case temp_is_pseudo(Src) of
	true ->
	  Offset = pseudo_offset(Src, FPoff, Context),
	  mk_load('lwz', Dst, Offset, mk_sp(), []);
	_ ->
	  [hipe_ppc:mk_alu('or', Dst, Src, Src)]
      end
  end.

pseudo_offset(Temp, FPoff, Context) ->
  FPoff + context_offset(Context, Temp).

%%%
%%% Return - deallocate frame and emit 'ret $N' insn.
%%%

do_pseudo_ret(_I, Context, FPoff) ->
  %% XXX: perhaps use explicit pseudo_move;mtlr,
  %% avoiding the need to hard-code Temp1 here
  %% XXX: typically only one instruction between
  %% the mtlr and the blr, ouch
  restore_lr(FPoff,
	     adjust_sp(FPoff + word_size() * context_arity(Context),
		       [hipe_ppc:mk_blr()])).

restore_lr(FPoff, Rest) ->
  Temp = mk_temp1(),
  mk_load('lwz', Temp, FPoff - word_size(), mk_sp(),
	  [hipe_ppc:mk_mtspr('lr', Temp) |
	   Rest]).

adjust_sp(N, Rest) ->
  if N =:= 0 ->
      Rest;
     true ->
      SP = mk_sp(),
      hipe_ppc:mk_addi(SP, SP, N, Rest)
  end.

%%%
%%% Recursive calls.
%%%

do_pseudo_call_prepare(I, FPoff0) ->
  %% Create outgoing arguments area on the stack.
  NrStkArgs = hipe_ppc:pseudo_call_prepare_nrstkargs(I),
  Offset = NrStkArgs * word_size(),
  {adjust_sp(-Offset, []), FPoff0 + Offset}.

do_pseudo_call(I, LiveOut, Context, FPoff0) ->
  #ppc_sdesc{exnlab=ExnLab,arity=OrigArity} = hipe_ppc:pseudo_call_sdesc(I),
  FunC = hipe_ppc:pseudo_call_func(I),
  LiveTemps = [Temp || Temp <- LiveOut, temp_is_pseudo(Temp)],
  SDesc = mk_sdesc(ExnLab, Context, LiveTemps),
  ContLab = hipe_ppc:pseudo_call_contlab(I),
  Linkage = hipe_ppc:pseudo_call_linkage(I),
  CallCode = [hipe_ppc:mk_pseudo_call(FunC, SDesc, ContLab, Linkage)],
  context_need_stack(Context, FPoff0),
  StkArity = max(0, OrigArity - hipe_ppc_registers:nr_args()),
  ArgsBytes = word_size() * StkArity,
  {CallCode, FPoff0 - ArgsBytes}.

%%%
%%% Create stack descriptors for call sites.
%%%

mk_sdesc(ExnLab, Context, Temps) ->	% for normal calls
  Temps0 = only_tagged(Temps),
  Live = mk_live(Context, Temps0),
  Arity = context_arity(Context),
  FSize = context_framesize(Context),
  hipe_ppc:mk_sdesc(ExnLab, (FSize div word_size())-1, Arity,
                    list_to_tuple(Live)).

only_tagged(Temps)->
  [X || X <- Temps, hipe_ppc:temp_type(X) =:= 'tagged'].

mk_live(Context, Temps) ->
  lists:sort([temp_to_slot(Context, Temp) || Temp <- Temps]).

temp_to_slot(Context, Temp) ->
  (context_framesize(Context) + context_offset(Context, Temp))
    div word_size().

mk_minimal_sdesc(Context) ->		% for inc_stack_0 calls
  hipe_ppc:mk_sdesc([], 0, context_arity(Context), {}).

%%%
%%% Tailcalls.
%%%

do_pseudo_tailcall(I, Context) -> % always at FPoff=context_framesize(Context)
  Arity = context_arity(Context),
  Args = hipe_ppc:pseudo_tailcall_stkargs(I),
  FunC = hipe_ppc:pseudo_tailcall_func(I),
  Linkage = hipe_ppc:pseudo_tailcall_linkage(I),
  {Insns, FPoff1} = do_tailcall_args(Args, Context),
  context_need_stack(Context, FPoff1),
  FPoff2 = FPoff1 + word_size()*Arity - word_size()*length(Args),
  context_need_stack(Context, FPoff2),
  I2 =
    case FunC of
      'ctr' ->
	hipe_ppc:mk_bctr([]);
      Fun ->
	hipe_ppc:mk_b_fun(Fun, Linkage)
    end,
  %% XXX: break out the LR restore, just like for pseudo_ret?
  restore_lr(context_framesize(Context),
	     Insns ++ adjust_sp(FPoff2, [I2])).

do_tailcall_args(Args, Context) ->
  FPoff0 = context_framesize(Context),
  Arity = context_arity(Context),
  FrameTop = word_size()*Arity,
  DangerOff = FrameTop - word_size()*length(Args),
  %%
  Moves = mk_moves(Args, FrameTop, []),
  %%
  {Stores, Simple, Conflict} =
    split_moves(Moves, Context, DangerOff, [], [], []),
  %% sanity check (shouldn't trigger any more)
  if DangerOff < -FPoff0 ->
      exit({?MODULE,do_tailcall_args,DangerOff,-FPoff0});
     true -> []
  end,
  FPoff1 = FPoff0,
  %%
  {Pushes, Pops, FPoff2} = split_conflict(Conflict, FPoff1, [], []),
  %%
  TempReg = hipe_ppc_registers:temp1(),
  %%
  {adjust_sp(-(FPoff2 - FPoff1),
	     simple_moves(Pushes, FPoff2, TempReg,
			  store_moves(Stores, FPoff2, TempReg,
				      simple_moves(Simple, FPoff2, TempReg,
						   simple_moves(Pops, FPoff2, TempReg,
								[]))))),
   FPoff2}.

mk_moves([Arg|Args], Off, Moves) ->
  Off1 = Off - word_size(),
  mk_moves(Args, Off1, [{Arg,Off1}|Moves]);
mk_moves([], _, Moves) ->
  Moves.

split_moves([Move|Moves], Context, DangerOff, Stores, Simple, Conflict) ->
  {Src,DstOff} = Move,
  case src_is_pseudo(Src) of
    false ->
      split_moves(Moves, Context, DangerOff, [Move|Stores],
		  Simple, Conflict);
    true ->
      SrcOff = context_offset(Context, Src),
      Type = typeof_temp(Src),
      if SrcOff =:= DstOff ->
	  split_moves(Moves, Context, DangerOff, Stores,
		      Simple, Conflict);
	 SrcOff >= DangerOff ->
	  split_moves(Moves, Context, DangerOff, Stores,
		      Simple, [{SrcOff,DstOff,Type}|Conflict]);
	 true ->
	  split_moves(Moves, Context, DangerOff, Stores,
		      [{SrcOff,DstOff,Type}|Simple], Conflict)
      end
  end;
split_moves([], _, _, Stores, Simple, Conflict) ->
  {Stores, Simple, Conflict}.

split_conflict([{SrcOff,DstOff,Type}|Conflict], FPoff, Pushes, Pops) ->
  FPoff1 = FPoff + word_size(),
  Push = {SrcOff,-FPoff1,Type},
  Pop = {-FPoff1,DstOff,Type},
  split_conflict(Conflict, FPoff1, [Push|Pushes], [Pop|Pops]);
split_conflict([], FPoff, Pushes, Pops) ->
  {lists:reverse(Pushes), Pops, FPoff}.

simple_moves([{SrcOff,DstOff,Type}|Moves], FPoff, TempReg, Rest) ->
  Temp = hipe_ppc:mk_temp(TempReg, Type),
  SP = mk_sp(),
  LoadOff = FPoff+SrcOff,
  StoreOff = FPoff+DstOff,
  simple_moves(Moves, FPoff, TempReg,
	       mk_load('lwz', Temp, LoadOff, SP,
		       mk_store('stw', Temp, StoreOff, SP,
				Rest)));
simple_moves([], _, _, Rest) ->
  Rest.

store_moves([{Src,DstOff}|Moves], FPoff, TempReg, Rest) ->
  %%Type = typeof_temp(Src),
  SP = mk_sp(),
  StoreOff = FPoff+DstOff,
  {NewSrc,FixSrc} =
    case hipe_ppc:is_temp(Src) of
      true ->
	{Src, []};
      _ ->
	Temp = hipe_ppc:mk_temp(TempReg, 'untagged'),
	{Temp, hipe_ppc:mk_li(Temp, Src)}
    end,
  store_moves(Moves, FPoff, TempReg,
	      FixSrc ++ mk_store('stw', NewSrc, StoreOff, SP, Rest));
store_moves([], _, _, Rest) ->
  Rest.

%%%
%%% Contexts
%%%

-record(context, {liveness, framesize, arity, map, ra, ref_maxstack}).

mk_context(Liveness, Formals, Temps) ->
  RA = hipe_ppc:mk_new_temp('untagged'),
  {Map, MinOff} = mk_temp_map(Formals, RA, Temps),
  FrameSize = (-MinOff),
  RefMaxStack = hipe_bifs:ref(FrameSize),
  Context = #context{liveness=Liveness,
		     framesize=FrameSize, arity=length(Formals),
		     map=Map, ra=RA, ref_maxstack=RefMaxStack},
  Context.

context_need_stack(#context{ref_maxstack=RM}, N) ->
  M = hipe_bifs:ref_get(RM),
  if N > M -> hipe_bifs:ref_set(RM, N);
     true -> []
  end.

context_maxstack(#context{ref_maxstack=RM}) ->
  hipe_bifs:ref_get(RM).

context_arity(#context{arity=Arity}) ->
  Arity.

context_framesize(#context{framesize=FrameSize}) ->
  FrameSize.

context_liveness(#context{liveness=Liveness}) ->
  Liveness.

context_offset(#context{map=Map}, Temp) ->
  tmap_lookup(Map, Temp).

%%%context_ra(#context{ra=RA}) ->
%%%  RA.

mk_temp_map(Formals, RA, Temps) ->
  {Map, 0} = enter_vars(Formals, word_size() * length(Formals),
			tmap_empty()),
  enter_vars([RA|tset_to_list(Temps)], 0, Map).

enter_vars([V|Vs], PrevOff, Map) ->
  Off =
    case hipe_ppc:temp_type(V) of
      'double' -> PrevOff - 2*word_size();
      _ -> PrevOff - word_size()
    end,
  enter_vars(Vs, Off, tmap_bind(Map, V, Off));
enter_vars([], Off, Map) ->
  {Map, Off}.

tmap_empty() ->
  gb_trees:empty().

tmap_bind(Map, Key, Val) ->
  gb_trees:insert(Key, Val, Map).

tmap_lookup(Map, Key) ->
  gb_trees:get(Key, Map).

%%%
%%% do_prologue: prepend stack frame allocation code.
%%%
%%% NewStart:
%%%	temp1 = *(P + P_SP_LIMIT)
%%%	temp2 = SP - MaxStack
%%%	if( temp2 < temp1 ) goto IncStack else goto AllocFrame
%%% AllocFrame:
%%%	SP -= FrameSize
%%%	temp1 = LR
%%%	*(SP + FrameSize-WordSize) = temp1
%%%	goto OldStart
%%% OldStart:
%%%	...
%%% IncStack:
%%%	temp1 = LR
%%%	bl inc_stack
%%%	LR = temp1
%%%	goto NewStart

do_prologue(CFG, Context) ->
  MaxStack = context_maxstack(Context),
  if MaxStack > 0 -> % XXX: this will always be true
      FrameSize = context_framesize(Context),
      OldStartLab = hipe_ppc_cfg:start_label(CFG),
      NewStartLab = hipe_gensym:get_next_label(ppc),
      AllocFrameLab = hipe_gensym:get_next_label(ppc),
      IncStackLab = hipe_gensym:get_next_label(ppc),
      %%
      P = hipe_ppc:mk_temp(hipe_ppc_registers:proc_pointer(), 'untagged'),
      Temp1 = mk_temp1(),
      Temp2 = mk_temp2(),
      SP = mk_sp(),
      %%
      NewStartCode =
	[hipe_ppc:mk_load('lwz', Temp1, ?P_NSP_LIMIT, P) |
	 hipe_ppc:mk_addi(Temp2, SP, -MaxStack,
			  [hipe_ppc:mk_cmp('cmpl', Temp2, Temp1),
			   hipe_ppc:mk_mfspr(Temp1, 'lr'), % hoisted
			   hipe_ppc:mk_pseudo_bc('lt', IncStackLab,
						 AllocFrameLab, 0.01)])],
      %%
      %% XXX: In leaf functions, Temp2 already equals SP-FrameSize.
      %% XXX: Replace this adjust_sp() with something cleverer.
      AllocFrameCode =
	adjust_sp(-FrameSize,
		  mk_store('stw', Temp1, FrameSize-word_size(), SP,
			   [hipe_ppc:mk_b_label(OldStartLab)])),
      %%
      IncStackCode =
	[hipe_ppc:mk_bl(hipe_ppc:mk_prim('inc_stack_0'),
			mk_minimal_sdesc(Context), not_remote),
	 hipe_ppc:mk_mtspr('lr', Temp1),
	 hipe_ppc:mk_b_label(NewStartLab)],
      %%
      CFG1 = hipe_ppc_cfg:bb_add(CFG, NewStartLab,
                                 hipe_bb:mk_bb(NewStartCode)),
      CFG2 = hipe_ppc_cfg:bb_add(CFG1, AllocFrameLab,
                                 hipe_bb:mk_bb(AllocFrameCode)),
      CFG3 = hipe_ppc_cfg:bb_add(CFG2, IncStackLab,
                                 hipe_bb:mk_bb(IncStackCode)),
      CFG4 = hipe_ppc_cfg:start_label_update(CFG3, NewStartLab),
      %%
      CFG4;
     true -> % XXX: this will never happen
      exit({?MODULE,do_prologue,MaxStack}),
      CFG
  end.

%%% Create a load instruction.
%%% May clobber TEMP2 for large offsets.

mk_load(LdOp, Dst, Offset, Base, Rest) ->
  if Offset >= -32768, Offset =< 32767 ->
      [hipe_ppc:mk_load(LdOp, Dst, Offset, Base) | Rest];
     true ->
      LdxOp =
	case LdOp of
	  'lwz' -> 'lwzx'
	end,
      Index = mk_temp2(),
      [hipe_ppc:mk_li(Index, Offset),
       hipe_ppc:mk_loadx(LdxOp, Dst, Base, Index) | Rest]
  end.

%%% Create a store instruction.
%%% May clobber TEMP2 for large offsets.

mk_store(StOp, Src, Offset, Base, Rest) ->
  if Offset >= -32768, Offset =< 32767 ->
      [hipe_ppc:mk_store(StOp, Src, Offset, Base) | Rest];
     true ->
      StxOp =
	case StOp of
	  'stw' -> 'stwx'
	end,
      Index = mk_temp2(),
      [hipe_ppc:mk_li(Index, Offset),
       hipe_ppc:mk_storex(StxOp, Src, Base, Index) | Rest]
  end.

%%% typeof_temp -- what's temp's type?

typeof_temp(Temp) ->
  hipe_ppc:temp_type(Temp).

%%% Cons up an 'SP' Temp.

mk_sp() ->
  hipe_ppc:mk_temp(hipe_ppc_registers:stack_pointer(), 'untagged').

%%% Cons up a 'TEMP1' Temp.

mk_temp1() ->
  hipe_ppc:mk_temp(hipe_ppc_registers:temp1(), 'untagged').

%%% Cons up a 'TEMP2' Temp.

mk_temp2() ->
  hipe_ppc:mk_temp(hipe_ppc_registers:temp2(), 'untagged').

%%% Check if an operand is a pseudo-Temp.

src_is_pseudo(Src) ->
  case hipe_ppc:is_temp(Src) of
    true -> temp_is_pseudo(Src);
    _ -> false
  end.

temp_is_pseudo(Temp) ->
  not(hipe_ppc_registers:is_precoloured(hipe_ppc:temp_reg(Temp))).

%%%
%%% Build the set of all temps used in a Defun's body.
%%%

all_temps(Code, Formals) ->
  S0 = find_temps(Code, tset_empty()),
  S1 = tset_del_list(S0, Formals),
  S2 = tset_filter(S1, fun(T) -> temp_is_pseudo(T) end),
  S2.

find_temps([I|Insns], S0) ->
  S1 = tset_add_list(S0, hipe_ppc_defuse:insn_def(I)),
  S2 = tset_add_list(S1, hipe_ppc_defuse:insn_use(I)),
  find_temps(Insns, S2);
find_temps([], S) ->
  S.

tset_empty() ->
  gb_sets:new().

tset_size(S) ->
  gb_sets:size(S).

tset_insert(S, T) ->
  gb_sets:add_element(T, S).

tset_add_list(S, Ts) ->
  gb_sets:union(S, gb_sets:from_list(Ts)).

tset_del_list(S, Ts) ->
  gb_sets:subtract(S, gb_sets:from_list(Ts)).

tset_filter(S, F) ->
  gb_sets:filter(F, S).

tset_to_list(S) ->
  gb_sets:to_list(S).

%%%
%%% Compute minimum permissible frame size, ignoring spilled temps.
%%% This is done to ensure that we won't have to adjust the frame size
%%% in the middle of a tailcall.
%%%

defun_minframe(Defun) ->
  MaxTailArity = body_mta(hipe_ppc:defun_code(Defun), 0),
  MyArity = length(fix_formals(hipe_ppc:defun_formals(Defun))),
  max(MaxTailArity - MyArity, 0).

body_mta([I|Code], MTA) ->
  body_mta(Code, insn_mta(I, MTA));
body_mta([], MTA) ->
  MTA.

insn_mta(I, MTA) ->
  case I of
    #pseudo_tailcall{arity=Arity} ->
      max(MTA, Arity - hipe_ppc_registers:nr_args());
    _ -> MTA
  end.

max(X, Y) -> % why isn't max/2 a standard BIF?
  if X > Y -> X; true -> Y end.

%%%
%%% Ensure that we have enough temps to satisfy the minimum frame size,
%%% if necessary by prepending unused dummy temps.
%%%

ensure_minframe(MinFrame, Temps) ->
  ensure_minframe(MinFrame, tset_size(Temps), Temps).

ensure_minframe(MinFrame, Frame, Temps) ->
  if MinFrame > Frame ->
      Temp = hipe_ppc:mk_new_temp('untagged'),
      ensure_minframe(MinFrame, Frame+1, tset_insert(Temps, Temp));
     true -> Temps
  end.

word_size() ->
  hipe_rtl_arch:word_size().
