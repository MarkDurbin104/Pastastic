unit TxnTranslateU;

interface

uses
  ActiveX,ComObj,ComServ2, QueryMapU,DBUtil,
  Windows,SysUtils,Classes,Dialogs,FileCtrl,DB,DBTables,
  PackStrListU,GPCSGUID,GPCSBase_TLB,GPCSBaseAU,CRC32,StringUtil,GPCSErrorLine;

const                                           
   UndefinedSystemIdentifier = 'Undefined';
   BermudaSystemIdentifier   = 'BermudaTxnTrans.dll';
   BotswanaSystemIdentifier  = 'BotswanaTxnTrans.dll';
   PakistanSystemIdentifier  = 'PakistanTxnTrans.dll';
   SaudiSystemIdentifier     = 'SaudiTxnTrans.dll';
   TanzaniaSystemIdentifier  = 'TanzaniaTxnTrans.dll';
   UgandaSystemIdentifier    = 'UgandaTxnTrans.dll';
   VietnamSystemIdentifier   = 'VietnamTxnTrans.dll';

   FixedFieldNames = 'TransactionID,RecordID,WSNumber,OfficeCode,'       +
                          'AccountingPeriod,TransactionType,TxnDateTime,'        +
                          'Teller,ProgramID,ProgramVersion,PLU,ItemPrice,TxnIdent,'  +
                          'ItemQuantity,ItemValue,Description,CRC,ProcessedOK';
   SQLReservedWords =
      'ACTIVE,ADD,ALL,AFTER,ALTER,AND,ANY,AS,ASC,ASCENDING,AT,AUTO,AUTOINC,AVG,BASE_NAME,BEFORE,BEGIN'+
      'BETWEEN,BLOB,BOOLEAN,BOTH,BY,BYTES,CACHE,CAST,CHAR,CHARACTER,CHECK,CHECK_POINT_LENGTH,COLLATE'+
      'COLUMN,COMMIT,COMMITTED,COMPUTED,CONDITIONAL,CONSTRAINT,CONTAINING,COUNT,CREATE,CSTRING'+
      'CURRENT,CURSOR,DATABASE,DATE,DAY,DEBUG,DEC,DECIMAL,DECLARE,DEFAULT,DELETE,DESC,DESCENDING'+
      'DISTINCT,DO,DOMAIN,DOUBLE,DROP,ELSE,END,ENTRY_POINT,ESCAPE,EXCEPTION,EXECUTE,EXISTS,EXIT,EXTERNAL'+
      'EXTRACT,FILE,FILTER,FLOAT,FOR,FOREIGN,FROM,FULL,FUNCTION,GDSCODE,GENERATOR,GEN_ID,GRANT,GROUP'+
      'GROUP_COMMIT_WAIT_TIME,HAVING,HOUR,IF,IN,INT,INACTIVE,INDEX,INNER,INPUT_TYPE,INSERT,INTEGER,INTO,IS'+
      'ISOLATION,JOIN,KEY,LONG,LENGTH,LOGFILE,LOWER,LEADING,LEFT,LEVEL,LIKE,LOG_BUFFER_SIZE,MANUAL,MAX'+
      'MAXIMUM_SEGMENT,MERGE,MESSAGE,MIN,MINUTE,MODULE_NAME,MONEY,MONTH,NAMES,NATIONAL,NATURAL'+
      'NCHAR,NO,NOT,NULL,NUM_LOG_BUFFERS,NUMERIC,OF,ON,ONLY,OPTION,OR,ORDER,OUTER,OUTPUT_TYPE'+
      'OVERFLOW,PAGE_SIZE,PAGE,PAGES,PARAMETER,PASSWORD,PLAN,POSITION,POST_EVENT,PRECISION,PROCEDURE'+
      'PROTECTED,PRIMARY,PRIVILEGES,RAW_PARTITIONS,RDB$DB_KEY,READ,REAL,RECORD_VERSION,REFERENCES'+
      'RESERV,RESERVING,RETAIN,RETURNING_VALUES,RETURNS,REVOKE,RIGHT,ROLLBACK,SECOND,SEGMENT,SELECT'+
      'SET,SHARED,SHADOW,SCHEMA,SINGULAR,SIZE,SMALLINT,SNAPSHOT,SOME,SORT,SQLCODE,STABILITY,STARTING'+
      'STARTS,STATISTICS,SUB_TYPE,SUBSTRING,SUM,SUSPEND,TABLE,THEN,TIME,TIMESTAMP,TIMEZONE_HOUR'+
      'TIMEZONE_MINUTE,TO,TRAILING,TRANSACTION,TRIGGER,TRIM,UNCOMMITTED,UNION,UNIQUE,UPDATE,UPPER'+
      'USER,VALUE,VALUES,VARCHAR,VARIABLE,VARYING,VIEW,WAIT,WHEN,WHERE,WHILE,WITH,WORK,WRITE,YEAR';

   Const_FTransactionID     = 0 ;
   Const_FRecordID          = 1 ;
   Const_FWSNumber          = 2 ;
   Const_FOfficeCode        = 3 ;
   Const_FAccountingPeriod  = 4 ;
   Const_FTransactionType   = 5 ;
   Const_FDateTime          = 6 ;
   Const_FTeller            = 7 ;
   Const_FProgramID         = 8 ;
   Const_FProgramVersion    = 9 ;
   Const_FPLU               = 10;
   Const_FItemPrice         = 11;
   Const_ItemQuantity       = 12;
   Const_FItemValue         = 13;
   Const_FDescription       = 14;
   Const_FCRC               = 15;
   Const_OffSetHead         = 16;
   Const_ProcessedOK        = 16;
   Const_TxnIdent           = 17;

type
  TTxLimitData  = class(TObject)
     WSNumber:Integer;
     FromRID:Integer;
     ToRID:Integer;
  end;
  TFreeOnDestroyList = class(TList)
  public
     destructor Destroy; override;
  end;
  TOldTxnDomInfoLine = class(TObject)
   private
     FEnabled   :Boolean;
     FFocused   :Boolean;
     FDomType   :String;
     FName      :String;
     FPrompt    :String;
     FText      :String;
     FHint      :String;
     FError     :String;
     FValidation:String;
     FAddtional :String;
   public
     property Enabled   :Boolean read FEnabled    write FEnabled   ;
     property Focused   :Boolean read FFocused    write FFocused   ; 
     property DomType   :String  read FDomType    write FDomType   ;
     property Name      :String  read FName       write FName      ;
     property Prompt    :String  read FPrompt     write FPrompt    ;
     property Text      :String  read FText       write FText      ;
     property Hint      :String  read FHint       write FHint      ;
     property Error     :String  read FError      write FError     ;
     property Validation:String  read FValidation write FValidation;
     property Addtional :String  read FAddtional  write FAddtional ;
  end;
  TOldTxnDomInfoLines = class(TFreeOnDestroyList)
    private
      function GetItem(Index:Integer):TOldTxnDomInfoLine;
      procedure SetItem(Index:Integer;Value:TOldTxnDomInfoLine);
    public
      function AddFromPackText(TxnDomInfoLine:String):Integer;
      property Item[Index:Integer]:TOldTxnDomInfoLine read GetItem write SetItem; default;
  end;
  TOldTransactions = class;
  TTransactionLines = class;
  TTranslateFunc = function (TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
  TOldTransaction = class(TObject)
    private
       FGroupIndex     :Integer;
       FTxnRecordID    :Integer;
       FTxnWSNumber    :Integer;
       FTxnDateTime    :TDateTime;
       FTxnPeriod      :Integer;
       FTxnType        :String;
       FTxnOffice      :Integer;
       FTxnTeller      :String;
       FTxnIdent       :String;
       FTxnIndex       :Integer;
       FTxnPLU         :Integer;
       FTxnPrice       :Currency;
       FTxnQuantity    :Integer;
       FTxnValue       :Currency;
       FTxnDescription :String;
       FTxnInfo        :String;
       FTxnProd        :String;
       FTxnDomInfo     :String;
    public
       property GroupIndex     :Integer   read FGroupIndex     write FGroupIndex    ;
       property TxnRecordID    :Integer   read FTxnRecordID    write FTxnRecordID   ;
       property TxnWSNumber    :Integer   read FTxnWSNumber    write FTxnWSNumber   ;
       property TxnDateTime    :TDateTime read FTxnDateTime    write FTxnDateTime   ;
       property TxnPeriod      :Integer   read FTxnPeriod      write FTxnPeriod     ;
       property TxnType        :String    read FTxnType        write FTxnType       ;
       property TxnOffice      :Integer   read FTxnOffice      write FTxnOffice     ;
       property TxnTeller      :String    read FTxnTeller      write FTxnTeller     ;
       property TxnIdent       :String    read FTxnIdent       write FTxnIdent      ;
       property TxnIndex       :Integer   read FTxnIndex       write FTxnIndex      ;
       property TxnPLU         :Integer   read FTxnPLU         write FTxnPLU        ;
       property TxnPrice       :Currency  read FTxnPrice       write FTxnPrice      ;
       property TxnQuantity    :Integer   read FTxnQuantity    write FTxnQuantity   ;
       property TxnValue       :Currency  read FTxnValue       write FTxnValue      ;
       property TxnDescription :String    read FTxnDescription write FTxnDescription;
       property TxnInfo        :String    read FTxnInfo        write FTxnInfo       ;
       property TxnProd        :String    read FTxnProd        write FTxnProd       ;
       property TxnDomInfo     :String    read FTxnDomInfo     write FTxnDomInfo    ;
  end;     
  TOldTransactions = class(TFreeOnDestroyList)
    private
      function GetItem(Index:Integer):TOldTransaction;
      procedure SetItem(Index:Integer;Value:TOldTransaction);
    public
      function AddFromPackText(TxnLine:String):Integer;
      property Item[Index:Integer]:TOldTransaction read GetItem write SetItem; default;
  end;
  TTxnTranslate = class(TObject)
    private
      FSystemIdentifier:String;
    public
      constructor Create;
      function TranslateTransaction(OldTxnStrings:String):TTransactionLines;
      property SystemIdentifier:String read FSystemIdentifier write FSystemIdentifier;
      class function AddGroup(SystemIdentifier:String;TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
      class function TranslateFor(SystemIdentifier,OldTxnStrings:String):TTransactionLines;
      class function GetMsgStoreData(FromPeriod,ToPeriod:Integer;User:String;Office,Workstation:Integer;RequiredTxnTypes:String):TTransactionLines;
      class function TranslateQuery(SystemIdentifier,TxnLogQuery:String):TTransactionLines;
      class function GetQueryData(SystemIdentifier,QueryText:String):TTransactionLines;
      class function GetTransferRecords(WSNumber:Integer;var Ranges:String):String;
      class procedure MarkTransferComplete(WSNumber:Integer;Ranges:String);
  end;                     
  TTransactionDetail = class(TObject)
    private
       FName:String;
       FValue:String;
       FIdentifier:Integer;
       FParentProgID:String;
       FDomName:String;
       FEnabled:Boolean;
       FPLU:Integer;
       procedure SetName(Value:String);
    public
       property Name      :String  read FName  write SetName ;
       property Value     :String  read FValue write FValue;
       property Identifier:Integer read FIdentifier write FIdentifier;
       property ParentProgID:String  read FParentProgID write FParentProgID;
       property DomName:String  read FDomName write FDomName;
       property Enabled:Boolean read FEnabled write FEnabled;
       property PLU:Integer read FPLU write FPLU;
  end;          
  TTransactionLine = class(TFreeOnDestroyList)
    private
      FTransactionID     :Integer;
      FRecordID          :Integer;
      FWSNumber          :Integer;
      FOfficeCode        :Integer;
      FAccountingPeriod  :Integer;
      FTransactionType   :String;
      FDateTime          :TDateTime;
      FTeller            :String;
      FProgramID         :String;
      FProgramVersion    :Integer;
      FPLU               :Integer;
      FItemPrice         :Currency;
      FItemQuantity      :Integer;
      FItemValue         :Currency;
      FDescription       :String;
      FCRC               :Integer;
      FProcessedOK       :Char;
      FTxnIdent          :String;
      FFieldsResult       :String ;
      function GetItem(Index:Integer):TTransactionDetail;
      procedure SetItem(Index:Integer;Value:TTransactionDetail);
    public
      constructor Create;
      destructor Destroy; override;
      function AsString:String;
      function CommaText :String ;
      procedure SetFromString(Value:String);
      function DetailsAsString:String;
      procedure SetDetailsFromString(Value:String);
      function AddDetail(Parent,DomName,Name:String;Value:Variant;Enabled:Boolean;PLU:Integer):Integer;
      property Detail[Index:Integer]:TTransactionDetail read GetItem write SetItem; default;
      property TransactionID   :Integer     read FTransactionID    write FTransactionID   ;
      property RecordID        :Integer     read FRecordID         write FRecordID        ;
      property WSNumber        :Integer     read FWSNumber         write FWSNumber        ;
      property OfficeCode      :Integer     read FOfficeCode       write FOfficeCode      ;
      property AccountingPeriod:Integer     read FAccountingPeriod write FAccountingPeriod;
      property TransactionType :String      read FTransactionType  write FTransactionType ;
      property DateTime        :TDateTime   read FDateTime         write FDateTime        ;
      property Teller          :String      read FTeller           write FTeller          ;
      property ProgramID       :String      read FProgramID        write FProgramID       ;
      property ProgramVersion  :Integer     read FProgramVersion   write FProgramVersion  ;
      property PLU             :Integer     read FPLU              write FPLU             ;
      property ItemPrice       :Currency    read FItemPrice        write FItemPrice       ;
      property ItemQuantity    :Integer     read FItemQuantity     write FItemQuantity    ;
      property ItemValue       :Currency    read FItemValue        write FItemValue       ;
      property Description     :String      read FDescription      write FDescription     ;
      property CRC             :Integer     read FCRC              write FCRC             ;
      property ProcessedOK     :Char        read FProcessedOK      write FProcessedOK     ;
      property TxnIdent        :String      read FTxnIdent         write FTxnIdent        ;
      property FieldsResult    :String      read FFieldsResult      write FFieldsResult ;
  end;
  TTransactionLines = class(TFreeOnDestroyList)
    private
      FFieldsResult : String ;
      constructor Create ;
      function GetItem(Index:Integer):TTransactionLine;
      procedure SetItem(Index:Integer;Value:TTransactionLine);
      function Find(Value:Integer):TTransactionLine;
    public
      function CheckTables(Alias,BaseName:String):Boolean;
      function AddToTable(Alias,BaseName:String):Boolean;
      function ConvertToTable(Alias,BaseName:String):Boolean;
      function AsString:String;
      function CommaText :String ;
      procedure SetFromString(Value:String);
      property Item[Index:Integer]:TTransactionLine read GetItem      write SetItem; default;
      property FieldsResult       :String           read FFieldsResult write FFieldsResult ;
  end;

  function TxStkFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
  function StockTxFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
  function StartDayFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
  function EndDayFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
  function SimpleMailFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
  function EMSMailFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
  function RegMailFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
  function MOIssueFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
  function SimpleFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
  procedure CopyStdData(TransactionLine:TTransactionLine;TxnBlock:TOldTransactions);


var
   IPSFileName:String;
   ForceTableColumns:String;
   ColumnNames:TStrings;
   PLUsUsed:TStrings;
   
function SetTransferData(Data:String;var Error:String):Boolean;
function GetTransferData(DataType:String):String;
function ValidateFieldName(FieldName, RestrictList : String) : String;
//returns validated fieldname (eg ValueDet)


implementation
uses
   FileTxStatusU,StatusMonitorU,MsgFileAccessU,MsgConfigU,StringWrapperU;
                                           
function ValidateFieldName(FieldName, RestrictList : String) : String;
//returns validated fieldname (eg ValueDet)
var
  I:Integer;
  RestList : TStringObject;
begin
  Result := '';
  for I:=1 to Length(FieldName) do
    if FieldName[I] in ['0'..'9','A'..'Z','a'..'z','_'] then
      Result := Result + FieldName[I];

   RestList := TStringObject.Create(UpperCase( RestrictList ));
   if RestList.Strings.IndexOf( UpperCase( Result ) )>=0 then
      Result := Result + 'Det';
   if Result = '' then Result :='Unknown';
   
   if Result[1] in ['0'..'9'] then
      Result := 'n'+Result;
      
   Result := LeftString( Result, 25);
   RestList.Free;
end;

function GetNextTransactionID(Alias : String; BaseName : String) : Integer;
const
  NextID:Integer=-1;
var
   SL:TPackStringList;
begin
  if NextID = -1 then
  begin
     SL:=TPackStringList.Create;
     try
        SL.CommaText:=AliasQueryToCommaText(Alias, 'Select max(TRANSACTIONID) from ' + BaseName);
        if SL.Count > 0 then
        begin
          SL.CommaText:=SL[0];
          if SL.Count > 0 then
             NextID:=StrToIntDef(SL[0],-1);
        end;
     except
     end;
     SL.Free;
  end;
  Inc(NextID);
  Result:=NextID;
end;
function GetNextDetailID(Alias : String; BaseName : String) : Integer;
const
  NextID:Integer=-1;
var
   SL:TPackStringList;
begin
  if NextID = -1 then
  begin
     SL:=TPackStringList.Create;
     try
        SL.CommaText:=AliasQueryToCommaText(Alias, 'Select max(DETAILID) from ' + BaseName + 'DETAIL');
        if SL.Count > 0 then
        begin
          SL.CommaText:=SL[0];
          if SL.Count > 0 then
             NextID:=StrToIntDef(SL[0],-1);
        end;
     except
     end;
     SL.Free;
  end;
  Inc(NextID);
  Result:=NextID;
end;

{TTransactionDetail}
procedure TTransactionDetail.SetName(Value:String);
begin
   FName := ValidateFieldName(Value, FixedFieldNames);
   FName := ValidateFieldName(FNAme, SQLReservedWords);
end;
{TFreeOnDestroyList}
destructor TFreeOnDestroyList.Destroy;
var
   I:Integer;
begin
   for I:=0 to Count-1 do
   begin
      if Get(I) <> nil then
      begin
         TObject(Get(I)).Free;
         Put(I,nil);
      end;
   end;
   inherited Destroy;
end;
{TOldTxnDomInfoLines}
function TOldTxnDomInfoLines.GetItem(Index:Integer):TOldTxnDomInfoLine;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=TOldTxnDomInfoLine(Get(Index))
   else
      Result:=nil;
end;
procedure TOldTxnDomInfoLines.SetItem(Index:Integer;Value:TOldTxnDomInfoLine);
begin
   if (Index >= 0) and (Index < Count) then
      Put(Index,Value);
end;
function TOldTxnDomInfoLines.AddFromPackText(TxnDomInfoLine:String):Integer;
var
  OldTxnDomInfoLine:TOldTxnDomInfoLine;
  OSL:TPackStringList;
  SL:TPackStringList;
  I:Integer;
begin
  SL:=TPackStringList.Create;
  OSL:=TPackStringList.Create;
  OSL.PackText:=TxnDomInfoLine;
  for I:=0 to OSL.Count-1 do
  begin
     SL.PackText:=OSL[I];
     OldTxnDomInfoLine:=TOldTxnDomInfoLine.Create;
     try
        with OldTxnDomInfoLine do
        begin
           if SL.Count > 0 then if SL[0] = '1' then Enabled:=True else Enabled:=False;
           if SL.Count > 1 then if SL[1] = '1' then Focused:=True else Focused:=False;
           if SL.Count > 2 then DomType   :=SL[2];
           if SL.Count > 3 then Name      :=SL[3];
           if SL.Count > 4 then Prompt    :=SL[4];
           if SL.Count > 5 then Text      :=SL[5];
           if SL.Count > 6 then Hint      :=SL[6];
           if SL.Count > 7 then Error     :=SL[7];
           if SL.Count > 8 then Validation:=SL[8];
           if SL.Count > 9 then Addtional :=SL[9];
        end;                         
     except                          
        // ??
     end;
     Add(OldTxnDomInfoLine);
  end;
  Result:=Count;
  SL.Free;
  OSL.Free;
end;


{TTransactionLine}
constructor TTransactionLine.Create;
begin
   inherited Create;
   FTransactionID     :=0;
   FRecordID          :=0;
   FWSNumber          :=0;
   FOfficeCode        :=0;
   FAccountingPeriod  :=0;
   FTransactionType   :='';
   FDateTime          :=0;
   FTeller            :='';
   FProgramID         :='';
   FProgramVersion    :=0;
   FPLU               :=0;
   FItemPrice         :=0;
   FItemQuantity      :=0;
   FItemValue         :=0;
   FDescription       :='';
   FCRC               :=0;
   FProcessedOK       :='N';
   FTxnIdent          :='' ;  
   FFieldsResult       :='' ;  
end;
destructor TTransactionLine.Destroy;
begin
   inherited Destroy;
end;
function TTransactionLine.GetItem(Index:Integer):TTransactionDetail;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=TTransactionDetail(Get(Index))
   else
      Result:=nil;
end;
procedure TTransactionLine.SetItem(Index:Integer;Value:TTransactionDetail);
begin
   if (Index >= 0) and (Index < Count) then
      Put(Index,Value);
end;                                                
function TTransactionLine.AddDetail(Parent,DomName,Name:String;Value:Variant;Enabled:Boolean;PLU:Integer):Integer;
var
   TransactionDetail:TTransactionDetail;
   I:Integer;
begin
   for I:=0 to Count-1 do
   begin
      if Detail[I].Name = Replace(Name, ' ', '') then
      begin
         Result:=I;
         Exit;
      end;
   end;
   TransactionDetail              := TTransactionDetail.Create;
   TransactionDetail.Name         := Name ;
   TransactionDetail.Value        := Value;
   TransactionDetail.ParentProgID := Parent;
   TransactionDetail.Enabled      := Enabled;
   TransactionDetail.DomName      := DomName;
   TransactionDetail.PLU          := PLU;
   Result:=Add(TransactionDetail);
end;
procedure TTransactionLine.SetDetailsFromString(Value:String);
var
   SL:TPackStringList;
   DSL:TPackStringList;
   I:Integer;
   TransactionDetail:TTransactionDetail;
begin
   SL :=TPackStringList.Create;
   DSL:=TPackStringList.Create;
   DSL.PackText:=Value;
   for I:=0 to DSL.Count-1 do 
   begin
      SL.PackText:=DSL[I];
      TransactionDetail:=TTransactionDetail.Create;
      if SL.Count > 0 then TransactionDetail.Name :=SL[0];
      if SL.Count > 1 then TransactionDetail.Value:=SL[1];
      Add(TransactionDetail);
   end;
   SL .Free;
   DSL.Free;
end;
function TTransactionLine.DetailsAsString:String;
var
   SL:TPackStringList;
   DSL:TPackStringList;
   I:Integer;
begin
   SL :=TPackStringList.Create;
   DSL:=TPackStringList.Create;
   for I:=0 to Count-1 do 
   begin
      SL.Clear;
      SL.Add(Detail[I].Name);
      SL.Add(Detail[I].Value);
      DSL.Add(SL.PackText);
   end;
   Result:=DSL.PackText;
   SL .Free;
   DSL.Free;
end;
procedure TTransactionLine.SetFromString(Value:String);
var
   SL:TPackStringList;
   code:Integer;
begin
   SL:=TPackStringList.Create;
   SL.PackText:=Value;
   if SL.Count >  0 then FTransactionID     :=StrToIntDef (SL[ 0],0);
   if SL.Count >  1 then FRecordID          :=StrToIntDef (SL[ 1],0);
   if SL.Count >  2 then FWSNumber          :=StrToIntDef (SL[ 2],0);
   if SL.Count >  3 then FOfficeCode        :=StrToIntDef (SL[ 3],0);
   if SL.Count >  4 then FAccountingPeriod  :=StrToIntDef (SL[ 4],0);
   if SL.Count >  5 then FTransactionType   :=             SL[ 5]   ;
   if SL.Count >  6 then                               Val(SL[ 6],FDateTime,code);
   if SL.Count >  7 then FTeller            :=             SL[ 7]   ;
   if SL.Count >  8 then FProgramID         :=             SL[ 8]   ;
   if SL.Count >  9 then FProgramVersion    :=StrToIntDef (SL[ 9],0);
   if SL.Count > 10 then FPLU               :=StrToIntDef (SL[10],0);
   if SL.Count > 11 then FItemPrice         :=StrToCurrDef(SL[11],0);
   if SL.Count > 12 then FItemQuantity      :=StrToIntDef (SL[12],0);
   if SL.Count > 13 then FItemValue         :=StrToCurrDef(SL[13],0);
   if SL.Count > 14 then FDescription       :=             SL[14]   ;
   if SL.Count > 15 then FCRC               :=StrToIntDef (SL[15],0);
   if SL.Count > 17 then FTxnIdent          :=SL[17]                ;
   
   if SL.Count > 16 then begin
                            if Copy(SL[16],1,1) = 'Y' then
                               FProcessedOK:='Y'
                            else
                               FProcessedOK:='N';
                         end;
   if SL.Count > 18 then SetDetailsFromString(SL[18]);
   SL.Free;
end;       

function TTransactionLine.AsString:String;
var
   SL:TPackStringList;
   S:String;
begin
   SL:=TPackStringList.Create;
   SL.Clear;
   SL.Add(IntToStr(FTransactionID     ));
   SL.Add(IntToStr(FRecordID          ));
   SL.Add(IntToStr(FWSNumber          ));
   SL.Add(IntToStr(FOfficeCode        ));
   SL.Add(IntToStr(FAccountingPeriod  ));
   SL.Add(         FTransactionType    );
   Str(FDateTime,S); SL.Add(S);
   SL.Add(         FTeller             );
   SL.Add(         FProgramID          );
   SL.Add(IntToStr(FProgramVersion    ));
   SL.Add(IntToStr(FPLU               ));
   SL.Add(CurrToStr(FItemPrice        ));
   SL.Add(IntToStr(FItemQuantity      ));
   SL.Add(CurrToStr(FItemValue        ));
   SL.Add(         FDescription        );
   SL.Add(IntToStr(FCRC               ));
   SL.Add(FProcessedOK);
   SL.Add(FTxnIdent);
   SL.Add(DetailsAsString);
   Result:=SL.PackText;
   SL.Free;
end;

function TTransactionLine.CommaText :String ;
var
   SL:TPackStringList;
   SLField : TPackStringList ;
   S:String;
   F, I : integer ;
begin
   SL:=TPackStringList.Create;

   // Keep the fix header

   SL.Clear;
   SL.Add(IntToStr(FTransactionID     )); //0  Const_FTransactionID
   SL.Add(IntToStr(FRecordID          )); //1  Const_FRecordID
   SL.Add(IntToStr(FWSNumber          )); //2  Const_FWSNumber
   SL.Add(IntToStr(FOfficeCode        )); //3  Const_FOfficeCode
   SL.Add(IntToStr(FAccountingPeriod  )); //4  Const_FAccountingPeriod
   SL.Add(         FTransactionType    ); //5  Const_FTransactionType
   Str(FDateTime,S); SL.Add(S);           //6  Const_FDateTime
   SL.Add(         FTeller             ); //7  Const_FTeller
   SL.Add(         FProgramID          ); //8  Const_FProgramID
   SL.Add(IntToStr(FProgramVersion    )); //9  Const_FProgramVersion
   SL.Add(IntToStr(FPLU               )); //10 Const_FPLU
   SL.Add(CurrToStr(FItemPrice        )); //11 Const_FItemPrice
   SL.Add(IntToStr(FItemQuantity      )); //12 Const_ItemQuantity
   SL.Add(CurrToStr(FItemValue        )); //13 Const_FItemValue
   SL.Add(         FDescription        ); //14 Const_FDescription
   SL.Add(IntToStr(FCRC               )); //15 Const_FCRC , Const_OffSetHead
   SL.Add(FProcessedOK                 ); //16 Const_ProcessedOK
   SL.Add(FTxnIdent);
                      
   if FFieldsResult = '' then
   begin

      for I := 0 to Count -1 do
      begin
         SL.Add( Detail[I].Value );
      end ;
   end
   else
   begin
      SLField := TPackStringList.Create ;
      SLField.CommaText := UpperCase(FFieldsResult);
      for F := 0 to SLField.Count -1 do
      begin
         I := 0 ;
         if ( Count > 0 ) then
         begin
            while ( I <= Count-1 ) and ( SLField[F]<>UpperCase(Detail[I].Name) ) do Inc( I ) ;
            if (I<=Count-1) and (SLField[F]=UpperCase(Detail[I].Name)) then
               SL.Add( Detail[I].Value );
         end ;
      end ;
      SLField.Free ;
   end ;

   Result:=SL.Commatext;
   SL.Free;

end ;
{TTransactionLines}
Constructor TTransactionLines.Create ;
begin
   inherited Create;
   FFieldsResult := '' ;
end ;

function TTransactionLines.Find(Value:Integer):TTransactionLine;
var
   I:Integer;
begin
   for I:=0 to Count-1 do
   begin
      if GetItem(I).TransactionID = Value then
      begin
         Result:=GetItem(I);
         Exit;
      end;
   end;
   Result:=TTransactionLine.Create;
end;
function TTransactionLines.GetItem(Index:Integer):TTransactionLine;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=TTransactionLine(Get(Index))
   else
      Result:=nil;
end;
procedure TTransactionLines.SetItem(Index:Integer;Value:TTransactionLine);
begin
   if (Index >= 0) and (Index < Count) then
      Put(Index,Value);
end;                                                
function TTransactionLines.AsString:String;
var
   SL:TPackStringList;
   I:Integer;
begin
   SL:=TPackStringList.Create;
   for I:=0 to Count-1 do SL.Add(Item[I].AsString);
   Result:=SL.PackText;
   SL.Free;
end;

function TTransactionLines.CommaText:String;
var
   SL:TPackStringList;
   I:Integer;
begin
   SL:=TPackStringList.Create;

   for I:=0 to Count-1 do
   begin
      Item[I].FieldsResult := FFieldsResult ;
      SL.Add(Item[I].CommaText);
   end ;
   Result:=SL.CommaText;
   SL.Free;
end;

procedure TTransactionLines.SetFromString(Value:String);
var
   SL:TPackStringList;
   I:Integer;
   TransactionLine:TTransactionLine;
begin
   SL:=TPackStringList.Create;
   SL.PackText:=Value;
   for I:=0 to SL.Count-1 do
   begin
      TransactionLine:=TTransactionLine.Create;
      TransactionLine.SetFromString(SL[I]);
      Add(TransactionLine);
   end;
   SL.Free;
end;
function IsCurr(Value:String):Boolean;
var
   P:PChar;
   Pos:Integer;
   HadPoint:Boolean;
begin
   Result:=False;
   If Length(Value) > 14 then exit;
   HadPoint:=False;
   Pos:=0;
   P:=PChar(Value);
   while P^ <> #0 do
   begin
      if (P^ = '-') and ((Pos > 0) or (Length(Value) = 1)) then Exit;
      if (P^ = '.') then
      begin
         if (HadPoint) or (Length(Value) = 1) then Exit;
         HadPoint:=True;
      end
      else if not (P^ in ['0'..'9','-']) then 
         Exit;
      Inc(P);
      Inc(Pos);
   end;
   Result:=True;
end;
function IsInteger(Value:String):Boolean;
var
   P:PChar;
   Pos:Integer;
begin
   Result:=False;
   If Length(Value) > 9 then exit;
   Pos:=0;
   P:=PChar(Value);
   while P^ <> #0 do
   begin
      if (P^ = '-') and ((Pos > 0) or (Length(Value) = 1)) then Exit;
      if not (P^ in ['0'..'9','-']) then Exit;
      Inc(P);
      Inc(Pos);
   end;        
   Result:=True;
end;
function FieldType(Value:String;OldType:Integer;var TypeChanged:Boolean):Integer;
var
   FT:TFieldType;
begin
    TypeChanged:=False;
    Result:=OldType and $FFFFF000;
    if OldType = 0 then
       FT:=ftInteger
    else
       FT:=TFieldType(OldType shr 12);

    if FT = ftString then Exit;

    if IsInteger(Value) and (FT <> ftCurrency) then
       FT:=ftInteger
    else if IsCurr(Value) then
       FT:=ftCurrency
    else
       FT:=ftString;
    TypeChanged:=FT <> TFieldType(OldType shr 12);
    Result:=Integer(FT) shl 12;
end;
function TTransactionLines.ConvertToTable(Alias,BaseName:String):Boolean;
var
   I,J:Integer;
   DetailList:TStringList;
   TxnLine:TTransactionLine;
   Index,ItemLen,ItemType:Integer;
   TypeChanged:Boolean;
   TxnTypeLen:Integer;
   TellerLen :Integer;
   ProgIDLen :Integer;
   DescLen   :Integer;
   Database:TDatabase;
   Table:TTable;
   Query:TQuery;
   SL:TStringList;
   DatabaseType:String;
   function Max(A,B:Integer):Integer;
   begin
      if A > B then Result:=A else Result:=B;
   end;
begin
   Database:=TDatabase.Create(nil);
   Database.AliasName:='PSL';
   Database.DatabaseName:='ReportTemp';
   Database.LoginPrompt:=False;
   Table:=TTable.Create(nil);
   Table.DatabaseName:='ReportTemp';
   Query:=TQuery.Create(nil);
   Query.DatabaseName:='ReportTemp';
   try
      DetailList:=TStringList.Create;
      Result:=True;
      TxnTypeLen:=1;
      TellerLen :=1;
      ProgIDLen :=1;
      DescLen   :=1;
      for I:=0 to Count-1 do
      begin
         TxnLine:=Item[I];
         TxnTypeLen:=Max(TxnTypeLen,Length(TxnLine.TransactionType));
         TellerLen :=Max(TellerLen ,Length(TxnLine.Teller         ));
         ProgIDLen :=Max(ProgIDLen ,Length(TxnLine.ProgramID      ));
         DescLen   :=Max(DescLen   ,Length(TxnLine.Description    ));
         for J:=0 to TxnLine.Count-1 do
         begin
            TxnLine[J].Value:=Trim(TxnLine[J].Value);
            if (TxnLine[J].Name <> '') and (TxnLine[J].Value <> '') then
            begin
                Index:=DetailList.IndexOf(TxnLine[J].Name);
                if Index = -1 then
                begin
                   ItemLen:=Length(TxnLine[J].Value)+1;
                   ItemType:=FieldType(TxnLine[J].Value,0,TypeChanged);
                   DetailList.AddObject(TxnLine[J].Name,TObject(ItemLen or ItemType));
                end
                else
                begin
                   ItemLen:=Integer(DetailList.Objects[Index]) and $FFF;
                   ItemType:=FieldType(TxnLine[J].Value,Integer(DetailList.Objects[Index]),TypeChanged);
                   if (ItemLen < Length(TxnLine[J].Value)) or TypeChanged then
                   begin
                      ItemLen:=Length(TxnLine[J].Value)+1;
                      DetailList.Objects[Index]:=TObject(ItemLen or ItemType);
                   end;
                end;
            end;
         end;
      end;
      if ForceTableColumns <> '' then
      begin
         SL:=TStringList.Create;
         SL.CommaText:=ForceTableColumns;
         for I:=0 to SL.Count-1 do
         begin
            Index:=DetailList.IndexOf(SL[I]);
            if (Index = -1) 
            and (Pos(SL[I],FixedFieldNames) = 0) 
            and (Pos(SL[I],SQLReservedWords) = 0) then
            begin
               ItemLen:=20;
               ItemType:=Integer(ftString) shl 12;
               DetailList.AddObject(SL[I],TObject(ItemLen or ItemType));
            end;
         end;
         SL.Free;
      end;
      DatabaseType:=GetGPCSRegString('Workstation','DBType','Paradox');
      if ColumnNames <> nil then
      begin
         ColumnNames.Add('TransactionID'   );
         ColumnNames.Add('RecordID'        );
         ColumnNames.Add('WSNumber'        );
         ColumnNames.Add('OfficeCode'      );
         ColumnNames.Add('AccountingPeriod');
         ColumnNames.Add('TransactionType' );
         ColumnNames.Add('TxnDateTime'     );
         ColumnNames.Add('Teller'          );
         ColumnNames.Add('ProgramID'       );
         ColumnNames.Add('ProgramVersion'  );
         ColumnNames.Add('PLU'             );
         ColumnNames.Add('ItemPrice'       );
         ColumnNames.Add('ItemQuantity'    );
         ColumnNames.Add('ItemValue'       );
         ColumnNames.Add('Description'     );
         ColumnNames.Add('CRC'             );
         ColumnNames.Add('ProcessedOK'     );
         ColumnNames.Add('TxnIdent'        );
         for I:=0 to DetailList.Count-1 do
             ColumnNames.Add(DetailList[I])
      end;                                 
      if DatabaseType = 'Paradox' then
      begin
         with Table do
         begin
            try
               Active:=False;
               TableType:=ttDefault;
               TableName:=BaseName;
               with FieldDefs do
               begin
                  Clear; // clear the current field definitions
                  Add('TransactionID'   ,ftInteger    ,         0,True );
                  Add('RecordID'        ,ftInteger    ,         0,True );
                  Add('WSNumber'        ,ftInteger    ,         0,True );
                  Add('OfficeCode'      ,ftInteger    ,         0,True );
                  Add('AccountingPeriod',ftInteger    ,         0,True );
                  Add('TransactionType' ,ftString     ,TxnTypeLen,True );
                  Add('TxnDateTime'     ,ftDateTime   ,         0,True );
                  Add('Teller'          ,ftString     ,TellerLen ,False);
                  Add('ProgramID'       ,ftString     ,ProgIDLen ,False);
                  Add('ProgramVersion'  ,ftInteger    ,         0,False);
                  Add('PLU'             ,ftInteger    ,         0,False);
                  Add('ItemPrice'       ,ftCurrency   ,         0,False);
                  Add('ItemQuantity'    ,ftInteger    ,         0,False);
                  Add('ItemValue'       ,ftCurrency   ,         0,False);
                  Add('Description'     ,ftString     ,DescLen   ,False);
                  Add('CRC'             ,ftInteger    ,         0,False);
                  Add('ProcessedOK'     ,ftString     ,         1,False);
                  Add('TxnIdent'        ,ftString     ,       100,False);
                  for I:=0 to DetailList.Count-1 do
                  begin
                      ItemType:=(Integer(DetailList.Objects[I]) shr 12);
                      if ItemType = Integer(ftString) then
                         Add(DetailList[I],ftString,Integer(DetailList.Objects[I]) and $FFF,False)
                      else
                         Add(DetailList[I],TFieldType(ItemType),0,False);
                  end;
                  //ensure fieldsresults exist
                  With TStringList.Create do
                  begin
                     CommaText := FFieldsResult;
                     for I:=0 to Count-1 do
                     begin
                        Strings[i] := ValidateFieldName(Strings[i], FixedFieldNames);
                        Strings[i] := ValidateFieldName(Strings[i], SQLReservedWords);
                        If (DetailList.IndexOf(Strings[i]) = -1) then //required field not in these records
                        begin
                          FieldDefs.Add(Strings[i],ftInteger,0,False);
                          if ColumnNames <> nil then
                             ColumnNames.Add(Strings[i])
                        end;
                     end;
                     Free;
                  end;
               end;
               with IndexDefs do // create the index
               begin
                  Clear;
                  Add('','TransactionID;RecordID;WSNumber;OfficeCode' , [ixPrimary, ixUnique]);
               end;
               CreateTable;
            except
               on E : Exception do
               begin
                  RaiseGUIDException('{0E08DEC7-A889-470E-A2D5-987C6DD1168E}',E);
                  Result:=False;
               end;
            end;
         end;
      end
      else if DatabaseType = 'SQLServer' then
      begin
          with Query do
          begin
             try
                 Query.SQL.Text:='DROP TABLE "'+UpperCase(BaseName)+'"';
                 Query.ExecSQL;
             except
             end;
             Query.SQL.Text:='CREATE TABLE '+UpperCase(BaseName)+'(';
             Query.SQL.Add('TRANSACTIONID    INT                             NOT NULL,');
             Query.SQL.Add('RECORDID         INT                             NOT NULL,');
             Query.SQL.Add('WSNUMBER         INT                             NOT NULL,');
             Query.SQL.Add('OFFICECODE       INT                             NOT NULL,');
             Query.SQL.Add('ACCOUNTINGPERIOD INT                             NOT NULL,');
             Query.SQL.Add('TRANSACTIONTYPE  CHAR('+IntToStr(TxnTypeLen)+')  NOT NULL,');
             Query.SQL.Add('TXNDATETIME      DATETIME                                ,');
             Query.SQL.Add('TELLER           CHAR('+IntToStr(TellerLen)+')           ,');
             Query.SQL.Add('PROGRAMID        CHAR('+IntToStr(ProgIDLen)+')           ,');
             Query.SQL.Add('PROGRAMVERSION   INT                                     ,');
             Query.SQL.Add('PLU              INT                                     ,');
             Query.SQL.Add('ITEMPRICE        MONEY                                   ,');
             Query.SQL.Add('ITEMQUANTITY     INT                                     ,');
             Query.SQL.Add('ITEMVALUE        MONEY                                   ,');
             Query.SQL.Add('DESCRIPTION      CHAR('+IntToStr(DescLen)+')             ,');
             Query.SQL.Add('CRC              INT                                     ,');
             Query.SQL.Add('PROCESSEDOK      CHAR(1)                                 ,');
             Query.SQL.Add('TXNIDENT         CHAR(100)                               ,');
             
             for I:=0 to DetailList.Count-1 do
             begin
                 ItemType:=(Integer(DetailList.Objects[I]) shr 12);
                 if ItemType = Integer(ftString) then
                 begin
                    Query.SQL.Add(DetailList[I]+'  CHAR('+IntToStr(Integer(DetailList.Objects[I]) and $FFF)+') ,');
                 end
                 else
                 begin
                    case TFieldType(ItemType) of
                       ftInteger  : Query.SQL.Add(DetailList[I]+'  INT,');
                       ftCurrency : Query.SQL.Add(DetailList[I]+'  MONEY,');
                    end;
                 end
             end;
             //ensure fieldsresults exist
             With TStringList.Create do
             begin
                CommaText := FFieldsResult;
                for I:=0 to Count-1 do
                begin
                   Strings[i] := ValidateFieldName(Strings[i], FixedFieldNames);
                   Strings[i] := ValidateFieldName(Strings[i], SQLReservedWords);
                   If (DetailList.IndexOf(Strings[I]) = -1) then//required field not in this record
                   begin
                      Query.SQL.Add(Strings[I]+'  INT,');
                      if ColumnNames <> nil then
                         ColumnNames.Add(Strings[I])
                   end;                             
                end;
                Free;
             end;
             Query.SQL.Add(' CONSTRAINT '+UpperCase(BaseName)+'_PINDEX PRIMARY KEY(TRANSACTIONID,RECORDID,WSNUMBER,OFFICECODE));');
             try
                 Query.SQL.SaveToFile('C:\RRQuery.sql');
                 Query.ExecSQL;
             finally
             end;
          end;
      end;
      with Table do
      begin
         TableName:=BaseName;
         Table.Active:=True;
         try
            for I:=0 to Count-1 do
            begin
               TxnLine:=Item[I];
               TxnLine.FTransactionID:=I+1;
               EditKey;
               FieldByName('RecordID'  ).Value:=TxnLine.RecordID;
               FieldByName('WSNumber'  ).Value:=TxnLine.WSNumber;
               FieldByName('OfficeCode').Value:=TxnLine.OfficeCode;
               if GotoKey then
               begin
                  if TxnLine.CRC <> FieldByName('CRC').Value then ;
               end
               else
               begin
                  if PLUsUsed <> nil then
                  begin
                     if PLUsUsed.IndexOf(IntToStr(TxnLine.PLU)) = -1 then
                        PLUsUsed.Add(IntToStr(TxnLine.PLU));
                  end;
                  Append;
                  if TxnLine.FTransactionID < 1 then
                     TxnLine.FTransactionID:=GetNextTransactionID(Alias, BaseName);
                  FieldByName('TransactionID'   ).Value:=TxnLine.FTransactionID;
                  FieldByName('RecordID'        ).Value:=TxnLine.RecordID;
                  FieldByName('WSNumber'        ).Value:=TxnLine.WSNumber;
                  FieldByName('OfficeCode'      ).Value:=TxnLine.OfficeCode;
                  FieldByName('AccountingPeriod').Value:=TxnLine.AccountingPeriod;
                  FieldByName('TransactionType' ).Value:=TxnLine.TransactionType;
                  FieldByName('TxnDateTime'     ).Value:=TxnLine.DateTime;
                  FieldByName('Teller'          ).Value:=TxnLine.Teller;
                  FieldByName('ProgramID'       ).Value:=TxnLine.ProgramID;
                  FieldByName('ProgramVersion'  ).Value:=TxnLine.ProgramVersion;
                  FieldByName('PLU'             ).Value:=TxnLine.PLU;
                  FieldByName('ItemPrice'       ).Value:=TxnLine.ItemPrice;
                  FieldByName('ItemQuantity'    ).Value:=TxnLine.ItemQuantity;
                  FieldByName('ItemValue'       ).Value:=TxnLine.ItemValue;
                  FieldByName('Description'     ).Value:=TxnLine.Description;
                  FieldByName('CRC'             ).Value:=TxnLine.CRC;
                  FieldByName('ProcessedOK'     ).Value:=TxnLine.ProcessedOK;
                  FieldByName('TxnIdent'        ).Value:=TxnLine.TxnIdent;
                  for J:=0 to TxnLine.Count-1 do
                  begin
                      if (TxnLine[J].Name <> '') and (TxnLine[J].Value <> '') then
                         FieldByName(TxnLine[J].Name).AsString:=TxnLine[J].Value;
                  end;
                  Post;
               end;
            end;
            Active:=False;
         except
            on E : Exception do
            begin
               RaiseGUIDException('{78DB1021-88CC-4D59-AAFE-F56708AE9412}',E);
               Result:=False;
            end;
         end;
      end;
   finally
      Query.Free;
      Table.Free;
      Database.Free;
   end;
end;
function TTransactionLines.AddToTable(Alias,BaseName:String):Boolean;
var
   MainTable:TTable;
   DetailTable:TTable;
   DetailNameTable:TTable;
   DetailList:TStringList;
   TxnLine:TTransactionLine;
   I,J,Index:Integer;
begin  
   Result:=CheckTables(Alias,BaseName);
   if not Result then
      Exit;
   
   DetailList:=TStringList.Create;
   DetailNameTable:=TTable.Create(nil);
   with DetailNameTable do
   begin
      try
         Active:=False;
         DatabaseName:=Alias;
         TableType:=ttDefault;
         TableName:=BaseName+'DetailName';
         Active:=True;
         First;
         while not EOF do
         begin
            I:=FieldByName('DetailID').Value;
            DetailList.AddObject(FieldByName('DetailName').AsString,TObject(I));
            Next;
         end;
         for I:=0 to Count-1 do
         begin
            TxnLine:=Item[I];
            for J:=0 to TxnLine.Count-1 do
            begin
               if (DetailList.IndexOf(TxnLine[J].Name) = -1) and (TxnLine[J].Name <> '') then
               begin
                  DetailList.Add(TxnLine[J].Name);
                  Append;
                  if TxnLine[J].Identifier < 1 then
                     TxnLine[J].Identifier := GetNextDetailID(Alias, BaseName);
                  FieldByName('DetailID'   ).Value:=TxnLine[J].Identifier;
                  FieldByName('DetailName').AsString:=TxnLine[J].Name;
                  Post;
               end;
            end;
         end;
         DetailList.Clear;
         First;
         while not EOF do
         begin
            I:=FieldByName('DetailID').Value;
            DetailList.AddObject(FieldByName('DetailName').AsString,TObject(I));
            Next;
         end;
         Active:=False;
      except
         on E : Exception do
         begin
            RaiseGUIDException('{41E50562-9581-41A8-A68F-5BB2D0756B24}',E);
            Free;
         end;
      end;
   end;
   for I:=0 to Count-1 do
   begin
      TxnLine:=Item[I];
      for J:=0 to TxnLine.Count-1 do
      begin
         Index:=DetailList.IndexOf(TxnLine[J].Name);
         if Index = -1 then
         begin
//            ShowMessage('Error Detail Name ('+TxnLine.AsString+')Not Added !!!');
         end
         else
         begin
            TxnLine[J].Identifier:=Integer(DetailList.Objects[Index]);
         end;
      end;
   end;
   MainTable:=TTable.Create(nil);
   with MainTable do
   begin
      try
         Active:=False;
         DatabaseName:=Alias;
         TableType:=ttDefault;
         TableName:=BaseName;
         Active:=True;
         for I:=0 to Count-1 do
         begin
            TxnLine:=Item[I];
            EditKey;
            FieldByName('RecordID'        ).Value:=TxnLine.RecordID;
            FieldByName('WSNumber'        ).Value:=TxnLine.WSNumber;
            FieldByName('OfficeCode'      ).Value:=TxnLine.OfficeCode;
            if not GotoKey then
            begin
               Append;
               if TxnLine.FTransactionID < 1 then
                  TxnLine.FTransactionID:=GetNextTransactionID(Alias, BaseName);
               FieldByName('TransactionID'   ).Value:=TxnLine.FTransactionID;
               FieldByName('RecordID'        ).Value:=TxnLine.RecordID;
               FieldByName('WSNumber'        ).Value:=TxnLine.WSNumber;
               FieldByName('OfficeCode'      ).Value:=TxnLine.OfficeCode;
               FieldByName('AccountingPeriod').Value:=TxnLine.AccountingPeriod;
               FieldByName('TransactionType' ).Value:=TxnLine.TransactionType;
               FieldByName('TxnDateTime'     ).Value:=TxnLine.DateTime;
               FieldByName('Teller'          ).Value:=TxnLine.Teller;
               FieldByName('ProgramID'       ).Value:=TxnLine.ProgramID;
               FieldByName('ProgramVersion'  ).Value:=TxnLine.ProgramVersion;
               FieldByName('PLU'             ).Value:=TxnLine.PLU;
               FieldByName('ItemPrice'       ).Value:=TxnLine.ItemPrice;
               FieldByName('ItemQuantity'    ).Value:=TxnLine.ItemQuantity;
               FieldByName('ItemValue'       ).Value:=TxnLine.ItemValue;
               FieldByName('Description'     ).Value:=TxnLine.Description;
               FieldByName('CRC'             ).Value:=TxnLine.CRC;
               FieldByName('ProcessedOK'     ).Value:=TxnLine.ProcessedOK;
               FieldByName('TxnIdent'        ).Value:=TxnLine.TxnIdent;
               Post;
            end;
         end;
      except
         on E : Exception do
         begin
            RaiseGUIDException('{BECE8A99-6CBD-413E-8606-7AFD33EDBB15}',E);
            Free;
         end;
      end;
   end;
   DetailTable:=TTable.Create(nil);
   with DetailTable do
   begin
      Active:=False;
      DatabaseName:=Alias;
      TableType:=ttDefault;
      TableName:=BaseName+'Detail';
      Active:=True;
      for I:=0 to Count-1 do
      begin
         TxnLine:=Item[I];
         for J:=0 to TxnLine.Count-1 do
         begin
            EditKey;
            FieldByName('TransactionID').Value:=TxnLine.TransactionID;
            FieldByName('DetailID').Value:=TxnLine[J].Identifier;
            if not GotoKey then
            begin
               Append;
               FieldByName('TransactionID').Value:=TxnLine.TransactionID;
               FieldByName('DetailID').Value:=TxnLine[J].Identifier;
               FieldByName('DetailValue').Value:=TxnLine[J].Value;
               Post;
            end;
         end;
      end;
      Free;
   end;
end;              
function TTransactionLines.CheckTables(Alias,BaseName:String):Boolean;
begin
   if GetGPCSRegString('WorkStation','DBType','Paradox') <> 'Paradox' then
   begin
     Result:=TRUE;
     exit;
   end;
   
   if Alias = 'PSL' then Alias:='C:\Tan\Database';
   
   Result:=True;
   ForceDirectories(Alias);
   if not (FileExists(Alias+'\'+BaseName+'.db')) then
   begin
      with TTable.Create(nil) do // create the money order issued table
      begin                      // records each issue
        try
           Active:=False;
           DatabaseName:=Alias;
           TableType:=ttParadox;
           TableName:=BaseName;
           with FieldDefs do
           begin
              Clear; // clear the current field definitions
              Add('TransactionID'   ,ftInteger    ,  0,True);
              Add('RecordID'        ,ftInteger    ,  0,True);
              Add('WSNumber'        ,ftInteger    ,  0,True);
              Add('OfficeCode'      ,ftInteger    ,  0,True);
              Add('AccountingPeriod',ftInteger    ,  0,True);
              Add('TransactionType' ,ftString     , 50,True);
              Add('TxnDateTime'     ,ftDateTime   ,  0,True);
              Add('Teller'          ,ftString     , 50,False);
              Add('ProgramID'       ,ftString     , 50,False);
              Add('ProgramVersion'  ,ftInteger    ,  0,False);
              Add('PLU'             ,ftInteger    ,  0,False);
              Add('ItemPrice'       ,ftCurrency   ,  0,False);
              Add('ItemQuantity'    ,ftInteger    ,  0,False);
              Add('ItemValue'       ,ftCurrency   ,  0,False);
              Add('Description'     ,ftString     ,255,False);
              Add('CRC'             ,ftInteger    ,  0,False);
              Add('ProcessedOK'     ,ftString     ,  1,False);
              Add('TxnIdent'        ,ftString     ,100,False);
           end;

           with IndexDefs do // create the index
           begin
              Clear;
              Add('','TransactionID;RecordID;WSNumber;OfficeCode' , [ixPrimary, ixUnique]);
           end;
           CreateTable;
        except
           on E : Exception do
           begin
              RaiseGUIDException('{E44BECB9-3AF5-43AA-BBF0-14F29E985C03}',E);
              Result:=False;
           end;
        end;
        Free;
      end;
   end;
   if not (FileExists(Alias+'\'+BaseName+'Detail.db')) then
   begin
      with TTable.Create(nil) do // create the money order issued table
      begin                      // records each issue
         try
            Active:=False;
            DatabaseName:=Alias;
            TableType:=ttParadox;
            TableName:=BaseName+'Detail';
            with FieldDefs do
            begin
               Clear; // clear the current field definitions
               Add('TransactionID',ftInteger,  0,True );
               Add('DetailID'     ,ftInteger,  0,True );
               Add('DetailValue'  ,ftString ,255,False);
            end;

            with IndexDefs do // create the index
            begin
               Clear;
               Add('','TransactionID;DetailID' , [ixPrimary, ixUnique]);
            end;
            CreateTable;
         except
            on E : Exception do
            begin
               RaiseGUIDException('{4DF3D8D8-014F-4A84-BFA7-7B347EADFF6C}',E);
               Result:=False;
            end;
         end;
         Free;
      end;
   end;
   if not (FileExists(Alias+'\'+BaseName+'DetailName.db')) then
   begin
      with TTable.Create(nil) do // create the money order issued table
      begin                      // records each issue
         try
            Active:=False;
            DatabaseName:=Alias;
            TableType:=ttParadox;
            TableName:=BaseName+'DetailName';
            with FieldDefs do
            begin
               Clear; // clear the current field definitions
               Add('DetailID'  ,ftInteger,  0,True );
               Add('DetailName',ftString ,100,True );
            end;

            with IndexDefs do // create the index
            begin
               Clear;
               Add('','DetailID' , [ixPrimary, ixUnique]);
            end;
            CreateTable;
         except
            on E : Exception do
            begin
               RaiseGUIDException('{C584FD60-EFAA-425B-9989-655795295994}',E);
               Result:=False;
            end;
         end;
         Free;
      end;
   end;
end;
{TOldTransactions}
function TOldTransactions.GetItem(Index:Integer):TOldTransaction;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=TOldTransaction(Get(Index))
   else
      Result:=nil;
end;
procedure TOldTransactions.SetItem(Index:Integer;Value:TOldTransaction);
begin
   if (Index >= 0) and (Index < Count) then
      Put(Index,Value);
end;
function TOldTransactions.AddFromPackText(TxnLine:String):Integer;
var
  OldTransaction:TOldTransaction;
  SL:TPackStringList;
  Code:Integer;
  DT:TDateTime;
begin
  SL:=TPackStringList.Create;
  SL.PackText:=TxnLine;
  OldTransaction:=TOldTransaction.Create;
  try
     with OldTransaction do
     begin
        if SL.Count >  0 then TxnRecordID   :=StrToIntDef (SL[ 0],0);
        if SL.Count >  1 then TxnWSNumber   :=StrToIntDef (SL[ 1],0);
        if SL.Count >  2 then begin                   Val (SL[ 2],DT,Code); TxnDateTime:=DT; end;
        if SL.Count >  3 then TxnType       :=             SL[ 3];
        if SL.Count >  4 then TxnPeriod     :=StrToIntDef (SL[ 4],0);
        if SL.Count >  5 then TxnIndex      :=StrToIntDef (SL[ 5],0);
        if SL.Count >  6 then TxnOffice     :=StrToIntDef (SL[ 6],0);
        if SL.Count >  7 then TxnTeller     :=             SL[ 7];
        if SL.Count >  8 then TxnPLU        :=StrToIntDef (SL[ 8],0);
        if SL.Count >  9 then TxnProd       :=             SL[ 9];
        if SL.Count > 10 then TxnPrice      :=StrToCurrDef(SL[10],0);
        if SL.Count > 11 then TxnQuantity   :=StrToIntDef (SL[11],0);
        if SL.Count > 12 then TxnValue      :=StrToCurrDef(SL[12],0);
        if SL.Count > 13 then TxnDescription:=             SL[13];
        if SL.Count > 14 then TxnInfo       :=             SL[14];
        if SL.Count > 15 then TxnIdent      :=             SL[15];
        if SL.Count > 16 then TxnDomInfo    :=             SL[16];
     end;                         
  except                          
     // ??
  end;
  Result:=Add(OldTransaction);
  SL.Free;
end;
{TTxnTranslate}
constructor TTxnTranslate.Create;
begin
   if GetGPCSRegString('','System Name','Tanzania Post') = 'Tanzania Post' then
      FSystemIdentifier:=TanzaniaSystemIdentifier
   else
      FSystemIdentifier:=UndefinedSystemIdentifier;
end;
procedure CopyAdjData(TransactionLine:TTransactionLine;TxnBlock:TOldTransactions);
var
   Item,I:Integer;
   OldTxnDomInfoLines:TOldTxnDomInfoLines;
begin
   with TransactionLine do
   begin
      RecordID          :=TxnBlock[0].TxnRecordID   ;
      WSNumber          :=TxnBlock[0].TxnWSNumber   ;
      OfficeCode        :=TxnBlock[0].TxnOffice     ;
      AccountingPeriod  :=TxnBlock[0].TxnPeriod     ;
      TransactionType   :=TxnBlock[0].TxnType       ;
      DateTime          :=TxnBlock[0].TxnDateTime   ;
      Teller            :=TxnBlock[0].TxnTeller     ;
      ProgramID         :=TxnBlock[0].TxnProd       ;
      PLU               :=TxnBlock[0].TxnPLU        ;
      ItemPrice         :=TxnBlock[0].TxnPrice      ;
      ItemQuantity      :=TxnBlock[0].TxnQuantity   ;
      ItemValue         :=TxnBlock[0].TxnValue      ;
      Description       :=TxnBlock[0].TxnDescription;
      TxnIdent          :=TxnBlock[0].TxnIdent;
      ProgramVersion    :=1;
      for Item:=0 to TxnBlock.Count-1 do
      begin
         OldTxnDomInfoLines:=TOldTxnDomInfoLines.Create;
         OldTxnDomInfoLines.AddFromPackText(TxnBlock[Item].TxnDomInfo);
         for I:=0 to OldTxnDomInfoLines.Count-1 do // add as details
            AddDetail(TxnBlock[Item].FTxnProd,OldTxnDomInfoLines[I].Name,OldTxnDomInfoLines[I].Prompt,OldTxnDomInfoLines[I].Text,OldTxnDomInfoLines[I].Enabled,TxnBlock[Item].FTxnPLU);
         OldTxnDomInfoLines.Free;
      end;
   end;
end;
procedure CopyStdData(TransactionLine:TTransactionLine;TxnBlock:TOldTransactions);
var
   Item,I:Integer;
   OldTxnDomInfoLines:TOldTxnDomInfoLines;
begin                      
   with TransactionLine do
   begin
      RecordID          :=TxnBlock[0].TxnRecordID   ;
      WSNumber          :=TxnBlock[0].TxnWSNumber   ;
      OfficeCode        :=TxnBlock[0].TxnOffice     ;
      AccountingPeriod  :=TxnBlock[0].TxnPeriod     ;
      TransactionType   :=TxnBlock[0].TxnType       ;
      DateTime          :=TxnBlock[0].TxnDateTime   ;
      Teller            :=TxnBlock[0].TxnTeller     ;
      ProgramID         :=TxnBlock[0].TxnProd       ;
      PLU               :=TxnBlock[0].TxnPLU        ;
      ItemPrice         :=TxnBlock[0].TxnPrice      ;
      ItemQuantity      :=TxnBlock[0].TxnQuantity   ;
      ItemValue         :=TxnBlock[0].TxnValue      ;
      Description       :=TxnBlock[0].TxnDescription;
      TxnIdent          :=TxnBlock[0].TxnIdent;
      ProgramVersion    :=1;
      for Item:=0 to TxnBlock.Count-1 do
      begin
         OldTxnDomInfoLines:=TOldTxnDomInfoLines.Create;
         if TxnBlock[Item].TxnType = 'TxnLine' then // collect all data from txnlines
            OldTxnDomInfoLines.AddFromPackText(TxnBlock[Item].TxnDomInfo);
         for I:=0 to OldTxnDomInfoLines.Count-1 do // add as details
            AddDetail(TxnBlock[Item].FTxnProd,OldTxnDomInfoLines[I].Name,OldTxnDomInfoLines[I].Prompt,OldTxnDomInfoLines[I].Text,OldTxnDomInfoLines[I].Enabled,TxnBlock[Item].FTxnPLU);
         OldTxnDomInfoLines.Free;
      end;
   end;
end;
function TxStkFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
var
   TransactionLine:TTransactionLine;
begin
   Result:=False;
   TransactionLine:=TTransactionLine.Create;
   try
      with TransactionLine do
      begin
         CopyStdData(TransactionLine,TxnBlock);
         if TxnBlock[0].TxnType = 'TxStkTo' then
         begin
            AddDetail('','','Transfer To',TxnBlock[0].TxnIdent,False,0);
            AddDetail('','','Transfer From',Copy(TxnBlock[0].TxnInfo,2,Length(TxnBlock[0].TxnInfo)),False,0);
         end
         else
         begin
            AddDetail('','','Transfer From',TxnBlock[0].TxnIdent,False,0);
            AddDetail('','','Transfer To',Copy(TxnBlock[0].TxnInfo,2,Length(TxnBlock[0].TxnInfo)),False,0);
         end;
         ProcessedOK:='Y';
      end;
      TransactionLines.Add(TransactionLine);
      Result:=True;
   except
   end;
end;
function StockTxFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
var
   TransactionLine:TTransactionLine;
begin
   Result:=False;
   TransactionLine:=TTransactionLine.Create;
   try
      with TransactionLine do
      begin
         CopyStdData(TransactionLine,TxnBlock);
         if TxnBlock[0].TxnIdent[1] = '<' then
         begin
            if TxnBlock[0].TxnQuantity < 0 then
               AddDetail('','','Complete Transfer From',Copy(TxnBlock[0].TxnIdent,2,Length(TxnBlock[0].TxnIdent)),False,0)
            else         
               AddDetail('','','Pending Transfer From' ,Copy(TxnBlock[0].TxnIdent,2,Length(TxnBlock[0].TxnIdent)),False,0);
         end
         else
         begin
            if TxnBlock[0].TxnQuantity < 0 then
               AddDetail('','','Complete Transfer To'  ,Copy(TxnBlock[0].TxnIdent,2,Length(TxnBlock[0].TxnIdent)),False,0)
            else
               AddDetail('','','Pending Transfer To'   ,Copy(TxnBlock[0].TxnIdent,2,Length(TxnBlock[0].TxnIdent)),False,0);
         end;
         ProcessedOK:='Y';
      end;
      TransactionLines.Add(TransactionLine);
      Result:=True;
   except
   end;
end;
function StartDayFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
var
   TransactionLine:TTransactionLine;
begin
   Result:=False;
   TransactionLine:=TTransactionLine.Create;
   try
      with TransactionLine do
      begin
         CopyStdData(TransactionLine,TxnBlock);
         if TxnBlock.Count > 1 then
         begin
            PLU               :=TxnBlock[1].TxnPLU        ; // PLU from TxnTotal
            Description       :=TxnBlock[1].TxnDescription; // Description from TxnTotal
            AddDetail('','','Start Day Cash' ,TxnBlock[1].TxnPrice,False,0); // Start Day Cash from TxnTotal
            AddDetail('','','Start Day Stock',TxnBlock[1].TxnValue,False,0); // Start Day Stock from TxnTotal
         end;
         ProcessedOK:='Y';
      end;
      TransactionLines.Add(TransactionLine);
      Result:=True;
   except
   end;
end;
function CashAccAdj(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
var
   TransactionLine:TTransactionLine;
begin
   Result:=False;
   TransactionLine:=TTransactionLine.Create;
   try
      with TransactionLine do
      begin
         CopyAdjData(TransactionLine,TxnBlock);
         ProcessedOK:='Y';
      end;
      TransactionLines.Add(TransactionLine);
      Result:=True;
   except
   end;
end;
function PrLabelFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
var
   TransactionLine:TTransactionLine;
begin
   Result:=False;
   TransactionLine:=TTransactionLine.Create;
   try
      with TransactionLine do
      begin
         CopyStdData(TransactionLine,TxnBlock);
         AddDetail('','','GUID',TxnBlock[0].FTxnInfo,False,0);
         ProcessedOK:='Y';
      end;
      TransactionLines.Add(TransactionLine);
      Result:=True;
   except
   end;
end;
function EndDayFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
var
   TransactionLine:TTransactionLine;
begin
   Result:=False;
   TransactionLine:=TTransactionLine.Create;
   try
      with TransactionLine do
      begin
         CopyStdData(TransactionLine,TxnBlock);
         AddDetail('','','End Day Cash' ,TxnBlock[0].TxnValue,False,0);
         AddDetail('','','End Day Stock',TxnBlock[0].TxnPrice,False,0);
         ProcessedOK:='Y';
      end;
      TransactionLines.Add(TransactionLine);
      Result:=True;
   except
   end;
end;
function SimpleMailFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
var
   TransactionLine:TTransactionLine;
   PrePaidStamp:TOldTransaction;
   I:Integer;
begin
   Result:=False;
   PrePaidStamp:=nil;
   for I:=0 to TxnBlock.Count-1 do
   begin
      if TxnBlock[I].TxnProd = 'Product.PrePaidStamp' then
      begin
         PrePaidStamp:=TxnBlock[I];
         break;
      end;
   end;
   TransactionLine:=TTransactionLine.Create;
   try
      with TransactionLine do
      begin
         CopyStdData(TransactionLine,TxnBlock);
         AddDetail('','','Weight',TxnBlock[0].TxnInfo,False,0);
         if PrePaidStamp <> nil then AddDetail('','','Pre-Paid Stamps',PrePaidStamp.TxnPrice,False,0);
         ProcessedOK:='Y';
      end;                              
      TransactionLines.Add(TransactionLine);
      Result:=True;
   except
   end;
end;
{
WeightWeight240Enter the WeightEnter a Valid WeightRange(0,50000)
EMSCountryZoneCountryBelizePlease Select a Country by Pressing EnterPlease Select a CountryAfghanistanAlbaniaZimbabwe
EMSIdentifierEMSIdentifierEE00001111XTZEnter the EMS IdentifierEnter a Valid EMS Identifier^in the format EE99999999XTZMask(EU99999999XTZ)
MIQuantityMailItemQuantity1Enter the Mail Item QuantityEnter the Mail Item QuantityRange(0,9999)
StandardFeeStandardFee24,000.00()Product.IntEMSPar
TotalFeeTotalFee24,000.00()TotalField
}

                                                                     
function LookUp(Country:String):String;                              
begin                                                                
        if Country = 'Afghanistan'		           then Result:='AF'
   else if Country = 'Albania'			           then Result:='AL'
   else if Country = 'Angola'				           then Result:='AO'
   else if Country = 'Argentina'		              then Result:='AR'
   else if Country = 'Australia'		              then Result:='AU'
   else if Country = 'Austria'			           then Result:='AT'
   else if Country = 'Bahrain'			           then Result:='BH'
   else if Country = 'Bangladesh'		           then Result:='BD'
   else if Country = 'Belgium'				        then Result:='BE'
   else if Country = 'Belize'				           then Result:='BZ'
   else if Country = 'Benin'	   		           then Result:='BJ'
   else if Country = 'Bolivia'	   		        then Result:='BO'
   else if Country = 'Botswana'   		           then Result:='BW'
   else if Country = 'Brazaville'			        then Result:='CG'
   else if Country = 'Brazil'			              then Result:='BR'
   else if Country = 'Brunei'			              then Result:='BN'
   else if Country = 'Bulgaria'   		           then Result:='BG'
   else if Country = 'Burkina Faso'	              then Result:='BF'
   else if Country = 'Burundi'			           then Result:='BR'
   else if Country = 'C.I.S.'			              then Result:='RU'
   else if Country = 'Cambodia'                   then Result:='KH'	
   else if Country = 'Cameroon'                   then Result:='CM'	
   else if Country = 'Canada'			              then Result:='CA'
   else if Country = 'Chad'	                    then Result:='TD'
   else if Country = 'Channel Isles'              then Result:='GB'
   else if Country = 'Chile'	                    then Result:='CL'
   else if Country = 'China'	                    then Result:='CN'
   else if Country = 'Colombia'                   then Result:='CO'
   else if Country = 'Comoros'                    then Result:='KM'
   else if Country = 'Congo Ct. Afr. Rep.'        then Result:='CG'
   else if Country = 'Congo Dem. Rep.'            then Result:='CD'
   else if Country = 'Costa Rica'                 then Result:='CR'
   else if Country = 'Croatia'	                 then Result:='HR'
   else if Country = 'Cuba'	                    then Result:='CU'
   else if Country = 'Cyprus'	                    then Result:='CY'
   else if Country = 'Czech.Rep'                  then Result:='CZ'
   else if Country = 'Denmark'	                 then Result:='DK'
   else if Country = 'Djibouti'                   then Result:='DJ'
   else if Country = 'Egypt'                      then Result:='EG'
   else if Country = 'Ethiopia'                   then Result:='ET'
   else if Country = 'Finland'                    then Result:='FI'
   else if Country = 'France'	                    then Result:='FR'
   else if Country = 'Gabon'	                    then Result:='GA'
   else if Country = 'Gambia'                     then Result:='GM'
   else if Country = 'Germany'	                 then Result:='DE'
   else if Country = 'Ghana'	                    then Result:='GH'
   else if Country = 'Greece'                     then Result:='GR'
   else if Country = 'Guatemala'                  then Result:='GT'
   else if Country = 'Guinea Bissau'              then Result:='GW'
   else if Country = 'Haiti'                      then Result:='HT'
   else if Country = 'Honduras'                   then Result:='HN'
   else if Country = 'HongKong'                   then Result:='HK'
   else if Country = 'Honkongo'                   then Result:='HK'
   else if Country = 'Hungary'                    then Result:='HU'
   else if Country = 'India'	                    then Result:='IN'
   else if Country = 'Indonesia'                  then Result:='ID'
   else if Country = 'Iran'                       then Result:='IR'
   else if Country = 'Iraq'                       then Result:='IQ'
   else if Country = 'Ireland'                    then Result:='IE'
   else if Country = 'Israel'                     then Result:='IL'
   else if Country = 'Italy'                      then Result:='IT'
   else if Country = 'Ivory Coast'                then Result:='CI'
   else if Country = 'Jamaica'	                 then Result:='JM'
   else if Country = 'Japan'	                    then Result:='JP'
   else if Country = 'Jordan'                     then Result:='JO'
   else if Country = 'Kenya'                      then Result:='KE'
   else if Country = 'Korea'	                    then Result:='KR'
   else if Country = 'Kuwait'                     then Result:='KW'
   else if Country = 'Lebanon'                    then Result:='LB'
   else if Country = 'Leichtstein'                then Result:='LI'
   else if Country = 'Liberia'	                 then Result:='LR'
   else if Country = 'Libya'		                 then Result:='LY'
   else if Country = 'Lithuania'                  then Result:='LT'
   else if Country = 'London'                     then Result:='GB'
   else if Country = 'Luxembourg'                 then Result:='LU'
   else if Country = 'Madagascar'                 then Result:='MG'
   else if Country = 'Malawi'                     then Result:='MW'
   else if Country = 'Malaysia'                   then Result:='MY'
   else if Country = 'Mali'	                    then Result:='ML'
   else if Country = 'Malta'	                    then Result:='MT'
   else if Country = 'Mauritania'                 then Result:='MR'
   else if Country = 'Mauritius'                  then Result:='MU'
   else if Country = 'Mexico'	                    then Result:='MX'
   else if Country = 'Monaco'                     then Result:='MC'
   else if Country = 'Morocco'                    then Result:='MA'
   else if Country = 'Mozambique'                 then Result:='MZ'
   else if Country = 'Namibia'                    then Result:='NA'
   else if Country = 'Nepal'                      then Result:='NP'
   else if Country = 'Netherlands'                then Result:='NL'
   else if Country = 'New Zealand'                then Result:='NZ'
   else if Country = 'Nicaragua'                  then Result:='NI'
   else if Country = 'Niger'                      then Result:='NI'
   else if Country = 'Nigeria'                    then Result:='NG'
   else if Country = 'Norway'                     then Result:='NO'
   else if Country = 'Oman'                       then Result:='OM'
   else if Country = 'Pakistan'                   then Result:='PK'
   else if Country = 'Paraguay'                   then Result:='PY'
   else if Country = 'Peru'	                    then Result:='PE'
   else if Country = 'Poland'	                    then Result:='PL'
   else if Country = 'Portugal'                   then Result:='PT'
   else if Country = 'Qatar'                      then Result:='QA'
   else if Country = 'Romania'                    then Result:='RO'
   else if Country = 'Russia'                     then Result:='RU'
   else if Country = 'Rwanda'                     then Result:='RW'
   else if Country = 'Saudi Arabia'               then Result:='SA'
   else if Country = 'Seychelles'                 then Result:='SC'
   else if Country = 'Siera Lione'                then Result:='SL'
   else if Country = 'Singapore'                  then Result:='SG'
   else if Country = 'Somalia'	                 then Result:='SO'
   else if Country = 'SouthAfrica'                then Result:='ZA'
   else if Country = 'Spain'		                 then Result:='ES'
   else if Country = 'SriLanka'                   then Result:='LK'
   else if Country = 'Sudan'	                    then Result:='SD'
   else if Country = 'Surinam'                    then Result:='SR'
   else if Country = 'Swaziland'                  then Result:='SZ'
   else if Country = 'Sweden'	                    then Result:='SE'
   else if Country = 'Switzeland'                 then Result:='CH'
   else if Country = 'Syria'	                    then Result:='SY'
   else if Country = 'Taiwan'                     then Result:='TW'
   else if Country = 'Thailand'                   then Result:='TH'
   else if Country = 'Togo'		                 then Result:='TG'
   else if Country = 'Tongo'	                    then Result:='TO'	
   else if Country = 'Tunisia'	                 then Result:='TN'
   else if Country = 'Turkey'	                    then Result:='TR'
   else if Country = 'Uganda'                     then Result:='UG'
   else if Country = 'Ukraine'	                 then Result:='UA'
   else if Country = 'United Arab Emirates'       then Result:='AE'
   else if Country = 'United Kingdom(not London)' then Result:='GB'
   else if Country = 'United States of America'   then Result:='US'
   else if Country = 'Uruguay'                    then Result:='UY'
   else if Country = 'US.Virgia'                  then Result:='VI'
   else if Country = 'Venezuela'                  then Result:='VE'
   else if Country = 'Yemen'	                    then Result:='YE'
   else if Country = 'Yugolslavia'                then Result:='YU'
   else if Country = 'Yugoslavia'	              then Result:='YU'
   else if Country = 'Zambia'		                 then Result:='ZM'
   else if Country = 'Zimbabwe'	                 then Result:='ZW'
   else Result:='ZZ';
end;
function IsNumber(ID:String):Boolean;
var
  I:Integer;
begin
   Result:=False;
   if Length(ID) > 8 then Exit; // Greater than can be held in an integer
   for I:=1 to Length(ID) do
      if not (ID[I] in ['0'..'9']) then Exit;
   Result:=True;
end;
function CalcIDRange(ID:String;Count:Integer):String;
var
   StartStr:String;
   EndStr:String;
   ValueStr:String;
   Value:Integer;
   WithCRC:Boolean;
begin
   Result:=ID;
   if Count < 1 then Exit;
   if IsNumber( ID ) then
   begin
      Value:=StrToIntDef(ID,0);
      Inc(Value,Count);
      Result:=LeftPad(IntToStr(Value),Length(ID),'0');
   end
   else if (Length(ID) = 13) then
   begin
      StartStr:=Copy(ID,1,2);
      EndStr  :=Copy(ID,12,2);
      ValueStr:=Copy(ID,3,8);
      WithCRC :=UpperCase(Copy(ID,11,1)) <> 'X';
      Value:=StrToIntDef(ValueStr,0);
      Inc(Value,Count);
      ValueStr:=LeftPad(IntToStr(Value),8,'0');
      if not withCRC then
      begin
         Result:=StartStr+ValueStr+'X'+EndStr;
      end
      else
      begin
         Result:=StartStr+ValueStr+Mod11(Value)+EndStr;
      end;
   end;
end;

procedure PostToIPS(TransactionLine:TTransactionLine);
var
   SL:TStringList;
   I:Integer;
   Weight:String;
   Dest:String;
   MType:String;
   ID:String;
   ItemCount:Integer;
const 
    Testing = False;
begin
   SL:=TStringList.Create;
   try
      ItemCount:=1;
      if IPSFileName = '' then
         IPSFileName:='C:\IPS_'+FormatDateTime('yyyymmddhhnn',Now)+'.DAT';
      if FileExists(IPSFileName) then
      begin
         SL.LoadFromFile(IPSFileName);
      end
      else
      begin
         SL.Add('GENERATED_BY: ''Tanzania Post Corporation (CORVUS-PSL)''');
         SL.Add('VERSION:      0303');
         SL.Add('DATE:        '+FormatDateTime('dd/mm/yyyy-hh:nn:ss',Now));
         SL.Add('OFFICE:      ''Dar es Salaam GPO''');
         if Testing then
            SL.Add('WORKSTATION: ''RSCEASRV''')
         else
            SL.Add('WORKSTATION: ''TZDARASRV''');
         SL.Add('USER:        ''AUTO''');
         SL.Add('');
      end;
      if TransactionLine.PLU = 70000008 then MType:='D' else MType:='M';
      for I:=0 to TransactionLine.Count-1 do
      begin
              if TransactionLine[I].Name = 'Weight' then
         begin
            Weight:=Trim(TransactionLine[I].Value);
            if Weight[Length(Weight)] = 'g' then
               Weight:=Copy(Weight,1,Length(Weight)-2);
            Weight:=LeftPad(Weight,5,'0');
         end
         else if TransactionLine[I].Name = 'ZoneCountry' then
            Dest:=LookUp(TransactionLine[I].Value)
         else if TransactionLine[I].Name = 'EMSIdentifier' then
            ID:=TransactionLine[I].Value
         else if TransactionLine[I].Name = 'MailItemQuantity' then
            ItemCount:=StrToIntDef(TransactionLine[I].Value,0);
      end;
      if ItemCount < 1 then ItemCount:=1;
   
      for I:=0 to ItemCount-1 do
      begin   
         SL.Add('{'+CalcIDRange(ID,I));
         SL.Add('LOCATION:      TN601');
         SL.Add('LODGING_POINT: ''TZDARA''');
         SL.Add('LODGING_DATE:  '+FormatDateTime('dd/mm/yyyy-hh:nn:ss',Now));
         SL.Add('MAIL_CLASS:    '+ID[1]);
         SL.Add('WEIGHT:        '+Weight);
         SL.Add('DEST_COUNTRY:  '+Dest);
         SL.Add('MAIL_CONTENT:  '+MType);
         SL.Add('OFFICE:        ''TZDARA'''); // look up office code!
         if Testing then
            SL.Add('WORKSTATION:   ''RSCEASRV''')
         else
            SL.Add('WORKSTATION:   ''TZDARASRV''');
         SL.Add('USER:          '''+TransactionLine.Teller+'''');
         SL.Add('EVENT_DATE:    '+FormatDateTime('dd/mm/yyyy-hh:nn:ss',TransactionLine.DateTime));
         SL.Add('}');
         SL.Add('');
      end;
   except
      // error processing IPS data
   end;
   SL.SaveToFile(IPSFileName);
   SL.Free;
end;
function EMSMailFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
var
   TransactionLine   :TTransactionLine;
   AdviceOfDel   :TOldTransaction;
   I:Integer;
begin   
   Result:=False;                   
   AdviceOfDel   :=nil;
   for I:=0 to TxnBlock.Count-1 do
   begin
      if TxnBlock[I].TxnPLU = 80000008 then
         AdviceOfDel   :=TxnBlock[I];
   end;
   TransactionLine:=TTransactionLine.Create;
   try
      with TransactionLine do
      begin
         CopyStdData(TransactionLine,TxnBlock);
         AddDetail('','','Weight',TxnBlock[0].TxnInfo,False,0);
         if AdviceOfDel <> nil then AddDetail('','','Advice Of Delivery',AdviceOfDel.TxnPrice,False,0);
         PostToIPS(TransactionLine);
         ProcessedOK:='Y';
      end;
      TransactionLines.Add(TransactionLine);
      Result:=True;
   except
   end;
end;

function RegMailFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
var
   TransactionLine   :TTransactionLine;
   PrePaidStamp  :TOldTransaction;
   Registration  :TOldTransaction;
   RegistrationID:TOldTransaction;
   AdviceOfDel   :TOldTransaction;
   I:Integer;
begin   
   Result:=False;
   PrePaidStamp  :=nil;
   Registration  :=nil;
   RegistrationID:=nil;
   AdviceOfDel   :=nil;
   for I:=0 to TxnBlock.Count-1 do
   begin
      if TxnBlock[I].TxnProd = 'Product.PrePaidStamp' then
         PrePaidStamp  :=TxnBlock[I]
      else if TxnBlock[I].TxnDescription = 'Registration' then
         Registration  :=TxnBlock[I]
      else if Copy(TxnBlock[I].TxnDescription,1,4) = 'ID =' then
         RegistrationID:=TxnBlock[I]
      else if TxnBlock[I].TxnProd = 'Product.AdviceDelive' then
         AdviceOfDel   :=TxnBlock[I];
   end;
   TransactionLine:=TTransactionLine.Create;
   try
      with TransactionLine do
      begin
         CopyStdData(TransactionLine,TxnBlock);
         AddDetail('','','Weight',TxnBlock[0].TxnInfo,False,0);
         if PrePaidStamp   <> nil then AddDetail('','','Pre-Paid Stamps'   ,PrePaidStamp.TxnPrice,False,0);
         if Registration   <> nil then AddDetail('','','Registration'      ,Registration.TxnPrice,False,0);
         if RegistrationID <> nil then AddDetail('','','Registration ID'   ,RegistrationID.TxnInfo,False,0);
         if AdviceOfDel    <> nil then AddDetail('','','Advice Of Delivery',AdviceOfDel.TxnPrice,False,0);
         PostToIPS(TransactionLine);
         ProcessedOK:='Y';          
      end;                              
      TransactionLines.Add(TransactionLine);
      Result:=True;
   except
   end;
end;
function MOIssueFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
var
   TransactionLine:TTransactionLine;
//   OldTxnDomInfoLines:TOldTxnDomInfoLines;
//   I,Item:Integer;
begin
   Result:=False;
//   OldTxnDomInfoLines:=TOldTxnDomInfoLines.Create;
   TransactionLine:=TTransactionLine.Create;
   try
      with TransactionLine do                              
      begin
         CopyStdData(TransactionLine,TxnBlock);
//       for Item:=0 to TxnBlock.Count-1 do
//       if TxnBlock[0].TxnType = 'TxStkTo' then
      end;
   except
   end;



//   if (TxnBlock[0].TxnProd = 'MOPaid') and (ProgID = 'MOPaid Complete') then // Pay Money Order
//   begin
//      MoneyOrders:=TMoneyOrders.Create(False);
//      MoneyOrders.Office:=StrToIntDef(Office,0);
//      MoneyOrders.Clerk:=GetUserNumber(Teller);
//      MoneyOrders.PayMO(Description,2001,0,'',CanProcess,0,True);
//      if not CanProcess then
//      begin
//         RaiseGUIDError('{6B8C2127-A8A7-470F-A436-F575E8213397}','Can''t Pay Money Order No. '+Description);
//         if GetGPCSRegString('Indigo3','Allow Clerk Re-Pay Money Order','No') = 'Yes' then
//            MoneyOrders.ForcePayMO(Description,2001,0,'',' by '+Teller,0);
//      end;
//      MoneyOrders.Free;
//   end
//   else if (TxnType = 'MFIssue') or (TxnType = 'MOIssue') then // Issue Money Order
//   begin
//      MoneyOrders:=TMoneyOrders.Create(False);
//      MoneyOrders.Office:=StrToIntDef(Office,0);
//      MoneyOrders.Clerk:=GetUserNumber(Teller);
//      TxnDomInfoLines:=TTxnDomInfoLines.Create;
//      TxnDomInfoLines.AddFromPackText(DomInfo);
//      Sender:=TPersonDetails.Create(nil);
//      Payee :=TPersonDetails.Create(nil);
//      if TxnDomInfoLines.Count > 0 then
//      begin
//         RContact1:='';
//         RContact2:='';
//         Information:='';
//         for J:=0 to TxnDomInfoLines.Count-1 do
//         begin
//            if TxnDomInfoLines[J].Name = 'SendersSearchName'     then
//               Sender.SearchName:=TxnDomInfoLines[J].Text
//            else if TxnDomInfoLines[J].Name = 'SendersOtherNames'     then
//               Sender.AddName1:=TxnDomInfoLines[J].Text
//            else if TxnDomInfoLines[J].Name = 'SendersTelephone' then
//               Sender.AddressLine3:=TxnDomInfoLines[J].Text
//            else if TxnDomInfoLines[J].Name = 'SendersPOBox'     then
//               Sender.AddressLine4:=TxnDomInfoLines[J].Text
//            else if TxnDomInfoLines[J].Name = 'SendersAddress'    then   
//               Sender.AddressLine1:=TxnDomInfoLines[J].Text
//            else if TxnDomInfoLines[J].Name = 'SendersMessage'   then   
//               Information:=TxnDomInfoLines[J].Text
//            else if TxnDomInfoLines[J].Name = 'PayeesSearchName' then
//               Payee.SearchName:=TxnDomInfoLines[J].Text
//            else if TxnDomInfoLines[J].Name = 'PayeesOtherNames'     then
//               Payee.AddName1:=TxnDomInfoLines[J].Text
//            else if TxnDomInfoLines[J].Name = 'PayeesTelephone'  then
//               RContact1:=TxnDomInfoLines[J].Text
//            else if TxnDomInfoLines[J].Name = 'PayeesPOBox'      then
//               RContact2:=TxnDomInfoLines[J].Text
//            else if TxnDomInfoLines[J].Name = 'PayeesAddress'    then   
//               Payee.AddressLine1:=TxnDomInfoLines[J].Text
//         end;
//      end;
//      TxnDomInfoLines.Free;
//      if TxnType = 'MFIssue' then
//         MoneyOrders.ForceIssueMO(Description,2001,Price,Value,0,'FAX',Quantity,Now+180,StrToIntDef(Additional,0),Sender,Payee,Information,CanProcess,0,RContact1,RContact2)
//      else
//         MoneyOrders.ForceIssueMO(Description,2001,Price,Value,0,'EXP',Quantity,Now+180,StrToIntDef(Additional,0),Sender,Payee,Information,CanProcess,0,RContact1,RContact2);
//      Sender.Free;
//      Payee .Free;
//      if not CanProcess then
//         RaiseGUIDError('{370C4EF5-A7EB-452E-AEC1-1C0DC51EA706}','Can''t Issue Money Order No. '+Description);
//      MoneyOrders.Free;
//   end
//   else if ((TxnType = 'MOPaid') and (ProgID = 'MOPaid Complete')) or
//           ((TxnType = 'MFPaid') and (ProgID = 'MFPaid Complete')) then // Pay Money Order
//   begin
//      MoneyOrders:=TMoneyOrders.Create(False);
//      MoneyOrders.Office:=StrToIntDef(Office,0);
//      MoneyOrders.Clerk:=GetUserNumber(Teller);
//      MoneyOrders.PayMO(Description,2001,0,'',CanProcess,0,True);
//      if not CanProcess then
//      begin
//         RaiseGUIDError('{6B8C2127-A8A7-470F-A436-F575E8213397}','Can''t Pay Money Order No. '+Description);
//         if GetGPCSRegString('Indigo3','Allow Clerk Re-Pay Money Order','No') = 'Yes' then
//            MoneyOrders.ForcePayMO(Description,2001,0,'',' by '+Teller,0);
//      end;
//      MoneyOrders.Free;
//   end
//   else if TxnType = 'MOIInfo' then // Issue Money Order
//   begin
//      MOItem:=TMOIssued.Create(nil);
//      MOItem.AsString:=DomInfo;
//      MoneyOrders:=TMoneyOrders.Create(False);
//      MoneyOrders.Office:=MOItem.IssuingOffice;
//      MoneyOrders.Clerk:=GetUserNumber(Teller);
//
//      Sender:=TPersonDetails.Create(nil);
//      Sender.PName:=MOItem.SendersName;
//      Sender.PAddress:=MOItem.SendersAddress;
//
//      Payee:=TPersonDetails.Create(nil);
//      Payee .PName:=MOItem.RecipientsName;
//      Payee .PAddress:=MOItem.RecipientsAddress;
//
//      MoneyOrders.ForceIssueMO(MOItem.Identifier,MOItem.IssueNumber,MOItem.Value,MOItem.Commission,MOItem.Tax,MOItem.SSIndicator,MOItem.SSFee,MOItem.PayByDateTime,MOItem.PayingOffice,Sender,Payee,MOItem.Information,CanProcess,MOItem.DateTime,MOItem.RContact1,MOItem.RContact2);
//      Sender.Free;
//      Payee.Free;
//      if not CanProcess then
//         RaiseGUIDError('{5977550C-2710-4D5C-A064-6D4054D9AC91}','Can''t Issue Money Order No. '+Description);
//      MOItem.Free;
//      MoneyOrders.Free;
//   end;
end;
function SimpleFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
var
   TransactionLine:TTransactionLine;
begin
   Result:=False;
   TransactionLine:=TTransactionLine.Create;
   try
      CopyStdData(TransactionLine,TxnBlock);
      TransactionLine.ProcessedOK:='Y';
      TransactionLines.Add(TransactionLine);
      Result:=True;
   except
   end;
end;
function DefaultTranslateFunc(TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
var
   ProgID:String;
begin
   Result:=False;                                           
   // no lines or block doesn't end in a TxnTotal.
//   if (TxnBlock.Count <= 0) or ((TxnBlock[TxnBlock.Count-1].TxnType <> 'TxnTotal') and (TxnBlock[TxnBlock.Count-1].TxnType <> 'StockTx')) then Exit;
   
   try
      if TxnBlock[0].TxnType = 'StartDay' then
      begin
         Result:=StartDayFunc(TxnBlock,TransactionLines); // process Start of Day Function
      end
      else if TxnBlock[0].TxnType = 'PrLabel' then
      begin
         Result:=PrLabelFunc(TxnBlock,TransactionLines); // process PrLabel Function
      end
      else if TxnBlock[0].TxnType = 'CashAccAdj' then
      begin
         Result:=CashAccAdj(TxnBlock,TransactionLines); // process PrLabel Function
      end
      else if TxnBlock[0].TxnType = 'EndDay' then
      begin
         Result:=EndDayFunc(TxnBlock,TransactionLines); // process Start of Day Function
      end
      else if TxnBlock[0].TxnType = 'StockTx' then
      begin
         Result:=StockTxFunc(TxnBlock,TransactionLines); // process Start of Day Function
      end
      else if (TxnBlock[0].TxnType = 'TxStkFrom') or
              (TxnBlock[0].TxnType = 'TxStkTo'  ) then
      begin
         Result:=TxStkFunc(TxnBlock,TransactionLines); // process Start of Day Function
      end
      else if TxnBlock[0].TxnType = 'TxnLine' then
      begin
         ProgID:=TxnBlock[0].TxnProd;
         
         Result:=SimpleFunc(TxnBlock,TransactionLines);    // default one line processing 
      end
      else if TxnBlock[0].TxnType = 'MFIssue' then
         Result:=MOIssueFunc(TxnBlock,TransactionLines)
      else if TxnBlock[0].TxnType = 'MFPaid' then
         Result:=MOIssueFunc(TxnBlock,TransactionLines)
      else if TxnBlock[0].TxnType = 'MOIssue' then
         Result:=MOIssueFunc(TxnBlock,TransactionLines)
      else if TxnBlock[0].TxnType = 'MOPaid' then
         Result:=MOIssueFunc(TxnBlock,TransactionLines)
      else if TxnBlock[0].TxnType = 'MOIInfo' then
         Result:=MOIssueFunc(TxnBlock,TransactionLines)
      else
         Result:=SimpleFunc(TxnBlock,TransactionLines);    // default one line processing 
   except
   end;
end;
class function TTxnTranslate.AddGroup(SystemIdentifier:String;TxnBlock:TOldTransactions;TransactionLines:TTransactionLines):Boolean;
const
   CountryDLL:String = '';
   HModule:Integer = 0;
 //  ApplyDefaultAction = True;
var
   TranslateFunc:TTranslateFunc;
   ApplyDefaultAction:Boolean;
begin
   ApplyDefaultAction:=GetGPCSRegString('','DefaultTranslate','1') = '1';
   if ApplyDefaultAction then
   begin
      Result:=DefaultTranslateFunc(TxnBlock,TransactionLines);
      Exit;
   end;

   Result:=False;
   if CountryDLL <> SystemIdentifier then
   begin
      try
         if HModule <> 0 then
         begin
            if FreeLibrary(HModule) then
              HModule:=0;
         end;
      except
         // error in free lib
      end;
      if HModule = 0 then
      try
         HModule:=LoadLibrary(PChar(SystemIdentifier));
      except
         HModule:=0; // error loading lib
   	   // On E : Exception do
      end;
      CountryDLL:=SystemIdentifier;
   end;

   if HModule <> 0 then
   begin
      try
         @TranslateFunc:=GetProcAddress(HModule,'TranslateTxns');
         if @TranslateFunc <> nil then
            Result:=TranslateFunc(TxnBlock,TransactionLines);
//         else
//             // error no func
      except
         // error using lib
      end;
   end;
end;
function TransactionSortFunc(Item1,Item2:Pointer):Integer;
var
  TxnLine1,TxnLine2:TOldTransaction;
begin
   TxnLine1:=TOldTransaction(Item1);
   TxnLine2:=TOldTransaction(Item2);
   Result:=TxnLine1.TxnWSNumber-TxnLine2.TxnWSNumber; // order by WSNumber
   if Result = 0 then // same WSNumber so order by RecordID
      Result:=TxnLine1.TxnRecordID-TxnLine2.TxnRecordID;
end;
class function TTxnTranslate.TranslateFor(SystemIdentifier,OldTxnStrings:String):TTransactionLines;
var
   OldTxns:TPackStringList;
   I:Integer;
   OldTransactions:TOldTransactions;
   TransactionBlock:TOldTransactions;
   SimpleTransactionBlock:TOldTransactions;
   IPSShare:String;
begin
   Result:=nil;
   IPSFileName:='';
   if SystemIdentifier = UndefinedSystemIdentifier then Exit;
   Result:=TTransactionLines.Create;;
   OldTxns:=TPackStringList.Create;
   OldTxns.PackText:=OldTxnStrings;
   OldTransactions:=TOldTransactions.Create;
   for I:=0 to OldTxns.Count-1 do
      OldTransactions.AddFromPackText(OldTxns[I]);
   OldTxns.Free;
   OldTransactions.Sort(TransactionSortFunc);
   
   TransactionBlock:=TOldTransactions.Create;
   SimpleTransactionBlock:=TOldTransactions.Create;
   for I:=0 to OldTransactions.Count-1 do
   begin
      if Pos(' '+OldTransactions[I].TxnType+' ',' TxnLine StartDay ') <> 0 then
      begin
         TransactionBlock.Add(OldTransactions[I]);
      end
      else 
      begin
         if OldTransactions[I].TxnType = 'TxnTotal' then
         begin
            if TransactionBlock.Count > 0 then
            begin
               TransactionBlock.Add(OldTransactions[I]);
               AddGroup(SystemIdentifier,TransactionBlock,Result);
            end;
            TransactionBlock.Clear;
         end
         else
         begin
            if OldTransactions[I].TxnType = 'ExtraTxnLine' then
               OldTransactions[I].TxnType:='TxnLine';
            SimpleTransactionBlock.Add(OldTransactions[I]);
            AddGroup(SystemIdentifier,SimpleTransactionBlock,Result);
            SimpleTransactionBlock.Clear;
         end;                         
      end;
   end;
   SimpleTransactionBlock.Free;
   TransactionBlock.Free;
   OldTransactions.Free;
   if IPSFileName <> '' then
   begin
      IPSShare:=GetGPCSRegString('IPS','Share Name','\\Rsceasrv\IPS Input');
      IPSShare:='D:';
      CopyFile(PChar(IPSFileName),PChar(IPSShare+'\'+ExtractFileName(IPSFileName)),True);
      IPSFileName:='';
   end;
end;
function TTxnTranslate.TranslateTransaction(OldTxnStrings:String):TTransactionLines;
begin
   Result:=nil;
   if FSystemIdentifier = UndefinedSystemIdentifier then Exit;
   Result:=TranslateFor(FSystemIdentifier,OldTxnStrings);
end;    
class function TTxnTranslate.GetMsgStoreData(FromPeriod,ToPeriod:Integer;User:String;Office,Workstation:Integer;RequiredTxnTypes:String):TTransactionLines;
var
   FileStatusMon:TFileStatusMon;
   Status:TStatusBits;
   WSIdx,I:Integer;
   OfficeCode:Integer;
   WSNumber  :Integer;
   Flags,TxnLineIdx:Integer;
   MessageData:TMessageAccess;
   TxnLine:TTxnLogLine;
   TxnLines:TTxnLogLines;
   OldTxnStrings:TPackStringList;
   MainPLU:Integer;
begin
   if User = 'All' then User:='';
   OldTxnStrings:=TPackStringList.Create;
   TxnLines:=TTxnLogLines.Create;
   TxnLine:=TTxnLogLine.Create;   
   FileStatusMon:=TFileStatusMon.Create(nil);
   FileStatusMon.Active:=False;
   Status:=TStatusBits.Create;
   Status.State:=FileStatusMon.FileBlockMgr.GetStatus;
   for WSIdx:=0 to Status.Count-1 do
   begin
      OfficeCode:=Status.OfficeCode(WSIdx);
      WSNumber  :=Status.WSNumber(WSIdx);
      for I:=0 to Status.Size(OfficeCode,WSNumber) do
      begin
         Flags:=FileStatusMon.FileBlockMgr.GetMessageFlags(OfficeCode,WSNumber,I);
         if ((Flags and MessageHasGoodCRC) <> 0)
         and ((Flags and TransactionMsg) <> 0) then
         begin
            MessageData:=FileStatusMon.FileBlockMgr.GetMessage(OfficeCode,WSNumber,I);
            if MessageData <> nil then
            begin
               TxnLines.PackText:=MessageData.MessageData;
               // seperate each line of a customer session
               if TxnLines.Count > 0 then
               begin
                  TxnLine.PackText:=TxnLines[0];
                  if  ((FromPeriod = 0 ) or (TxnLine.Period >= FromPeriod))
                  and ((ToPeriod   = 0 ) or (TxnLine.Period <= ToPeriod  ))
                  and ((Office     = 0 ) or (TxnLine.Office = Office     ))
                  and ((User       = '') or (TxnLine.Teller = User       )) then
                  begin
                     MainPLU:=99999999;
                     for TxnLineIdx:=0 to TxnLines.Count-1 do
                     begin
                        TxnLine.PackText:=TxnLines[TxnLineIdx];
                        if (TxnLine.RecIndex = 0) then
                           MainPLU:=TxnLine.PLU;
                        if Pos(TxnLine.RecType,RequiredTxnTypes) > 0 then
                        begin
                           if ((TxnLine.RecType = 'TxnLine') and ((TxnLine.DomInfo <> '') or (TxnLine.RecIndex = 0))) 
                           or  (TxnLine.RecType <> 'TxnLine') then
                           begin
                              OldTxnStrings.Add(TxnLines[TxnLineIdx]);
                           end;
                           if ((TxnLine.RecType = 'TxnLine') and (TxnLine.RecIndex <> 0) and (TxnLine.PLU <> MainPLU) and (MainPLU <> 0)) then
                           begin
                              TxnLine.RecType:='ExtraTxnLine';
                              OldTxnStrings.Add(TxnLine.PackText);
                              TxnLine.RecType:='TxnLine';
                           end;
                        end; 
                     end;
                  end; 
               end; 
               MessageData.Free;
            end;
         end;
      end;
   end;
   Result:=TranslateFor('',OldTxnStrings.PackText);
   OldTxnStrings.Free;
   TxnLines.Free;
   TxnLine.Free;
   FileStatusMon.Free;
end;    
class function TTxnTranslate.TranslateQuery(SystemIdentifier,TxnLogQuery:String):TTransactionLines;
begin
   Result:=TranslateFor(SystemIdentifier,QueryToPackText(TxnLogQuery));
end;    
class function TTxnTranslate.GetQueryData(SystemIdentifier,QueryText:String):TTransactionLines;
var
   Query:TQuery;
   TransactionLines:TTransactionLines;
   TransactionLine:TTransactionLine;
begin
//   QueryStr:='select * from Transact,TransactDetail, TransactDetailName '+
//             'where Transact.TransactionID = TransactDetail.TransactionID '+
//             'and TransactDetail.DetailID = TransactDetailName.DetailID ';

   TransactionLines:=TTransactionLines.Create;
   Result:=TransactionLines;
   Query:=TQuery.Create(nil);
   try
      with Query do
      begin
         DatabaseName:='PSL';
         SQL.Text:=QueryText;
         Active:=True;
         while not Query.EOF do
         begin
            TransactionLine:=TransactionLines.Find(FieldByName('TransactionID').Value);
            if TransactionLine.FTransactionID <> FieldByName('TransactionID'   ).Value then
            begin
               TransactionLines.Add(TransactionLine);
               TransactionLine.FTransactionID   :=FieldByName('TransactionID'   ).Value;
               TransactionLine.RecordID         :=FieldByName('RecordID'        ).Value;
               TransactionLine.WSNumber         :=FieldByName('WSNumber'        ).Value;
               TransactionLine.OfficeCode       :=FieldByName('OfficeCode'      ).Value;
               TransactionLine.AccountingPeriod :=FieldByName('AccountingPeriod').Value;
               TransactionLine.TransactionType  :=FieldByName('TransactionType' ).AsString;
               TransactionLine.DateTime         :=FieldByName('TxnDateTime'     ).Value;
               TransactionLine.Teller           :=FieldByName('Teller'          ).AsString;
               TransactionLine.ProgramID        :=FieldByName('ProgramID'       ).AsString;
               TransactionLine.ProgramVersion   :=FieldByName('ProgramVersion'  ).Value;
               TransactionLine.PLU              :=FieldByName('PLU'             ).Value;
               TransactionLine.ItemPrice        :=FieldByName('ItemPrice'       ).Value;
               TransactionLine.ItemQuantity     :=FieldByName('ItemQuantity'    ).Value;
               TransactionLine.ItemValue        :=FieldByName('ItemValue'       ).Value;
               TransactionLine.Description      :=FieldByName('Description'     ).AsString;
               TransactionLine.CRC              :=FieldByName('CRC'             ).Value;
               TransactionLine.TxnIdent         :=FieldByName('TxnIdent'        ).AsString;
               TransactionLine.ProcessedOK      :=Copy(FieldByName('ProcessedOK'     ).AsString,1,1)[1];
            end;
            TransactionLine.AddDetail('','',FieldByName('DetailName').AsString,FieldByName('DetailValue').AsString,False,0);
            Next;
         end;
         Active:=False;
      Query.Free;
      end;
   except
      on E : Exception do
         RaiseGUIDException('{4F751A7F-5FAE-4465-A63C-13032A40A4F6}',E);
   end;
end;
class procedure TTxnTranslate.MarkTransferComplete(WSNumber:Integer;Ranges:String);
var
   Txnlog:ITransactionlog;
   SL:TPackStringList;
begin
   try
      Txnlog:=CreateTransactionlog;
      TxnLog.Workstation:=WSNumber;
      TxnLog.Office:=StrToIntDef(GetGPCSRegString('OfficeInfo','Office ID','0'),0);
      TxnLog.User:='Transfer';
      Txnlog.WriteTransaction('*TxnTrans',0,0,CalcCCITTCRC(Ranges),0,0,'Transfer Marker','','',Ranges);
      SL:=TPackStringList.Create;
      Sleep(100);
      SL.PackText:=QueryToPackText('select RecordID from txnlog where WSNumber = '+IntToStr(WSNumber)+' and RecType = ''TxnTrans'' and PLU = '+IntToStr(CalcCCITTCRC(Ranges)));
      while SL.Count < 1 do // wait for txn to be written
      begin
         Sleep(100);
         SL.PackText:=QueryToPackText('select RecordID from txnlog where WSNumber = '+IntToStr(WSNumber)+' and RecType = ''TxnTrans'' and PLU = '+IntToStr(CalcCCITTCRC(Ranges)));
      end;
      Txnlog:=nil;
      SL.Free;
   except
      on E : Exception do
         RaiseGUIDException('{57954483-EC7B-4D00-84CA-8BDE70081738}',E);
   end;
end;
class function TTxnTranslate.GetTransferRecords(WSNumber:Integer;var Ranges:String):String;
var
   TxnLogQuery:String;
   SL:TPackStringList;
   TmpSL:TPackStringList;
   PrevTx:TPackStringList;
   I,J:Integer;
   LastEntry:Integer;
   TxLimitData:TTxLimitData;
begin
   PrevTx:=TPackStringList.Create;
   TmpSL:=TPackStringList.Create;
   SL:=TPackStringList.Create;
   SL.PackText:=QueryToPackText('select Max(RecordID) from txnlog where WSNumber = '+IntToStr(WSNumber)+' and RecType = ''TxnTrans''');
   LastEntry:=-1;
   if SL.Count > 0 then
   begin
     SL.PackText:=SL[0];
     if SL.Count > 0 then
        LastEntry:=StrToIntDef(SL[0],-1);
   end;
   SL.PackText:=QueryToPackText('select DomInfo from txnlog where WSNumber = '+IntToStr(WSNumber)+' and RecordID = '+IntToStr(LastEntry));
   if SL.Count > 0 then PrevTx.PackText:=SL[0];
   Ranges:=QueryToPackText('select WSNumber,max(RecordID) from txnlog group by WSNumber');
   if PrevTx.Count > 0 then
   begin
      PrevTx.PackText:=PrevTx[0];
      SL.PackText:=Ranges;
      // SL = New Maxes, PrevTX = Last Maxes
      for I:=0 to SL.Count-1 do
      begin
         TmpSL.PackText:=SL[I];
         if TmpSL.Count > 0 then
         begin
            TxLimitData:=TTxLimitData.Create;
            TxLimitData.WSNumber:=StrToIntDef(TmpSL[0],0);
            if TmpSL.Count > 1 then
               TxLimitData.ToRID:=StrToIntDef(TmpSL[1],0)
            else
               TxLimitData.ToRID:=0;
            TxLimitData.FromRID:=-1;
            SL[I]:=IntToStr(TxLimitData.WSNumber);
            SL.Objects[I]:=TxLimitData;
         end
         else
            SL[I]:='';
      end;   
      for I:=0 to PrevTx.Count-1 do
      begin
         TmpSL.PackText:=PrevTx[I];
         if TmpSL.Count > 0 then
         begin
            J:=SL.IndexOf(TmpSL[0]);
            if (J >= 0) and (TmpSL.Count > 1) then
            begin
               TxLimitData:=TTxLimitData(SL.Objects[J]);
               TxLimitData.FromRID:=StrToIntDef(TmpSL[1],0);
            end;
         end;
      end;
      PrevTx.Free;
      TmpSL.Free;
   
      TxnLogQuery:='select * from txnlog where ( ';
      for I:=0 to SL.Count-1 do
      begin
         TxLimitData:=TTxLimitData(SL.Objects[I]);
         if TxLimitData <> nil then
         begin
            if TxLimitData.FromRID <> TxLimitData.ToRID then
            begin
                if TxnLogQuery <> 'select * from txnlog where ( ' then
                   TxnLogQuery:=TxnLogQuery+' and ( WSNumber = '+IntToStr(TxLimitData.WSNumber)+' and (RecordID > '+IntToStr(TxLimitData.FromRID)+' and RecordID <= '+IntToStr(TxLimitData.ToRID)+') ) '
                else
                   TxnLogQuery:=TxnLogQuery+'( WSNumber = '+IntToStr(TxLimitData.WSNumber)+' and (RecordID > '+IntToStr(TxLimitData.FromRID)+' and RecordID <= '+IntToStr(TxLimitData.ToRID)+') ) ';
            end;
            TxLimitData.Free;
         end;
      end;
      TxnLogQuery:=TxnLogQuery+' )';
   end
   else
   begin
      TxnLogQuery:='select * from txnlog';
   end;
   if TxnLogQuery = 'select * from txnlog where (  )' then
      Result:=''
   else
      Result:=QueryToPackText(TxnLogQuery);
   SL.Free;     
end;
function SetTransferData(Data:String;var Error:String):Boolean;
var
   TransactionLines:TTransactionLines;
begin
   Result:=True;
   if Data = '' then Exit;
   TransactionLines:=TTransactionLines.Create;
   try
//      TransactionLines.SetFromString(Data);
      TransactionLines:=TTxnTranslate.TranslateFor('',Data);
      TransactionLines.AddToTable('PSL','Transact');
   except
      Error:='Exception in TransactionLines.SetFromString';
      Result:=False;
   end;
   TransactionLines.Free;
end;
function GetTransferData(DataType:String):String;
var
//   TransactionLines:TTransactionLines;
   Ranges:String;
   WorkStation:Integer;
begin
   WorkStation:=StrToIntDef(GetGPCSRegString('WorkStation','Ident','99999'),99999);
   try
//      Result:=QueryToPackText('select * from txnlog');
      Result:=TTxnTranslate.GetTransferRecords(WorkStation,Ranges);
      TTxnTranslate.MarkTransferComplete(WorkStation,Ranges);
   except
      Result:=''
   end;
end;           
end.

