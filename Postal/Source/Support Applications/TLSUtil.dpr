program TLSUtil;

uses
  Forms,
  TLSUtilF in 'TLSUtilF.pas' {TLSUtilForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TTLSUtilForm, TLSUtilForm);
  Application.Run;
end.
