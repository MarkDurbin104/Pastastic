unit OfficeInfoAU;

interface

uses
  Windows,Graphics,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Registry;
  
type
  TOfficeInfoDevice = class(TGPCSDevice,IDevice,IDeviceEventSink)
    FDeviceEventSink:IDeviceEventSink;
    CounterName:String;
  protected
    function  GetDeviceEntry(Name:String):String;
    procedure SetDeviceEntry(Name,Value:String);
  public  
    procedure SetEventSink(const EventSink: IDeviceEventSink);                          override;
    function  WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool; override;
    function  ReadDevice(var Data: WideString;var Len: Integer):WordBool;                  override;
    function  GetStatus: WideString;                                                    override;
    function  TakeControl: WordBool;                                                    override;
    procedure ReleaseControl;                                                           override;
    procedure Trigger(const Data: WideString);                                          safecall;
    procedure ControlReleased;                                                          safecall;
  end;                  
  
implementation
uses
   ComServ2;
   
procedure TOfficeInfoDevice.SetEventSink(const EventSink: IDeviceEventSink);
begin
   FDeviceEventSink:=EventSink;
end;
function TOfficeInfoDevice.GetDeviceEntry(Name:String):String;
var
   Registry:TRegistry;
begin
   Registry:=TRegistry.Create;
   with Registry do
   begin
      RootKey:=HKEY_LOCAL_MACHINE;
      if OpenKey('SOFTWARE\PSL\GPCS\OfficeInfo',False) then
      begin
         Result:=ReadString(Name);
         if Result = '' then WriteString(Name,'');
      end                       
      else
      begin
         if OpenKey('SOFTWARE\PSL\GPCS\OfficeInfo',True) then
         begin
            WriteString(Name,'');
            Result:='';                       
         end;
      end;
      CloseKey;
      Free;
   end;
end;
procedure TOfficeInfoDevice.SetDeviceEntry(Name,Value:String);
var
   Registry:TRegistry;
begin
   Registry:=TRegistry.Create;
   with Registry do
   begin
      RootKey:=HKEY_LOCAL_MACHINE;
      if OpenKey('SOFTWARE\PSL\GPCS\OfficeInfo',True) then
      begin
         WriteString(Name,Value);
      end;
      CloseKey;
      Free;
   end;
end;
function TOfficeInfoDevice.WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool;
begin
   Result:=False;
   case CommandType of
      dcInitialise : begin
                        CounterName:=Data;
                        Result:=True;       
                      end;
      dcRawData    : begin
                     end;
      dcShutdown   : begin
                        FDeviceEventSink:=nil;
                        Result:=True;
                     end;
      dcLine1Data  : begin
                        SetDeviceEntry(CounterName,Data);
                        Result:=True;
                     end;
      dcLine2Data  : Result:=True;
      dcLine3Data  : Result:=True;
      dcLine4Data  : Result:=True;
      dcLine5Data  : Result:=True;
      dcList1Data  : Result:=True;
      dcList2Data  : Result:=True;
      dcList3Data  : Result:=True;
      dcList4Data  : Result:=True;
      dcList5Data  : Result:=True;                  
      else Result:=False;
   end;                            
end;              
function TOfficeInfoDevice.ReadDevice(var Data: WideString;var Len: Integer):WordBool;
begin
   Data:=GetDeviceEntry(Data);
   Result:=True;
end;
function TOfficeInfoDevice.GetStatus: WideString;
begin
   Result:=GetDeviceEntry(CounterName);
end;
function TOfficeInfoDevice.TakeControl: WordBool; 
begin
   Result:=False;
end;
procedure TOfficeInfoDevice.ReleaseControl;       
begin
end;
procedure TOfficeInfoDevice.Trigger(const Data: WideString);
begin
end;
procedure TOfficeInfoDevice.ControlReleased;
begin
end;
initialization
  TGPCSCompFactory.Create(ComServer,TOfficeInfoDevice,Class_OfficeInfoDevice,
                          'Device.OfficeInfo','GPCS Office Info Device',
                          ciMultiInstance);
end.