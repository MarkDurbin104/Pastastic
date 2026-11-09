program Try1;

uses
  Forms,
  TryForm1 in 'TryForm1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;     
end.
 