unit ZebraEMS;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TBaudRates     = (br9600,br4800,br2400,br1200,br600,br300,br110,br19200);
  TDataTypes     = (db8Bits,db7Bits,db6Bits,db5Bits);
  TParityTypes   = (ptNoParity,ptEvenParity,ptOddParity);
  TStopTypes     = (sb1Bit,sb1_5Bits,sb2Bits);
  TPortNumbs     = (COM1,COM2,COM3,COM4);

  TZebraEMS = class(TComponent)
  private
     FPortHandle    :THandle;

     FServInd       :String;
     FCountry       :String;
     FStartNumber   :Integer;
     FRunLength     :Integer;
     FPortNumber    :TPortNumbs;
     FBaudRate      :TBaudRates;
     FDataBits      :TDataTypes;
     FParity        :TParityTypes;
     FStopBits      :TStopTypes;
     FPrintSpeed    :Integer;
     
     function WritePort(Data:String):Boolean;
     function ReadPort(var Data:String;Length:Integer):Boolean;
     function ReadPortToLF(var Data:String):Boolean;
     procedure SetPrintSpeed(NewSpeed:Integer);
  protected   
    function  OpenPort:Boolean;
    procedure ClosePort;
    function  SetupPort:Boolean;
    function  GetStatus:Boolean;
  public
    FPortOpen      :Boolean;
    FPortSetup     :Boolean;
    FPaperOut      :Boolean;
    FPaused        :Boolean;
    FBufferFull    :Boolean;
    FCorruptRAM    :Boolean;
    FUnderTemp     :Boolean;
    FOverTemp      :Boolean;             
    FHeadUp        :Boolean;
    FRibonOut      :Boolean;
    FStillPrinting :Integer;
    FNoResponse    :Boolean;
    FCommsError    :Boolean;
    StatLine1      :String;
    StatLine2      :String;
    StatLine3      :String;
    LastPrinted:Integer;
    CancelPrint:Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function  Print:Boolean;
    function BVal(Val:Integer):String;
    function mod11(Code:Integer):Char;
  published            
     property ServiceIndicator :String       read FServInd     write FServInd      ;
     property Country          :String       read FCountry     write FCountry      ;
     property StartNumber      :Integer      read FStartNumber write FStartNumber  default 1;
     property RunLength        :Integer      read FRunLength   write FRunLength    default 1;
     property PortNumber       :TPortNumbs   read FPortNumber  write FPortNumber   default TPortNumbs  (COM1);
     property BaudRate         :TBaudRates   read FBaudRate    write FBaudRate     default TBaudRates  (br9600);
     property DataBits         :TDataTypes   read FDataBits    write FDataBits     default TDataTypes  (db8Bits);
     property Parity           :TParityTypes read FParity      write FParity       default TParityTypes(ptNoParity);
     property StopBits         :TStopTypes   read FStopBits    write FStopBits     default TStopTypes  (sb1Bit);
     property PrintSpeed       :Integer      read FPrintSpeed  write SetPrintSpeed default 6;
  end;

procedure Register;

implementation
constructor TZebraEMS.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FPortOpen:=False;
    FPortSetup:=False;
    FPortNumber:=TPortNumbs(COM1);
    FServInd:='EE'
end;
destructor TZebraEMS.Destroy;
begin
    if FPortOpen then ClosePort;
    inherited Destroy;
end;
procedure TZebraEMS.SetPrintSpeed(NewSpeed:Integer);
begin
   if (NewSpeed >= 2) and (NewSpeed <= 8) then
      FPrintSpeed:=NewSpeed;
end;
function TZebraEMS.OpenPort:Boolean;
var
   PortNumber:PChar;
begin
   result:=False;
   if FPortOpen then ClosePort;
   FPortOpen:=False;
   case FPortNumber of
      TPortNumbs(COM1): PortNumber:='COM1';
      TPortNumbs(COM2): PortNumber:='COM2';
      TPortNumbs(COM3): PortNumber:='COM3';
      TPortNumbs(COM4): PortNumber:='COM4';
      else PortNumber:='COM1';
   end;
   
   FPortHandle:=CreateFile(PortNumber,GENERIC_READ+GENERIC_WRITE,
                           0,nil,OPEN_EXISTING,0,0);
   if FPortHandle <> INVALID_HANDLE_VALUE then 
   begin
      FPortOpen:=True;
      result:=True;
   end;
end;
procedure TZebraEMS.ClosePort;
begin
    if (FPortOpen) and (FPortHandle <> INVALID_HANDLE_VALUE) then 
        CloseHandle(FPortHandle);
    FPortOpen:=False;
end;

function TZebraEMS.SetupPort:Boolean;
var
   dcb:TDCB;
   ct:TCommTimeOuts;
begin
   result:=False; 
   FPortSetup:=False;
   if not FPortOpen then Exit;
   
   ct.ReadIntervalTimeout        :=0;
   ct.ReadTotalTimeoutMultiplier :=0;
   ct.ReadTotalTimeoutConstant   :=3000;
   ct.WriteTotalTimeoutMultiplier:=0;
   ct.WriteTotalTimeoutConstant  :=3000;
   
   if GetCommState(FPortHandle,dcb) then
   begin
      if      FBaudRate = TBaudRates(br19200) then dcb.BaudRate:=19200
      else if FBaudRate = TBaudRates(br9600)  then dcb.BaudRate:=9600
      else if FBaudRate = TBaudRates(br4800)  then dcb.BaudRate:=4800
      else if FBaudRate = TBaudRates(br2400)  then dcb.BaudRate:=2400
      else if FBaudRate = TBaudRates(br1200)  then dcb.BaudRate:=1200
      else if FBaudRate = TBaudRates(br600)   then dcb.BaudRate:=600
      else if FBaudRate = TBaudRates(br300)   then dcb.BaudRate:=300
      else if FBaudRate = TBaudRates(br110)   then dcb.BaudRate:=110
      else dcb.BaudRate:=9600;
      
      if      FDataBits = TDataTypes(db8Bits) then dcb.ByteSize:=8
      else if FDataBits = TDataTypes(db7Bits) then dcb.ByteSize:=7
      else if FDataBits = TDataTypes(db6Bits) then dcb.ByteSize:=6
      else if FDataBits = TDataTypes(db5Bits) then dcb.ByteSize:=5
      else dcb.ByteSize:=8;
      
      if      FParity = TParityTypes(ptNoParity)   then dcb.Parity:=NOPARITY
      else if FParity = TParityTypes(ptEvenParity) then dcb.Parity:=EVENPARITY
      else if FParity = TParityTypes(ptOddParity)  then dcb.Parity:=ODDPARITY
      else dcb.Parity:=NOPARITY;
      
      
      if      FStopBits = TStopTypes(sb1Bit)    then dcb.StopBits:=ONESTOPBIT
      else if FStopBits = TStopTypes(sb1_5Bits) then dcb.StopBits:=ONE5STOPBITS
      else if FStopBits = TStopTypes(sb2Bits)   then dcb.StopBits:=TWOSTOPBITS
      else dcb.StopBits:=ONESTOPBIT;
      
      if SetCommState(FPortHandle,dcb) then
      begin
         if SetCommTimeouts(FPortHandle,ct) then 
         begin
            FPortSetup:=True;
            result:=True; 
         end;
      end;
   end;
end; 
function TZebraEMS.WritePort(Data:String):Boolean;
var
   BytesWritten:DWORD;
   len:DWORD;
   PString:ShortString;
begin
   result:=False;
   if (not FPortOpen) or (not FPortSetup) then Exit;
   PString:=Data;
   len:=Length(PString);
   if WriteFile(FPortHandle,PString[1],len,BytesWritten,nil) then
   begin
       if len = BytesWritten then
          result:=True;
   end;
end;

function TZebraEMS.ReadPortToLF(var Data:String):Boolean;
var
   BytesRead:DWORD;
   RByte:ShortString;
begin
   result:=False;
   if (not FPortOpen) or (not FPortSetup) then Exit;
   Data:='';
   while ReadFile(FPortHandle,RByte,1,BytesRead,nil) do
   begin
       if BytesRead <> 1 then Exit;
       Data:=Data + RByte[1];
       if RByte[1] = #10 then
       begin
          result:=True;
          Exit;
       end;
   end;                   
end;
function TZebraEMS.ReadPort(var Data:String;Length:Integer):Boolean;
var
   BytesRead:DWORD;
   RByte:Array[0..100] of Char;
   i:Integer;
begin
   Data:='';
   result:=False;
   if (not FPortOpen) or (not FPortSetup) then Exit;
   if ReadFile(FPortHandle,RByte,Length,BytesRead,nil) then
   begin
       if BytesRead = Length then 
       begin
          result:=True;
          for i:=1 to BytesRead do
             Data:=Data+RByte[i];
       end;
   end;                   
end;

function TZebraEMS.GetStatus:Boolean;
var
   Ofs:Integer;
begin
   FPaperOut     :=False;
   FPaused       :=False;
   FBufferFull   :=False;
   FCorruptRAM   :=False;
   FUnderTemp    :=False;
   FOverTemp     :=False;
   FHeadUp       :=False;
   FRibonOut     :=False;
   FStillPrinting:=0;
   FNoResponse   :=False;
   
   result:=False;
   FCommsError:=True;
   if (not FPortOpen) or (not FPortSetup) then Exit;
   FCommsError:=False;
   if not WritePort('~HS') then Exit;
   FNoResponse:=True;
   if not ReadPort(StatLine1,36) then Exit;
   if not ReadPort(StatLine2,36) then Exit;
   if not ReadPort(StatLine3,10) then Exit;
   FNoResponse:=False;
   ofs:=0;
   while ((StatLine1[Ofs+1] < #48) 
     or (StatLine1[Ofs+1] > #57)) 
     and (Ofs < 50) do
        Inc(Ofs);
   if StrToIntDef(Copy(StatLine1, 5+Ofs,1),0) <> 0 then FPaperOut     :=True; 
   if StrToIntDef(Copy(StatLine1, 7+Ofs,1),0) <> 0 then FPaused       :=True;
   if StrToIntDef(Copy(StatLine1,18+Ofs,1),0) <> 0 then FBufferFull   :=True;
   if StrToIntDef(Copy(StatLine1,28+Ofs,1),0) <> 0 then FCorruptRAM   :=True;
   if StrToIntDef(Copy(StatLine1,30+Ofs,1),0) <> 0 then FUnderTemp    :=True;
   if StrToIntDef(Copy(StatLine1,32+Ofs,1),0) <> 0 then FOverTemp     :=True;
   ofs:=0;
   while ((StatLine2[Ofs+1] < #48) 
     or (StatLine2[Ofs+1] > #57) )
     and (Ofs < 50) do
        Inc(Ofs);
   if StrToIntDef(Copy(StatLine2, 7+Ofs,1),0) <> 0 then FHeadUp       :=True;
   if StrToIntDef(Copy(StatLine2, 9+Ofs,1),0) <> 0 then FRibonOut     :=True;
   if StrToIntDef(Copy(StatLine2,23+Ofs,4),0) <> 0 then FStillPrinting:=StrToInt(Copy(StatLine2,23,4));

   if  (not FPaperOut     )
   and (not FPaused       )
   and (not FBufferFull   )
   and (not FCorruptRAM   )
   and (not FUnderTemp    )
   and (not FOverTemp     )
   and (not FHeadUp       )
   and (not FRibonOut     )
//   and (not FStillPrinting)
   and (not FNoResponse   )
   and (not FNoResponse   )
   and (not FCommsError   ) then
      result:=True;
end;
function TZebraEMS.mod11(Code:Integer):Char;
var
   res,cnt:Integer;
   chkval:Integer;
begin
    chkval:=86423597;
    res:=0;
    while code > 0 do
    begin
        res:=res+(chkval mod 10)*(code mod 10);
        code:=code div 10;
        chkval:=chkval div 10;
    end;
    res:=res mod 11;
    if res = 0 then
    begin
       Result:=#53;
    end
    else if res = 1 then
    begin
       Result:=#48;
    end           
    else
    begin
       Result:=Char((11-res)+48);
    end;
end;
function TZebraEMS.BVal(Val:Integer):String;
var
   I:Integer;
   m:Char;
begin
  I:=10000000;
  m:=mod11(Val);
  Result:='';
  if Val <> 0 then
  begin
     while I > Val do
     begin
        Result:=Result+'0';
        I:=I div 10;
     end;
     Result:=Result+IntToStr(Val);
  end
  else
  begin
     Result:=Result+'00000000';
  end;
  Result:=Result+m;
end;
function TZebraEMS.Print:Boolean;         
var
   i,j,k:integer;
   Bl,Bt,Tl,Tt,Sp:Integer;
   PValue:String;
begin
   LastPrinted:=FStartNumber-1;
   CancelPrint:=False;
   result:=False;
   Bl:=275;
   Tl:=370;
   Bt:=90;
   Tt:=165;
   Sp:=120;
   if (not FPortOpen) then if not OpenPort then Exit;
   if (not FPortSetup) then if not SetupPort then Exit;
   if FRunLength = 1 then
   begin
      j:=FStartNumber;
      while (GetStatus) and (FStillPrinting > 1) do
      begin
      end;
      if GetStatus then
      begin
         if not WritePort('^XA^CFD^FS^B^PR'+Char(FPrintSpeed+63)) then Exit;
//         if not WritePort('^XA^CFD^FS') then Exit;
         for K:=0 to 2 do
         begin
            if not WritePort('^FO'+
                          IntToStr(Bl)+','+
                          IntToStr(Bt+Sp*K)+
                          '^B3N,N,68,N,N^FD' + FServInd + 
                          BVal(StartNumber) + 
                          FCountry +'^FS') then Exit;
            if not WritePort('^FO'+
                          IntToStr(Tl)+','+
                          IntToStr(Tt+Sp*K)+
                          '^AEN,3,2^FD' + FServInd + ' '+
                          BVal(StartNumber)
                          +' '+ FCountry +'^FS') then Exit;
         end;
         if not WritePort('^XZ') then Exit;
         LastPrinted:=j;
      end                  
      else 
      begin
         // raise exception
         Exit;
      end;
   end
   else
   begin
      for i:=1 to FRunLength do
      begin
         if CancelPrint then Exit;
         j:=FStartNumber + (i-1);
         while (GetStatus) and (FStillPrinting >= 10) do
         begin
         end;
         if GetStatus then
         begin
         if not WritePort('^XA^CFD^FS^B^PR'+Char(FPrintSpeed+63)) then Exit;
//         if not WritePort('^XA^CFD^FS^PRE') then Exit;
            for K:=0 to 2 do
            begin
               if not WritePort('^FO'+
                             IntToStr(Bl)+','+
                             IntToStr(Bt+Sp*K)+
                             '^B3N,N,68,N,N^FD' + FServInd + 
                             BVal(j) + 
                             FCountry +'^FS') then Exit;
               if not WritePort('^FO'+
                             IntToStr(Tl)+','+
                             IntToStr(Tt+Sp*K)+
                             '^AEN,3,2^FD' + FServInd + ' '+
                             BVal(j) 
                             +' '+ FCountry +'^FS') then Exit;
            end;
            if not WritePort('^XZ') then Exit;
            LastPrinted:=j;
         end
         else 
         begin
            Exit;
         end;
      end;    
   end;
   result:=True;
end;
 
procedure Register;
begin
  RegisterComponents('P.S.L.', [TZebraEMS]);
end;

end.


