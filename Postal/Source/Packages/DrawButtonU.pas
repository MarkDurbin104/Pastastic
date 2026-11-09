unit DrawButtonU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;
  
procedure DrawButtonBG(Canvas:TCanvas;R:TRect;Color:TColor;BevelWidth,ColourDepth:Integer;IsDown:Boolean;ShadowLength:Integer);

implementation
  
function CalcColor(Color:TColor;Offset,Mag:Integer):TColor;
var
   R,G,B:Integer;
begin
   Color:=ColorToRGB(Color);
   B:=(Color and $FF0000) shr 16;
   G:=(Color and $00FF00) shr 8;
   R:=(Color and $0000FF);
   if R+Offset*Mag > 255 then R:=255 else if R+Offset*Mag < 0 then R:=0 else R:=R+Offset*Mag;
   if G+Offset*Mag > 255 then G:=255 else if G+Offset*Mag < 0 then G:=0 else G:=G+Offset*Mag;
   if B+Offset*Mag > 255 then B:=255 else if B+Offset*Mag < 0 then B:=0 else B:=B+Offset*Mag;
   Result:=RGB(R,G,B);
end;
procedure DrawRim(Canvas:TCanvas;R:TRect;LTColor,BRColor:TColor;IsDown:Boolean);
begin
   with Canvas do
   begin
      with R do
      begin
         Pen.Color:=LTColor;
         if not IsDown then
         begin
            Brush.Color:=LTColor;
            PolyLine([Point(Left,Bottom),Point(Left,Top),Point(Right,Top)]);
         end;
         Pen.Color:=BRColor;
         PolyLine([Point(Right,Top),Point(Right,Bottom),Point(Left,Bottom)]);
      end;
   end;
end;
procedure DrawButtonBG(Canvas:TCanvas;R:TRect;Color:TColor;BevelWidth,ColourDepth:Integer;IsDown:Boolean;ShadowLength:Integer);
var
   I:Integer;
begin
   with Canvas do
   begin
      Brush.Color:=CalcColor(Color,0,ColourDepth);
      if IsDown then
         FillRect(R);
      R.Bottom:=R.Bottom-ShadowLength;
      R.Right:=R.Right-ShadowLength;
      if IsDown then
      begin
         InflateRect(R,-2,-2);
         Color:=CalcColor(Color,-1,3);
      end
      else
      begin
         Pen.Color:=CalcColor(Color,0-BevelWidth div 2,ColourDepth);
         with R do
            for I:=0 to ShadowLength-1 do
               PolyLine([Point(Left+I,Bottom+I),Point(Right+I,Bottom+I),Point(Right+I,Top+I)]);
      end;
      FillRect(R);
      for I:=0 to (BevelWidth div 2) do
      begin
         DrawRim(Canvas,R,CalcColor(Color,(BevelWidth div 2)-I,ColourDepth),CalcColor(Color,(0-(BevelWidth div 2))+I,ColourDepth),False);
         InflateRect(R,-1,-1);
      end;
      InflateRect(R,1,1);
      Brush.Color:=CalcColor(Color,0,ColourDepth);
      FillRect(R);
   end;
end;

end.
