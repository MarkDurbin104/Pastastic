library DummyReceipt;

uses
  ComServ2,
  DummyReceiptAU in 'DummyReceiptAU.pas',
  DummyReceiptFU in 'DummyReceiptFU.pas' {ReceiptForm};

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.
