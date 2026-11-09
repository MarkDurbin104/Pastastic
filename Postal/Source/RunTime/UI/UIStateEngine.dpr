program UIStateEngine;

uses
  Forms,ComServ2,UIInterfaceU,
  UITypesFU in 'UITypesFU.pas' {Form1},
  ListBaseU in 'ListBaseU.pas',
  UIStatesU in 'UIStatesU.pas',
  UIClientSinkU in 'UIClientSinkU.pas',
  UIStateAU in 'UIStateAU.pas';

{$R *.RES}

begin
  CreateInterfaceFactories;
  Application.Initialize;
  if ComServer.StartMode <> smStandAlone then
     Application.ShowMainForm:=False;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
