unit CommsControllerFU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdTCPServer, IdUDPBase, IdUDPServer, ExtCtrls, IdBaseComponent,
  IdComponent, IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer,  IdContext,
  IdSocketHandle, WinSock, ShellAPI, IdTCPConnection, IdTCPClient,
  IdZLibCompressorBase, IdCompressorZLibEx, IdHTTP,DirectoryU,DIMimeStreams;

type
  TCommsController = class(TForm)
    IdHTTPServer: TIdHTTPServer;
    Log: TMemo;
    Button1: TButton;
    Button2: TButton;
    Timer1: TTimer;
    IdUDPServer1: TIdUDPServer;
    IdTCPServer1: TIdTCPServer;
    IdTCPClient1: TIdTCPClient;
    DeviceTimer: TTimer;
    IdHTTP1: TIdHTTP;
    IdCompressorZLibEx1: TIdCompressorZLibEx;
    Button4: TButton;
    CheckBox1: TCheckBox;
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
    function DataAvailable:Boolean;
    procedure DeviceTimerTimer(Sender: TObject);
    procedure IdTCPClient1Connected(Sender: TObject);
    procedure IdTCPClient1Disconnected(Sender: TObject);
    procedure IdTCPClient1Status(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    procedure Button4Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  private
    FActive:Boolean;
    IsConnected:Boolean;
    DeviceIPAddress:String;
    DevicePortNumber:Integer;
    ReceivedData:TStringList;
    FHTMLDir:String;
    MyIP:Integer;
    MachineName:String;
    ConnectionList:TList;
    AvailableDevices:TStringList;
    ImageIndex:Integer;
    ItemIndex:Integer;
    DataState:Integer;
    counter:Integer;
    FileList:TStringList;
    Closing:Boolean;
    procedure SetActive(value:Boolean);
    function GetLocalMachineName:String;
    function GetIPAddress(MachineName:String):Integer;
    function CrossDomainXML(port:Integer):String;
    procedure LogLine(value:String);
    function LocalIPAddress:String;
    function HexToDec(Str:String):String;
    function StrToIP(Str:String):String;
    procedure OnFile(Name:String;Details:TSearchRec);
    procedure FillList();
    function GetFile(URL,FileName:String;LocalPath:String='';FileTime:Integer=0):String;
    procedure PutFile(URL,FileName:String;LocalPath:String);
  public
    property Active:Boolean read FActive write SetActive;
    procedure ConnectDevice(Host:String;Port:Integer);
    procedure DisconnectDevice;
    procedure SendCommand(Cmd:String);
    procedure LogDataToFile(value:String);
    procedure LogStreamToFile(Stream:TStream);
  end;

const
    DataFileName  = 'C:\Vuit_Output.txt';
    LoggingPath   = 'C:\VU.iT\Logging';
    LoggingFile   = 'ReceivedData.dat';
//    ProiamSiteURL = 'http://www.proiam.com/busappdemotest';
    ProiamSiteURL = 'http://www.proiam.com/demonstration';
    FileListName  = 'F173715D.dat';
    LocalFilePath = 'C:\VU.iT\HTML';


implementation

{$R *.dfm}

procedure CreateFullDir(Path:String);
var
  I:Integer;
begin
  for I := 1 to Length(Path) do
  begin
    if ((Path[I] = '\') and (not DirectoryExists(ExtractFilePath(Copy(Path,1,I))))) then
        CreateDir(Copy(Path,1,I));
  end;
  if (not DirectoryExists(ExtractFilePath(Path))) then
      CreateDir(ExtractFilePath(Path));
end;
procedure LogFileAdd(Line,FileName:String);
var
   FileStream:TFileStream;
begin
    if not DirectoryExists(ExtractFilePath(FileName)) then
      CreateFullDir(ExtractFilePath(FileName));
   try
     if FileExists(FileName) then
        FileStream:=TFileStream.Create(FileName,fmOpenReadWrite or fmShareExclusive)
     else
      FileStream:=nil;
   except
      FileStream:=nil;
   end;
   try
      if FileStream = nil then
         FileStream:=TFileStream.Create(FileName,fmCreate or fmShareExclusive);
   except
      FileStream:=nil;
   end;

   if FileStream = nil then Exit;

   try
      FileStream.Position:=FileStream.Size;
      Line:=IntToHex(Length(line)+2,8)+FormatDateTime('yymmddhhnnss',now)+#13#10+Line+#13#10;
      FileStream.Write(Pointer(Line)^,Length(Line));
   except;
      ;
   end;
   try
      FileStream.Free;
   except;
      ;
   end;
end;
procedure LogFileStream(Stream:TStream;FileName:String);
var
   SS:TStringStream;
begin
  SS:=TStringStream.Create('');
  MimeEncodeStream(Stream,SS);
  LogFileAdd('<Mime>'+#13#10+SS.DataString+#13#10+'</Mime>',FileName);
  SS.Free;
end;
procedure TCommsController.LogDataToFile(value:String);
begin
  if CheckBox1.Checked then
  begin
    LogFileAdd(value,LoggingPath+'\'+LoggingFile);
  end;
end;
procedure TCommsController.LogStreamToFile(Stream:TStream);
begin
  if CheckBox1.Checked then
  begin
    LogFileStream(Stream,LoggingPath+'\'+LoggingFile);
  end;
end;
procedure TCommsController.LogLine(value:String);
var
  SL:TStringList;
begin
  if (Visible and (not Closing)) then
  begin
    Log.Lines.BeginUpdate;
    try
      while Log.Lines.Count > 500 do
        Log.Lines.Delete(0);
      SL:=TStringList.Create;
      SL.Text:=value;
      Log.Lines.Add(Trim(SL.Text));
      SL.Free;
    finally
      Log.Lines.EndUpdate;
      Log.SelStart:=Length(Log.Lines.Text);
      Log.SelLength:=0;
    end;
  end;
end;
procedure TCommsController.SetActive(value:Boolean);
begin
  try
    FActive:=value;
    IdHTTPServer.Active:=FActive;
    IdTCPServer1.Active:=FActive;
    IdUDPServer1.Active:=FActive;
  except
    LogLine('Exception in SetActive');
  end;
end;
function TCommsController.GetLocalMachineName:String;
var
   Length:DWord;
begin
  try
     Length:=MAX_COMPUTERNAME_LENGTH+1;
     SetLength(Result,Length);
     GetComputerName(PChar(Result),Length);
     SetLength(Result,Length);
  except
    LogLine('Exception in GetLocalMachine');
  end;
end;
function TCommsController.GetIPAddress(MachineName:String):Integer;
var
  HostEnt: PHostEnt;
  S:String;
  IPAddress:Integer;
begin
  try
    S:=GetLocalMachineName;
    IPAddress:=0;
    HostEnt:=WinSock.gethostbyname(PChar(MachineName));
    if HostEnt <> nil then
       IPAddress:=(Integer(HostEnt^.h_addr^[0]) shl 24) or
                  (Integer(HostEnt^.h_addr^[1]) shl 16) or
                  (Integer(HostEnt^.h_addr^[2]) shl  8) or
                  (Integer(HostEnt^.h_addr^[3]) shl  0);
  except
     IPAddress:=$7F000001;
     LogLine('Could not resolve host, using 127.0.0.1');
  end;
  Result:=IPAddress;
end;

procedure TCommsController.Button1Click(Sender: TObject);
begin
  ShellAPI.ShellExecute(Handle, PChar('open'), 'http://127.0.0.1:8000/', nil, nil, 0);
end;

procedure TCommsController.Button2Click(Sender: TObject);
begin
   Log.Lines.Clear;
end;


procedure TCommsController.OnFile(Name:String;Details:TSearchRec);
var
  LocalPath:String;
begin
   LocalPath:=Copy(Name,Length(LocalFilePath)+2,Length(Name));
   if (Copy(LocalPath,1,4) <> 'com\') and (LocalPath<>FileListName) and (Details.Size<>0) then
     FileList.Add(IntToHex(Details.Time,8)+LocalPath);
end;
procedure TCommsController.FillList();
var
   Dir:TDirectory;
begin
   FileList:=TStringList.Create;
   Dir:=TDirectory.Create;
   Dir.Mask:='*.*';
   Dir.Attr:=$FF;
   Dir.AllDirs:=False;
   Dir.OnFile:=OnFile;
   Dir.Recurse:=True;
   Dir.RootPath:=LocalFilePath;
   Dir.Free;
end;
function FileDateToFileTime(FileDate:Integer):TFileTime;
var
  st:SYSTEMTIME;
  FT:TFileTime;
  FD:TDateTime;
begin
  FD:=FileDateToDateTime(FileDate);
  DateTimeToSystemTime(FD,&st);

  SystemTimeToFileTime(&st, &FT);
  LocalFileTimeToFileTime(&FT,&result);
end;
function Prepare(value:String):String;
var
  I:Integer;
begin
  for I := 1 to Length(value) do
  begin
    if value[I] = ' ' then
      result:=result+'%20'
    else
      result:=result+value[I];
  end;
end;
function TCommsController.GetFile(URL,FileName:String;LocalPath:String='';FileTime:Integer=0):String;
var
  IdHTTP: TIdHTTP;
  FS:TFileStream;
  FT:TFileTime;
begin
  FS:=nil;
  try
    IdHTTP := TIdHTTP.Create(nil);
    try
      IdHTTP.ReadTimeout:=20000;
      if LocalPath = '' then
      begin
        result:=IdHTTP.Get(URL+'/'+FileName);
      end
      else
      begin
        if not DirectoryExists(ExtractFilePath(LocalPath+'\'+FileName)) then
          CreateFullDir(ExtractFilePath(LocalPath+'\'+FileName));
        FS:=TFileStream.Create(LocalPath+'\'+FileName,fmCreate or fmOpenWrite,fmShareExclusive);
        IdHTTP.Get(Prepare(URL+'/'+FileName),FS);
        FT:=FileDateToFileTime(FileTime);
        SetFileTime(FS.Handle,@FT,@FT,@FT);
        FS.Free;
        FS:=nil;
      end;
    finally
      IdHTTP.Free;
      if FS <> nil then
        FS.Free;
    end;
  except
    LogLine('Exception in GetFile');
  end;
end;
procedure TCommsController.PutFile(URL,FileName:String;LocalPath:String);
var
  IdHTTP: TIdHTTP;
  FS:TFileStream;
begin
  if not FileExists(LocalPath+'\'+FileName) then Exit;
  try
  FS:=nil;
  IdHTTP := TIdHTTP.Create(nil);
  try
    IdHTTP.ReadTimeout:=20000;
    FS:=TFileStream.Create(LocalPath+'\'+FileName,fmOpenRead,fmShareDenyNone);
    IdHTTP.Put(URL+'/'+FileName,FS);
    FS.Free;
    FS:=nil;
  finally
    IdHTTP.Free;
    if FS <> nil then
      FS.Free;
  end;
  except
    LogLine('Exception in PutFile');
  end;
end;
procedure TCommsController.Button4Click(Sender: TObject);
var
  SL:TStringList;
  I:Integer;
  FileTime:Integer;
  FileCount:Integer;
  FailCount:Integer;
begin
  FillList();
  SL:=TStringList.Create;
  LogLine('Checking for updates on '+ProiamSiteURL);
  SL.Text:=GetFile(ProiamSiteURL,FileListName);
  FileCount:=0;
  FailCount:=0;
  if SL.Count > 0 then
  begin
    for I := 0 to SL.Count - 1 do
    begin
      if (FileList.IndexOf(SL[I]) = -1) then
      begin
        try
          FileTime:=StrToInt('$'+Copy(SL[I],1,8));
          GetFile(ProiamSiteURL,Copy(SL[I],9,999),FHTMLDir,FileTime);
          LogLine('File '+Copy(SL[I],9,999)+' Transfer OK');
          Inc(FileCount);
        except
          LogLine('File '+Copy(SL[I],9,999)+' Transfer FAILED !');
          Inc(FailCount);
        end;
      end;
    end;
  end;
  if ((FileCount = 0) and (FailCount = 0)) then
    LogLine('No updates needed.')
  else if (FileCount <> 0) then
    LogLine('File Transfer complete - Transfered '+IntToStr(FileCount)+' files.');
  if (FailCount <> 0) then
    LogLine('File Transfer errors - Failed to transfer '+IntToStr(FailCount)+' files.');
  Button1.Visible:=True;
  SL.Free;
end;

procedure TCommsController.FormClose(Sender: TObject; var Action: TCloseAction);
var
  I: Integer;
  Connection:TIdTCPConnection;
begin
   try
     Closing:=True;
     DeviceTimer.Enabled:=False;
     if IsConnected then
      DisconnectDevice;
     IdHTTPServer.Active:=False;
     IdUDPServer1.Active:=False;
     if visible then
     begin
       Application.Terminate;
     end;

     try
       IdTCPServer1.Active:=False;
     except

     end;
     for I := 0 to ConnectionList.Count - 1 do
     begin
      try
        Connection:=TIdTCPConnection(ConnectionList[I]);
          if Connection.Connected then
            Connection.Disconnect;
      except

      end;
     end;
     ConnectionList.Free;
   except

   end;
end;

procedure TCommsController.FormCreate(Sender: TObject);
var
  SL:TStringList;
  iniFile:String;
begin
  Closing:=False;
  ReceivedData:=TStringList.Create;
  counter:=0;
  IsConnected:=False;
  ImageIndex:=0;
  ItemIndex:=0;
  DataState:=0;
  AvailableDevices:=TStringList.Create;
  MachineName:=GetLocalMachineName;
  MyIP:=GetIPAddress(MachineName);
  FActive:=False;
  FHTMLDir := LocalFilePath;
  SL:=TStringList.Create;
  iniFile:=ExtractFilePath(ParamStr(0))+'\Service.ini';
  try
    if FileExists(iniFile) then
      SL.LoadFromFile(iniFile);
  except end;
  DeviceIPAddress:='127.0.0.1';
  DevicePortNumber:=2000;
  if SL.Count > 0 then
  begin
    DeviceIPAddress:=SL.Values['DeviceIPAddress'];
    DevicePortNumber:=StrToIntDef(SL.Values['PortNumber'],2000);
  end
  else
  begin
    SL.Clear;
    SL.Add('[DeviceInterface]');
    SL.Add('DeviceIPAddress=127.0.0.1');
    SL.Add('DevicePortNumber=2000');
    SL.SaveToFile(iniFile);
  end;
  SL.Free;
  ConnectionList:=TList.Create;
  DeviceTimer.Enabled:=True;
end;
function TCommsController.CrossDomainXML(port:Integer):String;
var
  SL:TStringList;
  ip:String;
begin
    ip:=LocalIPAddress;
    SL:=TStringList.Create;
    SL.Add('  <?xml version="1.0" ?>');
    SL.Add('  <!--  http://'+ip+':'+IntToStr(port)+'/crossdomain.xml-->');
    SL.Add('  <cross-domain-policy>');
    SL.Add('    <allow-access-from domain="'+ip+'" to-ports="80,8000,45001,45000"/>');
    SL.Add('    <allow-access-from domain="*.proiam.com" to-ports="80,8000,45001,45000"/>');
    SL.Add('    <allow-access-from domain="*.cykorsystems.com" to-ports="80,8000,45001,45000"/>');
    SL.Add('    <allow-access-from domain="*.cykor.homedns.org" to-ports="80,8000,45001,45000"/>');
    SL.Add('    <allow-access-from domain="localhost" to-ports="80,8000,45001,45000" />');
    SL.Add('    <allow-access-from domain="127.0.0.1" to-ports="80,8000,45001,45000" />');
    SL.Add('  </cross-domain-policy>');
    result:=SL.Text;
    SL.Free;
end;
procedure TCommsController.IdHTTPServerCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  LFilename: string;
  LPathname: string;
  SL:TStringList;
  S:String;
  SS:TStringStream;
  FS:TFileStream;
begin
  try
  LFilename := ARequestInfo.Document;
  if LFileName='/crossdomain.xml' then
  begin
    S:=CrossDomainXML(8000);
    SS:=TStringStream.Create(S);
    SS.Position:=0;
    LogDataToFile(S);
    AResponseInfo.ContentStream := SS;
    LogLine('cross domain security policy file sent');
  end
  else if LFileName='/VU.iT.Data.xml' then
  begin
    DataState:=1;
    SL:=TStringList.Create;
    SL.Add('<?xml version="1.0" ?>');
    SL.Add(' <AvailableDevices>');
    if (ReceivedData.Count > 0) then
    begin
      SL.Add(' <Machine ipAddress="'+LocalIPAddress+'" dataAvailable="true" location="local" machineName="'+MachineName+'">');
      while (ReceivedData.Count > 0) do
      begin
        SL.Add(ReceivedData[0]);
        ReceivedData.Delete(0);
      end;
      SL.Add(' </Machine>');
    end
    else
    begin
      SL.Add(' <Machine ipAddress="'+LocalIPAddress+'" dataAvailable="false" location="local" machineName="'+MachineName+'"/>');
    end;
    SL.Add(' </AvailableDevices>');
    S:=SL.Text;
    SS:=TStringStream.Create(S);
    SS.Position:=0;
    LogDataToFile(S);
    AResponseInfo.ContentStream := SS;
    LogLine('/VU.iT.Data.xml');
    SL.Free;
    DataState:=0;
  end
  else if LFileName='/VU.iT.Ready.xml' then
  begin
    if IsConnected then
      SendCommand('ARM');
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
    if Copy(LFilename,1,2) = '//' then
    begin
      LPathname := Copy(LFilename,3,Length(LFilename));
    end else
    begin
      LPathname := FHTMLDir + LFilename;
    end;
    if FileExists(LPathname) then
    begin
      FS:=TFileStream.Create(LPathname, fmOpenRead + fmShareDenyWrite);
      LogStreamToFile(FS);
      AResponseInfo.ContentStream := FS;
      LogLine(LPathname);
    end
    else
    begin
      AResponseInfo.ResponseNo := 404;
      AResponseInfo.ContentText := 'The requested URL ' + ARequestInfo.Document + ' was not found on this server.';
      LogLine('ERROR 404: '+LPathname);
    end;
  end;
  except
    LogLine('Exception in HttpServerGet');
  end;
end;
function TCommsController.DataAvailable:Boolean;
begin
  if (ReceivedData.Count > 0) and (DataState=0) then
  begin
    Result:=True;
  end
  else
  begin
    Result:=False;
  end;
end;

procedure TCommsController.IdTCPServer1Execute(AContext: TIdContext);
var
  S:String;
  CDP:String;
  SL:TStringList;
  I: Integer;
  Tick:Integer;
begin
  Tick:=0;
  if ((AContext = nil) or (AContext.Connection = nil) or (AContext.Connection.IOHandler = nil)) then Exit;
  try
    with AContext.Connection do begin
      if Connected then
          LogLine('Connected...');
    DataState:=0;
    ConnectionList.Add(AContext.Connection);
    while ((AContext <> nil) and (AContext.Connection <> nil) and (Connected) and (IOHandler <> nil)) do begin
      if Closing then Exit;
      try
        IOHandler.CheckForDataOnSource(100);
        S:=Trim(IOHandler.InputBufferAsString);
      except
      end;
      if Closing then Exit;
      if S <> '' then
      begin
        LogLine(S);
        if S='<policy-file-request/>' then
        begin
          CDP:=CrossDomainXML(45000);
          try
            IOHandler.Write(CDP+#0);
          except

          end;
          LogLine('cross domain security policy file sent');
        end;
      end
      else
      begin
         if Closing then Exit;
         Inc(Tick);
         if ((Tick mod 20) = 0) or (DataAvailable) then
         begin
            Tick:=0;
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
            try
              IOHandler.Write(SL.Text+#0);
            except

            end;
            Sl.Free;
         end;
      end;
    end;
    if Closing then Exit;
    LogLine('Disconnected.');
    if ((AContext <> nil) and (AContext.Connection <> nil)) then
    begin
      try
        I:=ConnectionList.IndexOf(AContext.Connection);
        if I >= 0 then
          ConnectionList.Delete(I);
      except

      end;
    end;
  end;
  except

  end;
end;

procedure TCommsController.Timer1Timer(Sender: TObject);
begin
  try
      if IdUDPServer1.Active then
    begin
      if DataAvailable then
         IdUDPServer1.Broadcast('VU.iT :'+IntToHex(MyIP,8)+'!'+MachineName,45001)
      else
         IdUDPServer1.Broadcast('VU.iT :'+IntToHex(MyIP,8)+' '+MachineName,45001);
    end;
  except

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
  Index,Value:Integer;
begin
  try
  RxString:=Copy(PChar(AData),1,High(AData)+1);
  LogLine('UDP:'+RxString);
  if Copy(RxString,1,7) = 'VU.iT :' then
  begin
    IPAddress:=Copy(RxString,8,8);
    Machine:=Copy(RxString,17,Length(RxString));
    dataStr:=Copy(RxString,16,1);
    if Machine <> MachineName then
    begin
      DecIP:=StrToIP(IPAddress);
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
  end;
  except
    LogLine('Exception in UDPRead');
  end;
end;


procedure TCommsController.CheckBox1Click(Sender: TObject);
begin
   if (CheckBox1.Checked and FileExists(LoggingPath+'\'+LoggingFile)) then
     DeleteFile(LoggingPath+'\'+LoggingFile);
end;

procedure TCommsController.ConnectDevice(Host:String;Port:Integer);
begin
  try
    IdTCPClient1.Host:=Host;
    IdTCPClient1.Port:=Port;
    IdTCPClient1.Connect;
  except
    LogLine('No connection to device');
  end;
end;

procedure TCommsController.DisconnectDevice;
begin
  try
    IdTCPClient1.Disconnect;
  except
  end;
end;
procedure TCommsController.SendCommand(Cmd:String);
var
   SL:TStringList;
begin
   SL:=TStringList.Create;
  try
    LogLine('Send Device Command: '+Cmd);
    SL.Add('<vuitControl>');
    SL.Add('  <command>'+Cmd+'</command>');
    SL.Add('</vuitControl>');
    if IdTCPClient1.IOHandler <> nil then
      IdTCPClient1.IOHandler.WriteLn(SL.Text);
  except
  end;
  SL.Free;
end;

procedure TCommsController.IdTCPClient1Connected(Sender: TObject);
begin
   LogLine('Device Connected');
   IsConnected:=True;
end;

procedure TCommsController.IdTCPClient1Disconnected(Sender: TObject);
begin
   LogLine('Device Disconnected');
   IsConnected:=False;
end;

procedure TCommsController.IdTCPClient1Status(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: string);
begin
    LogLine(AStatusText);
    if AStatusText='Disconnected.' then
      IsConnected:=False;
end;

procedure TCommsController.DeviceTimerTimer(Sender: TObject);
var
  S,RxData:String;
begin
  if DeviceTimer.Tag=1 then Exit;
  DeviceTimer.Tag:=1;
  try
    if (not IsConnected) or (IdTCPClient1.IOHandler = nil) then
    begin
      Inc(counter);
      if counter >  20 then
      begin
        counter:=0;
        LogLine('Attempt Connect to Device IP:'+DeviceIPAddress+' Port:'+IntToStr(DevicePortNumber));
        ConnectDevice(DeviceIPAddress,DevicePortNumber);
      end;
    end
    else
    begin
      try
        if IdTCPClient1.IOHandler <> nil then
        begin
          IdTCPClient1.IOHandler.CheckForDataOnSource(100);
          S:=Trim(IdTCPClient1.IOHandler.InputBufferAsString);
          if S <> '' then
          begin
            RxData:='';
            while S <> '' do
            begin
              RxData:=RxData+S;
              IdTCPClient1.IOHandler.CheckForDataOnSource(100);
              S:=Trim(IdTCPClient1.IOHandler.InputBufferAsString);
            end;
            ReceivedData.Add(RxData);
            LogDataToFile(RxData);
            LogLine('Device Data received');
          end;
        end;
      except
        try
          IdTCPClient1.Disconnect;
        except

        end;
        IsConnected:=false;
      end;
    end;
  finally
    DeviceTimer.Tag:=0;
  end;
end;

end.
