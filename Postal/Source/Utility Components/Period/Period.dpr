program Period;

uses
  Forms,
  ComServ2,
  PeriodFU in 'PeriodFU.pas' {PeriodForm},
  PeriodAU in 'PeriodAU.pas';

{$R *.RES}

begin
  Application.Initialize;
  if ComServer.StartMode <> smStandAlone then
     Application.ShowMainForm:=False;
  Application.CreateForm(TPeriodForm, PeriodForm);
  Application.Run;
end.
