{  Module          Corvus Component Loader
   Unit            Project
   Copyright(c)    Postal Solutions Limited 1996..1998
   Author          MJD
   Description     Implement all Component Loading Functions for Corvus
                   by loading COM objects via GUID and returning variant
                   references to each component.
                   When a maximum number of components (MaxLoad) is Loaded
                   start a new version of self to load additional components
   Modifications   06/01/98 - MJD
                              Original Release
}
program NewTxnLog;

uses
  Forms,
  ComServ,
  NewTxnlogAU in 'NewTxnlogAU.pas',
  NewTxnlogFU in 'NewTxnlogFU.pas' {NewTxnForm};

{$R *.RES}

begin
  Application.Initialize;
  if ComServer.StartMode <> smStandalone then // if run under automation
     Application.ShowMainForm:=False;         // then hide main form
  Application.Title := 'Transaction Log';
  Application.CreateForm(TNewTxnForm, NewTxnForm);
  Application.Run;
end.
