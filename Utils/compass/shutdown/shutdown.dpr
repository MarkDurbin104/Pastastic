program Shutdown;

uses
  Forms,
  Shutform in 'SHUTFORM.PAS' {Form1},
  Countdn in 'COUNTDN.PAS' {CountForm};

{$R *.RES}

begin
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TCountForm, CountForm);
  Application.Run;
end.
 