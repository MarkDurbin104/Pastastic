unit AssetModelsPaletteF;

interface

uses
	AssetManager_TLB,
	AssetManagedPaletteF,
	SavePosFormU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  AssetManagedF, StdCtrls, FileCtrl, ExtCtrls;

type
  TAssetModelsPaletteForm = class(TAssetManagedPaletteForm)
    AssetModelPanel: TPanel;
    AssetModelFileListBox: TFileListBox;
    AssetModelDirectoryListBox: TDirectoryListBox;
    AssetModelTopPanel: TPanel;
    DriveComboBox: TDriveComboBox;
    procedure FormCreate(Sender: TObject);
    procedure AssetModelDirectoryListBoxChange(Sender: TObject);
  private
    { Private declarations }
		procedure ClearAssetModelList;
		procedure FillAssetModelList;
  protected
  public
    { Public declarations }
    procedure AddModel(ModelName : String);
    procedure RemoveModel(ModelName : String);

  end;

var
  AssetModelsPaletteForm: TAssetModelsPaletteForm;

implementation
uses
  GPCSRegistry,
  StringUtil,
	ComponentUtil,
	AssetModelNodeU;

{$R *.DFM}

procedure TAssetModelsPaletteForm.ClearAssetModelList;
var
  ControlIndex : Integer;
begin
	For ControlIndex := ControlCount-1 downto 0 do
  begin
  	If Controls[ControlIndex] is TAssetModelNode then
    	RemoveModel((Controls[ControlIndex] as TAssetModelNode).Caption);
  end;
end;

procedure TAssetModelsPaletteForm.FillAssetModelList;
var
  ModelIndex : Integer;
begin
	For ModelIndex := 0 to AssetModelFileListBox.Items.Count -1 do
  begin
		AssetModelFileListBox.ItemIndex := ModelIndex;
  	AddModel(AssetModelFileListBox.FileName);
  end;
end;


procedure TAssetModelsPaletteForm.AddModel(ModelName : String);
var
	AssetModelFound : Boolean;
	AssetModelNode 	: TAssetModelNode;
	ControlIndex 		: Integer;
  ModelCount 			: Integer;
begin

	//try to find the model node
  AssetModelFound := False;
	ControlIndex := 0;
  ModelCount := 0;
  While (ControlIndex <= ControlCount -1) and (not AssetModelFound) do
  begin
  	If Controls[ControlIndex] is TAssetModelNode then
    begin
    	Inc(ModelCount);
    	If (Controls[ControlIndex] as TAssetModelNode).Caption = ModelName then
      	AssetModelFound := True;
    end;
    Inc(ControlIndex);
  end;

	//add new node if required
  If not AssetModelFound then
  begin
    //add to form
    AssetModelNode := TAssetModelNode.Create(self);
    AssetModelNode.Parent := self;
    AssetModelNode.Name := ValidControlName(AssetModelNode);
    AssetModelNode.DragMode := dmAutomatic;
    AssetModelNode.Left := 0;
    AssetModelNode.Top := (ModelCount) * AssetModelNode.Height;
    AssetModelNode.Caption := ModelName;
    AssetModelNode.AssetManager := AssetManager;
  end;
end;

procedure TAssetModelsPaletteForm.RemoveModel(ModelName : String);
var
	AssetModelNode : TAssetModelNode;
	ControlIndex : Integer;
begin

	AssetModelNode := nil;

	//try to find the model node
	ControlIndex := -1;	//incremented immeditaley in loop
  While (AssetModelNode = nil) and (ControlIndex <= ControlCount -1)do
  begin
    Inc(ControlIndex);
		If Controls[ControlIndex] is TAssetModelNode then
    begin
    	AssetModelNode := Controls[ControlIndex] as TAssetModelNode;
    	If AssetModelNode.Caption <> ModelName then
      	AssetModelNode := nil;
    end;
  end;

	//remove node if found
  If AssetModelNode <> nil then
  begin
    AssetModelNode.Parent := nil;
    AssetModelNode.Free;
  end;
end;

procedure TAssetModelsPaletteForm.FormCreate(Sender: TObject);
begin
	FillAssetModelList;
end;

procedure TAssetModelsPaletteForm.AssetModelDirectoryListBoxChange(
  Sender: TObject);
begin
	ClearAssetModelList;
  FillAssetModelList;
end;

end.
