program ZLIBFile;

uses
  Forms,
  ZLIBFileFU in 'ZLIBFileFU.pas' {Form1},
  Compress in 'Compress.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
