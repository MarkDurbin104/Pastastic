{  <Synopsis>      Corvus Component Loader
   <Unit>          Project
   <Copyright(c)>  Postal Solutions Limited 1996..1998
   <Author>        MJD
   <Description>   Implement all Component Loading Functions for Corvus
                   by loading COM objects via GUID and returning variant
                   references to each component.
                   When a maximum number of components (MaxLoad) is Loaded
                   start a new version of self to load additional components
   <Modifications> 06/01/98 - MJD
                              Original Release
                   13/02/99 - MJD
                              Change Commenting format
}                          
program CompLoad;

uses
  Forms,ComServ2,
  CompLoadAU in 'CompLoadAU.pas',
  CompLoadFU in 'CompLoadFU.pas';

{$R *.RES}

begin
  Application.Initialize;
  if ComServer.StartMode <> smStandalone then // if run under automation
     Application.ShowMainForm:=False;         // then hide main form
  Application.Title := 'Component Loader';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
