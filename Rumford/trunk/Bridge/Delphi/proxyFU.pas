unit proxyFU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdIntercept, IdServerInterceptLogBase,
  IdServerInterceptLogEvent, IdServerIOHandler, IdServerIOHandlerSocket,
  IdServerIOHandlerStack, IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdTCPServer, IdCmdTCPServer, IdHTTPProxyServer, ExtCtrls;

type
  TForm1 = class(TForm)
    IdHTTPProxyServer1: TIdHTTPProxyServer;
    IdServerIOHandlerStack1: TIdServerIOHandlerStack;
    IdServerInterceptLogEvent1: TIdServerInterceptLogEvent;
    Memo1: TMemo;
    Timer1: TTimer;
    Button1: TButton;
    procedure IdServerInterceptLogEvent1LogString(
      ASender: TIdServerInterceptLogEvent; AText: string);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  SL:TStringList;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
   SL.Clear;
   Memo1.Lines.Clear;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SL:=TStringList.Create;
end;

procedure TForm1.IdServerInterceptLogEvent1LogString(
  ASender: TIdServerInterceptLogEvent; AText: string);
begin
//    Memo1.Lines.BeginUpdate();
    Memo1.Lines.Add(AText);
//    Memo1.Lines.EndUpdate();
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
{  if SL.Count <> Memo1.Lines.Count then
  begin
    Memo1.Lines.BeginUpdate();
    Memo1.Lines.Text:=SL.Text;
    Memo1.Lines.EndUpdate();
  end;}
end;

end.
