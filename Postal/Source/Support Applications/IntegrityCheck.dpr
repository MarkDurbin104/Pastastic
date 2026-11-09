program IntegrityCheck;

uses
  Forms,
  ProjectFormFU,
  ErrorFormFU,
  IntegrityCheckFU in 'IntegrityCheckFU.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TErrorForm, ErrorForm);
  Application.CreateForm(TProjectsForm, ProjectsForm);
  Application.Run;
end.
