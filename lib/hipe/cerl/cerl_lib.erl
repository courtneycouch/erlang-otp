%% ``The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved via the world wide web at http://www.erlang.org/.
%% 
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%% 
%% The Initial Developer of the Original Code is Richard Carlsson.
%% Copyright (C) 1999-2002 Richard Carlsson.
%% Portions created by Ericsson are Copyright 2001, Ericsson Utvecklings
%% AB. All Rights Reserved.''
%% 
%%     $Id$

%% @doc Utility functions for Core Erlang abstract syntax trees.
%%
%% <p>Syntax trees are defined in the module <a
%% href=""><code>cerl</code></a>.</p>
%%
%% @type cerl() = cerl:cerl()

-module(cerl_lib).

-define(NO_UNUSED, true).

-export([is_safe_expr/2, reduce_expr/1]).
-ifndef(NO_UNUSED).
-export([is_safe_expr/1, is_pure_expr/1, is_pure_expr/2]).
-endif.


%% The default function property check always returns `false':

default_check(_Property, _Function) -> false.


%% @spec (Expr::cerl()) -> bool()
%%
%% @doc Returns `true' if `Expr' represents a "safe" Core Erlang
%% expression, otherwise `false'. An expression is safe if it always
%% completes normally and does not modify the state (although the return
%% value may depend on the state).
%%
%% Expressions of type `apply', `case', `receive' and `binary' are
%% always considered unsafe by this function.

%% TODO: update cerl_inline to use these functions instead.

-ifndef(NO_UNUSED).
is_safe_expr(E) ->
    Check = fun default_check/2,
    is_safe_expr(E, Check).
-endif.
%% @clear

is_safe_expr(E, Check) ->
    case cerl:type(E) of
	literal ->
	    true;
	var ->
	    true;
	'fun' ->
	    true;
	values ->
	    is_safe_expr_list(cerl:values_es(E), Check);
	tuple ->
	    is_safe_expr_list(cerl:tuple_es(E), Check);
	cons ->
	    case is_safe_expr(cerl:cons_hd(E), Check) of
		true ->
		    is_safe_expr(cerl:cons_tl(E), Check);
		false ->
		    false
	    end;
	'let' ->
	    case is_safe_expr(cerl:let_arg(E), Check) of
		true ->
		    is_safe_expr(cerl:let_body(E), Check);
		false ->
		    false
	    end;
	letrec ->
	    is_safe_expr(cerl:letrec_body(E), Check);
	seq ->
	    case is_safe_expr(cerl:seq_arg(E), Check) of
		true ->
		    is_safe_expr(cerl:seq_body(E), Check);
		false ->
		    false
	    end;
	'catch' ->
	    is_safe_expr(cerl:catch_body(E), Check);
	'try' ->
	    %% If the guarded expression is safe, the try-handler will
	    %% never be evaluated, so we need only check the body.  If
	    %% the guarded expression is pure, but could fail, we also
	    %% have to check the handler.
	    case is_safe_expr(cerl:try_arg(E), Check) of
		true ->
		    is_safe_expr(cerl:try_body(E), Check);
		false ->
		    case is_pure_expr(cerl:try_arg(E), Check) of
			true ->
			    case is_safe_expr(cerl:try_body(E), Check) of
				true ->
				    is_safe_expr(cerl:try_handler(E), Check);
				false ->
				    false
			    end;
			false ->
			    false
		    end
	    end;
	primop ->
	    Name = cerl:atom_val(cerl:primop_name(E)),
	    As = cerl:primop_args(E),
	    case Check(safe, {Name, length(As)}) of
		true ->
		    is_safe_expr_list(As, Check);
		false ->
		    false
	    end;
	call ->
	    Module = cerl:call_module(E),
	    Name = cerl:call_name(E),
	    case cerl:is_c_atom(Module) and cerl:is_c_atom(Name) of
		true ->
		    M = cerl:atom_val(Module),
		    F = cerl:atom_val(Name),
		    As = cerl:call_args(E),
		    case Check(safe, {M, F, length(As)}) of
			true ->
			    is_safe_expr_list(As, Check);
			false ->
			    false
		    end;
		false ->
		    false    % Call to unknown function
	    end;
	_ ->
	    false
    end.

is_safe_expr_list([E | Es], Check) ->
    case is_safe_expr(E, Check) of
	true ->
	    is_safe_expr_list(Es, Check);
	false ->
	    false
    end;
is_safe_expr_list([], _Check) ->
    true.


%% @spec (Expr::cerl()) -> bool()
%%
%% @doc Returns `true' if `Expr' represents a "pure" Core Erlang
%% expression, otherwise `false'. An expression is pure if it does not
%% affect the state, nor depend on the state, although its evaluation is
%% not guaranteed to complete normally for all input.
%%
%% Expressions of type `apply', `case', `receive' and `binary' are
%% always considered impure by this function.

-ifndef(NO_UNUSED).
is_pure_expr(E) ->
    Check = fun default_check/2,
    is_pure_expr(E, Check).
-endif.
%% @clear

is_pure_expr(E, Check) ->
    case cerl:type(E) of
	literal ->
	    true;
	var ->
	    true;
	'fun' ->
	    true;
	values ->
	    is_pure_expr_list(cerl:values_es(E), Check);
	tuple ->
	    is_pure_expr_list(cerl:tuple_es(E), Check);
	cons ->
	    case is_pure_expr(cerl:cons_hd(E), Check) of
		true ->
		    is_pure_expr(cerl:cons_tl(E), Check);
		false ->
		    false
	    end;
	'let' ->
	    case is_pure_expr(cerl:let_arg(E), Check) of
		true ->
		    is_pure_expr(cerl:let_body(E), Check);
		false ->
		    false
	    end;
	letrec ->
	    is_pure_expr(cerl:letrec_body(E), Check);
	seq ->
	    case is_pure_expr(cerl:seq_arg(E), Check) of
		true ->
		    is_pure_expr(cerl:seq_body(E), Check);
		false ->
		    false
	    end;
	'catch' ->
	    is_pure_expr(cerl:catch_body(E), Check);
	'try' ->
	    case is_pure_expr(cerl:try_arg(E), Check) of
		true ->
		    case is_pure_expr(cerl:try_body(E), Check) of
			true ->
			    is_pure_expr(cerl:try_handler(E), Check);
			false ->
			    false
		    end;
		false ->
		    false
	    end;
	primop ->
	    Name = cerl:atom_val(cerl:primop_name(E)),
	    As = cerl:primop_args(E),
	    case Check(pure, {Name, length(As)}) of
		true ->
		    is_pure_expr_list(As, Check);
		false ->
		    false
	    end;
	call ->
	    Module = cerl:call_module(E),
	    Name = cerl:call_name(E),
	    case cerl:is_c_atom(Module) and cerl:is_c_atom(Name) of
		true ->
		    M = cerl:atom_val(Module),
		    F = cerl:atom_val(Name),
		    As = cerl:call_args(E),
		    case Check(pure, {M, F, length(As)}) of
			true ->
			    is_pure_expr_list(As, Check);
			false ->
			    false
		    end;
		false ->
		    false    % Call to unknown function
	    end;
	_ ->
	    false
    end.

is_pure_expr_list([E | Es], Check) ->
    case is_pure_expr(E, Check) of
	true ->
	    is_pure_expr_list(Es, Check);
	false ->
	    false
    end;
is_pure_expr_list([], _Check) ->
    true.


%% Peephole optimizations
%%
%% This is only intended to be a light-weight cleanup optimizer,
%% removing small things that may e.g. have been generated by other
%% optimization passes or in the translation from higher-level code.
%% It is not recursive in general - it only descends until it can do no
%% more work in the current context.
%%
%% To expose hidden cases of final expressions (enabling last call
%% optimization), we try to remove all trivial let-bindings (`let X = Y
%% in X', `let X = Y in Y', `let X = Y in let ... in ...', `let X = let
%% ... in ... in ...', etc.). We do not, however, try to recognize any
%% other similar cases, even for simple `case'-expressions like `case E
%% of X -> X end', or simultaneous multiple-value bindings.

reduce_expr(E) ->
    Check = fun default_check/2,
    reduce_expr(E, Check).

reduce_expr(E, Check) ->
    case cerl:type(E) of
	values ->
	    case cerl:values_es(E) of
		[E1] ->
		    %% Not really an "optimization" in itself, but
		    %% enables other rewritings by removing the wrapper.
		    reduce_expr(E1, Check);
		_ ->
		    E
	    end;
	'seq' ->
	    %% Rewrite `do <E1> do <E2> <E3>' to `do do <E1> <E2> <E3>'
	    %% so that the "body" of the outermost seq-operator is the
	    %% expression which produces the final result (i.e., E3).
	    %% This can make other optimizations easier; see `let'.
	    A = reduce_expr(cerl:seq_arg(E), Check),
	    B = reduce_expr(cerl:seq_body(E), Check),
	    case cerl:is_c_seq(B) of
		true ->
		    B1 = cerl:seq_arg(B),
		    B2 = cerl:seq_body(B),
		    cerl:c_seq(cerl:c_seq(A, B1), B2);
		false ->
		    cerl:c_seq(A, B)
	    end;
	'let' ->
	    A = reduce_expr(cerl:let_arg(E), Check),
	    case cerl:is_c_seq(A) of
		true ->
		    %% `let X = do <E1> <E2> in Y' is equivalent to `do
		    %% <E1> let X = <E2> in Y'. Note that `<E2>' cannot
		    %% be a seq-operator, due to the `seq' optimization.
		    A1 = cerl:seq_arg(A),
		    A2 = cerl:seq_body(A),
		    E1 = cerl:update_c_let(E, cerl:let_vars(E),
					   A2, cerl:let_body(E)),
		    cerl:c_seq(A1, reduce_expr(E1, Check));
		false ->
		    B = reduce_expr(cerl:let_body(E), Check),
		    Vs = cerl:let_vars(E),
		    %% We give up if the body does not reduce to a
		    %% single variable. This is not a generic copy
		    %% propagation.
		    case cerl:is_c_var(B) of
			true when length(Vs) == 1 ->
			    %% We have `let <V1> = <E> in <V2>':
			    [V] = Vs,
			    N1 = cerl:var_name(V),
			    N2 = cerl:var_name(B),
			    if N1 =:= N2 ->
				    %% `let X = <E> in X' equals `<E>'
				    A;
			       true ->
				    %% `let X = <E> in Y' is equivalent
				    %% to `Y' if and only if `<E>' is
				    %% "safe"; otherwise it is eqivalent
				    %% to `do <E> Y'.
				    case is_safe_expr(A, Check) of
					true ->
					    B;
					false ->
					    cerl:c_seq(A, B)
				    end
			    end;
			_ ->
			    cerl:update_c_let(E, Vs, A, B)
		    end
	    end;
	'try' ->
	    %% Get rid of unnecessary try-expressions.
	    A = reduce_expr(cerl:try_arg(E), Check),
	    B = reduce_expr(cerl:try_body(E), Check),
	    case is_safe_expr(A, Check) of
		true ->
		    B;
		false ->
		    cerl:update_c_try(E, A, cerl:try_vars(E), B,
				      cerl:try_evars(E),
				      cerl:try_handler(E))
	    end;
	'catch' ->
	    %% Just a simpler form of try-expressions.
	    B = reduce_expr(cerl:catch_body(E), Check),
	    case is_safe_expr(B, Check) of
		true ->
		    B;
		false ->
		    cerl:update_c_catch(E, B)
	    end;
	_ ->
	    E
    end.
