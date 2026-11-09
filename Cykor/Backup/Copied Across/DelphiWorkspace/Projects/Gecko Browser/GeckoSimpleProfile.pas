unit GeckoSimpleProfile;

interface

uses
  Windows, Messages, SysUtils, Classes;

type
  TGeckoSimpleProfile = class(TComponent)
  private
    { Private éŒ¾ }
    procedure SetProfileBaseDirectory(Value: AnsiString);
    function GetProfileBaseDirectory: AnsiString;
  protected
    { Protected éŒ¾ }
  public
    { Public éŒ¾ }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published éŒ¾ }
    property ProfileBaseDirectory: AnsiString
        read GetProfileBaseDirectory
        write SetProfileBaseDirectory;
  end;

procedure Register;

implementation

uses
  nsXPCOM, nsXPCOMGlue, nsError, nsGeckoStrings, nsProfile, nsTypes;

procedure Register;
begin
  RegisterComponents('Gecko', [TGeckoSimpleProfile]);
end;

var
  sProfileDirServiceProvider: nsProfileDirServiceProvider;
  sProfileBaseDirectory: AnsiString;
  sRefCnt: Integer = 0;

procedure ChangeProfileBaseDirectory; forward;
procedure SavePreferences; forward;
procedure LoadPreferences; forward;

constructor TGeckoSimpleProfile.Create(AOwner: TComponent);
var
  rv: nsresult;
  provider: nsProfileDirServiceProvider;
begin
  inherited Create(AOwner);

  if not (csDesigning in ComponentState) then
  begin
    rv := GRE_Startup;
    if NS_FAILED(rv) then
      raise Exception.Create('GRE_Startup');

    if not Assigned(sProfileDirServiceProvider) then
    begin
      rv := NS_NewProfileDirServiceProvider(True, provider);
      if NS_FAILED(rv) then
        raise Exception.Create('NS_NewProfileDirServiceProvider');

      sProfileDirServiceProvider := provider;

      Inc(sRefCnt);

      if Length(sProfileBaseDirectory)>0 then ChangeProfileBaseDirectory;
    end;
  end;
end;

destructor TGeckoSimpleProfile.Destroy;
begin
  if not (csDesigning in ComponentState) then
  begin
    SavePreferences;

    Dec(sRefCnt);
    if sRefCnt=0 then
      sProfileDirServiceProvider := nil;
  end;

  inherited;
end;

procedure TGeckoSimpleProfile.SetProfileBaseDirectory(Value: AnsiString);
begin
  if Value = sProfileBaseDirectory then Exit;

  sProfileBaseDirectory := Value;

  if not (csDesigning in ComponentState) then
  begin
    ChangeProfileBaseDirectory;
    LoadPreferences;
  end;
end;

function TGeckoSimpleProfile.GetProfileBaseDirectory: AnsiString;
begin
  Result := sProfileBaseDirectory;
end;

procedure ChangeProfileBaseDirectory;
var
  rv: nsresult;
  localFile: nsILocalFile;
  localFileStr: IInterfacedCString;
begin
  if Length(sProfileBaseDirectory)=0 then
  begin
    sProfileDirServiceProvider.SetProfileDir(nil);
    Exit;
  end;

  try
    localFileStr := NewCString(sProfileBaseDirectory);
  except
    Exit;
  end;
  rv := NS_NewNativeLocalFile(localFileStr.ACString, True, localFile);
  if NS_FAILED(rv) then Exit;

  sProfileDirServiceProvider.SetProfileDir(localFile);
  sProfileDirServiceProvider.Register;
end;

procedure SavePreferences;
var
  prefSrv: nsIPrefService;
  prefFile: nsIFile;
  rv: nsresult;
begin
  rv := NS_GetService(NS_PREFSERVICE_CID, nsIPrefService, prefSrv);
  if NS_FAILED(rv) then Exit;
  rv := NS_GetSpecialDirectory(NS_APP_PREFS_50_FILE, prefFile);
  if NS_FAILED(rv) then Exit;
  prefSrv.SavePrefFile(prefFile);
end;

procedure LoadPreferences;
var
  prefSrv: nsIPrefService;
  prefFile: nsIFile;
  rv: nsresult;
begin
  rv := NS_GetService(NS_PREFSERVICE_CID, nsIPrefService, prefSrv);
  if NS_FAILED(rv) then Exit;
  rv := NS_GetSpecialDirectory(NS_APP_PREFS_50_FILE, prefFile);
  if NS_FAILED(rv) then Exit;
  prefSrv.ResetPrefs;
  prefSrv.ReadUserPrefs(prefFile);
end;

end.
