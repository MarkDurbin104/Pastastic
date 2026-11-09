{  Module
   Unit            
   Copyright(c)    
   Author          
   Description     
                   
                   
                   
                   
   Modifications   
                   
}
program TrackedMail;

uses
  Forms,
  ComServ2,
  TrackedMailAU in 'TrackedMailAU.pas',
  TrackedMailFU in 'TrackedMailFU.pas';

{$R *.RES}

begin
  Application.Initialize;
  if ComServer.StartMode <> smStandalone then // if run under automation
     Application.ShowMainForm:=False;         // then hide main form
  Application.Title := 'Tracked Mail Log';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
