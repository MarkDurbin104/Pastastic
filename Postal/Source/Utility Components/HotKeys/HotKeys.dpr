program HotKeys;

uses
  Forms,
  ComServ2,
  HotKeysAU in 'HotKeysAU.pas';

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
