unit MesQueueU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  Dialogs, ScktComp2, StdCtrls, ExtCtrls, Registry,WinSock,FileCtrl,
  WinExecU,GPCSGUID,PackStrListU,Compress,TxnTranslateU;

const
  MessagePortNumber  = 50100;
  MaxRxLength        = 5000000;
  RxBufferSize       = 50000;

type
  TMessageQueue = class;
  TQueueRxEvent = procedure(Socket:TCustomWinSocket;Message:String;MoreData:Boolean) of object;
  TCommandType  = (ctInvalid,ctCompressed,ctRxAcknowledge,ctError,ctResend,ctAbortTx,
                   ctSaveLocalFile,ctSendLocalFile,ctReplaceSelf,ctDeleteFile,
                   ctExecuteFile,ctExecuteWait,ctExecShowFile,ctExecShowWait,
                   ctExecAcknowledge,ctShutdown,ctGetData,ctSetData,ctRestart,ctLogoff);
  TClientQueue = class
  private
     Messages:TPackStringList;
     FServer:String;
     SocketError:Boolean;
     ClientSocket:TClientSocket;
     FOnError:TSocketErrorEvent;
     FOnRead:TSocketEventEvent;
     procedure Error(Sender:TObject;Socket:TCustomWinSocket;Event:TErrorEvent;var Code:Integer);
     procedure Write(Sender:TObject;Socket:TCustomWinSocket);
     procedure Read(Sender:TObject;Socket:TCustomWinSocket);
//     function EnableAutoDial(State:Boolean):Boolean;
     procedure ConnectClient;
  public
     procedure DisConnectClient;
     constructor Create(Server:String);
     destructor Destroy; override;
     function Send(Message:String):Boolean;
     property OnError:TSocketErrorEvent read FOnError write FOnError;
     property OnRead:TSocketEventEvent read FOnRead write FOnRead;
  end;         

  TMessageQueue = class
  private
     ServerSocket:TServerSocket;
     Servers:TPackStringList;
     LengthToReceive:Integer;
     ReceivedMessage:TMemoryStream;
     LastMessage:String;
     FOnMessage:TQueueRxEvent;
     FOnError:TSocketErrorEvent;
     function HexToInt(Val:String):Integer;
     procedure Error(Sender:TObject;Socket:TCustomWinSocket;Event:TErrorEvent;var Code: Integer);
     function ReceiveText(Socket:TCustomWinSocket):string;
     procedure Read(Sender:TObject;Socket:TCustomWinSocket);
     procedure ClientRead(Sender:TObject;Socket:TCustomWinSocket;SocketEvent:TSocketEvent);
     procedure Notify(Socket:TCustomWinSocket;Message:String;MoreData:Boolean);
     function  GetLength(var Message:String):Integer;
     procedure AppendMessage(Message:String);
     procedure ClearMessage;
     function  GetMessage:String;
     function  GetLocalIPAddress:String;
  public
     constructor Create;
     destructor Destroy; override;
     procedure Disconnect(ToServer:String);
     function Send(ToServer,Message:String):Boolean;
     function SendOnSocket(Socket:TCustomWinSocket;Message:String):Boolean;
     procedure Activate;
     procedure DeActivate;
     property OnMessage:TQueueRxEvent read FOnMessage write FOnMessage;
     property OnError:TSocketErrorEvent read FOnError write FOnError;
     property LocalIPAddress:String read GetLocalIPAddress;
  end;

  TCommsLink = class;
  TOnRxCommand = procedure (CommandType:TCommandType;From,Data:String;var CanProcess:Boolean) of object;
  TCommsLink = class(TObject) 
  protected
    FOnError:TSocketErrorEvent;
    FOnRxCommand:TOnRxCommand;
    FCompDLength:Integer;
    FUnCompDLength:Integer;
    procedure SaveFile(Msg:String);
    procedure UnPackMessage(Socket:TCustomWinSocket;Msg,ReplyTo:String);
    procedure RxMessage(Socket:TCustomWinSocket;Msg:String;MoreData:Boolean);
    procedure Error(Sender:TObject;Socket:TCustomWinSocket;Event:TErrorEvent;var Code:Integer);
  public                       
    MessageQueue:TMessageQueue;
    function FileData(FileName:String):String;
    constructor Create;
    destructor Destroy; override;
    function Send(CommandType:TCommandType;ToServer,Data:String):Boolean;
    property OnRxCommand:TOnRxCommand read FOnRxCommand write FOnRxCommand;
    property OnError:TSocketErrorEvent read FOnError write FOnError;
    property CompDLength  :Integer read FCompDLength   write FCompDLength  ;
    property UnCompDLength:Integer read FUnCompDLength write FUnCompDLength;
  end;                       

function ErrorString(ErrorCode:Integer):String;
function StrIPToHexIP(IPValue:String):String;
procedure LogError(GUID,E:String);
procedure LogEvent(E:String);
procedure LogException(E:Exception;GUID:String);

implementation
{TCommsLink}
procedure LogError(GUID,E:String);
var
  SL:TStringList;
begin
  SL:=TStringList.Create;
  if FileExists('C:\Comms.log') then
     SL.LoadFromFile('C:\Comms.log');
  while SL.Count > 1000 do SL.Delete(SL.Count-1);
  SL.Insert(0,DateTimeToStr(Now)+' '+GUID+' '+E);
  SL.SaveToFile('C:\Comms.log');
  SL.Free;  
end;
procedure LogEvent(E:String);
begin
   LogError(E,'');
end;
procedure LogException(E:Exception;GUID:String);
begin 
   LogError('Exception:'+E.Message,GUID);
end;
function StrIPToHexIP(IPValue:String):String;
begin
   Result:=IntToHex(inet_addr(PChar(IPValue)),8);
   Result:=Copy(Result,7,2)+Copy(Result,5,2)+Copy(Result,3,2)+Copy(Result,1,2);
end;
function ErrorString(ErrorCode:Integer):String;
var
   mBuf:Pointer;
   Len:Integer;
begin
   Len:=FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS,
                nil,ErrorCode,$00000409, @mBuf, 0,nil);
   SetString(Result,PChar(mBuf),Len);
   Windows.LocalFree(Integer(mBuf));
   Result:=Trim(Result);
end;

constructor TCommsLink.Create;
begin
   inherited Create;
   MessageQueue:=TMessageQueue.Create;
   MessageQueue.OnMessage:=RxMessage;
   MessageQueue.OnError:=Error;
   MessageQueue.Activate;
end;
destructor TCommsLink.Destroy;
begin
   MessageQueue.DeActivate;
   MessageQueue.Free;
   inherited Destroy;
end;
procedure TCommsLink.Error(Sender:TObject;Socket:TCustomWinSocket;Event:TErrorEvent;var Code:Integer);
begin
   if Assigned(FOnError) then 
      FOnError(Sender,Socket,Event,Code)
   else
      LogError('{32F861AC-2906-4DA9-98EC-43F0B6FAA38D}','TCommsLink Error '+IntToStr(Integer(Event))+' '+ErrorString(Code));
end;                           
function TCommsLink.Send(CommandType:TCommandType;ToServer,Data:String):Boolean;
begin
   if Pos('.',ToServer) > 0 then
      ToServer:=StrIPToHexIP(ToServer); // convert x.x.x.x to Hex
   Result:=MessageQueue.Send(ToServer,IntToHex(Integer(CommandType),8)+Data);
end;
procedure WriteString(SS:TStream;Str:String);
var 
   Len:Integer;
begin
   Len:=Length(Str);
   SS.Write(Len,SizeOf(Len));
   SS.Write((@Str[1])^,Len);
end;
function ReadString(SS:TStream):String;
var 
   Len:Integer;
begin
   SS.Read(Len,SizeOf(Len));
   SetLength(Result,Len);
   SS.Read((@Result[1])^,Len);
end;
function TCommsLink.FileData(FileName:String):String;
var
   SS:TStringStream;
   FS:TFileStream;
begin
   FS:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyNone);
   FS.Position:=0;
   SS:=TStringStream.Create('');
   WriteString(SS,FileName);
   SS.CopyFrom(FS,FS.Size);
   FS.Free;
   SS.Position:=0;
   Result:=SS.DataString;
   SS.Free;
end;
procedure TCommsLink.SaveFile(Msg:String);
var
   SS:TStringStream;
   FS:TFileStream;
   FileName:String;
begin
   SS:=TStringStream.Create(Msg);
   SS.Position:=0;
   FileName:=ReadString(SS);
   if Not FileExists(ExtractFilePath(FileName)) then
      ForceDirectories(ExtractFilePath(FileName));
   try
      FS:=TFileStream.Create(FileName,fmCreate);
   except
      FS:=TFileStream.Create(FileName,fmOpenWrite or fmShareDenyNone);
   end;
   FS.CopyFrom(SS,SS.Size-SS.Position);
   FS.Free;
   SS.Free;
end;              
procedure SetShutdownPrivilege;
var
   ProcHandle:THandle;
   TokHandle:THandle;
   TmpLUID:TLargeInteger;
   TokPriv:TTokenPrivileges;
   TokNew:TTokenPrivileges;
   BufferNeeded:DWord;
begin
   ProcHandle:=GetCurrentProcess;
   OpenProcessToken(ProcHandle,TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,TokHandle);
   LookupPrivilegeValue('','SeShutdownPrivilege',TmpLUID);
   TokPriv.PrivilegeCount:=1;
   TokPriv.Privileges[0].LUID:=TmpLUID;
   TokPriv.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED;
   AdjustTokenPrivileges(TokHandle,False,TokPriv,Sizeof(TokNew),TokNew,BufferNeeded);
end;                  

procedure TCommsLink.UnPackMessage(Socket:TCustomWinSocket;Msg,ReplyTo:String);
var
   CommandType:TCommandType;
   CanProcess:Boolean;
   L:Integer;
   S:String;
begin
   L:=Length(Msg);
   if L < 8 then Exit;
   CommandType:=TCommandType(StrToIntDef('$'+Copy(Msg,1,8),0));
   if CommandType = ctCompressed then
   begin
      Inc(FCompDLength,L);
      Msg:=TCompressor.DeCompressString(Copy(Msg,9,L));
      CommandType:=TCommandType(StrToIntDef('$'+Copy(Msg,1,8),0));
      L:=Length(Msg);
   end;           
   Inc(FUnCompDLength,L);
   Msg:=Copy(Msg,9,L);
   CanProcess:=False;
   if Assigned(FOnRxCommand) then
      FOnRxCommand(CommandType,ReplyTo,Msg,CanProcess)
   else
      CanProcess:=True;
   if CanProcess then
   begin
      case CommandType of
         ctShutdown     : begin 
                             SetShutdownPrivilege;
                             MessageQueue.SendOnSocket(Socket,IntToHex(Integer(ctRxAcknowledge),8));
                             ExitWindowsEx(EWX_SHUTDOWN or EWX_FORCE,0);
                          end;
         ctRestart     :  begin 
                             SetShutdownPrivilege;
                             MessageQueue.SendOnSocket(Socket,IntToHex(Integer(ctRxAcknowledge),8));
                             ExitWindowsEx(EWX_REBOOT or EWX_FORCE,0);
                          end;
         ctLogoff     :   begin 
                             SetShutdownPrivilege;
                             MessageQueue.SendOnSocket(Socket,IntToHex(Integer(ctRxAcknowledge),8));
                             ExitWindowsEx(EWX_LOGOFF or EWX_FORCE,0);
                          end;
         ctDeleteFile    : begin 
                               try
                                  DeleteFile(Msg); 
                                  MessageQueue.SendOnSocket(Socket,IntToHex(Integer(ctRxAcknowledge),8));
                               except
                                  On E:Exception do
                                     MessageQueue.SendOnSocket(Socket,IntToHex(Integer(ctError),8)+E.Message);
                               end;
                            end;                                                                       
         ctGetData        : begin 
                               MessageQueue.SendOnSocket(Socket,IntToHex(Integer(ctSetData),8)+GetTransferData(Msg));
                            end;                                                                      
         ctSetData        : begin
                               if not SetTransferData(Msg,S) then
                                  MessageQueue.SendOnSocket(Socket,IntToHex(Integer(ctError),8)+S);
                            end;                                                                       
         ctExecuteFile    : begin 
                               try
                                  WinExec(PChar(Msg),SW_HIDE); 
                                  MessageQueue.SendOnSocket(Socket,IntToHex(Integer(ctRxAcknowledge),8));
                               except
                                  On E:Exception do
                                     MessageQueue.SendOnSocket(Socket,IntToHex(Integer(ctError),8)+E.Message);
                               end;
                            end;                                                                       
         ctExecuteWait    : begin
                               try
                                  WinExecAndWait(PChar(Msg),S,False);
                                  MessageQueue.SendOnSocket(Socket,IntToHex(Integer(ctExecAcknowledge),8)+S);
                               except
                                  On E:Exception do
                                     MessageQueue.SendOnSocket(Socket,IntToHex(Integer(ctError),8)+E.Message);
                               end;
                            end;                                                                       
         ctSaveLocalFile  : begin 
                               try
                                  SaveFile(Msg); 
                                  MessageQueue.SendOnSocket(Socket,IntToHex(Integer(ctRxAcknowledge),8));
                               except
                                  On E:Exception do
                                     MessageQueue.SendOnSocket(Socket,IntToHex(Integer(ctError),8)+E.Message);
                               end;
                            end;                                                                       
         ctSendLocalFile  : begin 
                               try
                                  MessageQueue.SendOnSocket(Socket,IntToHex(Integer(ctSaveLocalFile),8)+FileData(Msg));
                               except
                                  On E:Exception do
                                     MessageQueue.SendOnSocket(Socket,IntToHex(Integer(ctError),8)+E.Message);
                               end;
                            end;  
         ctRxAcknowledge   : ;
         ctError           : ;
         ctResend          : ;
         ctAbortTx         : ;
         ctReplaceSelf     : ;        
         ctInvalid         : ; 
         ctCompressed      : ;
         ctExecShowFile    : ;
         ctExecShowWait    : ;
         ctExecAcknowledge : ;
         else // reply with ctError and original data !
            MessageQueue.SendOnSocket(Socket,IntToHex(Integer(ctError),8)+'Invalid '+Msg);
      end;        
   end; 
end;
procedure TCommsLink.RxMessage(Socket:TCustomWinSocket;Msg:String;MoreData:Boolean);
begin
   if (Msg <> '') then
      UnPackMessage(Socket,Msg,StrIPToHexIP(Socket.RemoteAddress));
end;

{TClientQueue}
constructor TClientQueue.Create(Server:String);
var
   ServerAddress:Integer;
begin
   ClientSocket:=TClientSocket.Create(nil,INADDR_ANY,False);
   ClientSocket.Active:=False;
   ClientSocket.ClientType:=ctNonBlocking;
   ClientSocket.Port:=MessagePortNumber;
   ServerAddress:=StrToInt('$'+Server);
   FServer:=IntToStr((ServerAddress shr 24) and $FF)+'.'+IntToStr((ServerAddress shr 16) and $FF)+'.'+IntToStr((ServerAddress shr 8) and $FF)+'.'+IntToStr(ServerAddress and $FF);
   ClientSocket.Address:=FServer;
   ClientSocket.OnWrite:=Write;
   ClientSocket.OnError:=Error;
   ClientSocket.OnRead:=Read;
   Messages:=TPackStringList.Create;
end;
destructor TClientQueue.Destroy;
begin
   if ClientSocket.Active then
      ClientSocket.Close;
   ClientSocket.Free;
   Messages.Free;
   inherited Destroy;
end;
procedure TClientQueue.Error(Sender:TObject;Socket:TCustomWinSocket;Event:TErrorEvent;var Code:Integer);
begin
   ClientSocket.Close;
   SocketError:=True;
   if Assigned(FOnError) then 
      FOnError(Sender,Socket,Event,Code)
   else
      LogError('{2CBF288C-9850-4C70-A709-FF30CCAC7098}','TClientQueue Error '+IntToStr(Integer(Event))+' '+ErrorString(Code));
end;                         
procedure TClientQueue.DisConnectClient;
begin
   if ClientSocket.Active then
      ClientSocket.Close;
end;
procedure TClientQueue.ConnectClient;
//var
//   Dial:Boolean;
begin
//   Dial:=EnableAutoDial(False);
   if not ClientSocket.Active then
   begin
      ClientSocket.Host:='';
      ClientSocket.Address:=FServer;
      ClientSocket.Open;
   end;
//   if Dial then EnableAutoDial(Dial);
end;
function WaitForData(Socket:TCustomWinSocket;Timeout: Longint): Integer;
var
  FDSet: TFDSet;
  TimeVal: TTimeVal;
begin
  TimeVal.tv_sec := Timeout div 1000;
  TimeVal.tv_usec := (Timeout mod 1000) * 1000;
  FD_ZERO(FDSet);
  FD_SET(Socket.SocketHandle, FDSet);
  Result := select(0, @FDSet, nil, nil, @TimeVal);
end;
procedure TClientQueue.Read(Sender:TObject;Socket:TCustomWinSocket);
begin
   if Assigned(FOnRead) then 
      FOnRead(Sender,Socket,seRead);
end;
procedure TClientQueue.Write(Sender:TObject;Socket:TCustomWinSocket);
var
   SentLength:Integer;
   SendLength:Integer;
   WaitForDataRes:Integer;
const
   SendString:String = '';
begin
   while Messages.Count <> 0 do
   begin
      SendString:=Messages.Strings[0];
      Messages.Delete(0);
      SendLength:=Length(SendString);
      try
         WaitForDataRes:=WaitForData(Socket,1);
         while WaitForDataRes <> 0 do
         begin
            Application.ProcessMessages;
            Sleep(1);
            WaitForDataRes:=WaitForData(Socket,1);
         end;
         SentLength:=Socket.SendBuf(Pointer(SendString)^,SendLength);
      except
         SentLength:=0;
      end;
      if SentLength > 0 then
      begin
         if SentLength <> SendLength then
         begin
            Messages.Insert(0,Copy(SendString,SentLength,SendLength));
            break;
         end;
      end
      else
      begin
         break;
      end;
   end;
end;
function TClientQueue.Send(Message:String):Boolean;
begin
   SocketError:=False;
   ConnectClient;
   Result:=False;
   While (not SocketError) and (not ClientSocket.Socket.Connected) do
   begin
      Application.ProcessMessages;
            Sleep(1);
      if Application.Terminated then Exit;
   end;
   if (not SocketError) then
   begin
      Messages.Add('Corvus:'+IntToHex(Length(Message),8)+':'+Message);
      Write(ClientSocket,ClientSocket.Socket);
      Result:=True;
//      ClientSocket.Close;
   end;
end;
{function TClientQueue.EnableAutoDial(State:Boolean):Boolean;
var
   Registry:TRegistry;
   BDBuffer:array[0..4] of Byte;
begin
   Result:=True;
   try
      Registry:=TRegistry.Create;
      with Registry do
      begin
         RootKey:=HKEY_CURRENT_USER;
         if (OpenKey('Software\Microsoft\Windows\CurrentVersion\Internet Settings',False)) then
         begin
            ReadBinaryData('EnableAutoDial',BDBuffer,4);
            if BDBuffer[0] = 1 then
               Result:=True
            else
               Result:=False;
            if State <> Result then
            begin
               if State then
                  BDBuffer[0]:=1
               else
                  BDBuffer[0]:=0;
               WriteBinaryData('EnableAutoDial',BDBuffer,4);
            end;
            CloseKey;
         end;
      end;
      Registry.Free;
   except
   end;
end; }

{TMessageQueue}
constructor TMessageQueue.Create;
begin
   Servers:=TPackStringList.Create;
   ServerSocket:=TServerSocket.Create(nil,INADDR_ANY,False);
   ServerSocket.Active:=False;
   ServerSocket.Port:=MessagePortNumber;
   ServerSocket.ServerType:=stNonBlocking;
   ServerSocket.OnClientRead:=Read;
   ServerSocket.OnClientError:=Error;
   LengthToReceive:=0;
   LastMessage:='';
   ReceivedMessage:=TMemoryStream.Create;
   ClearMessage;
end;
destructor TMessageQueue.Destroy;
begin
   ServerSocket.Free;
   while Servers.Count > 0 do
   begin
      if Servers.Objects[0] <> nil then
         TClientQueue(Servers.Objects[0]).Free;
      Servers.Delete(0);
   end;
   Servers.Free;
   ReceivedMessage.Free;
   inherited Destroy;
end;
procedure TMessageQueue.Activate;
begin
   ServerSocket.Active:=True;
end;
procedure TMessageQueue.DeActivate;
begin
   ServerSocket.Active:=False;
end;
procedure TMessageQueue.ClientRead(Sender:TObject;Socket:TCustomWinSocket;SocketEvent:TSocketEvent);
begin
   Read(Sender,Socket);
end;

function TMessageQueue.SendOnSocket(Socket:TCustomWinSocket;Message:String):Boolean;
var
   SentLength:Integer;
   SendLength:Integer;
   WaitForDataRes:Integer;
   SendString:String;
   RetryCount:Integer;
const
   RetryLimit=10;
begin
   Result:=False;
   RetryCount:=0;
   if Socket.Connected then
   begin
      Message:=IntToHex(Integer(ctCompressed),8)+TCompressor.CompressString(Message);
      Message:='Corvus:'+IntToHex(Length(Message),8)+':'+Message;
      while Message <> '' do
      begin
         SendString:=Message;
         Message:='';
         SendLength:=Length(SendString);
         try
            WaitForDataRes:=WaitForData(Socket,1);
            while WaitForDataRes <> 0 do
            begin
               Application.ProcessMessages;
               Sleep(1);
               WaitForDataRes:=WaitForData(Socket,1);
            end;
            SentLength:=Socket.SendBuf(Pointer(SendString)^,SendLength);
         except
            SentLength:=0;
         end;
         if SentLength > 0 then
         begin
            if SentLength <> SendLength then
            begin
               Message:=Copy(SendString,SentLength,SendLength);
            end;
         end
         else
            Inc(RetryCount);
         if RetryCount >= RetryLimit then
            Exit;
      end;
   end;
   Result:=True;
end;            
procedure TMessageQueue.Disconnect(ToServer:String);
var
   ClientQueue:TClientQueue;
   Index:Integer;
begin
   if Pos('.',ToServer) > 0 then
      ToServer:=StrIPToHexIP(ToServer); // convert x.x.x.x to Hex
   Index:=Servers.IndexOf(ToServer);
   if Index <> -1 then
   begin
      ClientQueue:=TClientQueue(Servers.Objects[Index]);
      Servers.Delete(Index);
      ClientQueue.DisConnectClient;
      ClientQueue.Free;
   end;
end;
function TMessageQueue.Send(ToServer,Message:String):Boolean;
var
   Index:Integer;
   ClientQueue:TClientQueue;
begin
   Result:=True;
   Message:=IntToHex(Integer(ctCompressed),8)+TCompressor.CompressString(Message);
   
   Index:=Servers.IndexOf(ToServer);
//   if Index = -1 then
//      Index:=Servers.AddObject(ToServer,TClientQueue.Create(ToServer));
   if Index <> -1 then Disconnect(ToServer);
   Index:=Servers.AddObject(ToServer,TClientQueue.Create(ToServer));
   ClientQueue:=TClientQueue(Servers.Objects[Index]);
   ClientQueue.OnError:=Error;
   ClientQueue.OnRead:=ClientRead;
   ClientQueue.Send(Message);
end;
procedure TMessageQueue.Error(Sender:TObject;Socket:TCustomWinSocket;Event:TErrorEvent;var Code: Integer);
begin
   if Assigned(FOnError) then 
      FOnError(Sender,Socket,Event,Code)
   else
      LogError('{8C6D5DE4-24A8-432C-A371-9FC8FBFE057C}','TMessageQueue Error '+IntToStr(Integer(Event))+' '+ErrorString(Code));
end;                         
procedure TMessageQueue.Notify(Socket:TCustomWinSocket;Message:String;MoreData:Boolean);
begin
   if Assigned(FOnMessage) then 
      FOnMessage(Socket,Message,MoreData);
end;
function TMessageQueue.HexToInt(Val:String):Integer;
var
  Pos:Integer;
  Nybble:Integer;
  ReturnVal:Integer;
begin
   Result:=-1;
   ReturnVal:=0;
   for Pos:=1 to Length(Val) do
   begin
      ReturnVal:=ReturnVal shl 4;
      Nybble:=Integer(Val[Pos])-48;
      if Nybble > 9 then Dec(Nybble,7);
      if (Nybble > 15) or (Nybble < 0) then Exit;
      Inc(ReturnVal,Nybble);
   end;
   Result:=ReturnVal;
end;
function TMessageQueue.GetLength(var Message:String):Integer;
var
   Size:Integer;
begin
   Result:=-1;
   if Copy(Message,1,7) = 'Corvus:' then
   begin
      Size:=HexToInt(Copy(Message,8,8));
      if Size > 0 then
      begin
         Message:=Copy(Message,17,Length(Message));
         Result:=Size;
      end;
   end;
end;
procedure TMessageQueue.AppendMessage(Message:String);
begin
   ReceivedMessage.Write(Pointer(Message)^,Length(Message));
end;
procedure TMessageQueue.ClearMessage;
begin
   ReceivedMessage.Position:=0;
end;
function TMessageQueue.GetMessage:String;
var
   Size:Integer;
begin
   Size:=ReceivedMessage.Position;
   ReceivedMessage.Position:=0;
   SetLength(Result,Size);
   ReceivedMessage.Read(Pointer(Result)^,Size);
end;
function TMessageQueue.ReceiveText(Socket:TCustomWinSocket):string;
var
  Buf: array [0..RxBufferSize] of Char;
  Temp: string;
  Bytes: Integer;
begin
  Result:='';
  Bytes := Socket.ReceiveBuf(Buf, sizeof(Buf));
  while Bytes > 0 do
  begin
    SetString(Temp, Buf, Bytes);
    Result := Result + Temp;
    if Length(Result) > MaxRxLength then
       break;
    Bytes := Socket.ReceiveBuf(Buf, sizeof(Buf));
  end;
end;
procedure TMessageQueue.Read(Sender:TObject;Socket:TCustomWinSocket);
var
   ReceivedLength:Integer;
   S:String;
begin
   S:=ReceiveText(Socket);
   if S <> '' then
   begin
      LastMessage:=LastMessage+S;
      ReceivedLength:=Length(LastMessage);
      Windows.Beep(1000,100);
      if ReceivedLength = 0 then Exit;

      if ReceivedLength = LengthToReceive then
      begin
         AppendMessage(LastMessage);
         LengthToReceive:=0;
         Notify(Socket,GetMessage,False);
         ClearMessage;
      end
      else if ReceivedLength < LengthToReceive then
      begin
         AppendMessage(LastMessage);
         Dec(LengthToReceive,ReceivedLength);
      end
      else
      begin
         while (ReceivedLength > 0) and (ReceivedLength >= LengthToReceive) do
         begin
            if LengthToReceive > 0 then
            begin
               AppendMessage(Copy(LastMessage,1,LengthToReceive));
               Notify(Socket,GetMessage,True);
               ClearMessage;
               LastMessage:=Copy(LastMessage,LengthToReceive+1,ReceivedLength);
               ReceivedLength:=Length(LastMessage);
            end;                          
            if ReceivedLength > 0 then
            begin
               LengthToReceive:=GetLength(LastMessage);
               if LengthToReceive < 0 then // Error
               begin
                  LastMessage:='';
                  LengthToReceive:=0;
                  Exit;         
               end;
               ReceivedLength:=Length(LastMessage);
               if ReceivedLength < LengthToReceive then
               begin
                  AppendMessage(LastMessage);
                  Dec(LengthToReceive,ReceivedLength);
                  ReceivedLength:=0;
               end;
            end
            else
            begin
               LengthToReceive:=0;
            end
         end;  
      end;
   end;
   LastMessage:='';
end;
function TMessageQueue.GetLocalIPAddress:String;
begin
    if ServerSocket <> nil then
       Result:=inet_ntoa(ServerSocket.Socket.LookupName(GetLocalMachineName))
    else
       Result:='';
end;
end.
