program ReStartService;

uses
  Windows,SysUtils,
  GPCSGUID,WinExecU,GPCSErrorLine,TaskKillerU,ServiceControlU;

var
   S:String;
   TimeOut:Integer;
begin
  CtrlService(ctStop);
  Sleep(500);
  if FileExists('C:\CorvusService\CorvusService.exe') then
  begin
     if GetProcessIDOfCorvusService <> 0 then
     begin
//        WinExecAndWait('C:\CorvusService\CorvusService.exe /E',S,False);
//        TimeOut:=0;
//        while (GetProcessIDOfCorvusService <> 0) and (TimeOut < 2) do
//        begin
//           Windows.Beep(1000,100);
//           Sleep(1000);
//           Inc(TimeOut);
//        end;
//        if TimeOut >= 2 then // no response in 5 seconds! - Kill it!
//        begin
           TimeOut:=0;
           while (GetProcessIDOfCorvusService <> 0) and (TimeOut < 30) do
           begin
              TerminateCorvusServiceProcess; // kill, kill, kill ... - I love my work.
//              Windows.Beep(1200+(TimeOut*10),500);
              Sleep(500);
              Inc(TimeOut);
           end;
//        end;
        try
           S:=GPCSGUID.GetPSLRegString('CorvusService','DLLName','');
           if FileExists(S+'.Rep') then
           begin
              DeleteFile(PChar(S));
              RenameFile(PChar(S+'.Rep'),PChar(S));
           end;
        except
           on E:Exception do RaiseGUIDException('{D2F2EEEE-29CF-4C68-B3DF-88067E9CEDCE}',E);
        end;
     end;
     try
        S:='C:\CorvusService\CorvusService.exe';
        if FileExists(S+'.Rep') then
        begin
           DeleteFile(PChar(S));
           RenameFile(PChar(S+'.Rep'),PChar(S));
        end;
     except
        on E:Exception do GPCSErrorLine.RaiseGUIDException('{0D959EBA-E12A-4D10-AD42-C16A54DF1DA3}',E);
     end;
     TimeOut:=0;
     Sleep(1000);
     WinExecAndWait('C:\CorvusService\CorvusService.exe /B',S,False);
     // wait upto 30 seconds for Startup
     while (GetProcessIDOfCorvusService = 0) and (TimeOut < 30) do
     begin
        Windows.Beep(2000,100);
        Sleep(900);
        Inc(TimeOut);
     end;
  end;
end.
