%%------------------------------------------------------------
%%
%% Implementation stub file
%% 
%% Target: CosFileTransfer_IllegalOperationException
%% Source: /net/isildur/ldisk/daily_build/otp_prebuild_r13b01.2009-06-07_20/otp_src_R13B01/lib/cosFileTransfer/src/CosFileTransfer.idl
%% IC vsn: 4.2.21
%% 
%% This file is automatically generated. DO NOT EDIT IT.
%%
%%------------------------------------------------------------

-module('CosFileTransfer_IllegalOperationException').
-ic_compiled("4_2_21").


-include("CosFileTransfer.hrl").

-export([tc/0,id/0,name/0]).



%% returns type code
tc() -> {tk_except,"IDL:omg.org/CosFileTransfer/IllegalOperationException:1.0",
                   "IllegalOperationException",
                   [{"reason",{tk_string,0}}]}.

%% returns id
id() -> "IDL:omg.org/CosFileTransfer/IllegalOperationException:1.0".

%% returns name
name() -> "CosFileTransfer_IllegalOperationException".



