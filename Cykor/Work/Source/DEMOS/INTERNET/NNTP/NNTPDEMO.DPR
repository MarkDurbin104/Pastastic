{ This application demonstrates some of the basic functionality of the NNTP
  component.  It is not a complete application rather a browser of Usenet news
  groups/messages. }
program nntpdemo;

uses
  Forms,
  main in 'main.pas' {NewsForm},
  connect in 'connect.pas' {ConnectDlg};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TNewsForm, NewsForm);
  Application.Run;
end.
