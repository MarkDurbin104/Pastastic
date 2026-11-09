program Counters;

uses
  Forms,ComServ2,
  CountersAU in 'CountersAU.pas';

{$R *.RES}

begin
  Application.Initialize;
//  if ComServer.StartMode <> smStandalone then
  begin
     repeat
        Application.HandleMessage
     until Application.Terminated;
  end;
end.

