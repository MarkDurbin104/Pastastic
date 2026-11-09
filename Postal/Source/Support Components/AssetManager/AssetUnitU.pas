unit AssetUnitU;

interface

uses
  ComObj,
  AssetManagerDM,
  AssetManager_TLB, DbTables;

type

  TAssetUnit = class(TAutoObject, IAssetUnit)
  private
    AssetUnitsTable : TTable;
    FName : String;
    FExchange : Currency;
    function Get_Name : WideString; safecall;
    procedure Set_Name(const Value : WideString); safecall;
    function Get_Exchange : Currency; safecall;
    procedure Set_Exchange(Value : Currency); safecall;

  public
    constructor Create;
    destructor Destroy; override;
    property Name   : WideString  read Get_Name write Set_Name;
    property Exchange : Currency  read Get_Exchange write Set_Exchange;
  end;

implementation
uses
  ComServ2;

constructor TAssetUnit.Create;
begin
  Inherited Create;
  AssetUnitsTable := AssetManagerDataModule.AssetUnitTable;
end;

destructor TAssetUnit.Destroy;
begin
  Inherited Destroy;
end;

function TAssetUnit.Get_Name : WideString;
begin
  Result := FName;
end;

procedure TAssetUnit.Set_Name(const Value : WideString);
var
  ExchangeRate : Variant;
begin
  If FName <> Value then
  begin
    ExchangeRate := AssetUnitsTable.Lookup('AUName',Value,'AUExchange');
    FExchange := ExchangeRate;
    FName := Value;
  end;
end;

function TAssetUnit.Get_Exchange : Currency;
begin
  Result := FExchange;
end;

procedure TAssetUnit.Set_Exchange(Value : Currency);
begin
  If FExchange <> Value then
  begin
    FExchange := Value;
    If AssetUnitsTable.Locate('AUName', FName,[]) then
    begin
      AssetUnitsTable.Edit;
      AssetUnitsTable.FieldByName('AUExchange').AsCurrency := Value;
      AssetUnitsTable.Post;
    end;
  end;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TAssetUnit, Class_AssetUnit, ciInternal);


end.
