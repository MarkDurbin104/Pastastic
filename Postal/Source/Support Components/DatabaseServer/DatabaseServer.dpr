{ Module          Database Server
  Unit            Project
  Copyright(c)    Postal Solutions Limited 1996..1999
  Author          ASH
  Description     Manages database access and domestic mail management (Hungary)
  Modifications   09/1998     - ASH
                                Original Release - for Hungarian Demo
                  25/01/1999  - ASH
                                Header comments and code formatting

}
program DatabaseServer;

uses
  ComServ2,
  Forms,
  DatabaseServerF in 'DatabaseServerF.pas' {DatabaseServerForm},
  DatabaseServer_TLB in 'DatabaseServer_TLB.pas',
  DatabaseServerAU in 'DatabaseServerAU.pas' {DatabaseServerAuto: CoClass},
  CreateRemote in 'CreateRemote.pas',
  GPCSBase_TLB;

{$R *.RES}

{$R *.TLB}
    
begin
  Application.Initialize;
  If ComServer.StartMode <> smStandAlone then
    Application.ShowMainForm := False;
  Application.CreateForm(TDatabaseServerForm, DatabaseServerForm);
  Application.Run;
end.
