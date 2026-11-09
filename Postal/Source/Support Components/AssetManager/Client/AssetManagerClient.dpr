program AccountManagerClient;

uses
  Forms,
  AccountManagerClientF in 'AccountManagerClientF.pas' {AccountManagerClientForm},
  AccountManager_TLB in '..\AccountManager_TLB.pas',
  SavePosFormU in '..\..\..\..\..\corvus\Source\Component Test Bed\SavePosFormU.pas',
  GridUtil in '..\..\..\COMMON\GridUtil.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TAccountManagerClientForm, AccountManagerClientForm);
  Application.Run;
end.
