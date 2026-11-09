program Docu_c;

uses
  Forms,
  Interp in 'INTERP.PAS' {Form1},
  Print in 'PRINT.PAS' {Form2};

{$R *.RES}

begin
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
 