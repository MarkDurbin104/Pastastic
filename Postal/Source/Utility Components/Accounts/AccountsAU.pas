unit AccountsAU;

interface

uses
  Windows,Graphics,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Dialogs,NewAccountsFU,dbtables;
  
type
  TAccounts = class(TGPCSAccounts)
  private
     CurrentSession:TSession;
  protected
    procedure LogItem(const ItemID: WideString; Value: Currency; Quantity: Integer); override;
    function GetAccountDetails(const AccountGroup,PeriodList: WideString): WideString; override;
    procedure TransferStock(const UserFrom,UserTo,Name:WideString;Value:Currency;Quantity:Integer); override;
    procedure ReturnStock(const Name:WideString;Value:Currency;Quantity:Integer); override;
    procedure ReceiveStock(const Name:WideString;Value:Currency;Quantity:Integer); override;
    function GetCurrentStockLevels(const List: WideString): WideString; override;
    procedure SetStockLevel(const Name:WideString;Value:Currency;Quantity:Integer); override;
    procedure EndOfDay(var CashValue, StockValue: Currency);   override;
    procedure StartOfDay(var CashValue, StockValue: Currency); override;
    function GetLastEndOfDay(var CashValue, StockValue: Currency):Integer; override;
    function  HasPeriodStarted(const User:WideString):WordBool; override;
    procedure DispatchRem(const Name:WideString;Value:Currency;Quantity:Integer); override;
    procedure ReceiveRem(const Name:WideString;Value:Currency;Quantity:Integer); override;
    function  GetNewProducts: WideString; override;
    procedure CreateNewProduct(const Name, AType, ALine: WideString; Value: Currency); override;
    procedure SellNewProduct(const Name: WideString; Value: Currency); override;
    function Get_AccountUsers: WideString; override;
    function SelectCurrentPeriod:WordBool; override;
  public      
    procedure Initialize; override;
    destructor Destroy; override;
  end;                  
  
implementation
uses
   ComServ2;
   
procedure TAccounts.Initialize;
begin
   CurrentSession:=Sessions.OpenSession('Session'+DateTimeToStr(Now));
end;
destructor TAccounts.Destroy;
begin
   CurrentSession.Close;
   inherited Destroy;
end;         
procedure TAccounts.LogItem(const ItemID: WideString; Value: Currency; Quantity: Integer);
begin
   CurrentSession:=Sessions.OpenSession(CurrentSession.SessionName);
   if not AccountsForm.LogItem(FUser,ItemID,Value,Quantity,FPeriod) then
      RaiseError(3,3,3,'Log Account '+ItemID+' No Parents !');
end;
function TAccounts.GetAccountDetails(const AccountGroup,PeriodList: WideString): WideString;
begin
   CurrentSession:=Sessions.OpenSession(CurrentSession.SessionName);
   if PeriodList = '' then
   begin
      if FPeriod = 0 then
         Set_Period(0);
      Result:=AccountsForm.CommaText(AccountGroup,FUser,IntToStr(FPeriod));
   end
   else
   begin
      Result:=AccountsForm.CommaText(AccountGroup,FUser,PeriodList);
   end;
end;
procedure TAccounts.TransferStock(const UserFrom,UserTo,Name:WideString;Value:Currency;Quantity:Integer);
begin
   CurrentSession:=Sessions.OpenSession(CurrentSession.SessionName);
   AccountsForm.TransferStock(UserFrom,UserTo,Name,Value,Quantity,FPeriod);
end;
procedure TAccounts.ReturnStock(const Name:WideString;Value:Currency;Quantity:Integer);
begin
   CurrentSession:=Sessions.OpenSession(CurrentSession.SessionName);
   AccountsForm.ReturnStock(FUser,Name,Value,Quantity,FPeriod);
end;
procedure TAccounts.ReceiveStock(const Name:WideString;Value:Currency;Quantity:Integer);
begin
   CurrentSession:=Sessions.OpenSession(CurrentSession.SessionName);
   AccountsForm.ReceiveStock(FUser,Name,Value,Quantity,FPeriod);
end;
procedure TAccounts.SetStockLevel(const Name:WideString;Value:Currency;Quantity:Integer);
var
  StockValue:Currency;
  StockQuantity:Integer;
  SoldValue:Currency;
  SoldQuantity:Integer;
  TotalValue:Currency;
  TotalQuantity:Integer;
begin
   CurrentSession:=Sessions.OpenSession(CurrentSession.SessionName);
   AccountsForm.GetLineValue(FUser,Name,SoldValue,SoldQuantity,FPeriod);
   AccountsForm.GetLineValue(FUser,'S'+Name,StockValue,StockQuantity,FPeriod);
   TotalValue:=StockValue-SoldValue;
   TotalQuantity:=StockQuantity-SoldQuantity;
   AccountsForm.LogStock(FUser,Name,Value-TotalValue,Quantity-TotalQuantity,FPeriod);
end;
function TAccounts.GetCurrentStockLevels(const List: WideString): WideString;
var
  SL:TStringList;
  TSL:TStringList;
  BSL:TStringList;
  I:Integer;
begin
  CurrentSession:=Sessions.OpenSession(CurrentSession.SessionName);
  SL:=TStringList.Create;
  TSL:=TStringList.Create;
  BSL:=TStringList.Create;
  SL.CommaText:=List;
  for I:=0 to SL.Count-1 do
  begin
     TSL.CommaText:=SL[I]; // name value prodname
//     BSL.CommaText:=AccountsForm.CommaText('Single.'+TSL[3],FUser,IntToStr(FPeriod));
     BSL.CommaText:=AccountsForm.CommaText('Single.'+TSL[2],FUser,IntToStr(FPeriod));
     if BSL.Count > 2 then
        TSL.Add(BSL[2]) // name value prodname quantity
     else
        TSL.Add('0'); // name value prodname 0
     SL[I]:=TSL.CommaText;
  end;    
  Result:=SL.CommaText;
  SL.Free;
  TSL.Free;
  BSL.Free;
end;             
procedure TAccounts.EndOfDay(var CashValue, StockValue: Currency);
begin
  CurrentSession:=Sessions.OpenSession(CurrentSession.SessionName);
  AccountsForm.EndOfDay(FUser,FPeriod,CashValue,StockValue);
end;
procedure TAccounts.StartOfDay(var CashValue, StockValue: Currency);
begin
  CurrentSession:=Sessions.OpenSession(CurrentSession.SessionName);
  if FUser = 'Supervisor' then
  begin
     if not AccountsForm.HasPeriodStarted(FUser) then
     begin
        AccountsForm.GetLastEndOfDay(FUser,CashValue,StockValue);
        AccountsForm.StartOfDay(FUser,FPeriod,CashValue,StockValue);
     end;
  end
  else
  begin
     AccountsForm.StartOfDay(FUser,FPeriod,CashValue,StockValue);
  end;
end;
function TAccounts.SelectCurrentPeriod:WordBool;
var 
   CashValue,StockValue:Currency;
   Per:Integer;
begin
  Result:=True;
  Set_Period(0);
  if HasPeriodStarted(FUser) then
     Per:=AccountsForm.GetLastEndOfDay(FUser,CashValue,StockValue)
  else
     Per:=FPeriod;
  if Per <> FPeriod then 
  begin
      Set_Period(Per);
      Result:=False;
  end;
end;
function TAccounts.GetLastEndOfDay(var CashValue, StockValue: Currency):Integer;
begin
  CurrentSession:=Sessions.OpenSession(CurrentSession.SessionName);
  Result:=AccountsForm.GetLastEndOfDay(FUser,CashValue,StockValue);
end;
function TAccounts.HasPeriodStarted(const User:WideString):WordBool;
begin
  CurrentSession:=Sessions.OpenSession(CurrentSession.SessionName);
  Result:=AccountsForm.HasPeriodStarted(User);
end;
procedure TAccounts.DispatchRem(const Name:WideString;Value:Currency;Quantity:Integer);
begin
   CurrentSession:=Sessions.OpenSession(CurrentSession.SessionName);
   AccountsForm.LogDispatch(FUser,Name,Value,Quantity,FPeriod);
end;
procedure TAccounts.ReceiveRem(const Name:WideString;Value:Currency;Quantity:Integer);
begin
   CurrentSession:=Sessions.OpenSession(CurrentSession.SessionName);
   AccountsForm.LogReceipt(FUser,Name,Value,Quantity,FPeriod);
end;
function TAccounts.GetNewProducts: WideString;
var
   SL:TStringList;
begin
   CurrentSession:=Sessions.OpenSession(CurrentSession.SessionName);
   SL:=TStringList.Create;
   Result:='';
   try
      if not AccountsForm.Table4.Active then 
         AccountsForm.Table4.Active:=True;
      AccountsForm.Table4.First;
      while not AccountsForm.Table4.EOF do
      begin
         SL.Add('"'+AccountsForm.Table4PName.Value            +'","'+
                    CurrToStr(AccountsForm.Table4PPrice.Value)+'","'+
                    AccountsForm.Table4PAType.Value           +'","'+
                    AccountsForm.Table4PReportsTo.Value       +'"');
         AccountsForm.Table4.Next;
      end;
      Result:=SL.CommaText;
   except
   end;
   SL.Free;
   if AccountsForm.Table4.Active then 
      AccountsForm.Table4.Active:=False;
   Result:='';
end;
procedure TAccounts.CreateNewProduct(const Name, AType, ALine: WideString; Value: Currency);
begin
   CurrentSession:=Sessions.OpenSession(CurrentSession.SessionName);
   if not AccountsForm.Table4.Active then 
      AccountsForm.Table4.Active:=True;
   AccountsForm.Table4.SetKey;
   AccountsForm.Table4PName.Value:=Name;
   if AccountsForm.Table4.GotoKey then
   begin
      AccountsForm.Table4.Edit;
   end
   else
   begin
      AccountsForm.Table4.Append;
      AccountsForm.Table4PName.Value:=Name;
   end;                         
   AccountsForm.Table4PPrice.Value    :=Value;
   AccountsForm.Table4PAType.Value    :=AType;
   AccountsForm.Table4PReportsTo.Value:=ALine;
   AccountsForm.Table4.Post;
   AccountsForm.Table4.Active:=False;
end;                       
procedure TAccounts.SellNewProduct(const Name: WideString; Value: Currency);
begin
   CurrentSession:=Sessions.OpenSession(CurrentSession.SessionName);
   if not AccountsForm.Table4.Active then 
      AccountsForm.Table4.Active:=True;
   AccountsForm.Table4.SetKey;
   AccountsForm.Table4PName.Value:=Name;
   if AccountsForm.Table4.GotoKey then
   begin
      ;
   end;                         
   AccountsForm.Table4.Active:=False;
end;
function TAccounts.Get_AccountUsers: WideString;
var
   SL:TStringList;
begin
   Result:='';
   SL:=TStringList.Create;
   with AccountsForm do
   begin
      AU.Active:=True;
      AU.First;
      while not AU.EOF do
      begin
         SL.Add(AUUser.Value);
         AU.Next;
      end;
      AU.Active:=False;
   end;
   Result:=SL.CommaText;
   SL.Free;
end;              
    
initialization
  TGPCSCompFactory.Create(ComServer,TAccounts,Class_Accounts,
                          'Support.Accounts','GPCS Accounts Manager',
                          ciMultiInstance);
end.
