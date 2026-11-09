program UDPShirikaQ;

uses
  Forms,
  UDPShirikaQFU in 'UDPShirikaQFU.pas' {Form1},
  ShirikaU in '..\..\Packages\ShirikaU.pas',
  UDPSocketU in '..\..\Packages\UDPSocketU.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
