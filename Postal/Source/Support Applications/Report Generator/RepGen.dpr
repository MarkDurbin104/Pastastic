program RepGen;

uses
  Forms,
  ErrorFormFU,
  ProjectFormFU,
  RepGenFU in 'RepGenFU.pas' {Form1},
  ReportIDSU in '..\..\Packages\ReportIDSU.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TErrorForm, ErrorForm);
  Application.CreateForm(TProjectsForm, ProjectsForm);
  Application.Run;
end.
