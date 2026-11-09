library AXPanel;

uses
  ComServ,
  AXPanel_TLB in 'AXPanel_TLB.pas',
  AXPanelU in 'AXPanelU.pas' {PanelX: CoClass},
  AXPanelAbout in 'AXPanelAbout.pas' {PanelXAbout};

{$E ocx}

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.
