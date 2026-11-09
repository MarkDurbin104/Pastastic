unit TokenParser;

interface

uses
  Classes,Compress,Graphics,SysUtils,PackStrListU;

type
   // class for placing a string in the Object property of a TStrings
   TWhiteSpace = class(TObject)
   private
      Data:String;
      constructor Create(Value:String);
   end;
   
   TTokenList = class(TObject)
   private
      List:TPackStringList;
      procedure LoadListItems(InputString:String);
      procedure FreeListItems;
     function VArrayToHex(VName:String;Varr:Variant):String;
   protected
     function ConvertBitmap(Name:String;BitMap:TBitMap):String;
   public           
      constructor Create(InputString:String);
      destructor  Destroy; override;
      function    AsString:String;
      procedure   ReplaceToken(Token,WithValue:String);
      procedure   ReplaceTokenAfter(Token,WithValue:String);
      procedure   ReplaceTextBetweenTokens(SToken,EToken,WithValue:String);
      procedure   ReplaceCommaTextBetweenTokens(SToken,EToken,CommaValue:String);
      procedure   LoadFromFile(FileName:String); virtual;
      procedure   SaveToFile(FileName:String); virtual;
   end;         
   
implementation

function TTokenList.VArrayToHex(VName:String;Varr:Variant):String;
var
  Size:Integer;
  Data:PChar;
  I:Integer;
begin
   Size:=VarArrayHighBound(Varr,1) ;
   Data:=VarArrayLock(Varr);
   try
      Result:=#13#10'const'#13#10'  '+VName+'Size = '+IntToStr(Size+1)+';'#13#10'  '+VName+':Array[0..'+VName+'Size-1] of Byte = ('#13#10'    ';
      for I:=0 to Size do
      begin
         if I = Size then
            Result:=Result+'$'+IntToHex(Integer(Data[I]),2)
         else
            Result:=Result+'$'+IntToHex(Integer(Data[I]),2)+',';
         if (I mod 19) = 18 then Result:=Result+#13#10+'    ';
      end;
      Result:=Result+');'#13#10'  ';
   finally
      VarArrayUnLock(Varr); // Added by MJD
   end;
end;
function TTokenList.ConvertBitmap(Name:String;BitMap:TBitMap):String;
var
   Comp:TCompressor;
begin
   Comp:=TCompressor.Create;
   Result:=VArrayToHex(Name,Comp.CreateArrayFromBitmap(BitMap));
   Comp.Free;
end;     
{===============================================================================
  <Synopsis>     Create a TWhiteSpace
  <Description>  Create a TWhiteSpace
  <Value>        The content
________________________________________________________________________________}
constructor TWhiteSpace.Create(Value:String);
begin
   inherited Create;
   Data:=Value;
end;

{===============================================================================
  <Synopsis>     Create a Token List
  <Description>  Create a Token List and Fill the List from 'InputString'
                 where 'InputString' is CRLF delimited text i.e. 
                 as the .Text property of a TPackStringList or TMemo
  <InputString>  CRLF delimited Text
________________________________________________________________________________}
constructor TTokenList.Create(InputString:String);
begin
   inherited Create;
   LoadListItems(InputString);
end;
{===============================================================================
  <Synopsis>     Fill Token List
  <Description>  Fill List from 'InputString'
                 by breaking the string into Token/Whitespace pairs
  <InputString>  CRLF delimited Text
________________________________________________________________________________}
procedure TTokenList.LoadListItems(InputString:String);
var
   I,CP :Integer;
   Token:String;
begin
   if List = nil then 
      List:=TPackStringList.Create
   else
      FreeListItems;
      
   I:=1;
   while I <= Length(InputString) do  
   begin
      CP:=I;
      while (I <= Length(InputString)) // Build up a token
      and   (InputString[I] in ['0'..'9','A'..'Z','a'..'z','_']) do 
         Inc(I);
      if CP = I then // Zero Length Token
      begin
         if InputString[I] = #39 then // Build a string token
         begin
            Inc(I);
            while (I <= Length(InputString)) and (InputString[I] <> #39) do 
               Inc(I);
            Inc(I);
         end
         else if InputString[I] = '{' then // Build a block comment token
         begin
            Inc(I);
            while (I <= Length(InputString)) and (InputString[I] <> '}') do 
               Inc(I);
            Inc(I);
         end
         else
         begin
            Inc(I); // error in file
         end;
      end;                  
      Token:=Copy(InputString,CP,I-CP); // copy out into Token string
      CP:=I;
      while (I <= Length(InputString)) // collect White Space upto Next Token
      and   (not (InputString[I] in ['0'..'9','A'..'Z','a'..'z','{',#39,'_'])) do 
         Inc(I);
      // Add Token/Whitespace Pair to List
      List.AddObject(Token,TWhiteSpace.Create(Copy(InputString,CP,I-CP)));
   end;
end;
{===============================================================================
  <Synopsis>     Free the Objects in the List
  <Description>  Free the Objects in the List
                 i.e. the Whitespace held in the Object property
________________________________________________________________________________}
procedure TTokenList.FreeListItems;
var
   I:Integer;
begin
   if List <> nil then
      for I:=0 to List.Count-1 do
         if List.Objects[I] <> nil then
            TWhiteSpace(List.Objects[I]).Free;
   List.Clear;
end;
{===============================================================================
  <Synopsis>     Destroy the Token List
  <Description>  Destroy the Token List
________________________________________________________________________________}
destructor TTokenList.Destroy; 
begin
   FreeListItems;
   if List <> nil then List.Free;
   inherited Destroy;
end;
{===============================================================================
  <Synopsis>     Tokens as a String
  <Description>  Rebuild the Tokens into a CRLF delimited String
  <Result>       The List as a String
________________________________________________________________________________}
function TTokenList.AsString:String;
var
   I:Integer;
begin
   Result:='';
   for I:=0 to List.Count-1 do // append each Token/Whitespace pair onto Result
      Result:=Result+List[I]+TWhiteSpace(List.Objects[I]).Data;
end;
{===============================================================================
  <Synopsis>     Replace all occurances of a Token in the Token List
  <Description>  Replace all occurances of a Token in the Token List
                 with the Value 'WithValue'
                 note: this function will not remove the Whitespace 
                 between tokens
  <Token>        The Token
  <WithValue>    The Replacement Value
________________________________________________________________________________}
procedure TTokenList.ReplaceToken(Token,WithValue:String);
var                                    
   Index:Integer;
begin
   for Index:=0 to List.Count-1 do
   begin
      if List[Index] = Token then // if token found in list
         List[Index]:=WithValue;  // replace it
   end;
end;
{===============================================================================
  <Synopsis>     Replace all occurances of the item after 'Token' in the Token List
  <Description>  Replace all occurances of the item after 'Token' in the
                 Token List with the Value 'WithValue'
                 Note: This function leaves the White Space between the
                 Token and the item
  <Token>        The Token
  <WithValue>    The Replacement Value
________________________________________________________________________________}
procedure TTokenList.ReplaceTokenAfter(Token,WithValue:String);
var
   Index:Integer;
begin
   for Index:=0 to List.Count-2 do
   begin
      if List[Index] = Token then  // if token found in list
         List[Index+1]:=WithValue; // replace next token
   end;
end;
{===============================================================================
  <Synopsis>     Replace all occurances of the items between a Start Token and End Token
  <Description>  Replace all occurances of the items between a Start Token
                 and End Token with the Text 'WithValue'
                 where WithValue is a CRLF delimited String
                 note: all whitespace between SToken & EToken is removed
  <SToken>       The Start Token
  <EToken>       The End Token
  <WithValue>    The CR LF delimited Replacement Value
________________________________________________________________________________}
procedure TTokenList.ReplaceTextBetweenTokens(SToken,EToken,WithValue:String);
var
   Index:Integer;
begin
   Index:=0;
   while Index < List.Count-1 do
   begin
      if List[Index] = SToken then // found the Start Token
      begin
         TWhiteSpace(List.Objects[Index]).Data:=''; // remove the trailing WhiteSpace
         Inc(Index);
         while (List[Index] <> EToken) and (Index < List.Count-1) do
         begin
            TWhiteSpace(List.Objects[Index]).Free; // free each line between Start and End
            List.Delete(Index);
         end;
         List.InsertObject(Index,WithValue,TWhiteSpace.Create('')); // insert new lines
      end;
      Inc(Index);
   end;
end;
{===============================================================================
  <Synopsis>     Replace all occurances of the items between a Start Token and End Token
  <Description>  Replace all occurances of the items between a Start Token
                 and End Token with the Text 'WithValue'
                 where WithValue is Comma delimited String
                 note: all whitespace between SToken & EToken is removed
  <SToken>       The Start Token
  <EToken>       The End Token
  <WithValue>    The Comma delimited Replacement Value
________________________________________________________________________________}
procedure TTokenList.ReplaceCommaTextBetweenTokens(SToken,EToken,CommaValue:String);
var
   WithValue:String;
   SL:TPackStringList;
begin
   // Convert from Comma Text to CRLF Text
   SL:=TPackStringList.Create;
   SL.CommaText:=CommaValue;
   WithValue:=SL.Text; 
   SL.Free;
   // Pass to Text function
   ReplaceTextBetweenTokens(SToken,EToken,WithValue);
end;
{===============================================================================
  <Synopsis>     Load the Token List from a Text File
  <Description>  Load the Token List from a Text File
  <FileName>     the file to load
________________________________________________________________________________}
procedure TTokenList.LoadFromFile(FileName:String);
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.LoadFromFile(FileName);
   LoadListItems(SL.Text);
   SL.Free;
end;             
{===============================================================================
  <Synopsis>     Save the Token List to a Text File
  <Description>  Save the Token List to a Text File
  <FileName>     the file to save
________________________________________________________________________________}
procedure TTokenList.SaveToFile(FileName:String);
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Text:=AsString;           
   SL.SaveToFile(FileName);
   SL.Free;
end;             

end.
