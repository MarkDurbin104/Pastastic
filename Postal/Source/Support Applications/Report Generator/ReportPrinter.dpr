program ReportPrinter;

uses
  Forms,
  ReportPrinterFU in 'ReportPrinterFU.pas' {Form1},
  ErrorFormFU in '..\..\Packages\ErrorFormFU.pas' {ErrorForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TErrorForm, ErrorForm);
  Application.Run;
end.
