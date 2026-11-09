unit TranProcessU;

interface

uses
  QueryMapU,
    Windows,Messages,Classes,Forms,SysUtils,Db,DBTables,
    MOSupportU,MODefinitionsU,CustomerListU,PackStrListU,
    GPCSErrorLine,GPCSGUID,GPCSBase_TLB,UDPMessageU,TxnTxU,UIDllSupportU,I3UIParseU;//,ShareDataU;

const
   AliasName = 'PSL';
   TableName = 'TXNLOG';
   WM_WRITENOW = WM_USER+5;

type
  TBlockPos = (bpFirst,bpMiddle,bpLast);
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
  TTxnProcessor = class(TObject)
  private
     Txnlog:ITransactionLog;
     Stock:IStock;
     PSLDatabase:TDatabase;
     WindowHandle:THandle;
  public
     StatsList:TPackStringList;
     TxnList:TPackStringList;
     TxnLogTable:TTable;
     TransmitData:TTransmitData;
     constructor Create;
     destructor Destroy; override;
     procedure WndProc(var Message: TMessage);
     procedure WMWriteNow(var Msg:TMessage); message WM_WRITENOW;
     procedure AddRecord(Data: String;FirstLastMid:TBlockPos);
     procedure ReceiveMessage(Data:String);
     procedure WriteTransactions(PackText:String);
     procedure CheckTxns(Sender:TObject);
     procedure CheckTxnList;
  end;                

          
implementation

{TTxnProcessor}
constructor TTxnProcessor.Create;
begin
   inherited Create;
   
   WindowHandle:=AllocateHWnd(WndProc);
   
   TxnList:=TPackStringList.Create;
   StatsList:=TPackStringList.Create;
      
   PSLDatabase:=TDatabase.Create(nil);
   PSLDatabase.AliasName   :=AliasName;
   PSLDatabase.DatabaseName:=AliasName;
   PSLDatabase.LoginPrompt :=False;
   PSLDatabase.SessionName :='Default';
   
   TxnLogTable:=TTable.Create(nil);
   TxnLogTable.DatabaseName:=AliasName;
   TxnLogTable.TableName   :=TableName;
   
   if GetGPCSRegString('WorkStation','DBType','Paradox') <> 'Paradox' then
      TxnLogTable.IndexName:='TXNLOG_PINDEX';
      
   if GetGPCSRegString('WorkStation','DBType','Paradox') = 'SQLServer' then
      TxnLogTable.TableName   :='dbo.TXNLOG';
                                                                          
   PSLDataBase.Params.Add('USER NAME='+GetGPCSRegString('','UserName','psl'   ));
   PSLDataBase.Params.Add('PASSWORD=' +GetGPCSRegString('','Password','suvroc'));
   
   TransmitData:=TTransmitData.Create(MaxRecordTxRecords);
   TransmitData.OnMessage:=ReceiveMessage;
end;
destructor TTxnProcessor.Destroy;
begin
   GetUserNumber('*DestroyList');
   Txnlog:=nil;
   Stock:=nil;
   TransmitData.OnMessage:=nil;
   TransmitData.Free;
   TxnLogTable.Free;
   PSLDatabase.Free;
   TxnList.Free;
   StatsList.Free;
   DeAllocateHWnd(WindowHandle);
   inherited Destroy;
end;
procedure TTxnProcessor.WndProc(var Message: TMessage);
begin
  try             
    Dispatch(Message);
  except
      on E:Exception do RaiseException(8,E);
  end;
end;
procedure TTxnProcessor.AddRecord(Data: String;FirstLastMid:TBlockPos);
var
   SL:TPackStringList;
   SLExtra:TStringList;
   Description:String;
   Teller:String;
   Ident:String;
   Quantity:Integer;
   TxnType:String;
   PLU:Integer;
   Idx:Integer;
   Price:Currency;
   ProgID:String;
   Additional:String;
   DomInfo:String;
   Office:String;
   Value:Currency;
   MoneyOrder:TMoneyOrder;
   J:Integer;
   TxnDomInfoLines:TTxnDomInfoLines;
   I3UINode:TI3UINode;
   MOEvent:TMOEvent;
   MOFee:TMOFee;
   MODetail:TMODetail;
begin
   try
      if Txnlog = nil then
         Txnlog:=CreateTransactionLog;
      if Stock = nil then
         Stock:=CreateStock;
      if FirstLastMid = bpFirst then
         Stock.TransferStock('BlockUpdateStart','');
      SL:=TPackStringList.Create;
      SL.PackText:=Data;
      if SL.Count > 15 then
      begin
         { 0=RecordID  1=WSNumber     2=DateTime   3=TxnType
           4=Period    5=Index        6=Offcie     7=Teller
           8=PLU       9=Prod        10=Price     11=Quantity
          12=Value    13=Description 14=Info      15=Ident    16=DomInfo }
         Teller     :=SL[ 7];
         Quantity   :=StrToIntDef(SL[11],0);
         Description:=SL[13];
         Ident      :=SL[15];
         TxnType    :=SL[ 3];

         // update stats list box
         Idx:=StatsList.IndexOf(TxnType);
         if Idx = -1 then
            StatsList.AddObject(TxnType,TObject(1))
         else
            StatsList.Objects[Idx]:=TObject(Integer(StatsList.Objects[Idx])+1);

         PLU        :=StrToIntDef(SL[8],0);
         Price      :=StrToCurrDef(SL[10],0);
         ProgID     :=SL[9];
         Additional :=SL[14];
         Office     :=SL[6];
         Value      :=StrToCurrDef(SL[12],0);
         if SL.Count > 16 then
            DomInfo    :=SL[16];

         if Pos(TxnType,'TxStkTo TxStkFrom StockUsed StockSet NewStock DelStock') > 0 then
         begin
            if Stock <> nil then
            begin
               if TxnType = 'TxStkTo' then
               begin
                  Stock.AdjustStockLevel(Teller,Description,0-Quantity);
                  if Teller <> ident then
                     Stock.AdjustStockLevel(Ident,Description,Quantity);
               end
               else if TxnType = 'TxStkFrom' then
               begin
                  Stock.AdjustStockLevel(Ident,Description,0-Quantity);
                  if Teller <> ident then
                     Stock.AdjustStockLevel(Teller,Description,Quantity);
               end
               else if TxnType = 'StockUsed' then
               begin
                  Stock.AdjustStockLevel(Teller,Description,0-Quantity);
               end
               else if TxnType = 'SupStkUsd' then  // Supervisor Stock Used
               begin
                  Stock.AdjustStockLevel('Supervisor',Description,0-Quantity);
               end
               else if TxnType = 'StockSet' then
               begin
                  Stock.SetStockLevel(Teller,Description,Quantity);
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
                  Stock.DeleteStockItem(Description);
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
         else if TxnType = 'StockReset' then // Reset All Stock Transfers
         begin
            QueryToPackText('UPDATE TXNLOG SET RecType = ''OStockTx'' WHERE RecType = ''StockTx''');
         end
         else if TxnType = 'ListUpdt' then
         begin
            UpdateLocalList(Description,Additional,ProgID);
         end
         else if TxnType = 'CustQuery' then
         begin
            if GetGPCSRegString('Customers','LocalDatabase','0') = '1' then
            begin
               Txnlog.WriteTransaction('*CustRes',0,0,0,0,0,Description,Additional,'',QueryToPackText(DomInfo));
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
                     I3UINode:=CreateI3UINode('');
                     if Assigned(I3UINode) then
                     begin
                        MoneyOrder.Position.NextOffice:=FindNextOffice(I3UINode, MoneyOrder.Position.CurrentOffice, MoneyOrder.PayOffice);
                        I3UINode.Free;
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

                     TxnDomInfoLines:=TTxnDomInfoLines.Create;
                     TxnDomInfoLines.AddFromPackText(DomInfo);
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
         end;
      end                        
      else
      begin
         // update stats list box with error 'Short Data'
         Idx:=StatsList.IndexOf('Short Data');
         if Idx = -1 then
            StatsList.AddObject('Short Data',TObject(1))
         else
            StatsList.Objects[Idx]:=TObject(Integer(StatsList.Objects[Idx])+1);
      end;
      SL.Free;
      if FirstLastMid = bpLast then
         Stock.TransferStock('BlockUpdateEnd','');
   except
      On E : Exception do
        RaiseGUIDException('{CA872063-A3FD-4C85-BB2F-03E9C55AFEBD}', E);
   end;
end;

procedure TTxnProcessor.ReceiveMessage(Data:String);
var
   RecordsSL  : TPackStringList;
   RecordSL   : TPackStringList;
   RecordIndex, FieldIndex : Integer;
   DT:TDateTime;
   Code:Integer;
   RecID,WSNo,Period:Integer;
begin
   try

      RecordsSL          :=  TPackStringList.Create; //for all packed records
      RecordSL           :=  TPackStringList.Create; //for a single packed record
      try
        RecordsSL.PackText :=  Data;                   //grab all packed records
        if not TxnLogTable.Active then
          TxnLogTable.Active:=True;

        //go through all records received
        for RecordIndex:=0 to RecordsSL.Count-1 do
        begin
          RecordSL.PackText := RecordsSL[RecordIndex];  //grab each packed record
                    
          //extract record key fields
          RecID:=StrToIntDef(RecordSL[0],-1);
          WSNo :=StrToIntDef(RecordSL[1],-1);
          Period :=StrToIntDef(RecordSL[4],-1);

//          only write recs in period range
          if Period >= TxnTxU.LastPeriod then
          begin
//            try to find record
            if not TxnLogTable.FindKey([RecID,WSNo]) then
            begin
              //add the record
              TxnLogTable.Append;
              for FieldIndex:=0 to RecordSL.Count-1 do
              begin
                // Each machine may have different Date & Time format settings
                // so transmitted as TDateTime not String.
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
              //call event
              if RecordIndex = RecordsSL.Count-1 then
                 AddRecord(RecordsSL[RecordIndex],bpLast)
              else if RecordIndex = 0 then
                 AddRecord(RecordsSL[RecordIndex],bpFirst)
              else
                AddRecord(RecordsSL[RecordIndex],bpMiddle);
              //update bitmap
              TransmitData.RecordAdded(WSNo,RecId);
            end;
          end
          else
          begin
             // mark as received so we don't request it again
             TransmitData.RecordAdded(WSNo,RecId);
          end;  //if in period range
        end;  //for all records
//        If DebugMode > 0 then Windows.Beep(400,500);
      finally
        TxnLogTable.Active:=False;
        RecordSL.Free;
        RecordsSL.Free;
      end;

      try
     // force the AutoSave Flag Back On
      if Stock <> nil then
         Stock.TransferStock('BlockUpdateEnd','');
      except
      on E: Exception do
        GPCSErrorline.RaiseGUIDException('{404D9912-3ED4-4DE1-AFB8-71054C373582}',E);
      end;

   except
      On E : Exception do
        RaiseGUIDException('{92B9ACCC-2D4D-4D0D-A04B-88496BAEB83D} ' + RecordSL.PackText, E);
   end;
end;
procedure TTxnProcessor.WriteTransactions(PackText:String);
begin
   TxnList.Add(PackText);
   PostMessage(WindowHandle,WM_WRITENOW,0,0);
end;

procedure TTxnProcessor.WMWriteNow(var Msg:TMessage);
begin
   CheckTxnList;
end;

procedure TTxnProcessor.CheckTxnList;
var
  NextRecId : Integer;
  SL        : TPackStringList;
  FSL       : TPackStringList;
  I         : Integer;
  TryCount  : Integer;
const
  MaxTries : Integer = 10;
   Incheck:Boolean = False;
begin
  if Incheck then Exit;
  if TxnList.Count = 0 then Exit;
  Incheck:=True;
  try
    if not TxnlogTable.Active then
      TxnlogTable.Active:=True;
    FSL :=  TPackStringList.Create;
    SL  :=  TPackStringList.Create;
    try
      NextRecId := TransmitData.NextFreeRecordID;
    except
      On E : Exception do
      begin
        NextRecId := StrToInt(AliasQueryToCommaText('PSL', 'Select Max(RecordId) from Txnlog where WSNumber = ' + GetGPCSRegString('Workstation','Ident','')));
        RaiseGUIDException('{EDF58FC9-B84E-4642-924A-13A16F52EE3E}', E);
      end;
    end;

    //process all txns
    while (TxnList.Count > 0) do
    begin
      FSL.PackText:=TxnList[0]; //grab first txn batch
      try
        for I:=0 to FSL.Count-1 do  //unpack
        begin
          TryCount :=0;
          While TryCount < MaxTries do
          begin
            try
              SL.PackText:=FSL[I];
              TxnlogTable.Append;
              TxnlogTable.FieldByName('RECORDID')   .value  := NextRecId;
              TxnlogTable.FieldByName('WSNUMBER')   .value  := StrToInt (SL[ 0]);
              TxnlogTable.FieldByName('DATETIME')   .value  := Now;
              TxnlogTable.FieldByName('PERIOD')     .value  := StrToInt (SL[ 1]);
              TxnlogTable.FieldByName('RECTYPE')    .value  :=           SL[ 2] ;
              TxnlogTable.FieldByName('OFFICE')     .value  := StrToInt (SL[ 3]);
              TxnlogTable.FieldByName('TELLER')     .value  :=           SL[ 4] ;
              TxnlogTable.FieldByName('IDENT')      .value  :=           SL[ 5] ;
              TxnlogTable.FieldByName('RECINDEX')   .value  := StrToInt (SL[ 6]);
              TxnlogTable.FieldByName('PLU')        .value  := StrToInt (SL[ 7]);
              TxnlogTable.FieldByName('PRICE')      .value  := StrToCurr(SL[ 8]);
              TxnlogTable.FieldByName('QUANTITY')   .value  := StrToInt (SL[ 9]);
              TxnlogTable.FieldByName('TXNVALUE')   .value  := StrToCurr(SL[10]);
              TxnlogTable.FieldByName('DESCRIPTION').value  :=           SL[11] ;
              TxnlogTable.FieldByName('INFO')       .value  :=           SL[12] ;
              TxnlogTable.FieldByName('PROD')       .value  :=           SL[13] ;
              TxnlogTable.FieldByName('DOMINFO')    .value  :=           SL[14] ;
              TxnLogTable.Post;
              TryCount := MaxTries; //record posted ok
              //update bitmap
              try
                 TransmitData.RecordsAddedLocally(NextRecId,NextRecId);
              except
                On E : Exception do
                  RaiseGUIDException('{934C0A0E-CE5A-46AE-89D5-0D41CB83D5E7}', E);
              end;
            except
              On E : Exception do
              begin
                RaiseGUIDException('{D186EB05-3863-4549-9C72-B94906BDB6E8}', E);
                TxnlogTable.Cancel;
                Inc(TryCount);
              end;
            end;
            Inc(NextRecId);
          end;  //while TryCount < MaxTries
        end;  //for all txns in batch
        TxnList.Delete(0);
      except
        On E : Exception do
          RaiseGUIDException('{4E8542B2-554E-4B59-99BC-4BDD90DE36ED}', E);
      end;
    end;
    TxnlogTable.Active:=False;

    FSL.Free;
    SL.Free;
  except
    On E : Exception do
      RaiseGUIDException('{C0DC5387-4927-4B36-B8D0-79D85C1E1425}', E);
  end;
  Incheck:=False;
end;
procedure TTxnProcessor.CheckTxns(Sender:TObject);
const
   CheckIng:Boolean = False;
begin
   if Checking then Exit;
   Checking:=True;
   if TxnList.Count <> 0 then CheckTxnList;
   Checking:=False;
end;

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

end.
