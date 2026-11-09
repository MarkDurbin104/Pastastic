unit SerialAU;

interface
uses
  Windows,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,PackStrListU;
  
  
type
  TSerialDevice = class(TGPCSDevice, IDevice)
  private
    FPortHandle    :THandle;
    FPortOpen      :Boolean;
    FPortSetup     :Boolean;
    FPortNumber    :Integer;
    FBaudRate      :Integer;
    FDataBits      :Integer;
    FParity        :String;
    FStopBits      :Integer;
    FInTimeOut     :Integer;
    FOutTimeOut    :Integer;
    FDeviceEventSink:IDeviceEventSink;
    function  SetupPort:Boolean;
    function WritePort(Data:String):WordBool;
    function WritePortB(Data:String;Length:Integer):WordBool;
    function ReadPort(var Data:String;var Length:Integer):WordBool;
    procedure ClosePort;
    function OpenPort:Boolean;
  public  
    procedure  Initialise;
    destructor Destroy; override;
    procedure SetEventSink(const EventSink: IDeviceEventSink); override;
    function  WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool; override;
    function  ReadDevice(var Data: WideString;var Len: Integer):WordBool; override;
    function  GetStatus: WideString; override;
  end;                  
  
implementation
uses
   ComServ2;
   
procedure TSerialDevice.Initialise;
begin
   FBaudRate   :=9600 ;
   FDataBits   :=1    ;
   FParity     :='N'  ;
   FPortNumber :=1    ;
   FStopBits   :=8    ;
   FInTimeOut  :=500  ;
   FOutTimeOut :=1000 ;
end; 

destructor TSerialDevice.Destroy;
begin
    if FPortOpen then ClosePort;
    inherited Destroy;
end;
function TSerialDevice.OpenPort:Boolean;
var
   PortNumber:String;
begin
   result:=False;
   if FPortOpen then ClosePort;
   FPortOpen:=False;
   PortNumber:='COM'+IntToStr(FPortNumber);
   
   FPortHandle:=CreateFile(PChar(PortNumber),GENERIC_READ+GENERIC_WRITE,
                           0,nil,OPEN_EXISTING,0,0);
   if FPortHandle <> INVALID_HANDLE_VALUE then 
   begin
      FPortOpen:=True;
      result:=True;
   end;
end;
procedure TSerialDevice.ClosePort;
begin
    if (FPortOpen) and (FPortHandle <> INVALID_HANDLE_VALUE) then 
        CloseHandle(FPortHandle);
    FPortHandle:=INVALID_HANDLE_VALUE;
    FPortOpen:=False;
    FPortSetup:=False;
end;

function TSerialDevice.SetupPort:Boolean;
var
   dcb:TDCB;
   ct:TCommTimeOuts;
begin
   result:=False; 
   FPortSetup:=False;
   if not FPortOpen then Exit;
   
   ct.ReadIntervalTimeout        :=0;
   ct.ReadTotalTimeoutMultiplier :=0;
   ct.ReadTotalTimeoutConstant   :=FInTimeOut;
   ct.WriteTotalTimeoutMultiplier:=0;
   ct.WriteTotalTimeoutConstant  :=FOutTimeOut;
   
   if GetCommState(FPortHandle,dcb) then
   begin
      if (FBaudRate = 19200) or (FBaudRate = 9600 )
      or (FBaudRate = 4800 ) or (FBaudRate = 2400 )
      or (FBaudRate = 1200 ) or (FBaudRate = 600  )
      or (FBaudRate = 300  ) or (FBaudRate = 110  ) then 
        dcb.BaudRate:=FBaudRate
      else dcb.BaudRate:=FBaudRate;
      
      if (FDataBits = 8) or (FDataBits = 7)
      or (FDataBits = 6) or (FDataBits = 5) then 
         dcb.ByteSize:=FDataBits
      else dcb.ByteSize:=8;
      
      if      (FParity = 'n') or (FParity = 'N') then dcb.Parity:=NOPARITY
      else if (FParity = 'e') or (FParity = 'E') then dcb.Parity:=EVENPARITY
      else if (FParity = 'o') or (FParity = 'O') then dcb.Parity:=ODDPARITY
      else dcb.Parity:=NOPARITY;
      
      if      FStopBits = 1  then dcb.StopBits:=ONESTOPBIT
      else if FStopBits = 15 then dcb.StopBits:=ONE5STOPBITS
      else if FStopBits = 2  then dcb.StopBits:=TWOSTOPBITS
      else dcb.StopBits:=ONESTOPBIT;
      
      if SetCommState(FPortHandle,dcb) then
      begin
         if SetCommTimeouts(FPortHandle,ct) then 
         begin
            FPortSetup:=True;
            result:=True; 
         end;
      end;
   end;
end; 
function TSerialDevice.WritePortB(Data:String;Length:Integer):WordBool;
var
   BytesWritten:DWORD;
   len:DWORD;
   PString:ShortString;
begin
   result:=False;
   if (not FPortOpen ) and (not OpenPort) then Exit;
   if (not FPortSetup) and (not SetupPort) then Exit;
   PString:=Data;
   len:=Length;
   if WriteFile(FPortHandle,PString[1],len,BytesWritten,nil) then
   begin
       if len = BytesWritten then
          result:=True;
   end;
end;
function TSerialDevice.WritePort(Data:String):WordBool;
begin
   result:=WritePortB(Data,Length(Data));
end;
function TSerialDevice.ReadPort(var Data:String;var Length:Integer):WordBool;
var
   BytesRead:DWORD;
   RByte:Array[0..100] of Char;
   ReqLen:Integer;
begin
   ReqLen:=Length;
   Data:='';
   Length:=0;
   result:=False;
   if (not FPortOpen ) and (not OpenPort) then Exit;
   if (not FPortSetup) and (not SetupPort) then Exit;
   if ReadFile(FPortHandle,RByte,ReqLen,BytesRead,nil) then
   begin
       RByte[BytesRead+1]:=#0;
       if Integer(BytesRead) = ReqLen then 
          Result:=True;
       Data:=Copy(RByte,1,BytesRead);
       Length:=BytesRead;
   end;                   
end;
procedure TSerialDevice.SetEventSink(const EventSink: IDeviceEventSink);
begin
   FDeviceEventSink:=EventSink;
   FDeviceEventSink.Trigger('OK');
end;
function TSerialDevice.WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool;
var
   SL:TPackStringList;
begin
   case CommandType of
      dcInitialise : begin
                       try
                          SL:=TPackStringList.Create;
                          SL.CommaText:=Data;
                          FPortNumber:=StrToIntDef(SL[0],1   );
                          FBaudRate  :=StrToIntDef(SL[1],9600);
                          FDataBits  :=StrToIntDef(SL[2],1   );
                          FParity    :=            SL[3]      ;
                          FStopBits  :=StrToIntDef(SL[4],8   );
                          FInTimeOut :=StrToIntDef(SL[5],500 );
                          FOutTimeOut:=StrToIntDef(SL[6],1000);
                          SL.Free;
                          OpenPort;
                          SetUpPort;
                          Result:=True;
                      except     
                          Result:=False;
                      end;
                    end;
      dcRawData   : Result:=WritePort(Data);
      dcBinData   : Result:=WritePortB(Data,Len);
      dcShutdown  : begin
                       ClosePort; 
                       FDeviceEventSink:=nil;
                       Result:=True;
                    end;   
      else Result:=False;
   end;                                 
end;              
function TSerialDevice.ReadDevice(var Data: WideString;var Len: Integer):WordBool;
var
   DataString:String;
begin
   DataString:='';
   Result:=ReadPort(DataString,Len);
   Data:=DataString;
end;
function TSerialDevice.GetStatus: WideString;
begin
   Result:='';
end;
initialization
  TGPCSCompFactory.Create(ComServer,TSerialDevice,Class_SerialDevice,
                          'Device.Serial','GPCS Serial Device',
                          ciMultiInstance);
end.