unit StockAU;

interface

uses
  Windows,Graphics,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Registry,Dialogs,DatabaseServer_TLB,DBTables,StockU;
  
type
  TStock = class(TGPCSStock)
  private
  public
     procedure Initialize; override;
     destructor Destroy; override;
  protected
    function ListAllStock(const Owner, StockGroup: WideString): WideString; override;
    function ListAvailableStock(const Owner, StockGroup: WideString): WideString; override;
    function ListPendingTransfersFrom(const Owner: WideString): WideString; override;
    function ListPendingTransfersTo(const Owner: WideString): WideString; override;
    function ListTransferStock(const FromOwner,ToOwner: WideString): WideString; override;
    function QueryStockLevel(const Owner, StockItemName: WideString): Integer; override;
    procedure ClearTempAdjustments(const Owner:WideString); override;
    procedure AdjustStockLevel(const Owner, StockItemName: WideString; Quantity: Integer); override;
    procedure ChangeStockTransfer(const FromOwner, ToOwner, StockItemName: WideString; Quantity: Integer); override;
    procedure CreateNewStockUnit(const Owner, StockUnitType: WideString); override;
    procedure DeleteStockUnit(const Owner, StockUnitType: WideString); override;
    procedure SetStockLevel(const Owner, StockItemName: WideString; Quantity: Integer); override;
    procedure SetupStockTransfer(const FromOwner, ToOwner, StockItemName: WideString; Quantity: Integer); override;
    procedure TransferStock(const FromOwner, ToOwner: WideString); override;
    procedure DeleteStockItem(const Description: WideString); override;
    procedure AddNewStockItem(const Description:WideString;Value:Currency;const Group:WideString;PLU:Integer;const AccountLine,AcctType,Report,ProgID,SUTypes:WideString); override;
    function  GetStockItemDetails(const Description:WideString):WideString; override;
  end;                  
  
implementation

uses
   ComServ2,StockFU;
   
{TStock}       
procedure TStock.Initialize;
begin
   inherited Initialize;
end;
destructor TStock.Destroy;
begin
   inherited Destroy;
end;
function TStock.ListAllStock(const Owner, StockGroup: WideString): WideString;
begin
   StockForm.SiteStock.EmptySetUp(Owner);
   Result:=StockForm.SiteStock.StockUnits.ListAll(Owner,StockGroup);
   if Result = '' then
      Result:=StockForm.SiteStock.StockUnitTypes.ListAll('Declare',StockGroup)
end;
function TStock.ListAvailableStock(const Owner, StockGroup: WideString): WideString;
begin
   StockForm.SiteStock.EmptySetUp(Owner);
   Result:=StockForm.SiteStock.StockUnits.ListAvailable(Owner,StockGroup);
end;
function TStock.ListPendingTransfersFrom(const Owner: WideString): WideString;
begin
   StockForm.SiteStock.EmptySetUp(Owner);
   Result:=StockForm.SiteStock.ListTransfersFrom(Owner);
end;
function TStock.ListPendingTransfersTo(const Owner: WideString): WideString;
begin
   StockForm.SiteStock.EmptySetUp(Owner);
   Result:=StockForm.SiteStock.ListTransfersTo(Owner);
end;
function TStock.ListTransferStock(const FromOwner,ToOwner: WideString): WideString;
begin
   StockForm.SiteStock.EmptySetUp(FromOwner);
   Result:=StockForm.SiteStock.ListTransferStock(FromOwner,ToOwner);
end;
function TStock.GetStockItemDetails(const Description:WideString):WideString;
begin
   Result:=StockForm.SiteStock.GetStockItemDetails(Description);
end;
procedure TStock.DeleteStockItem(const Description: WideString);
begin
   StockForm.SiteStock.DeleteStockItemByName(Description);
end;
procedure TStock.AddNewStockItem(const Description:WideString;Value:Currency;const Group:WideString;PLU:Integer;const AccountLine,AcctType,Report,ProgID,SUTypes:WideString);
begin
   StockForm.SiteStock.AddNewStockItem(Description,Value,Group,PLU,AccountLine,AcctType,Report,ProgID,SUTypes);
end;
function TStock.QueryStockLevel(const Owner, StockItemName: WideString): Integer;
begin
   StockForm.SiteStock.EmptySetUp(Owner);
   Result:=StockForm.SiteStock.GetStockLevel(Owner,StockItemName);
end;
procedure TStock.ClearTempAdjustments(const Owner:WideString);
begin
   StockForm.SiteStock.ClearTempAdjustments(Owner);
end;                       
procedure TStock.AdjustStockLevel(const Owner, StockItemName: WideString; Quantity: Integer);
begin
   StockForm.SiteStock.EmptySetUp(Owner);
   StockForm.SiteStock.AdjustStockLevel(Owner,StockItemName,Quantity);
end;                       
procedure TStock.ChangeStockTransfer(const FromOwner, ToOwner, StockItemName: WideString; Quantity: Integer);
begin
   StockForm.SiteStock.EmptySetUp(FromOwner);
   StockForm.SiteStock.ChangeStockTransfer(FromOwner,ToOwner,StockItemName,Quantity);
end;
procedure TStock.CreateNewStockUnit(const Owner, StockUnitType: WideString);
begin
   StockForm.SiteStock.EmptySetUp(Owner);
   StockForm.SiteStock.CreateNewStockUnit(Owner,StockUnitType);
end;
procedure TStock.DeleteStockUnit(const Owner, StockUnitType: WideString);
begin
   StockForm.SiteStock.EmptySetUp(Owner);
   StockForm.SiteStock.DeleteStockUnit(Owner);
end;
procedure TStock.SetStockLevel(const Owner, StockItemName: WideString; Quantity: Integer);
begin
   StockForm.SiteStock.EmptySetUp(Owner);
   StockForm.SiteStock.SetStockLevel(Owner,StockItemName,Quantity);
end;                           
procedure TStock.SetupStockTransfer(const FromOwner, ToOwner, StockItemName: WideString; Quantity: Integer);
begin
   StockForm.SiteStock.EmptySetUp(FromOwner);
   StockForm.SiteStock.SetupStockTransfer(FromOwner,ToOwner,StockItemName,Quantity);
end;                        
procedure TStock.TransferStock(const FromOwner, ToOwner: WideString);
begin
   StockForm.SiteStock.EmptySetUp(FromOwner);
   StockForm.SiteStock.TransferStock(FromOwner,ToOwner);
end;                   

initialization
  TGPCSCompFactory.Create(ComServer,TStock,Class_Stock,
                          'Support.Stock','GPCS Stock',
                          ciMultiInstance);
end.