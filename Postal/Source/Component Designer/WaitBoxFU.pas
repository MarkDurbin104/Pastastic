unit WaitBoxFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;
const
  ImageWidth = 120;
type
  TWaitBox = class(TForm)
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    BitMap:TBitMap;
    SR:TRect;
    BO:Integer;
    BW:Integer;
  public
    { Public declarations }
  end;

var
  WaitBox: TWaitBox;

implementation

{$R *.DFM}

procedure DrawLogo(Canvas:TCanvas;XPos,YPos,Width,Angle:Integer);
var
   PolyPoints:Array[0..48+26] of TPoint;
   Rad:Integer;
   procedure FillPointArray(CX,CY,R,A:Integer);
   var
      I:Integer;
      X,Y:Integer;
      POfs:Integer;
   begin
      POfs:=0;
      CX:=CX+Trunc(R*sin((PI/180.0)*(135-A)));
      CY:=CY+Trunc(R*cos((PI/180.0)*(135-A)));
      for I:=18 to 63 do
      begin
         X:=CX+Trunc(R*sin((PI/180.0)*((I*5)-A)));
         Y:=CY+Trunc(R*cos((PI/180.0)*((I*5)-A)));
         PolyPoints[POfs]:=Point(X,Y);
         Inc(POfs);
      end;
      X:=X+Trunc(R*sin((PI/180.0)*(315-A)));
      Y:=Y+Trunc(R*cos((PI/180.0)*(315-A)));
      PolyPoints[POfs]:=Point(X,Y);
      Inc(POfs);
      X:=X+Trunc(R*sin((PI/180.0)*(225-A)));
      Y:=Y+Trunc(R*cos((PI/180.0)*(225-A)));
      PolyPoints[POfs]:=Point(X,Y);
      Inc(POfs);
      for I:=44 downto 18 do
      begin
         X:=CX+Trunc(R*sin((PI/180.0)*((I*5)-A)));
         Y:=CY+Trunc(R*cos((PI/180.0)*((I*5)-A)));
         PolyPoints[POfs]:=Point(X,Y);
         Inc(POfs);
      end;
   end;
begin
   Rad:=Trunc(Width/3.5);
   XPos:=XPos+(Width div 2);
   YPos:=YPos+(Width div 2);
   with Canvas do
   begin
      Pen.Width:=1;
      Brush.Color:=clMaroon;
      FillPointArray(XPos,YPos,Rad,Angle);
      PolyGon(PolyPoints);               
      Brush.Color:=clNavy;
      FillPointArray(XPos,YPos,Rad,180+Angle);
      PolyGon(PolyPoints);
   end;
end;
procedure TWaitBox.Timer1Timer(Sender: TObject);
begin
   if (Timer1.Tag mod 360) = 0 then
      Timer1.Interval:=1000
   else
      Timer1.Interval:=10;
   BitMap.Canvas.Brush.Color:=$00A68242;
   BitMap.Canvas.FillRect(SR);
   DrawLogo(BitMap.Canvas,BO,BO,BW,Timer1.Tag);
   Canvas.CopyRect(SR,BitMap.Canvas,SR);
   Timer1.Tag:=Timer1.Tag+10;
end;

procedure TWaitBox.FormCreate(Sender: TObject);
begin
   BitMap:=TBitMap.Create;
   ClientWidth:=ImageWidth;
   ClientHeight:=ImageWidth;
   SR:=Bounds(0,0,ImageWidth,ImageWidth);
   BitMap.Width:=ImageWidth;
   BitMap.Height:=ImageWidth;
   BO:=ImageWidth div 16;
   BW:=(ImageWidth*7) div 8;
end;

procedure TWaitBox.FormDestroy(Sender: TObject);
begin
   BitMap.Free;
end;

procedure TWaitBox.FormShow(Sender: TObject);
begin
   Timer1.Tag:=0;
   Timer1.Interval:=10;
   Timer1.Enabled:=True;
end;

end.
