unit CompressU;
{$A+ O+ R-}

Interface

uses SysUtils,Forms,Windows;

type Int16 = SmallInt;

const
    BufferMaxSize = 32768;
    BufferMax     = BufferMaxSize-1;
    FLAG_Copied   = $80;
    FLAG_Compress = $40;
    MarkerString  = 'C0R7';
    MaxBlockSize  = 16384;
    
type
    BufferIndex   = 0..BufferMax + 15;
    BufferSize    = 0..BufferMaxSize;
    Bufferarray   = array [BufferIndex] of BYTE;
    BufferPtr     = ^Bufferarray;
    HashTable     = array [0..4095] of Int16;
    HashTabPtr    = ^Hashtable;

    TCompress = class(TObject)
    private
      Hash : HashTable;
      function Compression(Source,Dest:BufferPtr;SourceSize:BufferSize):BufferSize;
      function Decompression(Source,Dest:BufferPtr;SourceSize:BufferSize):BufferSize;
      function GetMatch(Source:BufferPtr;X:BufferIndex;SourceSize:BufferSize;
                        Hash:HashTabPtr;var Size:WORD;var Pos:BufferIndex):Boolean;
      function CompressBlock(Input:String):String;
      function DeCompressBlock(Input:String):String;
      function DigToInt(Value:String):Integer;
      function IntToDig(Value:Integer):String;
    public     
      function CompressString(Input:String):String;
      function isCompressed(Input:String):Boolean;
    end;  

implementation

function TCompress.GetMatch(Source:BufferPtr;X:BufferIndex;SourceSize:BufferSize;
                  Hash:HashTabPtr;var Size:WORD;var Pos:BufferIndex):Boolean;
var
  HashValue      : WORD;
  TmpHash        : Int16;
begin
  HashValue := (40543*((((Source^[X] shl 4) xor Source^[X+1]) shl 4) xor
                                     Source^[X+2]) shr 4) and $0FFF;
  Result := FALSE;
  TmpHash := Hash^[HashValue];
  if  (TmpHash <> -1) and (X - TmpHash < 4096) then 
  begin
    Pos := TmpHash;
    Size := 0;
    while ((Size < 18) 
    and (Source^[X+Size] = Source^[Pos+Size])
    and (X+Size < SourceSize)) do 
    begin
      INC(Size);
    end;
    Result := (Size >= 3)
  end;
  Hash^[HashValue] := X
end;
                                    { compress a buffer of max. 32 KB }
function TCompress.Compression(Source,Dest:BufferPtr;SourceSize:BufferSize):BufferSize;
var
  Bit,Command,Size:Word;
  Key             :Word;
  X,Y,Z,Pos       :BufferIndex;
begin
  FillChar(Hash,SizeOf(Hashtable), $FF);
  Dest^[0] := FLAG_Compress;
  X := 0;
  Y := 3;
  Z := 1;
  Bit := 0;
  Command := 0;
  while (X < SourceSize) and (Y <= SourceSize) do 
  begin
    if  (Bit > 15) then 
    begin
      Dest^[Z] := HI(Command);
      Dest^[Z+1] := LO(Command);
      Z := Y;
      Bit := 0;
      INC(Y,2)
    end;
    Size := 1;
    while ((Source^[X] = Source^[X+Size]) 
    and (Size < $FFF)
    and (X+Size < SourceSize)) do 
    begin
       INC(Size);
    end;
    if (Size >= 16) then 
    begin
      Dest^[Y] := 0;
      Dest^[Y+1] := HI(Size-16);
      Dest^[Y+2] := LO(Size-16);
      Dest^[Y+3] := Source^[X];
      INC(Y,4);
      INC(X,Size);
      Command := (Command shl 1) + 1;
    end
    else 
    begin { not size >= 16 }
      if  (GetMatch(Source,X,SourceSize,@Hash,Size,Pos)) then 
      begin
        Key := ((X-Pos) shl 4) + (Size-3);
        Dest^[Y] := HI(Key);
        Dest^[Y+1] := LO(Key);
        INC(Y,2);
        INC(X,Size);
        Command := (Command shl 1) + 1
      end
      else 
      begin
        Dest^[Y] := Source^[X];
        INC(Y);
        INC(X);
        Command := Command shl 1
      end;
    end; { size <= 16 }
    INC(Bit);
  end; { while x < sourcesize ... }
  Command := Command shl (16-Bit);
  Dest^[Z] := HI(Command);
  Dest^[Z+1] := LO(Command);
  if (Y > SourceSize) then 
  begin
    MOVE(Source^[0],Dest^[1],SourceSize);
    Dest^[0] := FLAG_Copied;
    Y := SUCC(SourceSize)
  end;
  Result := Y
end;
                                    { decompress a buffer of max 32 KB }
function TCompress.Decompression(Source,Dest:BufferPtr;SourceSize:BufferSize):BufferSize;
var
  X,Y,Pos        :BufferIndex;
  Command,Size,K :WORD;
  Bit            :BYTE;
begin
  if SourceSize <= 1 then 
  begin
    Result:=0;
    Exit;
  end;
  if Source^[0] = FLAG_Copied then  
  begin
    Result:=PRED(SourceSize);
    MOVE(Source^[1],Dest^[0],PRED(SourceSize));
    Exit;
  end;
  try
     Y:=0;
     X:=3;
     Command:=(Source^[1] shl 8) + Source^[2];
     Bit:=16;
     while X < SourceSize do 
     begin
       if Bit = 0 then 
       begin
         Command:=(Source^[X] shl 8) + Source^[X+1];
         Bit:=16;
         INC(X,2)
       end;
       if  ((Command and $8000) = 0) then 
       begin
          Dest^[Y]:=Source^[X];
          INC(X);
          INC(Y)
       end
       else 
       begin
          Pos:=((Source^[X] shl 4) +(Source^[X+1] shr 4));
          if Pos = 0 then 
          begin
             Size:=(Source^[X+1] shl 8) + Source^[X+2] + 15;
             for K:=0 TO Size do 
             begin
                Dest^[Y+K]:=Source^[X+3];
             end;
             INC(X,4);
             INC(Y,Size+1)
          end
          else 
          begin
             Size:=(Source^[X+1] and $0F)+2;
             for K:=0 TO Size DO
                Dest^[Y+K]:=Dest^[Y-Pos+K];
             INC(X,2);
             INC(Y,Size+1)
          end;
       end;
       Command:=Command shl 1;
       DEC(Bit);
     end;
     Result := Y;
  except
     Source^[0]:=FLAG_Copied;
     Result:=SUCC(SourceSize);
     MOVE(Source^[1],Dest^[0],SourceSize);
  end;           
end;

function TCompress.CompressBlock(Input:String):String;
var
   CompSize:Integer;
   InputSize:Integer;
   CompStr:String;
begin
   InputSize:=Length(Input);
   if  InputSize < MaxBlockSize then 
   begin
      SetLength(CompStr,InputSize*2);
      CompSize:=Compression(Pointer(Input),Pointer(CompStr),InputSize);
      SetLength(CompStr,CompSize);
      SetLength(Result,CompSize);
      Result:=CompStr;
   end;
end;
function TCompress.DeCompressBlock(Input:String):String;
var
   DeCompSize:Integer;
   InputSize:Integer;
   DeCompStr:String;
begin
    InputSize:=Length(Input);
    SetLength(DeCompStr,MaxBlockSize+1);
    DeCompSize:=DeCompression(Pointer(Input),Pointer(DeCompStr),InputSize);
    SetLength(DeCompStr,DeCompSize);
    Result:=DeCompStr;
end;
function TCompress.DigToInt(Value:String):Integer;
var
  I:Integer;
begin
   Result:=0;
   for I:=1 to Length(Value) do
   begin
      Result:=Result shl 7;
      Inc(Result,Byte(Value[I])-1);
   end;
end;
function TCompress.IntToDig(Value:Integer):String;
begin
   Result:='';
   Result:=Result+Char(((Value and $3F80) shr 7)+1);
   Result:=Result+Char(((Value and $007F)      )+1);
end;
function TCompress.CompressString(Input:String):String;
var
   CurrentBlock:String;
   CurrentLength:Integer;
   Position:Integer;
begin
   if  Copy(Input,1,Length(MarkerString)) = MarkerString then // decompress
   begin
      Position:=Length(MarkerString)+1;
      Result:='';
      while Position < Length(Input) do
      begin
         CurrentLength:=DigToInt(Copy(Input,Position,2));
         Inc(Position,2);
         Result:=Result+DeCompressBlock(Copy(Input,Position,CurrentLength));
         Inc(Position,CurrentLength);
      end;
   end
   else
   begin
      Position:=0;
      Result:=MarkerString;
      CurrentLength:=Length(Input);
      while Position < Length(Input) do
      begin
         if  Position+(MaxBlockSize-1) > Length(Input) then
         begin
            CurrentLength:=(Length(Input)-Position);
            CurrentBlock:=Copy(Input,Position+1,CurrentLength);
         end
         else
         begin
            if  CurrentLength > 0 then
            CurrentLength:=MaxBlockSize-1;
            CurrentBlock:=Copy(Input,Position+1,CurrentLength);
         end;
         CurrentBlock:=CompressBlock(CurrentBlock);
         Result:=Result+IntToDig(Length(CurrentBlock))+CurrentBlock;
         Inc(Position,CurrentLength);
      end;
   end;
end;
function TCompress.isCompressed(Input:String):Boolean;
begin
   Result:=(Copy(Input,1,Length(MarkerString)) = MarkerString);
end;

end.

