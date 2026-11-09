program OliReceipt;

uses
  Forms,
  ComServ2,
  OliReceiptAU in 'OliReceiptAU.pas',
  Receipt_TLB in 'Receipt_TLB.pas';

{exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;
}
{$R *.TLB}

{$R *.RES}

begin
  Application.Initialize;
  while not Application.Terminated do Application.HandleMessage;
end.
