program emailtst;

uses
  Forms,
  testpas in 'testpas.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Test email binary application';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
 