{  Module          Manager NETAPI32
   Unit            Project
   Copyright(c)    Postal Solutions Limited 1998..1998
   Author          DDB
   Description     Create easy access to NETAPI32.DLL .
                              Original Release
}
program UManager;

uses
  ComServ2,
  Forms,
  SysUtils,
  FrmMan in 'FrmMan.pas' {ServerForm},
  FrNew in 'FrNew.pas' {NewForm},
  FrProper in 'FrProper.pas' {PropertyForm},
  FrGroup in 'FrGroup.pas' {GroupsForm},
  Umanager_TLB in 'Umanager_TLB.pas',
  NetUserAU in 'NetUserAU.pas' {NetUser: CoClass},
  NetManagerAU in 'NetManagerAU.pas' {NetManager: CoClass},
  GPCSBase_TLB,
  GPCSErrorCode,
  GPCSErrorLine,
  GPCSGUID;

{$R *.TLB}

{$R *.RES}
type

  // This is to stops the errors from the TUserMan
  TErrClass=Class
     procedure ExceptionEvent(Sender:TObject;E:Exception);
  end ;
var
  ErrorClass : TErrClass ;


  procedure TErrClass.ExceptionEvent(Sender:TObject;E:Exception);

  begin
     GlobalExceptionEvent(Sender,E);
  end ;


begin

  Application.Initialize;
  ErrorClass := TErrClass.Create ;

  Application.OnException:=ErrorClass.ExceptionEvent ;

  If ComServer.StartMode <> smStandAlone then
    Application.ShowMainForm := False;

  Application.CreateForm(TServerForm, ServerForm);
  Application.Run;
  ErrorClass.Free ;
end.
