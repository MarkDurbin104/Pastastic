unit AssetOwnerU;

interface

uses
  AssetManager_TLB, ComObj;

type
  TAssetOwner = class(TAutoObject, IAssetOwner)
  private
    FName   : String;
    FParent : IAssetOwner;
    FSite   : String;

    function Get_Name : WideString; safecall;
    procedure Set_Name(const Value : WideString); safecall;
    function Get_Parent : IAssetOwner; safecall;
    procedure Set_Parent(const Value : IAssetOwner); safecall;
    function Get_Site : WideString; safecall;
    procedure Set_Site(const Value : WideString); safecall;

  protected
    procedure Initialize; override;

  public
    property Name   : WideString read Get_Name write Set_Name;
    property Parent : IAssetOwner read Get_Parent write Set_Parent;
    property Site   : WideString read Get_Site write Set_Site;

  end;

implementation
uses
  ComServ2;

procedure TAssetOwner.Initialize;
begin
  _AddRef;
end;

function TAssetOwner.Get_Name : WideString;
begin
  Result := FName;
end;

procedure TAssetOwner.Set_Name(const Value : WideString);
begin
  If FName <> Value then
  begin
    Fname := Value;
  end;
end;

function TAssetOwner.Get_Parent : IAssetOwner;
begin
  Result := FParent;
end;

procedure TAssetOwner.Set_Parent(const Value : IAssetOwner);
begin
  If FParent <> Value then
  begin
    FParent := Value;
  end;
end;

function TAssetOwner.Get_Site : WideString;
begin
  Result := FSite;
end;

procedure TAssetOwner.Set_Site(const Value : WideString);
begin
  If FSite <> Value then
  begin
    FSite := Value;
  end;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TAssetOwner, Class_AssetOwner, ciInternal);

end.
