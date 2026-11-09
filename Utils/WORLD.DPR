program World;

uses
  Forms,
  Unit1 in 'DELCONV\UNIT1.PAS' {Form1},
  Unit2 in 'DELCONV\UNIT2.PAS' {Form2};

{$R *.RES}

begin
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
 