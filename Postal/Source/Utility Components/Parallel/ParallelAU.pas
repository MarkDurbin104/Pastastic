unit ParallelAU;

interface
uses
  Windows,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode;

type
  TParallelDevice = class(TGPCSDevice, IDevice)
  private
    FPortHandle    :THandle;
    FPortOpen      :Boolean;
    FPortNumber    :Integer;
    FDeviceEventSink:IDeviceEventSink;
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

function CreateParallelDevice  :IDevice;
begin
  Result:=CreateComObject(Class_ParallelDevice) as IDevice;
end;

function CreateRemoteParallelDevice(const MachineName:String):IDevice;
begin
  Result:=CreateRemoteComObject(MachineName,Class_ParallelDevice) as IDevice;
end;


procedure TParallelDevice.Initialise;
begin
   FPortNumber :=1    ;
end;

destructor TParallelDevice.Destroy;
begin
    if FPortOpen then ClosePort;
    inherited Destroy;
end;
function TParallelDevice.OpenPort:Boolean;
var
   PortNumber:String;
begin
   result:=False;
   if FPortOpen then ClosePort;
   FPortOpen:=False;
   PortNumber:='LPT'+IntToStr(FPortNumber);

   FPortHandle:=CreateFile(PChar(PortNumber),GENERIC_READ+GENERIC_WRITE,
                           0,nil,OPEN_EXISTING,0,0);
   if FPortHandle <> INVALID_HANDLE_VALUE then 
   begin
      FPortOpen:=True;
      result:=True;
   end;
end;
procedure TParallelDevice.ClosePort;
begin
    if (FPortOpen) and (FPortHandle <> INVALID_HANDLE_VALUE) then
        CloseHandle(FPortHandle);
    FPortHandle:=INVALID_HANDLE_VALUE;
    FPortOpen:=False;
end;

function TParallelDevice.WritePortB(Data:String;Length:Integer):WordBool;
var
   BytesWritten:DWORD;
   len:DWORD;
   PString:ShortString;
begin
   result:=False;
   if (not FPortOpen ) and (not OpenPort) then Exit;

   PString:=Data;
   len:=Length;
   if WriteFile(FPortHandle,PString[1],len,BytesWritten,nil) then
   begin
       if len = BytesWritten then
          result:=True;
   end;
end;
function TParallelDevice.WritePort(Data:String):WordBool;
begin
   result:=WritePortB(Data,Length(Data));
end;
function TParallelDevice.ReadPort(var Data:String;var Length:Integer):WordBool;
var
   BytesRead:DWORD;
   RByte:Array[0..100] of Char;
begin
   Data:='';
   result:=False;
   if (not FPortOpen ) and (not OpenPort) then Exit;

   if ReadFile(FPortHandle,RByte,Length,BytesRead,nil) then
   begin
       RByte[BytesRead+1]:=#0;
       if Integer(BytesRead) = Length then
          Result:=True;
       Data:=Copy(RByte,1,BytesRead);
       Length:=BytesRead;
   end;
end;
procedure TParallelDevice.SetEventSink(const EventSink: IDeviceEventSink);
begin
   FDeviceEventSink:=EventSink;
   FDeviceEventSink.Trigger('OK');
end;

function TParallelDevice.WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool;
begin
   case CommandType of
      dcInitialise : begin
                       try
                          FPortNumber:=StrToIntDef(Data,1   );
                          OpenPort;
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

function TParallelDevice.ReadDevice(var Data: WideString;var Len: Integer):WordBool;
var
   DataString:String;
begin
   DataString:='';
   Result:=ReadPort(DataString,Len);
   Data:=DataString;
end;
function TParallelDevice.GetStatus: WideString;
begin
   Result:='';
end;


initialization
  TGPCSCompFactory.Create(ComServer,TParallelDevice,Class_ParallelDevice,
                          'Device.Parallel','GPCS Parallel Device',
                          ciMultiInstance);
end.