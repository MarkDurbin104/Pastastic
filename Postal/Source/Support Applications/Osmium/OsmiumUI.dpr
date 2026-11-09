program OsmiumUI;

uses
  Forms,
  MOSupportU,
  UIMainFormFU {I3UIForm},
  TestParseU;

{$R *.RES}

begin
  Application.Initialize;
  SystemType:='Osmium';
  Application.CreateForm(TI3UIForm, I3UIForm);
  Application.Run;
end.
