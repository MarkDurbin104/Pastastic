program Project1;

uses
  Forms,
  Base64DecodeFU in 'Base64DecodeFU.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
