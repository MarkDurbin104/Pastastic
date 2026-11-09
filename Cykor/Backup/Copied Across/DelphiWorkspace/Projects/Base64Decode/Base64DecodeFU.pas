unit Base64DecodeFU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdBaseComponent, IdCoder, IdCoder3to4, IdCoderMIME,DIMimeStreams,
  ExtCtrls, jpeg;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure DecodeFile(InFile,OutFile:String);
var
  FS:TFileStream;
  SS:TStringStream;
  SL:TStringList;
begin
  SL:=TStringList.Create;
  SL.LoadFromFile(InFile);
  SL.Delete(0); SL.Delete(0); SL.Delete(0); SL.Delete(0);
  SL.Delete(SL.Count-1);

  SS:=TStringStream.Create(Trim(SL.Text));
  SS.Position:=0;

  if FileExists(OutFile) then DeleteFile(OutFile);
  FS:=TFileStream.Create(OutFile,fmCreate or fmOpenWrite or fmShareExclusive);
  MimeDecodeStream(SS,FS);

  FS.Free;
  SS.Free;
  SL.Free;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Image1.Picture.LoadFromFile('C:\Treachery of Modelling.jpg');
  Image1.Refresh;
  DecodeFile('c:\VuitImage.txt','C:\TestFinal.jpg');
  Image1.Picture.LoadFromFile('C:\TestFinal.jpg');
end;

end.
