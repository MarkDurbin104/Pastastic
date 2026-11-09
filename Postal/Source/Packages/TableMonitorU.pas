unit TableMonitorU;

interface

uses
   Windows,Forms,SysUtils, Classes,DGramU,GPCSGUID,DBTables,Db,GPCSErrorLine,PackStrListU,
   UDPMessageU; // MesQueueU,

const
   WSFieldName = 'WSNumber';
   IDFieldName = 'RecordID';

type
  TTMonitor = class;
  TNotifyChange = procedure (Sender:TTMonitor;Data:String) of object;
  TBits = Array[0..0] of Cardinal;
  PBits = ^TBits;
  TBitMapping = class(TObject)
  private
     FBaseOffset:Cardinal;
     FBits  :PBits;
     FCount :Cardinal;
  protected
     procedure SetBit(Index:Cardinal;Value:Boolean);
     function GetBit(Index:Cardinal):Boolean;
  public
     constructor Create;
     destructor Destroy; override;
     function AsString:String;
     procedure SetFromString(Value:String);
     function BitDifference(Value:String):String;
     function LastBitSet:Integer;
     property Bit[Index:Cardinal]:Boolean read GetBit write SetBit; default;
     property Count:Cardinal read FCount;
     property BaseOffset:Cardinal read FBaseOffset write FBaseOffset;
  end;
  TTableRecords = class(TObject)
  private
     FWSNumber:Integer;
     FBitMap:TBitMapping;
     FNextIndex:Integer;
  public
     function AsString:String;
     constructor Create(Alias,Table:String;WorkStation:Integer);
     destructor Destroy; override;
  end;
  TTableMapping = class(TObject)
  private
     FWSNumber:Integer;
     WSList:TPackStringList;
     FAlias:String;
     FTable:String;
  public
     constructor Create(Alias,Table:String);
     destructor Destroy; override;
     function BMP(WorkStation:Integer):TBitMapping;
     function AsString:String;
     function WSString(WorkStation:Integer):String;
     property WSNumber:Integer read FWSNumber write FWSNumber;
  end;
  TTMonitor = Class(TComponent)
  private
//     FIgnoreUpdates:Boolean;
     MessageData:TPackStringList;
     FActive:Boolean;
     Tables:TPackStringList;
     FWSNumber:Integer;
     FDGramSocket:TDGramSocket;
     MsgServer:TMsgServer;
     FOnAddRecord:TNotifyChange;
     FOnDelRecord:TNotifyChange;
     FOnTxRecord :TNotifyChange;
     FOnRxDGram  :TNotifyChange;
     FOnTxDGram  :TNotifyChange;
     FOnRefresh  :TNotifyChange;
     function GetList:TStrings;
     procedure SetList(Value:TStrings);
     procedure RxDataGram(Sender:TDGramSocket;From,Data:String);
//     procedure TxRecord(Alias,TableName:String;Workstation,RecordID:Integer);
     function RecordData(Alias,TableName:String;Workstation,RecordID:Integer):String;
//     procedure AddRecord(PackText:String);
//     procedure DelRecord(PackText:String);
     procedure SetActive(Value:Boolean);
     function GetIPAddress:String;
  public
     ProcessingData:Array[0..999] of Boolean;
     TxInProgress:TPackStringList;
     procedure SendDGram(Data:String);
     procedure CheckRxMessage;
     procedure RxMessage(Message:String);
     function Mapping(Alias,Table:String):TTableMapping;
     procedure RecNotify(Alias,Table:String;StartRecordID,EndRecordID:Integer;RecordDeleted:Boolean);
     procedure UpdateComplete(Alias,Table:String);
     function  NextFreeIdent(Alias,TableName:String):Integer;
     property Active:Boolean read FActive write SetActive;
     property DGramSocket:TDGramSocket read FDGramSocket;
  published
     constructor Create(AOwner:TComponent); override;
     destructor Destroy; override;
     property TableList:TStrings read GetList write SetList;
     property WSNumber:Integer read FWSNumber write FWSNumber stored False;
     property OnAddRecord:TNotifyChange read FOnAddRecord write FOnAddRecord;
     property OnDelRecord:TNotifyChange read FOnDelRecord write FOnDelRecord;
     property OnTxRecord :TNotifyChange read FOnTxRecord  write FOnTxRecord ;
     property OnRxDGram  :TNotifyChange read FOnRxDGram   write FOnRxDGram  ;
     property OnTxDGram  :TNotifyChange read FOnTxDGram   write FOnTxDGram  ;
     property OnRefresh  :TNotifyChange read FOnRefresh   write FOnRefresh  ;
     property IPAddress  :String read GetIPAddress;
  end;

procedure Register;

implementation

procedure Register;
begin
   RegisterComponents('PSL-IPM', [TTMonitor]);
end;

{TTMonitor}
function TTMonitor.GetIPAddress:String;
begin
   if FDGramSocket <> nil then
      Result:=FDGramSocket.IPAddress
   else
      Result:='';
end;
procedure TTMonitor.UpdateComplete(Alias,Table:String);
var
   TableMapping:TTableMapping;
begin
//   if not FIgnoreUpdates then
   begin
      TableMapping:=Mapping(Alias,Table);
      if TableMapping <> nil then
         SendDGram(TableMapping.WSString(-1));
      CheckRxMessage;
   end;
end;  
procedure TTMonitor.RecNotify(Alias,Table:String;StartRecordID,EndRecordID:Integer;RecordDeleted:Boolean);
var
   TableMapping:TTableMapping;
   I:Integer;
begin
   TableMapping:=Mapping(Alias,Table);
   if TableMapping <> nil then
   begin
      for I:=StartRecordID to EndRecordID do
         TableMapping.BMP(FWSNumber)[I]:=not RecordDeleted;
   end;
end;
procedure TTMonitor.SendDGram(Data:String);
var
   Query:TQuery;
   J,K:Integer;
begin
//   if FIgnoreUpdates then Exit;
   try
      if Data <> 'Delete All Records' then
      begin
         if Assigned(FOnTxDGram) then FOnTxDGram(Self,Data);
      end
      else
      begin
         Query:=TQuery.Create(nil);
         Query.DatabaseName:='PSL';
         Query.SQL.Text:='delete from txnlog';
         Query.ExecSQL;
         Query.Free;
         for J:=0 to Tables.Count-1 do
         begin
            if Tables.Objects[J] <> nil then
            begin
               for K:=0 to TTableMapping(Tables.Objects[J]).WSList.Count-1 do
                  TTableRecords(TTableMapping(Tables.Objects[J]).WSList.Objects[K]).Free;
               TTableMapping(Tables.Objects[J]).WSList.Clear;
            end;
         end;
         Tables.Clear;
      end;
   except
      on E : Exception do RaiseGUIDException('{CC6BFC4B-2170-4E60-B7BB-A78C39F72E6E}',E);
   end;
   FDGramSocket.SendDGram(Data);
end;
function TTMonitor.Mapping(Alias,Table:String):TTableMapping;
var
   Index:Integer;
begin
   Index:=Tables.IndexOf(Alias+':'+Table);
   if Index <> -1 then
      Result:=TTableMapping(Tables.Objects[Index])
   else
      Result:=nil;
end;
function TTMonitor.NextFreeIdent(Alias,TableName:String):Integer;
var
   Index:Integer;
   TableMapping:TTableMapping;
begin
   Result:=0;     
   Index:=Tables.IndexOf(Alias+':'+TableName);
   if Index <> -1 then
   begin
      TableMapping:=TTableMapping(Tables.Objects[Index]);
      if TableMapping <> nil then
         Result:=TableMapping.BMP(FWSNumber).LastBitSet+1;
   end;
end;
procedure TTMonitor.RxMessage(Message:String);
var
   SL:TPackStringList;
   WS:Integer;
begin
   SL:=TPackStringList.Create;
   try
      SL.Text:=Message;
      SL.PackText:=SL[0];
      if SL.Count > 2 then
      begin
         WS:=StrToIntDef(SL[2],-1);
         ProcessingData[WS]:=True;
         if Assigned(FOnRefresh) then FOnRefresh(Self,'');
         MessageData.Add(Message);
      end;
   except
   end;
end;
procedure TTMonitor.CheckRxMessage;
var
   SL:TPackStringList;
   RSL:TPackStringList;
   WS,I,J,K:Integer;
//   Data:String;
   TableIndex:Integer;
   TableMapping:TTableMapping;
   Table:TTable;
//   RSL:TPackStringList;
   FSL:TPackStringList;
   Code:Integer;
   DT:TDateTime;
   FID:Integer;
   Message:String;
const
   LastCheck:Integer = 0;
begin
   Inc(LastCheck);
   if MessageData.Count > 0 then
   begin
      Message := MessageData[0];
      MessageData.Delete(0);
   end
   else
   begin
      for I:=0 to 999 do ProcessingData[I]:=False;
      if Assigned(FOnRefresh) then FOnRefresh(Self,'');
      Exit;
   end;
   SL:=TPackStringList.Create;
   RSL:=TPackStringList.Create;
   FSL:=TPackStringList.Create;
//   FIgnoreUpdates:=True;
   try
      SL.Text:=Message;
      RSL.PackText:=SL[0];
      if RSL.Count > 2 then
      begin
         if (RSL[0] = '*') then
         begin
            TableIndex:=Tables.IndexOf(RSL[1]);
            if TableIndex <> -1 then
            begin
               TableMapping:=TTableMapping(Tables.Objects[TableIndex]);
               Table:=TTable.Create(nil);
               Table.DatabaseName:=TableMapping.FAlias;
               Table.TableName   :=TableMapping.FTable;
               Table.Active:=True;
               WS:=StrToIntDef(RSL[2],-1);
               for I:=0 to SL.Count-1 do
               begin
                  RSL.PackText:=SL[I];
                  WS:=StrToIntDef(RSL[2],-1);
                  if TableMapping.BMP(WS) <> nil then
                  begin
                     J:=StrToIntDef(RSL[3],9999);
                     if not TableMapping.BMP(WS)[J] then
                     begin
                        try
                           RSL.PackText:=RSL[4];
                           Table.Append;
                           for K:=0 to RSL.Count-1 do
                           begin
                              FSL.PackText:=RSL[K];
                              if FSL.Count > 1 then
                              begin
                                 FID:=StrToInt(FSL[0]);
                                 if ((Table.Fields[FID] is TDateTimeField)
                                 or  (Table.Fields[FID] is TTimeField)
                                 or  (Table.Fields[FID] is TDateField)) then
                                 begin
                                    Val(FSL[1],DT,Code);
                                    Table.Fields[FID].Value:=DT;
                                 end
                                 else
                                    Table.Fields[FID].AsString:=FSL[1];
                              end;
                           end;
                           Table.Post;
                           if Assigned(FOnAddRecord) then
                              FOnAddRecord(Self,RSL.PackText);
                           if (I mod 20) = 19 then
                           begin
                              Application.ProcessMessages;
                              Sleep(1);
                           end;
                           if Application.Terminated then Break;
                        except
                        end;
                        TableMapping.BMP(WS)[J]:=True;
                     end;
                  end;
               end;
               Table.Active:=False;
               Table.Free;
               ProcessingData[WS]:=False;
               if Assigned(FOnRefresh) then FOnRefresh(Self,'');
            end;
         end
{         else if (SL[0] = '!') then
         begin
            RSL.PackText:=Data;
            if RSL.Count > 4 then
            begin
               TableIndex:=Tables.IndexOf(RSL[1]+','+RSL[2]);
               if TableIndex <> -1 then
               begin
                  TableMapping:=TTableMapping(Tables.Objects[TableIndex]);
                  WS:=StrToIntDef(RSL[3],-1);
                  if TableMapping.BMP(WS) <> nil then
                  begin
                     J:=StrToIntDef(RSL[4],99999999);
                     if TableMapping.BMP(WS)[J] then
                     begin
                        DelRecord(RSL.PackText);
                        TableMapping.BMP(WS)[J]:=False;
                     end;
                     if (I mod 20) = 19 then
                     begin
                        Application.ProcessMessages;
                        Sleep(1);
                     end;
                     if Application.Terminated then Break;
                  end;
               end;
            end
            else
            begin
                RaiseError($97,3,3,'Received data '+Data);
            end;
         end;}
      end;
   except
      on E : Exception do RaiseGUIDException('{BC7BC4AB-F066-425C-82E2-FC2EEEC98831}',E);
   end;
   FSL.Free;
   RSL.Free;
   SL.Free;
//   FIgnoreUpdates:=False;
end;
constructor TTMonitor.Create(AOwner:TComponent);
begin
   MessageData:=TPackStringList.Create;
   TxInProgress:=TPackStringList.Create;

   inherited Create(AOwner);
   try
      MsgServer:=TMsgServer.Create;
      MsgServer.OnMessage:=RxMessage;
   except
      if MsgServer <> nil then MsgServer.Free;
      MsgServer:=nil;
   end;
   Tables:=TPackStringList.Create;
   FWSNumber:=StrToInt(GetGPCSRegString('Workstation','Ident','0'));
   FDGramSocket:=TDGramSocket.Create(nil);
   FDGramSocket.NotifyRxOwn:=False;
   FDGramSocket.PortNumber:=45001;
   FDGramSocket.MaxDGramLen:=500;
   FDGramSocket.OnRxDataGram:=RxDataGram;
//   FIgnoreUpdates:=False;
end;
destructor TTMonitor.Destroy;
var
   I:Integer;
begin
   FDGramSocket.Active:=False;
   if MsgServer <> nil then MsgServer.Free;
   FDGramSocket.Free;
   for I:=0 to Tables.Count-1 do
      if Tables.Objects[I] <> nil then
        TTableMapping(Tables.Objects[I]).Free;
   Tables.Free;
   MessageData.Free;
   inherited Destroy;
end;
procedure TTMonitor.RxDataGram(Sender:TDGramSocket;From,Data:String);
var
   SL:TPackStringList;
   RSL:TPackStringList;
   WS,J,K:Integer;
   TableIndex:Integer;
   TableMapping:TTableMapping;
   RequestData:Boolean;
   Query:TQuery;
begin
//   if FIgnoreUpdates then Exit;
   RequestData:=False;
   if Data = 'Delete All Records' then
   begin
      Query:=TQuery.Create(nil);
      Query.DatabaseName:='PSL';
      Query.SQL.Text:='delete from txnlog';
      try
        Query.ExecSQL;
      except
        on E : Exception do RaiseGUIDException('{02C34109-6324-4810-9813-FF4A66ECA522}',E);
      end;
      Query.Free;
      for J:=0 to Tables.Count-1 do
      begin
         if Tables.Objects[J] <> nil then
         begin
            for K:=0 to TTableMapping(Tables.Objects[J]).WSList.Count-1 do
               TTableRecords(TTableMapping(Tables.Objects[J]).WSList.Objects[K]).Free;
            TTableMapping(Tables.Objects[J]).WSList.Clear;
         end;
      end;
      Exit;
   end;
   if Copy(Data,1,7) = 'Request' then
   begin
      RequestData:=True;
      Data:=Copy(Data,8,Length(Data));
   end;
   if Assigned (FOnRxDGram) then FOnRxDGram(Self,From+Data);
   if (Data = '!!!') then Exit;

   TableIndex:=-1;
   SL:=TPackStringList.Create;
   RSL:=TPackStringList.Create;
   SL.PackText:=Data;
   if SL.Count > 0 then TableIndex:=Tables.IndexOf(SL[0]);
   if (TableIndex = -1) or (SL.Count < 2) then
   begin
      RSL.Free;
      SL.Free;
      Exit;
   end;
   TableMapping:=TTableMapping(Tables.Objects[TableIndex]);

   RSL.PackText:=SL[1];
   if RSL.Count > 0 then
   begin
      WS:=StrToIntDef(RSL[0],-1);
      if WS = FWSNumber then
      begin
         if TxInProgress.IndexOf(From) = -1 then
         begin
            TxInProgress.Add(From);
            RSL.Delete(0);
            if TableMapping.BMP(WS) <> nil then
               RSL.PackText:=TableMapping.BMP(WS).BitDifference(RSL.PackText);
            if RSL.Count > 0 then
            begin
   //            FIgnoreUpdates:=True;
               try
                  for J:=0 to RSL.Count-1 do
                  begin
                      RSL[J]:=RecordData(TableMapping.FAlias,TableMapping.FTable,WS,StrToInt(RSL[J]));
                      if (J mod 20) = 19 then Application.ProcessMessages;
                      if Application.Terminated then Exit;
                  end;
                  if MsgServer <> nil then
                     MsgServer.SendMessage(RSL.Text);
               except
               end;
   //            FIgnoreUpdates:=False;
            end;
            TxInProgress.Delete(TxInProgress.IndexOf(From));
         end;
      end
      else if (not RequestData) and (not ProcessingData[WS]) then
      begin
         RSL.Delete(0);
         if TableMapping.BMP(WS) <> nil then
         begin
            if TableMapping.BMP(WS).BitDifference(RSL.PackText) <> '' then
               SendDGram('Request'+TableMapping.WSString(WS));
         end;
      end;
   end;
   SL.Free;
   RSL.Free;
end;
function TableDataToPackText(TableData:String):String;
var
   SL:TPackStringList;
   FSL:TPackStringList;
   I:Integer;
   J:Integer;
   WS:String;
begin
   SL:=TPackStringList.Create;
   FSL:=TPackStringList.Create;
   WS:='';
   for I:=1 to Length(TableData) do
   begin
      if TableData[I] = #3 then
      begin
         for J:=1 to Length(WS) do
         begin
            if WS[J] = #4 then
            begin
               FSL.Clear;
               FSL.Add(Copy(WS,1,J-1));
               FSL.Add(Copy(WS,J+1,Length(WS)));
               SL.Add(FSL.PackText);
            end;
         end;
         WS:='';
      end
      else
      begin
         WS:=WS+TableData[I];
      end;
   end;
   FSL.Free;
   Result:=SL.PackText;
   SL.Free;
end;
function PackTextToTableData(PackText:String):String;
var
   SL:TPackStringList;
   FSL:TPackStringList;
   I:Integer;
begin
   SL:=TPackStringList.Create;
   FSL:=TPackStringList.Create;
   SL.PackText:=PackText;
   Result:='';
   for I:=0 to SL.Count-1 do
   begin
      FSL.PackText:=SL[I];
      if FSL.Count > 1 then
         Result:=Result+FSL[0]+#4+FSL[1];
      if I < SL.Count-1 then
         Result:=Result+#3;
   end;                     
   FSL.Free;
   SL.Free;
end;
function TTMonitor.RecordData(Alias,TableName:String;Workstation,RecordID:Integer):String;
var
   SL:TPackStringList;
   Table:TTable;
   I:Integer;
   S:String;
   RSL:TPackStringList;
   FSL:TPackStringList;
begin
   if not FActive then Exit;
   if RecordID < 0 then
   begin
      Result:='!,'+Alias+':'+TableName+','+IntToStr(Workstation)+','+IntToStr((-1)-RecordID);
   end
   else
   begin
      SL:=TPackStringList.Create;
      SL.Add('*');
      SL.Add(Alias+':'+TableName);
      SL.Add(IntToStr(Workstation));
      SL.Add(IntToStr(RecordID));
      Table:=TTable.Create(nil);
      try
         Table.DatabaseName:=Alias;
         Table.TableName:=TableName;
         Table.Active:=True;
         Table.SetKey;
         Table.FieldByName(WSFieldName).Value:=Workstation;
         Table.FieldByName(IDFieldName).Value:=RecordID;
         if Table.GotoKey then
         begin
            RSL:=TPackStringList.Create;
            FSL:=TPackStringList.Create;
            for I:=0 to Table.FieldCount-1 do
            begin
                FSL.Add(IntToStr(I));
                if ((Table.Fields[I] is TDateTimeField)
                or  (Table.Fields[I] is TTimeField) 
                or  (Table.Fields[I] is TDateField)) then
                begin
                   Str(Table.Fields[I].Value,S);
                   FSL.Add(S);
                end
                else
                   FSL.Add(Table.Fields[I].AsString);
                RSL.Add(FSL.PackText);
                FSL.Clear;
            end;
            SL.Add(RSL.PackText);
            RSL.Free;
            FSL.Free;
         end;
         Table.Active:=False;
      except
         on E : Exception do RaiseGUIDException('{E39C3369-94F6-4593-8FB6-52C1B4639442}',E);
      end;
      Table.Free;
      Result:=SL.PackText;
      SL.Free;
   end;
end;  
{procedure TTMonitor.AddRecord(PackText:String);
var
   SL:TPackStringList;
   Table:TTable;
   RSL:TPackStringList;
   FSL:TPackStringList;
   Code,I:Integer;
   DT:TDateTime;
   P,FID:Integer;
begin
   SL:=TPackStringList.Create;
   RSL:=TPackStringList.Create;
   FSL:=TPackStringList.Create;
   SL.PackText:=PackText;
   if SL.Count > 4 then 
   begin
      RSL.PackText:=SL[4];
      Table:=TTable.Create(nil);
      try
         P:=Pos(':',SL[1]);
         if P > 0 then
         begin
            Table.DatabaseName:=Copy(SL[1],1,P-1);
            Table.TableName:=Copy(SL[1],P+1,Length(SL[1]));
            Table.Active:=True;
            Table.Append;
            for I:=0 to RSL.Count-1 do
            begin
               FSL.PackText:=RSL[I];
               if FSL.Count > 1 then
               begin
                  FID:=StrToInt(FSL[0]);
                  if ((Table.Fields[FID] is TDateTimeField)
                  or  (Table.Fields[FID] is TTimeField) 
                  or  (Table.Fields[FID] is TDateField)) then
                  begin
                     Val(FSL[1],DT,Code);
                     Table.Fields[FID].Value:=DT;
                  end
                  else
                     Table.Fields[FID].AsString:=FSL[1];
               end;
            end;                     
            Table.Post;
            Table.Active:=False;
            if Assigned(FOnAddRecord) then 
               FOnAddRecord(Self,RSL.PackText);
         end;
      except
      end;
      Table.Free;
   end;
   FSL.Free;
   RSL.Free;
   SL.Free;
end;
procedure TTMonitor.DelRecord(PackText:String);
var
   SL:TPackStringList;
   Table:TTable;
begin
   SL:=TPackStringList.Create;
   SL.PackText:=PackText;
   if SL.Count > 4 then
   begin
      Table:=TTable.Create(nil);
      try
         Table.DatabaseName:=SL[1];
         Table.TableName:=SL[2];
         Table.Active:=True;
         Table.SetKey;
         Table.FieldByName(WSFieldName).AsString:=SL[3];
         Table.FieldByName(IDFieldName).AsString:=SL[4];
         if Table.GotoKey then
           Table.Delete;
         Table.Active:=False;
         if Assigned(FOnDelRecord) then FOnDelRecord(Self,SL.PackText);
      except
      end;
      Table.Free;
   end;
   SL.Free;
end; }
procedure TTMonitor.SetActive(Value:Boolean);
var
   TableMapping:TTableMapping;
   Alias,Table:String;
   I:Integer;
   P:Integer;
begin
   if Value then  
   begin
//      MessageQueue.Activate;
      FDGramSocket.Active:=True;
      for I:=0 to Tables.Count-1 do
      begin
         P:=Pos(':',Tables[I]);
         if P > 0 then
         begin
            Alias:=Copy(Tables[I],1,P-1);
            Table:=Copy(Tables[I],P+1,Length(Tables[I]));
            TableMapping:=TTableMapping.Create(Alias,Table);
            TableMapping.WSNumber:=FWSNumber;
            Tables.Objects[I]:=TableMapping;
         end;
      end;    
      FActive:=True;
   end
   else
   begin
//      MessageQueue.DeActivate;
      FDGramSocket.Active:=False;
   end;
end;
function TTMonitor.GetList:TStrings;
begin
   Result:=Tables;
end;
procedure TTMonitor.SetList(Value:TStrings);
begin
   Tables.Assign(Value);
end;
{TTableMapping}
constructor TTableMapping.Create(Alias,Table:String);
var
   Query: TQuery;
   I:Integer;
   Field:TField;
   KeepPeriod,LastPeriod:Integer;
begin
   inherited Create;
   FAlias:=Alias;
   FTable:=Table;
   WSList:=TPackStringList.Create;
   Query:=TQuery.Create(nil);
   try
      Query.DatabaseName:=Alias;
      Query.SQL.Text:='Select distinct '+WSFieldName+' from '+Table;
      Query.Active:=True;
      Query.First;
      Field:=Query.FieldByName(WSFieldName);
      while not Query.EOF do
      begin
         I:=Field.Value;
         if I >= 0 then
            WSList.Add(IntToStr(I));
         Query.Next;
      end;
      Query.Active:=False;
      KeepPeriod:=StrToIntDef(GetGPCSRegString('','Transaction Periods To Keep','0'),0);
      if (UpperCase(Table) = 'TXNLOG') and (KeepPeriod > 0) then
      begin
         for I:=0 to WSList.Count-1 do
         begin
            Query.SQL.Text:='Select distinct period from '+Table+' where '+WSFieldName+' = '+WSList[I]+' order by period';
            try
               Query.Active:=True;
               Query.Last;
               LastPeriod:=Query.FieldByName('Period').Value;
            except
               LastPeriod:=GetTodayasPeriod;
            end;
            Query.Active:=False;
            Query.SQL.Text:='delete from txnlog where '+WSFieldName+' = '+WSList[I]+' and Period < '+IntToStr(LastPeriod-KeepPeriod);
            try
               Query.ExecSQL;
            except
            end;
         end; 
      end;
   except
      Query.Active:=False;
      on E : Exception do RaiseGUIDException('{55D96207-9FAE-42E1-A4CB-0711575A1960}',E);
   end;
   Query.Free;
   for I:=0 to WSList.Count-1 do
   try
      WSList.Objects[I]:=TTableRecords.Create(Alias,Table,StrToInt(WSList[I]));      
   except
   end;
end;
destructor TTableMapping.Destroy;
var
   I:Integer;
begin
   for I:=0 to WSList.Count-1 do
      if WSList.Objects[I] <> nil then
         TTableRecords(WSList.Objects[I]).Free;
   WSList.Free;
   inherited Destroy;
end;
function TTableMapping.WSString(WorkStation:Integer):String;
var
  Index:Integer;
  SL:TPackStringList;
  S:String;
begin
   SL:=TPackStringList.Create;
   if WorkStation = -1 then WorkStation:=WSNumber;
   Index:=WSList.IndexOf(IntToStr(WorkStation));
   if Index <> -1 then
   begin
      S:=TTableRecords(WSList.Objects[Index]).AsString;
   end
   else
   begin
      SL.Add(IntToStr(WorkStation));
      SL.Add('0');   
      S:=SL.PackText;
      SL.Clear;
   end;
      
   SL.Add(FAlias+':'+FTable);
   SL.Add(S);
   Result:=SL.PackText;
   SL.Free;
end;
function TTableMapping.BMP(WorkStation:Integer):TBitMapping;
var
  Index:Integer;
begin
   Index:=WSList.IndexOf(IntToStr(WorkStation));
   if Index = -1 then
      Index:=WSList.AddObject(IntToStr(WorkStation),TTableRecords.Create(FAlias,FTable,WorkStation));
      
   if Index <> -1 then
      Result:=TTableRecords(WSList.Objects[Index]).FBitmap
   else
      Result:=nil;
end;
function TTableMapping.AsString:String;
var
   I:Integer;
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Add(FAlias+':'+FTable);
   for I:=0 to WSList.Count-1 do
   begin
      if WSList.Objects[I] <> nil then
         SL.Add(TTableRecords(WSList.Objects[I]).AsString);
   end;
   Result:=SL.PackText;
   SL.Free;
end;
{TableRecords}
constructor TTableRecords.Create(Alias,Table:String;WorkStation:Integer);
var
   Query: TQuery;
   IDent:Integer;
   Field:TField;
begin
   inherited Create;
   FWSNumber:=WorkStation;
   FBitMap:=TBitMapping.Create;
   FNextIndex:=0;
   Query:=TQuery.Create(nil);
   try
      Query.DatabaseName:=Alias;
      Query.SQL.Text:='Select '+IDFieldName+' from '+Table+' where '+WSFieldName+' = '+IntToStr(WorkStation)+' order by '+IDFieldName;
      Query.Active:=True;
      Query.First;

      Field:=Query.FieldByName(IDFieldName);
      while not Query.EOF do
      begin
         IDent:=Field.Value;
         FBitMap[IDent]:=True;
         FNextIndex:=IDent+1;
         Query.Next;
      end;
      Query.Active:=False;
   except
      Query.Active:=False;
      on E : Exception do RaiseGUIDException('{86C79164-4B31-4BFA-87B7-0C86E076216E}',E);
   end;
   Query.Free;
end;         
destructor TTableRecords.Destroy;
begin
   FBitMap.Free;  
   inherited Destroy;
end;
function TTableRecords.AsString:String;
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.PackText:=FBitMap.AsString;
   SL.Insert(0,IntToStr(FWSNumber));
   Result:=SL.PackText;
   SL.Free;
end;
 
{TBitMapping}
constructor TBitMapping.Create;
begin
   inherited Create;
   FBaseOffset:=0;
   GetMem(FBits,SizeOf(Integer));
   ZeroMemory(FBits,SizeOf(Integer));
   FCount:=32;
end;
destructor TBitMapping.Destroy;
begin
   if FBits <> nil then FreeMem(FBits);
   inherited Destroy;
end;
function IntToBin(Value:Integer):String;
var
   I,Mask:Integer;
begin
   Mask:=$80000000;
   Result:='';
   for I:=0 to 31 do
   begin
     if (Value and Mask) = 0 then
        Result:=Result+'0'
     else
        Result:=Result+'1';
     Mask:=Mask shr 1;
   end;
end;
function TBitMapping.LastBitSet:Integer;
var
   I:Cardinal;
begin
   Result:=0;     
   for I:=FCount-1 downto 0 do  
   begin
      if Bit[I+FBaseOffset] then
      begin
         Result:=I+FBaseOffset;
         Exit;
      end;
   end;
end; 
function TBitMapping.AsString:String;
var
   I,RunLength:Cardinal;
   State:Boolean;
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   Result:='';    
   State:=False;
   RunLength:=0;
   for I:=0 to FCount-1 do  
   begin
      if State <> Bit[I+FBaseOffset] then
      begin
         if SL.Count = 0 then
            SL.Add(IntToStr(RunLength+FBaseOffset))
         else
            SL.Add(IntToStr(RunLength));
         RunLength:=0;
         State:=not State;
      end;
      Inc(RunLength);
   end;
   if State then
   begin
      SL.Add(IntToStr(RunLength));
   end
   else
   begin
      if SL.Count = 0 then SL.Add('0');
   end;
   Result:=SL.PackText;
   SL.Free;
end;
procedure TBitMapping.SetBit(Index:Cardinal;Value:Boolean);
var
   TempBits:PBits;
   IntIndex:Cardinal;
const
   FirstPass:Boolean = True;
begin
   if FirstPass then
   begin
      FBaseOffset:=0;
      FirstPass:=False;
   end;
   if Index >= FBaseOffset then
   begin
      Dec(Index,FBaseOffset);
      IntIndex:=(Index shr 5);
      if IntIndex >= (FCount shr 5) then
      begin
         GetMem(TempBits,(IntIndex+100)*SizeOf(Integer));
         ZeroMemory(TempBits,(IntIndex+100)*SizeOf(Integer));
         CopyMemory(TempBits,FBits,(FCount shr 5)*SizeOf(Integer));
         FreeMem(FBits);
         FBits:=TempBits;
         FCount:=(IntIndex+100) shl 5;
      end;
      if Value then
         FBits^[IntIndex]:=FBits^[IntIndex] or ($80000000 shr (Index and 31))
      else
         FBits^[IntIndex]:=FBits^[IntIndex] and (not ($80000000 shr (Index and 31)));
   end
end;
function TBitMapping.GetBit(Index:Cardinal):Boolean;
begin    
   if (Index >= FBaseOffset) then 
   begin
      Dec(Index,FBaseOffset);
      if (Index < FCount) then
         Result:=((FBits^[Index shr 5]) and ($80000000 shr (Index and 31))) <> 0
      else
         Result:=False;
   end
   else
      Result:=False;
end;   
procedure TBitMapping.SetFromString(Value:String);
var
   I:Integer;
   RL,RI:Integer;
   Ofs:Integer;
   SL:TPackStringList;
   State:Boolean;
begin
   if Value = '' then Exit;
   SL:=TPackStringList.Create;
   SL.PackText:=Value;
   State:=False;
   Ofs:=0;
   if SL.Count > 0 then
   begin
      Ofs:=StrToInt(SL[0]);
      SL[0]:='0';
   end;
   for I:=0 to SL.Count-1 do
   begin
      RL:=StrToInt(SL[I]);
      for RI:=0 to RL-1 do
      begin
         Bit[Ofs]:=State;
         Inc(Ofs);
      end;
      State:=not State;
   end;
   SL.Free;
end;
function TBitMapping.BitDifference(Value:String):String;
var
   BM:TBitMapping;
   I:Integer;
   S:String;
   MinIndex:Cardinal;
   MaxIndex:Cardinal;
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   Result:='';    
   S:=AsString;
   if S = Value then Exit;
   MinIndex:=FBaseOffset;
   MaxIndex:=Count+FBaseOffset;
   BM:=TBitMapping.Create;
   BM.SetFromString(Value);
   if MinIndex > BM.FBaseOffset then MinIndex:=BM.FBaseOffset;
   if MaxIndex < BM.Count+BM.FBaseOffset then MaxIndex:=BM.Count+BM.FBaseOffset;
   for I:=MinIndex to MaxIndex-1 do
   begin
      if Bit[I] and (BM[I] <> Bit[I]) then
         SL.Add(IntToStr(I));
   end;
   for I:=MinIndex to MaxIndex-1 do
   begin
      if BM[I] and (BM[I] <> Bit[I]) then
         SL.Add(IntToStr((-1)-I));
   end;
   BM.Free;
   Result:=SL.PackText;
   SL.Free;
end;

end.
