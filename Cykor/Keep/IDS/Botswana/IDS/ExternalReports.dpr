library ExternalReports;

uses
  SysUtils,
  ComServ2,
  ComObj,
  GPCSBase_TLB,
  GPCSBaseAU,
  BaseProduct,
  PackStrListU,
  GPCSGUID;

type
  TExternalReports = class(TAutoObject)
  end;

var
   GPCSCompFactory:TGPCSCompFactory;

function PLUToSQL(PLURanges:String):String;
var
   I,P:Integer;
   List:TPackStringList;
begin
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
function RTypeToSQL(RType:String):String;
begin
   Result:=RType+''' or RecType = ''CashAcc';
end;

function BotswanaCashAccount(BaseProduct : TBaseProduct) : Boolean;
var
  FL                 : TPackStringList;
  SL                 : TPackStringList;
  TotalStock,
  StampsOnCredit,
  PostOrdsOnCredit,
  BalancingFigure,
  BalancingFigureToProve,
  ActualCash,
  CashOnHand,
  ChequesOnHand,
  TotalCashAndCheques,
  TotalReceipt,
  TotalPayment : Currency;

  TxnType : String;

   procedure TotRec(Title,Range,RType:String);
   begin
      With BaseProduct,BaseProduct.ReportParams do
         TotalReceipt:=TotalReceipt+TxnRepSection(DB,Title,PLUToSQL(Range),FromPeriod,ToPeriod,ReportLines,Summary,False,RTypeToSQL(RType));
   end;
   procedure TotPay(Title,Range,RType:String);
   begin
      With BaseProduct,BaseProduct.ReportParams do
         TotalPayment:=TotalPayment+TxnRepSection(DB,Title,PLUToSQL(Range),FromPeriod,ToPeriod,ReportLines,Summary,False,RTypeToSQL(RType));
   end;
   procedure TotStk(Title,Range:String);
   begin
      With BaseProduct,BaseProduct.ReportParams do
         TotalStock:=TotalStock+TxnRepSection(DB,Title,PLUToSQL(Range),FromPeriod,ToPeriod,FL,Summary,False,'CashAcc');
   end;
   procedure TotStS(Title,Range:String);
   begin
      With BaseProduct,BaseProduct.ReportParams do
         TotalStock:=TotalStock+StkRepSection(Stock,Title,Range,FL,False);
   end;
   procedure TotStM(Title,Range,SRange:String);
   var
      TS:Currency;
      FL:TPackStringList;
   begin
      FL:=TPackStringList.Create;
      With BaseProduct,BaseProduct.ReportParams do
      begin
         TS:=TxnRepSection(DB,'',PLUToSQL(Range),FromPeriod,ToPeriod,FL,Summary,False,'CashAcc');
         TS:=TS+StkRepSection(Stock,'',SRange,FL,False);
         ReportLines.Add('"'+Title+'","'+CurrToStrF(TS,ffNumber,2)+'"');
      end;
      TotalStock:=TotalStock+TS;
      FL.Free;
   end;
   
begin
  With BaseProduct, BaseProduct.ReportParams do
  begin
    if FOfficeNo = '' then
    begin
      FReportTitle:='Botswana Post - Full Cash Account';
      CheckReportedStock:=False;
      if FromDate = '' then
        ReportLines.Add('"Clerk Cash Account",""');
    end
    else if Copy(OfficeNo,1,1) = '!' then
    begin
       CheckReportedStock:=True;
       FReportTitle:='Botswana Post - Subs Cash Account';
    end
    else if StrToIntDef(OfficeNo,-1) = UIEventSink.Office then
    begin
       CheckReportedStock:=False;
       FReportTitle:='Botswana Post - GPO Cash Account';
    end
    else
    begin
       CheckReportedStock:=True;
       FReportTitle:='Botswana Post - Sub Cash Account';
       ReportLines.Add('"For Office '+OfficeNo+'",""');
    end;

    if CheckReportedStock then ;

    ReportLines.Add('"Receipts",""');
    ReportLines.Add('"------------------------------------------------------------------------",""');

    TotalReceipt:=0;

    DoFullUserSearch:=True;
    TotalReceipt :=                TxnRepSection(DB,'Balance Brought Forward'              ,'((PLU = 02009001) or (PLU = 61000000))'       ,FromPeriod,ToPeriod,ReportLines,Summary,False,'TxnTotal'' or RecType = ''CashAcc');
    DoFullUserSearch:=False;

    TotRec('Saving Bank Deposit'                 ,'090000201,090000203,090000211,090000213,090000221,090000223,090000230','TxnLine'  );
    TotRec('BSB Lost Book Fees'                  ,'090000240','TxnLine'  );
    TotRec('Customs Handling Charges'            ,'050020101','TxnLine'  );
    TotRec('Customs Duty Fees Botswana'          ,'050020102','TxnLine'  );
    TotRec('Customs Duty Fees South Africa'      ,'050020103','TxnLine'  );
    TotRec('COD Trade Charges'                   ,'050020009','TxnLine'  );
    TotRec('COD Handling Charges'                ,'050020008','TxnLine'  );
    TotRec('EMS Receipts - Individual'           ,'050050001,050050003','TxnLine'  );
    TotRec('EMS Receipts - Contract'             ,'050050005,050050006','TxnLine'  );
    TotRec('PO Bag Receipts'                     ,'030000030-030000039','TxnLine'  );
    TotRec('PO Box Receipts'                     ,'030000010-030000019,50031003','TxnLine'  );
    TotRec('Bulk Posting'                        ,'050000250-050000254','TxnTotal'  );
    TotRec('National Saving Certificates'        ,'090000100','TxnTotal'  );
    TotRec('Group Funeral (BLI)'                 ,'060030008','TxnLine'  );
    TotRec('Ipolokeng (BLI)'                     ,'060030009','TxnLine'  );
    TotRec('R.I.P.C.'                            ,'060030007','TxnLine'  );
    TotRec('Registration of Newspapers'          ,'050031009','TxnLine'  );
    TotRec('Money Order - Inland Issued'         ,'050021001','TxnLine'  );
    TotRec('Money Order - Foreign Issued'        ,'050021005','TxnLine'  );
    TotRec('Money Order - Commission'            ,'000100003','TxnLine'  );
    TotRec('Money Order - Other charges'         ,'050021008,050021009,050021015-050021016,050021018,050021019','TxnLine'  );
    TotRec('Money Order - Transmission Charges'  ,'050021013-050021014','TxnLine'  );
    TotRec('Postal Order Commission'             ,'100021','TxnLine'  );
    TotRec('Unaddressed Leaflets'                ,'050031010','TxnLine'  );
    TotRec('Customer Fax'                        ,'050031011','TxnLine'  );
    TotRec('Business Reply'                      ,'050031012','TxnLine'  );
    TotRec('Franking Machine'                    ,'050031004','TxnLine'  );
    TotRec('Water Affairs'                       ,'060030005','TxnLine'  );
    TotRec('Water Utilities'                     ,'060030006','TxnLine'  );
    TotRec('Housing Corporation'                 ,'060030004','TxnLine'  );
    TotRec('Department of Electrical'            ,'060030001','TxnLine'  );
    TotRec('Botswana Telecom'                    ,'060030002','TxnLine'  );
    TotRec('Miscellaneous Receipts'              ,'050032001','TxnLine'  );
    TotRec('Western Union'                       ,'-1','TxnLine'  );
    TotRec('Postage Labels'                      ,'-1','TxnLine'  );
    TotRec('Cash Received From Bank'             ,'-1','TxnLine'  );
    TotRec('5 thebe adjustment'                  ,'1000001,1000004','TxnLine'  );

    DoFullUserSearch:=True;
    if User = 'Supervisor' then
    begin
      TxnType := 'TxStkTo';  //supervisor remittances
      ReportLines.Add('"Remittances Received From Other Offices & HQ",""')
    end
    else
    begin
      TxnType := 'TxStkFrom';
      ReportLines.Add('"Received From Main Stock",""');
    end;
    TotRec('- Cash'              ,'6000005-6010000',TxnType  );
    TotRec('- Cheques'           ,'6100000-6100000',TxnType  );
    TotRec('- Stamps Items'      ,'9010005-9011000,9020005-9020125,9118000-9118150',TxnType  );
    TotRec('- Retail Items'      ,'9118160-9118999',TxnType  );
    TotRec('- Postal Orders'     ,'5100005-5101000',TxnType  );
    TotRec('- Philatelic Items'  ,'7000010-7000460',TxnType  );

    DoFullUserSearch:=False;

    ReportLines.Add('"","-------------------"');
    ReportLines.Add('A - Total Receipts,"'+CurrToStrF(TotalReceipt, ffNumber, 2)+'"');

    ReportLines.Add('"",""');
    ReportLines.Add('"Payments",""');
    ReportLines.Add('"------------------------------------------------------------------------",""');

    TotalPayment:=0;

    TotPay('Money Order - Inland Paid'             ,'050021002','TxnLine'  );
    TotPay('Money Order - Foreign Paid'            ,'050021006','TxnTotal'  );
    TotPay('Money Order - Bulk Paid'               ,'050021017','TxnTotal'  );
    TotPay('Money Order - Inland Refund'           ,'050021004','TxnTotal'  );
    TotPay('Post Ord Paid - Inland'                ,'050021051','TxnTotal'  );
    TotPay('Post Ord Paid - UK'                    ,'050021052','TxnTotal'  );
    TotPay('Post Ord Paid - Other Foreign'         ,'050021053','TxnTotal'  );
    TotPay('Savings Bank Withdrawals'              ,'090000202,090000204,090000212,090000214,090000222,090000224','TxnLine'  );
    TotPay('National Savings Certs Paid'           ,'090000101,090000102','TxnLine'  );
    TotPay('Refunds'                               ,'050031006,050031020','TxnLine'  );
    TotPay('Pensions Paid RSA'                     ,'050040003','TxnLine'  );
    TotPay('Old Age Pension Botswana'              ,'050040001,050040002','TxnLine'  );
    TotPay('Discount To Vendors'                   ,'060020011','TxnLine'  );
    TotPay('Miscellaneous Payments'                ,'050032002','TxnLine'  );
    TotPay('Western Union'                         ,'-1','TxnLine'  );
    TotPay('Imprest and travel claims'             ,'050033002','TxnLine'  );
    TotPay('Salaries P&P'                          ,'050033001','TxnLine'  );
    TotPay('Wages Industrial Class'                ,'050033003','TxnLine'  );
    TotPay('Temporary Staff'                       ,'050033004','TxnLine'  );
    TotPay('Death Claim'                           ,'050033005','TxnLine'  );
    TotPay('Deposit With Bank'                     ,'-1','TxnLine'  );
    TotPay('5 thebe adjustment'                    ,'1000002-1000003','TxnLine'  );

    DoFullUserSearch:=True;
    if User = 'Supervisor' then
    begin
      TxnType := 'TxStkFrom';  //supervisor remittances
      ReportLines.Add('"Remittances Despatched To Other Offices & HQ",""')
    end
    else
    begin
      TxnType := 'TxStkTo';
      ReportLines.Add('"Returned To Main Stock",""');
    end;
    TotPay('- Cash'                   ,'6000005-6010000',TxnType  );
    TotPay('- Cheques'                ,'6100000-6100000',TxnType  );
    TotPay('- Stamp Items'            ,'9010005-9011000,9020005-9020125,9118000-9118150',TxnType  );
    TotPay('- Retail Items'           ,'9118160-9118999',TxnType  );
    TotPay('- Postal Orders'          ,'5100005-5101000',TxnType  );
    TotPay('- Philatelic Items'       ,'7000010-7000460',TxnType  );
    DoFullUserSearch:=False;

    ReportLines.Add('"","-------------------"');
    ReportLines.Add('B - Total Payments,"'+CurrToStrF(TotalPayment, ffNumber, 2)+'"');

    FL:=TPackStringList.Create;

    ReportLines.Add('"",""');
    ReportLines.Add('"Cash On Hand",""');
    ReportLines.Add('"------------------------------------------------------------------------",""');
    //    CashOnHand is used later in the "Balancing" section
    CashOnHand :=              TxnRepRelSection(DB,''              ,'Prod = ''Product.Cash'''              ,FromPeriod,ToPeriod,FL,Summary,False,'TxnTotal'' or RecType = ''StartDay');
    CashOnHand := CashOnHand + TxnRepSection   (DB,''              ,'((PLU = 1000001) or (PLU = 1000004))' ,FromPeriod,ToPeriod,FL,Summary,False,'TxnLine'' or RecType = ''CashAcc');
    CashOnHand := CashOnHand - TxnRepSection   (DB,''              ,'((PLU = 1000002) or (PLU = 1000003))' ,FromPeriod,ToPeriod,FL,Summary,False,'TxnLine'' or RecType = ''CashAcc');
    ReportLines.Add('- Cash on Hand,"' +CurrToStrF(CashOnHand, ffNumber, 2)+'"');

    ChequesOnHand:= StkRepSection(Stock,'','6100000-6100000',FL,True);
    ReportLines.Add('- Cheques on Hand,"' +CurrToStrF(ChequesOnHand, ffNumber, 2)+'"');

    TotalCashAndCheques := CashOnHand + ChequesOnHand;
    ReportLines.Add('"","-------------------"');
    ReportLines.Add('C - Total Cash,"'+CurrToStrF(TotalCashAndCheques, ffNumber, 2)+'"');

    ReportLines.Add('"",""');
    ReportLines.Add('"Stock On Hand",""');
    ReportLines.Add('"------------------------------------------------------------------------",""');
    TotalStock := 0;
//    TotStS('- Stamp Items'           ,'9010005-9011000,9020005-9020125,9118010-9118150');
//    TotStS('- Retail Items'          ,'9118160-9118610');
//    TotStS('- Postal Orders'         ,'5100005-5101000');
//    TotStS('- Philatelic Items'      ,'7000010-7000460');
    TotalStock := TotalStock + StkRepSection(Stock,'- Stamp Items'      ,'9010005-9011000,9020005-9020125, 9118000-9118150',ReportLines,True);
    TotalStock := TotalStock + StkRepSection(Stock,'- Retail Items'     ,'9118160-9118999',ReportLines,True);
    TotalStock := TotalStock + StkRepSection(Stock,'- Postal Orders'    ,'5100005-5101000',ReportLines,True);
    TotalStock := TotalStock + StkRepSection(Stock,'- Philatelic Items' ,'7000010-7000460',ReportLines,True);

// Stock supplied to agencies on credit should only show on the Supervisor account
    if User = 'Supervisor' then
    begin
       StampsOnCredit := 0;
       TotalStock := TotalStock + StampsOnCredit;
       ReportLines.Add('- Stamps Supplied On Credit,"'+CurrToStrF(StampsOnCredit, ffNumber, 2)+'"');
       PostOrdsOnCredit := 0;
       TotalStock := TotalStock + PostOrdsOnCredit;
       ReportLines.Add('- Postal Orders Supplied On Credit,"'+CurrToStrF(PostOrdsOnCredit, ffNumber, 2)+'"');
    end;

    ReportLines.Add('"","-------------------"');
    ReportLines.Add('D - Total Stock,"'+CurrToStrF(TotalStock, ffNumber, 2)+'"');

    ReportLines.Add('"",""');
    ReportLines.Add('"Balancing",""');
    ReportLines.Add('"------------------------------------------------------------------------",""');

    BalancingFigure := TotalReceipt-TotalPayment;
    ReportLines.Add('E - Balancing Figure,"'+CurrToStrF(BalancingFigure, ffNumber, 2)+'"');

    ReportLines.Add('"",""');
    BalancingFigureToProve := TotalCashAndCheques + TotalStock;
    ReportLines.Add('F - Balancing Figure To Prove,"'+CurrToStrF(BalancingFigureToProve, ffNumber, 2)+'"');

    ReportLines.Add('"",""');
    ActualCash := TxnRepSection   (DB,'I - Actual Cash'         ,'((PLU >= 6000001) and (PLU <= 6100001))',FromPeriod,ToPeriod,FL,stSummary,False,'StockDec');
    ReportLines.Add('G - Actual Cash,"'+CurrToStrF(ActualCash, ffNumber, 2)+'"');

    ReportLines.Add('"",""');
    if TotalCashAndCheques > ActualCash then
    begin
       ReportLines.Add('Cash Shortage,"'+CurrToStrF(TotalCashAndCheques-ActualCash, ffNumber, 2)+'"');
    end;
    if TotalCashAndCheques < ActualCash then
    begin
       ReportLines.Add('Cash Over,"'+CurrToStrF(TotalCashAndCheques-ActualCash, ffNumber, 2)+'"');
    end;
    if TotalCashAndCheques = ActualCash then
    begin
       ReportLines.Add('"Cash Balances",""');
    end;
  ReportLines.Add('"------------------------------------------------------------------------",""');
  end;  //with BaseProduct
  Result := True;
end;

function GetIComponent:IComponent;
begin
   if GPCSCompFactory = nil then
   begin
      GPCSCompFactory:=
      TGPCSCompFactory.Create(ComServer,{PClass}TExternalReports,
                              StringToGUID({PGUID}'{B9CDDA65-A52E-479E-AE50-7EDB26BDFECA}'),
                              {PProgID}'Utility.Reports',{PRegDesc}'Corvus External Reports',ciMultiInstance);
   end;
   Result:=nil; //TExternalReports.Create;
end;

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer,
  GetIComponent,
  BotswanaCashAccount;


begin
  GetIComponent;
end.



