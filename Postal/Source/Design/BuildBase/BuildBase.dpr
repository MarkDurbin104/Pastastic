program BuildBase;

uses
  Forms,
  BuildBaseFU in 'BuildBaseFU.pas' {BaseBuild},
  SourceFormFU in '..\IDSParse\SourceFormFU.pas' {SourceForm},
  IDSParseFU in '..\IDSParse\IDSParseFU.pas' {MainForm},
  WaitF in '..\IDSParse\WaitF.pas' {WaitForm},
  ParseNode in '..\IDSParse\ParseNode.pas',
  ProjectElements in '..\IDSParse\ProjectElements.pas',
  DrawNodeU in '..\DrawNodeU.pas',
  DomainsFU in '..\IDSParse\DomainsFU.pas' {DomainsForm},
  BuilderFU in '..\IDSParse\BuilderFU.pas' {Builder},
  TokenParser in '..\..\Component Designer\Product Designer\TokenParser.pas',
  ProdGenU in '..\..\Component Designer\Product Designer\ProdGenU.pas',
  CompListFormFU in '..\IDSParse\CompListFormFU.pas' {CompListForm},
  LookTestFU in '..\IDSParse\LookTestFU.pas' {LookTest};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TBaseBuild, BaseBuild);
  Application.CreateForm(TSourceForm, SourceForm);
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TWaitForm, WaitForm);
  Application.CreateForm(TDomainsForm, DomainsForm);
  Application.CreateForm(TBuilder, Builder);
  Application.CreateForm(TCompListForm, CompListForm);
  Application.CreateForm(TLookTest, LookTest);
  Application.Run;
end.
