//Webpage : http://www.borland.com/devsupport/bde/bdeapiex/dbidorestructure.html


unit DBUtil;

interface

uses
  ActiveX,
  ComObj,
  GPCSBase_TLB,
   DBGrids,StringUtil,Classes,Math,SysUtils,PackStrListU,
   Windows,Forms,DB,DBTables,BDE,Dialogs,GPCSErrorLine;

type
  ChangeRec = packed record
    szName: DBINAME;
    iType: word;
    iSubType: word;
    iLength: word;
    iPrecision: byte;
  end;


procedure AddAuxPassword(Table: TTable; mstrpswd, pswd: string; rights: PRVType);
//AddAuxPassword(Table1, 'MyMstrPswd', 'MyNewAuxPswd', pvrINSDEL)

procedure AddField(Table: TTable; NewField: ChangeRec);
//NOTE: You must fill in all options in the ChangeRec with 0 or '' if the option

procedure AddLookupTable(Table, LookupTable: TTable; LookupField: TField);
//AddLookupTable(Table3, Table4, Table3.FieldByName('Lookup'));

procedure AddMasterPassword(Table: TTable; pswd: string);
//AddMasterPassword(Table1, 'MyNewPassword')

procedure AddRI(Master, Detail: TTable; RIName: string; ModOp, DelOp: RINTQual);
//AddRI(Table2, Table3, 'CustomerRI', rintRESTRICT, rintRESTRICT);

procedure AddValidityCheck(Tbl: TTable; Field: TField; MinVal, MaxVal,
           DefVal: pLongint; Required: Bool);
//The field must be a longint, and the TTable must be open.
//AddValidityCheck(Table4, Table4.Fields[0], @Min, @Max, nil, True)

procedure ChangeField(Table: TTable; Field: TField; Rec: ChangeRec);
//NOTE: You must fill in all options in the ChangeRec with 0 or '' if the option
//is not used in the restructure. FillChar can be used to do this:
//Fillchar(MyChangeRec, sizeof(MyChangeRec), 0);
//ChangeField(Table1, Table1.FieldByName('FOO'), MyChangeRec)

procedure ChangePIdx(Table: TTable; Fields: word);
//This input will take an existing primary index and change it to apply to the
//first 2 fields in the table.

procedure CreateView(FileName, ViewSQL : String);
//creates a view

procedure CommaTextIntoTable(CommaText : String; Table : TTable);
//adds commatext as table records

procedure FitColumnWidths(DBGrid : TDBGrid);
//fits column widths in a db grid

procedure PackTable(Table: TTable);
// Pack a Paradox or dBASE table
// The table must be opened execlusively before calling this function...

procedure RemoveAuxPassword(Table: TTable; mstrpswd, pswd: string);
//RemoveAuxPassword(Table1, 'MstrPswd', 'AuxToRemove')

procedure RemoveMasterPassword(Table: TTable);
//RemoveMasterPassword(Table1)

procedure RemoveRI(Detail: TTable; SeqNo: word; RIName: PChar);
//RemoveRI(DetailRITable, 0, 'RIName'); OR
//RemoveRI(DetailRITable, 1, nil);

procedure RestructureTable(Table: TTable; Option, OptData: string);
//RestructureTable(Table1, 'LEVEL', '7') Change table level to 7
//RestructureTable(Table1, 'BLOCK SIZE', '4096') Change table block size to 4096

//run a query over the PSL alias and return results as packtext
function QueryToPackText(QueryText:String):String;

//run a query over the Named alias and return results as packtext
function AliasQueryToPackText(Alias,QueryText:String):String;

//post txn and wait for record to be written until timeout
function WaitForRecord(TxnLog : ITransactionLog;Info : String; TimeOut : Integer):Boolean;

implementation

function QueryToPackText(QueryText:String):String;
begin
  Result:=AliasQueryToPackText('PSL',QueryText);
end;
function AliasQueryToPackText(Alias,QueryText:String):String;
var                         
  Query       : TQuery;
  AllRecsSL   : TPackStringList;
  RecSL       : TPackStringList;
  I           : Integer;
  FieldStr    : String;
begin
  try
    AllRecsSL   := TPackStringList.Create;
    RecSL       := TPackStringList.Create;
    Query       := TQuery.Create(nil);
    try
       //execute query
       with Query do
       begin
          DatabaseName:=Alias;
          SQL.Text:=QueryText;
          Active:=True;
          First;
          //go through ny returned records
          while (not EOF) do
          begin
             try
                //got through all fields
                for I:=0 to FieldCount-1 do
                begin
                   //evaluate datetimes as floats?
                   if ((Fields[I] is TDateTimeField)
                    or  (Fields[I] is TTimeField)
                    or  (Fields[I] is TDateField)) then
                   begin
                      Str(Fields[I].Value,FieldStr);
                      RecSL.Add(FieldSTr);
                   end
                   else  //non-datetime field
                      RecSL.Add(Fields[I].AsString);
                end;
                AllRecsSL.Add(RecSL.PackText);
             except
                On E : Exception do
                  RaiseGUIDException('{4529B823-B6D3-4CB4-B0B8-0EFC322EA34D}'+Application.ExeName+' '+QueryText , E);
             end;
             RecSL.Clear;
             Next;  //netx record
          end;
          Active:=False;  //kill query
       end;
    except
       On E : Exception do
         RaiseGUIDException('{25F78B59-2C27-45C8-97AA-94D0D7AB66D4}'+Application.ExeName+' '+QueryText , E);
    end;
    Query.Free;
    RecSL.Free;
    Result:=AllRecsSL.PackText; //return packtext of records
    AllRecsSL.Free;
  except
    On E : Exception do
      RaiseGUIDException('{F702123D-ABDF-4545-BB30-BF55B09CF680}'+Application.ExeName+' '+QueryText , E);
  end;
end;
// Pack a Paradox or dBASE table
// The table must be opened execlusively before calling this function...
procedure PackTable(Table: TTable);
var
  Props: CURProps;
  hDb: hDBIDb;
  TableDesc: CRTblDesc;

begin
  // Make sure the table is open exclusively so we can get the db handle...
  if Table.Active = False then
    raise EDatabaseError.Create('Table must be opened to pack');
  if Table.Exclusive = False then
    raise EDatabaseError.Create('Table must be opened exclusively to pack');

  // Get the table properties to determine table type...
  Check(DbiGetCursorProps(Table.Handle, Props));

  // If the table is a Paradox table, you must call DbiDoRestructure...
  if Props.szTableType = szPARADOX then
  begin
    // Blank out the structure...
    FillChar(TableDesc, sizeof(TableDesc), 0);
    //  Get the database handle from the table's cursor handle...
    Check(DbiGetObjFromObj(hDBIObj(Table.Handle), objDATABASE, hDBIObj(hDb)));
    // Put the table name in the table descriptor...
    StrPCopy(TableDesc.szTblName, Table.TableName);
    // Put the table type in the table descriptor...
    StrPCopy(TableDesc.szTblType, Props.szTableType);
    // Set the Pack option in the table descriptor to TRUE...
    TableDesc.bPack := True;
    // Close the table so the restructure can complete...
    Table.Close;
    // Call DbiDoRestructure...
    Check(DbiDoRestructure(hDb, 1, @TableDesc, nil, nil, nil, FALSE));
  end
  else
    // If the table is a dBASE table, simply call DbiPackTable...
    if Props.szTableType = szDBASE then
      Check(DbiPackTable(Table.DBHandle, Table.Handle, nil, szDBASE, TRUE))
    else
      // Pack only works on PAradox or dBASE; nothing else...
      raise EDatabaseError.Create('Table must be either of Paradox or dBASE ' +
               'type to pack');

  Table.Open;
end;

procedure ChangeField(Table: TTable; Field: TField; Rec: ChangeRec);
{
NOTE: You must fill in all options in the ChangeRec with 0 or '' if the option is not used in the restructure. FillChar can be used to do this: Fillchar(MyChangeRec, sizeof(MyChangeRec), 0);
ChangeField(Table1, Table1.FieldByName('FOO'), MyChangeRec)
}

var
  Props: CURProps;
  hDb: hDBIDb;
  TableDesc: CRTblDesc;
  pFields: pFLDDesc;
  pOp: pCROpType;
  B: byte;

begin
  // Initialize the pointers...
//  pFields := nil; pOp := nil;
  // Make sure the table is open exclusively so we can get the db handle...
  if Table.Active = False then
    raise EDatabaseError.Create('Table must be opened to restructure');
  if Table.Exclusive = False then
    raise EDatabaseError.Create('Table must be opened exclusively to restructure');

  Check(DbiSetProp(hDBIObj(Table.Handle), curxltMODE, integer(xltNONE)));
  // Get the table properties to determine table type...
  Check(DbiGetCursorProps(Table.Handle, Props));

  // Make sure the table is either Paradox or dBASE...
  if (Props.szTableType <> szPARADOX) and (Props.szTableType <> szDBASE) then
    RaiseGUIDException('{D3FF8193-AD31-4A8E-B37A-E2636CD97B69',EDatabaseError.Create('Field altering can only occur on Paradox or dBASE tables'))
  else
  begin
     // Allocate memory for the field descriptor...
     pFields := AllocMem(Table.FieldCount * sizeof(FLDDesc));
     // Allocate memory for the operation descriptor...
     pOp := AllocMem(Table.FieldCount * sizeof(CROpType));
     try
       // Set the pointer to the index in the operation descriptor to put
       // crMODIFY (This means a modification to the record is going to happen)...
       Inc(pOp, Field.Index);
       pOp^ := crMODIFY;
       Dec(pOp, Field.Index);
       // Fill the field descriptor with the existing field information...
       Check(DbiGetFieldDescs(Table.Handle, pFields));
       // Set the pointer to the index in the field descriptor to make the
       // midifications to the field
       Inc(pFields, Field.Index);

       // If the szName portion of the ChangeRec has something in it, change it...
       if StrLen(Rec.szName) > 0 then
         pFields^.szName := Rec.szName;
       // If the iType portion of the ChangeRec has something in it, change it...
       if Rec.iType > 0 then
         pFields^.iFldType := Rec.iType;
       // If the iSubType portion of the ChangeRec has something in it, change it...
       if Rec.iSubType > 0 then
         pFields^.iSubType := Rec.iSubType;
       // If the iLength portion of the ChangeRec has something in it, change it...
       if Rec.iLength > 0 then
         pFields^.iUnits1 := Rec.iLength;
       // If the iPrecision portion of the ChangeRec has something in it, change it...
       if Rec.iPrecision > 0 then
         pFields^.iUnits2 := Rec.iPrecision;
       Dec(pFields, Field.Index);

       for B := 1 to Table.FieldCount do begin
         pFields^.iFldNum := B;
         Inc(pFields, 1);
       end;
       Dec(pFields, Table.FieldCount);

       // Blank out the structure...
       FillChar(TableDesc, sizeof(TableDesc), 0);
       //  Get the database handle from the table's cursor handle...
       Check(DbiGetObjFromObj(hDBIObj(Table.Handle), objDATABASE, hDBIObj(hDb)));
       // Put the table name in the table descriptor...
       StrPCopy(TableDesc.szTblName, Table.TableName);
       // Put the table type in the table descriptor...
       StrPCopy(TableDesc.szTblType, Props.szTableType);
       // The following three lines are necessary when doing any field restructure
       // operations on a table...

       // Set the field count for the table
       TableDesc.iFldCount := Table.FieldCount;
       // Link the operation descriptor to the table descriptor...
       TableDesc.pecrFldOp := pOp;
       // Link the field descriptor to the table descriptor...
       TableDesc.pFldDesc := pFields;
       // Close the table so the restructure can complete...
       Table.Close;
       // Call DbiDoRestructure...
       Check(DbiDoRestructure(hDb, 1, @TableDesc, nil, nil, nil, FALSE));
     finally
       if pFields <> nil then
         FreeMem(pFields);
       if pOp <> nil then
         FreeMem(pOp);
     end;
  end;
end;

procedure CommaTextIntoTable(CommaText : String; Table : TTable);
var
  FieldIndex  : Integer;
  RecordIndex : Integer;
  DataSL      : TStringList;
  RecordSL    : TStringList;
begin
  If (Table = nil) or (CommaText = '') then Exit;
  DataSL    := TStringList.Create;
  RecordSL  := TStringList.Create;
  try
    DataSL.CommaText := CommaText;
    For RecordIndex := 0 to DataSL.Count-1 do
    begin
      RecordSL.CommaText := DataSL[RecordIndex];
      Table.Open;
      Table.Append;
      For FieldIndex := 0 to MinIntValue([RecordSL.Count, Table.FieldCount]) -1 do
      begin
        //remove quotes
        RecordSL[FieldIndex] := Replace(RecordSL[FieldIndex], '"', '');
        RecordSL[FieldIndex] := Replace(RecordSL[FieldIndex], '''' , '');
        if Table.FieldDefs.Items[FieldIndex].DataType =  ftCurrency  then
           RecordSL[FieldIndex] := Replace(RecordSL[FieldIndex], ThousandSeparator , '');
        Table.Fields[FieldIndex].AsString := RecordSL[FieldIndex];
      end;
      Table.Post;
    end;

  finally
    DataSL.Free;
    RecordSL.Free;
  end;

end;

procedure CreateView(FileName, ViewSQL : String);
//creates a view
begin
  With TStringList.Create do
  begin
    try
      Text := ViewSQL;
      SaveToFile(FileName);
    finally
      Free;
    end;
  end;
end;

procedure AddMasterPassword(Table: TTable; pswd: string);
//AddMasterPassword(Table1, 'MyNewPassword')
const
  RESTRUCTURE_TRUE = WordBool(1);

var
  TblDesc: CRTblDesc;
  hDb: hDBIDb;

begin
  { Make sure that the table is opened and is exclusive }
  if (Table.Active = False) or (Table.Exclusive = False) then
    raise EDatabaseError.Create('Table must be opened in exclusive mode to add passwords');
  { Initialize the table descriptor }
  FillChar(TblDesc, SizeOf(CRTblDesc), 0);

  with TblDesc do
  begin
    { Place the table name in descriptor }
    StrPCopy(szTblName, Table.TableName);
    { Place the table type in descriptor }
    StrCopy(szTblType, szPARADOX);
    { Master Password, Password }
    StrPCopy(szPassword, pswd);
    { Set bProtected to True }
    bProtected := RESTRUCTURE_TRUE;
  end;

  { Get the database handle from the cursor handle }
  Check(DbiGetObjFromObj(hDBIObj(Table.Handle), objDATABASE, hDBIObj(hDb)));
  { Close the table }
  Table.Close;
  { Add the master password to the Paradox table }
  Check(DbiDoRestructure(hDb, 1, @TblDesc, nil, nil, nil, FALSE));
  { Add the new password to the session }
  Session.AddPassword(pswd);
  { Re-Open the table }
  Table.Open;
end;

procedure AddAuxPassword(Table: TTable; mstrpswd, pswd: string; rights: PRVType);
//AddAuxPassword(Table1, 'MyMstrPswd', 'MyNewAuxPswd', pvrINSDEL)
//In order to add an auxilary password, the master password MUST also be added
//at the same time; even if the master password is already on the table!
//A privelage type of prvINSDEL gives full rights without the ability to
//restructure or delete.

const
  RESTRUCTURE_TRUE = WordBool(1);

var
  { Specific information about the table structure, indexes, etc. }
  TblDesc: CRTblDesc;
  { Security descriptor }
  SDesc: SECDesc;
  { Uses as a handle to the database }
  hDb: hDBIDb;
  { crAdd }
  crType: CROpType;
  W: word;

begin
  { Add the master password to the session }
  Session.AddPassword(mstrpswd);
  { Make sure that the table is opened and is exclusive }
  if (Table.Active = False) or (Table.Exclusive = False) then
    raise EDatabaseError.Create('Table must be opened in exclusive mode to add passwords');
  { Initialize the table and security descriptor }
  FillChar(TblDesc, SizeOf(CRTblDesc), #0);
  FillChar(SDesc, SizeOf(SDesc), #0);
  crType := crAdd;
  { Table privileges }
  SDesc.eprvTable := rights;
  { Family rights }
  SDesc.iFamRights := NoFamRights;
  { Aux Password name }
  StrPCopy(SDesc.szPassword, pswd);
  { Set field rights to full }
  for W := 1 to Table.FieldCount do
    SDesc.aprvFld[W - 1] := prvFULL;

  { Place the table name in descriptor }
  StrPCopy(TblDesc.szTblName, Table.TableName);
  { Place the table type in descriptor }
  StrCopy(TblDesc.szTblType, szPARADOX);
  { Number of security definitions }
  TblDesc.iSecRecCount := 1;
  { This should be crAdd }
  TblDesc.pecrSecOp := @crType;
  { Attach the security descriptor to the Table Descriptor }
  TblDesc.psecDesc := @SDesc;
  { Copy in the master password }
  StrPCopy(TblDesc.szPassword, mstrpswd);
  { Set bProtected to True }
  TblDesc.bProtected := RESTRUCTURE_TRUE;

  { Get the database handle from the cursor handle }
  Check(DbiGetObjFromObj(hDBIObj(Table.Handle), objDATABASE, hDBIObj(hDb)));
  { Close the table }
  Table.Close;
  { Add the auxilary password to the Paradox table }
  Check(DbiDoRestructure(hDb, 1, @TblDesc, nil, nil, nil, FALSE));
  { Re-Open the table }
  Table.Open;
end;

procedure RemoveMasterPassword(Table: TTable);
//RemoveMasterPassword(Table1)
const
  RESTRUCTURE_FALSE = WordBool(0);

var
  TblDesc: CRTblDesc;
  hDb: hDBIDb;

begin
  { Make sure that the table is opened and is exclusive }
  if (Table.Active = False) or (Table.Exclusive = False) then
    raise EDatabaseError.Create('Table must be opened in exclusive mode to add passwords');
  { Initialize the table descriptor }
  FillChar(TblDesc, SizeOf(CRTblDesc), 0);

  with TblDesc do
  begin
    { Place the table name in descriptor }
    StrPCopy(szTblName, Table.TableName);
    { Place the table type in descriptor }
    StrCopy(szTblType, szPARADOX);
    { Set bProtected to False }
    bProtected := RESTRUCTURE_FALSE;
  end;

  { Get the database handle from the cursor handle }
  Check(DbiGetObjFromObj(hDBIObj(Table.Handle), objDATABASE, hDBIObj(hDb)));
  { Close the table }
  Table.Close;
  { Add the master password to the Paradox table }
  Check(DbiDoRestructure(hDb, 1, @TblDesc, nil, nil, nil, FALSE));
  { Re-Open the table }
  Table.Open;
end;


procedure RemoveAuxPassword(Table: TTable; mstrpswd, pswd: string);
//RemoveAuxPassword(Table1, 'MstrPswd', 'AuxToRemove')

  function GetSecNoFromName(hDb: hDBIDb; TblName, pswd: string): word;
  var
    hCur: hDBICur;
    Sec: SECDesc;

  begin
    Result := 0;
    Check(DbiOpenSecurityList(hDb, PChar(TblName), nil, hCur));
    try
      Check(DbiSetToBegin(hCur));
      while DbiGetNextRecord(hCur, dbiNOLOCK, @Sec, nil) = DBIERR_NONE do
      begin
        if CompareText(Sec.szPassword, pswd) = 0 then
        begin
          { Set the Security Number to the result }
          Result := Sec.iSecNum;
          break;
        end;
      end;
    finally
      Check(DbiCloseCursor(hCur));
    end;
  end;

const
  RESTRUCTURE_TRUE = WordBool(1);

var
  { Specific information about the table structure, indexes, etc. }
  TblDesc: CRTblDesc;
  { Security descriptor }
  SDesc: SECDesc;
  { Uses as a handle to the database }
  hDb: hDBIDb;
  { crAdd }
  crType: CROpType;

begin
  { Make sure that the table is opened and is exclusive }
  if (Table.Active = False) or (Table.Exclusive = False) then
    raise EDatabaseError.Create('Table must be opened in exclusive mode to add passwords');
  { Initialize the table and security descriptor }
  FillChar(TblDesc, SizeOf(CRTblDesc), 0);
  FillChar(SDesc, SizeOf(SECDesc), 0);
  crType := crDrop;
  { Descriptor number that specifies the password to remove }
  SDesc.iSecNum := GetSecNoFromName(Table.DbHandle, Table.TableName, pswd);
  if SDesc.iSecNum = 0 then
  begin
    ShowMessage('Could not find auxilary password.');
    Exit;
  end;

  with TblDesc do
  begin
    { Place the table name in descriptor }
    StrPCopy(szTblName, Table.TableName);
    { Place the table type in descriptor }
    StrCopy(szTblType, szPARADOX);
    { Number of security definitions }
    iSecRecCount := 1;
    { This should be crDrop }
    pecrSecOp := @crType;
    { Attach the security descriptor to the Table Descriptor }
    psecDesc := @SDesc;
    { Copy in the master password }
    StrPCopy(szPassword, mstrpswd);
    { Set bProtected to True }
    bProtected := RESTRUCTURE_TRUE;
  end;

  { Get the database handle from the cursor handle }
  Check(DbiGetObjFromObj(hDBIObj(Table.Handle), objDATABASE, hDBIObj(hDb)));
  { Close the table }
  Table.Close;
  { Remove the auxilary password to the Paradox table }
  Check(DbiDoRestructure(hDb, 1, @TblDesc, nil, nil, nil, FALSE));
  { Re-Open the table }
  Table.Open;
end;

procedure RestructureTable(Table: TTable; Option, OptData: string);
//RestructureTable(Table1, 'LEVEL', '7') Change table level to 7
//RestructureTable(Table1, 'BLOCK SIZE', '4096') Change table block size to 4096
//This function calls DbiDoRestructure with the Option to change and the OptData
//which is the new value of the option. Since a database handle is needed and the
//table cannot be opened when restructuring is done, a new database handle is
//created and set to the directory where the table resides.
var
  hDb: hDBIDb;
  TblDesc: CRTblDesc;
  Props: CurProps;
  pFDesc: FLDDesc;

begin
  // If the table is not opened, raise an error.  Need the table open to get
  //   the table directory.
  if Table.Active <> True then
    raise EDatabaseError.Create('Table is not opened');
  // If the table is not opened exclusively, raise an error.  DbiDoRestructure
  //   will need exclusive access to the table.
  if Table.Exclusive <> True then
    raise EDatabaseError.Create('Table must be opened exclusively');
  // Get the table properties.
  Check(DbiGetCursorProps(Table.Handle, Props));
  // If the table is not a Paradox type, raise an error.  These options only
  //   work with Paradox tables.
  if StrComp(Props.szTableType, szPARADOX) <> 0 then
    raise EDatabaseError.Create('Table must be of type PARADOX');
  // Get the database handle.
  Check(DbiGetObjFromObj(hDBIObj(Table.Handle), objDATABASE, hDBIObj(hDb)));
  // Close the table.
  Table.Close;
  // Setup the Table descriptor for DbiDoRestructure
  FillChar(TblDesc, SizeOf(TblDesc), #0);
  StrPCopy(TblDesc.szTblName, Table.Tablename);
  StrCopy(TblDesc.szTblType, szParadox);
  // The optional parameters are passed in through the FLDDesc structure.
  //   It is possible to change many Options at one time by using a pointer
  //   to a FLDDesc (pFLDDesc) and allocating memory for the structure.
  pFDesc.iOffset := 0;
  pFDesc.iLen := Length(OptData) + 1;
  StrPCopy(pFDesc.szName, Option);
  // The changed values of the optional parameters are in a contiguous memory
  //   space.  Sonce only one parameter is being used, the OptData variable
  //   can be used as a contiguous memory space.
  TblDesc.iOptParams := 1;  // Only one optional parameter
  TblDesc.pFldOptParams := @pFDesc;
  TblDesc.pOptData := @OptData[1];
  try
    // Restructure the table with the new parameter.
    Check(DbiDoRestructure(hDb, 1, @TblDesc, nil, nil, nil, False));
  finally
    Table.Open;
  end;
end;

procedure AddRI(Master, Detail: TTable; RIName: string; ModOp, DelOp: RINTQual);
//AddRI(Table2, Table3, 'CustomerRI', rintRESTRICT, rintRESTRICT);
//This function calls DbiDoRestructure passing it one RINTDesc descriptor to add
//referential integrity. There are some conditions prior to using this function that need to be met:
//The tables must have a primary index on the master table and a primary or secondary
//index on the detail table.
//The table must be opened exclusively on the index that the RI is going to be placed on.
//The fields that are going to be joined by RI must be of the same type and size.
var
  MasterProps, DetailProps: CURProps;
  hDb: hDBIDb;
  TableDesc: CRTblDesc;
  Op: CROpType;
  RInt: RINTDesc;
  MIndex, DIndex: IDXDesc;
  MNo, DNo: Word;

begin
  if Master.Active = False then
    raise EDatabaseError.Create('Master table: ' + Master.TableName +
                                ' is not opened');
  if Detail.Active = False then
    raise EDatabaseError.Create('Detail table: ' + Detail.TableName +
                                ' is not opened');

  if Master.Exclusive = False then
    raise EDatabaseError.Create('Table: ' + Master.TableName +
                                ' must be opened exclusively');
  if Detail.Exclusive = False then
    raise EDatabaseError.Create('Table: ' + Detail.TableName +
                                ' must be opened exclusively');

  // Make sure the tables are opened with an index and get their descriptors...
  FillChar(DIndex, sizeof(DIndex), 0);
  FillChar(MIndex, sizeof(MIndex), 0);
  Check(DbiGetIndexDesc(Detail.Handle, 0, DIndex));
  Check(DbiGetIndexDesc(Master.Handle, 0, MIndex));

  // Get the table properties to determine table type...
  Check(DbiGetCursorProps(Master.Handle, MasterProps));
  Check(DbiGetCursorProps(Detail.Handle, DetailProps));

  // If the table is not a Paradox table, raise an error...
  if (MasterProps.szTableType <> szPARADOX) and
     (MasterProps.szTableType <> szDBASE) then
     raise EDatabaseError.Create('Master table: ' + Master.TableName +
                                 ' must be a Paradox or dBASE table type');
  if (DetailProps.szTableType <> szPARADOX) and
     (DetailProps.szTableType <> szDBASE) then
     raise EDatabaseError.Create('Detail table: ' + Detail.TableName +
                                 ' must be a Paradox or dBASE table type');
  if MasterProps.szTableType <> DetailProps.szTableType then
     raise EDatabaseError.Create('Master and Detail tables must be of same type');

  // Blank out the structures...
  FillChar(TableDesc, sizeof(TableDesc), 0);
  FillChar(RInt, sizeof(RInt), 0);
  //  Get the database handle from the table's cursor handle...
  Check(DbiGetObjFromObj(hDBIObj(Master.Handle), objDATABASE, hDBIObj(hDb)));
  // Put the table name in the table descriptor...
  StrPCopy(TableDesc.szTblName, Detail.TableName);
  // Put the table type in the table descriptor...
  TableDesc.szTblType := MasterProps.szTableType;
  // Set the operation type...
  Op := crADD;
  TableDesc.pecrRintOp := @Op;
  // Set the amount of new RI descriptors...
  TableDesc.iRintCount := 1;
  // Connect the table descriptor to the RI descriptor...
  TableDesc.printDesc := @RInt;
  // Setup the RI descriptor...
  // Put in the name of the RI...
  StrPCopy(RInt.szRintName, RIName);
  // Do the restructure on the dependent (detail) table...
  RInt.eType := rintDEPENDENT;
  // Add the master table name...
  StrPCopy(RInt.szTblName, Master.TableName);
  // Modify operations will be restricted (this can be changed to rintCASCADE)...
  RInt.eModOp := ModOp;
  // Delete operations will be restricted (NOTE: rintCASCADE will not work)...
  RInt.eDelOp := DelOp;
  // Only one field in link...
  RInt.iFldCount := 1;
  // If the tables are Paradox, then put the associated field numbers in the descriptor...
  if (MasterProps.szTableType = szPARADOX) then
  begin
    //
    if RInt.eDelOp = rintCASCADE then
      raise EDatabaseError.Create('Cannot use cascading delete RI with Paradox tables');
    // Put the detail field index in the array...
    RInt.aiThisTabFld := DIndex.aiKeyFld;
    // Put the master field index in the array...
    RInt.aiOthTabFld := MIndex.aiKeyFld;
  end;

  // If the tables are dBASE, then put the sequence number in the descriptor...
  if MasterProps.szTableType = szDBASE then
  begin
    Check(DbiGetIndexSeqNo(Master.Handle, MIndex.szName, MIndex.szTagName, 0, MNo));
    Check(DbiGetIndexSeqNo(Detail.Handle, DIndex.szName, DIndex.szTagName, 0, DNo));
    // Put the detail field index in the array...
    RInt.aiThisTabFld[0] := DNo;
    // Put the master field index in the array...
    RInt.aiOthTabFld[0] := MNo;
  end;

  try
    Master.Close;
    Detail.Close;
    Check(DbiDoRestructure(hDb, 1, @TableDesc, nil, nil, nil, FALSE));
  finally
    Master.Open;
    Detail.Open;
  end;
end;

procedure AddField(Table: TTable; NewField: ChangeRec);
//NOTE: You must fill in all options in the ChangeRec with 0 or '' if the option
//is not used in the restructure. FillChar can be used to do this:
//Fillchar(MyChangeRec, sizeof(MyChangeRec), 0);
//This example uses the following input:
//AddField(Table1, MyChangeRec);
//ChangeRec is defind as follows:
//ChangeRec = packed record
//    szName: DBINAME;
//    iType: word;
//    iSubType: word;
//    iLength: word;
//    iPrecision: byte;
//  end;

var
  Props: CURProps;
  hDb: hDBIDb;
  TableDesc: CRTblDesc;
  pFlds: pFLDDesc;
  pOp: pCROpType;
  B: byte;

begin
  // Make sure the table is open exclusively so we can get the db handle...
  if Table.Active = False then
    raise EDatabaseError.Create('Table must be opened to restructure');
  if Table.Exclusive = False then
    raise EDatabaseError.Create('Table must be opened exclusively to restructure');

  // Get the table properties to determine table type...
  Check(DbiSetProp(hDBIObj(Table.Handle), curxltMODE, integer(xltNONE)));
  Check(DbiGetCursorProps(Table.Handle, Props));
  pFlds := AllocMem((Table.FieldCount + 1) * sizeof(FLDDesc));
  FillChar(pFlds^, (Table.FieldCount + 1) * sizeof(FLDDesc), 0);
  Check(DbiGetFieldDescs(Table.handle, pFlds));

  for B := 1 to Table.FieldCount do begin
    pFlds^.iFldNum := B;
    Inc(pFlds, 1);
  end;
  try
    StrCopy(pFlds^.szName, NewField.szName);
    pFlds^.iFldType := NewField.iType;
    pFlds^.iSubType := NewField.iSubType;
    pFlds^.iUnits1  := NewField.iLength;
    pFlds^.iUnits2  := NewField.iPrecision;
    pFlds^.iFldNum  := Table.FieldCount + 1;
  finally
    Dec(pFlds, Table.FieldCount);
  end;

  pOp := AllocMem((Table.FieldCount + 1) * sizeof(CROpType));
  Inc(pOp, Table.FieldCount);
  pOp^ := crADD;
  Dec(pOp, Table.FieldCount);

  // Blank out the structure...
  FillChar(TableDesc, sizeof(TableDesc), 0);
  //  Get the database handle from the table's cursor handle...
  Check(DbiGetObjFromObj(hDBIObj(Table.Handle), objDATABASE, hDBIObj(hDb)));
  // Put the table name in the table descriptor...
  StrPCopy(TableDesc.szTblName, Table.TableName);
  // Put the table type in the table descriptor...
  StrPCopy(TableDesc.szTblType, Props.szTableType);
  // Close the table so the restructure can complete...
  TableDesc.iFldCount := Table.FieldCount + 1;
  Tabledesc.pfldDesc := pFlds;
  TableDesc.pecrFldOp := pOp;
  Table.Close;
  // Call DbiDoRestructure...
  try
    Check(DbiDoRestructure(hDb, 1, @TableDesc, nil, nil, nil, FALSE));
  finally
    FreeMem(pFlds);
    FreeMem(pOp);
    Table.Open;
  end;
end;

procedure RemoveRI(Detail: TTable; SeqNo: word; RIName: PChar);
//RemoveRI(DetailRITable, 0, 'RIName'); OR
//RemoveRI(DetailRITable, 1, nil);
var
  Props: CURProps;
  B: byte;
  pRI: pRINTDesc;
  pOP: pcrOpType;
  TblDesc: CRTblDesc;
  hDb: hDBIDb;
  RIFound: Boolean;

begin
//  pRI := nil; pOP := nil;
  if (SeqNo = 0) and (RIName = nil) then
    raise EDatabaseError.Create('SeqNo must be positive or a RI name must be specified');

  if (SeqNo <> 0) and (RIName <> nil) then
    raise EDatabaseError.Create('You must either use the SeqNo or RIName to specify the constraint; not both');

  { Make sure that the table is opened and is exclusive... }
  if (Detail.Active = False) or (Detail.Exclusive = False) then
    raise EDatabaseError.Create('Table must be opened and in exclusive mode');

  Check(DbiGetCursorProps(Detail.Handle, Props));
  if Props.iRefIntChecks < 1 then
    raise EDatabaseError.Create('There are no RI constraints on this table');

  { Make sure the table is either Paradox or dBASE... }
  if (Props.szTableType <> szPARADOX) and (Props.szTableType <> szDBASE) then
    raise EDatabaseError.Create('Field altering can only occur on Paradox' +
                ' or dBASE tables');

  pRI := AllocMem(Props.iRefIntChecks * sizeof(RINTDesc));
  pOp := AllocMem(Props.iRefIntChecks * sizeof(CROpType));
  try
    { Fill the RInt descriptor will all RI information... }
    for B := 1 to Props.iRefIntChecks do
    begin
      Check(DbiGetRIntDesc(Detail.Handle, B, pRI));
      { If the SeqNo was given use it to determine the constraint to remove... }
      if SeqNo > 0 then
      begin
        if pRI^.iRintNum = SeqNo then
          pOp^ := crDROP;
      end;
      { If the name was given use it to determine the constraint to remove... }
      if RIName <> nil then
      begin
        if StrComp(pRI^.szRintName, RIName) = 0 then
          pOp^ := crDROP;
      end;
      Inc(pOP);
      Inc(pRI);
    end;
    Dec(pRI, Props.iRefIntChecks);
    Dec(pOP, Props.iRefIntChecks);

    { Make sure the constraint was found... }
    RIFound := False;
    for B := 0 to Props.iRefIntChecks - 1 do
    begin
      Inc(pOP, B);
      if pOP^ <> crNOOP then
        RIFound := True;
      Dec(pOP, B);
    end;
    if RIFound = False then
      raise EDatabaseError.Create('Constraint was not found');

    { Get the database handle... }
    Check(DbiGetObjFromObj(hDBIObj(Detail.Handle), objDATABASE, hDBIObj(hDb)));
    { Close the table }
    Detail.Close;
    { Setup the Table descriptor for DbiDoRestructure }
    FillChar(TblDesc, SizeOf(TblDesc), #0);
    StrPCopy(TblDesc.szTblName, Detail.Tablename);
    StrCopy(TblDesc.szTblType, Props.szTableType);
    TblDesc.iRintCount := Props.iRefIntchecks;
    TblDesc.printDesc := pRI;
    TblDesc.pecrRintOp := pOP;
    { Restructure the table }
    Check(DbiDoRestructure(hDb, 1, @TblDesc, nil, nil, nil, FALSE));
  finally
    if pRI <> nil then
      FreeMem(pRI);
    if pOP <> nil then
      FreeMem(pOP);
  end;
end;


procedure ChangePIdx(Table: TTable; Fields: word);
//This input will take an existing primary index and change it to apply to the
//first 2 fields in the table.
//NOTE: If you define an index that is more restrictive on the table's data
//(usually by removing fields from the index) all records that violate the new
//primary index will be removed from the table. In other words data will be lost!
var
  Props: CURProps;
  hDb: hDBIDb;
  TableDesc: CRTblDesc;
  Index: IDXDesc;
  OP: CROpType;
  W: word;

begin
  // Make sure that at least one field is specified...
  if Fields < 1 then
    raise EDatabaseError.Create('Field count must be greater than 0');
  // Make sure the table is open exclusively so we can get the db handle...
  if Table.Active = False then
    raise EDatabaseError.Create('Table must be opened to change the index');
  if Table.Exclusive = False then
    raise EDatabaseError.Create('Table must be opened exclusively to change the index');

  // Get the table properties to determine table type...
  Check(DbiGetCursorProps(Table.Handle, Props));
  // Make sure that enough fields exist to create the index...
  if Props.iFields < Fields then
    raise EDatabaseError.Create('Cannot specify more fields in an index than existing fields');
  // If the table is a Paradox table, you must call DbiDoRestructure...
  if (Props.szTableType <> szPARADOX) and (Props.szTableType <> szDBASE) then
    raise EDatabaseError.Create('Table must be of type Paradox or dBASE 7');


  // Blank out the structure...
  FillChar(TableDesc, sizeof(TableDesc), 0);
  //  Get the database handle from the table's cursor handle...
  Check(DbiGetObjFromObj(hDBIObj(Table.Handle), objDATABASE, hDBIObj(hDb)));
  // Put the table name in the table descriptor...
  StrPCopy(TableDesc.szTblName, Table.TableName);
  // Put the table type in the table descriptor...
  StrPCopy(TableDesc.szTblType, Props.szTableType);
  // Fill in index descriptor...
  FillChar(Index, sizeof(IDXDesc), 0);
  Index.bPrimary:= TRUE;
  Index.bUnique:= TRUE;
  Index.bMaintained:= TRUE;
  Index.iFldsInKey:= Fields;
  for W := 1 to Fields do
    Index.aiKeyFld[W - 1]:= W;
  // Modify an existing index only...
  OP := crMODIFY;
  // Only one index to change...
  TableDesc.iIdxCount := 1;
  TableDesc.pecrIdxOp := @OP;
  TableDesc.pidxDesc := @Index;
  // Close the table so the restructure can complete...
  Table.Close;
  try
    // Call DbiDoRestructure...
    Check(DbiDoRestructure(hDb, 1, @TableDesc, nil, nil, nil, FALSE));
  finally
    Table.Open;
  end;
end;


procedure AddLookupTable(Table, LookupTable: TTable; LookupField: TField);
//AddLookupTable(Table3, Table4, Table3.FieldByName('Lookup'));
var
  hDb: hDbiDb;
  TblDesc: CRTblDesc;
  VChk: VChkDesc;
  OpType: CROpType;

begin
  if Table.Exclusive = False then
    raise EDatabaseError.Create('Table must be opened exclusively to add lookup table');

  FillChar(VChk, sizeof(VCHKDesc), 0);
  // put the field number in the descriptor..
  VCHK.iFldNum := LookupField.Index + 1;
  // lookup type (this is the paradox standard)...
  VCHK.elkupType := lkupHELP;
  // copy the lookup table name into the descriptor...
  StrPCopy(VCHK.szLkupTblName, LookupTable.TableName);
  OpType := crADD;

  FillChar(TblDesc, sizeof(TblDesc), 0);
  // Place the add option into the table descriptor...
  TblDesc.pecrValChkOp := @OpType;
  // One validity check to add..
  TblDesc.iValChkCount := 1;
  TblDesc.pvchkDesc := @VCHK;
  StrPCopy(TblDesc.szTblName, Table.TableName);
  StrCopy(TblDesc.szTblType, szParadox);
  try
    // Get the database handle from the TTable's cursor handle...
    Check(DbiGetObjFromObj(hDBIObj(Table.Handle), objDATABASE, hDBIObj(hDb)));
    // Close both tables...
    Table.Close;
    LookupTable.Close;
    // Restructure the table...
    Check(DbiDoRestructure(hDb, 1, @TblDesc, nil, nil, nil, False));
  finally
    LookupTable.Open;
    Table.Open;
  end;
end;

procedure AddValidityCheck(Tbl: TTable; Field: TField; MinVal, MaxVal,
           DefVal: pLongint; Required: Bool);
//The field must be a longint, and the TTable must be open.
//AddValidityCheck(Table4, Table4.Fields[0], @Min, @Max, nil, True)

var
  hDb: hDbiDb;
  TblDesc: CRTblDesc;
  VChk: pVChkDesc;
  Dir: String;
  NumVChks: Word;
  OpType: CROpType;

begin
  NumVChks := 0;
  SetLength(Dir, dbiMaxNameLen + 1);
  Check(DbiGetDirectory(Tbl.DBHandle, False, PChar(Dir)));
  SetLength(Dir, StrLen(PChar(Dir)));
  VChk := AllocMem(sizeof(VChkDesc));
  try
    FillChar(TblDesc, sizeof(CRTblDesc), #0);

    VChk.iFldNum := Field.Index + 1;
    Tbl.DisableControls;
    Tbl.Close;
    Check(DbiOpenDatabase(nil, nil, dbiReadWrite, dbiOpenExcl, 
               nil, 0, nil, nil, hDb));
    Check(DbiSetDirectory(hDb, PChar(Dir)));
    with VChk^ do
    begin
      bRequired := Required;
      if MinVal <> nil then
      begin
        Inc(NumVChks);
        bHasMinVal := True;
        move(MinVal^, aMinVal, sizeof(MinVal^));
      end
      else
        bHasMinVal := False;
      if MaxVal <> nil then

      begin
        Inc(NumVChks);
        bHasMaxVal := True;
        move(MaxVal^, aMaxVal, sizeof(MaxVal^));
      end
      else
        bHasMaxVal := False;
      if DefVal <> nil then
      begin
        Inc(NumVChks);
        bHasDefVal := True;
        move(DefVal^, aDefVal, sizeof(DefVal^));
      end
      else
        bHasDefVal := False;

    end;
    TblDesc.iValChkCount := NumVChks;
    TblDesc.pVChkDesc := VChk;
    OpType := crADD;
    TblDesc.pecrValChkOp := @OpType;

    StrPCopy(TblDesc.szTblName, Tbl.TableName);
    StrCopy(TblDesc.szTblType, szParadox);
    Check(DbiDoRestructure(hDb, 1, @TblDesc, nil, nil, nil, False));
  finally
    Check(DbiCloseDatabase(hDb));
    FreeMem(VChk, sizeof(VChkDesc));
    Tbl.EnableControls;
    Tbl.Open;
  end;
end;

procedure FitColumnWidths(DBGrid : TDBGrid);
//fits column widths in a db grid
var
  ColIndex      : Integer;
  MaxCellWidths : Array [0..100] of Integer;
  SavedBookmark : TBookMarkStr;
begin
  SavedBookmark := DBGrid.DataSource.DataSet.Bookmark;

  DBGrid.Visible := False;
  try
    //reset col widths
    For ColIndex := 0 to DBGrid.FieldCount -1 do
    begin
      MaxCellWidths[ColIndex] := 0;
    end;

    //go through all rows
    DBGrid.DataSource.DataSet.First;
    While not DBGrid.DataSource.DataSet.EOF do
    begin
      For ColIndex := 0 to DBGrid.FieldCount -1 do
      begin
        MaxCellWidths[ColIndex] := MaxIntValue(
          [MaxCellWidths[ColIndex],
          10+ DBGrid.Canvas.TextWidth(DBGrid.DataSource.DataSet.Fields[ColIndex].AsString)] //this cell
        );
      end;
      DBGrid.DataSource.DataSet.Next;
    end;  //while not EOF

    //apply max cell widths
    For ColIndex := 0 to DBGrid.FieldCount -1 do
    begin
      If not (DBGrid.DataSource.DataSet.Fields[ColIndex] is TMemoField) then
        DBGrid.Columns[ColIndex].Width := MaxCellWidths[ColIndex];
    end;
  DBGrid.DataSource.DataSet.Bookmark := SAvedBookmark ;
  finally
    DBGrid.Visible := True;
  end;
end;

//post txn and wait for record to be written until timeout
function WaitForRecord(TxnLog : ITransactionLog;Info : String; TimeOut : Integer):Boolean;
const
  SecondsInDay : Integer = 60*60*24;
var
  StartTime : TDateTime;
  CountTime : TDateTime;
  GUID : TGUID;
begin
  result := False;
  StartTime := Now;
  CountTime := Now;
  CoCreateGUID(GUID);
  TxnLog.WriteTransaction('*WaitRecord',0,0,0,0,0,GUIDToString(GUID),Info,'','');
  While ((CountTime-StartTime) * SecondsInDay < TimeOut)
  and (Result = False) do
  begin
    Sleep(1000);                                                               
    If QueryToPackText('select description from txnlog where rectype= ''WaitRecord'' and description = '''
        + GUIDToString(GUID) + '''') = #2#1+GUIDToString(GUID) then
      Result := True;
    CountTime := Now;
  end;
  If not Result then
    RaiseGUIDError('{AF71445C-FA0B-4CE6-BF1C-08383E6C80B3}', 'WaitForRecord ' + Info +' Timeout' + IntToStr(TimeOut) + ' secs');
end;




end.
