library Project1;

uses
  ComServ,
  Project1_TLB in 'Project1_TLB.pas',
  ActiveFormImpl in 'ActiveFormImpl.pas' {ActiveFormX: TActiveForm} {ActiveFormX: CoClass},
  About in 'About.pas' {ActiveFormXAbout};

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
