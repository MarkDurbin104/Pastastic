program TableViewer;

uses
  Forms,
  TableViewerF in 'TableViewerF.pas' {TableViewerForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TTableViewerForm, TableViewerForm);
  Application.Run;
end.
