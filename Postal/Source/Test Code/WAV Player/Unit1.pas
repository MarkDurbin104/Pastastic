unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  MPlayer, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
procedure PlayWAV(FileName:String);
var 
   MediaPlayer:TMediaPlayer;
begin
   MediaPlayer:=TMediaPlayer.Create(nil);
   Form1.InsertControl(MediaPlayer);
   MediaPlayer.FileName:=FileName;
   MediaPlayer.Open;
   MediaPlayer.Wait:=True;     
   MediaPlayer.Play;  
   MediaPlayer.Close;
   Form1.RemoveControl(MediaPlayer);
   MediaPlayer.Free;
end;
procedure TForm1.Button1Click(Sender: TObject);
begin
   PlayWAV('C:\WINDOWS\Media\tada.wav');
end;

end.
