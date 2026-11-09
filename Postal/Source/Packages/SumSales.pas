unit SumSales;

interface

uses
   ReportIDSU,
   DB,DBTables,Classes,SysUtils,GPCSGUID,PackStrListU,
   ParseNodeU, DBUtil ;

type

  TTotalItem = class( TObject )
  private
   FValue : Currency;
   FQuantity : currency;
  public
     property  Value: currency read FValue write FValue ;
     property  Quantity: currency read FQuantity write FQuantity;
     procedure AddValue( AddValue,AddQty:currency ) ;
  end ;

  TTotals = class(TStringList)
     function GetItem(TotalName:string ): TTotalItem ;
  public
     procedure   AddValue(TotalName:string; Value,Qty: Currency );
     destructor  Destroy ; override ;
     property    Item[TotalName:string]: TTotalItem read GetItem; default;
  end ;

  TSalesItem = class(TObject)
  private
     FPeriod:Integer;
     FTeller:String;
     FPLU:Integer;
     FIndex:Integer;
     FRecType:String;
     FValue:Currency;
     FQuantity:Integer;
     FUsed:Boolean;
     procedure SetPackText(Value:String);
  public
     property Period     :Integer  read FPeriod      write FPeriod     ;
     property Teller     :String   read FTeller      write FTeller     ;
     property PLU        :Integer  read FPLU         write FPLU        ;
     property Index      :Integer  read FIndex       write FIndex      ;
     property RecType    :String   read FRecType     write FRecType    ;
     property Value      :Currency read FValue       write FValue      ;
     property Quantity   :Integer  read FQuantity    write FQuantity   ;
     property Used       :Boolean  read FUsed        write FUsed       ;
     property PackText   :String  write SetPackText;
  end;
  TSalesItems = class(TList)
  private
     FQuery : String;
     procedure SetPackText(Value:String);
     procedure SetQuery(Query:String);
     function GetSalesItem(Index:Integer):TSalesItem;
  public
     procedure GETValueQty( SQLText:String; var value:Currency; var Qty:integer );
     procedure Populate(RecType,User:String;FromPeriod,ToPeriod:Integer;UserList:TStrings);
     property PackText:String write SetPackText;
     property Item[Index:Integer]:TSalesItem read GetSalesItem; default;
     property Query:String read FQuery write SetQuery;
  end;
  TReportGrid = class(TList)
    private
      FColCount:Integer;
      function GetElement(Row,Col:Integer):String;
      procedure SetElement(Row,Col:Integer;Value:String);
    public
       procedure PutTotalsInPlace( TotalCounter:TTotals );
       procedure PutTotalsInMultiPlace( TotalCounter:TTotals; Times:integer; ColumnName:integer );
       destructor Destroy; override;
       property ColCount:Integer read FColCount;
       function RowCount:Integer;
       property Element[Row,Col:Integer]:String read GetElement write SetElement; default;
  end;

  procedure   TotalInCounters( Node:TCorvusNode;TotalCounter:TTotals;EntryValue,EntryQty:currency;AddTo,SubFrom:String );
  procedure   TotalInMultiCounters( Node:TCorvusNode;TotalCounter:TTotals;EntryValue,EntryQty:currency;AddTo,SubFrom:String;Column:integer );
implementation
{TSalesItem}
procedure TSalesItem.SetPackText(Value:String);
var
  SL:TPackStringList;
begin
  SL:=TPackStringList.Create;
  SL.PackText:=Value;
  if SL.Count > 0 then FPeriod     :=StrToIntDef (SL[0],0);
  if SL.Count > 1 then FTeller     :=             SL[1];
  if SL.Count > 2 then FPLU        :=StrToIntDef (SL[2],0);
  if SL.Count > 3 then FIndex      :=StrToIntDef (SL[3],0);
  if SL.Count > 4 then FRecType    :=             SL[4];
  if SL.Count > 5 then FValue      :=StrToCurrDef(SL[5],0);
  if SL.Count > 6 then FQuantity   :=StrToIntDef (SL[6],0);
  FUsed:=False;
  SL.Free;
end;
{TSalesItems}
procedure TSalesItems.GETValueQty( SQLText:String; var value:Currency; var Qty:integer );
var
   i:integer ;
begin
   Value:=0;
   Qty:=0;
   if SQLText <> '' then
   begin
      Query := SQLText ;
      for I:=0 to Count-1 do
      begin
         Value:=Value+Abs(Item[I].Value);
         Qty:=Qty+Item[I].Quantity;
      end;
   end;

end ;
procedure TSalesItems.Populate(RecType,User:String;FromPeriod,ToPeriod:Integer;UserList:TStrings);
var
   I:Integer;
   //PSLDatabase:TDatabase;
begin
   //PSLDatabase:=TDatabase.Create(nil);
   //PSLDatabase.AliasName   :='PSL';
   //PSLDatabase.DatabaseName:='PSL';
   //PSLDatabase.LoginPrompt :=False;
   //PSLDatabase.SessionName :='Default';
   //PSLDataBase.Params.Add('USER NAME='+GetGPCSRegString('','UserName','psl'   ));
   //PSLDataBase.Params.Add('PASSWORD=' +GetGPCSRegString('','Password','suvroc'));
   Query := ReplaceParams(':',
                          ' Select Period,Teller,PLU,RecIndex,RecType,Sum(TxnValue),Sum(Quantity) from txnlog '+
                          ' where '+RecType+' and (PLU <> 0) and (Quantity*Price = TxnValue or PLU = 61000000 ) '+
                          ' and :TellerCondition: and :OfficeCondition:' +
                          ' group by Period,Teller,PLU,RecIndex,RecType order by Period,Teller,PLU,RecType');
   //PSLDatabase.Free;
   if UserList <> nil then
   begin
      for I:=0 to Count-1 do
      begin
         if UserList.IndexOf(Item[I].Teller) = -1 then
            UserList.Add(Item[I].Teller);
      end;
   end;
end;
procedure TSalesItems.SetQuery(Query:String);
var
   PSLDatabase:TDatabase;
begin
   PSLDatabase:=TDatabase.Create(nil);
   PSLDatabase.AliasName   :='PSL';
   PSLDatabase.DatabaseName:='SumSales';
   PSLDatabase.LoginPrompt :=False;
   PSLDatabase.SessionName :='Default';
   PSLDataBase.Params.Add('USER NAME='+GetGPCSRegString('','UserName','psl'   ));
   PSLDataBase.Params.Add('PASSWORD=' +GetGPCSRegString('','Password','suvroc'));
   FQuery := Query;
   PackText:=QueryToPackText(Query);

   PSLDataBase.Free ;

end;
function TSalesItems.GetSalesItem(Index:Integer):TSalesItem;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=TSalesItem(Get(Index))
   else
      Result:=nil;
end;
procedure TSalesItems.SetPackText(Value:String);
var
  SL:TPackStringList;
  I,J:Integer;
  S:String;
  SI:TSalesItem;
  PLUList:TStringList;
  CompPLU,PLU,Index:Integer;
begin
  Clear;
  SL:=TPackStringList.Create;
  SL.PackText:=Value;
  for I:=0 to SL.Count-1 do
  begin
     SI:=TSalesItem.Create;
     SI.PackText:=SL[I];
     Add(SI);
  end;
  PLUList:=TPackStringList.Create;
  for I:=0 to Count-1 do
  begin
     S:=IntToHex(Item[I].PLU,8)+IntToHex(Item[I].Index,8);
     if PLUList.IndexOf(S) = -1 then
        PLUList.Add(S);
  end;
  PLUList.Sort;
  I:=0;
  while I < PLUList.Count do
  begin
     PLU  :=StrToInt('$'+Copy(PLUList[I],1,8));
     Index:=StrToInt('$'+Copy(PLUList[I],9,8));
     if (Index = 0) and (I < PLUList.Count-1) then
     begin
        Inc(I);
        CompPLU:=StrToInt('$'+Copy(PLUList[I],1,8));
        while (I < PLUList.Count) and (CompPLU = PLU) do
        begin
           PLUList.Delete(I);
           // reduce the quantity of sub items with the same PLU to 0
           for J:=0 to Count-1 do 
           begin
              if (Item[J].PLU = PLU) and (Item[J].Index > 0) then 
                 Item[J].Quantity:=0;
           end;
{           // delete sub items with the same PLU 
           J:=0;
           while J < Count do
           begin
              if (Item[J].PLU = PLU) and (Item[J].Index > 0) then
                 Delete(J)
              else
                 Inc(J)
           end; }
           if (I < PLUList.Count) then CompPLU:=StrToInt('$'+Copy(PLUList[I],1,8));
        end;  
     end       
     else
       Inc(I);
  end;
  PLUList.Free;
  SL.Free;
end;
{TReportGrid}
procedure TReportGrid.PutTotalsInPlace( TotalCounter:TTotals );
var
   I : integer;
begin

   // It searchs for the elements into the counter object and pick the values.
   for I:=0 to Count-1 do
   begin
      if TotalCounter[element[I,3]] <> nil then
      begin
         element[I,1]:= CurrToStr(TotalCounter[element[I,3]].Value);
         element[I,2]:= CurrToStr(TotalCounter[element[I,3]].Quantity );
      end ;
   end ;

end ;
procedure TReportGrid.PutTotalsInMultiPlace( TotalCounter:TTotals; Times:integer; ColumnName:integer );
var
   I : integer;
   Column:integer;
   Item:TTotalItem;
begin

   // It searchs for the elements into the counter object and pick the values.
   for Column := 0 to Times-1 do
   begin
      for I:=0 to Count-1 do
      begin
         Item:= TotalCounter[element[I,ColumnName]+'_'+IntToStr(Column)] ;
         if Item <> nil then
         begin
            element[I,1+Column]:= CurrToStr(Item.Value);
         end ;
      end ;
   end;

end ;

function TReportGrid.GetElement(Row,Col:Integer):String;
var
   RowList:TStringList;
begin
   Result:='';
   if Row >= Count then exit;
   RowList:=TStringList(Get(Row));
   if (RowList = nil) or (Col >= RowList.Count) then Exit;
   Result:=RowList[Col];
end;
procedure TReportGrid.SetElement(Row,Col:Integer;Value:String);
var
   RowList:TStringList;
begin
   while Row >= Count do Add(TStringList.Create);
   RowList:=TStringList(Get(Row));
   if RowList <> nil then
   begin
      while Col >= RowList.Count do RowList.Add('');
      RowList[Col]:=Value;
      if Col > FColCount then FColCount:=Col;
   end;
end;
function TReportGrid.RowCount:Integer;
begin
   Result:=Count;
end;

destructor TReportGrid.Destroy;
begin
   while Count > 0 do
   begin
      if Get(0) <> nil then
         TStringList(Get(0)).Free;
      Delete(0);
   end;
end;

{TTotalItem}
procedure TTotalItem.AddValue( AddValue,AddQty :currency );
begin
   Fvalue := Fvalue + AddValue ;
   FQuantity := FQuantity + AddQty ;
end ;

{TTotals}
destructor TTotals.Destroy ;
var
   i:integer ;
begin
   for i:=0 to count-1 do
      Objects[i].Free;
   inherited destroy ;
end ;

procedure TTotals.AddValue(TotalName:string; Value,Qty : Currency );
var
   i : integer ;
   TotalItem : TTotalItem ;
begin
   if TotalName <> '' then
   begin
      i := IndexOf( TotalName );
      if i = -1 then
      begin
         TotalItem := TTotalItem.Create ;
         AddObject( TotalName, TotalItem )
      end
      else
         TotalItem := TTotalItem(Objects[i]);

      TotalItem.AddValue( Value,Qty );
   end ;

end ;

function TTotals.GetItem(TotalName:string ): TTotalItem ;
var
   i : integer ;
begin
   i := IndexOf( TotalName );
   if i = -1 then
      result := nil
   else
      result := TTotalItem(Objects[i]);
end ;

//------------------------------------------------------------------------------

procedure AddTotalNamesToList( SL,Node:TStrings );
var
   i : integer ;
begin
   for i:=0 to node.count-1 do
      if SL.IndexOf( Node[i] ) = -1 then
         SL.Add(Node[i]) ;
end ;

procedure TotalInCounters( Node:TCorvusNode;
                           TotalCounter:TTotals;
                           EntryValue,EntryQty:currency;
                           AddTo,SubFrom:String );
var
   I : integer ;
   SLAdd:TStringList;
   SLSub:TStringList;
   SLTemp:TstringList ;
begin
   SLTemp := TStringList.Create;
   SLTemp.Text:= AddTo ;
   SLAdd:= TStringList.Create;
   AddTotalNamesToList( SLAdd,SLTemp );

   SLSub:= TStringList.Create;
   SLTemp.Text:= SubFrom ;
   AddTotalNamesToList( SLSub,SLTemp );
   SLTemp.Free;

   if Node <> nil then
   begin

      i:= Node.indexof( 'AddTo' );
      if (i <> -1) then
         AddTotalNamesToList( SLAdd,TStrings(Node.Objects[i]) ) ;

      i:= Node.indexof( 'SubFrom' );
      if (i <> -1) then
         AddTotalNamesToList( SLSub,TStrings(Node.Objects[i]) );

   end;

   for i := 0 to SLAdd.Count-1 do
      TotalCounter.AddValue( SLAdd[i], Abs(EntryValue), EntryQty );

   for i := 0 to SLSub.Count-1 do
      TotalCounter.AddValue( SLSub[i], -(Abs(EntryValue)), EntryQty );

   SLAdd.Free;
   SLSub.Free;

end ;

procedure TotalInMultiCounters( Node:TCorvusNode;
                           TotalCounter:TTotals;
                           EntryValue,EntryQty:currency;
                           AddTo,SubFrom:String;
                           Column:integer );
var
   I : integer ;
   SLAdd:TStringList;
   SLSub:TStringList;
   SLTemp:TstringList ;
begin
   SLTemp := TStringList.Create;
   SLTemp.Text:= AddTo ;
   SLAdd:= TStringList.Create;
   AddTotalNamesToList( SLAdd,SLTemp );

   SLSub:= TStringList.Create;
   SLTemp.Text:= SubFrom ;
   AddTotalNamesToList( SLSub,SLTemp );
   SLTemp.Free;

   if Node <> nil then
   begin

      i:= Node.indexof( 'AddTo' );
      if (i <> -1) then
         AddTotalNamesToList( SLAdd,TStrings(Node.Objects[i]) ) ;

      i:= Node.indexof( 'SubFrom' );
      if (i <> -1) then
         AddTotalNamesToList( SLSub,TStrings(Node.Objects[i]) );

   end;

   for i := 0 to SLAdd.Count-1 do
      TotalCounter.AddValue( SLAdd[i]+'_'+IntToStr(Column), Abs(EntryValue), EntryQty );

   for i := 0 to SLSub.Count-1 do
      TotalCounter.AddValue( SLSub[i]+'_'+IntToStr(Column), -(Abs(EntryValue)), EntryQty );

   SLAdd.Free;
   SLSub.Free;

end ;


end.


