program Transparent;

uses
  Forms,
  TransparentFU in 'TransparentFU.pas' {BGForm},
  TransparentMainFU in 'TransparentMainFU.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TBGForm, BGForm);
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
