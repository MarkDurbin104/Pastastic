unit CountersAU;

interface

uses
  Forms,Windows,Graphics,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Dialogs,UDPMessageU,PackStrListU;

type
  TCountersDevice = class(TGPCSDevice,IDevice,IDeviceEventSink)
    FDeviceEventSink:IDeviceEventSink;
    MessageServer:TMessageServer;
    CounterName:String;
    WaitForCounter:String;
    UsingGlobal:Boolean;
    CounterValue:Integer;
    ThisIsTheServer:Boolean;
  protected
    function  GetDeviceEntry(Name:String):String;
    function  GetGlobalCounter(Name:String):String;
    procedure RxMessage(From,Data:String;MsgNumber:Integer);
  public
    procedure AppExcept(Sender: TObject; E: Exception);
    procedure Initialize; override;
    destructor Destroy; override;
    procedure SetEventSink(const EventSink: IDeviceEventSink);                                      override;
    function  WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool; override;
    function  ReadDevice(var Data: WideString;var Len: Integer):WordBool;                           override;
    function  GetStatus: WideString;                                                                override;
    function  TakeControl: WordBool;                                                                override;
    procedure ReleaseControl;                                                                       override;
    procedure Trigger(const Data: WideString);                                                      safecall;
    procedure ControlReleased;                                                                      safecall;
  end;

implementation
uses
   ComServ2;

procedure TCountersDevice.AppExcept(Sender: TObject; E: Exception);
begin
  RaiseGUIDException('{D4397D1D-3A89-4997-940E-6FF13E7485B1}', E);
end;

procedure TCountersDevice.Initialize;
begin
  Application.OnException := AppExcept;
  UsingGlobal:=GetGPCSRegString('Counters','UsingGlobal','0') <> '0';
  ThisIsTheServer:=GetGPCSRegString('Counters','Server','0') <> '0';
  if UsingGlobal then
  begin
    MessageServer:=TMessageServer.Create;
    TBasicUDP(MessageServer.BasicUDPList[0]).RxOwn:=True;
    TBasicUDP(MessageServer.BasicUDPList[0]).PortNumber:=49001;
    MessageServer.OnRxMessage:=RxMessage;
  end;
end;
destructor TCountersDevice.Destroy;
begin
   if (UsingGlobal) and (MessageServer <> nil) then
   begin
      MessageServer.Free;
      MessageServer:=nil;
   end;
   inherited Destroy;
end;
procedure TCountersDevice.SetEventSink(const EventSink: IDeviceEventSink);
begin
   FDeviceEventSink:=EventSink;
end;
procedure TCountersDevice.RxMessage(From,Data:String;MsgNumber:Integer);
var
   SL:TPackStringList;
   Name:String;
begin
   SL:=TPackStringList.Create;
   SL.PackText:=Data;
   if SL.Count > 3 then
   begin
      if  (SL[0] = 'Counter')
      and (SL[1] = WaitForCounter)
      and (SL[2] = TBasicUDP(MessageServer.BasicUDPList[0]).HexIPAddress) then
      begin
         CounterValue:=StrToIntDef(SL[3],0);
      end;
   end
   else if (ThisIsTheServer) and (SL.Count > 1) then
   begin
      if  (SL[0] = 'GetCounter') then
      begin
         Name:=SL[1];
         CounterValue:=StrToIntDef(GetGPCSRegString('Counters\'+Name,'CurrentValue','0'),0);
         SetGPCSRegString('Counters\'+Name,'CurrentValue',IntToStr(CounterValue+1));
         SL.Clear;
         SL.Add('Counter');
         SL.Add(Name);
         SL.Add(From);
         SL.Add(IntToStr(CounterValue));
         MessageServer.SendMessage(SL.PackText);
      end;
   end;
   SL.Free;
end;
function TCountersDevice.GetGlobalCounter(Name:String):String;
var
   InnerTimeout:Integer;
   OuterTimeout:Integer;
const
   RetrySendCount = 5;
   RetryReceiveCount = 100;
begin
   CounterValue:=-1;
   WaitForCounter:=Name;
   OuterTimeout:=0;
   while (CounterValue = -1) and (not Application.Terminated) and (OuterTimeout < RetrySendCount) do
   begin
      MessageServer.SendMessage(#1'GetCounter'+#1+Name);
      InnerTimeout:=0;
      while (CounterValue = -1) and (not Application.Terminated) and (InnerTimeout < RetryReceiveCount) do
      begin
         Application.ProcessMessages;
         Sleep(1);
         Inc(InnerTimeout);
      end;
      if InnerTimeout >= RetryReceiveCount then
      begin
         GPCSErrorLine.RaiseError(0,0,0,'Timeout Error waiting for Counter '+WaitForCounter+' Retrying');
      end;
      Inc(OuterTimeout);
   end;
   if OuterTimeout >= RetrySendCount then
   begin
      GPCSErrorLine.RaiseError(0,0,0,'Failed on Timeout Error waiting for Counter '+WaitForCounter);
   end;
   Result:=IntToStr(CounterValue);
end;
function TCountersDevice.GetDeviceEntry(Name:String):String;
begin
   if UsingGlobal then
   begin
//      Result:=GetGlobalCounter(Name);
      Result := '-1'; //force global error
      If Result = '-1' then //global counter failed
      begin
        Result:=GetGPCSRegString('Counters\'+Name,'CurrentValue','0');
        SetGPCSRegString('Counters\'+Name,'CurrentValue',IntToStr(StrToIntDef(Result,0)+1));
        Result := '-' + Result; 
      end;
   end
   else
   begin
      Result:=GetGPCSRegString('Counters\'+Name,'CurrentValue','0');
      SetGPCSRegString('Counters\'+Name,'CurrentValue',IntToStr(StrToIntDef(Result,0)+1));
   end;
end;
function TCountersDevice.WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool;
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
      dcLine1Data  : Result:=True;
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
function TCountersDevice.ReadDevice(var Data: WideString;var Len: Integer):WordBool;
begin
   Data:=GetDeviceEntry(Data);
end;
function TCountersDevice.GetStatus: WideString;
begin
   Result:=GetDeviceEntry(CounterName);
end;
function TCountersDevice.TakeControl: WordBool;
begin
   Result:=False;
end;
procedure TCountersDevice.ReleaseControl;
begin
end;
procedure TCountersDevice.Trigger(const Data: WideString);
begin
end;
procedure TCountersDevice.ControlReleased;
begin
end;
initialization

  TGPCSCompFactory.Create(ComServer,TCountersDevice,Class_CounterDevice,
                          'Device.Counters','GPCS Counter Device',
                          ciMultiInstance);
end.