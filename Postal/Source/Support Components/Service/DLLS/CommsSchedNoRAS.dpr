library CommsSchedNoRAS;

uses
  Windows,
  Forms,ActiveX,
  MesQueueU;
  
var
  CommsLink:TCommsLink;

procedure StartUp;
begin
   try
     CoInitialize(nil);
   except
   end;
   CommsLink:=TCommsLink.Create;
   Windows.Beep(1000,100);
   Windows.Beep(2000,50);
end;
procedure ShutDown;
begin
   CommsLink.Free;
   CommsLink:=nil;
   Windows.Beep(2000,100);
   Windows.Beep(1000,50);
   CoUnInitialize;
end;
procedure Timer;
begin
   Application.ProcessMessages;
end;

exports
   StartUp,Timer,ShutDown;
   
begin
end.
