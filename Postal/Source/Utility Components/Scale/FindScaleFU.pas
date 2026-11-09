unit FindScaleFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TSerialDevice = class(TObject)
  private
    FPortHandle    :THandle;
    FPortOpen      :Boolean;
    FPortSetup     :Boolean;
    FPortNumber    :Integer;
    FBaudRate      :Integer;
    FDataBits      :Integer;
    FParity        :String;
    FStopBits      :Integer;
    FInTimeOut     :Integer;
    FOutTimeOut    :Integer;
  public  
    constructor Create;
    destructor Destroy; override;
    function SetupPort:Boolean;
    function WritePort(Data:String):WordBool;
    function WritePortB(Data:String;Length:Integer):WordBool;
    function ReadPort(var Data:String;var Length:Integer):WordBool;
    procedure ClosePort;
    function OpenPort:Boolean;
    property PortNumber    :Integer read FPortNumber write FPortNumber;
    property BaudRate      :Integer read FBaudRate   write FBaudRate  ;
    property DataBits      :Integer read FDataBits   write FDataBits  ;
    property Parity        :String  read FParity     write FParity    ;
    property StopBits      :Integer read FStopBits   write FStopBits  ;
    property InTimeOut     :Integer read FInTimeOut  write FInTimeOut ; 
    property OutTimeOut    :Integer read FOutTimeOut write FOutTimeOut;
  end;                  
  
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    KT: TCheckBox;
    Timer1: TTimer;
    CAS: TCheckBox;
    MaxPort: TEdit;
    UpTo: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure KTClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

constructor TSerialDevice.Create;
begin
   inherited Create;
   FBaudRate   :=9600 ;
   FDataBits   :=1    ;
   FParity     :='N'  ;
   FPortNumber :=1    ;
   FStopBits   :=8    ;
   FInTimeOut  :=500 ;
   FOutTimeOut :=1000 ;
end; 

destructor TSerialDevice.Destroy;
begin
    if FPortOpen then ClosePort;
    inherited Destroy;
end;
function TSerialDevice.OpenPort:Boolean;
var
   PortName:String;
begin
   Result:=False;
   if FPortOpen then ClosePort;
   FPortOpen:=False;
   PortName:='COM'+IntToStr(FPortNumber);
   
   FPortHandle:=CreateFile(PChar(PortName),GENERIC_READ+GENERIC_WRITE,
                           0,nil,OPEN_EXISTING,0,0);
   if FPortHandle <> INVALID_HANDLE_VALUE then 
   begin
      FPortOpen:=True;
      Result:=True;
   end;
end;
procedure TSerialDevice.ClosePort;
begin
   if (FPortOpen) and (FPortHandle <> INVALID_HANDLE_VALUE) then 
       CloseHandle(FPortHandle);
   FPortHandle:=INVALID_HANDLE_VALUE;
   FPortOpen:=False;
   FPortSetup:=False;
end;

function TSerialDevice.SetupPort:Boolean;
var
   dcb:TDCB;
   ct:TCommTimeOuts;
begin
   result:=False; 
   FPortSetup:=False;
   if not FPortOpen then Exit;
   
   ct.ReadIntervalTimeout        :=0;
   ct.ReadTotalTimeoutMultiplier :=0;
   ct.ReadTotalTimeoutConstant   :=FInTimeOut;
   ct.WriteTotalTimeoutMultiplier:=0;
   ct.WriteTotalTimeoutConstant  :=FOutTimeOut;
   
   if GetCommState(FPortHandle,dcb) then
   begin
      if (FBaudRate = 19200) or (FBaudRate = 9600 )
      or (FBaudRate = 4800 ) or (FBaudRate = 2400 )
      or (FBaudRate = 1200 ) or (FBaudRate = 600  )
      or (FBaudRate = 300  ) or (FBaudRate = 110  ) then 
        dcb.BaudRate:=FBaudRate
      else dcb.BaudRate:=FBaudRate;
      
      if (FDataBits = 8) or (FDataBits = 7)
      or (FDataBits = 6) or (FDataBits = 5) then 
         dcb.ByteSize:=FDataBits
      else dcb.ByteSize:=8;
      
      if      (FParity = 'n') or (FParity = 'N') then dcb.Parity:=NOPARITY
      else if (FParity = 'e') or (FParity = 'E') then dcb.Parity:=EVENPARITY
      else if (FParity = 'o') or (FParity = 'O') then dcb.Parity:=ODDPARITY
      else dcb.Parity:=NOPARITY;
      
      if      FStopBits = 1  then dcb.StopBits:=ONESTOPBIT
      else if FStopBits = 15 then dcb.StopBits:=ONE5STOPBITS
      else if FStopBits = 2  then dcb.StopBits:=TWOSTOPBITS
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
function TSerialDevice.WritePortB(Data:String;Length:Integer):WordBool;
var
   BytesWritten:DWORD;
   len:DWORD;
   PString:ShortString;
begin
   Result:=False;
   if (not FPortOpen ) and (not OpenPort) then Exit;
   if (not FPortSetup) and (not SetupPort) then Exit;
   PString:=Data;
   len:=Length;
   if WriteFile(FPortHandle,PString[1],len,BytesWritten,nil) then
   begin
       if len = BytesWritten then
          Result:=True;
   end;
end;
function TSerialDevice.WritePort(Data:String):WordBool;
begin
   result:=WritePortB(Data,Length(Data));
end;
function TSerialDevice.ReadPort(var Data:String;var Length:Integer):WordBool;
var       
   BytesRead:DWORD;
   RByte:Array[0..1000] of Char;
   I:Integer;
begin
   Data:='';
   Result:=False;
   if (not FPortOpen ) and (not OpenPort) then Exit;
   if (not FPortSetup) and (not SetupPort) then Exit;
   if ReadFile(FPortHandle,RByte,Length,BytesRead,nil) then
   begin
       if BytesRead = Length then 
          Result:=True;
       Length:=BytesRead;
       if Length > 0 then
       begin
          SetLength(Data,Length);
          for I:=0 to Length-1 do
             Data[I+1]:=RByte[I];
       end;
   end;                   
end;

procedure TForm1.Button1Click(Sender: TObject);
var
   I,D,P,Len:Integer;
   Data,Result:String;
   WriteOK:Boolean;
   SerialDevice:TSerialDevice;
   
   procedure TestPort;
   var
      J:Integer;
   begin
      if CAS.Checked then 
      begin
         WriteOK:=SerialDevice.WritePort(#5#$11);
//         Sleep(500);
//         WriteOK:=WriteOK and SerialDevice.WritePort(#$11);
      end
      else
      begin
         WriteOK:=SerialDevice.WritePort('W'+#13);
      end;
      if WriteOK then
      begin
         Data:=''; Len:=1000;
         SerialDevice.ReadPort(Data,Len);
         if Len > 0 then
         begin
            Result:='';
            for J:=1 to Len do Result:=Result+IntToHex(Integer(Data[J]),2);
            Result:=Result+' ';
            for J:=1 to Len do
            begin
               if Data[J] in [#32..#127] then
                  Result:=Result+Data[J];
            end;
            Memo1.Lines.Add('Data Received - DataLen ('+IntToStr(SerialDevice.DataBits)+
                          ') StopBits ('+IntToStr(SerialDevice.StopBits)+
                          ') Parity ('+SerialDevice.Parity+
                          ') = '+Result);
         end;
      end
      else
      begin
         Memo1.Lines.Add('Write Port - Failed');
      end;
   end;
begin
   Memo1.Clear;
   for I:=1 to StrToIntDef(MaxPort.Text,12) do
   begin
     SerialDevice:=TSerialDevice.Create;
     SerialDevice.PortNumber:=I;
     SerialDevice.BaudRate  :=9600;
     SerialDevice.StopBits  :=1;
     if SerialDevice.OpenPort then
     begin
        SerialDevice.ClosePort;
        Memo1.Lines.Add('Opened Port (COM'+IntToStr(I)+') - Testing ...');
        for D:=8 downto 7 do
        begin
           SerialDevice.DataBits:=D;
           if D = 8 then
           begin
              SerialDevice.Parity:='N';
              TestPort;
           end
           else
           begin
              for P:=1 to 2 do
              begin
                 case P of
                    1 : SerialDevice.Parity:='E';
                    2 : SerialDevice.Parity:='O';
                 end;
                 TestPort;
              end;  
           end;
        end;
        SerialDevice.ClosePort;
     end
     else
     begin
        Memo1.Lines.Add('Failed to Open Port (COM'+IntToStr(I)+')');
     end;
   end;
end;

procedure TForm1.KTClick(Sender: TObject);
begin
   Timer1.Enabled:=KT.Checked;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
   Button1Click(Button1);
end;

end.
