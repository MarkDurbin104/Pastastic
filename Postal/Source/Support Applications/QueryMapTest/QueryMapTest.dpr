program QueryMapTest;

uses
  Forms,
  QueryMapTestF in 'QueryMapTestF.pas' {QueryMapTestForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TQueryMapTestForm, QueryMapTestForm);
  Application.Run;
end.
