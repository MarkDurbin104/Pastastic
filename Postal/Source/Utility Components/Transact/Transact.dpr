{$ifdef BUILDLIBRARY}
library Transact;
{$else}
program Transact;
{$endif}

uses
  Forms,
  ComServ2,
  TransactFU in 'TransactFU.pas' {TxnForm},
  TransactAU in 'TransactAU.pas',
  TranProcessU;

{$R *.RES}

{$ifdef BUILDLIBRARY}
exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer,
  GetInterface;
{$endif}

begin
{$ifndef BUILDLIBRARY}
  Application.Initialize;
  if ComServer.StartMode <> smStandAlone then
     Application.ShowMainForm:=False;
  Application.CreateForm(TTxnForm, TxnForm);
  Application.Run;
{$endif}
end.


