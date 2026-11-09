unit StockPassU;

interface

uses
   StockU,
   Classes, SysUtils ;

type
   TSiteStockPass = Class(TSiteStock)
   public
      procedure LoadFromStream(SStock :TStream); override ;
      procedure LoadFromFile; override ;
   end;


implementation


procedure TSiteStockPass.LoadFromFile;
var
   FSStock, FFStockItem : TFileStream;
begin
//   FCurrentFileName:=FileName;
   if FileExists( FullStockFile) then //and FileExists(FullStockItemFile) then
   begin
      FSStock    :=TFileStream.Create(FullStockFile    ,fmOpenRead or fmShareDenyNone);
      LoadFromStream(FSStock );
      FSStock.Free;
   end;
end;



procedure TSiteStockPass.LoadFromStream(SStock:TStream);
var
   I,J:Integer;
   StockItem:TStockItem;
begin
   FStockItems.LoadFromStream(SStock);
   FStockUnits.LoadFromStream(SStock);

   for I:=0 to FStockUnits.Count-1 do
   begin
      J:=0;
      while J < FStockUnits[I].Count do
      begin
          StockItem:=FStockItems.IndexOfID(FStockUnits[I][J].ItemIndex);
          if StockItem <> nil then
          begin
             FStockUnits[I][J].StockItem:=StockItem;
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
          FStockUnitTypes[I][J].StockItem:=FStockItems.IndexOfID(FStockUnitTypes[I][J].ItemIndex);
          FStockUnitTypes[I].Description[J]:=FStockUnitTypes[I][J].StockItem.Description;
      end;
   end;

   FStockTransfers.LoadFromStream(SStock);
   for I:=0 to FStockTransfers.Count-1 do
   begin
      for J:=0 to FStockTransfers[I].Count-1 do
      begin
          FStockTransfers[I][J].StockItem:=FStockItems.IndexOfID(FStockTransfers[I][J].ItemIndex);
          FStockTransfers[I].Description[J]:=FStockTransfers[I][J].StockItem.Description;
      end;
   end;
   Modified:=False;
   ItemModified:=False;
   UnitItemModified:=False;
end;

end.
