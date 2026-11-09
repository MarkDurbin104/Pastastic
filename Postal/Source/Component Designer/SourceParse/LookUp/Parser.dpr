program Parser;

uses
  Forms,
  TokenParser in 'TokenParser.pas',
  Compress in 'Compress.pas',
  LkpassFU in 'LkpassFU.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
