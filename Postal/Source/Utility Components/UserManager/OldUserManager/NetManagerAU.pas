{  Module          Manager NETAPI32
   Unit            Automation Net Manager
   Copyright(c)    Postal Solutions Limited 1998..1998
   Author          DDB
   Description     Create easy access to NETAPI32.DLL .
                              Original Release
}
unit NetManagerAU;

interface

uses
  FrmMan,NetUserAu, lmErr,
  Classes, SysUtils, Dialogs,
  GPCSBase_TLB, GPCSErrorCode, GPCSErrorLine,
  Windows,
  ComObj, ActiveX, Umanager_TLB;

type

  LPCWSTR = PWideChar;
  LPBYTE = ^Byte;
  PPointer = ^Pointer;

  TNetManager = class(TAutoObject, INetManager)

  private
    FStatus : integer     { Status of the last operaton };
    FGetUser : INetUser;  { it is using to create a new user
                            which can keep the information }
    procedure HandleStatusError( sMsg : String ) ;

  protected
    function AddGlobalGroup(const ServerName, GroupName: WideString): WordBool;
      safecall;
    function AddLocalGroup(const ServerName, GroupName: WideString): WordBool;
      safecall;
    function AddUser(const ServerName, UserName: WideString): WordBool;
      safecall;
    function DeleteGlobalGroup(const ServerName,
      GroupName: WideString): WordBool; safecall;
    function DeleteLocalGroup(const ServerName,
      GroupName: WideString): WordBool; safecall;
    function DeleteUser(const ServerName, UserName: WideString): WordBool;
      safecall;
    function GetGlobalGroups(const ServerName: WideString): WideString;
      safecall;
    function GetLocalGroups(const ServerName: WideString): WideString;
      safecall;
    function GetUsers( Const ServerName: WideString): WideString; safecall;
    function GetUser(const ServerName, UserName: WideString): INetUser;
      safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function GetServers: WideString; safecall;
    function Get_Status: NetManagerStatus; safecall;
    function GetPDC: WideString; safecall;
    function ChangePassword(const Servername, UserName, oldPassword,
      NewPassword: WideString): WordBool; safecall;
  end;


   function NetGetDCName (servername : LPCWSTR; domainname : LPCWSTR;
      var bufptr : LPBYTE) : DWORD; stdcall;

   function NetApiBufferFree(var bufptr : LPBYTE) : DWORD; stdcall;

   function NetUserChangePassword (domainname : LPCWSTR; username : LPCWSTR;
            oldpassword : LPCWSTR; newpassword : LPCWSTR) : DWORD; stdcall;

//var
//  AutoObjectFactory : TTypedComObjectFactory;


implementation

uses ComServ2;

Const
  NetApiDll = 'NetAPI32.DLL';

function NetGetDCName    ; external NetApiDll name 'NetGetDCName';
function NetApiBufferFree; external NetApiDll name 'NetApiBufferFree';
function NetUserChangePassword ; external NetApiDll name 'NetUserChangePassword';

{===============================================================================
  Class        TNetManager
  Method       HandleStatusError
  Description  Set the status in case of error
  Params       sMsg : a string with the error
               UserName   : a string with the user name
  Result       None
________________________________________________________________________________}
procedure TNetManager.HandleStatusError( sMsg : String ) ;
var
  iErrorNumber : integer ;
begin
  iErrorNumber := StrToInt( Copy( sMsg, 1 , Pos( ':', sMsg )-1  ) );
  case iErrorNumber of
    ERROR_ACCESS_DENIED   : FStatus := nmsAccessDenied ;
    NERR_UserExists       : FStatus := nmsUserExists ;
    NERR_GroupExists      : FStatus := nmsGroupExists ;
    NERR_ResourceExists   : FStatus := nmsResourceExit ;
    NERR_InvalidComputer  : FStatus := nmsInvalidComputer ;
    NERR_SpeGroupOp       : FStatus := nmsOprtnNoAllowInGroup ;
    NERR_NotPrimary       : FStatus := nmsNotPrimary ;
    NERR_RemoteOnly       : FStatus := nmsRemoteOnly  ;
    NERR_NetworkError     : FStatus := nmsNetworkError ;
    NERR_GroupNotFound    : FStatus := nmsGroupNoFound ;
    NERR_UserNotFound     : FStatus := nmsUserNoFound ;
    NERR_ResourceNotFound : FStatus := nmsResourceNoFound ;
    NERR_PasswordTooShort : FStatus := nmsPasswordTooShort ;
    NERR_PasswordTooRecent: FStatus := nmsPasswordTooRecent ;
  else
    FStatus := nmsUndefinedError ;

  end ;
end ;
{===============================================================================
  Class        TNetManager
  Method       AddUser
  Description  Add new user
  Params       ServerName : a string with the server name where add the new user
               UserName   : a string with the user name
  Result       None
________________________________________________________________________________}
function TNetManager.AddUser(const ServerName,
  UserName: WideString): WordBool;
begin
  try
    ServerForm.UserMan.MachineName := Trim( ServerName ) ;
    ServerForm.UserMan.Users.Add( UserName );
    if ServerForm.Visible then
      ServerForm.LocalRadioButtonClick(nil);// Actualiz the information in the main form
    FStatus := nmsOk ;
    result := TRUE ;
  except

    on e : exception do
    begin
      GPCSErrorLine.RaiseException($800, E);
      result := FALSE ;
      HandleStatusError( e.message );
    end ;

  end
end;
{===============================================================================
  Class        TNetManager
  Method       AddLocalGroup
  Description  Add local group in a server
  Params       ServerName : a string with the server name
                            where add the new group
               GroupName   : a string with the group name
  Result       None
________________________________________________________________________________}
function TNetManager.AddLocalGroup(const ServerName,
  GroupName: WideString): WordBool;
begin
  try

    ServerForm.UserMan.MachineName := Trim( ServerName ) ;
    ServerForm.UserMan.LocalGroups.Add( GroupName );
    if ServerForm.Visible then
      ServerForm.LocalRadioButtonClick(nil);// Actualiz the information in the main form
    FStatus := nmsOk ;
    result := TRUE ;

  except

    on e : exception do
    begin
      GPCSErrorLine.RaiseException($801, E);
      result := FALSE ;
      HandleStatusError( e.message );
    end ;

  end ;

end;
{===============================================================================
  Class        TNetManager
  Method       AddGlobalGroup
  Description  Add global group in a server
  Params       ServerName : a string with the server name
                            where add the new group
               GroupName   : a string with the group name
  Result       None
________________________________________________________________________________}
function TNetManager.AddGlobalGroup(const ServerName,
  GroupName: WideString): WordBool;
begin
  try

    ServerForm.UserMan.MachineName := Trim( ServerName ) ;
    ServerForm.UserMan.GlobalGroups.Add( GroupName );
    if ServerForm.Visible then
      ServerForm.LocalRadioButtonClick(nil);// Actualiz the information in the main form
    FStatus := nmsOk ;
    result := TRUE ;

  except

    on e : exception do
    begin
      GPCSErrorLine.RaiseException($802, E);
      result := FALSE ;
      HandleStatusError( e.message );
    end ;

  end ;

end;
{===============================================================================
  Class        TNetManager
  Method       DeleteGlobalGroup
  Description  Delete global group in a server
  Params       ServerName : a string with the server name
                            where delete the group
               GroupName   : a string with the group name
  Result       None
________________________________________________________________________________}
function TNetManager.DeleteGlobalGroup(const ServerName,
  GroupName: WideString): WordBool;
var
  GroupPosition : Integer ;
  sMsgError : String ;
begin

  try
        // It must find out the possition of the GroupName in the List
        // to use the component method delete
    ServerForm.UserMan.MachineName := Trim( ServerName ) ;
    GroupPosition := ServerForm.UserMan.GlobalGroups.IndexOf( GroupName ) ;
    if GroupPosition >= 0 then
    begin
      ServerForm.UserMan.GlobalGroups.Delete( GroupPosition );
      if ServerForm.Visible then
        ServerForm.LocalRadioButtonClick(nil);// Actualiz the information in the main form
      FStatus := nmsOk ;
      result := TRUE ;
    end
    else
      // The group name is wrong then it will update with the correct status
      sMsgError := IntToStr( NERR_GroupNotFound )+ ': User name could not be found ';

  except

    on e : exception do
    begin
      GPCSErrorLine.RaiseException($803, E);
      sMsgError := e.message ;
    end ;

  end ;

  if sMsgError <> '' then
  begin
    result := FALSE ;
    HandleStatusError( sMsgError );
  end ;


end;
{===============================================================================
  Class        TNetManager
  Method       DeleteLocalGroup
  Description  Delete local group in a server
  Params       ServerName : a string with the server name
                            where delete the group
               GroupName  : a string with the group name
  Result       None
________________________________________________________________________________}
function TNetManager.DeleteLocalGroup(const ServerName,
  GroupName: WideString): WordBool;
var
  GroupPosition : Integer ;
  sMsgError : String ;
begin

  try

        // It must find out the possition of the GroupName in the List
        // to use the component method delete
    ServerForm.UserMan.MachineName := Trim( ServerName ) ;
    GroupPosition := ServerForm.UserMan.LocalGroups.IndexOf( GroupName ) ;
    sMsgError := '' ;

    if GroupPosition >= 0 then
    begin
      ServerForm.UserMan.LocalGroups.Delete( GroupPosition );
      if ServerForm.Visible then
        ServerForm.LocalRadioButtonClick(nil);  // Actualiz the information in
      FStatus := nmsOk ;                                      // the main form
      result := TRUE ;
    end
    else
      // The group name is wrong then it will update with the correct status
      sMsgError := IntToStr( NERR_GroupNotFound )+ ': User name could not be found ';

  except

    on e : exception do
    begin
      GPCSErrorLine.RaiseException($804, E);
      sMsgError := e.message ;
    end ;

  end ;

  if sMsgError <> '' then
  begin
    result := FALSE ;
    HandleStatusError( sMsgError );
  end ;




end;
{===============================================================================
  Class        TNetManager
  Method       DeleteUser
  Description  Delete user in a server
  Params       ServerName : a string with the server name
                            where delete the user
               UserName   : a string with the user name
  Result       None
________________________________________________________________________________}
function TNetManager.DeleteUser(const ServerName,
  UserName: WideString): WordBool;
var
  UserPosition : Integer ;
  sMsgError : string ;
begin

  try
        // It must find out the possition of the UserName in the List
        // to use the component method delete
    ServerForm.UserMan.MachineName := Trim( ServerName ) ;
    UserPosition := ServerForm.UserMan.Users.IndexOf( UserName ) ;
    sMsgError := '' ;

    if UserPosition >= 0 then
    begin
      ServerForm.UserMan.Users.Delete( UserPosition );
      if ServerForm.Visible then
        ServerForm.LocalRadioButtonClick(nil);// Actualiz the information in the main form
      FStatus := nmsOk ;
      result := TRUE ;
    end
    else
      // The user name is wrong then it will update with the correct status
      sMsgError := INtToStr( NERR_UserNotFound ) + ': User name could not be found ';

  except

    on e : exception do
    begin
      GPCSErrorLine.RaiseException($805, E);
      sMsgError := e.message ;
    end ;

  end ;

  if sMsgError <> '' then
  begin
    result := FALSE ;
    HandleStatusError( sMsgError );
  end ;


end;
{===============================================================================
  Class        TNetManager
  Method       GetGlobalGroups
  Description  Return a string with global groups
  Params       ServerName : a string with the server name
  Result       a string with global groups separate by comma
________________________________________________________________________________}
function TNetManager.GetGlobalGroups(
  const ServerName: WideString): WideString;
begin

  try
    ServerForm.UserMan.MachineName := Trim( ServerName ) ;
    result := ServerForm.UserMan.GlobalGroups.CommaText ;
    FStatus := nmsOk ;

  except

    on e : exception do
    begin
      GPCSErrorLine.RaiseException($806, E);
      result := '' ;
      HandleStatusError( e.message );
    end ;

  end ;
end;
{===============================================================================
  Class        TNetManager
  Method       GetLocalGroups
  Description  Return a string with local groups
  Params       ServerName : a string with the server name
  Result       a string with local groups separate by comma
________________________________________________________________________________}
function TNetManager.GetLocalGroups(
  const ServerName: WideString): WideString;
begin
  try

    ServerForm.UserMan.MachineName := Trim( ServerName ) ;
    result := ServerForm.UserMan.LocalGroups.CommaText ;
    FStatus := nmsOk ;

  except

    on e : exception do
    begin
      GPCSErrorLine.RaiseException($807, E);
      result := '';
      HandleStatusError( e.message );
    end;

  end ;
end;
{===============================================================================
  Class        TNetManager
  Method       GetUsers
  Description  Return a string with users in a specific server
  Params       ServerName : a string with the server name
  Result       a string with users
________________________________________________________________________________}
function TNetManager.GetUsers( Const ServerName: WideString): WideString;
begin
  try

    ServerForm.UserMan.MachineName := Trim( ServerName ) ;
    result := ServerForm.UserMan.Users.CommaText ;
    FStatus := nmsOk ;

  except

    on e : exception do
    begin
      GPCSErrorLine.RaiseException($808, E);
      result := '' ;
      HandleStatusError( e.message );
    end ;

  end ;
end;
{===============================================================================
  Class        TNetManager
  Method       GetUser
  Description  Return a INetUser object with information of the user
  Params       ServerName : a string with the server name
               UserName   : a string of the user to get information from
  Result       a InetUser object
________________________________________________________________________________}
function TNetManager.GetUser(const ServerName,
  UserName: WideString): INetUser;
begin
  try

    FGetUser := TNetUser.Create As INetUser;
    FGetUser.SetUser(ServerName,UserName);
    Result := FGetUser;
    FStatus := nmsOk ;

  except

    on e : exception do
    begin
      GPCSErrorLine.RaiseException($809, E);
      HandleStatusError( e.message );
    end ;

  end ;
end;
{===============================================================================
  Class        TNetManager
  Method       Get_Visible
  Description  Property of the server to know if it is visible.
  Params       None
  Result       a boolean of server visible
________________________________________________________________________________}
function TNetManager.Get_Visible: WordBool;
safecall;
begin
  result := ServerForm.Visible  ;
end ;
{===============================================================================
  Class        TNetManager
  Method       Set_Visible
  Description  Set visible property of the server.
  Params       a boolean value of visible
  Result       None
________________________________________________________________________________}
procedure TNetManager.Set_Visible(Value: WordBool);
//var
//FormIndex : integer ;
begin
  if ServerForm.Visible <> value then
  begin
    ServerForm.Visible := Value ;
    ServerForm.LocalRadioButtonClick(nil);// Actualiz the information in the main form
  end ;
end;
{===============================================================================
  Class        TNetManager
  Method       GetServers
  Description  Get a string with server names
  Params       None
  Result       a string with server names
________________________________________________________________________________}
function TNetManager.GetServers: WideString;
var
  ServersStringList : TStringList ;
begin
  ServersStringList := TStringList.Create ;
  ServerForm.LocalRadioButtonClick(nil);// Actualiz the information in the main form
  Try
    ServersStringList := ServerForm.UserMan.GetServers('') ;
    Result := ServersStringList.CommaText ;
  finally
    ServersStringList.Free ;
  end ;
end;

function TNetManager.Get_Status: NetManagerStatus;
begin
  Result := FStatus ;
end;
{===============================================================================
  Class        TNetManager
  Method       GetPDC
  Description  Determines the server name of the Primary Domain Controler .
  Result       A string with the Primary Domain Controler.
________________________________________________________________________________}

function TNetManager.GetPDC: WideString;
var
//  temp    : ARRAY[0..255] OF WideChar;
  tempStr : LPCWSTR;
  retVal  : LPBYTE;
begin


   result:='';
   try

      if NetGetDCName(nil,nil,retVal) = NERR_Success then
      begin
         tempStr:=@retVal^;
         result:=WideChartoString(tempStr);
         NetApiBufferFree(retVal);
         FStatus := nmsOk ;
      end ;

   except

       on e : exception do
       begin
         GPCSErrorLine.RaiseException($809, E);
         HandleStatusError( e.message );
       end ;
   end ;

end;

function TNetManager.ChangePassword(const Servername, UserName,
  oldPassword, NewPassword: WideString): WordBool;
var
  wServerName, wUserName, wOldPassword, wNewPassword : WideString;
begin

   wServerName  := ServerName  ;
   wUserName    := UserName    ;
   wOldPassword := OldPassword ;
   wNewPassword := NewPassword ;

   try

      result := ( NetUserChangePassword ( PWideChar (wServerName),
                                          PWideChar (wUserName),
                                          PWideChar (woldPassword),
                                          PWideChar (wNewPassword)
                                        )
                  =  NERR_Success );

   except

      on e : exception do
      begin

         GPCSErrorLine.RaiseException($864, E);
         HandleStatusError( e.message );

      end ;

   end ;



end;

initialization
  //AutoObjectFactory :=
   TAutoObjectFactory.Create(ComServer, TNetManager, Class_NetManager, ciMultiInstance) As TTypedComObjectFactory;
//  AutoObjectFactory.ClassInfo.GetDocumentation(
end.
