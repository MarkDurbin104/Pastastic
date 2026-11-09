unit Utils;

interface
uses
  SysUtils,
  GPCSErrorLine,
  GpcsGUID,
  TypInfo,
  Windows,Graphics,Classes;

function Max(A,B:Integer):Integer;
function Min(A,B:Integer):Integer;
function LoCase(ch:Char):Char;
function UpCase(ch:Char):Char;
procedure PaintButton(var R:TRect;Canvas:TCanvas;Color:TColor);
function CentreTextH(Canvas:TCanvas;R:TRect;Text:String):Integer;
function CentreTextHV(Canvas:TCanvas;R:TRect;Text:String):Integer;
procedure Get3Colours(Color:TColor;var Low,Mid,High:TColor);
procedure DrawBEdge(Canvas:TCanvas;Dest:TRect;High,Low:TColor);
function FaceColor(Color:TColor):TColor;
function Fade(Color:TColor;Percentage:Integer):TColor;

procedure SetObjectProperty(TheObject:TObject;PropertyName:String;Value:Variant);
function  GetObjectProperty(TheObject:TObject;PropertyName:String):Variant;
procedure SetRecentValues(DomainControl : TComponent; ValuesCommaText : String);
procedure GetRecentValues(DomainControl : TComponent; ValuesCommaText : String);
function  ListPropertyNames(TheObject:TObject):String;

type
 teUnits = (teMilliSecond, teSecond, teMinute, teHour, teDay, teMonth, teYear);
function TimeElapsed(Start, Finish : TDateTime; Units : teUnits) : Double;


implementation

function TimeElapsed(Start, Finish : TDateTime; Units : teUnits) : Double;
var
  Difference : TDateTime;
  MilliSecond, Second, Minute, Hour, Day, Month, Year : Word;
begin
  Result := 0;
  Difference := Finish - Start; //Trunc(Difference) = no of days
  Day := Trunc(Difference);
  DecodeDate(Difference, Year, Month, Day);
  Dec(Year,1899); Dec(Month,12); Dec(Day,30);
  DecodeTime(Difference, Hour, Minute, Second, MilliSecond);
  Case Units of
    teMilliSecond : Result := Day*24*60*60*1000 + MilliSecond;
    teSecond      : Result := Day*24*60*60      + Second;
    teMinute      : Result := Day*24*60         + Minute;
    teHour        : Result := Day*24            + Hour;
    teDay         : Result := Day;
    teMonth       : Result := Month;
    teYear        : Result := Year;
  end;
end;

procedure SetRecentValues(DomainControl : TComponent; ValuesCommaText : String);
begin
  With TStringList.Create do
  begin
    try
      CommaText := ValuesCommaText;
      While Count > 0 do
      begin
        try
          SetGPCSRegString('\Recent Value\' + DomainControl.Name ,Strings[0], GetObjectProperty(DomainControl, Strings[0]));
          Delete(0);
        except
          On E : Exception do
            RaiseGUIDException('{1ADE5E63-88D7-4AC6-B24C-697E7E5040B9}' , E);
        end;
      end;
    finally
      Free;
    end;
  end;
end;

procedure GetRecentValues(DomainControl : TComponent; ValuesCommaText : String);
begin
  With TStringList.Create do
  begin
    try
      CommaText := ValuesCommaText;
      While Count > 0 do
      begin
        try
          SetObjectProperty(DomainControl,
                            Strings[0],
                            GetGPCSRegString('\Recent Value\' + DomainControl.Name, Strings[0], ''));
          Delete(0);
        except
          On E : Exception do
            RaiseGUIDException('{2EEE4E9C-34CE-4EC5-A6D8-E407AF4EB075}' , E);
        end;
      end;
    finally
      Free;
    end;
  end;
end;


function Max(A,B:Integer):Integer;
asm
   CMP EAX,EDX    // compare A with B
   JGE @@ABigger  // Greater or Equal then Return A
   MOV EAX,EDX    // Move B into Result
   @@ABigger:
end;
function Min(A,B:Integer):Integer;
asm
   CMP EAX,EDX    // compare A with B
   JLE @@ASmaller // Less or Equal then Return A
   MOV EAX,EDX    // Move B into Result
   @@ASmaller:
end;
function LoCase(ch:Char):Char;    
asm
   CMP AL,'A'       // compare against 'A'
   JB  @@OutOfRange // below - so exit
   CMP AL,'Z'       // comapre against 'Z'
   JA  @@OutOfRange // above - so exit
   ADD AL,$20       // adjust by difference between 'A' and 'a' i.e. 32
   @@OutOfRange:    // exit label
end;

function UpCase(ch:Char):Char;    
asm
   CMP AL,'a'       // compare against 'a'
   JB  @@OutOfRange // below - so exit
   CMP AL,'z'       // comapre against 'z'
   JA  @@OutOfRange // above - so exit
   SUB AL,$20       // adjust by difference between 'A' and 'a' i.e. 32
   @@OutOfRange:    // exit label
end;

function CentreTextH(Canvas:TCanvas;R:TRect;Text:String):Integer;
begin
   Result:=DrawText(Canvas.Handle,PChar(Text),Length(Text),R,DT_WORDBREAK or DT_CENTER);
end;
function CentreTextHV(Canvas:TCanvas;R:TRect;Text:String):Integer;
var
   OrigR:TRect;
begin
   OrigR:=R;
   Result:=DrawText(Canvas.Handle,PChar(Text),Length(Text),R,DT_WORDBREAK or DT_CALCRECT);
   OrigR.Top:=OrigR.Top+((OrigR.Bottom-OrigR.Top)-Result) div 2;
   OrigR.Bottom:=OrigR.Top+Result;
   DrawText(Canvas.Handle,PChar(Text),Length(Text),OrigR,DT_WORDBREAK or DT_CENTER);
end;
procedure Get3Colours(Color:TColor;var Low,Mid,High:TColor);
var
   R,G,B:Byte;
   ColRGB:Integer;
begin
   ColRGB:=ColorToRGB(Color);
   R:=((ColRGB       ) and $FF) div 2;
   G:=((ColRGB shr 8 ) and $FF) div 2;
   B:=((ColRGB shr 16) and $FF) div 2;
   Low :=RGB(R,G,B);
   Mid :=RGB(R+64,G+64,B+64);
   High:=RGB(R+127,G+127,B+127);
end;
procedure DrawBEdge(Canvas:TCanvas;Dest:TRect;High,Low:TColor);
begin
    with Canvas,Dest do
    begin
      Pen.Color:=High;
      PolyLine([Point(Left,Bottom-1),Point(Left,Top),Point(Right,Top)]);
      Pen.Color:=Low;
      PolyLine([Point(Left,Bottom-1),Point(Right-1,Bottom-1),Point(Right-1,Top)]);
   end;
end;
function Fade(Color:TColor;Percentage:Integer):TColor;
var
   R,G,B:Byte;
   ColRGB:Integer;
begin
   ColRGB:=ColorToRGB(Color);
   R:=((ColRGB       ) and $FF) div 2;
   G:=((ColRGB shr 8 ) and $FF) div 2;
   B:=((ColRGB shr 16) and $FF) div 2;
   Result:=RGB(R+((255-R)*Percentage) div 100,G+((255-G)*Percentage) div 100,B+((255-B)*Percentage) div 100);
end;

function FaceColor(Color:TColor):TColor;
var
  Low,High:TColor;
begin
   Get3Colours(Color,Low,Result,High);
end;
procedure PaintButton(var R:TRect;Canvas:TCanvas;Color:TColor);
var
  Low,Mid,High:TColor;
  PC:TColor;
begin
   Get3Colours(Color,Low,Mid,High);
   with Canvas do
   begin
      PC:=Pen.Color  ;
      Pen.Color  :=clBlack;
      Brush.Color:=Mid;
      with R do Rectangle(Left,Top,Right,Bottom);
      InflateRect(R,-1,-1);
      DrawBEdge(Canvas,R,High,Low);
      InflateRect(R,-1,-1);
      DrawBEdge(Canvas,R,High,Low);
      InflateRect(R,-1,-1);
      Pen.Color  :=PC;
      Brush.Color:=Mid;
   end;
end;

procedure SetObjectProperty(TheObject : TObject; PropertyName : String; Value : Variant);
//sets the object's property to value
var
  PropInfo: PPropInfo;
begin
  PropInfo := GetPropInfo(TheObject.ClassInfo,PropertyName);
  If PropInfo <> nil then
  begin
    Case PropInfo.PropType^.Kind of
      tkUnknown : ;
      tkInteger,
      tkChar,
      tkEnumeration   : SetOrdProp(TheObject,PropInfo, Value);
      tkFloat         : SetFloatProp(TheObject, PropInfo, Value);
      tkString,
      tkWChar,
      tkLString,
      tkWString       : SetStrProp(TheObject, PropInfo, String(Value));
      tkSet,
      tkClass,
      tkMethod        : ;
      tkVariant       : SetVariantProp(TheObject, PropInfo, Value);
      tkArray,
      tkRecord ,
      tkInterface     : ;
    end;
  end;
end;

function GetObjectProperty(TheObject:TObject;PropertyName:String):Variant;
var
  PropInfo: PPropInfo;
begin
  PropInfo := GetPropInfo(TheObject.ClassInfo,PropertyName);
  If PropInfo <> nil then
  begin
    Case PropInfo.PropType^.Kind of
      tkUnknown : ;
      tkInteger,
      tkChar,
      tkEnumeration   : Result:=GetOrdProp(TheObject,PropInfo);
      tkFloat         : Result:=GetFloatProp(TheObject,PropInfo);
      tkString,
      tkWChar,
      tkLString,
      tkWString       : Result:=GetStrProp(TheObject,PropInfo);
      tkSet,
      tkClass,
      tkMethod        : ;
      tkVariant       : Result:=GetVariantProp(TheObject,PropInfo);
      tkArray,
      tkRecord ,
      tkInterface     : ;
    end;
  end;
end;

function ListPropertyNames(TheObject:TObject):String;
var
   Count:Integer;
   Filter:TTypeKinds;
   List: PPropList;
   I:Integer;
   PropInfo:PPropInfo;
   SL:TStringList;
begin
   SL:=TStringList.Create;
   Filter:=tkProperties;
   Count:=GetPropList(TheObject.ClassInfo,Filter,nil);
   GetMem(List,Count*SizeOf(Pointer));
   GetPropList(TheObject.ClassInfo,Filter,List);
   for I:=0 to Count-1 do
   begin
      PropInfo:=List^[I];
      SL.Add(PropInfo.Name);
   end;
   if List <> nil then FreeMem(List,Count*SizeOf(Pointer));
   Result:=SL.Text;
   SL.Free;
end;

end.
