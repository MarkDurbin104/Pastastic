unit ScaleAU;

interface

uses
  Windows,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Registry;
  
type
  TScaleDevice = class(TGPCSDevice,IDevice,IDeviceEventSink)
    FDeviceEventSink:IDeviceEventSink;
    FReadTimer:TTimer;
    FPrefix:String;
    FSuffix:String;
    FReadInterval:Integer;
    FLastReading:String;
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
   ComServ2,ScaleFU;
   
procedure TScaleDevice.SetEventSink(const EventSink: IDeviceEventSink);
begin
   FDeviceEventSink:=EventSink;
end;
procedure TScaleDevice.ReadTimerEvent(Sender: TObject);
begin
   FReadTimer.Interval:=FReadInterval;
   if FDeviceEventSink <> nil then
   begin
      FLastReading:=IntToStr(StrToIntDef(Trim(Form1.MaskEdit1.Text),-2));
      FDeviceEventSink.Trigger(FPrefix+FLastReading+FSuffix);
   end;
end;
function TScaleDevice.GetDeviceEntry(Name:String):String;
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
         FPrefix:='^';
         FSuffix:='^';
         FReadInterval:=1000;
         Result:='1,9600,8,N,1,500,500';
      end;
      CloseKey;
      Free;
   end;
   Sl.Free;
end;
function TScaleDevice.WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool;
begin
   Result:=False;
   case CommandType of
      dcInitialise : begin
                        FPrefix:='^';
                        FSuffix:='^';
                        FReadInterval:=1000;
//                        Form1.Caption:=GetDeviceEntry('Scale');
                        FReadTimer:=TTimer.Create(nil);
                        FReadTimer.Enabled:=False;
                        FReadTimer.Interval:=10000;
                        FReadTimer.OnTimer:=ReadTimerEvent;
                        FReadTimer.Enabled:=True;
                        Result:=True;       
                     end;
      dcRawData   :  begin
                        Result:=True;
                     end;
      dcShutdown  :  begin
                       FDeviceEventSink:=nil;
                       FReadTimer.Free;
                       Result:=True;
                     end;
   end;                            
end;              
function TScaleDevice.ReadDevice(var Data: WideString;var Len: Integer):WordBool;
begin
   Result:=False;
end;
function TScaleDevice.GetStatus: WideString;
begin
   Result:=FLastReading;
end;
function TScaleDevice.TakeControl: WordBool; 
begin
   Result:=False;
end;
procedure TScaleDevice.ReleaseControl;       
begin
end;
procedure TScaleDevice.Trigger(const Data: WideString);
begin
end;
procedure TScaleDevice.ControlReleased;
begin
end;                             
initialization
  TGPCSCompFactory.Create(ComServer,TScaleDevice,Class_ScaleDevice,
                          'Device.Scale','GPCS Scale Device',
                          ciMultiInstance);
end.