unit GPCSBase_TLB;

{ This file contains pascal declarations imported from a type library.
  This file will be written during each import or refresh of the type
  library editor.  Changes to this file will be discarded during the
  refresh process. }

{ GPCS Base Library }
{ Version 1.0 }

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

const
  LIBID_GPCSBase: TGUID = '{0A0D90C0-CAA9-11D1-8A92-080000223037}';

const

{ ResourceIndex }

  riVersion = 0;
  riBarCode = 1;
  riDescription = 2;
  riEndDate = 3;
  riHighDays = 4;
  riMaxQuantity = 5;
  riMCRCode = 6;
  riMinQuantity = 7;
  riOCRCode = 8;
  riOtherCode = 9;
  riPLU = 10;
  riRegulations = 11;
  riStartDate = 12;
  riUnitPrice = 13;
  riUnitQuantity = 14;
  riUseDays = 15;
  riCaption = 16;
  riBitMap = 17;
  riKey = 18;
  riCount = 19;
  riItemBase = 20;
  riTitle = 120;
  riPrompt = 121;
  riPMessage = 122;
  riRowCount = 123;
  riColumnCount = 124;
  riName = 125;
  riProjectFiles = 126;
  riGUID = 127;
  riProgramID = 128;
  riColumnName = 129;
  riTaxes = 130;
  riMOPs = 131;
  riAvailAftEOD = 132;
  riDimensionBase = 1000;
  riRange = 30000;

{ InstructStyle }

  isTextCentre = 0;
  isTextLeft = 1;
  isTextRight = 2;
  isBMP = 3;
  isBMPTopText = 4;
  isBMPBottomText = 5;
  isBMPLeftText = 6;
  isBMPRightText = 7;
  isRestore = 8;
  esTextCentre = 9;
  esTextLeft = 10;
  esTextRight = 11;
  esBMP = 12;
  esBMPTopText = 13;
  esBMPBottomText = 14;
  esBMPLeftText = 15;
  esBMPRightText = 16;

{ TriggerSource }

  tsKeyboard = 0;
  tsBarCode = 1;
  tsOCRReader = 2;
  tsMCRReader = 3;
  tsScale = 4;
  tsOtherReader = 5;
  tsStatusDevice0 = 6;
  tsStatusDevice1 = 7;
  tsStatusDevice2 = 8;
  tsStatusDevice3 = 9;
  tsStatusDevice4 = 10;
  tsStatusDevice5 = 11;
  tsStatusDevice6 = 12;
  tsStatusDevice7 = 13;
  tsStatusDevice8 = 14;
  tsStatusDevice9 = 15;

{ DeviceCommand }

  dcInitialise = 0;
  dcRawData = 1;
  dcShutdown = 2;
  dcLine1Data = 3;
  dcLine2Data = 4;
  dcLine3Data = 5;
  dcLine4Data = 6;
  dcLine5Data = 7;
  dcList1Data = 8;
  dcList2Data = 9;
  dcList3Data = 10;
  dcList4Data = 11;
  dcList5Data = 12;
  dcBinData = 13;

{ DeviceStatusType }

  dsSlipIn = 1;
  dsSlipOut = 2;

{ SMUpdateType }

  smuFileUpdate = 1;
  smuRegistryUpdate = 2;
  smuRegisterFiles = 3;
  smuUnRegisterFiles = 4;
  smuReRegisterFiles = 5;
  smuReplaceSelf = 6;

{ TextAlign }

  aLeft = 0;
  aRight = 1;
  aCentre = 2;

{ FontStyle }

  ifsNormal = 0;
  ifsBold = 1;
  ifsItalic = 2;
  ifsBoldItalic = 3;

{ FormState }

  uisNone = 1;
  uisPick = 2;
  uisForm = 3;
  uisMenu = 4;
  uisTrans = 5;
  uisHelp = 6;
  uisInfo = 7;

{ ButtonState }

  bsUp = 1;
  bsDown = 2;
  bsToggle = 3;

{ esState }

  esStateFinished = 1;
  esStateStarted = 2;
  esStateNotFinished = 4;
  esStateNotStarted = 8;
  esStateStartNewDay = 18;

const

{ Component class GUIDs }
  Class_GPCSExecComponent: TGUID = '{8BEA5961-CB18-11D1-8A92-080000223037}';
  Class_GPCSAbstractProduct: TGUID = '{0A0D90C9-CAA9-11D1-8A92-080000223037}';
  Class_GPCSAbstractGroup: TGUID = '{0A0D90CA-CAA9-11D1-8A92-080000223037}';
  Class_GPCSAbstractWUGroup: TGUID = '{0A0D90CB-CAA9-11D1-8A92-080000223037}';
  Class_GPCSAbstractPickList: TGUID = '{0A0D90CC-CAA9-11D1-8A92-080000223037}';
  Class_GPCSAbstractLookUp: TGUID = '{0A0D90CD-CAA9-11D1-8A92-080000223037}';
  Class_GPCSAbstractEventSink: TGUID = '{0A0D90CE-CAA9-11D1-8A92-080000223037}';
  Class_GPCSAbstractUIEventSink: TGUID = '{2A60DF81-CD29-11D1-8A92-080000223037}';
  Class_GPCSAbstractService: TGUID = '{2A60DF83-CD29-11D1-8A92-080000223037}';
  Class_AbstractCompLoad: TGUID = '{9D67CA61-CE9C-11D1-8A92-080000223037}';
  Class_AbstractCompMan: TGUID = '{9D67CA63-CE9C-11D1-8A92-080000223037}';
  Class_AbstractErrorHandler: TGUID = '{9D67CA65-CE9C-11D1-8A92-080000223037}';
  Class_GPCSAbstractSysGroup: TGUID = '{4469B521-CF1B-11D1-8A92-080000223037}';
  Class_AbstractTransactionLog: TGUID = '{956078A1-D3F9-11D1-8B69-080000223037}';
  Class_AbstractTxnEventSink: TGUID = '{5366E741-DEFD-11D1-8B69-080000223037}';
  Class_GPCSDevice: TGUID = '{DD64C163-34F7-11D2-8B6A-080000223037}';
  Class_DeviceEventSink: TGUID = '{DD64C164-34F7-11D2-8B6A-080000223037}';
  Class_PictureServer: TGUID = '{63800F01-36D0-11D2-8B6A-080000223037}';
  Class_MailItemLog: TGUID = '{11984981-3B6E-11D2-9D88-444553540001}';
  Class_BaseExchangeRateServer: TGUID = '{B232C121-5C77-11D2-9D88-006008BA10FE}';
  Class_BaseHotKeys: TGUID = '{78A2D061-5C79-11D2-9D88-006008BA10FE}';
  Class_GPCSAccounts: TGUID = '{A2016FC4-5EF4-11D2-9D89-006008BA10FE}';
  Class_GPCSSiteManager: TGUID = '{39F80881-60B1-11D2-9D8A-006008BA10FE}';
  Class_GPCSRemoteControl: TGUID = '{9B98FBB1-748D-11D2-B94C-006008BA10FE}';
  Class_GPCSHookUp: TGUID = '{02BAF651-AC70-11D2-B9D1-006008BA10FE}';
  Class_GPCSStock: TGUID = '{9FF2E9F1-AE18-11D2-B9D8-006008BA10FE}';
  Class_UIServer: TGUID = '{273517E3-CF2B-11D2-AA05-00A0CC3A61B2}';
  Class_Translate: TGUID = '{F7BFE6C0-2B13-11D3-96F9-DEE8E6C0AD37}';
  Class_Messenger: TGUID = '{35097B40-3549-11D3-9EA4-00902707E0A1}';
  Class_UILink: TGUID = '{363E341D-9B4F-4D29-A0AA-7E2E945C2E84}';
  Class_UIState: TGUID = '{E1BF9299-91D2-4BD3-9947-C6AB13566C2D}';
  Class_Period: TGUID = '{59C12C6C-71C4-45C4-BF7A-19146E76F612}';
  Class_TableMonitor: TGUID = '{D1D61A9D-2592-484E-9F4D-C2DCA127BA19}';
  Class_GPCSComponent: TGUID = '{0A0D90C2-CAA9-11D1-8A92-080000223037}';
  Class_GPCSBaseComponent: TGUID = '{02C2D7CC-FB16-4C06-835E-ADFBFC853292}';

type

{ Forward declarations: Interfaces }
  IBaseComponent = interface;
  IBaseComponentDisp = dispinterface;
  IComponent = interface;
  IComponentDisp = dispinterface;
  IExecComponent = interface;
  IExecComponentDisp = dispinterface;
  IProduct = interface;
  IProductDisp = dispinterface;
  IGroup = interface;
  IGroupDisp = dispinterface;
  IWUGroup = interface;
  IWUGroupDisp = dispinterface;
  IPickList = interface;
  IPickListDisp = dispinterface;
  ILookUp = interface;
  ILookUpDisp = dispinterface;
  IEventSink = interface;
  IEventSinkDisp = dispinterface;
  IUIEventSink = interface;
  IUIEventSinkDisp = dispinterface;
  IService = interface;
  IServiceDisp = dispinterface;
  ICompLoad = interface;
  ICompLoadDisp = dispinterface;
  ICompMan = interface;
  ICompManDisp = dispinterface;
  IErrorHandler = interface;
  IErrorHandlerDisp = dispinterface;
  ISysGroup = interface;
  ISysGroupDisp = dispinterface;
  ITransactionLog = interface;
  ITransactionLogDisp = dispinterface;
  ITxnEventSink = interface;
  ITxnEventSinkDisp = dispinterface;
  IDevice = interface;
  IDeviceDisp = dispinterface;
  IDeviceEventSink = interface;
  IDeviceEventSinkDisp = dispinterface;
  IPictureServer = interface;
  IPictureServerDisp = dispinterface;
  IMailItemLog = interface;
  IMailItemLogDisp = dispinterface;
  IExchangeRateServer = interface;
  IExchangeRateServerDisp = dispinterface;
  IHotKeys = interface;
  IHotKeysDisp = dispinterface;
  IAccounts = interface;
  IAccountsDisp = dispinterface;
  ISiteManager = interface;
  ISiteManagerDisp = dispinterface;
  IRemoteControl = interface;
  IRemoteControlDisp = dispinterface;
  IHookUp = interface;
  IHookUpDisp = dispinterface;
  IStock = interface;
  IStockDisp = dispinterface;
  IGPCSFont = interface;
  IGPCSFontDisp = dispinterface;
  IGPCSLabel = interface;
  IGPCSLabelDisp = dispinterface;
  IBitMap = interface;
  IBitMapDisp = dispinterface;
  IButton = interface;
  IButtonDisp = dispinterface;
  IUIStyle = interface;
  IUIStyleDisp = dispinterface;
  IUIServer = interface;
  IUIServerDisp = dispinterface;
  IDesignEventSink = interface;
  IDesignEventSinkDisp = dispinterface;
  ITranslate = interface;
  ITranslateDisp = dispinterface;
  IMessenger = interface;
  IMessengerDisp = dispinterface;
  IUILink = interface;
  IUILinkDisp = dispinterface;
  IUIClientSink = interface;
  IUIClientSinkDisp = dispinterface;
  IPickItem = interface;
  IPickItemDisp = dispinterface;
  IPickItemList = interface;
  IPickItemListDisp = dispinterface;
  IUIState = interface;
  IUIStateDisp = dispinterface;
  IPeriod = interface;
  IPeriodDisp = dispinterface;
  ITableMonitor = interface;
  ITableMonitorDisp = dispinterface;

{ Forward declarations: CoClasses }
  GPCSExecComponent = IExecComponent;
  GPCSAbstractProduct = IProduct;
  GPCSAbstractGroup = IGroup;
  GPCSAbstractWUGroup = IWUGroup;
  GPCSAbstractPickList = IPickList;
  GPCSAbstractLookUp = ILookUp;
  GPCSAbstractEventSink = IEventSink;
  GPCSAbstractUIEventSink = IUIEventSink;
  GPCSAbstractService = IService;
  AbstractCompLoad = ICompLoad;
  AbstractCompMan = ICompMan;
  AbstractErrorHandler = IErrorHandler;
  GPCSAbstractSysGroup = ISysGroup;
  AbstractTransactionLog = ITransactionLog;
  AbstractTxnEventSink = ITxnEventSink;
  GPCSDevice = IDevice;
  DeviceEventSink = IDeviceEventSink;
  PictureServer = IPictureServer;
  MailItemLog = IMailItemLog;
  BaseExchangeRateServer = IExchangeRateServer;
  BaseHotKeys = IHotKeys;
  GPCSAccounts = IAccounts;
  GPCSSiteManager = ISiteManager;
  GPCSRemoteControl = IRemoteControl;
  GPCSHookUp = IHookUp;
  GPCSStock = IStock;
  UIServer = IUIServer;
  Translate = ITranslate;
  Messenger = IMessenger;
  UILink = IUILink;
  UIState = IUIState;
  Period = IPeriod;
  TableMonitor = ITableMonitor;
  GPCSComponent = IComponent;
  GPCSBaseComponent = IBaseComponent;

{ Forward declarations: Enums }
  ResourceIndex = TOleEnum;
  InstructStyle = TOleEnum;
  TriggerSource = TOleEnum;
  DeviceCommand = TOleEnum;
  DeviceStatusType = TOleEnum;
  SMUpdateType = TOleEnum;
  TextAlign = TOleEnum;
  FontStyle = TOleEnum;
  FormState = TOleEnum;
  ButtonState = TOleEnum;
  esState = TOleEnum;

  IBaseComponent = interface(IDispatch)
    ['{CF7707C8-CF06-4E63-BCF2-B07128737ECF}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; safecall;
  end;

{ DispInterface declaration for Dual Interface IBaseComponent }

  IBaseComponentDisp = dispinterface
    ['{CF7707C8-CF06-4E63-BCF2-B07128737ECF}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
  end;

{ Dispatch interface for Component Object }

  IComponent = interface(IBaseComponent)
    ['{0A0D90C1-CAA9-11D1-8A92-080000223037}']
    function Get_InterfaceVersion: Integer; safecall;
    function Get_Version: Integer; safecall;
    function Get_Name: WideString; safecall;
    function Get_ProgramID: WideString; safecall;
    function Get_GUID: WideString; safecall;
    function Get_ProjectFiles: WideString; safecall;
    function Design(const Password: WideString; const EVSink: IDesignEventSink): WideString; safecall;
    procedure TerminateDesign; safecall;
    function CurrentStatus: WideString; safecall;
    property InterfaceVersion: Integer read Get_InterfaceVersion;
    property Version: Integer read Get_Version;
    property Name: WideString read Get_Name;
    property ProgramID: WideString read Get_ProgramID;
    property GUID: WideString read Get_GUID;
    property ProjectFiles: WideString read Get_ProjectFiles;
  end;

{ DispInterface declaration for Dual Interface IComponent }

  IComponentDisp = dispinterface
    ['{0A0D90C1-CAA9-11D1-8A92-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property InterfaceVersion: Integer readonly dispid 7;
    property Version: Integer readonly dispid 8;
    property Name: WideString readonly dispid 9;
    property ProgramID: WideString readonly dispid 10;
    property GUID: WideString readonly dispid 11;
    property ProjectFiles: WideString readonly dispid 12;
    function Design(const Password: WideString; const EVSink: IDesignEventSink): WideString; dispid 13;
    procedure TerminateDesign; dispid 14;
    function CurrentStatus: WideString; dispid 99999;
  end;

  IExecComponent = interface(IComponent)
    ['{8BEA5960-CB18-11D1-8A92-080000223037}']
    function Get_BitMap: OleVariant; safecall;
    function Get_Caption: WideString; safecall;
    function Get_Price(ScaleReading: Integer): Currency; safecall;
    function Get_EventSink: IEventSink; safecall;
    procedure Set_EventSink(const Value: IEventSink); safecall;
    function Get_Count: Integer; safecall;
    function Get_Item(Index: Integer): WideString; safecall;
    function Get_Title: WideString; safecall;
    function Get_Prompt: WideString; safecall;
    function Get_PMessage: WideString; safecall;
    function Get_NeedsWeight: WordBool; safecall;
    procedure Execute(Quantity, MaxItems: Integer; NoRedraw: WordBool; const UIEventSink: IUIEventSink; const TxnLog: ITransactionLog; Nested: WordBool); safecall;
    procedure TerminateExecute(const TxnLog: ITransactionLog); safecall;
    procedure CompleteExecute(var Index: Integer; const TxnLog: ITransactionLog); safecall;
    procedure NotifyChildClick(const Name: WideString; Index: Integer); safecall;
    procedure TriggerValue(Source: TriggerSource; const Value: WideString); safecall;
    function Get_CanTerminate: WordBool; safecall;
    property BitMap: OleVariant read Get_BitMap;
    property Caption: WideString read Get_Caption;
    property Price[ScaleReading: Integer]: Currency read Get_Price;
    property EventSink: IEventSink read Get_EventSink write Set_EventSink;
    property Count: Integer read Get_Count;
    property Item[Index: Integer]: WideString read Get_Item;
    property Title: WideString read Get_Title;
    property Prompt: WideString read Get_Prompt;
    property PMessage: WideString read Get_PMessage;
    property NeedsWeight: WordBool read Get_NeedsWeight;
    property CanTerminate: WordBool read Get_CanTerminate;
  end;

{ DispInterface declaration for Dual Interface IExecComponent }

  IExecComponentDisp = dispinterface
    ['{8BEA5960-CB18-11D1-8A92-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property InterfaceVersion: Integer readonly dispid 7;
    property Version: Integer readonly dispid 8;
    property Name: WideString readonly dispid 9;
    property ProgramID: WideString readonly dispid 10;
    property GUID: WideString readonly dispid 11;
    property ProjectFiles: WideString readonly dispid 12;
    function Design(const Password: WideString; const EVSink: IDesignEventSink): WideString; dispid 13;
    procedure TerminateDesign; dispid 14;
    function CurrentStatus: WideString; dispid 99999;
    property BitMap: OleVariant readonly dispid 1;
    property Caption: WideString readonly dispid 2;
    property Price[ScaleReading: Integer]: Currency readonly dispid 3;
    property EventSink: IEventSink dispid 4;
    property Count: Integer readonly dispid 5;
    property Item[Index: Integer]: WideString readonly dispid 6;
    property Title: WideString readonly dispid 15;
    property Prompt: WideString readonly dispid 16;
    property PMessage: WideString readonly dispid 17;
    property NeedsWeight: WordBool readonly dispid 18;
    procedure Execute(Quantity, MaxItems: Integer; NoRedraw: WordBool; const UIEventSink: IUIEventSink; const TxnLog: ITransactionLog; Nested: WordBool); dispid 19;
    procedure TerminateExecute(const TxnLog: ITransactionLog); dispid 20;
    procedure CompleteExecute(var Index: Integer; const TxnLog: ITransactionLog); dispid 21;
    procedure NotifyChildClick(const Name: WideString; Index: Integer); dispid 22;
    procedure TriggerValue(Source: TriggerSource; const Value: WideString); dispid 23;
    property CanTerminate: WordBool readonly dispid 24;
  end;

  IProduct = interface(IExecComponent)
    ['{0A0D90C4-CAA9-11D1-8A92-080000223037}']
    function Get_BarCode: WideString; safecall;
    function Get_Description: WideString; safecall;
    function Get_EndDate: WideString; safecall;
    function Get_HighDays: WideString; safecall;
    function Get_MaxQuantity: Integer; safecall;
    function Get_MCRCode: WideString; safecall;
    function Get_MinQuantity: Integer; safecall;
    function Get_OCRCode: WideString; safecall;
    function Get_OtherCode: WideString; safecall;
    function Get_PLU: Integer; safecall;
    function Get_Regulations: WideString; safecall;
    function Get_StartDate: WideString; safecall;
    function Get_UnitPrice: Currency; safecall;
    function Get_UnitQuantity: Integer; safecall;
    function Get_UseDays: WideString; safecall;
    function GetExecData: WideString; safecall;
    function SetExecData(const Value: WideString; var FlagError: WordBool): WideString; safecall;
    function Get_Taxes: WideString; safecall;
    function Get_MOPs: WideString; safecall;
    function Get_AvailableAfterEOD: WordBool; safecall;
    property BarCode: WideString read Get_BarCode;
    property Description: WideString read Get_Description;
    property EndDate: WideString read Get_EndDate;
    property HighDays: WideString read Get_HighDays;
    property MaxQuantity: Integer read Get_MaxQuantity;
    property MCRCode: WideString read Get_MCRCode;
    property MinQuantity: Integer read Get_MinQuantity;
    property OCRCode: WideString read Get_OCRCode;
    property OtherCode: WideString read Get_OtherCode;
    property PLU: Integer read Get_PLU;
    property Regulations: WideString read Get_Regulations;
    property StartDate: WideString read Get_StartDate;
    property UnitPrice: Currency read Get_UnitPrice;
    property UnitQuantity: Integer read Get_UnitQuantity;
    property UseDays: WideString read Get_UseDays;
    property Taxes: WideString read Get_Taxes;
    property MOPs: WideString read Get_MOPs;
    property AvailableAfterEOD: WordBool read Get_AvailableAfterEOD;
  end;

{ DispInterface declaration for Dual Interface IProduct }

  IProductDisp = dispinterface
    ['{0A0D90C4-CAA9-11D1-8A92-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property InterfaceVersion: Integer readonly dispid 7;
    property Version: Integer readonly dispid 8;
    property Name: WideString readonly dispid 9;
    property ProgramID: WideString readonly dispid 10;
    property GUID: WideString readonly dispid 11;
    property ProjectFiles: WideString readonly dispid 12;
    function Design(const Password: WideString; const EVSink: IDesignEventSink): WideString; dispid 13;
    procedure TerminateDesign; dispid 14;
    function CurrentStatus: WideString; dispid 99999;
    property BitMap: OleVariant readonly dispid 1;
    property Caption: WideString readonly dispid 2;
    property Price[ScaleReading: Integer]: Currency readonly dispid 3;
    property EventSink: IEventSink dispid 4;
    property Count: Integer readonly dispid 5;
    property Item[Index: Integer]: WideString readonly dispid 6;
    property Title: WideString readonly dispid 15;
    property Prompt: WideString readonly dispid 16;
    property PMessage: WideString readonly dispid 17;
    property NeedsWeight: WordBool readonly dispid 18;
    procedure Execute(Quantity, MaxItems: Integer; NoRedraw: WordBool; const UIEventSink: IUIEventSink; const TxnLog: ITransactionLog; Nested: WordBool); dispid 19;
    procedure TerminateExecute(const TxnLog: ITransactionLog); dispid 20;
    procedure CompleteExecute(var Index: Integer; const TxnLog: ITransactionLog); dispid 21;
    procedure NotifyChildClick(const Name: WideString; Index: Integer); dispid 22;
    procedure TriggerValue(Source: TriggerSource; const Value: WideString); dispid 23;
    property CanTerminate: WordBool readonly dispid 24;
    property BarCode: WideString readonly dispid 25;
    property Description: WideString readonly dispid 26;
    property EndDate: WideString readonly dispid 27;
    property HighDays: WideString readonly dispid 28;
    property MaxQuantity: Integer readonly dispid 29;
    property MCRCode: WideString readonly dispid 30;
    property MinQuantity: Integer readonly dispid 31;
    property OCRCode: WideString readonly dispid 32;
    property OtherCode: WideString readonly dispid 33;
    property PLU: Integer readonly dispid 34;
    property Regulations: WideString readonly dispid 35;
    property StartDate: WideString readonly dispid 36;
    property UnitPrice: Currency readonly dispid 37;
    property UnitQuantity: Integer readonly dispid 38;
    property UseDays: WideString readonly dispid 39;
    function GetExecData: WideString; dispid 40;
    function SetExecData(const Value: WideString; var FlagError: WordBool): WideString; dispid 41;
    property Taxes: WideString readonly dispid 42;
    property MOPs: WideString readonly dispid 43;
    property AvailableAfterEOD: WordBool readonly dispid 44;
  end;

  IGroup = interface(IExecComponent)
    ['{0A0D90C5-CAA9-11D1-8A92-080000223037}']
    function Get_Key: Integer; safecall;
    property Key: Integer read Get_Key;
  end;

{ DispInterface declaration for Dual Interface IGroup }

  IGroupDisp = dispinterface
    ['{0A0D90C5-CAA9-11D1-8A92-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property InterfaceVersion: Integer readonly dispid 7;
    property Version: Integer readonly dispid 8;
    property Name: WideString readonly dispid 9;
    property ProgramID: WideString readonly dispid 10;
    property GUID: WideString readonly dispid 11;
    property ProjectFiles: WideString readonly dispid 12;
    function Design(const Password: WideString; const EVSink: IDesignEventSink): WideString; dispid 13;
    procedure TerminateDesign; dispid 14;
    function CurrentStatus: WideString; dispid 99999;
    property BitMap: OleVariant readonly dispid 1;
    property Caption: WideString readonly dispid 2;
    property Price[ScaleReading: Integer]: Currency readonly dispid 3;
    property EventSink: IEventSink dispid 4;
    property Count: Integer readonly dispid 5;
    property Item[Index: Integer]: WideString readonly dispid 6;
    property Title: WideString readonly dispid 15;
    property Prompt: WideString readonly dispid 16;
    property PMessage: WideString readonly dispid 17;
    property NeedsWeight: WordBool readonly dispid 18;
    procedure Execute(Quantity, MaxItems: Integer; NoRedraw: WordBool; const UIEventSink: IUIEventSink; const TxnLog: ITransactionLog; Nested: WordBool); dispid 19;
    procedure TerminateExecute(const TxnLog: ITransactionLog); dispid 20;
    procedure CompleteExecute(var Index: Integer; const TxnLog: ITransactionLog); dispid 21;
    procedure NotifyChildClick(const Name: WideString; Index: Integer); dispid 22;
    procedure TriggerValue(Source: TriggerSource; const Value: WideString); dispid 23;
    property CanTerminate: WordBool readonly dispid 24;
    property Key: Integer readonly dispid 25;
  end;

  IWUGroup = interface(IComponent)
    ['{0A0D90C6-CAA9-11D1-8A92-080000223037}']
    function Get_Count: Integer; safecall;
    function Get_Item(Index: Integer): WideString; safecall;
    procedure Set_Item(Index: Integer; const Value: WideString); safecall;
    procedure ApplyGroup(const WUGroup: WideString); safecall;
    property Count: Integer read Get_Count;
    property Item[Index: Integer]: WideString read Get_Item write Set_Item;
  end;

{ DispInterface declaration for Dual Interface IWUGroup }

  IWUGroupDisp = dispinterface
    ['{0A0D90C6-CAA9-11D1-8A92-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property InterfaceVersion: Integer readonly dispid 7;
    property Version: Integer readonly dispid 8;
    property Name: WideString readonly dispid 9;
    property ProgramID: WideString readonly dispid 10;
    property GUID: WideString readonly dispid 11;
    property ProjectFiles: WideString readonly dispid 12;
    function Design(const Password: WideString; const EVSink: IDesignEventSink): WideString; dispid 13;
    procedure TerminateDesign; dispid 14;
    function CurrentStatus: WideString; dispid 99999;
    property Count: Integer readonly dispid 1;
    property Item[Index: Integer]: WideString dispid 2;
    procedure ApplyGroup(const WUGroup: WideString); dispid 3;
  end;

  IPickList = interface(IComponent)
    ['{0A0D90C7-CAA9-11D1-8A92-080000223037}']
    function Get_RowCount: Integer; safecall;
    function Get_ColumnCount: Integer; safecall;
    function Get_ColumnName(Index: Integer): WideString; safecall;
    function Get_Item(Index: Integer): WideString; safecall;
    function Get_CurrentColumn: WideString; safecall;
    procedure Set_CurrentColumn(const Value: WideString); safecall;
    property RowCount: Integer read Get_RowCount;
    property ColumnCount: Integer read Get_ColumnCount;
    property ColumnName[Index: Integer]: WideString read Get_ColumnName;
    property Item[Index: Integer]: WideString read Get_Item;
    property CurrentColumn: WideString read Get_CurrentColumn write Set_CurrentColumn;
  end;

{ DispInterface declaration for Dual Interface IPickList }

  IPickListDisp = dispinterface
    ['{0A0D90C7-CAA9-11D1-8A92-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property InterfaceVersion: Integer readonly dispid 7;
    property Version: Integer readonly dispid 8;
    property Name: WideString readonly dispid 9;
    property ProgramID: WideString readonly dispid 10;
    property GUID: WideString readonly dispid 11;
    property ProjectFiles: WideString readonly dispid 12;
    function Design(const Password: WideString; const EVSink: IDesignEventSink): WideString; dispid 13;
    procedure TerminateDesign; dispid 14;
    function CurrentStatus: WideString; dispid 99999;
    property RowCount: Integer readonly dispid 1;
    property ColumnCount: Integer readonly dispid 2;
    property ColumnName[Index: Integer]: WideString readonly dispid 3;
    property Item[Index: Integer]: WideString readonly dispid 4;
    property CurrentColumn: WideString dispid 5;
  end;

  ILookUp = interface(IComponent)
    ['{0A0D90C8-CAA9-11D1-8A92-080000223037}']
    function Get_RowCount: Integer; safecall;
    function Get_ColumnCount: Integer; safecall;
    function Get_ColumnName(Index: Integer): WideString; safecall;
    function Get_Value(Index: Integer): WideString; safecall;
    function Get_Item(Index: Integer): WideString; safecall;
    function Get_CurrentColumn: WideString; safecall;
    procedure Set_CurrentColumn(const Value: WideString); safecall;
    function Get_Range(Index: Integer): WideString; safecall;
    property RowCount: Integer read Get_RowCount;
    property ColumnCount: Integer read Get_ColumnCount;
    property ColumnName[Index: Integer]: WideString read Get_ColumnName;
    property Value[Index: Integer]: WideString read Get_Value;
    property Item[Index: Integer]: WideString read Get_Item;
    property CurrentColumn: WideString read Get_CurrentColumn write Set_CurrentColumn;
    property Range[Index: Integer]: WideString read Get_Range;
  end;

{ DispInterface declaration for Dual Interface ILookUp }

  ILookUpDisp = dispinterface
    ['{0A0D90C8-CAA9-11D1-8A92-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property InterfaceVersion: Integer readonly dispid 7;
    property Version: Integer readonly dispid 8;
    property Name: WideString readonly dispid 9;
    property ProgramID: WideString readonly dispid 10;
    property GUID: WideString readonly dispid 11;
    property ProjectFiles: WideString readonly dispid 12;
    function Design(const Password: WideString; const EVSink: IDesignEventSink): WideString; dispid 13;
    procedure TerminateDesign; dispid 14;
    function CurrentStatus: WideString; dispid 99999;
    property RowCount: Integer readonly dispid 1;
    property ColumnCount: Integer readonly dispid 2;
    property ColumnName[Index: Integer]: WideString readonly dispid 3;
    property Value[Index: Integer]: WideString readonly dispid 4;
    property Item[Index: Integer]: WideString readonly dispid 5;
    property CurrentColumn: WideString dispid 6;
    property Range[Index: Integer]: WideString readonly dispid 15;
  end;

  IEventSink = interface(IBaseComponent)
    ['{0A0D90C3-CAA9-11D1-8A92-080000223037}']
    procedure Complete(const EventSource: IExecComponent); safecall;
    procedure DesignComplete(const EventSource: IExecComponent); safecall;
  end;

{ DispInterface declaration for Dual Interface IEventSink }

  IEventSinkDisp = dispinterface
    ['{0A0D90C3-CAA9-11D1-8A92-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    procedure Complete(const EventSource: IExecComponent); dispid 1;
    procedure DesignComplete(const EventSource: IExecComponent); dispid 2;
  end;

  IUIEventSink = interface(IBaseComponent)
    ['{2A60DF80-CD29-11D1-8A92-080000223037}']
    procedure DisplayItemInfo(const EventSource: IExecComponent; Index: Integer; BitMap: OleVariant; const Caption: WideString; Price: Currency; State: Integer; Notify, Nested: WordBool); safecall;
    procedure Restore; safecall;
    procedure DisplayInstructions(Style: InstructStyle; const Text: WideString; BitMap: OleVariant); safecall;
    procedure DataChanged(const EventSource: IExecComponent; const Value: WideString; FlagError: WordBool); safecall;
    function GetComponentReference(const Name: WideString): IDispatch; safecall;
    function CurrentDetails: WideString; safecall;
    function Translate(const Value: WideString): WideString; safecall;
    function Endorse(X, Y, ColCount: Integer; const CommaText: WideString): WordBool; safecall;
    procedure WaitFor(DeviceStatus: DeviceStatusType); safecall;
    procedure SwapTo(const ProgID, PassData: WideString); safecall;
    function Get_User: WideString; safecall;
    function Get_Workstation: Integer; safecall;
    function Get_Office: Integer; safecall;
    function ReferenceData(const Name: WideString): WideString; safecall;
    function CurrentLine: Integer; safecall;
    procedure Print2x2(const Title, Desc1, Desc2, Office, DataCommatext: WideString); safecall;
    function Get_HookUp: IHookUp; safecall;
    procedure ProgressBar(const Title: WideString; Min, Max, Pos, Auto: Integer); safecall;
    procedure OpenCashDrawer; safecall;
    procedure TransferTxnsToDiskette; safecall;
    procedure TransferTxnsFromDiskette; safecall;
    property User: WideString read Get_User;
    property Workstation: Integer read Get_Workstation;
    property Office: Integer read Get_Office;
    property HookUp: IHookUp read Get_HookUp;
  end;

{ DispInterface declaration for Dual Interface IUIEventSink }

  IUIEventSinkDisp = dispinterface
    ['{2A60DF80-CD29-11D1-8A92-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    procedure DisplayItemInfo(const EventSource: IExecComponent; Index: Integer; BitMap: OleVariant; const Caption: WideString; Price: Currency; State: Integer; Notify, Nested: WordBool); dispid 1;
    procedure Restore; dispid 2;
    procedure DisplayInstructions(Style: InstructStyle; const Text: WideString; BitMap: OleVariant); dispid 3;
    procedure DataChanged(const EventSource: IExecComponent; const Value: WideString; FlagError: WordBool); dispid 4;
    function GetComponentReference(const Name: WideString): IDispatch; dispid 5;
    function CurrentDetails: WideString; dispid 6;
    function Translate(const Value: WideString): WideString; dispid 7;
    function Endorse(X, Y, ColCount: Integer; const CommaText: WideString): WordBool; dispid 8;
    procedure WaitFor(DeviceStatus: DeviceStatusType); dispid 9;
    procedure SwapTo(const ProgID, PassData: WideString); dispid 10;
    property User: WideString readonly dispid 11;
    property Workstation: Integer readonly dispid 12;
    property Office: Integer readonly dispid 13;
    function ReferenceData(const Name: WideString): WideString; dispid 14;
    function CurrentLine: Integer; dispid 15;
    procedure Print2x2(const Title, Desc1, Desc2, Office, DataCommatext: WideString); dispid 16;
    property HookUp: IHookUp readonly dispid 17;
    procedure ProgressBar(const Title: WideString; Min, Max, Pos, Auto: Integer); dispid 18;
    procedure OpenCashDrawer; dispid 19;
    procedure TransferTxnsToDiskette; dispid 20;
    procedure TransferTxnsFromDiskette; dispid 21;
  end;

  IService = interface(IExecComponent)
    ['{2A60DF82-CD29-11D1-8A92-080000223037}']
  end;

{ DispInterface declaration for Dual Interface IService }

  IServiceDisp = dispinterface
    ['{2A60DF82-CD29-11D1-8A92-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property InterfaceVersion: Integer readonly dispid 7;
    property Version: Integer readonly dispid 8;
    property Name: WideString readonly dispid 9;
    property ProgramID: WideString readonly dispid 10;
    property GUID: WideString readonly dispid 11;
    property ProjectFiles: WideString readonly dispid 12;
    function Design(const Password: WideString; const EVSink: IDesignEventSink): WideString; dispid 13;
    procedure TerminateDesign; dispid 14;
    function CurrentStatus: WideString; dispid 99999;
    property BitMap: OleVariant readonly dispid 1;
    property Caption: WideString readonly dispid 2;
    property Price[ScaleReading: Integer]: Currency readonly dispid 3;
    property EventSink: IEventSink dispid 4;
    property Count: Integer readonly dispid 5;
    property Item[Index: Integer]: WideString readonly dispid 6;
    property Title: WideString readonly dispid 15;
    property Prompt: WideString readonly dispid 16;
    property PMessage: WideString readonly dispid 17;
    property NeedsWeight: WordBool readonly dispid 18;
    procedure Execute(Quantity, MaxItems: Integer; NoRedraw: WordBool; const UIEventSink: IUIEventSink; const TxnLog: ITransactionLog; Nested: WordBool); dispid 19;
    procedure TerminateExecute(const TxnLog: ITransactionLog); dispid 20;
    procedure CompleteExecute(var Index: Integer; const TxnLog: ITransactionLog); dispid 21;
    procedure NotifyChildClick(const Name: WideString; Index: Integer); dispid 22;
    procedure TriggerValue(Source: TriggerSource; const Value: WideString); dispid 23;
    property CanTerminate: WordBool readonly dispid 24;
  end;

  ICompLoad = interface(IBaseComponent)
    ['{9D67CA60-CE9C-11D1-8A92-080000223037}']
    function LoadComponent(const GUID: WideString): IUnknown; safecall;
    procedure Show; safecall;
    procedure Hide; safecall;
  end;

{ DispInterface declaration for Dual Interface ICompLoad }

  ICompLoadDisp = dispinterface
    ['{9D67CA60-CE9C-11D1-8A92-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    function LoadComponent(const GUID: WideString): IUnknown; dispid 1;
    procedure Show; dispid 2;
    procedure Hide; dispid 3;
  end;

  ICompMan = interface(IBaseComponent)
    ['{9D67CA62-CE9C-11D1-8A92-080000223037}']
    function LoadComponent(const Name: WideString): IUnknown; safecall;
    procedure Show; safecall;
    procedure Hide; safecall;
    function Get_AsToolBar: WordBool; safecall;
    procedure Set_AsToolBar(Value: WordBool); safecall;
    function Get_Ready: WordBool; safecall;
    property AsToolBar: WordBool read Get_AsToolBar write Set_AsToolBar;
    property Ready: WordBool read Get_Ready;
  end;

{ DispInterface declaration for Dual Interface ICompMan }

  ICompManDisp = dispinterface
    ['{9D67CA62-CE9C-11D1-8A92-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    function LoadComponent(const Name: WideString): IUnknown; dispid 1;
    procedure Show; dispid 2;
    procedure Hide; dispid 3;
    property AsToolBar: WordBool dispid 4;
    property Ready: WordBool readonly dispid 5;
  end;

  IErrorHandler = interface(IBaseComponent)
    ['{9D67CA64-CE9C-11D1-8A92-080000223037}']
    procedure RaiseError(ErrorPlaceCode, ErrorTypeCode, ErrorPriority: Integer; const ErrorData: WideString); safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_LogFile: WideString; safecall;
    procedure Set_LogFile(const Value: WideString); safecall;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property LogFile: WideString read Get_LogFile write Set_LogFile;
  end;

{ DispInterface declaration for Dual Interface IErrorHandler }

  IErrorHandlerDisp = dispinterface
    ['{9D67CA64-CE9C-11D1-8A92-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    procedure RaiseError(ErrorPlaceCode, ErrorTypeCode, ErrorPriority: Integer; const ErrorData: WideString); dispid 1;
    property Visible: WordBool dispid 2;
    property LogFile: WideString dispid 3;
  end;

  ISysGroup = interface(IExecComponent)
    ['{4469B520-CF1B-11D1-8A92-080000223037}']
  end;

{ DispInterface declaration for Dual Interface ISysGroup }

  ISysGroupDisp = dispinterface
    ['{4469B520-CF1B-11D1-8A92-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property InterfaceVersion: Integer readonly dispid 7;
    property Version: Integer readonly dispid 8;
    property Name: WideString readonly dispid 9;
    property ProgramID: WideString readonly dispid 10;
    property GUID: WideString readonly dispid 11;
    property ProjectFiles: WideString readonly dispid 12;
    function Design(const Password: WideString; const EVSink: IDesignEventSink): WideString; dispid 13;
    procedure TerminateDesign; dispid 14;
    function CurrentStatus: WideString; dispid 99999;
    property BitMap: OleVariant readonly dispid 1;
    property Caption: WideString readonly dispid 2;
    property Price[ScaleReading: Integer]: Currency readonly dispid 3;
    property EventSink: IEventSink dispid 4;
    property Count: Integer readonly dispid 5;
    property Item[Index: Integer]: WideString readonly dispid 6;
    property Title: WideString readonly dispid 15;
    property Prompt: WideString readonly dispid 16;
    property PMessage: WideString readonly dispid 17;
    property NeedsWeight: WordBool readonly dispid 18;
    procedure Execute(Quantity, MaxItems: Integer; NoRedraw: WordBool; const UIEventSink: IUIEventSink; const TxnLog: ITransactionLog; Nested: WordBool); dispid 19;
    procedure TerminateExecute(const TxnLog: ITransactionLog); dispid 20;
    procedure CompleteExecute(var Index: Integer; const TxnLog: ITransactionLog); dispid 21;
    procedure NotifyChildClick(const Name: WideString; Index: Integer); dispid 22;
    procedure TriggerValue(Source: TriggerSource; const Value: WideString); dispid 23;
    property CanTerminate: WordBool readonly dispid 24;
  end;

  ITransactionLog = interface(IBaseComponent)
    ['{956078A0-D3F9-11D1-8B69-080000223037}']
    procedure Set_Parent(Value: Integer); safecall;
    function Get_ItemCount: Integer; safecall;
    function Get_Total: Currency; safecall;
    function Get_Price(Index: Integer): Currency; safecall;
    function Get_Value(Index: Integer): Currency; safecall;
    function Get_ItemIndex(Index: Integer): Integer; safecall;
    function Get_Quantity(Index: Integer): Integer; safecall;
    function Get_Description(Index: Integer): WideString; safecall;
    function Get_Additional(Index: Integer): WideString; safecall;
    function Get_PLU(Index: Integer): Integer; safecall;
    function Get_ProgID(Index: Integer): WideString; safecall;
    function Get_DomInfo(Index: Integer): WideString; safecall;
    function Get_User: WideString; safecall;
    procedure Set_User(const Value: WideString); safecall;
    function Get_Workstation: Integer; safecall;
    procedure Set_Workstation(Value: Integer); safecall;
    function Get_SubLogVisible: WordBool; safecall;
    procedure Set_SubLogVisible(Value: WordBool); safecall;
    procedure LogTransaction(Index, Quantity, PLU: Integer; Value, Price: Currency; const Description, Additional, ProgID, DomInfo: WideString); safecall;
    procedure EndCustomer(const UniqueID: WideString); safecall;
    procedure CancelCustomer; safecall;
    procedure PrintReceipt; safecall;
    procedure SubLogTransaction(Index, Quantity, PLU: Integer; Value, Price: Currency; const Description, Additional, ProgID, DomInfo: WideString); safecall;
    procedure SubLogClear; safecall;
    procedure SetEventSink(const EventSink: ITxnEventSink); safecall;
    function Get_Contents: WideString; safecall;
    procedure Delete(Index: Integer); safecall;
    function GetExecData(Index: Integer; var ProgID: WideString): WideString; safecall;
    procedure LogToAccounts(Quantity, PLU: Integer; Value: Currency; const ProgID: WideString); safecall;
    function RetrieveAccountsFor(const ProgIDList: WideString): WideString; safecall;
    function RetrieveTxnsFor(const SQLString: WideString): WideString; safecall;
    function Get_Office: Integer; safecall;
    procedure Set_Office(Value: Integer); safecall;
    function Get_Hook: IHookUp; safecall;
    procedure Set_Hook(const Value: IHookUp); safecall;
    procedure WriteTransaction(const TxnType: WideString; Index, Quantity, PLU: Integer; Value, Price: Currency; const Description, Additional, ProgID, DomInfo: WideString); safecall;
    procedure WriteFullTransaction(WsNumber, Period, Index, Office: Integer; const TxnType, Teller: WideString; Quantity, PLU: Integer; Value, Price: Currency; const Description, Info, ProgID, Ident, DomInfo: WideString); safecall;
    property Parent: Integer write Set_Parent;
    property ItemCount: Integer read Get_ItemCount;
    property Total: Currency read Get_Total;
    property Price[Index: Integer]: Currency read Get_Price;
    property Value[Index: Integer]: Currency read Get_Value;
    property ItemIndex[Index: Integer]: Integer read Get_ItemIndex;
    property Quantity[Index: Integer]: Integer read Get_Quantity;
    property Description[Index: Integer]: WideString read Get_Description;
    property Additional[Index: Integer]: WideString read Get_Additional;
    property PLU[Index: Integer]: Integer read Get_PLU;
    property ProgID[Index: Integer]: WideString read Get_ProgID;
    property DomInfo[Index: Integer]: WideString read Get_DomInfo;
    property User: WideString read Get_User write Set_User;
    property Workstation: Integer read Get_Workstation write Set_Workstation;
    property SubLogVisible: WordBool read Get_SubLogVisible write Set_SubLogVisible;
    property Contents: WideString read Get_Contents;
    property Office: Integer read Get_Office write Set_Office;
    property Hook: IHookUp read Get_Hook write Set_Hook;
  end;

{ DispInterface declaration for Dual Interface ITransactionLog }

  ITransactionLogDisp = dispinterface
    ['{956078A0-D3F9-11D1-8B69-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property Parent: Integer writeonly dispid 1;
    property ItemCount: Integer readonly dispid 2;
    property Total: Currency readonly dispid 3;
    property Price[Index: Integer]: Currency readonly dispid 4;
    property Value[Index: Integer]: Currency readonly dispid 5;
    property ItemIndex[Index: Integer]: Integer readonly dispid 6;
    property Quantity[Index: Integer]: Integer readonly dispid 7;
    property Description[Index: Integer]: WideString readonly dispid 8;
    property Additional[Index: Integer]: WideString readonly dispid 9;
    property PLU[Index: Integer]: Integer readonly dispid 10;
    property ProgID[Index: Integer]: WideString readonly dispid 11;
    property DomInfo[Index: Integer]: WideString readonly dispid 12;
    property User: WideString dispid 13;
    property Workstation: Integer dispid 14;
    property SubLogVisible: WordBool dispid 15;
    procedure LogTransaction(Index, Quantity, PLU: Integer; Value, Price: Currency; const Description, Additional, ProgID, DomInfo: WideString); dispid 16;
    procedure EndCustomer(const UniqueID: WideString); dispid 17;
    procedure CancelCustomer; dispid 18;
    procedure PrintReceipt; dispid 19;
    procedure SubLogTransaction(Index, Quantity, PLU: Integer; Value, Price: Currency; const Description, Additional, ProgID, DomInfo: WideString); dispid 20;
    procedure SubLogClear; dispid 21;
    procedure SetEventSink(const EventSink: ITxnEventSink); dispid 22;
    property Contents: WideString readonly dispid 23;
    procedure Delete(Index: Integer); dispid 24;
    function GetExecData(Index: Integer; var ProgID: WideString): WideString; dispid 25;
    procedure LogToAccounts(Quantity, PLU: Integer; Value: Currency; const ProgID: WideString); dispid 26;
    function RetrieveAccountsFor(const ProgIDList: WideString): WideString; dispid 27;
    function RetrieveTxnsFor(const SQLString: WideString): WideString; dispid 28;
    property Office: Integer dispid 29;
    property Hook: IHookUp dispid 30;
    procedure WriteTransaction(const TxnType: WideString; Index, Quantity, PLU: Integer; Value, Price: Currency; const Description, Additional, ProgID, DomInfo: WideString); dispid 31;
    procedure WriteFullTransaction(WsNumber, Period, Index, Office: Integer; const TxnType, Teller: WideString; Quantity, PLU: Integer; Value, Price: Currency; const Description, Info, ProgID, Ident, DomInfo: WideString); dispid 32;
  end;

  ITxnEventSink = interface(IBaseComponent)
    ['{5366E740-DEFD-11D1-8B69-080000223037}']
    procedure OnChange(const EventSource: ITransactionLog); safecall;
    procedure LoggedTransaction(Index, Quantity, PLU: Integer; Value, Price: Currency; const Description, Additional, ProgID, DomInfo: WideString); safecall;
    procedure VoidedTransaction(Index, Quantity, PLU: Integer; Value, Price: Currency; const Description, Additional, ProgID, DomInfo: WideString); safecall;
  end;

{ DispInterface declaration for Dual Interface ITxnEventSink }

  ITxnEventSinkDisp = dispinterface
    ['{5366E740-DEFD-11D1-8B69-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    procedure OnChange(const EventSource: ITransactionLog); dispid 1;
    procedure LoggedTransaction(Index, Quantity, PLU: Integer; Value, Price: Currency; const Description, Additional, ProgID, DomInfo: WideString); dispid 2;
    procedure VoidedTransaction(Index, Quantity, PLU: Integer; Value, Price: Currency; const Description, Additional, ProgID, DomInfo: WideString); dispid 3;
  end;

  IDevice = interface(IBaseComponent)
    ['{DD64C160-34F7-11D2-8B6A-080000223037}']
    procedure SetEventSink(const EventSink: IDeviceEventSink); safecall;
    function WriteDevice(CommandType: DeviceCommand; const Data: WideString; Len: Integer): WordBool; safecall;
    function ReadDevice(var Data: WideString; var Len: Integer): WordBool; safecall;
    function GetStatus: WideString; safecall;
    function TakeControl: WordBool; safecall;
    procedure ReleaseControl; safecall;
  end;

{ DispInterface declaration for Dual Interface IDevice }

  IDeviceDisp = dispinterface
    ['{DD64C160-34F7-11D2-8B6A-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    procedure SetEventSink(const EventSink: IDeviceEventSink); dispid 1;
    function WriteDevice(CommandType: DeviceCommand; const Data: WideString; Len: Integer): WordBool; dispid 2;
    function ReadDevice(var Data: WideString; var Len: Integer): WordBool; dispid 3;
    function GetStatus: WideString; dispid 4;
    function TakeControl: WordBool; dispid 5;
    procedure ReleaseControl; dispid 6;
  end;

  IDeviceEventSink = interface(IBaseComponent)
    ['{DD64C161-34F7-11D2-8B6A-080000223037}']
    procedure Trigger(const Data: WideString); safecall;
    procedure ControlReleased; safecall;
  end;

{ DispInterface declaration for Dual Interface IDeviceEventSink }

  IDeviceEventSinkDisp = dispinterface
    ['{DD64C161-34F7-11D2-8B6A-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    procedure Trigger(const Data: WideString); dispid 1;
    procedure ControlReleased; dispid 2;
  end;

  IPictureServer = interface(IComponent)
    ['{63800F00-36D0-11D2-8B6A-080000223037}']
    function BitMap(const Named: WideString): WideString; safecall;
    function Get_PictureNames: WideString; safecall;
    function ZLBitMap(const Named: WideString): OleVariant; safecall;
    property PictureNames: WideString read Get_PictureNames;
  end;

{ DispInterface declaration for Dual Interface IPictureServer }

  IPictureServerDisp = dispinterface
    ['{63800F00-36D0-11D2-8B6A-080000223037}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property InterfaceVersion: Integer readonly dispid 7;
    property Version: Integer readonly dispid 8;
    property Name: WideString readonly dispid 9;
    property ProgramID: WideString readonly dispid 10;
    property GUID: WideString readonly dispid 11;
    property ProjectFiles: WideString readonly dispid 12;
    function Design(const Password: WideString; const EVSink: IDesignEventSink): WideString; dispid 13;
    procedure TerminateDesign; dispid 14;
    function CurrentStatus: WideString; dispid 99999;
    function BitMap(const Named: WideString): WideString; dispid 1;
    property PictureNames: WideString readonly dispid 2;
    function ZLBitMap(const Named: WideString): OleVariant; dispid 3;
  end;

  IMailItemLog = interface(IComponent)
    ['{11984980-3B6E-11D2-9D88-444553540001}']
    procedure AddItem(const TrackingNumber: WideString; Weight: Integer; const Destination: WideString; Value: Currency; const Info: WideString); safecall;
    function Get_User: WideString; safecall;
    procedure Set_User(const Value: WideString); safecall;
    function Get_Office: Integer; safecall;
    procedure Set_Office(Value: Integer); safecall;
    function Get_Workstation: Integer; safecall;
    procedure Set_Workstation(Value: Integer); safecall;
    procedure WriteToStore; safecall;
    function List: WideString; safecall;
    procedure ClearLog; safecall;
    property User: WideString read Get_User write Set_User;
    property Office: Integer read Get_Office write Set_Office;
    property Workstation: Integer read Get_Workstation write Set_Workstation;
  end;

{ DispInterface declaration for Dual Interface IMailItemLog }

  IMailItemLogDisp = dispinterface
    ['{11984980-3B6E-11D2-9D88-444553540001}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property InterfaceVersion: Integer readonly dispid 7;
    property Version: Integer readonly dispid 8;
    property Name: WideString readonly dispid 9;
    property ProgramID: WideString readonly dispid 10;
    property GUID: WideString readonly dispid 11;
    property ProjectFiles: WideString readonly dispid 12;
    function Design(const Password: WideString; const EVSink: IDesignEventSink): WideString; dispid 13;
    procedure TerminateDesign; dispid 14;
    function CurrentStatus: WideString; dispid 99999;
    procedure AddItem(const TrackingNumber: WideString; Weight: Integer; const Destination: WideString; Value: Currency; const Info: WideString); dispid 1;
    property User: WideString dispid 2;
    property Office: Integer dispid 3;
    property Workstation: Integer dispid 4;
    procedure WriteToStore; dispid 5;
    function List: WideString; dispid 6;
    procedure ClearLog; dispid 15;
  end;

  IExchangeRateServer = interface(IComponent)
    ['{B232C120-5C77-11D2-9D88-006008BA10FE}']
    function RateFor(const Country: WideString): Currency; safecall;
    function Exchange(const Country: WideString; Amount: Currency): Currency; safecall;
    procedure SetRateFor(const Country: WideString; NewRate: Currency); safecall;
    function GetRatesAsCommaText: WideString; safecall;
  end;

{ DispInterface declaration for Dual Interface IExchangeRateServer }

  IExchangeRateServerDisp = dispinterface
    ['{B232C120-5C77-11D2-9D88-006008BA10FE}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property InterfaceVersion: Integer readonly dispid 7;
    property Version: Integer readonly dispid 8;
    property Name: WideString readonly dispid 9;
    property ProgramID: WideString readonly dispid 10;
    property GUID: WideString readonly dispid 11;
    property ProjectFiles: WideString readonly dispid 12;
    function Design(const Password: WideString; const EVSink: IDesignEventSink): WideString; dispid 13;
    procedure TerminateDesign; dispid 14;
    function CurrentStatus: WideString; dispid 99999;
    function RateFor(const Country: WideString): Currency; dispid 1;
    function Exchange(const Country: WideString; Amount: Currency): Currency; dispid 2;
    procedure SetRateFor(const Country: WideString; NewRate: Currency); dispid 3;
    function GetRatesAsCommaText: WideString; dispid 4;
  end;

  IHotKeys = interface(IComponent)
    ['{78A2D060-5C79-11D2-9D88-006008BA10FE}']
    function ComponentToExecute(KeyStroke, ShiftState: Integer): WideString; safecall;
    function Get_UserType: WideString; safecall;
    procedure Set_UserType(const Value: WideString); safecall;
    function Get_WorkstationType: WideString; safecall;
    procedure Set_WorkstationType(const Value: WideString); safecall;
    property UserType: WideString read Get_UserType write Set_UserType;
    property WorkstationType: WideString read Get_WorkstationType write Set_WorkstationType;
  end;

{ DispInterface declaration for Dual Interface IHotKeys }

  IHotKeysDisp = dispinterface
    ['{78A2D060-5C79-11D2-9D88-006008BA10FE}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property InterfaceVersion: Integer readonly dispid 7;
    property Version: Integer readonly dispid 8;
    property Name: WideString readonly dispid 9;
    property ProgramID: WideString readonly dispid 10;
    property GUID: WideString readonly dispid 11;
    property ProjectFiles: WideString readonly dispid 12;
    function Design(const Password: WideString; const EVSink: IDesignEventSink): WideString; dispid 13;
    procedure TerminateDesign; dispid 14;
    function CurrentStatus: WideString; dispid 99999;
    function ComponentToExecute(KeyStroke, ShiftState: Integer): WideString; dispid 1;
    property UserType: WideString dispid 2;
    property WorkstationType: WideString dispid 3;
  end;

  IAccounts = interface(IComponent)
    ['{A2016FC3-5EF4-11D2-9D89-006008BA10FE}']
    function Get_Period: Integer; safecall;
    procedure Set_Period(Value: Integer); safecall;
    function Get_User: WideString; safecall;
    procedure Set_User(const Value: WideString); safecall;
    procedure LogItem(const ItemID: WideString; Value: Currency; Quantity: Integer); safecall;
    function GetAccountDetails(const AccountGroup, PeriodList: WideString): WideString; safecall;
    procedure TransferStock(const UserFrom, UserTo, Name: WideString; Value: Currency; Quantity: Integer); safecall;
    procedure ReturnStock(const Name: WideString; Value: Currency; Quantity: Integer); safecall;
    procedure ReceiveStock(const Name: WideString; Value: Currency; Quantity: Integer); safecall;
    function GetCurrentStockLevels(const List: WideString): WideString; safecall;
    procedure SetStockLevel(const Name: WideString; Value: Currency; Quantity: Integer); safecall;
    function Get_SystemTime: TDateTime; safecall;
    procedure StartOfDay(var CashValue, StockValue: Currency); safecall;
    procedure EndOfDay(var CashValue, StockValue: Currency); safecall;
    function HasPeriodStarted(const User: WideString): WordBool; safecall;
    function GetLastEndOfDay(var CashValue, StockValue: Currency): Integer; safecall;
    procedure ReceiveRem(const Name: WideString; Value: Currency; Quantity: Integer); safecall;
    procedure DispatchRem(const Name: WideString; Value: Currency; Quantity: Integer); safecall;
    function GetNewProducts: WideString; safecall;
    procedure CreateNewProduct(const Name, AType, ALine: WideString; Value: Currency); safecall;
    procedure SellNewProduct(const Name: WideString; Value: Currency); safecall;
    function Get_AccountUsers: WideString; safecall;
    function SelectCurrentPeriod: WordBool; safecall;
    property Period: Integer read Get_Period write Set_Period;
    property User: WideString read Get_User write Set_User;
    property SystemTime: TDateTime read Get_SystemTime;
    property AccountUsers: WideString read Get_AccountUsers;
  end;

{ DispInterface declaration for Dual Interface IAccounts }

  IAccountsDisp = dispinterface
    ['{A2016FC3-5EF4-11D2-9D89-006008BA10FE}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property InterfaceVersion: Integer readonly dispid 7;
    property Version: Integer readonly dispid 8;
    property Name: WideString readonly dispid 9;
    property ProgramID: WideString readonly dispid 10;
    property GUID: WideString readonly dispid 11;
    property ProjectFiles: WideString readonly dispid 12;
    function Design(const Password: WideString; const EVSink: IDesignEventSink): WideString; dispid 13;
    procedure TerminateDesign; dispid 14;
    function CurrentStatus: WideString; dispid 99999;
    property Period: Integer dispid 1;
    property User: WideString dispid 2;
    procedure LogItem(const ItemID: WideString; Value: Currency; Quantity: Integer); dispid 3;
    function GetAccountDetails(const AccountGroup, PeriodList: WideString): WideString; dispid 4;
    procedure TransferStock(const UserFrom, UserTo, Name: WideString; Value: Currency; Quantity: Integer); dispid 5;
    procedure ReturnStock(const Name: WideString; Value: Currency; Quantity: Integer); dispid 6;
    procedure ReceiveStock(const Name: WideString; Value: Currency; Quantity: Integer); dispid 15;
    function GetCurrentStockLevels(const List: WideString): WideString; dispid 16;
    procedure SetStockLevel(const Name: WideString; Value: Currency; Quantity: Integer); dispid 17;
    property SystemTime: TDateTime readonly dispid 18;
    procedure StartOfDay(var CashValue, StockValue: Currency); dispid 19;
    procedure EndOfDay(var CashValue, StockValue: Currency); dispid 20;
    function HasPeriodStarted(const User: WideString): WordBool; dispid 21;
    function GetLastEndOfDay(var CashValue, StockValue: Currency): Integer; dispid 22;
    procedure ReceiveRem(const Name: WideString; Value: Currency; Quantity: Integer); dispid 23;
    procedure DispatchRem(const Name: WideString; Value: Currency; Quantity: Integer); dispid 24;
    function GetNewProducts: WideString; dispid 25;
    procedure CreateNewProduct(const Name, AType, ALine: WideString; Value: Currency); dispid 26;
    procedure SellNewProduct(const Name: WideString; Value: Currency); dispid 27;
    property AccountUsers: WideString readonly dispid 28;
    function SelectCurrentPeriod: WordBool; dispid 29;
  end;

  ISiteManager = interface(IComponent)
    ['{39F80880-60B1-11D2-9D8A-006008BA10FE}']
    function CopyFile(const FromMachine, FromPath, FromFile, ToMachine, ToPath, ToFile: WideString): WordBool; safecall;
    function WhosHere: WideString; safecall;
    function ApplyUpdate(UpdateType: SMUpdateType; const FromMachineData: WideString): WordBool; safecall;
    function CurrentVersion: WideString; safecall;
    function StartUpGPCS: WordBool; safecall;
    function ShutDownGPCS: WordBool; safecall;
    procedure ShutDownMachine; safecall;
    procedure LogOffMachine; safecall;
    procedure ReLoadComponents(const ProgIDs: WideString); safecall;
    function GetLocalFile(const Path, Name: WideString; var datetime: TDateTime): OleVariant; safecall;
    function SetLocalFile(const Path, Name: WideString; datetime: TDateTime; Value: OleVariant): WordBool; safecall;
  end;

{ DispInterface declaration for Dual Interface ISiteManager }

  ISiteManagerDisp = dispinterface
    ['{39F80880-60B1-11D2-9D8A-006008BA10FE}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property InterfaceVersion: Integer readonly dispid 7;
    property Version: Integer readonly dispid 8;
    property Name: WideString readonly dispid 9;
    property ProgramID: WideString readonly dispid 10;
    property GUID: WideString readonly dispid 11;
    property ProjectFiles: WideString readonly dispid 12;
    function Design(const Password: WideString; const EVSink: IDesignEventSink): WideString; dispid 13;
    procedure TerminateDesign; dispid 14;
    function CurrentStatus: WideString; dispid 99999;
    function CopyFile(const FromMachine, FromPath, FromFile, ToMachine, ToPath, ToFile: WideString): WordBool; dispid 1;
    function WhosHere: WideString; dispid 2;
    function ApplyUpdate(UpdateType: SMUpdateType; const FromMachineData: WideString): WordBool; dispid 3;
    function CurrentVersion: WideString; dispid 4;
    function StartUpGPCS: WordBool; dispid 5;
    function ShutDownGPCS: WordBool; dispid 6;
    procedure ShutDownMachine; dispid 15;
    procedure LogOffMachine; dispid 16;
    procedure ReLoadComponents(const ProgIDs: WideString); dispid 17;
    function GetLocalFile(const Path, Name: WideString; var datetime: TDateTime): OleVariant; dispid 18;
    function SetLocalFile(const Path, Name: WideString; datetime: TDateTime; Value: OleVariant): WordBool; dispid 19;
  end;

  IRemoteControl = interface(IBaseComponent)
    ['{9B98FBB0-748D-11D2-B94C-006008BA10FE}']
    function Execute(const ExecName: WideString): WideString; safecall;
    function KeyStroke(const KeyName: WideString): WideString; safecall;
    function ScreenShot: OleVariant; safecall;
    function HelpText: WideString; safecall;
    function Get_Title: WideString; safecall;
    function Get_ScaleReading: Integer; safecall;
    procedure Set_ScaleReading(Value: Integer); safecall;
    function Get_DateEnabled: WordBool; safecall;
    procedure Set_DateEnabled(Value: WordBool); safecall;
    property Title: WideString read Get_Title;
    property ScaleReading: Integer read Get_ScaleReading write Set_ScaleReading;
    property DateEnabled: WordBool read Get_DateEnabled write Set_DateEnabled;
  end;

{ DispInterface declaration for Dual Interface IRemoteControl }

  IRemoteControlDisp = dispinterface
    ['{9B98FBB0-748D-11D2-B94C-006008BA10FE}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    function Execute(const ExecName: WideString): WideString; dispid 1;
    function KeyStroke(const KeyName: WideString): WideString; dispid 2;
    function ScreenShot: OleVariant; dispid 3;
    function HelpText: WideString; dispid 4;
    property Title: WideString readonly dispid 5;
    property ScaleReading: Integer dispid 6;
    property DateEnabled: WordBool dispid 7;
  end;

  IHookUp = interface(IBaseComponent)
    ['{02BAF650-AC70-11D2-B9D1-006008BA10FE}']
    function Get_Accounts: IAccounts; safecall;
    function Get_Counters: IDevice; safecall;
    function Get_DatabaseServer: IDispatch; safecall;
    procedure KeepAwake; safecall;
    procedure ReleaseHooks; safecall;
    function Get_Translate: ITranslate; safecall;
    property Accounts: IAccounts read Get_Accounts;
    property Counters: IDevice read Get_Counters;
    property DatabaseServer: IDispatch read Get_DatabaseServer;
    property Translate: ITranslate read Get_Translate;
  end;

{ DispInterface declaration for Dual Interface IHookUp }

  IHookUpDisp = dispinterface
    ['{02BAF650-AC70-11D2-B9D1-006008BA10FE}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property Accounts: IAccounts readonly dispid 1;
    property Counters: IDevice readonly dispid 2;
    property DatabaseServer: IDispatch readonly dispid 3;
    procedure KeepAwake; dispid 4;
    procedure ReleaseHooks; dispid 5;
    property Translate: ITranslate readonly dispid 6;
  end;

  IStock = interface(IBaseComponent)
    ['{9FF2E9F0-AE18-11D2-B9D8-006008BA10FE}']
    procedure CreateNewStockUnit(const Owner, StockUnitType: WideString); safecall;
    procedure DeleteStockUnit(const Owner, StockUnitType: WideString); safecall;
    procedure AdjustStockLevel(const Owner, StockItemName: WideString; Quantity: Integer); safecall;
    procedure SetStockLevel(const Owner, StockItemName: WideString; Quantity: Integer); safecall;
    function ListAllStock(const Owner, StockGroup: WideString): WideString; safecall;
    function ListAvailableStock(const Owner, StockGroup: WideString): WideString; safecall;
    procedure SetupStockTransfer(const FromOwner, ToOwner, StockItemName: WideString; Quantity: Integer); safecall;
    procedure ChangeStockTransfer(const FromOwner, ToOwner, StockItemName: WideString; Quantity: Integer); safecall;
    function ListTransferStock(const FromOwner, ToOwner: WideString): WideString; safecall;
    function ListPendingTransfersTo(const Owner: WideString): WideString; safecall;
    function ListPendingTransfersFrom(const Owner: WideString): WideString; safecall;
    procedure TransferStock(const FromOwner, ToOwner: WideString); safecall;
    function QueryStockLevel(const Owner, StockItemName: WideString): Integer; safecall;
    procedure ClearTempAdjustments(const Owner: WideString); safecall;
    procedure AddNewStockItem(const Description: WideString; Value: Currency; const Group: WideString; PLU: Integer; const AccountLine, AcctType, Report, ProgID, SUTypes: WideString); safecall;
    function GetStockItemDetails(const Description: WideString): WideString; safecall;
    procedure DeleteStockItem(const Description: WideString); safecall;
  end;

{ DispInterface declaration for Dual Interface IStock }

  IStockDisp = dispinterface
    ['{9FF2E9F0-AE18-11D2-B9D8-006008BA10FE}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    procedure CreateNewStockUnit(const Owner, StockUnitType: WideString); dispid 1;
    procedure DeleteStockUnit(const Owner, StockUnitType: WideString); dispid 2;
    procedure AdjustStockLevel(const Owner, StockItemName: WideString; Quantity: Integer); dispid 4;
    procedure SetStockLevel(const Owner, StockItemName: WideString; Quantity: Integer); dispid 5;
    function ListAllStock(const Owner, StockGroup: WideString): WideString; dispid 6;
    function ListAvailableStock(const Owner, StockGroup: WideString): WideString; dispid 7;
    procedure SetupStockTransfer(const FromOwner, ToOwner, StockItemName: WideString; Quantity: Integer); dispid 8;
    procedure ChangeStockTransfer(const FromOwner, ToOwner, StockItemName: WideString; Quantity: Integer); dispid 9;
    function ListTransferStock(const FromOwner, ToOwner: WideString): WideString; dispid 10;
    function ListPendingTransfersTo(const Owner: WideString): WideString; dispid 11;
    function ListPendingTransfersFrom(const Owner: WideString): WideString; dispid 12;
    procedure TransferStock(const FromOwner, ToOwner: WideString); dispid 13;
    function QueryStockLevel(const Owner, StockItemName: WideString): Integer; dispid 14;
    procedure ClearTempAdjustments(const Owner: WideString); dispid 3;
    procedure AddNewStockItem(const Description: WideString; Value: Currency; const Group: WideString; PLU: Integer; const AccountLine, AcctType, Report, ProgID, SUTypes: WideString); dispid 15;
    function GetStockItemDetails(const Description: WideString): WideString; dispid 16;
    procedure DeleteStockItem(const Description: WideString); dispid 17;
  end;

  IGPCSFont = interface(IBaseComponent)
    ['{87FA6900-CE7B-11D2-AA05-00A0CC3A61B2}']
    function Get_Color: Integer; safecall;
    procedure Set_Color(Value: Integer); safecall;
    function Get_Height: Integer; safecall;
    procedure Set_Height(Value: Integer); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function Get_Size: Integer; safecall;
    procedure Set_Size(Value: Integer); safecall;
    function Get_Style: FontStyle; safecall;
    procedure Set_Style(Value: FontStyle); safecall;
    function Get_Ident: Integer; safecall;
    procedure Set_Ident(Value: Integer); safecall;
    property Color: Integer read Get_Color write Set_Color;
    property Height: Integer read Get_Height write Set_Height;
    property Name: WideString read Get_Name write Set_Name;
    property Size: Integer read Get_Size write Set_Size;
    property Style: FontStyle read Get_Style write Set_Style;
    property Ident: Integer read Get_Ident write Set_Ident;
  end;

{ DispInterface declaration for Dual Interface IGPCSFont }

  IGPCSFontDisp = dispinterface
    ['{87FA6900-CE7B-11D2-AA05-00A0CC3A61B2}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property Color: Integer dispid 1;
    property Height: Integer dispid 2;
    property Name: WideString dispid 3;
    property Size: Integer dispid 4;
    property Style: FontStyle dispid 5;
    property Ident: Integer dispid 6;
  end;

  IGPCSLabel = interface(IBaseComponent)
    ['{87FA6901-CE7B-11D2-AA05-00A0CC3A61B2}']
    function Get_Alignment: TextAlign; safecall;
    procedure Set_Alignment(Value: TextAlign); safecall;
    function Get_AutoSize: WordBool; safecall;
    procedure Set_AutoSize(Value: WordBool); safecall;
    function Get_Transparent: WordBool; safecall;
    procedure Set_Transparent(Value: WordBool); safecall;
    function Get_WordWrap: WordBool; safecall;
    procedure Set_WordWrap(Value: WordBool); safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_Top: Integer; safecall;
    procedure Set_Top(Value: Integer); safecall;
    function Get_Left: Integer; safecall;
    procedure Set_Left(Value: Integer); safecall;
    function Get_Width: Integer; safecall;
    procedure Set_Width(Value: Integer); safecall;
    function Get_Height: Integer; safecall;
    procedure Set_Height(Value: Integer); safecall;
    function Get_FontIdent: Integer; safecall;
    procedure Set_FontIdent(Value: Integer); safecall;
    function Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function Get_Color: Integer; safecall;
    procedure Set_Color(Value: Integer); safecall;
    property Alignment: TextAlign read Get_Alignment write Set_Alignment;
    property AutoSize: WordBool read Get_AutoSize write Set_AutoSize;
    property Transparent: WordBool read Get_Transparent write Set_Transparent;
    property WordWrap: WordBool read Get_WordWrap write Set_WordWrap;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Top: Integer read Get_Top write Set_Top;
    property Left: Integer read Get_Left write Set_Left;
    property Width: Integer read Get_Width write Set_Width;
    property Height: Integer read Get_Height write Set_Height;
    property FontIdent: Integer read Get_FontIdent write Set_FontIdent;
    property Caption: WideString read Get_Caption write Set_Caption;
    property Name: WideString read Get_Name write Set_Name;
    property Color: Integer read Get_Color write Set_Color;
  end;

{ DispInterface declaration for Dual Interface IGPCSLabel }

  IGPCSLabelDisp = dispinterface
    ['{87FA6901-CE7B-11D2-AA05-00A0CC3A61B2}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property Alignment: TextAlign dispid 1;
    property AutoSize: WordBool dispid 2;
    property Transparent: WordBool dispid 3;
    property WordWrap: WordBool dispid 4;
    property Visible: WordBool dispid 5;
    property Top: Integer dispid 6;
    property Left: Integer dispid 7;
    property Width: Integer dispid 8;
    property Height: Integer dispid 9;
    property FontIdent: Integer dispid 10;
    property Caption: WideString dispid 11;
    property Name: WideString dispid 12;
    property Color: Integer dispid 13;
  end;

  IBitMap = interface(IBaseComponent)
    ['{FD7439E0-CE94-11D2-AA05-00A0CC3A61B2}']
    function Get_Data: OleVariant; safecall;
    procedure Set_Data(Value: OleVariant); safecall;
    function Get_Width: Integer; safecall;
    procedure Set_Width(Value: Integer); safecall;
    function Get_Height: Integer; safecall;
    procedure Set_Height(Value: Integer); safecall;
    function Get_Ident: Integer; safecall;
    procedure Set_Ident(Value: Integer); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function Get_Left: Integer; safecall;
    procedure Set_Left(Value: Integer); safecall;
    function Get_Top: Integer; safecall;
    procedure Set_Top(Value: Integer); safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_Transparent: WordBool; safecall;
    procedure Set_Transparent(Value: WordBool); safecall;
    property Data: OleVariant read Get_Data write Set_Data;
    property Width: Integer read Get_Width write Set_Width;
    property Height: Integer read Get_Height write Set_Height;
    property Ident: Integer read Get_Ident write Set_Ident;
    property Name: WideString read Get_Name write Set_Name;
    property Left: Integer read Get_Left write Set_Left;
    property Top: Integer read Get_Top write Set_Top;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Transparent: WordBool read Get_Transparent write Set_Transparent;
  end;

{ DispInterface declaration for Dual Interface IBitMap }

  IBitMapDisp = dispinterface
    ['{FD7439E0-CE94-11D2-AA05-00A0CC3A61B2}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property Data: OleVariant dispid 1;
    property Width: Integer dispid 2;
    property Height: Integer dispid 3;
    property Ident: Integer dispid 4;
    property Name: WideString dispid 5;
    property Left: Integer dispid 6;
    property Top: Integer dispid 7;
    property Visible: WordBool dispid 8;
    property Transparent: WordBool dispid 9;
  end;

  IButton = interface(IBaseComponent)
    ['{B20C0140-CF20-11D2-AA05-00A0CC3A61B2}']
    function Get_Left: Integer; safecall;
    procedure Set_Left(Value: Integer); safecall;
    function Get_Top: Integer; safecall;
    procedure Set_Top(Value: Integer); safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    function Get_Down: WordBool; safecall;
    procedure Set_Down(Value: WordBool); safecall;
    function Get_FontIdent: Integer; safecall;
    procedure Set_FontIdent(Value: Integer); safecall;
    function Get_BitMapUpIdent: Integer; safecall;
    procedure Set_BitMapUpIdent(Value: Integer); safecall;
    function Get_BitMapDownIdent: Integer; safecall;
    procedure Set_BitMapDownIdent(Value: Integer); safecall;
    function Get_GlyphIdent: Integer; safecall;
    procedure Set_GlyphIdent(Value: Integer); safecall;
    function Get_Text: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function Get_Price: WideString; safecall;
    procedure Set_Price(const Value: WideString); safecall;
    function Get_Key: WideString; safecall;
    procedure Set_Key(const Value: WideString); safecall;
    function Get_Toggle: WordBool; safecall;
    procedure Set_Toggle(Value: WordBool); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    property Left: Integer read Get_Left write Set_Left;
    property Top: Integer read Get_Top write Set_Top;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property Down: WordBool read Get_Down write Set_Down;
    property FontIdent: Integer read Get_FontIdent write Set_FontIdent;
    property BitMapUpIdent: Integer read Get_BitMapUpIdent write Set_BitMapUpIdent;
    property BitMapDownIdent: Integer read Get_BitMapDownIdent write Set_BitMapDownIdent;
    property GlyphIdent: Integer read Get_GlyphIdent write Set_GlyphIdent;
    property Text: WideString read Get_Text write Set_Text;
    property Price: WideString read Get_Price write Set_Price;
    property Key: WideString read Get_Key write Set_Key;
    property Toggle: WordBool read Get_Toggle write Set_Toggle;
    property Name: WideString read Get_Name write Set_Name;
  end;

{ DispInterface declaration for Dual Interface IButton }

  IButtonDisp = dispinterface
    ['{B20C0140-CF20-11D2-AA05-00A0CC3A61B2}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property Left: Integer dispid 1;
    property Top: Integer dispid 2;
    property Enabled: WordBool dispid 3;
    property Down: WordBool dispid 4;
    property FontIdent: Integer dispid 5;
    property BitMapUpIdent: Integer dispid 6;
    property BitMapDownIdent: Integer dispid 7;
    property GlyphIdent: Integer dispid 8;
    property Text: WideString dispid 9;
    property Price: WideString dispid 10;
    property Key: WideString dispid 11;
    property Toggle: WordBool dispid 12;
    property Name: WideString dispid 13;
  end;

  IUIStyle = interface(IBaseComponent)
    ['{B20C0141-CF20-11D2-AA05-00A0CC3A61B2}']
    function Get_Width: Integer; safecall;
    procedure Set_Width(Value: Integer); safecall;
    function Get_Height: Integer; safecall;
    procedure Set_Height(Value: Integer); safecall;
    function Get_BGColor: Integer; safecall;
    procedure Set_BGColor(Value: Integer); safecall;
    function Get_DefaultFontIdent: Integer; safecall;
    procedure Set_DefaultFontIdent(Value: Integer); safecall;
    function Get_ButtonCount: Integer; safecall;
    function Get_BitMapCount: Integer; safecall;
    function Get_FontCount: Integer; safecall;
    function Get_TextLabelCount: Integer; safecall;
    function Get_Button(Index: Integer): IButton; safecall;
    function Get_BitMap(Index: Integer): IBitMap; safecall;
    function Get_Font(Index: Integer): IGPCSFont; safecall;
    function Get_TextLabel(Index: Integer): IGPCSLabel; safecall;
    function AddButton: Integer; safecall;
    function AddBitMap: Integer; safecall;
    function AddFont: Integer; safecall;
    function AddTextLabel: Integer; safecall;
    function Get_RightAnchored: WordBool; safecall;
    procedure Set_RightAnchored(Value: WordBool); safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    property Width: Integer read Get_Width write Set_Width;
    property Height: Integer read Get_Height write Set_Height;
    property BGColor: Integer read Get_BGColor write Set_BGColor;
    property DefaultFontIdent: Integer read Get_DefaultFontIdent write Set_DefaultFontIdent;
    property ButtonCount: Integer read Get_ButtonCount;
    property BitMapCount: Integer read Get_BitMapCount;
    property FontCount: Integer read Get_FontCount;
    property TextLabelCount: Integer read Get_TextLabelCount;
    property Button[Index: Integer]: IButton read Get_Button;
    property BitMap[Index: Integer]: IBitMap read Get_BitMap;
    property Font[Index: Integer]: IGPCSFont read Get_Font;
    property TextLabel[Index: Integer]: IGPCSLabel read Get_TextLabel;
    property RightAnchored: WordBool read Get_RightAnchored write Set_RightAnchored;
    property Visible: WordBool read Get_Visible write Set_Visible;
  end;

{ DispInterface declaration for Dual Interface IUIStyle }

  IUIStyleDisp = dispinterface
    ['{B20C0141-CF20-11D2-AA05-00A0CC3A61B2}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property Width: Integer dispid 1;
    property Height: Integer dispid 2;
    property BGColor: Integer dispid 3;
    property DefaultFontIdent: Integer dispid 4;
    property ButtonCount: Integer readonly dispid 5;
    property BitMapCount: Integer readonly dispid 6;
    property FontCount: Integer readonly dispid 7;
    property TextLabelCount: Integer readonly dispid 8;
    property Button[Index: Integer]: IButton readonly dispid 9;
    property BitMap[Index: Integer]: IBitMap readonly dispid 10;
    property Font[Index: Integer]: IGPCSFont readonly dispid 11;
    property TextLabel[Index: Integer]: IGPCSLabel readonly dispid 12;
    function AddButton: Integer; dispid 13;
    function AddBitMap: Integer; dispid 14;
    function AddFont: Integer; dispid 15;
    function AddTextLabel: Integer; dispid 16;
    property RightAnchored: WordBool dispid 17;
    property Visible: WordBool dispid 18;
  end;

  IUIServer = interface(IBaseComponent)
    ['{273517E2-CF2B-11D2-AA05-00A0CC3A61B2}']
    function Get_Client: IUIStyle; safecall;
    procedure Set_Client(const Value: IUIStyle); safecall;
    procedure OnButtonClick(const Sender: IButton); safecall;
    property Client: IUIStyle read Get_Client write Set_Client;
  end;

{ DispInterface declaration for Dual Interface IUIServer }

  IUIServerDisp = dispinterface
    ['{273517E2-CF2B-11D2-AA05-00A0CC3A61B2}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property Client: IUIStyle dispid 1;
    procedure OnButtonClick(const Sender: IButton); dispid 2;
  end;

  IDesignEventSink = interface(IBaseComponent)
    ['{47ABB0A0-D68E-11D2-AA05-00A0CC3A61B2}']
    function Get_Parent: Integer; safecall;
    procedure Set_Parent(Value: Integer); safecall;
    function Get_BuildParams: WideString; safecall;
    procedure Set_BuildParams(const Value: WideString); safecall;
    function Get_DataChange: WideString; safecall;
    procedure Set_DataChange(const Value: WideString); safecall;
    procedure Cancel; safecall;
    function ReBuild: WordBool; safecall;
    function Attach(const Component: IComponent): WordBool; safecall;
    property Parent: Integer read Get_Parent write Set_Parent;
    property BuildParams: WideString read Get_BuildParams write Set_BuildParams;
    property DataChange: WideString read Get_DataChange write Set_DataChange;
  end;

{ DispInterface declaration for Dual Interface IDesignEventSink }

  IDesignEventSinkDisp = dispinterface
    ['{47ABB0A0-D68E-11D2-AA05-00A0CC3A61B2}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property Parent: Integer dispid 1;
    property BuildParams: WideString dispid 2;
    property DataChange: WideString dispid 3;
    procedure Cancel; dispid 4;
    function ReBuild: WordBool; dispid 5;
    function Attach(const Component: IComponent): WordBool; dispid 6;
  end;

  ITranslate = interface(IBaseComponent)
    ['{814B1950-2B12-11D3-96F9-DEE8E6C0AD37}']
    function Get_AvailableLanguages: WideString; safecall;
    function Get_CurrentLanguage: WideString; safecall;
    procedure Set_CurrentLanguage(const Value: WideString); safecall;
    function Get_CurrentLanguageID: Integer; safecall;
    procedure Set_CurrentLanguageID(Value: Integer); safecall;
    function Get_DefaultLanguage: WideString; safecall;
    function Get_DefaultLanguageID: Integer; safecall;
    function Get_LanguageDataPath: WideString; safecall;
    function Get_Modified: WordBool; safecall;
    function Get_SaveOnClose: WordBool; safecall;
    procedure Set_SaveOnClose(Value: WordBool); safecall;
    function Get_SaveOnAdd: WordBool; safecall;
    procedure Set_SaveOnAdd(Value: WordBool); safecall;
    procedure Save; safecall;
    function Translate(const Text: WideString): WideString; safecall;
    function TranslateFromTo(const Text, FromLanguage, ToLanguage: WideString): WideString; safecall;
    function TranslateCommaText(const Text, TransCols: WideString): WideString; safecall;
    property AvailableLanguages: WideString read Get_AvailableLanguages;
    property CurrentLanguage: WideString read Get_CurrentLanguage write Set_CurrentLanguage;
    property CurrentLanguageID: Integer read Get_CurrentLanguageID write Set_CurrentLanguageID;
    property DefaultLanguage: WideString read Get_DefaultLanguage;
    property DefaultLanguageID: Integer read Get_DefaultLanguageID;
    property LanguageDataPath: WideString read Get_LanguageDataPath;
    property Modified: WordBool read Get_Modified;
    property SaveOnClose: WordBool read Get_SaveOnClose write Set_SaveOnClose;
    property SaveOnAdd: WordBool read Get_SaveOnAdd write Set_SaveOnAdd;
  end;

{ DispInterface declaration for Dual Interface ITranslate }

  ITranslateDisp = dispinterface
    ['{814B1950-2B12-11D3-96F9-DEE8E6C0AD37}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property AvailableLanguages: WideString readonly dispid 1;
    property CurrentLanguage: WideString dispid 2;
    property CurrentLanguageID: Integer dispid 3;
    property DefaultLanguage: WideString readonly dispid 4;
    property DefaultLanguageID: Integer readonly dispid 5;
    property LanguageDataPath: WideString readonly dispid 6;
    property Modified: WordBool readonly dispid 7;
    property SaveOnClose: WordBool dispid 8;
    property SaveOnAdd: WordBool dispid 9;
    procedure Save; dispid 10;
    function Translate(const Text: WideString): WideString; dispid 11;
    function TranslateFromTo(const Text, FromLanguage, ToLanguage: WideString): WideString; dispid 12;
    function TranslateCommaText(const Text, TransCols: WideString): WideString; dispid 13;
  end;

{ GPCS IMessenger Interface }

  IMessenger = interface(IBaseComponent)
    ['{28B479E0-3549-11D3-9EA4-00902707E0A1}']
    function SetEvSink(const Sink: IMessenger): IMessenger; safecall;
    function Get_Data: WideString; safecall;
    procedure Set_Data(const Value: WideString); safecall;
    function Get_Name: WideString; safecall;
    procedure Shutdown; safecall;
    property Data: WideString read Get_Data write Set_Data;
    property Name: WideString read Get_Name;
  end;

{ DispInterface declaration for Dual Interface IMessenger }

  IMessengerDisp = dispinterface
    ['{28B479E0-3549-11D3-9EA4-00902707E0A1}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    function SetEvSink(const Sink: IMessenger): IMessenger; dispid 1;
    property Data: WideString dispid 2;
    property Name: WideString readonly dispid 3;
    procedure Shutdown; dispid 4;
  end;

  IUILink = interface(IBaseComponent)
    ['{307064B2-E114-49DB-BF53-518F8BDBE788}']
    procedure SetButtonState(Index: Integer; State: ButtonState); safecall;
    procedure SetTitle(const Value: WideString); safecall;
    procedure SetPrompt(const Value: WideString); safecall;
    procedure SetHint1(const Value: WideString); safecall;
    procedure SetHint2(const Value: WideString); safecall;
    procedure SetFormState(Value: FormState); safecall;
    procedure SetText(const Value: WideString); safecall;
    procedure ClearUI; safecall;
    procedure SetButtonInfo(Index: Integer; const Caption: WideString; PictureID: Integer; Price: Currency; Enabled, Selected: WordBool); safecall;
    procedure SetLineInfo(Index: Integer; const Caption: WideString); safecall;
    procedure SetCurrentLine(Value: Integer); safecall;
    function GetCurrentLine: Integer; safecall;
    function GetMaxCurrentLine: Integer; safecall;
    procedure SetServerName(const Value: WideString); safecall;
    function SavePicture(const Picture: IBitMap): Integer; safecall;
    function GetPictureIdentFromCRC(CRC: Integer): Integer; safecall;
    procedure SetUIClientSink(const UIClientSink: IUIClientSink); safecall;
    procedure SetPicture(PictureID: Integer); safecall;
    function Get_MaxItem: Integer; safecall;
    procedure Set_MaxItem(Value: Integer); safecall;
    property MaxItem: Integer read Get_MaxItem write Set_MaxItem;
  end;

{ DispInterface declaration for Dual Interface IUILink }

  IUILinkDisp = dispinterface
    ['{307064B2-E114-49DB-BF53-518F8BDBE788}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    procedure SetButtonState(Index: Integer; State: ButtonState); dispid 1;
    procedure SetTitle(const Value: WideString); dispid 2;
    procedure SetPrompt(const Value: WideString); dispid 3;
    procedure SetHint1(const Value: WideString); dispid 4;
    procedure SetHint2(const Value: WideString); dispid 5;
    procedure SetFormState(Value: FormState); dispid 6;
    procedure SetText(const Value: WideString); dispid 7;
    procedure ClearUI; dispid 8;
    procedure SetButtonInfo(Index: Integer; const Caption: WideString; PictureID: Integer; Price: Currency; Enabled, Selected: WordBool); dispid 9;
    procedure SetLineInfo(Index: Integer; const Caption: WideString); dispid 10;
    procedure SetCurrentLine(Value: Integer); dispid 11;
    function GetCurrentLine: Integer; dispid 12;
    function GetMaxCurrentLine: Integer; dispid 13;
    procedure SetServerName(const Value: WideString); dispid 14;
    function SavePicture(const Picture: IBitMap): Integer; dispid 15;
    function GetPictureIdentFromCRC(CRC: Integer): Integer; dispid 16;
    procedure SetUIClientSink(const UIClientSink: IUIClientSink); dispid 17;
    procedure SetPicture(PictureID: Integer); dispid 18;
    property MaxItem: Integer dispid 19;
  end;

  IUIClientSink = interface(IBaseComponent)
    ['{3F285829-6B04-41E2-8D17-B7298844D059}']
    procedure KeyPress(KeyCode: Integer; SystemKey: WordBool); safecall;
  end;

{ DispInterface declaration for Dual Interface IUIClientSink }

  IUIClientSinkDisp = dispinterface
    ['{3F285829-6B04-41E2-8D17-B7298844D059}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    procedure KeyPress(KeyCode: Integer; SystemKey: WordBool); dispid 1;
  end;

  IPickItem = interface(IBaseComponent)
    ['{F35D4A96-B07C-4E7F-BB25-3E51A68C4A10}']
    function Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    function Get_Picture: IBitMap; safecall;
    procedure Set_Picture(const Value: IBitMap); safecall;
    function Get_Selected: WordBool; safecall;
    procedure Set_Selected(Value: WordBool); safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    function Get_Price: Currency; safecall;
    procedure Set_Price(Value: Currency); safecall;
    property Caption: WideString read Get_Caption write Set_Caption;
    property Picture: IBitMap read Get_Picture write Set_Picture;
    property Selected: WordBool read Get_Selected write Set_Selected;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property Price: Currency read Get_Price write Set_Price;
  end;

{ DispInterface declaration for Dual Interface IPickItem }

  IPickItemDisp = dispinterface
    ['{F35D4A96-B07C-4E7F-BB25-3E51A68C4A10}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property Caption: WideString dispid 1;
    property Picture: IBitMap dispid 2;
    property Selected: WordBool dispid 3;
    property Enabled: WordBool dispid 4;
    property Price: Currency dispid 5;
  end;

  IPickItemList = interface(IBaseComponent)
    ['{AD6A2428-C946-48EE-AC74-5FC30340BBCE}']
    function Get_Title: WideString; safecall;
    procedure Set_Title(const Value: WideString); safecall;
    function Get_Prompt: WideString; safecall;
    procedure Set_Prompt(const Value: WideString); safecall;
    function Get_Hint: WideString; safecall;
    procedure Set_Hint(const Value: WideString); safecall;
    function Get_Picture: IBitMap; safecall;
    procedure Set_Picture(const Value: IBitMap); safecall;
    function Get_Items(Index: Integer): IPickItem; safecall;
    function Add(const PickItem: IPickItem): Integer; safecall;
    procedure Delete(Index: Integer); safecall;
    function Get_Count: Integer; safecall;
    property Title: WideString read Get_Title write Set_Title;
    property Prompt: WideString read Get_Prompt write Set_Prompt;
    property Hint: WideString read Get_Hint write Set_Hint;
    property Picture: IBitMap read Get_Picture write Set_Picture;
    property Items[Index: Integer]: IPickItem read Get_Items;
    property Count: Integer read Get_Count;
  end;

{ DispInterface declaration for Dual Interface IPickItemList }

  IPickItemListDisp = dispinterface
    ['{AD6A2428-C946-48EE-AC74-5FC30340BBCE}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    property Title: WideString dispid 1;
    property Prompt: WideString dispid 2;
    property Hint: WideString dispid 3;
    property Picture: IBitMap dispid 4;
    property Items[Index: Integer]: IPickItem readonly dispid 5;
    function Add(const PickItem: IPickItem): Integer; dispid 6;
    procedure Delete(Index: Integer); dispid 7;
    property Count: Integer readonly dispid 8;
  end;

  IUIState = interface(IBaseComponent)
    ['{E78FD4FE-D291-4706-B28F-3B6C39986845}']
    procedure ShowForm(const Items: IPickItemList; const Product: IProduct; const HItems: IPickItemList; const HText: WideString); safecall;
    function ShowWarning(const WButtons: IPickItemList; const Warning: WideString): Integer; safecall;
    procedure ShowHelp(const HelpText: WideString); safecall;
    procedure ShowInfo(const HelpText: WideString); safecall;
    function PickItem(const Items: IPickItemList; ShowNumbers, Sorted: WordBool; DefaultItem: Integer): Integer; safecall;
    function PickMenuItem(const Items: IPickItemList; const TransactionLog: ITransactionLog): Integer; safecall;
    function Get_CurrentState: FormState; safecall;
    procedure Set_CurrentState(Value: FormState); safecall;
    property CurrentState: FormState read Get_CurrentState write Set_CurrentState;
  end;

{ DispInterface declaration for Dual Interface IUIState }

  IUIStateDisp = dispinterface
    ['{E78FD4FE-D291-4706-B28F-3B6C39986845}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    procedure ShowForm(const Items: IPickItemList; const Product: IProduct; const HItems: IPickItemList; const HText: WideString); dispid 8;
    function ShowWarning(const WButtons: IPickItemList; const Warning: WideString): Integer; dispid 9;
    procedure ShowHelp(const HelpText: WideString); dispid 10;
    procedure ShowInfo(const HelpText: WideString); dispid 11;
    function PickItem(const Items: IPickItemList; ShowNumbers, Sorted: WordBool; DefaultItem: Integer): Integer; dispid 12;
    function PickMenuItem(const Items: IPickItemList; const TransactionLog: ITransactionLog): Integer; dispid 13;
    property CurrentState: FormState dispid 14;
  end;

  IPeriod = interface(IBaseComponent)
    ['{3018FF92-E646-45A1-8B33-A2E0D89843F9}']
    function GetCurrentPeriod(const User: WideString): Integer; safecall;
    procedure StartOfDay(const User: WideString); safecall;
    procedure EndOfDay(const User: WideString); safecall;
    procedure Open(const User: WideString; Period: Integer); safecall;
    function GetStartOfDayValues(const User: WideString): WideString; safecall;
    function HadEndOfDay(const User: WideString): WordBool; safecall;
    function GetLastPeriod(const User: WideString): Integer; safecall;
    function GetLastPeriodCash(const User: WideString): Currency; safecall;
    function GetPeriodCash(const User: WideString): Currency; safecall;
    function GetPeriodStock(const User: WideString): Currency; safecall;
    function GetESState(const User: WideString): esState; safecall;
  end;

{ DispInterface declaration for Dual Interface IPeriod }

  IPeriodDisp = dispinterface
    ['{3018FF92-E646-45A1-8B33-A2E0D89843F9}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    function GetCurrentPeriod(const User: WideString): Integer; dispid 1;
    procedure StartOfDay(const User: WideString); dispid 2;
    procedure EndOfDay(const User: WideString); dispid 3;
    procedure Open(const User: WideString; Period: Integer); dispid 4;
    function GetStartOfDayValues(const User: WideString): WideString; dispid 5;
    function HadEndOfDay(const User: WideString): WordBool; dispid 6;
    function GetLastPeriod(const User: WideString): Integer; dispid 7;
    function GetLastPeriodCash(const User: WideString): Currency; dispid 8;
    function GetPeriodCash(const User: WideString): Currency; dispid 9;
    function GetPeriodStock(const User: WideString): Currency; dispid 10;
    function GetESState(const User: WideString): esState; dispid 11;
  end;

  ITableMonitor = interface(IBaseComponent)
    ['{ADBE3742-9FAA-49B8-87D2-ACEA1C0B1D4B}']
    procedure Attach; safecall;
    procedure WriteTransactions(const PackText: WideString); safecall;
  end;

{ DispInterface declaration for Dual Interface ITableMonitor }

  ITableMonitorDisp = dispinterface
    ['{ADBE3742-9FAA-49B8-87D2-ACEA1C0B1D4B}']
    function AccessFunction(const FunctionName, Value: WideString): WideString; dispid 999999;
    procedure Attach; dispid 1;
    procedure WriteTransactions(const PackText: WideString); dispid 2;
  end;

{ GPCS Exec Component }

  CoGPCSExecComponent = class
    class function Create: IExecComponent;
    class function CreateRemote(const MachineName: string): IExecComponent;
  end;

{ GPCS Abstract Product }

  CoGPCSAbstractProduct = class
    class function Create: IProduct;
    class function CreateRemote(const MachineName: string): IProduct;
  end;

{ GPCS Abstract Group }

  CoGPCSAbstractGroup = class
    class function Create: IGroup;
    class function CreateRemote(const MachineName: string): IGroup;
  end;

{ GPCS Abstract WU Group }

  CoGPCSAbstractWUGroup = class
    class function Create: IWUGroup;
    class function CreateRemote(const MachineName: string): IWUGroup;
  end;

{ GPCS Abstract Pick List }

  CoGPCSAbstractPickList = class
    class function Create: IPickList;
    class function CreateRemote(const MachineName: string): IPickList;
  end;

{ GPCS Abstract LookUp }

  CoGPCSAbstractLookUp = class
    class function Create: ILookUp;
    class function CreateRemote(const MachineName: string): ILookUp;
  end;

{ GPCS Abstract Event sink }

  CoGPCSAbstractEventSink = class
    class function Create: IEventSink;
    class function CreateRemote(const MachineName: string): IEventSink;
  end;

{ GPCS Abstract UI Event Sink }

  CoGPCSAbstractUIEventSink = class
    class function Create: IUIEventSink;
    class function CreateRemote(const MachineName: string): IUIEventSink;
  end;

{ GPCS Abstract service }

  CoGPCSAbstractService = class
    class function Create: IService;
    class function CreateRemote(const MachineName: string): IService;
  end;

{ GPCS Abstract Component Loader }

  CoAbstractCompLoad = class
    class function Create: ICompLoad;
    class function CreateRemote(const MachineName: string): ICompLoad;
  end;

{ GPCS Abstract Component Manager }

  CoAbstractCompMan = class
    class function Create: ICompMan;
    class function CreateRemote(const MachineName: string): ICompMan;
  end;

{ GPCS Abstract Error Handler }

  CoAbstractErrorHandler = class
    class function Create: IErrorHandler;
    class function CreateRemote(const MachineName: string): IErrorHandler;
  end;

{ GPCS Abstract System Group }

  CoGPCSAbstractSysGroup = class
    class function Create: ISysGroup;
    class function CreateRemote(const MachineName: string): ISysGroup;
  end;

{ GPCS Abstract Transaction Log }

  CoAbstractTransactionLog = class
    class function Create: ITransactionLog;
    class function CreateRemote(const MachineName: string): ITransactionLog;
  end;

{ GPCS Abstract Transaction event sink }

  CoAbstractTxnEventSink = class
    class function Create: ITxnEventSink;
    class function CreateRemote(const MachineName: string): ITxnEventSink;
  end;

{ GPCS Device }

  CoGPCSDevice = class
    class function Create: IDevice;
    class function CreateRemote(const MachineName: string): IDevice;
  end;

{ GPCS Device Event sink }

  CoDeviceEventSink = class
    class function Create: IDeviceEventSink;
    class function CreateRemote(const MachineName: string): IDeviceEventSink;
  end;

{ GPCS Picture server }

  CoPictureServer = class
    class function Create: IPictureServer;
    class function CreateRemote(const MachineName: string): IPictureServer;
  end;

{ GPCS Mail Item Log }

  CoMailItemLog = class
    class function Create: IMailItemLog;
    class function CreateRemote(const MachineName: string): IMailItemLog;
  end;

{ GPCS Exchange Rate Server }

  CoBaseExchangeRateServer = class
    class function Create: IExchangeRateServer;
    class function CreateRemote(const MachineName: string): IExchangeRateServer;
  end;

{ GPCS Hot Keys }

  CoBaseHotKeys = class
    class function Create: IHotKeys;
    class function CreateRemote(const MachineName: string): IHotKeys;
  end;

{ GPCS Accounts }

  CoGPCSAccounts = class
    class function Create: IAccounts;
    class function CreateRemote(const MachineName: string): IAccounts;
  end;

{ GPCS Site Manager }

  CoGPCSSiteManager = class
    class function Create: ISiteManager;
    class function CreateRemote(const MachineName: string): ISiteManager;
  end;

{ GPCS Remote Control }

  CoGPCSRemoteControl = class
    class function Create: IRemoteControl;
    class function CreateRemote(const MachineName: string): IRemoteControl;
  end;

{ GPCS HookUp }

  CoGPCSHookUp = class
    class function Create: IHookUp;
    class function CreateRemote(const MachineName: string): IHookUp;
  end;

{ GPCS Stock }

  CoGPCSStock = class
    class function Create: IStock;
    class function CreateRemote(const MachineName: string): IStock;
  end;

  CoUIServer = class
    class function Create: IUIServer;
    class function CreateRemote(const MachineName: string): IUIServer;
  end;

{ GPCS Language Translation Component }

  CoTranslate = class
    class function Create: ITranslate;
    class function CreateRemote(const MachineName: string): ITranslate;
  end;

{ GPCS Messenger }

  CoMessenger = class
    class function Create: IMessenger;
    class function CreateRemote(const MachineName: string): IMessenger;
  end;

  CoUILink = class
    class function Create: IUILink;
    class function CreateRemote(const MachineName: string): IUILink;
  end;

  CoUIState = class
    class function Create: IUIState;
    class function CreateRemote(const MachineName: string): IUIState;
  end;

  CoPeriod = class
    class function Create: IPeriod;
    class function CreateRemote(const MachineName: string): IPeriod;
  end;

{ GPCS Transact Table Monitor }

  CoTableMonitor = class
    class function Create: ITableMonitor;
    class function CreateRemote(const MachineName: string): ITableMonitor;
  end;

{ GPCS Component Object }

  CoGPCSComponent = class
    class function Create: IComponent;
    class function CreateRemote(const MachineName: string): IComponent;
  end;

{ GPCS Base Component }

  CoGPCSBaseComponent = class
    class function Create: IBaseComponent;
    class function CreateRemote(const MachineName: string): IBaseComponent;
  end;



implementation

uses ComObj;

class function CoGPCSExecComponent.Create: IExecComponent;
begin
  Result := CreateComObject(Class_GPCSExecComponent) as IExecComponent;
end;

class function CoGPCSExecComponent.CreateRemote(const MachineName: string): IExecComponent;
begin
  Result := CreateRemoteComObject(MachineName, Class_GPCSExecComponent) as IExecComponent;
end;

class function CoGPCSAbstractProduct.Create: IProduct;
begin
  Result := CreateComObject(Class_GPCSAbstractProduct) as IProduct;
end;

class function CoGPCSAbstractProduct.CreateRemote(const MachineName: string): IProduct;
begin
  Result := CreateRemoteComObject(MachineName, Class_GPCSAbstractProduct) as IProduct;
end;

class function CoGPCSAbstractGroup.Create: IGroup;
begin
  Result := CreateComObject(Class_GPCSAbstractGroup) as IGroup;
end;

class function CoGPCSAbstractGroup.CreateRemote(const MachineName: string): IGroup;
begin
  Result := CreateRemoteComObject(MachineName, Class_GPCSAbstractGroup) as IGroup;
end;

class function CoGPCSAbstractWUGroup.Create: IWUGroup;
begin
  Result := CreateComObject(Class_GPCSAbstractWUGroup) as IWUGroup;
end;

class function CoGPCSAbstractWUGroup.CreateRemote(const MachineName: string): IWUGroup;
begin
  Result := CreateRemoteComObject(MachineName, Class_GPCSAbstractWUGroup) as IWUGroup;
end;

class function CoGPCSAbstractPickList.Create: IPickList;
begin
  Result := CreateComObject(Class_GPCSAbstractPickList) as IPickList;
end;

class function CoGPCSAbstractPickList.CreateRemote(const MachineName: string): IPickList;
begin
  Result := CreateRemoteComObject(MachineName, Class_GPCSAbstractPickList) as IPickList;
end;

class function CoGPCSAbstractLookUp.Create: ILookUp;
begin
  Result := CreateComObject(Class_GPCSAbstractLookUp) as ILookUp;
end;

class function CoGPCSAbstractLookUp.CreateRemote(const MachineName: string): ILookUp;
begin
  Result := CreateRemoteComObject(MachineName, Class_GPCSAbstractLookUp) as ILookUp;
end;

class function CoGPCSAbstractEventSink.Create: IEventSink;
begin
  Result := CreateComObject(Class_GPCSAbstractEventSink) as IEventSink;
end;

class function CoGPCSAbstractEventSink.CreateRemote(const MachineName: string): IEventSink;
begin
  Result := CreateRemoteComObject(MachineName, Class_GPCSAbstractEventSink) as IEventSink;
end;

class function CoGPCSAbstractUIEventSink.Create: IUIEventSink;
begin
  Result := CreateComObject(Class_GPCSAbstractUIEventSink) as IUIEventSink;
end;

class function CoGPCSAbstractUIEventSink.CreateRemote(const MachineName: string): IUIEventSink;
begin
  Result := CreateRemoteComObject(MachineName, Class_GPCSAbstractUIEventSink) as IUIEventSink;
end;

class function CoGPCSAbstractService.Create: IService;
begin
  Result := CreateComObject(Class_GPCSAbstractService) as IService;
end;

class function CoGPCSAbstractService.CreateRemote(const MachineName: string): IService;
begin
  Result := CreateRemoteComObject(MachineName, Class_GPCSAbstractService) as IService;
end;

class function CoAbstractCompLoad.Create: ICompLoad;
begin
  Result := CreateComObject(Class_AbstractCompLoad) as ICompLoad;
end;

class function CoAbstractCompLoad.CreateRemote(const MachineName: string): ICompLoad;
begin
  Result := CreateRemoteComObject(MachineName, Class_AbstractCompLoad) as ICompLoad;
end;

class function CoAbstractCompMan.Create: ICompMan;
begin
  Result := CreateComObject(Class_AbstractCompMan) as ICompMan;
end;

class function CoAbstractCompMan.CreateRemote(const MachineName: string): ICompMan;
begin
  Result := CreateRemoteComObject(MachineName, Class_AbstractCompMan) as ICompMan;
end;

class function CoAbstractErrorHandler.Create: IErrorHandler;
begin
  Result := CreateComObject(Class_AbstractErrorHandler) as IErrorHandler;
end;

class function CoAbstractErrorHandler.CreateRemote(const MachineName: string): IErrorHandler;
begin
  Result := CreateRemoteComObject(MachineName, Class_AbstractErrorHandler) as IErrorHandler;
end;

class function CoGPCSAbstractSysGroup.Create: ISysGroup;
begin
  Result := CreateComObject(Class_GPCSAbstractSysGroup) as ISysGroup;
end;

class function CoGPCSAbstractSysGroup.CreateRemote(const MachineName: string): ISysGroup;
begin
  Result := CreateRemoteComObject(MachineName, Class_GPCSAbstractSysGroup) as ISysGroup;
end;

class function CoAbstractTransactionLog.Create: ITransactionLog;
begin
  Result := CreateComObject(Class_AbstractTransactionLog) as ITransactionLog;
end;

class function CoAbstractTransactionLog.CreateRemote(const MachineName: string): ITransactionLog;
begin
  Result := CreateRemoteComObject(MachineName, Class_AbstractTransactionLog) as ITransactionLog;
end;

class function CoAbstractTxnEventSink.Create: ITxnEventSink;
begin
  Result := CreateComObject(Class_AbstractTxnEventSink) as ITxnEventSink;
end;

class function CoAbstractTxnEventSink.CreateRemote(const MachineName: string): ITxnEventSink;
begin
  Result := CreateRemoteComObject(MachineName, Class_AbstractTxnEventSink) as ITxnEventSink;
end;

class function CoGPCSDevice.Create: IDevice;
begin
  Result := CreateComObject(Class_GPCSDevice) as IDevice;
end;

class function CoGPCSDevice.CreateRemote(const MachineName: string): IDevice;
begin
  Result := CreateRemoteComObject(MachineName, Class_GPCSDevice) as IDevice;
end;

class function CoDeviceEventSink.Create: IDeviceEventSink;
begin
  Result := CreateComObject(Class_DeviceEventSink) as IDeviceEventSink;
end;

class function CoDeviceEventSink.CreateRemote(const MachineName: string): IDeviceEventSink;
begin
  Result := CreateRemoteComObject(MachineName, Class_DeviceEventSink) as IDeviceEventSink;
end;

class function CoPictureServer.Create: IPictureServer;
begin
  Result := CreateComObject(Class_PictureServer) as IPictureServer;
end;

class function CoPictureServer.CreateRemote(const MachineName: string): IPictureServer;
begin
  Result := CreateRemoteComObject(MachineName, Class_PictureServer) as IPictureServer;
end;

class function CoMailItemLog.Create: IMailItemLog;
begin
  Result := CreateComObject(Class_MailItemLog) as IMailItemLog;
end;

class function CoMailItemLog.CreateRemote(const MachineName: string): IMailItemLog;
begin
  Result := CreateRemoteComObject(MachineName, Class_MailItemLog) as IMailItemLog;
end;

class function CoBaseExchangeRateServer.Create: IExchangeRateServer;
begin
  Result := CreateComObject(Class_BaseExchangeRateServer) as IExchangeRateServer;
end;

class function CoBaseExchangeRateServer.CreateRemote(const MachineName: string): IExchangeRateServer;
begin
  Result := CreateRemoteComObject(MachineName, Class_BaseExchangeRateServer) as IExchangeRateServer;
end;

class function CoBaseHotKeys.Create: IHotKeys;
begin
  Result := CreateComObject(Class_BaseHotKeys) as IHotKeys;
end;

class function CoBaseHotKeys.CreateRemote(const MachineName: string): IHotKeys;
begin
  Result := CreateRemoteComObject(MachineName, Class_BaseHotKeys) as IHotKeys;
end;

class function CoGPCSAccounts.Create: IAccounts;
begin
  Result := CreateComObject(Class_GPCSAccounts) as IAccounts;
end;

class function CoGPCSAccounts.CreateRemote(const MachineName: string): IAccounts;
begin
  Result := CreateRemoteComObject(MachineName, Class_GPCSAccounts) as IAccounts;
end;

class function CoGPCSSiteManager.Create: ISiteManager;
begin
  Result := CreateComObject(Class_GPCSSiteManager) as ISiteManager;
end;

class function CoGPCSSiteManager.CreateRemote(const MachineName: string): ISiteManager;
begin
  Result := CreateRemoteComObject(MachineName, Class_GPCSSiteManager) as ISiteManager;
end;

class function CoGPCSRemoteControl.Create: IRemoteControl;
begin
  Result := CreateComObject(Class_GPCSRemoteControl) as IRemoteControl;
end;

class function CoGPCSRemoteControl.CreateRemote(const MachineName: string): IRemoteControl;
begin
  Result := CreateRemoteComObject(MachineName, Class_GPCSRemoteControl) as IRemoteControl;
end;

class function CoGPCSHookUp.Create: IHookUp;
begin
  Result := CreateComObject(Class_GPCSHookUp) as IHookUp;
end;

class function CoGPCSHookUp.CreateRemote(const MachineName: string): IHookUp;
begin
  Result := CreateRemoteComObject(MachineName, Class_GPCSHookUp) as IHookUp;
end;

class function CoGPCSStock.Create: IStock;
begin
  Result := CreateComObject(Class_GPCSStock) as IStock;
end;

class function CoGPCSStock.CreateRemote(const MachineName: string): IStock;
begin
  Result := CreateRemoteComObject(MachineName, Class_GPCSStock) as IStock;
end;

class function CoUIServer.Create: IUIServer;
begin
  Result := CreateComObject(Class_UIServer) as IUIServer;
end;

class function CoUIServer.CreateRemote(const MachineName: string): IUIServer;
begin
  Result := CreateRemoteComObject(MachineName, Class_UIServer) as IUIServer;
end;

class function CoTranslate.Create: ITranslate;
begin
  Result := CreateComObject(Class_Translate) as ITranslate;
end;

class function CoTranslate.CreateRemote(const MachineName: string): ITranslate;
begin
  Result := CreateRemoteComObject(MachineName, Class_Translate) as ITranslate;
end;

class function CoMessenger.Create: IMessenger;
begin
  Result := CreateComObject(Class_Messenger) as IMessenger;
end;

class function CoMessenger.CreateRemote(const MachineName: string): IMessenger;
begin
  Result := CreateRemoteComObject(MachineName, Class_Messenger) as IMessenger;
end;

class function CoUILink.Create: IUILink;
begin
  Result := CreateComObject(Class_UILink) as IUILink;
end;

class function CoUILink.CreateRemote(const MachineName: string): IUILink;
begin
  Result := CreateRemoteComObject(MachineName, Class_UILink) as IUILink;
end;

class function CoUIState.Create: IUIState;
begin
  Result := CreateComObject(Class_UIState) as IUIState;
end;

class function CoUIState.CreateRemote(const MachineName: string): IUIState;
begin
  Result := CreateRemoteComObject(MachineName, Class_UIState) as IUIState;
end;

class function CoPeriod.Create: IPeriod;
begin
  Result := CreateComObject(Class_Period) as IPeriod;
end;

class function CoPeriod.CreateRemote(const MachineName: string): IPeriod;
begin
  Result := CreateRemoteComObject(MachineName, Class_Period) as IPeriod;
end;

class function CoTableMonitor.Create: ITableMonitor;
begin
  Result := CreateComObject(Class_TableMonitor) as ITableMonitor;
end;

class function CoTableMonitor.CreateRemote(const MachineName: string): ITableMonitor;
begin
  Result := CreateRemoteComObject(MachineName, Class_TableMonitor) as ITableMonitor;
end;

class function CoGPCSComponent.Create: IComponent;
begin
  Result := CreateComObject(Class_GPCSComponent) as IComponent;
end;

class function CoGPCSComponent.CreateRemote(const MachineName: string): IComponent;
begin
  Result := CreateRemoteComObject(MachineName, Class_GPCSComponent) as IComponent;
end;

class function CoGPCSBaseComponent.Create: IBaseComponent;
begin
  Result := CreateComObject(Class_GPCSBaseComponent) as IBaseComponent;
end;

class function CoGPCSBaseComponent.CreateRemote(const MachineName: string): IBaseComponent;
begin
  Result := CreateRemoteComObject(MachineName, Class_GPCSBaseComponent) as IBaseComponent;
end;


end.
