unit AssetU;

interface

uses
  ComObj, AssetManager_TLB, AssetBaseU, AssetManagerDM,
  AssetEntryU, AssetFilterU ,AssetOwnerU,AssetQuantityU,
  DbTables;

type

  TAsset = class(TAssetBase,IAsset)
  private
    FBalance      : TAssetQuantity;
    FOwner        : IAssetOwner;
    function Get_Balance : IAssetQuantity; safecall;
    procedure Set_Balance(const Value : IAssetQuantity); safecall;
    function Get_Owner        : IAssetOwner; safecall;
    procedure Set_Owner(const Value : IAssetOwner); safecall;

  public
    constructor Create;
    destructor Destroy; override;
    property Balance     : IAssetQuantity read Get_Balance write Set_Balance;
    property Owner       : IAssetOwner    read Get_Owner write Set_Owner;
    function EntriesUsing(Filter : TAssetFilter) : TAssetEntries;
  end;

implementation
uses
  ComServ2;

constructor TAsset.Create;
begin
  Inherited Create;
  //create balance
  FBalance := TAssetQuantity.Create;
end;


destructor TAsset.Destroy;
begin

  //destroy balance
  FBalance.Free;
  Inherited Destroy;
end;

function TAsset.EntriesUsing(Filter : TAssetFilter) : TAssetEntries;
begin
  Filter.Site := self.Owner.Site;
  Filter.Asset := self;
  Result := TAssetEntries.Create;
end;

function TAsset.Get_Balance : IAssetQuantity;
begin
  Result := FBalance;
end;

procedure TAsset.Set_Balance(const Value : IAssetQuantity);
begin
{  If  (FBalance.Amount <> Value.Amount)
  or  (FBalance.Units.Name <> Value.Units.Name) then
  begin
   // FBalance.Amount := Value.Amount;
   // FBalance.Units.Name := Value.Units.Name;
  end;
}
end;

function TAsset.Get_Owner       : IAssetOwner;
begin
  Result := FOwner;
end;

procedure TAsset.Set_Owner(const Value : IAssetOwner);
begin
  If FOwner <> Value then
  begin
    FOwner := Value;
  end;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TAsset, Class_Asset, ciInternal);


end.
