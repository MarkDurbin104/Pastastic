unit ReceiptAU;

interface

uses
  Windows,Graphics,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Registry,Dialogs;
  
const
   ReceiptWidth  = 44;
   {Series 3 of 9 Barcode data }
   BarMap:String ='$%*+ -./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
   Bars:Array[1..44] of String =(
	'010101000',	'000101010',	'010010100',	'010001010',	'011000100',
	'010000101',	'110000100',	'010100010',	'000110100',	'100100001',
	'001100001',	'101100000',	'000110001',	'100110000',	'001110000',
	'000100101',	'100100100',	'001100100',	'100001001',	'001001001',
	'101001000',	'000011001',	'100011000',	'001011000',	'000001101',
	'100001100',	'001001100',	'000011100',	'100000011',	'001000011',
	'101000010',	'000010011',	'100010010',	'001010010',	'000000111',
	'100000110',	'001000110',	'000010110',	'110000001',	'011000001',
	'111000000',	'010010001',	'110010000',	'011010000'   );
  CompStr='$%+ -./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
type
  TReceiptDevice = class(TGPCSDevice,IDevice,IDeviceEventSink)
    FLastBarCode : String;
    FHeader      : String;
    FTitle       : String;
    FOfficeData1 : String;
    FOfficeData2 : String;
    FThankYou    : String;
    FTotal       : String;
    FLogoFile    : String;
    FUser        : Integer;
    FOffice      : Integer;
    FValue       : Integer;
    FFee         : Integer;
    FZip         : Integer;
    FWorkstation : Integer;
    FIdent        : String;
    FWUser        : String;
    FWOffice      : String;
    FWValue       : String;
    FWFee         : String;
    FWZip         : String;
    FWWorkstation : String;
    FDeviceEventSink:IDeviceEventSink;
  protected
    function  FormatReceiptData(Quantity,Description,Value:String):String;
    procedure PrintReport(Data:String;Columns:Integer);
    procedure PrintReceipt(Data:String);
    procedure PrintSlip(Data:String);
    procedure ReceiptData(Data:String);
    function  GetDeviceEntry(Name:String):String;
    function  CalcRBC(Clerk,Pos,Office:Integer):String;
  public  
    procedure SetEventSink(const EventSink: IDeviceEventSink);                          override;
    function  WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool; override;
    function  ReadDevice(var Data: WideString;var Len: Integer):WordBool;                  override;
    function  GetStatus: WideString;                                                    override;
    function  TakeControl: WordBool;                                                    override;
    procedure ReleaseControl;                                                           override;
    procedure Trigger(const Data: WideString);                                          safecall;
    procedure ControlReleased;                                                          safecall;
  end;                  
  
implementation
uses
   ComServ2,ReceiptFU;
   
procedure TReceiptDevice.SetEventSink(const EventSink: IDeviceEventSink);
begin
   FDeviceEventSink:=EventSink;
end;
function TReceiptDevice.GetDeviceEntry(Name:String):String;
var
   Registry:TRegistry;
   SL:TStringList;
begin
   SL:=TStringList.Create;
   Registry:=TRegistry.Create;
   with Registry do
   begin
      RootKey:=HKEY_LOCAL_MACHINE;
      if OpenKey('SOFTWARE\PSL\GPCS\DeviceSetup\'+Name,False) then
      begin
         SL.Add(ReadString('PortNumber'));
         SL.Add(ReadString('BaudRate'  ));
         SL.Add(ReadString('DataBits'  ));
         SL.Add(ReadString('Parity'    ));
         SL.Add(ReadString('StopBits'  ));
         SL.Add(ReadString('InTimeOut' ));
         SL.Add(ReadString('OutTimeOut'));
         Result:=SL.CommaText;
         FLogoFile:=ReadString('LogoFileName');
         if FLogoFile = '' then
           FLogoFile:='LogoBW.bmp';
      end                       
      else
      begin
         Result:='1,9600,8,N,1,500,500';
         FLogoFile:='LogoBW.bmp';
      end;
      CloseKey;
      Free;
   end;
   Sl.Free;
end;
function TReceiptDevice.FormatReceiptData(Quantity,Description,Value:String):String;
var
   I:Integer;
begin
   Quantity   :=Trim(Quantity   );
   Description:=Trim(Description);
   Value      :=Trim(Value      );
   while Length(Quantity) < 3 do Quantity:=' '+Quantity;
   SetLength(Result,ReceiptWidth);
   for I:=1 to Length(Quantity) do Result[I]:=Quantity[I];
   Result[Length(Quantity)+1]:=' ';
   for I:=1 to Length(Description) do Result[Length(Quantity)+1+I]:=Description[I];
   for I:=Length(Description)+Length(Quantity)+2 to ReceiptWidth do Result[I]:=' ';
   for I:=1 to Length(Value) do Result[(ReceiptWidth-Length(Value))+I]:=Value[I];
end;
procedure TReceiptDevice.ReceiptData(Data:String);
var
   Lines:TStringList;
begin
   Lines:=TStringList.Create;
   Lines.CommaText:=Data;
   if Lines.Count >  0 then FUser        :=StrToIntDef(Lines[ 0],0);
   if Lines.Count >  1 then FOffice      :=StrToIntDef(Lines[ 1],0);
   if Lines.Count >  2 then FValue       :=StrToIntDef(Lines[ 2],0);
   if Lines.Count >  3 then FFee         :=StrToIntDef(Lines[ 3],0);
   if Lines.Count >  4 then FZip         :=StrToIntDef(Lines[ 4],0);
   if Lines.Count >  5 then FWorkstation :=StrToIntDef(Lines[ 5],0);
   if Lines.Count >  6 then FIdent       :=            Lines[ 6]   ;
   if Lines.Count >  7 then FWUser       :=            Lines[ 7]   ;
   if Lines.Count >  8 then FWOffice     :=            Lines[ 8]   ;
   if Lines.Count >  9 then FWValue      :=            Lines[ 9]   ;
   if Lines.Count > 10 then FWFee        :=            Lines[10]   ;
   if Lines.Count > 11 then FWZip        :=            Lines[11]   ;
   if Lines.Count > 12 then FWWorkstation:=            Lines[12]   ;
   if Lines.Count > 13 then FTitle       :=            Lines[13]   ;
   if Lines.Count > 14 then FOfficeData1 :=            Lines[14]   ;
   if Lines.Count > 15 then FOfficeData2 :=            Lines[15]   ;
   if Lines.Count > 16 then FThankYou    :=            Lines[16]   ;
   if Lines.Count > 17 then FTotal       :=            Lines[17]   ;
   Form1.Memo1.Lines.Add('FUser        ='+IntToStr(FUser        ));
   Form1.Memo1.Lines.Add('FOffice      ='+IntToStr(FOffice      ));
   Form1.Memo1.Lines.Add('FValue       ='+IntToStr(FValue       ));
   Form1.Memo1.Lines.Add('FFee         ='+IntToStr(FFee         ));
   Form1.Memo1.Lines.Add('FZip         ='+IntToStr(FZip         ));
   Form1.Memo1.Lines.Add('FWorkstation ='+IntToStr(FWorkstation ));
   Form1.Memo1.Lines.Add('FIdent       ='+FIdent       );
   Form1.Memo1.Lines.Add('FWUser       ='+FWUser       );
   Form1.Memo1.Lines.Add('FWOffice     ='+FWOffice     );
   Form1.Memo1.Lines.Add('FWValue      ='+FWValue      );
   Form1.Memo1.Lines.Add('FWFee        ='+FWFee        );
   Form1.Memo1.Lines.Add('FWZip        ='+FWZip        );
   Form1.Memo1.Lines.Add('FWWorkstation='+FWWorkstation);
   Form1.Memo1.Lines.Add('FTitle       ='+FTitle       );
   Form1.Memo1.Lines.Add('FOfficeData1 ='+FOfficeData1 );
   Form1.Memo1.Lines.Add('FOfficeData2 ='+FOfficeData2 );
   Form1.Memo1.Lines.Add('FThankYou    ='+FThankYou    );
   Form1.Memo1.Lines.Add('FTotal       ='+FTotal       );
   Lines.Free;
end;
function CurrToB43(Value:Currency;BCLength:Integer):String;
var
   I:Integer;
   V:Integer;
   TVal:Currency;
begin
   Result:='';
   for I:=1 to BCLength do
   begin
       TVal:=Int(Value/43)*43;
       V:=Trunc(Value-TVal);
       Value:=Int(Value/43);
       Result:=Result+CompStr[1+V];
   end;
end;
function B43toCurr(S:String):Currency;
var
   I,J:Integer;
begin
   Result:=0;
   for I:=Length(S) downto 1 do
   begin
       Result:=Result*43.0;
       for J:=1 to 43 do
       begin
          if S[I] = CompStr[J] then
          begin
             Result:=Result+(J-1);
             break;
          end;
       end;
   end;
end;
function TReceiptDevice.CalcRBC(Clerk,Pos,Office:Integer):String;
var      
   Day   :Word;
   Month :Word;
   Year  :Word;
   Hour  :Word;
   Minute:Word;
   Second:Word;
   milli:Word;
   Value:Comp;
   CV:Comp;
   NW:TDateTime;
begin
   NW:=Now;
   DecodeDate(NW,Year,Month,Day);
   DecodeTime(NW,Hour,Minute,Second,milli);
   Year:=Year-1997;
   Value:=Second;                   CV:=60;
   Value:=Value+(Trunc(Minute)*CV); CV:=CV*60;
   Value:=Value+(Trunc(Hour)*CV);   CV:=CV*24;
   Value:=Value+(Trunc(Day)*CV);    CV:=CV*31;
   Value:=Value+(Trunc(Month)*CV);  CV:=CV*12;
   Value:=Value+(Trunc(Year)*CV);  
   Result:=CurrToB43(Value,6);  // DateTime 00:00:00 01/01/1997 - 23:59:59 2193
   Value:=Office;
   Result:=Result+CurrToB43(Value,3); // Office 00000 - 79507
   Value:=Pos;
   Value:=Value+Clerk*100;
   Result:=Result+CurrToB43(Value,3); // Pos 00 to 99 Teller 000 to 794
   FLastBarCode:=Result;
end;
function CalcFromRBC(var Clerk,Pos,Office:Integer;var DateTime:TDateTime;S:String):String;
var
   Day   :Word;
   Month :Word;
   Year  :Word;
   Hour  :Word;
   Minute:Word;
   Second:Word;
   Value:Comp;
   CV:Comp;
begin
   Value:=B43ToCurr(Copy(S,1,6));
   CV:=12;
   CV:=CV*31;
   CV:=CV*24;
   CV:=CV*60;
   CV:=CV*60;
   Year:=Trunc(Value/CV);
   Value:=Value-Year*CV;
   Year:=Year+97;
   CV:=CV/12;
   Month:=Trunc(Value/CV);
   Value:=Value-Month*CV;
   CV:=CV/31;
   Day:=Trunc(Value/CV);
   Value:=Value-Day*CV;
   CV:=CV/24;
   Hour:=Trunc(Value/CV);
   Value:=Value-Hour*CV;
   CV:=CV/60;
   Minute:=Trunc(Value/CV);
   Second:=Trunc(Value-Minute*CV);
   Office:=Trunc(B43ToCurr(Copy(S,7,3)));       
   Value:=B43ToCurr(Copy(S,10,3));
   Clerk:=Trunc(Value/100);
   Pos:=Trunc(Value-Clerk*100);
   Result:=IntToStr(Day)+'/'+IntToStr(Month)+'/'+IntToStr(Year)+' '+IntToStr(Hour)+':'+IntToStr(Minute)+':'+IntToStr(Second);
   DateTime:=EncodeDate(Year+1900,Month,Day);
   DateTime:=DateTime+EncodeTime(Hour,Minute,Second,0);
   Result:=Result+' '+IntToStr(Office)+' '+IntToStr(Pos)+' '+IntToStr(Clerk);
end;    
procedure TReceiptDevice.PrintSlip(Data:String);
var
  SL:TStringList;
  I:Integer;
begin
   SL:=TStringList.Create;
   SL.CommaText:=Data;
   for I:=0 to SL.Count-1 do
      Form1.Memo1.Lines.Add(SL[I]);
   SL.Free;
end;
procedure TReceiptDevice.PrintReport(Data:String;Columns:Integer);
var
   Lines:TStringList;
   Cols:TStringList;
   LineCount,I,CurLine:Integer;
   S,Str:String;
   
begin
   Lines:=TStringList.Create;
   Cols:=TStringList.Create;
   Lines.CommaText:=Data;
   LineCount:=0;
   Str:='                                          ';
   CurLine:=0;
   while LineCount < Lines.Count do
   begin
      Cols.CommaText:=Lines[LineCount];
      S:=Cols[0];
      for I:=1 to Length(S) do Str[I]:=S[I];
      S:=Cols[1];
      case CurLine of
         2 : FOffice     :=StrToIntDef(S,0);
         3 : FUser       :=StrToIntDef(S,0);
         4 : FWorkstation:=StrToIntDef(S,0);
      end;
      for I:=1 to Length(S) do Str[(Length(Str)-Length(S))+I]:=S[I];
      Inc(LineCount);
      Form1.Memo1.Lines.Add(Str);
      Str:='                                          ';
      Inc(CurLine);
   end; 
   Cols.Free;
   Lines.Free;
   CalcRBC(FUser,FWorkstation,FOffice);
   Form1.Memo1.Lines.Add(CalcRBC(FUser,FWorkstation,FOffice));
end;
procedure TReceiptDevice.PrintReceipt(Data:String);
var
   Lines:TStringList;
   Items:TStringList;
   LineCount:Integer;
begin
   Lines:=TStringList.Create;
   Items:=TStringList.Create;
   Lines.CommaText:=Data;
   Form1.Memo1.Lines.Add(FTitle);
   Form1.Memo1.Lines.Add(FOfficeData1);
   Form1.Memo1.Lines.Add(FOfficeData2);
   for LineCount:=0 to Lines.Count-1 do
   begin
      Items.CommaText:=Lines[LineCount];
      Form1.Memo1.Lines.Add(FormatReceiptData(Items[0],Items[1],Items[2]));
   end;
   Lines.Free;
   Items.Free;
   Form1.Memo1.Lines.Add(FThankYou);
   Form1.Memo1.Lines.Add(FormatDateTime('DD/MM/YYYY HH:NN:SS',Now));
end;
function TReceiptDevice.WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool;
begin
   Result:=False;
   case CommandType of
      dcInitialise : begin
//                        Form1.Caption:=GetDeviceEntry('Receipt');
                        Result:=True;       
                      end;
      dcRawData    : begin
                        Form1.Memo1.Lines.Add(Data);
                        Result:=True;
                     end;
      dcShutdown   : begin
                        FDeviceEventSink:=nil;
                        Result:=True;
                     end;
      dcLine1Data  : begin 
                       Form1.Memo1.Lines.Add(Data);
                       Result:=True;
                     end;
      dcLine2Data  : begin
                       Form1.Memo1.Lines.Add(Data);
                       Result:=True;
                     end;
      dcLine3Data  : Result:=True;
      dcLine4Data  : Result:=True;
      dcLine5Data  : Result:=True;
      dcList1Data  : begin
                       PrintReceipt(Data);
                       Result:=True;
                     end;
      dcList2Data  : begin
                       ReceiptData(Data);
                       Result:=True;
                     end;
      dcList3Data  : begin
                       PrintSlip(Data);
                       Result:=True;
                     end;
      dcList4Data  : begin
                       PrintReport(Data,2);
                       Result:=True;
                     end;
      dcList5Data  : begin
                       PrintReport(Data,2);
                       Result:=True;
                     end;
      else Result:=False;
   end;                            
end;              
function TReceiptDevice.ReadDevice(var Data: WideString;var Len: Integer):WordBool;
var
   Clerk,Pos,Office:Integer;
   DateTime:TDateTime;
begin
   Data:=CalcFromRBC(Clerk,Pos,Office,DateTime,Data);
   Result:=True;
end;
function TReceiptDevice.GetStatus: WideString;
begin
   Form1.Memo1.Lines.Add('---- '+FLastBarCode+' ----');
   Result:=FLastBarCode;
end;
function TReceiptDevice.TakeControl: WordBool; 
begin
   Result:=False;
end;
procedure TReceiptDevice.ReleaseControl;       
begin
end;
procedure TReceiptDevice.Trigger(const Data: WideString);
begin
end;
procedure TReceiptDevice.ControlReleased;
begin
end;
initialization
  TGPCSCompFactory.Create(ComServer,TReceiptDevice,Class_ReceiptDevice,
                          'Device.Receipt','GPCS Receipt Device',
                          ciMultiInstance);
end.