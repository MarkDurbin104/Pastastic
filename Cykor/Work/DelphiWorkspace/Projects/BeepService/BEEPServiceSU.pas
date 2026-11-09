unit BEEPServiceSU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  IdIntercept, IdServerInterceptLogBase, IdServerInterceptLogEvent,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdCustomHTTPServer, IdContext,
  IdHTTPServer;

type
  TSparkyThread = class(TThread)
  public
    procedure Execute; override;
  end;

  TBeep = class(TService)
    IdHTTPServer1: TIdHTTPServer;
    IdServerInterceptLogEvent1: TIdServerInterceptLogEvent;
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  private
    FHTMLDir:String;
    SparkyThread:TSparkyThread;
  public
    function GetServiceController: TServiceController; override;
  end;

var
  Beep1: TBeep;

implementation

{$R *.DFM}
procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  Beep1.Controller(CtrlCode);
end;

{TBeep1}
function TBeep.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

{TSparkyThread}
procedure TSparkyThread.Execute;
begin
  while not Terminated do
  begin
    Beep;
    Sleep(5000);
  end;
end;

procedure TBeep.IdHTTPServer1CommandGet(AContext: TIdContext;
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
  end
  else
  begin
    AResponseInfo.ResponseNo := 404;
    AResponseInfo.ContentText := 'The requested URL ' + ARequestInfo.Document + ' was not found on this server.';
  end;
end;

procedure TBeep.ServiceContinue(Sender: TService; var Continued: Boolean);
begin
  IdHTTPServer1.Active:=True;
  SparkyThread.Resume;
  Continued := True;
end;

procedure TBeep.ServicePause(Sender: TService; var Paused: Boolean);
begin
  IdHTTPServer1.Active:=False;
  SparkyThread.Suspend;
  Paused := True;
end;

procedure TBeep.ServiceStart(Sender: TService; var Started: Boolean);
begin
  FHTMLDir := 'C:\VU.iT\HTML';
  IdHTTPServer1.Active:=True;
  SparkyThread := TSparkyThread.Create(False);
  Started := True;
end;

procedure TBeep.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  IdHTTPServer1.Active:=False;
  SparkyThread.Terminate;
  Stopped := True;
end;

end.
