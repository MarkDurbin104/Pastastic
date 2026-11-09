unit CompExecU;

interface

uses
  IPControl, StringWrapperU,
  Windows,Classes,Forms,Messages,Controls,ComObj,SysUtils,Graphics,ExtCtrls,
  GPCSBase_TLB,GPCSBaseAU,CompressU,Bin2String,GPCSGUID,GPCSErrorCode,GPCSErrorLine, 
  StringUtil,FileTxStatusU,Registry,DatabaseServer_TLB,DBTables,Compress,
  CpyFile,Dialogs,PackStrListU,UserManager_TLB,FileCtrl,CRC32;

const
  WM_RESTOREPREVIOUS = WM_USER+1;
  WM_CANCELPREVIOUS  = WM_USER+2;
  WM_TXNLOGCHANGED   = WM_USER+3;
  WM_TRACKINGRECEIPT = WM_USER+4;
  
  OneHour = 1/24;
  OneMinute = OneHour/60;
  OneSecond = OneMinute/60;
  
type
  TPType =(ptForm,ptError,ptHelp,ptInfo,ptPick,ptTrans,ptAcct,ptCancel);
  TPadMode = (pmPick,pmHelp,pmForm,pmTrans,pmCols,pmInst);
  TGetFormIndex     = function :Integer                                 of object;
  TGetButtonRef     = function (Index:Integer):TControl                 of object;
  TGetButtonIndex   = function (Button:TControl):Integer                of object;
  TSetButtonBitMap  = procedure(Button:TControl;var BitMap :TBitMap )   of object;
  TSetButtonCaption = procedure(Button:TControl;Caption:String  )       of object;
  TSetButtonPrice   = procedure(Button:TControl;Price  :Currency)       of object;
  TSetButtonToggle  = procedure(Button:TControl;State:Integer)          of object;
  TSetButtonOnClick = procedure(Button:TControl;Handler:TNotifyEvent)   of object;
  TGetButtonOnClick = function (Button:TControl):TNotifyEvent           of object;
  TSetTextItem      = procedure(Caption:String)                         of object;
  TSetFormData      = procedure(Caption:String;FlagError,NewForm,DontUpdate:Boolean)       of object;
  TSetBitMap        = procedure(BitMap:TBitMap)                         of object;
  TSaveCurrentState = procedure(Restore:Boolean)                        of object;
  TModalDialogBox   = procedure(PType:TPType;Text,DlgPrompt,DlgHint:String;B1,B2,B3:TControl;B1C,B2C,B3C:String) of object;
  TFuncKeyPress     = procedure(FKey:Integer)                           of object;
  TDisplayInstruct  = procedure(Text,BitMap:String)                     of object;
  TOnProgress       = procedure(Title:String;Min,Max,Pos:Integer)       of object;
  TEODWarning       = procedure(Title:String;State:Boolean)             of object;
  TReportPreview    = function(Name:String;JustData:Boolean):String     of object;
  TSaveData = class
     BitMap     :array[0..20] of TBitMap;
     Caption    :array[0..20] of String;
     Price      :array[0..20] of Currency;
     BEnabled   :array[0..20] of Boolean;
     NotifyChild:array[0..20] of Boolean;
     ToggleClick:array[0..20] of Boolean;
     IsUp       :array[0..20] of Boolean;
  end;
  TCompExec = Class(TGPCSBaseComponent,IUIEventSink,ITxnEventSink,IDeviceEventSink)
  private
    AccountManager:IAccounts;
    ReferenceDataList : TPackStringList;
    ExecList:TPackStringList;
    FinishedInitialise:Boolean;
    FESState:esState;
    FUser       :String;
    FRealUser       :String;
    FOffice     :String;
    FWorkstation:String;
    FServerName :String;
    NotifyChild:Array[0..100] of Boolean;
    ReturnedAlready:Boolean;
    SaveList:TPackStringList;
    WindowHandle:THandle;
    ItemList:TPackStringList;
    Item:IExecComponent;
    FQuantity:Integer;
    FMaxItems:Integer;
    FGroupSuffix:String;
    FUsers:String;
    FOnGetButtonRef    :TGetButtonRef;
    FOnGetFormIndex    :TGetFormIndex;
    FOnGetButtonIndex  :TGetButtonIndex;
    FOnSetButtonBitMap :TSetButtonBitMap;
    FOnSetButtonCaption:TSetButtonCaption;
    FOnSetButtonPrice  :TSetButtonPrice;
    FOnSetButtonToggle :TSetButtonToggle;
    FOnSetButtonOnClick:TSetButtonOnClick;
    FOnGetButtonOnClick:TGetButtonOnClick;
    FOnSaveCurrentState:TSaveCurrentState;
    FOnSetTitle        :TSetTextItem;
    FOnSetPrompt       :TSetTextItem;
    FOnSetPMessage     :TSetTextItem;
    FOnSetTransactions :TSetTextItem;
    FOnSetAccounts     :TSetTextItem;
    FOnSetFormData     :TSetFormData;
    NewFormNext:Boolean;
    FOnSetScale        :TSetTextItem;
    FOnSetBitMap       :TSetBitMap;
    FOnDisplayInstruct :TDisplayInstruct;
    FOnModalDialog     :TModalDialogBox;
    FEODWarning        :TEODWarning;
    FOnReportPreview   :TReportPreview;
    DontRePaint:Boolean;
    FWorkStationGroup:String;
    FUserGroup  :String;
    WUGroup:IWUGroup;
    InExecFromList:Boolean;
    Compressor:TCompressor;
    WaitOnModalDialog:Boolean;
    ModalDialogKey:String;

    FPeriod          :IPeriod         ;
    //FNetManager      :INetManager     ;
    FNetManager      :INetUser        ;
    //FNetUser         :INetUser        ;
    FTxnLog          :ITransactionLog ;
    FCompMan         :ICompMan        ;
    FStock           :IStock          ;
    FPictureServer   :IPictureServer  ;
    FLabelPr         :IDevice         ;
    FTrackedMail     :IMailItemLog    ;
    FCounter         :IDevice         ;
    FScale           :IDevice         ;
    FReceiptSlip     :IDevice         ;
    FOCR             :IDevice         ;
    FOfficeInfo      :IDevice         ;
    FCustDisp        :IDevice         ;
    FExtBarCode      :IDevice         ;
    FTranslator      :ITranslate      ;
    FHookUp          :IHookUp         ;
    function GetUniqueID(Office,WorkStation:String):String;
    //function GetNetManager      :INetManager     ;
    function GetNetManager      :INetUser     ;
    //function GetNetUser         :INetUser        ;
    function GetTxnLog:ITransactionLog;

    function GetPeriod:IPeriod;
    function GetCompMan:ICompMan;
    function GetStock:IStock;
    function GetPictureServer:IPictureServer;
    function GetLabelPr:IDevice;
    function GetTrackedMail:IMailItemLog;
    function GetCounter:IDevice;
    function GetScale:IDevice;
    function GetReceiptSlip:IDevice;
    function GetOCR:IDevice;
    function GetOfficeInfo:IDevice;
    function GetCustDisp:IDevice;
    function GetExtBarCode:IDevice;
    function GetTranslator:ITranslate;
    function GetHookUp:IHookUp;

    function GetBitmap(Value:OleVariant;BType:Boolean):TBitMap;
    procedure WMRestorePrevious(var Msg:TMessage); message WM_RESTOREPREVIOUS;
    procedure WMTxnLogChanged(var Msg:TMessage); message WM_TXNLOGCHANGED;
    procedure WMTrackingReceipt(var Msg:TMessage); message WM_TRACKINGRECEIPT;
    procedure DefaultHandler(var Message); override;
    procedure WndProc(var Message: TMessage);
    procedure SetWorkStationGroup(Value:String);
    procedure SetUserGroup  (Value:String);
    procedure SetUser       (Value:String);
    procedure SetOffice     (Value:String);
    procedure SetWorkstation(Value:String);
    procedure Execute(Name,Data:String);
  protected   
    RunAfterCancel    :String;
    RunAfterCancelData:String;
    ProgressTitle:String;
    ProgressMin:Integer;
    ProgressMax:Integer;
    ProgressPos:Integer;
    ProgressTimer:TTimer;
    FOnProgress:TOnProgress;
    DiskUnustable:Boolean;
    procedure OpenCashDrawer; safecall;
    procedure ProgressBar(const Title: WideString; Min, Max, Pos, Auto: Integer); safecall; 
    procedure CreateTxnBatchFile;
    procedure ReadTxnBatchFile;
    procedure TransferTxnsToDiskette; safecall;
    procedure TransferTxnsFromDiskette; safecall;
    procedure ProgressTick(Sender:TObject);
    function Endorse(X,Y,ColCount:Integer;const PackText:WideString):WordBool; safecall;
    procedure WaitFor(DeviceStatus: DeviceStatusType); safecall;
    procedure DisplayItemInfo(const EventSource: IExecComponent; Index: Integer;BitMap:OleVariant;const Caption: WideString; Price: Currency; State: Integer;Notify,Nested:WordBool); safecall;
    procedure DisplayInstructions(Style: InstructStyle; const Text:WideString;BitMap:OleVariant); safecall;
    procedure OnChange(const EventSource:ITransactionLog); safecall;
    procedure LoggedTransaction(Index,Quantity,PLU:Integer;Value,Price:Currency;
                                const Description,Additional,ProgID,DomInfo:WideString); safecall;
    procedure VoidedTransaction(Index,Quantity,PLU:Integer;Value,Price:Currency;
                                const Description,Additional,ProgID,DomInfo:WideString); safecall;
    function GetComponentReference(const Name: WideString): IDispatch; safecall;
    function CurrentDetails:WideString; safecall;
    function CurrentLine: Integer; safecall;
    procedure EmptySaveList;
    function  PutBack(Name:String):Boolean;
    function  InternalFunction(FuncName:String):Boolean;
    procedure ItemSelected(Index:Integer);
    function FormDataChanged(Value:String):Boolean;
    procedure Trigger(const Data: WideString); safecall;
    procedure ControlReleased; safecall;
    function Get_User:WideString; safecall;
    function Get_Office:Integer; safecall;
    function Get_Workstation:Integer; safecall;
    procedure SetTime(DateTime:TDateTime);
    procedure SetShutdownPrivilege;
    procedure SendReceiptDetails(Ident:String);
    procedure Print2x2(const Title,Desc1,Desc2,Office,DataPackText:WideString); safecall;
//    procedure RPrintAccount(AccountGroup:String);
    procedure SelectAccount(AccountGroup:String);
    procedure Shutdown;
    procedure LogOff;
    procedure Lock;
    procedure CopyFromFloppyCopyFile(Sender: TCopyFile);
    procedure CopyFromFloppyGetReadyDevice;
    function  CopyFromFloppyInsertDisk(Txt: String): Word;
    procedure CopyIntoFloppyCopyFile(Sender:TCopyFile);
    procedure CopyIntoFloppyDiskNoRead;
    procedure CopyIntoFloppyGetReadyDevice;
    function  CopyIntoFloppyInsertDisk(Txt:String):Word;
    function  CopyIntoFloppyInsertFormatDisk(Txt:String):Word;
    procedure TriggerSubProducts(Value:String);    
  public
    IPControl : TIPControl;
    ClerkCode      :Integer;
    ClerkOfficeCode:Integer;
    ClerkLevel     :Integer;
    Exiting:Boolean;
    KeyHit:Boolean;
    DontTrigger:Boolean;
    DontUpdate:Boolean;
    CurrentExec:String;
    TriggerValue:String;
    UnderRemoteControl:Boolean;
    ScaleReading:Integer;
    LastScaleReading:Integer;
    ModalSelection:Integer;
    procedure Activate;
    procedure CloseAllLinks;
    procedure Refresh;
    procedure SetExecDataValues(Values:String);
    procedure WMCancelPrevious(var Msg:TMessage); message WM_CANCELPREVIOUS;
    function CheckStartOfDay(Force:Boolean):Boolean;
    procedure ExecuteComponent(CompToExec,Data:String);
    procedure SwapTo(const ProgID, PassData: WideString); safecall;
    procedure DataChanged(const EventSource: IExecComponent;const Value: WideString; FlagError: WordBool); safecall;
    function  Translate(const Value: WideString):WideString; safecall;
    function  ReferenceData(const Name: WideString):WideString; safecall;
    procedure ExecFromList(List:TStrings);
    function  GetPictureFromServer(Value:String):TBitMap;
    procedure Initialize; override;
    destructor Destroy; override;
    procedure Restore; safecall;
    function Get_HookUp:IHookUp; safecall;
    procedure Cancel;
    procedure CancelToTop;
    procedure ZeroScale;
    procedure EndCustomer(UniqueID:String);
    procedure CancelCustomer;
    function ProgIsTracked(ProgID:String):Boolean;
    procedure TrackingReceipt(Description,Destination,Sender,Recpient,Ident:String;Price,Fee:Currency);
    procedure Receipt(Print:Boolean);
    procedure SetTxnLogParent(Value:THandle);
    procedure ItemClicked(Sender:TObject);
    function CanExecute(GroupName:String):Boolean;
    property WorkStationGroup:String read FWorkStationGroup write SetWorkStationGroup;
    property UserGroup  :String read FUserGroup   write SetUserGroup  ;
    property Users      :String read FUsers       write FUsers        ;
    property OnGetButtonRef    :TGetButtonRef     read FOnGetButtonRef     write FOnGetButtonRef    ;
    property OnGetFormIndex    :TGetFormIndex     read FOnGetFormIndex     write FOnGetFormIndex    ;
    property OnGetButtonIndex  :TGetButtonIndex   read FOnGetButtonIndex   write FOnGetButtonIndex  ;
    property OnSetButtonBitMap :TSetButtonBitMap  read FOnSetButtonBitMap  write FOnSetButtonBitMap ;
    property OnSetButtonCaption:TSetButtonCaption read FOnSetButtonCaption write FOnSetButtonCaption;
    property OnSetButtonPrice  :TSetButtonPrice   read FOnSetButtonPrice   write FOnSetButtonPrice  ;
    property OnSetButtonToggle :TSetButtonToggle  read FOnSetButtonToggle  write FOnSetButtonToggle ;
    property OnSetButtonOnClick:TSetButtonOnClick read FOnSetButtonOnClick write FOnSetButtonOnClick;
    property OnGetButtonOnClick:TGetButtonOnClick read FOnGetButtonOnClick write FOnGetButtonOnClick;
    property OnSaveCurrentState:TSaveCurrentState read FOnSaveCurrentState write FOnSaveCurrentState  ;
    property OnSetTitle        :TSetTextItem      read FOnSetTitle         write FOnSetTitle        ;
    property OnSetPrompt       :TSetTextItem      read FOnSetPrompt        write FOnSetPrompt       ;
    property OnSetPMessage     :TSetTextItem      read FOnSetPMessage      write FOnSetPMessage     ;
    property OnSetTransactions :TSetTextItem      read FOnSetTransactions  write FOnSetTransactions ;
    property OnSetAccounts     :TSetTextItem      read FOnSetAccounts      write FOnSetAccounts     ;
    property OnSetFormData     :TSetFormData      read FOnSetFormData      write FOnSetFormData     ;
    property OnSetScale        :TSetTextItem      read FOnSetScale         write FOnSetScale        ;
    property OnSetBitMap       :TSetBitMap        read FOnSetBitMap        write FOnSetBitMap       ;
    property OnDisplayInstruct :TDisplayInstruct  read FOnDisplayInstruct  write FOnDisplayInstruct ;
    property OnModalDialog :TModalDialogBox  read FOnModalDialog  write FOnModalDialog ;
    property EODWarning        :TEODWarning read FEODWarning write FEODWarning;
    property OnReportPreview   :TReportPreview read FOnReportPreview write FOnReportPreview;
    property MaxItems:Integer read FMaxItems write FMaxItems;
    property Quantity:Integer read FQuantity write FQuantity;
    property TxnLogParent:THandle write SetTxnLogParent;
    property GroupSuffix:String read FGroupSuffix write FGroupSuffix;
    property User        :String  read FUser        write SetUser       ;
    property RealUser    :String  read FRealUser    write FRealUser      ;
    property Office      :String  read FOffice      write SetOffice     ;
    property Workstation :String  read FWorkstation write SetWorkstation;
    property OnProgress:TOnProgress read FOnProgress write FOnProgress;
    //property NetManager    :INetManager     read GetNetManager   ;
    property NetManager    :INetUser      read GetNetManager   ;
    //property NetUser       :INetUser        read GetNetUser      ;
    property TransactionLog:ITransactionLog read GetTxnLog       ;
    property Period        :IPeriod         read GetPeriod       ;
    property TxnLog        :ITransactionLog read GetTxnLog       ;
    property CompMan       :ICompMan        read GetCompMan      ;
    property Stock         :IStock          read GetStock        ;
    property PictureServer :IPictureServer  read GetPictureServer;
    property LabelPr       :IDevice         read GetLabelPr      ;
    property TrackedMail   :IMailItemLog    read GetTrackedMail  ;
    property Counter       :IDevice         read GetCounter      ;
    property Scale         :IDevice         read GetScale        ;
    property ReceiptSlip   :IDevice         read GetReceiptSlip  ;
    property OCR           :IDevice         read GetOCR          ;
    property OfficeInfo    :IDevice         read GetOfficeInfo   ;
    property CustDisp      :IDevice         read GetCustDisp     ;
    property ExtBarCode    :IDevice         read GetExtBarCode   ;
    property Translator    :ITranslate      read GetTranslator   ;
    property HookUp        :IHookUp         read GetHookUp       ;
  end;
  TUICompExec = Class(TComponent)
  private
    FUserGroup  :String;
    FWorkStationGroup:String;
    FQuantity   :Integer;
    FMaxItems   :Integer;
    FGroupSuffix:String;
    FOnGetButtonRef    :TGetButtonRef;
    FOnGetFormIndex    :TGetFormIndex;
    FOnGetButtonIndex  :TGetButtonIndex;
    FOnSetButtonBitMap :TSetButtonBitMap;
    FOnSetButtonCaption:TSetButtonCaption;
    FOnSetButtonPrice  :TSetButtonPrice;
    FOnSetButtonToggle :TSetButtonToggle;
    FOnSetButtonOnClick:TSetButtonOnClick;
    FOnGetButtonOnClick:TGetButtonOnClick;
    FOnSaveCurrentState:TSaveCurrentState;
    FOnSetTitle        :TSetTextItem;
    FOnSetPrompt       :TSetTextItem;
    FOnSetPMessage     :TSetTextItem;
    FOnSetTransactions :TSetTextItem;
    FOnSetAccounts     :TSetTextItem;
    FOnSetFormData     :TSetFormData;
    FOnSetScale        :TSetTextItem;
    FOnSetBitMap       :TSetBitMap;
    FOnDisplayInstruct :TDisplayInstruct;
    FOnProgress:TOnProgress;
    FOnModalDialog:TModalDialogBox;
    function GetTxnLog:ITransactionLog;
    function GetWorkStationGroup:String;
    function GetUserGroup  :String;
    function GetWorkStation:String;
    function GetOffice     :String;
    function GetUser       :String;
    function GetGroupSuffix:String;
    function GetMaxItems   :Integer;
    function GetQuantity   :Integer;
    procedure SetWorkStationGroup(Value:String);
    procedure SetUserGroup  (Value:String);
    procedure SetWorkStation(Value:String);
    procedure SetOffice     (Value:String);
    procedure SetUser       (Value:String);
    procedure SetGroupSuffix(Value:String);
    procedure SetMaxItems   (Value:Integer);
    procedure SetQuantity   (Value:Integer);
    procedure SetTxnLogParent(Value:Integer);
    procedure SetDontTrigger(Value:Boolean);
  protected
    function GetButtonRef(Index:Integer):TControl;
    procedure Progress(Title:String;Min,Max,Pos:Integer);
    function GetFormIndex:Integer;
    function GetButtonIndex(Button:TControl):Integer;
    function GetButtonOnClick(Button:TControl):TNotifyEvent;
    procedure SetButtonBitMap (Button:TControl;var BitMap :TBitMap );
    procedure SetButtonCaption(Button:TControl;Caption:String  );
    procedure SetButtonPrice  (Button:TControl;Value:Currency);
    procedure SetButtonToggle (Button:TControl;State:Integer);
    procedure SetButtonOnClick(Button:TControl;Handler:TNotifyEvent);
    procedure SetTitle   (Caption:String);
    procedure SaveCurrentState(Restore:Boolean);
    procedure SetPrompt  (Caption:String);
    procedure SetPMessage(Caption:String);
    procedure SetTransactions(Caption:String);
    procedure SetAccounts(Caption:String);
    procedure SetFormData(Caption:String;FlagError,NewForm,DontUpdate:Boolean);
    procedure SetBitMap(BitMap:TBitMap);
    procedure DisplayInstruct(Text,BitMap:String);
    procedure ModalDialog(PType:TPType;Text,DlgPrompt,DlgHint:String;B1,B2,B3:TControl;B1C,B2C,B3C:String);
    procedure SetScale(Reading:String);
    function GetCurrentExec:String;
  public
    CompExec:TCompExec;
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure RefreshUI;
    procedure Execute(Name:String;CancelFirst:Boolean);
    procedure ExecuteWith(Name,Data:String);
    function  Translate(Value: String):String;
    procedure SetTrigger(Value:String);
    procedure FireTrigger(Value:String);
//    function  GetBitmap(Value:String):TBitMap;
    procedure Cancel;
    procedure CancelToTop;
    procedure SetKeyHit;
    property TxnLogParent:Integer write SetTxnLogParent;
    function TranslateString(Component,Text:String;LangID,Index,TType:Integer):String;
    function FormDataChanged(Value:String):Boolean;
    function  GetPictureFromServer(Value:String):TBitMap;
    procedure SelectAccount(AccountGroup:String);
    procedure PutBack;
    procedure SetTranslationOn(Value:Boolean);
    function  GetTranslationOn:Boolean;
    property TriggerValue:String write SetTrigger;
    property User        :String  read GetUser        write SetUser       ;
    property Office      :String  read GetOffice      write SetOffice     ;
    property Workstation :String  read GetWorkstation write SetWorkstation;
    property TransactionLog:ITransactionLog read GetTxnLog;
    property CurrentExec :String read GetCurrentExec;
    property WorkStationGroup :String  read GetWorkStationGroup write SetWorkStationGroup;
    property UserGroup   :String  read GetUserGroup   write SetUserGroup  ;
    property TranslationOn :Boolean read GetTranslationOn write SetTranslationOn;
    property DontTrigger    :Boolean write SetDontTrigger;

  published
    property OnGetButtonRef    :TGetButtonRef     read FOnGetButtonRef     write FOnGetButtonRef    ;
    property OnGetFormIndex    :TGetFormIndex     read FOnGetFormIndex     write FOnGetFormIndex    ;
    property OnGetButtonIndex  :TGetButtonIndex   read FOnGetButtonIndex   write FOnGetButtonIndex  ;
    property OnSetButtonBitMap :TSetButtonBitMap  read FOnSetButtonBitMap  write FOnSetButtonBitMap ;
    property OnSetButtonCaption:TSetButtonCaption read FOnSetButtonCaption write FOnSetButtonCaption;
    property OnSetButtonPrice  :TSetButtonPrice   read FOnSetButtonPrice   write FOnSetButtonPrice  ;
    property OnSetButtonToggle :TSetButtonToggle  read FOnSetButtonToggle  write FOnSetButtonToggle ;
    property OnSetButtonOnClick:TSetButtonOnClick read FOnSetButtonOnClick write FOnSetButtonOnClick;
    property OnGetButtonOnClick:TGetButtonOnClick read FOnGetButtonOnClick write FOnGetButtonOnClick;
    property OnSetTitle        :TSetTextItem      read FOnSetTitle         write FOnSetTitle        ;
    property OnSaveCurrentState:TSaveCurrentState read FOnSaveCurrentState write FOnSaveCurrentState;
    property OnSetPrompt       :TSetTextItem      read FOnSetPrompt        write FOnSetPrompt       ;
    property OnSetPMessage     :TSetTextItem      read FOnSetPMessage      write FOnSetPMessage     ;
    property OnSetTransactions :TSetTextItem      read FOnSetTransactions  write FOnSetTransactions ;
    property OnSetAccounts     :TSetTextItem      read FOnSetAccounts      write FOnSetAccounts     ;
    property OnSetFormData     :TSetFormData      read FOnSetFormData      write FOnSetFormData     ;
    property OnSetScale        :TSetTextItem      read FOnSetScale         write FOnSetScale        ;
    property OnSetBitMap       :TSetBitMap        read FOnSetBitMap        write FOnSetBitMap       ;
    property OnDisplayInstruct :TDisplayInstruct  read FOnDisplayInstruct  write FOnDisplayInstruct ;
    property OnModalDialog     :TModalDialogBox   read FOnModalDialog      write FOnModalDialog     ;
    property OnProgress        :TOnProgress       read FOnProgress         write FOnProgress        ;
    
    property GroupSuffix :String  read GetGroupSuffix write SetGroupSuffix;
    property MaxItems    :Integer read GetMaxItems    write SetMaxItems   ;
    property Quantity    :Integer read GetQuantity    write SetQuantity   ;
  end;       
  
var
   HookUp:IHookUp;
   ServerName:String;
   InHotMenu:Boolean;
   
procedure Register;
function ValidInstall:Boolean;

//function LockWorkStation:BOOL; stdcall; external 'user32.dll' name 'LockWorkStation';
  
implementation
uses
   ComServ2;
   
function ValidInstall:Boolean;
var
   CompStr:String;
const
   ValidSystem:Boolean = False;
begin
   if not ValidSystem then
   begin
      CompStr:=IntToHex(CalcCCITTCRC(GetGPCSRegValues('OfficeInfo','')),8);
      if GetGPCSRegString('','{FBAE2919-024F-44A5-9677-76EA42DA0C53}','0') = '1' then
         SetGPCSRegString('','OfficeInfo',CompStr);
      ValidSystem:=GetGPCSRegString('','OfficeInfo','') = CompStr;
   end;
   Result:=ValidSystem;
end;

//function TakeOffQuotes(Text:String):String;
//begin
//   if (Length(Text) > 1) and (Text[1] = '"') and (Text[Length(Text)] = '"') then
//      Text:=Copy(Text,2,Length(Text)-2);
//   Result:=Text;
//end;

{TCompExec}
procedure TCompExec.DefaultHandler(var Message);
begin
  with TMessage(Message) do
     if WindowHandle <> 0 then
        Result:=CallWindowProc(@DefWindowProc,WindowHandle,Msg,wParam,lParam);
end;
procedure TCompExec.WndProc(var Message: TMessage);
begin
  try             
    Dispatch(Message);
  except
      on E:Exception do RaiseException(8,E);
  end;
end;
function EnableAutoDial(State:Boolean):Boolean;
var
  Registry:TRegistry;
  BDBuffer:array[0..3] of Byte;
begin
  Result:=True; // default to Enabled for Error conditions
  Registry:=TRegistry.Create;
  try
    with Registry do
    begin
      RootKey:=HKEY_CURRENT_USER;
      if (OpenKey('Software\Microsoft\Windows\CurrentVersion\Internet Settings',False)) then
      begin
        If GetDataType('EnableAutoDial') <> rdBinary  then
        begin
          DeleteValue('EnableAutoDial');//check in case written as integer
          BDBuffer[1] := 0; BDBuffer[2] := 0; BDBuffer[3] := 0;
        end
        else
        begin
          ReadBinaryData('EnableAutoDial',BDBuffer,SizeOf(BDBuffer));
          if BDBuffer[0] = 1 then Result:=True
          else Result := False;
        end;

        if State then BDBuffer[0]:=1
        else BDBuffer[0]:=0;
        WriteBinaryData('EnableAutoDial',BDBuffer,SizeOf(BDBuffer));
        CloseKey;
      end;  //if openkey
    end;  //with registry
  finally
   Registry.Free;
  end;
end;
//function TCompExec.GetNetManager:INetManager;
function TCompExec.GetNetManager:INetUser;
begin
   if FNetManager = nil then
   begin
      try
         //FNetManager:=CreateOleObject('Umanager.NetManager') as INetManager;
         FNetManager:=CreateOleObject('UserManager.NetUser') as INetUser;
      except
         //on E:Exception do RaiseError($80,0,0,E.Message+' No NetManager');
         on E:Exception do RaiseError($80,0,0,E.Message+' No NetUser');
      end;
   end;
   Result:=FNetManager;
end;

//function TCompExec.GetNetUser:INetUser;
//begin
//   if FNetUser = nil then
//   begin
//      try
//         FNetUser:=CreateOleObject('Umanager.NetUser') as INetUser;
//      except
//         on E:Exception do RaiseError($80,0,0,E.Message+' No NetUser');
//      end;
//   end;
//   Result:=FNetUser;
//end;
function TCompExec.GetPeriod:IPeriod;
begin
   if FPeriod = nil then FPeriod:=CreatePeriod;
   Result:=FPeriod;
end;
function TCompExec.GetTxnLog:ITransactionLog;
begin
   if FTxnLog = nil then
   begin
      try
         FTxnLog:=CreateTransactionLog;
         if FTxnLog <> nil then
         begin
            FTxnLog.SetEventSink(Self);
            FTxnLog.Hook:=HookUp;
         end;
      except
         on E:Exception do RaiseError($80,0,0,E.Message+' No TxnLog');
      end;
   end;
   Result:=FTxnLog;
end;        
function TCompExec.GetCompMan:ICompMan;
begin
   if FCompMan = nil then
   begin
      try
         FCompMan:=CreateCompMan;
      except
         on E:Exception do RaiseError($80,0,0,E.Message+' No CompMan');
      end;
   end;
   Result:=FCompMan;
end;
function TCompExec.GetStock:IStock;
var
   I:Integer;
begin
   if FStock = nil then
   begin
      try
         I:=0;
         while (not Application.Terminated)
         and IsServiceUsingStock 
         and (I < 20) do
         begin
            Sleep(1000);
            Inc(I);
            Application.ProcessMessages;
         end;
         FStock:=CreateStock;
      except
         on E:Exception do RaiseError($80,0,0,E.Message+' No Stock');
      end;
   end;
   Result:=FStock;
end;
function TCompExec.GetPictureServer:IPictureServer;
begin
   if FPictureServer = nil then
   begin
      try
         FPictureServer:=CreatePictureServer;
      except
         on E:Exception do RaiseError($80,0,0,E.Message+' No PictureServer');
      end;
   end;
   Result:=FPictureServer;
end;
function TCompExec.GetLabelPr:IDevice;
begin
   if FLabelPr = nil then
   begin
      try
         if GetGPCSRegString('DeviceEnabled','LabelPr','0') = '1' then
            FLabelPr:=CreateLabelDevice;
         if FLabelPr <> nil then
         begin
            FLabelPr.WriteDevice(dcInitialise,'',0);
         end;
      except
         on E:Exception do RaiseError($80,0,0,E.Message+' No LabelPr Device');
      end;
   end;
   Result:=FLabelPr;
end;
function TCompExec.GetTrackedMail:IMailItemLog;
begin
   if FTrackedMail = nil then
   begin
      try
         if GetGPCSRegString('DeviceEnabled','TrackedMail','0') = '1' then
            FTrackedMail:=CreateTrackedMailLog;      
         if FTrackedMail <> nil then
         begin
            FTrackedMail.User       :=FUser       ;
            FTrackedMail.Office     :=StrToIntDef(FOffice     ,9999);
            FTrackedMail.Workstation:=StrToIntDef(FWorkstation,99);
         end;
      except
         on E:Exception do RaiseError($80,0,0,E.Message+' No TrackedMail');
      end;
   end;
   Result:=FTrackedMail;
end;
function TCompExec.GetCounter:IDevice;
begin
   if FCounter = nil then
   begin
      try
         FCounter:=CreateCounterDevice;
         if FCounter <> nil then
         begin
            FCounter.WriteDevice(dcInitialise,'',0);
         end;
      except
         on E:Exception do RaiseError($80,0,0,E.Message+' No Counter Device');
      end;
   end;
   Result:=FCounter;
end;
function TCompExec.GetScale:IDevice;
begin
   if FScale = nil then
   begin
      try
         if GetGPCSRegString('DeviceEnabled','Scale','1') = '1' then
            FScale:=CreateScaleDevice;
         if FScale <> nil then
         begin
            FScale.WriteDevice(dcInitialise,'',0);
         end;
      except
         on E:Exception do RaiseError($80,0,0,E.Message+' No Scale Device');
      end;
   end;
   Result:=FScale;
end;
function TCompExec.GetReceiptSlip:IDevice;
begin
   if FReceiptSlip = nil then
   begin
      try
         if GetGPCSRegString('DeviceEnabled','Receipt','1') = '1' then
            FReceiptSlip:=CreateReceiptDevice;
         if FReceiptSlip <> nil then
         begin
            FReceiptSlip.SetEventSink(Self);
            FReceiptSlip.WriteDevice(dcInitialise,'',0);
         end;
      except
         on E:Exception do RaiseError($80,0,0,E.Message+' No ReceiptSlip Device');
      end;
   end;
   Result:=FReceiptSlip;
end;
function TCompExec.GetOCR:IDevice;
begin
   if FOCR = nil then
   begin
      try
         if GetGPCSRegString('DeviceEnabled','OCR','0') = '1' then
            FOCR:=CreateOCRDevice;
         if FOCR <> nil then
         begin
            FOCR.SetEventSink(Self);
            FOCR.WriteDevice(dcInitialise,'',0);
         end;
      except
         on E:Exception do RaiseError($80,0,0,E.Message+' No OCR Device');
      end;
   end;
   Result:=FOCR;
end;
function TCompExec.GetOfficeInfo:IDevice;
begin
   if FOfficeInfo = nil then
   begin
      try
         if GetGPCSRegString('DeviceEnabled','OfficeInfo','0') = '1' then
            FOfficeInfo:=CreateOfficeInfoDevice;  
         if FOfficeInfo <> nil then
         begin
            FOfficeInfo.WriteDevice(dcInitialise,'',0);
         end;
      except
         on E:Exception do RaiseError($80,0,0,E.Message+' No OfficeInfo Device');
      end;
   end;
   Result:=FOfficeInfo;
end;
function TCompExec.GetCustDisp:IDevice;
begin
   if FCustDisp = nil then
   begin
      try
         if GetGPCSRegString('DeviceEnabled','CustDisp','0') = '1' then
            FCustDisp:=CreateCustDispDevice;
         if FCustDisp <> nil then
         begin
            FCustDisp.WriteDevice(dcInitialise,'',0);
            FCustDisp.WriteDevice(dcRawData,'"' + GetGPCSRegString('DeviceSetup\CustDisp', 'Idle Line 1', '') +  '","'
                                               + GetGPCSRegString('DeviceSetup\CustDisp', 'Idle Line 2', '') +  '"',0);

         end;                                         
      except
         on E:Exception do RaiseError($80,0,0,E.Message+' No CustDisp Device');
      end;
   end;
   Result:=FCustDisp;
end;
function TCompExec.GetExtBarCode:IDevice;
begin
   if FExtBarCode = nil then
   begin
      try
         if GetGPCSRegString('DeviceEnabled','ExtBarCode','0') = '1' then
            FExtBarCode:=CreateExtBarCodeDevice;
         if FExtBarCode <> nil then
         begin
            FExtBarCode.SetEventSink(Self);
            FExtBarCode.WriteDevice(dcInitialise,'',0);
         end;
      except
         on E:Exception do RaiseError($80,0,0,E.Message+' No ExtBarCode Device');
      end;
   end;
   Result:=FExtBarCode;
end;
function TCompExec.GetTranslator:ITranslate;
begin
   if FTranslator = nil then
   begin
      try
         if HookUp <> nil then
            FTranslator:=HookUp.Translate
         else
            FTranslator:=CreateTranslator;
            
         if GetGPCSRegString('Language','UpdateTable','Y') = 'Y' then
            FTranslator.SaveOnClose:=True;
            
      except
         on E:Exception do RaiseError($80,0,0,E.Message+' No Translator');
      end;
   end;
   Result:=FTranslator;
end;
function TCompExec.GetHookUp:IHookUp;
begin
   if FHookUp = nil then
   begin
      try
         if FServerName = GetLocalMachineName then
            FHookUp:=CreateHookUp
         else
            FHookUp:=CreateRemoteHookUp(FServerName);
      except
         on E:Exception do RaiseError($80,0,0,E.Message+' No HookUp');
      end;
   end;
   Result:=FHookUp;
end;
procedure TCompExec.Activate;
var
   TryAgain:Boolean;
begin         
   try
      Exiting:=False;
      ReferenceDataList := TPackStringList.Create;
      UnderRemoteControl:=False;
      ScaleReading:=-1;
      Compressor:=TCompressor.Create;
      ExecList:=TPackStringList.Create;
      EnableAutoDial(False);
      FServerName:=GetGPCSRegString('','ServerName',GetLocalMachineName);
      SaveList:=TPackStringList.Create;
      ItemList:=TPackStringList.Create;
      WindowHandle:=AllocateHWnd(WndProc);
      DontRePaint:=False;
//      GroupSuffix:='...';

      TryAgain:=True;
      while TryAgain do
      begin
         try
            GetCompMan;
            GetPeriod;
            GetReceiptSlip;
            GetCustDisp;
            GetScale;
            GetStock;
            Stock.ClearTempAdjustments('All');
            TryAgain:=False;
         except
            on E:Exception do 
            begin
               RaiseGUIDException('{36962909-786A-4744-9334-38F2D9BD7B15}',E);
               FCompMan:=nil;
               FReceiptSlip:=nil;
               FCustDisp:=nil;
               FScale:=nil;
               FStock:=nil;
            end
         end;
      end;
//      GetHookUp;
//      GetTranslator;
//      GetTxnLog;
//      GetOCR;
//      GetTrackedMail;
//      GetLabelPr;
//      GetScale;
//      GetOfficeInfo;
//      GetExtBarCode;
//      GetCustDisp;
//      GetPictureServer;
   except
      on E:Exception do RaiseGUIDException('{F76A213F-B1FA-4FB1-AC30-9D40D2FCBAEF}',E);
   end;
   FinishedInitialise:=True;
end;
procedure TCompExec.Initialize;
begin
   Exiting:=False;
   FinishedInitialise:=False;
   try
      _AddRef;
   except
      on E:Exception do RaiseException(9,E);
   end;
end;
procedure Log(S,FileName:String);
var
   SL:TStringList;
begin
   SL:=TStringList.Create;
   if FileExists(FileName) then 
      SL.LoadFromFile(FileName);
   while SL.Count > 200 do SL.Delete(200);
   SL.Insert(0,S);
   SL.SaveToFile(FileName);
   SL.Free;
end;
procedure TCompExec.CloseAllLinks;
//const
//  Done:Boolean = False;
begin
//   if Done then Exit;
//   Done:=True;
   
   try
//      PostQuitMessage(1);
      Log('CloseAllLinks','C:\Shutdown.log');
      EnableAutoDial(True);
      Log('EnableAutoDial','C:\Shutdown.log');
      if Item <> nil then  
         Item.TerminateExecute(TxnLog);
      Log('Item.TerminateExecute','C:\Shutdown.log');
      Application.ProcessMessages;
      Item:=nil;
      Log('Item:=nil','C:\Shutdown.log');
      Application.ProcessMessages;
      if WindowHandle <> 0 then DeAllocateHWnd(WindowHandle);
      Log('DeAllocateHWnd(WindowHandle)','C:\Shutdown.log');
      WindowHandle:=0;
      try FPeriod:=nil; except end;
      try FNetManager:=nil; except end;
      try FPictureServer:=nil; except end;
      Log('FPeriod:=nil','C:\Shutdown.log');
      if FReceiptSlip <> nil then
      begin
         FReceiptSlip.WriteDevice(dcShutDown,'',0);
         FReceiptSlip:=nil;
      end;           
      Log('FReceiptSlip:=nil','C:\Shutdown.log');
      if FCounter <> nil then
      begin
         FCounter.WriteDevice(dcShutDown,'',0);
         FCounter:=nil;
      end;
      Log('FCounter:=nil','C:\Shutdown.log');
      if FScale <> nil then
      begin
         FScale.WriteDevice(dcShutDown,'',0);
         FScale:=nil;
      end;           
      Log('FScale:=nil','C:\Shutdown.log');
      if FOCR <> nil then
      begin
         FOCR.WriteDevice(dcShutDown,'',0);
         FOCR:=nil;
      end;
      Log('FOCR:=nil','C:\Shutdown.log');
      Application.ProcessMessages;
      if FLabelPr <> nil then
      begin
         FLabelPr.WriteDevice(dcShutDown,'',0);
         FLabelPr:=nil;
      end;
      Log('FLabelPr:=nil','C:\Shutdown.log');
      FTrackedMail:=nil;
      if FOfficeInfo <> nil then
      begin
         FOfficeInfo.WriteDevice(dcShutDown,'',0);
         FOfficeInfo:=nil;
      end;           
      Log('FOfficeInfo:=nil','C:\Shutdown.log');
      if FCustDisp <> nil then
      begin
         FCustDisp.WriteDevice(dcShutDown,'',0);
         FCustDisp:=nil;
      end;
      Log('FCustDisp:=nil','C:\Shutdown.log');
      FTranslator:=nil;
      if ItemList <> nil then
         ItemList.Free;
      Log('ItemList.Free','C:\Shutdown.log');
      ItemList:=nil; 
      if SaveList <> nil then
      begin
         EmptySaveList;
         SaveList.Free;
      end;
      Log('SaveList.Free','C:\Shutdown.log');
      Application.ProcessMessages;
      SaveList:=nil; 
      FTxnLog:=nil;
      FStock:=nil;
      FHookUp:=nil;
      Log('FHookUp:=nil;','C:\Shutdown.log');
      if Compressor <> nil then
      begin
         Compressor.Free;
         Compressor:=nil;
      end;
      Log('Compressor:=nil;','C:\Shutdown.log');
      if ExecList <> nil then
      begin
         ExecList.Free;
      end;
      Log('ExecList.Free;','C:\Shutdown.log');
      try FCompMan.LoadComponent('Empty'); except end;
      Log('LoadComponent(''Empty'')','C:\Shutdown.log');
      FCompMan:=nil;         
      Log('FCompMan:=nil','C:\Shutdown.log');
   except      
      on E:Exception do RaiseException(10,E);
   end;
end;
destructor TCompExec.Destroy;
begin
   Exiting:=True;
  //clean up any reference data list and objects
  try
     If ReferenceDataList <> nil then
     begin
       try
         While ReferenceDataList.Count > 0 do
         begin
           If ReferenceDataList.Objects[ReferenceDataList.Count-1] <> nil then
             ReferenceDataList.Objects[ReferenceDataList.Count-1].Free;
           ReferenceDataList.Delete(ReferenceDataList.Count-1);
         end;
       finally
         ReferenceDataList.Free;
       end;
     end;
  except
  end;
  
  inherited Destroy;
end;
function TCompExec.Get_User:WideString;
begin
   Result:=FUser;
end;
function TCompExec.Get_Office:Integer;
begin
   Result:=StrToIntDef(FOffice,0);
end;
function TCompExec.Get_Workstation:Integer;
begin
   Result:=StrToIntDef(FWorkstation,0);
end;
procedure TCompExec.Trigger(const Data: WideString);
var
   Trigg:WideString;
begin
   if not FinishedInitialise then Exit;
   if DontTrigger then Exit;
   case Data[1] of
      '^' : if Item <> nil then
            begin
               try
                  if ScaleReading <> -1 then
                     TriggerValue:=IntToStr(ScaleReading)
                  else
                     TriggerValue:=Copy(Data,2,Length(Data)-2);
                  LastScaleReading:=StrToIntDef(TriggerValue,-1);
                  Trigg:=IntToStr(LastScaleReading);
                  DontUpdate:=True;
                  if Item.NeedsWeight then Item.TriggerValue(tsScale,Trigg);
                  DontUpdate:=False;
                  if (LastScaleReading >= 0) and (LastScaleReading < 99999) then
                     OnSetScale(TriggerValue)
                  else
                     OnSetScale('NONE');
                except
                   on  E:Exception do
                      RaiseGUIDException('{FECCFB20-2B6A-4F34-96E0-11B229579649}', E);
                end;
            end;
      '%' : begin
               try
                   TriggerValue:=Data;
                   if CurrentExec = 'Product.MoneyOrder' then
                   begin
                      TriggerValue:=Copy(Data,2,Length(Data)-2);
                      Trigg:=TriggerValue;
                      Item.TriggerValue(tsOCRReader,Trigg);
                   end
                   else
                   begin
                      ItemClicked(OnGetButtonRef(1));
                   end;
                except
                   on  E:Exception do
                      RaiseGUIDException('{7A8FC2CE-B7A8-487F-9196-F947AADC2150}', E);
                end;
            end;
      '*',',',#2,#3 : begin
               try
                  TriggerValue:=Copy(Data,2,Length(Data)-2);
                  Trigg:=TriggerValue;
                  if GetGPCSRegString('System Parameters','TriggerSubProducts','N') = 'Y' then
                     TriggerSubProducts( Trigg );
                  Item.TriggerValue(tsBarCode,Trigg);
                except
                   on  E:Exception do
                      RaiseGUIDException('{C75B23B9-F479-445C-A00A-28ADFB3B9373}', E);
                end;
            end;
      '&' : begin
                try
                  TriggerValue:=Copy(Data,2,Length(Data)-2);
                  Trigg:=TriggerValue;
                  Item.TriggerValue(tsMCRReader,Trigg);
                except
                  on  E:Exception do
                     RaiseGUIDException('{7BF9A605-F86A-4AEB-8D25-176AC385371A}', E);
                end;
            end;
   end;
   TriggerValue:='';
end;
procedure TCompExec.ControlReleased;
begin
end;
procedure TCompExec.EmptySaveList;
var
   I:Integer;
begin
   try
   for I:=0 to SaveList.Count-1 do
      if SaveList.Objects[I] <> nil then TSaveData(SaveList.Objects[I]).Free;
   SaveList.Clear;
   except
      on E:Exception do RaiseException(11,E);
   end;
end;
function TCompExec.CheckStartOfDay(Force:Boolean):Boolean;
var
   State:esState;
   UsrGrpStartofDay : Boolean ;
   SystemName:String;
const
   AlreadyChecking:Boolean = False;
   DateOfLastCheck:Integer = 0;
begin
   Result:=True;
   if AlreadyChecking then Exit;
   AlreadyChecking:=True;
   
   if DateOfLastCheck <> Trunc(Now) then // left running overnight ?
   begin
      DateOfLastCheck:=Trunc(Now);
      Force:=True; // force read of DB
   end;
   
   try
       //not had start of day
      if Force or ((FESState and esStateStarted) <> esStateStarted) then
      begin

          // For Any Country --------------------
         UsrGrpStartofDay := NeedStartOfDay( UserGroup ) ;
         if UsrGrpStartofDay then
         begin
            State:=Period.GetESState(FUser);
            
            if (State = esStateNotFinished) then // add an end of day record
               Period.EndOfDay(FUser);
               
            State:=Period.GetESState(FUser);
            if (State = esStateNotStarted) or (State = esStateNotFinished) then
               Period.StartOfDay(FUser);
         end;
         SystemName:=GetGPCSRegString('','System Name','Tanzania Post');
         if (SystemName = 'Bermuda Post') then
         begin
           if not UsrGrpStartofDay then
           begin
              State:=Period.GetESState(FUser);
              if (State = esStateNotStarted) then
                 Period.StartOfDay(FUser);
           end;
         end
         else if ((SystemName = 'Tanzania Post')) or
                 ((SystemName = 'Uganda Post')) or
                 ((SystemName = 'Botswana Post')) then
         begin
           if UserGroup = 'UGroup.Supervisor' then
           begin
              FUser:='Supervisor';
              Txnlog.User:=FUser;
           end
           else if UserGroup = 'UGroup.Admin' then
           begin
              FUser:='Admin';
              Txnlog.User:=FUser;
           end;

         end;

         if Period <> nil then
         begin
            FESState:=Period.GetESState(FUser);
            case FESState of
               esStateFinished    : begin
                                       if Assigned(FEODWarning) then EODWarning('You have completed End of day',True);
                                    end;
               esStateStarted     : begin
                                       if Assigned(FEODWarning) then EODWarning('',False);
                                    end;
               esStateNotFinished : begin
                                       if Assigned(FEODWarning) then EODWarning('You MUST complete the End of Day Balance for the Previous day',True);
                                    end;
               esStateNotStarted  : begin
                                       if Assigned(FEODWarning) then EODWarning('Please select Start of Day',True);
                                    end;
               esStateStartNewDay : begin
                                       if Assigned(FEODWarning) then EODWarning('You are not working in today''s accounting period',True);
                                    end;
            end;
         end;
      end;
   finally
      AlreadyChecking:=False;
   end;
end;
procedure TCompExec.SetWorkStationGroup(Value:String);
var
   Index:Integer;
begin
   FWorkStationGroup:=Value;
   try
      EmptySaveList;
      SaveList.Clear;
      try
         while not CompMan.Ready do Sleep(500);
         WUGroup:=CompMan.LoadComponent(FWorkStationGroup) as IWUGroup;
      except
         on E:Exception do RaiseError(1,1,1,'CompMan.LoadComponent '+FWorkStationGroup+' '+E.Message);
      end;
      if (WUGroup <> nil) and (FUserGroup <> '') then
      begin
         try
            WUGroup.ApplyGroup(FUserGroup);
         except
            on E:Exception do RaiseError(1,1,1,'WUGroup.ApplyGroup '+FUserGroup+' '+E.Message);
         end;
         ItemList.Clear;
         if Item <> nil then
         begin
            Index:=0;
            Item.CompleteExecute(Index,TxnLog);
            Item:=nil;
         end;
         try
            Execute('','');
         except
            on E:Exception do RaiseError(1,1,1,'WG First Execute Failed '+E.Message);
         end;
      end;
      if Scale <> nil then
         Scale.SetEventSink(Self);
   except      
      on E:Exception do RaiseError(1,1,1,'Loading Workstation Group '+FWorkStationGroup+' '+E.Message);
   end;
end;  
procedure TCompExec.SetUserGroup(Value:String);
var 
   Index:Integer;
   SL:TPackStringList;
const
   FirstTime:Boolean = True;
begin
   try
      EmptySaveList;
      FUserGroup:=Value;
      if (WUGroup <> nil) and (FUserGroup <> '') then
      begin
         WUGroup.ApplyGroup(FUserGroup);
         ItemList.Clear;
         if Item <> nil then
         begin
            Index:=0;
            Item.CompleteExecute(Index,TxnLog);
            Item:=nil;
         end;
         try
            Execute('','');
         except
            on E:Exception do RaiseError(1,1,1,'UG First Execute Failed '+E.Message);
         end;
      end;
   except
      on E:Exception do RaiseError(1,1,1,'Loading User Group '+Value+' '+E.Message);
   end;
   if FirstTime then
   begin
      FirstTime:=False;
      SL:=TPackStringList.Create;
      try
         ReceiptSlip.WriteDevice(dcInitialise,'',1);
         SendReceiptDetails('A');
         ReceiptSlip.WriteDevice(dcShutDown,'',1);
      except
      end;
      SL.Free;
   end;
end;
function TCompExec.CanExecute(GroupName:String):Boolean;
var
  I:Integer;
  Item:IProduct;
  ProductName : String;
begin
   if UnderRemoteControl then
   begin
      Result:=True;
      Exit;
   end;
   Result:=False;
   try
      if (Copy(GroupName,1,5) = 'Group') and (WUGroup <> nil) then
      begin
         for I:=0 to WUGroup.Count-1 do
         begin
            if UpperCase(WUGroup.Item[I]) = UpperCase(GroupName) then
            begin
               Result:=True;
               Exit;
            end;
         end;
      end
      else
      begin
         Result:=True;
         CheckStartOfDay(False);
         ProductName := Copy(GroupName,9,999);
         case FESState of
            esStateFinished    : if GetGPCSRegString('','System Name','Tanzania Post') = 'Bermuda Post' then
                                 begin
                                    if (GroupName = 'Product.StartOfDay')
                                    or ((Copy(CurrentExec,1,8) = 'Product.'))
                                    or ((Copy(GroupName,1,8) <> 'Product.'))
                                    //clerk reports
                                    or (Pos(ProductName, 'RepStamp,RepPOBox,'+
                                                         'RepPrLab,RepSchool,'+
                                                         'RepStock,RepAgency,'+
                                                         'RepDogs,RepPhil,'+
                                                         'RepStockSales,RepIncome') > 0 ) then
                                       Result:=True
                                    else
                                       Result:=False;
                                 end
                                 else 
                                 begin
                                    if ((Copy(GroupName,1,8) = 'Product.'))then
                                       Item:=CompMan.LoadComponent(GroupName) as IProduct
                                    else
                                       Item:=nil;
                                    if Item <> nil then
                                    begin
                                       if Item.AvailableAfterEOD then
                                          Result:=True
                                       else
                                          Result:=False;
                                       Item:=nil;
                                    end
                                    else
                                       Result:=False;
                                 end;
            esStateStarted,
            esStateStartNewDay,
            esStateNotFinished : Result:=True;
            esStateNotStarted  : begin
                                    if (GroupName = 'Product.StartOfDay') or ((Copy(CurrentExec,1,8) = 'Product.')) then
                                       Result:=True
                                    else
                                    begin
                                       if ((Copy(GroupName,1,8) = 'Product.'))then
                                          Item:=CompMan.LoadComponent(GroupName) as IProduct
                                       else
                                          Item:=nil;
                                       if Item <> nil then
                                       begin
                                          if Item.AvailableAfterEOD then
                                             Result:=True
                                          else
                                             Result:=False;
                                          Item:=nil;
                                       end
                                       else
                                          Result:=False;
                                    end;
                                 end;
         end;
      end;
   except
      on E:Exception do RaiseException(14,E);
   end;
end;
function TCompExec.GetBitmap(Value:OleVariant;BType:Boolean):TBitMap;
var
   SStream:TStringStream;
   Compress:TCompress;
begin
   result:=nil;
   if BType then
   begin
      try
         if Value = '' then Exit;
         Compress:=TCompress.Create;
         Value:=StringToBinary(Value);
         Value:=Compress.CompressString(Value);
         Compress.Free;
         SStream:=TStringStream.Create(Value);
         SStream.Position:=0;
         Result:=TBitMap.Create;
         Result.LoadFromStream(SStream);
         SStream.Free;
      except
         on E:Exception do RaiseException(15,E);
      end;
   end
   else
   begin
      if VarIsArray(Value) then
         Result:=Compressor.CreateBitmapFromArray(Value);
   end;
end;  
function GetOS:Integer;
var
  Info: TOSVersionInfoA;
begin
   Info.dwOSVersionInfoSize:=sizeof(Info);
   GetVersionEx(Info);
   Result:=Info.dwMajorVersion*100 + (Info.dwMinorVersion mod 100); 
end;
procedure TCompExec.SetShutdownPrivilege;
var
   ProcHandle:THandle;
   TokHandle:THandle;
   TmpLUID:TLargeInteger;
   TokPriv:TTokenPrivileges;
   TokNew:TTokenPrivileges;
   BufferNeeded:DWord;
begin
   ProcHandle:=GetCurrentProcess;
   OpenProcessToken(ProcHandle,TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,TokHandle);
   LookupPrivilegeValue('','SeShutdownPrivilege',TmpLUID);
   TokPriv.PrivilegeCount:=1;
   TokPriv.Privileges[0].LUID:=TmpLUID;
   TokPriv.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED;
   AdjustTokenPrivileges(TokHandle,False,TokPriv,Sizeof(TokNew),TokNew,BufferNeeded);
end;                  
procedure TCompExec.Shutdown;
begin
   if CustDisp <> nil then
   begin
      CustDisp.WriteDevice(dcInitialise,'',0);
      CustDisp.WriteDevice(dcRawData,'"' + GetGPCSRegString('DeviceSetup\CustDisp', 'Log Off Line 1', '') +  '","'
                                         + GetGPCSRegString('DeviceSetup\CustDisp', 'Log Off Line 2', '') +  '"',0);
      CustDisp.WriteDevice(dcShutdown,'',0);
   end;
   Sleep(1+StrToIntDef(GetGPCSRegString('','Pre-Shutdown Delay In Seconds','0'),0)*1000);
   SetShutdownPrivilege;
   if GetOS < 500  then // NT does not support POWER OFF.
      ExitWindowsEx(EWX_SHUTDOWN,0)
   else
      ExitWindowsEx(EWX_SHUTDOWN or EWX_POWEROFF,0);
   Application.MainForm.Close;
end;             
procedure TCompExec.LogOff;
begin
   Exiting:=True;
   if CustDisp <> nil then
   begin
      CustDisp.WriteDevice(dcInitialise,'',0);
      CustDisp.WriteDevice(dcRawData,'"' + GetGPCSRegString('DeviceSetup\CustDisp', 'Log Off Line 1', '') +  '","'
                                         + GetGPCSRegString('DeviceSetup\CustDisp', 'Log Off Line 2', '') +  '"',0);
      CustDisp.WriteDevice(dcShutdown,'',0);
   end;
   with TRegistry.Create do
   begin
      RootKey:=HKEY_LOCAL_MACHINE;
      if OpenKey('\SOFTWARE\PSL\GPCS\Exit',False) then
      begin
         CloseKey;
         Free;
         WinExec(PChar('c:\CorvusService\RestartService'),SW_HIDE);         
         Application.MainForm.Close;
         Exit;
      end;
      Free;
   end;
   WinExec(PChar('c:\CorvusService\RestartService'),SW_HIDE);
   Sleep(1+StrToIntDef(GetGPCSRegString('','Pre-Shutdown Delay In Seconds','0'),0)*1000);
   SetShutdownPrivilege;
   ExitWindowsEx(EWX_LOGOFF or EWX_FORCE,0);
   Application.MainForm.Close;
end;
procedure TCompExec.Lock;
begin
//   LockWorkstation;
   if CustDisp <> nil then
   begin
      CustDisp.WriteDevice(dcInitialise,'',0);
      CustDisp.WriteDevice(dcRawData,'"' + GetGPCSRegString('DeviceSetup\CustDisp', 'Log Off Line 1', '') +  '","'
                                         + GetGPCSRegString('DeviceSetup\CustDisp', 'Log Off Line 2', '') +  '"',0);
      CustDisp.WriteDevice(dcShutdown,'',0);
   end;
   Sleep(1+StrToIntDef(GetGPCSRegString('','Pre-Shutdown Delay In Seconds','0'),0)*1000);
   SetShutdownPrivilege;  
   ExitWindowsEx(EWX_LOGOFF,0);
   Application.MainForm.Close;
end;
procedure TCompExec.SelectAccount(AccountGroup:String);
var
   SL:TPackStringList;
   RSL:TPackStringList;
   I:Integer;
begin
   try
      if AccountGroup = '' then
      begin
         if Assigned(FOnSaveCurrentState) then FOnSaveCurrentState(True);
         AccountManager:=nil;
      end
      else
      begin
         if AccountManager = nil then
            AccountManager:=HookUp.Accounts;
//            AccountManager:=CreateRemoteAccounts(GetGPCSRegString('','Account ServerName',GetLocalMachineName));
         if AccountManager <> nil then
         begin
            AccountManager.User:=FUser;
            // Saudi 25/06/99
//            if not AccountManager.SelectCurrentPeriod then
//               MainForm.EODWarning.Visible:=True
//            else
//               MainForm.EODWarning.Visible:=False;
            SL:=TPackStringList.Create; 
            RSL:=TPackStringList.Create;
            SL.PackText:=AccountManager.GetAccountDetails(AccountGroup,'');
            if SL.PackText <> '' then
            begin
               for I:=0 to SL.Count-1 do 
               begin
                  RSL.PackText:=SL[I];
//                  if AccountManager.IsAGroup(RSL[0]) then
                     SL[I]:=SL[I]+',"'+AccountGroup+'","IsGroup"'
//                  else
//                     SL[I]:=SL[I]+',"'+AccountGroup+'","NotGroup"';
               end;
               if Assigned(OnSetAccounts) then 
                  OnSetAccounts(SL.PackText);
            end
            else
            begin
               if (AccountGroup = 'Cash Account') and (Assigned(FOnSaveCurrentState)) then 
               begin
                  FOnSaveCurrentState(True);
                  AccountManager:=nil;
               end;
            end;
            SL.Free;
            RSL.Free;
         end;
      end;
   except
      // Raise Error
   end;
end;
procedure TCompExec.Print2x2(const Title,Desc1,Desc2,Office,DataPackText:WideString);
begin
//   PrintForm.print2x2(Title,Desc1,Desc2,Office,DataPackText);
end;
function TCompExec.InternalFunction(FuncName:String):Boolean;
var
   State:esState;
   TimeOut:TDateTime;
begin                                  
   Result:=True;
   if FuncName = 'Cancel' then
      Cancel
   else if FuncName = 'Complete' then
      Restore
   else if FuncName = 'ModalOK' then
   begin
      if Assigned(FOnDisplayInstruct) then FOnDisplayInstruct('***','');
      WaitOnModalDialog:=False;
      ModalDialogKey:='OK';
   end
   else if FuncName = 'ModalCANCEL' then
   begin
      if Assigned(FOnDisplayInstruct) then FOnDisplayInstruct('***','');
      WaitOnModalDialog:=False;
      ModalDialogKey:='CANCEL';
   end
   else if FuncName = 'ModalReturn' then
   begin
      if Assigned(FOnDisplayInstruct) then FOnDisplayInstruct('***','');
   end
   else if FuncName = 'Exit' then
   begin
      if Assigned(FOnModalDialog) then
      begin
         with Translator do
         FOnModalDialog(ptError,
           #1+Translate('Warning')+#1+Translate('This will exit the application and log you off'),
            Translate('Do you want to Exit?'),Translate('Press [F1] to Confirm^Press [F2] to go back to the application'),
            OnGetButtonRef(0),OnGetButtonRef(1),nil,'Exit','Return','');
      end
      else
      begin
         TxnLog.WriteTransaction( '*AppEnd',0,0,0, 0,0,'Application Stop','','','');
         LogOff;
      end;
   end
   else if FuncName = 'LogOff' then
   begin
      TxnLog.WriteTransaction( '*AppEnd',0,0,0, 0,0,'Application Stop','','','');
      LogOff
   end
   else if FuncName = 'Shutdown Workstation' then
   begin
      if Assigned(FOnModalDialog) then
      begin
         if FUser = 'Supervisor' then
         begin
            FOnModalDialog(ptError,
              #1'Severe Warning'#1'This will Shutdown the Office Server'+
              #1'DO NOT PROCEED WITH THIS OPERATION UNLESS THE'#1'OFFICE HAS COMPLETED BUSINESS FOR THE DAY'+
              #1'This operation should only be performed'#1'for maintenance or at the end of the day'+
              #1'prior to switching off the machine'#1'All the Office workstations should be shutdown BEFORE'#1'completing this operation',
               'Do you want to Shutdown?','Press [F1] to Confirm^Press [F2] to go back to the application',
               OnGetButtonRef(0),OnGetButtonRef(1),nil,'Shutdown Workstation','Return','');
         end
         else
         begin
            with Translator do
            FOnModalDialog(ptError,
               #1+Translate('Warning')+'","'+
                   #1+Translate('This will Shutdown this workstation')+
                   #1+Translate('This operation should only be performed')+
                   #1+Translate('for maintenance or at the end of the day,')+
                   #1+Translate('prior to switching off the machine.'),
                   Translate('Do you want to Shutdown?'),
                   Translate('Press [F1] to Confirm^Press [F2] to go back to the application'),
               OnGetButtonRef(0),OnGetButtonRef(1),nil,'Shutdown Workstation','Return','');
         end;
      end
      else
      begin
         TxnLog.WriteTransaction( '*AppEnd',0,0,0, 0,0,'Application Shutdown','','','');
         Shutdown;
      end;
   end
   else if FuncName = 'ShutdownWorkstation' then
   begin
      TxnLog.WriteTransaction( '*AppEnd',0,0,0, 0,0,'Application Shutdown','','','');
      Shutdown
   end
   else if FuncName = 'Shutdown All Workstations' then
   begin
      if Assigned(FOnModalDialog) then
      begin
         if FUser = 'Supervisor' then
         begin
            FOnModalDialog(ptError,
              #1'Severe Warning'#1'This will Shutdown ALL the Office Workstaions'+
              #1'DO NOT PROCEED WITH THIS OPERATION UNLESS THE'#1'OFFICE HAS COMPLETED BUSINESS FOR THE DAY'+
              #1'This operation should only be performed'#1'for maintenance or at the end of the day'+
              #1'prior to switching off the machine'#1'All the Office workstations should be logged off BEFORE'#1'completing this operation',
               'Do you want to Shutdown the Workstations?','Press [F1] to Confirm^Press [F2] to go back to the application',
               OnGetButtonRef(0),OnGetButtonRef(1),nil,'Shutdown All Workstations','Return','');
         end;
      end
      else
      begin
         SendDGram('ShutdownAll');
         if Assigned(FOnDisplayInstruct) then FOnDisplayInstruct('***','');
      end;                         
   end
   else if FuncName = 'ShutdownAllWorkstations' then
   begin
      SendDGram('ShutdownAll');
      if Assigned(FOnDisplayInstruct) then FOnDisplayInstruct('***','');
   end
   else if FuncName = 'Lock Workstation' then
      Lock
   else if FuncName = 'End Customer' then
   begin
      if (TxnLog.Contents = '') or (TxnLog.Total = 0) then
      begin
         Receipt(False);
//         PutBack(CurrentExec);
         if Assigned(FOnDisplayInstruct) then FOnDisplayInstruct('***','');
         if CustDisp <> nil then
         begin
           CustDisp.WriteDevice(dcRawData,'"' + GetGPCSRegString('DeviceSetup\CustDisp', 'Idle Line 1', '') +  '","'
                                               + GetGPCSRegString('DeviceSetup\CustDisp', 'Idle Line 2', '') +  '"',0);
         end;
      end;
   end
   else if FuncName = 'Cancel Customer' then
   begin
      if Assigned(FOnModalDialog) then
      begin
         with Translator do
         FOnModalDialog(ptError,
           #1+Translate('Warning')+#1+Translate('This will clear all the current')+#1+Translate('customer transaction information'),
            Translate('Do you want to Cancel this Customer?'),Translate('Press [F1] to Confirm^Press [F2] to go back to the application'),
            OnGetButtonRef(0),OnGetButtonRef(1),nil,'Cancel Customer','Return','');
      end
      else
      begin
         if CustDisp <> nil then
         begin
           CustDisp.WriteDevice(dcRawData,'"' + GetGPCSRegString('DeviceSetup\CustDisp', 'Idle Line 1', '') +  '","'
                                              + GetGPCSRegString('DeviceSetup\CustDisp', 'Idle Line 2', '') +  '"',0);
         end;
         CancelCustomer;
         PutBack(CurrentExec);
         if Assigned(FOnDisplayInstruct) then FOnDisplayInstruct('***','');
      end;
   end
   else if FuncName = 'CancelCustomer' then
   begin
      CancelCustomer;
      if CustDisp <> nil then
      begin
        CustDisp.WriteDevice(dcRawData,'"' + GetGPCSRegString('DeviceSetup\CustDisp', 'Idle Line 1', '') +  '","'
                                          + GetGPCSRegString('DeviceSetup\CustDisp', 'Idle Line 2', '') +  '"',0);
      end;

      PutBack(CurrentExec);
      if Assigned(FOnDisplayInstruct) then FOnDisplayInstruct('***','');
   end
   else if FuncName = 'View Balance' then
   begin
      if Assigned(FOnSaveCurrentState) then FOnSaveCurrentState(False);
      SelectAccount('Cash Account');
   end
   else if FuncName = 'Copy On Distribution Files' then
   begin
      CopyOnDistributionFiles;
   end
   else if FuncName = 'Clean Screen' then
   begin
      if Assigned(FOnDisplayInstruct) then FOnDisplayInstruct('***','');
   end
   else if FuncName = 'FlipSides' then
   begin
      if Assigned(FOnDisplayInstruct) then FOnDisplayInstruct('****','');
   end
   else if FuncName = 'Help' then
   begin
      if Assigned(FOnDisplayInstruct) then FOnDisplayInstruct('HELP','');
   end
   else if FuncName = 'Information' then
   begin
      if Assigned(FOnDisplayInstruct) then FOnDisplayInstruct('INFO','');
   end
   else if FuncName = 'Cancel' then
   begin
      if Assigned(FOnDisplayInstruct) then FOnDisplayInstruct('CANCEL','');
   end
   else if FuncName = 'Top Menu' then
   begin
      if Assigned(FOnDisplayInstruct) then FOnDisplayInstruct('TOPMENU','');
   end
   else if FuncName = 'End Of Day' then
   begin
      if (GetGPCSRegString('','System Name','Tanzania Post') = 'Tanzania Post') and (FUser = 'Supervisor') then
      begin
         state:=FESState; 
         TimeOut:=Now+1*OneMinute;
         if Period <> nil then
            Period.EndOfDay('Supervisor');
         while (state = FESState) and (Now < TimeOut) do
         begin
            CheckStartOfDay(True);
            Sleep(1000);
         end;
//         Sleep(1000); 
//         CheckStartOfDay(True);
//         FESState:=esStateFinished;
      end
      else
      begin
         state:=FESState;
         TimeOut:=Now+1*OneMinute;
         if Period <> nil then
            Period.EndOfDay(FUser);
         while (state = FESState) and (Now < TimeOut) do
         begin
            CheckStartOfDay(True);
            Sleep(1000);
         end;    
//         Sleep(1000);
//         CheckStartOfDay(True);
//         FESState:=esStateFinished;
      end;
   end
   else if FuncName = 'Receipt' then
   begin
      if (TxnLog.Contents = '') or (TxnLog.Total = 0) then
      begin
         Receipt(True);
//         PutBack(CurrentExec);
         if Assigned(FOnDisplayInstruct) then FOnDisplayInstruct('***','');
         if CustDisp <> nil then
         begin
           CustDisp.WriteDevice(dcRawData,'"' + GetGPCSRegString('DeviceSetup\CustDisp', 'Idle Line 1', '') +  '","'
                                             + GetGPCSRegString('DeviceSetup\CustDisp', 'Idle Line 2', '') +  '"',0);
         end;
      end;
   end
   else
      Result:=False;
end;
procedure TCompExec.Refresh;
begin
   PutBack(CurrentExec);
   if Assigned(FOnDisplayInstruct) then FOnDisplayInstruct('***','');
end;
procedure TCompExec.ExecFromList(List:TStrings);
begin
   InExecFromList:=True;
end;
procedure TCompExec.ItemSelected(Index:Integer);
begin
   InExecFromList:=False;
end;
procedure TCompExec.ExecuteComponent(CompToExec,Data:String);
var
   Index:Integer;
begin
   if (not UnderRemoteControl) and (ScaleReading >= 0) then
      ScaleReading:=-1;
   if (CompToExec <> '') then
   begin
      if InternalFunction(CompToExec) then Exit;
      if not CanExecute(CompToExec) then Exit;
      ItemList.Add(CurrentExec);
      Index:=0;
      Item.CompleteExecute(Index,TxnLog);
      Item:=nil;
      Execute(CompToExec,Data);
   end;
end;
procedure TCompExec.ItemClicked(Sender:TObject);
var
   Index:Integer;
   TIndex:Integer;
   CompToExec:String;
   Msg:TMessage;
begin
   try
      if not Assigned(OnGetButtonIndex) then Exit;
      Index:=OnGetButtonIndex(Sender as TControl);
      if NotifyChild[Index] then
      begin
         Item.NotifyChildClick(Item.Item[Index],Index);
         Exit;
      end;
      if (Item <> nil) and (not Item.CanTerminate) then Exit;
      if InExecFromList then
      begin
         ItemSelected(Index);
         Exit;
      end;
      CompToExec:=Item.Item[Index];
      if InHotMenu then 
      begin
         InHotMenu:=False;
         WMCancelPrevious(Msg);
      end;
      if (CompToExec <> '') then
      begin
         if InternalFunction(CompToExec) then Exit;
         if not CanExecute(CompToExec) then
            Exit;
         ItemList.Add(CurrentExec);
         TIndex:=0;
         Item.CompleteExecute(TIndex,TxnLog);
         Item:=nil;
         Execute(CompToExec,'');
      end;
   except
      on E:Exception do RaiseException(16,E);
   end;
end;  
procedure TCompExec.SetTime(DateTime:TDateTime);
var
   ProcHandle:THandle;
   TokHandle:THandle;
   TmpLUID:TLargeInteger;
   TokPriv:TTokenPrivileges;
   TokNew:TTokenPrivileges;
   BufferNeeded:DWord;
   SystemTime:TSystemTime;
begin
   ProcHandle:=GetCurrentProcess;
   OpenProcessToken(ProcHandle,TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,TokHandle);
   LookupPrivilegeValue('','SeSystemTimeName',TmpLUID);
   TokPriv.PrivilegeCount:=1;
   TokPriv.Privileges[0].LUID:=TmpLUID;
   TokPriv.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED;
   AdjustTokenPrivileges(TokHandle,False,TokPriv,Sizeof(TokNew),TokNew,BufferNeeded);
   DateTimeToSystemTime(DateTime,SystemTime);
   SetLocalTime(SystemTime);
   AdjustTokenPrivileges(TokHandle,False,TokNew,Sizeof(TokPriv),TokPriv,BufferNeeded);
end;
function TCompExec.GetPictureFromServer(Value:String):TBitMap;
var
   BMPString:String;
begin
   Result:=nil;
   BMPString:=PictureServer.Bitmap(Value);
   if BMPString <> '' then
      Result:=GetBitmap(BMPString,True);
end;
function TCompExec.ReferenceData(const Name: WideString):WideString;
var
  SL            : TPackStringList;
  Key           : Word;
  RefIndex      : Integer;
  RefLen        : Integer;
  RefName       : WideString;
  RefValue      : String;
  WMKey         : TWMKey;
//  PDC           : String ;
  ComputerName  : String;
  List:TStringList;
  I:integer;
  TmpStr:String;
begin
  Result  :=  '';
  try
    //PASSWORD
    If LeftOf(UpperCase(Name), 'PASSWORD(') then
    begin
      RefValue := SubString(Name, 'PASSWORD(', ')');
      If (IPControl <> nil) then
      begin
        IPControl.PasswordChar := RefValue[1];
      end;
    end
    //GETNETUSER
    else If LeftOf(UpperCase(Name), 'GETNETUSER(') then
    begin
      With TNetUserStringWrapper.Create do
      begin
        RefValue := SubString(Name, 'GETNETUSER(', ')');
        try
          UserName      := RefValue;
          ComputerName := GetGPCSRegString('','Primary Domain Controller','');
          If  ComputerName = 'None' then ComputerName := '';
          if ComputerName <> '' then
          begin
            if not NetManager.UserExists( ComputerName, UserName) then
               if NetManager.UserExists( '', UserName) then
                  ComputerName := '' ;
          end;
          FullName      := NetManager.GetFullName(ComputerName, UserName);
          Password      := '';
          Description   := NetManager.GetComment(ComputerName, UserName);
          If ComputerName = '' then //no PDC defined
            Groups        := NetManager.GetMemberLocalGroups(ComputerName, UserName)
          else
            Groups        := NetManager.GetMemberGlobalGroups(ComputerName, UserName);
          Result := PackText;
        finally
          Free;
        end;
      end;
    end
    //SETNETUSER
    //else If LeftOf(UpperCase(Name), 'SETNETUSER(') then
    //begin
    //  With TNetUserStringWrapper.Create do
    //  begin
    //    RefValue := SubString(Name, 'SETNETUSER(', ')');
    //    PackText := RefValue;
    //    try
    //      UserName     := RefValue;
    //      ComputerName := GetGPCSRegString('','Primary Domain Controller','');
    //      If  ComputerName = 'None' then ComputerName := '';
    //      Netmanager.AddOrUpdateUser(ComputerName, UserName, FullName, Description, Password, Groups);
    //      Result := PackText;
    //    finally
    //      Free;
    //    end;
    //  end;
    //end
    //SENDCHAR
    else If LeftOf(UpperCase(Name), 'SENDCHAR(') then
    begin
      RefValue := SubString(Name, 'SENDCHAR(', ')');
      Key := Word(STrToInt(RefValue));
      If (IPControl <> nil) then
      begin
        WMKey.CharCode := Key;
        IPControl.WMKeyDown(WMKey);
      end;
    end
    //GETITEMID(MailDomRR,8)
    else If  Copy(Name,1,10) = 'GETITEMID(' then
    begin
      RefName := SubString(Name,'GETITEMID(',',');          //grab counter name to set
      RefValue:= DelimitedString(Name, ',', True);          //grab id length reqd)
      RefValue:= DelimitedString(RefValue, ')', False);     //remove trail )
      Counter.ReadDevice(RefName, RefLen);
      If StrToIntDef(RefName,0) <= 0 then //counter error (global counter failed?)
      begin
        RefName := IntToStr(Abs(StrToInt(RefName)));
        RefName := LeftPad(FWorkstation,2,'0') + LeftPad(RefName,6,'0');
        //mod11 assumes 8 digits
        Result := RefName + Mod11(StrToIntDef(RefName,0))
      end
      else
        //mod11 assumes 8 digits
        Result := LeftPad(RefName,8,'0') + Mod11(StrToIntDef(RefName,0))
    end
    else If  Copy(Name,1,11) = 'GETCOUNTER(' then
    begin
      RefName := SubString(Name,'GETCOUNTER(',')');          //grab counter name to set
      Counter.ReadDevice(RefName, RefLen);
      Result := RefName;
    end
    else If  Copy(Name,1,4) = 'SET(' then
    begin
      RefName := SubString(Name,'SET(',',');                   //grab name to set
      RefValue:= DelimitedString(Name, ',', True);             //grab value
      RefValue:= ReverseDelimitedString(RefValue, ')', FALSE); //remove everything after last bracket
      RefIndex := ReferenceDataList.IndexOf(RefName);
      If RefIndex = -1 then
        ReferenceDataList.AddObject(RefName, TStringObject.Create(RefValue))
      else
      begin
        If ReferenceDataList.Objects[RefIndex] <> nil then
          (ReferenceDataList.Objects[RefIndex] As TStringObject).Value := RefValue
        else
          ReferenceDataList.Objects[RefIndex] := TStringObject.Create(RefValue);
      end;
    end
    else If Copy(Name,1,4) = 'GET(' then
    begin
      RefName := SubString(Name,'GET(',')');            //grab name to get
      RefIndex := ReferenceDataList.IndexOf(RefName);
      If RefIndex > -1 then
      begin
        If ReferenceDataList.Objects[RefIndex] <> nil then
          Result := (ReferenceDataList.Objects[RefIndex] As TStringObject).Value;
      end;
    end
    else if Name = 'Users' then
      Result:=FUsers
{    else if Name = 'ReportNames' then
      ReportsNode:=TReportsNode.Create('Reports',ReportFileName,1);
      ReportsNode.ParseFile(ExtractFilePath(ReportFileName),ReportFileName,1);
      ReportsNode.PutInReportTitles(ProdForm.ReportList.Items);
      ProdForm.ReportList.Sorted:=True;
      ReportsNode.Free;
    else if Name = 'ReportTitles' then
      ReportsNode:=TReportsNode.Create('Reports',ReportFileName,1);
      ReportsNode.ParseFile(ExtractFilePath(ReportFileName),ReportFileName,1);
      ReportsNode.PutInReportTitles(ProdForm.ReportList.Items);
      ProdForm.ReportList.Sorted:=True;
      ReportsNode.Free;}
    else if Name = 'FreshPDCUsers' then
    begin
      ServerName := FNetManager.GETPDC;
      if ServerName = '' then
         result := ''
      else
         Result:=FNetManager.GetUsers(ServerName);
    end
    else if Name = 'UserGroup' then
      Result:=UserGroup
    else if Name = 'ClerkCode' then
      Result:=IntToStr(ClerkCode)
    else if Name = 'ClerkOfficeCode' then
      Result:=IntToStr(ClerkOfficeCode)
    else if Name = 'ClerkLevel' then
      Result:=IntToStr(ClerkLevel)
    else if Name = 'NewFormNext' then
      NewFormNext:=True
    else if Copy(Name,1,8) = 'PASSWORD' then
    begin
      SL:=TPackStringList.Create;
      SL.CommaText:=Name;
      if SL.Count > 2 then
      begin
         NetManager.SetPassword(ServerName, SL[1], SL[2]);
         //NetUser.SetUser(ServerName,SL[1]);
         //NetUser.GetUserInformation;
         //NetUser.Set_Password(SL[2]);
         //NetUser.SetUser(ServerName,FUser);
         //NetUser.GetUserInformation;
      end;
      SL.Free;
    end
    else if LeftOf(UpperCase(Name), 'ADDNEWUSER(') then
    begin
      List := TStringList.Create;

      SL:=TPackStringList.Create;
      SL.CommaText := SubString(Name, 'ADDNEWUSER(', ')');

        //[0]UserName,[1]CentralUserFullName,[2]CentralComment,[3]CentralUserPassword,[4] CentralUserGroup
      try
        try
          ComputerName:= GetLocalMachineName ;
          if ComputerName <> '' then
          begin
            FNetManager.AddOrUpdateUser(ComputerName, SL[0], SL[1], SL[2], SL[3], SL[4]);

            //Using List for passing the data to txnlog in dominfo
            List.Clear;
            List.Add( SL[0] );  // UserName
            List.Add( SL[1] );  // CentralUserFullName
            List.Add( SL[2] );  // CentralComment
            List.Add( SL[3] );  // CentralUserPassword
            List.Add( SL[4] );  // CentralUserGroup
            //List.Add( SL[5] );  // CentralOfficeCode

            FTxnLog.WriteTransaction( '*AddNewUsr',0,0,0, 0,0,'','',SL[5],List.CommaText);
          end;

        finally
          List.Free;
          SL.Free;
        end;
      except
        on e : exception do
          RaiseGUIDError('{90B8BDF8-27E2-479D-88E5-8F36FF01488E}', E.Message);
      end;
    end  //If DELETEUSER
    else if LeftOf(UpperCase(Name), 'DELETEUSER(') then
    begin
      try

         SL:=TPackStringList.Create;
         try
            SL.CommaText := SubString(Name, 'DELETEUSER(', ')');
            // SL[0] Name
            // SL[1] Office
            //RefName := SubString(Name, 'DELETEUSER(', ')');
            ComputerName:= GetLocalMachineName ;
            if ComputerName <> '' then
            begin
              //FNetManager.DeleteUser(ComputerName, RefName);
              FNetManager.AddOrUpdateUser(ComputerName, SL[0], '', '^Delete', '', '');
              FTxnLog.WriteTransaction( '*DelUsr',0,0,0, 0,0,'','',SL[1],SL[0]);
            end;
         finally
            SL.Free;
         end;

      except
        on e : exception do
          RaiseGUIDError('{4B8D9133-CD8C-4AEF-AEED-2C4D3C658BDA}', E.Message);
      end
    end
    else if Name = 'SendReceiptDetails' then
            SendReceiptDetails(GetUniqueID(FOffice,FWorkStation))
    
    else if Name='BROADCASTUSERS' then
    begin

         RefName     := FNetManager.GetPDC();
         ComputerName:= GetLocalMachineName ;
         try
            SL:=TPackStringList.Create;
            List := TStringList.Create;

            if ComputerName <> '' then
            begin

              try
                i:=0;
                SL.CommaText := NetManager.GetUsers(ServerName);
                while i <= SL.Count -1 do
                begin
                   TmpStr := GetGPCSUserGroup( RefName, SL[i], NetManager );
                   if TmpStr = '' then
                      SL.delete(i)
                   else
                   begin
                      List.Clear;
                      List.Add( SL[i] );
                      List.Add( TmpStr );
                      SL[i]:= List.CommaText;
                      inc(i);
                   end;
                end;

                SetUsersBroadCast( SL.CommaText );
                //FNetManager.AddOrUpdateUser(ComputerName, RefName, '', '^', '', '');
                FTxnLog.WriteTransaction( '*BCTUsr',0,0,0, 0,0,'','','',Sl.CommaText);

            finally
               List.Free;
               SL.Free;
            end;
         end;
      except
        on e : exception do
          RaiseGUIDError('{4B8D9133-CD8C-4AEF-AEED-2C4D3C658BDA}', E.Message);
      end;
    end;
  except  //general exception handler
      on e : exception do
        RaiseGUIDError('{47CE5105-4AD1-4FB9-9994-D03EE5EAF9C2}', E.Message);
  end;

end;

function TCompExec.Translate(const Value: WideString):WideString;
var
   RecordList:TPackStringList;
   FieldList :TPackStringList;
   TransList :TPackStringList;
   I:Integer;
   J:Integer;
   OnlyColum:integer;
   StrValue :String;
begin

   // No Translation required for Tan & Bermuda
//   Result:=Value;
//   Exit;
   // No Translation required for Tan & Bermuda

   StrValue:= Value ;
   OnlyColum:=-1;
   RecordList:=TPackStringList.Create;
   FieldList :=TPackStringList.Create;
   TransList :=TPackStringList.Create;
   if Copy( StrValue, 1, 7)='<COLUM:' then
   begin
      i:= Pos( '>', StrValue );
      OnlyColum:= StrToIntDef(Copy( StrValue, 8, i-8 ),-1);
      StrValue := Copy( StrValue, i+1, Length(StrValue)-i );
   end;

   J:=0;
   for I:=1 to Length(StrValue) do
   begin
      if (StrValue[I] = ',') or (StrValue[I] < #32) then
      begin
         J:=1;
         break;
      end;
   end;

   if J = 1 then
      RecordList.PackText:=StrValue
   else
      RecordList.Text:=StrValue;
   if RecordList.Count = 1 then
   begin
      Result:=Translator.Translate(StrValue);
   end
   else
   begin
      TransList.PackText:=RecordList[0];
         for I:=1 to RecordList.Count-1 do
         begin
            FieldList.PackText:=RecordList[I];
            if OnlyColum= -1 then
               for J:=0 to FieldList.Count-1 do
               begin
                  if (TransList.Count > J) and (TransList[J] <> '0') then
                     FieldList[J]:=Translator.Translate(FieldList[J]);
               end
            else
               if OnlyColum < FieldList.Count then
                  FieldList[OnlyColum]:=Translator.Translate(FieldList[OnlyColum]);

            RecordList[I]:=FieldList.PackText;
         end;
      Result:=RecordList.PackText;
   end;
   RecordList.Free;
   FieldList .Free;
   TransList .Free;
end;

procedure TCompExec.DisplayItemInfo(const EventSource: IExecComponent; Index: Integer;BitMap:OleVariant;const Caption: WideString; Price: Currency; State: Integer;Notify,Nested:WordBool);
var
   Button:TControl;
   BMP:TBitMap;
   I,J:Integer;
   CurData:TSaveData;
   ItemName:String;
   ButtonCaption:String;
   BMPOK:Boolean;
begin
   BMP:=nil;
   try
      if (State = BUTTON_ENABLED_UP) or (State = BUTTON_ENABLED_DOWN) then
      begin
         Button:=OnGetButtonRef(Index);
         if Button = nil then Exit;
         if Assigned(FOnSetButtonToggle) then
            FOnSetButtonToggle(Button,State);
         Exit;
      end;
      ButtonCaption:=Caption;
      BMPOK:=True;
      BMP:=GetBitMap(BitMap,False);
      if BMP = nil then
         BMPOK:=False;
      DontRePaint:=False;
      if not Assigned(OnGetButtonRef) then Exit;
      Button:=OnGetButtonRef(Index);
      if Button = nil then Exit;
      ItemName:='';
      if (Index < Item.Count) then
         ItemName:=Item.Item[Index];
      NotifyChild[Index]:=Notify;
//      if (ItemName <> '') and CanExecute(ItemName) then
      if (ItemName <> '') then
         Button.Enabled:=True
      else
         Button.Enabled:=False;
      if (not BMPOK) and (ButtonCaption = '') then
      begin
         if Assigned(FOnSetButtonBitMap ) then FOnSetButtonBitMap (Button,BMP);
         if Assigned(FOnSetButtonCaption) then FOnSetButtonCaption(Button,'' );
         if Assigned(FOnSetButtonPrice  ) then FOnSetButtonPrice  (Button,0  );
         if Assigned(FOnSetButtonToggle ) then FOnSetButtonToggle (Button,BUTTON_DISABLED_TOGGLE);
         if Assigned(FOnSetButtonOnClick) then FOnSetButtonOnClick(Button,nil);
         Button.Enabled:=False;
      end
      else
      begin
         ButtonCaption:=Translator.Translate(ButtonCaption);
         if Copy(ItemName,1,5) = 'Group' then ButtonCaption:=ButtonCaption+GroupSuffix;
         if (Copy(ItemName,1,5) <> 'Group') and (Copy(ItemName,1,7) <> 'Product') then
            BMP:=GetPictureFromServer(ItemName);
         if Assigned(FOnSetButtonBitMap ) then FOnSetButtonBitMap (Button,BMP    );
         if Assigned(FOnSetButtonCaption) then FOnSetButtonCaption(Button,ButtonCaption);
         if Assigned(FOnSetButtonPrice  ) then FOnSetButtonPrice  (Button,Price  );
         if (State and 1) = 1 then
            if Assigned(FOnSetButtonToggle ) then FOnSetButtonToggle (Button,BUTTON_ENABLED_TOGGLE)
         else
            if Assigned(FOnSetButtonToggle ) then FOnSetButtonToggle (Button,BUTTON_DISABLED_TOGGLE);
         if Assigned(FOnSetButtonOnClick) then FOnSetButtonOnClick(Button,ItemClicked);
      end;
      I:=SaveList.IndexOf(CurrentExec);
      if I <> -1 then
      begin
         if SaveList.Objects[I] = nil then
         begin
            SaveList.Objects[I]:=TSaveData.Create;
            CurData:=TSaveData(SaveList.Objects[I]);
            for J:=0 to MaxItems-1 do
            begin
               if CurData.BitMap[J] <> nil then CurData.BitMap[J].Free;
               CurData.BitMap     [J]:=nil;
               CurData.Caption    [J]:='';
               CurData.Price      [J]:=0;
               CurData.BEnabled   [J]:=False;
               CurData.NotifyChild[J]:=False;
               CurData.ToggleClick[J]:=False;
               CurData.IsUp       [J]:=True;
            end;
         end;
         CurData:=TSaveData(SaveList.Objects[I]);
         if CurData <> nil then
         begin
            if CurData.BitMap[Index] <> nil then CurData.BitMap[Index].Free;
            if BMP <> nil then
            begin
               CurData.BitMap[Index]:=TBitMap.Create;
               CurData.BitMap[Index].Assign(BMP);
            end
            else
            begin
               CurData.BitMap[Index]:=nil;
            end;
            CurData.Caption [Index]   :=ButtonCaption;
            CurData.Price   [Index]   :=Price  ;
            CurData.BEnabled[Index]   :=True;
            CurData.NotifyChild[Index]:=NotifyChild[Index];
            CurData.ToggleClick[Index]:=(State and 1) = 1;
            CurData.IsUp       [Index]:=(State and 4) = 4;
         end;              
      end;
   except
      on E:Exception do RaiseException(17,E);
   end;
   if BMP <> nil then
      BMP.Free;
end;   
procedure TCompExec.DisplayInstructions(Style: InstructStyle; const Text:WideString;BitMap:OleVariant);
var
  TS:String;
begin
   TS:=Translator.Translate(Text);
   if Assigned(FOnDisplayInstruct) then FOnDisplayInstruct(TS,BitMap);
end;
function TCompExec.PutBack(Name:String):Boolean;
var
   Index:Integer;
   I:Integer;
   BitMap :TBitMap;
   Caption:String;
   Price  :Currency;
   Button:TControl;
   State:Boolean;
   SaveData:TSaveData;
begin
   IPControl.SetLngBack ;
   Result:=False;
   try
   I:=SaveList.IndexOf(Name);
   if (I <> -1) and (SaveList.Objects[I] <> nil) then
   begin
      SaveData:=TSaveData(SaveList.Objects[I]);
      Result:=True;
      if DontRePaint then Exit;
      for Index:=0 to MaxItems-1 do
      begin
         BitMap :=SaveData.BitMap [Index];
         Caption:=SaveData.Caption[Index];
         Price  :=SaveData.Price  [Index];
         NotifyChild[Index]:=SaveData.NotifyChild[Index];
         State:=SaveData.ToggleClick[Index];
                          
         Button:=OnGetButtonRef(Index);
         if Button = nil then Exit;
         
         Button.Enabled:=SaveData.BEnabled[Index];
         if Button.Enabled then
         begin
            if Assigned(FOnSetButtonOnClick) then FOnSetButtonOnClick(Button,ItemClicked);
         end
         else
         begin
            if Assigned(FOnSetButtonOnClick) then FOnSetButtonOnClick(Button,nil);
         end;
         
         if Assigned(FOnSetButtonBitMap ) then FOnSetButtonBitMap (Button,BitMap);
         if Assigned(FOnSetButtonCaption) then FOnSetButtonCaption(Button,Caption);
         if Assigned(FOnSetButtonPrice  ) then FOnSetButtonPrice  (Button,Price);
         if Assigned(FOnSetButtonToggle ) and (SaveData.IsUp[Index])then FOnSetButtonToggle(Button,BUTTON_ENABLED_TOGGLE);
         if State then
         begin
            if Assigned(FOnSetButtonToggle ) then FOnSetButtonToggle (Button,BUTTON_ENABLED_TOGGLE)
         end
         else
         begin
            if Assigned(FOnSetButtonToggle ) then FOnSetButtonToggle (Button,BUTTON_DISABLED_TOGGLE);
         end;
      end;
      try 
         if Item <> nil then
         begin
            if Assigned(OnSetTitle   ) then OnSetTitle   (Translator.Translate(Item.Title   ));
            if Assigned(OnSetPrompt  ) then OnSetPrompt  (Translator.Translate(Item.Prompt  ));
            if Assigned(OnSetPMessage) then OnSetPMessage(Translator.Translate(Item.PMessage));
         end;
      except
      end;
   end;                   
   except
      on E:Exception do RaiseException(18,E);
   end;
end;  
procedure TCompExec.WMRestorePrevious(var Msg:TMessage);
var
   S:String;
   Index:Integer;
begin
   if (not UnderRemoteControl) and (ScaleReading >= 0) then
      ScaleReading:=-1;
   try                    
      if ItemList.Count = 0 then Exit;
      if (Item <> nil) and (not Item.CanTerminate) then Exit;
      S:=ItemList[ItemList.Count-1];
      ItemList.Delete(ItemList.Count-1);
      Index:=0;
      Item.CompleteExecute(Index,TxnLog);
      Item:=nil;
      CheckStartOfDay(False);
      Execute(S,'');
   except
      on E:Exception do RaiseException(19,E);
   end;
end;  
procedure TCompExec.SwapTo(const ProgID, PassData: WideString);
begin
   try
      RunAfterCancel:=ProgID;
      RunAfterCancelData:=PassData;
      PostMessage(WindowHandle,WM_CANCELPREVIOUS,0,0);
      ReturnedAlready:=True;
   except
      on E:Exception do RaiseException(20,E);
   end;
end;  
function TCompExec.Get_HookUp:IHookUp;
begin
   Result:=HookUp;
end;
procedure TCompExec.Restore; 
begin
   try
      PostMessage(WindowHandle,WM_RESTOREPREVIOUS,0,0);
      ReturnedAlready:=True;
   except
      on E:Exception do RaiseException(20,E);
   end;
end;
procedure TCompExec.WMCancelPrevious(var Msg:TMessage);
var
   S:String;
begin
  if (not UnderRemoteControl) and (ScaleReading >= 0) then
    ScaleReading:=-1;
  try
    if CustDisp <> nil then
    begin
      CustDisp.WriteDevice(dcInitialise,'',0);
      if TxnLog.Total <> 0 then
      begin
        if CustDisp <> nil then
        begin
          CustDisp.WriteDevice(dcRawData,'"Total '
                    + Format(GetGPCSRegString('','Currency Format','$%s'),
                             [CurrToStrF(TxnLog.Total,ffNumber,2)])+'"," "',0);
        end;
      end
      else
      begin
        if CustDisp <> nil then
        begin
          CustDisp.WriteDevice(dcRawData,'"' + GetGPCSRegString('DeviceSetup\CustDisp', 'Idle Line 1', '') +  '","'
                                                     + GetGPCSRegString('DeviceSetup\CustDisp', 'Idle Line 2', '') +  '"',0);
        end;
      end;

      CustDisp.WriteDevice(dcShutdown,'',0);
    end;
    if ItemList.Count = 0 then Exit;
    if (Item <> nil) and (not Item.CanTerminate) then Exit;
    if RunAfterCancel <> '' then
    begin
      try
        if Item <> nil then
          Item.TerminateExecute(TxnLog);
      except
        on E:Exception do RaiseException(121,E);
      end;
      Item:=nil;
      S:=RunAfterCancel;
      RunAfterCancel:='';
//         ExecuteComponent(S,'');
      Execute(S,'');
      if (Item <> nil) and (RunAfterCancelData <> '') then
      begin
        Item.TriggerValue(tsStatusDevice0,RunAfterCancelData);
        RunAfterCancelData:='';
      end;
      Exit;
    end
    else
    begin
      S:=ItemList[ItemList.Count-1];
      ItemList.Delete(ItemList.Count-1);
      try
        if Item <> nil then
          Item.TerminateExecute(TxnLog);
      except
        on E:Exception do RaiseException(121,E);
      end;
      Item:=nil;
      Execute(S,'');
    end;
  except
    on E:Exception do RaiseException(21,E);
  end;
end;

procedure TCompExec.Cancel;
begin
   try
      InHotMenu:=False;
      PostMessage(WindowHandle,WM_CANCELPREVIOUS,0,0);
      ReturnedAlready:=True;
   except
      on E:Exception do RaiseException(22,E);
   end;
end;  
procedure TCompExec.CancelToTop;
var              
   S:String;
begin
   InHotMenu:=False;
   if (not UnderRemoteControl) and (ScaleReading >= 0) then
      ScaleReading:=-1;
   try                           
      if ItemList.Count = 0 then Exit;
      if (Item <> nil) and (not Item.CanTerminate) then Exit;
      S:=ItemList[0];
      ItemList.Clear;
      try
         if Item <> nil then
            Item.TerminateExecute(TxnLog);
      except
         on E:Exception do RaiseException(121,E);
      end;
      Item:=nil;
      Execute(S,'');
   except
      on E:Exception do RaiseException(21,E);
   end;
end;  
function CleanUp(Data:String):String;
var
   SL:TPackStringList;
   LSL:TPackStringList;
   TSL:TPackStringList;
   I:Integer;
begin
   SL :=TPackStringList.Create;
   TSL:=TPackStringList.Create;
   LSL:=TPackStringList.Create;
   SL.PackText:=Data;
   TSL.Add('a'); // 0 E
   TSL.Add('a'); // 1 F
   TSL.Add('a'); // 2 Type
   TSL.Add('a'); // 3 Name
   TSL.Add('a'); // 4 Prompt
   TSL.Add('a'); // 5 Text
   TSL.Add('a'); // 6 Extra
   for I:=0 to SL.Count-1 do
   begin
      LSL.PackText:=SL[I];
      if LSL.Count > 6 then
      begin
         TSL[3]:=LSL[3];
         TSL[5]:=LSL[5];
         SL[I]:=TSL.PackText;
      end;
   end;
   Result:=SL.PackText;
   LSL.Free;
   SL .Free;
   TSL.Free;
end;
procedure TCompExec.SetExecDataValues(Values:String);
var
   VSL:TPackStringList;
   SL:TPackStringList;
   LSL:TPackStringList;
   VLSL:TPackStringList;
   I,J:Integer;
   S:WideString;
   FlagError:WordBool;
begin
   VSL:=TPackStringList.Create;
   SL:=TPackStringList.Create;
   LSL:=TPackStringList.Create;
   VLSL:=TPackStringList.Create;
   
   VSL.PackText:=Values;
   VSL.PackText:=VSL[0];
   for I:=0 to VSL.Count-1 do
      (Item as IProduct).NotifyChildClick(VSL[I],I);
   
   VSL.PackText:=Values;
   VSL.PackText:=VSL[1];
   SL.PackText:=(Item as IProduct).GetExecData;
   for I:=0 to SL.Count-1 do
   begin
      LSL.PackText:=SL[I];
      for J:=0 to VSL.Count-1 do
      begin
         VLSL.PackText:=VSL[J];
         if (VLSL.Count > 1) and (LSL.Count > 5) and (VLSL[0] = LSL[3]) then
         begin
            LSL[5]:=VLSL[1];
         end;
      end;
      SL[I]:=LSL.PackText;
   end;
   S:=SL.PackText;
   FlagError:=False;
   LSL.Free;
   VLSL.Free;
   SL.Free;
   VSL.Free;
   
   S:=(Item as IProduct).SetExecData(S,FlagError);
   OnSetFormData(S,False,True,False);
end; 
procedure TCompExec.Execute(Name,Data:String);
var
   I:Integer;
   CurrDontRePaint:Boolean;
   BMP:TBitMap;
   SL,SL2:TPackStringList;
   J:Integer;
   FlagError:WordBool;
//   CD:String;
begin
   try
      if ExecList.IndexOf(Name) = -1 then ExecList.Add(Name);
      if (Name = '') and (WUGroup <> nil) then
         Name:=WUGroup.Item[0];
      ReferenceData('SET(LAST'
                    + DelimitedString(Name,'.',False) //'Group' or 'Product'
                    + ','
                    + Name
                    + ')');
      CurrentExec:=Name;
      if PutBack(Name) then DontRePaint:=True;
      if RefCount < 1 then Exit;
      //try
      //  Item:=CreateOleObject(Name) as IExecComponent;
      //except
      //end ;
      Item:=CompMan.LoadComponent(Name) as IExecComponent;
      if Item = nil then
      begin
         Cancel;
         Exit;
      end;
      if Assigned(OnGetButtonRef) then
      begin
         I:=0;
         while (I < MaxItems) and (I < Item.Count) do
         begin
            if Assigned(FOnSetButtonOnClick) then FOnSetButtonOnClick(OnGetButtonRef(I),ItemClicked);
            Inc(I);
         end;
         while I < MaxItems do
         begin
            if Assigned(FOnSetButtonOnClick) then FOnSetButtonOnClick(OnGetButtonRef(I),nil);
            Inc(I);
         end;
      end;
      if SaveList.IndexOf(CurrentExec) = -1 then
      begin
         SaveList.AddObject(CurrentExec,nil);
      end;
      CurrDontRePaint:=DontRePaint;
      DontRePaint:=True;
      ReturnedAlready:=False;
      //force repaint of products to init optional buttons
      If LeftOf(Name, 'Product.') then
        Item.Execute(FQuantity,FMaxItems,False,Self,TxnLog,False)
      else
        Item.Execute(FQuantity,FMaxItems,CurrDontRePaint,Self,TxnLog,False);
      if Item.NeedsWeight then
      begin
         DontUpdate:=True;
         Item.TriggerValue(tsScale,IntToStr(LastScaleReading));
         DontUpdate:=False;
      end;
      if TriggerValue <> '' then
      begin
         case TriggerValue[1] of
             '*',',',#2,#3 : Item.TriggerValue(tsBarCode    ,Copy(TriggerValue,2,Length(TriggerValue)-2));
             '%' : Item.TriggerValue(tsOCRReader  ,Copy(TriggerValue,2,Length(TriggerValue)-2));
             '&' : Item.TriggerValue(tsMCRReader  ,Copy(TriggerValue,2,Length(TriggerValue)-2));
             '^' : Item.TriggerValue(tsScale      ,Copy(TriggerValue,2,Length(TriggerValue)-2));
             '$' : Item.TriggerValue(tsOtherReader,Copy(TriggerValue,2,Length(TriggerValue)-2));
         end;
      end;                                         
      if CurrDontRePaint then
         DontRePaint:=False;
      if not ReturnedAlready then
      begin
         try
            if Assigned(OnSetTitle   ) then OnSetTitle   (Translator.Translate(Item.Title   ));
            if Assigned(OnSetPrompt  ) then OnSetPrompt  (Translator.Translate(Item.Prompt  ));
            if Assigned(OnSetPMessage) then OnSetPMessage(Translator.Translate(Item.PMessage));
            if Assigned(OnSetBitMap  ) then                                                          
            begin
               BMP:=GetBitMap(Item.BitMap,False);
               OnSetBitMap(BMP);
               BMP.Free;
            end;
            if (Copy(Name,1,7) = 'Product') and Assigned(OnSetFormData) then 
            begin
               SL:=TPackStringList.Create;
               SL2:=TPackStringList.Create;
               try
                  if Data <> '' then 
                  begin
                     SL.PackText:=(Item as IProduct).SetExecData(CleanUp(Data),FlagError);
                  end
                  else
                     SL.PackText:=(Item as IProduct).GetExecData;
               except
                  on E:Exception do RaiseException(100,E);
               end;
               if SL.Count = 0 then 
                  SL.Add(#1'0'#1'0'#1'M'#1' '#1' '#1' '#1'Press F1 to Complete transaction^or select optional services'#1'Press F1 to Complete'#1'Mask(!)');
               for J:=0 to SL.Count-1 do
               begin
                  SL2.PackText:=SL[J];
                  SL2[4]:=Translator.Translate(SL2[4]);
                  SL2[6]:=Translator.Translate(SL2[6]);
                  SL2[7]:=Translator.Translate(SL2[7]);
                  SL[J]:=SL2.PackText;
               end;
               SL2.Free;
               OnSetFormData(SL.PackText,False,True,DontUpdate);
               NewFormNext:=False;
               SL.Free;
            end;
         except
            on E:Exception do RaiseException(99,E);
         end;
      end;
   except
      on E:Exception do RaiseException(23,E);
   end;
end;                      
function TCompExec.FormDataChanged(Value:String):Boolean;
var
   SL :TPackStringList;
   SL2:TPackStringList;
   J:Integer;
   FlagError:WordBool;
begin
   FlagError:=False;
   if Assigned(OnSetFormData) then
   begin
     SL:=TPackStringList.Create;
     try
        SL.PackText:=(Item as IProduct).SetExecData(CleanUp(Value),FlagError);
     except
        on E:Exception do RaiseException(100,E);
     end;
     SL2:=TPackStringList.Create;
     for J:=0 to SL.Count-1 do
     begin
        SL2.PackText:=SL[J];
        SL2[4]:=Translator.Translate(SL2[4]);
        SL2[6]:=Translator.Translate(SL2[6]);
        SL2[7]:=Translator.Translate(SL2[7]);
        SL[J]:=SL2.PackText;
     end;
     SL2.Free;
     OnSetFormData(SL.PackText,FlagError,False,DontUpdate);
     SL.Free;
   end;
   if FlagError then Result:=False else Result:=True;
end;
function TCompExec.GetComponentReference(const Name: WideString): IDispatch;
var
   SL:TPackStringList;
   S:String;
begin
   Result:=nil;
        if Name = GUIDToString(Class_ScaleDevice) then
      Result:=Scale
   else if Name = GUIDToString(Class_LabelDevice) then
      Result:=LabelPr
   else if Name = GUIDToString(Class_OfficeInfoDevice) then
      Result:=OfficeInfo
   else if Name = GUIDToString(Class_CustDispDevice) then
      Result:=CustDisp
   else if Name = GUIDToString(Class_OCRDevice) then
      Result:=OCR
   else if Name = GUIDToString(Class_GPCSTrackedMail) then
      Result:=TrackedMail
   else if Name = GUIDToString(Class_ReceiptDevice) then
      Result:=ReceiptSlip
   else if Name = GUIDToString(Class_DatabaseServerAuto) then
      Result:=HookUp.DatabaseServer
   else if Pos('ReceiptPreview',Name) = 1 then
   begin
      Result:=ReceiptSlip;
      if GetGPCSRegString('Reports','Preview Receipt Reports','0') = '1' then
      begin
         if Assigned(FOnModalDialog) then
         begin
            SL:=TPackStringList.Create;
            S:=Copy(Name,15,Length(Name));
            if Pos('Report.',S) = 1 then
            begin
               SL.CommaText:=FOnReportPreview(S,True);
            end
            else
               SL.CommaText:=S;

            with Translator do
            FOnModalDialog(ptAcct,SL.PackText,
                           Translate('Press [Report] to continue:'),
                           Translate('Press the [Report] Button to continue^or the [Return] button to Cancel'),
                           OnGetButtonRef(0),OnGetButtonRef(1),nil,
                           'Report','Return','');
            SL.Free;
            if ModalSelection <> 1 then
               Result:=nil;
         end;
      end;
   end
   else if (Pos('Report.',Name) = 1) and Assigned(FOnReportPreview) then
   begin
      ReferenceData('SET(LASTREPORT,' + Name + ')');
      FOnReportPreview(Name,False);
   end
   else if LeftOf(Name, 'Receipt.') and Assigned(FOnReportPreview) then
   begin
      ReferenceData('SET(LASTREPORT,' + Name + ')');
      FOnReportPreview(Name,False);
   end
   else if Name = 'End Of Day' then
   begin
      InternalFunction('End Of Day');
   end;

end;
procedure TCompExec.DataChanged(const EventSource: IExecComponent;const Value: WideString; FlagError: WordBool);
var
   SL :TPackStringList;
   SL2:TPackStringList;
   J:Integer;
begin
   if Assigned(OnSetFormData) then
   begin
      SL:=TPackStringList.Create;
      SL2:=TPackStringList.Create;
      SL.PackText:=Value;
      for J:=0 to SL.Count-1 do
      begin
         SL2.PackText:=SL[J];
         if SL2.Count > 4 then SL2[4]:=Translator.Translate(SL2[4]);
         if SL2.Count > 6 then SL2[6]:=Translator.Translate(SL2[6]);
         if SL2.Count > 7 then SL2[7]:=Translator.Translate(SL2[7]);
         SL[J]:=SL2.PackText;
      end;
      SL2.Free;
      OnSetFormData(SL.PackText,FlagError,NewFormNext,DontUpdate);
      NewFormNext:=False;
      SL.Free;     
   end;
end;
procedure TCompExec.CancelCustomer;
begin
   try
      if TrackedMail <> nil then TrackedMail.ClearLog;
      TxnLog.CancelCustomer;
   except
      on E:Exception do RaiseException($1004,E);
   end;
end;  
function ZeroPad(V:String;Len:Integer):String;
var
   I:Integer;
begin
   Result:='';
   if Len < Length(V) then Len:=Length(V);
   for I:=1 to Len do Result:=Result+'0';
   for I:=1 to Length(V) do Result[(Len-Length(V))+I]:=V[I];
end;
function TCompExec.GetUniqueID(Office,WorkStation:String):String;
const
   ErrorID:Integer = 0;
begin
   try
     Counter.WriteDevice(dcInitialise,'Customer Session',1);
     Result:=ZeroPad(Trim(Office),5)+ZeroPad(Trim(WorkStation),3)+ZeroPad(Counter.GetStatus,7);
   except
      Result:='E'+ZeroPad(Trim(Office),5)+ZeroPad(Trim(WorkStation),3)+ZeroPad(IntToStr(ErrorID),7);
      Inc(ErrorID);
   end;
end;
procedure TCompExec.CopyIntoFloppyCopyFile(Sender: TCopyFile);
begin
   ProgressBar('Copying Files...',0,24,2,1000);
end;
procedure TCompExec.CopyIntoFloppyDiskNoRead;
begin
   DiskUnustable:=True;
end;
function TCompExec.CopyIntoFloppyInsertDisk(Txt: String): Word; begin Result:=mrOK; end;
procedure TCompExec.CopyIntoFloppyGetReadyDevice; begin ; end;
function TCompExec.CopyIntoFloppyInsertFormatDisk(Txt: String): Word;
begin
   ProgressBar('',0,0,0,0);
   FOnModalDialog(ptPick,'','','',nil,nil,nil,'','','');
//   Result:=MessageDlg('Insert Disk Number '+IntToStr(StrToInt(Txt)+1),mtInformation,[mbOK,mbCancel],0);
   if DiskUnustable then
   begin
      FOnModalDialog(ptInfo,
                  #1+Translate('Please Insert a Diskette')+
                  #1+
                  #1+Translate('The Diskette should be labelled (Transfer Disk - Number')+' '+IntToStr(StrToInt(Txt)+1)+')'+
                  #1+Translate('Press [F1] once the disk has been inserted')+
                  #1+Translate('Press [F2] to cancel this operation'),
                  Translate('Please Insert ANOTHER Diskette'),
                  Translate('This one has already been used!^Insert Diskette Number ')+IntToStr(StrToInt(Txt)+1),
                  OnGetButtonRef(0),OnGetButtonRef(1),nil,'OK','CANCEL','');
   end
   else
   begin
      FOnModalDialog(ptInfo,
                  #1+Translate('Please Insert a Diskette')+
                  #1+
                  #1+Translate('The Diskette should be labelled (Transfer Disk - Number ')+IntToStr(StrToInt(Txt)+1)+')'+
                  #1+Translate('Press [F1] once the disk has been inserted')+
                  #1+Translate('Press [F2] to cancel this operation'),
                  Translate('Please Insert a Diskette'),
                  Translate('Insert Diskette Number')+' '+IntToStr(StrToInt(Txt)+1),
                  OnGetButtonRef(0),OnGetButtonRef(1),nil,'OK','CANCEL','');
   end;
   DiskUnustable:=False;
   WaitOnModalDialog:=True;
   ModalDialogKey:='';
   while (WaitOnModalDialog) and (not Application.Terminated) do
      Application.ProcessMessages;
   if ModalDialogKey = 'OK' then
   begin
      ProgressBar('Formatting Disk...',0,84,0,1000);
      FOnModalDialog(ptInfo,'','Diskette','Please Wait: ^A disk operation is in progress',nil,nil,nil,'','','');
      Result:=mrOK;
   end
   else
   begin
      ProgressBar('Cancel Operation...',0,1,1,0);
      Result:=mrAbort;            
   end;
end;   


procedure TCompExec.CreateTxnBatchFile;
var
   Table:TTable;
   Query:TQuery;
   Batch:TBatchMove;
   LastUpdatePeriod:String;
begin
   LastUpdatePeriod:=GetGPCSRegString('LastTransfer','Period','0');
   try
      Table:=TTable.Create(nil);
      with Table do
      begin
        ForceDirectories(ApplicationRootPath+'TxData');
        DatabaseName:=ApplicationRootPath+'TxData';
        TableName:='Transactions';
        TableType:=ttParadox;
      end;
      Query:=TQuery.Create(nil);
      with Query do
      begin
        DatabaseName:='PSL';
        SQL.Text:='select * from txnlog where Period >= '+LastUpdatePeriod;
      end;
      Batch:=TBatchMove.Create(nil);
      with Batch do
      begin
        AbortOnKeyViol:=False;
        AbortOnProblem:=False;
        Destination:=Table;
        Mode:=batCopy;
        Source:=Query;
        Execute;
        if ProblemCount < 1 then
          SetGPCSRegString('LastTransfer','Period',IntToStr(GetTodayasPeriod));
        Free;
      end;
      Query.Free;
      Table.Free;
   except
      on E : Exception do RaiseGUIDException('{3308F804-6B72-44AE-A3CE-C06E5959386B}',E);
   end;
end;
procedure TCompExec.ReadTxnBatchFile;
var
  TableIn:TTable;
  TableOut:TTable;
  Batch:TBatchMove;
  TxnType:String;
  User,Description:String;
  ToUser:String;
  Quantity:Integer;
  Stock:IStock;
  CurrencyName:String;
  ExRate:Currency;
begin
   try                   
      TableIn:=TTable.Create(nil);
      with TableIn do
      begin
        ForceDirectories(ApplicationRootPath+'RxData');
        DatabaseName:=ApplicationRootPath+'RxData';
        TableName:='Transactions';
      end;
      TableOut:=TTable.Create(nil);
      with TableOut do
      begin
        DatabaseName:='PSL';
        TableName:='TXNLOG';
        DataBase.Params.Add('USER NAME=' + GetGPCSRegString('','UserName','psl'));
        DataBase.Params.Add('PASSWORD='  + GetGPCSRegString('','Password','suvroc'));
      end;
      Batch:=TBatchMove.Create(nil);
      with Batch do
      begin
        AbortOnKeyViol:=False;
        AbortOnProblem:=False;
        Mode:=batAppendUpdate;
        Source:=TableIn;
        Destination:=TableOut;
        Execute;
        Free;                   
      end;
      TableOut.Free;
      try
         with TableIn do
         begin
            if not Active then Active:=True;
            First;
            while not EOF do
            begin
               TxnType:=TableIn.FieldByName('RecType').Value;
               if (TxnType = 'TransStk') or (TxnType = 'TxStkTo') then
               begin
                  User       :=FieldByName('Teller').Value;
                  ToUser     :=FieldByName('Ident').AsString;
                  Description:=FieldByName('Description').Value;
                  Quantity   :=FieldByName('Quantity').Value;
                  if (User <> '') and (Description <> '') and (Quantity <> 0) then
                  begin
                     Stock:=CreateStock;
                     if Stock <> nil then
                     begin
                        Stock.AdjustStockLevel(User,Description,0-Quantity);
                        Stock.AdjustStockLevel(ToUser,Description,Quantity);
                        Stock:=nil;
                     end;
                  end;
               end
               else if TxnType = 'TxStkFrom' then
               begin
                  ToUser     :=FieldByName('Teller').Value;
                  User       :=FieldByName('Ident').AsString;
                  Description:=FieldByName('Description').Value;
                  Quantity   :=FieldByName('Quantity').Value;
                  if (User <> '') and (Description <> '') and (Quantity <> 0) then
                  begin
                     Stock:=CreateStock;
                     if Stock <> nil then
                     begin
                        Stock.AdjustStockLevel(User,Description,0-Quantity);
                        Stock.AdjustStockLevel(ToUser,Description,Quantity);
                        Stock:=nil;
                     end;
                  end;
               end
               else if (TxnType = 'StockUsed') or (TxnType = 'SupStkUsd') then
               begin
                  User       :=FieldByName('Teller').Value;
                  Description:=FieldByName('Description').Value;
                  Quantity   :=FieldByName('Quantity').Value;
                  if (User <> '') and (Description <> '') and (Quantity <> 0) then
                  begin
                     Stock:=CreateStock;
                     if Stock <> nil then
                     begin
                        Stock.AdjustStockLevel(User,Description,0-Quantity);
                        Stock:=nil;
                     end;
                  end;
               end
               else if TxnType = 'StockSet' then
               begin
                  User       :=FieldByName('Teller').Value;
                  Description:=FieldByName('Description').Value;
                  Quantity   :=FieldByName('Quantity').Value;
                  if (User <> '') and (Description <> '') and (Quantity <> 0) then
                  begin
                     Stock:=CreateStock;
                     if Stock <> nil then
                     begin
                        Stock.SetStockLevel(User,Description,Quantity);
                        Stock:=nil;
                     end;
                  end;
               end
               else if TxnType = 'Exchange' then
               begin
                  CurrencyName:=FieldByName('Description').Value;
                  ExRate      :=StrToCurrDef(FieldByName('Ident').AsString,0);
                  if (CurrencyName <> '') and (ExRate > 0) then
                     SetGPCSRegString('ExchangeRates',CurrencyName,CurrToStr(ExRate));
               end
               else if TxnType = 'DelExchg' then
               begin
                  CurrencyName:=FieldByName('Description').Value;
                  if (CurrencyName <> '') then
                     DeleteCountryExchange(CurrencyName);
               end;
                  
                  
               Next;
            end;
            Active:=False;
         end; 
      except
         on E : Exception do RaiseGUIDException('{B16AFB25-B211-452E-822A-D300346D2B75}',E);
      end;
      TableIn.Free;
   except
   end;
end;
procedure TCompExec.TransferTxnsToDiskette;
var
   CopyIntoFloppy:TCopyIntoFloppy;
begin
   DiskUnustable:=False;
   CopyIntoFloppy:=TCopyIntoFloppy.Create(nil);
   with CopyIntoFloppy do
   begin
      OutputDir:='A:\';
      ShowMsg:=True;
//      DoFormat:=False;
      CreateTxnBatchFile;
      InputFileNames:='"'+ApplicationRootPath+'TxData\Transactions.MB","'+ApplicationRootPath+'TxData\Transactions.DB"';
      OnCopyFile:=CopyIntoFloppyCopyFile;
      OnGetReadyDevice:=CopyIntoFloppyGetReadyDevice;
      OnInsertDisk:=CopyIntoFloppyInsertDisk;
      OnInsertFormatDisk:=CopyIntoFloppyInsertFormatDisk;
      OnDiskNoRead:=CopyIntoFloppyDiskNoRead;
      FOnModalDialog(ptInfo,'','Diskette','Please Wait: ^A disk operation is in progress',nil,nil,nil,'','','');
      StartCopying;
   end;
   CopyIntoFloppy.Free;          
   FOnModalDialog(ptCancel,'','','',nil,nil,nil,'','','');
   ProgressBar('',0,0,0,0);
end;
procedure TCompExec.CopyFromFloppyCopyFile(Sender: TCopyFile); begin ; end;
procedure TCompExec.CopyFromFloppyGetReadyDevice; begin ; end;
function TCompExec.CopyFromFloppyInsertDisk(Txt: String): Word;
begin
   ProgressBar('',0,0,0,0);
   FOnModalDialog(ptPick,'','','',nil,nil,nil,'','','');
   FOnModalDialog(ptInfo,
               #1+Translate('Please Insert the Diskette')+
               #1+Translate('Labelled (Transfer Disk - Number')+' '+IntToStr(StrToInt(Txt)+1)+')'+
               #1+
               #1+Translate('Press [F1] once the disk has been inserted')+
               #1+Translate('Press [F2] to cancel this operation'),
               Translate('Please Insert a Diskette'),
               Translate('Insert Diskette Number ')+IntToStr(StrToInt(Txt)+1),
               OnGetButtonRef(0),OnGetButtonRef(1),nil,'OK','CANCEL','');
   WaitOnModalDialog:=True;
   ModalDialogKey:='';
   while (WaitOnModalDialog) and (not Application.Terminated) do
      Application.ProcessMessages;
   if ModalDialogKey = 'OK' then
   begin
      ProgressBar('Transfering Data...',0,40,0,1000);
      FOnModalDialog(ptInfo,'','Diskette','Please Wait: ^A disk operation is in progress',nil,nil,nil,'','','');
      Result:=mrOK;
   end
   else
   begin
      ProgressBar('Cancel Operation...',0,1,1,0);
      Result:=mrAbort;            
   end;
end;
procedure TCompExec.TransferTxnsFromDiskette;
var
  CopyFromFloppy:TCopyFromFloppy;
begin
  CopyFromFloppy:=TCopyFromFloppy.Create(nil);
  with CopyFromFloppy do
  begin
    OutputDir:=ApplicationRootPath+'RxData\';
    ShowMsg:=True;
    DoFormat:=False;
    OnCopyFile:=CopyFromFloppyCopyFile;
    OnGetReadyDevice:=CopyFromFloppyGetReadyDevice;
    OnInsertDisk:=CopyFromFloppyInsertDisk;
    FOnModalDialog(ptInfo,'','Diskette','Please Wait: ^A disk operation is in progress',nil,nil,nil,'','','');
    StartCopying;
  end;
  CopyFromFloppy.Free;          
  FOnModalDialog(ptCancel,'','','',nil,nil,nil,'','','');
  ProgressBar('',0,0,0,0);
  ReadTxnBatchFile;
end;
procedure TCompExec.OpenCashDrawer;
var
   S:String;
   Drawer  :Char;
   OnDelay :Char;
   OffDelay:Char;
   SL:TStringList;
begin
   if ReceiptSlip <> nil then
   begin
      S:=GetGPCSRegString('DeviceSetup\Receipt','CashDrawer','');
      if S <> '' then
      begin
         SL:=TStringList.Create;
         SL.CommaText:=S;
         if SL.Count > 2 then
         begin
            Drawer  :=Char(StrToIntDef(SL[0],0));
            OnDelay :=Char(StrToIntDef(SL[1],40));
            OffDelay:=Char(StrToIntDef(SL[2],40));
            ReceiptSlip.WriteDevice(dcInitialise,' ',1);
            ReceiptSlip.WriteDevice(dcRawData,#$1B+#$70+Drawer+OnDelay+OffDelay,0);
            ReceiptSlip.WriteDevice(dcShutDown,' ',0);
         end;
         SL.Free;
      end;
      S:=GetGPCSRegString('DeviceSetup\Receipt','Automatic Print','0');
      if S <> '0' then
      begin
         if (TxnLog.Total = 0) and (TxnLog.Contents <> '') then
         begin
            Receipt(True);
         end;
      end;
   end;   
end;
procedure TCompExec.ProgressTick(Sender:TObject);
begin
   if ProgressPos < ProgressMax then
   begin
      Inc(ProgressPos);
      if Assigned(OnProgress) then 
         OnProgress(ProgressTitle,ProgressMin,ProgressMax,ProgressPos);
   end;
end;
procedure TCompExec.ProgressBar(const Title: WideString; Min, Max, Pos, Auto: Integer);
begin
   if (Min = Max) or (Auto = 0) then
   begin
      if Assigned(OnProgress) then OnProgress(Title,Min,Max,Pos);
      if ProgressTimer <> nil then
      begin
         ProgressTimer.Free;
         ProgressTimer:=nil;
      end;
   end;
   if (Min = Max) then Exit;
   if Assigned(OnProgress) then OnProgress(Title,Min,Max,Pos);
   if Auto > 0 then
   begin
      if ProgressTimer = nil then
      begin
         ProgressTimer:=TTimer.Create(nil);
         ProgressTimer.OnTimer:=ProgressTick;
         ProgressTimer.Enabled:=True;
      end;
      ProgressTimer.Interval:=Auto;
      ProgressTitle:=Title;
      ProgressMin:=Min;
      ProgressMax:=Max;
      ProgressPos:=Pos;
   end;
end;
procedure TCompExec.ZeroScale;
begin
   Scale.WriteDevice(dcRawData,'Z',1);
end;
procedure TCompExec.EndCustomer(UniqueID:String);
begin
   if (TxnLog.Contents = '') or (not ValidInstall) then Exit;
   if TxnLog.Total <> 0 then Exit;
//   OpenCashDrawer;
   try                     
      if TrackedMail <> nil then TrackedMail.WriteToStore;
      TxnLog.User       :=FUser;
      TxnLog.Office     :=StrToIntDef(FOffice,999);
      TxnLog.WorkStation:=StrToIntDef(FWorkStation,999);
      TxnLog.EndCustomer(UniqueID);
   except
      on E:Exception do RaiseException(24,E);
   end;
end;  
procedure TCompExec.SendReceiptDetails(Ident:String);
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;                           
   SL.Add(FUser       ); // Clerk ID
   SL.Add(FOffice     ); // Office ID
   SL.Add(' '          ); // Money Order Value
   SL.Add(' '          ); // Money Order Fee
   SL.Add(' '          ); // Destination Zip Code
   SL.Add(FWorkStation); // Position
   SL.Add(Ident        ); // Money Order Number
   SL.Add(Translator.Translate('Clerk' )); // Text - Clerk
   SL.Add(Translator.Translate('Office')); // Text - Office
   SL.Add(Translator.Translate('Value' )); // Text - Value
   SL.Add(Translator.Translate('Fee'   )); // Text - Fee
   SL.Add(Translator.Translate('Zip'   )); // Text - Zip
   SL.Add(Translator.Translate(GetGPCSRegString('OfficeInfo','Title','Tanzanian Post Corporation'))); // Text - Position
   SL.Add(Translator.Translate(GetGPCSRegString('OfficeInfo','Title','Tanzanian Post Corporation'))); // Text - Position
   SL.Add(Translator.Translate(GetGPCSRegString('OfficeInfo','Address Line 1','Libya Street'     ))); // Text - Position
   SL.Add(Translator.Translate(GetGPCSRegString('OfficeInfo','Address Line 2','Dar es Salaam'    ))); // Text - Position
//   SL.Add(Translator.Translate('Thank You - Please call again.')); // Text - Position
   SL.Add(Translator.Translate(GetGPCSRegString('OfficeInfo','Thankyou Message','Thank You - Please call again.'))); // Text - Position
   SL.Add(Translator.Translate('Total'                         )); // Text - Position
   ReceiptSlip.WriteDevice(dcList2Data,SL.CommaText,0);
   SL.Free;
end;
procedure TCompExec.TrackingReceipt(Description,Destination,Sender,Recpient,Ident:String;Price,Fee:Currency);
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Add(Translator.Translate('Tracking Receipt'));
   SL.Add(Translator.Translate(Description));
   SL.Add(CurrToStrF(Price,ffCurrency,2));
   SL.Add(Destination);
   SL.Add(Sender);
   SL.Add(Recpient);
   SL.Add(Ident);
   If Fee <> 0 then
      SL.Add(CurrToStrF(Fee,ffCurrency,2))
   else
      SL.Add('');
   SL.Add(Translator.Translate('From:'));
   SL.Add(Translator.Translate('To:'));
   ReceiptSlip.WriteDevice(dcInitialise,' ',1);
   SendReceiptDetails('');
   ReceiptSlip.WriteDevice(dcLine2Data,SL.CommaText,0);
   ReceiptSlip.WriteDevice(dcShutDown,' ',0);
   SL.Free;
end;
procedure TCompExec.Receipt(Print:Boolean);
const
   LastRcptPrinted:String = '';
   UniqueID       :String = '';
var
   OSL:TPackStringList;
   SL:TPackStringList;
   ISL:TPackStringList;
   I:Integer;
   Total:Currency;
   Desc:String;
begin
   try
      if TxnLog.Contents = '' then // re-print
      begin
         if LastRcptPrinted = '' then Exit;
         SL:=TPackStringList.Create;
         OSL:=TPackStringList.Create;
         try
            if TrackedMail <> nil then
               TrackedMail.WriteToStore;
         except
            on E:Exception do RaiseError(1,3,3,'TrackedMail.WriteToStore in Receipt '+E.Message);
         end;
         try
            ReceiptSlip.WriteDevice(dcInitialise,'',1);
            SendReceiptDetails(UniqueID);
         except
            on E:Exception do RaiseError(1,3,3,'WriteDevice dcList2Data in Receipt 1 '+E.Message);
         end;
         try
            OSL.Add('" ","'+Translator.Translate('Receipt Re-Print')+'"," "');
            OSL.Add('" ","__________________________________________________","_"');
            SL.PackText:=LastRcptPrinted;
            ISL:=TPackStringList.Create;
            Total:=0;
            for I:=0 to SL.Count-1 do
            begin
               ISL.PackText:=SL[I];
               if ISL.Count > 6 then
                  Desc:=Translator.Translate(ISL[1])+' '+ISL[6]
               else
                  Desc:=Translator.Translate(ISL[1]);
               if ISL[4][1] = '-' then
               begin
                 If Total > 0 then //do not subtotal every withdrawal
                 begin

                  OSL.Add('" ","__________________________________________________","_"');
                  OSL.Add('" ","'+Translator.Translate('Total')+'","'+CurrToStrF(Total,ffNumber,CurrencyDecimals)+'"');
                  OSL.Add('" ","__________________________________________________","_"');
                 end;
                  OSL.Add('" ","'+Desc+'","'+Copy(ISL[4],2,999)+'"');
               end
               else if StrToCurrDef(ISL[4],0) = 0 then
               begin
                  if ISL[0] = '0' then
                     OSL.Add('"'+ISL[2]+'","'+Desc+'"," "')
                  else
                     OSL.Add('" ","'+Desc+'"," "');
               end
               else
               begin
//                  if ISL[0] = '0' then
                     OSL.Add('"'+ISL[2]+'","'+Desc+'","'+ISL[4]+'"')
//                  else
//                     OSL.Add('" ","'+Desc+'","'+ISL[4]+'"');
               end;
               Total:=Total+StrToCurrDef(ISL[4],0);
            end;
            ISL.Free;
            SL.Free;
         except
            on E:Exception do RaiseError(1,3,3,'Translate Data in Receipt '+E.Message);
         end;
         try
            if Print then
               ReceiptSlip.WriteDevice(dcList1Data,OSL.CommaText,0);
            ReceiptSlip.WriteDevice(dcShutDown,'',1);
         except
            on E:Exception do RaiseError(1,3,3,'ReceiptSlip.WriteDevice in Receipt'+E.Message);
         end;
         OSL.Free;
      end
      else if TxnLog.Total = 0 then
      begin
         UniqueID:=GetUniqueID(FOffice,FWorkStation);
         SL:=TPackStringList.Create;
         OSL:=TPackStringList.Create;
         try
            if TrackedMail <> nil then
               TrackedMail.WriteToStore;
         except
            on E:Exception do RaiseError(1,3,3,'TrackedMail.WriteToStore in Receipt '+E.Message);
         end;
         try
            ReceiptSlip.WriteDevice(dcInitialise,'',1);
            SendReceiptDetails(UniqueID);
         except
            on E:Exception do RaiseError(1,3,3,'WriteDevice dcList2Data in Receipt 1 '+E.Message);
         end;
         try
            SL.PackText:=TxnLog.Contents;
            LastRcptPrinted:=SL.PackText;
            ISL:=TPackStringList.Create;
            Total:=0;
            for I:=0 to SL.Count-1 do
            begin
               ISL.PackText:=SL[I];
               if ISL.Count > 6 then
                  Desc:=Translator.Translate(ISL[1])+' '+ISL[6]
               else
                  Desc:=Translator.Translate(ISL[1]);
               if ISL[4][1] = '-' then
               begin
                 If Total > 0 then //do not subtotal every withdrawal
                 begin
                  OSL.Add('" ","__________________________________________________","_"');
                  OSL.Add('" ","'+Translator.Translate('Total')+'","'+CurrToStrF(Total,ffNumber,CurrencyDecimals)+'"');
                  OSL.Add('" ","__________________________________________________","_"');
                 end;
                 OSL.Add('" ","'+Desc+'","'+Copy(ISL[4],2,999)+'"');
               end
               else if StrToCurrDef(ISL[4],0) = 0 then
               begin
                  if ISL[0] = '0' then
                     OSL.Add('"'+ISL[2]+'","'+Desc+'"," "')
                  else
                     OSL.Add('" ","'+Desc+'"," "');
               end
               else
               begin
//                  if ISL[0] = '0' then
                     OSL.Add('"'+ISL[2]+'","'+Desc+'","'+ISL[4]+'"')
//                  else
//                     OSL.Add('" ","'+Desc+'","'+ISL[4]+'"');
               end;
               Total:=Total+StrToCurrDef(ISL[4],0);
            end;
            ISL.Free;
            SL.Free;
         except
            on E:Exception do RaiseError(1,3,3,'Translate Data in Receipt '+E.Message);
         end;
         try
            if Print then
               ReceiptSlip.WriteDevice(dcList1Data,OSL.CommaText,0);
            //auto reprint
            If GetGPCSRegString('DeviceSetup\Receipt','Reprint','0') = '1' then
               ReceiptSlip.WriteDevice(dcList1Data,OSL.CommaText,0);            
            ReceiptSlip.WriteDevice(dcShutDown,'',1);
         except
            on E:Exception do RaiseError(1,3,3,'ReceiptSlip.WriteDevice in Receipt'+E.Message);
         end;
         OSL.Free;
      end;
      EndCustomer(UniqueID);
   except
      on E:Exception do RaiseException(24,E);
   end;
end;
procedure TCompExec.SetTxnLogParent(Value:THandle);
begin
   try
   TxnLog.Parent:=Value;
   except
      on E:Exception do RaiseException(25,E);
   end;
end;
function TCompExec.ProgIsTracked(ProgID:String):Boolean;
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.PackText:=GetGPCSRegNames('Tracking Receipt','');
   Result:=SL.IndexOf(ProgID) <> -1;
   SL.Free;
end;
procedure TCompExec.WMTrackingReceipt(var Msg:TMessage);
begin
   LoggedTransaction(-2,0,0,0,0,'','','','');
end;
procedure TCompExec.LoggedTransaction(Index,Quantity,PLU:Integer;
                                      Value,Price:Currency;const Description,
                                      Additional,ProgID,DomInfo:WideString);
const
   SIndex      :Integer  = 0;
   SQuantity   :Integer  = 0;
   SPLU        :Integer  = 0;
   SValue      :Currency = 0;
   SPrice      :Currency = 0;
   ExSPrice      :Currency = 0;
   SDescription:String   = '';
   ExSAdditional :String   = '';
   SAdditional :String   = '';
   SProgID     :String   = '';
   SDomInfo    :String   = '';
   ExXSAdditional :String   = '';
   ExXSDescription:String   = '';
begin
   if Index = 0  then
   begin
      SIndex      :=Index      ;
      SQuantity   :=Quantity   ;
      SPLU        :=PLU        ;
      SValue      :=Value      ;
      SPrice      :=Price      ;
      SDescription:=Description;
      SAdditional :=Additional ;
      SProgID     :=ProgID     ;
      SDomInfo    :=DomInfo    ;
   end
   else if Index = 1 then
   begin
      ExSPrice:=Price;
      ExSAdditional:=Additional;
   end                                 
   else if ProgID = 'Sender' then
   begin
      if ProgIsTracked(SProgID) then
      begin
         ExXSAdditional :=Additional ;
         ExXSDescription:=Description;
         PostMessage(WindowHandle,WM_TRACKINGRECEIPT,0,0);
      end;
   end
   else if Index = -2 then
   begin
      TrackingReceipt(SDescription,SAdditional,ExXSDescription,ExXSAdditional,ExSAdditional,SPrice,ExSPrice);
   end;
end;

procedure TCompExec.VoidedTransaction(Index,Quantity,PLU:Integer;
                                      Value,Price:Currency;const Description,
                                      Additional,ProgID,DomInfo:WideString);
begin
end;
procedure TCompExec.OnChange(const EventSource:ITransactionLog);
begin
   PostMessage(WindowHandle,WM_TXNLOGCHANGED,0,0);
end;
procedure TCompExec.WMTxnLogChanged(var Msg:TMessage);
var
   CurrFormat:String;
begin
   try            
      if (Self.CurrentExec[1] = 'G') and Assigned(OnSetTransactions) and (TxnLog <> nil) then
      begin
         OnSetTransactions(TxnLog.Contents);
         if TxnLog.Contents = '' then
         begin
            if CustDisp <> nil then
            begin
               CustDisp.WriteDevice(dcInitialise,'',0);
               CustDisp.WriteDevice(dcRawData,'"' + GetGPCSRegString('DeviceSetup\CustDisp', 'Idle Line 1', '') +  '","'
                                                 + GetGPCSRegString('DeviceSetup\CustDisp', 'Idle Line 2', '') +  '"',0);

               CustDisp.WriteDevice(dcShutdown,'',0);
            end;
         end
         else
         begin
            if TxnLog.Total <> 0 then
            begin
               if CustDisp <> nil then
               begin
                  CustDisp.WriteDevice(dcInitialise,'',0);
                  CurrFormat:=GetGPCSRegString('','Currency Format','$%s');
                  CurrFormat:=Format(CurrFormat,[CurrToStrF(TxnLog.Total,ffNumber,2)]);
                  CustDisp.WriteDevice(dcRawData,'"Total '+CurrFormat+'"," "',0);
                  CustDisp.WriteDevice(dcShutdown,'',0);
               end;
            end
            else
            begin
               if CustDisp <> nil then
               begin
                  CustDisp.WriteDevice(dcInitialise,'',0);
                  CustDisp.WriteDevice(dcRawData,'"' + GetGPCSRegString('DeviceSetup\CustDisp', 'Idle Line 1', '') +  '","'
                                                     + GetGPCSRegString('DeviceSetup\CustDisp', 'Idle Line 2', '') +  '"',0);
                  CustDisp.WriteDevice(dcShutdown,'',0);
               end;
            end;
         end;
      end;
   except
      on E:Exception do RaiseException(26,E);
   end;
end;  
function TCompExec.CurrentLine:Integer;
begin
   Result:=0;
   if Assigned(FOnGetFormIndex) then Result:=FOnGetFormIndex;
end;
function TCompExec.CurrentDetails:WideString;
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Add(FUser       );
   SL.Add(FOffice     );
   SL.Add(FWorkstation);
   SL.Add(FServerName); 
   Result:=SL.PackText;
   SL.Free;
end;
procedure TCompExec.SetUser(Value:String);
begin
   if FUser <> Value then
   begin
      FUser:=Value;
      if TrackedMail <> nil then
         TrackedMail.User:=Value;
      if TransactionLog <> nil then
         TransactionLog.User:=Value;
      try // update line at end of receipt
         ReceiptSlip.WriteDevice(dcInitialise,'',1);
         SendReceiptDetails('A');
         ReceiptSlip.WriteDevice(dcShutDown,'',1);
      except
      end;
   end;      
end;
procedure TCompExec.SetOffice(Value:String);
begin
   if FOffice <> Value then
   begin
      FOffice:=Value;
      if TrackedMail <> nil then
         TrackedMail.Office:=StrToIntDef(Value,9999);
      if TransactionLog <> nil then
         TransactionLog.Office:=StrToIntDef(Value,9999);
      try // update line at end of receipt
         ReceiptSlip.WriteDevice(dcInitialise,'',1);
         SendReceiptDetails('A');
         ReceiptSlip.WriteDevice(dcShutDown,'',1);
      except
      end;
   end;
end;
procedure TCompExec.SetWorkstation(Value:String);
begin
   if FWorkstation <> Value then
   begin
      FWorkstation:=Value;
      if TrackedMail <> nil then
         TrackedMail.Workstation:=StrToIntDef(Value,99);
      if TransactionLog <> nil then
         TransactionLog.Workstation:=StrToIntDef(Value,99);
      try // update line at end of receipt
         ReceiptSlip.WriteDevice(dcInitialise,'',1);
         SendReceiptDetails('A');
         ReceiptSlip.WriteDevice(dcShutDown,'',1);
      except
      end;
   end;
end;
procedure TCompExec.WaitFor(DeviceStatus:DeviceStatusType);
begin
   case DeviceStatus of
      dsSlipIn  : begin
                     ReceiptSlip.WriteDevice(dcInitialise,'',1);
                     ReceiptSlip.WriteDevice(dcLine4Data,'SlipInserted',0);
                     ReceiptSlip.WriteDevice(dcShutDown,'',0);
                 end;
      dsSlipOut : begin
                     ReceiptSlip.WriteDevice(dcInitialise,'',1);
                     ReceiptSlip.WriteDevice(dcLine4Data,'SlipRemoved',0);
                     ReceiptSlip.WriteDevice(dcShutDown,'',0);
                 end;
   end;
end;
function TCompExec.Endorse(X,Y,ColCount:Integer;const PackText:WideString):WordBool;
var
   Series:String;
begin
   Result:=True;
   if ReceiptSlip <> nil then
   begin
      ReceiptSlip.WriteDevice(dcInitialise,'',1);
      if ReceiptSlip.WriteDevice(dcLine4Data,'SlipInserted',0) then
      begin
         try
            if UpperCase(Copy(PackText,1,12)) = 'MONEY ORDER ' then
            begin
               Series:=Copy(PackText,13,Length(PackText));
               ReceiptSlip.WriteDevice(dcRawData,#$1C#$18,0);    // 1C Select Slip 18 Open Form
               ReceiptSlip.WriteDevice(dcRawData,#$1B#$07,0);    // 1B07 Generate Tone
               ReceiptSlip.WriteDevice(dcRawData,#$1D#$14#$3,0); // Reverse Feed 3 Lines
               ReceiptSlip.WriteDevice(dcRawData,#$14#11,0);     // down 8 lines
               ReceiptSlip.WriteDevice(dcRawData,Series+'                    '+Series+#13,0);
               ReceiptSlip.WriteDevice(dcRawData,#$14#15,0);     // down 15 lines
               ReceiptSlip.WriteDevice(dcRawData,Series+'                    '+Series+#13,0);
               ReceiptSlip.WriteDevice(dcRawData,#$0C#$1E,0);    // 0C Eject Form 1E Select Receipt
            end
            else
            begin
               ReceiptSlip.WriteDevice(dcLine3Data,PackText,0)
            end;
         except
            on E:Exception do RaiseError($80,0,0,E.Message+' Printing Slip '+PackText);
         end;
      end
      else
      begin
         Result:=False;
      end;
      ReceiptSlip.WriteDevice(dcShutDown,'',0);
   end;
end;
procedure TCompExec.TriggerSubProducts(Value:String);
var
   SubProduct:IExecComponent;
   i:integer;
begin
   for i := 0 to Item.Count-1 do
   begin
      if Item.item[i] <> '' then
      begin
         SubProduct:=CompMan.LoadComponent(Item.item[i]) as IExecComponent;
         if SubProduct<>nil then
            SubProduct.TriggerValue(tsBarCode,Value);
      end;
   end ;
end;

{TUICompExec}
constructor TUICompExec.Create(AOwner:TComponent);
begin
   inherited Create(AOwner);
   if csDesigning in ComponentState then
   begin
      FWorkstationGroup:=GetGPCSRegString('Workstation','Group','FrontOfficeA');
//      FWorkStationGroup:='WGroup.FrontOfficeA';
      FMaxItems:=10;
      FQuantity:=1;
      FGroupSuffix:='...';
      FUserGroup:='UGroup.Supervisor';
      CompExec:=nil;
      Exit;
   end;

   CompExec:=TCompExec.Create;
   CompExec.OnProgress        :=Progress;
   CompExec.OnGetButtonRef    :=GetButtonRef;
   CompExec.OnGetFormIndex    :=GetFormIndex;
   CompExec.OnGetButtonIndex  :=GetButtonIndex;
   CompExec.OnSetButtonCaption:=SetButtonCaption;
   CompExec.OnSetButtonPrice  :=SetButtonPrice;
   CompExec.OnSetButtonToggle :=SetButtonToggle;
   CompExec.OnSetButtonBitMap :=SetButtonBitMap;
   CompExec.OnSetButtonOnClick:=SetButtonOnClick;
   CompExec.OnGetButtonOnClick:=GetButtonOnClick;
   CompExec.OnSetTitle        :=SetTitle   ;
   CompExec.OnSaveCurrentState:=SaveCurrentState;
   CompExec.OnSetPrompt       :=SetPrompt  ;
   CompExec.OnSetPMessage     :=SetPMessage;
   CompExec.OnSetTransactions :=SetTransactions;
   CompExec.OnSetAccounts    :=SetAccounts;
   CompExec.OnSetFormData     :=SetFormData;
   CompExec.OnDisplayInstruct :=DisplayInstruct;
   CompExec.OnModalDialog     :=ModalDialog;
   CompExec.OnSetBitMap       :=SetBitMap;
   CompExec.OnSetScale        :=SetScale;
   
   if csLoading in ComponentState then Exit;
//   CompExec.WorkStationGroup:='WGroup.FrontOfficeA';
   CompExec.MaxItems:=10;
   CompExec.Quantity:=1;
   CompExec.GroupSuffix:='...';
//   CompExec.UserGroup:='UGroup.Supervisor';
end;
destructor TUICompExec.Destroy;
begin
   
   if not (csDesigning in ComponentState) then 
   begin
      CompExec.Free;
      CompExec:=nil;
   end;
   inherited Destroy;
end;               
function TUICompExec.GetFormIndex:Integer;
begin
   Result:=0;
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnGetFormIndex) then Result:=FOnGetFormIndex;
end;
procedure TUICompExec.Progress(Title:String;Min,Max,Pos:Integer);
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnProgress) then FOnProgress(Title,Min,Max,Pos);
end;
function TUICompExec.GetButtonRef(Index:Integer):TControl;
begin
   Result:=nil;
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnGetButtonRef) then Result:=FOnGetButtonRef(Index);
end;
function TUICompExec.GetButtonIndex(Button:TControl):Integer;
begin
   Result:=0;
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnGetButtonIndex) and (Button <> nil) then Result:=FOnGetButtonIndex(Button);
end;
function TUICompExec.GetButtonOnClick(Button:TControl):TNotifyEvent;
begin
   Result:=nil;
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnGetButtonOnClick) and (Button <> nil)  then Result:=FOnGetButtonOnClick(Button);
end;
procedure TUICompExec.SetButtonBitMap(Button:TControl;var BitMap :TBitMap );
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnSetButtonBitMap) and (Button <> nil)  then FOnSetButtonBitMap(Button,BitMap);
end;
procedure TUICompExec.SetButtonCaption(Button:TControl;Caption:String  );
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnSetButtonCaption) and (Button <> nil)  then FOnSetButtonCaption(Button,Caption);
end;
procedure TUICompExec.SetButtonPrice(Button:TControl;Value:Currency);
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnSetButtonPrice) and (Button <> nil)  then FOnSetButtonPrice(Button,Value);
end;
procedure TUICompExec.SetButtonToggle(Button:TControl;State:Integer);
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnSetButtonToggle) and (Button <> nil)  then FOnSetButtonToggle(Button,State);
end;

procedure TUICompExec.SetButtonOnClick(Button:TControl;Handler:TNotifyEvent);
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnSetButtonOnClick) and (Button <> nil)  then FOnSetButtonOnClick(Button,Handler);
end;
procedure TUICompExec.SetTitle(Caption:String);
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnSetTitle) then FOnSetTitle(Caption);
end;
procedure TUICompExec.SetPrompt(Caption:String);
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnSetPrompt) then FOnSetPrompt(Caption);
end;
procedure TUICompExec.SetPMessage(Caption:String);
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnSetPMessage) then FOnSetPMessage(Caption);
end;
procedure TUICompExec.SetFormData(Caption:String;FlagError,NewForm,DontUpdate:Boolean);
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnSetFormData) then FOnSetFormData(Caption,FlagError,NewForm,DontUpdate);
end;
procedure TUICompExec.SetTransactions(Caption:String);
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnSetTransactions) then FOnSetTransactions(Caption);
end;
procedure TUICompExec.SetAccounts(Caption:String);
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnSetAccounts) then FOnSetAccounts(Caption);
end;
procedure TUICompExec.SetBitMap(BitMap:TBitMap);
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnSetBitMap) then FOnSetBitMap(BitMap);
end;
procedure TUICompExec.ModalDialog(PType:TPType;Text,DlgPrompt,DlgHint:String;B1,B2,B3:TControl;B1C,B2C,B3C:String);
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnModalDialog) then FOnModalDialog(PType,Text,DlgPrompt,DlgHint,B1,B2,B3,B1C,B2C,B3C);
end;
procedure TUICompExec.DisplayInstruct(Text,BitMap:String);
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   if Assigned(FOnDisplayInstruct) then FOnDisplayInstruct(Text,BitMap);
end;

procedure TUICompExec.SetScale(Reading:String);
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   try
      if Assigned(FOnSetScale) then FOnSetScale(Reading);
   except
   end;
end;
function TUICompExec.GetWorkStationGroup:String;
begin
   if csDesigning in ComponentState then
      Result:=FWorkStationGroup
   else
      Result:=CompExec.WorkStationGroup;
end;
procedure TUICompExec.SetWorkStationGroup(Value:String);
begin
   if csDesigning in ComponentState then
      FWorkStationGroup:=Value
   else
      CompExec.WorkStationGroup:=Value;
end;
function TUICompExec.GetUserGroup:String;
begin
   if csDesigning in ComponentState then
      Result:=FUserGroup
   else
      Result:=CompExec.UserGroup;
end;
procedure TUICompExec.SetUserGroup(Value:String);
begin
   if csDesigning in ComponentState then
      FUserGroup:=Value
   else
      CompExec.UserGroup:=Value;
end;
function TUICompExec.GetGroupSuffix:String;
begin
   if csDesigning in ComponentState then
      Result:=FGroupSuffix
   else
      Result:=CompExec.GroupSuffix;
end;                
procedure TUICompExec.SetGroupSuffix(Value:String);
begin
   if csDesigning in ComponentState then
      FGroupSuffix:=Value
   else
      CompExec.GroupSuffix:=Value;
end;
function TUICompExec.GetMaxItems:Integer;
begin               
   if csDesigning in ComponentState then
      Result:=FMaxItems
   else
      Result:=CompExec.MaxItems;
end;
procedure TUICompExec.SetMaxItems(Value:Integer);
begin
   if csDesigning in ComponentState then
      FMaxItems:=Value
   else
      CompExec.MaxItems:=Value;
end;
function TUICompExec.GetQuantity:Integer;
begin
   if csDesigning in ComponentState then
      Result:=FQuantity
   else
      Result:=CompExec.Quantity;
end;
procedure TUICompExec.SetQuantity(Value:Integer);
begin
   if csDesigning in ComponentState then
      FQuantity:=Value
   else
      CompExec.Quantity:=Value;
end;
procedure TUICompExec.SetTxnLogParent(Value:Integer);
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   CompExec.TxnLogParent:=Value;
end;
{function TUICompExec.GetBitmap(Value:String):TBitMap;
begin
   Result:=nil;
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   Result:=CompExec.GetBitmap(Value);
end;}
procedure TUICompExec.Cancel;
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   CompExec.Cancel;
end;
procedure TUICompExec.CancelToTop;
begin                   
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   CompExec.CancelToTop;
end;
function TUICompExec.TranslateString(Component,Text:String;LangID,Index,TType:Integer):String;
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   Result:=CompExec.Translator.Translate(Text);
end;
function TUICompExec.FormDataChanged(Value:String):Boolean;
begin
   Result:=True;
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   Result:=CompExec.FormDataChanged(Value);
end;
function TUICompExec.GetPictureFromServer(Value:String):TBitMap;
begin
   Result:=nil;
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   Result:=CompExec.GetPictureFromServer(Value);
end;
procedure TUICompExec.SetTrigger(Value:String);
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   CompExec.TriggerValue:=Value;
end;
procedure TUICompExec.FireTrigger(Value:String);
begin
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   CompExec.Trigger(Value);
end;
function TUICompExec.GetWorkStation:String;
begin
   Result:='0';
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   try  
      if CompExec <> nil then
         Result:=CompExec.WorkStation;
   except 
      ;
   end;
end;
function TUICompExec.GetOffice     :String;
begin
   Result:='0';
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   try  
      if CompExec <> nil then
         Result:=CompExec.Office;
   except 
      ;
   end;
end;
function TUICompExec.GetUser       :String;
begin
   Result:='0';
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   try  
      if CompExec <> nil then
         Result:=CompExec.User;
   except 
      ;
   end;
end;
procedure TUICompExec.SetWorkStation(Value:String);
begin
   CompExec.WorkStation:=Value;
end;
procedure TUICompExec.SetOffice(Value:String);
begin
   CompExec.Office:=Value;
end;
procedure TUICompExec.SetUser(Value:String);
begin
   CompExec.User:=Value;
end;
function TUICompExec.GetTxnLog:ITransactionLog;
begin
   Result:=CompExec.TransactionLog;
end;
function TUICompExec.Translate(Value: String):String;
begin
   Result:=Value;
   if (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
   try  
      if CompExec <> nil then
         Result:=CompExec.Translate(Value);
   except 
      ;
   end;
end;
function TUICompExec.GetCurrentExec:String;
begin
   Result:='';
   if CompExec <> nil then
      Result:=CompExec.CurrentExec;
end;
                                           
procedure TUICompExec.SelectAccount(AccountGroup:String);
begin
   if CompExec <> nil then
      CompExec.SelectAccount(AccountGroup);
end;
procedure TUICompExec.SaveCurrentState(Restore:Boolean);
begin
   if Assigned(FOnSaveCurrentState) then FOnSaveCurrentState(Restore);
end;
procedure TUICompExec.ExecuteWith(Name,Data:String);
begin
   if CompExec = nil then Exit;
   CompExec.ExecuteComponent(Name,Data);
end;
procedure TUICompExec.Execute(Name:String;CancelFirst:Boolean);
begin
   if CompExec = nil then Exit;
   if (CancelFirst) then
   begin
      CompExec.RunAfterCancel:=Name;
      CompExec.RunAfterCancelData:='';
      CompExec.Cancel;
   end
   else
   begin
      CompExec.RunAfterCancel:='';
      CompExec.RunAfterCancelData:='';
      CompExec.ExecuteComponent(Name,'');
   end;
end;
procedure TUICompExec.RefreshUI;
begin
   if CompExec <> nil then CompExec.Refresh;
end;

procedure TUICompExec.PutBack;
begin
   if CompExec <> nil then CompExec.PutBack(CompExec.CurrentExec);
end;
procedure TUICompExec.SetKeyHit;
begin
   if CompExec <> nil then CompExec.KeyHit:=True;
end;
procedure TUICompExec.SetDontTrigger(Value:Boolean);
begin
   if (CompExec <> nil) then
      CompExec.DontTrigger:=Value;
end;

procedure TUICompExec.SetTranslationOn(Value:Boolean);
var
   SL:TPackStringList;
   I:Integer;
begin
   if GetGPCSRegString('Language','TranslationOn','0') = '1' then
   begin
      if (CompExec = nil) or (CompExec.Translator = nil) then Exit;
      if Value then
      begin
         with CompExec.Translator do
         begin
            // need support for base language Id in Translator Interface!
            if CurrentLanguageID <> $809 then Exit;
            SL:=TPackStringList.Create;
            SL.CommaText:=AvailableLanguages;
            for I:=0 to SL.Count-1 do
            begin
               if SL[I] <> 'English' then
               begin
                  CurrentLanguage:=SL[I];
                  break;
               end;
            end;
            SL.Free;
         end;
      end
      else
      begin
         with CompExec.Translator do
            CurrentLanguageID:=$809;
      end;
   end;
end;
function TUICompExec.GetTranslationOn:Boolean;
begin
   Result:=False;
   if (CompExec = nil) or (CompExec.Translator = nil) then Exit;
      Result:=CompExec.Translator.CurrentLanguageID <> $809;
end;



procedure Register;
begin
   RegisterComponents('CorvusVCL',[TUICompExec]);
end;

initialization
  TComObjectFactory.Create(ComServer,TCompExec,
                          StringToGUID('{55584140-CBC8-11D1-8A92-080000223037}'),
                          'Event.EventSink','Event.EventSink',ciInternal);
end.
