//==============================================================================
//  Type          | Unit
//  Name          | PasswordTable
//  Description   | TTable class with modified CreateTable method for
//                | creating a table with a password. Additional methods
//                | had to be overriden in order to implement CreatTable
//------------------------------------------------------------------------------
// Date     | Who | Comments
//------------------------------------------------------------------------------
// 26/01/01 | MJD | Initial Release
//==============================================================================

unit PasswordTable;

interface
uses
   Windows,SysUtils,DB,DBTables,DBCommon,Bde;

type
   // Copy of sections of TTable needed to add password protection in
   // CreateTable, based upon code from Borland's DBTables.pas.
   // Changed sections highlighted with "Added By PSL"

   TPassTable = class(TTable)
   protected
     function IsDBaseTable: Boolean;
     function GetDriverTypeName(Buffer: PChar): PChar;
     function GetTableTypeName: PChar;
   public
     procedure CreateTable(Password:String);
   end;

implementation

function TPassTable.IsDBaseTable: Boolean;
begin
  Result := (TableType = ttDBase) or
    (CompareText(ExtractFileExt(TableName), '.DBF') = 0);
end;
function TPassTable.GetDriverTypeName(Buffer: PChar): PChar;
var
  Length: Word;
begin
  Result := Buffer;
  Check(DbiGetProp(HDBIOBJ(DBHandle), dbDATABASETYPE, Buffer,
    SizeOf(DBINAME), Length));
  if StrIComp(Buffer, szCFGDBSTANDARD) = 0 then
  begin
    Result := GetTableTypeName;
    if Result <> nil then Result := StrCopy(Buffer, Result);
  end;
end;
function TPassTable.GetTableTypeName: PChar;
const
  Names: array[TTableType] of PChar =
    (szPARADOX, szPARADOX, szDBASE, szASCII);
var
  TableTyp: TTableType;
  Extension: string;
begin
  Result := nil;
  if not Database.IsSQLBased then
  begin
    TableTyp := TableType;
    if TableTyp = ttDefault then
    begin
      Extension := ExtractFileExt(TableName);
      if CompareText(Extension, '.DBF') = 0 then TableTyp := ttDBase;
      if CompareText(Extension, '.TXT') = 0 then TableTyp := ttASCII;
    end;
    Result := Names[TableTyp];
  end;
end;
procedure TPassTable.CreateTable(Password:String);
var
  I: Integer;
  FieldDescs: PFLDDesc;
  ValCheckPtr: PVCHKDesc;
  DriverTypeName: DBINAME;
  TableDesc: CRTblDesc;
  LName: string;
  TempLocale, OldLocale: TLocale;
  SQLLName: DBIName;
  PSQLLName: PChar;
  LvlFldDesc: FLDDesc;
  Level: DBINAME;
  SPassword: DBIName; // Added By PSL

  function GetStandardLanguageDriver: string;
  var
    DriverName: string;
    Buffer: array[0..DBIMAXNAMELEN - 1] of char;
  begin
    if not Database.IsSQLBased then
    begin
      DriverName := GetTableTypeName;
      if DriverName = '' then
        if IsDBaseTable then
          DriverName := szDBASE else
          DriverName := szPARADOX;
      if DbiGetLdName(PChar(DriverName), nil, Buffer) = 0 then
        Result := Buffer;
    end
    else Result := '';
  end;

begin
  CheckInactive;
  if FieldDefs.Count = 0 then
    for I := 0 to FieldCount - 1 do
      with Fields[I] do
        if FieldKind = fkData then
          FieldDefs.Add(FieldName, DataType, Size, Required);
  FieldDescs := nil;
  FillChar(TableDesc, SizeOf(TableDesc), 0);
  with TableDesc do
  begin
    SetDBFlag(dbfTable, True);
    try
      AnsiToNative(Locale, TableName, szTblName, SizeOf(szTblName) - 1);
      if GetTableTypeName <> nil then
        StrCopy(szTblType, GetTableTypeName);
      iFldCount := FieldDefs.Count;
      FieldDescs := AllocMem(iFldCount * SizeOf(FLDDesc));
      TempLocale := nil;
      LName := GetStandardLanguageDriver;
      OldLocale := Locale;
      if (LName <> '') and (OsLdLoadBySymbName(PChar(LName), TempLocale) = 0) then
        SetLocale(TempLocale);
      try
        for I := 0 to FieldDefs.Count - 1 do
          with FieldDefs[I] do
          begin
            EncodeFieldDesc(PFieldDescList(FieldDescs)^[I], Name,
              DataType, Size);
            if (DataType = ftBCD) and (Precision > 0) then
              PFieldDescList(FieldDescs)^[I].iUnits1 := Precision;
            if Required then Inc(iValChkCount);
          end;
      finally
        if TempLocale <> nil then
        begin
          OsLdUnloadObj(TempLocale);
          SetLocale(OldLocale);
        end;
      end;
      pFldDesc := AllocMem(iFldCount * SizeOf(FLDDesc));
      PSQLLName := nil;
      if Database.IsSQLBased then
        if DbiGetLdNameFromDB(DBHandle, nil, SQLLName) = 0 then
          PSQLLName := SQLLName;
      Check(DbiTranslateRecordStructure(nil, iFldCount, FieldDescs,
        GetDriverTypeName(DriverTypeName), PSQLLName, pFLDDesc, False));
      iIdxCount := IndexDefs.Count;
      pIdxDesc := AllocMem(iIdxCount * SizeOf(IDXDesc));
      for I := 0 to IndexDefs.Count - 1 do
        with IndexDefs[I] do
          EncodeIndexDesc(PIndexDescList(pIdxDesc)^[I], Name, Fields,
            Options);
      if iValChkCount <> 0 then
      begin
        pVChkDesc := AllocMem(iValChkCount * SizeOf(VCHKDesc));
        ValCheckPtr := pVChkDesc;
        for I := 0 to FieldDefs.Count - 1 do
          if FieldDefs[I].Required then
          begin
            ValCheckPtr^.iFldNum := I + 1;
            ValCheckPtr^.bRequired := True;
            Inc(ValCheckPtr);
          end;
      end;

      if TableLevel > 0 then
      with TableDesc do
      begin
        iOptParams := 1;
        StrCopy(@Level, PChar(IntToStr(TableLevel)));
        pOptData := @Level;
        StrCopy(LvlFldDesc.szName, szCFGDRVLEVEL);
        LvlFldDesc.iLen := StrLen(Level);
        LvlFldDesc.iOffset := 0;
        pfldOptParams :=  @LvlFldDesc;
      end;

      // if password is blank then function as TTable.CreateTable  Added By PSL
      if Password <> '' then                                    // Added By PSL
      begin                                                     // Added By PSL
         StrPLCopy(SPassword, Password, SizeOf(SPassword) - 1); // Added By PSL
         CharToOEM(SPassword, SPassword);                       // Added By PSL
         TableDesc.bProtected:=True;                            // Added By PSL
         TableDesc.szPassword:=SPassword;                       // Added By PSL
      end;                                                      // Added By PSL

      Check(DbiCreateTable(DBHandle, True, TableDesc));
    finally
      if pVChkDesc <> nil then FreeMem(pVChkDesc, iValChkCount * SizeOf(VCHKDesc));
      if pIdxDesc <> nil then FreeMem(pIdxDesc, iIdxCount * SizeOf(IDXDesc));
      if pFldDesc <> nil then FreeMem(pFldDesc, iFldCount * SizeOf(FLDDesc));
      if FieldDescs <> nil then FreeMem(FieldDescs, iFldCount * SizeOf(FLDDesc));
      SetDBFlag(dbfTable, False);
    end;
  end;
end;

end.
