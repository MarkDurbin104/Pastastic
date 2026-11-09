unit ExternalFunc;

interface

uses
  BaseProduct,
  Classes,
  sysutils,
  GPCSGUID,
  GPCSBase_TLB,
  DataBaseServer_TLB,
  GPCSErrorCode,
  GPCSErrorLine,
  ReportPreviewF,
  PackStrListU,
  TxnTranslateU;

   const
      NumberDecimals = 2 ;

   function ClientReturnData( StartDomainText, EndDomainText, User, Office  : String; SummaryOnly : Boolean  ) : string;
   function MFReportData( StartDomainText, EndDomainText, User, Office : String; SummaryOnly : Boolean ) : string;
   function MOReportData( StartDomainText, EndDomainText, User, Office : String; SummaryOnly : Boolean ) : string;
   function EMSReportData( StartDomainText, EndDomainText, User, Office : String; SummaryOnly : Boolean ) : string;

   procedure A4ReportPrint(User, Office, ReportTitle, ColumnHeaders, TotalLine, ColumnWidths : String; ReportLines : String);
   function  ReceiptReportLines(User, Office, StartDate, EndDate, ReportTitle, ColumnHeaders, TotalLine : String;
                               ReportLines : String) : String;
   procedure AddA4Line( ResultList : TStringList; NumberOfColumns : Integer );
   procedure AddSolidLine( ResultList : TStringList );
   procedure BlankLine( ResultList : TStringList );
   function  ExtractBoxNo(S:String):String;
   procedure DomesticEMS( ResultList : TStringList ; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );
   procedure IntEMSDocuments( ResultList : TStringList ; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );
   procedure IntEMSParcels( ResultList : TStringList ; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );
   procedure MiscReceipts( ResultList : TStringList ; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );
   procedure PrePaidPostage( ResultList : TStringList ; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );
   procedure PaymentVoucher( ResultList : TStringList ; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );
   procedure PostalOrdersIssued( ResultList : TStringList ; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );
   procedure PostBoxRentalCharges( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );
   procedure PostBagRentalCharges( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );
   procedure PostalOrdersPaid( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );
   procedure FaxMoneyOrdersIssued( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean ) ;
   procedure FaxMoneyOrdersPaid( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean ) ;
   procedure MoneyOrdersIssued( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean ) ;
   procedure MoneyOrdersPaid( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean ) ;
   procedure ServiceMoneyOrdersIssued( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean ) ;
   procedure InternationalSpeedCashIssued( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean ) ;
   procedure InternationalSpeedCashPaid( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean ) ;
   procedure PostbankWithdrawals( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean ) ;
   procedure PostbankDeposits( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean ) ;
   procedure AddLine( ResultList : TStringList );
   procedure Centre(CentreString : String ; ResultList : TStringList );
   function ToDaysPeriod:Integer;
   function LeftPad(S:String;Len:Integer;PadChar:Char):String;
   function RightPad(S:String;Len:Integer;PadChar:Char):String;
   function StrToPeriod(DateS:String):String;
   function UserSearch( User: String ):String;

implementation
   uses IDSConstants ;


function ClientReturnData( StartDomainText, EndDomainText, User, Office : String; SummaryOnly : Boolean ) : string;
var
  A,B:Integer;
  ResultList : TStringList ;
  DatabaseServer : IDataBaseServerAuto ;
  StartPeriod, EndPeriod : String;
  StartDateString,EndDateString : String;
  TotalPrice:Real;
begin

  Result := '' ;
  A:= 0;

  try
    //database server
    DatabaseServer:= CoDatabaseServerAuto.CreateRemote(GetGPCSRegString('','Transaction ServerName',GetLocalMachineName));
    ResultList := TStringList.Create;

    try
      DatabaseServer.DataAlias := 'PSL';

      //insert '/' into dates
      StartPeriod:=StrToPeriod(StartDomainText);
      EndPeriod  :=StrToPeriod(EndDomainText);
      StartDateString := Copy(StartDomainText,1,2) + '/'
                          + Copy(StartDomainText,4,2) + '/'
                          + Copy(StartDomainText,7,2);
      EndDateString   := Copy(EndDomainText,1,2) + '/'
                          + Copy(EndDomainText,4,2) + '/'
                          + Copy(EndDomainText,7,2);


      //headers
      BlankLine( ResultList );
      if SummaryOnly then
         Centre('Client Returns Summary', ResultList )
      else
         Centre('Client Returns', ResultList );

      AddLine(ResultList);
      ResultList.Add('"Teller","'+User+'"');
      ResultList.Add('"Office","'+Office+'"');
      ResultList.Add('"Dates"," ' + StartDateString + ' to ' + EndDateString + '"');
      AddLine(ResultList);

      BlankLine( ResultList );
      Centre('Receipts', ResultList );
      B:=ResultList.Count;

      if not SummaryOnly then
      begin
         //postal orders Issued
         BlankLine( ResultList );
         Centre('Postal Orders Issued', ResultList );
         BlankLine( ResultList );
         A:=ResultList.Count;
      end ;

      PostalOrdersIssued( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      if not SummaryOnly then
        if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      //if not SummaryOnly then
      //begin
      //   //postal orders Issued
      //   BlankLine( ResultList );
      //   Centre('Miscellaneous Receipts', ResultList );
      //   BlankLine( ResultList );
      //   A:=ResultList.Count;
      //end ;

      //MiscReceipts( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      //if not SummaryOnly then
      //  if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      //if not SummaryOnly then
      //begin
      //   //postal orders Issued
      //   BlankLine( ResultList );
      //   Centre('Pre-Paid Postage', ResultList );
      //   BlankLine( ResultList );
      //   A:=ResultList.Count;
      //end ;

      //PrePaidPostage( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      //if not SummaryOnly then
      //  if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      //domestic money orders Issued

      if not SummaryOnly then
      begin
         BlankLine( ResultList );
         Centre('Money Orders Issued', ResultList );
         BlankLine( ResultList );
         A:=ResultList.Count;
      end ;
      MoneyOrdersIssued( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      if not SummaryOnly then
         if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      //if not SummaryOnly then
      //begin
      //   BlankLine( ResultList );
      //   Centre('Service Money Orders Issued', ResultList );
      //   BlankLine( ResultList );
      //   A:=ResultList.Count;
      //end ;
      //ServiceMoneyOrdersIssued( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      //if not SummaryOnly then
      //   if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      //Foreign Speed Cash Issued
      if not SummaryOnly then
      begin
         BlankLine( ResultList );
         Centre('Foreign Speed Cash Issued', ResultList );
         BlankLine( ResultList );
         A:=ResultList.Count;
      end ;
      InternationalSpeedCashIssued( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      if not SummaryOnly then
         if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      //Savings Bank Deposit
      if not SummaryOnly then
      begin
         BlankLine( ResultList );
         Centre('Savings Bank Deposit', ResultList );
         BlankLine( ResultList );
         A:=ResultList.Count;
      end ;
      PostbankDeposits( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      if not SummaryOnly then
         if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      //Post Box Rental Charges
      if not SummaryOnly then
      begin
         BlankLine( ResultList );
         Centre('Post Box Rental Charges', ResultList );
         BlankLine( ResultList );
         A:=ResultList.Count;
      end ;
      PostBoxRentalCharges( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      if not SummaryOnly then
         if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      //Post Box Rental Charges
      if not SummaryOnly then
      begin
         BlankLine( ResultList );
         Centre('Post Bag Rental Charges', ResultList );
         BlankLine( ResultList );
         A:=ResultList.Count;
      end ;
      PostBagRentalCharges( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      if not SummaryOnly then
         if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      if B = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      BlankLine( ResultList );
      Centre('Payments', ResultList );
      B:=ResultList.Count;

      //postal orders paid

      if not SummaryOnly then
      begin
         BlankLine( ResultList );
         Centre('Postal Orders Paid', ResultList );
         BlankLine( ResultList );
         A:=ResultList.Count;
      end ;
      PostalOrdersPaid( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      if not SummaryOnly then
         if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      // Payment Vouchers
      //if not SummaryOnly then
      //begin
      //   BlankLine( ResultList );
      //   Centre('Payment Vouchers', ResultList );
      //   BlankLine( ResultList );
      //   A:=ResultList.Count;
      //end ;
      //PaymentVoucher( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      //if not SummaryOnly then
      //   if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      //domestic money orders paid

      if not SummaryOnly then
      begin
         BlankLine( ResultList );
         Centre('Money Orders Paid', ResultList );
         BlankLine( ResultList );
         A:=ResultList.Count;
      end ;
      MoneyOrdersPaid( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      if not SummaryOnly then
         if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      //Foreign Speed Cash Paid

      if not SummaryOnly then
      begin
         BlankLine( ResultList );
         Centre('Foreign Speed Cash Paid', ResultList );
         BlankLine( ResultList );
         A:=ResultList.Count;
      end ;
      InternationalSpeedCashPaid( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      if not SummaryOnly then
         if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      //Savings Bank Withdrawal

      if not SummaryOnly then
      begin
         BlankLine( ResultList );
         Centre('Savings Bank Withdrawal', ResultList );
         BlankLine( ResultList );
         A:=ResultList.Count;
      end ;
      PostbankWithdrawals( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      if not SummaryOnly then
         if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      if B = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

    finally
      Result := ResultList.CommaText ;
      ResultList.Free;
      DatabaseServer := nil;
      //TerminateExecute(TxnLog);
    end;
  except
    On  E:Exception do
      RaiseException($401,E);
  end;

end;


function UserSearch( User: String ):String;
begin
  Result:='';

  if User <> 'Supervisor' then
     Result:=' and Teller = ''' + User + '''';
end;

procedure MiscReceipts( ResultList : TStringList ; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );
var
  RecordIndex : Integer;
  QueryStringList : TStringList;
  RecordStringList:TStringList;
  TxnLogQuery : String;
begin
  QueryStringList :=TStringList.Create;
  RecordStringList :=TStringList.Create;
  TxnLogQuery :=
  ' select Prod, Price, Info, TxnValue, DateTime, RecordID  from TxnLog'
  + ' where (Prod  = ''Product.Miscellaneou'')'
  + ' and RecType = ''TxnLine'''
  + UserSearch( User )
  //start/end date converted to periods
  + ' and Period >= ' + StartPeriod
  + ' and Period <= ' +  EndPeriod
  + ' order by DateTime, RecordID'
  ;
  QueryStringList.CommaText := DatabaseServer.QueryToCommaText(TxnLogQuery);

  //extract reqd columns
  TotalPrice := 0;
  if QueryStringList.CommaText <> '' then
  begin
    For RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin
      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[3]:=CurrToStrF(Abs(StrToCurr(RecordStringList[3])),ffNumber, NumberDecimals);
      if not SummaryOnly then
         begin
           ResultList.Add('"'
           //        + LeftPad(RecordStringList[0],18,' ')               //Postal Order Denomination
                   + RecordStringList[2] + '","'  //Serial Number
                   + RecordStringList[3] + '"');  //Value
         end;
      //update bottom totals
      TotalPrice := TotalPrice + StrToInt(RecordStringList[3]);
    end;
    //add bottom totals
    if not SummaryOnly then
    begin
       AddLine(ResultList);
       ResultList.Add('"Total","' + CurrToStrF(TotalPrice,ffNumber,NumberDecimals) + '"');
       AddLine(ResultList);
    end
    else
       ResultList.Add('"Miscellaneous Receipts","' + CurrToStrF(TotalPrice,ffNumber,NumberDecimals) + '"');
  end;
  QueryStringList.Free;
  RecordStringList.Free;
end;
procedure PrePaidPostage( ResultList : TStringList ; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );
var
  RecordIndex : Integer;
  QueryStringList : TStringList;
  RecordStringList:TStringList;
  TxnLogQuery : String ;
begin
  QueryStringList :=TStringList.Create;
  RecordStringList :=TStringList.Create;
  TxnLogQuery :=
  ' select Prod, Price, Info, TxnValue, DateTime, RecordID  from TxnLog'
  + ' where (Prod  = ''Product.PPPostage'')'
  + ' and RecType = ''TxnLine'''
  + UserSearch( User )
  //start/end date converted to periods
  + ' and Period >= ' + StartPeriod
  + ' and Period <= ' +  EndPeriod
  + ' order by DateTime, RecordID'
  ;
  QueryStringList.CommaText := DatabaseServer.QueryToCommaText(TxnLogQuery);

  //extract reqd columns
  TotalPrice := 0;
  if QueryStringList.CommaText <> '' then
  begin
    For RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin
      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[3]:=IntToStr(Abs(StrToInt(RecordStringList[3])));
      if not SummaryOnly then
         begin
           ResultList.Add('"'
           //        + LeftPad(RecordStringList[0],18,' ')               //Postal Order Denomination
                   + RecordStringList[2] + '","'  //Serial Number
                   + RecordStringList[3] + '"');  //Value
         end;
      //update bottom totals
      TotalPrice := TotalPrice + StrToInt(RecordStringList[3]);
    end;
    //add bottom totals
    if not SummaryOnly then
    begin
       AddLine(ResultList);
       ResultList.Add('"Total","' + CurrToStrF(TotalPrice,ffNumber,NumberDecimals) + '"');
       AddLine(ResultList);
    end
    else
       ResultList.Add('"Pre-Paid Postage","' + CurrToStrF(TotalPrice,ffNumber,NumberDecimals) + '"');
  end;
  QueryStringList.Free;
  RecordStringList.Free;
end;
procedure PaymentVoucher( ResultList : TStringList ; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );
var
  RecordIndex : Integer;
  QueryStringList : TStringList;
  RecordStringList:TStringList;
  TxnLogQuery : String ;
begin
  QueryStringList :=TStringList.Create;
  RecordStringList :=TStringList.Create;
  TxnLogQuery :=
  ' select Prod, Price, Info, TxnValue, DateTime, RecordID  from TxnLog'
  + ' where (Prod  = ''Product.PayVouch'')'
  + ' and RecType = ''TxnLine'''
  + UserSearch( User )
  //start/end date converted to periods
  + ' and Period >= ' + StartPeriod
  + ' and Period <= ' +  EndPeriod
  + ' order by DateTime, RecordID'
  ;
  QueryStringList.CommaText := DatabaseServer.QueryToCommaText(TxnLogQuery);

  //extract reqd columns
  TotalPrice := 0;
  if QueryStringList.CommaText <> '' then
  begin
    For RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin
      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[3]:=IntToStr(Abs(StrToInt(RecordStringList[3])));
      if not SummaryOnly then
         begin
           ResultList.Add('"'
           //        + LeftPad(RecordStringList[0],18,' ')               //Postal Order Denomination
                   + RecordStringList[2] + '","'  //Serial Number
                   + RecordStringList[3] + '"');  //Value
         end;
      //update bottom totals
      TotalPrice := TotalPrice + StrToCurr(RecordStringList[3]);
    end;
    //add bottom totals
    if not SummaryOnly then
    begin
       AddLine(ResultList);
       ResultList.Add('"Total","' + CurrToStrF(TotalPrice,ffNumber,NumberDecimals) + '"');
       AddLine(ResultList);
    end
    else
       ResultList.Add('"Payment Vouchers","' + CurrToStrF(TotalPrice,ffNumber, NumberDecimals) + '"');
  end;
  QueryStringList.Free;
  RecordStringList.Free;
end;
procedure PostalOrdersIssued( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );
var
  Lines:TTransactionLines;
  RecordIndex : Integer;
  QueryStringList : TStringList;
  RecordStringList:TStringList;
begin

   QueryStringList :=TStringList.Create;
   RecordStringList :=TStringList.Create;
   Lines:=TTxnTranslate.TranslateQuery('',
                                          'select * from txnlog            '+
                                          'where                           '+
                                          '  Period >= ' + StartPeriod  + ' and ' +
                                          '  Period <= ' +  EndPeriod   +
                                             UserSearch( User )         + ' and ' +
                                          '  PLU >=''5000000'' and ' +
                                          '  PLU <=''5599999'' and ' +
                                          '  RecType = ''TxnLine'' '
                                       );

   Lines.FieldsResult := 'SerialNumber,Commission';
   QueryStringList.CommaText := Lines.CommaText ;
   Lines.Free;

  TotalPrice := 0;
  //check for no postal orders
  If QueryStringList.CommaText <> '' then  //blank
  begin
////      ResultList.Add('"None"," "')  ;
//  end
//  else  //postal orders Issued
//  begin
    For RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin
      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[Const_FItemValue]:=CurrToStrF(Abs(StrToCurr(RecordStringList[Const_FItemValue])), ffNumber, NumberDecimals);
      if not SummaryOnly then
      begin

           ResultList.Add('"   '
                   + RecordStringList[Const_OffSetHead+1] + '","'  //Serial Number
                   + RecordStringList[Const_FItemValue  ] + '"');       //Value
           ResultList.Add('"   Commission","'  + RecordStringList[Const_OffSetHead+2] + '"');       //Value
          //update bottom totals
      end ;
      TotalPrice := TotalPrice + StrToCurrDef(RecordStringList[Const_FItemValue]   ,0)
                               + StrToCurrDef(RecordStringList[Const_OffSetHead+2] ,0) ;
    end;
    //add bottom totals
    if not SummaryOnly then
    begin
       AddLine(ResultList);
       ResultList.Add('"Total","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');
       AddLine(ResultList);
    end
    else
       ResultList.Add('"Postal Orders Issued","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');

  end;
  QueryStringList.Free;
  RecordStringList.Free;

end;


function ExtractBoxNo(S:String):String;
var
   I:Integer;
begin
   S:=Trim(S);
   Result:=S;
   for I:=1 to Length(S) do
   begin
      if S[I] = ' ' then
      begin
         Result:=Copy(S,1,I-1);
         Exit;
      end;
   end;
end;

procedure PostBoxRentalCharges( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );

var
  Lines:TTransactionLines;
  RecordIndex : Integer;
  QueryStringList : TStringList;
  RecordStringList:TStringList;
begin


   QueryStringList :=TStringList.Create;
   RecordStringList :=TStringList.Create;

   Lines:=TTxnTranslate.TranslateQuery('',
                                          'select * from txnlog            '+
                                          'where                           '+
                                          '  Period >= ' + StartPeriod  + ' and ' +
                                          '  Period <= ' +  EndPeriod   +
                                             UserSearch( User )         + ' and ' +
                                          '  PLU in ('+PLU_PrivBoxAnnualRent+','+PLU_PBQuarterRent+
                                          '          ) and ' +
                                          '  RecType = ''TxnLine'' '
                                       );

   Lines.FieldsResult := 'PrivateBoxNumber';
   QueryStringList.CommaText := Lines.CommaText ;

   Lines.Free;

  TotalPrice := 0;
  //check for no postal orders
  If QueryStringList.CommaText = '' then  //blank
  begin
//      ResultList.Add('"None"," "')  ;
  end
  else  //postal orders Issued
  begin
    For RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin
      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[Const_FItemValue]:=CurrToStrF(Abs(StrToCurr(RecordStringList[Const_FItemValue])), ffNumber, NumberDecimals);
      if not SummaryOnly then
         ResultList.Add('"'
   //              + LeftPad(RecordStringList[0],18,' ') // Post Box Type
                 + ' '+ ExtractBoxNo(RecordStringList[Const_OffSetHead+1]) + '","' // Box Number
                 + RecordStringList[Const_FItemValue] + '"');          // Value
      //update bottom totals
      TotalPrice := TotalPrice + StrToCurrDef(RecordStringList[Const_FItemValue], 0);
    end;
    //add bottom totals
    if not SummaryOnly then
    begin
       AddLine(ResultList);
       ResultList.Add('"Total","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');
       AddLine(ResultList);
    end
    else
    ResultList.Add('"Post Box Rental Charges","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');
  end;
  QueryStringList.Free;
  RecordStringList.Free;

end;

procedure PostBagRentalCharges( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );

var
  Lines:TTransactionLines;
  RecordIndex : Integer;
  QueryStringList : TStringList;
  RecordStringList:TStringList;
begin
   QueryStringList :=TStringList.Create;
   RecordStringList :=TStringList.Create;

   Lines:=TTxnTranslate.TranslateQuery('',
                                          'select * from txnlog            '+
                                          'where                           '+
                                          '  Period >= ' + StartPeriod  + ' and ' +
                                          '  Period <= ' +  EndPeriod   +
                                             UserSearch( User )         + ' and ' +
                                          '  PLU in ('+PLU_BagNewRental+','+PLU_BagAnnualRent+','+
                                                       PLU_BagQuarterRent+
                                          '          ) and ' +
                                          '  RecType = ''TxnLine'' '

                                       );

   Lines.FieldsResult := 'PrivateBagNumber';
   QueryStringList.CommaText := Lines.CommaText ;
   Lines.Free;

  //extract reqd columns
  TotalPrice := 0;
  //check for no postal orders
  If QueryStringList.CommaText = '' then  //blank
  begin
//      ResultList.Add('"None"," "')  ;
  end
  else
  begin
    For RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin
      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[Const_FItemValue]:=CurrToStrF(Abs(StrToCurr(RecordStringList[Const_FItemValue])), ffNumber, NumberDecimals);
      if not SummaryOnly then
         ResultList.Add('"'
   //              + LeftPad(RecordStringList[0],18,' ') // Post Box Type
                 + ' '+ ExtractBoxNo(RecordStringList[Const_OffSetHead+1]) + '","' // Box Number
                 + RecordStringList[Const_FItemValue] + '"');          // Value
      //update bottom totals
      TotalPrice := TotalPrice + StrToCurrDef(RecordStringList[Const_FItemValue], 0);
    end;
    //add bottom totals
    if not SummaryOnly then
    begin
       AddLine(ResultList);
       ResultList.Add('"Total","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');
       AddLine(ResultList);
    end
    else
    ResultList.Add('"Post Bag Rental Charges","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');
  end;
  QueryStringList.Free;
  RecordStringList.Free;

end;

procedure PostalOrdersPaid( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );
var
  Lines:TTransactionLines;
  RecordIndex : Integer;
  QueryStringList : TStringList;
  RecordStringList:TStringList;
begin

   QueryStringList :=TStringList.Create;
   RecordStringList :=TStringList.Create;
   Lines:=TTxnTranslate.TranslateQuery('',
                                          'select * from txnlog            '+
                                          'where                           '+
                                          '  Period >= ' + StartPeriod  + ' and ' +
                                          '  Period <= ' +  EndPeriod   +
                                             UserSearch( User )         + ' and ' +
                                          '  PLU = '+PLU_PostalOrderPay + ' and ' +
                                          '  RecType = ''TxnLine'' '
                                       );

   Lines.FieldsResult := 'SerialNumber';
   QueryStringList.CommaText := Lines.CommaText ;
   Lines.Free;

  TotalPrice := 0;
  //check for no postal orders
  If QueryStringList.CommaText = '' then  //blank
  begin
//      ResultList.Add('"None"," "')  ;
  end
  else  //postal orders Issued
  begin
    For RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin
      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[Const_FItemValue]:=CurrToStrF(Abs(StrToCurr(RecordStringList[Const_FItemValue])), ffNumber, NumberDecimals);
      if not SummaryOnly then
         ResultList.Add('"'
                 + ' '+ RecordStringList[Const_OffSetHead+1] + '","'  //Serial Number
                 + RecordStringList[Const_FItemValue] + '"');       //Value
      //update bottom totals
      TotalPrice := TotalPrice + StrToCurrDef(RecordStringList[Const_FItemValue], 0);
    end;
    //add bottom totals
    if not SummaryOnly then
    begin
       AddLine(ResultList);
       ResultList.Add('"Total","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');
       AddLine(ResultList);
    end
    else
       ResultList.Add('"Postal Orders Paid","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');

  end;
  QueryStringList.Free;
  RecordStringList.Free;
end;

procedure ServiceMoneyOrdersIssued( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean ) ;
var
  RecordIndex  : Integer;
  QueryStringList : TStringList;
  RecordStringList:TStringList;
  TxnLogQuery : String ;
begin
  QueryStringList :=TStringList.Create;
  RecordStringList :=TStringList.Create;

  TxnLogQuery :=
  ' select Description, Price, Info, TxnValue ,DateTime, RecordID from TxnLog'
  + ' where (Description = ''Service Money Order'')'
  + ' and RecType = ''TxnLine'''
  + UserSearch( User )
  //start/end date converted to periods
  + ' and Period >= ' + StartPeriod
  + ' and Period <= ' +  EndPeriod
  + ' order by DateTime, RecordID'
  ;
  QueryStringList.CommaText := DatabaseServer.QueryToCommaText(TxnLogQuery);

  //extract reqd columns
  TotalPrice := 0;
  //check for no postal orders
  If QueryStringList.CommaText = '' then  //blank
  begin
//      ResultList.Add('"None"," "')  ;
  end
  else  //postal orders Issued
  begin
    For RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin
      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[3]:=IntToStr(Abs(StrToInt(RecordStringList[3])));
      if not SummaryOnly then
         ResultList.Add('"'
                 + ' '+ RecordStringList[2] + '","'  //Serial Number
                 + RecordStringList[3] + '"');       //Value
      //update bottom totals
      TotalPrice := TotalPrice + StrToCurrDef(RecordStringList[3],0);
    end;
    //add bottom totals
    if not SummaryOnly then
    begin
       AddLine(ResultList);
       ResultList.Add('"Total","' + CurrToStrF(TotalPrice,ffNumber,NumberDecimals) + '"');
       AddLine(ResultList);
    end
    else
       ResultList.Add('"Service Money Orders Issued","' + CurrToStrF(TotalPrice,ffNumber, NumberDecimals) + '"');

  end;
  QueryStringList.Free;
  RecordStringList.Free;
end;

procedure FaxMoneyOrdersIssued( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean ) ;
var
  RecordIndex  : Integer;
  QueryStringList : TStringList;
  RecordStringList:TStringList;
  TxnLogQuery : String ;
  SerialNo  :String;
  Value     :String;
  Commission:String;
  TotalValue:Real;
  TotalCommi:Integer;
  TotalFee:Integer;
  ItemCount:Integer;
begin
  QueryStringList :=TStringList.Create;
  RecordStringList :=TStringList.Create;

  TxnLogQuery :=
  ' select Description, Price, Info, TxnValue ,DateTime, RecordID from TxnLog'
  + ' where (Description = ''Money Fax Issue'' or Prod = ''Money Fax Comm.'' or Prod = ''Pay Office'' or Prod = ''Money Fax Fee'')'
  + ' and RecType = ''TxnLine'''
  + UserSearch( User )
  //start/end date converted to periods
  + ' and Period >= ' + StartPeriod
  + ' and Period <= ' +  EndPeriod
  + ' order by DateTime, RecordID'
  ;
  QueryStringList.CommaText := DatabaseServer.QueryToCommaText(TxnLogQuery);

  //extract reqd columns
  TotalPrice := 0;
  TotalValue := 0;
  TotalCommi := 0;
  TotalFee   := 0;
  ItemCount  := 0;
  //check for no postal orders
  SerialNo:='';
  Value   :='';
  if QueryStringList.CommaText <> '' then
  begin
    if not SummaryOnly then
       ResultList.Add('"'+RightPad('Serial No.',8,' ')+LeftPad( 'Value',14,' ')+LeftPad( 'Comm.',8,' ')+'","PYO"');
    For RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin
      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[3]:=IntToStr(Abs(Trunc(StrToCurr(RecordStringList[3]))));
      if not SummaryOnly then
         if Copy(RecordStringList[0],1,10) = 'Pay Office' then
         begin
           ResultList.Add('"'+RightPad(SerialNo,10,' ')+LeftPad(Value,14,' ')+LeftPad(Commission,8,' ')+'","'+Copy(RecordStringList[0],Length(RecordStringList[0])-10,3)+'"');
         end
         else if RecordStringList[0] = 'Commission' then
         begin
           Commission:=RecordStringList[3];
           Inc(TotalCommi, Trunc(StrToCurr(Commission)));
         end
         else if RecordStringList[0] = 'Fee' then
         begin
           Inc(ItemCount);
           Inc(TotalFee,Trunc(StrToCurr(RecordStringList[3])));
         end
         else  //face value
         begin
           TotalValue := TotalValue + StrToCurr(RecordStringList[3]);
           SerialNo:=RecordStringList[2];
           if Copy(SerialNo,1,1) = 'N' then
              SerialNo:=Trim(Copy(SerialNo,4,Length(SerialNo)));
           Value:=Trim(RecordStringList[3]);
         end;
      //update bottom totals
      TotalPrice := TotalPrice + StrToCurr(RecordStringList[3]);
    end;
    //add bottom totals
    if not SummaryOnly then
    begin
       AddLine(ResultList);
       ResultList.Add('"'+RightPad('Totals',10,' ')+LeftPad(CurrToStrF(TotalValue,ffNumber,NumberDecimals),14,' ')+LeftPad(CurrToStrF(TotalCommi,ffNumber,NumberDecimals),8,' ')+'",""');
       ResultList.Add('"Total Fees (2000/- x '+IntToStr(ItemCount)+')","'+IntToStr(TotalFee)+'"');
       ResultList.Add('"Grand Total","'+CurrToStrF(TotalPrice,ffNumber, NumberDecimals)+'"');
       AddLine(ResultList);
    end
    else
       ResultList.Add('"Money Fax Issue","' + CurrToStrF(TotalPrice,ffNumber,NumberDecimals) + '"');

  end;
  QueryStringList.Free;
  RecordStringList.Free;
end;

procedure FaxMoneyOrdersPaid( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean ) ;
var
  RecordIndex  : Integer;
  QueryStringList : TStringList;
  RecordStringList:TStringList;
  TxnLogQuery : String ;
  Value:String ;
  SerialNo:String ;
begin
  QueryStringList :=TStringList.Create;
  RecordStringList :=TStringList.Create;

  TxnLogQuery :=
  ' select Description, Price, Info, TxnValue, DateTime from TxnLog'
  + ' where (Description = ''Money Fax Pay'' or Prod = ''Issue Office'')'
  + ' and RecType = ''TxnLine'''
  + UserSearch( User )
  //start/end date converted to periods
  + ' and Period >= ' + StartPeriod
  + ' and Period <= ' +  EndPeriod
  + ' order by DateTime'
  ;
  QueryStringList.CommaText := DatabaseServer.QueryToCommaText(TxnLogQuery);

  //extract reqd columns
  TotalPrice := 0;
  //check for no postal orders
  if QueryStringList.CommaText <> '' then  //blank
  begin
    if not SummaryOnly then
       ResultList.Add('"'+RightPad('Serial No.',10,' ')+LeftPad( 'Value',22,' ')+'","ISO"');
    for RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin
      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[3]:=IntToStr(Abs(Trunc(StrToCurr(RecordStringList[3]))));
      if not SummaryOnly then
      begin
         if RecordStringList[0] = 'Money Fax Pay' then
         begin
            Value:=RecordStringList[1];
            SerialNo:=RecordStringList[2];
         end
         else
         begin
            ResultList.Add('"'+RightPad(SerialNo,10,' ')+LeftPad( Value,22,' ')+'","'+Copy(RecordStringList[0],Length(RecordStringList[0])-10,3)+'"');
         end;
      end;
      //update bottom totals
      TotalPrice := TotalPrice+ StrToCurrDef(RecordStringList[3],0);
    end;
    //add bottom totals
    if not SummaryOnly then
    begin
       AddLine(ResultList);
       ResultList.Add('"'+RightPad('Total',10,' ')+LeftPad(CurrToStrF(TotalPrice,ffNumber,NumberDecimals),22,' ')+'",""');
       AddLine(ResultList);
    end
    else
       ResultList.Add('"Money Fax Paid","' + CurrToStrF(TotalPrice,ffNumber,NumberDecimals) + '"');

  end;
  QueryStringList.Free;
  RecordStringList.Free;
end;

procedure MoneyOrdersIssued( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean ) ;
var
  Lines:TTransactionLines;
  RecordIndex : Integer;
  QueryStringList : TStringList;
  RecordStringList:TStringList;
  SerialNo  :String;
  Value     :String;
  Commission:String;
  TotalValue:Currency;
  TotalCommi:Currency;
begin

   QueryStringList :=TStringList.Create;
   RecordStringList :=TStringList.Create;
   Lines:=TTxnTranslate.TranslateQuery('',
                                          'select * from txnlog            '+
                                          'where                           '+
                                          '  Period >= ' + StartPeriod  + ' and ' +
                                          '  Period <= ' +  EndPeriod   +
                                             UserSearch( User )         + ' and ' +
                                          '  PLU = '+PLU_DomMoneyOrd    + ' and ' +
                                          '  RecType = ''TxnLine'' '
                                       );

   Lines.FieldsResult := 'PaymentOffice,SerialNumber,Commission';
   QueryStringList.CommaText := Lines.CommaText ;
   Lines.Free;
  //extract reqd columns
  TotalPrice := 0;
  TotalValue := 0;
  TotalCommi := 0;
  //check for no postal orders
  SerialNo:='';
  Value   :='';
  if QueryStringList.CommaText <> '' then
  begin
    if not SummaryOnly then
       ResultList.Add('"'+RightPad('Serial No.',8,' ')+LeftPad( 'Value',14,' ')+LeftPad( 'Comm.',8,' ')+'","PYO"');
    For RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin

      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[Const_FItemValue]:=CurrToStrF(Abs(StrToCurr(RecordStringList[Const_FItemValue])), ffNumber, NumberDecimals);

      Commission:=RecordStringList[Const_OffSetHead+3];
      TotalCommi := TotalCommi + StrToCurrDef(Commission,0);

      Value:=Trim(RecordStringList[Const_FItemValue]);
      TotalValue := TotalValue + StrToCurrDef( Value, 0 ); ;

      TotalPrice := TotalPrice + StrToCurrDef( Value, 0 ) + StrToCurrDef( Commission, 0 )  ; // Commission

      if not SummaryOnly then
      begin
         SerialNo:=RecordStringList[Const_OffSetHead+2];
         if Copy(SerialNo,1,1) = 'N' then SerialNo:=Trim(Copy(SerialNo,4,Length(SerialNo)));

         ResultList.Add('"'+RightPad(SerialNo,10,' ')+
                        LeftPad(Value,13,' ')+' '+
                        LeftPad(Commission,9,' ')+
                        '","'+Copy(RecordStringList[Const_OffSetHead+1],Length(RecordStringList[Const_OffSetHead+1])-5,5)+'"'); //update bottom totals
      end ;

    end;
    //add bottom totals
    if not SummaryOnly then
    begin
       AddLine(ResultList);

       ResultList.Add('"'+RightPad('Totals',10,' ')+
                          LeftPad(CurrToStrF(TotalValue, ffNumber, NumberDecimals),13,' ')+' '+
                          LeftPad(CurrToStrF(TotalCommi, ffNumber, NumberDecimals),9,' ')+'",""');
       ResultList.Add('"Grand Total","'+CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"'); //??
       AddLine(ResultList);
    end
    else
       ResultList.Add('"Money Order Issue","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');

  end;
  QueryStringList.Free;
  RecordStringList.Free;
end;

procedure MoneyOrdersPaid( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean ) ;
var
  Lines:TTransactionLines;
  RecordIndex : Integer;
  QueryStringList : TStringList;
  RecordStringList:TStringList;
begin

   QueryStringList :=TStringList.Create;
   RecordStringList :=TStringList.Create;
   Lines:=TTxnTranslate.TranslateQuery('',
                                          'select * from txnlog            '+
                                          'where                           '+
                                          '  Period >= ' + StartPeriod  + ' and ' +
                                          '  Period <= ' +  EndPeriod   +
                                             UserSearch( User )         + ' and ' +
                                          '  PLU = '+PLU_DomMoneyOrderPay +' and ' +
                                          '  RecType = ''TxnLine'' '
                                       );

   Lines.FieldsResult := 'SerialNumber,IssuingOfficed';
   QueryStringList.CommaText := Lines.CommaText ;
   Lines.Free;
  TotalPrice := 0;
  //check for no postal orders
  if QueryStringList.CommaText <> '' then  //blank
  begin
    if not SummaryOnly then
       ResultList.Add('"'+RightPad('Serial No.',10,' ')+LeftPad( 'Value',22,' ')+'","ISO"');
    for RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin
      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[Const_FItemValue]:=CurrToStrF(Abs(StrToCurr(RecordStringList[Const_FItemValue])), ffNumber, NumberDecimals);
      if not SummaryOnly then
         ResultList.Add('"'+
                           RightPad(RecordStringList[Const_OffSetHead+1],10,' ')+LeftPad( RecordStringList[Const_FItemValue],22,' ')+
                           '","'+
                           Copy(RecordStringList[Const_OffSetHead+2],Length(RecordStringList[Const_OffSetHead+2])-4,4)+'"');

      //update bottom totals
      TotalPrice := TotalPrice + StrToCurrDef(RecordStringList[Const_FItemValue], 0);
    end;
    //add bottom totals
    if not SummaryOnly then
    begin
       AddLine(ResultList);
       ResultList.Add('"'+RightPad('Total',10,' ')+LeftPad(RecordStringList[Const_FItemValue],22,' ')+'",""');
       AddLine(ResultList);
    end
    else
       ResultList.Add('"Money Order Paid","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');

  end;
  QueryStringList.Free;
  RecordStringList.Free;
end;

procedure InternationalSpeedCashIssued( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean ) ;
var
  Lines:TTransactionLines;
  RecordIndex : Integer;
  QueryStringList : TStringList;
  RecordStringList:TStringList;
begin

   QueryStringList :=TStringList.Create;
   RecordStringList :=TStringList.Create;
   Lines:=TTxnTranslate.TranslateQuery('',
                                          'select * from txnlog            '+
                                          'where                           '+
                                          '  Period >= ' + StartPeriod  + ' and ' +
                                          '  Period <= ' +  EndPeriod   +
                                             UserSearch( User )         + ' and ' +
                                          '  PLU = '+ PLU_IntMoneyOrder + ' and ' +
                                          '  RecType = ''TxnLine'' '
                                       );

   Lines.FieldsResult := 'MoneyOrderNumber,Commission';
   QueryStringList.CommaText := Lines.CommaText ;
   Lines.Free;

  TotalPrice := 0;
  //check for no postal orders

  if QueryStringList.CommaText = '' then  //blank
  begin
//      ResultList.Add('"None"," "');
  end
  else  //postal orders Issued
  begin
    For RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin
      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[Const_FItemValue]:=CurrToStrF(Abs(StrToCurr(RecordStringList[Const_FItemValue])), ffNumber, NumberDecimals);

      if not SummaryOnly then
      begin
         ResultList.Add('"'
                     + ' ' + RecordStringList[Const_OffSetHead+1] + '","'  //Serial Number
                     + RecordStringList[Const_FItemValue] + '"');       //Value
         ResultList.Add('"   Commission","'  + RecordStringList[Const_OffSetHead+2] + '"');
      end;

      //update bottom totals
      TotalPrice := TotalPrice + StrToCurrDef(RecordStringList[Const_FItemValue],   0) +
                                 StrToCurrDef(RecordStringList[Const_OffSetHead+2], 0) ;

    end;
    //add bottom totals
    if not SummaryOnly then
    begin
       AddLine(ResultList);
       ResultList.Add('"Total","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');
       AddLine(ResultList);
    end
    else
       ResultList.Add('"Foreign M/O Issued","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');

  end;
  QueryStringList.Free;
  RecordStringList.Free;
end;

procedure InternationalSpeedCashPaid( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean ) ;
var
  Lines:TTransactionLines;
  RecordIndex : Integer;
  QueryStringList : TStringList;
  RecordStringList:TStringList;
begin

   QueryStringList :=TStringList.Create;
   RecordStringList :=TStringList.Create;
   Lines:=TTxnTranslate.TranslateQuery('',
                                          'select * from txnlog            '+
                                          'where                           '+
                                          '  Period >= ' + StartPeriod  + ' and ' +
                                          '  Period <= ' +  EndPeriod   +
                                             UserSearch( User )         + ' and ' +
                                          '  PLU = '+PLU_IntMoneyOrderPaid + ' and ' +
                                          '  RecType = ''TxnLine'' '
                                       );

   Lines.FieldsResult := 'SerialNumber';
   QueryStringList.CommaText := Lines.CommaText ;
   Lines.Free;

  TotalPrice := 0;

    For RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin
      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[Const_FItemValue]:=CurrToStrF(Abs(StrToCurr(RecordStringList[Const_FItemValue])), ffNumber, NumberDecimals);
      if not SummaryOnly then
         ResultList.Add('"'
                 + ' '+ RecordStringList[Const_OffSetHead+1] + '","'  //Serial Number
                 + RecordStringList[Const_FItemValue] + '"');       //Value
      //update bottom totals

      TotalPrice := TotalPrice + StrToCurrDef(RecordStringList[Const_FItemValue], 0);

    end;

    //add bottom totals
    if QueryStringList.Count > 0 then
       if not SummaryOnly then
       begin
          AddLine(ResultList);
          ResultList.Add('"Total","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');
          AddLine(ResultList);
       end
       else
          ResultList.Add('"Foreign M/O Paid","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');

//  end;
  QueryStringList.Free;
  RecordStringList.Free;
end;

procedure PostbankWithdrawals( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean ) ;
var
  Lines:TTransactionLines;
  RecordIndex : Integer;
  QueryStringList : TStringList;
  RecordStringList:TStringList;
begin

   QueryStringList :=TStringList.Create;
   RecordStringList :=TStringList.Create;
   Lines:=TTxnTranslate.TranslateQuery('',
                                          'select * from txnlog            '+
                                          'where                           '+
                                          '  Period >= ' + StartPeriod  + ' and ' +
                                          '  Period <= ' +  EndPeriod   +
                                             UserSearch( User )         + ' and ' +
                                          '  PLU in ('+PLU_BankOrdWith+','+PLU_BankTrsWith+','+PLU_BankSpcWith+
                                          '     ) and ' +
                                          '  RecType = ''TxnLine'' '
                                       );

   Lines.FieldsResult := 'AccountNumber';
   QueryStringList.CommaText := Lines.CommaText ;
   Lines.Free;

  //extract reqd columns
  TotalPrice := 0;
  //check for no postal orders
  If QueryStringList.CommaText = '' then  //blank
  begin
//      ResultList.Add('"None"," "');
  end
  else  //postal orders Issued
  begin
    For RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin
      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[Const_FItemValue]:=CurrToStrF(Abs(StrToCurr(RecordStringList[Const_FItemValue])), ffNumber, NumberDecimals);
      if not SummaryOnly then
         ResultList.Add('"'
                 + ' '+ RecordStringList[Const_OffSetHead+1] + '","'  //Serial Number
                 + RecordStringList[Const_FItemValue] + '"');       //Value
      //update bottom totals
      TotalPrice := TotalPrice + StrToCurrDef(RecordStringList[Const_FItemValue], 0);
    end;
    //add bottom totals
    if not SummaryOnly then
    begin
       AddLine(ResultList);
       ResultList.Add('"Total","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');
       AddLine(ResultList);
    end
    else
       ResultList.Add('"Postbank Withdrawal","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');
  end;
  QueryStringList.Free;
  RecordStringList.Free;
end;

procedure PostbankDeposits( ResultList : TStringList; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean ) ;
var
   Lines:TTransactionLines;
   RecordIndex : Integer;
   QueryStringList : TStringList;
   RecordStringList:TStringList;
begin

   QueryStringList :=TStringList.Create;
   RecordStringList :=TStringList.Create;
   Lines:=TTxnTranslate.TranslateQuery('',
                                          'select * from txnlog            '+
                                          'where                           '+
                                          '  Period >= ' + StartPeriod  + ' and ' +
                                          '  Period <= ' +  EndPeriod   +
                                             UserSearch( User )         + ' and ' +
                                          '  PLU in ('+PLU_BankOrdDep+','+PLU_BankTrsDep+','+PLU_BankSpcDep+','+PLU_BankSAYEDep+
                                          '         ) and ' +
                                          '  RecType = ''TxnLine'' '
                                       );

   Lines.FieldsResult := 'AccountNumber';
   QueryStringList.CommaText := Lines.CommaText ;
   Lines.Free;

  TotalPrice := 0;
  //check for no postal orders
  If QueryStringList.CommaText = '' then  //blank
  begin
//      ResultList.Add('"None"," "');
  end
  else  //postal orders Issued
  begin
    For RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin
      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[Const_FItemValue]:=CurrToStrF(Abs(StrToCurr(RecordStringList[Const_FItemValue])), ffNumber, NumberDecimals);
      if not SummaryOnly then
         ResultList.Add('"'
                 + ' '+ RecordStringList[Const_OffSetHead+1] + '","'  //Serial Number
                 + RecordStringList[Const_FItemValue] + '"');       //Value
      //update bottom totals
      TotalPrice := TotalPrice + StrToCurrDef(RecordStringList[Const_FItemValue], 0);
    end;
    //add bottom totals
    if not SummaryOnly then
    begin
       AddLine(ResultList);
       ResultList.Add('"Total","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');
       AddLine(ResultList);
    end
    else
       ResultList.Add('"Postbank Deposit","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');

  end;
  QueryStringList.Free;
  RecordStringList.Free;
end;

procedure AddA4Line( ResultList : TStringList;  NumberOfColumns : Integer );
var
  i : Integer;
begin
  with TStringList.Create do
  begin
    for i:= 0 to NumberOfColumns-1 do
      Add('__________________________________________________________________________________________');
    ResultList.Add(CommaText);
    Free;
  end;
end;

procedure AddSolidLine( ResultList : TStringList );
begin
  ResultList.Add('" "," "," "," "," ","__________________________________________"');
end;

procedure BlankLine( ResultList : TStringList );
begin
  ResultList.Add('" "," "');
end;

procedure AddLine( ResultList : TStringList );
begin
  ResultList.Add('"_______________________","_______________________"');
end;

function RightPad(S:String;Len:Integer;PadChar:Char):String;
var
  I:Integer;
  PadStr:String;
begin
  PadStr:='';
  for I:=Length(S) to Len do
     PadStr:=PadStr+PadChar;
  Result:=Copy(S,1,Len)+PadStr;
end;
function LeftPad(S:String;Len:Integer;PadChar:Char):String;
var
  I:Integer;
  PadStr:String;
begin
  PadStr:='';
  for I:=Length(S) to Len do
     PadStr:=PadStr+PadChar;
  Result:=PadStr+Copy(S,1,Len);
end;

procedure Centre(CentreString : String ; ResultList : TStringList );
var
   CS:String;
   Ofs,I:Integer;
begin
  CS:='';
  Ofs:=(44-Length(CentreString)) div 2;
  for I:=1 to 44 do CS:=CS+' ';
  for I:=1 to Length(CentreString) do CS[I+Ofs]:=CentreString[I];

  ResultList.Add('"' + CentreString + '"," "');
//  ResultList.Add('"' + StringUtil.Centre(CentreString,44,' ') + '"," "');
end;

function ToDaysPeriod:Integer;
begin
   Result:=Trunc(Date)-DaysUntil_010198;
end;

function StrToPeriod(DateS:String):String;
var
   PDate:TDateTime;
   Y:Word;
   M:Word;
   D:Word;
begin
   D:=StrToIntDef(Copy(DateS,1,2),1);
   M:=StrToIntDef(Copy(DateS,4,2),1);
   Y:=StrToIntDef(Copy(DateS,7,2),98);
   if Y < 80 then Inc(Y,100);
   Inc(Y,1900);
   PDate:=EncodeDate(Y,M,D);
   Result:=IntToStr(Trunc(PDate)-DaysUntil_010198);
end;

function MFReportData( StartDomainText, EndDomainText, User, Office : String; SummaryOnly : Boolean ) : string;
var
  A,B:Integer;
  ResultList : TStringList ;
  DatabaseServer : IDataBaseServerAuto ;
  StartPeriod, EndPeriod : String;
  StartDateString,EndDateString : String;
  TotalPrice:Real;
begin

  Result := '' ;
  A:= 0;

  try
    //database server
    DatabaseServer:= CoDatabaseServerAuto.CreateRemote(GetGPCSRegString('','Transaction ServerName',GetLocalMachineName));
    ResultList := TStringList.Create;

    try
      DatabaseServer.DataAlias := 'PSL';

      //insert '/' into dates
      StartPeriod:=StrToPeriod(StartDomainText);
      EndPeriod  :=StrToPeriod(EndDomainText);
      StartDateString := Copy(StartDomainText,1,2) + '/'
                          + Copy(StartDomainText,4,2) + '/'
                          + Copy(StartDomainText,7,2);
      EndDateString   := Copy(EndDomainText,1,2) + '/'
                          + Copy(EndDomainText,4,2) + '/'
                          + Copy(EndDomainText,7,2);


      //headers
      BlankLine( ResultList );
      if SummaryOnly then
         Centre('Money Fax Summary', ResultList )
      else
         Centre('Money Fax', ResultList );

      AddLine(ResultList);
      ResultList.Add('"Teller","'+User+'"');
      ResultList.Add('"Office","'+Office+'"');
      ResultList.Add('"Dates"," ' + StartDateString + ' to ' + EndDateString + '"');
      AddLine(ResultList);

      BlankLine( ResultList );
      Centre('Receipts', ResultList );
      B:=ResultList.Count;

      //Fax money orders Issued
      if not SummaryOnly then
      begin
         BlankLine( ResultList );
         Centre('Money Fax Issued', ResultList );
         BlankLine( ResultList );
         A:=ResultList.Count;
      end ;
      FaxMoneyOrdersIssued( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      if not SummaryOnly then
         if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      if B = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;
      BlankLine( ResultList );
      Centre('Payments', ResultList );
      B:=ResultList.Count;

      //Fax money orders paid
      if not SummaryOnly then
      begin
         BlankLine( ResultList );
         Centre('Money Fax Paid', ResultList );
         BlankLine( ResultList );
         A:=ResultList.Count;
      end ;
      FaxMoneyOrdersPaid( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      if not SummaryOnly then
         if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      if B = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

    finally
      Result := ResultList.CommaText ;
      ResultList.Free;
      DatabaseServer := nil;
      //TerminateExecute(TxnLog);
    end;
  except
    On  E:Exception do
      RaiseException($401,E);
  end;

end;
function MOReportData( StartDomainText, EndDomainText, User, Office : String; SummaryOnly : Boolean ) : string;
var
  A,B:Integer;
  ResultList : TStringList ;
  DatabaseServer : IDataBaseServerAuto ;
  StartPeriod, EndPeriod : String;
  StartDateString,EndDateString : String;
  TotalPrice:Real;
begin

  Result := '' ;
  A:= 0;

  try
    //database server
    DatabaseServer:= CoDatabaseServerAuto.CreateRemote(GetGPCSRegString('','Transaction ServerName',GetLocalMachineName));
    ResultList := TStringList.Create;

    try
      DatabaseServer.DataAlias := 'PSL';

      //insert '/' into dates
      StartPeriod:=StrToPeriod(StartDomainText);
      EndPeriod  :=StrToPeriod(EndDomainText);
      StartDateString := Copy(StartDomainText,1,2) + '/'
                          + Copy(StartDomainText,4,2) + '/'
                          + Copy(StartDomainText,7,2);
      EndDateString   := Copy(EndDomainText,1,2) + '/'
                          + Copy(EndDomainText,4,2) + '/'
                          + Copy(EndDomainText,7,2);


      //headers
      BlankLine( ResultList );
      if SummaryOnly then
         Centre('Money Order Summary', ResultList )
      else
         Centre('Money Orders', ResultList );

      AddLine(ResultList);
      ResultList.Add('"Teller","'+User+'"');
      ResultList.Add('"Office","'+Office+'"');
      ResultList.Add('"Dates"," ' + StartDateString + ' to ' + EndDateString + '"');
      AddLine(ResultList);

      BlankLine( ResultList );
      Centre('Receipts', ResultList );
      B:=ResultList.Count;

      //Fax money orders Issued
      if not SummaryOnly then
      begin
         BlankLine( ResultList );
         Centre('Money Orders Issued', ResultList );
         BlankLine( ResultList );
         A:=ResultList.Count;
      end ;
      MoneyOrdersIssued( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      if not SummaryOnly then
         if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      if not SummaryOnly then
      begin
         BlankLine( ResultList );
         Centre('Service Money Orders Issued', ResultList );
         BlankLine( ResultList );
         A:=ResultList.Count;
      end ;
      ServiceMoneyOrdersIssued( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      if not SummaryOnly then
         if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      if B = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;
      BlankLine( ResultList );
      Centre('Payments', ResultList );
      B:=ResultList.Count;

      //Fax money orders paid
      if not SummaryOnly then
      begin
         BlankLine( ResultList );
         Centre('Money Orders Paid', ResultList );
         BlankLine( ResultList );
         A:=ResultList.Count;
      end ;
      MoneyOrdersPaid( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      if not SummaryOnly then
         if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      if B = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

    finally
      Result := ResultList.CommaText ;
      ResultList.Free;
      DatabaseServer := nil;
      //TerminateExecute(TxnLog);
    end;
  except
    On  E:Exception do
      RaiseException($401,E);
  end;

end;
function EMSReportData( StartDomainText, EndDomainText, User, Office : String; SummaryOnly : Boolean ) : string;
var
  A:Integer;
  ResultList : TStringList ;
  DatabaseServer : IDataBaseServerAuto ;
  StartPeriod, EndPeriod : String;
  StartDateString,EndDateString : String;
  TotalPrice:Real;
begin
  Result := '' ;
  A:= 0;
  try
    //database server
    DatabaseServer:= CoDatabaseServerAuto.CreateRemote(GetGPCSRegString('','Transaction ServerName',GetLocalMachineName));
    ResultList := TStringList.Create;
    try
      DatabaseServer.DataAlias := 'PSL';
      //insert '/' into dates
      StartPeriod:=StrToPeriod(StartDomainText);
      EndPeriod  :=StrToPeriod(EndDomainText);
      StartDateString:= Copy(StartDomainText,1,2)+'/'
                      + Copy(StartDomainText,4,2)+'/'
                      + Copy(StartDomainText,7,2);
      EndDateString  := Copy(EndDomainText,1,2)+'/'
                      + Copy(EndDomainText,4,2)+'/'
                      + Copy(EndDomainText,7,2);
      //headers
      BlankLine( ResultList );
      if SummaryOnly then
         Centre('EMS Summary', ResultList )
      else
         Centre('EMS', ResultList );

      AddLine(ResultList);
      ResultList.Add('"Teller","'+User+'"');
      ResultList.Add('"Office","'+Office+'"');
      ResultList.Add('"Dates"," ' + StartDateString + ' to ' + EndDateString + '"');
      AddLine(ResultList);

      //Fax money orders Issued
      if not SummaryOnly then
      begin
         BlankLine( ResultList );
         Centre('Domesic EMS', ResultList );
         BlankLine( ResultList );
         A:=ResultList.Count;
      end ;
      DomesticEMS( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      if not SummaryOnly then
         if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      if not SummaryOnly then
      begin
         BlankLine( ResultList );
         Centre('Int. EMS Documents', ResultList );
         BlankLine( ResultList );
         A:=ResultList.Count;
      end ;
      IntEMSDocuments( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      if not SummaryOnly then
         if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

      if not SummaryOnly then
      begin
         BlankLine( ResultList );
         Centre('Int. EMS Parcels', ResultList );
         BlankLine( ResultList );
         A:=ResultList.Count;
      end ;
      IntEMSParcels( ResultList, DataBaseServer,TotalPrice, StartPeriod, EndPeriod, User, SummaryOnly );
      if not SummaryOnly then
         if A = ResultList.Count then begin ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); ResultList.Delete(ResultList.Count-1); end;

    finally
      Result := ResultList.CommaText ;
      ResultList.Free;
      DatabaseServer := nil;
      //TerminateExecute(TxnLog);
    end;
  except
    On  E:Exception do
      RaiseException($401,E);
  end;

end;
procedure A4ReportPrint(User, Office, ReportTitle, ColumnHeaders, TotalLine, ColumnWidths : String; ReportLines : String);
var
  ReportHeader,
  ReportLinesSL    : TStringList;
  ReportPrint      : TReportPreviewForm;
  i, ColumnCount,
  TotalColumnWidth : Integer;
begin
  ReportHeader   := TStringList.Create;
  ReportLinesSL  := TStringList.Create;
  ReportLinesSL.CommaText := ReportLines;

  ReportPrint := TReportPreviewForm.Create(nil);
  with TStringList.Create do
  begin
    CommaText := ColumnWidths;
    ColumnCount:=Count;
    TotalColumnWidth := 0;
    for i:=0 to Count-1 do
      TotalColumnWidth := TotalColumnWidth + abs(StrToInt(Strings[i]));
    Free;
  end;

  // Header Info
  ReportPrint.OfficeNumber:=Office;
  ReportPrint.OfficeName := GetGPCSRegString('OfficeInfo', 'Office Name', '');
  if User = '' then
    ReportPrint.User:='All'
  else
    ReportPrint.User:=User;
  BlankLine(ReportHeader);
  AddA4Line(ReportHeader, ColumnCount);
  BlankLine(ReportHeader);
  ReportHeader.Add(ReportTitle);
  AddA4Line(ReportHeader, ColumnCount);
  ReportHeader.Add(ColumnHeaders);
  BlankLine(ReportHeader);

  // Totals
  if TotalLine <> '' then
  begin
    AddA4Line(ReportLinesSL, ColumnCount);
    BlankLine(ReportLinesSL);
    ReportLinesSL.Add(TotalLine);
    AddA4Line(ReportLinesSL, ColumnCount);
  end;

  // Print A4 Report
  ReportPrint.PrintReportStandard(IntToStr(TotalColumnWidth),ColumnWidths, ReportHeader.CommaText + ',' + ReportLinesSL.CommaText);
  ReportHeader.Free;
  ReportLinesSL.Free;
  ReportPrint.FormDestroy(nil);
end;
function ReceiptReportLines(User, Office, StartDate, EndDate, ReportTitle, ColumnHeaders, TotalLine : String;
                               ReportLines : String) : String;
var
  ReportHeader,
  ReportLinesSL     : TStringList;

begin
  ReportHeader   := TStringList.Create;
  ReportLinesSL   := TStringList.Create;
  ReportLinesSL.CommaText := ReportLines;

  ReportHeader.Add('"<' + ReportTitle + '"," "," "');
  AddSolidLine(ReportHeader);
  BlankLine(ReportHeader);
  if User <> '' then
    ReportHeader.Add('"<Teller : ","' + User + '"');
  if Office <> '' then
    ReportHeader.Add('"<Office : ","' + Office + '"');
  if (StartDate <> '') and (EndDate <> '') then
    ReportHeader.Add('"<Dates  : ","' + StartDate + ' to ' + EndDate + '"')
  else if StartDate <> '' then
    ReportHeader.Add('"<Date   : ","' + StartDate + '"');
  AddSolidLine(ReportHeader);
  ReportHeader.Add(ColumnHeaders);
  BlankLine(ReportHeader);

  // Totals
  if TotalLine <> '' then
  begin
    AddSolidLine(ReportLinesSL);
    BlankLine(ReportLinesSL);
    ReportLinesSL.Add(TotalLine);
    AddSolidLine(ReportLinesSL);
  end;
  
  Result :=  ReportHeader.CommaText + ',' + ReportLinesSL.CommaText;
  ReportHeader.Free;
  ReportLinesSL.Free;
end;

procedure DomesticEMS( ResultList : TStringList ; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );
var
  RecordIndex  : Integer;
  QueryStringList : TStringList;
  RecordStringList:TStringList;
  TxnLogQuery : String ;
  SerialNo  :String;
  Value     :String;
  Commission:String;
  TotalValue:Real;
  TotalCommi:Integer;
begin
  QueryStringList :=TStringList.Create;
  RecordStringList :=TStringList.Create;

  TxnLogQuery :=
  ' select Description, Price, Info, TxnValue ,DateTime, RecordID from TxnLog'
  + ' where (Prod = ''Product.DomEMS'' or Prod = ''DomEMSID'' or Prod = ''DomEMSVAT'')'
  + ' and RecType = ''TxnLine'''
  + UserSearch( User )
  + ' and Period >= ' + StartPeriod
  + ' and Period <= ' +  EndPeriod
  + ' order by DateTime, RecordID'
  ;
  QueryStringList.CommaText := DatabaseServer.QueryToCommaText(TxnLogQuery);

  //extract reqd columns
  TotalPrice := 0;
  TotalValue := 0;
  TotalCommi := 0;
  //check for no postal orders
  SerialNo:='';
  Value   :='';
  if QueryStringList.CommaText <> '' then
  begin
    For RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin
      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[3]:=IntToStr(Abs(StrToInt(RecordStringList[3])));
      if not SummaryOnly then
         if Copy(RecordStringList[0],1,2) = 'ID' then
         begin
           SerialNo:=RecordStringList[2];
           ResultList.Add('"'+SerialNo+'","'+Value+'"');
         end
         else if Copy(RecordStringList[0],1,3) = 'VAT' then
         begin
           Commission:=RecordStringList[3];
           Inc(TotalCommi, StrToInt(Commission));
         end
         else
         begin
           TotalValue := TotalValue + StrToCurrDef(RecordStringList[3],0);
           Value:=Trim(RecordStringList[3]);
         end;
      //update bottom totals
      TotalPrice := TotalPrice + StrToCurrDef(RecordStringList[3],0);
    end;
    //add bottom totals
    if not SummaryOnly then
    begin
       AddLine(ResultList);
       ResultList.Add('"Total","'+CurrToStrF(TotalValue, ffNumber, NumberDecimals)+'"');
       ResultList.Add('"Total VAT","'+CurrToStrF(TotalCommi,ffNumber, NumberDecimals)+'"');
       ResultList.Add('"Grand Total","'+CurrToStrF(TotalPrice,ffNumber, NumberDecimals)+'"');
       AddLine(ResultList);
    end
    else
       ResultList.Add('"Inland EMS","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals ) + '"');

  end;
  QueryStringList.Free;
  RecordStringList.Free;
end;
procedure IntEMSDocuments( ResultList : TStringList ; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );
var
  RecordIndex  : Integer;
  QueryStringList : TStringList;
  RecordStringList:TStringList;
  TxnLogQuery : String ;
  SerialNo  :String;
  Value     :String;
  Destination:String;
begin
  QueryStringList :=TStringList.Create;
  RecordStringList :=TStringList.Create;

  TxnLogQuery :=
  ' select Description, Price, Info, TxnValue ,DateTime, RecordID from TxnLog'
  + ' where (Prod = ''Product.IntEMSDoc'' or Prod = ''IntEMSDocDest'' or Prod = ''IntEMSDocID'')'
  + ' and RecType = ''TxnLine'''
  + UserSearch( User )
  + ' and Period >= ' + StartPeriod
  + ' and Period <= ' +  EndPeriod
  + ' order by DateTime, RecordID'
  ;
  QueryStringList.CommaText := DatabaseServer.QueryToCommaText(TxnLogQuery);

  //extract reqd columns
  TotalPrice := 0;
  //check for no postal orders
  SerialNo:='';
  Value   :='';
  if QueryStringList.CommaText <> '' then
  begin
    For RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin
      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[3]:=IntToStr(Abs(StrToInt(RecordStringList[3])));
      if not SummaryOnly then
         if Copy(RecordStringList[0],1,2) = 'ID' then
         begin
           SerialNo:=RecordStringList[2];
           if Length(SerialNo) > 13 then
           begin
              ResultList.Add('"'+SerialNo+'",""');
              ResultList.Add('" > '+Destination+'","'+Value+'"');
           end
           else
              ResultList.Add('"'+SerialNo+' > '+Destination+'","'+Value+'"');
         end
         else if Copy(RecordStringList[0],1,3) = 'To' then
         begin
           Destination:=RecordStringList[2];
         end
         else
         begin
           Value:=Trim(RecordStringList[3]);
         end;
      //update bottom totals
      TotalPrice := TotalPrice + StrToCurrDef(RecordStringList[3],0);
    end;
    //add bottom totals
    if not SummaryOnly then
    begin
       AddLine(ResultList);
       ResultList.Add('"Total","'+CurrToStrF(TotalPrice,ffNumber, NumberDecimals)+'"');
       AddLine(ResultList);
    end
    else
       ResultList.Add('"Int. EMS Documents","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');

  end;
  QueryStringList.Free;
  RecordStringList.Free;
end;
procedure IntEMSParcels( ResultList : TStringList ; DataBaseServer:IDataBaseServerAuto;var TotalPrice:Real; StartPeriod, EndPeriod, User : String; SummaryOnly : Boolean );
var
  RecordIndex  : Integer;
  QueryStringList : TStringList;
  RecordStringList:TStringList;
  TxnLogQuery : String ;
  SerialNo  :String;
  Value     :String;
  Destination:String;
begin
  QueryStringList :=TStringList.Create;
  RecordStringList :=TStringList.Create;

  TxnLogQuery :=
  ' select Description, Price, Info, TxnValue ,DateTime, RecordID from TxnLog'
  + ' where (Prod = ''Product.IntEMSPar'' or Prod = ''IntEMSParDest'' or Prod = ''IntEMSParID'')'
  + ' and RecType = ''TxnLine'''
  + UserSearch( User )
  + ' and Period >= ' + StartPeriod
  + ' and Period <= ' +  EndPeriod
  + ' order by DateTime, RecordID'
  ;
  QueryStringList.CommaText := DatabaseServer.QueryToCommaText(TxnLogQuery);

  //extract reqd columns
  TotalPrice := 0;
  //check for no postal orders
  SerialNo:='';
  Value   :='';
  if QueryStringList.CommaText <> '' then
  begin
    For RecordIndex := 0 to (QueryStringList.Count - 1) do
    begin
      RecordStringList.CommaText := QueryStringLIst[RecordIndex];
      RecordStringList[3]:=IntToStr(Abs(StrToInt(RecordStringList[3])));
      if not SummaryOnly then
         if Copy(RecordStringList[0],1,2) = 'ID' then
         begin
           SerialNo:=RecordStringList[2];
           if Length(SerialNo) > 13 then
           begin
              ResultList.Add('"'+SerialNo+'",""');
              ResultList.Add('" > '+Destination+'","'+Value+'"');
           end
           else
              ResultList.Add('"'+SerialNo+' > '+Destination+'","'+Value+'"');
         end
         else if Copy(RecordStringList[0],1,3) = 'To' then
         begin
           Destination:=RecordStringList[2];
         end
         else
         begin
           Value:=Trim(RecordStringList[3]);
         end;
      //update bottom totals
      TotalPrice := TotalPrice + StrToCurrDef(RecordStringList[3],0);
    end;
    //add bottom totals
    if not SummaryOnly then
    begin
       AddLine(ResultList);
       ResultList.Add('"Total","'+CurrToStrF(TotalPrice, ffNumber, NumberDecimals)+'"');
       AddLine(ResultList);
    end
    else
       ResultList.Add('"Int. EMS Parcels","' + CurrToStrF(TotalPrice, ffNumber, NumberDecimals) + '"');

  end;
  QueryStringList.Free;
  RecordStringList.Free;
end;


end.
