program AssetTrigger;

uses
  Windows,
  ComObj,
  ComServ2,
  Forms,
  AssetTriggerAU in 'AssetTriggerAU.pas',
  GPCSErrorLine in '..\..\Error Handler\GPCSErrorLine.pas',
  AssetManager_TLB in '..\AssetManager_TLB.pas';

{$R *.TLB}

{$R *.RES}

begin
  Application.Initialize;

  While not Application.Terminated do
    Application.HandleMessage;
    
  Application.Run;
end.
