program trans;

uses
  Forms,
  main in 'main.pas' {MainForm},
  Fileacc in 'Fileacc.pas' {Save},
  AbtForm in '\SRC\images\AbtForm.pas' {About},
  ModifChk in 'ModifChk.pas' {SaveCheck},
  resload in 'resload.pas' {LoadLine},
  wait1 in 'wait1.pas' {WaitForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'IPS ''96 translation Utility';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSave, Save);
  Application.CreateForm(TAbout, About);
  Application.CreateForm(TSaveCheck, SaveCheck);
  Application.CreateForm(TLoadLine, LoadLine);
  Application.CreateForm(TWaitForm, WaitForm);
  Application.Run;
end.
 