program UserManager;

uses
  ComServ,
  Forms,
  LmAccess in 'LmAccess.pas',
  Lmcons in 'lmcons.pas',
  lmglobal in 'lmglobal.pas',
  UserManagerAU in 'UserManagerAU.pas',
  UserManagerFU in 'UserManagerFU.pas' {UserForm},
  UserManager_TLB in 'UserManager_TLB.pas';

{$R *.TLB}

{$R *.RES}

begin


  Application.Initialize;
  If ComServer.StartMode <> smStandAlone then
    Application.ShowMainForm := False;
  Application.CreateForm(TUserForm, UserForm);
  Application.Run;
end.
