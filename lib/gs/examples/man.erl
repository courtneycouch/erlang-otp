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
%% ------------------------------------------------------------
%% Simple Manual Page Browser
%% ------------------------------------------------------------

-module(man).

-export([start/0,init/0]).
-export([man_list/0]).
-export([browser/1,browser_init/2]).
-import(lists,[sort/1,reverse/1,concat/1]).


start() ->
    case whereis(man) of
	undefined ->
	    register(man,Pid=spawn(man,init,[])),
	    Pid;
	Pid ->
	    Pid
    end.


%% ---- Man Directories -----
dirManual() ->
    concat([code:root_dir(), '/man/cat3/']).


%% ----- init -----
init() ->
    S=gs:start(),
    Width=520,Height=520,
    gs:create(window,win,S,[{title,"Manual Browser"},
			    {width,Width},{height,Height}]),
    gs:create(button,quit,win,[{width,60},{label,{text,"Quit"}}]),
    gs:create(button,select,win,[{x,60},{label,{text,"Select Page"}}]),
    gs:create(editor,editor,win,[{y,30},{width,Width},{height,Height-30},
				 {hscroll,false},{vscroll,left}]),
    gs:config(win,[{map,true},{configure,true}]),
    man_loop(Width,Height).

man_loop(Width0,Height0) ->
    receive
	{gs,_Win,configure,_,[Width0,Height0|_]} -> %% already got that size!
	    man_loop(Width0,Height0);
	{gs,_Win,configure,_,[Width,Height|_]} ->
	    %%io:format("man: width=~w, height=~w ~n",[Width,Height]),
	    gs:config(editor,[{width,Width},{height,Height-30}]),
	    man_loop(Width,Height);
	{gs,quit,click,_,_} -> 
	    %%io:format("man: exiting.~n",[]),
	    exit(normal);
	{gs,select,click,_,_} -> 
	    case browser(man_list()) of
		cancel -> true;
		{ok,Page} -> load_page(Page);
		O -> io:format("man: bad browser result: ~w~n",[O])
	    end,
	    man_loop(Width0,Height0);
	{gs,_,destroy,_,_} ->
	    exit(normal);
	X -> 
	    io:format("man: got other: ~w~n",[X]),
	    man_loop(Width0,Height0)
    end.


%% ----- man_list ----
%% Stolen from Wikborg
%%
man_list() ->
    {ok,FirstList} = file:list_dir(dirManual()),
    sort(check_4_last(FirstList)).

check_4_last([]) -> [];
check_4_last([H|T]) ->
    case catch(get_4_last(reverse(H))) of
	[46,116,120,116] -> % ".txt"
	    [remove_4_last(H)|check_4_last(T)];
	_Any ->
	    check_4_last(T)
    end.

get_4_last([H1,H2,H3,H4|_T]) ->
    [H4,H3,H2,H1].

remove_4_last(Str) ->
    reverse(tl(tl(tl(tl(reverse(Str)))))).


%% ------------------------------------------------------------
%% Load in the Page

load_page(Page) ->
    %%io:format("man: load page start.~n",[]),
    Filename = lists:flatten([dirManual(),Page,".txt"]),
    {ok,Bin}=file:read_file(Filename),
    _Txt=binary_to_list(Bin),
    gs:config(editor,{enable,true}),
    gs:config(editor,{load,Filename}),
    gs:config(editor,{enable,false}),
    %%io:format("man: load page done.~n",[]),
    true.

 
%% ------------------------------------------------------------
%% Simple Browser
%% ------------------------------------------------------------

browser(Items) ->
    Browser=spawn_link(man,browser_init,[self(),Items]),
    await_reply(Browser).

await_reply(Browser) ->
    receive
	{browser,Result} -> 
	    Result;
	{gs,_,destroy,_,_} -> exit(normal);
	{gs,quit,click,_,_} -> exit(normal);
	{gs,select,click,_,_} ->
	    Browser ! wake_up,
	    await_reply(Browser)
    end.

browser_init(Pid,Items) ->
    process_flag(trap_exit,true),
    S=gs:start(),
    Win=gs:window(win,S,[{width,250},{height,270},{title,"Browser"}]),
    _Lbl=gs:label(Win,[{label,{text,"Select a Manual Page"}},{width,250}]),
    gs:label(Win,[{width,40},{y,35},{label,{text,"Page:"}}]),
    Entry=gs:entry(Win,[{y,35},{width,205},{x,40},
			{keypress,true},{focus,true}]),
    Lb=gs:listbox(Win,[{x,5},{y,65},{width,160},{height,195},
		       {vscroll,right},{click,true},{doubleclick,true}]),
    Ok=gs:button(Win,[{label,{text,"OK"}},{width,40},{x,185},{y,175}]),
    Cancel=gs:button(Win,[{label,{text,"Cancel"}},{x,175},{y,225},{width,65}]),
    gs:config(Lb,[{items,Items}]),
    gs:config(Win,{map,true}),
    browser_loop(Pid,Ok,Cancel,Entry,Lb).

browser_loop(Pid,Ok,Cancel,Entry,Lb) ->
    receive
	{gs,Ok,click,_,_} ->
	    Txt=gs:read(Entry,text),
	    Pid ! {browser,{ok,Txt}};
	{gs,Cancel,click,_,_} ->
	    Pid ! {browser,cancel};
	{gs,Entry,keypress,_,['Return'|_]} ->
	    Txt=gs:read(Entry,text),
	    Pid ! {browser,{ok,Txt}};
	{gs,Entry,keypress,_,_} ->
	    browser_loop(Pid,Ok,Cancel,Entry,Lb);
	{gs,Lb,click,_,[_Idx, Txt| _Rest]} ->
	    gs:config(Entry,{text,Txt}),
	    browser_loop(Pid,Ok,Cancel,Entry,Lb);
	{gs,Lb,doubleclick,_,[_Idx, Txt| _Rest]} ->
	    Pid ! {browser,{ok,Txt}};
	{gs,_,destroy,_,_} ->
	    Pid ! {browser,cancel};
	wake_up ->
	    gs:config(win,[{iconify,false},raise]),
	    browser_loop(Pid,Ok,Cancel,Entry,Lb);
	{'EXIT',_Man,Why} ->
	    exit(Why);
	X ->
	    io:format("man: browser got other: ~w.~n",[X]),
	    browser_loop(Pid,Ok,Cancel,Entry,Lb)
    end.

%% ------------------------------------------------------------
%% end of man.erl
