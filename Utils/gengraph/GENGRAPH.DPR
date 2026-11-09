program Gengraph;

uses
  Forms,
  About in 'ABOUT.PAS' {AboutBox},
  Btmanu in 'BTMANU.PAS' {WaitForm},
  Mainform in 'MAINFORM.PAS' {GGForm};

{$R *.RES}

begin
  Application.Title := 'Generated Graphics Prototype';
  Application.CreateForm(TGGForm, GGForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TWaitForm, WaitForm);
  Application.Run;
end.
 