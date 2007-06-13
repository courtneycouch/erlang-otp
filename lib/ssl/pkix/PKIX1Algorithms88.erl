%% Generated by the Erlang ASN.1 BER_V2-compiler version, utilizing bit-syntax:1.4.5
%% Purpose: encoder and decoder to the types in mod PKIX1Algorithms88

-module('PKIX1Algorithms88').
-include("PKIX1Algorithms88.hrl").
-define('RT_BER',asn1rt_ber_bin_v2).
-asn1_info([{vsn,'1.4.5'},
            {module,'PKIX1Algorithms88'},
            {options,[ber_bin_v2,report_errors,{cwd,[47,108,100,105,115,107,47,100,97,105,108,121,95,98,117,105,108,100,47,111,116,112,95,112,114,101,98,117,105,108,100,95,114,49,49,98,46,50,48,48,55,45,48,54,45,49,49,95,49,57,47,111,116,112,95,115,114,99,95,82,49,49,66,45,53,47,108,105,98,47,115,115,108,47,112,107,105,120]},{outdir,[47,108,100,105,115,107,47,100,97,105,108,121,95,98,117,105,108,100,47,111,116,112,95,112,114,101,98,117,105,108,100,95,114,49,49,98,46,50,48,48,55,45,48,54,45,49,49,95,49,57,47,111,116,112,95,115,114,99,95,82,49,49,66,45,53,47,108,105,98,47,115,115,108,47,112,107,105,120]},noobj,optimize,compact_bit_string,der,{i,[46]},{i,[47,108,100,105,115,107,47,100,97,105,108,121,95,98,117,105,108,100,47,111,116,112,95,112,114,101,98,117,105,108,100,95,114,49,49,98,46,50,48,48,55,45,48,54,45,49,49,95,49,57,47,111,116,112,95,115,114,99,95,82,49,49,66,45,53,47,108,105,98,47,115,115,108,47,112,107,105,120]}]}]).

-export([encoding_rule/0]).
-export([
'enc_DSAPublicKey'/2,
'enc_Dss-Parms'/2,
'enc_Dss-Sig-Value'/2,
'enc_RSAPublicKey'/2,
'enc_DHPublicKey'/2,
'enc_DomainParameters'/2,
'enc_ValidationParms'/2,
'enc_KEA-Parms-Id'/2,
'enc_FieldID'/2,
'enc_ECDSA-Sig-Value'/2,
'enc_Prime-p'/2,
'enc_Characteristic-two'/2,
'enc_Trinomial'/2,
'enc_Pentanomial'/2,
'enc_FieldElement'/2,
'enc_ECPoint'/2,
'enc_EcpkParameters'/2,
'enc_ECParameters'/2,
'enc_ECPVer'/2,
'enc_Curve'/2
]).

-export([
'dec_DSAPublicKey'/2,
'dec_Dss-Parms'/2,
'dec_Dss-Sig-Value'/2,
'dec_RSAPublicKey'/2,
'dec_DHPublicKey'/2,
'dec_DomainParameters'/2,
'dec_ValidationParms'/2,
'dec_KEA-Parms-Id'/2,
'dec_FieldID'/2,
'dec_ECDSA-Sig-Value'/2,
'dec_Prime-p'/2,
'dec_Characteristic-two'/2,
'dec_Trinomial'/2,
'dec_Pentanomial'/2,
'dec_FieldElement'/2,
'dec_ECPoint'/2,
'dec_EcpkParameters'/2,
'dec_ECParameters'/2,
'dec_ECPVer'/2,
'dec_Curve'/2
]).

-export([
'md2'/0,
'md5'/0,
'id-sha1'/0,
'id-dsa'/0,
'id-dsa-with-sha1'/0,
'pkcs-1'/0,
'rsaEncryption'/0,
'md2WithRSAEncryption'/0,
'md5WithRSAEncryption'/0,
'sha1WithRSAEncryption'/0,
'dhpublicnumber'/0,
'id-keyExchangeAlgorithm'/0,
'ansi-X9-62'/0,
'id-ecSigType'/0,
'ecdsa-with-SHA1'/0,
'id-fieldType'/0,
'prime-field'/0,
'characteristic-two-field'/0,
'id-characteristic-two-basis'/0,
'gnBasis'/0,
'tpBasis'/0,
'ppBasis'/0,
'id-publicKeyType'/0,
'id-ecPublicKey'/0,
'ellipticCurve'/0,
'c-TwoCurve'/0,
'c2pnb163v1'/0,
'c2pnb163v2'/0,
'c2pnb163v3'/0,
'c2pnb176w1'/0,
'c2tnb191v1'/0,
'c2tnb191v2'/0,
'c2tnb191v3'/0,
'c2onb191v4'/0,
'c2onb191v5'/0,
'c2pnb208w1'/0,
'c2tnb239v1'/0,
'c2tnb239v2'/0,
'c2tnb239v3'/0,
'c2onb239v4'/0,
'c2onb239v5'/0,
'c2pnb272w1'/0,
'c2pnb304w1'/0,
'c2tnb359v1'/0,
'c2pnb368w1'/0,
'c2tnb431r1'/0,
'primeCurve'/0,
'prime192v1'/0,
'prime192v2'/0,
'prime192v3'/0,
'prime239v1'/0,
'prime239v2'/0,
'prime239v3'/0,
'prime256v1'/0
]).

-export([info/0]).


-export([encode/2,decode/2,encode_disp/2,decode_disp/2]).

encoding_rule() ->
   ber_bin_v2.

encode(Type,Data) ->
case catch encode_disp(Type,Data) of
  {'EXIT',{error,Reason}} ->
    {error,Reason};
  {'EXIT',Reason} ->
    {error,{asn1,Reason}};
  {Bytes,_Len} ->
    {ok,Bytes};
  Bytes ->
    {ok,Bytes}
end.

decode(Type,Data) ->
case catch decode_disp(Type,element(1,?RT_BER:decode(Data))
) of
  {'EXIT',{error,Reason}} ->
    {error,Reason};
  {'EXIT',Reason} ->
    {error,{asn1,Reason}};
  Result ->
    {ok,Result}
end.

encode_disp('DSAPublicKey',Data) -> 'enc_DSAPublicKey'(Data);
encode_disp('Dss-Parms',Data) -> 'enc_Dss-Parms'(Data);
encode_disp('Dss-Sig-Value',Data) -> 'enc_Dss-Sig-Value'(Data);
encode_disp('RSAPublicKey',Data) -> 'enc_RSAPublicKey'(Data);
encode_disp('DHPublicKey',Data) -> 'enc_DHPublicKey'(Data);
encode_disp('DomainParameters',Data) -> 'enc_DomainParameters'(Data);
encode_disp('ValidationParms',Data) -> 'enc_ValidationParms'(Data);
encode_disp('KEA-Parms-Id',Data) -> 'enc_KEA-Parms-Id'(Data);
encode_disp('FieldID',Data) -> 'enc_FieldID'(Data);
encode_disp('ECDSA-Sig-Value',Data) -> 'enc_ECDSA-Sig-Value'(Data);
encode_disp('Prime-p',Data) -> 'enc_Prime-p'(Data);
encode_disp('Characteristic-two',Data) -> 'enc_Characteristic-two'(Data);
encode_disp('Trinomial',Data) -> 'enc_Trinomial'(Data);
encode_disp('Pentanomial',Data) -> 'enc_Pentanomial'(Data);
encode_disp('FieldElement',Data) -> 'enc_FieldElement'(Data);
encode_disp('ECPoint',Data) -> 'enc_ECPoint'(Data);
encode_disp('EcpkParameters',Data) -> 'enc_EcpkParameters'(Data);
encode_disp('ECParameters',Data) -> 'enc_ECParameters'(Data);
encode_disp('ECPVer',Data) -> 'enc_ECPVer'(Data);
encode_disp('Curve',Data) -> 'enc_Curve'(Data);
encode_disp(Type,_Data) -> exit({error,{asn1,{undefined_type,Type}}}).


decode_disp('DSAPublicKey',Data) -> 'dec_DSAPublicKey'(Data);
decode_disp('Dss-Parms',Data) -> 'dec_Dss-Parms'(Data);
decode_disp('Dss-Sig-Value',Data) -> 'dec_Dss-Sig-Value'(Data);
decode_disp('RSAPublicKey',Data) -> 'dec_RSAPublicKey'(Data);
decode_disp('DHPublicKey',Data) -> 'dec_DHPublicKey'(Data);
decode_disp('DomainParameters',Data) -> 'dec_DomainParameters'(Data);
decode_disp('ValidationParms',Data) -> 'dec_ValidationParms'(Data);
decode_disp('KEA-Parms-Id',Data) -> 'dec_KEA-Parms-Id'(Data);
decode_disp('FieldID',Data) -> 'dec_FieldID'(Data);
decode_disp('ECDSA-Sig-Value',Data) -> 'dec_ECDSA-Sig-Value'(Data);
decode_disp('Prime-p',Data) -> 'dec_Prime-p'(Data);
decode_disp('Characteristic-two',Data) -> 'dec_Characteristic-two'(Data);
decode_disp('Trinomial',Data) -> 'dec_Trinomial'(Data);
decode_disp('Pentanomial',Data) -> 'dec_Pentanomial'(Data);
decode_disp('FieldElement',Data) -> 'dec_FieldElement'(Data);
decode_disp('ECPoint',Data) -> 'dec_ECPoint'(Data);
decode_disp('EcpkParameters',Data) -> 'dec_EcpkParameters'(Data);
decode_disp('ECParameters',Data) -> 'dec_ECParameters'(Data);
decode_disp('ECPVer',Data) -> 'dec_ECPVer'(Data);
decode_disp('Curve',Data) -> 'dec_Curve'(Data);
decode_disp(Type,_Data) -> exit({error,{asn1,{undefined_type,Type}}}).





info() ->
   case ?MODULE:module_info() of
      MI when is_list(MI) ->
         case lists:keysearch(attributes,1,MI) of
            {value,{_,Attributes}} when is_list(Attributes) ->
               case lists:keysearch(asn1_info,1,Attributes) of
                  {value,{_,Info}} when is_list(Info) ->
                     Info;
                  _ ->
                     []
               end;
            _ ->
               []
         end
   end.


%%================================
%%  DSAPublicKey
%%================================
'enc_DSAPublicKey'(Val) ->
    'enc_DSAPublicKey'(Val, [<<2>>]).


'enc_DSAPublicKey'({'DSAPublicKey',Val}, TagIn) ->
   'enc_DSAPublicKey'(Val, TagIn);

'enc_DSAPublicKey'(Val, TagIn) ->
?RT_BER:encode_integer([], Val, TagIn).


'dec_DSAPublicKey'(Tlv) ->
   'dec_DSAPublicKey'(Tlv, [2]).

'dec_DSAPublicKey'(Tlv, TagIn) ->
?RT_BER:decode_integer(Tlv,[],TagIn).



%%================================
%%  Dss-Parms
%%================================
'enc_Dss-Parms'(Val) ->
    'enc_Dss-Parms'(Val, [<<48>>]).

'enc_Dss-Parms'(Val, TagIn) ->
{_,Cindex1, Cindex2, Cindex3} = Val,

%%-------------------------------------------------
%% attribute p(1) with type INTEGER
%%-------------------------------------------------
   {EncBytes1,EncLen1} = ?RT_BER:encode_integer([], Cindex1, [<<2>>]),

%%-------------------------------------------------
%% attribute q(2) with type INTEGER
%%-------------------------------------------------
   {EncBytes2,EncLen2} = ?RT_BER:encode_integer([], Cindex2, [<<2>>]),

%%-------------------------------------------------
%% attribute g(3) with type INTEGER
%%-------------------------------------------------
   {EncBytes3,EncLen3} = ?RT_BER:encode_integer([], Cindex3, [<<2>>]),

   BytesSoFar = [EncBytes1, EncBytes2, EncBytes3],
LenSoFar = EncLen1 + EncLen2 + EncLen3,
?RT_BER:encode_tags(TagIn, BytesSoFar, LenSoFar).


'dec_Dss-Parms'(Tlv) ->
   'dec_Dss-Parms'(Tlv, [16]).

'dec_Dss-Parms'(Tlv, TagIn) ->
   %%-------------------------------------------------
   %% decode tag and length 
   %%-------------------------------------------------
Tlv1 = ?RT_BER:match_tags(Tlv,TagIn), 

%%-------------------------------------------------
%% attribute p(1) with type INTEGER
%%-------------------------------------------------
[V1|Tlv2] = Tlv1, 
Term1 = ?RT_BER:decode_integer(V1,[],[2]),

%%-------------------------------------------------
%% attribute q(2) with type INTEGER
%%-------------------------------------------------
[V2|Tlv3] = Tlv2, 
Term2 = ?RT_BER:decode_integer(V2,[],[2]),

%%-------------------------------------------------
%% attribute g(3) with type INTEGER
%%-------------------------------------------------
[V3|Tlv4] = Tlv3, 
Term3 = ?RT_BER:decode_integer(V3,[],[2]),

case Tlv4 of
[] -> true;_ -> exit({error,{asn1, {unexpected,Tlv4}}}) % extra fields not allowed
end,
   {'Dss-Parms', Term1, Term2, Term3}.



%%================================
%%  Dss-Sig-Value
%%================================
'enc_Dss-Sig-Value'(Val) ->
    'enc_Dss-Sig-Value'(Val, [<<48>>]).

'enc_Dss-Sig-Value'(Val, TagIn) ->
{_,Cindex1, Cindex2} = Val,

%%-------------------------------------------------
%% attribute r(1) with type INTEGER
%%-------------------------------------------------
   {EncBytes1,EncLen1} = ?RT_BER:encode_integer([], Cindex1, [<<2>>]),

%%-------------------------------------------------
%% attribute s(2) with type INTEGER
%%-------------------------------------------------
   {EncBytes2,EncLen2} = ?RT_BER:encode_integer([], Cindex2, [<<2>>]),

   BytesSoFar = [EncBytes1, EncBytes2],
LenSoFar = EncLen1 + EncLen2,
?RT_BER:encode_tags(TagIn, BytesSoFar, LenSoFar).


'dec_Dss-Sig-Value'(Tlv) ->
   'dec_Dss-Sig-Value'(Tlv, [16]).

'dec_Dss-Sig-Value'(Tlv, TagIn) ->
   %%-------------------------------------------------
   %% decode tag and length 
   %%-------------------------------------------------
Tlv1 = ?RT_BER:match_tags(Tlv,TagIn), 

%%-------------------------------------------------
%% attribute r(1) with type INTEGER
%%-------------------------------------------------
[V1|Tlv2] = Tlv1, 
Term1 = ?RT_BER:decode_integer(V1,[],[2]),

%%-------------------------------------------------
%% attribute s(2) with type INTEGER
%%-------------------------------------------------
[V2|Tlv3] = Tlv2, 
Term2 = ?RT_BER:decode_integer(V2,[],[2]),

case Tlv3 of
[] -> true;_ -> exit({error,{asn1, {unexpected,Tlv3}}}) % extra fields not allowed
end,
   {'Dss-Sig-Value', Term1, Term2}.



%%================================
%%  RSAPublicKey
%%================================
'enc_RSAPublicKey'(Val) ->
    'enc_RSAPublicKey'(Val, [<<48>>]).

'enc_RSAPublicKey'(Val, TagIn) ->
{_,Cindex1, Cindex2} = Val,

%%-------------------------------------------------
%% attribute modulus(1) with type INTEGER
%%-------------------------------------------------
   {EncBytes1,EncLen1} = ?RT_BER:encode_integer([], Cindex1, [<<2>>]),

%%-------------------------------------------------
%% attribute publicExponent(2) with type INTEGER
%%-------------------------------------------------
   {EncBytes2,EncLen2} = ?RT_BER:encode_integer([], Cindex2, [<<2>>]),

   BytesSoFar = [EncBytes1, EncBytes2],
LenSoFar = EncLen1 + EncLen2,
?RT_BER:encode_tags(TagIn, BytesSoFar, LenSoFar).


'dec_RSAPublicKey'(Tlv) ->
   'dec_RSAPublicKey'(Tlv, [16]).

'dec_RSAPublicKey'(Tlv, TagIn) ->
   %%-------------------------------------------------
   %% decode tag and length 
   %%-------------------------------------------------
Tlv1 = ?RT_BER:match_tags(Tlv,TagIn), 

%%-------------------------------------------------
%% attribute modulus(1) with type INTEGER
%%-------------------------------------------------
[V1|Tlv2] = Tlv1, 
Term1 = ?RT_BER:decode_integer(V1,[],[2]),

%%-------------------------------------------------
%% attribute publicExponent(2) with type INTEGER
%%-------------------------------------------------
[V2|Tlv3] = Tlv2, 
Term2 = ?RT_BER:decode_integer(V2,[],[2]),

case Tlv3 of
[] -> true;_ -> exit({error,{asn1, {unexpected,Tlv3}}}) % extra fields not allowed
end,
   {'RSAPublicKey', Term1, Term2}.



%%================================
%%  DHPublicKey
%%================================
'enc_DHPublicKey'(Val) ->
    'enc_DHPublicKey'(Val, [<<2>>]).


'enc_DHPublicKey'({'DHPublicKey',Val}, TagIn) ->
   'enc_DHPublicKey'(Val, TagIn);

'enc_DHPublicKey'(Val, TagIn) ->
?RT_BER:encode_integer([], Val, TagIn).


'dec_DHPublicKey'(Tlv) ->
   'dec_DHPublicKey'(Tlv, [2]).

'dec_DHPublicKey'(Tlv, TagIn) ->
?RT_BER:decode_integer(Tlv,[],TagIn).



%%================================
%%  DomainParameters
%%================================
'enc_DomainParameters'(Val) ->
    'enc_DomainParameters'(Val, [<<48>>]).

'enc_DomainParameters'(Val, TagIn) ->
{_,Cindex1, Cindex2, Cindex3, Cindex4, Cindex5} = Val,

%%-------------------------------------------------
%% attribute p(1) with type INTEGER
%%-------------------------------------------------
   {EncBytes1,EncLen1} = ?RT_BER:encode_integer([], Cindex1, [<<2>>]),

%%-------------------------------------------------
%% attribute g(2) with type INTEGER
%%-------------------------------------------------
   {EncBytes2,EncLen2} = ?RT_BER:encode_integer([], Cindex2, [<<2>>]),

%%-------------------------------------------------
%% attribute q(3) with type INTEGER
%%-------------------------------------------------
   {EncBytes3,EncLen3} = ?RT_BER:encode_integer([], Cindex3, [<<2>>]),

%%-------------------------------------------------
%% attribute j(4) with type INTEGER OPTIONAL
%%-------------------------------------------------
   {EncBytes4,EncLen4} =  case Cindex4 of
         asn1_NOVALUE -> {<<>>,0};
         _ ->
            ?RT_BER:encode_integer([], Cindex4, [<<2>>])
       end,

%%-------------------------------------------------
%% attribute validationParms(5)   External PKIX1Algorithms88:ValidationParms OPTIONAL
%%-------------------------------------------------
   {EncBytes5,EncLen5} =  case Cindex5 of
         asn1_NOVALUE -> {<<>>,0};
         _ ->
            'enc_ValidationParms'(Cindex5, [<<48>>])
       end,

   BytesSoFar = [EncBytes1, EncBytes2, EncBytes3, EncBytes4, EncBytes5],
LenSoFar = EncLen1 + EncLen2 + EncLen3 + EncLen4 + EncLen5,
?RT_BER:encode_tags(TagIn, BytesSoFar, LenSoFar).


'dec_DomainParameters'(Tlv) ->
   'dec_DomainParameters'(Tlv, [16]).

'dec_DomainParameters'(Tlv, TagIn) ->
   %%-------------------------------------------------
   %% decode tag and length 
   %%-------------------------------------------------
Tlv1 = ?RT_BER:match_tags(Tlv,TagIn), 

%%-------------------------------------------------
%% attribute p(1) with type INTEGER
%%-------------------------------------------------
[V1|Tlv2] = Tlv1, 
Term1 = ?RT_BER:decode_integer(V1,[],[2]),

%%-------------------------------------------------
%% attribute g(2) with type INTEGER
%%-------------------------------------------------
[V2|Tlv3] = Tlv2, 
Term2 = ?RT_BER:decode_integer(V2,[],[2]),

%%-------------------------------------------------
%% attribute q(3) with type INTEGER
%%-------------------------------------------------
[V3|Tlv4] = Tlv3, 
Term3 = ?RT_BER:decode_integer(V3,[],[2]),

%%-------------------------------------------------
%% attribute j(4) with type INTEGER OPTIONAL
%%-------------------------------------------------
{Term4,Tlv5} = case Tlv4 of
[{2,V4}|TempTlv5] ->
    {?RT_BER:decode_integer(V4,[],[]), TempTlv5};
    _ ->
        { asn1_NOVALUE, Tlv4}
end,

%%-------------------------------------------------
%% attribute validationParms(5)   External PKIX1Algorithms88:ValidationParms OPTIONAL
%%-------------------------------------------------
{Term5,Tlv6} = case Tlv5 of
[{16,V5}|TempTlv6] ->
    {'dec_ValidationParms'(V5, []), TempTlv6};
    _ ->
        { asn1_NOVALUE, Tlv5}
end,

case Tlv6 of
[] -> true;_ -> exit({error,{asn1, {unexpected,Tlv6}}}) % extra fields not allowed
end,
   {'DomainParameters', Term1, Term2, Term3, Term4, Term5}.



%%================================
%%  ValidationParms
%%================================
'enc_ValidationParms'(Val) ->
    'enc_ValidationParms'(Val, [<<48>>]).

'enc_ValidationParms'(Val, TagIn) ->
{_,Cindex1, Cindex2} = Val,

%%-------------------------------------------------
%% attribute seed(1) with type BIT STRING
%%-------------------------------------------------
   {EncBytes1,EncLen1} = ?RT_BER:encode_bit_string([], Cindex1, [], [<<3>>]),

%%-------------------------------------------------
%% attribute pgenCounter(2) with type INTEGER
%%-------------------------------------------------
   {EncBytes2,EncLen2} = ?RT_BER:encode_integer([], Cindex2, [<<2>>]),

   BytesSoFar = [EncBytes1, EncBytes2],
LenSoFar = EncLen1 + EncLen2,
?RT_BER:encode_tags(TagIn, BytesSoFar, LenSoFar).


'dec_ValidationParms'(Tlv) ->
   'dec_ValidationParms'(Tlv, [16]).

'dec_ValidationParms'(Tlv, TagIn) ->
   %%-------------------------------------------------
   %% decode tag and length 
   %%-------------------------------------------------
Tlv1 = ?RT_BER:match_tags(Tlv,TagIn), 

%%-------------------------------------------------
%% attribute seed(1) with type BIT STRING
%%-------------------------------------------------
[V1|Tlv2] = Tlv1, 
Term1 = ?RT_BER:decode_compact_bit_string(V1,[],[],[3]),

%%-------------------------------------------------
%% attribute pgenCounter(2) with type INTEGER
%%-------------------------------------------------
[V2|Tlv3] = Tlv2, 
Term2 = ?RT_BER:decode_integer(V2,[],[2]),

case Tlv3 of
[] -> true;_ -> exit({error,{asn1, {unexpected,Tlv3}}}) % extra fields not allowed
end,
   {'ValidationParms', Term1, Term2}.



%%================================
%%  KEA-Parms-Id
%%================================
'enc_KEA-Parms-Id'(Val) ->
    'enc_KEA-Parms-Id'(Val, [<<4>>]).


'enc_KEA-Parms-Id'({'KEA-Parms-Id',Val}, TagIn) ->
   'enc_KEA-Parms-Id'(Val, TagIn);

'enc_KEA-Parms-Id'(Val, TagIn) ->
?RT_BER:encode_octet_string([], Val, TagIn).


'dec_KEA-Parms-Id'(Tlv) ->
   'dec_KEA-Parms-Id'(Tlv, [4]).

'dec_KEA-Parms-Id'(Tlv, TagIn) ->
?RT_BER:decode_octet_string(Tlv,[],TagIn).



%%================================
%%  FieldID
%%================================
'enc_FieldID'(Val) ->
    'enc_FieldID'(Val, [<<48>>]).

'enc_FieldID'(Val, TagIn) ->
{_,Cindex1, Cindex2} = Val,

%%-------------------------------------------------
%% attribute fieldType(1) with type OBJECT IDENTIFIER
%%-------------------------------------------------
   {EncBytes1,EncLen1} = ?RT_BER:encode_object_identifier(Cindex1, [<<6>>]),

%%-------------------------------------------------
%% attribute parameters(2) with type ASN1_OPEN_TYPE
%%-------------------------------------------------
   {EncBytes2,EncLen2} = ?RT_BER:encode_open_type(Cindex2, []),

   BytesSoFar = [EncBytes1, EncBytes2],
LenSoFar = EncLen1 + EncLen2,
?RT_BER:encode_tags(TagIn, BytesSoFar, LenSoFar).


'dec_FieldID'(Tlv) ->
   'dec_FieldID'(Tlv, [16]).

'dec_FieldID'(Tlv, TagIn) ->
   %%-------------------------------------------------
   %% decode tag and length 
   %%-------------------------------------------------
Tlv1 = ?RT_BER:match_tags(Tlv,TagIn), 

%%-------------------------------------------------
%% attribute fieldType(1) with type OBJECT IDENTIFIER
%%-------------------------------------------------
[V1|Tlv2] = Tlv1, 
Term1 = ?RT_BER:decode_object_identifier(V1,[6]),

%%-------------------------------------------------
%% attribute parameters(2) with type ASN1_OPEN_TYPE
%%-------------------------------------------------
[V2|Tlv3] = Tlv2, 
Term2 = ?RT_BER:decode_open_type_as_binary(V2,[]),

case Tlv3 of
[] -> true;_ -> exit({error,{asn1, {unexpected,Tlv3}}}) % extra fields not allowed
end,
   {'FieldID', Term1, Term2}.



%%================================
%%  ECDSA-Sig-Value
%%================================
'enc_ECDSA-Sig-Value'(Val) ->
    'enc_ECDSA-Sig-Value'(Val, [<<48>>]).

'enc_ECDSA-Sig-Value'(Val, TagIn) ->
{_,Cindex1, Cindex2} = Val,

%%-------------------------------------------------
%% attribute r(1) with type INTEGER
%%-------------------------------------------------
   {EncBytes1,EncLen1} = ?RT_BER:encode_integer([], Cindex1, [<<2>>]),

%%-------------------------------------------------
%% attribute s(2) with type INTEGER
%%-------------------------------------------------
   {EncBytes2,EncLen2} = ?RT_BER:encode_integer([], Cindex2, [<<2>>]),

   BytesSoFar = [EncBytes1, EncBytes2],
LenSoFar = EncLen1 + EncLen2,
?RT_BER:encode_tags(TagIn, BytesSoFar, LenSoFar).


'dec_ECDSA-Sig-Value'(Tlv) ->
   'dec_ECDSA-Sig-Value'(Tlv, [16]).

'dec_ECDSA-Sig-Value'(Tlv, TagIn) ->
   %%-------------------------------------------------
   %% decode tag and length 
   %%-------------------------------------------------
Tlv1 = ?RT_BER:match_tags(Tlv,TagIn), 

%%-------------------------------------------------
%% attribute r(1) with type INTEGER
%%-------------------------------------------------
[V1|Tlv2] = Tlv1, 
Term1 = ?RT_BER:decode_integer(V1,[],[2]),

%%-------------------------------------------------
%% attribute s(2) with type INTEGER
%%-------------------------------------------------
[V2|Tlv3] = Tlv2, 
Term2 = ?RT_BER:decode_integer(V2,[],[2]),

case Tlv3 of
[] -> true;_ -> exit({error,{asn1, {unexpected,Tlv3}}}) % extra fields not allowed
end,
   {'ECDSA-Sig-Value', Term1, Term2}.



%%================================
%%  Prime-p
%%================================
'enc_Prime-p'(Val) ->
    'enc_Prime-p'(Val, [<<2>>]).


'enc_Prime-p'({'Prime-p',Val}, TagIn) ->
   'enc_Prime-p'(Val, TagIn);

'enc_Prime-p'(Val, TagIn) ->
?RT_BER:encode_integer([], Val, TagIn).


'dec_Prime-p'(Tlv) ->
   'dec_Prime-p'(Tlv, [2]).

'dec_Prime-p'(Tlv, TagIn) ->
?RT_BER:decode_integer(Tlv,[],TagIn).



%%================================
%%  Characteristic-two
%%================================
'enc_Characteristic-two'(Val) ->
    'enc_Characteristic-two'(Val, [<<48>>]).

'enc_Characteristic-two'(Val, TagIn) ->
{_,Cindex1, Cindex2, Cindex3} = Val,

%%-------------------------------------------------
%% attribute m(1) with type INTEGER
%%-------------------------------------------------
   {EncBytes1,EncLen1} = ?RT_BER:encode_integer([], Cindex1, [<<2>>]),

%%-------------------------------------------------
%% attribute basis(2) with type OBJECT IDENTIFIER
%%-------------------------------------------------
   {EncBytes2,EncLen2} = ?RT_BER:encode_object_identifier(Cindex2, [<<6>>]),

%%-------------------------------------------------
%% attribute parameters(3) with type ASN1_OPEN_TYPE
%%-------------------------------------------------
   {EncBytes3,EncLen3} = ?RT_BER:encode_open_type(Cindex3, []),

   BytesSoFar = [EncBytes1, EncBytes2, EncBytes3],
LenSoFar = EncLen1 + EncLen2 + EncLen3,
?RT_BER:encode_tags(TagIn, BytesSoFar, LenSoFar).


'dec_Characteristic-two'(Tlv) ->
   'dec_Characteristic-two'(Tlv, [16]).

'dec_Characteristic-two'(Tlv, TagIn) ->
   %%-------------------------------------------------
   %% decode tag and length 
   %%-------------------------------------------------
Tlv1 = ?RT_BER:match_tags(Tlv,TagIn), 

%%-------------------------------------------------
%% attribute m(1) with type INTEGER
%%-------------------------------------------------
[V1|Tlv2] = Tlv1, 
Term1 = ?RT_BER:decode_integer(V1,[],[2]),

%%-------------------------------------------------
%% attribute basis(2) with type OBJECT IDENTIFIER
%%-------------------------------------------------
[V2|Tlv3] = Tlv2, 
Term2 = ?RT_BER:decode_object_identifier(V2,[6]),

%%-------------------------------------------------
%% attribute parameters(3) with type ASN1_OPEN_TYPE
%%-------------------------------------------------
[V3|Tlv4] = Tlv3, 
Term3 = ?RT_BER:decode_open_type_as_binary(V3,[]),

case Tlv4 of
[] -> true;_ -> exit({error,{asn1, {unexpected,Tlv4}}}) % extra fields not allowed
end,
   {'Characteristic-two', Term1, Term2, Term3}.



%%================================
%%  Trinomial
%%================================
'enc_Trinomial'(Val) ->
    'enc_Trinomial'(Val, [<<2>>]).


'enc_Trinomial'({'Trinomial',Val}, TagIn) ->
   'enc_Trinomial'(Val, TagIn);

'enc_Trinomial'(Val, TagIn) ->
?RT_BER:encode_integer([], Val, TagIn).


'dec_Trinomial'(Tlv) ->
   'dec_Trinomial'(Tlv, [2]).

'dec_Trinomial'(Tlv, TagIn) ->
?RT_BER:decode_integer(Tlv,[],TagIn).



%%================================
%%  Pentanomial
%%================================
'enc_Pentanomial'(Val) ->
    'enc_Pentanomial'(Val, [<<48>>]).

'enc_Pentanomial'(Val, TagIn) ->
{_,Cindex1, Cindex2, Cindex3} = Val,

%%-------------------------------------------------
%% attribute k1(1) with type INTEGER
%%-------------------------------------------------
   {EncBytes1,EncLen1} = ?RT_BER:encode_integer([], Cindex1, [<<2>>]),

%%-------------------------------------------------
%% attribute k2(2) with type INTEGER
%%-------------------------------------------------
   {EncBytes2,EncLen2} = ?RT_BER:encode_integer([], Cindex2, [<<2>>]),

%%-------------------------------------------------
%% attribute k3(3) with type INTEGER
%%-------------------------------------------------
   {EncBytes3,EncLen3} = ?RT_BER:encode_integer([], Cindex3, [<<2>>]),

   BytesSoFar = [EncBytes1, EncBytes2, EncBytes3],
LenSoFar = EncLen1 + EncLen2 + EncLen3,
?RT_BER:encode_tags(TagIn, BytesSoFar, LenSoFar).


'dec_Pentanomial'(Tlv) ->
   'dec_Pentanomial'(Tlv, [16]).

'dec_Pentanomial'(Tlv, TagIn) ->
   %%-------------------------------------------------
   %% decode tag and length 
   %%-------------------------------------------------
Tlv1 = ?RT_BER:match_tags(Tlv,TagIn), 

%%-------------------------------------------------
%% attribute k1(1) with type INTEGER
%%-------------------------------------------------
[V1|Tlv2] = Tlv1, 
Term1 = ?RT_BER:decode_integer(V1,[],[2]),

%%-------------------------------------------------
%% attribute k2(2) with type INTEGER
%%-------------------------------------------------
[V2|Tlv3] = Tlv2, 
Term2 = ?RT_BER:decode_integer(V2,[],[2]),

%%-------------------------------------------------
%% attribute k3(3) with type INTEGER
%%-------------------------------------------------
[V3|Tlv4] = Tlv3, 
Term3 = ?RT_BER:decode_integer(V3,[],[2]),

case Tlv4 of
[] -> true;_ -> exit({error,{asn1, {unexpected,Tlv4}}}) % extra fields not allowed
end,
   {'Pentanomial', Term1, Term2, Term3}.



%%================================
%%  FieldElement
%%================================
'enc_FieldElement'(Val) ->
    'enc_FieldElement'(Val, [<<4>>]).


'enc_FieldElement'({'FieldElement',Val}, TagIn) ->
   'enc_FieldElement'(Val, TagIn);

'enc_FieldElement'(Val, TagIn) ->
?RT_BER:encode_octet_string([], Val, TagIn).


'dec_FieldElement'(Tlv) ->
   'dec_FieldElement'(Tlv, [4]).

'dec_FieldElement'(Tlv, TagIn) ->
?RT_BER:decode_octet_string(Tlv,[],TagIn).



%%================================
%%  ECPoint
%%================================
'enc_ECPoint'(Val) ->
    'enc_ECPoint'(Val, [<<4>>]).


'enc_ECPoint'({'ECPoint',Val}, TagIn) ->
   'enc_ECPoint'(Val, TagIn);

'enc_ECPoint'(Val, TagIn) ->
?RT_BER:encode_octet_string([], Val, TagIn).


'dec_ECPoint'(Tlv) ->
   'dec_ECPoint'(Tlv, [4]).

'dec_ECPoint'(Tlv, TagIn) ->
?RT_BER:decode_octet_string(Tlv,[],TagIn).



%%================================
%%  EcpkParameters
%%================================
'enc_EcpkParameters'(Val) ->
    'enc_EcpkParameters'(Val, []).


'enc_EcpkParameters'({'EcpkParameters',Val}, TagIn) ->
   'enc_EcpkParameters'(Val, TagIn);

'enc_EcpkParameters'(Val, TagIn) ->
   {EncBytes,EncLen} = case element(1,Val) of
      ecParameters ->
         'enc_ECParameters'(element(2,Val), [<<48>>]);
      namedCurve ->
         ?RT_BER:encode_object_identifier(element(2,Val), [<<6>>]);
      implicitlyCA ->
         ?RT_BER:encode_null(element(2,Val), [<<5>>]);
      Else -> 
         exit({error,{asn1,{invalid_choice_type,Else}}})
   end,

?RT_BER:encode_tags(TagIn, EncBytes, EncLen).




'dec_EcpkParameters'(Tlv) ->
   'dec_EcpkParameters'(Tlv, []).

'dec_EcpkParameters'(Tlv, TagIn) ->
Tlv1 = ?RT_BER:match_tags(Tlv,TagIn), 
case (case Tlv1 of [CtempTlv1] -> CtempTlv1; _ -> Tlv1 end) of

%% 'ecParameters'
    {16, V1} -> 
        {ecParameters, 'dec_ECParameters'(V1, [])};


%% 'namedCurve'
    {6, V1} -> 
        {namedCurve, ?RT_BER:decode_object_identifier(V1,[])};


%% 'implicitlyCA'
    {5, V1} -> 
        {implicitlyCA, ?RT_BER:decode_null(V1,[])};

      Else -> 
         exit({error,{asn1,{invalid_choice_tag,Else}}})
   end
.


%%================================
%%  ECParameters
%%================================
'enc_ECParameters'(Val) ->
    'enc_ECParameters'(Val, [<<48>>]).

'enc_ECParameters'(Val, TagIn) ->
{_,Cindex1, Cindex2, Cindex3, Cindex4, Cindex5, Cindex6} = Val,

%%-------------------------------------------------
%% attribute version(1) with type INTEGER
%%-------------------------------------------------
   {EncBytes1,EncLen1} = ?RT_BER:encode_integer([], Cindex1, [{ecpVer1,1}], [<<2>>]),

%%-------------------------------------------------
%% attribute fieldID(2)   External PKIX1Algorithms88:FieldID
%%-------------------------------------------------
   {EncBytes2,EncLen2} = 'enc_FieldID'(Cindex2, [<<48>>]),

%%-------------------------------------------------
%% attribute curve(3)   External PKIX1Algorithms88:Curve
%%-------------------------------------------------
   {EncBytes3,EncLen3} = 'enc_Curve'(Cindex3, [<<48>>]),

%%-------------------------------------------------
%% attribute base(4) with type OCTET STRING
%%-------------------------------------------------
   {EncBytes4,EncLen4} = ?RT_BER:encode_octet_string([], Cindex4, [<<4>>]),

%%-------------------------------------------------
%% attribute order(5) with type INTEGER
%%-------------------------------------------------
   {EncBytes5,EncLen5} = ?RT_BER:encode_integer([], Cindex5, [<<2>>]),

%%-------------------------------------------------
%% attribute cofactor(6) with type INTEGER OPTIONAL
%%-------------------------------------------------
   {EncBytes6,EncLen6} =  case Cindex6 of
         asn1_NOVALUE -> {<<>>,0};
         _ ->
            ?RT_BER:encode_integer([], Cindex6, [<<2>>])
       end,

   BytesSoFar = [EncBytes1, EncBytes2, EncBytes3, EncBytes4, EncBytes5, EncBytes6],
LenSoFar = EncLen1 + EncLen2 + EncLen3 + EncLen4 + EncLen5 + EncLen6,
?RT_BER:encode_tags(TagIn, BytesSoFar, LenSoFar).


'dec_ECParameters'(Tlv) ->
   'dec_ECParameters'(Tlv, [16]).

'dec_ECParameters'(Tlv, TagIn) ->
   %%-------------------------------------------------
   %% decode tag and length 
   %%-------------------------------------------------
Tlv1 = ?RT_BER:match_tags(Tlv,TagIn), 

%%-------------------------------------------------
%% attribute version(1) with type INTEGER
%%-------------------------------------------------
[V1|Tlv2] = Tlv1, 
Term1 = ?RT_BER:decode_integer(V1,[],[{ecpVer1,1}],[2]),

%%-------------------------------------------------
%% attribute fieldID(2)   External PKIX1Algorithms88:FieldID
%%-------------------------------------------------
[V2|Tlv3] = Tlv2, 
Term2 = 'dec_FieldID'(V2, [16]),

%%-------------------------------------------------
%% attribute curve(3)   External PKIX1Algorithms88:Curve
%%-------------------------------------------------
[V3|Tlv4] = Tlv3, 
Term3 = 'dec_Curve'(V3, [16]),

%%-------------------------------------------------
%% attribute base(4) with type OCTET STRING
%%-------------------------------------------------
[V4|Tlv5] = Tlv4, 
Term4 = ?RT_BER:decode_octet_string(V4,[],[4]),

%%-------------------------------------------------
%% attribute order(5) with type INTEGER
%%-------------------------------------------------
[V5|Tlv6] = Tlv5, 
Term5 = ?RT_BER:decode_integer(V5,[],[2]),

%%-------------------------------------------------
%% attribute cofactor(6) with type INTEGER OPTIONAL
%%-------------------------------------------------
{Term6,Tlv7} = case Tlv6 of
[{2,V6}|TempTlv7] ->
    {?RT_BER:decode_integer(V6,[],[]), TempTlv7};
    _ ->
        { asn1_NOVALUE, Tlv6}
end,

case Tlv7 of
[] -> true;_ -> exit({error,{asn1, {unexpected,Tlv7}}}) % extra fields not allowed
end,
   {'ECParameters', Term1, Term2, Term3, Term4, Term5, Term6}.



%%================================
%%  ECPVer
%%================================
'enc_ECPVer'(Val) ->
    'enc_ECPVer'(Val, [<<2>>]).


'enc_ECPVer'({'ECPVer',Val}, TagIn) ->
   'enc_ECPVer'(Val, TagIn);

'enc_ECPVer'(Val, TagIn) ->
?RT_BER:encode_integer([], Val, [{ecpVer1,1}], TagIn).


'dec_ECPVer'(Tlv) ->
   'dec_ECPVer'(Tlv, [2]).

'dec_ECPVer'(Tlv, TagIn) ->
?RT_BER:decode_integer(Tlv,[],[{ecpVer1,1}],TagIn).



%%================================
%%  Curve
%%================================
'enc_Curve'(Val) ->
    'enc_Curve'(Val, [<<48>>]).

'enc_Curve'(Val, TagIn) ->
{_,Cindex1, Cindex2, Cindex3} = Val,

%%-------------------------------------------------
%% attribute a(1) with type OCTET STRING
%%-------------------------------------------------
   {EncBytes1,EncLen1} = ?RT_BER:encode_octet_string([], Cindex1, [<<4>>]),

%%-------------------------------------------------
%% attribute b(2) with type OCTET STRING
%%-------------------------------------------------
   {EncBytes2,EncLen2} = ?RT_BER:encode_octet_string([], Cindex2, [<<4>>]),

%%-------------------------------------------------
%% attribute seed(3) with type BIT STRING OPTIONAL
%%-------------------------------------------------
   {EncBytes3,EncLen3} =  case Cindex3 of
         asn1_NOVALUE -> {<<>>,0};
         _ ->
            ?RT_BER:encode_bit_string([], Cindex3, [], [<<3>>])
       end,

   BytesSoFar = [EncBytes1, EncBytes2, EncBytes3],
LenSoFar = EncLen1 + EncLen2 + EncLen3,
?RT_BER:encode_tags(TagIn, BytesSoFar, LenSoFar).


'dec_Curve'(Tlv) ->
   'dec_Curve'(Tlv, [16]).

'dec_Curve'(Tlv, TagIn) ->
   %%-------------------------------------------------
   %% decode tag and length 
   %%-------------------------------------------------
Tlv1 = ?RT_BER:match_tags(Tlv,TagIn), 

%%-------------------------------------------------
%% attribute a(1) with type OCTET STRING
%%-------------------------------------------------
[V1|Tlv2] = Tlv1, 
Term1 = ?RT_BER:decode_octet_string(V1,[],[4]),

%%-------------------------------------------------
%% attribute b(2) with type OCTET STRING
%%-------------------------------------------------
[V2|Tlv3] = Tlv2, 
Term2 = ?RT_BER:decode_octet_string(V2,[],[4]),

%%-------------------------------------------------
%% attribute seed(3) with type BIT STRING OPTIONAL
%%-------------------------------------------------
{Term3,Tlv4} = case Tlv3 of
[{3,V3}|TempTlv4] ->
    {?RT_BER:decode_compact_bit_string(V3,[],[],[]), TempTlv4};
    _ ->
        { asn1_NOVALUE, Tlv3}
end,

case Tlv4 of
[] -> true;_ -> exit({error,{asn1, {unexpected,Tlv4}}}) % extra fields not allowed
end,
   {'Curve', Term1, Term2, Term3}.

'md2'() ->
{1,2,840,113549,2,2}.

'md5'() ->
{1,2,840,113549,2,5}.

'id-sha1'() ->
{1,3,14,3,2,26}.

'id-dsa'() ->
{1,2,840,10040,4,1}.

'id-dsa-with-sha1'() ->
{1,2,840,10040,4,3}.

'pkcs-1'() ->
{1,2,840,113549,1,1}.

'rsaEncryption'() ->
{1,2,840,113549,1,1,1}.

'md2WithRSAEncryption'() ->
{1,2,840,113549,1,1,2}.

'md5WithRSAEncryption'() ->
{1,2,840,113549,1,1,4}.

'sha1WithRSAEncryption'() ->
{1,2,840,113549,1,1,5}.

'dhpublicnumber'() ->
{1,2,840,10046,2,1}.

'id-keyExchangeAlgorithm'() ->
{2,16,840,1,101,2,1,1,22}.

'ansi-X9-62'() ->
{1,2,840,10045}.

'id-ecSigType'() ->
{1,2,840,10045,4}.

'ecdsa-with-SHA1'() ->
{1,2,840,10045,4,1}.

'id-fieldType'() ->
{1,2,840,10045,1}.

'prime-field'() ->
{1,2,840,10045,1,1}.

'characteristic-two-field'() ->
{1,2,840,10045,1,2}.

'id-characteristic-two-basis'() ->
{1,2,840,10045,1,2,3}.

'gnBasis'() ->
{1,2,840,10045,1,2,3,1}.

'tpBasis'() ->
{1,2,840,10045,1,2,3,2}.

'ppBasis'() ->
{1,2,840,10045,1,2,3,3}.

'id-publicKeyType'() ->
{1,2,840,10045,2}.

'id-ecPublicKey'() ->
{1,2,840,10045,2,1}.

'ellipticCurve'() ->
{1,2,840,10045,3}.

'c-TwoCurve'() ->
{1,2,840,10045,3,0}.

'c2pnb163v1'() ->
{1,2,840,10045,3,0,1}.

'c2pnb163v2'() ->
{1,2,840,10045,3,0,2}.

'c2pnb163v3'() ->
{1,2,840,10045,3,0,3}.

'c2pnb176w1'() ->
{1,2,840,10045,3,0,4}.

'c2tnb191v1'() ->
{1,2,840,10045,3,0,5}.

'c2tnb191v2'() ->
{1,2,840,10045,3,0,6}.

'c2tnb191v3'() ->
{1,2,840,10045,3,0,7}.

'c2onb191v4'() ->
{1,2,840,10045,3,0,8}.

'c2onb191v5'() ->
{1,2,840,10045,3,0,9}.

'c2pnb208w1'() ->
{1,2,840,10045,3,0,10}.

'c2tnb239v1'() ->
{1,2,840,10045,3,0,11}.

'c2tnb239v2'() ->
{1,2,840,10045,3,0,12}.

'c2tnb239v3'() ->
{1,2,840,10045,3,0,13}.

'c2onb239v4'() ->
{1,2,840,10045,3,0,14}.

'c2onb239v5'() ->
{1,2,840,10045,3,0,15}.

'c2pnb272w1'() ->
{1,2,840,10045,3,0,16}.

'c2pnb304w1'() ->
{1,2,840,10045,3,0,17}.

'c2tnb359v1'() ->
{1,2,840,10045,3,0,18}.

'c2pnb368w1'() ->
{1,2,840,10045,3,0,19}.

'c2tnb431r1'() ->
{1,2,840,10045,3,0,20}.

'primeCurve'() ->
{1,2,840,10045,3,1}.

'prime192v1'() ->
{1,2,840,10045,3,1,1}.

'prime192v2'() ->
{1,2,840,10045,3,1,2}.

'prime192v3'() ->
{1,2,840,10045,3,1,3}.

'prime239v1'() ->
{1,2,840,10045,3,1,4}.

'prime239v2'() ->
{1,2,840,10045,3,1,5}.

'prime239v3'() ->
{1,2,840,10045,3,1,6}.

'prime256v1'() ->
{1,2,840,10045,3,1,7}.
