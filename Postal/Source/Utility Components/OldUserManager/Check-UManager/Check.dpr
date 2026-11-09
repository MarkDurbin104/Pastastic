program Check;

uses
  Forms,
  CheckFU in 'CheckFU.pas' {Form1},
  Umanager_TLB in '..\Umanager_TLB.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
