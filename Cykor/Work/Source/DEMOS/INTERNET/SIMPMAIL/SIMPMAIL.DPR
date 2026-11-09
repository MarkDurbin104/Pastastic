program simpmail;

uses
  Forms,
  Main in 'MAIN.PAS' {MainForm};

{$R *.RES}

begin
  Application.Title := 'SimpleMail';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
