program Accounts;

uses
  Forms,
  ComServ2,
  AccountsAU in 'AccountsAU.pas',
  NewAccountsFU in 'NewAccountsFU.pas' {AccountsForm},
  CommatextFU in 'CommatextFU.pas' {Form2};

{$R *.RES}

begin
  Application.Initialize;
  if ComServer.StartMode <> smStandalone then
     Application.ShowMainForm:=False;
  Application.CreateForm(TAccountsForm, AccountsForm);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.                     
