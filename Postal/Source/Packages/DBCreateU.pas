{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y-,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
unit DBCreateU;

interface

uses StringUtil,Classes, DB, DBtables;

function CreateAllTables(Alias : String) : Boolean;
function FillAllTables(FromAlias, ToAlias : String) : Boolean;

function TransactScript           : String;
function TransactDetailScript     : String;
function TransactDetailNameScript : String;
function TxnlogScript             : String;
function PicturesScript           : String;
function MOIssueScript            : String;
function MOStatusScript           : String;
function MOStatusChangeScript     : String;
function MOPaidScript             : String;

type
  TDBType = (dbParadox, dbSQLServer, dbOracle);

const
  FieldTypeArray : array[ftUnknown..ftTypedBinary, dbParadox..dbOracle] of String =
    // Paradox      SQL Server  Oracle
    ( ('', '', ''), //ftUnknown
      ('CHAR',      'CHAR',               'CHAR'),            //ftString
      ('SMALLINT',  'SMALLINT',           'NUMBER'),          //ftSmallint
      ('INTEGER',   'INT',                'NUMBER'),          //ftInteger
      ('SMALLINT',  'SMALLINT',           'NUMBER'),          //ftWord
      ('BOOLEAN',   'BIT',                'CHAR(1)'),         //ftBoolean
      ('NUMERIC',   'FLOAT',              'NUMBER'),          //ftFloat
      ('MONEY',     'MONEY',              'NUMBER(18, 4)'),   //ftCurrency
      ('DECIMAL',   'NUMERIC',            'NUMBER'),          //ftBCD
      ('DATE',      'DATETIME',           'DATE'),            //ftDate
      ('TIME',      'DATETIME',           'DATE'),            //ftTime
      ('DATE',      'DATETIME',           'DATE'),            //ftDateTime
      ('BYTES',     'IMAGE',              'LONG RAW'),        //ftBytes
      ('BYTES',     'IMAGE',              'LONG RAW'),        //ftVarBytes
      ('AUTOINC',   'INT IDENTITY(1,1)',  'NUMBER'),          //ftAutoInc
      ('BLOB(0,2)', 'IMAGE',              'LONG RAW'),        //ftBlob
      ('BLOB(0,1)', 'NTEXT',              'VARCHAR2(4000)'),  //ftMemo
      ('BLOB(0,2)', 'IMAGE',              'LONG RAW'),        //ftGraphic
      ('BLOB(0,3)', 'IMAGE',              'LONG RAW'),        //ftFmtMemo
      ('BLOB(0,4)', 'IMAGE',              'LONG RAW'),        //ftParadoxOle
      ('BLOB(0,4)', 'IMAGE',              'LONG RAW'),        //ftDBaseOle
      ('BLOB(0,2)', 'IMAGE',              'LONG RAW')         //ftTypedBinary
    );

implementation

function FindCommonStrings(SetACommaText, SetBCommaText : String) : String;
//returns commatext of common strings in Set A and B
var
  SetASL, SetBSL , CommonSL: TStringList;
  AIndex : Integer;
begin
  SetASL := TStringList.Create;
  SetBSL := TStringList.Create;
  CommonSL := TStringList.Create;
  try
    SetASL.CommaTExt := SetACommaText;
    SetBSL.CommaTExt := SetBCommaText;
    For AIndex := 0 to SetASL.Count-1 do
    begin
      If SetBSL.IndexOf(SetASL[AIndex]) >= 0 then
        CommonSL.Add(SetASL[AIndex]);
    end;
    Result := CommonSL.CommaText;
  finally
    SetASL.Free;
    SetBSL.Free;
    CommonSL.Free;
  end;

end;

procedure ExecuteSQL(Alias, SQLText : String);
begin
With TQuery.Create(nil) do
try
  DatabaseName := Alias;
  SQL.Text := SQLText;
  ExecSQL;
finally
  Free;
end;
end;



function CreateAllTables(Alias : String) : Boolean;

begin
//  Result := False;
  ExecuteSQL(Alias,TransactScript);
  ExecuteSQL(Alias,TransactDetailScript);
  ExecuteSQL(Alias,TransactDetailNameScript);
  ExecuteSQL(Alias,TxnlogScript);
  ExecuteSQL(Alias,PicturesScript);
  ExecuteSQL(Alias,MOIssueScript);
  ExecuteSQL(Alias,MOStatusScript);
  ExecuteSQL(Alias,MOStatusChangeScript);
  ExecuteSQL(Alias,MOPaidScript);
  Result := True;
end;

function FillAllTables(FromAlias, ToAlias : String) : Boolean;
var
  FromTableNames, ToTableNames, FromTableFields, ToTableFields : TStringList;
  FromTable, ToTable : TTable;
begin
//  Result := False;
  FromTableNames  := TStringList.Create;
  ToTableNames    := TStringList.Create;
  FromTableFields   := TStringList.Create;
  ToTableFields   := TStringList.Create;
  ToTable         := TTable.Create(nil);
  FromTable       := TTable.Create(nil);

  try
    FromTable.DatabaseName  := FromAlias;
    ToTable.DatabaseName    := ToAlias;

    //get lists of tables in each alias
    Session.GetTableNames(FromAlias, '', False, False, FromTableNames);
    Session.GetTableNames(ToAlias, '', False, False, TOTableNames);

    //all destination tables
    While ToTableNames.Count > 0 do
    begin
      //remove dbo.
      If LeftOf(ToTableNames[0], 'dbo.') then
        ToTableNames[0] := DelimitedString(ToTableNames[0],'dbo.', True);

      //find a matching table name
      If FromTableNames.IndexOf(ToTableNames[0]) >= 0 then
      begin
        //get field names
        ToTable.TableName := ToTableNames[0];
        ToTable.GetFieldNames(ToTableFields);
        FromTable.TableName := ToTableNames[0];
        FromTable.GetFieldNames(FromTableFields);

        //fins the common fields in both tables
        ToTableFields.CommaText := FindCommonStrings(FromTableFields.CommaText, ToTableFields.CommaText);

        ExecuteSQL(FromAlias,
                      ' Insert into ":' + ToAlias + ':' + ToTable.TableName + '"'
                    + ' select ' + ToTableFields.CommaText
                    + ' from ":' + FromAlias + ':' + FromTable.TableName + '"');
      end;
      ToTableNames.Delete(0); //processed a destination table
    end;
  finally
    FromTableNames.Free;
    ToTableNames.Free;
    ToTableFields.Free;
    FromTableFields.Free;
    ToTable.Close;
    ToTable.Free;
    FromTable.Close;
    FromTable.Free;
  end;
  Result := True;
end;

function FieldClause(FieldName : String; FieldType : TFieldType; DBType : TDBType; Number, Precision : Integer) : String;
begin
  Result := FieldName + ' ' + FieldTypeArray[FieldType, DBType];
end;

function TransactScript           : String;
begin
  Result :=
      ' CREATE TABLE "TRANSACT"(                     '
    + ' "TRANSACTIONID"    INT          NOT NULL,    '
    + ' "RECORDID"         INT          NOT NULL,    '
    + ' "WSNUMBER"         INT          NOT NULL,    '
    + ' "OFFICECODE"       INT          NOT NULL,    '
    + ' "ACCOUNTINGPERIOD" INT,                      '
    + ' "TRANSACTIONTYPE"  CHAR(50),                 '
    + ' "DATETIME"         DATETIME,                 '
    + ' "TELLER"           CHAR(50),                 '
    + ' "PROGRAMID"        CHAR(50),                 '
    + ' "PROGRAMVERSION"   INT,                      '
    + ' "PLU"              INT,                      '
    + ' "ITEMPRICE"        MONEY,                    '
    + ' "ITEMQUANTITY"     INT,                      '
    + ' "ITEMVALUE"        MONEY,                    '
    + ' "DESCRIPTION"      CHAR(255),                '
    + ' "CRC"              INT,                      '
    + ' "PROCESSEDOK"      CHAR(1),                  '
    + ' CONSTRAINT "TRANSACT_PINDEX" PRIMARY KEY("TRANSACTIONID", "RECORDID", "WSNUMBER", "OFFICECODE")); ';
end;

function TransactDetailScript     : String;
begin
  Result :=
      'CREATE TABLE "TRANSACTDETAIL"(                           '
    + '  "TRANSACTIONID"    INT NOT NULL,                       '
    + '  "DETAILID"         INT NOT NULL,                       '
    + '  "DETAILVALUE"      CHAR(255),                          '
    + '  CONSTRAINT "TRANSACTDETAIL_PINDEX" PRIMARY KEY("TRANSACTIONID", "DETAILID"));';

end;

function TransactDetailNameScript : String;
begin
  Result :=
      'CREATE TABLE "TRANSACTDETAILNAME"(                   '
    + '  "DETAILID"         INT NOT NULL,             '
    + '  "DETAILNAME"       CHAR(100),                      '
    + '  CONSTRAINT "TRANSACTDETAILNAME_PINDEX" PRIMARY KEY("DETAILID"));  ';
end;

function TxnlogScript             : String;
begin
  Result :=
    'CREATE TABLE "TXNLOG"(                                                         '
  + '  "RECORDID"    INT        NOT NULL,                                        '
  + '  "WSNUMBER"    SMALLINT   NOT NULL,                                        '
  + '  "DATETIME"    DATETIME,                                                '
  + '  "RECTYPE"     CHAR(10),                                                '
  + '  "PERIOD"      INT,                                                '
  + '  "RECINDEX"    SMALLINT,                                                '
  + '  "OFFICE"      INT,                                                '
  + '  "TELLER"      CHAR(20),                                                '
  + '  "PLU"         INT,                                                '
  + '  "PROD"        CHAR(20),                                                '
  + '  "PRICE"       MONEY,                                                '
  + '  "QUANTITY"    INT,                                                '
  + '  "TXNVALUE"    MONEY,                                                '
  + '  "DESCRIPTION" VARCHAR(255),                                                '
  + '  "INFO"        TEXT,                                                '
  + '  "IDENT"       CHAR(15),                                                '
  + '  "DOMINFO"     TEXT,                                                '
  + '  CONSTRAINT "TXNLOG_PINDEX" PRIMARY KEY("RECORDID", "WSNUMBER"));                   '
  + '                                                                               '
  + 'CREATE INDEX "PERIODIDX" ON "TXNLOG"("PERIOD");                                '
  + '                                                                               '
  + 'CREATE INDEX "PERIODTELLERTYPEIDX" ON "TXNLOG"("PERIOD", "TELLER", "RECTYPE"); ';
end;

function PicturesScript           : String;
begin
  Result :=
      'CREATE TABLE "PICTURES"(                           '
    + ' "PICTURENAME" CHAR(255) NOT NULL,                 '
    + ' "PICTURE" IMAGE,                                  '
    + '  CONSTRAINT "PICTURES_PINDEX" PRIMARY KEY("PICTURENAME"));'
end;

function MOIssueScript            : String;
begin
  Result :=
    'CREATE TABLE "MOISSUE"(                                                                  '
  + '  "MOIDENTIFIER"        CHAR(20)       NOT NULL,                                          '
  + '  "MOISSUENUMBER"       INT            NOT NULL,                                          '
  + '  "MODATETIME"          DATETIME       NOT NULL,                                          '
  + '  "MOVALUE"             MONEY          NOT NULL,                                          '
  + '  "MOCOMMISSION"        MONEY,                                                  '
  + '  "MOTAX"               MONEY,                                                  '
  + '  "MOSSINDICATOR"       CHAR(20),                                                  '
  + '  "MOSSFEE"             MONEY,                                                  '
  + '  "MOISSUINGOFFICE"     INT            NOT NULL,                                          '
  + '  "MOISSUINGCLERK"      INT            NOT NULL,                                          '
  + '  "MOPAYINGOFFICE"      INT            NOT NULL,                                          '
  + '  "MOPAYBYDATETIME"     DATETIME          ,                                                  '
  + '  "MOSENDERSNAME"       VARCHAR(100)  ,                                                  '
  + '  "MOSENDERSADDRESS"    VARCHAR(255) ,                                                  '
  + '  "MORCONTACT1"         VARCHAR(40)  ,                                                  '
  + '  "MORCONTACT2"         VARCHAR(40)  ,                                                  '
  + '  "MORECIPIENTSNAME"    VARCHAR(100) ,                                                  '
  + '  "MORECIPIENTSADDRESS" VARCHAR(255) ,                                                  '
  + '  "MOINFORMATION"       VARCHAR(255) ,                                                  '
  + '  CONSTRAINT "MOISSUE_PINDEX" PRIMARY KEY("MOIDENTIFIER", "MOISSUENUMBER", "MODATETIME"));  ';
end;

function MOStatusScript           : String;
begin
  Result :=
    'CREATE TABLE "MOSTATUS"(                                                                  '
  + '  "MOIDENTIFIER"   CHAR(20)   NOT NULL,                                                    '
  + '  "MOISSUENUMBER" INT NOT NULL,                                                    '
  + '  "MODATETIME"     DATETIME       NOT NULL,                                                    '
  + '  "MOSTATUSVALUE"  INT NOT NULL,                                                    '
  + '  CONSTRAINT "MOSTATUS_PINDEX" PRIMARY KEY("MOIDENTIFIER", "MOISSUENUMBER", "MODATETIME"));  ';
end;

function MOStatusChangeScript     : String;
begin
  Result :=
    'CREATE TABLE "MOSTATUSCHANGE"(                                                                 '
  + '  "MOIDENTIFIER"  CHAR(20)     NOT NULL,                                                       '
  + '  "MOISSUENUMBER" INT          NOT NULL,                                                       '
  + '  "MODATETIME"    DATETIME     NOT NULL,                                                       '
  + '  "MOSTATUSFROM"  INT          NOT NULL,                                                       '
  + '  "MOSTATUSTO"    INT          NOT NULL,                                                       '
  + '  "MOREASON"      VARCHAR(255),                                                               '
  + '  CONSTRAINT "MOSTATUSCHANGE_PINDEX" PRIMARY KEY("MOIDENTIFIER", "MOISSUENUMBER", "MODATETIME")); ';
end;

function MOPaidScript             : String;
begin
  Result :=
      'CREATE TABLE "MOPAID"(                                                                 '
    + '  "MOIDENTIFIER"      CHAR(20)     NOT NULL,                                           '
    + '  "MOISSUENUMBER"     INT   NOT NULL,                                           '
    + '  "MODATETIME"        DATETIME         NOT NULL,                                           '
    + '  "MOCOMMISSION"      MONEY,                                                   '
    + '  "MOPAIDOFFICE"      INT   NOT NULL,                                           '
    + '  "MOPAIDCLERK"       INT   NOT NULL,                                           '
    + '  "MOINFORMATION"     VARCHAR(255),                                                   '
    + '  "MOFORCEPAYDETAILS" VARCHAR(255),                                                   '
    + '  CONSTRAINT "MOPAID_PINDEX" PRIMARY KEY("MOIDENTIFIER", "MOISSUENUMBER", "MODATETIME")); ';
end;

end.
