unit StringUtil;

interface
uses
  GPCSGUID,
  Math,
  Classes,
  Dialogs,
	Windows,
	StdCtrls,
	PackStrListU,
  SysUtils;

type

  TStringObject = class(TObject)
  private
    FValue : String;
    procedure SetValue(NewValue : String);
  public
    Strings : TStringList;
    property Value : String read FValue write SetValue;
    constructor Create(Str:String);
    destructor Destroy; override;
    function ContainsString(AString : String) : Boolean;
  end;

function CommaTextToPackText(TheCommaText : String)  : String;
//converts a commatext string to packtext

function ContainsSubString(SearchString, SubString : String) : Boolean;
//whether search string contains the substring

function ConvertFigureToWords(const Figure : Double; Whole, Fract : String) : string;
//converts a commatext string to packtext 1.02 = 1 'Whole' and 2 'Fract'

function CountStr(SubString : String; SearchString : String) : Integer;
//counts number of occurrences of Substring in SearchString

procedure CurrencyKeyPress(Sender : TCustomEdit; var Key : Char);
//checks keypresses when entering a float value

function DeSpace(SearchString, ReplaceString : String) : String;
//replaces spaces in saerchstring with replace string

function DoubleQuote(StringToQuote : String) : String;
//puts double quotes around string

function FindParamIndex(ParamName : String) : Integer;
//returns index of parameter or -1

function FindPartial(PartialSearch : String; SearchList : TStrings) : Integer;
//finds index of partial matched string in (un)sorted lists

function LeftString(SearchString : String; NumChars : Integer)  :String;
//returns leftmost characters from a string

function LeftStringExcept(SearchString : String; NumChars : Integer) : String;
//returns leftmost part of string without the numchars from end of string

function LeftOf(SearchString, SubString : String) : Boolean;
//determines whether left side of search string is the substring

function PackTextToCommaText(ThePackText : String)  : String;
//converts a packtext string to commatext

function RightString(SearchString : String; NumChars : Integer)  :String;
//returns rightmost characters from a string

function RightStringExcept(SearchString : String; NumChars : Integer)  :String;
//returns rightmost characters from a string except number of characters

function RightOf(SearchString, SubString : String) : Boolean;
//determines whether right side of search string is the substring

function LeftPad(UnPaddedString : String; ReqdLength : Integer; PadString : String) : String;
//pads string to reqd length

function Centre(UnCentredString : String; ReqdLength : Integer; PadString : String) : String;
//centres string

function DelimitedString(SearchString, Delimiter : String; After : Boolean) : String;
//returns string up until (or after) the first delimiter working from left to right

function ReverseDelimitedString(SearchString, Delimiter : String; After : Boolean) : String;
//returns string up until (or after) the first delimiter working from right to left

function EnsureSuffix(SearchString : String; Suffix : String) : String;
//returns string with suffix string (if it was not already there

function LastWord(SearchString : String) : String;
//returns last word in SearchString (defined by SPACE before word)

function TransposeCommaText(HorizCommaTExt : String; Offset : Integer) : String;
//transposes horizontal commatext of strings to vertical for receipt rotated printing

function Mod11(Code:Integer):Char;
//UPU checksum

function PosOccurrence(SubString: string; SearchString: string; Occurrence : Integer): Integer;
//returns the position of the occurrence of SubStr in SearchString

function RandomString(ReqdLength : Integer) : String;
//returns a random ASCII string of required length

function Replace(OriginalString,SearchString,ReplaceString : String) : String;
//replaces search string with replace string in original string and returns changed string

function ReplaceSubString(OriginalString, StartTag, EndTag, ReplaceString : String) : String;
//replaces string between tags in original string

function RemoveNumbers(OriginalString:String):String;
//returns original string with numbers removed

function RemoveLetters(OriginalString:String):String;
//returns original string with letters a..z and A..Z removed

function RightPad(UnPaddedString : String; ReqdLength : Integer; PadString : String) : String;
//pads string to reqd length

function StrToCurrStrDef(CurrencyString : String; Default : Currency) : String ;
// converts a string to a string formatted according to control panel currency settings

function StrToFloatDef(FloatString : String; DefaultValue : Double) : Double;
//converts string to float with a default value

function StrToDateDef(DateS:String;DefDateTime:TDateTime):TDateTime;
//converts string to a date of TDateTime with a default value

function SubString(MainString : String; StartTag : String; EndTag : String) : String;
//returns substring between tags in main string

function Wrap(LinesToWrapCommaText : String; Column : Integer; BreakOnWord : Boolean) : String;
//wraps lines at column with option to break on on word breaks

function HasGotAlphaChar( S:String ) : boolean ;
// returns true if it can find any character no numeric! (A-Z)

implementation

constructor TStringObject.Create(Str:String);
begin
   inherited Create;
   Strings := TStringList.Create;
   Value:=Str;
end;

destructor TStringObject.destroy;
begin
  Strings.Free;
  inherited Destroy;
end;

function TStringObject.ContainsString(AString : String) : Boolean;
begin
  Result := (Strings.IndexOf(AString) > -1);
end;

procedure TStringObject.SetValue(NewValue : String);
begin
  If NewValue <> Value then
  begin
    FValue := NewValue;
    Strings.Commatext := NewValue;
  end;
end;

function CommaTextToPackText(TheCommaText : String)  : String;
//converts a commatext string to packtext
begin
   With TPackStringList.Create do
   begin
      try
         CommaText := TheCommaText;
         Result := PackText;
      finally
         Free;
      end;
   end;
end;

function ContainsSubString(SearchString, SubString : String) : Boolean;
//whether search string contains the substring
begin
  Result := Pos(SubString, SearchString) <> 0
end;

procedure CurrencyKeyPress(Sender : TCustomEdit; var Key : Char);
//checks keypresses when entering a float value
var
	DecimalPos : Integer;
begin
	DecimalPos := Pos(DecimalSeparator,Sender.Text);

	If Key in [Char(VK_DELETE), Char(VK_BACK)] then  //always valid
			//allow key
	else If (Key = '-') and (Sender.SelStart = 0) then
			//allow -ve when at start
	else If (Key = DecimalSeparator) and  (DecimalPos > 0) then//single decimal place
		Key := #0
	else If (DecimalPos > 0) and ((Length(Sender.Text) - DecimalPos+1) > CurrencyDecimals) then //number decimal places
		Key := #0
	else If not (Key in ['0'..'9',DecimalSeparator]) then  //valid numeric keys
		Key := #0;

end;

function DoubleQuote(StringToQuote : String) : String;
//puts double quotes around string
begin
	If Copy(StringToQuote,1,1) = '"' then
		Result := StringToQuote
  else
    Result := '"' + StringToQuote + '"';
end;

function FindParamIndex(ParamName : String) : Integer;
//returns index of parameter or -1
var
  ParamIndex : Integer;
begin
  Result := -1;
  For ParamIndex := 1 to ParamCount  do
  begin

    If UpperCase(ParamName) = Copy(UpperCase(ParamStr(ParamIndex)),2,999) then
    begin
      Result := ParamIndex;
    end;
  end;
end;

function ConvertFigureToWords(const Figure : Double; Whole, Fract : String) : string;
var
  FormattedString, PartString :  string;
  PartGroup,GroupsToProcess : integer;
  Big : array[0..5] of string;

const

  Tens: array[2..9] of string = ('Twenty ', 'Thirty ', 'Forty ', 'Fifty ',
                                 'Sixty ', 'Seventy ', 'Eighty ', 'Ninety ');

  Odds: array[0..19] of string = ('', 'One ', 'Two ', 'Three ', 'Four ',
                                  'Five ', 'Six ', 'Seven ', 'Eight ', 'Nine ',
                                  'Ten ', 'Eleven ', 'Twelve ', 'Thirteen ',
                                  'Fourteen ', 'Fifteen ', 'Sixteen ',
                                  'Seventeen ', 'Eighteen ', 'Nineteen ');

  function IntegerString(IntValue : Integer) : String;
  begin
    Case IntValue of
      0..19   : Result := Odds[IntValue];
      20..99  : Result := Tens[IntValue div 10] + IntegerString(IntValue mod 10);
      100..999: begin
                  Result := Odds[IntValue div 100] + 'Hundred ';
                  If (IntValue mod 100) > 0 then Result := Result + 'and ' + IntegerString(IntValue mod 100);
                end;
      else    Result := ''
    end;
  end;

begin

  Result := '';

  Big[0] := 'Billion ';
  Big[1] := 'Million ';
  Big[2] := 'Thousand ';

  PartString := '';  Result := '';
  FormattedString := Formatfloat('000000000000.00', Figure);

  { The integer part contains 12 digits where they will be processed
    in groups of 3 digits which maDigitValuees a total of 4 groups whereas
    the leftmost will be the first. }

  if Frac( Figure ) > 0 then GroupsToProcess := 4
  else GroupsToProcess := 3;

  for PartGroup := 0 to GroupsToProcess do
  begin
    PartString := Copy(FormattedString, PartGroup*3+1, 3);
    if PartString[1] = '.' then PartString[1] := '0';
    if StrToInt(PartString)  = 0 then
      Continue
    else
    begin //this group is non-zero
      If PartGroup = 4 then
      begin
        Result := Result + Whole; //starting fraction
        If Trunc(Figure) > 1 then Result := Result + 's';
        Result := Result + ' ';         
      end;

      If (StrToInt(PartString) < 100) and (Result<>'') then Result := Result + 'and ';
      Result := Result + IntegerString(StrToInt(PartString)) + Big[PartGroup];

      //
      If (Frac(Figure) = 0) and (PartGroup = GroupsToProcess) then
      begin
        Result := Result + Whole;
        If Trunc(Figure) > 1 then Result := Result + 's';
      end;
    end;
  end;  {for}
  //add fraction suffix
  If Frac(Figure) > 0 then
    Result := Result + Fract;
  Result := Result;

end;

function PackTextToCommaText(ThePackText : String)  : String;
//converts a packtext string to commatext
begin
  With TPackStringList.Create do
  begin
    try
      PackText := ThePackText;
      Result := CommaText;
    finally
      Free;
    end;
  end;
end;

function Mod11(Code:Integer):Char;
//UPU checksum
var
   res:Integer;
   chkval:Integer;
begin
    chkval:=86423597;
    res	:=	0;
    while code > 0 do
    begin
        res			:=	res+(chkval mod 10)*(code mod 10);
        code		:=	code div 10;
        chkval	:=	chkval div 10;
    end;
    res	:=	res mod 11;
    if res = 0 then
       Result	:=	#53
    else if res = 1 then
       Result	:=	#48
    else
       Result	:=	Char((11-res)+48);
end;


function LeftString(SearchString : String; NumChars : Integer)  :String;
//returns leftmost characters from a string
begin
	Result := Copy(SearchString, 1, NumChars);
end;

function LeftStringExcept(SearchString : String; NumChars : Integer) : String;
//returns leftmost part of string without the numchars from end of string
begin
  Result := LeftString(SearchString, Length(SearchString) - NumChars);
end;

function LeftOf(SearchString, SubString : String) : Boolean;
//determines whether left side of search string is the substring
begin
  Result := (SubString = LeftString(SearchString, Length(SubString)));
end;

function RightString(SearchString : String; NumChars : Integer)  :String;
//returns rightmost characters from a string
begin
	Result := Copy(SearchString, Length(SearchString) - NumChars + 1, NumChars);
end;

function RightStringExcept(SearchString : String; NumChars : Integer)  :String;
//returns rightmost characters from a string except number of characters
begin
	Result := Copy(SearchString, NumChars + 1, Length(SearchString) - NumChars );
end;

function RightOf(SearchString, SubString : String) : Boolean;
//determines whether left side of search string is the substring
begin
  Result := (SubString = RightString(SearchString, Length(SubString)));
end;

function Centre(UnCentredString : String; ReqdLength : Integer; PadString : String) : String;
//centres string
var
  PadIndex : Integer;
begin
  Result := '';
  For PadIndex := 0 to ((ReqdLength - Length(UnCentredString))
                        div Length(PadString) div 2) -1 do
  begin
    Result := Result + PadString;
  end;
  Result := Result + UnCentredString;
end;

function CountStr(SubString : String; SearchString : String) : Integer;
//counts number of occurrences of Substring in SearchString
var
   FoundPosition : Integer;  //index of found SubString
begin

   FoundPosition := Pos(SubString,SearchString);
   if FoundPosition > 0 then
       CountStr := 1 + CountStr(SubString,Copy(SearchString,FoundPosition+1,Length(SearchString)))
   else
       CountStr := 0;

end;

function DelimitedString(SearchString, Delimiter : String; After : Boolean) : String;
//returns string up until delimiter (or after) delimiter
var
   FoundPosition : Integer;  //index of found SubString
begin
   FoundPosition := Pos(Delimiter,SearchString);
   if FoundPosition > 0 then  //delimiter found
   begin
      If After then
        Result := Copy(SearchString,FoundPosition+Length(Delimiter), Length(SearchString))
      else
        Result := Copy(SearchString,1,FoundPosition-1);
   end
   else //delimiter not found
    Result := '';
end;

function ReverseDelimitedString(SearchString, Delimiter : String; After : Boolean) : String;
//returns string up until (or after) the first delimiter working from right to left
var
   FoundPosition : Integer;  //index of found SubString
begin

   FoundPosition:=PosOccurrence(Delimiter,SearchString,CountStr(Delimiter,SearchString));
   if FoundPosition > 0 then  //delimiter found
   begin
      If After then
        Result := Copy(SearchString,FoundPosition+Length(Delimiter), Length(SearchString))
      else
        Result := Copy(SearchString,1,FoundPosition-1);
   end
   else //delimiter not found
    Result := '';
end;

function DeSpace(SearchString, ReplaceString : String) : String;
//replaces spaces in saerchstring with replace string
begin
  Result := Replace(SearchString, ' ', ReplaceString);
end;


function EnsureSuffix(SearchString : String; Suffix : String) : String;
//returns string with suffix string (if it was not already there
var
  LengthSearchString : Integer;
	CurrentSuffix : String;
begin
  LengthSearchString := Length(SearchString);
  CurrentSuffix := Copy(SearchString, LengthSearchString - Length(Suffix)+1, LengthSearchString);
  If CurrentSuffix <> Suffix then
    Result := SearchString + Suffix
  else
    Result := SearchString;
end;

function FindPartial(PartialSearch : String; SearchList : TStrings) : Integer;
//finds index of partial matched string in (un)sorted lists
var
  Idx : Integer;
begin
  //create a sorted list
  With TStringList.Create do
  begin
    try
      //grab unsorted list
      Assign(SearchList);
      //store original position indexes in objects property
      For Idx := 0 to Count -1 do Objects[Idx] := TObject(Idx);
      Sorted := True; //and sort
      //find partial match in sorted list
      Find(PartialSearch, Idx);
      //find original position
      If Idx < Count then Result := Integer(Objects[Idx])
      else result := Count;
    finally
      Free;
    end;
  end;
end;

function LeftPad(UnPaddedString : String; ReqdLength : Integer; PadString : String) : String;
//pads string to reqd length
var
 PadIndex : Integer;
begin

  Result := '';
  For PadIndex := 0 to ((ReqdLength - Length(UnPaddedString)) div length(PadString)) - 1                do
  begin
    Result := Result + PadString;
  end;
  Result := Result + UnPaddedString;
end;

function LastWord(SearchString : String) : String;
//returns last word in SearchString (defined by SPACE before word)
var
  FoundSpacePosition : Integer;  //index of found space
begin
  FoundSpacePosition := Length(SearchString);
  While (FoundSpacePosition > 1) and (SearchString[FoundSpacePosition] <> ' ') do
    Dec(FoundSpacePosition);
  Result := Copy(SearchString,FoundSpacePosition+1, 99999);
end;

function PosOccurrence(SubString: string; SearchString: string; Occurrence : Integer): Integer;
//returns the position of the occurrence of SubStr in SearchString
var
  FoundPosition : Integer;  //index of found SubString
begin
  FoundPosition := Pos(SubString,SearchString);
  If (FoundPosition > 0) and (Occurrence >0) then
  begin
    Result := FoundPosition + PosOccurrence(SubString,Copy(SearchString,FoundPosition+1,Length(SearchString)), Occurrence-1);
    If (Result = FoundPosition) and (Occurrence > 1)  then Result := 0;	//could not find enough occurrences
  end
  else
    Result := 0;
end;

function RightPad(UnPaddedString : String; ReqdLength : Integer; PadString : String) : String;
//pads string to reqd length
var
 PadIndex : Integer;
begin

  Result := UnPaddedString;
  For PadIndex := 0 to ((ReqdLength - Length(UnPaddedString)) div length(PadString)) - 1                do
  begin
    Result := Result + PadString;
  end;

end;

function RandomString(ReqdLength : Integer) : String;
//returns a random ASCII string of required length
var
  Index : Integer;
begin
  Result := '';
  For Index := 1 to ReqdLength do
  begin
    Result := Result + Chr(65 + Trunc(Random(26)));
  end;
end;

function Replace(OriginalString,SearchString,ReplaceString : String) : String;
//replaces search string with replace string in original string and returns changed string
var
  SearchPos     : Integer; //position of search string
begin

  SearchPos := Pos(SearchString,OriginalString);
  Result := '';
  If SearchPos > 0 then
  begin
    if SearchPos > 1 then //search string not at start
      Result := Copy(OriginalString,1,SearchPos - 1);

    Result := Result + ReplaceString;

    if SearchPos < Length(OriginalString) - Length(SearchString) + 1 then //search string not at end
      Result := Result + Replace(Copy(OriginalString, SearchPos + Length(SearchString), Length(OriginalString) - SearchPos),
                                  SearchString, ReplaceString);
  end //if search string found
  else
  begin
    Result := OriginalString;
  end;
end;

function ReplaceSubString(OriginalString, StartTag, EndTag, ReplaceString : String) : String;
//replaces string between tags in original string
begin
  Replace(OriginalString, SubString(OriginalString, StartTag, EndTag), ReplaceString);
end;

function RemoveNumbers(OriginalString:String):String;
var
  i:Integer;
begin
   Result:=OriginalString;
   for i:=48 to 57 do
      Result:=Replace(Result,Chr(i),'');
end;

function RemoveLetters(OriginalString:String):String;
var
  i:Integer;
begin
   Result:=OriginalString;
   for i:=65 to 122 do
      if i in[65..90,97..122] then
         Result:=Replace(Result,Chr(i),'');
end;

function SubString(MainString : String; StartTag : String; EndTag : String) : String;
//returns substring between tags in main string
var
   StartTagPos    : Integer;
   EndTagOffSet   : Integer;
   LengthStartTag : Integer;
begin
   Result := '';
   StartTagPos := Pos(StartTag,MainString);
   If StartTagPos > 0 then //starttag found
   begin
      LengthStartTag := Length(StartTag);
      EndTagOffset := Pos(EndTag,Copy(MainString,StartTagPos+LengthStartTag,Length(MainString)));
      If EndTagOffSet > 0 then   //endtag found after start tag
      begin
         Result := Copy(MainString, StartTagPos + LengthStartTag, EndTagOffset - 1);
      end;
   end;
end;

function StrToCurrStrDef(CurrencyString : String; Default : Currency) : String ;
// converts a string to a string formatted according to control panel currency settings
begin
  Result := CurrToStrF(StrToCurrDef(CurrencyString,Default), ffNumber,CurrencyDecimals);
end;

function StrToFloatDef(FloatString : String; DefaultValue : Double) : Double;
//converts string to float with a default value
begin
	try
  	Result := StrToFloat(FloatString);
  except
  	Result := DefaultValue;
  end;
end;

function StrToDateDef(DateS:String;DefDateTime:TDateTime):TDateTime;
// Valid Date Range = 01/01/0001 - 31/12/3000
// "DateS" is UK date format and "DefDateTime" must be a valid datetime
var
   Y:Word;
   M:Word;
   D:Word;
begin
   // showmessage(DateSeparator + ' | ' + shortdateformat);
   Result:=Trunc(DefDateTime);

   D:=StrToIntDef(Copy(DateS,1,2),0);
   M:=StrToIntDef(Copy(DateS,4,2),0);
   if Length(DateS) >= 10 then // 4 digit year
      Y := StrToIntDef(Copy(DateS,7,4),0)
   else // 2 digit year
   begin
      Y:=StrToIntDef(Copy(DateS,7,2),0);
      if Y < 80 then Inc(Y,100);
      Inc(Y,1900);
   end;
   if CountStr(DateSeparator,DateS) < 2 then exit;
   if (Y < 1) or (Y > 3000) then exit;
   if not(M in [1..12]) then exit;
   if (D < 1) or (D > MonthDays[IsLeapYear(Y), M]) then exit;

   Result:=EncodeDate(Y,M,D);
end;

function TransposeCommaText(HorizCommaTExt : String; Offset : Integer) : String;
//transposes horizontal commatext of strings to vertical for receipt rotated printing
//ab     gda
//def -> heb
//ghi    if
var
  VertString      : String;
  HorizSL, VertSL : TStringList;
  HorizIndex      : Integer;
  MaxStringLength : Integer;
begin
  HorizSL := TStringList.Create;
  VertSL  := TStringList.Create;
  try
    maxStringLength := 0;
    HorizSL.CommaText := HorizCommaTExt;
    Repeat
      //Build a vertline
      VertString := '';
      For HorizIndex := HorizSL.Count -1 downto 0 do
      begin
        MaxStringLength := MaxIntValue([MaxStringLength, Length(HorizSL[HorizIndex])]);
        //add next char
        If Length(HorizSL[HorizIndex]) >= (VertSL.Count+1) then
          VertString := VertString + HorizSL[HorizIndex][VertSL.Count+1]
        else
          VertString := VertString + ' ';
      end;
      VertSL.Add(LeftPad(' ', OffSet, ' ') + VertString); //add the completed line      
    Until VertSL.Count >= MaxStringLength;
    Result := VertSL.CommaText;

  finally
    HorizSL.Free;
    VertSL.Free;
  end;
end;

function Wrap(LinesToWrapCommaText : String; Column : Integer; BreakOnWord : Boolean) : String;
//wraps lines at column with option to break on on word breaks
var
  WordBreak : Integer;
  LineIndex : Integer;
begin
  With TStringList.Create do
  begin
    CommaText := LinesToWrapCommaText;
    LineIndex := 0;
    While LineIndex < Count do
    begin
      If Length(Strings[LineIndex]) > Column then
      begin
        WordBreak := COlumn;
        If BreakOnWord then //break line on column
        begin
          //find last space before column
          WordBreak := PosOccurrence(' ',
                        LeftString(Strings[LineIndex],Column),                //before column
                        CountStr(' ', LeftString(Strings[LineIndex],Column))); //num spaces before column
          If WordBreak = 0 then //no word break
            WordBreak := Column;
        end;
        //wrap line
        Strings[LineIndex] := LeftString(Strings[LineIndex],WordBreak)
                              + #13#10
                              + Copy(Strings[LineIndex],WordBreak+1,Length(Strings[LineIndex]));
        Text := Text;
      end;
      Inc(LineIndex);
    end;
    Result :=Commatext;
  end;
end;


function HasGotAlphaChar( S: String ) : boolean ;
var
  i : integer ;
begin
  i := 1 ;
  result := false ;
  while (i <= length( s )) and  not result do
  begin
    result := ( s[i] in [ 'A'..'Z','a'..'z', '!','"','%','&','*','/',';','<','>',
                       '=','?','@','(',')','\',']','^','_','`','{', '{'..'~' ] );
    inc(i);
  end;

end ;


end.
