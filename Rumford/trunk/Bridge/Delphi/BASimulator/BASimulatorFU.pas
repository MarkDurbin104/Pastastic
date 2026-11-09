unit BASimulatorFU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, StdCtrls,
  ExtCtrls, ComCtrls, jpeg, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack,DIMimeStreams;

type
  TForm1 = class(TForm)
    IdTCPClient1: TIdTCPClient;
    Panel1: TPanel;
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    Edit2: TEdit;
    Label2: TLabel;
    Panel2: TPanel;
    Memo1: TMemo;
    Panel3: TPanel;
    Button3: TButton;
    Panel4: TPanel;
    Splitter1: TSplitter;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    DataMemo: TMemo;
    TabSheet2: TTabSheet;
    DataImage: TImage;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure IdTCPClient1Connected(Sender: TObject);
    procedure IdTCPClient1Disconnected(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    function ProcessImage(Text:String):String;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  IdTCPClient1.Host:=Edit1.Text;
  IdTCPClient1.Port:=StrToInt(Edit2.Text);
  IdTCPClient1.Connect;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  IdTCPClient1.Disconnect;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if IdTCPClient1.IOHandler <> nil then
    IdTCPClient1.IOHandler.WriteLn(Memo1.Text);
end;

procedure TForm1.IdTCPClient1Connected(Sender: TObject);
begin
   Button1.Enabled:=False;
   Button2.Enabled:=True;
   Button3.Enabled:=True;
   Edit1.Enabled:=False;
   Edit2.Enabled:=False;
end;

procedure TForm1.IdTCPClient1Disconnected(Sender: TObject);
begin
   Button1.Enabled:=True;
   Button2.Enabled:=False;
   Button3.Enabled:=False;
   Edit1.Enabled:=True;
   Edit2.Enabled:=True;
end;
procedure DecodeData(DataString,OutFile:String);
var
  FS:TFileStream;
  SS:TStringStream;
//  SL:TStringList;
  I:Integer;
begin
//  SL:=TStringList.Create;
//  SL.Text:=DataString;
  I:=Pos('base64',DataString);
  if I > 0  then
    SS:=TStringStream.Create(Copy(DataString,I+6,Length(DataString)))
  else
    SS:=TStringStream.Create(DataString);

//  for I := 2 downto 0 do
//    if (Pos('MIME',SL[I]) >= 0) or (Pos('Content',SL[I]) >= 0) or (Trim(SL[I]) = '') then SL.Delete(I);
//
//  SS:=TStringStream.Create(Trim(SL.Text));
  SS.Position:=0;

  if FileExists(OutFile) then DeleteFile(OutFile);
  FS:=TFileStream.Create(OutFile,fmCreate or fmOpenWrite or fmShareExclusive);
  MimeDecodeStream(SS,FS);

  FS.Free;
  SS.Free;
//  SL.Free;
end;
function TForm1.ProcessImage(Text:String):String;
var
  SL,ImageText:TStringList;
  I:Integer;
  StartL,EndL:Integer;
const
  ImageFile:String='C:\VU.iT\TempImage.jpg';
  DataFile:String='C:\VU.iT\TempVuitData.txt';
begin
  SL:=TStringList.Create;
  SL.Text:=Text;
  SL.SaveToFile(DataFile);
  while (SL.Count > 0) and (UpperCase(Trim(SL[0])) <> '<VUITRESULT>') do
    SL.Delete(0);
  while (SL.Count > 0) and (UpperCase(Trim(SL[SL.Count-1])) <> '</VUITRESULT>') do
    SL.Delete(SL.Count-1);
  Result:=Trim(SL.Text);
  StartL:=0;
  EndL:=0;
  for I := 0 to SL.Count - 1 do
  begin
    if Pos('<image>',SL[I]) > 0 then
      StartL:=I
    else if Pos('</image>',SL[I]) > 0 then
    begin
      EndL:=I;
      break;
    end;
  end;
  if ((StartL > 0) and (EndL > 0)) then
  begin
    ImageText:=TStringList.Create;
    for I := StartL+1 to EndL-1 do
    begin
      ImageText.Add(SL[I]);
    end;
    try
      DecodeData(ImageText.Text,ImageFile);
      if FileExists(ImageFile) then
      begin
        DataImage.Picture.LoadFromFile(ImageFile);
        PageControl1.TabIndex:=1;
//        DeleteFile(ImageFile);
      end;
    except
      ShowMessage('Image Decode Failed');
    end;
    ImageText.Free;
  end;
  SL.Free;
end;
procedure TForm1.Timer1Timer(Sender: TObject);
var
  S:String;
  SL:TStringList;
begin
  if IdTCPClient1.IOHandler <> nil then
  begin
    IdTCPClient1.IOHandler.CheckForDataOnSource(100);
    S:=Trim(IdTCPClient1.IOHandler.InputBufferAsString);
    if S <> '' then
    begin
      SL:=TStringList.Create;
      while S <> '' do
      begin
        SL.Add(S);
        IdTCPClient1.IOHandler.CheckForDataOnSource(10);
        S:=Trim(IdTCPClient1.IOHandler.InputBufferAsString);
      end;
      DataMemo.Lines.Text:=ProcessImage(SL.Text);
      SL.Free;
      PageControl1.Enabled:=True;
    end;
  end;
end;

end.
