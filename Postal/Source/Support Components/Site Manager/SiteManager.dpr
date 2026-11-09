{  Module          Corvus Site Manager
   Unit            Project
   Copyright(c)    Postal Solutions Limited 1996..1998
   Author          MJD
   Description     
   Modifications   
                              Original Release
________________________________________________________________________________}
program SiteManager;

uses
  Forms,
  ComServ2,
  SiteManagerAU in 'SiteManagerAU.pas',
  SiteManagerFU in 'SiteManagerFU.pas',
  DataGramU in 'DataGramU.pas',
  RegUtils in 'RegUtils.pas';

{$R *.RES}

begin
  Application.Initialize;
  if ComServer.StartMode <> smStandalone then // if run under automation
     Application.ShowMainForm:=False;         // then hide main form
  Application.Title := 'Site Manager';
  Application.CreateForm(TSiteManagerForm, SiteManagerForm);
  Application.Run;
end.
