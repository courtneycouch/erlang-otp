%% hipe_x86_ext_format.hrl
%% Definitions for unified external object format
%% Currently: sparc, x86, amd64
%% Authors: Erik Johansson, Ulf Magnusson

-define(LOAD_ATOM,0).
-define(LOAD_ADDRESS,1).
-define(CALL_REMOTE,2).
-define(CALL_LOCAL,3).
-define(SDESC,4).
-define(X86ABSPCREL,5).

-define(TERM,0).
-define(BLOCK,1).
-define(SORTEDBLOCK,2).

-define(TRUE,1).
-define(FALSE,0).


-define(CONST_TYPE2EXT(T),
	case T of
	    term -> ?TERM;
	    sorted_block -> ?SORTEDBLOCK;
            block -> ?BLOCK
        end).

-define(EXT2CONST_TYPE(E),
	case E of
	    ?TERM -> term;
	    ?SORTEDBLOCK -> sorted_block;
	    ?BLOCK -> block
	end).

-define(BOOL2EXT(B),
	case B of
	    true -> ?TRUE;
	    false -> ?FALSE
        end).

-define(EXT2BOOL(E),
	case E of
	    ?TRUE -> true;
	    ?FALSE -> false
	end).

-define(PATCH_TYPE2EXT(A),
	case A of
	    load_atom -> ?LOAD_ATOM;
	    load_address -> ?LOAD_ADDRESS;
	    sdesc -> ?SDESC;
	    x86_abs_pcrel -> ?X86ABSPCREL;
	    call_local -> ?CALL_LOCAL;
	    call_remote -> ?CALL_REMOTE
        end).

-define(EXT2PATCH_TYPE(E),
	case E of
	    ?LOAD_ATOM -> load_atom;
	    ?LOAD_ADDRESS -> load_address;
	    ?SDESC -> sdesc;
	    ?X86ABSPCREL -> x86_abs_pcrel;
	    ?CALL_REMOTE -> call_remote;
	    ?CALL_LOCAL -> call_local
	end).

-define(STACK_DESC(ExnRA, FSize, Arity, Live), {ExnRA, FSize, Arity, Live}).
