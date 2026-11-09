program MSGSViewer;

uses
  Forms,
  MSGSViewerFU in 'MSGSViewerFU.pas' {MSVForm},
  MsgFileMaintU in '..\..\Packages\MsgFileMaintU.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMSVForm, MSVForm);
  Application.Run;
end.
