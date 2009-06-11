%%
%% %CopyrightBegin%
%% 
%% Copyright Ericsson AB 2009. All Rights Reserved.
%% 
%% The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved online at http://www.erlang.org/.
%% 
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%% 
%% %CopyrightEnd%

-module(ex_cursor).

-behavoiur(wx_object).

%% Client API
-export([start/1]).

%% wx_object callbacks
-export([init/1, terminate/2,  code_change/3,
	 handle_info/2, handle_call/3, handle_event/2]).

-include_lib("wx/include/wx.hrl").

-record(state, 
	{
	  parent,
	  config,
	  cursors,
	  win
	}).

start(Config) ->
    wx_object:start_link(?MODULE, Config, []).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init(Config) ->
    wx:batch(fun() -> do_init(Config) end).

do_init(Config) ->
    Parent = proplists:get_value(parent, Config),  
    Panel = wxScrolledWindow:new(Parent, []),
    wxScrolledWindow:setScrollRate(Panel, 5,5),
    %% Setup sizers
    MainSizer = wxBoxSizer:new(?wxVERTICAL),
    CursorLabels = [Cursor || {Cursor, _} <- cursors()],
    StockCursors = wxRadioBox:new(Panel, ?wxID_ANY, "Stock cursors",
			      ?wxDefaultPosition,
			      ?wxDefaultSize, CursorLabels,
			      [{majorDim, 2},
			       {style, ?wxHORIZONTAL}]),

    Fun = fun(Item, Int) ->
		  CursorId = proplists:get_value(Item, cursors()),
		  Cursor = wxCursor:new(CursorId),
		  case wxCursor:ok(Cursor) of
		      true ->
			  ok;
		      false ->
			  wxRadioBox:enable(StockCursors, Int, [{enable, false}])
		  end,
		  Int+1
	  end,
    wx:foldl(Fun,0, CursorLabels),
    



    MiscSizer = wxStaticBoxSizer:new(?wxVERTICAL, Panel, 
				     [{label, "Misc"}]),
    Win = wxWindow:new(Panel, ?wxID_ANY, [{size, {300,300}}]),
    StaticBoxSizer = wxStaticBoxSizer:new(?wxHORIZONTAL, Panel, [{label, "Test the cursor here"}]),

    ToggleButton = wxToggleButton:new(Panel, ?wxID_ANY, "Begin busy cursor", []),

    %% Add to sizers
    CursorSizer = wxBoxSizer:new(?wxHORIZONTAL),
    wxSizer:add(CursorSizer, StockCursors),
    wxSizer:add(StaticBoxSizer, Win),
    wxSizer:add(CursorSizer, StaticBoxSizer),
    wxSizer:add(MiscSizer, ToggleButton),
    wxToggleButton:connect(ToggleButton, command_togglebutton_clicked, []),

    wxSizer:add(MainSizer, CursorSizer),
    wxSizer:add(MainSizer, MiscSizer),
    wxRadioBox:connect(StockCursors, command_radiobox_selected, []),
    wxPanel:setSizer(Panel, MainSizer),
    {Panel, #state{parent=Panel, config=Config,
		   win = Win}}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Callbacks handled as normal gen_server callbacks
handle_info(Msg, State) ->
    demo:format(State#state.config, "Got Info ~p\n", [Msg]),
    {noreply, State}.

handle_call(Msg, _From, State) ->
    demo:format(State#state.config, "Got Call ~p\n", [Msg]),
    {reply,{error, nyi}, State}.

%% Async Events are handled in handle_event as in handle_info
handle_event(#wx{event = #wxCommand{type = command_radiobox_selected,
				    cmdString = String}},
	     State = #state{}) ->
    wxWindow:refresh(State#state.parent),
    CursorId = proplists:get_value(String, cursors()),
    Cursor = wxCursor:new(CursorId),
    wxWindow:setCursor(State#state.win,  Cursor),
    {noreply, State#state{}};
handle_event(#wx{obj = ToggleButton,
		 event = #wxCommand{type = command_togglebutton_clicked,
				    commandInt = Int}},
	     State = #state{}) ->
    case Int of
	1 ->
	    wx_misc:beginBusyCursor(),
	    wxToggleButton:setLabel(ToggleButton, "End busy cursor");
	0 ->
	    wx_misc:endBusyCursor(),
	    wxToggleButton:setLabel(ToggleButton, "Begin busy cursor")
    end,
    {noreply, State};
handle_event(Ev = #wx{}, State = #state{}) ->
    demo:format(State#state.config, "Got Event ~p\n", [Ev]),
    {noreply, State}.

code_change(_, _, State) ->
    {stop, ignore, State}.

terminate(_Reason, _State) ->
    case wx_misc:isBusy() of
	true ->
	    wx_misc:endBusyCursor();
	false ->
	    ignore
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cursors() ->
    [{"Arrow",          ?wxCURSOR_ARROW},
     {"Right arrow",    ?wxCURSOR_RIGHT_ARROW},
     {"Blank",          ?wxCURSOR_BLANK},
     {"Bullseye",       ?wxCURSOR_BULLSEYE},
     {"Char",           ?wxCURSOR_CHAR},
     {"Cross",          ?wxCURSOR_CROSS},
     {"Hand",           ?wxCURSOR_HAND},
     {"I-beam",         ?wxCURSOR_IBEAM},
     {"Left button",    ?wxCURSOR_LEFT_BUTTON},
     {"Magnifier",      ?wxCURSOR_MAGNIFIER},
     {"Middle button",  ?wxCURSOR_MIDDLE_BUTTON},
     {"No entry",       ?wxCURSOR_NO_ENTRY},
     {"Paint brush",    ?wxCURSOR_PAINT_BRUSH},
     {"Pencil",         ?wxCURSOR_PENCIL},
     {"Point left",     ?wxCURSOR_POINT_LEFT},
     {"Point right",    ?wxCURSOR_POINT_RIGHT},
     {"Question arrow", ?wxCURSOR_QUESTION_ARROW},
     {"Right button",   ?wxCURSOR_RIGHT_BUTTON},
     {"Size NE-SW",     ?wxCURSOR_SIZENESW},
     {"Size N-S",       ?wxCURSOR_SIZENS},
     {"Size NW-SE",     ?wxCURSOR_SIZENWSE},
     {"Size W-E",       ?wxCURSOR_SIZEWE},
     {"Sizing",         ?wxCURSOR_SIZING},
     {"Spraycan",       ?wxCURSOR_SPRAYCAN},
     {"Wait",           ?wxCURSOR_WAIT},
     {"Watch",          ?wxCURSOR_WATCH},
     {"Arrow wait",     ?wxCURSOR_ARROWWAIT}].
