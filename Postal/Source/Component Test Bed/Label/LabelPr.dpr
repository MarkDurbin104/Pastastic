program LabelPr;

uses
  Forms,
  ComServ2,
  LabelPrAU in 'LabelPrAU.pas',
  LabelPrFU in 'LabelPrFU.pas' {Form1},
  SavePosFormU in '..\SavePosFormU.pas',
  GPCSBase_TLB in '..\..\Base Type Library\GPCSBase_TLB.pas',
  GPCSGUID in '..\..\Base Type Library\GPCSGUID.pas',
  GPCSBaseAU in '..\..\Base Type Library\GPCSBaseAU.pas',
  GPCSErrorCode in '..\..\Support Components\Error Handler\GPCSErrorCode.pas',
  GPCSErrorLine in '..\..\Support Components\Error Handler\GPCSErrorLine.pas';
                                        
{$R *.RES}

begin
   Application.Initialize;
   Application.ShowMainForm:=False;
   Application.CreateForm(TForm1, Form1);
   Application.Run;
end.
