program HookUp;

uses
  Forms,
  ComServ2,
  HookUpAU in 'HookUpAU.pas',
  HookUpFU in 'HookUpFU.pas' {HookForm};

{$R *.RES}

begin
  Application.Initialize;
  if ComServer.StartMode <> smStandalone then
     Application.ShowMainForm:=False;
  Application.CreateForm(THookForm, HookForm);
  Application.Run;
//  if ComServer.StartMode <> smStandalone then
//  begin
//     repeat
//        Application.HandleMessage
//     until Application.Terminated;
//  end;
end.
