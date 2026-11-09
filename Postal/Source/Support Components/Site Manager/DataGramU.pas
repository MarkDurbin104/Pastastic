unit DataGramU;

interface
uses
  Windows,Messages,Graphics,Forms,Extctrls,Sysutils,Classes,WinSock,ScktComp,
  ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode;
                             
const
   WM_RXDATAGRAM      = WM_USER+1;
   DGramPortNumber    = 45000;
   DGramLength        = 400;
   
type
  TNotifyWhosHere = procedure (List:TStrings)       of object;
  TNotifyError    = procedure (ErrorMessage:String) of object;
  TDGram = class(TObject)
  private
     FDGInterval:Integer;
     FVersion:Integer;
     FHSocket:THandle;
     FWindowHandle:THandle;
     FDGramSocket:THandle;
     FComputerName:String;
     FWhosHere:TStringList;
     FDInAddr:TSockAddrIn;
     FTimer:TTimer;
     FOnWhosHere:TNotifyWhosHere;
     FOnError:TNotifyError;
     procedure TimerTick(Sender:TObject);
     procedure WndProc(var Message: TMessage);
     function  SendDGram(Data:String):Boolean;
     procedure RxDataGram(var msg: TMessage); message WM_RXDATAGRAM;
     procedure RemFromWhosHere(Name:String);
     procedure AddToWhosHere(Name:String);
     procedure SetDGInterval(Value:Integer);
  protected
  public
    constructor Create; 
    destructor Destroy; override;
  published
    property Version   :Integer         read FVersion    write FVersion     ;
    property DGInterval:Integer         read FDGInterval write SetDGInterval;
    property OnWhosHere:TNotifyWhosHere read FOnWhosHere write FOnWhosHere  ;
    property OnError   :TNotifyError    read FOnError    write FOnError     ;
  end;

implementation

constructor TDGram.Create;
var
   SockAddrIn:TSockAddrIn;
   Res:Integer;
   WSAData:TWSAData;
   Opt:Integer;
begin
   FHSocket:=INVALID_SOCKET;
   FWindowHandle:=AllocateHWnd(WndProc);
   FComputerName:=GetLocalMachineName;
      
   SockAddrIn.sin_family:=AF_INET;
   SockAddrIn.sin_addr.s_addr:=INADDR_ANY;
   SockAddrIn.sin_port:=htons(DGramPortNumber);
   
   if WSAStartUp($0101,WSAData) = 0 then
   begin
      FHSocket:=WinSock.Socket(PF_INET,SOCK_DGRAM,IPPROTO_UDP);
      if FHSocket <> INVALID_SOCKET then
      begin
         Res:=Bind(FHSocket,TSockAddr(SockAddrIn),sizeof(SockAddrIn));
         if Res <> SOCKET_ERROR then 
         begin
            WSAASyncSelect(FHSocket,FWindowHandle,WM_RXDATAGRAM,FD_READ);
         end
         else
         begin
            if Assigned(FOnError) then FOnError('Bind Failed');
         end;
      end
      else
      begin
         if Assigned(FOnError) then FOnError('Socket Failed');
      end;
   end
   else
   begin
      if Assigned(FOnError) then FOnError('Start Up Failed');
   end;   
   FWhosHere:=TStringList.Create;
   Opt:=1;
   FDInAddr.sin_family:=AF_INET;
   FDInAddr.sin_addr.s_addr:=INADDR_BROADCAST;
   FDInAddr.sin_port:=htons(DGramPortNumber);
   
   FDGramSocket:=WinSock.Socket(PF_INET,SOCK_DGRAM,IPPROTO_UDP);
   if FDGramSocket <> INVALID_SOCKET then
   begin
      Opt:=SetSockOpt(FDGramSocket,SOL_SOCKET,SO_BROADCAST,PChar(@Opt),SizeOf(Opt));
      if Opt = SOCKET_ERROR then
      begin
         CloseSocket(FDGramSocket);
         FDGramSocket:=INVALID_SOCKET;
      end;
      FTimer:=TTimer.Create(nil);
      FTimer.Interval:=10000; 
      FTimer.OnTimer:=TimerTick;
   end;
   if FDGramSocket <> INVALID_SOCKET then
      FTimer.Enabled:=True;
end;                  
destructor TDGram.Destroy;
begin
   FTimer.Free;
   try
      if FHSocket <> INVALID_SOCKET then
      begin
         CloseSocket(FHSocket);
         SendDGram('"'+FComputerName+'","'+IntToStr(FVersion)+'","ShutDown"');
      end;
   except
      ;
   end;
   try
      if FDGramSocket <> INVALID_SOCKET then
         CloseSocket(FDGramSocket);
   except
      ;
   end;
      
   if FWindowHandle <> 0 then DeAllocateHWnd(FWindowHandle);
   FWhosHere.Free;
                       
   inherited Destroy;
end;
procedure TDGram.SetDGInterval(Value:Integer);
begin
   if FDGInterval <> Value then
   begin
      FDGInterval:=Value;
      FTimer.Interval:=Value;
   end;
end;
procedure TDGram.RemFromWhosHere(Name:String);
var
   Index:Integer;
begin
   Index:=FWhosHere.IndexOf(Name);
   if Index <> -1 then 
   begin
      FWhosHere.Delete(Index);
      if Assigned(FOnWhosHere) then FOnWhosHere(FWhosHere);
   end;   
end;                   
procedure TDGram.AddToWhosHere(Name:String);
var
   Index:Integer;
begin
   Index:=FWhosHere.IndexOf(Name);
   if Index = -1 then 
   begin
      FWhosHere.Add(Name);
      if Assigned(FOnWhosHere) then FOnWhosHere(FWhosHere);
   end;
end;
procedure TDGram.WndProc(var Message: TMessage);
begin
  try
    Dispatch(Message);
  except
    Application.HandleException(Self);
  end;
end;
function TDGram.SendDGram(Data:String):Boolean;
var
  Res:Integer;
begin
   Result:=False;
   if FDGramSocket <> INVALID_SOCKET then
   begin
      Res:=SendTo(FDGramSocket,Pointer(Data)^,Length(Data),0,
                  TSockAddr(FDInAddr),SizeOf(FDInAddr));
      if Res <> SOCKET_ERROR then 
      begin
         Result:=True;
      end
      else
      begin
//         FError:='SendTo Failed';
//         if Assigned(FOnError) then FOnError(Self);
      end;      
   end;
end;
procedure TDGram.TimerTick(Sender:TObject);
begin
   SendDGram('"'+FComputerName+'","'+IntToStr(FVersion)+'","Notify"');
end;
procedure TDGram.RxDataGram(var msg: TMessage);
var
   Src   :TSockAddrIn;
   SrcLen:Integer;
   RxStr :String;
   Len   :Integer;
   RxData:TStringList;
begin
   SetLength(RxStr,DGramLength);
   SrcLen:=SizeOf(Src);
   Len:=RecvFrom(FHSocket,Pointer(RxStr)^,DGramLength,0,Src,SrcLen);
   SetLength(RxStr,Len);
   if Len > 0 then 
   begin
      RxData:=TStringList.Create;
      RxData.CommaText:=RxStr;
      if RxData.Count > 1 then
      begin
         if RxData[1] = 'ShutDown' then
            RemFromWhosHere(RxData[0])
         else
            AddToWhosHere(RxData[0]);
      end;   
      RxData.Free;
   end;  
end;  

end.
