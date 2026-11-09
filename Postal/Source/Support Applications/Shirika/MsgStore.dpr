library MsgStore;

uses
  Windows,
  Forms,
  FileTxStatusU,
  GPCSGUID,
  MsgStoreFU in 'MsgStoreFU.pas' {MainForm};
  
procedure StartUp;
begin
   if GetPSLRegString('CorvusService','Start Silently','0') = '0' then
   begin
      Beep(1000,100);
      Beep(2000,100);
   end;
   MainForm:=TMainForm.Create(nil);
   MainForm.Visible:=False;
   CheckForOldDLLName;
   MainForm.Enable;
end;          
procedure ShutDown;
begin
   MainForm.Disable;
   if GetPSLRegString('CorvusService','Start Silently','0') = '0' then
   begin
      Beep(2000,100);
      Beep(1000,100);
   end;
   MainForm.Free;
end;
procedure Timer;
begin
   Application.ProcessMessages;
end;

exports
   StartUp,Timer,ShutDown;

begin
end.

