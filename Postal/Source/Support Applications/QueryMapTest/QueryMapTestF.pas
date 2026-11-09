unit QueryMapTestF;

interface

uses
  ClipBrd,
  Math,
  GridUtil,
  StringUtil,
  QueryMapU,
  SavePosFormEx,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FileCtrl, StdCtrls, ExtCtrls, ComCtrls, Grids, Db, DBTables, Buttons,
  Menus;

type
  TQueryMapTestForm = class(TSavePosForm)
    ResultsSplitter: TSplitter;
    DatabaseGroupBox: TGroupBox;
    DriveComboBox: TDriveComboBox;
    DirectoryListBox: TDirectoryListBox;
    FileListBox: TFileListBox;
    ResultGroupBox: TGroupBox;
    ResultStringGrid: TStringGrid;
    Query: TQuery;
    MapsGroupBox: TGroupBox;
    MapsStringGrid: TStringGrid;
    FieldListBox: TListBox;
    QueryPanel: TPanel;
    QueryGroupBox: TGroupBox;
    QueryMemo: TMemo;
    SelectGroupBox: TGroupBox;
    SelectFieldsListBox: TListBox;
    ResultFieldGroupBox: TGroupBox;
    ResultFieldsListBox: TListBox;
    ResultFieldEdit: TEdit;
    QueryBottomPanel: TPanel;
    QueryExecButton: TButton;
    QueryPreviousButton: TButton;
    QueryNextButton: TButton;
    DirSpeedButton: TSpeedButton;
    DirEdit: TEdit;
    MapListBox: TListBox;
    CodeButton: TButton;
    QuerySplitter: TSplitter;
    CodeMemo: TMemo;
    ResultTableEdit: TEdit;
    MapsPopupMenu: TPopupMenu;
    DeleteMenu: TMenuItem;
    TotalFieldGroupBox: TGroupBox;
    TotalFieldsListBox: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure QueryExecButtonClick(Sender: TObject);
    procedure ResultStringGridColumnMoved(Sender: TObject; FromIndex,
      ToIndex: Integer);
    procedure QueryPreviousButtonClick(Sender: TObject);
    procedure QueryNextButtonClick(Sender: TObject);
    procedure FileListBoxChange(Sender: TObject);
    procedure ResultFieldsMemoDragOver(Sender, Source: TObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure QueryMemoChange(Sender: TObject);
    procedure DirectoryListBoxChange(Sender: TObject);
    procedure SelectFieldsListBoxDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure ResultFieldsListBoxDragOver(Sender, Source: TObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure ResultFieldsListBoxDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure ResultFieldsListBoxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ResultFieldsListBoxKeyPress(Sender: TObject; var Key: Char);
    procedure ResultFieldEditKeyPress(Sender: TObject; var Key: Char);
    procedure DirSpeedButtonClick(Sender: TObject);
    procedure DirEditChange(Sender: TObject);
    procedure MapsStringGridDragOver(Sender, Source: TObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure MapsStringGridDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure MapListBoxDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure MapListBoxDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure CodeButtonClick(Sender: TObject);
    procedure MapsStringGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DeleteMenuClick(Sender: TObject);
    procedure MapsStringGridMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TotalFieldsListBoxDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure TotalFieldsListBoxDragOver(Sender, Source: TObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure TotalFieldsListBoxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    QueryHistory      : TStringList;
    FCurrentQueryMap  : TQueryMap;
    procedure SetCurrentQueryMap(NewQueryMap : TQueryMap);
    procedure AppExcept(Sender: TObject; E: Exception);
  public
    { Public declarations }
    property CurrentQueryMap : TQueryMap read FCurrentQueryMap write SetCurrentQueryMap;
  end;

var
  QueryMapTestForm: TQueryMapTestForm;

implementation

{$R *.DFM}

procedure TQueryMapTestForm.AppExcept(Sender: TObject; E: Exception);
begin
  ShowMessage(E.Message);
end;

procedure TQueryMapTestForm.FormCreate(Sender: TObject);
begin
  DirSpeedButtonClick(nil);
  Application.OnException := AppExcept;
  DriveComboBox.Drive := 'c';
//  DirectoryListBox.Directory := 'c:\bermuda\database';
  DirectoryListBox.Directory := '';

  QueryHistory := TStringList.Create;
  While QueryHistory.Count < 10 do
  begin
    QueryHistory.AddObject(Format('Query%d',[QueryHistory.Count]),TQueryMap.Create);
    (QueryHistory.Objects[QueryHistory.Count-1] as TQueryMap).Name := QueryHistory[QueryHistory.Count-1];
  end;
  CurrentQueryMap := QueryHistory.Objects[0] as TQueryMap;

  If CurrentQuerymap = nil then
    CurrentQuerymap := TQueryMap.Create;

  //maps
  MapsStringGrid.Rows[0].CommaText := 'Compare, To, Select, Result';
end;

procedure TQueryMapTestForm.FormDestroy(Sender: TObject);
begin
  While QueryHistory.Count > 0 do
  begin
    (QueryHistory.Objects[QueryHistory.Count-1] as TQueryMap).Free;
    QueryHistory.Delete(QueryHistory.Count-1);
  end;
end;

procedure TQueryMapTestForm.SetCurrentQueryMap(NewQueryMap : TQueryMap);
var
  FieldMap : TFieldMap;
  Index : Integer;
begin
  If NewQueryMap = nil then Exit;
  If FCurrentQueryMap <> NewQueryMap then
  begin
    FCurrentQueryMap      := NewQueryMap;
    QueryMemo.Text        := FCurrentQueryMap.SQL;
    QueryGroupBox.Caption := 'Query:' + FCurrentQueryMap.Name;
    SelectFieldsListBox.Items.CommaText := FCurrentQueryMap.SelectFields;
    ResultFieldsListBox.Items.CommaText := FCurrentQueryMap.ResultFields;

    //set column widths
    With TStringList.Create do
    begin
      CommaText := CurrentQueryMap.ColWidths;
      ResultStringGrid.ColCount := Count;
      For Index := 0 to Count -1 do
        ResultStringGrid.ColWidths[Index] := StrToInt(Strings[Index]);
      Free;
    end;

    //build maps
    MapsStringGrid.RowCount := 2;
    MapsStringGrid.Rows[1].CommaText := '';
    MapsStringGrid.RowCount := 2  + FCurrentQueryMap.Maps.Count;
    For Index := 0 to     FCurrentQueryMap.Maps.Count -1 do
    begin
      FieldMap := (FCurrentQueryMap.Maps.Objects[Index] as TFieldMap);
      MapsStringGrid.Cells[0,1 + Index] := FieldMap.CompareField;
      If FieldMap.Comparison = mcEquals then
      begin
        MapsStringGrid.Cells[1,1 + Index] := FieldMap.CompareValue;
        MapsStringGrid.Cells[2,1 + Index] := FieldMap.SelectFields;
        MapsStringGrid.Cells[3,1 + Index] := FieldMap.ResultFields;
      end;
    end;
    MapsStringGrid.RowCount := 10;

  end;
end;


procedure TQueryMapTestForm.QueryExecButtonClick(Sender: TObject);
var
  MapIndex  : Integer;
  ColIndex  : Integer;
begin
  CurrentQueryMap.DataAlias     := DirEdit.Text;
  CurrentQueryMap.SelectFields  := SelectFieldsListBox.Items.CommaText;
  CurrentQueryMap.ResultFields  := ResultFieldsListBox.Items.CommaText;
  CurrentQueryMap.TotalFields   := TotalFieldsListBox.Items.CommaText;
  CurrentQueryMap.SQL           := QueryMemo.Text;
  CurrentQueryMap.ResultTableName :=ResultTableEdit.Text;
  MapIndex := 1;
  CurrentQueryMap.ClearMaps;
  While     (MapsStringGrid.Cells[0,MapIndex] <> '')
        and (MapsStringGrid.Cells[1,MapIndex] <> '')
        and (MapsStringGrid.Cells[2,MapIndex] <> '')
        and (MapsStringGrid.Cells[3,MapIndex] <> '') do
  begin
    CurrentQueryMap.AddMap(MapsStringGrid.Cells[0,MapIndex],
                        mcEquals,
                        MapsStringGrid.Cells[1,MapIndex],
                        MapsStringGrid.Cells[2,MapIndex],
                        MapsStringGrid.Cells[3,MapIndex]);


    Inc(MapIndex);
  end;
  With TStringList.Create do
  begin
    //store grid colwidths
    While Count <  ResultStringGrid.ColCount do
      Add(IntToStr(ResultStringGrid.ColWidths[Count]));
    CurrentQueryMap.ColWidths := CommaText;

    ResultStringGrid.Rows[0].Assign(ResultFieldsListBox.Items);
    ResultStringGrid.Update;
    ResultStringGrid.Refresh;
    GridUtil.CommaTextIntoGrid(ResultStringGrid, CurrentQueryMap.Execute);

    //restore
    CommaText  := CurrentQueryMap.ColWidths;
    for ColIndex := 0 to MinIntValue([ResultStringGrid.ColCount, Count]) -1 do
      ResultStringGrid.ColWidths[ColIndex] := StrToInt(Strings[ColIndex]);
    Free;
  end;

end;

procedure TQueryMapTestForm.ResultStringGridColumnMoved(Sender: TObject;
  FromIndex, ToIndex: Integer);
var
  ColIndex : Integer;
begin
  With TStringList.Create do
  begin
    For ColIndex := 0 to ResultStringGrid.ColCount -1 do
      Add(IntToStr(ResultStringGrid.ColWidths[ColIndex]));
    CurrentQueryMap.ColWidths := CommaText;
    Free;
  end;
end;

procedure TQueryMapTestForm.QueryPreviousButtonClick(Sender: TObject);
var
  QueryNumber : Integer;
begin
  QueryNumber := StrToIntDef(DelimitedString(CurrentQueryMap.Name,'Query', True),-1);
  If  QueryNumber > 0 then
    CurrentQueryMap := QueryHistory.Objects[QueryNumber-1] as TQueryMap;
end;

procedure TQueryMapTestForm.QueryNextButtonClick(Sender: TObject);
var
  QueryNumber : Integer;
begin
  QueryNumber := StrToIntDef(DelimitedString(CurrentQueryMap.Name,'Query', True),-1);
  If  QueryNumber < (QueryHistory.Count-1) then
    CurrentQueryMap := QueryHistory.Objects[QueryNumber+1] as TQueryMap;
end;


procedure TQueryMapTestForm.FileListBoxChange(Sender: TObject);
begin
  With TTable.Create(nil) do
  begin
    try
      FieldListBox.Clear;
      DatabaseName := ExtractFilePath(FileListBox.FileName);
      TableName    := ExtractFileName(FileListBox.FileName);
      try
        If FileExists(FileListBox.FileName) then
          Open;
      except
      end;

      If Active then
        While FieldListBox.Items.count < FieldDefs.Count do
          FieldListBox.Items.Add(FieldDefs[FieldListBox.Items.Count].Name);
    finally
      Free;
    end;
  end;
end;

procedure TQueryMapTestForm.ResultFieldsMemoDragOver(Sender,
  Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  If (Source = SelectFieldsListBox) then Accept := True;
end;

procedure TQueryMapTestForm.QueryMemoChange(Sender: TObject);
var
  FieldsSL : TStringList;
  FieldsString : String;
  Field     : String;
begin
  FieldsSL := TStringList.Create;
  try
    FieldsString := LowerCase(Trim(QueryMemo.Text));
    FieldsString := Replace(FieldsString, #$D#$A, ' ');  //remove line breaks
    FieldsString := SubString(FieldsString, 'select', ' from');
    Repeat
      If Pos(',',FieldsString) > 0 then //not last field
        Field := DelimitedString(FieldsString, ',', False)
      else  //last field
        Field := FieldsString;

      Field := LastWord(Field);
      If Field <> '*' then FieldsSL.Add(Field);
      FieldsString := DelimitedString(FieldsString, ',', True);
    Until FieldsString = '';
    SelectFieldsListBox.Items.Assign(FieldsSL);

  finally
    FieldsSL.Free;
  end;

end;

procedure TQueryMapTestForm.DirectoryListBoxChange(Sender: TObject);
begin
  DirEdit.Text := DirectoryListBox.Directory;;  
end;

procedure TQueryMapTestForm.SelectFieldsListBoxDragDrop(Sender,
  Source: TObject; X, Y: Integer);
begin
  If Source = FieldListBox then
    If SelectFieldsListBox.Items.IndexOf(FieldListBox.Items[FieldListBox.ItemIndex]) < 0 then
      SelectFieldsListBox.Items.Add(FieldListBox.Items[FieldListBox.ItemIndex]);


end;


procedure TQueryMapTestForm.ResultFieldsListBoxDragOver(Sender,
  Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  DropLine : Integer;
begin
  If Source = SelectFieldsListBox then
  begin
    Accept := True;
    DropLine := ResultFieldsListBox.TopIndex +  Round(Y /  ResultFieldsListBox.ItemHeight);
    If DropLine > ResultFieldsListBox.Items.Count -1 then DropLine := -1;
    ResultFieldsListBox.ItemIndex := DropLine;
  end;
end;

procedure TQueryMapTestForm.ResultFieldsListBoxDragDrop(Sender,
  Source: TObject; X, Y: Integer);
var
  DropLine    : Integer;
  InsertLine  : Integer;
  SelIndex    : Integer;
  SelField    : String;
begin
  If (Source = SelectFieldsListBox) and (SelectFieldsListBox.ItemIndex >= 0) then
  begin
    DropLine := ResultFieldsListBox.TopIndex+  Round(Y /  ResultFieldsListBox.ItemHeight); //which line dropped on
    If DropLine <= ResultFieldsListBox.Items.Count -1 then //within list
      InsertLine := DropLine  //insertion point
    else
      InsertLine := ResultFieldsListBox.Items.Count;  //or at end

    For SelIndex := SelectFieldsListBox.Items.Count -1 downto 0 do
    begin
      If SelectFieldsListBox.Selected[SelIndex]  then     //selected field
      begin
        SelField := SelectFieldsListBox.Items[SelIndex];
        If ResultFieldsListBox.Items.IndexOf(SelField) < 0 then //not in result field list yet
        begin
          ResultFieldsListBox.Items.Insert(InsertLine, SelField)
        end;  //if item not in result field list
      end;  //if a selected item
    end;  //all items in select field list
  end;  //source is select field list
end;




procedure TQueryMapTestForm.ResultFieldsListBoxKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  SaveItemIndex : Integer;
begin
  If Ord(Key) = VK_DELETE then
  begin
    SaveItemIndex := ResultFieldsListBox.ItemIndex;
    ResultFieldsListBox.Items.Delete(ResultFieldsListBox.ItemIndex);
    ResultFieldsListBox.ItemIndex := MinIntValue([ResultFieldsListBox.Items.Count-1,SaveItemIndex]);
  end;
end;

procedure TQueryMapTestForm.ResultFieldsListBoxKeyPress(Sender: TObject;
  var Key: Char);
begin
  If Key in ['A'..'Z', 'a'..'z', '0'..'9'] then
  begin
    ResultFieldEdit.SetBounds(ResultFieldsListBox.Left+4,
                              2 + ResultFieldsListBox.Top +  ResultFieldsListBox.Items.Count * ResultFieldsListBox.ItemHeight,
                              ResultFieldsListBox.Width-6, ResultFieldsListBox.ItemHeight);
    ResultFieldEdit.Visible := True;
    ResultFieldEdit.SetFocus;
    ResultFieldEdit.Text := Key;
    ResultFieldEdit.SelStart := 1;
  end;
end;

procedure TQueryMapTestForm.ResultFieldEditKeyPress(Sender: TObject;
  var Key: Char);
begin
  If Ord(Key) in [VK_RETURN, VK_ESCAPE]  then
  begin
    If (Ord(Key) = VK_RETURN) and (ResultFieldsListBox.Items.IndexOf(ResultFieldEdit.Text) < 0) then
    begin
      ResultFieldsListBox.Items.Add(ResultFieldEdit.Text);
      ResultFieldsListBox.ItemIndex := ResultFieldsListBox.Items.Count-1; 
    end;
    ResultFieldEdit.Visible := False;
    ResultFieldsListBox.SetFocus;
  end;
end;

procedure TQueryMapTestForm.DirSpeedButtonClick(Sender: TObject);
begin
  If DirSpeedButton.Down then DirSpeedButton.Parent.Height := 161
  else DirSpeedButton.Parent.Height := 47;
end;

procedure TQueryMapTestForm.DirEditChange(Sender: TObject);
begin
  If FCurrentQueryMap <> nil then
    FCurrentQueryMap.DataAlias := DirEdit.Text;

end;

procedure TQueryMapTestForm.MapsStringGridDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  CellIndex : Integer;
  OverCol : Integer;
  OverRow : Integer;
begin

  GetDragOverColRow(MapsStringGrid, X, Y, OverCol, OverRow);
  Case OverCol of
    0 : Accept := (Source = SelectFieldsListBox);
    2 : begin
          Accept := (Source = SelectFieldsListBox);
          If OverRow < MapsStringGrid.RowCount then
          begin
            If (Source = SelectFieldsListBox) then
            begin
              MapListBox.Width  := MapsStringGrid.ColWidths[OverCol];

              CellIndex := 0;
              MapListBox.Left := 0;
              While CellIndex < OverCol do
                MapListBox.Left := MapListBox.Left + MapsStringGrid.ColWidths[OverCol];

              MapListBox.Items.CommaText := MapsStringGrid.Cells[OverCol, OverRow];
              MapListBox.Visible := True;
            end;
          end;
        end;
    3   : Accept := (Source = ResultFieldsListBox);
    else  Accept := False;
  end;  //case

end;

procedure TQueryMapTestForm.MapsStringGridDragDrop(Sender, Source: TObject;
  X, Y: Integer);
var
  DropCol : INteger;
  DropRow : Integer;
  SelFieldsListBox : TListBox;
  FieldName : String;
  CellContentsSL : TStringList;
begin
  GetDragOverColRow(MapsStringGrid, X, Y, DropCol, DropRow);
  If DropRow = 0 then DropRow := 1;

  CellContentsSL := TStringList.Create;
  try
    If Source = SelectFieldsListBox then
    begin
      SelFieldsListBox  := Source as TListBox;
      FieldName         := SelFieldsListBox.Items[SelFieldsListBox.ItemIndex];
      Case DropCol of
        0 : MapsStringGrid.Cells[DropCol, DropRow] := SelFieldsListBox.Items[SelFieldsListBox.ItemIndex];
        2 : begin
              CellContentsSL.CommaText := MapsStringGrid.Cells[DropCol, DropRow];
              If CellContentsSL.IndexOf(FieldName) = -1 then
              If Trim(MapsStringGrid.Cells[DropCol, DropRow]) = '' then MapsStringGrid.Cells[DropCol, DropRow] := FieldName
              else MapsStringGrid.Cells[DropCol, DropRow] := MapsStringGrid.Cells[DropCol, DropRow] + ', ' + FieldName;
            end;
      end;  //case
    end;
  finally
    CellContentsSL.Free;
  end;
end;

procedure TQueryMapTestForm.MapListBoxDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  DropLine : Integer;
begin
  If (Source = SelectFieldsListBox) or (Source = ResultFieldsListBox) then
  begin
    Accept := True;
    DropLine := Round(Y /  MapListBox.ItemHeight);
    If DropLine > MapListBox.Items.Count -1 then DropLine := -1;
    MapListBox.ItemIndex := DropLine;
  end;

end;

procedure TQueryMapTestForm.MapListBoxDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  DropLine        : Integer;
  SourceIndex        : Integer;
  SourceField        : String;
  SourceListBox   : TListBox;
begin
  If (Source is TListBox) then
  begin
    SourceListBox := Source as TListBox;
    If SourceListBox.ItemIndex >= 0 then
    begin
      For SourceIndex := 0 to SourceListBox.Items.Count -1 do
      begin
        If SourceListBox.Selected[SourceIndex]  then
        begin
          SourceField := SourceListBox.Items[SourceIndex];
          If MapListBox.Items.IndexOf(SourceField) < 0 then
          begin
            DropLine := Round(Y /  MapListBox.ItemHeight);
            If DropLine > MapListBox.Items.Count -1 then
              MapListBox.ItemIndex := MapListBox.Items.Add(SourceField)
            else
            begin
              MapListBox.Items.Insert(MapListBox.ItemIndex, SourceField);
              MapListBox.ItemIndex := MapListBox.ItemIndex -1;
            end;  //if dropline at end
          end;  //if item not in result field list
        end;  //if a selected item
      end;  //all items in select field list
    end;  //source is select field list
  end;  //if source is a list box
end;

procedure TQueryMapTestForm.CodeButtonClick(Sender: TObject);
var
  I : Integer;
  CodeSegment : String;
  OrigTemplate : String;
begin
  //save original template
  OrigTemplate := CodeMemo.Text;

  //prepare code template
  CodeMemo.Text := Replace(CodeMemo.Text, '{Directory}',     DirectoryListBox.Directory);

  //build select fields string
  CodeSegment := '';
  For i := 0 to SelectFieldsListBox.Items.Count-1 do
    CodeSegment := CodeSegment + SelectFieldsListBox.Items[i] + ',';
  CodeSegment := LeftString(CodeSegment, Length(CodeSegment)-1);
  CodeMemo.Text := Replace(CodeMemo.Text, '{SelectFields}',  CodeSegment );

  //build result fields string
  CodeSegment := '';
  For i := 0 to ResultFieldsListBox.Items.Count-1 do
    CodeSegment := CodeSegment + ResultFieldsListBox.Items[i] + ',';
  CodeSegment := LeftString(CodeSegment, Length(CodeSegment)-1);
  CodeMemo.Text := Replace(CodeMemo.Text, '{ResultFields}',  CodeSegment);

  //build result fields string
  CodeSegment := '';
  For i := 0 to TotalFieldsListBox.Items.Count-1 do
    CodeSegment := CodeSegment + TotalFieldsListBox.Items[i] + ',';
  CodeSegment := LeftString(CodeSegment, Length(CodeSegment)-1);
  CodeMemo.Text := Replace(CodeMemo.Text, '{TotalFields}',  CodeSegment);

  //build sql
  CodeSegment := '';
  For i := 0 to QueryMemo.Lines.Count -1 do
    CodeSegment := CodeSegment + #13#10 + '    + '' ' + Replace(QueryMemo.Lines[i], '''', '''''') + '''';
  CodeSegment := DelimitedString(CodeSegment, '+', True);
  CodeMemo.Text := Replace(CodeMemo.Text, '{SQL}',  '  ' + CodeSegment+ ';');

  //maps
  i := 1;
  CodeSegment := '';
  While     (MapsStringGrid.Cells[0,i] <> '')
        and (MapsStringGrid.Cells[1,i] <> '')
        and (MapsStringGrid.Cells[2,i] <> '')
        and (MapsStringGrid.Cells[3,i] <> '') do
  begin
    CodeSegment := CodeSegment + '  AddMap(''' + MapsStringGrid.Cells[0,i] + ''',';
    CodeSegment := CodeSegment + '  mcEquals,' ;
    CodeSegment := CodeSegment + '  ''' + MapsStringGrid.Cells[1,i] + ''','  ;
    CodeSegment := CodeSegment + '  ''' + MapsStringGrid.Cells[2,i] + ''',' ;
    CodeSegment := CodeSegment + '  ''' + MapsStringGrid.Cells[3,i] + ''');' +#13#10;
    Inc(i);
  end;
  CodeMemo.Text := Replace(CodeMemo.Text, '{Maps}',  '  ' + CodeSegment+ ';');

  Clipboard.SetTextBuf(PChar(CodeMemo.Text));

  //restore original template
  CodeMemo.Text := OrigTemplate;

end;

procedure TQueryMapTestForm.MapsStringGridKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  If (MapsStringGrid.Row = MapsStringGrid.RowCount-1)and  (Ord(Key) = VK_DOWN) then
  begin
    MapsStringGrid.RowCount := MapsStringGrid.RowCount +1;
  end;
end;


procedure TQueryMapTestForm.DeleteMenuClick(Sender: TObject);
var
  GridSL : TStringList;
begin
  If MapsPopupMenu.PopupComponent = MapsStringGrid then
  begin
    IF Sender = DeleteMenu then
    begin
      CurrentQueryMap.Maps.Objects[MapsStringGrid.Row-1].Free;
      CurrentQueryMap.Maps.Delete(MapsStringGrid.Row-1);
      If MapsStringGrid.Row >= MapsStringGrid.FixedRows then  //deleting a map
      begin
        GridSL := TStringList.Create;
        try
          GridSL.CommaText := GridToText(MapsStringGrid);
          GridSl.Delete(MapsStringGrid.Row);
          GridSL.Delete(0); //remove header info
          TextIntoGrid(MapsStringGrid, GridSL.CommaText);
        finally
          GridSL.Free;
        end;

      end;
    end;
  end;
end;

procedure TQueryMapTestForm.MapsStringGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ClickRow, ClickCOl : Integer;
begin
  If Button = mbRight then
  begin
    GetDragOverColRow(MapsStringGrid, X, Y, ClickCol, ClickRow);
    MapsStringGrid.Row := ClickRow;
  end;
end;

procedure TQueryMapTestForm.TotalFieldsListBoxDragDrop(Sender,
  Source: TObject; X, Y: Integer);
var
  DropLine    : Integer;
  InsertLine  : Integer;
  ResIndex    : Integer;
  ResField    : String;
begin
  If (Source = ResultFieldsListBox) and (ResultFieldsListBox.ItemIndex >= 0) then
  begin
    DropLine := TotalFieldsListBox.TopIndex+  Round(Y /  TotalFieldsListBox.ItemHeight); //which line dropped on
    If DropLine <= TotalFieldsListBox.Items.Count -1 then //within list
      InsertLine := DropLine  //insertion point
    else
      InsertLine := TotalFieldsListBox.Items.Count;  //or at end

    For ResIndex := ResultFieldsListBox.Items.Count -1 downto 0 do
    begin
      If ResultFieldsListBox.Selected[ResIndex]  then     //selected field
      begin
        ResField := ResultFieldsListBox.Items[ResIndex];
        If TotalFieldsListBox.Items.IndexOf(ResField) < 0 then //not in result field list yet
        begin
          TotalFieldsListBox.Items.Insert(InsertLine, ResField)
        end;  //if item not in total field list
      end;  //if a selected item
    end;  //all items in result field list
  end;  //source is result field list

end;

procedure TQueryMapTestForm.TotalFieldsListBoxDragOver(Sender,
  Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  DropLine : Integer;
begin
  If Source = ResultFieldsListBox then
  begin
    Accept := True;
    DropLine := TotalFieldsListBox.TopIndex +  Round(Y /  TotalFieldsListBox.ItemHeight);
    If DropLine > TotalFieldsListBox.Items.Count -1 then DropLine := -1;
    TotalFieldsListBox.ItemIndex := DropLine;
  end
  else
    Accept := False;
end;

procedure TQueryMapTestForm.TotalFieldsListBoxKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  SaveItemIndex : Integer;
begin
  If Ord(Key) = VK_DELETE then
  begin
    SaveItemIndex := TotalFieldsListBox.ItemIndex;
    TotalFieldsListBox.Items.Delete(TotalFieldsListBox.ItemIndex);
    TotalFieldsListBox.ItemIndex := MinIntValue([TotalFieldsListBox.Items.Count-1,SaveItemIndex]);
  end;
end;


end.
