program CorvusSetup;

uses
  Forms,
  ComServ2,
  CorvusSetupFU in 'CorvusSetupFU.pas' {SetupForm},
  UnRar in 'UnRar.pas',
  CorvusSetupSplashF in 'CorvusSetupSplashF.pas' {CorvusSetupSplashForm};

{$R *.RES}
{$R RAR.RES}
{$R RarDll.RES}

begin
  if ComServer.StartMode = smRegServer then
  begin
    SetupForm:=TSetupForm.Create(nil);
    SetupForm.ShowModal;
    SetupForm.Free;
  end;
  Application.Initialize;
  CorvusSetupSplashForm := TCorvusSetupSplashForm.Create(Application);
  CorvusSetupSplashForm.Show;
  CorvusSetupSplashForm.Refresh;  

  Application.CreateForm(TSetupForm, SetupForm);
  CorvusSetupSplashForm.Hide;
  CorvusSetupSplashForm.Free;
  Application.Run;
end.
