program Twain;

uses
  Forms,
  TwainF in 'TwainF.pas' {TwainForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TTwainForm, TwainForm);
  Application.Run;
end.
