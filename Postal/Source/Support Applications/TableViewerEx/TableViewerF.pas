//$Archive: /CorvusV3/Source/Support Applications/TableViewerEx/TableViewerF.pas $
unit TableViewerF;

interface

uses
  BDE,DbUtil,
  Clipbrd, GridUtil,
  Math, StringUtil,
  RegistryEx,
	SavePosFormEx,Series,
  TxnTranslateU,GPCSGUID,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, DBGrids, Db, DBTables, DBCtrls, Spin, ComCtrls,
  TeeProcs, TeEngine, Chart, quickrpt, Qrctrls;

type
  TTableViewerForm = class(TForm)
    Table: TTable;
    DataSource: TDataSource;
    TopPanel: TPanel;
    AliasLabel: TLabel;
    AliasComboBox: TComboBox;
    TableComboBox: TComboBox;
    TableLabel: TLabel;
    RefreshButton: TButton;
    RefreshSpinEdit: TSpinEdit;
    RefreshFreqLabel: TLabel;
    RefreshTimer: TTimer;
    PageControl: TPageControl;
    ViewTabSheet: TTabSheet;
    Splitter: TSplitter;
    DBGrid: TDBGrid;
    DBMemo: TDBMemo;
    RecordCountTabSheet: TTabSheet;
    RecordCountLabel: TLabel;
    MultiTabSheet: TTabSheet;
    RecordCountChart: TChart;
    Series1: TBarSeries;
    ChartSplitter: TSplitter;
    QueryTabSheet: TTabSheet;
    Query: TQuery;
    SQLGroupBox: TGroupBox;
    SQLMemo: TMemo;
    SQLSplitter: TSplitter;
    ResultsGroupBox: TGroupBox;
    ResultsDBGrid: TDBGrid;
    DBNavigator: TDBNavigator;
    QueryDataSource: TDataSource;
    QueryPanel: TPanel;
    ExecuteButton: TButton;
    AliasBrowseButton: TButton;
    OpenDialog: TOpenDialog;
    QuerySpinButton: TSpinButton;
    QueryDBMemo: TDBMemo;
    CodeCopyButton: TButton;
    LogGroupBox: TGroupBox;
    LogSplitter: TSplitter;
    LogMemo: TMemo;
    MultiPanel: TPanel;
    MultiStringGrid: TStringGrid;
    MultiTopPanel: TPanel;
    DeleteButton: TButton;
    ReportButton: TButton;
    ReportTabSheet: TTabSheet;
    QuickRep: TQuickRep;
    TitleQRBand: TQRBand;
    DateTimeQRSysData: TQRSysData;
    HeaderQRBand: TQRBand;
    DetailQRBand: TQRBand;
    SQLQRMemo: TQRMemo;
    AliasQRLabel: TQRLabel;
    CSVButton: TButton;
    SaveDialog: TSaveDialog;
    TableViewerDatabase: TDatabase;
    TableViewerSession: TSession;
    LiveCheckBox: TCheckBox;
    ViewFilterPanel: TPanel;
    ViewFilterLabel: TLabel;
    ViewFilterEdit: TEdit;
    TranslateButton: TButton;
    TranslateResultFieldsGroupBox: TGroupBox;
    TranslateResultFieldsComboBox: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure TableComboBoxChange(Sender: TObject);
    procedure DBGridCellClick(Column: TColumn);
    procedure DBGridDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure RefreshButtonClick(Sender: TObject);
    procedure RefreshSpinEditChange(Sender: TObject);
    procedure RefreshTimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure ExecuteButtonClick(Sender: TObject);
    procedure AliasBrowseButtonClick(Sender: TObject);
    procedure QuerySpinButtonDownClick(Sender: TObject);
    procedure QuerySpinButtonUpClick(Sender: TObject);
    procedure SQLMemoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ResultsDBGridColEnter(Sender: TObject);
    procedure CodeCopyButtonClick(Sender: TObject);
    procedure AliasComboBoxExit(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ReportButtonClick(Sender: TObject);
    procedure CSVButtonClick(Sender: TObject);
    procedure ResultsDBGridTitleClick(Column: TColumn);
    procedure ViewFilterEditDragOver(Sender, Source: TObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure ViewFilterEditDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure ViewFilterEditKeyPress(Sender: TObject; var Key: Char);
    procedure TranslateButtonClick(Sender: TObject);
    procedure DBGridTitleClick(Column: TColumn);
  private
    { Private declarations }
    SavedQueries : TStringList;
    SavedColumns : TStringList;
    procedure AppExcept(Sender: TObject; E: Exception);
    procedure LoadQueries;
    procedure LogEvent(EventMsg : String);
    procedure SaveQuery;
    function GetQueryColWidths : String;
    procedure SetQueryColumnWidths(ColWidths : String);
    procedure RefreshStatus;


  public
    { Public declarations }
    procedure Loaded; override;
  end;

var
  TableViewerForm: TTableViewerForm;

implementation

{$R *.DFM}

procedure TTableViewerForm.Loaded;
begin
try
  Session.GetAliasNames(AliasComboBox.Items);
  AliasComboBox.ItemIndex := AliasComboBox.Items.IndexOf('PSL');
  If AliasComboBox.ItemIndex = -1 then AliasComboBox.ItemIndex := 0;
  AliasComboBoxExit(nil);
  TableComboBoxChange(nil);
  MultiStringGrid.Rows[0].CommaText := 'Alias/Dir, "Record Count"';
  If FileExists(ExtractFilePath(Application.ExeName) + 'AliasList.txt') then
		MultiStringGrid.Cols[0].LoadFromFile(ExtractFilePath(Application.ExeName) + 'AliasList.txt');
  LoadQueries;
except
end;

end;

procedure TTableViewerForm.LogEvent(EventMsg : String);
begin
  LogMemo.Lines.Add(EventMsg);
  LogMemo.SelStart := Length(LogMemo.Text); 
end;

procedure TTableViewerForm.AppExcept(Sender: TObject; E: Exception);
begin
  LogEvent(E.MEssage);
end;


procedure TTableViewerForm.SetQueryColumnWidths(ColWidths : String);
var
  ColIndex : Integer;
begin
  With TStringList.Create do
  begin
    CommaTExt := ColWidths;
    For ColIndex := 0 to Count-1 do
    begin
      If ResultsDBGrid.Columns.Count > ColIndex then ResultsDBGrid.Columns[ColIndex].Width := StrToInt(Strings[ColIndex]);
    end;
    Free;
  end;
end;

procedure TTableViewerForm.LoadQueries;
begin
  //saved queries
  SavedQueries := TStringList.Create;
  SavedColumns := TStringList.Create;

  If FileExists(ExtractFilePath(Application.ExeName) + 'SavedQueries.txt') then
    SavedQueries.LoadFromFile(ExtractFilePath(Application.ExeName) + 'SavedQueries.txt');
  If SavedQueries.Count > 0 then SQLMemo.Lines.CommaText := SavedQueries[0];

  If FileExists(ExtractFilePath(Application.ExeName) + 'SavedTranslateResultFields.txt') then
    TranslateResultFieldsComboBox.Items.LoadFromFile(ExtractFilePath(Application.ExeName) + 'SavedTranslateResultFields.txt');
  If TranslateResultFieldsComboBox.Items.Count > 0 then TranslateResultFieldsComboBox.ItemIndex := 0;

  If FileExists(ExtractFilePath(Application.ExeName) + 'SavedColumns.txt') then
    SavedColumns.LoadFromFile(ExtractFilePath(Application.ExeName) + 'SavedColumns.txt');
  If SavedColumns.Count > 0 then
    SetQueryColumnWidths(SavedColumns[0]);
end;

procedure TTableViewerForm.SaveQuery;
begin

  //Save result column widths
  SavedColumns.Insert(0,GetQueryColWidths);
  While SavedColumns.Count > 100 do SavedColumns.Delete(100);
  SavedColumns.SaveToFile(ExtractFilePath(Application.ExeName) + 'SavedColumns.txt');

  //save query
  If (SavedQueries.Count = 0)
  or (SQLMemo.Lines.CommaText <> SavedQueries[0]) then
  begin
    SavedQueries.Insert(0,SQLMemo.Lines.CommaText);
    While SavedQueries.Count > 100 do SavedQueries.Delete(100);
    SavedQueries.SaveToFile(ExtractFilePath(Application.ExeName) + 'SavedQueries.txt');
  end;

  //save translate result fields
  If (TranslateResultFieldsComboBox.Items.Count = 0)
  or (TranslateResultFieldsComboBox.Text <> TranslateResultFieldsComboBox.Items[0]) then
  begin
    TranslateResultFieldsComboBox.Items.Insert(0, TranslateResultFieldsComboBox.Text);
    While TranslateResultFieldsComboBox.Items.Count > 100 do TranslateResultFieldsComboBox.Items.Delete(100);
    TranslateResultFieldsComboBox.Items.SaveToFile(ExtractFilePath(Application.ExeName) + 'SavedTranslateResultFields.txt');
  end;

end;


procedure TTableViewerForm.RefreshStatus;
const
	ColorArray : Array [0..15] of TColor =  (clAqua, clBlack, clBlue, clFuchsia,
  																				clGreen, clLime, clLtGray, clMaroon,
                													clNavy, clOlive, clPurple, clRed,  clSilver,
                													clTeal, clWhite, clYellow);
var
  RowIndex 		: Integer;
  NewChartSeries 	: TPointSeries;
  WSNumber, RecordID 	: TField;
  WSNumbers 		: TStringList;
  Series 		: TChartSeries;
begin
 try
    //ipdate local record count
    Table.Active   := False;
    Table.Databasename 	:= AliasComboBox.Text;
    Table.TableName 	:= TableComboBox.Text;
    
    if (Table.TableName = 'Txnlog') 
    and (GetGPCSRegString('WorkStation','DBType','Paradox') <> 'Paradox') then
        Table.IndexName:='TXNLOG_PINDEX';
        
    if (Copy(Table.TableName,1,4) <> 'dbo.') 
    and (GetGPCSRegString('WorkStation','DBType','Paradox') = 'SQLServer') then
    begin
       Table.TableName:='dbo.'+Table.TableName;
    end;
    
    Table.Active 	:= True;
    RecordCountLabel.Caption := IntToStr(Table.Recordcount);
  except
  	On E : Exception do RecordCountLabel.Caption := E.Message;
  end;

  WSNumbers := TStringList.Create;
  //multi grid
  If MultiStringGrid.Visible then
  begin
    While RecordCountChart.SeriesCount >0 do
    begin
      Series := RecordCountChart.Series[0];
      Series.ParentChart := nil;
      Series.Free;
    end;

    //iterate all databases
    For RowIndex := 1 to MultiStringGrid.RowCount-1 do
    begin
      If MultiStringGrid.Cells[0,RowIndex] <> '' then
      begin
        try
          //connect table to this database
          Table.Active := False;
          Table.Databasename := MultiStringGrid.Cells[0,RowIndex];
          Table.TableName := TableComboBox.Text;
          Table.Active := True;

          //gab recordcount
          MultiStringGrid.Cells[1,RowIndex] := IntToStr(Table.RecordCount);

          //plot record bitmap
          NewChartSeries := TPointSeries.Create(self);
          With NewChartSeries do
          begin
            NewChartSeries.Pointer.Pen.Visible := False;
            NewChartSeries.Pointer.VertSize 	:= 2;
            NewChartSeries.Pointer.HorizSize 	:= 1;
  //            	NewChartSeries.SideMargins := False;
            Newchartseries.SeriesColor := clBlack;
            NewChartSeries.Title := Table.DatabaseName;
            NewChartSeries.Marks.Visible := False;
  //							NewChartSeries.BarStyle := bsCilinder;
            Table.First;
            WSNumber := Table.FieldByName('WSNumber');
            RecordId  := Table.FieldByName('RecordID');

            //add axis label
            NewChartSeries.AddXY(1020 * (RowIndex-1) ,  0, Table.DatabaseName, clTeeColor);
            while not Table.EOF do
            begin
              If WSnumbers.IndexOf(IntToStr(WSNumber.AsInteger)) < 0 then
                WSNumbers.Add(IntToStr(WSNumber.AsInteger));
              NewChartSeries.AddXY(1020 * (RowIndex-1) + 4 * WSNumber.Value,  RecordID.Value, '', ColorArray[(WSnumber.AsInteger) Mod 16]);
              Table.Next;
            end;
            NewChartSeries.ParentChart := RecordCountChart;
          end;
        except
          On E : Exception do
            MultiStringGrid.Cells[1,RowIndex] := 'Error:' + E.Message;
        end;

      end
      else
        MultiStringGrid.Cells[1,RowIndex] := '';
    end;
  end;



end;

procedure TTableViewerForm.FormCreate(Sender: TObject);
begin
  Application.OnException := AppExcept;
  TableViewerDatabase.Params.Add('USER NAME=' + GetGPCSRegString('','UserName','psl'));
  TableViewerDatabase.Params.Add('PASSWORD='  + GetGPCSRegString('','Password','suvroc'));
  TableViewerDatabase.LoginPrompt:=False;
end;

procedure TTableViewerForm.TableComboBoxChange(Sender: TObject);
begin
	try
    Table.Active := False;
		Table.DatabaseName := AliasComboBox.Text;
		Table.TableName := TableComboBox.Text;
    Table.Active := True;
  except
    ShowMessage('Unable to access table. Alias <'
    							+ AliasComboBox.TExt
                  + '>, Table <'
                  + TableComboBox.Text
                  + '>');
  end;
end;

procedure TTableViewerForm.DBGridCellClick(Column: TColumn);
begin
	try
  	DBMemo.DataField := Column.FieldName;
  except
  end;
end;

procedure TTableViewerForm.DBGridDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
{
	If Column.Field.DataType = ftMemo	then
  begin
  	canvas.FillRect(Rect);
  	Canvas.MoveTo(Rect.Left,Rect.Top);
		Canvas.LineTo(Rect.Right, Rect.Bottom);
  end
  else
}
  DBGrid.DefaultDrawColumnCell(Rect,DataCol,Column,State);;
end;

procedure TTableViewerForm.RefreshButtonClick(Sender: TObject);
begin
	RefreshButton.Enabled := False;
  try
		RefreshStatus;
  finally
		RefreshButton.Enabled := True;
  end;
end;

procedure TTableViewerForm.RefreshSpinEditChange(Sender: TObject);
begin
	If RefreshSpinEdit.Value <> 0 then
  begin
		RefreshTimer.Interval := 1000 * RefreshSpinEdit.Value;
		RefreshTimer.Enabled  := True;
  end
  else
		RefreshTimer.Enabled  := False;

end;

procedure TTableViewerForm.RefreshTimerTimer(Sender: TObject);
begin
	RefreshTimer.Enabled := False;
	RefreshStatus;
	RefreshTimer.Enabled := True;
end;

procedure TTableViewerForm.FormDestroy(Sender: TObject);
begin
	MultiStringGrid.Cols[0].SaveToFile(ExtractFilePath(Application.ExeName) + 'AliasList.txt');
end;

procedure TTableViewerForm.DeleteButtonClick(Sender: TObject);
var
	RowIndex : Integer;
  procedure ClearTable;
  begin
  	try
      Table.Active := True;
      Table.First;
      While not Table.EOF do Table.Delete;
    except
    end;
  end;

begin
	If mrYes = MessageDlg('Delete all records from selected table(s)?', mtConfirmation, [mbYes,mbNo], 0) then
  begin
  	If MultiStringGrid.Visible then
    begin
    	For RowIndex := 1 to MultiStringGrid.RowCount-1 do
      begin
      	try
          If MultiStringGrid.Cells[0,RowIndex] <> '' then
          begin
            Table.Active := False;
            Table.Databasename := MultiStringGrid.Cells[0,RowIndex];
            Table.TableName := TableComboBox.Text;
            ClearTable;
          end;
        except
        end;
      end;
    end
    else
    begin
      Table.Active := False;
      Table.Databasename := AliasComboBox.Text;
      Table.TableName 		:= TableComboBox.Text;
      ClearTable;
    end;
  end;

end;

function TTableViewerForm.GetQueryColWidths : String;
var
  ColIndex : Integer;
begin
  For ColIndex := 0 to ResultsDBGrid.Columns.Count-1 do
  begin
    Result := Result + IntToStr(ResultsDBGrid.Columns[ColIndex].Width) + ',';
  end;
end;


procedure TTableViewerForm.ExecuteButtonClick(Sender: TObject);
var
  ColWidths : String;
  StartTime, EndTime : TTimeStamp;
begin
  FormResize(Sender);
//  DbiSetCurrSession(TableViewerSession.Handle);
  ExecuteButton.Enabled := False;
  Screen.Cursor := crHourGlass;
  try
    ColWidths := GetQueryColWidths;
    Query.Active := False;
    Query.RequestLive := LiveCheckBox.Checked;
    QueryDBMemo.DataField  := '';
    Query.DatabaseName := AliasComboBox.Text;
    Query.SQL.Text := SQLMemo.Text;
    SaveQuery;
  //  SaveResultGridColumns;

    StartTime := DateTimeToTimeStamp(Now);
    //determine type of query
    if UpperCase( DelimitedString(Trim(Query.SQL.Text),' ', False) ) = 'SELECT' then
      Query.Active := True
    else
      Query.ExecSQL;

    EndTime := DateTimeToTimeStamp(Now);
    LogEvent(Format('Query Time : %.3f s', [(EndTime.Time - StartTime.Time)/1000]));

    SetQueryColumnWidths(ColWidths);
  //  LoadresultGridColumns;
    ResultsDBGrid.SelectedField := ResultsDBGrid.Fields[0];
//    ResultsDBGrid.SelectedIndex := 1;
//    ResultsDBGrid.DataSource.DataSet.First;
    ResultsDBGrid.SetFocus;
  finally
    Screen.Cursor := crDefault;
    ExecuteButton.Enabled := True;

  end;
end;

procedure TTableViewerForm.AliasBrowseButtonClick(Sender: TObject);
begin
  OpenDialog.InitialDir := ExtractFileDir(AliasComboBox.Text);
  OpenDialog.FileName := ExtractFileName(AliasComboBox.Text);
  If OpenDialog.Execute then
  begin
    AliasComboBox.Text := ExtractFilePath(OpenDialog.FileName);
    AliasComboBoxExit(Sender);
  end;
end;

procedure TTableViewerForm.QuerySpinButtonDownClick(Sender: TObject);
begin
  SQLMemo.Tag := MinIntValue([SQLMemo.Tag + 1, SavedQueries.Count-1]);
  If (SQLMemo.Tag > -1) and (SavedQueries.Count > SQLMemo.Tag) then
  begin
    SQLMemo.Lines.CommaText := SavedQueries[SQLMemo.Tag];
    TranslateResultFieldsComboBox.Text := TranslateResultFieldsComboBox.Items[SQLMemo.Tag];
//    SetQueryColumnWidths(SavedColumns[SQLMemo.Tag]);
  end;
end;

procedure TTableViewerForm.QuerySpinButtonUpClick(Sender: TObject);
begin
  SQLMemo.Tag := MaxIntValue([SQLMemo.Tag -1,0]);
  If SavedQueries.Count > SQLMemo.Tag then
  begin
    SQLMemo.Lines.CommaText := SavedQueries[SQLMemo.Tag];
    TranslateResultFieldsComboBox.Text := TranslateResultFieldsComboBox.Items[SQLMemo.Tag];
//    SetQueryColumnWidths(SavedColumns[SQLMemo.Tag]);
  end;
end;

procedure TTableViewerForm.SQLMemoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If (Key in [VK_DOWN, VK_NEXT]) and (SQLMemo.SelStart = Length(SQLMemo.Text)) then
 begin
//   QuerySpinButtonDownClick(Sender);
 end
 else If (Key in [VK_UP, VK_PRIOR]) and (SQLMemo.SelStart = 0) then
 begin
//   QuerySpinButtonUpClick(Sender);
 end

end;

procedure TTableViewerForm.ResultsDBGridColEnter(Sender: TObject);
begin
  QueryDBMemo.DataField := ResultsDBGrid.SelectedField.FieldName;
end;

procedure TTableViewerForm.CodeCopyButtonClick(Sender: TObject);
var
  SQLIndex : Integer;
  CodeCopy  : String;
begin
  CodeCopy := '''  ' + SQLMemo.Lines[0] + '''' + #13#10;
  For SQLIndex := 1 to SQLMemo.Lines.Count -1 do
  begin
    CodeCopy := CodeCopy + ' + '' ' + SQLMemo.Lines[SQLIndex] + '''' + #13#10
  end;
  Clipboard.SetTextBuf(PChar(CodeCopy));

end;

procedure TTableViewerForm.AliasComboBoxExit(Sender: TObject);
begin
  TableViewerDatabase.LoginPrompt:=False;
  Session.GetTableNames(AliasComboBox.Text,'',False,False,	TableComboBox.Items);
	TableComboBox.ItemIndex := TableComboBox.Items.IndexOf('TxnLog');
	If TableComboBox.ItemIndex = -1 then TableComboBox.ItemIndex := 0;
  TableComboBoxChange(Sender);
end;

procedure TTableViewerForm.FormResize(Sender: TObject);
begin
//  QuickRep.SetBounds(0,0,QuickRep.Parent.Width, QuickRep.Parent.Height);
end;

procedure TTableViewerForm.ReportButtonClick(Sender: TObject);
var
  FieldIndex        : Integer;
  ColumnOffset      : Integer;
  PrintableWidth    : Integer;
  TotalColumnWidth : Integer;
begin
  PageControl.ActivePage := ReportTabSheet;
  //query
  SQLQRMemo.Lines.Text := SQLMemo.Text;
  AliasQRLabel.CAption := 'Alias:'+ AliasComboBox.text;

  //free all variable report components
  While HeaderQRBand.ComponentCount > 0 do
    HeaderQRBand.Components[0].Free;
  While DetailQRBand.ComponentCount > 0 do
    DetailQRBand.Components[0].Free;

  //sum column widths
  TotalColumnWidth := 0;
  For FieldIndex := 0 to Query.FieldCount -1 do
    Inc(TotalColumnWidth, ResultsDBGrid.Columns[FieldIndex].Width);

  //add column headers
  PrintableWidth := QuickRep.Width - Trunc(QuickRep.Page.Leftmargin) - Trunc(QuickRep.Page.RightMargin);
  ColumnOffset := 0;
  For FieldIndex := 0 to Query.FieldCount -1 do
  begin
    With TQRLabel.Create(HeaderQRBand) do
    begin
      Parent := HeaderQRBand;
      Caption := Query.Fields[FieldIndex].FieldName;
      Top := 0;
      Left := ColumnOffset;
    end;

    With TQRDBText.Create(DetailQRBand) do
    begin
      Parent    := DetailQRBand;
      DataSet   := Query;
      DataField := Query.Fields[FieldIndex].FieldName;
      If  (Query.Fields[FieldIndex].DataType <> ftBlob)
      and (Query.Fields[FieldIndex].DataType <> ftMemo) then
      begin
        AutoSize := False;
        AutoStretch := True;
      end;
      Top := 0;
      Left := ColumnOffset;
    end;

    //ready for next column
    Inc(ColumnOffset, Trunc(PrintableWidth * ResultsDBGrid.Columns[FieldIndex].Width / TotalColumnWidth))
  end;  //for all fields

  QuickRep.Preview;

end;

procedure TTableViewerForm.CSVButtonClick(Sender: TObject);
var
  CSVSL : TStringList;
  RecordSL : TStringList;
  FieldIndex : Integer;
begin
  If SaveDialog.Execute then
  begin
    CSVSL := TStringList.Create;
    RecordSL := TStringList.Create;
    try
      //col headers
      For FieldIndex := 0 to Query.FieldCount -1 do
      begin
        RecordSL.Add(Query.Fields[FieldIndex].FieldName);
      end;
      CSVSL.Add(RecordSL.Commatext);      

      Query.First;
      While not Query.EOF do
      begin
        RecordSL.Clear;
        For FieldIndex := 0 to Query.FieldCount -1 do
        begin
          If Trim(Query.Fields[FieldIndex].AsString) = '' then
            RecordSL.Add('"' + Query.Fields[FieldIndex].AsString + '"')
          else
            RecordSL.Add(Query.Fields[FieldIndex].AsString);
        end;
        CSVSL.Add(RecordSL.Commatext);
        Query.Next;
      end;
      CSVSL.SaveToFile(SaveDialog.FileName);
    finally
      CSVSL.Free;
      RecordSL.Free;
    end;
  end;

end;


procedure TTableViewerForm.ResultsDBGridTitleClick(Column: TColumn);
begin
  If Column.Index = 0 then  //size to fit all columns
    FitColumnWidths(ResultsDBGrid);
end;

procedure TTableViewerForm.ViewFilterEditDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Source = DBGrid);
end;

procedure TTableViewerForm.ViewFilterEditDragDrop(Sender, Source: TObject;
  X, Y: Integer);
begin
  ViewFilterEdit.Text := LeftString(ViewFilterEdit.Text, ViewFilterEdit.SelStart)
                          + TDBGrid(Source).SelectedField.FieldName
                          + RightStringExcept(ViewFilterEdit.Text, ViewFilterEdit.SelStart);
end;

procedure TTableViewerForm.ViewFilterEditKeyPress(Sender: TObject;
  var Key: Char);
begin
  If Key = #13 then
  begin
    try
      Table.Filter := Trim(ViewFilterEdit.Text);
      Table.Filtered := True;
    except
      Table.Filtered := false;
      Raise;
    end;
  end;

end;

procedure TTableViewerForm.TranslateButtonClick(Sender: TObject);
var
  ColWidths : String;
  StartTime, EndTime : TTimeStamp;
  ResultLines : TTransactionLines;
begin
  FormResize(Sender);

  //create a results table
  ResultLines := TTxnTranslate.TranslateQuery('', SQLMemo.Text);
  ResultLines.FieldsResult := TranslateResultFieldsComboBox.Text;
  ResultLines.ConvertToTable(AliasComboBox.Text,'ReportResults');
  TableComboBox.Text := 'ReportResults';
  ResultLines.Free;

  DbiSetCurrSession(TableViewerSession.Handle);
  TranslateButton.Enabled := False;
  Screen.Cursor := crHourGlass;
  try
    ColWidths := GetQueryColWidths;
    Query.Active := False;
    Query.RequestLive := LiveCheckBox.Checked;
    QueryDBMemo.DataField  := '';
    Query.DatabaseName := AliasComboBox.Text;
    If Trim(TranslateResultFieldsComboBox.Text) = '' then Query.SQL.Text := 'select * from ReportResults'
    else Query.SQL.Text := 'select ' +  TranslateResultFieldsComboBox.Text + ' from ReportResults';
    SaveQuery;
  //  SaveResultGridColumns;

    StartTime := DateTimeToTimeStamp(Now);
    //determine type of query
    if UpperCase( DelimitedString(Trim(Query.SQL.Text),' ', False) ) = 'SELECT' then
      Query.Active := True
    else
      Query.ExecSQL;

    EndTime := DateTimeToTimeStamp(Now);
    LogEvent(Format('Query Time : %.3f s', [(EndTime.Time - StartTime.Time)/1000]));

    SetQueryColumnWidths(ColWidths);
  //  LoadresultGridColumns;
  finally
    Screen.Cursor := crDefault;
    TranslateButton.Enabled := True;
  end;
end;

procedure TTableViewerForm.DBGridTitleClick(Column: TColumn);
begin
  If Column.Index = 0 then  //size to fit all columns
    FitColumnWidths(DBGrid);
end;

end.
