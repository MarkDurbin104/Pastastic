program WebBrows;

uses
  Forms,
  main in 'main.pas' {Form1},
  DocSrc in 'DocSrc.pas' {DocSourceFrm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TDocSourceFrm, DocSourceFrm);
  Application.Run;
end.
