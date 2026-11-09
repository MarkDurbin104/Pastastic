unit Unit3;

interface

type
  TUIStateList = class(TObject)
  private
     FItems:TStringList;
     function GetItem(Index:Integer):TUIStateDetails;
     function GetCount:Integer;
  public
     constructor Create;
     destructor Destroy; override;
     function IndexOf(Value:String):Integer;
     procedure Delete(Index:Integer);
     function Add(Value:TUIStateDetails):Integer;
     property Item[Index:Integer]:TUIStateDetails read GetItem; default;
     property Count:Integer read GetCount;
  end;

implementation
{TUIStateList}
constructor TUIStateList.Create;
begin
   inherited Create;
   FItems:=TStringList.Create;
end;
destructor TUIStateList.Destroy;
begin
   while Count > 0 do 
   begin
      Item[0].Free;
      Delete(0);
   end;
   FItems.Free;
   inherited Destroy;
end;
function TUIStateList.GetItem(Index:Integer):TUIStateDetails;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=TUIStateDetails(FItems.Objects[Index])
   else
      Result:=nil
end;   
function TUIStateList.GetCount:Integer;
begin
   Result:=FItems.Count;
end;   
function TUIStateList.IndexOf(Value:String):Integer;
begin
   Result:=FItems.IndexOf(Value);
end;   
procedure TUIStateList.Delete(Index:Integer);
begin
   if (Index >= 0) and (Index < Count) then
      FItems.Delete(Index);
end;   
function TUIStateList.Add(Value:TUIStateDetails):Integer;
begin
    Result:=FItems.AddObject(Value.Name,Value);
end;   

end.
 