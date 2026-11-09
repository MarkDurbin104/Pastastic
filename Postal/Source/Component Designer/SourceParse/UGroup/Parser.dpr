program Parser;

uses
  Forms,
  UGpassFU in 'UGpassFU.pas' {Form1},
  TokenParser in 'TokenParser.pas',
  Compress in 'Compress.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
