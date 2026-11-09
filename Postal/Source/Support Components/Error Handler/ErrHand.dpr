{  Module          Corvus Error Handler
   Unit            Project
   Copyright(c)    Postal Solutions Limited 1996..1998
   Author          MJD
   Description     Display and log errors form the rest of the Corvus system.
   Modifications   19/03/98 - MJD
                              Original Release
   									27/03/00 - ASH
                    					RaiseGUIDError, RaiseGUIDException added
                    30/03/00 - ASH
                    					Registry reads for Logfile, Visible and NTEventLog

}
program ErrHand;

uses
  Forms,
  ComServ2,
  ErrorHFU in 'ErrorHFU.pas' {ErrorForm},
  ErrorHAU in 'ErrorHAU.pas',
  GPCSErrorCode in 'GPCSErrorCode.pas',
  GPCSErrorLine in 'GPCSErrorLine.pas',
  LogFileU in 'LogFileU.pas',
  afpEventLog;

{$R *.RES}

begin
  Application.Initialize;
  if ComServer.StartMode <> smStandalone then // if not testing 
     Application.ShowMainForm := False;
  Application.Title := 'Corvus Error Manager';
  Application.CreateForm(TErrorForm, ErrorForm);
  Application.Run;
end.
