unit StockAU;

interface
{$define USING_SERVICE}
uses
  Windows,Graphics,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Registry,Dialogs,DatabaseServer_TLB,DBTables,
{$ifndef USING_SERVICE }
  SharedStockU,
{$endif} //ndef USING_SERVICE 
  PackStrListU;
  
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
   ComServ2,StockFU,FileTxStatusU;

{TStock}
procedure TStock.Initialize;
begin
   inherited Initialize;
end;
destructor TStock.Destroy;
begin
   inherited Destroy;
end;
function TStock.ListPendingTransfersFrom(const Owner: WideString): WideString;
begin
end;
function TStock.ListPendingTransfersTo(const Owner: WideString): WideString;
begin
end;
function TStock.ListTransferStock(const FromOwner,ToOwner: WideString): WideString;
begin
end;
procedure TStock.ChangeStockTransfer(const FromOwner, ToOwner, StockItemName: WideString; Quantity: Integer);
begin
end;
procedure TStock.SetupStockTransfer(const FromOwner, ToOwner, StockItemName: WideString; Quantity: Integer);
begin
end;                        
procedure TStock.TransferStock(const FromOwner, ToOwner: WideString);
begin
end;                   

{   'AdjustStockLevel'
   'SetStockLevel'   
   'DeleteStockUnit'
   'CreateNewStockUnit'}
   
{$ifdef USING_SERVICE }
function TStock.ListAllStock(const Owner, StockGroup: WideString): WideString;
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Add(Owner);
   SL.Add(StockGroup);
   SL.Add(IntToStr(Integer(False)));
   Result:=RequestServiceData('ListStock',SL.PackText);
   if Result = '' then
   begin
      SL[0]:='All';
      Result:=RequestServiceData('ListStock',SL.PackText);
   end;           
   SL.Free;
end;
function TStock.ListAvailableStock(const Owner, StockGroup: WideString): WideString;
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Add(Owner);
   SL.Add(StockGroup);
   SL.Add(IntToStr(Integer(True)));
   Result:=RequestServiceData('ListStock',SL.PackText);
   SL.Free;
end;
function TStock.GetStockItemDetails(const Description:WideString):WideString;
begin
   Result:=RequestServiceData('GetStockItemDetails',Description);
end;
procedure TStock.DeleteStockItem(const Description: WideString);
begin
   RequestServiceData('DeleteStockItem',Description);
end;
procedure TStock.AddNewStockItem(const Description:WideString;Value:Currency;const Group:WideString;PLU:Integer;const AccountLine,AcctType,Report,ProgID,SUTypes:WideString);
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Add(Description     ); 
   SL.Add(CurrToStr(Value));
   SL.Add(Group           );
   SL.Add(IntToStr(PLU   ));
   SL.Add(AccountLine     );
   SL.Add(AcctType        );
   SL.Add(Report          );
   SL.Add(ProgID          );
   SL.Add(SUTypes         );
   RequestServiceData('AddNewStockItem',SL.PackText);
   SL.Free;
end;
function TStock.QueryStockLevel(const Owner, StockItemName: WideString): Integer;
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Add(Owner); 
   SL.Add(StockItemName);
   Result:=StrToInt(RequestServiceData('GetStockLevel',SL.PackText));
   SL.Free;
end;
procedure TStock.ClearTempAdjustments(const Owner:WideString);
begin
   RequestServiceData('ClearTempAdjustments',Owner);
end;                       
procedure TStock.AdjustStockLevel(const Owner, StockItemName: WideString; Quantity: Integer);
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Add(Owner); 
   SL.Add(StockItemName);
   SL.Add(IntToStr(Quantity));
   RequestServiceData('AdjustStockLevel',SL.PackText);
   SL.Free;
end;                       
procedure TStock.SetStockLevel(const Owner, StockItemName: WideString; Quantity: Integer);
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Add(Owner); 
   SL.Add(StockItemName);
   SL.Add(IntToStr(Quantity));
   RequestServiceData('SetStockLevel',SL.PackText);
   SL.Free;
end;                           
procedure TStock.CreateNewStockUnit(const Owner, StockUnitType: WideString);
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Add(Owner); 
   SL.Add(StockUnitType);
   RequestServiceData('CreateNewStockUnit',SL.PackText);
   SL.Free;
end;
procedure TStock.DeleteStockUnit(const Owner, StockUnitType: WideString);
begin
   RequestServiceData('DeleteStockUnit',Owner);
end;
{$else} //def USING_SERVICE
function TStock.ListAllStock(const Owner, StockGroup: WideString): WideString;
begin
   StockForm.SiteStock.EmptySetUp(Owner);
   Result:=StockForm.SiteStock.Stock.ListAll(Owner,StockGroup);
   if Result = '' then
      Result:=StockForm.SiteStock.Stock.ListAll('All',StockGroup)
end;
function TStock.ListAvailableStock(const Owner, StockGroup: WideString): WideString;
begin
   StockForm.SiteStock.EmptySetUp(Owner);
   Result:=StockForm.SiteStock.Stock.ListAvailable(Owner,StockGroup);
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
procedure TStock.SetStockLevel(const Owner, StockItemName: WideString; Quantity: Integer);
begin
   StockForm.SiteStock.EmptySetUp(Owner);
   StockForm.SiteStock.SetStockLevel(Owner,StockItemName,Quantity);
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
{$endif} //def USING_SERVICE

initialization
  TGPCSCompFactory.Create(ComServer,TStock,Class_Stock,
                          'Support.Stock','GPCS Stock',
                          ciMultiInstance);
end.