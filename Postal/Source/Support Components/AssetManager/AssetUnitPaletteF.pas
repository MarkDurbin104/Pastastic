unit AssetUnitPaletteF;

interface

uses
	AssetManagedF,
  AssetManagerDM,
  SavePosFormU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Db, DBTables, ToolWin, Grids, DBGrids;

type
  TAssetUnitPaletteForm = class(TAssetManagedForm)
    ToolBarImageList: TImageList;
    ListViewImageList: TImageList;
    MainPageControl: TPageControl;
    ListViewTabSheet: TTabSheet;
    ViewToolBar: TToolBar;
    ViewStyleToolButton: TToolButton;
    AssetUnitListView: TListView;
    DataTabSheet: TTabSheet;
    AssetUnitDescriptionDBGrid: TDBGrid;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure ViewStyleToolButtonClick(Sender: TObject);
  private
    { Private declarations }
    AssetUnitList : TStringList;
    procedure FillAssetUnitList;

  public
    { Public declarations }
  end;

var
  AssetUnitPaletteForm: TAssetUnitPaletteForm;

implementation

uses MainF;

{$R *.DFM}

procedure TAssetUnitPaletteForm.FormCreate(Sender: TObject);
begin
  //determine whether to show or not
  Visible := MainForm.AssetUnitToolButton.Down;
  //populate account list view with available account groups
  FillAssetUnitList;
end;

procedure TAssetUnitPaletteForm.FillAssetUnitList;
begin
  //ensure list for asset units is available
  If AssetUnitList = nil then
    AssetUnitList := TStringList.Create;

  With AssetUnitListView.Items do
  begin
    Clear;
    AssetManagerDataModule.AssetUnitTable.Active := True;
    AssetManagerDataModule.AssetUnitTable.First;
    While not AssetManagerDataModule.AssetUnitTable.EOF do
    begin
      //add to list view
      With AssetUnitListView.Items.Add do
      begin
        Caption := AssetManagerDataModule.AssetUnitTableAUName.AsString;
        SubItems.Add(AssetManagerDataModule.AssetUnitTableAUExchange.AsString);
      end;

      //add to list
      

      AssetManagerDataModule.AssetUnitTable.Next;
    end;
  end;
end;

procedure TAssetUnitPaletteForm.ViewStyleToolButtonClick(Sender: TObject);
var
  NewViewStyle : Integer;
begin
  NewViewStyle := (Integer(AssetUnitListView.ViewStyle) + 1) Mod (Integer(High(TViewStyle))+1);
  AssetUnitListView.ViewStyle  := TViewStyle(NewViewStyle);
end;

end.
