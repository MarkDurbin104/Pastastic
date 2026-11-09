unit MOSupportU;

interface

uses
  stdctrls,
  I3UIParseU,GPCSErrorLine,MODefinitionsU,
  Windows,Graphics,Classes,SysUtils,Dialogs,
  PackStrListU,StringUtil,CRC32,ReportIDSU,
  GPCSGUID,GPCSBase_TLB,Code128Consts,StringWrapperU,ShareDataU;

const
   SystemType:String = 'Indigo3';
type
   TPrnType = (ptUndefined,ptOffice,ptTanzania);
   TPrintStat = (psNoPrinter,psSlipInserted,psSlipRemoved);


   TOfficeCodes = class
   public
      Name  :String;
      Code  :Integer;
      Scode :String;
      I3Code:Integer;
      constructor create (VName,VCode,VScode,VI3Code:String);
   end ;
   TOfficeList = class (TList)
   private
      function GetItem(Index:Integer):TOfficeCodes;
   public
      function TranslateCode( Value:string; InputField,OutputField:TOfficeField):string;
      destructor destroy ; override;
      property Items[Index:Integer]:TOfficeCodes read GetItem; default;
   end;

   TButtonState = class(TStringWrapper)
   public
      property IsUp      :Variant Index 0 read GetElement write SetElement;
      property Caption   :Variant Index 1 read GetElement write SetElement;
   end;

var
  I3UINode : TI3UINode;
  ReportsNode : TReportsNode;

  Receipt:IDevice;

function DecodeMoneyOrder(Series:String;var SerialNo:String;var Value:Currency;var IOffice,POffice,Clerk:Integer;var MOType:TMOType;var IssueDate:TDateTime):Boolean;
procedure PayMO(Series:String;Clerk,Date:Integer;TxnLog:ITransactionLog);
function CheckSeries(Series:String):Boolean;
function MOSeriesToCode128(Series:String):String;
function Code128ToMOSeries(Code128Data:String;WithSpacing:Boolean):String;
function EncodeMoneyOrder(SerialNo:String;Value:Currency;IOffice,POffice,Clerk:Integer;MOType:TMOType;IssueDate:TDateTime;WithSpacing:Boolean):String;
function SlipInserted:TPrintStat;
function CleanMOSeries(Series:String):String;
procedure EncStringCanvasPixels(Canvas:TCanvas;DestRect:TRect;EncBString:String;XScale:Integer);
function PackDate(Date:TDateTime):Integer;
function OfficeFromIndex(Value:Integer):Integer;
function IndexFromOffice(Value:Integer):Integer;

function CodeToName(OfficeListCombo:TComboBox;Code:Integer):String;
function GetSCodeFromOList(OfficeListCombo:TComboBox):String;
function GetCodeFromOList (OfficeListCombo:TComboBox):String;
procedure GetOrderOfficeList( List:TComboBox );
procedure GetShortOfficeList( List:TComboBox );
procedure GetOrderOfficeListInfo( List:TComboBox; ListCodes:TOfficeList ;Field:TOfficeField );

procedure EndorseMO(Series:String);
procedure EndorseJournal(Series:String);

function DateToPeriod(Date:TDateTime):Integer;
function PeriodToDate(Period:Integer):TDateTime;
function TodayAsPeriod:Integer;
function DateTimeToMoment(DateTime : TDateTime) : Integer;
function MomentToDateTime(Moment   : Integer) : TDateTime;
function UnPackDate(Date:Integer):TDateTime;
function DBTypePrefix : String;
function CreateI3UINode(RequiredMOTypes:String) : TI3UINode;
function GetI3ReportsNode : TReportsNode;
function FindNextOffice(I3UINode:TI3UINode; CurrentOffice,DestinationOffice:Integer):Integer;

implementation
uses
   FileTxStatusU,UIDllSupportU;

const
   BaseNumb = 35;
   BaseVals:String = '0123456789ABCDEFGHIJKLMNPQRSTUVWXYZ';

destructor TOfficeList.Destroy ;
var
   I:integer;
begin
   for I := 0 to count -1 do
      TOfficeList(Items[i]).Free;
   inherited ;
end;
function TOfficeList.GetItem(Index:Integer):TOfficeCodes;
begin
   if (Index >=0) and (Index < Count) then
      Result:=TOfficeCodes(inherited Items[Index])
   else
      Result:=nil;
end;     
function TOfficeList.TranslateCode( Value:string; InputField,OutputField:TOfficeField):string;
var
  I : integer;
  Found:boolean;
begin
  i:=0;
  found:=false;
  while (i<=count-1) and not Found do
  begin
     case InputField of
      ofScode  : found := (TOfficeCodes(items[i]).SCode = Value ) ;
      ofCode   : found := (TOfficeCodes(items[i]).Code  = StrToInt(Value) )  ;
      ofI3Code : found := (TOfficeCodes(items[i]).I3Code = StrToInt(Value)) ;
     end ;
    if not found then inc(i);
  end;
  result :='';
  if found then
     case OutputField of
      ofScode  : result := TOfficeCodes(items[i]).SCode ;
      ofCode   : result := IntToStr(TOfficeCodes(items[i]).Code);
      ofI3Code : result := IntToStr(TOfficeCodes(items[i]).I3Code);
     end ;
end;
constructor TOfficeCodes.Create(VName,VCode,VScode,VI3Code:String);
begin
  Name:=VName;
  Code:= StrToIntDef(VCode,0);
  SCode:=VSCode;
  I3Code:=StrToIntDef(VI3Code,0);
end;
// RequiredMOTypes is a comma seperated string which may contain a list of Money Order Types
// eg - 'Normal,Fax' which will return a Node with offices which can only issue normal or fax MOs
// if RequiredMOTypes='' then all offices are returned

function CreateI3UINode(RequiredMOTypes:String) : TI3UINode;
var
  Filename : String;
  RequiredMOTypesSL,
  MOOfficeNamesSL,MOOfficeCodesSL:TPackStringList;
  I,J:Integer;
  SL:TPackStringList;
  OffCodeRef:TOffCodeRef;
begin
  try
    FileName:=GetGPCSRegString(SystemType,'UI Definition Data','');
    if FileName = '' then
    begin
       Result:=nil;
       exit;
    end;
    SharedData:=TSharedData.Create('CorvusReportShare',False);
    if (Copy(FileName,1,1) <> '\') and (Copy(FileName,2,1) <> ':') then
       FileName:= ApplicationRootPath+FileName;
    I3UINode:=TI3UINode.Create('UI',FileName,1);
    I3UINode.ParseFile(ExtractFilePath(FileName),FileName,1);

    MOOfficeNamesSL:=TPackStringlist.Create;
    MOOfficeCodesSL:=TPackStringlist.Create;
    SL:=TPackStringList.Create;
    OffCodeRef:=TOffCodeRef.Create;
    RequiredMOTypesSL:=TPackStringlist.Create;
    RequiredMOTypesSL.CommaText:=RequiredMOTypes;
    SL.Packtext:=TTxnTransfer.OfficeCodeRefs;
    for I:=0 to SL.Count-1 do                              
    begin
       OffCodeRef.PackText:=SL[I];
       if RequiredMOTypes = '' then
       begin
          MOOfficeNamesSL.Add(OffCodeRef.OfficeTitle);
          MOOfficeCodesSL.Add(OffCodeRef.OfficeCode );
       end
       else
       begin
          for J:=0 to RequiredMOTypesSL.Count-1 do
          begin
             if Pos(RequiredMOTypesSL[J],OffCodeRef.OfficeType) > 0 then
             begin
                MOOfficeNamesSL.Add(OffCodeRef.OfficeTitle);
                MOOfficeCodesSL.Add(OffCodeRef.OfficeCode );
                break
             end;
          end;
       end;
    end;    
    SL.Free;
    RequiredMOTypesSL.Free;

    SharedData.SetVariable('OfficeCodeMapping',MOOfficeCodesSL.PackText);
    SharedData.SetVariable('OfficeNames'      ,MOOfficeNamesSL.PackText);
    MOOfficeNamesSL.Free;
    MOOfficeCodesSL.Free;
  except
    On E : Exception do RaiseGUIDException('{7E7646DD-9FD6-4A87-8AC0-2CD8451DA629}', E);
  end;
  Result:=I3UINode;
end;

function GetI3ReportsNode : TReportsNode;
var
  RepFileName : String;
begin
  try
    If ReportsNode = nil then
    begin
      RepFileName:=GetGPCSRegString(SystemType,'Report Definition Data',RepFileName);
      if (Copy(RepFileName,1,1) <> '\') and (Copy(RepFileName,2,1) <> ':') then
        RepFileName:=ApplicationRootPath+RepFileName;
      if FileExists(RepFileName) then
      begin
        ReportsNode:=TReportsNode.Create('Reports',RepFileName,1);
        ReportsNode.ParseFile(ExtractFilePath(RepFileName),RepFileName,1);
      end;
    end;
  except
    On E : Exception do RaiseGUIDException('{5171A43B-5FEE-4D4C-B5C0-65EDE1811786}', E);
  end;
  Result := ReportsNode;
end;

function DirectDispatch(DispatchNode:TUIDispatchNode; CurrentOffice,DestinationOffice:Integer):Boolean;
var
   SL:TStringList;
   I:Integer;
begin
   Result:=False;
   SL:=TStringList.Create;
   SL.Text:=DispatchNode.GetDispListByCode(CurrentOffice);
   for I:=0 to SL.Count-1 do
   begin
      if StrToIntDef(SL[I],0) = DestinationOffice then
      begin
         Result:=True;
         break;
      end;
   end;
   SL.Free;
end;

function FindNextOffice(I3UINode:TI3UINode; CurrentOffice,DestinationOffice:Integer):Integer;
var
  COff : TOffice;
  DOff : TOffice;
begin
  Result  := DestinationOffice;
  COff    := I3UINode.OfficeNode.OfficeCoded(CurrentOffice);
  DOff    := I3UINode.OfficeNode.OfficeCoded(DestinationOffice);

  if (COff<>nil) and  not I3UINode.OfficeNode.HasChildern(COff) then // I'm a sub office
  begin
    Result:=COff.ParentNode; // send it to HPO
  end
  else if (COff<>nil) and
      ( (DOff.ParentNode = CurrentOffice)  // It's going to my child
         or (DOff.IsSorting)                   // or it's going to a sorting centre
         or DirectDispatch(I3UINode.DispatchNode,CurrentOffice,DestinationOffice)
      ) then // or I can send directly
  begin
    Result:=DestinationOffice;
  end
  else
  begin
    if (COff<>nil) and
       ( DirectDispatch(I3UINode.DispatchNode,CurrentOffice,DOff.ParentNode)  // I can sent to it's parent
         or I3UINode.OfficeNode.OfficeCoded(DOff.ParentNode).IsSorting
       ) then  // It's parent is a sorting centre
    begin
      Result:=DOff.ParentNode;
    end
    else
    begin
      // if we got here, there is a problem!
      // Just send it directly to it's destination office
    end;
  end;
end;

function DateToPeriod(Date:TDateTime):Integer;
begin
  Result:=Trunc(Date)-DaysUntil_010198;
end;
function PeriodToDate(Period:Integer):TDateTime;
begin
  Result:=Period+DaysUntil_010198;
end;
function TodayAsPeriod:Integer;
begin
   Result:=DateToPeriod(Now);
end;

function DateTimeToMoment(DateTime : TDateTime) : Integer;
//converts the current datetime to int representing a period and number of seconds
//eg 31/12/02 23:59:59 -> 0236586399
var
  DAyFrac : Double;
  Seconds : Integer;
  Days    : Integer;
  Year, Month, Day : Word;
begin
  DayFrac := Frac(DateTime);
  Seconds     := Round(DayFrac * 24*60*60);
  DecodeDate(DateTime, Year, Month, Day);
  Days := Trunc(DateTime - EncodeDate(Year, 1, 1))+1;
  //mod 2000 to stop integer overflow gives a moment repeat every 6 years approx.
  Result      := (Year mod 10) * 100000000; //2002 -> 0200000000
  Result := Result + Days * 100000;          //13/01/2002 -> 0201300000
  Result := Result + Seconds;               //13/01/2002 23:59 -> 0201386399
end;

function MomentToDateTime(Moment   : Integer) : TDateTime;
var
  DayFrac : Double;
  Year, Day : Word;
begin
  Year := Trunc(Moment/100000000);
  Day := Trunc((Moment - (Year*100000000)) /100000) ;
  Inc(Year, 2000);                      //0236586399 -> 2002
  While Now - EncodeDate(Year, 1, 1) > 3660 do Inc(Year,10);
  While EncodeDate(Year, 1, 1) - Now > 3660 do Dec(Year,10);
  DayFrac := Moment mod 100000 / (24*60*60);
  Result := EncodeDate(Year,1,1) -1 + Day + DayFrac;
end;

procedure EncStringCanvasPixels(Canvas:TCanvas;DestRect:TRect;EncBString:String;XScale:Integer);
var
	X : Integer;
  XOffset : Integer;
  BarWidth : Integer;
begin
  Canvas.Brush.Color := clWhite;
  Canvas.fillRect(DestRect);

  Canvas.Brush.Color := clBlack;
  XOffset := DestRect.Left;
  For X := 1 to Length(EncBString)  do
  begin
    BarWidth:=Integer(EncBString[X])-48; // convert char representation to digit
    BarWidth:=BarWidth*XScale;
    if (X and 1) = 1 then // black bar
    begin
       Canvas.FillRect(Rect( XOffset,
                             DestRect.Top,
                             XOffset+BarWidth,
                             DestRect.Bottom));
    end;
    Inc(XOffset,BarWidth);
  end;
  Canvas.Brush.Color := clWhite;
end;

function LineCount(Bitmap:TBitmap):Integer;
begin
   Result:=Bitmap.Width div 8;
   if (Result*8) <> Bitmap.Width then
      Inc(Result);
end;
function Bitmapline(LineNo,Margin:Integer;Bitmap:TBitmap):String;
var
   I,J,TopOfs:Integer;
   Mask,Value:Byte;
begin
   Result:='';
   if (LineNo*8) > Bitmap.Width then Exit;
   for I:=0 to Margin-1 do Result:=Result+#0;
   TopOfs:=(LineNo*8);
   for I:=Bitmap.Height-1 downto 0 do
   begin
      Mask:=$80;
      Value:=0;
      for J:=0 to 7 do
      begin
         if  (TopOfs+J < Bitmap.Width) 
         and (Bitmap.Canvas.Pixels[TopOfs+J,I] <> clWhite) then
            Value:=Value or Mask;
         Mask:=Mask shr 1;
      end;
      if Value = 26 then Value:=25;
      Result:=Result+Char(Value);
   end;
end;
function SlipInserted:TPrintStat;
var
   Data:WideString;
   Len,Value:Integer;
   SlipIn:Boolean;
   PType:String;
   StatusCommand:String;
   SL:TPackStringList;
   StatusMask:Integer;
   StatusTest:Integer;
   I:Integer;
const
    PrnType:TPrnType = ptUndefined; // ptTanzania, ptOffice
begin
   if GetGPCSRegString('DeviceSetup\Receipt','Check Status','1') = '0' then
   begin
      Result:=psSlipInserted;
      Exit;
   end;
   Result:=psNoPrinter;
   if Receipt = nil then
   begin
      Receipt:=CreateReceiptDevice;
      Receipt.WriteDevice(dcInitialise,'',0);
   end;
   try
      SL:=TPackStringList.Create;
      SL.CommaText:=GetGPCSRegString('DeviceSetup\Receipt','Status Command','$1B,$76,$01');
      StatusMask:=StrToIntDef(GetGPCSRegString('DeviceSetup\Receipt','Status Mask','$60'),$60);
      StatusTest:=StrToIntDef(GetGPCSRegString('DeviceSetup\Receipt','Status Test','$00'),$00);
      StatusCommand:='';
      for I:=0 to SL.Count-1 do
         StatusCommand:=StatusCommand+Char(StrToIntDef(SL[I],0));
      if PrnType = ptUndefined then
      begin
         PType:=GetGPCSRegString('DeviceSetup\Receipt','Type','Tan');
         if PType = 'Tan' then
            PrnType:=ptTanzania
         else if PType = 'Office' then
            PrnType:=ptOffice
      end;
      if PrnType = ptUndefined then Exit; 
   
      if Receipt <> nil then
      begin
         if PrnType = ptTanzania then
            Receipt.WriteDevice(dcRawData,#$1B#$76#$01,3)
         else
            Receipt.WriteDevice(dcRawData,StatusCommand,3);
         Len:=100; SetLength(Data,100);
         Receipt.ReadDevice(Data,Len);
         Data:=Data+#1#1#1#1;
         if Len > 0 then 
         begin
            Value:=Integer(Data[Len]);
            if PrnType = ptTanzania then
               SlipIn:=(Value and $60) = $60
            else
               SlipIn:=(Value and StatusMask) = StatusTest;
            if SlipIn then
               Result:=psSlipInserted
            else
               Result:=psSlipRemoved;
         end;
      end;   
   except
      Result:=psNoPrinter;
   end;   
end;
procedure EndorseJournal(Series:String);
begin
   if Receipt = nil then
   begin
      Receipt:=CreateReceiptDevice;
      Receipt.WriteDevice(dcInitialise,'',0);
   end;
   Receipt.WriteDevice(dcRawData,#$1C#$18,0);  // 1C Select Slip 18 Open Form
   Receipt.WriteDevice(dcRawData,#$1B#$07,0);  // 1B07 Generate Tone
   Receipt.WriteDevice(dcRawData,Series+#13,0); // line underneath
   Receipt.WriteDevice(dcRawData,#$0C#$1E,0); // 0C Eject Form 1E Select Receipt
   Receipt.WriteDevice(dcShutdown,'',0);
   Receipt:=nil;
end;
procedure EndorseMO(Series:String);
begin     
   if Receipt = nil then
   begin
      Receipt:=CreateReceiptDevice;
      Receipt.WriteDevice(dcInitialise,'',0);
   end;
   
   Receipt.WriteDevice(dcRawData,#$1C#$18,0);    // 1C Select Slip 18 Open Form
   Receipt.WriteDevice(dcRawData,#$1B#$07,0);    // 1B07 Generate Tone
   Receipt.WriteDevice(dcRawData,#$1D#$14#$3,0); // Reverse Feed 3 Lines
   Receipt.WriteDevice(dcRawData,#$14#11,0);      // down 8 lines
   Receipt.WriteDevice(dcRawData,Series+'                    '+Series+#13,0);
   Receipt.WriteDevice(dcRawData,#$14#15,0);     // down 15 lines
   Receipt.WriteDevice(dcRawData,Series+'                    '+Series+#13,0);
   Receipt.WriteDevice(dcRawData,#$0C#$1E,0);    // 0C Eject Form 1E Select Receipt
   
   Receipt.WriteDevice(dcShutdown,'',0);
   Receipt:=nil;
end;
function UnPackDate(Date:Integer):TDateTime;
var
  DifferenceDays:Integer;
  D,M,Y,CurrentY,IssueYear:Word;
begin
   Y:=Date div 365;                       // Year mod 3
   DifferenceDays:=Date mod 365;  // days since 01/01/Year
   DecodeDate(Now,CurrentY,m,d);          // this year
   IssueYear:=CurrentY;

   if DifferenceDays > Now then
      IssueYear:=CurrentY-1;
   while ((IssueYear-2000) mod 3) <> Y do Dec(IssueYear);
   Result:=EncodeDate(IssueYear,1,1)+DifferenceDays; // date
end;
function PackDate(Date:TDateTime):Integer;
var
  d,m,y:Word;
  StartOfYearDay:Integer;
  DifferenceDays:Integer;
begin
   DecodeDate(Date,y,m,d); // get day month year
   StartOfYearDay:=Trunc(EncodeDate(y,1,1)); // start of year in days
   DifferenceDays:=(Trunc(Date)-StartOfYearDay); // days since start year
   Y:=(Y-2000) mod 3;
   Result:=DifferenceDays+(Y*365);
end;
function CleanMOSeries(Series:String):String;
var
  I:Integer;
begin
   Result:=UpperCase(Series);
   Series:='';
   for I:=1 to Length(Result) do
   begin
      if Result[I] in ['0'..'9','A'..'Z']  then
      begin
         if Result[I] = 'O' then Series:=Series+'0'
         else Series:=Series+Result[I];
      end;
   end;
   Result:=Series;
end;
function BaseNumbDec(Value:String):UINT;
var          
  I:Integer;
begin
   Result:=0;
   for I:=1 to Length(Value) do
   begin
      Result:=Result*BaseNumb;
      Result:=Result+UINT(Pos(Value[I],BaseVals)-1);
   end;
end;
function BaseNumbEnc(Value,Digits:UINT):String;
begin
   Result:='';
   while (Value > 0) or (Digits > 0) do
   begin
      Result:=BaseVals[(Value mod BaseNumb)+1]+Result;
      Value:=Value div BaseNumb;
      Dec(Digits);
   end;
end;
function OfficeFromIndex(Value:Integer):Integer;
var
   I:Integer;
const
   List:TOfficeList=nil;
begin
   if List = nil then
   begin
      List:=TOfficeList.Create;
      GetOrderOfficeListInfo(nil,List,ofCode );
   end;
   for I:=0 to List.count-1 do
   begin
      if List.Items[I].I3Code = Value then
      begin
         Result:=List.Items[I].Code;
         Exit;
      end;
   end;
   Result:=Value;
end;
function IndexFromOffice(Value:Integer):Integer;
var
   I:Integer;
const
   List:TOfficeList=nil;
begin
   if List = nil then
   begin
      List:=TOfficeList.Create;
      GetOrderOfficeListInfo(nil,List,ofCode );
   end;
   for I:=0 to List.count-1 do
   begin
      if List.Items[I].Code = Value then
      begin
         Result:=List.Items[I].I3Code;
         Exit;
      end;
   end;
   Result:=Value;
end;
                          
function MOSeriesToCode128(Series:String):String;
var
  Seg1:Integer;
  Seg2:Integer;
  Seg3:Integer;
  SerialNo:String;
  Value:Currency;
  IOffice,POffice,Clerk:Integer;
  MOType:TMOType;
  IssueDate:TDateTime;
begin
   Result:='';
   if not DecodeMoneyOrder(Series,SerialNo,Value,IOffice,POffice,Clerk,MOType,IssueDate) then Exit;
   Seg1:=((Trunc(Value) and $FFFFFFF) shl 3) 
       or (Integer(MOType) and 7);
   Seg2:=((StrToInt(SerialNo) and $FFFFFF) shl 7) 
       or (Clerk and $7F);
   Seg3:=((PackDate(IssueDate) and $7FF) shl 20)
      or ((IndexFromOffice(IOffice) and $3FF) shl 10) 
      or  (IndexFromOffice(POffice) and $3FF);
      
   Result:=       LeftPad(IntToStr(Seg1),10,'0');
   Result:=Result+LeftPad(IntToStr(Seg2),10,'0');
   Result:=Result+LeftPad(IntToStr(Seg3),10,'0');
end;
function Code128ToMOSeries(Code128Data:String;WithSpacing:Boolean):String;
var
  Seg1:Integer;
  Seg2:Integer;
  Seg3:Integer;
  SerialNo:String;
  Value:Currency;
  IOffice,POffice,Clerk:Integer;
  MOType:TMOType;
  IssueDate:TDateTime;
begin 
   Seg1:=StrToInt(Copy(Code128Data, 1,10));  
   Seg2:=StrToInt(Copy(Code128Data,11,10));  
   Seg3:=StrToInt(Copy(Code128Data,21,10));  
   
   Value:=(Seg1 shr 3) and $FFFFFFF;
   MOType:=TMOType(Seg1 and 7);
   SerialNo:=IntToStr((Seg2 shr 7) and $FFFFFF);
   Clerk:=Seg2 and $7F;
   IssueDate:=UnPackDate((Seg3 shr 20) and $7FF);
   IOffice:=OfficeFromIndex((Seg3 shr 10)and $3FF);
   POffice:=OfficeFromIndex(Seg3 and $3FF);
   
   Result:=EncodeMoneyOrder(SerialNo,Value,IOffice,POffice,Clerk,MOType,IssueDate,WithSpacing);
end;
function BaseNumbCRC(Value:String):String;
begin
   Result:=BaseNumbEnc(Abs(CalcCCITTCRC(Value)) mod BaseNumb,1);
end;

procedure SwapVals(var S:String;Pos1,Pos2:Integer);
var
   T:Char;
begin
   T:=S[Pos1];
   S[Pos1]:=S[Pos2];
   S[Pos2]:=T;
end;
function EncPos(Up:Boolean;Value:String):String;
const
   ShuffleStr:String = '0123456789ABCDEFGHIJKLMNPQRSTUVWXYZ0123456789ABCDEFGHIJKLMNPQRSTUVWXYZ';
var
  I:Integer;
begin
   if Up then
   begin
      for I:=2 to Length(Value) do 
         Value[I]:=ShuffleStr[Pos(Value[I],ShuffleStr)+I];
      SwapVals(Value, 2,14); SwapVals(Value, 3,19); SwapVals(Value, 4,11);
      SwapVals(Value, 5,16); SwapVals(Value, 6,18); SwapVals(Value, 7,17);
      SwapVals(Value, 8,13); SwapVals(Value, 9,12); SwapVals(Value,10,15);
      SwapVals(Value,20,3);
   end
   else
   begin
      SwapVals(Value,20,3);
      SwapVals(Value, 2,14); SwapVals(Value, 3,19); SwapVals(Value, 4,11);
      SwapVals(Value, 5,16); SwapVals(Value, 6,18); SwapVals(Value, 7,17);
      SwapVals(Value, 8,13); SwapVals(Value, 9,12); SwapVals(Value,10,15);
      for I:=2 to Length(Value) do 
         Value[I]:=ShuffleStr[BaseNumb+(Pos(Value[I],ShuffleStr)-I)];
   end;
   Result:=Value;
end;
function ShuffleType(SType:Integer;Up:Boolean;Value:String):String;
const
   ShuffleStr1:String = 'HSUYZFGQ8JK6VLBCM2P37E9NTIADR1X5W40';
   ShuffleStr2:String = 'GQ8JKD37IALE9N6UY2PBCMZVW4TR1X50HSF';
   ShuffleStr3:String = '6ULE9NPBCMZVTR1X50FY2GQI8W4JKD3HS7A';
   ShuffleStr4:String = 'THEQUICKBR0WNFXJMPSVLAZYDG123456789';
var
  S:String;
  I:Integer;
begin
   S:=Value[1];
   if Up then
   begin
      case SType of 
         1 :  for I:=2 to Length(Value) do
                S:=S+ShuffleStr1[Pos(Value[I],BaseVals)];
         2 :  for I:=2 to Length(Value) do
                S:=S+ShuffleStr2[Pos(Value[I],BaseVals)];
         3 :  for I:=2 to Length(Value) do
                S:=S+ShuffleStr3[Pos(Value[I],BaseVals)];
         else for I:=2 to Length(Value) do
                S:=S+ShuffleStr4[Pos(Value[I],BaseVals)];
      end;
      Result:=EncPos(Up,S);
   end
   else
   begin
      Value:=EncPos(Up,Value);
      case SType of 
         1 :  for I:=2 to Length(Value) do
                S:=S+BaseVals[Pos(Value[I],ShuffleStr1)];
         2 :  for I:=2 to Length(Value) do
                S:=S+BaseVals[Pos(Value[I],ShuffleStr2)];
         3 :  for I:=2 to Length(Value) do
                S:=S+BaseVals[Pos(Value[I],ShuffleStr3)];
         else for I:=2 to Length(Value) do
                S:=S+BaseVals[Pos(Value[I],ShuffleStr4)];
      end;
      Result:=S;
   end;                
end;   
function Shuffle(Up:Boolean;Value:String):String;
begin
   if Length(Value) <> 20 then Exit;
   Result:=ShuffleType(Integer(Value[1]) mod 4,Up,Value);
end;  
// Base 35 dont use O(Owe) confused with 0(Zero)
// Decoding MO Series 
// Serial Number 45435423
// Value         1,544,804,415.00
// IOffice       1023
// POffice       1023
// Clerk         127
// MOType        7
// Date          31/12/2002
function EncodeMoneyOrder(SerialNo:String;Value:Currency;IOffice,POffice,Clerk:Integer;MOType:TMOType;IssueDate:TDateTime;WithSpacing:Boolean):String;
var
  DifferenceDays:Integer;
  ResSerialNo :String;
  ResValue    :String;
  ResOffice   :String;
  ResIssueDate:String;
  ResCRC      :String;
  OfficeClerkType:UINT;
begin
   if IssueDate <> 0 then
      DifferenceDays:=PackDate(IssueDate)
   else
      DifferenceDays:=0;

   IOffice:=IndexFromOffice(IOffice);
   POffice:=IndexFromOffice(POffice);
   OfficeClerkType:=((IOffice and $03FF) shl 20)   // max 1023
                 or ((POffice and $03FF) shl 10)   // max 1023
                 or ((Clerk   and $007F) shl  3)   // max 127
                 or ((Integer(MOType)  and $0007));// max 7
   ResSerialNo  :=BaseNumbEnc(StrToIntDef(SerialNo,0),5);
   ResValue     :=BaseNumbEnc(Trunc(Value)           ,6);
   ResOffice    :=BaseNumbEnc(OfficeClerkType        ,6);
   ResIssueDate :=BaseNumbEnc(DifferenceDays         ,2);

   Result:=ResIssueDate+ResSerialNo+ResValue+ResOffice;
   ResCRC:=BaseNumbCRC(Result);
   Result:=Shuffle(True,ResCRC+Result);
   if WithSpacing then
      Result:=Copy(Result, 1,5)+' '
             +Copy(Result, 6,5)+' '
             +Copy(Result,11,5)+' '
             +Copy(Result,16,5);
end;
function CheckSeries(Series:String):Boolean;
begin
   Result:=False;
   Series:=CleanMOSeries(Series);
   Series:=Shuffle(False,Series);
   if (Length(Series) <> 20) 
   or (Copy(Series,1,1) <> BaseNumbCRC(Copy(Series,2,19))) then 
      Exit;
   Result:=True;
end;
//function DecodeMoneyOrder(Series:String;var SerialNo:String;var Value:Currency;var IOffice,POffice,Clerk,MOType:Integer;var IssueDate:TDateTime):Boolean;
function DecodeMoneyOrder(Series:String;var SerialNo:String;var Value:Currency;var IOffice,POffice,Clerk:Integer;var MOType:TMOType;var IssueDate:TDateTime):Boolean;
var
  ResIssueDate :Integer;
  OfficeClerkType:DWORD;
begin 
   Result:=False;
   Series:=CleanMOSeries(Series);
   Series:=Shuffle(False,Series);
   if (Length(Series) <> 20) 
   or (Copy(Series,1,1) <> BaseNumbCRC(Copy(Series,2,19))) then 
      Exit;
   Result:=True;
                   
   ResIssueDate:=         BaseNumbDec(Copy(Series, 2,2)) ;  
   SerialNo    :=IntToStr(BaseNumbDec(Copy(Series, 4,5)));  
   Value       :=         BaseNumbDec(Copy(Series, 9,6)) ;
   OfficeClerkType:=      BaseNumbDec(Copy(Series,15,6)) ;

   IOffice:=OfficeFromIndex(((OfficeClerkType shr 20) and $03FF)); // max 1023
   POffice:=OfficeFromIndex(((OfficeClerkType shr 10) and $03FF)); // max 1023
   Clerk  :=((OfficeClerkType shr  3) and $007F); // max 127
   MOType :=TMOType(((OfficeClerkType       ) and $0007)); // max 7

   IssueDate:=UnPackDate(ResIssueDate);
end;

procedure PayMO(Series:String;Clerk,Date:Integer;TxnLog:ITransactionLog);
var
   MoneyOrder:TMoneyOrder;
   MOEvent:TMOEvent;
begin
   MoneyOrder:=TMoneyOrder.Create;
   MoneyOrder.Events:=TMOEvents.Create;
   MoneyOrder.Series:=Series;
   MoneyOrder.PayPeriod:=Date;
   MoneyOrder.PayClerk:=Clerk;

   MOEvent          := TMOEvent .Create;
   MOEvent.EvType   := Integer(evPaid);
   MOEvent.EvWho    := Clerk;
   MOEvent.EvWhere  :=MoneyOrder.PayOffice;
   MOEvent.EvWhen   := DateTimeToMoment(PeriodToDate( Date));
   MoneyOrder.Events.Add(MOEvent);

   MOEvent :=TMOEvent .Create;
   MOEvent.EvType :=Integer(evPayLodged);
   if SharedData <> nil then
   begin
      MOEvent.EvWho  :=StrToIntDef(SharedData.GetVariable('ClerkCode' ),0);
      MOEvent.EvWhere:=StrToIntDef(SharedData.GetVariable('OfficeCode'),0);
   end
   else
   begin
      MOEvent.EvWho  := 0;
      MOEvent.EvWhere:= 0;
   end;

   MOEvent.EvWhen :=DateTimeToMoment(Now);
   MoneyOrder.Events.Add(MOEvent);

   MoneyOrder.SaveToTable('PSL');
   MoneyOrder.RemFromList(MoneyOrder.PayOffice);
   if Txnlog <> nil then
      TxnLog.WriteTransaction('*MOPInfo',0,1,0,0,0,'Money Order Paid','','MOPaid',MoneyOrder.PackedString);
   MoneyOrder.Free;

// PayMO(ProdForm.Series.Text,0,DateToPeriod(Now),TxnLog);
// MFLogPaid
end;

function DBTypePrefix : String;
begin

  if GetGPCSRegString('Workstation','DBType','Paradox') = 'SQLServer' then
    Result := 'dbo.'
  else
    Result := '';

end;

procedure GetOrderOfficeList( List:TComboBox );
begin
   GetOrderOfficeListInfo(List,nil,ofCode );
end;
procedure GetShortOfficeList( List:TComboBox );
begin
   GetOrderOfficeListInfo(List,nil,ofScode );
end;
function CodeToName(OfficeListCombo:TComboBox;Code:Integer):String;
var
  I:Integer;
begin
   Result:=IntToStr(Code);
   for I:=0 to OfficeListCombo.Items.Count-1 do
   begin
      if StrToIntDef('$'+Copy(TStringObject(OfficeListCombo.Items.Objects[I]).Value,2,4),0) = Code then
      begin
         Result:=OfficeListCombo.Items[I];
         break;
      end;
   end;
end;
function GetSCodeFromOList(OfficeListCombo:TComboBox):String;
var
   Index:Integer;
   List:TStrings;
begin  
   Result:='';
   List:=OfficeListCombo.Items;
   Index:=OfficeListCombo.Items.IndexOf(OfficeListCombo.Text);
   if List.Objects[Index] = nil then 
      Exit;
   Result:=Copy(TStringObject(List.Objects[Index]).Value,6,3);
end;
function GetCodeFromOList(OfficeListCombo:TComboBox):String;
var
   Index:Integer;
   List:TStrings;
begin  
   Result:='';
   List:=OfficeListCombo.Items;
   Index:=OfficeListCombo.Items.IndexOf(OfficeListCombo.Text);
   if List.Objects[Index] = nil then 
      Exit;
   Result:=IntToStr(StrToIntDef('$'+Copy(TStringObject(List.Objects[Index]).Value,2,4),0));
end;
procedure GetOrderOfficeListInfo( List:TComboBox; ListCodes:TOfficeList;Field:TOfficeField );
var
   I:Integer;
   SL:TPackStringList;
   OffCodeRef:TOffCodeRef;
begin
   SL:=TPackStringList.Create;
   OffCodeRef:=TOffCodeRef.Create;
   if List <> nil then
      List.Clear; 
   SL.Packtext:=FileTxStatusU.TTxnTransfer.OfficeCodeRefs;
   case Field of
      ofCode  : 
         begin
            for I:=0 to SL.Count-1 do                              
            begin
               OffCodeRef.PackText:=SL[I];
               if List <> nil then
                  List.Items.AddObject(OffCodeRef.OfficeTitle,TStringObject.Create('O'+IntToHex(OffCodeRef.OfficeCode,4)+OffCodeRef.OfficeSCode));
               if ListCodes <> nil then
                  ListCodes.Add( TOfficeCodes.Create( OffCodeRef.OfficeTitle,
                                                      OffCodeRef.OfficeCode,
                                                      OffCodeRef.OfficeSCode,
                                                      OffCodeRef.OfficeI3Code));
            end;
         end;
      ofScode : 
         begin
            for I:=0 to SL.Count-1 do                              
            begin
               OffCodeRef.PackText:=SL[I];
               if Pos('Fax',OffCodeRef.OfficeType) > 0 then
               begin
                  if List <> nil then
                     List.Items.AddObject(OffCodeRef.OfficeTitle,TStringObject.Create('O'+IntToHex(OffCodeRef.OfficeCode,4)+OffCodeRef.OfficeSCode));
                  if ListCodes <> nil then
                     ListCodes.Add( TOfficeCodes.Create( OffCodeRef.OfficeTitle,
                                                         OffCodeRef.OfficeCode,
                                                         OffCodeRef.OfficeSCode,
                                                         OffCodeRef.OfficeI3Code));
               end;
            end;    
         end;
   end;  
   SL.Free;
   if List <> nil then
      List.Sorted:=True;
end;

end.
