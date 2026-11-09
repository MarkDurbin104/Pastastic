unit MainF;

interface

uses
  AssetManagerAu,
  SavePosFormU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, ToolWin, ComCtrls, OleCtrls, vcf1, Menus, RecentListU,
  StdCtrls, bi_btns;

const
  FIXED_HEIGHT = 72;
  MAX_HEIGHT = 52;

type
  TMainForm = class(TSavePosForm)
    AssetToolButton: TBI_GradientButton;
    AssetUnitToolButton: TBI_GradientButton;
    AssetTriggerToolButton: TBI_GradientButton;
    MainMenu: TMainMenu;
    ViewMenu: TMenuItem;
    ViewUserMenu: TMenuItem;
    FileMenu: TMenuItem;
    FileExitMenu: TMenuItem;
    ViewAssetMenu: TMenuItem;
    ViewTriggersMenu: TMenuItem;
    UserToolButton: TBI_GradientButton;
    ViewModelsMenu: TMenuItem;
    AssetModelsToolButton: TBI_GradientButton;
    procedure AssetToolButtonClick(Sender: TObject);
    procedure AssetUnitToolButtonClick(Sender: TObject);
    procedure AssetTriggerToolButtonClick(Sender: TObject);
    procedure FileExitMenuClick(Sender: TObject);
    procedure ViewUserMenuClick(Sender: TObject);
    procedure ViewAssetMenuClick(Sender: TObject);
    procedure ViewTriggersMenuClick(Sender: TObject);
    procedure UserToolButtonClick(Sender: TObject);
    procedure ViewModelsMenuClick(Sender: TObject);
    procedure AssetModelsToolButtonClick(Sender: TObject);
  private
    { Private declarations }
    procedure WMWindowPosChanging(var Message  : TWMWindowPosMsg); message WM_WindowPosChanging;
  public
    { Public declarations }
    AssetManager : TAssetManager;
  end;

var
  MainForm: TMainForm;

implementation

uses AssetPaletteF, AssetBalanceF, AssetUnitPaletteF, AssetTriggerPaletteF,
  UserF, AssetModelsF, AssetModelsPaletteF;

{$R *.DFM}

procedure TMainForm.WMWindowPosChanging(var Message  : TWMWindowPosMsg);
begin
  If Message.WindowPos.cy <> FIXED_HEIGHT then
    Message.WindowPos.cy := FIXED_HEIGHT;
end;

procedure TMainForm.AssetToolButtonClick(Sender: TObject);
begin
  AssetToolButton.Down := not AssetToolButton.Down;
  AssetPaletteForm.Visible := AssetToolButton.Down;
  AssetBalanceForm.Visible := AssetToolButton.Down;
end;

procedure TMainForm.AssetUnitToolButtonClick(Sender: TObject);
begin
  AssetUnitToolButton.Down := not AssetUnitToolButton.Down;
  AssetUnitPaletteForm.Visible := AssetUnitToolButton.Down;
end;

procedure TMainForm.AssetTriggerToolButtonClick(Sender: TObject);
begin
  AssetTriggerToolButton.Down := not AssetTriggerToolButton.Down;
  AssetTriggerPaletteForm.Visible := AssetTriggerToolButton.Down;
end;

procedure TMainForm.FileExitMenuClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.ViewUserMenuClick(Sender: TObject);
begin
  ViewUserMenu.Checked  := not ViewUserMenu.Checked;
  UserToolButton.Down   := ViewUserMenu.Checked;
  UserForm.Visible      := ViewUserMenu.Checked;
  UserForm.AssetManager := AssetManager;
  UserForm.Show;

end;

procedure TMainForm.ViewAssetMenuClick(Sender: TObject);
begin
  ViewAssetMenu.Checked := not ViewAssetMenu.Checked;
  AssetPaletteForm.Visible := ViewAssetMenu.Checked;
  AssetToolButton.Down := ViewAssetMenu.Checked;
end;


procedure TMainForm.ViewTriggersMenuClick(Sender: TObject);
begin
  ViewTriggersMenu.Checked := not ViewTriggersMenu.Checked;
  AssetTriggerPaletteForm.Visible := ViewTriggersMenu.Checked;
  AssetTriggerToolButton.Down := ViewTriggersMenu.Checked;
end;

procedure TMainForm.UserToolButtonClick(Sender: TObject);
begin
  UserToolButton.Down := not UserToolButton.Down;
  UserForm.Visible := UserToolButton.Down;
end;

procedure TMainForm.ViewModelsMenuClick(Sender: TObject);
begin
  AssetModelsPaletteForm.Visible := AssetModelsToolButton.Down;
  AssetModelsForm.Visible := True;
end;

procedure TMainForm.AssetModelsToolButtonClick(Sender: TObject);
begin
  AssetModelsToolButton.Down := not AssetModelsToolButton.Down;
  AssetModelsForm.Visible := AssetModelsToolButton.Down;
  AssetModelsPaletteForm.Visible := AssetModelsToolButton.Down;
end;

end.
