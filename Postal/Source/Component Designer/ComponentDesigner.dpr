program ComponentDesigner;

uses
  Forms,
  CDMain in 'CDMain.pas' {MainForm},
  CompListFU in 'CompListFU.pas' {ComponentPalette},
  GPCSRegistry in 'GPCSRegistry.pas',
  SnapInFU in 'SnapInFU.pas' {Form2},
  SplashFU in 'SplashFU.pas' {Splash},
  WaitBoxFU in 'WaitBoxFU.pas' {WaitBox},
  CompOptionsFU in 'CompOptionsFU.pas' {CompOptions},
  WinExecU in 'WinExecU.pas',
  BuildProgFU in 'BuildProgFU.pas' {BuildProg},
  SourceFormFU in 'SourceFormFU.pas' {SourceForm},
  DesInterfaceU in 'DesInterfaceU.pas',
  GPCSGUID in '..\Base Type Library\GPCSGUID.pas',
  ProjOptionsFU in 'ProjOptionsFU.pas' {ProjOptions};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSplash, Splash);
  Application.CreateForm(TWaitBox, WaitBox);
  Application.CreateForm(TCompOptions, CompOptions);
  Application.CreateForm(TBuildProg, BuildProg);
  Application.CreateForm(TSourceForm, SourceForm);
  Application.CreateForm(TProjOptions, ProjOptions);
  Application.Run;
end.
