program Tax20AssetTrigger;
uses
  Windows,
  ComObj,
  ComServ2,
  Forms,
  Tax20AssetTriggerAU in '..\..\..\Packages\Tax20AssetTriggerAU.pas',
  AssetTriggerAU in 'AssetTriggerAU.pas',
  AssetManager_TLB in '..\AssetManager_TLB.pas',
  GPCSErrorCode in '..\..\Error Handler\GPCSErrorCode.pas',
  GPCSBase_TLB in '..\..\..\Base Type Library\GPCSBase_TLB.pas',
  GPCSBaseAU in '..\..\..\Base Type Library\GPCSBaseAU.pas',
  GPCSGUID in '..\..\..\Base Type Library\GPCSGUID.pas',
  GPCSErrorLine in '..\..\Error Handler\GPCSErrorLine.pas';


{$R *.RES}

const
  Class_Tax20AssetTrigger: TGUID = '{08EC48D1-48E8-11D3-A704-00A024B01373}';


begin
  TGPCSCompFactory.Create(ComServer, TTax20AssetTrigger, Class_Tax20AssetTrigger, 'AssetTrigger.Tax20', 'GPCS Tax20 Asset Trigger', ciMultiInstance);
  Application.Initialize;
  While not Application.Terminated do
    Application.ProcessMessages;
  Application.Run;
end.
