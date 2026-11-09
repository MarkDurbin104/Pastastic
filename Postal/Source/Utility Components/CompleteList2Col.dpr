program {PName}CompleteList2Col;

uses
  Forms,
  ComServ2,
  ComObj,
  CompleteList2ColAU in 'CompleteList2ColAU.pas',
  GPCSBase_TLB in '..\Base Type Library\GPCSBase_TLB.pas',
  GPCSBaseAU in '..\Base Type Library\GPCSBaseAU.pas',
  GPCSGUID in '..\Base Type Library\GPCSGUID.pas',
  GPCSErrorCode in '..\Support Components\Error Handler\GPCSErrorCode.pas',
  GPCSErrorLine in '..\Support Components\Error Handler\GPCSErrorLine.pas',
  BaseProduct in '..\Base Components\Product\BaseProduct.pas',
  ProdDesign in '..\Base Components\Product\ProdDesign.pas' {DesForm},
  CompleteList2ColFU in 'CompleteList2ColFU.pas' {ProdForm},
  DatabaseServer_TLB in '..\..\..\gpcs\source\v2\DatabaseServer\DatabaseServer_TLB.pas';

{$R *.RES}
  
begin
  TGPCSCompFactory.Create(ComServer,{PClass}TComplListProduct,
                          StringToGUID({PGUID}'{54DA11E0-5CD6-11D2-9D88-006008BA10FE}'),
                          {PProgID}'Product.ComplList2',{PRegDesc}'GPCS 2 Column Completion List Product',ciMultiInstance);
  Application.Initialize;
  if ComServer.StartMode <> smStandalone then
  begin
     repeat
        Application.HandleMessage
     until Application.Terminated;
  end;
end.
