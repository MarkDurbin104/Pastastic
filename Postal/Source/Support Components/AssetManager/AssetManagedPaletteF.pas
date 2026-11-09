unit AssetManagedPaletteF;

interface

uses
	AssetManager_TLB,
	AssetManagedF,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TAssetManagedPaletteForm = class(TAssetManagedForm)
  private
    { Private declarations }
  protected
  	procedure SetAssetManager(Value : IAssetManager); override;

  public
    { Public declarations }
  end;

var
  AssetManagedPaletteForm: TAssetManagedPaletteForm;

implementation

uses
	AssetManagerStructureNodeU;

{$R *.DFM}

procedure TAssetManagedPaletteForm.SetAssetManager(Value : IAssetManager);
var
  CompIndex : Integer;
begin
	Inherited;
  //update nodes' asset manager
  For CompIndex := 0 to ComponentCount -1 do
    If Components[CompIndex] is TAssetManagerStructureNode then
      (Components[CompIndex] as TAssetManagerStructureNode).AssetManager := Value;
end;



end.
