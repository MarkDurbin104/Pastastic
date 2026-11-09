unit SharedStockU;
// /update c:\botswana\binary\stock.csv
interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,PackStrListU,GPCSGUID,StringUtil,IPCThrd,GPCSErrorLine,ParseNodeU;
const
   NumItems  = 2500;
   NumUsers  = 250;
   OneMinute = (1 / (24*60));
type
  String80 = String[80];
  String20 = String[20];
  String40 = String[40];
  PStockStruct = ^TStockStruct;
  TStockStruct = packed record
      Changed    :Integer;
      LastItem   :Integer;
      Description:Array[0..NumItems-1] of String80;
      PLU        :Array[0..NumItems-1] of String20;
      ProgID     :Array[0..NumItems-1] of String40;
      Price      :Array[0..NumItems-1] of Currency;
      Group      :Array[0..NumItems-1] of String40;
      Agency     :Array[0..NumItems-1] of String40;
      Owner      :Array[0..NumUsers-1]  of String40;
      Quantity   :Array[0..NumUsers-1,0..NumItems-1] of Integer;
      AdjustQty  :Array[0..NumUsers-1,0..NumItems-1] of Short;
  end;
  TAsssetsNode = class(TParseNode)
  end;
  TStock = class(TObject)
  private
     FStockStruct:PStockStruct;
     function  GetValue(ItemIndex,Index:Integer):Variant;
     procedure SetValue(ItemIndex,Index:Integer;Value:Variant);
     function  GetQuantity(UserIndex,ItemIndex:Integer):Integer;
     procedure SetQuantity(UserIndex,ItemIndex:Integer;Value:Integer);
     function  GetAdjQty(UserIndex,ItemIndex:Integer):Integer;
     procedure SetAdjQty(UserIndex,ItemIndex:Integer;Value:Integer);
     function  GetAvailQty(UserIndex,ItemIndex:Integer):Integer;
     function  FirstFreeItem:Integer;
     function  LastItem:Integer;
     function  FirstFreeUser:Integer;
     function LastUser:Integer;
  public
     constructor Create(BaseAddress:PStockStruct);
     procedure Clear;
     function  AddItem(Description,PLU,Group,Agency:String;Price:Currency;ProgId:String):Integer;
     procedure DeleteItem(Description:String);
     function  ItemCount:Integer;
     function  IndexOfItem(Description:String):Integer;
     function  AddUser(Name:String):Integer;
     procedure DeleteUser(Name:String);
     function  UserCount:Integer;
     function  IndexOfUser(Name:String):Integer;
     function  ListStock(Owner,StockGroups:String;Avail:Boolean):String;
     function  SaveIDS(FileName:String):Boolean;
     function  LoadIDS(FileName:String):String;
     function  ListAll(Owner,StockGroup:String):String;
     function  ListAvailable(Owner,StockGroup:String):String;
     property  Description[ItemIndex:Integer]:Variant index 0 read GetValue write SetValue;
     property  PLU        [ItemIndex:Integer]:Variant index 1 read GetValue write SetValue;
     property  ProgID     [ItemIndex:Integer]:Variant index 2 read GetValue write SetValue;
     property  Price      [ItemIndex:Integer]:Variant index 3 read GetValue write SetValue;
     property  Group      [ItemIndex:Integer]:Variant index 4 read GetValue write SetValue;
     property  Agency     [ItemIndex:Integer]:Variant index 5 read GetValue write SetValue;
     property  Owner      [ItemIndex:Integer]:Variant index 6 read GetValue write SetValue;
     property  Quantity   [UserIndex,ItemIndex:Integer]:Integer read GetQuantity write SetQuantity;
     property  AdjustQty  [UserIndex,ItemIndex:Integer]:Integer read GetAdjQty   write SetAdjQty  ;
     property  AvailQty   [UserIndex,ItemIndex:Integer]:Integer read GetAvailQty;
  end;
  TStockSortClass = class(TObject)
   public
     Stock:TStock;
     Description:String;
     Quantity:Integer;
     Index:Integer;
     constructor Create(Stk:TStock;Desc:String;Idx,Qty:Integer);
  end;
  TSharedFile = class(TObject)
  private
    FBasePointer     :Pointer;
    FileMappingHandle:THandle;
    FileHandle       :THandle;
    FileCreated      :Boolean;
  public
    constructor Create(FileName,Name:String;MaxFileSize:Integer;ClearFile,DontCreate:Boolean);
    destructor Destroy; override;
    property BasePointer:Pointer read FBasePointer;
    procedure PopulateFromOldStockDat(Stock:TStock;FileName:String);
  end;
  TSiteStock = class(TObject)
  private
     FSharedFile:TSharedFile;
     FStock:TStock;
     FShareLock:TMutex;
  public
     constructor Create;
     destructor Destroy; override;
     procedure Clear;
     function GetStockLevel(Owner,StockItemName:String):Integer;
     procedure ClearTempAdjustments(Owner:String);
     function AdjustStockLevel(Owner,StockItemName:String;ByValue:Integer):Integer;
     function SetStockLevel(Owner,StockItemName:String;ToValue:Integer):Integer;
     procedure CreateNewStockUnit(Owner,StockUnitTypeName:String);
     procedure DeleteStockUnit(Owner:String);
     procedure EmptySetUp(Owner:String);
     procedure ResetStockFor(Owner:String);
     procedure DeleteStockItemByName(Description:String);
     function  GetStockItemDetails(Description:String):String;
     procedure AddNewStockItem(Description:String;Value:Currency;Group:String;PLU:Integer;AccountLine,AcctType,Report,ProgID,SUTypes:String);
     property Stock:TStock read FStock;
  end;

function UpdateFromCSV(CSVFileName : String;SiteStock:TSiteStock) : Boolean;
procedure SaveToCSV(CSVFileName:String;SiteStock:TSiteStock);
                                                            
implementation
procedure SaveToCSV(CSVFileName:String;SiteStock:TSiteStock);
var
   SL,LSL:TStringList;
   I:Integer;
begin
   if SiteStock = nil then Exit;
   SL :=TStringList.Create;
   LSL:=TStringList.Create;
   for I:=0 to SiteStock.Stock.ItemCount-1 do
   begin
      if (not VarIsEmpty(SiteStock.Stock.Description[I])) and (SiteStock.Stock.Description[I] <> '') then
      begin
   //"Parking Tickets",0.00,Parking,0010000000,Magistrates,Receipt,"PARKING FINES","Product.ParkFine"
   //0=Description,1=Value,2=Group,3=PLU,4=AccountLine,5=AcctType,6=Report,7=ProgID
         SL.Add(SiteStock.Stock.Description[I]);
         SL.Add(CurrToStr(SiteStock.Stock.Price[I]));
         SL.Add(SiteStock.Stock.Group[I]);
         SL.Add(IntToStr(SiteStock.Stock.PLU[I])   );
         SL.Add('NotNeeded');
         SL.Add(SiteStock.Stock.Agency[I]);
         SL.Add('NotNeeded');
         SL.Add(SiteStock.Stock.ProgID[I]);
         SL.Add('Clerk');
         SL.Add('Supervisor');
         SL.Add('Declare');
         LSL.Add(SL.CommaText);
         SL.Clear;
      end;
   end;    
   SL .Free;
   LSL.SaveToFile(CSVFileName);
   LSL.Free;
end;
function UpdateFromCSV(CSVFileName:String;SiteStock:TSiteStock) : Boolean;
var
  TSL       : TPackStringList;
  CSVItems  : TPackStringList;
  CSVItem   : TPackStringList;
  I,J       : Integer;
begin
  Result := False;
  CSVItems  :=  TPackStringList.Create;
  CSVItem   :=  TPackStringList.Create;
  TSL       :=  TPackStringList.Create;
  If not FileExists(CSVFileName) then Exit;
  CSVItems.LoadFromFile(CSVFileName);
  for I:=0 to CSVItems.Count-1 do
  begin
    if Trim(CSVItems[I]) <> '' then
    begin
      CSVItem.CommaText:=CSVItems[I];
      TSL.CommaText:=CSVItems[I];     //stock unit types in pos 8,10,11...
      for J:=0 to 7 do TSL.Delete(0);
      //"Parking Tickets",0.00,Parking,0010000000,Magistrates,Receipt,"PARKING FINES","Product.ParkFine"
      //0=Description,1=Value,2=Group,3=PLU,4=AccountLine,5=AcctType,6=Report,7=ProgID
        If UpperCase(CSVItem[2]) = 'DELETE' then //delete group
          SiteStock.DeleteStockItemByName(CSVItem[0])
        else
          SiteStock.AddNewStockItem(CSVItem[0],StrToCurrDef(CSVItem[1],0),CSVItem[2],StrToIntDef(CSVItem[3],0),CSVItem[4],CSVItem[5],CSVItem[6],CSVItem[7],TSL.CommaText);
    end;
  end; //for all stock items in CSV file

  CSVItem.Free;
  CSVItems.Free;
  TSL.Free;
  Result := True;
end;

{TStockSortClass}
constructor TStockSortClass.Create(Stk:TStock;Desc:String;Idx,Qty:Integer);
begin
   Stock:=Stk;
   Description:=Desc;
   Index:=Idx;
   Quantity:=Qty;
end;
function IntFromStream(Stream:TStream):Integer ;
begin
   Stream.ReadBuffer(Result,SizeOf(Result));
end;
function CurFromStream(Stream:TStream):Currency;
begin
   Result:=IntFromStream(Stream) / 1000;
end;
function StrFromStream(Stream:TStream):String;
var
   Len:Integer;
begin
   Len:=IntFromStream(Stream);
   SetLength(Result,Len);
   Stream.ReadBuffer(Pointer(@Result[1])^,Len);
end;
{TStock}
constructor TStock.Create(BaseAddress:PStockStruct);
begin
   FStockStruct:=BaseAddress;
end;
function  TStock.GetValue(ItemIndex,Index:Integer):Variant;
begin
   Result:=Unassigned;
   if (ItemIndex < 0) or (ItemIndex >= NumItems) then Exit;
   case Index of
      0 : Result:=Trim(FStockStruct^.Description[ItemIndex]);
      1 : Result:=FStockStruct^.PLU        [ItemIndex];
      2 : Result:=FStockStruct^.ProgID     [ItemIndex];
      3 : Result:=FStockStruct^.Price      [ItemIndex];
      4 : Result:=FStockStruct^.Group      [ItemIndex];
      5 : Result:=FStockStruct^.Agency     [ItemIndex];
      6 : Result:=FStockStruct^.Owner      [ItemIndex];
   end;
end;
procedure TStock.SetValue(ItemIndex,Index:Integer;Value:Variant);
begin
   if (ItemIndex < 0) or (ItemIndex >= NumItems) then Exit;
   case Index of
      0 : FStockStruct^.Description[ItemIndex]:=Trim(Value);
      1 : FStockStruct^.PLU        [ItemIndex]:=Value;
      2 : FStockStruct^.ProgID     [ItemIndex]:=Value;
      3 : FStockStruct^.Price      [ItemIndex]:=Value;
      4 : FStockStruct^.Group      [ItemIndex]:=Value;
      5 : FStockStruct^.Agency     [ItemIndex]:=Value;
      6 : FStockStruct^.Owner      [ItemIndex]:=Value;
   end;
end;
function  TStock.GetQuantity(UserIndex,ItemIndex:Integer):Integer;
begin
   Result:=0;
   if (UserIndex < 0) or (UserIndex >= NumUsers) or (ItemIndex < 0) or (ItemIndex >= NumItems) then Exit;
   Result:=FStockStruct^.Quantity[UserIndex,ItemIndex];
end;
procedure TStock.SetQuantity(UserIndex,ItemIndex:Integer;Value:Integer);
begin
   if (UserIndex < 0) or (UserIndex >= NumUsers) or (ItemIndex >= NumItems) then Exit;
   FStockStruct^.Quantity[UserIndex,ItemIndex]:=Value;
end;
function  TStock.GetAdjQty(UserIndex,ItemIndex:Integer):Integer;
begin
   Result:=0;
   if (UserIndex < 0) or (UserIndex >= NumUsers) or (ItemIndex < 0) or (ItemIndex >= NumItems) then Exit;
   Result:=FStockStruct^.AdjustQty[UserIndex,ItemIndex];
end;
procedure TStock.SetAdjQty(UserIndex,ItemIndex:Integer;Value:Integer);
begin
   if (UserIndex < 0) or (UserIndex >= NumUsers) or (ItemIndex < 0) or (ItemIndex >= NumItems) then Exit;
   FStockStruct^.AdjustQty[UserIndex,ItemIndex]:=Value;
end;
function  TStock.GetAvailQty(UserIndex,ItemIndex:Integer):Integer;
begin
   Result:=0;
   if (UserIndex < 0) or (UserIndex >= NumUsers) or (ItemIndex < 0) or (ItemIndex >= NumItems) then Exit;
   Result:=Quantity[UserIndex,ItemIndex]+AdjustQty[UserIndex,ItemIndex];
end;

function TStock.FirstFreeItem:Integer;
var
   I:Integer;
begin
   Result:=-1;
   for I:=0 to NumItems-1 do
   begin
      if Trim(FStockStruct^.Description[I]) = '' then
      begin
         Result:=I;
         Exit;
      end;
   end;
end;
function TStock.LastItem:Integer;
var
   I:Integer;
begin
   Result:=-1;
   for I:=NumItems-1 downto 0 do
   begin
      if Trim(FStockStruct^.Description[I]) <> '' then
      begin
         Result:=I+1;
         Exit;
      end;
   end;
end;

function TStock.AddItem(Description,PLU,Group,Agency:String;Price:Currency;ProgID:String):Integer;
begin
  Result:=IndexOfItem(Description);
  if Result = -1 then
    Result:=FirstFreeItem;
  if Result >= 0 then
  begin
    FStockStruct^.Description[Result]:=Description;
    FStockStruct^.PLU        [Result]:=PLU;
    FStockStruct^.Price      [Result]:=Price;
    FStockStruct^.Group      [Result]:=Group;
    FStockStruct^.Agency     [Result]:=Agency;
    FStockStruct^.ProgID     [Result]:=ProgID;
  end;
end;
procedure TStock.DeleteItem(Description:String);
var
   Index:Integer;
begin
   Index:=IndexOfItem(Description);
   if Index >= 0 then
      FStockStruct^.Description[Index]:='';
end;
function TStock.ItemCount:Integer;
//var
//   I:Integer;
begin
   Result:=NumItems;
//   for I:=0 to NumItems-1 do
//      if FStockStruct^.Description[I] <> '' then
//        Inc(Result);
end;
function TStock.IndexOfItem(Description:String):Integer;
var
   I:Integer;
begin
   Result:=-1;
   for I:=0 to NumItems-1 do
   begin
      if Trim(FStockStruct^.Description[I]) = Trim(Description) then
      begin
         Result:=I;
         Exit;
      end;
   end;
end;
function TStock.LastUser:Integer;
var
   I:Integer;
begin
   Result:=-1;
   for I:=NumUsers-1 downto 0 do
   begin
      if FStockStruct^.Owner[I] <> '' then
      begin
         Result:=I+1;
         Exit;
      end;
   end;
end;

function TStock.FirstFreeUser:Integer;
var
   I:Integer;
begin
   Result:=-1;
   for I:=0 to NumUsers-1 do
   begin
      if FStockStruct^.Owner[I] = '' then
      begin
         Result:=I;
         Exit;
      end;
   end;
end;
function TStock.AddUser(Name:String):Integer;
var
   I:Integer;
begin
   Result:=IndexOfUser(Name);
   if Result = -1 then
      Result:=FirstFreeUser;
   if Result >= 0 then
   begin
      FStockStruct^.Owner[Result]:=Name;
      for I:=0 to NumItems-1 do
         FStockStruct^.Quantity[Result,I]:=0;
   end;
end;
procedure TStock.DeleteUser(Name:String);
var
   Index:Integer;
begin
   Index:=IndexOfUser(Name);
   if Index >= 0 then
      FStockStruct^.Owner[Index]:='';
end;
function TStock.UserCount:Integer;
begin
   Result:=NumUsers;
end;
function TStock.IndexOfUser(Name:String):Integer;
var
   I:Integer;
begin
   Result:=-1;
   for I:=0 to NumUsers-1 do
   begin
      if FStockStruct^.Owner[I] = Name then
      begin
         Result:=I;
         Exit;
      end;
   end;
end;
procedure TStock.Clear;
var
   I:Integer;
begin
   for I:=0 to NumItems-1 do FStockStruct^.Description[I]:='';
   for I:=0 to NumUsers-1 do FStockStruct^.Owner[I]:='';
end;
function StockListSort(Item1,Item2: Pointer):Integer;
var
   A,B:TStockSortClass;
   G1,G2:String;
   I1,I2:Integer;
   C1,C2:Currency;
begin
   A:=TStockSortClass(Item1);
   B:=TStockSortClass(Item2);

   If GetGPCSRegString('', 'Stock Alpha Sort', '0') = '1' then
   begin
     Result:=StrComp(PChar(A.Description),PChar(B.Description));
   end
   else
   begin
     G1:=UpperCase(A.Stock.Group[A.index]); 
     G2:=UpperCase(B.Stock.Group[B.index]);
     if G1 = 'STAMPS' then G1:='*'+G1;
     if G2 = 'STAMPS' then G2:='*'+G2;
     Result:=StrComp(PChar(G1),PChar(G2));
     if Result = 0 then
     begin
        I1:=A.Stock.PLU[A.index];
        I2:=B.Stock.PLU[B.index];
        if I1 < I2 then
          Result:=-1
        else if I1 > I2 then
          Result:=1
        else
        begin
           C1:=A.Stock.Price[A.index];
           C2:=B.Stock.Price[B.index];
           if C1 < C2 then
             Result:=-1
           else if C1 > C2 then
             Result:=1;
        end;
     end;
     if Result = 0 then
        Result:=StrComp(PChar(A.Description),PChar(B.Description));
   end;
end;
function TStock.LoadIDS(FileName:String):String;
var
   AsssetsNode:TAsssetsNode;
   StockItems:TCorvusNode;
   StockUnits:TCorvusNode;
   Node:TCorvusNode;
   ItemNode:TCorvusNode;
   UserNode:TCorvusNode;
   ItemsNode:TCorvusNode;
   I,J,UserIndex,ItemIndex:Integer;
   Description:String;
   Group      :String;
   Agency     :String;
   ProgID     :String;
   PLU        :String;
   Price      :Currency;
   SL:TPackStringList;
begin
   Result:='';
   if not FileExists(FileName) then Exit;
   SL:=TPackStringList.Create;
   try
      SL.LoadFromFile(FileName);
   except
      SL.Free;
      Exit;
   end;
   Result:=SL.PackText;
   AsssetsNode:=TAsssetsNode.Create('Asssets',FileName,1);
   if AsssetsNode = nil then Exit;
   AsssetsNode.ParseFile(ExtractFilePath(FileName),FileName,1);
   StockItems:=AsssetsNode.NodeNamed('StockItems');
   if StockItems <> nil then
   begin
      Clear;
      for I:=0 to StockItems.Count-1 do
      begin
         ItemNode:=TCorvusNode(StockItems.Objects[I]);
         if ItemNode <> nil then
         begin
            Node:=ItemNode.NodeNamed('Description'); if Node <> nil then Description:=Node[0] else Description:='';
            Node:=ItemNode.NodeNamed('Group'      ); if Node <> nil then Group      :=Node[0] else Group      :='';
            Node:=ItemNode.NodeNamed('Agency'     ); if Node <> nil then Agency     :=Node[0] else Agency     :='';
            Node:=ItemNode.NodeNamed('ProgID'     ); if Node <> nil then ProgID     :=Node[0] else ProgID     :='';
            Node:=ItemNode.NodeNamed('PLU'        ); if Node <> nil then PLU        :=Node[0] else PLU        :='';
            Node:=ItemNode.NodeNamed('Price'      ); if Node <> nil then Price      :=StrToCurrDef(Node[0],0) else Price:=0;
            if Description <> '' then
               AddItem(Description,PLU,Group,Agency,Price,ProgID);
         end;
      end;
      StockUnits:=AsssetsNode.NodeNamed('StockUnits');
      if StockUnits <> nil then
      begin
         for I:=0 to StockUnits.Count-1 do
         begin
            UserNode:=TCorvusNode(StockUnits.Objects[I]);
            if UserNode <> nil then
            begin
               UserIndex:=AddUser(UserNode.Name);
               ItemsNode:=UserNode.NodeNamed('Items');
               if ItemsNode <> nil then
               begin
                  for J:=0 to ItemsNode.Count-1 do
                  begin
                     ItemNode:=TCorvusNode(ItemsNode.Objects[J]);
                     if ItemNode <> nil then
                     begin
                        Node:=StockItems.NodeNamed(ItemNode.Name);
                        if Node <> nil then
                        begin
                           Node:=Node.NodeNamed('Description');
                           if Node <> nil then
                           begin
                              ItemIndex:=IndexOfItem(Node[0]);
                              if ItemIndex >= 0 then
                              begin
                                 SetQuantity(UserIndex,ItemIndex,StrToIntDef(ItemNode[0],0));
                                 SetAdjQty(UserIndex,ItemIndex,0);
                              end;
                           end;
                        end;
                     end;
                  end;
               end;
            end;
         end;
      end;           
   end;           
   AsssetsNode.Free;
end;           
function TStock.SaveIDS(FileName:String):Boolean;
var
   SL:TStringList;
   I,J:Integer;
   MaxItem,MaxUnit:Integer;
begin            
   try
      SL:=TStringList.Create;
      MaxItem:=LastItem;
      SL.Add('StockItems {');
      for I:=0 to MaxItem-1 do    
      begin
         if Description[I] <> '' then
         begin
            SL.Add('   Item'+IntToStr(I)+' {');
            SL.Add('      Description { '''+Description[I]+''' }');
            SL.Add('      Group       { '''+Group [I]     +''' }');
            SL.Add('      Agency      { '''+Agency[I]     +''' }');
            SL.Add('      ProgID      { '''+ProgID[I]     +''' }');
            SL.Add('      PLU         { '  +PLU   [I]     +' }');
            SL.Add('      Price       { '+CurrToStrF(Price[I],ffFixed,2)+' }');
            SL.Add('   }');
         end;
      end;
      SL.Add('}');
   
      MaxUnit:=LastUser;
      SL.Add('StockUnits {');
      for J:=0 to MaxUnit-1 do
      begin
         SL.Add('   '+Owner[J]+' {');
         SL.Add('      Items {');
         for I:=0 to MaxItem-1 do    
         begin
            if Quantity[J,I] <> 0 then
            begin
               SL.Add('         Item'+IntToStr(I)+' { '+IntToStr(Quantity[J,I])+' } // '+Description[I]);
            end;
         end;
         SL.Add('      }');
         SL.Add('   }');
      end;
      SL.Add('}');
   
      SL.SaveToFile(FileName);
      Result:=True;
   except
      on E:Exception do
      begin
         RaiseGUIDException('{5A097ACC-7D87-4F3E-90A6-46BA9D30CDAB}',E);
         Result:=False;
      end;
   end;
end;             

function TStock.ListStock(Owner,StockGroups:String;Avail:Boolean):String;
var
  SI,
  ItemIdx,I,Qty,
  UnitIdx        : Integer;
  StockList      : TStringList;
  OrderedList    : TList;   //list of stock items in order
  Res            : TPackStringList;
  ReportCash     : Boolean;
  StockGroupsList: TStringObject; //list of stockgroups
  IncludedGroups : TStringObject; //groups to be included in result (eg "Stamps")
  ExcludedGroups : TStringObject; //groups to be excluded from result (eg "!CashAcc,!CashDenoms")
  AgencyGroups   : TStringObject; //agencies to be included in the result
  MaxItem:Integer;
  MaxUser:Integer;
  SL:TStringList;
begin
  Result:='';
  StockList       := TStringList.Create;
  OrderedList     := TList.Create;
  Res             := TPackStringList.Create;
  ExcludedGroups  := TStringObject.Create('');
  IncludedGroups  := TStringObject.Create('');
  AgencyGroups    := TStringObject.Create('');
  StockGroupsList := TStringObject.Create(Stockgroups);
    SL:=TStringList.Create;

  try
    //determine excluded, agency and included groups (eg, "!CashAcc,*Stamps,CashDenoms")
    While StockGroupsList.Strings.Count > 0 do
    begin
      If LeftOf(StockGroupsList.Strings[0],'!') then
        ExcludedGroups.Strings.Add(Copy(StockGroupsList.Strings[0],2,999))
      else if LeftOf(StockGroupsList.Strings[0],'*') then
        AgencyGroups.Strings.Add(Copy(StockGroupsList.Strings[0],2,999))
      else
        IncludedGroups.Strings.Add(StockGroupsList.Strings[0]);
      StockGroupsList.Strings.Delete(0);
    end;
    //if only exclusions define return all groups but exclusions
    If (IncludedGroups.Strings.Count = 0) and (AgencyGroups.Strings.Count = 0) then
      IncludedGroups.Strings.Add('All');

    //determine cash reporting
    ReportCash:= not AgencyGroups.ContainsString('All'); //don't report cash for all stock

    //show stock for all/selected users
    If   Owner = 'All' then
       UnitIdx := 0
    else
       UnitIdx := IndexOfUser(Owner); //specific
    MaxItem:=LastItem;
    MaxUser:=LastUser;
    While ((Owner = 'All') and (UnitIdx <= MaxUser))
    or    ( UnitIdx = IndexOfUser(Owner) ) do
    begin
      
      SL.Add('-----------------------------------------------------------------------------------');
      SL.Add('Stock for User '+Self.Owner[UnitIdx]);
      SL.Add('-----------------------------------------------------------------------------------');
      for ItemIdx := 0 to MaxItem do //all stock items in this unit
      begin
        if  ( ReportCash
              or
              ( (Group[ItemIdx] <> 'Cash')
                and
                (not LeftOf(Group[ItemIdx],'CashDenom'))
              )
            )  //handle cash reporting
        and ((not Avail) or (Quantity[UnitIdx,ItemIdx] > 0))      //only items in stock (unless Avail flag unset)
        and (    (IncludedGroups.ContainsString('All'))           //all groups required
              or (AgencyGroups.ContainsString('All'))             //or all agencies required
              or (IncludedGroups.ContainsString(Group[ItemIdx]))  //or this group required explicitly
              or (AgencyGroups.ContainsString(Agency[ItemIdx]))   //or this agency required explicitly
            )
        and (not ExcludedGroups.ContainsString(Group[ItemIdx]))   //group not excluded
        then
        begin
          if Description[ItemIdx] <> '' then 
          begin
             SI:=StockList.IndexOf(Description[ItemIdx]);  //check whether stockitem is already in the list
             if SI = -1 then
                StockList.AddObject(Description[ItemIdx],TObject(AvailQty[UnitIdx,ItemIdx]))
             else
                StockList.Objects[SI]:=TObject(Integer(StockList.Objects[SI])+AvailQty[UnitIdx,ItemIdx]);
             SL.Add(Description[ItemIdx]+IntToStr(AvailQty[UnitIdx,ItemIdx]));
          end; //stockitem quantity accumulation
        end;  //if stockitem matches criteria
      end; //for all stockitems in unit
      Inc(UnitIdx);
    end;
    SL.SaveToFile('C:\StockList.txt');
    SL.Free;

    //order this group by description
    OrderedList.Clear;
     
    for I := 0 to StockList.Count-1 do
       OrderedList.Add(TStockSortClass.Create(Self,StockList[I],IndexOfItem(StockList[I]),Integer(StockList.Objects[I])));
    OrderedList.Sort(StockListSort);
    for I := 0 to OrderedList.Count-1 do
    begin
       ItemIdx:=IndexOfItem(TStockSortClass(OrderedList[I]).Description);
       Qty:=TStockSortClass(OrderedList[I]).Quantity;
       //when viewing available stock
       //do not list cashstock because already handled by 'cash on hand' code
       If (ProgID[ItemIdx]  <> 'Product.CashStock')  //any other stock item
       or (Avail = False) //or viewing a full stock list
       then
          Res.Add('"'+Description[ItemIdx]+'","'+IntToStr(Qty)+'","'+CurrToStrF(Price[ItemIdx],ffNumber,2)+'","'+PLU[ItemIdx]+'","'+ProgID[ItemIdx]+'"');
    end;
  finally
    IncludedGroups.Free;
    AgencyGroups.Free;
    ExcludedGroups.Free;
    OrderedList.Free;
    StockList.Free;
    StockGroupsList.Free;
    Result:=Res.CommaText;
    Res.Free;
  end;
end;
function TStock.ListAll(Owner,StockGroup:String):String;
begin
   Result:=ListStock(Owner,StockGroup,False);
end;
function TStock.ListAvailable(Owner,StockGroup:String):String;
begin
   Result:=ListStock(Owner,StockGroup,True);
end;

{TSiteStock}
constructor TSiteStock.Create;
var
   DT:TDateTime;
   RetryCount:Integer;
   SystemName,FilePath:String;
begin
   inherited Create;
   RetryCount:=0;
   FShareLock:=nil;
   while (FShareLock = nil) and (RetryCount < 10) do
   begin
      Inc(RetryCount);
      DT:=Now+OneMinute;
      while (FShareLock = nil) and (Now < DT) do
      begin
         try
            FShareLock:=TMutex.Create('StockSharedFileLock');
         except
            FShareLock:=nil;
            Sleep(1000);
         end;
         if FShareLock = nil then
            Windows.Beep(2000,200);
      end;
      if FShareLock = nil then
      begin
         RaiseGUIDError('{D74BBAEA-A5A6-4CFE-8ED0-80BA4BC498F9}','Unable to get StockMutex');
      end;
   end;
   if FShareLock = nil then
   begin
      RaiseGUIDError('{D74BBAEA-A5A6-4CFE-8ED0-80BA4BC498F9}','Unable to get StockMutex - Aborting');
      Abort;
   end;
   
   FilePath:=ApplicationRootPath;
   SystemName:=GetGPCSRegString('','System Name','');
   if SystemName = 'Tanzania Post' then
      SystemName:='Tan'
   else if Pos(' ',SystemName) > 0 then
      SystemName:=Copy(SystemName,1,Pos(' ',SystemName)-1);
   if SystemName <> '' then
      FilePath:='C:\'+SystemName+'\Binary\';
      
   if FileExists(FilePath+'SharedStock.dat') then
   begin
      FSharedFile:=TSharedFile.Create(FilePath+'SharedStock.dat','SharedFile',SizeOf(TStockStruct),False,False);
      FStock:=TStock.Create(FSharedFile.BasePointer);
   end
   else
   begin
      FSharedFile:=TSharedFile.Create(FilePath+'SharedStock.dat','SharedFile',SizeOf(TStockStruct),False,False);
      FStock:=TStock.Create(FSharedFile.BasePointer);
      FSharedFile.PopulateFromOldStockDat(FStock,FilePath+'Stock.dat');
      if FileExists(FilePath+'Stock.csv') then
      begin
         UpdateFromCSV(FilePath+'Stock.csv',Self);
      end;
   end;
   if FileExists(FilePath+'UpdateStock.csv') then
   begin
      Windows.Beep(2000,2000);
      UpdateFromCSV(FilePath+'UpdateStock.csv',Self);
      DeleteFile(FilePath+'UpdateStock.csv');
   end;
end;
destructor TSiteStock.Destroy;
begin
   FShareLock.Free;
   FShareLock:=nil;
   FStock.Free;
   FStock:=nil;
   FSharedFile.Free;
   FSharedFile:=nil;
   inherited Destroy;
end;
function TSiteStock.GetStockItemDetails(Description:String):String;
var
   Index:Integer;
   SL:TStringList;
begin
   Result:='';
   Index:=FStock.IndexOfItem(Description);
   if Index <> -1 then
   begin
      SL:=TStringList.Create;
      SL.Add(FStock.Description[Index]);
      SL.Add(FStock.Price      [Index]);
      SL.Add(FStock.Group      [Index]);
      SL.Add(FStock.Agency     [Index]);
      SL.Add(FStock.Agency     [Index]);
      SL.Add(FStock.Agency     [Index]);
      SL.Add(FStock.PLU        [Index]);
      SL.Add(FStock.ProgID     [Index]);
      Result:=SL.CommaText;
      SL.Free;
   end;
end;
procedure TSiteStock.AddNewStockItem(Description:String;Value:Currency;Group:String;PLU:Integer;AccountLine,AcctType,Report,ProgID,SUTypes:String);
var
   DontRelease:Boolean;
begin
   DontRelease:=False;
   if FShareLock.CurrentlyHaveMutex then
   begin
      DontRelease:=True;
   end
   else if not FShareLock.Get(1000) then
   begin
      RaiseGUIDError('{F3B6D0A9-C916-451C-A690-7F8DA7ADFABF}','Can''t get Stock File Mutex short wait');
      FShareLock.Get(INFINITE);
   end;
   try
      FStock.AddItem(Description,IntToStr(PLU),Group,AcctType,Value,ProgID);
   finally
      if not DontRelease then
         FShareLock.Release;
   end;
end;
procedure TSiteStock.DeleteStockItemByName(Description:String);
var
   DontRelease:Boolean;
begin
   DontRelease:=False;
   if FShareLock.CurrentlyHaveMutex then
   begin
      DontRelease:=True;
   end
   else if not FShareLock.Get(1000) then
   begin
      RaiseGUIDError('{F3B6D0A9-C916-451C-A690-7F8DA7ADFABF}','Can''t get Stock File Mutex short wait');
      FShareLock.Get(INFINITE);
   end;
   try
      FStock.DeleteItem(Description);
   finally
      if not DontRelease then
         FShareLock.Release;
   end;
end;
procedure TSiteStock.Clear;
begin
   FStock.Clear;
end;
function TSiteStock.GetStockLevel(Owner,StockItemName:String):Integer;
var
   ItemIndex:Integer;
   UserIndex:Integer;
begin
   ItemIndex:=FStock.IndexOfItem(StockItemName);
   UserIndex:=FStock.IndexOfUser(Owner);
   Result:=FStock.AvailQty[UserIndex,ItemIndex];
end;
procedure TSiteStock.ClearTempAdjustments(Owner:String);
var
   I:Integer;
   UserIndex:Integer;
   DontRelease:Boolean;
begin
   DontRelease:=False;
   if FShareLock.CurrentlyHaveMutex then
   begin
      DontRelease:=True;
   end
   else if not FShareLock.Get(1000) then
   begin
      RaiseGUIDError('{9AC424BF-DFBE-4886-A8D4-99947AA30699}','Can''t get Stock File Mutex short');
      FShareLock.Get(INFINITE);
   end;
   try
      UserIndex:=FStock.IndexOfUser(Owner);
      if UserIndex >= 0  then
      begin
         for I:=0 to NumItems-1 do
            FStock.AdjustQty[UserIndex,I]:=0;
      end;
// ?      if Owner <> 'Supervisor' then
// ?        ClearTempAdjustments('Supervisor');
   finally
      if not DontRelease then
         FShareLock.Release;
   end;
end;
procedure LogStock(LogLine:String);
var
   FileStream:TFileStream;
const
   FFileName:String = 'C:\StockChanges.log';
begin
  Exit; //stock logging off
   LogLine:=DateTimeToStr(Now)+' '+LogLine+#13#10;
   // open existing file
   try
      FileStream:=TFileStream.Create(FFileName,fmOpenReadWrite or fmShareExclusive);
   except
      FileStream:=nil;
   end;
   // failed - try to create
   try
      if FileStream = nil then 
         FileStream:=TFileStream.Create(FFileName,fmCreate or fmShareExclusive);
   except
      FileStream:=nil;
   end;
      
   // failed - give up !
   if FileStream = nil then Exit;
   FileStream.Position:=FileStream.Size; 
   FileStream.Write(Pointer(LogLine)^,Length(LogLine));
   FileStream.Free;
end;
function TSiteStock.AdjustStockLevel(Owner,StockItemName:String;ByValue:Integer):Integer;
var
   UserIndex:Integer;
   ItemIndex:Integer;
   AdjustOnly:Boolean;
   DontRelease:Boolean;
begin
   Result:=0;
   DontRelease:=False;
   if FShareLock.CurrentlyHaveMutex then
   begin
      DontRelease:=True;
   end
   else if not FShareLock.Get(1000) then
   begin
      RaiseGUIDError('{DFE6F154-F465-453A-819C-42D6613E92D2}','Can''t get Stock File Mutex short');
      FShareLock.Get(INFINITE);
   end;
   try
      AdjustOnly:=False;
      if Copy(StockItemName,1,1) ='*' then
      begin
         StockItemName:=Copy(StockItemName,2,999);
         AdjustOnly:=True;
      end;
      UserIndex:=FStock.IndexOfUser(Owner);
      ItemIndex:=FStock.IndexOfItem(StockItemName);
      if (UserIndex >= 0) and (ItemIndex >= 0)  then
      begin
         if AdjustOnly then
            FStock.AdjustQty[UserIndex,ItemIndex]:=FStock.AdjustQty[UserIndex,ItemIndex]+ByValue
         else
            FStock.Quantity[UserIndex,ItemIndex]:=FStock.Quantity[UserIndex,ItemIndex]+ByValue;
         Result:=FStock.AvailQty[UserIndex,ItemIndex];
         if AdjustOnly then
            LogStock('Adjust '+ Owner +','+IntToStr(FStock.IndexOfUser(Owner))+') Item('+
               StockItemName+','+IntToStr(FStock.IndexOfItem(StockItemName))+') By Value = '+
               IntToStr(ByValue))
         else
            LogStock('Use    '+ Owner +','+IntToStr(FStock.IndexOfUser(Owner))+') Item('+
               StockItemName+','+IntToStr(FStock.IndexOfItem(StockItemName))+') By Value = '+
               IntToStr(ByValue))
      end         
      else
      begin
         RaiseGUIDError('{8074DC93-DAFA-43C4-9F71-66BB18967410}',
           'Can''t Adjust Stock Level User('+
            Owner        +','+IntToStr(FStock.IndexOfUser(Owner))+') Item('+
            StockItemName+','+IntToStr(FStock.IndexOfItem(StockItemName))+') By Value = '+
            IntToStr(ByValue));
      end;
   except
      on E:Exception do
         RaiseGUIDException('{A7B98FF2-A551-4AEB-92AD-8267142FD607}',E);
   end;
   if not DontRelease then
      FShareLock.Release;
end;
function TSiteStock.SetStockLevel(Owner,StockItemName:String;ToValue:Integer):Integer;
var
   UserIndex:Integer;
   ItemIndex:Integer;
   DontRelease:Boolean;
begin
   DontRelease:=False;
   if FShareLock.CurrentlyHaveMutex then
   begin
      DontRelease:=True;
   end
   else if not FShareLock.Get(1000) then
   begin
      RaiseGUIDError('{76506163-0925-4707-9D6E-D34B64EBD3F5}','Can''t get Stock File Mutex short');
      FShareLock.Get(INFINITE);
   end;
   try
      Result:=0;
      UserIndex:=FStock.IndexOfUser(Owner);
      ItemIndex:=FStock.IndexOfItem(StockItemName);
      if (UserIndex >= 0) and (ItemIndex >= 0)  then
      begin
         FStock.Quantity[UserIndex,ItemIndex]:=FStock.Quantity[UserIndex,ItemIndex]+ToValue;
         Result:=FStock.Quantity[UserIndex,ItemIndex];
      end;
   finally
      if not DontRelease then
         FShareLock.Release;
   end;
end;
procedure TSiteStock.CreateNewStockUnit(Owner,StockUnitTypeName:String);
var
//   I:Integer;
   DontRelease:Boolean;
//   SL:TStringList;
begin
   DontRelease:=False;
   if FShareLock.CurrentlyHaveMutex then
   begin
      DontRelease:=True;
   end
   else if not FShareLock.Get(1000) then
   begin
      RaiseGUIDError('{36CB2652-7D0F-49C2-AFC1-6870ADC2C0C9','Can''t get Stock File Mutex short');
      FShareLock.Get(INFINITE);
   end;
   try
      FStock.AddUser(Owner);
   finally
      if not DontRelease then
         FShareLock.Release;
   end;
end;
procedure TSiteStock.DeleteStockUnit(Owner:String);
var
   DontRelease:Boolean;
begin
   DontRelease:=False;
   if FShareLock.CurrentlyHaveMutex then
   begin
      DontRelease:=True;
   end
   else if not FShareLock.Get(1000) then
   begin
      RaiseGUIDError('{472173BE-E05B-4EA1-8F33-8DEA348B45C2}','Can''t get Stock File Mutex short');
      FShareLock.Get(INFINITE);
   end;
   try
      FStock.DeleteUser(Owner);
   finally
      if not DontRelease then
         FShareLock.Release;
   end;
end;
procedure TSiteStock.ResetStockFor(Owner:String);
var
   DontRelease:Boolean;
begin
   DontRelease:=False;
   if FShareLock.CurrentlyHaveMutex then
   begin
      DontRelease:=True;
   end
   else if not FShareLock.Get(1000) then
   begin
      RaiseGUIDError('{9B2E61F2-022E-43E3-ADDC-38A022733755}','Can''t get Stock File Mutex short');
      FShareLock.Get(INFINITE);
   end;
   try
      FStock.DeleteUser(Owner);
      FStock.AddUser(Owner);
   finally
      if not DontRelease then
         FShareLock.Release;
   end;
end;
procedure TSiteStock.EmptySetUp(Owner:String);
var
   I,J:Integer;
   Value:Integer;
   MaxItem:Integer;
   DontRelease:Boolean;
begin
   If Replace(Replace(Owner, '*', ''), '!', '') = 'All' then Exit;
   Value:=StrToIntDef(GetGPCSRegString('','Empty Stock','0'),0);
   DontRelease:=False;
   if FShareLock.CurrentlyHaveMutex then
   begin
      DontRelease:=True;
   end
   else if not FShareLock.Get(1000) then
   begin
      RaiseGUIDError('{9C2046CD-6BB0-40A5-B0A5-D428D89F8C43}','Can''t get Stock File Mutex short');
      FShareLock.Get(INFINITE);
   end;
   try
      I:=FStock.IndexOfUser(Owner);
      if I = -1 then
      begin
         I:=FStock.AddUser(Owner);
         MaxItem:=FStock.LastItem;
         for J:=0 to MaxItem do
            FStock.Quantity[I,J]:=Value;
      end;
   finally
      if not DontRelease then
         FShareLock.Release;
   end;
end;

{TSharedFile}
constructor TSharedFile.Create(FileName,Name:String;MaxFileSize:Integer;ClearFile,DontCreate:Boolean);
begin
   FBasePointer     :=nil;
   FileHandle       :=0;
   FileCreated:=False;
   FileMappingHandle:=OpenFileMapping(FILE_MAP_ALL_ACCESS,True,PChar(Name));

   if (FileMappingHandle = 0) and (DontCreate) then Abort;

   if (FileMappingHandle = 0) then
   begin
      if not FileExists(FileName) then ClearFile:=True;
      FileHandle:=CreateFile(PChar(FileName),GENERIC_READ or GENERIC_WRITE,
                     FILE_SHARE_READ or FILE_SHARE_WRITE,nil,OPEN_ALWAYS,
                     FILE_ATTRIBUTE_NORMAL,0);
      FileMappingHandle:=CreateFileMapping(FileHandle,nil,PAGE_READWRITE,
                                           0,MaxFileSize,PChar(Name));
      FileCreated:=True;
   end;
   FBasePointer:=MapViewOfFile(FileMappingHandle,FILE_MAP_ALL_ACCESS,0,0,0);
   if FileCreated and ClearFile then ZeroMemory(FBasePointer,MaxFileSize);
end;

destructor TSharedFile.Destroy;
begin
   if FBasePointer      <> nil then begin UnmapViewOfFile(FBasePointer);   FBasePointer     :=nil; end;
   if FileMappingHandle <> 0   then begin CloseHandle(FileMappingHandle);  FileMappingHandle:=0  ; end;
   if FileHandle        <> 0   then begin CloseHandle(FileHandle);         FileHandle       :=0  ; end;
   FBasePointer:=nil;
   inherited Destroy;
end;
procedure TSharedFile.PopulateFromOldStockDat(Stock:TStock;FileName:String);
var
   FileStream:TFileStream;
   I,J:Integer;
   S:String;
   Count,ItemCount:Integer;
   TempList:TStringList;
   Qty,AdjQty,ItemIndex:Integer;
begin
   if FileExists(FileName) then
   begin
      TempList:=TStringList.Create;

      FileStream:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyNone);
      // Stock Items
      ItemCount:=0;
      FileStream.ReadBuffer(Count,SizeOf(Count));
      for I:=0 to Count-1 do
      begin
         S:=StrFromStream(FileStream);
         if S <> '' then
         begin
            Stock.Description[ItemCount]:=S;
            Stock.Price      [ItemCount]:=Currency(CurFromStream(FileStream));
            //Stock.Identifier [ItemCount]:IntFromStream(FileStream);
            TempList.Add( IntToStr( IntFromStream(FileStream) ) );
           {Stock.AccountID  [ItemCount]:}StrFromStream(FileStream);
            Stock.Group      [ItemCount]:=StrFromStream(FileStream);
            Stock.PLU        [ItemCount]:=IntFromStream(FileStream);
            Stock.ProgID     [ItemCount]:=StrFromStream(FileStream);
            Stock.Agency     [ItemCount]:=StrFromStream(FileStream);
           {Stock.ReportLine [ItemCount]:}StrFromStream(FileStream);
           Inc(ItemCount);
         end
         else
         begin
            CurFromStream(FileStream);
            IntFromStream(FileStream);
            StrFromStream(FileStream);
            StrFromStream(FileStream);
            IntFromStream(FileStream);
            StrFromStream(FileStream);
            StrFromStream(FileStream);
            StrFromStream(FileStream);
         end;
      end;
      // Stock Units
      FileStream.ReadBuffer(Count,SizeOf(Count));
      for I:=0 to Count-1 do
      begin
         Stock.Owner     [I]:=StrFromStream(FileStream);
        {Stock.TransferTo[I]:}StrFromStream(FileStream);
         ItemCount        :=IntFromStream(FileStream);
         for J:=0 to ItemCount-1 do
         begin
            Qty:= IntFromStream(FileStream);
            AdjQty:= IntFromStream(FileStream);
           {Stock.MinLevel [I,J]:}IntFromStream(FileStream);
           {Stock.MaxLevel [I,J]:}IntFromStream(FileStream);
           {Stock.NomLevel [I,J]:}IntFromStream(FileStream);
           ItemIndex:=IntFromStream(FileStream);
           Stock.Quantity [I, TempList.IndexOf( IntToStr(ItemIndex) ) ]:=Qty;
           Stock.AdjustQty[I, TempList.IndexOf( IntToStr(ItemIndex) ) ]:=AdjQty;
         end;
      end;
      FileStream.Free;
      TempList.Free;
   end;
end;

end.
