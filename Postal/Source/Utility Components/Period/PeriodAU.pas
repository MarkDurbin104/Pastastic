unit PeriodAU;

interface

uses
  GPCSErrorLine,
  Forms,Windows,Graphics,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,PackStrListU,
  Dialogs,DBTables;
  
type
  TGPCSPeriod = class(TPeriod)
  private
     LastEnd:Integer;
     LastStart:Integer;
  public
    procedure Initialize; override;
    destructor Destroy; override;
    function QueryToPackText(TxnLogQuery:String):String;
  protected
    function  GetCurrentPeriod(const User: WideString): Integer;  override;
    procedure EndOfDay(const User: WideString); override;
    procedure Open(const User: WideString; Period: Integer); override;
    procedure StartOfDay(const User: WideString); override;
    function  GetStartOfDayValues(const User: WideString):WideString; override;
    function  HadEndOfDay(const User: WideString):WordBool; override;
    function  GetLastPeriod(const User: WideString): Integer; override;
    function  GetCarryItem(PLUVal,SupLastPeriod:String):Currency;
    function  GetAnyPeriodCash(const User : WideString; const Period : Integer) : Currency;
    function  GetLastPeriodCash(const User: WideString): Currency; override;
    function  GetPeriodCash(const User: WideString): Currency; override;
    function  GetPeriodStock(const User: WideString): Currency; override;
    function  GetPeriodCheque(const User: WideString): Currency;
    function  GetESState(const User: WideString): esState; override;
  end;

procedure LogEvent(Event : String);

implementation

uses
   ComServ2,PeriodFU;

procedure LogEvent(Event : String);
begin
  if ComServer.StartMode <> smStandAlone then Exit;
  PeriodForm.LogMemo.Lines.Add(TimeToStr(Now) +' - ' + Event);
  While PeriodForm.LogMemo.Lines.Count > 500 do
    PeriodForm.LogMemo.lines.Delete(0);
end;

{TStock}
function TGPCSPeriod.QueryToPackText(TxnLogQuery:String):String;
var
  Query:TQuery;
  SL:TPackStringList;
  RSL:TPackStringList;
  I:Integer;
begin
  try
    SL:=TPackStringList.Create;
    RSL:=TPackStringList.Create;
    Query:=TQuery.Create(nil);
    try
       with Query do
       begin
          DatabaseName:='PSL';
          SQL.Text:=TxnLogQuery;
          Active:=True;
          First;
          while not EOF do
          begin
             for I:=0 to FieldCount-1 do
                RSL.Add(Fields[I].AsString);
             SL.Add(RSL.PackText);
             RSL.Clear;
             Next;
          end;
          Active:=False;
       end;
    finally
      Query.Free;
      RSL.Free;
      Result:=SL.PackText;
      SL.Free;
    end;
  except
    On E : Exception do
      RaiseGUIDException('{9E4DE400-7EB2-4F2B-8FF0-65BC92E3B6F3}' + TxnLogQuery, E);
  end;
end;

procedure TGPCSPeriod.Initialize;
begin
  LogEvent('Initialize Start');
   inherited Initialize;
  LogEvent('Initialize End');
end;

destructor TGPCSPeriod.Destroy;
begin
  LogEvent('Destroy Start');
   inherited Destroy;
  LogEvent('Destroy End');
end;

function FirstField(S:String):String;
var
   SL:TPackStringlist;
begin
  try
    SL:=TPackStringlist.Create;
    SL.PackText:=S;
    if SL.Count > 0 then
      Result:=SL[0]
    else
      Result:=S;
    SL.Free;
  except
    On E : Exception do
      RaiseGUIDException('{8162D3B0-3950-467A-8CD1-25861BA63A1E}', E);
  end;

end;

function TGPCSPeriod.GetESState(const User: WideString): esState;
var
   CP:Integer;
   TP:Integer;
   NewUser:Boolean;
begin
  try
   LogEvent('GetESState Start');
   Result:=PeriodForm.UserList.GetState(User,NewUser);
   if NewUser then
   begin
      HadEndOfDay(User);
      TP:=GetTodayasPeriod;
      CP:=GetCurrentPeriod(User);
      LogEvent('TodaysPeriod = '+IntToStr(TP));
      LogEvent('CurrentPeriod = '+IntToStr(CP));
      if CP >= TP then
      begin
         if LastEnd = CP then
         begin
            Result:=esStateFinished;
            LogEvent('Result:=esStateFinished');
         end
         else
         begin
            Result:=esStateStarted;
            if CP > TP then
            begin
               Result:=esStateStartNewDay;
               LogEvent('Result:=esStateStartNewDay');
            end
            else
            begin
               Result:=esStateStarted;
               LogEvent('Result:=esStateStarted');
            end;
         end;
      end
      else
      begin
         if (LastEnd >= CP) or ((LastStart = -1) and (LastEnd = -1)) then
         begin
            Result:=esStateNotStarted;
            LogEvent('Result:=esStateNotStarted');
         end
         else
         begin
            Result:=esStateNotFinished;
            LogEvent('Result:=esStateNotFinished');
         end;
      end;
      PeriodForm.UserList.SetState(User,Result);
   end;
   LogEvent('GetESState End');
  except
    On E : Exception do
      RaiseGUIDException('{6EA46519-5E14-4598-ABAB-CF2FDD2D6B4A}', E);
  end;
end;
function TGPCSPeriod.GetCarryItem(PLUVal,SupLastPeriod:String):Currency;
var
   QuerySL:TPackStringList;
   TxnLogQuery:String;
begin
   Result:=0;
   try
      QuerySL:=TPackStringList.Create;
      TxnLogQuery:='select Sum(TxnValue) from Txnlog'               +
                   ' where ( Period        = ' + SupLastPeriod +')' +
                   ' and   ( PLU           = '''+PLUVal+'''      )' +
                   ' and   ( Teller        = ''Supervisor''      )' +
                   ' and   ( RecType = ''TxnTotal''        )';
      QuerySL.PackText:=QueryToPackText(TxnLogQuery);
      if QuerySL.Count > 0 then
         Result:=StrToCurrDef(FirstField(QuerySL[0]),0);
      QuerySL.Free;
   except
      On E : Exception do
         RaiseGUIDException('{8EB610C9-1C80-462D-B84D-CC5216786D30}', E);
   end;
end;
function TGPCSPeriod.GetLastPeriodCash(const User: WideString): Currency;
var
  TempUser : WideString;
begin
  try
    LogEvent('GetLastPeriod Start');
    If User = 'All' then
      TempUser := 'Supervisor'
    else
      TempUser := User;
    Result := GetAnyPeriodCash(TempUser,GetLastPeriod(TempUser));
    LogEvent('GetLastPeriod End');
  except
    On E : Exception do
      RaiseGUIDException('{B9DC58D5-0E79-4D84-B017-70400D7CB46F}', E);
  end;
end;

function TGPCSPeriod.GetPeriodStock(const User: WideString): Currency;
var
   Stock:IStock;
   SL:TPackStringList;
   LSL:TPackStringList;
   I:Integer;
begin
  Result:=0;
  try
    LogEvent('GetPeriodStock Start');
    SL:=TPackStringList.Create;
    Stock:=CreateStock;
    if Stock <> nil then
    begin
      //  ListAvailableStock - Description,Quantity,Price,PLU,ProgID
      SL.CommaText:=Stock.ListAvailableStock(User,'*All');
      Stock:=nil;
    end;
    LSL:=TPackStringList.Create;
    for I:=0 to SL.Count-1 do
    begin
      LSL.CommaText:=SL[I];
      if SL.Count > 2 then
         Result:=Result+StrToCurrDef(LSL[2],0)*StrToIntDef(LSL[1],0)
      else
         RaiseGUIDError('{B98C3EC4-081D-4056-B6BF-8A6786400E0B}','Error in ListAvailableStock ('+SL.PackText+') Line '+IntToStr(I) );
    end;
    SL.Free;
    LSL.Free;
    LogEvent('GetPeriodStock End');
  except
    On E : Exception do
      RaiseGUIDException('{8B1EAE1C-55A0-4C1D-85E0-E863709140DE}', E);
  end;
end;

function TGPCSPeriod.GetPeriodCheque(const User: WideString): Currency;
var
   Stock:IStock;
   SL:TPackStringList;
   LSL:TPackStringList;
   I:Integer;
begin
  Result:=0;
  try
    LogEvent('GetPeriodStock Start');
    SL:=TPackStringList.Create;
    Stock:=CreateStock;
    if Stock <> nil then
    begin
      //  ListAvailableStock - Description,Quantity,Price,PLU,ProgID
      SL.CommaText:=Stock.ListAvailableStock(User, 'Cash');
      Stock:=nil;
    end;

    LSL:=TPackStringList.Create;
    for I:=0 to SL.Count-1 do
    begin
      LSL.CommaText:=SL[I];
      if LSL[4] = 'Product.Cheque' then
         Result:=Result+StrToCurrDef(LSL[2],0)*StrToIntDef(LSL[1],0);
    end;
    SL.Free;
    LSL.Free;
    LogEvent('GetPeriodStock End');
  except
    On E : Exception do
      RaiseGUIDException('{8B1EAE1C-55A0-4C1D-85E0-E863709140DE}', E);
  end;
end;


function  TGPCSPeriod.GetAnyPeriodCash(const User : WideString; const Period : Integer) : Currency;
var
  QuerySL:TPackStringList;
  TxnLogQuery:String;
  StandardSearch : String;
begin
  QuerySL:=TPackStringList.Create;
  StandardSearch :=  ' ((Prod = ''Product.Cash'') or (Prod = ''Product.CashAccAdj'' and PLU = 2009010)) and Period = ' + IntToStr(Period);
  TxnlogQuery :=
            ' select Sum(TxnValue) from Txnlog '
          + ' where ' + StandardSearch
          + ' and                              '
          + ' (                                '
          + '   ( Teller = ''' + User + '''    '
          + '     and                          '
          + '     ( RecType = ''TxnLine''      '
          + '       or                         '
                    //only get last StartDay record
          + '       ( RecType = ''StartDay'' '
          + '         and                    '
          + '         RecordId = (Select Max(Recordid) from Txnlog '
          + '                   where '+ StandardSearch
          + '                   and RecType = ''StartDay'' '
          + '                   and Teller = ''' + User + '''))'
          + '     ) '
          + '   )';

  //grab clerk Cash txns for supervisor (ie office) cash total
  if User = 'Supervisor' then
  begin
    TxnLogQuery:= TxnLogQuery
          + '   or '
          + '   ( Teller <> ''Supervisor'' '
          + '     and RecType = ''TxnLine'' ' //nb clerk startday value already in Supervisor StartDay above!
          + '   )';
  end;
  TxnLogQuery := TxnLogQuery  + ' )  '; //final bracket

  QuerySL.PackText:=QueryToPackText(TxnLogQuery);
  if QuerySL.Count > 0 then
    Result:=StrToCurrDef(FirstField(QuerySL[0]),0)
  else
    Result:=0;
  QuerySL.Free;
end;

function TGPCSPeriod.GetPeriodCash(const User: WideString): Currency;
begin
  try
    LogEvent('GetPeriodCash Start');
    Result := GetAnyPeriodCash(User, GetCurrentPeriod(User));
    LogEvent('GetPeriodCash End');
  except
    On E : Exception do
      RaiseGUIDException('{F5783B17-598A-4F8C-98CC-DB31428E2D5D}', E);
  end;
end;

function TGPCSPeriod.GetLastPeriod(const User: WideString): Integer;
var
   QuerySL:TPackStringList;
   TxnLogQuery:String;
begin
  try
    LogEvent('GetLastPeriod Start');
    QuerySL:=TPackStringList.Create;
    Result:=0;
    TxnLogQuery:='select Max(Period) from Txnlog' +
                ' where Teller = '''+User+'''';
    QuerySL.PackText:=QueryToPackText(TxnLogQuery);
    if QuerySL.Count > 0 then
      Result:=StrToIntDef(FirstField(QuerySL[QuerySL.Count-1]),0);
    QuerySL.Free;
    LogEvent('GetLastPeriod End');
  except
    On E : Exception do
      RaiseGUIDException('{36969038-CE3C-49BB-A5C0-FF317B0412FF}', E);
  end;
end;

function TGPCSPeriod.GetCurrentPeriod(const User: WideString): Integer;
var
   QuerySL:TPackStringList;
   TxnLogQuery:String;
begin
  try
    LogEvent('GetCurrentPeriod Start');
    if FileExists('C:\ForcePeriod.Lck')  then
    begin
      QuerySL:=TPackStringList.Create;
      try
         QuerySL.LoadFromFile('C:\ForcePeriod.Lck');
         Result:=StrToIntDef(QuerySL[0],GetTodayasPeriod);
      except
         Result:=GetTodayasPeriod+1;
      end;
      QuerySL.Free;
      Exit;
    end;
    QuerySL:=TPackStringList.Create;
    TxnLogQuery:='select max(Period) from Txnlog' +
                ' where RecType = ''StartDay'''  +
                ' and Teller = '''+User+'''';

    QuerySL.PackText:=QueryToPackText(TxnLogQuery);
    if QuerySL.Count > 0 then
    begin
      LastStart:=StrToIntDef(FirstField(QuerySL[QuerySL.Count-1]),-1);
      if LastStart = -1 then
         Result:=GetTodayasPeriod-1
      else
         Result:=LastStart;
    end
    else
    begin
      Result:=GetTodayasPeriod-1;
      LastStart:=-1;
    end;
    QuerySL.Free;
    LogEvent('GetCurrentPeriod End');
  except
    On E : Exception do
      RaiseGUIDException('{0CFD9D19-5A34-4D34-8E4F-8C638C75EFBF}', E);
  end;

end;

function TGPCSPeriod.HadEndOfDay(const User: WideString):WordBool;
var
   QuerySL:TPackStringList;
   TxnLogQuery:String;
   HadCancelEOD:Boolean;
   CancelEODRecord:Integer;
   EODRecordID:Integer;
begin
  try
     LogEvent('HadEndOfDay Start');
     Result:=True;
     LastEnd:=-1;
     QuerySL:=TPackStringList.Create;
     TxnLogQuery:='select max(Period) from Txnlog' +
                  ' where RecType = ''EndDay'''  +
                  ' and Teller = '''+User+'''';
     QuerySL.PackText:=QueryToPackText(TxnLogQuery);
     if QuerySL.Count > 0 then
     begin
        LastEnd:=StrToIntDef(FirstField(QuerySL[QuerySL.Count-1]),-1);
        if LastEnd > 0 then
        begin
           if GetCurrentPeriod(User) < LastEnd then
              Result:=True
           else
              Result:=False;
        end;
     end;
     if (LastEnd = GetCurrentPeriod(User)) then // we have had an end of day today
     begin
        TxnLogQuery:='select RecordID from Txnlog' +
                     ' where RecType = ''CancelEOD'' and Period = '+IntToStr(LastEnd)+' '+
                     ' and Teller = '''+User+'''';
        QuerySL.PackText:=QueryToPackText(TxnLogQuery);
        HadCancelEOD:=False;
        CancelEODRecord:=-1;
        if QuerySL.Count > 0 then
        begin
           CancelEODRecord:=StrToIntDef(FirstField(QuerySL[QuerySL.Count-1]),-1);
           if CancelEODRecord > 0 then
              HadCancelEOD:=True;
        end;
        if HadCancelEOD then // we have had a CencelEOD for the same day
        begin
           TxnLogQuery:='select max(RecordID) from Txnlog' +
                        ' where RecType = ''EndDay'''  +
                        ' and Teller = '''+User+'''';
           QuerySL.PackText:=QueryToPackText(TxnLogQuery);
           if QuerySL.Count > 0 then
           begin
              EODRecordID:=StrToIntDef(FirstField(QuerySL[QuerySL.Count-1]),-1);
              if CancelEODRecord > EODRecordID then
              begin
                 Dec(LastEnd); // Cancel > End: make end previous day
              end;
           end;
        end;
     end;
     QuerySL.Free;
     LogEvent('HadEndOfDay End');
  except
    On E : Exception do
      RaiseGUIDException('{1A680429-EB1E-4754-B098-A0A60EF190BA}', E);
  end;
end;

procedure TGPCSPeriod.EndOfDay(const User: WideString);
var
   TxnLog:ITransactionLog;
   State:esState;
begin
  try
     LogEvent('EndOfDay Start');
     PeriodForm.UserList.Delete(User);
     TxnLog:=CreateTransactionLog;
     TxnLog.User:=User;
     TxnLog.Office:=StrToIntDef(GetGPCSRegString('OfficeInfo','Office ID','3211'),3211);
     TxnLog.WriteTransaction( '*EndDay',0,0,0,GetPeriodCash(User),GetPeriodStock(User),'','','','');
     TxnLog:=nil;
//   PeriodForm.UserList.SetState(User,esStateFinished);
     State:=GetESState(User);
     while (State <> esStateFinished) and (State <> esStateNotStarted) do
     begin
        PeriodForm.UserList.Delete(User);
        Sleep(1000);
        Application.ProcessMessages;
        if Application.Terminated then Exit;
        State:=GetESState(User);
     end;
    LogEvent('EndOfDay End');
  except
    On E : Exception do
      RaiseGUIDException('{C245ECE2-D7E2-4C7C-B6DA-7678025357AD}', E);
  end;
end;

procedure TGPCSPeriod.Open(const User: WideString; Period: Integer);
var
   SL:TStringList;
begin
  try
    LogEvent('Open Start');
     SL:=TStringList.Create;
     SL.Add(IntToStr(Period));
     SL.SaveToFile('C:\ForcePeriod.Lck');
     SL.Free;
     StartOfDay(User);
     DeleteFile('C:\ForcePeriod.Lck');
    LogEvent('Open End');
  except
    On E : Exception do
      RaiseGUIDException('{C86EBF4C-DDDA-40ED-B70E-7F5B9F80101E}', E);
  end;
end;

procedure TGPCSPeriod.StartOfDay(const User: WideString);
var
   TxnLog:ITransactionLog;
   LPCheque:Currency;
   LPCash,LPStock:Currency;
   PMStock:Currency;
   Bank:Currency;
   PostShop:Currency;
   UnClPay:Currency;
   UnChRec:Currency;
   SupLastPeriod:String;
begin
  try
     LogEvent('StartOfDay Start');
     PeriodForm.UserList.Delete(User);
     TxnLog:=CreateTransactionLog;
     TxnLog.User:=User;
     TxnLog.Office:=StrToIntDef(GetGPCSRegString('OfficeInfo','Office ID','3211'),3211);
     TxnLog.WorkStation:=StrToIntDef(GetGPCSRegString('WorkStation','Ident','2'),2);
     if User = 'Supervisor' then
     begin
        SupLastPeriod:=IntToStr(GetLastPeriod('Supervisor'));
        LPStock:=GetPeriodStock( 'All' );
        LPCash :=GetLastPeriodCash( 'All' );
     end
     else
     begin
        LPStock:=GetPeriodStock(User);
        LPCash :=GetLastPeriodCash(User);
     end;

     TxnLog.WriteTransaction('*StartDay',0,0,0,LPCash,0,'','','Product.Cash','');
     //PeriodForm.UserList.SetState(User,esStateStarted);
     PeriodForm.UserList.Delete(User);
     while (GetESState(User) and esStateStarted) <> esStateStarted do
     begin
        PeriodForm.UserList.Delete(User);
        Sleep(1000);
        Application.ProcessMessages;
        if Application.Terminated then Exit;
     end;

     if User = 'Supervisor' then
     begin
        LPCheque:=GetPeriodCheque('All');
        PMStock :=GetCarryItem('2005100',SupLastPeriod);
        UnClPay :=GetCarryItem('2005200',SupLastPeriod);
        UnChRec :=GetCarryItem('2005400',SupLastPeriod);
        Bank    :=GetCarryItem('2005090',SupLastPeriod);
        PostShop:=GetCarryItem('2001000',SupLastPeriod);

        TxnLog.WriteTransaction('*TxnTotal',0,0,61000000,(LPCheque+LPStock+LPCash+PMStock+UnClPay+Bank)-UnChRec,0,'Balance Brought Forward','','','');
        TxnLog.WriteTransaction('*TxnTotal',0,0,2005100,PMStock ,0,'Total Sub-PostMasters Stock','','','');
        TxnLog.WriteTransaction('*TxnTotal',0,0,2005200,UnClPay ,0,'Unclaimed Payments','','','');
        TxnLog.WriteTransaction('*TxnTotal',0,0,2005400,UnChRec ,0,'Uncharged Receipts','','','');
        TxnLog.WriteTransaction('*TxnTotal',0,0,2005090,Bank    ,0,'Bank','','','');
        TxnLog.WriteTransaction('*TxnTotal',0,0,2001000,PostShop,0,'Post Shop Items','','','');
     end
     else
     begin
     LPCheque:=GetPeriodCheque(User);
     TxnLog.WriteTransaction('*TxnTotal',0,0,61000000,LPCheque+LPStock+LPCash,0,'Balance Brought Forward','','','');
     end ;
     TxnLog:=nil;
    LogEvent('StartOfDay End');
  except
    On E : Exception do
      RaiseGUIDException('{16767D87-1DAC-4599-89A7-51079C6323FB}', E);
  end;
end;

function TGPCSPeriod.GetStartOfDayValues(const User: WideString):WideString;
var
   SL:TPackStringList;
var
   LSL:TPackStringList;
   QuerySL:TPackStringList;
   TxnLogQuery:String;
begin
  try
    LogEvent('GetStartOfDayValues Start');
     Result:='';
     LSL:=TPackStringList.Create;
     SL:=TPackStringList.Create;
     QuerySL:=TPackStringList.Create;

     // find End of Day entries for last period
     TxnLogQuery:=' select TxnValue , Price from TxnLog' +
                  ' where RecType = ''EndDay'''          +
                  ' and Teller = '''+User+'''  '         +
                  ' and Period = ' + IntToStr(GetLastPeriod(User))   ;

     QuerySL.PackText:=QueryToPackText(TxnLogQuery);
     if (QuerySL.Count > 0) then
        Result:=QuerySL[0];
     LSL.Free;
     QuerySL.Free;
     SL.Free;
    LogEvent('GetStartOfDayValues End');
  except
    On E : Exception do
      RaiseGUIDException('{5BC26AFF-9530-4986-AA4C-9A5AB4FF82D7}', E);
  end;
end;

initialization
  TGPCSCompFactory.Create(ComServer,TGPCSPeriod,Class_GPCSPeriod,
                          'Support.Period','GPCS Period Component',
                          ciMultiInstance);
end.