unit TCPIPCU;

interface

uses
   Windows,Forms,SysUtils,UDPMessageU,PackStrListU;
   
const   
   Interval1Day    = 1;
   Interval1Hour   = (Interval1Day / 24);
   Interval1Minute = (Interval1Hour / 60);
   Interval1Second = (Interval1Minute / 60);
   
type
  TRxCommand = procedure (FromProc,Command,Data:String) of object;
  TTCPIPC = class(TObject)
  private
     LocalUDP:TBasicUDP;
     FOnRxCommand:TRxCommand;
     procedure RxDGram(Sender:TBasicUDP;From,TimeStamp,Data:String);
  public
     ThisProcess:String;
     Waiting:Boolean;
     ReceivedResponse:String;
     constructor Create;
     destructor Destroy; override;
     procedure SendCommand(ToProc,Command,Data:String);
     function SendCommandAndWait(ToProc,Command,Data:String;WaitInSeconds:Integer):String;
     property OnRxCommand:TRxCommand read FOnRxCommand write FOnRxCommand;
  end;

implementation

constructor TTCPIPC.Create;
begin
   inherited Create;
   Waiting:=False;
   ThisProcess:='TCPIPC';
   LocalUDP:=TBasicUDP.Create;
   LocalUDP.RxOwn:=True;
   LocalUDP.PortNumber:=54321;
   LocalUDP.OnRxDGram:=RxDGram;
   LocalUDP.Active:=True;
end;
destructor TTCPIPC.Destroy;
begin
   LocalUDP.Active:=False;
   LocalUDP.Free;
   inherited Destroy;
end;
procedure TTCPIPC.SendCommand(ToProc,Command,Data:String);
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Add(ThisProcess);
   SL.Add(ToProc);
   SL.Add(Command);
   SL.Add(Data);
   LocalUDP.SendDGram(SL.PackText);
   SL.Free;
end;
function TTCPIPC.SendCommandAndWait(ToProc,Command,Data:String;WaitInSeconds:Integer):String;
var
   SL:TPackStringList;
   EndTime:TDateTime;
begin
   SL:=TPackStringList.Create;
   SL.Add(ThisProcess);
   SL.Add(ToProc);
   SL.Add(Command);
   SL.Add(Data);
   EndTime:=Now+(WaitInSeconds*Interval1Second);
   Waiting:=True;
   LocalUDP.SendDGram(SL.PackText);
   while (not Application.Terminated)
   and (Now < EndTime)
   and (Waiting) do
   begin
      Application.ProcessMessages;
      Sleep(1);
   end;
   if not Waiting then
      Result:=ReceivedResponse
   else
      Result:='Timeout';
   Waiting:=False;
   SL.Free;
end;
procedure TTCPIPC.RxDGram(Sender:TBasicUDP;From,TimeStamp,Data:String);
var
   SL:TPackStringList;
begin 
   if (From = LocalUDP.HexIPAddress) and Assigned (FOnRxCommand) then
   begin
      SL:=TPackStringList.Create;
      SL.PackText:=Data;
      if (SL.Count > 3) and (SL[1] = ThisProcess) then
      begin
         if Waiting then
         begin
            ReceivedResponse:=SL[3];
            Waiting:=False;
         end
         else
         begin
            FOnRxCommand(SL[0],SL[2],SL[3]);
         end;
      end;
      SL.Free;
   end;
end;

end.
