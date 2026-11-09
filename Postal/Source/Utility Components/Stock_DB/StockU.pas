unit StockU;

interface

uses
  DB,
  StockData,
  StringUtil,
  GPCSErrorLine,
  SysUtils, Classes,GPCSGUID,PackStrListU;

const
   TextSave:Boolean = True;

type

  //StatusItem =( sNew, sNone, sModified, sDeleted );
  TStockFiles =( tStockItems, tStockUnits, tStockUnitTypes, tStockTransfers ) ;
  TStockUnitItemsFields =( tsTempAdjust,tsQuantity, tsMinLevel, tsMaxLevel, tsNomLevel, tsTQuantity,  tsDescription, tsPrice,
                           tsGroup, tsAgency, tsPLU, tsProgID  );


  SetStockFiles = Set of TStockFiles ;
  SetStockUnitItemsFields = Set of TStockUnitItemsFields ;

  TStockUnit = class ;

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

  TStockItem = class(TListItem)
  private
     FDescription:String  ;
     FPrice      :Currency;
     FPLU        :Integer ;
     FProgID     :String  ;
     FAccountID  :String  ;
     FGroup      :String  ;
     FIdentifier :Integer ;
     FAgency     :String ;
     FReportLine :String ;
     //FStatus     : StatusItem ;
  public
     constructor Create(Description:String;Price:Currency;Identifier:Integer);
     procedure Save ; //ToStream(Stream:TStream); //override;
     procedure LoadFromStream(Stream:TStream); override;
     procedure Load ;
     procedure DeleteRecord ;
     property Description:String   read FDescription  write FDescription;
     property Price     :Currency read FPrice         write FPrice      ;
     property Identifier:Integer  read FIdentifier    write FIdentifier ;
     property AccountID :String     read FAccountID   write FAccountID  ;
     property Group     :String     read FGroup       write FGroup      ;
     property Agency    :String     read FAgency      write FAgency     ;
     property ReportLine:String     read FReportLine  write FReportLine ;
     property PLU       :Integer    read FPLU         write FPLU   ;
     property ProgID    :String     read FProgID      write FProgID;
     //property Status    :StatusItem read FStatus      write FStatus ;
  end;
  TStockList = class(TItemList)
  private
     function GetItem(Index:Integer):TStockItem;
  public
     function Add(Item:TStockItem):Integer;
     procedure LoadFromStream(Stream:TStream); override;
     procedure Load ;
//     procedure DeleteRecords( Id: Integer ) ;
     procedure SaveToStream(Stream:TStream); override;
     function IndexOfID(Id:Integer):TStockItem;
     property Items[Index:Integer]:TStockItem read GetItem; default;
  end;
  TStockUnitItem = class(TListItem)
  private
     FTempAdjust :Integer;
     FQuantity   :Integer;
     FMinLevel   :Integer;
     FMaxLevel   :Integer;
     FNomLevel   :Integer;
     FStockItem  :TStockItem;
     FTQuantity  :Integer;
     FStockObjectOwner : TStockUnit ;
     FItemIndex  :Integer;     
     function GetDescription:String  ;
     function GetPrice      :Currency;
     function GetGroup      :String  ;
     function GetAgency     :String  ;
     function GetPLU        :Integer ;
     function GetProgID     :String  ;
     function GetQuantity   :Integer ;
     function GetAccountID  :String ;
     function GetReportLine :String;
  public
     constructor Create(StockItem:TStockItem;Qty,Min,Max,Nom:Integer; Owner: TStockUnit );
     procedure SaveToStream(Stream:TStream); override;
     procedure Save ;
     procedure LoadFromStream(Stream:TStream); override;
     procedure Load ;
     procedure DeleteRecord ;
     property Description:String   read GetDescription;
     property Price      :Currency read GetPrice      ;
     property Group      :String   read GetGroup   ;
     property Agency     :String   read GetAgency  ;
     property ProgID     :String   read GetProgID   ;
     property PLU        :Integer  read GetPLU     ;
     property AccountID  :String   read GetAccountID ;
     property ReportLine :String   read GetReportLine;
     property TempAdjust :Integer read FTempAdjust write FTempAdjust;
     property Quantity   :Integer read GetQuantity write FQuantity;
     property TQuantity  :Integer read FTQuantity write FTQuantity;
     property MinLevel   :Integer read FMinLevel write FMinLevel;
     property MaxLevel   :Integer read FMaxLevel write FMaxLevel;
     property NomLevel   :Integer read FNomLevel write FNomLevel;
     property ItemIndex  :Integer read FItemIndex ;
     property StockItem  :TStockItem read FStockItem write FStockItem ;
  end;
  TStockUnit = class(TItemList)
  private
     FOwner:String;
     FTransferTo:String;
     function GetItem(Index:Integer):TStockUnitItem;
  public
     constructor Create(Owner:String);
     procedure DeleteRecords(Index:Integer);
     procedure SaveToStream(Stream:TStream); override;
     procedure LoadFromStream(Stream:TStream); override;
     procedure Load ;//FromStream(Stream:TStream); override;
     procedure Save ;
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
     procedure Save ;
     procedure Load ;
     procedure DeleleteRecords( Id : Integer );
     property Items[Index:Integer]:TStockUnit read GetItem; default;
     function ListStock(Owner,StockGroup:String;Avail:Boolean):String;
     function ListAll(Owner,StockGroup:String):String;
     function ListAvailable(Owner,StockGroup:String):String;
  end;
  TSiteStock = class(TObject)
  private
     //FCurrentFileName:String;
     FCurrentDirectory : String ;
     FStockFile     : String ;
     //FStockItemFile : String ;
     FUnitItemModified:Boolean;
     FModified:Boolean;
     FItemModified:Boolean ;
     FAutoSave:Boolean;
     function GetStockItem(Owner,StockItemName:String):TStockUnitItem;
     procedure SetModified(Value:Boolean);
     procedure SetItemModified(Value:Boolean);
     procedure SetUnitItemModified(Value:Boolean);
     function  GetFullStockFile : String ;
     function  GetTextSave : Boolean ;
     procedure SetTextSave( Value : Boolean ) ;

  protected
     FStockItems:TStockList;
     FStockUnits:TStockUnitList;
     FStockUnitTypes:TStockUnitTypeList;
     FStockTransfers:TStockUnitList;
  public
     constructor Create;
     destructor Destroy; override;
     procedure SaveToStream(StockStream:TStream; StockFiles :SetStockFiles );
     //procedure LoadFromStream(SStock, SStockItem:TStream); dynamic ;
     procedure LoadFromStream(SStock:TStream); dynamic ;
     //procedure SaveToFiles(FileName:String);
     procedure SaveToStockFile ;
     procedure SaveToStockItemFile ;
     procedure SaveToStockUnitItemFile ;
     procedure SaveToFiles ;
     //procedure LoadFromFile(FileName:String);
     procedure LoadFromFile; dynamic ;
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
     procedure DeleteStockItemByName(Description:String);
     function  GetStockItemDetails(Description:String):String;
     procedure DeleteStockItem(StockItem:TStockItem);
     function  GetStockUnitsOwners : String ;
     function  GetStockUnitsItems( Owner : String; OutputString : TStrings; FieldsDisplay : Variant ): String ;
     procedure AddNewStockItem(Description:String;Value:Currency;Group:String;PLU:Integer;AccountLine,AcctType,Report,ProgID,SUTypes:String);
     property StockItems:TStockList             read FStockItems     write FStockItems    ;
     property StockUnits:TStockUnitList         read FStockUnits     write FStockUnits    ;
     property StockUnitTypes:TStockUnitTypeList read FStockUnitTypes write FStockUnitTypes;
     property StockTransfers:TStockUnitList     read FStockTransfers write FStockTransfers;
     property Modified:Boolean read FModified write SetModified;
     property ItemModified:Boolean read FItemModified write SetItemModified;
     property UnitItemModified:Boolean read FUnitItemModified write SetUnitItemModified;
     property AutoSave:Boolean read FAutoSave write FAutoSave;
     property CurrentDirectory : string read FCurrentDirectory write FCurrentDirectory ;
     property StockFile : string        read FStockFile        write FStockFile ;
     //property StockItemFile : String    read FStockItemFile    write FStockItemFile ;
     property FullStockFile : String    read GetFullStockFile;
     property TextSaveMode : boolean  read GetTextSave  write SetTextSave ;

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
     begin
       Items[Index].Free;
     end ;

     TheList.Delete(Index);

  end;
end;
{TStockItem}
constructor TStockItem.Create(Description:String;Price:Currency;Identifier:Integer);
begin
   inherited Create;
   FDescription:=Description;
   FPrice      :=Price      ;
   FIdentifier :=Identifier ;
end;
procedure TStockItem.DeleteRecord ;
begin

   with StockDataModule do
   begin
      OpenStockItem ;
      if StockItemTable.State <> dsInactive then
      begin

         StockItemTable.IndexName:='';
         if StockItemTable.Locate( 'SIIdentifier', FIdentifier, [] ) then
            StockItemTable.Delete ;

      end ;
      CloseStockItem ;
   end ;

end;
procedure TStockItem.Save ; //ToStream(Stream:TStream);
begin
   try

      with StockDataModule do
      begin

         OpenStockItem ;

         if StockItemTable.State <> dsInactive then
         begin

            if not StockItemTable.Eof and
               StockItemTable.Locate( 'SIIdentifier', FIdentifier, [] ) then
               StockItemTable.Edit
            else
            begin
               StockItemTable.Insert ;
               StockItemTableSIIdentifier.Value := FIdentifier ;
            end ;

            StockItemTableSIDescription.Value := FDescription ;
            StockItemTableSIPrice.Value       := FPrice ;
            StockItemTableSIAccountID.Value   := FAccountID ;
            StockItemTableSIGroup.Value       := FGroup ;
            StockItemTableSIPLU.Value         := FPLU ;
            StockItemTableSIProgID.Value      := FProgID ;
            StockItemTableSIAgency.Value      := FAgency ;
            StockItemTableSIReportLine.Value  := FReportLine ;
            StockItemTable.Post ;

         end ;

         CloseStockItem ;
         
      end;
   except
     On E : Exception do RaiseGUIDException('{CBE8E8CA-00CF-424B-84C5-B3B2630FAE13}', E);
   end;
end;

procedure TStockItem.LoadFromStream(Stream:TStream);
begin
   FDescription:=StrFromStream(Stream);
   FPrice      :=CurFromStream(Stream);
   FIdentifier :=IntFromStream(Stream);
   FAccountID  :=StrFromStream(Stream);
   FGroup      :=StrFromStream(Stream);
   FPLU        :=IntFromStream(Stream);
   FProgID     :=StrFromStream(Stream);
   FAgency     :=StrFromStream(Stream);
   FReportLine :=StrFromStream(Stream);
end ;

procedure TStockItem.Load ; //FromStream(Stream:TStream);
begin

   with StockDataModule do
   begin

      if StockItemTable.State <> dsInactive then
      begin
         FDescription   := StockItemTableSIDescription.Value ;
         FPrice         := StockItemTableSIPrice.Value ;
         FIdentifier    := StockItemTableSIIdentifier.Value ;
         FAccountID     := StockItemTableSIAccountID.Value ;
         FGroup         := StockItemTableSIGroup.Value ;
         FPLU           := StockItemTableSIPLU.Value ;
         FProgID        := StockItemTableSIProgID.Value ;
         FAgency        := StockItemTableSIAgency.Value ;
         FReportLine    := StockItemTableSIReportLine.Value ;
      end;
   end ;
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
   // Item.Identifier:=Ident;
   // inherited Add(Item.Description,Item);
   TheList.AddObject(Item.Description,Item);
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
   end ;

end ;

procedure TStockList.Load ;//FromStream(Stream:TStream);
var
   StockItem:TStockItem;
begin

   with StockDataModule do
   begin

      OpenStockItem ;

      if StockItemTable.State <> dsInactive then
      begin
         while not StockItemTable.Eof do
         begin
            StockItem:=TStockItem.Create('',0,0);
            StockItem.Load ; //FromStream(Stream);
            Add(StockItem);
            StockItemTable.Next ;
         end ;
      end ;
      
      CloseStockItem ;
   end;

end;
procedure TStockList.SaveToStream(Stream:TStream);
var
   I:Integer;
begin
 //  IntToStream(Count,Stream);
   for I:=0 to Count-1 do
      Items[I].Save ;
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
constructor TStockUnitItem.Create(StockItem:TStockItem;Qty,Min,Max,Nom:Integer; Owner: TStockUnit );
begin
   inherited Create;
   FQuantity :=Qty;
   FMinLevel :=Min;
   FMaxLevel :=Max;
   FNomLevel :=Nom;
   FTempAdjust:=0;
   FStockItem:=StockItem;
   FStockObjectOwner := Owner ;
end;
procedure TStockUnitItem.DeleteRecord ;
begin

   with StockDataModule do
   begin

      OpenStockUnitItem ;
      if StockUnitItemTable.State <> dsInactive then
      begin
         StockUnitItemTable.IndexName:='';
         if StockUnitItemTable.Locate( 'SUIIdentifier;SUIOwner', VarArrayOf( [FStockItem.Identifier, FStockObjectOwner.Owner ]),[] ) then
            StockUnitItemTable.Delete ;
      end;
      CloseStockUnitItem ;
   end ;

end;

procedure TStockUnitItem.SaveToStream(Stream:TStream);
begin
   IntToStream(FQuantity,Stream);
   IntToStream(FTempAdjust,Stream);
   IntToStream(FMinLevel,Stream);
   IntToStream(FMaxLevel,Stream);
   IntToStream(FNomLevel,Stream);
   IntToStream(FStockItem.Identifier,Stream);
end;

procedure TStockUnitItem.Save ;
begin

   try

      with StockDataModule do
      begin

         OpenStockUnitItem ;

         if StockUnitItemTable.State <> dsInactive then
         begin

            if StockUnitItemTable.IndexName <> '' then
               StockUnitItemTable.IndexName :='';

            if not StockUnitItemTable.Eof and
               StockUnitItemTable.Locate( 'SUIIdentifier;SUIOwner ',
                                          VarArrayOf([FStockItem.Identifier,FStockObjectOwner.Owner ]), [] ) then
               StockUnitItemTable.Edit
            else
            begin
               StockUnitItemTable.Insert ;
               StockUnitItemTableSUIIdentifier.Value := FStockItem.Identifier ;
               StockUnitItemTableSUIOwner.Value      := FStockObjectOwner.Owner ;
            end ;

            StockUnitItemTableSUIQuantity.Value    := FQuantity ;
            StockUnitItemTableSUITempAdjust.Value  := FTempAdjust ;
            StockUnitItemTableSUIMinLevel.Value    := FMinLevel ;
            StockUnitItemTableSUIMaxLevel.Value    := FMaxLevel ;
            StockUnitItemTableSUINomLevel.Value    := FNomLevel ;
            StockUnitItemTableSUITransferTo.Value  := FStockObjectOwner.TransferTo ;
            StockUnitItemTable.Post ;

         end ;

         CloseStockUnitItem ;

      end ;

   except
      On E : Exception do RaiseGUIDException('{905547E6-69D9-41AE-A639-9FBF460DEC20}', E);
   end;

end;
procedure TStockUnitItem.LoadFromStream(Stream:TStream);
begin
   FQuantity:=IntFromStream(Stream);
   FTempAdjust:=IntFromStream(Stream);
   FMinLevel:=IntFromStream(Stream);
   FMaxLevel:=IntFromStream(Stream);
   FNomLevel:=IntFromStream(Stream);
   FItemIndex:=IntFromStream(Stream);
end;

procedure TStockUnitItem.Load ;
begin
   with StockDataModule do
   begin

      if StockUnitItemTable.State <> dsInactive then
      begin
         FQuantity   := StockUnitItemTableSUIQuantity.Value ;
         FTempAdjust := StockUnitItemTableSUITempAdjust.Value ;
         FMinLevel   := StockUnitItemTableSUIMinLevel.Value ;
         FMaxLevel   := StockUnitItemTableSUIMaxLevel.Value ;
         FNomLevel   := StockUnitItemTableSUINomLevel.Value ;
         FItemIndex  := StockUnitItemTableSUIIdentifier.Value ;
      end;

   end ;

end;
function TStockUnitItem.GetDescription:String;
begin
   if FStockItem <> nil then
      Result:=FStockItem.Description
   else
      Result:='';
end;
function TStockUnitItem.GetPrice:Currency;
begin
   if FStockItem <> nil then
      Result:=FStockItem.Price
   else
      Result:=0;
end;
function TStockUnitItem.GetGroup:String;
begin
   if FStockItem <> nil then
      Result:=FStockItem.Group
   else
      Result:='';
end;                                      
function TStockUnitItem.GetAgency:String;
begin
   if FStockItem <> nil then
      Result:=FStockItem.Agency
   else
      Result:='';
end;                                      
function TStockUnitItem.GetQuantity:Integer;
begin
   Result:=FQuantity+FTempAdjust;
end;
function TStockUnitItem.GetPLU:Integer;
begin
   if FStockItem <> nil then
      Result:=FStockItem.PLU
   else
      Result:=0;
end;
function TStockUnitItem.GetProgID:String;
begin
   if FStockItem <> nil then
      Result:=FStockItem.ProgID
   else
      Result:='';
end;
function TStockUnitItem.GetAccountID:String;
begin
   if FStockItem <> nil then
      Result:=FStockItem.AccountID
   else
      Result:='';
end;
function TStockUnitItem.GetReportLine:String;
begin
   if FStockItem <> nil then
      Result:=FStockItem.ReportLine
   else
      Result:='';
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

procedure TStockUnit.Save ;
var
   I:Integer;
begin
   for I:=0 to Count-1 do
      Items[I].Save ;
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
      StockUnitItem:=TStockUnitItem.Create(nil,0,0,0,0, Self );
      StockUnitItem.LoadFromStream(Stream);
      Add(StockUnitItem);
   end;

end ;

procedure TStockUnit.Load ; //FromStream(Stream:TStream);
var
   StockUnitItem:TStockUnitItem;
begin

   with StockDataModule do
   begin

      if StockUnitItemTable.State <> dsInactive then
      begin

         FOwner := StockUnitItemTableSUIOwner.Value;
         while not StockUnitItemTable.Eof and
                   ( FOwner = StockUnitItemTableSUIOwner.Value ) do

         begin
            StockUnitItem:=TStockUnitItem.Create(nil,0,0,0,0, Self );
            StockUnitItem.Load ; //DDB
            Add(StockUnitItem);

            FOwner      := StockUnitItemTableSUIOwner.Value;
            FTransferTo := StockUnitItemTableSUITransferTo.Value;

            StockUnitItemTable.Next ;
         end ;

      end;

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
procedure TStockUnit.DeleteRecords(Index:Integer);
begin

   with StockDataModule do
   begin
      OpenStockUnitItem ;

      if StockUnitItemTable.State <> dsInactive then
      begin
         StockUnitItemTable.IndexName:='';

         StockUnitItemTable.Locate( 'SUIIdentifier', Index,[] );
         while StockUnitItemTableSUIIdentifier.Value = Index do
            TStockUnitItem(inherited Items[Index]).DeleteRecord;

      end;

      CloseStockUnitItem  ;
   end ;



end ;
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
end ;
procedure TStockUnitList.Load ;//FromStream(Stream:TStream);
var
   StockUnit:TStockUnit;
   TempOwner : String;
begin

   with StockDataModule do
   begin

      OpenStockUnitItem ;

      if StockUnitItemTable.State <> dsInactive then
      begin
         StockUnitItemTable.IndexName := 'Owner' ;
         TempOwner := StockUnitItemTableSUIOwner.Value;
         while not StockUnitItemTable.Eof and
                   ( TempOwner = StockUnitItemTableSUIOwner.Value ) do
         begin

            StockUnit:=TStockUnit.Create('');
            StockUnit.Load ;//FromStream(Stream);
            Add(StockUnit);
            TempOwner      := StockUnitItemTableSUIOwner.Value;
         end ;
      end;

      CloseStockUnitItem ;
   end;

end;
procedure TStockUnitList.Save ;
var
   I:Integer;
begin

   for I:=0 to Count-1 do
      Items[I].Save ;


end;

function StockListSort(Item1,Item2: Pointer):Integer;
var
   A,B:TStockUnitItem;
   G1,G2:String;
begin
   A:=TStockUnitItem(Item1);
   B:=TStockUnitItem(Item2);
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
      Result:=StrComp(PChar(A.Description),PChar(B.Description));
end;
function TStockUnitList.ListStock(Owner,StockGroup:String;Avail:Boolean):String;
var
   SI,I,J:Integer;
   StockUnit:TStockUnit;
   SList:TStringList;
   OList:TList;
   StockUnitItem:TStockUnitItem;
   Res:TPackStringList;
   ReportCash:Boolean;
begin
   SList:=TStringList.Create;
   if StockGroup = '*All' then
   begin
      ReportCash:=False;
      StockGroup:='All';
   end
   else
      ReportCash:=True;

   Result:='';
   if Owner = 'All' then
   begin
      for J:=0 to Count-1 do
      begin
         StockUnit:=Items[J];
         if StockUnit <> nil then
         begin
            if Copy(StockGroup,1,1) = '*' then
            begin
               StockGroup:=Copy(StockGroup,2,999);
               for I:=0 to StockUnit.Count-1 do
               begin
                  StockUnitItem:=StockUnit[I];
                  if ((ReportCash) or (StockUnitItem.Group <> 'Cash'))
                  and ((not Avail) or (StockUnitItem.Quantity > 0))
                  and (StockUnitItem.Agency = StockGroup) then
                  begin
                     SI:=SList.IndexOf(StockUnitItem.Description);
                     if SI = -1 then
                     begin
                        SList.AddObject(StockUnitItem.Description,StockUnitItem);
                        StockUnitItem.TQuantity:=StockUnitItem.Quantity;
                     end
                     else
                     begin
                        TStockUnitItem(SList.Objects[SI]).TQuantity:=TStockUnitItem(SList.Objects[SI]).TQuantity+StockUnitItem.Quantity;
                     end;
                  end;
               end;
            end
            else
            begin
               for I:=0 to StockUnit.Count-1 do
               begin
                  StockUnitItem:=StockUnit[I];
                  if ((ReportCash) or (StockUnitItem.Group <> 'Cash'))
                  and ((not Avail) or (StockUnitItem.Quantity > 0))
                  and ((StockGroup = 'All') or (StockUnitItem.Group = StockGroup)) then
                  begin
                     SI:=SList.IndexOf(StockUnitItem.Description);
                     if SI = -1 then
                     begin
                        SList.AddObject(StockUnitItem.Description,StockUnitItem);
                        StockUnitItem.TQuantity:=StockUnitItem.Quantity;
                     end
                     else
                     begin
                        TStockUnitItem(SList.Objects[SI]).TQuantity:=TStockUnitItem(SList.Objects[SI]).TQuantity+StockUnitItem.Quantity;
                     end;
                  end;
               end;
            end;
         end;
      end;
   end
   else
   begin
      StockUnit:=Items[IndexOf(Owner)];
      if StockUnit <> nil then
      begin
         if Copy(StockGroup,1,1) = '*' then
         begin
            StockGroup:=Copy(StockGroup,2,999);
            for I:=0 to StockUnit.Count-1 do
            begin
               StockUnitItem:=StockUnit[I];
               if ((ReportCash) or (StockUnitItem.Group <> 'Cash'))
               and ((not Avail) or (StockUnitItem.Quantity > 0))
               and (StockUnitItem.Agency = StockGroup) then
               begin
                  SList.AddObject(StockUnitItem.Description,StockUnitItem);
                  StockUnitItem.TQuantity:=StockUnitItem.Quantity;
               end;
            end;
         end
         else if Copy(StockGroup,1,1) = '!' then
         begin
            StockGroup:=Copy(StockGroup,2,999);
            for I:=0 to StockUnit.Count-1 do
            begin
               StockUnitItem:=StockUnit[I];
               if ((ReportCash) or (StockUnitItem.Group <> 'Cash'))
               and ((not Avail) or (StockUnitItem.Quantity > 0))
               and (StockUnitItem.Group <> StockGroup) then
               begin
                  SList.AddObject(StockUnitItem.Description,StockUnitItem);
                  StockUnitItem.TQuantity:=StockUnitItem.Quantity;
               end;
            end;
         end
         else
         begin
            for I:=0 to StockUnit.Count-1 do
            begin
               StockUnitItem:=StockUnit[I];
               if ((ReportCash) or (StockUnitItem.Group <> 'Cash'))
               and ((not Avail) or (StockUnitItem.Quantity > 0))
               and ((StockGroup = 'All') or (StockUnitItem.Group = StockGroup)) then
               begin
                  SList.AddObject(StockUnitItem.Description,StockUnitItem);
                  StockUnitItem.TQuantity:=StockUnitItem.Quantity;
               end;
            end;
         end;
      end;
   end;
   Res:=TPackStringList.Create;
   OList:=TList.Create;
   for I:=0 to SList.Count-1 do
      OList.Add(SList.Objects[I]);
   SList.Free;
   OList.Sort(StockListSort);
   for I:=0 to OList.Count-1 do
   begin
      StockUnitItem:=TStockUnitItem(OList[I]);
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
procedure TStockUnitList.DeleleteRecords( Id : Integer );
begin

   StockDataModule.FlagLeaveUnitItemOpen := True ;
   if (Id >= 0) and (Id < Count) then
   begin
     if Items[Id] <> nil then
       Items[Id].DeleteRecords(Id);
   end ;
   StockDataModule.FlagLeaveUnitItemOpen := False ;

end ;

{TSiteStock}
constructor TSiteStock.Create;
begin
   FStockItems:=TStockList.Create;
   FStockUnits:=TStockUnitList.Create;
   FStockUnitTypes:=TStockUnitTypeList.Create;
   FStockTransfers:=TStockUnitList.Create;
   FAutoSave:=True;
   Modified:=False;
   ItemModified :=False;
   UnitItemModified:=False;
   StockDataModule.OpenTables ;
   //if StockDataModule.StockItemTable.State <> dsInactive then
   //   StockDataModule.StockItemTable.First;

end;
destructor TSiteStock.Destroy;
begin
   StockDataModule.CloseTables ;
   FStockItems.Free;
   FStockUnits.Free;
   FStockUnitTypes.Free;
   FStockTransfers.Free;
   inherited Destroy;
end;
procedure TSiteStock.SaveToStream(StockStream:TStream; StockFiles :SetStockFiles );
begin
   if tStockItems in StockFiles then
   begin
      FStockItems.SaveToStream(StockStream);
      ItemModified:=False;
   end ;
   if tStockUnits in StockFiles then
   begin
      FStockUnits.Save ;
      UnitItemModified:=False;
   end ;
   if tStockUnitTypes in StockFiles then
   begin
      FStockUnitTypes.SaveToStream(StockStream);
      Modified:=False;
   end ;
   if tStockTransfers in StockFiles then
   begin
      FStockTransfers.SaveToStream(StockStream);
      Modified:=False;
   end ;
end;
procedure TSiteStock.LoadFromStream(SStock: TStream );//, SStockItem:TStream);
var
   I,J:Integer;
   StockItem:TStockItem;
begin

   StockDataModule.FlagLeaveItemOpen := True ;
   StockDataModule.FlagLeaveUnitItemOpen := True ;

   FStockItems.Load ; //FromStream(SStockItem);
   FStockUnits.Load ; //FromStream(SStock);

   StockDataModule.FlagLeaveItemOpen := False ;
   StockDataModule.FlagLeaveUnitItemOpen := False ;

   for I:=0 to FStockUnits.Count-1 do
   begin
      J:=0;
      while J < FStockUnits[I].Count do
      begin
          StockItem:=FStockItems.IndexOfID(FStockUnits[I][J].FItemIndex);
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

   FStockUnitTypes.LoadFromStream(SStock);
   for I:=0 to FStockUnitTypes.Count-1 do
   begin
      for J:=0 to FStockUnitTypes[I].Count-1 do
      begin
          FStockUnitTypes[I][J].FStockItem:=FStockItems.IndexOfID(FStockUnitTypes[I][J].FItemIndex);
          FStockUnitTypes[I].Description[J]:=FStockUnitTypes[I][J].FStockItem.Description;
      end;
   end;

   FStockTransfers.LoadFromStream(SStock);
   for I:=0 to FStockTransfers.Count-1 do
   begin
      for J:=0 to FStockTransfers[I].Count-1 do
      begin
          FStockTransfers[I][J].FStockItem:=FStockItems.IndexOfID(FStockTransfers[I][J].FItemIndex);
          FStockTransfers[I].Description[J]:=FStockTransfers[I][J].FStockItem.Description;
      end;
   end;
   Modified:=False;
   ItemModified:=False;
   UnitItemModified:=False;
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
         begin
            FStockUnits[I].DeleteRecords(J) ;
            FStockUnits[I].Delete(J) ;
         end
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

   FStockItems.Delete(FStockItems.IndexOf(StockItem.FDescription));
   StockItem.DeleteRecord;
   Modified:=True;
   //UnitItemModified:=True; //it does de delete into the database
   //ItemModified:=True;
end;
procedure TSiteStock.SetModified(Value:Boolean);
begin
   if AutoSave and Value then
   begin
      //SaveToFiles(FCurrentFileName)
      if ( FCurrentDirectory <> '' ) and ( FStockFile <> '' ) then //and  ( FStockItemFile <> '' ) then
      begin
         SaveToStockFile ;
         //SaveToFiles ;
      end
   end
   else
      FModified:=Value;
end;
procedure TSiteStock.SetItemModified(Value:Boolean);
begin
   if AutoSave and Value then
   begin
      //SaveToFiles(FCurrentFileName)
      if ( FCurrentDirectory <> '' ) and ( FStockFile <> '' ) then //and  ( FStockItemFile <> '' ) then
      begin
         SaveToStockItemFile ;
         //SaveToFiles ;
      end
   end
   else
      FItemModified:=Value;
end;


procedure TSiteStock.SetUnitItemModified(Value:Boolean);
begin
   if AutoSave and Value then
   begin
      //SaveToFiles(FCurrentFileName)
      if ( FCurrentDirectory <> '' ) and ( FStockFile <> '' ) then //and  ( FStockItemFile <> '' ) then
      begin
         SaveToStockUnitItemFile ;
         //SaveToFiles ;
      end
   end
   else
      FUnitItemModified:=Value;
end;


procedure TSiteStock.SaveToFiles ;
//var
//   StockStream : TFileStream;
begin
   //if FullStockFile <> FullStockItemFile then
   //begin
      SaveToStockFile ;
      SaveToStockItemFile ;
      SaveToStockUnitItemFile;
   //end
   //else
   //begin
   //   StockStream:=TFileStream.Create(FullStockFile,fmCreate or fmOpenWrite or fmShareDenyNone);
   //   SaveToStream( StockStream, [ tStockItems, tStockUnits, tStockUnitTypes, tStockTransfers ] );
   //   StockStream.Free;
   //end ;



end;
procedure TSiteStock.SaveToStockFile ;
var
   StockStream : TFileStream;
begin
   StockStream:=TFileStream.Create(FullStockFile,fmCreate or fmOpenWrite or fmShareDenyNone);
   SaveToStream( StockStream, [ tStockUnitTypes, tStockTransfers ] );
   StockStream.Free;
end ;
procedure TSiteStock.SaveToStockItemFile ;
var
   StockStream : TFileStream;
begin
   //StockStream :=TFileStream.Create(FullStockItemFile,fmCreate or fmOpenWrite or fmShareDenyNone);
   SaveToStream(StockStream, [ tStockItems ] );
   //StockStream.Free;
end ;
procedure TSiteStock.SaveToStockUnitItemFile ;
var
   StockStream : TFileStream;
begin
   //StockStream :=TFileStream.Create(FullStockItemFile,fmCreate or fmOpenWrite or fmShareDenyNone);
   SaveToStream(StockStream, [ tStockUnits ] );
   //StockStream.Free;
end ;

procedure TSiteStock.LoadFromFile;
var
   FSStock :TFileStream; //, FSStockItem:TFileStream;
begin
//   FCurrentFileName:=FileName;
   if FileExists( FullStockFile) then //and FileExists(FullStockItemFile) then
   begin
      FSStock    :=TFileStream.Create(FullStockFile    ,fmOpenRead or fmShareDenyNone);
      //if ( FullStockFile <> FullStockItemFile ) then
      //begin
         //FSStockItem:=TFileStream.Create(FullStockItemFile,fmOpenRead or fmShareDenyNone);
         LoadFromStream(FSStock );//, FSStockItem);
         //FSStockItem.Free;
      //end
      //else
      //   LoadFromStream(FSStock, FSStock);

      FSStock.Free;


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

         //UnitItemModified:=True;
         Modified:=True;
         //ItemModified:=True;
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
      begin
         StockUnit[I].TempAdjust:=0;
         StockUnit[I].Save ;
      end;


       //UnitItemModified:=True;
      //Modified:=True;
      //ItemModified:=True;
   end;
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
         StockUnitItem.Quantity:=StockUnitItem.FQuantity+ByValue;

      StockUnitItem.Save ;

      //UnitItemModified:=True; //Modify into the database already using .Save
      //Modified:=True;
      //ItemModified:=True;
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
      StockUnitItem.Save;
      //UnitItemModified:=True;
      Modified:=True;
      //ItemModified:=True;
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
         StockUnit.Save ;
         StockUnits.Add(StockUnit);
      end;
      for I:=0 to StockUnitType.Count-1 do
      begin
         StockUnitTypeItem:=StockUnitType[I];
         if StockUnitTypeItem <> nil then
         begin
            Index:=StockUnit.IndexOf(StockUnitTypeItem.Description);
            if Index = -1 then
               Index:=StockUnit.Add(TStockUnitItem.Create(StockUnitTypeItem.FStockItem,0,0,0,0, StockUnit ));

            StockUnitItem:=StockUnit[Index];
            if StockUnitItem <> nil then
            begin
               StockUnitItem.FQuantity :=0;
               StockUnitItem.FMinLevel :=StockUnitTypeItem.FMinLevel ;
               StockUnitItem.FMaxLevel :=StockUnitTypeItem.FMaxLevel ;
               StockUnitItem.FNomLevel :=StockUnitTypeItem.FNomLevel ;
               StockUnitItem.FStockItem:=StockUnitTypeItem.FStockItem;
               StockUnitItem.Save;
            end;
         end;
      end;
      //UnitItemModified:=True;
      //Modified:=True;
      //ItemModified:=True;
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
   //ItemModified:=True;
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
            StockUnitItem:=TStockUnitItem.Create(StockItems[StockItems.IndexOf(StockItemName)],0,0,0,0, StockTransfers[I]);
            Index:=StockTransfers[I].Add(StockUnitItem);
         end;
         StockTransfers[I][Index].Quantity:=Quantity;
         Modified:=True;
         //ItemModified:=True;
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
                        FromStockUnitItem.Save ;
                          ToStockUnitItem.Save ;
                     end;
                  end;
                  StockTransfer.Delete(0);
               end;
               Modified:=True;
               //ItemModified:=True;
               Exit;
            end;
         end;
      end;
   end;
end;
procedure TSiteStock.EmptySetUp(Owner:String);
var
   StockUnitType:TStockUnitType;
   I:Integer;
   Value:Integer;
   StockUnit:TStockUnit;
   Added:Boolean;
begin

   StockDataModule.FlagLeaveItemOpen      := True ;
   StockDataModule.FlagLeaveUnitItemOpen  := True ;

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
          // SetStockLevel is saving all ready
         //Modified:=True;
         //ItemModified:=True;
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
         //if Added then ItemModified:=True;
      end;
   end;

   StockDataModule.FlagLeaveItemOpen      := False ;
   StockDataModule.FlagLeaveUnitItemOpen  := False ;

end;
procedure TSiteStock.AddNewStockItem(Description:String;Value:Currency;Group:String;PLU:Integer;AccountLine,AcctType,Report,ProgID,SUTypes:String);
var
   SL:TPackStringList;
   I:Integer;
   StockItem:TStockItem;
   SUType:TStockUnitType;
   Index:Integer;
   NewStockUnitItem : TStockUnitItem ;
begin
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
      StockItem.Save ;
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
               SUType.Add(TStockUnitItem.Create(StockItem,0,0,0,0, SUType ));
            end
         end;
         for I:=0 to StockUnits.Count-1 do
         begin
            NewStockUnitItem := TStockUnitItem.Create(StockItem,0,0,0,0, StockUnits[I]) ;
            NewStockUnitItem.Save ;
            StockUnits[I].Add(NewStockUnitItem);
         end;


         Modified:=True;

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
      StockItem.Save ;

   end;
   SL.Free;
   //ItemModified:=True;
end;

function TSiteStock.GetFullStockFile : String ;
begin
   result := FCurrentDirectory + FStockFile
end ;
//function TSiteStock.GetFullStockItemFile : String ;
//begin
//   result :=FCurrentDirectory + FStockItemFile ;
//end ;

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

function TSiteStock.GetStockUnitsOwners : String ;
var
   SL : TStringList ;
   I : Integer ;
begin
   SL := TStringList.Create ;

   for I:=0 to StockUnits.Count-1 do
   begin
      SL.Add(TStockUnit( StockUnits.Items[I] ).Owner );
   end ;
   Result := SL.CommaText ;
   SL.Free ;

end ;

function TSiteStock.GetStockUnitsItems( Owner : String;
                                        OutputString : TStrings;
                                        FieldsDisplay : variant  ): String ;

var
   StockUnit : TStockUnit ;
   I, x : integer ;
   S : String ;
begin
   result := '' ;
   StockUnit:=FStockUnits[FStockUnits.IndexOf(Owner)];
   if StockUnit <> nil then
   begin
      OutputString.Clear ;
      for I := 0 to StockUnit.Count-1 do
      begin
         S :=  '' ;

         for X := 0 to  VarArrayHighBound( FieldsDisplay, 1 ) do
         begin

            if FieldsDisplay[x] = tsDescription then //in FieldsDisplay then
               S := S + RightPad( StockUnit.Items[I].Description, 40, ' ' ) ;
            if FieldsDisplay[x] =  tsPrice      then //  in FieldsDisplay then
               S := S + LeftPad( CurrToStrF( StockUnit.Items[I].Price, ffNumber , 2 ), 8, ' ' );
            if FieldsDisplay[x] = tsQuantity     then //in FieldsDisplay then
               S := S + LeftPad( IntToStr( StockUnit.Items[I].Quantity ), 5, ' ');
            if FieldsDisplay[x] = tsMinLevel     then //in FieldsDisplay then
               S := S + LeftPad( IntToStr( StockUnit.Items[I].MinLevel ), 5 , ' ');
            if FieldsDisplay[x] = tsMaxLevel     then //in FieldsDisplay then
               S := S + LeftPad( IntToStr( StockUnit.Items[I].MaxLevel ), 5, ' ' );
            if FieldsDisplay[x] = tsTempAdjust   then //in FieldsDisplay then
               S := S + LeftPad( IntToStr( StockUnit.Items[I].TempAdjust ), 5, ' ' );
            if FieldsDisplay[x] = tsTQuantity    then //in FieldsDisplay then
               S := S + LeftPad( IntToStr( StockUnit.Items[I].Quantity ), 5, ' ' );
            if FieldsDisplay[x] = tsNomLevel     then //in FieldsDisplay then
               S := S + LeftPad( IntToStr( StockUnit.Items[I].NomLevel ), 5, ' ' );
            if FieldsDisplay[x] = tsGroup        then //in FieldsDisplay then
               S := S + StockUnit.Items[I].Group ;
            if FieldsDisplay[x] = tsAgency       then //in FieldsDisplay then
               S := S + StockUnit.Items[I].Agency ;
            if FieldsDisplay[x] = tsPLU          then //in FieldsDisplay then
               S := S + IntToStr( StockUnit.Items[I].PLU );
            if FieldsDisplay[x] = tsProgID       then //in FieldsDisplay then
               S := S + StockUnit.Items[I].ProgID ;

         end ;

         OutputString.AddObject( S, StockUnit.Items[I] );

      end ;
      Result:=OutputString.CommaText ;
   end ;

end ;

function  TSiteStock.GetTextSave : boolean ;
begin
   Result := TextSave ;
end ;
procedure TSiteStock.SetTextSave( Value : Boolean ) ;
begin
   TextSave := Value ;
end ;

end.




