(*============================================================================*
 | unit NetServer                                                             |
 |                                                                            |
 | Encapsulates NT Lanman Server                                              |
 |                                                                            |
 | TNetServer public properties:                                              |
 |   DomainName : string     ro       Returns the domain name for the server. |
 |   ServerType : string     ro       Returns the server type flags.          |
 |                                                                            |
 | TNetServer published properties:                                           |
 |   ServerName : string     rw       Contains the name of the server to use. |
 |                                                                            |
 | TNetServer public methods:                                                 |
 |   procedure SetNameToAny           Prime the component to use the first DC |
 |                                    it finds.                               |
 |                                                                            |
 |   procedure SetNameToPDC           Prime the component to use the PDC.     |
 |                                                                            |
 |   procedure GetServers             Enumerate servers or domains            |
 |                                                                            |
 |   procedure GetUsers               Enumerate user IDs                      |
 |                                                                            |
 |   procedure GetUsersDetails        Enumerate user IDs and other details    |
 |                                                                            |
 |   procedure CreateUserObjects      Create a list of TNetUser objects for   |
 |                                    each user.                              |
 |                                                                            |
 |   procedure GetLocalGroups         Enumerate local group names             |
 |                                                                            |
 |   procedure GetLocalGroupsDetails  Enumerate local group names & other     |
 |                                    details.                                |
 |                                                                            |
 |   procedure GetGlobalGroups        Enumerate global group names            |
 |                                                                            |
 |   procedure GetGlobalGroupsDetails Enumerate global group names & other    |
 |                                    details.                                |
 |                                                                            |
 |   procedure NetLogonControl        Perform special control function on a   |
 |                                    server.                                 |
 |                                                                            |
 |   procedure Synchronize            Synchronize a domain's controllers.     |
 |                                                                            |
 |                                                                            |
 | Programmed by Colin Wilson - colin@wilsonc.demon.co.uk                     |
 |                                                                            |
 | Version  Date      By    Description                                       |
 | -------  --------  ----  ------------------------------------------------- |
 | 1.0      May 1997  CPWW  Original                                          |
 | 1.5      May 1998  CPWW  Increased functionality:                          |
 |                            Enumerated type for Account Type filters.       |
 |                                                                            |
 |                            New GetUsersDetails and CreateUserObjects       |
 |                            functions to get more user details in one hit.  |
 |                                                                            |
 |                            New GetxxxGroupDetails function to get more     |
 |                            group details in one hit.                       |
 |                                                                            |
 |                            GetGroups renamed to GetGlobalGroups            |
 |                                                                            |
 |                            'Synchronize' function added to sync. the       |
 |                            domain controllers.                             |
 *============================================================================*)

unit NetServer;

interface

uses
  Windows, SysUtils, Classes;

type
  //---------------------------------------------------------------------------
  // TServerInfoFlags are used to record which bits of server
  // information have been cached.  Only the Domain Name and
  // Server Type are handled so far...

  LPCWSTR = PWideChar;
  LPBYTE = ^Byte;
  PPointer = ^Pointer;


  TServerInfo = (svrDomainName, svrServerType);
  TServerInfoFlags = set of TServerInfo;


  //---------------------------------------------------------------------------
  // TUserAccountFilters are used to filter user enumeration in GetUsers,
  // GetUsersDetails, etc.
  TUserAccountType = (
    fltrDuplicate,        // Enumerates local user account data on a domain controller.
    fltrNormal,           // Enumerates global user account data on a computer.
    fltrProxy,            // ???
    fltrInterdomainTrust, // Enumerates domain trust account data on a domain controller.
    fltrWorkstationTrust, // Enumerates workstation or member server account data on a domain controller.
    fltrServerTrust       // Enumerates domain controller account data on a domain controller.
  );
  TUserAccountFilter = set of TUserAccountType;

  TServerAccountType = (
    svTypeWorkstation,      // All Net workstations
    svTypeServer,           // All Net servers
    svTypeSQLServer,        // Any server running with Microsoft SQL Server
    svTypeDomainCtrl,       // Primary domain controller

    svTypeDomainBakCtrl,    // Backup domain controller
    svTypeTimeSource,       // Server running the Timesource service
    svTypeAFP,              // Apple File Protocol servers
    svTypeNovell,           // Novell servers

    svTypeDomainMember,     // LAN Manager 2.x Domain Member
    svTypePrint,            // Server sharing print queue
    svTypeDialin,           // Server running dial-in service
    svTypeXenixServer,      // Xenix Server

    svTypeNT,               // Windows NT (either Workstation or Server)
    svTypeWFW,              // Server running Windows for Workgroups
    svTypeMFPN,             // Microsoft File and Print for Netware
    svTypeServerNT,         // Windows NT Non-DC server

    svTypePotentialBrowser, // Server that can run the Browser service
    svTypeBackupBrowser,    // Server running a Browser service as backup
    svTypeMasterBrowser,    // Server running the master Browser service
    svTypeDomainMaster,     // Server running the domain master Browser

    svTypeServerOSF,        // OSF Server??
    svTypeServerVMS,        // VMS Server
    svTypeWindows,          // Windows95 and above
    svTypeDFS,              // Root of a DFS tree

    svTypeAlternateXport,   // return list for alternate transport
    svTypeLocalListOnly,    // Return local list only
    svTypeDomainEnum,       // Enumerate primary domains
    svTypeAll
  );
  TServerAccountFilter = set of TServerAccountType;

  TNetServer = class(TComponent)
  private
    flags : TServerInfoFlags;

    fServerName : string;

    fDomainName : string;
    fServerType : TServerAccountFilter;

    function GetDomainName : string;
    function GetServerType : TServerAccountFilter;

    procedure SetServerName (const value : string);


  protected

  public
    procedure SetNameToAny (const domainName : string);
    procedure SetNameToPDC (const domainName : string);
    function  GetPDC(domName:String ):string;
    procedure GetServers (filter : TServerAccountFilter; const domain : string; list : TStrings);

    function GetUsers (const ServerName : string ; filter : TUserAccountFilter) :string;
    procedure GetUsersDetails (filter : TUserAccountFilter; list : TStrings);
    procedure CreateUserObjects (owner : TComponent; filter : TUserAccountFilter; list : TList);

    function GetLocalGroups( wServer:WideString ) : String;
//    procedure GetLocalGroupsDetails (list : TStrings);
    function GetGlobalGroups (wServer:WideString):String ;
    procedure GetGlobalGroupsDetails (list : TStrings);
    procedure NetLogonControl (fn : Integer);
    procedure Synchronize;

    function ChangePassword(const wServername, wUserName,woldPassword, wNewPassword: WideString): boolean;

    property DomainName : string read GetDomainName;
    property ServerType : TServerAccountFilter read GetServerType;

  published
    property ServerName : string read fServerName Write SetServerName;
  end;

function WStrNew (s : PWideChar) : PWideChar;

procedure Register;

implementation

uses lmglobal, lmaccess, lmserver, unitNTException, NetUser;

var
  NIL_HANDLE : Integer absolute 0;


(*----------------------------------------------------------------------------*
 | function WStrNew (...) : PWideChar;                                        |
 |                                                                            |
 | Allocates a new copy of a PWideChar string                                 |
 |                                                                            |
 | Parameters                                                                 |
 |   s : PWideChar         The string to copy                                 |
 |                                                                            |
 | The function returns the copy of the string.                               |
 *----------------------------------------------------------------------------*)
function WStrNew (s : PWideChar) : PWideChar;
begin
  GetMem (result, (lstrlenW (s) + 1) * sizeof (WideChar));
  lstrcpyW (result, s);
end;


(*----------------------------------------------------------------------------*
 | function UserAccountFilterToDWORD (...) : DWORD;                           |
 |                                                                            |
 | Returns the DWORD value for a user enum filter set                         |
 |                                                                            |
 | Parameters                                                                 |
 |   filter : TUserAccountFilter                                              |
 |                                                                            |
 | The function returns the DWORD value of the filter                         |
 *----------------------------------------------------------------------------*)
function UserAccountFilterToDWORD (filter : TUserAccountFilter) : DWORD;
begin
  result := 0;
  if fltrDuplicate in filter then result := result or FILTER_TEMP_DUPLICATE_ACCOUNT;
  if fltrNormal in filter then result := result or FILTER_NORMAL_ACCOUNT;
  if fltrProxy in filter then result := result or FILTER_PROXY_ACCOUNT;
  if fltrInterdomainTrust in filter then result := result or FILTER_INTERDOMAIN_TRUST_ACCOUNT;
  if fltrWorkstationTrust in filter then result := result or FILTER_WORKSTATION_TRUST_ACCOUNT;
  if fltrServerTrust in filter then result := result or FILTER_SERVER_TRUST_ACCOUNT
end;


(*----------------------------------------------------------------------------*
 | function ServerAccountFilterToDWORD (...) : DWORD;                         |
 |                                                                            |
 | Returns the DWORD value for a server enum filter set                       |
 |                                                                            |
 | Parameters                                                                 |
 |   filter : TServerAccountFilter                                            |
 |                                                                            |
 | The function returns the DWORD value of the filter                         |
 *----------------------------------------------------------------------------*)
function ServerAccountFilterToDWORD (filter : TServerAccountFilter) : DWORD;
begin
  if svTypeAll in filter then
    result := SV_TYPE_ALL
  else
  begin
    result := 0;
    if svTypeWorkstation in filter then result := result or SV_TYPE_WORKSTATION;
    if svTypeServer in filter then result := result or SV_TYPE_SERVER;
    if svTypeSQLServer in filter then result := result or SV_TYPE_SQLSERVER;
    if svTypeDomainCtrl in filter then result := result or SV_TYPE_DOMAIN_CTRL;

    if svTypeDomainBakCtrl in filter then result := result or SV_TYPE_DOMAIN_BAKCTRL;
    if svTypeTimeSource in filter then result := result or SV_TYPE_TIME_SOURCE;
    if svTypeAFP in filter then result := result or SV_TYPE_AFP;
    if svTypeNovell in filter then result := result or SV_TYPE_NOVELL;

    if svTypeDomainMember in filter then result := result or SV_TYPE_DOMAIN_MEMBER;
    if svTypePrint in filter then result := result or SV_TYPE_PRINTQ_SERVER;
    if svTypeDialin in filter then result := result or SV_TYPE_DIALIN_SERVER;
    if svTypeXenixServer in filter then result := result or SV_TYPE_XENIX_SERVER;

    if svTypeNT in filter then result := result or SV_TYPE_NT;
    if svTypeWFW in filter then result := result or SV_TYPE_WFW;
    if svTypeMFPN in filter then result := result or SV_TYPE_SERVER_MFPN;
    if svTypeServerNT in filter then result := result or SV_TYPE_SERVER_NT;

    if svTypePotentialBrowser in filter then result := result or SV_TYPE_POTENTIAL_BROWSER;
    if svTypeBackupBrowser in filter then result := result or SV_TYPE_BACKUP_BROWSER;
    if svTypeMasterBrowser in filter then result := result or SV_TYPE_MASTER_BROWSER;
    if svTypeDomainMaster in filter then result := result or SV_TYPE_DOMAIN_MASTER;

    if svTypeServerOSF in filter then result := result or SV_TYPE_SERVER_OSF;
    if svTypeServerVMS in filter then result := result or SV_TYPE_SERVER_VMS;
    if svTypeWindows in filter then result := result or SV_TYPE_WINDOWS;
    if svTypeDFS in filter then result := result or SV_TYPE_DFS;

    if svTypeAlternateXport in filter then result := result or SV_TYPE_ALTERNATE_XPORT;
    if svTypeLocalListOnly in filter then result := result or SV_TYPE_LOCAL_LIST_ONLY;
    if svTypeDomainEnum in filter then result := result or SV_TYPE_DOMAIN_ENUM
  end
end;


(*----------------------------------------------------------------------------*
 | function DWORDToServerAccountFilter (...) : TServerAccountFilter;          |
 |                                                                            |
 | Returns the TServerAccountFilter value for a server type DWORD             |
 |                                                                            |
 | Parameters                                                                 |
 |   serverType : DWORD                                                       |
 |                                                                            |
 | The function returns the TServerAccountFilter value for a server type      |
 | DWORD                                                                      |
 *----------------------------------------------------------------------------*)
function DWORDToServerAccountFilter (serverType : DWORD) : TServerAccountFilter;
begin
  if serverType = SV_TYPE_ALL then
    result := [svTypeAll]
  else
  begin
    result := [];
    if (serverType and SV_TYPE_WORKSTATION) <> 0 then result := result + [svTypeWorkstation];
    if (serverType and SV_TYPE_SERVER) <> 0 then result := result + [svTypeServer];
    if (serverType and SV_TYPE_SQLSERVER) <> 0 then result := result + [svTypeSQLServer];
    if (serverType and SV_TYPE_DOMAIN_CTRL) <> 0 then result := result + [svTypeDomainCtrl];

    if (serverType and SV_TYPE_DOMAIN_BAKCTRL) <> 0 then result := result + [svTypeDomainBakCtrl];
    if (serverType and SV_TYPE_TIME_SOURCE) <> 0 then result := result + [svTypeTimeSource];
    if (serverType and SV_TYPE_AFP) <> 0 then result := result + [svTypeAFP];
    if (serverType and SV_TYPE_NOVELL) <> 0 then result := result + [svTypeNovell];

    if (serverType and SV_TYPE_DOMAIN_MEMBER) <> 0 then result := result + [svTypeDomainMember];
    if (serverType and SV_TYPE_PRINTQ_SERVER) <> 0 then result := result + [svTypePrint];
    if (serverType and SV_TYPE_DIALIN_SERVER) <> 0 then result := result + [svTypeDialin];
    if (serverType and SV_TYPE_XENIX_SERVER) <> 0 then result := result + [svTypeXenixServer];

    if (serverType and SV_TYPE_NT) <> 0 then result := result + [svTypeNT];
    if (serverType and SV_TYPE_WFW) <> 0 then result := result + [svTypeWFW];
    if (serverType and SV_TYPE_SERVER_MFPN) <> 0 then result := result + [svTypeMFPN];
    if (serverType and SV_TYPE_SERVER_NT) <> 0 then result := result + [svTypeServerNT];

    if (serverType and SV_TYPE_POTENTIAL_BROWSER) <> 0 then result := result + [svTypePotentialBrowser];
    if (serverType and SV_TYPE_BACKUP_BROWSER) <> 0 then result := result + [svTypeBackupBrowser];
    if (serverType and SV_TYPE_MASTER_BROWSER) <> 0 then result := result + [svTypeMasterBrowser];
    if (serverType and SV_TYPE_DOMAIN_MASTER) <> 0 then result := result + [svTypeDomainMaster];

    if (serverType and SV_TYPE_SERVER_OSF) <> 0 then result := result + [svTypeServerOSF];
    if (serverType and SV_TYPE_SERVER_VMS) <> 0 then result := result + [svTypeServerVMS];
    if (serverType and SV_TYPE_WINDOWS) <> 0 then result := result + [svTypeWindows];
    if (serverType and SV_TYPE_DFS) <> 0 then result := result + [svTypeDFS];

    if (serverType and SV_TYPE_ALTERNATE_XPORT) <> 0 then result := result + [svTypeAlternateXport];
    if (serverType and SV_TYPE_LOCAL_LIST_ONLY) <> 0 then result := result + [svTypeLocalListOnly];
    if (serverType and SV_TYPE_DOMAIN_ENUM) <> 0 then result := result + [svTypeDomainEnum];
  end
end;

(*----------------------------------------------------------------------------*
 | procedure TNetServer.SetNameToAny                                          |
 |                                                                            |
 | Sets the 'ServerName' property to the name of any Domain Controller (DC)   |
 | for the domain.  Use this after creating the TNetServer object, before     |
 | calling any of the other TNetServer methods.                               |
 |                                                                            |
 | Parameters                                                                 |
 |   const domainName : string           The name of the domain.  Pass an     |
 |                                       empty string to indicate the current |
 |                                       domain.                              |
 *----------------------------------------------------------------------------*)
procedure TNetServer.SetNameToAny (const domainName : string);
var
  wDomainName : WideString;
  buffer : pointer;
  rv : Integer;
begin
  wDomainName := domainName;
  rv := NetGetAnyDCName (Nil, PWideChar (wDomainName), buffer);

  if rv = NERR_Success then
    try
      ServerName := PWideChar (buffer);
    finally
      NetAPIBufferFree (buffer)
    end
  else
    raise ENTException.Create (rv);
end;


(*----------------------------------------------------------------------------*
 | procedure TNetServer.SetNameToPDC                                          |
 |                                                                            |
 | Sets the 'ServerName' property to the name of the Primary Domain           |
 | Controller (PDC) for the domain.  Use this after creating the TNetServer   |
 | object, before calling any other TNetServer method.                        |
 |                                                                            |
 | Parameters                                                                 |
 |   const domainName : string             The name of the domain to use.     |
 |                                         Pass an empty string to indiciate  |
 |                                         the current domain.                |
 *----------------------------------------------------------------------------*)
procedure TNetServer.SetNameToPDC (const domainName : string);
var
  wDomainName : WideString;
  buffer : pointer;
  rv : Integer;
begin
  wDomainName := domainName;
  rv := NetGetDCName (Nil, PWideChar (wDomainName), buffer);

  if rv = NERR_Success then
    try
      ServerName := PWideChar (buffer);
    finally
      NetAPIBufferFree (buffer)
    end
  else
    raise ENTException.Create (rv);
end;

(*----------------------------------------------------------------------------*
 | procedure TNetServer.GetServers ()                                         |
 |                                                                            |
 | Get a list of servers.  Specify [svTypeAll] for the filter to get a list   |
 | of all servers.  Specify [svTypeDomainEnum] to get a list of domains.      |
 |                                                                            |
 |                                                                            |
 | Parameters                                                                 |
 |   filter : TServerAccountFilter       Type of server to get                |
 |                                                                            |
 |   const domain : string               The domain to get servers for.  Use  |
 |                                       an empty string for the primary      |
 |                                       domain.                              |
 |                                                                            |
 |   list : TStrings                     Returns the list of servers.         |
 *----------------------------------------------------------------------------*)
procedure TNetServer.GetServers (filter : TServerAccountFilter; const domain : string; list : TStrings);
var
  wServerName : WideString;
  wDomain : WideString;
  pwDomain : PWideChar;
  rv : NetAPIStatus;
  p : PSERVER_INFO_100;
  buffer : pointer;
  i, entriesRead, totalEntries : Integer;

begin
  list.Clear;
  wServerName := ServerName;
  wDomain := domain;
  if domain = '' then
    pwDomain := Nil
  else
    pwDomain := PWideChar (wDomain);

  rv := NetServerEnum (PWideChar (wServerName), 100, buffer, MAX_PREFERRED_LENGTH,
                       entriesRead, totalEntries, ServerAccountFilterToDWORD (filter), pwDomain, NIL_HANDLE);
  if rv = NERR_Success then
    try
      p := PSERVER_INFO_100 (buffer);
      for i := 0 to entriesRead - 1 do
      begin
        list.AddObject (p^.sv100_name, TObject (p^.sv100_platform_id));
        Inc (p)
      end
    finally
      NetAPIBufferFree (buffer);
    end
  else
    raise ENTException.Create (rv);
end;

(*----------------------------------------------------------------------------*
 | procedure TNetServer.GetUsers                                              |
 |                                                                            |
 | Get a list of user IDs.  This is the quickest way to get a list of user    |
 | IDs from a server, but see GetUsersDetails and CreateUserObjects below     |
 | for ways of getting more details in one hit.                               |
 |                                                                            |
 | Parameters                                                                 |
 |   filter : TUserAccountFilters     The account filter to use.  An empty    |
 |                                    set enumerates all accounts.            |
 |                                                                            |
 *----------------------------------------------------------------------------*)
//procedure TNetServer.GetUsers (filter : TUserAccountFilter; list : TStrings);
function TNetServer.GetUsers(const ServerName : string ; filter : TUserAccountFilter ):string;
var
  wServerName : WideString;
  rv : NetAPIStatus;
  buffer : pointer;
  i, entriesRead, totalEntries : Integer;
  p : PUSER_INFO_0;
  List : TStringList ;
begin
  List := TStringList.Create ;
  wServerName := ServerName;
  rv := NetUserEnum (PWideChar (wServerName), 0, UserAccountFilterToDWORD (filter), buffer, MAX_PREFERRED_LENGTH,
                     entriesRead, totalEntries, NIL_HANDLE);
  if rv = NERR_Success then
    try
      p := PUSER_INFO_0 (buffer);
      for i := 0 to entriesRead - 1 do
      begin
        list.Add (p^.usri0_name);
        Inc (p)
      end
    finally
      NetAPIBufferFree (buffer)
    end
  else
    raise ENTException.Create (rv);
   result := List.CommaText ;
   List.Free ;
end;

(*----------------------------------------------------------------------------*
 | procedure TNetServer.GetUsersDetails                                       |
 |                                                                            |
 | Get a list of user IDs and related information.  each returned string      |
 | contains a nul-separated list of userid, fullname and comment, which is    |
 | sufficient to populate the initial user-manager user list.                 |
 |                                                                            |
 | Parameters                                                                 |
 |   filter : TUserAccountFilters     The account filter to use.  An empty    |
 |                                    set enumerates all accounts.            |
 |                                                                            |
 |   list : TStrings                  Returns the list of user details        |
 *----------------------------------------------------------------------------*)
procedure TNetServer.GetUsersDetails (filter : TUserAccountFilter;  list : TStrings);
var
  wServerName : WideString;
  rv : NetAPIStatus;
  buffer : pointer;
  i, entriesRead, totalEntries : Integer;
  p : PUSER_INFO_20;
  st : string;
begin
  list.Clear;
  wServerName := ServerName;
  rv := NetUserEnum (PWideChar (wServerName), 20, UserAccountFilterToDWORD (filter), buffer, MAX_PREFERRED_LENGTH,
                     entriesRead, totalEntries, NIL_HANDLE);
  if rv = NERR_Success then
    try
      p := PUSER_INFO_20 (buffer);
      for i := 0 to entriesRead - 1 do
      begin
        st := p^.usri20_name;
        st := st + #0;
        st := st + p^.usri20_full_name + #0 + p^.usri20_comment;
        list.Add (st);
        Inc (p)
      end
    finally
      NetAPIBufferFree (buffer)
    end
  else
    raise ENTException.Create (rv)
end;

(*----------------------------------------------------------------------------*
 | procedure TNetServer.CreateUserObjects                                     |
 |                                                                            |
 | Get a list containing TNetUser objects, with all their details.  This is   |
 | the slowest way of getting a list of users, but it gets all the details    |
 | in one hit.  If you pass 'nil' as the 'owner', be sure to free each        |
 | TNetUser in the list once you've finished with them.                       |
 |                                                                            |
 | Parameters                                                                 |
 |   owner : TComponent       Owner component for the TNetUser objects which  |
 |                            get created by this call.                       |
 |                                                                            |
 |   filter : TUserAccountFilters     The account filter to use.  An empty    |
 |                                    set enumerates all accounts.            |
 |                                                                            |
 |   list : TList                     Returns the list of TNetUser objects    |
 *----------------------------------------------------------------------------*)
procedure TNetServer.CreateUserObjects (owner : TComponent; filter : TUserAccountFilter; list : TList);
var
  wServerName : WideString;
  rv : NetAPIStatus;
  buffer : pointer;
  i, entriesRead, totalEntries : Integer;
  p : PUSER_INFO_3;
begin
  list.Clear;
  wServerName := ServerName;
  rv := NetUserEnum (PWideChar (wServerName), 3, UserAccountFilterToDWORD (filter), buffer, MAX_PREFERRED_LENGTH,
                     entriesRead, totalEntries, NIL_HANDLE);
  if rv = NERR_Success then
    try
      p := PUSER_INFO_3 (buffer);
      for i := 0 to entriesRead - 1 do
      begin
        list.Add (TNetUser.CreateFrom (owner, self, p));
        Inc (p)
      end
    finally
      NetAPIBufferFree (buffer)
    end
  else
    raise ENTException.Create (rv)
end;

(*----------------------------------------------------------------------------*
 | procedure TNetServer.GetGlobalGroups                                       |
 |                                                                            |
 | Gets a list of Global Group names.                                         |
 |                                                                            |
 | Parameters                                                                 |
 |  list : TStrings           Returns the list of global groups.              |
 *----------------------------------------------------------------------------*)
function TNetServer.GetGlobalGroups (wServer:WideString):String;
var
//  wServer : WideString;
  rv, i, entriesRead, totalEntries : Integer;
  buffer : pointer;
  p : PGROUP_INFO_0;
  List:TstringList;
begin
  List:=TstringList.Create;
  list.Clear;
  result:='';
  rv := NetGroupEnum (PWideChar (wServer), 0, buffer, MAX_PREFERRED_LENGTH,
                      entriesRead, totalEntries, NIL_HANDLE);

  if rv = NERR_Success then
  try
    p := PGROUP_INFO_0 (buffer);
    if (entriesRead <> 1) or (p^.grpi0_name <> 'None') then
      for i := 0 to entriesRead - 1 do
      begin
        list.Add (p^.grpi0_name);
        Inc (p)
      end ;
    result:=List.CommaText;
  finally
    NetApiBufferFree (buffer);
    List.Free;
  end
  else
    raise ENTException.Create (rv);

end;

(*----------------------------------------------------------------------------*
 | procedure TNetServer.GetGlobalGroupsDetails                                |
 |                                                                            |
 | Gets a list of group names and other details, suitable for populating the  |
 | user manager group list.  Each string returned consists of a Nul-separeted |
 | list of group name, group comment, and group ID (RID)                      |
 |                                                                            |
 | Parameters                                                                 |
 |   list : TStrings.          Returns the list of group details.             |
 *----------------------------------------------------------------------------*)
procedure TNetServer.GetGlobalGroupsDetails (list : TStrings);
var
  wServer : WideString;
  rv, i, entriesRead, totalEntries : Integer;
  buffer : pointer;
  p : PGROUP_INFO_2;
  st : string;
begin
  list.Clear;
  wServer := ServerName;
  rv := NetGroupEnum (PWideChar (wServer), 2, buffer, MAX_PREFERRED_LENGTH,
                      entriesRead, totalEntries, NIL_HANDLE);

  if rv = NERR_Success then
  try
    p := PGROUP_INFO_2 (buffer);
    if (entriesRead <> 1) or (p^.grpi2_name <> 'None') then
      for i := 0 to entriesRead - 1 do
      begin
        st := p^.grpi2_name;
        st := st + #0 + p^.grpi2_comment;
        st := st + #0 + IntToStr (p^.grpi2_group_id);
        list.Add (st);
        Inc (p)
      end
  finally
    NetApiBufferFree (buffer);
  end
  else
    raise ENTException.Create (rv);
end;

(*----------------------------------------------------------------------------*
 | procedure TNetServer.GetLocalGroups                                        |
 |                                                                            |
 | Returns a list of local group names.  Note that if there aren't any local  |
 | groups, lanman still returns a single entry with a group name of 'None'    |
 |                                                                            |
 | Parameters                                                                 |
 |   list : TStrings                    Returns the list of local group IDs.  |
 *----------------------------------------------------------------------------*)
function TNetServer.GetLocalGroups( wServer:WideString ):String;
var
//  wServer : WideString;
  rv, i, entriesRead, totalEntries : Integer;
  buffer : pointer;
  p : PLOCALGROUP_INFO_0;
  List:TStringList;
begin
  List:=TStringList.Create;
  list.Clear;
  Result :='';
  rv := NetLocalGroupEnum (PWideChar (wServer), 0, buffer, MAX_PREFERRED_LENGTH,
                           entriesRead, totalEntries, NIL_HANDLE);

  if rv = NERR_Success then
  try
    p := PLOCALGROUP_INFO_0 (buffer);
    for i := 0 to entriesRead - 1 do
    begin
      list.Add (p^.lgrpi0_name);
      Inc (p) ;
    end ;
   Result := List.CommaText ;
  finally
    NetApiBufferFree (buffer);
    List.Free;
  end
  else
    raise ENTException.Create (rv);

end;

(*----------------------------------------------------------------------------*
 | procedure TNetServer.GetLocalGroupsDetails                                 |
 |                                                                            |
 | Returns a list of local group names and comments.  Each entry in the list  |
 | consists of the group name, a NULL character, followed by the comment.     |
 |                                                                            |
 | Parameters                                                                 |
 |   list : TStrings            Returns the list of local group details       |
 *----------------------------------------------------------------------------*)
//procedure TNetServer.GetLocalGroupsDetails (list : TStrings);
//var
//  wServer : WideString;
//  rv, i, entriesRead, totalEntries : Integer;
//  buffer : pointer;
//  p : PLOCALGROUP_INFO_1;
//  st : string;
//begin
//  list.Clear;
//  wServer := ServerName;
//  rv := NetLocalGroupEnum (PWideChar (wServer), 1, buffer, MAX_PREFERRED_LENGTH,
//                           entriesRead, totalEntries, NIL_HANDLE);
//
//  if rv = NERR_Success then
//  try
//    p := PLOCALGROUP_INFO_1 (buffer);
//    for i := 0 to entriesRead - 1 do
//    begin
//      st := p^.lgrpi1_name;
//      st := st + #0 + p^.lgrpi1_comment;
//      list.Add (st);
//      Inc (p)
//    end
//  finally
//    NetApiBufferFree (buffer);
//  end
//  else
//    raise ENTException.Create (rv);
//end;

(*----------------------------------------------------------------------------*
 | function TNetServer.GetDomainName : string                                 |
 |                                                                            |
 | Returns the name of the domain that the server is a member of.             |
 |                                                                            |
 | The function returns the name of the domain.                               |
 *----------------------------------------------------------------------------*)
function TNetServer.GetDomainName : string;
var
  err : Integer;
  buf : pointer;
  wServerName : WideString;
begin
  if not (svrDomainName in flags) then
  begin
    wServerName := ServerName;
    err := NetServerGetInfo (PWideChar (wServerName), 503, buf);
    if err = NERR_Success then
    try
      fDomainName := PSERVER_INFO_503 (buf)^.sv503_domain;
      flags := flags + [svrDomainName];
    finally
      NetAPIBufferFree (buf)
    end
    else
      raise ENTException.Create (err);
  end;

  result := fDomainName;
end;

(*----------------------------------------------------------------------------*
 | function TNetServer.GetServerType : TServerAccountFilter                   |
 |                                                                            |
 | Gets the 'server type' flags                                               |
 *----------------------------------------------------------------------------*)
function TNetServer.GetServerType : TServerAccountFilter;
var
  err : Integer;
  buf : pointer;
  wServerName : WideString;
begin
  if not (svrServerType in flags) then
  begin
    wServerName := ServerName;
    err := NetServerGetInfo (PWideChar (wServerName), 101, buf);
    if err = NERR_Success then
    try
      fServerType := DWORDToServerAccountFilter (PSERVER_INFO_101 (buf)^.sv101_type);
      flags := flags + [svrServerType];
    finally
      NetAPIBufferFree (buf)
    end
    else
      raise ENTException.Create (err);
  end;

  result := fServerType
end;

(*----------------------------------------------------------------------------*
 | procedure TNetServer.SetServerName                                         |
 |                                                                            |
 | Sets the value of the ServerName property.  See SetNameToPDC and           |
 | SetNameToAnyDC for other ways of setting the server name property.         |
 *----------------------------------------------------------------------------*)
procedure TNetServer.SetServerName (const value : string);
begin
  if value <> fServerName then
  begin
    flags := [];
    fServerName := value
  end
end;

(*----------------------------------------------------------------------------*
 | procedure TNetServer.NetLogonControl                                       |
 |                                                                            |
 | Does strange things to servers.  Used by the 'Synchronize' method          |
 |                                                                            |
 | Parameters                                                                 |
 |   fn : Integer      ID of the Net Logon Control function to execute.       |
 *----------------------------------------------------------------------------*)
procedure TNetServer.NetLogonControl (fn : Integer);
var
  err : Integer;
  buf : pointer;
  wServerName : WideString;
begin
  wServerName := ServerName;
  err := I_NetLogonControl (PWideChar (wServerName), fn, 1, buf);

  if err = NERR_Success then
    NetAPIBufferFree (buf)
  else
    raise ENTException.Create (err);
end;

(*----------------------------------------------------------------------------*
 | procedure TNetServer.Synchronize                                           |
 |                                                                            |
 | Synchronize a PDC with it's BDCs.                                          |
 *----------------------------------------------------------------------------*)
procedure TNetServer.Synchronize;
begin
  NetLogonControl (NETLOGON_CONTROL_SYNCHRONIZE);
end;


function TNetServer.GetPDC(domName:String ):string;

//------------------------------------------------------
// Name       : getPDC
//
// Parameters : domName - Domain name.
//
//              err     - Error flag.
//
// Purpose    : Determines the server name of the PDC in
//              the domName domain.
//
// Notes      : The retVal buffer returned by NetGetDCName
//              is allocated within that function.  It
//              has, therefore, to be freed by a call to
//              NetAPIBufferFree.
//
//              Buffers passed to and from calls to
//              NETAPI32 are generally byte pointers,
//              LPBYTE.  To access the returned data
//              we need the address of the byte pointed
//              to by this hence
//
//                 tempStr:=@retVal^
//
//              The server name returned is prefixed by
//              \\, e.g. \\FRED1
//------------------------------------------------------

var
  //temp    : ARRAY[0..255] OF WideChar;
   Temp:String;
   tempStr : LPCWSTR;
   //retVal  : LPBYTE;
   retval:pointer;
begin
   result:='';
  //rv := NetGetDCName (Nil, PWideChar (wDomainName), buffer);
  //IF NetGetDCName(NIL,temp,retVal) = NERR_Success THEN
   if NetGetDCName(NIL,PWideChar(Temp),retVal) = NERR_Success THEN
   begin
      tempStr:=@retVal^;
      result:=WideChartoString(tempStr);
      NetApiBufferFree(retVal)
   end;
end;

function TNetServer.ChangePassword(const wServername, wUserName,wOldPassword, wNewPassword: WideString): boolean;
//var
//  wServerName, wUserName, wOldPassword, wNewPassword : WideString;
begin

//   wServerName  := ServerName  ;
//   wUserName    := UserName    ;
//   wOldPassword := OldPassword ;
//   wNewPassword := NewPassword ;
   result:=False;

   try

      result := ( NetUserChangePassword ( PWideChar (wServerName),
                                          PWideChar (wUserName),
                                          PWideChar (woldPassword),
                                          PWideChar (wNewPassword)
                                        )
                  =  NERR_Success );

   except

      //on e : exception do
      //begin
      //
      //   GPCSErrorLine.RaiseException($864, E);
      //   HandleStatusError( e.message );
      //
      //end ;

   end ;

end ;

procedure Register;
begin
  RegisterComponents('Lan Manager', [TNetServer]);
end;


end.
