unit QueryMapU;

interface

uses
  GPCSErrorLine,
  GPCSGuid,
  DbUtil,
  Db,
  DbTables,
  Controls,
  Math,
  ComObj,
  DatabaseServer_TLB,
  Forms,
  RegistryEx,
  StringUtil,
  SysUtils,  Classes;

type
  TMapComparison = (mcLessThan, mcEquals, mcMoreThan);

  TFieldMap = class
    CompareField  : String;         //field to be compared
    Comparison    : TMapComparison; //type of comparison
    CompareValue  : String;         //value to compare against
    SelectFields  : String;         //select fields to be mapped
    ResultFields  : String;         //result fields to be populated
  public
    procedure SaveToStream(Stream : TStream);
    procedure LoadFromStream(Stream : TStream);
  end;

  TFieldMapList = class(TStringList)
    procedure AddMap(NewFieldMap : TFieldMap);
  end;

  TQueryMap = class
  private
    FApplicationName  : String;
    FColWidths        : String;
    FDataAlias        : String;
    FName             : String;
    FSQL              : String;
    ResultTable       : TTable;

    function CreateResultTable(ResultQuery : TQuery) : TTable;
    procedure SetName(NewName : String);

    function GetResultFields  : String;
    procedure SetResultFields(NewValue : String);
    function GetSelectFields  : String;
    procedure SetSelectFields(NewValue : String);
    function GetTotalFields  : String;
    procedure SetTotalFields(NewValue : String);


  public
    ResultTableName : String;
    Maps : TFieldMapList; //maps of select fields to result fields
    ResultFieldsSL   : TStringList;
    SelectFieldsSL   : TStringList;
    TotalFieldsSL    : TStringList;
    Totals           : Variant;    

    constructor Create;
    destructor Destroy; override;
    property ColWidths                  : String read FColWidths write FColWidths;
    property DataAlias                  : String read FDataAlias write FDataAlias;
    property Name                       : String read FName write SetName;
    property ResultFields               : String read GetResultFields write SetResultFields;
    property SelectFields               : String read GetSelectFields write SetSelectFields;
    property TotalFields                : String read GetTotalFields write SetTotalFields;
    property SQL                        : String read FSQL  write FSQL;
    procedure AddMap(CompareField : String; Comparison : TMapComparison; CompareValue : String;
                            SelectFields : String; ResultFields  : String);
    procedure ClearMaps;

    function Execute                    : String;
    function QueryToCommaText(SQLText : String) : WideString;
    procedure SaveToStream(Stream : TStream);
    procedure LoadFromStream(Stream : TStream);
	end;

	function AliasQueryToCommaText(Alias, SQL : String) : String;

implementation

function AliasQueryToCommaText(Alias, SQL : String) : String;
var
	QueryMap : TQueryMap;
begin
	QueryMap := TQueryMap.Create;
	try
		QueryMap.DataAlias := Alias;
		Result := QueryMap.QueryToCommaText(SQL);
	finally
		QueryMap.Free;
	end;
end;

procedure TFieldMapList.AddMap(NewFieldMap : TFieldMap);
begin
  AddObject(IntToStr(Count), NewFieldMap); //add a field map to list
end;

procedure TFieldMap.SaveToStream(Stream : TStream);
var
  SL : TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Add(CompareField);
    Case Comparison of
      mcLessThan : SL.Add('mcLessThan');
      mcEquals   : SL.Add('mcEquals');
      mcMoreThan : SL.Add('mcMoreThan');
    end;  //case
    SL.Add(CompareValue);
    SL.Add(SelectFields);
    SL.Add(ResultFields);
    SL.SaveToStream(Stream);
  finally
    SL.Free;
  end
end;

procedure TFieldMap.LoadFromStream(Stream : TStream);
var
  SL : TStringList;
begin
  SL := TStringList.Create;
  try
    SL.LoadFromStream(Stream);
    CompareField := SL[0];
         If SL[1] = 'mcLessThan' then Comparison := mcLessThan
    else If SL[1] = 'mcEquals'   then Comparison := mcEquals
    else If SL[1] = 'mcMoreThan' then Comparison := mcMoreThan;
    CompareValue := SL[2];
    SelectFields := SL[3];
    ResultFields := SL[4];
  finally
    SL.Free;
  end
end;

function TQueryMap.CreateResultTable(ResultQuery : TQuery) : TTable;
var
  FieldType   : TFieldType;
  FieldLength : Integer;
  FieldIndex  : Integer;
  FieldFound  : Integer;
  SelectField : TFieldDef;
  Path        : String;
  TableName   : String;

  function StringToFieldType(FieldTypeString : String) : TFieldType;
  begin
    With TStringList.Create do
    begin
      try
        CommaText := 'ftUnknown, ftString, ftSmallint, ftInteger, ftWord, ftBoolean, ftFloat, ftCurrency, ftBCD, ftDate, ftTime, ftDateTime, ftBytes, ftVarBytes, ftAutoInc, ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor';
        Result :=  TFieldType(IndexOf('ft'+FieldTypeString));
      finally
        Free;
      end;
    end;
  end;

begin
  Result := nil;
  If ResultQuery = nil then Exit;
  If ResultFieldsSL.Count = 0 then Exit;
  TableName := ExtractFileName(ResultTableName);
  If TableName = '' then Exit;
  Result := TTable.Create(nil);
  Result.TableName := TableName;
  Path := ExtractFilePath(ResultTableName);
  If Path <> '' then Result.DatabaseName := Path
  else Result.DatabaseName := 'PSL';

  //create structure
  //add field for each field in returned set
  For FieldIndex := 0 to ResultFieldsSL.Count -1 do
  begin


    //create result fields
    FieldFound := SelectFieldsSL.IndexOf(ResultFieldsSL[FieldIndex]);   //is result field in select fields
    //check for specific field types   (eg, wsnumber, recordid, info(string^30)
    FieldType   := StringToFieldType(SubString(ResultFieldsSL[FieldIndex], '(','^'));
    FieldLength := StrToIntDef(SubString(ResultFieldsSL[FieldIndex], '^',')'),-1);
    If (FieldType <> TFieldType(-1)) and (FieldLength <> -1) then
    begin
      //add a specific field definition
      ResultFieldsSL[FieldIndex] := DelimitedString(ResultFieldsSL[FieldIndex], '(', False);
      Result.FieldDefs.Add(ResultFieldsSL[FieldIndex], FieldType, FieldLength, False);
    end
    else If FieldFound > -1 then //field in the query
    begin
      SelectField := ResultQuery.FieldDefs[FieldFound];
      Result.FieldDefs.Add(ResultFieldsSL[FieldIndex], SelectField.DataType, SelectField.Size, SelectField.Required);
    end
    else  //virtual field from a map
    begin
      Result.FieldDefs.Add(ResultFieldsSL[FieldIndex], ftString, 100, False);
    end;
  end;
  Result.CreateTable;
end;

function TQueryMap.QueryToCommaText(SQLText : String) : WideString;
var
	FieldIndex        : Integer;
	FieldStringList   : TStringList;
	RecordStringList  : TStringList;
	ResultQuery       : TQuery;
begin
	Result := '';
	//build query result stringlists
	FieldStringList   := TStringList.Create;
	RecordStringList  := TStringList.Create;
  ResultQuery := TQuery.Create(nil);
  try
    With RecordStringList, ResultQuery do
	  begin
      Close;
      DatabaseName := FDataAlias;
      ResultQuery.SQL.Text := SQLText;
      Open;
      //create result table
      ResultTable := CreateResultTable(ResultQuery);
      First;
      FieldStringList.Clear;
      While not EOF do
      begin
        For FieldIndex := 0 to FieldCount - 1 do
        begin
          if Fields[FieldIndex].DataType = ftCurrency then
          begin
             if Fields[FieldIndex].Value = null then
                FieldStringList.Add('0')
             else
                FieldStringList.Add(CurrToStrF(Fields[FieldIndex].Value,ffNumber,CurrencyDecimals));
          end
          else If Fields[FieldIndex].AsString = '' then
             FieldStringList.Add('""')
          else
             FieldStringList.Add(Fields[FieldIndex].AsString);
        end;
        RecordStringList.Add(FieldStringList.CommaText);  //add each record
        FieldStringList.Clear;
        Next;
      end;
      Result := RecordStringList.CommaText;
    end;  //with RecordStringList, ResultQuery
  except
    On E : Exception do
      RaiseGUIDException('{483C397C-8D50-49F8-AFDB-D2B234BD324C}' + SQLText, E);
  end;
  ResultQuery.Close;
  ResultQuery.Free;
  FieldStringList.Free;
  RecordStringList.Free;
end;

procedure TQueryMap.SaveToStream(Stream : TStream);
begin
end;

procedure TQueryMap.LoadFromStream(Stream : TStream);
begin
end;

constructor TQueryMap.Create;
begin
  inherited Create;
  FApplicationName  := ExtractFileName(Application.ExeName);
  FApplicationName  := DelimitedString(FApplicationName,'.',False);
  FDataAlias        := 'PSL'; //default
  Maps              := TFieldMapList.Create;
  ResultFieldsSL   := TStringList.Create;
  SelectFieldsSL   := TStringList.Create;
  TotalFieldsSL    := TStringList.Create;  
  ResultTableName   := '';
end;

destructor TQueryMap.Destroy;
var
  FieldMapIndex   : Integer;
  FieldMapStream  : TStringStream;
begin
  If FName <> '' then
  begin

    //clean up registry
    RegistryEx.DeleteKeyTree('HKCU\Software\PSL\'
                                  + FApplicationName
                                  + '\Query History\'
                                  + FName);

    RegistryEx.WriteRegistryValue('HKCU\Software\PSL\'
                                  + FApplicationName
                                  + '\Query History\'
                                  + FName + '\SQL', SQL);

    RegistryEx.WriteRegistryValue('HKCU\Software\PSL\'
                                  + FApplicationName
                                  + '\Query History\'
                                  + FName + '\ColWidths', FColWidths);

    RegistryEx.WriteRegistryValue('HKCU\Software\PSL\'
                                  + FApplicationName
                                  + '\Query History\'
                                  + FName + '\SelectFields', SelectFields);

    RegistryEx.WriteRegistryValue('HKCU\Software\PSL\'
                                  + FApplicationName
                                  + '\Query History\'
                                  + FName + '\ResultFields', ResultFields);



    For FieldMapIndex := 0 to Maps.Count -1 do
    begin
      FieldMapStream := TStringStream.Create('');
      try
        (Maps.Objects[FieldMapIndex] as TFieldMap).SaveToStream(FieldMapStream);
        RegistryEx.WriteRegistryValue('HKCU\Software\PSL\'
                                    + FApplicationName
                                    + '\Query History\'
                                    + FName + '\Map' + IntToStr(FieldMapIndex) ,
                                      FieldMapStream.DataString);
      finally
        FieldMapStream.Free;
      end;
    end;
  end;

  ClearMaps;
  Maps.Free;

  ResultFieldsSL.Free;
  SelectFieldsSL.Free;
  TotalFieldsSL.Free;

  inherited Destroy;
end;

procedure TQueryMap.SetName(NewName : String);
var
  FieldMap          : TFieldMap;
  FieldMapIndex     : Integer;
  FieldMapStream    : TStringStream;
  FieldMapStreamVar : Variant;

begin
  If NewName <> '' then
  begin
    FName := NewName;
    SQL := RegistryEx.ReadRegistryStringValue('HKCU\Software\PSL\'
                                              + FApplicationName
                                              + '\Query History\'
                                              + FName + '\SQL');
    FColWidths := RegistryEx.ReadRegistryStringValue('HKCU\Software\PSL\'
                                              + FApplicationName
                                              + '\Query History\'
                                              + FName + '\ColWidths');

    SelectFields := RegistryEx.ReadRegistryStringValue('HKCU\Software\PSL\'
                                              + FApplicationName
                                              + '\Query History\'
                                              + FName + '\SelectFields');

    ResultFields := RegistryEx.ReadRegistryStringValue('HKCU\Software\PSL\'
                                              + FApplicationName
                                              + '\Query History\'
                                              + FName + '\ResultFields');

    //get maps
    FieldMapIndex := 0;
    Repeat
      FieldMapStreamVar := RegistryEx.ReadRegistryValue('HKCU\Software\PSL\'
                                        + FApplicationName
                                        + '\Query History\'
                                        + FName + '\Map' + IntToStr(FieldMapIndex));
      If not VarIsNull(FieldMapStreamVar) then
      begin
        FieldMapStream := TStringStream.Create(FieldMapStreamVar);
        try
          If FieldMapStream.DataString <> '' then
          begin
            FieldMap := TFieldMap.Create;
            FieldMap.LoadFromStream(FieldMapStream);
            Maps.AddObject(IntToStr(FieldMapIndex),FieldMap);
          end;  //if maps exist in registry
        finally
          FieldMapStream.Free;
        end;
        Inc(FieldMapIndex);
      end;  //stream in reg
    Until VarIsNull(FieldMapStreamVar);
  end;  //new name not blank
end;

function TQueryMap.Execute    : String;
var
  CompareFieldIndex   : Integer;
  FieldMap            : TFieldMap;
  MapFound            : Boolean;
  MapIndex            : Integer;
  MapSelectFieldIndex : Integer;
  MapSelectFieldsSL   : TStringList;
  MapResultFieldIndex : Integer;
  MapResultFieldsSL   : TStringList;
  RecordIndex         : Integer;
  RecordSL            : TStringList;
  RecordsSL           : TStringList;
  ResultLineSL        : TStringList;
  ResultLinesSL       : TStringList;
  TotalFieldIndex     : Integer;
begin
  MapSelectFieldsSL   := TStringList.Create;
  MapResultFieldsSL   := TStringList.Create;
  RecordSL            := TStringList.Create;
  RecordsSL           := TStringList.Create;
  ResultLineSL        := TStringList.Create;
  ResultLinesSL       := TStringList.Create;

  //init totals array
  If TotalFieldsSL.Count > 0 then
  begin
    Totals := VarArrayCreate([0, ResultFieldsSL.Count-1], varCurrency);
    For TotalFieldIndex := 0 to VarArrayHighBound(Totals,1) do
      Totals[TotalFieldIndex] := 0;
  end;

  try
    RecordsSL.CommaText := QueryToCommaText(FSQL);

    //go through all returned records
    RecordIndex := 0;
    While RecordIndex <= RecordsSL.Count -1 do
    begin

      //grab next record
      RecordSL.CommaText := RecordsSL[RecordIndex];

      //process field maps
      MapFound  := False;
      MapIndex  := 0;
      While (MapIndex < Maps.Count ) and (not MapFound) do
      begin
        FieldMap := Maps.Objects[MapIndex] as TFieldMap;

        //check comparison field
        CompareFieldIndex := SelectFieldsSL.IndexOf(FieldMap.CompareField);
        If CompareFieldIndex > -1 then
        begin
          If RecordSL[CompareFieldIndex] = FieldMap.CompareValue then
          begin
            MapFound := True;

            //ensure there is a valid result line
            If ResultLineSL.Count = 0 then
            begin
              While ResultLineSL.Count < ResultFieldsSL.Count do
                ResultLineSL.Add('""');
            end;

            MapSelectFieldsSL.CommaText := FieldMap.SelectFields;
            MapResultFieldsSL.CommaText := FieldMap.ResultFields;

            //process all of the map's fields
            While (MapSelectFieldsSL.Count > 0) and (MapResultFieldsSL.Count > 0) do
            begin
              //locate map select/result field in query select/result fields
              MapSelectFieldIndex := SelectFieldsSL.IndexOf(MapSelectFieldsSL[0]);
              MapResultFieldIndex := ResultFieldsSL.IndexOf(MapResultFieldsSL[0]);
              If (MapSelectFieldIndex > -1) and (MapResultFieldIndex > -1) then
              begin
                ResultLineSL[MapResultFieldIndex] := RecordSL[MapSelectFieldIndex];
                //update totals
                TotalFieldIndex := TotalFieldsSL.IndexOf(MapResultFieldsSL[0]);
                If TotalFieldIndex > -1 then  //result field in total
                  Totals[MapResultFieldIndex] := Totals[MapResultFieldIndex] + StrToCurrDef(ResultLineSL[MapResultFieldIndex],0);
              end;  //if map select/result fields both found
              //remove mapped values
              MapSelectFieldsSL.Delete(0);
              MapResultFieldsSL.Delete(0);
            end;  //while more fields to map

          end;  //if comparefield matches
        end;  //if compare located in selectfields
        Inc(MapIndex);
      end;  //try maps until one found

      //non-mappable records
      If not MapFound then //found a starting record
      begin
        //add any result line
        If ResultLineSL.Count > 0 then
          ResultLinesSL.Add(ResultLineSL.CommaText);

        //reset a result line
        ResultLineSL.Clear;
        While ResultLineSL.Count < ResultFieldsSL.Count do
          ResultLineSL.Add('""');

        //grab next record
        RecordSL.CommaText := RecordsSL[RecordIndex];

        //straight mappings
        For MapSelectFieldIndex := 0 to MinIntValue([SelectFieldsSL.Count, RecordSL.Count]) -1  do
        begin
          //locate the select field in the result field
          MapResultFieldIndex := ResultFieldsSL.IndexOf(SelectFieldsSL[MapSelectFieldIndex]);
          If MapResultFieldIndex > -1 then //select field also in result fields
          begin
            ResultLineSL[MapResultFieldIndex] :=  RecordSL[MapSelectFieldIndex];
            //update totals
            TotalFieldIndex := TotalFieldsSL.IndexOf(SelectFieldsSL[MapSelectFieldIndex]);
            If TotalFieldIndex > -1 then  //result field in total
              Totals[MapResultFieldIndex] := Totals[MapResultFieldIndex] + StrToCurrDef(ResultLineSL[MapResultFieldIndex],0);
          end;  //if select field in result field
        end;  //for all select fields
      end;  //if no map found

      //next record
      Inc(RecordIndex);

    end;  //while recordindex <= recordcount

    //add last result line
    If ResultLineSL.Count > 0 then
      ResultLinesSL.Add(ResultLineSL.CommaText);
    //add totals
    If TotalFieldsSL.Count > 0 then
    begin
      ResultLineSL.Clear;
      While ResultLineSL.Count < ResultFieldsSL.Count do
        If Totals[ResultLineSL.Count] <> 0 then
          ResultLineSL.Add(CurrToStr(Totals[ResultLineSL.Count]))
        else
          ResultLineSL.Add('""');
      ResultLinesSL.Add(ResultLineSL.CommaText);
    end;

    Result := ResultLinesSL.CommaText;

    //add result to result table
    CommaTextIntoTable(Result, ResultTable);

  finally
    ResultTable.Free;
    RecordSL.Free;
    RecordsSL.Free;
    ResultLineSL.Free;
    ResultLinesSL.Free;
  end;
end;

procedure TQueryMap.AddMap(CompareField : String; Comparison : TMapComparison; CompareValue : String;
                        SelectFields : String; ResultFields  : String);
var
  NewFieldMap : TFieldMap;
begin
  NewFieldMap := TFieldMap.Create;                   //setup a new field map
  NewFieldMap.CompareField  := CompareField;
  NewFieldMap.Comparison    := Comparison;
  NewFieldMap.CompareValue  := CompareValue;
  NewFieldMap.SelectFields  := SelectFields;
  NewFieldMap.ResultFields  := ResultFields;
  Maps.AddObject(IntToStr(Maps.Count), NewFieldMap); //add a field map to list

end;

procedure TQueryMap.ClearMaps;
begin
  While Maps.Count > 0 do
  begin
    Maps.Objects[0].Free;
    Maps.Delete(0);
  end;
end;

function TQueryMap.GetResultFields  : String;
begin
  Result := ResultFieldsSL.CommaText;
end;

procedure TQueryMap.SetResultFields(NewValue : String);
begin
  ResultFieldsSL.CommaText := NewValue;
end;

function TQueryMap.GetSelectFields  : String;
begin
  Result := SelectFieldsSL.CommaText;
end;

procedure TQueryMap.SetSelectFields(NewValue : String);
begin
  SelectFieldsSL.CommaText := NewValue;
end;

function TQueryMap.GetTotalFields  : String;
begin
  Result := TotalFieldsSL.CommaText;
end;

procedure TQueryMap.SetTotalFields(NewValue : String);
begin
  TotalFieldsSL.CommaText := NewValue;
end;

end.
