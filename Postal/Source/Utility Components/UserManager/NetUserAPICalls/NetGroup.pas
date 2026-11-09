unit NetGroup;

interface

uses
  Windows, SysUtils, Classes, NetServer, lmaccess;

type
  TNetGroupComponents = (uiComment, uiAttributes, uiGroupID);
  TNetGroupFlags = set of TNetGroupComponents;

  TNetGroup = class(TComponent)
  private
    fGroupName : string;
    fServer : TNetServer;
    fInfoFlags : TNetGroupFlags;

    procedure SetGroupName (const value : string);
    procedure SetServer (value : TNetServer);
    procedure GetWideName (var wServer, wName : WideString);

  protected
    procedure ClearInfoBuffer; virtual;
    function GetInfoBuffer (level : Integer) : pointer; virtual; abstract;
    procedure SetInfoBuffer (level : Integer; value : pointer); virtual; abstract;
    function GetComment : string; virtual; abstract;
    procedure SetComment (value : string); virtual; abstract;

    property InfoBuffer [level : Integer] : pointer read GetInfoBuffer write SetInfoBuffer;

  public
    destructor Destroy; override;
    property Comment : string read GetComment write SetComment;
    procedure GetMembers (list : TStrings); virtual; abstract;
    procedure CreateGroup (const comment : string); virtual; abstract;
    procedure AddMember (const id : string); virtual; abstract;
    procedure DeleteMember (const id : string); virtual; abstract;
    procedure DeleteGroup; virtual; abstract;
    procedure RenameGroup (const newName : string); virtual; abstract;
  published
    property GroupName : string read fGroupName write SetGroupName;
    property Server : TNetServer read fServer write SetServer;
  end;

  TNetGlobalGroup = class (TNetGroup)
    private
    fInfo : GROUP_INFO_2;

    function GetGroupID : Integer;

    protected
    procedure ClearInfoBuffer; override;
    function GetInfoBuffer (level : Integer) : pointer; override;
    procedure SetInfoBuffer (level : Integer; value : pointer); override;
    function GetComment : string; override;
    procedure SetComment (value : string); override;

    public
    procedure GetLevel2Info;
    property GroupID : Integer read GetGroupID;
    procedure CreateGroup (const comment : string); override;
    procedure DeleteGroup; override;
    procedure GetMembers (list : TStrings); override;
    procedure AddMember (const id : string); override;
    procedure DeleteMember (const id : string); override;
    procedure RenameGroup (const newName : string); override;
  end;

  TNetLocalGroup = class (TNetGroup)
  private
    fInfo : LOCALGROUP_INFO_1;

  protected
    procedure ClearInfoBuffer; override;
    function GetInfoBuffer (level : Integer) : pointer; override;
    procedure SetInfoBuffer (level : Integer; value : pointer); override;
    function GetComment : string; override;
    procedure SetComment (value : string); override;

  public
    procedure CreateGroup (const comment : string); override;
    procedure DeleteGroup; override;
    procedure GetMembers (list : TStrings); override;
    procedure AddMember (const id : string); override;
    procedure DeleteMember (const id : string); override;
    procedure AddMemberFrom (const id, memberServer : string);
    procedure DeleteMemberFrom (const id, memberServer : string);
    procedure RenameGroup (const newName : string); override;
  end;

procedure Register;

implementation

uses lmglobal, unitNTException;

var
  NIL_HANDLE : Integer absolute 0;

destructor TNetGroup.Destroy;
begin
  ClearInfoBuffer;
  inherited
end;

procedure TNetGroup.GetWideName (var wServer, wName : WideString);
begin
  if Assigned (Server) then
    wServer := Server.ServerName
  else
    wServer := '';
  wName := GroupName;
end;

procedure TNetGroup.ClearInfoBuffer;
begin
  fInfoFlags := [];
end;

procedure TNetGroup.SetGroupName (const value : string);
begin
  if value <> fGroupname then
  begin
    fGroupName := value;
    ClearInfoBuffer
  end
end;

procedure TNetGroup.SetServer (value : TNetServer);
begin
  if value <> fServer then
  begin
    fServer := value;
    ClearInfoBuffer
  end
end;

procedure TNetGlobalGroup.ClearInfoBuffer;
begin
  if uiComment in fInfoFlags then FreeMem (fInfo.grpi2_Comment);
  inherited
end;

function TNetGlobalGroup.GetInfoBuffer (level : Integer) : pointer;
var
  wServer : WideString;
  wGroup : WideString;
  rv : Integer;
begin
  GetWideName (wServer, wGroup);
  rv := NetGroupGetInfo (PWideChar (wServer), PWideChar (wGroup), level, result);
  if rv <> NErr_Success then
    raise ENTException.Create (rv);
end;

procedure TNetGlobalGroup.SetInfoBuffer (level : Integer; value : pointer);
var
  wServer : WideString;
  wGroup : WideString;
  rv : Integer;
begin
  GetWideName (wServer, wGroup);
  rv := NetGroupSetInfo (PWideChar (wServer), PWideChar (wGroup), level, PChar (value), NIL_HANDLE);
  if rv <> NErr_Success then
    raise ENTException.Create (rv);
end;

function TNetGlobalGroup.GetComment : string;
begin
  if not (uiComment in fInfoFlags) then
    GetLevel2Info;

  result := fInfo.grpi2_comment;
end;

procedure TNetGlobalGroup.SetComment(value : string);
var
  wValue : WideString;
  buffer : GROUP_INFO_1002;
begin
  if value <> Comment then
  begin
    if uiComment in fInfoFlags then FreeMem (fInfo.grpi2_comment);
    wValue := value;
    fInfo.grpi2_comment := WStrNew (PWideChar (wValue));
    fInfoFlags := fInfoFlags + [uiComment];

    buffer.grpi1002_comment := fInfo.grpi2_comment;
    InfoBuffer [1002] := @buffer;
  end
end;

procedure TNetGlobalGroup.GetMembers (list : TStrings);
var
  wServer, wGroupName : WideString;
  rv, i, entriesRead, totalEntries : Integer;
  buffer : pointer;
  p : PGROUP_USERS_INFO_0;
begin
  list.Clear;
  GetWideName (wServer, wGroupName);
  rv := NetGroupGetUsers (PWideChar (wServer), PWideChar (wGroupName), 0, buffer, MAX_PREFERRED_LENGTH,
                           entriesRead, totalEntries, NIL_HANDLE);

  if rv = NERR_Success then
  try
    p := PGROUP_USERS_INFO_0 (buffer);
    for i := 0 to entriesRead - 1 do
    begin
      list.AddObject (p^.grpui0_name, TObject (SidTypeUser));
      Inc (p)
    end
  finally
    NetApiBufferFree (buffer);
  end
  else
    raise ENTException.Create (rv);
end;

procedure TNetGlobalGroup.CreateGroup (const comment : string);
var
  info : GROUP_INFO_1;
  wServer : WideString;
  wComment : WideString;
  wGroupName : WideString;
  err : Integer;
begin
  ClearInfoBuffer;
  GetWideName (wServer, wGroupName);

  wComment := comment;

  info.grpi1_comment := PWideChar (wComment);
  info.grpi1_name := PWideChar (wGroupName);

  err := NetGroupAdd (PWideChar (WServer), 1, @info, NIL_HANDLE);

  if err = NERR_Success then
  begin
    fInfo.grpi2_comment := WStrNew (PWideChar (wComment));
    fInfoFlags := fInfoFlags + [uiComment]
  end
  else
    raise ENTException.Create (err);
end;

procedure TNetGlobalGroup.DeleteGroup;
var
  err : Integer;
  wServer, wGroupName : WideString;
begin
  GetWideName (wServer, wGroupName);

  err := NetGroupDel (PWideChar (wServer), PWideChar (wGroupName));
  if err = NERR_Success then
    ClearInfoBuffer
  else
    raise ENTException.Create (err);
end;

procedure TNetGlobalGroup.RenameGroup (const NewName : string);
var
  wNewName : WideString;
  buffer : GROUP_INFO_0;
begin
  wNewName := newName;
  buffer.grpi0_name := PWideChar (wNewName);
  InfoBuffer [0] := @buffer;
  fGroupName := newName
end;

procedure TNetGlobalGroup.AddMember (const id : string);
var
  wServer, wGroup, wUser : WideString;
  err : Integer;
begin
  GetWideName (wServer, wGroup);
  wUser := id;

  err := NetGroupAddUser (PWideChar (wServer), PWideChar (wGroup), PWideChar (wUser));
  if err <> NERR_Success then
    raise ENTException.Create (err);
end;

procedure TNetGlobalGroup.DeleteMember (const id : string);
var
  wServer, wGroup, wUser : WideString;
  err : Integer;
begin
  GetWideName (wServer, wGroup);
  wUser := id;

  err := NetGroupDelUser (PWideChar (wServer), PWideChar (wGroup), PWideChar (wUser));
  if err <> NERR_Success then
    raise ENTException.Create (err);
end;

function TNetGlobalGroup.GetGroupID : Integer;
begin
  if not (uiGroupID in fInfoFlags) then
    GetLevel2Info;

  result := fInfo.grpi2_group_id
end;

procedure TNetGlobalGroup.GetLevel2Info;
var
  buffer : PGROUP_INFO_2;
begin
  buffer := InfoBuffer [2];
  with buffer^ do
  try
    fInfo.grpi2_comment := WStrNew (grpi2_comment);
    fInfo.grpi2_attributes := grpi2_attributes;
    fInfo.grpi2_group_id := grpi2_group_id;

    fInfoFlags := fInfoFlags + [uiComment, uiAttributes, uiGroupID];

  finally
    NetApiBufferFree (buffer);
  end
end;

procedure TNetLocalGroup.ClearInfoBuffer;
begin
  if uiComment in fInfoFlags then FreeMem (fInfo.lgrpi1_Comment);
  inherited
end;

function TNetLocalGroup.GetInfoBuffer (level : Integer) : pointer;
var
  wServer : WideString;
  wGroup : WideString;
  rv : Integer;
begin
  GetWideName (wServer, wGroup);
  rv := NetLocalGroupGetInfo (PWideChar (wServer), PWideChar (wGroup), level, result);
  if rv <> NErr_Success then
    raise ENTException.Create (rv)
end;

procedure TNetLocalGroup.SetInfoBuffer (level : Integer; value : pointer);
var
  wServer : WideString;
  wGroup : WideString;
  rv : Integer;
begin
  GetWideName (wServer, wGroup);
  rv := NetLocalGroupSetInfo (PWideChar (wServer), PWideChar (wGroup), level, PChar (value), NIL_HANDLE);
  if rv <> NErr_Success then
    raise ENTException.Create (rv);
end;

function TNetLocalGroup.GetComment : string;
var
  buffer : PLOCALGROUP_INFO_1;
begin
  if not (uiComment in fInfoFlags) then
  begin
    buffer := InfoBuffer [1];
    with buffer^ do
    try
      fInfo.lgrpi1_comment := WStrNew (lgrpi1_comment);
      fInfoFlags := fInfoFlags + [uiComment];
    finally
      NetApiBufferFree (buffer);
    end
  end;

  result := fInfo.lgrpi1_comment;
end;

procedure TNetLocalGroup.SetComment(value : string);
var
  wValue : WideString;
  buffer : LOCALGROUP_INFO_1002;
begin
  if value <> Comment then
  begin
    if uiComment in fInfoFlags then FreeMem (fInfo.lgrpi1_comment);
    wValue := value;
    fInfo.lgrpi1_comment := WStrNew (PWideChar (wValue));
    fInfoFlags := fInfoFlags + [uiComment];
    buffer.lgrpi1002_comment := fInfo.lgrpi1_comment;
    InfoBuffer [1002] := @buffer;
  end
end;

procedure TNetLocalGroup.GetMembers (list : TStrings);
var
  ServerName : string;
  wServer, wGroupName : WideString;
  rv, i, entriesRead, totalEntries : Integer;
  buffer : pointer;
  p : PLOCALGROUP_MEMBERS_INFO_0;
  accountName : array [0..UNLEN] of char;
  domainName : array [0..DNLEN] of char;
  accountNameLen, domainNameLen : DWORD;
  sidNameUse : SID_NAME_USE;
  st : string;
  defaultServer : string;
begin
  list.Clear;
  if Assigned (Server) then
    ServerName := Server.ServerName
  else
    ServerName := '';
  if ServerName = '' then
  begin
    SetLength (defaultServer, CNLEN + 1);
    domainNameLen := CNLEN + 1;
    GetComputerName (PChar (defaultServer), domainNameLen);
    SetLength (defaultServer, lstrlen (PChar (defaultServer)))
  end
  else defaultServer := ServerName;

  wServer := ServerName;
  wGroupName := GroupName;
  rv := NetLocalGroupGetMembers (PWideChar (wServer), PWideChar (wGroupName), 0, buffer, MAX_PREFERRED_LENGTH,
                           entriesRead, totalEntries, NIL_HANDLE);

  if rv = NERR_Success then
  try
    p := PLOCALGROUP_MEMBERS_INFO_0 (buffer);
    for i := 0 to entriesRead - 1 do
    begin
      accountNameLen := sizeof (accountName);
      domainNameLen := sizeof (domainName);

      if not LookupAccountSid (PChar (ServerName), p^.lgrmi0_sid,
                               accountName, accountNameLen,
                               domainName, domainNameLen, sidNameUse) then
      begin
        accountName := 'Unknown';
        raise ENTException.Create (GetLastError)
      end;

      if domainName = defaultServer then
        st := accountName
      else
        st := domainName + '\' + string (accountName);
      list.AddObject (st, TObject (sidNameUse));
      Inc (p)
    end
  finally
    NetApiBufferFree (buffer);
  end
  else
    raise ENTException.Create (rv);
end;

procedure TNetLocalGroup.CreateGroup (const comment : string);
var
  info : LOCALGROUP_INFO_1;
  wServer : WideString;
  wComment : WideString;
  wGroupName : WIdeString;
  err : Integer;
begin
  ClearInfoBuffer;
  GetWideName (wServer, wGroupName);
  wComment := comment;

  info.lgrpi1_comment := PWideChar (wComment);
  info.lgrpi1_name := PWideChar (wGroupName);

  err := NetLocalGroupAdd (PWideChar (WServer), 1, @info, NIL_HANDLE);

  if err = NERR_Success then
  begin
    fInfo.lgrpi1_comment := WStrNew (PWideChar (wComment));
    fInfoFlags := fInfoFlags + [uiComment]
  end
  else
    raise ENTException.Create (err);
end;

procedure TNetLocalGroup.DeleteGroup;
var
  err : Integer;
  wServer, wGroupName : WideString;
begin
  GetWideName (wServer, wGroupName);

  err := NetLocalGroupDel (PWideChar (wServer), PWideChar (wGroupName));
  if err = NERR_Success then
    ClearInfoBuffer
  else
    raise ENTException.Create (err);
end;

procedure TNetLocalGroup.AddMemberFrom (const id, memberServer : string);
var
  sid : PSid;
  peUse : SID_NAME_USE;
  err : Integer;
  sidLen, domainNameLen : DWORD;
  domainName : array [0..DNLEN] of char;
  wServer, wGroup : WideString;
begin
  GetWideName (wServer, wGroup);

  sidLen := 65536;
  domainNameLen := DNLEN + 1;

  GetMem (sid, sidLen);
  try
    if (LookupAccountName (PChar (memberServer), PChar (id), sid, sidLen, domainName, domainNameLen, peUse)) then
    begin
      err := NetLocalGroupAddMember (PWideChar (wServer), PWideChar (wGroup), sid);
      if err <> NERR_Success then
        raise ENTException.Create (err);
    end
    else raise ENTException.CreateLastError;
  finally
    FreeMem (sid)
  end
end;

procedure TNetLocalGroup.AddMember (const id : string);
var
  serverName : string;
begin
  if Assigned (Server) then
    serverName := Server.ServerName
  else
    serverName := '';

  AddMemberFrom (id, serverName)
end;

procedure TNetLocalGroup.DeleteMemberFrom (const id, memberServer : string);
var
  sid : PSid;
  err : Integer;
  peUse : SID_NAME_USE;
  sidLen, domainNameLen : DWORD;
  domainName : array [0..DNLEN] of char;
  wServer, wGroup : WideString;
begin
  GetWideName (wServer, wGroup);

  sidLen := 65536;
  domainNameLen := DNLEN + 1;

  GetMem (sid, sidLen);
  try
    if (LookupAccountName (PChar (memberServer), PChar (id), sid, sidLen, domainName, domainNameLen, peUse)) then
    begin
      err := NetLocalGroupDelMember (PWideChar (wServer), PWideChar (wGroup), sid);
      if err <> NERR_Success then
        raise ENTException.Create (err);
    end
    else raise ENTException.CreateLastError;
  finally
    FreeMem (sid)
  end
end;

procedure TNetLocalGroup.DeleteMember (const id : string);
var
  serverName : string;
begin
  if Assigned (Server) then
    serverName := Server.ServerName
  else
    serverName := '';

  DeleteMemberFrom (id, serverName)
end;

procedure TNetLocalGroup.RenameGroup (const NewName : string);
var
  wNewName : WideString;
  buffer : LOCALGROUP_INFO_0;
begin
  wNewName := newName;
  buffer.lgrpi0_name := PWideChar (wNewName);
  InfoBuffer [0] := @buffer;
  fGroupName := newName
end;


procedure Register;
begin
  RegisterComponents('Lan Manager', [TNetGlobalGroup, TNetLocalGroup]);
end;

end.
