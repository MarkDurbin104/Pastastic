program bprint;

uses
  Forms,
  bselect in 'bselect.pas' {Form1},
  breport in 'breport.pas' {Form2},
  PError in 'PError.pas' {ErrorForm},
  RCountry in 'RCountry.pas' {ByCountry},
  RDate in 'RDate.pas' {ByDate},
  RVol in 'RVol.pas' {ByVol},
  psfu in 'psfu.pas' {Form3};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TErrorForm, ErrorForm);
  Application.CreateForm(TByCountry, ByCountry);
  Application.CreateForm(TByDate, ByDate);
  Application.CreateForm(TByVol, ByVol);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
 