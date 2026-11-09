unit AccountList;

interface

uses
  Windows,Graphics,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Registry,Dialogs;

type
  TAccountItem = class(TObject)
  private
     FReportsTo:TStringList;
     FDecreases:TStringList;
     FIncreases:TStringList;
  public   
     constructor Create; 
     destructor Destroy; override;
     property ReportsTo:TStringList read FReportsTo write FReportsTo;
     property Decreases:TStringList read FDecreases write FDecreases;
     property Increases:TStringList read FIncreases write FIncreases;
  end;
  TAccountItemList = class(TObject)
  private
     FItems:TStringList;
     function GetLine(Name:String):TAccountItem;
  public   
     constructor Create;
     destructor Destroy; override;
     procedure LoadFromFile(FileName:String);
     procedure SaveToFile(FileName:String);
     procedure AddLine(Name:String);
     procedure AddReportsToLine(Name,ReportsToLine:String);
     procedure AddDecreasesLine(Name,DecreasesLine:String);
     procedure AddIncreasesLine(Name,IncreasesLine:String);
     procedure RemoveLine(Name:String);
     procedure RemoveReportsToLine(Name,ReportsToLine:String);
     procedure RemoveDecreasesLine(Name,DecreasesLine:String);
     procedure RemoveIncreasesLine(Name,IncreasesLine:String);
     procedure GetUpDateLinesFor(Name:String;var ReportsToLines,DecreasesLines,IncreasesLines:String);
     function GetAllThatAdjust(Name:String):String;
     property Items:TStringList read FItems write FItems;
  end;

implementation

{TAccountItem}
constructor TAccountItem.Create;
begin
   inherited Create;
   FIncreases:=TStringList.Create;
   FDecreases:=TStringList.Create;
   FReportsTo:=TStringList.Create;
end;
destructor TAccountItem.Destroy;
begin
   FIncreases.Free;
   FDecreases.Free;
   FReportsTo.Free;
   inherited Destroy;
end;         

{TAccountItemList}
constructor TAccountItemList.Create;
begin
   inherited Create;
   FItems:=TStringList.Create;
end;
destructor TAccountItemList.Destroy;
var
   I:Integer;
begin
   for I:=0 to FItems.Count-1 do
      if FItems.Objects[I] <> nil then 
         TAccountItem(FItems.Objects[I]).Free;
   FItems.Free;
   inherited Destroy;
end;
procedure TAccountItemList.LoadFromFile(FileName:String);
var
   SL:TStringList;
   I:Integer;
   Name,Line:String;
   LType:Char;
   AccountItem:TAccountItem;
begin
   AccountItem:=nil;
   SL:=TStringList.Create;
   try
      SL.LoadFromFile(FileName);
   except
      SL.Free;
      // Log Error
      Exit;
   end;
   For I:=0 to SL.Count-1 do
   begin
      Line:=Trim(SL[I]);
      if Line <> '' then
      begin
         Name:=Copy(Line,3,Length(Line));
         LType:=Line[1];
         case LType of
            'L' : begin
                     AccountItem:=TAccountItem.Create;
                     FItems.AddObject(Name,AccountItem);
                  end;
            'R' : if AccountItem <> nil then AccountItem.ReportsTo.Add(Name);
            'I' : if AccountItem <> nil then AccountItem.Increases.Add(Name);
            'D' : if AccountItem <> nil then AccountItem.Decreases.Add(Name);
         end;
      end;
   end;
   SL.Free;
end;
procedure TAccountItemList.SaveToFile(FileName:String);
var
   SL:TStringList;
   I,J:Integer;
   AccountItem:TAccountItem;
begin
   SL:=TStringList.Create;
   for I:=0 to FItems.Count-1 do
   begin
      SL.Add('L:'+FItems[I]);
      AccountItem:=TAccountItem(FItems.Objects[I]);
      if AccountItem <> nil then
      begin
         for J:=0 to AccountItem.ReportsTo.Count-1 do
           SL.Add('R:'+AccountItem.ReportsTo[J]);
         for J:=0 to AccountItem.Increases.Count-1 do
           SL.Add('I:'+AccountItem.Increases[J]);
         for J:=0 to AccountItem.Decreases.Count-1 do
           SL.Add('D:'+AccountItem.Decreases[J]);
      end;                                    
   end;
   try
      SL.SaveToFile(FileName);
   except
      // Log Error
   end;
   SL.Free;
end;
procedure TAccountItemList.AddLine(Name:String);
var
   AccountItem:TAccountItem;
begin
   if FItems.IndexOf(Name) = -1 then
   begin
      AccountItem:=TAccountItem.Create;
      FItems.AddObject(Name,AccountItem);
   end;
end;
function TAccountItemList.GetLine(Name:String):TAccountItem;
var
   ItemIndex:Integer;
begin
   ItemIndex:=FItems.IndexOf(Name);
   if ItemIndex = -1 then
   begin
      Result:=TAccountItem.Create;
      ItemIndex:=FItems.AddObject(Name,Result);
   end;
   Result:=TAccountItem(FItems.Objects[ItemIndex]);
end;
procedure TAccountItemList.AddReportsToLine(Name,ReportsToLine:String);
var
   AccountItem:TAccountItem;
begin
   AccountItem:=GetLine(Name);
   if AccountItem.ReportsTo.IndexOf(Name) = -1 then 
      AccountItem.ReportsTo.Add(ReportsToLine);
end;
procedure TAccountItemList.AddDecreasesLine(Name,DecreasesLine:String);
var
   AccountItem:TAccountItem;
begin
   AccountItem:=GetLine(Name);
   if AccountItem.Decreases.IndexOf(Name) = -1 then 
      AccountItem.Decreases.Add(DecreasesLine);
end;
procedure TAccountItemList.AddIncreasesLine(Name,IncreasesLine:String);
var
   AccountItem:TAccountItem;
begin
   AccountItem:=GetLine(Name);
   if AccountItem.Increases.IndexOf(Name) = -1 then 
      AccountItem.Increases.Add(IncreasesLine);
end;
procedure TAccountItemList.RemoveLine(Name:String);
var
   AccountItem:TAccountItem;
   ItemIndex:Integer;
begin
   ItemIndex:=FItems.IndexOf(Name);
   if ItemIndex <> -1 then
   begin
      AccountItem:=TAccountItem(FItems.Objects[ItemIndex]);
      AccountItem.Free;
      FItems.Delete(ItemIndex);
   end;
end;
procedure TAccountItemList.RemoveReportsToLine(Name,ReportsToLine:String);
var
   AccountItem:TAccountItem;
   ItemIndex:Integer;
begin
   AccountItem:=GetLine(Name);
   ItemIndex:=AccountItem.ReportsTo.IndexOf(ReportsToLine);
   if ItemIndex <> -1 then
      AccountItem.ReportsTo.Delete(ItemIndex);
end;
procedure TAccountItemList.RemoveDecreasesLine(Name,DecreasesLine:String);
var
   AccountItem:TAccountItem;
   ItemIndex:Integer;
begin
   AccountItem:=GetLine(Name);
   ItemIndex:=AccountItem.Decreases.IndexOf(DecreasesLine);
   if ItemIndex <> -1 then
      AccountItem.Decreases.Delete(ItemIndex);
end;
procedure TAccountItemList.RemoveIncreasesLine(Name,IncreasesLine:String);
var
   AccountItem:TAccountItem;
   ItemIndex:Integer;
begin
   AccountItem:=GetLine(Name);
   ItemIndex:=AccountItem.Increases.IndexOf(IncreasesLine);
   if ItemIndex <> -1 then
      AccountItem.Increases.Delete(ItemIndex);
end;
procedure TAccountItemList.GetUpDateLinesFor(Name:String;var ReportsToLines,DecreasesLines,IncreasesLines:String);
var
   AccountItem:TAccountItem;
begin                         
   AccountItem:=GetLine(Name);
   ReportsToLines:=AccountItem.ReportsTo.CommaText;
   DecreasesLines:=AccountItem.Decreases.CommaText;
   IncreasesLines:=AccountItem.Increases.CommaText;
end;
function TAccountItemList.GetAllThatAdjust(Name:String):String;
var
   I,J:Integer;
   ResSL:TStringList;
   Found:Boolean;
   AccountItem:TAccountItem;
begin
   ResSL:=TStringList.Create;
   for I:=0 to FItems.Count-1 do
   begin
      Found:=False;
      AccountItem:=TAccountItem(FItems.Objects[I]);
      for J:=0 to AccountItem.ReportsTo.Count-1 do
         if (not Found) and (AccountItem.ReportsTo[J] = Name) then 
            Found:=True;
      for J:=0 to AccountItem.Decreases.Count-1 do
         if (not Found) and (AccountItem.Decreases[J] = Name) then 
            Found:=True;
      for J:=0 to AccountItem.Increases.Count-1 do
         if (not Found) and (AccountItem.Increases[J] = Name) then 
            Found:=True;
            
      if Found and (ResSL.IndexOf(FItems[I]) = -1) then
           ResSL.Add(FItems[I]);
   end;
   Result:=ResSL.Commatext;
   ResSL.Free
end;

end.
 