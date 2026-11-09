unit TopBorderFormU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls,Registry;

const
   SM_CMONITORS = 80;
   HTBUTTON1    = HTHELP+10;
   HTBUTTON2    = HTHELP+11;
   HTBUTTON3    = HTHELP+12;
   HTBUTTON4    = HTHELP+13;
   HTBUTTON5    = HTHELP+14;
   HTBUTTON6    = HTHELP+15;
   HTBUTTON7    = HTHELP+16;
   HTBUTTON8    = HTHELP+17;
   HTBUTTON9    = HTHELP+18;
   HTBUTTON10   = HTHELP+19;
   HTTABS       = HTHELP+19;
   
type                     
  TSideType = ( stLeft,stRight,stTop,stBottom );
  TTopBorderForm = class(TForm)
  private
    FStatusString:String;
    procedure SetStatus(Value:String);
  public
    Skin:TBitmap;
    Tabs:TStringList;
    SelTab:Integer;
    FOnButton1:TNotifyEvent;
    FOnButton2:TNotifyEvent;
    FOnButton3:TNotifyEvent;
    FOnButton4:TNotifyEvent;
    FOnButton5:TNotifyEvent;
    FOnButton6:TNotifyEvent;
    FOnButton7:TNotifyEvent;
    FTabPanel1:TPanel;
    FTabPanel2:TPanel;
    FTabPanel3:TPanel;
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure DrawCSection;                    
    procedure DrawBackground;                    
    procedure DrawButtons;
    procedure Paint; override;
    procedure Resize; override;
    procedure WMNCPaint(var Msg:TWMNCPaint); message WM_NCPAINT;
    procedure WMGetMinMaxInfo(var Msg:TMessage); message WM_GETMINMAXINFO; 
    procedure WMNCHitTest(var Message : TWMNCHitTest); message WM_NCHITTEST;
    procedure WMNCLButtonDown(var Message : TWMNCLButtonDown); message WM_NCLButtonDown;
    procedure WMNCLButtonUp  (var Message : TWMNCLButtonUp); message WM_NCLButtonUp;
    procedure WMNCMouseMove  (var Message : TWMNCLButtonUp); message WM_NCMOUSEMOVE;
    property  StatusString:String read FStatusString write SetStatus;
  end;   

var
  TitleButton:Array[0..9] of Integer = (1,1,1,1,1,1,1,1,1,1);
  
implementation

function ExtractBMP(From:TBitmap;X,Y,W,H:Integer):TBitmap;
begin
   Result:=TBitmap.Create;
   Result.Width:=W;
   Result.Height:=H;
   Result.Canvas.CopyRect(Bounds(0,0,W,H),From.Canvas,Bounds(X,Y,W,H));
end;
function StretchBMP(From:TBitmap;X,Y,W,H,Len:Integer;Side:TSideType):TBitmap;
var
   Orig:TBitmap;
begin
   Result:=TBitmap.Create;
   Orig:=ExtractBMP(From,X,Y,W,H);
   case Side of
       stLeft   : begin
                     Result.Height:=H;
                     Result.Width:=W+Len;
                     Result.Canvas.CopyRect(Bounds(Len-1,0,W,H),Orig.Canvas,Bounds(0,0,W,H));
                     Result.Canvas.CopyRect(Bounds(0,0,Len,H),Orig.Canvas,Bounds(0,0,1,H));
                  end;                                
       stRight  : begin
                     Result.Height:=H;
                     Result.Width:=W+Len;
                     Result.Canvas.CopyRect(Bounds(0,0,W,H),Orig.Canvas,Bounds(0,0,W,H));
                     Result.Canvas.CopyRect(Bounds(W,0,Len,H),Orig.Canvas,Bounds(W-1,0,1,H));
                  end;               
       stTop    : begin
                     Result.Height:=H+Len;
                     Result.Width:=W;
                     Result.Canvas.CopyRect(Bounds(0,Len-1,W,H),Orig.Canvas,Bounds(0,0,W,H));
                     Result.Canvas.CopyRect(Bounds(0,0,W,Len),Orig.Canvas,Bounds(0,0,W,1));
                  end;      
       stBottom : begin
                     Result.Height:=H+Len;
                     Result.Width:=W;
                     Result.Canvas.CopyRect(Bounds(0,0,W,H),Orig.Canvas,Bounds(0,0,W,H));
                     Result.Canvas.CopyRect(Bounds(0,H,W,Len),Orig.Canvas,Bounds(0,H-1,W,1));
                  end;                               
   end;      
   Orig.Free;
end;
function MakeSquare(Canvas:TCanvas;From:TBitmap;Orig:TRect;Centre:TPoint;Dest:TRect;FillCentre:Boolean):TBitmap;
var
   BMP:TBitmap;
   GW,GH:Integer;
   OW,OH:Integer;
   Width :Integer;
   Height:Integer;
begin          
   Result:=nil;
   Width :=Dest.Right-Dest.Left;
   Height:=Dest.Bottom-Dest.Top;
   if (Width < 1) or (Height < 1) then Exit;
   if Canvas = nil then
   begin
      Result:=TBitmap.Create;
      Result.Width :=Width ;
      Result.Height:=Height;
      Canvas:=Result.Canvas;
   end;
   
   
   OW:=Orig.Right-Orig.Left;
   OH:=Orig.Bottom-Orig.Top;
   
   GW:=Width -OW;
   GH:=Height-OH;
                                        
   if (GW < 1) then GW:=1;
   if (GH < 1) then GH:=1;
     
   BMP:=StretchBMP(From,Orig.Left,Orig.Top,Centre.X+1,Centre.Y+1,GW,stRight);
   Canvas.StretchDraw(Bounds(0,0,Centre.X+GW,Centre.Y+1),BMP);
   BMP.Free;
   
   BMP:=StretchBMP(From,Orig.Left+Centre.X,Orig.Top,OW-Centre.X,Centre.Y+1,GH,stBottom);
   Canvas.StretchDraw(Bounds(Centre.X+GW,0,OW-Centre.X,Centre.Y+GH),BMP);
   BMP.Free;
   
   BMP:=StretchBMP(From,Orig.Left+Centre.X,Orig.Top+Centre.Y,OW-Centre.X,OH-Centre.Y,GW,stLeft);
   Canvas.StretchDraw(Bounds(Centre.X+1,Centre.Y+GH,(OW-Centre.X)+GW,OH-Centre.Y),BMP);
   BMP.Free;
   
   BMP:=StretchBMP(From,Orig.Left,Orig.Top+Centre.Y,Centre.X+1,OH-Centre.Y,GH,stTop);
   Canvas.StretchDraw(Bounds(0,Centre.Y+1,Centre.X+1,(OH-Centre.Y)+GH),BMP);
   BMP.Free;
   if FillCentre then
      Canvas.CopyRect(Bounds(Centre.X+1,Centre.Y+1,GW-1,GH-1),From.Canvas,Bounds(Orig.Left+Centre.X,Orig.Top+Centre.Y,1,1));
end;
function MakeButton(From:TBitmap;BRect,ButtonRect,MRect,MaskRect:TRect):TBitmap;
var
   Mask:TBitmap;
begin
   Result:=MakeSquare(nil,From,BRect,Point(2,2),ButtonRect,True);
   Mask:=ExtractBMP(From,MRect.Left,MRect.Top,MRect.Right-MRect.Left,MRect.Bottom-MRect.Top);
   Result.Canvas.Brush.Style:=bsClear;
   Result.Canvas.BrushCopy(MaskRect,Mask,Bounds(0,0,MRect.Right-MRect.Left,MRect.Bottom-MRect.Top),Mask.Canvas.Pixels[0,0]);
   Result.Canvas.Brush.Style:=bsSolid;
end;
procedure DrawSquare(Canvas:TCanvas;Pos:TPoint;From:TBitmap;Orig:TRect;Centre:TPoint;Dest:TRect;FillCentre:Boolean);
var
   BMP:TBitmap;
begin          
   if FillCentre then
   begin
      BMP:=MakeSquare(nil,From,Orig,Centre,Dest,FillCentre);
      Canvas.StretchDraw(Bounds(Pos.X,Pos.Y,BMP.Width,BMP.Height),BMP);
      BMP.Free;
   end
   else
      MakeSquare(Canvas,From,Orig,Centre,Dest,FillCentre);
end;   
procedure DrawTabs(Canvas:TCanvas;Pos:TPoint;From:TBitmap;Tabs:TStrings;OpenTab:Integer);
var
   LLO,LLC    :TRect;
   MLO,MCC,MRO:TRect;
   RRO,RRC    :TRect;
   BR         :TRect;
   BMP:TBitmap;
   TabNo:Integer;
   
   NumbTabs:Integer;
begin
   if (Tabs = nil) or (Tabs.Count = 0) then Exit;
   LLO:=Bounds(34, 0,15,15);
   LLC:=Bounds(34,15,15,15);
   MLO:=Bounds(49, 0,15,15);
   MCC:=Bounds(49,15,15,15);
   MRO:=Bounds(19, 0,15,15);
   RRO:=Bounds(64,15,14,15);
   RRC:=Bounds(64, 0,14,15);
   TabNo:=0;
   NumbTabs:=Tabs.Count;
   if OpenTab = TabNo then
      BMP:=StretchBMP(From,LLO.Left,LLO.Top,LLO.Right-LLO.Left,LLO.Bottom-LLO.Top,Canvas.TextWidth(Tabs[TabNo])+8,stRight)
   else
      BMP:=StretchBMP(From,LLC.Left,LLC.Top,LLC.Right-LLC.Left,LLC.Bottom-LLC.Top,Canvas.TextWidth(Tabs[TabNo])+8,stRight);
   BR:=Bounds(Pos.X,Pos.Y,BMP.Width,BMP.Height);
   Canvas.StretchDraw(BR,BMP);
   if TabNo = OpenTab then
      OffsetRect(BR,7,0)
   else
      OffsetRect(BR,8,1);
   Canvas.Brush.Style:=bsClear;
   DrawText(Canvas.Handle,PChar(Tabs[TabNo]),-1,BR,DT_CENTER);
   Canvas.Brush.Style:=bsSolid;
   Pos.X:=Pos.X+BMP.Width;
   BMP.Free;
   BMP:=nil;
   while NumbTabs > 1 do
   begin
      Dec(NumbTabs);
      if OpenTab = TabNo then
         BMP:=StretchBMP(From,MLO.Left,MLO.Top,MLO.Right-MLO.Left,MLO.Bottom-MLO.Top,Canvas.TextWidth(Tabs[TabNo])+8,stRight);
         
      Inc(TabNo);
      if OpenTab = TabNo then
         BMP:=StretchBMP(From,MRO.Left,MRO.Top,MRO.Right-MRO.Left,MRO.Bottom-MLO.Top,Canvas.TextWidth(Tabs[TabNo])+8,stRight);
      if BMP = nil then
         BMP:=StretchBMP(From,MCC.Left,MCC.Top,MCC.Right-MCC.Left,MCC.Bottom-MCC.Top,Canvas.TextWidth(Tabs[TabNo])+8,stRight);
         
      BR:=Bounds(Pos.X,Pos.Y,BMP.Width,BMP.Height);
      Canvas.StretchDraw(BR,BMP);
      if TabNo = OpenTab then
         OffsetRect(BR,7,0)
      else
         OffsetRect(BR,8,1);
      Canvas.Brush.Style:=bsClear;
      DrawText(Canvas.Handle,PChar(Tabs[TabNo]),-1,BR,DT_CENTER);
      Canvas.Brush.Style:=bsSolid;
      Pos.X:=Pos.X+BMP.Width;     
      BMP.Free;
      BMP:=nil;
   end;
   if OpenTab = TabNo then
      BMP:=ExtractBMP(From,RRO.Left,RRO.Top,RRO.Right-RRO.Left,RRO.Bottom-RRO.Top)
   else
      BMP:=ExtractBMP(From,RRC.Left,RRC.Top,RRC.Right-RRC.Left,RRC.Bottom-RRC.Top);
   Canvas.StretchDraw(Bounds(Pos.X,Pos.Y,BMP.Width,BMP.Height),BMP);
   Pos.X:=Pos.X+BMP.Width;
   BMP.Free;
   
end;                      
procedure DrawButton(Canvas:TCanvas;Pos:TPoint;From:TBitmap;BRect,ButtonRect,MRect,MaskRect:TRect);
var
   BMP:TBitmap;
begin
   BMP:=MakeButton(From,BRect,ButtonRect,MRect,MaskRect);
   Canvas.StretchDraw(Bounds(Pos.X,Pos.Y,BMP.Width,BMP.Height),BMP);
   BMP.Free;
end;

constructor TTopBorderForm.Create(AOwner:TComponent);
var
   SL:TStringList;
begin
   Tabs:=TStringList.Create;
   SelTab:=0;
   inherited Create(AOwner);
   with TRegistry.Create do
   begin
      RootKey:=HKEY_LOCAL_MACHINE;
      if OpenKey('\SOFTWARE\PSL\FORMPOS\'+Application.Title+'.'+Name,False) then
      begin
         SL:=TStringList.Create;
         SL.CommaText:=ReadString('Position');
         if SL.Count > 3 then
         begin
            SetBounds(StrToIntDef(SL[0],Left  ),
                      StrToIntDef(SL[1],Top   ),
                      StrToIntDef(SL[2],Width ),
                      StrToIntDef(SL[3],Height));
         end;
         SL.Free;
      end;    
      Free;
   end;
   if GetSystemMetrics(SM_CMONITORS) < 2 then
   begin
      if Left+Width > Screen.Width  then Left:=Screen.Width-Width;
      if Top+Height > Screen.Height then Top:=Screen.Height-Height;
      if Left < 0 then Left:=0;
      if Top < 0 then Top:=0;
   end;
end;
destructor TTopBorderForm.Destroy;
begin
   with TRegistry.Create do
   begin
      RootKey:=HKEY_LOCAL_MACHINE;
      if OpenKey('\SOFTWARE\PSL\FORMPOS\'+Application.Title+'.'+Name,True) then
      begin
         WriteString('Position',
            IntToStr(Left  )+','+
            IntToStr(Top   )+','+
            IntToStr(Width )+','+
            IntToStr(Height));
      end;    
      Free;
   end;
//   inherited Destroy;
end;
procedure TTopBorderForm.WMGetMinMaxInfo(var MSG: Tmessage);
begin
   if Application.Terminated then Exit;
   inherited;
   PMinMaxInfo(MSG.lparam)^.ptMinTrackSize.X:=170;
   PMinMaxInfo(MSG.lparam)^.ptMinTrackSize.Y:=50;
end; 
procedure TTopBorderForm.Resize;
begin
   if Application.Terminated then Exit;
  DrawBackground;
end;
procedure TTopBorderForm.Paint;
begin
   if Application.Terminated then Exit;
  DrawBackground;
end;             
procedure TTopBorderForm.WMNCPaint(var Msg : TWMNCPaint);
begin
   if Application.Terminated then Exit;
  DrawBackground;
end;                
procedure TTopBorderForm.WMNCMouseMove(var Message : TWMNCLButtonUp);
begin
   if Application.Terminated then Exit;
   if (Message.HitTest < HTBUTTON1) or (Message.HitTest > HTBUTTON7) then
   begin
      if (TitleButton[0] = 2) then begin TitleButton[0]:=1; DrawButtons; end;
      if (TitleButton[1] = 2) then begin TitleButton[1]:=1; DrawButtons; end;
      if (TitleButton[2] = 2) then begin TitleButton[2]:=1; DrawButtons; end;
      if (TitleButton[3] = 2) then begin TitleButton[3]:=1; DrawButtons; end;
      if (TitleButton[4] = 2) then begin TitleButton[4]:=1; DrawButtons; end;
      if (TitleButton[5] = 2) then begin TitleButton[5]:=1; DrawButtons; end;
      if (TitleButton[6] = 2) then begin TitleButton[6]:=1; DrawButtons; end;
      inherited;
   end
end;
procedure TTopBorderForm.WMNCLButtonUp  (var Message : TWMNCLButtonUp);
begin
   if Application.Terminated then Exit;
   if (Message.HitTest >= HTBUTTON1) and (Message.HitTest <= HTBUTTON7) then
   begin
      if (Message.HitTest = HTBUTTON1) and (TitleButton[0] <> 0) then begin TitleButton[0]:=1; if Assigned(FOnButton1) then FOnButton1(Self); end;
      if (Message.HitTest = HTBUTTON2) and (TitleButton[1] <> 0) then begin TitleButton[1]:=1; if Assigned(FOnButton2) then FOnButton2(Self); end;
      if (Message.HitTest = HTBUTTON3) and (TitleButton[2] <> 0) then begin TitleButton[2]:=1; if Assigned(FOnButton3) then FOnButton3(Self); end;
      if (Message.HitTest = HTBUTTON4) and (TitleButton[3] <> 0) then begin TitleButton[3]:=1; if Assigned(FOnButton4) then FOnButton4(Self); end;
      if (Message.HitTest = HTBUTTON5) and (TitleButton[4] <> 0) then begin TitleButton[4]:=1; if Assigned(FOnButton5) then FOnButton5(Self); end;
      if (Message.HitTest = HTBUTTON6) and (TitleButton[5] <> 0) then begin TitleButton[5]:=1; if Assigned(FOnButton6) then FOnButton6(Self); end;
      if (Message.HitTest = HTBUTTON7) and (TitleButton[6] <> 0) then begin TitleButton[6]:=1; if Assigned(FOnButton7) then FOnButton7(Self) else Close; end;
      DrawButtons;
   end
   else 
   begin
      if (TitleButton[0] = 2) then begin TitleButton[0]:=1; Invalidate; end;
      if (TitleButton[1] = 2) then begin TitleButton[1]:=1; Invalidate; end;
      if (TitleButton[2] = 2) then begin TitleButton[2]:=1; Invalidate; end;
      if (TitleButton[3] = 2) then begin TitleButton[3]:=1; Invalidate; end;
      if (TitleButton[4] = 2) then begin TitleButton[4]:=1; Invalidate; end;
      if (TitleButton[5] = 2) then begin TitleButton[5]:=1; Invalidate; end;
      if (TitleButton[6] = 2) then begin TitleButton[6]:=1; Invalidate; end;
      inherited;
   end;
end;    
procedure TTopBorderForm.WMNCLButtonDown(var Message : TWMNCLButtonDown);
var
   XPos,I:Integer;
begin
   if Application.Terminated then Exit;
  if (Message.HitTest >= HTBUTTON1) and (Message.HitTest <= HTBUTTON7) then
  begin
     if (Message.HitTest = HTBUTTON1) and (TitleButton[0] <> 0) then TitleButton[0]:=2;
     if (Message.HitTest = HTBUTTON2) and (TitleButton[1] <> 0) then TitleButton[1]:=2;
     if (Message.HitTest = HTBUTTON3) and (TitleButton[2] <> 0) then TitleButton[2]:=2;
     if (Message.HitTest = HTBUTTON4) and (TitleButton[3] <> 0) then TitleButton[3]:=2;
     if (Message.HitTest = HTBUTTON5) and (TitleButton[4] <> 0) then TitleButton[4]:=2;
     if (Message.HitTest = HTBUTTON6) and (TitleButton[5] <> 0) then TitleButton[5]:=2;
     if (Message.HitTest = HTBUTTON7) and (TitleButton[6] <> 0) then TitleButton[6]:=2;
     DrawButtons;                                                                           
  end
  else if (Message.HitTest = HTTABS) then
  begin
     XPos:=Left+16;
     if Tabs <> nil then
     begin
        for I:=0 to Tabs.Count-1 do
        begin
           if (Message.XCursor > XPos) and (Message.XCursor < XPos+Canvas.TextWidth(Tabs[I])+24) then
           begin
              if SelTab <> I then
              begin
                      if ((SelTab = 0) and Assigned(FTabPanel1)) then FTabPanel1.Visible:=False
                 else if ((SelTab = 1) and Assigned(FTabPanel2)) then FTabPanel2.Visible:=False
                 else if ((SelTab = 2) and Assigned(FTabPanel3)) then FTabPanel3.Visible:=False;
                 SelTab:=I;
                 break
              end;
           end;
           Inc(XPos,Canvas.TextWidth(Tabs[I])+8+15);
        end;
             if ((SelTab = 0) and Assigned(FTabPanel1)) then FTabPanel1.Visible:=True
        else if ((SelTab = 1) and Assigned(FTabPanel2)) then FTabPanel2.Visible:=True
        else if ((SelTab = 2) and Assigned(FTabPanel3)) then FTabPanel3.Visible:=True;
        DrawBackground;     
     end;
  end     
  else
     inherited;
end;

procedure TTopBorderForm.WMNCHitTest(var Message : TWMNCHitTest);
var
  BRect:TRect;
  XY:TPoint;
begin
   if Application.Terminated then Exit;
   inherited;
   GetWindowRect(Handle,BRect);
   BRect.Bottom:=BRect.Top+29;
   if PtInRect(BRect,Point(Message.Pos.X,Message.Pos.Y)) then 
   begin
      XY.X:=Message.Pos.X-BRect.Left;
      XY.Y:=Message.Pos.Y-BRect.Top;
           if PtInRect(Bounds(      26, 5,18,18),XY) then Message.Result:=HTBUTTON1
      else if PtInRect(Bounds(      45, 5,18,18),XY) then Message.Result:=HTBUTTON2
      else if PtInRect(Bounds(      64, 5,18,18),XY) then Message.Result:=HTBUTTON3
      else if PtInRect(Bounds(      83, 5,18,18),XY) then Message.Result:=HTBUTTON4
      else if PtInRect(Bounds(Width-61, 5,18,18),XY) then Message.Result:=HTBUTTON5
      else if PtInRect(Bounds(Width-42, 5,18,18),XY) then Message.Result:=HTBUTTON6
      else if PtInRect(Bounds(Width-23, 5,18,18),XY) then Message.Result:=HTBUTTON7;
   end;
   GetWindowRect(Handle,BRect);
   InflateRect(BRect,-4,-4);
   BRect.Top:=BRect.Bottom-16;
   if PtInRect(BRect,Point(Message.Pos.X,Message.Pos.Y)) then 
      Message.Result:=HTTABS;
end;
procedure TTopBorderForm.DrawButtons;
var
   SH:THandle;
   R:TRect;
begin
   if Skin = nil then Exit;
   SH:=Canvas.Handle;
   Canvas.Handle:=GetWindowDC(Self.Handle);
   try                                                                          
      DrawButton(Canvas,Point(      26, 5),Skin,Bounds(19+TitleButton[0]*5,20, 5, 5),Bounds(0,0,18,18),Bounds(29,30,12,12),Bounds(3,3,12,12));
      DrawButton(Canvas,Point(      45, 5),Skin,Bounds(19+TitleButton[1]*5,20, 5, 5),Bounds(0,0,18,18),Bounds(40,30,12,12),Bounds(3,3,12,12));
      DrawButton(Canvas,Point(      64, 5),Skin,Bounds(19+TitleButton[2]*5,20, 5, 5),Bounds(0,0,18,18),Bounds(40,41,12,12),Bounds(3,3,12,12));
      DrawButton(Canvas,Point(      83, 5),Skin,Bounds(19+TitleButton[3]*5,20, 5, 5),Bounds(0,0,18,18),Bounds(29,41,12,12),Bounds(3,3,12,12));
      DrawButton(Canvas,Point(Width-61, 5),Skin,Bounds(19+TitleButton[4]*5,20, 5, 5),Bounds(0,0,18,18),Bounds(51,30,12,12),Bounds(3,3,12,12));
      DrawButton(Canvas,Point(Width-42, 5),Skin,Bounds(19+TitleButton[5]*5,20, 5, 5),Bounds(0,0,18,18),Bounds(51,41,12,12),Bounds(3,3,12,12));
      DrawButton(Canvas,Point(Width-23, 5),Skin,Bounds(19+TitleButton[6]*5,20, 5, 5),Bounds(0,0,18,18),Bounds(62,30,12,12),Bounds(3,3,12,12));
      DrawSquare(Canvas,Point(     103, 5),Skin,Bounds(29,20, 5, 5),Point( 2, 2),Bounds(0,0,Width-166, 18),True);
      R:=Bounds(105, 7,Width-170,14);
      Canvas.Font.Color:=clBlack;
      Canvas.Brush.Style:=bsClear;
      DrawText(Canvas.Handle,PChar(FStatusString),-1,R,DT_CENTER);
      Canvas.Brush.Style:=bsSolid;
   finally                       
      ReleaseDC(Self.Handle,Canvas.Handle);
      Canvas.Handle:=SH;
   end;
end;
procedure TTopBorderForm.DrawCSection;
var
   TabPanel:TPanel;
begin
   TabPanel:=nil;
        if ((SelTab = 0) and Assigned(FTabPanel1)) then TabPanel:=FTabPanel1
   else if ((SelTab = 1) and Assigned(FTabPanel2)) then TabPanel:=FTabPanel2
   else if ((SelTab = 2) and Assigned(FTabPanel3)) then TabPanel:=FTabPanel3;
   if TabPanel <> nil then
   begin
      TabPanel.Color:=Skin.Canvas.Pixels[9,8];
      TabPanel.Font.Color:=Skin.Canvas.Pixels[4,15];
      if (TabPanel.Left <> 9) or (TabPanel.Top <> 5)
      or (TabPanel.Width <> Width-27) or (TabPanel.Height <> Height-60) then
        TabPanel.SetBounds(9,5,Width-27,Height-60);
      TabPanel.BringToFront;
   end;          
end;
procedure TTopBorderForm.DrawBackground;
var
   SH:THandle;
   BGBMP:TBitmap;
   R:TRect;
const
   inhere:Boolean =False;
begin
   if inhere then Exit;
   if (Skin = nil) or (not Visible) then Exit;
   SH:=Canvas.Handle;
   Canvas.Handle:=GetWindowDC(Self.Handle);
   inhere:=True;
   try
      BGBMP:=TBitmap.Create;
      BGBMP.Width:=Width;
      BGBMP.Height:=Height;
      DrawSquare(BGBMP.Canvas,Point(       0, 0),Skin,Bounds(0 ,30,29,32),Point(23,27),Bounds(0,0,Width  ,Height),False);
      DrawSquare(BGBMP.Canvas,Point(       4,27),Skin,Bounds(0 , 0,19,30),Point( 9, 8),Bounds(0,0,Width-8,Height-31),True);
      DrawSquare(BGBMP.Canvas,Point(     103, 5),Skin,Bounds(29,20, 5, 5),Point( 2, 2),Bounds(0,0,Width-166, 18),True);
      DrawButton(BGBMP.Canvas,Point(      26, 5),Skin,Bounds(19+TitleButton[0]*5,20, 5, 5),Bounds(0,0,18,18),Bounds(29,30,12,12),Bounds(3,3,12,12));
      DrawButton(BGBMP.Canvas,Point(      45, 5),Skin,Bounds(19+TitleButton[1]*5,20, 5, 5),Bounds(0,0,18,18),Bounds(40,30,12,12),Bounds(3,3,12,12));
      DrawButton(BGBMP.Canvas,Point(      64, 5),Skin,Bounds(19+TitleButton[2]*5,20, 5, 5),Bounds(0,0,18,18),Bounds(40,41,12,12),Bounds(3,3,12,12));
      DrawButton(BGBMP.Canvas,Point(      83, 5),Skin,Bounds(19+TitleButton[3]*5,20, 5, 5),Bounds(0,0,18,18),Bounds(29,41,12,12),Bounds(3,3,12,12));
      DrawButton(BGBMP.Canvas,Point(Width-61, 5),Skin,Bounds(19+TitleButton[4]*5,20, 5, 5),Bounds(0,0,18,18),Bounds(51,30,12,12),Bounds(3,3,12,12));
      DrawButton(BGBMP.Canvas,Point(Width-42, 5),Skin,Bounds(19+TitleButton[5]*5,20, 5, 5),Bounds(0,0,18,18),Bounds(51,41,12,12),Bounds(3,3,12,12));
      DrawButton(BGBMP.Canvas,Point(Width-23, 5),Skin,Bounds(19+TitleButton[6]*5,20, 5, 5),Bounds(0,0,18,18),Bounds(62,30,12,12),Bounds(3,3,12,12));
      if Height > 62 then
         DrawTabs(BGBMP.Canvas,Point(8,Height-20),Skin,Tabs,SelTab);
      Canvas.StretchDraw(Bounds(0,0,Width,Height),BGBMP);
      R:=Bounds(105, 7,Width-170,14);
      Canvas.Font.Color:=clBlack;
      Canvas.Brush.Style:=bsClear;
      DrawText(Canvas.Handle,PChar(FStatusString),-1,R,DT_CENTER);
      Canvas.Brush.Style:=bsSolid;
      BGBMP.Free;
      DrawCSection;
   finally         
      inhere:=False;
      ReleaseDC(Self.Handle,Canvas.Handle);
      Canvas.Handle:=SH;
   end;
end;
procedure TTopBorderForm.SetStatus(Value:String);
begin
   if FStatusString <> Value then
   begin
      FStatusString:=Value;
      DrawButtons;
   end;
end;

end.
