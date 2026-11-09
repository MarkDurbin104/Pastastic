unit TwainF;

interface

uses
	SavePosFormU,
	StringUtil,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OleCtrls, ScanLib_TLB, StdCtrls, ImgeditLib_TLB, ComCtrls, ExtCtrls,
  Buttons, ToolWin, Menus;


type
  TTwainForm = class(TSavePosForm)
    ImgScan: TImgScan;
    ClientPanel: TPanel;
    ImgEdit: TImgEdit;
    ZoomGroupBox: TGroupBox;
    ZoomTrackBar: TTrackBar;
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    FileExitMenu: TMenuItem;
    MainToolBar: TToolBar;
    ExitBitBtn: TBitBtn;
    StartBitBtn: TBitBtn;
    SetupMenu: TMenuItem;
    SetupNewMenu: TMenuItem;
    ScanPreviewMenu: TMenuItem;
    StopBitBtn: TBitBtn;
    SetupSelectScannerMenu: TMenuItem;
    SetupPagemenu: TMenuItem;
    SetupScanPreferencesMenu: TMenuItem;
    ZoomMenu: TMenuItem;
    ZoomToFitMenu: TMenuItem;
    Zoom10Menu: TMenuItem;
    Zoom50Menu: TMenuItem;
    Zoom100Menu: TMenuItem;
    Zoom200Menu: TMenuItem;
    Zoom500Menu: TMenuItem;
    Zoom1000Menu: TMenuItem;
    ZoomComboBox: TComboBox;
    ZoomSelectionMenu: TMenuItem;
    ZoomSelectionBitBtn: TBitBtn;
    CopyBitBtn: TBitBtn;
    ScanMenu: TMenuItem;
    ScanScanMenu: TMenuItem;
    FileSaveAsMenu: TMenuItem;
    FileSep1Menu: TMenuItem;
    EditMenu: TMenuItem;
    EditCopyMenu: TMenuItem;
    procedure StartScanButtonClick(Sender: TObject);
    procedure ZoomComboBoxChange(Sender: TObject);
    procedure ZoomTrackBarChange(Sender: TObject);
    procedure FileExitMenuClick(Sender: TObject);
    procedure SetupNewMenuClick(Sender: TObject);
    procedure ScanPreviewMenuClick(Sender: TObject);
    procedure StopBitBtnClick(Sender: TObject);
    procedure SetupSelectScannerMenuClick(Sender: TObject);
    procedure SetupPagemenuClick(Sender: TObject);
    procedure SetupScanPreferencesMenuClick(Sender: TObject);
    procedure StartBitBtnClick(Sender: TObject);
    procedure ExitBitBtnClick(Sender: TObject);
		procedure ZoomMenuClick(Sender : TObject);
    procedure ZoomSelectionBitBtnClick(Sender: TObject);
    procedure CopyBitBtnClick(Sender: TObject);
    procedure ImgEditSelectionRectDrawn(Sender: TObject; Left, Top, Width,
      Height: Integer);
    procedure ScanScanMenuClick(Sender: TObject);
    procedure EditCopyMenuClick(Sender: TObject);
  private
    { Private declarations }
    LastSelectionRect : TRect;
    procedure ZoomImage;
  public
    { Public declarations }

  end;

var
  TwainForm: TTwainForm;

implementation

{$R *.DFM}

procedure TTwainForm.StartScanButtonClick(Sender: TObject);
begin
	ImgScan.StartScan;
end;


procedure TTwainForm.ZoomComboBoxChange(Sender: TObject);
begin
  ZoomImage;
end;

procedure TTwainForm.ZoomTrackBarChange(Sender: TObject);
begin
	ZoomComboBox.Text := IntToStr(ZoomTrackBar.Position) + '%';
  ZoomImage;
end;

procedure TTwainForm.ZoomImage;
begin
	If ZoomComboBox.Text = 'Zoom to Fit' then ImgEdit.FitTo(0, True)
  else If ZoomComboBox.Text = 'Zoom to Selection' then ImgEdit.ZoomToSelection
  else ImgEdit.Zoom := StrToIntDef(DelimitedString(ZoomComboBox.Text,'%',False),100);
end;

procedure TTwainForm.FileExitMenuClick(Sender: TObject);
begin
	ExitBitBtnClick(Sender);
end;

procedure TTwainForm.SetupNewMenuClick(Sender: TObject);
begin
	ImgScan.ShowScanNew(True);
end;

procedure TTwainForm.ScanPreviewMenuClick(Sender: TObject);
begin
	ImgScan.ShowSetupBeforeScan := True;	//preview setup
  ImgScan.StartScan;
end;

procedure TTwainForm.StopBitBtnClick(Sender: TObject);
begin
	ImgScan.StopScan;
end;

procedure TTwainForm.SetupSelectScannerMenuClick(Sender: TObject);
begin
	ImgScan.ShowSelectScanner;
end;

procedure TTwainForm.SetupPagemenuClick(Sender: TObject);
begin
	ImgScan.ShowScanPage(True);
end;

procedure TTwainForm.SetupScanPreferencesMenuClick(Sender: TObject);
begin
	ImgScan.ShowScanPreferences;
end;

procedure TTwainForm.ZoomMenuClick(Sender : TObject);
var
	MenuItem : TMenuItem;
begin
	MenuItem := Sender as TMenuItem;
	If MenuItem.Caption = 'Zoom to &Fit' then ZoomComboBox.Text := 'Zoom to Fit'
  else If MenuItem.Caption = 'Zoom to &Selection' then ZoomComboBox.Text := 'Zoom to Selection'
	else ZoomComboBox.Text := MenuItem.Caption;
	ZoomImage;
end;

procedure TTwainForm.StartBitBtnClick(Sender: TObject);
begin
	ImgScan.ShowSetupBeforeScan := False;	//no preview setup
	ImgScan.StartScan;
end;

procedure TTwainForm.ExitBitBtnClick(Sender: TObject);
begin
	Close;
end;


procedure TTwainForm.ZoomSelectionBitBtnClick(Sender: TObject);
begin
	ZoomComboBox.Text := 'Zoom to Selection';
  ZoomImage;
end;

procedure TTwainForm.CopyBitBtnClick(Sender: TObject);
var
	ImgEditVar : Variant;
begin
	//use queryinterface to avoid problems with passing paramters with clipboardcopy
	ImgEditVar := ImgEdit.OleObject;
	ImgEditVar.ClipBoardCopy;
  ImgEditVar := UnAssigned;
end;

procedure TTwainForm.ImgEditSelectionRectDrawn(Sender: TObject; Left, Top,
  Width, Height: Integer);
begin
	If (Left + Top + Width + Height) <> 0 then //valid rect drawn
  	LastSelectionRect := Bounds(Left, Top, Width, Height);
end;

procedure TTwainForm.ScanScanMenuClick(Sender: TObject);
begin
	StartBitBtnClick(Sender);
end;

procedure TTwainForm.EditCopyMenuClick(Sender: TObject);
begin
	CopyBitBtnClick(Sender);
end;

end.
