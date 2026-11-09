{  Module          Manager NETAPI32
   Unit            Automation User
   Copyright(c)    Postal Solutions Limited 1998..1998
   Author          DDB
   Description     Create easy access to NETAPI32.DLL .
                              Original Release
}
unit NetUserAU;

interface

uses
  lmErr,
  FrmMan, UserMan, FrProper,
  GPCSBase_TLB, GPCSErrorCode, GPCSErrorLine,  
  Classes, SysUtils,
  Windows,
  ComObj, ActiveX, Umanager_TLB;

type
  TNetUser = class(TAutoObject, INetUser)
  private
    FUserName             : WideString ;  { Current User Name }
    FServerName           : WideString;   { Current Server Name }
    FAccountDisable       : WordBool ;    {  State of Account disable for
                                             the current user }
    FCannotChangePassword : WordBool ;    {  State of Cannot change the password
                                             for the current user }
    FComment              : WideString ;  { Comment for the current user }
    FFullName             : WideString ;  { Full Name for the current user }
    FHomeDirRequired      : WordBool ;    {  State of Home Dir for the current
                                            user  }
    FLockout              : WordBool ;    { State Lock Out for the current user }
    FPassword             : WideString ;  { Password for the current user }
    FPasswordNeverExpired : WordBool ;    { State of Password Never Expired
                                            for the current user }
    FPasswordNotRequired  : WordBool ;    { state Password not Required for the
                                            current user}
    FHomeDir              : WideString ;  { Home directory for the current user}
    FLastLogOff           : TDateTime ;   { Time of last log off for the
                                            current user }
    FLastLogOn            : TDateTime ;   { Time of last log on for the
                                            current user }
    FLogonCount           : integer ;     { Number of Times that the current user
                                            has log on }
    FScript               : WordBool ;    { Get the logon scrit executed state
                                            for the current user }
    FMemberOfGlobal       : WideString ;  { Global groups that the user is
                                            a member}
    FMemberOfLocal        : WideString ;  { Local groups that the user
                                            is a member }
    FWorkStation          : WideString ;  { work station from which,
                                            the user can log on }
    FWrongLogonCount      : integer  ;    { Number of times that the user
                                            fail to log on }
    FDomain               : WideString ;  { Domain the current user }
    FStatus               : integer ;

    procedure SetFlags ;
    procedure HandleStatusError( sMsg : String ) ;

  protected
    function Get_AccountDisable: WordBool; safecall;
    function Get_CannotChangePassword: WordBool; safecall;
    function Get_Comment: WideString; safecall;
    function Get_FullName: WideString; safecall;
    function Get_HomeDirRequired: WordBool; safecall;
    function Get_Lockout: WordBool; safecall;
    function Get_PasswordNeverExpired: WordBool; safecall;
    function Get_PasswordNotRequired: WordBool; safecall;
    procedure Set_AccountDisable(Value: WordBool); safecall;
    procedure Set_CannotChangePassword(Value: WordBool); safecall;
    procedure Set_Comment(const Value: WideString); safecall;
    procedure Set_FullName(const Value: WideString); safecall;
    procedure Set_HomeDirRequired(Value: WordBool); safecall;
    procedure Set_Lockout(Value: WordBool); safecall;
    procedure Set_Password(const Value: WideString); safecall;
    procedure Set_PasswordNeverExpired(Value: WordBool); safecall;
    procedure Set_PasswordNotRequired(Value: WordBool); safecall;
    function Get_HomeDir: WideString; safecall;
    function Get_LastLogOff: TDateTime; safecall;
    function Get_lastLogOn : TDateTime; safecall;
    function Get_LogonCount: Integer; safecall;
    function Get_MemberOfGlobal: WideString; safecall;
    function Get_WorkStation: WideString; safecall;
    function Get_WrongLogonCount: Integer; safecall;
    procedure Set_HomeDir(const Value: WideString); safecall;
    procedure Set_MemberOfGlobal(const Value: WideString); safecall;
    procedure Set_WorkStation(const Value: WideString); safecall;
    procedure GetUserInformation; safecall;
    function Get_Script: WordBool; safecall;
    function Get_Domain: WideString; safecall;
    function Get_MemberOfLocal: WideString; safecall;
    procedure Set_MemberOfLocal(const Value: WideString); safecall;
    procedure SetUser(const ServerNAme, UserNAme: WideString); safecall;
    function Get_UserName: WideString; safecall;
    function Get_ServerName: WideString; safecall;
    function Get_Status: Integer; safecall;
  end;


implementation

uses ComServ2;




procedure TNetUser.HandleStatusError( sMsg : String ) ;
var
  iErrorNumber : integer ;
begin
  iErrorNumber := StrToInt( Copy( sMsg, 1 , Pos( ':', sMsg )-1  ) );
  case iErrorNumber of
    ERROR_ACCESS_DENIED   : FStatus := nmsAccessDenied ;
    NERR_InvalidComputer  : FStatus := nmsInvalidComputer ;
    NERR_NetworkError     : FStatus := nmsNetworkError ;
    NERR_GroupNotFound    : FStatus := nmsGroupNoFound ;    
    NERR_UserNotFound     : FStatus := nmsUserNoFound ;
    NERR_PasswordTooShort : FStatus := nmsPasswordTooShort ;
    NERR_PasswordTooRecent: FStatus := nmsPasswordTooRecent ;
  else
    FStatus := nmsUndefinedError ;
  end ;

end ;

{===============================================================================

<Sysnopsis>       Get the user's name.

<Description>     Get the user's name.

<Result>          WideString with user name.

________________________________________________________________________________}
function TNetUser.Get_UserName: WideString;
begin
  Result := FUserName
end;
{===============================================================================

<Sysnopsis>       Get Account Disable State.

<Description>     Get Account Disable State.

<Result>          Boolean of AccountDisable's State

________________________________________________________________________________}
function TNetUser.Get_AccountDisable: WordBool;
begin
  Result := FAccountDisable ;
end;
{===============================================================================

<Sysnopsis>        Get state if cannot change password.

<Description>     Get state if cannot change password

<Result>          a Boolean of Cannot Change Password State

________________________________________________________________________________}
function TNetUser.Get_CannotChangePassword: WordBool;
begin
  Result := FCannotChangePassword ;
end;
{===============================================================================

<Sysnopsis>       Get Comment.

<Description>     Get Comment.

<Result>          a String of the comment.

________________________________________________________________________________}
function TNetUser.Get_Comment: WideString;
begin
  Result := FComment ;
end;
{===============================================================================

<Sysnopsis>       Get Full name.

<Description>     Get Full name.

<Result>          a String of full name.

________________________________________________________________________________}
function TNetUser.Get_FullName: WideString;
begin
  Result := FFullName ;
end;
{===============================================================================

<Sysnopsis>      Get Home dir Required state ( ignored in windows NT ).

<Description>     Get Home dir Required state ( ignored in windows NT ).

<Result>          a Boolean of Home Dir Required.

________________________________________________________________________________}
function TNetUser.Get_HomeDirRequired: WordBool;
begin
  Result := FHomeDirRequired ;
end;
{===============================================================================

<Sysnopsis>       Get the lockout state of an account.

<Description>     Get the lockout state of an account.

<Result>          a Boolean of Lockout.

________________________________________________________________________________}
function TNetUser.Get_Lockout: WordBool;
begin
  Result := FLockout ;
end;
{===============================================================================

<Sysnopsis>       Get Password Never Expired status of the current user.

<Description>     Get Password Never Expired status of the current user.

<Result>          a Boolean of Passowrd Never Expired.

________________________________________________________________________________}
function TNetUser.Get_PasswordNeverExpired: WordBool;
begin
  Result := FPasswordNeverExpired ;
end;
{===============================================================================

<Sysnopsis>       Get Password Not Required status of the current user.

<Description>     Get Password Not Required status of the current user.

<Result>          a Boolean of Passowrd not Required Status.

________________________________________________________________________________}
function TNetUser.Get_PasswordNotRequired: WordBool;
begin
  Result := FPasswordNotRequired ;
end;
{===============================================================================

<Sysnopsis>       Set Account Disable State of the current user.

<Description>     Set Account Disable State of the current user.

<Post state>      If new value is different than old value then
                  it will change it and will refresh the UserMan component
                  information.

<Value>           Boolean of State to set Account Disable.

________________________________________________________________________________}
procedure TNetUser.Set_AccountDisable(Value: WordBool);
begin
  if Value <> FAccountDisable then
  begin
    try

      ServerForm.UserMan.UserName := FUserName ;
      ServerForm.UserMan.MachineName := FServerName ;
      FAccountDisable := Value ;
      SetFlags ;      // Set Flags such as expired password, account disable.
      FStatus := nmsOk ;

    except

      on e : exception do
      begin
        GPCSErrorLine.RaiseException($851, E);
        HandleStatusError( e.message );
      end ;

    end ;
  end ;
end;
{===============================================================================

<Sinopsis>        Set the current user state of can not change the password.

<Description>     Set the current user state of can not change the password.

<Post state>      If new value is different than old value then
                  it will change it and will refresh the UserMan component
                  information.

<Value>           a Boolean of State to set Can not change the password.

________________________________________________________________________________}
procedure TNetUser.Set_CannotChangePassword(Value: WordBool);
begin
  if Value <> FCannotChangePassword then
  begin
    try

      ServerForm.UserMan.UserName := FUserName ;
      ServerForm.UserMan.MachineName := FServerName ;
      FCannotChangePassword := Value ;
      SetFlags ;        // Set Flags such as expired password, account disable.
      FStatus := nmsOk ;

    except

      on e : exception do
      begin

        GPCSErrorLine.RaiseException($852, E);
        HandleStatusError( e.message );

      end ;

    end ;

  end ;
end;
{===============================================================================
  Class        TNetUser
  Method       Set_Comment
  Description  Set the comment of the current user
  Params       a String of Comment
  Result       None
________________________________________________________________________________}
procedure TNetUser.Set_Comment(const Value: WideString);
begin
  if Value <> FComment then
  begin
    try

      ServerForm.UserMan.UserName := FUserName ;
      ServerForm.UserMan.MachineName := FServerName  ;
      FComment := Value ;
      ServerForm.UserMan.UserInfo.Comment := Value ;
      FStatus := nmsOk ;

    except

      on e : exception do
      begin

        GPCSErrorLine.RaiseException($853, E);
        HandleStatusError( e.message );

      end ;
      
    end ;
  end ;
end;
{===============================================================================
  Class        TNetUser
  Method       Set_FullName
  Description  Set the full name of the current user
  Params       a String of full name
  Result       None
________________________________________________________________________________}
procedure TNetUser.Set_FullName(const Value: WideString);
begin
  if Value <> FFullName then
  begin
    try

      ServerForm.UserMan.UserName := FUserName ;
      ServerForm.UserMan.MachineName := FServerName ;
      FFullName := Value ;
      ServerForm.UserMan.UserInfo.FullName := Value ;
      FStatus := nmsOk ;

    except

      on e : exception do
      begin

        GPCSErrorLine.RaiseException($854, E);
        HandleStatusError( e.message );

      end ;

    end ;

  end ;
end;
{===============================================================================
  Class        TNetUser
  Method       Set_HomeDirRequired
  Description  Set the Home Dir Required state of the current user ( ingnored
                                                              in windows NT )
  Params       a Boolean of Home Dir Required
  Result       None
________________________________________________________________________________}
procedure TNetUser.Set_HomeDirRequired(Value: WordBool);
begin
  if Value <> FHomeDirRequired then
  begin
    try

      ServerForm.UserMan.UserName := FUserName ;
      ServerForm.UserMan.MachineName := FServerName ;
      FHomeDirRequired := Value ;
      SetFlags ;        // Set Flags such as expired password, account disable.
      FStatus := nmsOk ;

    except

      on e : exception do
      begin

        GPCSErrorLine.RaiseException($855, E);
        HandleStatusError( e.message );

      end ;

    end ;
  end ;
end;
{===============================================================================
  Class        TNetUser
  Method       Set_Lockout
  Description  Set the Lockout state of current user's account
  Params       a Boolean of Lockout
  Result       None
________________________________________________________________________________}
procedure TNetUser.Set_Lockout(Value: WordBool);
begin
  if Value <> FLockout then
  begin
    try

      ServerForm.UserMan.UserName := FUserName ;
      ServerForm.UserMan.MachineName := FServerName ;
      FLockout := Value ;
      SetFlags ;         // Set Flags such as expired password, account disable.
      FStatus := nmsOk ;

    except

      on e : exception do
      begin

        GPCSErrorLine.RaiseException($856, E);
        HandleStatusError( e.message );

      end ;

    end ;
  end ;
end;
{===============================================================================
  Class        TNetUser
  Method       Set_Password
  Description  Set the Password of the current user
  Params       a String of Password
  Result       None
________________________________________________________________________________}
procedure TNetUser.Set_Password(const Value: WideString);
begin

  if Value <> FPassword then
  begin
    try

      ServerForm.UserMan.UserName := FUserName ;
      ServerForm.UserMan.MachineName := FServerName ;
      FPassword := Value ;
      ServerForm.UserMan.UserInfo.Password := Value ;
      FStatus := nmsOk ;

    except

      on e : exception do
      begin

        GPCSErrorLine.RaiseException($857, E);
        HandleStatusError( e.message );

      end ;

    end ;

  end ;
end;
{===============================================================================
  Class        TNetUser
  Method       Set_PasswordNeverExpired
  Description  Set the Password Never Expired state of the current user
  Params       a Boolean of Password Never Expired
  Result       None
________________________________________________________________________________}
procedure TNetUser.Set_PasswordNeverExpired(Value: WordBool);
begin
  if Value <> FPasswordNeverExpired then
  begin
    try

      ServerForm.UserMan.UserName := FUserName ;
      ServerForm.UserMan.MachineName := FServerName ;
      FPasswordNeverExpired := Value ;
      SetFlags ;        // Set Flags such as expired password, account disable.
      FStatus := nmsOk ;

    except

      on e : exception do
      begin

        GPCSErrorLine.RaiseException($858, E);
        HandleStatusError( e.message );

      end ;

    end ;

  end ;
end;
{===============================================================================
  Class        TNetUser
  Method       Set_PasswordNotRequired
  Description  Set the Password Not Required state of the current user
  Params       a Boolean of Password Not Required
  Result       None
________________________________________________________________________________}
procedure TNetUser.Set_PasswordNotRequired(Value: WordBool);
begin

  if Value <> FPasswordNotRequired then
  begin
    try

      ServerForm.UserMan.UserName := FUserName ;
      ServerForm.UserMan.MachineName := FServerName ;
      FPasswordNotRequired := Value ;
      SetFlags ;     // Set Flags such as expired password, account disable.
      FStatus := nmsOk ;

    except

      on e : exception do
      begin

        GPCSErrorLine.RaiseException($859, E);
        HandleStatusError( e.message );

      end ;

    end ;

  end ;

end;
{===============================================================================
  Class        TNetUser
  Method       Get_HomeDir
  Description  Get the path Home directory of the current user
  Params       None
  Result       a String of Home Directory's path
________________________________________________________________________________}
function TNetUser.Get_HomeDir: WideString;
begin
  Result := FHomeDir ;
end;
{===============================================================================
  Class        TNetUser
  Method       Get_LastLogOff
  Description  Get Last logoff the current user
  Params       None
  Result       a DateTime of Last logoff
________________________________________________________________________________}
function TNetUser.Get_LastLogOff: TDateTime;
begin
  Result := FLastLogOff ;
end;
{===============================================================================
  Class        TNetUser
  Method       Get_LastLogon
  Description  Get Last logon of the current user
  Params       None
  Result       a DateTime of Last logon
________________________________________________________________________________}
function TNetUser.Get_LastLogon: TDateTime;
begin
  Result := FLastLogon ;
end;
{===============================================================================
  Class        TNetUser
  Method       Get_LogonCount
  Description  Get a number of how many time the current user has logon
  Params       None
  Result       a integer of logon's counter
________________________________________________________________________________}
function TNetUser.Get_LogonCount: Integer;
begin
  Result := FLogonCount ;
end;
{===============================================================================
  Class        TNetUser
  Method       Get_MemberOfGlobal
  Description  Get global groups that the current member belong
  Params       None
  Result       a string of groups that the current member belong
________________________________________________________________________________}
function TNetUser.Get_MemberOfGlobal: WideString;
begin
  Result := FMemberOfGlobal ;
end;
{===============================================================================
  Class        TNetUser
  Method       Get_WorkStation
  Description  Get the names of work station from which, the user can log on
  Params       None
  Result       a string of Work Station's names
________________________________________________________________________________}
function TNetUser.Get_WorkStation: WideString;
begin
  Result := FWorkStation ;
end;
{===============================================================================
  Class        TNetUser
  Method       Get_WrongLogonCount
  Description  Get a number of how many times the user fail the logon
  Params       None
  Result       a integer of wrong logon
________________________________________________________________________________}
function TNetUser.Get_WrongLogonCount: Integer;
begin
  Result := FWrongLogonCount ;
end;
{===============================================================================
  Class        TNetUser
  Method       Set_HomeDir
  Description  Set path of the home directory
  Params       a string of home directory path
  Result       None
________________________________________________________________________________}
procedure TNetUser.Set_HomeDir(const Value: WideString);
begin
  if Value <> FHomeDir then
  begin
    try

      ServerForm.UserMan.UserName := FUserName ;
      ServerForm.UserMan.MachineName := FServerName ;
      FHomeDir := Value ;
      ServerForm.UserMan.UserInfo.HomeDir := Value ;
      FStatus := nmsOk ;

    except

      on e : exception do
      begin

        GPCSErrorLine.RaiseException($860, E);
        HandleStatusError( e.message );

      end ;

    end ;

  end ;
end;
{===============================================================================
  Class        TNetUser
  Method       Set_MemberOfGlobal
  Description  Set Global groups that the current member belong.
  Params       a string global groups
  Result       None
________________________________________________________________________________}
procedure TNetUser.Set_MemberOfGlobal(const Value: WideString);
var
  MemberStringList : TStringList ;
begin


  if Value <> FMemberOfGlobal then
  begin
    try

      MemberStringList := TStringList.create ;
      try
        MemberStringList.CommaText := Value ;
        ServerForm.UserMan.UserName := FUserName ;
        ServerForm.UserMan.MachineName := FServerName ;
        FMemberOfGlobal := Value ;
        ServerForm.UserMan.MemberOfGlob := MemberStringList ;
        FStatus := nmsOk ;
      finally
        MemberStringList.Free ;
      end ;

    except

      on e : exception do
      begin

        GPCSErrorLine.RaiseException($861, E);
        HandleStatusError( e.message );

      end ;

    end ;

  end ;
end;
{===============================================================================
  Class        TNetUser
  Method       Set_WorkStation
  Description  Set the names of work station from which, the user can log on
  Params       a string of Work station's names
  Result       None
________________________________________________________________________________}
procedure TNetUser.Set_WorkStation(const Value: WideString);
begin
  if Value <> FWorkStation then
  begin
    try
      ServerForm.UserMan.UserName := FUserName ;
      ServerForm.UserMan.MachineName := FServerName ;
      FWorkStation := Value ;
      FStatus := nmsOk ;
    except

      on e : exception do
      begin

        GPCSErrorLine.RaiseException($862, E);
        HandleStatusError( e.message );

      end ;

    end ;

  end ;
end;
{===============================================================================
  Class        TNetUser
  Method       GetUserInformation
  Description  Set the property values of the current user
  Params       None
  Result       None
________________________________________________________________________________}
procedure TNetUser.GetUserInformation;
begin

  try
    ServerForm.UserMan.UserName :=  FUserName ;
    ServerForm.UserMan.MachineName :=  FServerName ;

    with ServerForm.UserMan, PropertyForm do
    begin

      FAccountDisable       := FALSE ;
      FCannotChangePassword := FALSE ;
      FComment              := '' ;
      FFullName             := '' ;
      FHomeDirRequired      := FALSE ;
      FLockout              := FALSE ;
      FPassword             := '' ;
      FPasswordNeverExpired := FALSE ;
      FPasswordNotRequired  := FALSE ;
      FHomeDir              := '' ;
      FLastLogOff           := Now ;
      FLastLogon            := Now ;
      FLogonCount           := 0 ;
      FScript               := FALSE ;
      FDomain               := '' ;
      FMemberOfGlobal       := '' ;
      FMemberOfLocal        := '' ;
      FWorkStation          := '' ;
      FWrongLogonCount      := 0 ;

      // -----------------------------------------------------------

      FAccountDisable       := F_ACCOUNTDISABLE in UserInfo.Options ;
      FCannotChangePassword := F_PASSWD_CANT_CHANGE in UserInfo.Options ;
      FComment              := UserInfo.Comment ;
      FFullName             := UserInfo.FullName ;
      FHomeDirRequired      := F_HOMEDIR_REQUIRED in UserInfo.Options ;
      FLockout              := F_LOCKOUT in UserInfo.Options ;
      FPassword             := '' ;
      FPasswordNeverExpired := F_DONT_EXPIRE_PASSWD in UserInfo.Options ;
      FPasswordNotRequired  := F_PASSWD_NOTREQD in UserInfo.Options ;
      FHomeDir              := UserInfo.HomeDir ;
      FLastLogOff           := UserInfo.LastLogOff ;
      FLastLogon            := UserInfo.LastLogon ;
      FLogonCount           := UserInfo.LogonCount ;
      FScript               := F_SCRIPT in UserInfo.Options ;
      FDomain               := UserInfo.Domain ;
      FMemberOfGlobal       := ServerForm.UserMan.MemberOfGlob.CommaText ;
      FMemberOfLocal        := ServerForm.UserMan.MemberOfLocal.CommaText ;
      FWorkStation          := UserInfo.Workstations ;
      FWrongLogonCount      := UserInfo.BadPasswordCount ;

    end ;
    FStatus := nmsOk ;

  except

    on e : exception do
    begin

      GPCSErrorLine.RaiseException($863, E);
      HandleStatusError( e.message );

    end ;

  end ;

end;
{===============================================================================
  Class        TNetUser
  Method       Get_Script
  Description  Get the logon scrit executed state of the current user
  Params       None
  Result       a Boolean of logon script executed
________________________________________________________________________________}
function TNetUser.Get_Script: WordBool;
begin
  Result := FScript ;
end;
{===============================================================================
  Class        TNetUser
  Method       Get_Domain
  Description  Get the domain of the current user
  Params       None
  Result       a string of the domain
________________________________________________________________________________}
function TNetUser.Get_Domain: WideString;
begin
  Result := FDomain ;
end;
{===============================================================================
  Class        TNetUser
  Method       Get_MemberOfLocal
  Description  Get local groups that the current member belong.
  Params       None
  Result       a string of local groups
________________________________________________________________________________}
function TNetUser.Get_MemberOfLocal: WideString;
begin
  Result := FMemberOfLocal ;
end;
{===============================================================================
  Class        TNetUser
  Method       Set_MemberOfLocal
  Description  Set local groups that the current member belong.
  Params       a string of local groups
  Result       None
________________________________________________________________________________}
procedure TNetUser.Set_MemberOfLocal(const Value: WideString);
var
  MemberStringList : TStringList ;
begin

  if Value <> FMemberOfLocal then
  begin
    try
      MemberStringList := TStringList.Create ;
      try
        ServerForm.UserMan.UserName := FUserName ;
        ServerForm.UserMan.MachineName := FServerName ;
        FMemberOfLocal := Value ;
        MemberStringList.CommaText := Value ;
        ServerForm.UserMan.MemberOfLocal := MemberStringList ;
        FStatus := nmsOk ;
      finally
        MemberStringList.Free ;
      end ;

    except

      on e : exception do
      begin

        GPCSErrorLine.RaiseException($864, E);
        HandleStatusError( e.message );

      end ;

    end ;

  end ;

end;
{===============================================================================
  Class        TNetUser
  Method       SetFlags
  Description  Set Flags of the current member
  Params       None
  Result       None
________________________________________________________________________________}
procedure TNetUser.SetFlags ;
var
      Opt : TUserFlags ;
begin
  Opt := [] ;

  if  FScript                 then Opt := Opt + [F_SCRIPT];
  if  FAccountDisable         then Opt := Opt + [F_ACCOUNTDISABLE];
  if  FHomeDirRequired        then Opt := Opt + [F_HOMEDIR_REQUIRED];
  if  FLockout                then Opt := Opt + [F_LOCKOUT];
  if  FPasswordNotRequired    then Opt := Opt + [F_PASSWD_NOTREQD];
  if  FCannotChangePassword   then Opt := Opt + [F_PASSWD_CANT_CHANGE];
  if  FPasswordNeverExpired   then Opt := Opt + [F_DONT_EXPIRE_PASSWD];

  ServerForm.UserMan.UserInfo.Options := Opt;

end ;
{===============================================================================
  Class        TNetUser
  Method       SetUser
  Description  Set an user with an server and get the information into the
                properties.
  Params       ServerName : a string with the Server Name
               UserName   : a string with the User Name
  Result       None
________________________________________________________________________________}
procedure TNetUser.SetUser(const ServerNAme, UserNAme: WideString);
begin
  if (UserName <> FUserName) or (ServerName <> FServerName) then
  begin
    FUserName := UserName ;       // Set the information for the current user
    FServerName := ServerName ;
    GetUserInformation ;          // Enter the information into the properties
  end;

end;
{===============================================================================
  Class        TNetUser
  Method       Get_ServerName
  Description  Get the current server name
  Params       None
  Result       a String with the current server name
________________________________________________________________________________}
function TNetUser.Get_ServerName: WideString;
begin
  Result := FServerName ;
end;
{===============================================================================
  Class        TNetUser
  Method       Get_Status
  Description  Get the current status
  Params       None
  Result       a integer value of the status
________________________________________________________________________________}
function TNetUser.Get_Status: Integer;
begin
  Result := FStatus ;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TNetUser, Class_NetUser, ciMultiInstance);
end.
