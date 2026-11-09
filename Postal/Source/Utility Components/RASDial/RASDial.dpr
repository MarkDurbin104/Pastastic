program RASDial;

uses
  Forms,
  DialFU in 'DialFU.pas' {FormDial},
  RASDialU in 'RASDialU.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormDial, FormDial);
  Application.Run;
end.
