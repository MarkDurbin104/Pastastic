{$define BuildingDLL=1}
{$define NoRAS=1}

{$ifdef BuildingDLL}
library MsgStoreNoRAS;
{$else}
program MsgStore;
{$endif}

uses
  Windows,Forms,FileTxStatusU,
  MsgStoreFU in 'MsgStoreFU.pas' {MainForm};
  
{$R *.RES}

{$ifdef BuildingDLL}
procedure StartUp;
begin
   Beep(1000,100);
   Beep(2000,100);
   MainForm:=TMainForm.Create(nil);
   CheckForOldDLLName;
end;
procedure ShutDown;
begin
   Beep(2000,100);
   Beep(1000,100);
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
{$else}
begin
  Application.Initialize;
  Application.ShowMainForm:=False;
  Application.CreateForm(TMainForm, MainForm);
  MainForm.FileTxStatus.RunningAsService:=False;
  CheckForOldDLLName;
  Application.Run;
end.
{$endif}
