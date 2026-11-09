unit AssetPaletteF;

interface

uses
  AssetManager_TLB,
  AssetManagedF,
  AssetManagerDM,
  SavePosFormU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Db, DBTables, ToolWin, Grids, DBGrids;

type
  TAssetPaletteForm = class(TAssetManagedForm)
    ToolBarImageList: TImageList;
    ListViewImageList: TImageList;
    MainPageControl: TPageControl;
    ListViewTabSheet: TTabSheet;
    ViewToolBar: TToolBar;
    ViewStyleToolButton: TToolButton;
    AssetListView: TListView;
    DataTabSheet: TTabSheet;
    AssetGroupDescriptionDBGrid: TDBGrid;
    ImageList1: TImageList;
    NodesTabSheet: TTabSheet;
    NodesScrollBox: TScrollBox;
    procedure FormCreate(Sender: TObject);
    procedure ViewStyleToolButtonClick(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure SetAssetManager(Value : IAssetManager); override;
  public
    { Public declarations }
  end;

var
  AssetPaletteForm: TAssetPaletteForm;

implementation

uses
  AssetNodeU;

{$R *.DFM}

procedure TAssetPaletteForm.SetAssetManager(Value : IAssetManager);
var
  CompIndex : Integer;
begin
	Inherited;
  If AssetManager <> Value then
    //change asset nodes
    For CompIndex := 0 to self.ComponentCount -1 do
      If Components[CompIndex] is TAssetNode then
        (Components[CompIndex] as TAssetNode).AssetManager := Value;
end;

procedure TAssetPaletteForm.FormCreate(Sender: TObject);
var
  NewAssetNode : TAssetNode;
  NodeIndex : Integer;
begin
  //populate account list view with available account groups
  With AssetListView.Items do
  begin
    Clear;
    AssetManagerDataModule.AssetDescriptionTable.Active := True;
    AssetManagerDataModule.AssetDescriptionTable.First;
    NodeIndex := 0;
    While not AssetManagerDataModule.AssetDescriptionTable.EOF do
    begin
      With Add do
      begin
        Caption := AssetManagerDataModule.AssetDescriptionTableADDescription.AsString;
        SubItems.Add(AssetManagerDataModule.AssetDescriptionTableADAsset.AsString);
        SubItems.Add(AssetManagerDataModule.AssetDescriptionTableADDisplayOrder.AsString);
      end;

      //add to nodes box
      NewAssetNode := TAssetNode.Create(self);
      NewAssetNode.Parent := NodesScrollBox;
      NewAssetNode.Name := 'Node' + IntToStr(NodeIndex);
      NewAssetNode.DragMode := dmAutomatic;
      NewAssetNode.Left := 0;
      NewAssetNode.Top := NodeIndex * NewAssetNode.Height;
      NewAssetNode.Caption := AssetManagerDataModule.AssetDescriptionTableADAsset.AsString;
      Inc(NodeIndex);
      AssetManagerDataModule.AssetDescriptionTable.Next;
    end;
  end;
end;

procedure TAssetPaletteForm.ViewStyleToolButtonClick(Sender: TObject);
var
  NewViewStyle : Integer;
begin
  NewViewStyle := (Integer(AssetListView.ViewStyle) + 1) Mod (Integer(High(TViewStyle))+1);
  AssetListView.ViewStyle  := TViewStyle(NewViewStyle);
end;

end.
