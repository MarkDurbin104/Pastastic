unit TokenParser;

interface

uses
  Windows,Classes,Compress,Graphics,SysUtils,PackStrListU;

type
   // class for placing a string in the Object property of a TStrings
   TWhiteSpace = class(TObject)
   private
      Data:String;
      constructor Create(Value:String);
   end;
   
   TTokenList = class(TObject)
   private
      procedure LoadListItems(InputString:String);
      procedure FreeListItems;
     function VArrayToHex(VName:String;Varr:Variant):String;
   protected
     List:TPackStringList;
     function ConvertBitmap(Name:String;BitMap:TBitMap):String;
   public
      constructor Create(InputString:String); virtual;
      destructor  Destroy; override;
      function    AsString:String;
      procedure   AssignData(Another:TTokenList);
      procedure   InsertData(Index:Integer;Another:TTokenList);
      procedure   InsertString(Index:Integer;Value:String);
      procedure   ReplaceToken(Token,WithValue:String);
      procedure   ReplaceTokenAfter(Token,WithValue:String);
      procedure   ReplaceTextBetweenTokens(SToken,EToken,WithValue:String);
      procedure   ReplaceCommaTextBetweenTokens(SToken,EToken,CommaValue:String);
      procedure   LoadFromFile(FileName:String); virtual;
      procedure   LoadFromString(S:String); virtual;
      procedure   SaveToFile(FileName:String); virtual;
   end;         
  TOPThread = class(TThread)
  public
     TokenList:TTokenList;
     FileName:String;
     procedure Execute; override;
  end;

implementation

function TTokenList.VArrayToHex(VName:String;Varr:Variant):String;
var
  Size:Integer;
  Data:PChar;
  I:Integer;
  SL:TPackStringList;
  S:String;
begin
   SL:=TPackStringList.Create;
   Size:=VarArrayHighBound(Varr,1) ;
   Data:=VarArrayLock(Varr);
   try
      SL.Add('');
      SL.Add('const');
      SL.Add('  '+VName+'Size = '+IntToStr(Size+1)+';');
      SL.Add('  '+VName+':Array[0..'+VName+'Size-1] of Byte = (');
      S:='    ';
      for I:=0 to Size do
      begin
         if I = Size then
            S:=S+'$'+IntToHex(Integer(Data[I]),2)
         else
            S:=S+'$'+IntToHex(Integer(Data[I]),2)+',';
         if (I mod 80) = 79 then 
         begin
            SL.Add(S);
            S:='    ';
         end;
      end;
      S:=S+');';
      SL.Add(S);
      Result:=SL.Text+'  ';
      SL.Free;
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
procedure TTokenList.AssignData(Another:TTokenList);
var
   I:Integer;
   WS:TWhiteSpace;
begin
   if List = nil then 
      List:=TPackStringList.Create
   else
      FreeListItems;
   for I:=0 to Another.List.Count-1 do
   begin
      WS:=TWhiteSpace.Create(TWhiteSpace(Another.List.Objects[I]).Data);
      List.AddObject(Another.List[I],WS);
   end;
//   List.Assign(Another.List);
end;
procedure TTokenList.InsertData(Index:Integer;Another:TTokenList);
var
   I:Integer;
   WS:TWhiteSpace;
begin
   if List = nil then 
   begin
      AssignData(Another);
      Exit;
   end;
   for I:=0 to Another.List.Count-1 do
   begin
      WS:=TWhiteSpace.Create(TWhiteSpace(Another.List.Objects[I]).Data);
      List.InsertObject(Index,Another.List[I],WS);
      Inc(Index);
   end;
end;
procedure TTokenList.InsertString(Index:Integer;Value:String);
var
   Another:TTokenList;
begin
   Another:=TTokenList.Create(Value);
   InsertData(Index,Another);
   Another.Free;
end;
{===============================================================================
  <Synopsis>     Fill Token List
  <Description>  Fill List from 'InputString'
                 by breaking the string into Token/Whitespace pairs
  <InputString>  CRLF delimited Text
________________________________________________________________________________}
procedure TTokenList.LoadListItems(InputString:String);
var
//   I,CP :Integer;
   Token:String;
   White:String;
   SP,EP:PChar;
begin
   if List = nil then 
      List:=TPackStringList.Create
   else
      FreeListItems;
      
//   I:=1;
   SP:=PChar(InputString);
   while SP^ <> #0 do  
   begin
      EP:=SP;
      while (EP^ <> #0) // Build up a token
      and   (EP^ in ['0'..'9','A'..'Z','a'..'z','_']) do 
         Inc(EP);
      if SP = EP then // Zero Length Token
      begin
         if EP^ = #39 then // Build a string token
         begin
            Inc(EP);
            while (EP^ <> #0) and (EP^ <> #39) do 
               Inc(EP);
            Inc(EP);
         end
         else if EP^ = '{' then
         begin
            Inc(EP);
            while (EP^ <> #0) and (EP^ <> '}') do 
               Inc(EP);
            Inc(EP);
         end
         else
         begin
            Inc(EP);
         end;
      end;                  
      SetString(Token,SP,EP-SP);
      SP:=EP;
      while (EP^ <> #0) // collect White Space upto Next Token
      and   (not (EP^ in ['0'..'9','A'..'Z','a'..'z','{','}',#39,'_'])) do 
         Inc(EP);
      // Add Token/Whitespace Pair to List
      SetString(White,SP,EP-SP);
      SP:=EP;
      List.AddObject(Token,TWhiteSpace.Create(White));
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
   Len:Integer;
   P:PChar;
   S:String;
begin
   Len:=0;
   for I:=0 to List.Count-1 do
   begin
      Inc(Len,Length(List[I]));
      Inc(Len,Length(TWhiteSpace(List.Objects[I]).Data));
   end;
   SetLength(Result,Len);
   P:=@Result[1];
   for I:=0 to List.Count-1 do // append each Token/Whitespace pair onto Result
   begin
      Len:=Length(List[I]);
      CopyMemory(P,@(List[I][1]),Len);
      Inc(P,Len);
      S:=TWhiteSpace(List.Objects[I]).Data;
      Len:=Length(S);
      CopyMemory(P,@S[1],Len);
      Inc(P,Len);
   end;
//   Result:=Result+List[I]+TWhiteSpace(List.Objects[I]).Data;
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
   FIndex:Integer;
begin                   
   FIndex:=List.IndexOf(Token);
   if FIndex = -1 then Exit;
   for Index:=FIndex to List.Count-1 do
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
   FIndex:Integer;
begin
   FIndex:=List.IndexOf(Token);
   if FIndex = -1 then Exit;
   for Index:=FIndex to List.Count-2 do
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
   Index:=List.IndexOf(SToken);
   if Index = -1 then Exit;
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
         InsertString(Index,WithValue);
//         List.InsertObject(Index,WithValue,TWhiteSpace.Create('')); // insert new lines
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
procedure TTokenList.LoadFromString(S:String);
begin
   LoadListItems(S);
end;
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
{TOPThread}
procedure TOPThread.Execute;
begin
   TokenList.SaveToFile(FileName);
end;

end.
