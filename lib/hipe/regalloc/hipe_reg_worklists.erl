%%%----------------------------------------------------------------------
%%% File    : hipe_reg_worklists.erl
%%% Author  : Andreas Wallin <d96awa@csd.uu.se>
%%% Purpose : Represents sets of nodes/temporaries that we are
%%%           working on, such as simplify and spill sets.
%%% Created : 3 Feb 2000 by Andreas Wallin <d96awa@csd.uu.se>
%%%----------------------------------------------------------------------

-module(hipe_reg_worklists).
-author(['Andreas Wallin',  'Thorild Sel�n']).
-export([new/4,
	 simplify/1,
	 spill/1,
	 freeze/1,
	 add_simplify/2,
	 add_freeze/2,
	 remove_simplify/2,
	 remove_spill/2,
	 remove_freeze/2,
	 is_empty_simplify/1,
	 is_empty_spill/1,
	 is_empty_freeze/1,
	 member_freeze/2,
	 %% head/2,
	 %% tail/2,
	 transfer_freeze_simplify/2,
	 transfer_freeze_spill/2
	]).

-record(worklists, 
	{simplify, % Less that K nodes
	 spill,    % Greater than K modes
	 freeze    % Less than K move related nodes
	}).

%%%----------------------------------------------------------------------
%% Function:    new
%%
%% Description: Constructor for worklists structure
%%
%% Parameters:
%%   IG              -- Interference graph
%%   Node_sets       -- Node information
%%   Move_sets       -- Move information
%%   K               -- Number of registers
%%   
%% Returns:
%%   A new worklists data structure
%%
%%%----------------------------------------------------------------------

new(IG, Node_sets, Move_sets, K) ->
    init(hipe_node_sets:initial(Node_sets), K, hipe_ig:degree(IG), Move_sets, empty()).
	 
%% construct an empty initialized worklists data structure
empty() ->
    #worklists{
       simplify = ordsets:new(),
       spill    = ordsets:new(),
       freeze   = ordsets:new()
      }.    

%% Selectors for worklists record

simplify(Worklists) -> Worklists#worklists.simplify.
spill(Worklists)    -> Worklists#worklists.spill.
freeze(Worklists)   -> Worklists#worklists.freeze.

%% Updating worklists records

set_simplify(Simplify, Worklists) ->
    Worklists#worklists{simplify = Simplify}.
set_spill(Spill, Worklists) ->
    Worklists#worklists{spill = Spill}.
set_freeze(Freeze, Worklists) ->
    Worklists#worklists{freeze = Freeze}.


%%----------------------------------------------------------------------
%% Function:    init
%%
%% Description: Initializes worklists
%%
%% Parameters:
%%   Initials        -- Not precoloured temporaries
%%   K               -- Number of registers
%%   Degree          -- Degree information for nodes
%%   Move_sets       -- Move information
%%   Worklists       -- (Empty) worklists structure
%%   
%% Returns:
%%   Initialized worklists structure
%%
%%----------------------------------------------------------------------

init([], _, _, _, Worklists) -> Worklists;
init([Initial|Initials], K, Degree, Move_sets, Worklists) -> 
    case hipe_degree:is_trivially_colorable(Initial, K, Degree) of
	false ->
	    New_worklists = add_spill(Initial, Worklists),
	    init(Initials, K, Degree, Move_sets, New_worklists);
	_ ->
	    case hipe_moves:move_related(Initial, Move_sets) of
		true ->
		    New_worklists = add_freeze(Initial, Worklists),
		    init(Initials, K, Degree, Move_sets, New_worklists);
		_ ->
		    New_worklists = add_simplify(Initial, Worklists),
		    init(Initials, K, Degree, Move_sets, New_worklists)
	    end
    end.

%%%----------------------------------------------------------------------
%% Function:    is_empty
%%
%% Description: Tests if the selected worklist if empty or not.
%%
%% Parameters:
%%   Worklists                -- A worklists data structure
%%   
%% Returns:
%%   true  -- If the worklist was empty
%%   false -- otherwise
%%
%%%----------------------------------------------------------------------

is_empty_simplify(Worklists) ->
    simplify(Worklists) == [].

is_empty_spill(Worklists) ->
    spill(Worklists) == [].

is_empty_freeze(Worklists) ->
    freeze(Worklists) == [].

%%----------------------------------------------------------------------
%% Function:    head
%%
%% Description: Takes out the head (first element) from one of the
%%               worklists.
%%
%% Parameters:
%%   simplify, spill, freeze  -- The worklist you want the first element
%%                                 of
%%   Worklists                -- A worklists data structure
%%   
%% Returns:
%%   First element from selected worklist. The worklists structure is
%%    unchanged.
%%
%%----------------------------------------------------------------------

%% head(simplify, Worklists) ->
%%     [H, _] = simplify(Worklists),
%%     H;
%% head(spill, Worklists) ->
%%     [H, _] = spill(Worklists),
%%     H;
%% head(freeze, Worklists) ->
%%     [H, _] = freeze(Worklists),
%%     H.

%%----------------------------------------------------------------------
%% Function:    tail
%%
%% Description: Takes out the tail (elements after the first) from one 
%%               of the worklists.
%%
%% Parameters:
%%   simplify, spill, freeze  -- The worklist you want the tail of
%%   Worklists                -- A worklists data structure
%%   
%% Returns:
%%   The tail elements from selected worklist. The worklists structure 
%%    is unchanged.
%%
%%----------------------------------------------------------------------

%% tail(simplify, Worklists) ->
%%     [_, T] = simplify(Worklists),
%%     T;
%% tail(spill, Worklists) ->
%%     [_, T] = spill(Worklists),
%%     T;
%% tail(freeze, Worklists) ->
%%     [_, T] = freeze(Worklists),
%%     T.

%%%----------------------------------------------------------------------
% Function:    add
%
% Description: Adds one element to one of the worklists.
%
% Parameters:
%   Element                  -- An element you want to add to the 
%                                selected worklist. The element should 
%                                be a node/temporary.
%   Worklists                -- A worklists data structure
%   
% Returns:
%   An worklists data-structure that have Element in selected 
%    worklist.
%
%%%----------------------------------------------------------------------
add_simplify(Element, Worklists) ->
    Simplify = ordsets:add_element(Element, simplify(Worklists)),
    set_simplify(Simplify, Worklists).

add_spill(Element, Worklists) ->
    Spill = ordsets:add_element(Element, spill(Worklists)),
    set_spill(Spill, Worklists).

add_freeze(Element, Worklists) ->
    Freeze = ordsets:add_element(Element, freeze(Worklists)),
    set_freeze(Freeze, Worklists).

%%%----------------------------------------------------------------------
% Function:    remove
%
% Description: Removes one element to one of the worklists.
%
% Parameters:
%   Element                  -- An element you want to remove from the 
%                                selected worklist. The element should 
%                                be a node/temporary.
%   Worklists                -- A worklists data structure
%   
% Returns:
%   A worklists data-structure that don't have Element in selected 
%    worklist.
%
%%%----------------------------------------------------------------------
remove_simplify(Element, Worklists) ->
    Simplify = ordsets:del_element(Element, simplify(Worklists)),
    set_simplify(Simplify, Worklists).

remove_spill(Element, Worklists) ->
    Spill = ordsets:del_element(Element, spill(Worklists)),
    set_spill(Spill, Worklists).

remove_freeze(Element, Worklists) ->
    Freeze = ordsets:del_element(Element, freeze(Worklists)),
    set_freeze(Freeze, Worklists).

%%%----------------------------------------------------------------------
% Function:    transfer
%
% Description: Moves element from one worklist to another.
%
%%%----------------------------------------------------------------------
transfer_freeze_simplify(Element, Worklists) ->
    add_simplify(Element, remove_freeze(Element, Worklists)).

transfer_freeze_spill(Element, Worklists) ->
    add_spill(Element, remove_freeze(Element, Worklists)).

%%%----------------------------------------------------------------------
% Function:    member
%
% Description: Checks if one element if member of selected worklist.
%
% Parameters:
%   Element                  -- Element you want to know if it's a 
%                                member of selected worklist.
%   Worklists                -- A worklists data structure
%   
% Returns:
%   true   --  if Element is a member of selected worklist
%   false  --  Otherwise
%
%%%----------------------------------------------------------------------

member_freeze(Element, Worklists) ->
    ordsets:is_element(Element, freeze(Worklists)).
