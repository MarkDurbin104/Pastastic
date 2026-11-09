(*============================================================================*
 | unit NetUser                                                               |
 |                                                                            |
 | Programmed by Colin Wilson - colin@wilsonc.demon.co.uk                     |
 |                                                                            |
 | Encapsulates NT Lanman User                                                |
 |                                                                            |
 | Public methods:-                                                           |
 |                                                                            |
 | constructor CreateFrom                                                     |
 |                                                                            |
 |   Alternative constructor initialisesa TNetUser from known information     |
 |                                                                            |
 | procedure GetLevel20Info                                                   |
 |                                                                            |
 |   Get's all level 20 information (full name, comment, flags and user ID)   |
 |   in one hit.                                                              |
 |                                                                            |
 | procedure GetLevel3Info                                                    |
 |                                                                            |
 |   Get's all information in one hit.                                        |
 |                                                                            |
 | procedure BeginUpdate                                                      |
 |                                                                            |
 |   Starts a cached update transaction.  Call GetLevel3Info first.           |
 |                                                                            |
 | procedure EndUpdate                                                        |
 |                                                                            |
 |   Ends a cached update transaction.  Sends the data to lanman.             |
 |                                                                            |
 | procedure CancelUpdate                                                     |
 |                                                                            |
 |   Cancels a cached update.                                                 |
 |                                                                            |
 | procedure CreateAccount                                                    |
 |                                                                            |
 |   Creates a lanman user account.                                           |
 |                                                                            |
 | procedure DeleteAccount                                                    |
 |                                                                            |
 |   Deletes a lanman user account.                                           |
 |                                                                            |
 | procedure RenameAccount                                                    |
 |                                                                            |
 |   Rename a lanman account.                                                 |
 |                                                                            |
 | procedure GetGlobalGroups                                                  |
 |                                                                            |
 |   Get a list of global groups that the user belongs to.                    |
 |                                                                            |
 | procedure GetLocalGroups                                                   |
 |                                                                            |
 |   Geta list of local groups that the user belongs to.                      |
 |                                                                            |
 | procedure ChangePassword                                                   |
 |                                                                            |
 |   Change the password.                                                     |
 |                                                                            |
 | procedure AddToLocalGroup                                                  |
 |                                                                            |
 |   Make the user a member of a local group.                                 |
 |                                                                            |
 | procedure RemoveFromLocalGroup                                             |
 |                                                                            |
 |   Remove membership from a local group.                                    |
 |                                                                            |
 | procedure AddToGlobalGroup                                                 |
 |                                                                            |
 |   Make the user a member of a global group.                                |
 |                                                                            |
 | procedure RemoveFromGlobalGroup                                            |
 |                                                                            |
 |   Remove membership from a global group.                                   |
 |                                                                            |
 |                                                                            |
 | Public properties:-                                                        |
 |                                                                            |
 | (rw) property Flags : TNetUserFlag            Access User Flags            |
 | (ro) property InfoFlags : TNetUserInfoFlags   Get RO User flags            |
 | (ro) property PasswordAge : Integer           Password age in seconds      |
 | (ro) property Priv : TNetUserPriv             Get account privilege        |
 | (rw) property HomeDir : string                Access Home Directory        |
 | (rw) property Comment : string                Access Comment               |
 | (rw) property ScriptPath : string             Access logon-script path     |
 | (ro) property AuthFlags : Integer             Get Auth flags               |
 | (rw) property FullName : string               Access user full name        |
 | (rw) property UsrComment : string             Access user comment          |
 | (rw) property Parms : string                  Access 'parms' field         |
 | (rw) property Workstations : string           Access allowed wkstn list    |
 | (ro) property LastLogon : TDateTime           Get last logon date/time     |
 | (ro) property LastLogoff : TDateTime          Get last logoff date/time    |
 | (rw) property AcctExpires : TDateTime         Access account expiry dt/tm  |
 | (rw) property MaxStorage : Integer            Access max storage           |
 | (rw) property PasswordExpired : boolean       Access password exp'd flag   |
 | (rw) property PrimaryGroupID : Integer        Access Primary group RID     |
 | (rw) property Profile : string                Access profile path          |
 | (rw) property HomeDirDrive : string           Access Home Dir Drive        |
 | (wo) property Password : string               Set the password             |
 |                                                                            |
 |                                                                            |
 | Version  Date      By    Description                                       |
 | -------  --------  ----  ------------------------------------------------- |
 | 1.0      May 1997  CPWW  Original                                          |
 | 1.5      May 1998  CPWW  Increased functionality:                          |
 |                            Alternative CreateFrom constructor added.       |
 |                                                                            |
 |                            BeginUpdate and EndUpdate methods added to      |
 |                            commit several changes in one hit.              |
 *============================================================================*)

unit NetUser;

interface

uses
  Windows, SysUtils, Classes, NetServer, lmaccess;

//const
//  DOMAIN_GROUP_RID_USERS = lmaccess.DOMAIN_GROUP_RID_USERS;

type
  //---------------------------------------------------------------------------
  // TNetUserFlags are used to record which bits of user information
  // have been cached.

  TNetUserComponents = (
    uiPasswordAge,
    uiPriv,
    uiHomeDir,
    uiComment,
    uiFlags,
    uiScriptPath,
    uiAuthFlags,
    uiFullName,
    uiUsrComment,
    uiParms,
    uiWorkstations,
    uiLastLogon,
    uiLastLogoff,
    uiAcctExpires,
    uiMaxStorage,
    uiUnitsPerWeek,
    uiLogonHours,
    uiBadPWCount,
    uiNumLogons,
    uiLogonServer,
    uiCountryCode,
    uiCodepage,
    uiUserID,
    uiPrimaryGroupID,
    uiProfile,
    uiHomeDirDrive,
    uiPasswordExpired
  );
  TNetUserCacheFlags = set of TNetUserComponents;

  TNetUserFlag = (
    ufAccountDisable,
    ufHomedirRequired,
    ufLockout,
    ufPasswordNotRequired,
    ufPasswordCantChange,
    ufDontExpirePassword,
    ufMNSLogonAccount
  );
  TNetUserFlags = set of TNetUserFlag;

  TNetUserInfoFlag = (
    uifScript,
    uifTempDuplicateAccount,
    uifNormalAccount,
    uifInterdomainTrustAccount,
    uifWorkstationTrustAccount,
    uifServerTrustAccount);
  TNetUserInfoFlags = set of TNetUserInfoFlag;

  TNetUserPriv = (
    upUnknown,
    upGuest,
    upUser,
    upAdmin);

  TNetUserAuthFlag = (
    afOpPrint,
    afOpComm,
    afOpServer,
    afOpAccounts
  );
  TNetUserAuthFlags = set of TNetUserAuthFlag;


  TNetUser = class(TComponent)
  private

    fServer : TNetServer;
    fUserName : string;
    fInfoFlags : TNetUserCacheFlags;
    fInfo : USER_INFO_3;                    // Details cache.
    fUpdating : boolean;                    // See BeginUpdate / EndUpdate

    procedure ClearInfoBuffer;
    procedure SetUserName (const value : string);
    procedure SetServer (value : TNetServer);

//    function GetFullname : string;
//    procedure SetFullName (const value : string);

//    procedure SetComment (const value : string);

//    function GetFlags : TNetUserFlags;
//    procedure SetFlags (value : TNetUserFlags);

//    function GetInfoFlags : TNetUserInfoFlags;

    function GetInfoBuffer (wServer, wUser: WideString; level : Integer) : pointer;
//    procedure SetInfoBuffer (level : Integer; value : pointer);

//    function GetPasswordExpired : boolean;
//    procedure SetPasswordExpired (value : boolean);

//    function GetPasswordAge : Integer;
//    function GetPriv : TNetUserPriv;

//    function GetHomeDir : string;
//    procedure SetHomeDir (const value : string);

//    function GetScriptPath : string;
//    procedure SetScriptPath (const value : string);

//    function GetAuthFlags : TNetUserAuthFlags;

//    function GetUsrComment : string;
//    procedure SetUsrComment (const value : string);

//    function GetParms : string;
//    procedure SetParms (const value : string);

//    function GetWorkstations : string;
//    procedure SetWorkstations (const value : string);

//    function GetLastLogon : TDateTime;
//    function GetLastLogoff : TDateTime;

//    function GetAcctExpires : TDateTime;
//    procedure SetAcctExpires  (value : TDateTime);

//    function GetMaxStorage : Integer;
//    procedure SetMaxStorage (value : Integer);

//    function GetPrimaryGroupID : Integer;
//    procedure SetPrimaryGroupID (value : Integer);

//    function GetProfile : string;
//    procedure SetProfile (const value : string);

//    function GetHomeDirDrive : string;
//    procedure SetHomeDirDrive (const value : string);

//    procedure SetPassword ( const value : string);

//    procedure GetWideName (var wServer, wUser : WideString);

  protected
//    property InfoBuffer [level : Integer] : pointer read GetInfoBuffer write SetInfoBuffer;

  public
    constructor CreateFrom (AOwner : TComponent; AServer : TNetServer; info : PUSER_INFO_3);
    destructor Destroy; override;
    procedure GetLevel20Info(wServer, wUser:WideString);
    function  GetComment(wServer, wUser:WideString) : string;
//    procedure GetLevel3Info;
    procedure BeginUpdate;
//    procedure EndUpdate;
    procedure CancelUpdate;
    //procedure CreateAccount (const description, password : string);
    function CreateAccount (const Server:String ; const User:String; const description:String; const password:string):boolean;
//    procedure DeleteAccount;
//    procedure RenameAccount (const newName : string);

//    property Flags : TNetUserFlags read GetFlags write SetFlags;
//    property InfoFlags : TNetUserInfoFlags read GetInfoFlags;
//    property PasswordAge : Integer read GetPasswordAge;
//    property Priv : TNetUserPriv read GetPriv;
//    property HomeDir : string read GetHomeDir write SetHomeDir;
//    property Comment : string read GetComment write SetComment;
//    property ScriptPath : string read GetScriptPath write SetScriptPath;
//    property AuthFlags : TNetUserAuthFlags read GetAuthFlags;
//    property FullName : string read GetFullName write SetFullName;
//    property UsrComment : string read GetUsrComment write SetUsrComment;
//    property Parms : string read GetParms write SetParms;
//    property Workstations : string read GetWorkstations write SetWorkstations;
//    property LastLogon : TDateTime read GetLastLogon;
//    property LastLogoff : TDateTime read GetLastLogoff;
//    property AcctExpires : TDateTime read GetAcctExpires write SetAcctExpires;
//    property MaxStorage : Integer read GetMaxStorage write SetMaxStorage;
//    property PasswordExpired : boolean read GetPasswordExpired write SetPasswordExpired;
//    property PrimaryGroupID : Integer read GetPrimaryGroupID write SetPrimaryGroupID;
//    property Profile : string read GetProfile write SetProfile;
//    property HomeDirDrive : string read GetHomeDirDrive write SetHomeDirDrive;
//    property Password : string write SetPassword;

    function GetMemberGlobalGroups ( wServer, wUser:WideString ):string;
    function GetMemberLocalGroups( wServer, wUser:WideString ):string;

    procedure AddToLocalGroup (const group : string);
    procedure RemoveFromLocalGroup (const group : string);
    procedure AddToGlobalGroup (const group : string);
    procedure RemoveFromGlobalGroup (const group : string);

  published
    property Server : TNetServer read fServer write SetServer;
    property UserName : string read fUserName write SetUserName;
  end;

procedure Register;

implementation

uses lmglobal, unitNTException, NetGroup;

var
  NIL_HANDLE : Integer absolute 0;

(*----------------------------------------------------------------------------*
 | function DWORDToUserFlags () : TNetUserFlags;                              |
 |                                                                            |
 | Convert a DWORD user flags value to a TNetUserFlags set                    |
 |                                                                            |
 | Parameters:                                                                |
 |  flags : DWORD          The flags to convert                               |
 |                                                                            |
 | The function returns the flags set.                                        |
 *----------------------------------------------------------------------------*)
function DWORDToUserFlags (flags : DWORD) : TNetUserFlags;
begin
  result := [];
  if (flags and UF_ACCOUNTDISABLE) <> 0 then result := result + [ufAccountDisable];
  if (flags and UF_HOMEDIR_REQUIRED) <> 0 then result := result + [ufHomedirRequired];
  if (flags and UF_LOCKOUT) <> 0 then result := result + [ufLockout];
  if (flags and UF_PASSWD_NOTREQD) <> 0 then result := result + [ufPasswordNotRequired];
  if (flags and UF_PASSWD_CANT_CHANGE) <> 0 then result := result + [ufPasswordCantChange];
  if (flags and UF_DONT_EXPIRE_PASSWD) <> 0 then result := result + [ufDontExpirePassword];
  if (flags and UF_MNS_LOGON_ACCOUNT) <> 0 then result := result + [ufMNSLogonAccount];
end;

(*----------------------------------------------------------------------------*
 | function UserFlagsToDWORD () : DWORD;                                      |
 |                                                                            |
 | Convert a user flags set to a DWORD                                        |
 |                                                                            |
 | Parameters:                                                                |
 |  flags : TNetUserFlags    The flags to convert                             |
 |                                                                            |
 | The function returns the flags DWORD.                                      |
 *----------------------------------------------------------------------------*)
function UserFlagsToDWORD (flags : TNetUserFlags) : DWORD;
begin
  result := 0;
  if ufAccountDisable in flags then result := result or UF_ACCOUNTDISABLE;
  if ufHomedirRequired in flags then result := result or UF_HOMEDIR_REQUIRED;
  if ufLockout in flags then result := result or UF_LOCKOUT;
  if ufPasswordNotRequired in flags then result := result or UF_PASSWD_NOTREQD;
  if ufPasswordCantChange in flags then result := result or UF_PASSWD_CANT_CHANGE;
  if ufDontExpirePassword in flags then result := result or UF_DONT_EXPIRE_PASSWD;
  if ufMNSLogonAccount in flags then result := result or UF_MNS_LOGON_ACCOUNT;
end;

(*----------------------------------------------------------------------------*
 | function DWORDToUserInfoFlags () : TNetUserInfoFlags;                      |
 |                                                                            |
 | Convert a DWORD user flags value to a TNetUserInfoFlags set                |
 |                                                                            |
 | Parameters:                                                                |
 |  flags : DWORD          The flags to convert                               |
 |                                                                            |
 | The function returns the flags set.                                        |
 *----------------------------------------------------------------------------*)
function DWORDToUserInfoFlags (flags : DWORD) : TNetUserInfoFlags;
begin
  result := [];
  if (flags and UF_SCRIPT) <> 0 then result := result + [uifScript];
  if (flags and UF_TEMP_DUPLICATE_ACCOUNT) <> 0 then result := result + [uifTempDuplicateAccount];
  if (flags and UF_NORMAL_ACCOUNT) <> 0 then result := result + [uifNormalAccount];
  if (flags and UF_INTERDOMAIN_TRUST_ACCOUNT) <> 0 then result := result + [uifInterdomainTrustAccount];
  if (flags and UF_WORKSTATION_TRUST_ACCOUNT) <> 0 then result := result + [uifWorkstationTrustAccount];
  if (flags and UF_SERVER_TRUST_ACCOUNT) <> 0 then result := result + [uifServerTrustAccount];
end;

(*----------------------------------------------------------------------------*
 | function DWORDToPriv () : TNetUserPriv                                     |
 |                                                                            |
 | Convert a DWORD user priv value to a TNetUserPriv enum                     |
 |                                                                            |
 | Parameters:                                                                |
 |  p : DWORD          The priv value to convert                              |
 |                                                                            |
 | The function returns the TNetUserPriv value                                |
 *----------------------------------------------------------------------------*)
function DWORDToPriv (p : DWORD) : TNetUserPriv;
begin
  case p of
    USER_PRIV_GUEST : result := upGuest;
    USER_PRIV_USER  : result := upUser;
    USER_PRIV_ADMIN : result := upAdmin;
    else
      result := upUnknown
  end
end;

(*----------------------------------------------------------------------------*
 | function DWORDToAuthFlags () : TNetUserAuthFlags                           |
 |                                                                            |
 | Convert a DWORD Auth value to a set of TNetUserAuthFlags                   |
 |                                                                            |
 | Parameters:                                                                |
 |  p : DWORD          The auth value to convert                              |
 |                                                                            |
 | The function returns the TNetUserAuthFlags set                             |
 *----------------------------------------------------------------------------*)
function DWORDToAuthFlags (p : DWORD) : TNetUserAuthFlags;
begin
  result := [];
  if (p and AF_OP_PRINT) <> 0 then result := result + [afOpPrint];
  if (p and AF_OP_COMM) <> 0 then result := result + [afOpComm];
  if (p and AF_OP_SERVER) <> 0 then result := result + [afOpServer];
  if (p and AF_OP_ACCOUNTS) <> 0 then result := result + [afOpAccounts];
end;

(*----------------------------------------------------------------------------*
 | function time_tToDateTime () : TDateTime                                   |
 |                                                                            |
 | Converts a C style time_t integer (seconds since 1/1/1970) to a Delphi     |
 | TDateTime.                                                                 |
 *----------------------------------------------------------------------------*)
function time_tToDateTime (t : Integer) : TDateTime;
type
  PComp = ^Comp;
var
  baseDate : TDateTime;
  systemBaseDate : TSystemTime;
  filetimeBaseDate : TFileTime;
  timet_comp, c : comp;

begin
  baseDate := EncodeDate (1970, 1, 1);
  DateTimeToSystemTime (baseDate, systemBaseDate);
  SystemTimeToFileTime (systemBaseDate, filetimeBaseDate);
  timet_comp := PComp (@filetimeBaseDate)^;

  c := t;
  c := c * 10000000 + timet_comp; // + d3time_comp;
  filetimeBaseDate := PFileTime (@c)^;
  FileTimeToSystemTime (filetimeBaseDate, systemBaseDate);
  result := SystemTimeToDateTime (systemBaseDate)
end;

(*----------------------------------------------------------------------------*
 | function DateTimeTotime_t() : TDateTime                                    |
 |                                                                            |
 | Converts a TDateTime to a C style time_t integer                           |
 *----------------------------------------------------------------------------*)
function DateTimeTotime_t (const dt : TDateTime) : DWORD;
type
  PComp = ^Comp;
var
  baseDate : TDateTime;
  systemBaseDate : TSystemTime;
  filetimeBaseDate : TFileTime;
  timet_comp, c : comp;

begin
  baseDate := EncodeDate (1970, 1, 1);
  DateTimeToSystemTime (baseDate, systemBaseDate);
  SystemTimeToFileTime (systemBaseDate, filetimeBaseDate);
  timet_comp := PComp (@filetimeBaseDate)^;

  DateTimeToSystemTime (dt, systemBaseDate);
  SystemTimeToFileTime (systemBaseDate, filetimeBaseDate);
  c := PComp (@filetimeBaseDate)^;
  c := (c - timet_comp) / 10000000;
  result := Round (c)
end;

(*----------------------------------------------------------------------------*
 | constructor TNetUser.CreateFrom                                            |
 |                                                                            |
 | Alternative constructor.  Create the TNetUserObject and initialize it with |
 | supplied info.  See TNetServer.CreateUserObjects                           |
 |                                                                            |
 | Parameters                                                                 |
 |   AOwner : TComponent             The owning component.                    |
 |   AServer : TNetServer            The server on which the account resides. |
 |   info : PUSER_INFO_3             The user's details.                      |
 *----------------------------------------------------------------------------*)
constructor TNetUser.CreateFrom (AOwner : TComponent; AServer : TNetServer; info : PUSER_INFO_3);
begin
  inherited Create (AOwner);
  with info^ do
  begin
    fUserName := usri3_name;
    fServer := AServer;
    fInfo.usri3_password_age := usri3_password_age;
    fInfo.usri3_priv := usri3_priv;
    fInfo.usri3_home_dir := WStrNew (usri3_home_dir);
    fInfo.usri3_comment := WStrNew (usri3_comment);
    fInfo.usri3_flags := usri3_flags;
    fInfo.usri3_script_path := WStrNew (usri3_script_path);
    fInfo.usri3_auth_flags := usri3_auth_flags;
    fInfo.usri3_full_name := WStrNew (usri3_full_name);
    fInfo.usri3_usr_comment := WStrNew (usri3_usr_comment);
    fInfo.usri3_parms := WStrNew (usri3_parms);
    fInfo.usri3_workstations := WStrNew (usri3_workstations);
    fInfo.usri3_last_logon := usri3_last_logon;
    fInfo.usri3_last_logoff := usri3_last_logoff;
    fInfo.usri3_acct_expires := usri3_acct_expires;
    fInfo.usri3_max_storage := usri3_max_storage;
    fInfo.usri3_units_per_week := usri3_units_per_week;

    GetMem (fInfo.usri3_logon_hours, 21);
    Move (usri3_logon_hours^, fInfo.usri3_logon_hours^, 21);

    fInfo.usri3_bad_pw_count := usri3_bad_pw_count;
    fInfo.usri3_num_logons := usri3_num_logons;
    fInfo.usri3_logon_server := WStrNew (usri3_logon_server);
    fInfo.usri3_country_code := usri3_country_code;
    fInfo.usri3_code_page := usri3_code_page;
    fInfo.usri3_user_id := usri3_user_id;
    fInfo.usri3_primary_group_id := usri3_primary_group_id;
    fInfo.usri3_profile := WStrNew (usri3_profile);
    fInfo.usri3_home_dir_drive := WStrNew (usri3_home_dir_drive);
    fInfo.usri3_password_expired := usri3_password_expired;

                                 // Set all info flags.
    fInfoFlags := [Low (TNetUserComponents)..High (TNetUserComponents)];
  end
end;

(*----------------------------------------------------------------------------*
 | destructor TNetUser.Destroy;                                               |
 |                                                                            |
 | Destructor for TNetUser object.  Clears cached information.                |
 *----------------------------------------------------------------------------*)
destructor TNetUser.Destroy;
begin
  ClearInfoBuffer;
  inherited
end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.ClearInfoBuffer                                         |
 |                                                                            |
 | (private) Clears cached information                                        |
 *----------------------------------------------------------------------------*)
procedure TNetUser.ClearInfoBuffer;
begin
  fUpdating := False;
  if uiFullName in fInfoFlags then FreeMem (fInfo.usri3_full_name);
  if uiComment in fInfoFlags then FreeMem (fInfo.usri3_Comment);
  if uiHomeDir in fInfoFlags then FreeMem (fInfo.usri3_home_dir);
  if uiScriptPath in fInfoFlags then FreeMem (fInfo.usri3_script_path);
  if uiUsrComment in fInfoFlags then FreeMem (fInfo.usri3_usr_comment);
  if uiParms in fInfoFlags then FreeMem (fInfo.usri3_parms);
  if uiWorkstations in fInfoFlags then FreeMem (fInfo.usri3_workstations);
  if uiLogonHours in fInfoFlags then FreeMem (fInfo.usri3_logon_hours);
  if uiLogonServer in fInfoFlags then FreeMem (fInfo.usri3_logon_server);
  if uiHomeDirDrive in fInfoFlags then FreeMem (fInfo.usri3_home_dir_drive);
  if uiProfile in fInfoFlags then FreeMem (fInfo.usri3_profile);

  fInfoFlags := [];
end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetInfoBuffer () : pointer                               |
 |                                                                            |
 | (private) Returns user info for the specified level.                       |
 |                                                                            |
 | Parameters                                                                 |
 |   level : Integer               The level to return the info for.          |
 |                                                                            |
 | The function returns a pointer to a buffer containing the information.     |
 | The buffer must be freed with NetAPIBufferFree.                            |
 *----------------------------------------------------------------------------*)
function TNetUser.GetInfoBuffer (wServer, wuser: WideString ; level : Integer) : pointer;
var
//  wServer : WideString;
//  wUser : WideString;
  rv : Integer;
begin
//  GetWideName (wServer, wUser);
  rv := NetUserGetInfo (PWideChar (wServer), PWideChar (wUser), level, result);
  if rv <> NErr_Success then
    raise ENTException.Create (rv);
end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.GetLevel20Info.                                         |
 |                                                                            |
 | Gets and Caches the full name, comment, flags and ID fields.               |
 *----------------------------------------------------------------------------*)
procedure TNetUser.GetLevel20Info( wServer, wUser: WideString );
var
  buffer : pointer;
begin
//  buffer := InfoBuffer [20];
  buffer := GetInfoBuffer( wServer, wUser, 20);
  with PUSER_INFO_20 (buffer)^ do
  try
    if uiFullName in fInfoFlags then FreeMem (fInfo.usri3_full_name);
    fInfo.usri3_full_name := WStrNew (usri20_full_name);

    if uiComment in fInfoFlags then FreeMem (fInfo.usri3_comment);
    fInfo.usri3_comment := WStrNew (usri20_comment);

    fInfo.usri3_flags := usri20_flags;
    fInfo.usri3_user_id := usri20_user_id;

    fInfoFlags := fInfoFlags + [uiFullName, uiComment, uiFlags, uiUserID];
  finally
    NetAPIBufferFree (buffer)
  end
end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.GetLevel3Info                                           |
 |                                                                            |
 | Gets and caches all information.                                           |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.GetLevel3Info;
//var
//  buffer : pointer;
//begin
//  buffer := InfoBuffer [3];
//  ClearInfoBuffer;
//  with PUSER_INFO_3 (buffer)^ do
//  try
//    fInfo.usri3_password_age := usri3_password_age;
//    fInfo.usri3_priv := usri3_priv;
//    fInfo.usri3_home_dir := WStrNew (usri3_home_dir);
//    fInfo.usri3_comment := WStrNew (usri3_comment);
//    fInfo.usri3_flags := usri3_flags;
//    fInfo.usri3_script_path := WStrNew (usri3_script_path);
//    fInfo.usri3_auth_flags := usri3_auth_flags;
//    fInfo.usri3_full_name := WStrNew (usri3_full_name);
//    fInfo.usri3_usr_comment := WStrNew (usri3_usr_comment);
//    fInfo.usri3_parms := WStrNew (usri3_parms);
//    fInfo.usri3_workstations := WStrNew (usri3_workstations);
//    fInfo.usri3_last_logon := usri3_last_logon;
//    fInfo.usri3_last_logoff := usri3_last_logoff;
//    fInfo.usri3_acct_expires := usri3_acct_expires;
//    fInfo.usri3_max_storage := usri3_max_storage;
//    fInfo.usri3_units_per_week := usri3_units_per_week;
//
//    GetMem (fInfo.usri3_logon_hours, 21);
//    Move (usri3_logon_hours^, fInfo.usri3_logon_hours^, 21);
//
//    fInfo.usri3_bad_pw_count := usri3_bad_pw_count;
//    fInfo.usri3_num_logons := usri3_num_logons;
//    fInfo.usri3_logon_server := WStrNew (usri3_logon_server);
//    fInfo.usri3_country_code := usri3_country_code;
//    fInfo.usri3_code_page := usri3_code_page;
//    fInfo.usri3_user_id := usri3_user_id;
//    fInfo.usri3_primary_group_id := usri3_primary_group_id;
//    fInfo.usri3_profile := WStrNew (usri3_profile);
//    fInfo.usri3_home_dir_drive := WStrNew (usri3_home_dir_drive);
//    fInfo.usri3_password_expired := usri3_password_expired;
//
//    fInfoFlags := [Low (TNetUserComponents)..High (TNetUserComponents)];
//  finally
//    NetAPIBufferFree (buffer)
//  end
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.SetInfoBuffer ()                                        |
 |                                                                            |
 | (Private)  Sets the user information for the specified level.              |
 |                                                                            |
 | Parameters                                                                 |
 |   level : Integer          The level of the ifnormation to set.            |
 |   value : pointer          The information for the level.                  |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.SetInfoBuffer (level : Integer; value : pointer);
//var
//  wServer : WideString;
//  wUser : WideString;
//  rv : Integer;
//begin
//  if fUpdating then Exit;
//  GetWideName (wServer, wUser);
//  rv := NetUserSetInfo (PWideChar (wServer), PWideChar (wUser), level, PChar (value), NIL_HANDLE);
//  if rv <> NErr_Success then
//    raise ENTException.Create (rv);
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.SetUserName                                             |
 |                                                                            |
 | 'Set' method for UserName property. Sets the UserName property and clears  |
 | cached information.                                                        |
 |                                                                            |
 | Parameters                                                                 |
 |   const value : string        The new user name.                           |
 *----------------------------------------------------------------------------*)
procedure TNetUser.SetUserName (const value : string);
begin
  if value <> UserName then
  begin
    fUserName := value;
    ClearInfoBuffer
  end
end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.SetServer (const value : TNetServer)                    |
 |                                                                            |
 | 'Set' method for the Server property.  Sets the property and clears cached |
 | info.                                                                      |
 |                                                                            |
 | Parameters                                                                 |
 |   value : TNetServer                 The new server to use.                |
 *----------------------------------------------------------------------------*)
procedure TNetUser.SetServer (value : TNetServer);
begin
  if value <> fServer then
  begin
    fServer := value;
    ClearInfoBuffer
  end
end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetFullName                                              |
 |                                                                            |
 | 'Get' method for the FullName property.  Returns the full name.            |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetFullName : string;
//begin
//  if not (uiFullName in fInfoFlags) then
//    GetLevel20Info;
//
//  result := fInfo.usri3_full_name;
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.SetFullName                                             |
 |                                                                            |
 | 'Set' method for the FullName property.  Changes the FullName value for    |
 | the user.                                                                  |
 |                                                                            |
 | Parameters                                                                 |
 |   const value : string           The new full name.                        |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.SetFullName (const value : string);
//var
//  wValue : WideString;
//  buffer : USER_INFO_1011;
//begin
//  if value <> FullName then
//  begin
//    FreeMem (fInfo.usri3_full_name);
//    wValue := value;
//    fInfo.usri3_full_name := WStrNew (PWideChar (wValue));
//    buffer.usri1011_full_name := fInfo.usri3_full_name;
//    InfoBuffer [1011] := @buffer;
//  end
//end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetComment                                               |
 |                                                                            |
 | 'Get' method for Comment property.  Returns the comment.                   |
 *----------------------------------------------------------------------------*)
function TNetUser.GetComment(wServer, wUser:WideString) : string;
begin
  result := '' ;
  if wUser <> '' then
  begin
     if not (uiComment in fInfoFlags) then
       GetLevel20Info(wServer, wUser);
     result := fInfo.usri3_comment;
  end ;
end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.SetComment                                              |
 |                                                                            |
 | 'Set' function for Comment property.                                       |
 |                                                                            |
 | Parameters                                                                 |
 |   const value : string         The new comment.                            |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.SetComment (const value : string);
//var
//  wValue : WideString;
//  buffer : USER_INFO_1007;
//begin
//  if value <> Comment then
//  begin
//    FreeMem (fInfo.usri3_comment);
//    wValue := value;
//    fInfo.usri3_comment := WStrNew (PWideChar (wValue));
//    buffer.usri1007_comment := fInfo.usri3_comment;
//    InfoBuffer [1007] := @buffer;
//  end
//end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetFlags : Integer                                       |
 |                                                                            |
 | 'Get' method for user flags property.                                      |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetFlags : TNetUserFlags;
//begin
//  if not (uiFlags in fInfoFlags) then
//    GetLevel20Info;
//
//  result := DWORDToUserFlags (fInfo.usri3_flags);
//end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetFlags : Integer                                       |
 |                                                                            |
 | 'Get' method for user flags property.                                      |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetInfoFlags : TNetUserInfoFlags;
//begin
//  if not (uiFlags in fInfoFlags) then
//    GetLevel20Info;
//
//  result := DWORDToUserInfoFlags (fInfo.usri3_flags);
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.SetFlags                                                |
 |                                                                            |
 | 'Set' method for flags property.                                           |
 |                                                                            |
 | Parameters                                                                 |
 |   value : Integer         The new flags value.                             |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.SetFlags (value : TNetUserFlags);
//var
// buffer : USER_INFO_1008;
//  rwFlagsMask : DWORD;

//begin
//  if value <> Flags then
//  begin
//    rwFlagsMask := UserFlagsToDWORD ([Low (TNetUserFlag)..High (TNetUserFlag)]);
//    fInfo.usri3_flags := (fInfo.usri3_flags and (not rwFlagsMask)) or UserFlagsToDWORD (value);
//    buffer.usri1008_flags := fInfo.usri3_flags;
//    InfoBuffer [1008] := @buffer;
//  end
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.GetGlobalGroups                                         |
 |                                                                            |
 | Gets a list of global group names to which the user belongs.               |
 |                                                                            |
 | Parameters                                                                 |
 |   list : TStrings                Returns the list of group names.          |
 *----------------------------------------------------------------------------*)
function TNetUser.GetMemberGlobalGroups ( wServer, wUser:WideString ):string;
var
//  wServer : WideString;
//  wUser : WideString;
  buffer : pointer;
  p : PGROUP_USERS_INFO_0;
  rv, i, entriesRead, totalEntries : Integer;
  List:TStringList ;
begin
  result:='';
   List:=TStringList.Create;

//  GetWideName (wServer, wUser);
  list.Clear;
  if wUser<>''then
  begin
    rv := NetUserGetGroups (PWideChar (wServer), PWideChar (wUser), 0, buffer, MAX_PREFERRED_LENGTH, entriesRead, totalEntries);
    if rv = NERR_Success then
    try
      p := PGROUP_USERS_INFO_0 (buffer);
      if (entriesRead <> 1) or (p^.grpui0_name <> 'None') then
        for i := 0 to entriesRead - 1 do
        begin
          list.Add (p^.grpui0_name);
          Inc (p)
        end ;
    Result:= List.CommaText;
    finally
      NetAPIBufferFree (buffer);
      List.Free ;
    end
    else raise ENTException.Create (rv)
  end ;
end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.GetLocalGroups ()                                       |
 |                                                                            |
 | Gets a list of local group names to which the user belongs.                |
 |                                                                            |
 | Parameters                                                                 |
 |   list : TStrings                Returns the list of group names.          |
 *----------------------------------------------------------------------------*)
function TNetUser.GetMemberLocalGroups( wServer, wUser:WideString ):string;
var
//  wServer : WideString;
//  wUser : WideString;
  buffer : pointer;
  p : PLOCALGROUP_USERS_INFO_0;
  rv, i, entriesRead, totalEntries : Integer;
  List:TStringList;

begin
  Result := '' ;
  if wUser <> '' then
  begin

     List := TStringList.Create;
     list.Clear;

     rv := NetUserGetLocalGroups (PWideChar (wServer), PWideChar (wUser), 0, 0, buffer, MAX_PREFERRED_LENGTH, entriesRead, totalEntries);
     if rv = NERR_Success then
     try
       p := PLOCALGROUP_USERS_INFO_0 (buffer);
       for i := 0 to entriesRead - 1 do
       begin
         list.Add (p^.lgrui0_name);
         Inc (p)
       end ;
     result:= List.CommaText;
     finally
       NetAPIBufferFree (buffer);
       List.Free;
     end;
   //  else raise ENTException.Create (rv)
  end ; 
end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetPasswordExpired : boolean                             |
 |                                                                            |
 | 'Get' method for PasswordExpired property.  Returns true if the password   |
 | has expired.                                                               |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetPasswordExpired : boolean;
//begin
//  if not (uiPasswordExpired in fInfoFlags) then
//    GetLevel3Info;
//
//  result := Boolean (fInfo.usri3_password_expired)
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.SetPasswordExpired                                      |
 |                                                                            |
 | 'Set' method for PasswordExpired property.                                 |
 |                                                                            |
 | Parameters                                                                 |
 |   value : boolean       The new value of PasswordExpired.                  |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.SetPasswordExpired (value : boolean);
//begin
//  if fInfoFlags <> [Low (TNetUserComponents).. High (TNetUserComponents)] then
//    GetLevel3Info;
 // fInfo.usri3_password_expired := Ord (value);
//  InfoBuffer [3] := @fInfo
//end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetPasswordAge : Integer                                 |
 |                                                                            |
 | 'Get' method for the PasswordAge.  Returns number of seconds since the     |
 | password was last changed.                                                 |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetPasswordAge : Integer;
//begin
//  if not (uiPasswordAge in fInfoFlags) then
//    GetLevel3Info;
//  result := fInfo.usri3_password_age;
//end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetPriv : TNetUserPriv                                   |
 |                                                                            |
 | Returns the user account privilege level - user, guest or administrator    |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetPriv : TNetUserPriv;
//begin
//  if not (uiPriv in fInfoFlags) then
//    GetLevel3Info;
//  result := DWORDToPriv (fInfo.usri3_priv);
//end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetHomeDir : string                                      |
 |                                                                            |
 | 'Get' method for HomeDir property.                                         |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetHomeDir : string;
//begin
//  if not (uiHomeDir in fInfoFlags) then
//    GetLevel3Info;
//
//  result := fInfo.usri3_home_dir;
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.SetHomeDir                                              |
 |                                                                            |
 | 'Set' method for HomeDir property                                          |
 |                                                                            |
 | Parameters                                                                 |
 |   const value : string          The new home dir.                          |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.SetHomeDir (const value : string);
//var
//  wValue : WideString;
//  buffer : USER_INFO_1006;
//begin
//  if value <> HomeDir then
//  begin
//    FreeMem (fInfo.usri3_home_dir);
//    wValue := value;
//    fInfo.usri3_home_dir := WStrNew (PWideChar (wValue));
//    buffer.usri1006_home_dir := fInfo.usri3_home_dir;
//    InfoBuffer [1006] := @buffer;
//  end
//end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetScriptPath : string                                   |
 |                                                                            |
 | 'Get' method for ScriptPath property                                       |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetScriptPath : string;
//begin
//  if not (uiScriptPath in fInfoFlags) then
//    GetLevel3Info;
//
//  result := fInfo.usri3_script_path
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.SetScriptPath                                           |
 |                                                                            |
 | 'Set' method for ScriptPath property                                       |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.SetScriptPath (const value : string);
//var
//  wValue : WideString;
//  buffer : USER_INFO_1009;
//begin
//  if value <> ScriptPath then
//  begin
//    FreeMem (fInfo.usri3_script_path);
//    wValue := value;
//    fInfo.usri3_script_path := WStrNew (PWideChar (wValue));
//    buffer.usri1009_script_path := fInfo.usri3_script_path;
//    InfoBuffer [1009] := @buffer;
//  end
//end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetAuthFlags : TNetUserAuthFlags                         |
 |                                                                            |
 | 'Get' method for auth flags property                                       |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetAuthFlags : TNetUserAuthFlags;
//begin
//  if not (uiAuthFlags in fInfoFlags) then
//    GetLevel3Info;
//  result := DWORDToAuthFlags (fInfo.usri3_auth_flags);
//end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetUsrComment : string                                   |
 |                                                                            |
 | 'Get' method for UsrComment property                                       |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetUsrComment : string;
//begin
//  if not (uiUsrComment in fInfoFlags) then
//    GetLevel3Info;
//
//  result := fInfo.usri3_usr_comment;
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.SetUsrComment                                           |
 |                                                                            |
 | 'Set' method for UsrComment property                                       |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.SetUsrComment (const value : string);
//var
//  wValue : WideString;
//  buffer : USER_INFO_1012;
//begin
//  if value <> UsrComment then
//  begin
//    FreeMem (fInfo.usri3_usr_comment);
//    wValue := value;
//    fInfo.usri3_usr_comment := WStrNew (PWideChar (wValue));
//    buffer.usri1012_usr_comment := fInfo.usri3_usr_comment;
//    InfoBuffer [1012] := @buffer;
//  end
//end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetParms : string                                        |
 |                                                                            |
 | 'Get' method for parms property                                            |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetParms : string;
//begin
//  if not (uiParms in fInfoFlags) then
//    GetLevel3Info;
//
//  result := fInfo.usri3_parms;
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.SetParms                                                |
 |                                                                            |
 | 'Set' method for parms property.                                           |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.SetParms (const value : string);
//var
//  wValue : WideString;
//  buffer : USER_INFO_1013;
//begin
//  if value <> Parms then
//  begin
//    FreeMem (fInfo.usri3_parms);
//    wValue := value;
//    fInfo.usri3_parms := WStrNew (PWideChar (wValue));
//    buffer.usri1013_parms := fInfo.usri3_parms;
//    InfoBuffer [1013] := @buffer;
//  end
//end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetWorkstations : string                                 |
 |                                                                            |
 | 'Get' method for allowed logon workstations - can contain a comma          |
 | separated list of up to 8 workstation names.                               |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetWorkstations : string;
//begin
//  if not (uiWorkstations in fInfoFlags) then
//    GetLevel3Info;
//
//  result := fInfo.usri3_workstations;
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.SetWorkstations                                         |
 |                                                                            |
 | 'Set' method for Workstations property.  Set it to an empty string, or a   |
 | comma separated list of up to 8 workstation nanems.                        |
 |                                                                            |
 | Parameters                                                                 |
 |   const value : string        The new value of the Workstations property.  |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.SetWorkstations (const value : string);
//var
//  wValue : WideString;
//  buffer : USER_INFO_1014;
//begin
//  if value <> Workstations then
//  begin
//    FreeMem (fInfo.usri3_workstations);
//    wValue := value;
//    fInfo.usri3_workstations := WStrNew (PWideChar (wValue));
//    buffer.usri1014_workstations := fInfo.usri3_workstations;
//    InfoBuffer [1014] := @buffer;
//  end
//end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetLastLogon : Integer                                   |
 |                                                                            |
 | 'Get' method for 'LastLogon' property. Returns the 'last logon' date/time  |
 | as a C time_t integer.                                                     |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetLastLogon : TDateTime;
//begin
//  if not (uiLastLogon in fInfoFlags) then
//    GetLevel3Info;
//
//  if fInfo.usri3_last_logon = 0 then
//    result := 0
//  else
//    result := time_tToDateTime (fInfo.usri3_last_logon);
//end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetLastLogoff : Integer                                  |
 |                                                                            |
 | 'Get' method for 'LastLogoff' property. Returns the 'last logon' date/time |
 | as a C time_t integer.                                                     |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetLastLogoff : TDateTime;
//begin
//  if not (uiLastLogoff in fInfoFlags) then
//    GetLevel3Info;
//
//  if fInfo.usri3_last_logoff = 0 then
//    result := 0
//  else
//    result := time_tToDateTime (fInfo.usri3_last_logoff);
//end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetLastLogon : Integer                                   |
 |                                                                            |
 | 'Get' method for 'AcctExpires' property. Returns the 'account expiry'      |
 |  date/time as a C time_t integer.                                          |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetAcctExpires : TDateTime;
//begin
//  if not (uiAcctExpires in fInfoFlags) then
//    GetLevel3Info;
//
//  if fInfo.usri3_acct_expires = TIMEQ_FOREVER then
//    result := 0
//  else
//    result := time_tToDateTime (fInfo.usri3_acct_expires);
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.SetAcctExpires                                          |
 |                                                                            |
 | 'Set' method for 'AcctExpires' property.                                   |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.SetAcctExpires (value : TDateTime);
//var
//  buffer : USER_INFO_1017;
//begin
//  if value <> AcctExpires then
//  begin
//    if value = 0 then
//      fInfo.usri3_acct_expires := TIMEQ_FOREVER
//    else
//      fInfo.usri3_acct_expires := DateTimeTotime_t (value);
//
//    buffer.usri1017_acct_expires := fInfo.usri3_acct_expires;
//    InfoBuffer [1017] := @buffer;
//  end
//end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetMaxStorage : Integer                                  |
 |                                                                            |
 | 'Get' method for the 'MaxStorage' property.                                |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetMaxStorage : Integer;
//begin
//  if not (uiMaxStorage in fInfoFlags) then
//    GetLevel3Info;
//
//  result := fInfo.usri3_max_storage;
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.SetMaxStorage                                           |
 |                                                                            |
 | 'Set' method for the MaxStorage property.                                  |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.SetMaxStorage (value : Integer);
//var
//  buffer : USER_INFO_1018;
//begin
//  if value <> MaxStorage then
//  begin
//    fInfo.usri3_max_storage := value;
//    buffer.usri1018_max_storage := fInfo.usri3_max_storage;
//    InfoBuffer [1018] := @buffer;
//  end
//end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetPrimaryGroupID : Integer                              |
 |                                                                            |
 | 'Get' method for the 'PrimaryGroupID' property.  Returns the relative ID   |
 | (RID) of the global group.                                                 |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetPrimaryGroupID : Integer;
//begin
//  if not (uiPrimaryGroupID in fInfoFlags) then
//    GetLevel3Info;
//
//  result := fInfo.usri3_primary_group_id;
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.SetPrimaryGroupID : Integer                             |
 |                                                                            |
 | 'Set' method for the 'PrimaryGroupID' property.                            |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.SetPrimaryGroupID (value : Integer);
//var
//  buffer : USER_INFO_1051;
//begin
//  if value <> PrimaryGroupID then
//  begin
//    fInfo.usri3_primary_group_id := value;
//    buffer.usri1051_primary_group_id := fInfo.usri3_primary_group_id;
//    InfoBuffer [1051] := @buffer;
//  end
//end;

(*----------------------------------------------------------------------------*
 | function TNetUser.GetProfile : string                                      |
 |                                                                            |
 | 'Get' method for the Profile property.  Returns the UNC path of the user's |
 | profile                                                                    |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetProfile : string;
//begin
//  if not (uiProfile in fInfoFlags) then
//    GetLevel3Info;
//
//  result := fInfo.usri3_profile;
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.SetProfile                                              |
 |                                                                            |
 | 'Set' method for the Profile property.                                     |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.SetProfile (const value : string);
//var
//  wValue : WideString;
//  buffer : USER_INFO_1052;
//begin
//  if value <> Profile then
//  begin
//    FreeMem (fInfo.usri3_profile);
//    wValue := value;
//    fInfo.usri3_profile := WStrNew (PWideChar (wValue));
//    buffer.usri1052_profile := fInfo.usri3_profile;
//    InfoBuffer [1052] := @buffer;
//  end
//end;


(*----------------------------------------------------------------------------*
 | function TNetUser.GetHomeDirDrive : string                                 |
 |                                                                            |
 | 'Get' method for the HomeDirDrive property.  Gets the drive letter for the |
 | user's home directory.                                                     |
 *----------------------------------------------------------------------------*)
//function TNetUser.GetHomeDirDrive : string;
//begin
//  if not (uiHomeDirDrive in fInfoFlags) then
//    GetLevel3Info;
//
//  result := fInfo.usri3_home_dir_drive;
//end;


(*----------------------------------------------------------------------------*
 | procedure TNetUser.SetHomeDirDrive                                         |
 |                                                                            |
 | 'Set' method for the HomeDirDrive property.                                |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.SetHomeDirDrive (const value : string);
//var
//  wValue : WideString;
//  buffer : USER_INFO_1053;
//begin
//  if value <> HomeDirDrive then
//  begin
//    FreeMem (fInfo.usri3_home_dir_drive);
//    wValue := value;
//    fInfo.usri3_home_dir_drive := WStrNew (PWideChar (wValue));
//    buffer.usri1053_home_dir_drive := fInfo.usri3_home_dir_drive;
//    InfoBuffer [1053] := @buffer;
//  end
//end;


(*----------------------------------------------------------------------------*
 | procedure TNetUser.CreateAccount                                           |
 |                                                                            |
 | Create a new lanman account.                                               |
 |                                                                            |
 | Parameters                                                                 |
 |  const description : string       The account comment.                     |
 |  const password : string          The account password.                    |
 *----------------------------------------------------------------------------*)
function TNetUser.CreateAccount (const Server:String ; const User:String; const description:String; const password:string):boolean;
var
  wServer, wUser, wPassword, wDescription : WideString;
  details : USER_INFO_1;
  parmErr : Integer;
  err : Integer;

begin
   wServer      := Server ;
   wUser        := User ;
   wDescription := Description ;
   wpassword    := wPassword ;


   FillChar (details, sizeof (details), 0);
   details.usri1_priv := USER_PRIV_USER;
   details.usri1_name := PWideChar (wUser);
   details.usri1_password := PWideChar (wPassword);
   details.usri1_comment := PWideChar (wDescription);
   details.usri1_flags := UF_SCRIPT;

   err := NetUserAdd (PWideChar (wServer), 1, @details, parmErr);

  result := (err = NERR_Success);
//  if err <> NERR_Success then
//    raise ENTException.Create (err)
//  else
//    begin
//      fInfo.usri3_comment := WStrNew (details.usri1_comment);
//      fInfo.usri3_flags := details.usri1_flags;
//      fInfoFlags := [uiComment, uiFlags];
//    end
end;


(*----------------------------------------------------------------------------*
 | procedure TNetUser.DeleteAccount                                           |
 |                                                                            |
 | Delete the user account.                                                   |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.DeleteAccount;
//var
//  wUser, wServer : WideString;
//  err : Integer;
//begin
//  ClearInfoBuffer;
//  GetWideName (wServer, wUser);
//  err := NetUserDel (PWideChar (wServer), PWideChar (wUser));
//  if err <> NERR_Success then
//    raise ENTException.Create (err)
//end;


(*----------------------------------------------------------------------------*
 | procedure TNetUser.SetPassword.                                            |
 |                                                                            |
 | 'Set' method for the (wo) password property.  Sets the password for the    |
 | account.   Needs 'Administrator' or 'DomainAdmins' access.                 |
 |                                                                            |
 | Parameters                                                                 |
 |   const value : string           The new password.                         |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.SetPassword (const value : string);
//var
//  wValue : WideString;
//  buffer : USER_INFO_1003;
//begin
//  wValue := value;
//  buffer.usri1003_password := PWideChar (wValue);
//  if fUpdating then
//  begin
//    if Assigned (fInfo.usri3_password) then
//      FreeMem (fInfo.usri3_password);
//    fInfo.usri3_password := WStrNew (PWideChar (wValue))
//  end;
//  InfoBuffer [1003] := @buffer;
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.RenameAccount                                           |
 |                                                                            |
 | Rename a user account.                                                     |
 |                                                                            |
 | Parameters                                                                 |
 |   const newName : string         The account's new name.                   |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.RenameAccount (const newName : string);
//var
//  wNewName : WideString;
//  buffer : USER_INFO_0;
//begin
//  wNewName := newName;
//  buffer.usri0_name := PWideChar (wNewName);
//  InfoBuffer [0] := @buffer;
//  fUserName := newName
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.GetWideName                                             |
 |                                                                            |
 | Private function to get wide-string versions of server & user names.       |
 |                                                                            |
 | Parameters                                                                 |
 |   var wServer : WideString           Returns the server name.              |
 |   var wUser : WideString             Returns the user name.                |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.GetWideName (var wServer, wUser : WideString);
//begin
//  if Assigned (server) then
//    wServer := Server.ServerName
//  else
//    wServer := '';
//
//  wUser := UserName;
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.BeginUpdate                                             |
 |                                                                            |
 | Starts an update.  This has the effect of:                                 |
 |   * Changes aren't written until they're committed by calling EndUpdate.   |
 |                                                                            |
 |   *  When the changes are finally written, they're written in a single     |
 |      chunk - which can improve performance.                                |
 *----------------------------------------------------------------------------*)
procedure TNetUser.BeginUpdate;
begin
  if fInfoFlags <> [Low (TNetUserComponents)..High (TNetUserComponents)] then
    raise Exception.Create ('Insufficient details to begin update.  Call GetUserInfo3 first.');

  if fUpdating then
    raise Exception.Create ('Already updating - can''t BeginUpdate');

  fUpdating := True;
end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.EndUpdate;                                              |
 |                                                                            |
 | Commits changes made since call to previous BeginUpdate                    |
 *----------------------------------------------------------------------------*)
//procedure TNetUser.EndUpdate;
//begin
//  if fUpdating then
//  begin
//    fUpdating := False;
//    InfoBuffer [3] := @fInfo;
//    if fInfo.usri3_password <> Nil then
//    begin
//      FreeMem (fInfo.usri3_password);
//      fInfo.usri3_password := Nil
//    end
//  end
//  else
//    raise Exception.Create ('EndUpdate called before BeginUpdate');
//end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.CancelUpdate                                            |
 |                                                                            |
 | Cancel changes made since calling BeginUpdate.                             |
 *----------------------------------------------------------------------------*)
procedure TNetUser.CancelUpdate;
begin
  ClearInfoBuffer
end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.AddToLocalGroup                                         |
 |                                                                            |
 | Add the user to a local group.  See also TNetLocalGroup.AddUser            |
 |                                                                            |
 | Parameters                                                                 |
 |   const group : string       The name of the local group to add the user   |
 |                              to.                                           |
 *----------------------------------------------------------------------------*)
procedure TNetUser.AddToLocalGroup (const group : string);
begin
  with TNetLocalGroup.Create (Nil) do
  try
    Server := self.Server;
    GroupName := group;
    AddMember (UserName)
  finally
    Free
  end
end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.RemoveFromLocalGroup                                    |
 |                                                                            |
 | Remove the user from a local group.  See also TNetLocalGroup.DeleteMember  |
 |                                                                            |
 | Parameters                                                                 |
 |   const group : string       The name of the local group to remove the     |
 |                              the user from.                                |
 *----------------------------------------------------------------------------*)
procedure TNetUser.RemoveFromLocalGroup (const group : string);
begin
  with TNetLocalGroup.Create (Nil) do
  try
    Server := self.Server;
    GroupName := group;
    DeleteMember (UserName)
  finally
    Free
  end
end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.AddToGlobalGroup                                        |
 |                                                                            |
 | Add the user to a global group.  See also TNetGlobalGroup.AddUser          |
 |                                                                            |
 | Parameters                                                                 |
 |   const group : string       The name of the global group to add the user  |
 |                              to.                                           |
 *----------------------------------------------------------------------------*)
procedure TNetUser.AddToGlobalGroup (const group : string);
begin
  with TNetGlobalGroup.Create (nil) do
  try
    Server := self.Server;
    GroupName := group;
    AddMember (UserName)
  finally
    Free
  end
end;

(*----------------------------------------------------------------------------*
 | procedure TNetUser.RemoveFromGlobalGroup                                   |
 |                                                                            |
 | Remove the user from a global group.  See also TNetGLobalGroup.DeleteMember|
 |                                                                            |
 | Parameters                                                                 |
 |   const group : string       The name of the global group to remove the    |
 |                              the user from.                                |
 *----------------------------------------------------------------------------*)
procedure TNetUser.RemoveFromGlobalGroup (const group : string);
begin
  with TNetGlobalGroup.Create (nil) do
  try
    Server := self.Server;
    GroupName := group;
    DeleteMember (UserName)
  finally
    Free
  end
end;


procedure Register;
begin
  RegisterComponents('Lan Manager', [TNetUser]);
end;

end.
