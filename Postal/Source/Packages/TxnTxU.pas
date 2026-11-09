unit TxnTxU;

interface

uses
  DBUtil, GPCSErrorLine,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBTables,DB,UDPMessageU,PackStrListU,GPCSGUID,Compress;

type
  TMessageRx = procedure (Data:String) of object;
  TRequestedData = class(TObject)
  private
     FMachineNo:Integer;
     FThisWSBits:TBBits;
     FTransmittedBits:TBBits;
     FBitsToTransmit:TBBits;
     FMaxTxBits:Integer;
  public
     constructor Create;
     destructor Destroy; override;
     procedure ProcessRequest(RequestBits:TBBits);
     procedure SetThisWSBits(Bits:TBBits);
     function GetTransmitdata:String;
     procedure MessageReset;
     property ThisWSBits     :TBBits  read FThisWSBits      write FThisWSBits     ;
     property MaxTxBits      :Integer read FMaxTxBits       write FMaxTxBits      ;
     property MachineNo:Integer read FMachineNo write FMachineNo;
  end;


  TRequestingData = class(TObject)
  private
     FMachineNo:Integer;
     FIPAddress:Integer;
     FMyViewOfWS:TBBits;
     FStatementOfWS:TBBits;
     FRequestedBits:TBBits;
  public
     constructor Create;
     destructor Destroy; override;
     procedure ProcessStatement(StatementBits:TBBits);
     procedure SetMyViewOfWS(Bits:TBBits);
     procedure MachineReset;
     function GetRequestBitmap:String;
     function GetStatusBitmap:String;
     property MachineNo:Integer read FMachineNo write FMachineNo;
     property IPAddress:Integer read FIPAddress write FIPAddress;
  end;

  TRequestingDataList = class(TObject)
  private
     FList:TList;
     function FindMachine(MachineNo:Integer):TRequestingData;
  public
     constructor Create;
     destructor Destroy; override;
     procedure ProcessStatement(MachineNo:Integer;StatementBits:TBBits);
     procedure RecordAdded(MachineNo,RecordID:Integer);
     procedure SetMyViewOfWS(MachineNo:Integer;Bits:TBBits);
     procedure MachineReset(IPAddress:Integer);
     function Count:Integer;
     function MachineNo(Index:Integer):Integer;
     function GetStatusBitmap(MachineNo:Integer):String;
     function GetRequestBitmap(MachineNo:Integer):String;
  end;

  TTransmitData = class(TObject)
  private
    FRD:TRequestedData;
    FRDList:TRequestingDataList;
    FMessageRx:TMessageRx;
    MessageServer:TMessageServer;
    procedure SetupMapOfLocalDB;
    procedure SendStatement;
    function Statement:String;
    procedure RxStatement(From,Value:String;MsgNumber:Integer);
    procedure ResetTxMesageQueue;
    procedure ResetRxMesageQueue(IPAddress:String);
  public
    constructor Create(MaxTxSize:Integer);
    destructor Destroy; override;
    function GetTxnData:String;
    procedure RecordsAddedLocally(FromID,ToID:Integer);
    function  NextFreeRecordID:Integer;
    procedure RecordAdded(WSNumber,RecordID:Integer);
    property MServer:TMessageServer read MessageServer;
    property  OnMessage:TMessageRx read FMessageRx write FMessageRx;
  end;

var
  LastPeriod:Integer;
  RxStatusString:String;
  
implementation
  
{TRequestedData}
constructor TRequestedData.Create;
begin
   inherited Create;
   FThisWSBits     :=TBBits.Create;
   FTransmittedBits:=TBBits.Create;
   FBitsToTransmit :=TBBits.Create;
   FMachineNo:=-1;
   FMaxTxBits:=100;
end;
destructor TRequestedData.Destroy;
begin
   FThisWSBits     .Free;
   FTransmittedBits.Free;
   FBitsToTransmit .Free;
   inherited Destroy;
end;
procedure TRequestedData.ProcessRequest(RequestBits:TBBits);
var
   I:Integer;
begin
   for I:=0 to RequestBits.Size do
   begin
      if RequestBits[I] then
      begin
         if FThisWSBits[I] and (not FTransmittedBits[I]) then
           FBitsToTransmit[I]:=True;
      end;
   end;
end;
procedure TRequestedData.SetThisWSBits(Bits:TBBits);
var
   I:Integer;
begin
   FThisWSBits.Free;
   FThisWSBits:=TBBits.Create;
   FThisWSBits.Size:=0;
   for I:=0 to Bits.Size do
      if Bits[I] then
         FThisWSBits[I]:=True;
end;
function TRequestedData.GetTransmitdata:String;
var
   I,J,K:Integer;
   Table:TTable;
//   RecordID:TField;
//   WSNumber:TField;
   SL :TPackStringList;
   RSL:TPackStringList;
   FoundRec:Integer;
   S:String;
begin
   Result:='';
   if FMachineNo =-1 then Exit;
   SL :=TPackStringList.Create;
   RSL:=TPackStringList.Create;

   I:=FBitsToTransmit.Size;
   J:=0;
   FoundRec:=-2;
   Table:=TTable.Create(nil);
   try
      with Table do
      begin
         TableName:='TXNLOG';                     
         if GetGPCSRegString('WorkStation','DBType','Paradox') <> 'Paradox' then
            Table.IndexName:='TXNLOG_PINDEX';
      
         if GetGPCSRegString('WorkStation','DBType','Paradox') = 'SQLServer' then
            Table.TableName   :='dbo.TXNLOG';
            
         DatabaseName:='PSL';
         Active:=True;
//         RecordID:=FieldByName('RecordID');
//         WSNumber:=FieldByName('WSNumber');

         while (I >= 0) and (J < FMaxTxBits) do
         begin
            if FBitsToTransmit[I] and (not FTransmittedBits[I]) then
            begin
               try
//                  SetKey;
//                  RecordID.Value:=I;
//                  WSNumber.Value:=FMachineNo;
                  if FindKey([I,FMachineNo]) then
//                  if GotoKey then
                     FoundRec:=I;
                  if FoundRec = I then
                  begin
                     try
                        for K:=0 to FieldCount-1 do
                        begin
                           if ((Fields[K] is TDateTimeField)
                           or  (Fields[K] is TTimeField)
                           or  (Fields[K] is TDateField)) then
                           begin
                             Str(Fields[K].Value,S);
                             RSL.Add(S);
                           end
                           else
                           begin
                             RSL.Add(Fields[K].AsString);
                           end;
                        end;
                        SL.Add(RSL.PackText);
                     except
                        on E:Exception do
                           RaiseGUIDException('{0375E21A-A47F-4CBB-898C-AA44850A66BD}',E);
                     end;
                     RSL.Clear;
                  end;
               except
                  on E:Exception do
                     RaiseGUIDException('{730498F3-8159-486D-888B-2D9D3DD1C752}',E);
               end;  
               FTransmittedBits[I]:=True;
               Inc(J);
            end;
            Dec(I);
         end;
         Active:=False;
      end;
   except
      on E:Exception do
         RaiseGUIDException('{ACF58D83-907A-4A6A-8FB0-19FB18285F08}',E);
   end;  
   Table.Free;
   Result:=SL.PackText;
   RxStatusString:=RunLengthEncode(FBitsToTransmit);
   SL .Free;
   RSL.Free;
end;
procedure TRequestedData.MessageReset;
//var
//   I:Integer;
begin
   FTransmittedBits.Free;
   FBitsToTransmit.Free;
   FTransmittedBits:=TBBits.Create;
   FBitsToTransmit:=TBBits.Create;
   FBitsToTransmit.Size:=0;
   FTransmittedBits.Size:=0;
//   for I:=0 to FTransmittedBits.Size do
//      if FTransmittedBits[I] then
//         FBitsToTransmit[I]:=False;
//   FTransmittedBits.Size:=0;
end;

{TRequestingData}
constructor TRequestingData.Create;
begin
   inherited Create;
   FMyViewOfWS:=TBBits.Create;
   FRequestedBits:=TBBits.Create;
   FStatementOfWS:=TBBits.Create;
end;
destructor TRequestingData.Destroy;
begin
   FMyViewOfWS.Free;
   FRequestedBits.Free;
   FStatementOfWS.Free;
   inherited Destroy;
end;
procedure TRequestingData.SetMyViewOfWS(Bits:TBBits);
var
   I:Integer;
begin
   FMyViewOfWS.Free;
   FMyViewOfWS:=TBBits.Create;
   FMyViewOfWS.Size:=0;
   for I:=0 to Bits.Size do
      if Bits[I] then
         FMyViewOfWS[I]:=True;
end;
procedure TRequestingData.ProcessStatement(StatementBits:TBBits);
var
   I:Integer;
begin
   FStatementOfWS.Free;
   FStatementOfWS:=TBBits.Create;
   FStatementOfWS.Size:=0;
   for I:=0 to StatementBits.Size do
      if StatementBits[I] then
         FStatementOfWS[I]:=True;
end;
function TRequestingData.GetRequestBitmap:String;
var
   I:Integer;
   RBits:TBBits;
begin
   Result:='';
   RBits:=TBBits.Create;
   for I:=0 to FStatementOfWS.Size do
   begin
      if FStatementOfWS[I] and (not FMyViewOfWS[I]) and (not FRequestedBits[I]) then
      begin
         FRequestedBits[I]:=True;
         RBits[I]:=True;
      end;
   end;
   if RBits.Size > 0 then
       Result:=RunLengthEncode(RBits);
   RBits.Free;
end;
function TRequestingData.GetStatusBitmap:String;
var
   I:Integer;
   RBits:TBBits;
begin
   Result:='';
   RBits:=TBBits.Create;
   for I:=0 to FStatementOfWS.Size do
   begin
      if FStatementOfWS[I] and (not FMyViewOfWS[I]) then
      begin
         RBits[I]:=True;
      end;
   end;
   if RBits.Size > 0 then
       Result:=RunLengthEncode(RBits);
   RBits.Free;
end;
procedure TRequestingData.MachineReset;
begin
   FRequestedBits.Free;
   FRequestedBits:=TBBits.Create;
   FRequestedBits.Size:=0;
end;
{TRequestingDataList}
constructor TRequestingDataList.Create;
begin
   inherited Create;
   FList:=TList.Create;
end;
destructor TRequestingDataList.Destroy;
var
   I:Integer;
begin
   for I:=0 to FList.Count-1 do
      TRequestingData(FList[I]).Free;
   FList.Free;
   inherited Destroy;
end;
function TRequestingDataList.FindMachine(MachineNo:Integer):TRequestingData;
var
   I:Integer;
begin
   for I:=0 to FList.Count-1 do
   begin
      if TRequestingData(FList[I]).MachineNo = MachineNo then
      begin
         Result:=TRequestingData(FList[I]);
         Exit;
      end;
   end;
   Result:=TRequestingData.Create;
   Result.MachineNo:=MachineNo;
   FList.Add(Result);
end;
procedure TRequestingDataList.RecordAdded(MachineNo,RecordID:Integer);
var
   RD:TRequestingData;
begin
   RD:=FindMachine(MachineNo);
   RD.FMyViewOfWS[RecordID]:=True;
end;
procedure TRequestingDataList.SetMyViewOfWS(MachineNo:Integer;Bits:TBBits);
var
   RD:TRequestingData;
begin
   RD:=FindMachine(MachineNo);
   RD.SetMyViewOfWS(Bits);
end;
procedure TRequestingDataList.ProcessStatement(MachineNo:Integer;StatementBits:TBBits);
var
   RD:TRequestingData;
begin
   RD:=FindMachine(MachineNo);
   RD.ProcessStatement(StatementBits);
end;
procedure TRequestingDataList.MachineReset(IPAddress:Integer);
var
   I:Integer;
   RD:TRequestingData;
begin
   for I:=0 to FList.Count-1 do
   begin
      RD:=TRequestingData(FList[I]);
      if RD.IPAddress = IPAddress then
      begin
         RD.MachineReset;
         Exit;
      end;
   end;
end;

function TRequestingDataList.GetStatusBitmap(MachineNo:Integer):String;
var
   RD:TRequestingData;
begin
   RD:=FindMachine(MachineNo);
   Result:=RD.GetStatusBitmap;
end;
function TRequestingDataList.GetRequestBitmap(MachineNo:Integer):String;
var
   RD:TRequestingData;
begin
   RD:=FindMachine(MachineNo);
   Result:=RD.GetRequestBitmap;
end;
function TRequestingDataList.Count:Integer;
begin
   Result:=FList.Count;
end;
function TRequestingDataList.MachineNo(Index:Integer):Integer;
begin
   if (Index >= 0) and (Index < FList.Count) then
      Result:=TRequestingData(FList[Index]).MachineNo
   else
      Result:=-1;
end;
{TTransmitData}
constructor TTransmitData.Create(MaxTxSize:Integer);
var
   WSNumber:Integer;
begin
   inherited Create;
   MessageServer:=TMessageServer.Create;
   WSNumber:=StrToInt(GetGPCSRegString('Workstation','Ident','0'));
   if WSNumber = 0 then
   begin
      if TBasicUDP(MessageServer.BasicUDPList[0]).HexIPAddress <> '7F000001' then
      begin
         WSNumber:=HexToIntDef(Copy(TBasicUDP(MessageServer.BasicUDPList[0]).HexIPAddress,7,2),0);
         if WSNumber <> 0 then
            SetGPCSRegString('Workstation','Ident',IntToStr(WSNumber));
      end;
   end;
   FRD:=TRequestedData.Create;
   FRD.MachineNo:=WSNumber;
   FRD.MaxTxBits:=MaxTxSize;
   FRDList:=TRequestingDataList.Create;
   SetupMapOfLocalDB;
   MessageServer.OnRxMessage:=RxStatement;
   MessageServer.OnNewStart:=ResetRxMesageQueue;
   MessageServer.OnClearMQ:=ResetTxMesageQueue;
   MessageServer.OnStatement:=SendStatement;
end;
destructor TTransmitData.Destroy;
begin
   MessageServer.Free;
   FRD.Free;
   FRDList.Free;
   inherited Destroy;
end;

procedure TTransmitData.SetupMapOfLocalDB;
var
  Query:TQuery;
  SL :TPackStringList;
  I:Integer;
  RecordID:TField;
  WSNumber:TField;
  LastWS:String;
  Index:Integer;
  RecordIDValue:String;
  WSNumberValue:String;
  KeepPeriod:Integer;
begin
  SL:=TPackStringList.Create;
  KeepPeriod:=StrToIntDef(GetGPCSRegString('','Transaction Periods To Keep','0'),0);
  LastPeriod := 0;
  if (KeepPeriod > 0) then
  begin
     Query:=TQuery.Create(nil);
     try
        try
           Query.DatabaseName:='PSL';
           SL.PackText:=QueryToPackText('Select max(period) from txnlog');
           if SL.Count > 0 then
           begin
              SL.PackText:=SL[0];
              if SL.Count > 0 then
              begin
                 LastPeriod:=StrToIntDef(SL[0],-1)-KeepPeriod;
              end;
           end;
        finally
           Query.Free;
        end;
     except
        on E : Exception do RaiseGUIDException('{55D96207-9FAE-42E1-A4CB-0711575A1960}',E);
     end;
  end;
  SL.Clear;
  Query:=TQuery.Create(nil);
  try
     with Query do
     begin
        DatabaseName := 'PSL';
        SL.AddObject(IntToStr(FRD.MachineNo),TBBits.Create);
        SQL.Text:='select RecordID,WSNumber from txnlog order by WSNumber,RecordID';
        Active:=True;
        First;
        RecordID:=FieldByName('RecordID');
        WSNumber:=FieldByName('WSNumber');
        LastWS:='';
        Index:=0;
        while not EOF do
        begin
           RecordIDValue:=RecordID.AsString;
           WSNumberValue:=WSNumber.AsString;
           if WSNumberValue <> '' then
           begin
              if LastWS <> WSNumberValue then
              begin
                 LastWS:=WSNumberValue;
                 Index:=SL.IndexOf(LastWS);
                 if Index = -1 then
                    Index:=SL.AddObject(LastWS,TBBits.Create);
              end;
              if RecordIDValue <> '' then
                 TBBits(SL.Objects[Index])[StrToInt(RecordIDValue)]:=True;
           end;
           Next;
        end;
        Active:=False;
     end;
  except
     on E:Exception do
        RaiseGUIDException('{F72270CE-5154-4219-A316-C7A6AD83AB6D}',E);
  end;  
  Query.Free;
  for I:=0 to SL.Count-1 do
  begin
     Index:=StrToIntDef(SL[I],0);
     if Index = FRD.MachineNo then
     begin
        FRD.SetThisWSBits(TBBits(SL.Objects[I]));
     end
     else
     begin
        FRDList.SetMyViewOfWS(Index,TBBits(SL.Objects[I]));
     end;
     TBBits(SL.Objects[I]).Free;
     SL.Objects[I]:=nil;
  end;
  SL.Free;
end;
function TTransmitData.Statement:String;
var
   SL:TPackStringList;
   RSL:TPackStringList;
   I:Integer;
   RB:String;
begin
   SL:=TPackStringList.Create;
   RSL:=TPackStringList.Create;
   SL.Add(IntToStr(FRD.MachineNo));
   SL.Add(RunLengthEncode(FRD.FThisWSBits));
   SL.Add(FRD.GetTransmitdata);
   SL.Add('*');
   for I:=0 to FRDList.Count-1 do
   begin
      RB:=FRDList.GetRequestBitmap(FRDList.MachineNo(I));
      if RB <> '' then
      begin
         RSL.PackText:=RB;
         RSL.Insert(0,IntToHex(FRDList.MachineNo(I),8));
         SL.Add(RSL.PackText);
      end;
      if FRDList.GetStatusBitmap(FRDList.MachineNo(I)) <> '' then
      begin
         if RxStatusString = '' then
            RxStatusString:=RxStatusString+'R'+IntToStr(FRDList.MachineNo(I))
         else
            RxStatusString:=RxStatusString+','+'R'+IntToStr(FRDList.MachineNo(I))
      end;
   end;
   SL.Add('*');
   Result:=TCompressor.CompressString(SL.PackText);
   SL.Clear;
   SL.Add(RxStatusString);
   SL.SaveToFile('C:\RxStatusString.txt');
   RSL.Free;
   SL.Free;
end;
procedure TTransmitData.SendStatement;
begin
   MessageServer.SendMessage(Statement);
end;
procedure TTransmitData.RxStatement(From,Value:String;MsgNumber:Integer);
var
   SL:TPackStringList;
   RSL:TPackStringList;
   I:Integer;
   Bits:TBBits;
   MNo:Integer;
   RD:TRequestingData;
begin
   if Value = '' Then Exit;
   SL:=TPackStringList.Create;
   RSL:=TPackStringList.Create;
   try
    //test for uncompressed data from an old transact
     if Integer(Value[1]) < 31 then
     begin
       SL.PackText:=Value;
       RaiseGUIDError('{D4059C36-8E7C-4F90-BA43-921E523F788D}',
         Format('Uncompressed data received from %d.%d.%d.%d',
                [ StrToInt('$' + Copy(From,1,2)),
                  StrToInt('$' + Copy(From,3,2)),
                  StrToInt('$' + Copy(From,5,2)),
                  StrToInt('$' + Copy(From,7,2))
                ]
       ));
     end
     else
       SL.PackText:=TCompressor.DeCompressString(Value);
   except
    On E : Exception do
    begin
     SL.PackText:=Value;
     RaiseGUIDException('{D4059C36-8E7C-4F90-BA43-921E523F788D}', E);
    end;
   end;

   if SL.Count > 2 then // Records to add
   begin
      MNo:=StrToIntDef(SL[0],-1);
      RD:=FRDList.FindMachine(MNo);
      if RD <> nil then
      begin
         RD.IPAddress:=StrToInt('$'+From);
         if SL[1] <> '' then
         begin
            Bits:=TBBits.Create;
            RD.ProcessStatement(RunLengthDecode(SL[1],Bits,False));
            Bits.Free;
         end;
      end;
      if (Mno >= 0) and (SL[2] <> '') then
         if Assigned(FMessageRx) then FMessageRx(SL[2]);
   end;
   for I:=3 to SL.Count-1 do
   begin
      if SL[I] <> '*' then
      begin
         RSL.PackText:=SL[I];
         if (RSL.Count > 0) and (StrToIntDef('$'+RSL[0],-1) = FRD.MachineNo) then
         begin
            RSL.Delete(0);
            Bits:=TBBits.Create;
            FRD.ProcessRequest(RunLengthDecode(RSL.PackText,Bits,False));
            Bits.Free;
            break;
         end;
      end;
   end;
   SL.Free;
   RSL.Free;
end;
procedure TTransmitData.ResetTxMesageQueue;
begin
   FRD.MessageReset;
end;
procedure TTransmitData.ResetRxMesageQueue(IPAddress:String);
begin
   FRDList.MachineReset(StrToInt('$'+IPAddress));
end;
procedure TTransmitData.RecordAdded(WSNumber,RecordID:Integer);
begin
   if WSNumber <> FRD.MachineNo then
      FRDList.RecordAdded(WSNumber,RecordID);
end;
procedure TTransmitData.RecordsAddedLocally(FromID,ToID:Integer);
var
   I:Integer;
begin
   for I:=FromID to ToID do
   begin
      FRD.ThisWSBits[I]:=True;
      FRD.FBitsToTransmit[I]:=True;
   end;
end;
function TTransmitData.NextFreeRecordID:Integer;
begin
   Result:=FRD.ThisWSBits.Size;
end;
function TTransmitData.GetTxnData:String;
var
  I:Integer;
  SL:TPackStringList;
  RSL:TPackStringList;
begin
  SL :=TPackStringList.Create;
  RSL:=TPackStringList.Create;
  RSL.PackText:=RunLengthEncode(FRD.ThisWSBits);
  RSL.Insert(0,IntToHex(FRD.MachineNo,4));
  SL.Add(RSL.PackText);
  for I:=0 to FRDList.Count-1 do
  begin
     RSL.PackText:=RunLengthEncode(FRDList.FindMachine(FRDList.MachineNo(I)).FMyViewOfWS);
     RSL.Insert(0,IntToHex(FRDList.MachineNo(I),4));
     SL.Add(RSL.PackText);
  end;
  Result:=SL.PackText;
  RSL.Free;
  SL.Free;
end;

end.
