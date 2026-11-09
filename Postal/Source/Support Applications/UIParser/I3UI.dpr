program I3UI;

uses
  Forms,
  MOSupportU,
  UIMainFormFU;

{$R *.RES}

begin
  Application.Initialize;
  SystemType:='Indigo3';
  Application.CreateForm(TI3UIForm, I3UIForm);
  Application.Run;
end.
