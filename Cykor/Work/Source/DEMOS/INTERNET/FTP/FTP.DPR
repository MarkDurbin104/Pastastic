program FTP;

uses
  Forms,
  main in 'main.pas' {MainForm},
  UsrInfo in 'UsrInfo.pas' {ConnectForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
