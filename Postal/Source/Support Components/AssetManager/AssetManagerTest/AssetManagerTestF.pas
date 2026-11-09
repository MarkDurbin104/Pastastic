unit AssetManagerTestF;

interface

uses
  SavePosFormU,
  AssetManager_TLB,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, FileCtrl, Grids, DBGrids, Db, DBTables, ComCtrls;

type
  TAssetManagerTestForm = class(TSavePosForm)
    PageControl: TPageControl;
    AssetEntryTabSheet: TTabSheet;
    PersonGroupBox: TGroupBox;
    SiteLabel: TLabel;
    WorkstationLabel: TLabel;
    PersonLabel: TLabel;
    SiteEdit: TEdit;
    WorkstationEdit: TEdit;
    PersonEdit: TEdit;
    SetPersonButton: TButton;
    AssetEntryGroupBox: TGroupBox;
    AssetCodeLabel: TLabel;
    AssetAmountLabel: TLabel;
    AssetUnitsLabel: TLabel;
    AssetCodeEdit: TEdit;
    AssetAmountEdit: TEdit;
    AssetUnitsEdit: TEdit;
    LogAssetEntryButton: TButton;
    AssetModelsGroupBox: TGroupBox;
    AssetModelLabel: TLabel;
    AssetModelAddButton: TButton;
    DriveComboBox: TDriveComboBox;
    DirectoryListBox: TDirectoryListBox;
    AssetModelFileListBox: TFileListBox;
    AssetBalanceTabSheet: TTabSheet;
    AssetBalanceTable: TTable;
    AssetBalanceDataSource: TDataSource;
    AssetBalanceDBGrid: TDBGrid;
    procedure FormDestroy(Sender: TObject);
    procedure SetPersonButtonClick(Sender: TObject);
    procedure LogAssetEntryButtonClick(Sender: TObject);
    procedure AssetModelAddButtonClick(Sender: TObject);
    procedure AssetBalanceTabSheetEnter(Sender: TObject);
  private
    { Private declarations }
    AssetManager : IAssetManager;
    procedure CreateAssetManager;
    procedure SetPerson;
  public
    { Public declarations }
  end;

var
  AssetManagerTestForm: TAssetManagerTestForm;

implementation

uses
  ComObj;

{$R *.DFM}

procedure TAssetManagerTestForm.CreateAssetManager;
begin
  If AssetManager = nil then
    AssetManager := CreateComObject(Class_AssetManager) As IAssetManager;
end;

procedure TAssetManagerTestForm.SetPerson;
begin
  AssetManager.Site := SiteEdit.Text;
  AssetManager.Workstation := WorkstationEdit.Text;
  AssetManager.Person := AssetManager.Owners[PersonEdit.Text];
  LogAssetEntryButton.Enabled := True;
end;

procedure TAssetManagerTestForm.FormDestroy(Sender: TObject);
begin
  AssetManager := nil;
end;

procedure TAssetManagerTestForm.SetPersonButtonClick(Sender: TObject);
begin
  CreateAssetManager;
  SetPerson;
end;

procedure TAssetManagerTestForm.LogAssetEntryButtonClick(Sender: TObject);
var
  AssetQuantity : IAssetQuantity;
begin
    CreateAssetManager;
  SetPerson;

  AssetQuantity :=
    AssetManager.CreateAssetQuantity(
      StrToCurr(AssetAmountEdit.Text),
      AssetUnitsEdit.Text);

  AssetManager.AddAssetEntry(AssetCodeEdit.Text,AssetQuantity);
  AssetQuantity := nil;
end;

procedure TAssetManagerTestForm.AssetModelAddButtonClick(Sender: TObject);
begin
  CreateAssetManager;
  AssetManager.OpenModel(AssetModelFileListBox.FileName);
end;

procedure TAssetManagerTestForm.AssetBalanceTabSheetEnter(Sender: TObject);
begin
  AssetBalanceTable.Refresh;
end;

end.
