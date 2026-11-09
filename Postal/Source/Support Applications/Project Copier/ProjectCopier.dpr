program ProjectCopier;

uses
  Forms,
  ProjectCopierFU in 'ProjectCopierFU.pas' {Form1},
  ErrorFormFU,
  ProjectFormFU;

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TErrorForm, ErrorForm);
  Application.CreateForm(TProjectsForm, ProjectsForm);
  Application.Run;
end.
