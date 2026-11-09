unit RASDialer;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,Ras,
  ExtCtrls, StdCtrls, ComCtrls,MesQueueU,GPCSGUID;

type

  TConnectEvent = procedure (Sender:TObject;Event:String) of object;
  TRasCallBackFunc = procedure(Msg:Integer;state:TRasConnState;dwError:Longint); stdcall;
  TRasDialer = class(TObject)
  private
     FOnConnectEvent:TConnectEvent;
     FOnErrorEvent:TConnectEvent;
     RasCallBackFunc:TRasCallBackFunc;
     FRasConn: THRasConn;
     FRasDialParams: TRasDialParams;
     FCLientIPAddress:String;
     FServerIPAddress:String;
     FConnected:Boolean;
     FOnConnected:TConnectEvent;
     FOnDisConnected:TConnectEvent;
  public
     constructor Create;
     destructor Destroy; override;
     function GetPhoneBookEntries:String;
     procedure Phone(EntryName:String);
     procedure HangUp;
     procedure CheckConnectStatus;
     procedure GetIPAddress;
     procedure GetCredentials(EntryName:String;var UserName,Password,Domain:String);
     procedure GetEntry(EntryName:String;var UserName,Password,PhoneNumber,Domain:String);
     procedure AddEntry(EntryName,UserName,Password,PhoneNumber,Domain:String);
     procedure ModEntry(EntryName,UserName,Password,PhoneNumber,Domain:String);
     procedure DeleteEntry(EntryName:String);
     procedure ReNameEntry(EntryName,NewEntryName:String);
     procedure ChangeUser(EntryName,UserName:String);
     procedure ChangePassword(EntryName,Password:String);
     procedure ChangePhoneNumber(EntryName,PhoneNumber:String);
     procedure ChangeDomain(EntryName,Domain:String);
     property OnConnectEvent:TConnectEvent read FOnConnectEvent write FOnConnectEvent; 
     property OnErrorEvent  :TConnectEvent read FOnErrorEvent   write FOnErrorEvent  ; 
     property OnConnected   :TConnectEvent read FOnConnected    write FOnConnected   ;
     property OnDisConnected:TConnectEvent read FOnDisConnected write FOnDisConnected;
     property RasConn       :THRasConn      read FRasConn       write FRasConn      ;
     property RasDialParams :TRasDialParams read FRasDialParams write FRasDialParams;
     property CLientIPAddress:String read FCLientIPAddress write FCLientIPAddress;
     property ServerIPAddress:String read FServerIPAddress write FServerIPAddress;
     property Connected:Boolean read FConnected write FConnected;
  end;
var
   RasDialVar:TRasDialer;
   
function ErrorToStr(ErrorCode:Integer):String;

implementation      
function ErrorToStr(ErrorCode:Integer):String;
begin
    SetLength(Result,512);
    RasGetErrorString(ErrorCode,PChar(Result),512);
    Result:=StrPas(PChar(Result));
    if Result = '' then
      Result:='Error Code '+IntToStr(ErrorCode);
end;

procedure RasCallBack(Msg:Integer;State:TRasConnState;dwError:Longint); stdcall;
var
  S:String;
begin
   if (dwError <> 0) then 
   begin
      S:=ErrorToStr(dwError);
      if Assigned(RasDialVar.FOnErrorEvent) then
         RasDialVar.FOnErrorEvent(RasDialVar,S);
      state:=RASCS_Disconnected;
   end;
   case state of
      RASCS_OpenPort:
         S := 'The comm port is about to be opened.';
      RASCS_PortOpened:
         S := 'The comm port has been opened successfully.';
      RASCS_ConnectDevice:
         S := 'A device is about to be connected.';
      RASCS_DeviceConnected:
         S := 'A device has connected successfully.';
      RASCS_AllDevicesConnected:
         S := 'All devices have successfully connected.';
      RASCS_Authenticate:
         S := 'The authentication process is starting.';
      RASCS_AuthNotify:
         S := 'An authentication event has occurred.';
      RASCS_AuthRetry:
         S := 'New validation attempt requested.';
      RASCS_AuthCallback:
         S := 'The remote server has requested a callback.';
      RASCS_AuthChangePassword:
         S := 'The client has requested a password change.';
      RASCS_AuthProject:
         S := 'The projection phase is starting.';
      RASCS_AuthLinkSpeed:
         S := 'The link-speed calculation phase is starting.';
      RASCS_AuthAck:
         S := 'An authentication request is being acknowledged.';
      RASCS_ReAuthenticate:
         S := 'Reauthentication (after callback) is starting.';
      RASCS_Authenticated:
         S := 'The client has successfully completed authentication.';
      RASCS_PrepareForCallback:
         S := 'The line will disconnect in preparation for callback.';
      RASCS_WaitForModemReset:
         S := 'Delaying; getting ready for a callback.';
      RASCS_WaitForCallback:
         S := 'Waiting for an incoming call from the remote server.';
      RASCS_Projected:
         S := 'Projection result information is available.';
      RASCS_StartAuthentication:
         S := 'Windows 95 only: User authentication initiated.';
      RASCS_CallbackComplete:
         S := 'Windows 95 only: Client has been called back.';
      RASCS_LogonNetwork:
         S := 'Windows 95 only: Client is logging on to the network.';
      RASCS_Connected: begin
         S := 'Successful connection.';
         RasDialVar.Connected:=True;
         RasDialVar.GetIPAddress;
         if Assigned(RasDialVar.OnConnected) then
            RasDialVar.OnConnected(RasDialVar,'Connect');
      end;
      RASCS_Disconnected: begin
          S := 'Disconnection or failed connection.';
          RasDialVar.Connected:=False;
          RasHangUp(RasDialVar.RasConn);
          RasDialVar.RasConn := 0;
         if Assigned(RasDialVar.OnDisConnected) then
            RasDialVar.OnDisConnected(RasDialVar,'Connect');
      end;
   end;                         
  if Assigned(RasDialVar.OnConnectEvent) then
     RasDialVar.OnConnectEvent(RasDialVar,S);
end;
{TRasDialer}
//   FOnConnectEvent:TConnectEvent;
constructor TRasDialer.Create;
begin
   RasDialVar:=Self;
   FRasConn:=0;
   FConnected:=False;
   RasCallBackFunc:=RasCallBack;
end;
destructor TRasDialer.Destroy;
begin
   if FRasConn <> 0 then HangUp;
end;
procedure TRasDialer.HangUp;
begin
   RasCallBackFunc(0,RASCS_Disconnected,0);
end;
procedure TRasDialer.GetIPAddress;
var
  RasPppIp:TRasPppIp;
  dwSize:Integer;
  ErrNo:Integer;
begin
  FCLientIPAddress:='';
  FServerIPAddress:='';
  If FRASConn = 0 then Exit;
  FillChar(RasPppIp,SizeOf(RasPppIp),#0);
  RASPppIp.dwSize:=SizeOf(RasPppIp);
  dwSize:=SizeOf(RasPppIp);
  ErrNo:=RASGetProjectionInfo(RASConn,RASP_PppIp,@RasPppIp,dwSize) ;
  if ErrNo = 0 then
  begin
    FCLientIPAddress:=StrPas(RasPppIp.szIpAddress);
    FServerIPAddress:=StrPas(RasPppIp.szServerIpAddress);
  end
  else
    if Assigned(FOnConnectEvent) then 
       FOnConnectEvent(Self,ErrorToStr(ErrNo));
end;  
procedure TRasDialer.CheckConnectStatus;
var
  RASConnStatus: TRASConnStatus;
begin
  if (RASConn <> 0) then
  begin
     FillChar(RASConnStatus,SizeOf(RASConnStatus),#0);
     RASConnStatus.dwSize:=SizeOf(RasConnStatus);
     RasGetConnectStatus(RASConn,RASConnStatus);
     if RASConnStatus.RasConnState <> RASCS_Connected then
        RasCallBackFunc(0,RASCS_Disconnected,RASConnStatus.dwError);
  end;
end;   
function TRasDialer.GetPhoneBookEntries:String;
var
  RasEntryName: array[1..2000] of TRasEntryName;
  I: DWord;
  ErrNo:Integer;
  BufSize:Integer;
  Entries:Integer;
  SL:TStringList;
begin
  SL:=TStringList.Create;
  BufSize:=SizeOf(RasEntryName);
  RasEntryName[1].dwSize := SizeOf(RasEntryName[1]);
  ErrNo:=RasEnumEntries(nil,nil,@RasEntryName,BufSize,Entries);
  if ErrNo = 0 then
  begin
     for I := 1 to Entries do
     begin
       if RasEntryName[i].szEntryName[0] <> #0 then
          SL.Add(StrPas(RasEntryName[i].szEntryName));
     end;
  end
  else
    if Assigned(FOnConnectEvent) then 
       FOnConnectEvent(Self,ErrorToStr(ErrNo));
  Result:=SL.CommaText;
  SL.Free;
end;
procedure TRasDialer.Phone(EntryName:String);
var
  ErrNo:Integer;
begin
  if Assigned(FOnConnectEvent) then
    FOnConnectEvent(Self,'Starting Call');
    
  if (StrPas(FRASDialParams.szUserName) = '') 
  or (StrPas(FRASDialParams.szDomain  ) = '') 
  or (StrPas(FRASDialParams.szPassword) = '') then // hard code user/password on NT/2000
  begin
    FOnConnectEvent(Self,'Replacing Blank User / Password / Domain from Registry');
    StrPCopy(FRASDialParams.szUserName,GetPSLRegString('Message Transfer','Dialup User Name','CorvusDial'));
    StrPCopy(FRASDialParams.szPassword,GetPSLRegString('Message Transfer','Dialup Password' ,'CorvusDial'));
    StrPCopy(FRASDialParams.szDomain  ,GetPSLRegString('Message Transfer','Dialup Domain'   ,''));
  end;
    
  ErrNo:=RasDial(nil,nil,FRasDialParams,0,@RasCallBackFunc,FRasConn);
  if (ErrNo <> 0) then 
  begin
    if Assigned(FOnConnectEvent) then 
       FOnConnectEvent(Self,ErrorToStr(ErrNo));
    if Assigned(FOnDisConnected) then
       FOnDisConnected(Self,ErrorToStr(ErrNo));
  end;
end;

procedure TRasDialer.GetCredentials(EntryName:String;var UserName,Password,Domain:String);
var
  RasCredentials:TRASCredentials;
  ErrNo:Integer;
begin
   ZeroMemory(@RasCredentials,SizeOf(TRASCredentials));
   RasCredentials.dwSize:=SizeOf(TRASCredentials);
   RasCredentials.dwMask:=RASCM_UserName or RASCM_Password or RASCM_Domain;
   ErrNo:=RasGetCredentials(nil,PChar(EntryName),RasCredentials);
   if ErrNo = 0 then
   begin
      if ((RasCredentials.dwMask) and RASCM_UserName) <> 0 then 
         UserName:=StrPas(RasCredentials.szUserName);
      if ((RasCredentials.dwMask) and RASCM_Password) <> 0 then 
         Password:=StrPas(RasCredentials.szPassword);
      if ((RasCredentials.dwMask) and RASCM_Domain  ) <> 0 then 
         Domain  :=StrPas(RasCredentials.szDomain  );
   end
   else
     if Assigned(FOnConnectEvent) then 
        FOnConnectEvent(Self,ErrorToStr(ErrNo));
end;
procedure TRasDialer.GetEntry(EntryName:String;var UserName,Password,PhoneNumber,Domain:String);
var
  fp: LongBool;
  ErrNo, ESize, DSize: Longint;
  Entry: TRasEntry;
  S: string;
begin
  ZeroMemory(@FRasDialParams,SizeOf(TRasDialParams));
  FRasDialParams.dwSize:=Sizeof(TRasDialParams);
  StrLCopy(FRasDialParams.szEntryName,PChar(EntryName),Ras_MaxEntryName);
  ErrNo:=RasGetEntryDialParams(nil,FRasDialParams,fp);
  if (ErrNo = 0) then
  begin
     if Assigned(FOnConnectEvent) then
        FOnConnectEvent(Self,S);
     with FRasDialParams do 
     begin
        UserName:=StrPas(FRASDialParams.szUserName);
        if fp then Password:=StrPas(FRASDialParams.szPassword);
        Domain := StrPas(FRASDialParams.szDomain);
     end;
  end
  else
  begin
    if Assigned(FOnConnectEvent) then 
       FOnConnectEvent(Self,ErrorToStr(ErrNo));
    Exit;
  end;

  ESize:=0;
  DSize:=0;
  Entry.dwSize:=SizeOf(TRasEntry);
  RasGetEntryProperties(nil,PChar(EntryName),nil,ESize,nil,DSize);
  ErrNo:=RasGetEntryProperties(nil,PChar(EntryName),@Entry,ESize,nil,DSize);
  if (ErrNo = 0) then 
  begin
     with Entry do 
     begin
        if (dwCountryCode <> null) and (szAreaCode <> '') then
           PhoneNumber:=IntToStr(dwCountryCode)+' ('+szAreaCode+') '+szLocalPhoneNumber
        else if (szAreaCode <> '') then
           PhoneNumber:='('+szAreaCode+') '+szLocalPhoneNumber
        else
           PhoneNumber:=szLocalPhoneNumber;
     end;
  end
  else if Assigned (FOnConnectEvent) then
  begin
    if Assigned(FOnConnectEvent) then 
       FOnConnectEvent(Self,ErrorToStr(ErrNo));
  
{     case RasGetErrorString(ErrNo, cTxt, 256) of
        0                                    : S:=cTxt;
        ERROR_INSUFFICIENT_BUFFER            : S:='ERROR INSUFFICIENT BUFFER';
        ERROR_INVALID_PARAMETER              : S:='ERROR INVALID PARAMETER';
        else case ErrNo of
           ERROR_INVALID_USER_BUFFER         : S:='ERROR_INVALID_USER_BUFFER';
           ERROR_INVALID_PARAMETER           : S:='ERROR_INVALID_PARAMETER';
           ERROR_BUFFER_INVALID              : S:='ERROR_BUFFER_INVALID';
           ERROR_BUFFER_TOO_SMALL            : S:='ERROR_BUFFER_TOO_SMALL';
           ERROR_CANNOT_OPEN_PHONEBOOK       : S:='ERROR_CANNOT_OPEN_PHONEBOOK';
           ERROR_CANNOT_FIND_PHONEBOOK_ENTRY : S:='ERROR_CANNOT_FIND_PHONEBOOK_ENTRY';
           else                                S:='Unknown => ' + IntToStr(ErrNo);
        end;
     end;
     FOnConnectEvent(Self,'RasGetEntryProperties failed with: ' + S); }
     if Assigned(FOnDisConnected) then
         FOnDisConnected(Self,'RasGetEntryProperties failed with: ' + S);
  end;
end;
procedure TRasDialer.AddEntry(EntryName,UserName,Password,PhoneNumber,Domain:String);
begin
end;
procedure TRasDialer.ModEntry(EntryName,UserName,Password,PhoneNumber,Domain:String);
begin
end;
procedure TRasDialer.DeleteEntry(EntryName:String);
begin
end;
procedure TRasDialer.ReNameEntry(EntryName,NewEntryName:String);
begin
end;
procedure TRasDialer.ChangeUser(EntryName,UserName:String);
begin
end;
procedure TRasDialer.ChangePassword(EntryName,Password:String);
begin
end;
procedure TRasDialer.ChangePhoneNumber(EntryName,PhoneNumber:String);
begin
end;
procedure TRasDialer.ChangeDomain(EntryName,Domain:String);
begin
end;

end.
