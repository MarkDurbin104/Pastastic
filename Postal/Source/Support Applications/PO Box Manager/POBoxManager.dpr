program POBoxManager;

uses
  ComServ2,
  SysUtils,
  Forms,
  POBoxManagerF in 'POBoxManagerF.pas' {POBoxManagerForm},
  POBoxManager_TLB in 'POBoxManager_TLB.pas',
  POBoxManagerAU in 'POBoxManagerAU.pas' {POBoxManagerAuto: CoClass},
  POBoxAU in 'POBoxAU.pas' {POBox: CoClass},
  SavePosFormU in '..\..\..\..\MyStuff\Common\SavePosFormU.pas',
  POBoxOfficeAU in 'POBoxOfficeAU.pas' {POBoxOffice: CoClass},
  GPCSGUID in '..\..\Base Type Library\GPCSGUID.pas',
  GPCSBase_TLB in '..\..\Base Type Library\GPCSBase_TLB.pas',
  POBoxCustomerAU in 'POBoxCustomerAU.pas' {POBoxCustomer: CoClass},
  GPCSErrorLine in '..\Error Handler\GPCSErrorLine.pas',
  POBoxOfficeF in 'POBoxOfficeF.pas' {POBoxOfficeForm},
  POBoxF in 'POBoxF.pas' {POBoxForm},
  POBoxCustomerF in 'POBoxCustomerF.pas' {POBoxCustomerForm},
  TableViewF in 'TableViewF.pas' {TableViewForm},
  MemoFieldViewF in 'MemoFieldViewF.pas' {MemoFieldViewForm},
  DatabaseUtils in 'DatabaseUtils.pas';

{$R *.TLB}

{$R *.RES}

begin
  try
    Application.Initialize;
    Application.Title := 'GPCS PO Box Manager';
    If ComServer.StartMode <> smStandAlone then
      Application.ShowMainForm := False;
    Application.CreateForm(TPOBoxManagerForm, POBoxManagerForm);
  Application.CreateForm(TTableViewForm, TableViewForm);
  Application.CreateForm(TMemoFieldViewForm, MemoFieldViewForm);
  Application.Run;
  except
    On E : Exception do
    begin
      RaiseException($1500,E);
    end;
  end;
end.
