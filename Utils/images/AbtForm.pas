unit AbtForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TAbout = class(TForm)
    Label2: TLabel;
    Button1: TButton;
    Image1: TImage;
    Timer1: TTimer;
    Image2: TImage;
    Bevel1: TBevel;
    copylab: TLabel;
    Image3: TImage;
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
   ImageOfs:Integer;
   ImDir:Integer;
  public
    { Public declarations }
  end;

var
  About: TAbout;

implementation

{$R *.DFM}

procedure TAbout.Timer1Timer(Sender: TObject);
var
   r1,r2:TRect;
begin
   if Imdir = 0 then
      Inc(ImageOfs) 
   else                          
      Dec(ImageOfs);
   Timer1.Interval:=10;
   if ImageOfs = 3 then begin Timer1.Interval:=400; ImDir:=1; end;
   if ImageOfs = 0 then begin Timer1.Interval:=400; ImDir:=0; end;
   r1.Left  :=100+ImageOfs*99;
   r1.Right :=100+ImageOfs*99+99;
   r1.Top   :=0 ;
   r1.Bottom:=80;
   r2.Left  :=0;
   r2.Right :=99;
   r2.Top   :=0 ;
   r2.Bottom:=80;
   Image1.Picture.Bitmap.Canvas.CopyRect(r2,Image1.Picture.Bitmap.Canvas,r1);
end;

procedure TAbout.FormShow(Sender: TObject);
begin
   ImageOfs:=0;
   ImDir:=0;
   copylab.caption:='Copyright ' + #169 + ' 1996 P.S.L';
end;

end.
 