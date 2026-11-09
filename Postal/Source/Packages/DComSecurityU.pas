unit DComSecurityU;

interface

uses
	Windows;

type
	TAuthenticationLevel = (alDefault, alNone, alConnect, alCall,
      alPacket,alPacketIntegrity,alPacketPrivacy);

  TImpersonationLevel= (ilNone, ilAnonymous, ilIdentify,
       ilImpersonate,ilDelegate);


const
  COINIT_MULTITHREADED     = 0;  // OLE calls objects on any thread.
  COINIT_APARTMENTTHREADED = 2;  // Apartment model
  COINIT_DISABLE_OLE1DDE   = 4;  // Don't use DDE for Ole1 support.
  COINIT_SPEED_OVER_MEMORY = 8;  // Trade memory for speed.


  RPC_C_AUTHN_LEVEL_DEFAULT     		= 0;
  RPC_C_AUTHN_LEVEL_NONE          	= 1;
  RPC_C_AUTHN_LEVEL_CONNECT      		= 2;
  RPC_C_AUTHN_LEVEL_CALL          	= 3;
  RPC_C_AUTHN_LEVEL_PKT          		= 4;
  RPC_C_AUTHN_LEVEL_PKT_INTEGRITY 	= 5;
  RPC_C_AUTHN_LEVEL_PKT_PRIVACY  		= 6;

  RPC_C_IMP_LEVEL_ANONYMOUS      		= 1;
  RPC_C_IMP_LEVEL_IDENTIFY        	= 2;
  RPC_C_IMP_LEVEL_IMPERSONATE    		= 3;
  RPC_C_IMP_LEVEL_DELEGATE        	= 4;

  POLICY_VIEW_LOCAL_INFORMATION     = $00000001;
  POLICY_VIEW_AUDIT_INFORMATION     = $00000002;
  POLICY_GET_PRIVATE_INFORMATION    = $00000004;
  POLICY_TRUST_ADMIN                = $00000008;
  POLICY_CREATE_ACCOUNT             = $00000010;
  POLICY_CREATE_SECRET              = $00000020;
  POLICY_CREATE_PRIVILEGE           = $00000040;
  POLICY_SET_DEFAULT_QUOTA_LIMITS   = $00000080;
  POLICY_SET_AUDIT_REQUIREMENTS     = $00000100;
  POLICY_AUDIT_LOG_ADMIN            = $00000200;
  POLICY_SERVER_ADMIN               = $00000400;
  POLICY_LOOKUP_NAMES               = $00000800;
  POLICY_NOTIFICATION               = $00001000;



type
	USHORT = Word;
  PWSTR = PWideChar;
	_LSA_UNICODE_STRING = record
		Length 				: USHORT;
  	MaximumLength : USHORT;
  	Buffer				: PWSTR;
  end;
  LSA_UNICODE_STRING = _LSA_UNICODE_STRING;
  PLSA_UNICODE_STRING = ^LSA_UNICODE_STRING;

  ULONG 	= LongInt;
  HANDLE 	= THandle;
  PVOID  	= Pointer;
  _LSA_OBJECT_ATTRIBUTES = record
  	Length 										: ULONG;
  	RootDirectory 						: HANDLE;
  	ObjectName 								: PLSA_UNICODE_STRING;
  	Attributes								: ULONG;
  	SecurityDescriptor				: PVOID;
  	SecurityQualityOfService 	: PVOID;
  end;
  LSA_OBJECT_ATTRIBUTES = _LSA_OBJECT_ATTRIBUTES;
  PLSA_OBJECT_ATTRIBUTES = ^LSA_OBJECT_ATTRIBUTES;

  ACCESS_MASK = DWORD ;

  LSA_HANDLE 	= Pointer;
  PLSA_HANDLE = ^LSA_HANDLE;
	NTSTATUS    = LongInt;
  PNTSTATUS		= ^NTSTATUS;



implementation

uses
  ActiveX, ComObj, SysUtils;

var
  SaveInitProc: Pointer;
  NeedToUninitialize: Boolean;

	function LsaOpenPolicy(	SystemName  			: PLSA_UNICODE_STRING ;
  												ObjectAttributes 	: PLSA_OBJECT_ATTRIBUTES;
  												DesiredAccess			: ACCESS_MASK;
  												PolicyHandle			: PLSA_HANDLE
											  ) :  NTSTATUS cdecl  {$IFDEF WIN32} stdcall {$ENDIF}; external 'NTSECAPI';

  function LsaStorePrivateData(	PolicyHandle 	: LSA_HANDLE;
  															KeyName 		 	: PLSA_UNICODE_STRING;
  															PrivateData 	: PLSA_UNICODE_STRING
															) : NTSTATUS cdecl  {$IFDEF WIN32} stdcall {$ENDIF}; external 'NTSECAPI';

  function LsaClose( ObjectHandle  : LSA_HANDLE ) : NTSTATUS cdecl  {$IFDEF WIN32} stdcall {$ENDIF}; external 'NTSECAPI';


function WideStrToUnicodeStr(WideStr : WideString) : LSA_UNICODE_STRING;
begin
	Result.Length 			 := Length(WideStr) * SizeOf(WideChar);
  Result.MaximumLength := (Length(WideStr) + 1) * SizeOf(WideChar);
  Result.Buffer 			 := PWideChar(WideStr);

end;

// SetCOMRunAsPassword sets the corresponding password
// for the RunAs principal for a given AppID into the
// LSA as a secret. This allows the COM SCM to look it up
// and call LogonUser / CreateProcessAsUser to launch your
// COM server using the security principal of your choice.
procedure SetCOMRunAsPassword( const AppID, Password  : String);
var
  hPolicy 		: LSA_HANDLE ;
	ObjectAttr 	: LSA_OBJECT_ATTRIBUTES;
  Key 				: LSA_UNICODE_STRING;
  Value				: LSA_UNICODE_STRING;
begin
	ObjectAttr.Length := SizeOf(ObjectAttr);
  ZeroMemory(@ObjectAttr, sizeof(ObjectAttr));
	LsaOpenPolicy( nil, @ObjectAttr, POLICY_CREATE_SECRET, @hPolicy );

  // create key formed from AppID in the following format:
  // "SCM:{00000000-0000-0000-0000-000000000000}"
  Key 		:= WideStrToUnicodeStr('SCM:' + AppID);
	Value 	:= WideStrToUnicodeStr(Password);
  LsaStorePrivateData( hPolicy, @Key, @Value);
  LsaClose( hPolicy );
end;

//// This helper function demonstrates how to add a privilege
//// to a user account. The privilege you will most likely
//// be interested in is "SeBatchLogonRight".
//void AddPrivilege( void* psid, wchar_t* pszPriv )
//{
//    LSA_HANDLE hPolicy = 0;
//    LSA_OBJECT_ATTRIBUTES oa = { sizeof oa };
//    LsaOpenPolicy( 0, &oa,
//                   POLICY_LOOKUP_NAMES | POLICY_CREATE_ACCOUNT,
//                   &hPolicy );
//
//    UNICODE_STRING usPriv; InitString( usPriv, pszPriv );
//
//    LsaAddAccountRights( hPolicy, psid, &usPriv, 1 );
//
//    LsaClose( hPolicy );
//}

procedure TurnOffDCOMSecurity(CoInitFlags : Integer);
begin
  if (CoInitFlags <> -1) then
  	NeedToUninitialize := Succeeded(CoInitializeEx(nil, CoInitFlags))
  else
    NeedToUninitialize := Succeeded(CoInitialize(nil));
  OleCheck(CoInitializeSecurity(nil, -1, nil, nil, RPC_C_AUTHN_LEVEL_NONE, RPC_C_IMP_LEVEL_IDENTIFY, nil, 0, nil));
end;

procedure DCOMInitProc;
begin
  TurnOffDCOMSecurity(COINIT_MULTITHREADED);
  if SaveInitProc <> nil then TProcedure(SaveInitProc);
end;

{initialization
begin
  SaveInitProc := InitProc;
  InitProc := @DCOMInitProc;
end;

finalization
begin
  if NeedToUninitialize then CoUninitialize;
end;
}

end.


