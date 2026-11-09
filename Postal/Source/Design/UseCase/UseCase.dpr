program UseCase;

uses
  Forms,
  UseCaseFU in 'UseCaseFU.pas' {UCSDForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TUCSDForm, UCSDForm);
  Application.Run;
end.
