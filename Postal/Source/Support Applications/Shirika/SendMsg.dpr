program SendMsg;

uses
  Forms,
  SendMsgFU in 'SendMsgFU.pas' {MainForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
