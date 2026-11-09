unit DGramU;

interface

uses
   Windows,Messages,Graphics,Classes,Forms,Extctrls,Sysutils,Dialogs,Registry,
   WinSock,GPCSGUID,PackStrListU;

const
   WM_RXDATAGRAM      = WM_USER+1;
   
type
  TDGramSocket = class;
  TSocketNotifyEvent = procedure (Sender:TDGramSocket;EMessage:String) of object;
  TRxDGramNotifyEvent =  procedure (Sender:TDGramSocket;From,Data:String) of object;
  
  TDGramBuffer = class(TObject)
  private
    Parent:TDGramSocket;
    TXList:TPackStringList;
  public        
    constructor Create;
    destructor Destroy; override;
    procedure PostDGram(Data:String);               
  published
  end;
  
  TDGramSocket = class(TComponent)
  private
    RxDgramList:TPackStringList;
    RxUpdateTimer:TTimer;
    DGramIndex:Integer;
    DGramBuffer:TDGramBuffer;
    FMachineName:String;
    FIPAddress:String;
    WindowHandle:THandle;
    HSocket:TSocket;
    DDramSocket:TSocket;
    DInAddr:TSockAddrIn;
    FDGramPortNumber:Integer;
    FDGramLength    :Integer;
    FOnRxDataGram:TRxDGramNotifyEvent;
    FOnError:TSocketNotifyEvent;
    FActive:Boolean;
    FNotifyRxOwn:Boolean;
    procedure WndProc(var Message: TMessage);
    procedure RxDataGram(var msg: TMessage); message WM_RXDATAGRAM;
    procedure SetActive(Value:Boolean);
    function GetLocalIPAddress:String;
    procedure CheckRxDGrams(Sender:TObject);
  public        
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    function  SendDGram(Data:String):Boolean;
    procedure ForceRead;
  published
    property Active:Boolean read FActive write SetActive;
    property NotifyRxOwn:Boolean read FNotifyRxOwn write FNotifyRxOwn;
    property PortNumber :Integer read FDGramPortNumber write FDGramPortNumber;
    property MaxDGramLen:Integer read FDGramLength     write FDGramLength    ;
    property OnError:TSocketNotifyEvent read FOnError write FOnError;
    property OnRxDataGram:TRxDGramNotifyEvent read FOnRxDataGram write FOnRxDataGram;
    property IPAddress:String read FIPAddress;
  end;
  TServiceMachineList = class(TComponent)
  private
     FList:TPackStringList;
     FOnListChange:TNotifyEvent;
     FDGramSocket:TDGramSocket;
     FOnError:TSocketNotifyEvent;
     function GetList:TPackStringList;
     procedure RxDataGram(Sender:TDGramSocket;From,Data:String);
     procedure DGError(Sender:TDGramSocket;EMessage:String);
  public       
     constructor Create(AOwner:TComponent); override;
     destructor Destroy; override;
     property List:TPackStringList read GetList;
     procedure Trigger;
  published
     property OnError:TSocketNotifyEvent read FOnError write FOnError;
     property OnListChange:TNotifyEvent read FOnListChange write FOnListChange; 
  end;                      
  TMachineList = class(TServiceMachineList)
  private
     Timer:TTimer;
     procedure TimerTick(Sender:TObject);
  public       
     constructor Create(AOwner:TComponent); override;
     destructor Destroy; override;
  end;                      
  
procedure Register;
  
implementation

procedure Register;
begin
   RegisterComponents('PSL-IPM', [TDGramSocket,TMachineList]);
end;
{TMachineList}
procedure TServiceMachineList.DGError(Sender:TDGramSocket;EMessage:String);
begin
   if Assigned (FOnError) then
      FOnError(Sender,EMessage);
end;
procedure TServiceMachineList.RxDataGram(Sender:TDGramSocket;From,Data:String);
var
   Idx:Integer;
begin
   Idx:=FList.IndexOf(From);
   if (Idx = -1) and (Data = '*') then
   begin
      FList.AddObject(From,TObject(5));
      if Assigned(FOnListChange) then FOnListChange(Self);
   end
   else if (Idx <> -1) then
   begin
      if  (Data <> '*') then
      begin
         FList.Delete(Idx); // Machine Closed
         if Assigned(FOnListChange) then FOnListChange(Self);
      end
      else
         FList.Objects[Idx]:=TObject(5);
   end;
end;
procedure TServiceMachineList.Trigger;
var
   I:Integer;
   J:Integer;
begin
   I:=0;
   while I < FList.Count do    
   begin
      J:=Integer(FList.Objects[I])-1;
      if J > 0 then
      begin
         FList.Objects[I]:=TObject(J);
         Inc(I);
      end
      else
      begin
         FList.Delete(I); // Machine Died
         if Assigned(FOnListChange) then FOnListChange(Self);
      end;
   end;  
   FDGramSocket.SendDGram('*');
   FDGramSocket.ForceRead;
end;
function TServiceMachineList.GetList:TPackStringList;
begin
   Result:=FList; 
end;
constructor TServiceMachineList.Create(AOwner:TComponent);
begin
   inherited Create(AOwner);
   FList:=TPackStringList.Create;
   FDGramSocket:=TDGramSocket.Create(nil);
   FDGramSocket.Active:=False;
   FDGramSocket.OnRxDataGram:=RxDataGram;
   FDGramSocket.OnError:=DGError;
   FDGramSocket.MaxDGramLen:=100;
   FDGramSocket.NotifyRxOwn:=True;
   FDGramSocket.PortNumber:=45000;
   if not (csDesigning in ComponentState) then
   begin
      FDGramSocket.Active:=True;
      FDGramSocket.SendDGram('*');
   end;
end;           
destructor TServiceMachineList.Destroy;
begin
   FDGramSocket.SendDGram('!');
   FList.Free;
   FDGramSocket.Active:=False;
   FDGramSocket.Free;
   inherited Destroy;
end;
procedure TMachineList.TimerTick(Sender:TObject);
begin
   Trigger;
end;
constructor TMachineList.Create(AOwner:TComponent);
begin
   inherited Create(AOwner);
   Timer:=TTimer.Create(nil);
   Timer.Enabled:=False;
   Timer.Interval:=2000;
   Timer.OnTimer:=TimerTick;
   Timer.Enabled:=True;
end;
destructor TMachineList.Destroy;
begin
   Timer.Enabled:=False;
   Timer.Free;
   inherited Destroy;
end;

{TDGramBuffer}
constructor TDGramBuffer.Create;
begin
   TXList:=TPackStringList.Create;
end;
destructor TDGramBuffer.Destroy;
begin
   TXList.Free;
   inherited Destroy;
end;
procedure TDGramBuffer.PostDGram(Data:String);
var
   Res:Integer;
begin
   if TXList.IndexOf(Data) = -1 then
      TXList.Add(Data);
   while TXList.Count > 0 do
   begin
      Data:=TXList[0];
      Res:=SendTo(Parent.DDramSocket,Pointer(Data)^,Length(Data),0,
             TSockAddr(Parent.DInAddr),SizeOf(Parent.DInAddr));
      if Res = SOCKET_ERROR then 
      begin
         break;
      end;
      TXList.Delete(0);
      Application.ProcessMessages;
   end;
end;

{TDGramSocket}

constructor TDGramSocket.Create(AOwner:TComponent);
begin
   inherited Create(AOwner);
   RxUpdateTimer:=TTimer.Create(nil);
   RxUpdateTimer.Enabled:=False;
   RxUpdateTimer.Interval:=100;
   RxUpdateTimer.OnTimer:=CheckRxDGrams;
   RxDgramList:=TPackStringList.Create;
   DGramIndex:=0;
   FNotifyRxOwn:=False;
   DGramBuffer:=TDGramBuffer.Create;
   DGramBuffer.Parent:=Self;
   FActive:=False;
   FDGramPortNumber:=45000;
   FDGramLength:=500;
   Integer(HSocket):=INVALID_SOCKET;
   WindowHandle:=AllocateHWnd(WndProc);
end;
destructor TDGramSocket.Destroy;
begin
   DGramBuffer.Free;
   if Active then Active:=False;
   RxUpdateTimer.Free;
   RxDgramList.Free;
   if WindowHandle <> 0 then DeAllocateHWnd(WindowHandle);
   inherited Destroy;
end;                            
procedure TDGramSocket.ForceRead;
begin
   CheckRxDGrams(Self);
end;
procedure TDGramSocket.SetActive(Value:Boolean);
var
   SockAddrIn:TSockAddrIn;
   Res:Integer;
   WSAData:TWSAData;
   Opt:Integer;
begin
   if FActive <> Value then
   begin
      FActive:=Value;
      if FActive then
      begin
         SockAddrIn.sin_family:=AF_INET;
         SockAddrIn.sin_addr.s_addr:=INADDR_ANY;
         SockAddrIn.sin_port:=htons(FDGramPortNumber);
         if WSAStartUp($0101,WSAData) = 0 then
         begin
            HSocket:=WinSock.Socket(PF_INET,SOCK_DGRAM,IPPROTO_UDP);
            if HSocket <> INVALID_SOCKET then
            begin
               Res:=Bind(HSocket,TSockAddr(SockAddrIn),sizeof(SockAddrIn));
               if Res <> SOCKET_ERROR then 
               begin
                  Res:=WSAASyncSelect(HSocket,WindowHandle,WM_RXDATAGRAM,FD_READ);
                  if (Res = SOCKET_ERROR) and Assigned(FOnError) then 
                     FOnError(Self,'Sync Error '+IntToStr(WSAGetLastError));
               end     
               else
               begin
                  if Assigned(FOnError) then FOnError(Self,'Bind Error '+IntToStr(WSAGetLastError));
               end;
            end
            else
            begin
               if Assigned(FOnError) then FOnError(Self,'Socket Error '+IntToStr(WSAGetLastError));
            end;
         end
         else
         begin
            if Assigned(FOnError) then FOnError(Self,'WSAStartup Error '+IntToStr(WSAGetLastError));
         end;   
         Opt:=1;
         DInAddr.sin_family:=AF_INET;
         DInAddr.sin_addr.s_addr:=-1; //INADDR_BROADCAST;
         DInAddr.sin_port:=htons(FDGramPortNumber);
         DDramSocket:=WinSock.Socket(PF_INET,SOCK_DGRAM,IPPROTO_UDP);
         if DDramSocket <> INVALID_SOCKET then
         begin
            Opt:=SetSockOpt(DDramSocket,SOL_SOCKET,SO_BROADCAST,PChar(@Opt),SizeOf(Opt));
            if Opt = SOCKET_ERROR then
            begin
               CloseSocket(DDramSocket);
               DDramSocket:=INVALID_SOCKET;
            end;
         end;
         FMachineName:=GetLocalIPAddress;
         RxUpdateTimer.Enabled:=True;
      end
      else
      begin
         try
            if HSocket <> INVALID_SOCKET then
            begin
               CloseSocket(HSocket);
            end;
            if DDramSocket <> INVALID_SOCKET then
               CloseSocket(DDramSocket);
         except
            ;
         end;
         HSocket:=INVALID_SOCKET;
         DDramSocket:=INVALID_SOCKET;
         RxUpdateTimer.Enabled:=False;
         while RxDGramList.Count > 0 do CheckRxDGrams(nil);
      end;
   end;
end;
procedure TDGramSocket.WndProc(var Message: TMessage);
begin
  try             
    Dispatch(Message);
  except
    Application.HandleException(Self);
  end;
end;
function TDGramSocket.GetLocalIPAddress:String;
var
  HostEnt: PHostEnt;
  Length:DWord;
  MachineName:array[0..MAX_COMPUTERNAME_LENGTH] of Char;
begin
   Length:=Sizeof(MachineName);
   GetComputerName(MachineName,Length);
   HostEnt:=WinSock.gethostbyname(MachineName);
   FIPAddress:=IntToStr(Integer(HostEnt^.h_addr^[0]))+'.'+
               IntToStr(Integer(HostEnt^.h_addr^[1]))+'.'+
               IntToStr(Integer(HostEnt^.h_addr^[2]))+'.'+
               IntToStr(Integer(HostEnt^.h_addr^[3]));

   Result:=IntToHex((Integer(HostEnt^.h_addr^[0]) shl 24) or
                    (Integer(HostEnt^.h_addr^[1]) shl 16) or
                    (Integer(HostEnt^.h_addr^[2]) shl  8) or
                    (Integer(HostEnt^.h_addr^[3])       )   ,8);
   FIPAddress:=FIPAddress+' ['+Result+']';
end;
function TDGramSocket.SendDGram(Data:String):Boolean;
begin
   Result:=False;
   if (not FActive) or (DDramSocket = INVALID_SOCKET) then Exit;
   DGramBuffer.PostDGram(FMachineName+Data);
   Result:=True;
end;
procedure TDGramSocket.CheckRxDGrams(Sender:TObject);
var
   From:String;
   Data:String;
begin
   if RxDGramList.Count > 0 then
   begin
      while RxDGramList.Count > 0 do
      begin
         Data:=RxDGramList[0];
         From:=Copy(Data,1,8);
         RxDGramList.Delete(0);
         if FNotifyRxOwn or (From <> FMachineName) then
         begin
            if Assigned(FOnRxDataGram) then
               FOnRxDataGram(Self,From,Copy(Data,9,Length(Data)));
            Application.ProcessMessages;
         end;
      end;
      Application.ProcessMessages;
   end;
end;
procedure TDGramSocket.RxDataGram(var msg: TMessage);
var
   Src   :TSockAddrIn;
   SrcLen:Integer;
   RxStr :String;
   Len   :Integer;
begin
   if not Assigned(FOnRxDataGram) then Exit;
   SetLength(RxStr,FDGramLength);
   SrcLen:=SizeOf(Src);
   Len:=RecvFrom(HSocket,Pointer(RxStr)^,FDGramLength,0,Src,SrcLen);
   if Len > 0 then 
   begin
      SetLength(RxStr,Len);
      if RxDgramList.IndexOf(RxStr) = -1 then
         RxDgramList.Add(RxStr);
   end;  
end;  

end.
 