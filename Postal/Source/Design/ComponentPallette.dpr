program ComponentPallette;

uses
  Forms,
  ComponentPalletteFU in 'ComponentPalletteFU.pas' {Form1},
  ParseNode in 'IDSParse\ParseNode.pas',
  DesignNodeBase in 'DesignNode\DesignNodeBase.pas',
  DrawNodeU in 'DrawNodeU.pas',
  ParseErrorFU in 'IDSParse\ParseErrorFU.pas' {ParseError};

{$R *.RES}
  
begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TParseError, ParseError);
  HintWindowClass:=TDrawNodeHint;
  Application.Run;
end.
