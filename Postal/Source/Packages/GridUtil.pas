unit GridUtil;

interface

uses
	StringUtil,
   Classes,
   Grids;

procedure CommaTextIntoGrid(  StringGrid : TStringGrid;
                              GridCommaText : String);

procedure TextIntoGrid(  StringGrid : TStringGrid;
                         GridText : String);

procedure FillStringGrid(  StringGrid  : TStringGrid;
                           StringList  : TStringList;
                           NumCols     : Integer);

function GridToText( StringGrid : TStringGrid ) : String;

procedure GetDragOverColRow(Grid : TStringGrid; X, Y : Integer; var Col, Row : Integer);

procedure InsertRow(Grid : TStringGrid; Index : Integer; RowCommaText : String);

procedure ResizeGridCols(StringGrid : TStringGrid);

implementation

function GridToText( StringGrid : TStringGrid ) : String;
var
  CommaTextStringList : TStringList;
  CommaTextLine       : TStringList;
  LineIndex           : Integer;
begin
  CommaTextStringList := TStringList.Create;
  CommaTextLine       := TStringList.Create;
  try
    For LineIndex := 0 to StringGrid.RowCount -1 do
      CommaTextStringList.Add(StringGrid.Rows[LineIndex].Text);
    Result := CommaTextStringList.CommaText;
  finally
    CommaTextStringList.Free;
    CommaTextLine.Free;
  end;

end;

procedure TextIntoGrid(  StringGrid : TStringGrid;
                           GridText : String);
var
  CommaTextStringList : TStringList;
  CommaTextLine       : TStringList;
  LineIndex           : Integer;
  NumCols             : Integer;
  OrigRow             : Integer;
begin
  With StringGrid do
  begin

    //clear grid
    RowCount := FixedRows + 1;  //min 1 row
    Rows[FixedRows].Clear;  //clear only non-fixed row

    If GridText <> '' then
    begin
      CommaTextStringList := TStringList.Create;
      CommaTextLine := TStringList.Create;
      try
        CommaTextStringList.CommaText := GridText;
        //save state
        OrigRow := Row;
        //size grid
        If CommaTextStringList.Count > 0 then
        begin
          StringGrid.ColCount := StringGrid.FixedCols;
          RowCount := FixedRows + CommaTextStringList.Count;
          //fill grid
          For LineIndex := 0+FixedRows to (CommaTextStringList.Count -1) + FixedRows do
          begin
            CommaTextLine.Text       := CommaTextStringList.Strings[LineIndex - FixedRows];  //each row
            NumCols                  := CommaTextLine.Count+FixedCols; //calc cols from number of strings
            If NumCols > StringGrid.ColCount then
              StringGrid.ColCount := NumCols;
            StringGrid.Rows[LineIndex+FixedRows-1].Text := CommaTextLine.Text;
          end;

          //try to select same row
          If OrigRow <= RowCount -1 then
          begin
             Row := OrigRow;
          end
          else
          begin
             Row := 1;
          end;
        end;  //If Count > FixedRows
      finally
        CommaTextStringList.Free;
        CommaTextLine.Free;
      end;  //try

    end; //if GridCommaTExt <> ''
  end;  //with dtringGrid

end;

procedure CommaTextIntoGrid(  StringGrid : TStringGrid;
                           GridCommaText : String);
var
  CommaTextStringList : TStringList;
	CommaTextLine       : TStringList;
	LineIndex           : Integer;
	NumCols             : Integer;
	OrigRow             : Integer;
	ColIndex						: Integer;
begin
  With StringGrid do
  begin

    //clear grid
    RowCount := FixedRows + 1;  //min 1 row
    Rows[FixedRows].Clear;  //clear only non-fixed row

    If GridCommaText <> '' then
    begin
      CommaTextStringList := TStringList.Create;
      CommaTextLine := TStringList.Create;
      try
        CommaTextStringList.CommaText := GridCommaText;
        //save state
        OrigRow := Row;
        //size grid
        If CommaTextStringList.Count > 0 then
        begin
          StringGrid.ColCount := StringGrid.FixedCols;
          RowCount := FixedRows + CommaTextStringList.Count;
          //fill grid
          For LineIndex := 0+FixedRows to (CommaTextStringList.Count -1) + FixedRows do
          begin
            CommaTextLine.CommaText       := CommaTextStringList.Strings[LineIndex - FixedRows];  //each row
            NumCols                  := CommaTextLine.Count+FixedCols; //calc cols from number of strings
            If NumCols > StringGrid.ColCount then
							StringGrid.ColCount := NumCols;
						StringGrid.Rows[LineIndex].CommaText := CommaTextLine.CommaText;
						For ColIndex := 0 to StringGrid.ColCount -1 do
							StringGrid.Cells[ColIndex, LineIndex] := Replace( StringGrid.Cells[ColIndex,LineIndex], '""', '');
					end;

					//try to select same row
					If OrigRow <= RowCount -1 then
          begin
             Row := OrigRow;
          end
          else
          begin
             Row := 1;
          end;
        end;  //If Count > FixedRows
      finally
        CommaTextStringList.Free;
        CommaTextLine.Free;
      end;  //try

    end; //if GridCommaTExt <> ''
  end;  //with dtringGrid

end;

procedure FillStringGrid(  StringGrid  : TStringGrid;
                           StringList  : TStringList;
                           NumCols     : Integer);
var
  ColIndex    : Integer;  //grid col
  NumItems    : Integer;  //toal items
  OrigRow     : Integer;  //original row selected
  RowIndex    : Integer;  //grid row
  StringIndex : Integer;
begin
  With  StringGrid,
        StringList do
  begin
    //save state
    OrigRow := Row;

    //clear grid
    RowCount := FixedRows + 1;  //min 1 row
    Rows[FixedRows].Clear;  //clear only non-fixed row

    //size grid
    NumItems := Count div NumCols;
    If NumItems > 0 then
    begin
      RowCount := FixedRows + NumItems;
      ColCount := NumCols;

      //fill grid
      StringIndex  := 0;  //start with first string
      For RowIndex := 0+FixedRows to (NumItems -1) + FixedRows do
      begin
         For ColIndex := 0 + FixedCols to (NumCols -1) + FixedCols  do
         begin
            Cells[ColIndex , RowIndex] := Strings[StringIndex];
            Inc(StringIndex);
         end;
      end;

      //try to select same row
      If OrigRow <= RowCount -1 then
      begin
         Row := OrigRow;
      end
      else
      begin
         Row := 1;
      end;
    end;
  end;
end;

procedure GetDragOverColRow(Grid : TStringGrid; X, Y : Integer; var Col, Row : Integer);
var
  Offset  : Integer;
begin
  //determine column
  Col := 0;
  Offset := 0;
  Repeat
    Inc(Offset, Grid.ColWidths[Col]);
    Inc(Col);
  until  (Offset > X);
  Dec(Col);

  //determine row
  Row := 0;
  Offset := 0;
  Repeat
    Inc(Offset, Grid.RowHeights[Row]);
    Inc(Row);
  until  (Offset > Y);
  Dec(Row);
end;

procedure InsertRow(Grid : TStringGrid; Index : Integer; RowCommaText : String);
begin
  With TStringList.Create do
  begin
    try
      CommaText := GridToText(Grid);
      Insert(Index, RowCommaText);
      CommaTextIntoGrid(Grid,CommaText);
    finally
      Free;
    end;
  end;
end;

procedure ResizeGridCols(StringGrid : TStringGrid);
const
  Margin = 12;
var
  ColIndex : Integer;
begin
  With StringGrid do
  begin
    For ColIndex := 0 to ColCount -1 do
    begin
      ColWidths[ColIndex] :=
        (StringGrid.Width - 2*Margin) div ColCount;
    end;
  end;
end;

end.
