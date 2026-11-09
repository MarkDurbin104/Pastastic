unit TestHarmessFU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer,IdContext,IdIOHandler,
  StdCtrls;

type
  TForm1 = class(TForm)
    IdTCPServer1: TIdTCPServer;
    Memo1: TMemo;
    Button1: TButton;
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure Button1Click(Sender: TObject);
  private
  public
    FIOHandler: TIdIOHandler;
    procedure LogLine(s:String);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
procedure TForm1.LogLine(s:String);
begin
  Memo1.Lines.Add(S);
end;
procedure TForm1.Button1Click(Sender: TObject);
var
  SL:TStringList;
begin
  if FIOHandler = nil then Exit;
  SL:=TStringList.Create;
  SL.LoadFromFile('C:\VuitResult.txt');
  FIOHandler.WriteLn(SL.Text);
  SL.Free;
end;

procedure TForm1.IdTCPServer1Execute(AContext: TIdContext);
var
  S:String;
begin
  with AContext.Connection do begin
    if Connected then
        LogLine('Connected...');
    while Connected do begin
      FIOHandler:=IOHandler;
      IOHandler.CheckForDataOnSource(100);
      S:=Trim(IOHandler.InputBufferAsString);
      if S <> '' then
      begin
        LogLine(S);
        //IOHandler.Write(S+#0);
      end
      else
      begin
      end;
    end;
    FIOHandler:=nil;
    if not Connected then
      LogLine('Disconnected.');
  end;
end;

end.
