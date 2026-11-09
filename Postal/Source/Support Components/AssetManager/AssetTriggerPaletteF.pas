unit AssetTriggerPaletteF;

interface

uses
	AssetManagedPaletteF,
  AssetManager_TLB,
  ComObj,
  GPCSRegistry,
  SavePosFormU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, ComCtrls, ToolWin, ExtCtrls, StdCtrls, DBCtrls,
  AssetManagedF;

type
  TAssetTriggerPaletteForm = class(TAssetManagedPaletteForm)
    MainPageControl: TPageControl;
    ListViewTabSheet: TTabSheet;
    ViewToolBar: TToolBar;
    ViewStyleToolButton: TToolButton;
    AssetTriggerListView: TListView;
    DataTabSheet: TTabSheet;
    AssetUnitDescriptionDBGrid: TDBGrid;
    ToolBarImageList: TImageList;
    ListViewImageList: TImageList;
    ImageList1: TImageList;
    CodeDBMemo: TDBMemo;
    DataSplitter: TSplitter;
    NodesTabSheet: TTabSheet;
    NodesScrollBox: TScrollBox;
    procedure FormCreate(Sender: TObject);
    procedure ViewStyleToolButtonClick(Sender: TObject);
  private
    { Private declarations }
    procedure FillAssetTriggerList;

  public
    { Public declarations }
  end;

var
  AssetTriggerPaletteForm: TAssetTriggerPaletteForm;

implementation

uses
  StringUtil,
  AssetTriggerNodeU, AssetManagerDM, MainF;

{$R *.DFM}

procedure TAssetTriggerPaletteForm.FormCreate(Sender: TObject);
begin
  //determine whether to show or not
  Visible := MainForm.AssetTriggerToolButton.Down;
  //populate list view with available asset triggers
  FillAssetTriggerList;
end;

procedure TAssetTriggerPaletteForm.FillAssetTriggerList;
var
  GPCSReg : TGPCSRegistry;
  TriggerStringList : TStringList;
  NewAssetTriggerNode : TAssetTriggerNode;
  NodeIndex : Integer;
begin
  GPCSReg := TGPCSRegistry.Create;
  try
    GPCSReg.LoadFromRegistry;
    TriggerStringList := GPCSReg.CreateCompList('Others', 'AssetTrigger');
    try
      With AssetTriggerListView.Items do
      begin
        Clear;
        NodeIndex := 0;
        While NodeIndex <= TriggerStringList.Count -1 do
        begin
          //add to list view
          With AssetTriggerListView.Items.Add do
          begin
            //Caption := AssetManagerDataModule.AssetTriggerTableATName.AsString;
            //SubItems.Add(AssetManagerDataModule.AssetTriggerTableATCode.AsString);
            Caption := DelimitedString(TriggerStringList[NodeIndex],',', True);;
          end;  //with AssetTriggerListView

          //add to nodes
          NewAssetTriggerNode := TAssetTriggerNode.Create(self);
          With NewAssetTriggerNode do
          begin
            Parent := NodesScrollBox;
            Name := 'Node' + IntToStr(NodeIndex);
            NewAssetTriggerNode.DragMode := dmAutomatic;
            NewAssetTriggerNode.Left := 0;
            NewAssetTriggerNode.Top := NodeIndex * NewAssetTriggerNode.Height;
            Caption := DelimitedString(TriggerStringList[NodeIndex],'.', True);
						NewAssetTriggerNode.AssetManager := self.AssetManager;
            Inc(NodeIndex);
          end;  //with AssetTriggerNode

        end; //While NodeIndex <= TriggerStringList.Count -1
      end;  //With AssetTriggerListView.Items do
    finally
      TriggerStringList.Free;
    end;
  finally
    GPCSReg.Free;

  end;
end;

procedure TAssetTriggerPaletteForm.ViewStyleToolButtonClick(Sender: TObject);
var
  NewViewStyle : Integer;
begin
  NewViewStyle := (Integer(AssetTriggerListView.ViewStyle) + 1) Mod (Integer(High(TViewStyle))+1);
  AssetTriggerListView.ViewStyle  := TViewStyle(NewViewStyle);
end;


end.
