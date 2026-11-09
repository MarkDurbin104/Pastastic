program IDSParse;
uses
  Forms,
  IDSParseFU in 'IDSParseFU.pas' {MainForm},
  ProjectElements in 'ProjectElements.pas',
  ParseNode in 'ParseNode.pas',
  DomainsFU in 'DomainsFU.pas' {DomainsForm},
  BuilderFU in 'BuilderFU.pas' {Builder},
  SourceFormFU in 'SourceFormFU.pas' {SourceForm},
  CompListFormFU in 'CompListFormFU.pas' {CompListForm},
  WaitF in 'WaitF.pas' {WaitForm},
  LookTestFU in 'LookTestFU.pas' {LookTest},
  TokenParser in '..\..\Component Designer\Product Designer\TokenParser.pas',
  ProdGenU in '..\..\Component Designer\Product Designer\ProdGenU.pas',
  ParseErrorFU in 'ParseErrorFU.pas' {ParseError},
  DrawNodeU in '..\DrawNodeU.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDomainsForm, DomainsForm);
  Application.CreateForm(TBuilder, Builder);
  Application.CreateForm(TSourceForm, SourceForm);
  Application.CreateForm(TCompListForm, CompListForm);
  Application.CreateForm(TWaitForm, WaitForm);
  Application.CreateForm(TLookTest, LookTest);
  Application.CreateForm(TParseError, ParseError);
  Application.Run;
end.
