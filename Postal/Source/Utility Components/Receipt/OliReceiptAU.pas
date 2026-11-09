unit OliReceiptAU;

interface

uses
  Windows,Forms,Messages,Graphics,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Registry,Code128BU;
  
const
   ReceiptWidth  = 38;
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
  TPrintStat = (psNoPrinter,psSlipInserted,psSlipRemoved);
  TReceiptDevice = class(TGPCSDevice,IDevice,IDeviceEventSink)
  private
    FLastBarCode : String;
//    FHeader      : String;
    FTitle       : String;
    FOfficeData1 : String;
    FOfficeData2 : String;
    FThankYou    : String;
    FTotal       : String;
    FLogoFile    : String;
    FUser        : String;
    FOffice      : String;
    FValue       : String;
    FFee         : String;
    FZip         : String;
    FWorkstation : String;
    FIdent        : String;
    FWUser        : String;
    FWOffice      : String;
    FWValue       : String;
    FWFee         : String;
    FWZip         : String;
    FWWorkstation : String;
    ABitMap:TBitMap;
    FDeviceEventSink:IDeviceEventSink;
    FSerialDevice:IDevice;
    procedure WaitFor;
  protected
    procedure Endorse(Space:Integer;Prompt:String;Data:Integer);
    procedure EndorseS(Space:Integer;Prompt:String);
    procedure Stamp(Data:String);
    procedure EndorseDT(Space:Integer);
    function  FormatReceiptData(Quantity,Description,Value:String):String;
    procedure PrintReport(Data:String;Columns:Integer);
    procedure PrintCA(Data:String);
    procedure PrintReceipt(Data:String);
    procedure PrintSlip(Data:String);
    procedure ReceiptData(Data:String);
    procedure PrintLogo;
    function  GetDeviceEntry(Name:String):String;
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

  function Code128Data(Value:String;WithHeader:Boolean):String;
  
implementation
uses
   ComServ2;
   
function ZeroPad(Val:Integer):String;
begin
   if Val >=100 then Result:=IntToStr(Val)
   else if Val >=10 then Result:='0'+IntToStr(Val)
   else Result:='00'+IntToStr(Val);
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
function GetStat(Device:IDevice):Integer;
var
   Len:Integer;
   S:WideString;
   Stat:Boolean;
   I:Integer;
begin 
   Result:=0;
   if Device <> nil then  
   begin
      if not Device.WriteDevice(dcRawData,#$1B+#$6A,2) then
         Exit;
      Len:=3;
      SetLength(S,Len);
      for I:=0 to 20 do
      begin
         Stat:=Device.ReadDevice(S,Len);
         if (not Stat) or (Len <> 3) then
         begin
            ProcessMessages;
         end
         else
            Break;
      end;
      if (not Stat) or (Len <> 3) then Exit;
      Result:=Integer(S[3]);
   end;  
end;
procedure TReceiptDevice.WaitFor;
var
   S,T,Len:Integer;
   WS:WideString;
begin
   T:=0;
   FSerialDevice.WriteDevice(dcRawData,#$1B+'S5',3);
   while True do                
   begin
      S:=GetStat(FSerialDevice);
      if S = 0 then Inc(T) else T:=0;
      if ((S and $10) = $10) or (T = 10) then Break;
      ProcessMessages;
   end;
   Len:=1000;
   SetLength(WS,1000);
   while FSerialDevice.ReadDevice(WS,Len) do
   begin
      Len:=1000;
      SetLength(WS,1000);
   end;
end;                                      
function ReMapChars(Text:String):String;
const
   MapList:TStringList = nil;
var
   J,I:Integer;
   Found:Boolean;
begin
   if MapList = nil then
   begin
      MapList:=TStringList.Create;
      try
         MapList.LoadFromFile('C:\CharMap.txt');
      except
         MapList.Add('öo'); MapList.Add('üu'); MapList.Add('ée');
         MapList.Add('áa'); MapList.Add('õo'); MapList.Add('óo');
         MapList.Add('ûu'); MapList.Add('úu'); MapList.Add('ÜU');
         MapList.Add('ÁA'); MapList.Add('íi'); MapList.Add('ÉE');
         MapList.Add('ÖO');
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
         FLogoFile:='C:\Tan\LogoBW.bmp';
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
   Description:=Trim(Description); if Length(Description) > (ReceiptWidth-3) then Description:=Copy(Description,1,(ReceiptWidth-3));if Length(Description) > (ReceiptWidth-4) then Description:=Copy(Description,1,(ReceiptWidth-4));
   Value      :=Trim(Value      );
   while Length(Quantity) < 1 do Quantity:=' '+Quantity;
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
   if Lines.Count >  0 then FUser        :=Lines[ 0];
   if Lines.Count >  1 then FOffice      :=Lines[ 1];
   if Lines.Count >  2 then FValue       :=Lines[ 2];
   if Lines.Count >  3 then FFee         :=Lines[ 3];
   if Lines.Count >  4 then FZip         :=Lines[ 4];
   if Lines.Count >  5 then FWorkstation :=Lines[ 5];
   if Lines.Count >  6 then FIdent       :=Lines[ 6];
   if Lines.Count >  7 then FWUser       :=Lines[ 7];
   if Lines.Count >  8 then FWOffice     :=Lines[ 8];
   if Lines.Count >  9 then FWValue      :=Lines[ 9];
   if Lines.Count > 10 then FWFee        :=Lines[10];
   if Lines.Count > 11 then FWZip        :=Lines[11];
   if Lines.Count > 12 then FWWorkstation:=Lines[12];
   if Lines.Count > 13 then FTitle       :=Lines[13];
   if Lines.Count > 14 then FOfficeData1 :=Lines[14];
   if Lines.Count > 15 then FOfficeData2 :=Lines[15];
   if Lines.Count > 16 then FThankYou    :=Lines[16];
   if Lines.Count > 17 then FTotal       :=Lines[17];
   Lines.Free;
end;
procedure TReceiptDevice.PrintCA(Data:String);
var
   Lines:TStringList;
   Cols:TStringList;
   I,CurLine:Integer;
   S,Str:String;
begin
   Lines:=TStringList.Create;
   Cols:=TStringList.Create;
   Lines.CommaText:=Data;
   Str:='                                      ';
   PrintLogo;
//   FSerialDevice.WriteDevice(dcRawData,'Daily Balance Sheet'#13,0);
   CurLine:=0;
   while CurLine < Lines.Count do
   begin
      Cols.CommaText:=Lines[CurLine];
      S:=Copy(Cols[0],1,Length(Str)-8);
      for I:=1 to Length(S) do Str[I]:=S[I];
      S:=Cols[1];
      for I:=1 to Length(S) do Str[(Length(Str)-Length(S))+I]:=S[I];
      Str[(Length(Str)-Length(S))]:=' ';
      FSerialDevice.WriteDevice(dcRawData,Str+#13#10,0);
      Str:='                                      ';
      Inc(CurLine);
   end; 
   Cols.Free;
   Lines.Free;
   FSerialDevice.WriteDevice(dcRawData,#13#10,0);
   FSerialDevice.WriteDevice(dcRawData,FUser+' '+FWorkstation+' '+FOffice+' '+#13#10,0); // BarCode
   FSerialDevice.WriteDevice(dcRawData,FormatDateTime('DD/MM/YYYY HH:NN:SS',Now)+#13#10,0); // Date Time
   FSerialDevice.WriteDevice(dcRawData,#13#10#13#10#13#10#13#10#13#10#13#10#13#10#13#10#13#10#$1B+'m',0);
end;
procedure TReceiptDevice.PrintReport(Data:String;Columns:Integer);
var
   Lines:TStringList;
   Cols:TStringList;
   LineCount,I,CurLine,K:Integer;
   S,Id,Str:String;
begin
   Lines:=TStringList.Create;
   Cols:=TStringList.Create;
   Lines.CommaText:=Data;
   LineCount:=1;
   Str:='                                     ';
   PrintLogo;
   Lines.SaveToFile('C:\Report.txt');
   FSerialDevice.WriteDevice(dcRawData,#13,0);
   CurLine:=0;
   Cols.CommaText:=Lines[0];
   Id:=Cols[0];
   while LineCount < Lines.Count do
   begin
      Cols.CommaText:=Lines[LineCount];
      S:=Cols[0];
      for I:=1 to Length(S) do Str[I]:=S[I];
      S:=Cols[1];
      case CurLine of
         2 : FOffice       :=S;
//         3 : FUser       :=S);
         4 : FWorkstation:=S;
      end;
      for I:=1 to Length(S) do Str[(Length(Str)-Length(S))+I]:=S[I];
      Inc(LineCount);
      FSerialDevice.WriteDevice(dcRawData,Str+#13#10,0);
      Str:='                                     ';
      Inc(CurLine);
   end; 
   Cols.Free;
   Lines.Free;
   FSerialDevice.WriteDevice(dcRawData,#13#10,0);
   FSerialDevice.WriteDevice(dcRawData,FUser+' '+FWorkstation+' '+FOffice+' '+#13#10,0); // BarCode
//   FSerialDevice.WriteDevice(dcRawData,CalcRBC(FUser,FWorkstation,FOffice)+#13,0); // BarCode Data
//   FSerialDevice.WriteDevice(dcRawData,#$1D+#$6B+#4+'.'+CalcRBC(1,FWorkstation,FOffice)+#0+#0,0); // BarCode
   FSerialDevice.WriteDevice(dcRawData,FormatDateTime('DD/MM/YYYY HH:NN:SS',Now)+#13#10,0); // Date Time
   S:=Code128Data(Id,False);
   FSerialDevice.WriteDevice(dcRawData,#$1B#$26+'07',4); 
   for K:=0 to 2 do                         
   begin
      FSerialDevice.WriteDevice(dcRawData,#$1B#$25#$41+ZeroPad(50+Length(S)),6);
      for I:=1 to 50 do FSerialDevice.WriteDevice(dcRawData,#0,1);
      for I:=1 to Length(S) do FSerialDevice.WriteDevice(dcRawData,S[I],1);
//    Device.WriteDevice(dcRawData,S,Length(S));
      FSerialDevice.WriteDevice(dcRawData,#13#10,2);
   end;
   FSerialDevice.WriteDevice(dcRawData,#$1B#$26+'00',4); 
   FSerialDevice.WriteDevice(dcRawData,#13#10#13#10#13#10#13#10#13#10#13#10#13#10#13#10#13#10#$1B+'m',0);
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
   PrintLogo;
   FSerialDevice.WriteDevice(dcRawData,#13#10+FTitle+#13#10+FOfficeData1+#13#10+FOfficeData2+#13#10+#13#10+#13+#10,0);
//   Exit;
   for LineCount:=0 to Lines.Count-1 do
   begin
      Items.CommaText:=Lines[LineCount];
      FSerialDevice.WriteDevice(dcRawData,FormatReceiptData(Items[0],Items[1],Items[2])+#13#10,0);
   end;
   Lines.Free;
   Items.Free;
   FSerialDevice.WriteDevice(dcRawData,#13#10+#13#10+FThankYou+#13#10+#13#10,0);
   FSerialDevice.WriteDevice(dcRawData,'Teller '+FUser+'  Position '+FWorkstation+#13#10,0); // Date Time
   FSerialDevice.WriteDevice(dcRawData,FormatDateTime('DD/MM/YYYY HH:NN:SS',Now)+#13#10,0); // Date Time
   FSerialDevice.WriteDevice(dcRawData,#13#10#13#10#13#10#13#10#13#10#13#10#13#10#13#10#13#10#$1B+'m',0);
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
   SL:TStringList;
   I:Integer;
begin
   SL:=TStringList.Create;
   SL.CommaText:=Data;
   for I:=0 to SL.Count-1 do
      FSerialDevice.WriteDevice(dcRawData,SL[I]+#13+#10,Length(SL[I])+2);
   FSerialDevice.WriteDevice(dcRawData,#$1B#$4F,2); // Eject
   FSerialDevice.WriteDevice(dcRawData,#$1B+'S1',3); //Select Receipt
end;
procedure TReceiptDevice.EndorseS(Space:Integer;Prompt:String);
var
   S:String;
   I:Integer;
begin
   S:=''; for I:=1 to Space do S:=S+' ';
   S:=S+Prompt+#13+#10;
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
   S:=S+#13#10;
   FSerialDevice.WriteDevice(dcRawData,S,0);
end;
procedure TReceiptDevice.EndorseDT(Space:Integer);
var
   S:String;
   I:Integer;
begin
   S:=''; for I:=1 to Space do S:=S+' ';
   S:=S+FormatDateTime('DD/MM/YY HHNN',Now)+#13#10;
   FSerialDevice.WriteDevice(dcRawData,S,0);
end;
function Calc128CRC(Value:String):Char;
var
   I:Integer;
   CheckSum:Integer;
begin                                            
   CheckSum:=103;
   for I:=2 to Length(Value) do
      CheckSum:=CheckSum+((I-1)*Integer(Value[I]));
   Result:=Char(CheckSum mod 103);
end;
function BuildBC(Value:String;WithHeader:Boolean):String;
var
   I:Integer;
   S:String;
//   CS:Integer;
begin
   if WithHeader then
      S:=#103#52#41  // Start A + 'TI' + Code C +
   else
      S:=#103;  // Start C
       
   if (Length(Value) and 1) = 1 then // odd number of chars
   begin
      S:=S+Char(Integer(Value[1])-32)+#99;
      for I:=0 to (Length(Value)-2) div 2 do
         S:=S+Char(StrToInt(Copy(Value,I*2+2,2))); // + 2 digit code
   end
   else
   begin
      S:=S+#99;
      for I:=0 to (Length(Value)-1) div 2 do
         S:=S+Char(StrToInt(Copy(Value,I*2+1,2))); // + 2 digit code
   end;
   if WithHeader then
      S:=S+#101#40#53 // + Code A + 'HU'
   else
      S:=S; // + Code A + 'HU'
   Result:=S+Calc128CRC(S)+#106; // + CRC + Stop
end;
function Code128Data(Value:String;WithHeader:Boolean):String;
var
   S:String;
   BS:String;
   I,J:Integer;
   Toggle:Boolean;
begin
   Result:='';
   S:=BuildBC(Value,WithHeader);
   BS:='';
   for I:=1 to Length(S) do
   begin
      BS:=BS+BCData[Integer(S[I])][3];
   end;
      
   Toggle:=True;
   for I:=1 to Length(BS) do
   begin
      for J:=1 to (Integer(BS[I])-48) do
      begin
         if Toggle then
            Result:=Result+#$FF
         else
            Result:=Result+#0;
      end;
      Toggle:=not Toggle;
   end;
end;                  
procedure PrintLabel(Device:IDevice;Office,Weight,Destination,Fee,Id:String);
var
   S:String;
   K,I:Integer;
   DT:String;
begin       
   for I:=0 to 10000 do Application.ProcessMessages;
   Office     :=Trim(Office     );
   Weight     :=Trim(Weight     );
   Destination:=Trim(Destination);
   Fee        :=Trim(Fee        );
   Id         :=Trim(Id         );  
     
   While Length(Office     ) < 4 do Office     :='0'+Office     ;
   While Length(Weight     ) < 5 do Weight     :=' '+Weight     ;
   While Length(Destination) < 4 do Destination:='0'+Destination;
   While Length(Fee        ) < 6 do Fee        :=' '+Fee        ;
   
   Device.WriteDevice(dcRawData,#13#10#13#10#13#10#13#10#13#10#$1B#$26+'04'+#13#10#$1B#$26+'08',0);
   S:=Code128Data(Id,True);
   for K:=0 to 2 do     
   begin
      Device.WriteDevice(dcRawData,#$1B#$25#$41+ZeroPad(Length(S)+212),6);
      for I:=1 to 106 do
         Device.WriteDevice(dcRawData,#0#0,2);
      for I:=1 to Length(S) do
         Device.WriteDevice(dcRawData,S[I],1);
//      Device.WriteDevice(dcRawData,S,Length(S));
      Device.WriteDevice(dcRawData,#13#10,2);
      for I:=0 to 10000 do Application.ProcessMessages;
   end;
   for I:=0 to 10000 do Application.ProcessMessages;
   Device.WriteDevice(dcRawData,#$1B#$26+'04',4);
   for I:=0 to 10000 do Application.ProcessMessages;
   Device.WriteDevice(dcRawData,#13#10+'                                                      TI'+Id+'HU'+#13#10,0);
   for I:=0 to 10000 do Application.ProcessMessages;
   Device.WriteDevice(dcRawData,#$1B#$26+'27'+#13#10#$1B#$26+'18',0);
   for I:=0 to 10000 do Application.ProcessMessages;
   Device.WriteDevice(dcRawData,'                                                                          '+Office+#13#10,0);
   for I:=0 to 10000 do Application.ProcessMessages;
   Device.WriteDevice(dcRawData,'                                                                         '+Weight+#13#10,0);
   for I:=0 to 10000 do Application.ProcessMessages;
   Device.WriteDevice(dcRawData,'                                                                          '+Destination+#13#10,0);
   for I:=0 to 10000 do Application.ProcessMessages;
   Device.WriteDevice(dcRawData,#$1B#$26+'22',4);
   for I:=0 to 10000 do Application.ProcessMessages;
   DT:=FormatDateTime('YYYY.MM.DD HH:NN',Now);
   for I:=0 to 10000 do Application.ProcessMessages;
   Device.WriteDevice(dcRawData,'                                            '+DT+'            '+Fee+#13#10,0);
   for I:=0 to 10000 do Application.ProcessMessages;
   Device.WriteDevice(dcRawData,#$1B#$26+'15',4);
   for I:=0 to 10000 do Application.ProcessMessages;
   Device.WriteDevice(dcRawData,'                                                    TI'+Id+'HU    '+Weight+#13#10,0);
   for I:=0 to 10000 do Application.ProcessMessages;
   Device.WriteDevice(dcRawData,'                                                                         '+Fee+#13#10,0);
   for I:=0 to 10000 do Application.ProcessMessages;
   Device.WriteDevice(dcRawData,#$1B#$26+'00',4);
   for I:=0 to 10000 do Application.ProcessMessages;
   Device.WriteDevice(dcRawData,#$1B#$4F,2); // Eject
   for I:=0 to 10000 do Application.ProcessMessages;
   Device.WriteDevice(dcRawData,#$1B+'S1',3); //Select Receipt
end;                                     
procedure PrintMoneyOrder(Device:IDevice;OfficeSs,DestinationSs,ValueSs,FeeSs,UserSs,WorkStnSs,DateSs,TimeSs,Office,Destination,Value,Fee,User,WorkStn:String;Date:TDateTime;Id:String);
var
   S:String;
   OfficeS,DestinationS,ValueS,FeeS,UserS,WorkStnS,DateS,TimeS:String;
   DT:String;
   K,I:Integer;
begin
   OfficeS     :=OfficeSs;
   DestinationS:=DestinationSs;
   ValueS      :=ValueSs;
   FeeS        :=FeeSs;
   UserS       :=UserSs;
   WorkStnS    :=WorkStnSs;
   DateS       :=DateSs;
   TimeS       :=TimeSs;
   
   While Length(OfficeS     ) < 15 do OfficeS     :=OfficeS     +' '; 
   While Length(DestinationS) < 15 do DestinationS:=DestinationS+' ';
   While Length(ValueS      ) < 15 do ValueS      :=ValueS      +' ';
   While Length(FeeS        ) < 15 do FeeS        :=FeeS        +' ';
   While Length(UserS       ) < 15 do UserS       :=UserS       +' ';
   While Length(WorkStnS    ) < 15 do WorkStnS    :=WorkStnS    +' ';
   While Length(DateS       ) < 15 do DateS       :=DateS       +' ';
   While Length(TimeS       ) < 15 do TimeS       :=TimeS       +' ';
   for I:=Length(Office     ) downto 1 do OfficeS     [(15-Length(Office     ))+I]:=Office     [I];
   for I:=Length(Destination) downto 1 do DestinationS[(15-Length(Destination))+I]:=Destination[I];
   for I:=Length(Value      ) downto 1 do ValueS      [(15-Length(Value      ))+I]:=Value      [I];
   for I:=Length(Fee        ) downto 1 do FeeS        [(15-Length(Fee        ))+I]:=Fee        [I];
   for I:=Length(User       ) downto 1 do UserS       [(15-Length(User       ))+I]:=User       [I];
   for I:=Length(WorkStn    ) downto 1 do WorkStnS    [(15-Length(WorkStn    ))+I]:=WorkStn    [I];
   DT:=FormatDateTime('dd/mm/yy',Now);
   for I:=Length(DT         ) downto 1 do DateS       [(15-Length(DT))+I]:=DT         [I];
   DT:=FormatDateTime('hh:nn',Now);
   for I:=Length(DT         ) downto 1 do TimeS       [(15-Length(DT))+I]:=DT         [I];
   
   Device.WriteDevice(dcRawData,#$1B#$26+'09',4); 
   Device.WriteDevice(dcRawData,'                                                       '+OfficeS     +#13#10,0);
   Device.WriteDevice(dcRawData,'                                                       '+DestinationS+#13#10,0);
   Device.WriteDevice(dcRawData,'                                                       '+ValueS      +#13#10,0);
   Device.WriteDevice(dcRawData,'                                                       '+FeeS        +#13#10,0);
   Device.WriteDevice(dcRawData,'                                                       '+UserS       +#13#10,0);
   Device.WriteDevice(dcRawData,'                                                       '+WorkStnS    +#13#10,0);
   Device.WriteDevice(dcRawData,'                                                       '+DateS       +#13#10,0);
   Device.WriteDevice(dcRawData,'                                                       '+TimeS       +#13#10,0);
   Device.WriteDevice(dcRawData,#$1B#$26+'04'#13#10,6); 
   Device.WriteDevice(dcRawData,#$1B#$26+'00',4);    
   for I:=1 to 7 do
      Device.WriteDevice(dcRawData,#13#10,0);  
   S:=Code128Data(Id,False);
   Device.WriteDevice(dcRawData,#$1B#$26+'07',4); 
   for K:=0 to 2 do                         
   begin
      Device.WriteDevice(dcRawData,#$1B#$25#$41+ZeroPad(200+Length(S)),6);
      for I:=1 to 200 do Device.WriteDevice(dcRawData,#0,1);
      for I:=1 to Length(S) do Device.WriteDevice(dcRawData,S[I],1);
//      Device.WriteDevice(dcRawData,S,Length(S));
      Device.WriteDevice(dcRawData,#13#10,2);
   end;
   Device.WriteDevice(dcRawData,#$1B#$26+'00',4); 
   for I:=1 to 20 do
      Device.WriteDevice(dcRawData,#13#10,0);
   Device.WriteDevice(dcRawData,#$1B#$26+'07'#13#10,6); 
   Device.WriteDevice(dcRawData,#$1B#$26+'09'#13#10,6); 
   Device.WriteDevice(dcRawData,'                                                         '+OfficeS     +#13#10,0);
   Device.WriteDevice(dcRawData,'                                                         '+DestinationS+#13#10,0);
   Device.WriteDevice(dcRawData,'                                                         '+ValueS      +#13#10,0);
   Device.WriteDevice(dcRawData,'                                                         '+FeeS        +#13#10,0);
   Device.WriteDevice(dcRawData,'                                                         '+UserS       +#13#10,0);
   Device.WriteDevice(dcRawData,'                                                         '+WorkStnS    +#13#10,0);
   Device.WriteDevice(dcRawData,'                                                         '+DateS       +#13#10,0);
   Device.WriteDevice(dcRawData,'                                                         '+TimeS       +#13#10,0);
   Device.WriteDevice(dcRawData,#$1B#$26+'00',4); 
   Device.WriteDevice(dcRawData,#$1B#$4F,2); // Eject
   Device.WriteDevice(dcRawData,#$1B+'S1',3); //Select Receipt
   Device.WriteDevice(dcRawData,#$1B+'l',2); // Reset
end;                                            
procedure TReceiptDevice.PrintSlip(Data:String);  
begin
   PrintMoneyOrder(FSerialDevice,FWOffice,FWZip,FWValue,FWFee,FWUser,FWWorkStation,'Date','Time',FOffice,FZip,FValue,FFee,FUser,FWorkStation,Now,FIdent);
end;
procedure TReceiptDevice.PrintLogo;                              
var
  I,J,K,W:Integer;
  OP:Byte;
  OPS:String;
begin
   if ABitMap = nil then
   begin
      ABitmap:=TBitMap.Create;
      ABitmap.LoadFromFile(FLogoFile);
   end;
   if FSerialDevice = nil then Exit;
   with ABitmap do
   begin
      FSerialDevice.WriteDevice(dcRawData,#$1B#$26+'08',3);
      for K:=0 to ABitmap.Height div 8 do     
      begin
         W:=(182-ABitmap.Width) div 2;
         FSerialDevice.WriteDevice(dcRawData,#$1B#$25#$41+ZeroPad(W+ABitmap.Width),6);
         SetLength(OPS,ABitmap.Width);
         for I:=1 to W do
             FSerialDevice.WriteDevice(dcRawData,#0,1);
         for I:=0 to ABitMap.Width do                        
         begin 
            OP:=0;
            for J:=0 to 7 do
            begin
               if Canvas.Pixels[I,J+K*8] = 0 then
                  OP:=OP or (1 shl J);
            end;
            FSerialDevice.WriteDevice(dcRawData,Char(OP),1);
            OPS[I+1]:=Char(OP);   
         end;
         FSerialDevice.WriteDevice(dcRawData,#13#10,2);
      end;
   end;                    
   FSerialDevice.WriteDevice(dcRawData,#$1B#$26+'00',3);
end;
function TReceiptDevice.WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool;
begin
   Result:=False;
   case CommandType of
      dcInitialise : begin
                        FSerialDevice:=CreateSerialDevice;
                        if FSerialDevice <> nil then
                        begin
                           FSerialDevice.SetEventSink(Self);
                           FSerialDevice.WriteDevice(dcInitialise,GetDeviceEntry('Receipt'),0);
                           FSerialDevice.WriteDevice(dcRawData,#$1B+'0',2);
                           Result:=True;                            
                        end;                                                              
                      end;
      dcRawData    : begin
                        Result:=FSerialDevice.WriteDevice(dcRawData,Data,0);
                     end;
      dcShutdown   : begin
                        FSerialDevice:=nil;
                        FDeviceEventSink:=nil;
                        Result:=True;
                     end;
      dcLine1Data  : begin 
                       PrintLogo;
                       Result:=True;
                     end;
      dcLine2Data  : begin
                       FSerialDevice.WriteDevice(dcRawData,#13#10#13#10,4);
                       PrintLogo;
                       FSerialDevice.WriteDevice(dcRawData,#$1B+'m',4);
                       Result:=True;
                     end;
      dcLine3Data  : begin
                        Stamp(ReMapChars(Data));
                     end;
      dcLine4Data  : if FSerialDevice <> nil then
                     begin
                        WaitFor;
                     end;
      dcLine5Data  : PrintLabel(FSerialDevice,FOffice,ReMapChars(Data),FZip,FFee,FIdent);
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
begin
   Data:='123456789';
   Result:=True;
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
initialization
  TGPCSCompFactory.Create(ComServer,TReceiptDevice,Class_ReceiptDevice,
                          'Device.Receipt','GPCS Custustomer Display Device',
                          ciMultiInstance);
end.