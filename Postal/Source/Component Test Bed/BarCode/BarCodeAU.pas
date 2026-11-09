unit BarCodeAU;

interface

uses
  Windows,Classes,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Registry,SysUtils;
  
type
  TBarCodeDevice = class(TGPCSDevice, IDevice,IDeviceEventSink)
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
    function ReadDevice(var Data: WideString; Len: Integer):WordBool; override;
    function  GetStatus: WideString; override;
    function  TakeControl: WordBool; override;
    procedure ReleaseControl;       override;
    procedure Trigger(const Data: WideString); safecall;
    procedure ControlReleased; safecall;
  end;                  
  
implementation
uses
   ComServ2,BarCodeFU;
   
procedure TBarCodeDevice.SetEventSink(const EventSink: IDeviceEventSink);
begin
   FDeviceEventSink:=EventSink;
end;
procedure TBarCodeDevice.ReadTimerEvent(Sender: TObject);
begin
   if FDeviceEventSink <> nil then
   begin
      if Form1.DataAvailable <> '' then   
          FDeviceEventSink.Trigger(FPrefix+Form1.DataAvailable+FSuffix);
      Form1.DataAvailable:='';
   end;
end;
function TBarCodeDevice.GetDeviceEntry(Name:String):String;
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
         FPrefix:='*';
         FSuffix:='*';
         Result:='9,9600,8,N,1,500,1000';
         FReadInterval:=2000;
      end;                      
      CloseKey;
      Free;
   end;
   Sl.Free;
end;
function TBarCodeDevice.WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool;
begin
   Result:=False;
   case CommandType of
      dcInitialise : begin
                        FPrefix:='*';
                        FSuffix:='*';
                        FReadInterval:=2000;
//                       Form1.Caption:=GetDeviceEntry('BarCode');
                       FReadTimer:=TTimer.Create(nil);
                       FReadTimer.Enabled:=False;
                       FReadTimer.Interval:=FReadInterval;
                       FReadTimer.OnTimer:=ReadTimerEvent;
                       FReadTimer.Enabled:=True;
                       Result:=True;  
                    end;
      dcRawData   : Result:=True;
      dcShutdown  : begin
                      Form1.Caption:='Bar Code Device';
                      FSerialDevice:=nil;
                      FDeviceEventSink:=nil;
                      FReadTimer.Free;
                      Result:=True;
                    end;
   end;                            
end;              
function TBarCodeDevice.ReadDevice(var Data: WideString; Len: Integer):WordBool;
begin
   Result:=False;
end;
function TBarCodeDevice.GetStatus: WideString;
begin
   Result:='';
end;
function TBarCodeDevice.TakeControl: WordBool; 
begin
   Result:=False;
end;
procedure TBarCodeDevice.ReleaseControl;       
begin
end;
procedure TBarCodeDevice.Trigger(const Data: WideString);
begin
end;
procedure TBarCodeDevice.ControlReleased;
begin
end;
initialization
  TGPCSCompFactory.Create(ComServer,TBarCodeDevice,Class_ExtBarCodeDevice,
                          'Device.BarCode','GPCS BarCode Reader',
                          ciMultiInstance);
end.