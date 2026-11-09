program SiteManager;

uses
  Forms,
  SiteManagerFU in 'SiteManagerFU.pas' {Form1},
  SiteManagerAU in 'SiteManagerAU.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
