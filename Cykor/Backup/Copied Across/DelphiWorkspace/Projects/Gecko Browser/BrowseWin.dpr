program BrowseWin;

uses
  Forms,
  Brow10 in 'Brow10.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
