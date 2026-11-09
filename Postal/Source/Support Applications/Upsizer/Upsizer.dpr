program Upsizer;

uses
  Forms,
  UpsizerF in 'UpsizerF.pas' {UpsizerForm},
  DBCreateU in 'DBCreateU.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TUpsizerForm, UpsizerForm);
  Application.Run;
end.
