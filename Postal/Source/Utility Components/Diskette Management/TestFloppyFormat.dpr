program TestFloppyFormat;

uses
  Forms,
  TestFloppyFormatFU in 'TestFloppyFormatFU.pas' {Form1},
  ExFlpFmt in 'ExFlpFmt.pas',
  CpyFile in 'CpyFile.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
