unit AssetQuantityU;

interface

uses
  ComObj, AssetManager_TLB, AssetUnitU;

type
  TAssetQuantity = class(TAutoObject, IAssetQuantity)
  private
    FAmount : Currency;
    FUnits : IAssetUnit;
    function Get_Amount : Currency; safecall;
    procedure Set_Amount(Value : Currency); safecall;
    function Get_Units : IAssetUnit; safecall;
    procedure Set_Units(const Value : IAssetUnit); safecall;
  protected

    destructor Destroy; override;
    procedure Initialize; override;
  public
    property Amount : Currency   read Get_Amount write Set_Amount;
    property Units  : IAssetUnit  read Get_Units write Set_Units;
    constructor Create;

    function ConvertTo(const AssetUnit : IAssetUnit) : Currency; safecall;
  end;

implementation
uses
  ComServ2;

function TAssetQuantity.ConvertTo(const AssetUnit : IAssetUnit) : Currency;
begin
  Result := Amount * AssetUnit.Exchange / Units.Exchange;
end;

constructor TAssetQuantity.Create;
begin
  inherited Create;
  FUnits := TAssetUnit.Create;
  FUnits.Name := 'GBP';
end;

destructor TAssetQuantity.Destroy;
begin
  FUnits := nil;
  Inherited Destroy;
end;

procedure TAssetQuantity.Initialize;
begin
  _AddRef;
end;

function TAssetQuantity.Get_Amount : Currency;
begin
  Result := FAmount;
end;

procedure TAssetQuantity.Set_Amount(Value : Currency);
begin
  If FAmount <> Value then
  begin
    FAmount := Value;
  end;
end;

function TAssetQuantity.Get_Units : IAssetUnit;
begin
  Result := FUnits;
end;

procedure TAssetQuantity.Set_Units(const Value : IAssetUnit);
var
  OrigExchange  : Currency;
begin
  If FUnits.Name <> Value.Name then
  begin
    //convert amount to new exchange rate amount
    OrigExchange := FUnits.Exchange;
    FUnits := Value;
    Set_Amount((Get_Amount * FUnits.Exchange)  / OrigExchange);
  end;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TAssetQuantity, Class_AssetQuantity, ciInternal);

end.
