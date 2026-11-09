unit BaseProduct;

interface

uses
  CommonConst,
  DBUtil,
  ShareDataU,
  UIDLLSupportU,
  Utils,
  StringWrapperU,
  QueryMapU,
  Stock2U,
  RegistryEx,
  Windows,ReportPreviewF,
  Math,
  StringUtil,
  Forms,ComObj, ActiveX, SysUtils, Classes,
  GPCSBaseAU, GPCSBase_TLB,GPCSErrorLine,GPCSErrorCode,
  {ProdDesign,CompInspector,}GPCSGUID,Domain,CombineU,
  DatabaseServer_TLB,PrintReportU,UserManager_TLB,PackStrListU,Dialogs;
//  DatabaseServer_TLB,PrintReportU,UManager_TLB,PackStrListU,Dialogs;
const
   K_CANCELATION_STR='RECORCANCEL';
type
  TSummaryType        = (stSummary,stDetail,stEveryLine);
  TMutualActionType  = Set Of (maDeSelect, maEnable, maDisable);

  TReportParams = record
    OfficeNo    : String;
    FromDate    : String;
    FromPeriod  : Integer;
    ToPeriod    : Integer;
    ToDate      : String;
    Summary     : TSummaryType;
    ReportLines : TStringList;
    DB          : IDatabaseServerAuto;
    Stock       : IStock;
    User        : String;
  end;


  TBaseProduct = class(TGPCSAbstractProduct,IEventSink,IUIEventSink)
  private
//    HModule       : THandle;
//    ReportFunc    : function(BaseProduct : TBaseProduct) : Boolean;
    CustDisp      : IDevice;
    TotalField    : TDomainEdit;
    FUser         : String;
    IdentStr      : String;
    StockReturns     : Boolean;
    TotalReceipt : Currency;
    TotalPayment : Currency;
    TotalStock   : Currency ;
    AStock              : IStock;
    procedure TotRec(Title,Range,RType:String);
    function  TotRecRel(Title,Range,RType:String) : Currency;
//    procedure TotPay(Title,Range,RType:String );
    procedure TotPayRel(Title,Range,RType:String );
    procedure TotStk(Title,Range:String);
    procedure TotStS(Title,Range:String);
    procedure TotStM(Title,Range,SRange:String);

  protected
    DisablePrint:Boolean;
    FUIEventSink:IUIEventSink;
    IndentStampLog:Integer;
    FNested:WordBool;
    procedure CompleteTransfers(FromUser:String;CommingToThisUser:Boolean;StockLines:TStrings;TxnLog:ITransactionLog;PeriodTxn:integer);
    procedure UpdateCustomerDisplay(Line1,Line2:String);
    procedure SetExchangeRates(TxnLog:ITransactionLog;List:TDomainCombo);
    procedure SetExchangeRate(TxnLog:ITransactionLog; Key,Value:String);
    function  GetExchangeRates(List:TDomainCombo):Boolean;
    function  GetAvailableStock(List:TDomainCombo;Owner,StockType:String):Boolean;
    procedure CancelTransfer( TxnLog:ITransactionLog;List:TDomainCombo);
    procedure LogStock(TxnLog:ITransactionLog;List:TDomainCombo);
    procedure LogStandardTxn(const TxnLog : ITransactionLog;  ProdForm : TForm; var Index : Integer; Price : Currency; Description, Additional : String);
    procedure UseAdjustStockItem(TxnLog : ITransactionLog; Index : Integer; StockItemDesc : String; Quantity : Integer; Log : Boolean);
    function  CalcMultiStockDenoms(StockLines:TStrings;TotalValue:Currency; Multiple : Integer):String;
    function  CalcStockDenoms(StockLines:TStrings;TotalValue:Currency):String;
    function  FindTotalField(ProdForm:TForm):TDomainEdit;
    function  TotalWithoutAdvDel(ProdForm:TForm):String;
    procedure SetTotalFieldValue(ProdForm:TForm;Value:Currency);
    function  EndorseData(Price:Currency;DataLine1,DataLine2,FormData:String):String;
    function  EndorseLabels(Number : Integer; Value:Currency;TxnLog:ITransactionLog;CommaText:String;WaitRemoval:Boolean):Boolean;
    function  EndorseLabel(Value:Currency;TxnLog:ITransactionLog;CommaText:String;WaitRemoval:Boolean):Boolean;
    function  ListTotal(List:TDomainCombo):String;
    function  CheckTransfersAvail(List:TDomainCombo;Owner:String):Boolean;
    function  GetTransferDetails(List:TDomainCombo;Owner,ReqFrom:String):Boolean;
    procedure CancelDailyTransfer( ListOrg: TdomainCombo; Owner,DateTran :String;const TxnLog: ITransactionLog);

    procedure PrintReport(Lines:TStrings);
    procedure PrintReportReceipt(MajorColumnWidths, MinorColumnWidths :String; ReportVals : String);
    procedure Print2x2Report(Lines:TStrings);
    procedure PrintReportStandard(MajorColumnWidths, MinorColumnWidths, ReportVals : String);

    function  OfficeCheck:String;
    function  UserSearch:String;
    function  GetUserGroup(User:String):String;
    function  CancelledLabelList(DB:IDatabaseServerAuto;FromPeriod,ToPeriod:Integer):String;


    function  TxnReport(RType,FromDate,ToDate:String;Summary:TSummaryType;OfficeNo:String):Currency;
    procedure StockReport;
    procedure UserStockReport(User:String);
    procedure StockReport2x2;
    function  StockReportList(var Total:Currency;User:String):String;
    function  SetUserPassword(OldPass,NewPass:String):Boolean;
    function  ListUsers:String;
    function  GetItemId(DomainEdit : TDomainEdit) : String;

    function GetResourceString(Index:Integer):String; virtual; abstract;
    procedure SetupButtons(MaxItems,Quantity:Integer;NoRedraw:WordBool;const UIEventSink:IUIEventSink;ProdForm:TForm;Nested:WordBool);
    procedure TriggerKeyboard     (Value:String); virtual;
    procedure TriggerBarCode      (Value:String); virtual;
    procedure TriggerOCRReader    (Value:String); virtual;
    procedure TriggerMCRReader    (Value:String); virtual;
    procedure TriggerScale        (Value:String); virtual;
    procedure TriggerOtherReader  (Value:String); virtual;
    procedure TriggerStatusDevice0(Value:String); virtual;
    procedure TriggerStatusDevice1(Value:String); virtual;
    procedure TriggerStatusDevice2(Value:String); virtual;
    procedure TriggerStatusDevice3(Value:String); virtual;
    procedure TriggerStatusDevice4(Value:String); virtual;
    procedure TriggerStatusDevice5(Value:String); virtual;
    procedure TriggerStatusDevice6(Value:String); virtual;
    procedure TriggerStatusDevice7(Value:String); virtual;
    procedure TriggerStatusDevice8(Value:String); virtual;
    procedure TriggerStatusDevice9(Value:String); virtual;
  public
    DoFullUserSearch : Boolean;
    AdditionalInfo:String;
    PrLabelGUID : String;
    ReportParams : TReportParams;
    FOfficeNo:String;
    FReportTitle:String;
    CheckReportedStock : Boolean; // if printing sub cash account only report stock entered for subs
    function SetFormData(Value:String;ProdForm:TForm):String;
    function GetFormData(ProdForm:TForm):String;
    function  SetTotalField(ProdForm:TForm):Currency;
    function  TxnRepSection(DB:IDatabaseServerAuto;Description,Search:String;FromPeriod,ToPeriod:Integer;Res:TStrings;Summary:TSummaryType;ReportEmptyLines:Boolean;TxnType:String):Currency;
    function  TxnRepRelSection(DB:IDatabaseServerAuto;Description,Search:String;FromPeriod,ToPeriod:Integer;Res:TStrings;Summary:TSummaryType;ReportEmptyLines:Boolean;TxnType:String):Currency;
    function StkAtPeriodRepSection(Stock:IStock ; Desc : String; PLUList:String; Res:TStrings; ReportEmptyLines:Boolean; ReqdPeriod : Integer; DB : IDatabaseServerAuto) : Currency;
    function  StkRepSection(Stock:IStock;Description,PLUList:String;Res:TStrings;ReportEmptyLines:Boolean):Currency;
    function LookUpExRate(Name:String):Currency;
    function Get_Name: WideString;                    override;
    function Get_ProjectFiles: WideString;            override;
    function Get_GUID: WideString;                    override;
    function Get_ProgramID: WideString;               override;
    function Get_Version: Integer;                           override;
    function Design(const Password: WideString;const EVSink: IDesignEventSink): WideString; override;
    procedure TerminateDesign;                               override;
    procedure TerminateExecute(const TxnLog: ITransactionLog); override;
    procedure CompleteExecute(var Index:Integer;const TxnLog: ITransactionLog);  override;
    procedure TriggerValue(Source: TriggerSource; const Value: WideString); override;
    function Get_BarCode: WideString;                        override;
    function Get_Description: WideString;                    override;
    function Get_EndDate: WideString;                        override;
    function Get_HighDays: WideString;                       override;
    function Get_MaxQuantity: Integer;                       override;
    function Get_MCRCode: WideString;                        override;
    function Get_MinQuantity: Integer;                       override;
    function Get_OCRCode: WideString;                        override;
    function Get_OtherCode: WideString;                      override;
    function Get_PLU: Integer;                               override;
    function Get_Regulations: WideString;                    override;
    function Get_StartDate: WideString;                      override;
    function Get_UnitPrice: Currency;                        override;
    function Get_UnitQuantity: Integer;                      override;
    function Get_UseDays: WideString;                        override;
    function Get_BitMap: OleVariant;                         override;
    function Get_Caption: WideString;                        override;
    function Get_Price(ScaleReading: Integer): Currency;     override;
    function Get_Count:Integer;                              override;
    function Get_Item(Index:Integer):WideString;             override;
    function Get_PMessage: WideString;                       override;
    function Get_Prompt  : WideString;                       override;
    function Get_Title   : WideString;                       override;
    function Get_AvailableAfterEOD: WordBool;                override;
    function Get_MOPs: WideString;                           override;
    function Get_Taxes: WideString;                          override;

    procedure Execute(Quantity, MaxItems: Integer;
                      NoRedraw: WordBool;
                      const UIEventSink: IUIEventSink;
                      const TxnLog: ITransactionLog;Nested:WordBool);        override;
    procedure NotifyChildClick(const Name: WideString; Index: Integer); override;
    procedure Complete(const EventSource: IExecComponent);            safecall;
    procedure DesignComplete(const EventSource: IExecComponent);      safecall;

    // UIEventSink
    procedure DisplayItemInfo(const EventSource: IExecComponent; Index: Integer; BitMap:OleVariant;const Caption: WideString; Price: Currency; State: Integer;Notify,Nested:WordBool); safecall;
    procedure Restore; safecall;
    procedure DisplayInstructions(Style: InstructStyle; const Text:WideString;BitMap:OleVariant); safecall;
    procedure DataChanged(const EventSource: IExecComponent;const Value: WideString; FlagError: WordBool); safecall;
    function  GetComponentReference(const Name: WideString): IDispatch; safecall;
    function  CurrentDetails:WideString; safecall;
    function  Translate(const Value: WideString):WideString; safecall;
    function  Endorse(X,Y,ColCount:Integer;const CommaText:WideString):WordBool; safecall;
    procedure WaitFor(DeviceStatus: DeviceStatusType); safecall;
    procedure SwapTo(const ProgID, PassData: WideString); safecall;
    function  Get_User:WideString; safecall;
    function  Get_Workstation:Integer; safecall;
    function  Get_Office:Integer; safecall;
    function  ReferenceData(const Name: WideString):WideString; safecall;
    function  CurrentLine: Integer; safecall;
    procedure Print2x2(const Title,Desc1,Desc2,Office,DataCommatext:WideString); safecall;
    function  Get_HookUp:IHookUp; safecall;
    procedure ProgressBar(const Title:WideString;Min,Max,Pos,Auto:Integer); safecall;
    procedure OpenCashDrawer; safecall;
    procedure TransferTxnsToDiskette; safecall;
    procedure TransferTxnsFromDiskette; safecall;
    procedure DeleteStockItems(TxnLog:ITransactionLog;List:TStrings);
    procedure DeleteCountriesExchange( TxnLog:ITransactionLog;List:TStrings);
    //procedure DeleteCountryExchange( TxnLog:ITransactionLog;Value:String);
    procedure ResetStockLevels(TxnLog:ITransactionLog);
    //procedure AddStockItem(TxnLog:ITransactionLog;Description,Group,ProgID:String;PLU:Integer;Price:Currency);
    procedure AddStockItem(TxnLog:ITransactionLog;Description,Group,AccountID,Agency,ReportLine,ProgID:String;PLU:Integer;Price:Currency);
    function  GetStockItemDetails(const Description:WideString):WideString;
    function  GetCancelLines( List:TDomainCombo; UserName, DateTran : String): Boolean;
    function  GetCancelDetails( ListDest, ListOrg :TDomainCombo; UserName, LineTran:String  ) : Boolean;
    procedure MutualAction(Name : String; MutualProducts : String; MutualAction : TMutualActionType );
    function  CalcMultiGroupStockDenoms(StockLines:TStrings;TotalValue:Currency; Multiple:Integer;GrpStk:string):String;
    function  TotalStockSelected( StrList : String ): real;
  public
    CurrentTxnTotal:Currency;
    CombineList:TCombineList;
    FQuantity:Integer;
    property UIEventSink:IUIEventSink read FUIEventSink;
    function GetCurrentPeriod : Integer;
    function CalcIDRange(ID:String;Count:Integer):String;
    function CheckRegSum( ID : String ) : boolean ;
    function ChequeIDRange(IDFrom, IDTo :String;Count:Integer):Boolean;
  end;

function ExchangeRateFor(Country : WideString) : Currency;
function LookUp(Column,Value,LookUpName:String;Field:TComponent;var Valid:Boolean):String;
function PickList(PickListName,InputColumn,OutputColumn,Value : String):String;
function TotalStockValue(StockList:TStrings):String;
function SufficientStockLeft(StockList:TStrings;CurrentLine:Integer):Boolean;
function CheckMaskEdits(ProdForm:TForm):Boolean;
function TodaysPeriod:Integer;
function DateTimeToPeriod(DateTime:TDateTime):Integer;
function PeriodToDateStr( Period : integer ): string ;
function PLUToSQL(PLURanges:String):String;
function StrToPeriod(DateS:String):Integer;
function IsNumber(ID:String):Boolean;
function EncodeName(Code,Value:String):String;
function DecodeName(Code,Value:String):String;
function DayStartingOnMonday(Date:TDateTime): TDateTime;

var
  ReportSort : Boolean;  //whether everyline reports are sorted in TxbRepSection
  ClassIdString: PWideChar;


implementation

uses
  ComServ2;


procedure TBaseProduct.MutualAction(Name : String; MutualProducts : String; MutualAction : TMutualActionType );
//deselectd other optional products when named product is selected
var
  MutualProductsList : TStringObject;
  MutualProductIndex : Integer;
begin
  MutualProductsList := TStringObject.Create(MutualProducts);
  try
    If MutualProductsList.Strings.IndexOf(DelimitedString(Name, '.', True)) > -1 then
    begin
      //process all other products in the exclude group
      For MutualProductIndex := 0 to MutualProductsList.Strings.Count-1 do
      begin
        If 'Product.' + MutualProductsList.Strings[MutualProductIndex] <> Name then
          If maDeSelect in MutualAction then CombineList.ForceDeSelect('Product.' + MutualProductsList.Strings[MutualProductIndex]);
        If maEnable   in MutualAction then CombineList.Enable('Product.' + MutualProductsList.Strings[MutualProductIndex]);
        If maDisable  in MutualAction then CombineList.Disable('Product.' + MutualProductsList.Strings[MutualProductIndex]);
      end;
    end;  //named product is in the exclude group
  finally
    MutualProductsList.Free;
  end;
end;

function TotalStockValue(StockList:TStrings):String;
var
  StockLine:TPackStringList;
  I:Integer;
  Qty:Integer;
  Value:Currency;
  Total:Currency;
begin
  Total:=0;
  StockLine:=TPackStringList.Create;
  for I:=0 to StockList.Count-1 do
  begin
    StockLine.PackText:=StockList[I];
    if StockLine.Count >= 7 then
    begin
      Value := StrToCurrDef(StockLine[4],0);
      //handle zero price items , eg, cheques
      If Value <> 0 then
      begin
        Qty   := StrToIntDef(Replace(StockLine[1],ThousandSeparator,''),0);
        Total := Total+Qty*Value
      end
      else
      begin
        Total := Total + StrToCurrDef(Replace(StockLine[1],ThousandSeparator,''),0);
      end;
    end;
  end;
  StockLine.Free;
  if GetGPCSRegString('','System Name','Tanzania Post') = 'Bermuda Post' then
    Result:='$'+CurrToStrF(Total,ffNumber,2)
  else
    Result:=CurrToStrF(Total,ffNumber,2);
end;

function PickList(PickListName,InputColumn,OutputColumn,Value : String):String;
var
  CompMan:ICompMan;
  PickList:IPickList;
  i : Integer;
begin
  If InputColumn = '' then InputColumn := PickListName;  //default
  If OutputColumn = '' then OutputColumn := 'Zone';  //default
  Result := '';
  CompMan:=CreateCompMan;
  if CompMan <> nil then
  begin
    PickList:=CompMan.LoadComponent('PickList.'+PickListName) as IPickList;
    if PickList <> nil then
    begin
      PickList.CurrentColumn := InputColumn;
      i := 0;
      While (i <= PickList.RowCount-1)
      and (PickList.Item[i] <> Value) do
        Inc(i);

      PickList.CurrentColumn := OutputColumn;
      Result := PickList.Item[i];
    end
    else
    begin
      GPCSErrorLine.RaiseGUIDError('{931ACA3E-A0C4-4A1D-9393-15E512AC2475}','Error Loading PickList.'+PickListName);
      Result:='';
    end;
  end;
end;

function ExchangeRateFor(Country : WideString) : Currency;
var
  ExchangeRateServer : IExchangeRateServer;
begin
  ExchangeRateServer := CreateRemoteExchangeRateServer(GetGPCSRegString('','ServerName',GetLocalMachineName));
  try
    Result:=ExchangeRateServer.RateFor(Country);
  finally
    ExchangeRateServer := nil;
  end;
end;

procedure TBaseProduct.LogStandardTxn(const TxnLog : ITransactionLog; ProdForm : TForm; var Index : Integer; Price : Currency; Description, Additional : String);
var
  Enum : String;
begin
  If FNested and (FUIEventSink <> nil)then
    FQuantity := StrToIntDef(FUIEventSink.ReferenceData('GET(Quantity)'),1);
  If Index = 0 then Enum := Enumerate(ProdForm)
  else Enum := '';
  TxnLog.LogTransaction(Index,FQuantity,Get_PLU,FQuantity * Price,Price,Description,Additional, Get_ProgramID,Enum);
  Inc(Index);
end;

procedure TBaseProduct.UseAdjustStockItem(TxnLog : ITransactionLog; Index : Integer; StockItemDesc : String; Quantity : Integer; Log : Boolean);
//logs stockused, temp adjusts stock level and logs txnline (optional)
//to be used ion CompleteExecute stock products  
var
  Stock               : IStock;
  StringObject        : TStringObject;
begin
  Stock := CreateStock;
  try
    StringObject  := TStringObject.Create(Stock.GetStockItemDetails(StockItemDesc));
    With StringObject do
    begin
      If Log then
      begin
        TxnLog.LogTransaction(Index,
                              Quantity,
                              StrToIntDef(Strings[6],0),           //PLU
                              Quantity*StrToCurrDef(Strings[1],0), //Value
                              StrToCurrDef(Strings[1],0),          //Price
                              Strings[0],                          //Description
                              '',                                  //Additional
                              Strings[7],                          //ProgId
                              '');
      end;  //if logging required
      TxnLog.WriteTransaction('StockUsed',
                              0,                                    //Index
                              Quantity,                             //Quantity
                              StrToIntDef(Strings[6],0),            //PLU
                              Quantity*StrToCurrDef(Strings[1],0),  //Value
                              StrToCurrDef(Strings[1],0),           //Price
                              Strings[0],                           //Description
                              '',                                   //Additional
                              Strings[7],                           //ProgId
                              '');                                  //DomInfo

      Stock.AdjustStockLevel( TxnLog.User,
                              '*' + Strings[0],                 //Description
                              -Quantity);
    end;  //with StringObject
  except
    On E : Exception do
      RaiseGUIDException('{B1371A88-4D61-4938-8090-E20D28E75409}'+Get_Name, E);
  end;
  Stock := nil ;
end;

function EncodeName(Code,Value:String):String;
const
   NumList:String = '725936841';
   LetList:String = 'NOMQPRKGLHIJSXVZTUWYDBEAFCNOMQPRKG';
var
   COfs:Integer;
   I:Integer;
begin
   Value:=UpperCase(Value);
   Result:=Value;
   COfs:=Pos(Code,NumList);
   if COfs > 0 then
   begin
      Result:='';
      for I:=1 to Length(Value) do
      begin
         if Value[I] = ' ' then
            Result:=Result+' '
         else
            Result:=Result+LetList[COfs+(Integer(Value[I])-65)];
      end;
   end;
end;
function DecodeName(Code,Value:String):String;
const
   NumList:String = '725936841';
   LetList:String = 'NOMQPRKGLHIJSXVZTUWYDBEAFCNOMQPRKG';
var
   COfs:Integer;
   CmpStr:String;
   I:Integer;
begin
   Value:=UpperCase(Value);
   Result:=Value;
   COfs:=Pos(Code,NumList);
   if COfs > 0 then
   begin
      CmpStr:=Copy(LetList,COfs,26);
      Result:='';
      for I:=1 to Length(Value) do
      begin
         if Value[I] = ' ' then
            Result:=Result+' '
         else
            Result:=Result+Char(Pos(Value[I],CmpStr)+64);
      end;
   end;
end;
function DayStartingOnMonday(Date:TDateTime):TDateTime;
begin
   if DayOfWeek(Date) = 1 then  // Sunday
      Date := Date - 6
   else
      Date := Date - DayOfWeek(Date) + 2;
   Result := Date ;
end;
function TBaseProduct.GetItemId(DomainEdit : TDomainEdit) : String;
var
  Mask  : String;
begin
  Mask    := SubString(DomainEdit.Validation, 'Mask(', ')');
  Result  := ReferenceData('GETITEMID(' + Mask + ',8)');
end;

function TBaseProduct.Get_Name: WideString;
begin
   try
      Result:=GetResourceString(riName);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_BarCode,E);
   end;
end;
function TBaseProduct.Get_ProjectFiles: WideString;
begin
   try
      Result:=GetResourceString(riProjectFiles);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_BarCode,E);
   end;
end;
function TBaseProduct.Get_GUID: WideString;
begin
   try
      Result:=GetResourceString(riGUID);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_BarCode,E);
   end;
end;
function TBaseProduct.Get_ProgramID: WideString;
begin
   try
      Result:=GetResourceString(riProgramID);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_BarCode,E);
   end;
end;
function TBaseProduct.Get_Version: Integer;
begin
   try
      Result:=StrToIntDef(GetResourceString(riVersion),1);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_Version,E);
   end;
end;
function TBaseProduct.Design(const Password: WideString;const EVSink: IDesignEventSink): WideString;
begin
{   try
      Result:='';
      if EVSink <> nil then
      begin
         Application.Handle:=EVSink.Parent;
         EVSink.Attach(Self);
      end;
      DesForm:=TDesForm.Create(Application);
      DesForm.BaseProd:=Self;
      DesForm.FEVSink:=EVSink;
      DesForm.ProdDes.Add('Bar Code      ',itString  ,GetResourceString(riBarCode     ));
      DesForm.ProdDes.Add('Caption       ',itString  ,GetResourceString(riCaption     ));
      DesForm.ProdDes.Add('Description   ',itString  ,GetResourceString(riDescription ));
      DesForm.ProdDes.Add('End Date      ',itDate    ,GetResourceString(riEndDate     ));
      DesForm.ProdDes.Add('High Days     ',itString  ,GetResourceString(riHighDays    ));
      DesForm.ProdDes.Add('Max. Quantity ',itInteger ,GetResourceString(riMaxQuantity ));
      DesForm.ProdDes.Add('MCR Code      ',itString  ,GetResourceString(riMCRCode     ));
      DesForm.ProdDes.Add('Min. Quantity ',itInteger ,GetResourceString(riMinQuantity ));
      DesForm.ProdDes.Add('OCR Code      ',itString  ,GetResourceString(riOCRCode     ));
      DesForm.ProdDes.Add('Other Code    ',itString  ,GetResourceString(riOtherCode   ));
      DesForm.ProdDes.Add('Picture       ',itBitMap  ,GetResourceString(riBitMap      ));
      DesForm.ProdDes.Add('PLU           ',itInteger ,GetResourceString(riPLU         ));
      DesForm.ProdDes.Add('Regulations   ',itString  ,GetResourceString(riRegulations ));
      DesForm.ProdDes.Add('Start Date    ',itDate    ,GetResourceString(riStartDate   ));
      DesForm.ProdDes.Add('Unit Price    ',itCurrency,GetResourceString(riUnitPrice   ));
      DesForm.ProdDes.Add('Unit Quantity ',itInteger ,GetResourceString(riUnitQuantity));
      DesForm.ProdDes.Add('Use Days      ',itString  ,GetResourceString(riUseDays     ));
      DesForm.ProdDes.Add('Version       ',itInteger ,GetResourceString(riVersion     ));
      DesForm.Show;
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Design,E);
   end;}
end;
procedure TBaseProduct.TerminateDesign;
begin
{   try
      Application.Handle:=0;
      DesForm.FEVSink:=nil;
      DesForm.Free;
      DesForm:=nil;
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_TerminateDesign,E);
   end; }
end;
procedure TBaseProduct.TerminateExecute(const TxnLog: ITransactionLog);
begin
  try
    If SharedData <> nil then
    begin
      SharedData.Free;
      SharedData := nil;
    end;
      CustDisp:=nil;
      if CombineList <> nil then
      begin
         CombineList.ParentSink:=nil;
         CombineList.Free;
      end;
      CombineList:=nil;
      FUIEventSink:=nil;
  except
    on E:Exception do RaiseException(EC_Product_TBaseProduct_TerminateExecute,E);
  end;
end;
function TBaseProduct.Get_BarCode: WideString;
begin
   try
      Result:=GetResourceString(riBarCode);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_BarCode,E);
   end;
end;
function TBaseProduct.Get_Description: WideString;
begin
   try
      Result:=GetResourceString(riDescription);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_Description,E);
   end;
end;
function TBaseProduct.Get_EndDate: WideString;    
begin
   try
      Result:=GetResourceString(riEndDate);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_EndDate,E);
   end;
end;
function TBaseProduct.Get_HighDays: WideString;   
begin
   try
      Result:=GetResourceString(riHighDays);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_HighDays,E);
   end;
end;
function TBaseProduct.Get_MaxQuantity: Integer;   
begin
   try
      Result:=StrToIntDef(GetResourceString(riMaxQuantity),1);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_MaxQuantity,E);
   end;
end;
function TBaseProduct.Get_MCRCode: WideString;    
begin
   try
      Result:=GetResourceString(riMCRCode);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_MCRCode,E);
   end;
end;
function TBaseProduct.Get_MinQuantity: Integer;   
begin
   try
      Result:=StrToIntDef(GetResourceString(riMinQuantity),1);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_MinQuantity,E);
   end;
end;
function TBaseProduct.Get_OCRCode: WideString;    
begin
   try
      Result:=GetResourceString(riOCRCode);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_OCRCode,E);
   end;
end;
function TBaseProduct.Get_OtherCode: WideString;  
begin
   try
      Result:=GetResourceString(riOtherCode);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_OtherCode,E);
   end;
end;
function TBaseProduct.Get_PLU: Integer;           
begin
   try
      Result:=StrToIntDef(GetResourceString(riPLU),1);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_PLU,E);
   end;
end;
function TBaseProduct.Get_Regulations: WideString;
begin
   try
      Result:=GetResourceString(riRegulations);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_Regulations,E);
   end;
end;
function TBaseProduct.Get_StartDate: WideString;  
begin
   try
      Result:=GetResourceString(riStartDate);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_StartDate,E);
   end;
end;
function TBaseProduct.Get_UnitPrice: Currency;    
begin
   try
      Result:=StrToCurr(GetResourceString(riUnitPrice));
   except
      Result:=0;
   end;
end;
function TBaseProduct.Get_UnitQuantity: Integer;  
begin
   try
      Result:=StrToIntDef(GetResourceString(riUnitQuantity),1);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_UnitQuantity,E);
   end;
end;
function TBaseProduct.Get_UseDays: WideString;    
begin
   try
      Result:=GetResourceString(riUseDays);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_UseDays,E);
   end;
end;
function TBaseProduct.Get_BitMap: OleVariant;
begin
   try
      Result:=GetResourceString(riBitMap);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_BitMap,E);
   end;
end;
function TBaseProduct.Get_Caption: WideString;    
begin
   try
      Result:=GetResourceString(riCaption);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_Caption,E);
   end;
end;
function TBaseProduct.Get_Price(ScaleReading: Integer): Currency;
begin
   try
      Result:=Get_UnitPrice;
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_Price,E);
   end;
end;
function TBaseProduct.Get_Count: Integer;
begin
   try
      Result:=StrToIntDef(GetResourceString(riCount),0);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_Count,E);
   end;
end;
function TBaseProduct.Get_Item(Index: Integer): WideString;
begin
   try
      Result:=GetResourceString(riItemBase+Index);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_Item,E);
   end;
end;
function TBaseProduct.Get_PMessage: WideString;
begin
   try
      Result:=GetResourceString(riPMessage);
   except
      on E:Exception do RaiseException(EC_GPCSBase_TGPCSExecComponent_Get_PMessage,E);
   end;
end;
function TBaseProduct.Get_Prompt  : WideString;
begin
   try
      Result:=GetResourceString(riPrompt);
   except
      on E:Exception do RaiseException(EC_GPCSBase_TGPCSExecComponent_Get_Prompt,E);
   end;
end;
function TBaseProduct.Get_Title   : WideString;
begin
   try
      Result:=GetResourceString(riTitle);
   except
      on E:Exception do RaiseException(EC_GPCSBase_TGPCSExecComponent_Get_Title,E);
   end;
end;
function TBaseProduct.Get_AvailableAfterEOD: WordBool;
begin
   try
      Result:=GetResourceString(riAvailAftEOD) <> '0';
   except
      on E:Exception do RaiseGUIDException('{AB1DBC59-9FDA-4A55-BA0A-A026EEEEF2AC}',E);
   end;
end;
function TBaseProduct.Get_MOPs: WideString;
begin
   try
      Result:=GetResourceString(riMOPs);
   except
      on E:Exception do RaiseGUIDException('{98483017-9FDE-4A68-9DAF-CD3D788C0F21}',E);
   end;
end;
function TBaseProduct.Get_Taxes: WideString;
begin
   try
      Result:=GetResourceString(riTaxes);
   except
      on E:Exception do RaiseGUIDException('{5D3EB3C9-166D-4D17-9223-A7869553CB2C}',E);
   end;
end;
procedure TBaseProduct.Execute(Quantity, MaxItems: Integer; NoRedraw: WordBool;
                  const UIEventSink: IUIEventSink;const TxnLog: ITransactionLog;Nested:WordBool);
begin
  if UIEventSink = nil then Exit;
  SharedData:=TSharedData.Create('CorvusReportShare',False);
  FQuantity:=Quantity;
  UIEventSink.Restore;
end;
procedure TBaseProduct.CompleteExecute(var Index:Integer;const TxnLog: ITransactionLog);
begin
   if ThisProgID = '' then
      ComServer.UpdateRegistry(True);
   TxnLog.LogTransaction(Index,FQuantity,Get_PLU,Get_UnitPrice,Get_UnitPrice,Get_Description,'',ThisProgID,'');
end;
procedure TBaseProduct.NotifyChildClick(const Name: WideString; Index: Integer);
begin
   CombineList.Toggle(Name);
end;
procedure TBaseProduct.Complete(const EventSource: IExecComponent);
begin
end;
procedure TBaseProduct.DesignComplete(const EventSource: IExecComponent);
begin
end;
procedure TBaseProduct.SetupButtons(MaxItems,Quantity:Integer;NoRedraw:WordBool;const UIEventSink:IUIEventSink;ProdForm:TForm;Nested:WordBool);
var
   I:Integer;
   CurrentItem:IProduct;
   ProgIDList:TPackStringList;
   CompressedBitmap:Variant;
begin
   TotalField:=nil;
   FUIEventSink:=UIEventSink;
   FNested:=Nested;
   if (FUIEventSink.ReferenceData('UserGroup') = 'UGroup.Supervisor')
   or (FUIEventSink.ReferenceData('UserGroup') = 'UGroup.Admin') then
      FUser:='Supervisor'
   else
      FUser:=FUIEventSink.User;

   if (not Nested) and (UIEventSink = nil) then Exit;
   FQuantity:=Quantity;
   IndentStampLog:=0;
   ProgIDList:=TPackStringList.Create;
   for I:=0 to Get_Count-1 do
   begin
      if Copy(Get_Item(I),1,8) = 'Product.' then
         ProgIDList.Add(IntToHex(I,2)+Get_Item(I));
   end;
   CombineList:=TCombineList.Create(ProgIDList.PackText);
   CombineList.BaseProduct:=Self;
   CombineList.ParentSink:=FUIEventSink;  //self???
   ProgIDList.Free;

   I:=0;
   while (I < MaxItems) and (I < Get_Count) do
   begin
      CurrentItem:=CombineList.InstanceOf(Get_Item(I));
      if CurrentItem <> nil then
      begin
         if not NoRedraw then
         begin
            CompressedBitmap:=CurrentItem.Bitmap;
            FUIEventSink.DisplayItemInfo(Self,I,CompressedBitmap,
                                                CurrentItem.Caption,
                                                CurrentItem.Price[0],1,True,True);
         end;
         Inc(I);
      end
      else
      begin
         if not NoRedraw then
         begin
            if Get_Item(I) = 'Complete' then
               FUIEventSink.DisplayItemInfo(Self,I,'',Get_Item(I),0,0,False,False)
            else
               FUIEventSink.DisplayItemInfo(Self,I,'',Get_Item(I),0,0,True,False);
         end;
         Inc(I);
      end;
   end;
   if not NoRedraw then
   begin
      while (I < MaxItems) do
      begin
         FUIEventSink.DisplayItemInfo(Self,I,'','',0,0,False,False);
         Inc(I);
      end;
   end;
end;
function TBaseProduct.SetUserPassword(OldPass,NewPass:String):Boolean;
var
   NetManager:INetUser;//INetManager;
   Server:String;
begin
   Result:=False;
   //NetManager:=CreateOleObject('Umanager.NetManager') as INetManager;
   NetManager:=CreateOleObject('UserManager.NetUser') as INetUser;
   try
      Server:=NetManager.GetPDC;
      if Server = '' then
         Server:=GetLocalMachineName;
      Result:=NetManager.ChangePassword(Server,FUIEventSink.User,OldPass,NewPass);
   except
      // raise error
   end;
   NetManager:=nil;
end;
function TBaseProduct.ListUsers:String;
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.PackText:=FUIEventSink.ReferenceData('Users');
   Result:=SL.CommaText;
   SL.Free;
end;
function TBaseProduct.FindTotalField(ProdForm:TForm):TDomainEdit;
var
   I:Integer;
begin
   if TotalField = nil then
   begin
      for I:=0 to ProdForm.ComponentCount-1 do
      begin
         if (ProdForm.Components[I] is TDomainEdit) 
         and ((ProdForm.Components[I] as TDomainEdit).AssociatedProgId = 'TotalField') then
         begin
            TotalField:=ProdForm.Components[I] as TDomainEdit;
            Break;
         end;
      end;
   end;
   Result:=TotalField;
end;
function CheckMaskEdits(ProdForm:TForm):Boolean;
var
   I:Integer;
   Field:TDomainEdit;
   DomainCombo : TDomainCombo;
begin
   Result:=True;
   ClearFocus(ProdForm);

   for I:=0 to ProdForm.ComponentCount-1 do
   begin

       //maintain itemindex in domain combos
       if (ProdForm.Components[I] is TDomainCombo) then
       begin
        DomainCombo := ProdForm.Components[I] as TDomainCombo;
        If Trim(DomainCombo.Text) <> '' then
          DomainCombo.ItemIndex := DomainCombo.Items.IndexOf(DomainCombo.Text);
       end;

      if (ProdForm.Components[I] is TDomainEdit) then
      begin
         Field:=ProdForm.Components[I] as TDomainEdit;
         if (Field.Enabled) and (not Field.ValidationComplete) and (not Field.Ignore) and (Copy(Field.Validation,1,4) <> 'None') then
         begin
            MoveFocusTo(Field);
            Result:=False;
            Exit;
         end
      end
      else if ((ProdForm.Components[I] is TDomainCombo) 
           and ((ProdForm.Components[I] as TDomainCombo).Enabled)
           and not ((ProdForm.Components[I] as TDomainCombo).Ignore)
           and ((ProdForm.Components[I] as TDomainCombo).Text = '')) then
      begin
         MoveFocusTo(ProdForm.Components[I]);
         Result:=False;
         Exit;
      end;
   end;
end;
procedure TBaseProduct.SetTotalFieldValue(ProdForm:TForm;Value:Currency);
var
   TotalField:TDomainEdit;
begin
   TotalField:=FindTotalField(ProdForm);
   if TotalField <> nil then
      TotalField.Text:=CurrToStrF(Value,ffNumber,CurrencyDecimals);
end;
function TBaseProduct.SetTotalField(ProdForm:TForm):Currency;
var
   I:Integer;
   Field:TDomainEdit;
   TotalField:TDomainEdit;
begin
   TotalField:=FindTotalField(ProdForm);
   Result:=0;
   if TotalField <> nil then
   begin
      for I:=0 to ProdForm.ComponentCount-1 do
      begin
         if (ProdForm.Components[I] is TDomainEdit) then
         begin
            Field:=(ProdForm.Components[I] as TDomainEdit);
            if Field.UseDefault then
               Result:=Result+StrToCurrDef(Field.Text,0);
         end;
      end;
      TotalField.Text:=CurrToStrF(Result,ffNumber,CurrencyDecimals);
   end;
end;
function TBaseProduct.GetFormData(ProdForm:TForm):String;
var
   TmpTotal:Currency;
   Total:Currency;
begin
   Result:='';
   Try
      Total:=SetTotalField(ProdForm);
      TmpTotal:=0;
      Result:=CombineList.InsertPackText(Enumerate(ProdForm),1,TmpTotal);
//      if TmpTotal <> 0 then
//      begin
         Total:=Total+TmpTotal;
         SetTotalFieldValue(ProdForm,Total);
         TmpTotal:=0;
         Result:=CombineList.InsertPackText(Enumerate(ProdForm),1,TmpTotal);
//      end;
   except
      on E:Exception do RaiseException(EC_Group_TBaseGroup_TerminateExecute+1,E);
   end;
end;
function TBaseProduct.SetFormData(Value:String;ProdForm:TForm):String;
var
  GenericDomain : TGenericDomain;
  DomainPSL   : TPackStringList;
  FormDataPSL : TPackStringList;
  i : Integer;
begin
  Try
    Domain.FirstTime := False;  //do not put default values in domains when setting form data
    if ProdForm <> nil then
    begin
      With ProdForm do
      begin
        Value := CombineList.RemovePackText(Value,1);
        ReFill(Value,ProdForm);
        Result      := GetFormData(ProdForm);
        DomainPSL   := TPackStringList.Create;
        FormDataPSL := TPackStringList.Create;
        GenericDomain := TGenericDomain.Create(nil);
        try
          For i := 0 to ProdForm.ComponentCount-1 do
          begin
            If (Components[i] is TDomainEdit)
            or (Components[i] is TDomainCombo)
            or (Components[i] is TDomainMemo) then
            begin
              GenericDomain.Domain := Components[i];
              DomainPSL.Add(GenericDomain.Name);
              DomainPSL.Add(GenericDomain.Text);
              FormDataPSL.Add(DomainPSL.PackText);
              DomainPSL.Clear;
            end;
          end;
          If SharedData = nil then
            SharedData:=TSharedData.Create('CorvusReportShare',False);
          SharedData.SetVariable('FormData', FormDataPSL.PackText);
        finally
          DomainPSL.Free;
          FormDataPSL.Free;
          GenericDomain.Free;
        end;
      end;  //with ProdForm
    end;
  except
    on E:Exception do RaiseException(EC_Group_TBaseGroup_TerminateExecute+1,E);
  end;
end;
procedure TBaseProduct.TriggerValue(Source: TriggerSource; const Value: WideString);
begin
   case Source of
      tsKeyboard       : TriggerKeyboard     (Value);
      tsBarCode        : TriggerBarCode      (Value);
      tsOCRReader      : TriggerOCRReader    (Value);
      tsMCRReader      : TriggerMCRReader    (Value);
      tsScale          : TriggerScale        (Value);
      tsOtherReader    : TriggerOtherReader  (Value);
      tsStatusDevice0  : TriggerStatusDevice0(Value);
      tsStatusDevice1  : TriggerStatusDevice1(Value);
      tsStatusDevice2  : TriggerStatusDevice2(Value);
      tsStatusDevice3  : TriggerStatusDevice3(Value);
      tsStatusDevice4  : TriggerStatusDevice4(Value);
      tsStatusDevice5  : TriggerStatusDevice5(Value);
      tsStatusDevice6  : TriggerStatusDevice6(Value);
      tsStatusDevice7  : TriggerStatusDevice7(Value);
      tsStatusDevice8  : TriggerStatusDevice8(Value);
      tsStatusDevice9  : TriggerStatusDevice9(Value);
   end;
end;
procedure TBaseProduct.TriggerKeyboard     (Value:String); begin end; 
procedure TBaseProduct.TriggerBarCode      (Value:String); begin end; 
procedure TBaseProduct.TriggerOCRReader    (Value:String); begin end; 
procedure TBaseProduct.TriggerMCRReader    (Value:String); begin end;
procedure TBaseProduct.TriggerScale        (Value:String); begin end; 
procedure TBaseProduct.TriggerOtherReader  (Value:String); begin end; 
procedure TBaseProduct.TriggerStatusDevice0(Value:String); begin end; 
procedure TBaseProduct.TriggerStatusDevice1(Value:String); begin end; 
procedure TBaseProduct.TriggerStatusDevice2(Value:String); begin end; 
procedure TBaseProduct.TriggerStatusDevice3(Value:String); begin end; 
procedure TBaseProduct.TriggerStatusDevice4(Value:String); begin end; 
procedure TBaseProduct.TriggerStatusDevice5(Value:String); begin end; 
procedure TBaseProduct.TriggerStatusDevice6(Value:String); begin end; 
procedure TBaseProduct.TriggerStatusDevice7(Value:String); begin end; 
procedure TBaseProduct.TriggerStatusDevice8(Value:String); begin end; 
procedure TBaseProduct.TriggerStatusDevice9(Value:String); begin end; 

procedure TBaseProduct.DisplayItemInfo(const EventSource: IExecComponent; Index: Integer; BitMap:OleVariant; const Caption: WideString; Price: Currency; State: Integer;Notify,Nested:WordBool);
begin
   if FUIEventSink <> nil then
      FUIEventSink.DisplayItemInfo(EventSource,Index,BitMap,Caption,Price,State,Notify,Nested);
end;
procedure TBaseProduct.Restore; 
begin
   if FUIEventSink <> nil then
      FUIEventSink.Restore; 
end;
procedure TBaseProduct.DisplayInstructions(Style: InstructStyle; const Text:WideString;BitMap:OleVariant); 
begin
   if FUIEventSink <> nil then
      FUIEventSink.DisplayInstructions(Style,Text,BitMap);
end;
procedure TBaseProduct.DataChanged(const EventSource: IExecComponent;const Value: WideString; FlagError: WordBool);
begin
   if FUIEventSink <> nil then
      FUIEventSink.DataChanged(EventSource,Value,FlagError);
end;
function  TBaseProduct.GetComponentReference(const Name: WideString): IDispatch;
begin
   Result:=nil;
   if FUIEventSink <> nil then
      Result:=FUIEventSink.GetComponentReference(Name);
end;
function  TBaseProduct.CurrentDetails:WideString;
begin
   Result:='';
   if FUIEventSink <> nil then
      Result:=FUIEventSink.CurrentDetails;
end;
function  TBaseProduct.Translate(const Value: WideString):WideString; 
begin
   Result:=Value;
   if FUIEventSink <> nil then
      Result:=FUIEventSink.Translate(Value);
end;

function TBaseProduct.EndorseLabels(Number : Integer; Value:Currency;TxnLog:ITransactionLog;CommaText:String;WaitRemoval:Boolean):Boolean;
var
  I : Integer;
begin
  Result := True;
  For i := 1 to Number do
  begin
    Result := EndorseLabel(Value,TxnLog,CommaText,WaitRemoval) ;
    If not result then Exit;
  end;
end;

function  TBaseProduct.EndorseLabel(Value:Currency;TxnLog:ITransactionLog;CommaText:String;WaitRemoval:Boolean):Boolean;
var
   LabelBitmapName:String;
begin
   Result:=True;
   if FUIEventSink <> nil then
   begin
      //check whether a franking label should be printed
      if GetGPCSRegString('DeviceSetup\Receipt','Endorse','1') = '1' then
      begin
        LabelBitmapName:=GetGPCSRegString('','Insert Label Bitmap Name','Insert Bermuda Label');
        FUIEventSink.DisplayInstructions(isBMPRightText,'"Insert the Label into the slip printer, until the green light comes on"',LabelBitmapName);
        Result:=FUIEventSink.Endorse(0,0,0,CommaText);
      end;

      //always write record of franked item
      FQuantity := MaxIntValue([1, FQuantity]);
      if Result then
      begin
        PrLabelGUID := GenerateGUID;  //GUID for matching printed labels with sold labels
        TxnLog.WriteTransaction( '*PrLabel',0,FQuantity,Get_PLU, Value,Value / FQuantity,Get_Description,
                                PrLabelGUID, Get_ProgramID,CommaText);
      end;

      //check whether a franking label should be printed
      if GetGPCSRegString('DeviceSetup\Receipt','Endorse','1') = '1' then
      begin
        if Result and WaitRemoval then
        begin
           FUIEventSink.DisplayInstructions(isBMPRightText,'"Remove the Label from the slip printer"','Remove Receipt');
           FUIEventSink.WaitFor(dsSlipOut);
        end;
        FUIEventSink.DisplayInstructions(isRestore,'','');
      end;
   end;
end;
function  TBaseProduct.Endorse(X,Y,ColCount:Integer;const CommaText:WideString):WordBool; 
begin
   Result:=True;
end;                          
procedure TBaseProduct.WaitFor(DeviceStatus: DeviceStatusType); 
begin
   if FUIEventSink <> nil then
      FUIEventSink.WaitFor(DeviceStatus); 
end;
procedure TBaseProduct.SwapTo(const ProgID, PassData: WideString); 
begin
   if FUIEventSink <> nil then
      FUIEventSink.SwapTo(ProgID,PassData); 
end;
function  TBaseProduct.Get_User:WideString;
begin
   Result:='';
   if FUIEventSink <> nil then
      Result:=FUIEventSink.Get_User;
end;
function  TBaseProduct.Get_Workstation:Integer;
begin
   Result:=0;
   if FUIEventSink <> nil then
      Result:=FUIEventSink.Get_Workstation;
end;
function  TBaseProduct.Get_Office:Integer;
begin
   Result:=0;
   if FUIEventSink <> nil then
      Result:=FUIEventSink.Get_Office;
end;
function  TBaseProduct.ReferenceData(const Name: WideString):WideString;
begin
  Result:='';
  if FUIEventSink <> nil then
    Result:=FUIEventSink.ReferenceData(Name);
end;
function TBaseProduct.CurrentLine: Integer; 
begin
   Result:=0;
   if FUIEventSink <> nil then
      Result:=FUIEventSink.CurrentLine; 
end;
procedure TBaseProduct.Print2x2(const Title,Desc1,Desc2,Office,DataCommatext:WideString);
begin
   if FUIEventSink <> nil then
      FUIEventSink.Print2x2(Title,Desc1,Desc2,Office,DataCommatext);
end;
function  TBaseProduct.Get_HookUp:IHookUp;
begin
   Result:=nil;
   if FUIEventSink <> nil then
      Result:=FUIEventSink.Get_HookUp;
end;
procedure TBaseProduct.TransferTxnsFromDiskette;
begin
   if FUIEventSink <> nil then
      FUIEventSink.TransferTxnsFromDiskette;
end;
procedure TBaseProduct.TransferTxnsToDiskette;
begin
   if FUIEventSink <> nil then
      FUIEventSink.TransferTxnsToDiskette;
end;
procedure TBaseProduct.ProgressBar(const Title:WideString;Min,Max,Pos,Auto:Integer);
begin
   if FUIEventSink <> nil then
      FUIEventSink.ProgressBar(Title,Min,Max,Pos,Auto);
end;
procedure TBaseProduct.OpenCashDrawer;
begin
   if FUIEventSink <> nil then
      FUIEventSink.OpenCashDrawer;
end;
function TBaseProduct.ListTotal(List:TDomainCombo):String;
var
   I:Integer;
   TotalValue:Currency;
   SL:TPackStringList;
begin
   TotalValue:=0;
   SL:=TPackStringList.Create;
   for I:=0 to List.Items.Count-1 do
   begin
      SL.PackText:=List.Items[I];
      if SL.Count > 4 then
         TotalValue:=TotalValue+(StrToIntDef(SL[1],0)*StrToCurrDef(SL[4],0));
   end;
   SL.Free;
   Result:=CurrToStrF(TotalValue,ffNumber,2);
end;
function TodaysPeriod:Integer;
begin
   Result:=Trunc(Date)-DaysUntil_010198;
//   Period:=CreatePeriod;
//   Result:=Period.GetCurrentPeriod(FUIEventSink.User);
//   Period:=nil;
end;

function DateTimeToPeriod(DateTime:TDateTime):Integer;
begin
   Result:=Trunc(DateTime)-DaysUntil_010198;
end;

function PeriodToDateStr( Period : integer ): string ;
var
   PDate:TDateTime;
   Y:Word;
   M:Word;
   D:Word;
begin
   Y := 1998 ;
   M := 1 ;
   D := 1 ;
   PDate:=EncodeDate(Y,M,D)+Period;

   DecodeDate(PDate,Y,M,D);
   result := IntToStr(D div 10)+IntToStr(D mod 10)+'/'
           + IntToStr(M div 10)+IntToStr(M mod 10)+'/'
           + IntToStr(Y);

   //result := DateToStr(PDate) ;
end;

function StrToPeriod(DateS:String):Integer;
var
   PDate:TDateTime;
   Y:Word;
   M:Word;
   D:Word;
begin
   D:=StrToIntDef(Copy(DateS,1,2),14);
   M:=StrToIntDef(Copy(DateS,4,2),2);
   if Length( DateS ) >= 10 then
      Y := StrToIntDef(Copy(DateS,7,4),0)
   else
   begin
      Y:=StrToIntDef(Copy(DateS,7,2),0);
      if Y < 80 then Inc(Y,100);
      Inc(Y,1900);
   end ;
   PDate:=EncodeDate(Y,M,D);
   Result:=Trunc(PDate)-DaysUntil_010198;
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

function TBaseProduct.CheckTransfersAvail(List:TDomainCombo;Owner:String):Boolean;
var
   LSL:TPackStringList;
   FSL:TPackStringList;
   QuerySL:TPackStringList;
   I:Integer;
   TxnLogQuery:String;
   DB:IDatabaseServerAuto;
   FromU,ToU:String;
begin
   LSL:=TPackStringList.Create;
   FSL:=TPackStringList.Create;
   Owner:=UpperCase(Owner);
   TxnLogQuery :=
      //' select Teller, Ident, Sum(Quantity)  from TxnLog'
      ' select Teller, Ident, Sum(Quantity), Period  from TxnLog'
      + ' where RecType = ''StockTx'''
      + ' group by Period, Teller, Ident'
      ;
   QuerySL:=TPackStringList.Create;

   DB:=CoDatabaseServerAuto.CreateRemote(GetGPCSRegString('','Transaction ServerName',GetLocalMachineName));
   DB.DataAlias:='PSL';
   QuerySL.CommaText:=DB.QueryToCommaText(TxnLogQuery);
   DB:=nil;
   for I:=0 to QuerySL.Count-1 do
   begin
      LSL.CommaText:=QuerySL[I];
      if LSL.Count > 1 then
      begin
         if LSL[0] <> Owner then
         begin
            if Copy(LSL[1],1,1) = '<' then
            begin
               FromU:=UpperCase(Copy(LSL[1],2,999));
               if FromU = Owner then
               begin
                  if (StrToIntDef(LSL[2],0) > 0) then // and (FSL.IndexOf('Request From '+LSL[0]) = -1) then
                  begin
                     FSL.Add( PeriodToDateStr(StrToInt(LSL[3])) +'  Request From '+LSL[0] );
                  end ;
               end;
            end
            else
            begin
               ToU:=UpperCase(Copy(LSL[1],2,999));
               if ToU = Owner then
               begin
                  if (StrToIntDef(LSL[2],0) > 0) then //and (FSL.IndexOf('Transfer From '+LSL[0]) = -1) then
                  begin
                     FSL.Add( PeriodToDateStr(StrToInt(LSL[3])) +'  Transfer From '+LSL[0] );
                  end ;
               end;
            end;
         end;
      end;
   end;
   QuerySL.Free;
   List.Clear;
   for I:=0 to FSL.Count-1 do
      List.Items.Add(FSL[I]);
   FSL.Free;
   LSL.Free;
   Result:=List.Items.Count > 0;
end;

function TBaseProduct.GetTransferDetails(List:TDomainCombo;Owner,ReqFrom:String):Boolean;
var
  StockCollection       : TStockCollection;
  StockCollectionIndex  : Integer;
  StockCollectionQty    : Integer;
  SL                    : TPackStringList;
  LSL                   : TPackStringList;
  QuerySL               : TPackStringList;
  RecordSL              : TPackStringList;
  I                     : Integer;
  TxnLogQuery           : String;
  DataBaseServer        : IDatabaseServerAuto;
  PeriodTxn             : integer ;
  LengthDate            : integer ;
  Stock                 : IStock;
begin
  SL   :=  TPackStringList.Create;
  LSL  :=  TPackStringList.Create;
  RecordSL  :=  TPackStringList.Create;

  //Extract the date with the period
  //LengthDate := Length( DateToStr(Date) );
  LengthDate := Length( PeriodToDateStr(1) );

  PeriodTxn := StrToPeriod( Copy( ReqFrom, 1, LengthDate ));
  ReqFrom   := Copy( ReqFrom, LengthDate+3, 999 );

  if Copy(ReqFrom,1,12) = 'Request From' then
  begin
     ReqFrom   :=  Copy(ReqFrom,14,999);
     IdentStr  :=  '<' + Owner;
  end
  else // Copy(ReqFrom,1,13) = 'Transfer From'
  begin
     ReqFrom   :=  Copy(ReqFrom,15,999);
     IdentStr  :=  '>'+Owner;
  end;

  //find all pending stock transfers between the 2 users in the required direction
  TxnLogQuery :=
    ' select Description ,Sum(Quantity),Price, PLU, Prod ,Sum(TxnValue), Ident from TxnLog'
  + ' where RecType = ''StockTx'''
//   + ' and Period >= ' + IntToStr(TodaysPeriod)  // Check !!!!
//   + ' and Period <= ' +  IntToStr(TodaysPeriod)
  + ' and Teller  = '''+ReqFrom+''''
  + ' and Ident   = '''+IdentStr+''''
  + ' and Period  = ' + IntToStr( PeriodTxn )
  + ' group by Description, PLU, Prod, Price, Ident'
  + ' order by PLU' ;

  //get results in string list
  QuerySL         :=  TPackStringList.Create;
  StockCollection := TStockCollection.Create;
  DatabaseServer  :=  CoDatabaseServerAuto.CreateRemote(GetGPCSRegString('','Transaction ServerName',GetLocalMachineName));
  Stock           := CreateStock;
  try
    DatabaseServer.DataAlias       :=  'PSL';
    try
      QuerySL.CommaText  :=  DatabaseServer.QueryToCommaText(TxnLogQuery);
    finally
      DatabaseServer:=nil;
    end;
    StockCollection.CommaText  := Stock.ListAvailableStock(Owner,'!CashAcc');
    //reuse Domain Combo to display transfer details
    List.Clear;
    for I:=0 to QuerySL.Count-1 do
    begin
      SL.Clear;
      LSL.CommaText:=QuerySL[I];  //grab each transfer line (1 stock item)
      //check transfer is in correct direction, to/from correct person, with positive net transfer of this stock item
      if (LSL.Count > 6) and (IdentStr = LSL[6]) and (StrToIntDef(LSL[1],0) > 0) then
      begin

        //build columns for the display
        // 0=Description 1=Quantity 2=Price 3=PLU 4=Prod 5=Value 6=Ident 7=Info

        //get this item's current stock level
        StockCollectionQty := 0;
        For StockCollectionIndex := 0 to StockCollection.Count -1 do
          If StockCollection.Items[StockCollectionIndex].Description = LSL[0] then
          begin
            StockCollectionQty := StockCollection.Items[StockCollectionIndex].Quantity;
            Break;
          end;
        if UpperCase(Copy(LSL[4],1,12)) <> 'PRODUCT.CASH' then
          SL.Add(LSL[0] +' '+CHRTRL+'(' + IntToStr(StockCollectionQty) + ')'+CHRTRL) // 0,Desc (Quantity)
        else
          SL.Add(LSL[0]); // 0,Desc cash denominations unknown
        SL.Add(LSL[1]); // 1,Input Quantity
        SL.Add('0');    // 2,Focused
        SL.Add('1');    // 3,Enabled
        SL.Add(LSL[2]); // 4,Price
        SL.Add(LSL[4]); // 5,ProgID
        SL.Add(LSL[1]); // 6,StockQ
        SL.Add('0');    // 7,Declared
        SL.Add(LSL[3]); // 8,PLU
        SL.Add(LSL[0]); // 9,Original Description
        if UpperCase(Copy(LSL[4],1,12)) = 'PRODUCT.CASH' then
          SL.Add('Cash') // 10,Additional
        else
          SL.Add(''); // 10,Additional
        List.Items.Add(SL.PackText);
      end;
    end;
  finally
    Stock := nil;
    StockCollection.Free;
    QuerySL.Free;
    LSL.Free;
    RecordSL.Free;
    SL.Free;
  end;
  Result:=List.Items.Count > 0;
end;

function TBaseProduct.GetCancelDetails( ListDest, ListOrg:TDomainCombo; UserName, LineTran:String ) : Boolean;
var
   TxnLogQuery  : String;
   DB           : IDatabaseServerAuto;
   QuerySL      : TPackStringList;
   LSL          : TPackStringList;
   SSL          : TPackStringList;
   SL           : TPackStringList;
   I            : Integer;
   Found        : Boolean ;
   RecordId     : Integer ;
   RecordIdNext : Integer ;
   PrevIndex    : Integer ;
   WrkStnNumber : Integer ;
begin

   Found := FALSE ;
   I := 0 ;
   while not Found and ( I <= ListOrg.Items.Count -1 ) do
   begin
      Found := ( LineTran = ListOrg.Items[I] );
      if not Found then
         Inc( I ) ;
   end ;

   RecordId := Integer ( ListOrg.Items.Objects[ I ] ) Div 1000 ;
   WrkStnNumber := Integer ( ListOrg.Items.Objects[ I ] ) mod  1000 ;
   if ( I < ListOrg.Items.Count -1 ) then
      RecordIdNext := Integer ( ListOrg.Items.Objects[ I+1 ] ) Div  1000
   else
      RecordIDNext := 0 ;

   LSL  :=  TPackStringList.Create;
   SSL  :=  TPackStringList.Create;
   SL   :=  TPackStringList.Create;
   QuerySL :=  TPackStringList.Create;

   TxnLogQuery :=
      'select  RecordID, WSNumber, TxnValue, Description, Info, RecIndex  from txnlog      '+
      '   where                                         '+
      '    ( WSNumber='+IntToStr( WrkStnNumber ) +') and '+
      '    ( Description <> ''Cash'' ) and       '+
      '    ( Prod <> ''Product.Cash''  ) and     '+
      '    ( RecType = ''TxnLine'' ) and           '+
      '    ( RecordId >= '+ IntToStr( RecordId )+')'  ;
   if RecordIdNext <> 0 then
     TxnLogQuery := TxnLogQuery +
      ' and ( RecordId < '+ IntToStr( RecordIdNext )+')';

   DB                 :=  CoDatabaseServerAuto.CreateRemote(GetGPCSRegString('','Transaction ServerName',GetLocalMachineName));
   DB.DataAlias       :=  'PSL';
   QuerySL.CommaText  :=  DB.QueryToCommaText(TxnLogQuery);
   DB:=nil;


   Sl.Clear;
   if QuerySL.Count > 0 then
   begin
      I := 0 ;
      PrevIndex := -1 ;
      LSL.CommaText:=QuerySL[ 0 ];  //grab each transfer line (1 stock item)
      while ( I <= QuerySL.Count-1 ) and ( PrevIndex < StrToInt( LSL[5] ) )do
      begin
        SL.Add( QuerySL[ I ] );
        PrevIndex := StrToInt( LSL[5] );
        Inc( I ) ;
        if I <= QuerySL.Count-1 then
           LSL.CommaText:=QuerySL[ I ];  //grab each transfer line
      end ;
   end ;


   ListDest.Clear ;
   if SL.Count > 0 then
   begin
      LSL.CommaText:=SL[0];  //grab each transfer line (1 stock item)
      SSL.Clear;
      SSL.Add( 'Time' ); // 3,Desc
      SSL.Add(Copy( LineTran, 1, 20 )); // 2,Input Value
      SSL.Add('0');   // 2,Focused
      SSL.Add('1');   // 3,Enabled
      SSL.Add('0');   // 4,Price
      SSL.Add('0');   // 5,ProgID
      SSL.Add('0');   // 6,StockQ
      SSL.Add('0');   // 7,Declared
      SSL.Add('0');   // 8,PLU
      SSL.Add('0');   // 9,Original Description
      ListDest.Items.Add( SSL.PackText );
      SSL.Clear;
      SSL.Add( 'Workstation' ); // 3,Desc
      SSL.Add( LSL[ 1 ] ); // 2,Input Value
      SSL.Add('0');   // 2,Focused
      SSL.Add('1');   // 3,Enabled
      SSL.Add('0');   // 4,Price
      SSL.Add('0');   // 5,ProgID
      SSL.Add('0');   // 6,StockQ
      SSL.Add('0');   // 7,Declared
      SSL.Add('0');   // 8,PLU
      SSL.Add('0');   // 9,Original Description
      ListDest.Items.Add( SSL.PackText ); // WSNumber
      SSL.Clear;
      SSL.Add( 'User' ); // 3,Desc
      SSL.Add( UserName ); // 2,Input Value
      SSL.Add('0');   // 2,Focused
      SSL.Add('1');   // 3,Enabled
      SSL.Add('0');   // 4,Price
      SSL.Add('0');   // 5,ProgID
      SSL.Add('0');   // 6,StockQ
      SSL.Add('0');   // 7,Declared
      SSL.Add('0');   // 8,PLU
      SSL.Add('0');   // 9,Original Description
      ListDest.Items.Add( SSL.PackText ); // WSNumber

   end ;

   for I:=0 to SL.Count-1 do
   begin

      SSL.Clear;
      LSL.CommaText:=SL[I];  //grab each transfer line (1 stock item)
      try
         StrToFloat( LSL[4] ); //Check if there is a number in Info
         SSL.Add( LSL[3] ); // 3,Desc
      except
         SSL.Add( LSL[3] +' '+LSL[4]); // 3,Desc
      end ;
      if StrToCurrDef(LSL[2],2) = 0.0 then
         SSL.Add('') // 2,Input Value
      else
         SSL.Add(CurrToStrF(StrToCurrDef(LSL[2],2),ffNumber,2)); // 2,Input Value
      SSL.Add('0');   // 2,Focused
      SSL.Add('1');   // 3,Enabled
      SSL.Add('0');   // 4,Price
      SSL.Add('0');   // 5,ProgID
      SSL.Add('0');   // 6,StockQ
      SSL.Add('0');   // 7,Declared
      SSL.Add('0');   // 8,PLU
      SSL.Add('0');   // 9,Original Description
      ListDest.Items.AddObject(SSL.PackText, TObject ( StrToInt( LSL[0]))); //display with RecordID
   end;

   QuerySL.Free;
   LSL.Free;
   SL.Free;

   result := (ListDest.Items.Count > 0 );
end ;

function TBaseProduct.GetCancelLines( List:TDomainCombo; UserName, DateTran : String): Boolean;
var
   TxnLogQuery  : String;
   DB           : IDatabaseServerAuto;
   QuerySL      : TPackStringList;
   LSL          : TPackStringList;
   LSLW         : TPackStringList;
   I,W          : Integer;
   PeriodStr    : String ;
   Found        : Boolean ;
   Comma2Pos     : integer ;
begin

   LSL  :=  TPackStringList.Create;
   LSLW  :=  TPackStringList.Create;

   QuerySL :=  TPackStringList.Create;

   PeriodStr := IntToStr( StrToPeriod( DateTran ) );
   TxnLogQuery :=
      'select RecordID,WSNumber, DateTime, Description, Info, PLU from txnlog '+
      '   where                                        '+
      '   ( Teller = ''' + UserName + ''' ) and '+
      '   ( Description <> ''Cash'' ) and       '+
      '   ( Prod <> ''Product.Cash''  ) and     '+
      '   ( RecType = ''TxnLine'' ) and         '+
      '   ( RecIndex = 0 ) and                  '+
      '   ( Period = '+ PeriodStr+' )           ';


   DB                 :=  CoDatabaseServerAuto.CreateRemote(GetGPCSRegString('','Transaction ServerName',GetLocalMachineName));
   DB.DataAlias       :=  'PSL';
   QuerySL.CommaText  :=  DB.QueryToCommaText(TxnLogQuery);
   DB:=nil;

   //SL.Clear;
   List.Clear ;
   for I:=0 to QuerySL.Count-1 do
   begin

      LSL.CommaText:=QuerySL[I];
      if ( Copy( LSL[4],1 , 11 ) <> K_CANCELATION_STR ) then
      begin
         W := 1 ;
         Found := FALSE ;
         while ( W <= QuerySL.Count -1 ) and not Found do
         begin

            LSLW.CommaText := QuerySL[W] ;
            if Copy( LSLW[4],1 , 11 ) = K_CANCELATION_STR then
            begin

               try
                  Comma2Pos := Pos(',', Copy( LSLW[4], 13, Length( LSLW[4] )-13 ) )+12;
                  Found := ( LSL[0] = Copy( LSLW[4], 13, Comma2Pos - 13 ) ) and // REcordID
                           ( LSL[1] = Copy( LSLW[4], Comma2Pos+1 , Length( LSLW[4] )-Comma2Pos ) )  ;                   // WorkStation
               except
               end ;

            end ;
            Inc( W );
         end ;

         if not Found then
            List.Items.AddObject( LSL[2] + '   '+ LSL[3], TObject( StrToInt( LSL[0] )*1000+StrToInt(LSL[1]) ));

      end ;

   end ;

   QuerySL.Free;
   LSL.Free;
   LSLW.Free;
   //SL.Free;

   result := ( List.Items.Count > 0 ) ;
end ;

procedure TBaseProduct.CancelDailyTransfer( ListOrg: TdomainCombo; Owner,DateTran :String;const TxnLog: ITransactionLog);

var

   LSL          : TPackStringList;
   SL           : TPackStringList;
   QuerySL      : TPackStringList;
   I            : Integer;
   TxnLogQuery  : String;
   DB           : IDatabaseServerAuto;

   UserGroup:String;
   ReportLines :TPackStringList;
   OnReceiptPrinter:Boolean;

   Found         : boolean ;
   RecordId     : Integer ;
   RecordIdNext : Integer ;
   PeriodStr    : String ;
   Desc         : String ;
   WrkStnNumber : Integer ;
begin

   LSL:=TPackStringList.Create;
   SL:=TPackStringList.Create;
   ReportLines:=TPackStringList.Create;
   QuerySL:=TPackStringList.Create;
   PeriodStr := IntToStr( StrToPeriod( DateTran ) );


   Found := FALSE ;
   I := 0 ;
   while not Found and ( I <= ListOrg.Items.Count -1 ) do
   begin
      Found := ( ListOrg.Text = ListOrg.Items[I] );
      if not Found then
         Inc( I ) ;
   end ;

   RecordId := Integer ( ListOrg.Items.Objects[ I ] ) Div 1000 ;
   WrkStnNumber := Integer ( ListOrg.Items.Objects[ I ] ) Mod 1000 ;
   if ( I < ListOrg.Items.Count -1 ) then
      RecordIdNext := Integer ( ListOrg.Items.Objects[ I+1 ] ) Div  1000
   else
      RecordIDNext := 0 ;

   TxnLogQuery :=
      'select  RecordID, WSNumber, DateTime, RecType,Period, RecIndex, Office, Teller, '+
      '        PLU, Prod, Price, Quantity, TxnValue, Description, Info, Ident,'+
      '        DomInfo   from txnlog '+
      '   where                                          '+
      '    ( WSNumber='+IntToStr( WrkStnNumber ) +') and '+
      '    ( Teller = ''' + Owner +''') and              '+
      '    ( Period = '+ PeriodStr+' )  and              '+
      '    ( ( RecType = ''TxnLine'' ) or ( RecType = ''TxnTotal'' ) )  and'+
      '    ( RecordId >= '+ IntToStr( RecordId )+')'  ;
      if RecordIdNext <> 0 then
      TxnLogQuery := TxnLogQuery +
      ' and ( RecordId < '+ IntToStr( RecordIdNext )+')';

   DB                 :=  CoDatabaseServerAuto.CreateRemote(GetGPCSRegString('','Transaction ServerName',GetLocalMachineName));
   DB.DataAlias       :=  'PSL';
   QuerySL.CommaText  :=  DB.QueryToCommaText(TxnLogQuery);
   DB:=nil;


   try

      Sl.Clear;

      if QuerySL.Count > 0 then
      begin
         I := 0 ;
         Found := FALSE ;
         LSL.CommaText:=QuerySL[ 0 ];  //grab each transfer line (1 stock item)
         while ( I <= QuerySL.Count-1 ) and not found do
         begin
           SL.Add( QuerySL[ I ] );
           LSL.CommaText:=QuerySL[ I ];  //grab each transfer line (1 stock item)
           Found := ( LSL[3] = 'TxnTotal' ) ;
           Inc( I ) ;
         end ;
      end ;

      ReportLines.Add('"Cancel Transaction","",""');
      ReportLines.Add('"From","< User : '+Owner+'",""');
      ReportLines.Add('"    ","< Date : '+DateTran+'",""');

      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');


      for I:=0 to SL.Count-1 do
      begin
         LSL.CommaText:=SL[I];  //grab each transfer line (1 stock item)
         //check transfer is in correct direction, to/from correct person, with positive net transfer of this stock item

         //build columns for the display
         // 0=RecordID, 1=WSNumber, 2=DateTime, 3=RecType, 4=Period,    5=RecIndex,  6=Office,
         // 7=Teller,   8=PLU,      9=Prod,     10=Price,  11=Quantity, 12=TxnValue, 13=Description,
         // 14=Info,   15=Ident,   16=DomInfo


           TxnLog.WriteFullTransaction(
                                       FUIEventSink.Workstation, // WStation
                                       StrToInt(LSL[4]),    // Period
                                       StrToInt(LSL[5]),    // Index
                                       FUIEventSink.Office, // Office
                                       LSL[3],              // Txntype
                                       LSL[7],              // Teller
                                      -StrToInt(LSL[11]),   // Quantity
                                       StrToInt(LSL[8]),    // PLU
                                      -StrToFloat(LSL[12]), // Value
                                       StrToFloat(LSL[10]), // Price
                                       LSL[13],             // Description
                                       K_CANCELATION_STR + ','+LSL[0]+','+LSL[1], // Info, RecordId+WSNumber
                                       LSL[9],              // ProgID,
                                       LSL[15],             // Ident,
                                       FUIEventSink.User //LSL[16]              // DomInfo
                                       );

         if LSL[3] = 'TxnTotal' then
         begin
            ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
            Desc := 'Total' ;
            ReportLines.Add('"","<'+Desc+'","'+CurrToStrF(0-StrToFloat(LSL[12]),ffNumber,2)+'"');
         end
         else
         begin
            try
               StrToFloat( LSL[14] ); //Check if there is a number in Info
               Desc := LSL[13]; // 3,Desc
            except
               Desc := LSL[13] +' '+LSL[14]; // 3,Desc
            end ;
            if ( StrToFloat(LSL[12]) <> 0 ) then
               ReportLines.Add('">'+LSL[11]+'","<'+Desc+'","'+CurrToStrF(0-StrToFloat(LSL[12]),ffNumber,2)+'"')
            else
               ReportLines.Add('" ","<'+Desc+'"," "');

         end;


      end ;

      try
         OnReceiptPrinter:=True;
         UserGroup:=FUIEventSink.ReferenceData('UserGroup');
         if Pos(UserGroup,'UGroup.Supervisor, UGroup.Admin') > 0 then
            OnReceiptPrinter:=False;
         if GetGPCSRegString('','System Name','Tanzania Post') = 'Tanzania Post' then
            OnReceiptPrinter:=True;
      except
         OnReceiptPrinter:=True;
      end;

      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
      ReportLines.Add('"","<Transaction Cancelled."," "');
      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
      ReportLines.Add('"Signature "," "," "');
      ReportLines.Add('" "," "," "');
      ReportLines.Add('" "," "," "');
      ReportLines.Add('" "," "," "');
      ReportLines.Add('" "," "," "');
      ReportLines.Add('" "," "," "');
      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');

      //   if not OnReceiptPrinter then Print2x2Report(ReportLines) else PrintReport(ReportLines);
      if not OnReceiptPrinter then
         PrintReportStandard('1900','400,900,500',ReportLines.CommaText)
      else
         PrintReportReceipt('42','5,25,10',ReportLines.CommaText);

   except
      On E : Exception do RaiseGUIDException('{F83BA1C4-B120-4271-8D64-637858D1728B}', E);  // Cancel Transfer
   end ;

   ReportLines.Free;
   QuerySL.Free;
   LSL.Free;
   SL.Free;


end;


procedure TBaseProduct.SetExchangeRates(TxnLog:ITransactionLog;List:TDomainCombo);
var
   SL:TPackStringList;
   I:Integer;
begin
   SL:=TPackStringList.Create;
   for I:=0 to List.Items.Count-1 do
   begin
      SL.PackText:=List.Items[I];
      SetExchangeRate(Txnlog,SL[0],SL[1]);
   end;
   SL.Free;
end;
procedure TBaseProduct.SetExchangeRate(TxnLog:ITransactionLog; Key,Value:String);
begin
   SetGPCSRegString('ExchangeRates',Key,Value);
   if TxnLog <> nil then
      TxnLog.WriteTransaction( '*Exchange',0,0,0,0,0,Key,Value,'','');
end;
function TBaseProduct.GetExchangeRates(List:TDomainCombo):Boolean;
var
   SL:TPackStringList;
   SSL:TPackStringList;
   I:Integer;
   Rate:String;
begin
   Result:=True;
   SL:=TPackStringList.Create;
   SSL:=TPackStringList.Create;
   List.AssociatedProgId:='ExchangeRates';
   SL.CommaText:=GetGPCSRegNames('ExchangeRates','');
   for I:=0 to SL.Count-1 do
   begin
      SSL.Clear;
      Rate:=GetGPCSRegString('ExchangeRates',SL[I],'1');
      SSL.Add(SL[I]); // 0,Desc
      SSL.Add(Rate); // 1,Input Quantity
      SSL.Add('0'); // 2,Focused
      SSL.Add('1'); // 3,Enabled
      SSL.Add('0'); // 4,Price
      SSL.Add('0'); // 5,ProgID
      SSL.Add('999999999'); // 6,StockQ
      SSL.Add('0'); // 7,Declared
      SSL.Add('0'); // 8,PLU
      SSL.Add(SL[I]); // 9,Original Description
      List.Items.Add(SSL.PackText);
   end;
   List.EMaskValue:='Currency(0,9999999)';
   SSL.Free;
   SL.Free;
end;

function TBaseProduct.GetCurrentPeriod : Integer;
var
  Period : IPeriod;
begin
  Result := -1;
  Period := CreatePeriod;
  if Period <> nil then
  begin
    try
      Result :=Period.GetCurrentPeriod(FUIEventSink.User);
    finally
      Period := nil ;
    end;
  end;
end;

function TBaseProduct.GetAvailableStock(List:TDomainCombo;Owner,StockType:String):Boolean;
var
   LSL              : TPackStringList;
   SSL              : TPackStringList;
   FSL              : TPackStringList;
   QuerySL          : TPackStringList;
   StockListSL      : TPackStringList;  // StockList returned by StockGroups[CurrentGroup]
   StockGroups      : TPackStringList;  // List of StockGroups for multi group StockList.  eg "Stamps","PostalOrd","Retail"
   FullList         : TStringList;      // Total Availailable Stock for all StockGroups (Returned List)
   CurrentGroup,                        // Counter for StockGroups
   I,J              : Integer;
   Stock            : IStock;
   SOverride        : String;
   TxnLogQuery      : String;
   DB               : IDatabaseServerAuto;
   Price            : Currency;
   CashTotal        : Currency;
   ToUser           : String;
   CurrentPeriod    : Integer;

   //query build blocks
   SelectClause : String;
   WhereClause  : String;
   GroupByClause: String;
   NumberDecimals:Integer;
   DivBy100      :Boolean ;
begin
   // In case I have to div by 100 the quantity to display
   if LeftOf(StockType,'DivBy100:') then
   begin
      StockType := Copy( StockType, 10, Length( StockType )-9);
      DivBy100:=True;
   end
   else
      DivBy100:=False;

   NumberDecimals:=StrToIntDef(GetGPCSRegString('','Number Decimals','0'),0);
   if StockType = 'ExchangeRates' then
   begin
      Result:=GetExchangeRates(List);
      Exit;
   end;
   ToUser:='';
   StockGroups:=TPackStringList.Create;
   //Extract requirements from StockType
   with TStringList.Create do
   begin
      try
        CommaText:=StockType; //StockType, eg, "Stamps" or "Stamps, View, Fred"
        StockGroups.CommaText:=Strings[0];
        if Count > 1 then
        begin
          SOverride := Strings[1];                //grab operation if specified
          if Count > 2 then ToUser := Strings[2]; //grab ToUser if specified
        end
        else
          SOverride := Owner;
      finally
        Free;
      end; //try
   end; // with
   FullList:=TStringList.Create;
   StockListSL:=TPackStringList.Create;
   LSL:=TPackStringList.Create; //query line returned
   SSL:=TPackStringList.Create; //display list columns
   FSL:=TPackStringList.Create;
   for CurrentGroup:=0 to StockGroups.Count-1 do  // loop for multi stock groups
   begin
     //clear the (screen) list - used to store each group before adding to FullList
      List.Clear;
      try
         Stock:=CreateStock;
         if (SOverride = 'Declare') or (SOverride = 'Remove') or (SOverride = 'Return')  or (SOverride = 'Receive') or (SOverride = 'Add') or (SOverride = 'Void') or (SOverride = 'Set') or (SOverride = 'Transfer') then
            StockListSL.CommaText:=Stock.ListAllStock(Owner,StockGroups[CurrentGroup])
         else
            StockListSL.CommaText:=Stock.ListAvailableStock(Owner,StockGroups[CurrentGroup]);
         Stock:=nil;
      except
         On E : Exception do RaiseGUIDException('{6B20DAA1-8D50-11D4-AA28-00107A1589F5}', E);  // Error in Stock
      end;

      CurrentPeriod := GetCurrentPeriod;
      //Cash on hand
      if (Currentgroup = 0) //only calculate cash once
      and (SOverride = 'View') and ( ContainsSubString('CashOnHand,All,!CashAcc,', StockGroups[CurrentGroup]+',')) then
      begin
        // transferring cash, adding instead of subtracting
        //Supervisor
        If Owner = 'Supervisor' then
        begin
          TxnLogQuery :=
              ' select Sum(txnvalue) '
            + ' from TxnLog '
            + ' where Period =  ' + IntToStr(CurrentPeriod)
            + ' and Prod = ''Product.Cash'' '
            + ' and RecType in (''TxnLine'', ''StartDay'')   '
            + ' and Teller = ''Supervisor''  '
            + ' union                         '
            + ' select -Sum(txnvalue)         '
            + ' from txnlog '
            + ' where Period = ' + IntToStr(CurrentPeriod)
            + ' and Prod = ''Product.Cash'''
            + ' and Teller <> ''Supervisor'' '
            + ' and RecType in (''StartDay'')  ';
        end
        //individual clerk
        else If (Owner <> 'Supervisor') and (Owner <> 'All') then
        begin
          TxnLogQuery :=
              ' select Sum(TxnValue) from TxnLog'
            + ' where Period = ' + IntToStr(TodaysPeriod)
            + ' and Prod = ''Product.Cash'''
            + ' and RecType in (''TxnLine'', ''StartDay'')'
            + ' and Teller = ''' + Owner + '''';
        end
        //All users chosen
        else
        begin
          TxnLogQuery :=
              ' select Sum(TxnValue) from TxnLog'
            + ' where Period = ' + IntToStr(TodaysPeriod)
            + ' and Prod = ''Product.Cash'''
            + ' and ((Teller =  ''Supervisor'' and RecType in (''TxnLine'', ''StartDay''))' //supervisor transfers
            + '       or'
            + '      (Teller <> ''Supervisor'' and RecType in (''TxnLine'')))';             //+ clerk txns
        end;

        //Total Cash
        QuerySL:=TPackStringList.Create;
        try
           QuerySL.PackText := QueryToPackText(TxnLogQuery);
           CashTotal := 0;
           While QuerySL.Count > 0 do
           begin
             LSL.PackText := QuerySL[0];
             if LSL.Count > 0 then
               CashTotal := CashTotal + StrToCurrDef(LSL[0],0);
             QuerySL.Delete(0);
           end;

           SSL.Clear;
           SSL.Add('Cash On Hand'); // 0,Desc
           SSL.Add(CurrToStrF(CashTotal,ffNumber,NumberDecimals)); // 1,Input Quantity
           SSL.Add('0');   // 2,Focused
           SSL.Add('1');   // 3,Enabled
           SSL.Add('0');   // 4,Price
           SSL.Add('0');   // 5,ProgID
           SSL.Add('0');   // 6,StockQ
           SSL.Add('0');   // 7,Declared
           SSL.Add('0');   // 8,PLU
           SSL.Add('0');   // 9,Original Description
           List.Items.Insert(0,SSL.PackText);
        finally
          QuerySL.Free;
        end;
      end; //cash on hand
      Result :=  List.Items.Count > 0; //cash always found
      If (StockGroups.Count = 1) and (StockListSL.CommaText = '') then Exit; //no stock details retrieved

      // LSL            :=  TPackStringList.Create;
      // SSL            :=  TPackStringList.Create;
      // FSL            :=  TPackStringList.Create;

      //declare and transfer functions
      if (SOverride = 'Declare') or (SOverride = 'Transfer') then
      begin
         CurrentPeriod := GetCurrentPeriod;
         //set standard clauses
         SelectClause    :=    ' select Description,Sum(Quantity),Sum(Price), PLU, Prod ,Sum(TxnValue)  from TxnLog';
         WhereClause     :=    ' and Teller = ''' + Owner + ''''
                             + ' and Period >= ' + IntToStr(CurrentPeriod)
                             + ' and Period <= ' +  IntToStr(CurrentPeriod);
         GroupByClause   :=  ' group by Description, PLU, Prod'
                           + ' order by PLU';

         if (SOverride = 'Declare') then //declaration of stock on hand for the Owner
            TxnLogQuery := SelectClause + ' where RecType = ''StockDec''' + WhereClause + GroupByClause
         else if (SOverride = 'Transfer') and (ToUser = '') then //all transfers from Owner to unamed (ie Common Supervisor)
            TxnLogQuery := SelectClause + ' where RecType = ''StockTx''' + WhereClause + GroupByClause
         else if (SOverride = 'Transfer') and (ToUser <> '') then //all transfers from Owner to named user
            TxnLogQuery := SelectClause + ' where RecType = ''StockTx''' + WhereClause + ' and Ident = '''+ToUser+'''' + GroupByClause;

         //get required stock details in list
         QuerySL:=TPackStringList.Create;
         DB:=CoDatabaseServerAuto.CreateRemote(GetGPCSRegString('','Transaction ServerName',GetLocalMachineName));
         try
           DB.DataAlias:='PSL';
           QuerySL.CommaText:=DB.QueryToCommaText(TxnLogQuery);
         finally
           DB:=nil;
         end;

         //build list of stock 'prod's returned by query
         for I:=0 to QuerySL.Count-1 do // get list of declared ProgID's from Query (ProgIDs!!!???)
         begin
            LSL.CommaText:=QuerySL[I];
            if LSL.Count > 4 then
               //SSL.Add(LSL[4])
               SSL.Add(LSL[0])
            else
               SSL.Add('');

            if DivBy100 then
            begin
               LSL[1]:=CurrToStr(StrToCurrDef(LSL[1],0)/100);
               QuerySL[I]:=LSL.CommaText;
            end;

         end;

         //build list of all stock 'prod's
         for I:=0 to StockListSL.Count-1 do // get list of available ProgID's from Stock List
         begin
            LSL.CommaText:=StockListSL[I];
            if LSL.Count > 4 then
               // FSL.Add(LSL[4])
               FSL.Add(LSL[0]) // 4 ProgID, 0 Description
            else
               FSL.Add('');

            if DivBy100 then
            begin
               LSL[1]:=CurrToStr(StrToCurrDef(LSL[1],0)/100);
               StockListSL[I]:=LSL.CommaText;
            end ;

         end;

         //for each stock item in the required list get the stock level
         for I:=0 to StockListSL.Count-1 do   // get list of available ProgID's from Stock List
         begin
            J:=SSL.IndexOf(FSL[I]);  //search for each stock item in the returned list
            if J >= 0 then           //stock item found
            begin
               LSL.CommaText:=StockListSL[I]; //get stock item details from current stock list
               if LSL.Count > 4 then //stock details complete
               begin
                  if StrToCurrDef(LSL[2],0) > 0 then //priced stock item
                  begin
                     LSL.CommaText:=QuerySL[J];      //get stock item details from returned list
                     if LSL.Count > 1 then           //stock item details exist
                        StockListSL[I]:=StockListSL[I]+',"'+LSL[1]+'"' //stock item quantity
                     else
                        StockListSL[I]:=StockListSL[I]+',0';
                  end
                  else                               //zero/-ve priced stock item
                  begin
                     LSL.CommaText:=QuerySL[J];      //get stock item details from returned list
                     if LSL.Count > 5 then           //stock item details complete
                        StockListSL[I]:=StockListSL[I]+',"'+LSL[5]+'"' //stock item value
                     else
                        StockListSL[I]:=StockListSL[I]+',0';
                  end;
               end;  //if stock item details complete
            end  //if stock item found
            else //stock item not found in the returned query list
            begin
               StockListSL[I]:=StockListSL[I]+',0';  //zero
            end;
         end;
         QuerySL.Free;
      end;

      //clear scratch lists
      LSL.Clear;
      FSL.Clear;
      SSL.Clear;

      //update domain combo with override directive
      if SOverride = 'Declare' then
         List.AssociatedProgId:='Declare'
      else if SOverride = 'Set' then
         List.AssociatedProgId:='Set'
      else if SOverride = 'Void' then
         List.AssociatedProgId:='Void'
      else if SOverride = 'Add' then
      begin
         //special case to print report with correct header
         if Get_ProgramID = 'Product.ReceiveStockFromVendors' then
            List.AssociatedProgId:='Add Receive Stock From Vendors'
         else if Get_ProgramID = 'Product.ReceiveStockFromStampController' then
            List.AssociatedProgId:='Add Receive Stock From Stamp Controller'
         else
            List.AssociatedProgId:='Add';
      end
      else if SOverride = 'Receive' then
         List.AssociatedProgId:='Receive'
      else if SOverride = 'Return' then
         List.AssociatedProgId:='Return'
      else if SOverride = 'Remove' then
      begin
         //special cases (to change prompt on screen???)
         if Get_ProgramID = 'Product.ReturnStockToVendors' then
            List.AssociatedProgId:='Remove Returned to Vendors'
         else if Get_ProgramID = 'Product.IssueToPhilatelicAgents' then
            List.AssociatedProgId:='Remove Issued to Philatelic Agents'
         else if Get_ProgramID = 'Product.ReturnStockToStampController' then
            List.AssociatedProgId:='Remove Returned to Stamp Controller'
         else
            List.AssociatedProgId:='Remove Removed for Destruction';
         end
      else
         List.AssociatedProgId:='Log';


      //for each stock item
      for I:=0 to StockListSL.Count-1 do
      begin
         SSL.Clear;
         LSL.CommaText:=StockListSL[I]; //grab stock item details
   //    Stock Data = "0=Desc,1=Qty,2=Price,3=PLU,4=ProgID,5=Declared
         Price:=StrToCurrDef(LSL[2],0);

         //stock declaration
         if SOverride = 'Declare' then
         begin
            if Price = 0 then  //zero priced stock items (no demonination eg cheques)
            begin
               if StockGroups[CurrentGroup] = 'CashAcc' then
               begin
                  SSL.Add(Trim(LSL[0]));
                  List.EMaskValue:='Mask(xxxxxxxxxxxxxx)'; //change mask to limit entry
               end
               else
               begin
                  SSL.Add(LSL[0]+' Value '+LSL[1]); // 0,Desc  //show value ($ hardcoded!!!)
                  List.EMaskValue:='Currency(0,99999999999)'; //change mask to limit entry
               end;
            end
            else               //non-zero priced stock items
               if GetGPCSRegString('','System Name','Tanzania Post') = 'Botswana Post' then
                  SSL.Add(LSL[0]) // 0,Desc
               else
                  SSL.Add(LSL[0]+' '+CHRTRL+'('+LSL[1]+')'+CHRTRL); // 0,Desc //show description and quantity in brackets
         end
         //stock set/return/remove
         else if (SOverride = 'Set') or (SOverride = 'Return') or (SOverride = 'Remove') then
         begin
            if Price = 0 then  //zero priced stock items (no demonination eg cheques)
               List.EMaskValue:='Currency(0,99999999999)'; //change mask to limit entry
            SSL.Add(LSL[0]+' '+CHRTRL+'('+LSL[1]+')'+CHRTRL) // 0,Desc //show description and quantity in brackets
         end
         //stock transfer
         else if (SOverride = 'Transfer') then
         begin
            if Price = 0 then  //zero priced stock items (no demonination eg cheques)
               List.EMaskValue:='Currency(0,99999999999)'; //change mask to limit entry
            SSL.Add(LSL[0]+' '+CHRTRL+'('+LSL[5]+')'+CHRTRL) // 0,Desc  //stock item value in brackets
         end
         else
         begin
            if Price = 0 then  //zero priced stock items (no demonination eg cheques)
               List.EMaskValue:='Currency(0,99999999999)'; //change mask to limit entry
            SSL.Add(LSL[0]); // 0,Desc       //show description only
         end;

         if (SOverride = 'Declare') then
            SSL.Add(LSL[5])    // 1,Input Quantity   //declared value
         else if (SOverride = 'Set') then
            SSL.Add(LSL[1])    // 1,Input Quantity   //quantity
         else if (SOverride = 'View') then
            SSL.Add(LSL[1])    // 1,Input Quantity   //quantity
         else
            SSL.Add('0');    // 1,Input Quantity
         SSL.Add('0');    // 2,Focused
         SSL.Add('1');    // 3,Enabled
         SSL.Add(LSL[2]); // 4,Price
         SSL.Add(LSL[4]); // 5,ProgID
         SSL.Add(LSL[1]); // 6,StockQ
         if (SOverride = 'Declare') then
            SSL.Add(LSL[5])  // 7,Declared
         else if (SOverride = 'Transfer') then
            SSL.Add('0')  // 7,Declared
         else if SOverride = 'Set' then
            SSL.Add(LSL[1])  // 7,Declared
         else
            SSL.Add('0');    // 7,Declared
         SSL.Add(LSL[3]); // 8,PLU
         SSL.Add(LSL[0]); // 9,Original Description

         If  not ((SOverride = 'Void') and (LSL[4] = 'Product.CashStock')) then //customer cannot return cash
           List.Items.Add(SSL.PackText);
      end;  //for each stock items

      //add the returned list
      FullList.AddStrings(List.Items);

      //clearlists before next stock group
      FSL.Clear;
      LSL.Clear;
      SSL.Clear;
      StockListSL.Clear;
   end; // for - each stockgroup
   Result :=  FullList.Count > 0; //cash always found
   List.Items.CommaText:=FullList.CommaText;
   FullList.Free;
   FSL.Free;
   LSL.Free;
   SSL.Free;
   StockListSL.Free;
   StockGroups.Free;
end;

procedure TBaseProduct.CompleteTransfers(FromUser:String;CommingToThisUser:Boolean;StockLines:TStrings;TxnLog:ITransactionLog;PeriodTxn:integer);
var
   StockLine:TPackStringList;
   I,Qty:Integer;
   Value:Currency;
   WriteCount:Integer;
begin
   if TxnLog = nil then Exit;
   StockLine:=TPackStringList.Create;

   WriteCount:=0;
   for I:=0 to StockLines.Count-1 do
   begin
      StockLine.PackText:=StockLines[I];
      Qty:=StrToIntdef(StockLine[1],0);
      if Qty > 0 then
      begin
         if WriteCount = 0 then
            TxnLog.WriteTransaction('*MBlkStart',0,0,0,0,0,'','','','');
         Inc(WriteCount);
         Value:=StrToCurrDef(StockLine[4],0);
         if CommingToThisUser then
            TxnLog.WriteTransaction('*CancelStockTx',0,0-Qty,StrToIntDef(StockLine[8],9000000),
                                      0-Qty*Value,Value,StockLine[9],'*<'+FromUser,StockLine[5],IntToStr(PeriodTxn)+','+IdentStr)
         else
            TxnLog.WriteTransaction('*CancelStockTx',0,0-Qty,StrToIntDef(StockLine[8],9000000),
                                      0-Qty*Value,Value,StockLine[9],'*>'+FromUser,StockLine[5],IntToStr(PeriodTxn)+','+IdentStr);
      end;
   end;
   if WriteCount > 0 then
      TxnLog.WriteTransaction('*MBlkEnd',0,0,0,0,0,'','','','');

   StockLine.Free;
end;

procedure TBaseProduct.ResetStockLevels(TxnLog:ITransactionLog);
var
   DB:IDatabaseServerAuto;
begin
   DB:=CoDatabaseServerAuto.CreateRemote(GetGPCSRegString('','Transaction ServerName',GetLocalMachineName));
   DB.DataAlias:='PSL';
   try
      DB.QueryToCommaText('UPDATE TXNLOG SET RecType = ''OStockTx'' WHERE RecType = ''StockTx''');
   except
   end;
   DB:=nil;

   TxnLog.WriteTransaction('*StockReset',0,0,0,0,0,'','','','');
end;
procedure TBaseProduct.CancelTransfer( TxnLog:ITransactionLog; List:TDomainCombo );
var
   UserGroup:String;
   CommingToMe:Boolean;
   TotalValue: real ;
   ReqFrom:String;
   StockLine, ReportLines :TPackStringList;
   Stock:IStock;
   I,Qty:Integer;
   Value:Currency;
   OnReceiptPrinter:Boolean;
   PeriodTxn:integer;
   LengthDate : integer;
begin

   try
      OnReceiptPrinter:=True;
      UserGroup:=FUIEventSink.ReferenceData('UserGroup');
      If Pos(UserGroup,'UGroup.Supervisor, UGroup.Admin') > 0 then
         OnReceiptPrinter:=False;
      if GetGPCSRegString('','System Name','Tanzania Post') = 'Tanzania Post' then
         OnReceiptPrinter:=True;
   except
      OnReceiptPrinter:=True;
   end;

   ReportLines:=TPackStringList.Create;
   //List.AssociatedProgId:=Copy(List.AssociatedProgId,2,999);
   //LengthDate := Length( DateToStr(Date) );
   LengthDate := Length( PeriodToDateStr(1) );
   PeriodTxn := StrToPeriod( Copy( List.AssociatedProgId, 2, LengthDate ));
   List.AssociatedProgId  := Copy( List.AssociatedProgId, LengthDate+4, 999 );


   if Copy(List.AssociatedProgId,1,12) = 'Request From' then
   begin
      ReqFrom:=Copy(List.AssociatedProgId,14,999);
      CommingToMe:=False;
      ReportLines.Add('"<'+Translate('Cancel Request From')+' ","<'+ReqFrom+'"," "');
   end
   else // Copy(ReqFrom,1,13) = 'Transfer From'
   begin
      ReqFrom:=Copy(List.AssociatedProgId,15,999);
      CommingToMe:=True;
      ReportLines.Add('"<'+Translate('Cancel Transfer From')+' ","<'+ReqFrom+'"," "');
   end;
   ReportLines.Add('"<'+FUIEventSink.User+'","","'+DateTimeToStr(Now)+'"');
   ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
   StockLine:=TPackStringList.Create;
   TotalValue := 0 ;
   Stock:=CreateStock;
   for I:=0 to List.Items.Count-1 do
   begin
     StockLine.PackText:=List.Items[I];
     Qty:=StrToIntdef(StockLine[1],0);
     if Qty > 0 then
     begin

        Value:=StrToCurrDef(StockLine[4],0);
        TotalValue := TotalValue + (Qty*Value) ;

        if not OnReceiptPrinter then
            ReportLines.Add('">'+ IntToStr(Qty) + '","<'+Translate(StockLine[9])+'","'+CurrToStrF(Qty*Value,ffNumber,2)+'"')
        else
            ReportLines.Add('"'+ LeftPad(IntToStr(Qty),5 , ' ')  + '","'+Translate(StockLine[9])+'","'+CurrToStrF(Qty*Value,ffNumber,2)+'"');

      end;
   end;

   CompleteTransfers(ReqFrom,CommingToMe,List.Items,TxnLog,PeriodTxn);
   Stock:=nil;
   ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
   ReportLines.Add('"","<'+Translate('Total')+'","'+CurrToStrF(TotalValue,ffNumber,2)+'"');
   ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
   ReportLines.Add('"","<'+Translate('Stock Transfer Cancelled')+'."," "');
   ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
   ReportLines.Add('"","<'+Translate('From Signature:')+'"," "');
   ReportLines.Add('" "," "," "');
   ReportLines.Add('" "," "," "');
   ReportLines.Add('" "," "," "');
   ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
   ReportLines.Add('" ","<'+Translate('To Signature:')+'"," "');
   ReportLines.Add('" "," "," "');
   ReportLines.Add('" "," "," "');
   ReportLines.Add('" "," "," "');
   ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
//   if not OnReceiptPrinter then Print2x2Report(ReportLines) else PrintReport(ReportLines);
   if not OnReceiptPrinter then
      PrintReportStandard('1900','400,900,500',ReportLines.CommaText)
   else
      PrintReportReceipt('42','5,25,10',ReportLines.CommaText);

   ReportLines.Free;

end ;
function TBaseProduct.TotalStockSelected( StrList : String ): real ;
var
   SL : TStringList ;
   StockLine:TPackStringList;
   I:integer ;
   Total : double ;
begin
   SL:=TStringList.create ;
   StockLine:=TPackStringList.create;
   Total:= 0 ;

   SL.CommaText := StrList ;
   for I:=0 to SL.Count-1 do
   begin
      StockLine.PackText:=SL[I];
      Total:=  Total + StrToCurrDef( StockLine[1], 0 ) * StrTocurrDef( StockLine[4], 0 );

//         SSL.Add('0');// 1,Input Quantity
//         SSL.Add('0');   // 2,Focused
//         SSL.Add('1');   // 3,Enabled
//         SSL.Add('0');   // 4,Price
//         SSL.Add('0');   // 5,ProgID
//         SSL.Add('0');   // 6,StockQ
//         SSL.Add('0');   // 7,Declared
//         SSL.Add('0');   // 8,PLU
//         SSL.Add('0');   // 9,Original Description

   end ;
   result := Total ;
   StockLine.Free;
   SL.Free ;
end ;
procedure TBaseProduct.LogStock(TxnLog:ITransactionLog;List:TDomainCombo);
var
  UserGroup:String;
  StockLine:TPackStringList;
  I,Qty,Index:Integer;
  WriteCount:Integer;
  Value:Currency;
  Stock:IStock;
  ReportLines:TPackStringList;
  NumberOfCopies:Integer;
  ReqFrom, PrintFrom:String;
  CommingToMe:Boolean;
  OnReceiptPrinter:Boolean;
  TotalValue: real;
  PeriodTxn : integer ;
  LengthDate : integer ;
  MulBy100:Boolean ;
begin
   WriteCount:=0;
   if Copy( List.AssociatedProgId, 1, 9 )='MulBy100:' then
   begin
      List.AssociatedProgId := Copy( List.AssociatedProgId,10, Length( List.AssociatedProgId )-9);
      MulBy100:=True;
   end
   else
      MulBy100:=False;

   NumberOfCopies:=1;
   try
      OnReceiptPrinter:=True;
      UserGroup:=FUIEventSink.ReferenceData('UserGroup');
      If Pos(UserGroup,'UGroup.Supervisor, UGroup.Admin') > 0 then
         OnReceiptPrinter:=False;
      if GetGPCSRegString('','System Name','Tanzania Post') = 'Tanzania Post' then
         OnReceiptPrinter:=True;
   except
      OnReceiptPrinter:=True;
   end;
   if List.AssociatedProgId = 'ExchangeRates' then
   begin
      SetExchangeRates(TxnLog,List);
   end
   else if List.AssociatedProgId = 'Declare' then
   begin
      StockLine:=TPackStringList.Create;
      for I:=0 to List.Items.Count-1 do
      begin
         StockLine.PackText:=List.Items[I];
         if StrToCurrDef(StockLine[4],0) > 0 then
         begin
            Qty:=StrToIntDef(StockLine[1],0);
            if MulBy100 then
               Qty:=Qty-Trunc((StrToCurrDef(StockLine[7],0)*100))
            else
               Qty:=Qty-StrToIntDef(StockLine[7],0);
            Value:=StrToCurrDef(StockLine[4],0);
         end
         else
         begin
            Qty:=1;
            Value:=StrToCurrDef(StockLine[1],0);
            if MulBy100 then
               Qty:=Qty-Trunc((StrToCurrDef(StockLine[7],0)*100))
            else
               Value:=Value-StrToCurrDef(StockLine[7],0);
         end;
         if (Qty*Value) <> 0 then
         begin
            if WriteCount = 0 then
               TxnLog.WriteTransaction('*MBlkStart',0,0,0,0,0,'','','','');
            Inc(WriteCount);
            TxnLog.WriteTransaction('*StockDec',0,Qty,StrToIntDef(StockLine[8],9000000),
                                    Qty*Value,Value,StockLine[9],'',StockLine[5],'');
         end;
      end;
      if WriteCount > 0 then
         TxnLog.WriteTransaction('*MBlkStart',0,0,0,0,0,'','','','');

   end
   else if List.AssociatedProgId = 'Set' then
   begin

      StockLine:=TPackStringList.Create;
      if TxnLog <> nil then
      begin
         TxnLog.WriteTransaction('*MBlkStart',0,0,0,0,0,'','','','');
         for I:=0 to List.Items.Count-1 do
         begin
            StockLine.PackText:=List.Items[I];
            if StrToCurrDef(StockLine[4],0) = 0 then // 0 priced product !
            begin
               StockLine[4]:=StockLine[1];
               StockLine[1]:='1';
            end;
            Qty:=StrToIntDef(StockLine[1],0);
            Value:=StrToCurrDef(StockLine[4],0);
            TxnLog.WriteTransaction('*StockSet',0,Qty,StrToIntDef(StockLine[8],9000000),
                                    Qty*Value,Value,StockLine[9],'',StockLine[5],'');
         end;
         TxnLog.WriteTransaction('*MBlkEnd',0,0,0,0,0,'','','','');

         Stock:=CreateStock;
         if Stock <> nil then
         begin
            Stock.TransferStock('BlockUpdateStart','');
            for I:=0 to List.Items.Count-1 do
            begin
               StockLine.PackText:=List.Items[I];
               if StrToCurrDef(StockLine[4],0) = 0 then // 0 priced product !
               begin
                  StockLine[4]:=StockLine[1];
                  StockLine[1]:='1';
               end;
               Qty:=StrToIntDef(StockLine[1],0);
               try
                  Stock.SetStockLevel(TxnLog.User,StockLine[9],Qty);
               except
                  // Error in Stock
               end;
            end;
            Stock.TransferStock('BlockUpdateEnd','');
            Stock:=nil;
         end ;

      end ;
   end
   else if Copy(List.AssociatedProgId,1,3) = 'Add' then
   begin
      ReportLines:=TPackStringList.Create;
      if Length(List.AssociatedProgId) > 3 then
      begin
         ReportLines.Add('"-----------------------------","-----------------------------"');
         ReportLines.Add('"'+Copy(List.AssociatedProgId,4,999)+'"," "');
         ReportLines.Add('" "," "');
         ReportLines.Add('"-----------------------------","-----------------------------"');
         ReportLines.Add('" "," "');
      end;

      StockLine:=TPackStringList.Create;
      if TxnLog <> nil then
      begin
         for I:=0 to List.Items.Count-1 do
         begin
            StockLine.PackText:=List.Items[I];
            if StrToCurrDef(StockLine[4],0) = 0 then // 0 priced product !
            begin
               StockLine[4]:=StockLine[1];
               StockLine[1]:='1';
            end;
            Qty:=StrToIntdef(StockLine[1],0);
            if Qty > 0 then
            begin
               if WriteCount = 0 then
                  TxnLog.WriteTransaction('*MBlkStart',0,0,0,0,0,'','','','');
               Inc(WriteCount);
               if Length(List.AssociatedProgId) > 3 then
                  ReportLines.Add('"'+StockLine[9]+'","'+IntToStr(Qty)+'"');
               Value:=StrToCurrDef(StockLine[4],0);
               TxnLog.WriteTransaction('*StockUsed',0,0-Qty,StrToIntDef(StockLine[8],9000000),
                                    0-Qty*Value,0-Value,StockLine[9],'',StockLine[5],'');
            end;
         end;
         if WriteCount > 0 then
            TxnLog.WriteTransaction('*MBlkEnd',0,0,0,0,0,'','','','');

         Stock:=CreateStock;
         if Stock <> nil then
         begin
            Stock.TransferStock('BlockUpdateStart','');

            for I:=0 to List.Items.Count-1 do
            begin
               StockLine.PackText:=List.Items[I];
               if StrToCurrDef(StockLine[4],0) = 0 then // 0 priced product !
                  StockLine[1]:='1';

               Qty:=StrToIntdef(StockLine[1],0);
               if Qty > 0 then
               begin
                  try
                     Stock.AdjustStockLevel(TxnLog.User,StockLine[9],Qty);
                  except
                     // Error in Stock
                  end;
               end;
            end;
            Stock.TransferStock('BlockUpdateEnd','');
            Stock:=nil;

         end ;

      end;
      if Length(List.AssociatedProgId) > 3 then
      begin
         ReportLines.Add('" "," "');
         ReportLines.Add('"-----------------------------","-----------------------------"');
         ReportLines.Add('"Signature:"," "');
         ReportLines.Add('" "," "');
         ReportLines.Add('" "," "');
         ReportLines.Add('" "," "');
         ReportLines.Add('"-----------------------------","-----------------------------"');

         if not OnReceiptPrinter then
            Print2x2Report(ReportLines)
         else
            PrintReport(ReportLines);
      end;
      ReportLines.Free;
   end
   else if Copy(List.AssociatedProgId,1,6) = 'Remove' then
   begin
      ReportLines:=TPackStringList.Create;
      ReportLines.Add('"-----------------------------","-----------------------------"');
      ReportLines.Add('"'+Copy(List.AssociatedProgId,8,999)+'"," "');
      ReportLines.Add('" "," "');
      ReportLines.Add('"-----------------------------","-----------------------------"');
      ReportLines.Add('" "," "');
      StockLine:=TPackStringList.Create;

      if TxnLog <> nil then
      begin
         for I:=0 to List.Items.Count-1 do
         begin
            StockLine.PackText:=List.Items[I];
            if StrToCurrDef(StockLine[4],0) = 0 then // 0 priced product !
            begin
               StockLine[4]:=StockLine[1];
               StockLine[1]:='1';
            end;
            Qty:=StrToIntdef(StockLine[1],0);
            if Qty > 0 then
            begin
               if WriteCount = 0 then
                  TxnLog.WriteTransaction('*MBlkStart',0,0,0,0,0,'','','','');
               Inc(WriteCount);
               ReportLines.Add('"'+StockLine[9]+'","'+IntToStr(Qty)+'"');
               Value:=StrToCurrDef(StockLine[4],0);
               TxnLog.WriteTransaction('*StockUsed',0,Qty,StrToIntDef(StockLine[8],9000000),
                                    Qty*Value,0-Value,StockLine[9],'',StockLine[5],'');
            end;
         end;
         if WriteCount > 0 then
            TxnLog.WriteTransaction('*MBlkEnd',0,0,0,0,0,'','','','');

         Stock:=CreateStock;
         if Stock <> nil then
         begin
            Stock.TransferStock('BlockUpdateStart','');

            for I:=0 to List.Items.Count-1 do
            begin
               StockLine.PackText:=List.Items[I];
               if StrToCurrDef(StockLine[4],0) = 0 then // 0 priced product !
                  StockLine[1]:='1';
               Qty:=StrToIntdef(StockLine[1],0);
               if Qty > 0 then
               begin
                  try
                     Stock.AdjustStockLevel(TxnLog.User,StockLine[9],0-Qty);
                  except
                     // Error in Stock
                  end;
               end;
            end;
            Stock.TransferStock('BlockUpdateEnd','');
            Stock:=nil;
         end;

      end;

      ReportLines.Add('" "," "');
      ReportLines.Add('"-----------------------------","-----------------------------"');
      ReportLines.Add('"Signature:"," "');
      ReportLines.Add('" "," "');
      ReportLines.Add('" "," "');
      ReportLines.Add('" "," "');
      ReportLines.Add('"-----------------------------","-----------------------------"');
      if not OnReceiptPrinter then Print2x2Report(ReportLines) else PrintReport(ReportLines);
      ReportLines.Free;
   end
   else if LeftOf(List.AssociatedProgId,'Receive') then
   begin
      ReportLines:=TPackStringList.Create;
      If UIEventSink.ReferenceData('GET(REMRECSERIALNUMBER)') <> '' then
        ReportLines.Add('" ","<Receipt No : '+UIEventSink.ReferenceData('GET(REMRECSERIALNUMBER)')+' "," "')
      else
        ReportLines.Add('" "," "," "');
      ReportLines.Add('"<'+FUIEventSink.User+'","<'+Translate('Remittances Received') + Copy(List.AssociatedProgId,8,999) + '","'+DateTimeToStr(Now)+'"');
      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
      ReportLines.Add('" "," "," "');
      TotalValue := 0 ;
      StockLine:=TPackStringList.Create;
      if TxnLog <> nil then
      begin
         for I:=0 to List.Items.Count-1 do
         begin
            StockLine.PackText:=List.Items[I];
            if  (StrToCurrDef(StockLine[4],0) = 0)   // 0 priced product
            and (StrToCurrDef(StockLine[1],0) <> 0) // but value entered
            then
            begin
               StockLine[4]:=StockLine[1];
               StockLine[1]:='1';
            end;
            Qty:=StrToIntdef(StockLine[1],0);
            if Qty > 0 then
            begin
               if WriteCount = 0 then
                  TxnLog.WriteTransaction('*MBlkStart',0,0,0,0,0,'','','','');
               Inc(WriteCount);
               Value:=StrToCurrDef(StockLine[4],0);
               if UpperCase(Copy(StockLine[5],1,12)) = 'PRODUCT.CASH' then StockLine.Add('Cash') else StockLine.Add('');
               begin
                  if StockLine.Count > 10 then
                  begin
                     TotalValue := TotalValue + (Qty*Value) ;
                     ReportLines.Add('">'+ IntToStr(Qty) + '","<'+Translate(StockLine[9])+'","'+CurrToStrF(Qty*Value,ffNumber,2)+'"');
                     TxnLog.WriteTransaction('*TxStkTo',0,0-Qty,StrToIntDef(StockLine[8],9000000),
                                          Qty*Value,Value,StockLine[9],'*' + TxnLog.User,StockLine[5],StockLine[10]);

                     if StockLine[10] = 'Cash' then
                     begin
                        TxnLog.WriteTransaction ('*TxnLine',0,  Qty,0,  Qty*Value,  Value,'Cash Transfer Adjustment',''         ,'Product.Cash','');
                        TxnLog.WriteTransaction ('*TxnTotal',0,  Qty,0,  Qty*Value,  Value,'Cash Transfer Adjustment',''         ,'Product.Cash','');
                     end ;
                     if ReferenceData('GET(RemittanceDest)') <> '' then
                        TxnLog.WriteTransaction(
                           '*RemInfo',                          // Type
                           0,                                    // Index
                           0-Qty,                                // Quantity
                           StrToIntDef(StockLine[8],9000000),    // plu
                           Qty*Value,                            // Value
                           Value,                                // Price
                           StockLine[9],                         // Description
                           ReferenceData('GET(RemittanceDest)'), // Additional
                           StockLine[5],                         // ProgID
                           ''                                    // DomInfo
                        );
                  end
                  else
                     TxnLog.WriteTransaction('*TxStkTo',0,0-Qty,StrToIntDef(StockLine[8],9000000),
                                          Qty*Value,Value,StockLine[9],'*Supervisor',StockLine[5],'');
               end; // if
            end; // if
         end; // for
         if WriteCount > 0 then
            TxnLog.WriteTransaction('*MBlkEnd',0,0,0,0,0,'','','','');


         Stock:=CreateStock;
         if Stock <> nil then
         begin
            Stock.TransferStock('BlockUpdateStart','');

            for I:=0 to List.Items.Count-1 do
            begin
               StockLine.PackText:=List.Items[I];
               if  (StrToCurrDef(StockLine[4],0) = 0)   // 0 priced product
               and (StrToCurrDef(StockLine[1],0) <> 0) // but value entered
               then
               begin
                  StockLine[4]:=StockLine[1];
                  StockLine[1]:='1';
               end;
               Qty:=StrToIntdef(StockLine[1],0);

               if Qty > 0 then
               begin
                  if UpperCase(Copy(StockLine[5],1,12)) = 'PRODUCT.CASH' then StockLine.Add('Cash') else StockLine.Add('');
                  begin
                     try
                        Stock.AdjustStockLevel(TxnLog.User,StockLine[9],Qty);
                     except
                     // Error in Stock
                     end;
                  end; // if
               end; // if
            end; // for
            Stock.TransferStock('BlockUpdateEnd','');
            Stock:=nil;
         end;

      end;//if

      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
      ReportLines.Add('"","<'+Translate('Total')+'","'+CurrToStrF(TotalValue,ffNumber,2)+'"');
      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
      ReportLines.Add('"","<'+Translate('Signature:')+'"," "');
      ReportLines.Add('" "," "," "');
      ReportLines.Add('" "," "," "');
      ReportLines.Add('" "," "," "');
      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');

      if not OnReceiptPrinter then
         PrintReportStandard('1900','400,900,500',ReportLines.CommaText)
      else
         PrintReportReceipt('42','5,25,10',ReportLines.CommaText);
      ReportLines.Free;
   end
   else if Copy(List.AssociatedProgId,1,6) = 'Return' then
   begin
      ReportLines:=TPackStringList.Create;
      If UIEventSink.ReferenceData('GET(REMDISPSERIALNUMBER)') <> '' then
        ReportLines.Add('" ","<Advice No : '+UIEventSink.ReferenceData('GET(REMDISPSERIALNUMBER)')+' "," "')
      else
        ReportLines.Add('" "," "," "');
      ReportLines.Add('"<'+FUIEventSink.User+'","<'+Translate('Remittances Dispatched') + Copy(List.AssociatedProgId,7,999) + '","'+DateTimeToStr(Now)+'"');
      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
      ReportLines.Add('" "," "," "');
      TotalValue := 0 ;
      StockLine:=TPackStringList.Create;

      if TxnLog <> nil then
      begin
         for I:=0 to List.Items.Count-1 do
         begin
            StockLine.PackText:=List.Items[I];
            if (StrToCurrDef(StockLine[4],0) = 0)  // 0 priced product !
            and (StrToCurrDef(StockLine[1],0) <> 0) // but value entered
            then
            begin
               StockLine[4]:=StockLine[1];
               StockLine[1]:='1';
            end;
            Qty:=StrToIntdef(StockLine[1],0);
            if Qty > 0 then
            begin
               if WriteCount = 0 then
                  TxnLog.WriteTransaction('*MBlkStart',0,0,0,0,0,'','','','');
               Inc(WriteCount);
               Value:=StrToCurrDef(StockLine[4],0);
               if UpperCase(Copy(StockLine[5],1,12)) = 'PRODUCT.CASH' then StockLine.Add('Cash') else StockLine.Add('');
               begin
                  if StockLine.Count > 10 then
                  begin
                     TotalValue := TotalValue + (Qty*Value) ;
                     ReportLines.Add('">'+ IntToStr(Qty) + '","<'+Translate(StockLine[9])+'","'+CurrToStrF(Qty*Value,ffNumber,2)+'"');
                     TxnLog.WriteTransaction( '*TxStkFrom',0,Qty,StrToIntDef(StockLine[8],9000000),
                                          Qty*Value,Value,StockLine[9],'*' + TxnLog.User,StockLine[5],StockLine[10]);
                     if StockLine[10] = 'Cash' then
                     begin
                        TxnLog.WriteTransaction ('*TxnLine',0,  0-Qty,0,  0-Qty*Value,  Value,'Cash Transfer Adjustment',''         ,'Product.Cash','');
                        TxnLog.WriteTransaction ('*TxnTotal',0,  0-Qty,0,  0-Qty*Value,  Value,'Cash Transfer Adjustment',''         ,'Product.Cash','');
                     end;
                     if ReferenceData('GET(RemittanceDest)') <> '' then
                        TxnLog.WriteTransaction(
                           '*RemInfo',                          // Type
                           0,                                    // Index
                           Qty,                                // Quantity
                           StrToIntDef(StockLine[8],9000000),    // plu
                           Qty*Value,                            // Value
                           Value,                                // Price
                           StockLine[9],                         // Description
                           ReferenceData('GET(RemittanceDest)'), // Additional
                           StockLine[5],                         // ProgID
                           ''                                    // DomInfo
                        );
                  end
                  else
                    TxnLog.WriteTransaction( '*TxStkFrom',0,Qty,StrToIntDef(StockLine[8],9000000),
                                         Qty*Value,Value,StockLine[9],'*Supervisor',StockLine[5],'');
               end; // if
            end; // if
         end; // for
         if WriteCount > 0 then
            TxnLog.WriteTransaction('*MBlkEnd',0,0,0,0,0,'','','','');

         Stock:=CreateStock;
         if Stock <> nil then
         begin
            Stock.TransferStock('BlockUpdateStart','');
            for I:=0 to List.Items.Count-1 do
            begin
               StockLine.PackText:=List.Items[I];
               if (StrToCurrDef(StockLine[4],0) = 0)  // 0 priced product !
               and (StrToCurrDef(StockLine[1],0) <> 0) // but value entered
               then
               begin
                  StockLine[4]:=StockLine[1];
                  StockLine[1]:='1';
               end;
               Qty:=StrToIntdef(StockLine[1],0);
               if Qty > 0 then
               begin
                  if UpperCase(Copy(StockLine[5],1,12)) = 'PRODUCT.CASH' then StockLine.Add('Cash') else StockLine.Add('');
                  begin
                     try
                        Stock.AdjustStockLevel(TxnLog.User,StockLine[9],0-Qty);
                     except
                        // Error in Stock
                     end;
                  end; // if
               end; // if
            end; // for
            Stock.TransferStock('BlockUpdateEnd','');
            Stock:=nil;
         end ;

      end;

      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
      ReportLines.Add('"","<'+Translate('Total')+'","'+CurrToStrF(TotalValue,ffNumber,2)+'"');
      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
      ReportLines.Add('"","<'+Translate('Signature:')+'"," "');
      ReportLines.Add('" "," "," "');
      ReportLines.Add('" "," "," "');
      ReportLines.Add('" "," "," "');
      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');

      if not OnReceiptPrinter then
         PrintReportStandard('1900','400,900,500',ReportLines.CommaText)
      else
         PrintReportReceipt('42','5,25,10',ReportLines.CommaText);
      ReportLines.Free;
   end
   else if List.AssociatedProgId = 'Log' then
   begin
      StockLine:=TPackStringList.Create;

      if TxnLog <> nil then
      begin
         for I:=0 to List.Items.Count-1 do
         begin
           StockLine.PackText:=List.Items[I];
            if StrToCurrDef(StockLine[4],0) = 0 then // 0 priced product !
            begin
               StockLine[4]:=StockLine[1];
               StockLine[1]:='1';
            end;
           Qty:=StrToIntdef(StockLine[1],0);
           if Qty > 0 then
           begin
               if WriteCount = 0 then
                  TxnLog.WriteTransaction('*MBlkStart',0,0,0,0,0,'','','','');
               Inc(WriteCount);
              Value:=StrToCurrDef(StockLine[4],0);
              if IndentStampLog > 0 then Index:=IndentStampLog else Index:=0;
              TxnLog.LogTransaction(Index,Qty,StrToIntDef(StockLine[8],9000000),
                                    Qty*Value,Value,StockLine[9],'',StockLine[5],'');
              TxnLog.WriteTransaction('StockUsed',0,Qty,StrToIntDef(StockLine[8],9000000),
                                      Qty*Value,Value,StockLine[9],'',StockLine[5],'');
           end;
         end;
         if WriteCount > 0 then
            TxnLog.WriteTransaction('*MBlkEnd',0,0,0,0,0,'','','','');

         Stock:=CreateStock;
         if Stock <> nil then
         begin
            Stock.TransferStock('BlockUpdateStart','');

            for I:=0 to List.Items.Count-1 do
            begin
              StockLine.PackText:=List.Items[I];
               if StrToCurrDef(StockLine[4],0) = 0 then // 0 priced product !
               begin
                  StockLine[4]:=StockLine[1];
                  StockLine[1]:='1';
               end;
              Qty:=StrToIntdef(StockLine[1],0);
              if Qty > 0 then
              begin
                 try
                    Stock.AdjustStockLevel(TxnLog.User,'*'+StockLine[9],0-Qty);
                 except
                    // Error in Stock
                 end;
              end;
            end;
            Stock.TransferStock('BlockUpdateEnd','');
            Stock:=nil;
         end;

      end;

   end
   else if List.AssociatedProgId = 'SupLog' then
   begin
      StockLine:=TPackStringList.Create;
      if TxnLog <> nil then
      begin
         for I:=0 to List.Items.Count-1 do
         begin
           StockLine.PackText:=List.Items[I];
            if StrToCurrDef(StockLine[4],0) = 0 then // 0 priced product !
            begin
               StockLine[4]:=StockLine[1];
               StockLine[1]:='1';
            end;
           Qty:=StrToIntdef(StockLine[1],0);
           if Qty > 0 then
           begin
               if WriteCount = 0 then
                  TxnLog.WriteTransaction('*MBlkStart',0,0,0,0,0,'','','','');
               Inc(WriteCount);
              Value:=StrToCurrDef(StockLine[4],0);
              if IndentStampLog > 0 then Index:=IndentStampLog else Index:=0;
              TxnLog.LogTransaction(Index,Qty,StrToIntDef(StockLine[8],9000000),
                                    Qty*Value,Value,StockLine[9],'',StockLine[5],'');
              TxnLog.WriteTransaction('SupStkUsd',0,Qty,StrToIntDef(StockLine[8],9000000),
                                      Qty*Value,Value,StockLine[9],'',StockLine[5],'');
           end;
         end;
         if WriteCount > 0 then
            TxnLog.WriteTransaction('*MBlkEnd',0,0,0,0,0,'','','','');

         Stock:=CreateStock;
         if Stock <> nil then
         begin
            Stock.TransferStock('BlockUpdateStart','');
            for I:=0 to List.Items.Count-1 do
            begin
              StockLine.PackText:=List.Items[I];
               if StrToCurrDef(StockLine[4],0) = 0 then // 0 priced product !
                  StockLine[1]:='1';
              Qty:=StrToIntdef(StockLine[1],0);
              if Qty > 0 then
                 try
                    Stock.AdjustStockLevel('Supervisor','*'+StockLine[9],0-Qty);
                 except
                    // Error in Stock
                 end;

            end;
            Stock.TransferStock('BlockUpdateEnd','');
            Stock:=nil;
         end;
      end;

   end
   else if List.AssociatedProgId = 'Void' then
   begin
      StockLine:=TPackStringList.Create;

      if TxnLog <> nil then
      begin
         Index:=0;
         for I:=0 to List.Items.Count-1 do
         begin
           StockLine.PackText:=List.Items[I];
            if StrToCurrDef(StockLine[4],0) = 0 then // 0 priced product !
            begin
               StockLine[4]:=StockLine[1];
               StockLine[1]:='1';
            end;
           Qty:=StrToIntdef(StockLine[1],0);
           if Qty > 0 then
           begin
               if WriteCount = 0 then
                  TxnLog.WriteTransaction('*MBlkStart',0,0,0,0,0,'','','','');
               Inc(WriteCount);
              Value:=0-StrToCurrDef(StockLine[4],0);
                       TxnLog.LogTransaction(Index,Qty,StrToIntDef(StockLine[8],9000000)+100000000,
                                    Qty*Value,Value,'Return '+StockLine[9],'',StockLine[5],'');
              TxnLog.WriteTransaction('StockUsed',0,0-Qty,StrToIntDef(StockLine[8],9000000),
                                      Qty*Value,Value,StockLine[9],'',StockLine[5],'');
              try
                 Stock.AdjustStockLevel(TxnLog.User,'*'+StockLine[9],Qty);
              except
                 // Error in Stock
              end;
           end;
         end;
         if WriteCount > 0 then
            TxnLog.WriteTransaction('*MBlkEnd',0,0,0,0,0,'','','','');

         Stock:=CreateStock;
         if Stock <> nil then
         begin
            Stock.TransferStock('BlockUpdateStart','');

            for I:=0 to List.Items.Count-1 do
            begin
              StockLine.PackText:=List.Items[I];
               if StrToCurrDef(StockLine[4],0) = 0 then // 0 priced product !
               begin
                  StockLine[1]:='1';
               end;
              Qty:=StrToIntdef(StockLine[1],0);
              if Qty > 0 then
                 try
                    Stock.AdjustStockLevel(TxnLog.User,'*'+StockLine[9],Qty);
                 except
                    // Error in Stock
                 end;
            end;
            Stock.TransferStock('BlockUpdateEnd','');
            Stock:=nil;
         end;
      end;

   end
   else if List.AssociatedProgId = 'SupVoid' then
   begin
      StockLine:=TPackStringList.Create;

      if TxnLog <> nil then
      begin
         Index:=0;
         for I:=0 to List.Items.Count-1 do
         begin
           StockLine.PackText:=List.Items[I];
            if StrToCurrDef(StockLine[4],0) = 0 then // 0 priced product !
            begin
               StockLine[4]:=StockLine[1];
               StockLine[1]:='1';
            end;
           Qty:=StrToIntdef(StockLine[1],0);
           if Qty > 0 then
           begin
              if WriteCount = 0 then
                 TxnLog.WriteTransaction('*MBlkStart',0,0,0,0,0,'','','','');
              Inc(WriteCount);
              Value:=0-StrToCurrDef(StockLine[4],0);
                       TxnLog.LogTransaction(Index,Qty,StrToIntDef(StockLine[8],9000000)+100000000,
                                    Qty*Value,Value,'Return '+StockLine[9],'',StockLine[5],'');
              TxnLog.WriteTransaction('SupStkUsd',0,0-Qty,StrToIntDef(StockLine[8],9000000),
                                      Qty*Value,Value,StockLine[9],'',StockLine[5],'');
              try
                 Stock.AdjustStockLevel('Supervisor','*'+StockLine[9],Qty);
              except
                 // Error in Stock
              end;
           end;
         end;
         if WriteCount > 0 then
            TxnLog.WriteTransaction('*MBlkEnd',0,0,0,0,0,'','','','');

         Stock:=CreateStock;
         if Stock <> nil then
         begin
            Stock.TransferStock('BlockUpdateStart','');

            for I:=0 to List.Items.Count-1 do
            begin
              StockLine.PackText:=List.Items[I];
               if StrToCurrDef(StockLine[4],0) = 0 then // 0 priced product !
                  StockLine[1]:='1';

              Qty:=StrToIntdef(StockLine[1],0);
              if Qty > 0 then
                 try
                    Stock.AdjustStockLevel('Supervisor','*'+StockLine[9],Qty);
                 except
                    // Error in Stock
                 end;
            end;
            Stock.TransferStock('BlockUpdateEnd','');
            Stock:=nil;
         end;
      end;

   end
   else if Copy(List.AssociatedProgId,1,1) = '*' then
   begin

      //LengthDate := Length( DateToStr(Date) );
      LengthDate := Length( PeriodToDateStr(1) );
      if GetGPCSRegString('','System Name','Tanzania Post') = 'Uganda Post' then
        NumberOfCopies:=2;
      ReportLines:=TPackStringList.Create;

      //List.AssociatedProgId:=Copy(List.AssociatedProgId,2,999);
      PeriodTxn := StrToPeriod( Copy( List.AssociatedProgId, 2, LengthDate ));
      List.AssociatedProgId  := Copy( List.AssociatedProgId, LengthDate+4, 999 );

      if Copy(List.AssociatedProgId,1,12) = 'Request From' then
      begin
         ReqFrom:=Copy(List.AssociatedProgId,14,999);
         if Copy( ReqFrom, 1, 7 )= 'Vendor:' then
         begin
            PrintFrom :=  Copy( ReqFrom, 8, 999 );
            ReqFrom := 'Vendor' ;       // User for the cash account
         end
         else
            PrintFrom := ReqFrom ;

         CommingToMe:=False;
         ReportLines.Add('"<'+Translate('Transfer Stock To')+' ","<'+PrintFrom+'"," "');
      end
      else // Copy(ReqFrom,1,13) = 'Transfer From'
      begin
         ReqFrom:=Copy(List.AssociatedProgId,15,999);
         if Copy( ReqFrom, 1, 7 )= 'Vendor:' then
         begin
            PrintFrom :=  Copy( ReqFrom, 8, 999 );
            ReqFrom := 'Vendor' ;       // User for the cash account
         end
         else
            PrintFrom := ReqFrom ;

         CommingToMe:=True;
         ReportLines.Add('"<'+Translate('Accept Stock From')+' ","<'+PrintFrom+'"," "');
      end;

      ReportLines.Add('"<'+FUIEventSink.User+'","","'+DateTimeToStr(Now)+'"');
      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
      StockLine:=TPackStringList.Create;
      TotalValue := 0 ;

      try
         for I:=0 to List.Items.Count-1 do
         begin
           StockLine.PackText:=List.Items[I];
           Qty:=StrToIntdef(StockLine[1],0);
           if Qty > 0 then
           begin
               if WriteCount = 0 then
                  TxnLog.WriteTransaction('*MBlkStart',0,0,0,0,0,'','','','');
               Inc(WriteCount);
              Value:=StrToCurrDef(StockLine[4],0);

              if CommingToMe then
                 TxnLog.WriteTransaction('*RequestTo',0,Qty,StrToIntDef(StockLine[8],9000000),
                                         Qty*Value,Value,StockLine[9],'*'+ReqFrom,StockLine[5],IntToStr( PeriodTxn ))
              else
                 TxnLog.WriteTransaction('*RequestFrom',0,Qty,StrToIntDef(StockLine[8],9000000),
                                         Qty*Value,Value,StockLine[9],'*'+ReqFrom,StockLine[5],IntToStr( PeriodTxn ));

              TotalValue := TotalValue + (Qty*Value) ;
              if not OnReceiptPrinter then
                  ReportLines.Add('">'+ IntToStr(Qty) + '","<'+Translate(StockLine[9])+'","'+CurrToStrF(Qty*Value,ffNumber,2)+'"')
              else
                  ReportLines.Add('"'+ LeftPad( IntToStr(Qty),5 , ' ' ) + '","'+Translate(StockLine[9])+'","'+CurrToStrF(Qty*Value,ffNumber,2)+'"');

              if (StockLine.Count > 10) and (StockLine[10] = 'Cash') then
              begin
                 if CommingToMe then
                 begin
                    TxnLog.WriteTransaction ('*TxnLine' ,0,  Qty,0,  Qty*Value,  Value,'Cash Transfer Adjustment',''         ,'Product.Cash','');
                    TxnLog.WriteTransaction ('*TxnTotal',0,  Qty,0,  Qty*Value,  Value,'Cash Transfer Adjustment',''         ,'Product.Cash','');
                    TxnLog.WriteTransaction ('*TxnLine' ,0,0-Qty,0,0-Qty*Value,0-Value,'Cash Transfer Adjustment','*'+ReqFrom,'Product.Cash','');
                    TxnLog.WriteTransaction ('*TxnTotal',0,0-Qty,0,0-Qty*Value,0-Value,'Cash Transfer Adjustment','*'+ReqFrom,'Product.Cash','');
                 end
                 else
                 begin
                    TxnLog.WriteTransaction ('*TxnLine' ,0,  Qty,0,  Qty*Value,  Value,'Cash Transfer Adjustment','*'+ReqFrom,'Product.Cash','');
                    TxnLog.WriteTransaction ('*TxnTotal',0,  Qty,0,  Qty*Value,  Value,'Cash Transfer Adjustment','*'+ReqFrom,'Product.Cash','');
                    TxnLog.WriteTransaction ('*TxnLine' ,0,0-Qty,0,0-Qty*Value,0-Value,'Cash Transfer Adjustment',''         ,'Product.Cash','');
                    TxnLog.WriteTransaction ('*TxnTotal',0,0-Qty,0,0-Qty*Value,0-Value,'Cash Transfer Adjustment',''         ,'Product.Cash','');
                 end;
              end;

           end;
         end;
         if WriteCount = 0 then
            TxnLog.WriteTransaction('*MBlkEnd',0,0,0,0,0,'','','','');


         //---------------------------------------------------------------------------

         Stock:=CreateStock;
         if Stock <> nil then
         begin
            Stock.TransferStock('BlockUpdateStart','');

            for I:=0 to List.Items.Count-1 do
            begin
              StockLine.PackText:=List.Items[I];
              Qty:=StrToIntdef(StockLine[1],0);
              if Qty > 0 then
              begin
                 if CommingToMe then
                 begin
                    Stock.AdjustStockLevel(TxnLog.User,StockLine[9],Qty);
                    Stock.AdjustStockLevel(ReqFrom,StockLine[9],0-Qty);
                 end
                 else
                 begin
                    Stock.AdjustStockLevel(TxnLog.User,StockLine[9],0-Qty);
                    Stock.AdjustStockLevel(ReqFrom,StockLine[9],Qty);
                 end;

              end;
            end;

            if Stock <> nil then
               Stock.TransferStock('BlockUpdateEnd','');
            Stock:=nil;

         end;

         if ReqFrom <> 'Vendor' then   // it doesn't need to cancel the stock transfer, because there isn't
            CompleteTransfers(ReqFrom,CommingToMe,List.Items,TxnLog,PeriodTxn);
      except
         on E:Exception do
            RaiseGUIDException('{CB920A11-239C-443C-8CBF-3A57ED93D3A9}',E);
      end;
      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
      ReportLines.Add('"","<'+Translate('Total')+'","'+CurrToStrF(TotalValue,ffNumber,2)+'"');
      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
      ReportLines.Add('"","<'+Translate('Stock Transferred.')+'"," "');
      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
      ReportLines.Add('"","<'+Translate('From Signature:')+'"," "');
      ReportLines.Add('" "," "," "');
      ReportLines.Add('""," "," "');
      ReportLines.Add('" "," "," "');
      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
      ReportLines.Add('"","<'+Translate('To Signature:')+'"," "');
      ReportLines.Add('" "," "," "');
      ReportLines.Add('" "," "," "');
      ReportLines.Add('" "," "," "');
      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');

      for I:=0 to NumberOfCopies-1 do
      begin
         if not OnReceiptPrinter then
            PrintReportStandard('1900','400,900,500',ReportLines.CommaText)
         else
            PrintReportReceipt('42','5,25,10',ReportLines.CommaText);
      end;
      ReportLines.Free;
   end
   else if (Copy(List.AssociatedProgId,1,1) = '>') or (Copy(List.AssociatedProgId,1,1) = '<') then
   begin
      ReportLines:=TPackStringList.create;
      if List.AssociatedProgId[1] = '>' then
         ReportLines.Add('"<Transfer Stock To ","<'+Copy(List.AssociatedProgId,2,999)+'"," "')
      else
         ReportLines.Add('"<Request Stock From ","<'+Copy(List.AssociatedProgId,2,999)+'"," "');
      ReportLines.Add('"<'+FUIEventSink.User+'","","'+DateTimeToStr(Now)+'"');
      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
      StockLine:=TPackStringList.Create;
//      Stock:=CreateStock;
      TotalValue := 0 ;

      try

         for I:=0 to List.Items.Count-1 do
         begin
           StockLine.PackText:=List.Items[I];
           Qty:=StrToIntdef(StockLine[1],0);
           if Qty > 0 then
           begin
               if WriteCount = 0 then
                  TxnLog.WriteTransaction('*MBlkStart',0,0,0,0,0,'','','','');
               Inc(WriteCount);
              Value:=StrToCurrDef(StockLine[4],0);
              //test for zero price items
              If Value = 0 then
              begin
                Value := Qty;  //interpret qty as value
                Qty   := 1;
              end;
              TxnLog.WriteTransaction('*StockTx',0,Qty,StrToIntDef(StockLine[8],9000000),
                                      Qty*Value,Value,StockLine[9],List.AssociatedProgId,StockLine[5],AdditionalInfo);
              //ReportLines.Add('"'+StockLine[9]+'","'+IntToStr(Qty)+'"');
              TotalValue := TotalValue + (Qty*Value) ;

              if not OnReceiptPrinter then
               ReportLines.Add('">'+ IntToStr(Qty) + '","<'+StockLine[9]+'","'+CurrToStrF(Qty*Value,ffNumber,2)+'"')
              else
               ReportLines.Add('"'+ LeftPad( IntToStr(Qty),5 , ' ') + '","'+StockLine[9]+'","'+CurrToStrF(Qty*Value,ffNumber,2)+'"');

           end;
         end;
      finally
         if WriteCount > 0 then
            TxnLog.WriteTransaction('*MBlkEnd',0,0,0,0,0,'','','','');
      end;
      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');
      ReportLines.Add('"","<Total","'+CurrToStrF(TotalValue,ffNumber,2)+'"');
      ReportLines.Add('"--------------------","<----------------------------------------------------------","-----------------------------"');

      if not OnReceiptPrinter then
          PrintReportStandard('1900','400,900,500',ReportLines.CommaText)
      else
         PrintReportReceipt('42','5,25,10',ReportLines.CommaText);

      ReportLines.Free;

   end;
end;


function TBaseProduct.CalcMultiStockDenoms(StockLines:TStrings;TotalValue:Currency; Multiple : Integer):String;
begin
   Result := CalcMultiGroupStockDenoms( StockLines,TotalValue,Multiple,'Stamp');
end ;
function TBaseProduct.CalcMultiGroupStockDenoms(StockLines:TStrings;TotalValue:Currency; Multiple:Integer;GrpStk:string):String;
//StockLines from as TStrings,
//0=Desc,   1=Input Quantity, 2=Focused,  3=Enabled,  4=Price,
//5=ProgID, 6=StockQ,         7=Declared, 8=PLU,      9=Original Description }
var
  MultiIndex : Integer;
  StockLine  : TPackStringList;
  OrderList  : TPackStringList;
  OrderIndex : Integer;
  Qty,I      : Integer;
  Value      : Currency;
  StartAt    : Integer;
  SubStartAt : integer ;
  ValueLeft  : Currency;
//  MinValue   : Currency;
  CurQty     : Integer;
  CurrQtyLst : TPackStringList;
  FirstScope:boolean;
  ExitBackCount:Boolean;
  //TotalQtyAvailable :Currency;
  BestStockLines : TPackStringList;
  BestValueLeft  : currency ;
  TotalAvailable :Currency;
  EnoughStock    :Boolean;
  SatisfyQty     :Boolean ;
  StartTime      : TDateTime;
  TimeOut        : Integer;
begin
  Result:='';
  TimeOut := StrToInt(GetGPCSRegString('System Parameters','Calc Stock Denoms Timeout','20'));
  TotalAvailable := 0 ;
  StockLine :=TPackStringList.Create;
  OrderList :=TPackStringList.Create;
  CurrQtyLst:=TPackStringList.Create;
  BestStockLines:=TPackStringList.Create;

  I:=0;
  if GrpStk <> '' then
  begin
     { 0=Desc,1=Input Quantity,2=Focused,3=Enabled,4=Price,5=ProgID,6=StockQ,7=Declared,8=PLU,9=Original Description }
     while I < StockLines.Count do // reduce each item to the max that would satisfy requirement
     begin
       StockLine.PackText:=StockLines[I];
       try
          //if Copy(StockLine[0],Length(StockLine[0])-4,5) = 'Stamp' then
          if RightOf( StockLine[0],GrpStk )  then
          begin
     //            if StrToIntDef(StockLine[6],0) > (TotalValue / StrToCurrDef(StockLine[4],1)) then
     //               StockLine[6]:=IntToStr(Trunc(TotalValue / StrToCurrDef(StockLine[4],1)));
             StockLines[I]:=StockLine.PackText;
             Inc(I);
          end
          else
          begin
             StockLines.Delete(I);
          end;
       except
          Inc(I);
       end;
     end;
  end;

  //sort into denomination order to avoid selection of low value before high value
  With TStockLine.Create do
  begin
    try
      //prepend formatted price to each stockline
      For i := 0 to StockLines.Count -1 do
      begin
        StockLines.Objects[I] := TObject(I); //store current order in objects
        PackText := StockLines[I];
        StockLines[I] := FormatCurr('0000000000.0000',Price) + '@' + StockLines[I];
      end;
      //sort by assigning to a stringlist (keeps objects intact?!)
      BestStockLines.Assign(StockLines);
      BestStockLines.Sort;
      StockLines.Assign(BestStockLines);
      //remove prepended price
      For i := 0 to StockLines.Count -1 do
        StockLines[I] := DelimitedString(StockLines[I], '@', True);

    finally
      Free; //TStockLine;
    end;
  end;

  //deselect all items
  for I:=0 to StockLines.Count-1 do
  begin
     StockLine.PackText:=StockLines[I];
     StockLine[1]:='0';
     CurrQtyLst.Add( StockLine[6]) ;// Keep the original Current Quantity to put it back into the original list
     StockLines[I]:=StockLine.PackText;
  end;

  //go through all mail items
  BestStockLines.Assign( StockLines );
  EnoughStock := True ;
  SatisfyQty := True ;
  For MultiIndex := 1 to Multiple do
  begin

    StartAt    :=  StockLines.Count-1;  //start at top denomination
    ValueLeft  :=  TotalValue;  //total value for this mail item
    BestValueLeft := ValueLeft;

    SubStartAt := StartAt ;
    FirstScope:=True;
    StartTime := Now;
    while (ValueLeft > 0)
    and (StartAt >= 0)
    and EnoughStock
    and (TimeElapsed(StartTime,Now,teSecond) < TimeOut) do //and (TotalQtyAvailable >= ValueLeft) do
    begin

      //while ( SubStartAt >= StartAt ) and (ValueLeft > 0) do
      while ( SubStartAt >= 0 )
      and (ValueLeft > 0)
      and EnoughStock
      and (TimeElapsed(StartTime,Now,teSecond) < TimeOut) do
      begin
        StockLine.PackText  :=  StockLines[SubStartAt];
        CurQty              :=  StrToIntDef(StockLine[6],0);  //get all available
        Value               :=  StrToCurrDef(StockLine[4],0);
        Qty                 :=  MinIntValue([Trunc(ValueLeft / Value),CurQty]);  //no of these stamps
        TotalAvailable := TotalAvailable + (StrToCurrDef(StockLine[4],0)*StrToIntDef(StockLine[6],0)) ;
        Dec(CurQty, Qty);
        StockLine[1]  :=  IntToStr(Qty + StrToInt(StockLine[1])); //increase no of this denom selected
        StockLine[6]  :=  IntToStr(CurQty);
        StockLines[SubStartAt] :=  StockLine.PackText;
        ValueLeft     :=  ValueLeft-(Qty*Value);

        if (Qty > 0)  and  FirstScope then  // Trying to be faster.
        begin
          StartAt := SubStartAt ;
          FirstScope:=false;
        end ;

        Dec( SubStartAt );
      end;
      Inc( SubStartAt );
      if ValueLeft< BestValueLeft then
      begin
         BestValueLeft := ValueLeft ;
         BestStockLines.Assign( StockLines );
      end ;

      if TotalAvailable < TotalValue then // if there isn't enough then it mush exit
         EnoughStock := False ;

      //check for exact satisfaction
      if (ValueLeft > 0) and SatisfyQty then
      begin

        ExitBackCount := False ;
        while (SubStartAt <= ( StartAt ))
        and not ExitBackCount
        and SatisfyQty
        and (TimeElapsed(StartTime,Now,teSecond)< TimeOut) do
        begin
            StockLine.PackText :=  StockLines[SubStartAt];          //from high denoms
            CurQty             :=  StrToIntDef(StockLine[6],0);  //currently available stock
            Qty                :=  StrToIntDef(StockLine[1],0);  //currently selected qty
            Value              :=  StrToCurrDef(StockLine[4],0); //denom value

            if Qty > 0 then
            begin
               // if is the end, then do all of this denomination
               if SubStartAt = 0 then
               begin
                  ValueLeft   := ValueLeft + (Value*Qty);
                  CurQty := CurQty + Qty;
                  Qty := 0;
               end
               else
               begin
                  ValueLeft   := ValueLeft + (Value);
                  Dec( Qty );
                  Inc( CurQty );
               end ;
               StockLine[1]:=  IntToStr(Qty);
               StockLine[6]:=  IntToStr(CurQty); //replace in available stock
               StockLines[SubStartAt]  :=  StockLine.PackText;
               ExitBackCount := True ;
            end;
             Inc( SubStartAt );
        end ;
        Dec( SubStartAt );

        // Increase the Search ...
        StockLine.PackText  :=  StockLines[StartAt];
        Qty := StrToIntDef(StockLine[1],0);

        if Qty = 0 then
        begin
           Dec( StartAt ) ;
           SubStartAt := StartAt ;
        end
        else
           Dec( SubStartAt );

      end;  //if not satisfied

      if not SatisfyQty then
         StartAt := -1;

    end;  //while valueleft > 0 and not not tried all denoms

    // in case it couldn't find the right denominations, it keeps the best value
    if ValueLeft > BestValueLeft then
       StockLines.Assign( BestStockLines );

    SatisfyQty := (ValueLeft=0);
  end;  //for multiple items

  // Before ordering the orignal list we put back the Original Current Quantity!!!
  for I:=0 to StockLines.Count-1 do
  begin
    StockLine.PackText:=StockLines[I];
    StockLine[6]:= CurrQtyLst[I];
    StockLines[I]:=StockLine.PackText;
  end ;

  //re-order to original stock list order
  //prepend formatted original order to each stockline
  For i := 0 to StockLines.Count -1 do
    StockLines[I] := Format('%5d',[Integer(StockLines.Objects[I])]) + '@' + StockLines[I];
  //sort by assigning to a stringlist
  BestStockLines.Assign(StockLines);
  BestStockLines.Sort;
  StockLines.Assign(BestStockLines);
  //remove prepended ordering
  For i := 0 to StockLines.Count -1 do
    StockLines[I] := DelimitedString(StockLines[I], '@', True);

  //order selected denominations to top
  OrderIndex := 0;
  for I:=0 to StockLines.Count-1 do
  begin
    StockLine.PackText:=StockLines[I];
    if StrToIntDef(StockLine[1],0) <> 0 then
    begin
      OrderList.Insert(OrderIndex,StockLines[I]);
      Inc(OrderIndex);
    end
    else
      OrderList.Add(StockLines[I]);
  end;
  StockLines.Assign(OrderList);


  OrderList.Free;
  StockLine.Free;
  CurrQtyLst.Free;
  BestStockLines.Free;
end;


function TBaseProduct.CalcStockDenoms(StockLines:TStrings;TotalValue:Currency):String;
//var
//   StockLine:TPackStringList;
//   OrderList:TPackStringList;
//   Qty,I:Integer;
//   Value:Currency;
//   StartAt:Integer;
//   ValueLeft:Currency;
//   CurQty:Integer;
begin
   result := CalcMultiStockDenoms( StockLines,TotalValue,1 );
//   Result:='';
//   StockLine:=TPackStringList.Create;
//   I:=0;
//   { 0=Desc,1=Input Quantity,2=Focused,3=Enabled,4=Price,5=ProgID,6=StockQ,7=Declared,8=PLU,9=Original Description }
//   while I < StockLines.Count do // reduce each item to the max that would satisfy requirement
//   begin
//      StockLine.PackText:=StockLines[I];
//      try
//         if Copy(StockLine[0],Length(StockLine[0])-4,5) = 'Stamp' then
//         begin
//            if StrToIntDef(StockLine[6],0) > (TotalValue / StrToCurrDef(StockLine[4],1)) then
//               StockLine[6]:=IntToStr(Trunc(TotalValue / StrToCurrDef(StockLine[4],1)));
//            StockLines[I]:=StockLine.PackText;
//            Inc(I);
//         end
//         else
//         begin
//            StockLines.Delete(I);
//         end;
//      except
//         Inc(I);
//      end;
//   end;
//   StartAt:=StockLines.Count-1;
//   ValueLeft:=TotalValue;
//   while (ValueLeft > 0) and (StartAt >= 0) do
//   begin
//      for I:=0 to StockLines.Count-1 do // Zero All Stamp Values
//      begin
//         StockLine.PackText:=StockLines[I];
//         StockLine[1]:='0';
//         StockLines[I]:=StockLine.PackText;
//      end;
//      for I:=StartAt downto 0 do
//      begin
//         StockLine.PackText:=StockLines[I];
//         CurQty:=StrToIntDef(StockLine[6],0);
//         Value:=StrToCurrDef(StockLine[4],0);
//         Qty:=0;
//         while (ValueLeft >= Value) and (CurQty > 0) do
//         begin
//            Inc(Qty);
//            Dec(CurQty);
//            ValueLeft:=ValueLeft-Value;
//         end;
//         StockLine[1]:=IntToStr(Qty);
//         StockLines[I]:=StockLine.PackText;
//      end;
//      if ValueLeft > 0 then
//      begin
//         StockLine.PackText:=StockLines[StartAt];
//         CurQty:=StrToIntDef(StockLine[6],0);
//         if CurQty > 0 then
//         begin
//            StockLine[6]:=IntToStr(CurQty-1);
//            StockLines[StartAt]:=StockLine.PackText;
//         end
//         else
//         begin
//            Dec(StartAt);
//         end;
//         ValueLeft:=TotalValue;
//      end;
//   end;
//   OrderList:=TPackStringList.Create;
//   for I:=0 to StockLines.Count-1 do
//   begin
//      StockLine.PackText:=StockLines[I];
//      if StrToIntDef(StockLine[1],0) > 0 then
//         OrderList.Add(StockLines[I]);
//   end;
//   for I:=0 to StockLines.Count-1 do
//   begin
//      StockLine.PackText:=StockLines[I];
//      if StrToIntDef(StockLine[1],0) = 0 then
//         OrderList.Add(StockLines[I]);
//   end;
//   StockLines.Assign(OrderList);
//   OrderList.Free;
//   StockLine.Free;
end;
procedure TBaseProduct.UpdateCustomerDisplay(Line1,Line2:String);
begin
   if FUIEventSink = nil then Exit;
   if CustDisp = nil then
   begin
      CustDisp:=FUIEventSink.GetComponentReference(GUIDToString(Class_CustDispDevice)) as IDevice;
   end;
   if CustDisp = nil then Exit;
   CustDisp.WriteDevice(dcInitialise,'',0);
   CustDisp.WriteDevice(dcRawData,'"'+Line1+'","'+Line2+'"',0);
   CustDisp.WriteDevice(dcShutDown,'',0);
end;
procedure TBaseProduct.Print2x2Report(Lines:TStrings);
var
   ReportPrint:TPrintReport;
begin
   Lines.CommaText := FUIEventSink.Translate( '<GRID:ALLITEMS>'+ Lines.Commatext );
   ReportPrint:=TPrintReport.Create;
   ReportPrint.User         := FUIEventSink.User ;
   ReportPrint.OfficeNumber := IntToStr(FUIEventSink.Office) ;
   ReportPrint.ReportTitle  := FReportTitle;
   ReportPrint.OfficeName   := UpperCase(GetGPCSRegString('OfficeInfo','Office Name','OFFICE NAME')) ;
   ReportPrint.Print2x2ColumnReport(Lines.CommaText);
   ReportPrint.Free;
end;

procedure TBaseProduct.PrintReportStandard(MajorColumnWidths, MinorColumnWidths, ReportVals : String);
var
   ReportPrint:TReportPreviewForm;
begin
   ReportPrint := TReportPreviewForm.Create(nil);
   ReportPrint.User         := FUIEventSink.User ;
   ReportPrint.OfficeNumber := IntToStr(FUIEventSink.Office) ;
   ReportPrint.OfficeName   := UpperCase(GetGPCSRegString('OfficeInfo','Office Name','OFFICE NAME')) ;
   //ReportVals := FUIEventSink.Translate( '<GRID:ALLITEMS>'+ ReportVals );
   ReportPrint.PrintReportStandard(MajorColumnWidths,MinorColumnWidths,  ReportVals);
   ReportPrint.Free;
end;

procedure TBaseProduct.PrintReportReceipt(MajorColumnWidths, MinorColumnWidths :String; ReportVals : String);
type
  TReportColumn = record
    Offset : Integer;
    Width  : Integer;
  end;

var
  FieldIndex  : Integer;          //index of each field in a line
  LineIndex   : Integer;          //report line index
  LineList    : TPackStringList;  //nested field values

  MajorColumnWidthsSL : TStringList;
  MinorColumnWidthsSL : TStringList;

  MajorColumns  : Array[0..100] of TReportColumn;
  MinorColumns  : Array[0..100] of TReportColumn;
  ColumnIndex   : Integer;
  FieldList   : TPackStringList;  //each line
  ColumnOffset  : Integer;
  LastPrintPosition : Integer;
  Translator    : ITranslate ;
begin

  LineList            := TPackStringList.Create;
  FieldList           := TPackStringList.Create;
  MajorColumnWidthsSL := TStringList.Create;
  MinorColumnWidthsSL := TStringList.Create;

   if  FUIEventSink <> nil then
   begin                        
       Translator:= FUIEventSink.Hookup.Translate;
       try
        //setup array of columns
        ColumnOffset := 0;
        MajorColumnWidthsSL.CommaText := MajorColumnWidths;            //eg, '500,500,300,200
        For ColumnIndex := 0 to MajorColumnWidthsSL.Count -1 do
        begin
          MajorColumns[ColumnIndex].Offset := ColumnOffset;
          MajorColumns[ColumnIndex].Width  := StrToInt(MajorColumnWidthsSL[ColumnIndex]);
          Inc(ColumnOffset,MajorColumns[ColumnIndex].Width);
        end;

        ColumnOffset := 0;  //minor cols at left of major col
        MinorColumnWidthsSL.CommaText := MinorColumnWidths;
        For ColumnIndex := 0 to MinorColumnWidthsSL.Count -1 do
        begin
          MinorColumns[ColumnIndex].Offset := ColumnOffset;
          MinorColumns[ColumnIndex].Width  := StrToInt(MinorColumnWidthsSL[ColumnIndex]);
          Inc(ColumnOffset,MinorColumns[ColumnIndex].Width);
        end;

        //extract report values into lines
        LineList.CommaText  := ReportVals;

        //go through report lines
        for LineIndex := 0 to LineList.Count-1 do
        begin

          //prepare each line for printing on receipt printer
          FieldList.CommaText :=  LineList[LineIndex]; //grab fields from this line

          {if (IsNumber(Trim(FieldList[0]))) and (Length(Trim(FieldList[0]))>0) then       // In case qty, don't translate it
               FieldList[0]:= CHRTRL+FieldList[0]+CHRTRL;
          if FieldList[2]<>'' then
               FieldList[2]:= CHRTRL+FieldList[2]+CHRTRL;
          }
          //clean up justification chars
          //   For FieldIndex := 0 to FieldList.Count -1 do
          //   begin
          //     If (FieldList[FieldIndex] <> '') and (FieldList[FieldIndex][1] in ['<', '>']) then
          //       FieldList[FieldIndex] := Copy(FieldList[FieldIndex], 2, Length(FieldList[FieldIndex])-1);
          //   end;

          //print each field in a minor column
          ColumnOffset      := 0;
          LastPrintPosition := 0;
          LineList[LineIndex] := '"'; //add prefix for commatext
          For FieldIndex := 0 to MinIntValue([MinorColumnWidthsSL.Count -1, FieldList.Count-2])  do //-2 = penultimate field
          begin
            //right pad to ensure field is AT LEAST the column width (but allows fields to overrun their column width)
            //overrun required to allow full report width headers etc
            if FieldList[FieldIndex] <> '' then
            begin
              if FieldList[FieldIndex][1] <> '>' then // Left Allign (Default branch)
              begin
                If FieldList[FieldIndex][1] = '<' then
                  FieldList[FieldIndex] := Copy(FieldList[FieldIndex], 2, Length(FieldList[FieldIndex])-1);
                FieldList[FieldIndex] := RightPad(FieldList[FieldIndex],
                                                  MinorColumns[FieldIndex].Width        //defined report column width
                                                  - (LastPrintPosition - ColumnOffset)  //minus accumulated overrun
                                                  , ' ');
              end
              else  // Right Allign
              begin
                If FieldList[FieldIndex][1] = '>' then
                  FieldList[FieldIndex] := Copy(FieldList[FieldIndex], 2, Length(FieldList[FieldIndex])-1);
                FieldList[FieldIndex] := LeftPad(FieldList[FieldIndex],
                                                  MinorColumns[FieldIndex].Width        //defined report column width
                                                  - (LastPrintPosition - ColumnOffset)  //minus accumulated overrun
                                                  , ' ');
              end
            end;
            LineList[LineIndex]   := LineList[LineIndex] + ' ' + Translator.Translate(FieldList[FieldIndex]);
            Inc(ColumnOffset, MinorColumns[FieldIndex].Width);      //record end of the column
            Inc(LastPrintPosition, Length(FieldList[FieldIndex]));  //record last print position
          end;
          If (FieldList[FieldList.Count-1] <> '') and (FieldList[FieldList.Count-1][1] in ['<', '>']) then
            FieldList[FieldList.Count-1] := Copy(FieldList[FieldList.Count-1], 2, Length(FieldList[FieldList.Count-1])-1);
          LineList[LineIndex] := LineList[LineIndex] + '","' + FieldList[FieldList.Count-1] + '"';   //line data to 2 columns with last field as second column
        end;  //for all report lines

        PrintReport(LineList);  //print report on receipt printer

      finally
        LineList.Free;
        FieldList.Free;
        MajorColumnWidthsSL.Free;
        MinorColumnWidthsSL.Free;
      end;  //try
   end;

end;

procedure TBaseProduct.PrintReport(Lines:TStrings);
var
   ReceiptPrinter:IDevice;
begin
   if (DisablePrint) or (FUIEventSink = nil) or (Lines.Count < 1) then Exit;
   try
     // Lines.CommaText := FUIEventSink.Translate( '<GRID:ALLITEMS>'+ Lines.Commatext );
      ReceiptPrinter:=FUIEventSink.GetComponentReference('ReceiptPreview'+Lines.Commatext) as IDevice;
      if ReceiptPrinter <> nil then
      begin
         ReceiptPrinter.WriteDevice(dcInitialise,'',1);
         FUIEventSink.ReferenceData('SendReceiptDetails');
         ReceiptPrinter.WriteDevice(dcList5Data,Lines.Commatext,1);
         ReceiptPrinter.WriteDevice(dcShutdown,'',0);
      end;
   finally
      ReceiptPrinter := nil;
   end ;
   ReceiptPrinter:=nil;
end;

function TBaseProduct.OfficeCheck:String;
begin
  Result:='';
  if (FOfficeNo <> '') and (FOfficeNo <> '0') then
  begin
    if FOfficeNo[1] ='!' then
      Result:=' and (Office <> '''+Copy(FOfficeNo,2,999)+''')'
    else
      Result:=' and (Office = '''+FOfficeNo+''')';
  end
end;

function TBaseProduct.UserSearch:String;
begin
  Result:='';
  if DoFullUserSearch then
     Result:=' and Teller = ''' + FUser + ''''
  else if FUser <> 'Supervisor' then
     Result:=' and Teller = ''' + FUIEventSink.User + '''';
end;

function TBaseProduct.GetUserGroup(User:String):String;
// Returns the GPCS Group for a user eg - GPCS_Clerk
var
  NetManager : INetUser;
  UserGroups : TStringList;
  i : Integer;
begin
  Result:='';
  User:=UpperCase(User);
  try
     NetManager:=CoNetUser.Create;
     UserGroups:=TStringList.Create;
     if NetManager.GetPDC = '' then // Get Local Info
     begin
        if Pos(User,UpperCase(NetManager.GetUsers(GetLocalMachineName))) <> 0 then // user in userlist
           UserGroups.CommaText:=NetManager.GetMemberLocalGroups(GetLocalMachineName,User);
     end
     else // Get Global Info
     begin
        if Pos(User,UpperCase(NetManager.GetUsers(NetManager.GetPDC))) <> 0 then // user in userlist
           UserGroups.CommaText:=NetManager.GetMemberGlobalGroups(NetManager.GetPDC,User);
     end;
     for i:=0 to UserGroups.Count-1 do
     begin
        if UpperCase(Copy(UserGroups[I],1,4)) = 'GPCS' then
        begin
           Result:=UserGroups[i];
           Exit;
        end;
     end;
     UserGroups.Free;
     NetManager:=nil;
  except
     on E : Exception do RaiseGUIDException('{036AC2B9-56A2-4319-96DE-2A519FA3F61E}', E);
  end;
end;


function PLUToSQL(PLURanges:String):String;
var
   I,P:Integer;
   List:TPackStringList;
begin
  Result := '';
   List:=TPackStringList.Create;
   List.CommaText:=PLURanges;
   for I:=0 to List.Count-1 do
   begin
      P:=Pos('-',List[I]);
      if P > 1 then
      begin
         if Result = '' then
            Result:=Result+'((PLU >= '+Copy(List[I],1,P-1)+') and (PLU <= '+Copy(List[I],P+1,Length(List[I]))+'))'
         else
            Result:=Result+' or ((PLU >= '+Copy(List[I],1,P-1)+') and (PLU <= '+Copy(List[I],P+1,Length(List[I]))+'))'
      end
      else
      begin
         if Result = '' then
            Result:=Result+'(PLU = '+List[I]+')'
         else
            Result:=Result+' or (PLU = '+List[I]+')'
      end;
   end;
   Result:='('+Result+')';
end;

function TBaseProduct.StkAtPeriodRepSection(Stock:IStock; Desc : String; PLUList:String; Res:TStrings; ReportEmptyLines:Boolean; ReqdPeriod : Integer; Db : IDatabaseServerAuto ) : Currency;
//returns stock level at end of a given period
type
  TPLURange = (prFrom, prTo);
var
  TheCurrentPeriod    : Integer;
  PLUSL               : TPackStringList;
  TxnsSL              : TPackStringList;
  StockCollection     : TStockCollection;
  StockCollectionItem : TStockCollectionItem;
  StockItemIndex,
  PLUIndex            : Integer;
  FromPLU,ToPLU       : Integer;
  UserName            : String;
  PLURange            : Array[0..20,prFrom..prTo] of Integer;  //up to 20 ranges of low -> high PLU ranges
  PosSign,NegSign     :String ;
  RP : Integer;
const
   LastList:String = '';
begin
  RP := ReqdPeriod;
  TheCurrentPeriod := GetCurrentPeriod ;
  Result := 0;
  if (DoFullUserSearch) or (FUser <> 'Supervisor') then UserName:=FUser
  else UserName:='All';

  StockCollection := TStockCollection.Create;
  PLUSL :=TPackStringList.Create;
  TxnsSL:=TPackStringList.Create;
  try

    //grab current stock levels
//    TheCurrentPeriod := GetCurrentPeriod;
    if Stock <> nil then
    begin
       if ReportEmptyLines then 
          LastList:=Stock.ListAllStock(UserName,'All')
       else 
          LastList:=Stock.ListAvailableStock(UserName,'All');
    end;
    StockCollection.CommaText:=LastList;

    //extract PLU ranges
    If PLUList <> '' then //PLUs specified
    begin
      PLUSL.CommaText:=PLUList; //grab PLU expressions, eg, "123-456,789,234"
      ZeroMemory(@PLURange,SizeOf(PLURange)); //clear all array values
      for PLUIndex := 0 to PLUSL.Count-1 do
      begin
        if Pos('-',PLUSL[PLUIndex]) = 0 then //single value PLUs
        begin
          FromPLU := StrToIntDef(PLUSL[PLUIndex],0);
          ToPLU := FromPLU;
        end
        else
        begin
          FromPLU := StrToIntDef(DelimitedString(PLUSL[PLUIndex],'-',False),0);
          ToPLU   := StrToIntDef(DelimitedString(PLUSL[PLUIndex],'-',True),0);
        end;
        PLURange[PLUIndex,prFrom] := FromPLU;
        PLURange[PLUIndex,prTo] := ToPLU;
      end;
    end;

    //go through all stock items
    for StockItemIndex:=0 to StockCollection.Count-1 do
    begin
      StockCollectionItem := StockCollection.Items[StockItemIndex];
      if PLUList = '' then     //no PLUs specified - return all items individually
      begin
        Res.Add('"' + StockCollectionItem.Description + '","' + IntToStr(StockCollectionItem.Quantity) + '"');  //description, quantity
        Result := Result + StockCollectionItem.Price * StockCollectionItem.Quantity;  //value
      end
      else  //PLUs specified
      begin
        for PLUIndex := 0 to PLUSL.Count-1 do //test this stock item against each PLU range
        begin
          if (StockCollectionItem.PLU >= PLURange[PLUIndex,prFrom]) and (StockCollectionItem.PLU <= PLURange[PLUIndex,prTo]) then //matches a PLU
          begin
            Result := Result + StockCollectionItem.Price * StockCollectionItem.Quantity;  //add current level for this stock item
            //calculate previous stock level of this stock item

            If (RP <> TheCurrentPeriod) then //and (DB <> nil) then
            begin
              //subtract all stock txns of this stock item from current level (TheCurrentPeriod) back to the start of the period following the required period
              With TQueryMap.Create do
              begin
                try
                  SelectFields        := 'applyvalue';
                  ResultFields        := 'applyvalue';
                  TotalFields         := 'applyvalue';

                  if FUser = 'Supervisor'  then//Supervisor
                  begin
                    PosSign := '';
                    NegSign :='-';
                  end
                  else //Clerks/Vendors
                  begin
                    PosSign := '-';
                    NegSign :='';
                  end;

                  //remittances in to the supervisor and transfers to the vendors/clerks
                  SQL := SQL
                  + ' select Sum('+PosSign+'TxnValue) as ApplyValue, 0 from TxnLog '
                  + ' where (Description = ''' + StockCollectionItem.Description + ''') '
                  + ' and (RecType = "TxStkTo" ) '
                  + ' and Period >=  ' + IntToStr(ReqdPeriod+1)
                  + ' and (Teller = "' + FUser + '")'
                  //remittances out from supervisor, transfers back from vendors and transfers to clerks.
                  + ' union'
                  + ' select Sum('+NegSign+'TxnValue) as ApplyValue, 1 from TxnLog '
                  + ' where (Description = ''' + StockCollectionItem.Description + ''') '
                  + ' and (RecType = "TxStkFrom" ) '
                  + ' and Period >= ' + IntToStr(ReqdPeriod+1)
                  + ' and (Teller = "' + FUser + '")' ;

                  If FUser <> 'Vendor' then //Supervisor/Clerks
                  begin
                    //StockUsed (=Sold) records are required for back-calculating from current stock levels
                    SQL := SQL
                         + ' union '
                         //+ ' select Sum(-TxnValue) as Applyvalue, 2 from TxnLog '
                         + ' select Sum(-Price*Quantity) as Applyvalue, 2 from TxnLog '  // modification to pick up cheques
                         + ' where (Description = ''' + StockCollectionItem.Description + ''') '
                         + ' and (RecType = "StockUsed") '
                         + ' and Period >= ' + IntToStr(ReqdPeriod+1) ;
                    If FUser <> 'Supervisor' then //clerks
                      SQL := SQL + ' and (Teller = "' + FUser + '")' ;  //only clerks's own sold stock
                  end;

                  ClearMaps;
                  TxnsSL.CommaText := Execute;
                finally
                  Free; //querymap
                end;
              end;
              Result := Result - StrToCurrDef(TxnsSL[TxnsSL.Count -1],0); //last line is total of stock txns
            end;  //stock required for a previous period
          end;  //if this stock item matches a plu
        end;  //if PLUs specified
      end;  //if PLU list given
    end;  //for all stock item

    //PLUs specified - add summary line only
    if PLUList <> '' then Res.Add('"'+Desc+'","'+CurrToStrF(Result,ffNumber,2)+'"');
  finally
    StockCollection.Free;
    PLUSL.Free;
    TxnsSL.Free;
  end;
end;

function TBaseProduct.StkRepSection(Stock:IStock;Description,PLUList:String;Res:TStrings;ReportEmptyLines:Boolean):Currency;
begin
  Result := StkAtPeriodRepSection(Stock, Description,PLUList,Res,ReportEmptyLines,GetCurrentPeriod, nil );
end;

function TBaseProduct.CancelledLabelList(DB:IDatabaseServerAuto;FromPeriod,ToPeriod:Integer):String;
var
   TxnLogQuery:String;
   QuerySL:TPackStringList;
   RecSL:TPackStringList;
   I:Integer;
   Qty,TQty:Integer;
   Value,TValue:Currency;
begin
   TxnLogQuery:='Select quantity, TxnValue from txnlog '
               + ' where RecType = ''PrLabel'''
               + UserSearch
               + OfficeCheck
               + ' and Period >= ' + IntToStr(FromPeriod)
               + ' and Period <= ' +  IntToStr(ToPeriod);
   DB.DataAlias:='PSL';
   QuerySL :=TPackStringList.Create;
   QuerySL.CommaText:=DB.QueryToCommaText(TxnLogQuery);
   RecSL:=TPackStringList.Create;
   TQty:=0;
   TValue:=0;
   for I:=0 to QuerySL.Count-1 do
   begin
      RecSL.CommaText:=QuerySL[I];
      if RecSL.Count > 1 then
      begin
         Qty:=StrToIntDef(RecSL[0],0);
         Value:=StrToCurrDef(RecSL[1],0);
         if Qty > 0 then
            TValue:=TValue+Value
         else
            TValue:=TValue-Value;
         TQty:=TQty+Qty;
      end;
   end;
   QuerySL.Clear;
   QuerySL.Add(IntToStr(TQty)+' Cancelled Labels   Value =');
   QuerySL.Add(CurrToStr(TValue));
   Result:=QuerySL.CommaText;
   QuerySL.Clear;
   QuerySL.Add(Result);
   Result:=QuerySL.CommaText;
   QuerySL.Free;
   RecSL.Free;
end;
function TBaseProduct.TxnRepSection(DB:IDatabaseServerAuto;Description,Search:String;FromPeriod,ToPeriod:Integer;Res:TStrings;Summary:TSummaryType;ReportEmptyLines:Boolean;TxnType:String):Currency;
var
   RecordIndex:Integer;
   QuerySL:TPackStringList;
   RecordSL:TPackStringList;
   TotalValue,Value:Currency;
   TxnLogQuery:String;
   DivBy100:Boolean;
begin
   TotalValue := 0;
   QuerySL :=TPackStringList.Create;
   RecordSL:=TPackStringList.Create;
   try
      Search := '(' + Search + ')'; //ensure search is self-contained (not combined with other where clauses
      case Summary of
         stSummary,stDetail :
         begin
            //Stock returns should be -ve in txnlog so use PLU (>100 000 000) to adjust logged value
            If StockReturns then
               TxnLogQuery := 'select Description, Sum((1-2*(PLU/100000000))*TxnValue), PLU, Sum ( quantity)  from txnlog'
            else
               TxnLogQuery := 'select Description, Sum(TxnValue), PLU, Sum( quantity ) from TxnLog';

            TxnLogQuery := TxnLogQuery
                    + ' where '+Search
                    + ' and (RecType = '''+TxnType+''')'
                    + UserSearch
                    + OfficeCheck
                    + ' and Period >= ' + IntToStr(FromPeriod)
                    + ' and Period <= ' +  IntToStr(ToPeriod);

            //only retrieve last of possible Balance Carried Forward totals
            If Description = 'Balance Brought Forward'  then
              TxnLogQuery := TxnLogQuery
                    + ' and recordid =( '
                    + '   select max(recordid) from TxnLog '
                    + '   where '+Search
                    + '   and (RecType = '''+TxnType+''')'
                    +     UserSearch
                    +     OfficeCheck
                    + '   and Period Between ' + IntToStr(FromPeriod) + ' and  ' + IntToStr(ToPeriod)
                    + ')';

            //finish query
            TxnLogQuery := TxnLogQuery
                    + ' group by Description, PLU'
                    + ' order by PLU'
                    ;
         end;
         stEveryLine :
         begin
            TxnLogQuery :=
            ' select Description, Info, TxnValue, DateTime, WSNumber, RecordID  from TxnLog'
            + ' where '+Search
            + ' and (RecType = '''+TxnType+''')'
            + UserSearch
            + OfficeCheck
            + ' and Period >= ' + IntToStr(FromPeriod)
            + ' and Period <= ' +  IntToStr(ToPeriod)
            + ' order by DateTime, WSNumber, RecordID'
            ;
         end;
      end;
      DB.DataAlias:='PSL';
      QuerySL.CommaText:=DB.QueryToCommaText(TxnLogQuery);

      if (QuerySL.Count > 0) or ReportEmptyLines then
      begin
         case Summary of
            stSummary   : begin
                             for RecordIndex:=0 to QuerySL.Count-1 do
                             begin
                                RecordSL.CommaText:=QuerySL[RecordIndex];
                                TotalValue:=TotalValue+StrToCurrDef(RecordSL[1],0);
                             end;
                             If  (Description <> 'Cash on Hand')
                             and (Description <> 'Opening Balance') //show -ve cash on hand or opening balance
                             and (not StockReturns)                 //StockReturns mode uses PLU to determine summed values of sold-returned
                             then
                                 TotalValue:=Abs(TotalValue);
                             Res.Add('"'+Description+'","'+CurrToStrF(TotalValue,ffNumber,2)+'"')
                          end;
            stDetail    : begin
                             if Copy( Description,1, 9 )= 'DivBy100:' then
                             begin
                                 Description := Copy( Description, 10, 999 );
                                 DivBy100:=True;
                             end
                             else
                                 DivBy100:=False;

                             Res.Add('"'+Translate(Description)+'"," "');
                             for RecordIndex:=0 to QuerySL.Count-1 do
                             begin
                                RecordSL.CommaText:=QuerySL[RecordIndex];
                                if StrtoIntDef( RecordSL[3], 0 ) > 0 then
                                begin
                                   Value:=Abs(StrToCurrDef(RecordSL[1],0));
                                   RecordSL[1]:=CurrToStrF(Value,ffNumber,2);

                                   if DivBy100 then
                                     RecordSL[3]:= CurrToStrF(StrToCurrDef(RecordSL[3],0)/100, ffNumber, 2);

                                   Res.Add( '"'+CHRTRL+RightPad( RecordSL[3], 3, ' ' )+CHRTRL+' '+   // QTY
                                                   Copy( RecordSL[0],1, 34 )+'","'+    // Description
                                                   RecordSL[1]+'"'  // Value
                                           ) ;
                                   TotalValue:=TotalValue+Value;
                                end ;
                             end;
                             Res.Add('"------------------------------","------------------------------"');
                             Res.Add('"Total","'+CurrToStrF(TotalValue,ffNumber,2)+'"');
                             Res.Add('"------------------------------","------------------------------"');
                          end;
            stEveryLine : begin
                             for RecordIndex:=0 to QuerySL.Count-1 do
                             begin
                                If ReportSort then
                                  QuerySL.Sort;
                                RecordSL.CommaText:=QuerySL[RecordIndex];
                                Value:=Abs(StrToCurrDef(RecordSL[2],0));
                                RecordSL[2]:=CurrToStrF(Value,ffNumber,2);
                                Res.Add('"'+RecordSL[0]+' '  +   //Description
                                            RecordSL[1]+'","'+   //Info
                                            RecordSL[2]+ '"'  ); //Value
                                TotalValue:=TotalValue+Value;
                             end;
                             Res.Insert(0,'"'+Description+'"," "');
                             Res.Add('"------------------------------","------------------------------"');
                             Res.Add('"Total","'+CurrToStrF(TotalValue,ffNumber,2)+'"');
                             Res.Add('"------------------------------","------------------------------"');
                          end;
         end;
      end;
   except
      On E : Exception do
         RaiseGUIDException('{A760E835-7CA1-463B-B1F9-E052A25F7619}', E);
   end;
   QuerySL.Free;
   RecordSL.Free;
   Result:=TotalValue;
end;
function TBaseProduct.TxnRepRelSection(DB:IDatabaseServerAuto;Description,Search:String;FromPeriod,ToPeriod:Integer;Res:TStrings;Summary:TSummaryType;ReportEmptyLines:Boolean;TxnType:String):Currency;
var
   RecordIndex:Integer;
   QuerySL:TPackStringList;
   RecordSL:TPackStringList;
   TotalValue,Value:Currency;
   StartDayFix,TxnLogQuery:String;
begin
   TotalValue := 0;
   QuerySL :=TPackStringList.Create;
   RecordSL:=TPackStringList.Create;
   try
     Search := '(' + Search + ')'; //ensure search is self-contained (not combined with other where clauses
     //only retrieve last of possible Balance Carried Forward totals
     If TxnType = 'StartDay'  then
       StartDayFix := TxnLogQuery
             + ' and recordid =( '
             + '   select max(recordid) from TxnLog '
             + '   where '+Search
             + '   and (RecType = '''+TxnType+''')'
             +     UserSearch
             +     OfficeCheck
             + '   and Period Between ' + IntToStr(FromPeriod) + ' and  ' + IntToStr(ToPeriod)
             + ')';

     case Summary of
        stSummary,stDetail :
        begin
            TxnLogQuery :=
            ' select Description, Sum(TxnValue), PLU, Sum( quantity )  from TxnLog'
            + ' where '+Search
            + ' and (RecType = '''+TxnType+''')'
            + UserSearch
            + OfficeCheck
            + ' and Period >= ' + IntToStr(FromPeriod)
            + ' and Period <= ' +  IntToStr(ToPeriod)
            + StartDayFix
            + ' group by Description, PLU'
            + ' order by PLU'
            ;
        end;
        stEveryLine :
        begin
            TxnLogQuery :=
            ' select Description, Info, TxnValue, DateTime, WSNumber, RecordID  from TxnLog'
            + ' where '+Search
            + ' and (RecType = '''+TxnType+''')'
            + UserSearch
            + OfficeCheck
            + ' and Period >= ' + IntToStr(FromPeriod)
            + ' and Period <= ' +  IntToStr(ToPeriod) 
            + ' order by DateTime, WSNumber, RecordID'
            ;
         end;
      end;

      DB.DataAlias:='PSL';
      QuerySL.CommaText:=DB.QueryToCommaText(TxnLogQuery);

      if (QuerySL.Count > 0) or ReportEmptyLines then
      begin
         case Summary of
              stSummary   : begin
                               for RecordIndex:=0 to QuerySL.Count-1 do
                               begin
                                  RecordSL.CommaText:=QuerySL[RecordIndex];
                                  TotalValue:=TotalValue+StrToCurrDef(RecordSL[1],0);
                               end;
                               Res.Add('"'+Description+'","'+CurrToStrF(TotalValue,ffNumber,2)+'"')
                            end;
              stDetail    : begin
                               Res.Add('"'+Description+'"," "');
                               for RecordIndex:=0 to QuerySL.Count-1 do
                               begin
                                  RecordSL.CommaText:=QuerySL[RecordIndex];
                                  Value:= StrToCurrDef(RecordSL[1],0);
                                  RecordSL[1]:=CurrToStrF(Value,ffNumber,2);

                                  Res.Add( '"'+RightPad( RecordSL[3], 3, ' ' )+' '+   // QTY
                                           Copy( RecordSL[0],1, 34 )+'","'+    // Description
                                           RecordSL[1]+'"'  // Value
                                          ) ;
                                  TotalValue:=TotalValue+Value;
                               end;
                               Res.Add('"------------------------------","------------------------------"');
                               Res.Add('"Total","'+CurrToStrF(TotalValue,ffNumber,2)+'"');
                               Res.Add('"------------------------------","------------------------------"');
                            end;
              stEveryLine : begin
                               Res.Add('"'+Description+'"," "');
                               for RecordIndex:=0 to QuerySL.Count-1 do
                               begin
                                  RecordSL.CommaText:=QuerySL[RecordIndex];
                                  Value:=StrToCurrDef(RecordSL[2],0);
                                  RecordSL[2]:=CurrToStrF(Value,ffNumber,2);
                                  Res.Add('"'+RecordSL[0]+' '  +   //Description
                                              RecordSL[1]+'","'+   //Info
                                              RecordSL[2]+ '"'  ); //Value
                                  TotalValue:=TotalValue+Value;
                               end;
                               Res.Add('"------------------------------","------------------------------"');
                               Res.Add('"Total","'+CurrToStrF(TotalValue,ffNumber,2)+'"');
                               Res.Add('"------------------------------","------------------------------"');
                            end;
         end;
      end;
   except;
   end;
   QuerySL.Free;
   RecordSL.Free;
   Result:=TotalValue;
end;
function RTypeToSQL(RType:String):String;
begin
   Result:=RType+''' or RecType = ''CashAcc'' or RecType = ''CashAccAdj';
end;

procedure TBaseProduct.TotRec(Title,Range,RType:String);
begin
  With ReportParams do
    TotalReceipt:=TotalReceipt+TxnRepSection(DB,Title,PLUToSQL(Range),FromPeriod,FromPeriod,ReportLines,Summary,False,RTypeToSQL(RType));
end;
function TBaseProduct.TotRecRel(Title,Range,RType:String) : Currency;
begin
  With ReportParams do
    Result        := TxnRepRelSection(DB,Title,PLUToSQL(Range),FromPeriod,ToPeriod,ReportLines,Summary,False,RTypeToSQL(RType));
  TotalReceipt  := TotalReceipt+Result;
end;
{procedure TBaseProduct.TotPay(Title,Range,RType:String );
begin
  With ReportParams do
    TotalPayment:=TotalPayment+TxnRepSection(DB,Title,PLUToSQL(Range),FromPeriod,FromPeriod, ReportLines,Summary,False,RTypeToSQL(RType));
end;
}
procedure TBaseProduct.TotPayRel(Title,Range,RType:String);
begin
  With ReportParams do
    TotalPayment:=TotalPayment+TxnRepRelSection(DB,Title,PLUToSQL(Range),FromPeriod,ToPeriod,ReportLines,Summary,False,RTypeToSQL(RType));
end;
procedure TBaseProduct.TotStk(Title,Range:String);
begin
  With ReportParams do
    TotalStock:=TotalStock+TxnRepSection(DB,Title,PLUToSQL(Range),Fromperiod,ToPeriod,ReportLines,Summary,False,'CashAcc');
end;
procedure TBaseProduct.TotStS(Title,Range:String);
begin
  With ReportParams do
    TotalStock:=TotalStock+StkRepSection(AStock,Title,Range,ReportLines,False);
end;
procedure TBaseProduct.TotStM(Title,Range,SRange:String);
var
  TS:Currency;
  FL:TPackStringList;
begin
  With ReportParams do
  begin
    FL:=TPackStringList.Create;
    try
      TS:=TxnRepSection(DB,'',PLUToSQL(Range),FromPeriod,ToPeriod,FL,Summary,False,'CashAccAdj');
      TS:=TS+StkRepSection(AStock,'',SRange,FL,False);
      ReportLines.Add('"'+Title+'","'+CurrToStrF(TS,ffNumber,2)+'"');
      TotalStock:=TotalStock+TS;
    finally
      FL.Free;
    end;
  end;
end;

function  TBaseProduct.TxnReport(RType,FromDate,ToDate:String;Summary:TSummaryType;OfficeNo:String):Currency;
var
   DB                 : IDatabaseServerAuto;
   SL                 : TPackStringList;
   POBoxDescSL,
   POBoxSL            : TPackStringList;  //special case to format POBox report
   POBoxNextDescSL    : TPackStringList;  //next POBox Details
   POBoxBranchAndNo   : String;           //branch and POBox number eg, HM12345
   POBoxBranchTotal   : Currency;         //branch total
   POBoxIndex         : Integer;
   FL                 : TPackStringList;

   FP,TP              : Integer;
   PrecedingPeriod    : Integer;   //period preceding the From Period (FP)
   TD,TV,TI           : Currency;
   ReportPrint        : TPrintReport;
   Print2x2           : Boolean;
   vAM,vAC,vAO,vAS,vAK,vAP,vACQ,vACC: Currency ;
   vDM,vDC,vDO,vDS,vDK,vDP,vDCQ,vDCC: Currency ;

   DeclaredCash       , DeclaredCheques    , DeclaredVouchers   , DeclaredPostStamps                  : Currency ;
   DeclaredRevStamps  , DeclaredPostageDue , DeclaredPostOrders , DeclaredMTN                         : Currency ;
   DeclaredPhoneCards , DeclaredEasyCall   , DeclaredPhumelela  , DeclaredPhil       , DeclaredRegEnv : Currency ;
   DeclaredUmkhululi  , DeclaredPOBoxKeys  , DeclaredAerogrammes                                      : Currency ;
                        ActualCheques      , ActualVouchers     , ActualPostStamps                    : Currency ;
   ActualRevStamps    , ActualPostageDue   , ActualPostOrders   , ActualMTN                           : Currency ;
   ActualPhoneCards   , ActualEasyCall     , ActualPhumelela    , ActualPhil         , ActualRegEnv   : Currency ;
   ActualUmkhululi    , ActualPOBoxKeys    , ActualAerogrammes                                        : Currency ;

   SubTotal,
   UGRecSubTot1,                         //  Needed for subtotals in the Uganda Cash Account
   UGRecSubTot2,
   UGRecSubTot3,
   UGPaySubTot1,
   UGPaySubTot2,
   UGPaySubTot3         : Currency ;

   Period             : IPeriod ;
   TmpStock           : Currency ;
   OtherUser          : String;
   TxnType : String;
   CashOnHand,
   ChequesOnHand,
   VouchersOnHand,
   StampsOnCredit,
   PostOrdsOnCredit,
   BalancingFigure,
   BalancingFigureToProve,
   ActualCash,
   TotalCashAndCheques : Currency;
   VendorStamp, VendorRetail, VendorBWCourier, VendorMerch, VendorPostalOrder : currency ;
   SuperStamp, SuperRetail, SuperBWCourier, SuperMerch, SuperPostalOrder : currency ;


begin
   FOfficeNo:=OfficeNo;
   if RType = '*Stock' then
   begin
      Result:=0;
      StockReport2x2;
      Exit;
   end;
   AStock:=CreateStock;
   TV:=0; 
   if (FUIEventSink.ReferenceData('UserGroup') = 'UGroup.Supervisor')
   or (FUIEventSink.ReferenceData('UserGroup') = 'UGroup.Central')
   or (FUIEventSink.ReferenceData('UserGroup') = 'UGroup.Admin') then
      FUser:='Supervisor'
   else
      FUser:=FUIEventSink.User;

   if FromDate = '' then
   begin
      Period := CreatePeriod ;
      if Period <> nil then
      begin
         FP:=Period.GetCurrentPeriod(FUIEventSink.User);
         TP:=FP;
         Period := nil ;
      end
      else
      begin
         FP:=ToDaysPeriod;
         TP:=ToDaysPeriod;
      end ;
   end
   else
   begin
      FP:=StrToPeriod(FromDate);
      TP:=StrToPeriod(ToDate);
   end;

   SL:=TPackStringList.Create;
   if    (FromDate <> ToDate)
      or (FP <> TodaysPeriod)
      or (TP <> TodaysPeriod)
      or (GetGPCSRegString('','System Name','Tanzania Post') = 'Tanzania Post')
      or (GetGPCSRegString('','System Name','Tanzania Post') = 'Bermuda Post')
      then
   begin
      if FromDate <> '' then
         SL.Add('"From: ' + FromDate+' - To: ' + ToDate + '",""');
   end;

   try
       DB:=CoDatabaseServerAuto.CreateRemote(GetGPCSRegString('','Transaction ServerName',GetLocalMachineName));
    //   DB:=FUIEventSink.GetComponentReference(GUIDToString(Class_DatabaseServerAuto)) as IDatabaseServerAuto;
       Print2x2:=False;

      //setup standard params for external reports (eg BotsCash Account)
      ReportParams.FromDate    := FromDate;
      ReportParams.ToDate      := ToDate;
      ReportParams.FromPeriod  := FP;
      ReportParams.ToPeriod    := TP;
      ReportParams.ReportLines := SL;
      ReportParams.DB          := DB;
      ReportParams.Stock       := AStock;
      ReportParams.User        := FUser;

       if Copy(RType,1,1) = '*' then
       begin
          RType:=Copy(RType,2,999);
          if GetGPCSRegString('Reports','ForceToReceiptPrinter','0') <> '1' then
             Print2x2:=True;
       end;

       if RType = 'CashUp' then
          Summary:=stSummary;

       if RType = 'IncomeDepositSum' then
       begin
          RType:='IncomeDeposit';
          Summary:=stSummary;
       end;
       if RType = 'Stamps' then
       begin
          SL.Add('"Stamp Sales"," "');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,RType,'(PLU >= 9000000) and (PLU < 9910000)',FP,TP,SL,Summary,False,'TxnLine');
       end
       else if RType = 'Retail' then
       begin
          SL.Add('"Retail Sales"," "');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,RType,'(((PLU >= 0002000010) and (PLU <= 0002000040)) or ((PLU >= 0002000110) and (PLU <= 0002000140)) or ((PLU >= 0020001000) and (PLU <= 0020001004)))',FP,TP,SL,stDetail,False,'TxnLine');
       end

    //*****************************************************************************************************//
    //*                                                                                                   *//
    //*                                Swaziland Cash Account - Start                                     *//
    //*                                                                                                   *//
    //*****************************************************************************************************//

      else if LeftOf(UpperCase(RType), 'DLL') then
      begin
      end

      else if RType = 'SwaziCash Account' then
      begin
        ReportParams.Summary     := Summary;
        ReportParams.OfficeNo    := OfficeNo;
        With ReportParams do
        begin
          if FOfficeNo = '' then
          begin
            FReportTitle:='SwaziPost - Full Cash Account';
            CheckReportedStock:=False;
            if FromDate = '' then
              ReportLines.Add('"Clerk Cash Account",""');
          end
          else if Copy(OfficeNo,1,1) = '!' then
          begin
             CheckReportedStock:=True;
             FReportTitle:='SwaziPost - Subs Cash Account';
          end
          else if StrToIntDef(OfficeNo,-1) = UIEventSink.Office then
          begin
             CheckReportedStock:=False;
             FReportTitle:='SwaziPost - GPO Cash Account';
          end
          else
          begin
            CheckReportedStock:=True;
            FReportTitle:='SwaziPost - Sub Cash Account';
            If OfficeNo = '0' then
              ReportLines.Add('"For Office : All",""')
            else
              ReportLines.Add('"For Office : '+OfficeNo+'",""');
          end;

          if CheckReportedStock then ;

          ReportLines.Add('"Receipts",""');
          ReportLines.Add('"------------------------------------------------------------------------",""');

          TotalReceipt:=0;

          DoFullUserSearch:=True;
          TotalReceipt := TxnRepSection(DB,'Balance Brought Forward' ,'((PLU = 02009010) or (PLU = 61000000))',FromPeriod,FromPeriod,ReportLines,Summary,False,RTypeToSQL('TxnTotal'));
          DoFullUserSearch:=False;

          TotRecRel('Debit Errors'                         ,'050032024','TxnLine'  );
          TotRecRel('Money Order - Inland Issued'         ,'002009190,050021001','TxnLine'  );
          TotRecRel('Money Order - Foreign Issued'        ,'002009200,050021005','TxnLine'  );
          TotRecRel('Money Order - Commission'            ,'002009210,000100003','TxnLine'  );
          TotRecRel('Money Order - Other charges'         ,'002009220,050021008,050021009,050021015-050021016,050021018,050021019,050021020,050021021','TxnLine'  );
          TotRecRel('Money Order - Transmission Charges'  ,'002009230,050021013-050021014','TxnLine'  );
          TotRecRel('Telegrams - Domestic'                ,'002009230,050033006','TxnTotal'  );
          TotRecRel('Telegrams - International'           ,'002009230,050033007','TxnTotal'  );
          TotRecRel('Saving Bank Deposit'                 ,'002009020,090000201,090000203','TxnTotal'  );
          TotRecRel('COD Trade Charges'                   ,'002009070,050020009','TxnLine'  );
//          TotRecRel('Domestic COD Trade Charges'          ,'002009070,050020009','TxnLine'  );
//          TotRecRel('Foreign COD Trade Charges'           ,'002009070,050020009','TxnLine'  );
          TotRecRel('Handling Charges'                    ,'002009080,050020006','TxnLine'  );
//          TotRecRel('Customs Handling Charges'            ,'002009040,050020101','TxnLine'  );
          TotRecRel('Customs Duty Fees'                   ,'002009050,050020102-050020103','TxnLine'  );
          TotRecRel('Govt. Sales Tax'                     ,'002009050,050020008','TxnLine'  );
          TotRecRel('Parcel and Sm. Packets Demurrage'   ,'002009050,041000020,041000021','TxnLine'  );
          TotRecRel('Telegraphic Address Renewals'        ,'002009030,050033005','TxnLine'  );
          TotRecRel('PO Box Deposits'                     ,'002009110,050031009','TxnLine'  );
          TotRecRel('PO Box Rentals'                      ,'002009110,030000015,030000016,030000020,030000021','TxnLine'  );
          TotRecRel('PO Box - Other Payments'             ,'002009110,030000025','TxnLine'  );
          TotRecRel('Private Bag Rent Payments'           ,'002009120,030000030-030000032,030000034-030000036','TxnLine'  );
          TotRecRel('Private Bag Other Payments'          ,'002009120,030000033,030000037','TxnLine'  );
          TotRecRel('Postage Prepaid'                     ,'002009130,042000001-042000003','TxnTotal'  );  // Bulk Posting
          TotRecRel('Unaddressed Leaflets'                ,'002009250,050031010','TxnLine'  );
          TotRecRel('Customer Fax'                        ,'002009260,050031011','TxnLine'  );
          TotRecRel('Customer Fax Receive'                ,'          050031012','TxnLine'  );
          TotRecRel('Customer Photocopy'                  ,'002009260,050031015-050031016','TxnLine'  );
          TotRecRel('Franking Machine'                    ,'002009280,050031004','TxnLine'  );
          TotRecRel('Office Rentals'                      ,'          050032025','TxnLine'  );
          TotRecRel('School Fees'                         ,'          050032026','TxnLine'  );
          TotRecRel('School Fees - commission'            ,'          050032027','TxnLine'  );
          TotRecRel('Telephone Bureau Receipts'           ,'          050031017','TxnLine'  );
          TotRecRel('Water Utilities'                     ,'002009300,060030005','TxnLine'  );
          TotRecRel('Electricity'                         ,'002009320,060030001','TxnLine'  );
          TotRecRel('Swazi Telecom'                       ,'002009340,060030002','TxnLine'  );
          TotRecRel('Miscellaneous Receipts'              ,'002009350,050032001','TxnLine'  );

          TotRecRel('EMS Receipts - Individual'           ,'002009090,050050001,050050003','TxnLine'  );
          TotRecRel('EMS Receipts - Contract'             ,'002009100,050050005,050050006','TxnLine'  );
//          TotRecRel('Postal Order Commission'             ,'002009240,050021050','TxnLine'  );
//          TotRecRel('Vouchers Received'                   ,'          050031006','TxnLine'  );
          TotRecRel('Cash Received From Bank'             ,'002009380,050036001','TxnLine'  );

          DoFullUserSearch:=True;
          if User = 'Supervisor' then
          begin
            TxnType := 'TxStkTo';  //supervisor remittances
            ReportLines.Add('"Remittances Received From Other Offices & HQ",""')
          end
          else
          begin
            TxnType := 'TxStkFrom';
            ReportLines.Add('"Received From Postmaster",""');
          end;
          TotRecRel('- Cash'                    ,'002009400,6000000-6020000',TxnType  );
          TotRecRel('- Cheques'                 ,'002009410,6100000-6100000',TxnType  );
//          TotRecRel('- Vouchers'                ,'          050031006',      TxnType  );
          TotRecRel('- Stamps Items'            ,'002009420,9010000-9019999',TxnType  );
          TotRecRel('- Revenue Stamps'          ,'002009420,9020000-9029999',TxnType  );
          TotRecRel('- Postage Due Labels'      ,'002009420,9030000-9039999',TxnType  );
          TotRecRel('- Postal Orders'           ,'002009460,5100000-5109999',TxnType  );
          TotRecRel('- MTN Products'            ,'002009420,2020000-2022999',TxnType  );
          TotRecRel('- Phone Cards'             ,'002009420,2000010-2000999',TxnType  );
          TotRecRel('- EasyCall Cards'          ,'002009420,2010020-2010999',TxnType  );
          TotRecRel('- Umkhululi Cards'         ,'002009420,2011025-2011050',TxnType  );
          TotRecRel('- Phumelela Tickets'       ,'002009420,2023000-2023005',TxnType  );
          TotRecRel('- Phumelela Envelopes'     ,'002009420,2023010-2023010',TxnType  );
          TotRecRel('- Philatelic Items'        ,'002009470,7000010-7000999',TxnType  );
          TotRecRel('- Registered Envelopes'    ,'002009470,2024000-2024010',TxnType  );
          TotRecRel('- Aerogrammes'             ,'002009470,2024020-2024020',TxnType  );
          TotRecRel('- PO Box Keys'             ,'002009470,8000010-8000010',TxnType  );

          DoFullUserSearch:=False;

          ReportLines.Add('"","-------------------"');
          ReportLines.Add('A - Total Receipts,"'+CurrToStrF(TotalReceipt, ffNumber, 2)+'"');

          ReportLines.Add('"",""');
          ReportLines.Add('"Payments",""');
          ReportLines.Add('"------------------------------------------------------------------------",""');

          TotalPayment:=0;

          TotPayRel('Credit Errors'                         ,'050032023','TxnLine'  );
          TotPayRel('Money Order - Inland Paid'             ,'002009510,050021002,050021010,050021017','TxnLine'  );
          TotPayRel('Money Order - Foreign Paid'            ,'002009520,050021006','TxnTotal'  );
          TotPayRel('Money Order - Inland Refund'           ,'002009540,050021004','TxnTotal'  );
          TotPayRel('Post Ord Paid - Inland'                ,'002009550,050021051','TxnTotal'  );
//          TotPayRel('Post Ord Paid - UK'                    ,'002009560,050021052','TxnTotal'  );
          TotPayRel('Post Ord Paid - Foreign'               ,'002009570,050021053','TxnTotal'  );
          TotPayRel('Savings Bank Withdrawals'              ,'002009580,090000202,090000204','TxnTotal'  );
          TotPayRel('PO Box Deposit Refunds'                ,'002009600,030000040','TxnLine'  );
          TotPayRel('Phumelela Prizes Paid Out'             ,'002009600,60030155','TxnLine'  );
          TotPayRel('Pensions Paid - Swaziland'             ,'002009610,050040001','TxnTotal'  );
          TotPayRel('Pensions Paid - South Africa'          ,'002009610,050040003','TxnTotal'  );
          TotalPayment:=TotalPayment+TxnRepRelSection(DB,'Discount To Vendors','PLU = 002009630 or (PLU=060020010 and Quantity<0)', FP,TP,SL,Summary,False,RTypeToSQL('TxnLine'));
          TotPayRel('Miscellaneous Payments'                ,'002009640,050032002','TxnLine'  );
          TotPayRel('Temporary Staff'                       ,'002009690,050033004','TxnLine'  );
          TotPayRel('Deposit With Bank'                     ,'002009710,050035001','TxnLine'  );

          DoFullUserSearch:=True;
          if User = 'Supervisor' then
          begin
            TxnType := 'TxStkFrom';  //supervisor remittances
            ReportLines.Add('"Remittances Despatched To Other Offices & HQ",""')
          end
          else
          begin
            TxnType := 'TxStkTo';
            ReportLines.Add('"Returned To Postmaster",""');
          end;
          TotPayRel('- Cash'                    ,'002009400,6000005-6020000',TxnType  );
          TotPayRel('- Cheques'                 ,'002009410,6100000-6100000',TxnType  );
//          TotPayRel('- Vouchers'                ,'          050031006',      TxnType  );
          TotPayRel('- Stamps Items'            ,'002009420,9010000-9019999',TxnType  );
          TotPayRel('- Revenue Stamps'          ,'002009420,9020000-9029999',TxnType  );
          TotPayRel('- Postage Due Labels'      ,'002009420,9030000-9039999',TxnType  );
          TotPayRel('- Postal Orders'           ,'002009460,5100000-5109999',TxnType  );
          TotPayRel('- MTN Products'            ,'002009420,2020000-2022999',TxnType  );
          TotPayRel('- Phone Cards'             ,'002009420,2000010-2000999',TxnType  );
          TotPayRel('- EasyCall Cards'          ,'002009420,2010020-2010999',TxnType  );
          TotPayRel('- Umkhululi Cards'         ,'002009420,2011025-2011050',TxnType  );
          TotPayRel('- Phumelela Tickets'       ,'002009420,2023000-2023005',TxnType  );
          TotPayRel('- Phumelela Envelopes'     ,'002009420,2023010-2023010',TxnType  );
          TotPayRel('- Philatelic Items'        ,'002009470,7000010-7000999',TxnType  );
          TotPayRel('- Registered Envelopes'    ,'002009470,2024000-2024010',TxnType  );
          TotPayRel('- Aerogrammes'             ,'002009470,2024020-2024020',TxnType  );
          TotPayRel('- PO Box Keys'             ,'002009470,8000010-8000010',TxnType  );
          DoFullUserSearch:=False;

          ReportLines.Add('"","-------------------"');
          ReportLines.Add('B - Total Payments,"'+CurrToStrF(TotalPayment, ffNumber, 2)+'"');

          FL:=TPackStringList.Create;

          ReportLines.Add('"",""');
          ReportLines.Add('"Cash On Hand",""');
          ReportLines.Add('"------------------------------------------------------------------------",""');
          //    CashOnHand is used later in the "Balancing" section
//          CashOnHand :=              TxnRepRelSection(DB,''              ,'Prod = ''Product.Cash'''              ,FromPeriod,ToPeriod,FL,Summary,False,'TxnTotal'' or RecType = ''StartDay'' or RecType = ''CashAccAdj' );

                                    // For "start day" record only pick up the current user.
          DoFullUserSearch:=True;   // This must be done because supervisor "start day" record
                                    // includes cash for the whole office
// test
          CashOnHand :=              TxnRepRelSection(DB,''              ,'Prod = ''Product.Cash'''              ,ToPeriod,ToPeriod,FL,Summary,False,'StartDay' );
// test
          DoFullUserSearch:=False ;
// test
          CashOnHand := CashOnHand + TxnRepRelSection(DB,''              ,'Prod = ''Product.Cash'''              ,ToPeriod,ToPeriod,FL,Summary,False,'TxnTotal'' or RecType = ''CashAccAdj' );
          CashOnHand := CashOnHand + TxnRepSection   (DB,''              ,'(PLU = 2009840)'                      ,ToPeriod,ToPeriod,FL,Summary,False,RTypeToSQL('TxnLine'));
          ReportLines.Add('- Cash on Hand,"' +CurrToStrF(CashOnHand, ffNumber, 2)+'"');

          ChequesOnHand:=                 StkAtPeriodRepSection(Stock,'- Cheques on Hand', '6100000-6100000',FL,True,TP, DB);
          ChequesOnHand:= ChequesOnHand + TxnRepSection   (DB,'','(PLU = 2009850)',ToPeriod,ToPeriod,FL,Summary,False,RTypeToSQL('TxnLine'));
          ReportLines.Add('- Cheques on Hand,"' +CurrToStrF(ChequesOnHand, ffNumber, 2)+'"');

//          VouchersOnHand:=                 StkAtPeriodRepSection(Stock,'- Vouchers on Hand', '050031006',FL,True,TP, DB);
//          VouchersOnHand:= VouchersOnHand + TxnRepSection   (DB,'','(PLU = 00000000)',ToPeriod,ToPeriod,FL,Summary,False,RTypeToSQL('TxnLine'));
//          ReportLines.Add('- Vouchers on Hand,"' +CurrToStrF(VouchersOnHand, ffNumber, 2)+'"');

          TotalCashAndCheques := CashOnHand + ChequesOnHand;
          ReportLines.Add('"","-------------------"');
          ReportLines.Add('C - Cash/Cheques,"'+CurrToStrF(TotalCashAndCheques, ffNumber, 2)+'"');

          ReportLines.Add('"",""');
          ReportLines.Add('"Stock On Hand",""');
          ReportLines.Add('"------------------------------------------------------------------------",""');
          TotalStock := 0;
      //    TotStS('- Stamp Items'           ,'9010005-9011000,9020005-9020125,9118010-9118150');
      //    TotStS('- Retail Items'          ,'9118160-9118610');
      //    TotStS('- Postal Orders'         ,'5100005-5101000');
      //    TotStS('- Philatelic Items'      ,'7000010-7000460');

         if User <> 'Supervisor' then
         begin
          TotalStock := TotalStock + StkAtPeriodRepSection(Stock,'- Stamps Items'            ,'002009420,9010000-9019999',ReportLines,True,TP,DB);
          TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Revenue Stamps'          ,'002009420,9020000-9029999',ReportLines,True,TP,DB);
          TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Postage Due Labels'      ,'002009420,9030000-9039999',ReportLines,True,TP,DB);
          TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Postal Orders'           ,'002009460,5100000-5109999',ReportLines,True,TP,DB);
          TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- MTN Products'            ,'002009420,2020000-2022999',ReportLines,True,TP,DB);
          TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Phone Cards'             ,'002009420,2000010-2000999',ReportLines,True,TP,DB);
          TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- EasyCall Cards'          ,'002009420,2010020-2010999',ReportLines,True,TP,DB);
          TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Umkhululi Cards'         ,'002009420,2011025-2011050',ReportLines,True,TP,DB);
          TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Phumelela Tickets'       ,'002009420,2023000-2023005',ReportLines,True,TP,DB);
          TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Phumelela Envelopes'     ,'002009420,2023010-2023010',ReportLines,True,TP,DB);
          TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Philatelic Items'        ,'002009470,7000010-7000999',ReportLines,True,TP,DB);
          TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Registered Envelopes'    ,'002009470,2024000-2024010',ReportLines,True,TP,DB);
          TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Aerogrammes'             ,'002009470,2024020-2024020',ReportLines,True,TP,DB);
          TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- PO Box Keys'             ,'002009470,8000010-8000010',ReportLines,True,TP,DB);

         end
         else
         begin
           FUser := 'Vendor';
           VendorStamp       := StkAtPeriodRepSection(Stock,'- Get Vendor Stamps ',  '2009950,9010000-9019999',FL,True,TP,DB);
           VendorPostalOrder := StkAtPeriodRepSection(nil  ,'- Get Vendor Postal Orders ', '2009960,5100000-5109999',FL,True,TP,DB);
           //VendorRevenue     := StkAtPeriodRepSection(nil  ,'- Get Vendor Revenue Stamps ',  '2009970,9020000-9029999',FL,True,TP,DB);

           FUser := 'Supervisor';
           SuperStamp        := StkAtPeriodRepSection(Stock,'- Get Supervisor Stamps ',  '9010000-9019999',FL,True,TP,DB);

           ReportLines.Add('- Stamp Items,"'+CurrToStrF(SuperStamp-VendorStamp, ffNumber, 2)+'"');
           TotalStock := TotalStock + SuperStamp ;

           //SuperReVenue  := StkAtPeriodRepSection(nil  ,' Get Supervisor Revenue Stamps'    ,'9020000-9029999',FL,True,TP,DB);
           //ReportLines.Add('- Revenue Stamps,"'+CurrToStrF(SuperRevenue-VendorRevenue, ffNumber, 2)+'"');
           //TotalStock := TotalStock + SuperRevenue ;

           TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Revenue Stamps'          ,'9020000-9029999',ReportLines,True,TP,DB);
           TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Postage Due Labels'      ,'9030000-9039999',ReportLines,True,TP,DB);

           SuperPostalOrder  := StkAtPeriodRepSection(nil  ,' Get Supervisor Postal Orders'    ,'5100000-5109999',FL,True,TP,DB);
           ReportLines.Add('- Postal Orders,"'+CurrToStrF(SuperPostalOrder-VendorPostalOrder, ffNumber, 2)+'"');
           TotalStock := TotalStock + SuperPostalOrder ;

           TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- MTN Products'            ,'2020000-2022999',ReportLines,True,TP,DB);
           TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Phone Cards'             ,'2000010-2000999',ReportLines,True,TP,DB);
           TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- EasyCall Cards'          ,'2010020-2010999',ReportLines,True,TP,DB);
           TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Umkhululi Cards'         ,'2011025-2011050',ReportLines,True,TP,DB);
           TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Phumelela Tickets'       ,'2023000-2023005',ReportLines,True,TP,DB);
           TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Phumelela Envelopes'     ,'2023010-2023010',ReportLines,True,TP,DB);
           TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Philatelic Items'        ,'7000010-7000999',ReportLines,True,TP,DB);
           TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Registered Envelopes'    ,'2024000-2024010',ReportLines,True,TP,DB);
           TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Aerogrammes'             ,'2024020-2024020',ReportLines,True,TP,DB);
           TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- PO Box Keys'             ,'8000010-8000010',ReportLines,True,TP,DB);

             // Stock supplied to agencies on credit should only show on the Supervisor account

           ReportLines.Add('"Stock Supplied To Agencies",""');
           ReportLines.Add('- Stamps On Credit,"'+CurrToStrF(VendorStamp, ffNumber, 2)+'"');
           ReportLines.Add('- Postal Orders On Credit,"'+CurrToStrF(VendorPostalOrder, ffNumber, 2)+'"');
         //ReportLines.Add('- Revenue Stamps On Credit,"'+CurrToStrF(VendorRevenue, ffNumber, 2)+'"');

         end ;


          ReportLines.Add('"","-------------------"');
          ReportLines.Add('D - Total Stock,"'+CurrToStrF(TotalStock, ffNumber, 2)+'"');

          ReportLines.Add('"",""');
          ReportLines.Add('"Balancing",""');
          ReportLines.Add('"------------------------------------------------------------------------",""');

//          BalancingFigure := TotalReceipt-TotalPayment;
//          ReportLines.Add('E - Balancing Figure,"'+CurrToStrF(BalancingFigure, ffNumber, 2)+'"');

//          ReportLines.Add('"",""');
//          BalancingFigureToProve := TotalCashAndCheques + TotalStock;
//          ReportLines.Add('F - Balancing Figure To Prove,"'+CurrToStrF(BalancingFigureToProve, ffNumber, 2)+'"');

          ReportLines.Add('"",""');
          ActualCash := TxnRepSection   (DB,'I - Actual Cash'         ,'((PLU >= 6000001) and (PLU <= 6200000))',ToPeriod,ToPeriod,FL,stSummary,False,'StockDec');
          ReportLines.Add('G - Actual Cash/Cheques/Vouchers,"'+CurrToStrF(ActualCash, ffNumber, 2)+'"');

          ReportLines.Add('"",""');
          if TotalCashAndCheques > ActualCash then
          begin
             ReportLines.Add('Cash/Cheques Shortage,"'+CurrToStrF(ActualCash-TotalCashAndCheques, ffNumber, 2)+'"');
          end;
          if TotalCashAndCheques < ActualCash then
          begin
             ReportLines.Add('Cash/Cheques Over,"'+CurrToStrF(ActualCash-TotalCashAndCheques, ffNumber, 2)+'"');
          end;
          if TotalCashAndCheques = ActualCash then
          begin
             ReportLines.Add('"Cash/Cheques Balance",""');
          end;
          ReportLines.Add('"------------------------------------------------------------------------",""');

        end;  //with BaseProduct
      end
    //*****************************************************************************************************//
    //*                                                                                                   *//
    //*                                 Swaziland Cash Account - end                                      *//
    //*                                                                                                   *//
    //*****************************************************************************************************//


       else if RType = 'JAV' then
       begin
          SL.Add('"JAV Report"," "');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,RType,'(PLU = 30000106)',FP,TP,SL,Summary,False,'TxnLine');
       end
       else if RType = 'POBox' then //clerk report
       begin
          SL.Add('"POBox Sales"," "');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TV+TxnRepSection(DB,RType,'(PLU >= 0010000001) and (PLU < 0010000008)',FP,TP,SL,Summary,True,'TxnLine');
       end
       else if RType = 'POBoxSup' then //supervisor report
       begin
          SL.Add('"POBox Sales"," "');
          SL.Add('"------------------------------","------------------------------"');

          POBoxSL     := TPackStringList.Create;
          POBoxDescSL := TPackStringList.Create;
          POBoxNextDescSL := TPackStringList.Create;
          try
             TV:=TV+TxnRepSection(DB,RType,'(PLU >= 0010000001) and (PLU < 0010000008)',FP,TP,SL,Summary,True,'TxnLine');

             //delete report description line (POBoxSup)
             SL.Delete(3);

             //grab data lines from report
             For POBoxIndex := SL.Count -4 downto  3 do  //miss out title and total lines
             begin
                POBoxSL.Insert(0, SL[POBoxIndex]);  //add each report line
                SL.Delete(POBoxIndex);              //remove from report lines until reformatted
             end;

             //change 999 Desc HM12345 to HM Desc 999 for sorting
             For POBoxIndex :=0 to POBoxSL.Count -1 do
             begin
                POBoxDescSL.CommaText := POBoxSL[POBoxIndex];                           //grab a report line '"999 Desc HM123455","999.99"'
                POBoxBranchAndNo      := LastWord(POBoxDescSL[0]);                      //grab branch and number from '999 Desc HM12345'
                POBoxDescSL[0]        := DelimitedString(POBoxDescSL[0], POBoxBranchAndNo, False);   //change to '999 Desc'
                //change to ' Desc 999'
                POBoxDescSL[0]        := DelimitedString(POBoxDescSL[0], ' ', True) + ' '
                                                                                                                 + DelimitedString(POBoxDescSL[0], ' ', False);
                //change to HM Desc 999
                POBoxDescSL[0]        := Copy(POBoxBranchAndNo, 1,2) + POBoxDescSL[0];
                POBoxSL[POBoxIndex]   := POBoxDescSL.CommaText; //update report line
             end;

             //sort into branch order
             POBoxSL.Sort;

             //total same products by office
             POBoxIndex        := 0;
             POBoxBranchAndNo  := '';
             While (POBoxIndex < POBoxSL.Count-1) do
             begin
                POBoxDescSL.CommaText     := POBoxSL[POBoxIndex];  //grab report line '"HM Desc 999","999.99"'
                POBoxNextDescSL.CommaText := POBoxSL[POBoxIndex+1];
                //chek for matching office and descriptions
                If  LeftString(POBoxDescSL[0],     Length(POBoxDescSL[0])     - Length(LastWord(POBoxDescSL[0])))
                   = LeftString(POBoxNextDescSL[0], Length(POBoxNextDescSL[0]) - Length(LastWord(POBoxNextDescSL[0]))) then
                begin
                   //add quantities
                   POBoxDescSL[0] := LeftString(POBoxDescSL[0],     Length(POBoxDescSL[0])     - Length(LastWord(POBoxDescSL[0])))
                                                                                           + IntToStr(StrToInt(LastWord(POBoxDescSL[0])) + StrToInt(LastWord(POBoxNextDescSL[0])));
                   //add values
                   POBoxDescSL[1] := CurrToStrF(StrToCurr(Replace(POBoxDescSL[1],',','')) + StrToCurr(POBoxNextDescSL[1]), ffNumber, 2	);

                   //remove matching second line product
                   POBoxSL.Delete(POBoxIndex+1);

                   //update record
                   POBoxSL[POBoxIndex] := POBoxDescSL.CommaText;
                end
                else
                   Inc(POBoxIndex);
             end;

             //extract branch headers for report sections
             POBoxIndex        := 0;
             POBoxBranchAndNo  := '';
             POBoxBranchTotal  := -1;            //no branches totalled yet
             While POBoxIndex < POBoxSL.Count do
             begin
                POBoxDescSL.CommaText := POBoxSL[POBoxIndex];  //grab report line '"HM Desc 999","999.99"'
                If LeftString(DelimitedString(POBoxDescSL[0],' ', False),2) <> POBoxBranchAndNo then  //next branch
                begin
                   //show total for last branch
                   If POBoxBranchTotal <> -1 then //not first time
                   begin
                      POBoxSL.Insert(POBoxIndex, '"------------------------------","------------------------------"');
                      POBoxSL.Insert(POBoxIndex+1  , '"Branch Total","'+ CurrToStrF(POBoxBranchTotal, ffNumber, 2	) + '"');
                      Inc(POBoxIndex,2);
                      POBoxBranchTotal := 0
                   end;

                   POBoxBranchAndNo := Copy(DelimitedString(POBoxDescSL[0],' ', False),1,2);       //grab 'HM'
                   //insert '"Branch HM," "' above
                   POBoxSL.Insert(POBoxIndex, '" "," "');
                   POBoxSL.Insert(POBoxIndex+1  , '"Branch ' + POBoxBranchAndNo + '"," "');
                   POBoxSL.Insert(POBoxIndex+2, '"------------------------------","------------------------------"');
                   Inc(POBoxIndex,3);  //adjust to allow for inserted lines
                end;

                //update branch total
                if POBoxBranchTotal = -1 then POBoxBranchTotal := 0;
                POBoxBranchTotal := POBoxBranchTotal + StrToCurrDef(POBoxDescSL[1],0);

                //remove branch/number
                POBoxDescSL[0]      := DelimitedString(POBoxDescSL[0],' ', True); //'HM Desc 999' becomes 'Desc 999'
                                                                                                                                                                                                                                                                                        //'Desc 999' becomes '999 Desc'
                POBoxDescSL[0]      := LastWord(POBoxDescSL[0]) + ' ' + LeftString(POBoxDescSL[0], Length(POBoxDescSL[0]) - Length(LastWord(POBoxDescSL[0])));
                POBoxSL[POBoxIndex] := POBoxDescSL.CommaText; //update report line

                Inc(POBoxIndex);
             end;

             //show total for last branch
             If POBoxBranchTotal <> -1 then //not first time
             begin
                POBoxSL.Insert(POBoxIndex, '"------------------------------","------------------------------"');
                POBoxSL.Insert(POBoxIndex+1  , '"Branch Total","'+ CurrToStrF(POBoxBranchTotal, ffNumber, 2	) + '"');
                POBoxSL.Insert(POBoxIndex+2, '" "," "');
             end;

             //add to report
             For POBoxIndex := POBoxSL.Count -1 downto 0 do
             begin
                SL.Insert(3,POBoxSL[POBoxIndex]);
             end;
          finally
             POBoxSL.Free;
             POBoxDescSL.Free;
             POBoxNextDescSL.Free;
          end;
       end
       else if RType = 'PrLab' then
       begin
          SL.CommaText:=CancelledLabelList(DB,FP,TP);
          SL.Insert(0,'"Cancelled Franking Labels"," "');
          SL.Insert(1, '"From: ' + FromDate+' - To: ' + ToDate + '",""');
          SL.Insert(2,'"------------------------------","------------------------------"');
       end
       else if RType = 'RetailDeclaration' then
       begin
          TV:=0;
          SL.CommaText:=StockReportList(TV,FUIEventSink.User);
          if SL.Count > 0 then
                   SL.Insert(1,'"------------------------------","------------------------------"');

          TI:=TxnRepSection(DB,'Stock Declared','( ((PLU >= 1000000   ) and (PLU < 9910000)) or '+
                                                                                                                                                                  '  ((PLU >= 0020001000) and (PLU < 0020005000)) or '+
                                                                                                                                                                  '  ((PLU >= 0010010000) and (PLU < 0010020000)) )',FP,TP,SL,stDetail,False,'StockDec');

          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Total Stock on Hand","'+CurrToStrF(TV,ffNumber,2)+'"');
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Total Stock Declared","'+CurrToStrF(TI,ffNumber,2)+'"');
          SL.Add('"------------------------------","------------------------------"');
          if TV-TI > 0 then
             SL.Add('"Overs/Shorts","(+)'+CurrToStrF(TV-TI,ffNumber,2)+'"')
          else if TV-TI < 0 then
             SL.Add('"Overs/Shorts","(-)'+CurrToStrF(TI-TV,ffNumber,2)+'"')
          else
             SL.Add('"Overs/Shorts","NONE"');
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Signed Cashier:"," "');
          SL.Add('" "," "');
          SL.Add('" "," "');
          SL.Add('" "," "');
          SL.Add('"------------------------------","------------------------------"');
       end
       else if RType = 'StockRecon' then
       begin
       end
       else if RType = 'Mail' then
       begin
          //if Summary = stSummary then
          //   SL.Add('"Mail Summary",""')
          //else
          //   SL.Add('"Mail Detail",""');
          //SL.Add('"------------------------------","------------------------------"');

          TV:=TV+TxnRepSection(DB,'Frank Post' , '(      (PLU Between 10040000 and 10040004)' +
                                                    ' or (PLU Between 10040011 and 10040017)' +
                                                    ' or (PLU Between 10040020 and 10040024)' +
                                                    ' or (PLU in(10040400, 10040026, 10040027, 10040600, 10040300, 10040301))' +
                                                    ' ) and (Price <> 0) ',FP,TP,SL,Summary,FALSE,'TxnLine');

          TV:=TV+TxnRepSection(DB,'Advice of Delivery' , 'PLU in (10040050, 10040350, 10040450) '
                                                           ,FP,TP,SL,Summary,FALSE,'TxnLine');

          TV:=TV+TxnRepSection(DB,'Registered' , 'PLU in (10040051, 10040052) '
                                                           ,FP,TP,SL,Summary,FALSE,'TxnLine');

          SL.Add('" "," "');
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Grand Total", "' + CurrToStrF(TV, ffNumber, 2) + '"');
          SL.Add('"------------------------------","------------------------------"');

    {
          TV:=TV+TxnRepSection(DB,'Domestic Letter'           ,'(PLU = 0010040000)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Domestic Printed Paper'    ,'(PLU = 0010040001)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Domestic Local Print Paper','(PLU = 0010040002)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Domestic Post Card'        ,'(PLU = 0010040003)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Domestic Blind Literature' ,'(PLU = 0010040004)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'IDE'                       ,'(PLU = 0010040400)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Surface Letter'            ,'(PLU = 0010040011)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Surface Packet'            ,'(PLU = 0010040012)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Surface Printed Papers'    ,'(PLU = 0010040013)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Surface Local Papers'      ,'(PLU = 0010040014)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Surface Post Card'         ,'(PLU = 0010040015)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Surface Local Books'       ,'(PLU = 0010040016)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Surface Blind Literature'  ,'(PLU = 0010040017)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Surface Parcel'            ,'(PLU = 0010040300)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Air Letter'                ,'(PLU = 0010040020)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Air Packet'                ,'(PLU = 0010040021)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Air Papers and Packets'    ,'(PLU = 0010040022)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Air Locally Printed Papers','(PLU = 0010040023)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Air Post Card'             ,'(PLU = 0010040024)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Air Locally Printed Books' ,'(PLU = 0010040026)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Air Blind Literature'      ,'(PLU = 0010040027)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Air Parcel'                ,'(PLU = 0010040301)',FP,TP,SL,Summary,False,'TxnLine');

          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Grand Total","'+CurrToStrF(TV,ffNumber,2)+'"');
    }
       end
       else if RType = 'Agency' then
       begin
          if Summary = stSummary then
             SL.Add('"Agency Summary"," "')
          else
             SL.Add('"Agency Detail"," "');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TV+TxnRepSection(DB,'Public Transportation'     ,'(PLU >= 0008000010) and (PLU < 0008000300)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Customs'                   ,'(PLU >= 0010000020) and (PLU < 0010000030) and (RecIndex) = 0',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Agriculture and Fisheries' ,'(PLU = 0010000010)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Education'                 ,'(PLU = 0007002000)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Youth and Sport'           ,'(PLU = 0007002500)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Corp of Hamiltom'          ,'(PLU = 0005000500)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'Works and Engineering'     ,'(PLU >= 0010000100) and (PLU < 0010000300)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'TBI Phone Cards'           ,'(PLU >= 0004000011) and (PLU < 0004000019)',FP,TP,SL,Summary,False,'TxnLine');
          TV:=TV+TxnRepSection(DB,'C&W Phone Cards'           ,'(PLU >= 0004000001) and (PLU < 0004000009)',FP,TP,SL,Summary,False,'TxnLine');
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Grand Total","'+CurrToStrF(TV,ffNumber,2)+'"');
       end
       else if RType = 'Dogs' then
       begin
          Sl.Add('"Dog Licence Sales"," "');
          SL.Add('"------------------------------","------------------------------"');
          ReportSort := True;
          try
            TV:=TxnRepSection(DB,RType,'(PLU = 0010000010)',FP,TP,SL,Summary,True,'TxnLine');
          finally
            ReportSort := False;
          end;
       end
       else if RType = 'Philatelic' then
       begin
          Sl.Add('"Philatelic Sales"," "');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,RType,'(PLU >= 0010010000) and (PLU < 0010020000)',FP,TP,SL,Summary,False,'TxnLine');
       end

    //*****************************************************************************************************//
    //*                                                                                                   *//
    //*                             Bermuda Stock Returns and Stock Orders printing                       *//
    //*                                               Start                                               *//
    //*                                                                                                   *//
    //*****************************************************************************************************//

       else if RType = 'BermudaReturns' then
       begin
          SL.Add('"Stock Returns",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=   TxnRepSection(DB,'Stamps'                     ,'Ident = ">Supervisor" and ((PLU >= 9000005) and (PLU <= 9020095))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Bermudian Cash/Cheques'     ,'Ident = ">Supervisor" and ((PLU >= 0500001) and (PLU <= 0510000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Other Cash/Cheques'         ,'Ident = ">Supervisor" and ((PLU >= 0600096) and (PLU <= 0610000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Phone Cards'                ,'Ident = ">Supervisor" and ((PLU >= 4000001) and (PLU <= 4000013))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Bus Tickets / Passes'       ,'Ident = ">Supervisor" and ((PLU >= 8000010) and (PLU <= 8000170))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Retail Items'               ,'Ident = ">Supervisor" and ((PLU >= 2000010) and (PLU <= 2000140))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Stationery'                 ,'Ident = ">Supervisor" and ((PLU >= 20001000) and (PLU <= 20001004))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'School Vouchers'            ,'Ident = ">Supervisor" and ((PLU >= 7002000) and (PLU <= 7002500))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Works and Eng Booklets'     ,'Ident = ">Supervisor" and ((PLU >= 10000100) and (PLU <= 10000100))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Philatelic'                 ,'Ident = ">Supervisor" and ((PLU >= 10012023) and (PLU <= 10012813))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Customs Duty'               ,'Ident = ">Supervisor" and ((PLU >= 10000020) and (PLU <= 10000020))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Land Tax'                   ,'Ident = ">Supervisor" and ((PLU >= 10000050) and (PLU <= 10000050))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Parking Tickets / Vouchers' ,'Ident = ">Supervisor" and ((PLU = 10000060) or (PLU = 5000500))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Vehicle Licencing'          ,'Ident = ">Supervisor" and ((PLU >= 10000070) and (PLU <= 10000070))',FP,TP,SL,stDetail,False,'StockTx');

          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Grand Total","'+CurrToStrF(TV,ffNumber,2)+'"');

       end
       else if RType = 'BermudaRequests' then
       begin
          SL.Add('"Stock Requests",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=   TxnRepSection(DB,'Stamps'                     ,'Ident = "<Supervisor" and ((PLU >= 9000005) and (PLU <= 9020095))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Bermudian Cash/Cheques'     ,'Ident = "<Supervisor" and ((PLU >= 0500001) and (PLU <= 0510000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Other Cash/Cheques'         ,'Ident = "<Supervisor" and ((PLU >= 0600096) and (PLU <= 0610000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Phone Cards'                ,'Ident = "<Supervisor" and ((PLU >= 4000001) and (PLU <= 4000013))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Bus Tickets / Passes'       ,'Ident = "<Supervisor" and ((PLU >= 8000010) and (PLU <= 8000170))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Retail Items'               ,'Ident = "<Supervisor" and ((PLU >= 2000010) and (PLU <= 2000140))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Stationery'                 ,'Ident = "<Supervisor" and ((PLU >= 20001000) and (PLU <= 20001004))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'School Vouchers'            ,'Ident = "<Supervisor" and ((PLU >= 7002000) and (PLU <= 7002500))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Works and Eng Booklets'     ,'Ident = "<Supervisor" and ((PLU >= 10000100) and (PLU <= 10000100))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Philatelic'                 ,'Ident = "<Supervisor" and ((PLU >= 10012023) and (PLU <= 10012813))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Customs Duty'               ,'Ident = "<Supervisor" and ((PLU >= 10000020) and (PLU <= 10000020))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Land Tax'                   ,'Ident = "<Supervisor" and ((PLU >= 10000050) and (PLU <= 10000050))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Parking Tickets / Vouchers' ,'Ident = "<Supervisor" and ((PLU = 10000060) or (PLU = 5000500))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Vehicle Licencing'          ,'Ident = "<Supervisor" and ((PLU >= 10000070) and (PLU <= 10000070))',FP,TP,SL,stDetail,False,'StockTx');

          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Grand Total","'+CurrToStrF(TV,ffNumber,2)+'"');

       end

    //*****************************************************************************************************//
    //*                                                                                                   *//
    //*                             Bermuda Stock Returns and Stock Orders printing                       *//
    //*                                                End                                                *//
    //*                                                                                                   *//
    //*****************************************************************************************************//

       else if RType = 'IncomeSummary' then
       begin
          if Summary = stSummary then
             SL.Add('"Income Summary"," "')
          else
             SL.Add('"Income Detail"," "');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TV+TxnRepSection(DB,'PHILATELIC ACCOUNT HOLDERS'   ,'(PLU = 0010020000)',FP,TP,SL,Summary,True,'TxnLine');
          //TV:=TV+TxnRepSection(DB,'POSTAGE STAMPS'               ,'(PLU >= 0009000000) and (PLU < 0009910000)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'POSTAGE STAMPS/AEROGRAMS'     ,'((PLU >= 0009000000) and (PLU < 0009910000) and (PLU <> 0009020095))',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'PHILATELIC SALES'             ,'(PLU >= 0010010000) and (PLU < 0010020000)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'BUS TICKETS'                  ,'(PLU >= 0008000010) and (PLU < 0008000099)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'BUS PASSES'                   ,'(PLU >= 0008000100) and (PLU < 0008000300)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'CUSTOMS DUTIES'               ,'(PLU = 0010000021) and (RecIndex) = 0',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'CUSTOMS DEPOSITS'             ,'(PLU = 0010000020) and (RecIndex) = 0',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'BOX RENTS (Inc. Locks & Keys)','(PLU >= 0010000001) and (PLU < 0010000008)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'DOG LICENCES'                 ,'(PLU = 0010000010)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'I.R.C.''s'                    ,'(PLU = 0009020095)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'TAX MAIL'                     ,'(PLU = 0010030000)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'FRANK POST - LICENCE HOLDER'  ,'(PLU = 0010040500)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'FRANK POST - OTHER'           ,'(PLU >= 0010040000) and (PLU < 0010040100)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'FRANK POST - PARCEL POST'     ,'(PLU >= 0010040300) and (PLU < 0010040400)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'FRANK POST - IDE'             ,'(PLU >= 0010040400) and (PLU < 0010040500)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'BULK MAIL'                    ,'(PLU >= 0010040600) and (PLU < 0010040700)',FP,TP,SL,Summary,True,'TxnTotal');
          TV:=TV+TxnRepSection(DB,'A.S.P. VOUCHERS'              ,'(PLU = 0007002500)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'PHOTOCOPIES'                  ,'(PLU >= 0010041000) and (PLU < 0010041010)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'BILL OF ENTRY FORMS'          ,'(PLU = 0010000030)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'FAX'                          ,'(PLU = 0010041010)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'T. SHIRTS'                    ,'(PLU >= 0002000000) and (PLU < 0002000200)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'PARKING VOUCHERS'             ,'(PLU = 0005000500)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'TELEPHONE CARDS'              ,'(PLU >= 0004000000) and (PLU < 0004000020)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'PRE-SCHOOL VOUCHERS'          ,'(PLU = 0007002000)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'OTHER RETAIL ITEMS'           ,'(PLU >= 0020001000) and (PLU < 0020005000)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'POSTAGE PAID PERMIT'          ,'(PLU = 0030000001)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'LOCAL SEALING PERMIT'         ,'(PLU = 0030000002)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'BUSISNESS REPLY PERMIT'      ,'(PLU = 0030000003)',FP,TP,SL,Summary,True,'TxnLine');
          TV:=TV+TxnRepSection(DB,'MAIL HANDING FEE'             ,'(PLU = 0030000004)',FP,TP,SL,Summary,True,'TxnLine');
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Grand Total","'+CurrToStrF(TV,ffNumber,2)+'"');
       end
       else if RType = 'DepositSummary' then
       begin
          SL.Add('"Deposit Summary"," "');
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Declared"," "');
          TV:=TV+TxnRepSection(DB,'BD $ 100 X'       ,'(PLU = 0000510000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'BD $  50 X'       ,'(PLU = 0000505000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'BD $  20 X'       ,'(PLU = 0000502000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'BD $  10 X'       ,'(PLU = 0000501000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'BD $   5 X'       ,'(PLU = 0000500500)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'BD $   2 X'       ,'(PLU = 0000500200)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'BD $ CHEQUES'     ,'(PLU = 0000500250)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'US $ 100 X'       ,'(PLU = 0000610000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'US $  50 X'       ,'(PLU = 0000605000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'US $  20 X'       ,'(PLU = 0000602000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'US $  10 X'       ,'(PLU = 0000601000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'US $   5 X'       ,'(PLU = 0000600500)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'US $   1 X'       ,'(PLU = 0000600100)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'US $ CHEQUES'     ,'(PLU = 0000600250)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'COINS'            ,'(PLU Between 500001 and 0000500100) and PLU <> 500095',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'I.R.C.''s'        ,'(PLU = 500095)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'JAV''s'           ,'(PLU = 0000600096)',FP,TP,SL,Summary,True,'StockDec');
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Declared Total","'+CurrToStrF(TV,ffNumber,2)+'"');
          SL.Add('"Receipts"," "');
          SL.Add('"------------------------------","------------------------------"');
          TxnRepSection(DB,'TOTAL CHEQUES RECEIVED'  ,'(PLU = 0030000103)',FP,TP,SL,stSummary,True,'TxnTotal');
          TxnRepSection(DB,'TOTAL FCHEQUES RECEIVED' ,'(PLU = 0030000104)',FP,TP,SL,stSummary,True,'TxnTotal');
          TxnRepSection(DB,'TOTAL I.R.C.''S RECEIVED','(PLU = 0030000105)',FP,TP,SL,stSummary,True,'TxnTotal');
          TxnRepSection(DB,'TOTAL JAV''s RECEIVED'   ,'(PLU = 0030000106)',FP,TP,SL,stSummary,True,'TxnTotal');
          SL.Add('"------------------------------","------------------------------"');
       end
       else if ( RType = 'IncomeDeposit' ) or ( RType = 'CashUp' ) then
       begin

          if RType = 'CashUp' then
          begin
             SL.Add('"Cash Up Sheet",""') ;
             SL.Add('"Working Period '+PeriodToDateStr( FP )+'",""');
          end
          else
             if Summary = stSummary then
                SL.Add('"Income Summary Sheet",""')
             else
                SL.Add('"Income Detail Sheet",""');

          SL.Add('"------------------------------","------------------------------"');
          if Summary = stSummary then
             SL.Add('"Income Summary",""')
          else
             SL.Add('"Income Detail",""');
          SL.Add('"------------------------------","------------------------------"');
          //Flag Stock Returns as active to be subtracted from stock sales in report
          StockReturns := True;
          try
             TV:=TV+TxnRepSection(DB,'PHILATELIC ACCOUNT HOLDERS'   ,'(PLU = 0010020000)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'POSTAGE STAMPS/AEROGRAMS'     ,'((PLU Between 09000000 and 09909999) and (PLU  <> 0009020095))  or ((PLU Between 109000000 and 109909999) and (PLU  <> 109020095))',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'PHILATELIC SALES'             ,'(PLU Between 10010000 and 10019999) or (PLU Between 110010000 and 110019999)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'BUS TICKETS'                  ,'(PLU Between 08000010 and 08000099) or (PLU Between 108000010 and 108000099)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'BUS PASSES'                   ,'(PLU Between 08000100 and 08000299) or (PLU Between 108000100 and 108000299)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'CUSTOMS DUTIES'               ,'(PLU = 0010000021) and (RecIndex) = 0',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'CUSTOMS DEPOSITS'             ,'(PLU = 0010000020) and (RecIndex) = 0' ,FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'BOX RENTS (Inc. Locks & Keys)','(PLU Between 0010000001 and 0010000007)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'DOG LICENCES'                 ,'(PLU = 0010000010)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'I.R.C.''s'                    ,'(PLU = 0009020095) or (PLU = 109020095)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'TAX MAIL'                     ,'(PLU = 0010030000)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'FRANK POST - LICENCE HOLDER'  ,'(PLU = 0010040500)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'FRANK POST - OTHER'           ,'(PLU Between 010040000 and 010040099)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'FRANK POST - PARCEL POST'     ,'(PLU Between 010040300 and 010040399)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'FRANK POST - IDE'             ,'(PLU Between 010040400 and 010040499)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'BULK MAIL'                    ,'(PLU Between 010040600 and 010040699)',FP,TP,SL,Summary,True,'TxnTotal');
             TV:=TV+TxnRepSection(DB,'A.S.P. VOUCHERS'              ,'(PLU in (0007002500, 107002500))',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'PHOTOCOPIES'                  ,'(PLU Between 010041000 and 010041009)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'BILL OF ENTRY FORMS'          ,'(PLU = 0010000030)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'FAX'                          ,'(PLU = 0010041010)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'T. SHIRTS'                    ,'(PLU Between 002000000 and 002000199) or (PLU Between 102000000 and 102000199)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'PARKING VOUCHERS'             ,'(PLU in (005000500, 105000500))',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'TELEPHONE CARDS'              ,'(PLU Between 004000000 and 004000019) or (PLU Between 104000000 and 104000019)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'PRE-SCHOOL VOUCHERS'          ,'(PLU in (007002000, 107002000))',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'OTHER RETAIL ITEMS'           ,'(PLU Between 020001000 and 020004999) or (PLU Between 120001000 and 120004999)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'POSTAGE PAID PERMIT'          ,'(PLU = 0030000001)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'LOCAL SEALING PERMIT'         ,'(PLU = 0030000002)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'BUSINESS REPLY PERMIT'        ,'(PLU = 0030000003)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'MAIL HANDING FEE'             ,'(PLU = 0030000004)',FP,TP,SL,Summary,True,'TxnLine');
          finally
             StockReturns := False;
          end;

          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Total Income","'+CurrToStrF(TV,ffNumber,2)+'"');
          SL.Add('"------------------------------","------------------------------"');
          //returned stock already accounted for in individual lines
          TxnRepSection(DB,'RETURNED STOCK'               ,'((PLU >= 0100000000) and (PLU < 0200000000))',FP,TP,SL,Summary,True,'TxnLine');
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Total Income (Inc. Returns)","'+CurrToStrF(TV,ffNumber,2)+'"');
          SL.Add('"------------------------------","------------------------------"');
          TI:=TV;
          TV:=0;
          SL.Add('"Deposit Summary",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TV+TxnRepSection(DB,'BD $ 100 X',       '(PLU = 0000510000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'BD $  50 X',       '(PLU = 0000505000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'BD $  20 X',       '(PLU = 0000502000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'BD $  10 X',       '(PLU = 0000501000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'BD $   5 X',       '(PLU = 0000500500)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'BD $   2 X',       '(PLU = 0000500200)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'BD $ CHEQUES',     '(PLU = 0000500250)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'US $ 100 X',       '(PLU = 0000610000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'US $  50 X',       '(PLU = 0000605000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'US $  20 X',       '(PLU = 0000602000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'US $  10 X',       '(PLU = 0000601000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'US $   5 X',       '(PLU = 0000600500)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'US $   1 X',       '(PLU = 0000600100)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'US $ CHEQUES',     '(PLU = 0000600250)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'COINS'            ,'(PLU Between 500001 and 0000500100) and PLU <> 500095',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'I.R.C.''s'        ,'(PLU = 500095)',FP,TP,SL,stSummary,True,'StockDec');
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Total Deposits","'+CurrToStrF(TV,ffNumber,2)+'"');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TV+TxnRepSection(DB,'JAV''s (enc)',           '(PLU = 0000600096)',FP,TP,SL,Summary,True,'StockDec');
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Total Income","'+CurrToStrF(TI,ffNumber,2)+'"');
          SL.Add('"------------------------------","------------------------------"');
          if TV-TI > 0 then
             SL.Add('"Overs/Shorts","(+)'+CurrToStrF(TV-TI,ffNumber,2)+'"')
          else if TV-TI < 0 then
             SL.Add('"Overs/Shorts","(-)'+CurrToStrF(TI-TV,ffNumber,2)+'"')
          else
             SL.Add('"Overs/Shorts","NONE"');
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Signed Cashier:",""');
          SL.Add('"",""');
          SL.Add('"",""');
          SL.Add('"",""');
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"'+DateTimeToStr(Now)+'",""');
          SL.Add('"------------------------------","------------------------------"');
       end
       else if RType = 'Clerk End-Of-Day' then
       begin
             if Summary = stSummary then
                SL.Add('"Income Summary Sheet",""')
             else
                SL.Add('"Income Detail Sheet",""');

          SL.Add('"------------------------------","------------------------------"');
          if Summary = stSummary then
             SL.Add('"Income Summary",""')
          else
             SL.Add('"Income Detail",""');
          SL.Add('"------------------------------","------------------------------"');
          //Flag Stock Returns as active to be subtracted from stock sales in report
          StockReturns := True;
          try
             TV:=TV+TxnRepSection(DB,'ORDINARY STAMPS'              ,'((PLU Between 6000001 and 6000500)',FP,TP,SL,Summary,True,'TxnLine');
             TV:=TV+TxnRepSection(DB,'AEROGRAMMES'                  ,'(PLU = 9000010) and (RecIndex) = 0',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'FRANKING SERVICE'             ,'(PLU Between 060000400 and 060000420)',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'OTHER MAIL SERVICES'          ,'(PLU Between 070000100 and 070000140)',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'LOTTERY CARDS'                ,'(PLU = 070000150) and (RecIndex) = 0',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'I.R.C.''s'                    ,'(PLU = 0009020095) or (PLU = 109020095)',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'TAX MAIL'                     ,'(PLU = 0010030000)',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'FRANK POST - LICENCE HOLDER'  ,'(PLU = 0010040500)',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'FRANK POST - OTHER'           ,'(PLU Between 010040000 and 010040099)',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'FRANK POST - PARCEL POST'     ,'(PLU Between 010040300 and 010040399)',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'FRANK POST - IDE'             ,'(PLU Between 010040400 and 010040499)',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'BULK MAIL'                    ,'(PLU Between 010040600 and 010040699)',FP,TP,SL,Summary,True,'TxnTotal');
        //     TV:=TV+TxnRepSection(DB,'A.S.P. VOUCHERS'              ,'(PLU in (0007002500, 107002500))',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'PHOTOCOPIES'                  ,'(PLU Between 010041000 and 010041009)',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'BILL OF ENTRY FORMS'          ,'(PLU = 0010000030)',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'FAX'                          ,'(PLU = 0010041010)',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'T. SHIRTS'                    ,'(PLU Between 002000000 and 002000199) or (PLU Between 102000000 and 102000199)',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'PARKING VOUCHERS'             ,'(PLU in (005000500, 105000500))',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'TELEPHONE CARDS'              ,'(PLU Between 004000000 and 004000019) or (PLU Between 104000000 and 104000019)',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'PRE-SCHOOL VOUCHERS'          ,'(PLU in (007002000, 107002000))',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'OTHER RETAIL ITEMS'           ,'(PLU Between 020001000 and 020004999) or (PLU Between 120001000 and 120004999)',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'POSTAGE PAID PERMIT'          ,'(PLU = 0030000001)',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'LOCAL SEALING PERMIT'         ,'(PLU = 0030000002)',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'BUSINESS REPLY PERMIT'        ,'(PLU = 0030000003)',FP,TP,SL,Summary,True,'TxnLine');
        //     TV:=TV+TxnRepSection(DB,'MAIL HANDING FEE'             ,'(PLU = 0030000004)',FP,TP,SL,Summary,True,'TxnLine');
          finally
             StockReturns := False;
          end;

          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Total Income","'+CurrToStrF(TV,ffNumber,2)+'"');
          SL.Add('"------------------------------","------------------------------"');
          //returned stock already accounted for in individual lines
          TxnRepSection(DB,'RETURNED STOCK'               ,'((PLU >= 0100000000) and (PLU < 0200000000))',FP,TP,SL,Summary,True,'TxnLine');
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Total Income (Inc. Returns)","'+CurrToStrF(TV,ffNumber,2)+'"');
          SL.Add('"------------------------------","------------------------------"');
          TI:=TV;
          TV:=0;
          SL.Add('"Deposit Summary",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TV+TxnRepSection(DB,'£ 1  ',       '(PLU = 0000510000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'£ 2  ',       '(PLU = 0000505000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'£ 5  ',       '(PLU = 0000502000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'£ 10 ',       '(PLU = 0000501000)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'£ 20 ',       '(PLU = 0000500500)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'£ 50 ',       '(PLU = 0000500200)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'CHEQUES',     '(PLU = 0000500250)',FP,TP,SL,stSummary,True,'StockDec');
          TV:=TV+TxnRepSection(DB,'I.R.C.''s'        ,'(PLU = 500095)',FP,TP,SL,stSummary,True,'StockDec');
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Total Deposits","'+CurrToStrF(TV,ffNumber,2)+'"');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TV+TxnRepSection(DB,'JAV''s (enc)',           '(PLU = 0000600096)',FP,TP,SL,Summary,True,'StockDec');
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Total Income","'+CurrToStrF(TI,ffNumber,2)+'"');
          SL.Add('"------------------------------","------------------------------"');
          if TV-TI > 0 then
             SL.Add('"Overs/Shorts","(+)'+CurrToStrF(TV-TI,ffNumber,2)+'"')
          else if TV-TI < 0 then
             SL.Add('"Overs/Shorts","(-)'+CurrToStrF(TI-TV,ffNumber,2)+'"')
          else
             SL.Add('"Overs/Shorts","NONE"');
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Signed Cashier:",""');
          SL.Add('"",""');
          SL.Add('"",""');
          SL.Add('"",""');
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"'+DateTimeToStr(Now)+'",""');
          SL.Add('"------------------------------","------------------------------"');
       end
       else if RType = 'School' then
       begin
          Sl.Add('"School Voucher Sales",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,RType,'(PLU >= 0007002000) and (PLU < 0007003000)',FP,TP,SL,Summary,False,'TxnLine');
       end
       else if RType = 'ASum' then
       begin
          ReportPrint:=TPrintReport.Create;

          FL:=TPackStringList.Create;
          TI:=0;
          StockReturns := True;
          try
             SL.Clear; TV:=TxnRepSection(DB,'PHILATELIC ACCOUNT HOLDERS','(PLU = 0010020000)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName1'); FL.Add(SL[0]); FL.Add('MoneyI1'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'POSTAGE STAMPS/AEROGRAMS','((PLU Between 09000000 and 09909999) and (PLU <> 0009020095)) or ((PLU Between 109000000 and 109909999) and (PLU <> 109020095))',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName2'); FL.Add(SL[0]); FL.Add('MoneyI2'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'PHILATELIC SALES'             ,'(PLU Between 010010000 and 010019999) or (PLU Between 110010000 and 110019999)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName3'); FL.Add(SL[0]); FL.Add('MoneyI3'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'BUS TICKETS'                  ,'(PLU Between 08000010 and 08000099) or (PLU Between 108000010 and 108000099)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName4'); FL.Add(SL[0]); FL.Add('MoneyI4'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'BUS PASSES'                   ,'(PLU Between 08000100 and 08000299) or (PLU Between 108000100 and 108000299)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName5'); FL.Add(SL[0]); FL.Add('MoneyI5'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'CUSTOMS DUTIES'               ,'(PLU Between 0010000020 and 010000029) and (RecIndex) = 0',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName6'); FL.Add(SL[0]); FL.Add('MoneyI6'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'BOX RENTS (inc. locks and keys)','(PLU Between 010000001 and 010000007)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName7'); FL.Add(SL[0]); FL.Add('MoneyI7'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'DOG LICENCES'                 ,'(PLU = 010000010)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName8'); FL.Add(SL[0]); FL.Add('MoneyI8'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'I.R.C.''s'                    ,'PLU in (09020095, 109020095)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName9'); FL.Add(SL[0]); FL.Add('MoneyI9'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'TAX MAIL'                     ,'    (PLU Between 020001000 and 020004999) or (PLU Between 120001000 and 120004999)'+
                                                                                                                                                                                                                                                                      ' or (PLU Between 030000001 and 0030000003) '+
                                                                                                                                                                                                                                                                      ' or (PLU = 010030000)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName10'); FL.Add(SL[0]); FL.Add('MoneyI10'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'FRANK POST - LICENCE HOLDER'  ,'(PLU = 0010040500)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName11'); FL.Add(SL[0]); FL.Add('MoneyI11'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'FRANK POST - OTHER'           ,'(PLU Between 010040000 and 0010040099)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName12'); FL.Add(SL[0]); FL.Add('MoneyI12'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'FRANK POST - PARCEL POST'     ,'(PLU Between 010040300 and 010040399)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName13'); FL.Add(SL[0]); FL.Add('MoneyI13'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'FRANK POST - IDE'             ,'(PLU Between 010040400 and 0010040499)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName14'); FL.Add(SL[0]); FL.Add('MoneyI14'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'BULK MAIL'                    ,'(PLU Between 010040600 and 0010040699)',FP,TP,SL,Summary,True,'TxnTotal'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName15'); FL.Add(SL[0]); FL.Add('MoneyI15'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'A.S.P. VOUCHERS'              ,'PLU in(0007002500, 107002500)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName16'); FL.Add(SL[0]); FL.Add('MoneyI16'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'PHOTOCOPIES'                  ,'(PLU Between 010041000 and 010041009)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName17'); FL.Add(SL[0]); FL.Add('MoneyI17'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'BILL OF ENTRY FORMS'          ,'(PLU = 0010000030)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName18'); FL.Add(SL[0]); FL.Add('MoneyI18'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'FAX'                          ,'(PLU = 0010041010)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName19'); FL.Add(SL[0]); FL.Add('MoneyI19'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'T. SHIRTS'                    ,'(PLU Between 02000000 and 02000199) or (PLU Between 102000000 and 102000199) ',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName20'); FL.Add(SL[0]); FL.Add('MoneyI20'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'PARKING VOUCHERS'             ,'PLU in (0005000500, 105000500)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName21'); FL.Add(SL[0]); FL.Add('MoneyI21'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'TELEPHONE CARDS'              ,'(PLU Between 04000000 and 04000019) or (PLU Between 104000000 and 104000019)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName22'); FL.Add(SL[0]); FL.Add('MoneyI22'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'PRE-SCHOOL VOUCHERS'          ,'PLU in (07002000, 107002000)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName23'); FL.Add(SL[0]); FL.Add('MoneyI23'); FL.Add(CurrToStr(TV));
          finally
             StockReturns := False;
          end;
          FL.Add('MoneyI24'); FL.Add(CurrToStr(TI));
          TD:=0;
          SL.Clear; TV:=TxnRepSection(DB,'BD $ 100 X',       '(PLU = 0000510000)',FP,TP,SL,stSummary,True,'StockDec'); TD:=TD+TV;
          SL.CommaText:=SL[0]; FL.Add('DepositName1' ); FL.Add(SL[0]); FL.Add('MoneyD1' ); FL.Add(CurrToStr(TV));
          SL.Clear; TV:=TxnRepSection(DB,'BD $  50 X',       '(PLU = 0000505000)',FP,TP,SL,stSummary,True,'StockDec'); TD:=TD+TV;
          SL.CommaText:=SL[0]; FL.Add('DepositName2' ); FL.Add(SL[0]); FL.Add('MoneyD2' ); FL.Add(CurrToStr(TV));
          SL.Clear; TV:=TxnRepSection(DB,'BD $  20 X',       '(PLU = 0000502000)',FP,TP,SL,stSummary,True,'StockDec'); TD:=TD+TV;
          SL.CommaText:=SL[0]; FL.Add('DepositName3' ); FL.Add(SL[0]); FL.Add('MoneyD3' ); FL.Add(CurrToStr(TV));
          SL.Clear; TV:=TxnRepSection(DB,'BD $  10 X',       '(PLU = 0000501000)',FP,TP,SL,stSummary,True,'StockDec'); TD:=TD+TV;
          SL.CommaText:=SL[0]; FL.Add('DepositName4' ); FL.Add(SL[0]); FL.Add('MoneyD4' ); FL.Add(CurrToStr(TV));
          SL.Clear; TV:=TxnRepSection(DB,'BD $   5 X',       '(PLU = 0000500500)',FP,TP,SL,stSummary,True,'StockDec'); TD:=TD+TV;
          SL.CommaText:=SL[0]; FL.Add('DepositName5' ); FL.Add(SL[0]); FL.Add('MoneyD5' ); FL.Add(CurrToStr(TV));
          SL.Clear; TV:=TxnRepSection(DB,'BD $   2 X',       '(PLU = 0000500200)',FP,TP,SL,stSummary,True,'StockDec'); TD:=TD+TV;
          SL.CommaText:=SL[0]; FL.Add('DepositName6' ); FL.Add(SL[0]); FL.Add('MoneyD6' ); FL.Add(CurrToStr(TV));
          SL.Clear; TV:=TxnRepSection(DB,'BD $ CHEQUES',     '(PLU = 0000500250)',FP,TP,SL,stSummary,True,'StockDec'); TD:=TD+TV;
          SL.CommaText:=SL[0]; FL.Add('DepositName7' ); FL.Add(SL[0]); FL.Add('MoneyD7' ); FL.Add(CurrToStr(TV));
          SL.Clear; TV:=TxnRepSection(DB,'US $ 100 X',       '(PLU = 0000610000)',FP,TP,SL,stSummary,True,'StockDec'); TD:=TD+TV;
          SL.CommaText:=SL[0]; FL.Add('DepositName8' ); FL.Add(SL[0]); FL.Add('MoneyD8' ); FL.Add(CurrToStr(TV));
          SL.Clear; TV:=TxnRepSection(DB,'US $  50 X',       '(PLU = 0000605000)',FP,TP,SL,stSummary,True,'StockDec'); TD:=TD+TV;
          SL.CommaText:=SL[0]; FL.Add('DepositName9' ); FL.Add(SL[0]); FL.Add('MoneyD9' ); FL.Add(CurrToStr(TV));
          SL.Clear; TV:=TxnRepSection(DB,'US $  20 X',       '(PLU = 0000602000)',FP,TP,SL,stSummary,True,'StockDec'); TD:=TD+TV;
          SL.CommaText:=SL[0]; FL.Add('DepositName10'); FL.Add(SL[0]); FL.Add('MoneyD10'); FL.Add(CurrToStr(TV));
          SL.Clear; TV:=TxnRepSection(DB,'US $  10 X',       '(PLU = 0000601000)',FP,TP,SL,stSummary,True,'StockDec'); TD:=TD+TV;
          SL.CommaText:=SL[0]; FL.Add('DepositName11'); FL.Add(SL[0]); FL.Add('MoneyD11'); FL.Add(CurrToStr(TV));
          SL.Clear; TV:=TxnRepSection(DB,'US $   5 X',       '(PLU = 0000600500)',FP,TP,SL,stSummary,True,'StockDec'); TD:=TD+TV;
          SL.CommaText:=SL[0]; FL.Add('DepositName12'); FL.Add(SL[0]); FL.Add('MoneyD12'); FL.Add(CurrToStr(TV));
          SL.Clear; TV:=TxnRepSection(DB,'US $   1 X',       '(PLU = 0000600100)',FP,TP,SL,stSummary,True,'StockDec'); TD:=TD+TV;
          SL.CommaText:=SL[0]; FL.Add('DepositName13'); FL.Add(SL[0]); FL.Add('MoneyD13'); FL.Add(CurrToStr(TV));
          SL.Clear; TV:=TxnRepSection(DB,'US $ CHEQUES',     '(PLU = 0000600250)',FP,TP,SL,stSummary,True,'StockDec'); TD:=TD+TV;
          SL.CommaText:=SL[0]; FL.Add('DepositName14'); FL.Add(SL[0]); FL.Add('MoneyD14'); FL.Add(CurrToStr(TV));
          SL.Clear; TV:=TxnRepSection(DB,'COINS',            '(PLU Between 0000500001 and 0000500100) and (PLU <> 500095)',FP,TP,SL,stSummary,True,'StockDec'); TD:=TD+TV;
          SL.CommaText:=SL[0]; FL.Add('DepositName15'); FL.Add(SL[0]); FL.Add('MoneyD15'); FL.Add(CurrToStr(TV));

          SL.Clear; TV:=TxnRepSection(DB,'I.R.C.''s',        '(PLU = 500095)',FP,TP,SL,stSummary,True,'StockDec'); TD:=TD+TV;
          SL.CommaText:=SL[0]; FL.Add('DepositName16'); FL.Add(SL[0]); FL.Add('MoneyD16'); FL.Add(CurrToStr(TV));

          FL.Add('DepositName17'); FL.Add('TOTAL DEPOSITS'); FL.Add('MoneyD17'); FL.Add(CurrToStr(TD));
          SL.Clear; TV:=TxnRepSection(DB,'JAV''s (enc)',     '(PLU = 0000600096)',FP,TP,SL,Summary,True,'StockDec'); TD:=TD+TV;
          SL.CommaText:=SL[0]; FL.Add('DepositName18'); FL.Add(SL[0]); FL.Add('MoneyD18'); FL.Add(CurrToStr(TV));
          FL.Add('DepositName18'); FL.Add('TOTAL INCOME'); FL.Add('MoneyD18'); FL.Add(CurrToStr(TI));

          FL.Add('IncSumSheetTot'   ); FL.Add(CurrToStr(TI));
    //      FL.Add('Office'           ); FL.Add(UpperCase(GetGPCSRegString('OfficeInfo','Office Name','MANGROVE BAY')));
          FL.Add('Office'           ); FL.Add(UpperCase(GetGPCSRegString('OfficeInfo','Office Name','OFFICE NAME')));
          FL.Add('LocationNo'       ); FL.Add(FOfficeNo);
          FL.Add('StockHolder'      ); FL.Add(FUIEventSink.User);
          FL.Add('Date'             ); FL.Add(FromDate + ' - ' + ToDate);
          FL.Add('MachineCloseTotal'); FL.Add('');
          FL.Add('MachineOpenTotal' ); FL.Add('');
          FL.Add('PostageUsed'      ); FL.Add('');
          FL.Add('CashRegTapeTotal' ); FL.Add('');
          FL.Add('IncSumSheetTot'   ); FL.Add(CurrToStr(TI));
          FL.Add('OversShorts'      );
          if TD-TI > 0 then
             FL.Add('(+)'+CurrToStrF(TD-TI,ffNumber,2))
          else if TD-TI < 0 then
             FL.Add('(-)'+CurrToStrF(TI-TD,ffNumber,2))
          else
             FL.Add('NONE');
          //FL.Add('CopyNumber'       ); FL.Add('2nd COPY (PINK)');
          ReportPrint.PrintIncomeSummary(FL.CommaText);
          FL.Free;
          ReportPrint.Free;
          If DB <> nil then
            DB.Close;
          DB:=nil;
          SL.Free;
          Result:=TI;
          ReportParams.Stock:=nil;
          AStock:=nil;
          Exit;
       end
       else if RType = 'ATot' then
       begin
          TI:=0;
          ReportPrint:=TPrintReport.Create;
          FL:=TPackStringList.Create;
          try
            StockReturns := True;
            try
         //------------
                SL.Clear; TV:=TxnRepSection(DB,'Agency: Ag & Fish Dog Licences','(PLU = 0010000010)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
                SL.CommaText:=SL[0]; FL.Add('IncomeName1'); FL.Add(SL[0]); FL.Add('Income1'); FL.Add(CurrToStr(TV));

                SL.Clear; TV:=TxnRepSection(DB,'Agency: Customs Deposits'      ,'(PLU = 0010000020) and (RecIndex) = 0',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
                SL.CommaText:=SL[0]; FL.Add('IncomeName2'); FL.Add(SL[0]); FL.Add('Income2'); FL.Add(CurrToStr(TV));

         //         SL.Clear; TV:=TxnRepSection(DB,'AGENCY: CUSTOMS DUTIES'       ,'(PLU >= 0010000020) and (PLU < 0010000030)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
                SL.Clear; TV:=TxnRepSection(DB,'Agency: Customs Duties'       ,'(PLU = 0010000021) and (RecIndex) = 0',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
                SL.CommaText:=SL[0]; FL.Add('IncomeName3'); FL.Add(SL[0]); FL.Add('Income3'); FL.Add(CurrToStr(TV));

                SL.Clear; TV:=TxnRepSection(DB,'Agency: Education: Pre-School Vouchers'  ,'PLU in (07002000, 107002000)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
                SL.CommaText:=SL[0]; FL.Add('IncomeName4'); FL.Add(SL[0]); FL.Add('Income4'); FL.Add(CurrToStr(TV));

                SL.Clear; TV:=TxnRepSection(DB,'Agency: P T B: Bus Passes'     ,'(PLU Between 08000100 and 08000299) or (PLU Between 108000100 and 108000299)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
                SL.CommaText:=SL[0]; FL.Add('IncomeName5'); FL.Add(SL[0]); FL.Add('Income5'); FL.Add(CurrToStr(TV));

                SL.Clear; TV:=TxnRepSection(DB,'Agency: P T B: Bus Tickets'    ,'(PLU Between 08000010 and 08000099) or (PLU Between 108000010 and 108000099)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
                SL.CommaText:=SL[0]; FL.Add('IncomeName6'); FL.Add(SL[0]); FL.Add('Income6'); FL.Add(CurrToStr(TV));

                SL.Clear; TV:=TxnRepSection(DB,'Agency: Youth & Sport: After School Vouchers','PLU in (07002500, 107002500)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
                SL.CommaText:=SL[0]; FL.Add('IncomeName7'); FL.Add(SL[0]); FL.Add('Income7'); FL.Add(CurrToStr(TV));

                SL.Clear; TV:=TxnRepSection(DB,'POS: Box Rents'               ,'(PLU Between 10000001 and 10000007)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
                SL.CommaText:=SL[0]; FL.Add('IncomeName8'); FL.Add(SL[0]); FL.Add('Income8'); FL.Add(CurrToStr(TV));

                SL.Clear; TV:=TxnRepSection(DB,'POS: Frankpost: Bulk Mail'    ,'(PLU Between 10040600 and 10040699)',FP,TP,SL,Summary,True,'TxnTotal'); TI:=TI+TV;
                SL.CommaText:=SL[0]; FL.Add('IncomeName9'); FL.Add(SL[0]); FL.Add('Income9'); FL.Add(CurrToStr(TV));

                SL.Clear; TV:=TxnRepSection(DB,'POS: Frankpost: IDExpress'    ,'(PLU Between 10040400 and 10040499)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
                SL.CommaText:=SL[0]; FL.Add('IncomeName10'); FL.Add(SL[0]); FL.Add('Income10'); FL.Add(CurrToStr(TV));

                SL.Clear; TV:=TxnRepSection(DB,'POS: Frankpost: Licence Holder'    ,'(PLU = 10040500)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
                SL.CommaText:=SL[0]; FL.Add('IncomeName11'); FL.Add(SL[0]); FL.Add('Income11'); FL.Add(CurrToStr(TV));

                SL.Clear; TV:=TxnRepSection(DB,'POS: Frankpost: Other'  ,'(PLU Between 10040000 and 10040099)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
                SL.CommaText:=SL[0]; FL.Add('IncomeName12'); FL.Add(SL[0]); FL.Add('Income12'); FL.Add(CurrToStr(TV));

                SL.Clear; TV:=TxnRepSection(DB,'POS: Frankpost: Parcels' ,'(PLU Between 10040300 and 10040399)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
                SL.CommaText:=SL[0]; FL.Add('IncomeName13'); FL.Add(SL[0]); FL.Add('Income13'); FL.Add(CurrToStr(TV));

                SL.Clear; TV:=TxnRepSection(DB,'POS: Miscellaneous Receipts' ,' (PLU = 10000030) or '+	//Bill of Entry Forms
                                                                              ' (PLU Between 10041000 and 10041009)' + // photocopies
                                                                              ' (PLU = 10041010) or '+ // Fax
                                                                              ' (PLU Between 30000001 and 30000004) or '+ // Licences
                                                                              ' (PLU = 10030000) )'	//Tax Mail
                                                                              ,FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;; // Tax Mail
                SL.CommaText:=SL[0]; FL.Add('IncomeName14'); FL.Add(SL[0]); FL.Add('Income14'); FL.Add(CurrToStr(TV));

                SL.Clear; TV:=TxnRepSection(DB,'POS: Philatelic Account Holders'   ,'(PLU = 10020000)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
                SL.CommaText:=SL[0]; FL.Add('IncomeName15'); FL.Add(SL[0]); FL.Add('Income15'); FL.Add(CurrToStr(TV));

                SL.Clear; TV:=TxnRepSection(DB,'POS: Philatelic Sales'          ,'(PLU Between 10010000 and 10019999) or (PLU Between 110010000 and 110019999)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
                SL.CommaText:=SL[0]; FL.Add('IncomeName16'); FL.Add(SL[0]); FL.Add('Income16'); FL.Add(CurrToStr(TV));

                SL.Clear; TV:=TxnRepSection(DB,'POS: Retail Receipts'         ,'    (PLU Between 04000000 and 04000019) or (PLU Between 104000000 and 104000019)   '+  // Telephone cards
                                                                               ' or (PLU Between 02000000 and 02000199) or (PLU Between 102000000 and 102000199)   '+  // TShirts
                                                                               ' or (PLU in (05000500, 105000500))                     '+  // Parking vouchers
                                                                               ' or (PLU Between 20001000 and 20004999) or (PLU Between 120001000 and 120004999)   '   // Other retail items
                                                                               ,FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
                SL.CommaText:=SL[0]; FL.Add('IncomeName17'); FL.Add(SL[0]); FL.Add('Income17'); FL.Add(CurrToStr(TV));

                SL.Clear; TV:=TxnRepSection(DB,'POS: Stamps sales - includes IRCs / Aerograms' ,'(PLU Between 09000000 and 09909999) or (PLU Between 109000000 and 109909999)'
                                                                               ,FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
                SL.CommaText:=SL[0]; FL.Add('IncomeName18'); FL.Add(SL[0]); FL.Add('Income18'); FL.Add(CurrToStr(TV));

                FL.Add('IncomeName19'); FL.Add(''); FL.Add('Income19'); FL.Add('');
                SL.Clear; TV :=TxnRepSection(DB,'Money'                       ,'(PLU Between 00500000 and 00610000))'
                                                                               ,FP,TP,SL,stSummary,True,'StockDec');
                if (TV-TI) > 0 then
                begin
                   FL.Add('IncomeName20'); FL.Add('POS: Cash Over/Short (+)'); FL.Add('Income20'); FL.Add(CurrToStrF(TV-TI,ffNumber,2))
                end
                else if ( TV-TI ) < 0 then
                begin
                   FL.Add('IncomeName20'); FL.Add('POS: Cash Over/Short (-)'); FL.Add('Income20'); FL.Add(CurrToStrF(TI-TV,ffNumber,2))
                end
                else
                begin
                   FL.Add('IncomeName20'); FL.Add('POS: Cash Over/Short    '); FL.Add('Income20'); FL.Add('NONE');
                end ;


                FL.Add('IncomeName21'); FL.Add('POS: Loss on exchange'); FL.Add('Income21'); FL.Add(AdditionalInfo);
                FL.Add('Total'); FL.Add(CurrToStr(TI+StrToCurrDef(AdditionalInfo,0)));
             finally
                StockReturns := False;
             end;
          except
             On E : Exception do
                     RaiseGUIDError('{8296FFFA-C607-4CAD-852F-4321924B4C00}', E.MEssage);
          end;
          FL.Add( 'CostCentre1');  FL.Add( '47040');
          FL.Add( 'CostCentre2');  FL.Add( '22060');
          FL.Add( 'CostCentre3');  FL.Add( '22060');
          FL.Add( 'CostCentre4');  FL.Add( '27000');               
          FL.Add( 'CostCentre5');  FL.Add( '45010');
          FL.Add( 'CostCentre6');  FL.Add( '45010');
          FL.Add( 'CostCentre7');  FL.Add( '30125');
          FL.Add( 'CostCentre8');  FL.Add( IntToStr(FUIEventSink.Office+15));
          FL.Add( 'CostCentre9');  FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre10'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre11'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre12'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre13'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre14'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre15'); FL.Add( '00100');
          FL.Add( 'CostCentre16'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre17'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre18'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre19'); FL.Add( '');
          FL.Add( 'CostCentre20'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre21'); FL.Add('21000');


          FL.Add( 'IncomeObject1'); FL.Add( '7351');
          FL.Add( 'IncomeObject2'); FL.Add( '6607');
          FL.Add( 'IncomeObject3'); FL.Add( '6606');
          FL.Add( 'IncomeObject4'); FL.Add( '7621');
          FL.Add( 'IncomeObject5'); FL.Add( '7657');
          FL.Add( 'IncomeObject6'); FL.Add( '7658');
          FL.Add( 'IncomeObject7'); FL.Add( '7620');
          FL.Add( 'IncomeObject8'); FL.Add( '7815');
          FL.Add( 'IncomeObject9'); FL.Add( '7565');
          FL.Add( 'IncomeObject10'); FL.Add( '7561');
          FL.Add( 'IncomeObject11'); FL.Add( '7560');
          FL.Add( 'IncomeObject12'); FL.Add( '7563');
          FL.Add( 'IncomeObject13'); FL.Add( '7562');
          FL.Add( 'IncomeObject14'); FL.Add( '7950');
          FL.Add( 'IncomeObject15'); FL.Add( '1560');
          FL.Add( 'IncomeObject16'); FL.Add( '7512');
          FL.Add( 'IncomeObject17'); FL.Add( '7640');
          FL.Add( 'IncomeObject18'); FL.Add( '7551');
          FL.Add( 'IncomeObject19'); FL.Add( ''    );
          FL.Add( 'IncomeObject20'); FL.Add( '4654');
          FL.Add( 'IncomeObject21'); FL.Add( '4615');


          ReportPrint.OfficeName   := UpperCase(GetGPCSRegString('OfficeInfo','Office Name','OFFICE NAME')) ;
          ReportPrint.PrintDepartmentalReceipts(FL.CommaText );
          FL.Free;
          ReportPrint.Free;
          If DB <> nil then
            DB.Close;
          DB:=nil;
          SL.Free;
          Result:=TI;
          ReportParams.Stock:=nil;
          AStock:=nil;
          Exit;
       end
       else if RType = 'ATot_Old' then
       begin
          TI:=0;
          ReportPrint:=TPrintReport.Create;
          FL:=TPackStringList.Create;
          try
             SL.Clear; TV:=TxnRepSection(DB,'PHILATELIC ACCOUNT HOLDERS','(PLU = 0010020000)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName1'); FL.Add(SL[0]); FL.Add('Income1'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'STAMP SALES / I R C''S / AEROGRAMS & TAX MAIL' ,'( ((PLU >= 0009000000) and (PLU < 0009910000))'+
                                                                                              ' or (PLU = 0010030000) )',
                                                                                              FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName2'); FL.Add(SL[0]); FL.Add('Income2'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'PHILATELIC SALES'             ,'(PLU >= 0010010000) and (PLU < 0010020000)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName3'); FL.Add(SL[0]); FL.Add('Income3'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'BUS TICKETS'                  ,'(PLU >= 0008000010) and (PLU < 0008000099)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName4'); FL.Add(SL[0]); FL.Add('Income4'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'BUS PASSES'                   ,'(PLU >= 0008000100) and (PLU < 0008000300)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName5'); FL.Add(SL[0]); FL.Add('Income5'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'CUSTOMS DUTIES'               ,'(PLU >= 0010000020) and (PLU < 0010000030) and (RecIndex) = 0',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName6'); FL.Add(SL[0]); FL.Add('Income6'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'BOX RENTS'                    ,'(PLU >= 0010000001) and (PLU < 0010000008)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName7'); FL.Add(SL[0]); FL.Add('Income7'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'DOG LICENCE'                 ,'(PLU = 0010000010)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName8'); FL.Add(SL[0]); FL.Add('Income8'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'MISCELLANEOUS RECEIPTS'     ,'(PLU = 0010000030)', FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName9'); FL.Add(SL[0]); FL.Add('Income9'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'FRANK POST - LICENCE HOLDER'  ,'(PLU = 0010040500)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName10'); FL.Add(SL[0]); FL.Add('Income10'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'FRANK POST - OTHER'           ,'(PLU >= 0010040000) and (PLU < 0010040100)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName11'); FL.Add(SL[0]); FL.Add('Income11'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'FRANK POST - PARCEL POST'     ,'(PLU >= 0010040300) and (PLU < 0010040400)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName12'); FL.Add(SL[0]); FL.Add('Income12'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'FRANK POST - IDE'             ,'(PLU >= 0010040400) and (PLU < 0010040500)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName13'); FL.Add(SL[0]); FL.Add('Income13'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'BULK MAIL'                    ,'(PLU >= 0010040600) and (PLU < 0010040700)',FP,TP,SL,Summary,True,'TxnTotal'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName14'); FL.Add(SL[0]); FL.Add('Income14'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'A.S.P. VOUCHERS'              ,'(PLU = 0007002500)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName15'); FL.Add(SL[0]); FL.Add('Income15'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'PHOTO COPIES'                  ,'(PLU >= 0010041000) and (PLU < 0010041010)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName16'); FL.Add(SL[0]); FL.Add('Income16'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'FAX'                          ,'(PLU = 0010041010)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName17'); FL.Add(SL[0]); FL.Add('Income17'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'PARKING VOUCHERS'              ,'(PLU = 0005000500)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName18'); FL.Add(SL[0]); FL.Add('Income18'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'LICENCES'                      ,'((PLU >= 0030000001) and  (PLU <= 0030000004))',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName19'); FL.Add(SL[0]); FL.Add('Income19'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'RETAIL RECEIPTS'               ,'( ((PLU >= 0004000000) and (PLU < 0004000020))    '+  // Tephone cards
                                                                             ' or ((PLU >= 0002000000) and (PLU < 0002000200))  '+  // TShirts
                                                                             ' or ((PLU >= 0020001000) and (PLU < 0020005000)) )'   // Other retail items
                                                                             ,FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName20'); FL.Add(SL[0]); FL.Add('Income20'); FL.Add(CurrToStr(TV));
             SL.Clear; TV:=TxnRepSection(DB,'PRE-SCHOOL VOUCHERS'              ,'(PLU = 0007002000)',FP,TP,SL,Summary,True,'TxnLine'); TI:=TI+TV;
             SL.CommaText:=SL[0]; FL.Add('IncomeName21'); FL.Add(SL[0]); FL.Add('Income21'); FL.Add(CurrToStr(TV));
             FL.Add('IncomeName22'); FL.Add('LOSS ON EXCHANGE'); FL.Add('Income22'); FL.Add(AdditionalInfo);
             FL.Add('Total'); FL.Add(CurrToStr(TI+StrToCurrDef(AdditionalInfo,0)));

          except
          end;
          FL.Add( 'CostCentre1'); FL.Add( '23100');
          FL.Add( 'CostCentre2'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre3'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre4'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre5'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre6'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre7'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre8'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre9'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre10'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre11'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre12'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre13'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre14'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre15'); FL.Add( '30125');
          FL.Add( 'CostCentre16'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre17'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre18'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre19'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre20'); FL.Add( IntToStr(FUIEventSink.Office));
          FL.Add( 'CostCentre21'); FL.Add('27000');
          FL.Add( 'CostCentre22'); FL.Add('00100');


          FL.Add( 'IncomeObject1'); FL.Add( '1560');
          FL.Add( 'IncomeObject2'); FL.Add( '7551');
          FL.Add( 'IncomeObject3'); FL.Add( '7512');
          FL.Add( 'IncomeObject4'); FL.Add( '4752');
          FL.Add( 'IncomeObject5'); FL.Add( '4751');
          FL.Add( 'IncomeObject6'); FL.Add( '6606');
          FL.Add( 'IncomeObject7'); FL.Add( '7815');
          FL.Add( 'IncomeObject8'); FL.Add( '7350');
          FL.Add( 'IncomeObject9'); FL.Add( '7950');
          FL.Add( 'IncomeObject10'); FL.Add( '7560');
          FL.Add( 'IncomeObject11'); FL.Add( '7563');
          FL.Add( 'IncomeObject12'); FL.Add( '7562');
          FL.Add( 'IncomeObject13'); FL.Add( '7561');
          FL.Add( 'IncomeObject14'); FL.Add( '7565');
          FL.Add( 'IncomeObject15'); FL.Add( '7620');
          FL.Add( 'IncomeObject16'); FL.Add( '7055');
          FL.Add( 'IncomeObject17'); FL.Add( '7050');
          FL.Add( 'IncomeObject18'); FL.Add( '7630');
          FL.Add( 'IncomeObject19'); FL.Add( '7305');
          FL.Add( 'IncomeObject20'); FL.Add( '7640');
          FL.Add( 'IncomeObject21'); FL.Add( '7621');
          FL.Add( 'IncomeObject22'); FL.Add( '1180');

          ReportPrint.PrintDepartmentalReceipts(FL.CommaText );
          FL.Free;
          ReportPrint.Free;
          If DB <> nil then
            DB.Close;
          DB:=nil;
          SL.Free;
          Result:=TI;
          ReportParams.Stock:=nil;
          AStock:=nil;
          Exit;
       end
       else if RType = 'BotsReturns' then
       begin
          SL.Add('"Inventory Returns",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,'Cash/Cheques'      ,'Ident = ">Supervisor" and ((PLU >= 6000000) and (PLU <= 6100000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Stamps'            ,'Ident = ">Supervisor" and ((PLU >= 9010000) and (PLU <= 9019999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'BW Courier'        ,'Ident = ">Supervisor" and ((PLU >= 9118190) and (PLU <= 9118350))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Merchandise'       ,'Ident = ">Supervisor" and ((PLU >= 9118360) and (PLU <= 9118620))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Retail'            ,'Ident = ">Supervisor" and ((PLU >= 9118010) and (PLU <= 9118180))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Postal Orders'     ,'Ident = ">Supervisor" and ((PLU >= 5100000) and (PLU <= 5109999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Phil. FDC'         ,'Ident = ">Supervisor" and ((PLU >= 7000400) and (PLU <= 7000460))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Phil. Souv Sheets' ,'Ident = ">Supervisor" and ((PLU >= 7000360) and (PLU <= 7000398))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Phil. Year Packs'  ,'Ident = ">Supervisor" and ((PLU >= 7000300) and (PLU <= 7000352))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Phil. Other'       ,'Ident = ">Supervisor" and ((PLU >= 7000010) and (PLU <= 7000295))',FP,TP,SL,stDetail,False,'StockTx');
       end
       else if RType = 'BotsOrders' then
       begin
          SL.Add('"Inventory Orders",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,'Cash/Cheques'      ,'Ident = "<Supervisor" and ((PLU >= 6000000) and (PLU <= 6100000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Stamps'            ,'Ident = "<Supervisor" and ((PLU >= 9010000) and (PLU <= 9019999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'BW Courier'        ,'Ident = "<Supervisor" and ((PLU >= 9118190) and (PLU <= 9118350))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Merchandise'       ,'Ident = "<Supervisor" and ((PLU >= 9118360) and (PLU <= 9118620))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Retail'            ,'Ident = "<Supervisor" and ((PLU >= 9118010) and (PLU <= 9118180))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Postal Orders'     ,'Ident = "<Supervisor" and ((PLU >= 5100000) and (PLU <= 5109999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Phil. FDC'         ,'Ident = "<Supervisor" and ((PLU >= 7000400) and (PLU <= 7000460))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Phil. Souv Sheets' ,'Ident = "<Supervisor" and ((PLU >= 7000360) and (PLU <= 7000398))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Phil. Year Packs'  ,'Ident = "<Supervisor" and ((PLU >= 7000300) and (PLU <= 7000352))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Phil. Other'       ,'Ident = "<Supervisor" and ((PLU >= 7000010) and (PLU <= 7000295))',FP,TP,SL,stDetail,False,'StockTx');
       end
       else if RType = 'QatarOrders' then
       begin
          SL.Add('"Inventory Orders",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,'Cash/Cheques'      ,'Ident = "<Supervisor" and ((PLU >= 6000000) and (PLU <= 6100010))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Stamps'            ,'Ident = "<Supervisor" and ((PLU >= 9000015) and (PLU <= 9003000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Rev Stamps'        ,'Ident = "<Supervisor" and ((PLU >= 9100100) and (PLU <= 9150000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'IRC'               ,'Ident = "<Supervisor" and ((PLU >= 2000300) and (PLU <= 2000500))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Phone Cards'       ,'Ident = "<Supervisor" and ((PLU >= 2100030) and (PLU <= 2100100))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Stationery'        ,'Ident = "<Supervisor" and ((PLU >= 2100300) and (PLU <= 2105000))',FP,TP,SL,stDetail,False,'StockTx');
       end
       else if RType = 'QatarReturns' then
       begin
          SL.Add('"Inventory Returns",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,'Cash/Cheques'      ,'Ident = ">Supervisor" and ((PLU >= 6000000) and (PLU <= 6100000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Stamps'            ,'Ident = ">Supervisor" and ((PLU >= 9000015) and (PLU <= 9003000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Rev Stamps'        ,'Ident = ">Supervisor" and ((PLU >= 9100100) and (PLU <= 9150000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'IRC'               ,'Ident = ">Supervisor" and ((PLU >= 2000300) and (PLU <= 2000500))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Phone Cards'       ,'Ident = ">Supervisor" and ((PLU >= 2100030) and (PLU <= 2100100))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Stationery'        ,'Ident = ">Supervisor" and ((PLU >= 2100300) and (PLU <= 2105000))',FP,TP,SL,stDetail,False,'StockTx');
       end
       else if RType = 'BotsDeclaration' then
       begin
          SL.Add('"Inventory Declaration",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,'Cash/Cheques'      ,'((PLU >= 6000000) and (PLU <= 6100000))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Stamps'            ,'((PLU >= 9010000) and (PLU <= 9019999))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'BW Courier'        ,'((PLU >= 9118190) and (PLU <= 9118350))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Merchandise'       ,'((PLU >= 9118360) and (PLU <= 9118620))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Retail'            ,'((PLU >= 9118010) and (PLU <= 9118180))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Postal Orders'     ,'((PLU >= 5100000) and (PLU <= 5109999))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Phil. FDC'         ,'((PLU >= 7000400) and (PLU <= 7000460))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Phil. Souv Sheets' ,'((PLU >= 7000360) and (PLU <= 7000398))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Phil. Year Packs'  ,'((PLU >= 7000300) and (PLU <= 7000352))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Phil. Other'       ,'((PLU >= 7000010) and (PLU <= 7000295))',FP,TP,SL,stDetail,False,'StockDec');
       end
       else if RType = 'GhanaReturns' then
       begin
          SL.Add('"Inventory Returns",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,'Cash/Cheques'      ,'Ident = ">Supervisor" and ((PLU >= 6000000) and (PLU <= 6100000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Stamps'            ,'Ident = ">Supervisor" and ((PLU >= 9000001) and (PLU <= 9010000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Till Stock'        ,'Ident = ">Supervisor" and ((PLU >= 2000000) and (PLU <= 2000999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Postal Orders'     ,'Ident = ">Supervisor" and ((PLU >= 5000000) and (PLU <= 5199999))',FP,TP,SL,stDetail,False,'StockTx');
       end
       else if RType = 'GhanaOrders' then
       begin
          SL.Add('"Inventory Orders",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,'Cash/Cheques'      ,'Ident = "<Supervisor" and ((PLU >= 6000000) and (PLU <= 6100000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Stamps'            ,'Ident = "<Supervisor" and ((PLU >= 9000001) and (PLU <= 9010000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Till Stock'        ,'Ident = "<Supervisor" and ((PLU >= 2000000) and (PLU <= 2000999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Postal Orders'     ,'Ident = "<Supervisor" and ((PLU >= 5000000) and (PLU <= 5199999))',FP,TP,SL,stDetail,False,'StockTx');
       end
       else if RType = 'Returns' then
       begin
          SL.Add('"Inventory Returns",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,'Postal Orders','Ident = ">Supervisor" and ((PLU >= 5000100) and (PLU <= 5599999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Cash/Cheques' ,'Ident = ">Supervisor" and ((PLU >= 6000000) and (PLU <= 6010000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Stamps'       ,'Ident = ">Supervisor" and ((PLU >= 9000020) and (PLU <= 9099999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Stock'        ,'Ident = ">Supervisor" and (((PLU >= 2000200) and (PLU <= 2007999)) or ((PLU >= 9118001) and (PLU <= 9200000)))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Philatelic'   ,'Ident = ">Supervisor" and ((PLU >= 7000000) and (PLU <= 7100000))',FP,TP,SL,stDetail,False,'StockTx');
       end
       else if RType = 'Orders' then
       begin
          SL.Add('"Inventory Orders",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,'Postal Orders','Ident = ''<Supervisor'' and ((PLU >= 5000050) and (PLU <= 5599999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Cash'         ,'Ident = ''<Supervisor'' and ((PLU >= 6000001) and (PLU <= 6010000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Stamps'       ,'Ident = ''<Supervisor'' and ((PLU >= 9000020) and (PLU <= 9099999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Stock'        ,'Ident = ''<Supervisor'' and (((PLU >= 2000200) and (PLU <= 2007999)) or ((PLU >= 9118001) and (PLU <= 9200000)))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Philatelic'   ,'Ident = ''<Supervisor'' and ((PLU >= 7000000) and (PLU <= 7100000))',FP,TP,SL,stDetail,False,'StockTx');
       end
       else if LeftOf(RType,'Guernsey Orders') then
       begin
          OtherUser := DelimitedString(RType, ',', True); //passed using report name
          SL.Add('"Stock/Cash Orders",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,'Ordered From ' + OtherUser       ,'(Ident = ''<' + OtherUser +''')',FP,TP,SL,stDetail,False,'StockTx');
       end
       else if RType = 'Declaration' then
       begin
          SL.Add('"Inventory Declaration",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,'Postal Orders','((PLU >= 5000100) and (PLU <= 5599999))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Cash/Cheques' ,'((PLU >= 6000000) and (PLU <= 6010000))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Stamps'       ,'((PLU >= 9000020) and (PLU <= 9099999))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Stock'        ,'(((PLU >= 2000200) and (PLU <= 2007999)) or ((PLU >= 9118001) and (PLU <= 9200000)))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Philatelic'   ,'((PLU >= 7000000) and (PLU <= 7100000))',FP,TP,SL,stDetail,False,'StockDec');
       end
       else if RType = 'QatarDeclaration' then
       begin
          SL.Add('"Inventory Declaration",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,'Cash/Cheques' ,'((PLU >= 6000000) and (PLU <= 6100000))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Credit Cards' ,'((PLU >= 6100010) and (PLU <= 6100011))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Stamps'       ,'((PLU >= 9000015) and (PLU <= 9099999))',FP,TP,SL,stDetail,False,'StockDec');
//          TV:=TxnRepSection(DB,'Till Stock'   ,'(((PLU >= 2000300) and (PLU <= 2000500)) and ((PLU >= 2100030) and (PLU <= 2100600)) and ((PLU >= 9100100) and (PLU <= 9150000)))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Rev Stamps'   ,'((PLU >= 9100100) and (PLU <= 9150000))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'IRC'          ,'((PLU >= 2000300) and (PLU <= 2000500))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Phone Cards'  ,'((PLU >= 2100030) and (PLU <= 2100100))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Stationery'   ,'((PLU >= 2100300) and (PLU <= 2105000))',FP,TP,SL,stDetail,False,'StockDec');
       end
       else if RType = 'GuernseyDeclaration' then
       begin

          SL.Add('"Inventory Declaration",""');
          SL.Add('"------------------------------","------------------------------"');

          TV:=TxnRepSection(DB,'Monies                     ','((PLU >= 6000001) and (PLU <= 6005000)) or (PLU = 6009036) or (PLU = 6009045)',
                                                                                                       FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'DivBy100:Other Monies               ','((PLU >= 6009000) and (PLU <= 6009004)) or (PLU = 6000000)',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Stamps                     ','((PLU >= 9000000) and (PLU <= 9599999))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Postal Orders              ','((PLU >= 5000050) and (PLU <= 5002000))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Other Value Stock          ','((PLU >= 3000001) and (PLU <= 3005000))',FP,TP,SL,stDetail,False,'StockDec');
       end
       else if ( RType = 'GuernseyBalance') or (RType = 'EODGuernseyBalance' ) then
       begin
          SL.Add('"End of Day Balance",""');
          SL.Add('"------------------------------","------------------------------"');

          VDC:=TxnRepSection(DB,'Total Declared Monies'          ,'((PLU >= 6000001) and (PLU <= 6005000)) or (PLU = 6009036) or (PLU = 6009045)',FP,TP,SL,stSummary,False,'StockDec');
          VDM:=TxnRepSection(DB,'Total Declared Other Monies'    ,'((PLU >= 6009000) and (PLU <= 6009004)) or (PLU = 6000000)',FP,TP,SL,stSummary,False,'StockDec');
          VDS:=TxnRepSection(DB,'Total Declared Stamps'          ,'((PLU >= 9000000) and (PLU <= 9599999))',FP,TP,SL,stSummary,False,'StockDec');
          VDO:=TxnRepSection(DB,'Total Declared Postal Orders     ','((PLU >= 5000050) and (PLU <= 5002000))',FP,TP,SL,stSummary,False,'StockDec');
          VDK:=TxnRepSection(DB,'Total Declared Other Value Stock ','(((PLU >= 3000001) and (PLU <= 3005000)) or ((PLU >= 9118001) and (PLU <= 9200000)))',FP,TP,SL,stSummary,False,'StockDec');
          SL.Add('" "," "');
          VAC:=TxnRepSection(DB,'Total Monies','Prod = ''Product.Cash''',FP,TP,SL,Summary,False,'TxnTotal'' or RecType = ''StartDay');
          VAM:= StkRepSection(AStock,'Total Other Monies','6000000-6000000,6009000-6009004',SL,False);
          VAS:= StkRepSection(AStock,'Total Stamps','9000000-9599999',SL,False);
          VAO:= StkRepSection(AStock,'Total Postal Orders','5000050-5002000',SL,False);
          VAK:= StkRepSection(AStock,'Total Other Value Stock','3000001-3005000',SL,False);
          SL.Add('" "," "');
          if VAC > VDC then
             SL.Add('"Monies Shortage of","'+CurrToStrF(VAC-VDC,ffNumber, 2)+'"')
          else if VAC < VDC then
             SL.Add('"Monies Excess of","'+CurrToStrF(VDC-VAC,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Monies"," "');

          if VAM > VDM then
             SL.Add('"Other Monies Shortage of","'+CurrToStrF(VAM-VDM,ffNumber, 2)+'"')
          else if VAM < VDM then
             SL.Add('"Other Monies Excess of","'+CurrToStrF(VDM-VAM,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Other Monies"," "');

          if VAS > VDS then
             SL.Add('"Stamps Shortage of","'+CurrToStrF(VAS-VDS,ffNumber, 2)+'"')
          else if VAS < VDS then
             SL.Add('"Stamps Excess of","'+CurrToStrF(VDS-VAS,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Stamps"," "');

          if VAO > VDO then
             SL.Add('"Postal Order Shortage of","'+CurrToStrF(VAO-VDO, ffNumber, 2)+'"')
          else if VAO < VDO then
             SL.Add('"Postal Order Excess of","'+CurrToStrF(VDO-VAO,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Postal Orders"," "');

          if VAK > VDK then
             SL.Add('"Value Stock Shortage of","'+CurrToStrF(VAK-VDK,ffNumber, 2)+'"')
          else if VAK < VDK then
             SL.Add('"Value Stock Excess of","'+CurrToStrF(VDK-VAK,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Value Stock"," "');

          SL.Add('" "," "');
          SL.Add('"Total cash carried forward","'+CurrToStrF(VAC,ffNumber, 2)+'"');
          SL.Add('"Total stock carried forward","'+CurrToStrF(VAK+VAS+VAO+VAM,ffNumber, 2)+'"');

          if ( RType = 'EODGuernseyBalance' ) then
          begin
             SL.Add('" "," "');
             SL.Add('"------------------------------","------------------------------"');
             SL.Add('"Signature "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('"------------------------------","------------------------------"');
          end ;

       end
       else if ( RType = 'GuernseyOtherMoneyBalance') then
       begin
          SL.Add('"Other Money Balance",""');
          SL.Add('"------------------------------","------------------------------"');

          VDM:=TxnRepSection(DB,'Total Declared Other Monies'    ,'((PLU >= 6009000) and (PLU <= 6009004)) or (PLU = 6000000)',FP,TP,SL,stSummary,False,'StockDec');
          SL.Add('" "," "');
          VAM:= StkRepSection(AStock,'Total Other Monies','6000000-6000000,6009000-6009004',SL,False);
          SL.Add('" "," "');

          if VAM > VDM then
             SL.Add('"Other Monies Shortage of","'+CurrToStrF(VAM-VDM,ffNumber, 2)+'"')
          else if VAM < VDM then
             SL.Add('"Other Monies Excess of","'+CurrToStrF(VDM-VAM,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Other Monies"," "');

       end
       else if ( RType = 'Balance') or (RType = 'EODBalance' ) then
       begin
          SL.Add('"End of Day Balance",""');
          SL.Add('"------------------------------","------------------------------"');
          VDC:=TxnRepSection(DB,'Total Declared Monies'          ,'((PLU >= 6000000) and (PLU <= 6100000))',FP,TP,SL,stSummary,False,'StockDec');
          VDS:=TxnRepSection(DB,'Total Declared Stamps'          ,'((PLU >= 9000000) and (PLU <= 9100000))',FP,TP,SL,stSummary,False,'StockDec');
          VDO:=TxnRepSection(DB,'Total Declared Postal Orders     ','((PLU >= 5000000) and (PLU <= 5100000))',FP,TP,SL,stSummary,False,'StockDec');
          VDK:=TxnRepSection(DB,'Total Declared Other Value Stock ','(((PLU >= 2000001) and (PLU <= 2100000)) or ((PLU >= 9118001) and (PLU <= 9200000)))',FP,TP,SL,stSummary,False,'StockDec');
          SL.Add('" "," "');
          VAC:=TxnRepSection(DB,'Total Monies','Prod = ''Product.Cash''',FP,TP,SL,Summary,False,'TxnTotal'' or RecType = ''StartDay');
          VAS:= StkRepSection(AStock,'Total Stamps','9000000-9100000',SL,False);
          VAO:= StkRepSection(AStock,'Total Postal Orders','5000050-5100000',SL,False);
          VAK:= StkRepSection(AStock,'Total Other Value Stock','2000001-2105000,9118001-9200000',SL,False);
          SL.Add('" "," "');
          if VAC > VDC then
             SL.Add('"Monies Shortage of","'+CurrToStrF(VAC-VDC,ffNumber, 2)+'"')
          else if VAC < VDC then
             SL.Add('"Monies Excess of","'+CurrToStrF(VDC-VAC,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Monies"," "');

          if VAS > VDS then
             SL.Add('"Stamps Shortage of","'+CurrToStrF(VAS-VDS,ffNumber, 2)+'"')
          else if VAS < VDS then
             SL.Add('"Stamps Excess of","'+CurrToStrF(VDS-VAS,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Stamps"," "');

          if VAO > VDO then
             SL.Add('"Postal Order Shortage of","'+CurrToStrF(VAO-VDO, ffNumber, 2)+'"')
          else if VAO < VDO then
             SL.Add('"Postal Order Excess of","'+CurrToStrF(VDO-VAO,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Postal Orders"," "');

          if VAK > VDK then
             SL.Add('"Value Stock Shortage of","'+CurrToStrF(VAK-VDK,ffNumber, 2)+'"')
          else if VAK < VDK then
             SL.Add('"Value Stock Excess of","'+CurrToStrF(VDK-VAK,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Value Stock"," "');

          SL.Add('" "," "');
          SL.Add('"Total cash carried forward","'+CurrToStrF(VAC,ffNumber, 2)+'"');
          SL.Add('"Total stock carried forward","'+CurrToStrF(VAK+VAS+VAO,ffNumber, 2)+'"');


          if ( RType = 'EODBalance' ) then
          begin
             SL.Add('" "," "');
             SL.Add('"------------------------------","------------------------------"');
             SL.Add('"Signature "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('"------------------------------","------------------------------"');
          end ;
       end
       else if ( RType = 'BotsBalance') or  ( RType = 'EODBotsBalance') then
       begin
          if ( RType = 'BotsBalance') then
             SL.Add('"Trial Balance",""')
          else
             SL.Add('"End of Day Balance",""');

          SL.Add('"------------------------------","------------------------------"');
          VDC :=TxnRepSection(DB,'Total Declared Cash'         ,'((PLU >= 6000001) and (PLU <= 6010000))',FP,TP,SL,stSummary,False,'StockDec');
          VDCQ:=TxnRepSection(DB,'Total Declared Cheques'      ,'(PLU = 6100000)'                        ,FP,TP,SL,stSummary,False,'StockDec');
          VDO :=TxnRepSection(DB,'Total Declared Postal Orders','((PLU >= 5100005) and (PLU <= 5101000))',FP,TP,SL,stSummary,False,'StockDec');
          VDS :=TxnRepSection(DB,'Total Declared Stamps'       ,'(((PLU >= 9010005) and (PLU <= 9019999))or((PLU >= 9020005) and (PLU <= 9020125)))',FP,TP,SL,stSummary,False,'StockDec');
          VDK :=TxnRepSection(DB,'Total Declared Stock'        ,'((PLU >= 9118000) and (PLU <= 9118999))',FP,TP,SL,stSummary,False,'StockDec');
          VDP :=TxnRepSection(DB,'Total Declared Philatelic'   ,'((PLU >= 7000010) and (PLU <= 7000460))',FP,TP,SL,stSummary,False,'StockDec');
          SL.Add('" "," "');

          FL:=TPackStringList.Create;
          VAC := TxnRepSection(DB,'Total Cash','Prod = ''Product.Cash''',FP,TP,FL,Summary,False,'TxnTotal'' or RecType = ''StartDay');
          VACQ:= StkRepSection(AStock,'Total Cheques','6100000-6100000',FL,False);
          VAO := StkRepSection(AStock,'Total Postal Orders','5100005-5101000',FL,False);
          VAS := StkRepSection(AStock,'Total Stamps','9010005-9019999,9020005-9020125',FL,False);
          VAK := StkRepSection(AStock,'Total Stock','9118000-9118999',FL,False);
          VAP := StkRepSection(AStock,'Total Philatelic','7000010-7000460',FL,False);
          
          if (FUser = 'Supervisor') or (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then 
             SL.AddStrings(FL);
          FL.Free;
          
          SL.Add('" "," "');
          if (FUser = 'Supervisor') or (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then 
          begin
             if VAC > VDC then
                SL.Add('"Cash Shortage of","'+CurrToStrF(VAC-VDC,ffNumber, 2)+'"')
             else if VAC < VDC then
                SL.Add('"Cash Surplus of","'+CurrToStrF(VDC-VAC,ffNumber, 2)+'" "')
             else
                SL.Add('"Cash Balances"," "');
          end   
          else
          begin
             if VAC > VDC then
                SL.Add('"Cash Shortage "," "')
             else if VAC < VDC then
                SL.Add('"Cash Surplus "," "')
             else
                SL.Add('"Cash Balances"," "');
          end;
          
          if (FUser = 'Supervisor') or (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then 
          begin
             if VACQ > VDCQ then
                SL.Add('"Cheques Shortage of","'+CurrToStrF(VACQ-VDCQ,ffNumber, 2)+'"')
             else if VACQ < VDCQ then
                SL.Add('"Cheques Surplus of","'+CurrToStrF(VDCQ-VACQ,ffNumber, 2)+'" "')
             else
                SL.Add('"Cheques Balance"," "');
          end   
          else
          begin
             if VACQ > VDCQ then
                SL.Add('"Cheques Shortage "," "')
             else if VACQ < VDCQ then
                SL.Add('"Cheques Surplus "," "')
             else
                SL.Add('"Cheques Balance"," "');
          end;
          
          if (FUser = 'Supervisor') or (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then 
          begin
             if VAO > VDO then
                SL.Add('"Postal Order Shortage of","'+CurrToStrF(VAO-VDO, ffNumber, 2)+'"')
             else if VAO < VDO then
                SL.Add('"Postal Order Surplus of","'+CurrToStrF(VDO-VAO,ffNumber, 2)+'" "')
             else
                SL.Add('"Postal Orders Balance"," "');
          end   
          else
          begin
             if VAO > VDO then
                SL.Add('"Postal Order Shortage "," "')
             else if VAO < VDO then
                SL.Add('"Postal Order Surplus "," "')
             else
                SL.Add('"Postal Orders Balance"," "');
          end;
          

          if (FUser = 'Supervisor') or (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then 
          begin
             if VAS > VDS then
                SL.Add('"Stamps Shortage of","'+CurrToStrF(VAS-VDS,ffNumber, 2)+'"')
             else if VAS < VDS then
                SL.Add('"Stamps Surplus of","'+CurrToStrF(VDS-VAS,ffNumber, 2)+'" "')
             else
                SL.Add('"Stamps Balance"," "');
          end   
          else
          begin
             if VAS > VDS then
                SL.Add('"Stamps Shortage "," "')
             else if VAS < VDS then
                SL.Add('"Stamps Surplus "," "')
             else
                SL.Add('"Stamps Balance"," "');
          end;
          
          if (FUser = 'Supervisor') or (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then 
          begin
             if VAK > VDK then
                SL.Add('"Stock Shortage of","'+CurrToStrF(VAK-VDK,ffNumber, 2)+'"')
             else if VAK < VDK then
                SL.Add('"Stock Surplus of","'+CurrToStrF(VDK-VAK,ffNumber, 2)+'" "')
             else
                SL.Add('"Stock Balances"," "');
          end   
          else
          begin
             if VAK > VDK then
                SL.Add('"Stock Shortage "," "')
             else if VAK < VDK then
                SL.Add('"Stock Surplus "," "')
             else
                SL.Add('"Stock Balances"," "');
          end;
          
          if (FUser = 'Supervisor') or (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then 
          begin
             if VAP > VDP then
                SL.Add('"Philatelic Shortage of","'+CurrToStrF(VAP-VDP,ffNumber, 2)+'"')
             else if VAP < VDP then
                SL.Add('"Philatelic Surplus of","'+CurrToStrF(VDP-VAP,ffNumber, 2)+'" "')
             else
                SL.Add('"Philatelic Balances"," "');
          end                               
          else
          begin
             if VAP > VDP then
                SL.Add('"Philatelic Shortage "," "')
             else if VAP < VDP then
                SL.Add('"Philatelic Surplus "," "')
             else
                SL.Add('"Philatelic Balances"," "');
          end;
          

          SL.Add('" "," "');
          if (FUser = 'Supervisor') or (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then 
             SL.Add('"Total cash carried forward","'+CurrToStrF(VAC,ffNumber, 2)+'"');
          if (FUser = 'Supervisor') or (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then 
             SL.Add('"Total stock carried forward","'+CurrToStrF(VAK+VAS+VAO+VAP,ffNumber, 2)+'"');


          if ( RType = 'EODBotsBalance') then
          begin
             SL.Add('" "," "');
             SL.Add('"------------------------------","------------------------------"');
             SL.Add('"Signature "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('"------------------------------","------------------------------"');
          end ;
       end

       else if ( RType = 'QatarBalance') or  ( RType = 'EODQatarBalance') then
       begin
          if ( RType = 'QatarBalance') then
             SL.Add('"Trial Balance",""')
          else
             SL.Add('"End of Day Balance",""');

          SL.Add('"------------------------------","------------------------------"');
          VDC :=TxnRepSection(DB,'Total Declared Cash'         ,'((PLU >= 6000000) and (PLU <= 6050000))',FP,TP,SL,stSummary,False,'StockDec');
          VDCQ:=TxnRepSection(DB,'Total Declared Cheques'      ,'(PLU = 6100000)'                        ,FP,TP,SL,stSummary,False,'StockDec');
          VDCC:=TxnRepSection(DB,'Total Declared CCs'          ,'(PLU = 6100010)'                        ,FP,TP,SL,stSummary,False,'StockDec');
          VDS :=TxnRepSection(DB,'Total Declared Stamps'       ,'(((PLU >= 9000005) and (PLU <= 9019999)) or ((PLU >= 9020005) and (PLU <= 9020125)))',FP,TP,SL,stSummary,False,'StockDec');
          VDK :=TxnRepSection(DB,'Total Declared Till Stock'   ,'(((PLU >= 9100100) and (PLU <= 9150000)) or ((PLU >= 2000300) and (PLU <= 2100600)))',FP,TP,SL,stSummary,False,'StockDec');
          //VDP :=TxnRepSection(DB,'Total Declared Philatelic'   ,'((PLU >= 7000010) and (PLU <= 7000460))',FP,TP,SL,stSummary,False,'StockDec');
          SL.Add('" "," "');
          VAC :=TxnRepSection(DB,'Total Cash','Prod = ''Product.Cash''',FP,TP,SL,Summary,False,'TxnTotal'' or RecType = ''StartDay');
          VACQ:= StkRepSection(AStock,'Total Cheques','6100000-6100000',SL,False);
          VACC:= StkRepSection(AStock,'Total CCs','6100010-6100010',SL,False);
          VAS := StkRepSection(AStock,'Total Stamps','9000005-9019999,9020005-9020125',SL,False);
          VAK := StkRepSection(AStock,'Total Till Stock','2000300-2001000,2100030-2100600,9100100-9150000',SL,False);
//          VAP := StkRepSection(AStock,'Total Philatelic','7000010-7000460',SL,False);
          SL.Add('" "," "');
          if VAC > VDC then
             SL.Add('"Cash Shortage of","'+CurrToStrF(VAC-VDC,ffNumber, 2)+'"')
          else if VAC < VDC then
             SL.Add('"Cash Excess of","'+CurrToStrF(VDC-VAC,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Cash"," "');

          if VACQ > VDCQ then
             SL.Add('"Cheques Shortage of","'+CurrToStrF(VACQ-VDCQ,ffNumber, 2)+'"')
          else if VACQ < VDCQ then
             SL.Add('"Cheques Excess of","'+CurrToStrF(VDCQ-VACQ,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Cheques"," "');

          if VACC > VDCC then
             SL.Add('"CCs Shortage of","'+CurrToStrF(VACC-VDCC,ffNumber, 2)+'"')
          else if VACC < VDCC then
             SL.Add('"CCs Excess of","'+CurrToStrF(VDCC-VACC,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess CCs"," "');

          if VAS > VDS then
             SL.Add('"Stamps Shortage of","'+CurrToStrF(VAS-VDS,ffNumber, 2)+'"')
          else if VAS < VDS then
             SL.Add('"Stamps Excess of","'+CurrToStrF(VDS-VAS,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Stamps"," "');

          if VAK > VDK then
             SL.Add('"Stock Shortage of","'+CurrToStrF(VAK-VDK,ffNumber, 2)+'"')
          else if VAK < VDK then
             SL.Add('"Stock Excess of","'+CurrToStrF(VDK-VAK,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Stock"," "');

          //if VAP > VDP then
          //   SL.Add('"Philatelic Shortage of","'+CurrToStrF(VAP-VDP,ffNumber, 2)+'"')
          //else if VAP < VDP then
          //   SL.Add('"Philatelic Excess of","'+CurrToStrF(VDP-VAP,ffNumber, 2)+'" "')
          //else
          //   SL.Add('"Zero Excess Philatelic"," "');


          SL.Add('" "," "');
          SL.Add('"Total Cash carried forward","'+CurrToStrF(VAC,ffNumber, 2)+'"');
          SL.Add('"Total Stock carried forward","'+CurrToStrF(VAK+VAS+VAP,ffNumber, 2)+'"');
          SL.Add('"Grand Total Cash and Stock","'+CurrToStrF(VAC+VAK+VAS+VAP,ffNumber, 2)+'"');


          if ( RType = 'EODQatarBalance') then
          begin
             SL.Add('" "," "');
             SL.Add('"------------------------------","------------------------------"');
             SL.Add('"Signature "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('"------------------------------","------------------------------"');
          end ;
       end
       else if ( RType = 'GhanaBalance') or  ( RType = 'EODGhanaBalance') then
       begin
          if ( RType = 'GhanaBalance') then
             SL.Add('"Trial Balance",""')
          else
             SL.Add('"End of Day Balance",""');

          SL.Add('"------------------------------","------------------------------"');
          VDC :=TxnRepSection(DB,'Total Declared Cash'         ,'((PLU >= 6000001) and (PLU <= 6010000))',FP,TP,SL,stSummary,False,'StockDec');
          VDCQ:=TxnRepSection(DB,'Total Declared Cheques'      ,'(PLU = 6100000)'                        ,FP,TP,SL,stSummary,False,'StockDec');
          VDO :=TxnRepSection(DB,'Total Declared Postal Orders','((PLU >= 5000005) and (PLU <= 5100000))',FP,TP,SL,stSummary,False,'StockDec');
          VDS :=TxnRepSection(DB,'Total Declared Stamps'       ,'(((PLU >= 9000005) and (PLU <= 9019999))or((PLU >= 9020005) and (PLU <= 9020125)))',FP,TP,SL,stSummary,False,'StockDec');
          VDK :=TxnRepSection(DB,'Total Declared Till Stock'   ,'((PLU >= 2000301) and (PLU <= 2001000))',FP,TP,SL,stSummary,False,'StockDec');
          //VDP :=TxnRepSection(DB,'Total Declared Philatelic'   ,'((PLU >= 7000010) and (PLU <= 7000460))',FP,TP,SL,stSummary,False,'StockDec');
          SL.Add('" "," "');
          VAC :=TxnRepSection(DB,'Total Cash','Prod = ''Product.Cash''',FP,TP,SL,Summary,False,'TxnTotal'' or RecType = ''StartDay');
          VACQ:= StkRepSection(AStock,'Total Cheques','6100000-6100000',SL,False);
          VAO := StkRepSection(AStock,'Total Postal Orders','5000005-5100000',SL,False);
          VAS := StkRepSection(AStock,'Total Stamps','9000005-9019999,9020005-9020125',SL,False);
          VAK := StkRepSection(AStock,'Total Till Stock','2000300-2001000',SL,False);
          //VAP := StkRepSection(AStock,'Total Philatelic','7000010-7000460',SL,False);
          SL.Add('" "," "');
          if VAC > VDC then
             SL.Add('"Cash Shortage of","'+CurrToStrF(VAC-VDC,ffNumber, 2)+'"')
          else if VAC < VDC then
             SL.Add('"Cash Excess of","'+CurrToStrF(VDC-VAC,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Cash"," "');

          if VACQ > VDCQ then
             SL.Add('"Cheques Shortage of","'+CurrToStrF(VACQ-VDCQ,ffNumber, 2)+'"')
          else if VACQ < VDCQ then
             SL.Add('"Cheques Excess of","'+CurrToStrF(VDCQ-VACQ,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Cheques"," "');

          if VAO > VDO then
             SL.Add('"Postal Order Shortage of","'+CurrToStrF(VAO-VDO, ffNumber, 2)+'"')
          else if VAO < VDO then
             SL.Add('"Postal Order Excess of","'+CurrToStrF(VDO-VAO,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Postal Orders"," "');


          if VAS > VDS then
             SL.Add('"Stamps Shortage of","'+CurrToStrF(VAS-VDS,ffNumber, 2)+'"')
          else if VAS < VDS then
             SL.Add('"Stamps Excess of","'+CurrToStrF(VDS-VAS,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Stamps"," "');

          if VAK > VDK then
             SL.Add('"Stock Shortage of","'+CurrToStrF(VAK-VDK,ffNumber, 2)+'"')
          else if VAK < VDK then
             SL.Add('"Stock Excess of","'+CurrToStrF(VDK-VAK,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Stock"," "');

          //if VAP > VDP then
          //   SL.Add('"Philatelic Shortage of","'+CurrToStrF(VAP-VDP,ffNumber, 2)+'"')
          //else if VAP < VDP then
          //   SL.Add('"Philatelic Excess of","'+CurrToStrF(VDP-VAP,ffNumber, 2)+'" "')
          //else
          //   SL.Add('"Zero Excess Philatelic"," "');


          SL.Add('" "," "');
          SL.Add('"Total cash carried forward","'+CurrToStrF(VAC,ffNumber, 2)+'"');
          SL.Add('"Total stock carried forward","'+CurrToStrF(VAK+VAS+VAO+VAP,ffNumber, 2)+'"');
          SL.Add('"Grand Total Cash and Stock","'+CurrToStrF(VAC+VAK+VAS+VAO+VAP,ffNumber, 2)+'"');


          if ( RType = 'EODGhanaBalance') then
          begin
             SL.Add('" "," "');
             SL.Add('"------------------------------","------------------------------"');
             SL.Add('"Signature "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('"------------------------------","------------------------------"');
          end ;
       end
       else if RType = 'Cash Account' then  // Tan Cash Account
       begin
           // Philatelic Items 7000000-7100000 HAS TO BE ADDED TO CASH ACCOUNT

          if OfficeNo = '' then
          begin
             FReportTitle:='Tanzania Posts Corporation - Full Cash Account';
             CheckReportedStock:=False;
             if FromDate = ''  then
                SL.Add('"Clerk Cash Account",""');
          end
          else if Copy(OfficeNo,1,1) = '!' then
          begin
             CheckReportedStock:=True;
             FReportTitle:='Tanzania Posts Corporation - Subs Cash Account';
          end
          else if StrToIntDef(OfficeNo,-1) = FUIEventSink.Office then
          begin
             CheckReportedStock:=False;
             FReportTitle:='Tanzania Posts Corporation - GPO Cash Account';
          end
          else
          begin
             CheckReportedStock:=True;
             FReportTitle:='Tanzania Posts Corporation - Sub Cash Account';
             SL.Add('"For Office '+OfficeNo+'",""');
          end;
          SL.Add('"------------------------------","------------------------------"');
          DoFullUserSearch:=True;
          TotalReceipt :=                TxnRepSection(DB,'1   Balance B/Fwd from line 80'  ,'((PLU = 02009001) or (PLU = 61000000))',FP,FP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          DoFullUserSearch:=False;
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'2   Express Money Order Issued'  ,'((PLU = 02009002) or (PLU = 090000009))' ,FP,TP,SL,Summary,True,'TxnLine''  or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'3   Express Money Order Comm.'   ,'((PLU = 02009003) or (PLU = 000100003))' ,FP,TP,SL,Summary,True,'TxnLine''  or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'4   EMail'                       ,'((PLU = 02009004) or (PLU = 060000000))' ,FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'5   IMO Issued'                  ,'((PLU = 02009005) or (PLU = 090000012))' ,FP,TP,SL,Summary,True,'TxnLine''  or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'6   IMO Commission'              ,'((PLU = 02009006) or (PLU = 000100006))' ,FP,TP,SL,Summary,True,'TxnLine''  or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'7   IMO Advice of Delivery'      ,'((PLU = 02009007) or (PLU = 002000010))' ,FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'8   Parcel Charges Accrued'      ,'((PLU = 02009008) or (( PLU >= 042000021 ) and (PLU <= 042000024 )))' ,FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'9   Customs Duty'                ,'((PLU = 02009009) or (PLU = 002000020))' ,FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'10  EMS Money Fax Issued'        ,'((PLU = 02009010) or (PLU = 002000030))' ,FP,TP,SL,Summary,True,'TxnLine'' or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'11  EMS Money Fax Commission'    ,'((PLU = 02009011) or (PLU = 002000040))' ,FP,TP,SL,Summary,True,'TxnLine'' or RecType = ''CashAcc');
          //TotalReceipt := TotalReceipt + TxnRepSection(DB,'12  EMS Charges'                 ,'((PLU = 02009012) or (PLU = 070000001))' ,FP,TP,SL,Summary,True,'TxnLine'' or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'12  EMS Charges'                 ,'((PLU = 02009012) or (PLU =  70000020))' ,FP,TP,SL,Summary,True,'TxnLine'' or RecType = ''CashAcc');

          FL:=TPackStringList.Create;
          //TmpStock:=TxnRepSection(DB,' ','((PLU = 02009013) or (PLU = 70000020))' ,FP,TP,FL,Summary,True,'TxnLine'' or RecType = ''CashAcc');
          TmpStock:=TxnRepSection(DB,' ','(PLU = 02009013)' ,FP,TP,FL,Summary,True,'TxnLine'' or RecType = ''CashAcc');
          TmpStock:=TmpStock+TxnRepSection(DB,' ',' ( ((PLU >= 070000003 ) and (PLU <= 070000007)) or ' +
                                                  '    (PLU =  070000009 ) or                           ' +
                                                  '   ((PLU >= 070000011 ) and (PLU <= 070000013))    ' +
                                                  ' )' ,FP,TP,FL,Summary,True,'TxnTotal');
          //SL.Add('13  EMS Fax Charges","'+CurrToStrF(TmpStock, ffNumber, 2)+'"');
          SL.Add('"13  EMS Fax Message","'+CurrToStrF(TmpStock, ffNumber, 2)+'"');
          TotalReceipt := TotalReceipt + TmpStock;
          FL.Free;

          //EMS
          TmpStock:=         TxnRepSection(DB,' ','((PLU = 02009014) or (PLU = 070000001) or (PLU = 070000008))' ,FP,TP,FL,Summary,True,'TxnTotal');
          //EMSVAT
          TmpStock:=TmpStock-TxnRepSection(DB,' ','((PLU = 02009016) or (PLU = 070000002))' ,FP,TP,FL,Summary,True,'TxnLine');
          TotalReceipt := TotalReceipt + TmpStock ;

          //TotalReceipt := TotalReceipt + TxnRepSection(DB,'14  EMS Postage Charges'         ,'((PLU = 02009014) or (PLU = 070000008))' ,FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          //last one ->TotalReceipt := TotalReceipt + TxnRepSection(DB,'14  EMS Postage Charges'         ,'((PLU = 02009014) or (PLU = 070000001) or (PLU = 070000008))' ,FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          SL.Add('"14  EMS Postage Charges","'+CurrToStrF(TmpStock, ffNumber, 2)+'"');

          TotalReceipt := TotalReceipt + TxnRepSection(DB,'15  EMS Parcel Charges'          ,'((PLU = 02009015) or (PLU = 070000010))' ,FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'16  Value Added Tax (V.A.T.)'    ,'((PLU = 02009016) or (PLU = 070000002))' ,FP,TP,SL,Summary,True,'TxnLine''  or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'17  Box Bag Rental Charges'      ,'((PLU = 02009017) or ((PLU >= 30000015) and (PLU <= 30000020 )))',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'18  Postage Prepaid in Money'    ,'((PLU = 02009018) or (PLU = 002000050))' ,FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');

          //TotalReceipt := TotalReceipt + TxnRepSection(DB,'19  Telegraph Collected In.Chgs.','((PLU = 02009019) or (PLU = 002000060))' ,FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          //TotalReceipt := TotalReceipt + TxnRepSection(DB,'20  Telegraph Collected Comm.'   ,'((PLU = 02009020) or (PLU = 002000070))' ,FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'19  Giro'                        ,'((PLU = 02009019) or (PLU = 090000030))' ,FP,TP,SL,Summary,True,'TxnLine'' or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'20  Giro Commission'              ,'((PLU = 02009020) or (PLU = 090000031))' ,FP,TP,SL,Summary,True,'TxnLine'' or RecType = ''CashAcc');

          TotalReceipt := TotalReceipt + TxnRepSection(DB,'21  Postal Orders Commission'    ,'((PLU = 02009021) or (PLU = 000100021))' ,FP,TP,SL,Summary,True,'TxnLine''  or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'22  Luku Electicity Charges'     ,'((PLU = 02009022) or (PLU = 002000080))' ,FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'23  Luku Electricy Commission'   ,'((PLU = 02009023) or (PLU = 002000090))' ,FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'24  Postal Bank (TPB) Deposit'   ,'((PLU = 02009024) or (PLU = 090000001))' ,FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'25  Photocopy Charges'           ,'((PLU = 02009025) or ((PLU >= 90000021) and (PLU <= 90000023 )))',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'26  Miscellaneous Receipts'      ,'((PLU = 02009026) or ((( PLU >= 042000001 ) and (PLU <= 042000020)) or (( PLU >= 041000012 ) and (PLU <= 041000018))))',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'27  Postal Labels Printed'       ,'((PLU = 02009027) or (( PLU >= 050000001 )and (PLU <= 051000100 )))',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'28  Blank Line'                  ,'((PLU = 02009028) or (PLU = 002000100))' ,FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          if FUser = 'Supervisor' then
          begin
             DoFullUserSearch:=True;
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'29  RR Locks'                 ,'((PLU = 02009029) or (PLU = 30000013))'                         ,FP,TP,SL,Summary,True,'TxStkTo'' or RecType = ''CashAcc');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'30  RR Cash/Cheques'          ,'((PLU = 02009030) or ((PLU >= 6000001) and (PLU <= 6010000)))',FP,TP,SL,Summary,True,'TxStkTo'' or RecType = ''CashAcc');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'31  RR Stamps'                ,'((PLU = 02009031) or ((PLU >= 9010020) and (PLU <= 9118060)))',FP,TP,SL,Summary,True,'TxStkTo'' or RecType = ''CashAcc');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'32  RR Postal Orders'         ,'((PLU = 02009032) or ((PLU >= 5000100) and (PLU <= 5599999)))',FP,TP,SL,Summary,True,'TxStkTo'' or RecType = ''CashAcc');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'33  RR Phone Cards'           ,'((PLU = 02009033) or ((PLU >= 2000200) and (PLU <= 2000500)))',FP,TP,SL,Summary,True,'TxStkTo'' or RecType = ''CashAcc');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'34  RR ACG Cards'             ,'((PLU = 02009034) or ((PLU >= 9120000) and (PLU <= 9125000)))',FP,TP,SL,Summary,True,'TxStkTo'' or RecType = ''CashAcc');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'34a RR Jupiter Cards'         ,'((PLU = 02009035) or ((PLU >= 9130000) and (PLU <= 9135000)))',FP,TP,SL,Summary,True,'TxStkTo'' or RecType = ''CashAcc');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'35  RR RTD Cards'             ,'((PLU = 02009036) or ((PLU >= 9140000) and (PLU <= 9145000)))',FP,TP,SL,Summary,True,'TxStkTo'' or RecType = ''CashAcc');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'36  RR VodaCom Cards'         ,'((PLU = 02009037) or ((PLU >= 2007000) and (PLU <= 2007999)))',FP,TP,SL,Summary,True,'TxStkTo'' or RecType = ''CashAcc');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'37  RR Post Shop Items'       ,'((PLU = 02009038) or ((PLU >= 2001000) and (PLU <= 2001999)))',FP,TP,SL,Summary,True,'TxStkTo'' or RecType = ''CashAcc');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'38  RR Payment Vouchers'      ,'((PLU = 02009039) or ((PLU >= 2002000) and (PLU <= 2002999)))',FP,TP,SL,Summary,True,'TxStkTo'' or RecType = ''CashAcc');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'39  RR Blank Line'            ,'((PLU = 02009040) or ((PLU >= 2003000) and (PLU <= 2003999)))',FP,TP,SL,Summary,True,'TxStkTo'' or RecType = ''CashAcc');
             DoFullUserSearch:=False;
          end
          else
          begin
             DoFullUserSearch:=True;
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'29  RR Locks'                 ,'(PLU = 30000013 )'                        ,FP,TP,SL,Summary,True,'TxStkFrom');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'30  RR Cash/Cheques'          ,'((PLU >= 6000001) and (PLU <= 6010000))',FP,TP,SL,Summary,True,'TxStkFrom');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'31  RR Stamps'                ,'((PLU >= 9010020) and (PLU <= 9118060))',FP,TP,SL,Summary,True,'TxStkFrom');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'32  RR Postal Orders'         ,'((PLU >= 5000100) and (PLU <= 5599999))',FP,TP,SL,Summary,True,'TxStkFrom');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'33  RR Phone Cards'           ,'((PLU >= 2000200) and (PLU <= 2000500))',FP,TP,SL,Summary,True,'TxStkFrom');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'34  RR ACG Cards'             ,'((PLU >= 9120000) and (PLU <= 9125000))',FP,TP,SL,Summary,True,'TxStkFrom');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'34a RR Jupiter Cards'         ,'((PLU >= 9130000) and (PLU <= 9135000))',FP,TP,SL,Summary,True,'TxStkFrom');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'35  RR RTD Cards'             ,'((PLU >= 9140000) and (PLU <= 9145000))',FP,TP,SL,Summary,True,'TxStkFrom');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'36  RR VodaCom Cards'         ,'((PLU >= 2007000) and (PLU <= 2007999))',FP,TP,SL,Summary,True,'TxStkFrom');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'37  RR Post Shop Items'       ,'((PLU >= 2001000) and (PLU <= 2001999))',FP,TP,SL,Summary,True,'TxStkFrom');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'38  RR Payment Vouchers'      ,'((PLU >= 2002000) and (PLU <= 2002999))',FP,TP,SL,Summary,True,'TxStkFrom');
             TotalReceipt := TotalReceipt + TxnRepSection(DB,'39  RR Blank Line'            ,'((PLU >= 2003000) and (PLU <= 2003999))',FP,TP,SL,Summary,True,'TxStkFrom');
             DoFullUserSearch:=False;
          end;
          if FromDate = ToDate then  SL.Add('"",""');
          SL.Add('"40  Total Receipts (1-39)","'+CurrToStrF(TotalReceipt, ffNumber, 2)+'"');
          SL.Add('"",""');

          TotalPayment :=                TxnRepSection(DB,'41  Express Money Orders Paid'   ,'((PLU = 02009042) or (PLU = 090000011))',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalPayment := TotalPayment + TxnRepSection(DB,'42  Postal Orders Paid'          ,'((PLU = 02009043) or (PLU = 090000029))',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalPayment := TotalPayment + TxnRepSection(DB,'43  International Coupons Paid'  ,'((PLU = 02009044) or (PLU = 090000005))',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalPayment := TotalPayment + TxnRepSection(DB,'44  Postal Bank Withdrawals'     ,'((PLU = 02009045) or (PLU = 090000002))',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalPayment := TotalPayment + TxnRepSection(DB,'45  Postal Bank Excess Cash'     ,'((PLU = 02009046) or (PLU = 002005000))',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalPayment := TotalPayment + TxnRepSection(DB,'46  Schedule of Refunds'         ,'((PLU = 02009047) or (PLU = 002005010))',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalPayment := TotalPayment + TxnRepSection(DB,'47  Expenditure Schedule'        ,'((PLU = 02009048) or (PLU = 002008000))',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalPayment := TotalPayment + TxnRepSection(DB,'48  Salary Control Account'      ,'((PLU = 02009049) or (PLU = 002005030))',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalPayment := TotalPayment + TxnRepSection(DB,'49  Interstate Money Order Paid' ,'((PLU = 02009050) or (PLU = 090000014))',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalPayment := TotalPayment + TxnRepSection(DB,'50  EMS Money Fax Paid'          ,'((PLU = 02009051) or (PLU = 090000015))',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');

          DoFullUserSearch:=True;
          if FUser = 'Supervisor' then
          begin
             DoFullUserSearch:=True;
             TotalPayment := TotalPayment + TxnRepSection(DB,'51  RD Locks'                 ,'((PLU = 02009052) or ( PLU = 30000013))'                      ,FP,TP,SL,Summary,True,'TxStkFrom'' or RecType = ''CashAcc');
             TotalPayment := TotalPayment + TxnRepSection(DB,'52  RD Cash/Cheques'          ,'((PLU = 02009053) or ((PLU >= 6000001) and (PLU <= 6010000)))',FP,TP,SL,Summary,True,'TxStkFrom'' or RecType = ''CashAcc');
             TotalPayment := TotalPayment + TxnRepSection(DB,'53  RD Stamps'                ,'((PLU = 02009054) or ((PLU >= 9010020) and (PLU <= 9118060)))',FP,TP,SL,Summary,True,'TxStkFrom'' or RecType = ''CashAcc');
             TotalPayment := TotalPayment + TxnRepSection(DB,'54  RD Postal Orders'         ,'((PLU = 02009055) or ((PLU >= 5000100) and (PLU <= 5599999)))',FP,TP,SL,Summary,True,'TxStkFrom'' or RecType = ''CashAcc');
             TotalPayment := TotalPayment + TxnRepSection(DB,'55  RD Phone Cards'           ,'((PLU = 02009056) or ((PLU >= 2000200) and (PLU <= 2000500)))',FP,TP,SL,Summary,True,'TxStkFrom'' or RecType = ''CashAcc');
             TotalPayment := TotalPayment + TxnRepSection(DB,'56  RD ACG Cards'             ,'((PLU = 02009057) or ((PLU >= 9120000) and (PLU <= 9125000)))',FP,TP,SL,Summary,True,'TxStkFrom'' or RecType = ''CashAcc');
             TotalPayment := TotalPayment + TxnRepSection(DB,'56a RD Jupiter Cards'         ,'((PLU = 02009058) or ((PLU >= 9130000) and (PLU <= 9135000)))',FP,TP,SL,Summary,True,'TxStkFrom'' or RecType = ''CashAcc');
             TotalPayment := TotalPayment + TxnRepSection(DB,'57  RD RTD Cards'             ,'((PLU = 02009059) or ((PLU >= 9140000) and (PLU <= 9145000)))',FP,TP,SL,Summary,True,'TxStkFrom'' or RecType = ''CashAcc');
             TotalPayment := TotalPayment + TxnRepSection(DB,'58  RD VodaCom Cards'         ,'((PLU = 02009060) or ((PLU >= 2007000) and (PLU <= 2007999)))',FP,TP,SL,Summary,True,'TxStkFrom'' or RecType = ''CashAcc');
             TotalPayment := TotalPayment + TxnRepSection(DB,'59  RD Post Shop Items'       ,'((PLU = 02009061) or ((PLU >= 2001000) and (PLU <= 2001999)))',FP,TP,SL,Summary,True,'TxStkFrom'' or RecType = ''CashAcc');
             TotalPayment := TotalPayment + TxnRepSection(DB,'60  RD Payment Vouchers'      ,'((PLU = 02009062) or ((PLU >= 2002000) and (PLU <= 2002999)))',FP,TP,SL,Summary,True,'TxStkFrom'' or RecType = ''CashAcc');
             DoFullUserSearch:=False;
             TotalPayment := TotalPayment + TxnRepSection(DB,'61  Post Giro'                ,'((PLU = 02009063) or (PLU = 2003000))'                        ,FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
             TotalPayment := TotalPayment + TxnRepSection(DB,'62  Blank Line'               ,'((PLU = 02009064) or (PLU = 2009000))'                        ,FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          end
          else
          begin
             DoFullUserSearch:=True;
             TotalPayment := TotalPayment + TxnRepSection(DB,'51  RD Locks'                 ,'(PLU = 30000013 )'                        ,FP,TP,SL,Summary,True,'TxStkTo');
             TotalPayment := TotalPayment + TxnRepSection(DB,'52  RD Cash/Cheques'          ,'((PLU >= 6000001) and (PLU <= 6010000))',FP,TP,SL,Summary,True,'TxStkTo');
             TotalPayment := TotalPayment + TxnRepSection(DB,'53  RD Stamps'                ,'((PLU >= 9010020) and (PLU <= 9118060))',FP,TP,SL,Summary,True,'TxStkTo');
             TotalPayment := TotalPayment + TxnRepSection(DB,'54  RD Postal Orders'         ,'((PLU >= 5000100) and (PLU <= 5599999))',FP,TP,SL,Summary,True,'TxStkTo');
             TotalPayment := TotalPayment + TxnRepSection(DB,'55  RD Phone Cards'           ,'((PLU >= 2000200) and (PLU <= 2000500))',FP,TP,SL,Summary,True,'TxStkTo');
             TotalPayment := TotalPayment + TxnRepSection(DB,'56  RD ACG Cards'             ,'((PLU >= 9120000) and (PLU <= 9125000))',FP,TP,SL,Summary,True,'TxStkTo');
             TotalPayment := TotalPayment + TxnRepSection(DB,'56a RD Jupiter Cards'         ,'((PLU >= 9130000) and (PLU <= 9135000))',FP,TP,SL,Summary,True,'TxStkTo');
             TotalPayment := TotalPayment + TxnRepSection(DB,'57  RD RTD Cards'             ,'((PLU >= 9140000) and (PLU <= 9145000))',FP,TP,SL,Summary,True,'TxStkTo');
             TotalPayment := TotalPayment + TxnRepSection(DB,'58  RD VodaCom Cards'         ,'((PLU >= 2007000) and (PLU <= 2007999))',FP,TP,SL,Summary,True,'TxStkTo');
             TotalPayment := TotalPayment + TxnRepSection(DB,'59  RD Post Shop Items'       ,'((PLU >= 2001000) and (PLU <= 2001999))',FP,TP,SL,Summary,True,'TxStkTo');
             TotalPayment := TotalPayment + TxnRepSection(DB,'60  RD Payment Vouchers'      ,'((PLU >= 2002000) and (PLU <= 2002999))',FP,TP,SL,Summary,True,'TxStkTo');
             TotalPayment := TotalPayment + TxnRepSection(DB,'61  Post Giro'                ,'( PLU = 2003000  )',FP,TP,SL,Summary,True,'TxnTotal');
             TotalPayment := TotalPayment + TxnRepSection(DB,'62  Blank Line'               ,'( PLU = 2009000  )',FP,TP,SL,Summary,True,'TxnTotal');
             DoFullUserSearch:=False;
          end;
          SL.Add('63  Total Payments (41-62)","'+CurrToStrF(TotalPayment, ffNumber, 2)+'"');
          if FromDate = ToDate then  SL.Add('"",""');
          FL:=TPackStringList.Create;

    //      TotalStock :=              TxnRepSection(DB,'64  Cash on Hand' ,'((PLU = 02009066) or Prod = ''Product.Cash'')',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''StartDay'' or RecType = ''CashAcc');
    //      TotalStock := TotalStock + TxnRepSection(DB,'65  Bank'         ,'((PLU = 02009067) or (PLU = 2005090))'    ,FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');

          TotalStock :=              TxnRepRelSection(DB,'Temp.Cash on Hand' ,'((PLU = 02009066) or Prod = ''Product.Cash'')',FP,TP,FL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          DoFullUserSearch := TRUE ;
          TotalStock := TotalStock + TxnRepRelSection(DB,'Temp.Cash on Hand' ,'(PLU <> -1)',FP,TP,FL,Summary,True,'StartDay');
          DoFullUserSearch := FALSE ;

          SL.Add('"64  Cash on Hand","'         +CurrToStrF(TotalStock, ffNumber, 2)+'"');
          TotalStock := TotalStock + TxnRepSection(DB,'65  Bank'         ,'((PLU = 02009067) or (PLU = 2005090))'    ,FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');

          FL.Free;
          if CheckReportedStock then
          begin
             TotalStock := TotalStock + TxnRepSection(DB ,'66  Stamps'         ,'(PLU = 02009068)',FP,TP,SL,Summary,True,'CashAcc');
             TotalStock := TotalStock + TxnRepSection(DB ,'67  Postal Orders'  ,'(PLU = 02009069)',FP,TP,SL,Summary,True,'CashAcc');
             TotalStock := TotalStock + TxnRepSection(DB ,'68  Phone Cards'    ,'(PLU = 02009070)',FP,TP,SL,Summary,True,'CashAcc');
             TotalStock := TotalStock + TxnRepSection(DB ,'69  ACG Cards'      ,'(PLU = 02009071)',FP,TP,SL,Summary,True,'CashAcc');
             TotalStock := TotalStock + TxnRepSection(DB ,'69a Jupiter Cards'  ,'(PLU = 02009072)',FP,TP,SL,Summary,True,'CashAcc');
             TotalStock := TotalStock + TxnRepSection(DB ,'70  RTD Cards'      ,'(PLU = 02009073)',FP,TP,SL,Summary,True,'CashAcc');
             TotalStock := TotalStock + TxnRepSection(DB ,'71  VodaCom Cards'  ,'(PLU = 02009074)',FP,TP,SL,Summary,True,'CashAcc');
             TotalStock := TotalStock + TxnRepSection(DB ,'72  Philately'      ,'(PLU = 02009075)',FP,TP,SL,Summary,True,'CashAcc');
             TotalStock := TotalStock + TxnRepSection(DB ,'73  Post Shop Items','(PLU = 02009076)',FP,TP,SL,Summary,True,'CashAcc');
             TotalStock := TotalStock + TxnRepSection(DB ,'74  Locks'          ,'(PLU = 02009077)',FP,TP,SL,Summary,True,'CashAcc');
          end
          else
          begin
             FL:=TPackStringList.Create;
             TmpStock:=TxnRepSection(DB ,'','(PLU = 02009068)',FP,TP,FL,Summary,True,'CashAcc');
             TmpStock:=TmpStock+StkRepSection(AStock,'','9010020-9118060',FL,False);
             SL.Add('"66  Stamps","'         +CurrToStrF(TmpStock, ffNumber, 2)+'"');
             TotalStock := TotalStock + TmpStock;
             TmpStock:=TxnRepSection(DB ,'','(PLU = 02009069)',FP,TP,FL,Summary,True,'CashAcc');
             TmpStock:=TmpStock+StkRepSection(AStock,'','5000100-5599999',FL,False);
             SL.Add('"67  Postal Orders","'  +CurrToStrF(TmpStock, ffNumber, 2)+'"');
             TotalStock := TotalStock + TmpStock;
             TmpStock:=TxnRepSection(DB ,'','(PLU = 02009070)',FP,TP,FL,Summary,True,'CashAcc');
             TmpStock:=TmpStock+StkRepSection(AStock,'','2000200-2000500',FL,False);
             SL.Add('"68  Phone Cards","'    +CurrToStrF(TmpStock, ffNumber, 2)+'"');
             TotalStock := TotalStock + TmpStock;
             TmpStock:=TxnRepSection(DB ,'','(PLU = 02009071)',FP,TP,FL,Summary,True,'CashAcc');
             TmpStock:=TmpStock+StkRepSection(AStock,'','9120000-9125000',FL,False);
             SL.Add('"69  ACG Cards","'      +CurrToStrF(TmpStock, ffNumber, 2)+'"');
             TotalStock := TotalStock + TmpStock;
             TmpStock:=TxnRepSection(DB ,'','(PLU = 02009072)',FP,TP,FL,Summary,True,'CashAcc');
             TmpStock:=TmpStock+StkRepSection(AStock,'','9130000-9135000',FL,False);
             SL.Add('"69a Jupiter Cards","'  +CurrToStrF(TmpStock, ffNumber, 2)+'"');
             TotalStock := TotalStock + TmpStock;
             TmpStock:=TxnRepSection(DB ,'','(PLU = 02009073)',FP,TP,FL,Summary,True,'CashAcc');
             TmpStock:=TmpStock+StkRepSection(AStock,'','9140000-9145000',FL,False);
             SL.Add('"70  RTD Cards","'      +CurrToStrF(TmpStock, ffNumber, 2)+'"');
             TotalStock := TotalStock + TmpStock;
             TmpStock:=TxnRepSection(DB ,'','(PLU = 02009074)',FP,TP,FL,Summary,True,'CashAcc');
             TmpStock:=TmpStock+StkRepSection(AStock,'','2007000-2007999',FL,False);
             SL.Add('"71  VodaCom Cards","'  +CurrToStrF(TmpStock, ffNumber, 2)+'"');
             TotalStock := TotalStock + TmpStock;
             TmpStock:=TxnRepSection(DB ,'','(PLU = 02009075)',FP,TP,FL,Summary,True,'CashAcc');
             TmpStock:=TmpStock+StkRepSection(AStock,'','2006000-2006999',FL,False);
             SL.Add('"72  Philately","'      +CurrToStrF(TmpStock, ffNumber, 2)+'"');
             TotalStock := TotalStock + TmpStock;
             TmpStock:=TxnRepSection(DB ,'','(PLU = 02009076)',FP,TP,FL,Summary,True,'CashAcc');
             TmpStock:=TmpStock+StkRepSection(AStock,'','2001000-2001999',FL,False);
             SL.Add('"73  Post Shop Items","'+CurrToStrF(TmpStock, ffNumber, 2)+'"');
             TotalStock := TotalStock + TmpStock;
             TmpStock:=TxnRepSection(DB ,'','(PLU = 02009077)',FP,TP,FL,Summary,True,'CashAcc');
             TmpStock:=TmpStock+StkRepSection(AStock,'','30000013-30000013',FL,False);
             SL.Add('"74  Locks","'          +CurrToStrF(TmpStock, ffNumber, 2)+'"');
             TotalStock := TotalStock + TmpStock;
             FL.Free;

          end;
          TotalStock := TotalStock + TxnRepSection(DB   ,'75  Total Sub-Postmasters Stock','((PLU = 02009078) or (PLU = 2005100))',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalStock := TotalStock + TxnRepSection(DB   ,'76  Unclaimed Payment (Table 5)','((PLU = 02009079) or (PLU = 2005200))',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          TotalStock := TotalStock + TxnRepSection(DB   ,'77  Blank Line'                 ,'((PLU = 02009080) or (PLU = 2005300))',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          DoFullUserSearch:=False;
          SL.Add('"78  Total Stock (64-77)","'+CurrToStrF(TotalStock, ffNumber, 2)+'"');
          TV:=                       TxnRepSection(DB,'79  Less Uncharged Receipts'       ,'((PLU = 02009082) or (PLU = 2005400))',FP,TP,SL,Summary,True,'TxnTotal'' or RecType = ''CashAcc');
          SL.Add('"80  Net Total - Stock On Hand","'+CurrToStrF(TotalStock-TV, ffNumber, 2)+'"'); // Subtract Uncharged Receipts
          SL.Add('"81  Total Of Lines 63","'+CurrToStrF(TotalPayment, ffNumber, 2)+'"');
          SL.Add('"82  Total To Agree with Line 40","'+CurrToStrF(TotalPayment+(TotalStock-TV), ffNumber, 2)+'"');
       end

       else if RType = 'Ug Cash Account' then
       begin
        // **********************************************************************************************
        // *  Uganda Cash Account start                                                                 *
        // **********************************************************************************************

        // Philatelic Items 7000000-7100000 HAS TO BE ADDED TO CASH ACCOUNT
          if OfficeNo = '' then
          begin
             FReportTitle:='Posta Uganda - Full Cash Account';
             CheckReportedStock:=False;
             if FromDate = ''  then
                SL.Add('"Clerk Cash Account",""');
          end
          else if Copy(OfficeNo,1,1) = '!' then
          begin
             CheckReportedStock:=True;
             FReportTitle:='Posta Uganda - Subs Cash Account';
          end
          else if StrToIntDef(OfficeNo,-1) = FUIEventSink.Office then
          begin
             CheckReportedStock:=False;
             FReportTitle:='Posta Uganda - GPO Cash Account';
          end
          else
          begin
             CheckReportedStock:=True;
             FReportTitle:='Posta Uganda - Sub Cash Account';
             SL.Add('"For Office '+OfficeNo+'",""');
          end;
          SL.Add('"------------------------------","------------------------------"');
//          TotalReceipt:=0;
//
//          DoFullUserSearch:=True;
//                       //  Pick up the Brought Forward Record
//                       //  DoFullUserSearch:=True; means that this is for the "current" user only
//          TotalReceipt := TxnRepRelSection(DB,'Sup. Balance B/F' ,'(PLU = 061000000)',FP,TP,FL,Summary,False,'TxnTotal');
//
//          DoFullUserSearch:=False;
//                       //  Now add in the cash acc adjustment records for "Brought Forward"
//                       //  DoFullUserSearch:=False; means that this is for the all users
//          TotalReceipt := TotalReceipt + TxnRepRelSection(DB,'Cash Acc Balance B/F' ,'(PLU = 020000010)',FP,TP,FL,Summary,False,'CashAccAdj');
//
//          SL.Add('"Balance Brought Forward","'+CurrToStrF(TotalReceipt, ffNumber, 2)+'"');
//
          TotalReceipt:=0;
          DoFullUserSearch:=True;
          FL:=TPackStringList.Create;
          TotRec('Balance Brought Forward'   ,'061000000'          ,'TxnTotal' );
          //determine period of last working day before the required period
          With TStringObject.Create(QueryToPackText('Select Max(Period) from Txnlog where RecType = ''StartDay'' and Period < ' + IntToStr(FP) + UserSearch)) do
          begin
            try
              If Strings.Count > 0 then
                PrecedingPeriod := StrToIntDef(Strings[0],-1)
              else
                PrecedingPeriod := -1;
            finally
              Free;
            end;
          end;
          DoFullUserSearch:=False;
          TotalStock := TxnRepRelSection(DB,'-Cash' ,'((PLU = 020000510) or (PLU = 90000003) or Prod = ''Product.Cash'')',PrecedingPeriod,PrecedingPeriod,FL,Summary,False,'TxnTotal'' or RecType = ''CashAccAdj');
          DoFullUserSearch:=True;
          TotalStock := TotalStock + TxnRepRelSection(DB,'Temp.Cash on Hand' ,'(PLU <> -1)',PrecedingPeriod,PrecedingPeriod,FL,Summary,False,'StartDay');
          SL.Add('"-Cash and Cheques on Hand","'+CurrToStrF(TotalStock, ffNumber, 2)+'"');
          TotalStock := 0;
          FL.Free;

          DoFullUserSearch:=False;
          //stock from previous period close
          StkAtPeriodRepSection(AStock, '-Stamps'             ,'009000050-009090002',SL, False, PrecedingPeriod, DB);
          StkAtPeriodRepSection(nil   , '-Payment Vouchers'   ,'-1'                 ,SL, False, PrecedingPeriod, DB);
          StkAtPeriodRepSection(nil   , '-Postal Orders'      ,'005000100-005005000',SL, False, PrecedingPeriod, DB);
          StkAtPeriodRepSection(nil   , '-Philatelic'         ,'002000351-002000399',SL, False, PrecedingPeriod, DB);
          StkAtPeriodRepSection(nil   , '-Stationery'         ,'002000300-002000349',SL, False, PrecedingPeriod, DB);
          StkAtPeriodRepSection(nil   , '-MTN Products'       ,'002000400-002000449',SL, False, PrecedingPeriod, DB);
          StkAtPeriodRepSection(nil   , '-CelTel Products'    ,'002000450-002000499',SL, False, PrecedingPeriod, DB);

          TotRecRel('Balance B/F Adjust'   ,'020000010'          ,'CashAccAdj' );
          UGRecSubTot1 := TotalReceipt;
          SL.Add('"                Sub Total","'+CurrToStrF(UGRecSubTot1, ffNumber, 2)+'"');


          SL.Add('"------------  Receipts  ------------",""');
          TotRecRel('Money Order - Issued'      ,'020000020,040100010'          ,'TxnLine'  );
          TotRecRel('Money Order - Commission'  ,'020000030,000100003'          ,'TxnLine'  );
          TotRecRel('Money Order - other'       ,'020000040,040100040-040100100','TxnLine'  );
          TotRecRel('ISC - Issued'              ,'020000050,040200010'          ,'TxnLine'  );
          TotRecRel('ISC - Commission'          ,'020000060,000100006'          ,'TxnLine'  );
          TotRecRel('ISC - other charges'       ,'020000070,090100075-090100090','TxnLine'  );
          TotRecRel('Postal Order Commission'   ,'020000080,000100021'          ,'TxnLine'  );
          TotRecRel('Savings Bank Deposits'     ,'020000090,040400010,040400030','TxnLine'  );   // include new accounts as deposits
          TotRecRel('Domestic EMS'              ,'020000100,070100010'          ,'TxnLine'  );
          TotRecRel('Domestic EMS VAT'          ,'020000105,070100011'          ,'TxnLine'  );   // 020000105,070100011
          TotRecRel('International EMS'         ,'020000110,070200010'          ,'TxnLine'  );
          TotRecRel('International EMS VAT'     ,'020000115,070200011'          ,'TxnLine'  );   // 020000115,070200011
          TotRecRel('EMS Client Payments'       ,'020000116,070900500'          ,'TxnLine'  );   // EMS contract custs paying their bills - Data to be retrieved from CustomerTransactions table
          TotRecRel('Advice of Delivery'        ,'020000117,090100010,090100050','TxnLine'  );   // Dom,Int 090100010,090100050 <- All AOD charges
          TotRecRel('Insurance Premiums'        ,'020000118,090100040'          ,'TxnLine'  );   // Insurance premiums on parcels
          TotRecRel('Registration of Newspapers','020000120,080000010'          ,'TxnLine'  );
          TotRecRel('ForEx Receipts'            ,'020000125'                    ,'TxnLine'  );   // Not included in system - only shown as 0 on Cash Account
          TotRecRel('Enquiry Fee'               ,'020000130,080000020'          ,'TxnLine'  );
          TotRecRel('Franking Machine Payment'  ,'020000132,080000100'          ,'TxnLine'  );
          TotRecRel('E-Mail Receipts'           ,'020000133,080000110'          ,'TxnLine'  );
          TotRecRel('Bulk Mail'                 ,'020000135,060500010-060500100','TxnTotal' );   // Dom,Int,SAL Letters Paid in Cash (Bulk Mail)
          TotRecRel('Postage Pre-Paid Payment'  ,'020000136,080000090','TxnTotal' );   // Dom,Int,SAL Letters Paid in Cash (Bulk Mail)
          TotRecRel('Parcel Charges'            ,'020000137,060400010-060400030','TxnLine'  );   // ?? Parcels Paid in Cash - Probably not what should be on this line but leave here for now
          TotRecRel('Bus Ticket Sales'          ,'020000140,080000040'          ,'TxnLine'  );
          TotRecRel('Box Holders Circulars'     ,'020000150,080000060'          ,'TxnLine'  );
          TotRecRel('Private Box GPO Small'     ,'020000160,030100040'          ,'TxnLine' );
          TotRecRel('Private Box GPO Large'     ,'020000170,030100050'          ,'TxnLine' );
          TotRecRel('Private Box GPO Kampala'   ,'020000180,030100060'          ,'TxnLine' );
          TotRecRel('Private Box Head Offices'  ,'020000190,030100070'          ,'TxnLine' );
          TotRecRel('Private Box DPO''s'        ,'020000200,030100080'          ,'TxnLine' );
          TotRecRel('Private Box Sub Offices'   ,'020000210,030100090'          ,'TxnLine' );
          TotRecRel('Private Bag Kampala GPO'   ,'020000220,030100100'          ,'TxnLine'  );
          TotRecRel('Private Bag Branch Office' ,'020000225,030100110'          ,'TxnLine'  );
          TotRecRel('Private Bag DPO''s'        ,'020000230,030100120'          ,'TxnLine' );
          TotRecRel('Private Bag Sub Offices'   ,'020000240,030100130'          ,'TxnLine' );
          TotRecRel('Box Key Deposit'           ,'020000250,030100140,030100160,030100180'          ,'TxnLine' );
          TotRecRel('Box Arrears'               ,'020000255,30100195'           ,'TxnLine' );
          TotRecRel('Replace Authority Card'    ,'020000260,080000030'          ,'TxnTotal' );
          TotRecRel('New Authority Cards'       ,'020000262,080000035'          ,'TxnTotal' );
          TotRecRel('Replacement Bags/Locks'    ,'020000265,030100010,030100020,030100030','TxnTotal' ); // 030100010,030100020,030100030
          TotRecRel('VAT on Boxes and Bags'     ,'020000268,030100210,'         ,'TxnLine' );
          TotRecRel('Mail delivery charges'     ,'020000270,060600010-060600060','TxnTotal' );
          TotRecRel('Miscellaneous Receipts'    ,'020000280,080000070','TxnTotal' );
          UGRecSubTot2 := TotalReceipt - UGRecSubTot1;
          SL.Add('"                                Sub Total","'+CurrToStrF(UGRecSubTot2, ffNumber, 2)+'"');
          DoFullUserSearch:=True;
          if FUser = 'Supervisor' then
          begin
             SL.Add('"Remittances Received",""');
             TotRecRel(' - Cash'                 ,'020000290,006000002-006002000','TxStkTo'  );
             TotRecRel(' - Cheques'              ,'020000300,006000001'          ,'TxStkTo'  );
             TotRecRel(' - Cash Pension Funds'   ,'020000305'                    ,'TxStkTo'  );  // 020000305
             TotRecRel(' - Cash Principals'      ,'020000307'                    ,'TxStkTo'  );  // 020000307
             TotRecRel(' - Stamps'               ,'020000310,009000050-009090002','TxStkTo'  );
             TotRecRel(' - Payment Vouchers'     ,'020000315,040300020'          ,'TxStkTo'  );  // 020000525,040300020
             TotRecRel(' - Postal Orders'        ,'020000320,005000100-005005000','TxStkTo'  );
             TotRecRel(' - Philatelic'           ,'020000540,002000351-002000399','TxStkTo'  );
             TotRecRel(' - Stationery'           ,'020000330,002000300-002000349','TxStkTo'  );
             TotRecRel(' - MTN Products'         ,'020000340,002000400-002000449','TxStkTo'  );
             TotRecRel(' - CelTel Products'      ,'020000345,002000450-002000499','TxStkTo'  );
          end
          else
          begin
             SL.Add('"Received from Strong Room",""');
             TotRecRel(' - Cash'                 ,'020000290,006000002-006002000','TxStkFrom');
             TotRecRel(' - Cheques'              ,'020000300,006000001'          ,'TxStkFrom');
             TotRecRel(' - Cash Pension Funds'   ,'020000305'                    ,'TxStkFrom');  // 020000305
             TotRecRel(' - Cash Principals'      ,'020000307'                    ,'TxStkFrom');  // 020000307
             TotRecRel(' - Stamps'               ,'020000310,009000050-009090002','TxStkFrom');
             TotRecRel(' - Payment Vouchers'     ,'020000315,040300020'          ,'TxStkFrom');  //
             TotRecRel(' - Postal Orders'        ,'020000320,005000100-005005000','TxStkFrom');
             TotRecRel(' - Philatelic'           ,'020000540,002000351-002000399','TxStkFrom');
             TotRecRel(' - Stationery'           ,'020000330,002000300-002000349','TxStkFrom');
             TotRecRel(' - MTN Products'         ,'020000340,002000400-002000449','TxStkFrom');
             TotRecRel(' - CelTel Products'      ,'020000345,002000450-002000499','TxStkFrom');
          end;
          DoFullUserSearch:=False;
          UGRecSubTot3 := TotalReceipt - UGRecSubTot2 - UGRecSubTot1;
          SL.Add('"                                Sub Total","'+CurrToStrF(UGRecSubTot3, ffNumber, 2)+'"');
          if FromDate = ToDate then  SL.Add('"",""');
          SL.Add('"Total Receipts","'+CurrToStrF(TotalReceipt, ffNumber, 2)+'"');
          SL.Add('"",""');

          // Payments
          SL.Add('"------------  Payments  ------------",""');
          TotalPayment:=0;
          TotPayRel('Money Orders Paid'         ,'020000350,040100015-040100020','TxnTotal' );
          TotPayRel('Money Order Refund'        ,'020000360,040100030'          ,'TxnTotal' );
          TotPayRel('ISC - Paid'                ,'020000370,040200060'          ,'TxnTotal' );
          TotPayRel('ISC - Refund'              ,'020000380,040200020'          ,'TxnTotal' );
          TotPayRel('Postal Orders Paid'        ,'020000390,040200040'          ,'TxnTotal' );
          TotPayRel('Postal Orders Refund'      ,'020000400,040200050'          ,'TxnTotal' );
          TotPayRel('Savings Bank Withdrawal'   ,'020000410,040400020'          ,'TxnTotal' );
          TotPayRel('Pension Fund Payments'     ,'020000420,040300010'          ,'TxnTotal' );
        //  TotPayRel('Money Fax Payments'        ,'020000425'                    ,'TxnTotal' );   // ?? Is this to be included
          TotPayRel('Bus Ticket Refund'         ,'020000430,080000050'          ,'TxnTotal' );
          TotPayRel('Expenditure Schedule'      ,'020000432'                    ,'TxnLine'  );   // Not included in system - only shown as 0 on Cash Account          TotPay('Miscellaneous Payments'    ,'020000440,080000080'          ,'TxnTotal' );
          TotPayRel('Payment Vouchers Redeemed' ,'020000434,040300020'          ,'TxnTotal' );
          TotPayRel('Miscellaneous Payments'    ,'020000440,80000080'           ,'TxnTotal' );

          UGPaySubTot1 := TotalPayment;
          SL.Add('"                                Sub Total","'+CurrToStrF(UGPaySubTot1, ffNumber, 2)+'"');

          DoFullUserSearch:=True;
          if FUser = 'Supervisor' then
          begin
             SL.Add('"Remittances Dispatched",""');
             TotPayRel(' - Cash'                 ,'020000450,006000002-006002000','TxStkFrom');
             TotPayRel(' - Cheques'              ,'020000460,006000001'          ,'TxStkFrom');
             TotPayRel(' - Cash Principals'      ,'020000462'                    ,'TxStkFrom');   //
             TotPayRel(' - Bank UPL'             ,'020000464'                    ,'TxStkFrom');   //
             TotPayRel(' - Bank Principals'      ,'020000466'                    ,'TxStkFrom');   //
             TotPayRel(' - Stamps'               ,'020000470,009000050-009090002','TxStkFrom');
             TotPayRel(' - Payment Vouchers'     ,'020000475,040300020'          ,'TxStkFrom');   //
             TotPayRel(' - Postal Orders'        ,'020000480,005000100-005005000','TxStkFrom');
             TotPayRel(' - Philatelic'           ,'020000540,002000351-002000399','TxStkFrom');
             TotPayRel(' - Stationery'           ,'020000490,002000300-002000349','TxStkFrom');
             TotPayRel(' - MTN Products'         ,'020000500,002000400-002000449','TxStkFrom');
             TotPayRel(' - CelTel Products'      ,'020000505,002000450-002000499','TxStkFrom');
          end
          else
          begin
             SL.Add('"Returned to Strong Room",""');
             TotPayRel(' - Cash'                 ,'020000450,006000002-006002000','TxStkTo'  );
             TotPayRel(' - Cheques'              ,'020000460,006000001'          ,'TxStkTo'  );
             TotPayRel(' - Cash Principals'      ,'020000462'                    ,'TxStkTo'  );   //
             TotPayRel(' - Bank UPL'             ,'020000464'                    ,'TxStkTo'  );   //
             TotPayRel(' - Bank Principals'      ,'020000466'                    ,'TxStkTo'  );   //
             TotPayRel(' - Stamps'               ,'020000470,009000050-009090002','TxStkTo'  );
             TotPayRel(' - Payment Vouchers'     ,'020000475,040300020'          ,'TxStkTo'  );   //
             TotPayRel(' - Postal Orders'        ,'020000480,005000100-005005000','TxStkTo'  );
             TotPayRel(' - Philatelic'           ,'020000540,002000351-002000399','TxStkTo'  );
             TotPayRel(' - Stationery'           ,'020000490,002000300-002000349','TxStkTo'  );
             TotPayRel(' - MTN Products'         ,'020000500,002000400-002000449','TxStkTo'  );
             TotPayRel(' - CelTel Products'      ,'020000505,002000450-002000499','TxStkTo');
          end;
          DoFullUserSearch:=False;
          UGPaySubTot2 := TotalPayment - UGPaySubTot1;
          SL.Add('"                                Sub Total","'+CurrToStrF(UGPaySubTot2, ffNumber, 2)+'"');
          SL.Add('"Total Payments","'+CurrToStrF(TotalPayment, ffNumber, 2)+'"');
          if FromDate = ToDate then  SL.Add('"",""');

          FL:=TPackStringList.Create;                                          // SubCashAcc Cash      |     Cash         |      Cheques
        // original // TotalStock :=              TxnRepRelSection(DB,'Temp.Cash on Hand' ,'((PLU = 020000510) or (PLU = 90000003) or (PLU = 90000004) or Prod = ''Product.Cash'')',FP,TP,FL,Summary,False,'TxnTotal'' or RecType = ''CashAccAdj');
          TotalStock :=              TxnRepRelSection(DB,'Temp.Cash on Hand' ,'((PLU = 020000510) or (PLU = 90000003) or Prod = ''Product.Cash'')',FP,TP,FL,Summary,False,'TxnTotal'' or RecType = ''CashAccAdj');
          DoFullUserSearch:=True;
          TotalStock := TotalStock + TxnRepRelSection(DB,'Temp.Cash on Hand' ,'(PLU <> -1)',FP,TP,FL,Summary,False,'StartDay');
          TotStS('Cheques','6000001'); //cheques from stock not txnlog
          DoFullUserSearch:=False;
          TotStS('','6000000-6000000');
          //  Value is incorrect if CashAcc is done for >= 2 days (correct for 1 day)
          //  Possibly a general problem. (check temp cash on hand lines)
          SL.Add('"",""');
          SL.Add('"----------  Stock on Hand  ----------",""');
          SL.Add('"Cash and cheques on Hand","'+CurrToStrF(TotalStock, ffNumber, 2)+'"');
          FL.Free;

          if CheckReportedStock then
          begin
             TotStk('Stamps'           ,'020000520');
             TotStk('Payment Vouchers' ,'020000525');
             TotStk('Postal Orders'    ,'020000530');
             TotStk('Philatelic'       ,'020000540');
             TotStk('Stationery'       ,'020000550');
             TotStk('MTN Products'     ,'020000560');
             TotStk('CelTel Products'  ,'020000565');
             TotStk('Bills Paid'       ,'020000570');
             TotStk('Cash transferred' ,'020000580');
          end
          else
          begin
             TotStM('Bank UPL'           ,'020000464','-1' );                         // ??  info reqd
             TotStM('Bank Cash Principal','020000466','-1' );                         // ??  info reqd
             TotStM('Stamps'             ,'020000520,','009000050-009090002');
             TotStM('Payment Vouchers'   ,'020000525','-1'                 );  // 020000525,040300020
             TotStM('Postal Orders'      ,'020000530','005000100-005005000');
             TotStM('Philatelic'         ,'020000540','002000351-002000399');
             TotStM('Stationery'         ,'020000550','002000300-002000349');
             TotStM('MTN Products'       ,'020000560','002000400-002000449');
             TotStM('CelTel Products'    ,'020000565','002000450-002000499');
//             TotStM('EMS Client Receipts','-1','-1' );                         // Payments made to EMS contract customers - Data to be retrieved from CustomerTransactions table
//             TotStM('Bills Paid'         ,'020000570','-1');
//             TotStM('Cash transferred'   ,'020000580','-1');
          end;
          DoFullUserSearch:=False;
          SL.Add('"Total Stock ","'+CurrToStrF(TotalStock, ffNumber, 2)+'"');

          SL.Add('"",""');
          SL.Add('"----------  Stock Sales  ----------",""');

// this commented out section shows all itemised stock sales
//          TxnRepSection(DB,'Stock',
//               '(((PLU >= 2000200) and (PLU <= 2007999)) or ((PLU >= 9020022) and (PLU <= 9200000)))',
//               FP,TP,SL,stDetail,False,'TxnTotal');

          TotalReceipt := 0;

          TotRecRel('Stamps','020000520,009000020-009099999','StockUsed' );
          TotRecRel('Postal Orders','020000530,005000100-005005000','StockUsed' );
          TotRecRel('Philatelic','020000540,002000351-002000359','StockUsed' );
          TotRecRel('Stationery','020000550,002000200-002000349','StockUsed' );
          TotRecRel('MTN Products','020000560,002000400-002000449','StockUsed' );
          TotRecRel('CelTel Products','020000565,002000450-002000499','StockUsed' );

          SL.Add('"","----------"');
          SL.Add('"Total Stock Sales Value","'+CurrToStrF(TotalReceipt, ffNumber, 2)+'"');

       //*********************************************************************************************
       //*  Uganda Cash Account finish                                                               *
       //*********************************************************************************************
       end
       else if RType = 'Ghana Cash Account' then
       begin
        // **********************************************************************************************
        // *  Ghana Cash Account start                                                                 *
        // **********************************************************************************************
          if OfficeNo = '' then
          begin
             FReportTitle:='Ghana Post - Full Cash Account';
             CheckReportedStock:=False;
             if FromDate = ''  then
                SL.Add('"Clerk Cash Account",""');
          end
          else if StrToIntDef(OfficeNo,-1) = FUIEventSink.Office then
          begin
             CheckReportedStock:=False;
             FReportTitle:='Ghana - GPO Cash Account';
          end;
          SL.Add('"BROUGHT FORWARD",""');
          SL.Add('"__________________________________________",""');
          TotalReceipt:=0;
          TotalPayment:=0;
          TotalStock := 0;

          TotalReceipt:=0;
          DoFullUserSearch:=False;
          FL:=TPackStringList.Create;
          TotalStock := TxnRepRelSection(DB,'-Cash' ,'((PLU = 90000003) or Prod = ''Product.Cash'')',FP-1,FP-1,FL,Summary,False,'TxnTotal'' or RecType = ''CashAccAdj');
          DoFullUserSearch:=True;
          TotalStock := TotalStock + TxnRepRelSection(DB,'Temp.Cash on Hand' ,'(PLU <> -1)',FP-1,FP-1,FL,Summary,False,'StartDay');
          SL.Add('"Cash","'+CurrToStrF(TotalStock, ffNumber, 2)+'"');
          FL.Free;
          DoFullUserSearch:=False;

          //stock from previous period close
      //    StkAtPeriodRepSection(AStock, 'Cash'               ,'-1'                              ,SL, False, FP-1, DB);
          StkAtPeriodRepSection(AStock, 'Cheques'            ,'6100000'                         ,SL, False, FP-1, DB);
          StkAtPeriodRepSection(nil   , 'Stamps'             ,'9000100-9005000'                 ,SL, False, FP-1, DB);
          StkAtPeriodRepSection(nil   , 'Postal Orders'      ,'5000500-5100000'                 ,SL, False, FP-1, DB);
          StkAtPeriodRepSection(nil   , 'Till Stock'         ,'2000300-2000399'                 ,SL, False, FP-1, DB);
          StkAtPeriodRepSection(nil   , 'Tel Cards'          ,'2000400-2000499'                 ,SL, False, FP-1, DB);
          DoFullUserSearch := True;
          if FUser = 'Supervisor' then
          begin
             StkAtPeriodRepSection(nil   , 'Post Shop Stock'    ,'2010010-2020000'                 ,SL, False, FP-1, DB);
             StkAtPeriodRepSection(nil   , 'Philatelic Stock'   ,'7000010-7999999'                 ,SL, False, FP-1, DB);
          end;
      //    TotRecRel('Balance B/F Adjust'                     ,'020000010'                       ,'CashAccAdj' );
      //    SL.Add('"__________________________________________",""');
          TotRec('TOTAL BROUGHT FORWARD'                     ,'061000000'                       ,'TxnTotal' );
          SL.Add('"__________________________________________",""');
          SL.Add('"RECEIPTS",""');
          if FUser = 'Supervisor' then
            SL.Add('"___________ Remittances Received ___________",""')
          else
            SL.Add('"___________ Stock Sent _____________________",""');
          SubTotal := TotalReceipt;
          TotRecRel('Cash'                               ,'6000001-6020000'                     ,'TxStkTo' );
          TotRecRel('Stamps'                             ,'9000100-9005000'                     ,'TxStkTo' );
          TotRecRel('Postal Orders'                      ,'5000500-5100000'                     ,'TxStkTo' );
          TotRecRel('Till Stock'                         ,'2000300-2000399'                     ,'TxStkTo' );
          TotRecRel('Tel Cards'                          ,'2000400-2000499'                     ,'TxStkTo' );
          if FUser = 'Supervisor' then
          begin
             TotRecRel('Post Shop Stock'                    ,'2010010-2020000'                     ,'TxStkTo' );
             TotRecRel('Philatelic Stock'                   ,'7000010-7999999'                     ,'TxStkTo' );
          end;
          SL.Add('"Sub-Total","' + CurrToStrF(TotalReceipt-SubTotal,ffNumber,CurrencyDecimals) + '"');
          SubTotal := TotalReceipt; //total at this point
          DoFullUserSearch := False;
          SL.Add('"_______________ Mail Services _______________",""');
          TotRecRel('Dom. Business Mail'                 ,'50100010'                            ,'TxnLine' );
          TotRecRel('Int. Business Mail'                 ,'60500010'                            ,'TxnLine' );
          TotRecRel('Dom. EMS'                           ,'70000010,70000011'                   ,'TxnLine' ); {inc VAT}
          TotRecRel('Int. EMS'                           ,'70000020,70000021'                   ,'TxnLine' ); {inc VAT}
          TotRecRel('EMS Account Payment'                ,'70000030'                            ,'TxnLine' );
          TotRecRel('Kwikpost Items'                     ,'50100060,50100061,60100070' {inc VAT},'TxnLine' );
          TotRecRel('Items Delivery'                     ,'60600010,60600020,60600030,60600040,60600050' ,'TxnTotal' );
          TotRecRel('Stamps Sales'                       ,'9000100-9005000'                     ,'TxnLine' );
//          TotRecRel('Postage Labels'                     ,'50100010-050100050,050100070-50100310,60500010,60100010-60100230' ,'TxnLine' );
          TotRecRel('Int. Reply Coupons'                 ,'50200070'                            ,'TxnLine' );
          TotRecRel('Direct Mail'                        ,'50200030'                            ,'TxnLine' );
          TotRecRel('Franking Machines'                  ,'50200040'                            ,'TxnLine' );
          TotRecRel('Door To Door Service Renewal'       ,'50200050'                            ,'TxnLine' );
          SL.Add('"Sub-Total","' + CurrToStrF(TotalReceipt-SubTotal,ffNumber,CurrencyDecimals) + '"');
          SubTotal := TotalReceipt; //total at this point
          SL.Add('"__________ Communications Centre __________",""');
          TotRecRel('Send & Receive Fax'                 ,'90300010,90300020'                   ,'TxnLine' );
          TotRecRel('Photocopies'                        ,'90300030'                            ,'TxnLine' );
          TotRecRel('Telephone Calls'                    ,'90300040'                            ,'TxnLine' );
          TotRecRel('Internet Services'                  ,'90300050'                            ,'TxnLine' );
          TotRecRel('Photo Booth'                        ,'90300060'                            ,'TxnLine' );
          TotRecRel('Student Project Service'            ,'90300070'                            ,'TxnLine' );
          SL.Add('"Sub-Total","' + CurrToStrF(TotalReceipt-SubTotal,ffNumber,CurrencyDecimals) + '"');
          SubTotal := TotalReceipt; //total at this point
          SL.Add('"______________ Money Services _____________",""');
          TotRecRel('Postal Order Sales'                 ,'5000000-6000000'                     ,'TxnLine' );
          TotRecRel('Postal Order Commission'            ,'40210000'                            ,'TxnLine' );
          SL.Add('"Sub-Total","' + CurrToStrF(TotalReceipt-SubTotal,ffNumber,CurrencyDecimals) + '"');
          SubTotal := TotalReceipt; //total at this point
          SL.Add('"______________ PO Boxes/Bags ______________",""');
          TotRecRel('P.O. Boxes'                         ,'30100200,30100210,30100220,30100230,30100240,30100270,30100280' ,'TxnLine' );
          TotRecRel('P.O. Bags'                          ,'30100290-30100292'                   ,'TxnLine' );
          SL.Add('"Sub-Total","' + CurrToStrF(TotalReceipt-SubTotal,ffNumber,CurrencyDecimals) + '"');
          SubTotal := TotalReceipt; //total at this point
          SL.Add('"______________ Agency Services _____________",""');
//          TotRecRel('Telephone Cards'                    ,'2000400-2000500'                     ,'TxnLine' );
          TotRecRel('Passport Forms'                     ,'40300110'                            ,'TxnLine' );
          TotRecRel('Drivers Licence Forms'              ,'40300120'                            ,'TxnLine' );
          TotRecRel('TV Licences'                       ,'40300130'                            ,'TxnLine' );
          TotRecRel('SIC Car Insurance'                  ,'40300140'                            ,'TxnLine' );
          TotRecRel('Government Bonds'                   ,'40300150'                            ,'TxnLine' );
          TotRecRel('Savings Certificates'               ,'40300160'                            ,'TxnLine' );
          TotRecRel('Newspaper Registration'             ,'40300170'                            ,'TxnLine' );
          SL.Add('"Sub-Total","' + CurrToStrF(TotalReceipt-SubTotal,ffNumber,CurrencyDecimals) + '"');
          SubTotal := TotalReceipt; //total at this point
          SL.Add('"_______________ Bill Payments _______________",""');
          TotRecRel('DSTv Subscriptions'                 ,'40300010'                            ,'TxnLine' );
          TotRecRel('ECG Electricity Bills'              ,'40300020'                            ,'TxnLine' );
          TotRecRel('Water Bills'                        ,'40300030'                            ,'TxnLine' );
          TotRecRel('Ghana Telecom Bills'                ,'40300040'                            ,'TxnLine' );
          SL.Add('"Sub-Total","' + CurrToStrF(TotalReceipt-SubTotal,ffNumber,CurrencyDecimals) + '"');
          SubTotal := TotalReceipt; //total at this point
          SL.Add('"__________________________________________",""');
          TotRecRel('Till Stock Sales'                   ,'2000300-2000399'                     ,'TxnLine' );
          TotRecRel('Tel Card Sales'                     ,'2000400-2000499'                     ,'TxnLine' );
          if FUser = 'Supervisor' then
          begin
             TotRecRel('Post Shop Sales'                    ,'2010010-2020000'                     ,'TxnLine' );
             TotRecRel('Philatelic Items'                   ,'7000010-7999999'                     ,'TxnLine' );
          end;
          SL.Add('"Sub-Total","' + CurrToStrF(TotalReceipt-SubTotal,ffNumber,CurrencyDecimals) + '"');
          SL.Add('" ",""');
          TotRecRel('50 Cedis adjustment'                ,'002009390,1000001,1000004','TxnLine'  );
          SL.Add('"",""');
          if FUser = 'Supervisor' then
             TotRecRel('Miscellaneous Receipts'            ,'80000070'                            ,'TxnLine' );
          //   SL.Add('"__________________________________________",""');
          SL.Add('"TOTAL RECEIPTS","'+CurrToStrF(TotalReceipt, ffNumber, 2)+'"');
          SL.Add('"__________________________________________",""');
          SL.Add('"PAYMENTS",""');
          SubTotal := 0;
          TotPayRel('Money Order Paid - Foreign'         ,'40100015'                            ,'TxnLine' );
          TotPayRel('P.O. Paid - Inland'                 ,'40200040'                            ,'TxnLine' );
          TotPayRel('P.O. Paid - UK'                     ,'40200050'                            ,'TxnLine' );
          TotPayRel('Redeem Int. Reply Coupon'           ,'50200060'                            ,'TxnLine' );
          SL.Add('"Sub-Total","' + CurrToStrF(TotalPayment-SubTotal,ffNumber,CurrencyDecimals) + '"');
          SubTotal := TotalPayment; //total at this point
          DoFullUserSearch := True;
          if FUser = 'Supervisor' then
          begin
            SL.Add('"___________ Remittances Sent _____________",""');
            TotPayRel('Cash'                               ,'6000000-6020000'                     ,'TxStkFrom' );
            TotPayRel('Cheques'                            ,'6100000'                             ,'TxStkFrom' );
            TotPayRel('Stamps'                             ,'9000100-9005000'                     ,'TxStkFrom' );
            TotPayRel('Postal Orders'                      ,'5000500-5100000'                     ,'TxStkFrom' );
            TotPayRel('Till Stock'                         ,'2000300-2000399'                     ,'TxStkFrom' );
            TotPayRel('Tel Cards'                          ,'2000400-2000499'                     ,'TxStkFrom' );
            TotPayRel('Post Shop Stock'                    ,'2010010-2020000'                     ,'TxStkFrom' );
            TotPayRel('Philatelic Stock'                   ,'7000010-7999999'                     ,'TxStkFrom' )
          end
          else
          begin
            SL.Add('"_____ Stock/Cash Returned to Supervisor ____",""');
            TotPayRel('Cash'                               ,'6000000-6020000'                     ,'TxStkTo' );
            TotPayRel('Cheques'                            ,'6100000'                             ,'TxStkTo' );
            TotPayRel('Stamps'                             ,'9000100-9005000'                     ,'TxStkTo' );
            TotPayRel('Postal Orders'                      ,'5000500-5100000'                     ,'TxStkTo' );
            TotPayRel('Till Stock'                         ,'2000300-2000399'                     ,'TxStkTo' );
            TotPayRel('Tel Cards'                          ,'2000400-2000499'                     ,'TxStkTo' );
          end;
          DoFullUserSearch := False;
          SL.Add('"Sub-Total","' + CurrToStrF(TotalPayment-SubTotal,ffNumber,CurrencyDecimals) + '"');
          SL.Add('" ",""');
          TotPayRel('50 Cedis adjustment'                ,'002009720,1000002-1000003','TxnLine'  );
          SL.Add('"",""');
          if FUser = 'Supervisor' then
            TotRecRel('Miscellaneous Payments'             ,'80000080'                            ,'TxnLine' );

       //   SL.Add('"__________________________________________",""');
          SL.Add('"TOTAL PAYMENTS","'+CurrToStrF(TotalPayment, ffNumber, 2)+'"');
          SL.Add('"__________________________________________",""');
         // SL.Add('"CASH ON HAND",""');

          FL:=TPackStringList.Create;                                          //      Cash
          TotalStock :=              TxnRepRelSection(DB,'Temp.Cash on Hand' ,'((PLU = 90000003) or Prod = ''Product.Cash'')',FP,TP,FL,Summary,False,'TxnTotal'' or RecType = ''CashAccAdj');
          DoFullUserSearch:=True;
          TotalStock := TotalStock + TxnRepRelSection(DB,'Temp.Cash on Hand' ,'(PLU <> -1)',FP,TP,FL,Summary,False,'StartDay');
          DoFullUserSearch:=False;
          //  Value is incorrect if CashAcc is done for >= 2 days (correct for 1 day)
          //  Possibly a general problem. (check temp cash on hand lines)
          SL.Add('"Cash On Hand","'+CurrToStrF(TotalStock, ffNumber, 2)+'"');
          TotStS('Cheques','6100000-6100000'); //cheques from stock not txnlog
          SL.Add('"Cheques On Hand","'+CurrToStrF(StkRepSection(AStock,'Cheques','6100000',FL,False), ffNumber, 2)+'"');
          SL.Add('"TOTAL CASH ON HAND","'+CurrToStrF(TotalStock, ffNumber, 2)+'"');
          SL.Add('"__________________________________________",""');
          SL.Add('"STOCK ON HAND",""');
          FL.Free;
          TotalStock:=0;

          TotalStock := TotalStock + StkAtPeriodRepSection(AStock,'Stamps'            ,'9000100-9005000',SL,True,TP,DB);
          TotalStock := TotalStock + StkAtPeriodRepSection(nil   ,'Postal Orders'     ,'5000500-5100000',SL,True,TP,DB);
          TotalStock := TotalStock + StkAtPeriodRepSection(nil   ,'Till Stock'        ,'2000300-2000399',SL,True,TP,DB);
          TotalStock := TotalStock + StkAtPeriodRepSection(nil   ,'Tel Cards'         ,'2000400-2000499',SL,True,TP,DB);

          if FUser = 'Supervisor' then
          begin
            TotalStock := TotalStock + StkAtPeriodRepSection(nil   ,'Post Shop Stock'   ,'2010010-2020000',SL,True,TP,DB);
            TotalStock := TotalStock + StkAtPeriodRepSection(nil   ,'Philatelic Stock'  ,'7000010-7999999',SL,True,TP,DB);
         end;
          SL.Add('"TOTAL STOCK ON HAND","'+CurrToStrF(TotalStock, ffNumber, 2)+'"');
        //*********************************************************************************************
        //*  Ghana Cash Account finish                                                               *
        //*********************************************************************************************
       end

       else if RType = 'Qatar Cash Account' then
       begin                     
        // **********************************************************************************************
        // *  Qatar Cash Account start                                                                  *
        // **********************************************************************************************
          if OfficeNo = '' then
          begin
             FReportTitle:='Qatar Post - Full Cash Account';
             CheckReportedStock:=False;
             if FromDate = ''  then
                SL.Add('"Clerk Cash Account",""');
          end
          else if StrToIntDef(OfficeNo,-1) = FUIEventSink.Office then
          begin
             CheckReportedStock:=False;
             FReportTitle:='Qatar - GPO Cash Account';
          end;
          SL.Add('"BROUGHT FORWARD",""');
          SL.Add('"__________________________________________",""');
          TotalReceipt:=0;
          TotalPayment:=0;
          TotalStock := 0;

          TotalReceipt:=0;
          DoFullUserSearch:=False;
          FL:=TPackStringList.Create;
          TotalStock := TxnRepRelSection(DB,'-Cash' ,'((PLU = 90000003) or Prod = ''Product.Cash'')',FP-1,FP-1,FL,Summary,False,'TxnTotal'' or RecType = ''CashAccAdj');
          DoFullUserSearch:=True;
          TotalStock := TotalStock + TxnRepRelSection(DB,'Temp.Cash on Hand' ,'(PLU <> -1)',FP-1,FP-1,FL,Summary,False,'StartDay');
          SL.Add('"Cash","'+CurrToStrF(TotalStock, ffNumber, 2)+'"');
          FL.Free;
          DoFullUserSearch:=False;

          //stock from previous period close
      //    StkAtPeriodRepSection(AStock, 'Cash'               ,'-1'                              ,SL, False, FP-1, DB);
          StkAtPeriodRepSection(AStock, 'Cheques'            ,'6100000'                         ,SL, False, FP-1, DB);
          StkAtPeriodRepSection(AStock, 'CC Receipts'        ,'6100010'                         ,SL, False, FP-1, DB);
          StkAtPeriodRepSection(AStock, 'Stamps'             ,'9000000-9090000'                 ,SL, False, FP-1, DB);
          StkAtPeriodRepSection(AStock, 'Till Stock'         ,'2000300-2000500,2100005-2100800,9100100-9150000' ,SL, False, FP-1, DB);
          DoFullUserSearch := True;
          if FUser = 'Supervisor' then
          begin
            StkAtPeriodRepSection(AStock, 'Post Shop Stock'    ,'2010010-2020000'                 ,SL, False, FP-1, DB);
            StkAtPeriodRepSection(AStock, 'Philatelic Stock'   ,'7000010-7999999'                 ,SL, False, FP-1, DB);
          end;
      //    TotRecRel('Balance B/F Adjust'                     ,'020000010'                       ,'CashAccAdj' );
      //    SL.Add('"__________________________________________",""');
          TotRec('TOTAL BROUGHT FORWARD'                     ,'061000000'                       ,'TxnTotal' );
          SL.Add('"__________________________________________",""');
          SL.Add('" ",""');
          SL.Add('"RECEIPTS",""');
          if FUser = 'Supervisor' then
          begin
            SL.Add('"___________ Remittances Received ___________",""');
            TotRecRel('Cash'                               ,'6000001-6050000,6100000-6100010'                     ,'TxStkTo' );
            TotRecRel('Stamps'                             ,'9000000-9090000'                     ,'TxStkTo' );
            TotRecRel('Till Stock'                         ,'2000300-2000500,2100005-2100800,9100100-9150000' ,'TxStkTo' )
          end
          else
          begin
            SL.Add('"____ Stock/Cash Ordered from Supervisor ____",""');
            TotRecRel('Cash'                               ,'6000001-6050000,6100000-6100010'     ,'TxStkFrom' );
            TotRecRel('Stamps'                             ,'9000000-9090000'                     ,'TxStkFrom' );
            TotRecRel('Till Stock'                         ,'2000300-2000500,2100005-2100800,9100100-9150000' ,'TxStkFrom' );
          end;
          if FUser = 'Supervisor' then
          begin
            TotRecRel('Post Shop Stock'                    ,'2010010-2020000'                     ,'TxStkTo' );
            TotRecRel('Philatelic Stock'                   ,'7000010-7999999'                     ,'TxStkTo' );
          end;
          DoFullUserSearch := False;
          SL.Add('"_______________ Mail Services _______________",""');
          TotRecRel('Stamps Sales'                       ,'9000000-9090000'                     ,'TxnLine' );
          TotRecRel('Domestic Mail'                      ,'050100010-050100050,050100070'       ,'TxnLine' );
          TotRecRel('International Mail'              ,'060100010-060100060,060100080,060100085','TxnLine' );
//          TotRecRel('Postage Labels'                     ,'50100010-050100050,050100070-50100310,60500010,60100010-60100230' ,'TxnLine' );
          TotRecRel('Registered Service'                 ,'50100200,60100200'                   ,'TxnLine' );
          TotRecRel('Express Service'                    ,'50100230,60100230'                   ,'TxnLine' );
//          TotRecRel('Insurance Fees'                     ,'50100210,60100210'                   ,'TxnLine' );
          TotRecRel('Adv of Delivery'                    ,'50100220,60100220'                   ,'TxnLine' );
          TotRecRel('EMS Outward'                        ,'70000010,70000020'                   ,'TxnLine' );
          TotRecRel('Items Delivery'                     ,'60600010,60600020,60600030,60600040,60600060' ,'TxnTotal' );
          TotRecRel('Direct Mail'                        ,'50200030'                            ,'TxnLine' );
          TotRecRel('IRC Sales'                          ,'2000300'                             ,'TxnLine' );
          TotRecRel('Stationery Sales'                   ,'2100300-2100600'                     ,'TxnLine' );
          TotRecRel('Tracking Enquiries'                 ,'50200080'                            ,'TxnLine' );
          TotRecRel('Item Recalls'                       ,'50200010'                            ,'TxnLine' );
          TotRecRel('Intel Post'                         ,'50200090'                            ,'TxnLine' );
          SL.Add('"______________ Money Orders _______________",""');
          TotRecRel('Money Order Sales'                  ,'40100010'                            ,'TxnLine' );
          TotRecRel('Money Order Commission'             ,'40100030'                            ,'TxnLine' );
//          SL.Add('"______________ PO Boxes ___________________",""');
//          TotRecRel('P.O. Box Rentals'                   ,'30100210,30100220'                   ,'TxnLine' );
//          TotRecRel('P.O. Box Keys'                      ,'30100240,30100270,30100280'          ,'TxnLine' );
          SL.Add('"______________ Agency Services _____________",""');
          TotRecRel('Telephone Cards'                    ,'2100030-2100100'                     ,'TxnLine' );
          TotRecRel('Revenue Stamps'                     ,'9100100-9150000'                     ,'TxnLine' );
          TotRecRel('Kaharamaa Bills'                    ,'40300010'                            ,'TxnLine' );
//          TotRecRel('Q-Tel Bills'                        ,'40300040'                            ,'TxnLine' );
          TotRecRel('Car Insurance'                      ,'40300120,40300130'                   ,'TxnLine' );
          TotRecRel('Health Cards'                       ,'40300140'                            ,'TxnLine' );
          FL:=TPackStringList.Create;
          TmpStock :=  TxnRepSection(DB,'e-Resident Payments in'  ,'((PLU = 40300150 or PLU = 40300160))',FP,FP,FL,Summary,True,'TxnLine');
          TmpStock :=  TmpStock - TxnRepSection(DB,'e-Resident Payments out'  ,'(PLU = 40300161)',FP,FP,FL,Summary,True,'TxnLine');
          FL.Free;
          SL.Add('"e-Resident Payments","'+CurrToStrF(TmpStock, ffNumber, 2)+'"');
          TotRecRel('Internet Cafe Sales'                ,'50200100'                            ,'TxnLine' );
//          SL.Add('"__________________________________________",""');
          SL.Add('" ",""');
          TotRecRel('Post Shop Sales'                    ,'2010010-2020000'                     ,'TxnLine' );
          SL.Add('" ",""');
//          TotRecRel('Mailing Items Sales'                ,'0'                                   ,'TxnLine' );
//          SL.Add('" ",""');
          TotRecRel('Philatelic Sales'                   ,'7000010-7999999'                     ,'TxnLine' );
          SL.Add('" ",""');
          if FUser = 'Supervisor' then
          begin
            TotRecRel('Miscellaneous Receipts'             ,'080000070'                         ,'TxnLine' );
            SL.Add('" ",""');
          end;
          //SL.Add('"__________________________________________",""');
          SL.Add('"TOTAL RECEIPTS","'+CurrToStrF(TotalReceipt, ffNumber, 2)+'"');
          SL.Add('"__________________________________________",""');
          SL.Add('" ",""');
          SL.Add('"PAYMENTS",""');
          TotPayRel('Money Order Paid'                   ,'40100020'                            ,'TxnLine' );
          TotPayRel('IRCs Redeemed'                      ,'50200060'                            ,'TxnLine' );
          DoFullUserSearch := True;
          if FUser = 'Supervisor' then
          begin
            TotPayRel('Miscellaneous Payments'             ,'080000080'                           ,'TxnLine' );
            SL.Add('" ",""');
            SL.Add('"______________ Remittances Sent ____________",""');
            TotPayRel('Cash'                               ,'6000000-6050000'                     ,'TxStkFrom' );
            TotPayRel('Cheques'                            ,'6100000'                             ,'TxStkFrom' );
            TotPayRel('Credit Card Receipts'               ,'6100010'                             ,'TxStkFrom' );
            TotPayRel('Stamps'                             ,'9000000-9090000'                     ,'TxStkFrom' );
            TotPayRel('Till Stock'                         ,'2000300-2000500,2100005-2100800,9100100-9150000' ,'TxStkFrom' );
            TotPayRel('Post Shop Stock'                    ,'2010010-2020000'                     ,'TxStkFrom' );
            TotPayRel('Philatelic Stock'                   ,'7000010-7999999'                     ,'TxStkFrom' )
          end
          else
          begin
              SL.Add('" ",""');
              SL.Add('"_____ Stock/Cash Returned to Supervisor ____",""');
              TotPayRel('Cash'                               ,'6000000-6050000'                     ,'TxStkTo' );
              TotPayRel('Cheques'                            ,'6100000'                             ,'TxStkTo' );
              TotPayRel('CC Receipts'                        ,'6100010'                             ,'TxStkTo' );
              TotPayRel('Stamps'                             ,'9000000-9090000'                     ,'TxStkTo' );
              TotPayRel('Till Stock'                         ,'2000300-2000500,2100005-2100800,9100100-9150000' ,'TxStkTo' );
          end;
          DoFullUserSearch := False;
          SL.Add('" ",""');
       //   SL.Add('"__________________________________________",""');
          SL.Add('"TOTAL PAYMENTS","'+CurrToStrF(TotalPayment, ffNumber, 2)+'"');
          SL.Add('"__________________________________________",""');
         // SL.Add('"CASH ON HAND",""');
          SL.Add('" ",""');

          FL:=TPackStringList.Create;                                          //      Cash
          TotalStock :=              TxnRepRelSection(DB,'Temp.Cash on Hand' ,'((PLU = 90000003) or Prod = ''Product.Cash'')',FP,TP,FL,Summary,False,'TxnTotal'' or RecType = ''CashAccAdj');
          DoFullUserSearch:=True;
          TotalStock := TotalStock + TxnRepRelSection(DB,'Temp.Cash on Hand' ,'(PLU <> -1)',FP,TP,FL,Summary,False,'StartDay');
          DoFullUserSearch:=False;
          //  Value is incorrect if CashAcc is done for >= 2 days (correct for 1 day)
          //  Possibly a general problem. (check temp cash on hand lines)
          SL.Add('"Cash On Hand","'+CurrToStrF(TotalStock, ffNumber, 2)+'"');
          TotStS('Cheques','6100000-6100000'); //cheques from stock added to TotalStock
          SL.Add('"Cheques On Hand","'+CurrToStrF(StkRepSection(AStock,'Cheques','6100000',FL,False), ffNumber, 2)+'"');
          TotStS('CC Receipts','6100010-6100010'); //cc receipts from stock added to TotalStock
          SL.Add('"CC Receipts On Hand","'+CurrToStrF(StkRepSection(AStock,'CC Receipts','6100010',FL,False), ffNumber, 2)+'"');
          SL.Add('"TOTAL CASH ON HAND","'+CurrToStrF(TotalStock, ffNumber, 2)+'"');
          SL.Add('"__________________________________________",""');
          SL.Add('"STOCK ON HAND",""');
          FL.Free;
          TotalStock:=0;
          TotalStock := TotalStock + StkAtPeriodRepSection(AStock,'Stamps'            ,'9000000-9090000',SL,True,TP,DB);
          TotalStock := TotalStock + StkAtPeriodRepSection(AStock,'Till Stock'        ,'2000300-2000600,2100005-2100800,9100100-9150000',SL,True,TP,DB);
          if FUser = 'Supervisor' then
          begin
            TotalStock := TotalStock + StkAtPeriodRepSection(AStock,'Post Shop Stock'   ,'2010010-2020000',SL,True,TP,DB);
            TotalStock := TotalStock + StkAtPeriodRepSection(AStock,'Philatelic Stock'  ,'7000010-7999999',SL,True,TP,DB);
          end;
          SL.Add('"TOTAL STOCK ON HAND","'+CurrToStrF(TotalStock, ffNumber, 2)+'"');
        //*********************************************************************************************
        //*  Qatar Cash Account finish                                                                *
        //*********************************************************************************************
       end

       else if RType = 'ClerkTrans' then
       begin
          FReportTitle:='Guernsey Post - End-of-day Transaction Summary';
          SL.Add('"Receipts",""');
          SL.Add('"",""');
          DoFullUserSearch:=True;
          TotalReceipt :=                TxnRepSection(DB,'1   Balance B/Fwd '  ,'((PLU = 61000000))',FP,FP,SL,Summary,True,'TxnTotal');
          DoFullUserSearch:=False;
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'2   Domestic Mail'                    ,'((PLU >= 020000000) AND (PLU <= 020000040))' ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'3   International AirMail'            ,'((PLU >= 030000100) AND (PLU <= 030000160))' ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'4   International Surface Mail'       ,'((PLU >= 050000300) AND (PLU <= 050000360))' ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'5   International EMS'                ,'((PLU = 030050000))'                         ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'6   Postage Franking Service'         ,'((PLU >= 060000400) AND (PLU <= 060000420))' ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'7   Redirection Service'              ,'((PLU = 070000100))'                         ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'8   Keepsafe'                         ,'((PLU = 070000110))'                         ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'9   NSB Ordinary Open/Deposit'        ,'((PLU IN (090000201,090000202)))'            ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'10  NSB Investment Open/Deposit'      ,'((PLU IN (090000210,090000211)))'            ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'11  Premium Bonds Issued'             ,'( PLU IN (090000220))'                        ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'12  Other Bonds Issued'               ,'( PLU IN (090000230,090000231,090000240))'    ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'13  National Savings Certs Issued'    ,'((PLU = 090000250))'                         ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'14  Girobank Deposit/Bill Payment'    ,'( PLU IN (090000301,090000303))'              ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'15  Barclays Bank Deposit'            ,'( PLU IN (090000262))'                        ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'16  State Receipts'                   ,'((PLU >= 91000213) AND (PLU <= 91000227))'   ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'17  TV Licence New/Renewals'          ,'((PLU = 091000301))'                         ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'18  Customer Faxes'                   ,'((PLU = 070000130))'                         ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'19  Franking Meters'                  ,'((PLU = 070000140))'                          ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'20  Postal Orders (inc Commission)'   ,'((PLU = 91000400) )'                         ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'21  Retail Sales'                     ,'((PLU Between 2000210 AND 2000670) or PLU in (70000150,3000001,3000002,3000103,3000200,3000201,3000202))' ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'22  Philatelic Sales'                 ,'((PLU Between 7000010 AND 7002000))'         ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'23  Vendor Sales'                     ,'((PLU Between 9000022 AND 9000500) or PLU IN (9100027, 9100075, 9200220, 9200270, 9302200, 9302700))' ,FP,TP,SL,Summary,True,'VendSale');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'24  Stamp Sales'                      ,'((PLU Between 9000000 AND 9000500) or PLU IN (9100027, 9100075, 9200220, 9200270, 9302200, 9302700,9500200) or (PLU BETWEEN 9400010 AND 9400300))' ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'25  Miscellaneous Receipts'           ,'( PLU = 091000330) and (Description = ''Misc. Receipt'')'     ,FP,TP,SL,Summary,True,'TxnTotal');

          SL.Add('"",""');
          SL.Add('"Total Receipts","'+CurrToStrF(TotalReceipt, ffNumber, 2)+'"');
          SL.Add('"",""');
          if FromDate = ToDate then  SL.Add('"",""');
          SL.Add('"------------------------","------------------------------"');
          SL.Add('"Payments",""');
          SL.Add('"",""');
          TotalPayment := 0;
          TotalPayment := TotalPayment + TxnRepSection(DB,'1   Social Payments'                   ,'((PLU = 091000310))'                         ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'2   NSB Ordinary Close/With'           ,'((PLU IN (090000203,090000204)))'            ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'3   NSB Investment Close/With'         ,'((PLU IN (090000212,090000213)))'            ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'4   Premium Bonds Redeemed'            ,'(PLU IN (90000221))'                         ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'5   Girobank Withdrawal'               ,'(PLU IN (90000302))'                         ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'6   Barclays Bank Withdrawal'          ,'((PLU = 90000261))'                          ,FP,TP,SL,Summary,True,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'7   Lottery Card Prize Payment'        ,'((PLU = 091000228))'                          ,FP,TP,SL,Summary,True,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'8   TV Licence Refunds'                ,'((PLU = 0))'                                 ,FP,TP,SL,Summary,True,'TVRefund');
          TotalPayment := TotalPayment + TxnRepSection(DB,'9   Postal Orders Redeemed'            ,'((PLU = 91000410))'                          ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'10  Postal Orders Redeemed (Bulk)'     ,'((PLU = 91000420))'                          ,FP,TP,SL,Summary,True,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'11  Miscellaneous Payments'            ,'(PLU = 091000330) and (Description = ''Misc. Payment'')'      ,FP,TP,SL,Summary,True,'TxnTotal');
          SL.Add('"",""');
          SL.Add('"------------------------","------------------------------"');
          SL.Add('"Total Payments","'+CurrToStrF(TotalPayment, ffNumber, 2)+'"');
          SL.Add('"",""');
          if FromDate = ToDate then  SL.Add('"",""');

        end
       else if RType = 'TanCash' then
       begin           // transferring cash, adding instead of subtracting
          TxnRepSection(DB,'Cash on Hand'  ,'Prod = ''Product.Cash''',
                                        FP,TP,SL,Summary,False,
                                        'TxnTotal'' or RecType = ''StartDay');

       end
       //else if RType = 'GuernseyCheques' then
       //begin           // transferring cash, adding instead of subtracting
       //   TxnRepSection(DB,'Cheques on Hand'  ,'Prod = ''Product.Cheque''',
       //                                 FP,TP,SL,Summary,False,
       //                                 'TxnTotal');
       //end
       else if RType = 'GuernseyCash' then
       begin           // transferring cash, adding instead of subtracting
         TotalReceipt:= TxnRepSection(DB,'Cash on Hand'  ,'Prod = ''Product.Cash''',
                                        FP,TP,SL,Summary,False,
                                        'TxnTotal'' or RecType = ''StartDay');

         TotalReceipt:= TotalReceipt + TxnRepSection(DB,'Cheques on Hand'  ,'Prod = ''Product.Cheque''',
                                        FP,TP,SL,Summary,False,
                                        'TxnTotal');
         TotalReceipt:= TotalReceipt + TxnRepSection(DB,'TV Stamps taken'  ,'Prod = ''Product.TVStpsTk''',
                                        FP,TP,SL,Summary,False,
                                        'TxnLine');
         TotalReceipt:= TotalReceipt + TxnRepSection(DB,'Card Payment'  ,'(RecIndex = 0) and (Prod = ''Product.CardPay'')',
                                        FP,TP,SL,Summary,False,
                                        'TxnLine');
         TotalReceipt:= TotalReceipt + TxnRepSection(DB,'On Account'  ,'Prod = ''Product.AccountPay''',
                                        FP,TP,SL,Summary,False,
                                        'TxnTotal');
         TotalReceipt:= TotalReceipt + TxnRepSection(DB,'Foreign Exchange'  ,'Prod = ''Product.ForeignExcha''',
                                        FP,TP,SL,Summary,False,
                                        'TxnTotal');

          SL.Add('"",""');
          SL.Add('"------------------------","------------------------------"');
          SL.Add('"Total Payments","'+CurrToStrF(TotalReceipt, ffNumber, 2)+'"');
       end
       else if RType = 'GuernseyCashOnHand' then
       begin           // transferring cash, adding instead of subtracting
         SL.Add('"Cash on Hand",""');
         SL.Add('"------------------------------","------------------------------"');
         TotalStock := 0;
         DoFullUserSearch := True;  //Supervisor cash already includes clerk cash
         TotalStock:= TxnRepSection(DB,'Cash on Hand'  ,'Prod = ''Product.Cash''',
                                        FP,TP,SL,Summary,False,
                                        'TxnTotal'' or RecType = ''StartDay');
         DoFullUserSearch := False;

         //TotalStock := TotalStock + StkRepSection(Stock,'Cash',                     '6000001-6005000',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'Cheques',                  '6000000-6000000',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'Card Payments',            '9100000-9100000',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'TV Stamps Taken',          '6009004-6009004',SL,False);

         //TotalStock := TotalStock + TxnRepSection(DB,'On Account'  ,'Prod = ''Product.AccountPay''',
         //                               FP,TP,SL,Summary,False,
         //                               'TxnTotal');

         TotalStock := TotalStock + StkRepSection(AStock,'Australian dollar (AUD)',  '6009010-6009010',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'Canadian dollar (CND)',    '6009020-6009020',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'Euro (EUR)',               '6009030-6009030',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'Hong Kong dollar (HKD)',   '6009040-6009040',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'Japanese yen (JPY)',       '6009050-6009050',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'New Zealand dollar (NZD)', '6009060-6009060',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'Norwegian krone (NOK)',    '6009070-6009070',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'South African rand (ZAR)', '6009080-6009080',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'Swiss franc (CHF)',        '6009090-6009090',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'US dollar (USD)',          '6009100-6009100',SL,False);

         SL.Add('"",""');
         SL.Add('"------------------------","------------------------------"');
         SL.Add('"Total Stock on Hand","'+CurrToStrF(TotalStock, ffNumber, 2)+'"');

       end
       else if RType = 'TanStamps' then
       begin
          TxnRepSection(DB,'Stamps'
                          ,'((PLU >= 9000020) and (PLU <= 9099999))',
                          FP,TP,SL,Summary,False,'TxnTotal');
       end
       else if RType = 'TanStock' then
       begin
          TxnRepSection(DB,'Stock',
                '(((PLU >= 2000200) and (PLU <= 2007999)) or ((PLU >= 9020022) and (PLU <= 9200000)))',
                FP,TP,SL,Summary,False,'TxnTotal');
       end
       else if RType = 'GenPhilatelic' then
       begin
          TxnRepSection(DB,'Stamps'
                          ,'((PLU >= 7000000) and (PLU <= 7100000))',
                          FP,TP,SL,Summary,False,'TxnTotal');
       end
       else if RType = 'GhanaPostShop' then
       begin
          // Where is the Paper PLU
          TxnRepSection(DB,'Stamps'
                          ,'(PLU in ( 2011070,2010700,2010560,2010420,2010370,2010210,'+
                           '           2010010,2010020,2010030,2010040,2010050,2010060,2010070,2010080,'+
                           '           2010090,2010100,2010110,2010120,2010130,2010140,2010150,2010160,'+
                           '           2010170,2010180,2010190,2010200 '+
                           ' ))',
                          FP,TP,SL,Summary,False,'TxnTotal');
       end


       else if RType = 'GuernseyStock' then
       begin
         SL.Add('"Stock on Hand",""');
         SL.Add('"------------------------------","------------------------------"');
         TotalStock := 0;
         TotalStock := TotalStock + StkRepSection(AStock,'Postage Stamps',     '9000000-9000500',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'Int.Reply Coupons',  '9100075-9100075',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'UK Postage Stamps',  '9100027-9100027',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'Stamp Books',        '9200000-9299999',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'Stamp Boxes',        '9300000-9399999',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'VAT Stamps',         '9400000-9499999',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'TV Stamps',          '9500000-9599999',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'Postal Orders',      '5000050-5002000',SL,False);
         TotalStock := TotalStock + StkRepSection(AStock,'Other Value Stock',  '3000000-3999999',SL,False);
         SL.Add('"",""');
         SL.Add('"------------------------","------------------------------"');
         SL.Add('"Total Stock on Hand","'+CurrToStrF(TotalStock, ffNumber, 2)+'"');

       end
       else if RType = 'BVIStock' then
       begin
          TxnRepSection(DB,'Stock Sales',
                '((PLU >= 0) and (PLU <> 90000003))',
                FP,TP,SL,Summary,False,'TxnTotal');
       end
       else if RType = 'GuernseyStateRec' then
       begin
          TxnRepRelSection(DB,'State Receipts','((PLU Between 091000213 and 091000228 ))',FP,TP,SL,Summary,False,'TxnTotal');
       end
       else if RType = 'TanFullBalance' then
       begin
       end
       else if RType = 'TanPostBank' then
       begin
          TV := TxnRepSection(DB,'Tanzania Postal Bank (TPB) Deposit'
                               ,'( PLU = 090000001 )',FP,TP,SL,
                                  Summary,False,'TxnTotal');
          TV := TV - ( TxnRepSection(DB,'Tanzania Postal Bank (TPB) Withdrawals'
                                       ,'( PLU = 090000002 )',
                                       FP,TP,SL,Summary,False,
                                       'TxnTotal')
                      );
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Total","'+CurrToStrF(TV,ffNumber,2)+'"');
          SL.Add('"------------------------------","------------------------------"');
       end
       else if RType = 'UgandaPostBank' then
       begin
          TV := TxnRepSection(DB,'Post Bank Uganda - New Acc.'
                               ,'( PLU = 040400030 )',FP,TP,SL,
                                  Summary,False,'TxnTotal');
          TV := TV + ( TxnRepSection(DB,'Post Bank Uganda - Dep.'
                               ,'( PLU = 040400010 )',FP,TP,SL,
                                  Summary,False,'TxnTotal')
                     );
          TV := TV - ( TxnRepSection(DB,'Post Bank Uganda - With.'
                                       ,'( PLU = 040400020 )',
                                       FP,TP,SL,Summary,False,
                                       'TxnTotal')
                      );
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Total","'+CurrToStrF(TV,ffNumber,2)+'"');
          SL.Add('"------------------------------","------------------------------"');
       end
       else if RType = 'GuernseyPostBank' then
       begin
          TV := TxnRepSection(DB,'NSB Deposits'
                               ,'(PLU IN (090000201,090000202,090000210,090000211))',FP,TP,SL,
                                  Summary,False,'TxnTotal');
          TV := TV - ( TxnRepSection(DB,'NSB Withdrawals'
                                       ,'(PLU IN (090000203,090000204,090000212,090000213))',FP,TP,SL,Summary,False,'TxnTotal'));
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Cash Balance","'+CurrToStrF(TV,ffNumber,2)+'"');
          SL.Add('"------------------------------","------------------------------"');
       end
       else if RType = 'GuernseyGiroBank' then
       begin
          TV :=      TxnRepSection(DB,'Girobank Deposits',   '(PLU IN (090000301,090000303)) AND (RECINDEX = 0)',FP,TP,SL,Summary,False,'TxnLine');
          TV := TV + TxnRepSection(DB,'Girobank Fees',       '(PLU IN (090000303))           AND (RECINDEX = 2)',FP,TP,SL,Summary,False,'TxnLine');
          TV := TV - (
                TxnRepSection(DB,'Girobank Withdrawals','(PLU = 090000302)',                                FP,TP,SL,Summary,False,'TxnTotal'));
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Cash Balance","'+CurrToStrF(TV,ffNumber,2)+'"');
          SL.Add('"------------------------------","------------------------------"');
       end
       else if RType = 'GuernseyTVLic' then
       begin
          TV := TxnRepSection(DB,'Guernsey TV Licence Payments'
                               ,'(PLU = 091000301)',FP,TP,SL,
                                  Summary,False,'TxnLine');
          TV := TV - ( TxnRepSection(DB,'Guernsey TV Licence Refunds'
                               ,'(PLU = 091000302)',FP,TP,SL,
                                  Summary,False,'TxnLine'));
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"Cash Balance","'+CurrToStrF(TV,ffNumber,2)+'"');
          SL.Add('"------------------------------","------------------------------"');
       end
       else if RType = 'TanMoneyOrd' then
       begin
       end
    // Pakistan reports
       else if RType = 'PakOrders' then
       begin
          SL.Add('"Inventory Orders",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TV+TxnRepSection(DB,'Postal Orders','Ident = ''<Supervisor'' and ((PLU >= 5000100) and (PLU <= 5599999))',-1,999999,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Cash'         ,'Ident = ''<Supervisor'' and ((PLU >=  600001) and (PLU <=  610000))',-1,999999,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Stamps'       ,'Ident = ''<Supervisor'' and ((PLU >= 9000020) and (PLU <= 9079999))',-1,999999,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Stock'        ,'Ident = ''<Supervisor'' and ((PLU >= 9080000) and (PLU <= 9200000))',-1,999999,SL,stDetail,False,'StockTx');
          SL.Add(Format('"Grand Total","%m"',[TV]));
       end
       else if RType = 'PakReturns' then
       begin
          SL.Add('"Inventory Returns",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TV+TxnRepSection(DB,'Postal Orders','Ident = ''>Supervisor'' and ((PLU >= 5000100) and (PLU <= 5599999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Cash'         ,'Ident = ''>Supervisor'' and ((PLU >=  600001) and (PLU <=  610000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Stamps'       ,'Ident = ''>Supervisor'' and ((PLU >= 9000020) and (PLU <= 9079999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TV+TxnRepSection(DB,'Stock'        ,'Ident = ''>Supervisor'' and ((PLU >= 9080000) and (PLU <= 9200000))',FP,TP,SL,stDetail,False,'StockTx');
          SL.Add(Format('"Grand Total","%m"',[TV]));
       end
       else if RType = 'PakDeclaration' then
       begin
          SL.Add('"Inventory Declaration",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TV+TxnRepSection(DB,'Postal Orders','((PLU >= 5000100) and (PLU <= 5599999))',FP,TP,SL,stDetail,False,'StockDec');
    //      TV:=TxnRepSection(DB,'Cash'         ,'((PLU >=  600001) and (PLU <=  610000))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TV+TxnRepSection(DB,'Stamps'       ,'((PLU >= 9000020) and (PLU <= 9079999))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TV+TxnRepSection(DB,'Stock'        ,'((PLU >= 9080000) and (PLU <= 9200000))',FP,TP,SL,stDetail,False,'StockDec');
          SL.Add(Format('"Grand Total","%m"',[TV]));
       end
       else if RType = 'PakCash' then
       begin

          TxnRepSection(DB,'Cash on Hand'  ,'Prod = ''Product.Cash''',
                                        FP,TP,SL,Summary,False,
                                        'TxnTotal'' or RecType = ''StartDay');
       end
       else if RType = 'PakStamps' then
       begin
          TxnRepSection(DB,'Stamps'
                          ,'((PLU >= 9010005) and (PLU <= 9075000))',
                          FP,TP,SL,Summary,False,'StockUsed');
       end

    //*****************************************************************************************************//
    //*                                                                                                   *//
    //*                                Botswana Cash Account - Start                                      *//
    //*                                                                                                   *//
    //*****************************************************************************************************//

      else if LeftOf(UpperCase(RType), 'DLL') then
      begin
      end
      else if RType = 'BotsCash Account' then
      begin
        ReportParams.Summary     := Summary;
        //try
          //BotswanaCashAccount(self);
          //StringFromCLSID(ProgIDToClassID('Utility.Reports'), ClassIdString);
          //HModule := LoadLibrary(PChar(RegistryEx.ReadRegistryStringValue('HKCR\CLSID\' + ClassIdString  + '\InProcServer32\')));
          //@ReportFunc := GetProcAddress(HModule,'BotswanaCashAccount');
          //ReportFunc(self);
        //except
        //  On E : Exception do
        //   RaiseGUIDException('{BB5245B9-6471-42A2-BD1A-5E38081BA70E}', E);
        //end;  //try
        //FreeLibrary(HModule);
        With ReportParams do
        begin
          if FOfficeNo = '' then
          begin
            FReportTitle:='Botswana Post - Full Cash Account';
            CheckReportedStock:=False;
            if FromDate = '' then
              ReportLines.Add('"Clerk Cash Account",""');
          end
          else if Copy(FOfficeNo,1,1) = '!' then
          begin
             CheckReportedStock:=True;
             FReportTitle:='Botswana Post - Subs Cash Account';
          end
          else if StrToIntDef(FOfficeNo,-1) = UIEventSink.Office then
          begin
             CheckReportedStock:=False;
             FReportTitle:='Botswana Post - Head Office Cash Account';
          end
          else
          begin
             CheckReportedStock:=True;
             FReportTitle:='Botswana Post - Sub Cash Account';
             ReportLines.Add('"For Office '+FOfficeNo+'",""');
          end;

          if CheckReportedStock then ;

//*                                                                                                   *//
//*   Note - all references to TOTREC and TOTPAY now changed to TOTRECREL and TOTPAYREL               *//
//*            This is to allow negative values to be inserted into the cash account                  *//
//*                   from the supervisor menu option "CashAccAdj"                                    *//
//*                                                                                                   *//
          ReportLines.Add('"Receipts",""');
          ReportLines.Add('"------------------------------------------------------------------------",""');

          TotalReceipt:=0;

          DoFullUserSearch:=True;
          TotalReceipt :=                TxnRepSection(DB,'Balance Brought Forward'              ,'((PLU = 02009010) or (PLU = 61000000))'       ,FromPeriod,FromPeriod,ReportLines,Summary,False,RTypeToSQL('TxnTotal'));
          TotalStock := 0;
          FL:=TPackStringList.Create;

          DoFullUserSearch:=False;

          TotRecRel('Saving Bank Deposit'                 ,'002009020,090000201,090000203,090000211,090000213,090000221,090000223,090000230','TxnLine'  );
          TotRecRel('BSB Lost Book Fees'                  ,'002009030,090000240','TxnLine'  );
          TotRecRel('Customs Handling Charges'            ,'002009040,050020101','TxnLine'  );
          TotRecRel('Customs Duty Fees Botswana'          ,'002009050,050020102','TxnLine'  );
          TotRecRel('Customs Duty Fees South Africa'      ,'002009060,050020103','TxnLine'  );
          TotRecRel('COD Trade Charges'                   ,'002009070,050020009','TxnLine'  );
          TotRecRel('COD Handling Charges'                ,'002009080,050020008','TxnLine'  );
          TotRecRel('EMS Receipts - Individual'           ,'002009090,050050001,050050003','TxnLine'  );
          TotRecRel('EMS Receipts - Contract'             ,'002009100,050050005,050050006','TxnLine'  );
          TotRecRel('EMS Contract Account Payment'        ,'002009105,090000005','TxnLine'  );
          TotRecRel('PO Bag Receipts'                     ,'002009110,030000030-030000039','TxnLine'  );
          TotRecRel('PO Box Receipts'                     ,'002009120,030000010-030000023,50031003,50031021,50031022','TxnLine'  );
          TotRecRel('Bulk Posting'                        ,'002009130,050000250-050000254','TxnTotal'  );
          TotRecRel('National Saving Certificates'        ,'002009140,090000100','TxnTotal'  );
          TotRecRel('Group Funeral (BLI)'                 ,'002009150,060030008','TxnLine'  );
          TotRecRel('Ipolokeng (BLI)'                     ,'002009160,060030009','TxnLine'  );
          TotRecRel('R.I.P.C.'                            ,'002009170,060030007','TxnLine'  );
          TotRecRel('Registration of Newspapers'          ,'002009180,050031009','TxnLine'  );
          TotRecRel('Money Order - Inland Issued'         ,'002009190,050021001','TxnLine'  );
          TotRecRel('Money Order - Foreign Issued'        ,'002009200,050021005','TxnLine'  );
          TotRecRel('Money Order - Commission'            ,'002009210,000100003','TxnLine'  );
          TotRecRel('Money Order - Other charges'         ,'002009220,050021008,050021009,050021015-050021016,050021018,050021019','TxnLine'  );
          TotRecRel('Money Order - Transmission Charges'  ,'002009230,050021013-050021014','TxnLine'  );
          TotRecRel('Postal Order Commission'             ,'002009240,000100021','TxnLine'  );
          TotRecRel('Unaddressed Leaflets'                ,'002009250,050031010','TxnLine'  );
          TotRecRel('Customer Fax'                        ,'002009260,050031011','TxnLine'  );
          TotRecRel('Business Reply'                      ,'002009270,050031012','TxnLine'  );
          TotRecRel('Franking Machine'                    ,'002009280,050031004','TxnLine'  );
          TotRecRel('Water Affairs'                       ,'002009290,060030005','TxnLine'  );
          TotRecRel('Water Utilities'                     ,'002009300,060030006','TxnLine'  );
          TotRecRel('Housing Corporation'                 ,'002009310,060030004','TxnLine'  );
          TotRecRel('Electricity - DOE'                   ,'002009320,060030000','TxnLine'  );
          TotRecRel('Electricity - BPC'                   ,'002009330,060030001','TxnLine'  );
          TotRecRel('Botswana Telecom'                    ,'002009340,060030002','TxnLine'  );
          TotRecRel('Miscellaneous Receipts'              ,'002009350,050032001','TxnLine'  );
          TotRecRel('Imprest and Travel Receipts'         ,'002009355,050033006','TxnLine'  );
          TotRecRel('Western Union'                       ,'002009360','TxnLine'  );
          TotRecRel('Postage Labels'                      ,'002009370','TxnLine'  );
          if User = 'Supervisor' then
          begin
            TotalReceipt  := TotalReceipt +
                TxnRepRelSection(DB,'Cash Received From Bank','((Ident Like ''Barclay%'') and (Quantity < 0) or (RecType = ''CashAccAdj'')) and ' +
                PLUToSQL('002009380,6000005-6010000,6100000'),FP,TP,SL,Summary,False,RTypeToSQL('RemInfo'));
          end
          else
          begin
            TotalReceipt  := TotalReceipt +
                TxnRepRelSection(DB,'Cash Received From Bank','(Ident Like ''Barclay%'') and (Quantity < 0) and ' +
                PLUToSQL('002009380,6000005-6010000,6100000'),FP,TP,SL,Summary,False,RTypeToSQL('TxStkFrom'));
          end;
          TotRecRel('5 thebe adjustment'                  ,'002009390,1000001,1000004','TxnLine'  );

          DoFullUserSearch:=True;
          if User = 'Supervisor' then
          begin
            TxnType := 'TxStkTo';  //supervisor remittances
            ReportLines.Add('"Remittances Received From Other Offices & HQ",""');
            TotalReceipt  := TotalReceipt +
              TxnRepRelSection(DB,'- Cash','((Ident not Like ''Barclay%'') and (Quantity < 0) or (RecType = ''CashAccAdj'')) and '
              + PLUToSQL('002009400,6000005-6010000'),FP,TP,SL,Summary,False,RTypeToSQL('RemInfo'));
            TotalReceipt  := TotalReceipt +
              TxnRepRelSection(DB,'- Cheques','((Ident not Like ''Barclay%'') and (Quantity < 0) or (RecType = ''CashAccAdj'')) and '
              + PLUToSQL('002009410,6100000-6100000'),FP,TP,SL,Summary,False,RTypeToSQL('RemInfo'));
          end
          else
          begin
            TxnType := 'TxStkFrom';
            ReportLines.Add('"Received From Main Stock",""');
            TotalReceipt  := TotalReceipt + TxnRepRelSection(DB,'- Cash','(Ident not Like ''Barclay%'') and (Quantity > 0) and '
              + PLUToSQL('002009400,6000005-6010000'),FP,TP,SL,Summary,False,RTypeToSQL('TxStkFrom'));
            TotalReceipt  := TotalReceipt + TxnRepRelSection(DB,'- Cheques','(Ident not Like ''Barclay%'') and (Quantity > 0) and '
              + PLUToSQL('002009410,6100000-6100000'),FP,TP,SL,Summary,False,RTypeToSQL('TxStkFrom'));
          end;
          TotRecRel('- Stamps Items'            ,'002009420,9010005-9019999,9020005-9020125',TxnType  );
          TotRecRel('- Retail Items'            ,'002009430,9118000-9118180',TxnType  );
          TotRecRel('- BW Courier'              ,'002009440,9118190-9118350',TxnType  );
          TotRecRel('- Merchandise'             ,'002009450,9118360-9118999',TxnType  );
          TotRecRel('- Postal Orders'           ,'002009460,5100005-5101000',TxnType  );
          TotRecRel('- Phil. First Day Covers'  ,'002009470,7000400-7000499',TxnType  );
          TotRecRel('- Phil. Souvenir Sheets'   ,'002009480,7000360-7000399',TxnType  );
          TotRecRel('- Phil. Year Packs'        ,'002009490,7000300-7000359',TxnType  );
          TotRecRel('- Phil. Other items'       ,'002009500,7000010-7000299',TxnType  );

          DoFullUserSearch:=False;

          ReportLines.Add('"","-------------------"');
          ReportLines.Add('A - Total Receipts,"'+CurrToStrF(TotalReceipt, ffNumber, 2)+'"');

          ReportLines.Add('"",""');
          ReportLines.Add('"Payments",""');
          ReportLines.Add('"------------------------------------------------------------------------",""');

          TotalPayment:=0;

          TotPayRel('Money Order - Inland Paid'             ,'002009510,050021002','TxnLine'  );
          TotPayRel('Money Order - Foreign Paid'            ,'002009520,050021006','TxnTotal'  );
          TotPayRel('Money Order - Bulk Paid'               ,'002009530,050021017','TxnTotal'  );
          TotPayRel('Money Order - Inland Refund'           ,'002009540,050021004','TxnTotal'  );
          TotPayRel('Post Ord Paid - Inland'                ,'002009550,050021051','TxnTotal'  );
          TotPayRel('Post Ord Paid - UK'                    ,'002009560,050021052','TxnTotal'  );
          TotPayRel('Post Ord Paid - Other Foreign'         ,'002009570,050021053','TxnTotal'  );
          TotPayRel('Post Ord Paid - Bulk'                  ,'050021054','TxnTotal'  );
          TotPayRel('Savings Bank Withdrawals'              ,'002009580,090000202,090000204,090000212,090000214,090000222,090000224','TxnLine'  );
          TotPayRel('National Savings Certs Paid'           ,'002009590,090000101,090000102','TxnLine'  );
          TotPayRel('Refunds'                               ,'002009600,050031006,050031020','TxnLine'  );
          TotPayRel('Pensions Paid RSA'                     ,'002009610,050040003','TxnLine'  );
          TotPayRel('Old Age Pension Botswana'              ,'002009620,050040001,050040002','TxnLine'  );
          TotPayRel('Discount To Vendors'                   ,'002009630,060020011','TxnLine'  );
          TotPayRel('Miscellaneous Payments'                ,'002009640,050032002','TxnLine'  );
          TotPayRel('Western Union'                         ,'002009650','TxnLine'  );
          TotPayRel('Imprest and travel claims'             ,'002009660,050033002','TxnLine'  );
          TotPayRel('Salaries P&P'                          ,'002009670,050033001','TxnLine'  );
          TotPayRel('Wages Industrial Class'                ,'002009680,050033003','TxnLine'  );
          TotPayRel('Temporary Staff'                       ,'002009690,050033004','TxnLine'  );
          TotPayRel('Death Claim'                           ,'002009700,050033005','TxnLine'  );
          TotPayRel('Humana'                                ,'002009705,050033007','TxnLine'  );
          if User = 'Supervisor' then
          begin
            TotalPayment  := TotalPayment + TxnRepRelSection(DB,'Deposit With Bank',
                '((Ident Like ''Barclay%'') and (Quantity > 0) or (RecType = ''CashAccAdj'')) and'
                + PLUToSQL('002009710,6000005-6010000,6100000'),FP,TP,SL,Summary,False,RTypeToSQL('RemInfo'));
          end
          else
          begin
            TotalPayment  := TotalPayment +
              TxnRepRelSection(DB,'Deposit With Bank','(Ident Like ''Barclay%'') and (Quantity > 0) and '
              + PLUToSQL('002009710,6000005-6010000,6100000'),FP,TP,SL,Summary,False,RTypeToSQL('TxStkTo'));
          end;
          TotPayRel('5 thebe adjustment'                    ,'002009720,1000002-1000003','TxnLine'  );

          DoFullUserSearch:=True;
          if User = 'Supervisor' then
          begin
            TxnType := 'TxStkFrom';  //supervisor remittances
            ReportLines.Add('"Remittances Despatched To Other Offices & HQ",""');
            TotalPayment  := TotalPayment +
              TxnRepRelSection(DB,'- Cash','((Ident not Like ''Barclay%'') and (Quantity > 0) or (RecType = ''CashAccAdj'')) and '
              + PLUToSQL('002009730,6000005-6010000'),FP,TP,SL,Summary,False,RTypeToSQL('RemInfo'));
            TotalPayment  := TotalPayment +
              TxnRepRelSection(DB,'- Cheques','((Ident not Like ''Barclay%'') and (Quantity > 0) or (RecType = ''CashAccAdj'')) and '
              + PLUToSQL('002009740,6100000-6100000'),FP,TP,SL,Summary,False,RTypeToSQL('RemInfo'));
          end
          else
          begin
            TxnType := 'TxStkTo';
            ReportLines.Add('"Returned To Main Stock",""');
            TotalPayment  := TotalPayment + TxnRepRelSection(DB,'- Cash','(Ident not Like ''Barclay%'') and (Quantity > 0) and '
              + PLUToSQL('002009730,6000005-6010000'),FP,TP,SL,Summary,False,RTypeToSQL('TxStkTo'));
            TotalPayment  := TotalPayment + TxnRepRelSection(DB,'- Cheques','(Ident not Like ''Barclay%'') and (Quantity > 0) and '
              + PLUToSQL('002009740,6100000-6100000'),FP,TP,SL,Summary,False,RTypeToSQL('TxStkTo'));
          end;
          TotPayRel('- Stamps Items'            ,'002009750,9010005-9019999,9020005-9020125',TxnType  );
          TotPayRel('- Retail Items'            ,'002009760,9118000-9118180',TxnType  );
          TotPayRel('- BW Courier'              ,'002009770,9118190-9118350',TxnType  );
          TotPayRel('- Merchandise'             ,'002009780,9118360-9118999',TxnType  );
          TotPayRel('- Postal Orders'           ,'002009790,5100005-5101000',TxnType  );
          TotPayRel('- Phil. First Day Covers'  ,'002009800,7000400-7000499',TxnType  );
          TotPayRel('- Phil. Souvenir Sheets'   ,'002009810,7000360-7000399',TxnType  );
          TotPayRel('- Phil. Year Packs'        ,'002009820,7000300-7000359',TxnType  );
          TotPayRel('- Phil. Other items'       ,'002009830,7000010-7000299',TxnType  );
          DoFullUserSearch:=False;

          ReportLines.Add('"","-------------------"');
          ReportLines.Add('B - Total Payments,"'+CurrToStrF(TotalPayment, ffNumber, 2)+'"');

          if (FUser = 'Supervisor') or (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then
          begin
             ReportLines.Add('"",""');
             ReportLines.Add('"Cash On Hand",""');
             ReportLines.Add('"------------------------------------------------------------------------",""');
          end;

                                    // For "start day" record only pick up the current user.
          DoFullUserSearch:=True;   // This must be done because supervisor "start day" record
                                    // includes cash for the whole office

          CashOnHand :=              TxnRepRelSection(DB,''              ,'Prod = ''Product.Cash'''              ,ToPeriod,ToPeriod,FL,Summary,False,'StartDay' );
          DoFullUserSearch:=False ;

          CashOnHand := CashOnHand + TxnRepRelSection(DB,''              ,'Prod = ''Product.Cash'''              ,ToPeriod,ToPeriod,FL,Summary,False,'TxnTotal'' or RecType = ''CashAccAdj' );
          CashOnHand := CashOnHand + TxnRepSection   (DB,''              ,'((PLU = 1000001) or (PLU = 1000004))' ,ToPeriod,ToPeriod,FL,Summary,False,RTypeToSQL('TxnLine'));
          CashOnHand := CashOnHand - TxnRepSection   (DB,''              ,'((PLU = 1000002) or (PLU = 1000003))' ,ToPeriod,ToPeriod,FL,Summary,False,RTypeToSQL('TxnLine'));
          CashOnHand := CashOnHand + TxnRepRelSection   (DB,''              ,'(PLU = 2009840)'                      ,ToPeriod,ToPeriod,FL,Summary,False,RTypeToSQL('TxnLine'));
          if (FUser = 'Supervisor') or (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then
             ReportLines.Add('- Cash on Hand,"' +CurrToStrF(CashOnHand, ffNumber, 2)+'"');

          ChequesOnHand:=                 StkAtPeriodRepSection(Stock,'- Cheques on Hand', '6100000-6100000',FL,True,TP, DB);
          ChequesOnHand:= ChequesOnHand + TxnRepRelSection   (DB,'','(PLU = 2009850)',ToPeriod,ToPeriod,FL,Summary,False,RTypeToSQL('TxnLine'));
          if (FUser = 'Supervisor') or (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then
             ReportLines.Add('- Cheques on Hand,"' +CurrToStrF(ChequesOnHand, ffNumber, 2)+'"');

          TotalCashAndCheques := CashOnHand + ChequesOnHand;
          if (FUser = 'Supervisor') or (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then
             ReportLines.Add('"","-------------------"');
          if (FUser = 'Supervisor') or (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then
             ReportLines.Add('C - Total Cash,"'+CurrToStrF(TotalCashAndCheques, ffNumber, 2)+'"');

          if (FUser = 'Supervisor') or (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then
          begin
             ReportLines.Add('"",""');
             ReportLines.Add('"Stock On Hand",""');
             ReportLines.Add('"------------------------------------------------------------------------",""');
          end;
          TotalStock := 0;

         if User <> 'Supervisor' then
         begin
             FL.Clear;
             TotalStock := TotalStock + StkAtPeriodRepSection(Stock,'- Stamp Items'            ,'2009860,9010005-9019999,9020005-9020125',FL,True,TP,DB);
             TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Retail Items'           ,'2009870,9118000-9118180',FL,True,TP,DB);
             TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- BW Courier'             ,'2009880,9118190-9118350',FL,True,TP,DB);
             TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Merchandise'            ,'2009890,9118360-9118999',FL,True,TP,DB);
             TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Postal Orders'          ,'2009900,5100005-5101000',FL,True,TP,DB);
             TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Phil. First Day Covers' ,'2009910,7000400-7000499',FL,True,TP,DB);
             TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Phil. Souvenir Sheets'  ,'2009920,7000360-7000399',FL,True,TP,DB);
             TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Phil. Year Packs'       ,'2009930,7000300-7000359',FL,True,TP,DB);
             TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Phil. Other Items'      ,'2009940,7000010-7000299',FL,True,TP,DB);
             if (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then
             begin
                ReportLines.AddStrings(FL);
             end;
         end
         else
         begin
           FUser := 'Vendor';
           VendorStamp       := StkAtPeriodRepSection(Stock,'- Get Vendor Stamps ',  '2009950,9010005-9019999,9020005-9020125',FL,True,TP,DB);
           VendorPostalOrder := StkAtPeriodRepSection(nil  ,'- Get Vendor Postal Orders ', '2009960,5100005-5101000',FL,True,TP,DB);
           VendorRetail      := StkAtPeriodRepSection(nil  ,'- Get Vendor Retail        ', '2009970,9118000-9118180',FL,True,TP,DB);
           VendorBWCourier   := StkAtPeriodRepSection(nil  ,'- Get Vendor BW Courier    ', '2009970,9118190-9118350',FL,True,TP,DB);
           VendorMerch       := StkAtPeriodRepSection(nil  ,'- Get Vendor Merchandise   ', '2009970,9118360-9118999',FL,True,TP,DB);

           FUser := 'Supervisor';
           SuperStamp        := StkAtPeriodRepSection(Stock,'- Get Supervisor Stamps ',  '9010005-9019999,9020005-9020125',FL,True,TP,DB);

           ReportLines.Add('- Stamp Items,"'+CurrToStrF(SuperStamp-VendorStamp, ffNumber, 2)+'"');
           TotalStock := TotalStock + SuperStamp ;

           SuperRetail  := StkAtPeriodRepSection(nil  ,' Get Supervisor Retail Items'    ,'9118000-9118180',FL,True,TP,DB);
           ReportLines.Add('- Retail Items,"'+CurrToStrF(SuperRetail-VendorRetail, ffNumber, 2)+'"');
           TotalStock := TotalStock + SuperRetail ;

           SuperBWCourier  := StkAtPeriodRepSection(nil  ,' Get Supervisor BW Courier Items'    ,'9118190-9118350',FL,True,TP,DB);
           ReportLines.Add('- BW Courier Items,"'+CurrToStrF(SuperBWCourier-VendorBWCourier, ffNumber, 2)+'"');
           TotalStock := TotalStock + SuperBWCourier ;

           SuperMerch  := StkAtPeriodRepSection(nil  ,' Get Supervisor Merchandise Items'    ,'9118360-9118999',FL,True,TP,DB);
           ReportLines.Add('- Merchandise Items,"'+CurrToStrF(SuperMerch-VendorMerch, ffNumber, 2)+'"');
           TotalStock := TotalStock + SuperMerch ;

           SuperPostalOrder  := StkAtPeriodRepSection(nil  ,' Get Supervisor Postal Orders'    ,'5100005-5101000',FL,True,TP,DB);
           ReportLines.Add('- Postal Orders,"'+CurrToStrF(SuperPostalOrder-VendorPostalOrder, ffNumber, 2)+'"');
           TotalStock := TotalStock + SuperPostalOrder ;

           TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Phil. First Day Covers' ,'2009910,7000400-7000499',ReportLines,True,TP,DB);
           TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Phil. Souvenir Sheets'  ,'2009920,7000360-7000399',ReportLines,True,TP,DB);
           TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Phil. Year Packs'       ,'2009930,7000300-7000359',ReportLines,True,TP,DB);
           TotalStock := TotalStock + StkAtPeriodRepSection(nil  ,'- Phil. Other Items'      ,'2009940,7000010-7000299',ReportLines,True,TP,DB);

             // Stock supplied to agencies on credit should only show on the Supervisor account

           ReportLines.Add('"Stock Supplied On Credit",""');
           ReportLines.Add('- Stamps,"'+CurrToStrF(VendorStamp, ffNumber, 2)+'"');
           ReportLines.Add('- Retail Items,"'+CurrToStrF(VendorRetail, ffNumber, 2)+'"');
           ReportLines.Add('- BW Courier Items,"'+CurrToStrF(VendorBWCourier, ffNumber, 2)+'"');
           ReportLines.Add('- Merchandise Items,"'+CurrToStrF(VendorMerch, ffNumber, 2)+'"');
           ReportLines.Add('- Postal Orders,"'+CurrToStrF(VendorPostalOrder, ffNumber, 2)+'"');
         end ;


          if (FUser = 'Supervisor') or (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then
          begin
             ReportLines.Add('"","-------------------"');
             ReportLines.Add('D - Total Stock,"'+CurrToStrF(TotalStock, ffNumber, 2)+'"');
          end;

          ReportLines.Add('"",""');
          ReportLines.Add('"Balancing",""');
          ReportLines.Add('"------------------------------------------------------------------------",""');

          BalancingFigure := TotalReceipt-TotalPayment;
          ReportLines.Add('E - Balancing Figure,"'+CurrToStrF(BalancingFigure, ffNumber, 2)+'"');

          ReportLines.Add('"",""');
          BalancingFigureToProve := TotalCashAndCheques + TotalStock;
          ReportLines.Add('F - Balancing Figure To Prove,"'+CurrToStrF(BalancingFigureToProve, ffNumber, 2)+'"');

          ReportLines.Add('"",""');
          ActualCash := TxnRepSection   (DB,'I - Actual Cash'         ,'((PLU >= 6000001) and (PLU <= 6100001))',ToPeriod,ToPeriod,FL,stSummary,False,'StockDec');
          ReportLines.Add('G - Actual Cash,"'+CurrToStrF(ActualCash, ffNumber, 2)+'"');

          ReportLines.Add('"",""');
          if TotalCashAndCheques > ActualCash then
          begin
             if (FUser = 'Supervisor') or (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then
                ReportLines.Add('Cash Shortage,"'+CurrToStrF(ActualCash-TotalCashAndCheques, ffNumber, 2)+'"')
             else
                ReportLines.Add('Cash Shortage," "');
          end;
          if TotalCashAndCheques < ActualCash then
          begin
             if (FUser = 'Supervisor') or (GetGPCSRegString('','Show Cash Balance','N') <> 'N') then
                ReportLines.Add('Cash Over,"'+CurrToStrF(ActualCash-TotalCashAndCheques, ffNumber, 2)+'"')
             else
                ReportLines.Add('Cash Over," "');
          end;
          if TotalCashAndCheques = ActualCash then
          begin
             ReportLines.Add('"Cash Balances",""');
          end;
          ReportLines.Add('"------------------------------------------------------------------------",""');

        end;
        FL.Free;

      end
    //*****************************************************************************************************//
    //*                                                                                                   *//
    //*                                 Botswana Cash Account - end                                       *//
    //*                                                                                                   *//
    //*****************************************************************************************************//

    //*****************************************************************************************************//
    //*                                                                                                   *//
    //*                 Swaziland Stock Returns, Stock Orders and Stock Declaration printing              *//
    //*                                               Start                                               *//
    //*                                                                                                   *//
    //*****************************************************************************************************//

       else if RType = 'SwaziReturns' then
       begin
          SL.Add('"Inventory Returns",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,'Cash/Cheques'           ,'Ident = ">Supervisor" and ((PLU >= 6000001) and (PLU <= 6020000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Cheques'                ,'Ident = ">Supervisor" and  (PLU  = 6100000)                      ',FP,TP,SL,stDetail,False,'StockTx');
//          TV:=TxnRepSection(DB,'Vouchers'               ,'Ident = ">Supervisor" and  (PLU  = 6200000)                      ',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Postage Stamps'         ,'Ident = ">Supervisor" and ((PLU >= 9010001) and (PLU <= 9019999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Revenue Stamps'         ,'Ident = ">Supervisor" and ((PLU >= 9020000) and (PLU <= 9029999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Postage Due Labels'     ,'Ident = ">Supervisor" and ((PLU >= 9030000) and (PLU <= 9039999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Postal Orders'          ,'Ident = ">Supervisor" and ((PLU >= 5100001) and (PLU <= 5109999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'MTN Products'           ,'Ident = ">Supervisor" and ((PLU >= 2020000) and (PLU <= 2022999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Phone Cards'            ,'Ident = ">Supervisor" and ((PLU >= 2000010) and (PLU <= 2000999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'EasyCall Cards'         ,'Ident = ">Supervisor" and ((PLU >= 2010020) and (PLU <= 2010999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Umkhululi Ekhaya Cards' ,'Ident = ">Supervisor" and ((PLU >= 2011025) and (PLU <= 2011050))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Phumelela Items'        ,'Ident = ">Supervisor" and ((PLU >= 2023000) and (PLU <= 2023010))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Philatelic'             ,'Ident = ">Supervisor" and ((PLU >= 7000001) and (PLU <= 7000999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Reg Envelopes'          ,'Ident = ">Supervisor" and ((PLU >= 2024000) and (PLU <= 2024010))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Aerogrammes'            ,'Ident = ">Supervisor" and ((PLU >= 2024020) and (PLU <= 2024020))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'PO Box Keys'            ,'Ident = ">Supervisor" and ((PLU >= 8000010) and (PLU <= 8000010))',FP,TP,SL,stDetail,False,'StockTx');
       end
       else if RType = 'SwaziOrders' then
       begin
          SL.Add('"Inventory Orders",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,'Cash/Cheques'           ,'Ident = "<Supervisor" and ((PLU >= 6000001) and (PLU <= 6020000))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Cheques'                ,'Ident = "<Supervisor" and  (PLU  = 6100000)                      ',FP,TP,SL,stDetail,False,'StockTx');
//          TV:=TxnRepSection(DB,'Vouchers'               ,'Ident = "<Supervisor" and  (PLU  = 6200000)                      ',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Postage Stamps'         ,'Ident = "<Supervisor" and ((PLU >= 9010001) and (PLU <= 9019999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Revenue Stamps'         ,'Ident = "<Supervisor" and ((PLU >= 9020000) and (PLU <= 9029999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Postage Due Labels'     ,'Ident = "<Supervisor" and ((PLU >= 9030000) and (PLU <= 9039999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Postal Orders'          ,'Ident = "<Supervisor" and ((PLU >= 5100001) and (PLU <= 5109999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'MTN Products'           ,'Ident = "<Supervisor" and ((PLU >= 2020000) and (PLU <= 2022999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Phone Cards'            ,'Ident = "<Supervisor" and ((PLU >= 2000010) and (PLU <= 2000999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'EasyCall Cards'         ,'Ident = "<Supervisor" and ((PLU >= 2010020) and (PLU <= 2010999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Umkhululi Ekhaya Cards' ,'Ident = "<Supervisor" and ((PLU >= 2011025) and (PLU <= 2011050))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Phumelela Items'        ,'Ident = "<Supervisor" and ((PLU >= 2023000) and (PLU <= 2023010))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Philatelic'             ,'Ident = "<Supervisor" and ((PLU >= 7000001) and (PLU <= 7000999))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Reg Envelopes'          ,'Ident = "<Supervisor" and ((PLU >= 2024000) and (PLU <= 2024010))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'Aerogrammes'            ,'Ident = "<Supervisor" and ((PLU >= 2024020) and (PLU <= 2024020))',FP,TP,SL,stDetail,False,'StockTx');
          TV:=TxnRepSection(DB,'PO Box Keys'            ,'Ident = "<Supervisor" and ((PLU >= 8000010) and (PLU <= 8000010))',FP,TP,SL,stDetail,False,'StockTx');
       end
       else if RType = 'SwaziDeclaration' then
       begin
          SL.Add('"Inventory Declaration",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,'Cash/Cheques'           ,'((PLU >= 6000001) and (PLU <= 6020000))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Cheques'                ,' (PLU  = 6100000)                      ',FP,TP,SL,stDetail,False,'StockDec');
//          TV:=TxnRepSection(DB,'Vouchers'               ,' (PLU  = 6200000)                      ',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Postage Stamps'         ,'((PLU >= 9010001) and (PLU <= 9019999))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Revenue Stamps'         ,'((PLU >= 9020000) and (PLU <= 9029999))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Postage Due Labels'     ,'((PLU >= 9030000) and (PLU <= 9039999))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Postal Orders'          ,'((PLU >= 5100001) and (PLU <= 5109999))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'MTN Products'           ,'((PLU >= 2020000) and (PLU <= 2022999))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Phone Cards'            ,'((PLU >= 2000010) and (PLU <= 2000999))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'EasyCall Cards'         ,'((PLU >= 2010020) and (PLU <= 2010999))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Umkhululi Ekhaya Cards' ,'((PLU >= 2011025) and (PLU <= 2011050))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Phumelela Items'        ,'((PLU >= 2023000) and (PLU <= 2023010))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Philatelic'             ,'((PLU >= 7000001) and (PLU <= 7000999))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Reg Envelopes'          ,'((PLU >= 2024000) and (PLU <= 2024010))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'Aerogrammes'            ,'((PLU >= 2024020) and (PLU <= 2024020))',FP,TP,SL,stDetail,False,'StockDec');
          TV:=TxnRepSection(DB,'PO Box Keys'            ,'((PLU >= 8000010) and (PLU <= 8000010))',FP,TP,SL,stDetail,False,'StockDec');
       end

    //*****************************************************************************************************//
    //*                                                                                                   *//
    //*                 Swaziland Stock Returns, Stock Orders and Stock Declaration printing              *//
    //*                                                End                                                *//
    //*                                                                                                   *//
    //*****************************************************************************************************//

    //*****************************************************************************************************//
    //*                                                                                                   *//
    //*                                 Swaziland Trial Balance and EOD Balance                           *//
    //*                                               Start                                               *//
    //*                                                                                                   *//
    //*****************************************************************************************************//
       else if ( RType = 'SwaziBalance') or  ( RType = 'EODSwaziBalance') then
       begin
          if ( RType = 'SwaziBalance') then
             SL.Add('"Trial Balance",""')
          else
             SL.Add('"End of Day Balance",""');

          SL.Add('"------------------------------","------------------------------"');
          DeclaredCash       :=TxnRepSection(DB,'Declared Cash'              ,'((PLU >= 6000001) and (PLU <= 6020000))',FP,TP,SL,stSummary,False,'StockDec');
          DeclaredCheques    :=TxnRepSection(DB,'Declared Cheques'           ,' (PLU  = 6100000)'                      ,FP,TP,SL,stSummary,False,'StockDec');
//          DeclaredVouchers   :=TxnRepSection(DB,'Declared Vouchers'          ,' (PLU  = 6200000)'                      ,FP,TP,SL,stSummary,False,'StockDec');
          DeclaredPostStamps :=TxnRepSection(DB,'Declared Postage Stamps'    ,'((PLU >= 9010001) and (PLU <= 9019999))',FP,TP,SL,stSummary,False,'StockDec');
          DeclaredRevStamps  :=TxnRepSection(DB,'Declared Revenue Stamps'    ,'((PLU >= 9020000) and (PLU <= 9029999))',FP,TP,SL,stSummary,False,'StockDec');
          DeclaredPostageDue :=TxnRepSection(DB,'Declared Postage Due Labels','((PLU >= 9030000) and (PLU <= 9039999))',FP,TP,SL,stSummary,False,'StockDec');
          DeclaredPostOrders :=TxnRepSection(DB,'Declared Postal Orders'     ,'((PLU >= 5100001) and (PLU <= 5109999))',FP,TP,SL,stSummary,False,'StockDec');
          DeclaredMTN        :=TxnRepSection(DB,'Declared MTN Products'      ,'((PLU >= 2020000) and (PLU <= 2022999))',FP,TP,SL,stSummary,False,'StockDec');
          DeclaredPhoneCards :=TxnRepSection(DB,'Declared Phone Cards'       ,'((PLU >= 2000010) and (PLU <= 2000999))',FP,TP,SL,stSummary,False,'StockDec');
          DeclaredEasyCall   :=TxnRepSection(DB,'Declared EasyCall Cards'    ,'((PLU >= 2010020) and (PLU <= 2010999))',FP,TP,SL,stSummary,False,'StockDec');
          DeclaredUmkhululi  :=TxnRepSection(DB,'Declared Umkhululi Ekhaya Cards'    ,'((PLU >= 2011025) and (PLU <= 2011050))',FP,TP,SL,stSummary,False,'StockDec');
          DeclaredPhumelela  :=TxnRepSection(DB,'Declared Phumelela Items'   ,'((PLU >= 2023000) and (PLU <= 2023010))',FP,TP,SL,stSummary,False,'StockDec');
          DeclaredPhil       :=TxnRepSection(DB,'Declared Philatelic'        ,'((PLU >= 7000001) and (PLU <= 7000999))',FP,TP,SL,stSummary,False,'StockDec');
          DeclaredRegEnv     :=TxnRepSection(DB,'Declared Reg Envelopes'     ,'((PLU >= 2024000) and (PLU <= 2024010))',FP,TP,SL,stSummary,False,'StockDec');
          DeclaredAerogrammes:=TxnRepSection(DB,'Declared Aerogrammes'       ,'((PLU >= 2024020) and (PLU <= 2024020))',FP,TP,SL,stSummary,False,'StockDec');
          DeclaredPOBoxKeys  :=TxnRepSection(DB,'Declared PO Box Keys'       ,'((PLU >= 8000010) and (PLU <= 8000010))',FP,TP,SL,stSummary,False,'StockDec');
          SL.Add('" "," "');
          ActualCash         := TxnRepSection(DB,'Total Cash','Prod = ''Product.Cash''',FP,TP,SL,Summary,False,'TxnTotal'' or RecType = ''StartDay');
          ActualCheques      := StkRepSection(AStock,'Total Cheques'           ,'6100000-6100000',SL,False);
//          ActualVouchers     := StkRepSection(AStock,'Total Vouchers'          ,'6200000-6200000',SL,False);
          ActualPostStamps   := StkRepSection(AStock,'Total Postage Stamps'    ,'9010001-9019999',SL,False);
          ActualRevStamps    := StkRepSection(AStock,'Total Revenue Stamps'    ,'9020000-9029999',SL,False);
          ActualPostageDue   := StkRepSection(AStock,'Total Postage Due Labels','9030000-9039999',SL,False);
          ActualPostOrders   := StkRepSection(AStock,'Total Postal Orders'     ,'5100001-5102000',SL,False);
          ActualMTN          := StkRepSection(AStock,'Total MTN Products'      ,'2020000-2022999',SL,False);
          ActualPhoneCards   := StkRepSection(AStock,'Total Phone Cards'       ,'2000010-2000999',SL,False);
          ActualEasyCall     := StkRepSection(AStock,'Total EasyCall Cards'          ,'2010020-2010999',SL,False);
          ActualUmkhululi    := StkRepSection(AStock,'Total Umkhululi Ekhaya Cards'  ,'2011025-2011050',SL,False);
          ActualPhumelela    := StkRepSection(AStock,'Total Phumelela Items'   ,'2023000-2023010',SL,False);
          ActualPhil         := StkRepSection(AStock,'Total Philatelic'        ,'7000001-7000999',SL,False);
          ActualRegEnv       := StkRepSection(AStock,'Total Reg Envelopes'     ,'2024000-2024010',SL,False);
          ActualAerogrammes  := StkRepSection(AStock,'Total Aerogrammes'       ,'2024020-2024020',SL,False);
          ActualPOBoxKeys    := StkRepSection(AStock,'Total PO Box Keys'       ,'8000010-8000010',SL,False);
          SL.Add('" "," "');
          if ActualCash > DeclaredCash then
             SL.Add('"Cash Shortage of","'+CurrToStrF(ActualCash-DeclaredCash,ffNumber, 2)+'"')
          else if ActualCash < DeclaredCash then
             SL.Add('"Cash Excess of","'+CurrToStrF(DeclaredCash-ActualCash,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Cash"," "');

          if ActualCheques > DeclaredCheques then
             SL.Add('"Cheques Shortage of","'+CurrToStrF(ActualCheques-DeclaredCheques,ffNumber, 2)+'"')
          else if ActualCheques < DeclaredCheques then
             SL.Add('"Cheques Excess of","'+CurrToStrF(DeclaredCheques-ActualCheques,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Cheques"," "');

//          if ActualVouchers > DeclaredVouchers then
//             SL.Add('"Vouchers Shortage of","'+CurrToStrF(ActualVouchers-DeclaredVouchers,ffNumber, 2)+'"')
//          else if ActualCheques < DeclaredCheques then
//             SL.Add('"Vouchers Excess of","'+CurrToStrF(DeclaredVouchers-ActualVouchers,ffNumber, 2)+'" "')
//          else
//             SL.Add('"Zero Excess Vouchers"," "');

          if ActualPostStamps > DeclaredPostStamps then
             SL.Add('"Postage Stamps Shortage of","'+CurrToStrF(ActualPostStamps-DeclaredPostStamps,ffNumber, 2)+'"')
          else if ActualPostStamps < DeclaredPostStamps then
             SL.Add('"Postage Stamps Excess of","'+CurrToStrF(DeclaredPostStamps-ActualPostStamps,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Postage Stamps"," "');

          if ActualRevStamps > DeclaredRevStamps then
             SL.Add('"Revenue Stamps Shortage of","'+CurrToStrF(ActualRevStamps-DeclaredRevStamps,ffNumber, 2)+'"')
          else if ActualRevStamps < DeclaredRevStamps then
             SL.Add('"Revenue Stamps Excess of","'+CurrToStrF(DeclaredRevStamps-ActualRevStamps,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Revenue Stamps"," "');

          if ActualPostageDue > DeclaredPostageDue then
             SL.Add('"Postage Due Labels Shortage of","'+CurrToStrF(ActualPostageDue-DeclaredPostageDue,ffNumber, 2)+'"')
          else if ActualPostageDue < DeclaredPostageDue then
             SL.Add('"Postage Due Labels Excess of","'+CurrToStrF(DeclaredPostageDue-ActualPostageDue,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Postage Due Labels "," "');

          if ActualPostOrders > DeclaredPostOrders then
             SL.Add('"Postal Order Shortage of","'+CurrToStrF(ActualPostOrders-DeclaredPostOrders, ffNumber, 2)+'"')
          else if ActualPostOrders < DeclaredPostOrders then
             SL.Add('"Postal Order Excess of","'+CurrToStrF(DeclaredPostOrders-ActualPostOrders,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Postal Orders"," "');

          if ActualMTN > DeclaredMTN then
             SL.Add('"MTN Shortage of","'+CurrToStrF(ActualMTN-DeclaredMTN,ffNumber, 2)+'"')
          else if ActualMTN < DeclaredMTN then
             SL.Add('"MTN Excess of","'+CurrToStrF(DeclaredMTN-ActualMTN,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero MTN  Retail"," "');

          if ActualPhoneCards > DeclaredPhoneCards then
             SL.Add('"Phone Cards Shortage of","'+CurrToStrF(ActualPhoneCards-DeclaredPhoneCards,ffNumber, 2)+'"')
          else if ActualPhoneCards < DeclaredPhoneCards then
             SL.Add('"Phone Cards Excess of","'+CurrToStrF(DeclaredPhoneCards-ActualPhoneCards,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Phone Cards"," "');

          if ActualEasyCall > DeclaredEasyCall then
             SL.Add('"EasyCall Cards Shortage of","'+CurrToStrF(ActualEasyCall-DeclaredEasyCall,ffNumber, 2)+'"')
          else if ActualEasyCall < DeclaredEasyCall then
             SL.Add('"EasyCall Cards Excess of","'+CurrToStrF(DeclaredEasyCall-ActualEasyCall,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess EasyCall Cards"," "');

          if ActualUmkhululi > DeclaredUmkhululi then
             SL.Add('"Umkhululi Ekhaya Cards Shortage of","'+CurrToStrF(ActualUmkhululi-DeclaredUmkhululi,ffNumber, 2)+'"')
          else if ActualUmkhululi < DeclaredUmkhululi then
             SL.Add('"Umkhululi Ekhaya Cards Excess of","'+CurrToStrF(DeclaredUmkhululi-ActualUmkhululi,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Umkhululi Ekhaya Cards"," "');

          if ActualPhumelela > DeclaredPhumelela then
             SL.Add('"Phumelela Shortage of","'+CurrToStrF(ActualPhumelela-DeclaredPhumelela,ffNumber, 2)+'"')
          else if ActualPhumelela < DeclaredPhumelela then
             SL.Add('"Phumelela Excess of","'+CurrToStrF(DeclaredPhumelela-ActualPhumelela,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Phumelela Cards"," "');

          if ActualPhil > DeclaredPhil then
             SL.Add('"Philatelic Shortage of","'+CurrToStrF(ActualPhil-DeclaredPhil,ffNumber, 2)+'"')
          else if ActualPhil < DeclaredPhil then
             SL.Add('"Philatelic Excess of","'+CurrToStrF(DeclaredPhil-ActualPhil,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Phil Cards"," "');

          if ActualRegEnv > DeclaredRegEnv then
             SL.Add('"Reg Envelopes Shortage of","'+CurrToStrF(ActualRegEnv-DeclaredRegEnv,ffNumber, 2)+'"')
          else if ActualRegEnv < DeclaredRegEnv then
             SL.Add('"Reg Envelopes Excess of","'+CurrToStrF(DeclaredRegEnv-ActualRegEnv,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Reg Envelopes "," "');

          if ActualAerogrammes > DeclaredAerogrammes then
             SL.Add('"Aerogrammes Shortage of","'+CurrToStrF(ActualAerogrammes-DeclaredAerogrammes,ffNumber, 2)+'"')
          else if ActualAerogrammes < DeclaredAerogrammes then
             SL.Add('"Aerogrammes Excess of","'+CurrToStrF(DeclaredAerogrammes-ActualAerogrammes,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess Aerogrammes "," "');

          if ActualPOBoxKeys > DeclaredPOBoxKeys then
             SL.Add('"PO Box Keys Shortage of","'+CurrToStrF(ActualPOBoxKeys-DeclaredPOBoxKeys,ffNumber, 2)+'"')
          else if ActualPOBoxKeys < DeclaredPOBoxKeys then
             SL.Add('"PO Box Keys Excess of","'+CurrToStrF(DeclaredPOBoxKeys-ActualPOBoxKeys,ffNumber, 2)+'" "')
          else
             SL.Add('"Zero Excess PO Box Keys "," "');



          SL.Add('" "," "');
          SL.Add('"Cash carried forward","'+CurrToStrF(ActualCash,ffNumber, 2)+'"');
          SL.Add('"Cheques c/f","'+CurrToStrF(ActualCheques,ffNumber, 2)+'"');
          SL.Add('"Stock carried forward","'+CurrToStrF( ActualPostStamps
                                                              +ActualRevStamps
                                                              +ActualPostageDue
                                                              +ActualPostOrders
                                                              +ActualMTN
                                                              +ActualPhoneCards
                                                              +ActualEasyCall
                                                              +ActualUmkhululi
                                                              +ActualPhumelela
                                                              +ActualPhil
                                                              +ActualRegEnv
                                                              +ActualPOBoxKeys,ffNumber, 2)+'"');

          if ( RType = 'EODSwaziBalance') then
          begin
             SL.Add('" "," "');
             SL.Add('"------------------------------","------------------------------"');
             SL.Add('"Signature "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('" "," "');
             SL.Add('"------------------------------","------------------------------"');
          end ;
       end
    //*****************************************************************************************************//
    //*                                                                                                   *//
    //*                                 Swaziland Trial Balance and EOD Balance                           *//
    //*                                                End                                                *//
    //*                                                                                                   *//
    //*****************************************************************************************************//

       else if RType = 'PakCash Account' then
       begin
          FL := TPackStringList.Create;
          SL.Add('"Cash Account",""');
          SL.Add('"------------------------------","------------------------------"');
          SL.Add('"RECEIPTS",""');

    //
    // (( PLU >= 042000021 ) and (PLU <= 042000024 ))

          TotalReceipt :=                TxnRepSection(DB,'Opening Balance'                                ,'( PLU = 061000000 )',FP,TP,SL,Summary,False,'TxnTotal');
    {B/O} TotalReceipt := TotalReceipt + TxnRepSection(DB,'Postage due on H.O. Letter Mail '               ,'( PLU = 010510051 )' ,FP,TP,SL,Summary,False,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Cash received from H.O. and S.O.'               ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnLine');
    {B/O} TotalReceipt := TotalReceipt + TxnRepSection(DB,'Postage due on Direct Letter Mail'              ,'( PLU = 010510052 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    {B/O} TotalReceipt := TotalReceipt + TxnRepSection(DB,'Postage realised in cash'                       ,'( PLU = 010510053 )' ,FP,TP,SL,Summary,False,'TxnTotal');
          //use total stock to find sold franking labels
          TotalStock := TxnRepSection(DB,'Franking machine receipts',
              ' (Quantity < 0)'
            + ' and ( '
            + '    ( PLU between 001000000 and 001000750 ) '
            + ' or ( PLU between 001000900 and 001000950 ) '
            + ' or ( PLU = 010500011)'
            + ' )',
            FP,TP,FL,Summary,False,'PrLabel');
          //add in backoffice franking machine receipts
          TotalStock := TotalStock + TxnRepSection(DB,'Franking machine receipts', '(PLU = 010500011)', FP,TP,FL,Summary,False, 'TxnLine');
          //consolidate franking receipts
          TotalReceipt := TotalReceipt + TotalStock;
          SL.Add('"Franking machine receipts","'         +CurrToStrF(TotalStock, ffNumber, 2)+'"');

          FL.Free;
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Franking machine renewals'                   ,'( PLU = 010500010 ) ',FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Fax Mail Service Receipt'                    ,'( PLU = 001000802 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'International Speed Post Charges'            ,'( PLU = 001000804 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Urgent Mail Service Charges'                 ,'( PLU = 001000800 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Air Express (Airex) Charges'                 ,'( PLU = 001000801 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'L.E.S. Charges Realised'                     ,'( PLU = 001000803 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Central Excise Duty'                         ,'(( PLU >= 001000805 ) and ( PLU <= 001000808 ))' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Money Order - Value'                         ,'( PLU = 002000020 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Money Order - Commission'                    ,'( PLU = 002000021 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Urgent Money Order - Value'                  ,'( PLU = 002000040 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Urgent Money Order - Commission'             ,'( PLU = 002000041 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Urgent Money Order - Fee'                    ,'( PLU = 002000042 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Fax Money Order - Value'                     ,'( PLU = 002000030 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Fax Money Order - Commission'                ,'( PLU = 002000031 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Fax Money Order - Fee'                       ,'( PLU = 002000032 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Postal Draft - Value'                        ,'( PLU = 002000010 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Postal Draft - Commission'                   ,'( PLU = 002000011 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Pakistan Postal Order - Value'               ,'((PLU >= 005000000) and (PLU <= 5010000))' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Pakistan Postal Order - Commission'          ,'( PLU = 002000002 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'National Registration Forms sold'            ,'( PLU = 9080190 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Money Order Forms sold'                      ,'( PLU = 9080200 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Motorway Code Books - Urdu'                  ,'( PLU = 9080230 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Motorway Code Books - English'               ,'( PLU = 9080220 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Highway Code Books'                          ,'( PLU = 9080240 )' ,FP,TP,SL,Summary,False,'TxnLine');     TotalReceipt := TotalReceipt + TxnRepSection(DB,'Agricultural Loan Pass Books sold'           ,'( PLU = 9080210 )' ,FP,TP,SL,Summary,False,'TxnLine');
    {}      TotalReceipt := TotalReceipt + TxnRepSection(DB,'Sale of Fed. Gov. Attestation Stamps'        ,'((PLU >= 9070500) and (PLU <= 9075000))',FP,TP,SL,Summary,False,'TxnTotal');

    //  CHECK PLUs for savings bank deposit stuff
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'SB Deposit - Ordinary Account'               ,'( PLU = 006000102 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'SB Deposit - Security Account'               ,'( PLU = 006000602 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'SB Deposit - Public Account'                 ,'( PLU = 006000702 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'SB Deposit - GIRO Account'                   ,'( PLU = 006000502 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'SB Deposit - Mobile Account'                 ,'( PLU = 006000402 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'SB Deposit - Special Savings Account'        ,'( PLU = 006000202 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'SB Deposit - Mahana Amdhani'                 ,'( PLU = 006000302 )' ,FP,TP,SL,Summary,False,'TxnLine');

          // What are these lines for ?? current PLUs are for pension deposits - when are they made
          // Does not make sense - there are separate lines for Pension Payments/Receipts
    // X //{ ? } TotalReceipt := TotalReceipt + TxnRepSection(DB,'Army Pensioners SB Accounts'                 ,'((PLU = 10000001) or (PLU = 10000101))' ,FP,TP,SL,Summary,False,'TxnLine');
    // X //{ ? } TotalReceipt := TotalReceipt + TxnRepSection(DB,'P.A.F. Pensioners SB Accounts'               ,'( PLU = 10000601 )' ,FP,TP,SL,Summary,False,'TxnLine');
    // X //{ ? } TotalReceipt := TotalReceipt + TxnRepSection(DB,'Naval Pensioners SB Accounts'                ,'( PLU = 10000501 )' ,FP,TP,SL,Summary,False,'TxnLine');
    // X //{ ? } TotalReceipt := TotalReceipt + TxnRepSection(DB,'F.C. Pensioners SB Accounts'                 ,'( PLU = 10000701 )' ,FP,TP,SL,Summary,False,'TxnLine');

          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Special Savings Certificate (Regd.)'         ,'(PLU = 006000920) or (PLU = 006000921)' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Special Savings Certificate (Bearer)'        ,'(PLU = 006000930) or (PLU = 006000931)' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Defence Savings Certificate'                 ,'(PLU = 006000900) or (PLU = 006000901)' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Regular Income Certificate'                  ,'(PLU = 006000940) or (PLU = 006000941)' ,FP,TP,SL,Summary,False,'TxnLine');
    {B/O}   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Income Tax Receipts'  {WHT for SB & Cert}    ,'( PLU = 010510054 )' ,FP,TP,SL,Summary,False,'TxnTotal');
          { Same line as above (Income Tax Rec) for WHT on accounts and Certs - not sure }
    // X //   TotalReceipt := TotalReceipt + TxnRepSection(DB,'R.I.C. - withholding tax'                    ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnLine');

          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Motor Vehicle Tax collection'                ,'( PLU = 007000002 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'M.V.T. withholding tax'                      ,'( PLU = 007000010 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'M.V.T. provincial tax'                       ,'( PLU = 007000020 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'M.V.T. seat tax'                             ,'( PLU = 007000030 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'M.V.T. wealth tax'                           ,'( PLU = 007000040 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Driving Licence Revenue'                     ,'( PLU = 007000001 )' ,FP,TP,SL,Summary,False,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Arms Licence Penalty Revenue'                ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');

    {X}   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Drawn from treasury - cash'                  ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnLine');
    {X}   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Drawn from treasury - cheques'               ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnLine');
    {X}   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Receipt from zonal Stamps store'             ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnLine');
    {X}   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Receipts from other Head Offices'            ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    {X}   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Cash remitted from other offices'            ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');

          TotalReceipt := TotalReceipt + TxnRepSection(DB,'PLI - Premiums received'                     ,'( PLU = 006000800 ) or (PLU = 006000801)' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'PLI - loan repayments received'              ,'( PLU = 006000803 )' ,FP,TP,SL,Summary,False,'TxnTotal');

          { what is this line for }
    {X}   TotalReceipt := TotalReceipt + TxnRepSection(DB,'P.O. Annuity Receipts'                       ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');

          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Customs Duty - letter mail'                  ,'( PLU = 002000210 )' ,FP,TP,SL,Summary,False,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Customs Duty - parcel mail'                  ,'( PLU = 002000220 )' ,FP,TP,SL,Summary,False,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Zakat Collection'                            ,'( PLU = 006000001 )' ,FP,TP,SL,Summary,False,'TxnTotal');

    {X}   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Recovery of Pension Overpay - Army'          ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    {X}   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Recovery of Pension Overpay - PAF'           ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    {X}   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Recovery of Pension Overpay - Navy'          ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    {X}   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Recovery of Pension Overpay - Fed Cons'      ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    {X}   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Recovery of Pension Overpay - War Injury'    ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    {X}   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Recovery of Pension Overpay - Postal'        ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    // X //  TotalReceipt := TotalReceipt + TxnRepSection(DB,'Recovery of Overpayment - Combined'        ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    {X}   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Recovery of Pension Overpay - P.T.C.L.'      ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    {X}   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Recovery of Pension Overpay - CDA'           ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    {X}   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Recovery of Pension Overpay - other'         ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    {X}   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Recovery of R.I.C. service charges'          ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');

    // X //   TotalReceipt := TotalReceipt + TxnRepSection(DB,'N.T.N. cards'                                ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    // X //   TotalReceipt := TotalReceipt + TxnRepSection(DB,'N.I.C. cards'                                ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    { ?X }TotalReceipt := TotalReceipt + TxnRepSection(DB,'Bait-ul-mall receipts'                       ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Issue of PTV Licence'                        ,'( PLU = 008000001 )',FP,TP,SL,Summary,False,'TxnTotal');
    // X //   TotalReceipt := TotalReceipt + TxnRepSection(DB,'PO Commission on PTV Licences'               ,'( PLU = -1 )',FP,TP,SL,Summary,False,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Electricity Bill Collection'                 ,'( PLU = 008000000 )',FP,TP,SL,Summary,False,'TxnTotal');
    // X //   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Electricity Bill  - commission'              ,'( PLU = -1 )',FP,TP,SL,Summary,False,'TxnTotal');
    // X //   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Sui Gas Bill Collection'                     ,'( PLU = -1 )',FP,TP,SL,Summary,False,'TxnTotal');
    // X //   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Sui Gas Bill - commission'                   ,'( PLU = -1 )',FP,TP,SL,Summary,False,'TxnTotal');
    // X //   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Telephone Bill Collection'                   ,'( PLU = -1 )',FP,TP,SL,Summary,False,'TxnTotal');
    // X //   TotalReceipt := TotalReceipt + TxnRepSection(DB,'Telephone Bill  - commission'                ,'( PLU = -1 )',FP,TP,SL,Summary,False,'TxnTotal');
          TotalReceipt := TotalReceipt + TxnRepSection(DB,'Unclassified Receipts'                       ,'((PLU >= 003000000 and PLU <= 003000002) or (PLU = 010500001) or (PLU = 010500005) )',FP,TP,SL,Summary,False,'TxnTotal');
    //      TotalReceipt := TotalReceipt + TxnRepSection(DB,'Food Support Program (Bait-ul-mall)'           ,'( PLU = 010001200 )',FP,TP,SL,Summary,False,'TxStkFrom');

          DoFullUserSearch:=False;
          SL.Add('"",""');
          SL.Add('"Total Receipts","'+CurrToStrF(TotalReceipt, ffNumber, 2)+'"');
          SL.Add('"",""');
          if Print2x2 then
          begin
             SL.Add('"",""');
             SL.Add('"",""');
             SL.Add('"",""');
             SL.Add('"",""');
             SL.Add('"",""');
             SL.Add('"",""');
             SL.Add('"",""');
             SL.Add('"",""');
             SL.Add('"",""');
             SL.Add('"",""');
          end;
          SL.Add('"PAYMENTS",""');
    {B/O} TotalPayment :=                TxnRepSection(DB,'Undeliverable Postage due Mail to H.O.'            ,'( PLU = 010510001 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    {X}   TotalPayment := TotalPayment + TxnRepSection(DB,'Cash Remitted to H.O./S.O'                         ,'( PLU = -1 )',FP,TP,SL,Summary,False,'TxnTotal');
    {B/O} TotalPayment := TotalPayment + TxnRepSection(DB,'Postage due Mail sent to R.L.O./Fwd Postage'       ,'( PLU = 010510002 )',FP,TP,SL,Summary,False,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'Money Orders Paid - Ordinary'                      ,'( PLU = 002000022 )',FP,TP,SL,Summary,False,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'Money Orders Paid - Urgent'                        ,'( PLU = 002000043 )',FP,TP,SL,Summary,False,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'Money Orders Paid - Fax'                           ,'( PLU = 002000033 )',FP,TP,SL,Summary,False,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'Postal Draft Paid'                                 ,'( PLU = 002000015 )',FP,TP,SL,Summary,False,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'Pakistan Postal Orders Paid'                       ,'( PLU = 002000005 )',FP,TP,SL,Summary,False,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'British Postal Orders Paid'                        ,'( PLU = 002000006 )',FP,TP,SL,Summary,False,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'SB Withdrawal - Ordinary Savings'                  ,'( PLU = 006000103 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'SB Withdrawal - Mobile'                            ,'( PLU = 006000403 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'SB Withdrawal - GIRO'                              ,'( PLU = 006000503 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'SB Withdrawal - Security Deposit'                  ,'( PLU = 006000603 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'SB Withdrawal - Public'                            ,'( PLU = 006000703 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'SB Withdrawal Special Savings - principal'         ,'( PLU = 006000203 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'SB Withdrawal Special Savings - profit'            ,'( PLU = 006000204 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'SB Withdrawal Mahana Amdani - principal'           ,'( PLU = 006000303 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'SB Withdrawal Mahana Amdani - profit'              ,'( PLU = 006000304 )' ,FP,TP,SL,Summary,False,'TxnLine');
          // What are these lines for ?? current PLUs are for pension Withdrawals - when are they made
          // Does not make sense - there are separate lines for Pension Payments/Receipts
    // X //      TotalPayment := TotalPayment + TxnRepSection(DB,'SB Withdrawal - Army Pensioners'                   ,'((PLU = 10000000) or (PLU = 10000100))' ,FP,TP,SL,Summary,False,'TxnLine');
    // X //      TotalPayment := TotalPayment + TxnRepSection(DB,'SB Withdrawal - P.A.F. Pensioners'                 ,'( PLU = 10000600 )' ,FP,TP,SL,Summary,False,'TxnLine');
    // X //      TotalPayment := TotalPayment + TxnRepSection(DB,'SB Withdrawal - Naval Pensioners'                  ,'( PLU = 10000500 )' ,FP,TP,SL,Summary,False,'TxnLine');
    // X //      TotalPayment := TotalPayment + TxnRepSection(DB,'SB Withdrawal - F.C. Pensioners'                   ,'( PLU = 10000700 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'D.S.C. Discharge - Value'                          ,'( PLU = 006000902 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'D.S.C. Discharge - Profit'                         ,'( PLU = 006000903 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'S.S.C. (Regd) Discharge - Value'                   ,'( PLU = 006000922 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'S.S.C. (Regd) Discharge - Profit'                  ,'( PLU = 006000923 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'S.S.C. (Bearer) Discharge - Value'                 ,'( PLU = 006000932 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'S.S.C. (Bearer) Discharge - Profit'                ,'( PLU = 006000933 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'R.I.C. Discharge - Value'                          ,'( PLU = 006000942 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'R.I.C. Discharge - Profit'                         ,'( PLU = 006000943 )' ,FP,TP,SL,Summary,False,'TxnLine');
    {X}   TotalPayment := TotalPayment + TxnRepSection(DB,'R.I.C. - withholding tax'                          ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnLine');
    // X //      TotalPayment := TotalPayment + TxnRepSection(DB,'Income Tax on Goods Transport'                     ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnLine');
    // X //      TotalPayment := TotalPayment + TxnRepSection(DB,'Income Tax on Private Motor Cars'                  ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnLine');
    // X //      TotalPayment := TotalPayment + TxnRepSection(DB,'M.V.T. withholding tax'                            ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnLine');
    // X //      TotalPayment := TotalPayment + TxnRepSection(DB,'M.V.T. provincial tax'                             ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnLine');
    // X //      TotalPayment := TotalPayment + TxnRepSection(DB,'M.V.T. seat tax'                                   ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnLine');
    // X //      TotalPayment := TotalPayment + TxnRepSection(DB,'M.V.T. wealth tax'                                 ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnLine');
    // X //      TotalPayment := TotalPayment + TxnRepSection(DB,'Remitted to treasury - cash'                       ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnLine');
    // X //      TotalPayment := TotalPayment + TxnRepSection(DB,'Remitted to treasury - cheques'                    ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnLine');
             { REMITTED TO TREASURY }
    {X}      TotalPayment := TotalPayment + TxnRepSection(DB,'Cash remitted to other offices'                    ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    {X}      TotalPayment := TotalPayment + TxnRepSection(DB,'PLI - Premiums remitted'                           ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnLine');
    {X}      TotalPayment := TotalPayment + TxnRepSection(DB,'PLI - Loan repayments remitted'                    ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnLine');
    {X}      TotalPayment := TotalPayment + TxnRepSection(DB,'PO Annuity payments remitted'                      ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnLine');

    //      TotalPayment := TotalPayment + TxnRepSection(DB,'P&T Pension Overpayment - PPO'                     ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    //      TotalPayment := TotalPayment + TxnRepSection(DB,'P&T Pension Overpayment - Fed Govnt (PPO)'         ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    //      TotalPayment := TotalPayment + TxnRepSection(DB,'P&T Pension Overpayment - PTC'                     ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'Military Pension payment - Army'             {@??} ,'( PLU = 010000000 )' ,FP,TP,SL,Summary,False,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'Military Pension payment - PAF'              {@??} ,'( PLU = 010000600 )' ,FP,TP,SL,Summary,False,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'Military Pension payment - Navy'             {@??} ,'( PLU = 010000500 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'Military Pension payment - F.C.'             {@??} ,'( PLU = 010000700 )' ,FP,TP,SL,Summary,False,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'Military Pension payment - War Injury'       {@??} ,'( PLU = 010000400 )' ,FP,TP,SL,Summary,False,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'Postal Pension payments'                           ,'( PLU = 010000900 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    // X //      TotalPayment := TotalPayment + TxnRepSection(DB,'Combined Pension payments'                         ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'P.T.C.L. Pension payments'                         ,'( PLU = 010001000 )' ,FP,TP,SL,Summary,False,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'C.D.A. Pension payments'                           ,'( PLU = 010000800 )' ,FP,TP,SL,Summary,False,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'Audit Office Pension payments'                     ,'( PLU = 010001100 )' ,FP,TP,SL,Summary,False,'TxnTotal');
          // what about "indian Libability", "HK/Singapore Burma" and "War Injury" pensions ???
          TotalPayment := TotalPayment + TxnRepSection(DB,'(Void) Money Orders Paid'                          ,'( PLU = 002000100 )',FP,TP,SL,Summary,False,'TxnTotal');
    {X}   TotalPayment := TotalPayment + TxnRepSection(DB,'(Void) Fax Money Orders Paid'                      ,'( PLU = -1 )',FP,TP,SL,Summary,False,'TxnTotal');
    {X}   TotalPayment := TotalPayment + TxnRepSection(DB,'(Void) Urgent Money Orders Paid'                   ,'( PLU = -1 )',FP,TP,SL,Summary,False,'TxnTotal');
    {X}   TotalPayment := TotalPayment + TxnRepSection(DB,'(Void) Postal Draft Paid'                          ,'( PLU = -1 )',FP,TP,SL,Summary,False,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'Bait-ul-mall Payment'                              ,'( PLU = 10001200 )' ,FP,TP,SL,Summary,False,'TxnLine');
          TotalPayment := TotalPayment + TxnRepSection(DB,'Zakat Refund / Payment'               {check PLU}  ,'( PLU = 006000001 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    {B/O} TotalPayment := TotalPayment + TxnRepSection(DB,'Bills Paid - ALL'                                  ,'( PLU = 010510003 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    //{X}      TotalPayment := TotalPayment + TxnRepSection(DB,'Bills Paid - GPO'                                  ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    //{X}      TotalPayment := TotalPayment + TxnRepSection(DB,'Bills Paid - PMG Office'                           ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    //{X}      TotalPayment := TotalPayment + TxnRepSection(DB,'Bills Paid - Directorate General'                  ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    //{X  B/O} TotalPayment := TotalPayment + TxnRepSection(DB,'Bills Paid - Express and International Post'       ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    //{X}      TotalPayment := TotalPayment + TxnRepSection(DB,'Bills Paid - Postal staff College'                 ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    //{X}      TotalPayment := TotalPayment + TxnRepSection(DB,'Bills Paid - Postal Training Centre'               ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    //{X}      TotalPayment := TotalPayment + TxnRepSection(DB,'Bills Paid - International Mail Office'            ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    {B/O} TotalPayment := TotalPayment + TxnRepSection(DB,'Workers Expenditure'                                 ,'( PLU = 010510004 )' ,FP,TP,SL,Summary,False,'TxnTotal');
          TotalPayment := TotalPayment + TxnRepSection(DB,'Unclassified Payments'                             ,'( PLU = 010500012 )' ,FP,TP,SL,Summary,False,'TxnTotal');
    //      TotalPayment := TotalPayment + TxnRepSection(DB,'Payment of Fixed income tax'                   ,'( PLU = -1 )' ,FP,TP,SL,Summary,False,'TxnTotal');

          DoFullUserSearch:=False;
          if not Print2x2 then SL.Add('"",""');
          SL.Add('"",""');
          SL.Add('"Total Payments","'+CurrToStrF(TotalPayment, ffNumber, 2)+'"');
          SL.Add('"",""');
          SL.Add('"STOCK",""');

          TotalStock := TxnRepSection(DB,'Cash on Hand'                                                       ,'Prod = ''Product.Cash''',FP,TP,SL,Summary,False,'TxnTotal'' or RecType = ''StartDay');
          TotalStock := TotalStock + StkRepSection(AStock,   'Postage Stamps and stationery'                   ,'9010010-9015000,9080100-9080185',SL,True);
          TotalStock := TotalStock + StkRepSection(AStock,   'Pakistan Revenue Stamps'                         ,'9020015-9020200',SL,True);
          TotalStock := TotalStock + StkRepSection(AStock,   'Arms License Stamps'                             ,'9060050-9066000',SL,True);
          TotalStock := TotalStock + StkRepSection(AStock,   'Driving License Stamps'                          ,'9050040-9052000',SL,True);
          TotalStock := TotalStock + StkRepSection(AStock,   'Route Permit Stamps'                             ,'9076010-9076600',SL,True);
          TotalStock := TotalStock + StkRepSection(AStock,   'Vehicle Fitness Stamps'                          ,'9040250-9043000',SL,True);
          TotalStock := TotalStock + StkRepSection(AStock,   'I.D. Card Stamps'                                ,'9030500-9034000',SL,True);
          TotalStock := TotalStock + StkRepSection(AStock,   'National ID Card forms'                          ,'9080190-9080190',SL,True);
          TotalStock := TotalStock + StkRepSection(AStock,   'Money Order forms'                               ,'9080200-9080200',SL,True);
          TotalStock := TotalStock + StkRepSection(AStock,   'International Reply Coupons'                     ,'9080099-9080099',SL,True);
          TotalStock := TotalStock + StkRepSection(AStock,   'Telecom Cards'                                   ,'9090000-9090500',SL,True);
          TotalStock := TotalStock + StkRepSection(AStock,   'Postal Orders'                                   ,'5000100-5010000',SL,True);
          TotalStock := TotalStock + StkRepSection(AStock,   'Motorway Code Book - Urdu'                       ,'9080230-9080230',SL,True);
          TotalStock := TotalStock + StkRepSection(AStock,   'Motorway Code Book - English'                    ,'9080220-9080220',SL,True);
          TotalStock := TotalStock + StkRepSection(AStock,   'Agricultural Loan Pass Book'                     ,'9080210-9080210',SL,True);
          TotalStock := TotalStock + StkRepSection(AStock,   'Federal Government Attestation Stamps'           ,'9070500-9075000',SL,True);
          TotalStock := TotalStock + StkRepSection(AStock,   'Post Code Books'                                 ,'9080201-9080201',SL,True);
          TotalStock := TotalStock + StkRepSection(AStock,   'SB7 Cheque Books'                                ,'9080202-9080202',SL,True);
          SL.Add('"",""');
          SL.Add('"Total Stock","'+CurrToStrF(TotalStock, ffNumber, 2)+'"');

    //      TV:=TxnRepSection(DB,'79  Less Uncharged Receipts'                  ,'( PLU = 999999999 )',FP,TP,SL,Summary,False,'TxnTotal');
    //      SL.Add('"80  Net Total - Stock On Hand","'+CurrToStrF(TotalStock-TV, ffNumber, 2)+'"'); // Subtract Uncharged Receipts
    //      SL.Add('"81  Total Of Lines 63","'+CurrToStrF(TotalPayment, ffNumber, 2)+'"');
    //      SL.Add('"82  Total To Agree with Line 40","'+CurrToStrF(TotalPayment+(TotalStock-TV), ffNumber, 2)+'"');
       end
       else if RType = 'PakistanDomMail' then
       begin
          SL.Add('"Domestic Mail Sales",""');
          SL.Add('"------------------------------","------------------------------"');
          TV:=TxnRepSection(DB,RType,'(PLU >= 010000000) and (PLU < 011999999)',FP,TP,SL,Summary,False,'TxnLine');
       end;
    finally
      If DB <> nil then //sometimes nilled by individual reports (ag ASUM - Bermuda)
        DB.Close;
      DB:=nil;
    end;

   if Print2x2 then
      Print2x2Report(SL)
   else
      PrintReport(SL);
    SL.Free;
   Result:=TV;
   ReportParams.Stock:=nil;
   AStock:=nil;
   FOfficeNo:='';
   FReportTitle:='';
end;
function  TBaseProduct.GetStockItemDetails(const Description:WideString):WideString;
var
   Stock:IStock;
begin
   Result:='';
   try
      Stock:=CreateStock;
      Result:=Stock.GetStockItemDetails(Description);
      Stock:=nil;
   except
      // Error in Stock
   end;
end;

function TBaseProduct.StockReportList(var Total:Currency;User:String):String;
var
   Res:TPackStringList;
   SL:TPackStringList;
   LSL:TPackStringList;
   I:Integer;
   Stock:IStock;
   StockList:String;
   Qty  :Integer;
   Price,LineTot:Currency;
   FullExp:Boolean;
begin
  try
    Stock:=CreateStock;
    StockList:=Stock.ListAllStock(User,'!CashAcc,!CashDenoms');
    Stock:=nil;
  except
    On E : Exception do
      RaiseGUIDException('{BEA28AD5-E033-483F-82A3-F4CCAEFBA39E}', E);
  end;
  if StockList = '' then Exit;
  if GetGPCSRegString('','System Name','Tanzania Post') = 'Bermuda Post' then
    FullExp:=True
  else
    FullExp:=False;
  Res:=TPackStringList.Create;
  Res.Add('"Stock on Hand",""');
  SL :=TPackStringList.Create;
  LSL:=TPackStringList.Create;
  SL.CommaText:=StockList;
  Total:=0;

   for I:=0 to SL.Count-1 do
   begin
//    Stock Data = [0]=Desc,[1]=Qty,[2]=Price,[3]=PLU,[4]=ProgID
      LSL.CommaText:=SL[I];

      If LSL[0] <> 'Cash'  then //do not show cash stock (doesn't include payments!)
      begin
       Qty  :=StrToIntDef(LSL[1],0);
       If (Qty <> 0) or
          (GetGPCSRegString('Reports','ReportZeroStock','Y') <> 'N') then
       begin
         Price:=StrToCurrDef(LSL[2],0);
         LineTot:=Price*Qty;
         LSL.CommaText:=SL[I];
         if FullExp then
            Res.Add('"'+LSL[1]+' x '+LSL[0]+' @ '+LSL[2]+' = ","'+CurrToStrF(LineTot,ffNumber,2)+'"')
         else
            Res.Add('"'+LSL[1]+' '+LSL[0]+'","'+CurrToStrF(LineTot,ffNumber,2)+'"');
         Total:=Total+LineTot;
       end;
     end; //if not cash stock
   end;
   Res.Add('"Total Value","'+CurrToStrF(Total,ffNumber,2)+'"');
   Result:=Res.CommaText;
   Res.Free;
   SL .Free;
   LSL.Free;
end;
procedure TBaseProduct.AddStockItem(TxnLog:ITransactionLog;Description,Group,AccountID,Agency,ReportLine,ProgID:String;PLU:Integer;Price:Currency);
var
   Stock:IStock;
   SLGroup:TStringList;
begin
   Stock:=CreateStock;
   if Stock <> nil then
   begin
      SLGroup:=TStringList.Create;
      SLGroup.Add(Group);
      SLGroup.Add(AccountID);
      SLGroup.Add(Agency);
      SLGroup.Add(ReportLine);
      Stock.AddNewStockItem(Description,Price,Group,PLU,AccountID,Agency,ReportLine,ProgID,'"Clerk","Supervisor","Central","Admin"');
      TxnLog.WriteTransaction('*NewStock',0,0,PLU,Price,Price,Description,SLGroup.CommaText,ProgID,'"Clerk","Supervisor","Central","Admin"');
      SLGroup.Free;
      Stock:=nil;
   end;
end;
procedure TBaseProduct.DeleteStockItems(TxnLog:ITransactionLog;List:TStrings);
var
   Stock:IStock;
   I:Integer;
   Value:String;
begin           
   Stock:=CreateStock;
   try
      for I:=0 to List.Count-1 do
      begin
         Value:=List[I];
         if Copy(Value,Length(Value)-9,10) =' <- DELETE' then
         begin
            Value:=Copy(Value,1,Length(Value)-10);
            Stock.DeleteStockItem(Value);
            TxnLog.WriteTransaction('*DelStock',0,0,0,0,0,Value,'','','');
         end;
      end;
   except
      // Error in Stock
   end;
   Stock:=nil;
end;
procedure TBaseProduct.DeleteCountriesExchange(TxnLog:ITransactionLog;List:TStrings);
var
   I:Integer;
   Value:String;
begin
   try
      for I:=0 to List.Count-1 do
      begin
         Value:=List[I];
         if Copy(Value,Length(Value)-9,10) =' <- DELETE' then
         begin
            Value:=Copy(Value,1,Length(Value)-10);
            DeleteCountryExchange(Value );
            TxnLog.WriteTransaction('*DelExchg',0,0,0,0,0,Value,'','','');
         end;
      end;
   except
      // Error in Stock
   end;

end;
//procedure TBaseProduct.DeleteCountryExchange(TxnLog:ITransactionLog;Value:String);
//begin
//   EraseValue( HKEY_LOCAL_MACHINE, 'Software\PSL\GPCS\ExchangeRates',Value );
//   TxnLog.WriteTransaction('*DelExchg',0,0,0,0,0,Value,'','','');
//end ;
procedure TBaseProduct.UserStockReport(User:String);
var
   SL:TPackStringList;
   Total:Currency;
begin
   SL:=TPackStringList.Create;
   Total:=0;
   SL.CommaText:=StockReportList(Total,User);
   if User <> FUIEventSink.User then
   begin
      SL.Insert(0,'"Current Stock Levels",""');
      SL.Insert(0,'"For: '+User+'",""');
   end;
   PrintReport(SL);
   SL.Free;
end;
procedure TBaseProduct.StockReport;
begin
   UserStockReport(FUIEventSink.User);
end;
procedure TBaseProduct.StockReport2x2;
var
   SL:TPackStringList;
   Total:Currency;
begin
   SL:=TPackStringList.Create;
   Total:=0;
   SL.CommaText:=StockReportList(Total,FUIEventSink.User);
   Print2x2Report(SL);
   SL.Free;
end;
function LookUp(Column,Value,LookUpName:String;Field:TComponent;var Valid:Boolean):String;
var
   CompMan:ICompMan;
   Lookup:ILookUp;
begin
   Result:='Invalid';
   CompMan:=CreateCompMan;
   if CompMan <> nil then
   begin
      Lookup:=CompMan.LoadComponent('LookUp.'+LookUpName) as ILookUp;
      if Lookup <> nil then
      begin
         Lookup.CurrentColumn:=Column;
         Result:=Lookup.Value[Trunc(StrToCurrDef(Value,High(StrToInt(Value))))];
         if StrToCurrDef(Result,-1) < 0 then
            Result:='Invalid';
      end
      else
      begin
         GPCSErrorLine.RaiseError(1,1,1,'Error Loading LookUp.'+LookUpName);
         Result:='Tariff Error';
      end;
   end;
   if StrToCurrDef(Result,-1) < 0 then
   begin
      if Valid then
      begin
         MoveFocusTo(Field);
         Valid:=False;
      end;
   end;
end;
function SufficientStockLeft(StockList:TStrings;CurrentLine:Integer):Boolean;
var
   StockLine:TPackStringList;
   Qty:Integer;
   MaxQty:Integer;
begin
   Result:=True;
   StockLine:=TPackStringList.Create;
   StockLine.PackText:=StockList[CurrentLine];
   if StockLine.Count < 7 then
   begin
      Result:=FALSE;
      Exit;
     // Result:=True;
   end;
   Qty:=StrToIntDef(StockLine[1],0);
   MaxQty:=StrToIntDef(StockLine[6],0);
   if (Qty > MaxQty) then
   begin
      if MaxQty > 0 then
         StockLine[1]:=StockLine[6]
      else
         StockLine[1]:='0';
      StockList[CurrentLine]:=StockLine.PackText;
      Result:=False;
   end;
   StockLine.Free;
end;


function TBaseProduct.TotalWithoutAdvDel(ProdForm:TForm):String;
var
   DelAdvice:Currency;
   TotalFromField:Currency;
   DomainEdit : TComponent;
begin
   DelAdvice :=CombineList.TotalOf('Product.Retail120');
//                 + CombineList.TotalOf('Product.PrePaidStamps'); //already subtracted from total

   //CED cannot be paid by stamps
   DomainEdit := ProdForm.FindComponent('CentralExciseDutyFee');
   If DomainEdit <> nil then
   begin
     DelAdvice := DelAdvice + StrToCurrDef(TDomainEdit(DomainEdit).Text,0);
   end;
   //Driving Licence Penalty cannot be paid by stamps
   DomainEdit := ProdForm.FindComponent('LicPenaltyAmount');
   If DomainEdit <> nil then
   begin
     DelAdvice := DelAdvice + StrToCurrDef(TDomainEdit(DomainEdit).Text,0);
   end;

//               CombineList.TotalOf('Product.AdvOfDelBlind') +
//               CombineList.TotalOf('Product.PAdvOfDel') +
//               CombineList.TotalOf('Product.IAdvOfDel') +
//               CombineList.TotalOf('Product.IAdvOfDelBlind');
   TotalFromField:=StrToCurrDef(FindTotalField(ProdForm).Text,0);
  Result:=CurrToStrF(TotalFromField-DelAdvice,ffNumber,2);

//   Result:=CurrToStrF( StrToCurrDef(FindTotalField(ProdForm).Text,0),ffNumber,2);
end;
function TBaseProduct.EndorseData(Price:Currency;DataLine1,DataLine2,FormData:String):String;
var
   S:String;
   SL:TPackStringList;
   LSL:TPackStringList;
   FieldsSL:TPackStringList;
   FieldsLineSL:TPackStringList;
   PriceString:String;
   Registered,DelAdvice:Boolean;
   Ident:String;
   I,J:Integer;
   EndorseType:String;
   Time24 : String;
   FieldName:string;
   Pos1, Pos2, NewLine:Integer;
begin
   EndorseType:=GPCSGUID.GetGPCSRegString('DeviceSetup\Receipt','Endorse Type','Bermuda');
  if EndorseType = 'Test' then
  begin
    With TStringObject.Create('"012345678911234567892123456789312345678941234567895123456789612345",' +
                              '"1         1         1         1         1         1         1     ",' +
                              '"2         2         2         2         2         2         2     ",' +
                              '"3         3         3         3         3         3         3     ",' +
                              '"4         4         4         4         4         4         4     ",' +
                              '"5         5         5         5         5         5         5     ",' +
                              '"6         6         6         6         6         6         6     ",' +
                              '"7         7         7         7         7         7         7     ",' +
                              '"8         8         8         8         8         8         8     ",' +
                              '"9         9         9         9         9         9         9     ",' +
                              '"10        10        10        10        10        10        10    ",'+
                              '"11        11        11        11        11        11        11    ",'+
                              '"12        12        12        12        12        12        12    ",'+
                              '"13        13        13        13        13        13        13    ",'+
                              '"14        14        14        14        14        14        14    ",'+
                              '"15        15        15        15        15        15        15    ",'+
                              '"16        16        16        16        16        16        16    ",'+
                              '"17        17        17        17        17        17        17    ",'+
                              '"18        18        18        18        18        18        18    ",'+
                              '"19        19        19        19        19        19        19    ",'+
                              '"20        20        20        20        20        20        20    "') do
    begin
      try
        Result := Strings.CommaText;
      finally
        Free;
      end;
    end;
   end
   else
   if EndorseType = 'Bermuda' then
   begin
      SL:=TPackStringList.Create;
      LSL:=TPackStringList.Create;
      SL.PackText:=FormData;
      Ident:='';
      for I:=0 to SL.Count-1 do
      begin
         LSL.PackText:=SL[I];
         if LSL.Count > 5 then
         begin
            if (LSL[3] = 'IntEMSID')
            or (LSL[3] = 'IntRegID')
            or (LSL[3] = 'DomRegID')
            or (LSL[3] = 'IntParID')
            or (LSL[3] = 'DomParID') then
               Ident:=LSL[5];
         end;
         if Ident <> '' then Break;
      end;
      LSL.Free;

      Registered:=CombineList.IsSelected('Product.Registered' ) or
                  CombineList.IsSelected('Product.IntReg'     ) or
                  CombineList.IsSelected('Product.DomRegBlind') or
                  CombineList.IsSelected('Product.IntRegBlind');

      DelAdvice :=CombineList.IsSelected('Product.AdvOfDel'      ) or
                  CombineList.IsSelected('Product.AdvOfDelBlind' ) or
                  CombineList.IsSelected('Product.PAdvOfDel'     ) or
                  CombineList.IsSelected('Product.IAdvOfDel'     ) or
                  CombineList.IsSelected('Product.IAdvOfDelBlind');

      PriceString:=CurrToStrF(Price,ffNumber,2);
      while Length(PriceString) < 11 do PriceString:='#'+PriceString;
      SL.Clear;
      SL.Add('');
      if Registered then SL.Add('                                     X') else SL.Add('');
      SL.Add('                                                      '+PriceString);
      if DelAdvice  then SL.Add('                                     X') else SL.Add('');
      SL.Add('');
      SL.Add('                                      '+Copy(DataLine1,1,27));
      SL.Add('                                      '+Copy(DataLine2,1,27));
      SL.Add('                                      '+Copy(Ident    ,1,27));
      Result:=SL.CommaText;
      SL.Free;
   end
   else
   begin
   if EndorseType = 'Guernsey' then
   begin
     SL:=TPackStringList.Create;
     LSL:=TPackStringList.Create;
     SL.PackText:=FormData;
     Ident:='';

     FieldsSL := TPackStringList.Create  ;
     FieldsLineSL := TPackStringList.Create  ;
     Pos1 := Pos( '#', DataLine1 ); // No new line
     Pos2 := Pos( '^', DataLine1 );  // with new line
     NewLine := 0 ;
     while (Pos1 > 0) or (Pos2 > 0) do
     begin
         //ether one o the other  it is a new field
         NewLine :=  0; // No new line
         if ((Pos1 > Pos2) and (Pos2 <> 0)) or ((Pos1 = 0) and (Pos2 <> 0)) then
         begin
           NewLine := 1; // Yes, new line
           Pos1:= Pos2;
         end ;

         FieldName := Copy( DataLine1, 1, Pos1-1 ) ;
         FieldsSL.AddObject( FieldName, TObject(NewLine)) ;
         DataLine1 := Copy( DataLine1, Pos1+1, Length( DataLine1 ) );

         Pos1 := Pos( '#', DataLine1 ); // No new line
         Pos2 := Pos( '^', DataLine1 );  // with new line

     end ;
     FieldsSL.AddObject( DataLine1, TObject(NewLine) ) ;

     for I := 0 to FieldsSL.Count-1 do
     begin
       for J:=0 to SL.Count-1 do
       begin
          LSL.PackText:=SL[J];
          if LSL.Count > 5 then
             if (LSL[3] =  FieldsSL[I] ) then
                FieldsSL[I]:=LSL[5];
        end;
      end ;

     for I:=0 to SL.Count-1 do
     begin
        LSL.PackText:=SL[I];
        if LSL.Count > 5 then
        begin
           if (LSL[3] = 'RegistrationNumber') then
              Ident:=LSL[5];
        end;
        if Ident <> '' then Break;
     end;

     SL.Clear;
     //Registered:=CombineList.IsSelected('Product.DomRecDel' ) or
     //             CombineList.IsSelected('Product.PrepaidVAT' )or
     //             CombineList.IsSelected('Product.SpecialDelivery' );
     Time24 := FormatDateTime('dd mmm yy hh:nn', StrToDateTime(DataLine2));
     SL.Add(' ');
     SL.Add(' ');
     SL.Add(' ');
     SL.Add(' ');
     SL.Add(' ');
     SL.Add(' ');

     SL.Add(' ');
     SL.Add(' ');

     // Multiple lines in Endorse with Fields Values
     S :=  '                             ';
     for I := 0 to  FieldsSL.Count-1 do
     begin
       //S := S +Copy(FieldsSL[i],1,27)+ ' ';
       S := S +FieldsSL[i]+ ' ';
       if Integer( FieldsSL.Objects[I] )=1 then
       begin
         SL.Add( S );
         S := '                             ';
       end
       //SL.Add('                             '+Copy(LSL[i],1,27));
     end;
     if Trim(S) <> '' then  SL.Add( S );

     SL.Add('                             '+Copy(Time24,1,27));
     SL.Add('                             '+Copy(Ident    ,1,27));
     S:='                             '+#156+'     ';

     PriceString:= CurrToStrF(Price,ffNumber,2);
     for I:=1 to Length(PriceString) do
       S[35-Length(PriceString)+I]:=PriceString[I];
     SL.Add(S);


     //if Registered then
     //begin
        //SL.Add('                             '+Copy(DataLine1,1,27));
        //SL.Add('                             '+Copy(Time24,1,27));
        //SL.Add('                             '+Copy(Ident    ,1,27));
        //S:='                             £     ';
        //PriceString:= CurrToStrF(Price,ffNumber,2);
        //for I:=1 to Length(PriceString) do
        //  S[35-Length(PriceString)+I]:=PriceString[I];
        //SL.Add(S);
     //end
     //else
     //begin
        //SL.Add('                             '+Copy(DataLine1,1,27));
        //SL.Add('                             '+Copy(Time24,1,27));
        //SL.Add('                             '+Copy(Ident    ,1,27));
        //S:='                             £     ';
        //PriceString:= CurrToStrF(Price,ffNumber,2);
        //for I:=1 to Length(PriceString) do
        //  S[35-Length(PriceString)+I]:=PriceString[I];
        //SL.Add(S);
     //end;
     Result:=SL.CommaText;
     SL.Free;
     LSL.Free;
     FieldsSL.Free;
     FieldsLineSL.Free ;
   end
   else
   begin
     SL:=TPackStringList.Create;
     LSL:=TPackStringList.Create;
     SL.PackText:=FormData;
     Ident:='';
     for I:=0 to SL.Count-1 do
     begin
        LSL.PackText:=SL[I];
        if LSL.Count > 5 then
        begin
           if (LSL[3] = 'RegistrationNumber') then
              Ident:=LSL[5];
        end;
        if Ident <> '' then Break;
     end;
     LSL.Free;
        SL.Clear;
     Registered:=CombineList.IsSelected('Product.RegDom' ) or
                  CombineList.IsSelected('Product.RegInt' );

     SL.Add(' ');
     SL.Add(' ');
     SL.Add(' ');
     S:='                                             000000000/-';
     PriceString:=CurrToStrF(Price,ffNumber,2);
     for I:=1 to Length(PriceString) do
        S[54-Length(PriceString)+I]:=PriceString[I];
     SL.Add(S);
     SL.Add(' ');
     SL.Add(' ');
     SL.Add(' ');
     if Registered then
     begin
        SL.Add('                             '+Copy(DataLine1,1,27));
        SL.Add('                             '+Copy(DataLine2,1,27));
        SL.Add('                             '+Copy(Ident    ,1,27));
     end
     else
     begin
        SL.Add('                        XXXX '+Copy(DataLine1,1,27));
        SL.Add('                        XXXX '+Copy(DataLine2,1,27));
        SL.Add('                        XXXX '+Copy(Ident    ,1,27));
     end;
     Result:=SL.CommaText;
     SL.Free;
   end
  end;
end;
function TBaseProduct.LookUpExRate(Name:String):Currency;
begin
   Result:=StrToCurrDef(GetGPCSRegString('ExchangeRates',Name,'0'),0);
end;

function TBaseProduct.ChequeIDRange(IDFrom, IDTo :String;Count:Integer):Boolean;
var
   ValueFrom, ValueTo : Integer ;
begin

   result := False ;
   if (IDTo <> '') and (IDFrom <> '' ) and (Count > 0 )then
   begin
      ValueFrom := 0 ;
      ValueTo   := 0;
      if IsNumber( IDTo ) and IsNumber( IDFrom ) then
      begin
         ValueFrom := StrToIntDef( IDFrom, 0);
         ValueTo   := StrToIntDef( IDTo, 0);
      end
      else
         if not IsNumber( IDTo ) and not IsNumber( IDFrom ) then
         begin
            ValueFrom:=StrToIntDef(Copy(IDFrom,3,8), 0);
            ValueTo  :=StrToIntDef(Copy(IDTo,3,8), 0)  ;
         end ;

      Result := ValueFrom + Count -1 <= ValueTo

   end ;


end ;

function TBaseProduct.CheckRegSum( ID : String ) : boolean ;
begin

   result := FALSE ;
   if IsNumber( ID ) then
      result := TRUE
   else
      if (Length(ID) = 13) then
      begin
         if UpperCase(Copy(ID,11,1)) = 'X' then
         begin
            Result:=TRUE ;
         end
         else
         begin
            result := (Copy(ID,11,1) = Mod11( StrToIntDef(Copy(ID,3,8),0) )) ;
         end;
      end;

end ;

function TBaseProduct.CalcIDRange(ID:String;Count:Integer):String;
var
   StartStr:String;
   EndStr:String;
   ValueStr:String;
   Value:Integer;
   WithCRC:Boolean;
begin
   if Count < 0 then Exit;
   if Count = 0 then 
      Result:=''
   else
      Result:=ID;
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


end.


