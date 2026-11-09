unit StatusMonitorU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,MsgConfigU,
  StdCtrls, ExtCtrls,WinSock,ScktComp2,GPCSGUID,PackStrListU,GPCSErrorLine,DTSocketU,
  StringUtil;
  
type
  TGlobalMemory = class(TObject)
  public
     MyData:String;
     Others:TStringList;
     constructor Create;
     destructor Destroy; override;
  end;
  TUDPSocket = class;
  TUDPEvent = procedure (Sender:TUDPSocket;EMessage:String) of object;
  TRxEvent = procedure (Sender:TUDPSocket;From,Data:String) of object;
  TRxStatusEvent = procedure (Size:Integer;From:String;Stat:Boolean) of object;
  TTxStatusEvent = procedure (Size:Integer;Stat:Boolean) of object;
  TOnReqReplace = procedure(From:String) of object;
  TUDPSocket = class(TObject)
  private
    FActive:Boolean;
    FPortNumber:Integer;
    FReuseAddr:Boolean;
    FHSocket:TSocket;
    FDramSocket:TSocket;
    FWindowHandle:THandle;
    FOnError:TUDPEvent;
    FOnRxDGram:TRxEvent;
    FRxOwn:Boolean;
    FPortNumbers:String;
    FNextSocket:TUDPSocket; // multiple ports
    FOnSendStatus:TTxStatusEvent;
    FOnRecvStatus:TRxStatusEvent;
  protected
    procedure DefaultHandler(var Message); override;
    procedure WndProc       (var Msg: TMessage);
    procedure RxDataGram    (var Msg: TMessage); message WM_RXDATAGRAM;
    procedure SetActive     (Value:Boolean    ); virtual;
    procedure SetPortNumber (Value:Integer    ); virtual;
    procedure SetRxOwn      (Value:Boolean    ); virtual;
    procedure SetOnError    (Value:TUDPEvent  ); virtual;
    procedure SetOnRxDGram  (Value:TRxEvent   ); virtual;
    procedure SetReuseAddr  (Value:Boolean    ); virtual;
    procedure SetPortNumbers(Value:String     ); virtual;
  public
    constructor Create; virtual;
    destructor  Destroy; override;
    function    HexIPAddress:String;
    function    GetIPAddress:Integer;
    function    SendDGram(Data:String):Boolean; virtual;
    property    Active    :Boolean   read FActive      write SetActive     ;
    property    PortNumber:Integer   read FPortNumber  write SetPortNumber ;
    property    PortNumbers:String   read FPortNumbers write SetPortNumbers;
    property    RxOwn     :Boolean   read FRxOwn       write SetRxOwn      ;
    property    OnError   :TUDPEvent read FOnError     write SetOnError    ;
    property    OnRxDGram :TRxEvent  read FOnRxDGram   write SetOnRxDGram  ;
    property    ReuseAddr :Boolean   read FReuseAddr   write SetReuseAddr  ;
    property    OnSendStatus:TTxStatusEvent read FOnSendStatus write FOnSendStatus;
    property    OnRecvStatus:TRxStatusEvent read FOnRecvStatus write FOnRecvStatus;
  end;                     
  TQueuedUDPSocket = class(TUDPSocket)
    private
       TxQueue:TStringList;
       AccessingTxQueue:Boolean;
    public
       constructor Create; override;
       destructor  Destroy; override;
       function    SendDGram(Data:String):Boolean; override;
       procedure   OnTimer;
  end;
  
  
  TBBits = class(TBits)
  private
      function GetBit(Index:Integer):Boolean;
      procedure SetBit(Index:Integer;Value:Boolean);
      function GetRLEBits:String;
      procedure SetRLEBits(Value:String);
  public        
      function BitwiseXOR(RLE:String):String;
      function BitwiseOR (RLE:String):String;
      function BitwiseAND(RLE:String):String;
      function BitwiseNOT:String;
      property Bits[Index:Integer]:Boolean read GetBit write SetBit; default;
      property AsString:String read GetRLEBits write SetRLEBits;
  end;
  TStatusBits = class(TObject)
  private
     FWSList:TPackStringList; // Workstation Bits -  one string per WS
     FOnChange:TNotifyEvent;
     function GetState:String;
     procedure SetState(Value:String);
     function GetBit(Office,WS,Index:Integer):Boolean;
     procedure SetBit(Office,WS,Index:Integer;State:Boolean);
     function GetWSIndex(Office,WS:Integer):Integer;
     function GetBits(Office,WS:Integer):TBBits;
     procedure SetBits(Office,WS:Integer;Value:TBBits);
     function CountBits(Office,WS:Integer):Integer;
  public
     constructor Create; virtual;
     destructor  Destroy; override;
     function  Missing (Value:String):String; // bits only in Value
     function  Matching(Value:String):String; // bits in Self AND Value
     procedure Merge   (Value:String);        // Self = Self OR Value
     function Count:Integer;
     function Size(Office,WSNumber:Integer):Integer;
     function Width:Integer;
     function WSNumber(Index:Integer):Integer;
     function OfficeCode(Index:Integer):Integer;
     function DrawOn(Office:Integer;Canvas:TCanvas;InRect:TRect;MaxBits:Integer;Interval:Integer;Clear:Boolean;ThisWorkstation,ThisOffice:Integer;WSList:TStrings):Integer;
     property State:String                  read GetState write SetState;
     property Bit[Office,WS,Index:Integer]:Boolean read GetBit   write SetBit  ; default;
     property Bits[Office,WS:Integer]:TBBits       read GetBits  write SetBits ;
     property OnChange:TNotifyEvent         read FOnChange write FOnChange;
     property WSList:TPackStringList        read FWSList   write FWSList;
  end;
  TTimedStatusBits = class(TStatusBits)
  private
     AddingBits:Boolean;
     FList:TPackStringList; // TimedList - One Line per second
     FCurrentIndex:Integer;
     FNextProcess:Integer;
  public        
     constructor Create; override;
     destructor Destroy; override;
     procedure AddBits(Value:String);
     procedure CheckTimeOut;
  end;    
  
  TStatusMonitor = class;
  TDataRxEvent    = procedure (Sender:TStatusMonitor;DataReceived:String) of object;
  TDataTxEvent    = function  (Sender:TStatusMonitor;OfficeID,Workstation,BlockNumber:Integer;Into:TStream):TStream of object;
  TDataEvent      = procedure (Sender:TStatusMonitor;ErrorMessage:String) of object;
  
  TStatusMonitor = class(Tobject)
  private
     FThisWorkstation:Integer;
     FUDPSocket:TQueuedUDPSocket;
     FCurrentStatus:TStatusBits;
     FReceivedBlocks:TStatusBits;
     FPrevRequested:TTimedStatusBits;
     FAcceptedProps:TTimedStatusBits;
     FActive:Boolean;
     FOnDataRx :TDataRxEvent;
     FOnDataTx :TDataTxEvent;
     FOnError  :TDataEvent;
     FOnSend   :TDataEvent;
     FOnReceive:TDataEvent;
     FOnSendData:TSendCommand;
     FOnChange:TNotifyEvent;
     FCurrentOffice:Integer;
     FOnReqReplace:TOnReqReplace;
     FThisVersion:Integer;
     FOnSendStatus:TTxStatusEvent;
     FOnRecvStatus:TRxStatusEvent;
     FOnRestart :TNotifyEvent;
     FOnLogOff :TNotifyEvent;
     FOnShutdown:TNotifyEvent;
     FOnPowerOff:TNotifyEvent;
     procedure Changed(Sender:TObject);
     function CutDown(Bitmap:String):String;
     procedure SetActive(Value:Boolean);
     function RemoveIgnoredWS(Status:String):String;
     procedure ReceiveStatus  (From,Status  :String);
     procedure ReceiveOldRequest(WorkStation:Integer;From,Request:String);
     procedure ReceiveProposal(Old:Boolean;Workstation:Integer;Proposal:String);
     procedure ReceiveAccept  (From:String;Workstation:Integer;Accept  :String);
     procedure ReceiveRequest (Workstation:Integer;From,Request :String);
     procedure ReceiveData    (Workstation:Integer;Data    :String);
     procedure SendStatus     (Status  :String);
     procedure SendProposal   (FromWorkstation,ToWorkstation:Integer;Proposal:String);
     procedure SendOldProposal(FromWorkstation,ToWorkstation:Integer;Proposal:String);
     procedure SendAccept     (Workstation:Integer;Accept  :String);
     procedure SendRequest    (Request :String);
     procedure UpdateGlobalMemory(WorkStation:Integer;From,Data:String);
     procedure ReceiveCommand(WorkStation:Integer;From,Data:String);
     function IgnoringWS(WS:Integer):Boolean;    
     procedure DGError  (Sender:TUDPSocket;EMessage :String);
     procedure DGReceive(Sender:TUDPSocket;From,Data:String);
     procedure SendDataGram(Data:String);
     procedure SendStat(Size:Integer;Stat:Boolean);
     procedure RecvStat(Size:Integer;From:String;Stat:Boolean);
  public
     constructor Create;
     destructor Destroy; override;
     procedure SetStatus(Status:String);
     procedure SendData(Data:String);
     procedure SendGlobalMemory(Data:String);
     procedure SendCommand   (FromWorkstation,ToWorkstation:Integer;CommandCode:TCommandType;CommandString:String);
     procedure UpdateStatus(Office,Workstation,BlockNumber:Integer);
     procedure TimerTick;
     property Active         :Boolean          read FActive          write SetActive       ;
     property ThisWorkstation:Integer          read FThisWorkstation write FThisWorkstation;
     property CurrentStatus  :TStatusBits      read FCurrentStatus   write FCurrentStatus  ;
     property ReceivedBlocks :TStatusBits      read FReceivedBlocks  write FReceivedBlocks ;
     property PrevRequested  :TTimedStatusBits read FPrevRequested   write FPrevRequested  ;
     property AcceptedProps  :TTimedStatusBits read FAcceptedProps   write FAcceptedProps  ;
     property UDPSocket      :TQueuedUDPSocket read FUDPSocket       write FUDPSocket      ;
     property CurrentOffice  :Integer          read FCurrentOffice   write FCurrentOffice  ;
     property ThisVersion    :Integer          read FThisVersion     write FThisVersion    ;
     property OnDataRx       :TDataRxEvent     read FOnDataRx        write FOnDataRx       ;
     property OnDataTx       :TDataTxEvent     read FOnDataTx        write FOnDataTx       ;
     property OnError        :TDataEvent       read FOnError         write FOnError        ;
     property OnSend         :TDataEvent       read FOnSend          write FOnSend         ;
     property OnReceive      :TDataEvent       read FOnReceive       write FOnReceive      ;
     property OnSendData     :TSendCommand     read FOnSendData      write FOnSendData     ;
     property OnChange       :TNotifyEvent     read FOnChange        write FOnChange       ;
     property OnReqReplace   :TOnReqReplace    read FOnReqReplace    write FOnReqReplace   ;
     property OnSendStatus   :TTxStatusEvent   read FOnSendStatus    write FOnSendStatus   ;
     property OnRecvStatus   :TRxStatusEvent   read FOnRecvStatus    write FOnRecvStatus   ;
     property OnRestart      :TNotifyEvent     read FOnRestart       write FOnRestart      ;
     property OnLogOff       :TNotifyEvent     read FOnLogOff        write FOnLogOff       ;
     property OnShutdown     :TNotifyEvent     read FOnShutdown      write FOnShutdown     ;
     property OnPowerOff     :TNotifyEvent     read FOnPowerOff      write FOnPowerOff     ;
  end;

function HexIPToIP(HexIP:String):String;

var
   GlobalMemory:TGlobalMemory;

implementation
{TGlobalMemory}
constructor TGlobalMemory.Create;
begin
   inherited Create;
   MyData:='';
   Others:=TStringList.Create;
end;
destructor TGlobalMemory.Destroy;
begin
   Others.Free;
   inherited Destroy;
end;

{TUDPSocket}
constructor TUDPSocket.Create;
begin
  try
    inherited Create;
    FNextSocket:=nil;
    FRxOwn:=False;
    FReuseAddr:=False;
    
    FActive:=False;
    FPortNumber:=DGPortNumberValue;

    if GetGPCSRegString('','ReUse UDP Port','Yes') = 'Yes' then
      FReuseAddr:=True;

    Integer(FHSocket):=INVALID_SOCKET;
    FWindowHandle:=AllocateHWnd(WndProc);
  except
    On E : Exception do
      RaiseGUIDException( '{D5F9DE61-0543-4257-98B8-5630AE20B2FC}'+ Application.ExeName , E);
  end;
end;

destructor TUDPSocket.Destroy;
begin
  try
    if FActive then
      Active:=False;
    if FWindowHandle <> 0 then DeAllocateHWnd(FWindowHandle);
    if FNextSocket <> nil then
       FNextSocket.Free;
    inherited Destroy;
  except
    On E : Exception do
      RaiseGUIDException( '{87B6DCE2-213E-4F30-AB4B-6E0B0C8BF770}'+ Application.ExeName , E);
  end;
end;

procedure TUDPSocket.RxDataGram(var Msg: TMessage);
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
      begin
        If Assigned(FOnError) then
          FOnError(Self,'RecvFrom Error '+IntToStr(WSAGetLastError)+' ('+Copy(RxStr,1,20)+')')
        else
          RaiseGUIDError('{3268238C-F719-4BE8-A5A9-1E2CC54990C0}', 'RecvFrom Error '+IntToStr(WSAGetLastError)+' ('+Copy(RxStr,1,20)+')');
         if Assigned(FOnRecvStatus) then FOnRecvStatus(0,Copy(RxStr,1,20),False);
      end;
    end
    else if (Len >= 18) and (Len < $FFFE) and (Copy(RxStr,1,10) = 'CORVUSV300') then
    begin
      if Assigned(FOnRxDGram) then
      begin
        SetLength(RxStr,Len);
        From:=Copy(RxStr,11,8);
        if (FRxOwn) or (From <> HexIPAddress) then
        begin
           FOnRxDGram(Self,From,Copy(RxStr,19,Len));
           if Assigned(FOnRecvStatus) then FOnRecvStatus(Len,From,True);
        end;
      end;
    end
    else
      RaiseGUIDError('{F038C02C-F77F-4692-B25B-F5F114F58E68}', 'Invalid UDP Message on port' + IntToStr(FPortNumber));
  except
    On E : Exception do
      RaiseGUIDException( '{CC2A5B4D-21A8-45DC-8CE1-2E61ACA2682F}'+ Application.ExeName , E);
  end;

end;

function TUDPSocket.SendDGram(Data:String):Boolean;
var
   AddrIn:TSockAddrIn;
   Res:Integer;
begin
  Result:=True;
  try
    if (Self.HexIPAddress = '7F000001') and (not RxOwn) then Exit; // no network card or N/C
    AddrIn.sin_family:=AF_INET;
    AddrIn.sin_addr.s_addr:=INADDR_BROADCAST;
    AddrIn.sin_port:=htons(FPortNumber);
    Data:='CORVUSV300'+HexIPAddress+Data;
    Res:=SendTo(FDramSocket,Pointer(@Data[1])^,Length(Data),0,TSockAddr(AddrIn),SizeOf(AddrIn));
    if Assigned(FOnSendStatus) then FOnSendStatus(Length(Data),Res <> SOCKET_ERROR);
    if Res = SOCKET_ERROR then
    begin
      if Assigned(FOnError) then
        FOnError(Self,'SendTo Error '+IntToStr(WSAGetLastError));
      Result:=False;
    end;
  except
    On E : Exception do
      RaiseGUIDException('{76892E60-135B-421C-94B6-CFC5944A1B25}'+ Application.ExeName , E);
  end;
  if FNextSocket <> nil then
     FNextSocket.SendDGram(Data);
end;

procedure TUDPSocket.SetPortNumbers(Value:String);
var
   SL:TStringList;
   I:Integer;
   PNValue:Integer;
   CurrentSocket:TUDPSocket;
   NextSocket:TUDPSocket;
begin
   if Value <> FPortNumbers then
   begin
      CurrentSocket:=Self;
      FPortNumbers:=Value;
      SL:=TStringList.Create;
      SL.CommaText:=FPortNumbers;
      for I:=0 to SL.Count-1 do
      begin
         PNValue:=StrToIntDef(SL[I],-1);
         if PNValue <> -1 then
         begin
            if CurrentSocket <> nil then
               CurrentSocket.PortNumber:=PNValue;
            PNValue:=-1;
            if I < SL.Count-1 then
               PNValue:=StrToIntDef(SL[I+1],-1);
               
            if (CurrentSocket.FNextSocket = nil) and (PNValue <> -1) then
            begin
               NextSocket:=TUDPSocket.Create;
               NextSocket.FReuseAddr:=CurrentSocket.FReuseAddr;
               NextSocket.FRxOwn    :=CurrentSocket.FRxOwn    ;
               NextSocket.FOnError  :=CurrentSocket.FOnError  ;
               NextSocket.FOnRxDGram:=CurrentSocket.FOnRxDGram;
               NextSocket.Active    :=CurrentSocket.FActive;
               CurrentSocket.FNextSocket:=NextSocket;
               CurrentSocket:=NextSocket;
            end
            else
               CurrentSocket:=CurrentSocket.FNextSocket;
         end;               
      end;
      SL.Free;
      if CurrentSocket = Self then
      begin
         PNValue:=StrToIntDef(Value,DGPortNumberValue);
         CurrentSocket.PortNumber:=PNValue;
      end;
   end;
end;
procedure TUDPSocket.SetPortNumber(Value:Integer);
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
      RaiseGUIDException('{8905D388-EA0A-4091-B6F5-98357857CB3E}'+ Application.ExeName , E);
  end;
end;
procedure TUDPSocket.SetRxOwn(Value:Boolean);
var
   WasActive:Boolean;
begin
   try
     if FRxOwn <> Value then
     begin
       WasActive:=Active;
       if WasActive then Active:=False;
       FRxOwn:=Value;
       Active:=WasActive;
     end;
   except
     On E : Exception do
       RaiseGUIDException('{9E0BEBAD-A928-4844-8592-DE6B1E395C97}'+Application.ExeName , E);
   end;
   if FNextSocket <> nil then
      FNextSocket.SetRxOwn(Value);
end;
procedure TUDPSocket.SetOnError(Value:TUDPEvent);
begin
   FOnError:=Value;
   if FNextSocket <> nil then
      FNextSocket.SetOnError(Value);
end;
procedure TUDPSocket.SetOnRxDGram(Value:TRxEvent);
begin
   FOnRxDGram:=Value;
   if FNextSocket <> nil then
      FNextSocket.SetOnRxDGram(Value);
end;
procedure TUDPSocket.SetReuseAddr(Value:Boolean);
var
   WasActive:Boolean;
begin
   try
     if FReuseAddr <> Value then
     begin
       WasActive:=Active;
       if WasActive then Active:=False;
       FReuseAddr:=Value;
       Active:=WasActive;
     end;
   except
     On E : Exception do
       RaiseGUIDException('{7739C494-BFA8-4E2D-B724-4DBF4A568AAC}'+Application.ExeName , E);
   end;
   if FNextSocket <> nil then
      FNextSocket.SetReuseAddr(Value);
end;

procedure TUDPSocket.SetActive(Value:Boolean);
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
         if WSAStartUp($0101,WSAData) = 0 then
         begin
            SockAddrIn.sin_family:=AF_INET;
            SockAddrIn.sin_addr.s_addr:=INADDR_ANY;  // GetIPAddress;
            SockAddrIn.sin_port:=htons(FPortNumber);
            FHSocket:=WinSock.Socket(PF_INET,SOCK_DGRAM,IPPROTO_UDP);
            if FHSocket <> INVALID_SOCKET then
            begin
               if FReuseAddr then // allow more than one process to open Port number
               begin
                  Opt:=1;
                  Res:=SetSockOpt(FHSocket,SOL_SOCKET,SO_REUSEADDR,PChar(@Opt),SizeOf(Opt));
                  if Res = SOCKET_ERROR then
                     RaiseGUIDError('{7A9FE952-2EEB-4F1D-A9F7-54A2B4EEA43C}','SetSockOpt SO_REUSEADDR Error '+IntToStr(WSAGetLastError));
               end;
//               Opt:=(MaxDGramLength+100)*MaxSendNumber;
//               Res:=SetSockOpt(FHSocket,SOL_SOCKET,SO_SNDBUF,PChar(@Opt),SizeOf(Opt));
//               if Res = SOCKET_ERROR then
//                  ShowMessage('SetSockOpt SO_SNDBUF Error '+IntToStr(WSAGetLastError));
               Res:=Bind(FHSocket,TSockAddr(SockAddrIn),sizeof(SockAddrIn));
               if Res <> SOCKET_ERROR then
               begin
                  Res:=WSAASyncSelect(FHSocket,FWindowHandle,WM_RXDATAGRAM,FD_READ);
                  if (Res = SOCKET_ERROR) and Assigned(FOnError) then
                  begin
                     FOnError(Self,'WSAASyncSelect Error '+IntToStr(WSAGetLastError));
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
               RaiseGUIDException('{03B237AC-3EC8-426C-8B07-6F733252CECE}',E);
         end;
         FHSocket:=INVALID_SOCKET;
         FDramSocket:=INVALID_SOCKET;
         FActive:=False;
      end;
    end;
  except
    On E : Exception do
      RaiseGUIDException( '{87EB3D7C-14F5-4745-9EBC-BCAB7618298A}' + Application.ExeName , E);
  end;
  if FNextSocket <> nil then
     FNextSocket.SetActive(Value);
end;
function HexIPToIP(HexIP:String):String;
var
   IPAsUINT:UINT;
begin
   IPAsUINT:=StrToIntdef('$'+HexIP,0);
   Result:=IntToStr((IPAsUINT shr 24) and $FF)+'.'+
           IntToStr((IPAsUINT shr 16) and $FF)+'.'+
           IntToStr((IPAsUINT shr  8) and $FF)+'.'+
           IntToStr((IPAsUINT       ) and $FF);
end;
function TUDPSocket.GetIPAddress:Integer;
var
   HostEnt: PHostEnt;
   Len:DWord;
   MachineName:array[0..MAX_COMPUTERNAME_LENGTH] of Char;
const
   IPAddress:Integer = 0;
begin
  Result:=IPAddress;
  try
//    if (IPAddress = 0) then
    begin
      Len:=Sizeof(MachineName);
      GetComputerName(MachineName,Len);
      HostEnt:=WinSock.gethostbyname(MachineName);
      if HostEnt <> nil then
         IPAddress:=(Integer(HostEnt^.h_addr^[0]) shl 24) or
                    (Integer(HostEnt^.h_addr^[1]) shl 16) or
                    (Integer(HostEnt^.h_addr^[2]) shl  8) or
                    (Integer(HostEnt^.h_addr^[3]) shl  0);
    end;
    Result:=IPAddress;
  except
    On E : Exception do
      RaiseGUIDException( '{5FF23D06-079B-4844-ABAC-CE130D68747D}'+ Application.ExeName , E);
  end;
end;
function TUDPSocket.HexIPAddress:String;
var
   HostEnt: PHostEnt;
   Len:DWord;
   MachineName:array[0..MAX_COMPUTERNAME_LENGTH] of Char;
const
   IPAddress:String = '';
begin
  try
//    if (IPAddress = '') then
    begin
      Len:=Sizeof(MachineName);
      GetComputerName(MachineName,Len);
      HostEnt:=WinSock.gethostbyname(MachineName);
      if HostEnt <> nil then
         IPAddress:=IntToHex(GetIPAddress,8)
      else
         IPAddress:='';
    end;
    Result:=IPAddress;
  except
    On E : Exception do
      RaiseGUIDException( '{5FF23D06-079B-4844-ABAC-CE130D68747D}'+ Application.ExeName , E);
  end;
end;
procedure TUDPSocket.DefaultHandler(var Message);
begin
  with TMessage(Message) do
     if FWindowHandle <> 0 then
        Result:=CallWindowProc(@DefWindowProc,FWindowHandle,Msg,wParam,lParam);
end;
procedure TUDPSocket.WndProc(var Msg: TMessage);
begin
  try
     Dispatch(Msg);
  except
    On E : Exception do
      RaiseGUIDException( '0371B231-F2C1-4676-8B38-C3BB4A30F517' + Application.ExeName , E);
  end;
end;
{TQueuedUDPSocket}
constructor TQueuedUDPSocket.Create;
begin
   inherited Create;
   AccessingTxQueue:=False;
   TxQueue:=TStringList.Create;
end;
destructor TQueuedUDPSocket.Destroy;
begin
   TxQueue.Free;
   inherited Destroy;
end;
function TQueuedUDPSocket.SendDGram(Data:String):Boolean;
begin
   while AccessingTxQueue do
      Application.ProcessMessages;
   AccessingTxQueue:=True;
   try
      TxQueue.Add(Data);
   finally
      AccessingTxQueue:=False;
   end;
   Result:=True;
end;
procedure TQueuedUDPSocket.OnTimer;
var
  S:String;
  MaxSendCount:Integer;
begin
   AccessingTxQueue:=True;
   try
      MaxSendCount:=0;
      while (TxQueue.Count > 0) and (MaxSendCount < MaxSendNumber) and (not Application.Terminated) do
      begin
         Inc(MaxSendCount);
         S:=TxQueue[0];
         TxQueue.Delete(0);
         inherited SendDGram(S);
         Application.ProcessMessages;
      end;
   except
      // timer error
   end;
   AccessingTxQueue:=False;
end;
  
{TBBits}
function TBBits.BitwiseXOR(RLE:String):String;
var
   MB:TBBits;
   I:Integer;
begin
   MB:=TBBits.Create;
   MB.AsString:=RLE;
   for I:=0 to Size-1 do
      MB[I]:=(Bits[I] xor MB[I]);
   Result:=MB.AsString;
   MB.Free;
end;
function TBBits.BitwiseOR(RLE:String):String;
var
   MB:TBBits;
   I:Integer;
begin
   MB:=TBBits.Create;
   MB.AsString:=RLE;
   for I:=0 to Size-1 do
      MB[I]:=(Bits[I] or MB[I]);
   Result:=MB.AsString;
   MB.Free;
end;
function TBBits.BitwiseAND(RLE:String):String;
var
   MB:TBBits;
   I:Integer;
begin
   MB:=TBBits.Create;
   MB.AsString:=RLE;
   
   if MB.Size > Size then
      MB.Size:=Size
   else
      Size:=MB.Size;
      
   for I:=0 to Size-1 do
      MB[I]:=(Bits[I] and MB[I]);
   Result:=MB.AsString;
   MB.Free;
end;
function TBBits.BitwiseNOT:String;
var
   MB:TBBits;
   I:Integer;
begin
   MB:=TBBits.Create;
   for I:=0 to Size-1 do
      MB[I]:=not Bits[I];
   Result:=MB.AsString;
   MB.Free;
end;
                         
function TBBits.GetBit(Index:Integer):Boolean;
begin
  if (Index >= 0) and (Index < Size) then
    Result:=inherited Bits[Index]
  else
    Result:=False;
end;

procedure TBBits.SetBit(Index:Integer;Value:Boolean);
begin
  if (Index >= 0) then
    inherited Bits[Index]:=Value;
end;

function TBBits.GetRLEBits:String;
var
   I:Integer;
   RL:Integer;
   State:Boolean;
   RSL:TPackStringList;
begin
   Result:='';
   if Size = 0 then Exit;
   RSL:=TPackStringList.Create;
   State:=Bits[0];
   if State then RSL.Add('0');
   RL:=0;
   for I:=0 to Size-1 do
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
   if State then
      RSL.Add(IntToStr(RL));
   Result:=RSL.PackText;
   RSL.Free;
end;
procedure TBBits.SetRLEBits(Value:String);
var
  SL:TPackStringList;
  I:Integer;
  State:Boolean;
  RL:Integer;
  CurrentOfs:Integer;
begin
  Size:=0; // this doesn't clear the associated memory
  if Value = '' then Exit;
  SL:=TPackStringList.Create;
  SL.PackText:=Value;
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
           while RL > 0 do
           begin
              Bits[CurrentOfs]:=False;
              Inc(CurrentOfs);
              Dec(RL);
           end;
        end;
        State:=not State;
     end;
  end;
  SL.Free;
end;
{TStatusBits}
constructor TStatusBits.Create;   
begin
   inherited Create;
   FWSList:=TPackStringList.Create;
end;                                                 
destructor TStatusBits.Destroy;
begin
   FWSList.Free;
   inherited Destroy;
end;
function TStatusBits.Count:Integer;
begin
   Result:=FWSList.Count;
end;
function TStatusBits.Size(Office,WSNumber:Integer):Integer;
var
   Bits:TBBits;
begin
   Result:=0;
   Bits:=GetBits(Office,WSNumber);
   if Bits <> nil then
   begin
      Result:=Bits.Size;
      Bits.Free;
   end;
end;
function TStatusBits.Width:Integer;
var
  I:Integer;
  Bits:TBBits;
begin
   Bits:=TBBits.Create;
   Result:=1;
   for I:=0 to FWSList.Count-1 do
   begin
      Bits.AsString:=Copy(FWSList[I],7,Length(FWSList[I]));
      if Bits.Size > Result then
         Result:=Bits.Size;
   end;
   Bits.Free;
end;
function TStatusBits.OfficeCode(Index:Integer):Integer;
begin
   Result:=-1;
   if (Index >= 0) and (Index < Count) then
      Result:=StrToIntDef('$'+Copy(FWSList[Index],1,4),-1);
end;
function TStatusBits.WSNumber(Index:Integer):Integer;
begin
   Result:=-1;
   if (Index >= 0) and (Index < Count) then
      Result:=StrToIntDef('$'+Copy(FWSList[Index],5,2),-1);
end;
function TStatusBits.GetBit(Office,WS,Index:Integer):Boolean;
var
   B:TBBits;
begin
   Result:=False;       // default to false if not found
   B:=Bits[Office,WS];         // get the bits for this workstation
   if B <> nil then     // if there are some
   begin
      Result:=B[Index]; // return the one required
      B.Free;
   end;
end;
procedure TStatusBits.SetBit(Office,WS,Index:Integer;State:Boolean);
var
   B:TBBits;
begin
   B:=Bits[Office,WS];         // get the bits for this workstation
   if (B <> nil) then
   begin
      if (B[Index] <> State) then     // if the bit needs changing 
      begin
         B[Index]:=State; // set the bit
         Bits[Office,WS]:=B;     // set the bits for the workstation
      end;
      B.Free;
   end;
   if Assigned(FOnChange) then FOnChange(Self);
end;
function TStatusBits.GetWSIndex(Office,WS:Integer):Integer;
var
   I:Integer;
   Search:String;
begin
   Result:=-1;
   Search:=IntToHex(Office,4)+IntToHex(WS,2);
   I:=0;
   while I < FWSList.Count do
   begin
      if Search = Copy(FWSList[I],1,6) then
      begin
         Result:=I;
         break;
      end;
      Inc(I);
   end;
end;
function TStatusBits.CountBits(Office,WS:Integer):Integer;
var
   WSIndex:Integer;
   Bits:TBBits;
   I:Integer;
begin 
   Result:=0;
   WSIndex:=GetWSIndex(Office,WS);
   if WSIndex <> -1 then
   begin
      Bits:=TBBits.Create;
      Bits.Size:=0;
      Bits.AsString:=Copy(FWSList[WSIndex],7,Length(FWSList[WSIndex]));
      for I:=0 to Bits.Size do
         if Bits[I] then Inc(Result);
      Bits.Free;
   end;
end;
function TStatusBits.GetBits(Office,WS:Integer):TBBits;
var
   WSIndex:Integer;
begin
   WSIndex:=GetWSIndex(Office,WS);
   Result:=TBBits.Create;
   Result.Size:=0;
   if WSIndex <> -1 then
      Result.AsString:=Copy(FWSList[WSIndex],7,Length(FWSList[WSIndex]));
end;
procedure TStatusBits.SetBits(Office,WS:Integer;Value:TBBits);
var
   WSIndex:Integer;
begin
   WSIndex:=GetWSIndex(Office,WS);
   if Trim(Value.AsString) = '' then
   begin
      if WSIndex <> -1 then FWSList.Delete(WSIndex);
   end
   else
   begin
      if WSIndex = -1 then
         FWSList.Add(IntToHex(Office,4)+IntToHex(WS,2)+Value.AsString)
      else
         FWSList[WSIndex]:=IntToHex(Office,4)+IntToHex(WS,2)+Value.AsString;
   end;
   if Assigned(FOnChange) then FOnChange(Self);
end;
function TStatusBits.GetState:String;
begin
   Result:=FWSList.Text;
end;
procedure TStatusBits.SetState(Value:String);
begin
   if FWSList.Text <> Value then
   begin
      FWSList.Text:=Value;
      if Assigned(FOnChange) then FOnChange(Self);
   end;
end;
function TStatusBits.Missing(Value:String):String; // bits only in Value i.e. (Self XOR Value) AND Value
var                                                // 11111110 XOR 11000111 = 00111001 AND 11000111 = 00000001
   WSNumList:TStringList;
   I,Office,WSNumber:Integer;
   ResSB:TStatusBits;
   BitsA,BitsB:TBBits;
begin
   ResSB:=TStatusBits.Create;

   WSNumList:=TStringList.Create; // list of all WS's from Self & Value
   WSNumList.Text:=Value;
   for I:=0 to WSNumList.Count-1 do // all WS's from Value
      WSNumList[I]:=Copy(WSNumList[I],1,6);
   for I:=0 to FWSList.Count-1 do // add all missing WS's from Self
   begin
      if WSNumList.IndexOf(Copy(FWSList[I],1,6)) = -1 then
         WSNumList.Add(Copy(FWSList[I],1,6));
   end;

   ResSB.State:=Value;
   for I:=0 to WSNumList.Count-1 do // each workstation
   begin
      Office:=StrToIntDef('$'+Copy(WSNumList[I],1,4),-1);
      WSNumber:=StrToIntDef('$'+Copy(WSNumList[I],5,2),-1);
      if (Office <> -1) and (WSNumber <> -1) then
      begin
         BitsA:=ResSB.GetBits(Office,WSNumber);
         BitsB:=GetBits(Office,WSNumber);

         BitsB.AsString:=BitsB.BitwiseXOR(BitsA.AsString);
         BitsB.AsString:=BitsB.BitwiseAND(BitsA.AsString);
         ResSB.SetBits(Office,WSNumber,BitsB);

         BitsB.Free;
         BitsA.Free;
      end;
   end;
   WSNumList.Free;
   Result:=ResSB.State;
   ResSB.Free;
end;
function TStatusBits.Matching(Value:String):String; // bits in Self AND StatusBits
var                                                 // 00111001 AND 11000111 = 00000001
   WSNumList:TStringList;
   I,Office,WSNumber:Integer;
   ResSB:TStatusBits;
   BitsA,BitsB:TBBits;
begin
   ResSB:=TStatusBits.Create;

   WSNumList:=TStringList.Create; // list of all WS's from Self & Value
   WSNumList.Text:=Value;
   for I:=0 to WSNumList.Count-1 do // all WS's from Value
      WSNumList[I]:=Copy(WSNumList[I],1,6);
   for I:=0 to FWSList.Count-1 do // add all missing WS's from Self
   begin
      if WSNumList.IndexOf(Copy(FWSList[I],1,6)) = -1 then
         WSNumList.Add(Copy(FWSList[I],1,6));
   end;

   ResSB.State:=Value;
   for I:=0 to WSNumList.Count-1 do // each workstation
   begin
      Office:=StrToIntDef('$'+Copy(WSNumList[I],1,4),-1);
      WSNumber:=StrToIntDef('$'+Copy(WSNumList[I],5,2),-1);
      if (Office <> -1) and (WSNumber <> -1) then
      begin
         BitsA:=ResSB.GetBits(Office,WSNumber);
         BitsB:=GetBits(Office,WSNumber);

         BitsB.AsString:=BitsB.BitwiseAND(BitsA.AsString);
         ResSB.SetBits(Office,WSNumber,BitsB);

         BitsB.Free;
         BitsA.Free;
      end;
   end;
   WSNumList.Free;
   Result:=ResSB.State;
   ResSB.Free;
end;
procedure TStatusBits.Merge(Value:String); // Self = Self OR Value
var                                        // 00111001 OR 11000111 = 11111111
   WSNumList:TStringList;
   I,Office,WSNumber:Integer;
   ResSB:TStatusBits;
   BitsA,BitsB:TBBits;
begin
   if Value = '' then Exit;
   ResSB:=TStatusBits.Create;

   WSNumList:=TStringList.Create; // list of all WS's from Self & Value
   WSNumList.Text:=Value;
   for I:=0 to WSNumList.Count-1 do // all WS's from Value
      WSNumList[I]:=Copy(WSNumList[I],1,6);
   for I:=0 to FWSList.Count-1 do // add all missing WS's from Self
   begin
      if WSNumList.IndexOf(Copy(FWSList[I],1,6)) = -1 then
         WSNumList.Add(Copy(FWSList[I],1,6));
   end;

   ResSB.State:=Value;
   for I:=0 to WSNumList.Count-1 do // each workstation
   begin
      Office:=StrToIntDef('$'+Copy(WSNumList[I],1,4),-1);
      WSNumber:=StrToIntDef('$'+Copy(WSNumList[I],5,2),-1);
      if (Office <> -1) and (WSNumber <> -1) then
      begin
         BitsA:=ResSB.GetBits(Office,WSNumber);
         BitsB:=GetBits(Office,WSNumber);

         BitsB.AsString:=BitsB.BitwiseOR(BitsA.AsString);
         ResSB.SetBits(Office,WSNumber,BitsB);

         BitsB.Free;
         BitsA.Free;
      end;
   end;
   WSNumList.Free;
   State:=ResSB.State;
   ResSB.Free;
   if Assigned(FOnChange) then FOnChange(Self);
end;
function TStatusBits.DrawOn(Office:Integer;Canvas:TCanvas;InRect:TRect;MaxBits:Integer;Interval:Integer;Clear:Boolean;ThisWorkstation,ThisOffice:Integer;WSList:TStrings):Integer;
var
   I,J:Integer;
   BC:TColor;
   BitWidth,LeftOffset,TopOffset,RectWidth:Integer;
   Bits:TBBIts;
   XScale,YScale:Double;
   RLEList:TPackStringList;
   Limit,Index:Integer;
   LastLine:Integer;
begin
   Result:=Canvas.TextHeight('Wg');
   BC:=Canvas.Brush.Color;
   BitWidth:=MaxBits;
   FWSList.Sort;
   if MaxBits = 0 then
   begin
      for I:=0 to FWSList.Count-1 do
      begin
         Bits:=GetBits(StrToIntDef('$'+Copy(FWSList[I],1,4),-1),StrToIntDef('$'+Copy(FWSList[I],5,2),-1));
         if BitWidth < Bits.Size then
            BitWidth:=Bits.Size;
         Bits.Free;
      end;
   end;

   LeftOffset:=Canvas.TextWidth('00000.000');
   XScale:=((InRect.Right-InRect.Left)-LeftOffset) / BitWidth;
   YScale:=Canvas.TextHeight('Wg');

   Canvas.Brush.Color:=clWhite;
   Canvas.Font.Color:=clBlack;
   if Clear then
      Canvas.FillRect(InRect);

   Canvas.Brush.Color:=clSilver;
   if Canvas.Pen.Color = clBlack then
      Canvas.Brush.Style:=bsFDiagonal
   else if Canvas.Pen.Color = clBlue then
      Canvas.Brush.Style:=bsSolid
   else
      Canvas.Brush.Style:=bsBDiagonal;

   RLEList:=TPackStringList.Create;
   Limit:=FWSList.Count-1;
   LastLine:=0;
   for I:=0 to Limit do
   begin
      TopOffset:=I;
      Index:=I;
//      if WSList <> nil then
//      begin
//         TopOffset:=I;
//         Index:=GetWSIndex(Office,I);
//      end;
      if Index >= 0 then
      begin
         if (FWSList[Index] <> '') and (FWSList[Index][1] = 'V') then
            FWSList[Index]:=Copy(FWSList[Index],10,Length(FWSList[Index]));
         RLEList.PackText:=Copy(FWSList[Index],7,Length(FWSList[Index]));
         if (StrToIntDef('$'+Copy(FWSList[Index],5,2),0) = ThisWorkstation)
         and (StrToIntDef('$'+Copy(FWSList[Index],1,4),0) = ThisOffice) then
         begin
            Canvas.Font.Color:=clNavy;
            if Canvas.Brush.Color = clSilver then
            begin
               Canvas.Brush.Style:=bsDiagCross;
               Canvas.Brush.Color:=clNavy;
            end;
         end
         else
         begin
            Canvas.Font.Color:=clBlack;
            Canvas.Brush.Color:=clSilver;
            Canvas.Brush.Style:=bsFDiagonal
         end;
         LeftOffset:=Canvas.TextWidth('00000.000');
         for J:=0 to RLEList.Count-1 do
         begin
            RectWidth:=Trunc(StrToInt(RLEList[J])*XScale);
            if (J and 1) = 1 then
               Canvas.Rectangle(InRect.Left+LeftOffset,
                                InRect.Top+Trunc(TopOffset*YScale),
                                InRect.Left+LeftOffset+RectWidth,
                                InRect.Top+Trunc((TopOffset+1)*YScale)-1);
            Inc(LeftOffset,RectWidth);
         end;
//         Canvas.Brush.Color:=clWhite;
         Canvas.TextOut(InRect.Left,
                        InRect.Top+Trunc(TopOffset*YScale),
                        IntToStr(StrToInt('$'+Copy(FWSList[Index],1,4)))+'.'+
                        IntToStr(StrToInt('$'+Copy(FWSList[Index],5,2))));
         if TopOffset >= LastLine then
            LastLine:=TopOffset+1;
      end;
   end;
   RLEList.Free;
   if LastLine > 0 then
   begin
      Canvas.Pen.Color:=clRed;
      Canvas.Font.Color:=clRed;
      LeftOffset:=Canvas.TextWidth('00000.000');
      for I:=0 to ((InRect.Right-InRect.Left)-LeftOffset) div Trunc((Interval*XScale)) do
      begin
         Canvas.MoveTo(Trunc(InRect.Left+LeftOffset+I*Interval*XScale),InRect.Top);
         Canvas.LineTo(Trunc(InRect.Left+LeftOffset+I*Interval*XScale),Trunc(InRect.Top+LastLine*YScale)-1);
         Canvas.TextOut(Trunc(InRect.Left+LeftOffset+I*Interval*XScale)-Canvas.TextWidth(IntToStr(Interval*I)) div 2,Trunc(InRect.Top+LastLine*YScale),IntToStr(Interval*I));
      end;
      Result:=Trunc(LastLine*YScale)+Canvas.TextHeight('Wg');
   end;
   Canvas.Brush.Color:=BC;
   Canvas.Brush.Style:=bsSolid;
end;     
{TTimedStatusBits}
constructor TTimedStatusBits.Create;
begin
   inherited Create;
   AddingBits:=False;
   FList:=TPackStringList.Create;
   FNextProcess:=0;
   FCurrentIndex:=0;
end;                                                 
destructor TTimedStatusBits.Destroy;
begin
   FList.Free;
   inherited Destroy;
end;
procedure TTimedStatusBits.AddBits(Value:String);
var
   StatusBits:TStatusBits;
begin
   StatusBits:=TStatusBits.Create;
   StatusBits.State:=Value;
   AddingBits:=True;
   try
      while FList.Count <= FCurrentIndex do FList.Add('');
      StatusBits.Merge(FList[FCurrentIndex]);
      FList[FCurrentIndex]:=StatusBits.State;
   except
   end;
   AddingBits:=False;
   if FCurrentIndex >= FList.Count then 
      RaiseGUIDError('{CE460443-4704-4332-9698-E36245AB14CF}','Dodgy CurrentIndex !');
   Merge(StatusBits.State);
   StatusBits.Free;
end;                                      
procedure TTimedStatusBits.CheckTimeOut;
var
   I:Integer;
   TS:Integer;
begin
   TS:=(DateTimeToTimeStamp(Now).Time div 1000) * 1000; // time in ms to the nearest second
   if (FNextProcess <= TS) and (not AddingBits) then
   begin
      FNextProcess:=TS+(CheckTimeOutDelay*1000); // process again in 1 second
      if FCurrentIndex < ListTimeOut then
         Inc(FCurrentIndex)
      else if FList.Count > 0 then
         FList.Delete(0);
      
      State:='';
      for I:=0 to FList.Count-1 do
         Merge(FList[I]);
   end;
end;
{TStatusMonitor}
constructor TStatusMonitor.Create;
begin
   inherited Create;
   FUDPSocket:=TQueuedUDPSocket.Create;
   FUDPSocket.Active:=False;
   FUDPSocket.PortNumbers:=DGPortNumber;
   FUDPSocket.OnRxDGram:=DGReceive;
   FUDPSocket.OnError  :=DGError  ;
   FUDPSocket.OnSendStatus:=SendStat;
   FUDPSocket.OnRecvStatus:=RecvStat;
   FCurrentStatus:=TStatusBits.Create;
   FReceivedBlocks:=TStatusBits.Create;
   FPrevRequested:=TTimedStatusBits.Create;
   FAcceptedProps:=TTimedStatusBits.Create;
   FCurrentStatus.OnChange:=Changed;
   FReceivedBlocks.OnChange:=Changed;
   FPrevRequested.OnChange:=Changed;
   FAcceptedProps.OnChange:=Changed;
   FActive:=False;
end;
destructor TStatusMonitor.Destroy;
begin
   Active:=False;
   FUDPSocket.Free;
   FCurrentStatus.Free;
   FReceivedBlocks.Free;
   FPrevRequested.Free;
   FAcceptedProps.Free;
   inherited Destroy;
end;
procedure TStatusMonitor.SendStat(Size:Integer;Stat:Boolean);
begin
   if Assigned(FOnSendStatus) then FOnSendStatus(Size,Stat);
end;
procedure TStatusMonitor.RecvStat(Size:Integer;From:String;Stat:Boolean);
begin
   if Assigned(FOnRecvStatus) then FOnRecvStatus(Size,From,Stat);
end;

procedure TStatusMonitor.Changed(Sender:TObject);
begin
   if Assigned(FOnChange) then FOnChange(Self);
end;
procedure TStatusMonitor.SetStatus(Status:String);
begin
   CurrentStatus.State:=Status;
end;
procedure TStatusMonitor.UpdateStatus(Office,Workstation,BlockNumber:Integer);
begin
   CurrentStatus.SetBit(Office,Workstation,BlockNumber,True);
end;
procedure TStatusMonitor.TimerTick;
var
   TS:Integer;
const 
   NextStatusTransmit:Integer = 0;
begin
   if not FActive then Exit;
   FUDPSocket.OnTimer;
   TS:=(DateTimeToTimeStamp(Now).Time div 1000) * 1000; // time in ms to the nearest second
   if NextStatusTransmit <= TS then
   begin
      NextStatusTransmit:=TS+(SendStatementDelay*1000); // process again in SendStatmentDelay seconds
      SendStatus(FCurrentStatus.State);
   end;
   if FPrevRequested <> nil then FPrevRequested.CheckTimeOut;
   if FAcceptedProps <> nil then FAcceptedProps.CheckTimeOut;
end;
procedure TStatusMonitor.SetActive(Value:Boolean);
begin
   if FActive <> Value then
   begin
      FActive:=Value;
      FUDPSocket.Active:=Value;
   end;
end;
procedure TStatusMonitor.DGError(Sender:TUDPSocket;EMessage :String);
begin
   if Assigned(FOnError) then 
      FOnError(Self,EMessage);
end;
procedure TStatusMonitor.DGReceive(Sender:TUDPSocket;From,Data:String);
var
   WorkStation:Integer;
   Command:Char;
const
   IPAddresses:TStringList = nil;
begin
   if IPAddresses = nil then
      IPAddresses:=TStringList.Create;
   if IPAddresses.IndexOf(From) = -1 then
   begin
      IPAddresses.Add(From);
      IPAddresses.SaveToFile('C:\IPAddresses.txt');
   end;
   // data in the format 
   //   CXXXXddddddddddddddd - C = Command XXXX = Source W/S (Hex) dddd = Data
   if Length(Data) < 5 then Exit;
   if Assigned(FOnReceive) then FOnReceive(Self,Data);
   Command:=Data[1];
   if Command in ['A','C','D','M','P','R','S','r','p','s'] then // Accept,Data,Proposal,Request,Status
   begin                                                       
      WorkStation:=StrToIntDef('$'+Copy(Data,2,4),0);          
      Data:=Copy(Data,6,Length(Data));                         
      if (Command <> 'A') and (WorkStation = ThisWorkStation) then
      begin
         RaiseGUIDError('{7B373B43-CB21-459F-AFA7-8B9B20477D6C}','Duplicate Workstation Number '+IntToStr(WorkStation)+' '+From);
         ShowMessage('Duplicate Workstation Number! '+IntToStr(WorkStation)+' ('+From+')');
         Exit;
      end;
      case Command of
         'A'     : ReceiveAccept     (From,WorkStation,Data);
         'D'     : ReceiveData       (Workstation,Data);
         'p'     : ReceiveProposal   (False,WorkStation,Data);
         'P'     : ReceiveProposal   (True ,WorkStation,Data);
         'r'     : ReceiveRequest    (WorkStation,From,Data);
         'R'     : ReceiveOldRequest (WorkStation,From,Data);
         'S','s' : ReceiveStatus     (From,Data);
         'M'     : UpdateGlobalMemory(WorkStation,From,Data);
         'C'     : ReceiveCommand    (WorkStation,From,Data);
      end;         
   end;
end;
procedure TStatusMonitor.ReceiveCommand(WorkStation:Integer;From,Data:String);
var
   ToWorkstation:Integer;
   CommandCode:TCommandType;
begin
   ToWorkstation:=StrToIntDef('$'+Copy(Data,1,4),-1);
   if (ToWorkstation = ThisWorkstation) or (ToWorkstation = 0) {All} then
   begin
      CommandCode:=TCommandType(StrToIntDef('$'+Copy(Data,5,4),-1));
      Data:=Copy(Data,9,Length(Data));  
      case CommandCode of
         ctShutdown : begin
                         Windows.Beep(5000,100);
                         Sleep(100);
                         Windows.Beep(5000,100);
                         Sleep(100);
                         Windows.Beep(5000,100);
                         Sleep(100);
                         if Assigned(FOnPowerOff) then
                            FOnPowerOff(nil);
                      end;                  
         ctRestart  : if Assigned(FOnRestart) then
                         FOnRestart(nil);
      end;   
   end;
end;
procedure TStatusMonitor.UpdateGlobalMemory(WorkStation:Integer;From,Data:String);
var
   SL:TPackStringList;
   I:Integer;
begin
   SL:=TPackStringList.Create;
   SL.PackText:=Data;
   if SL.Count > 1 then
   begin
      I:=GlobalMemory.Others.IndexOf(SL[0]);
      if (I <> -1) and (GlobalMemory.Others.Objects[I] <> nil) then
         TStringObject(GlobalMemory.Others.Objects[I]).Value:=SL[1];
   end;
   SL.Free;
end;
function TStatusMonitor.IgnoringWS(WS:Integer):Boolean;
var
   ValidWS:TStringList;
   I:Integer;
const
   IgnoreList:TStringlist = nil;
begin
   if IgnoreList = nil then
   begin
      IgnoreList:=TStringlist.Create;
      ValidWS:=TStringList.Create;
      ValidWS.CommaText:=ValidWorkstationList;
      for I:=0 to ValidWS.Count-1 do
      begin
         if Length(ValidWS[I]) <> 6 then
         begin
            IgnoreList.Add(IntToHex(StrToIntDef(Trim(ValidWS[I]),0),2));
         end
         else
            IgnoreList.Add(Copy(ValidWS[I],5,2));
      end;   
      if IgnoreList.Count <> 0 then
         for I:=250 to 255 do
            if IgnoreList.IndexOf(IntToHex(I,2)) = -1 then
               IgnoreList.Add(IntToHex(I,2));
      ValidWS.Free;
   end;       
   if IgnoreList.Count = 0 then
      Result:=False
   else
      Result:=IgnoreList.IndexOf(IntToHex(WS,2)) = -1;
end;     


function TStatusMonitor.RemoveIgnoredWS(Status:String):String;
var                                                // 11111110 XOR 11000111 = 00111001 AND 11000111 = 00000001
   WSNumList:TStringList;
   ValidWS:TStringList;
   I:Integer;
   ThisOffice:Integer;
   ThisWS    :Integer;
begin
   Result:=Status;
   if ValidWorkstationList = '' then Exit;
   ThisOffice:=StrToIntDef(GetGPCSRegString('OfficeInfo','Office ID','1000'),1000);
   ThisWS    :=StrToIntDef(GetGPCSRegString('Workstation','Ident','99'),99);
   ValidWS:=TStringList.Create;
   ValidWS.CommaText:=ValidWorkstationList;
   for I:=0 to ValidWS.Count-1 do
   begin
      if Length(ValidWS[I]) <> 6 then
      begin
         ValidWS[I]:=IntToHex(ThisOffice,4)+IntToHex(StrToIntDef(Trim(ValidWS[I]),0),2);
      end;
   end;
   for I:=250 to 255 do
      if ValidWS.IndexOf(IntToHex(ThisOffice,4)+IntToHex(I,2)) = -1 then
         ValidWS.Add(IntToHex(ThisOffice,4)+IntToHex(I,2));
   if ValidWS.IndexOf(IntToHex(ThisOffice,4)+IntToHex(ThisWS,2)) = -1 then
      ValidWS.Add(IntToHex(ThisOffice,4)+IntToHex(ThisWS,2));
   ValidWorkstationList:=ValidWS.CommaText;
   WSNumList:=TStringList.Create;
   WSNumList.Text:=Status;
   I:=0;
   while I < WSNumList.Count do
   begin
      if ValidWS.IndexOf(Copy(WSNumList[I],1,6)) = -1 then
         WSNumList.Delete(I)
      else
         Inc(I);
   end;
   Result:=WSNumList.Text;
   ValidWS.Free;
   WSNumList.Free;
end;     
procedure TStatusMonitor.ReceiveData(Workstation:Integer;Data:String);
begin
   if IgnoringWS(Workstation) then Exit;
   if Assigned(FOnDataRx) then
      FOnDataRx(Self,Data);
   if Assigned(FOnChange) then FOnChange(Self);
end;
procedure TStatusMonitor.SendDataGram(Data:String);
begin
   if Trim(Data) = '' then Exit;
//   if Length(Data) > MaxDGramLength then
//      Data:=Copy(Data,1,MaxDGramLength);
   FUDPSocket.SendDGram(Data);
   if Assigned(FOnSend) then FOnSend(Self,Data);
end;
procedure TStatusMonitor.SendGlobalMemory(Data:String);
begin
   if Data = '' then Exit;
   SendDataGram('G'+IntToHex(FThisWorkstation,4)+Data);
end;          
procedure TStatusMonitor.SendData(Data:String);
begin
   if Data = '' then Exit;
   SendDataGram('D'+IntToHex(FThisWorkstation,4)+Data);
end;          
procedure TStatusMonitor.SendStatus(Status:String);
begin
//   if Status = '' then Exit;
   SendDataGram('s'+IntToHex(FThisWorkstation,4)+'V'+IntToHex(FThisVersion,8)+RemoveIgnoredWS(Status));
end;          
procedure TStatusMonitor.ReceiveStatus(From,Status:String);
var
  CSMissing:String;
  PRMissing:String;
  StatusVersion:Integer;
const
  ReplaceList:TStringList = nil;
  NoReplaceUntil:TDateTime = 0;
begin
   if ReplaceList = nil then
      ReplaceList:=TStringList.Create;
   if Copy(Status,1,1) = 'V' then
   begin
      StatusVersion:=StrToIntDef('$'+Copy(Status,2,8),0);
      if (StatusVersion < ThisVersion) and (ReplaceList.IndexOf(From) = -1) then
      begin
         if AutoReplaceOld and (ReplaceList.IndexOf(From) = -1)
         and ((NoReplaceUntil = 0) or (NoReplaceUntil > Now))
         and Assigned(FOnReqReplace) then
         begin
            ReplaceList.Add(From);
            FOnReqReplace(From);
            NoReplaceUntil:=Now+OneSecond*(30+(Random(30)));
         end;
      end;
      Status:=RemoveIgnoredWS(Copy(Status,10,Length(Status)));
      CSMissing:=FCurrentStatus.Missing(Status);
      PRMissing:=FPrevRequested.Missing(CSMissing);
      PRMissing:=FReceivedBlocks.Missing(PRMissing);
      SendRequest(PRMissing);  
   end
   else
   begin
      if ReplaceList.IndexOf(From) = -1 then
      begin
         if AutoReplaceOld then
         begin
            ReplaceList.Add(From);
            if Assigned(FOnReqReplace) then
               FOnReqReplace(From);
         end;
      end;
   end;
end;
procedure TStatusMonitor.SendRequest(Request:String);
begin
   if Request = '' then Exit;
   PrevRequested.AddBits(Request);
   SendDataGram('r'+IntToHex(FThisWorkstation,4)+Request);
end;
procedure TStatusMonitor.ReceiveRequest(WorkStation:Integer;From,Request:String);
begin
   SendProposal(FThisWorkstation,WorkStation,FCurrentStatus.Matching(Request));
end;
procedure TStatusMonitor.ReceiveOldRequest(WorkStation:Integer;From,Request:String);
begin
   SendOldProposal(FThisWorkstation,WorkStation,FCurrentStatus.Matching(Request));
end;
procedure TStatusMonitor.SendCommand(FromWorkstation,ToWorkstation:Integer;CommandCode:TCommandType;CommandString:String);
begin
   if CommandCode = ctShutdown then
   begin
      Windows.Beep(5000,50);
      Sleep(100);
      Windows.Beep(1000,100);
      Sleep(100);
      Windows.Beep(2000,100);
      Sleep(100);
      Windows.Beep(5000,100);
   end;
   SendDataGram('C'+IntToHex(FromWorkstation,4)+IntToHex(ToWorkstation,4)+IntToHex(Integer(CommandCode),4)+CommandString);
end;                                
procedure TStatusMonitor.SendProposal(FromWorkstation,ToWorkstation:Integer;Proposal:String);
begin
   if Proposal = '' then Exit;
   SendDataGram('p'+IntToHex(FromWorkstation,4)+IntToHex(ToWorkstation,4)+Proposal);
end;                                
procedure TStatusMonitor.SendOldProposal(FromWorkstation,ToWorkstation:Integer;Proposal:String);
begin
   if Proposal = '' then Exit;
   SendDataGram('P'+IntToHex(FromWorkstation,4)+Proposal);
end;                                
procedure TStatusMonitor.ReceiveProposal(Old:Boolean;Workstation:Integer;Proposal:String);
var
  CSMissing:String;
  APMissing:String;
  ProposalRequestedBy:Integer;
begin
   if Old then
   begin
      Proposal:=RemoveIgnoredWS(Proposal);
      CSMissing:=FCurrentStatus.Missing(Proposal);
      APMissing:=FAcceptedProps.Missing(CSMissing);
      APMissing:=FReceivedBlocks.Missing(APMissing);
      SendAccept(Workstation,APMissing);
   end
   else
   begin
      ProposalRequestedBy:=StrToIntDef('$'+Copy(Proposal,1,4),-1);
      if (ProposalRequestedBy = ThisWorkstation) then
      begin
         Proposal:=Copy(Proposal,5,Length(Proposal));  
         Proposal:=RemoveIgnoredWS(Proposal);
         CSMissing:=FCurrentStatus.Missing(Proposal);
         APMissing:=FAcceptedProps.Missing(CSMissing);
         APMissing:=FReceivedBlocks.Missing(APMissing);
         SendAccept(Workstation,APMissing);
      end;
   end;
end;  
procedure TStatusMonitor.SendAccept(Workstation:Integer;Accept:String);
begin
   if Accept = '' then Exit;
   Accept:=CutDown(Accept); // limit to DGBlockTxMaxLimit blocks
   AcceptedProps.AddBits(Accept);
   SendDataGram('A'+IntToHex(Workstation,4)+Accept);
end;
procedure TStatusMonitor.ReceiveAccept(From:String;Workstation:Integer;Accept:String);
var
   I,J,Office,WSNumber:Integer;
   StatusBits:TStatusBits;
   TxStream:TStringStream;
   BlocksAdded:Integer;
   Err:String;
const
   SendingToList:TStringList = nil;
begin
//   ShowMessage('Receive Accept from '+From+' '+IntToStr(Workstation)+Accept);
   if SendingToList = nil then
      SendingToList:=TStringList.Create;
   if (Workstation = FThisWorkstation) and Assigned(FOnDataTx) and (SendingToList.IndexOf(From) = -1) then
   begin
      BlocksAdded:=0;
      SendingToList.Add(From); // only open one TCP session to a machine at any time
      try
         TxStream:=TStringStream.Create('');
         StatusBits:=TStatusBits.Create;
         StatusBits.State:=Accept;
         for I:=0 to StatusBits.Count-1 do
         begin
            WSNumber:=StatusBits.WSNumber(I);
            Office  :=StatusBits.OfficeCode(I);
            if CanSendWholeFiles
            and ((FCurrentStatus.GetBits(Office,WSNumber).AsString = StatusBits.GetBits(Office,WSNumber).AsString) // all bits requested
            or ((WSNumber = ThisWorkstation) and (StatusBits.CountBits(Office,WSNumber) > SendFileIfOverBitCount)))  then
            begin
               FOnDataTx(Self,Office,WSNumber,-1,TxStream); // whole file
               if (DGBlockTxMaxLimit > 0) 
               and (TxStream.Size > (DGBlockTxMaxLimit*1024)) then  // enough data
                  Break;
            end      
            else
            begin
               for J:=0 to StatusBits.Size(Office,WSNumber)-1 do
               begin
                  if StatusBits.Bit[Office,WSNumber,J] then
                  begin
                     FOnDataTx(Self,Office,WSNumber,J,TxStream);
                     Inc(BlocksAdded);
                  end;
                  if (DGBlockTxMaxLimit > 0) 
                  and (TxStream.Size > (DGBlockTxMaxLimit*1024)) then  // enough data
                     Break;
               end;
               if (DGBlockTxMaxLimit > 0) 
               and (BlocksAdded > DGBlockTxMaxLimit) then  // enough data
                  Break;
            end;
         end;
         StatusBits.Free;
         if (TxStream.Size > 0) and Assigned(FOnSendData) then
            Err:=FOnSendData(HexIPToIP(From),60,ctSetDataLocal,TxStream,True); // send it
         if Copy(Err,1,5) = 'Error' then
           RaiseGUIDError('{F7DF4C0C-509E-49F1-9511-C205834579BB}',Err);
         TxStream.Free;
      finally
         SendingToList.Delete(SendingToList.IndexOf(From)); // allow another session
      end;
   end;
end;
function TStatusMonitor.CutDown(Bitmap:String):String;
var
   I,J,Idx:Integer;
   WS,Office:Integer;
   StatusBits:TStatusBits;
   BitsList:TStringList;
   Bits:TBBits;
   MS,Limit:Integer;
begin
   Result:=Bitmap;
   if DGBlockTxMaxLimit = 0 then Exit;
   BitsList:=TStringList.Create;

   StatusBits:=TStatusBits.Create;
   StatusBits.State:=Bitmap;
   Limit:=0;
   MS:=1;
   for I:=0 to StatusBits.Count-1 do // get all workstation bits
   begin
      WS:=StatusBits.WSNumber(I);
      Office:=StatusBits.OfficeCode(I);
      Bits:=StatusBits.Bits[Office,WS];
      if Bits.Size > MS then MS:=Bits.Size;
      BitsList.AddObject(IntToHex(Office,4)+IntToHex(WS,2),Bits);
   end;
   if RequestLastRecordFirst then
   begin
      for J:=0 to MS-1 do
      begin
         for I:=0 to BitsList.Count-1 do // all workstations
         begin
            Bits:=TBBits(BitsList.Objects[I]);
            if Bits <> nil then
            begin
               Idx:=Bits.Size-J;
               if Bits[Idx] then
               begin
                  if Limit < DGBlockTxMaxLimit then
                     Inc(Limit)           // keep this bit in the array
                  else
                     Bits[Idx]:=False; // clear this bit from the array
               end;
            end;
         end;
      end;
   end
   else
   begin
      for I:=0 to BitsList.Count-1 do // all workstations
      begin
         Office:=StrToInt('$'+Copy(BitsList[I],1,4));
         WS    :=StrToInt('$'+Copy(BitsList[I],5,2));
         if FCurrentStatus.Bits[Office,WS].AsString <> '' then // we have some bits
         begin
            Bits:=TBBits(BitsList.Objects[I]);
            for J:=0 to Bits.Size-1 do
            begin
               if Bits[J] then
               begin
                  if Limit < DGBlockTxMaxLimit then
                     Inc(Limit)           // keep this bit in the array
                  else
                     Bits[J]:=False; // clear this bit from the array
               end;
            end;
         end;
      end;
   end;
   for I:=0 to BitsList.Count-1 do // assign updated bits back to result
   begin
      if BitsList.Objects[I] <> nil then
      begin
         Office:=StrToInt('$'+Copy(BitsList[I],1,4));
         WS    :=StrToInt('$'+Copy(BitsList[I],5,2));
         StatusBits.Bits[Office,WS]:=TBBits(BitsList.Objects[I]);
         BitsList.Objects[I].Free;
      end;
   end;
   Result:=StatusBits.State;
   StatusBits.Free;
   BitsList.Free;
end;

initialization
   GlobalMemory:=TGlobalMemory.Create;
    
finalization
   GlobalMemory.Free;
   GlobalMemory:=nil;                                                 

end.
