%% -*- erlang-indent-level: 2 -*-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copyright (c) 2001 by Erik Johansson.  All Rights Reserved 
%% ====================================================================
%%  Filename : 	hipe_icode_primops.erl
%%  Module   :	hipe_icode_primops
%%  Purpose  :  
%%  Notes    : 
%%  History  :	* 2001-06-13 Erik Johansson (happi@csd.uu.se): 
%%               Created.
%%
%% $Id$
%%

-module(hipe_icode_primops).

-export([is_safe/1, fails/1, pp/2, type/2]).

%% Note that 'unsafe_...' operations are generally "safe", i.e., it is
%% typically unsafe to use them unless you have extra information about
%% the call (e.g., if the types are known). However, if they have been
%% correctly introduced in the code, most of them are also ok to remove
%% if the result is not used.

is_safe(cons) -> true;
is_safe(extra_unsafe_add) -> true;
is_safe(mktuple) -> true;
is_safe(self) -> true;
is_safe(unsafe_add) -> true;
is_safe(unsafe_band) -> true;
is_safe(unsafe_bnot) -> true;
is_safe(unsafe_bor) -> true;
is_safe(unsafe_bxor) -> true;
is_safe(unsafe_element) -> true;
is_safe(unsafe_hd) -> true;
is_safe(unsafe_sub) -> true;
is_safe(unsafe_tag_float) -> true;
is_safe(unsafe_tl) -> true;
is_safe(unsafe_untag_float) -> true;
is_safe({closure_element,_}) -> true;
is_safe({hipe_bsi_primop, bs_get_orig_offset}) -> true;
is_safe({hipe_bsi_primop, bs_get_size}) -> true;
is_safe({hipe_bsi_primop,{bs_get_binary,_Offset,_Flags}}) -> true;
is_safe({hipe_bsi_primop,{bs_get_binary,_Size,_Offset,_Flags}}) -> true;
is_safe({hipe_bsi_primop,{bs_get_binary_all,_Offset,_Flags}}) -> true;
is_safe({hipe_bsi_primop,{bs_get_float,_Offset,_Flags}}) -> true;
is_safe({hipe_bsi_primop,{bs_get_float,_Size,_Offset,_Flags}}) -> true;
is_safe({hipe_bsi_primop,{bs_get_integer,_Offset,_Flags}}) -> true;
is_safe({hipe_bsi_primop,{bs_get_integer,_Size,_Offset,_Flags}}) -> true;
is_safe({mkfun,_,_,_}) -> true;
is_safe({unsafe_element,_}) -> true;
is_safe(_Op) -> false.


fails(cons) -> false;
fails(closure_element) -> false;
fails(fclearerror) -> false;
fails(fp_add) -> false;      
fails(fp_sub) -> false;
fails(fp_mul) -> false;
fails(fp_div) -> false;
fails(mkfun) -> false;
fails(mktuple) -> false;
fails(next_msg) -> false;
fails(unsafe_untag_float) -> false;
fails(unsafe_tag_float) -> false;
fails(unsafe_add) -> false;
fails(unsafe_sub) -> false;
fails(unsafe_bor) -> false;
fails(unsafe_bxor) -> false;
fails(unsafe_bnot) -> false;
fails(unsafe_hd) -> false;
fails(unsafe_tl) -> false;
fails({unsafe_element,_}) -> false;
fails({unsafe_update_element,_}) -> false;
fails(_) -> true.


pp(Op, Dev) ->
  case Op of
    {hipe_bs_primop, BsOp} ->
      case BsOp of 
	{bs_create_space, Size, _} ->
	  io:format(Dev, "bs_create_space<~w>", [Size]);
	{bs_put_binary_all, Flags} -> 
	  io:format(Dev, "bs_put_binary_all<~w>", [Flags]);
	{bs_put_binary, Size} ->
	  io:format(Dev, "bs_put_binary<~w>", [Size]);
	{bs_put_binary, Flags, Size} ->
	  io:format(Dev, "bs_put_binary<~w, ~w>", [Flags, Size]);
	{bs_put_float, Flags, Size, _ConstInfo} ->
	  io:format(Dev, "bs_put_float<~w, ~w>", [Flags, Size]);
	{bs_put_string, String, SizeInBytes} ->
	  io:format(Dev, "bs_put_string<~w, ~w>", [String, SizeInBytes]);
	{bs_put_integer, Bits, Flags, _ConstInfo} ->
	  io:format(Dev, "bs_put_integer<~w, ~w>", [Bits, Flags]);
	{unsafe_bs_put_integer, Bits, Flags, _ConstInfo} ->
	  io:format(Dev, "unsafe_bs_put_integer<~w, ~w>", [Bits, Flags]);
	{bs_skip_bits_all, Flags} ->
	  io:format(Dev, "bs_skip_bits_all<~w>", [Flags]);
	{bs_skip_bits, Unit} ->
	  io:format(Dev, "bs_skip_bits<~w>", [Unit]);
	bs_start_match ->
	  io:format(Dev, "bs_start_match", []);
	{bs_get_integer,Size,Flags} ->
	  io:format(Dev, "bs_get_integer<~w, ~w>", [Size, Flags]);
	{bs_get_float,Size,Flags} ->
	  io:format(Dev, "bs_get_float<~w, ~w>", [Size, Flags]);
	{bs_get_binary,Size,Flags} ->
	  io:format(Dev, "bs_get_binary<~w, ~w>", [Size, Flags]);
	{bs_get_binary_all,Flags} ->
	  io:format(Dev, "bs_get_binary_all<~w>", [Flags]);
	{bs_test_tail,NumBits} ->
	  io:format(Dev, "bs_test_tail<~w>", [NumBits]);
	{bs_restore, Index} ->
	  io:format(Dev, "bs_restore<~w>", [Index]);
	{bs_save, Index} ->
	  io:format(Dev, "bs_save<~w>", [Index]);
	{bs_init,_,_} ->
	  io:format(Dev, "bs_init", []);
	{bs_init,_} ->
	  io:format(Dev, "bs_init", []);
	{bs_init2,Size,_Words,Flags} ->
	  io:format(Dev, "bs_init2<~w, ~w>", [Size, Flags]);
	{bs_init2,_Words,Flags} ->
	  io:format(Dev, "bs_init2<~w>", [Flags]);
	{bs_need_buf, Need} ->
	  io:format(Dev, "bs_need_buf<~w>", [Need]);
	{bs_add, Unit} ->
	  io:format(Dev, "bs_add<~w>", [Unit]);
	{bs_add,Const,Unit} ->
	  io:format(Dev, "bs_add<~w, ~w>", [Const, Unit]);
	bs_bits_to_bytes ->
	  io:format(Dev, "bs_bits_to_bytes", []);
	bs_final ->
	  io:format(Dev, "bs_final", [])


      end;
    {hipe_bsi_primop, BsOp} ->
      case BsOp of
	bs_get_orig ->
	  io:format(Dev, "bs_get_orig", []);
	bs_get_orig_offset ->
	  io:format(Dev, "bs_get_orig_offset", []);
	bs_get_size ->
	  io:format(Dev, "bs_get_size", []);
	{bs_make_size, Unit} ->
	   io:format(Dev, "bs_make_size<~w>", [Unit]);
	bs_add ->
	  io:format(Dev, "bs_add", []);
	bs_div_test ->
	  io:format(Dev, "bs_div_test", []);
	bs_size_test ->
	  io:format(Dev, "bs_size_test", []);
	bs_size_test_all ->
	  io:format(Dev, "bs_size_test_all", []);
	{bs_get_float,Size, Offset, Flags} ->
	  io:format(Dev, "bs_get_float<~w, ~w, ~w>", [Size, Offset, Flags]);
	{bs_get_float,Offset, Flags} ->
	  io:format(Dev, "bs_get_float<~w, ~w>", [Offset, Flags]);
	{bs_get_integer, Size, Offset, Flags} ->
	  io:format(Dev, "bs_get_integer<~w, ~w, ~w>", [Size, Offset, Flags]);
	{bs_get_integer, Offset, Flags} ->
	  io:format(Dev, "bs_get_integer<~w, ~w>", [Offset, Flags]);
	{bs_get_binary, Size, Offset, Flags} ->
	  io:format(Dev, "bs_get_binary<~w, ~w, ~w>", [Size, Offset, Flags]);
	{bs_get_binary, Offset, Flags} ->
	  io:format(Dev, "bs_get_binary<~w, ~w>", [Offset, Flags]);
	{bs_get_binary_all, Offset, Flags} ->
	  io:format(Dev, "bs_get_binary_all<~w, ~w>", [Offset, Flags])
      end;
    {mkfun, {Mod, Fun, Arity}, U, I} ->
      io:format(Dev, "mkfun<~w,~w,~w,~w,~w>", [Mod, Fun, Arity, U, I]);
    {closure_element, N} ->
      io:format(Dev, "closure_element<~w>", [N]);
    {unsafe_element, N} ->
      io:format(Dev, "unsafe_element<~w>", [N]);
    {unsafe_update_element, N} ->
      io:format(Dev, "unsafe_update_element<~w>", [N]);
    {Fun, _Arity} ->
      io:format(Dev, "~w", [Fun]);
    {_M, _F, _A} ->
      exit({bad_primop, Op});
    Fun ->
      io:format(Dev, "~w", [Fun])
  end.

%% ____________________________________________________________________
%%
%% Type handling.
%%

type(Primop, Args) ->
  case Primop of
%%% -----------------------------------------------------
%%% Arithops
    '+' ->
      erl_bif_types:type(erlang, '+', 2, Args);
    '-' ->
      erl_bif_types:type(erlang, '-', 2, Args);
    '*' ->
      erl_bif_types:type(erlang, '*', 2, Args);
    '/' ->
      erl_bif_types:type(erlang, '/', 2, Args);
    'bor' ->
      erl_bif_types:type(erlang, 'bor', 2, Args);
    'band' ->
      erl_bif_types:type(erlang, 'band', 2, Args);
    'bxor' ->
      erl_bif_types:type(erlang, 'bxor', 2, Args);
    'bnot' ->
      erl_bif_types:type(erlang, 'bnot', 2, Args);
    'bsr' ->
      erl_bif_types:type(erlang, 'bsr', 2, Args);
    'bsl' ->
      erl_bif_types:type(erlang, 'bsl', 2, Args);
    unsafe_add ->
      erl_bif_types:type(erlang, '+', 2, Args);
    extra_unsafe_add ->
      erl_bif_types:type(erlang, '+', 2, Args);
    unsafe_sub ->
      erl_bif_types:type(erlang, '-', 2, Args);
    unsafe_bor ->
      erl_bif_types:type(erlang, 'bor', 2, Args);
    unsafe_band ->
      erl_bif_types:type(erlang, 'band', 2, Args);
    unsafe_bxor ->
      erl_bif_types:type(erlang, 'bxor', 2, Args);
    unsafe_bnot ->
      erl_bif_types:type(erlang, 'bnot', 2, Args);
%%% -----------------------------------------------------
%%% Lists
    cons ->
      [HeadType, TailType] = Args,
      erl_types:t_cons(HeadType, TailType);
    unsafe_tl ->
      [Type] = Args,
      case erl_types:t_is_cons(Type) of
	true -> erl_types:t_cons_tl(Type);
	false -> erl_types:t_none()
      end;
    unsafe_hd ->
      [Type] = Args,
      case erl_types:t_is_cons(Type) of
	true -> erl_types:t_cons_hd(Type);
	false -> erl_types:t_none()
      end;
%%% -----------------------------------------------------
%%% Tuples
    mktuple ->
      erl_types:t_tuple(Args);
    unsafe_element ->
      %%% TODO: This is not completely safe. However, those cases
      %%% when it isn't are generated by beam, so they have
      %%% (hopefully) proved that it is.
      [IndexType, TupleType] = Args,
      case erl_types:t_number_vals(IndexType) of
	[N] when is_integer(N)->
	  type({unsafe_element, N}, TupleType);
	_ ->
	  case erl_types:t_is_tuple(TupleType) of
	    false ->
	      erl_types:t_none();
	    true ->
	      erl_bif_types:type(erlang, element, 2, Args)
	  end
      end;
    {unsafe_element, N} ->
      [Type] = Args,
      case erl_types:t_is_tuple(Type) of
	false ->
	  erl_types:t_none();
	true ->
	  Index = erl_types:t_from_term(N),
	  erl_bif_types:type(erlang, element, 2, [Index|Args])
      end;
    {element, _} ->
      erl_bif_types:type(erlang, element, 2, Args);
%%% -----------------------------------------------------
%%% Floats
    unsafe_tag_float ->
      erl_types:t_float();
%%% -----------------------------------------------------
%%% Binaries    
    {hipe_bs_primop, {bs_get_integer, Size, Flags}} ->
      Signed = Flags band 4,
      if length(Args) == 4 -> %% No variable part of the size parameter.
	  if Size < 9, Signed == 0 -> erl_types:t_byte();
	     Size < 21, Signed == 0 -> erl_types:t_char();
	     true -> erl_types:t_integer()
	  end;
	 true -> erl_types:t_integer()
      end;
    {hipe_bs_primop, {bs_get_float, _, _}} ->
      erl_types:t_float();
    {hipe_bs_primop, {bs_get_binary, _, _}} ->
      erl_types:t_binary();
    {hipe_bs_primop, {bs_get_binary_all, _}} ->
      erl_types:t_binary();
    {hipe_bs_primop, bs_final} ->
      erl_types:t_binary();
    {hipe_bsi_primop, {bs_get_integer, _, _}} ->
      erl_types:t_integer();
    {hipe_bsi_primop, {bs_get_integer, Size, _, Flags}} ->
      Signed = Flags band 4,
      if Size < 9, Signed == 0 -> erl_types:t_byte();
	 Size < 21, Signed == 0 -> erl_types:t_char();
	 true -> erl_types:t_integer()
      end;
    {hipe_bsi_primop, {bs_get_float, _, _}} ->
      erl_types:t_float();
    {hipe_bsi_primop, {bs_get_float, _, _, _}} ->
      erl_types:t_float();
    {hipe_bsi_primop, {bs_get_binary, _, _}} ->
	erl_types:t_binary();
    {hipe_bsi_primop, {bs_get_binary, _, _, _}} ->
      erl_types:t_binary();
    {hipe_bsi_primop, {bs_get_binary_all, _, _}} ->
      erl_types:t_binary();
%%% -----------------------------------------------------
%%% Funs
    {mkfun, {_M, _F, A}, _MagicNum, _Index} ->
      %% Note that the arity includes the bound variables in args
      erl_types:t_fun(A - length(Args), erl_types:t_any());
    Op when Op == call_fun; Op == enter_fun ->
      [Fun|TailArgs0] = lists:reverse(Args),
      TailArgs = lists:reverse(TailArgs0),
      case erl_types:t_is_fun(Fun) of
	true ->	  
	  case  erl_types:t_fun_args(Fun) of
	    any ->
	      erl_types:t_any();
	    FunArgs ->
	      case check_fun_args(FunArgs, TailArgs) of
		ok ->
		  erl_types:t_fun_range(Fun);
		error ->
		  erl_types:t_none()
	      end
	  end;
	false ->
	  case erl_types:t_is_fun(erl_types:t_inf(erl_types:t_fun(), Fun)) of
	    true -> 
	      erl_types:t_any();
	    false ->
	      erl_types:t_none()
	  end
      end;
%%% -----------------------------------------------------
%%% Other
    {M, F, A} ->
      erl_bif_types:type(M, F, A, Args);
    _Op ->
      %%exit({"No type information", Op})
      erl_types:t_any()
  end.

check_fun_args([T1|Left1], [T2|Left2]) ->
  Inf = erl_types:t_inf(T1, T2),
  case erl_types:t_inf(Inf, T2) of
    Inf ->
      check_fun_args(Left1, Left2);
    _ ->
      error
  end;
check_fun_args([], []) ->
  ok;
check_fun_args(_, _) ->
  error.
