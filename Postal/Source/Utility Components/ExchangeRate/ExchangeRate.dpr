program ExchangeRate;

uses
  Forms,
  ComServ2,
  ExchangeRateAU in 'ExchangeRateAU.pas';

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
