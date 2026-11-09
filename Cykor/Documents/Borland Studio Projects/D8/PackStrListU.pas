unit PackStrListU;

interface

uses
  Classes,SysUtils,Variants;

type
  TPackStringList = class(TStringList)
  private
    function  GetPackText:String;
    procedure SetPackText(Value:String);
    function  GetCommaText:String;
    procedure SetCommaText(Value:String);
    function  GetVAPackText:OleVariant;
    procedure SetVAPackText(Value:OleVariant);
  public
    property CommaText  :String    read GetCommaText  write SetCommaText ;
    property PackText  :String     read GetPackText   write SetPackText  ;
    property VAPackText:OleVariant read GetVAPackText write SetVAPackText;
  end;                 
 
implementation

function Quote(S: string): string;
var
  I:Integer;
begin
  Result:='"';
  for I:=1 to Length(S) do
  begin
     if S[I] = '"' then Result:=Result+S[I];
     Result:=Result+S[I];
  end;
  Result:=Result+'"';
end;
function TPackStringList.GetCommaText:String;
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
end;
function TPackStringList.GetPackText:String;
var
   I,L,Size,Count:Integer;
   P:PChar;
   PackChar:Char;
   PC:Char;
   S:String;
begin
   PackChar:=#1;
   Count:=GetCount;
   Size:=0;
   for I:=0 to Count-1 do Inc(Size,Length(Get(I))+1);
   SetLength(Result,Size);
   P:=PChar(Result);
   for I:=0 to Count-1 do
   begin
      S:=Get(I);
      L:=Length(S);
      if (L > 0) and (S[1] in [#1..#31]) then
      begin
         PC:=Char(Integer(S[1])+1);
         if PC = #9 then PC:=#10;
         if PC > PackChar then PackChar:=PC;
      end;
   end;
   for I:=0 to Count-1 do
   begin
      S:=Get(I);
      L:=Length(S);
      P^:=PackChar;
      Inc(P);
      if L <> 0 then
      begin
         System.Move(PChar(S)^,P^,L);
         Inc(P,L);
      end;
   end;
end;
procedure TPackStringList.SetPackText(Value:String);
var                       
  P,Start:PChar;
  PackChar:Char;
  S:string;
begin
  BeginUpdate;
  try
    Clear;
    P:=PChar(Value);
    if P <> nil then
    begin
       if P^ in [#1..#31] then
       begin
          PackChar:=P^;
          Inc(P);
       end
       else
          PackChar:=#1;
       
       while P^ <> #0 do
       begin
          Start:=P;
          while not (P^ in [#0,PackChar]) do Inc(P);
          SetString(S,Start,P-Start);
          Add(S);
          if P^ = PackChar then
          begin
            Inc(P);
            If P^ = #0 then Add('');  //handle empty blank last line
          end;
       end;
    end;
  finally
    EndUpdate;
  end;
end;
function TPackStringList.GetVAPackText:OleVariant;
var
   S:String;
   Data:PChar;
   L:Integer;
begin
   S:=PackText;
   L:=Length(S);
   Result:=VarArrayCreate([1,L],varByte);
   try
      Data:=VarArrayLock(Result);
      System.Move(PChar(S)^,Data^,L);
   finally
      VarArrayUnlock(Result);
   end;
end;
procedure TPackStringList.SetVAPackText(Value:OleVariant);
var
   S:String;
   L:Integer;
   Data:PChar;
begin
   L:=VarArrayHighBound(Value,1);
   SetLength(S,L);
   Data:=VarArrayLock(Value);
   try
      System.Move(Data^,PChar(S)^,L);
   finally
      VarArrayUnLock(Value);
   end;
   PackText:=S;
end;

end.
