program ServiceTestHarness;

uses
  Forms,
  ServiceTestHarnessFU in 'ServiceTestHarnessFU.pas' {Form1},
  CommsControllerFU in 'CommsControllerFU.pas' {CommsController},
  DIMimeStreams in 'DIMimeStreams.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.ShowMainForm:=False;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
