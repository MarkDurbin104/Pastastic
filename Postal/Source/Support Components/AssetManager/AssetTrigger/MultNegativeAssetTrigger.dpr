program MultNegativeAssetTrigger;
uses
  Windows,
  ComObj,
  ComServ,
  Forms,
  MultNegativeAssetTriggerAU in 'MultNegativeAssetTriggerAU.pas',
  AssetTriggerAU in 'AssetTriggerAU.pas',
  AssetManager_TLB in '..\AssetManager_TLB.pas',
  GPCSErrorCode in '..\..\Error Handler\GPCSErrorCode.pas',
  GPCSBase_TLB in '..\..\..\Base Type Library\GPCSBase_TLB.pas',
  GPCSBaseAU in '..\..\..\Base Type Library\GPCSBaseAU.pas',
  GPCSGUID in '..\..\..\Base Type Library\GPCSGUID.pas',
  GPCSErrorLine in '..\..\Error Handler\GPCSErrorLine.pas';


{$R *.RES}

const
  Class_MultNegativeAssetTrigger: TGUID = '{8283CEE1-48E1-11D3-A704-00A024B01373}';


begin
  TGPCSCompFactory.Create(ComServer, TMultNegativeAssetTrigger, Class_MultNegativeAssetTrigger, 'AssetTrigger.MultNegative', 'GPCS MultNegative Asset Trigger', ciMultiInstance);
  Application.Initialize;
  While not Application.Terminated do
    Application.ProcessMessages;
  Application.Run;
end.
