unit DTSocketU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,MsgConfigU,
{$ifndef NoRAS}
  RASDialer,
{$endif} // ndef NoRAS
  ScktComp2,WinSock,Compress,GPCSErrorLine,PackStrListU, StdCtrls,StringWrapperU;
  
type
  TCommandType  = (ctInvalid,ctCompressed,ctRxAcknowledge,ctError,ctResend,ctAbortTx,
                   ctSaveLocalFile,ctSendLocalFile,ctReplaceSelf,ctDeleteFile,
                   ctExecuteFile,ctExecuteWait,ctExecShowFile,ctExecShowWait,
                   ctExecAcknowledge,ctShutdown,ctGetDataRemote,ctSetDataRemote,ctRestart,
                   ctLogoff,ctRebuildTxnLog,ctTxComplete,ctClearTxState,ctWho,
                   ctForward,ctGetMissingData,ctGetVersion,ctSetDataLocal,ctGetDataLocal,
                   ctExecuteQuery);
                   
  TDTSocket = class;
  TFileServerThread = class(TServerClientThread)
  public
    DTSocket:TDTSocket;
    DataString:String;
    SyncAddress:String;
    procedure Sync;
    procedure ClientExecute; override;
    function MessageComplete(Message:String):Boolean;
    function GetMessageData(var CommandType:TCommandType;Msg:String):String;
  end;   
  TRxDataEvent = function (CommandType:TCommandType;Data:String):String of object;
  TSendCommand = function (Host:String;TimeOut:Integer;CommandType:TCommandType;DataStream:TStringStream;HangUpAfter:Boolean):String of object;  
  TOnDataSend        = procedure(Host:String;Size:Integer) of object;
  TOnDataSent        = procedure(Host:String;Size:Integer;Stat:Boolean;Time:TTime) of object;
  TOnDataReceived    = procedure(Host:String;Size:Integer;Stat:Boolean;Time:TTime) of object;
  TOnDataConnectTime = procedure(Host:String;Time:TTime) of object;
  TDTSocket = class(TObject)
  private
    FOnDataSend       :TOnDataSend       ;
    FOnDataSent       :TOnDataSent       ;
    FOnDataReceived   :TOnDataReceived   ;
    FOnDataConnectTime:TOnDataConnectTime;
    ErrList:TStringList;
    FServerSocket:TServerSocket;
    FPortNumber:Integer;
    FOnRxData:TRxDataEvent;
{$ifndef NoRAS}
    RASDialer:TRASDialer;
    FRASConnecting:Boolean;
    function Dial(DUNEntry:String):String;
    function DialUpIndex(DUNEntry:String):Integer;
    procedure ErrorEvent(Sender:TObject;Event:String);
    procedure OnConnect(Sender:TObject;Event:String);
{$endif} // ndef NoRAS
    procedure SetActive(Value:Boolean);
    function GetActive:Boolean;
    procedure ServerSocketGetThread(Sender: TObject;ClientSocket: TServerClientWinSocket;var SocketThread: TServerClientThread);
    function ConnectTo(DUNEntry:String):String;
    procedure SocketErrorEvent(Sender:TObject;Socket:TCustomWinSocket;ErrorEvent:TErrorEvent;var ErrorCode:Integer);
  public
    constructor Create(PortNumber:Integer);
    destructor Destroy; override;
    procedure HangUp;
    function SendCommand(Host:String;TimeOut:Integer;CommandType:TCommandType;DataStream:TStringStream;HangUpAfter:Boolean):String;
    property Active      :Boolean       read GetActive     write SetActive    ;
    property ServerSocket:TServerSocket read FServerSocket write FServerSocket;
    property PortNumber  :Integer       read FPortNumber   write FPortNumber  ;
    property OnRxData    :TRxDataEvent  read FOnRxData     write FOnRxData    ;
    property OnDataSend       :TOnDataSend        read FOnDataSend        write FOnDataSend       ;
    property OnDataSent       :TOnDataSent        read FOnDataSent        write FOnDataSent       ;
    property OnDataReceived   :TOnDataReceived    read FOnDataReceived    write FOnDataReceived   ;
    property OnDataConnectTime:TOnDataConnectTime read FOnDataConnectTime write FOnDataConnectTime;
  end;
  
function ExecRemoteQuery(UserName,PassWord,Alias,Query,DestinationHost:String;mSTimeOut:Integer;HangUpAfter:Boolean):String;
                                                
implementation
uses
   FileTxStatusU;
   
function ExecRemoteQuery(UserName,PassWord,Alias,Query,DestinationHost:String;mSTimeOut:Integer;HangUpAfter:Boolean):String;
var                                    
   UserMessage:TUserMessage; 
   QueryParams:TQueryParams; 
begin
   QueryParams:=TQueryParams.Create;
   QueryParams.UserName:=UserName;
   QueryParams.Password:=PassWord;
   QueryParams.Alias   :=Alias;
   QueryParams.Query   :=Query;

   UserMessage:=TUserMessage.Create;
   UserMessage.DestinationHost:=DestinationHost;
   UserMessage.TimeOut        :=mSTimeOut;
   UserMessage.CommandType    :=ctExecuteQuery;
   UserMessage.Data           :=QueryParams.PackText;
   UserMessage.HangUpAfter    :=HangUpAfter;
   
   QueryParams.Free;
   Result:=RequestServiceData('SendMessage',UserMessage.PackText);
   UserMessage.Free;
end;

{TDTSocket}
procedure ServerSocketError(ErrorCode:Integer);
begin
   RaiseGUIDError('{B1B9EB68-6078-41BB-907E-90766E2EE318}','Socket Error '+IntToStr(ErrorCode));
end;
constructor TDTSocket.Create(PortNumber:Integer);
begin
   ErrList:=TStringList.Create;
   FPortNumber:=PortNumber;
   SocketErrorProc:=ServerSocketError;
   FServerSocket:=TServerSocket.Create(nil,INADDR_ANY,True);
   FServerSocket.Port:=FPortNumber;
   FServerSocket.ServerType:=stThreadBlocking;
   FServerSocket.OnGetThread:=ServerSocketGetThread;
   FServerSocket.Active:=False;
end;
destructor TDTSocket.Destroy;
begin
{$ifndef NoRAS}
   if RASDialer <> nil then
      RASDialer.Free;
{$endif} // ndef NoRAS
   FServerSocket.Active:=False;
   FServerSocket.Free;
   ErrList.Free;
end;
procedure TDTSocket.ServerSocketGetThread(Sender: TObject;ClientSocket: TServerClientWinSocket;var SocketThread: TServerClientThread);
begin
  SocketThread:=TFileServerThread.Create(False,ClientSocket);
  TFileServerThread(SocketThread).DTSocket:=Self;
end;
procedure TDTSocket.SetActive(Value:Boolean);
begin
   FServerSocket.Port:=FPortNumber;
   FServerSocket.Free;
   FServerSocket:=TServerSocket.Create(nil,INADDR_ANY,True);
   FServerSocket.Port:=FPortNumber;
   FServerSocket.ServerType:=stThreadBlocking;
   FServerSocket.OnGetThread:=ServerSocketGetThread;
   FServerSocket.Active:=Value;
end;
function TDTSocket.GetActive:Boolean;
begin
   Result:=FServerSocket.Active;
end;
function IsIPAddress(Value:String):Boolean;
var
   I,DC:Integer;
begin
   Result:=False;
   DC:=0;
   for I:=1 to Length(Value) do
   begin
      if not (Value[I] in ['0'..'9','.']) then Exit;
      if Value[I] = '.' then Inc(DC);
   end;
   Result:=DC=3;
end;

{$ifndef NoRAS}
procedure TDTSocket.OnConnect(Sender:TObject;Event:String);
begin
   FRASConnecting:=False;
end;

procedure TDTSocket.ErrorEvent(Sender:TObject;Event:String);
begin
   ErrList.Add(Event);
end;
function TDTSocket.DialUpIndex(DUNEntry:String):Integer;
var
   SL:TStringList;
begin
   if RASDialer = nil then
      RASDialer:=TRASDialer.Create;
   SL:=TStringList.Create;
   SL.CommaText:=RASDialer.GetPhoneBookEntries;
   Result:=SL.IndexOf(DUNEntry);
   SL.Free;
end;
function TDTSocket.Dial(DUNEntry:String):String;
var
   User,Pass,Phone,Dom:String;
   TimeOut:Integer;
begin
   Result:='';
   if DialUpIndex(DUNEntry) <> -1 then
   begin
      RASDialer.OnErrorEvent:=ErrorEvent;
      RASDialer.OnConnectEvent:=ErrorEvent;
      RasDialer.GetEntry(DUNEntry,User,Pass,Phone,Dom);
//      ErrList.Add('RASSettings U'+User+' P'+Pass+' T'+Phone+' D'+Dom);
      RASDialer.OnConnected   :=OnConnect;
      RASDialer.OnDisConnected:=OnConnect;
      FRASConnecting:=True;
      RASDialer.Phone(DUNEntry);
      TimeOut:=0;
      while (FRASConnecting) and (not Application.Terminated) and (not RASDialer.Connected) and (TimeOut < 240) do
      begin
         Sleep(500);
         Inc(TimeOut);
         Application.ProcessMessages;
      end;
      if RASDialer.Connected then
         Result:=RASDialer.ServerIPAddress;
   end;
end;
{$endif} // ndef NoRAS
function TDTSocket.ConnectTo(DUNEntry:String):String;
begin
{$ifdef NoRAS}
      Result:=DUNEntry
{$else} // def NoRAS
   if IsIPAddress(DUNEntry) then
   begin
      Result:=DUNEntry;
   end
   else
   begin
      if RASDialer = nil then
         RASDialer:=TRASDialer.Create;
      Result:=Dial(DUNEntry);
      if Result = '' then
         Result:=DUNEntry;
   end;
{$endif} // def NoRAS
end;
procedure TDTSocket.SocketErrorEvent(Sender:TObject;Socket:TCustomWinSocket;ErrorEvent:TErrorEvent;var ErrorCode:Integer);
begin
   ErrList.Add('Error '+IntToStr(ErrorCode));
end;

function TDTSocket.SendCommand(Host:String;TimeOut:Integer;CommandType:TCommandType;DataStream:TStringStream;HangUpAfter:Boolean):String;
var
   Buffer:String;
   SocketStream:TWinSocketStream;
   SS:TMemoryStream;
   S:String;
   Stat:Boolean;
   RXComplete:Boolean;
   Ticker,Len,Size:Integer;
   ClientSocket:TClientSocket;
   SendTimer,RxTimer:TTime;
   ReadNow:Boolean;
   I:Integer;
begin
   ErrList.Clear;
   ClientSocket:=TClientSocket.Create(nil,INADDR_ANY,True); // any local IP Port
   ClientSocket.ClientType:=ctBlocking;
   ClientSocket.Host:=ConnectTo(Host);
   ClientSocket.OnError:=SocketErrorEvent;
   if ClientSocket.Host = '' then
   begin
      Result:='Error - '+ErrList.Text;
      ClientSocket.Free;
      Exit;
   end;
   ClientSocket.Port:=FPortNumber;
   try
      ClientSocket.Active:=True;
   except
      Result:='Error - '+ErrList.Text;
      ClientSocket.Free;
      Exit;
   end;
   Ticker:=0;
   while (not Application.Terminated) and (not ClientSocket.Socket.Connected) and (Ticker < TimeOut) do
   begin
      Application.ProcessMessages;
      Sleep(1000);
      Inc(Ticker,1000);
   end;
   if Ticker >= TimeOut then
   begin
      ErrList.Add('Timount on client connect in Send Command');
      Result:='Error - '+ErrList.Text;
      ClientSocket.Free;
      Exit;
   end;
   if (WaitAfterConnectSeconds > 0) and (DialUpIndex(Host) <> -1) then
     Sleep(WaitAfterConnectSeconds);

   SS:=TMemoryStream.Create;
   if DataStream = nil then
      S:='Corvus3:00000008'+IntToHex(Integer(CommandType),8)
   else
      S:='Corvus3:'+IntToHex(DataStream.Size+8,8)+IntToHex(Integer(CommandType),8);
   SS.Write((@S[1])^,Length(S));
   if DataStream <> nil then
   begin
      DataStream.Position:=0;
      SS.CopyFrom(DataStream,DataStream.Size);
   end;
   SS.Position:=0;
   SendTimer:=Now;
   Size:=SS.Size;
   if Assigned(FOnDataSend) then FOnDataSend(Host,Size);
   Stat:=ClientSocket.Socket.SendStream(SS);  // DataStream is now owned by ClientSocket, DON'T FREE DataStreamSS!
   if Assigned(FOnDataSent) then FOnDataSent(Host,Size,Stat,Now-SendTimer);

   RXComplete:=False;
   Result:='';
   RxTimer:=Now;
   while Stat and ClientSocket.Socket.Connected and not RXComplete do
   try
     SocketStream:=TWinSocketStream.Create(ClientSocket.Socket,TimeOut); // 60 seconds
     try
        SetLength(Buffer,DataTransferBufferLen);
        FillChar((@Buffer[1])^,Length(Buffer), 0);
        while not RXComplete do
        begin
            ReadNow:=False;
            for I:=1 to (DataTransferTimeOut div 1000) do
            begin
               if SocketStream.WaitForData(1000) then
               begin
                  ReadNow:=True;
                  break;
               end;
            end;
            if ReadNow then
            begin
               Len:=SocketStream.Read((@Buffer[1])^,Length(Buffer))
            end
            else
            begin
               ErrList.Add('Timeout waiting to read from '+Host);
               Len:=0;
            end;
           if Len > 0 then
           begin
              SetLength(Buffer,Len);
              Result:=Result+Buffer; // append it !
              SetLength(Buffer,DataTransferBufferLen);
              FillChar((@Buffer[1])^,Length(Buffer),0);
           end
           else
           begin
              RXComplete:=True;
              ClientSocket.Socket.Close;
//              SetLength(Buffer,0);
           end;
        end;
     finally
        SocketStream.Free;
     end;
  except
     ;
  end;
  if (Copy(Result,1,8) = 'Corvus3:') then
  begin
     Result:=Copy(Result,25,Length(Result));
     if Assigned(FOnDataReceived) then FOnDataReceived(Host,Length(Result),True,Now-RxTimer);
  end
  else
  begin
     Result:='Error - '+IntToStr(GetLastError)+' '+ErrList.Text;
     if Assigned(FOnDataReceived) then FOnDataReceived(Host,Length(Result),True,Now-RxTimer);
  end;
  if HangUpAfter then
     HangUp;
  if Assigned(FOnDataConnectTime) then FOnDataConnectTime(Host,Now-SendTimer);
end;
procedure TDTSocket.HangUp;
begin
{$ifndef NoRAS}
   if RASDialer <> nil then
   begin
      RASDialer.Free;
      RASDialer:=nil;
   end;
{$endif} // ndef NoRAS
end;
{ TFileServerThread }
function TFileServerThread.GetMessageData(var CommandType:TCommandType;Msg:String):String;
var
   L:Integer;
begin
   CommandType:=ctError;
   if Copy(Msg,1,8) <> 'Corvus3:' then Exit;
   L:=Length(Msg);
   CommandType:=TCommandType(StrToIntDef('$'+Copy(Msg,17,8),0));
   if CommandType = ctCompressed then
   begin
      Msg:=TCompressor.DeCompressString(Copy(Msg,25,L));
      CommandType:=TCommandType(StrToIntDef('$'+Copy(Msg,17,8),0));
      L:=Length(Msg);
   end;
   Result:=Copy(Msg,25,L);
end;
function TFileServerThread.MessageComplete(Message:String):Boolean;
var
  MLen:Integer;
  Len:Integer;
begin
   Result:=False;
   Len:=Length(Message);
   if Len >= 16 then
   begin
      if Copy(Message,1,8) = 'Corvus3:' then
      begin
         MLen:=StrToIntDef('$'+Copy(Message,9,8),0);
         if MLen <= Len then
            Result:=True;
      end;
   end;
end;
procedure TFileServerThread.Sync;
var
  CommandType:TCommandType;
begin
   if (DTSocket <> nil) and Assigned (DTSocket.OnRxData) then
   begin
      DTSocket.OnDataReceived(SyncAddress,Length(DataString),True,0);
      DataString:=GetMessageData(CommandType,DataString);
      DataString:=DTSocket.OnRxData(CommandType,DataString);
   end
   else
   begin
      DataString:=IntToHex(Integer(ctRxAcknowledge),8);
      DataString:='Corvus3:'+IntToHex(Length(DataString),8)+DataString;
   end;
end;
procedure TFileServerThread.ClientExecute;
var
  Data:String;
  SocketStream: TWinSocketStream;
  Len:Integer;
  SS:TStringStream;
  RXComplete:Boolean;
  I:Integer;
  ReadNow:Boolean;
begin
  RXComplete:=False;
  while not Terminated and ClientSocket.Connected and not RXComplete do
  try
    SocketStream := TWinSocketStream.Create(ClientSocket,DataTransferTimeOut);
    try
      SetLength(Data,DataTransferBufferLen);
      DataString:='';
      FillChar((@Data[1])^,Length(Data),0);
      while not RXComplete and not MessageComplete(DataString) do
      begin
         ReadNow:=False;
         for I:=1 to (DataTransferTimeOut div 1000) do
         begin
            if SocketStream.WaitForData(1000) then
            begin
               ReadNow:=True;
               break;
            end;
            if Terminated or (not ClientSocket.Connected) then
               Break;
         end;
         if ReadNow then
            Len:=SocketStream.Read((@Data[1])^,Length(Data))
         else
            Len:=0;
         if Len > 0 then
         begin
            SetLength(Data,Len);
            DataString:=DataString+Data; // append it !
            FillChar((@Data[1])^,Length(Data),0);
            SetLength(Data,DataTransferBufferLen);
         end
         else
         begin
            RXComplete:=True;
            ClientSocket.Close;
         end;
      end;
      RXComplete:=True;
      if (not Terminated) and (ClientSocket.Connected) then
      begin
        SyncAddress:=ClientSocket.RemoteAddress;
        Synchronize(Sync); // process data
        SS:=TStringStream.Create(DataString);
        ClientSocket.SendStream(SS); // SS is now owned by ClientSocket, DON'T FREE SS!
      end;
    finally
      SocketStream.Free;
    end;
  except
    HandleException;
  end;
  Terminate;
end;

end.
