program Parser;

uses
  Forms,
  ParserFU in 'ParserFU.pas' {Form1},
  TokenParser in 'TokenParser.pas',
  Compress in 'Compress.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
