program CorvusService;

{$APPTYPE CONSOLE}

uses
   Windows,
   NTService in 'NTService.pas',
   CorvusServiceU in 'CorvusServiceU.pas',
   afpEventLog;

{$R CorvusService.RES}

begin
   StartUpService('CorvusService','Corvus Service');
end.

