program Shut;

uses
  Forms,
  Lastscr in 'LASTSCR.PAS' {LastForm},
  Shutform in 'SHUTFORM.PAS' {Form1};

{$R *.RES}

begin
  Application.Title := 'End Of Day Monitor Program';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TLastForm, LastForm);
  Application.Run;
end.
 