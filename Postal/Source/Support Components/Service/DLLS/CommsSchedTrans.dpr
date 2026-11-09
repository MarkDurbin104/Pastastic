library CommsSchedTrans;

uses
  Windows,Classes,ActiveX,Forms,SysUtils,
  GPCSErrorLine,MesQueueU,SchedulerU,TranProcessU;
  
var
  Schedule:TScheduler;
  CommsLink:TCommsLink;
  TxnProcessor:TTxnProcessor;

procedure StartUp;
var
   SL:TStringList;
begin
   try
     CoInitialize(nil);
   except
   end;
   CommsLink:=TCommsLink.Create;
   Schedule:=TScheduler.Create('C:\Schedule.dat');
   Schedule.CommsLink:=CommsLink;
   SL:=TStringList.Create;
   SL.SaveToFile('C:\TrInUse.lck');
//   RaiseGUIDError('Service','Take Control');
   SL.Free;
   TxnProcessor:=TTxnProcessor.Create;
   Windows.Beep(1000,100);
   Windows.Beep(2000,50);
end;
procedure ShutDown;
begin
   if TxnProcessor <> nil then
      TxnProcessor.Free;
   DeleteFile('C:\TrInUse.lck');
//   RaiseGUIDError('Service','Release Control');
   Schedule.CommsLink:=nil;      
   CommsLink.Free;
   CommsLink:=nil;
   Schedule.Free;
   Schedule:=nil;
   Windows.Beep(2000,100);
   Windows.Beep(1000,50);
   CoUnInitialize;
end;
procedure Timer;
const 
   LastTick:TDateTime = 0;
   TimeOut:Integer    = 0;
var
   SL:TStringList;
begin 
   Application.ProcessMessages;
   if ((Now-LastTick) >= Interval1Second) then
   begin
      if Schedule <> nil then
         Schedule.Check;
      
      LastTick:=Now;
      if TxnProcessor <> nil then
         TxnProcessor.CheckTxns(nil);
      if FileExists('C:\TrReqst.lck') then
      begin
//         RaiseGUIDError('Service','Release Control');
         TxnProcessor.Free;
         TxnProcessor:=nil;
         DeleteFile('C:\WatchDog.lck');
         DeleteFile('C:\TrInUse.lck');
      end;
      if FileExists('C:\TrHeld.lck') then
      begin
         if TimeOut = 0 then
         begin
            SL:=TStringList.Create;
            SL.SaveToFile('C:\WatchDog.lck');
            SL.Free;
         end;
      end;
      if FileExists('C:\WatchDog.lck') then
      begin
        if (TimeOut < 10) then
        begin
           TimeOut:=TimeOut+1;
        end
        else                  
        begin
//            RaiseGUIDError('Service','Regain Control');
            SL:=TStringList.Create;
            SL.SaveToFile('C:\TrInUse.lck');
            DeleteFile('C:\WatchDog.lck');
            DeleteFile('C:\TrHeld.lck');
            SL.Free;      
            TxnProcessor:=TTxnProcessor.Create;
        end;
      end
      else
         TimeOut:=0;
//      if TxnProcessor <> nil then
//         Windows.Beep(4000,10)
//      else
      if TxnProcessor = nil then
         Windows.Beep(2000,10); 
   end;
end;

exports
   StartUp,Timer,ShutDown;
   
begin
end.
