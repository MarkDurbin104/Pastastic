{  Module          MAC Address
   Unit            Class
   Copyright(c)    Postal Solutions Limited 1996..2000
   Author          ASH
   Description     TMAC Address Class Definition - access to machine MAC Address
   Modifications   04/04/2000 - ASH
                              	Original Release
}
unit MACAddrU;

interface

uses
	Windows,SHA1, UUEnc,
	SysUtils,NB30;

type
	TMACAddress = class
  private
  	FAddress : String;
    FDigest			: String;
    procedure SetAddress(Value : String);
  public
  	constructor Create;
  	property Address : string read FAddress write SetAddress;	//formatted MAC Address
    property Digest  : string read FDigest;										//UUEncoded Hashed Digest of MAC Address
  end;

implementation

type
	//required structures for API
  TNBLanaResources = (lrAlloc, lrFree);
  PMACAddressArray = ^TMACAddressArray;
  TMACAddressArray = array[0..5] of Byte;


{===============================================================================
  Class        	None
  Method       	ResetLana
  Description  	Calls NetBIOS function to reset the Lan Adapter
                Must be called before other NetBIOS calls
                See "NetBIOS" API function help
  Params       	LanaNum				: the Lan Adapter (Lana)to reset
                ReqSessions   : max number of sessions
                ReqNames			: max number of names
                LanaRes				: whether resources are to be freed or allocated
  Result       	Byte					: function return code
________________________________________________________________________________}
function ResetLana(LanaNum, ReqSessions, ReqNames: Byte;
  LanaRes: TNBLanaResources): Byte;
var
  ResetNCB: PNCB;
begin
  New(ResetNCB);
  ZeroMemory(ResetNCB, SizeOf(TNCB));
  try
    with ResetNCB^ do
    begin
      ncb_lana_num := Char(LanaNum);        // Set Lana_Num
      ncb_lsn := Char(LanaRes);             // Allocation of new resources
      ncb_callname[0] := Char(ReqSessions); // Query of max sessions
      ncb_callname[1] := #0;                // Query of max NCBs (default)
      ncb_callname[2] := Char(ReqNames);    // Query of max names
      ncb_callname[3] := #0;                // Query of use NAME_NUMBER_1
      ncb_command  := Char(NCBRESET);
      NetBios(ResetNCB);
      Result := Byte(ncb_cmd_cplt);
    end;
  finally
    Dispose(ResetNCB);
  end;
end;

{===============================================================================
  Class        	None
  Method       	GetMACAddress
  Description  	Determines the MAC Address of the given Lan Adapter (Lana) using
							  a NetBIOS function call
                See "NetBIOS" API function help
  Params       	LanaNum			: the Lan Adapter (Lana)
                MACAddress	: contains returned MAC Address
  Result       	Byte				: function return code
________________________________________________________________________________}
function GetMACAddress(LanaNum: Byte; MACAddress: PMACAddressArray): Byte;
var
  AdapterStatus: PAdapterStatus;
  StatNCB: PNCB;
begin
  New(StatNCB);
  ZeroMemory(StatNCB, SizeOf(TNCB));
  StatNCB.ncb_length := SizeOf(TAdapterStatus) +  255 * SizeOf(TNameBuffer);
  GetMem(AdapterStatus, StatNCB.ncb_length);
  try
    with StatNCB^ do
    begin
      ZeroMemory(MACAddress, SizeOf(TMACAddress));
      ncb_buffer := PChar(AdapterStatus);
      ncb_callname := '*              ' + #0;
      ncb_lana_num := Char(LanaNum);
      ncb_command  := Char(NCBASTAT);
      NetBios(StatNCB);
      Result := Byte(ncb_cmd_cplt);
      if Result = NRC_GOODRET then
        MoveMemory(MACAddress, AdapterStatus, SizeOf(TMACAddress));
    end;
  finally
    FreeMem(AdapterStatus);
    Dispose(StatNCB);
  end;
end;

{===============================================================================
  Class        	None
  Method       	ResetandGetMACAddr
  Description  	Resets and returns the MAC Adress of the zeroth Lan Adapter
  Params       	None
  Result       	String	: formatted MAC Address (blank if fails)
________________________________________________________________________________}
function ResetAndGetMACAddr : String;
var
	RetCode : Byte;
  MACAddress: PMACAddressArray;
begin
	//reset Lana
  RetCode := ResetLana(0, 0, 0, lrAlloc);
  If RetCode = NRC_GOODRET then
  begin
    New(MACAddress);
    try
	    RetCode := GetMACAddress(0, MACAddress);
      if RetCode = NRC_GOODRET then
      begin
        Result := Format('%2.2x-%2.2x-%2.2x-%2.2x-%2.2x-%2.2x',
          [MACAddress[0], MACAddress[1], MACAddress[2],
           MACAddress[3], MACAddress[4], MACAddress[5]]);
      end;
    finally
      Dispose(MACAddress);
    end;
  end;

  If RetCode <> NRC_GOODRET then
		Result := '';
end;

{===============================================================================
  Class        	None
  Method       	SHA1DigestString
  Description  	Returns UUencoded Hashed digest using SHA1 algorithm
  Params       	InString 	: String to hash
  Result       	String		: UUEncoded Digest of InString
________________________________________________________________________________}
function SHA1UUDigestString(InString : String)  : String;
var
	Hash : TDcp_Sha1;
  Digest: array[0..19] of byte; // sha1 produces a 160bit digest (20bytes)
  DigestString : String[20];
  DigestIndex : Integer;
begin
	//get hashed digest
  Hash:= TDCP_sha1.Create(nil);
  Hash.Init;
  Hash.UpdateStr(InString);
  Hash.Final(Digest);
  Hash.Free;

  //UUEncode Digest
  SetLength(DigestString, 20);
  For DigestIndex := 1 to Length(DigestString) do
  	DigestString[DigestIndex] := Chr(Digest[DigestIndex]);
  Result := UUEncode(DigestString);
end;

{===============================================================================
  Class        	TMACAddress
  Method       	Create
  Description  	Constructor of class
								Setsup Address property
  Params       	None
  Result       	None
________________________________________________________________________________}
constructor TMACAddress.Create;
begin
	Inherited Create;
  Address := ResetAndGetMACAddr;
end;

{===============================================================================
  Class        	TMACAddress
  Method       	SetAddress
  Description  	Address Property access method
								Changes MAC Address and recalculates UUEncoded Digest
  Params       	None
  Result       	None
________________________________________________________________________________}
procedure TMACAddress.SetAddress(Value : String);
begin
	If FAddress <> Value then
  begin
  	FAddress  := Value;
	  FDigest		:= SHA1UUDigestString(FAddress);
  end;
end;


end.
