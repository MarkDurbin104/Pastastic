program RegistryConfig;

uses
  Forms,
  RegistryConfigF in 'RegistryConfigF.pas' {RegistryConfigForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TRegistryConfigForm, RegistryConfigForm);
  Application.Run;
end.
