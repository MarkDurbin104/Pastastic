unit AssetManagedU;

interface

uses
  ComObj, AssetManager_TLB;

type
  TAssetManaged = class(TAutoObject)
  private
    FManager : IAssetManager;
  protected
    function Get_Manager : IAssetManager; safecall;
    procedure Set_Manager(const Value : IAssetManager); virtual; safecall;
  public
    property Manager : IAssetManager read Get_Manager write Set_Manager;
  end;

implementation

function TAssetManaged.Get_Manager : IAssetManager;
begin
  Result := FManager;
end;

procedure TAssetManaged.Set_Manager(const Value : IAssetManager);
begin
  If FManager <> Value then
  begin
    FManager := Value;
  end;
end;

end.
 