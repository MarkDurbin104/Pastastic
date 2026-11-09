program MyUserManager;

uses
  Forms,
  lmaccess in 'lmaccess.pas',
  lmserver in 'lmserver.pas',
  unitNTException in 'unitNTException.pas',
  lmglobal in 'lmglobal.pas',
  MyUserManagerAU in 'MyUserManagerAU.pas',
  Lmcons in 'lmcons.pas',
  MyUserManagerFU in 'MyUserManagerFU.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
