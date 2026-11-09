program TDX;

uses
  Forms,
  TDXFU in 'TDXFU.pas' {Form1},
  ProjectFormFU {ProjectsForm},
  ErrorFormFU {ErrorForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TErrorForm, ErrorForm);
  Application.CreateForm(TProjectsForm, ProjectsForm);
  Application.Run;
end.
