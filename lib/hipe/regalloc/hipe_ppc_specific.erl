%%% -*- erlang-indent-level: 2 -*-
%%% $Id$

-module(hipe_ppc_specific).

%% for hipe_coalescing_regalloc:
-export([number_of_temporaries/1
	 ,analyze/1
	 ,labels/1
	 ,all_precoloured/0
	 ,bb/2
	 ,liveout/2
	 ,reg_nr/1
	 ,def_use/1
	 ,is_move/1
	 ,is_precoloured/1
	 ,var_range/1
	 ,allocatable/0
	 ,non_alloc/1
	 ,physical_name/1
	 ,reverse_postorder/1
	 ,succ_map/1
	 ,livein/2
	 ,uses/1
	 ,defines/1
	]).

%% for hipe_graph_coloring_regalloc:
-export([is_fixed/1]).

%% for hipe_ls_regalloc:
%%-export([args/1, is_arg/1, is_global, new_spill_index/1]).
%%-export([breadthorder/1, postorder/1]).

%% callbacks for hipe_regalloc_loop
-export([defun_to_cfg/1,
	 check_and_rewrite/2]).

defun_to_cfg(Defun) ->
  hipe_ppc_cfg:init(Defun).

check_and_rewrite(Defun, Coloring) ->
  {NewDefun, _, NewSpillIndex} =
    hipe_ppc_ra_postconditions:check_and_rewrite(Defun, Coloring, [], []),
  {NewDefun, NewSpillIndex}.

reverse_postorder(CFG) ->
  hipe_ppc_cfg:reverse_postorder(CFG).

non_alloc(CFG) ->
  non_alloc(hipe_ppc_registers:nr_args(), hipe_ppc_cfg:params(CFG)).

non_alloc(N, [_|Rest]) when N > 0 -> non_alloc(N-1, Rest);
non_alloc(_, Params) -> Params.

%% Liveness stuff

analyze(CFG) ->
  hipe_ppc_liveness:analyze(CFG).

livein(Liveness,L) ->
  [X || X <- hipe_ppc_liveness:livein(Liveness,L),
	hipe_ppc:temp_is_allocatable(X),
	hipe_ppc:temp_type(X) /= 'double'].

liveout(BB_in_out_liveness,Label) ->
  [X || X <- hipe_ppc_liveness:liveout(BB_in_out_liveness,Label),
	hipe_ppc:temp_is_allocatable(X),
	hipe_ppc:temp_type(X) /= 'double'].

%% Registers stuff

allocatable() ->
  hipe_ppc_registers:allocatable().

all_precoloured() ->
  hipe_ppc_registers:all_precoloured().

is_precoloured(Reg) ->
  hipe_ppc_registers:is_precoloured(Reg).

is_fixed(R) ->
  hipe_ppc_registers:is_fixed(R).

physical_name(Reg) ->
  Reg.

%% CFG stuff

succ_map(CFG) ->
  hipe_ppc_cfg:succ_map(CFG).

labels(CFG) ->
  hipe_ppc_cfg:labels(CFG).

var_range(_CFG) ->
  hipe_gensym:var_range(ppc).

number_of_temporaries(_CFG) ->
  Highest_temporary = hipe_gensym:get_var(ppc),
  %% Since we can have temps from 0 to Max adjust by +1.
  Highest_temporary + 1.

bb(CFG,L) ->
  hipe_ppc_cfg:bb(CFG,L).

%% PowerPC stuff

def_use(Instruction) ->
  {defines(Instruction), uses(Instruction)}.

uses(I) ->
  [X || X <- hipe_ppc_defuse:insn_use(I),
	hipe_ppc:temp_is_allocatable(X),
	hipe_ppc:temp_type(X) /= 'double'].

defines(I) ->
  [X || X <- hipe_ppc_defuse:insn_def(I),
	hipe_ppc:temp_is_allocatable(X),
	hipe_ppc:temp_type(X) /= 'double'].

is_move(Instruction) ->
  case hipe_ppc:is_pseudo_move(Instruction) of
    true ->
      Dst = hipe_ppc:pseudo_move_dst(Instruction),
      case hipe_ppc:temp_is_allocatable(Dst) of
	false -> false;
	_ ->
	  Src = hipe_ppc:pseudo_move_src(Instruction),
	  hipe_ppc:temp_is_allocatable(Src)
      end;
    false -> false
  end.

reg_nr(Reg) ->
  hipe_ppc:temp_reg(Reg).

-ifdef(notdef).
new_spill_index(SpillIndex)->
  SpillIndex+1.

breadthorder(CFG) ->
  hipe_ppc_cfg:breadthorder(CFG).

postorder(CFG) ->
  hipe_ppc_cfg:postorder(CFG).

is_global(R) ->
  hipe_ppc_registers:is_fixed(R).

is_arg(R) ->
  hipe_ppc_registers:is_arg(R).

args(CFG) ->
  hipe_ppc_registers:args(hipe_ppc_cfg:arity(CFG)).
-endif.
