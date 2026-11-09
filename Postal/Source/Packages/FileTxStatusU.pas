unit FileTxStatusU;

interface

uses
  SysUtils,Classes,Windows,Messages,Graphics,Controls,Forms,Dialogs,Registry,
  StdCtrls,ExtCtrls,WinSock,MsgConfigU,IPCThrd,Db,DBTables,ActiveX,ComObj,
  GPCSErrorLine,GPCSGUID,GPCSBase_TLB,PackStrListU,ParseNodeU,WinExecU,Utils,RegistryEx,
  ScktComp2,StringWrapperU,StatusMonitorU,MsgFileAccessU,DTSocketU,ShareDataU,TaskKillerU,
  UIDllSupportU,I3UIParseU,FileCtrl,Compress,DirectoryU,DBUtil,StringUtil,SharedStockU;

const
   SeriesLength = 20;
   
type
  TDLLFunc = procedure(MessageData:String);
  TBlockPos = (bpFirst,bpMiddle,bpLast);
  TUpdateUI = procedure of object;
  TProgressCallBack = procedure (PhaseNo,PhaseOf,Max,Pos:Integer) of object;
  TContactStatus = procedure (Status:String) of object;
  TFileTxStatus = class;
  TMessageWrapper = class(TStringWrapper)         
      property DeliveryType      :Variant Index   0 read GetElement write SetElement;
      property DestinationOffice :Variant Index   1 read GetElement write SetElement;
      property SendBy            :Variant Index   2 read GetElement write SetElement;
      property ExpiresOn         :Variant Index   3 read GetElement write SetElement;
      property PhysicalLayout    :Variant Index   4 read GetElement write SetElement;
      property LogicalLayout     :Variant Index   5 read GetElement write SetElement;
      property MessageType       :Variant Index   6 read GetElement write SetElement;
      property MessageVersion    :Variant Index   7 read GetElement write SetElement;
      property MessageName       :Variant Index   8 read GetElement write SetElement;
      property MessageData       :Variant Index   9 read GetElement write SetElement;
      property WrapperType       :Variant Index  10 read GetElement write SetElement;
      property FromWorkstation   :Variant Index  11 read GetElement write SetElement;
      property FromOffice        :Variant Index  12 read GetElement write SetElement;
      property Identifier        :Variant Index  13 read GetElement write SetElement;
      property Flags             :Variant Index  14 read GetElement write SetElement;
      property MessageRecVersion :Variant Index  15 read GetElement write SetElement;
      property CRC 			      :Variant Index  16 read GetElement write SetElement;
  end;
  TOffCodeRef = class(TStringWrapper)
     property OfficeCode     :Variant Index  0 read GetElement write SetElement;
     property OfficeName     :Variant Index  1 read GetElement write SetElement;
     property OfficeTitle    :Variant Index  2 read GetElement write SetElement;
     property OfficeSCode    :Variant Index  3 read GetElement write SetElement;
     property OfficeI3Code   :Variant Index  4 read GetElement write SetElement;
     property OfficePCode    :Variant Index  5 read GetElement write SetElement;
     property OfficeAddress  :Variant Index  6 read GetElement write SetElement;
     property OfficePhone    :Variant Index  7 read GetElement write SetElement;
     property OfficePOBox    :Variant Index  8 read GetElement write SetElement;
     property OfficeAutomated:Variant Index  9 read GetElement write SetElement;
     property OfficeAccessVia:Variant Index 10 read GetElement write SetElement;
     property OfficeType     :Variant Index 11 read GetElement write SetElement;
  end;       
  TTxnProcessor = class(TObject)
  private
     Stock:TSiteStock;
     I3UINode:TI3UINode;
     PSLDatabase:TDatabase;
  public
     TxnLogTable:TTable;
     constructor Create(DBName:String);
     destructor Destroy; override;
     procedure AddRecord(Data: String;FirstLastMid:TBlockPos;FileTxStatus:TFileTxStatus);
     procedure ReceiveMessage(Data:String;LocalData:Boolean;MinPeriod:Integer;FileTxStatus:TFileTxStatus;MsgIndex:Integer);
  end;
  TExecLoop = class(TThread)
  private
     FFileTxStatus:TFileTxStatus;
     procedure ProcessTransactionFiles;
     procedure ExecuteFunction(EventID:Integer);
  public
     constructor Create(FileTxStatus:TFileTxStatus);
     destructor Destroy; override;
     procedure UpdateUserInterface;
     procedure SyncMessageData;
     procedure SyncUpdateStatus;
     procedure SyncServiceExclaim;
     procedure SyncServiceBusy;
     procedure Execute; override;
  end;
  TSignalLoop = class(TThread)
  private
     FFileTxStatus:TFileTxStatus;
  public
     constructor Create(FileTxStatus:TFileTxStatus);
     procedure UpdateUserInterface;
     procedure Execute; override;
  end;
  TDataCommLoop = class(TThread)
  private
     FFileTxStatus:TFileTxStatus;
  public
     procedure UpdateUserInterface;
     constructor Create(FileTxStatus:TFileTxStatus);
     destructor Destroy; override;
     procedure Execute; override;
  end;
  TInternalProcessLoop = class(TThread)
  private
     FFileTxStatus:TFileTxStatus;
  public
     procedure UpdateUserInterface;
     constructor Create(FileTxStatus:TFileTxStatus);
     destructor Destroy; override;
     procedure Execute; override;
  end;
  TTransmitItem = class(TStringWrapper)
     property NextOffice:Variant Index 0 read GetElement write SetElement; // transmit to
     property SendBy    :Variant Index 1 read GetElement write SetElement; // if not automatically transmitted by this time, connect to next office and send.
     property ToOffice  :Variant Index 2 read GetElement write SetElement; // final destination
     property FromOffice:Variant Index 3 read GetElement write SetElement; // used to find in msgstore
     property WSNumber  :Variant Index 4 read GetElement write SetElement; // used to find in msgstore
     property MessageNo :Variant Index 5 read GetElement write SetElement; // used to find in msgstore
  end;
  TFileTxStatus = class(TCustomControl)
  private
    FUnProcessedList:TStringList;
    FTransmitList:TStringList;
    FThisOfficeID:Integer;
    FCurrentStatus:Integer;
    FWorkstation:Integer;
    FThisVersion:Integer;
    FStatusMonitor:TStatusMonitor;
    FFileBlockMgr :TAllMsgFiles;
    FDTSocket     :TDTSocket;
    FRemDTSocket  :TDTSocket;
    FExecLoop     :TExecLoop;
    FSignalLoop   :TSignalLoop;
    FDataCommLoop :TDataCommLoop;
    InternalProcessLoop:TInternalProcessLoop;
    FOfficeRouteInfo:TParseNode;
    FOfficeReference:TPackStringList;
    FThisOfficeInfo:TOffCodeRef;
    FCurrentMinPeriod:Integer;
    FDontAutoProcess:Boolean;
    FDisableAutoProcess:Boolean;
    FOnChange     :TNotifyEvent;
    FOnContactStatus:TContactStatus;
    FOnContactError :TContactStatus;
    FOnSendStatus:TTxStatusEvent;
    FOnRecvStatus:TRxStatusEvent;
    FOnDataSend       :TOnDataSend       ;
    FOnDataSent       :TOnDataSent       ;
    FOnDataReceived   :TOnDataReceived   ;
    FOnDataConnectTime:TOnDataConnectTime;
    FOnUpdateUI:TUpdateUI;
    function GetContactSchedule:String;
    procedure CheckUpdateFiles;
  protected
    FSkipRest:Boolean;
    procedure GetOfficeRouteInfo;
    procedure DataRxEvent   (Sender:TStatusMonitor;DataReceived:String); virtual;
    function  DataTxEvent   (Sender:TStatusMonitor;OfficeID,Workstation,BlockNumber:Integer;Into:TStream):TStream; virtual;
    procedure DataErrorEvent(Sender:TStatusMonitor;ErrorMessage:String); virtual;
    procedure SendEvent     (Sender:TStatusMonitor;Data:String); virtual;
    procedure ReceiveEvent  (Sender:TStatusMonitor;Data:String); virtual;
    procedure MarkTransferComplete(BlockList:String);
    function GetTransferBlocks(ForOffice:Integer;RemoteState:String):String;
    function ProcessReceivedMessages(DataString:String):String;
    function  ProcessCommand(CommandType:TCommandType;Msg:String):String; virtual;
    function  ExecuteQuery(QueryParams:String):String;
    procedure SaveDataBlocks(Msg:String;CommandType:TCommandType); virtual;
    function  GetWorkstation:Integer;
    procedure SetWorkstation(Value:Integer);
    function  GetActive:Boolean;
    procedure SetActive(Value:Boolean);
    procedure Changed(Sender:TObject);
    procedure DataSend       (Host:String;Size:Integer);
    procedure DataSent       (Host:String;Size:Integer;Stat:Boolean;Time:TTime);
    procedure DataReceived   (Host:String;Size:Integer;Stat:Boolean;Time:TTime);
    procedure DataConnectTime(Host:String;Time:TTime);
    procedure SendStat(Size:Integer;Stat:Boolean);
    procedure RecvStat(Size:Integer;From:String;Stat:Boolean);
    function  GetCurrentStatus:Integer;
    procedure FillOfficeReference;
    function GetRefForCode(Code:Integer):TOffCodeRef;
    procedure LogOffMachine(Sender:TObject);
    procedure RestartMachine(Sender:TObject);
    procedure ShutdownMachine(Sender:TObject);
    procedure PowerOffMachine(Sender:TObject);
  public
    OfficeInfo:String;
    RunningAsService:Boolean;
    ContactSchedule:String;
    function SetGMemory(Data:String):String;
    function GetGMemory(MachineName:String):String;
    function SendUserDataGram(Data:String):String;
    function SendUserMessage(Data:String):String;
    function OfficeList:String;
    function WriteTransaction(Office,WSNumber,Period:Integer;DateTime:TDateTime;RecIndex,PLU:Integer;Price,TxnValue:Currency;Quantity:Integer;ProgID,User,RecType,Description,Ident,Info,DomInfo:String):Boolean;
    function FindPensionMessage(Office,DestinationOffice:Integer;MessageName:String):Boolean;
    function PensionTxnList(OfficeCode:Integer):String;
    function MoneyOrderPayList(OfficeCode:Integer;MOTypes:Integer):String;
    function PensionList(OfficeCode:Integer;Identifier:String):String;
    function FullPensionList(OfficeCode:Integer):String;
    function UnpaidPensionList(OfficeCode:Integer;Identifier:String):String;
    function PaidPensionList(OfficeCode:Integer):String;
    function NextOffice(Current,Destination:Integer;Mapping:String):Integer;
    function OfficeNameFromCode(OfficeCode:Integer):String;
    function OfficeCodeRef(OfficeCode:Integer):String;
    function OfficeCodeRefs:String;
    function OfficeTitleFromCode(OfficeCode:Integer):String;
    function OfficeSCodeFromCode(OfficeCode:Integer):String;
    function OfficePCodeFromCode(OfficeCode:Integer):Integer;
    function OfficeI3CodeFromCode(OfficeCode:Integer):Integer;
    function OfficeAddressFromCode(OfficeCode:Integer):String;
    function OfficePhoneFromCode(OfficeCode:Integer):String;
    function OfficePOBoxFromCode(OfficeCode:Integer):String;
    function OfficeAccessViaFromCode(OfficeCode:Integer):String;
    function OfficeAutomatedFromCode(OfficeCode:Integer):String;
    function OfficeCodeFromTitle(Title:String):Integer;
    function OfficeCodeFromName(Name:String):Integer;
    function OfficeCodeFromSCode(SCode:String):Integer;
    function OfficeCodeFromI3Code(I3Code:Integer):Integer;
    function OfficeCodeFromPCode(PCode:Integer):Integer;
    function ListOffices(OType:String;Into:TStrings):String;
    function GetRoute(A,B:Integer;Mapping:String):String;
    procedure TimerTick;
    procedure DataCommTick;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Status:String;
    procedure UpdateUI;
    function ContactAllSubs(OfficeToProcess:Integer):Integer;
    function SendRemoteCommand(Host:String;TimeOut:Integer;CommandType:TCommandType;DataStream:TStringStream;HangUpAfter:Boolean):String;
    function SendCommand(Host:String;TimeOut:Integer;CommandType:TCommandType;DataStream:TStringStream;HangUpAfter:Boolean):String;
    procedure PostForProcessing(MessageAccess:TMessageAccess;CreatedLocally:Boolean;TxnProcessor:TTxnProcessor);
    function GetTransmitItems(OfficeID:Integer):String;
    function DeleteTransmitItem(Value:String):String;
    function RequestDataFromOffice(OfficeID:Integer;Host:String;TimeOut:Integer;OfficeName:String):String;
    procedure RequestReplace(From:String);
    procedure ReplaceSelf(Data:String);
    property StatusMonitor:TStatusMonitor read FStatusMonitor write FStatusMonitor;
    property FileBlockMgr :TAllMsgFiles   read FFileBlockMgr  write FFileBlockMgr ;
    property DTSocket     :TDTSocket      read FDTSocket      write FDTSocket     ;
    property RemDTSocket  :TDTSocket      read FRemDTSocket   write FRemDTSocket  ;
    property ThisOfficeID:Integer read FThisOfficeID;
    property ThisOfficeInfo:TOffCodeRef read FThisOfficeInfo;
    property ThisVersion:Integer read FThisVersion write FThisVersion;
    property Workstation:Integer read FWorkstation;
    property TransmitList:TStringList read FTransmitList write FTransmitList;
    property OfficeRouteInfo:TParseNode read FOfficeRouteInfo;
    property OnContactStatus:TContactStatus read FOnContactStatus write FOnContactStatus;
    property OnContactError :TContactStatus read FOnContactError  write FOnContactError ;
    property OnDataSend       :TOnDataSend        read FOnDataSend        write FOnDataSend       ;
    property OnDataSent       :TOnDataSent        read FOnDataSent        write FOnDataSent       ;
    property OnDataReceived   :TOnDataReceived    read FOnDataReceived    write FOnDataReceived   ;
    property OnDataConnectTime:TOnDataConnectTime read FOnDataConnectTime write FOnDataConnectTime;
    property OnSendStatus     :TTxStatusEvent     read FOnSendStatus      write FOnSendStatus     ;
    property OnRecvStatus     :TRxStatusEvent     read FOnRecvStatus      write FOnRecvStatus     ;
    property OnUpdateUI       :TUpdateUI          read FOnUpdateUI        write FOnUpdateUI       ;
    property CurrentStatus    :Integer            read GetCurrentStatus   write FCurrentStatus    ;
  published
    property DisableAutoProcess:Boolean   read FDisableAutoProcess write FDisableAutoProcess;
    property ThisWorkstation :Integer     read GetWorkstation    write SetWorkstation   ;
    property CurrentMinPeriod:Integer     read FCurrentMinPeriod write FCurrentMinPeriod;
    property Active:Boolean               read GetActive         write SetActive        ;
    property OnChange:TNotifyEvent        read FOnChange         write FOnChange        ;
    property PopUpMenu;
  end;                   
  TFileStatusMon = class(TFileTxStatus)
  public
    constructor Create(AOwner: TComponent); override;
  end;
  TFileStatusMonW = class(TFileTxStatus)
  public
    constructor Create(AOwner: TComponent); override;
  end;                   
  
  TTxnTransfer = class(TObject)
  private
    class function GetTxnLogWhereClause:String;
  public
    class function CreateTxnLogCalled(Database:TDatabase;DBName,Alias,FileName:String):TTable;
    class procedure WriteTxnToTable(TxnLogLine:TTxnLogLine;Table:TTable;MessageIndex:Integer);
    class procedure BuildTxnlog(FromPeriod,ToPeriod:Integer;TxnLines:TTxnLogLines;TableName:String;ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus);
    class procedure WriteLimitedTransactionLines(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus;MaxPeriodCount:Integer;Table:TTable);
    class function GetLimitedTransactionLines(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus;MaxPeriodCount:Integer):TTxnLogLines;
    class function GetTransactionLines(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus):TTxnLogLines;
    class function GetAvailablePeriods(TxnLines:TTxnLogLines;ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus):String;
    class function CreateTxnlog(Database:TDatabase;TableName:String):TTable;
    class procedure RebuildTxnLog(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus);
    class procedure BuildStoreFromTxnLog(TxnLog:TQuery;FileTxStatus:TFileTxStatus;ProgressCallBack:TProgressCallBack);
    class function ProcessUnProcessedMessages(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus):Boolean;
    class function ProcessUnProcessedPensions(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus):Boolean;
    class function FindUnProcessedMessages(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus):Boolean;
    class procedure PutInMoneyOrderMessages(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus);
    class function MarkAllMessages(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus):Boolean;
    class function FindPensionMessages(FileTxStatus:TFileTxStatus):Boolean;
    class function FindMOMessages(FileTxStatus:TFileTxStatus):Boolean;
    class procedure MarkAsUnProcessed(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus);
    class function ListOffices(OType:String;Into:TStrings):String;
    class function OfficeCodeRefs:String;
    class function GetNextOffice(FileTxStatus:TFileTxStatus;DestinationOffice:Integer;PhysicalLayout,LogicalLayout:String):String;
    class function OfficeName(OfficeCode:Integer):String;
    class procedure MarkAsUnTransmitted(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus);
    class procedure MarkAsProcessed(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus);
    class function SendReplaceSelfTo(Host:String;FileTxStatus:TFileTxStatus;HangUpWhenComplete:Boolean):String;
    class function GetCurrentMinPeriod(TxnLines:TTxnLogLines;FileTxStatus:TFileTxStatus):Integer;
    class function GetMinPeriod(FileTxStatus:TFileTxStatus;MaxPeriodCount:Integer):Integer;
  end;

procedure GetTxnLogDB(var Database:TDatabase;var Table:TTable;AliasName,DBName:String);
function SendServiceMessage(DeliveryType:TDeliveryType;DestinationOffice,msTimeOut:Integer;SendBy,ExpiresOn:TDateTime;PhysicalLayout,LogicalLayout:String;MessageType:TMessageType;MessageVersion:Integer;MessageName,MessageData:String):Boolean;
function CreateServiceDistFile(DeliveryType:TDeliveryType;DestinationOffice,msTimeOut:Integer;SendBy,ExpiresOn:TDateTime;PhysicalLayout,LogicalLayout:String;MessageType:TMessageType;MessageVersion:Integer;MessageName,MessageData:String):Boolean;
function CopyOnDistributionFiles:Boolean;
function RequestServiceData(RequestName,ParameterData:String):String;
function SetGMemory(Data:String):String;
function RequestGMemory(MachineName:String):String;
function SendDGram(Data:String):String;
procedure UpdateStatus;
function IsServiceUsingStock:Boolean;
function IsServiceRunning:Boolean;
function IsServiceBusy:Boolean;
procedure CheckForOldDLLName;
function GetVersion:Integer;

var
   ThePensionsList:TStringList;
   TheMOList:TStringList;
   ServiceSharedData:TSharedData;
   TempFileTxStatus:TFileTxStatus;
   BeenInterrupted:Boolean;
   StartUpProcessing:Boolean;
   DontProcessNow:Boolean;
   ServiceIsBusy:Boolean;
   
const
   SpecialProcessing:Boolean = False;
   
implementation

uses
   OsmiumSupportU,MOSupportU,MODefinitionsU,CustomerListU,UserManager_TLB,MsgFileMaintU;
   
function NowInSeconds:Integer;
begin
   Result:=(DateTimeToTimeStamp(Now).Time div 1000);
end;
procedure GetTxnLogDB(var Database:TDatabase;var Table:TTable;AliasName,DBName:String);
begin
   LogProgress(2,'GetTxnLogDB start '+AliasName+' '+DBName);
   Database:=TDatabase.Create(nil);
   Database.AliasName   :=AliasName;
   Database.DatabaseName:=DBName;
   Database.LoginPrompt :=False;
   Database.SessionName :='Default';

   Table:=TTable.Create(nil);
   Table.DatabaseName:=DBName;
   Table.TableName   :=TableName;
   
   if GetGPCSRegString('WorkStation','DBType','Paradox') <> 'Paradox' then
      Table.IndexName:='TXNLOG_PINDEX';
      
   if GetGPCSRegString('WorkStation','DBType','Paradox') = 'SQLServer' then
      Table.TableName   :=DatabaseOwner+'.TXNLOG';
                                                                          
   DataBase.Params.Add('USER NAME='+GetGPCSRegString('','UserName','psl'   ));
   DataBase.Params.Add('PASSWORD=' +GetGPCSRegString('','Password','corvus'));
   LogProgress(2,'GetTxnLogDB end');
end;
function FindMaxRecordID(OfficeCode,WSNumber:Integer;FileTxStatus:TFileTxStatus):Integer;
var
   FSM:TFileTxStatus;
   Status:TStatusBits;
   TxnLine:TTxnLogLine;
   TxnLines:TTxnLogLines;
   MsgIndex,Flags,J:Integer;
   MessageData:TMessageAccess;
begin
   Result:=0;
   FSM:=FileTxStatus;
   Status:=TStatusBits.Create;
   TxnLine:=TTxnLogLine.Create;
   TxnLines:=TTxnLogLines.Create;
   try
      Status.State:=FSM.Status;
      MsgIndex:=Status.Size(OfficeCode,WSNumber);
      while MsgIndex >= 0 do
      begin
         Flags:=FSM.FileBlockMgr.GetMessageFlags(OfficeCode,WSNumber,MsgIndex);
         if (Flags and TransactionMsg) = TransactionMsg then
         begin
            MessageData:=FSM.FileBlockMgr.GetMessage(OfficeCode,WSNumber,MsgIndex);
            if MessageData <> nil then
            begin
               TxnLines.PackText:=MessageData.MessageData;
               for J:=0 to TxnLines.Count-1 do
               begin
                  TxnLine.PackText:=TxnLines[TxnLines.Count-1];
                  try
                     if (TxnLine.RecordID > Result) then
                        Result:=TxnLine.RecordID;
                  except
                  end;
               end; 
               MessageData.Free;
               if Result <> 0 then break;
            end;
         end;
         Dec(MsgIndex);
      end;
   except
      on E:Exception do 
         RaiseGUIDException('{CF497A71-7D7B-43B2-B718-73B35F0F54D2}',E);
   end;
   TxnLine.Free;
   TxnLines.Free;
   Status.Free;
end;
function ExecQuery(UserName,PassWord,Alias,Query,DestinationHost:String;mSTimeOut:Integer;HangUpAfter:Boolean;FileTxStatus:TFileTxStatus):String;
var                                    
   UserMessage:TUserMessage; 
   QueryParams:TQueryParams; 
begin
   QueryParams:=TQueryParams.Create;
   QueryParams.UserName:=UserName;
   QueryParams.Password:=PassWord;
   QueryParams.Alias   :=Alias;
   QueryParams.Query   :=Query;

   UserMessage:=TUserMessage.Create;
   UserMessage.DestinationHost:=DestinationHost;
   UserMessage.TimeOut        :=mSTimeOut;
   UserMessage.CommandType    :=ctExecuteQuery;
   UserMessage.Data           :=QueryParams.PackText;
   UserMessage.HangUpAfter    :=HangUpAfter;
   
   QueryParams.Free;
   Result:=FileTxStatus.SendUserMessage(UserMessage.PackText);
   UserMessage.Free;
end;
procedure MarkBillAsPaid(BillDetails:String;ThisOffice,Workstation:Integer;ReceiptNo:String;FileTxStatus:TFileTxStatus);
var
   EWBillPayment:TEWBillPayment;
   SQL:String;
begin
   EWBillPayment:=TEWBillPayment.Create;
   EWBillPayment.PackText:=BillDetails;
   if (EWBillPayment.OfficeCode = ThisOffice) and (EWBillPayment.WorkStation = WorkStation) then
   begin
      SQL:='INSERT bill_data_invoice (customer_number, check_digit, area_number, '+
                                ' electricity_amount, water_amount, total_amount, '+
                                ' payment_date, bill_period, payment_method, '+
                                ' ew_reference, qpost_reference, trailer_indicator, '+
                                ' record_count, summary_e_amount, summary_w_amount, '+
                                ' summary_t_amount, update_sent, invoice_sent, '+
                                ' cancelled, op_id) ';
      SQL:=SQL+' Values ('''+
         Trim(EWBillPayment.CustomerNumber   )+''', '''+Trim(EWBillPayment.CheckDigit       )+''', '''+
         Trim(EWBillPayment.AreaNumber       )+''', '''+Trim(EWBillPayment.ElectricityAmount)+''', '''+
         Trim(EWBillPayment.WaterAmount      )+''', '''+Trim(EWBillPayment.TotalAmount      )+''', '''+
         EWBillPayment.PaymentDay+EWBillPayment.PaymentMonth+EWBillPayment.PaymentYear       +''', '''+
         Trim(EWBillPayment.BillPeriod       )+''', '''+Trim(EWBillPayment.PaymentMethod    )+''', '''+
         Trim(EWBillPayment.EWReference      )+''', '''+Trim(EWBillPayment.QPostReference   )+ReceiptNo+''', '''+
         Trim(EWBillPayment.TrailerIndicator )+''', '''+Trim(EWBillPayment.RecordCount      )+''', '''+
         Trim(EWBillPayment.SummaryEAmount   )+''', '''+Trim(EWBillPayment.SummaryWAmount   )+''', '''+
         Trim(EWBillPayment.SummaryTAmount   )+''', '''+Trim(EWBillPayment.UpdateSent       )+''', '''+
         Trim(EWBillPayment.InvoiceSent      )+''', '''+Trim(EWBillPayment.Cancelled        )+''', '''+
         Copy(EWBillPayment.OpID,Length(EWBillPayment.OpID)-10,10)+ ''' )';
         
      ExecQuery('local','local','BillDev',SQL,'10.10.1.26',120000,True,FileTxStatus);
   end;
   EWBillPayment.Free;
end;
function ProcessTransactionsIntoDB(TxnPackText:String;var ContainsMoneyOrder,ContainsPension:Boolean;SetWSTo:Integer;FileTxStatus:TFileTxStatus):String;
var
   SL:TTxnLogLine;
   FSL:TTxnLogLines;
   I:Integer;
   Found:Boolean;
const
   NextIdent:Integer = -1;
   Incheck:Boolean = False;
   TxnLogTable:TTable = nil;
   DB:TDatabase = nil;
begin
   if TxnPackText = 'Finished' then
   begin
      if DB <> nil then
      begin
         DB.Free;
         DB:=nil;
      end;
      if TxnLogTable <> nil then
      begin
         TxnLogTable.Free;
         TxnLogTable:=nil;
      end;
      Exit;
   end;
   if DB = nil then
      GetTxnLogDB(DB,TxnLogTable,'PSL','PSLDB');
      
   FSL:=TTxnLogLines.Create;
   SL:=TTxnLogLine.Create;
   FSL.PackText:=TxnPackText;
   if (NextIdent = -1) then
   begin
      if (FSL.Count > 0) then 
         SL.PackText:=FSL[0];
      try
         NextIdent:=FindMaxRecordID(SL.Office,SL.WSNumber,FileTxStatus)+1;
      except
         on E:Exception do
            RaiseGUIDException('{09D36CE7-AC32-411A-8F59-BB84BC85E417}'+TxnPackText,E);
      end;
   end;
   
   if not TxnlogTable.Active then
   begin
      TxnlogTable.DatabaseName:='PSLDB';
      TxnlogTable.Active:=True;
   end;
      
   for I:=0 to FSL.Count-1 do
   begin
      try
         //ensure NextIdent is valid for this WS
         SL.PackText:=FSL[I];
         SL.RecordID:=NextIdent; 
         if SetWSTo <> 0 then SL.WSNumber:=SetWSTo;
         Found:=TxnLogTable.FindKey([SL.RecordID,SL.WSNumber]);
         if Found then
         begin
            RaiseGUIDError('{61288EAD-9BC1-40F0-925D-941FD7847841}','Record Already Found ID '+SL.RecordID+' WS '+SL.WSNumber);
            try                                                
               NextIdent:=FindMaxRecordID(SL.Office,SL.WSNumber,FileTxStatus)+2;
            except
               NextIdent := 0;
            end;
         end;
         SL.PackText:=FSL[I];
         if SetWSTo <> 0 then SL.WSNumber:=SetWSTo;
         SL.RecordID:=NextIdent; 
         Inc(NextIdent);
         FSL[I]:=SL.PackText;
         
         if (SL.PLU = NormalPensionPLU ) or (SL.PLU = ArrearsPensionPLU) then
         begin        
            ContainsPension:=True;
         end
         else if (SL.RecType = MOIssueType) or (SL.RecType = MOPaidType)
         or (SL.RecType = MOIInfoType) or (SL.RecType = MOPInfoType) 
         or (SL.RecType = MFIssueType) or (SL.RecType = MFPaidType) then
         begin
            ContainsMoneyOrder:=True;
         end;
         
         TxnlogTable.Append;
         TxnlogTable.FieldByName('RECORDID')   .value:=SL.RecordID   ;
         TxnlogTable.FieldByName('WSNUMBER')   .value:=SL.WSNumber   ;
         TxnlogTable.FieldByName('DATETIME')   .value:=TDateTime(SL.DateTime);
         TxnlogTable.FieldByName('RECTYPE')    .value:=SL.RecType    ;
         TxnlogTable.FieldByName('PERIOD')     .value:=SL.Period     ;
         TxnlogTable.FieldByName('RECINDEX')   .value:=SL.RecIndex   ;
         TxnlogTable.FieldByName('OFFICE')     .value:=SL.Office     ;
         TxnlogTable.FieldByName('TELLER')     .value:=SL.Teller     ;
         TxnlogTable.FieldByName('PLU')        .value:=SL.PLU        ;
         TxnlogTable.FieldByName('PROD')       .value:=SL.Prod       ;
         TxnlogTable.FieldByName('PRICE')      .value:=SL.Price      ;
         TxnlogTable.FieldByName('QUANTITY')   .value:=SL.Quantity   ;
         TxnlogTable.FieldByName('TXNVALUE')   .value:=SL.TxnValue   ;
         TxnlogTable.FieldByName('DESCRIPTION').value:=SL.Description;
         TxnlogTable.FieldByName('INFO')       .value:=SL.Info       ;
         TxnlogTable.FieldByName('IDENT')      .value:=SL.Ident      ;
         TxnlogTable.FieldByName('DOMINFO')    .value:=SL.DomInfo    ;
         TxnLogTable.Post;
         
         if SL.RecType = 'EWBillPay' then
            MarkBillAsPaid(SL.DomInfo,FileTxStatus.FThisOfficeID,FileTxStatus.FWorkstation,SL.Ident,FileTxStatus);
      except
         On E : Exception do
            RaiseGUIDException('{FA02EBB0-BE96-4A31-A15C-80E711ABB6C5}', E);
      end;
   end;
   Result:=FSL.PackText;
   FSL.Free;
   SL.Free;
end;
function UpdateLists(Flags,Office,WS,MsgIndex:Integer;FileTxStatus:TFileTxStatus;MessageAccess:TMessageAccess):Integer;
var
  Dest  :Integer;
  SendBy:TDateTime;
  FoundPensionTransaction:Boolean;
  FoundMoneyOrderTransaction:Boolean;
begin
   FoundPensionTransaction:=False;
   FoundMoneyOrderTransaction:=False;
   // if its a Transaction and it has bee processed
//   if ((Flags and MessageHasGoodCRC) = MessageHasGoodCRC) then
   begin
      if  ((Flags and TransactionMsg  ) = TransactionMsg   )
      and ((Flags and MessageProcessed) <> MessageProcessed) then
      begin
         FileTxStatus.FUnProcessedList.Add(IntToHex(Office,4)+IntToHex(WS,2)+IntToHex(MsgIndex,8));
      end
      else if (Flags and PensionMsg) <> 0 then
      begin
         if ((Flags and TransactionMsg) = TransactionMsg) then
         begin
            FoundPensionTransaction:=True;
            ThePensionsList.Add(IntToHex(Office,4)+IntToHex(WS,2)+IntToHex(MsgIndex,8)+'T');
         end
         else
         begin
            ThePensionsList.Add(IntToHex(Office,4)+IntToHex(WS,2)+IntToHex(MsgIndex,8)+'P');
         end;
      end                             
      else if ((Flags and MoneyOrderMsg) = MoneyOrderMsg) then
      begin
//         FileTxStatus.FMoneyOrderList.Add(IntToHex(Off,4)+IntToHex(WS,2)+IntToHex(MsgIndex,8));
         if ((Flags and TransactionMsg) = TransactionMsg) then
         begin
            FoundMoneyOrderTransaction:=True;              
            TheMOList.Add(IntToHex(Office,4)+IntToHex(WS,2)+IntToHex(MsgIndex,8)+'T');
         end
         else
         begin
            TheMOList.Add(IntToHex(Office,4)+IntToHex(WS,2)+IntToHex(MsgIndex,8)+'O');
         end;
      end;
      if  ((Flags and TransferMsg      ) = TransferMsg)
      and ((Flags and MessageTransfered) = 0          ) then
      begin
         if MessageAccess = nil then
         begin
            Dest  :=FileTxStatus.FileBlockMgr.GetMessageDestination(Office,WS,MsgIndex);
            SendBy:=FileTxStatus.FileBlockMgr.GetMessageSendBy(Office,WS,MsgIndex);
         end
         else
         begin
            Dest  :=MessageAccess.DestinationOffice;
            SendBy:=MessageAccess.SendBy           ;
         end;
         
         if (Dest <> Office) then // dont send back to origin! 
            FileTxStatus.FTransmitList.Add(IntToHex(Office,4)+IntToHex(WS,2)+IntToHex(MsgIndex,8)+IntToHex(Dest,4)+FloatToStr(SendBy));
      end;
   end;
   Result:=0;
   if FoundPensionTransaction then
      Result:=1;
   if FoundMoneyOrderTransaction then
      Result:=Result+2;
end;                            
{TTxnProcessor}
constructor TTxnProcessor.Create(DBName:String);
begin
   LogProgress(2,'TTxnProcessor.Create start '+DBName);
   GetTxnLogDB(PSLDatabase,TxnLogTable,AliasName,DBName);
   CoInitialize(nil);
   I3UINode:=nil;
   LogProgress(2,'TTxnProcessor.Create end');
end;
destructor TTxnProcessor.Destroy;
begin
   LogProgress(2,'TTxnProcessor.Destroy start');
   try
     GetUserNumber('*DestroyList');         
   except on E:Exception do RaiseGUIDException('{9CABC3FE-83AE-490B-A06E-A845A951DFC4}',E); end;
   
   try
      if Stock <> nil then 
      begin
         Stock.Free;
         Stock:=nil;
      end;
   except on E:Exception do RaiseGUIDException('{DC7D8C67-0A04-4387-9F39-FB769ADD73CB}',E); end;
   
   try
      if FileExists('C:\ServiceUsingStock.lck') then 
         DeleteFile('C:\ServiceUsingStock.lck');
   except on E:Exception do RaiseGUIDException('{D798940C-DF4A-4E2A-A08F-FC33EDC50DFC}',E); end;

   try
      if I3UINode <> nil then
         I3UINode.Free;
   except on E:Exception do RaiseGUIDException('{F6F38459-F5EE-41A4-B9CC-9B46A861F38F}',E); end;


   try
      TxnLogTable.Free;
   except on E:Exception do RaiseGUIDException('{31204F95-88D3-48CE-A03D-3DFF86D705FA}',E); end;

   try
      PSLDatabase.Free;
   except on E:Exception do RaiseGUIDException('{283D4F07-0F2F-47B4-9DAF-E36EEB15F03D}',E); end;

   try
      CoUnInitialize;
   except on E:Exception do RaiseGUIDException('{3BB86EE0-5D88-40AF-8ACB-1DAB7CC826F7}',E); end;
   inherited Destroy;
   LogProgress(2,'TTxnProcessor.Destroy end');
end;                                         
procedure TTxnProcessor.AddRecord(Data: String;FirstLastMid:TBlockPos;FileTxStatus:TFileTxStatus);
var
   SL:TTxnLogLine;
   SLExtra:TStringList;
   Description:String;
   Teller:String;
   Ident:String;
   Quantity:Integer;
   TxnType:String;
   PLU:Integer;
//   Idx:Integer;
   Price:Currency;
   ProgID:String;
   Additional:String;
   DomInfo:String;
   Office:String;
   Value:Currency;
   MoneyOrder:TMoneyOrder;
   I,J:Integer;
   PSL:TPackStringList;
   TxnDomInfoLines:TDomInfoLines;
   MOEvent:TMOEvent;
   MOFee:TMOFee;
   MODetail:TMODetail;
   NetManager:INetUser;
begin
   LogProgress(2,'TTxnProcessor.AddRecord start '+Data);
   try
      SL:=TTxnLogLine.Create;
      SL.PackText:=Data;
      if SL.Count > 15 then
      begin
         Teller     :=SL.Teller;
         Description:=SL.Description;
         Ident      :=SL.Ident;
         TxnType    :=SL.RecType;
         ProgID     :=SL.Prod;
         Additional :=SL.Info;
         Office     :=SL.Office;
         if SL.Count > 16 then
             DomInfo    :=SL.DomInfo;
         if SL.Quantity <> '' then Quantity:=SL.Quantity else Quantity:=0;
         if SL.PLU      <> '' then PLU     :=SL.PLU      else PLU     :=0;
         if SL.Price    <> '' then Price   :=SL.Price    else Price   :=0;
         if SL.TxnValue <> '' then Value   :=SL.TxnValue else Value   :=0;
{         if TxnType = 'RepairMS' then
         begin
            FileTxStatus.Enabled:=False;
            SetPSLRegString('Message Transfer','Compressing Blocks','Y');
            Repair(0);
            FileTxStatus.Enabled:=True;
            SetPSLRegString('Message Transfer','Last Rebuild','0');
         end                   
         else }
         if Pos(TxnType,'TxStkTo TxStkFrom StockUsed StockSet NewStock DelStock SaveStk ') > 0 then
         begin
            if Stock = nil then
            begin
               with TFileStream.Create('C:\ServiceUsingStock.lck',fmCreate or fmShareExclusive) do
                  Free;
               Stock:=TSiteStock.Create;
            end;
            if Stock <> nil then
            begin
               if TxnType = 'TxStkTo' then
               begin
                  Stock.EmptySetUp(Teller);
                  Stock.AdjustStockLevel(Teller,Description,0-Quantity);
                  if Teller <> ident then
                     Stock.AdjustStockLevel(Ident,Description,Quantity);
               end           
               else if TxnType = 'TxStkFrom' then
               begin
                  Stock.EmptySetUp(Ident);
                  Stock.AdjustStockLevel(Ident,Description,0-Quantity);
                  if Teller <> ident then
                  begin
                     Stock.EmptySetUp(Teller);
                     Stock.AdjustStockLevel(Teller,Description,Quantity);
                  end;
               end           
               else if TxnType = 'StockUsed' then
               begin
                  Stock.EmptySetUp(Teller);
                  Stock.AdjustStockLevel(Teller,Description,0-Quantity);
               end           
               else if TxnType = 'SupStkUsd' then  // Supervisor Stock Used
               begin
                  Stock.EmptySetUp('Supervisor');
                  Stock.AdjustStockLevel('Supervisor',Description,0-Quantity);
               end
               else if TxnType = 'StockSet' then
               begin
                  Stock.EmptySetUp(Teller);
                  Stock.SetStockLevel(Teller,Description,Quantity);
               end
               else if TxnType = 'SaveStk' then
               begin
                  try
                     for I:=0 to 9 do
                     begin
                        Windows.Beep(3000+I*100,100);
                        Sleep(100);
                     end;
                     PSL:=TPackStringList.Create;
                     PSL.PackText:=DomInfo;
                     PSL.SaveToFile('C:\StockUpdate.dat');
                     PSL.Free;
                     Stock.Stock.LoadIDS('C:\StockUpdate.dat');
                  except
                     on E:Exception do
                         RaiseGUIDException('{E273402A-EC6E-44C9-AD4B-334F4FA15DDC}',E);
                  end;
               end           
               else if TxnType = 'NewStock' then
               begin
                  SLExtra := TStringList.Create ;
                  SLExtra.CommaText := Additional ;
                  // Group(0),AccountID(1),Agency(2),ReportLine(3);
                  Stock.AddNewStockItem(Description,Price,SLExtra[0],PLU,SLExtra[1],SLExtra[2],SLExtra[3],ProgID,DomInfo);
                  SLExtra.Free;
               end
               else if TxnType = 'DelStock' then
               begin
//                  Stock.DeleteStockItem(Description);
                  Stock.DeleteStockItemByName(Description);
               end;
            end;
         end
         else if TxnType = 'Exchange' then
         begin
            SetGPCSRegString('ExchangeRates',Description,CurrToStr(StrToCurrDef(Ident,0)));
         end
         else if TxnType = 'DelExchg' then
         begin
            DeleteCountryExchange(Description);
         end
         else if TxnType = 'Account' then
         begin
            if GetGPCSRegString('Customers','LocalDatabase','0') = '1' then
            begin
                if Additional = 'Payment for Services' then
                  Value := -Abs(Value);
               TCustomers.CustomerTransaction(Description,Additional,Value);
            end ;
         end
         else if TxnType = 'ListUpdt' then
         begin
            UpdateLocalList(Description,Additional,ProgID);
         end
         else if TxnType = 'CustQuery' then
         begin
            if GetGPCSRegString('Customers','LocalDatabase','0') = '1' then
            begin
               FileTxStatus.WriteTransaction(FileTxStatus.FThisOfficeID,FileTxStatus.FWorkstation,
                                             SL.Period,Now,0,0,0,0,0,'',SL.Teller,'CustRes',Description,'',
                                             Additional,QueryToPackText(DomInfo));
            end;
         end
         else if ((TxnType = 'MOPaid') and (ProgID = 'MOPaid Complete')) or
                 ((TxnType = 'MFPaid') and (ProgID = 'MFPaid Complete')) then // Pay Money Order
         begin
            if CheckSeries(Description) then
            begin
               MoneyOrder:=TMoneyOrder.Create;
               try
                  MoneyOrder.Series:=Description;
                  MoneyOrder.RemFromList(StrToIntDef(Office,0));
                  if GetGPCSRegString('Indigo3','Money Order Database Here','No') = 'Yes' then
                  begin
                     MoneyOrder.Series:=Description;
                     MoneyOrder.PayOffice:=StrToIntDef(Office,0);
                     MoneyOrder.PayClerk:=GetUserNumber(Teller);
                     MoneyOrder.PayPeriod:=TodayAsPeriod;
                     MoneyOrder.Events:=TMOEvents.Create;

                     MOEvent:=TMOEvent.Create;
                     MOEvent.EvType :=Integer(evPaid);
                     MOEvent.EvWho  :=GetUserNumber(Teller);
                     MOEvent.EvWhere:=StrToIntDef(Office,0);
                     MOEvent.EvWhen :=DateTimeToMoment(Now);
                     MoneyOrder.Events.Add(MOEvent);

                     MOEvent :=TMOEvent.Create;
                     MOEvent.EvType :=Integer(evPayLodged);
                     MOEvent.EvWho  :=GetUserNumber(Teller);
                     MOEvent.EvWhere:=StrToIntDef(Office,0);
                     MOEvent.EvWhen :=DateTimeToMoment(Now);
                     MoneyOrder.Events.Add(MOEvent);

                     MoneyOrder.SaveToTable('PSL');
                  end;
               except
                  on E:Exception do
                     RaiseGUIDException('{88CA10FB-FE2D-4C13-973D-14C6CCD58E45}',E);
               end;
               MoneyOrder.Free;
            end;
         end
         else if (TxnType = 'MFIssue') or (TxnType = 'MOIssue') then // Issue Money Order
         begin
            if CheckSeries(Copy(Description,1,MOSeriesLength)) then
            begin
               MoneyOrder:=TMoneyOrder.Create;
               try
                  MoneyOrder.Series:=CleanMOSeries(Copy(Description,1,MOSeriesLength));
                  if GetGPCSRegString('Indigo3','Money Order Database Here','No') = 'Yes' then
                  begin
                     MoneyOrder.Position:=TMOPosition.Create;
                     MoneyOrder.Position.CurrentOffice:=StrToInt(GetGPCSRegString('OfficeInfo','Office ID','3201'));
                     MoneyOrder.Position.When         :=TodayAsPeriod;
                     MoneyOrder.Position.Dispatched   :=0;
                     if I3UINode = nil then
                        I3UINode:=CreateI3UINode('');
                     if Assigned(I3UINode) then
                     begin
                        MoneyOrder.Position.NextOffice:=FindNextOffice(I3UINode, MoneyOrder.Position.CurrentOffice, MoneyOrder.PayOffice);
                     end
                     else
                        MoneyOrder.Position.NextOffice:=0;

                     MoneyOrder.Events:=TMOEvents.Create;
                     MoneyOrder.Fees:=TMOFees.Create;
                     MOFee:=TMOFee.Create;
                     MOFee.FeeType:=ftCommission;
                     MOFee.Value:=Value;
                     MoneyOrder.Fees.Add(MOFee);
                     MOEvent:=TMOEvent.Create;
                     MOEvent.EvType :=Integer(evIssued);
                     MOEvent.EvWho  :=GetUserNumber(Teller);
                     MOEvent.EvWhere:=StrToIntDef(Office,0);
                     MOEvent.EvWhen :=DateTimeToMoment(Now);
                     MoneyOrder.Events.Add(MOEvent);

                     TxnDomInfoLines:=TDomInfoLines.Create;
                     TxnDomInfoLines.PackText:=DomInfo;
                     if TxnDomInfoLines.Count > 0 then
                     begin
                        MODetail:=TMODetail.Create;
                        MODetail.Sender:=TPerson.Create;
                        MODetail.Sender.Name:=TName.Create;
                        MODetail.Sender.Address:=TAddress.Create;
                        MODetail.Recipient:=TPerson.Create;
                        MODetail.Recipient.Name:=TName.Create;
                        MODetail.Recipient.Address:=TAddress.Create;

                        for J:=0 to TxnDomInfoLines.Count-1 do
                        begin
                           if Pos('SendersSearchName',TxnDomInfoLines.Element[J].Name) <> 0  then
                              MODetail.Sender.Name.Family:=TxnDomInfoLines.Element[J].Text
                           else if Pos('SendersOtherNames',TxnDomInfoLines.Element[J].Name) <> 0  then
                              MODetail.Sender.Name.Others:=TxnDomInfoLines.Element[J].Text
                           else if Pos('SendersTelephone',TxnDomInfoLines.Element[J].Name) <> 0  then
                              MODetail.Sender.Address.Telephone:=TxnDomInfoLines.Element[J].Text
                           else if Pos('SendersPOBox',TxnDomInfoLines.Element[J].Name) <> 0  then
                              MODetail.Sender.Address.POBox:=StrToIntDef(TxnDomInfoLines.Element[J].Text,0)
                           else if Pos('SendersAddress',TxnDomInfoLines.Element[J].Name) <> 0  then
                              MODetail.Sender.Address.MainLine:=TxnDomInfoLines.Element[J].Text
                           else if Pos('SendersMessage',TxnDomInfoLines.Element[J].Name) <> 0  then
                              MODetail.Info:=TxnDomInfoLines.Element[J].Text
                           else if Pos('PayeesSearchName',TxnDomInfoLines.Element[J].Name) <> 0  then
                              MODetail.Recipient.Name.Family:=TxnDomInfoLines.Element[J].Text
                           else if Pos('PayeesOtherNames',TxnDomInfoLines.Element[J].Name) <> 0  then
                              MODetail.Recipient.Name.Others:=TxnDomInfoLines.Element[J].Text
                           else if Pos('PayeesTelephone',TxnDomInfoLines.Element[J].Name) <> 0  then
                              MODetail.Recipient.Address.Telephone:=TxnDomInfoLines.Element[J].Text
                           else if Pos('PayeesPOBox',TxnDomInfoLines.Element[J].Name) <> 0  then
                              MODetail.Recipient.Address.POBox:=StrToIntDef(TxnDomInfoLines.Element[J].Text,0)
                           else if Pos('PayeesAddress',TxnDomInfoLines.Element[J].Name) <> 0  then
                              MODetail.Recipient.Address.MainLine:=TxnDomInfoLines.Element[J].Text;
                        end;
                        MoneyOrder.Details:=MODetail;
                     end;
                     TxnDomInfoLines.Free;
                     MoneyOrder.SaveToTable('PSL');
                  end;
                //  MoneyOrder.SaveToList(StrToIntDef(Office,0));
                  MoneyOrder.SaveToList(0);
               except
                  on E:Exception do
                     RaiseGUIDException('{CA41A653-DDB3-4BAE-9910-C5A99597CE01}',E);
               end;  
               MoneyOrder.Free;
            end;
         end
         else if TxnType = 'RepMOPList' then
         begin
            MoneyOrder:=TMoneyOrder.Create;
            try
               MoneyOrder.ReplaceList(DomInfo);
            except
               on E:Exception do
                  RaiseGUIDException('{9B446947-5352-4338-A535-3976E9CF2818}',E);
            end;
            MoneyOrder.Free;
         end
         else if TxnType = 'MOIInfo' then // Issue Money Order
         begin
            MoneyOrder:=TMoneyOrder.Create;
            try
            MoneyOrder.PackedString:=DomInfo;
            if GetGPCSRegString('Indigo3','Money Order Database Here','No') = 'Yes' then
               MoneyOrder.SaveToTable('PSL');
            MoneyOrder.SaveToList(StrToIntDef(Office,0));
            except
               on E:Exception do
                  RaiseGUIDException('{9B446947-5352-4338-A535-3976E9CF2818}',E);
            end;
            MoneyOrder.Free;
         end
         else if TxnType = 'MOPInfo' then // Issue Money Order
         begin
           MoneyOrder:=TMoneyOrder.Create;
            try
               MoneyOrder.PackedString:=DomInfo;
               MoneyOrder.RemFromList(StrToIntDef(Office,0));
            except
               on E:Exception do
                  RaiseGUIDException('{4510FADA-5927-4B6D-B8F1-C3BC91D4541D}',E);
            end;
            MoneyOrder.Free;
         end
         else if TxnType ='SetUser' then
         begin
            SLExtra := TStringList.Create ;
            try
               SLExtra.CommaText := DomInfo ;
               NetManager:=CreateOleObject('UserManager.NetUser') as INetUser;;
               NetManager.AddOrUpdateUser('', SLExtra[0], SLExtra[1], SLExtra[2], SLExtra[3], SLExtra[4]);
            finally
               SLExtra.Free;
               NetManager:=nil;
            end;
         end
         else if TxnType ='DelUser' then
         begin
            try
               NetManager:=CreateOleObject('UserManager.NetUser') as INetUser;;
               NetManager.AddOrUpdateUser('', DomInfo, '', '^Delete', '', '');
               //NetManager.DeleteUser('', DomInfo);
            finally
               NetManager:=nil;
            end;
         end;
      end;
      SL.Free;
   except
      On E : Exception do
        RaiseGUIDException('{CA872063-A3FD-4C85-BB2F-03E9C55AFEBD}', E);
   end ;
   LogProgress(2,'TTxnProcessor.AddRecord end');
end;

function ProgIDToServer(ProgID:String):String;
begin
   Result:=GUIDToString(ProgIDToClassID(ProgID));
   if Result <> '' then
   begin
      try
         Result:=RegistryEx.ReadRegistryStringValue('HKCR\CLSID\'+Result+'\InProcServer32\');
      except
         on E:Exception do
            RaiseGUIDException('{8F06FC03-E0FD-4C81-9C14-56621F1E2283}',E);
      end;
   end;
end;
procedure CallDLLFunc(FuncName,MessageData:String);
var
   DLLName   :String;
   LibHandle :THandle;
   DLLFunc:TDLLFunc;
begin
   DLLName   := ProgIDToServer('Utility.TBuilder');
   LibHandle := LoadLibrary(PChar(DLLName));
   try
      @DLLFunc:=GetProcAddress(LibHandle,PChar(FuncName));
      if @DLLFunc <> nil then
         DLLFunc(MessageData);
   except
      on E:Exception do
         RaiseGUIDException('{540D14D7-1266-4EB0-BEE1-2C53FB230003}',E);
   end;
   if LibHandle <> 0 then
      FreeLibrary(LibHandle);
end;

procedure TTxnProcessor.ReceiveMessage(Data:String;LocalData:Boolean;MinPeriod:Integer;FileTxStatus:TFileTxStatus;MsgIndex:Integer);
var
   RecordsSL  : TPackStringList;
   RecordSL   : TTxnLogLine;
   RecordIndex, FieldIndex : Integer;
   DT:TDateTime;
   Found:Boolean;
   Code:Integer;
const
   ThisOfficeID:Integer=-1;
begin
   LogProgress(2,'TTxnProcessor.ReceiveMessage start '+IntToStr(Integer(LocalData))+' '+IntToStr(MinPeriod)+' '+Data);
   if ThisOfficeID = -1 then
      ThisOfficeID:=StrToIntDef(GetGPCSRegString('OfficeInfo','Office ID','3201'),3201);
   if LocalData then Exit;                   
   try
      RecordsSL:=TPackStringList.Create;
      RecordSL :=TTxnLogLine.Create;
      try
         RecordsSL.PackText:=Data; //grab all packed records
//         TxnLogTable.DataBaseName:=PSLDataBase.DatabaseName;
//         TxnLogTable.DataBaseName:='PSL';
         if not TxnLogTable.Active then
            TxnLogTable.Active:=True;

         for RecordIndex:=0 to RecordsSL.Count-1 do
         begin
            RecordSL.PackText:=RecordsSL[RecordIndex];
            if (RecordSL.Period >= MinPeriod) 
            and (WriteDataForOtherOffices or (RecordSL.Office = ThisOfficeID)) then
            begin                   
               if CentralSystemDatabase then
                  Found:=TxnLogTable.FindKey([RecordSL.RecordID,RecordSL.WSNumber,RecordSL.Office])
               else
                  Found:=TxnLogTable.FindKey([RecordSL.RecordID,RecordSL.WSNumber]);
               if not Found then
               begin
                  try
                     TxnLogTable.Append;
                     if VarIsEmpty(RecordSL.Office)   then RecordSL.Office  :=0;
                     if VarIsEmpty(RecordSL.Price )   then RecordSL.Price   :=0;
                     if VarIsEmpty(RecordSL.TxnValue) then RecordSL.TxnValue:=0;
                     for FieldIndex:=0 to RecordSL.Count-1 do
                     begin
                       if ((TxnLogTable.Fields[FieldIndex] is TDateTimeField)
                       or  (TxnLogTable.Fields[FieldIndex] is TTimeField)
                       or  (TxnLogTable.Fields[FieldIndex] is TDateField)) then
                       begin
                          Val(RecordSL[FieldIndex],DT,Code);
                          TxnLogTable.Fields[FieldIndex].Value:=DT;
                       end
                       else
                          TxnLogTable.Fields[FieldIndex].AsString:=RecordSL[FieldIndex];
                     end;
                     TxnLogTable.Post;
                  except
                     on E:Exception do
                        RaiseGUIDException('{5FAE6303-A43F-4A64-BE73-A7AC80DE18DE}',E);
                  end;
               end;
               if RecordIndex = RecordsSL.Count-1 then
                  AddRecord(RecordsSL[RecordIndex],bpLast,FileTxStatus)
               else if RecordIndex = 0 then
                  AddRecord(RecordsSL[RecordIndex],bpFirst,FileTxStatus)
               else
                 AddRecord(RecordsSL[RecordIndex],bpMiddle,FileTxStatus);
            end;
         end;
         if (WriteDataForOtherOffices and (RecordSL.Office <> ThisOfficeID))
         and (GetPSLRegString('Table Builder','Enabled','0') = '1') then
            CallDLLFunc('CheckData',Data);  
      finally
        TxnLogTable.Active:=False;
        RecordSL.Free;
        RecordsSL.Free;
      end;

   except
      On E : Exception do
        RaiseGUIDException('{9DE71827-802F-4BE9-BDB5-74ACAE00C493}', E);
   end;
   LogProgress(2,'TTxnProcessor.ReceiveMessage end');
end;
function IsServiceRunning:Boolean;
var
   Event:TEvent;
begin
   LogProgress(2,'IsServiceRunning start');
   Event:=TEvent.Create('CorvusServiceIsRunning',True,False);
   Event.Reset;
   Result:=Event.Wait(1000);
   Event.Free;
   if not Result then
      RaiseGUIDError('{705AF5BE-FA18-41EB-B520-9934CC6C0B7E}', 'Service is not Running');
   LogProgress(2,'IsServiceRunning end '+IntToStr(Integer(Result)));
end;                                    

function GetServiceParameter(EventID:Integer;ParamName:String):Variant;
var
   Mutex:TMutex;
begin
   LogProgress(2,'GetServiceParameter start '+IntToStr(EventID)+' '+ParamName);
   Result:=Unassigned;
   Mutex:=TMutex.Create('CorvusServiceFileAccess');
   if Mutex.Get(INFINITE) then
   begin
      try
         Result:=ServiceSharedData.GetVariable(IntToHex(EventID,8)+ParamName);
      finally
         Mutex.Release;
      end;
   end;
   Mutex.Free;
   try
      case VarType(Result) of
         varSmallint,varInteger : LogProgress(2,'GetServiceParameter end '+IntToStr(EventID)+' '+ParamName+' '+IntToStr  (Result));
         varSingle,varDouble    : LogProgress(2,'GetServiceParameter end '+IntToStr(EventID)+' '+ParamName+' '+FloatToStr(Result));
         varCurrency            : LogProgress(2,'GetServiceParameter end '+IntToStr(EventID)+' '+ParamName+' '+CurrToStr (Result));
         varDate                : LogProgress(2,'GetServiceParameter end '+IntToStr(EventID)+' '+ParamName+' '+DateToStr (Result));
         varOleStr,varString    : LogProgress(2,'GetServiceParameter end '+IntToStr(EventID)+' '+ParamName+' '+Result);
         else                     LogProgress(2,'GetServiceParameter end '+IntToStr(EventID)+' '+ParamName);
      end;
   except
      LogProgress(2,'GetServiceParameter end');
   end;
end;              
procedure PassServiceParameter(EventID:Integer;ParamName:String;ParamValue:Variant);
var
   Mutex:TMutex;
begin
   try
      case VarType(ParamValue) of
         varSmallint,varInteger : LogProgress(2,'PassServiceParameter start '+IntToStr(EventID)+' '+ParamName+' '+IntToStr  (ParamValue));
         varSingle,varDouble    : LogProgress(2,'PassServiceParameter start '+IntToStr(EventID)+' '+ParamName+' '+FloatToStr(ParamValue));
         varCurrency            : LogProgress(2,'PassServiceParameter start '+IntToStr(EventID)+' '+ParamName+' '+CurrToStr (ParamValue));
         varDate                : LogProgress(2,'PassServiceParameter start '+IntToStr(EventID)+' '+ParamName+' '+DateToStr (ParamValue));
         varOleStr,varString    : LogProgress(2,'PassServiceParameter start '+IntToStr(EventID)+' '+ParamName+' '+Copy(ParamValue,1,255));
         else                     LogProgress(2,'PassServiceParameter start '+IntToStr(EventID)+' '+ParamName);
      end;
   except
      LogProgress(2,'PassServiceParameter start '+IntToStr(EventID)+' '+ParamName);
   end;
   
   Mutex:=TMutex.Create('CorvusServiceFileAccess');     
   if Mutex.Get(INFINITE) then
   begin
      try
         ServiceSharedData.SetVariable(IntToHex(EventID,8)+ParamName,ParamValue);
      finally
         Mutex.Release;
      end;
   end;
   Mutex.Free;
   LogProgress(2,'PassServiceParameter end ');
end;              
procedure RemoveServiceParameter(EventID:Integer;ParamName:String);
var
   Mutex:TMutex;
begin
   LogProgress(2,'RemoveServiceParameter start '+IntToStr(EventID)+' '+ParamName);
   Mutex:=TMutex.Create('CorvusServiceFileAccess');
   if Mutex.Get(INFINITE) then
   begin
      try
         ServiceSharedData.RemoveVariable(IntToHex(EventID,8)+ParamName);
      finally
         Mutex.Release;
      end;
   end;
   Mutex.Free;
   LogProgress(2,'RemoveServiceParameter end');
end;              

function GetFunctionExecuteID:Integer;
var
   SL:TStrings;
   I:Integer;
   Mutex:TMutex;
begin
   LogProgress(2,'GetFunctionExecuteID start ');
   Result:=-1;
   SL:=nil;
   Mutex:=TMutex.Create('CorvusServiceFileAccess');
   if Mutex.Get(INFINITE) then
   begin
      try
         SL:=ServiceSharedData.List;
      finally
         Mutex.Release;
      end;
   end;
   Mutex.Free;
   if SL <> nil then
   begin
      for I:=0 to SL.Count-1 do
      begin
         if Copy(SL[I],9,15) = 'FunctionExecute' then
         begin
            Result:=StrToIntDef('$'+Copy(SL[I],1,8),-1);
            RemoveServiceParameter(Result,'FunctionExecute');
            SL.Free;
            Exit;
         end;
      end;
      SL.Free;
   end;
   LogProgress(2,'GetFunctionExecuteID end '+IntToStr(Result));
end;
function HasServiceResponded(msTimeOut:Integer;EVID:String):Boolean;
var
   Event:TEvent;
   ResponseEvent:TEvent;
   I:Integer;
begin
   LogProgress(2,'HasServiceResponded start '+EVID);
   msTimeOut:=msTimeOut div 2;              
   for I:=1 to 2 do
   begin
      ResponseEvent:=TEvent.Create('FunctionComplete'+EVID,True,False);
      ResponseEvent.Reset;
      Event:=TEvent.Create('FunctionExecute',True,False);
      Event.Signal;
      Result:=ResponseEvent.Wait(msTimeOut);
      ResponseEvent.Free;
      Event.Free;
      if Result then 
         break;
   end;
   LogProgress(2,'HasServiceResponded end '+IntToStr(Integer(Result)));
end;
function IsServiceBusy:Boolean;
begin
   LogProgress(2,'IsServiceBusy start');
   Result:=True;
   if FileExists('C:\ServiceIsBusy.lck') then Exit;
   Result:=False;
   LogProgress(2,'IsServiceBusy end '+IntToStr(Integer(Result)));
end;              
function IsServiceUsingStock:Boolean;
begin
   LogProgress(2,'IsServiceUsingStock start');
   Result:=True;
   if FileExists('C:\ServiceUsingStock.lck') then Exit;
   Result:=False;
   LogProgress(2,'IsServiceUsingStock end '+IntToStr(Integer(Result)));
end;              
function RequestServiceData(RequestName,ParameterData:String):String;
var
   I:Integer;
begin
   LogProgress(2,'RequestServiceData start '+RequestName+' '+ParameterData);
   if ServiceSharedData = nil then
   begin
      MemoryFileName:='C:\CorvusServiceFile.Dat';
      ServiceSharedData:=TSharedData.Create('CorvusService',False);
   end;
   if ServiceSharedData.IsValid then
   begin
      Inc(EventID);
      PassServiceParameter(EventID,'FunctionExecute',1);
      PassServiceParameter(EventID,RequestName,1);
      PassServiceParameter(EventID,'ParameterData',ParameterData);
      I:=0;
      while (I < 10) and (not HasServiceResponded(5000,IntToHex(EventID,8))) do
        Inc(I);
      Result:=GetServiceParameter(EventID,'ParameterData');
      RemoveServiceParameter(EventID,RequestName);
      RemoveServiceParameter(EventID,'ParameterData');
   end;                                                    
   LogProgress(2,'RequestServiceData end '+Result);
end;
function SetGMemory(Data:String):String;
begin
   Result:=RequestServiceData('SetGMemory',Data);
end;
function RequestGMemory(MachineName:String):String;
begin                               
   Result:=RequestServiceData('GetGMemory',MachineName);
end;
function SendDGram(Data:String):String;
begin
   Result:=RequestServiceData('SendDGram',Data);
end;
function CopyOnDistributionFiles:Boolean;
var
   I:Integer;
   FileList:TStringList;
begin
   Result:=True;
   FileList:=TStringList.Create;
   try
      FillFileList('A:\','*.SMF',False,FileList);
   except
      Result:=False;
   end;        
   if FileList.Count > 0 then
   begin
      ForceDirectories(TransactionFilesDir);
      for I:=0 to FileList.Count-1 do
      begin
         try
            CopyFile(PChar(FileList[I]),PChar(TransactionFilesDir+'\'+ExtractFileName(FileList[I])+'.1ST'),False);
            RenameFile(TransactionFilesDir+'\'+ExtractFileName(FileList[I])+'.1ST',TransactionFilesDir+'\'+ExtractFileName(FileList[I]));
         except
            Result:=False;
         end;
      end;
   end;
   FileList.Free;
end;

function CreateServiceDistFile(DeliveryType:TDeliveryType;DestinationOffice,msTimeOut:Integer;SendBy,ExpiresOn:TDateTime;PhysicalLayout,LogicalLayout:String;MessageType:TMessageType;MessageVersion:Integer;MessageName,MessageData:String):Boolean;
var
   FileName:String;
   SL:TMessageWrapper;
   FS:TFileStream;
   SS:TStringStream;
const                                
   LastFileNumber:Integer = 0;
begin
   Result:=False;
   LogProgress(2,'CreateServiceDistFile start '+MessageName+' '+MessageData);
   
   ForceDirectories(DistributionFilesDir);
   SL:=TMessageWrapper.Create;
   try
      SL.DeliveryType     :=dtDistributionFile;
      SL.DestinationOffice:=DestinationOffice;
      SL.SendBy           :=SendBy           ;
      SL.ExpiresOn        :=ExpiresOn        ;
      SL.PhysicalLayout   :=PhysicalLayout   ;
      SL.LogicalLayout    :=LogicalLayout    ;
      SL.MessageType      :=MessageType      ;
      SL.MessageVersion   :=MessageVersion   ;
      SL.MessageName      :=MessageName      ;
      SL.MessageData      :=MessageData      ;
      SL.WrapperType      :='SMF'            ;
      
      SS:=TStringStream.Create(SL.PackText);
      SL.Free;
      
      FileName:=DistributionFilesDir+'\OSMIUM_'+ZeroPad(DestinationOffice,5)+'_'+MessageName+'.SMF';
      FS:=TFileStream.Create(FileName,fmCreate or fmShareDenyNone);
      
      TCompressor.CompressStream(SS,FS);

      SS.Free;
      FS.Free;
      
      Result:=True;
   except
      on E:Exception do 
         RaiseGUIDException('{E35C37A8-2CDB-4831-85D9-4CFD7C389650}',E);
   end;  
   LogProgress(2,'CreateServiceDistFile end');
end;
function SendServiceMessage(DeliveryType:TDeliveryType;DestinationOffice,msTimeOut:Integer;SendBy,ExpiresOn:TDateTime;PhysicalLayout,LogicalLayout:String;MessageType:TMessageType;MessageVersion:Integer;MessageName,MessageData:String):Boolean;
var
   FileName:String;
   SL:TMessageWrapper;
const                                
   ServiceRunning:Boolean=False;
   LastFileNumber:Integer = 0;
begin
   Result:=False;
   LogProgress(2,'SendServiceMessage start '+MessageName+' '+MessageData);
   
   ForceDirectories(TransactionFilesDir);
   SL:=TMessageWrapper.Create;
   try
      SL.DeliveryType     :=DeliveryType     ;
      SL.DestinationOffice:=DestinationOffice;
      SL.SendBy           :=SendBy           ;
      SL.ExpiresOn        :=ExpiresOn        ;
      SL.PhysicalLayout   :=PhysicalLayout   ;
      SL.LogicalLayout    :=LogicalLayout    ;
      SL.MessageType      :=MessageType      ;
      SL.MessageVersion   :=MessageVersion   ;
      SL.MessageName      :=MessageName      ;
      SL.MessageData      :=MessageData      ;
      SL.WrapperType      :='TXN'            ;
      
      FileName:=TransactionFilesDir+'\TXNS_'+ZeroPad(LastFileNumber,8)+'.';
      while FileExists(FileName+'1ST') 
         or FileExists(FileName+'2ND')
         or FileExists(FileName+'3RD')
         or FileExists(FileName+'4TH') do
      begin
         Inc(LastFileNumber);
         FileName:=TransactionFilesDir+'\TXNS_'+ZeroPad(LastFileNumber,8)+'.';
      end;
      
      Inc(LastFileNumber);
      SL.SaveToFile(FileName+'1ST');
      SL.Free;
      
      RenameFile(FileName+'1ST',FileName+'2ND');
      Result:=True;
   except
      on E:Exception do 
         RaiseGUIDException('{E35C37A8-2CDB-4831-85D9-4CFD7C389650}',E);
   end;  
   LogProgress(2,'SendServiceMessage end');
end;
function SendServiceRMessage(AMessage:TMessageAccess;FileTxStatus:TFileTxStatus;CommandType:TCommandType):Boolean;
var
   FileName:String;
   SL:TMessageWrapper;
const
   LastFileNumber:Integer = 0;
begin
   Result:=False;
   LogProgress(2,'SendServiceRMessage start ');
   
   if FileTxStatus.FStatusMonitor.ReceivedBlocks.Bit[AMessage.Office,AMessage.WorkStation,AMessage.Identifier] = False then
   begin
      FileTxStatus.FStatusMonitor.ReceivedBlocks.Bit[AMessage.Office,AMessage.WorkStation,AMessage.Identifier]:=True;
      ForceDirectories(TransactionFilesDir);
      SL:=TMessageWrapper.Create;
      try
         SL.DeliveryType     :=AMessage.DeliveryType     ;
         SL.DestinationOffice:=AMessage.DestinationOffice;
         SL.SendBy           :=AMessage.SendBy           ;
         SL.ExpiresOn        :=AMessage.ExpiryDate       ;
         SL.PhysicalLayout   :=AMessage.PhysicalLayout   ;
         SL.LogicalLayout    :=AMessage.LogicalLayout    ;
         SL.MessageType      :=AMessage.MessageType      ;
         SL.MessageVersion   :=AMessage.MessageVersion   ;
         SL.MessageName      :=AMessage.MessageName      ;
         SL.MessageData      :=AMessage.MessageData      ;
         SL.FromWorkstation  :=AMessage.WorkStation      ;
         SL.FromOffice       :=AMessage.Office           ;
         SL.Identifier       :=AMessage.Identifier       ;
         SL.Flags            :=AMessage.Flags            ;
         SL.MessageRecVersion:=AMessage.MessageRecVersion;
         SL.CRC 			     :=AMessage.CRC 			      ; 
         
         if CommandType = ctSetDataRemote then
            SL.WrapperType:='RMSG'
         else
            SL.WrapperType:='MSG';

         FileName:=TransactionFilesDir+'\MSGS_'+ZeroPad(LastFileNumber,8)+'.';
         while FileExists(FileName+'1ST') 
            or FileExists(FileName+'2ND')
            or FileExists(FileName+'3RD')
            or FileExists(FileName+'4TH') do
         begin
            Inc(LastFileNumber);
            FileName:=TransactionFilesDir+'\MSGS_'+ZeroPad(LastFileNumber,8)+'.';
         end;
      
         Inc(LastFileNumber);
         SL.SaveToFile(FileName+'1ST');
         SL.Free;
      
         RenameFile(FileName+'1ST',FileName+'2ND');
         Result:=True;
      except
         on E:Exception do 
            RaiseGUIDException('{18C3FF01-85B8-4F31-909B-D804B3589983}',E);
      end;  
   end;  
   LogProgress(2,'SendServiceRMessage end');
end;                                 
function SendServiceFile(AFile:String;Office,WorkStation:Integer):Boolean;
var                                           
   FileName:String;
   SL:TMessageWrapper;
const
   LastFileNumber:Integer = 0;
begin
   Result:=False;
   LogProgress(2,'SendServiceFile start ');
   
   ForceDirectories(TransactionFilesDir);
   SL:=TMessageWrapper.Create;
   try                      
      SL.MessageData      :=AFile      ;
      SL.WrapperType      :='FILE'     ;
      SL.FromWorkstation  :=WorkStation;
      SL.FromOffice       :=Office     ;
                                 
      FileName:=TransactionFilesDir+'\FILE_'+ZeroPad(LastFileNumber,8)+'.';
      while FileExists(FileName+'1ST') 
         or FileExists(FileName+'2ND')
         or FileExists(FileName+'3RD')
         or FileExists(FileName+'4TH') do
      begin
         Inc(LastFileNumber);
         FileName:=TransactionFilesDir+'\FILE_'+ZeroPad(LastFileNumber,8)+'.';
      end;
      
      Inc(LastFileNumber);
      SL.SaveToFile(FileName+'1ST');
      SL.Free;
      
      RenameFile(FileName+'1ST',FileName+'2ND');
      Result:=True;
   except
      on E:Exception do 
         RaiseGUIDException('{39FB339A-EC33-44BD-88C5-F95D76E1EE42}',E);
   end;  
   LogProgress(2,'SendServiceFile end');
end;              
procedure UpdateStatus;
begin
   LogProgress(2,'UpdateStatus start');
   if ServiceSharedData = nil then
   begin
      MemoryFileName:='C:\CorvusServiceFile.Dat';
      ServiceSharedData:=TSharedData.Create('CorvusService',False);
   end;
   if ServiceSharedData.IsValid then
   begin
      Inc(EventID);
      PassServiceParameter(EventID,'FunctionExecute',1);
      PassServiceParameter(EventID,'UpdateStatus',1);
      HasServiceResponded(3000,IntToHex(EventID,8));
      RemoveServiceParameter(EventID,'UpdateStatus');
   end;
   LogProgress(2,'UpdateStatus end');
end;

function GetOfficesNode(var OfficeRouteInfo:TParseNode):TCorvusNode;
var
   Offices:TCorvusNode;   
begin                     
   Result:=nil;
   if OfficeRouteInfo = nil then
   begin
      OfficeRouteInfo:=TParseNode.Create('OfficeRouteInfo',OfficeRoutesInfo,0);
      OfficeRouteInfo.ParseFile(ExtractFilePath(OfficeRoutesInfo),ExtractFileName(OfficeRoutesInfo),0);
   end;               
   Offices:=OfficeRouteInfo.NodeNamed('OfficesRoutes');
   if Offices <> nil then
      Result:=Offices.NodeNamed('Offices');
end;
function TFileTxStatus.WriteTransaction(Office,WSNumber,Period:Integer;DateTime:TDateTime;RecIndex,PLU:Integer;Price,TxnValue:Currency;Quantity:Integer;ProgID,User,RecType,Description,Ident,Info,DomInfo:String):Boolean;
var
   TxnLogLine:TTxnLogLine;
   TxnLogLines:TTxnLogLines;
   MessageAccess:TMessageAccess;
   ContainsMoneyOrder,ContainsPension:Boolean;
   SS:TStringStream;
begin                      
   Result:=False;
   try
      TxnLogLine:=TTxnLogLine.Create;
      TxnLogLine.Office     :=Office     ;      
      TxnLogLine.WSNumber   :=WSNumber   ;      
      TxnLogLine.Period     :=Period     ;      
      TxnLogLine.DateTime   :=DateTime   ;      
      TxnLogLine.RecIndex   :=RecIndex   ;      
      TxnLogLine.PLU        :=PLU        ;      
      TxnLogLine.Price      :=Price      ;      
      TxnLogLine.TxnValue   :=TxnValue   ;      
      TxnLogLine.Quantity   :=Quantity   ;      
      TxnLogLine.Prod       :=ProgID     ;      
      TxnLogLine.Teller     :=User       ;      
      TxnLogLine.RecType    :=RecType    ;      
      TxnLogLine.Description:=Description;      
      TxnLogLine.Ident      :=Ident      ;      
      TxnLogLine.Info       :=Info       ;      
      TxnLogLine.DomInfo    :=DomInfo    ;      
      TxnLogLines:=TTxnLogLines.Create;         
      TxnLogLines.Add(TxnLogLine.PackText);     
      TxnLogLines.PackText:=ProcessTransactionsIntoDB(TxnLogLines.PackText,ContainsMoneyOrder,ContainsPension,0,Self);
      TxnLogLines.PackText:=ProcessTransactionsIntoDB('Finished',ContainsMoneyOrder,ContainsPension,0,Self);
      MessageAccess:=
      FFileBlockMgr.AddMessage(
              ThisOfficeID,
              Workstation,0,
              dtTransaction,0,Now+60,Now+180,
              'Data','Data',
              mtTransaction,1,'',TxnLogLines.PackText,
              True);
      FFileBlockMgr.Flush;
      if FStatusMonitor <> nil then
         FStatusMonitor.SetStatus(FileBlockMgr.GetStatus);
      if MessageAccess <> nil then
      begin
         MessageAccess.Flags:=MessageAccess.Flags and (not MessageProcessed) ;
         FFileBlockMgr.SetMessageFlags(ThisOfficeID,Workstation,MessageAccess.Identifier,MessageAccess.Flags);
         UpdateLists(MessageAccess.Flags,ThisOfficeID,Workstation,MessageAccess.Identifier,Self,nil);
         if (FStatusMonitor <> nil) then
         begin
            SS:=TStringStream.Create('');
            DataTxEvent(FStatusMonitor,
                        FThisOfficeID,
                        FWorkstation,MessageAccess.Identifier,SS);
            FStatusMonitor.SendData(SS.DataString);
            Windows.Beep(5000,20);
            SS.Free;
         end;
         MessageAccess.Free;
         Result:=True;
      end;
      TxnLogLine.Free;
      TxnLogLines.Free;
   except
      on E:Exception do
      begin
         RaiseGUIDException('{123582FB-4E20-4EF9-A958-D45A289C0BD4}',E);
      end;
   end;               
end;
function TFileTxStatus.OfficeList:String;
var
   I:Integer;
   SL:TPackStringList;
   OffCodeRef:TOffCodeRef;
begin
   SL:=TPackStringList.Create;
   OffCodeRef:=TOffCodeRef.Create;
   if FOfficeReference = nil then FillOfficeReference;
   for I:=0 to FOfficeReference.Count-1 do
   begin
      OffCodeRef.PackText:=FOfficeReference[I];
      SL.Add(OffCodeRef.OfficeTitle);
   end;
   OffCodeRef.Free;
   SL.Sort;
   Result:=SL.Text;
   SL.Free;
end;
function TFileTxStatus.SetGMemory(Data:String):String;
var
   SL:TPackStringList;
begin
   Result:='Fail';
   GlobalMemory.MyData:=Data;
   if FStatusMonitor <> nil then
   begin
      SL:=TPackStringList.Create;
      SL.Add(GetLocalMachineName);
      SL.Add(GlobalMemory.MyData);
      FStatusMonitor.SendGlobalMemory(SL.PackText);
      SL.Free;
      Result:='OK';
   end;
end;
function TFileTxStatus.GetGMemory(MachineName:String):String;
var
   I:Integer;
begin
   Result:='';
   I:=GlobalMemory.Others.IndexOf(MachineName);
   if (I <> -1) and (GlobalMemory.Others.Objects[I] <> nil) then
      Result:=TStringObject(GlobalMemory.Others.Objects[I]).Value;
end;
function TFileTxStatus.SendUserDataGram(Data:String):String;
begin   
   Result:='Fail';
   if FStatusMonitor <> nil then
   begin
       if Data = 'ShutdownAll' then
           FStatusMonitor.SendCommand(0,0,ctShutdown,'')
       else if Data = 'RestartAll' then
           FStatusMonitor.SendCommand(0,0,ctRestart,'');
       Result:='OK';
   end;
end;                           
function TFileTxStatus.SendUserMessage(Data:String):String;
var
   UserData:TStringStream;
   UserMessage:TUserMessage;
begin   
   Result:='Fail';          
   UserMessage:=TUserMessage.Create;
   UserMessage.PackText:=Data;
   UserData:=TStringStream.Create(UserMessage.Data);
   Result:=SendCommand(UserMessage.DestinationHost,UserMessage.TimeOut,UserMessage.CommandType,UserData,UserMessage.HangUpAfter)
end;                           
procedure FillListToRoot(RootNode:TCorvusNode;NodeName:string;List:TStrings;var Found:Boolean);
var
   I:Integer;
   SubNode:TCorvusNode;
begin
   if RootNode = nil then Exit;
   if RootNode.IndexOf(NodeName) <> -1 then
   begin
      List.Add(NodeName);
      Found:=True;
   end
   else
   begin
      Found:=False;
      for I:=0 to RootNode.Count-1 do
      begin
         SubNode:=RootNode.Node[I];
         FillListToRoot(SubNode,NodeName,List,Found);
         if Found then break;
      end;
   end;
   if Found then List.Add(RootNode.Name);
end;            

function TFileTxStatus.GetRoute(A,B:Integer;Mapping:String):String;
var
   I:Integer;
   SL:TStringList;
   SLB:TStringList;     
   OfficeAName,OfficeBName:String;
   OfficeRoutes:TCorvusNode;
   Routes:TCorvusNode;
   RouteNode:TCorvusNode;
   LastCommonName:String;
   Found:Boolean;
begin
   SL:=TStringList.Create;
   SLB:=TStringList.Create;
   OfficeRoutes:=nil;
   if OfficeRouteInfo <> nil then
      OfficeRoutes:=OfficeRouteInfo.NodeNamed('OfficesRoutes');
   if OfficeRoutes <> nil then
   begin
      OfficeAName:=OfficeNameFromCode(A);
      OfficeBName:=OfficeNameFromCode(B);
      Routes:=OfficeRoutes.NodeNamed('Routes');
      if Routes <> nil then
      begin
         RouteNode:=Routes.NodeNamed(Mapping);
         if (RouteNode <> nil) and (RouteNode.Count = 1) and (RouteNode.Node[0] <> nil) then
         begin
            FillListToRoot(RouteNode.Node[0],OfficeAName,SL,Found);
            FillListToRoot(RouteNode.Node[0],OfficeBName,SLB,Found);
            LastCommonName:='';
            while (SL.Count > 0) and (SLB.Count > 0) and (SL[SL.Count-1] = SLB[SLB.Count-1]) do
            begin
               LastCommonName:=SL[SL.Count-1];
               SL.Delete(SL.Count-1);
               SLB.Delete(SLB.Count-1);
            end;
            if LastCommonName <> '' then
               SL.Add(LastCommonName);
            for I:=SLB.Count-1 downto 0 do
               SL.Add(SLB[I]);
         end;                       
      end;
   end;                        
   Result:=SL.Text;
   SLB.Free;
   SL.Free;    
end;         
procedure AssignPensionFromDomInfo(var PensionPayment:TMinPensionPayment;TxnDomInfoLines:TDomInfoLines);
var
   J:Integer;
begin
   PensionPayment.ProxyIdentifier :=0;
   for J:=0 to TxnDomInfoLines.Count-1 do
   begin
      if (TxnDomInfoLines.Element[J].Name = 'VoucherNumber'    )
      or (TxnDomInfoLines.Element[J].Name = 'VoucherNumberList') then
         PensionPayment.VoucherNumber:=TxnDomInfoLines.Element[J].Text
      else if TxnDomInfoLines.Element[J].Name = 'ID_Number' then
         PensionPayment.PayeeIdentifier:=TxnDomInfoLines.Element[J].Text
      else if (TxnDomInfoLines.Element[J].Name = 'CustomerName'  )
           or (TxnDomInfoLines.Element[J].Name = 'ROCustomerName') then
         PensionPayment.PayeeName:=TxnDomInfoLines.Element[J].Text
      else if (TxnDomInfoLines.Element[J].Name = 'Amount'  )
           or (TxnDomInfoLines.Element[J].Name = 'ROAmount') then
         PensionPayment.Amount:=TxnDomInfoLines.Element[J].Text;
   end;                          
end;
function TFileTxStatus.NextOffice(Current,Destination:Integer;Mapping:String):Integer;
var
   SL:TStringList;
begin
   Result:=Destination;
   if Current = Destination then Exit;
   SL:=TStringList.Create;
   SL.Text:=GetRoute(Current,Destination,Mapping);
   if SL.Count > 1 then
      Result:=OfficeCodeFromName(SL[1]);
   SL.Free;            
end;
function TFileTxStatus.FindPensionMessage(Office,DestinationOffice:Integer;MessageName:String):Boolean;
var
   WS,Off,I,MsgIndex:Integer;
   MessageData:TMessageAccess;
   PType:String;
begin
   Result:=True;
   for I:=0 to ThePensionsList.Count-1 do
   begin
      PType:=Copy(ThePensionsList[I],15,1);
      if PType = 'P' then // is a pension transaction
      begin
         Off     :=StrToInt('$'+Copy(ThePensionsList[I],1,4));
         WS      :=StrToInt('$'+Copy(ThePensionsList[I],5,2));
         MsgIndex:=StrToInt('$'+Copy(ThePensionsList[I],7,8));
         if (Off = Office) then
         begin
            MessageData:=FileBlockMgr.GetMessage(Off,WS,MsgIndex);
            if (DestinationOffice = MessageData.DestinationOffice)
            and (MessageData.MessageName = MessageName) then
               Exit;
         end;
      end;
   end;
   Result:=False;
end;
function TFileTxStatus.PensionTxnList(OfficeCode:Integer):String;
var
   Status:TStatusBits;
   WS,Off,I,MsgIndex:Integer;
   MessageData:TMessageAccess;
   TxnLine:TTxnLogLine;      
   TxnLineIdx:Integer;
   TxnLines:TTxnLogLines;
   TxnDomInfoLines:TDomInfoLines;
   ResultList:TPackStringList;
   PensionPayment:TMinPensionPayment;
   PType:String;
begin
   ResultList:=TPackStringList.Create;
   TxnLines:=TTxnLogLines.Create;
   TxnLine:=TTxnLogLine.Create;
   TxnDomInfoLines:=TDomInfoLines.Create;
   PensionPayment:=TMinPensionPayment.Create;
   Status:=TStatusBits.Create;    
   Status.State:=Self.Status;
   for I:=0 to ThePensionsList.Count-1 do
   begin
      PType:=Copy(ThePensionsList[I],15,1);
      if PType = 'T' then // is a pension transaction
      begin
         Off     :=StrToInt('$'+Copy(ThePensionsList[I],1,4));
         WS      :=StrToInt('$'+Copy(ThePensionsList[I],5,2));
         MsgIndex:=StrToInt('$'+Copy(ThePensionsList[I],7,8));
         MessageData:=FileBlockMgr.GetMessage(Off,WS,MsgIndex);
         if (MessageData <> nil) then // vaild message 
         begin
            TxnLines.PackText:=MessageData.MessageData;
            for TxnLineIdx:=0 to TxnLines.Count-1 do
            begin
               TxnLine.PackText:=TxnLines[TxnLineIdx];
               if  (TxnLine.RecIndex = 0) and (TxnLine.RecType = 'TxnLine')
               and ((TxnLine.PLU = NormalPensionPLU) or (TxnLine.PLU = ArrearsPensionPLU)) then
               begin
                  TxnDomInfoLines.PackText:=TxnLine.DomInfo;
                  AssignPensionFromDomInfo(PensionPayment,TxnDomInfoLines);
                  ResultList.Add(PensionPayment.PackData);
               end;
            end;
            MessageData.Free
         end;
      end;
   end;
   TxnLines.Free;
   TxnLine.Free;
   TxnDomInfoLines.Free;
   PensionPayment.Free;
   Result:=ResultList.PackText;
   ResultList.Free;
end;
function TFileTxStatus.MoneyOrderPayList(OfficeCode:Integer;MOTypes:Integer):String;
var
   Status:TStatusBits;
   WS,Off,I,MsgIndex,Flags:Integer;
   MessageData:TMessageAccess;
   MOData:TTxnLogLine;
   ResultList:TPackStringList;
   SerialNo:String;
   Value:Currency;
   IOffice:Integer;
   POffice:Integer;
   IClerk :Integer;
   MOType :TMOType;
   IDate  :TDateTime;
   J,Idx:Integer;
   MODetails:TMODetails;
   MOCompare:TMODetails;
   DomInfoLine:TDomInfoLine;
begin
   if TheMOList.Count = 0 then
      TTxnTransfer.FindMOMessages(Self);
   if TheMOList.Count = 0 then Exit;
   ResultList:=TPackStringList.Create;  
   Status:=TStatusBits.Create;    
   Status.State:=Self.Status;
   ResultList.Duplicates:=dupIgnore;
   MODetails:=TMODetails.Create;
   for I:=0 to TheMOList.Count-1 do
   begin
      Off     :=StrToInt('$'+Copy(TheMOList[I],1,4));
      WS      :=StrToInt('$'+Copy(TheMOList[I],5,2));
      MsgIndex:=StrToInt('$'+Copy(TheMOList[I],7,8));
      Flags:=FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex); 
      if  ((Flags and MoneyOrderMsg    ) = MoneyOrderMsg)      // this is a MoneyOrder message
      and ((Flags and TransactionMsg) = 0         ) then // not a MoneyOrder transaction
      begin
         MessageData:=FileBlockMgr.GetMessage(Off,WS,MsgIndex);
         if (MessageData <> nil) then  // vaild message 
         begin
            if ((MessageData.ExpiryDate > Now)                    // within date
            and (MessageData.DestinationOffice = OfficeCode)) then // for this office 
            begin
               MOData:=TTxnLogLine.Create;
               MOData.PackText:=MessageData.MessageData;
               if (MOData.Count > 0) and (MOData[0] <> '') and (Integer(MOData[0][1]) < 32) then
                  MOData.PackText:=MOData[0];
               MODetails.Clear;
               MODetails.Series:='';
               if MOData.Period > (TodayAsPeriod-PeriodsInPayList) then
               begin
                  if (MOData.RecType = 'MOIssue') or (MOData.RecType = 'MFIssue') then
                  begin
                     MODetails.Series  :=Copy(MOData.Description,1,SeriesLength);
                     MOData.PackText:=MOData.DomInfo;
                     DomInfoLine:=TDomInfoLine.Create;
                     for J:=0 to MOData.Count-1 do
                     begin
                        DomInfoLine.PackText:=MOData[J];
                        if Pos('PayeesPOBox',DomInfoLine.Name) > 0 then
                           MODetails.PPOBox:=DomInfoLine.Text
                        else if Pos('PayeesSearchName' ,DomInfoLine.Name) > 0 then
                           MODetails.PName:=MODetails.PName+' '+DomInfoLine.Text
                        else if Pos('PayeesOtherNames' ,DomInfoLine.Name) > 0 then
                           MODetails.PName:=DomInfoLine.Text+MODetails.PName
                        else if Pos('SendersSearchName',DomInfoLine.Name) > 0 then
                           MODetails.IName:=MODetails.IName+' '+DomInfoLine.Text
                        else if Pos('SendersOtherNames',DomInfoLine.Name) > 0 then
                           MODetails.IName:=DomInfoLine.Text+MODetails.IName
                        else if Pos('Message'          ,DomInfoLine.Name) > 0 then
                           MODetails.PMessage:=DomInfoLine.Text;
                     end;
                     DomInfoLine.Free;
                     MODetails.IssuePay:='I';                
                  end
                  else if (MOData.RecType = 'MOIInfo') then
                  begin
                     MOData.PackText:=MOData.DomInfo;
                     MODetails.IssuePay:='I';
                     MODetails.Series  :=MOData[0];
                  end
                  else if (MOData.RecType = 'MOPInfo')  then
                  begin
                     MOData.PackText:=MOData.DomInfo;
                     MODetails.IssuePay:='P';
                     MODetails.Series  :=MOData[0];
                  end;
               end;
               MOData.Free;
               if MODetails.Series <> '' then
               begin
                  DecodeMoneyOrder(MODetails.Series,SerialNo,Value,IOffice,POffice,IClerk,MOType,IDate);
                  MODetails.SerialNo:=StrToIntDef(SerialNo,0);
                  MODetails.Value   :=Value  ;
                  MODetails.IOffice :=IOffice;
                  MODetails.POffice :=POffice;
                  MODetails.IClerk  :=IClerk ;
                  MODetails.MOType  :=MOType ;
                  MODetails.IDate   :=IDate  ;
                  if ((OfficeCode = 0) or (OfficeCode =POffice)) 
                  and ((MOTypes = 0) or ((MOTypes and (1 shl Integer(MOType))) <> 0)) then
                     ResultList.Add(MODetails.PackText)
               end;
            end;
            MessageData.Free
         end;
      end;  
   end;
   I:=0;
   MOCompare:=TMODetails.Create;
   while I < ResultList.Count do
   begin
      MODetails.PackText:=ResultList[I];
      if MODetails.IssuePay = 'I' then
      begin
         Idx:=-1;
         for J:=0 to ResultList.Count-1 do
         begin
            MOCompare.PackText:=ResultList[J];
            // Same Issue Office & Serial Number in different records - delete
            if (J <> I) and (MODetails.SerialNo = MOCompare.SerialNo) and (MODetails.IOffice = MOCompare.IOffice)then
            begin
               Idx:=J;
               break;
            end;
         end;
         if Idx <> -1 then
         begin
            MODetails.PackText:=ResultList[Idx];
            if MODetails.IssuePay = 'I' then
            begin
               ResultList.Delete(Idx);
            end
            else
            begin
               if Idx < I then                 
               begin
                  ResultList.Delete(I);
                  ResultList.Delete(Idx);
               end                     
               else
               begin
                  ResultList.Delete(Idx);
                  ResultList.Delete(I);
               end;
            end;
         end
         else
            Inc(I);
      end
      else
         Inc(I);
   end;
   MOCompare.Free;
   I:=0;
   while I < ResultList.Count do
   begin
      MODetails.PackText:=ResultList[I];
      if MODetails.IssuePay = 'P' then
         ResultList.Delete(I)
      else
         Inc(I);
   end;  
   MODetails.Free;
   Result:=ResultList.PackText;
   ResultList.Free;
end;
function TFileTxStatus.PensionList(OfficeCode:Integer;Identifier:String):String;
var
   Status:TStatusBits;
   WS,Off,I,MsgIndex,PenIdx,Flags:Integer;
   MessageData:TMessageAccess;
   PensionData:TPackStringList;
   PensionPayment:TMinPensionPayment;
   ResultList:TPackStringList;
   IDNumber:Integer;
begin
   ResultList:=TPackStringList.Create;
   PensionPayment:=TMinPensionPayment.Create;
   Status:=TStatusBits.Create;    
   Status.State:=Self.Status;
   IDNumber:=StrToIntDef(Trim(Identifier),0);
   for I:=0 to ThePensionsList.Count-1 do
   begin
      Off     :=StrToInt('$'+Copy(ThePensionsList[I],1,4));
      WS      :=StrToInt('$'+Copy(ThePensionsList[I],5,2));
      MsgIndex:=StrToInt('$'+Copy(ThePensionsList[I],7,8));
      Flags:=FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex); 
      if  ((Flags and PensionMsg    ) = PensionMsg)      // this is a pension message
      and ((Flags and TransactionMsg) = 0         ) then // not a pension transaction
      begin
         MessageData:=FileBlockMgr.GetMessage(Off,WS,MsgIndex);
         if (MessageData <> nil)                               // vaild message 
         and (MessageData.ExpiryDate > Now)                    // within date
         and (MessageData.DestinationOffice = OfficeCode) then // for this office 
         begin
            PensionData:=TPackStringList.Create;
            PensionData.PackText:=MessageData.MessageData;
            if IDNumber = 0 then // get pensions for all
            begin
               ResultList.AddStrings(PensionData);
//               ResultList.Insert(0,'Compressed '+IntToStr(Length(MessageData.RawData))+' Expanded '+IntToStr(Length(PensionData.Text)));
            end
            else  // get pensions for 1 person
            begin
               for PenIdx:=0 to PensionData.Count-1 do // each pension payment
               begin
                  PensionPayment.PackData:=PensionData[PenIdx];
                  if (PensionPayment.PayeeIdentifier = IDNumber)      // for this person
                  or (PensionPayment.VoucherNumber   = IDNumber) then // for this voucher
                     ResultList.Add(PensionData[PenIdx]);
               end;
            end;
            PensionData.Free;
         end;
         if (MessageData <> nil) then MessageData.Free
      end;
   end;
   PensionPayment.Free;
   Result:=ResultList.PackText;
   ResultList.Free;
end;
function TFileTxStatus.FullPensionList(OfficeCode:Integer):String;
begin
   Result:=PensionList(OfficeCode,'');
end;
function IndexOfPension(TransactionList:TPackStringList;PensionPayment:TMinPensionPayment):Integer;
var
   I:Integer;
   TxnPensionPayment:TMinPensionPayment;
begin
   Result:=-1;
   TxnPensionPayment:=TMinPensionPayment.Create;
   for I:=0 to TransactionList.Count-1 do
   begin
      TxnPensionPayment.PackData:=TransactionList[I];
      if TxnPensionPayment.VoucherNumber = PensionPayment.VoucherNumber then
      begin
         Result:=I;
         break;
      end;
   end;
   TxnPensionPayment.Free;
end;   
function TFileTxStatus.UnpaidPensionList(OfficeCode:Integer;Identifier:String):String;
var
   PensionPayment:TMinPensionPayment;
   PensionsList:TPackStringList;
   TransactionList:TPackStringList;
   I,Idx:Integer;
begin
   PensionsList   :=TPackStringList.Create;
   TransactionList:=TPackStringList.Create;
   PensionsList.PackText   :=PensionList(OfficeCode,Identifier);
   TransactionList.PackText:=PensionTxnList(OfficeCode);
   PensionPayment:=TMinPensionPayment.Create;
   I:=0;
   while I < PensionsList.Count do
   begin
      PensionPayment.PackData:=PensionsList[I];
      Idx:=IndexOfPension(TransactionList,PensionPayment);
      if Idx <> -1 then
      begin
         TransactionList.Delete(Idx);
         PensionsList.Delete(I);
      end
      else
        Inc(I);
   end;
   Result:=PensionsList.PackText;
   PensionPayment .Free;
   PensionsList   .Free;
   TransactionList.Free;
end;
function TFileTxStatus.PaidPensionList(OfficeCode:Integer):String;
begin
   Result:=PensionTxnList(OfficeCode);
end;
function TFileTxStatus.ListOffices(OType:String;Into:TStrings):String;
var
   I:Integer;
   OCR:TOffCodeRef;
   SL:TPackStringList;
begin 
   SL:=TPackStringList.Create;
   OCR:=TOffCodeRef.Create;
      
   if FOfficeReference = nil then FillOfficeReference;
   for I:=0 to FOfficeReference.Count-1 do
   begin
      OCR.PackText:=FOfficeReference[I];
      if (OType = '') or (Pos(OType,OCR.OfficeType) > 0) then
      begin
         SL.AddObject(OCR.OfficeTitle,TStringObject.Create('O'+IntToHex(OCR.OfficeCode,4)+OCR.OfficeSCode));
      end;
   end;
   OCR.Free;
   SL.Sort;
   Result:=SL.CommaText;     
   if Into <> nil then 
   begin
      Into.Clear;
      for I:=0 to SL.Count-1 do
         Into.AddObject(SL[I],SL.Objects[I]);
   end
   else
   begin
      for I:=0 to SL.Count-1 do
         TStringObject(SL.Objects[I]).Free;
   end;
   SL.Free;
end;       

function TFileTxStatus.GetRefForCode(Code:Integer):TOffCodeRef;
var
  I:Integer;
begin
   Result:=TOffCodeRef.Create;
   if FOfficeReference = nil then FillOfficeReference;
   for I:=0 to FOfficeReference.Count-1 do
   begin
      Result.PackText:=FOfficeReference[I];
      if Result.OfficeCode = Code then
         Exit;
   end;
end;
function TFileTxStatus.OfficeCodeRefs:String;
begin
   if FOfficeReference = nil then FillOfficeReference;
   Result:=FOfficeReference.PackText;
end;
function TFileTxStatus.OfficeCodeRef(OfficeCode:Integer):String;
var
  OffCodeRef:TOffCodeRef;
begin
   OffCodeRef:=GetRefForCode(OfficeCode);
   Result:=OffCodeRef.PackText;
   OffCodeRef.Free;
end;
function TFileTxStatus.OfficeNameFromCode(OfficeCode:Integer):String;
var
  OffCodeRef:TOffCodeRef;
begin
   OffCodeRef:=GetRefForCode(OfficeCode);
   Result:=OffCodeRef.OfficeName;
   OffCodeRef.Free;
end;
function TFileTxStatus.OfficeTitleFromCode(OfficeCode:Integer):String;
var
  OffCodeRef:TOffCodeRef;
begin
   OffCodeRef:=GetRefForCode(OfficeCode);
   Result:=OffCodeRef.OfficeTitle;
   OffCodeRef.Free;
end;
function TFileTxStatus.OfficeSCodeFromCode(OfficeCode:Integer):String;
var
  OffCodeRef:TOffCodeRef;
begin
   OffCodeRef:=GetRefForCode(OfficeCode);
   Result:=OffCodeRef.OfficeSCode;
   OffCodeRef.Free;
end;
function TFileTxStatus.OfficePCodeFromCode(OfficeCode:Integer):Integer;
var
  OffCodeRef:TOffCodeRef;
begin
   OffCodeRef:=GetRefForCode(OfficeCode);
   Result:=OffCodeRef.OfficePCode;
   OffCodeRef.Free;
end;
function TFileTxStatus.OfficeI3CodeFromCode(OfficeCode:Integer):Integer;
var
  OffCodeRef:TOffCodeRef;
begin
   OffCodeRef:=GetRefForCode(OfficeCode);
   Result:=OffCodeRef.OfficeI3Code;
   OffCodeRef.Free;
end;
function TFileTxStatus.OfficeAddressFromCode(OfficeCode:Integer):String;
var
  OffCodeRef:TOffCodeRef;
begin
   OffCodeRef:=GetRefForCode(OfficeCode);
   Result:=OffCodeRef.OfficeAddress;
   OffCodeRef.Free;
end;
function TFileTxStatus.OfficePhoneFromCode(OfficeCode:Integer):String;
var
  OffCodeRef:TOffCodeRef;
begin
   OffCodeRef:=GetRefForCode(OfficeCode);
   Result:=OffCodeRef.OfficePhone;
   OffCodeRef.Free;
end;
function TFileTxStatus.OfficePOBoxFromCode(OfficeCode:Integer):String;
var
  OffCodeRef:TOffCodeRef;
begin
   OffCodeRef:=GetRefForCode(OfficeCode);
   Result:=OffCodeRef.OfficePOBox;
   OffCodeRef.Free;
end;
function TFileTxStatus.OfficeAccessViaFromCode(OfficeCode:Integer):String;
var
  OffCodeRef:TOffCodeRef;
begin
   OffCodeRef:=GetRefForCode(OfficeCode);
   Result:=OffCodeRef.OfficeAccessVia;
   OffCodeRef.Free;
end;
function TFileTxStatus.OfficeAutomatedFromCode(OfficeCode:Integer):String;
var
  OffCodeRef:TOffCodeRef;
begin
   OffCodeRef:=GetRefForCode(OfficeCode);
   Result:=OffCodeRef.OfficeAutomated;
   OffCodeRef.Free;
end;
function TFileTxStatus.OfficeCodeFromTitle(Title:String):Integer;
var
  I:Integer;
  OffCodeRef:TOffCodeRef;
begin
   Result:=0;
   OffCodeRef:=TOffCodeRef.Create;
   if FOfficeReference = nil then FillOfficeReference;
   for I:=0 to FOfficeReference.Count-1 do
   begin
      OffCodeRef.PackText:=FOfficeReference[I];
      if OffCodeRef.OfficeTitle = Title then
      begin
         Result:=OffCodeRef.OfficeCode;
         break;
      end;
   end;
   OffCodeRef.Free;
end;
function TFileTxStatus.OfficeCodeFromName(Name:String):Integer;
var
  I:Integer;
  OffCodeRef:TOffCodeRef;
begin
   Result:=0;
   OffCodeRef:=TOffCodeRef.Create;
   if FOfficeReference = nil then FillOfficeReference;
   for I:=0 to FOfficeReference.Count-1 do
   begin
      OffCodeRef.PackText:=FOfficeReference[I];
      if OffCodeRef.OfficeName = Name then
      begin
         Result:=OffCodeRef.OfficeCode;
         break;
      end;
   end;
   OffCodeRef.Free;
end;
function TFileTxStatus.OfficeCodeFromSCode(SCode:String):Integer;
var
  I:Integer;
  OffCodeRef:TOffCodeRef;
begin
   Result:=0;
   OffCodeRef:=TOffCodeRef.Create;
   if FOfficeReference = nil then FillOfficeReference;
   for I:=0 to FOfficeReference.Count-1 do
   begin
      OffCodeRef.PackText:=FOfficeReference[I];
      if OffCodeRef.OfficeSCode = SCode then
      begin
         Result:=OffCodeRef.OfficeCode;
         break;
      end;
   end;
   OffCodeRef.Free;
end;
function TFileTxStatus.OfficeCodeFromI3Code(I3Code:Integer):Integer;
var
  I:Integer;
  OffCodeRef:TOffCodeRef;
begin
   Result:=0;
   OffCodeRef:=TOffCodeRef.Create;
   if FOfficeReference = nil then FillOfficeReference;
   for I:=0 to FOfficeReference.Count-1 do
   begin
      OffCodeRef.PackText:=FOfficeReference[I];
      if OffCodeRef.OfficeI3Code = I3Code then
      begin
         Result:=OffCodeRef.OfficeCode;
         break;
      end;
   end;
   OffCodeRef.Free;
end;
function TFileTxStatus.OfficeCodeFromPCode(PCode:Integer):Integer;
var
  I:Integer;
  OffCodeRef:TOffCodeRef;
begin
   Result:=0;
   OffCodeRef:=TOffCodeRef.Create;
   if FOfficeReference = nil then FillOfficeReference;
   for I:=0 to FOfficeReference.Count-1 do
   begin
      OffCodeRef.PackText:=FOfficeReference[I];
      if OffCodeRef.OfficePCode = PCode then
      begin
         Result:=OffCodeRef.OfficeCode;
         break;
      end;
   end;
   OffCodeRef.Free;
end;
procedure PauseForMS(ms:Integer);
var
   WaitEvent:TEvent;
const
   LastCall:Integer = 0;
begin
   Inc(LastCall);                 
   WaitEvent:=TEvent.Create('NeverHappensEvent'+IntToStr(LastCall),True,False);
   try
      WaitEvent.Wait(ms);
   except
   end;
   WaitEvent.Free;
end;                              
{TDataCommLoop}
constructor TDataCommLoop.Create(FileTxStatus:TFileTxStatus);
begin
   inherited Create(True);
//   Priority:=tpLower;
   FreeOnTerminate:=True;
   FFileTxStatus:=FileTxStatus;
end;
destructor TDataCommLoop.Destroy;
begin
   FFileTxStatus:=nil;
   inherited Destroy;
end;
procedure TDataCommLoop.UpdateUserInterface;
begin
   if (FFileTxStatus <> nil) and Assigned(FFileTxStatus.OnContactStatus) then
      FFileTxStatus.OnContactStatus('Datacomm');
//   FFileTxStatus.UpdateUI;
//   Application.ProcessMessages;
end;
procedure TDataCommLoop.Execute;
begin
   while not Terminated do
   begin
      if not Terminated then PauseForMS(1000);
      if (not Terminated) and (FFileTxStatus <> nil) and (not StartUpProcessing) then
         FFileTxStatus.DataCommTick;
      if (not Terminated) then 
         Synchronize(UpdateUserInterface);
   end;
end;
{TInternalProcessLoop}
constructor TInternalProcessLoop.Create(FileTxStatus:TFileTxStatus);
begin
   inherited Create(True);
   FreeOnTerminate:=True;
   FFileTxStatus:=FileTxStatus;
end;
destructor TInternalProcessLoop.Destroy;
 begin
   FFileTxStatus:=nil;
   inherited Destroy;
end;
procedure TInternalProcessLoop.UpdateUserInterface;
begin
   if (FFileTxStatus <> nil) and Assigned(FFileTxStatus.OnContactStatus) then
      FFileTxStatus.OnContactStatus('Internal');
   Application.ProcessMessages;
end;
procedure TInternalProcessLoop.Execute;
begin
   while not Terminated do
   begin
      PauseForMS(100);
      if (not Terminated) and (FFileTxStatus <> nil) and (not StartUpProcessing)  then
         FFileTxStatus.TimerTick;
      if (not Terminated) then
         Synchronize(UpdateUserInterface);
   end;
end;
{TSignalLoop}
constructor TSignalLoop.Create(FileTxStatus:TFileTxStatus);
begin
   inherited Create(True);
   FreeOnTerminate:=True;
   FFileTxStatus:=FileTxStatus;
end;
procedure TSignalLoop.UpdateUserInterface;
begin
   if (FFileTxStatus <> nil) and Assigned(FFileTxStatus.OnContactStatus) then
      FFileTxStatus.OnContactStatus('Signal');
end;
procedure TSignalLoop.Execute;
var
   Event:TEvent;
begin
   Event:=TEvent.Create('CorvusServiceIsRunning',True,False);
   try
      while not Terminated do
      begin
         Event.Signal;   // tell other processes Service is running.
         Synchronize(UpdateUserInterface);
         PauseForMS(40); // wait 40 ms
      end;
   finally
      Event.Free;
   end;
end;
{TExecLoop}
constructor TExecLoop.Create(FileTxStatus:TFileTxStatus);
begin
   inherited Create(True);
   FreeOnTerminate:=True;
   FFileTxStatus:=FileTxStatus;
end;
destructor TExecLoop.Destroy;
begin
   FFileTxStatus:=nil;
   inherited Destroy;
end;
procedure TExecLoop.UpdateUserInterface;
begin
   if (FFileTxStatus <> nil) then
   begin
      if Assigned(FFileTxStatus.OnContactStatus) then
         FFileTxStatus.OnContactStatus('Execute');
   end;
end;
procedure TExecLoop.SyncMessageData;
begin
   if (FFileTxStatus <> nil) and Assigned(FFileTxStatus.OnContactStatus) then
      FFileTxStatus.OnContactStatus('MessageData');
end;
procedure TExecLoop.SyncUpdateStatus;
begin
   if (FFileTxStatus <> nil) and Assigned(FFileTxStatus.OnContactStatus) then
      FFileTxStatus.OnContactStatus('UpdateStatus');
end;
procedure TExecLoop.SyncServiceBusy;
begin
   if (FFileTxStatus <> nil) and Assigned(FFileTxStatus.OnContactStatus) then
      FFileTxStatus.OnContactStatus('ServiceBusy');
end;
procedure TExecLoop.SyncServiceExclaim;
begin
   if (FFileTxStatus <> nil) and Assigned(FFileTxStatus.OnContactStatus) then
      FFileTxStatus.OnContactStatus('Exclaim');
end;
procedure AddMOTransferMessages(FileTxStatus:TFileTxStatus;TxnPackText:String);
var
   TxnLogLine:TTxnLogLine;
   TxnLogLines:TTxnLogLines;
   DomInfoLines:TDomInfoLines;
   MoneyOrder:TMoneyOrder;
   MessageAccess:TMessageAccess;
   S:String;
   I:Integer;
   TempPackStrList:TPackStringList;
begin
   TxnLogLines:=TTxnLogLines.Create;
   TxnLogLine:=TTxnLogLine.Create;
   DomInfoLines:=TDomInfoLines.Create;
   MoneyOrder:=TMoneyOrder.Create;
   TempPackStrList:=TPackStringList.Create;
   MessageAccess:=nil;
                                    
   TxnLogLines.PackText:=TxnPackText;
   for I:=0 to TxnLogLines.Count-1 do
   begin
      try
         TxnLogLine.PackText:=TxnLogLines[I];
         if (TxnLogLine.RecType = MOIssueType) or (TxnLogLine.RecType = MFIssueType) then
         begin
            S:=EncodeMoneyOrder(TxnLogLine.Description,TxnLogLine.Price,FileTxStatus.ThisOfficeID,
                                StrToIntDef(TxnLogLine.Info,0),0,moNone,TxnLogLine.DateTime,False);
            TempPackStrList.Clear;
            TempPackStrList.Add(TxnLogLines[I]);
            MessageAccess:=FileTxStatus.FFileBlockMgr.AppendMessage(
                    FileTxStatus.ThisOfficeID,FileTxStatus.ThisWorkstation,
                    dtOfficeToOffice,TxnLogLine.Info,
                    Now+1,Now+180,'MORouting','Data',
                    mtMoneyOrder,1,S,TempPackStrList.PackText,True);
         end
         else if (TxnLogLine.RecType = MOPaidType) or (TxnLogLine.RecType = MFPaidType) then
         begin
            if TxnLogLine.Prod = 'MOPaid Complete' then
            begin
               MessageAccess:=FileTxStatus.FFileBlockMgr.AppendMessage(
                       FileTxStatus.ThisOfficeID,FileTxStatus.ThisWorkstation,
                       dtOfficeToOffice,FileTxStatus.ThisOfficeID,
                       Now+1,Now+180,'MORouting','Data',
                       mtMoneyOrder,1,TxnLogLine.Description,TxnLogLines[I],True);
            end;
         end
         else if (TxnLogLine.RecType = MOIInfoType) or (TxnLogLine.RecType = MOPInfoType) then
         begin
            MessageAccess:=FileTxStatus.FFileBlockMgr.AppendMessage(
                    FileTxStatus.ThisOfficeID,FileTxStatus.ThisWorkstation,
                    dtOfficeToOffice,FileTxStatus.ThisOfficeID,
                    Now+1,Now+180,'MORouting','Data',
                    mtMoneyOrder,1,TxnLogLine.Description,TxnLogLines[I],True);
         end;
         if MessageAccess <> nil then
         begin
            MessageAccess.Flags:=MessageAccess.Flags or TransferMsg;
            FileTxStatus.FFileBlockMgr.SetMessageFlags(FileTxStatus.ThisOfficeID,FileTxStatus.Workstation,MessageAccess.Identifier,MessageAccess.Flags);
            UpdateLists(MessageAccess.Flags,FileTxStatus.ThisOfficeID,FileTxStatus.Workstation,MessageAccess.Identifier,FileTxStatus,MessageAccess);
            MessageAccess.Free;
            MessageAccess:=nil;
         end;
      except
         On E : Exception do
            RaiseGUIDException('{BC5EFACB-FD56-46A1-87A2-D35C7015B1E1}', E);
      end;
   end;
   TempPackStrList.Free;
   MoneyOrder.Free;
   DomInfoLines.Free;
   TxnLogLines.Free;
   TxnLogLine.Free;
end;
procedure TExecLoop.ProcessTransactionFiles;
var
   FileList:TStringList;
   FilePartName:String;
   FileStream:TFileStream;
   MW:TMessageWrapper;
   SS:TStringStream;
   MsgIndex,I,J:Integer;          
   DeliveryType:TDeliveryType;
   DestinationOffice:Integer;
   SendBy,ExpiresOn:TDateTime;
   CurrStatus:TStatusBits;
   PhysicalLayout,LogicalLayout:String;
   MessageAccess:TMessageAccess;
   MessageType:TMessageType;
   MessageVersion:Integer;
   MessageName,MessageData:String;
   Office:Integer;
   WS:Integer;
   Flags,MI:Integer;
   FileType:String;
   ContainsMoneyOrder:Boolean;
   ContainsPension:Boolean;
   FS:TFileStream;
   DontAddMessage:Boolean;
   TxnLogLine:TTxnLogLine;
   TxnLogLines:TTxnLogLines;
   TI:Integer;
   TxnProcessor:TTxnProcessor;
const
   InProcessTransactionFiles:Boolean = False;
begin
   if InProcessTransactionFiles then Exit;
   InProcessTransactionFiles:=True;
   try
      MW:=TMessageWrapper.Create;
      FileList:=TStringList.Create;
      // process local transaction files first
      FillFileList(TransactionFilesDir,'T*.2ND',False,FileList);
      // no local transactions; get distributed messages
      if FileList.Count = 0  then
         FillFileList(TransactionFilesDir,'*.SMF',False,FileList);
      // no local transactions; get received messages
      if FileList.Count = 0  then
         FillFileList(TransactionFilesDir,'*.2ND',False,FileList);
      // only process MaxFilesToProcess at a time
      while FileList.Count > MaxFilesToProcess do FileList.Delete(MaxFilesToProcess);

      if FileList.Count > 0 then
      begin
         try
            for I:=0 to FileList.Count-1 do
            begin
               try
                  FilePartName:=Copy(FileList[I],1,Length(FileList[I])-3);
                  FileType:=Copy(FileList[I],Length(FileList[I])-2,3);
                  RenameFile(FileList[I],FilePartName+'3RD');
                  if FileExists(FilePartName+'3RD') then
                  begin
                     if ExtractFileName(FilePartName)[1] = 'F' then
                     begin
                        FileStream:=TFileStream.Create(FilePartName+'3RD',fmOpenRead or fmShareDenyNone);
                        Office:=StrToInt(Copy(ExtractFileName(FilePartName),2,5));
                        WS:=StrToInt(Copy(ExtractFileName(FilePartName),7,3));
                        FFileTxStatus.FFileBlockMgr.ReadFileFrom(Office,WS,FileStream);
                        FileStream.Free;
                        CurrStatus:=TStatusBits.Create;
                        CurrStatus.State:=FFileTxStatus.FFileBlockMgr.GetStatus;
                        FFileTxStatus.FStatusMonitor.SetStatus(CurrStatus.State);
                        DontProcessNow:=True;
                        try
                           for MsgIndex:=0 to CurrStatus.Size(Office,WS) do
                           begin
                              if CurrStatus.Bit[Office,WS,MsgIndex] then
                              begin
                                 Flags:=FFileTxStatus.FileBlockMgr.GetMessageFlags(Office,WS,MsgIndex);
                                 UpdateLists(Flags,Office,WS,MsgIndex,FFileTxStatus,nil);
                              end;                  
                           end;
                        finally
                           DontProcessNow:=False;
                        end;
                        CurrStatus.Free;
                     end 
                     else
                     begin
                        if FileType = 'SMF' then
                        begin
                           FS:=TFileStream.Create(FilePartName+'3RD',fmOpenRead or fmShareDenyNone);
                           SS:=TStringStream.Create('');
                           TCompressor.DecompressStream(FS,SS);
                           MW.PackText:=SS.DataString;
                           SS.Free;
                           FS.Free;
                        end
                        else
                        begin
                           MW.LoadFromFile(FilePartName+'3RD');
                        end;
                     
                        ContainsMoneyOrder:=False;
                        ContainsPension:=False;
                        DontAddMessage:=False;
                        DeliveryType     :=MW.DeliveryType     ;
                        DestinationOffice:=MW.DestinationOffice;
                        SendBy           :=MW.SendBy           ;
                        ExpiresOn        :=MW.ExpiresOn        ;
                        PhysicalLayout   :=MW.PhysicalLayout   ;
                        LogicalLayout    :=MW.LogicalLayout    ;
                        MessageType      :=MW.MessageType      ;
                        MessageVersion   :=MW.MessageVersion   ;
                        MessageName      :=MW.MessageName      ;
                        MessageData      :=MW.MessageData      ;
                     
                        if (MW.DeliveryType = dtDistributionFile) then
                        begin
                           DeliveryType:=dtOfficeToOffice;
                           MW.WrapperType:='RMSG';
                           MW.Flags:=0;
                           if (MessageType = mtPension) 
                           and FFileTxStatus.FindPensionMessage(FFileTxStatus.FThisOfficeID,DestinationOffice,MessageName) then 
                              DontAddMessage:=True;
                        end;  
                        
                        if (MW.WrapperType = 'MSG') then
                        begin
                           Office:=MW.FromOffice;
                           WS    :=MW.FromWorkstation;
                           MI    :=MW.Identifier;
                           Flags :=MW.Flags;
                        end   
                        else if (MW.WrapperType = 'RMSG') then
                        begin
                           // move message to new Index on this WS
                           Office:=FFileTxStatus.FThisOfficeID;
                           WS    :=FFileTxStatus.FWorkstation ;
                           MI    :=0;
                           Flags :=MW.Flags;
                        end   
                        else 
                        begin
                           if (MessageType = mtPension) then
                           begin
                              Office:=FFileTxStatus.FThisOfficeID;
                              WS:=250;
                              if (MessageType <> mtTransaction)
                              and FFileTxStatus.FindPensionMessage(Office,DestinationOffice,MessageName) then 
                                 DontAddMessage:=True;
                           end
                           else
                           begin
                              Office:=FFileTxStatus.FThisOfficeID;
                              WS:=FFileTxStatus.FWorkstation ;
                           end;
                           MI:=0;
                           Flags:=0;
                           if (MessageType = mtTransaction)
                           and (WriteDataForOtherOffices or (Office = FFileTxStatus.ThisOfficeID)) then
                           begin
                              MessageData:=ProcessTransactionsIntoDB(MessageData,ContainsMoneyOrder,ContainsPension,0,FFileTxStatus);
                           end;
                        end;
                        if not DontAddMessage then
                        begin
                           // if has no ID or flags = 0 i.e. message not in store.
                           if (MI = 0) or (FFileTxStatus.FFileBlockMgr.GetMessageFlags(Office,WS,MI) = 0) then
                           begin
                              MessageAccess:=FFileTxStatus.FFileBlockMgr.AddMessage(
                                      Office,WS,MI,DeliveryType,DestinationOffice,
                                      SendBy,ExpiresOn,PhysicalLayout,LogicalLayout,
                                      MessageType,MessageVersion,MessageName,MessageData,
                                      True);
                              MI:=MessageAccess.Identifier;
                              if (MessageAccess.DestinationOffice <> 0) and (DestinationOffice <> FFileTxStatus.FThisOfficeID) then
                              begin
                                 FFileTxStatus.FTransmitList.Add(IntToHex(MessageAccess.Office,4)+IntToHex(MessageAccess.WorkStation,2)+IntToHex(MessageAccess.Identifier,8)+IntToHex(MessageAccess.DestinationOffice,4)+FloatToStr(SendBy));
                                 MessageAccess.Flags:=MessageAccess.Flags or TransferMsg;
                                 FFileTxStatus.FFileBlockMgr.SetMessageFlags(Office,WS,MI,MessageAccess.Flags);
                              end;
                        
                              if ContainsPension or ((MessageAccess.Flags and PensionMsg) <> 0) then
                              begin
                                 MessageAccess.Flags:=(MessageAccess.Flags or PensionMsg) and (not MessageProcessed);
                                 Flags:=MessageAccess.Flags;
                                 FFileTxStatus.FFileBlockMgr.SetMessageFlags(Office,WS,MI,Flags);
                                 if (Flags and TransactionMsg) <> 0 then
                                    ThePensionsList.Add(IntToHex(Office,4)+IntToHex(WS,2)+IntToHex(MI,8)+'T')
                                 else
                                    ThePensionsList.Add(IntToHex(Office,4)+IntToHex(WS,2)+IntToHex(MI,8)+'P');
                              end;
                                                       
                              if (MW.WrapperType = 'MSG') or (MW.WrapperType = 'RMSG') then
                              begin
                                 FFileTxStatus.FFileBlockMgr.SetMessageFlags(Office,WS,MI,Flags);
                                 FFileTxStatus.FUnProcessedList.Add(IntToHex(MessageAccess.Office,4)+IntToHex(MessageAccess.WorkStation,2)+IntToHex(MessageAccess.Identifier,8));
                                 if ((MessageAccess.Flags and MoneyOrderMsg) <> 0) 
                                 and (MW.WrapperType = 'RMSG')
                                 and (DestinationOffice = FFileTxStatus.FThisOfficeID) then
                                 begin
                                    TxnLogLines:=TTxnLogLines.Create;
                                    TxnLogLine:=TTxnLogLine.Create;
                                    if (MessageData <> '') and (MessageData[1] = #1) then
                                       TxnLogLines.PackText:=#2+MessageData
                                    else
                                       TxnLogLines.PackText:=MessageData;
                                    for TI:=0 to TxnLogLines.Count-1 do
                                    begin
                                       TxnLogLine.PackText:=TxnLogLines[TI];
                                       TxnLogLine.Office  :=FFileTxStatus.FThisOfficeID;
                                       TxnLogLine.WSNumber:=FFileTxStatus.FWorkstation ;
                                       TxnLogLines[TI]:=TxnLogLine.PackText;
                                    end;
                                    TxnLogLines.PackText:=ProcessTransactionsIntoDB(TxnLogLines.PackText,ContainsMoneyOrder,ContainsPension,0,FFileTxStatus);
                                    TxnProcessor:=TTxnProcessor.Create('TempUPPSL');
                                    for TI:=0 to TxnLogLines.Count-1 do
                                       TxnProcessor.AddRecord(TxnLogLines[TI], bpLast ,FFileTxStatus);
                                    TxnProcessor.Free;
                                    MessageAccess:=FFileTxStatus.FFileBlockMgr.AddMessage(
                                            FFileTxStatus.ThisOfficeID,
                                            FFileTxStatus.Workstation,0,
                                            dtTransaction,0,SendBy,ExpiresOn,
                                            'Data','Data',
                                            mtTransaction,1,'',TxnLogLines.PackText,
                                            True);

                                    TxnLogLines.Free;
                                    TxnLogLine.Free;

                                    MI:=MessageAccess.Identifier;
                                    MessageAccess.Flags:=MessageAccess.Flags and (not MessageProcessed) ;
                                    FFileTxStatus.FFileBlockMgr.SetMessageFlags(FFileTxStatus.ThisOfficeID,FFileTxStatus.Workstation,MI,MessageAccess.Flags);
                                    UpdateLists(MessageAccess.Flags,FFileTxStatus.ThisOfficeID,FFileTxStatus.Workstation,MI,FFileTxStatus,nil);
                                    if (FFileTxStatus.FStatusMonitor <> nil) then
                                    begin
                                       SS:=TStringStream.Create('');
                                       FFileTxStatus.DataTxEvent(FFileTxStatus.FStatusMonitor,
                                                                 FFileTxStatus.FThisOfficeID,
                                                                 FFileTxStatus.FWorkstation,MI,SS);
                                       FFileTxStatus.FStatusMonitor.SendData(SS.DataString);
                                       Windows.Beep(5000,20);
                                       SS.Free;
                                    end;
                                 end;       
                              end
                              else if (MW.WrapperType = 'TXN') then
                              begin               
                                 if (FFileTxStatus.FStatusMonitor <> nil) then
                                 begin
                                    SS:=TStringStream.Create('');
                                    FFileTxStatus.DataTxEvent(FFileTxStatus.FStatusMonitor,
                                                              FFileTxStatus.FThisOfficeID,
                                                              FFileTxStatus.FWorkstation,MI,SS);
                                    FFileTxStatus.FStatusMonitor.SendData(SS.DataString);
                                    Windows.Beep(5000,20);
                                    SS.Free;
                                 end;
                                 if ContainsMoneyOrder then
                                 begin
                                    AddMOTransferMessages(FFileTxStatus,MessageData);
                                 end;
                              end;
                              MessageAccess.Free;
                           end;
                        end;
                     end;
                     if FileExists(FilePartName+'4TH') then
                     begin
                        J:=0;
                        while FileExists(FilePartName+IntToStr(J)+'.4TH') do Inc(J);
                        RenameFile(FilePartName+'3RD',FilePartName+IntToStr(J)+'.4TH');
                        DeleteFile(PChar(FilePartName+IntToStr(J)+'.4TH'));
                     end
                     else
                     begin
                        RenameFile(FilePartName+'3RD',FilePartName+'4TH');
                        DeleteFile(PChar(FilePartName+'4TH'));
                     end;
                    
                     if (MW.WrapperType = 'TXN') then
                        Synchronize(SyncMessageData);
                     Application.ProcessMessages;
                     if Application.Terminated then Break;
                  end;
               except
                  on E: Exception do 
                  begin
                     RaiseGUIDException('{D430735C-31D3-4287-A381-0272675D127F}',E);
                  end;
               end;
            end;
         finally
            ProcessTransactionsIntoDB('Finished',ContainsMoneyOrder,ContainsPension,0,FFileTxStatus);
            FFileTxStatus.FFileBlockMgr.Flush;
            if FFileTxStatus.FStatusMonitor <> nil then
               FFileTxStatus.FStatusMonitor.SetStatus(FFileTxStatus.FileBlockMgr.GetStatus);
         end;
      end;
      FileList.Free;
      MW.Free;
   except
      on E: Exception do 
         RaiseGUIDException('{3C8B32D0-822F-438C-B535-47B699ACF9D9}',E);
   end;
   InProcessTransactionFiles:=False;
end;         
procedure TExecLoop.ExecuteFunction(EventID:Integer);
var
   SL:TPackStringList;
   ResponseEvent:TEvent;
   DeliveryType:TDeliveryType;
   DestinationOffice:Integer;
   SendBy,ExpiresOn:TDateTime;
   PhysicalLayout,LogicalLayout:String;
   MessageType:TMessageType;
   MessageVersion:Integer;
   MessageName,MessageData:String;
   MessageAccess:TMessageAccess;
   Stock:TSiteStock;
   function GetSP(Param:String):String;
   begin
      Result:=GetServiceParameter(EventID,Param);
   end;
   procedure PassResult(Data:Variant);
   begin
      PassServiceParameter(EventID,'ParameterData',Data);
   end;
   function GetParam:Variant;
   begin
      Result:=GetServiceParameter(EventID,'ParameterData');
   end;
begin                                 
    MessageData:='';
    MessageData:=GetSP('MessageData');
    if MessageData <> '' then
    begin
       Synchronize(SyncMessageData);
       BeenInterrupted:=True;
       DeliveryType     :=GetServiceParameter(EventID,'DeliveryType'     );
       DestinationOffice:=GetServiceParameter(EventID,'DestinationOffice');
       SendBy           :=GetServiceParameter(EventID,'SendBy'           );
       ExpiresOn        :=GetServiceParameter(EventID,'ExpiresOn'        );
       PhysicalLayout   :=GetServiceParameter(EventID,'PhysicalLayout'   );
       LogicalLayout    :=GetServiceParameter(EventID,'LogicalLayout'    );
       MessageType      :=GetServiceParameter(EventID,'MessageType'      );
       MessageVersion   :=GetServiceParameter(EventID,'MessageVersion'   );
       MessageName      :=GetServiceParameter(EventID,'MessageName'      );

       MessageAccess:=FFileTxStatus.FFileBlockMgr.AppendMessage(
                  FFileTxStatus.FThisOfficeID,FFileTxStatus.FWorkstation ,
                  DeliveryType               ,DestinationOffice          ,
                  SendBy                     ,ExpiresOn                  ,
                  PhysicalLayout             ,LogicalLayout              ,
                  MessageType                ,MessageVersion             ,
                  MessageName                ,MessageData                ,
                  True);
       MessageAccess.Free;
       FFileTxStatus.FFileBlockMgr.Flush;
    end
    else if GetSP('UpdateStatus') <> '' then
    begin
       Synchronize(SyncUpdateStatus);
       FFileTxStatus.FStatusMonitor.SetStatus(FFileTxStatus.FileBlockMgr.GetStatus);
    end
    else if GetSP('ServiceBusy') <> '' then
    begin
       Synchronize(SyncServiceBusy);
       PassServiceParameter(EventID,'ServiceBusy',ServiceIsBusy);
    end
    else if GetSP('PensionList') <> '' then
       PassResult(FFileTxStatus.PensionList(FFileTxStatus.FThisOfficeID,GetParam))
    else if GetSP('MoneyOrderPayList') <> '' then
       PassResult(FFileTxStatus.MoneyOrderPayList(FFileTxStatus.FThisOfficeID,GetParam))
    else if GetSP('UnpaidPensionList') <> '' then
       PassResult(FFileTxStatus.UnpaidPensionList(FFileTxStatus.FThisOfficeID,GetParam))
    else if GetSP('OfficeList') <> '' then
       PassResult(FFileTxStatus.OfficeList)
    else if GetSP('OfficeCodeRefs') <> '' then
       PassResult(FFileTxStatus.OfficeCodeRefs)
    else if GetSP('OfficeCodeRef') <> '' then
       PassResult(FFileTxStatus.OfficeCodeRef          (GetParam))
    else if GetSP('OfficeNameFromCode') <> '' then    
       PassResult(FFileTxStatus.OfficeNameFromCode     (GetParam))
    else if GetSP('OfficeTitleFromCode'    ) <> '' then
       PassResult(FFileTxStatus.OfficeTitleFromCode    (GetParam))
    else if GetSP('OfficeSCodeFromCode'    ) <> '' then
       PassResult(FFileTxStatus.OfficeSCodeFromCode    (GetParam))
    else if GetSP('OfficePCodeFromCode'    ) <> '' then
       PassResult(FFileTxStatus.OfficePCodeFromCode    (GetParam))
    else if GetSP('OfficeI3CodeFromCode'   ) <> '' then
       PassResult(FFileTxStatus.OfficeI3CodeFromCode   (GetParam))
    else if GetSP('OfficeAddressFromCode'  ) <> '' then
       PassResult(FFileTxStatus.OfficeAddressFromCode  (GetParam))
    else if GetSP('OfficePhoneFromCode'    ) <> '' then
       PassResult(FFileTxStatus.OfficePhoneFromCode    (GetParam))
    else if GetSP('OfficePOBoxFromCode'    ) <> '' then
       PassResult(FFileTxStatus.OfficePOBoxFromCode    (GetParam))
    else if GetSP('OfficeAccessViaFromCode') <> '' then
       PassResult(FFileTxStatus.OfficeAccessViaFromCode(GetParam))
    else if GetSP('OfficeAutomatedFromCode') <> '' then
       PassResult(FFileTxStatus.OfficeAutomatedFromCode(GetParam))
    else if GetSP('OfficeCodeFromTitle'    ) <> '' then
       PassResult(FFileTxStatus.OfficeCodeFromTitle    (GetParam))
    else if GetSP('OfficeCodeFromName'     ) <> '' then
       PassResult(FFileTxStatus.OfficeCodeFromName     (GetParam))
    else if GetSP('OfficeCodeFromSCode'    ) <> '' then
       PassResult(FFileTxStatus.OfficeCodeFromSCode    (GetParam))
    else if GetSP('OfficeCodeFromI3Code'   ) <> '' then
       PassResult(FFileTxStatus.OfficeCodeFromI3Code   (GetParam))
    else if GetSP('OfficeCodeFromPCode'    ) <> '' then
       PassResult(FFileTxStatus.OfficeCodeFromPCode    (GetParam))
    else if GetSP('SetGMemory'             ) <> '' then
       PassResult(FFileTxStatus.SetGMemory             (GetParam))
    else if GetSP('GetGMemory'             ) <> '' then
       PassResult(FFileTxStatus.GetGMemory             (GetParam))
    else if GetSP('SendDGram'              ) <> '' then
       PassResult(FFileTxStatus.SendUserDataGram       (GetParam))
    else if GetSP('SendMessage'            ) <> '' then
       PassResult(FFileTxStatus.SendUserMessage        (GetParam))
    else if GetSP('AdjustStockLevel') <> '' then
    begin 
       Stock:=TSiteStock.Create;
       SL:=TPackStringList.Create;
       try
          SL.PackText:=GetParam;            
          if SL.Count > 2 then
          begin
             Stock.EmptySetUp(SL[0]);
             Stock.AdjustStockLevel(SL[0],SL[1],StrToInt(SL[2]));
          end;
       except
          on E:Exception do RaiseGUIDException('{DA6056EA-7D99-4154-A748-ED39259E00A8}',E);
       end;
       Stock.Free;
       SL.Free;
    end
    else if GetSP('SetStockLevel'   ) <> '' then
    begin
       Stock:=TSiteStock.Create;
       SL:=TPackStringList.Create;
       try
          SL.PackText:=GetParam;            
          if SL.Count > 2 then
          begin
             Stock.EmptySetUp(SL[0]);
             Stock.SetStockLevel(SL[0],SL[1],StrToInt(SL[2]));
          end;
       except
          on E:Exception do RaiseGUIDException('{DA6056EA-7D99-4154-A748-ED39259E00A8}',E);
       end;
       SL.Free;
       Stock.Free;
    end
    else if GetSP('AddNewStockItem' ) <> '' then
    begin
       Stock:=TSiteStock.Create;
       SL:=TPackStringList.Create;
       try
          SL.PackText:=GetParam;            
          if SL.Count > 8 then
             Stock.AddNewStockItem(SL[0],StrToCurr(SL[1]),SL[2],StrToInt(SL[3]),SL[4],SL[5],SL[6],SL[7],SL[8]);
       except
          on E:Exception do RaiseGUIDException('{DA6056EA-7D99-4154-A748-ED39259E00A8}',E);
       end;
       SL.Free;
       Stock.Free;
    end
    else if GetSP('RepairMessageStore') <> '' then
    begin
//       FFileTxStatus.WriteTransaction(FFileTxStatus.FThisOfficeID,FFileTxStatus.FWorkstation,TodayAsPeriod,Now,0,0,0,0,0,'','Service','RepairMS','Repair Message Store','','','');
       FFileTxStatus.Enabled:=False;
       SetPSLRegString('Message Transfer','Compressing Blocks','Y');
       Repair(0);
       FFileTxStatus.Enabled:=True;
       SetPSLRegString('Message Transfer','Last Rebuild','0');
    end                          
    else if GetSP('UpdateStockCSV') <> '' then
    begin
       SL:=TPackStringList.Create;
       Stock:=TSiteStock.Create;
       try
          UpdateFromCSV(GetParam,Stock);
       except
          on E:Exception do RaiseGUIDException('{1E9E5C24-DF64-4C1F-974E-6AA6405EFDB4}',E);
       end;
       Stock.Free;
       FFileTxStatus.WriteTransaction(FFileTxStatus.FThisOfficeID,FFileTxStatus.FWorkstation,TodayAsPeriod,Now,0,0,0,0,0,'','Service','SaveStk','Set Stock & Levels','','',SL.PackText);
       SL.Free;
    end
    else if GetSP('SaveStockCSV') <> '' then
    begin
       Stock:=TSiteStock.Create;
       try
          SaveToCSV(GetParam,Stock);
       except
          on E:Exception do RaiseGUIDException('{365339CA-7BC8-4DFA-8874-656573600C72}',E);
       end;
       Stock.Free;
    end
    else if GetSP('LoadStockIDS') <> '' then
    begin
       SL:=TPackStringList.Create;
       Stock:=TSiteStock.Create;
       try
          SL.PackText:=Stock.Stock.LoadIDS(GetParam);
       except
          on E:Exception do RaiseGUIDException('{26B5E146-21C5-4211-A672-1B71EA8DD111}',E);
       end;
       Stock.Free;
       FFileTxStatus.WriteTransaction(FFileTxStatus.FThisOfficeID,FFileTxStatus.FWorkstation,TodayAsPeriod,Now,0,0,0,0,0,'','Service','SaveStk','Set Stock & Levels','','',SL.PackText);
       SL.Free;
    end
    else if GetSP('SaveStockIDS') <> '' then
    begin
       Stock:=TSiteStock.Create;
       try
          Stock.Stock.SaveIDS(GetParam);
       except
          on E:Exception do RaiseGUIDException('{26B5E146-21C5-4211-A672-1B71EA8DD111}',E);
       end;
       Stock.Free;
    end
    else if GetSP('DeleteStockItem' ) <> '' then
    begin
       Stock:=TSiteStock.Create;
       try
          Stock.DeleteStockItemByName(GetParam);
       except
          on E:Exception do RaiseGUIDException('{DA6056EA-7D99-4154-A748-ED39259E00A8}',E);
       end;
       Stock.Free;
    end
    else if GetSP('ListStock'       ) <> '' then
    begin
       Stock:=TSiteStock.Create;
       SL:=TPackStringList.Create;
       try
          SL.PackText:=GetParam;            
          if SL.Count > 2 then
          begin
             Stock.EmptySetUp(SL[0]);
             PassResult(Stock.Stock.ListStock(SL[0],SL[1],Boolean(StrToInt(SL[2]))));
          end
          else
             PassResult('');
       except
          on E:Exception do RaiseGUIDException('{DA6056EA-7D99-4154-A748-ED39259E00A8}',E);
       end;
       SL.Free;
       Stock.Free;
    end
    else if GetSP('GetStockLevel'       ) <> '' then
    begin
       Stock:=TSiteStock.Create;
       SL:=TPackStringList.Create;
       try
          SL.PackText:=GetParam;            
          if SL.Count > 1 then
          begin
             Stock.EmptySetUp(SL[0]);
             PassResult(Stock.GetStockLevel(SL[0],SL[1]))
          end
          else
             PassResult('');
       except
          on E:Exception do RaiseGUIDException('{DA6056EA-7D99-4154-A748-ED39259E00A8}',E);
       end;
       Stock.Free;
       SL.Free;
    end
    else if GetSP('ClearTempAdjustments'       ) <> '' then
    begin
       Stock:=TSiteStock.Create;
       try
          Stock.ClearTempAdjustments(GetParam);
       except
          on E:Exception do RaiseGUIDException('{DA6056EA-7D99-4154-A748-ED39259E00A8}',E);
       end;
       Stock.Free;
    end
    else if GetSP('DeleteStockUnit'       ) <> '' then
    begin
       Stock:=TSiteStock.Create;
       try
          Stock.DeleteStockUnit(GetParam);
       except
          on E:Exception do RaiseGUIDException('{DA6056EA-7D99-4154-A748-ED39259E00A8}',E);
       end;
       Stock.Free;
    end
    else if GetSP('GetStockItemDetails'       ) <> '' then
    begin
       Stock:=TSiteStock.Create;
       try
          PassResult(Stock.GetStockItemDetails(GetParam));
       except
          on E:Exception do RaiseGUIDException('{DA6056EA-7D99-4154-A748-ED39259E00A8}',E);
       end;
       Stock.Free;
    end
    else if GetSP('CreateNewStockUnit'       ) <> '' then
    begin
       Stock:=TSiteStock.Create;
       SL:=TPackStringList.Create;
       try
          SL.PackText:=GetParam;            
          if SL.Count > 1 then
          begin
             Stock.CreateNewStockUnit(SL[0],SL[1]);
             Stock.EmptySetUp(SL[0]);
          end;
       except
          on E:Exception do RaiseGUIDException('{DA6056EA-7D99-4154-A748-ED39259E00A8}',E);
       end;
       SL.Free;
       Stock.Free;
    end
    else
    begin
       Synchronize(SyncServiceExclaim);
    end;
         
    ResponseEvent:=TEvent.Create('FunctionComplete'+IntToHex(EventID,8),True,False);
    ResponseEvent.Signal;
    ResponseEvent.Free;
end;
procedure TExecLoop.Execute;
var
   ExecuteEvent:TEvent;
   Process:Boolean;
   Count:Integer;
begin
   try
      Count:=0;
      while not Terminated do
      begin
         Inc(Count);
         ExecuteEvent:=nil;
         // try and open an Event that someone else has created
         try ExecuteEvent:=TEvent.Create('FunctionExecute',True,True); except end;
         if (not Terminated) and (ExecuteEvent <> nil) and (not StartUpProcessing) then // the Event Exists !
         begin
            Process:=ExecuteEvent.Wait(1000); // wait for it to be signaled
            ExecuteEvent.Reset;
            ExecuteEvent.Free;

            if Process then // signal received
            begin
               MemoryFileName:='C:\CorvusServiceFile.Dat';
               ServiceSharedData:=TSharedData.Create('CorvusService',False);
               MemoryFileName:='C:\MemoryFile.Dat';
               ExecuteFunction(GetFunctionExecuteID);
               ServiceSharedData.Free;
               ServiceSharedData:=nil;
            end;
         end
         else
         begin
            if (not Terminated) then PauseForMS(50);
         end;
         if ((Count mod 20) = 0)  and (not StartUpProcessing) then
            ProcessTransactionFiles;
         if (not Terminated) then 
            Synchronize(UpdateUserInterface);
      end;
   finally
   end;
end;

{TTxnTransfer}
class function TTxnTransfer.GetTxnLogWhereClause:String;
var
   StatusBits:TStatusBits;
   I,WS,Office,LastBit:Integer;
begin
   Result:='';
   Exit; // need to add all other WS's
   StatusBits:=TStatusBits.Create;
   StatusBits.State:=GetPSLRegString('Message Transfer','Last Txn Log Read','');
   if StatusBits.State <> '' then
   begin
      for I:=0 to StatusBits.Count-1 do
      begin
         WS:=StatusBits.WSNumber(I);
         Office:=StatusBits.OfficeCode(I);
         LastBit:=StatusBits.Size(Office,WS)-1;
         if Result = '' then
            Result:=Result+'where ((WSNumber = '+IntToStr(WS)+') and (RecordID > '+IntToStr(LastBit)+')) '
         else
            Result:=Result+'or ((WSNumber = '+IntToStr(WS)+') and (RecordID > '+IntToStr(LastBit)+')) '
      end;
   end;
   StatusBits.Free;
end;
class procedure TTxnTransfer.BuildStoreFromTxnLog(TxnLog:TQuery;FileTxStatus:TFileTxStatus;ProgressCallBack:TProgressCallBack);
var
   FieldIndex:Integer;
   RecordStringList:TTxnLogLine;
   RecordsList:TTxnLogLines;
   S:String;
   Counter,LastWSNumber:Integer;
   LastTxnType:String;
   TxnType:String;
   FN:Integer;
   SL:TStringList;
   RecordCount:Integer;
   DoneStatusBits:TStatusBits;
   MessageAccess:TMessageAccess;
begin
   LogProgress(2,'TTxnTransfer.BuildStoreFromTxnLog start');
   SL:=TStringList.Create;
   RecordStringList:=TTxnLogLine.Create;
   RecordsList:=TTxnLogLines.Create;
   
   if Assigned(ProgressCallBack) then //  "Opening Query..."
      ProgressCallBack(1,3,2,0);
      
   
   // get record count for progress bar   
   TxnLog.SQL.Text:='select count(RecordID) from txnlog '+GetTxnLogWhereClause;
   if not TxnLog.Active then 
      TxnLog.Active:=True;
   TxnLog.First;
   RecordCount:=0;
   if not TxnLog.EOF then
   begin
      RecordCount:=TxnLog.Fields[0].AsInteger;
      TxnLog.Active:=False;
   end;
   // get record count for progress bar   
   TxnLog.SQL.Text:='select * from Txnlog '+GetTxnLogWhereClause+' order by WSNumber,RecordID';
   if not TxnLog.Active then 
      TxnLog.Active:=True;
   if Assigned(ProgressCallBack) then //  "Transfering Data..."
      ProgressCallBack(1,3,2,1);
      
   DoneStatusBits:=TStatusBits.Create;
   DoneStatusBits.State:=GetPSLRegString('Message Transfer','Last Txn Log Read','');
   for FN:=1 to 1 do
   begin
      TxnLog.First;
      Counter:=0;
      while not TxnLog.EOF do
      begin
         if Assigned(ProgressCallBack) then
            ProgressCallBack(2,3,RecordCount,Counter); //  "Transfering Data..."
         Inc(Counter);
         if TxnLog.Fields[0].AsString = '' then
         begin
            TxnLog.Next;
         end
         else
         begin
            RecordStringList.Clear;
            for FieldIndex:=0 to TxnLog.FieldCount-1 do
            begin
               if ((TxnLog.Fields[FieldIndex] is TDateTimeField)
               or  (TxnLog.Fields[FieldIndex] is TTimeField)
               or  (TxnLog.Fields[FieldIndex] is TDateField)) then
               begin
                 Str(TxnLog.Fields[FieldIndex].Value,S);
                 RecordStringList.Add(S);
               end
               else
               begin
                 RecordStringList.Add(TxnLog.Fields[FieldIndex].AsString);
               end;
            end;
            if VarIsEmpty(RecordStringList.Office)   then RecordStringList.Office  :=0;
            if VarIsEmpty(RecordStringList.Price )   then RecordStringList.Price   :=0;
            if VarIsEmpty(RecordStringList.TxnValue) then RecordStringList.TxnValue:=0;
            
            // try and group by approx customer session
            RecordsList.Add(RecordStringList.PackText);
            LastTxnType:=TxnLog.FieldByName('RecType').AsString;
            LastWSNumber:=TxnLog.FieldByName('WSNumber').AsInteger;
            TxnLog.Next;
            if not TxnLog.EOF then
               TxnType:=TxnLog.FieldByName('RecType').AsString
            else
               TxnType:='';

            DoneStatusBits.Bit[TxnLog.FieldByName('Office').AsInteger,TxnLog.FieldByName('WSNumber').AsInteger,TxnLog.FieldByName('RecordID').AsInteger]:=True;
            if  (TxnLog.EOF)
            or  (RecordsList.Count >= 30)
            or (LastWSNumber <> TxnLog.FieldByName('WSNumber').AsInteger)
            or ((TxnType <> LastTxnType)
             and (LastTxnType <> 'TxnLine')
             and (LastTxnType <> 'TxnTotal')
             and (LastTxnType <> 'TxStkTo')
             and (LastTxnType <> 'TxStkFrom')
             and (LastTxnType <> 'StockUsed')
             and (LastTxnType <> 'StockTx')
             and (LastTxnType <> 'StockDec')
             and (LastTxnType <> 'PrLabel'))
            or ((TxnType='TxnTotal') and (TxnLog.FieldByName('Prod').AsString = 'Product.Cash'))  then
            begin // add message
              MessageAccess:=FileTxStatus.FileBlockMgr.AppendMessage(
                 TxnLog.FieldByName('Office').AsInteger,LastWSNumber,
                 dtTransaction,0,Now+1,Now+500,'Data','Data',mtTransaction,0,'',
                 RecordsList.PackText,True);
              RecordsList.Clear;
              MessageAccess.Free;
              // refresh display every thousand records
              if (Counter mod 1000) = 0 then
                 FileTxStatus.StatusMonitor.SetStatus(FileTxStatus.FileBlockMgr.GetStatus);
            end;
            if Application.Terminated then Break;
         end;
      end;

      if Assigned(ProgressCallBack) then //  "Flushing Files..."
         ProgressCallBack(3,3,2,0);
      FileTxStatus.FileBlockMgr.Flush;
      if Assigned(ProgressCallBack) then //  ""
         ProgressCallBack(3,3,2,1);

      // refresh display
      FileTxStatus.StatusMonitor.SetStatus(FileTxStatus.FileBlockMgr.GetStatus);
   end;
   SetPSLRegString('Message Transfer','Last Txn Log Read',DoneStatusBits.State);
   DoneStatusBits.Free;
   SL.Free;     
   RecordsList.Free;     
   RecordStringList.Free;
   LogProgress(2,'TTxnTransfer.BuildStoreFromTxnLog end');
end;

class procedure TTxnTransfer.WriteTxnToTable(TxnLogLine:TTxnLogLine;Table:TTable;MessageIndex:Integer);
var
   FieldIndex:Integer;
   DT:TDateTime;
   Code:Integer;
   Found:Boolean;
begin
   try
      if not Table.Active then Table.Active:=True;
      if CentralSystemDatabase then
         Found:=Table.FindKey([TxnLogLine.RecordID,TxnLogLine.WSNumber,TxnLogLine.Office])
      else
         Found:=Table.FindKey([TxnLogLine.RecordID,TxnLogLine.WSNumber]);
{      if Found then
      begin
         TxnLogLine.RecordID:=(MessageIndex *1000000)+TxnLogLine.RecordID;
         if CentralSystemDatabase then
            Found:=Table.FindKey([TxnLogLine.RecordID,TxnLogLine.WSNumber,TxnLogLine.Office])
         else
            Found:=Table.FindKey([TxnLogLine.RecordID,TxnLogLine.WSNumber]);
      end;}
      if not Found then
      begin
         try
            Table.Append;
            if TxnLogLine.Office = '' then
                TxnLogLine.Office:=0;
            for FieldIndex:=0 to TxnLogLine.Count-1 do
            begin
               if ((Table.Fields[FieldIndex] is TDateTimeField)
               or  (Table.Fields[FieldIndex] is TTimeField)
               or  (Table.Fields[FieldIndex] is TDateField)) then
               begin
                  Val(TxnLogLine[FieldIndex],DT,Code);
                  Table.Fields[FieldIndex].Value:=DT;
               end
               else
               begin
                  Table.Fields[FieldIndex].AsString:=TxnLogLine[FieldIndex];
               end;
            end;
            Table.Post;
         except
            on E:Exception do
            begin
               RaiseGUIDException('{44E5B599-4308-44C6-BB34-06F9CFF120F4} '+TxnLogLine.PackText,E);
               Table.Active:=False;
               Table.Active:=True;
            end;
         end;
      end;
//      else
//         RaiseGUIDError('{0999414C-F229-433A-B0D8-079C41C1594A}','Record Already Found ID '+TxnLogLine.PackText);
      
   except
      on E:Exception do
      begin
         RaiseGUIDException('{4F515A1B-CC2C-4995-9883-C1B20F565F04}',E);
      end;
   end;  
end;
class function TTxnTransfer.CreateTxnLogCalled(Database:TDatabase;DBName,Alias,FileName:String):TTable;
var
   DatabaseType:String;
   Query:TQuery;
begin
   LogProgress(2,'TTxnTransfer.CreateTxnLogCalled start '+DBName+' '+Alias+' '+FileName);
   Database.AliasName   :=Alias;
   Database.DatabaseName:=DBName;
   Database.LoginPrompt :=False;
   Database.SessionName :='Default';
   DataBase.Params.Add('USER NAME='+GetGPCSRegString('','UserName','psl'   ));
   DataBase.Params.Add('PASSWORD=' +GetGPCSRegString('','Password','corvus'));
   Result:=nil;                               
   // greate table of type given by HKLM\Software\PSL\GPCS\Workstation\DBType
   
   DatabaseType:=GetGPCSRegString('Workstation','DBType','Paradox');
   if DatabaseType = 'Paradox' then
   begin
      // create via DBE, this function should use SQL for all table types
      // and use common routines to select field naming syntax for 
      // specific DB types ... one day!
      
      Result:=TTable.Create(nil);
      with Result do
      begin
         try
            Active:=False;
            DatabaseName:=DBName;
            TableType:=ttParadox;
            TableName:=FileName;
            with FieldDefs do
            begin
               Clear; // clear the current field definitions
               Add('RecordID'        ,ftInteger    ,         0,True );
               Add('WSNumber'        ,ftSmallint   ,         0,True );
               Add('DateTime'        ,ftDateTime   ,         0,False);    
               Add('RecType'         ,ftString     ,        10,False);   
               Add('Period'          ,ftInteger    ,         0,False);
               Add('RecIndex'        ,ftSmallint ,           0,False);
               Add('Office'          ,ftInteger    ,         0,False);
               Add('Teller'          ,ftString     ,        20,False);   
               Add('PLU'             ,ftInteger    ,         0,False);
               Add('Prod'            ,ftString     ,        20,False);   
               Add('Price'           ,ftCurrency   ,         0,False);
               Add('Quantity'        ,ftInteger    ,         0,False);
               Add('TxnValue'        ,ftCurrency   ,         0,False);
               Add('Description'     ,ftString     ,       255,False);
               Add('Info'            ,ftMemo       ,         0,False);
               Add('Ident'           ,ftString     ,        15,False);
               Add('DomInfo'         ,ftMemo       ,         0,False);
            end;                                
            with IndexDefs do // create the index
            begin
               Clear;
               Add(''                   ,'RecordID;WSNumber'    ,[ixPrimary,ixUnique]);
               Add('PeriodIdx'          ,'PERIOD'               ,[ixCaseInsensitive] );
               Add('PeriodTellerTypeIdx','PERIOD;TELLER;RECTYPE',[ixCaseInsensitive] );
            end;                        
            CreateTable;
         except
            Result:=nil;
         end;
      end;
   end
   else if DatabaseType = 'Oracle' then
   begin
      Query:=TQuery.Create(nil);
      try
         Query.DatabaseName:=DBName;
         try
         Query.SQL.Text:='DROP TABLE "'+DBName+'"."'+FileName+'"'; // DROP TABLE "CORVUS"."TXNLOG";
         Query.ExecSQL;
         except
         end;
         Query.SQL.Text:='CREATE TABLE "'+DBName+'"."'+FileName+'"('                       +
                         '   "RECORDID"    NUMBER(9) NOT NULL,'                  +
                         '   "WSNUMBER"    NUMBER(9) NOT NULL,'                  +
                         '   "DATETIME"    DATE,'                                +
                         '   "RECTYPE"     CHAR(10),'                            +
                         '   "PERIOD"      NUMBER(9),'                           +
                         '   "RECINDEX"    NUMBER(9),'                           +
                         '   "OFFICE"      NUMBER(9),'                           +
                         '   "TELLER"      CHAR(20),'                            +
                         '   "PLU"         NUMBER(9),'                           +
                         '   "PROD"        CHAR(20),'                            +
                         '   "PRICE"       NUMBER(18, 4),'                       +
                         '   "QUANTITY"    NUMBER(10),'                          +
                         '   "TXNVALUE"    NUMBER(18, 4),'                       +
                         '   "DESCRIPTION" VARCHAR2(255),'                       +
                         '   "INFO"        VARCHAR2(255),'                       +
                         '   "IDENT"       CHAR(15),'                            +
                         '   "DOMINFO"     Long RAW,'                            +
                         'CONSTRAINT'                                            ;
         if CentralSystemDatabase then
         begin
            Query.SQL.Text:=Query.SQL.Text+
                         '   "TXNLOG_PINDEX" PRIMARY KEY("RECORDID", "WSNUMBER", "OFFICE"));';
         end
         else
         begin
            Query.SQL.Text:=Query.SQL.Text+
                         '   "TXNLOG_PINDEX" PRIMARY KEY("RECORDID", "WSNUMBER", "OFFICE"));';
         end;
         Query.ExecSQL;

         Query.SQL.Text:='CREATE INDEX "'+DBName+'"."PERIODIDX"  '+
                         '    ON "'+DBName+'"."+FileName+"("PERIOD");';
         Query.ExecSQL;
      
         Query.SQL.Text:='CREATE INDEX "'+DBName+'"."PERIODTELLERTYPEIDX"             '+
                         '    ON "'+DBName+'"."+FileName+"("PERIOD", "TELLER", "RECTYPE");';
         Query.ExecSQL;
         Query.Free;
      except
      end;
      Result:=TTable.Create(nil);
      with Result do
      begin
         Active:=False;
         DatabaseName:=DBName;
         TableName:=FileName;
      end;
   end
   else if DatabaseType = 'SQLServer' then
   begin
      Query:=TQuery.Create(nil);
      try
         Query.DatabaseName:=DBName;
         try
             Query.SQL.Text:='DROP TABLE "'+FileName+'"';
             Query.ExecSQL;
         except
         end;
         Query.SQL.Text:='CREATE TABLE '+UpperCase(FileName)+'(        '+
                         '  RECORDID    INT        NOT NULL, '+
                         '  WSNUMBER    SMALLINT   NOT NULL, '+
                         '  DATETIME    DATETIME,            '+
                         '  RECTYPE     CHAR(10),            '+
                         '  PERIOD      INT,                 '+
                         '  RECINDEX    SMALLINT,            '+
                         '  OFFICE      INT,                 '+
                         '  TELLER      CHAR(20),            '+
                         '  PLU         INT,                 '+
                         '  PROD        CHAR(20),            '+
                         '  PRICE       MONEY,               '+
                         '  QUANTITY    INT,                 '+
                         '  TXNVALUE    MONEY,               '+
                         '  DESCRIPTION VARCHAR(255),        '+
                         '  INFO        TEXT,                '+
                         '  IDENT       CHAR(15),            '+
                         '  DOMINFO     TEXT,                '+
                         '  CONSTRAINT '+UpperCase(FileName)+'_PINDEX PRIMARY KEY(RECORDID, WSNUMBER, OFFICE));';
         Query.ExecSQL;
                         
         Query.SQL.Text:='CREATE INDEX PERIODIDX ON '+UpperCase(FileName)+'(PERIOD);';
         Query.ExecSQL;
         
         Query.SQL.Text:='CREATE INDEX PERIODTELLERTYPEIDX ON '+UpperCase(FileName)+'(PERIOD, TELLER, RECTYPE);';
         Query.ExecSQL;

         Query.Free;
      except
      end;
      Result:=TTable.Create(nil);
      with Result do
      begin
         Active:=False;
         DatabaseName:=DBName;
         TableName:=FileName;
      end;
   end;        
   LogProgress(2,'TTxnTransfer.CreateTxnLogCalled end');
end;
class function TTxnTransfer.GetTransactionLines(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus):TTxnLogLines;
var
  MsgIndex:Integer;
  WSIdx:Integer;
  WS,Off,TxnLineIdx:Integer;
  Status:TStatusBits;
  MessageData:TMessageAccess;
  TxnLine:TTxnLogLine;
  TxnLines:TTxnLogLines;
  Flags:Integer;
  MaxTxnCount,TxnCount:Integer;
begin
   LogProgress(2,'TTxnTransfer.GetTransactionLines start');
   Result:=TTxnLogLines.Create;
   Status:=TStatusBits.Create;
   TxnLine:=TTxnLogLine.Create;
   TxnLines:=TTxnLogLines.Create;
   Status.State:=FileTxStatus.Status;

   MaxTxnCount:=0;
   for WSIdx:=0 to Status.Count-1 do
   begin
      WS:=Status.WSNumber(WSIdx);
      Off:=Status.OfficeCode(WSIdx);
      Inc(MaxTxnCount,Status.Size(Off,WS)); // get max count for progress bar
   end;
   TxnCount:=0;

   for WSIdx:=0 to Status.Count-1 do
   begin
      WS:=Status.WSNumber(WSIdx);
      Off:=Status.OfficeCode(WSIdx);
      for MsgIndex:=0 to Status.Size(Off,WS) do
      begin
         if Assigned(ProgressCallBack) then
            ProgressCallBack(1,3,MaxTxnCount,TxnCount); // "Getting Transaction Data..."
         Flags:=FileTxStatus.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
         // is it a transaction message
         if (Flags and TransactionMsg) = TransactionMsg then
         begin
            MessageData:=FileTxStatus.FileBlockMgr.GetMessage(Off,WS,MsgIndex);
            if MessageData <> nil then
            begin
               TxnLines.PackText:=MessageData.MessageData;
               // seperate each line of a customer session
               for TxnLineIdx:=0 to TxnLines.Count-1 do
                  Result.Add(TxnLines[TxnLineIdx]);
               MessageData.Free;
            end;
         end;
         Inc(TxnCount);
      end;
   end;
   TxnLine.Free;
   TxnLines.Free;
   Status.Free;
   LogProgress(2,'TTxnTransfer.GetTransactionLines end');
end;
class function TTxnTransfer.GetLimitedTransactionLines(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus;MaxPeriodCount:Integer):TTxnLogLines;
var
  MsgIndex:Integer;
  WSIdx:Integer;
  Off,WS,TxnLineIdx:Integer;
  Status:TStatusBits;
  MessageData:TMessageAccess;
  TxnLine:TTxnLogLine;
  TxnLines:TTxnLogLines;
  Flags:Integer;
  MaxTxnCount,TxnCount:Integer;
  MaxPeriod:Integer;
begin
   LogProgress(2,'TTxnTransfer.GetLimitedTransactionLines start '+IntToStr(MaxPeriodCount));
   Result:=TTxnLogLines.Create;
   Status:=TStatusBits.Create;
   TxnLine:=TTxnLogLine.Create;
   TxnLines:=TTxnLogLines.Create;
   Status.State:=FileTxStatus.Status;
   MaxTxnCount:=0;
   for WSIdx:=0 to Status.Count-1 do
   begin
      WS:=Status.WSNumber(WSIdx);
      Off:=Status.OfficeCode(WSIdx);
      Inc(MaxTxnCount,Status.Size(Off,WS)); // get max count for progress bar
   end;
   TxnCount:=0;

   for WSIdx:=0 to Status.Count-1 do
   begin
      MaxPeriod:=0;
      WS:=Status.WSNumber(WSIdx);
      Off:=Status.OfficeCode(WSIdx);
      for MsgIndex:=Status.Size(Off,WS) downto 0 do
      begin
         if Assigned(ProgressCallBack) then
            ProgressCallBack(1,3,MaxTxnCount,TxnCount); // "Getting Transaction Data..."
         Flags:=FileTxStatus.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
         // is it a transaction message
         if (Flags and TransactionMsg) = TransactionMsg then
         begin
            MessageData:=FileTxStatus.FileBlockMgr.GetMessage(Off,WS,MsgIndex);
            if MessageData <> nil then
            begin
               TxnLines.PackText:=MessageData.MessageData;
               MessageData.Free;
               if (MaxPeriod = 0) and (TxnLines.Count > 0) then
                  MaxPeriod:=TxnLines.Element[0].Period-MaxPeriodCount;
                  
               // seperate each line of a customer session
               if TxnLines.Element[0].Period >= MaxPeriod then
               begin
                  for TxnLineIdx:=0 to TxnLines.Count-1 do
                     Result.Add(TxnLines[TxnLineIdx]);
               end;
               // Limit Transaction read
//               if TxnLines.Element[0].Period < MaxPeriod then
//               begin
//                  Inc(TxnCount,MsgIndex);
//                  break;
//               end;
            end;
         end;
         Inc(TxnCount);
      end;
   end;
   TxnLine.Free;
   TxnLines.Free;
   Status.Free;
   LogProgress(2,'TTxnTransfer.GetLimitedTransactionLines end');
end;
class function TTxnTransfer.GetMinPeriod(FileTxStatus:TFileTxStatus;MaxPeriodCount:Integer):Integer;
var
  MsgIndex:Integer;
  WSIdx:Integer;
  Off,WS:Integer;
  Status:TStatusBits;
  MessageData:TMessageAccess;
  TxnLine:TTxnLogLine;
  TxnLines:TTxnLogLines;
  Flags:Integer;
  MaxPeriod:Integer;
  Size:Integer;
begin
   LogProgress(2,'TTxnTransfer.GetMinPeriod start '+IntToStr(MaxPeriodCount));
   Result:=TodayAsPeriod-MaxPeriodCount;
   Exit;
   Status:=TStatusBits.Create;
   TxnLine:=TTxnLogLine.Create;
   TxnLines:=TTxnLogLines.Create;
   Status.State:=FileTxStatus.Status;

   for WSIdx:=0 to Status.Count-1 do
   begin
      MaxPeriod:=0;
      WS:=Status.WSNumber(WSIdx);
      Off:=Status.OfficeCode(WSIdx);
      if (WS >= 0) and (Off >= 0) then
      begin
         Size:=Status.Size(Off,WS);
         for MsgIndex:=Size downto 0 do
         begin
            Flags:=FileTxStatus.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
            // is it a transaction message
            if (Flags and TransactionMsg) = TransactionMsg then
            begin
               MessageData:=FileTxStatus.FileBlockMgr.GetMessage(Off,WS,MsgIndex);
               if MessageData <> nil then
               begin
                  TxnLines.PackText:=MessageData.MessageData;
                  MessageData.Free;
                  try
                     if (MaxPeriod = 0) and (TxnLines.Count > 0) and (StrToIntDef(TxnLines.Element[0].Period,-1) <> -1) then
                     begin
                        MaxPeriod:=TxnLines.Element[0].Period-MaxPeriodCount;
                        if MaxPeriod < Result then
                           Result:=MaxPeriod;
                     end;
                     // Limit read
//                     if (TxnLines.Count > 0) // skip the rest for this WS as they are prior to MaxPeriod
//                     and (StrToIntDef(TxnLines.Element[0].Period,-1) <> -1) 
//                     and( TxnLines.Element[0].Period < MaxPeriod) then
//                     begin
//                        break;
//                     end;
                  except
                     on E:Exception do
                        RaiseGUIDException('{B6341411-6084-4320-B24A-42F8EDE00D72}',E)
                  end;
               end;
            end;
         end;
      end;
   end;
   TxnLine.Free;
   TxnLines.Free;
   Status.Free;
   LogProgress(2,'TTxnTransfer.GetMinPeriod end '+IntToStr(Result));
end;
class procedure TTxnTransfer.WriteLimitedTransactionLines(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus;MaxPeriodCount:Integer;Table:TTable);
var
  MsgIndex:Integer;
  WSIdx:Integer;
  Off,WS,TxnLineIdx:Integer;
  Status:TStatusBits;
  MessageData:TMessageAccess;
  TxnLine:TTxnLogLine;
  TxnLines:TTxnLogLines;
  Flags:Integer;
  KeepPeriods,PeriodCount:Integer;
  ThisPeriod:Integer;
  MaxTxnCount,TxnCount:Integer;
  StxPeriod:Integer;
begin
   LogProgress(2,'TTxnTransfer.WriteLimitedTransactionLines start '+IntToStr(MaxPeriodCount));
   Status:=TStatusBits.Create;
   TxnLine:=TTxnLogLine.Create;
   TxnLines:=TTxnLogLines.Create;
   Status.State:=FileTxStatus.Status;
   MaxTxnCount:=0;
   for WSIdx:=0 to Status.Count-1 do
   begin
      WS:=Status.WSNumber(WSIdx);
      Off:=Status.OfficeCode(WSIdx);
      Inc(MaxTxnCount,Status.Size(Off,WS)); // get max count for progress bar
   end;
   TxnCount:=0;
   KeepPeriods:=StrToIntDef(GetGPCSRegString('','Transaction Periods To Keep','0'),0);
   StxPeriod:=TodayAsPeriod-2;
   if FileTxStatus.CurrentMinPeriod < 0 then
      FileTxStatus.CurrentMinPeriod:=GetMinPeriod(FileTxStatus,KeepPeriods);
   for WSIdx:=0 to Status.Count-1 do
   begin
      PeriodCount:=0;
      ThisPeriod:=$FFFFFF;
      WS:=Status.WSNumber(WSIdx);
      Off:=Status.OfficeCode(WSIdx);
      if WriteDataForOtherOffices or (Off = FileTxStatus.ThisOfficeID) then
      begin
         if Assigned(ProgressCallBack) then
            ProgressCallBack(1,3,MaxTxnCount,TxnCount); // "Getting Transaction Data..."
         Beep(1500,50);
         for MsgIndex:=Status.Size(Off,WS) downto 0 do
         begin
            try
               Flags:=FileTxStatus.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
               // is it a transaction message
               if (Flags and TransactionMsg) = TransactionMsg then
               begin
                  MessageData:=FileTxStatus.FileBlockMgr.GetMessage(Off,WS,MsgIndex);
                  if MessageData <> nil then
                  begin
                     TxnLines.PackText:=MessageData.MessageData;
                     MessageData.Free;
                     if TxnLines.Count > 0 then
                     begin
                        if TxnLines.Element[0].Period < ThisPeriod then
                        begin
                           ThisPeriod:=TxnLines.Element[0].Period;
                           Inc(PeriodCount);
                        end;
                        if PeriodCount <= KeepPeriods then // break;
                        begin
                           for TxnLineIdx:=0 to TxnLines.Count-1 do
                           try
                              TxnLine.PackText:=TxnLines[TxnLineIdx];
                              // don't write StockTx's more that 2 days old
                              if (TxnLine.RecType <> 'StockTx') 
                              or (TxnLine.Period >= StxPeriod) then
                                 WriteTxnToTable(TxnLines.Element[TxnLineIdx],Table,MsgIndex);
                           except
                              on E:Exception do
                                 RaiseGUIDException('{F979A122-0515-445A-9428-DE90231351C1}',E);
                           end;
                           Application.ProcessMessages;
                        end;
                     end;    
                  end;
               end;
            except
               on E:Exception do
                  RaiseGUIDException('{849F3B21-8414-4F48-A37F-D80C88A4F4D7}',E);
            end;
            Inc(TxnCount);
            if Assigned(ProgressCallBack) then
               ProgressCallBack(1,3,MaxTxnCount,TxnCount); // "Getting Transaction Data..."
         end;
         Sleep(1);
      end;
   end;
   TxnLine.Free;
   TxnLines.Free;
   Status.Free;
   Beep(2000,100);
   LogProgress(2,'TTxnTransfer.WriteLimitedTransactionLines end');
end;
class procedure TTxnTransfer.MarkAsProcessed(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus);
var
  MsgIndex:Integer;
  WSIdx:Integer;
  Off,WS:Integer;
  Status:TStatusBits;
  Flags:Integer;
begin
    // just for testing...
   LogProgress(2,'TTxnTransfer.MarkAsProcessed start');
   FileTxStatus.FUnProcessedList.Clear;
   Status:=TStatusBits.Create;
   Status.State:=FileTxStatus.Status;
   for WSIdx:=0 to Status.Count-1 do
   begin
      WS:=Status.WSNumber(WSIdx);
      Off:=Status.OfficeCode(WSIdx);
      for MsgIndex:=0 to Status.Size(Off,WS) do
      begin
         Flags:=FileTxStatus.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
         // if its a Transaction and it has bee processed
         if  ((Flags and TransactionMsg  ) = TransactionMsg   )
         and ((Flags and MessageHasGoodCRC) = MessageHasGoodCRC)
         and ((Flags and MessageProcessed) <> MessageProcessed) then
         begin                           
            // change flags to processed
            Flags:=Flags or MessageProcessed;
            FileTxStatus.FileBlockMgr.SetMessageFlags(Off,WS,MsgIndex,Flags);
         end;
      end;
   end;
   Status.Free;
   LogProgress(2,'TTxnTransfer.MarkAsProcessed end');
end;                                                
class function TTxnTransfer.OfficeName(OfficeCode:Integer):String;
var
   FSM:TFileStatusMon;
begin
   FSM:=TFileStatusMon.Create(nil);
   Result:=FSM.OfficeNameFromCode(OfficeCode);
   FSM.Free;
end;
class function TTxnTransfer.ListOffices(OType:String;Into:TStrings):String;
var
   FSM:TFileStatusMon;
begin
   FSM:=TFileStatusMon.Create(nil);
   Result:=FSM.ListOffices(OType,Into);
   FSM.Free;
end;
class function TTxnTransfer.OfficeCodeRefs:String;
var
   FSM:TFileStatusMon;
begin
   try
      FSM:=TFileStatusMon.Create(nil);
      Result:=FSM.OfficeCodeRefs;
      FSM.Free;
   except
      on E:Exception do
         RaiseGUIDException('{34FC9F01-8E2E-4A09-863C-D837C235D56A}',E);
   end;
end;
class function TTxnTransfer.GetNextOffice(FileTxStatus:TFileTxStatus;DestinationOffice:Integer;PhysicalLayout,LogicalLayout:String):String;
var
  ResSL:TPackStringList;
{  OfficeRoutes:TCorvusNode;
  Offices:TCorvusNode;
  Routes:TCorvusNode;
  RouteNode:TCorvusNode;
  ThisOfficeOnRoute:TCorvusNode;
  DestOfficeOnRoute:TCorvusNode;
  I,J:Integer;
  DestinationOfficeName:String;}
  O1,O2:Integer;
begin
   LogProgress(2,'TTxnTransfer.GetNextOffice start '+IntToStr(DestinationOffice)+' '+PhysicalLayout+' '+LogicalLayout);
   ResSL:=TPackStringList.Create;
   O1:=0; O2:=0;
   ResSL.Text:=FileTxStatus.GetRoute(FileTxStatus.ThisOfficeID,DestinationOffice,PhysicalLayout);
   if ResSL.Count > 0 then 
      O1:=FileTxStatus.OfficeCodeFromName(ResSL[0]);
      
   ResSL.Text:=FileTxStatus.GetRoute(FileTxStatus.ThisOfficeID,DestinationOffice,LogicalLayout);
   if ResSL.Count > 0 then 
      O2:=FileTxStatus.OfficeCodeFromName(ResSL[0]);

   ResSL.Clear;
   if O1 > 0 then ResSL.Add(IntToStr(O1));
   if O2 > 0 then ResSL.Add(IntToStr(O2));
   Result:=ResSL.PackText;
   ResSL.Free;
   LogProgress(2,'TTxnTransfer.GetNextOffice end '+Result);
{      
   LogProgress(2,'TTxnTransfer.GetNextOffice start '+IntToStr(DestinationOffice)+' '+PhysicalLayout+' '+LogicalLayout);
   ResSL:=TPackStringList.Create;
   OfficeRoutes:=FileTxStatus.OfficeRouteInfo.NodeNamed('OfficesRoutes');
   if (FileTxStatus.ThisOfficeInfo <> nil) and (OfficeRoutes <> nil) then
   begin
      Offices:=OfficeRoutes.NodeNamed('Offices');
      Routes :=OfficeRoutes.NodeNamed('Routes');
      if (Offices <> nil) and (Routes <> nil) then
      begin
         DestinationOfficeName:='';
         for I:=0 to Offices.Count-1 do
         begin
            if (Offices.Node[I].NodeNamed('Code') <> nil) and (StrToIntDef(Offices.Node[I].NodeNamed('Code')[0],0) = DestinationOffice) then
            begin
               DestinationOfficeName:=Offices.Node[I].Name;
               break;
            end;
         end;
         if DestinationOfficeName <> '' then
         begin
            RouteNode:=Routes.NodeNamed(PhysicalLayout);
            if RouteNode <> nil then
            begin
               ThisOfficeOnRoute:=RouteNode.AnySubNodeNamed(FileTxStatus.ThisOfficeInfo.OfficeName);
               if ThisOfficeOnRoute <> nil then
               begin
                  DestOfficeOnRoute:=ThisOfficeOnRoute.AnySubNodeNamed(DestinationOfficeName);
                  while (DestOfficeOnRoute <> nil) and (DestOfficeOnRoute.ParentNode <> ThisOfficeOnRoute) do
                     DestOfficeOnRoute:=DestOfficeOnRoute.ParentNode;
                  if (DestOfficeOnRoute <> nil) then
                  begin
                     ResSL.Add(DestOfficeOnRoute.Name);
                  end; 
               end;                
            end;
            RouteNode:=Routes.NodeNamed(LogicalLayout);
            if RouteNode <> nil then
            begin
               ThisOfficeOnRoute:=RouteNode.AnySubNodeNamed(FileTxStatus.ThisOfficeInfo.OfficeName);
               if ThisOfficeOnRoute <> nil then
               begin
                  DestOfficeOnRoute:=ThisOfficeOnRoute.AnySubNodeNamed(DestinationOfficeName);
                  while (DestOfficeOnRoute <> nil) and (DestOfficeOnRoute.ParentNode <> ThisOfficeOnRoute) do
                     DestOfficeOnRoute:=DestOfficeOnRoute.ParentNode;
                  if (DestOfficeOnRoute <> nil) then
                  begin
                     ResSL.Add(DestOfficeOnRoute.Name);
                  end; 
               end;                
            end;
         end;
         for J:=0 to ResSL.Count-1 do
         begin
            for I:=0 to Offices.Count-1 do
            begin
               if  (Offices.NodeNamed(ResSL[J]) <> nil) 
               and (Offices.NodeNamed(ResSL[J]).NodeNamed('Code') <> nil) then
               begin
                  ResSL[J]:=Offices.NodeNamed(ResSL[J]).NodeNamed('Code')[0];
                  break;
               end;
            end;
         end;
      end;
   end;
   Result:=ResSL.PackText;
   ResSL.Free;
   LogProgress(2,'TTxnTransfer.GetNextOffice end '+Result); }
end;
class procedure TTxnTransfer.MarkAsUnTransmitted(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus);
var
  MsgIndex:Integer;
  WSIdx:Integer;
  Off,WS:Integer;
  Status:TStatusBits;
  Flags:Integer;
begin
   LogProgress(2,'TTxnTransfer.MarkAsUnTransmitted start');
    // just for testing...
   Status:=TStatusBits.Create;
   Status.State:=FileTxStatus.Status;
   for WSIdx:=0 to Status.Count-1 do
   begin
      WS:=Status.WSNumber(WSIdx);
      Off:=Status.OfficeCode(WSIdx);
      for MsgIndex:=0 to Status.Size(Off,WS) do
      begin
         Flags:=FileTxStatus.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
         // if its a Transaction and it has bee processed
         if (Flags and MessageTransfered) = MessageTransfered then
         begin
            // change flags to Un-Transfered
            Flags:=Flags and (not MessageTransfered) ;
            FileTxStatus.FileBlockMgr.SetMessageFlags(Off,WS,MsgIndex,Flags);
         end;
      end;
   end;
   Status.Free;
   LogProgress(2,'TTxnTransfer.MarkAsUnTransmitted end');
end;
class procedure TTxnTransfer.MarkAsUnProcessed(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus);
var
  MsgIndex:Integer;
  WSIdx:Integer;
  Off,WS:Integer;
  Status:TStatusBits;
  Flags:Integer;
  Max,Count:Integer;
begin
   LogProgress(2,'TTxnTransfer.MarkAsUnProcessed start');
   FileTxStatus.FUnProcessedList.Clear;
    // just for testing...                  
   Status:=TStatusBits.Create;
   Status.State:=FileTxStatus.FFileBlockMgr.GetStatus;
   Max:=0;
   for WSIdx:=0 to Status.Count-1 do
   begin
      WS:=Status.WSNumber(WSIdx);
      Off:=Status.OfficeCode(WSIdx);
      Max:=Max+Status.Size(Off,WS);
   end;
   Count:=0;
   for WSIdx:=0 to Status.Count-1 do
   begin
      WS:=Status.WSNumber(WSIdx);
      Off:=Status.OfficeCode(WSIdx);
      for MsgIndex:=0 to Status.Size(Off,WS) do
      begin
         if Assigned(ProgressCallBack) then ProgressCallBack(1,3,Max,Count);
         Inc(Count);
         Flags:=FileTxStatus.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
         // if its a Transaction and it has bee processed
         if  ((Flags and TransactionMsg  ) = TransactionMsg   )
         and ((Flags and MessageHasGoodCRC) = MessageHasGoodCRC)
         and ((Flags and (MessageProcessed or PenDataProcessed)) <> 0) then
         begin
            // change flags to unprocessed
            Flags:=Flags and (not MessageProcessed) ;
            Flags:=Flags and (not PenDataProcessed) ;
            FileTxStatus.FileBlockMgr.SetMessageFlags(Off,WS,MsgIndex,Flags);
            FileTxStatus.FUnProcessedList.Add(IntToHex(Off,4)+IntToHex(WS,2)+IntToHex(MsgIndex,8));
         end;
      end;
   end;
   Status.Free;
   LogProgress(2,'TTxnTransfer.MarkAsUnProcessed end');
end;                                                  

function GetVersion:Integer;
var 
   FS:TFileStream;
   FileName:String;
begin
   LogProgress(2,'GetVersion start');
   Result:=1;
   FileName:=GetPSLRegString('CorvusService','DLLName','');
   if (FileName <> '') and FileExists(FileName) then
   begin
      try
         FS:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyNone);
         Result:=FileGetDate(FS.Handle);
         FS.Free;
      except
      end;
   end;
   LogProgress(2,'GetVersion end '+IntToStr(Result));
end;
class function TTxnTransfer.SendReplaceSelfTo(Host:String;FileTxStatus:TFileTxStatus;HangUpWhenComplete:Boolean):String;
var 
   FS:TFileStream;
   DataLength:Integer;
   FileVersion:Integer;
   FileName:String;
const
   SS:TStringStream = nil;
begin
   LogProgress(2,'TTxnTransfer.SendReplaceSelfTo start '+Host);
   if Host = 'CleanUp' then
   begin
      if SS <> nil then 
      begin
         SS.Free;
         SS:=nil;
      end;
      Result:='OK';
      Exit;
   end;
   FileName:=GetPSLRegString('CorvusService','DLLName','');
   if (FileName <> '') and (FileTxStatus <> nil) then
   begin
     if Assigned (FileTxStatus.OnContactStatus) then
        FileTxStatus.OnContactStatus('Sending Replacement to '+Host);
     if SS = nil then
     begin
        FS:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyNone);
        SS:=TStringStream.Create('');
     
        FileVersion:=FileGetDate(FS.Handle);
        SS.Write(FileVersion,SizeOf(Integer));
        
        DataLength:=Length(FileName);
        SS.Write(DataLength,SizeOf(DataLength));
        SS.Write((@FileName[1])^,DataLength);

        TCompressor.CompressStream(FS,SS);
        FS.Free;
     end;
     SS.Position:=0;
     Result:=FileTxStatus.SendCommand(Host,ContactTimeOut,ctReplaceSelf,SS,HangUpWhenComplete);
   end;
   LogProgress(2,'TTxnTransfer.SendReplaceSelfTo end '+Result);
end;
class function TTxnTransfer.ProcessUnProcessedMessages(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus):Boolean;
var
   MsgIndex:Integer;
   I,Off,WS,MaxCount:Integer;
   Status:TStatusBits;
   TxnProcessor:TTxnProcessor;
   MessageData:TMessageAccess;
   ProcessedCount,Flags:Integer;
const
  RunningThisFunc:Boolean=False;
begin
   Result:=True;

   if DontProcessNow or RunningThisFunc
   or ((not FileTxStatus.Active) and (not SpecialProcessing))
   or (FileTxStatus.FUnProcessedList.Count = 0) then Exit;

   LogProgress(2,'PUPMst.');
   BeenInterrupted:=False;
   RunningThisFunc:=True;
   ProcessedCount:=0;
   try
      if FileTxStatus.CurrentMinPeriod < 0 then
         FileTxStatus.CurrentMinPeriod:=GetMinPeriod(FileTxStatus,StrToIntDef(GetGPCSRegString('','Transaction Periods To Keep','0'),0));
      if FileTxStatus.FUnProcessedList.Count > 0 then
      begin
         Result:=False;
         TxnProcessor:=TTxnProcessor.Create('TempUPPSL');
         try
            if StartUpProcessing then
               MaxCount:=FileTxStatus.FUnProcessedList.Count
            else
               MaxCount:=Min(FileTxStatus.FUnProcessedList.Count,MaxTxnProcessPerInterval);
            Status:=TStatusBits.Create;
            Status.State:=FileTxStatus.Status;
            for I:=0 to MaxCount-1 do
            begin
               if (not FileTxStatus.Active) and (not SpecialProcessing) then Break;
               if Assigned(ProgressCallBack) then
                  ProgressCallBack(3,3,MaxCount,I);
               if FileTxStatus.FUnProcessedList.Count > 0 then
               begin
                  Inc(ProcessedCount);
                  Off     :=StrToInt('$'+Copy(FileTxStatus.FUnProcessedList[0],1,4));
                  WS      :=StrToInt('$'+Copy(FileTxStatus.FUnProcessedList[0],5,2));
                  MsgIndex:=StrToInt('$'+Copy(FileTxStatus.FUnProcessedList[0],7,8));
                  FileTxStatus.FUnProcessedList.Delete(0);
                  Flags:=FileTxStatus.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
                  // is it a transaction that hasn't been processed?
                  if  ((Flags and TransactionMsg  ) = TransactionMsg   )
                  and ((Flags and MessageProcessed) <> MessageProcessed)
                  and ((Flags and MessageHasGoodCRC) = MessageHasGoodCRC) then
                  begin
                     FileTxStatus.CurrentStatus:=FileTxStatus.CurrentStatus or 1;
                     MessageData:=FileTxStatus.FileBlockMgr.GetMessage(Off,WS,MsgIndex);
                     if (MessageData <> nil) and (MessageData.GoodCRC) then
                     begin
                        TxnProcessor.ReceiveMessage(MessageData.MessageData,False,FileTxStatus.CurrentMinPeriod,FileTxStatus,MsgIndex);
                        MessageData.Flags:=Flags or MessageProcessed;
                        FileTxStatus.FFileBlockMgr.UpdateMessageFlags(MessageData);
                        MessageData.Free;
                     end
                     else
                     begin
                        FileTxStatus.FileBlockMgr.SetMessageFlags(Off,WS,MsgIndex,(Flags and (not MessageHasGoodCRC)) or BadMessageBlock);
                     end;
                  end;
               end;  
               if (I mod 50) = 0 then
                  Application.ProcessMessages;
               if (Application.Terminated) or BeenInterrupted then
                  Break;
            end;
            if WriteDataForOtherOffices and (GetPSLRegString('Table Builder','Enabled','0') = '1') then
               CallDLLFunc('CheckData','Complete');  
            Status.Free;
         except                                         
            on E:Exception do
               RaiseGUIDException('{7EFBAF38-7C7D-4CA0-9942-4F66CFC8BBBC}',E);
         end;
         TxnProcessor.Free;
      end;
      if (FileTxStatus.FUnProcessedList.Count = 0) then
      begin
         Result:=True;
         if (ProcessedCount > 0) then
            FileTxStatus.CurrentStatus:=FileTxStatus.CurrentStatus and $FC;
      end;
      if (ProcessedCount > 0) then
         FileTxStatus.FFileBlockMgr.Flush;
   finally
      RunningThisFunc:=False;
   end;
   LogProgress(2,'PUPMed.');
end;
class function TTxnTransfer.ProcessUnProcessedPensions(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus):Boolean;
var
   MsgIndex:Integer;
   I,Off,WS,MaxCount:Integer;
   Status:TStatusBits;
   MessageData:TMessageAccess;
   ProcessedCount,Flags:Integer;
   TxnLine:TTxnLogLine;      
   TxnLineIdx:Integer;
   TxnLines:TTxnLogLines;
   TxnDomInfoLines:TDomInfoLines;
   PensionPayment:TMinPensionPayment;
   Ofs:Integer;
const
  RunningThisFunc:Boolean=False;
begin
   Result:=True;
   if (not UpdateOsmiumDBHere)
   or DontProcessNow 
   or RunningThisFunc 
   or (ThePensionsList.Count <= 0) then Exit;
   LogProgress(2,'PUPPst.');      
   BeenInterrupted:=False;
   ProcessedCount:=0;
   RunningThisFunc:=True;
   TxnLine:=TTxnLogLine.Create;
   TxnLines:=TTxnLogLines.Create;
   TxnDomInfoLines:=TDomInfoLines.Create;
   PensionPayment:=TMinPensionPayment.Create;
   try
      if ThePensionsList.Count > 0 then
      begin
         Result:=False;
         try
            if StartUpProcessing then 
               MaxCount:=ThePensionsList.Count
            else
               MaxCount:=Min(ThePensionsList.Count,MaxPenProcessPerInterval);
            Status:=TStatusBits.Create;
            Status.State:=FileTxStatus.Status;
            Ofs:=0;
            for I:=0 to MaxCount-1 do
            begin
               if Assigned(ProgressCallBack) then
                  ProgressCallBack(3,3,MaxCount,I);
               if Ofs < ThePensionsList.Count then
               begin
                  Inc(ProcessedCount);
                  Off     :=StrToInt('$'+Copy(ThePensionsList[Ofs],1,4));
                  WS      :=StrToInt('$'+Copy(ThePensionsList[Ofs],5,2));
                  MsgIndex:=StrToInt('$'+Copy(ThePensionsList[Ofs],7,8));
                  Flags:=FileTxStatus.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
                  if  ( (Flags and TransactionMsg   ) =  TransactionMsg    )
                  and ( (Flags and PensionMsg       ) =  PensionMsg        )
//                  and ( (Flags and PenDataProcessed ) <> PenDataProcessed  ) 
                  and ( (Flags and MessageHasGoodCRC) =  MessageHasGoodCRC ) then
                  begin
                     ThePensionsList.Delete(Ofs);
//                     FileTxStatus.CurrentStatus:=FileTxStatus.CurrentStatus or 1;
                     MessageData:=FileTxStatus.FileBlockMgr.GetMessage(Off,WS,MsgIndex);
                     if (MessageData <> nil) and (MessageData.GoodCRC) then
                     begin
                        TxnLines.PackText:=MessageData.MessageData;
                        for TxnLineIdx:=0 to TxnLines.Count-1 do
                        begin
                           TxnLine.PackText:=TxnLines[TxnLineIdx];
                           if  (TxnLine.RecIndex = 0) and (TxnLine.RecType = 'TxnLine')
                           and ((TxnLine.PLU = NormalPensionPLU) or (TxnLine.PLU = ArrearsPensionPLU)) then
                           begin
                              TxnDomInfoLines.PackText:=TxnLine.DomInfo;
                              AssignPensionFromDomInfo(PensionPayment,TxnDomInfoLines);
                              MakePensionPayment(PensionPayment.VoucherNumber,FileTxStatus.OfficePCodeFromCode(TxnLine.Office),TxnLine.Period,PensionPayment.PayeeIdentifier,PensionPayment.Amount,PensionPayment.PayeeName);
                           end;
                        end;
                        MessageData.Flags:=Flags or PenDataProcessed;
                        FileTxStatus.FFileBlockMgr.UpdateMessageFlags(MessageData);
                        MessageData.Free;
                     end
                     else
                     begin
                        FileTxStatus.FileBlockMgr.SetMessageFlags(Off,WS,MsgIndex,(Flags and (not MessageHasGoodCRC)) or BadMessageBlock);
                     end;
                  end
                  else
                     Inc(Ofs);
               end;  
               if (I mod 50) = 0 then
                  Application.ProcessMessages;
               if (Application.Terminated) or BeenInterrupted then
                  Break;
            end;
            Status.Free;
         except                                         
            on E:Exception do
               RaiseGUIDException('{1D72F28F-17F8-456C-9F30-6ED2CEAF8175}',E);
         end;
      end;
//      if (FileTxStatus.FPensionsList.Count = 0) then
//      begin
//         Result:=True;
//         if (ProcessedCount > 0) then
//            FileTxStatus.CurrentStatus:=FileTxStatus.CurrentStatus and $FC;
//      end;
      if (ProcessedCount > 0) then
         FileTxStatus.FFileBlockMgr.Flush;
   finally
      RunningThisFunc:=False;
   end;
   TxnLine.Free;
   TxnLines.Free;
   TxnDomInfoLines.Free;
   PensionPayment.Free;
   LogProgress(2,'PUPPed.');
end;
class function TTxnTransfer.FindPensionMessages(FileTxStatus:TFileTxStatus):Boolean;
var
  MsgIndex:Integer;
  WSIdx:Integer;
  Off,WS:Integer;
  Status:TStatusBits;
  Size,Flags:Integer;
begin
   Result:=True;
   LogProgress(2,'TTxnTransfer.FindPensionMessages start');
//   FileTxStatus.FPensionsList.Clear;           
   Status:=TStatusBits.Create;
   if FileTxStatus.ClassType = TFileTxStatus then
      Status.State:=FileTxStatus.Status
   else
      Status.State:=FileTxStatus.FFileBlockMgr.GetStatus;
   try
      for WSIdx:=0 to Status.Count-1 do
      begin
         WS:=Status.WSNumber(WSIdx);
         Off:=Status.OfficeCode(WSIdx);
         if (WS >= 0) and (Off >= 0) then
         begin
            Size:=Status.Size(Off,WS);
            for MsgIndex:=0 to Size do
            begin
               Flags:=FileTxStatus.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
               if (Flags and PensionMsg) <> 0 then
               begin
                  if (Flags and TransactionMsg) <> 0 then
                     ThePensionsList.Add(IntToHex(Off,4)+IntToHex(WS,2)+IntToHex(MsgIndex,8)+'T')
                  else
                     ThePensionsList.Add(IntToHex(Off,4)+IntToHex(WS,2)+IntToHex(MsgIndex,8)+'P');
               end;
            end;
         end;
         if Application.Terminated then Break;
      end;
   except
      on E:Exception do
         RaiseGUIDException('{166FCD4D-7086-4959-826E-EEA540E7BA7E}',E);
   end;
   LogProgress(2,'TTxnTransfer.FindPensionMessages end');
end;
class function TTxnTransfer.FindMOMessages(FileTxStatus:TFileTxStatus):Boolean;
var
  MsgIndex:Integer;
  WSIdx:Integer;
  Off,WS:Integer;
  Status:TStatusBits;
  Size,Flags:Integer;
begin
   Result:=True;
   LogProgress(2,'TTxnTransfer.FindMOMessages start');
   if TheMOList = nil then TheMOList:=TStringList.Create;
   TheMOList.Clear;           
   Status:=TStatusBits.Create;
   if FileTxStatus.ClassType = TFileTxStatus then
      Status.State:=FileTxStatus.Status
   else
      Status.State:=FileTxStatus.FFileBlockMgr.GetStatus;
   try
      for WSIdx:=0 to Status.Count-1 do
      begin
         WS:=Status.WSNumber(WSIdx);
         Off:=Status.OfficeCode(WSIdx);
         if (WS >= 0) and (Off >= 0) then
         begin
            Size:=Status.Size(Off,WS);
            for MsgIndex:=0 to Size do
            begin
               Flags:=FileTxStatus.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
               if (Flags and MoneyOrderMsg) <> 0 then
               begin
                  if (Flags and TransactionMsg) <> 0 then
                     TheMOList.Add(IntToHex(Off,4)+IntToHex(WS,2)+IntToHex(MsgIndex,8)+'T')
                  else
                     TheMOList.Add(IntToHex(Off,4)+IntToHex(WS,2)+IntToHex(MsgIndex,8)+'O');
               end;
            end;
         end;
         if Application.Terminated then Break;
      end;
   except
      on E:Exception do
         RaiseGUIDException('{286E9C71-0A14-49F8-B512-7E8F84B7477F}',E);
   end;
   LogProgress(2,'TTxnTransfer.FindMOMessages end');
end;
class function TTxnTransfer.FindUnProcessedMessages(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus):Boolean;
var
  MsgIndex:Integer;
  WSIdx:Integer;
  Off,WS:Integer;
  Status:TStatusBits;
  Flags:Integer;
  Max,Count:Integer;
  ContainsPensionMessage:Boolean;
  FoundPensionTransaction:Boolean;
  FoundMoneyOrderTransaction:Boolean;
  ContainsMoneyOrderMessage:Boolean;
  TxnLine:TTxnLogLine;      
  TxnLineIdx:Integer;
  Res:Integer;
  TxnLines:TTxnLogLines;
  MessageAccess:TMessageAccess;
const       
  RunningThisFunc:Boolean=False;
begin
   Result:=True;
   if RunningThisFunc then Exit;
   Result:=False;
   RunningThisFunc:=True;
   try
      LogProgress(2,'TTxnTransfer.FindUnProcessedMessages start');
      FoundPensionTransaction:=False;
      FoundMoneyOrderTransaction:=False;
      FileTxStatus.FTransmitList.Clear;
//      FileTxStatus.FPensionsList.Clear;
      FileTxStatus.FUnProcessedList.Clear;
      try
         Status:=TStatusBits.Create;
         if FileTxStatus.ClassType = TFileTxStatus then
            Status.State:=FileTxStatus.Status
         else
            Status.State:=FileTxStatus.FFileBlockMgr.GetStatus;
         try
            Max:=0;
            for WSIdx:=0 to Status.Count-1 do
            begin
               WS:=Status.WSNumber(WSIdx);
               Off:=Status.OfficeCode(WSIdx);
               Max:=Max+Status.Size(Off,WS);
            end;
            Count:=0;
            for WSIdx:=0 to Status.Count-1 do
            begin
               WS:=Status.WSNumber(WSIdx);
               Off:=Status.OfficeCode(WSIdx);
               for MsgIndex:=0 to Status.Size(Off,WS) do
               begin
                  if ((WSIdx mod 1000) = 0) then
                  begin
                     if Assigned(ProgressCallBack) then 
                        ProgressCallBack(2,3,Max,Count);
                     Application.ProcessMessages;
                     if Application.Terminated then Break;
                  end;
                  Inc(Count);                                  
                  Flags:=FileTxStatus.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
                  if Flags <> 0 then
                  begin
                     Res:=UpdateLists(Flags,Off,WS,MsgIndex,FileTxStatus,nil);
                     if (Res and 1) = 1 then FoundPensionTransaction:=True;
                     if (Res and 2) = 2 then FoundMoneyOrderTransaction:=True;
                  end;   
               end;
               if Application.Terminated then Break;
            end;
         except
            on E:Exception do
               RaiseGUIDException('{6CE74ADD-3825-427E-873E-53CB1862B743}',E);
         end;
         // pension transaction need to be marked as pensions
         if (FileTxStatus.ClassType = TFileTxStatus)
         and ((ProcessingPensions and (not FoundPensionTransaction)) 
         or (ProcessingMoneyOrders and (not FoundMoneyOrderTransaction))) then
         begin
            TxnLines:=TTxnLogLines.Create;
            TxnLine:=TTxnLogLine.Create;
            for WSIdx:=0 to Status.Count-1 do
            begin
               WS:=Status.WSNumber(WSIdx);
               Off:=Status.OfficeCode(WSIdx);
               for MsgIndex:=0 to Status.Size(Off,WS) do
               begin
                  Flags:=FileTxStatus.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
                  ContainsPensionMessage:=False;
                  ContainsMoneyOrderMessage:=False;
                  if ((Flags and (MessageHasGoodCRC or TransactionMsg)) <> 0) then
                  begin
                     MessageAccess:=FileTxStatus.FileBlockMgr.GetMessage(Off,WS,MsgIndex);
                     if MessageAccess <> nil then
                     begin
                        TxnLines.PackText:=MessageAccess.MessageData;
                        for TxnLineIdx:=0 to TxnLines.Count-1 do
                        begin
                           TxnLine.PackText:=TxnLines[TxnLineIdx];
                           try
                              if (TxnLine.Count > 15) then
                              begin
                                 if (TxnLine.RecIndex = 0) and (TxnLine.RecType = 'TxnLine')
                                 and ((TxnLine.PLU = NormalPensionPLU) or (TxnLine.PLU = ArrearsPensionPLU)) then
                                 begin
                                    ContainsPensionMessage:=True;
                                 end
                                 else if (TxnLine.RecType = MOIssueType) or (TxnLine.RecType = MOPaidType)
                                      or (TxnLine.RecType = MOIInfoType) or (TxnLine.RecType = MOPInfoType) 
                                      or (TxnLine.RecType = MFIssueType) or (TxnLine.RecType = MFPaidType) then
                                 begin
                                    ContainsMoneyOrderMessage:=True;
                                 end;
                              end;
                           except
//                              on E:Exception do
//                                 ShowMessage(TxnLine.RecType+' '+TxnLine.RecIndex+' '+TxnLine.PLU+' '+E.Message)
                           end;
                        end;
                        MessageAccess.Free;
                     end;
                  end;
                  if ContainsPensionMessage then
                  begin
                     Flags:=Flags or PensionMsg;
                     FileTxStatus.FileBlockMgr.SetMessageFlags(Off,WS,MsgIndex,Flags);
                  end;
                  if ContainsMoneyOrderMessage then
                  begin
                     Flags:=Flags or MoneyOrderMsg;
                     FileTxStatus.FileBlockMgr.SetMessageFlags(Off,WS,MsgIndex,Flags);
                  end;
                  if ((WSIdx mod 1000) = 0) then Application.ProcessMessages;
                  if Application.Terminated then Break;
               end;
               if Application.Terminated then Break;
            end;
            TxnLines.Free;
            TxnLine.Free;
         end;
         Status.Free;
      except
         on E:Exception do
            RaiseGUIDException('{56B97980-FB07-4205-8800-A895DF87FF38}',E);
      end;
   finally
      RunningThisFunc:=False
   end;
   LogProgress(2,'TTxnTransfer.FindUnProcessedMessages end');
end;
class procedure TTxnTransfer.PutInMoneyOrderMessages(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus);
var
  MsgIndex:Integer;
  WSIdx:Integer;
  Off,WS:Integer;
  Status:TStatusBits;
  Flags:Integer;
  TxnLines:TTxnLogLines;
  MessageAccess:TMessageAccess;
begin
   LogProgress(2,'TTxnTransfer.PutInMoneyOrderMessages start');
   TxnLines:=TTxnLogLines.Create;
   Status:=TStatusBits.Create;
   Status.State:=FileTxStatus.FFileBlockMgr.GetStatus;
   for WSIdx:=0 to Status.Count-1 do
   begin
      WS:=Status.WSNumber(WSIdx);
      Off:=Status.OfficeCode(WSIdx);
      for MsgIndex:=0 to Status.Size(Off,WS) do
      begin
         Flags:=FileTxStatus.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
         if ((Flags and (MessageHasGoodCRC or TransactionMsg or MoneyOrderMsg)) = (MessageHasGoodCRC or TransactionMsg or MoneyOrderMsg)) then
         begin
            MessageAccess:=FileTxStatus.FileBlockMgr.GetMessage(Off,WS,MsgIndex);
            if MessageAccess <> nil then
            begin
               AddMOTransferMessages(FileTxStatus,MessageAccess.MessageData);
               MessageAccess.Free;
            end;
         end;
         if ((WSIdx mod 1000) = 0) then Application.ProcessMessages;
         if Application.Terminated then Break;
      end;
      if Application.Terminated then Break;
   end;
   TxnLines.Free;
   Status.Free;
   LogProgress(2,'TTxnTransfer.PutInMoneyOrderMessages end');
end;
class function TTxnTransfer.MarkAllMessages(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus):Boolean;
var
  MsgIndex:Integer;
  WSIdx:Integer;
  Off,WS:Integer;
  Status:TStatusBits;
  Flags:Integer;
  ContainsPensionMessage:Boolean;
  ContainsMoneyOrderMessage:Boolean;
  TxnLine:TTxnLogLine;      
  TxnLineIdx:Integer;
  TxnLines:TTxnLogLines;
  MessageAccess:TMessageAccess;
const       
  RunningThisFunc:Boolean=False;
begin
   Result:=True;
   if RunningThisFunc then Exit;
   Result:=False;
   RunningThisFunc:=True;
   try
      TxnLines:=TTxnLogLines.Create;
      TxnLine:=TTxnLogLine.Create;
      Status:=TStatusBits.Create;
      Status.State:=FileTxStatus.FFileBlockMgr.GetStatus;
      for WSIdx:=0 to Status.Count-1 do
      begin
         WS:=Status.WSNumber(WSIdx);
         Off:=Status.OfficeCode(WSIdx);
         for MsgIndex:=0 to Status.Size(Off,WS) do
         begin
            Flags:=FileTxStatus.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
            ContainsPensionMessage:=False;
            ContainsMoneyOrderMessage:=False;
            if ((Flags and (MessageHasGoodCRC or TransactionMsg)) = (MessageHasGoodCRC or TransactionMsg)) then
            begin
               MessageAccess:=FileTxStatus.FileBlockMgr.GetMessage(Off,WS,MsgIndex);
               if MessageAccess <> nil then
               begin
                  TxnLines.PackText:=MessageAccess.MessageData;
                  for TxnLineIdx:=0 to TxnLines.Count-1 do
                  begin
                     TxnLine.PackText:=TxnLines[TxnLineIdx];
                     try
                     if  (TxnLine.RecIndex = 0) and (TxnLine.RecType = 'TxnLine')
                     and ((TxnLine.PLU = NormalPensionPLU) or (TxnLine.PLU = ArrearsPensionPLU)) then
                     begin
                        ContainsPensionMessage:=True;
                     end
                     else if (TxnLine.RecType = MOIssueType) or (TxnLine.RecType = MOPaidType)
                          or (TxnLine.RecType = MOIInfoType) or (TxnLine.RecType = MOPInfoType) 
                          or (TxnLine.RecType = MFIssueType) or (TxnLine.RecType = MFPaidType) then
                     begin
                        ContainsMoneyOrderMessage:=True;
                     end;
                     except 
//                        ShowMessage('Office '+IntToStr(Off)+'WS '+IntToStr(WS));
                     end;
                  end;
                  MessageAccess.Free;
               end;
            end;
            if ContainsPensionMessage then
            begin
               Flags:=Flags or PensionMsg;
               FileTxStatus.FileBlockMgr.SetMessageFlags(Off,WS,MsgIndex,Flags);
            end;
            if ContainsMoneyOrderMessage then
            begin
               Flags:=Flags or MoneyOrderMsg;
               FileTxStatus.FileBlockMgr.SetMessageFlags(Off,WS,MsgIndex,Flags);
            end;
            if ((WSIdx mod 1000) = 0) then Application.ProcessMessages;
            if Application.Terminated then Break;
         end;
         if Application.Terminated then Break;
      end;
      TxnLines.Free;
      TxnLine.Free;
      Status.Free;
   finally
      RunningThisFunc:=False
   end;
   LogProgress(2,'TTxnTransfer.FindUnProcessedMessages end');
end;
class function TTxnTransfer.GetCurrentMinPeriod(TxnLines:TTxnLogLines;FileTxStatus:TFileTxStatus):Integer;
var
   PeriodList:TPackStringList;
   TxnLinesOwned:Boolean;
   P:String;
   I:Integer;
   KeepPeriod:Integer;
begin
   LogProgress(2,'TTxnTransfer.GetCurrentMinPeriod start');
   Result:=0;
   KeepPeriod:=StrToIntDef(GetGPCSRegString('','Transaction Periods To Keep','0'),0);
   if (KeepPeriod > 0) then
   begin
      PeriodList:=TPackStringList.Create;
      if TxnLines = nil then // get the data if not passed
      begin
         TxnLines:=GetLimitedTransactionLines(nil,FileTxStatus,KeepPeriod);
         TxnLinesOwned:=True;  // should free it later
      end
      else
         TxnLinesOwned:=False; // shouldn't free it later
      
      for I:=0 to TxnLines.Count-1 do
      begin
         P:=TxnLines.Element[I].Period;
         if PeriodList.IndexOf(P) = -1 then // add to list
            PeriodList.Add(P);
      end;
      if PeriodList.Count > KeepPeriod then
         Result:=StrToIntDef(PeriodList[PeriodList.Count-KeepPeriod],0);
      PeriodList.Free;
      if TxnLinesOwned then // free it?
         TxnLines.Free;
   end;
   LogProgress(2,'TTxnTransfer.GetCurrentMinPeriod end '+IntToStr(Result));
end;           

class function TTxnTransfer.GetAvailablePeriods(TxnLines:TTxnLogLines;ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus):String;
var
   PeriodList:TPackStringList;
   TxnLinesOwned:Boolean;
   P:String;
   I:Integer;
begin
   LogProgress(2,'TTxnTransfer.GetAvailablePeriods start');
   PeriodList:=TPackStringList.Create;
   if TxnLines = nil then // get the data if not passed
   begin
      TxnLines:=GetTransactionLines(ProgressCallBack,FileTxStatus);
      TxnLinesOwned:=True;  // should free it later
   end
   else
      TxnLinesOwned:=False; // shouldn't free it later
      
   for I:=0 to TxnLines.Count-1 do
   begin
      if Assigned(ProgressCallBack) then
         ProgressCallBack(2,3,TxnLines.Count,I); // "Finding Valid Periods..."
      P:=TxnLines.Element[I].Period;
      if PeriodList.IndexOf(P) = -1 then // add to list
         PeriodList.Add(P);
   end;
   Result:=PeriodList.PackText;
   PeriodList.Free;
   if TxnLinesOwned then // free it?
      TxnLines.Free;
   LogProgress(2,'TTxnTransfer.GetAvailablePeriods end '+Result);
end;           
class function TTxnTransfer.CreateTxnlog(Database:TDatabase;TableName:String):TTable;
begin
   LogProgress(2,'TTxnTransfer.CreateTxnlog start '+TableName);
   if TableName = '' then // blank table name - use default
      TableName:='TxnLog';
      
   Result:=CreateTxnLogCalled(Database,'PSL','PSL',TableName);
   
   if Result = nil then Exit;
   
   // set index name for SQL Server and Oracle
   if GetGPCSRegString('WorkStation','DBType','Paradox') <> 'Paradox' then
      Result.IndexName:=UpperCase(TableName)+'_PINDEX';
      
   // prepend the 'dbo.' for SQL/BDE index problem
   // dbo is the database owner
   if GetGPCSRegString('WorkStation','DBType','Paradox') = 'SQLServer' then
      Result.TableName:=DatabaseOwner+'.'+UpperCase(TableName);
   LogProgress(2,'TTxnTransfer.CreateTxnlog end ');
end;
class procedure TTxnTransfer.BuildTxnlog(FromPeriod,ToPeriod:Integer;TxnLines:TTxnLogLines;TableName:String;ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus);
var
  TxnLineIdx:Integer;
  TxnLine:TTxnLogLine;
  TxnLinesOwned:Boolean;
  Table:TTable;
  Database:TDatabase;
begin
   LogProgress(2,'TTxnTransfer.BuildTxnlog start '+IntToStr(FromPeriod)+' '+IntToStr(ToPeriod)+' '+TableName);
   GetTxnlogDB(Database,Table,'PSL','RBDatabase');
   Table.Free;
   Table:=CreateTxnlog(Database,TableName);
   if Table <> nil then
   begin
      // if we havent already read the data from the file...
      if TxnLines = nil then
      begin
         TxnLines:=GetTransactionLines(ProgressCallBack,FileTxStatus);
         TxnLinesOwned:=True; // we should free at end
      end
      else
         TxnLinesOwned:=False; // we shouldn't free at end
      
      TxnLine:=TTxnLogLine.Create;
      TxnLineIdx:=0;
      while TxnLines.Count > 0 do
      begin
         TxnLine.PackText:=TxnLines[0];
         TxnLines.Delete(0);
      
         // if transaction in range
         if (TxnLine.Period >= FromPeriod) and (TxnLine.Period <= ToPeriod) then
            WriteTxnToTable(TxnLine,Table,0);
         
         // update status bar every 100 txns
         if ((TxnLineIdx mod 100) = 0) and (Assigned(ProgressCallBack)) then 
            ProgressCallBack(3,3,TxnLines.Count,TxnLineIdx);  // "Writing Data to Txnlog..."
         Inc(TxnLineIdx);
      end;
      ProgressCallBack(3,3,TxnLines.Count,TxnLines.Count-1);  // "Writing Data to Txnlog..."
      Table.Active:=False;  
   
      Table.Free;
      TxnLine.Free;
      if TxnLinesOwned then TxnLines.Free; // we created them ...
   end;
   Database.Free;
   LogProgress(2,'TTxnTransfer.BuildTxnlog end');
end;
   
class procedure TTxnTransfer.RebuildTxnLog(ProgressCallBack:TProgressCallBack;FileTxStatus:TFileTxStatus);
var
   KeepPeriod:Integer;
   Table:TTable;
  Database:TDatabase;
begin                
   LogProgress(2,'TTxnTransfer.RebuildTxnLog start');
   Database:=TDatabase.Create(nil);
   Table:=CreateTxnlog(Database,'');
   if Table = nil then 
   begin
      if Database <> nil then Database.Free;
      Exit;
   end;
   
   KeepPeriod:=StrToIntDef(GetGPCSRegString('','Transaction Periods To Keep','0'),0);
   WriteLimitedTransactionLines(ProgressCallBack,FileTxStatus,KeepPeriod,Table);
   Table.Free;
   if Assigned(ProgressCallBack) then
      ProgressCallBack(1,3,2,1);
      
   if Database <> nil then Database.Free;
   LogProgress(2,'TTxnTransfer.RebuildTxnLog end');
end;
{TFileStatusMon}
constructor TFileStatusMon.Create(AOwner: TComponent); 
begin
   LogProgress(2,'TFileStatusMon.Create start');
   FSkipRest:=True;                        
   inherited Create(AOwner);
   RunningAsService:=False;
   NextProcess:=0;
   NextFind:=0;
   NextMonitor:=0;
   FCurrentStatus:=0;
   ServiceIsBusy:=False;
   FDontAutoProcess:=True;
   DisableAutoProcess:=True;
   FCurrentMinPeriod:=-1;

   InternalProcessLoop:=nil;
   FDTSocket:=nil;
   FRemDTSocket:=nil;
   FStatusMonitor:=nil;
   
   FThisOfficeID:=StrToIntDef(GetGPCSRegString('OfficeInfo','Office ID','3201'),3201);
   FWorkstation:=StrToIntDef(GetGPCSRegString('WorkStation','Ident','10'),10);
   
   FileBlockMgr:=TAllMsgFiles.Create(MessageDir,FThisOfficeID,True);
   
   //Active:=False;
   LogProgress(2,'TFileStatusMon.Create end');
end;                            
{TFileStatusMonW}
constructor TFileStatusMonW.Create(AOwner: TComponent); 
begin
   LogProgress(2,'TFileStatusMonW.Create start');
   FSkipRest:=True;
   inherited Create(AOwner);
   RunningAsService:=False;
   NextProcess:=0;
   NextFind:=0;
   NextMonitor:=0;
   FCurrentStatus:=0;
   ServiceIsBusy:=False;
   FDontAutoProcess:=True;
   DisableAutoProcess:=True;
   FCurrentMinPeriod:=-1;

   InternalProcessLoop:=nil;
   FDTSocket:=nil;
   FRemDTSocket:=nil;
   FStatusMonitor:=nil;
   
   FThisOfficeID:=StrToIntDef(GetGPCSRegString('OfficeInfo','Office ID','3201'),3201);
   FWorkstation:=StrToIntDef(GetGPCSRegString('WorkStation','Ident','10'),10);
   
   FileBlockMgr:=TAllMsgFiles.Create(MessageDir,FThisOfficeID,False);
   
   //Active:=False;
   LogProgress(2,'TFileStatusMonW.Create end');
end;                   
{TFileTxStatus}
constructor TFileTxStatus.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   FUnProcessedList:=TStringList.Create;
   FTransmitList:=TStringList.Create;
   if FSkipRest then Exit; // set by inherited classes
   LogProgress(2,'TFileTxStatus.Create start --------------------------------'+ParamStr(0)+'---------------------------------------');
{$ifdef BuildingDLL}
   RunningAsService:=True;
{$else}
   RunningAsService:=False;
{$endif}
   NextProcess:=0;
   NextFind:=0;
   NextMonitor:=0;
   FCurrentStatus:=0;
   ServiceIsBusy:=False;
   FDontAutoProcess:=False;
   DisableAutoProcess:=False;
   FCurrentMinPeriod:=-1;
   FTransmitList:=TPackStringList.Create;

   if RunningAsService then
   begin
      FSignalLoop:=TSignalLoop.Create(Self);
      FExecLoop:=TExecLoop.Create(Self);
      if ContactSubOffices <> 0 then
         FDataCommLoop:=TDataCommLoop.Create(Self);
   end;
   InternalProcessLoop:=TInternalProcessLoop.Create(Self);

   FDTSocket:=TDTSocket.Create(DataTransferSocketPort);
   FDTSocket.OnRxData:=ProcessCommand;
   FDTSocket.OnDataSend       :=DataSend       ;
   FDTSocket.OnDataSent       :=DataSent       ;
   FDTSocket.OnDataReceived   :=DataReceived   ;
   FDTSocket.OnDataConnectTime:=DataConnectTime;

   FRemDTSocket:=TDTSocket.Create(RemoteTransferSocketPort);
   FRemDTSocket.OnRxData:=ProcessCommand;
   FRemDTSocket.OnDataSend       :=DataSend       ;
   FRemDTSocket.OnDataSent       :=DataSent       ;
   FRemDTSocket.OnDataReceived   :=DataReceived   ;
   FRemDTSocket.OnDataConnectTime:=DataConnectTime;
   
   FThisOfficeID:=StrToIntDef(GetGPCSRegString('OfficeInfo','Office ID','3201'),3201);
   FileBlockMgr:=TAllMsgFiles.Create(MessageDir,FThisOfficeID,False);
   FWorkstation:=StrToIntDef(GetGPCSRegString('WorkStation','Ident','10'),10);
   FStatusMonitor:=TStatusMonitor.Create;
   FStatusMonitor.SetStatus(FFileBlockMgr.GetStatus);
   FStatusMonitor.ThisWorkstation:=Workstation;
   FStatusMonitor.OnSendStatus:=SendStat;
   FStatusMonitor.OnRecvStatus:=RecvStat;
   FStatusMonitor.OnDataRx :=DataRxEvent   ;
   FStatusMonitor.OnDataTx :=DataTxEvent   ;
   FStatusMonitor.OnError  :=DataErrorEvent;
   FStatusMonitor.OnSend   :=SendEvent     ;
   FStatusMonitor.OnReceive:=ReceiveEvent  ;
   FStatusMonitor.OnSendData:=DTSocket.SendCommand;
   FStatusMonitor.OnChange:=Changed;
   FStatusMonitor.OnReqReplace:=RequestReplace;
   FStatusMonitor.OnPowerOff:=PowerOffMachine;
   FStatusMonitor.OnRestart :=RestartMachine ;
   FStatusMonitor.OnLogOff :=LogOffMachine ;
   FStatusMonitor.OnShutdown:=ShutdownMachine;
   ThisVersion:=GetVersion;
   FStatusMonitor.ThisVersion:=ThisVersion;
   
   if (csDesigning in ComponentState) then
      Active:=False
   else
      Active:=True;
   GetOfficeRouteInfo;
   Left:=0;
   Top:=0;
   Width:=400;
   Height:=200;
   ContactSchedule:=GetContactSchedule;
   Changed(Self);
   LogProgress(2,'TFileTxStatus.Create end');
end;              
destructor TFileTxStatus.Destroy;
begin
   LogProgress(2,ClassName+'.Destroy start');
   try
      if Active then Active:=False;            
   except on E:Exception do RaiseGUIDException('8EA1CEFC-ADCD-4B1E-909D-2DB8C6F925CE',E); end;
   
   try
      if FTransmitList <> nil then
      begin
         FTransmitList.Free;
         FTransmitList:=nil;
      end;
   except on E:Exception do RaiseGUIDException('D4313F00-F481-47F3-8CCA-135BF0B3EDB3',E); end;
   try    
      if FUnProcessedList <> nil then
      begin
         FUnProcessedList.Free;
         FUnProcessedList:=nil;
      end;
   except on E:Exception do RaiseGUIDException('4D4EA8ED-D16F-4230-A2C3-6B4FD9693CEF',E); end;
   
   try
      if FOfficeReference <> nil then
      begin
         FOfficeReference.Free;
         FOfficeReference:=nil;
      end;
   except on E:Exception do RaiseGUIDException('DA573228-19A5-4F60-B5CA-3BCBB676C4E2',E); end;
   
   try
      if FOfficeRouteInfo <> nil then
      begin
         FOfficeRouteInfo.Free;
         FOfficeRouteInfo:=nil;
      end;
   except on E:Exception do RaiseGUIDException('160A4963-0DBC-45DC-A9B5-D06DD6B7CDC0',E); end;
   
   try
      if FSignalLoop <> nil then
      begin
         while FSignalLoop.Suspended do
            FSignalLoop.Resume;
         FSignalLoop.Terminate;
      end;
   except on E:Exception do RaiseGUIDException('11CCA8F3-F72B-47F8-8A4A-6797FB8B1194',E); end;
   
   try
      if FExecLoop <> nil then
      begin
         while FExecLoop.Suspended do
            FExecLoop.Resume;
         FExecLoop.Terminate;
      end;
   except on E:Exception do RaiseGUIDException('B300243A-545C-4B7E-A04A-7E3135274B5A',E); end;
   
   try
      if FDataCommLoop <> nil then
      begin
         while FDataCommLoop.Suspended do
            FDataCommLoop.Resume;
         FDataCommLoop.Terminate;
      end;
   except on E:Exception do RaiseGUIDException('55172F18-B4A2-41E7-8FF6-C803D5D6C3BA',E); end;
   
   try
      if InternalProcessLoop <> nil then
      begin
         while InternalProcessLoop.Suspended do
            InternalProcessLoop.Resume;
         InternalProcessLoop.Terminate;
      end;
   except on E:Exception do RaiseGUIDException('0E23B9F0-64E8-4836-B6FC-799E46C0FD71',E); end;
   
   try
      if FStatusMonitor <> nil then 
         FStatusMonitor.Free;
   except on E:Exception do RaiseGUIDException('38A26A16-7118-4E81-9ED6-60EABB72167B',E); end;
   
   try
      if FFileBlockMgr  <> nil then 
         FFileBlockMgr .Free;
   except on E:Exception do RaiseGUIDException('7D6F4A92-798C-401A-82E8-0143272E9FF5',E); end;
   

   try
      if FDTSocket      <> nil then 
         FDTSocket     .Free;
   except on E:Exception do RaiseGUIDException('E80D8CF0-5CF2-4F9B-B106-2237BA61EC5F',E); end;
   
   try
      if FRemDTSocket   <> nil then 
         FRemDTSocket  .Free;
   except on E:Exception do RaiseGUIDException('85C131A6-5B2B-4C9F-88EE-51257C8E446B',E); end;
   
   try
      if FTransmitList  <> nil then 
         FTransmitList .Free;
   except on E:Exception do RaiseGUIDException('CBCE28D4-134C-4C7F-85B0-5635D07915CE',E); end;
   
   TTxnTransfer.SendReplaceSelfTo('CleanUp',Self,True);
   
   LogProgress(2,ClassName+'.Destroy end');

   inherited Destroy;
end;
procedure TFileTxStatus.UpdateUI;
begin
   LogProgress(2,'TFileTxStatus.UpdateUI start');
   if Assigned(FOnUpdateUI) then FOnUpdateUI;
   LogProgress(2,'TFileTxStatus.UpdateUI end');
end;                            
procedure TFileTxStatus.SendStat(Size:Integer;Stat:Boolean);
begin
   if Assigned(FOnSendStatus) then FOnSendStatus(Size,Stat);
end;                            
procedure TFileTxStatus.RecvStat(Size:Integer;From:String;Stat:Boolean);
begin
   if Assigned(FOnRecvStatus) then FOnRecvStatus(Size,From,Stat);
end;                            
procedure TFileTxStatus.DataSend(Host:String;Size:Integer);
begin
   if Assigned(FOnDataSend) then            
      FOnDataSend(Host,Size);
end;
procedure TFileTxStatus.DataSent(Host:String;Size:Integer;Stat:Boolean;Time:TTime);
begin
   if Assigned(FOnDataSent) then 
      FOnDataSent(Host,Size,Stat,Time);
end;
procedure TFileTxStatus.DataReceived(Host:String;Size:Integer;Stat:Boolean;Time:TTime);
begin
   if Assigned(FOnDataReceived) then 
      FOnDataReceived(Host,Size,Stat,Time);
end;
procedure TFileTxStatus.DataConnectTime(Host:String;Time:TTime);
begin
   if Assigned(FOnDataConnectTime) then 
      FOnDataConnectTime(Host,Time);
end;
function TFileTxStatus.SendCommand(Host:String;TimeOut:Integer;CommandType:TCommandType;DataStream:TStringStream;HangUpAfter:Boolean):String;
begin
   LogProgress(2,'TFileTxStatus.SendCommand start '+Host+' '+IntToStr(Integer(CommandType)));
   Result:=DTSocket.SendCommand(Host,TimeOut,CommandType,DataStream,HangUpAfter);
   LogProgress(2,'TFileTxStatus.SendCommand end');
end;                                              
function TFileTxStatus.SendRemoteCommand(Host:String;TimeOut:Integer;CommandType:TCommandType;DataStream:TStringStream;HangUpAfter:Boolean):String;
begin
   LogProgress(2,'TFileTxStatus.SendRemoteCommand start '+Host+' '+IntToStr(Integer(CommandType)));
   Result:='';                                  
   if ContactSubOffices <> 0 then
      Result:=RemDTSocket.SendCommand(Host,TimeOut,CommandType,DataStream,HangUpAfter);
   LogProgress(2,'TFileTxStatus.SendRemoteCommand end');
end;                                
procedure TFileTxStatus.RequestReplace(From:String);
begin
   LogProgress(2,'TFileTxStatus.RequestReplace start '+From);
   TTxnTransfer.SendReplaceSelfTo(HexIPToIP(From),Self,True);
   LogProgress(2,'TFileTxStatus.RequestReplace end');
end;
procedure TFileTxStatus.FillOfficeReference;
var
  I:Integer;
  Offices:TCorvusNode;
  OfficeItemNode:TCorvusNode;
  OffCodeRef:TOffCodeRef;
begin
   LogProgress(2,'TFileTxStatus.FillOfficeReference start');
   if FOfficeRouteInfo = nil then
   begin
      FOfficeRouteInfo:=TParseNode.Create('OfficeRouteInfo',OfficeRoutesInfo,0);
      FOfficeRouteInfo.ParseFile(ExtractFilePath(OfficeRoutesInfo),ExtractFileName(OfficeRoutesInfo),0);
   end;
   if FOfficeReference = nil then
   begin
      FOfficeReference:=TPackStringList.Create;
      OffCodeRef:=TOffCodeRef.Create;
      Offices:=FOfficeRouteInfo.NodeNamed('OfficesRoutes');
      if Offices <> nil then
      begin
         Offices:=Offices.NodeNamed('Offices');
         if Offices <> nil then
         begin
            for I:=0 to Offices.Count-1 do
            begin
               OffCodeRef.Text:='';
               OffCodeRef.OfficeName:=Offices[I];
               OfficeItemNode:=Offices.Node[I].NodeNamed('Code');
               if OfficeItemNode <> nil then OffCodeRef.OfficeCode:=OfficeItemNode[0];
               OfficeItemNode:=Offices.Node[I].NodeNamed('Title');
               if OfficeItemNode <> nil then OffCodeRef.OfficeTitle:=OfficeItemNode[0];
               OfficeItemNode:=Offices.Node[I].NodeNamed('SCode');    
               if OfficeItemNode <> nil then OffCodeRef.OfficeSCode:=OfficeItemNode[0];    
               OfficeItemNode:=Offices.Node[I].NodeNamed('I3Code');   
               if OfficeItemNode <> nil then OffCodeRef.OfficeI3Code:=OfficeItemNode[0];   
               OfficeItemNode:=Offices.Node[I].NodeNamed('PCode');    
               if OfficeItemNode <> nil then OffCodeRef.OfficePCode:=OfficeItemNode[0];    
               OfficeItemNode:=Offices.Node[I].NodeNamed('Address');  
               if OfficeItemNode <> nil then OffCodeRef.OfficeAddress:=OfficeItemNode[0];  
               OfficeItemNode:=Offices.Node[I].NodeNamed('Telephone');    
               if OfficeItemNode <> nil then OffCodeRef.OfficePhone:=OfficeItemNode[0];    
               OfficeItemNode:=Offices.Node[I].NodeNamed('POBox');    
               if OfficeItemNode <> nil then OffCodeRef.OfficePOBox:=OfficeItemNode[0];    
               OfficeItemNode:=Offices.Node[I].NodeNamed('AccessVia');
               if OfficeItemNode <> nil then OffCodeRef.OfficeAccessVia:=OfficeItemNode[0];
               OfficeItemNode:=Offices.Node[I].NodeNamed('Type');
               if OfficeItemNode <> nil then OffCodeRef.OfficeType:=OfficeItemNode[0];
               
               
               if Offices.Node[I].IndexOf('Automated') <> -1 then
                  OffCodeRef.OfficeAutomated:='True' 
               else 
                  OffCodeRef.OfficeAutomated:='False';
                  
               FOfficeReference.Add(OffCodeRef.PackText);
            end;
         end;
      end;
      OffCodeRef.Free;
   end;
   LogProgress(2,'TFileTxStatus.FillOfficeReference end');
end;

procedure TFileTxStatus.GetOfficeRouteInfo;
var
  I:Integer;
  OffCodeRef:TOffCodeRef;
begin
   LogProgress(2,'TFileTxStatus.GetOfficeRouteInfo start');
   if FOfficeReference = nil then
      FillOfficeReference;
  OffCodeRef:=TOffCodeRef.Create;
   for I:=0 to FOfficeReference.Count-1 do
   begin
      OffCodeRef.PackText:=FOfficeReference[I];
      if OffCodeRef.OfficeCode = FThisOfficeID then
      begin
         FThisOfficeInfo:=TOffCodeRef.Create;
         FThisOfficeInfo.PackText:=FOfficeReference[I];
         OfficeInfo:=FThisOfficeInfo.OfficeTitle;
      end;
   end;
   LogProgress(2,'TFileTxStatus.GetOfficeRouteInfo end');
end;
function TFileTxStatus.GetContactSchedule:String;
var
  OfficeRoutes:TCorvusNode;
  Offices:TCorvusNode;
  Routes:TCorvusNode;
  RouteNode:TCorvusNode;
  Schedules:TCorvusNode;
  MySchedule:TCorvusNode;
  TheOffice:TCorvusNode;
  SL:TPackStringList;
  ContactInfo:TContactInfo;
  I,J,K:Integer;
  NName:String;
  Found:Boolean;
begin
   LogProgress(2,'TFileTxStatus.GetContactSchedule start');
   SL:=TPackStringList.Create;
   ContactInfo:=TContactInfo.Create;
   OfficeRoutes:=FOfficeRouteInfo.NodeNamed('OfficesRoutes');
   if OfficeRoutes <> nil then
   begin
      Offices:=OfficeRoutes.NodeNamed('Offices');
      Routes:=OfficeRoutes.NodeNamed('Routes');
      Schedules:=OfficeRoutes.NodeNamed('Schedules');
      if (Schedules <> nil) and (Offices <> nil) and (Routes <> nil) then
      begin
         if FThisOfficeInfo <> nil then
         begin
            MySchedule:=Schedules.NodeNamed(FThisOfficeInfo.OfficeName);
            if MySchedule <> nil then
            begin
               for I:=0 to MySchedule.Count-1 do
               begin
                  if MySchedule.Node[I].Name = 'AllSubOffices' then
                  begin
                     RouteNode:=Routes.NodeNamed('Data');
                     if RouteNode <> nil then
                     begin
                        RouteNode:=RouteNode.AnySubNodeNamed(FThisOfficeInfo.OfficeName);
                        if RouteNode <> nil then
                        begin
                           for J:=0 to RouteNode.Count-1 do
                           begin
                              if RouteNode.Node[J] <> nil then
                                 NName:=RouteNode.Node[J].Name
                              else
                                 NName:=RouteNode[J];
                              if NName <> '' then
                              begin
                                 TheOffice:=Offices.NodeNamed(NName);
                                 if (TheOffice <> nil)
                                 and (TheOffice.IndexOf('Automated') <> -1)
                                 and (TheOffice.NodeNamed('AccessVia') <> nil)
                                 and (TheOffice.NodeNamed('Code') <> nil) then
                                 begin
                                    ContactInfo.OfficeName  :=NName;
                                    ContactInfo.TimeInterval:=StrToIntDef(MySchedule.Node[I][0],30);
                                    ContactInfo.OfficeCode  :=TheOffice.NodeNamed('Code')[0];
                                    ContactInfo.AccessVia   :=TheOffice.NodeNamed('AccessVia')[0];
                                    ContactInfo.LastContact :=Now-ContactInfo.TimeInterval*OneMinute;
                                    Found:=False;
                                    for K:=0 to SL.Count-1 do // only add if not overriden
                                    begin
                                       if Integer(SL.Objects[K]) = ContactInfo.OfficeCode then
                                       begin
                                          Found:=True;
                                          break;
                                       end;
                                    end;
                                    if not Found then
                                       SL.AddObject(ContactInfo.PackText,TObject(Integer(ContactInfo.OfficeCode)));
                                 end;
                              end; 
                           end;
                        end;
                     end;
                  end
                  else
                  begin
                     TheOffice:=Offices.NodeNamed(MySchedule.Node[I].Name);
                     if (TheOffice <> nil)
                     and (TheOffice.IndexOf('Automated') <> -1)
                     and (TheOffice.NodeNamed('AccessVia') <> nil)
                     and (TheOffice.NodeNamed('Code') <> nil) then
                     begin             
                        ContactInfo.OfficeName  :=MySchedule.Node[I].Name;
                        ContactInfo.TimeInterval:=StrToIntDef(MySchedule.Node[I][0],30);
                        ContactInfo.OfficeCode  :=TheOffice.NodeNamed('Code')[0];
                        ContactInfo.AccessVia   :=TheOffice.NodeNamed('AccessVia')[0];
                        ContactInfo.LastContact :=Now-ContactInfo.TimeInterval*OneMinute;
                        // TODO override 'AllSubOffices' directive
                        SL.AddObject(ContactInfo.PackText,TObject(Integer(ContactInfo.OfficeCode)));
                     end;
                  end; 
               end;
            end;
         end;
      end;
   end;
   Result:=SL.PackText;
   ContactInfo.Free;
   SL.Free;
   LogProgress(2,'TFileTxStatus.GetContactSchedule end '+Result);
end;
function TFileTxStatus.ContactAllSubs(OfficeToProcess:Integer):Integer;
var
  SL:TPackStringList;
  StartedWith:Integer;
  ContactInfo:TContactInfo;
  ProcessingOffice:Integer;
begin
   LogProgress(2,'TFileTxStatus.ContactAllSubs start '+IntToStr(OfficeToProcess));
   Result:=OfficeToProcess;
   if ContactSchedule = '' then Exit;
   CoInitialize(nil);
   try
      SL:=TPackStringList.Create;
      ContactInfo:=TContactInfo.Create;
      SL.PackText:=ContactSchedule;
      if OfficeToProcess >= SL.Count then
         OfficeToProcess:=0;
      Result:=OfficeToProcess+1;
      StartedWith:=-1;

      while (OfficeToProcess <> Result) and (OfficeToProcess <> StartedWith) do
      begin
         if StartedWith = -1 then
            StartedWith:=OfficeToProcess;
         ProcessingOffice:=OfficeToProcess;
         ContactInfo.PackText:=SL[OfficeToProcess];
         Inc(OfficeToProcess);
         if OfficeToProcess >= SL.Count then
            OfficeToProcess:=0;
         Result:=OfficeToProcess;
         // due to call ?
         if ContactInfo.LastContact+(ContactInfo.TimeInterval*OneMinute) < Now then
         begin
            try
               if Assigned(FOnContactStatus) then
                  FOnContactStatus('Contacting :'+ContactInfo.OfficeName+' on '+ContactInfo.AccessVia);
               RequestDataFromOffice(ContactInfo.OfficeCode,ContactInfo.AccessVia,ContactTimeOut,ContactInfo.OfficeName);
               FStatusMonitor.SetStatus(FFileBlockMgr.GetStatus);
               if Assigned(FOnContactStatus) then
               begin
                  FOnContactStatus('Contact :'+ContactInfo.OfficeName+' on '+ContactInfo.AccessVia+' Complete');
                  FOnContactStatus('');
               end;
               // no errors so update LastContact
               ContactInfo.LastContact:=Now;
            except
               on E:Exception do
               begin
                  if Assigned(FOnContactError) then
                  begin
                     FOnContactError('Failed to Contact Office '+ContactInfo.OfficeName+' '+E.Message);
                     FOnContactStatus('');
                  end;
                  RaiseGUIDException('{A16242C9-5BD4-48A5-B19E-9FBAFBC279A1}',E);
                  RaiseGUIDError    ('{A16242C9-5BD4-48A5-B19E-9FBAFBC279A1}',
                                     'Failed to Contact Office '+ContactInfo.OfficeName+
                                     ' - see previous error for reason');
                  //Failed - try again in one minute
                  ContactInfo.LastContact:=(Now-(ContactInfo.TimeInterval*OneMinute))+OneMinute;
                  Inc(Result); // try to process the next office
               end;
            end;
            SL[ProcessingOffice]:=ContactInfo.PackText;
         end
         else // not due for contact
            Inc(Result); // try to process the next office
      end;
      ContactInfo.Free;
      ContactSchedule:=SL.PackText;
      SL.Free;
   except
   end;
   CoUnInitialize;
   LogProgress(2,'TFileTxStatus.ContactAllSubs end ');
end;
procedure TFileTxStatus.DataCommTick;
const
   NextContact:Integer=0;
   OfficeToProcess:Integer=0;
begin
   try
      if (ContactSubOffices <> 0) and (NextContact <= NowInSeconds) then
      begin
         NextContact:=NowInSeconds+ContactSubOffices;
         OfficeToProcess:=ContactAllSubs(OfficeToProcess);
      end;
   except
   end;
end;
procedure RegFile(FileName:String;UseRegserver:Boolean);
type
  TRegUnRegFunc = procedure;
var
   HModule:THandle;
   RegFunc:TRegUnRegFunc;
   op:String;
begin
  try
     if (FileName = '') then Exit;
     if UpperCase(Copy(FileName,Length(FileName)-2,3)) = 'EXE' then
     begin
        try
           WinExec(PChar(FileName+' /RegServer'),SW_SHOW);
        except
           RaiseGUIDError('{26167B7B-D3A5-489B-8843-1732FB6675EB}',FileName+' /RegServer - Failed');
        end;
     end
     else
     begin
        if UseRegserver then
        begin
           WinExecAndWaitEnv('Regsvr32 /s '+FileName,op,False,'PATH=%PATH%;'+ExtractFilePath(FileName)+#0#0#0#0);
        end
        else
        begin
           HModule:=LoadLibrary(PChar(FileName));
           if HModule <> 0 then
           begin
              try
                 if GetProcAddress(HModule,'DllRegisterServer') <> nil then
                 begin
                    @RegFunc:=GetProcAddress(HModule,'DllRegisterServer');
                    if @RegFunc <> nil then
                       RegFunc;
                 end
                 else
                 begin
                    RaiseGUIDError('{B8512F0C-F9DA-400B-86CC-D9F1AAB22C81}',FileName+' DllRegisterServer - Failed');
                 end;
              except
                 RaiseGUIDError('{F06B9613-C878-4BA2-A310-BE20AFC45952}',FileName+' DllRegisterServer - Failed');
              end;
              FreeLibrary(HModule);
           end
           else
           begin
              RaiseGUIDError('{24B0DB6B-BBEC-4C8B-B9D2-044CD951FE63}','LoadLibrary('+FileName+') - Failed');
           end;
        end;
     end;
    except
      On E : Exception do
        RaiseGUIDException('{1EF72885-F5D6-4BA4-A3CC-8DBD51D43711}',E);
    end;

end;
procedure UnRegFile(FileName:String;UseRegserver:Boolean);
type
  TRegUnRegFunc = procedure;
var
   HModule:THandle;
   UnRegFunc:TRegUnRegFunc;
   op:String;
begin
  try
     if (FileName = '') then Exit;
     if UpperCase(Copy(FileName,Length(FileName)-2,3)) = 'EXE' then
     begin
        try
           WinExec(PChar(FileName+' /UnRegServer'),SW_HIDE);
        except
           RaiseGUIDError('{C31D6402-E10F-4152-A7E8-F6DD7026B1F2}',FileName+' /UnRegServer - Failed');
        end;
     end
     else
     begin
        if UseRegserver then
        begin
           WinExecAndWaitEnv('Regsvr32 /s /u '+FileName,op,False,'PATH=%PATH%;'+ExtractFilePath(FileName)+#0#0#0#0);
        end
        else
        begin
           HModule:=LoadLibrary(PChar(FileName));
           if HModule <> 0 then
           begin
              try
                 if GetProcAddress(HModule,'DllUnregisterServer') <> nil then
                 begin
                    @UnRegFunc:=GetProcAddress(HModule,'DllUnregisterServer');
                    if @UnRegFunc <> nil then
                       UnRegFunc;
                 end;
              except
                 RaiseGUIDError('{1EB1A59B-FD95-4269-8EA0-B939A3A44030}',FileName+' DllUnregisterServer - Failed');
              end;
              FreeLibrary(HModule);
           end;
        end;
     end;
    except
      On E : Exception do
        RaiseGUIDException('{75C02F79-AE81-475F-8BE4-DF379D3D92F0}',E);
    end;

end;
procedure OverwriteFile(SourceFile,DestinationFile:String);
begin
   if FileExists(SourceFile)  then
   begin
      try
      if FileExists(DestinationFile) then
         UnRegFile(DestinationFile,False);
      CopyFile(PChar(SourceFile),PChar(DestinationFile),False);
      if FileExists(DestinationFile) then
         RegFile(DestinationFile,False);
      DeleteFile(PChar(SourceFile));
      except
         on E:Exception do 
            RaiseGUIDException('{E91BF8C2-0797-4A42-8DC0-0BE33D256D0A} Update ',E);
      end;
   end;
end;
procedure UpdateFile(UpdateFileName:String);
var
   UPDInfo:TParseNode;
   UpdateNode:TCorvusNode;
   Destination:TCorvusNode;
   Files:TCorvusNode;
   FileNode:TCorvusNode;
   I,J:Integer;
   Stock:TSiteStock;
   DList:TStringList;
begin
   UPDInfo:=TParseNode.Create('UPDInfo',UpdateFileName,0);
   UPDInfo.ParseFile(ExtractFilePath(UpdateFileName),ExtractFileName(UpdateFileName),0);
   UpdateNode:=UPDInfo.NodeNamed('Update');
   if UpdateNode <> nil then
   begin
      Destination:=UpdateNode.NodeNamed('DestinationPath');
      Files:=UpdateNode.NodeNamed('Files');
      if (Destination <> nil) and (Files <> nil) then
      begin
         for I:=0 to Files.Count-1 do
         begin
            FileNode:=Files.Node[I];
            if Files[I] = 'UpdateStock' then
            begin
              if (FileNode <> nil) and (FileNode.Count > 0) then
              begin
                 Stock:=TSiteStock.Create;
                 try
                    UpdateFromCSV(ExtractFilePath(UpdateFileName)+FileNode[0],Stock);
                    DeleteFile(PChar(ExtractFilePath(UpdateFileName)+FileNode[0]));
                    Stock.Free;
                 except
                    on E:Exception do
                       RaiseGUIDException('{E185EA39-9784-4D7A-BB0D-63374296F3CA}',E);
                 end;
              end;
            end
            else
            begin
              if (FileNode = nil) or (FileNode.Count = 0) then
              begin
                 OverwriteFile(ExtractFilePath(UpdateFileName)+Files[I]+'.dll',
                               Destination[0]+'\'+Files[I]+'.dll')
              end
              else if FileNode.Count = 1 then
              begin
                 DList:=TStringList.Create;
                 FillFileList(ExtractFilePath(UpdateFileName),FileNode[0],False,DList);
                 for J:=0 to DList.Count-1 do
                    OverwriteFile(DList[J],Destination[0]+'\'+ExtractFileName(DList[J]));
                 DList.Free;
              end             
              else 
              begin
                 OverwriteFile(ExtractFilePath(UpdateFileName)+FileNode[0],
                               Destination[0]+'\'+FileNode[1]);
              end;
            end;                        
         end;
      end;
   end;
   UPDInfo.Free;
end;
procedure TFileTxStatus.CheckUpdateFiles;
var
   Path:String;
   FileList:TStringList;
   FileDate,CurrentDate:Integer;
   I:Integer;
begin
   Path:=GetPSLRegString('Update','Source Path','');
   if Path = '' then Exit;
   FileList:=TStringList.Create;
   FillFileList(Path,'*.upd',True,FileList);
   CurrentDate:=DateTimeToFileDate(Now);
   for I:=0 to FileList.Count-1 do
   begin
      FileDate:=Integer(FileList.Objects[I]); 
      if CurrentDate >= FileDate then // upto or passed process date
         UpdateFile(FileList[I]);
   end;
   FileList.Free;
end;

procedure TFileTxStatus.TimerTick;
var
//   TxnLog:TQuery;
   FileList:TStringList;
   TS:Integer;
const
   InThisFunctionAlready:Boolean=False;
   LimitToSeconds:Integer = 0;
   FirstRun:Boolean = True;
begin
   try
      FStatusMonitor.TimerTick;
      TS:=(DateTimeToTimeStamp(Now).Time div 1000) * 1000; // time in ms to the nearest second
      if LimitToSeconds < TS  then
      begin
         LimitToSeconds:=TS+1000;
         if NextProcess = 0 then NextProcess:=NowInSeconds+ProcessTxnTimeInterval;
         if NextMonitor = 0 then NextMonitor:=NowInSeconds+TxnlogMonitorTimeOut;
         if NextFind    = 0 then NextFind   :=NowInSeconds+FindTxnTimeInterval;
                       
         if FStatusMonitor = nil then Exit;
         if ServiceIsBusy then Exit;

         if (FirstRun or (TodayAsPeriod <> StrToIntDef(GetPSLRegString('Message Transfer','Last Rebuild','0'),0) ))
         and RunningAsService then
         begin
            FirstRun:=False;
            StartUpProcessing:=True;
            ServiceIsBusy:=True;
            try
               LogProgress(1,'Rebuild Txnlog');
               FStatusMonitor.Active:=False;
               FDTSocket.Active:=False;
               FRemDTSocket.Active:=False;
               
               try
                  with TFileStream.Create('C:\ServiceIsBusy.lck',fmCreate or fmShareExclusive) do
                     Free;
               except
                  // already exists
               end;   
               
               CheckUpdateFiles;
               
               if (TodayAsPeriod <> StrToIntDef(GetPSLRegString('Message Transfer','Last Rebuild','0'),0) ) then
               begin
                  FCurrentStatus:=FCurrentStatus or 4; // set building flag
                  if CanRebuildTxnlog then
                     TTxnTransfer.RebuildTxnLog(nil,Self);
                  FCurrentStatus:=FCurrentStatus and $FB; // clear building flag
                  SetPSLRegString('Message Transfer','Last Rebuild',IntToStr(TodayAsPeriod));
                  FileList:=TStringList.Create;
                  FillFileList(TransactionFilesDir,'*.4TH',False,FileList);
                  while FileList.Count > 0 do
                  begin
                     DeleteFile(PChar(FileList[0]));
                     FileList.Delete(0);
                  end;
                  FileList.Free;
               end;
               
               FCurrentStatus:=FCurrentStatus or 8; // set finding flag
               TTxnTransfer.FindUnProcessedMessages(nil,Self);
               TTxnTransfer.FindPensionMessages(Self);
               TTxnTransfer.FindMOMessages(Self);
               NextFind:=NowInSeconds+FindTxnTimeInterval;
               FCurrentStatus:=FCurrentStatus and $F7; // clear finding flag
               
               FCurrentStatus:=FCurrentStatus or 16; // set processing flag
               try
                  TS:=10;
                  while (TS > 0) and (not TTxnTransfer.ProcessUnProcessedMessages(nil,Self)) do
                  begin
                     Dec(TS);
                     Application.ProcessMessages;
                  end;
               except
                  on E:Exception do
                     RaiseGUIDException('{E0824ED8-906C-4BE5-A2BA-A6FFEA470A8A}',E);
               end;
               try
                  TS:=10;
                  while (TS > 0) and (not TTxnTransfer.ProcessUnProcessedPensions(nil,Self)) do
                  begin
                     Dec(TS);
                     Application.ProcessMessages;
                  end;
               except
                  on E:Exception do
                     RaiseGUIDException('{EE03C766-01D4-4AF3-8CDD-5FFB06F45D07}',E);
               end;
               NextProcess:=NowInSeconds+ProcessTxnTimeInterval;
               FCurrentStatus:=FCurrentStatus and $EF; // clear processing flag
               
            except
               on E:Exception do
               begin
                  RaiseGUIDException('{EDBB0A0A-9819-4532-BD87-12A90B0091D7}',E);
                  SetPSLRegString('Message Transfer','Last Rebuild',IntToStr(TodayAsPeriod));
                  StartUpProcessing:=False;
               end;
            end;
            
            FStatusMonitor.Active:=True;
            FDTSocket.Active:=True;
            FRemDTSocket.Active:=True;
            
            try
               if FileExists('C:\ServiceIsBusy.lck') then 
                  DeleteFile('C:\ServiceIsBusy.lck');
               LogProgress(1,'Rebuild Txnlog complete');
            except
               on E:Exception do
                  RaiseGUIDException('{461AAC5A-FE7D-484A-BD70-A0A0B77F0695}',E);
            end;
            ServiceIsBusy:=False;
            StartUpProcessing:=False;
            Exit;                            
         end;
         if (not StartUpProcessing) and (NextFind <= NowInSeconds) then
         begin
            NextFind:=NowInSeconds+FindTxnTimeInterval;
            if (not FDontAutoProcess) and (not DisableAutoProcess) then
            begin
               FCurrentStatus:=FCurrentStatus or 8; // set finding flag
               TTxnTransfer.FindUnProcessedMessages(nil,Self);
               FCurrentStatus:=FCurrentStatus and $F7; // clear finding flag
            end;
         end
         else if (not StartUpProcessing) and (NextProcess <= NowInSeconds) then
         begin
            NextProcess:=NowInSeconds+ProcessTxnTimeInterval;
            if (not FDontAutoProcess) and (not DisableAutoProcess) then
            begin
               FCurrentStatus:=FCurrentStatus or 16; // set processing flag
               try
                  TTxnTransfer.ProcessUnProcessedMessages(nil,Self);
                  TTxnTransfer.ProcessUnProcessedPensions(nil,Self);
               except
               end;
               FCurrentStatus:=FCurrentStatus and $EF; // clear processing flag
            end;
            if FileExists('C:\ServiceIsBusy.lck') then
               DeleteFile('C:\ServiceIsBusy.lck');
{         end                                        
         else if (not StartUpProcessing) and (NextMonitor <= NowInSeconds) then
         begin
            NextMonitor:=NowInSeconds+TxnlogMonitorTimeOut;
            if MonitorTxnlog then
            begin
               FCurrentStatus:=FCurrentStatus or 32; // set monitoring flag
               LogProgress(1,'Monitor Txnlog');
               TxnLog:=TQuery.Create(nil);
               TxnLog.DatabaseName:='PSL';
               TxnLog.SessionName:='Default';
               TxnLog.SQL.Text:='select * from Txnlog order by WSNumber,RecordID';
               TTxnTransfer.BuildStoreFromTxnLog(TxnLog,Self,nil);
               TxnLog.Free;
               LogProgress(1,'Monitor Txnlog complete');
               FCurrentStatus:=FCurrentStatus and $DF; // clear monitoring flag
            end; }                     
         end;                          
      end;
   except
   end;
end;
procedure TFileTxStatus.DataRxEvent(Sender:TStatusMonitor;DataReceived:String);
var
   SS:TStringStream;
   MessageAccess:TMessageAccess;
   BlockType:Byte;
   Workstation:Integer;
   Office:Integer;
   FileStream:TFileStream;
begin
   LogProgress(2,'TFileTxStatus.DataRxEvent start '+DataReceived);
   SS:=TStringStream.Create(DataReceived);
   SS.Read(BlockType,SizeOf(BlockType));
   if BlockType = 0 then // single block
   begin
      MessageAccess:=TMessageAccess.Create;
      MessageAccess.LoadFromStream(SS);
      SS.Free;
      if MessageAccess.GoodCRC then
      begin
         MessageAccess.Flags:=MessageAccess.Flags and (not MessageProcessed);
         SendServiceRMessage(MessageAccess,Self,ctSetDataLocal);
      end                                                 
      else
      begin
         RaiseGUIDError('{767467B7-FB69-44C2-9280-F94BDDDCF9D1}','Message Received Bad CRC O='+IntToStr(MessageAccess.Office)+' W='+IntToStr(MessageAccess.WorkStation)+' MI='+IntToStr(MessageAccess.Identifier));
      end;
      MessageAccess.Free;
   end
   else if BlockType = 1 then // whole File
   begin
      SS.Read(Workstation,SizeOf(Workstation));
      SS.Read(Office,SizeOf(Office));
      try
         ForceDirectories(TransactionFilesDir);
         FileStream:=TFileStream.Create(TransactionFilesDir+'\F'+ZeroPad(Office,5)+ZeroPad(Workstation,3)+'.1ST',fmCreate);
         FileStream.CopyFrom(SS,SS.Size-SS.Position);
         FileStream.Free;
         RenameFile(TransactionFilesDir+'\F'+ZeroPad(Office,5)+ZeroPad(Workstation,3)+'.1ST',TransactionFilesDir+'\F'+ZeroPad(Office,5)+ZeroPad(Workstation,3)+'.2ND');
      except
         on E:Exception do
            RaiseGUIDException('{66B23E3A-14A5-447B-AB72-AB0DECBF81D3}',E);
      end;    
      SS.Free;
   end;
   LogProgress(2,'TFileTxStatus.DataRxEvent end');
end;                                           
function TFileTxStatus.DataTxEvent(Sender:TStatusMonitor;OfficeID,Workstation,BlockNumber:Integer;Into:TStream):TStream;
var
   MessageAccess:TMessageAccess;
   BlockType:Byte;
begin
   LogProgress(2,'TFileTxStatus.DataTxEvent start '+IntToStr(OfficeID)+' '+IntToStr(Workstation)+' '+IntToStr(BlockNumber));
   if Into = nil then
      Into:=TMemoryStream.Create;
   Result:=Into;
   if BlockNumber = -1 then // request whole File
   begin
      BlockType:=1;
      Into.Write(BlockType,SizeOf(BlockType));
      Into.Write(Workstation,SizeOf(Workstation));
      Into.Write(OfficeID,SizeOf(OfficeID));
      FFileBlockMgr.WriteFileTo(OfficeID,Workstation,Into);
   end
   else
   begin
      BlockType:=0;
      MessageAccess:=FFileBlockMgr.GetRawMessage(OfficeID,Workstation,BlockNumber);
      if MessageAccess <> nil then
      begin
         Into.Write(BlockType,SizeOf(BlockType));
         MessageAccess.Flags:=MessageAccess.Flags and (not MessageProcessed);
         MessageAccess.SaveToStream(Into);
         MessageAccess.Free;
      end;
   end;
   LogProgress(2,'TFileTxStatus.DataTxEvent end ');
end;
procedure TFileTxStatus.DataErrorEvent(Sender:TStatusMonitor;ErrorMessage:String);
begin
   RaiseGUIDError('{7A9FE952-2EEB-4F1D-A9F7-54A2B4EEA43C}','Socket Error '+ErrorMessage);
   LogProgress(2,'TFileTxStatus.DataErrorEvent'+ErrorMessage);
end;
procedure TFileTxStatus.SendEvent(Sender:TStatusMonitor;Data:String);
begin
end;
procedure TFileTxStatus.ReceiveEvent(Sender:TStatusMonitor;Data:String);
begin
end;
procedure GetDllName(var CurrentDLL:String);
var
   DeleteDLLName:String;
begin
   LogProgress(2,'GetDllName start');
   try
      CurrentDLL:='';
      DeleteDLLName:='';
      with TRegistry.Create do
      begin
         RootKey:=HKEY_LOCAL_MACHINE;
         if OpenKey('SOFTWARE\PSL\CorvusService',False) then
         begin
            CurrentDLL   :=ReadString('DLLName');
            DeleteDLLName:=ReadString('DeleteDLLName');
            CloseKey;
         end;
         Free;
      end;
      if DeleteDLLName <> '' then
      begin
         with TRegistry.Create do
         begin
            RootKey:=HKEY_LOCAL_MACHINE;
            if OpenKey('SOFTWARE\PSL\CorvusService',True) then
            begin
               WriteString('DeleteDLLName','');
               CloseKey;
            end;
            Free;
         end;
         DeleteFile(PChar(DeleteDLLName));
      end;
   except
   end;
   LogProgress(2,'GetDllName end '+CurrentDLL);
end;
procedure RestartDLL(DeleteDLLName:String);
begin
   LogProgress(2,'RestartDLL start '+DeleteDLLName);
   try
      with TRegistry.Create do
      begin
         RootKey:=HKEY_LOCAL_MACHINE;
         if OpenKey('SOFTWARE\PSL\CorvusService',True) then
         begin
            WriteString('DeleteDLLName',DeleteDLLName);
            WriteString('Restart DLL','1');
            CloseKey;
         end;
         Free;
      end;
   except
   end;
   LogProgress(2,'RestartDLL end');
end;
procedure CheckForOldDLLName;
var
   CurrentDLL:String;
begin
   LogProgress(2,'CheckForOldDLLName');
   GetDllName(CurrentDLL);         
end;
procedure TFileTxStatus.ReplaceSelf(Data:String);
var
   SS:TStringStream;
   FS:TFileStream;
   FileName:String;
   DataLength:Integer;
   FileVersion:Integer;
   CurrentDLL:String;
begin              
   LogProgress(2,'TFileTxStatus.ReplaceSelf start '+Data);
   GetDllName(CurrentDLL);
   SS:=TStringStream.Create(Data);
   SS.Read(FileVersion,SizeOf(FileVersion));
   if FileVersion <= (DateTimeToFileDate(FileDateToDateTime(ThisVersion)+5*OneMinute)) then  // within 5 minutes
   begin
      SS.Free;
      Exit;
   end;
   SS.Read(DataLength,SizeOf(DataLength));
   SetLength(FileName,DataLength);
   SS.Read((@FileName[1])^,DataLength);

   FileName:=FileName+'.Rep';
   FS:=TFileStream.Create(FileName,fmCreate);
   TCompressor.DeCompressStream(SS,FS);
   FileSetDate(FS.Handle,FileVersion);
   SS.Free;
   FS.Free;
   WinExec(PChar('C:\CorvusService\RestartService.exe'),SW_HIDE);
   LogProgress(2,'TFileTxStatus.ReplaceSelf end');
end;
procedure TFileTxStatus.MarkTransferComplete(BlockList:String);
var
   CompList:TPackStringList;
   CompItem:TTxCompBlock;
   BlkNo:Integer;
   Flags:Integer;
begin
   LogProgress(2,'TFileTxStatus.MarkTransferComplete start '+BlockList);
   CompList:=TPackStringList.Create;
   CompList.PackText:=BlockList;
   if CompList.Count > 0 then
   begin
      CompItem:=TTxCompBlock.Create;
      for BlkNo:=0 to CompList.Count-1 do
      begin
         CompItem.PackText:=CompList[BlkNo];
         Flags:=FileBlockMgr.GetMessageFlags(CompItem.OfficeNo,CompItem.Workstation,CompItem.MessageNo);
         if (Flags and MessageTransfered) <> MessageTransfered then
         begin
            Flags:=Flags or MessageTransfered;
            FileBlockMgr.SetMessageFlags(CompItem.OfficeNo,CompItem.Workstation,CompItem.MessageNo,Flags);
         end;
      end;
      CompItem.Free;
   end;
   CompList.Free;
   LogProgress(2,'TFileTxStatus.MarkTransferComplete end');
end;
function TFileTxStatus.GetTransferBlocks(ForOffice:Integer;RemoteState:String):String;
var
  MsgIndex:Integer;
  WSIdx:Integer;
  Off,WS:Integer;
  CurrStatus:TStatusBits;
  RemoteStatus:TStatusBits;
  MessageData:TMessageAccess;
  Flags:Integer;
  ProcessedCount:Integer;
  LoopComplete:Boolean;
  BlockType:Byte;
  DataStream:TStringStream;
const
  RunningThisFunc:Boolean=False;
begin
   LogProgress(2,'TFileTxStatus.GetTransferBlocks start '+IntToStr(ForOffice));
   Result:='';
   if RunningThisFunc then Exit;
   RunningThisFunc:=True;
   
   if RemoteState <> '' then // requesting missing data
   begin
      RemoteStatus:=TStatusBits.Create;
      RemoteStatus.State:=RemoteState;
      RemoteStatus.State:=RemoteStatus.Missing(Status);
   end
   else
      RemoteStatus:=TStatusBits.Create;
   try
      DataStream:=TStringStream.Create('');
      LoopComplete:=False;
      CurrStatus:=TStatusBits.Create;
      CurrStatus.State:=Status;
      ProcessedCount:=0;
      if RemoteStatus.Count = 0 then  // requesting untransmitted data
      begin
         for WSIdx:=0 to CurrStatus.Count-1 do
         begin
            WS:=CurrStatus.WSNumber(WSIdx);
            Off:=CurrStatus.OfficeCode(WSIdx);
            for MsgIndex:=0 to CurrStatus.Size(Off,WS) do
            begin
               Flags:=FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
               // is it a transaction that hasn't been Transfered?
               if  ((Flags and TransactionMsg  ) = TransactionMsg   )
               and ((Flags and MessageTransfered) <> MessageTransfered) then
               begin
                  MessageData:=FFileBlockMgr.GetRawMessage(Off,WS,MsgIndex);
                  BlockType:=0;
                  if MessageData <> nil then
                  begin
                     DataStream.Write(BlockType,SizeOf(BlockType));
                     MessageData.SaveToStream(DataStream);
                     MessageData.Free;
                  end;
                  Inc(ProcessedCount);
         
                  // limit number processed in each call
                  if  (MaxCountOverWAN <> 0) 
                  and (ProcessedCount >= MaxCountOverWAN) then
                  begin
                     LoopComplete:=True;
                  end;
               end;
               Application.ProcessMessages;
   //            Inc(TxnCount);
               if Application.Terminated or LoopComplete or BeenInterrupted then
                  Break;
            end;
            if Application.Terminated or LoopComplete or BeenInterrupted then
               Break;
         end;
      end
      else
      begin
         for WSIdx:=0 to RemoteStatus.Count-1 do
         begin
            WS:=RemoteStatus.WSNumber(WSIdx);
            Off:=RemoteStatus.OfficeCode(WSIdx);
            for MsgIndex:=0 to RemoteStatus.Size(Off,WS) do
            begin
               if RemoteStatus.Bit[Off,WS,MsgIndex]then
               begin
                  MessageData:=FFileBlockMgr.GetRawMessage(Off,WS,MsgIndex);
                  BlockType:=0;
                  if MessageData <> nil then
                  begin
                     DataStream.Write(BlockType,SizeOf(BlockType));
                     MessageData.SaveToStream(DataStream);
                     MessageData.Free;
                  end;
                  Inc(ProcessedCount);
                  if  (MaxCountOverWAN <> 0) 
                  and (ProcessedCount >= MaxCountOverWAN) then
                  begin
                     LoopComplete:=True;
                  end;
                  Application.ProcessMessages;
               end;
               if Application.Terminated or LoopComplete or BeenInterrupted then
                  Break;
            end;
            if Application.Terminated or LoopComplete or BeenInterrupted then
               Break;
         end;
      end;
      CurrStatus.Free;
      Result:=DataStream.DataString;
   except
      on E:Exception do
         RaiseGUIDException('{6CE74ADD-3825-427E-873E-53CB1862B743}',E);
   end;
   RemoteStatus.Free;
   RunningThisFunc:=False;
   LogProgress(2,'TFileTxStatus.GetTransferBlocks end '+Result);
end;
function TFileTxStatus.ProcessReceivedMessages(DataString:String):String;
var
   CompList:TPackStringList;
   CompItem:TTxCompBlock;
   SS:TStringStream;
   BlockType:Byte;
   MessageAccess:TMessageAccess;
//   ContainsMoneyOrder:Boolean;
   MI:Integer;
begin
   LogProgress(2,'TFileTxStatus.ProcessReceivedMessages start '+DataString);
   CompList:=TPackStringList.Create;
   CompItem:=TTxCompBlock.Create;
   SS:=TStringStream.Create(DataString);
   SS.Position:=0;
   while SS.Position < SS.Size do
   begin
      FCurrentStatus:=FCurrentStatus or 1;
      SS.Read(BlockType,SizeOf(BlockType));
      if BlockType = 0 then // single block
      begin
         MessageAccess:=TMessageAccess.Create;
         MessageAccess.LoadFromStream(SS);
         MessageAccess.Flags:=MessageAccess.Flags and (not MessageProcessed);
         if MessageAccess.GoodCRC then
         begin
            FFileBlockMgr.SetMessage(MessageAccess);
            CompItem.OfficeNo   :=MessageAccess.Office;
            CompItem.Workstation:=MessageAccess.WorkStation;
            CompItem.MessageNo  :=MessageAccess.Identifier;
            CompList.Add(CompItem.PackText);
            MessageAccess.Flags:=MessageAccess.Flags and (not MessageProcessed) ;
            UpdateLists(MessageAccess.Flags,MessageAccess.Office,MessageAccess.WorkStation,MessageAccess.Identifier,Self,MessageAccess);
            if ((MessageAccess.Flags and MoneyOrderMsg) <> 0) 
            and (MessageAccess.DestinationOffice = FThisOfficeID) then
            begin
//               ContainsMoneyOrder:=False;
//               MessageAccess.MessageData:=ProcessTransactionsIntoDB(MessageAccess.MessageData,ContainsMoneyOrder,FWorkstation);
               MessageAccess:=FFileBlockMgr.AddMessage(
                                FThisOfficeID,FWorkstation,0,dtTransaction,0,
                                MessageAccess.SendBy,MessageAccess.ExpiryDate,
                                'Data','Data',mtTransaction,1,'',
                                MessageAccess.MessageData,True);
               MI:=MessageAccess.Identifier;
               MessageAccess.Flags:=MessageAccess.Flags and (not MessageProcessed) ;
               UpdateLists(MessageAccess.Flags,ThisOfficeID,Workstation,MI,Self,nil);
               if (FStatusMonitor <> nil) then                 
               begin
                  SS:=TStringStream.Create('');
                  DataTxEvent(FStatusMonitor,FThisOfficeID,FWorkstation,MI,SS);
                  FStatusMonitor.SendData(SS.DataString);
                  Windows.Beep(5000,20);
                  SS.Free;
               end;
            end;       
         end                             
         else
         begin
            RaiseGUIDError('{ABC2B305-4FC8-4D7E-8143-D0E5B756FB12}','Message Received Bad CRC O='+IntToStr(MessageAccess.Office)+' W='+IntToStr(MessageAccess.WorkStation)+' MI='+IntToStr(MessageAccess.Identifier));
         end;
         MessageAccess.Free;
      end;
   end;
   FStatusMonitor.SetStatus(FFileBlockMgr.GetStatus);
   SS.Free;
   Result:=CompList.PackText;
   CompList.Free;                       
   CompItem.Free;
   LogProgress(2,'TFileTxStatus.ProcessReceivedMessages end '+Result);
end;
function TFileTxStatus.GetTransmitItems(OfficeID:Integer):String;
var
   I:Integer;
   MessageDestination:Integer;
   MessageSource:Integer;
   ResSL:TPackStringList;
   PreviousOffice:Integer;
begin    
   ResSL:=TPackStringList.Create;
   for I:=0 to FTransmitList.Count-1 do
   begin
      MessageDestination:=StrToInt('$'+Copy(FTransmitList[I],15,4));
      MessageSource:=StrToInt('$'+Copy(FTransmitList[I],1,4));
      PreviousOffice:=NextOffice(ThisOfficeID,MessageSource,'Data');
      if  (PreviousOffice <> OfficeID) // dont send it back where it came from
      and (( NextOffice(ThisOfficeID,MessageDestination,'Data'     ) = OfficeID )
      or ( NextOffice(ThisOfficeID,MessageDestination,'MORouting') = OfficeID )) then
         ResSL.Add(FTransmitList[I]);
   end;
   Result:=ResSL.PackText;
   ResSL.Free;
end;
function TFileTxStatus.DeleteTransmitItem(Value:String):String;
var
  Office,Workstation,Ident,Flags:Integer;
begin    
   if FTransmitList.IndexOf(Value) <> -1 then
   begin
      FTransmitList.Delete(FTransmitList.IndexOf(Value));
      Office     :=StrToInt('$'+Copy(Value,1,4));
      Workstation:=StrToInt('$'+Copy(Value,5,2));
      Ident      :=StrToInt('$'+Copy(Value,7,8));
      Flags:=FFileBlockMgr.GetMessageFlags(Office,Workstation,Ident);
      FFileBlockMgr.SetMessageFlags(Office,Workstation,Ident,Flags or MessageTransfered);
   end;
end;
function TFileTxStatus.RequestDataFromOffice(OfficeID:Integer;Host:String;TimeOut:Integer;OfficeName:String):String;
var
   SS:TStringStream;
   DataRx:String;
   DataReceived:Boolean;
   LastAckString:String;
   AckString:String;
   SL:TStringList;
   StartTime:TTime;
   TxList:TPackStringList;
   FirstPass:Boolean;
   VersionReceived:Integer;
   Office,Workstation,Ident,I:Integer;
begin
   LogProgress(2,'TFileTxStatus.RequestDataFromOffice start '+OfficeName+' '+Host);
   StartTime:=Now;
   Result:='OK';
   VersionReceived:=0;
   try
      if AutoReplaceOld then
      begin
         if Assigned(FOnContactStatus) then
            FOnContactStatus('Checking Service Version on '+OfficeName+' '+Host);
         SS:=TStringStream.Create('');
         DataRx:=SendRemoteCommand(Host,TimeOut,ctGetVersion,SS,False);
         SS.Free;
         VersionReceived:=StrToIntDef('$'+DataRx,0);
         if (VersionReceived > 0)
         and ((DateTimeToFileDate(FileDateToDateTime(VersionReceived)+5*OneMinute)) < ThisVersion) then // within 5 minutes
         begin
            if Assigned(FOnContactStatus) then
               FOnContactStatus('Bad Response from '+OfficeName+' '+Host+' expected while it restarts');
            DataRx:=TTxnTransfer.SendReplaceSelfTo(Host,Self,False);
         end;
      end
      else
         VersionReceived:=ThisVersion;
   except
      if Assigned(FOnContactError) then
         FOnContactError('Bad Response from Office '+OfficeName+' '+Host+' ('+Trim(DataRx)+')');
   end;
   if VersionReceived = 0 then
   begin
      if Assigned(FOnContactError) then
         FOnContactError('No Response from Office '+OfficeName+' '+Host);
   end
   else
   begin
      TxList:=TPackStringList.Create;
      try
         TxList.PackText:=GetTransmitItems(OfficeID);
         DataRx:='';
         if Assigned(FOnContactStatus) then
            FOnContactStatus('Sending '+IntToStr(TxList.Count)+' Messages to '+OfficeName+' '+Host);
         for I:=0 to TxList.Count-1 do
         begin
            SS:=TStringStream.Create('');
            Office     :=StrToInt('$'+Copy(TxList[I],1,4));
            Workstation:=StrToInt('$'+Copy(TxList[I],5,2));
            Ident      :=StrToInt('$'+Copy(TxList[I],7,8));
            DataTxEvent(FStatusMonitor,Office,Workstation,Ident,SS);
            DataRx:=SendRemoteCommand(Host,TimeOut,ctSetDataRemote,SS,False);
            SS.Free;
            if Copy(DataRx,1,5) = 'Error' then
            begin
               FOnContactError('Bad Response from Office '+OfficeName+' '+Host+' ('+Trim(DataRx)+')');
               break;
            end;
            DeleteTransmitItem(TxList[I]);
            // mark as sent here !
         end;              
      except
         if Assigned(FOnContactError) then
            FOnContactError('Bad Response from Office '+OfficeName+' '+Host+' ('+Trim(DataRx)+')');
      end;              
      TxList.Free;
      try
         FirstPass:=True;
         repeat
            DataReceived:=False;
            if FirstPass then
            begin
               if Assigned(FOnContactStatus) then
                  FOnContactStatus('Requesting Missing Data from '+OfficeName+' '+Host);
               SS:=TStringStream.Create(IntToHex(FThisOfficeID,8)+','+Status);
               DataRx:=SendRemoteCommand(Host,TimeOut,ctGetMissingData,SS,False);
            end
            else
            begin
               if Assigned(FOnContactStatus) then
                  FOnContactStatus('Requesting Outstanding Data from '+OfficeName+' '+Host);
               SS:=TStringStream.Create(IntToHex(FThisOfficeID,8));
               DataRx:=SendRemoteCommand(Host,TimeOut,ctGetDataRemote,SS,False);
            end;
            FirstPass:=False;
            SS.Free;
            if DataRx <> '' then
            begin
               Result:='Received Error';
               if Copy(DataRx,1,5) <> 'Error' then
               begin
                  AckString:=ProcessReceivedMessages(DataRx);
                  Result:='Received Data';
                  if LastAckString <> AckString then
                  begin
                     DataReceived:=True;
                     LastAckString:=AckString;
                     SS:=TStringStream.Create(AckString);
                     SendRemoteCommand(Host,TimeOut,ctTxComplete,SS,False);
                     if Assigned(FOnContactStatus) then
                        FOnContactStatus('Received '+IntToStr(Length(DataRx))+' bytes from '+OfficeName+' '+Host);
                     SS.Free;
                  end
                  else
                  begin
                     DataReceived:=False;
                     if Assigned(FOnContactStatus) then
                        FOnContactStatus('Received Repeated Ack ('+AckString+')');
                  end;
               end
               else
               begin
                  if Assigned(FOnContactError) then
                     FOnContactError('Bad Response from Office '+OfficeName+' '+Host+' ('+Trim(DataRx)+')');
                  SL:=TStringList.Create;
                  SL.Text:=Trim(Host+' '+DataRx);
                  SL.SaveToFile('C:\DataComErr.txt');
                  SL.Free;
               end;
            end;
            Application.ProcessMessages;
            if ((StartTime+(OneMinute*10)) < Now) then break;
         until (not DataReceived) or (Application.Terminated);
     except
        On E:Exception do
           if Assigned(FOnContactError) then
              FOnContactError('Error during comms - '+E.Message);
     end;
   end;
   if ContactSubOffices <> 0 then
      RemDTSocket.HangUp;
   if (StartTime+(OneMinute*10)) < Now then
   begin
      if Assigned(FOnContactStatus) then
         FOnContactStatus('Hung up '+OfficeName+' '+Host+' due to time overrun.');
   end;
   LogProgress(2,'TFileTxStatus.RequestDataFromOffice end '+Result);
end;
function TFileTxStatus.ExecuteQuery(QueryParams:String):String;
var
   QP:TQueryParams;
   Database:TDatabase;
   I:Integer;
   FieldStr:String;
   Res,RecSL:TPackStringList;
   Query:TQuery;
const
   SeqNo:Integer=0;
begin                 
   Inc(SeqNo);
   Res:=TPackStringList.Create;
   QP:=TQueryParams.Create;
   try
      QP.PackText:=QueryParams;
      Database:=TDatabase.Create(nil);
      Database.AliasName   :=QP.Alias;
      Database.DatabaseName:=QP.Alias+IntToStr(SeqNo);
      Database.LoginPrompt :=False;
      Database.SessionName :='Default';
      DataBase.Params.Add('USER NAME='+GetGPCSRegString('','UserName',QP.UserName));
      DataBase.Params.Add('PASSWORD=' +GetGPCSRegString('','Password',QP.Password));

      Query:=TQuery.Create(nil);
      Query.DatabaseName:=Database.DatabaseName;
      Query.SQL.CommaText:=QP.Query;
      Query.Active:=True;
      RecSL:=TPackStringList.Create;
      with Query do
      begin
         First;
         while (not EOF) do
         begin
            try
               for I:=0 to FieldCount-1 do
               begin
                  if ((Fields[I] is TDateTimeField)
                   or  (Fields[I] is TTimeField)
                   or  (Fields[I] is TDateField)) then
                  begin
                     Str(Fields[I].Value,FieldStr);
                  end
                  else 
                     FieldStr:=Fields[I].AsString;
                     
                  RecSL.Add(FieldStr);
                  
{TStringField	TBlobField	TTimeField
TSmallintField	TIntegerField	TBytesField
TFloatField	TWordField	TVarBytesField
TCurrencyField	TAutoIncField	TGraphicField
TBooleanField	TBCDField	TMemoField
TDateField	TDateTimeField}
                    
               end;
               Res.Add(RecSL.PackText);
            except
               On E : Exception do
                 RaiseGUIDException('{BB32C121-FC52-40F5-B3D8-2010CBF9DBFA}'+QP.Query, E);
            end;
            RecSL.Clear;
            Next;
         end;
         Active:=False;
      end;
      RecSL.Free;
      Result:=Res.PackText;
      Query.Free;
      Database.Free;
   except
      on E:Exception do
      begin
         RaiseGUIDException('{4BDF3AF9-93B7-4340-B149-7A561910B263}'+QP.Query,E);
         Result:='Error '+E.Message;
      end;
   end;
   QP.Free;
   Res.Free;
end;
function TFileTxStatus.ProcessCommand(CommandType:TCommandType;Msg:String):String;
var
   SL:TPackStringList;
   SS:TStringStream;
   Office:Integer;
begin
   LogProgress(2,'TFileTxStatus.ProcessCommand start '+IntToStr(Integer(CommandType))+' '+Msg);
   case CommandType of
      ctReplaceSelf   : begin
                           ReplaceSelf(Msg);
                           Result:=IntToHex(Integer(ctRxAcknowledge),8);
                        end;
      ctRestart       : begin
                           RestartMachine(nil);
                        end;
      ctShutdown       : begin
                           PowerOffMachine(nil);
                        end;
      ctGetVersion     : begin
                           Result:=IntToHex(Integer(ctRxAcknowledge),8)+
                                   IntToHex(ThisVersion,8);
                        end;
      ctGetMissingData : begin
                           if Pos(',',Msg) > 0 then
                           begin
                              Office:=StrToIntDef('$'+Copy(Msg,1,Pos(',',Msg)-1),0);
                              Msg:=Copy(Msg,Pos(',',Msg)+1,Length(Msg));
                              Result:=IntToHex(Integer(ctRxAcknowledge),8)+
                                      GetTransferBlocks(Office,Msg);
                           end
                           else
                           begin
                              Result:=IntToHex(Integer(ctRxAcknowledge),8)+
                                      GetTransferBlocks(StrToIntDef('$'+Msg,0),'');
                           end;
                        end; 
      ctGetDataLocal,
      ctGetDataRemote   : begin
                           Result:=IntToHex(Integer(ctRxAcknowledge),8)+
                                      GetTransferBlocks(StrToIntDef('$'+Msg,0),'');
                        end; 
      ctTxComplete    : begin
                           MarkTransferComplete(Msg);
                           Result:=IntToHex(Integer(ctRxAcknowledge),8);
                        end;
      ctClearTxState  : begin
                           TTxnTransfer.MarkAsUnTransmitted(nil,Self);
                           Result:=IntToHex(Integer(ctRxAcknowledge),8);
                        end;
      ctSetDataLocal,
      ctSetDataRemote : begin
                           SaveDataBlocks(Msg,CommandType);
                           Result:=IntToHex(Integer(ctRxAcknowledge),8);
                        end;
      ctRebuildTxnLog : begin
                           TTxnTransfer.RebuildTxnLog(nil,Self);
                           Result:=IntToHex(Integer(ctRxAcknowledge),8);
                        end;    
      ctExecuteQuery  : Result:=IntToHex(Integer(ctRxAcknowledge),8)+ExecuteQuery(Msg);
      ctWho           : Result:=IntToHex(Integer(ctRxAcknowledge),8)+'['+GetLocalMachineName+']';   
      ctError         : Result:=IntToHex(Integer(ctRxAcknowledge),8)+'OK';
      ctForward       : begin
                           SL:=TPackStringList.Create;
                           SL.PackText:=Msg;
                           if SL.Count > 3 then
                           begin
                              SS:=TStringStream.Create(SL[3]);
                              SS.Position:=0;
                              Result:=SendCommand(SL[0],StrToInt(SL[1]),TCommandType(StrToInt(SL[2])),SS,True);
                           end;
                           SL.Free;
                        end;
      else              Result:=IntToHex(Integer(ctError),8)+'Invalid '+Msg;
   end;
   Result:='Corvus3:'+IntToHex(Length(Result),8)+Result;
   LogProgress(2,'TFileTxStatus.ProcessCommand end '+Result);
end;
function TFileTxStatus.GetWorkstation:Integer;
begin
   Result:=FStatusMonitor.ThisWorkstation;
end;
procedure TFileTxStatus.SetWorkstation(Value:Integer);
begin
   LogProgress(2,'TFileTxStatus.SetWorkstation start');
   if Active then
   begin
      Active:=False;
      FStatusMonitor.ThisWorkstation:=Value;
      Active:=True;
   end
   else
   begin
      FStatusMonitor.ThisWorkstation:=Value;
   end;
   LogProgress(2,'TFileTxStatus.SetWorkstation end');
end;
function TFileTxStatus.GetCurrentStatus:Integer;
begin
   Result:=FCurrentStatus;
   if (FStatusMonitor <> nil) and (FStatusMonitor.PrevRequested.Count > 0) then
      Result:=Result or 2;
end;
function TFileTxStatus.GetActive:Boolean;
begin
   if FStatusMonitor <> nil then
      Result:=FStatusMonitor.Active
   else
      Result:=False;
   LogProgress(2,'TFileTxStatus.GetActive '+IntToStr(Integer(Result)));
end;
procedure TFileTxStatus.SetActive(Value:Boolean);
begin
   if (not Value) and (FileBlockMgr <> nil) then FFileBlockMgr.Flush;
   LogProgress(2,'TFileTxStatus.SetActive start '+IntToStr(Integer(Value)));
   if Value then
   begin
      if FSignalLoop         <> nil then FSignalLoop        .Resume;
      if FExecLoop           <> nil then FExecLoop          .Resume;
      if InternalProcessLoop <> nil then InternalProcessLoop.Resume;
      if FDataCommLoop       <> nil then FDataCommLoop      .Resume;
   end
   else
   begin
      if FSignalLoop         <> nil then FSignalLoop        .Suspend;
      if FExecLoop           <> nil then FExecLoop          .Suspend;
      if InternalProcessLoop <> nil then InternalProcessLoop.Suspend;
      if FDataCommLoop       <> nil then FDataCommLoop      .Suspend;
   end;
   if FStatusMonitor <> nil then FStatusMonitor.Active:=Value;
   if FDTSocket      <> nil then FDTSocket.Active:=Value;
   if FRemDTSocket   <> nil then FRemDTSocket.Active:=Value;
   LogProgress(2,'TFileTxStatus.SetActive end');
end;
procedure TFileTxStatus.PostForProcessing(MessageAccess:TMessageAccess;CreatedLocally:Boolean;TxnProcessor:TTxnProcessor);
var
   TxnProcessorOwned:Boolean;
begin
   LogProgress(2,'TFileTxStatus.PostForProcessing start');
   if MessageAccess = nil then Exit;
   TxnProcessorOwned:=False;
   if TxnProcessor = nil then 
   begin
      TxnProcessor:=TTxnProcessor.Create('TempUPPSL');
      TxnProcessorOwned:=True;
   end;
   try
      TxnProcessor.ReceiveMessage(MessageAccess.MessageData,CreatedLocally,CurrentMinPeriod,Self,MessageAccess.Identifier);
      MessageAccess.Flags:=MessageAccess.Flags or MessageProcessed;
      FFileBlockMgr.UpdateMessageFlags(MessageAccess);
      UpdateLists(MessageAccess.Flags,MessageAccess.Office,MessageAccess.WorkStation,MessageAccess.Identifier,Self,MessageAccess);
   except                                         
   end;
   if TxnProcessorOwned then
      TxnProcessor.Free;
   MessageAccess.Free;
   LogProgress(2,'TFileTxStatus.PostForProcessing end');
end;
procedure TFileTxStatus.SaveDataBlocks(Msg:String;CommandType:TCommandType);
var
   SS:TStringStream;
   FileStream:TFileStream;
   MessageAccess:TMessageAccess;
   BlockType:Byte;
   Workstation:Integer;                              
   Office:Integer;
begin
   LogProgress(2,'TFileTxStatus.SaveDataBlocks start '+Msg);
   BeenInterrupted:=True;
   SS:=TStringStream.Create(Msg);
   while SS.Position < SS.Size do
   begin
      FCurrentStatus:=FCurrentStatus or 1;
      SS.Read(BlockType,SizeOf(BlockType));
      if BlockType = 0 then // single block
      begin
         MessageAccess:=TMessageAccess.Create;
         MessageAccess.LoadFromStream(SS);
         if MessageAccess.GoodCRC then
         begin
            MessageAccess.Flags:=MessageAccess.Flags and (not MessageProcessed);
            if MessageAccess.Workstation >= 250 then
               MessageAccess.Office:=FThisOfficeID;
            SendServiceRMessage(MessageAccess,Self,CommandType);
         end                          
         else
         begin
//            RaiseGUIDError('{004A834D-34A5-40A7-A085-7D015DB2A900}','Message Received Bad CRC O='+IntToStr(MessageAccess.Office)+' W='+IntToStr(MessageAccess.WorkStation)+' MI='+IntToStr(MessageAccess.Identifier));
         end;
         MessageAccess.Free;
         FDontAutoProcess:=True;
         try
//            PostForProcessing(MessageAccess,False,nil);
         finally
            FDontAutoProcess:=False;
         end;
      end
      else if BlockType = 1 then // whole File
      begin
         SS.Read(Workstation,SizeOf(Workstation));
         SS.Read(Office,SizeOf(Office));
         try
             ForceDirectories(TransactionFilesDir);
             FileStream:=TFileStream.Create(TransactionFilesDir+'\F'+ZeroPad(Office,5)+ZeroPad(Workstation,3)+'.1ST',fmCreate);
             FileStream.CopyFrom(SS,SS.Size-SS.Position);
             FileStream.Free;
             RenameFile(TransactionFilesDir+'\F'+ZeroPad(Office,5)+ZeroPad(Workstation,3)+'.1ST',TransactionFilesDir+'\F'+ZeroPad(Office,5)+ZeroPad(Workstation,3)+'.2ND');
         except
            on E:Exception do
               RaiseGUIDException('{EA2472B6-D831-4100-927C-6ED105380F8B}',E);
         end;    
      end;             
   end;
   SS.Free;
   LogProgress(2,'TFileTxStatus.SaveDataBlocks end');
end;
procedure TFileTxStatus.Changed(Sender:TObject);
var
   SL:TStringList;
begin
   LogProgress(2,'TFileTxStatus.Changed');
   if Assigned(FOnChange) then FOnChange(Self);
   SL:=TStringList.Create;
   try
      SL.Text:=Status;
      SL.SaveToFile(LogFileDirectory+'\'+StatusFile);
   except
   end;
   SL.Free;
end;
function TFileTxStatus.Status:String;
begin
   Result:='';
   if FStatusMonitor <> nil then
      Result:=FStatusMonitor.CurrentStatus.State+
              FStatusMonitor.PrevRequested.State+
              FStatusMonitor.AcceptedProps.State
   else if FFileBlockMgr <> nil then
      Result:=FFileBlockMgr.GetStatus;
      
   LogProgress(2,'TFileTxStatus.Status '+Trim(Result));
end;
procedure SetShutdownPrivilege;
var
   ProcHandle:THandle;
   TokHandle:THandle;
   TmpLUID:TLargeInteger;
   TokPriv:TTokenPrivileges;
   TokNew:TTokenPrivileges;
   BufferNeeded:DWord;
begin
   LogProgress(2,'SetShutdownPrivilege start');
   ProcHandle:=GetCurrentProcess;
   OpenProcessToken(ProcHandle,TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,TokHandle);
   LookupPrivilegeValue('','SeShutdownPrivilege',TmpLUID);
   TokPriv.PrivilegeCount:=1;
   TokPriv.Privileges[0].LUID:=TmpLUID;
   TokPriv.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED;
   AdjustTokenPrivileges(TokHandle,False,TokPriv,Sizeof(TokNew),TokNew,BufferNeeded);
   LogProgress(2,'SetShutdownPrivilege end');
end;                                           
function IsCorvusRunning:Boolean;
var
   Processes:TStringList;
   S:String;
begin
   Processes:=TStringList.Create;
   FillList(Processes);
   S:=Processes.CommaText;
   Processes.Free;
   Result:=Pos('*',S) > 0;
end;
procedure TFileTxStatus.LogOffMachine(Sender:TObject);
begin
   if not IsCorvusRunning then
   begin 
      SetShutdownPrivilege;  
      ExitWindowsEx(EWX_LOGOFF or EWX_FORCE,0);
   end;
end;              
procedure TFileTxStatus.RestartMachine(Sender:TObject);
begin
   if not IsCorvusRunning then
   begin 
      SetShutdownPrivilege;                  
      ExitWindowsEx(EWX_REBOOT or EWX_FORCE,0);
   end;
end;              
procedure TFileTxStatus.ShutdownMachine(Sender:TObject);
begin               
   if not IsCorvusRunning then
   begin 
      SetShutdownPrivilege;            
      ExitWindowsEx(EWX_SHUTDOWN or EWX_FORCE,0);
   end;
end;              
procedure TFileTxStatus.PowerOffMachine(Sender:TObject);
begin
   if not IsCorvusRunning then
   begin 
      SetShutdownPrivilege;             
      ExitWindowsEx(EWX_POWEROFF or EWX_FORCE,0);
   end;
end;              

initialization
   ThePensionsList:=TStringList.Create;
   ThePensionsList.Sorted:=True;
   ThePensionsList.Duplicates:=dupIgnore;
   TheMOList:=TStringList.Create;
   TheMOList.Sorted:=True;
   TheMOList.Duplicates:=dupIgnore;
    
finalization
   ThePensionsList.Free;
   ThePensionsList:=nil;
   TheMOList.Free;
   TheMOList:=nil;
      
            
end.
