{  Module          Corvus Error Handler
   Unit            Log File Handler
   Copyright(c)    Postal Solutions Limited 1996..1998
   Author          MJD
   Description     Handle Logging of Errors to a file
   Modifications   19/03/98 - MJD
                              Original Release
                   27/03/98 - MJD
                              Fixed Error 1 in File Create and added more
                              Exception Handling in Add method
}
unit LogFileU;

interface

uses
  SysUtils,ComObj,Classes, ActiveX, ErrorHFU,GPCSErrorCode,GPCSErrorLine;

type
  TLogFile = class
  private
     FFileName:String;
  public
     constructor Create(FileName:String);
     procedure Add(Line:String);
     property FileName:String read FFileName write FFileName;
     procedure ReadInToList(List:TStrings);
     procedure Clear;
  end;

function HexToInt(S:String):Integer;
function IntToDateTime(DTVal:Integer):TDateTime;

implementation

{===============================================================================
  Function     IntToDateTime
  Description  Convert the log datetime (approx 2 seconds per bit) to a TDateTime
  Params       DTVal integer datetime
  Result       TDateTime unpacked datetime value
________________________________________________________________________________}
function IntToDateTime(DTVal:Integer):TDateTime;
begin
   Result:=(DTVal / 50000)+ $8000;
end;

{===============================================================================
  Function     HexToInt
  Description  Convert a Hexidecimal String to an Integer
               Strings > 8 digits or non hex digits - output undefined
  Params       The Hexidecimal string to translate
  Result       the integer value
________________________________________________________________________________}
function HexToInt(S:String):Integer;
var
   Nybble:Integer;
   Index:Integer;
begin
   Result:=0;
   for Index:=1 to Length(S) do             // go through string
   begin
      Result:=Result shl 4;                 // shift up 4 bits
      Nybble:=Integer(S[Index])-Ord('0');   // get digit -'0'
      if Nybble > 9 then Dec(Nybble,7);     // if > 9 then adjust for alpha
      Inc(Result,Nybble);                   // put in bottom 4 bits
   end;
end;

{TLogFile}
{===============================================================================
  Class        TLogFile
  Method       Create
  Description  Assign File Name 
  Params       None
  Result       None
________________________________________________________________________________}
constructor TLogFile.Create(FileName:String);
begin
   FFileName:=FileName;
end;

{===============================================================================
  Class        TLogFile
  Method       Add
  Description  Add a line to the log file
               The Line has the DateTime inserted before it in Hex
               and a CR/LF appended if it doesn't already have one
  Params       The Line to Add
  Result       None
________________________________________________________________________________}
procedure TLogFile.Add(Line:String);
var
   FileStream:TFileStream;
begin
   // open existing file
   try
      FileStream:=TFileStream.Create(FFileName,fmOpenReadWrite or fmShareExclusive);
   except
      FileStream:=nil;
   end;
   // failed - try to create
   try
      if FileStream = nil then 
         FileStream:=TFileStream.Create(FFileName,fmCreate or fmShareExclusive);
   except
      FileStream:=nil;
   end;
      
   // failed - give up !
   if FileStream = nil then Exit;
   
   try
      // position for append
      FileStream.Position:=FileStream.Size; 
      // Trunc((Now-$8000)*50000) = time integer with approx 2 sec accuracy
      Line:=IntToHex(Trunc((Now-$8000)*50000),8)+Line;
      // line =  Line + CR/LF
      if (Line[Length(Line)] <> #10) and (Line[Length(Line)] <> #13) then
         Line:=Line+#13#10;
      // Save to file
      FileStream.Write(Pointer(Line)^,Length(Line));
   except;
      ;
   end;
   // Close file
   try
      FileStream.Free;
   except;
      ;
   end;
end;      
{===============================================================================
  Class        TLogFile
  Method       ReadInToList
  Description  Read the Log file into a string list
  Params       List to fill
  Result       None
________________________________________________________________________________}
procedure TLogFile.ReadInToList(List:TStrings);
var
   I:Integer;
   DTVal:Integer;
begin
   try
      List.LoadFromFile(FFileName);  // load log file
      for I:=0 to List.Count-1 do
      begin
         DTVal:=HexToInt(Copy(List[I],1,8)); // cut out datetime stamp
         List[I]:=Copy(List[I],9,999);       // remove form list
         List.Objects[I]:=TObject(DTVal);    // place datetime in object
      end;
   except;
      ;
   end;
end;
{===============================================================================
  Class        TLogFile
  Method       ClearLogButtonClick
  Description  Clear the Error Log
  Params       Sender
  Result       None
________________________________________________________________________________}
procedure TLogFile.Clear;
var
   FileStream:TFileStream;
begin           
   FileStream:=TFileStream.Create(FFileName,fmCreate or fmShareExclusive);
   if FileStream <> nil then
      FileStream.Free;
end;

end.     
