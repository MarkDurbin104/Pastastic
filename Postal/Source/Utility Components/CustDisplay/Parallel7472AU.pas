unit Parallel7472AU;

interface

uses
  StringUtil,
  Windows,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Registry;
  
type
  TCustDispDevice = class(TGPCSDevice,IDevice,IDeviceEventSink)
    CustDispType:String;
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

var
    DeviceEventSink:IDeviceEventSink;
    SerialDevice:IDevice;
    
implementation
uses
   ComServ2;
   
procedure TCustDispDevice.SetEventSink(const EventSink: IDeviceEventSink);
begin
   DeviceEventSink:=EventSink;
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
         CustDispType:=ReadString('Type');
         if CustDispType = '' then CustDispType:='NCRa';
         Result:=SL.CommaText;
      end
      else
      begin
         Result:='1,9600,8,N,1,500,500';
         CustDispType:='NCRa';
      end;
      CloseKey;
      Free;
   end;
   Sl.Free;
end;
function TCustDispDevice.SendCommand(CommandStr:String):Boolean;
//var
//   Res:WideString;
const
  InSendCommand:Boolean = False;
begin
   Result:=True;
   if InSendCommand then Exit;
   InSendCommand:=True;
   try
      if CustDispType = 'EPOS Logic' then
        CommandStr:=#$1B+'=2'+#13+CommandStr+#13+#$1B+'=1'+#13;
      SerialDevice.WriteDevice(dcRawData,CommandStr,0);
   finally
     InSendCommand:=False;
   end;
//   Res:=' ';
//   TimeOut:=0;
//   while not SerialDevice.ReadDevice(Res,1) and (TimeOut < 100) do
//      Inc(TimeOut);
//   if Res[1] <> #6 then
//      Result:=False;
end;
procedure TCustDispDevice.WriteLine(LineNo:Integer;Data:String);
var
   S:String;
begin
   S:=Copy(Data,1,20);
   while Length(S) < 20 do S:=S+' ';
   //correct £ sign
   S := Replace(S,'£',#156);
   if CustDispType = 'NCRa' then
   begin
      if LineNo = 0 then
         SendCommand(#$1B+#$13+#$0+S)
      else
         SendCommand(#$1B+#$13+#$14+S);
   end
   else if CustDispType = 'EPOS Logic' then
   begin
      SendCommand(S+#13)
   end
   else if CustDispType = 'Baird Technologies' then
   begin
      if LineNo = 0 then
         SendCommand(#$1B+'QA'+S+#13)
      else
         SendCommand(#$1B+'QB'+S+#13);
   end;
end;
function TCustDispDevice.WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool;
var
   SL:TStringList;
begin
   Result:=False;
   case CommandType of
      dcInitialise : begin
                       if SerialDevice = nil then
                       begin
                          SL:=TStringList.Create;
                          SL.CommaText:=GetDeviceEntry('CustDisp');
                          if SL[0] = '0' then
                             SerialDevice:=CreateParallelDevice
                          else
                             SerialDevice:=CreateSerialDevice;
                          if SerialDevice <> nil then
                          begin
                             SerialDevice.SetEventSink(Self);
                             SerialDevice.WriteDevice(dcInitialise,SL.CommaText,0);
                             if CustDispType = 'NCRa' then
                                SendCommand(#$1B+#$05);
                             Result:=True;
                          end;                                                              
                          SL.Free;
                       end;                                                              
                    end;    
      dcBinData   : SerialDevice.WriteDevice(dcBinData,Data,Len);
      dcRawData   : begin
                       if Data = '' then
                       begin
                          if CustDispType = 'NCRa' then
                             SendCommand(#$1B+#$02)
                          else if CustDispType = 'EPOS Logic' then
                          begin
                             SendCommand(#$0C)
                          end
                          else if CustDispType = 'Baird Technologies' then
                             SendCommand(#$0C);
                       end                          
                       else
                       begin
                          SL:=TStringList.Create;
                          SL.CommaText:=Data;
                          if SL.Count > 0 then WriteLine(0,SL[0]) else WriteLine(0,'');
                          if SL.Count > 1 then WriteLine(1,SL[1]) else WriteLine(1,'');
                          SL.Free;
                       end;
                       Result:=True;
                    end;
      dcShutdown  : begin
//                      SerialDevice:=nil;
                      DeviceEventSink:=nil;
                      Result:=True;
                    end;
   end;
end;
function TCustDispDevice.ReadDevice(var Data: WideString;var Len: Integer):WordBool;
begin
   Result:=SerialDevice.ReadDevice(Data,Len);
end;
function TCustDispDevice.GetStatus: WideString;
begin
   Result:=SerialDevice.GetStatus;
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
   if DeviceEventSink <> nil then
      DeviceEventSink.Trigger(Data);
end;
procedure TCustDispDevice.ControlReleased;
begin
end;
initialization
  TGPCSCompFactory.Create(ComServer,TCustDispDevice,Class_CustDispDevice,
                          'Device.CustDisp','GPCS Custustomer Display Device',
                          ciMultiInstance);
end.