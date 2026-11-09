unit UserManager_TLB;

{ This file contains pascal declarations imported from a type library.
  This file will be written during each import or refresh of the type
  library editor.  Changes to this file will be discarded during the
  refresh process. }

{ UserManager Library }
{ Version 1.0 }

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

const
  LIBID_UserManager: TGUID = '{8FFD1201-6B8A-47F8-9589-FED4DF8501C2}';

const

{ Component class GUIDs }
  Class_NetUser: TGUID = '{223F920E-4940-4CDE-BA00-44F625178992}';

type

{ Forward declarations: Interfaces }
  INetUser = interface;
  INetUserDisp = dispinterface;

{ Forward declarations: CoClasses }
  NetUser = INetUser;

  INetUser = interface(IDispatch)
    ['{0A12E5D2-310F-45D5-825B-8AF9974C818E}']
    function GetPDC: WideString; safecall;
    function GetLocalGroups(const wServer: WideString): WideString; safecall;
    function GetGlobalGroups(const wServer: WideString): WideString; safecall;
    function GetUsers(const wServerName: WideString): WideString; safecall;
    function AddUser(const wServer, wUser, wDescription, wPassword: WideString): WordBool; safecall;
    function ChangePassword(const wServerName, wUserName, wOldPassword, wNewPassword: WideString): WordBool; safecall;
    function GetComment(const wServer, wUser: WideString): WideString; safecall;
    function GetMemberLocalGroups(const wServer, wUser: WideString): WideString; safecall;
    function GetMemberGlobalGroups(const wServer, wUser: WideString): WideString; safecall;
    procedure AddMemberLocalGroups(const wServer, wUser, wGroups: WideString); safecall;
    procedure AddMemberGlobalGroups(const wServer, wUser, Groups: WideString); safecall;
    procedure SetPassword(const wServer, wUser, wPassword: WideString); safecall;
    procedure AddLocalGroup(const wServer, wGroup: WideString); safecall;
    function GetFullName(const wServer, wUser: WideString): WideString; safecall;
    procedure SetComment(const wServer, wUser, wComment: WideString); safecall;
    procedure SetMemberLocalGroups(const wServer, wUser, wGroups: WideString); safecall;
    procedure AddOrUpdateUser(const wServer, wUser, wFullName, wComment, wPassword, wGroups: WideString); safecall;
    function UserExists(const wServer, wUser: WideString): WordBool; safecall;
    procedure SetFullName(const wServer, wUser, wFullName: WideString); safecall;
    procedure DelMemberLocalGroup(const wServer, wGroup, wUser: WideString); safecall;
  end;

{ DispInterface declaration for Dual Interface INetUser }

  INetUserDisp = dispinterface
    ['{0A12E5D2-310F-45D5-825B-8AF9974C818E}']
    function GetPDC: WideString; dispid 1;
    function GetLocalGroups(const wServer: WideString): WideString; dispid 2;
    function GetGlobalGroups(const wServer: WideString): WideString; dispid 3;
    function GetUsers(const wServerName: WideString): WideString; dispid 4;
    function AddUser(const wServer, wUser, wDescription, wPassword: WideString): WordBool; dispid 5;
    function ChangePassword(const wServerName, wUserName, wOldPassword, wNewPassword: WideString): WordBool; dispid 6;
    function GetComment(const wServer, wUser: WideString): WideString; dispid 7;
    function GetMemberLocalGroups(const wServer, wUser: WideString): WideString; dispid 8;
    function GetMemberGlobalGroups(const wServer, wUser: WideString): WideString; dispid 9;
    procedure AddMemberLocalGroups(const wServer, wUser, wGroups: WideString); dispid 10;
    procedure AddMemberGlobalGroups(const wServer, wUser, Groups: WideString); dispid 11;
    procedure SetPassword(const wServer, wUser, wPassword: WideString); dispid 12;
    procedure AddLocalGroup(const wServer, wGroup: WideString); dispid 13;
    function GetFullName(const wServer, wUser: WideString): WideString; dispid 14;
    procedure SetComment(const wServer, wUser, wComment: WideString); dispid 15;
    procedure SetMemberLocalGroups(const wServer, wUser, wGroups: WideString); dispid 16;
    procedure AddOrUpdateUser(const wServer, wUser, wFullName, wComment, wPassword, wGroups: WideString); dispid 17;
    function UserExists(const wServer, wUser: WideString): WordBool; dispid 18;
    procedure SetFullName(const wServer, wUser, wFullName: WideString); dispid 19;
    procedure DelMemberLocalGroup(const wServer, wGroup, wUser: WideString); dispid 20;
  end;

{ GPCS NetUser }

  CoNetUser = class
    class function Create: INetUser;
    class function CreateRemote(const MachineName: string): INetUser;
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


end.
