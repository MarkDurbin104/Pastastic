unit MultPositiveAssetTriggerAU;

interface

uses
  AssetManager_TLB,
  GPCSBaseAU,
  ComObj,
  AssetTriggerAU;

const

  TriggerCode : WideString = 'Result := 1 * Value;';

type
  TMultPositiveAssetTrigger = class(TAssetTrigger, IAssetTrigger)
  protected
    function Get_TriggerCode: WideString; override;
    function TriggerValue(Value: Double): Double; override;
  end;

implementation

uses
  ComServ2;

function TMultPositiveAssetTrigger.TriggerValue(Value: Double): Double;
begin
  Result := 1 * Value;
end;

function TMultPositiveAssetTrigger.Get_TriggerCode: WideString;
begin
  Result := TriggerCode;
end;

end.
