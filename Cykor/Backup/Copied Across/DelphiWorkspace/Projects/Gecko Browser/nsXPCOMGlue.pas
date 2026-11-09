unit nsXPCOMGlue;

interface

uses
  nsXPCOM, nsGeckoStrings, nsConsts;

const
  NS_XPCOM_STARTUP_OBSERVER_ID = 'xpcom-startup';
  NS_XPCOM_SHUTDOWN_OBSERVER_ID = 'xpcom-shutdown';
  NS_XPCOM_AUTOREGISTRATION_OBSERVER_ID = 'xpcom-autoregistration';

  NS_MEMORY_CONTRACTID      = '@mozilla.org/xpcom/memory-service;1';
  NS_MEMORY_CLASSNAME       = 'Global Memory Service';
  NS_MEMORY_CID: TGUID      = '{30a04e40-38e7-11d4-8cf5-0060b0fc14a3}';

  NS_XPCOM_CURRENT_PROCESS_DIR          = 'XCurProcD';
  NS_XPCOM_COMPONENT_REGISTRY_FILE      = 'ComRegF';
  NS_XPCOM_COMPONENT_DIR                = 'ComsD';
  NS_XPCOM_LIBRARY_FILE                 = 'XpcomLib';
  NS_GRE_DIR                            = 'GreD';
  NS_GRE_COMPONENT_DIR                  = 'GreComsD';
  NS_OS_HOME_DIR                        = 'Home';
  NS_OS_DRIVE_DIR                       = 'DrvD';
  NS_OS_TEMP_DIR                        = 'TmpD';
  NS_OS_CURRENT_PROCESS_DIR             = 'CurProcD';
  NS_OS_CURRENT_WORKING_DIR             = 'CurWorkD';
  NS_OS_SYSTEM_DIR                      = 'SysD';
  NS_WIN_WINDOWS_DIR                 = 'WinD';
  NS_WIN_HOME_DIR                    = 'Home';
  NS_WIN_DESKTOP_DIR                 = 'DeskV';// virtual folder at the root of the namespace
  NS_WIN_PROGRAMS_DIR                = 'Progs';
  NS_WIN_CONTROLS_DIR                = 'Cntls';
  NS_WIN_PRINTERS_DIR                = 'Prnts';
  NS_WIN_PERSONAL_DIR                = 'Pers';
  NS_WIN_FAVORITES_DIR               = 'Favs';
  NS_WIN_STARTUP_DIR                 = 'Strt';
  NS_WIN_RECENT_DIR                  = 'Rcnt';
  NS_WIN_SEND_TO_DIR                 = 'SndTo';
  NS_WIN_BITBUCKET_DIR               = 'Buckt';
  NS_WIN_STARTMENU_DIR               = 'Strt';
  NS_WIN_DESKTOP_DIRECTORY           = 'DeskP';// file sys dir which physically stores objects on desktop
  NS_WIN_DRIVES_DIR                  = 'Drivs';
  NS_WIN_NETWORK_DIR                 = 'NetW';
  NS_WIN_NETHOOD_DIR                 = 'netH';
  NS_WIN_FONTS_DIR                   = 'Fnts';
  NS_WIN_TEMPLATES_DIR               = 'Tmpls';
  NS_WIN_COMMON_STARTMENU_DIR        = 'CmStrt';
  NS_WIN_COMMON_PROGRAMS_DIR         = 'CmPrgs';
  NS_WIN_COMMON_STARTUP_DIR          = 'CmStrt';
  NS_WIN_COMMON_DESKTOP_DIRECTORY    = 'CmDeskP';
  NS_WIN_APPDATA_DIR                 = 'AppData';
  NS_WIN_PRINTHOOD                   = 'PrntHd';
  NS_WIN_COOKIES_DIR                 = 'CookD';

  NS_APP_APPLICATION_REGISTRY_FILE    = 'AppRegF';
  NS_APP_APPLICATION_REGISTRY_DIR     = 'AppRegD';
  NS_APP_DEFAULTS_50_DIR              = 'DefRt';         // The root dir of all defaults dirs
  NS_APP_PREF_DEFAULTS_50_DIR         = 'PrfDef';
  NS_APP_PROFILE_DEFAULTS_50_DIR      = 'profDef';       // The profile defaults of the "current"
                                                         // locale. Should be first choice.
  NS_APP_PROFILE_DEFAULTS_NLOC_50_DIR = 'ProfDefNoLoc';  // The profile defaults of the "default"
                                                         // installed locale. Second choice
                                                         // when above is not available.
  NS_APP_USER_PROFILES_ROOT_DIR       = 'DefProfRt';     // The dir where user profile dirs get created.
  NS_APP_RES_DIR                      = 'ARes';
  NS_APP_CHROME_DIR                   = 'AChrom';
  NS_APP_PLUGINS_DIR                  = 'APlugns';       // Deprecated - use NS_APP_PLUGINS_DIR_LIST
  NS_APP_SEARCH_DIR                   = 'SrchPlugns';
  NS_APP_PLUGINS_DIR_LIST             = 'APluginsDL';
  NS_APP_PREFS_50_DIR                 = 'PrefD';         // Directory which contains user prefs
  NS_APP_PREFS_50_FILE                = 'PrefF';
  NS_APP_USER_PROFILE_50_DIR          = 'ProfD';
  NS_APP_USER_CHROME_DIR              = 'UChrm';
  NS_APP_LOCALSTORE_50_FILE           = 'LclSt';
  NS_APP_HISTORY_50_FILE              = 'UHist';
  NS_APP_USER_PANELS_50_FILE          = 'UPnls';
  NS_APP_USER_MIMETYPES_50_FILE       = 'UMimTyp';
  NS_APP_BOOKMARKS_50_FILE            = 'BMarks';
  NS_APP_DOWNLOADS_50_FILE            = 'DLoads';
  NS_APP_SEARCH_50_FILE               = 'SrchF';
  NS_APP_MAIL_50_DIR                  = 'MailD';
  NS_APP_IMAP_MAIL_50_DIR             = 'IMapMD';
  NS_APP_NEWS_50_DIR                  = 'NewsD';
  NS_APP_MESSENGER_FOLDER_CACHE_50_DIR= 'MFCaD';
  NS_APP_INSTALL_CLEANUP_DIR          = 'XPIClnupD';  //location of xpicleanup.dat xpicleanup.exe

function NS_CreateInstance(const CID, IID: TGUID; out Intf): Longword; overload;
function NS_CreateInstance(ContractID: PAnsiChar; const IID: TGUID; out Intf): Longword; overload;
function NS_GetWeakReference(Instance: nsISupports; out ErrorCode: Longword): nsIWeakReference;
function NS_GetInterface(Source: nsISupports; const IID: TGUID; out Instance): Longword;
function NS_GetService(const CID, IID: TGUID; out Intf): Longword; overload;
function NS_GetService(ContractID: PAnsiChar; const IID: TGUID; out Intf): Longword; overload;
function NS_GetSpecialDirectory(const specialDirName: PAnsiChar; out _Result: nsIFile): Longword;

function XPCOMGlueStartup(xpcomFile: String): Longword;
function XPCOMGlueShutdown: Longword;

function GRE_Startup: Longword;
function GRE_Shutdown: Longword;

function NS_InitXPCOM2(out servMgr: nsIServiceManager; binDir: nsIFile; appFileLocationProvider: nsIDirectoryServiceProvider): Longword; cdecl;
function NS_ShutdownXPCOM(servMgr: nsIServiceManager): Longword; cdecl;
function NS_GetServiceManager(out servMgr: nsIServiceManager): Longword; cdecl;
function NS_GetComponentManager(out compMgr: nsIComponentManager): Longword; cdecl;
function NS_GetComponentRegistrar(out compReg: nsIComponentRegistrar): Longword; cdecl;
function NS_GetMemoryManager(out memMgr: nsIMemory): Longword; cdecl;
function NS_NewLocalFile(const Path: nsAString; FollowLinks: LongBool; out newFile: nsILocalFile): Longword; cdecl;
function NS_NewNativeLocalFile(const Path: nsACString; FollowLinks: LongBool; out newFile: nsILocalFile): Longword; cdecl;
{$IF MOZILLA_VERSION >= 1.5}
function NS_GetDebug(out debug: nsIDebug): Longword; cdecl;
function NS_GetTraceRefcnt(out traceRefcnt: nsITraceRefcnt): Longword; cdecl;
{$IFEND}
{$IF MOZILLA_VERSION >= 1.7}

type
  PLongBool = ^LongBool;

function NS_StringContainerInit(var aContainer: nsStringContainer): Longword; cdecl;
procedure NS_StringContainerFinish(var aContainer: nsStringContainer); cdecl;
function NS_StringGetData(const aStr: nsAString; out aData: PWideChar; aTerminated: PLongBool=nil): Longword; cdecl;
function NS_StringCloneData(const aStr: nsAString): PWideChar; cdecl;
procedure NS_StringSetData(aStr: nsAString; const aData: PWideChar; aDataLength: Longword = High(Longword)); cdecl;
procedure NS_StringSetDataRange(aStr: nsAString; aCutOffset, aCutLength: Longword; const aData: PWideChar; aDataLength: Longword = High(Longword)); cdecl;
procedure NS_StringCopy(aDestStr: nsAString; const aSrcStr: nsAString); cdecl;
procedure NS_StringAppendData(aStr: nsAString; const aData: PWideChar; aDataLength: Longword = High(Longword));
procedure NS_StringInsertData(aStr: nsAString; aOffSet: Longword; const aData: PWideChar; aDataLength: Longword = High(Longword));
procedure NS_StringCutData(aStr: nsAString; aCutOffset, aCutLength: Longword);

function NS_CStringContainerInit(var aContainer: nsCStringContainer): Longword; cdecl;
procedure NS_CStringContainerFinish(var aContainer: nsCStringContainer); cdecl;
function NS_CStringGetData(const aStr: nsACString; out aData: PAnsiChar; aTerminated: PLongBool=nil): Longword; cdecl;
function NS_CStringCloneData(const aStr: nsACString): PAnsiChar; cdecl;
procedure NS_CStringSetData(aStr: nsACString; const aData: PAnsiChar; aDataLength: Longword = High(Longword)); cdecl;
procedure NS_CStringSetDataRange(aStr: nsACString; aCutOffset, aCutLength: Longword; const aData: PAnsiChar; aDataLength: Longword = High(Longword)); cdecl;
procedure NS_CStringCopy(aDestStr: nsACString; const aSrcStr: nsACString); cdecl;
procedure NS_CStringAppendData(aStr: nsACString; const aData: PAnsiChar; aDataLength: Longword = High(Longword));
procedure NS_CStringInsertData(aStr: nsACString; aOffSet: Longword; const aData: PAnsiChar; aDataLength: Longword = High(Longword));
procedure NS_CStringCutData(aStr: nsACString; aCutOffset, aCutLength: Longword);

type
  nsSourceEncoding = ( NS_ENCODING_ASCII = 0,
                       NS_ENCODING_UTF8 = 1,
                       NS_ENCODING_NATIVE_FILESYSTEM = 2);

function NS_CStringToUTF16(const aSource: nsACString; aSrcEncoding: nsSourceEncoding; aDest: nsAString): Longword; cdecl;
function NS_UTF16ToCString(const aSource: nsAString; aSrcEncoding: nsSourceEncoding; aDest: nsACString): Longword; cdecl;
{$IFEND}

const
  PREF_INVALID = 0;
  PREF_STRING = 32;
  PREF_INT = 64;
  PREF_BOOL = 128;

  NS_PREFLOCALIZEDSTRING_CID: TGUID = '{064d9cee-1dd2-11b2-83e3-d25ab0193c26}';
  NS_PREFLOCALIZEDSTRING_CONTRACTID = '@mozilla.org/pref-localizedstring;1';
  NS_PREFLOCALIZEDSTRING_CLASSNAME  = 'Pref LocalizedString';

  NS_PREFSERVICE_CID: TGUID     = '{1cd91b88-1dd2-11b2-92e1-ed22ed298000}';
  NS_PREFSERVICE_CONTRACTID     = '@mozilla.org/preferences-service;1';
  NS_PREFSERVICE_CLASSNAME      = 'Preferences Server';
  NS_PREFSERVICE_RESET_TOPIC_ID = 'prefservice:before-reset';

  STATUS_UNKNOWN=0;
  STATUS_ACCEPTED=1;
  STATUS_DOWNGRADED=2;
  STATUS_FLAGGED=3;
  STATUS_REJECTED=4;
  POLICY_UNKNOWN=0;
  POLICY_NONE=1;
  POLICY_NO_CONSENT=2;
  POLICY_IMPLICIT_CONSENT=3;
  POLICY_EXPLICIT_CONSENT=4;
  POLICY_NO_II=5;

  NS_COOKIEPROMPTSERVICE_CONTRACTID  = '@mozilla.org/embedcomp/cookieprompt-service;1';

  NS_WINDOWWATCHER_CONTRACTID = '@mozilla.org/embedcomp/window-watcher;1';

  NS_WEBBROWSER_CID: TGUID = '{f1eac761-87e9-11d3-af80-00a024ffc08c}';
  NS_WEBBROWSER_CONTRACTID = '@mozilla.org/embedding/browser/nsWebBrowser;1';

  STATUS_SCRIPT         = $00000001;
  STATUS_SCRIPT_DEFAULT = $00000002;
  STATUS_LINK           = $00000003;
  CHROME_DEFAULT          = $00000001;
  CHROME_WINDOW_BORDERS   = $00000002;
  CHROME_WINDOW_CLOSE     = $00000004;
  CHROME_WINDOW_RESIZE    = $00000008;
  CHROME_MENUBAR          = $00000010;
  CHROME_TOOLBAR          = $00000020;
  CHROME_LOCATIONBAR      = $00000040;
  CHROME_STATUSBAR        = $00000080;
  CHROME_PERSONAL_TOOLBAR = $00000100;
  CHROME_SCROLLBARS       = $00000200;
  CHROME_TITLEBAR         = $00000400;
  CHROME_EXTRA            = $00000800;
  CHROME_WITH_SIZE        = $00001000;
  CHROME_WITH_POSITION    = $00002000;
  CHROME_WINDOW_MIN       = $00004000;
  CHROME_WINDOW_POPUP     = $00008000;
  CHROME_WINDOW_RAISED    = $02000000;
  CHROME_WINDOW_LOWERED   = $04000000;
  CHROME_CENTER_SCREEN    = $08000000;
  CHROME_DEPENDENT        = $10000000;
  CHROME_MODAL            = $20000000;
  CHROME_OPENAS_DIALOG    = $40000000;
  CHROME_OPENAS_CHROME    = $80000000;
  CHROME_ALL              = $00000ffe;

  SETUP_ALLOW_PLUGINS         = 1;
  SETUP_ALLOW_JAVASCRIPT      = 2;
  SETUP_ALLOW_META_REDIRECTS  = 3;
  SETUP_ALLOW_SUBFRAMES       = 4;
  SETUP_ALLOW_IMAGES          = 5;
  SETUP_FOCUS_DOC_BEFORE_CONTENT = 6;
  SETUP_USE_GLOBAL_HISTORY    = 256;
  SETUP_IS_CHROME_WRAPPER     = 7;

  PRINTPREVIEW_GOTO_PAGENUM = 0;
  PRINTPREVIEW_PREV_PAGE    = 1;
  PRINTPREVIEW_NEXT_PAGE    = 2;
  PRINTPREVIEW_HOME         = 3;
  PRINTPREVIEW_END          = 4;

  DIM_FLAGS_POSITION   = 1;
  DIM_FLAGS_SIZE_INNER = 2;
  DIM_FLAGS_SIZE_OUTER = 4;

  CONTEXT_NONE     = 0;
  CONTEXT_LINK     = 1;
  CONTEXT_IMAGE    = 2;
  CONTEXT_DOCUMENT = 4;
  CONTEXT_TEXT     = 8;
  CONTEXT_INPUT    = 16;
  CONTEXT_BACKGROUND_IMAGE = 32;

  STATE_START          = $00000001;
  STATE_REDIRECTING    = $00000002;
  STATE_TRANSFERRING   = $00000004;
  STATE_NEGOTIATING    = $00000008;
  STATE_STOP           = $00000010;
  STATE_IS_REQUEST     = $00010000;
  STATE_IS_DOCUMENT    = $00020000;
  STATE_IS_NETWORK     = $00040000;
  STATE_IS_WINDOW      = $00080000;
  STATE_IS_INSECURE     = $00000004;
  STATE_IS_BROKEN       = $00000001;
  STATE_IS_SECURE       = $00000002;
  STATE_SECURE_HIGH     = $00040000;
  STATE_SECURE_MED      = $00010000;
  STATE_SECURE_LOW      = $00020000;

  NOTIFY_STATE_REQUEST  = $00000001;
  NOTIFY_STATE_DOCUMENT = $00000002;
  NOTIFY_STATE_NETWORK  = $00000004;
  NOTIFY_STATE_WINDOW   = $00000008;
  NOTIFY_STATE_ALL      = $0000000f;
  NOTIFY_PROGRESS       = $00000010;
  NOTIFY_STATUS         = $00000020;
  NOTIFY_SECURITY       = $00000040;
  NOTIFY_LOCATION       = $00000080;
  NOTIFY_ALL            = $000000ff;
  
implementation

uses
  nsMemory, nsError, Windows, SysUtils, StrUtils;

var
  sCompMgr: nsIComponentManager = nil;
  sSrvMgr: nsIServiceManager = nil;

function NS_CreateInstance(const CID, IID: TGUID; out Intf): Longword; overload;
begin
  Result := NS_OK;
  if not Assigned(sCompMgr) then Result := NS_GetComponentManager(sCompMgr);
  if NS_FAILED(Result) then Exit;

  if Assigned(sCompMgr) then
    Result := sCompMgr.CreateInstance(CID, nil, IID, Intf)
  else
    Result := NS_ERROR_UNEXPECTED;

  if NS_FAILED(Result) then Integer(Intf) := 0;
end;

function NS_CreateInstance(ContractID: PAnsiChar; const IID: TGUID; out Intf): Longword; overload;
begin
  Result := NS_OK;
  if not Assigned(sCompMgr) then Result := NS_GetComponentManager(sCompMgr);
  if NS_FAILED(Result) then Exit;

  if Assigned(sCompMgr) then
    Result := sCompMgr.CreateInstanceByContractID(ContractID, nil, IID, Intf)
  else
    Result := NS_ERROR_UNEXPECTED;

  if NS_FAILED(Result) then Integer(Intf) := 0;
end;

function NS_GetService(const CID, IID: TGUID; out Intf): Longword;
begin
  Result := NS_OK;
  if not Assigned(sSrvMgr) then Result := NS_GetServiceManager(sSrvMgr);
  if NS_FAILED(Result) then Exit;

  if Assigned(sSrvMgr) then
    Result := sSrvMgr.GetService(CID, IID, Intf)
  else
    Result := NS_ERROR_UNEXPECTED;

  if NS_FAILED(Result) then Integer(Intf) := 0;
end;

function NS_GetService(ContractID: PAnsiChar; const IID: TGUID; out Intf): Longword;
begin
  Result := NS_OK;
  if not Assigned(sSrvMgr) then Result := NS_GetServiceManager(sSrvMgr);
  if NS_FAILED(Result) then Exit;

  if Assigned(sSrvMgr) then
    Result := sSrvMgr.GetServiceByContractID(ContractID, IID, Intf)
  else
    Result := NS_ERROR_UNEXPECTED;

  if NS_FAILED(Result) then Integer(Intf) := 0;
end;

function NS_GetSpecialDirectory(const specialDirName: PAnsiChar; out _result: nsIFile): Longword;
var
  serv: nsIProperties;
const
  NS_DIRECTORY_SERVICE_CID: TGUID = '{f00152d0-b40b-11d3-8c9c-000064657374}';
begin
  Result := NS_GetService(NS_DIRECTORY_SERVICE_CID, nsIProperties, serv);
  if NS_FAILED(Result) then Exit;

  Result := serv.Get(specialDirName, nsIFile, _result);
end;

function NS_GetWeakReference(Instance: nsISupports; out ErrorCode: Longword): nsIWeakReference;
var
  factory: nsISupportsWeakReference;
begin
  Result := nil;

  if Assigned(Instance) then
  begin
    factory := Instance as nsISupportsWeakReference;
    if Assigned(factory) then
    begin
      ErrorCode := factory.GetWeakReference(Result);
    end;
  end else
    ErrorCode := NS_ERROR_NULL_POINTER;
end;

function NS_GetInterface(Source: nsISupports; const IID: TGUID; out Instance): Longword;
var
  factory: nsIInterfaceRequestor;
begin
  if Assigned(Source) then
  begin
    factory := Source as nsIInterfaceRequestor;
    Result := factory.GetInterface(IID, Instance);
    if NS_FAILED(Result) then Integer(Instance) := 0;
  end else
    Result := NS_ERROR_NULL_POINTER;
end;

type
  nsGREDirServiceProvider = class(TInterfacedObject,
                                  nsIDirectoryServiceProvider)
    FPathEnvString: String;
    constructor Create;
    //destructor Destroy; override;
    function GetFile(const Prop: PChar; out persistent: LongBool; out _retval: nsIFile): Longword; stdcall;
    function GetGreDirectory(out aLocalFile: nsILocalFile): Longword;
    procedure AddGRELocatoinToPath;
  end;

function GetXPCOMPath: String; forward;
function GetGREDirectoryPath: String; forward;
function GetPathFromConfigDir(dirname: String): String; forward;
function GetPathFromConfigFile(filename: String): String; forward;

constructor nsGREDirServiceProvider.Create;
begin
  inherited;
  AddGRELocatoinToPath;
end;

(*destructor nsGREDirServiceProvider.Destroy;
begin
  inherited;
end;*)

function nsGREDirServiceProvider.GetFile(const Prop: PChar; out Persistent: LongBool; out _retval: nsIFile): Longword;
var
  localFile: nsILocalFile;
begin
  Result := NS_ERROR_FAILURE;

  persistent := True;

  if Prop = NS_GRE_DIR then
  begin
    Result := GetGreDirectory(localFile);
  end;

  if NS_FAILED(Result) then Exit;

  Result := localFile.QueryInterface(nsIFile, _retval);
end;

function GetCurrentProccessDirectory: String;
var
  buf: array [0..MAX_PATH-1] of Char;
begin
  if SUCCEEDED(GetModuleFileName(0, buf, SizeOf(buf))) then
  begin
    Result := ExtractFileDir(buf);
    Exit;
  end;
end;

type
  TGREVersion = record
    major: Integer;
    minor: Integer;
    revision: Integer;
    date: Integer;
  end;

function GetGREVersion(verStr: String): TGREVersion;
var
  before, after: String;
  idx, idx2: Integer;
  major, minor, revision, date: Integer;
begin
  ZeroMemory(@Result, SizeOf(Result));

  // major version
  idx := AnsiPos('.', verStr);
  if idx=0 then Exit;
  before := LeftStr(verStr, idx-1);
  after := MidStr(verStr, idx+1, High(Integer));
  major := StrToInt(before);

  // minor version
  idx := AnsiPos('.', after);
  idx2:= AnsiPos('_', after);
  if (idx>0) and (idx2>idx) then idx2:=idx;
  if idx2=0 then Exit;
  before := LeftStr(after, idx2-1);
  minor := StrToInt(before);

  // revision
  if idx<>0 then
  begin
    after := MidStr(after, idx+1, High(Integer));
    idx := AnsiPos('_', after);
    before := LeftStr(after, idx-1);
    after := MidStr(after, idx+1, High(Integer));
    revision := StrToInt(before);
  end else
  begin
    revision := 0;
    idx := AnsiPos('_', after);
    after := MidStr(after, idx+1, High(Integer));
  end;
  date := StrToInt(after);
  Result.major := major;
  Result.minor := minor;
  Result.revision := revision;
  Result.date := date;
end;

function GREVersionCompare(const lhs, rhs: TGREVersion): Integer;
begin
  Result := lhs.major - rhs.major;
  if Result<>0 then Exit;
  Result := lhs.minor - rhs.minor;
  if Result<>0 then Exit;
  Result := lhs.revision - rhs.revision;
  if Result<>0 then Exit;
  Result := lhs.date - rhs.date;
end;

function GetLatestGreLocation: String;
const
  nameBase = 'Software\mozilla.org\GRE';
var
  i: DWORD;
  rv: HRESULT;
  base, curKey: HKEY;
  //cuLast, lmLast: String;
  cuPath, lmPath: String;
  keyName: array[0..MAX_PATH] of Char;
  path: array[0..MAX_PATH] of Char;
  dwSize: DWORD;
  ver: TGREVersion;
  cuVer, lmVer: TGREVersion;
  reqVer: TGREVersion;
label
  NoLocalMachine,
  NoCurrentUser;
begin
  ZeroMemory(@cuVer, SizeOf(cuVer));
  ZeroMemory(@lmVer, SizeOf(lmVer));
  reqVer := GetGREVersion(GRE_BUILD_ID);
  
  rv := RegOpenKey(HKEY_LOCAL_MACHINE, nameBase, base);
  if rv<>0 then goto NoLocalMachine;
  i := 0;
  dwSize := MAX_PATH;
  rv := RegEnumKeyEx(base, i, keyName, dwSize, nil, nil, nil, nil);
  while rv=0 do
  begin
    rv := RegOpenKey(base, PChar(@keyName), curKey);
    if rv=0 then
    begin
      dwSize := MAX_PATH;
      rv := RegQueryValueEx(curKey, 'GreHome', nil, nil, PByte(@path), @dwSize);
      if rv=0 then
      begin
        ver := GetGREVersion(keyName);
        if (GREVersionCompare(ver, reqVer)>=0) and
           (GREVersionCompare(ver, lmVer)>=0) and
           FileExists(path+'\xpcom.dll') then
        begin
          //lmLast := keyName;
          lmPath := path;
          lmVer := ver;
        end;
      end;
      RegCloseKey(curKey);
    end;
    Inc(i);
    dwSize := MAX_PATH;
    rv := RegEnumKeyEx(base, i, keyName, dwSize, nil, nil, nil, nil);
  end;
  RegCloseKey(base);
NoLocalMachine:;
  rv := RegOpenKey(HKEY_CURRENT_USER, nameBase, base);
  if rv<>0 then goto NoCurrentUser;
  i := 0;
  dwSize := MAX_PATH;
  rv := RegEnumKeyEx(base, i, keyName, dwSize, nil, nil, nil, nil);
  while rv=0 do
  begin
    rv := RegOpenKey(base, PChar(@keyName), curKey);
    if rv=0 then
    begin
      dwSize := MAX_PATH;
      rv := RegQueryValueEx(curKey, 'GreHome', nil, nil, PByte(@path), @dwSize);
      if rv=0 then
      begin
        ver := GetGREVersion(keyName);
        if (GREVersionCompare(ver, reqVer)>=0) and
           (GREVersionCompare(ver, cuVer)>=0) and
           FileExists(path+'\xpcom.dll') then
        begin
          //cuLast := keyName;
          cuPath := path;
          cuVer := ver;
        end;
      end;
      RegCloseKey(curKey);
    end;
    Inc(i);
    dwSize := MAX_PATH;
    rv := RegEnumKeyEx(base, i, keyName, dwSize, nil, nil, nil, nil);
  end;
  RegCloseKey(base);
NoCurrentUser:;
  //lmLast := UpperCase(lmLast);
  //cuLast := UpperCase(cuLast);
  //if (Length(lmLast)>0) or (Length(cuLast)>0) then
  if (lmVer.major>0) or (cuVer.major>0) then
  begin
    if GREVersionCompare(lmVer,cuVer)>0 then
      Result := lmPath
    else
      Result := cuPath;
    //if StrToFloat(Result)<MOZILLA_VERSION then
    //  raise Exception.Create('GREのバージョンが一致しません。');
      //Result := '';
  end else
    Result := '';
end;

function CheckoGeckoVersion(path: string): Boolean;
var
  pbuf: Pointer;
  dwSize: DWORD;
  dw: DWORD;
  pFFI: PVSFixedFileInfo;
  version: Integer;
begin
  Result := False;

  dwSize := GetFileVersionInfoSize(PChar(path), dw);
  if dwSize<=0 then Exit;

  pbuf := GetMemory(dwSize);
  if not Assigned(pbuf) then Exit;

  try
    Result := GetFileVersionInfo(PChar(path), 0, dwSize, pbuf);
    if not Result then Exit;

    Result := VerQueryValue(pbuf, '\', Pointer(pFFI), dw);
    if not Result then Exit;

    version := HIWORD(pFFI.dwFileVersionMS)*10 + LOWORD(pFFI.dwFileVersionMS);
    if version < ROund(MOZILLA_VERSION*10) then
      Result := False
    else
      Result := True;
  finally
    FreeMemory(pbuf);
  end;
end;

var
  GRELocation: String = '';

function GetGREDirectoryPath: String;
const
  GRE_REGISTRY_KEY = GRE_WIN_REG_LOC + GRE_BUILD_ID;
var
  //GRELocation: String;
  cpd: String;
  xpcomLibPath: String;
  path: String;
  greConfHomePath: String;

  szKey: String;
  hRegKey: HKEY;
  dwLength: DWORD;
  rc: Longint;
  keyValue: array [0..MAX_PATH] of Char;
  //envPath: String;
begin
  if Length(GreLocation)>0 then
  begin
    Result := GRELocation;
    Exit;
  end;

  cpd := GetCurrentProccessDirectory;
  if Length(cpd)>0 then
  begin
    xpcomLibPath := cpd + '\xpcom.dll';
    if FileExists(xpcomLibPath) {and CheckoGeckoVersion(xpcomLibPath)} then
    begin
      Result := cpd;
      Exit;
    end;
  end;

  if Length(GetEnvironmentVariable('USE_LOCAL_GRE'))>0 then Exit;

  path := GetEnvironmentVariable('HOME');
  if Length(path)>0 then
  begin
    greConfHomePath := path + '\gre.config';
    GRELocation := GetPathFromConfigFile(greConfHomePath);
    if Length(GRELocation)>0 then
    begin
      Result := GRELocation;
      Exit;
    end;
  end;

  path := GetEnvironmentVariable('MOZ_GRE_CONF');
  if Length(path)>0 then
  begin
    GRELocation := GetPathFromConfigFile(path);
    if Length(GRELocation)>0 then
    begin
      Result := GRELocation;
      Exit;
    end;
  end;

  GRELocation := GetLatestGreLocation;
  if Length(GRELocation)>0 then
  begin
    Result := GRELocation;
    Exit;
  end;
  
  //envPath := GetEnvironmentVariable('PATH');

  hRegKey := 0;
  dwLength := SizeOf(Char) * MAX_PATH;
  szKey := GRE_REGISTRY_KEY;
  if RegOpenKeyEx(HKEY_CURRENT_USER, PChar(szKey), 0, KEY_QUERY_VALUE, hRegKey) = 0 then
  begin
    rc := RegQueryValueEx(hRegKey, 'GreHome', nil, nil, PByte(@keyValue[0]), @dwLength);
    if rc=0 then GreLocation := keyValue;
    RegCloseKey(hRegKey);
  end;
  if Length(GRELocation)>0 then
  begin
    Result := GRELocation;
    //SetEnvironmentVariable('PATH', PChar(GRELocation + ';' + envPath));
    Exit;
  end;

  hRegKey := 0;
  dwLength := SizeOf(Char) * MAX_PATH;
  szKey := GRE_REGISTRY_KEY;
  if RegOpenKeyEx(HKEY_LOCAL_MACHINE, PChar(szKey), 0, KEY_QUERY_VALUE, hRegKey) = 0 then
  begin
    rc := RegQueryValueEx(hRegKey, 'GreHome', nil, nil, PByte(@keyValue[0]), @dwLength);
    if rc=0 then GreLocation := keyValue;
    RegCloseKey(hRegKey);
  end;

  if Length(GRELocation)>0 then
  begin
    Result := GRELocation;
    //SetEnvironmentVariable('PATH', PChar(GRELocation + ';' + envPath));
  end;
end;

function GetPathFromConfigDir(dirname: String): String;
var
  GRELocation: String;
  sr: TSearchRec;
  rv: Integer;
begin
  rv := FindFirst(dirname+'*.conf', faAnyFile, sr);

  if rv <>0 then Exit;

  repeat
    GRELocation := GetPathFromConfigFile(dirname+'\'+sr.Name);
  until (Length(GRELocation)>0) or (FindNext(sr)<>0);
end;

function GetPathFromConfigFile(filename: String): String;
begin
  Result := '';
end;

function nsGREDirServiceProvider.GetGreDirectory(out aLocalFile: nsILocalFile): Longword;
var
  GreDir: String;
  tempLocal: nsILocalFile;
  leaf: IInterfacedCString;
begin
  GreDir := GetGREDirectoryPath;
  try
    leaf := NewCString(GreDir);
  except
    Result := NS_ERROR_OUT_OF_MEMORY;
    Exit;
  end;
  Result := NS_NewNativeLocalFile(leaf.ACString, True, tempLocal);

  if NS_SUCCEEDED(Result) then
  begin
    Result := tempLocal.QueryInterface(nsILocalFile, aLocalFile);
  end;
end;

function GetXPCOMPath: String;
var
  grePath: String;
  greEnv: String;
  path: String;
begin
  grePath := GetGREDirectoryPath;
  if Length(grePath)=0 then
  begin
    greEnv := GetEnvironmentVariable('MOZILLA_FIVE_HOME');
    if Length(greEnv)=0 then Exit;
    grePath := greEnv;
  end;

  path := GetEnvironmentVariable('PATH');
  SetEnvironmentVariable('PATH', PChar(grePath + ';' + path));
  Result := grePath + '\xpcom.dll';
end;

procedure nsGREDirServiceProvider.AddGRELocatoinToPath;
var
  grePath: String;
  path: String;
begin
  grePath := GetGREDirectoryPath;
  if Length(grePath)=0 then Exit;

  path := GetEnvironmentVariable('PATH');

  FPathEnvString := grePath + ';' + path;

  SetEnvironmentVariable(PChar('PATH'), PChar(grePath));

  SetCurrentDir(grePath);
end;

type
  XPCOMExitRoutine = function : Longword; stdcall;

  InitFunc = function(out servMgr: nsIServiceManager; binDir: nsIFile; provider: nsIDirectoryServiceProvider): Longword; cdecl;
  ShutdownFunc = function (servMgr: nsIServiceManager): Longword; cdecl;
  GetServiceManagerFunc = function (out servMgr: nsIServiceManager): Longword; cdecl;
  GetComponentManagerFunc = function (out compMgr: nsIComponentManager): Longword; cdecl;
  GetComponentRegistrarFunc = function (out compReg: nsIComponentRegistrar): Longword; cdecl;
  GetMemoryManagerFunc = function (out memMgr: nsIMemory): Longword; cdecl;
  NewLocalFileFunc = function (const path: nsAString; followLinks: LongBool; out newFile: nsILocalFile): Longword; cdecl;
  NewNativeLocalFileFunc = function (const path: nsACString; followLinks: LongBool; out newFile: nsILocalFile): Longword; cdecl;
  RegisterXPCOMExitRoutineFunc = function (exitRoutine: XPCOMExitRoutine; proproty: Longword): Longword; cdecl;
  UnregisterXPCOMExitRoutineFunc = function (exitRoutine: XPCOMExitRoutine): Longword; cdecl;
{$IF MOZILLA_VERSION >= 1.5}
  GetDebugFunc = function (out debug: nsIDebug): Longword; cdecl;
  GetTraceRefcntFunc = function (out traceRefcnt: nsITraceRefcnt): Longword; cdecl;
{$IFEND}
{$IF MOZILLA_VERSION >= 1.7}
  StringContainerInitFunc = function (var container: nsStringContainer): Longword; cdecl;
  StringContainerFinishFunc = procedure (var container: nsStringContainer); cdecl;
  StringGetDataFunc = function (const str: nsAString; out data: PWideChar; aTerminated: PLongBool): Longword; cdecl;
  StringCloneDataFunc = function (const str: nsAString): PWideChar; cdecl;
  StringSetDataFunc = procedure (str: nsAString; const data: PWideChar; length: Longword); cdecl;
  StringSetDataRangeFunc = procedure (str: nsAString; aCutOffset, aCutLength: Longword; const data: PWideChar; length: Longword); cdecl;
  StringCopyFunc = procedure (dst: nsAString; const src: nsAString); cdecl;

  CStringContainerInitFunc = function (var container: nsCStringContainer): Longword; cdecl;
  CStringContainerFinishFunc = procedure (var container: nsCStringContainer); cdecl;
  CStringGetDataFunc = function (const str: nsACString; out data: PAnsiChar; aTerminated: PLongBool): Longword; cdecl;
  CStringCloneDataFunc = function (const str: nsACString): PAnsiChar; cdecl;
  CStringSetDataFunc = procedure (str: nsACString; const data: PAnsiChar; length: Longword); cdecl;
  CStringSetDataRangeFunc = procedure (str: nsACString; aCutOffset, aCutLength: Longword; const data: PAnsiChar; length: Longword); cdecl;
  CStringCopyFunc = procedure (dst: nsACString; const src: nsACString); cdecl;

  CStringToUTF16Func = function (const src: nsACString; encoding: nsSourceEncoding; dst: nsAString): Longword; cdecl;
  UTF16ToCStringFunc = function (const src: nsAString; encoding: nsSourceEncoding; dst: nsACString): Longword; cdecl;
{$IFEND}

  XPCOMFunctions = record
    version: Longword;
    size: Longword;

    init: InitFunc;
    shutdown: ShutdownFunc;
    getServiceManager: GetServiceManagerFunc;
    getComponentManager: GetComponentManagerFunc;
    getComponentRegistrar: GetComponentRegistrarFunc;
    getMemoryManager: GetMemoryManagerFunc;
    newLocalFile: NewLocalFileFunc;
    newNativeLocalFile: NewNativeLocalFileFunc;

    registerXPCOMExitRoutine: RegisterXPCOMExitRoutineFunc;
    unregisterXPCOMExitRoutine: UnregisterXPCOMExitRoutineFunc;
{$IF MOZILLA_VERSION >= 1.5}
    getDebug: GetDebugFunc;
    getTraceRefCnt: GetTraceRefCntFunc;
{$IFEND}
{$IF MOZILLA_VERSION >= 1.7}
    stringContainerInit: StringContainerInitFunc;
    stringContainerFinish: StringContainerFinishFunc;
    stringGetData: StringGetDataFunc;
    stringSetData: StringSetDataFunc;
    stringSetDataRange: StringSetDataRangeFunc;
    stringCopy: StringCopyFunc;
    cstringContainerInit: CStringContainerInitFunc;
    cstringContainerFinish: CStringContainerFinishFunc;
    cstringGetData: CStringGetDataFunc;
    cstringSetData: CStringSetDataFunc;
    cstringSetDataRange: CStringSetDataRangeFunc;
    cstringCopy: CStringCopyFunc;
    cstringToUTF16: CStringToUTF16Func;
    UTF8ToCString: UTF16ToCStringFunc;
    stringCloneData: StringCloneDataFunc;
    cstringCloneData: CStringCloneDataFunc;
{$IFEND}
  end;

  GetFrozenFunctionsFunc = function(out enrtyPoints: XPCOMFunctions; libraryPath: PAnsiChar): Longword; cdecl;

var
  xpcomFunc: ^XPCOMFunctions;
  xpcomLib: HMODULE;

function XPCOMGlueStartup(xpcomFile: String): Longword;
var
  path: String;
  func: GetFrozenFunctionsFunc;
begin
  Result := NS_ERROR_FAILURE;

  if Length(xpcomFile)>0 then
    path := xpcomFile
  else
    path := 'xpcom.dll';

  xpcomLib := LoadLibrary(PChar(path));

  if xpcomLib=0 then Exit;

  func := GetProcAddress(xpcomLib, PChar('NS_GetFrozenFunctions'));

  if not Assigned(func) then
  begin
    FreeLibrary(xpcomLib);
    xpcomLib := 0;
    Exit;
  end;

  xpcomFunc := GetMemory(SizeOf(XPCOMFunctions));
  if not Assigned(xpcomFunc) then
  begin
    FreeLibrary(xpcomLib);
    xpcomLib := 0;
    Exit;
  end;

  ZeroMemory(xpcomFunc, SizeOf(XPCOMFunctions));
  xpcomFunc.version := 1;
  xpcomFunc.size := SizeOf(XPCOMFunctions);

  Result := func(xpcomFunc^, PChar(path));

  if NS_FAILED(Result) then
  begin
    FreeLibrary(xpcomLib);
    xpcomLib := 0;
    FreeMemory(xpcomFunc);
    xpcomFunc := nil;
    Exit;
  end;

  (*Result := GlueStartupDebug;

  if NS_FAILED(Result) then
  begin
    FreeLibrary(xpcomLib);
    xpcomLib := 0;
    FreeMemory(xpcomFunc);
    xpcomFunc := nil;
    Exit;
  end;*)

  Result := GlueStartupMemory;

  if NS_FAILED(Result) then
  begin
    //GlueShutdownDebug;
    FreeLibrary(xpcomLib);
    xpcomLib := 0;
    FreeMemory(xpcomFunc);
    xpcomFunc := nil;
    Exit;
  end;
end;

function XPCOMGlueShutdown: Longword;
begin
  GlueShutdownMemory;
  //GlueShutdownDebug;

  FreeLibrary(xpcomLib);
  xpcomLib := 0;

  FreeMemory(xpcomFunc);
  xpcomFunc := nil;

  Result := NS_OK;
end;

function NS_InitXPCOM2(out servMgr: nsIServiceManager;
                       binDir: nsIFile;
                       appFileLocationProvider: nsIDirectoryServiceProvider): Longword;
begin
  if Assigned(xpcomFunc) then
    Result := xpcomFunc.init(servMgr, binDir, appFileLocationProvider)
  else
    Result := NS_ERROR_FAILURE;
end;

function NS_ShutdownXPCOM(servMgr: nsIServiceManager): Longword;
begin
  if Assigned(xpcomFunc) then
    Result := xpcomFunc.shutdown(servMgr)
  else
    Result := NS_ERROR_FAILURE;
end;

function NS_GetServiceManager(out servMgr: nsIServiceManager): Longword;
begin
  if Assigned(xpcomFunc) then
    Result := xpcomFunc.getServiceManager(servMgr)
  else
    Result := NS_ERROR_FAILURE;
end;

function NS_GetComponentManager(out compMgr: nsIComponentManager): Longword;
begin
  if Assigned(xpcomFunc) then
    Result := xpcomFunc.getComponentManager(compMgr)
  else
    Result := NS_ERROR_FAILURE;
end;

function NS_GetComponentRegistrar(out compReg: nsIComponentRegistrar): Longword;
begin
  if Assigned(xpcomFunc) then
    Result := xpcomFunc.getComponentRegistrar(compReg)
  else
    Result := NS_ERROR_FAILURE;
end;

function NS_GetMemoryManager(out memMgr: nsIMemory): Longword;
begin
  if Assigned(xpcomFunc) then
    Result := xpcomFunc.getMemoryManager(memMgr)
  else
    Result := NS_ERROR_FAILURE;
end;

function NS_NewLocalFile(const path: nsAString;
                         followLinks: LongBool;
                         out newFile: nsILocalFile): Longword;
begin
  if Assigned(xpcomFunc) then
    Result := xpcomFunc.newLocalFile(path, followLinks, newFile)
  else
    Result := NS_ERROR_FAILURE;
end;

function NS_NewNativeLocalFile(const path: nsACString;
                               followLinks: LongBool;
                               out newFile: nsILocalFile): Longword;
begin
  if Assigned(xpcomFunc) then
    Result := xpcomFunc.newNativeLocalFile(path, followLinks, newFile)
  else
    Result := NS_ERROR_FAILURE;
end;

function NS_RegisterXPCOMExitRoutine(exitRoutine: XPCOMExitRoutine;
                                     priority: Longword): Longword;
begin
  if Assigned(xpcomFunc) then
    Result := xpcomFunc.registerXPCOMExitRoutine(exitRoutine, priority)
  else
    Result := NS_ERROR_FAILURE;
end;

function NS_UnregisterXPCOMExitRoutine(exitRoutine: XPCOMExitRoutine): Longword;
begin
  if Assigned(xpcomFunc) then
    Result := xpcomFunc.unregisterXPCOMExitRoutine(exitRoutine)
  else
    Result := NS_ERROR_FAILURE;
end;

{$IF MOZILLA_VERSION >= 1.5}
function NS_GetDebug(out debug: nsIDebug): Longword;
begin
  if Assigned(xpcomFunc) then
    Result := xpcomFunc.getDebug(debug)
  else
    Result := NS_ERROR_FAILURE;
end;

function NS_GetTraceRefcnt(out traceRefcnt: nsITraceRefcnt): Longword;
begin
  if Assigned(xpcomFunc) then
    Result := xpcomFunc.getTraceRefCnt(traceRefcnt)
  else
    Result := NS_ERROR_FAILURE;
end;
{$IFEND}
{$IF MOZILLA_VERSION >= 1.7}
function NS_StringContainerInit(var aContainer: nsStringContainer): Longword;
begin
  if Assigned(xpcomFunc) then
    Result := xpcomFunc.stringContainerInit(aContainer)
  else
    Result := NS_ERROR_FAILURE;
end;

procedure NS_StringContainerFinish(var aContainer: nsStringContainer);
begin
  if Assigned(xpcomFunc) then
    xpcomFunc.stringContainerFinish(aContainer);
end;

function NS_StringGetData(const aStr: nsAString; out aData: PWideChar; aTerminated: PLongBool): Longword;
begin
  if Assigned(xpcomFunc) then
    Result := xpcomFunc.stringGetData(aStr, aData, aTerminated)
  else
    Result := 0;
end;

procedure NS_StringSetData(aStr: nsAString; const aData: PWideChar; aDataLength: Longword);
begin
  if Assigned(xpcomFunc) then
    xpcomFunc.stringSetData(aStr, aData, aDataLength);
end;

procedure NS_StringSetDataRange(aStr: nsAString; aCutOffset, aCutLength: Longword; const aData: PWideChar; aDataLength: Longword);
begin
  if Assigned(xpcomFunc) then
    xpcomFunc.stringSetDataRange(aStr, aCutOffset, aCutLength, aData, aDataLength);
end;

procedure NS_StringCopy(aDestStr: nsAString; const aSrcStr: nsAString);
begin
  if Assigned(xpcomFunc) then
    xpcomFunc.stringCopy(aDestStr, aSrcStr);
end;

procedure NS_StringAppendData(aStr: nsAString; const aData: PWideChar; aDataLength: Longword);
begin
  NS_StringSetDataRange(aStr, High(Longword), 0, aData, aDataLength);
end;

procedure NS_StringInsertData(aStr: nsAString; aOffSet: Longword; const aData: PWideChar; aDataLength: Longword);
begin
  NS_StringSetDataRange(aStr, aOffset, 0, aData, aDataLength);
end;

procedure NS_StringCutData(aStr: nsAString; aCutOffset, aCutLength: Longword);
begin
  NS_StringSetDataRange(aStr, aCutOffset, aCutLength, nil, 0);
end;

function NS_CStringContainerInit(var aContainer: nsCStringContainer): Longword;
begin
  if Assigned(xpcomFunc) then
    Result := xpcomFunc.cstringContainerInit(aContainer)
  else
    Result := NS_ERROR_FAILURE;
end;

procedure NS_CStringContainerFinish(var aContainer: nsCStringContainer);
begin
  if Assigned(xpcomFunc) then
    xpcomFunc.cstringContainerFinish(aContainer);
end;

function NS_CStringGetData(const aStr: nsACString; out aData: PAnsiChar; aTerminated: PLongBool): Longword;
begin
  if Assigned(xpcomFunc) then
    Result := xpcomFunc.cstringGetData(aStr, aData, aTerminated)
  else
    Result := 0;
end;

procedure NS_CStringSetData(aStr: nsACString; const aData: PAnsiChar; aDataLength: Longword);
begin
  if Assigned(xpcomFunc) then
    xpcomFunc.cstringSetData(aStr, aData, aDataLength);
end;

procedure NS_CStringSetDataRange(aStr: nsACString; aCutOffset, aCutLength: Longword; const aData: PAnsiChar; aDataLength: Longword);
begin
  if Assigned(xpcomFunc) then
    xpcomFunc.cstringSetDataRange(aStr, aCutOffset, aCutLength, aData, aDataLength);
end;

procedure NS_CStringCopy(aDestStr: nsACString; const aSrcStr: nsACString);
begin
  if Assigned(xpcomFunc) then
    xpcomFunc.cstringCopy(aDestStr, aSrcStr);
end;

procedure NS_CStringAppendData(aStr: nsACString; const aData: PAnsiChar; aDataLength: Longword);
begin
  NS_CStringSetDataRange(aStr, High(Longword), 0, aData, aDataLength);
end;

procedure NS_CStringInsertData(aStr: nsACString; aOffSet: Longword; const aData: PAnsiChar; aDataLength: Longword);
begin
  NS_CStringSetDataRange(aStr, aOffset, 0, aData, aDataLength);
end;

procedure NS_CStringCutData(aStr: nsACString; aCutOffset, aCutLength: Longword);
begin
  NS_CStringSetDataRange(aStr, aCutOffset, aCutLength, nil, 0);
end;

function NS_CStringToUTF16(const aSource: nsACString; aSrcEncoding: nsSourceEncoding; aDest: nsAString): Longword;
begin
  if Assigned(xpcomFunc) and Assigned(xpcomFunc.cstringToUTF16) then
    Result := xpcomFunc.cstringToUTF16(aSource, aSrcEncoding, aDest)
  else
    Result := NS_ERROR_FAILURE;
end;

function NS_UTF16ToCString(const aSource: nsAString; aSrcEncoding: nsSourceEncoding; aDest: nsACString): Longword;
begin
  if Assigned(xpcomFunc) and Assigned(xpcomFunc.UTF8ToCString) then
    Result := xpcomFunc.UTF8ToCString(aSource, aSrcEncoding, aDest)
  else
    Result := NS_ERROR_FAILURE;
end;

function NS_StringCloneData(const aStr: nsAString): PWideChar;
begin
  if Assigned(xpcomFunc) and Assigned(xpcomFunc.stringCloneData) then
    Result := xpcomFunc.stringCloneData(aStr)
  else
    Result := nil;
end;

function NS_CStringCloneData(const aStr: nsACString): PAnsiChar;
begin
  if Assigned(xpcomFunc) and Assigned(xpcomFunc.cstringCloneData) then
    Result := xpcomFunc.cstringCloneData(aStr)
  else
    Result := nil;
end;

{$IFEND}

var
  sStartupCount: Integer = 0;

function GRE_Startup: Longword;
var
  xpcomLocation: String;
  provider: nsGREDirServiceProvider;
  servMgr: nsIServiceManager;
begin
  Result := NS_OK;

  if sStartupCount > 0 then
  begin
    Inc(sStartupCount);
    Exit;
  end;

  xpcomLocation := GetXPCOMPath;

  Result := XPCOMGlueStartup(xpcomLocation);

  if NS_FAILED(Result) then Exit;

  provider := nsGREDirServiceProvider.Create;
  if not Assigned(provider) then
  begin
    Result := NS_ERROR_OUT_OF_MEMORY;
    XPCOMGlueShutdown;
    Exit;
  end;

  provider._AddRef;
  Result := NS_InitXPCOM2(servMgr, nil, provider);
  provider._Release;

  if NS_FAILED(Result) then
  begin
    XPCOMGlueShutdown;
    Exit;
  end;
  Inc(sStartupCount);
end;

function GRE_Shutdown: Longword;
begin
  Dec(sStartupCount);

  if sStartupCount=0 then
  begin
    NS_ShutdownXPCOM(nil);
    XPCOMGlueShutdown;
  end else
  if sStartupCount<0 then sStartupCount := 0;

  Result := NS_OK;
end;

end.
