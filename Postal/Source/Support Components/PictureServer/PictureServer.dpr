program PictureServer;

uses
  Forms,
  ComServ2,
  PictureServerFU in 'PictureServerFU.pas' {Form1},
  PictureServerAU in 'PictureServerAU.pas';

{$R *.RES}

begin
  Application.Initialize;
  if ComServer.StartMode <> smStandAlone then
     Application.ShowMainForm:=False;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
