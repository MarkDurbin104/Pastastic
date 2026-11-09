unit GPCSBaseAU;

interface

uses
  Windows,Registry,Forms,Classes,ComObj,SysUtils,GPCSBase_TLB,GPCSErrorLine,GPCSErrorCode,PackStrListU;

type
  TGPCSBaseComponent = class(TAutoObject, IBaseComponent)
  protected
    function AccessFunction(const FunctionName, Value: WideString): WideString; virtual; safecall;
  end;
  
  TGPCSComponent = class(TGPCSBaseComponent, IComponent)
  protected
    function Get_InterfaceVersion: Integer;                  virtual; safecall;
    function Get_Version: Integer;                           virtual; safecall; abstract;
    function Design(const Password: WideString;const EVSink:IDesignEventSink): WideString; virtual; safecall;
    procedure TerminateDesign;                               virtual; safecall;
    function Get_Name: WideString;                           virtual; safecall; abstract;
    function Get_ProjectFiles: WideString;                   virtual; safecall; abstract;
    function Get_GUID: WideString;                           virtual; safecall; abstract;
    function Get_ProgramID: WideString;                      virtual; safecall; abstract;
    function CurrentStatus: WideString;                      virtual; safecall; 
  end;
  
  TGPCSExecComponent = class(TGPCSComponent, IExecComponent)
  private
    FEventSink:IEventSink;
  protected
    function Get_EventSink: IEventSink;                  virtual; safecall;
    procedure Set_EventSink(const Value: IEventSink);    virtual; safecall;
    function Get_BitMap: OleVariant;                     virtual; safecall; abstract;
    function Get_Caption: WideString;                    virtual; safecall; abstract;
    function Get_Price(ScaleReading: Integer): Currency; virtual; safecall; abstract;
    function Get_Count: Integer;                         virtual; safecall; abstract;
    function Get_Item(Index: Integer): WideString;       virtual; safecall; abstract;
    procedure CompleteExecute(var Index:Integer;const TxnLog: ITransactionLog); virtual; safecall; abstract;
    procedure Execute(Quantity, MaxItems: Integer; NoRedraw: WordBool;
      const UIEventSink: IUIEventSink; 
      const TxnLog: ITransactionLog;Nested:WordBool);    virtual; safecall; abstract;
    procedure TerminateExecute(const TxnLog: ITransactionLog); virtual; safecall; abstract;
    function Get_PMessage: WideString;                   virtual; safecall; abstract;
    function Get_Prompt  : WideString;                   virtual; safecall; abstract;
    function Get_Title   : WideString;                   virtual; safecall; abstract;
    procedure NotifyChildClick(const Name: WideString; Index: Integer); virtual; safecall;
    function Get_NeedsWeight: WordBool; virtual; safecall;
    procedure TriggerValue(Source: TriggerSource; const Value: WideString); virtual; safecall; 
    function Get_CanTerminate: WordBool; virtual; safecall;
  public
    destructor Destroy; override;
  end;
  
  TGPCSAbstractProduct = class(TGPCSExecComponent, IProduct)
  protected
    function Get_BarCode: WideString;     virtual; safecall; abstract;
    function Get_Description: WideString; virtual; safecall; abstract;
    function Get_EndDate: WideString;     virtual; safecall; abstract;
    function Get_HighDays: WideString;    virtual; safecall; abstract;
    function Get_MaxQuantity: Integer;    virtual; safecall; abstract;
    function Get_MCRCode: WideString;     virtual; safecall; abstract;
    function Get_MinQuantity: Integer;    virtual; safecall; abstract;
    function Get_OCRCode: WideString;     virtual; safecall; abstract;
    function Get_OtherCode: WideString;   virtual; safecall; abstract;
    function Get_PLU: Integer;            virtual; safecall; abstract;
    function Get_Regulations: WideString; virtual; safecall; abstract;
    function Get_StartDate: WideString;   virtual; safecall; abstract;
    function Get_UnitPrice: Currency;     virtual; safecall; abstract;
    function Get_UnitQuantity: Integer;   virtual; safecall; abstract;
    function Get_UseDays: WideString;     virtual; safecall; abstract;
    function GetExecData: WideString;     virtual; safecall;
    function SetExecData(const Value: WideString;var FlagError: WordBool): WideString; virtual; safecall;
    function Get_AvailableAfterEOD: WordBool; virtual; safecall;
    function Get_MOPs: WideString; virtual; safecall;
    function Get_Taxes: WideString; virtual; safecall;
  end;
  
  TGPCSAbstractGroup = class(TGPCSExecComponent, IGroup)
  protected
    function Get_Key: Integer;                      virtual; safecall; abstract;
  end;
  
  TGPCSAbstractWUGroup = class(TGPCSComponent, IWUGroup)
  protected
    function Get_Count: Integer;                     virtual; safecall; abstract;
    function Get_Item(Index: Integer): WideString;   virtual; safecall; abstract;
    procedure ApplyGroup(const WUGroup: WideString); virtual; safecall; abstract;
    procedure Set_Item(Index: Integer; const Value: WideString); safecall;
  end;
                                
  TGPCSAbstractPickList = class(TGPCSComponent, IPickList)
  protected
    function Get_RowCount: Integer;                       virtual; safecall; abstract;
    function Get_Item(Index: Integer): WideString;        virtual; safecall; abstract;
    function Get_ColumnCount: Integer;                    virtual; safecall; abstract;
    function Get_ColumnName(Index: Integer): WideString;  virtual; safecall; abstract;
    function Get_CurrentColumn: WideString;               virtual; safecall; abstract;
    procedure Set_CurrentColumn(const Value: WideString); virtual; safecall; abstract; 
  end;
  
  TGPCSAbstractLookUp = class(TGPCSComponent, ILookUp)
  protected
    function Get_RowCount: Integer;                       virtual; safecall; abstract;
    function Get_ColumnCount: Integer;                    virtual; safecall; abstract;
    function Get_ColumnName(Index: Integer): WideString;  virtual; safecall; abstract;
    function Get_Value(Index:Integer):WideString;         virtual; safecall; abstract;
    function Get_Item(Index:Integer): WideString;         virtual; safecall; abstract;
    function Get_CurrentColumn: WideString;               virtual; safecall; abstract;
    procedure Set_CurrentColumn(const Value: WideString); virtual; safecall; abstract;
    function Get_Range(Index: Integer): WideString;       virtual; safecall; abstract;
  end;
                                                         
  TGPCSAbstractEventSink = class(TGPCSComponent, IEventSink)
  protected
    procedure Complete(const EventSource: IExecComponent);       virtual; safecall; abstract;
    procedure DesignComplete(const EventSource: IExecComponent); virtual; safecall; abstract;
  end;
  
  TGPCSAbstractUIEventSink = class(TGPCSComponent, IUIEventSink)
  protected
    FUser       :String;
    FOffice     :String;
    FWorkstation:String;
    procedure DisplayItemInfo(const EventSource: IExecComponent; Index: Integer;BitMap:OleVariant;const Caption: WideString; Price: Currency; State: Integer; Notify,Nested: WordBool); virtual; safecall; abstract;
    procedure Restore; virtual; safecall; abstract;
    procedure DisplayInstructions(Style: InstructStyle;const Text:WideString;BitMap:OleVariant); virtual; safecall; abstract;
    procedure DataChanged(const EventSource: IExecComponent;const Value: WideString; FlagError: WordBool); virtual; safecall; abstract;
    function GetComponentReference(const Name: WideString): IDispatch;  virtual; safecall; abstract;
    function CurrentDetails: WideString; virtual; safecall; abstract;
    function Translate(const Value: WideString): WideString; virtual; safecall; abstract;
    function Endorse(X,Y,ColCount:Integer;const CommaText:WideString):WordBool; virtual; safecall; abstract;
    procedure WaitFor(DeviceStatus: DeviceStatusType); virtual; safecall; abstract;
    procedure SwapTo(const ProgID, PassData: WideString); virtual; safecall; abstract;
    function Get_Office: Integer; virtual; safecall; abstract;
    function Get_User: WideString; virtual; safecall; abstract;
    function Get_Workstation: Integer; virtual; safecall; abstract;
    function ReferenceData(const Name: WideString): WideString; virtual; safecall; abstract;
    function CurrentLine: Integer; virtual; safecall; abstract;
    procedure Print2x2(const Title,Desc1,Desc2,Office,DataCommatext:WideString); virtual; safecall; abstract;
    function Get_HookUp: IHookUp; virtual; safecall;
    procedure ProgressBar(const Title: WideString; Min, Max, Pos, Auto: Integer); virtual; safecall; abstract;
    procedure OpenCashDrawer; virtual; safecall; abstract;
    procedure TransferTxnsToDiskette; virtual; safecall; abstract;
    procedure TransferTxnsFromDiskette; virtual; safecall; abstract;
  end;                      
                          
  TGPCSCompFactory = class(TComObjectFactory)
     function GetProgID: string; override;
  end;
  
  TGPCSAbstractService = class(TGPCSExecComponent, IService)
  protected
  end;
  TAbstractCompLoad = class(TGPCSBaseComponent,ICompLoad)
  protected
    function LoadComponent(const GUID: WideString): IUnknown; virtual; safecall; abstract;
    procedure Show;                                           virtual; safecall; abstract;
    procedure Hide;                                           virtual; safecall; abstract;
  end;
  
  TAbstractCompMan = class(TGPCSBaseComponent,ICompMan)
  protected
    function LoadComponent(const Name: WideString): IUnknown; virtual; safecall; abstract;
    procedure Show;                                           virtual; safecall; abstract;
    procedure Hide;                                           virtual; safecall; abstract;
    function Get_AsToolBar: WordBool;                         virtual; safecall; abstract;
    procedure Set_AsToolBar(Value: WordBool);                 virtual; safecall; abstract;
    function Get_Ready: WordBool;                             virtual; safecall; abstract;
  end;
  
  TAbstractErrorHandler = class(TGPCSBaseComponent,IErrorHandler)
  protected
    procedure RaiseError(ErrorPlaceCode, ErrorTypeCode, ErrorPriority: Integer;
                         const ErrorData: WideString);                          virtual; safecall; abstract;
    function Get_Visible: WordBool;                                             virtual; safecall; abstract;
    procedure Set_Visible(Value: WordBool);                                     virtual; safecall; abstract;
    function Get_LogFile: WideString;                                           virtual; safecall; abstract;
    procedure Set_LogFile(const Value: WideString);                             virtual; safecall; abstract;
  end;     
  TGPCSAbstractSysGroup = class(TGPCSExecComponent, ISysGroup)
  protected
  end;
  TAbstractTransactionLog = class(TGPCSComponent,ITransactionLog)
  protected    
    function Get_Total: Currency;                        virtual; safecall; abstract;
    function Get_User: WideString;                       virtual; safecall; abstract;
    function Get_Office: Integer;                        virtual; safecall; abstract;
    function Get_Workstation: Integer;                   virtual; safecall; abstract;
    procedure CancelCustomer;                            virtual; safecall; abstract;
    procedure EndCustomer(const UniqueID:WideString);    virtual; safecall; abstract;
    procedure Set_User(const Value: WideString);         virtual; safecall; abstract;
    procedure Set_Workstation(Value: Integer);           virtual; safecall; abstract;
    procedure Set_Office(Value: Integer);                virtual; safecall; abstract;
    procedure Set_Parent(Value: Integer);                virtual; safecall; abstract;
    procedure LogTransaction(Index,Quantity,PLU:Integer;Value,Price:Currency;
               const Description,Additional,ProgID,DomInfo:WideString); virtual; safecall; abstract;
    procedure WriteTransaction(const TxnType:WideString;Index, Quantity, PLU: Integer; 
               Value, Price: Currency; const Description, Additional, ProgID, 
               DomInfo: WideString); virtual; safecall; abstract;
    procedure SubLogClear;                               virtual; safecall; abstract;
    procedure SubLogTransaction(Index,Quantity,PLU:Integer;Value,Price:Currency;
               const Description,Additional,ProgID,DomInfo:WideString); virtual; safecall; abstract;
    function Get_Additional(Index: Integer): WideString; virtual; safecall; abstract;
    function Get_Description(Index: Integer):WideString; virtual; safecall; abstract; 
    function Get_ItemCount: Integer;                     virtual; safecall; abstract;
    function Get_ItemIndex(Index: Integer): Integer;     virtual; safecall; abstract;
    function Get_Price(Index: Integer): Currency;        virtual; safecall; abstract;
    function Get_Quantity(Index: Integer): Integer;      virtual; safecall; abstract;
    function Get_Value(Index: Integer): Currency;        virtual; safecall; abstract;
    procedure PrintReceipt;                              virtual; safecall; abstract;
    procedure SetEventSink(const EventSink: ITxnEventSink); virtual; safecall; abstract;
    function Get_Contents: WideString;                   virtual; safecall; abstract;
    procedure Set_SubLogVisible(Value:WordBool);         virtual; safecall; abstract;
    function Get_SubLogVisible: WordBool;                virtual; safecall; abstract;
    function Get_PLU(Index: Integer): Integer;           virtual; safecall; abstract;
    function Get_DomInfo(Index: Integer): WideString;    virtual; safecall; abstract;
    function Get_ProgID(Index: Integer): WideString;     virtual; safecall; abstract;
    function GetExecData(Index: Integer; var ProgID: WideString): WideString; virtual; safecall; abstract;
    procedure Delete(Index: Integer);                    virtual; safecall; abstract;
    function RetrieveAccountsFor(const ProgIDList:WideString):WideString; virtual; safecall; abstract;
    procedure LogToAccounts(Quantity,PLU:Integer;Value:Currency;const ProgID:WideString); virtual; safecall; abstract;
    function RetrieveTxnsFor(const SQLString: WideString): WideString; virtual; safecall; abstract;
    function Get_Hook: IHookUp; virtual; safecall; abstract;
    procedure Set_Hook(const Value: IHookUp); virtual; safecall; abstract;
    procedure WriteFullTransaction(WsNumber, Period, Index, Office: Integer;
      const TxnType, Teller: WideString; Quantity, PLU: Integer; Value,
      Price: Currency; const Description, Info, ProdID, Ident,
      DomInfo: WideString); safecall;
  end;
  TAbstractTxnEventSink = class(TGPCSComponent, ITxnEventSink)
  protected
    procedure OnChange(const EventSource: ITransactionLog); virtual; safecall; abstract;
    procedure LoggedTransaction(Index, Quantity, PLU: Integer; Value,
      Price: Currency; const Description, Additional, ProgID,
      DomInfo: WideString); virtual; safecall; abstract;
    procedure VoidedTransaction(Index, Quantity, PLU: Integer; Value,
      Price: Currency; const Description, Additional, ProgID,
      DomInfo: WideString); virtual; safecall; abstract;
  end;
  
  TExecComponent = class
     FInstance:IExecComponent;
     FHadResponce:Boolean;
     FExecuting:Boolean;
  public        
     constructor Create(Instance:IExecComponent);
     destructor Destroy; override;
     property Instance   :IExecComponent read FInstance    write FInstance   ;
     property HadResponce:Boolean        read FHadResponce write FHadResponce;
     property Executing  :Boolean        read FExecuting   write FExecuting  ;
  end;
  TItemList = class
  private
     FItems:TPackStringList;
     function GetCount:Integer;
     function GetItem(Index:Integer):TExecComponent;
  public
     constructor Create;
     destructor Destroy; override;
     function Add(Instance:IExecComponent;Name:String):Integer;
     function IndexOf(Name:String):Integer;
     property Count:Integer read GetCount;
     property Items[Index:Integer]:TExecComponent read GetItem; default;
  end;
  TGPCSDevice = class(TGPCSComponent, IDevice)
  protected
     procedure SetEventSink(const EventSink: IDeviceEventSink);                          virtual; safecall; abstract;
     function  WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool; virtual; safecall; abstract;
     function  ReadDevice(var Data:WideString;var Len:Integer):WordBool;                     virtual; safecall; abstract;
     function  GetStatus: WideString;                                                    virtual; safecall; abstract;
     function  TakeControl: WordBool;                                                    virtual; safecall;
     procedure ReleaseControl;                                                           virtual; safecall;
  end;

  TDeviceEventSink = class(TGPCSComponent, IDeviceEventSink)
  protected
     procedure Trigger(const Data: WideString); virtual; safecall;
     procedure ControlReleased;                 virtual; safecall;
  end;
  TPictureServer = class(TGPCSComponent, IPictureServer)
  protected
    function Bitmap(const Named: WideString): WideString; virtual; safecall;
    function Get_PictureNames: WideString;          virtual; safecall;
    function ZLBitMap(const Named: WideString): OleVariant; virtual; safecall;
  end;
  TMailItemLog = class(TGPCSComponent, IMailItemLog)
  private
     FOffice:Integer;
     FUser:String;
     FWorkStation:Integer;
  protected
    procedure AddItem(const TrackingNumber: WideString; Weight: Integer;
      const Destination: WideString; Value: Currency; const Info: WideString);
      virtual; safecall;
    function Get_Office: Integer; safecall;
    function Get_User: WideString; safecall;
    function Get_Workstation: Integer; safecall;
    function List: WideString; virtual; safecall;
    procedure Set_Office(Value: Integer); safecall;
    procedure Set_User(const Value: WideString); safecall;
    procedure Set_Workstation(Value: Integer); safecall;
    procedure WriteToStore; virtual; safecall;
    procedure ClearLog; virtual; safecall;
  end;
  TBaseExchangeRateServer = class(TGPCSComponent, IExchangeRateServer)
  protected
    function RateFor(const Country: WideString): Currency; virtual; safecall; 
    function Exchange(const Country: WideString; Amount: Currency): Currency; virtual; safecall;
    function GetRatesAsCommaText: WideString; virtual; safecall;
    procedure SetRateFor(const Country: WideString; NewRate: Currency); virtual; safecall;
  end;
  
  TBaseHotKeys = class(TGPCSComponent,IHotKeys)
  private
     FWorkstationType:WideString;
     FUserType       :WideString;
  protected
    function ComponentToExecute(KeyStroke,ShiftState: Integer): WideString; virtual; safecall;
    function Get_UserType: WideString; virtual; safecall;
    function Get_WorkstationType: WideString; virtual; safecall;
    procedure Set_UserType(const Value: WideString); virtual; safecall;
    procedure Set_WorkstationType(const Value: WideString); virtual; safecall;
  end;
  TGPCSAccounts = Class(TGPCSComponent,IAccounts)
  protected
     FPeriod     :Integer;
     FUser       :String;
    function GetAccountDetails(const AccountGroup, PeriodList: WideString): WideString; virtual; safecall; abstract;
    procedure TransferStock(const UserFrom, UserTo, Name: WideString; Value: Currency; Quantity: Integer); virtual; safecall; abstract;
    procedure ReturnStock(const Name: WideString; Value: Currency; Quantity: Integer); virtual; safecall; abstract;
    procedure ReceiveStock(const Name: WideString; Value: Currency; Quantity: Integer); virtual; safecall; abstract;
    procedure LogItem(const ItemID: WideString; Value: Currency; Quantity: Integer); virtual; safecall; abstract;
    function GetCurrentStockLevels(const List: WideString): WideString; virtual; safecall; abstract;
    procedure SetStockLevel(const Name:WideString;Value:Currency;Quantity:Integer); virtual; safecall; abstract;
    procedure EndOfDay(var CashValue, StockValue: Currency);   virtual; safecall; abstract;
    procedure StartOfDay(var CashValue, StockValue: Currency); virtual; safecall; abstract;
    function HasPeriodStarted(const User: WideString): WordBool; virtual; safecall; abstract;
    function GetLastEndOfDay(var CashValue, StockValue: Currency):Integer; virtual; safecall; abstract;
    procedure DispatchRem(const Name:WideString;Value:Currency;Quantity:Integer); virtual; safecall; abstract;
    procedure ReceiveRem(const Name:WideString;Value:Currency;Quantity:Integer); virtual; safecall; abstract;
    function Get_Period: Integer; virtual; safecall;
    procedure Set_Period(Value: Integer); virtual; safecall;
    function Get_User: WideString; virtual; safecall;
    procedure Set_User(const Value: WideString); virtual; safecall;
    function Get_SystemTime: TDateTime; safecall;
    function GetNewProducts: WideString; virtual; safecall;
    procedure CreateNewProduct(const Name, AType, ALine: WideString; Value: Currency); virtual; safecall;
    procedure SellNewProduct(const Name: WideString; Value: Currency); virtual; safecall;
    function Get_AccountUsers: WideString; virtual; safecall;
    function SelectCurrentPeriod: WordBool; virtual; safecall;
  end;
  TGPCSSiteManager = class(TGPCSComponent, ISiteManager)
  protected
    function ApplyUpdate(UpdateType:SMUpdateType;const FromMachineData:WideString):WordBool; virtual; safecall; abstract;
    function CopyFile(const FromMachine,FromPath,FromFile,ToMachine,ToPath,ToFile:WideString):WordBool; virtual; safecall; abstract;
    function CurrentVersion:WideString; virtual; safecall; abstract;
    function ShutDownGPCS:WordBool; virtual; safecall; abstract;
    function StartUpGPCS:WordBool; virtual; safecall; abstract;
    function WhosHere:WideString; virtual; safecall; abstract;
    procedure LogOffMachine; virtual; safecall; abstract;
    procedure ReLoadComponents(const ProgIDs:WideString); virtual; safecall; abstract;
    procedure ShutDownMachine; virtual; safecall; abstract;
    function GetLocalFile(const Path,Name:WideString;var DateTime: TDateTime):OleVariant; virtual; safecall; abstract;
    function SetLocalFile(const Path,Name:WideString;DateTime:TDateTime;Value:OleVariant):WordBool; virtual; safecall; abstract;
  end;
  
  TGPCSRemoteControl = class(TGPCSBaseComponent,IRemoteControl)
    function Execute(const ExecName: WideString): WideString;  virtual; safecall; abstract;
    function KeyStroke(const KeyName: WideString): WideString; virtual; safecall; abstract;
    function ScreenShot: OleVariant;                     virtual; safecall; abstract;
    function HelpText: WideString;                       virtual; safecall; abstract;
    function Get_Title: WideString;                      virtual; safecall; abstract;
  protected
    function Get_DateEnabled: WordBool; virtual; safecall; abstract;
    function Get_ScaleReading: Integer; virtual; safecall; abstract;
    procedure Set_DateEnabled(Value: WordBool); virtual; safecall; abstract;
    procedure Set_ScaleReading(Value: Integer); virtual; safecall; abstract;
  end;
  TGPCSHookUp = class(TGPCSBaseComponent,IHookUp)
  protected
    function Get_Accounts: IAccounts; virtual; safecall;
    function Get_Counters: IDevice; virtual; safecall;
    function Get_DatabaseServer: IDispatch; virtual; safecall;
    procedure KeepAwake; virtual; safecall;
    procedure ReleaseHooks; virtual; safecall;
    function Get_Translate: ITranslate; virtual; safecall;
  end;
  TGPCSStock = class(TGPCSBaseComponent,IStock)
  protected
    function ListAllStock(const Owner, StockGroup: WideString): WideString; virtual; safecall; abstract;
    function ListAvailableStock(const Owner, StockGroup: WideString): WideString; virtual; safecall; abstract;
    function ListPendingTransfersFrom(const Owner: WideString): WideString; virtual; safecall; abstract;
    function ListPendingTransfersTo(const Owner: WideString): WideString; virtual; safecall; abstract;
    function ListTransferStock(const FromOwner,ToOwner: WideString): WideString; virtual; safecall; abstract;
    function QueryStockLevel(const Owner, StockItemName: WideString): Integer; virtual; safecall; abstract;
    procedure ClearTempAdjustments(const Owner:WideString); virtual; safecall; abstract;
    procedure AdjustStockLevel(const Owner, StockItemName: WideString; Quantity: Integer); virtual; safecall; abstract;
    procedure ChangeStockTransfer(const FromOwner, ToOwner, StockItemName: WideString; Quantity: Integer); virtual; safecall; abstract;
    procedure CreateNewStockUnit(const Owner, StockUnitType: WideString); virtual; safecall; abstract;
    procedure DeleteStockUnit(const Owner, StockUnitType: WideString); virtual; safecall; abstract;
    procedure SetStockLevel(const Owner, StockItemName: WideString; Quantity: Integer); virtual; safecall; abstract;
    procedure SetupStockTransfer(const FromOwner, ToOwner, StockItemName: WideString; Quantity: Integer); virtual; safecall; abstract;
    procedure TransferStock(const FromOwner, ToOwner: WideString); virtual; safecall; abstract;
    procedure AddNewStockItem(const Description:WideString;Value:Currency;const Group:WideString;PLU:Integer;const AccountLine,AcctType,Report,ProgID,SUTypes:WideString); virtual; safecall; abstract;
    function GetStockItemDetails(const Description: WideString): WideString; virtual; safecall; abstract;
    procedure DeleteStockItem(const Description: WideString); virtual; safecall; abstract;
  end;
  TUIServer = class(TGPCSBaseComponent,IUIServer)
  protected
    function Get_Client: IUIStyle; virtual; safecall; abstract;
    procedure Set_Client(const Value: IUIStyle); virtual; safecall; abstract;
    procedure OnButtonClick(const Sender: IButton); virtual; safecall; abstract;
  end;
  TUILink = class(TGPCSBaseComponent,IUILink)
  protected
    function GetCurrentLine: Integer; virtual; safecall; abstract;
    function GetMaxCurrentLine: Integer; virtual; safecall; abstract;
    procedure ClearUI; virtual; safecall; abstract;
    procedure SetButtonInfo(Index: Integer; const Caption: WideString;
      PictureID:Integer; Price: Currency; Enabled,
      Selected: WordBool); virtual; safecall; abstract;
    procedure SetButtonState(Index: Integer; State: ButtonState); virtual; safecall; abstract;
    procedure SetCurrentLine(Value: Integer); virtual; safecall; abstract;
    procedure SetFormState(Value: FormState); virtual; safecall; abstract;
    procedure SetHint1(const Value: WideString); virtual; safecall; abstract;
    procedure SetHint2(const Value: WideString); virtual; safecall; abstract;
    procedure SetLineInfo(Index: Integer; const Caption: WideString); virtual; safecall; abstract;
    procedure SetPrompt(const Value: WideString); virtual; safecall; abstract;
    procedure SetText(const Value: WideString); virtual; safecall; abstract;
    procedure SetTitle(const Value: WideString); virtual; safecall; abstract;
    function Get_MaxItem: Integer; virtual; safecall; abstract;
    procedure Set_MaxItem(Value: Integer); virtual; safecall; abstract;
    procedure SetServerName(const Value: WideString); virtual; safecall; abstract;
    function GetPictureIdentFromCRC(CRC: Integer): Integer; virtual; safecall; abstract;
    function SavePicture(const Picture: IBitMap): Integer; virtual; safecall; abstract;
    procedure SetUIClientSink(const UIClientSink: IUIClientSink); virtual; safecall; abstract;
    procedure SetPicture(PictureID: Integer); virtual; safecall; abstract;
  end;
  TUIState = class(TGPCSBaseComponent,IUIState)
  protected
    procedure ShowForm(const Items: IPickItemList; const Product: IProduct; const HItems: IPickItemList; const HText: WideString); virtual; safecall; abstract;
    function ShowWarning(const WButtons: IPickItemList; const Warning: WideString): Integer; virtual; safecall; abstract;
    procedure ShowHelp(const HelpText: WideString); virtual; safecall; abstract;
    procedure ShowInfo(const HelpText: WideString); virtual; safecall; abstract;
    function PickItem(const Items: IPickItemList; ShowNumbers, Sorted: WordBool; DefaultItem: Integer): Integer; virtual; safecall; abstract;
    function PickMenuItem(const Items: IPickItemList; const TransactionLog: ITransactionLog): Integer; virtual; safecall; abstract;
    function Get_CurrentState: FormState; virtual; safecall; abstract;
    procedure Set_CurrentState(Value: FormState); virtual; safecall; abstract;
  end;
 
  TPeriod = class(TGPCSBaseComponent,IPeriod)
  protected
    function GetCurrentPeriod(const User: WideString): Integer;  virtual; safecall; abstract;
    procedure EndOfDay(const User: WideString); virtual; safecall; abstract;
    procedure Open(const User: WideString; Period: Integer); virtual; safecall; abstract;
    procedure StartOfDay(const User: WideString); virtual; safecall; abstract;
    function GetStartOfDayValues(const User: WideString):WideString; virtual; safecall; abstract;
    function  HadEndOfDay(const User: WideString):WordBool; virtual; safecall; abstract;
    function GetLastPeriod(const User: WideString): Integer; virtual; safecall; abstract;
    function GetLastPeriodCash(const User: WideString): Currency; virtual; safecall; abstract;
    function GetPeriodCash(const User: WideString): Currency; virtual; safecall; abstract;
    function GetPeriodStock(const User: WideString): Currency; virtual; safecall; abstract;
    function GetESState(const User: WideString): esState; virtual; safecall; abstract;
  end;
  TTableMonitor = class(TGPCSBaseComponent,ITableMonitor)
  protected
    procedure Attach; virtual; safecall; abstract;
    procedure WriteTransactions(const PackText: WideString); virtual; safecall; abstract;
  end;
  TTranslate = class(TGPCSBaseComponent,ITranslate)
  protected
    function Get_AvailableLanguages:WideString; virtual; safecall; abstract;
    function Get_CurrentLanguage:WideString; virtual; safecall; abstract;
    function Get_CurrentLanguageID:Integer; virtual; safecall; abstract;
    function Get_DefaultLanguage:WideString; virtual; safecall; abstract;
    function Get_DefaultLanguageID:Integer; virtual; safecall; abstract;
    function Get_LanguageDataPath:WideString; virtual; safecall; abstract;
    function Get_Modified:WordBool; virtual; safecall; abstract;
    function Get_SaveOnAdd:WordBool; virtual; safecall; abstract;
    function Get_SaveOnClose:WordBool; virtual; safecall; abstract;
    function Translate(const Text:WideString):WideString; virtual; safecall; abstract;
    function TranslateCommaText(const Text,TransCols:WideString):WideString; virtual; safecall; abstract;
    function TranslateFromTo(const Text,FromLanguage,ToLanguage:WideString):WideString; virtual; safecall; abstract;
    procedure Save; virtual; safecall; abstract;
    procedure Set_CurrentLanguage(const Value:WideString); virtual; safecall; abstract;
    procedure Set_CurrentLanguageID(Value:Integer); virtual; safecall; abstract;
    procedure Set_SaveOnAdd(Value:WordBool); virtual; safecall; abstract;
    procedure Set_SaveOnClose(Value:WordBool); virtual; safecall; abstract;
  end;

  TMessenger = class(TGPCSBaseComponent,IMessenger)
  protected
    function Get_Data: WideString; virtual; safecall; abstract;
    function Get_Name: WideString; virtual; safecall; abstract;
    function SetEvSink(const Sink: IMessenger): IMessenger; virtual; safecall; abstract;
    procedure Set_Data(const Value: WideString); virtual; safecall; abstract;
    procedure ShutDown; virtual; safecall; abstract;
  end;
  
  
function GetTodayasPeriod:Integer;
function CurrentMemoryStatus: WideString;

var
   ThisProgID:String;

implementation

{TGPCSCompFactory}

function GetTodayasPeriod:Integer;
const
  DaysUntil_010198 = 35796;
begin
   Result:=Trunc(Date)-DaysUntil_010198;
end;
function TGPCSCompFactory.GetProgID: string;
begin
   Result:='';
   try
      ThisProgID:=ClassName;
      Result:=ThisProgID;
   except
//      on E:Exception do RaiseException(EC_GPCSBase_TGPCSCompFactory_GetProgID,E);
   end;
end;
{TGPCSBaseComponent}
function TGPCSBaseComponent.AccessFunction(const FunctionName, Value: WideString): WideString;
begin
end;

{TGPCSComponent}

function TGPCSComponent.Get_InterfaceVersion: Integer;
begin
   try
      Result:=3;
   except
      on E:Exception do RaiseException(EC_GPCSBase_TGPCSComponent_Get_InterfaceVersion,E);
   end;
end;
function TGPCSComponent.Design(const Password: WideString;const EVSink:IDesignEventSink): WideString;
begin
   Result:='';
end;
procedure TGPCSComponent.TerminateDesign;
begin
end;

function CurrentMemoryStatus: WideString;
var
   HeapStat:THeapStatus;
   SL:TPackStringList;
begin
   try
      SL:=TPackStringList.Create;
      HeapStat:=GetHeapStatus;
      SL.Add('TotalAddrSpace   = '+IntToStr(HeapStat.TotalAddrSpace  ));
      SL.Add('TotalUncommitted = '+IntToStr(HeapStat.TotalUncommitted));
      SL.Add('TotalCommitted   = '+IntToStr(HeapStat.TotalCommitted  ));
      SL.Add('TotalAllocated   = '+IntToStr(HeapStat.TotalAllocated  ));
      SL.Add('TotalFree        = '+IntToStr(HeapStat.TotalFree       ));
      SL.Add('FreeSmall        = '+IntToStr(HeapStat.FreeSmall       ));
      SL.Add('FreeBig          = '+IntToStr(HeapStat.FreeBig         ));
      SL.Add('Unused           = '+IntToStr(HeapStat.Unused          ));
      SL.Add('Overhead         = '+IntToStr(HeapStat.Overhead        ));
      SL.Add('HeapErrorCode    = '+IntToStr(HeapStat.HeapErrorCode   ));
      Result:=SL.CommaText;
      SL.Free;
   except
      on E:Exception do RaiseException(EC_GPCSBase_TGPCSComponent_Get_InterfaceVersion,E);
   end;
end;

function TGPCSComponent.CurrentStatus: WideString;
begin
   Result:=CurrentMemoryStatus;
end;

{TGPCSExecComponent}

destructor TGPCSExecComponent.Destroy;
begin
   try
      FEventSink:=nil;
      inherited Destroy;
   except
      on E:Exception do RaiseException(EC_GPCSBase_TGPCSExecComponent_Destroy,E);
   end;
end;

function TGPCSExecComponent.Get_EventSink: IEventSink;
begin
   try
      Result:=FEventSink;
   except
      on E:Exception do RaiseException(EC_GPCSBase_TGPCSExecComponent_Get_EventSink,E);
   end;
end;
procedure TGPCSExecComponent.Set_EventSink(const Value: IEventSink);
begin
   try
      FEventSink:=Value;
   except
      on E:Exception do RaiseException(EC_GPCSBase_TGPCSExecComponent_Set_EventSink,E);
   end;
end;

{TExecComponent}
constructor TExecComponent.Create(Instance:IExecComponent);
begin
   FInstance:=Instance;
   FExecuting:=False;
   FHadResponce:=False;
end;
destructor TExecComponent.Destroy;
begin
   if FInstance <> nil then
      FInstance.EventSink:=nil;
   FInstance:=nil;
   inherited Destroy;
end;

{TItemList}
constructor TItemList.Create;
begin
   FItems:=TPackStringList.Create;
end;
destructor TItemList.Destroy;
var
   I:Integer;
begin
   for I:=0 to Count-1 do 
      if FItems.Objects[I] <> nil then
         TExecComponent(FItems.Objects[I]).Free;
   FItems.Free;
   inherited Destroy;
end;
function TItemList.IndexOf(Name:String):Integer;
begin
   Result:=FItems.IndexOf(Name);
end;
function TItemList.GetCount:Integer;
begin
   Result:=FItems.Count;
end;
function TItemList.GetItem(Index:Integer):TExecComponent;
begin
   if Index < FItems.Count then
      Result:=TExecComponent(FItems.Objects[Index])
   else
      Result:=nil;
end;
function TItemList.Add(Instance:IExecComponent;Name:String):Integer;
var
   ExecComponent:TExecComponent;
begin
   ExecComponent:=TExecComponent.Create(Instance);
   if ExecComponent <> nil then
      Result:=FItems.AddObject(Name,TObject(ExecComponent))
   else
      Result:=-1;
end;

function TGPCSAbstractProduct.GetExecData: WideString;
begin
   Result:='';
end;

function TGPCSAbstractProduct.SetExecData(const Value: WideString;
  var FlagError: WordBool): WideString;
begin
   Result:=Value;
end;
procedure TGPCSExecComponent.NotifyChildClick(const Name: WideString; Index: Integer);
begin

end;

function TGPCSExecComponent.Get_NeedsWeight: WordBool;
begin
   Result:=False;
end;
procedure TGPCSExecComponent.TriggerValue(Source: TriggerSource; const Value: WideString);
begin
   ;
end;

function  TGPCSDevice.TakeControl: WordBool;
begin
   Result:=False;
end;
procedure TGPCSDevice.ReleaseControl;
begin
   ;
end;
procedure TDeviceEventSink.Trigger(const Data: WideString);
begin
   ;
end;
procedure TDeviceEventSink.ControlReleased;
begin
   ;
end;
   
function TPictureServer.Bitmap(const Named: WideString): WideString;
begin
   Result:='';
end;

function TPictureServer.Get_PictureNames: WideString;
begin
   Result:='';
end;
function TPictureServer.ZLBitMap(const Named: WideString): OleVariant;
begin
   Result:='';
end;

procedure TMailItemLog.AddItem(const TrackingNumber: WideString; Weight: Integer;
  const Destination: WideString; Value: Currency; const Info: WideString);
begin

end;

function TMailItemLog.Get_Office: Integer;
begin
   Result:=FOffice;
end;

function TMailItemLog.Get_User: WideString;
begin
   Result:=FUser;
end;

function TMailItemLog.Get_Workstation: Integer;
begin
   Result:=FWorkStation;
end;

function TMailItemLog.List: WideString;
begin
   Result:='';
end;

procedure TMailItemLog.Set_Office(Value: Integer);
begin
   FOffice:=Value;
end;

procedure TMailItemLog.Set_User(const Value: WideString);
begin
   FUser:=Value;
end;

procedure TMailItemLog.Set_Workstation(Value: Integer);
begin
   FWorkStation:=Value;
end;
procedure TMailItemLog.WriteToStore;
begin
   ;
end;
procedure TMailItemLog.ClearLog;
begin
   ;
end;

function TGPCSExecComponent.Get_CanTerminate: WordBool;
begin
   Result:=True;
end;

procedure TGPCSAbstractWUGroup.Set_Item(Index: Integer;
  const Value: WideString);
begin

end;
function TBaseExchangeRateServer.RateFor(const Country: WideString): Currency;
begin
   Result:=0;
end;
function TBaseExchangeRateServer.Exchange(const Country: WideString; Amount: Currency): Currency;
begin
   Result:=0;
end;
function TBaseHotKeys.ComponentToExecute(KeyStroke,ShiftState: Integer): WideString;
begin
   Result:='';
end;

function TBaseHotKeys.Get_UserType: WideString;
begin
   Result:=FUserType;
end;

function TBaseHotKeys.Get_WorkstationType: WideString;
begin
   Result:=FWorkstationType;
end;

procedure TBaseHotKeys.Set_UserType(const Value: WideString);
begin
   FUserType:=Value;
end;

procedure TBaseHotKeys.Set_WorkstationType(const Value: WideString);
begin
   FWorkstationType:=Value;
end;

function TBaseExchangeRateServer.GetRatesAsCommaText: WideString;
begin
   Result:='';
end;

procedure TBaseExchangeRateServer.SetRateFor(const Country: WideString;
  NewRate: Currency);
begin
end;
function TGPCSAccounts.Get_Period: Integer;
begin
   Result:=FPeriod;
end;
procedure TGPCSAccounts.Set_Period(Value: Integer);
begin
   if Value = 0 then Value:=GetTodayasPeriod;
   FPeriod:=Value;
end;
function TGPCSAccounts.Get_User: WideString;
begin
   Result:=FUser;
end;
procedure TGPCSAccounts.Set_User(const Value: WideString);
begin
   FUser:=Value;
end;

function TGPCSAccounts.Get_SystemTime: TDateTime;
var
  SystemTime: TSystemTime;
begin
  GetLocalTime(SystemTime);
  Result:=SystemTimeToDateTime(SystemTime);
end;

function TGPCSAccounts.GetNewProducts: WideString;
begin
   Result:='';
end;

procedure TGPCSAccounts.CreateNewProduct(const Name, AType, ALine: WideString; Value: Currency);
begin
end;

procedure TGPCSAccounts.SellNewProduct(const Name: WideString; Value: Currency);
begin
end;

function TGPCSHookUp.Get_Accounts:IAccounts;
begin
   Result:=nil;
end;

function TGPCSHookUp.Get_Counters:IDevice;
begin
   Result:=nil;
end;

function TGPCSHookUp.Get_DatabaseServer: IDispatch;
begin
   Result:=nil;
end;

procedure TGPCSHookUp.KeepAwake;
begin

end;

procedure TGPCSHookUp.ReleaseHooks;
begin

end;

function TGPCSAccounts.Get_AccountUsers: WideString;
begin
   Result:='';
end;

function TGPCSAccounts.SelectCurrentPeriod: WordBool;
begin
   Result:=True;
end;

function TGPCSAbstractUIEventSink.Get_HookUp: IHookUp;
begin
   Result:=nil;
end;

function TGPCSHookUp.Get_Translate: ITranslate;
begin
   Result:=nil;
end;
procedure TAbstractTransactionLog.WriteFullTransaction(WsNumber, Period,
  Index, Office: Integer; const TxnType, Teller: WideString; Quantity,
  PLU: Integer; Value, Price: Currency; const Description, Info, ProdID,
  Ident, DomInfo: WideString);
begin

end;

function TGPCSAbstractProduct.Get_AvailableAfterEOD: WordBool;
begin
   Result:=False;
end;

function TGPCSAbstractProduct.Get_MOPs: WideString;
begin
   Result:='';
end;

function TGPCSAbstractProduct.Get_Taxes: WideString;
begin
   Result:='';
end;

end.
