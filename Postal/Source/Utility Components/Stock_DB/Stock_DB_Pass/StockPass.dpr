program StockPass;

uses
  Forms,
  ComServ2,
  StockFU in 'StockFU.pas' {StockForm},
  StockData in '..\StockData.pas' {StockDataModule: TDataModule},
  StockU in '..\StockU.pas',
  StockPassU in '..\StockPassU.pas';

{$R *.RES}

begin
  Application.Initialize;
  if ComServer.StartMode <> smStandAlone then
     Application.ShowMainForm:=False;
  Application.CreateForm(TStockDataModule, StockDataModule);
  Application.CreateForm(TStockForm, StockForm);
  Application.Run;
end.
