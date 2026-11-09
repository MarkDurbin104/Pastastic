program Project1;

uses
  Forms,
  Unit1 in 'UNIT1.PAS' {Form1},
  Unit2 in '\SRC\DELCONV\UNIT2.PAS' {KeyForm};

{$R *.RES}

begin
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TKeyForm, KeyForm);
  Application.Run;
end.
 