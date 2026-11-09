unit TransparentMainFU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, StdCtrls, ExtCtrls, ComCtrls,TransparentFU,WinSock,
  IdContext,IdTCPConnection,IdBaseComponent, IdComponent, IdCustomTCPServer, IdCustomHTTPServer,
  IdHTTPServer, IdTCPServer, IdUDPBase, IdUDPClient, IdTimeUDP;

type
  TMainForm = class(TForm)
    WebBrowser1: TWebBrowser;
    TopPanel: TPanel;
    TrackBar2: TTrackBar;
    ILabel: TLabel;
    ColorListBox1: TColorListBox;
    TLabel: TLabel;
    TrackBar1: TTrackBar;
    Button1: TButton;
    HButton: TButton;
    IdHTTPServer: TIdHTTPServer;
    IdTCPServer: TIdTCPServer;
    ExitTimer: TTimer;
    IdTimeUDP1: TIdTimeUDP;
    procedure ColorListBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure HButtonClick(Sender: TObject);
    procedure IdHTTPServerCommandGet(AContext: TIdContext;ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure IdTCPServerExecute(AContext: TIdContext);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ExitTimerTimer(Sender: TObject);
  private
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message wm_NCHitTest;
    procedure SetClickThrough;
    function CrossDomainXML(port:Integer):String;
  public
    FirstShow:Boolean;
    FHTMLDir: String;
    Closing:Boolean;
    ConnectionList:TList;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.SetClickThrough;
var
  AStyle: Integer;
begin
  AStyle := GetWindowLong(BGForm.Handle, GWL_EXSTYLE);
  if (AStyle and (WS_EX_TRANSPARENT or WS_EX_LAYERED)) <> (WS_EX_TRANSPARENT or WS_EX_LAYERED) then
  begin
    SetWindowLong(BGForm.Handle, GWL_EXSTYLE, AStyle or (WS_EX_TRANSPARENT or WS_EX_LAYERED));
  end;
end;
procedure TMainForm.Button1Click(Sender: TObject);
begin
  BGForm.Close;
end;

procedure TMainForm.ColorListBox1Click(Sender: TObject);
begin
  BGForm.Color:=ColorListBox1.Selected;
  SetClickThrough();
end;


procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  I: Integer;
  Connection:TIdTCPConnection;
begin
   try
     Action:=caFree;

     Closing:=True;

     IdHTTPServer.Active:=False;

     try
       IdTCPServer.Active:=False;
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

procedure TMainForm.FormCreate(Sender: TObject);
begin
//  Width:=Screen.Width div 2;
  Width:=830;//1280 div 2;
  Height:=654;//(Width*3) div 4;
  Left:=(Screen.Width-Width)-Width div 15;
  Top:=Width div 15;
//  SetWindowRgn(Handle,CreateRoundRectRgn(2,2,Width-2,Height-2,(Height * 3) div 10,(Height * 3) div 10),true);
  SetWindowRgn(Handle,CreateRoundRectRgn(2,2,Width-1,Height-1,2,2),true);
  ConnectionList:=TList.Create;
  FirstShow:=True;
  Closing:=False;
  //IdTimeUDP1.Host:='time-a.nist.gov';
  //IdTimeUDP1.ReceiveTimeout:=5000; // wait max 5 seconds
  //IdTimeUDP1.SyncTime;
  FHTMLDir:=ExtractFilePath(ParamStr(0))+'\HTML\';
  IdHTTPServer.Active:=True;
  IdTCPServer.Active:=True;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
   if FirstShow then
   begin
     TopPanel.Visible:=False;
     WebBrowser1.Navigate('http://127.0.0.1:8000/bg.html');
     while WebBrowser1.Busy do
       Application.ProcessMessages;
     sleep(1000);
     WebBrowser1.Navigate('http://127.0.0.1:8000/index.html');
     WebBrowser1.Visible:=True;
     FirstShow:=False;
   end;
   SetClickThrough();
end;

procedure TMainForm.HButtonClick(Sender: TObject);
begin
   TopPanel.Visible:=not TopPanel.Visible;
   if TopPanel.Visible then
      HButton.Caption:='Hide'
   else
      HButton.Caption:='Show';
end;

procedure TMainForm.TrackBar1Change(Sender: TObject);
begin
  BGForm.AlphaBlendValue:=TrackBar1.Position;
  TLabel.Caption:='Transparency = '+IntToStr(Round(BGForm.AlphaBlendValue/2.55))+'%';
end;

procedure TMainForm.TrackBar2Change(Sender: TObject);
begin
  BGForm.IdleTime:=TrackBar2.Position*1000;
  ILabel.Caption:='Idle Time = '+IntToStr(TrackBar2.Position)+' Seconds';
end;

procedure TMainForm.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;
  if Msg.Result = htClient then
    Msg.Result := htCaption;
end;
function GetLocalMachineName:String;
var
   Length:DWord;
begin
  try
     Length:=MAX_COMPUTERNAME_LENGTH+1;
     SetLength(Result,Length);
     GetComputerName(PChar(Result),Length);
     SetLength(Result,Length);
  except
    //LogLine('Exception in GetLocalMachine');
  end;
end;
function GetIPAddress(MachineName:String):Integer;
var
  HostEnt: PHostEnt;
//  S:String;
  IPAddress:Integer;
begin
  try
//    S:=GetLocalMachineName;
    IPAddress:=0;
    HostEnt:=WinSock.gethostbyname(PChar(MachineName));
    if HostEnt <> nil then
       IPAddress:=(Integer(HostEnt^.h_addr^[0]) shl 24) or
                  (Integer(HostEnt^.h_addr^[1]) shl 16) or
                  (Integer(HostEnt^.h_addr^[2]) shl  8) or
                  (Integer(HostEnt^.h_addr^[3]) shl  0);
  except
     IPAddress:=$7F000001;
     //LogLine('Could not resolve host, using 127.0.0.1');
  end;
  Result:=IPAddress;
end;
function HexToDec(Str:String):String;
begin
  Result:=IntToStr(StrToInt('$'+Str));
  while Length(Result) < 3 do
    Result:='0'+Result;
end;
function StrToIP(Str:String):String;
begin
  Result:=HexToDec(Copy(Str,1,2))+'.'+HexToDec(Copy(Str,3,2))+'.'+HexToDec(Copy(Str,5,2))+'.'+HexToDec(Copy(Str,7,2));
end;
function LocalIPAddress:String;
begin
  Result:=StrToIP(IntToHex(GetIPAddress(GetLocalMachineName),8));
end;
function TMainForm.CrossDomainXML(port:Integer):String;
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
    SL.Add('    <allow-access-from domain="localhost" to-ports="80,8000,45001,45000" />');
    SL.Add('    <allow-access-from domain="127.0.0.1" to-ports="80,8000,45001,45000" />');
    SL.Add('  </cross-domain-policy>');
    result:=SL.Text;
    SL.Free;
end;
procedure TMainForm.ExitTimerTimer(Sender: TObject);
begin
   BGForm.Close;
end;

procedure TMainForm.IdHTTPServerCommandGet(AContext: TIdContext;ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  LFilename: string;
  LPathname: string;
  //SL:TStringList;
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
    //LogDataToFile(S);
    AResponseInfo.ContentStream := SS;
    //LogLine('cross domain security policy file sent');
  end
  else
  begin
    if LFilename = '/' then
    begin
      LFilename := '/index.html';
    end;
    {if Copy(LFilename,1,2) = '//' then
    begin
      LPathname := Copy(LFilename,3,Length(LFilename));
    end else}
    begin
      LPathname := FHTMLDir + LFilename;
    end;
    if FileExists(LPathname) then
    begin
      FS:=TFileStream.Create(LPathname, fmOpenRead + fmShareDenyWrite);
      AResponseInfo.ContentStream := FS;
    end
    else
    begin
      AResponseInfo.ResponseNo := 404;
      AResponseInfo.ContentText := 'The requested URL ' + ARequestInfo.Document + ' was not found on this server.';
    end;
  end;
  except
    //LogLine('Exception in HttpServerGet');
  end;
end;


function CopyInt(S:String;Offset:Integer=1):Integer;
var
  I:Integer;
  Return:String;
begin
  Return:='';
  I:=Offset;
  while (I < Length(S)) and (S[I] in ['0'..'9']) do
  begin
    Return:=Return+S[I];
    Inc(I);
  end;
  Result:=StrToIntDef(Return,0);
end;
procedure TMainForm.IdTCPServerExecute(AContext: TIdContext);
var
  S:String;
  CDP:String;
  //SL:TStringList;
  I: Integer;
  ColValue:Integer;
begin
  //Tick:=0;
  if ((AContext = nil) or (AContext.Connection = nil) or (AContext.Connection.IOHandler = nil)) then Exit;
  try
    if ConnectionList.IndexOf(AContext.Connection) < 0 then
      ConnectionList.Add(AContext.Connection);
    with AContext.Connection do
    begin
      //if Connected then LogLine('Connected...');
      while ((AContext <> nil) and (AContext.Connection <> nil) and (Connected) and (IOHandler <> nil)) do
      begin
        if Closing then Exit;
        try
          IOHandler.CheckForDataOnSource(100);
          S:=Trim(IOHandler.InputBufferAsString);
        except
        end;
        if Closing then Exit;
        if S <> '' then
        begin
          //LogLine(S);
          if S='<policy-file-request/>' then
          begin
            CDP:=CrossDomainXML(45000);
            try
              IOHandler.Write(CDP+#0);
            except

            end;
          end
          else if S='<exit/>' then
          begin
            ExitTimer.Enabled:=True;
          end
          else if Copy(S,1,6)='<color' then
          begin
             ColValue:=CopyInt(S,15);
             // swap RGB to BGR
             BGForm.Color:=((ColValue and $FF) shl 16) or (ColValue and $FF00) or ((ColValue and $FF0000) shr 16);
             SetClickThrough();
          end
          else if Copy(S,1,13)='<transparency' then
          begin
            BGForm.AlphaBlendValue:=Round(CopyInt(S,22)*2.55);
            TrackBar1.Position:=BGForm.AlphaBlendValue;
            TLabel.Caption:='Transparency = '+IntToStr(Round(BGForm.AlphaBlendValue/2.55))+'%';
          end
          else if Copy(S,1,9)='<idletime' then
          begin
            TrackBar2.Position:=CopyInt(S,18);
            BGForm.IdleTime:=TrackBar2.Position*1000;
            ILabel.Caption:='Idle Time = '+IntToStr(TrackBar2.Position)+' Seconds';
          end
          else if Copy(S,1,9)='<datetime' then
          begin
            IOHandler.Write('<datetime value="'+FormatDateTime('yy/mm/dd hh:nn:ss.zzz',IdTimeUDP1.DateTime)+'"/>'+#0);
          end;
        end
        else
        begin
           if Closing then Exit;
        end;
      end;
      if Closing then Exit;
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

end.
