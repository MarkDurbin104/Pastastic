unit ReceiptAU;

interface

uses
  Dialogs,Windows,Messages,Graphics,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Registry,PackStrListU;

const
   HIGHGRAPHICS  = True;
   ReceiptWidth:Integer  = 34+Integer(not HIGHGRAPHICS)*21;
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
  TPrnType = (ptUndefined,ptOffice,ptTanzania);
  TPrintStat = (psNoPrinter,psSlipInserted,psSlipRemoved);
  TDLThread = class(TThread)
     FLogoFile:String;
     FSerialDevice:IDevice;
     procedure Execute; override;
  end;
  TReceiptDevice = class(TGPCSDevice,IDevice,IDeviceEventSink)
  private
    FLastBarCode : String;
//    FHeader      : String;
    FTitle       : WideString;
    FOfficeData1 : WideString;
    FOfficeData2 : WideString;
    FThankYou    : WideString;
    FTotal       : WideString;
    FLogoFile    : WideString;
    FUser        : WideString;
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
    FUseGraphics  :Boolean;
    FDeviceEventSink:IDeviceEventSink;
    FSerialDevice:IDevice;
    TheGrammesSymbol:String;
    DLThread:TDLThread;
    function GetPrinterStatus:TPrintStat;
    function WaitFor(Status:TPrintStat):Boolean;
    procedure PrintGraphicsText(Data:WideString);
    procedure PrintText(Data:String);
    procedure PrintDate;
    function TakeOutG(Value:String):String;
  protected
    procedure Endorse(Space:Integer;Prompt:String;Data:Integer);
    procedure EndorseS(Space:Integer;Prompt:String);
    procedure Stamp(Data:String);
    procedure EndorseDT(Space:Integer);
    function  FormatReceiptData(Quantity,Description,Value:WideString):WideString;
    procedure PrintReport(Data:String;Columns:Integer);
    procedure PrintCA(Data:String);
    procedure PrintReceipt(Data:WideString);
    procedure PrintSlip(Data:String);
    procedure ReceiptData(Data:String);
    procedure PrintLogo;
    function  GetDeviceEntry(Name:String):String;
    procedure DownLoadLogo;
    function  CalcRBC(Clerk,Pos,Office:Integer):String;
    procedure PrintReceiptLine(Data:WideString);
    procedure PrintReceiptHead;
    procedure PrintReceiptFoot;
    procedure PrintTrackingReceipt(Data:String);
    procedure PrintExFooter;
    procedure PrintExHeader;
  public
    function ReMapChars(Text:String):String;
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
   ComServ2;
   
procedure Log(Desc,Data:String);
const
   Logging:Boolean = True;
var
   SL:TPackStringList;
begin
   if (Logging) and (GetGPCSRegString('DeviceSetup\Receipt','Logging','0') = '1') then
   begin
      SL:=TPackStringList.Create;
      if FileExists('C:\Receipt.Log') then
         SL.LoadFromFile('C:\Receipt.Log');
      while SL.Count > 100 do SL.Delete(0);
      SL.Add(Desc+' ['+Data+']');
      SL.SaveToFile('C:\Receipt.Log');
      SL.Free;
   end
   else
   begin
      Logging:=False;
   end;
end;
function TReceiptDevice.GetPrinterStatus:TPrintStat;
var
   Data:WideString;
   Len,Val:Integer;
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
   Val:=0;
   try
      SL:=TPackStringList.Create;
      SL.CommaText:=GetGPCSRegString('DeviceSetup\Receipt','Status Command','$1B,$76,$01');
      StatusMask:=StrToIntDef(GetGPCSRegString('DeviceSetup\Receipt','Status Mask','$60'),$60);
      StatusTest:=StrToIntDef(GetGPCSRegString('DeviceSetup\Receipt','Status Test','$00'),$00);
      StatusCommand:='';
      for I:=0 to SL.Count-1 do
      begin
         StatusCommand:=StatusCommand+Char(StrToIntDef(SL[I],0));
      end;
      for I:=1 to Length(StatusCommand) do
         Log('Status Comand '+IntToStr(Integer(StatusCommand[I])),IntToHex(Integer(StatusCommand[I]),2));
      Log('PType',PType);
      if PrnType = ptUndefined then
      begin
         PType:=GetGPCSRegString('DeviceSetup\Receipt','Type','Tan');
         if PType = 'Tan' then
            PrnType:=ptTanzania
         else if PType = 'Office' then
            PrnType:=ptOffice
      end;   
      Result:=psNoPrinter;
      Log('PType',PType);
      case PrnType of
         ptUndefined : Log('PrnType','ptUndefined');
         ptTanzania  : Log('PrnType','ptTanzania');
         ptOffice    : Log('PrnType','ptOffice');
      end;         
      if PrnType = ptUndefined then Exit; 
   
      if FSerialDevice <> nil then
      begin
         Log('SerialDevice','OK');
         if PrnType = ptTanzania then
            FSerialDevice.WriteDevice(dcRawData,#$1B#$76#$01,3)
         else
            FSerialDevice.WriteDevice(dcRawData,StatusCommand,3);
   //         FSerialDevice.WriteDevice(dcRawData,#$1D#$72#$01,3);
         Log('Write','StatusCommand');
         Len:=100; SetLength(Data,100);
         FSerialDevice.ReadDevice(Data,Len);
         Data:=Data+#1#1#1#1;
         Log('Read Length',IntToStr(Len));
         Log('Length Data',IntToStr(Length(Data)));
         try
         for I:=1 to Length(Data) do
            Log('Read Data','$'+IntToHex(Integer(Data[I]),2));
         except
            Log('Exception in Read Data List','');
         end;
         try
            for I:=1 to Len+1 do
               Log('Read Data Force Len','$'+IntToHex(Integer(Data[I]),2));
         except
            Log('Exception in Read Data Force List','');
         end;
         if Len > 0 then 
         begin
            try
               Log('Status Value *','$'+IntToHex(Integer(Data[Len]),2));
            except
               Log('Exception in Log(Status Value *','');
            end;
            try
               Val:=Integer(Data[Len]);
               Log('Status Value','$'+IntToHex(Val,2));
            except
               Log('Exception in Val:=Integer(Data[Len])','');
            end;
            if PrnType = ptTanzania then
               SlipIn:=(Val and $60) = $60
            else
               SlipIn:=(Val and StatusMask) = StatusTest;
   //            SlipIn:=(Val and $60) = 0;
            try
               if SlipIn then
               begin
                  Result:=psSlipInserted;
                  Log('Slip in','');
               end
               else
               begin
                  Result:=psSlipRemoved;
                  Log('Slip Out','');
               end;
            except
               Log('Exception in Slip Out','');
            end;
         end;
      end;   
   except
      Log('Exception in GetPrinterStatus','');
      Result:=psNoPrinter;
   end;   
end;
procedure ProcessMessages;
var
  Msg: TMsg;
begin
  while PeekMessage(Msg,0,0,0,PM_REMOVE) do
  begin
    if Msg.Message <> WM_QUIT then
    begin
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end
    else
      Exit;
  end;
end;
function TReceiptDevice.WaitFor(Status:TPrintStat):Boolean;
var
   PrStat:TPrintStat;
   RetryCount:Integer;
   EndorseWaiting:integer;
begin
   if GetGPCSRegString('DeviceSetup\Receipt','Check Status','1') = '0' then
   begin
      Result:=True;
      Exit;
   end;

   EndorseWaiting  := StrToIntDef( GetGPCSRegString('DeviceSetup\Receipt','Endorse Waiting','60'), 0 );

   Result:=False;
   RetryCount:=0;
   repeat
      PrStat:=GetPrinterStatus;
      if (PrStat <> Status) then ProcessMessages;
      if PrStat = psNoPrinter then
         Inc(RetryCount,20) // try three times when No printer reported
      else                  // i.e. for 1.5 Seconds
         Inc(RetryCount);
      Sleep(500);
   until  (PrStat = Status) or (RetryCount > EndorseWaiting); // Try for 30 Seconds

   if PrStat = Status then Result:=True;
end;
function TReceiptDevice.ReMapChars(Text:String):String;
const
   MapList:TPackStringList = nil;
var
   J,I:Integer;
   Found:Boolean;
begin
   Result:=Text;
   if GetGPCSRegString('DeviceSetup\Receipt','RemapChars','No') <> 'Yes' then Exit;
   if FUseGraphics then Exit;
   if MapList = nil then
   begin
      MapList:=TPackStringList.Create;
      if FileExists('C:\CharMap.txt') then
      begin
         MapList.LoadFromFile('C:\CharMap.txt');
      end
      else
      begin
          Maplist.Add(#163#156);
          Maplist.Add(#162#155);          
//       Hungary
//         MapList.Add('öo'); MapList.Add('üu'); MapList.Add('ée');
//         MapList.Add('áa'); MapList.Add('õo'); MapList.Add('óo');
//         MapList.Add('ûu'); MapList.Add('úu'); MapList.Add('ÜU');
//         MapList.Add('ÁA'); MapList.Add('íi'); MapList.Add('ÉE');
//         MapList.Add('ÖO');
      end;
   end;
   Result:=Text;
   if Text = '' then Exit;
   SetLength(Result,Length(Text));
   for I:=1 to Length(Text) do
   begin
      if (Text[I] in ['A'..'Z','a'..'z','0'..'9',',','.','-','\','/','<','>',';','[',']','!',' ','?',':','^','(',')','_','"',#13,#10]) then
      begin
         Result[I]:=Text[I]
      end
      else
      begin
         Found:=False;
         for J:=0 to MapList.Count-1 do
         begin
            if MapList[J][1] = Text[I] then
            begin
               Found:=True;
               Result[I]:=MapList[J][2];
               break;
            end;
         end;
         if not Found then
         begin
            Result[I]:=Text[I];
            MapList.Add(Text[I]+Text[I]);
         end;
      end;                
   end;
end;
procedure TReceiptDevice.SetEventSink(const EventSink: IDeviceEventSink);
begin
   FDeviceEventSink:=EventSink;
end;
function TReceiptDevice.GetDeviceEntry(Name:String):String;
var
   Registry:TRegistry;
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
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
         FUseGraphics:=ReadString('UseGraphics') = 'Y';
//         FLogoFile:='C:\Tan\LogoBW.bmp';
      end                       
      else
      begin
         Result:='1,9600,8,N,1,500,500';
         FLogoFile:='C:\Tan\LogoBW.bmp';
         FUseGraphics:=False;
      end;
      CloseKey;
      Free;
   end;
   Sl.Free;
end;
procedure TDLThread.Execute;
var
   X,Y,I,W,H:Integer;
   OutB:Char;
   Shift:Char;
   S:String;
   Bitmap:TBitMap;
begin               
   Bitmap:=nil;
   try
      if FLogoFile <> '' then
      begin
         try
            Bitmap:=TBitMap.Create;
            Bitmap.LoadFromFile(FLogoFile);
            W:=Bitmap.Width;
            H:=((Bitmap.Height+7) div 8);
            FSerialDevice.WriteDevice(dcRawData,#$1B#$40,2); // Reset Printer & Clear Data Buffer (NT Junk)
            FSerialDevice.WriteDevice(dcRawData,#$1D+#$2A+Char(((W+7) div 8))+Char(H),0);
            for X:=0 to W+7 do
            begin
               S:='';
               for Y:=0 to H-1 do
               begin
                  OutB:=#0;
                  Shift:=#$80;
                  for I:=0 to 7 do
                  begin
                     if  (X < Bitmap.Width)
                     and (Y*8+I < Bitmap.Height)
                     and (Bitmap.Canvas.Pixels[X,Y*8+I] <> $00FFFFFF) then
                     begin
                        OutB:=Char(Integer(OutB) or Integer(Shift));
                     end;
                     Shift:=Char(Integer(Shift) shr 1);
                  end;      
                  S:=S+OutB;
               end;         
               FSerialDevice.WriteDevice(dcRawData,S,0);
            end;
         except
            if Bitmap <> nil then Bitmap.Free;
            // Add Error Handling
            Exit;
         end;
         Bitmap.Free;
      end;
   except
      ; // Add Error Handling
   end;
end;
procedure TReceiptDevice.DownLoadLogo;
begin               
   DLThread:=TDLThread.Create(True);
   DLThread.FLogoFile:=FLogoFile;
   DLThread.FSerialDevice:=FSerialDevice;
   DLThread.Resume;
end;
function TReceiptDevice.TakeOutG(Value:String):String;
var
   I:Integer;
begin
   Result:=Value;
   for I:=1 to Length(Value) do if Value[I] = TheGrammesSymbol then Result[I]:='g';
end;
function TReceiptDevice.FormatReceiptData(Quantity,Description,Value:WideString):WideString;
var
   I:Integer;
   Qty:Integer;
begin
   SetLength(Result,ReceiptWidth);
   if Copy(Trim(Description),1,5) = '_____' then
   begin
      for I:=1 to ReceiptWidth do Result[I]:='_';
      Exit;
   end;
   for I:=1 to ReceiptWidth do Result[I]:=' ';
   Qty:=StrToIntDef(Trim(Quantity),0);
   Value      :=Trim(Value      );
//   if Value = '' then Value :='0.00';
   if TheGrammesSymbol <> #0 then
      Description:=TakeOutG(Description)
   else
      Description:=Trim(Description);     
   if Qty > 1 then
   begin
      Description:=Copy(Description,1,ReceiptWidth-9);
      for I:=1 to Length(Quantity) do Result[I]:=Quantity[I];
      for I:=1 to Length(Description) do Result[I+1+Length(Quantity)]:=Description[I];
   end
   else
   begin
      Description:=Copy(Description,1,ReceiptWidth-5);
      for I:=1 to Length(Description) do Result[I]:=Description[I];
   end;
   for I:=1 to Length(Value) do Result[(ReceiptWidth-Length(Value))+I]:=Value[I];
end;
procedure TReceiptDevice.ReceiptData(Data:String);
var
   Lines:TPackStringList;
begin
   Lines:=TPackStringList.Create;
   Lines.CommaText:=Data;
   if Lines.Count >  0 then FUser        :=Lines[ 0];
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
   if not(Char(FTitle[1]) in ['A'..'Z','a'..'z']) then
   begin
      TheGrammesSymbol:=#0;
      ReceiptWidth:=34+Integer(not HIGHGRAPHICS)*21
   end
   else
   begin
      TheGrammesSymbol:=GrammesSymbol;
      ReceiptWidth:=43;
   end;
   
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
   FLastBarCode:=IntToStr(Trunc(Value));
   Value:=Office;
   Result:=Result+CurrToB43(Value,3); // Office 00000 - 79507
   FLastBarCode:=FLastBarCode+IntToStr(Trunc(Value));
   Value:=Pos;
   Value:=Value+Clerk*100;
   Result:=Result+CurrToB43(Value,3); // Pos 00 to 99 Teller 000 to 794
   FLastBarCode:=FLastBarCode+IntToStr(Trunc(Value));
end;
function CalcFromRBC(var Clerk,Pos,Office:Integer;var DateTime:TDateTime;S:String):String;
var
   Day   :Integer;
   Month :Integer;
   Year  :Integer;
   Hour  :Integer;
   Minute:Integer;
   Second:Integer;
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
   DateTime:=EncodeDate(Year,Month,Day);
   DateTime:=DateTime+EncodeTime(Hour,Minute,Second,0);
   Result:=Result+' '+IntToStr(Office)+' '+IntToStr(Pos)+' '+IntToStr(Clerk);
end;    
procedure TReceiptDevice.PrintGraphicsText(Data:WideString);
var
   X,Y,I:Integer;
   OutB:Byte;
   S:String;
   BMP:TBitMap;
begin               
   BMP:=TBitMap.Create;
   BMP.Width:=1;
   BMP.Height:=1;
   BMP.Canvas.Font.Name:='Courier New';
   BMP.Canvas.Font.Charset:=ARABIC_CHARSET;
   BMP.Canvas.Font.Style:=[fsBold];
   with BMP do
   begin
      with Canvas do
      begin
         if HIGHGRAPHICS then
         begin
            BMP.Canvas.Font.Height:=24;
            BMP.Width:=BMP.Canvas.TextWidth(Data);
            Height:=24;
            SetTextAlign(BMP.Canvas.Handle,TA_RTLREADING or TA_RIGHT);
            TextOut(BMP.Width,0,Data);
            FSerialDevice.WriteDevice(dcBinData,#$1B+#$2A+#$21+Char(BMP.Width mod 256)+Char(BMP.Width div 256),5); // Double Density
   //         FSerialDevice.WriteDevice(dcBinData,#$1B+#$2A+#$20+Char(Width mod 256)+Char(Width div 256),5); // Single Density
            S:='';
            for X:=0 to BMP.Width-1 do
            begin
               for Y:=0 to 2 do
               begin
                  OutB:=0;
                  for I:=0 to 7 do
                     if BMP.Canvas.Pixels[X,Y*8+I] = clblack then
                        OutB:=OutB or ($80 shr I);
                  S:=S+Char(OutB);
               end;         
               if Length(S) >= 60 then
               begin
                  FSerialDevice.WriteDevice(dcRawData,S,0);
                  S:='';
               end;
            end;                 
            FSerialDevice.WriteDevice(dcRawData,S+#13#10,0);
         end
         else
         begin
            BMP.Canvas.Font.Height:=8;
            Width:=TextWidth(Data);
            Height:=8;
            SetTextAlign(BMP.Canvas.Handle,TA_RTLREADING or TA_RIGHT);
            TextOut(Width,0,Data);
   //         FSerialDevice.WriteDevice(dcBinData,#$1B+#$2A+#$1+Char(Width mod 256)+Char(Width div 256),5); // Double Density
            FSerialDevice.WriteDevice(dcBinData,#$1B+#$2A+#$0+Char(Width mod 256)+Char(Width div 256),5); // Single Density
            S:='';
            for X:=0 to Width-1 do
            begin
               OutB:=0;
               for I:=0 to 7 do
                  if BMP.Canvas.Pixels[X,I] = clblack then
                     OutB:=OutB or ($80 shr I);
               S:=S+Char(OutB);
               if Length(S) >= 60 then
               begin
                  FSerialDevice.WriteDevice(dcRawData,S,0);
                  S:='';
               end;
            end;                 
            FSerialDevice.WriteDevice(dcRawData,S+#13#10,0);
         end;
      end;                                             
   end;    
   BMP.Free;
end;
procedure TReceiptDevice.PrintText(Data:String);
begin
   if FUseGraphics and (Data <> '') and (not(Char(FTitle[1]) in ['A'..'Z','a'..'z'])) then
   begin
      PrintGraphicsText(Data)
   end
   else
      FSerialDevice.WriteDevice(dcRawData,Data+#13,0);
end;
procedure TReceiptDevice.PrintDate;
var
   SystemTime:TSystemTime;
   Buffer:array[0..200] of Char;
begin
   if not(Char(FTitle[1]) in ['A'..'Z','a'..'z']) then
   begin
      DateTimeToSystemTime(Now,SystemTime);
      GetDateFormat(GetThreadLocale,DATE_LONGDATE,@SystemTime,nil,Buffer,SizeOf(Buffer));
      PrintText(Buffer+' '+FormatDateTime('hh:nn',Now));
   end
   else
   begin
      PrintText(FormatDateTime('dd mmmm yyyy, hh:nn',Now));
   end;
end;
procedure TReceiptDevice.PrintCA(Data:String);
var
   Lines:TPackStringList;
   Cols:TPackStringList;
   I,CurLine:Integer;
   S,Str:String;
begin
   Lines:=TPackStringList.Create;
   Cols:=TPackStringList.Create;
   Lines.CommaText:=Data;
   SetLength(Str,ReceiptWidth);
   for I:=1 to ReceiptWidth do Str[I]:=' ';
   PrintLogo;
//   PrintText('Daily Balance Sheet');
   CurLine:=0;
   while CurLine < Lines.Count do
   begin
      Cols.CommaText:=Lines[CurLine];
      S:=Copy(Cols[0],1,Length(Str)-8);
      for I:=1 to Length(S) do Str[I]:=S[I];
      S:=Cols[1];
      for I:=1 to Length(S) do Str[(Length(Str)-Length(S))+I]:=S[I];
      Str[(Length(Str)-Length(S))]:=' ';
      PrintText(Str);
      SetLength(Str,ReceiptWidth);
      for I:=1 to ReceiptWidth do Str[I]:=' ';
      Inc(CurLine);
      Sleep(20);
   end; 
   Cols.Free;
   Lines.Free;
   FSerialDevice.WriteDevice(dcRawData,#13,0);
   PrintText(FUser+' '+IntToStr(FWorkstation)+' '+IntToStr(FOffice)+' ');
   PrintDate;
   FSerialDevice.WriteDevice(dcRawData,#13+#13+#13+#13+#13#13#$1A,0);  // Space before Cut - Partial Cut
end;
procedure TReceiptDevice.PrintReport(Data:String;Columns:Integer);
var
   Lines:TPackStringList;
   Cols:TPackStringList;
   LineCount,I,CurLine:Integer;
   S,Str:String;
   
begin
   Lines:=TPackStringList.Create;
   Cols:=TPackStringList.Create;
   Lines.CommaText:=Data;
   LineCount:=0;
   Str:='                                          ';
   PrintLogo;
   FSerialDevice.WriteDevice(dcRawData,#13,0);
   CurLine:=0;
   while LineCount < Lines.Count do
   begin
      Cols.CommaText:=Lines[LineCount];
      S:=Cols[0];
      for I:=1 to Length(S) do Str[I]:=S[I];
      S:=Cols[1];
      case CurLine of
         2 : FOffice     :=StrToIntDef(S,0);
//         3 : FUser       :=StrToIntDef(S,0);
         4 : FWorkstation:=StrToIntDef(S,0);
      end;
      for I:=1 to Length(S) do Str[(Length(Str)-Length(S))+I]:=S[I];
      Inc(LineCount);
      PrintText(Str);
      Str:='                                          ';
      Inc(CurLine);
      Sleep(20);
   end; 
   Cols.Free;
   Lines.Free;
   FSerialDevice.WriteDevice(dcRawData,#13,0);
   PrintText(FUser+' '+IntToStr(FWorkstation)+' '+IntToStr(FOffice));
   FSerialDevice.WriteDevice(dcRawData,#$1D+#$68+#80+#$1D+#$77+#2,0);   // BarCode Height / Width
   FSerialDevice.WriteDevice(dcRawData,#$1D+#$6B+#4+'.'+CalcRBC(1,FWorkstation,FOffice)+#0+#0,0); // BarCode
   PrintDate;
   FSerialDevice.WriteDevice(dcRawData,#13+#13+#13+#13+#13#13#$1A,0);  // Space before Cut - Partial Cut
end;
procedure TReceiptDevice.PrintReceiptHead;
begin
   PrintLogo;
   FSerialDevice.WriteDevice(dcRawData,#13,0);
   PrintText(FTitle);                  
   PrintText(FOfficeData1);
   PrintText(FOfficeData2);
   PrintExHeader;
   FSerialDevice.WriteDevice(dcRawData,#$1B+#$61+#0+#13+#13+#13,0);
end;
procedure TReceiptDevice.PrintReceiptFoot;
begin
  FSerialDevice.WriteDevice(dcRawData,#13+#13+#$1B+#$61+#1,0);
  PrintExFooter;
  PrintText(FThankYou);
  FSerialDevice.WriteDevice(dcRawData,#13+#$1D+#$68+#80+#$1D+#$77+#2,0);   // BarCode Height / Width
  FSerialDevice.WriteDevice(dcRawData,#$1D+#$6B+#5+'0'+FIdent+#0+#0,0); // BarCode
  if GetGPCSRegString('DeviceSetup\Receipt','PrintUniqueNumber','N') = 'Y' then
     PrintText(FIdent);
  PrintText(FUser+'  '+IntToStr(FWorkstation));
  PrintDate;
  FSerialDevice.WriteDevice(dcRawData,#13+#13+#13+#13+#13#13#$1A,0);  // Space before Cut - Partial Cut
end;
procedure TReceiptDevice.PrintReceiptLine(Data:WideString);
var
   Items:TPackStringList;
begin
   Items:=TPackStringList.Create;
   Items.CommaText:=Data;
//   ShowMessage('['+Items[0]+']['+Items[1]+']['+Items[2]+']');
   PrintText(FormatReceiptData(Items[0],Items[1],Items[2]));
   Items.Free;
end;
procedure TReceiptDevice.PrintReceipt(Data:WideString);
var
   Lines:TPackStringList;
   LineCount:Integer;
begin
   PrintReceiptHead;
   
   Lines:=TPackStringList.Create;
   Lines.CommaText:=Data;
   for LineCount:=0 to Lines.Count-1 do
   begin
      PrintReceiptLine(Lines[LineCount]);
      if (LineCount mod 50) = 49 then
         Sleep(2000);
   end;
   Lines.Free;
   
   PrintReceiptFoot;
end;
function GetBarOffset(Ident:Char):Integer;
var
   I:Integer;
begin
   Result:=1;
   for I:=1 to Length(BarMap) do
   begin
      if BarMap[I] = Ident then
      begin
         Result:=I;
         Exit;
      end;
   end;
end;
function BarData(Ident:String):String;
var
   Count,BarNumb:Integer;
   BarString:String;
begin
   Result:='';  
   for Count:=1 to 120 do Result:=Result+#$0;
   for Count:=1 to Length(Ident) do
   begin
      BarString:=Bars[GetBarOffset(Ident[Count])];
      for BarNumb:=1 to 9 do
      begin
         if BarString[BarNumb] = '1' then // Thick bar
         begin
            if (BarNumb and 1) <> 0 then // Black
               Result:=Result+#$FF#$FF
            else                         // White
               Result:=Result+#0#$0
         end
         else // Thin bar
         begin
            if (BarNumb and 1) <> 0 then
               Result:=Result+#$FF
            else                        // White
               Result:=Result+#0;
         end; 
      end;       
      Result:=Result+#0; // Spacer
   end; 
end;
procedure TReceiptDevice.Stamp(Data:String);
var
   SL:TPackStringList;
   I:Integer;
begin
   SL:=TPackStringList.Create;
   SL.CommaText:=Data;
   FSerialDevice.WriteDevice(dcRawData,#$1C#$18,0); // 1C Select Slip 18 Open Form
   FSerialDevice.WriteDevice(dcRawData,#$1D#$14#$3,0); // Reverse Feed 3 Lines
   for I:=0 to SL.Count-1 do
      FSerialDevice.WriteDevice(dcRawData,SL[I]+#13,Length(SL[I])+1);
   FSerialDevice.WriteDevice(dcRawData,#$0C#$1E,0); // 0C Print & Eject Form 1E Select Receipt
   SL.Free;
end;
procedure TReceiptDevice.EndorseS(Space:Integer;Prompt:String);
var
   S:String;
   I:Integer;
begin
   S:=''; for I:=1 to Space do S:=S+' ';
   S:=S+Prompt+#13;
   FSerialDevice.WriteDevice(dcRawData,S,0);
end;
procedure TReceiptDevice.Endorse(Space:Integer;Prompt:String;Data:Integer);
var
   S:String;
   V:String;
   I:Integer;
begin
   S:=''; for I:=1 to Space do S:=S+' ';
   S:=S+Prompt;
   for I:=Length(S) to Space+13 do S:=S+' ';
   V:=IntToStr(Data);
   for I:=1 to Length(V) do S[((Space+13)-Length(V))+I]:=V[I];
   S:=S+#13;
   FSerialDevice.WriteDevice(dcRawData,S,0);
end;
procedure TReceiptDevice.EndorseDT(Space:Integer);
var
   S:String;
   I:Integer;
begin
   S:=''; for I:=1 to Space do S:=S+' ';
   PrintDate;
   FSerialDevice.WriteDevice(dcRawData,S,0);
end;
procedure TReceiptDevice.PrintSlip(Data:String);
var
   CV:Currency;
   S:String;
   Str:String;
   Len:Integer;
   I:Integer;
begin
   FSerialDevice.WriteDevice(dcRawData,#$1C#$18#$1B#$07,0); // 1C Select Slip 18 Open Form 1B07 Generate Tone
   FSerialDevice.WriteDevice(dcRawData,#$1D#$14#$3,0); // Reverse Feed 3 Lines

   Endorse(36,FWOffice     ,FOffice     );
   Endorse(36,FWZip        ,FZip        );
   Endorse(36,FWValue      ,FValue      );
   Endorse(36,FWFee        ,FFee        );
//   Endorse(36,FWUser       ,FUser       );
   Endorse(36,FWWorkstation,FWorkstation);
   EndorseDT(36);
   FSerialDevice.WriteDevice(dcBinData,#$14#7#13,3);  // Feed 7 Lines + CR

   CV:=StrToCurr(FIdent);
   S:=BarData('*'+CurrToB43(CV,8)+'*');
   Len:=Length(S);

   FSerialDevice.WriteDevice(dcRawData,#$1B#$2A#0#1#0#0#13,7); // print empty line (stops bi-directional print)
   SetLength(Str,Len+6);
   Str:=#$1B#$2A#0+Char(Len mod 256)+Char(Len div 256)+S+#13; // 
   Len:=Length(Str);
   for I:=1 to Len do FSerialDevice.WriteDevice(dcRawData,Str[I],1);
   for I:=1 to Len do FSerialDevice.WriteDevice(dcRawData,Str[I],1);
   for I:=1 to Len do FSerialDevice.WriteDevice(dcRawData,Str[I],1);
   FSerialDevice.WriteDevice(dcRawData,#$14#26,0);
   Endorse(37,FWOffice     ,FOffice     );
   Endorse(37,FWZip        ,FZip        );
   Endorse(37,FWValue      ,FValue      );
   Endorse(37,FWFee        ,FFee        );
//   Endorse(37,FWUser       ,FUser       );
   Endorse(37,FWWorkstation,FWorkstation);
   EndorseDT(37);
   FSerialDevice.WriteDevice(dcRawData,#$0C#$1E,0);                                       
end;
procedure TReceiptDevice.PrintLogo;
begin
   FSerialDevice.WriteDevice(dcRawData,#$1B+#$16+#0+#$1B+#$61+#1+#$1D+#$2F+'0',0); // Print Logo
end;
procedure TReceiptDevice.PrintTrackingReceipt(Data:String);
var
   SL:TPackStringList;
   Tracking:String;
   Desc  :String;
   Dest  :String;
   Ident :String;
   Price :String;
   TFee  :String;
begin
   SL:=TPackStringList.Create;
   SL.CommaText:=Data;
   if SL.Count > 4 then
   begin
      Tracking:=SL[0];
      Desc :=SL[1];
      Price:=SL[2];
      Dest :=SL[3];
      Ident:=SL[4];
      TFee :=SL[5];
      PrintLogo;
      PrintText(FTitle);                  
      PrintText(FOfficeData1);
      PrintText(FOfficeData2);
      PrintText(Tracking);
      FSerialDevice.WriteDevice(dcRawData,#13,0);
      PrintText(Desc);
      PrintText(Dest);
      PrintText(Price);
      PrintText(FWFee+' '+TFee);
      FSerialDevice.WriteDevice(dcRawData,#13+#$1B+#$61+#1,0);
      FSerialDevice.WriteDevice(dcRawData,#$1D+#$68+#80+#$1D+#$77+#2,0);   // BarCode Height / Width
      FSerialDevice.WriteDevice(dcRawData,#$1D+#$6B+#4+Ident+#0+#0,0); // BarCode
      PrintText(Ident);
      PrintDate;
      FSerialDevice.WriteDevice(dcRawData,#13+#13+#13+#13+#13#13#$1A,0);  // Space before Cut - Partial Cut
   end;
   SL.Free;
end;
function TReceiptDevice.WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool;
begin
   Result:=False;
   case CommandType of
      dcInitialise : begin
                        FTitle:='ABC';
                        FSerialDevice:=CreateSerialDevice;
                        if FSerialDevice <> nil then
                        begin
                           FSerialDevice.SetEventSink(Self);
                           FSerialDevice.WriteDevice(dcInitialise,GetDeviceEntry('Receipt'),0);
                           if Len = 0 then DownLoadLogo;
                           Result:=True;
                        end;                                                              
                      end;
      dcRawData    : begin
                        Result:=FSerialDevice.WriteDevice(dcRawData,Data,0);
                     end;
      dcShutdown   : begin
                        if DLThread <> nil then
                           DLThread.Free;
                        DLThread:=nil;
                        FSerialDevice:=nil;
                        FDeviceEventSink:=nil;
                        Result:=True;
                     end;
      dcLine1Data  : begin 
                       PrintReceiptHead;
//                       PrintLogo;
                       Result:=True;
                     end;
      dcLine2Data  : begin
                       PrintTrackingReceipt(Data);
                       Result:=True;
                     end;
      dcLine3Data  : begin
                        Stamp(ReMapChars(Data));
                     end;
      dcLine4Data  : if FSerialDevice <> nil then
                     begin
                        if Data = 'SlipInserted' then
                           Result:=WaitFor(psSlipInserted)
                        else
                           Result:=WaitFor(psSlipRemoved);
                     end;
      dcLine5Data  : begin
                        PrintReceiptLine(RemapChars(Data));
                        Result:=True;
                     end;
      dcList1Data  : begin
                       PrintReceipt(ReMapChars(Data));
                       Result:=True;
                     end;
      dcList2Data  : begin
                       ReceiptData(ReMapChars(Data));
                       Result:=True;
                     end;
      dcList3Data  : begin
                       PrintSlip(ReMapChars(Data));
                       Result:=True;
                     end;
      dcList4Data  : begin
                       PrintReport(ReMapChars(Data),2);
                       Result:=True;
                     end;
      dcList5Data  : begin
                       PrintCA(ReMapChars(Data));
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
   if (Len = 100) and (FSerialDevice <> nil) then
   begin
      Result:=FSerialDevice.ReadDevice(Data,Len);
   end
   else
   begin
      Data:=CalcFromRBC(Clerk,Pos,Office,DateTime,Data);
      Result:=True;
   end;
end;
function TReceiptDevice.GetStatus: WideString;
begin
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
procedure TReceiptDevice.PrintExHeader;
var
  SL:TPackStringList;
  i : integer;
begin
  try
    with TRegistry.Create do
    begin
      RootKey:=HKEY_LOCAL_MACHINE;
      if OpenKey('Software\PSL\GPCS\DeviceSetup\Receipt\Header',False) then
      begin
        SL:=TPackStringList.Create;
        GetValueNames(SL);
        if (SL.Count > 0) then
        begin
          for i := 0 to SL.Count-1 do
            if (SL.Strings[i] <> '') then
              PrintText(ReadString(SL.Strings[i]));
        end;
        CloseKey;
        SL.Free;
      end;
      Free;
    end;
  except
   // Log Error
  end;
end;
procedure TReceiptDevice.PrintExFooter;
var
  SL:TPackStringList;
  i : integer;
begin
  try
    with TRegistry.Create do
    begin
      RootKey:=HKEY_LOCAL_MACHINE;
      if OpenKey('Software\PSL\GPCS\DeviceSetup\Receipt\Footer',False) then
      begin
        SL:=TPackStringList.Create;
        GetValueNames(SL);
        if (SL.Count > 0) then
        begin
          for i := 0 to SL.Count-1 do
            //if (Copy(Uppercase(SL.Strings[i]),1,4) = 'LINE') then
            if (SL.Strings[i] <> '') then
              PrintText(ReadString(SL.Strings[i]));
        end;
        CloseKey;
        SL.Free;
      end;
      Free;
    end;
  except
   // Log Error
  end;
end;
initialization
  TGPCSCompFactory.Create(ComServer,TReceiptDevice,Class_ReceiptDevice,
                          'Device.Receipt','GPCS Custustomer Display Device',
                          ciMultiInstance);
end.