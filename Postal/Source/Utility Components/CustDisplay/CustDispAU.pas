unit CustDispAU;

interface

uses
  Windows,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Registry;
  
type
  TCustDispDevice = class(TGPCSDevice,IDevice,IDeviceEventSink)
    FDeviceEventSink:IDeviceEventSink;
    FSerialDevice:IDevice;
  protected
    function  GetDeviceEntry(Name:String):String;
    function  SendCommand(CommandStr:String):Boolean;
    procedure WriteLine(LineNo:Integer;Data:String);
  public
    procedure SetEventSink(const EventSink: IDeviceEventSink); override;
    function  WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool; override;
    function  ReadDevice(var Data: WideString;var Len: Integer):WordBool; override;
    function  GetStatus: WideString; override;
    function  TakeControl: WordBool; override;
    procedure ReleaseControl;       override;
    procedure Trigger(const Data: WideString); safecall;
    procedure ControlReleased; safecall;
  end;                  
  
implementation
uses
   ComServ2;
   
procedure TCustDispDevice.SetEventSink(const EventSink: IDeviceEventSink);
begin
   FDeviceEventSink:=EventSink;
end;
function TCustDispDevice.GetDeviceEntry(Name:String):String;
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
         Result:=SL.CommaText;
      end
      else
      begin
         Result:='1,9600,8,N,1,500,500';
      end;
      CloseKey;
      Free;
   end;
   Sl.Free;
end;
function TCustDispDevice.SendCommand(CommandStr:String):Boolean;
var       
   Res:WideString;
//   TimeOut:Integer;
begin
   FSerialDevice.WriteDevice(dcRawData,#$04+#$01+CommandStr+#$17,0);
   Result:=True;
   Res:=' '; 
//   TimeOut:=0; 
//   while not FSerialDevice.ReadDevice(Res,1) and (TimeOut < 100) do 
//      Inc(TimeOut); 
   if Res[1] <> #6 then 
      Result:=False;
end;
procedure TCustDispDevice.WriteLine(LineNo:Integer;Data:String);
var
   S:String;
begin
   if LineNo = 0 then
      SendCommand(#$50+#$31)
   else
      SendCommand(#$50+#$45);
   S:=Copy(Data,1,20);
   while Length(S) < 20 do S:=S+' ';
   FSerialDevice.WriteDevice(dcRawData,S,0);
end;
function TCustDispDevice.WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool;
var
   SL:TStringList;
begin
   Result:=False;
   case CommandType of
      dcInitialise : begin
                       SL:=TStringList.Create;
                       SL.CommaText:=GetDeviceEntry('CustDisp');
                       if SL[0] = '0' then
                          FSerialDevice:=CreateParallelDevice
                       else
                          FSerialDevice:=CreateSerialDevice;
                       if FSerialDevice <> nil then
                       begin
                          FSerialDevice.SetEventSink(Self);
                          FSerialDevice.WriteDevice(dcInitialise,SL.CommaText,0);
                          SendCommand(#$43+#$31+#$58);
                          Result:=True;       
                       end;                                                              
                       SL.Free;
                    end;
      dcRawData   : begin
                       if Data = '' then 
                       begin
                          SendCommand(#$43+#$31+#$58);
                       end
                       else
                       begin
                          SL:=TStringList.Create;
                          SL.CommaText:=Data;
                          if SL.Count > 0 then WriteLine(0,SL[0]);
                          if SL.Count > 1 then WriteLine(1,SL[1]);
                          SL.Free;
                       end;
                       Result:=True;
                    end;
      dcShutdown  : begin
                      FSerialDevice:=nil;
                      FDeviceEventSink:=nil;
                      Result:=True;
                    end;
   end;                            
end;              
function TCustDispDevice.ReadDevice(var Data: WideString;var Len: Integer):WordBool;
begin
   Result:=False;
end;
function TCustDispDevice.GetStatus: WideString;
begin
   Result:='';
end;
function TCustDispDevice.TakeControl: WordBool; 
begin
   Result:=False;
end;
procedure TCustDispDevice.ReleaseControl;       
begin
end;
procedure TCustDispDevice.Trigger(const Data: WideString);
begin
end;
procedure TCustDispDevice.ControlReleased;
begin
end;
initialization
  TGPCSCompFactory.Create(ComServer,TCustDispDevice,Class_CustDispDevice,
                          'Device.CustDisp','GPCS Custustomer Display Device',
                          ciMultiInstance);
end.