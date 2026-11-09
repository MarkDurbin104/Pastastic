unit StockMemFileU;

interface

uses
  GPCSErrorLine,Dialogs, StringUtil,
  SysUtils, Classes,GPCSGUID,PackStrListU,ComServ2;

const
   TextSave:Boolean = False;//True;

type
  TListItem = Class(TObject)
  protected
     function IntFromStream(Stream:TStream):Integer ;
     function StrFromStream(Stream:TStream):String  ;
     function CurFromStream(Stream:TStream):Currency;
     procedure IntToStream(Value:Integer ;Stream:TStream);
     procedure StrToStream(Value:String  ;Stream:TStream);
     procedure CurToStream(Value:Currency;Stream:TStream);
  public
     procedure SaveToStream(Stream:TStream); virtual;
     procedure LoadFromStream(Stream:TStream); virtual;
  end;
  TItemList = Class(TListItem)
  private
     TheList:TPackStringList;
     function  GetItem(Index:Integer):TListItem;
     function  GetDescription(Index:Integer):String;
     procedure SetDescription(Index:Integer;Value:String);
  public
     constructor Create;
     destructor Destroy; override;
     function Add(ItemName:String;Item:TListItem):Integer;
     procedure Delete(Index:Integer);
     function IndexOf(ItemName:String):Integer;
     function Count:Integer;
     procedure SaveToStream(Stream:TStream); override;
     procedure LoadFromStream(Stream:TStream); override;
     property Items[Index:Integer]:TListItem read GetItem; default;
     property Description[Index:Integer]:String read GetDescription write SetDescription;
  end;
  String80 = String[80]; // short fixed length string.
  PStockItemStruct = ^TStockItemStruct;
  TStockItemStruct = packed record
     Description:String80;
     Price      :Currency;
     PLU        :Integer ;
     ProgID     :String80;
     AccountID  :String80;
     Group      :String80;
     Identifier :Integer ;
     Agency     :String80;
     ReportLine :String80;
  end;
  TStockItem = class(TListItem)
  private
     StockItemStruct:PStockItemStruct;
     procedure SetItemValue (Index:Integer;Value:Variant);
     function  GetItemValue (Index:Integer):Variant;
  public
     constructor Create(Description:String;Price:Currency;Identifier:Integer);
     destructor Destroy; override;
     procedure SaveToStream(Stream:TStream)  ; override;
     procedure LoadFromStream(Stream:TStream); override;
     property Description:Variant index 0 read GetItemValue write SetItemValue;
     property Price      :Variant index 1 read GetItemValue write SetItemValue;
     property PLU        :Variant index 2 read GetItemValue write SetItemValue;
     property ProgID     :Variant index 3 read GetItemValue write SetItemValue;
     property AccountID  :Variant index 4 read GetItemValue write SetItemValue;
     property Group      :Variant index 5 read GetItemValue write SetItemValue;
     property Identifier :Variant index 6 read GetItemValue write SetItemValue;
     property Agency     :Variant index 7 read GetItemValue write SetItemValue;
     property ReportLine :Variant index 8 read GetItemValue write SetItemValue;
  end;
  
  TStockList = class(TItemList)
  private
    function GetItem(Index:Integer):TStockItem;
  public
     function Add(Item:TStockItem):Integer;
     procedure LoadFromStream(Stream:TStream); override;
     function IndexOfID(Id:Integer):TStockItem;
     property Items[Index:Integer]:TStockItem read GetItem; default;
  end;
  PStockUnitItemStruct = ^TStockUnitItemStruct;
  TStockUnitItemStruct = packed record
     TempAdjust :Integer;
     Quantity   :Integer;
     MinLevel   :Integer;
     MaxLevel   :Integer;
     NomLevel   :Integer;
     TQuantity  :Integer;
     ItemIndex  :Integer;
  end;
  TStockUnitItem = class(TListItem)
  private
     FStockItem  :TStockItem;
     StockUnitItemStruct:PStockUnitItemStruct;
     procedure SetItemValue (Index:Integer;Value:Variant);
     function  GetItemValue (Index:Integer):Variant;
  public
     constructor Create(StockItem:TStockItem;Qty,Min,Max,Nom:Integer);
     destructor Destroy; override;
     procedure SaveToStream(Stream:TStream); override;
     procedure LoadFromStream(Stream:TStream); override;
     property Description:Variant index  0 read GetItemValue write SetItemValue;
     property Price      :Variant index  1 read GetItemValue write SetItemValue;
     property Group      :Variant index  2 read GetItemValue write SetItemValue;
     property Agency     :Variant index  3 read GetItemValue write SetItemValue;
     property ProgID     :Variant index  4 read GetItemValue write SetItemValue;
     property PLU        :Variant index  5 read GetItemValue write SetItemValue;
     property TempAdjust :Variant index  6 read GetItemValue write SetItemValue;
     property Quantity   :Variant index  7 read GetItemValue write SetItemValue;
     property TQuantity  :Variant index  8 read GetItemValue write SetItemValue;
     property MinLevel   :Variant index  9 read GetItemValue write SetItemValue;
     property MaxLevel   :Variant index 10 read GetItemValue write SetItemValue;
     property NomLevel   :Variant index 11 read GetItemValue write SetItemValue;
     property ItemIndex  :Variant index 12 read GetItemValue write SetItemValue;
  end;                    
  TStockUnit = class(TItemList)
  private
    FOwner     :String;
    FTransferTo:String;
    function GetItem(Index:Integer):TStockUnitItem;
  public
     constructor Create(Owner:String);
     procedure SaveToStream(Stream:TStream); override;
     procedure LoadFromStream(Stream:TStream); override;
     function Add(Item:TStockUnitItem):Integer;
     property Items[Index:Integer]:TStockUnitItem read GetItem; default;
     property Owner:String read FOwner write FOwner;
     property TransferTo:String read FTransferTo write FTransferTo;
  end;
  TStockUnitType = class(TStockUnit)
  private
     FName:String;
  public
     constructor Create(Name:String);
     procedure SaveToStream(Stream:TStream); override;
     procedure LoadFromStream(Stream:TStream); override;
     property Name:String read FName write FName;
  end;
  TStockUnitTypeList = class(TItemList)
  private
     function GetItem(Index:Integer):TStockUnitType;
  public
     function ListAll(SUTypeName,StockGroup:String):String;
     function Add(Item:TStockUnitType):Integer;
     procedure LoadFromStream(Stream:TStream); override;
     property Items[Index:Integer]:TStockUnitType read GetItem; default;
  end;
  TStockUnitList = class(TItemList)
  private
     function GetItem(Index:Integer):TStockUnit;
  public
     function Add(Item:TStockUnit):Integer;
     procedure LoadFromStream(Stream:TStream); override;
     property Items[Index:Integer]:TStockUnit read GetItem; default;
     function ListStock(Owner,StockGroup:String;Avail:Boolean):String;
     function ListAll(Owner,StockGroup:String):String;
     function ListAvailable(Owner,StockGroup:String):String;
  end;
  TSiteStock = class(TObject)
  private
     FCurrentFileName:String;
     FStockItems:TStockList;
     FStockUnits:TStockUnitList;
     FStockUnitTypes:TStockUnitTypeList;
     FStockTransfers:TStockUnitList;
     FModified:Boolean;
     FAutoSave:Boolean;
     function GetStockItem(Owner,StockItemName:String):TStockUnitItem;
     procedure SetModified(Value:Boolean);
  public
     constructor Create;
     destructor Destroy; override;
     procedure SaveToStream(Stream:TStream);
     procedure LoadFromStream(Stream:TStream);
     procedure SaveToFile(FileName:String);
     procedure LoadFromFile(FileName:String);
     function ListTransfersTo(Owner:String):String;
     function ListTransfersFrom(Owner:String):String;
     function ListTransferStock(FromOwner,ToOwner:String):String;
     procedure ChangeStockTransfer(FromOwner,ToOwner,StockItemName:String;Quantity:Integer);
     function GetStockLevel(Owner,StockItemName:String):Integer;
     procedure ClearTempAdjustments(Owner:String);
     function AdjustStockLevel(Owner,StockItemName:String;ByValue:Integer):Integer;
     function SetStockLevel(Owner,StockItemName:String;ToValue:Integer):Integer;
     procedure CreateNewStockUnit(Owner,StockUnitTypeName:String);
     procedure DeleteStockUnit(Owner:String);
     procedure SetupStockTransfer(FromOwner,ToOwner,StockItemName:String;Quantity:Integer);
     procedure TransferStock(FromOwner,ToOwner:String);
     procedure EmptySetUp(Owner:String);
     procedure ResetStockFor(Owner:String);
     procedure DeleteStockItemByName(Description:String);
     function  GetStockItemDetails(Description:String):String;
     procedure DeleteStockItem(StockItem:TStockItem);
     procedure AddNewStockItem(Description:String;Value:Currency;Group:String;PLU:Integer;AccountLine,AcctType,Report,ProgID,SUTypes:String);
     property StockItems:TStockList             read FStockItems     write FStockItems    ;
     property StockUnits:TStockUnitList         read FStockUnits     write FStockUnits    ;
     property StockUnitTypes:TStockUnitTypeList read FStockUnitTypes write FStockUnitTypes;
     property StockTransfers:TStockUnitList     read FStockTransfers write FStockTransfers;
     property Modified:Boolean read FModified write SetModified;
     property AutoSave:Boolean read FAutoSave write FAutoSave;
  end;        
implementation

{TListItem}
function TListItem.IntFromStream(Stream:TStream):Integer ;
var
   C:Char;
   S:String;
begin
   if TextSave then
   begin
      try
         S:='';
         Stream.ReadBuffer(Pointer(@C)^,1);
         while C <> #13 do
         begin
            S:=S+C;
            Stream.ReadBuffer(Pointer(@C)^,1);
         end;                
         Stream.ReadBuffer(Pointer(@C)^,1);
         Result:=StrToIntdef(S,0);
      except
         Result:=0;
         // raise read error
      end;
   end
   else
   begin
      try
         Stream.ReadBuffer(Pointer(@Result)^,SizeOf(Result));
      except
         Result:=0;
         // raise read error
      end;
   end;
end;
function TListItem.CurFromStream(Stream:TStream):Currency;
begin
   try
      Result:=IntFromStream(Stream) / 1000;
   except
      Result:=0;
      // raise read error
   end;
end;
function TListItem.StrFromStream(Stream:TStream):String;
var
   Len:Integer;
   C:Char;
   S:String;
begin
   if TextSave then
   begin
      try
         S:='';
         Stream.ReadBuffer(Pointer(@C)^,1);
         while C <> #13 do
         begin
            S:=S+C;
            Stream.ReadBuffer(Pointer(@C)^,1);
         end;                
         Stream.ReadBuffer(Pointer(@C)^,1);
         Result:=S;
      except
         Result:='';
         // raise read error
      end;
   end
   else
   begin
      try
         Len:=IntFromStream(Stream);
         SetLength(Result,Len);
         Stream.ReadBuffer(Pointer(@Result[1])^,Len);
      except
         Result:='';
         // raise read error
      end;
   end;
end;
procedure TListItem.IntToStream(Value:Integer;Stream:TStream);
var
   S:String;
begin
   if TextSave then
   begin
      S:=IntToStr(Value)+#13#10;
      Stream.WriteBuffer(Pointer(@S[1])^,Length(S));
   end
   else
   begin
      Stream.WriteBuffer(Pointer(@Value)^,SizeOf(Value));
   end;
end;
procedure TListItem.StrToStream(Value:String;Stream:TStream);
var
   Len:Integer;
begin
   if TextSave then
   begin
      Value:=Value+#13#10;
      Stream.WriteBuffer(Pointer(@Value[1])^,Length(Value));
   end
   else
   begin
      Len:=Length(Value);
      IntToStream(Len,Stream);
      Stream.WriteBuffer(Pointer(@Value[1])^,Len);
   end;
end;
procedure TListItem.CurToStream(Value:Currency;Stream:TStream);
var
   Milli:Integer;
begin
   Milli:=Trunc(1000*Value);
   IntToStream(Milli,Stream);
end;
procedure TListItem.SaveToStream(Stream:TStream);
begin
end;
procedure TListItem.LoadFromStream(Stream:TStream);
begin
end;
{TItemList}            
constructor TItemList.Create; 
begin
   inherited Create;
   TheList:=TPackStringList.Create;
end;
destructor TItemList.Destroy;
begin
   while Count > 0 do Delete(0);
   TheList.Free;
   inherited Destroy;
end;               
procedure TItemList.SaveToStream(Stream:TStream);
var
   I:Integer;
begin
   IntToStream(Count,Stream);
   for I:=0 to Count-1 do
      Items[I].SaveToStream(Stream);
end;
procedure TItemList.LoadFromStream(Stream:TStream);
var
   I:Integer;
   ItemCount:Integer;
   ListItem:TListItem;
begin
   ItemCount:=IntFromStream(Stream);
   for I:=0 to ItemCount-1 do
   begin
      ListItem:=TListItem.Create;
      ListItem.LoadFromStream(Stream);
      Add('',ListItem);
   end;
end;
function  TItemList.GetDescription(Index:Integer):String;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=TheList[Index]
   else
      Result:='';
end;   
procedure TItemList.SetDescription(Index:Integer;Value:String);
begin
   if (Index >= 0) and (Index < Count) then
      TheList[Index]:=Value;
end;   
function TItemList.GetItem(Index:Integer):TListItem;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=TListItem(TheList.Objects[Index])
   else
      Result:=nil;
end;   
function TItemList.Add(ItemName:String;Item:TListItem):Integer;
begin
   Result:=TheList.AddObject(ItemName,Item);
end;
function TItemList.IndexOf(ItemName:String):Integer;
begin
   Result:=TheList.IndexOf(ItemName);
end;
function TItemList.Count:Integer;
begin
  Result:=TheList.Count;
end;
procedure TItemList.Delete(Index:Integer);
begin
  if (Index >= 0) and (Index < Count) then
  begin
     if Items[Index] <> nil then 
        Items[Index].Free;
     TheList.Delete(Index);
  end;
end;
function GetSharedMemory(Size:Integer):Pointer;
begin
   GetMem(Result,Size);
end;
procedure FreeSharedMemory(Value:Pointer);
begin
   FreeMem(Value);
end;
{TStockItem}                             
constructor TStockItem.Create(Description:String;Price:Currency;Identifier:Integer);
begin
   inherited Create;
   StockItemStruct:=GetSharedMemory(SizeOf(TStockItemStruct));
   Self.Description:=Description;
   Self.Price      :=Price      ;
   Self.Identifier :=Identifier ;
end;
destructor TStockItem.Destroy;
begin
   FreeSharedMemory(StockItemStruct);
   inherited Destroy;
end;
procedure TStockItem.SetItemValue (Index:Integer;Value:Variant);
begin
   case Index of
      0 : StockItemStruct^.Description:=Value; 
      1 : StockItemStruct^.Price      :=Value; 
      2 : StockItemStruct^.PLU        :=Value; 
      3 : StockItemStruct^.ProgID     :=Value; 
      4 : StockItemStruct^.AccountID  :=Value; 
      5 : StockItemStruct^.Group      :=Value; 
      6 : StockItemStruct^.Identifier :=Value; 
      7 : StockItemStruct^.Agency     :=Value; 
      8 : StockItemStruct^.ReportLine :=Value; 
   end;               
end;
function  TStockItem.GetItemValue (Index:Integer):Variant;
begin
   case Index of
      0 : Result:=StockItemStruct^.Description; 
      1 : Result:=StockItemStruct^.Price      ; 
      2 : Result:=StockItemStruct^.PLU        ; 
      3 : Result:=StockItemStruct^.ProgID     ; 
      4 : Result:=StockItemStruct^.AccountID  ; 
      5 : Result:=StockItemStruct^.Group      ; 
      6 : Result:=StockItemStruct^.Identifier ; 
      7 : Result:=StockItemStruct^.Agency     ; 
      8 : Result:=StockItemStruct^.ReportLine ; 
   end;               
end;                     
procedure TStockItem.SaveToStream(Stream:TStream);
begin
   StrToStream(Description,Stream);
   CurToStream(Price      ,Stream);
   IntToStream(Identifier ,Stream);
   StrToStream(AccountID  ,Stream);
   StrToStream(Group      ,Stream);
   IntToStream(PLU        ,Stream);
   StrToStream(ProgID     ,Stream);
   StrToStream(Agency     ,Stream);
   StrToStream(ReportLine ,Stream);
end;                      
procedure TStockItem.LoadFromStream(Stream:TStream);
begin
   Description:=StrFromStream(Stream);
   Price      :=CurFromStream(Stream);
   Identifier :=IntFromStream(Stream);
   AccountID  :=StrFromStream(Stream);
   Group      :=StrFromStream(Stream);
   PLU        :=IntFromStream(Stream);
   ProgID     :=StrFromStream(Stream);
   Agency     :=StrFromStream(Stream);
   ReportLine :=StrFromStream(Stream);
end;

{TStockList}

function TStockList.GetItem(Index:Integer):TStockItem;
begin
   Result:=TStockItem(inherited Items[Index]);
end;
function TStockList.Add(Item:TStockItem):Integer;
var
   Ident:Integer;
   I:Integer;
begin
   Ident:=0;
   for I:=0 to Count-1 do
      if Items[I].Identifier > Ident then
         Ident:=Items[I].Identifier;
   Inc(Ident);
//   Item.Identifier:=Ident;
   inherited Add(Item.Description,Item);
   Result:=Ident;
end;
procedure TStockList.LoadFromStream(Stream:TStream);
var
   I:Integer;
   ItemCount:Integer;
   StockItem:TStockItem;
begin
   ItemCount:=IntFromStream(Stream);
   for I:=0 to ItemCount-1 do
   begin
      StockItem:=TStockItem.Create('',0,0);
      StockItem.LoadFromStream(Stream);
      Add(StockItem);
   end;
end;
function TStockList.IndexOfID(Id:Integer):TStockItem;
var
   I:Integer;
begin
   Result:=nil;
   for I:=0 to Count-1 do
   begin
      if Items[I].Identifier = Id then
      begin
         Result:=Items[I];
         Exit;
      end;
   end;
end;

{TStockUnitItem}
constructor TStockUnitItem.Create(StockItem:TStockItem;Qty,Min,Max,Nom:Integer);
begin
   inherited Create;
   StockUnitItemStruct:=GetSharedMemory(SizeOf(TStockUnitItemStruct));
   Quantity :=Qty;
   MinLevel :=Min;
   MaxLevel :=Max;
   NomLevel :=Nom;
   TempAdjust:=0;
   FStockItem:=StockItem;
end;
destructor TStockUnitItem.Destroy;
begin
   FreeSharedMemory(StockUnitItemStruct);
   inherited Destroy;
end;
procedure TStockUnitItem.SetItemValue (Index:Integer;Value:Variant);
begin
   case Index of
       0 : if FStockItem <> nil then FStockItem.Description        :=Value;
       1 : if FStockItem <> nil then FStockItem.Price              :=Value;
       2 : if FStockItem <> nil then FStockItem.Group              :=Value;
       3 : if FStockItem <> nil then FStockItem.Agency             :=Value;
       4 : if FStockItem <> nil then FStockItem.ProgID             :=Value;
       5 : if FStockItem <> nil then FStockItem.PLU                :=Value;
       6 : StockUnitItemStruct^.TempAdjust:=Value; 
       7 : StockUnitItemStruct^.Quantity  :=Value; 
       8 : StockUnitItemStruct^.TQuantity :=Value; 
       9 : StockUnitItemStruct^.MinLevel  :=Value; 
      10 : StockUnitItemStruct^.MaxLevel  :=Value; 
      11 : StockUnitItemStruct^.NomLevel  :=Value; 
      12 : StockUnitItemStruct^.ItemIndex :=Value; 
   end;
end;
function  TStockUnitItem.GetItemValue (Index:Integer):Variant;
begin
   Result:=Unassigned;
   case Index of
        0 : if FStockItem <> nil then Result:=FStockItem.Description;
        1 : if FStockItem <> nil then Result:=FStockItem.Price              ;
        2 : if FStockItem <> nil then Result:=FStockItem.Group              ;
        3 : if FStockItem <> nil then Result:=FStockItem.Agency             ;
        4 : if FStockItem <> nil then Result:=FStockItem.ProgID             ;
        5 : if FStockItem <> nil then Result:=FStockItem.PLU                ;
        6 : Result:=StockUnitItemStruct^.TempAdjust; 
        7 : Result:=StockUnitItemStruct^.Quantity+StockUnitItemStruct.TempAdjust; 
        8 : Result:=StockUnitItemStruct^.TQuantity ; 
        9 : Result:=StockUnitItemStruct^.MinLevel  ; 
       10 : Result:=StockUnitItemStruct^.MaxLevel  ; 
       11 : Result:=StockUnitItemStruct^.NomLevel  ; 
       12 : Result:=StockUnitItemStruct^.ItemIndex ; 
   end;
end;
procedure TStockUnitItem.SaveToStream(Stream:TStream);
begin
   IntToStream(Quantity,Stream);
   IntToStream(TempAdjust,Stream);
   IntToStream(MinLevel,Stream);
   IntToStream(MaxLevel,Stream);
   IntToStream(NomLevel,Stream);
   IntToStream(FStockItem.Identifier,Stream);
end;
procedure TStockUnitItem.LoadFromStream(Stream:TStream);
begin
   Quantity:=IntFromStream(Stream);
   TempAdjust:=IntFromStream(Stream);
   MinLevel:=IntFromStream(Stream);
   MaxLevel:=IntFromStream(Stream);
   NomLevel:=IntFromStream(Stream);
   ItemIndex:=IntFromStream(Stream);
end;
{TStockUnit}
constructor TStockUnit.Create(Owner:String);
begin
   inherited Create;
   FOwner:=Owner;
end;

procedure TStockUnit.SaveToStream(Stream:TStream);
begin
   StrToStream(FOwner,Stream);
   StrToStream(FTransferTo,Stream);
   inherited SaveToStream(Stream);
end;
procedure TStockUnit.LoadFromStream(Stream:TStream);
var
   I:Integer;
   ItemCount:Integer;
   StockUnitItem:TStockUnitItem;
begin
   FOwner:=StrFromStream(Stream);
   FTransferTo:=StrFromStream(Stream);
   ItemCount:=IntFromStream(Stream);
   for I:=0 to ItemCount-1 do
   begin
      StockUnitItem:=TStockUnitItem.Create(nil,0,0,0,0);
      StockUnitItem.LoadFromStream(Stream);
      Add(StockUnitItem);
   end;
end;
function TStockUnit.GetItem(Index:Integer):TStockUnitItem;
begin
   Result:=TStockUnitItem(inherited Items[Index]);
end;
function TStockUnit.Add(Item:TStockUnitItem):Integer;
begin
   Result:=inherited Add(Item.Description,Item);
end;
{TStockUnitList}
function TStockUnitList.GetItem(Index:Integer):TStockUnit;
begin
   Result:=TStockUnit(inherited Items[Index]);
end;
function TStockUnitList.Add(Item:TStockUnit):Integer;
begin
   Result:=inherited Add(Item.Owner,Item);
end;
procedure TStockUnitList.LoadFromStream(Stream:TStream);
var
   I:Integer;
   ItemCount:Integer;
   StockUnit:TStockUnit;
begin
   ItemCount:=IntFromStream(Stream);
   for I:=0 to ItemCount-1 do
   begin
      StockUnit:=TStockUnit.Create('');
      StockUnit.LoadFromStream(Stream);
      Add(StockUnit);
   end;
end;
function StockListSort(Item1,Item2: Pointer):Integer;
var
   A,B:TStockUnitItem;
   G1,G2:String;
begin
   A:=TStockUnitItem(Item1);
   B:=TStockUnitItem(Item2);


   If GetGPCSRegString('', 'Stock Alpha Sort', '0') = '1' then
   begin
     G1:=A.Description;
     G2:=B.Description;
     Result:=StrComp(PChar(G1),PChar(G2));   
   end
   else
   begin
     if UpperCase(A.Group) = 'STAMPS' then G1:='*'+A.Group else G1:=A.Group;
     if UpperCase(B.Group) = 'STAMPS' then G2:='*'+B.Group else G2:=B.Group;
     Result:=StrComp(PChar(G1),PChar(G2));
     if Result = 0 then
     begin
        if A.PLU < B.PLU then
          Result:=-1
        else if A.PLU > B.PLU then
          Result:=1
        else
        begin
           if A.Price < B.Price then
             Result:=-1
           else if A.Price > B.Price then
             Result:=1
        end;
     end;
     if Result = 0 then
     begin
        G1:=A.Description;
        G2:=B.Description;
        Result:=StrComp(PChar(G1),PChar(G2));   
     end;
   end;
end;
function TStockUnitList.ListStock(Owner,StockGroup:String;Avail:Boolean):String;
var
  SI,
  ItemIdx,
  UnitIdx         : Integer;
  StockUnit      : TStockUnit;
  SList          : TStringList;
  OList          : TList;
  StockUnitItem  : TStockUnitItem;
  Res            : TPackStringList;
  ReportCash     : Boolean;
  AgencySearch   : Boolean;  //whether the StockGroup parameter should be compared to the Agency
  ExcludeGroup   : Boolean;  //whether the StockGroup should be EXCLUDED from the returned list (eg, !CashAcc)
begin
  SList:=TStringList.Create;
  //determine cash reporting
  if StockGroup = '*All' then  //don't report cash for all stock
  begin
     ReportCash:=False;
     StockGroup:='All';
  end
  else
     ReportCash:=True;

  Result:='';

  //whether the StockGroup parameter should be compared to the Agency
  If Copy(StockGroup,1,1) = '*' then
  begin
    AgencySearch := True;
    StockGroup:=Copy(StockGroup,2,999); //grab actual 'Agency' required
  end
  else
    AgencySearch := False;

  //whether the StockGroup should be EXCLUDED from the returned list (eg, !CashAcc)
  if Copy(StockGroup,1,1) = '!' then
  begin
    ExcludeGroup := True;
    StockGroup:=Copy(StockGroup,2,999);
  end
  else
    ExcludeGroup := False;

  //show stock for all/selected users
  If   Owner = 'All' then UnitIdx := 0
  else UnitIdx := IndexOf(Owner); //specific
  While ((Owner = 'All') and (UnitIdx <= Count-1))
  or    ( UnitIdx = IndexOf(Owner) ) do
  begin
    StockUnit := Items[UnitIdx]; //grab each stock unit
    if StockUnit <> nil then
    begin
      for ItemIdx := 0 to StockUnit.Count-1 do //all stock items in this unit
      begin
        StockUnitItem := StockUnit[ItemIdx];
        if  ((ReportCash) or (StockUnitItem.Group <> 'Cash')) //handle cash reporting
        and ((not Avail) or (StockUnitItem.Quantity > 0))     //only items in stock
        //group/-ve group/agency searches
        and (
                 ((not AgencySearch) and (not ExcludeGroup) and ((StockGroup = 'All') or (StockUnitItem.Group = StockGroup)))  //group search (non-exlcuded
              or (    AgencySearch and (StockUnitItem.Agency = StockGroup)) //agency search
              or (    ExcludeGroup and (StockUnitItem.Group <> StockGroup)) //exclude group
            )
        then
        begin
          SI:=SList.IndexOf(StockUnitItem.Description);  //check whether stockitem is already in the list
          if SI = -1 then
          begin
             SList.AddObject(StockUnitItem.Description,StockUnitItem);
             StockUnitItem.TQuantity := StockUnitItem.Quantity;
          end
          else
          begin
             TStockUnitItem(SList.Objects[SI]).TQuantity:=TStockUnitItem(SList.Objects[SI]).TQuantity+StockUnitItem.Quantity;
          end; //stockitem quantity accumulation
        end;  //if stockitem matches criteria
      end; //for all stockitems in unit
    end; //if stockunti <> nil
    Inc(UnitIdx);
  end;
  Res:=TPackStringList.Create;
  OList:=TList.Create;
  for ItemIdx := 0 to SList.Count-1 do
     OList.Add(SList.Objects[ItemIdx]);
  SList.Free;
  OList.Sort(StockListSort);
  for ItemIdx := 0 to OList.Count-1 do
  begin
     StockUnitItem:=TStockUnitItem(OList[ItemIdx]);
     //when viewing available stock
     //do not list cashstock because already handled by 'cash on hand' code
     If (StockUnitItem.ProgID  <> 'Product.CashStock')  //any other stock item
     or (Avail = False) //or viewing a full stock list
     then
           Res.Add('"'+StockUnitItem.Description+'","'+IntToStr(StockUnitItem.TQuantity)+'","'+CurrToStrF(StockUnitItem.Price,ffNumber,2)+'","'+IntToStr(StockUnitItem.PLU)+'","'+StockUnitItem.ProgID+'"');
  end;
  OList.Free;
  Result:=Res.CommaText;
  Res.Free;
end;

function TStockUnitList.ListAll(Owner,StockGroup:String):String;
begin
   Result:=ListStock(Owner,StockGroup,False);
end;
function TStockUnitList.ListAvailable(Owner,StockGroup:String):String;
begin
   Result:=ListStock(Owner,StockGroup,True);
end;

{TSiteStock}
constructor TSiteStock.Create;
begin
   inherited Create;
   FStockItems:=TStockList.Create;
   FStockUnits:=TStockUnitList.Create;
   FStockUnitTypes:=TStockUnitTypeList.Create;
   FStockTransfers:=TStockUnitList.Create;
   FAutoSave:=True;
   Modified:=False;
end;              
destructor TSiteStock.Destroy;
begin
   FStockItems.Free;    
   FStockUnits.Free;
   FStockUnitTypes.Free;
   FStockTransfers.Free;
   inherited Destroy;
end;
procedure TSiteStock.SaveToStream(Stream:TStream);
begin
   FStockItems    .SaveToStream(Stream);
   FStockUnits    .SaveToStream(Stream);
   FStockUnitTypes.SaveToStream(Stream);
   FStockTransfers.SaveToStream(Stream);
   Modified:=False;
end;
procedure TSiteStock.LoadFromStream(Stream:TStream);
var
   I,J:Integer;
   StockItem:TStockItem;
begin
   FStockItems    .LoadFromStream(Stream);
   FStockUnits    .LoadFromStream(Stream);
   
   for I:=0 to FStockUnits.Count-1 do
   begin
      J:=0;
      while J < FStockUnits[I].Count do
      begin
          StockItem:=FStockItems.IndexOfID(FStockUnits[I][J].ItemIndex);
          if StockItem <> nil then
          begin
             FStockUnits[I][J].FStockItem:=StockItem;
             FStockUnits[I].Description[J]:=StockItem.Description;
             Inc(J);
          end
          else
          begin
             FStockUnits[I].Delete(J);
          end;
      end;
   end;
   
   FStockUnitTypes.LoadFromStream(Stream);
   for I:=0 to FStockUnitTypes.Count-1 do
   begin
      for J:=0 to FStockUnitTypes[I].Count-1 do
      begin
          FStockUnitTypes[I][J].FStockItem:=FStockItems.IndexOfID(FStockUnitTypes[I][J].ItemIndex);
          FStockUnitTypes[I].Description[J]:=FStockUnitTypes[I][J].FStockItem.Description;
      end;
   end;
   
   FStockTransfers.LoadFromStream(Stream);
   for I:=0 to FStockTransfers.Count-1 do
   begin
      for J:=0 to FStockTransfers[I].Count-1 do
      begin
          FStockTransfers[I][J].FStockItem:=FStockItems.IndexOfID(FStockTransfers[I][J].ItemIndex);
          FStockTransfers[I].Description[J]:=FStockTransfers[I][J].FStockItem.Description;
      end;
   end;
   Modified:=False;
end;                                           
function TSiteStock.GetStockItemDetails(Description:String):String;
var
   Index:Integer;
   SL:TStringList;
begin   
   Result:='';
   Index:=FStockItems.IndexOf(Description);
   if Index <> -1 then
   begin
      SL:=TStringList.Create;
      with FStockItems[Index] do
      begin
         SL.Add(          Description);
         SL.Add(CurrToStr(Price     ));
         SL.Add(          Group      );
         SL.Add(          AccountID  );
         SL.Add(          Agency     );
         SL.Add(          ReportLine );
         SL.Add( IntToStr(PLU       ));
         SL.Add(          ProgID     );
      end;
      Result:=SL.CommaText;
      SL.Free;
   end;
end;
procedure TSiteStock.DeleteStockItemByName(Description:String);
var
   Index:Integer;
begin
   Index:=FStockItems.IndexOf(Description);
   if Index <> -1 then
      DeleteStockItem(FStockItems[Index]);
end;
procedure TSiteStock.DeleteStockItem(StockItem:TStockItem);
var
   I,J:Integer;
begin
   for I:=0 to FStockUnits.Count-1 do
   begin
      J:=0;
      while J < FStockUnits[I].Count do
      begin
         if FStockUnits[I][J].FStockItem = StockItem then
            FStockUnits[I].Delete(J)
         else
            Inc(J);
      end;
   end;
   for I:=0 to FStockUnitTypes.Count-1 do
   begin
      J:=0;
      while J < FStockUnitTypes[I].Count do
      begin
         if FStockUnitTypes[I][J].FStockItem = StockItem then
            FStockUnitTypes[I].Delete(J)
         else
            Inc(J);
      end;
   end;
   FStockItems.Delete(FStockItems.IndexOf(StockItem.Description));
   Modified:=True;
end;              
procedure TSiteStock.SetModified(Value:Boolean);
begin
   if AutoSave and Value then
      SaveToFile(FCurrentFileName)
   else
      FModified:=Value;
end;
procedure TSiteStock.SaveToFile(FileName:String);
var
   FileStream:TFileStream;
begin                             
   FCurrentFileName:=FileName;
   FileStream:=TFileStream.Create(FileName,fmCreate or fmOpenWrite or fmShareDenyNone);
   SaveToStream(FileStream);
   FileStream.Free;
end;              
procedure TSiteStock.LoadFromFile(FileName:String);
var
   FileStream:TFileStream;
begin
   FCurrentFileName:=FileName;
   if FileExists(FileName) then
   begin
      FileStream:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyNone);
      LoadFromStream(FileStream);
      FileStream.Free;
   end;
end;
function TSiteStock.ListTransfersTo(Owner:String):String;
var
   I:Integer;
   StockUnit:TStockUnit;
   Res:TPackStringList;
begin
   Result:='';
   Res:=TPackStringList.Create;
   for I:=0 to StockTransfers.Count-1 do
   begin
      StockUnit:=StockTransfers[I];
      if (StockUnit <> nil) and (StockUnit.FTransferTo = Owner) then
         Res.Add(StockUnit.Owner);
   end;
   Result:=Res.CommaText;
   Res.Free;
end;
function TSiteStock.ListTransfersFrom(Owner:String):String;
var
   I:Integer;
   StockUnit:TStockUnit;
   Res:TPackStringList;
begin
   Result:='';
   Res:=TPackStringList.Create;
   for I:=0 to StockTransfers.Count-1 do
   begin
      StockUnit:=StockTransfers[I];
      if (StockUnit <> nil) and (StockUnit.Owner = Owner) then
         Res.Add(StockUnit.FTransferTo);
   end;
   Result:=Res.CommaText;
   Res.Free;
end;
function TSiteStock.ListTransferStock(FromOwner,ToOwner:String):String;
var
   I,J:Integer;
   StockUnit:TStockUnit;
   StockUnitItem:TStockUnitItem;
   Res:TPackStringList;
begin
   Result:='';
   for I:=0 to StockTransfers.Count-1 do
   begin
      StockUnit:=StockTransfers[I];
      if (StockUnit <> nil) and (StockUnit.Owner = FromOwner) and (StockUnit.TransferTo = ToOwner) then
      begin
         Res:=TPackStringList.Create;
         for J:=0 to StockUnit.Count-1 do
         begin
            StockUnitItem:=StockUnit[I];
            Res.Add('"'+StockUnitItem.Description+'","'+IntToStr(StockUnitItem.Quantity)+'","'+CurrToStrF(StockUnitItem.Price,ffNumber,2)+'"');
         end;
         Result:=Res.CommaText;
         Res.Free;
         Exit;
      end;
   end;
end;
procedure TSiteStock.ChangeStockTransfer(FromOwner,ToOwner,StockItemName:String;Quantity:Integer);
var
   I:Integer;
   StockUnit:TStockUnit;
   StockUnitItem:TStockUnitItem;
begin
   for I:=0 to StockTransfers.Count-1 do
   begin
      StockUnit:=StockTransfers[I];
      if (StockUnit <> nil) and (StockUnit.Owner = FromOwner) and (StockUnit.TransferTo = ToOwner) then
      begin
         StockUnitItem:=StockUnit[StockUnit.IndexOf(StockItemName)];
         if StockUnitItem <> nil then
            StockUnitItem.Quantity:=Quantity;
         Modified:=True;
         Exit;       
      end;    
   end;
end;
function TSiteStock.GetStockItem(Owner,StockItemName:String):TStockUnitItem;
var
   StockUnit:TStockUnit;
begin
   Result:=nil;
   StockUnit:=FStockUnits[FStockUnits.IndexOf(Owner)];
   if StockUnit <> nil then
      Result:=StockUnit[StockUnit.IndexOf(StockItemName)];
end;
function TSiteStock.GetStockLevel(Owner,StockItemName:String):Integer;
var
   StockUnitItem:TStockUnitItem;
begin
   Result:=0;
   StockUnitItem:=GetStockItem(Owner,StockItemName);
   if StockUnitItem <> nil then
      Result:=StockUnitItem.Quantity;
end;
procedure TSiteStock.ClearTempAdjustments(Owner:String);
var
   StockUnit:TStockUnit;
   I:Integer;
begin
   StockUnit:=FStockUnits[FStockUnits.IndexOf(Owner)];
   if StockUnit <> nil then
   begin
      for I:=0 to StockUnit.Count-1 do
         StockUnit[I].TempAdjust:=0;
      Modified:=True;
   end;
   if Owner <> 'Supervisor'then
      ClearTempAdjustments('Supervisor');

end;
function TSiteStock.AdjustStockLevel(Owner,StockItemName:String;ByValue:Integer):Integer;
var
   StockUnitItem:TStockUnitItem;
   AdjustOnly:Boolean;
begin
   Result:=0;
   AdjustOnly:=False;
   if Copy(StockItemName,1,1) ='*' then
   begin
      StockItemName:=Copy(StockItemName,2,999);
      AdjustOnly:=True;
   end;
   StockUnitItem:=GetStockItem(Owner,StockItemName);
   if StockUnitItem <> nil then
   begin
      if AdjustOnly then
         StockUnitItem.TempAdjust:=StockUnitItem.TempAdjust+ByValue
      else
         StockUnitItem.Quantity:=StockUnitItem.Quantity+ByValue;
      Modified:=True;
      Result:=StockUnitItem.Quantity;
   end;              
end;
function TSiteStock.SetStockLevel(Owner,StockItemName:String;ToValue:Integer):Integer;
var
   StockUnitItem:TStockUnitItem;
begin
   Result:=0;
   StockUnitItem:=GetStockItem(Owner,StockItemName);
   if StockUnitItem <> nil then
   begin
      StockUnitItem.Quantity:=ToValue;
      Result:=StockUnitItem.Quantity;
      Modified:=True;
   end;
end;
procedure TSiteStock.CreateNewStockUnit(Owner,StockUnitTypeName:String);
var
   I:Integer;
   Index:Integer;
   StockUnitItem:TStockUnitItem;
   StockUnit:TStockUnit;
   StockUnitType:TStockUnitType;
   StockUnitTypeItem:TStockUnitItem;
begin       
   StockUnitType:=StockUnitTypes[StockUnitTypes.IndexOf(StockUnitTypeName)];
   if StockUnitType <> nil then
   begin
      StockUnit:=StockUnits[StockUnits.IndexOf(Owner)];
      if StockUnit = nil then
      begin
         StockUnit:=TStockUnit.Create(Owner);
         StockUnits.Add(StockUnit);
      end;
      for I:=0 to StockUnitType.Count-1 do
      begin
         StockUnitTypeItem:=StockUnitType[I];
         if StockUnitTypeItem <> nil then
         begin
            Index:=StockUnit.IndexOf(StockUnitTypeItem.Description);
            if Index = -1 then
               Index:=StockUnit.Add(TStockUnitItem.Create(StockUnitTypeItem.FStockItem,0,0,0,0));
            
            StockUnitItem:=StockUnit[Index];
            if StockUnitItem <> nil then
            begin
               StockUnitItem.Quantity :=0;
               StockUnitItem.MinLevel :=StockUnitTypeItem.MinLevel ;
               StockUnitItem.MaxLevel :=StockUnitTypeItem.MaxLevel ;
               StockUnitItem.NomLevel :=StockUnitTypeItem.NomLevel ;
               StockUnitItem.FStockItem:=StockUnitTypeItem.FStockItem;
            end;
         end; 
      end;      
      Modified:=True;
   end;
end;
procedure TSiteStock.DeleteStockUnit(Owner:String);
var
   I:Integer;
begin       
   StockUnits.Delete(StockUnits.IndexOf(Owner));
   I:=0;
   while I < StockTransfers.Count do
   begin
      if (StockTransfers[I].Owner = Owner) or (StockTransfers[I].TransferTo = Owner) then
         StockTransfers.Delete(I)
      else
         Inc(I);
   end;                                      
   Modified:=True;
end;
procedure TSiteStock.SetupStockTransfer(FromOwner,ToOwner,StockItemName:String;Quantity:Integer);
var
   I:Integer;
   Index:Integer;
   StockUnitItem:TStockUnitItem;
begin       
   for I:=0 to StockTransfers.Count-1 do
   begin
      if (StockTransfers[I].Owner = FromOwner) or (StockTransfers[I].TransferTo = ToOwner) then
      begin
         Index:=StockTransfers[I].IndexOf(StockItemName);
         if Index = -1 then
         begin
            StockUnitItem:=TStockUnitItem.Create(StockItems[StockItems.IndexOf(StockItemName)],0,0,0,0);
            Index:=StockTransfers[I].Add(StockUnitItem);
         end;
         StockTransfers[I][Index].Quantity:=Quantity;
         Modified:=True;
         Exit;
      end;
   end;
end;
procedure TSiteStock.TransferStock(FromOwner,ToOwner:String);
var
   I:Integer;
   StockTransfer:TStockUnit;
   FromStockUnit:TStockUnit;
   ToStockUnit:TStockUnit;
   TransferItem:TStockUnitItem;
   FromStockUnitItem:TStockUnitItem;
   ToStockUnitItem:TStockUnitItem;
begin
   if FromOwner = 'BlockUpdateStart' then
   begin
      AutoSave:=False;
   end
   else if FromOwner = 'BlockUpdateEnd' then
   begin
      if ComServer.StartMode <> smStandalone then
         AutoSave:=True;
      Modified:=Modified;
   end;

   for I:=0 to StockTransfers.Count-1 do
   begin
      if (StockTransfers[I].Owner = FromOwner) or (StockTransfers[I].TransferTo = ToOwner) then
      begin
         StockTransfer:=StockTransfers[I];
         FromStockUnit:=StockUnits[StockUnits.IndexOf(FromOwner)];
         if FromStockUnit <> nil then
         begin
            ToStockUnit:=StockUnits[StockUnits.IndexOf(ToOwner)];
            if ToStockUnit <> nil then
            begin
               while StockTransfer.Count > 0 do
               begin
                  TransferItem:=StockTransfer[0];
                  if TransferItem <> nil then
                  begin
                     FromStockUnitItem:=FromStockUnit[FromStockUnit.IndexOf(TransferItem.Description)];
                     ToStockUnitItem:=ToStockUnit[ToStockUnit.IndexOf(TransferItem.Description)];
                     if (FromStockUnitItem <> nil) and (ToStockUnitItem <> nil) then
                     begin
                        FromStockUnitItem.Quantity:=FromStockUnitItem.Quantity-TransferItem.Quantity;
                          ToStockUnitItem.Quantity:=  ToStockUnitItem.Quantity+TransferItem.Quantity;
                     end;
                  end;
                  StockTransfer.Delete(0);
               end;
               Modified:=True;
               Exit;
            end;
         end;
      end;
   end;
end;
procedure TSiteStock.ResetStockFor(Owner:String);
var
   StockUnitType:TStockUnitType;
   I:Integer;
   Value:Integer;
   Added:Boolean;
   TmpAutoSave:Boolean;
begin
   TmpAutoSave:=FAutoSave;
   FAutoSave:=False;
   Value:=StrToIntDef(GetGPCSRegString('','Empty Stock','0'),0);
   I:=FStockUnits.IndexOf(Owner);
   if I <> -1 then
   begin
      StockUnitType:=StockUnitTypes[StockUnitTypes.IndexOf('Clerk')];
      Added:=False;
      if StockUnitType <> nil then
      begin
         for I:=0 to StockUnitType.Count-1 do
         begin
            SetStockLevel(Owner,StockUnitType[I].Description,Value);
            Added:=True;
         end;
         if Added then Modified:=True;
      end;
   end;
   if TmpAutoSave then
   begin
      AutoSave:=TmpAutoSave;
      Modified:=Modified;
   end
end;
procedure TSiteStock.EmptySetUp(Owner:String);
var
   StockUnitType:TStockUnitType;
   I:Integer;
   Value:Integer;
   StockUnit:TStockUnit;
   Added:Boolean;
   TmpAutoSave:Boolean;
begin
  If Replace(Replace(Owner, '*', ''), '!', '') = 'All' then Exit;
   TmpAutoSave:=FAutoSave;
   FAutoSave:=False;
   Value:=StrToIntDef(GetGPCSRegString('','Empty Stock','0'),0);
   I:=FStockUnits.IndexOf(Owner);
   if I = -1 then
   begin
      Self.CreateNewStockUnit(Owner,'Clerk');
      StockUnitType:=StockUnitTypes[StockUnitTypes.IndexOf('Clerk')];
      if StockUnitType <> nil then
      begin
         for I:=0 to StockUnitType.Count-1 do
            SetStockLevel(Owner,StockUnitType[I].Description,Value);
         Modified:=True;
      end;
   end
   else
   begin
      StockUnit:=FStockUnits[I];
      StockUnitType:=StockUnitTypes[StockUnitTypes.IndexOf('Clerk')];
      Added:=False;
      if StockUnitType <> nil then
      begin
         for I:=0 to StockUnitType.Count-1 do
         begin
            if StockUnit.IndexOf(StockUnitType[I].Description) = -1 then
            begin
               SetStockLevel(Owner,StockUnitType[I].Description,Value);
               Added:=True;
            end;
         end;
         if Added then Modified:=True;
      end;
   end;
   if TmpAutoSave then
   begin
      AutoSave:=TmpAutoSave;
      Modified:=Modified;
   end
end;
procedure TSiteStock.AddNewStockItem(Description:String;Value:Currency;Group:String;PLU:Integer;AccountLine,AcctType,Report,ProgID,SUTypes:String);
var
   SL:TPackStringList;
   I:Integer;
   StockItem:TStockItem;
   SUType:TStockUnitType;
   Index:Integer;
begin
   Description := Trim( Description  );
   Group := Trim( Group );
   AccountLine := Trim( AccountLine );
   AcctType := Trim( AcctType );
   Report := Trim( Report );
   ProgID := Trim( ProgID );
   SUTypes := Trim( SUTypes );

   if Trim(Description) = '' then Exit;
   SL:=TPackStringList.Create;
   SL.CommaText:=SUTypes;
   Index:=StockItems.IndexOf(Description);
   if Index = -1 then
   begin
      StockItem:=TStockItem.Create(Description,Value,0);
      StockItem.Group:=Group;
      StockItem.AccountID :=AccountLine;
      StockItem.Agency    :=AcctType;
      StockItem.ReportLine:=Report;
      StockItem.PLU:=PLU;
      StockItem.ProgID:=ProgID;
      StockItem.Identifier:=StockItems.Add(StockItem);
      if SL.Count > 0 then
      begin
         for I:=0 to SL.Count-1 do
         begin
            Index:=StockUnitTypes.IndexOf(SL[I]);
            if Index = -1 then
            begin
               SUType:=TStockUnitType.Create(SL[I]);
               StockUnitTypes.Add(SUType);
            end
            else
            begin
               SUType:=StockUnitTypes[Index];
            end;
            if SUType.IndexOf(Description) = -1 then
            begin
               SUType.Add(TStockUnitItem.Create(StockItem,0,0,0,0));
            end
         end;
         for I:=0 to StockUnits.Count-1 do
            StockUnits[I].Add(TStockUnitItem.Create(StockItem,0,0,0,0));
      end;    
   end
   else // modify current item
   begin
      StockItem:=FStockItems[Index];
      StockItem.Price:=Value;
      StockItem.Group:=Group;
      StockItem.AccountID :=AccountLine;
      StockItem.Agency    :=AcctType;
      StockItem.ReportLine:=Report;
      StockItem.PLU:=PLU;
      StockItem.ProgID:=ProgID;
   end;
   SL.Free;
   Modified:=True;
end;
{TStockUnitType}       
constructor TStockUnitType.Create(Name:String);
begin
   inherited Create('Corvus');
   FName:=Name;
end;
procedure TStockUnitType.SaveToStream(Stream:TStream);
begin
   StrToStream(FName,Stream);
   inherited SaveToStream(Stream);
end;
procedure TStockUnitType.LoadFromStream(Stream:TStream);
begin
   FName:=StrFromStream(Stream);
   inherited LoadFromStream(Stream);
end;
{TStockUnitTypeList}
function TStockUnitTypeList.ListAll(SUTypeName,StockGroup:String):String;
var
  StockUnitType:TStockUnitType;
  StockItem:TStockItem;
  I:Integer;
  Res:TPackStringList;
begin
   Res:=TPackStringList.Create;
   StockUnitType:=Items[IndexOf(SUTypeName)];
   if StockUnitType <> nil then
   begin
      if Copy(StockGroup,1,1) = '!' then
      begin
         StockGroup:=Copy(StockGroup,2,999);
         for I:=0 to StockUnitType.Count-1 do
         begin
            if StockUnitType[I] <> nil then
            begin
               StockItem:=StockUnitType[I].FStockItem;
               if ((StockGroup = 'All') or (StockItem.Group <> StockGroup)) then
                  Res.Add('"'+StockItem.Description+'","0","'+CurrToStrF(StockItem.Price,ffNumber,2)+'","'+IntToStr(StockItem.PLU)+'","'+StockItem.ProgID+'"');
            end;
         end;
      end
      else
      begin
         for I:=0 to StockUnitType.Count-1 do
         begin
            if StockUnitType[I] <> nil then
            begin
               StockItem:=StockUnitType[I].FStockItem;
               if ((StockGroup = 'All') or (StockItem.Group = StockGroup)) then
                  Res.Add('"'+StockItem.Description+'","0","'+CurrToStrF(StockItem.Price,ffNumber,2)+'","'+IntToStr(StockItem.PLU)+'","'+StockItem.ProgID+'"');
            end;
         end;
      end;
   end;
   Result:=Res.CommaText;
   Res.Free;
end;
function TStockUnitTypeList.GetItem(Index:Integer):TStockUnitType;
begin
   Result:=TStockUnitType(inherited Items[Index]);
end;
function TStockUnitTypeList.Add(Item:TStockUnitType):Integer;
begin
   Result:=inherited Add(Item.Name,Item);
end;
procedure TStockUnitTypeList.LoadFromStream(Stream:TStream);
var
   I:Integer;
   ItemCount:Integer;
   StockUnitType:TStockUnitType;
begin
   ItemCount:=IntFromStream(Stream);
   for I:=0 to ItemCount-1 do
   begin
      StockUnitType:=TStockUnitType.Create('');
      StockUnitType.LoadFromStream(Stream);
      Add(StockUnitType);
   end;
end; 
end.
