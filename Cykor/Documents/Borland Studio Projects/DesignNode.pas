unit DesignNode;

interface
uses
  Windows,Messages,Classes,Graphics,Controls,SysUtils,ExtCtrls,Printers;

type
  TLinkType = (ltDirect,ltSLine,ltRDown,ltJRDown);
  TDesignNode = class;
  TNodeClicked = procedure (DesignNode:TDesignNode;AreaCode:Integer) of object;
  TDesignNode = class(TCustomControl)
  private
     JoinList:TList;
     MX,MY:Integer;
     FBorderOn:Boolean;
     FBorderRect:TRect;
     FPenColor:TColor;
     FTitle:String;
     FCaption:String;
     FBitmap:TBitmap;
     FIcon:TBitmap;
     procedure DrawLink(OnCanvas:TCanvas;FromNode,ToNode:TDesignNode);
  public
     constructor Create(AOwner:TComponent); override;
     destructor Destroy; override;
     procedure Paint; override;
     procedure DrawLines(OnCanvas:TCanvas);
     procedure JoinTo(DesignNode:TDesignNode);
     procedure WMEraseBkgnd(var M : TWMEraseBkgnd); message WM_EraseBkgnd;
     procedure MouseMove(Shift:TShiftState;X,Y:Integer); override;
     procedure MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer); override;
     procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
     property PenColor:TColor read FPenColor write FPenColor;
     property Color;
     property Title   :String  read FTitle    write FTitle   ;
     property Caption :String  read FCaption  write FCaption ;
     property Bitmap  :TBitmap read FBitmap   write FBitmap  ;
     property Icon    :TBitmap read FIcon     write FIcon    ;
     property Cursor;
     property OnDragOver;
     property OnDragDrop;
     property OnMouseMove;
  end;

  TDiagBackground = class (TCustomControl)
  private
     FLinkType:TLinkType;
     FOnNodeClicked:TNodeClicked;
  public
     property Color;
     procedure NotifyPos(AControl: TControl);
     procedure InsertControl(AControl: TControl);
//     procedure WMEraseBkgnd(var M : TWMEraseBkgnd); message WM_EraseBkgnd;
     procedure Paint; override;
     property LinkType:TLinkType read FLinkType write FLinkType;
     property OnNodeClicked:TNodeClicked read FOnNodeClicked write FOnNodeClicked;
     property OnDragOver;
     property OnDragDrop;
  end;

var
   CurrentlyPrinting:Boolean;

implementation

{TDiagBackground}
procedure TDiagBackground.NotifyPos(AControl: TControl);
begin
   if AControl.Left+AControl.Width > Width then
      Width:=AControl.Left+AControl.Width+10;
   if AControl.Top+AControl.Height > Height then
      Height:=AControl.Top+AControl.Height+10;
end;
procedure TDiagBackground.InsertControl(AControl: TControl);
begin
   inherited InsertControl(AControl);
   NotifyPos(AControl);
end;
{procedure TDiagBackground.WMEraseBkgnd(var M : TWMEraseBkgnd);
begin
  M.Result := LRESULT(False);
end;}
procedure TDiagBackground.Paint;
var
   I:Integer;
begin
   with Canvas do
   begin
      Brush.Color:=clWhite;
      if ControlCount > 0 then
         for I:=0 to ControlCount-1 do
            if (Controls[I] is TDesignNode) then
               (Controls[I] as TDesignNode).DrawLines(Canvas);
   end;
end;
{TDesignNode}
procedure TDesignNode.WMEraseBkgnd(var M : TWMEraseBkgnd);
begin
  M.Result := LRESULT(False);
end;
constructor TDesignNode.Create(AOwner:TComponent);
begin
   inherited Create(AOwner);
   Width:=100;
   Height:=100;
   PenColor:=clBlack;
   Color:=clWindow;
   JoinList:=TList.Create;
end;
destructor TDesignNode.Destroy;
begin
   JoinList.Free;
   inherited Destroy;
end;
procedure TDesignNode.MouseMove(Shift:TShiftState;X,Y:Integer);
begin
   if ((ssLeft in Shift) or (ssRight in Shift)) then
   begin
      Inc(X,Left);
      Inc(Y,Top);
      if (Left <> (X+MX)) or (Top <> (Y+MY)) then
      begin
         Left:=X-MX;
         Top :=Y-MY;
         if Parent is TDiagBackground then
         begin
            (Parent as TDiagBackground).Invalidate;
            (Parent as TDiagBackground).NotifyPos(Self);
         end;
      end;
   end;
   inherited MouseMove(Shift,X,Y);
end;
procedure TDesignNode.MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
begin
   MX:=X;
   MY:=Y;
   FBorderOn:=True;
   FBorderRect:=Bounds(Left,Top,Width,Height);
   inherited MouseDown(Button,Shift,X,Y);
end;
procedure TDesignNode.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   FBorderOn:=False;
   if Parent is TDiagBackground then
   begin
      inherited MouseUp(Button,Shift,X,Y);
      if (Abs(FBorderRect.Left-Left) < 2) and (Abs(FBorderRect.Top-Top) < 2) and Assigned((Parent as TDiagBackground).OnNodeClicked) then
      begin
         if (FIcon <> nil) and (X > (Width-(FIcon.Width+3))) then
            (Parent as TDiagBackground).OnNodeClicked(Self,1)
         else
            (Parent as TDiagBackground).OnNodeClicked(Self,0);
      end
      else
      begin
         (Parent as TDiagBackground).Invalidate;
         (Parent as TDiagBackground).NotifyPos(Self);
      end;
   end;
end;
procedure TDesignNode.DrawLink(OnCanvas:TCanvas;FromNode,ToNode:TDesignNode);
var
   LineMid:Integer;
   LineTop:Integer;
   LineBot:Integer;
   Angle:Integer;
   LinkType:TLinkType;
begin
   if FromNode.Parent <> ToNode.Parent then Exit;
   if (Parent is TDiagBackground) then
      LinkType:=(Parent as TDiagBackground).LinkType
   else
      LinkType:=ltDirect;
      
   if LinkType = ltDirect then
   begin
      with OnCanvas do
      begin
         MoveTo(FromNode.Left+(FromNode.Width div 2),FromNode.Top+(FromNode.Height div 2));
         LineTo(ToNode.Left+(ToNode.Width div 2),ToNode.Top+(ToNode.Height div 2));
      end;
   end
   else if LinkType = ltJRDown then
   begin
      with OnCanvas do
      begin
         MoveTo(FromNode.Left+FromNode.Width,FromNode.Top+(FromNode.Height div 2));
         LineTo(FromNode.Left+FromNode.Width+8,FromNode.Top+(FromNode.Height div 2));
         LineTo(FromNode.Left+FromNode.Width+8,ToNode.Top+(ToNode.Height div 2));
         LineTo(ToNode.Left,ToNode.Top+(ToNode.Height div 2));
      end;
   end
   else if LinkType = ltRDown then
   begin
      with OnCanvas do
      begin
         MoveTo(FromNode.Left+FromNode.Width,FromNode.Top+(FromNode.Height div 2));
         LineTo(ToNode.Left-(ToNode.Left-(FromNode.Left+FromNode.Width)) div 2,FromNode.Top+(FromNode.Height div 2));
         LineTo(ToNode.Left-(ToNode.Left-(FromNode.Left+FromNode.Width)) div 2,ToNode.Top+(ToNode.Height div 2));
         LineTo(ToNode.Left,ToNode.Top+(ToNode.Height div 2));
      end;
   end
   else
   begin
      if ToNode.Left = FromNode.Left then
      begin
         if ToNode.Top > FromNode.Top then
            Angle:=90
         else
            Angle:=-90;
      end    
      else
      begin
         if ToNode.Top > FromNode.Top then
            Angle:=(Trunc(arctan((ToNode.Top-FromNode.Top)/(ToNode.Left-FromNode.Left))*(180/PI)))
         else
            Angle:=(Trunc(arctan((FromNode.Top-ToNode.Top)/(ToNode.Left-FromNode.Left))*(180/PI)));
      end;

      if (Angle > 135) or (Angle < 0) then
      begin
         DrawLink(OnCanvas,ToNode,FromNode);
      end
      else if Angle > 45 then
      begin
         LineMid:=FromNode.Top+FromNode.Height+((ToNode.Top-(FromNode.Top+FromNode.Height)) div 2);
         LineTop:=FromNode.Left+(FromNode.Width div 2);
         LineBot:=ToNode.Left+(ToNode.Width div 2);
         with OnCanvas do
         begin
            MoveTo(LineTop,FromNode.Top+FromNode.Height);
            LineTo(LineTop,LineMid);
            LineTo(LineBot,LineMid);
            LineTo(LineBot,ToNode.Top);
         end;
      end
      else
      begin
         LineMid:=FromNode.Left+FromNode.Width+((ToNode.Left-(FromNode.Left+FromNode.Width)) div 2);
         LineTop:=FromNode.Top+(FromNode.Height div 2);
         LineBot:=ToNode.Top+(ToNode.Height div 2);
         with OnCanvas do
         begin
            MoveTo(FromNode.Left+FromNode.Width,LineTop);
            LineTo(LineMid,LineTop);
            LineTo(LineMid,LineBot);
            LineTo(ToNode.Left,LineBot);
         end;
      end;
   end;
end;
procedure TDesignNode.JoinTo(DesignNode:TDesignNode);
begin
   if Parent <> DesignNode.Parent then Exit;
   JoinList.Add(DesignNode);
end;
procedure TDesignNode.Paint;
begin
   inherited Paint;
   if (Parent is TDiagBackground) then
      Canvas.Brush.Color:=(Parent as TDiagBackground).Color;
   Canvas.FillRect(Self.ClientRect);
   Canvas.Pen.Color:=PenColor;
   Canvas.Rectangle(0,0,Width,Height);

end;
procedure TDesignNode.DrawLines(OnCanvas:TCanvas);
var
   I:Integer;
   PC:TColor;
begin
   if (Parent is TDiagBackground) then
   begin
      OnCanvas.Brush.Color:=(Parent as TDiagBackground).Color;
      Canvas.Brush.Color:=(Parent as TDiagBackground).Color;
   end;
   OnCanvas.Pen.Color:=PenColor;
   if FBorderOn then
   begin
      PC:=OnCanvas.Pen.Color;
      OnCanvas.Pen.Color:=clSilver;
      OnCanvas.Rectangle(FBorderRect.Left-1,FBorderRect.Top-1,FBorderRect.Right+1,FBorderRect.Bottom+1);
      OnCanvas.MoveTo(FBorderRect.Left+(FBorderRect.Right-FBorderRect.Left) div 2,FBorderRect.Top+(FBorderRect.Bottom-FBorderRect.Top) div 2);
      OnCanvas.LineTo(Left+Width div 2,Top+Height div 2);
      OnCanvas.Pen.Color:=PC;
   end;
   if JoinList <> nil then
   begin
      for I:=0 to JoinList.Count-1 do
      begin
         DrawLink(OnCanvas,Self,JoinList[I]);
      end;
   end;
end;


end.
