unit TestHarmessFU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer,IdContext,IdIOHandler,
  StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    IdTCPServer1: TIdTCPServer;
    Memo1: TMemo;
    Button1: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Delay1: TEdit;
    Delay2: TEdit;
    Timer1: TTimer;
    Button2: TButton;
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
  public
    FIOHandler: TIdIOHandler;
    timerStep:Integer;
    AppPath:String;
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
procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if FIOHandler = nil then Exit;
  Inc(timerStep);
  timerStep :=timerStep mod 4;
  case (timerStep) of
      // the device needs to re-focus and reset its backgraound image and it
      // can't do that until no object is on the scale and nobody is in the viewable area.
    0 : FIOHandler.WriteLn('<vuitStatus>WAITING FOR OBJECT REMOVAL</vuitStatus>'+#0);
      // the device is focused and ready for an object
    1 : FIOHandler.WriteLn('<vuitStatus>IDLE</vuitStatus>'+#0);
      //the device is focused and currently tracking an object that was place on the scale.
    2 : FIOHandler.WriteLn('<vuitStatus>TRACKING OBJECT</vuitStatus>'+#0);
      // the system has locked on the object, it has sent the XML (1/3) if we are in progressive mode,
      // and it is about to embark on the high-resolution processing stages
    3 : FIOHandler.WriteLn('<vuitStatus>PROCESSING IMAGE</vuitStatus>'+#0);
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  SL:TStringList;
begin
  if FIOHandler = nil then Exit;
  if CheckBox1.Checked then
  begin
    FIOHandler.WriteLn('<vuitResult><status>FAIL</status><physicalAttributes><weight>0.2</weight><units>US</units></physicalAttributes></vuitResult>'+#0);
  end
  else if CheckBox2.Checked then
  begin
    SL:=TStringList.Create;
    SL.LoadFromFile(AppPath+'\ExternalEnvelope1.xml');
    FIOHandler.WriteLn(SL.Text);
    SL.Free;
  end
  else if CheckBox3.Checked then
  begin
    timerStep:=0;
    Timer1.Enabled:=true;
    sleep(StrToIntDef(Delay1.Text,2000));
    SL:=TStringList.Create;
    SL.LoadFromFile(AppPath+'\Joshua Crimonian - NY - 1 of 3.txt');
    FIOHandler.WriteLn(SL.Text);
    sleep(StrToIntDef(Delay1.Text,2000));
    SL.LoadFromFile(AppPath+'\Joshua Crimonian - NY - 2 of 3.txt');
    FIOHandler.WriteLn(SL.Text);
    sleep(StrToIntDef(Delay2.Text,2000));
    SL.LoadFromFile(AppPath+'\Joshua Crimonian - NY - 3 of 3.txt');
    FIOHandler.WriteLn(SL.Text);
    SL.Free;
    Timer1.Enabled:=false;
  end
  else
  begin
    SL:=TStringList.Create;
    SL.LoadFromFile(AppPath+'\EmbeddedImage.xml');
    FIOHandler.WriteLn(SL.Text);
    SL.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Timer1Timer(nil);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  AppPath:=ExtractFilePath(ParamStr(0));
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
        Button1Click(nil);
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
