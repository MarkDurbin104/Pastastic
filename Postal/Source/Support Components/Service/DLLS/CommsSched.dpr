library CommsSched;

uses
  Windows,Classes,ActiveX,Forms,SysUtils,
  GPCSErrorLine,MesQueueU,SchedulerU;
  
var
  Schedule:TScheduler;
  CommsLink:TCommsLink;

procedure StartUp;
begin
   try
     CoInitialize(nil);
   except
   end;
   CommsLink:=TCommsLink.Create;
   Schedule:=TScheduler.Create('C:\Schedule.dat');
   Schedule.CommsLink:=CommsLink;
   Windows.Beep(1000,100);
   Windows.Beep(2000,50);
end;
procedure ShutDown;
begin
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
begin 
   Application.ProcessMessages;
   if ((Now-LastTick) >= Interval1Second) then
   begin
      if Schedule <> nil then
         Schedule.Check;
      LastTick:=Now;
   end;
end;

exports
   StartUp,Timer,ShutDown;
   
begin
end.
