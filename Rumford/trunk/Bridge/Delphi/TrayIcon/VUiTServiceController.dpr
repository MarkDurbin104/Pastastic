program VUiTServiceController;

uses
  Forms,
  VUiTServiceControllerFU in 'VUiTServiceControllerFU.pas' {MainForm},
  ServiceControlU in 'ServiceControlU.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.ShowMainForm:=False;
  Application.MainFormOnTaskbar := False;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
