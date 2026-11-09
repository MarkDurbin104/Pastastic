unit AssetEntryU;

interface

uses
  SysUtils,
  ComObj,
  AssetBaseU,
  AssetManager_TLB, AssetOwnerU, AssetQuantityU, AssetTimePointU;

type
  TAssetEntry = class(TAssetBase, IAssetEntry)
  private

    FAssetQuantity: IAssetQuantity;
    FCreator      : IAssetOwner;
    FPerson       : IAssetOwner;
    FPeriod       : Integer;
    FSite         : WideString;
    FWhenCharged  : IAssetTimePoint;
    FWhenBooked	  : IAssetTimePoint;
    FWorkstation  : WideString;

    function  Get_AssetQuantity: IAssetQuantity; safecall;
    procedure Set_AssetQuantity(const Value: IAssetQuantity); safecall;
    function  Get_Creator: IAssetOwner; safecall;
    procedure Set_Creator(const Value: IAssetOwner); safecall;
    function  Get_Site: WideString; safecall;
    procedure Set_Site(const Value : WideString); safecall;
    function  Get_Workstation : WideString; safecall;
    procedure Set_Workstation(const Value : WideString); safecall;
    function  Get_Person : IAssetOwner; safecall;
    procedure Set_Person(const Value : IAssetOwner); safecall;
    function  Get_Period : Integer; safecall;
    procedure Set_Period(Value : Integer); safecall;
    function  Get_WhenCharged : IAssetTimePoint; safecall;
    procedure Set_WhenCharged(const Value : IAssetTimePoint); safecall;
    function  Get_WhenBooked : IAssetTimePoint; safecall;
    procedure Set_WhenBooked(const Value : IAssetTimePoint); safecall;

  protected
    procedure Initialize; override;
    destructor Destroy; override;
  public
    property AssetQuantity: IAssetQuantity  read Get_AssetQuantity       write Set_AssetQuantity;
    property Creator      : IAssetOwner     read Get_Creator      write Set_Creator;
    property Site         : WideString      read Get_Site         write Set_Site;
    property Workstation  : WideString      read Get_Workstation  write Set_Workstation;
    property Person       : IAssetOwner     read Get_Person       write Set_Person;
    property Period       : Integer         read Get_Period       write Set_Period;
    property WhenCharged  : IAssetTimePoint read Get_WhenCharged  write Set_WhenCharged;
    property WhenBooked	  : IAssetTimePoint read Get_WhenBooked   write Set_WhenBooked;

    function Log          : AMStatus;safecall;
  end;

  TAssetEntries = class
  private
    function GetItems(Index : Integer) : TAssetEntry;
  public
    property Items[Index : Integer] : TAssetEntry read GetItems;
  end;

implementation

uses
  ComServ2,
  AssetUnitU,
  AssetManagerDM;



function  TAssetEntry.Get_AssetQuantity: IAssetQuantity; safecall;
begin
  Result := FAssetQuantity;
end;

procedure TAssetEntry.Set_AssetQuantity(const Value: IAssetQuantity);
var
  ValueCurrency : Currency;
begin
  //Avoid compiler internal C2357 error by using a local variable
  ValueCurrency := Value.Amount;
  If  (FAssetQuantity.Amount <> ValueCurrency) or (FAssetQuantity.Units.Name <> Value.Units.Name) then
  begin
    FAssetQuantity.Amount := ValueCurrency;
    FAssetQuantity.Units := Value.Units;
  end;
end;

function  TAssetEntry.Get_Creator: IAssetOwner; safecall;
begin
  Result := FCreator As IAssetOwner;
end;

procedure TAssetEntry.Set_Creator(const Value: IAssetOwner); safecall;
begin
  If FCreator <> Value then
  begin
    FCreator := Value;
  end;
end;

function TAssetEntry.Get_Site : WideString;
begin
  Result := FSite;
end;

procedure TAssetEntry.Set_Site(const Value : WideString);
begin
  If FSite <> Value then
  begin
    FSite := Value;
  end;
end;

function TAssetEntry.Get_Workstation : WideString;
begin
  Result := FWorkstation;
end;

procedure TAssetEntry.Set_Workstation(const Value : WideString);
begin
  If FWorkstation <> Value then
  begin
    FWorkstation := Value;
  end;
end;

function TAssetEntry.Get_Person : IAssetOwner;
begin
  Result := FPerson;
end;

procedure TAssetEntry.Set_Person(const Value : IAssetOwner);
begin
  If FPerson <> Value then
  begin
    FPerson := Value;
  end;
end;

function TAssetEntry.Get_Period;
begin
  Result := FPeriod;
end;

procedure TAssetEntry.Set_Period(Value : Integer);
begin
  If FPeriod <> Value then
  begin
    FPeriod := Value;
  end;
end;

function TAssetEntry.Get_WhenCharged;
begin
  Result := FWhenCharged;
end;

procedure TAssetEntry.Set_WhenCharged(const Value  : IAssetTimePoint);
begin
  If FWhenCharged <> Value then
  begin
    FWhenCharged := Value
  end;
end;

function TAssetEntry.Get_WhenBooked : IAssetTimePoint;
begin
  Result := FWhenBooked;
end;

procedure TAssetEntry.Set_WhenBooked(const Value : IAssetTimePoint);
begin
  If FWhenBooked <> Value then
  begin
    FWhenBooked := Value;
  end;
end;

destructor TAssetEntry.Destroy;
begin
  FAssetQuantity := nil;
  Inherited;
end;

procedure TAssetEntry.Initialize;
begin
  Inherited;
  FAssetQuantity := TAssetQuantity.Create;
end;

function TAssetEntry.Log : AMStatus;
var
  CurrentAmount   : Currency;
  ConvertedAmount : Currency; //amount in stored units
  StoredUnits     : TAssetUnit;
begin
  try
    If AssetManagerDataModule.AssetBalanceTable.Locate(
        'ABSite;ABOwner;ABPeriod;ABCode',
        VarArrayOf([Site, Person.Name, Period, Code]), []) then
    begin
      AssetManagerDataModule.AssetBalanceTable.Edit;

      //check units used
      ConvertedAmount := self.AssetQuantity.Amount;
      If (FAssetQuantity.Units.Name <> AssetManagerDataModule.AssetBalanceTableABUnit.AsString) then
      begin
        StoredUnits := TAssetunit.Create;
        try
          StoredUnits.Name := AssetManagerDataModule.AssetBalanceTableABUnit.AsString;
          ConvertedAmount := FAssetQuantity.ConvertTo(StoredUnits);
        finally
          StoredUnits.Free;
        end;
      end;
      CurrentAmount := AssetManagerDataModule.AssetBalanceTableABAmount.AsCurrency;
      AssetManagerDataModule.AssetBalanceTableABAmount.AsCurrency :=
        CurrentAmount + ConvertedAmount;
    end
    else
    begin //first time for this asset
      AssetManagerDataModule.AssetBalanceTable.Append;
      AssetManagerDataModule.AssetBalanceTableABSite.AsString     := FSite;
      AssetManagerDataModule.AssetBalanceTableABOwner.AsString    := FCreator.Name;
      AssetManagerDataModule.AssetBalanceTableABPeriod.AsString   := IntToStr(Period);
      AssetManagerDataModule.AssetBalanceTableABCode.AsString     := Code;
      AssetManagerDataModule.AssetBalanceTableABUnit.AsString     := FAssetQuantity.Units.Name;
      AssetManagerDataModule.AssetBalanceTableABAmount.AsCurrency := FAssetQuantity.Amount;
    end;
    AssetManagerDataModule.AssetBalanceTable.Post;
    Result := amSuccess;
  except
    Result := amUnexpected;
  end;
end;

function TAssetEntries.GetItems(Index : Integer) : TAssetEntry;
begin
  Result := nil;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TAssetEntry, Class_AssetEntry, ciInternal);

end.
