%%% -*- erlang-indent-level: 2 -*-
%%% $Id$
%%% compute def/use sets for amd64 insns
%%%
%%% TODO:
%%% - represent EFLAGS (condition codes) use/def by a virtual reg?
%%% - should push use/def %esp?

-module(hipe_amd64_defuse).
-export([insn_def/1, insn_use/1]). %% src_use/1]).
-include("hipe_amd64.hrl").

%%%
%%% insn_def(Insn) -- Return set of temps defined by an instruction.
%%%

insn_def(I) ->
  case I of
    #alu{dst=Dst} -> dst_def(Dst);
    #cmovcc{dst=Dst} -> dst_def(Dst);
    #dec{dst=Dst} -> dst_def(Dst);
    #fmove{dst=Dst} -> dst_def(Dst);
    #fp_binop{dst=Dst} -> dst_def(Dst);
    #fp_unop{arg=Arg} -> dst_def(Arg);
    #inc{dst=Dst} -> dst_def(Dst);
    #lea{temp=Temp} -> [Temp];
    #move{dst=Dst} -> dst_def(Dst);
    #move64{dst=Dst} -> dst_def(Dst);
    #movsx{dst=Dst} -> dst_def(Dst);
    #movzx{dst=Dst} -> dst_def(Dst);
    #pseudo_call{} -> call_clobbered();
    #pseudo_tailcall_prepare{} -> tailcall_clobbered();
    #shift{dst=Dst} -> dst_def(Dst);
    %% call, cmp, comment, jcc, jmp_fun, jmp_label, jmp_switch, label
    %% nop, pseudo_jcc, pseudo_tailcall, push, ret
    _ -> []
  end.

dst_def(Dst) ->
  case Dst of
    #amd64_temp{} -> [Dst];
    #amd64_fpreg{} -> [Dst];
    _ -> []
  end.

call_clobbered() ->
  [hipe_amd64:mk_temp(R, T)
   || {R,T} <- hipe_amd64_registers:call_clobbered()].

tailcall_clobbered() ->
  [hipe_amd64:mk_temp(R, T)
   || {R,T} <- hipe_amd64_registers:tailcall_clobbered()].

%%%
%%% insn_use(Insn) -- Return set of temps used by an instruction.
%%%

insn_use(I) ->
  case I of
    #alu{src=Src,dst=Dst} -> addtemp(Src, addtemp(Dst, []));
    #call{'fun'=Fun} -> addtemp(Fun, []);
    #cmovcc{src=Src, dst=Dst} -> addtemp(Src, dst_use(Dst));
    #cmp{src=Src, dst=Dst} -> addtemp(Src, addtemp(Dst, []));
    #dec{dst=Dst} -> addtemp(Dst, []);
    #fmove{src=Src,dst=Dst} -> addtemp(Src, dst_use(Dst));
    #fp_unop{arg=Arg} -> addtemp(Arg, []);
    #fp_binop{src=Src,dst=Dst} -> addtemp(Src, addtemp(Dst, []));
    #inc{dst=Dst} -> addtemp(Dst, []);
    #jmp_fun{'fun'=Fun} -> addtemp(Fun, []);
    #jmp_switch{temp=Temp, jtab=Tab} -> addtemp(Temp, addtemp(Tab,[]));
    #lea{mem=Mem} -> addtemp(Mem, []);
    #move{src=Src,dst=Dst} -> addtemp(Src, dst_use(Dst));
    #move64{} -> [];
    #movsx{src=Src,dst=Dst} -> addtemp(Src, dst_use(Dst));
    #movzx{src=Src,dst=Dst} -> addtemp(Src, dst_use(Dst));
    #pseudo_call{'fun'=Fun,sdesc=#amd64_sdesc{arity=Arity}} ->
      addtemp(Fun, arity_use(Arity));
    #pseudo_tailcall{'fun'=Fun,arity=Arity,stkargs=StkArgs} ->
      addtemp(Fun, addtemps(StkArgs, 
                            addtemps(tailcall_clobbered(),
                                     arity_use(Arity))));
    #push{src=Src} -> addtemp(Src, []);
    #ret{} -> [hipe_amd64:mk_temp(hipe_amd64_registers:rax(), 'tagged')];
    #shift{src=Src,dst=Dst} -> addtemp(Src, addtemp(Dst, []));
    %% comment, jcc, jmp_label, label, nop, pseudo_jcc, pseudo_tailcall_prepare
    _ -> []
  end.

arity_use(Arity) ->
  [hipe_amd64:mk_temp(R, 'tagged')
   || R <- hipe_amd64_registers:args(Arity)].

dst_use(Dst) ->
  case Dst of
    #amd64_mem{base=Base,off=Off} -> addbase(Base, addtemp(Off, []));
    _ -> []
  end.

%%%
%%% src_use(Src) -- Return set of temps used by a source operand.
%%%

%% src_use(Src) ->
%%   addtemp(Src, []).

%%%
%%% Auxiliary operations on sets of temps
%%%

addtemps([Arg|Args], Set) ->
  addtemps(Args, addtemp(Arg, Set));
addtemps([], Set) ->
  Set.

addtemp(Arg, Set) ->
  case Arg of
    #amd64_temp{} -> add(Arg, Set);
    #amd64_mem{base=Base,off=Off} -> addtemp(Off, addbase(Base, Set));
    #amd64_fpreg{} -> add(Arg, Set);
    _ -> Set
  end.

addbase(Base, Set) ->
  case Base of
    [] -> Set;
    _ -> addtemp(Base, Set)
  end.

add(Arg, Set) ->
  case lists:member(Arg, Set) of
    false -> [Arg|Set];
    _ -> Set
  end.
