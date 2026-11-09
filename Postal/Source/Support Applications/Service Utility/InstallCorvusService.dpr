program InstallCorvusService;

uses
  SysUtils,
  WinExecU;

{$R *.RES}
var
   S:String;
begin
  if FileExists('C:\CorvusService\CorvusService.exe') then
     WinExecAndWait('C:\CorvusService\CorvusService /I',S,False);
end.
