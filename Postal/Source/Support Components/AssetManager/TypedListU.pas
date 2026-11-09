unit TypedListU;

interface

uses
	Classes;

type
	TObjectClass = class of TObject;

  TTypedList = class(TObject)
  private
     FItems	:	TList;
  protected
     function GetItem(Index:Integer)	:	TObject;virtual;
     function GetCount	:	Integer; virtual;
  public
     function 		Add(Value:TObject):Integer; virtual;
     constructor 	Create; virtual;
     procedure 		Delete(Index:Integer); virtual;
     destructor 	Destroy; override;
     function 		IndexOf(Value : TObject):Integer; virtual;
     function 		Remove(Value:TObject) : Integer; virtual;

     property Item[Index:Integer]	:	TObject read GetItem; default;
     property Count:Integer read GetCount;
  end;

implementation
{TTypedList}

function TTypedList.Add(Value:TObject):Integer;
begin
    Result:=FItems.Add(Value);
end;

constructor TTypedList.Create;
begin
   inherited Create;
   FItems:=TList.Create;
end;

procedure TTypedList.Delete(Index:Integer);
begin
   if (Index >= 0) and (Index < Count) then
      FItems.Delete(Index);
end;

destructor TTypedList.Destroy;
begin
{
   while Count > 0 do
   begin
      Item[0].Free;
      Delete(0);
   end;
}
   FItems.Free;
   inherited Destroy;
end;

function TTypedList.GetItem(Index:Integer): TObject;
begin
   if (Index >= 0) and (Index < Count) then
   begin
   	Result:=TObject(FItems[Index]);
   end
   else
      Result:=nil
end;

function TTypedList.GetCount:Integer;
begin
   Result:=FItems.Count;
end;

function TTypedList.IndexOf(Value : TObject):Integer;
begin
   Result:=FItems.IndexOf(Value);
end;

function TTypedList.Remove(Value : TObject) : Integer;
begin
	Result := FItems.Remove(Value);
end;

end.
