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
%% Purpose: The top supervisor for the inets application
%%----------------------------------------------------------------------

-module(httpd_sup).

-behaviour(supervisor).

-include("httpd_verbosity.hrl").

%% public
-export([start/2, start_link/2, stop/1, stop/2, init/1]).


-define(D(F, A), io:format("~p:" ++ F ++ "~n", [?MODULE|A])).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% supervisor callback functions

start(ConfigFile, Verbosity) ->
    case start_link(ConfigFile, Verbosity) of
	{ok, Pid} ->
	    unlink(Pid),
	    {ok, Pid};

	Else ->
	    Else
    end.

    
start_link(ConfigFile, Verbosity) ->
    case get_addr_and_port(ConfigFile) of
	{ok, ConfigList, Addr, Port} ->
	    Name    = make_name(Addr, Port),
	    SupName = {local, Name},
	    supervisor:start_link(SupName, ?MODULE, 
				  [ConfigFile, ConfigList, 
				   Verbosity, Addr, Port]);

	{error, Reason} ->
	    error_logger:error_report(Reason),
	    {stop, Reason};

	Else ->
	    error_logger:error_report(Else),
	    {stop, Else}
    end.

    

stop(Pid) when pid(Pid) ->
    do_stop(Pid);
stop(ConfigFile) when list(ConfigFile) ->
    case get_addr_and_port(ConfigFile) of
	{ok, _, Addr, Port} ->
	    stop(Addr, Port);
	    
	Error ->
	    Error
    end;
stop(StartArgs) ->
    ok.


stop(Addr, Port) when integer(Port) ->
    Name = make_name(Addr, Port), 
    case whereis(Name) of
	Pid when pid(Pid) ->
	    do_stop(Pid),
	    ok;
	_ ->
	    not_started
    end.
    
do_stop(Pid) ->
    exit(Pid, shutdown).


init([ConfigFile, ConfigList, Verbosity, Addr, Port]) -> 
    init(ConfigFile, ConfigList, Verbosity, Addr, Port);
init(BadArg) ->
    {error, {badarg, BadArg}}.

init(ConfigFile, ConfigList, Verbosity, Addr, Port) ->
    Flags = {one_for_one, 0, 1},
    AccSupVerbosity  = get_acc_sup_verbosity(Verbosity),
    MiscSupVerbosity = get_misc_sup_verbosity(Verbosity),
    Sups  = [sup_spec(httpd_acceptor_sup, Addr, Port, AccSupVerbosity), 
	     sup_spec(httpd_misc_sup, Addr, Port, MiscSupVerbosity), 
	     worker_spec(httpd_manager, Addr, Port, ConfigFile, ConfigList, 
			 Verbosity, [gen_server])],
    {ok, {Flags, Sups}}.


sup_spec(Name, Addr, Port, Verbosity) ->
    {{Name, Addr, Port}, 
     {Name, start, [Addr, Port, Verbosity]}, 
     permanent, 2000, supervisor, [Name, supervisor]}.
    
worker_spec(Name, Addr, Port, ConfigFile, ConfigList, Verbosity, Modules) ->
    {{Name, Addr, Port}, 
     {Name, start_link, [ConfigFile, ConfigList, Verbosity]}, 
     permanent, 2000, worker, [Name] ++ Modules}.


make_name(Addr,Port) ->
    httpd_util:make_name("httpd_sup",Addr,Port).


%% get_addr_and_port

get_addr_and_port(ConfigFile) ->
    case httpd_conf:load(ConfigFile) of
	{ok, ConfigList} ->
	    Port = httpd_util:key1search(ConfigList, port, 80),
	    Addr = httpd_util:key1search(ConfigList, bind_address),
	    {ok, ConfigList, Addr, Port};
	Error ->
	    Error
    end.


get_acc_sup_verbosity(V) ->
    case key1search(V, all) of
	undefined ->
	    key1search(V, acceptor_sup_verbosity, ?default_verbosity);
	Verbosity ->
	    Verbosity
    end.


get_misc_sup_verbosity(V) ->
    case key1search(V, all) of
	undefined ->
	    key1search(V, misc_sup_verbosity, ?default_verbosity);
	Verbosity ->
	    Verbosity
    end.


key1search(L, K) ->
    httpd_util:key1search(L, K).

key1search(L, K, D) ->
    httpd_util:key1search(L, K, D).
