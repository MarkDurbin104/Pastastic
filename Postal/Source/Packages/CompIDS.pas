unit CompIDS;

interface

uses
   Classes,SysUtils;

function IDSToComponent(IDS:String;WriteComp:TComponent):TComponent;       // create a TComponent from an IDS file
function ComponentToIDS(Component:TComponent):String; // create an IDS file from a TComponent

{
// EXAMPLE
// duplicate Button1 to a new button below it
procedure TForm1.Button1Click(Sender: TObject);
var
   Comp:TComponent;
   S:String;
begin
   S := ComponentToIDS(Sender as TControl);
   // S contains IDS of component
   Comp := IDSToComponent(S, nil);
   if Comp is TControl then
   begin
      with Comp as TControl do
      begin
         Name    := 'NewControl';  // rename it to avoid conflits
         Parent  := Self;
         Top     := (Sender as TControl).Top + (Sender as TControl).Height; // move it down
      end;
   end;
   InsertComponent(Comp); // insert in form.
end;

initialization
   RegisterClasses([TButton]); // you must make sure that the classes you are going to stream have been registered
}

implementation

type
  TAWriter = class(TWriter)
  public
    procedure WriteBinary(WriteData: TStreamProc);
    procedure WritePrefix(Flags: TFilerFlags; AChildPos: Integer);
    procedure WriteValue(Value: TValueType);
  end;


{TAWriter}
procedure TAWriter.WriteBinary(WriteData: TStreamProc);
begin
   inherited WriteBinary(WriteData);
end;
procedure TAWriter.WritePrefix(Flags: TFilerFlags; AChildPos: Integer);
begin
   inherited WritePrefix(Flags,AChildPos);
end;
procedure TAWriter.WriteValue(Value: TValueType);
begin
   inherited WriteValue(Value);
end;
procedure BinToHex(Buffer, Text: PChar; BufSize: Integer); assembler;
asm
        PUSH    ESI
        PUSH    EDI
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EDX,0
        JMP     @@1
@@0:    DB      '0123456789ABCDEF'
@@1:    LODSB
        MOV     DL,AL
        AND     DL,0FH
        MOV     AH,@@0.Byte[EDX]
        MOV     DL,AL
        SHR     DL,4
        MOV     AL,@@0.Byte[EDX]
        STOSW
        DEC     ECX
        JNE     @@1
        POP     EDI
        POP     ESI
end;
{ObjectBinaryToIDS}
procedure ObjectBinaryToIDS(Input, Output: TStream);
var
  NestingLevel: Integer;
  SaveSeparator: Char;
  Reader: TReader;
  Writer: TWriter;

  procedure WriteIndent;
  const
    Blanks: array[0..1] of Char = '  ';
  var
    I: Integer;
  begin
    for I := 1 to NestingLevel do Writer.Write(Blanks, SizeOf(Blanks));
  end;

  procedure WriteStr(const S: string);
  begin
    Writer.Write(S[1], Length(S));
  end;

  procedure NewLine;
  begin
    WriteStr(#13#10);
    WriteIndent;
  end;

  function ConvertValue:TValueType; forward;

  procedure ConvertHeader;
  var
    ClassName, ObjectName: string;
    Flags: TFilerFlags;
    Position: Integer;
  begin
    Reader.ReadPrefix(Flags, Position);
    ClassName := Reader.ReadStr;
    ObjectName := Reader.ReadStr;
    WriteIndent;
    WriteStr(ClassName);
    if ObjectName <> '' then
    begin
      WriteStr('^');
      WriteStr(ObjectName);
    end;
    WriteStr(' {');
//    if ffInherited in Flags then
//      WriteStr('inherited ')
//    else
//      WriteStr('object ');
    if ffChildPos in Flags then
    begin
      WriteStr(' [');
      WriteStr(IntToStr(Position));
      WriteStr(']');
    end;
    WriteStr(#13#10);
  end;

  procedure ConvertBinary;
  const
    BytesPerLine = 64;
  var
    MultiLine: Boolean;
    I: Integer;
    Count: Longint;
    Buffer: array[0..BytesPerLine - 1] of Char;
    Text: array[0..BytesPerLine * 2 - 1] of Char;
  begin
    Reader.ReadValue;
    WriteStr('{');
    Inc(NestingLevel);
    Reader.Read(Count, SizeOf(Count));
    MultiLine := Count >= BytesPerLine;
    while Count > 0 do
    begin
      if MultiLine then NewLine;
      if Count >= BytesPerLine then I := BytesPerLine else I := Count;
      Reader.Read(Buffer, I);
      BinToHex(Buffer, Text, I);
      Writer.Write(Text, I * 2);
      Dec(Count, I);
    end;
    Dec(NestingLevel);
    NewLine;
    WriteStr(' }');
  end;

  procedure ConvertProperty; forward;

  function ConvertValue:TValueType;
  const
    LineLength = 64;
  var
    I, J, K, L: Integer;
    S: string;
    LineBreak: Boolean;
  begin
    Result:=Reader.NextValue;
    case Result of
      vaList:
        begin
          Reader.ReadValue;
          WriteStr('(');
          Inc(NestingLevel);
          while not Reader.EndOfList do
          begin
            NewLine;
            ConvertValue;
          end;
          Reader.ReadListEnd;
          Dec(NestingLevel);
          WriteStr(')');
        end;
      vaInt8, vaInt16, vaInt32:
        WriteStr(IntToStr(Reader.ReadInteger));
      vaExtended:
        WriteStr(FloatToStr(Reader.ReadFloat));
      vaString, vaLString:
        begin
          S := Reader.ReadString;
          L := Length(S);
          if L = 0 then WriteStr('''''') else
          begin
            I := 1;
            Inc(NestingLevel);
            try
              if L > LineLength then NewLine;
              K := I;
              repeat
                LineBreak := False;
                if (S[I] >= ' ') and (S[I] <> '''') then
                begin
                  J := I;
                  repeat
                    Inc(I)
                  until (I > L) or (S[I] < ' ') or (S[I] = '''') or
                    ((I - K) >= LineLength);
                  if ((I - K) >= LineLength) then
                  begin
                    LIneBreak := True;
                    if ByteType(S, I) = mbTrailByte then Dec(I);
                  end;
                  WriteStr('''');
                  Writer.Write(S[J], I - J);
                  WriteStr('''');
                end else
                begin
                  WriteStr('#');
                  WriteStr(IntToStr(Ord(S[I])));
                  Inc(I);
                  if ((I - K) >= LineLength) then LineBreak := True;
                end;
                if LineBreak and (I <= L) then
                begin
                  WriteStr(' +');
                  NewLine;
                  K := I;
                end;
              until I > L;
            finally
              Dec(NestingLevel);
            end;
          end;
        end;
      vaIdent, vaFalse, vaTrue, vaNil:
        WriteStr(Reader.ReadIdent);
      vaBinary:
        ConvertBinary;
      vaSet:
        begin
          Reader.ReadValue;
          WriteStr('[');
          I := 0;
          while True do
          begin
            S := Reader.ReadStr;
            if S = '' then Break;
            if I > 0 then WriteStr(', ');
            WriteStr(S);
            Inc(I);
          end;
          WriteStr(']');
        end;
      vaCollection:
        begin
          Reader.ReadValue;
          WriteStr('<');
          Inc(NestingLevel);
          while not Reader.EndOfList do
          begin
            NewLine;
            WriteStr('item');
            if Reader.NextValue in [vaInt8, vaInt16, vaInt32] then
            begin
              WriteStr(' [');
              ConvertValue;
              WriteStr(']');
            end;
            WriteStr(#13#10);
            Reader.ReadValue;
//            Reader.CheckValue(vaList);
            Inc(NestingLevel);
            while not Reader.EndOfList do ConvertProperty;
            Reader.ReadListEnd;
            Dec(NestingLevel);
            WriteIndent;
            WriteStr('end');
          end;
          Reader.ReadListEnd;
          Dec(NestingLevel);
          WriteStr('>');
        end;
    end;
  end;

  procedure ConvertProperty;
  begin
    WriteIndent;
    WriteStr(Reader.ReadStr);
    WriteStr(' { ');
    if ConvertValue = vaBinary then
       WriteStr('}')
    else
       WriteStr(' }');
    WriteStr(#13#10);
  end;

  procedure ConvertObject;
  begin
    ConvertHeader;
    Inc(NestingLevel);
    while not Reader.EndOfList do ConvertProperty;
    Reader.ReadListEnd;
    while not Reader.EndOfList do ConvertObject;
    Reader.ReadListEnd;
    Dec(NestingLevel);
    WriteIndent;
    WriteStr('}'#13#10);
  end;

begin
  NestingLevel := 0;
  Reader := TReader.Create(Input, 4096);
  SaveSeparator := DecimalSeparator;
  DecimalSeparator := '.';
  try
    Writer := TWriter.Create(Output, 4096);
    try
      Reader.ReadSignature;
      ConvertObject;
    finally
      Writer.Free;
    end;
  finally
    DecimalSeparator := SaveSeparator;
    Reader.Free;
  end;
end;

{ObjectIDSToBinary}
procedure ObjectIDSToBinary(Input, Output: TStream);
var
  SaveSeparator: Char;
  Parser: TParser;
  Writer: TAWriter;

  function ConvertOrderModifier: Integer;
  begin
    Result := -1;
    if Parser.Token = '[' then
    begin
      Parser.NextToken;
      Parser.CheckToken(toInteger);
      Result := Parser.TokenInt;
      Parser.NextToken;
      Parser.CheckToken(']');
      Parser.NextToken;
    end;
  end;


  procedure ConvertHeader(ClassName:String);
  var
    ObjectName: string;
    Flags: TFilerFlags;
    Position: Integer;
  begin
    if ClassName = '' then
    begin
       ClassName := Parser.TokenString;
       ObjectName := '';
       if Parser.NextToken = '^' then
       begin
         Parser.NextToken;
         Parser.CheckToken(toSymbol);
         ObjectName := Parser.TokenString;
         Parser.NextToken;
       end;
    end
    else
    begin
       Parser.NextToken;
       Parser.CheckToken(toSymbol);
       ObjectName := Parser.TokenString;
       Parser.NextToken;
    end;
    Parser.NextToken;
    Flags := [];
    Position := ConvertOrderModifier;
    if Position > 0 then
      Include(Flags, ffChildPos);
    Writer.WritePrefix(Flags, Position);
    Writer.WriteStr(ClassName);
    Writer.WriteStr(ObjectName);
  end;

  function ConvertProperty:String; forward;

  procedure ConvertValue;
  var
    Order: Integer;

    function CombineString: string;
    begin
      Result := Parser.TokenString;
      while Parser.NextToken = '+' do
      begin
        Parser.NextToken;
        Parser.CheckToken(toString);
        Result := Result + Parser.TokenString;
      end;
    end;

  begin
    if Parser.Token = toString then
      Writer.WriteString(CombineString)
    else
    begin
      case Parser.Token of
        toSymbol:
          begin
            Writer.WriteIdent(Parser.TokenComponentIdent);
          end;
        toInteger:
          begin
            Writer.WriteInteger(Parser.TokenInt);
          end;
        toFloat:
          begin
            Writer.WriteFloat(Parser.TokenFloat);
          end;
        '[':
          begin
            Parser.NextToken;
            Writer.WriteValue(vaSet);
            if Parser.Token <> ']' then
              while True do
              begin
                Parser.CheckToken(toSymbol);
                Writer.WriteStr(Parser.TokenString);
                if Parser.NextToken = ']' then Break;
                Parser.CheckToken(',');
                Parser.NextToken;
              end;
            Writer.WriteStr('');
          end;
        '(':
          begin
            Parser.NextToken;
            Writer.WriteListBegin;
            while Parser.Token <> ')' do ConvertValue;
            Writer.WriteListEnd;
          end;
        '{':
          begin
            Writer.WriteBinary(Parser.HexToBinary);
//            Parser.NextToken;
          end;
        '<':
          begin
            Parser.NextToken;
            Writer.WriteValue(vaCollection);
            while Parser.Token <> '>' do
            begin
              Parser.CheckTokenSymbol('item');
              Parser.NextToken;
              Order := ConvertOrderModifier;
              if Order <> -1 then Writer.WriteInteger(Order);
              Writer.WriteListBegin;
              while not Parser.TokenSymbolIs('end') do ConvertProperty;
              Writer.WriteListEnd;
              Parser.NextToken;
            end;
            Writer.WriteListEnd;
          end;
//      else
//        Parser.Error(SInvalidProperty);
      end;
      Parser.NextToken;
    end;
  end;

  procedure ConvertObject(ClassName:String); forward;

  function ConvertProperty:String;
  var
    PropName: string;
  begin
    Result:='';
    PropName := Parser.TokenString;
    if PropName = '}' then
       Exit;
    Parser.NextToken;
    if Parser.Token = '^' then
    begin
       Result:=PropName;
    end
    else
    begin
       while Parser.Token = '.' do
       begin
         Parser.NextToken;
         Parser.CheckToken(toSymbol);
         PropName := PropName + '.' + Parser.TokenString;
         Parser.NextToken;
       end;
       Writer.WriteStr(PropName);
       Parser.CheckToken('{');
       Parser.NextToken;
       ConvertValue;
       Parser.NextToken;
    end;
  end;

  procedure ConvertObject(ClassName:String);
  var
     CName:String;
  begin
    ConvertHeader(ClassName);
    CName:='';
    while (Parser.TokenString <> '}') and (CName = '') do
    begin
       CName:=ConvertProperty;
    end;
    Writer.WriteListEnd;
    while (Parser.TokenString <> '}') or (CName <> '') do
    begin
       ConvertObject(CName);
       CName:='';
    end;
    Writer.WriteListEnd;
    Parser.NextToken;
  end;

begin
  Parser := TParser.Create(Input);
  SaveSeparator := DecimalSeparator;
  DecimalSeparator := '.';
  try
    Writer := TAWriter.Create(Output, 4096);
    try
      Writer.WriteSignature;
      ConvertObject('');
    finally
      Writer.Free;
    end;
  finally
    DecimalSeparator := SaveSeparator;
    Parser.Free;
  end;
end;
function ComponentToIDS(Component:TComponent):String;
var
   SI:TMemoryStream;
   SO:TStringStream;
begin
   SI:=TMemoryStream.Create;
   SO:=TStringStream.Create('');
   SI.WriteComponent(Component);
   SI.Position:=0;
   ObjectBinaryToIDS(SI,SO);
   Result:=SO.DataString;
   SO.Free;
   SI.Free;
end;
function IDSToComponent(IDS:String;WriteComp:TComponent):TComponent;
var
   SO:TMemoryStream;
   SI:TStringStream;
begin
   SO:=TMemoryStream.Create;
   SI:=TStringStream.Create(IDS);
   ObjectIDSToBinary(SI,SO);
   SO.Position:=0;
   Result:=SO.ReadComponent(WriteComp);
   SO.Free;
   SI.Free;
end;

end.
