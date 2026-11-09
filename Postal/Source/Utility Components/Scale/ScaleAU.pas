unit ScaleAU;

interface

uses
  Windows,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Registry,PackStrListU,UDPMessageU;

const
   GramsPer100thOz = 0.2835;

type
  TScaleDevice = class(TGPCSDevice,IDevice,IDeviceEventSink)
    FDeviceEventSink:IDeviceEventSink;
    FSerialDevice:IDevice;
    FReadTimer:TTimer;
    FPrefix:String;
    FSuffix:String;
    FReadInterval:Integer;
    FLastReading:String;
    FLogFile:String;
    UseCustDisp:Boolean;
    FScaleType:String;
    BasicUDP:TBasicUDP;
    UDPPort:String;
  protected
    procedure LogValue(DataString:String);
    procedure ReadTimerEvent(Sender: TObject);
    function GetDeviceEntry(Name:String):String;
    procedure TriggerReading(Value:String;Source:Boolean);
    procedure RxEvent(Sender:TBasicUDP;From,TimeStamp,Data:String);
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

function AveLastNValues(Value:String;NValues:Integer):String;
const
   LastValues:Array[1..20] of Integer = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
   CurrOfs:Integer = 1;
var
   I:Integer;
   TotVal:Integer;
begin
   if CurrOfs < NValues then
   begin
      LastValues[CurrOfs]:=StrToIntDef(Value,0);
      Inc(CurrOfs);
      Result:=Value;
   end
   else
   begin
      TotVal:=0;
      for I:=1 to NValues-1 do
      begin
         LastValues[I]:=LastValues[I+1];
         Inc(TotVal,LastValues[I]);
      end;
      LastValues[CurrOfs]:=StrToIntDef(Value,0);
      Inc(TotVal,LastValues[CurrOfs]);
      Result:=IntToStr(TotVal div NValues);
   end;
end;
procedure TScaleDevice.SetEventSink(const EventSink: IDeviceEventSink);
begin
   FDeviceEventSink:=EventSink;
end;
function Strip(S:String):String;
var
   I:Integer;
begin
   Result:='';
   for I:=1 to Length(S) do
      if S[I] in ['0'..'9','.'] then
         Result:=Result+S[I];
end;

function TrimToFigures(DataString:String):String;
const
   LastVal:Integer = 0;
   LastDummy:Integer = 0;
var
   SignificantChange:Boolean;
   Stable:Boolean;
   LBs,OZs:Currency;
begin
   Stable:=True;
   Result:='-2';
   if (Length(DataString) >= 17) then 
   begin
      if (StrScan(PChar(DataString),'z') = nil) then // no "oz" in string - grammes
      begin
         try
            Result:=CurrToStr(1000*StrToCurr(Trim(Copy(DataString,2,8))));
         except
            Result:='-2';
         end;
         if (Byte(DataString[14]) and 1) = 1 then
            Stable:=False;
      end
      else
      begin   
         try
            LBs:=1600*StrToCurr(Strip(Copy(DataString,2,4)));
            OZs:=StrToCurr(Trim(Copy(DataString,7,4)))*100;
            Result:=IntToStr(Trunc((LBs+OZs)*GramsPer100thOz));
         except
            Result:='-2';
         end;
         if (Byte(DataString[16]) and 1) = 1 then
            Stable:=False;
      end;
   end
   else
   begin
      if GetGPCSRegString('','DummyScale','0') = '1' then
      begin
         Inc(LastDummy);
         Result:='0';
         if ((LastDummy mod 10) = 0) or ((LastDummy mod 10) = 1) or ((LastDummy mod 10) = 2) then
            Result:='10';
         Stable:=True;
      end;
   end;
   SignificantChange:=(Abs(LastVal-StrToInt(Result)) > 1);
   
   if Stable and SignificantChange then 
      LastVal:=StrToInt(Result)
   else
      Result:=IntToStr(LastVal); // keep the last reading
end;
procedure TScaleDevice.LogValue(DataString:String);
var
   SL:TPackStringList;
   S:String;
   I:Integer;
   LBs,OZs:Currency;
begin
   if FLogFile = '' then Exit;
   S:='Short String';
   if Length(DataString) >= 17 then
   begin
      if DataString[2] = '^' then 
         S:='Over Range'
      else if DataString[2] = '_' then 
         S:='Under Range'
      else
      begin
         if (StrScan(PChar(DataString),'z') = nil) then // no oz in string
         begin
            try
               S:=CurrToStr(1000*StrToCurr(Trim(Copy(DataString,2,8))));
            except
               S:='0';
            end;
            case DataString[14] of
               '0' : S:=S+' Stable';
               '1' : S:=S+' Moving';
               '2' : S:=S+' AtZero';
               else  S:=S+' ??????';
            end;
         end
         else
         begin
            try
               LBs:=1600*StrToCurr(Trim(Copy(DataString,2,2)));
               OZs:=StrToCurr(Trim(Copy(DataString,7,4)))*100;
               S:=IntToStr(Trunc((LBs+OZs)*GramsPer100thOz));
            except
               S:='0';
            end;
            case DataString[18] of
               '0' : S:=S+' Stable';
               '1' : S:=S+' Moving';
               '2' : S:=S+' AtZero';
               else  S:=S+' ??????';
            end;
         end;
      end;
   end;
   SL:=TPackStringList.Create;
   try
      SL.LoadFromFile(FLogFile);
      while SL.Count > 999 do // maintain a log of <= 1000 lines
         SL.Delete(0);
   except
   end;
   try
      SL.Add(S);
      S:='DataString = ';
      for I:=1 to Length(DataString) do 
         S:=S+IntToHex(Integer(DataString[I]),2)+',';
      SL.Add(S);
      SL.SaveToFile(FLogFile);
   except
   end;
   SL.Free;
end;
procedure TScaleDevice.RxEvent(Sender:TBasicUDP;From,TimeStamp,Data:String);
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.PackText:=Data;
   if (SL.Count > 1) and (SL[0] = UDPPort) then
   begin
      FLastReading:=SL[1];
      TriggerReading(SL[1],False);
   end;
   SL.Free;
end;
procedure TScaleDevice.TriggerReading(Value:String;Source:Boolean);
var
   SL:TPackStringList;
   
begin
   if FDeviceEventSink = nil then Exit;
   FDeviceEventSink.Trigger(Value);
   if Source then
   begin
      SL:=TPackStringList.Create;
      SL.Add(UpperCase(GetLocalMachineName));
      SL.Add(Value);
      BasicUDP.SendDGram(SL.PackText);
      SL.Free;
   end;
end;
function CASTrimToFigures(DataString:String):String;
var
   I:Integer;
begin
   Result:='-1';
   if Length(DataString) = 16 then
   begin
      Result:='';
      for I:=5 to 11 do 
         if DataString[I] in ['0'..'9','-'] then
            Result:=Result+DataString[I];
      Result:=Result+'0';
      Result:=IntToStr(StrToIntDef(Result,-1));
   end;
end;
procedure TScaleDevice.ReadTimerEvent(Sender: TObject);
const
   NegCount:Integer=0;
var
   DataString:WideString;
   Len:Integer;
begin
   Len:=StrToIntDef(GetGPCSRegString('DeviceSetup\Scale','Dummy','0'),0);
   if Len > 0 then
   begin
       TriggerReading(FPrefix+IntToStr(Len)+FSuffix,True);
       Exit;
   end;
   if (FSerialDevice <> nil) then
   begin
      if FScaleType = 'CAS' then
         Len:=16
      else
         Len:=22;
      FSerialDevice.ReadDevice(DataString,Len);
      LogValue(DataString);
      if FScaleType = 'CAS' then
         DataString:=CASTrimToFigures(DataString)
      else
         DataString:=TrimToFigures(DataString);
      if DataString <> '' then
      begin
         FReadTimer.Interval:=FReadInterval;
         FLastReading:=DataString;
         if DataString[1] = '-' then 
         begin
            Inc(NegCount);
         end
         else
         begin
            NegCount:=0;
            if FDeviceEventSink <> nil then
                TriggerReading(FPrefix+DataString+FSuffix,True);
         end;
         if DataString[1] = '-' then 
            Inc(NegCount);
         if NegCount > 5 then
            if FDeviceEventSink <> nil then
                TriggerReading(FPrefix+DataString+FSuffix,True);
      end;              
      if NegCount > 10 then
      begin
         FReadTimer.Interval:=1000;
         FSerialDevice.WriteDevice(dcBinData,'Z'#13,2);
         NegCount:=0;
      end
      else
         if FScaleType = 'CAS' then
         begin
            FSerialDevice.WriteDevice(dcBinData,#5#$11,2);
         end
         else
            FSerialDevice.WriteDevice(dcBinData,'W'#13,2);
   end;
end;
function TScaleDevice.GetDeviceEntry(Name:String):String;
var
   Registry:TRegistry;
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   Registry:=TRegistry.Create;
   with Registry do
   begin
      RootKey:=HKEY_LOCAL_MACHINE;
      if OpenKey('SOFTWARE\PSL\GPCS\DeviceSetup\'+Name,False) then
      begin
         UDPPort:=UpperCase(ReadString('PortNumber'));
         SL.Add(UDPPort); 
         SL.Add(ReadString('BaudRate'  ));
         SL.Add(ReadString('DataBits'  ));
         SL.Add(ReadString('Parity'    ));
         SL.Add(ReadString('StopBits'  ));
         SL.Add(ReadString('InTimeOut' ));
         SL.Add(ReadString('OutTimeOut'));
         Result:=SL.CommaText;
         FPrefix:=ReadString('Prefix');
         FSuffix:=ReadString('Suffix');
         FReadInterval:=StrToIntDef(ReadString('ReadInterval'),500);
         FLogFile:=ReadString('LogFile');
         UseCustDisp:=ReadString('UseCustDisp') = '1';
         FScaleType:=ReadString('Type');
      end
      else
      begin
         FLogFile:='';
         FPrefix:='';
         FSuffix:='';
         FScaleType:='';
         FReadInterval:=750;
         Result:='1,9600,8,N,1,500,500';
      end;
      CloseKey;
      Free;
   end;
   Sl.Free;
end;
function TScaleDevice.WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool;
var
  S:String;
begin
   Result:=False;
   case CommandType of
      dcInitialise : begin
                       S:=GetDeviceEntry('Scale');
                       BasicUDP:=TBasicUDP.Create;
                       BasicUDP.PortNumber:=56000;
                       BasicUDP.Active:=True; //for transmit
                       if (Length(UDPPort) > 1) and (UDPPort[1] in ['\','A'..'Z','a'..'z']) then
                       begin
                          FSerialDevice:=nil;
                          BasicUDP.OnRxDGram:=RxEvent;
                       end
                       else
                       begin
                          if UseCustDisp then
                             FSerialDevice:=CreateCustDispDevice
                          else
                             FSerialDevice:=CreateSerialDevice;
                          end;
                       if FSerialDevice <> nil then
                       begin
                          FSerialDevice.SetEventSink(Self);
                          FSerialDevice.WriteDevice(dcInitialise,S,0);
                          FReadTimer:=TTimer.Create(nil);
                          FReadTimer.Enabled:=False;
                          FReadTimer.Interval:=FReadInterval;
                          FReadTimer.OnTimer:=ReadTimerEvent;
                          FReadTimer.Enabled:=True;
                          if FScaleType = 'CAS' then
                          begin
                             FSerialDevice.WriteDevice(dcBinData,#5#$11,2);
                          end
                          else
                             FSerialDevice.WriteDevice(dcBinData,'W'#13,2);
                          Result:=True;
                       end;
                    end;
      dcRawData   : begin
                       FSerialDevice.WriteDevice(dcBinData,'Z'#13,2);
                       Result:=True;
                    end;
      dcShutdown  : begin
                      if BasicUDP <> nil then
                         BasicUDP.Free;
                      BasicUDP:=nil;
                      FSerialDevice:=nil;
                      FDeviceEventSink:=nil;
                      FReadTimer.Free;
                      Result:=True;
                    end;
   end;
end;
function TScaleDevice.ReadDevice(var Data: WideString;var Len: Integer):WordBool;
begin
   Data:=FLastReading;
   Len:=Length(Data);
   Result:=(Len > 0);
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
   TriggerReading(Data,True);
end;
procedure TScaleDevice.ControlReleased;
begin
end;                             
initialization
  TGPCSCompFactory.Create(ComServer,TScaleDevice,Class_ScaleDevice,
                          'Device.Scale','GPCS Scale Device',
                          ciMultiInstance); //
end.