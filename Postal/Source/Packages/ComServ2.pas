
{*******************************************************}
{                                                       }
{       Delphi Runtime Library                          }
{                                                       }
{       Copyright (C) 1997 Borland International        }
{                                                       }
{*******************************************************}

unit ComServ2;



interface

uses Windows, ActiveX, SysUtils, ComObj, GPCSGUID;

type

{ Application start mode }

  TStartMode = (smStandalone, smAutomation, smRegServer, smUnregServer);

{ Class manager event types }

  TLastReleaseEvent = procedure(var Shutdown: Boolean) of object;

{ TComServer }

  TComServer = class(TComServerObject)
  private
    FObjectCount: Integer;
    FFactoryCount: Integer;
    FTypeLib: ITypeLib;
    FServerName: string;
    FHelpFileName: string;
    FIsInprocServer: Boolean;
    FStartMode: TStartMode;
    FRegister: Boolean;
    FOnLastRelease: TLastReleaseEvent;
    procedure FactoryFree(Factory: TComObjectFactory);
    procedure FactoryRegisterClassObject(Factory: TComObjectFactory);
    procedure FactoryUpdateRegistry(Factory: TComObjectFactory);
    procedure LastReleased;
  protected
    function CountObject(Created: Boolean): Integer; override;
    function CountFactory(Created: Boolean): Integer; override;
    function GetHelpFileName: string; override;
    function GetServerFileName: string; override;
    function GetServerKey: string; override;
    function GetServerName: string; override;
    function GetTypeLib: ITypeLib; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Initialize;
    procedure LoadTypeLib;
    procedure SetServerName(const Name: string);
    procedure UpdateRegistry(Register: Boolean);
    property IsInprocServer: Boolean read FIsInprocServer write FIsInprocServer;
    property ObjectCount: Integer read FObjectCount;
    property StartMode: TStartMode read FStartMode;
    property OnLastRelease: TLastReleaseEvent read FOnLastRelease write FOnLastRelease;
  end;

var
  ComServer: TComServer;

function DllGetClassObject(const CLSID, IID: TGUID; var Obj): HResult; stdcall;
function DllCanUnloadNow: HResult; stdcall;
function DllRegisterServer: HResult; stdcall;
function DllUnregisterServer: HResult; stdcall;

implementation

{$I ComServ2.inc}

{ Find command-line switch }

function FindCmdLineSwitch(const Switch: string): Boolean;
var
  I: Integer;
  S: string;
begin
  for I := 1 to ParamCount do
  begin
    S := ParamStr(I);
    if (S[1] in ['-', '/']) and
      (CompareText(Copy(S, 2, Maxint), Switch) = 0) then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

function GetModuleFileName: string;
var
  Buffer: array[0..261] of Char;
begin
  SetString(Result, Buffer, Windows.GetModuleFileName(HInstance,
    Buffer, SizeOf(Buffer)));
end;

function GetModuleName: string;
begin
  Result := ChangeFileExt(ExtractFileName(GetModuleFileName), '');
end;

function LoadTypeLibrary(const ModuleName: string): ITypeLib;
begin
  OleCheck(LoadTypeLib(PWideChar(WideString(ModuleName)), Result));
end;

procedure RegisterTypeLibrary(TypeLib: ITypeLib; const ModuleName: string);
var
  Name: WideString;
begin
  Name := ModuleName;
  OleCheck(RegisterTypeLib(TypeLib, PWideChar(Name), PWideChar(Name)));
end;

procedure UnregisterTypeLibrary(TypeLib: ITypeLib);
type
  TUnregisterProc = function(const GUID: TGUID; VerMajor, VerMinor: Word;
    LCID: TLCID; SysKind: TSysKind): HResult stdcall;
var
  Handle: THandle;
  UnregisterProc: TUnregisterProc;
  LibAttr: PTLibAttr;
begin
  Handle := GetModuleHandle('OLEAUT32.DLL');
  if Handle <> 0 then
  begin
    @UnregisterProc := GetProcAddress(Handle, 'UnRegisterTypeLib');
    if @UnregisterProc <> nil then
    begin
      OleCheck(ComServer.TypeLib.GetLibAttr(LibAttr));
      with LibAttr^ do
        UnregisterProc(guid, wMajorVerNum, wMinorVerNum, lcid, syskind);
      ComServer.TypeLib.ReleaseTLibAttr(LibAttr);
    end;
  end;
end;

function GetTypeLibName(TypeLib: ITypeLib): string;
var
  Name: WideString;
begin
  OleCheck(TypeLib.GetDocumentation(-1, @Name, nil, nil, nil));
  Result := Name;
end;

function DllGetClassObject(const CLSID, IID: TGUID; var Obj): HResult;
var
  Factory: TComObjectFactory;
begin
  Factory := ComClassManager.GetFactoryFromClassID(CLSID);
  if Factory <> nil then
    if Factory.GetInterface(IID, Obj) then
      Result := S_OK
    else
      Result := E_NOINTERFACE
  else
  begin
    Pointer(Obj) := nil;
    Result := CLASS_E_CLASSNOTAVAILABLE;
  end;
end;

function DllCanUnloadNow: HResult;
begin
  if (ComServer = nil) or
    ((ComServer.FObjectCount = 0) and (ComServer.FFactoryCount = 0)) then
    Result := S_OK
  else
    Result := S_FALSE;
end;

function DllRegisterServer: HResult;
begin
  Result := S_OK;
  try
    ComServer.UpdateRegistry(True);
  except
    Result := E_FAIL;
  end;
end;

function DllUnregisterServer: HResult;
begin
  Result := S_OK;
  try
    ComServer.UpdateRegistry(False);
  except
    Result := E_FAIL;
  end;
end;

{ Automation TerminateProc }

function AutomationTerminateProc: Boolean;
begin
  Result := True;
  // Does StartMode matter?
  if ( GetGPCSRegString('','Automation Warning','1') = '1' )
  and (ComServer.StartMode = smAutomation)
  and not ((ComServer = nil) or (ComServer.ObjectCount = 0)) then
  begin
    Result := MessageBox(0, PChar(SNoCloseActiveServer1 + SNoCloseActiveServer2),
      PChar(SAutomationWarning), MB_YESNO or MB_TASKMODAL or
      MB_ICONWARNING or MB_DEFBUTTON2) = IDYES;
  end;
end;

{ TComServer }

constructor TComServer.Create;
begin
  FTypeLib := nil;
  FIsInprocServer := ModuleIsLib;
  if FindCmdLineSwitch('AUTOMATION') or FindCmdLineSwitch('EMBEDDING') then
    FStartMode := smAutomation
  else if FindCmdLineSwitch('REGSERVER') then
    FStartMode := smRegServer
  else if FindCmdLineSwitch('UNREGSERVER') then
    FStartMode := smUnregServer;
end;

destructor TComServer.Destroy;
begin
  ComClassManager.ForEachFactory(Self, FactoryFree);
end;

function TComServer.CountObject(Created: Boolean): Integer;
begin
  if Created then Inc(FObjectCount) else
  begin
    Dec(FObjectCount);
    if FObjectCount = 0 then LastReleased;
  end;
  Result := FObjectCount;
end;

function TComServer.CountFactory(Created: Boolean): Integer;
begin
  if Created then Inc(FFactoryCount) else Dec(FFactoryCount);
  Result := FFactoryCount;
end;

procedure TComServer.FactoryFree(Factory: TComObjectFactory);
begin
  Factory.Free;
end;

procedure TComServer.FactoryRegisterClassObject(Factory: TComObjectFactory);
begin
  Factory.RegisterClassObject;
end;

procedure TComServer.FactoryUpdateRegistry(Factory: TComObjectFactory);
begin
  if Factory.Instancing <> ciInternal then
    Factory.UpdateRegistry(FRegister);
end;

function TComServer.GetHelpFileName: string;
begin
  Result := FHelpFileName;
end;

function TComServer.GetServerFileName: string;
begin
  Result := GetModuleFileName;
end;

function TComServer.GetServerKey: string;
begin
  if FIsInprocServer then
    Result := 'InprocServer32' else
    Result := 'LocalServer32';
end;

function TComServer.GetServerName: string;
begin
  if FServerName <> '' then
    Result := FServerName
  else
    if FTypeLib <> nil then
      Result := GetTypeLibName(FTypeLib)
    else
      Result := GetModuleName;
end;

procedure TComServer.SetServerName(const Name: string);
begin
  if FTypeLib = nil then
    FServerName := Name;
end;

function TComServer.GetTypeLib: ITypeLib;
begin
  LoadTypeLib;
  Result := FTypeLib;
end;

procedure TComServer.Initialize;
begin
  UpdateRegistry(FStartMode <> smUnregServer);
  if FStartMode in [smRegServer, smUnregServer] then Halt;
  ComClassManager.ForEachFactory(Self, FactoryRegisterClassObject);
end;

procedure TComServer.LastReleased;
var
  Shutdown: Boolean;
begin
  if not FIsInprocServer then
  begin
    Shutdown := FStartMode = smAutomation;
    if Assigned(FOnLastRelease) then FOnLastRelease(Shutdown);
    if Shutdown then PostQuitMessage(0);
  end;
end;

procedure TComServer.LoadTypeLib;
begin
  if FTypeLib = nil then FTypeLib := LoadTypeLibrary(GetModuleFileName);
end;

procedure TComServer.UpdateRegistry(Register: Boolean);
begin
  if FTypeLib <> nil then
    if Register then
      RegisterTypeLibrary(FTypeLib, GetModuleFileName) else
      UnregisterTypeLibrary(FTypeLib);
  FRegister := Register;
  ComClassManager.ForEachFactory(Self, FactoryUpdateRegistry);
end;

var
  SaveInitProc: Pointer = nil;
  OleAutHandle: Integer;

procedure InitComServer;
begin
  if SaveInitProc <> nil then TProcedure(SaveInitProc);
  ComServer.Initialize;
end;

initialization
begin
  OleAutHandle := LoadLibrary('OLEAUT32.DLL');
  ComServer := TComServer.Create;
  if not ModuleIsLib then
  begin
    SaveInitProc := InitProc;
    InitProc := @InitComServer;
    AddTerminateProc(@AutomationTerminateProc);
  end;
end;

finalization
begin
  ComServer.Free;
  ComServer := nil;
  FreeLibrary(OleAutHandle);
end;

end.
