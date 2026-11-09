program Shirika;

uses
  Forms,
  ShirikaFU in 'ShirikaFU.pas' {MainForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.ShowMainForm:=False;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
