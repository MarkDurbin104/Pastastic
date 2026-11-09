unit OCRAU;

interface

uses
  Windows,Classes,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Registry,SysUtils;
  
type
  TOCRDevice = class(TGPCSDevice, IDevice,IDeviceEventSink)
    FDeviceEventSink:IDeviceEventSink;
    FSerialDevice:IDevice;
    FReadTimer:TTimer;
    FPrefix:String;
    FSuffix:String;
    FReadInterval:Integer;
    protected
    procedure ReadTimerEvent(Sender: TObject);
    function GetDeviceEntry(Name:String):String;
  public
    procedure SetEventSink(const EventSink: IDeviceEventSink); override;
    function WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool; override;
    function ReadDevice(var Data: WideString;var Len: Integer):WordBool; override;
    function  GetStatus: WideString; override;
    function  TakeControl: WordBool; override;
    procedure ReleaseControl;       override;
    procedure Trigger(const Data: WideString); safecall;
    procedure ControlReleased; safecall;
  end;                  
  
implementation
uses
   ComServ2;
   
procedure TOCRDevice.SetEventSink(const EventSink: IDeviceEventSink);
begin
   FDeviceEventSink:=EventSink;
end;
function TrimToFigures(Value:String):String;
var
   I:Integer;
begin
   Result:='';
   for I:=1 to Length(Value) do
   begin
      if Value[I] in ['0'..'9'] then
         Result:=Result+Value[I];
   end;
end;
procedure TOCRDevice.ReadTimerEvent(Sender: TObject);
var
   DataString:WideString;
   OneChar:WideString;
   Len:Integer;
begin
   if (FSerialDevice <> nil) and (FDeviceEventSink <> nil) then
   begin
      Len:=1;
      if FSerialDevice.ReadDevice(OneChar,Len) then
      begin
         FReadTimer.Enabled:=False;
         DataString:=OneChar;
         while FSerialDevice.ReadDevice(OneChar,Len) do
            DataString:=DataString+OneChar;
         FDeviceEventSink.Trigger(FPrefix+TrimToFigures(DataString)+FSuffix);
         FReadTimer.Enabled:=True;
      end;
   end;
end;
function TOCRDevice.GetDeviceEntry(Name:String):String;
var
   Registry:TRegistry;
   SL:TStringList;
begin
   SL:=TStringList.Create;
   Registry:=TRegistry.Create;
   with Registry do
   begin
      RootKey:=HKEY_LOCAL_MACHINE;
      if OpenKey('SOFTWARE\PSL\GPCS\DeviceSetup\'+Name,False) then
      begin
         SL.Add(ReadString('PortNumber'));
         SL.Add(ReadString('BaudRate'  ));
         SL.Add(ReadString('DataBits'  ));
         SL.Add(ReadString('Parity'    ));
         SL.Add(ReadString('StopBits'  ));
         SL.Add(ReadString('InTimeOut' ));
         SL.Add(ReadString('OutTimeOut'));
         FPrefix:=ReadString('Prefix');
         FSuffix:=ReadString('Suffix');
         FReadInterval:=StrToIntDef(ReadString('ReadInterval'),500);
         Result:=SL.CommaText;  
      end
      else
      begin
         FPrefix:='%';
         FSuffix:='%';
         Result:='1,2400,8,N,1,500,1000';
         FReadInterval:=200000;
      end;                      
      CloseKey;
      Free;
   end;
   Sl.Free;
end;
function TOCRDevice.WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool;
begin
   Result:=False;
   case CommandType of
      dcInitialise : begin
                       FSerialDevice:=CreateSerialDevice;
                       if FSerialDevice <> nil then
                       begin
                          FSerialDevice.SetEventSink(Self);
                          FSerialDevice.WriteDevice(dcInitialise,GetDeviceEntry('OCR'),0);
                          FReadTimer:=TTimer.Create(nil);
                          FReadTimer.Enabled:=False;
                          FReadTimer.Interval:=FReadInterval;
                          FReadTimer.OnTimer:=ReadTimerEvent;
                          FReadTimer.Enabled:=True;
                          Result:=True;  
                       end;                                                              
                    end;
      dcRawData   : Result:=True;
      dcShutdown  : begin
                      FSerialDevice:=nil;
                      FDeviceEventSink:=nil;
                      FReadTimer.Free;
                      Result:=True;
                    end;
   end;                            
end;              
function TOCRDevice.ReadDevice(var Data: WideString;var Len: Integer):WordBool;
begin
   Result:=False;
end;
function TOCRDevice.GetStatus: WideString;
begin
   Result:='';
end;
function TOCRDevice.TakeControl: WordBool; 
begin
   Result:=False;
end;
procedure TOCRDevice.ReleaseControl;       
begin
end;
procedure TOCRDevice.Trigger(const Data: WideString);
begin
end;
procedure TOCRDevice.ControlReleased;
begin
end;
initialization
  TGPCSCompFactory.Create(ComServer,TOCRDevice,Class_OCRDevice,
                          'Device.OCR','GPCS OCR Reader',
                          ciMultiInstance);
end.