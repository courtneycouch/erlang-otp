%%----------------------------------------------------------------------
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
%% The Initial Developer of the Original Code is Ericsson Utvecklings AB.
%% Portions created by Ericsson are Copyright 1999, Ericsson Utvecklings
%% AB. All Rights Reserved.''
%% 
%%     $Id$
%%
%%----------------------------------------------------------------------
%% File: orber_tb.erl
%% 
%% Description:
%%    Handling MISC functions.
%%
%% Creation date: 040723
%%
%%----------------------------------------------------------------------
-module(orber_tb).

-include_lib("orber/include/corba.hrl").
-include_lib("orber/src/orber_iiop.hrl").

%%----------------------------------------------------------------------
%% External exports
%%----------------------------------------------------------------------
-export([wait_for_tables/1, wait_for_tables/2,
	 is_loaded/0, is_loaded/1, is_running/0, is_running/1, 
	 info/2, error/2]).

%%----------------------------------------------------------------------
%% Internal exports
%%----------------------------------------------------------------------
-define(DEBUG_LEVEL, 5).

-define(FORMAT(_F, _A), {error, lists:flatten(io_lib:format(_F, _A))}).
-define(EFORMAT(_F, _A), exit(lists:flatten(io_lib:format(_F, _A)))).

%%----------------------------------------------------------------------
%% Record Definitions
%%----------------------------------------------------------------------

%%----------------------------------------------------------------------
%% External functions
%%----------------------------------------------------------------------
%%----------------------------------------------------------------------
%% Function   : is_loaded/is_running
%% Arguments  : 
%% Returns    : 
%% Raises     : 
%% Description: 
%%----------------------------------------------------------------------
is_loaded() ->
    is_loaded(orber).
is_loaded(Appl) ->
    find_application(application:loaded_applications(), Appl).

is_running() ->
    is_running(orber).
is_running(Appl) ->
    find_application(application:which_applications(), Appl).

find_application([], _) ->
    false;
find_application([{Appl, _, _} |_], Appl) ->
    true;
find_application([_ |As], Appl) ->
    find_application(As, Appl).
  
%%----------------------------------------------------------------------
%% function : wait_for_tables/1
%% Arguments: 
%% Returns  : 
%% Exception: 
%% Effect   : 
%%----------------------------------------------------------------------
wait_for_tables(Tables) ->
    wait_for_tables(Tables, 30000).
wait_for_tables(Tables, Timeout) ->
    case mnesia:wait_for_tables(Tables, Timeout) of
	ok ->
	    ok;
	{timeout,  BadTabList} ->
	    info("Mnesia hasn't loaded the following tables (~p msec):~n~p",
		 [Timeout, BadTabList]),
	    mnesia:wait_for_tables(Tables, Timeout);
	{error, Reason} ->
	    error("Mnesia failed to load the some or all of the following"
		  "tables:~n~p", [Tables]),
	    {error, Reason}
    end.

%%----------------------------------------------------------------------
%% function : info/2
%% Arguments: 
%% Returns  : 
%% Exception: 
%% Effect   : 
%%----------------------------------------------------------------------
info(Format, Args) ->
    catch error_logger:info_msg("=================== Orber =================~n"++
				Format++
				"~n===========================================~n",
				Args).

%%----------------------------------------------------------------------
%% function : error/2
%% Arguments: 
%% Returns  : 
%% Exception: 
%% Effect   : 
%%----------------------------------------------------------------------
error(Format, Args) ->
    catch error_logger:error_msg("=================== Orber =================~n"++
				 Format++
				 "~n===========================================~n",
				 Args).


%%----------------------------------------------------------------------
%% Internal functions
%%----------------------------------------------------------------------

%%----------------------------------------------------------------------
%%------------- END OF MODULE ------------------------------------------
%%----------------------------------------------------------------------
