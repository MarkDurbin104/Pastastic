program InstallBuilder;

uses
  Forms,
  InstallerBuildFU in 'InstallerBuildFU.pas' {InstallBuild};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TInstallBuild, InstallBuild);
  Application.Run;
end.
