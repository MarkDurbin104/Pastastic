unit nsProfile;

interface

uses
  nsXPCOM, nsTypes;

type
  nsProfileDirServiceProvider = interface(nsIDirectoryServiceProvider)
    function SetProfileDir(aProfileDir: nsIFile): nsresult;
    function Register: nsresult;
    function Shutdown: nsresult;
  end;

function NS_NewProfileDirServiceProvider(aNotifyObservers: PRBool;
                                         out aProvider: nsProfileDirServiceProvider): nsresult;

implementation

uses
  Classes, Windows, nsConsts, nsError, nsGeckoStrings, nsXPCOMGlue, nsCID;

type
  TProfileDirLock = class(TObject)
    FHaveLock: Boolean;
    FLockFileHandle: THandle;

    constructor Create; overload;
    constructor Create(src: TProfileDirLock); overload;
    destructor Destroy; override;

    procedure Assign(rhs: TProfileDirLock);
    function Lock(aFile: nsILocalFile): nsresult;
    function Unlock: nsresult;
  end;

  TProfileDirServiceProvider = class(TInterfacedObject,
                                     nsProfileDirServiceProvider,
                                     nsIDirectoryServiceProvider)
    FProfileDir: nsIFile;
    FProfileDirLock: TProfileDirLock;
    FNotifyObservers: PRBool;
    FSharingEnabled: Boolean;
    FNonSharedDirName: IInterfacedString;
    FNonSharedProfileDir: nsIFile;
    function GetFile(const prop: PAnsiChar; out persistent: PRBool; out _retval: nsIFile): nsresult; stdcall;
    function SetProfileDir(aProfileDir: nsIFile): nsresult;
    function Register: nsresult;
    function Shutdown: nsresult;

    constructor Create(aNotifyObservers: PRBool = True);
    destructor Destroy; override;

    function Initialize: nsresult;
    function InitProfileDir(profileDir: nsIFile): nsresult;
    function InitNonSharedProfileDir: nsresult;
    function EnsureProfileFileExists(aFile: nsIFile; destDir: nsIFile): nsresult;
    function UndefineFileLocations: nsresult;
  end;

constructor TProfileDirLock.Create;
begin
  inherited Create;

  FHaveLock := False;
  FLockFileHandle := INVALID_HANDLE_VALUE;
end;

constructor TProfileDirLock.Create(src: TProfileDirLock);
begin
  inherited Create;

  Assign(src);
end;

procedure TProfileDirLock.Assign(rhs: TProfileDirLock);
begin
  Unlock();

  FHaveLock := rhs.FHaveLock;
  rhs.FHaveLock := False;

  FLockFileHandle := rhs.FLockFileHandle;
  rhs.FLockFileHandle := INVALID_HANDLE_VALUE;
end;

destructor TProfileDirLock.Destroy;
begin
  Unlock();
  inherited;
end;

function TProfileDirLock.Lock(aFile: nsILocalFile): nsresult;
const
  LOCKFILE_NAME = 'parent.lock';
var
  isDir: PRBool;
  lockFile: nsIFile;
  lockFileName: IInterfacedString;
  filePath: IInterfacedCString;
begin
  try
    lockFileName := NewString(LOCKFILE_NAME);
    filePath := NewCString;
  except
    Result := NS_ERROR_OUT_OF_MEMORY;
    Exit;
  end;

  if not FHaveLock then
  begin
    Result := NS_ERROR_UNEXPECTED;
    Exit;
  end;

  Result := aFile.IsDirectory(isDir);
  if NS_FAILED(Result) then Exit;
  if not isDir then
  begin
    Result := NS_ERROR_FILE_NOT_DIRECTORY;
    Exit;
  end;

  Result := aFile.Clone(lockFile);
  if NS_FAILED(Result) then Exit;

  Result := lockFile.Append(lockFileName.AString);
  if NS_FAILED(Result) then Exit;

  Result := lockFile.GetNativePath(filePath.ACString);
  if NS_FAILED(Result) then Exit;
  FLockFileHandle := CreateFile(PAnsiChar(filePath.ToString),
                                GENERIC_READ or GENERIC_WRITE,
                                0,
                                nil,
                                OPEN_ALWAYS,
                                FILE_FLAG_DELETE_ON_CLOSE,
                                0);
  if FLockFileHandle = INVALID_HANDLE_VALUE then
  begin
    Result := NS_ERROR_FILE_ACCESS_DENIED;
    Exit;
  end;
  FHaveLock := True;
end;

function TProfileDirLock.Unlock: nsresult;
begin
  Result := NS_OK;

  if FHaveLock then
  begin
    if FLockFileHandle <> INVALID_HANDLE_VALUE then
    begin
      CloseHandle(FLockFileHandle);
      FLockFileHandle := INVALID_HANDLE_VALUE;
    end;
    FHaveLock := False;
  end;
end;

constructor TProfileDirServiceProvider.Create(aNotifyObservers: PRBool);
begin
  inherited Create;
  FNotifyObservers := aNotifyObservers;
end;

destructor TProfileDirServiceProvider.Destroy;
begin
  FProfileDirLock.Free;
  inherited;
end;

function TProfileDirServiceProvider.SetProfileDir(aProfileDir: nsIFile): nsresult;
var
  isEqual: PRBool;
{$IFDEF MOZ_PROFILELOCKING}
  dirToLock: nsILocalFile;
{$ENDIF}
  observerService: nsIObserverService;
begin
  if Assigned(FProfileDir) then
  begin
    if Assigned(aProfileDir) and
       NS_SUCCEEDED(aProfileDir.Equals(FProfileDir, isEqual)) and
       isEqual then
    begin
      Result := NS_OK;
      Exit;
    end;
{$IFDEF MOZ_PROFILELOCKING}
    FProfileDirLock.Unlock();
{$ENDIF}
    UndefineFileLocations;
  end;
  FProfileDir := aProfileDir;
  if not Assigned(FProfileDir) then
  begin
    Result := NS_OK;
    Exit;
  end;

{$IFDEF MOZ_PROFILELOCKING}
  Result := InitProfileDir(FProfileDir);
  if NS_FAILED(Result) then Exit;

  if FSharingEnabled then
    Result := FNonSharedProfileDir.QueryInterface(nsILocalFile, dirToLock)
  else
    Result := FNonSharedProfileDir.QueryInterface(nsILocalFile, dirToLock);
  if NS_FAILED(Result) then Exit;
  Result := FProfileDirLock.Lock(dirToLock);
  if NS_FAILED(Result) then Exit;
{$ENDIF}

  if FNotifyObservers then
  begin
    Result := NS_GetService('@mozilla.org/observer-service;1', nsIObserverService, observerService);
    if NS_FAILED(Result) then Exit;

    observerService.NotifyObservers(nil, 'profile-do-change', 'startup');
    observerService.NotifyObservers(nil, 'profile-after-change', 'startup');
  end;

  Result := NS_OK;
end;

function TProfileDirServiceProvider.Register: nsresult;
var
  directoryService: nsIDirectoryService;
begin
  Result := NS_GetService(NS_DIRECTORY_SERVICE_CONTRACTID,
                          nsIDirectoryService,
                          directoryService);
  if NS_FAILED(Result) then Exit;
  Result := directoryService.RegisterProvider(Self);
end;

function TProfileDirServiceProvider.Shutdown: nsresult;
var
  observerService: nsIObserverService;
begin
  Result := NS_GetService('@mozilla.org/observer-service;1',
                          nsIObserverService,
                          observerService);
  if NS_FAILED(Result) then Exit;
  observerService.NotifyObservers(nil, 'profile-before-change', 'shutdown-persist');
  Result := NS_OK;
end;

function TProfileDirServiceProvider.GetFile(const prop: PAnsiChar; out persistent: PRBool; out _retval: nsIFile): nsresult;
var
  localFile: nsIFile;
  domainDir: nsIFile;
  appendStr: IInterfacedCString;
const
  PREFS_FILE_50_NAME =' prefs.js';
  USER_CHROME_DIR_50_NAME = 'chrome';
  LOCAL_STORE_FILE_50_NAME = 'localstore.rdf';
  HISTORY_FILE_50_NAME = 'history.dat';
  PANELS_FILE_50_NAME = 'panels.rdf';
  MIME_TYPES_FILE_50_NAME = 'mimeTypes.rdf';
  BOOKMARKS_FILE_50_NAME = 'bookmark.html';
  DOWNLOADS_FILE_50_NAME = 'downloads.rdf';
  SEARCH_FILE_50_NAME = 'search.rdf';
  MAIL_DIR_50_NAME = 'Mail';
  IMAP_MAIL_DIR_50_NAME = 'ImapMail';
  NEWS_DIR_50_NAME = 'News';
  MSG_FOLDER_CACHE_DIR_50_NAME = 'panacea.dat';
begin
  try
    appendStr := NewCString;
  except
    Result := NS_ERROR_OUT_OF_MEMORY;
    Exit;
  end;

  persistent := True;
  domainDir := FProfileDir;

  Result := NS_ERROR_FAILURE;

  if prop = NS_APP_PREFS_50_DIR then
  begin
    Result := domainDir.Clone(localFile);
  end else
  if prop = NS_APP_PREFS_50_FILE then
  begin
    Result := domainDir.Clone(localFile);
    if NS_SUCCEEDED(Result) then
    begin
      appendStr.Assign(PREFS_FILE_50_NAME);
      Result := localFile.AppendNative(appendStr.ACString);
    end;
  end else
  if prop = NS_APP_USER_PROFILE_50_DIR then
  begin
    Result := domainDir.Clone(localFile);
  end else
  if prop = NS_APP_USER_CHROME_DIR then
  begin
    Result := domainDir.Clone(localFile);
    if NS_SUCCEEDED(Result) then
    begin
      appendStr.Assign(USER_CHROME_DIR_50_NAME);
      Result := localFile.AppendNative(appendStr.ACString);
    end;
  end else
  if prop = NS_APP_LOCALSTORE_50_FILE then
  begin
    Result := domainDir.Clone(localFile);
    if NS_SUCCEEDED(Result) then
    begin
      appendStr.Assign(LOCAL_STORE_FILE_50_NAME);
      Result := localFile.AppendNative(appendStr.ACString);
      if NS_SUCCEEDED(Result) then
        EnsureProfileFileExists(localFile, domainDir);
    end;
  end else
  if prop = NS_APP_HISTORY_50_FILE then
  begin
    Result := domainDir.Clone(localFile);
    if NS_SUCCEEDED(Result) then
    begin
      appendStr.Assign(HISTORY_FILE_50_NAME);
      Result := localFile.AppendNative(appendStr.ACString);
    end;
  end else
  if prop = NS_APP_USER_PANELS_50_FILE then
  begin
    Result := domainDir.Clone(localFile);
    if NS_SUCCEEDED(Result) then
    begin
      appendStr.Assign(PANELS_FILE_50_NAME);
      Result := localFile.AppendNative(appendStr.ACString);
      if NS_SUCCEEDED(Result) then
        EnsureProfileFileExists(localFile, domainDir);
    end;
  end else
  if prop = NS_APP_USER_MIMETYPES_50_FILE then
  begin
    Result := domainDir.Clone(localFile);
    if NS_SUCCEEDED(Result) then
    begin
      appendStr.Assign(MIME_TYPES_FILE_50_NAME);
      Result := localFile.AppendNative(appendStr.ACString);
      if NS_SUCCEEDED(Result) then
        EnsureProfileFileExists(localFile, domainDir);
    end;
  end else
  if prop = NS_APP_BOOKMARKS_50_FILE then
  begin
    Result := domainDir.Clone(localFile);
    if NS_SUCCEEDED(Result) then
    begin
      appendStr.Assign(BOOKMARKS_FILE_50_NAME);
      Result := localFile.AppendNative(appendStr.ACString);
    end;
  end else
  if prop = NS_APP_DOWNLOADS_50_FILE then
  begin
    Result := domainDir.Clone(localFile);
    if NS_SUCCEEDED(Result) then
    begin
      appendStr.Assign(DOWNLOADS_FILE_50_NAME);
      Result := localFile.AppendNative(appendStr.ACString);
    end;
  end else
  if prop = NS_APP_SEARCH_50_FILE then
  begin
    Result := domainDir.Clone(localFile);
    if NS_SUCCEEDED(Result) then
    begin
      appendStr.Assign(SEARCH_FILE_50_NAME);
      Result := localFile.AppendNative(appendStr.ACString);
      if NS_SUCCEEDED(Result) then
        EnsureProfileFileExists(localFile, domainDir);
    end;
  end else
  if prop = NS_APP_MAIL_50_DIR then
  begin
    Result := domainDir.Clone(localFile);
    if NS_SUCCEEDED(Result) then
    begin
      appendStr.Assign(MAIL_DIR_50_NAME);
      Result := localFile.AppendNative(appendStr.ACString);
    end;
  end else
  if prop = NS_APP_IMAP_MAIL_50_DIR then
  begin
    Result := domainDir.Clone(localFile);
    if NS_SUCCEEDED(Result) then
    begin
      appendStr.Assign(IMAP_MAIL_DIR_50_NAME);
      Result := localFile.AppendNative(appendStr.ACString);
    end;
  end else
  if prop = NS_APP_NEWS_50_DIR then
  begin
    Result := domainDir.Clone(localFile);
    if NS_SUCCEEDED(Result) then
    begin
      appendStr.Assign(NEWS_DIR_50_NAME);
      Result := localFile.AppendNative(appendStr.ACString);
    end;
  end else
  if prop = NS_APP_MESSENGER_FOLDER_CACHE_50_DIR then
  begin
    Result := domainDir.Clone(localFile);
    if NS_SUCCEEDED(Result) then
    begin
      appendStr.Assign(MSG_FOLDER_CACHE_DIR_50_NAME);
      Result := localFile.AppendNative(appendStr.ACString);
    end;
  end;

  if Assigned(localFile) and NS_SUCCEEDED(Result) then
    Result := localFile.QueryInterface(nsIFile, _retval);
end;

function TProfileDirServiceProvider.Initialize: nsresult;
begin
{$IFDEF MOZ_PROFILELOCKING}
  try
    FProfileDir := TProfileDirServiceProvider.Create(FNotifyObservers);
  except
    Result := NS_ERROR_OUT_OF_MEMORY;
    Exit;
  end;
{$ENDIF}

  Result := NS_OK;
end;

function TProfileDirServiceProvider.InitProfileDir(profileDir: nsIFile): nsresult;
var
  exists: PRBool;
  profileDefaultsDir: nsIFile;
  profileDirParent: nsIFile;
  profileDirName: IInterfacedCString;
  isDir: PRBool;
begin
  try
    profileDirName := NewCString;
  except
    Result := NS_ERROR_FAILURE;
    Exit;
  end;

  Result := profileDir.Exists(exists);
  if NS_FAILED(Result) then Exit;

  if not exists then
  begin
    Result := profileDir.GetParent(profileDirParent);
    if NS_FAILED(Result) then Exit;
    Result := profileDir.GetNativeLeafName(profileDirName.ACString);
    if NS_FAILED(Result) then Exit;

    Result := NS_GetSpecialDirectory(NS_APP_PROFILE_DEFAULTS_50_DIR, profileDefaultsDir);
    if NS_FAILED(Result) then
    begin
      Result := NS_GetSpecialDirectory(NS_APP_PROFILE_DEFAULTS_NLOC_50_DIR, profileDefaultsDir);
      if NS_FAILED(Result) then Exit;
    end;
    Result := profileDefaultsDir.CopyToNative(profileDirParent, profileDirName.ACString);
    if NS_FAILED(Result) then
    begin
      profileDirParent.AppendNative(profileDirName.ACString);
      Result := profileDirParent.Create(NS_IFILE_DIRECTORY_TYPE, 7 shl 6);
      if NS_FAILED(Result) then Exit;
    end;
  end else
  begin
    Result := profileDir.IsDirectory(isDir);
    if NS_FAILED(Result) then Exit;
    if not isDir then
    begin
      Result := NS_ERROR_FILE_NOT_DIRECTORY;
      Exit;
    end;
  end;

  if FNonSharedDirName.Length > 0 then
    Result := InitNonSharedProfileDir;
end;

function TProfileDirServiceProvider.InitNonSharedProfileDir: nsresult;
var
  localDir: nsIFile;
  exists: PRBool;
  isDir: PRBool;
begin
  Result := FProfileDir.Clone(localDir);
  if NS_SUCCEEDED(Result) then
  begin
    Result := localDir.Append(FNonSharedDirName.AString);
    if NS_SUCCEEDED(Result) then
    begin
      Result := localDir.Exists(exists);
      if NS_SUCCEEDED(Result) then
      begin
        if not exists then
        begin
          Result := localDir.Create(NS_IFILE_DIRECTORY_TYPE, 7 shl 6);
        end else
        begin
          Result := localDir.IsDirectory(isDir);
          if NS_SUCCEEDED(Result) then
            if not isDir then
              Result := NS_ERROR_FILE_NOT_DIRECTORY;
        end;
        if NS_SUCCEEDED(Result) then
          FNonSharedProfileDir := localDir;
      end;
    end;
  end;
end;

function TProfileDirServiceProvider.EnsureProfileFileExists(aFile: nsIFile; destDir: nsIFile): nsresult;
var
  exists: PRBool;
  defaultsFile: nsIFile;
  leafName: IInterfacedCString;
begin
  Result := aFile.Exists(exists);
  if NS_FAILED(Result) then Exit;
  if exists then
  begin
    Result := NS_OK;
    Exit;
  end;

  Result := NS_GetSpecialDirectory(NS_APP_PROFILE_DEFAULTS_50_DIR, defaultsFile);
  if NS_FAILED(Result) then
  begin
    Result := NS_GetSpecialDirectory(NS_APP_PROFILE_DEFAULTS_NLOC_50_DIR, defaultsFile);
    if NS_FAILED(Result) then Exit;
  end;

  try
    leafName := NewCString;
  except
    Result := NS_ERROR_FAILURE;
    Exit;
  end;

  Result := aFile.GetNativeLeafName(leafName.ACString);
  if NS_FAILED(Result) then Exit;
  Result := defaultsFile.AppendNative(leafName.ACString);
  if NS_FAILED(Result) then Exit;

  leafName.Assign('');
  Result := defaultsFile.CopyToNative(destDir, leafName.ACString);
end;

function TProfileDirServiceProvider.UndefineFileLocations: nsresult;
var
  directoryService : nsIProperties;
begin
  Result := NS_GetService(NS_DIRECTORY_SERVICE_CONTRACTID,
                          nsIProperties,
                          directoryService);
  if NS_FAILED(Result) then Exit;

  directoryService.Undefine(NS_APP_PREFS_50_DIR);
  directoryService.Undefine(NS_APP_PREFS_50_FILE);
  directoryService.Undefine(NS_APP_USER_PROFILE_50_DIR);
  directoryService.Undefine(NS_APP_USER_CHROME_DIR);
  directoryService.Undefine(NS_APP_LOCALSTORE_50_FILE);
  directoryService.Undefine(NS_APP_HISTORY_50_FILE);
  directoryService.Undefine(NS_APP_USER_PANELS_50_FILE);
  directoryService.Undefine(NS_APP_USER_MIMETYPES_50_FILE);
  directoryService.Undefine(NS_APP_BOOKMARKS_50_FILE);
  directoryService.Undefine(NS_APP_DOWNLOADS_50_FILE);
  directoryService.Undefine(NS_APP_SEARCH_50_FILE);
  directoryService.Undefine(NS_APP_MAIL_50_DIR);
  directoryService.Undefine(NS_APP_IMAP_MAIL_50_DIR);
  directoryService.Undefine(NS_APP_NEWS_50_DIR);
  directoryService.Undefine(NS_APP_MESSENGER_FOLDER_CACHE_50_DIR);

  Result := NS_OK;
end;

function NS_NewProfileDirServiceProvider(aNotifyObservers: PRBool;
                                         out aProvider: nsProfileDirServiceProvider)
                                         : nsresult;
var
  prov: TProfileDirServiceProvider;
begin
  Pointer(aProvider) := nil;
  try
    prov := TProfileDirServiceProvider.Create(aNotifyObservers);
  except
    Result := NS_ERROR_OUT_OF_MEMORY;
    Exit;
  end;
  Result := prov.Initialize;
  if NS_FAILED(Result) then Exit;
  aProvider := prov;
  prov.FNotifyObservers := aNotifyObservers;
  Result := NS_OK;
end;

end.
