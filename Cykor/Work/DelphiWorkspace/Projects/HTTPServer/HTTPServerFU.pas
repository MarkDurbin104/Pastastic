unit HTTPServerFU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdIntercept, IdServerInterceptLogBase,
  IdServerInterceptLogEvent, IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdCustomHTTPServer, IdHTTPServer,ShellAPI,IdContext, IdServerInterceptLogFile,
  IdServerIOHandler, IdServerIOHandlerSocket, IdServerIOHandlerStack,
  IdTCPConnection, IdTCPClient, IdHTTP, IdTCPServer, IdCmdTCPServer,
  IdHTTPProxyServer, ExtCtrls;

type
  TForm1 = class(TForm)
    IdHTTPServer1: TIdHTTPServer;
    Memo1: TMemo;
    Memo2: TMemo;
    IdHTTPProxyServer1: TIdHTTPProxyServer;
    IdServerInterceptLogEvent1: TIdServerInterceptLogEvent;
    Splitter1: TSplitter;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure IdServerInterceptLogEvent1LogString(
      ASender: TIdServerInterceptLogEvent; AText: string);
  private
    FHTMLDir:String;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  WinExec(PAnsiChar('E:\Program Files\Mozilla Firefox\firefox.exe http://127.0.0.1:8000/'),SW_SHOW);
  ShellAPI.ShellExecute(Handle, PChar('open'), 'http://127.0.0.1:8000/', nil, nil, 0);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 FHTMLDir := ExtractFilePath(Application.ExeName) + 'HTML';
end;

procedure TForm1.IdHTTPServer1CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  LFilename: string;
  LPathname: string;
begin
  LFilename := ARequestInfo.Document;
  if LFilename = '/' then
  begin
    LFilename := '/index.html';
  end;
  LPathname := FHTMLDir + LFilename;
  if FileExists(LPathname) then
  begin
    AResponseInfo.ContentStream := TFileStream.Create(LPathname, fmOpenRead + fmShareDenyWrite);
    Memo1.Lines.Add('OK:'+LPathname);
  end
  else
  begin
    Memo1.Lines.Add('ERROR: '+LPathname);
    AResponseInfo.ResponseNo := 404;
    AResponseInfo.ContentText := 'The requested URL ' + ARequestInfo.Document + ' was not found on this server.';
  end;
end;

procedure TForm1.IdServerInterceptLogEvent1LogString(
  ASender: TIdServerInterceptLogEvent; AText: string);
begin
   Memo2.Lines.Add(AText);
end;

end.
