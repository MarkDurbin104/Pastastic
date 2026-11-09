unit AssetManagerStructureNodeU;

interface

uses
  AssetManager_TLB,
  SysUtils,Graphics,Classes,StructureNodeU, DropDownStructureNodeU,StructureNodeButtonU;

type
  TAssetManagerStructureNode = class(TDropDownStructureNode)
  private
    FAssetManager : IAssetManager;
  protected
    procedure Set_AssetManager(Value : IAssetManager); virtual;  
  public
    property AssetManager : IAssetManager read FAssetManager write Set_AssetManager;
  published
  end;

implementation

procedure TAssetManagerStructureNode.Set_AssetManager(Value : IAssetManager);
begin
  If FAssetManager <> Value then
  begin
    FAssetManager := Value;
  end;
end;

end.
 