unit AssetBaseU;

interface

uses
  AssetManagedU, ComObj, DBTables, AssetManager_TLB;

type
  TAssetBase = class(TAssetManaged, IAssetBase)
  private
    FName         : WideString;
    FCode         : WideString;
    FDescription  : WideString;

  protected

    function Get_Code : WideString; safecall;
    procedure Set_Code(const Value :WideString); safecall;

    function Get_Description : WideString; safecall;
    procedure Set_Description(const Value :WideString); safecall;

    function Get_Name : WideString; safecall;
    procedure Set_Name(const Value :WideString); safecall;

    procedure Initialize; override;
    destructor Destroy; override;
  public
    property Code : WideString read Get_Code write Set_Code;
    property Description : WideString read Get_Description;
  end;

implementation
uses
  AssetManagerDM;

function TAssetBase.Get_Code : WideString;
begin
  Result := FCode;
end;

procedure TAssetBase.Set_Code(const Value :WideString);
begin
  If FCode <> Value then
  begin
    If AssetManagerDataModule.AssetDescriptionTable.Locate('ADAsset',Value,[]) then
    begin
      FDescription  := AssetManagerDataModule.AssetDescriptionTable.FieldByName('ADDescription').AsString;
      FCode := Value;
    end;
  end;
end;

function TAssetBase.Get_Description : WideString; safecall;
begin
  Result := FDescription;
end;

procedure TAssetBase.Set_Description(const Value :WideString); safecall;
begin
  With AssetManagerDataModule.AssetDescriptionTable do
  begin
    If Locate('ADAsset', FCode, []) then
    begin
      Edit;
      FieldByName('ADDescription').AsString := Value;
      Post;
    end;
  end;
end;

procedure TAssetBase.Initialize;

begin
  inherited;
  _AddRef;
end;

destructor TAssetBase.Destroy;
begin
  Inherited Destroy;
end;

function TAssetBase.Get_Name : WideString; safecall;
begin
  Result := FName;
end;

procedure TAssetBase.Set_Name(const Value :WideString); safecall;
begin
  If FName <> Value then
  begin
    FName := Value;
  end;
end;

end.
