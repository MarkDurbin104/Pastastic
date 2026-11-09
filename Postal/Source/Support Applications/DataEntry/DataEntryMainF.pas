unit DataEntryMainF;

interface

uses
	DataEntryProblemF,
	DataControlPaletteF,
	StringUtil,
	DragLabelU,
	TwainF,
	SavePosFormU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBTables, Db, Grids, DBGrids, StdCtrls, ComCtrls, ExtCtrls, DBCtrls,
  Buttons, Menus, RecentListU,DBCompressImageU;

type

  TDataEntryMainForm = class(TSavePosForm)
    TopPanel: TPanel;
    NewFormSpeedButton: TSpeedButton;
    ExitSpeedButton: TSpeedButton;
    MainMenu: TMainMenu;
    WindowMenu: TMenuItem;
    SaveDialog: TSaveDialog;
    OpenFormSpeedButton: TSpeedButton;
    OpenDialog: TOpenDialog;
    DesignFormSpeedButton: TSpeedButton;
    SaveFormSpeedButton: TSpeedButton;
    FileMenu: TMenuItem;
    FileOpenMenu: TMenuItem;
    FileSaveMenu: TMenuItem;
    FileSaveAsMenu: TMenuItem;
    FileSep1Menu: TMenuItem;
    FileExitMenu: TMenuItem;
    FileNewMenu: TMenuItem;
    DesignMenu: TMenuItem;
    FileCloseMenu: TMenuItem;
    RecentList: TRecentList;
    ViewMenu: TMenuItem;
    ViewTablesMenu: TMenuItem;
    ViewControlsMenu: TMenuItem;
    ViewTwainMenu: TMenuItem;
    TwainSpeedButton: TSpeedButton;
    ViewOrderMenu: TMenuItem;
    procedure ExitSpeedButtonClick(Sender: TObject);
    procedure NewFormSpeedButtonClick(Sender: TObject);
    procedure OpenFormSpeedButtonClick(Sender: TObject);
    procedure DesignFormSpeedButtonClick(Sender: TObject);
    procedure SaveFormSpeedButtonClick(Sender: TObject);
    procedure FileExitMenuClick(Sender: TObject);
    procedure FileOpenMenuClick(Sender: TObject);
    procedure FileSaveMenuClick(Sender: TObject);
    procedure FileSaveAsMenuClick(Sender: TObject);
    procedure FileNewMenuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FileCloseMenuClick(Sender: TObject);
    procedure DesignMenuClick(Sender: TObject);
    procedure WindowMenuClick(Sender: TObject);
    procedure RecentListRecentClick(Sender: TObject);
    procedure ViewMenuClick(Sender: TObject);
    procedure TwainSpeedButtonClick(Sender: TObject);
    procedure ViewOrderMenuClick(Sender: TObject);
  private
    { Private declarations }
		procedure ApplicationException(Sender: TObject; E: Exception);
		procedure OpenForm(FormName : String);
  public
    { Public declarations }
    ActiveDataEntryForm : TForm;
  end;

var
  DataEntryMainForm: TDataEntryMainForm;

implementation

{$R *.DFM}


uses
  NavOrderF,
	DataEntryTableF,
	DataEntryFormF;

procedure TDataEntryMainForm.ExitSpeedButtonClick(Sender: TObject);
begin
	Close;
end;

procedure TDataEntryMainForm.NewFormSpeedButtonClick(Sender: TObject);
var
	NewDataEntryForm : TDataEntryFormForm;
begin
	NewDataEntryForm 												:= TDataEntryFormForm.Create(Application);
  NewDataEntryForm.Designing 							:= DesignFormSpeedButton.Down;
  NewDataEntryForm.WindowMenuItem 				:= TMenuItem.Create(NewDataEntryForm);
	NewDataEntryForm.Caption 								:= NewDataEntryForm.Caption + ' ' + IntToStr(WindowMenu.Count +1);
  NewDataEntryForm.WindowMenuItem.Caption := '&' + IntToStr(WindowMenu.Count+1) + ' ' + NewDataEntryForm.Caption;
	NewDataEntryForm.WindowMenuItem.OnClick := WindowMenuClick;
  WindowMenu.Add(NewDataEntryForm.WindowMenuItem);
	NewDataEntryForm.Visible := True;
end;

procedure TDataEntryMainForm.OPenForm(Formname : String);
var
	OPenedForm : TDataEntryFormForm;
  FileStream : TFileStream;
begin
	If (FormName = '') and (OpenDialog.Execute) then FormName := OpenDialog.FileName;
	If FormName <> '' then
  begin
    OpenedForm := TDataEntryFormForm.Create(Application);
    While OpenedForm.ComponentCount > 0 do OpenedForm.Components[0].Free;
    FileStream := TFileStream.Create(FormName,fmOpenRead);
    try
      FileStream.ReadComponent(OpenedForm);
    finally
      FileStream.Free;
    end;

		//create an inplace edit;
    OpenedForm.InPlaceEdit := TInPlaceEdit.Create(OpenedForm);
    OpenedForm.InPlaceEdit.Parent := OpenedForm;
    OpenedForm.InPlaceEdit.Visible := False;

    //set autopopup menu
		OpenedForm.ControlPopupMenu.AutoPopup := OpenedForm.Designing;

    //add to window menu
    OpenedForm.WindowMenuItem := TMenuItem.Create(self);
    OpenedForm.WindowMenuItem.Caption := '&' + IntToStr(WindowMenu.Count + 1) + ' ' +OpenedForm.Caption;
    OpenedForm.WindowMenuItem.OnClick := WindowMenuClick;
    WindowMenu.Add(OpenedForm.WindowMenuItem);


  end;
end;

procedure TDataEntryMainForm.OpenFormSpeedButtonClick(Sender: TObject);
begin
	OpenForm('');
end;

procedure TDataEntryMainForm.DesignFormSpeedButtonClick(Sender: TObject);
begin
	If ActiveDataEntryForm <> nil then
		(ActiveDataEntryForm as TDataEntryFormForm).Designing := DesignFormSpeedButton.Down;
  DesignMenu.Checked := DesignFormSpeedButton.Down;

end;

procedure TDataEntryMainForm.SaveFormSpeedButtonClick(Sender: TObject);
begin
	If ActiveDataEntryForm <> nil then
  	(ActiveDataEntryForm as TDataEntryFormForm).SaveForm;
end;

procedure TDataEntryMainForm.FileExitMenuClick(Sender: TObject);
begin
	Close;
end;

procedure TDataEntryMainForm.FileOpenMenuClick(Sender: TObject);
begin
	OpenFormSpeedButtonClick(Sender);
end;

procedure TDataEntryMainForm.FileSaveMenuClick(Sender: TObject);
begin
	SaveFormSpeedButtonClick(Sender);
end;

procedure TDataEntryMainForm.FileSaveAsMenuClick(Sender: TObject);
begin
	SaveDialog.Title := 'Save Form As';
	If (ActiveDataEntryForm <> nil) and (DataEntryMainForm.SaveDialog.Execute) then
  begin
    (ActiveDataEntryForm as TDataEntryFormForm).Caption := DataEntryMainForm.SaveDialog.FileName;
    (ActiveDataEntryForm as TDataEntryFormForm).SaveForm;
  end;
end;

procedure TDataEntryMainForm.FileNewMenuClick(Sender: TObject);
begin
	NewFormSpeedButtonClick(Sender);
end;

procedure TDataEntryMainForm.ApplicationException(Sender: TObject; E: Exception);
var
	ErrorIndex : Integer;
  DBEngineError : EDBEngineError;
begin
	DataEntryProblemForm.ProblemMemo.Clear;
  If E is EDBEngineError then
  begin
  	DBEngineError := E as EDBEngineError;
  	For ErrorIndex := 0 to DBEngineError.ErrorCount -1 do
    	DataEntryProblemForm.ProblemMemo.Lines.Add(DBEngineError.Errors[ErrorIndex].Message);
  end
  else
		DataEntryProblemForm.ProblemMemo.Text := E.Message;  

	DataEntryProblemForm.ShowModal;

end;

procedure TDataEntryMainForm.FormCreate(Sender: TObject);
var
	ParamIndex 		: Integer;
  FormToOpen  	: String;
begin
	ChDir(ExtractFilePath(Application.ExeName));
  Application.OnException := ApplicationException;

  //check startup forms
  for ParamIndex := 1 to ParamCount do
  begin
  	If UpperCase(LeftString(ParamStr(ParamIndex),6)) = '/FORM:' then
    begin
    	//hide design tools
      NewFormSpeedButton.Visible := False;
      SaveFormSpeedButton.Visible := False;
      DesignFormSpeedButton.Visible := False;
      FileSaveMenu.Visible := False;
      FileSaveAsMenu.Visible := False;
      FileNewMenu.Visible := False;
      DesignMenu.Visible := False;
      ViewTablesMenu.Visible := False;
      ViewControlsMenu.Visible := False;
			FormToOpen := DelimitedString(ParamStr(ParamIndex),':', True);
			OpenForm(EnsureSuffix(FormToOpen, '.def'));
    end;
  end;
end;

procedure TDataEntryMainForm.FileCloseMenuClick(Sender: TObject);
begin
	If ActiveDataEntryForm <> nil then
		ActiveDataEntryForm.Close; 
end;

procedure TDataEntryMainForm.DesignMenuClick(Sender: TObject);
begin
	DesignFormSpeedButton.Down := not DesignFormSpeedButton.Down;
	DesignFormSpeedButtonClick(Sender);
end;

procedure TDataEntryMainForm.WindowMenuClick(Sender: TObject);
var
	FormIndex : Integer;
begin
	If ((Sender is TMenuItem)) and ((Sender as TMenuItem).Parent = WindowMenu) then
  begin
  	for FormIndex  := 0 to  Screen.FormCount-1 do
	  	If Screen.Forms[FormIndex].Caption = DelimitedString((Sender as TMenuItem).Caption, ' ', True) then
      begin
				Screen.Forms[FormIndex].SetFocus;
        Exit;
      end;
  end;
end;

procedure TDataEntryMainForm.RecentListRecentClick(Sender: TObject);
begin
	OpenForm((Sender as  TMenuItem).Caption);
end;

procedure TDataEntryMainForm.ViewMenuClick(Sender: TObject);
var
	MenuItem : TMenuItem;
begin
	MenuItem := (Sender as TMenuItem);
	MenuItem.Checked := not MenuItem.Checked;
  If MenuItem.Caption = '&Tables' then DataEntryTableForm.Visible := MenuItem.Checked
  else If MenuItem.Caption = '&Controls' then ControlPaletteForm.Visible := MenuItem.Checked
	else If MenuItem.Caption = '&Twain' then TwainForm.Visible := MenuItem.Checked;

end;

procedure TDataEntryMainForm.TwainSpeedButtonClick(Sender: TObject);
begin
  If (ActiveDataEntryForm <> nil)
  and (ActiveDataEntryForm.ActiveControl is TDBCompressImage) then
  begin
    //use queryinterface to avoid problems with passing paramters with clipboardcopy
    TwainForm.ImgEdit.OleObject.ClipBoardCopy;
    (ActiveDataEntryForm.ActiveControl as TDBCompressImage).PasteFromClipboard;
  end;
end;

procedure TDataEntryMainForm.ViewOrderMenuClick(Sender: TObject);
begin
	If (DataEntryMainForm.ActiveDataEntryForm as TDataEntryFormForm).Designing then
		NavOrderForm.ShowModal;
end;

initialization
	RegisterClass(TDragLabel);
	RegisterClass(TDBGrid);
	RegisterClass(TDBEdit);
	RegisterClass(TDBMemo);
	RegisterClass(TDBCompressImage);
	RegisterClass(TInPlaceEdit);
end.


