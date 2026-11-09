program GroupDes;

uses
  Forms,
  GroupDesFU in 'GroupDesFU.pas' {Form1},
  ParseNode in '..\IDSParse\ParseNode.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
