unit UDPMessageU;

interface

uses
  Math,
  DBUtil,Db,DbTables,Windows,Messages,Graphics,Forms,SysUtils,Classes,WinSock,ExtCtrls,Dialogs,
  CRC32,Compress,PackStrListU,GPCSGUID,GPCSErrorLine,StringUtil,Registry;

const
   WM_RXDATAGRAM         = WM_USER+1;
   INADDR_BROADCAST      = -1;
   DGPortNumber          = 45020;
   TimeForPingReset      = 3;
   TimeForPing:Integer   = TimeForPingReset;
   TimeForTStampReset    = 60;
   TimeForTStamp:Integer = TimeForTStampReset;
   DataCompressed        = True;
   SendFrameSize             :Integer = 16280; // 16280;
   MaxRecordTxRecords    :Integer = 1000;
type
  TMessageStatus = (msReset,msOK,msIgnore,msQuit);
  TBBits = class(TBits)
  private
      function GetBit(Index:Integer):Boolean;
      procedure SetBit(Index:Integer;Value:Boolean);
  public
      property Bits[Index:Integer]:Boolean read GetBit write SetBit; default;
  end;

  TTransactionBits = class(TObject)
  private
     FMyBits:String;
     FNextFreeIdent:Integer;
     FWSNumber:Integer;
     FAllMachinesBits:String;
     function GetTxnData:String;
     function GeTBBits:String;
  public
     function Difference(Data:String):String;
     property AllMachinesBits:String read GeTBBits;
     property WSNumber:Integer read FWSNumber write FWSNumber;
     property MyBits:String read FMyBits write FMyBits; // the bitmap of transactions for this W/S
     property NextFreeIdent:Integer read FNextFreeIdent write FNextFreeIdent;
  end;
  TBasicUDP = class;
  TUDPEvent = procedure (Sender:TBasicUDP;EMessage:String) of object;
  TRxEvent = procedure (Sender:TBasicUDP;From,TimeStamp,Data:String) of object;
  TRxMessage = procedure (From,Data:String;MsgNumber:Integer) of object;
  TMessageRx = procedure (Data:String) of object;
  TNewStart  = procedure (From:String) of object;
  TEmptyProc = procedure of object;

  TBasicUDP = class(TObject)
  private
    FActive:Boolean;
    FTimeStamp:String;
    FPortNumber:Integer;
    FReuseAddr:Boolean;
    FHSocket:TSocket;
    FDramSocket:TSocket;
    FWindowHandle:THandle;
    FOnError:TUDPEvent;
    FOnRxDGram:TRxEvent;
    FRxOwn:Boolean;
  protected
    procedure WndProc(var Msg: TMessage);
    procedure RxDataGram(var Msg: TMessage); message WM_RXDATAGRAM;
    procedure SetActive(Value:Boolean); virtual;
    procedure SetPortNumber(Value:Integer);
  public
    constructor Create;
    destructor  Destroy; override;
    function    HexIPAddress:String;
    function    SendDGram(Data:String):Boolean; virtual;
    function    SendQuitMessage:Boolean; virtual;
    property    Active    :Boolean   read FActive     write SetActive   ;
    property    PortNumber:Integer   read FPortNumber write SetPortNumber ;
    property    RxOwn     :Boolean   read FRxOwn      write FRxOwn      ;
    property    TimeStamp :String    read FTimeStamp  write FTimeStamp  ;
    property    OnError   :TUDPEvent read FOnError    write FOnError    ;
    property    OnRxDGram :TRxEvent  read FOnRxDGram  write FOnRxDGram  ;
    property    ReuseAddr :Boolean   read FReuseAddr  write FReuseAddr  ;
  end;                     

  TMessageFrames = class(TObject)
  private
     FData      :String ;
     FrameSize  :Integer;
     FLength    :Integer;
     FFrameCount:Integer;
     FFrameData :TBBits  ;
     FComplete  :Boolean;
     FMsgNumber :Integer;
  published
     function GetFrameData(Index:Integer):String;
     procedure SetData(Value:String);
     procedure AddFrame(Value:String);
     function Missing:String;
  public
     constructor Create;
     destructor Destroy; override;
     property Complete  :Boolean read FComplete;
     property Data      :String  read FData write SetData;
     property DataLength:Integer read FLength;
     property FrameData [Index:Integer]:String read GetFrameData; default;
     property FrameCount:Integer read FFrameCount;
     property MsgNumber :Integer read FMsgNumber write FMsgNumber;
  end;

  TMessageList = class(TObject)
  private
     FMsgs:TList;
     FShouldBeUpTo:Integer;
     FRxedMessages:TBBits;
     FCompleteMessages:TBBits;
     FBelongsTo:String;
     FReceivedDataSize:Integer;
     function GetMsg(Index:Integer):TMessageFrames;
     function GetCount:Integer;
  public
     constructor Create;
     destructor Destroy; override;
     function IndexOf(MsgNumber:Integer):Integer;
     function Add(Msg:TMessageFrames):Integer;
     procedure Delete(Index:Integer);
     property Msg[Index:Integer]:TMessageFrames read GetMsg; default;
     property Count:Integer read GetCount;
     property ShouldBeUpTo:Integer read FShouldBeUpTo write FShouldBeUpTo;
     property RxedMessages:TBBits read FRxedMessages write FRxedMessages;
     property CompleteMessages:TBBits read FCompleteMessages write FCompleteMessages;
     property BelongsTo:String read FBelongsTo write FBelongsTo;
     property ReceivedDataSize:Integer read FReceivedDataSize write FReceivedDataSize;
  end;

  TMachineList = class(TObject)
  private
     FMachines:TStringList;
     function GetMsgList(Index:Integer):TMessageList;
     function GetMNumb(Index:Integer):String;
     function GetCount:Integer;
  public
     constructor Create;
     destructor Destroy; override;
     function IndexOf(MachineNumber:Integer):Integer;
     function Add(MachineNumber:Integer;MsgList:TMessageList):Integer;
     procedure Delete(Index:Integer);
     property MsgList[Index:Integer]:TMessageList read GetMsgList; default;
     property MNumber[Index:Integer]:String read GetMNumb;
     property Count:Integer read GetCount;
  end;

  TMessageServer = class(TObject)
  private
     TSList:TStringList;
     StatList:TStringList;
     LastRX:Integer;
     SendingTo:TStringList;
     FMsgNumber:Integer;
     FRxList:TMachineList;
     FTxList:TMessageList;
     FTxQueue:TStringList;
     FOnRxMessage:TRxMessage;
     FOnNewStart:TNewStart;
     CheckTimer:TTimer;
     FPaintBox:TPaintBox;
     FOnClearMQ:TEmptyProc;
     FOnStatement:TEmptyProc;
     procedure TimerCheck(Sender: TObject);
     procedure RxDGram(Sender:TBasicUDP;From,TimeStamp,Data:String);
     procedure DGramError(Sender:TBasicUDP;EMessage:String);
     procedure AddToQueue(MF:TMessageFrames;AndSend:Boolean);
     function  CheckTxQueue:Boolean;
     procedure ProcessRequest(Data:String);
     function  CheckRxMessageTS(From,TimeStamp:String;MessageNumber:Integer):TMessageStatus;
     procedure PaintBoxPaint(Sender: TObject);
     procedure SetPBBounds;
  public
     BasicUDPList:TList;
     constructor Create;
     destructor Destroy; override;
     procedure SendMessage(Data:String);
     procedure ClearRxMessages(From:String);
     procedure DrawOn(PaintBox:TPaintBox);
     property MachineList:TMachineList read FRxList write FRxList;
     property OnRxMessage:TRxMessage read FOnRxMessage write FOnRxMessage;
     property OnNewStart:TNewStart   read FOnNewStart  write FOnNewStart;
     property OnClearMQ:TEmptyProc read FOnClearMQ write FOnClearMQ;
     property OnStatement:TEmptyProc read FOnStatement write FOnStatement;
  end;
  TTxnMsgSvr = class(TObject)
  private
     FTxnBits:TTransactionBits;
     MessageServer:TMessageServer;
     FMessageRx:TMessageRx;
     procedure RxStatement(Data:String);
     procedure NewStart(From:String);
  public
     constructor Create;
     destructor Destroy; override;
     procedure RecordAdded(WSNumber,RecordID:Integer);
     procedure SendMessage(Data:String);
     procedure MessageServerRx(From,Data:String;MsgNumber:Integer);
     function NextFreeIdent:Integer;
     procedure RecNotify(StartIdent,EndIdent:Integer);
     function GetTxnData:String;
     property MServer:TMessageServer read MessageServer;
     property OnMessage:TMessageRx read FMessageRx write FMessageRx;
  end;

function HexToIntDef(Value:String;Default:Integer):Integer;
function RunLengthDecode(Data:String;var Bits:TBBits;WithWS:Boolean):TBBits;
function RunLengthEncode(Bits:TBBits):String;
function BitsWidth(RLE:String):Integer;
function BitsToBitmap(RLE:String;Height,MaxBitWidth,DisplayWidth:Integer):TBitmap;
function OSVersion:String;

implementation
{TBBits}
function TBBits.GetBit(Index:Integer):Boolean;
//checks array extents first
begin
  Result:=False;
  try
    if (Index >= 0) and (Index < Size) then
      Result:=inherited Bits[Index]
  except
    On E : Exception do
      RaiseGUIDException( '{15704DF4-1F61-4746-A59A-EC6DDE4EF10B} ' + Application.Exename, E);
  end;
end;

procedure TBBits.SetBit(Index:Integer;Value:Boolean);
//checks index first
begin
  try
    if (Index >= 0) then
      inherited Bits[Index]:=Value;
  except
    On E : Exception do
      RaiseGUIDException( '{2E16BEC8-2004-41DF-AA46-158EE573BA6E}'+ Application.ExeName , E);
  end;

end;


function TTransactionBits.Difference(Data:String):String;
//returns bitmap of differences between current bits and data bits passed
var
  BitsA,BitsB  : TBBits;
  I,MaxBits    : Integer;
  SQLText      : String;
  SL           : TPackStringList;
  CurrentOfs   : Integer;
begin
  try
    Result :=  '';
    BitsA  :=  TBBits.Create;
    BitsB  :=  TBBits.Create;
    try
      RunLengthDecode(Data,BitsA,True);
      RunLengthDecode(FMyBits,BitsB,True);
      for I:=0 to BitsB.Size do
      begin
        if ((BitsB[I]) and (BitsA[I])) then // they have record already
           BitsB[I]:=False;
      end;
      SL:=TPackStringList.Create;
      SL.PackText:=RunLengthEncode(BitsB);
      if (SL.Count and 1) = 1 then
        SL.Delete(SL.Count-1);
    finally
      BitsB.Free;
      BitsA.Free;
    end;
    SQLText:='Select * from Txnlog where (WSNumber = '+IntToStr(FWSNumber)+') and (';
    CurrentOfs:=0;
    if SL.Count = 0 then Exit;
    MaxBits:=0;
    for I:=0 to SL.Count-1 do
    begin
      if ((I and 1) = 0) then // range of no records
      begin
         CurrentOfs:=CurrentOfs+StrToIntDef(SL[I],0);
         SQLText:=SQLText+'((RecordID >= '+IntToStr(CurrentOfs)+') and ';
      end
      else // range of records
      begin
         if MaxBits+StrToIntDef(SL[I],0) > 100 then
         begin
            CurrentOfs:=CurrentOfs+100-MaxBits;
         end
         else
         begin
            CurrentOfs:=CurrentOfs+StrToIntDef(SL[I],0);
         end;
         MaxBits:=MaxBits+StrToIntDef(SL[I],0);
         SQLText:=SQLText+'(RecordID < '+IntToStr(CurrentOfs)+'))';
         if MaxBits > 100 then
            Break;
      end;
      if (I < SL.Count-2) and ((I and 1) = 1) then
         SQLText:=SQLText+' or ';
    end;
    SL.Free;
    Result:=QueryToPackText(SQLText+')');
  except
    On E : Exception do
      RaiseGUIDException( '{4E26BEFC-599D-41F3-B391-8BF1ABAEE032}'+ Application.ExeName , E);
  end;


end;

function TTransactionBits.GeTBBits:String;
begin
  try
    if FAllMachinesBits = '' then
     FAllMachinesBits:=GetTxnData;
    Result:=FAllMachinesBits;
  except
    On E : Exception do
      RaiseGUIDException( '{85B88CB6-7D10-401F-B4E7-007F5A0CF450}' + Application.ExeName, E);
  end;
end;

function TTransactionBits.GetTxnData:String;
var
  Query:TQuery;
  SL:TPackStringList;
  RSL:TPackStringList;
  I:Integer;
  RecordID:TField;
  WSNumber:TField;
  LastWS:String;
  Index:Integer;
  LastPeriod:String;
  KeepPeriod:Integer;
begin
  try
    SL:=TPackStringList.Create;
    Query:=TQuery.Create(nil);
    try
       with Query do
       begin
          DatabaseName:='PSL';
          KeepPeriod:=StrToIntDef(GetGPCSRegString('','Transaction Periods To Keep','0'),0);
          if (KeepPeriod > 0) then
          begin
             SL.PackText:=QueryToPackText('Select distinct period from txnlog order by Period');
             if SL.Count > KeepPeriod then
             begin
                SL.PackText:=SL[SL.Count-KeepPeriod];
                LastPeriod:=SL[0];
                Query.SQL.Text:='delete from txnlog where Period < '+LastPeriod;
                Query.ExecSQL;
             end;
             SL.Clear;
          end;
          SQL.Text:='select RecordID,WSNumber from txnlog order by WSNumber,RecordID';
          Active:=True;
          First;
          RecordID:=FieldByName('RecordID');
          WSNumber:=FieldByName('WSNumber');
          LastWS:='';
          Index:=0;
          while not EOF do
          begin
             if WSNumber.AsString <> '' then
             begin
                if LastWS <> WSNumber.AsString then
                begin
                   LastWS:=WSNumber.AsString;
                   Index:=SL.IndexOf(LastWS);
                   if Index = -1 then
                      Index:=SL.AddObject(LastWS,TBBits.Create);
                end;
                if RecordID.AsString <> '' then
                   TBBits(SL.Objects[Index])[RecordID.AsInteger]:=True;
             end;
             Next;
          end;
          Active:=False;
       end;
    except
       on E:Exception do
          RaiseGUIDException('{8D7A0EA1-62A4-407F-986F-DE9813AB97C7}',E);
    end;
    Query.Free;
    RSL:=TPackStringList.Create;
    for I:=0 to SL.Count-1 do
    begin
       Index:=StrToIntDef(SL[I],0);
       RSL.PackText:=RunLengthEncode(TBBits(SL.Objects[I]));
       RSL.Insert(0,IntToHex(Index,4));
       SL[I]:=RSL.PackText;
       if Index = FWSNumber then
       begin
          FMyBits:=SL[I];
          NextFreeIdent:=TBBits(SL.Objects[I]).Size;
       end;
       TBBits(SL.Objects[I]).Free;
       SL.Objects[I]:=nil;
    end;
    RSL.Free;
    Result:=SL.PackText;
    SL.Free;
  except
    On E : Exception do
      RaiseGUIDException( '{850A73E6-3C44-463F-830D-5E36667F626E}'+ Application.ExeName , E);
  end;
end;

function HexToIntDef(Value:String;Default:Integer):Integer;
begin
   Result:=StrToIntDef('$'+Value,Default);
end;

function TimeInSeconds(Present:TDateTime):Integer;
begin
  // 60*60*24 number of 1 seconds in a day
  // overflows on 16/03/2130 at 12:56:30
  Result:=Trunc((Now-DaysUntil_010198)*86400)
end;

{TMessageServer}
function OSVersion:String;
var
   VI:TOSVERSIONINFOA;
begin
  try
    Result:='';
    ZeroMemory(@VI,sizeof(TOSVERSIONINFOA));
    VI.dwOSVersionInfoSize:=sizeof(TOSVERSIONINFOA);
    GetVersionEx(VI);

    case VI.dwPlatformId of
      1 : begin
             case VI.dwMinorVersion of
                 0  : Result:='95';
                 10 : Result:='98';
                 90 : Result:='Me';
                 else Result:='16';
             end;
          end;
      2 : begin
             case VI.dwMajorVersion of
                 4  : Result:='NT';
                 5  : begin
                         case VI.dwMinorVersion of
                            0  : Result:='2K';
                            1  : Result:='XP';
                            else Result:='32';
                         end;
                      end;
                 else Result:='32';
             end;
          end;
      else Result:='64';
    end;
    Result:=Result+' B'+IntToStr(VI.dwBuildNumber );
  except
    On E : Exception do
      RaiseGUIDException( '{A3E28A73-613C-484B-AA13-20AFB1E6872A}' + Application.ExeName, E);
  end;
end;

constructor TMessageServer.Create;
var
   I:Integer;
   PN:Integer;
   SL:TStringList;
   S:String;
   BasicUDP:TBasicUDP;
begin
  try
    inherited Create;

    //   ShowMessage(OSVersion);

    BasicUDPList:=TList.Create;
    S:=GetGPCSRegString('UDP','Port Number','-1');
    if S = '-1' then
    begin
      S:=IntToStr(DGPortNumber);
      GetGPCSRegString('UDP','Port Number',S);
    end;
    SL:=TStringList.Create;
    SL.CommaText:=S;
    for I:=0 to SL.Count-1 do
    begin
      PN:=StrToIntDef(SL[I],0);
      if PN > 0 then
      begin
         BasicUDP:=TBasicUDP.Create;
         BasicUDP.OnRxDGram:=RxDGram   ;
         BasicUDP.OnError  :=DGramError;
         BasicUDP.RxOwn    :=False;
         BasicUDP.PortNumber:=PN;
         BasicUDPList.Add(BasicUDP);
      end
      else
         RaiseGUIDError('{E8F5E55B-F97B-43F4-A59F-1E40A17D1584}','Bad UDP Port Number '+SL[I]);
    end;
    // no valid integer values found
    if BasicUDPList.Count = 0 then
    begin
      BasicUDP:=TBasicUDP.Create;
      BasicUDP.OnRxDGram:=RxDGram   ;
      BasicUDP.OnError  :=DGramError;
      BasicUDP.RxOwn    :=False;
      BasicUDP.PortNumber:=DGPortNumber;
      BasicUDPList.Add(BasicUDP);
      RaiseGUIDError('{39DDD572-FA1D-4C72-8AB8-B76AFA441A25}','No Valid UDP Port Number, Using '+IntToStr(DGPortNumber));
    end;
    SL.Free;
    FPaintBox:=nil;
    SendingTo:=TStringList.Create;
    FRxList :=TMachineList.Create;
    FTxList :=TMessageList.Create;
    FTxQueue:=TStringList.Create;
    CheckTimer:=TTimer.Create(nil);
    CheckTimer.Enabled:=False;
    CheckTimer.Interval:=1000;
    CheckTimer.OnTimer:=TimerCheck;
    FMsgNumber:=0;
    StatList:=TStringList.Create;
    if FileExists('C:\StatList.txt') then
    begin
      if (GetTodayAsPeriod mod 7) = 0 then // reset every 7 days
         StatList.LoadFromFile('C:\StatList.txt');
    end;
    TSList:=TStringList.Create;
    if FileExists('C:\TSList.txt') then
    begin
      TSList.LoadFromFile('C:\TSList.txt');
      for I:=0 to TSList.Count-1 do
      begin
         TSList.Objects[I]:=TStringObject.Create(TSList[I]);
         TSList[I]:=Copy(TSList[I],1,8);
      end;
    end;
    for I:=0 to BasicUDPList.Count-1 do
      TBasicUDP(BasicUDPList[I]).Active:=True;
    CheckTimer.Enabled:=True;
  except
    On E : Exception do
      RaiseGUIDException('{AB147418-D0AE-4828-91BD-A68B7169ECF8}' + Application.ExeName , E);
  end;
end;

destructor TMessageServer.Destroy;
var
   I:Integer;
   MI:Integer;
   MsgList:TMessageList;
   S:String;
begin
  try
    for I:=0 to TSList.Count-1 do
    begin
      if TSList.Objects[I] <> nil then
      begin
         MI:=FRxList.IndexOf(HexToIntDef(TSList[I],-1));
         if (MI >= 0) then
         begin
            MsgList:=FRxList[MI];
            S:=TStringObject(TSList.Objects[I]).Value;
            TStringObject(TSList.Objects[I]).Free;
            TSList[I]:=Copy(S,1,16)+RunLengthEncode(MsgList.CompleteMessages);
         end;
      end;
    end;
    if TSList.Count > 0 then
      TSList.SaveToFile('C:\TSList.txt');
    TSList.Free;

    StatList.Free;

    SendingTo.Free;
    CheckTimer.Enabled:=False;
    CheckTimer.Free;
    for I:=0 to BasicUDPList.Count-1 do
      TBasicUDP(BasicUDPList[I]).Free;
    BasicUDPList.Free;
    FRxList .Free;
    FTxList .Free;
    FTxQueue.Free;
    inherited Destroy;
  except
    On E : Exception do
      RaiseGUIDException( '{A094F3A8-8C43-43AF-AF6E-A90D88133296}'+ Application.ExeName , E);
  end;
end;

function BitsWidth(RLE:String):Integer;
var
   I:Integer;
   SL:TPackStringList;
begin
  Result:=0;
  try
    SL:=TPackStringList.Create;
    SL.PackText:=RLE;
    for I:=0 to SL.Count-1 do
      Inc(Result,StrToIntDef(SL[I],0));
    SL.Free;
  except
    On E : Exception do
      RaiseGUIDException( '{280AF307-15EA-4AA5-BCD8-E5A487FD1FE6}'+ Application.ExeName , E);
  end;
end;
function BitsToBitmap(RLE:String;Height,MaxBitWidth,DisplayWidth:Integer):TBitmap;
var
   I,J:Integer;
   MW:Integer;
   SL:TPackStringList;
   X1,X2:Integer;
begin
  Result:=TBitmap.Create;
  try
    SL:=TPackStringList.Create;
    SL.PackText:=RLE;
    MW:=0;
    for I:=0 to SL.Count-1 do
      Inc(MW,StrToIntDef(SL[I],0));
    MW:=(MW*DisplayWidth) div MaxBitWidth;
    Result.Width:=MW;
    Result.Height:=Height;
    Result.Canvas.Brush.Color:=clWhite;
    Result.Canvas.FillRect(Bounds(0,0,MW,Height));
    Result.Canvas.Brush.Color:=clBlack;
    J:=0;
    X2:=0;
    for I:=0 to SL.Count-1 do
    begin
      X1:=X2;
      Inc(J,StrToIntDef(SL[I],0));
      X2:=(J*DisplayWidth) div MaxBitWidth;
      if (I and 1) = 1 then
         Result.Canvas.FillRect(Rect(X1,0,X2,Height));
    end;
    SL.Free;
  except
    On E : Exception do
      RaiseGUIDException( '{BFBB5148-A2A9-4FAB-8FDF-838BA5F5AD12}' + Application.ExeName, E);
  end;
end;

procedure TMessageServer.SetPBBounds;
var
   I:Integer;
   MsgList:TMessageList;
   MW:Integer;
   LO,LH:Integer;
begin
  try
    if FPaintBox = nil then Exit;
    MW:=0;
    LO:=0;
    for I:=0 to MachineList.Count-1 do
    begin
      MsgList:=MachineList.MsgList[I];
      if MW < MsgList.ShouldBeUpTo then
         MW:=MsgList.CompleteMessages.Size;
      LH:=FPaintBox.Canvas.TextWidth(MsgList.BelongsTo+' ['+IntToStr(MsgList.ReceivedDataSize)+']');
      if LH > LO then LO:=LH;
    end;
    MW:=(((MW+LO+11) div 100)+1)*100;
    if (FPaintBox.Width <> MW) or (FPaintBox.Height <> (MachineList.Count*FPaintBox.Canvas.TextHeight('Wg'))) then
      FPaintBox.SetBounds(0,0,MW,MachineList.Count*FPaintBox.Canvas.TextHeight('Wg'));
    FPaintBox.Invalidate;
  except
    On E : Exception do
      RaiseGUIDException( '{9B9E7E24-12A1-4116-B002-B446457C81E6}' + Application.ExeName, E);
  end;
end;

procedure TMessageServer.PaintBoxPaint(Sender: TObject);
var
  I,J         : Integer;
  MsgList     : TMessageList;
  LabelHeight : Integer;
  LabelWidth  : Integer;
begin
  try
    if FPaintBox = nil then Exit;
    with FPaintBox.Canvas do
    begin

      //get max width of info label
      LabelWidth := 0;
      for I := 0 to MachineList.Count-1 do
      begin
        MsgList := MachineList.MsgList[I];  //grab a meesage list
        LabelWidth := MaxIntValue([LabelWidth, TextWidth(MsgList.BelongsTo+' ['+IntToStr(MsgList.ReceivedDataSize)+']')]);
      end;
      LabelHeight := TextHeight('Wg');
      Inc(LabelWidth, 10); //gap

      //blank the canvas
      Brush.Color:=clWhite;
      FillRect(Bounds(0, 0, FPaintBox.Width, FPaintBox.Height));

      //got through each machine
      for I:=0 to MachineList.Count-1 do
      begin
        MsgList :=  MachineList.MsgList[I]; //grab a message list
        TextOut(0, I*LabelHeight, MsgList.BelongsTo + ' ['+IntToStr(MsgList.ReceivedDataSize)+']');  //label

        //go through all messages up to 'ShouldBeUpTo (highest received?)
        for J:=0 to MsgList.ShouldBeUpTo do
        begin

          if MsgList.CompleteMessages[J] then //message has all frames
          begin
             Pen.Color:=clBlack;
             Rectangle(LabelWidth+J, I*LabelHeight, LabelWidth+1+J, (I*LabelHeight)+LabelHeight div 2);
          end;  //if message complete

          if not MsgList.RxedMessages[J] then // message has missing frame(s) or is completely missing?
          begin
             Pen.Color:=clRed;
             Rectangle(LabelWidth + J,
                       I*LabelHeight + (LabelHeight div 2), //bottom half of bar
                       LabelWidth+1+J,
                       (I+1)*LabelHeight);
          end;  //if missing frames
        end;  //for all messages
      end;
    end;
  except
    On E : Exception do
      RaiseGUIDException( '{DBE4CE93-36F8-497A-AC21-7BF19D5D7213}' + Application.ExeName, E);
  end;
end;

procedure TMessageServer.TimerCheck(Sender: TObject);
var
   I,J,K,Index:Integer;
   MsgList:TMessageList;
   MRS:String;
   MF:TMessageFrames;
   SLUpdated:Boolean;
begin
  try
    CheckTimer.Enabled:=False;
    SLUpdated:=False;
    for Index:=0 to StatList.Count-1 do
    begin
      if Copy(StatList[Index],1,1) = '1' then // have received message this session
      begin
         I:=Integer(StatList.Objects[Index]);
         if I = 0 then
         begin
            StatList[Index]:='2'+Copy(StatList[Index],2,Length(StatList[Index]));
            SLUpdated:=True;
         end
         else
         begin
            Dec(I); // decrease timeout
            StatList.Objects[Index]:=TObject(I);
         end;
      end;
    end;
    if SLUpdated then
      StatList.SaveToFile('C:\StatList.txt');

    Dec(TimeForPing);
    Dec(TimeForTStamp);
    if TimeForTStamp < 1 then
    begin
      TimeForTStamp:=TimeForTStampReset;
      for I:=0 to BasicUDPList.Count-1 do
         TBasicUDP(BasicUDPList[I]).Active:=False;
      FMsgNumber:=0;
      FTxList.Free;
      FTxList:=TMessageList.Create;
      FTxQueue.Free;
      FTxQueue:=TStringList.Create;
      for I:=0 to BasicUDPList.Count-1 do
      begin
         TBasicUDP(BasicUDPList[I]).TimeStamp:=IntToHex(TimeInSeconds(Now),8);
         TBasicUDP(BasicUDPList[I]).Active:=True;
      end;
      TimeForPing:=0;
      if Assigned(FOnClearMQ) then FOnClearMQ;
    end;
    if TimeForPing < 1 then
    begin
      TimeForPing:=TimeForPingReset;
      MF:=TMessageFrames.Create;
      MF.Data:='!!!!!'+GetLocalMachineName;
      MF.MsgNumber:=FMsgNumber;
      Inc(FMsgNumber);
      FTxList.Add(MF);
      for I:=0 to MF.FrameCount-1 do
      begin
         if FTxQueue.IndexOf(MF.FrameData[I]) = -1 then
            FTxQueue.Add(MF.FrameData[I]);
      end;
      if Assigned(FOnStatement) then FOnStatement;
    end;
    if (not CheckTxQueue) and (LastRX <> TimeInSeconds(Now)) then
    begin
      if FRxList.Count > 0 then
      begin
         for I:=0 to FRxList.Count-1 do // each machine
         begin
            MsgList:=FRxList[I];
            if MsgList.RxedMessages.OpenBit < MsgList.ShouldBeUpTo then
            begin
               MRS:=RunLengthEncode(MsgList.RxedMessages);
               for K:=0 to BasicUDPList.Count-1 do
               begin
                  while not TBasicUDP(BasicUDPList[K]).SendDGram('R'+FRxList.MNumber[I]+'RXED'+MRS) do
                     Application.ProcessMessages;
               end;
            end;
         end;
      end;
      for I:=0 to FRxList.Count-1 do
      begin
         MsgList:=FRxList[I];
         for J:=0 to MsgList.Count-1 do
         begin
            if not MsgList[J].Complete then
            begin
               for K:=0 to BasicUDPList.Count-1 do
               begin
                  while not TBasicUDP(BasicUDPList[K]).SendDGram('R'+FRxList.MNumber[I]+MsgList[J].Missing) do
                     Application.ProcessMessages;
               end;
            end;
         end;
      end;
    end;
    CheckTimer.Enabled:=True;
    if FPaintBox <> nil then
      SetPBBounds;
  except
    On E : Exception do
      RaiseGUIDException( '{CCBBDAB1-D65D-4EEE-9911-80E2273C23F7}' + Application.ExeName , E);
  end;
end;

procedure TMessageServer.SendMessage(Data:String);
var
   MF:TMessageFrames;
begin
  try
    //   TimeForPing:=TimeForPingReset;
    MF:=TMessageFrames.Create;
    MF.Data:=Data;
    MF.MsgNumber:=FMsgNumber;
    Inc(FMsgNumber);
    FTxList.Add(MF);
    AddToQueue(MF,True);
  except
    On E : Exception do
      RaiseGUIDException( '{EB18D554-CB74-42D2-B831-1EDC7FD21884}' + Application.ExeName, E);
  end;
end;

function TMessageServer.CheckTxQueue:Boolean;
var
   J,K:Integer;
begin
  Result:=False;
  try
    if FTxQueue.Count = 0 then Exit;
    while FTxQueue.Count > 0 do
    begin
      J:=0;
      for K:=0 to BasicUDPList.Count-1 do
      begin
         if TBasicUDP(BasicUDPList[K]).SendDGram(FTxQueue[0]) then
            Inc(J);
      end;
      if J = BasicUDPList.Count then
         FTxQueue.Delete(0);
      Application.ProcessMessages;
      if Application.Terminated then Exit;
    end;
    if FTxQueue.Count <> 0 then Result:=True;
  except
    On E : Exception do
      RaiseGUIDException( '{B8F28937-8309-45F3-85D1-418FC627091B}' + Application.ExeName , E);
  end;
end;

procedure TMessageServer.AddToQueue(MF:TMessageFrames;AndSend:Boolean);
var
  I:Integer;
begin
  try
    CheckTimer.Enabled:=False;
    for I:=0 to MF.FrameCount-1 do
    begin
      if FTxQueue.IndexOf(MF.FrameData[I]) = -1 then
         FTxQueue.Add(MF.FrameData[I]);
    end;
    if AndSend then CheckTxQueue;
    CheckTimer.Enabled:=True;
  except
    On E : Exception do
      RaiseGUIDException( '{8C7DFBB5-2FDA-468F-B7CF-A40786A469D6}' + Application.ExeName, E);
  end;
end;

procedure TMessageServer.ProcessRequest(Data:String);
var
   I:Integer;
   Index:Integer;
   MF:TMessageFrames;
   FrameIndex:Integer;
   MessageList:TBBits;
begin
  try
    if Copy(Data,1,4) = 'RXED' then
    begin
      MessageList:=TBBits.Create;
      RunLengthDecode(Copy(Data,5,Length(Data)),MessageList,False);
      for I:=0 to FTxList.Count-1 do
      begin
         if not MessageList[I] then
         begin
            Index:=FTxList.IndexOf(I);
            if Index <> -1 then
               AddToQueue(FTxList[Index],True);
         end;
      end;
      MessageList.Free;
      Exit;
    end;
    Index:=FTxList.IndexOf(HexToIntDef(Copy(Data,1,4),0));
    if Index <> -1 then
    begin
      MF:=FTxList[Index];
      CheckTimer.Enabled:=False;
      for I:=1 to (Length(Data) div 4)-1 do
      begin
         FrameIndex:=HexToIntDef(Copy(Data,I*4+1,4),0);
         if FTxQueue.IndexOf(MF.FrameData[FrameIndex]) = -1 then
            FTxQueue.Add(MF.FrameData[FrameIndex]);
      end;
      CheckTxQueue;
      CheckTimer.Enabled:=True;
    end;
  except
    On E : Exception do
      RaiseGUIDException( '{12315C73-787E-4921-889D-05B00F22B46D}' + Application.ExeName, E);
  end;

end;

procedure TMessageServer.DrawOn(PaintBox:TPaintBox);
begin
  try
    FPaintBox:=PaintBox;
    FPaintBox.OnPaint:=PaintBoxPaint;
  except
    On E : Exception do
      RaiseGUIDException( '{AB12F3C1-E6AA-4785-B6D8-B16E50FD1443}'+ Application.ExeName , E);
  end;
end;

procedure TMessageServer.ClearRxMessages(From:String);
var
  Index:Integer;
  MsgList:TMessageList;
begin
  try
    Index:=FRxList.IndexOf(HexToIntDef(From,-1));
    if Index <> -1 then
    begin
      MsgList:=FRxList[Index];
      MsgList.Free;
      FRxList.Delete(Index);
    end;
  except
    On E : Exception do
      RaiseGUIDException( '{F62D5C84-4EB2-490D-A18B-0A74FC850041}' + Application.ExeName, E);
  end;
end;

function TMessageServer.CheckRxMessageTS(From,TimeStamp:String;MessageNumber:Integer):TMessageStatus;
var
   Index,I:Integer;
   LastTS:Integer;
   CurrentTS:Integer;
   MachineNo:Integer;
   S:String;
   MsgList:TMessageList;
   SLUpdated:Boolean;
begin
  Result:=msOK;
  try
    CurrentTS:=HexToIntDef(TimeStamp,0);
    Index:=-1;
    for I:=0 to StatList.Count-1 do
    begin
      if From = Copy(StatList[I],2,Length(StatList[I])) then
      begin
         Index:=I;
         break;
      end;
    end;
    if Index = -1 then Index:=StatList.Add('0'+From); // new machine

    SLUpdated:=False;

    if CurrentTS = $7FFFFFFF then // Quit Message
    begin
      if StatList[Index] <> '0'+From then
      begin
         StatList[Index]:='0'+From;
         SLUpdated:=True;
         Result:=msQuit;
      end;
    end
    else
    begin
      if StatList[Index] <> '1'+From then
      begin
         StatList[Index]:='1'+From;
         SLUpdated:=True;
      end;
      StatList.Objects[Index]:=TObject(30); // set max timeout
    end;
    if SLUpdated then
      StatList.SaveToFile('C:\StatList.txt');

    if Result = msQuit then Exit;

    Index:=TSList.IndexOf(From);
    MachineNo:=HexToIntDef(From,0);
    if Index = -1 then // other machine not seen before
    begin
      TSList.AddObject(From,TStringObject.Create(From+TimeStamp));
      Result:=msOK;
      Exit;
    end
    else
    begin
      S:=TStringObject(TSList.Objects[Index]).Value;
      LastTS:=HexToIntDef(Copy(S,9,8),0);
    end;

    // other machine restarted or other machine has had it's date reset to an earler day
    if (CurrentTS <> LastTS) then
    begin
      TStringObject(TSList.Objects[Index]).Value:=From+TimeStamp;
      Result:=msReset;
    end
    else
    begin // same timestamp as previous Messages
      Index:=FRxList.IndexOf(MachineNo);
      if Index >= 0 then // we have this machine in our list ?
      begin
         MsgList:=FRxList[Index];
         if MsgList.CompleteMessages[MessageNumber] then // already received this message
            Result:=msIgnore
         else
            Result:=msOK;
      end
      else // shouldn't be possible !
         Result:=msOK;
    end;
  except
    On E : Exception do
      RaiseGUIDException( '{E0A9E0DE-73AC-4F9B-9815-7345CCCBE85A}'+ Application.ExeName , E);
  end;
end;

procedure TMessageServer.RxDGram(Sender:TBasicUDP;From,TimeStamp,Data:String);
var
   Index:Integer;
   MsgList:TMessageList;
   MachineNumber:Integer;
   MessageFrame:TMessageFrames;
   MessageNumber:Integer;
   MS:TMessageStatus;
   RxBits:String;
begin
  try
    if Copy(Data,1,1) = 'R' then // Request
    begin
      if SendingTo.IndexOf(From) = -1 then
      begin
         if Copy(Data,2,8) = Sender.HexIPAddress then
         begin
    //            LastRX:=TimeInSeconds(Now);
            SendingTo.Add(From);
            ProcessRequest(Copy(Data,10,Length(Data)));
            Index:=SendingTo.IndexOf(From);
            SendingTo.Delete(Index);
         end;
      end;
      Exit;
    end;

    MessageNumber:=HexToIntDef(Copy(Data,1,4),-1);
    MS:=CheckRxMessageTS(From,TimeStamp,MessageNumber);
    if MS = msReset then
    begin
      ClearRxMessages(From);
      if Assigned(OnNewStart) then OnNewStart(From);
      MS:=msOK;
    end;
    if (MS = msIgnore) or (MS = msQuit) then Exit;

    MachineNumber:=HexToIntDef(From,-1);
    Index:=FRxList.IndexOf(MachineNumber);
    if Index = -1 then
    begin
      MsgList:=TMessageList.Create;
      FRxList.Add(MachineNumber,MsgList);
      Index:=TSList.IndexOf(From);
      if Index >= 0 then
      begin
         RxBits:=TStringObject(TSList.Objects[Index]).Value;
         RxBits:=Copy(RxBits,17,Length(RxBits));
         if RxBits <> '' then
         begin
            RunLengthDecode(RxBits,MsgList.FCompleteMessages,False);
            RunLengthDecode(RxBits,MsgList.FRxedMessages,False);
         end;
      end;
    end
    else
    begin
      MsgList:=FRxList[Index];
    end;
    if MsgList.CompleteMessages[MessageNumber] then Exit;
    if MessageNumber > MsgList.ShouldBeUpTo then
      MsgList.ShouldBeUpTo:=MessageNumber;
    Index:=MsgList.IndexOf(MessageNumber);
    if Index = -1 then
    begin
      MsgList.RxedMessages[MessageNumber]:=True;
      MessageFrame:=TMessageFrames.Create;
      MsgList.Add(MessageFrame);
    end
    else
    begin
      MessageFrame:=MsgList[Index];
    end;
    LastRX:=TimeInSeconds(Now);
    MsgList.ReceivedDataSize:=MsgList.ReceivedDataSize+Length(Data);
    MessageFrame.AddFrame(Data);
    if (MessageFrame.Complete) then
    begin
      MsgList.CompleteMessages[MessageNumber]:=True;
      if Copy(MessageFrame.Data,1,5) = '!!!!!' then
        MsgList.BelongsTo:=Copy(MessageFrame.Data,6,999)
      else if Assigned(FOnRxMessage) then
         FOnRxMessage(From,MessageFrame.Data,MessageFrame.FMsgNumber);
      MsgList.Delete(Index);
    end;
  except
    On E : Exception do
      RaiseGUIDException( '{E007C418-318F-44C5-BDB8-DE52C9E936D4}'+ Application.ExeName , E);
  end;
end;

procedure TMessageServer.DGramError(Sender:TBasicUDP;EMessage:String);
const
   LastError:String = '';
begin
  try
    if EMessage <> LastError then
    begin
      LastError:=EMessage;
      GPCSErrorLine.RaiseError(0,0,0,'Transact UDP '+EMessage);
    end;
  except
    On E : Exception do
      RaiseGUIDException('{E7E81948-FB25-4805-BBDE-4F7AC1F5FA5A}' + Application.ExeName , E);
  end;
end;

{TBasicUDP}
constructor TBasicUDP.Create;
begin
  try
    inherited Create;
    FTimeStamp:=IntToHex(TimeInSeconds(Now),8);
    FRxOwn:=False;
    FActive:=False;
    FPortNumber:=DGPortNumber;
    FReuseAddr:=False;

    if Copy(OSVersion,1,2) = 'XP' then // running on XP - degrade comms
      SendFrameSize:=1400;

    if GetGPCSRegString('','ReUse UDP Port','Yes') = 'Yes' then
    begin
      FReuseAddr:=True;
    end;

    Integer(FHSocket):=INVALID_SOCKET;
    FWindowHandle:=AllocateHWnd(WndProc);
  except
    On E : Exception do
      RaiseGUIDException( '{D04ABF08-5750-40EE-A16B-7037021B113C}'+ Application.ExeName , E);
  end;
end;

destructor TBasicUDP.Destroy;
begin
  try
    if FActive then
    begin
      SendQuitMessage;
      Sleep(500);
      Active:=False;
    end;
    if FWindowHandle <> 0 then DeAllocateHWnd(FWindowHandle);
    inherited Destroy;
  except
    On E : Exception do
      RaiseGUIDException( '{F629BAB2-64E5-4E42-8B54-C48401EEFFF5}'+ Application.ExeName , E);
  end;
end;

procedure TBasicUDP.RxDataGram(var Msg: TMessage);
var
   Src   :TSockAddrIn;
   SrcLen:Integer;
   RxStr :String;
   From  :String;
   Len   :Integer;
begin
  try
    SetLength(RxStr,$FFFF);
    SrcLen:=SizeOf(Src);
    Len:=RecvFrom(FHSocket,Pointer(@RxStr[1])^,$FFFF,0,Src,SrcLen);
    If Len = SOCKET_ERROR then
    begin
      if WSAGetLastError <> 10035 then // read from empty socket
        If Assigned(FOnError) then
          FOnError(Self,'RecvFrom Error '+IntToStr(WSAGetLastError)+' ('+Copy(RxStr,1,20)+')')
        else
          RaiseGUIDError('{3268238C-F719-4BE8-A5A9-1E2CC54990C0}', 'RecvFrom Error '+IntToStr(WSAGetLastError)+' ('+Copy(RxStr,1,20)+')');

    end
    else if (Len >= 26) and (Copy(RxStr,1,10) = 'CORVUSV300') then
    begin
      if Assigned(FOnRxDGram) then
      begin
        SetLength(RxStr,Len);
        From:=Copy(RxStr,11,8);
        if (FRxOwn) or (From <> HexIPAddress) then
          FOnRxDGram(Self,From,Copy(RxStr,19,8),Copy(RxStr,27,Len));
      end;
    end
    else
      RaiseGUIDError('{C17526F5-406B-4C1B-BE38-56480F956DF6}', 'Invalid UDP Message on port' + IntToStr(FPortNumber));
  except
    On E : Exception do
      RaiseGUIDException( '{C2DBB9EF-B8A7-4DD7-B34A-15252953E79A}'+ Application.ExeName , E);
  end;

end;

function TBasicUDP.SendDGram(Data:String):Boolean;
var
   AddrIn:TSockAddrIn;
   Res:Integer;
begin
  Result:=True;
  try
    if Self.HexIPAddress = '7F000001' then Exit; // no network card or N/C
    AddrIn.sin_family:=AF_INET;
    AddrIn.sin_addr.s_addr:=INADDR_BROADCAST;
    AddrIn.sin_port:=htons(FPortNumber);
    Data:='CORVUSV300'+HexIPAddress+FTimeStamp+Data;
    Res:=SendTo(FDramSocket,Pointer(@Data[1])^,Length(Data),0,TSockAddr(AddrIn),SizeOf(AddrIn));
    if Res = SOCKET_ERROR then
    begin
      if Assigned(FOnError) then
        FOnError(Self,'SendTo Error '+IntToStr(WSAGetLastError));
      Result:=False;
    end;
  except
    On E : Exception do
      RaiseGUIDException( '{8C88E11B-2CD1-4CB2-9082-1B4788AA3834}'+ Application.ExeName , E);
  end;
end;

function TBasicUDP.SendQuitMessage:Boolean;
var
   AddrIn:TSockAddrIn;
   Res:Integer;
   Data:String;
begin
  Result:=True;
  try
    if Self.HexIPAddress = '7F000001' then Exit; // no network card or N/C
    AddrIn.sin_family:=AF_INET;
    AddrIn.sin_addr.s_addr:=INADDR_BROADCAST;
    AddrIn.sin_port:=htons(FPortNumber);
    Data:='CORVUSV300'+HexIPAddress+IntToHex($7FFFFFFF,8);
    Res:=SendTo(FDramSocket,Pointer(@Data[1])^,Length(Data),0,TSockAddr(AddrIn),SizeOf(AddrIn));
    if Res = SOCKET_ERROR then
    begin
      if Assigned(FOnError) then
        FOnError(Self,'SendTo Error '+IntToStr(WSAGetLastError));
      Result:=False;
    end;
  except
    On E : Exception do
      RaiseGUIDException( '{2DE7562E-C043-40A4-9C16-673BDB1BD888}'+ Application.ExeName , E);
  end;
end;

procedure TBasicUDP.SetPortNumber(Value:Integer);
var
   WasActive:Boolean;
begin
  try
    if FPortNumber <> Value then
    begin
      WasActive:=Active;
      if WasActive then Active:=False;
      FPortNumber:=Value;
      Active:=WasActive;
    end;
  except
    On E : Exception do
      RaiseGUIDException( '{3E4134D6-B990-4128-A052-278B821515A5}'+ Application.ExeName , E);
  end;
end;

procedure TBasicUDP.SetActive(Value:Boolean);
var
   SockAddrIn:TSockAddrIn;
   Res:Integer;
   WSAData:TWSAData;
   Opt:Integer;
begin
  try
    if FActive <> Value then
    begin
      if Value then
      begin
         SockAddrIn.sin_family:=AF_INET;
         SockAddrIn.sin_addr.s_addr:=INADDR_ANY;
         SockAddrIn.sin_port:=htons(FPortNumber);
         if WSAStartUp($0101,WSAData) = 0 then
         begin
            FHSocket:=WinSock.Socket(PF_INET,SOCK_DGRAM,IPPROTO_UDP);
            // stop bind errors on multiple opens
    //            GetSockOpt(FHSocket,SOL_SOCKET,SO_MAX_MSG_SIZE,PChar(@Opt),SizeOf(Opt));
    //            ShowMessage(IntToStr(Opt));
            if FReuseAddr then // allow more than one process to open Port number
            begin
               Opt:=1;
               SetSockOpt(FHSocket,SOL_SOCKET,SO_REUSEADDR,PChar(@Opt),SizeOf(Opt));
            end;
            if FHSocket <> INVALID_SOCKET then
            begin
               Res:=Bind(FHSocket,TSockAddr(SockAddrIn),sizeof(SockAddrIn));
               if Res <> SOCKET_ERROR then
               begin
                  Res:=WSAASyncSelect(FHSocket,FWindowHandle,WM_RXDATAGRAM,FD_READ);
                  if (Res = SOCKET_ERROR) and Assigned(FOnError) then
                  begin
                     FOnError(Self,'Sync Error '+IntToStr(WSAGetLastError));
                     Exit;
                  end;
               end
               else
               begin
                  if Assigned(FOnError) then
                     FOnError(Self,'Bind Error '+IntToStr(WSAGetLastError));
                  Exit;
               end;
            end
            else
            begin
               if Assigned(FOnError) then
                  FOnError(Self,'Socket Error '+IntToStr(WSAGetLastError));
               Exit;
            end;
         end
         else
         begin
            if Assigned(FOnError) then
               FOnError(Self,'WSAStartup Error '+IntToStr(WSAGetLastError));
            Exit;
         end;
         Opt:=1;
         FDramSocket:=WinSock.Socket(PF_INET,SOCK_DGRAM,IPPROTO_UDP);
         if FDramSocket = INVALID_SOCKET then
         begin
            if Assigned(FOnError) then
               FOnError(Self,'Socket Error '+IntToStr(WSAGetLastError));
            FHSocket:=INVALID_SOCKET;
            Exit;
         end
         else
         begin
            Opt:=SetSockOpt(FDramSocket,SOL_SOCKET,SO_BROADCAST,PChar(@Opt),SizeOf(Opt));
            if Opt = SOCKET_ERROR then
            begin
               CloseSocket(FDramSocket);
               FDramSocket:=INVALID_SOCKET;
               FHSocket:=INVALID_SOCKET;
               if Assigned(FOnError) then
                  FOnError(Self,'SetSockOpt Error '+IntToStr(WSAGetLastError));
               Exit;
            end;
         end;
         FActive:=True;
      end
      else // Active = False
      begin
         try
            if FHSocket <> INVALID_SOCKET then
            begin
               CloseSocket(FHSocket);
            end;
            if FDramSocket <> INVALID_SOCKET then
               CloseSocket(FDramSocket);
         except
            on E:Exception do
               RaiseGUIDException('{BB646BF6-0DC4-4ADD-B4AE-3F32016A5882}',E);
         end;
         FHSocket:=INVALID_SOCKET;
         FDramSocket:=INVALID_SOCKET;
         FActive:=False;
      end;
    end;
  except
    On E : Exception do
      RaiseGUIDException( '{13FEBB49-C89E-4FB3-BFAD-1664364A16B5}' + Application.ExeName , E);
  end;
end;

function TBasicUDP.HexIPAddress:String;
var
   HostEnt: PHostEnt;
   Len:DWord;
   MachineName:array[0..MAX_COMPUTERNAME_LENGTH] of Char;
const
   IPAddress:String = '';
begin
  try
    if (IPAddress = '') then // or (IPAddress = '7F000001') then
    begin
      Len:=Sizeof(MachineName);
      GetComputerName(MachineName,Len);
      HostEnt:=WinSock.gethostbyname(MachineName);
      if HostEnt <> nil then
      IPAddress:=IntToHex((Integer(HostEnt^.h_addr^[0]) shl 24) or
                          (Integer(HostEnt^.h_addr^[1]) shl 16) or
                          (Integer(HostEnt^.h_addr^[2]) shl  8) or
                          (Integer(HostEnt^.h_addr^[3])       )   ,8)
      else
         IPAddress:='';
    end;
    Result:=IPAddress;
  except
    On E : Exception do
      RaiseGUIDException( '{EA55BB15-850E-4DFC-AE76-FF74ADBB4F49}'+ Application.ExeName , E);
  end;
end;
procedure TBasicUDP.WndProc(var Msg: TMessage);
begin
  try
    Dispatch(Msg);
  except
    On E : Exception do
      RaiseGUIDException( '{A371A3E5-6D58-44EB-B32D-11BB329C191A}' + Application.ExeName , E);
  end;
end;

{TMessageFrames}

constructor TMessageFrames.Create;
begin
  try
    inherited Create;
    FData      :='';
    FLength    :=0;
    FFrameCount:=0;
    FrameSize:=SendFrameSize;
    FFrameData :=TBBits.Create;
    FComplete  :=False;
    FMsgNumber :=-1;
  except
    On E : Exception do
      RaiseGUIDException( '{254F1F64-C96D-4688-9F8C-AA5ECEADA628}'+ Application.ExeName , E);
  end;
end;

destructor TMessageFrames.Destroy;
begin
  try
    FFrameData.Free;
    FFrameData:=nil;
    inherited Destroy;
  except
    On E : Exception do
      RaiseGUIDException( '{A94088DA-B2FA-42A7-AC3E-AC7E808D113F}' + Application.ExeName , E);
  end;
end;

procedure TMessageFrames.SetData(Value:String);
var
   I:Integer;
begin
  try
    FData:=Value;
    FLength:=Length(Value);
    FComplete:=True;
    FFrameCount:=FLength div FrameSize;
    if (FLength mod FrameSize) > 0 then Inc(FFrameCount);
    FFrameData.Size:=FFrameCount;
    for I:=0 to FFrameCount-1 do FFrameData.Bits[I]:=True;
  except
    On E : Exception do
      RaiseGUIDException('{A4D95357-F12B-4774-B41F-826DCF4E8F5B}' + Application.ExeName , E);
  end;
end;

function TMessageFrames.Missing:String;
var
  I:Integer;
begin
  try
    Result:=IntToHex(MsgNumber,4);
    for I:=0 to FFrameCount-1 do
      if not FFrameData.Bits[I] then
         Result:=Result+IntToHex(I,4);
  except
    On E : Exception do
      RaiseGUIDException( '{73C368B2-0907-4C70-81BE-BCF1AB04FFA6}' + Application.ExeName, E);
  end;
end;

function TMessageFrames.GetFrameData(Index:Integer):String;
var
  RS:String;
begin
  try
    if Index < FFrameCount then
    begin
      RS:=Copy(FData,1+Index*FrameSize,FrameSize);
      Result:=IntToHex(FMsgNumber,4)+IntToHex(Index,4)+IntToHex(FFrameCount,4)+IntToHex(CalcCCITTCRC(RS),8)+IntToHex(Length(RS),4)+IntToHex(FrameSize,4)+RS;
    end
    else
      Result:='';
  except
    On E : Exception do
      RaiseGUIDException( '{794B31BB-A6A1-4BCE-A8BD-E1B17752E01E}'+ Application.ExeName , E);
  end;
end;

procedure TMessageFrames.AddFrame(Value:String);
var
   Index :Integer;
   FCount:Integer;
   MNumb :Integer;
   CRC   :Integer;
   Len   :Integer;
begin
  try
    MNumb :=HexToIntDef(Copy(Value,1,4),-1);
    if FMsgNumber < 0 then
      FMsgNumber:=MNumb
    else
      if FMsgNumber <> MNumb then Exit;
    Index    :=HexToIntDef(Copy(Value,5,4),-1);
    FCount   :=HexToIntDef(Copy(Value,9,4),-1);
    CRC      :=HexToIntDef(Copy(Value,13,8),-1);
    Len      :=HexToIntDef(Copy(Value,21,4),-1);
    FrameSize:=HexToIntDef(Copy(Value,25,4),-1);
    Value :=Copy(Value,29,Length(Value)-28);
    if (CRC <> CalcCCITTCRC(Value)) or (Length(Value) < Len) then
      Exit;
    if FCount > FFrameCount then
    begin
      FFrameCount:=FCount;
      FFrameData.Size:=FFrameCount;
      SetLength(FData,FFrameCount*FrameSize);
    end;
    if Index < FFrameCount then
    begin
      CopyMemory(@(FData[1+Index*FrameSize]),@(Value[1]),Len);
      if Index = FFrameCount-1 then
         SetLength(FData,((FFrameCount-1)*FrameSize)+Len);
      FFrameData.Bits[Index]:=True;
    end;
    if FFrameData.OpenBit = FFrameCount then
      FComplete:=True;
  except
    On E : Exception do
      RaiseGUIDException( '{533CC630-1C64-431A-BFE1-753EA1E92B4E}'+ Application.ExeName , E);
  end;
end;

{TMessageList}
constructor TMessageList.Create;
begin
  try
    inherited Create;
    FMsgs:=TList.Create;
    FShouldBeUpTo:=0;
    FBelongsTo:='NOT KNOWN';
    ReceivedDataSize:=0;
    FRxedMessages:=TBBits.Create;
    FCompleteMessages:=TBBits.Create;
  except
    On E : Exception do
      RaiseGUIDException( '{21261BE8-7374-4081-9B8F-DB39376A618C}'+ Application.ExeName , E);
  end;
end;

destructor TMessageList.Destroy;
begin
  try
    while Count > 0 do Delete(0);
    FMsgs.Free;
    FMsgs:=nil;
    FRxedMessages.Free;
    FCompleteMessages.Free;
    inherited Destroy;
  except
    On E : Exception do
      RaiseGUIDException( '{D0A40E18-3A96-46E9-913C-213FA4DCF960}' + Application.ExeName , E);
  end;
end;

function TMessageList.GetMsg(Index:Integer):TMessageFrames;
begin
  Result:=nil;
  try
    if (Index >= 0) and (Index < Count) then
      Result:=TMessageFrames(FMsgs[Index]);
  except
    On E : Exception do
      RaiseGUIDException( '{35A00459-2ABC-4EC5-92B0-126D7B41A83B}'+ Application.ExeName , E);
  end;
end;

function TMessageList.GetCount:Integer;
begin
   Result:=FMsgs.Count;
end;

function TMessageList.IndexOf(MsgNumber:Integer):Integer;
var
   I:Integer;
begin
  Result:=-1;
  try
    for I:=0 to Count-1 do
    begin
      if Msg[I].MsgNumber = MsgNumber then
      begin
         Result:=I;
         Exit;
      end;
    end;
  except
    On E : Exception do
      RaiseGUIDException('{04EA9948-7716-4CB6-9B11-9BD4B645B635}'  + Application.ExeName , E);
  end;
end;

function TMessageList.Add(Msg:TMessageFrames):Integer;
begin
   Result:=FMsgs.Add(Msg);
end;

procedure TMessageList.Delete(Index:Integer);
begin
  try
    if (Index >= 0) and (Index < Count) then
    begin
      if FMsgs[Index] <> nil then
         TMessageFrames(FMsgs[Index]).Free;
      FMsgs.Delete(Index);
    end;
  except
    On E : Exception do
      RaiseGUIDException( '{5B5BCEF2-35CE-471A-AE2E-42F0C093D2FE}'+ Application.ExeName , E);
  end;
end;

{TMachineList}
constructor TMachineList.Create;
begin
  try
    inherited Create;
    FMachines:=TStringList.Create;
  except
    On E : Exception do
      RaiseGUIDException( '{5D8E2E23-0200-4D09-A071-E8076A71CE26}'+ Application.ExeName , E);
  end;
end;

destructor TMachineList.Destroy;
begin
  try
    FMachines.Free;
    FMachines:=nil;
    inherited Destroy;
  except
    On E : Exception do
      RaiseGUIDException( '{97F2E983-62D0-4C88-9ADC-3EE5B26C25B5}'+ Application.ExeName , E);
  end;
end;

function TMachineList.GetMNumb(Index:Integer):String;
begin
   if Index < Count then
      Result:=FMachines[Index]
   else
      Result:='00000000';
end;

function TMachineList.GetMsgList(Index:Integer):TMessageList;
begin
   if Index < Count then
      Result:=TMessageList(FMachines.Objects[Index])
   else
      Result:=nil;
end;

function TMachineList.GetCount:Integer;
begin
   Result:=FMachines.Count;
end;

function TMachineList.IndexOf(MachineNumber:Integer):Integer;
begin
   Result:=FMachines.IndexOf(IntToHex(MachineNumber,8));
end;

function TMachineList.Add(MachineNumber:Integer;MsgList:TMessageList):Integer;
begin
   Result:=FMachines.AddObject(IntToHex(MachineNumber,8),MsgList);
end;

procedure TMachineList.Delete(Index:Integer);
begin
   if Index < Count then
      FMachines.Delete(Index);
end;

{TTxnMsgSvr}
constructor TTxnMsgSvr.Create;
var
   WSNumber:Integer;
begin
  try
    inherited Create;
    MessageServer:=TMessageServer.Create;
    MessageServer.OnRxMessage:=MessageServerRx;
    MessageServer.OnNewStart:=NewStart;
    FTxnBits:=TTransactionBits.Create;
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
    FTxnBits.WSNumber:=WSNumber;
    SendMessage('Statement'+FTxnBits.AllMachinesBits);
  except
    On E : Exception do
      RaiseGUIDException( '{5A719025-09B9-4D92-A8CF-1036FC4B3184}' + Application.ExeName, E);
  end;
end;

procedure TTxnMsgSvr.NewStart(From:String);
begin
  try
    SendMessage('Statement'+FTxnBits.AllMachinesBits);
  except
    On E : Exception do
      RaiseGUIDException( '{ECB89B9D-AC32-40F3-A2BA-85C282AD9822}'+ Application.ExeName , E);
  end;
end;

destructor TTxnMsgSvr.Destroy;
begin
  try
    FTxnBits.Free;
    MessageServer.Free;
    inherited Destroy;
  except
    On E : Exception do
      RaiseGUIDException( '{B2F3C59E-DC29-413D-88A6-9962269F2D05}'+ Application.ExeName , E);
  end;
end;

procedure TTxnMsgSvr.SendMessage(Data:String);
var
   SI,SO:TStringStream;
   Comp:TCompressor;
begin
  try
  if Data = '' then Exit;
  Comp:=TCompressor.Create;
  SI:=TStringStream.Create(Data);
  SO:=TStringStream.Create('');
  try
    if DataCompressed then
    begin
       Comp.CompressStream(SI,SO);
       MessageServer.SendMessage(SO.DataString);
    end
    else
    begin
       MessageServer.SendMessage(Data);
    end;
  except
    on E:Exception do
       RaiseGUIDException('{F6FDE671-4BD4-43FE-B535-BAC0AFFDF741}',E);
  end;
  SO.Free;
  SI.Free;
  Comp.Free;
  except
    On E : Exception do
      RaiseGUIDException( '{F6959AD8-790C-4458-A4EA-193DD2A1C24E}'+ Application.ExeName , E);
  end;
end;

procedure TTxnMsgSvr.RxStatement(Data:String);
var
   SL:TPackStringList;
   RSL:TPackStringList;
   I:Integer;
begin
  try
    SL:=TPackStringList.Create;
    RSL:=TPackStringList.Create;
    SL.PackText:=Data;
    for I:=0 to SL.Count-1 do
    begin
      RSL.PackText:=SL[I];
      if RSL.Count > 0 then
      begin
         if HexToIntDef(RSL[0],0) = FTxnBits.WSNumber then
         begin
            if SL[I] <> FTxnBits.MyBits then
            begin
               SendMessage(FTxnBits.Difference(SL[I]));
            end;
            RSL.Free;
            SL.Free;
            Exit;
         end;
      end;
    end;
    RSL.Free;
    SL.Free;
    // not seen this machine before !
    SendMessage(FTxnBits.Difference(''));
  except
    On E : Exception do
      RaiseGUIDException( '{44A73054-3AAF-4C9B-86D4-4F8FD7FFACFB}'+ Application.ExeName , E);
  end;
end;

procedure TTxnMsgSvr.MessageServerRx(From,Data:String;MsgNumber:Integer);
var
   SI,SO:TStringStream;
   Comp:TCompressor;
begin
  try
    Comp:=TCompressor.Create;
    SI:=TStringStream.Create(Data);
    SO:=TStringStream.Create('');
    try
      if DataCompressed then
      begin
         Comp.DecompressStream(SI,SO);
      end
      else
      begin
         SI.Position:=0;
         SO.CopyFrom(SI,SI.Size);
         SO.Position:=0;
      end;
      if Copy(SO.DataString,1,9) = 'Statement' then
      begin
         RxStatement(Copy(SO.DataString,10,Length(SO.DataString)));
      end
      else
      begin
         if Assigned (FMessageRx) then
            FMessageRx(SO.DataString);
      end;
    except
      on E:Exception do
         RaiseGUIDException('{4D13736F-D0F1-41B4-A344-BFD6F8C441DD}',E);
    end;
    SO.Free;
    SI.Free;
    Comp.Free;
  except
    On E : Exception do
      RaiseGUIDException( '{859FD85E-42D1-47E5-B4D4-1354766A4F64}'+ Application.ExeName , E);
  end;
end;

procedure TTxnMsgSvr.RecNotify(StartIdent,EndIdent:Integer);
var
   BitsB:TBBits;
   I:Integer;
   SL:TPackStringList;
   WSSL:TPackStringList;
begin
  try
    WSSL:=TPackStringList.Create;
    BitsB:=TBBits.Create;
    RunLengthDecode(FTxnBits.MyBits,BitsB,True);
    for I:=StartIdent to EndIdent do
      BitsB[I]:=True;
    WSSL.PackText:=RunLengthEncode(BitsB);
    WSSL.Insert(0,IntToHex(FTxnBits.WSNumber,4));
    FTxnBits.FMyBits:=WSSL.PackText;
    WSSL.Free;
    BitsB.Free;
    FTxnBits.NextFreeIdent:=EndIdent+1;
    SendMessage(QueryToPackText('select * from TxnLog where WSNumber = '+IntToStr(FTxnBits.WSNumber)+' and (RecordID >= '+IntToStr(StartIdent)+' and RecordID <= '+IntToStr(EndIdent)+')'));
    SL:=TPackStringList.Create;
    WSSL:=TPackStringList.Create;
    SL.PackText:=FTxnBits.FAllMachinesBits;
    for I:=0 to SL.Count-1 do
    begin
      WSSL.PackText:=SL[I];
      if (WSSL.Count > 0) and (StrToIntDef('$'+WSSL[0],-1) = FTxnBits.WSNumber) then
      begin
         SL[I]:=FTxnBits.FMyBits;
         FTxnBits.FAllMachinesBits:=SL.PackText;
         break;
      end
    end;
    WSSL.Free;
    SL.Free;
  except
    On E : Exception do
      RaiseGUIDException( '{CA8B706F-BAE8-4978-99B3-2902174FDD54}'+ Application.ExeName , E);
  end;
end;

function TTxnMsgSvr.NextFreeIdent:Integer;
begin
  Result:=FTxnBits.NextFreeIdent;
end;

procedure TTxnMsgSvr.RecordAdded(WSNumber,RecordID:Integer);
var
   SL:TPackStringList;
   WSSL:TPackStringList;
   I:Integer;
   NewBits:TBBits;
begin
  try
    SL:=TPackStringList.Create;
    WSSL:=TPackStringList.Create;
    SL.PackText:=FTxnBits.FAllMachinesBits;
    for I:=0 to SL.Count-1 do
    begin
      WSSL.PackText:=SL[I];
      if (WSSL.Count > 0) and (StrToIntDef('$'+WSSL[0],-1) = WSNumber) then
      begin
         NewBits:=TBBits.Create;
         RunLengthDecode(SL[I],NewBits,True);
         NewBits[RecordID]:=True;
         WSSL.PackText:=RunLengthEncode(NewBits);
         NewBits.Free;
         WSSL.Insert(0,IntToHex(WSNumber,4));
         SL[I]:=WSSL.PackText;
         FTxnBits.FAllMachinesBits:=SL.PackText;
         SL.Free;
         WSSL.Free;
         Exit;
      end;
    end;
    // workstation not in list
    NewBits:=TBBits.Create;
    NewBits[RecordID]:=True;
    WSSL.PackText:=RunLengthEncode(NewBits);
    NewBits.Free;
    WSSL.Insert(0,IntToHex(WSNumber,4));
    SL.Add(WSSL.PackText);
    FTxnBits.FAllMachinesBits:=SL.PackText;
    SL.Free;
    WSSL.Free;
  except
    On E : Exception do
      RaiseGUIDException( '{687AF541-E75E-46E4-A04F-92D7DBA70357}'+ Application.ExeName , E);
  end;
end;

function TTxnMsgSvr.GetTxnData:String;
begin
  try
    if FTxnBits <> nil then
      Result:=FTxnBits.AllMachinesBits
    else
      Result:='';
  except
    On E : Exception do
      RaiseGUIDException( '{4230350E-CC0A-4B84-8953-A75FE1F0EFAA}'+ Application.ExeName , E);
  end;
end;

function RunLengthDecode(Data:String;var Bits:TBBits;WithWS:Boolean):TBBits;
var
  SL:TPackStringList;
  I:Integer;
  State:Boolean;
  RL:Integer;
  CurrentOfs:Integer;
begin
  Result:=Bits;
  try
    if Data = '' then Exit;
    SL:=TPackStringList.Create;
    SL.PackText:=Data;
    if WithWS then SL.Delete(0); // first element = WSNumber
    if SL.Count > 0 then
    begin
       State:=True;
       CurrentOfs:=StrToIntDef(SL[0],0);
       for I:=1 to SL.Count-1 do
       begin
          RL:=StrToIntDef(SL[I],0);
          if State then
          begin
             while RL > 0 do
             begin
                Bits[CurrentOfs]:=True;
                Inc(CurrentOfs);
                Dec(RL);
             end;
          end
          else
          begin
             Inc(CurrentOfs,RL);
          end;
          State:=not State;
       end;
    end;
    SL.Free;
  except
    On E : Exception do
      RaiseGUIDException( '{11382132-AAF5-4A27-B0F0-24700ABD28E8}'+ Application.ExeName , E);
  end;
end;

function RunLengthEncode(Bits:TBBits):String;
var
   I:Integer;
   RL:Integer;
   State:Boolean;
   RSL:TPackStringList;
begin
  try
    Result:='';
    if Bits.Size = 0 then Exit;
    RSL:=TPackStringList.Create;
    State:=Bits[0];
    if State then RSL.Add('0');
    RL:=0;
    for I:=0 to Bits.Size-1 do
    begin
      if Bits[I] = State then
      begin
         Inc(RL)
      end
      else
      begin
         RSL.Add(IntToStr(RL));
         RL:=1;
         State:=not State;
      end;
    end;
    RSL.Add(IntToStr(RL));
    Result:=RSL.PackText;
    RSL.Free;
  except
    On E : Exception do
      RaiseGUIDException( '{17280429-50B1-4CDF-B277-B1C00CE3E250}'+ Application.ExeName , E);
  end;
end;

end.
