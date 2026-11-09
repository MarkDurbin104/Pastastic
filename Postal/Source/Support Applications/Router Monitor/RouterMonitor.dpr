program RouterMonitor;

uses
  Forms,
  RouterMonitorF in 'RouterMonitorF.pas' {RouterMonitorForm},
  SavePosFormU in '..\..\Common\SavePosFormU.pas',
  DateTimeUtil in '..\..\Common\DateTimeUtil.pas',
  SavePosTrayFormU in '..\..\Common\SavePosTrayFormU.pas',
  Masks in 'D:\borland\Delphi3\Source\Extras\Masks.pas',
  StringUtil in '..\..\Common\StringUtil.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Router Monitor';
  Application.CreateForm(TRouterMonitorForm, RouterMonitorForm);
  Application.Run;
end.
