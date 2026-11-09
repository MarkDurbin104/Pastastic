{  <Synopsis>      Corvus Component Manager
   <Unit>          Project
   <Copyright(c)>  Postal Solutions Limited 1996..1998
   <Author>        MJD
   <Description>   Load and manage Corvus Components via the 
                   component loader
   <Modifications> 06/01/98 - MJD
                              Original Release
                   13/02/99 - MJD
                              Change Commenting format
}                          
program CompMan;

uses
  Forms,
  ComServ2,
  CompManFU in 'CompManFU.pas' {MainForm},
  CompManAU in 'CompManAU.pas',
  BackDirFU in 'BackDirFU.pas' {BackupForm},
  RGLFormFU in 'RGLFormFU.pas' {RGLForm};

{$R *.RES}

begin
  Application.Initialize;
  // if run under automation or started with valid parameter
  if (ComServer.StartMode <> smStandalone) or ValidCommandLine then 
     Application.ShowMainForm:=False;         // then hide main form
  Application.Title := 'Component Manager';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TBackupForm, BackupForm);
  Application.CreateForm(TRGLForm, RGLForm);
  MainForm.ParseCommandLine;
  Application.Run;
end.
