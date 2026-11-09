program RegDocGen;

uses
  Forms,
  RegDocGenFU in 'RegDocGenFU.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
