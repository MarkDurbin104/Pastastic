unit Bin2String;

interface

function BinaryToString(S:String):String;
function StringToBinary(S:String):String;

implementation
function TriToQuad(C1,C2,C3:Char):String;
var
   Work:Integer;
begin
   SetLength(Result,4);
   Work:=(Byte(C1) shl 16) or (Byte(C2)shl 8) or Byte(C3);
   
   Result[1]:=Char(((Work shr 18) and $3F)+Ord(' ')); if Result[1] = #39 then Result[1]:='a'; if Result[1] = '"' then Result[1]:='b';
   Result[2]:=Char(((Work shr 12) and $3F)+Ord(' ')); if Result[2] = #39 then Result[2]:='a'; if Result[2] = '"' then Result[2]:='b';
   Result[3]:=Char(((Work shr  6) and $3F)+Ord(' ')); if Result[3] = #39 then Result[3]:='a'; if Result[3] = '"' then Result[3]:='b';
   Result[4]:=Char(((Work       ) and $3F)+Ord(' ')); if Result[4] = #39 then Result[4]:='a'; if Result[4] = '"' then Result[4]:='b';
end;
function QuadToTri(C1,C2,C3,C4:Char):String;
var
   Work:Integer;
begin
   SetLength(Result,3);
   if C1 = 'a' then C1:=#39; if C1 = 'b' then C1:='"';
   if C2 = 'a' then C2:=#39; if C2 = 'b' then C2:='"';
   if C3 = 'a' then C3:=#39; if C3 = 'b' then C3:='"';
   if C4 = 'a' then C4:=#39; if C4 = 'b' then C4:='"';
   Dec(C1,Ord(' '));
   Dec(C2,Ord(' '));
   Dec(C3,Ord(' '));
   Dec(C4,Ord(' '));
   Work:=(Byte(C1) shl 18) or (Byte(C2)shl 12) or (Byte(C3)shl 6) or Byte(C4);
   
   Result[1]:=Char((Work shr 16) and $FF);
   Result[2]:=Char((Work shr  8) and $FF);
   Result[3]:=Char((Work       ) and $FF);
end;
function BinaryToString(S:String):String;
var
   Add,I:Integer;
   Quad:String;
   InOffSet :Integer;
   OutOffSet:Integer;
begin
   Add:=((Length(S)+1) mod 3);
        if Add = 1 then S:='2'+S+'  '
   else if Add = 2 then S:='1'+S+' '
   else                 S:='0'+S;
   SetLength(Result,(Length(S) div 3) *4);
   InOffSet :=1;
   OutOffSet:=1;
   for I:=1 to Length(S) div 3 do
   begin
      Quad:=TriToQuad(S[InOffSet+0],S[InOffSet+1],S[InOffSet+2]);
      Inc(InOffSet,3);
      Result[OutOffSet]:=Quad[1];
      Inc(OutOffSet);
      Result[OutOffSet]:=Quad[2];
      Inc(OutOffSet);
      Result[OutOffSet]:=Quad[3];
      Inc(OutOffSet);
      Result[OutOffSet]:=Quad[4];
      Inc(OutOffSet);
   end;
end;
function StringToBinary(S:String):String;
var
   I:Integer;
   Trip:String;
   InOffSet :Integer;
   OutOffSet:Integer;
begin
   SetLength(Result,(Length(S) div 4) *3);
   InOffSet :=1;
   OutOffSet:=1;
   for I:=1 to Length(S) div 4 do
   begin
      Trip:=QuadToTri(S[InOffSet+0],S[InOffSet+1],S[InOffSet+2],S[InOffSet+3]);
      Inc(InOffSet,4);
      Result[OutOffSet]:=Trip[1];
      Inc(OutOffSet);
      Result[OutOffSet]:=Trip[2];
      Inc(OutOffSet);
      Result[OutOffSet]:=Trip[3];
      Inc(OutOffSet);
   end;
        if Result[1] = '2' then Result:=Copy(Result,2,Length(Result)-2)
   else if Result[1] = '1' then Result:=Copy(Result,2,Length(Result)-1)
   else Result:=Copy(Result,2,Length(Result));
end;

end.
