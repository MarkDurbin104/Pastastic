unit ListBaseU;

interface
uses
   Classes,SysUtils,PackStrListU;
var
   TextSave:Boolean = True;

type
//  TListItem = Class(TPersistent)
  TListItem = Class(TComponent)
  protected
     function IntFromStream(Stream:TStream):Integer ;
     function StrFromStream(Stream:TStream):String  ;
     function CurFromStream(Stream:TStream):Currency;
     procedure IntToStream(Value:Integer ;Stream:TStream);
     procedure StrToStream(Value:String  ;Stream:TStream);
     procedure CurToStream(Value:Currency;Stream:TStream);
  public
     function FieldInfo: Pointer;
     procedure SaveToStream(Stream:TStream); virtual;
     procedure LoadFromStream(Stream:TStream); virtual;
  end;

  TItemList = Class(TListItem)
  private
     function  GetItem(Index:Integer):TListItem;
     function  GetDescription(Index:Integer):String;
     procedure SetDescription(Index:Integer;Value:String);
  public
     TheList:TPackStringList;
     constructor Create(Owner:TComponent); override;
     destructor  Destroy; override;
     function    GetCount:Integer;
     function    Add(ItemName:String;Item:TListItem):Integer;
     procedure   Delete(Index:Integer);
     procedure   Sort;
     function    Find(Value:String):Integer;
     function    IndexOf(ItemName:String):Integer;
     procedure   SaveToStream(Stream:TStream); override;
     procedure   LoadFromStream(Stream:TStream); override;
  published
     property Count:Integer read GetCount;
     property Items[Index:Integer]:TListItem read GetItem; default;
     property Description[Index:Integer]:String read GetDescription write SetDescription;
  end;

implementation

{TListItem}
function TListItem.FieldInfo: Pointer;
asm
   PUSH    ESI
@@Outer:
   MOV     EAX,[EAX]               { fetch class pointer           }
   MOV     ESI,[EAX].vmtFieldTable
   TEST    ESI,ESI
   JE      @@parent
   MOV     EAX,ESI
   JMP     @@exit
@@parent:
   MOV     EAX,[EAX].vmtParent     { fetch parent VMT              }
   TEST    EAX,EAX
   JNE     @@outer
   JMP     @@exit
@@exit:
   POP     ESI
end;
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
   inherited Create(nil);
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
      ListItem:=TListItem.Create(nil);
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
function TItemList.GetCount:Integer;
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
function TItemList.Find(Value:String):Integer;
begin
    TheList.Find(Value,Result);
end;
procedure TItemList.Sort;
begin
    TheList.Sort;
end;
    
end.
