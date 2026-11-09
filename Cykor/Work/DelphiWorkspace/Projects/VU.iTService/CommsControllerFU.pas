unit CommsControllerFU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdTCPServer, IdUDPBase, IdUDPServer, ExtCtrls, IdBaseComponent,
  IdComponent, IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer,  IdContext,
  IdSocketHandle, WinSock, ShellAPI, IdTCPConnection;

type
  TCommsController = class(TForm)
    IdHTTPServer: TIdHTTPServer;
    Log: TMemo;
    Button1: TButton;
    Button2: TButton;
    Timer1: TTimer;
    IdUDPServer1: TIdUDPServer;
    IdTCPServer1: TIdTCPServer;
    DevicesLB: TListBox;
    Button3: TButton;
    procedure IdHTTPServerCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure IdUDPServer1UDPRead(Sender: TObject; AData: TBytes;
      ABinding: TIdSocketHandle);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure Button3Click(Sender: TObject);
    function xToComma(Str:String):String;
    function FormatData:String;
    function DataAvailable:Boolean;
    function GetSize(Str:String;var Len,Wid,Hgt:String):String;
    procedure GetAddr(Str:String;var Addr,Name,City,Zip,State,Country:String);
  private
    FActive:Boolean;

    FHTMLDir:String;
    MyIP:Integer;
    MachineName:String;
    ConnectionList:TList;
    AvailableDevices:TStringList;
    ImageIndex:Integer;
    ItemIndex:Integer;
    DataState:Integer;
    procedure SetActive(value:Boolean);
    function GetLocalMachineName:String;
    function GetIPAddress(MachineName:String):Integer;
    procedure LogLine(value:String);
    function LocalIPAddress:String;
    function HexToDec(Str:String):String;
    function StrToIP(Str:String):String;
  public
    property Active:Boolean read FActive write SetActive;
  end;

const DataFileName = 'C:\Vuit_Output.txt';

implementation

{$R *.dfm}

procedure TCommsController.LogLine(value:String);
var
  SL:TStringList;
begin
  if Visible then
  begin
    Log.Lines.BeginUpdate;
    try
      while Log.Lines.Count > 250 do
        Log.Lines.Delete(0);
      SL:=TStringList.Create;
      SL.Text:=value;
      Log.Lines.Add(Trim(SL.Text));
      SL.Free;
    finally
      log.Lines.EndUpdate
    end;
  end;
end;
procedure TCommsController.SetActive(value:Boolean);
begin
  FActive:=value;
  try
    IdHTTPServer.Active:=FActive;
    IdTCPServer1.Active:=FActive;
    IdUDPServer1.Active:=FActive;
  except

  end;
end;
function TCommsController.GetLocalMachineName:String;
var
   Length:DWord;
begin
   Length:=MAX_COMPUTERNAME_LENGTH+1;
   SetLength(Result,Length);
   GetComputerName(PChar(Result),Length);
   SetLength(Result,Length);
end;
function TCommsController.GetIPAddress(MachineName:String):Integer;
var
  HostEnt: PHostEnt;
  S:String;
  IPAddress:Integer;
begin
  S:=GetLocalMachineName;
  IPAddress:=0;
  HostEnt:=WinSock.gethostbyname(PChar(MachineName));
  if HostEnt <> nil then
     IPAddress:=(Integer(HostEnt^.h_addr^[0]) shl 24) or
                (Integer(HostEnt^.h_addr^[1]) shl 16) or
                (Integer(HostEnt^.h_addr^[2]) shl  8) or
                (Integer(HostEnt^.h_addr^[3]) shl  0);
  Result:=IPAddress;
end;

procedure TCommsController.Button1Click(Sender: TObject);
begin
//  WinExec(PAnsiChar('E:\Program Files\Mozilla Firefox\firefox.exe http://127.0.0.1:8000/'),SW_SHOW);
  ShellAPI.ShellExecute(Handle, PChar('open'), 'http://127.0.0.1:8000/', nil, nil, 0);
end;

procedure TCommsController.Button2Click(Sender: TObject);
begin
   Log.Lines.Clear;
end;

procedure TCommsController.Button3Click(Sender: TObject);
var
  Connection:TIdTCPConnection;
  I:Integer;
begin
  for I := 0 to ConnectionList.Count - 1 do
  begin
    Connection:=TIdTCPConnection(ConnectionList[I]);
    if Connection.Connected then
    begin
        Connection.IOHandler.Write('<HeartBeat/>'+#0);
    end;
  end;
end;

procedure TCommsController.FormClose(Sender: TObject; var Action: TCloseAction);
var
  I: Integer;
  Connection:TIdTCPConnection;
begin
   for I := 0 to ConnectionList.Count - 1 do
   begin
    Connection:=TIdTCPConnection(ConnectionList[I]);
      if Connection.Connected then
        Connection.Disconnect;
   end;
   ConnectionList.Free;

   IdHTTPServer.Active:=False;
   IdUDPServer1.Active:=False;
   IdTCPServer1.Active:=False;
   if visible then
   begin
     Application.Terminate;
   end;
end;

procedure TCommsController.FormCreate(Sender: TObject);
begin
  ImageIndex:=0;
  ItemIndex:=0;
  DataState:=0;
  AvailableDevices:=TStringList.Create;
  MachineName:=GetLocalMachineName;
  MyIP:=GetIPAddress(MachineName);
  FActive:=False;
  FHTMLDir := 'C:\VU.iT\HTML';
  ConnectionList:=TList.Create;
end;

procedure TCommsController.IdHTTPServerCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  LFilename: string;
  LPathname: string;
  SL:TStringList;
  SS:TStringStream;
  S:String;
  ip:String;
begin
//  if not visible then Beep;
  LFilename := ARequestInfo.Document;
  if LFileName='/crossdomain.xml' then
  begin
    ip:=LocalIPAddress;
    SL:=TStringList.Create;
    SL.Add('  <?xml version="1.0" ?>');
    SL.Add('  <!--  http://'+ip+':8000/crossdomain.xml-->');
    SL.Add('  <cross-domain-policy>');
    SL.Add('    <allow-access-from domain="'+ip+'" to-ports="80,8000,45001,45000"/>');
    SL.Add('    <allow-access-from domain="*.proiam.com" to-ports="80,8000,45001,45000"/>');
    SL.Add('    <allow-access-from domain="*.cykorsystems.com" to-ports="80,8000,45001,45000"/>');
    SL.Add('    <allow-access-from domain="*.krozyr.com" to-ports="80,8000,45001,45000"/>');
    SL.Add('    <allow-access-from domain="localhost" to-ports="80,8000,45001,45000" />');
    SL.Add('    <allow-access-from domain="127.0.0.1" to-ports="80,8000,45001,45000" />');
//    SL.Add('    <allow-access-from domain="'+ip+'" />');
//    SL.Add('    <allow-access-from domain="*.proiam.com" />');
//    SL.Add('    <allow-access-from domain="*.cykorsystems.com" />');
//    SL.Add('    <allow-access-from domain="*.krozyr.com" />');
//    SL.Add('    <allow-access-from domain="localhost" />');
//    SL.Add('    <allow-access-from domain="127.0.0.1" />');
    SL.Add('  </cross-domain-policy>');
    SS:=TStringStream.Create(SL.Text);
    SS.Position:=0;
    AResponseInfo.ContentStream := SS;
    LogLine(SL.Text);
    SL.Free;
  end
  else if LFileName='/VU.iT.Data.xml' then
  begin
    SL:=TStringList.Create;
    SL.Add('<?xml version="1.0" ?>');
    SL.Add(' <AvailableDevices>');
    if DataAvailable then
    begin
      SL.Add(' <Machine ipAddress="'+LocalIPAddress+'" dataAvailable="true" location="local" machineName="'+MachineName+'">');
      SL.Add(FormatData);
      SL.Add(' </Machine>')
    end
    else
    begin
      SL.Add(' <Machine ipAddress="'+LocalIPAddress+'" dataAvailable="false" location="local" machineName="'+MachineName+'"/>');
    end;
    SL.Add(' </AvailableDevices>');
    S:=SL.Text;
    SS:=TStringStream.Create(S);
    SS.Position:=0;
    AResponseInfo.ContentStream := SS;
    LogLine(SL.Text);
    SL.Free;
    DataState:=1;
  end
  else if LFileName='/VU.iT.Ready.xml' then
  begin
    if FileExists(DataFileName) then
      DeleteFile(DataFileName);
    SS:=TStringStream.Create('<Ready/>');
    AResponseInfo.ContentStream := SS;
    LogLine('<Ready/>');
    DataState:=0;
  end
  else
  begin
    if LFilename = '/' then
    begin
      LFilename := '/index.html';
    end;
    LPathname := FHTMLDir + LFilename;
    if FileExists(LPathname) then
    begin
      AResponseInfo.ContentStream := TFileStream.Create(LPathname, fmOpenRead + fmShareDenyWrite);
      LogLine(LPathname);
    end
    else
    begin
      AResponseInfo.ResponseNo := 404;
      AResponseInfo.ContentText := 'The requested URL ' + ARequestInfo.Document + ' was not found on this server.';
      LogLine('ERROR 404: '+LPathname);
    end;
  end;
end;
function TCommsController.DataAvailable:Boolean;
begin
  if FileExists(DataFileName) and (DataState=0) then
  begin
    Result:=True;
  end
  else
  begin
    Result:=False;
  end;
end;
function TCommsController.xToComma(Str:String):String;
var
  I: Integer;
begin
  Result:='';
  for I := 1 to Length(Str) do
  begin
     if Str[I] = 'x' then
       Result:=Result+','
     else
       Result:=Result+Str[I];
  end;
end;
function TCommsController.GetSize(Str:String;var Len,Wid,Hgt:String):String;
var
  SL:TStringList;
begin
  SL:=TStringList.Create;
  try
  Str:=xToComma(Str);
  except end; try
  SL.commaText:=Str;
  except end; try
  Len:=SL[0];
  except end; try
  Wid:=SL[1];
  except end; try
  Hgt:=SL[2];
  except end;
  Sl.Free;
  Result:=Str;
end;
procedure TCommsController.GetAddr(Str:String;var Addr,Name,City,Zip,State,Country:String);
var
  I:Integer;
begin
  Addr:='';
  Name:='';
  Zip:='';
  City:='';
  State:='';
  Country:='';
  try
  for I := 1 to Length(Str) do
  begin
    if ((Str[I] in ['0'..'9']) and ((I=0) or (Str[I-1] = ' '))) then
    begin
      Name:=Trim(Copy(Str,1,I-1));
      break;
    end;
  end;
  except end; try
  for I := Length(Str) downto 1 do
  begin
    if Str[I] in ['0'..'9'] then
    begin
      Country:=Trim(Copy(Str,I+1,Length(Str)-I));
      break;
    end;
  end;
  except end; try
  Str:=Copy(Str,Length(Name)+1,Length(Str));
  except end; try
  Str:=Trim(Copy(Str,1,Length(Str)-Length(Country)));
  except end; try

  for I := Length(Str) downto 1 do
  begin
    if not (Str[I] in ['0'..'9']) then
    begin
      Zip:=Trim(Copy(Str,I+1,Length(Str)-I));
      break;
    end;
  end;
  except end; try
  Str:=Trim(Copy(Str,1,Length(Str)-Length(Zip)));
  except end; try
  State:=Trim(Copy(Str,Length(Str)-1,2));
  except end; try
  Str:=Trim(Copy(Str,1,Length(Str)-2));
  except end; try
  for I := Length(Str) downto 1 do
  begin
    if (Str[I] = ' ') then
    begin
      City:=Trim(Copy(Str,I+1,Length(Str)-I));
      break;
    end;
  end;
  except end; try
  Addr:=Trim(Copy(Str,1,Length(Str)-Length(City)));
  except end;
end;

function TCommsController.FormatData:String;
var
  FileData:TStringList;
  SL:TStringList;
  Weight:String;
  Size:String;
  Destination:String;
  Origin:String;
  Image:String;
  ImageFile:String;
  NewImageFile:String;
  ImageType:String;
  I: Integer;
  Addr,Name,City,Zip,State,Country:String;
  Len,Wid,Hgt:String;
begin
  if FileExists(DataFileName) then
  begin
    FileData:=TStringList.Create;
    FileData.LoadFromFile(DataFileName);
    SL:=TStringList.Create;
    if FileData.Count > 4 then
    begin
      try
      Weight:=FloatToStr(StrToFloat(Copy(FileData[0],1,Pos('lb',FileData[0])-1))*16+StrToFloat(Copy(FileData[0],Pos(' ',FileData[0])+1,Pos('o',FileData[0])-(Pos(' ',FileData[0])+1))));
      except end;
      try
      Size:=GetSize(Copy(FileData[1],1,Length(FileData[1])-2),Len,Wid,Hgt);
      except end;
      try
      Destination:=Trim(Copy(FileData[2],6,Length(FileData[2])));
      except end;
      try
      Origin:=Trim(Copy(FileData[3],6,Length(FileData[3])));
      except end;
      try
      ImageFile:=Trim(Copy(FileData[4],7,Length(FileData[4])));
      except end;
      try
      ImageType:=ExtractFileExt(ImageFile);
      except end;
      try
      NewImageFile:=Copy(ImageFile,1,Length(ImageFile)-(Length(ImageType)))+IntToStr(ImageIndex)+ImageType;
      except end;
      Inc(ImageIndex);
      try
      ImageIndex:=ImageIndex mod 20;
      if FileExists(FHTMLDir+'\'+NewImageFile) then
        DeleteFile(FHTMLDir+'\'+NewImageFile);
      except end;
      try
      CopyFile(PChar('C:\'+ImageFile),PChar(FHTMLDir+'\'+NewImageFile),false);
      Image:='/'+ExtractFileName(NewImageFile);
      except end;
      SL.Add('   <Item>');
      SL.Add('     <Weight>'+Weight+'</Weight>');
      SL.Add('     <Size>'+Size+'</Size>');
      SL.Add('     <Destination>'+Destination+'</Destination>');
      SL.Add('     <Origin>'+Origin+'</Origin>');
      SL.Add('     <Image>'+Image+'</Image>');
      SL.Add('     <Index>'+IntToStr(ItemIndex)+'</Index>');
      SL.Add('   </Item>');
      SL.Add('   <RawData>');
      SL.Add('     <![CDATA[');
      for I := 0 to FileData.Count - 1 do
        SL.Add('       '+Trim(FileData[I]));
      SL.Add('     ]]>');
      SL.Add('   </RawData>');

      SL.Add('   <vuitResult>');
      SL.Add('   	<status>OK</status>');
      SL.Add('   	<image>'+Image+'</image>');
      SL.Add('   	<physicalAttributes>');
      SL.Add('   		<weight>'+Weight+'</weight>');
      SL.Add('   		<length>'+Len+'</length>');
      SL.Add('   		<width>'+Wid+'</width>');
      SL.Add('   		<height>'+Hgt+'</height>');
      SL.Add('   		<units>US</units>');
      SL.Add('   	</physicalAttributes>');
      SL.Add('   	<postage/>');
      SL.Add('   	<services/>');
      GetAddr(Destination,Addr,Name,City,Zip,State,Country);
      SL.Add('   	<destination>');
      SL.Add('   		<zipCode>'+Zip+'</zipCode>');
      SL.Add('   		<country>'+Country+'</country>');
      SL.Add('   		<rawString>'+Destination+'</rawString>');
      SL.Add('   		<imageLocation>0, 0, 0, 0</imageLocation>');
      SL.Add('   		<address>');
      SL.Add('   			<name>'+Name+'</name>');
      SL.Add('   			<line1>'+Addr+'</line1>');
      SL.Add('   			<line2></line2>');
      SL.Add('   			<line3></line3>');
      SL.Add('   			<city>'+City+'</city>');
      SL.Add('   			<state>'+State+'</state>');
      SL.Add('   			<zip>'+Zip+'</zip>');
      SL.Add('   			<telephone></telephone>');
      SL.Add('   			<email></email>');
      SL.Add('   		</address>');
      SL.Add('   	</destination>');
      GetAddr(Origin,Addr,Name,City,Zip,State,Country);
      SL.Add('   	<origin>');
      SL.Add('   		<zipCode>'+Zip+'</zipCode>');
      SL.Add('   		<country>'+Country+'</country>');
      SL.Add('   		<rawString>'+Origin+'</rawString>');
      SL.Add('   		<imageLocation>0, 0, 0, 0</imageLocation>');
      SL.Add('   		<address>');
      SL.Add('   			<name>'+Name+'</name>');
      SL.Add('   			<line1>'+Addr+'</line1>');
      SL.Add('   			<line2></line2>');
      SL.Add('   			<line3></line3>');
      SL.Add('   			<city>'+City+'</city>');
      SL.Add('   			<state>'+State+'</state>');
      SL.Add('   			<zip>'+Zip+'</zip>');
      SL.Add('   			<telephone></telephone>');
      SL.Add('   			<email></email>');
      SL.Add('   		</address>');
      SL.Add('   	</origin>');
      SL.Add('   </vuitResult>');
    end;
    Result:=Trim(SL.Text);
    SL.Free;
    FileData.Free;
  end
  else
  begin
    Result:='';
  end;
end;

procedure TCommsController.IdTCPServer1Execute(AContext: TIdContext);
var
  S:String;
  SL:TStringList;
  I: Integer;
  Tick:Integer;
begin
  Tick:=0;
  with AContext.Connection do begin
    if Connected then
        LogLine('Connected...');
    DataState:=0;
    ConnectionList.Add(AContext.Connection);
    while Connected do begin
      IOHandler.CheckForDataOnSource(100);
      S:=Trim(IOHandler.InputBufferAsString);
      if S <> '' then
      begin
        LogLine(S);
        if S='<policy-file-request/>' then
        begin
          SL:=TStringList.Create;
          SL.Add('  <?xml version="1.0" ?>');
          SL.Add('  <!DOCTYPE cross-domain-policy SYSTEM "http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd">');
          SL.Add('  <!--  Policy file for http://'+LocalIPAddress+':8000/crossdomain.xml-->');
          SL.Add('  <cross-domain-policy>');
          SL.Add('    <allow-access-from domain="'+LocalIPAddress+'" to-ports="80,8000,45001,45000"/>');
          SL.Add('    <allow-access-from domain="*.proiam.com" to-ports="80,8000,45001,45000"/>');
          SL.Add('    <allow-access-from domain="*.cykorsystems.com" to-ports="80,8000,45001,45000"/>');
          SL.Add('    <allow-access-from domain="*.krozyr.com" to-ports="80,8000,45001,45000"/>');
          SL.Add('    <allow-access-from domain="localhost" to-ports="80,8000,45001,45000" />');
          SL.Add('    <allow-access-from domain="127.0.0.1" to-ports="80,8000,45001,45000" />');
          SL.Add('  </cross-domain-policy>');
          IOHandler.Write(SL.Text+#0);
          LogLine(SL.Text);
          SL.Free;
        end;
        //IOHandler.Write(S+#0);
      end
      else
      begin
         Inc(Tick);
         if ((Tick mod 20) = 0) then
         begin
            SL:=TStringList.Create;
            SL.Add('<?xml version="1.0" ?>');
            SL.Add(' <AvailableDevices>');
            if DataAvailable then
              SL.Add(' <Machine ipAddress="'+LocalIPAddress+'" dataAvailable="true" location="local" machineName="'+MachineName+'"/>')
            else
              SL.Add(' <Machine ipAddress="'+LocalIPAddress+'" dataAvailable="false" location="local" machineName="'+MachineName+'"/>');
            for I := 0 to AvailableDevices.Count - 1 do
            begin
              S:=AvailableDevices[I];
              if Copy(S,16,1) <> ' ' then
                SL.Add(' <Machine ipAddress="'+Copy(S,1,15)+'" dataAvailable="true" location="LAN" machineName="'+Copy(S,17,Length(S))+'"/>')
              else
                SL.Add(' <Machine ipAddress="'+Copy(S,1,15)+'" dataAvailable="false" location="LAN" machineName="'+Copy(S,17,Length(S))+'"/>');
            end;
            SL.Add(' </AvailableDevices>');
            LogLine('Sent'+SL.Text);
            IOHandler.Write(SL.Text+#0);
            Sl.Free;
         end;
      end;
    end;
    if not Connected then
        LogLine('Disconnected.');
    I:=ConnectionList.IndexOf(AContext.Connection);
    if I >= 0 then
      ConnectionList.Delete(I);
  end;
end;

procedure TCommsController.Timer1Timer(Sender: TObject);
begin
  if IdUDPServer1.Active then
  begin
    if DataAvailable then
       IdUDPServer1.Broadcast('VU.iT :'+IntToHex(MyIP,8)+'!'+MachineName,45001)
    else
       IdUDPServer1.Broadcast('VU.iT :'+IntToHex(MyIP,8)+' '+MachineName,45001);
  end;
end;
function TCommsController.LocalIPAddress:String;
begin
  Result:=StrToIP(IntToHex(MyIP,8));
end;
function TCommsController.HexToDec(Str:String):String;
begin
  Result:=IntToStr(StrToInt('$'+Str));
  while Length(Result) < 3 do
    Result:='0'+Result;
end;
function TCommsController.StrToIP(Str:String):String;
begin
  Result:=HexToDec(Copy(Str,1,2))+'.'+HexToDec(Copy(Str,3,2))+'.'+HexToDec(Copy(Str,5,2))+'.'+HexToDec(Copy(Str,7,2));
end;
procedure TCommsController.IdUDPServer1UDPRead(Sender: TObject; AData: TBytes;
  ABinding: TIdSocketHandle);
var
  RxString:String;
  IPAddress:String;
  DecIP:String;
  Machine:String;
  dataStr:String;
//  hasData:Boolean;
  Index,Value:Integer;
begin
  RxString:=Copy(PChar(AData),1,High(AData)+1);
  if Copy(RxString,1,7) = 'VU.iT :' then
  begin
    IPAddress:=Copy(RxString,8,8);
    Machine:=Copy(RxString,17,Length(RxString));
    dataStr:=Copy(RxString,16,1);
//    hasData:=(dataStr<>' ');
    if Machine <> MachineName then
    begin
      DecIP:=StrToIP(IPAddress);
//      LogLine('UDP:'+Machine+':'+DecIP);
      Index:=AvailableDevices.IndexOf(DecIP+dataStr+Machine);
      if Index = -1 then
        AvailableDevices.AddObject(DecIP+dataStr+Machine,TObject(20))
      else
        AvailableDevices.Objects[Index]:=TObject(20);
    end;
    for Index:=0 to AvailableDevices.Count-1 do
    begin
      Value:=Integer(AvailableDevices.Objects[Index]);
      Dec(Value);
      if Value < 1 then
        AvailableDevices.Delete(Index)
      else
        AvailableDevices.Objects[Index]:=TObject(Value);
    end;
    DevicesLB.Items.Text:=AvailableDevices.Text;
  end;
end;

end.
