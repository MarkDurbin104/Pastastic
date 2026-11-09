unit WideStringListU;

interface

uses
  Classes,SysUtils;

//type
{  TWideStringList = class(TObject)
    private
       FList:TList;
       function Get(Index:Integer):WideString;
       procedure Put(Index:Integer;Value:WideString);
    public
       constructor Create;
       destructor Destroy; override;
       function Add(Value:WideString):Integer;
       function AddObject(Value:WideString;AnObject:TObject):Integer;
       procedure Delete(Index:Integer);
       function Count:Integer;
       
//    property CommaText  :String    read GetCommaText  write SetCommaText ;
  end; }
  
implementation

{function Quote(S: string): string;
var
  P:PChar;
  R:PChar;
begin
  SetLength(Result,(Length(S)*2)+2);
  P:=PChar(S);
  R:=PChar(Result);
  R^:='"';
  Inc(R);
  while P^ <> #0 do
  begin
     if P^ = '"' then
     begin
        R^:='"';
        Inc(R);
     end;
     R^:=P^;
     Inc(R);
     Inc(P);
  end;
  R^:='"';
  Inc(R);
  SetLength(Result,R-PChar(Result));
end;
function GetCommaText:String;
var
  S:String;
  SP:PChar;
  R:PChar;
  L,I,Count,Ofs,MaxLen:Integer;
begin
  MaxLen:=5000;
  Count := GetCount;
  if Count = 0 then
  begin
    Result:='';
  end
  else if (Count = 1) and (Get(0) = '') then
    Result := '""'
  else
  begin
    SetLength(Result,MaxLen);
    SP:=PChar(Result);
    R:=SP;
    for I := 0 to Count - 1 do
    begin
      S:=Quote(Get(I));
      L:=Length(S);
      if L+(R-SP) > MaxLen then
      begin
         Ofs:=(R-SP);
         Inc(MaxLen,5000+L);
         SetLength(Result,MaxLen);
         SP:=PChar(Result);
         R:=SP;
         Inc(R,Ofs);
      end;           
      System.Move(PChar(S)^,R^,L);
      Inc(R,L);
      if I < (Count - 1) then
      begin
         R^:=',';
         Inc(R);
      end;
    end;
    if (R-SP) > 0 then
       SetLength(Result,(R-SP))
    else
       SetLength(Result,0);
  end;
end;
function ExtractQuotes(var S:PChar): string;
begin
  Result := '';
  Inc(S);
  while S^ <> #0 do
  begin
     if (S^ = '"') then
     begin
        Inc(S);
        if (S^ = '"') then
           Result:=Result+'"'
        else
           Exit;
     end
     else
       Result:=Result+S^;
     Inc(S);
  end;
end;
procedure TPackStringList.SetCommaText(Value:String);
var
  P, P1: PChar;
  S: string;
begin
  BeginUpdate;
  try
    Clear;
    P := PChar(Value);
    while P^ <> #0 do
    begin
      if P^ = '"' then
        S := ExtractQuotes(P)
      else
      begin
        P1 := P;
        while (P^ <> #0) and (P^ <> ',') do Inc(P);
        SetString(S, P1, P - P1);
      end;
      Add(S);
      if P^ = ',' then Inc(P);
    end;
  finally
    EndUpdate;
  end;
end;}

end.
