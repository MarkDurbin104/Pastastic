unit KGButton;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,StretchU{, Dialogs};

type
  TKGButton = class(TGraphicControl)
  private
    FRightAnchor:Boolean;
    FShowGlyph:Boolean;
    FAdjR:Integer;
    FAdjG:Integer;
    FAdjB:Integer;
    FGlyph:TBitmap;
    FUpBitMap:TBitmap;
    FDownBitMap:TBitmap;
    FToggleWhenClicked:Boolean;
    FTouchButton:Boolean;
    FButtonIsUp:Boolean;
    FIsAvailable:Boolean;
    FShowPrice:Boolean;
    FFlashing:Boolean;
    FKeyName:String;
    FPrice:String;
    FShowLED:Boolean;
    FUseFontColor:Boolean;
    FPictureIndex:Integer;
  protected
    procedure SetKeyName   (Value:String);
    procedure SetPrice     (Value:String);
    procedure SetGlyph     (Value:TBitmap);
    procedure SetUpBitMap  (Value:TBitmap);
    procedure SetDownBitMap(Value:TBitmap);
    procedure SetButtonIsUp(Value:Boolean);
    procedure SetIsAvailable(Value:Boolean);
    procedure SetFlashing   (Value:Boolean);
    procedure SetToggleWhenClicked(Value:Boolean);
    procedure SetTouchButton(Value:Boolean);
    procedure SetAdjColor(Index:Integer;Value:Integer);
    procedure SetRightAnchor(Value:Boolean);
    procedure SetShowGlyph(Value:Boolean);
    procedure Click; override;
  public
    procedure Invalidate; override;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
    procedure ForceClick;
    property PictureIndex:Integer read FPictureIndex write FPictureIndex;
  published 
    property ParentFont;
    property Font;
    property Caption;
    property Glyph            :TBitmap read FGlyph             write SetGlyph          ;
    property UpBitMap         :TBitmap read FUpBitMap        write SetUpBitMap       ;
    property DownBitMap       :TBitmap read FDownBitMap      write SetDownBitMap     ;
    property ToggleWhenClicked:Boolean read FToggleWhenClicked write SetToggleWhenClicked;
    property TouchButton      :Boolean read FTouchButton write SetTouchButton;
    property ButtonIsUp       :Boolean read FButtonIsUp        write SetButtonIsUp     ;
    property IsAvailable      :Boolean read FIsAvailable       write SetIsAvailable    ;
    property ShowPrice        :Boolean read FShowPrice         write FShowPrice        ;
    property KeyName          :String  read FKeyName           write SetKeyName        ;
    property Price            :String  read FPrice             write SetPrice          ;
    property Flashing         :Boolean read FFlashing          write SetFlashing       ;
    property AdjRed           :Integer index 0 read FAdjR      write SetAdjColor       ;
    property AdjGreen         :Integer index 1 read FAdjG      write SetAdjColor       ;
    property AdjBlue          :Integer index 2 read FAdjB      write SetAdjColor       ;
    property OnClick;
    property RightAnchor :Boolean  read FRightAnchor write SetRightAnchor;
    property ShowGlyph   :Boolean  read FShowGlyph   write SetShowGlyph  ;
    property ShowLED:Boolean      read FShowLED write FShowLED default True; 
    property UseFontColor:Boolean read FUseFontColor write FUseFontColor default False; 
  end;

procedure Register;
function  AdjustColor(BitMap:TBitMap;R,G,B:Integer):THandle;

implementation
{TKGButton}
function AdjustColor(BitMap:TBitMap;R,G,B:Integer):THandle;
type
   TRGBList = packed array[0..0] of packed record B,G,R:Byte; end;
   PRGBList = ^TRGBList;
   procedure LimitInc(var Val:Byte;Ofs:Integer);
   begin
      if (Integer(Val)+Ofs < 256) and (Integer(Val)+Ofs > 0) then Inc(Val,Ofs);
   end;
var
   I,J:Integer;
   Line:PRGBList;
begin
   Result:=0;
   if Bitmap = nil then Exit;
   Result:=Bitmap.Handle; // force bitmap update 
   if (R = 0) and (G = 0) and (B = 0) then Exit;
   Bitmap.PixelFormat:=pf24bit;
   for I:=0 to Bitmap.Height-1 do
   begin
      Line:=Bitmap.ScanLine[I];
      for J:=0 to Bitmap.Width-1 do
      begin
         LimitInc(Line[J].R,R); LimitInc(Line[J].G,G); LimitInc(Line[J].B,B);
      end;
   end;
end;
procedure TKGButton.Click;
begin
   if not FToggleWhenClicked then
   begin
      ButtonIsUp:=False;
      Refresh;
      inherited Click;
      ButtonIsUp:=True;
   end
   else
      inherited Click;
end;   
procedure TKGButton.Invalidate;
var
   R:TRect;
begin
    if (Parent = nil) or (not Visible) then Exit;
    R:=BoundsRect;
    if ((R.Bottom-R.Top) <> 0) and ((R.Right-R.Left) <> 0) then
       InvalidateRect(Parent.Handle,@R,False);
end;
procedure TKGButton.SetAdjColor(Index:Integer;Value:Integer);
begin
   case Index of
      0 : if FAdjR <> Value then
          begin
              if not (csLoading in ComponentState) then
              begin
                 AdjustColor(FUpBitmap  ,Value-FAdjR,0,0);
                 AdjustColor(FDownBitmap,Value-FAdjR,0,0);
              end;
              FAdjR:=Value;
              Invalidate;
          end;
      1 : if FAdjG <> Value then
          begin
              if not (csLoading in ComponentState) then
              begin
                 AdjustColor(FUpBitmap  ,0,Value-FAdjG,0);
                 AdjustColor(FDownBitmap,0,Value-FAdjG,0);
              end;
              FAdjG:=Value;
              Invalidate;
          end;
      2 : if FAdjB <> Value then
          begin
              if not (csLoading in ComponentState) then
              begin
                 AdjustColor(FUpBitmap  ,0,0,Value-FAdjB);
                 AdjustColor(FDownBitmap,0,0,Value-FAdjB);
              end;
              FAdjB:=Value;
              Invalidate;
          end;
   end;
end;
function Opposite(Value:TColor):TColor;
var
   R1,G1,B1:Integer;
   R2,G2,B2:Integer;
begin
   B1:=(Value shr 16) and $FF;
   G1:=(Value shr  8) and $FF;
   R1:=(Value       ) and $FF;
   R2:=255-R1; 
   G2:=255-G1; 
   B2:=255-B1; 
   // foreground and background colours too close
   if  (Abs(R2-R1) < 40) and (Abs(G2-G1) < 40) and (Abs(B2-B1) < 40) then
   begin
     if R1 < 128 then // is background dark ?
     begin 
        R2:=255; G2:=255; B2:=255; // set foreground to white
     end
     else 
     begin 
        R2:=0; G2:=0; B2:=0; // else set foreground to Black
     end;
   end;
   Result:=RGB(R2,G2,B2);
end;
function Adjust(Value:TColor;Amount:Integer):TColor;
begin
   Result:=RGB(( ColorToRGB(Value)         and $FF)+Amount,
               ((ColorToRGB(Value) shr 8 ) and $FF)+Amount,
               ((ColorToRGB(Value) shr 16) and $FF)+Amount);
end;
procedure TKGButton.SetShowGlyph(Value:Boolean);
begin
   if FShowGlyph <> Value then
   begin
      FShowGlyph:=Value;
      Invalidate;
   end;
end;
procedure TKGButton.SetRightAnchor(Value:Boolean);
begin
   if FRightAnchor <> Value then
   begin
      FRightAnchor:=Value;
      Invalidate;
   end;
end;
procedure TKGButton.Paint;
var
   Dest:TRect;
   H:Integer;
   FC,DFC:TColor;
   ABitMap:TBitMap;
begin             
   ABitMap:=TBitMap.Create;
   ABitMap.Width:=Width;
   ABitMap.Height:=Height;
   
   FC:=Opposite(FUpBitmap.Canvas.Pixels[0,0]);
   DFC:=Adjust(FC,-30);
   ABitMap.Canvas.Font:=Font;
   with ABitMap.Canvas do
   begin
      if FRightAnchor then SetTextAlign(ABitMap.Canvas.Handle,TA_RTLREADING);
      if FUpBitMap.Width > 0 then
      begin
         if ButtonIsUp then
         begin
            CopyRect(Bounds(0,0,Width,Height),FUpBitmap.Canvas,Bounds(0,0,Width,Height));
            if FKeyName <> '' then
            begin
               if FIsAvailable and (Caption <> ' ') then
                  Pen.Color:=FC //RGB(255,239,191)
               else
                  Pen.Color:=DFC; //RGB(128,120,95);
               if FKeyName = 'DOWN' then
                  PolyLine([Point(Width-16,10),Point(Width-16,20),Point(Width-14,15),Point(Width-18,15),Point(Width-16,20)])
               else if FKeyName = 'UP' then
                  PolyLine([Point(Width-16,20),Point(Width-16,10),Point(Width-14,15),Point(Width-18,15),Point(Width-16,10)])
               else
               begin
                  Brush.Style:=bsClear;
                  if not FUseFontColor then
                  begin
                     if FIsAvailable and (Caption <> ' ') then
                        Font.Color:=FC //RGB(255,239,191)
                     else
                        Font.Color:=DFC; //RGB(128,120,95);
                  end;
                  TextOut(Width-(13+TextWidth('8888')),8,FKeyName);
                  Brush.Style:=bsSolid;
               end;              
            end;
            if FShowPrice and FIsAvailable and (FPrice <> '') then
            begin
               Brush.Style:=bsClear;
               if not FUseFontColor then
                  Font.Color:=clWhite;
               TextOut((Width-TextWidth(FPrice)) div 2,5,FPrice);
               Brush.Style:=bsSolid;
            end;
            if FIsAvailable then
            begin
               if (FShowGlyph) and (FGlyph.Width <> 0) then
               begin
                  // Need to adjust bounds for a Large Glyph !!!
                  if FShowPrice then
                     Dest:=Bounds((Width-FGlyph.Width) div 2,TextHeight('Wg')+3,FGlyph.Width,FGlyph.Height)
                  else
                     Dest:=Bounds((Width-FGlyph.Width) div 2,7,FGlyph.Width,FGlyph.Height);
                  PlaceGlyphAt(ABitMap.Canvas,Dest,FGlyph);
               end;
               if FFlashing then
                  Brush.Color:=clRed
               else if Caption = ' ' then
                  Brush.Color:=FUpBitmap.Canvas.Pixels[0,0]
               else
                  Brush.Color:=FC; //clLime;
               Pen.Color:=clBlack;
            end
            else
            begin
               Brush.Color:=FUpBitmap.Canvas.Pixels[0,0];
               Pen.Color:=clBlack;
            end;
            if FShowLED then Ellipse(10,8,17,15);
            if Caption <> '' then
            begin
               Brush.Style:=bsClear;
               if FRightAnchor then  
                  Font.Size:=Font.Size+4
               else
                  Font.Size:=Font.Size+1;
               if not FUseFontColor then
               begin
                  if FIsAvailable and (Caption <> ' ') then
                     Font.Color:=FC //RGB(255,239,191)
                  else
                     Font.Color:=DFC; //RGB(128,120,95);
               end;
               Dest:=Rect(0,0,Width-24,Height);
               H:=DrawText(ABitMap.Canvas.Handle,PChar(Caption),Length(Caption),Dest,DT_CENTER or DT_CALCRECT or DT_WORDBREAK);
               if FShowGlyph then
                  Dest:=Rect(11,(Height-11)-H,Width-13,Height-11)
               else
                  Dest:=Rect(11,((Height-H) div 2),Width-13,((Height-H) div 2)+H);
               DrawText(ABitMap.Canvas.Handle,PChar(Caption),Length(Caption),Dest,DT_CENTER or DT_WORDBREAK);
         
               Brush.Style:=bsSolid;
            end;                       
         end
         else
         begin
            CopyRect(Bounds(0,0,Width,Height),FDownBitmap.Canvas,Bounds(0,0,Width,Height));
            Brush.Color:=clRed;
            Pen.Color:=clBlack;
            if FShowLED then Ellipse(15,12,22,19);
            if FKeyName <> '' then
            begin
               if FKeyName = 'DOWN' then
               begin
                  Pen.Color:=FC;
                  PolyLine([Point(Width-16,10),Point(Width-16,20),Point(Width-14,15),Point(Width-18,15),Point(Width-16,20)]);
               end
               else if FKeyName = 'UP' then
               begin
                  Pen.Color:=FC;
                  PolyLine([Point(Width-16,20),Point(Width-16,10),Point(Width-14,15),Point(Width-18,15),Point(Width-16,10)]);
               end
               else
               begin
                  Brush.Style:=bsClear;
                  if not FUseFontColor then
                     Font.Color:=FC;
                  TextOut(Width-(14+TextWidth('8888')),10,FKeyName);
                  Brush.Style:=bsSolid;
               end;
            end;              
            if FShowPrice and (FPrice <> '') then
            begin
               Brush.Style:=bsClear;
               if not FUseFontColor then
                  Font.Color:=clWhite;
               TextOut(((Width-TextWidth(FPrice)) div 2)+1,6,FPrice);
               Brush.Style:=bsSolid;
            end;              
            if (FShowGlyph) and (FGlyph.Width <> 0) then
            begin
               // Need to adjust bounds for a Large Glyph !!!
               if FShowPrice then
                  Dest:=Bounds((Width-FGlyph.Width) div 2,TextHeight('Wg')+4,FGlyph.Width,FGlyph.Height)
               else
                  Dest:=Bounds((Width-FGlyph.Width) div 2,8,FGlyph.Width,FGlyph.Height);
               PlaceGlyphAt(ABitMap.Canvas,Dest,FGlyph);
            end;                    
            if Caption <> '' then
            begin
               Brush.Style:=bsClear;
               if FRightAnchor then  
                  Font.Size:=Font.Size+4
               else
                  Font.Size:=Font.Size+1;
               if not FUseFontColor then
                  Font.Color:=FC;
         
               Dest:=Rect(0,0,Width-24,Height);
               H:=DrawText(ABitMap.Canvas.Handle,PChar(Caption),Length(Caption),Dest,DT_CENTER or DT_CALCRECT or DT_WORDBREAK);
               if FShowGlyph then
                  Dest:=Rect(12,(Height-10)-H,Width-12,Height-11)
               else
                  Dest:=Rect(12,((Height-H) div 2)+1,Width-12,((Height-H) div 2)+H+1);
               DrawText(ABitMap.Canvas.Handle,PChar(Caption),Length(Caption),Dest,DT_CENTER or DT_WORDBREAK);
         
               Brush.Style:=bsSolid;
            end;                       
         end;
      end
      else
      begin
         Brush.Color:=clBtnFace;
         Pen.Color:=clBlack;
         Rectangle(0,0,Width,Height);
      end;
   end;
   Canvas.CopyRect(Bounds(0,0,Width,Height),ABitMap.Canvas,Bounds(0,0,Width,Height));
   ABitMap.Free;
end;              
procedure TKGButton.SetTouchButton(Value:Boolean);
begin
   if FTouchButton <> Value then
   begin
      FTouchButton:=Value;
//      invalidate;
   end; 
end;
procedure TKGButton.SetToggleWhenClicked(Value:Boolean);
begin
//   if FToggleWhenClicked <> Value then
//   begin
      FToggleWhenClicked:=Value;
      if (not Value) and (not FButtonIsUp) then
      begin
         FButtonIsUp:=True;
         invalidate;
      end;
//   end; 
end;
procedure TKGButton.SetButtonIsUp(Value:Boolean);
begin
   if FButtonIsUp <> Value then
   begin
      FButtonIsUp:=Value;
      invalidate;
   end;
end;
procedure TKGButton.SetIsAvailable(Value:Boolean);
begin
   if FIsAvailable <> Value then
   begin
      FIsAvailable:=Value;
      invalidate;
   end;
end;
procedure TKGButton.SetFlashing(Value:Boolean);
begin
    if FFlashing <> Value then
   begin
      FFlashing:=Value;
      if ButtonIsUp and FIsAvailable then
      begin
         if FFlashing then
            Canvas.Brush.Color:=clRed
         else if Caption = ' ' then
            Canvas.Brush.Color:=FUpBitmap.Canvas.Pixels[0,0]
         else
            Canvas.Brush.Color:=RGB(255,239,191); //clLime;
            Canvas.Pen.Color:=clBlack;
         if FShowLED then Canvas.Ellipse(10,8,17,15);
      end;
   end;
end;
procedure TKGButton.SetKeyName(Value:String);
begin
   if FKeyName <> Value then
   begin
      FKeyName:=Value;
      invalidate;
   end;
end;      
procedure TKGButton.SetPrice(Value:String);
begin
   if FPrice <> Value then
   begin
      FPrice:=Value;
      invalidate;
   end;
end;      
procedure TKGButton.SetGlyph(Value:TBitmap);
const
   GlyphWidth   = 75;
   GlyphHeight  = 50;
begin
   FGlyph.Assign(Value);
   FGlyph.Width :=GlyphWidth ;
   FGlyph.Height:=GlyphHeight;

   // dont stretch the bitmap if the same size
   // if you copy a rectangle from Value.Canvas to Glyph.canvas
   // Delphi does not free the resource used properly!
   // this is due to the create on access code
   // so don't call Stretch if the bitmap is the same size as
   // the Glyph!
   if  (Value <> nil)
   and ((FGlyph.Width <> Value.Width  )
   or   (FGlyph.Height <> Value.Height)) then
      Stretch(Value,FGlyph);
      
   FGlyph.PixelFormat:=pf24bit;
   Invalidate;
end;
procedure TKGButton.SetUpBitMap(Value:TBitmap);
begin
   FUpBitMap.Assign(Value);
   AdjustColor(FUpBitmap,FAdjR,FAdjG,FAdjB);
   Width :=FUpBitMap.Width ;
   Height:=FUpBitMap.Height;
   Invalidate;
end;
procedure TKGButton.SetDownBitMap(Value:TBitmap);
begin
   FDownBitMap.Assign(Value);
   AdjustColor(FDownBitmap,FAdjR,FAdjG,FAdjB);
   Width :=FUpBitMap.Width ;
   Height:=FUpBitMap.Height;
   Invalidate;
end;          
constructor TKGButton.Create(AOwner:TComponent);
begin
   inherited Create(AOwner);
   FPictureIndex:=-1;
   FShowLED:=True;          
   FUseFontColor:=False;
   FAdjR:=0;
   FAdjG:=0;
   FAdjB:=0;
   ControlStyle:=ControlStyle + [csOpaque];
   Width:=100;
   Height:=100;
   FButtonIsUp:=True;
   FToggleWhenClicked:=True;
   FUpBitMap  :=TBitMap.Create;
   FDownBitMap:=TBitMap.Create;
   FGlyph     :=TBitMap.Create;
end;
destructor TKGButton.Destroy;
begin
   FUpBitMap.Free;
   FDownBitMap.Free;
   FGlyph.Free;
   inherited;
end;         
procedure TKGButton.WMLButtonUp(var Message: TWMLButtonUp);
begin
   if (FIsAvailable) and (FTouchButton) then
   begin
      if FToggleWhenClicked then
      begin
         ButtonIsUp:=True;
      end;
   end;
   inherited;
end;
procedure TKGButton.WMLButtonDown(var Message: TWMLButtonDown);
begin
   if FIsAvailable then
   begin
      if FToggleWhenClicked then
      begin
         if FTouchButton then
         begin
            ButtonIsUp:=False;
         end
         else
         begin
            ButtonIsUp:=not FButtonIsUp;
         end;
         inherited;
      end
      else
      begin
         ButtonIsUp:=not FButtonIsUp;
         Refresh;
         inherited;
         ButtonIsUp:=not FButtonIsUp;
      end;
   end;
end;
procedure TKGButton.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
   WMLButtonDown(Message);
end;
procedure TKGButton.ForceClick;
begin
   if FIsAvailable and Enabled then
   begin
      if FToggleWhenClicked then
      begin
         ButtonIsUp:=not FButtonIsUp;
         if Assigned(OnClick) then OnClick(Self);
      end
      else
      begin
         ButtonIsUp:=False;
         Refresh;
         if Assigned(OnClick) then OnClick(Self);
         ButtonIsUp:=True;
      end;
   end;
end;
procedure Register;
begin
  RegisterComponents('CorvusVCL', [TKGButton]);
end;

end.
