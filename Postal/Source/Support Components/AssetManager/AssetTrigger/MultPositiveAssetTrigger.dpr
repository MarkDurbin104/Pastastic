program MultPositiveAssetTrigger;
uses
  Windows,
  ComObj,
  ComServ2,
  Forms,
  MultPositiveAssetTriggerAU in 'MultPositiveAssetTriggerAU.pas',
  AssetTriggerAU in 'AssetTriggerAU.pas',
  AssetManager_TLB in '..\AssetManager_TLB.pas',
  GPCSErrorCode in '..\..\Error Handler\GPCSErrorCode.pas',
  GPCSBase_TLB in '..\..\..\Base Type Library\GPCSBase_TLB.pas',
  GPCSBaseAU in '..\..\..\Base Type Library\GPCSBaseAU.pas',
  GPCSGUID in '..\..\..\Base Type Library\GPCSGUID.pas',
  GPCSErrorLine in '..\..\Error Handler\GPCSErrorLine.pas';


{$R *.RES}

const
  Class_MultPositiveAssetTrigger: TGUID = '{200763C1-18F7-11D3-8BD9-00A024B01373}';


begin
  TGPCSCompFactory.Create(ComServer, TMultPositiveAssetTrigger, Class_MultPositiveAssetTrigger, 'AssetTrigger.MultPositive', 'GPCS MultPositive Asset Trigger', ciMultiInstance);
  Application.Initialize;
  While not Application.Terminated do
    Application.ProcessMessages;
  Application.Run;
end.
