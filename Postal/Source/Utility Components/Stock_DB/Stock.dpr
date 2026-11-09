program Stock;

uses
  Forms,
  ComServ2,
  StockFU in 'StockFU.pas' {StockForm},
  StockAU in 'StockAU.pas',
  StockData in 'StockData.pas' {StockDataModule: TDataModule};

{$R *.RES}

begin
  Application.Initialize;
  if ComServer.StartMode <> smStandAlone then
     Application.ShowMainForm:=False;
  Application.CreateForm(TStockDataModule, StockDataModule);
  Application.CreateForm(TStockForm, StockForm);
  Application.Run;
end.
