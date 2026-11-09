program Stock;

uses
  Controls,
  Windows,
  GPCSGUID,
  GPCSErrorLine,
  Forms,
  ComServ2,
  StringUtil,
  SysUtils,SharedStockU,
  StockFU in 'StockFU.pas' {StockForm},
  StockAU in 'StockAU.pas',
  StockMutexF in 'StockMutexF.pas' {StockMutexForm};

{$R *.RES}

begin
   Application.Initialize;
   if ComServer.StartMode <> smStandAlone then
      Application.ShowMainForm:=False;
   Application.CreateForm(TStockForm, StockForm);

   If FindParamIndex('Update') <> -1 then  //update CSV file supplied
   begin
      try
         UpdateFromCSV(ParamStr(FindParamIndex('Update')+1),StockForm.SiteStock);  //filename in next param
      except
      end;
      StockForm.Close;
   end;

   Application.Run;
end.
