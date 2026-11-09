{$A+,B-,C-,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y-,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}

// This unit contains all the procedures needed to alter Paradox version level,
//      block size, and strict integrity constraints.

unit restruct;

interface

uses
  DBTables, SYSUtils;

// Alter table's version level
// Input Example: AlterVersion(Table1, 7);
procedure AlterVersion(Table: TTable; Version: Byte);

// Alter table's block size
// Input Example: AlterBlockSize(Table1, 4096);
procedure AlterBlockSize(Table: TTable; BlockSize: Integer);

// Alter table's strict integrity constraint
// Input Example: AlterStrictIntegrity(Table1, TRUE);
procedure AlterStrictIntegrity(Table: TTable; SI: Boolean);

implementation

uses
  DB, BDE;

const
  // Constants used by EDatabaseError exceptions that are raised during
  //   abnormal termination
  notOpenError =
    'Table must be open to complete restructure operation';
  notExclusiveError =
    'Table must be opened exclusively to complete restructure operation';
  mustBeParadoxTable =
    'Table is not a Paradox table type';


// Calls DbiDoRestructure with the Option to change and the OptData which is
//   the new value of the option.
// Since a database handle is needed and the table cannot be opened when
//   restructuring is done, a new database handle is created and set to the
//   directory where the table resides.
procedure RestructureTable(Table: TTable; Option, OptData: string);
var
  hDb: hDBIDb;
  TblDesc: CRTblDesc;
  Props: CurProps;
  pFDesc: FLDDesc;

begin
  // If the table is not opened, raise an error.  Need the table open to get
  //   the table directory.
  if Table.Active <> True then
    raise EDatabaseError.Create(notOpenError);
  // If the table is not opened exclusively, raise an error.  DbiDoRestructure
  //   will need exclusive access to the table.
  if Table.Exclusive <> True then
    raise EDatabaseError.Create(notExclusiveError);
  // Get the table properties.
  Check(DbiGetCursorProps(Table.Handle, Props));
  // If the table is not a Paradox type, raise an error.  These options only
  //   work with Paradox tables.
  if StrComp(Props.szTableType, szPARADOX) <> 0 then
    raise EDatabaseError.Create(mustBeParadoxTable);
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

// Setup RestructureTable parameters for changing the table version
procedure AlterVersion(Table: TTable; Version: Byte);
var
  sVersion: string;

begin
  sVersion := IntToStr(Version);
  RestructureTable(Table, 'LEVEL', sVersion);
end;

// Setup RestructureTable parameters for changing the table block size
procedure AlterBlockSize(Table: TTable; BlockSize: Integer);
var
  sBlockSize: string;

begin
  sBlockSize := IntToStr(BlockSize);
  RestructureTable(Table, 'BLOCK SIZE', sBlockSize);
end;

// Setup RestructureTable parameters for changing the table strict integrity
procedure AlterStrictIntegrity(Table: TTable; SI: Boolean);
var
  sSI: string;

begin
  if SI = True then
    sSI := 'TRUE'
  else
    sSi := 'FALSE';

  RestructureTable(Table, 'STRICTINTEGRTY', sSI);
end;

end.
