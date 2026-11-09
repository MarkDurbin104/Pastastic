program MailFileParse;

uses
  Forms,
  MailFileParseFU in 'MailFileParseFU.pas' {Form1},
  PackStrListU in 'PackStrListU.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
