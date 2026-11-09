program SetupCtr;

uses
  Forms,
  SetForm1 in 'SetForm1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
 