program Translator;

uses
  Forms,
  ComServ2,
  TranslatorFU in 'TranslatorFU.pas' {TransForm},
  TranslatorAU in 'TranslatorAU.pas',
  WideStringListU in '..\..\Packages\WideStringListU.pas';

{$R *.RES}

begin
  Application.Initialize;
  if ComServer.StartMode <> smStandAlone then
     Application.ShowMainForm:=False;
  Application.CreateForm(TTransForm, TransForm);
  Application.Run;
end.
