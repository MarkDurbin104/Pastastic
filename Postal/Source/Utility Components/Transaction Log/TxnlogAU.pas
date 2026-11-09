{  Module          Corvus Transaction Log
   Unit            OLE Automation
   Copyright(c)    Postal Solutions Limited 1996..1998

$Log: /CorvusV3/Source/Utility Components/Transaction Log/TxnlogAU.pas $
 *
 * 34    22/09/01 21:39 Administrator
 * Changes in Tanzania
 *
 * 24    2/08/01 21:13 Administrator
 * Tan Visit Finish 02/08/01
 *
 * 23    29/07/01 14:13 Administrator
 * Changed Keywords
 *
 * 22    29/07/01 14:05 Administrator
 * Keywords

________________________________________________________________________________}

unit TxnlogAU;

interface

uses
  StringUtil,CustomerListU,MODefinitionsU,MOSupportU,DBUtil,
  Dialogs,Windows,Classes,ExtCtrls,ComObj,SysUtils,GPCSBase_TLB,TxnlogFU,TxnlogU,
  GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,PackStrListU,UIDllSupportU,I3UIParseU;

type
  TTxnDomInfoLine = class(TObject)
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
  TTxnDomInfoLines = class(TList)
    private
      function GetItem(Index:Integer):TTxnDomInfoLine;
      procedure SetItem(Index:Integer;Value:TTxnDomInfoLine);
    public
      destructor Destroy; override;
      function AddFromPackText(TxnDomInfoLine:String):Integer;
      property Item[Index:Integer]:TTxnDomInfoLine read GetItem write SetItem; default;
  end;
  TDripLine = class(TObject)
  private
     FQuantity    : Integer;
     FPrice       : Currency;
     FValue       : Currency;
     FAddIndex    : Integer;
     FPLU         : Integer;
     FDescription : String;
     FAdditional  : String;
     FProgID      : String;
     FDomInfo     : String;
     FTxnType     : String;
  public
    constructor Create(Index,Quantity,PLU:Integer;Value,Price:Currency;
                       Description,Additional,ProgID,DomInfo,TxnType:String);
  published
    property Quantity     : Integer  read FQuantity    write FQuantity   ;
    property Price        : Currency read FPrice       write FPrice      ;
    property Value        : Currency read FValue       write FValue      ;
    property AddIndex     : Integer  read FAddIndex    write FAddIndex   ;
    property PLU          : Integer  read FPLU         write FPLU        ;
    property Description  : String   read FDescription write FDescription;
    property Additional   : String   read FAdditional  write FAdditional ;
    property ProgID       : String   read FProgID      write FProgID     ;
    property DomInfo      : String   read FDomInfo     write FDomInfo    ;
    property TxnType      : String   read FTxnType     write FTxnType    ;
  end;
  TDripList = class(TObject)
  private
     FLineList:TList;
  public
     constructor Create;
     destructor Destroy; override;
     procedure Clear;
  published
    property LineList:TList read FLineList write FLineList;
  end;
  TTransactionLog = class(TGPCSComponent, ITransactionLog)
  private
//    FUniqueID:String;
    DripLines:TDripList;
    FServerName:String;
    FTxnEventSink:ITxnEventSink;
    FUser:String;
    FWorkStation:Integer;
    FOffice:Integer;
    LogAllAsZeroPrice:Boolean;
    I3UINode:TI3UINode;
//    procedure RefServerUpdate(TxnLine:TDripLine); //update ref data
    procedure SaveTransactions(UniqueID:String);
    procedure UpdateTxnLog(UID:String;DList:TDripList);
    procedure AddLineToTxnTable(Period,Index,Quantity,PLU,Office:Integer;
                                Value,Price:Currency;
                                TxnType,Desc,Info,ProgID,DomInfo,User,UID:String);
  public
    destructor Destroy; override;
    procedure Initialize; override;
  protected
    function Get_Total: Currency;                        safecall;
    function Get_User: WideString;                       safecall;
    function Get_Workstation: Integer;                   safecall;
    function Get_Office: Integer;                        safecall;
    procedure CancelCustomer;                            safecall;
    procedure EndCustomer(const UniqueID:WideString);    safecall;
    procedure LogTransaction(Index,Quantity,PLU:Integer;Value,Price:Currency;
               const Description,Additional,ProgID,DomInfo:WideString); safecall;
    procedure WriteTransaction(const TxnType:WideString;Index, Quantity, PLU: Integer;
               Value, Price: Currency; const Description, Additional, ProgID,
               DomInfo: WideString); safecall;
    procedure WriteFullTransaction(WsNumber, Period, Index, Office: Integer;
                                   const Txntype, Teller: WideString;
                                   Quantity, PLU: Integer;
                                   Value, Price: Currency;
                                   const Description, Info, ProgID, Ident, DomInfo: WideString);safecall;
    procedure Set_User(const Value: WideString);         safecall;
    procedure Set_Workstation(Value: Integer);           safecall;
    procedure Set_Office(Value: Integer);                safecall;
    procedure Set_Parent(Value: Integer);                safecall;
    procedure Set_SubLogVisible(Value: WordBool);        safecall;
    procedure SubLogClear;                               safecall;
    procedure SubLogTransaction(Index,Quantity,PLU:Integer;Value,Price:Currency;
               const Description,Additional,ProgID,DomInfo:WideString); safecall;
    function Get_Additional(Index: Integer): WideString; safecall;
    function Get_Description(Index: Integer):WideString; safecall;
    function Get_ItemCount: Integer;                     safecall;
    function Get_ItemIndex(Index: Integer): Integer;     safecall;
    function Get_Price(Index: Integer): Currency;        safecall;
    function Get_Quantity(Index: Integer): Integer;      safecall;
    function Get_Value(Index: Integer): Currency;        safecall;
    procedure PrintReceipt;                              safecall;
    procedure SetEventSink(const EventSink: ITxnEventSink); safecall;
    function Get_Contents: WideString; safecall;
    function Get_SubLogVisible: WordBool;        safecall;
    function Get_PLU(Index: Integer): Integer;   safecall;
    function Get_ProgID(Index: Integer): WideString; safecall;
    function Get_DomInfo(Index: Integer): WideString; safecall;
    procedure Delete(Index: Integer); safecall;
    function GetExecData(Index: Integer; var ProgID: WideString): WideString; safecall;
    function RetrieveAccountsFor(const ProgIDList:WideString):WideString; safecall;
    procedure LogToAccounts(Quantity,PLU:Integer;Value:Currency;const ProgID:WideString); safecall;
    function RetrieveTxnsFor(const SQLStr:WideString):WideString; safecall;
    function Get_Hook:IHookUp; safecall;
    procedure Set_Hook(const Value:IHookUp); safecall;
  end;

var
  HookUp              : IHookUp;
  Stock               : IStock;
{  RefServer           : IReferenceData;
  RefAccountAuto      : IRefAccountAuto;
  RefLicenceAuto      : IRefLicenceAuto;
  RefCertificateAuto  : IRefCertificateAuto;
  RefPensionAuto      : IRefPensionAuto;    }

implementation

uses ComServ; // for Class Factory

{TTxnDomInfoLines}
function TTxnDomInfoLines.GetItem(Index:Integer):TTxnDomInfoLine;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=TTxnDomInfoLine(Get(Index))
   else
      Result:=nil;
end;
procedure TTxnDomInfoLines.SetItem(Index:Integer;Value:TTxnDomInfoLine);
begin
   if (Index >= 0) and (Index < Count) then
      Put(Index,Value);
end;       
destructor TTxnDomInfoLines.Destroy;
var
   I:Integer;
begin
   for I:=0 to Count-1 do
      TTxnDomInfoLine(Get(I)).Free;
   inherited Destroy;
end;
function TTxnDomInfoLines.AddFromPackText(TxnDomInfoLine:String):Integer;
var
  OldTxnDomInfoLine:TTxnDomInfoLine;
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
     OldTxnDomInfoLine:=TTxnDomInfoLine.Create;
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
{TDripLine}
constructor TDripLine.Create(Index,Quantity,PLU:Integer;Value,Price:Currency;
                             Description,Additional,ProgID,DomInfo,TxnType:String);
begin
    FQuantity   :=Quantity   ;
    FPrice      :=Price      ;
    FValue      :=Value      ;
    FAddIndex   :=Index      ;
    FPLU        :=PLU        ;
    FDescription:=Description;
    FAdditional :=Additional ;
    FProgID     :=ProgID     ;
    FDomInfo    :=DomInfo    ;
    FTxnType    :=TxnType    ;
end;
{TDripList}
constructor TDripList.Create;
begin
   FLineList:=TList.Create;;
end;
destructor TDripList.Destroy;
var
   I:Integer;
begin
   for I:=0 to FLineList.Count-1 do TDripLine(FLineList[I]).Free;
   FLineList.Free;
   inherited Destroy;
end;
procedure TDripList.Clear;
var
   I:Integer;
begin
   for I:=0 to FLineList.Count-1 do TDripLine(FLineList[I]).Free;
   FLineList.Clear;
end;
{===============================================================================
  Class        TTransactionLog
  Method       Destroy
  Description  free the Component Manager reference and Destroy
  Params       None.
  Result       None.
________________________________________________________________________________}
//procedure TTransactionLog.RefServerUpdate(TxnLine:TDripLine); //update ref data
//var
//  VarCertNum : WideString;
//  DomInfoSL : TStringList;
//begin
//  //savings account
//  if LeftOf(TxnLine.Description, 'Account') then
//  begin
//    RefAccountAuto := CoRefAccountAuto.Create;
//    try
//      RefAccountAuto.AccountNum := TxnLine.ProgID + '^' + TxnLine.Additional;
//      if (TxnLine.Description = 'AccountClose') and (not RefAccountAuto.Close) then
//        RaiseGUIDError('{2B467ACD-8416-4169-8608-7002C39CF569}', 'Unable to close account ' + TxnLine.ProgID + '^' + TxnLine.Additional)
//      else if (TxnLine.Description = 'AccountDep' ) and (not RefAccountAuto.Deposit(TxnLine.FValue)) then
//        RaiseGUIDError('{65BC2CD7-B69D-4B0A-90E7-519CD7684F88}', 'Unable to deposit account ' + TxnLine.ProgID + '^' + TxnLine.Additional)
//      else if (TxnLine.Description = 'AccountWith') and (not RefAccountAuto.Withdrawal(-TxnLine.FValue)) then
//        RaiseGUIDError('{A115ACF1-3282-49EA-A490-F386519D1596}', 'Unable to withdraw account ' + TxnLine.ProgID + '^' + TxnLine.Additional)
//      else if (TxnLine.Description = 'AccountInterest') and (not RefAccountAuto.InterestPayment(TxnLine.FValue))  then
//        RaiseGUIDError('{A7B1F826-1467-4F4E-BD07-F102E7C824E7}', 'Unable to interest account ' + TxnLine.ProgID + '^' + TxnLine.Additional)
//      else if (TxnLine.Description = 'AccountZakat') and (not RefAccountAuto.Zakat(-TxnLine.FValue)) then
//        RaiseGUIDError('{2D69BBF7-34E5-4839-821B-38319BF41F6F}', 'Unable to zakat account ' + TxnLine.ProgID + '^' + TxnLine.Additional)
//      else if (TxnLine.Description = 'AccountTxn') then
//      //              RefServer.AccountTxn(TxnLine.ProgID + '^' + TxnLine.Additional, TxnLine.Quantity * TxnLine.Value)//SavingsAccountDep^934
//    finally
//      RefAccountAuto := nil;
//    end;
//  end
//  else if TxnLine.Description = 'DriveLicRenew' then
//  begin
//    RefLicenceAuto := CoRefLicenceAuto.Create;
//    try
//      RefLicenceAuto.SerialNum := TxnLine.ProgID + '^' + DelimitedString(TxnLine.Additional,'^', False);
//      RefLicenceAuto.UpToDate := StrToDateTime(DelimitedString(TxnLine.Additional,'^',True));
//      If not RefLicenceAuto.Renew(RefLicenceAuto.UpToDate, TxnLine.FValue) then
//        RaiseGUIDError('{E698C637-51E1-4AFD-82E6-89398FF305E7}', 'Unable to renew licence '
//        + TxnLine.ProgID + '^' + TxnLine.Additional);
//    finally
//      RefLicenceAuto := nil;
//    end;
//  end
//  else if TxnLine.Description = 'ArmsLicRenew' then
//  begin
//    RefLicenceAuto := CoRefLicenceAuto.Create;
//    try
//      RefLicenceAuto.SerialNum := TxnLine.ProgID + '^' + DelimitedString(TxnLine.Additional,'^', False);
//      RefLicenceAuto.UpToDate := StrToDateTime(DelimitedString(TxnLine.Additional,'^',True));
//      If not RefLicenceAuto.Renew(RefLicenceAuto.UpToDate, TxnLine.FValue) then
//        RaiseGUIDError('{1910D8B4-B941-4609-9EDC-491AE84EBB49}', 'Unable to renew licence '
//        + TxnLine.ProgID + '^' + TxnLine.Additional);
//    finally
//      RefLicenceAuto := nil;
//    end;
//  end
//  else if TxnLine.Description = 'MotorTax' then
//  begin
//    RefLicenceAuto := CoRefLicenceAuto.Create;
//    try
//      RefLicenceAuto.SerialNum := TxnLine.ProgID + '^' + DelimitedString(TxnLine.Additional,'^', False);
//      RefLicenceAuto.UpToDate := StrToDateTime(DelimitedString(TxnLine.Additional,'^',True));
//
//      With TStringList.Create do
//      try
//        CommaText := TxnLine.FDomInfo;
//        If not RefLicenceAuto.MotorTax(RefLicenceAuto.UpToDate,
//                                        StrToCurrDef(Values['Tax'],0),
//                                        StrToCurrDef(Values['Arrears'],0),
//                                        StrToCurrDef(Values['LicPenaltyAmount'],0),
//                                        StrToCurrDef(Values['MVTWithholding'],0)) then
//          RaiseGUIDError('{20924B9F-E775-424C-87A8-C737BD456112}', 'Unable to motor tax '
//          + TxnLine.ProgID + '^' + RefLicenceAuto.SerialNum);
//      finally
//        Free;
//      end;
//    finally
//      RefLicenceAuto := nil;
//    end;
//  end
//  else if LeftOf(TxnLine.Description,'Cert') then
//  begin
//    RefCertificateAuto := CoRefCertificateAuto.Create;
//    DomInfoSL := TStringList.Create;
//    try
//      With DomInfoSL do
//      begin
//        If (TxnLine.Description = 'CertApp') then
//        begin
//          CommaText := TxnLine.DomInfo;
//          VarCertNum := TxnLine.ProgID;
//          RefCertificateAuto.GetCertificateType(VarCertNum);  //determines type from product
//          RefCertificateAuto.CertificateAppNo   := TxnLine.Additional;
//          RefCertificateAuto.AccountType        := Values['CertificateAccountType'];
//          RefCertificateAuto.Declaration        := Values['Declaration'];
//          RefCertificateAuto.NameFamily         := Values['NameFamily'];
//          RefCertificateAuto.NamesGiven         := Values['NamesGiven'];
//          RefCertificateAuto.NameFatherHusband  := Values['NameFatherHusband'];
//          RefCertificateAuto.NICNumber          := Values['NICNumber'];
//          RefCertificateAuto.FullParticulars    := Values['FullParticulars'];
//          RefCertificateAuto.ZakatDeduction     := Values['CertZakatDeduction'];
//          If Values['SavCertPay'] = 'Cheque' then
//          begin
//            RefCertificateAuto.ChequeBank         := Values['ChequeBank'];
//            RefCertificateAuto.ChequeNo           := Values['ChequeNo'];
//          end;
//          RefCertificateAuto.Amount             := TxnLine.Value;
//          If not RefCertificateAuto.Application then
//            RaiseGUIDError('{9D094D5D-5695-4898-AC8B-E5C61EFD6057}',
//                            'Unable to Cert Application '
//                            + TxnLine.ProgID + ' ' + TxnLine.Additional);
//        end  //if CertApp
//        else if (TxnLine.Description = 'CertPurchase') then
//        begin
//          CommaText := TxnLine.DomInfo;
//          VarCertNum := TxnLine.ProgID + '^'; //determine certificate type
//          RefCertificateAuto.GetCertificateType(VarCertNum);  //determines type from product
//          RefCertificateAuto.CertificateAppNo := Values['CertificateAppNo'];
//          RefCertificateAuto.Amount           := StrToCurrDef(Values['CertificateAmount'],0);
//          If not RefCertificateAuto.Purchase(Values['CertificateSNo']) then
//            RaiseGUIDError('{2A5C128B-861A-4966-8579-37430A34BC07}',
//                            'Unable to Cert Purchase '
//                            + TxnLine.ProgID + ' ' + TxnLine.Additional);
//        end //if CertPurchase
//        else
//        begin
//          CommaText := TxnLine.DomInfo;
//          RefCertificateAuto.SerialNum := TxnLine.ProgID + '^' + TxnLine.Additional;
//          if (TxnLine.Description = 'CertEncash') and (not RefCertificateAuto.Encash) then
//            RaiseGUIDError('{5BCC8C33-A0F8-4091-A39C-AFE54DACFBC3}', 'Unable to encash certificate ' + TxnLine.ProgID + '^' + TxnLine.Additional);
//          if (TxnLine.Description = 'CertProfit') and (not RefCertificateAuto.Profit(TxnLine.Value,
//                                                                                     StrToCurrDef(Values['ZakatPayment'],0))) then
//            RaiseGUIDError('{09325551-7D20-4B63-B745-51E318E06E91}', 'Unable to profit certificate ' + TxnLine.ProgID + '^' + TxnLine.Additional);
//        end;  //if CertEncash/Profit
//      end;  //with DomInfoSL
//    finally
//      DomInfoSL.Free;
//      RefCertificateAuto := nil;
//    end;
//  end
//  else If LeftOf(TxnLine.Description, 'Pension') then
//  begin
//    RefPensionAuto := CoRefPensionAuto.Create;
//    DomInfoSL := TStringList.Create;
//    try
//      If TxnLine.Description = 'PensionWithdrawal' then
//      begin
//        DomInfoSL.CommaText := TxnLine.DomInfo;
//        RefPensionAuto.AccountNo := TxnLine.ProgID + '^' + TxnLine.Additional;
//        If not (RefPensionAuto.Withdrawal(TxnLine.Value)) then
//          RaiseGUIDError('{FE04DD14-7A86-47C6-9728-D26468382145}',
//                          'Unable to Pension Withdrawal '
//                          + TxnLine.ProgID + ' ' + TxnLine.Additional);
//        //make deposit (already included in PensionTotalAvailable - Balance)
//        If not (RefPensionAuto.Deposit(StrToCurrDef(DomInfoSL.Values['PensionTotalAvailable'],0)
//                                      -StrToCurrDef(DomInfoSL.Values['Balance'],0))) then
//          RaiseGUIDError('{7D95FF76-8B14-48C2-A8A8-DB50F916F7C9}',
//                          'Unable to Pension Deposit '
//                          + TxnLine.ProgID + ' ' + TxnLine.Additional);
//      end;
//    finally
//      DomInfoSl.Free;
//      RefPensionAuto := nil;
//    end;
//  end;
//end;
//
procedure TTransactionLog.Initialize;
begin
   FServerName:=GetGPCSRegString('','Transaction ServerName',GetLocalMachineName);
   I3UINode:=CreateI3UINode('Normal');
end;
destructor TTransactionLog.Destroy;
begin
   I3UINode.Free;
   inherited Destroy;
end;
function TTransactionLog.Get_Total: Currency;
begin
   Result:=NewTxnForm.TxnLog.Total;
end;
function TTransactionLog.Get_User: WideString;
begin
   Result:=FUser;
end;
function TTransactionLog.Get_Workstation: Integer;
begin
   Result:=FWorkStation;
end;
function TTransactionLog.Get_Office: Integer;
begin
   Result:=FOffice;
end;            
procedure TTransactionLog.CancelCustomer;
begin
   NewTxnForm.TxnLog.Clear;
   if FTxnEventSink <> nil then
      FTxnEventSink.OnChange(Self);
end;
function ToDaysPeriod:Integer;
const
  DaysUntil_010198 = 35796;
begin
   Result:=Trunc(Date)-DaysUntil_010198;
end;
procedure TTransactionLog.AddLineToTxnTable(Period,Index,Quantity,PLU,Office:Integer;Value,Price:Currency;TxnType,Desc,Info,ProgID,DomInfo,User,UID:String);
begin
   if (ProgID <> 'Product.PrePaidStamps') and (Info <> 'NegativeTxn') then  // Leave the sign as it is
     //if (ProgID = 'Product.Cash') and (TxnType = 'TxnTotal') then
     if (ProgID = 'Product.Cash') then  // Negate the sign
     begin
       Value:=0-Value;
       Price:=0-Price;
     end
     else // Allways make positive
     begin
       if Value < 0 then Value:=0-Value;
       if Price < 0 then Price:=0-Price;
     end;
   NewTxnForm.Transaction(Index,Quantity,PLU,NewTxnForm.WSNumber,Office,Period,Value,Price,User,TxnType,UID,Desc,Info,ProgID,DomInfo);
end;
procedure TTransactionLog.UpdateTxnLog(UID:String;DList:TDripList);
var
   I,J:Integer;
   CashValue:Currency;
   TxnLine:TDripLine;
   TotalTxnValue:Currency;
   CustomerTotal:Currency;
   OrigValue:Currency;
   CustomerQuantity:Integer;
   LastTopIndex:Integer;
   CurrentPeriod:Integer;
   Period:IPeriod;
   TxnDomInfoLines:TTxnDomInfoLines;
   MoneyOrder:TMoneyOrder;
   MOEvent:TMOEvent;
   MODetail:TMODetail;
   MOFee:TMOFee;
   WrtUser : String ;
   TotLine : boolean ;
begin
   Period:=CreatePeriod;
   CurrentPeriod:=Period.GetCurrentPeriod(FUser);
   Period:=nil;
   try
      if DList.FLineList.Count = 0 then Exit;
   except
      Exit;
   end;
   TotalTxnValue:=0;
   CustomerTotal:=0;
   CustomerQuantity:=0;
   LastTopIndex:=0;
   I:=0;
   TotLine := False ;
   while I < DList.FLineList.Count do
   begin
      TxnLine:=DList.FLineList[I];
      if TxnLine.TxnType = '' then
      begin
         OrigValue:=TxnLine.Value;
         if (TxnLine.Value < 0)
         and (TxnLine.ProgID = 'Product.Cash')
         and ((I+1) < DList.FLineList.Count)
         and (TDripLine(DList.FLineList[I+1]).DomInfo = 'Change') then
         begin
            CashValue:=0-TxnLine.Value;
            CashValue:=CashValue-(TDripLine(DList.FLineList[I+1]).Value);
            TxnLine.Additional:=CurrToStr(TxnLine.Value)+' Tendered, '+CurrToStr(TDripLine(DList.FLineList[I+1]).Value)+' Change';
            TDripLine(DList.FLineList[I+1]).Free;
            DList.FLineList.Delete(I+1);
            TxnLine.Price:=0-CashValue;
            TxnLine.Value:=0-CashValue;
            OrigValue:=0-CashValue;
            TxnLine.Quantity:=1;
         end;

         // Add a transaction total line for each product group
         if (TxnLine.AddIndex = 0) and TotLine then //and (TotalTxnValue <> 0) then
         begin
            TxnLine:=DList.FLineList[LastTopIndex];
            LastTopIndex:=I;
            CustomerQuantity:=CustomerQuantity+TxnLine.Quantity;
            with TxnLine do
               AddLineToTxnTable(CurrentPeriod,0,Quantity,PLU,FOffice,
                                 TotalTxnValue,TotalTxnValue,'TxnTotal',
                                 Description,'',ProgID,'',FUser,UID);
            TxnLine:=DList.FLineList[I];
            TotalTxnValue:=0;
           //TotLine:=False;
         end;
         with TxnLine do
               AddLineToTxnTable(CurrentPeriod,AddIndex,Quantity,PLU,FOffice,
                                 Value,Price,'TxnLine',Description,Additional,
                                 ProgID,DomInfo,FUser,UID);

         TotalTxnValue:=TotalTxnValue+TxnLine.Value;
         CustomerTotal:=CustomerTotal+OrigValue;
         TotLine := True ;
      end
      else
      begin
         WrtUser := FUser ;
         if TxnLine.TxnType = 'SupStkUsd' then  // Supervisor Stock Used
            WrtUser := 'Supervisor' ;

         with TxnLine do
            AddLineToTxnTable(CurrentPeriod,AddIndex,Quantity,PLU,FOffice,
                              Value,Price,TxnType,Description,Additional,
                              ProgID,DomInfo,WrtUser,UID);
         if (TxnLine.TxnType = 'StockUsed') or (TxnLine.TxnType = 'SupStkUsd') then   // Supervisor Stock Used
         begin
            if Stock = nil then Stock:=CreateStock;
            if Stock <> nil then
            begin
               Stock.AdjustStockLevel(WrtUser,TxnLine.Description,0-TxnLine.Quantity);
            end;
         end
         //else
         //if TxnLine.TxnType = 'SupStkUsd' then  // Supervisor Stock Used
         //begin
         //   if Stock = nil then Stock:=CreateStock;
         //   if Stock <> nil then
         //   begin
         //      Stock.AdjustStockLevel('Supervisor',TxnLine.Description,0-TxnLine.Quantity);
         //   end;
         //end
//         else if TxnLine.TxnType = 'RefServer' then // check for reference data txns
//         begin
//           RefServerUpdate(TxnLine);
//         end
         else if ((TxnLine.TxnType = 'MOPaid') and (TxnLine.ProgID = 'MOPaid Complete')) or
                 ((TxnLine.TxnType = 'MFPaid') and (TxnLine.ProgID = 'MFPaid Complete')) then // Pay Money Order
         begin
            if CheckSeries(TxnLine.Description) then
            begin
               MoneyOrder:=TMoneyOrder.Create;
               try
                  MoneyOrder.Series:=TxnLine.Description;
                  MoneyOrder.RemFromList(FOffice);
                  if GetGPCSRegString('Indigo3','Money Order Database Here','No') = 'Yes' then
                  begin
                     MoneyOrder.Series:=TxnLine.Description;
                     MoneyOrder.PayOffice:=FOffice;
                     MoneyOrder.PayClerk:=GetUserNumber(FUser);
                     MoneyOrder.PayPeriod:=TodayAsPeriod;
                     MoneyOrder.Events:=TMOEvents.Create;
                     MOEvent:=TMOEvent.Create;
                     MOEvent.EvType :=Integer(evPaid);
                     MOEvent.EvWho  :=GetUserNumber(FUser);
                     MOEvent.EvWhere:=FOffice;
                     MOEvent.EvWhen :=DateTimeToMoment(Now);
                     MoneyOrder.Events.Add(MOEvent);
                     MoneyOrder.SaveToTable('PSL');
                  end;
               except
                  on E:Exception do
                     RaiseGUIDException('{7F70EBF5-E495-4C84-8ECE-13DB65892E18}',E);
               end;
               MoneyOrder.Free;
            end;
         end
         else if (TxnLine.TxnType = 'MFIssue') or (TxnLine.TxnType = 'MOIssue') then // Issue Money Order
         begin
            if CheckSeries(Copy(TxnLine.Description,1,MOSeriesLength)) then
            begin
               MoneyOrder:=TMoneyOrder.Create;
               try
                  MoneyOrder.Series:=CleanMOSeries(Copy(TxnLine.Description,1,MOSeriesLength));
                  if GetGPCSRegString('Indigo3','Money Order Database Here','No') = 'Yes' then
                  begin
                     MoneyOrder.Position:=TMOPosition.Create;
                     MoneyOrder.Position.CurrentOffice:=StrToInt(GetGPCSRegString('OfficeInfo','Office ID','3201'));
                     MoneyOrder.Position.When         :=TodayAsPeriod;
                     MoneyOrder.Position.Dispatched   :=0;
                     //MoneyOrder.Position.NextOffice   :=FindNextOffice(NewTxnForm.I3UINode, MoneyOrder.Position.CurrentOffice, MoneyOrder.PayOffice);

                     MoneyOrder.Events:=TMOEvents.Create;
                     MoneyOrder.Fees:=TMOFees.Create;
                     MOFee:=TMOFee.Create;
                     MOFee.FeeType:=ftCommission;
                     MOFee.Value:=TxnLine.Value;
                     MoneyOrder.Fees.Add(MOFee);
                     MOEvent:=TMOEvent.Create;
                     MOEvent.EvType :=Integer(evIssued);
                     MOEvent.EvWho  :=GetUserNumber(FUser);
                     MOEvent.EvWhere:=FOffice;
                     MOEvent.EvWhen :=DateTimeToMoment(Now);
                     MoneyOrder.Events.Add(MOEvent);
            
                     TxnDomInfoLines:=TTxnDomInfoLines.Create;
                     TxnDomInfoLines.AddFromPackText(TxnLine.DomInfo);
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
                           if TxnDomInfoLines[J].Name = 'SendersSearchName'     then
                              MODetail.Sender.Name.Family:=TxnDomInfoLines[J].Text
                           else if TxnDomInfoLines[J].Name = 'SendersOtherNames'     then
                              MODetail.Sender.Name.Others:=TxnDomInfoLines[J].Text
                           else if TxnDomInfoLines[J].Name = 'SendersTelephone' then
                              MODetail.Sender.Address.Telephone:=TxnDomInfoLines[J].Text
                           else if TxnDomInfoLines[J].Name = 'SendersPOBox'     then
                              MODetail.Sender.Address.POBox:=StrToIntDef(TxnDomInfoLines[J].Text,0)
                           else if TxnDomInfoLines[J].Name = 'SendersAddress'    then   
                              MODetail.Sender.Address.MainLine:=TxnDomInfoLines[J].Text
                           else if TxnDomInfoLines[J].Name = 'SendersMessage'   then   
                              MODetail.Info:=TxnDomInfoLines[J].Text
                           else if TxnDomInfoLines[J].Name = 'PayeesSearchName' then
                              MODetail.Recipient.Name.Family:=TxnDomInfoLines[J].Text
                           else if TxnDomInfoLines[J].Name = 'PayeesOtherNames'     then
                              MODetail.Recipient.Name.Others:=TxnDomInfoLines[J].Text
                           else if TxnDomInfoLines[J].Name = 'PayeesTelephone'  then
                              MODetail.Recipient.Address.Telephone:=TxnDomInfoLines[J].Text
                           else if TxnDomInfoLines[J].Name = 'PayeesPOBox'      then
                              MODetail.Recipient.Address.POBox:=StrToIntDef(TxnDomInfoLines[J].Text,0)
                           else if TxnDomInfoLines[J].Name = 'PayeesAddress'    then   
                              MODetail.Recipient.Address.MainLine:=TxnDomInfoLines[J].Text;
                        end;
                        MoneyOrder.Details:=MODetail;
                     end;
                     TxnDomInfoLines.Free;
                     MoneyOrder.SaveToTable('PSL');
                  end;
                  MoneyOrder.SaveToList(FOffice);
               except
                  on E:Exception do
                     RaiseGUIDException('{54967182-FE41-4F85-AAE3-68DAB1737C7F}',E);
               end;  
               MoneyOrder.Free;
            end;
         end
         else if TxnLine.TxnType = 'RepMOPList' then
         begin
            MoneyOrder:=TMoneyOrder.Create;
            try
               MoneyOrder.ReplaceList(TxnLine.DomInfo);
            except
               on E:Exception do
                  RaiseGUIDException('{BF2DD45A-335E-43C7-A473-A6C2AA913384}',E);
            end;
            MoneyOrder.Free;
         end
         else if TxnLine.TxnType = 'MOIInfo' then // Issue Money Order
         begin
            MoneyOrder:=TMoneyOrder.Create;
            try
               MoneyOrder.PackedString:=TxnLine.DomInfo;
               if GetGPCSRegString('Indigo3','Money Order Database Here','No') = 'Yes' then
                  MoneyOrder.SaveToTable('PSL');
               MoneyOrder.SaveToList(FOffice);
            except
               on E:Exception do
                  RaiseGUIDException('{0783E78A-6882-45C7-A78C-BF114B7EF7D5}',E);
            end;
            MoneyOrder.Free;
         end
         else if TxnLine.TxnType = 'MOPInfo' then // Issue Money Order
         begin
            MoneyOrder:=TMoneyOrder.Create;
            try
               MoneyOrder.PackedString:=TxnLine.DomInfo;
               MoneyOrder.RemFromList(FOffice);
            except
               on E:Exception do
                  RaiseGUIDException('{575D04C9-8DF9-4444-86E4-2A8FC2846C3F}',E);
            end;
            MoneyOrder.Free;
         end
         else if TxnLine.TxnType = 'Account' then
         begin
            if GetGPCSRegString('Customers','LocalDatabase','0') = '1' then
               CustomerListU.TCustomers.CustomerTransaction(TxnLine.Description,TxnLine.Additional,TxnLine.Value);
         end;
      end;
      Inc(I);
   end;

   if (TotalTxnValue <> 0) or TotLine then
   begin
      TxnLine:=DList.FLineList[LastTopIndex];
      CustomerQuantity:=CustomerQuantity+TxnLine.Quantity;
      with TxnLine do
         AddLineToTxnTable(CurrentPeriod,AddIndex,Quantity,PLU,FOffice,
                           TotalTxnValue,TotalTxnValue,'TxnTotal',Description,'',
                           ProgID,'',FUser,UID);
   end;
   if CustomerTotal <> 0 then
      AddLineToTxnTable(CurrentPeriod,0,CustomerQuantity,0,FOffice,CustomerTotal,
                        0,'CustTotal','Customer Session','','','',FUser,UID);
   DList.Clear;
   Stock:=nil;
   NewTxnForm.WriteTransactions;
end;
procedure TTransactionLog.SaveTransactions(UniqueID:String);
var
   I,J:Integer;
   DripLine:TDripLine;
begin
   if DripLines = nil then
      DripLines:=TDripList.Create;
   for I:=0 to NewTxnForm.TxnLog.Count-1 do
   begin
      with (NewTxnForm.TxnLog.Items[I] as TTxnItem) do
      begin
         DripLine:=TDripLine.Create(AddIndex,Quantity,PLU,Value,Price,Description,Additional,ProgID,DomInfo,'');
         DripLines.FLineList.Add(DripLine);
         if AssociatedData.Count > 0 then
         begin
            for J:=0 to AssociatedData.Count-1 do
            begin
               with (AssociatedData.Items[J]) do
               begin
                  DripLine:=TDripLine.Create(AddIndex,Quantity,PLU,Value,Price,Description,Additional,ProgID,DomInfo,TxnType);
                  DripLines.FLineList.Add(DripLine);
               end;
            end;
         end;
      end;
   end;
   if Stock = nil then Stock:=CreateStock;
   if Stock <> nil then
   begin
      Stock.ClearTempAdjustments(FUser);
   end;
   Stock:=nil;
   UpdateTxnLog(UniqueID,DripLines);
   NewTxnForm.TxnLog.Clear;
   if FTxnEventSink <> nil then
      FTxnEventSink.OnChange(Self);
end;
procedure TTransactionLog.EndCustomer(const UniqueID:WideString);
begin
   if NewTxnForm.TxnLog.Count = 0 then Exit;
   SaveTransactions(UniqueID);
end;
procedure TTransactionLog.WriteTransaction(const TxnType:WideString;Index,Quantity,PLU:Integer;Value,Price:Currency;
                                           const Description,Additional,ProgID,DomInfo:WideString);
var
   LastLine:TTxnItem;
   AssociatedData:TTxnItem;
   FromUser:String;
   ToFrom:Char;
   CurrentPeriod:Integer;
   Period:IPeriod;
   PeriodTxn:integer;
   UserIdent:string;
   WrkType:String;
   MoneyOrder:TMoneyOrder;
begin
   Period:=CreatePeriod;
   CurrentPeriod:=Period.GetCurrentPeriod(FUser);
   Period:=nil;
   if Copy(TxnType,1,1) = '*' then // write Immediately
   begin

      if (Copy(TxnType,2,999) = 'DelUsr') then
      begin
         NewTxnForm.Transaction(
            Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
            CurrentPeriod,Value,Price,FromUser,'DelUser',
            UserIdent,Description,ProgID,'',DomInfo)
      end
      else if (Copy(TxnType,2,999) = 'AddNewUsr') then
      begin
         NewTxnForm.Transaction(
            Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
            CurrentPeriod,Value,Price,FromUser,'SetUser',
            UserIdent,Description,ProgID,'',DomInfo)
      end
      else if (Copy(TxnType,2,999) = 'CancelStockTx') then
      begin
         PeriodTxn :=StrToInt( Copy( DomInfo, 1, Pos(',',DomInfo)-1) );
         UserIdent :=Copy( DomInfo, Pos(',',DomInfo)+1,999);
         FromUser:=Copy(Additional,3,999);
         ToFrom:=Char(Additional[2]);
         if ToFrom = '>' then // accept a transfer from User to FromUser, initiated by FromUser
            NewTxnForm.Transaction(
               Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
               PeriodTxn,Value,Price,FromUser,'StockTx',
               UserIdent,Description,Additional,ProgID,'')
         else // accept a transfer from FromUser to User, initiated by FromUser
            NewTxnForm.Transaction(
               Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
               PeriodTxn,Value,Price,FromUser,'StockTx',
               UserIdent,Description,Additional,ProgID,'');
      end
      else if ((Copy(TxnType,2,999) = 'RequestTo') or (Copy(TxnType,2,999) = 'RequestFrom')) and (Copy(Additional,1,1) = '*') then
      begin
         FromUser:=Copy(Additional,2,999);
         if Copy(TxnType,2,999) = 'RequestTo' then
            WrkType := 'TxStkTo'
         else
            WrkType := 'TxStkFrom';
         NewTxnForm.Transaction(
            Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
            StrToInt(DomInfo),Value,Price,FromUser,WrkType,
            FUser,Description,Additional,ProgID,'')
      end
      else if ((Copy(TxnType,2,999) = 'TxStkTo') or (Copy(TxnType,2,999) = 'TxStkFrom')) and (Copy(Additional,1,1) = '*') then
      begin
         FromUser:=Copy(Additional,2,999);
         NewTxnForm.Transaction(
            Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
            CurrentPeriod,Value,Price,FromUser,Copy(TxnType,2,999),
            FUser,Description,Additional,ProgID,DomInfo);
      end
      else if ((Copy(TxnType,2,999) = 'TxnTotal') or (Copy(TxnType,2,999) = 'TxnLine')) and (Copy(Additional,1,1) = '*') then
      begin
         FromUser:=Copy(Additional,2,999);
         NewTxnForm.Transaction(
            Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
            CurrentPeriod,Value,Price,FromUser,Copy(TxnType,2,999),
            FUser,Description,Additional,ProgID,DomInfo);
      end
      else if (Copy(TxnType,2,999) = 'StockTx') and (Copy(Additional,1,1) = '*') then
      begin
         FromUser:=Copy(Additional,3,999);
         ToFrom:=Char(Additional[2]);
         if ToFrom = '>' then // accept a transfer from User to FromUser, initiated by FromUser
         begin
            NewTxnForm.Transaction(
               Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
               CurrentPeriod,Value,Price,FromUser,Copy(TxnType,2,999),
               DomInfo,Description,Additional,ProgID,DomInfo);
         end
         else // accept a transfer from FromUser to User, initiated by FromUser
         begin
            NewTxnForm.Transaction(
               Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
               CurrentPeriod,Value,Price,FromUser,Copy(TxnType,2,999),
               DomInfo,Description,Additional,ProgID,DomInfo);
         end;
      end
      else if (Copy(TxnType,2,999) = 'StartDay') then
      begin
         if FileExists('C:\ForcePeriod.Lck') then
         begin
            NewTxnForm.Transaction(
               Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
               CurrentPeriod,Value,Price,FUser,Copy(TxnType,2,999),
               Additional,Description,Additional,ProgID,DomInfo);
         end
         else
         begin
            NewTxnForm.Transaction(
               Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
               GetTodayasPeriod,Value,Price,FUser,Copy(TxnType,2,999),
               Additional,Description,Additional,ProgID,DomInfo);
         end;
      end
      else if (Copy(TxnType,2,999) = 'RevCashAcc') then // reverse cash account
      begin
         FromUser := DomInfo ;
         NewTxnForm.Transaction(
            Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
            StrToIntDef(Additional,CurrentPeriod),Value,Price,FromUser,'CashAcc',
            '',Description,'',ProgID,'');
      end
      else if (Copy(TxnType,2,999) = 'CashAcc') then
      begin
         NewTxnForm.Transaction(
            Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
            StrToIntDef(Additional,CurrentPeriod),Value,Price,FUser,Copy(TxnType,2,999),
            '',Description,'',ProgID,DomInfo);
      end
      else if (Copy(TxnType,2,999) = 'Account') then
      begin
         if GetGPCSRegString('Customers','LocalDatabase','0') = '1' then
            CustomerListU.TCustomers.CustomerTransaction(Description,Additional,Value);
         NewTxnForm.Transaction(
            Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
            CurrentPeriod,Value,Price,FUser,Copy(TxnType,2,999),
            Additional,Description,Additional,ProgID,DomInfo);
      end
      else if (Copy(TxnType,2,999) = 'ListUpdt') then
      begin
         UpdateLocalList(Description,Additional,ProgID);
         NewTxnForm.Transaction(
            Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
            CurrentPeriod,Value,Price,FUser,Copy(TxnType,2,999),
            Additional,Description,Additional,ProgID,DomInfo);
      end
      else if Copy(TxnType,2,999) = 'CustQuery' then
      begin
         if GetGPCSRegString('Customers','LocalDatabase','0') = '1' then
         begin
            // Execute the Query in DomInfo and log a CustRes with the packedtext in the DomInfo
            NewTxnForm.Transaction(
               Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
               CurrentPeriod,Value,Price,FUser,'CustRes',
               Additional,Description,Additional,ProgID,QueryToPackText(DomInfo));
         end
         else
         begin
            // Log the CustQuery Record
            NewTxnForm.Transaction(
               Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
               CurrentPeriod,Value,Price,FUser,Copy(TxnType,2,999),
               Additional,Description,Additional,ProgID,DomInfo);
         end
      end
      else if Copy(TxnType,2,999) = 'RepMOPList' then
      begin
         MoneyOrder:=TMoneyOrder.Create;
         try
            MoneyOrder.ReplaceList(DomInfo);
         except
            on E:Exception do
               RaiseGUIDException('{AFC2C672-DE71-4720-ABDC-C66AECF54559}',E);
         end;
         MoneyOrder.Free;
         NewTxnForm.Transaction(
            Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
            CurrentPeriod,Value,Price,FUser,Copy(TxnType,2,999),
            Additional,Description,Additional,ProgID,DomInfo);
      end                  
      else if Copy(TxnType,2,999) = 'MOIInfo' then // Issue Money Order
      begin
         MoneyOrder:=TMoneyOrder.Create;
         try
            MoneyOrder.PackedString:=DomInfo;
            MoneyOrder.SaveToList(FOffice);
         except
            on E:Exception do
               RaiseGUIDException('{50BB4DD7-5F97-40EB-9D58-00D8BAF7CA82}',E);
         end;
         MoneyOrder.Free;
         NewTxnForm.Transaction(
            Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
            CurrentPeriod,Value,Price,FUser,Copy(TxnType,2,999),
            Additional,Description,Additional,ProgID,DomInfo);
      end                  
      else if Copy(TxnType,2,999) = 'MOPInfo' then // Issue Money Order
      begin
         MoneyOrder:=TMoneyOrder.Create;
         try
            MoneyOrder.PackedString:=DomInfo;
            MoneyOrder.RemFromList(FOffice);
         except
            on E:Exception do
               RaiseGUIDException('{A98A9634-A9EF-4D9A-B6F6-C6BFB65FC6EC}',E);
         end;
         MoneyOrder.Free;
         NewTxnForm.Transaction(
            Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
            CurrentPeriod,Value,Price,FUser,Copy(TxnType,2,999),
            Additional,Description,Additional,ProgID,DomInfo);
      end                  
      else
      begin
         NewTxnForm.Transaction(
            Index,Quantity,PLU,NewTxnForm.WSNumber,FOffice,
            CurrentPeriod,Value,Price,FUser,Copy(TxnType,2,999),
            Additional,Description,Additional,ProgID,DomInfo);
      end;
      NewTxnForm.WriteTransactions;
   end
   else if NewTxnForm.TxnLog.Count > 0 then
   begin
      LastLine:=NewTxnForm.TxnLog.Items[NewTxnForm.TxnLog.Count-1];
      AssociatedData:=TTxnItem.Create(nil,Index,Quantity,PLU,Value,Price,Description,Additional,ProgID,DomInfo);
      AssociatedData.TxnType:=TxnType;
      If TxnType = 'PrLabel' then
        AssociatedData.Quantity := Quantity;  //ensure PrLabels can be logged as -ve qty

      LastLine.AssociatedData.Add(AssociatedData);
   end;
end;
procedure TTransactionLog.WriteFullTransaction(WSNumber, Period, Index, Office: Integer;
                                   const Txntype, Teller: WideString;
                                   Quantity, PLU: Integer;
                                   Value, Price: Currency;
                                   const Description, Info, ProgID, Ident, DomInfo: WideString);
var
   CurrentPeriod:IPeriod;
begin



   if Period = 0 then
   begin
      CurrentPeriod:=CreatePeriod;
      Period := CurrentPeriod.GetCurrentPeriod(FUser);
      CurrentPeriod:=nil;
   end ;

   NewTxnForm.Transaction(
            Index,Quantity,PLU,WSNumber,Office,
            Period,Value,Price,Teller,TxnType,
            Ident,Description,Info,ProgID,DomInfo);

   NewTxnForm.WriteTransactions;

end ;

procedure TTransactionLog.LogTransaction(Index,Quantity,PLU:Integer;Value,Price:Currency;
                                         const Description,Additional,ProgID,DomInfo:WideString);
begin
    //exception for Central Excise Duty
   if (LogAllAsZeroPrice) and (ProgID <> 'Product.Central') then
   begin
      Value:=0;
//      Price:=0;
   end;
   NewTxnForm.TxnLog.Add(Index,Quantity,PLU,Value,Price,Description,Additional,ProgID,DomInfo);
   if FTxnEventSink <> nil then
   begin
      FTxnEventSink.LoggedTransaction(Index,Quantity,PLU,Value,Price,Description,Additional,ProgID,DomInfo);
      FTxnEventSink.OnChange(Self);
   end;
end;
procedure TTransactionLog.Set_User(const Value: WideString);
begin
   FUser:=Value;
end;
procedure TTransactionLog.Set_Workstation(Value: Integer);
begin
   FWorkStation:=Value;
end;
procedure TTransactionLog.Set_Office(Value: Integer);
begin
   FOffice:=Value;
end;
procedure TTransactionLog.Set_Parent(Value: Integer);                
begin
   NewTxnForm.Visible:=False;
   NewTxnForm.Parent:=Value;
   NewTxnForm.Visible:=True;
end;     
function TTransactionLog.Get_SubLogVisible:WordBool;
begin
   Result:=LogAllAsZeroPrice;
   // temporary fudge to save modifying the type library
   // Result:=NewTxnForm.TxnLog.SubLogVisible;
end;
procedure TTransactionLog.Set_SubLogVisible(Value: WordBool);
begin
   LogAllAsZeroPrice:=Value;
   // temporary fudge to save modifying the type library
   // NewTxnForm.TxnLog.SubLogVisible:=Value;
   // if FTxnEventSink <> nil then
   //    FTxnEventSink.OnChange(Self);
end;
procedure TTransactionLog.SubLogClear;
begin
   NewTxnForm.TxnLog.ClearSubLog;
   if FTxnEventSink <> nil then
      FTxnEventSink.OnChange(Self);
end;
procedure TTransactionLog.SubLogTransaction(Index,Quantity,PLU:Integer;Value,Price:Currency;
           const Description,Additional,ProgID,DomInfo:WideString);
begin
   NewTxnForm.TxnLog.AddToSubLog(Index,Quantity,PLU,Value,Price,Description,Additional,ProgID,DomInfo);
   if FTxnEventSink <> nil then
      FTxnEventSink.OnChange(Self);
end;       
function TTransactionLog.Get_Additional(Index: Integer): WideString;
begin
   Result:='';
end;       
function TTransactionLog.Get_Description(Index: Integer):WideString;
begin
   Result:='';
end;       
function TTransactionLog.Get_ItemCount: Integer;                    
begin
   Result:=NewTxnForm.TxnLog.Count;
end;       
function TTransactionLog.Get_ItemIndex(Index: Integer): Integer;    
begin
   Result:=0;
end;       
function TTransactionLog.Get_Price(Index: Integer): Currency;       
begin
   Result:=0;
end;
function TTransactionLog.Get_Quantity(Index: Integer): Integer;    
begin
   Result:=0;
end;       
function TTransactionLog.Get_Value(Index: Integer): Currency;      
begin
   Result:=0;
end;       
procedure TTransactionLog.PrintReceipt;                            
begin
end;       
procedure TTransactionLog.SetEventSink(const EventSink: ITxnEventSink);
begin
   FTxnEventSink:=EventSink;
//   if DripTimer = nil then
//   begin
//      DripTimer:=TTimer.Create(nil);
//      DripTimer.OnTimer:=DripTick;
//      DripTimer.Interval:=100;
//      DripTimer.Enabled:=True;
//   end;
end;       
function TTransactionLog.Get_Contents: WideString;
var
   I:Integer;
   Lines:TPackStringList;
   LineItems:TPackStringList;
   TxnLine:TTxnItem;
   Toggle:Integer;
begin
   Lines:=TPackStringList.Create;
   LineItems:=TPackStringList.Create;
   Toggle:=1;
   for I:=0 to NewTxnForm.TxnLog.Count-1 do
   begin
      TxnLine:=NewTxnForm.TxnLog.Items[I];
      if TxnLine.AddIndex = 0 then Toggle:=Toggle xor 1;
      LineItems.Clear;
      LineItems.Add(IntToStr (TxnLine.AddIndex         ));
      LineItems.Add(          TxnLine.Description       );
      LineItems.Add(IntToStr (TxnLine.Quantity         ));
      LineItems.Add(CurrToStrF(TxnLine.Price,ffNumber,CurrencyDecimals));
      LineItems.Add(CurrToStrF(TxnLine.Value,ffNumber,CurrencyDecimals));
      LineItems.Add(IntToStr (Toggle                   ));
      LineItems.Add(          TxnLine.Additional        );
      LineItems.Add(          TxnLine.ProgID            );
      LineItems.Add(IntToStr (TxnLine.PLU              ));
      Lines.Add(LineItems.PackText);
   end;                             
   LineItems.Free;
   Result:=Lines.PackText;
   Lines.Free;
end;       
function TTransactionLog.Get_PLU(Index: Integer): Integer;
begin
   Result:=0;
end;
function TTransactionLog.Get_ProgID(Index: Integer): WideString;
begin
   Result:='';
end;
function TTransactionLog.Get_DomInfo(Index: Integer): WideString;
begin
   Result:='';
end;
procedure TTransactionLog.Delete(Index: Integer);
var
  I,J:Integer;
begin
   if Index >= NewTxnForm.TxnLog.Count Then Exit;
   while (Index > 0) and (NewTxnForm.TxnLog.Items[Index].AddIndex <> 0) do Dec(Index);
   if NewTxnForm.TxnLog.Items[Index].AddIndex <> 0 then Exit; // Shouldn't be possible!
   J:=Index;
   while (J=Index) or ((J < NewTxnForm.TxnLog.Count) and (NewTxnForm.TxnLog.Items[J].AddIndex > 0)) do
   begin
      if NewTxnForm.TxnLog.Items[J].AssociatedData.Count > 0 then
      begin
         for I:=0 to NewTxnForm.TxnLog.Items[J].AssociatedData.Count-1 do
         begin
            if NewTxnForm.TxnLog.Items[J].AssociatedData.Items[I].TxnType = 'StockUsed' then
            begin
               if Stock = nil then Stock:=CreateStock;
               if Stock <> nil then
                  Stock.AdjustStockLevel(FUser,'*'+NewTxnForm.TxnLog.Items[J].AssociatedData.Items[I].Description,NewTxnForm.TxnLog.Items[J].AssociatedData.Items[I].Quantity);
            end;
            if NewTxnForm.TxnLog.Items[J].AssociatedData.Items[I].TxnType = 'SupStkUsd' then
            begin
               if Stock = nil then Stock:=CreateStock;
               if Stock <> nil then
                  Stock.AdjustStockLevel('Supervisor','*'+NewTxnForm.TxnLog.Items[J].AssociatedData.Items[I].Description,NewTxnForm.TxnLog.Items[J].AssociatedData.Items[I].Quantity);
            end;
         end;
      end;
      Inc(J);
   end;
   Stock:=nil;
   NewTxnForm.TxnLog.Delete(Index);
   if FTxnEventSink <> nil then
      FTxnEventSink.OnChange(Self);
end;
function TTransactionLog.GetExecData(Index: Integer; var ProgID: WideString): WideString;
begin
   Result:='';
   if Index >= NewTxnForm.TxnLog.Count Then Exit;
   while (Index > 0) and (NewTxnForm.TxnLog.Items[Index].AddIndex <> 0) do Dec(Index);
   if NewTxnForm.TxnLog.Items[Index].AddIndex <> 0 then Exit; // Shouldn't be possible!
   ProgID:=NewTxnForm.TxnLog.Items[Index].ProgID;
   Result:=NewTxnForm.TxnLog.Items[Index].DomInfo;
end;
function TTransactionLog.RetrieveAccountsFor(const ProgIDList:WideString):WideString;
begin
   Result:='';
end;
procedure TTransactionLog.LogToAccounts(Quantity,PLU:Integer;Value:Currency;const ProgID:WideString);
begin
end;
function TTransactionLog.RetrieveTxnsFor(const SQLStr:WideString):WideString;
begin
end;
function TTransactionLog.Get_Hook:IHookUp;
begin
   Result:=HookUp;
end;
procedure TTransactionLog.Set_Hook(const Value:IHookUp);
begin
   HookUp:=Value;
   if Value = nil then
   begin
      Stock     := nil;
//      RefServer := nil;
   end;

end;
initialization
  TGPCSCompFactory.Create(ComServer,TTransactionLog,Class_GPCSTransactionLog,
                          'Support.TxnLog','GPCS Transaction Log',
                          ciMultiInstance);
end.
