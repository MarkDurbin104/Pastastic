unit Umanager_TLB;

{ This file contains pascal declarations imported from a type library.
  This file will be written during each import or refresh of the type
  library editor.  Changes to this file will be discarded during the
  refresh process. }

{ Umanager Library }
{ Version 1.0 }

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

const
  LIBID_Umanager: TGUID = '{844A0F31-B1E7-11D2-8AD9-00902707DA0F}';

const

{ NetManagerStatus }

  nmsOk = 0;
  nmsUndefinedError = 1;
  nmsAccessDenied = 2;
  nmsUserExists = 3;
  nmsGroupExists = 4;
  nmsInvalidComputer = 5;
  nmsResourceExit = 6;
  nmsOprtnNoAllowInGroup = 7;
  nmsNotPrimary = 8;
  nmsRemoteOnly = 9;
  nmsNetworkError = 10;
  nmsGroupNoFound = 11;
  nmsUserNoFound = 12;
  nmsResourceNoFound = 13;
  nmsPasswordTooShort = 14;
  nmsPasswordTooRecent = 15;

const

{ Component class GUIDs }
  Class_NetUser: TGUID = '{7C2581A3-B216-11D2-8ADA-00902707DA0F}';
  Class_NetManager: TGUID = '{7C2581A5-B216-11D2-8ADA-00902707DA0F}';

type

{ Forward declarations: Interfaces }
  INetUser = interface;
  INetUserDisp = dispinterface;
  INetManager = interface;
  INetManagerDisp = dispinterface;

{ Forward declarations: CoClasses }
  NetUser = INetUser;
  NetManager = INetManager;

{ Forward declarations: Enums }
  NetManagerStatus = TOleEnum;

{ Dispatch interface for NetUser Object }

  INetUser = interface(IDispatch)
    ['{7C2581A2-B216-11D2-8ADA-00902707DA0F}']
    function Get_UserName: WideString; safecall;
    function Get_ServerName: WideString; safecall;
    function Get_CannotChangePassword: WordBool; safecall;
    procedure Set_CannotChangePassword(Value: WordBool); safecall;
    function Get_FullName: WideString; safecall;
    procedure Set_FullName(const Value: WideString); safecall;
    function Get_Comment: WideString; safecall;
    procedure Set_Comment(const Value: WideString); safecall;
    procedure Set_Password(const Value: WideString); safecall;
    function Get_Lockout: WordBool; safecall;
    procedure Set_Lockout(Value: WordBool); safecall;
    function Get_PasswordNeverExpired: WordBool; safecall;
    procedure Set_PasswordNeverExpired(Value: WordBool); safecall;
    function Get_AccountDisable: WordBool; safecall;
    procedure Set_AccountDisable(Value: WordBool); safecall;
    function Get_PasswordNotRequired: WordBool; safecall;
    procedure Set_PasswordNotRequired(Value: WordBool); safecall;
    function Get_HomeDirRequired: WordBool; safecall;
    procedure Set_HomeDirRequired(Value: WordBool); safecall;
    function Get_LogonCount: Integer; safecall;
    function Get_WrongLogonCount: Integer; safecall;
    function Get_LastLogon: TDateTime; safecall;
    function Get_LastLogOff: TDateTime; safecall;
    function Get_HomeDir: WideString; safecall;
    procedure Set_HomeDir(const Value: WideString); safecall;
    function Get_WorkStation: WideString; safecall;
    procedure Set_WorkStation(const Value: WideString); safecall;
    function Get_Script: WordBool; safecall;
    function Get_Domain: WideString; safecall;
    function Get_MemberOfGlobal: WideString; safecall;
    procedure Set_MemberOfGlobal(const Value: WideString); safecall;
    function Get_MemberOfLocal: WideString; safecall;
    procedure Set_MemberOfLocal(const Value: WideString); safecall;
    procedure SetUser(const ServerName, UserName: WideString); safecall;
    procedure GetUserInformation; safecall;
    function Get_Status: Integer; safecall;
    property UserName: WideString read Get_UserName;
    property ServerName: WideString read Get_ServerName;
    property CannotChangePassword: WordBool read Get_CannotChangePassword write Set_CannotChangePassword;
    property FullName: WideString read Get_FullName write Set_FullName;
    property Comment: WideString read Get_Comment write Set_Comment;
    property Password: WideString write Set_Password;
    property Lockout: WordBool read Get_Lockout write Set_Lockout;
    property PasswordNeverExpired: WordBool read Get_PasswordNeverExpired write Set_PasswordNeverExpired;
    property AccountDisable: WordBool read Get_AccountDisable write Set_AccountDisable;
    property PasswordNotRequired: WordBool read Get_PasswordNotRequired write Set_PasswordNotRequired;
    property HomeDirRequired: WordBool read Get_HomeDirRequired write Set_HomeDirRequired;
    property LogonCount: Integer read Get_LogonCount;
    property WrongLogonCount: Integer read Get_WrongLogonCount;
    property LastLogon: TDateTime read Get_LastLogon;
    property LastLogOff: TDateTime read Get_LastLogOff;
    property HomeDir: WideString read Get_HomeDir write Set_HomeDir;
    property WorkStation: WideString read Get_WorkStation write Set_WorkStation;
    property Script: WordBool read Get_Script;
    property Domain: WideString read Get_Domain;
    property MemberOfGlobal: WideString read Get_MemberOfGlobal write Set_MemberOfGlobal;
    property MemberOfLocal: WideString read Get_MemberOfLocal write Set_MemberOfLocal;
    property Status: Integer read Get_Status;
  end;

{ DispInterface declaration for Dual Interface INetUser }

  INetUserDisp = dispinterface
    ['{7C2581A2-B216-11D2-8ADA-00902707DA0F}']
    property UserName: WideString readonly dispid 24;
    property ServerName: WideString readonly dispid 26;
    property CannotChangePassword: WordBool dispid 6;
    property FullName: WideString dispid 7;
    property Comment: WideString dispid 14;
    property Password: WideString writeonly dispid 15;
    property Lockout: WordBool dispid 1;
    property PasswordNeverExpired: WordBool dispid 2;
    property AccountDisable: WordBool dispid 3;
    property PasswordNotRequired: WordBool dispid 4;
    property HomeDirRequired: WordBool dispid 5;
    property LogonCount: Integer readonly dispid 8;
    property WrongLogonCount: Integer readonly dispid 9;
    property LastLogon: TDateTime readonly dispid 10;
    property LastLogOff: TDateTime readonly dispid 11;
    property HomeDir: WideString dispid 13;
    property WorkStation: WideString dispid 16;
    property Script: WordBool readonly dispid 19;
    property Domain: WideString readonly dispid 20;
    property MemberOfGlobal: WideString dispid 27;
    property MemberOfLocal: WideString dispid 21;
    procedure SetUser(const ServerName, UserName: WideString); dispid 23;
    procedure GetUserInformation; dispid 25;
    property Status: Integer readonly dispid 12;
  end;

{ Dispatch interface for NetManager Object }

  INetManager = interface(IDispatch)
    ['{7C2581A4-B216-11D2-8ADA-00902707DA0F}']
    function AddUser(const ServerName, UserName: WideString): WordBool; safecall;
    function AddLocalGroup(const ServerName, GroupName: WideString): WordBool; safecall;
    function AddGlobalGroup(const ServerName, GroupName: WideString): WordBool; safecall;
    function DeleteUser(const ServerName, UserName: WideString): WordBool; safecall;
    function DeleteLocalGroup(const ServerName, GroupName: WideString): WordBool; safecall;
    function DeleteGlobalGroup(const ServerName, GroupName: WideString): WordBool; safecall;
    function GetUsers(const ServerName: WideString): WideString; safecall;
    function GetLocalGroups(const ServerName: WideString): WideString; safecall;
    function GetGlobalGroups(const ServerName: WideString): WideString; safecall;
    function GetUser(const ServerName, UserName: WideString): INetUser; safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function GetServers: WideString; safecall;
    function Get_Status: NetManagerStatus; safecall;
    function GetPDC: WideString; safecall;
    function ChangePassword(const ServerName, UserName, oldPassword, NewPassword: WideString): WordBool; safecall;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Status: NetManagerStatus read Get_Status;
  end;

{ DispInterface declaration for Dual Interface INetManager }

  INetManagerDisp = dispinterface
    ['{7C2581A4-B216-11D2-8ADA-00902707DA0F}']
    function AddUser(const ServerName, UserName: WideString): WordBool; dispid 1;
    function AddLocalGroup(const ServerName, GroupName: WideString): WordBool; dispid 2;
    function AddGlobalGroup(const ServerName, GroupName: WideString): WordBool; dispid 3;
    function DeleteUser(const ServerName, UserName: WideString): WordBool; dispid 5;
    function DeleteLocalGroup(const ServerName, GroupName: WideString): WordBool; dispid 6;
    function DeleteGlobalGroup(const ServerName, GroupName: WideString): WordBool; dispid 7;
    function GetUsers(const ServerName: WideString): WideString; dispid 8;
    function GetLocalGroups(const ServerName: WideString): WideString; dispid 9;
    function GetGlobalGroups(const ServerName: WideString): WideString; dispid 10;
    function GetUser(const ServerName, UserName: WideString): INetUser; dispid 12;
    property Visible: WordBool dispid 4;
    function GetServers: WideString; dispid 11;
    property Status: NetManagerStatus readonly dispid 13;
    function GetPDC: WideString; dispid 14;
    function ChangePassword(const ServerName, UserName, oldPassword, NewPassword: WideString): WordBool; dispid 15;
  end;

{ GPCS NetUser }

  CoNetUser = class
    class function Create: INetUser;
    class function CreateRemote(const MachineName: string): INetUser;
  end;

{ GPCS NetManager }

  CoNetManager = class
    class function Create: INetManager;
    class function CreateRemote(const MachineName: string): INetManager;
  end;



implementation

uses ComObj;

class function CoNetUser.Create: INetUser;
begin
  Result := CreateComObject(Class_NetUser) as INetUser;
end;

class function CoNetUser.CreateRemote(const MachineName: string): INetUser;
begin
  Result := CreateRemoteComObject(MachineName, Class_NetUser) as INetUser;
end;

class function CoNetManager.Create: INetManager;
begin
  Result := CreateComObject(Class_NetManager) as INetManager;
end;

class function CoNetManager.CreateRemote(const MachineName: string): INetManager;
begin
  Result := CreateRemoteComObject(MachineName, Class_NetManager) as INetManager;
end;


end.
