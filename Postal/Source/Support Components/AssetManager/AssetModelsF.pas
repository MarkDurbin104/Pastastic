unit AssetModelsF;

interface

uses
	AssetManagedF,
  AssetManagerAU,
  AssetModelF,
  ComObj,
  AssetManager_TLB,
  ObjectBinary_TLB,
  SavePosFormU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StructureNodeButtonU, RecentListU, ExtCtrls;

type
  TAssetModelsForm = class(TAssetManagedForm)
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    FileSaveMenu: TMenuItem;
    FileMenuSep1: TMenuItem;
    FileExitMenu: TMenuItem;
    FileOpenMenu: TMenuItem;
    SaveDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    FileSaveAs: TMenuItem;
    ViewMenu: TMenuItem;
    ViewObjectTextMenu: TMenuItem;
    FileNewMenu: TMenuItem;
    FileCloseMenu: TMenuItem;
    RecentList: TRecentList;
    procedure FileSaveMenuClick(Sender: TObject);
    procedure FileOpenMenuClick(Sender: TObject);
    procedure FileSaveAsClick(Sender: TObject);
    procedure FileExitMenuClick(Sender: TObject);
    procedure ViewObjectTextMenuClick(Sender: TObject);
    procedure FileNewMenuClick(Sender: TObject);
    procedure FileCloseMenuClick(Sender: TObject);
    procedure RecentListRecentClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }

    procedure SaveModel;
    procedure SaveModelAs(SaveFileName : String);
  public
    { Public declarations }
    ActiveModel : TAssetModel
  end;

var
  AssetModelsForm: TAssetModelsForm;
  ObjectBinary : IObjectBinaryAuto;


implementation

uses
  StringUtil,
  StructureNodeU, AssetNodeU,AssetPaletteF, AssetTriggerPaletteF, AssetTriggerNodeU;

{$R *.DFM}

procedure TAssetModelsForm.FileSaveMenuClick(Sender: TObject);
begin
  SaveModel;
end;

procedure TAssetModelsForm.SaveModel;
begin
  If ActiveModel <> nil then
    SaveModelAs( DelimitedString(ActiveModel.Form.Caption,' - ', True))
  else
    MessageDlg('No active model.', mtError, [mbOk], 0);
end;

procedure TAssetModelsForm.SaveModelAs(SaveFileName : String);
begin

  //reset save file name
  If (SaveFileName = 'Untitled') then
    SaveFileName := '';

  //get filename if nec
  If (SaveFileName = '') then
    If SaveDialog.Execute then
      SaveFileName := SaveDialog.FileName;

  //check for valid filename
  If SaveFileName <> '' then
  begin
    ActiveModel.SaveToFile(SaveFileName);
    RecentList.AddRecent(SaveFileName);
  end;
end;

procedure TAssetModelsForm.FileOpenMenuClick(Sender: TObject);
begin
  If OpenDialog.Execute then
    AssetManager.OpenModel(OpenDialog.Filename);
end;

procedure TAssetModelsForm.FileSaveAsClick(Sender: TObject);
begin
  SaveModelAs('');
end;

procedure TAssetModelsForm.FileExitMenuClick(Sender: TObject);
begin
  Close;
end;

procedure TAssetModelsForm.ViewObjectTextMenuClick(Sender: TObject);
begin
  ViewObjectTextMenu.Checked := not ViewObjectTextMenu.Checked;
  If ViewObjectTextMenu.Checked then
  begin
  	try
      ObjectBinary := CreateOleObject('ObjectBinary.ObjectBinaryAuto') as IObjectBinaryAuto;
      ObjectBinary.FileName :=   DelimitedString(Caption,' - ', True);
      ObjectBinary.Visible := True;
    except
    	ShowMessage('Unable to start Object Binary Viewer');
			ObjectBinary := nil;
    end;
  end
  else
  begin
    ObjectBinary := nil;
  end;
end;

procedure TAssetModelsForm.FileNewMenuClick(Sender: TObject);
var
  NewAssetModel : TAssetModel;
begin
  NewAssetModel := TAssetModel.Create;
  NewAssetModel.Manager := AssetManager;
  NewAssetModel.Form.Left := 0;
  NewAssetModel.Form.Top := 0;
  If NewAssetModel.Form.Width > (Width -20) then
  	NewAssetModel.Form.Width := Width -20;
  If NewAssetModel.Form.Height > (Height -50) then
  	NewAssetModel.Form.Height := Height -50;
  NewAssetModel.Form.Visible := True;
  NewAssetModel.Form.Parent := self;  
  ActiveModel := NewAssetModel;

end;

procedure TAssetModelsForm.FileCloseMenuClick(Sender: TObject);
begin
	If ActiveModel <> nil then
  begin
    RecentList.AddRecent(ActiveModel.FileName);
    AssetManager.CloseModel(ActiveModel.FileName);
  end;
end;

procedure TAssetModelsForm.RecentListRecentClick(Sender: TObject);
begin
  AssetManager.OpenModel((Sender As TMenuItem).Caption);
end;

procedure TAssetModelsForm.FormDestroy(Sender: TObject);
begin
  AssetManager := nil;
end;

end.
