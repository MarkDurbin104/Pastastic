unit UDPSocketU;

interface

uses
  Windows,Messages,SysUtils,Classes,WinSock,Forms,
  GPCSGUID,GPCSErrorLine;
    
const
   WM_RXDATAGRAM         = WM_USER+1;
   INADDR_BROADCAST      = -1;
   DGPortNumber          = 45020;
   MaxDGramSize          = 1500;
   FrameSize             = 1400;
   
type
  TUDP = class;
  TUDPEvent = procedure (Sender:TUDP;EMessage:String) of object;
  TRxEvent = procedure (Sender:TUDP;From,Data:String) of object;

  TUDP = class(TObject)
  private
    FActive:Boolean;
    FPortNumber:Integer;
    FReuseAddr:Boolean;
    FRxLength:Integer;
    FHSocket:THandle;
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
    property    RxLength  :Integer   read FRxLength   write FRxLength   ;
    property    RxOwn     :Boolean   read FRxOwn      write FRxOwn      ;
    property    OnError   :TUDPEvent read FOnError    write FOnError    ;
    property    OnRxDGram :TRxEvent  read FOnRxDGram  write FOnRxDGram  ;
    property    ReuseAddr :Boolean   read FReuseAddr  write FReuseAddr  ;
  end;                     
  
implementation

{TUDP}
constructor TUDP.Create;
begin
   inherited Create;
   FRxOwn:=False;
   FActive:=False;
   FPortNumber:=DGPortNumber;
   FReuseAddr:=True;
   FRxLength  :=MaxDGramSize;
   Integer(FHSocket):=INVALID_SOCKET;
   FWindowHandle:=AllocateHWnd(WndProc);
end;
destructor TUDP.Destroy;
begin
   if FActive then
   begin
      SendQuitMessage;
      Sleep(500);
      Active:=False;
   end;
   if FWindowHandle <> 0 then DeAllocateHWnd(FWindowHandle);
   inherited Destroy;
end;
procedure TUDP.RxDataGram(var Msg: TMessage);
var
   Src   :TSockAddrIn;
   SrcLen:Integer;
   RxStr :String;
   From  :String;
   Len   :Integer;
begin
   SetLength(RxStr,FRxLength);
   SrcLen:=SizeOf(Src);
   Len:=RecvFrom(FHSocket,Pointer(@RxStr[1])^,FRxLength,0,Src,SrcLen);
   if Len >= 8 then
   begin
      if Assigned(FOnRxDGram) then
      begin
         SetLength(RxStr,Len);
         From:=Copy(RxStr,1,8);
         if (FRxOwn) or (From <> HexIPAddress) then
            FOnRxDGram(Self,From,Copy(RxStr,9,Len));
      end;
   end
   else
      if WSAGetLastError <> 10035 then // read from empty socket
         FOnError(Self,'RecvFrom Error '+IntToStr(WSAGetLastError));
end;
function TUDP.SendDGram(Data:String):Boolean;
var
   AddrIn:TSockAddrIn;
   Res:Integer;
begin
   Result:=True;
   if Self.HexIPAddress = '7F000001' then Exit; // no network card or N/C 
   AddrIn.sin_family:=AF_INET;
   AddrIn.sin_addr.s_addr:=INADDR_BROADCAST;
   AddrIn.sin_port:=htons(FPortNumber);
   Data:=HexIPAddress+Data;
   Res:=SendTo(FDramSocket,Pointer(@Data[1])^,Length(Data),0,TSockAddr(AddrIn),SizeOf(AddrIn));
   if Res = SOCKET_ERROR then
   begin
      if Assigned(FOnError) then
        FOnError(Self,'SendTo Error '+IntToStr(WSAGetLastError));
      Result:=False;
   end;
end;
function TUDP.SendQuitMessage:Boolean;
var
   AddrIn:TSockAddrIn;
   Res:Integer;
   Data:String;
begin
   Result:=True;
   if Self.HexIPAddress = '7F000001' then Exit; // no network card or N/C 
   AddrIn.sin_family:=AF_INET;
   AddrIn.sin_addr.s_addr:=INADDR_BROADCAST;
   AddrIn.sin_port:=htons(FPortNumber);
   Data:=HexIPAddress+IntToHex($7FFFFFFF,8);
   Res:=SendTo(FDramSocket,Pointer(@Data[1])^,Length(Data),0,TSockAddr(AddrIn),SizeOf(AddrIn));
   if Res = SOCKET_ERROR then
   begin
      if Assigned(FOnError) then
        FOnError(Self,'SendTo Error '+IntToStr(WSAGetLastError));
      Result:=False;
   end;
end;
procedure TUDP.SetPortNumber(Value:Integer);
var
   WasActive:Boolean;
begin
   if FPortNumber <> Value then
   begin
      WasActive:=Active;
      if WasActive then Active:=False;
      FPortNumber:=Value;
      Active:=WasActive;
   end;
end;
procedure TUDP.SetActive(Value:Boolean);
var
   SockAddrIn:TSockAddrIn;
   Res:Integer;
   WSAData:TWSAData;
   Opt:Integer;
begin
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
end;
function TUDP.HexIPAddress:String;
var
   HostEnt: PHostEnt;
   Len:DWord;
   MachineName:array[0..MAX_COMPUTERNAME_LENGTH] of Char;
const
   IPAddress:String = '';
begin
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
end;
procedure TUDP.WndProc(var Msg: TMessage);
begin
  try             
    Dispatch(Msg);
  except
    Application.HandleException(Self);
  end;
end;

end.
