%% =====================================================================
%% This library is free software; you can redistribute it and/or modify
%% it under the terms of the GNU Lesser General Public License as
%% published by the Free Software Foundation; either version 2 of the
%% License, or (at your option) any later version.
%%
%% This library is distributed in the hope that it will be useful, but
%% WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
%% Lesser General Public License for more details.
%%
%% You should have received a copy of the GNU Lesser General Public
%% License along with this library; if not, write to the Free Software
%% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
%% USA
%%
%% $Id: edoc_run.erl,v 1.11 2004/08/19 09:23:42 richardc Exp $
%%
%% @copyright 2003 Richard Carlsson
%% @author Richard Carlsson <richardc@csd.uu.se>
%% @see edoc
%% @end 
%% =====================================================================

%% @doc Interface for calling EDoc from Erlang startup options.
%% The following is an example of typical usage in a Makefile:
%% <pre>
%% $(DOCDIR)/%.html:%.erl
%%     erl -noshell -run edoc_run file '"$&lt;"' '[{dir,"$(DOCDIR)"}]' -s init stop</pre>
%% (note the single-quotes to avoid shell expansion, and the
%% double-quotes enclosing the strings).

-module(edoc_run).

-export([file/1, application/1, toc/1]).

-import(edoc_report, [report/2, error/1]).


toc(Args) ->
    F = fun () ->
 		case parse_args(Args) of
 		    [Dir, Paths, Opts] -> edoc_index:toc(Dir,Paths,Opts);
 		    _ ->
 			invalid_args("edoc_run:toc/1", Args)
 		end
 	end,
    run(F).

application(Args) ->
    F = fun () ->
		case parse_args(Args) of
		    [App, Opts] -> edoc:application(App, Opts);
		    [App, Dir, Opts] -> edoc:application(App, Dir, Opts);
		    _ ->
			invalid_args("edoc_run:application/1", Args)
		end
	end,
    run(F).


%% @spec ([string()]) -> ok | error
%% @doc Calls {@link edoc:file/2} with the corresponding arguments. The
%% strings in the list are parsed as Erlang constant terms. The list can
%% be either `[File]' or `[File, Options]'. In the first case, an empty
%% list of options is passed to {@link edoc:file/2}. See also the usage
%% example above.

file(Args) ->
    F = fun () ->
		case parse_args(Args) of
		    [File] -> edoc:file(File, []);
		    [File, Opts] -> edoc:file(File, Opts);
		    _ ->
			invalid_args("edoc_run:file/1", Args)
		end
	end,
    run(F).


run(F) ->
    wait_init(),
    case catch {ok, F()} of
	{ok, _} ->
	    ok;
	{'EXIT', E} ->
	    report("edoc terminated abnormally: ~P.", [E, 10]),
	    error;
	Thrown ->
	    report("internal error: throw without catch in edoc: ~P.",
		   [Thrown, 15]),
	    error
    end.

wait_init() ->
    case erlang:whereis(code_server) of
	undefined ->
	    erlang:yield(),
	    wait_init();
	_ ->
	    ok
    end.

parse_args([A | As]) when atom(A) ->
    [parse_arg(atom_to_list(A)) | parse_args(As)];
parse_args([A | As]) ->
    [parse_arg(A) | parse_args(As)];
parse_args([]) ->
    [].

parse_arg(A) ->
    case catch {ok, edoc_parse_expr:parse(A, 1)} of
	{ok, Expr} ->
	    case catch erl_parse:normalise(Expr) of
		{'EXIT', _} ->
		    report("bad argument: '~s':", [A]),
		    exit(error);
		Term ->
		    Term
	    end;
	{error, _, D} ->
	    report("error parsing argument '~s'", [A]),
	    error(D),
	    exit(error)
    end.

invalid_args(Where, Args) ->
    report("invalid arguments to ~s: ~w.", [Where, Args]),
    error.
