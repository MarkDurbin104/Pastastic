unit MultNegativeAssetTriggerAU;

interface

uses
  AssetManager_TLB,
  GPCSBaseAU,
  ComObj,
  AssetTriggerAU;

const

  TriggerCode : WideString = 'Result := -1 * Value;';

type
  TMultNegativeAssetTrigger = class(TAssetTrigger, IAssetTrigger)
  protected
    function Get_TriggerCode: WideString; override;
    function TriggerValue(Value: Double): Double; override;
  end;

implementation

uses
  ComServ2;

function TMultNegativeAssetTrigger.TriggerValue(Value: Double): Double;
begin
  Result := -1 * Value;
end;

function TMultNegativeAssetTrigger.Get_TriggerCode: WideString;
begin
  Result := TriggerCode;
end;

end.
