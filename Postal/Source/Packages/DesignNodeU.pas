unit DesignNodeU;

interface

uses
  Windows,Messages,Classes,Graphics,Controls,SysUtils,ExtCtrls,PackStrListU,GPCSGUID,Printers;

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
     FKey:String;
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
     property Key     :String  read FKey      write FKey     ;
     property Cursor;
     property OnDragOver;
     property OnDragDrop;                                                         
     property OnMouseMove;
  end;
  TGroupDesignNode = class(TDesignNode)
  public
     procedure Paint; override;
  end;
  TProductDesignNode = class(TDesignNode)
  private
     FPrice:String;
     FPLU:String;
     FIsSwap:Boolean;
  public
     procedure Paint; override;
     property Price:String read FPrice write FPrice;
     property PLU:String read FPLU write FPLU;
     property IsSwap:Boolean read FIsSwap write FIsSwap;
  end;
  TFunctionDesignNode = class(TDesignNode)
  public
     procedure Paint; override;
  end;
  TUGroupDesignNode = class(TDesignNode)
  public
     procedure Paint; override;
  end;
  TWGroupDesignNode = class(TUGroupDesignNode)
  end;
  TDomainDesignNode = class(TDesignNode)
  public
     procedure Paint; override;
  end;
  TSnippetDesignNode = class(TDesignNode)
  public
     procedure Paint; override;
  end;
  TConstantDesignNode = class(TDesignNode)
  public
     procedure Paint; override;
  end;
  TPickListDesignNode = class(TDomainDesignNode)
  public
  end;
  TLookUpDesignNode = class(TDomainDesignNode)
  public
  end;
  TCustDispDesignNode = class(TDesignNode)
  public
     procedure Paint; override;
  end;
  TLogFormatDesignNode = class(TDesignNode)
  public
     procedure Paint; override;
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

procedure DrawAGroupNode(Canvas:TCanvas;InRect:TRect;Title,Caption,Key:String;BGCol,PenCol,BrushCol:TColor;Bitmap,Icon:TBitmap);
procedure DrawAProductNode(Canvas:TCanvas;InRect:TRect;IsSwap:Boolean;Price,PLU,Title,Caption,Key:String;BGCol,PenCol,BrushCol:TColor;Bitmap,Icon:TBitmap);
procedure DrawAFunctionNode(Canvas:TCanvas;InRect:TRect;Title,Caption,Key:String;BGCol,PenCol,BrushCol:TColor;Bitmap,Icon:TBitmap;ToEdge:Boolean);
procedure DrawAUGroupNode(Canvas:TCanvas;InRect:TRect;Title,Caption,Key:String;BGCol,PenCol,BrushCol:TColor;Bitmap,Icon:TBitmap);
procedure DrawADomainNode(Canvas:TCanvas;InRect:TRect;Title,Caption,Key:String;BGCol,PenCol,BrushCol:TColor;Bitmap,Icon:TBitmap);
procedure DrawASnippetNode(Canvas:TCanvas;InRect:TRect;Title,Caption,Key:String;BGCol,PenCol,BrushCol:TColor;Bitmap,Icon:TBitmap);
procedure DrawAConstantNode(Canvas:TCanvas;InRect:TRect;Title,Caption:String;BGCol,PenCol,BrushCol:TColor);
procedure DrawACustDispNode(Canvas:TCanvas;InRect:TRect;Title,Caption:String;BGCol,PenCol,BrushCol:TColor;Bitmap:TBitmap);
procedure DrawALogFormatNode(Canvas:TCanvas;InRect:TRect;Title,Caption:String;BGCol,PenCol,BrushCol:TColor;Bitmap:TBitmap);

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
procedure DrawAGroupNode(Canvas:TCanvas;InRect:TRect;Title,Caption,Key:String;BGCol,PenCol,BrushCol:TColor;Bitmap,Icon:TBitmap);
var
   R:TRect;
   DWidth,DHeight:Integer;
   FC:TColor;
begin
   with Canvas do
   begin
      Brush.Color:=BGCol;
      FillRect(InRect);
      if CurrentlyPrinting then
      begin
         InRect.Left:=InRect.Left+Pen.Width;
         InRect.Top :=InRect.Top +Pen.Width;
      end;

      Pen.Color:=clSilver;
      Brush.Color:=Pen.Color;
      DWidth :=InRect.Right-InRect.Left;
      DHeight:=InRect.Bottom-InRect.Top;
      PolyGon([Point(InRect.Left                         ,InRect.Top+DHeight div 4),
               Point(InRect.Left+DHeight div 4           ,InRect.Top+0),
               Point(InRect.Left+DWidth-(DHeight div 4)-1,InRect.Top+0),
               Point(InRect.Left+DWidth-1                ,InRect.Top+(DHeight div 4)),
               Point(InRect.Left+DWidth-1                ,InRect.Top+(DHeight-1)-(DHeight div 4)),
               Point(InRect.Left+DWidth-(DHeight div 4)-1,InRect.Top+DHeight-1),
               Point(InRect.Left+DHeight div 4           ,InRect.Top+DHeight-1),
               Point(InRect.Left+0                       ,InRect.Top+(DHeight-1)-(DHeight div 4)),
               Point(InRect.Left+0                       ,InRect.Top+DHeight div 4)]);
      Dec(DWidth ,2);
      Dec(DHeight,2);

      Brush.Color:=BrushCol;
      Pen.Color:=PenCol;
      PolyGon([Point(InRect.Left                         ,InRect.Top+DHeight div 4),
               Point(InRect.Left+DHeight div 4           ,InRect.Top+0),
               Point(InRect.Left+DWidth-(DHeight div 4)-1,InRect.Top+0),
               Point(InRect.Left+DWidth-1                ,InRect.Top+(DHeight div 4)),
               Point(InRect.Left+DWidth-1                ,InRect.Top+(DHeight-1)-(DHeight div 4)),
               Point(InRect.Left+DWidth-(DHeight div 4)-1,InRect.Top+DHeight-1),
               Point(InRect.Left+DHeight div 4           ,InRect.Top+DHeight-1),
               Point(InRect.Left+0                       ,InRect.Top+(DHeight-1)-(DHeight div 4)),
               Point(InRect.Left+0                       ,InRect.Top+DHeight div 4)]);
      MoveTo(InRect.Left+DHeight div 4-DHeight div 5,InRect.Top+DHeight div 5);
      LineTo(InRect.Left+DWidth-(DHeight div 4-DHeight div 5),InRect.Top+DHeight div 5);

      if Icon <> nil then
      begin
         R:=Bounds(InRect.Left+DWidth-(Icon.Width+3),InRect.Top+(DHeight-Icon.Height) div 2,Icon.Width,Icon.Height);
         CopyRect(R,Icon.Canvas,Bounds(0,0,Icon.Width,Icon.Height));
      end;

      Brush.Color:=BrushCol;
      if Bitmap <> nil then
      begin
         R:=Bounds(InRect.Left+(DWidth-75) div 2,InRect.Top+(DHeight-(50+3)),75,50);
         BrushCopy(R,Bitmap,Bounds(0,0,Bitmap.Width,Bitmap.Height),Bitmap.Canvas.Pixels[0,0]);
      end;
      Brush.Color:=BrushCol;

      R:=Bounds(InRect.Left,InRect.Top+1,DWidth,(DHeight div 5)-1);
      DrawText(Handle,PChar(Title),-1,R,DT_CENTER);

      Font.Style:=[fsBold];
      Brush.Style:=bsClear;
      R:=Bounds(InRect.Left+DWidth div 6,InRect.Top+0,(DWidth div 3)*2,DHeight);
      DrawText(Handle,PChar(Caption),-1,R,DT_CENTER or DT_WORDBREAK or DT_CALCRECT);
      OffsetRect(R,(((DWidth div 3)*2)-(R.Right-R.Left)) div 2,(DHeight div 5)+2);
      FC:=Font.Color;
      Font.Color:=BrushCol;
      // border around text;
      OffsetRect(R,-1,-1); DrawText(Handle,PChar(Caption),-1,R,DT_CENTER or DT_WORDBREAK);
      OffsetRect(R, 2, 0); DrawText(Handle,PChar(Caption),-1,R,DT_CENTER or DT_WORDBREAK);
      OffsetRect(R, 0, 2); DrawText(Handle,PChar(Caption),-1,R,DT_CENTER or DT_WORDBREAK);
      OffsetRect(R,-2, 0); DrawText(Handle,PChar(Caption),-1,R,DT_CENTER or DT_WORDBREAK);
      OffsetRect(R,1,-1);
      Font.Color:=FC;
      DrawText(Handle,PChar(Caption),-1,R,DT_CENTER or DT_WORDBREAK);
      Brush.Style:=bsSolid;
      Font.Style:=[];
      Brush.Color:=BrushCol;

      TextOut(InRect.Left+3,InRect.Top+DHeight div 2-TextHeight('Wg') div 2,Key);
   end;
end;
{TGroupDesignNode}
procedure TGroupDesignNode.Paint;
begin
   DrawAGroupNode(Canvas,ClientRect,
                  FTitle,FCaption,FKey,
                  (Parent as TDiagBackground).Color,Canvas.Pen.Color,Canvas.Brush.Color,
                  FBitmap,FIcon);
end;
procedure DrawAProductNode(Canvas:TCanvas;InRect:TRect;IsSwap:Boolean;Price,PLU,Title,Caption,Key:String;BGCol,PenCol,BrushCol:TColor;Bitmap,Icon:TBitmap);
var
   R:TRect;
   DWidth,DHeight:Integer;
   PriceV:Currency;
   FC:TColor;
begin
   with Canvas do
   begin
      Brush.Color:=BGCol;
      FillRect(InRect);
      Pen.Color:=clSilver;
      Brush.Color:=Pen.Color;
      if CurrentlyPrinting then
      begin
         InRect.Left:=InRect.Left+Pen.Width;
         InRect.Top :=InRect.Top +Pen.Width;
      end;
      DWidth :=InRect.Right-InRect.Left;
      DHeight:=InRect.Bottom-InRect.Top;
      RoundRect(InRect.Left,InRect.Top,InRect.Left+DWidth,InRect.Top+DHeight,DHeight div 5,DHeight div 5);
      Dec(DWidth ,2);
      Dec(DHeight,2);

      Brush.Color:=BrushCol;
      Pen.Color:=PenCol;

      RoundRect(InRect.Left,InRect.Top,InRect.Left+DWidth,InRect.Top+DHeight,DHeight div 5,DHeight div 5);
      MoveTo(InRect.Left+0,InRect.Top+DHeight div 5);  LineTo(InRect.Left+DWidth,InRect.Top+DHeight div 5);

      if Icon <> nil then
      begin
         R:=Bounds(InRect.Left+DWidth-(Icon.Width+3),InRect.Top+(DHeight-Icon.Height) div 2,Icon.Width,Icon.Height);
         CopyRect(R,Icon.Canvas,Bounds(0,0,Icon.Width,Icon.Height));
      end;

      if Bitmap <> nil then
      begin
         R:=Bounds(InRect.Left+(DWidth-75) div 2,InRect.Top+(DHeight-(50+3)),75,50);
         BrushCopy(R,Bitmap,Bounds(0,0,Bitmap.Width,Bitmap.Height),Bitmap.Canvas.Pixels[0,0]); //
      end;
      Brush.Color:=BrushCol;

      R:=Bounds(InRect.Left,InRect.Top+1,DWidth,(DHeight div 5)-1);
      if IsSwap then
      begin
         Font.Style:=[fsBold];
         DrawText(Handle,PChar('Swap To '+Title),-1,R,DT_CENTER);
         Font.Style:=[];
      end
      else
      begin
         DrawText(Handle,PChar(Title),-1,R,DT_CENTER);
      end;

      Font.Style:=[fsBold];
      Brush.Style:=bsClear;
      R:=Bounds(InRect.Left+DWidth div 6,InRect.Top+0,(DWidth div 3)*2,DHeight);
      DrawText(Handle,PChar(Caption),-1,R,DT_CENTER or DT_WORDBREAK or DT_CALCRECT);
      OffsetRect(R,(((DWidth div 3)*2)-(R.Right-R.Left)) div 2,(DHeight div 5)+2);
      FC:=Font.Color;
      Font.Color:=BrushCol;
      // border around text;
      OffsetRect(R,-1,-1); DrawText(Handle,PChar(Caption),-1,R,DT_CENTER or DT_WORDBREAK);
      OffsetRect(R, 2, 0); DrawText(Handle,PChar(Caption),-1,R,DT_CENTER or DT_WORDBREAK);
      OffsetRect(R, 0, 2); DrawText(Handle,PChar(Caption),-1,R,DT_CENTER or DT_WORDBREAK);
      OffsetRect(R,-2, 0); DrawText(Handle,PChar(Caption),-1,R,DT_CENTER or DT_WORDBREAK);
      OffsetRect(R,1,-1);
      Font.Color:=FC;
      DrawText(Handle,PChar(Caption),-1,R,DT_CENTER or DT_WORDBREAK);
      Brush.Style:=bsSolid;
      Font.Style:=[];
      Brush.Color:=BrushCol;

      TextOut(InRect.Left+3,InRect.Top+DHeight div 2-TextHeight('Wg') div 2,Key);

      Font.Style:=[fsBold];

      PriceV:=StrToCurrDef(Price,0);
      if PriceV <> 0 then
         Price:=CurrToStrF(PriceV,ffNumber,2)
      else
         Price:='';
      TextOut(InRect.Left+3,InRect.Top+DHeight-(TextHeight('Wg')+3),Price);

      if (PLU <> '') and (not (PLU[1] in ['0'..'9'])) then
         PLU:='????????'
      else
         Font.Style:=[];

      R:=Bounds(InRect.Left+DWidth-(TextWidth(PLU)+4),InRect.Top+DHeight-(TextHeight('Wg')+3),TextWidth(PLU),TextHeight('Wg'));
      Brush.Style:=bsClear;
      FC:=Font.Color;
      Font.Color:=BrushCol;
      // border around text;
      OffsetRect(R,-1,-1); DrawText(Handle,PChar(PLU),-1,R,DT_CENTER or DT_WORDBREAK);
      OffsetRect(R, 2, 0); DrawText(Handle,PChar(PLU),-1,R,DT_CENTER or DT_WORDBREAK);
      OffsetRect(R, 0, 2); DrawText(Handle,PChar(PLU),-1,R,DT_CENTER or DT_WORDBREAK);
      OffsetRect(R,-2, 0); DrawText(Handle,PChar(PLU),-1,R,DT_CENTER or DT_WORDBREAK);
      OffsetRect(R,1,-1);
      Font.Color:=FC;
      DrawText(Handle,PChar(PLU),-1,R,DT_CENTER or DT_WORDBREAK);
      Brush.Style:=bsSolid;
      Brush.Color:=BrushCol;
      Font.Style:=[];
   end;
end;
{TProductDesignNode}
procedure TProductDesignNode.Paint;
begin
   DrawAProductNode(Canvas,ClientRect,
                  FIsSwap,FPrice,FPLU,FTitle,FCaption,FKey,
                  (Parent as TDiagBackground).Color,Canvas.Pen.Color,Canvas.Brush.Color,
                  FBitmap,FIcon);
end;
{TFunctionDesignNode}
procedure DrawAFunctionNode(Canvas:TCanvas;InRect:TRect;Title,Caption,Key:String;BGCol,PenCol,BrushCol:TColor;Bitmap,Icon:TBitmap;ToEdge:Boolean);
var
   R:TRect;
   DWidth,DHeight,H:Integer;
begin
   with Canvas do
   begin
      Brush.Color:=BGCol;
      FillRect(InRect);
      if CurrentlyPrinting then
      begin
         InRect.Left:=InRect.Left+Pen.Width;
         InRect.Top :=InRect.Top +Pen.Width;
      end;

      Pen.Color:=clSilver;
      Brush.Color:=Pen.Color;
      DWidth :=InRect.Right-InRect.Left;
      DHeight:=InRect.Bottom-InRect.Top;
      if ToEdge then
         RoundRect(InRect.Left,InRect.Top,InRect.Left+DWidth,InRect.Top+DHeight,DHeight,DHeight)
      else
         RoundRect(InRect.Left,InRect.Top+DHeight div 4,InRect.Left+DWidth,InRect.Top+DHeight div 4*3,DHeight div 2,DHeight div 2);
      Dec(DWidth ,2);
      Dec(DHeight,2);

      Brush.Color:=BrushCol;
      Pen.Color:=PenCol;
      if ToEdge then
         RoundRect(InRect.Left,InRect.Top,InRect.Left+DWidth,InRect.Top+DHeight,DHeight,DHeight)
      else
         RoundRect(InRect.Left,InRect.Top+DHeight div 4,InRect.Left+DWidth,InRect.Top+DHeight div 4*3,DHeight div 2,DHeight div 2);

      if Bitmap <> nil then
      begin
         R:=Bounds(InRect.Left+DWidth-((Bitmap.Width div 2)+5),InRect.Top+(DHeight-(Bitmap.Height div 2)) div 2,Bitmap.Width div 2,Bitmap.Height div 2);
         BrushCopy(R,Bitmap,Bounds(0,0,Bitmap.Width,Bitmap.Height),Bitmap.Canvas.Pixels[0,0]);
      end;
      Brush.Color:=BrushCol;

      Font.Style:=[fsBold];
      R:=Bounds(InRect.Left+DWidth div 4,InRect.Top+0,DWidth div 2,DHeight);
      H:=DrawText(Handle,PChar(Caption),-1,R,DT_CENTER or DT_WORDBREAK or DT_CALCRECT);
      OffsetRect(R,(DWidth div 2-(R.Right-R.Left)) div 2,(DHeight-H) div 2);
      DrawText(Handle,PChar(Caption),-1,R,DT_CENTER or DT_WORDBREAK);
      Font.Style:=[];

      TextOut(InRect.Left+3,InRect.Top+DHeight div 2-TextHeight('Wg') div 2,Key);
   end;
end;
procedure TFunctionDesignNode.Paint;
begin
   DrawAFunctionNode(Canvas,ClientRect,
                  FTitle,FCaption,FKey,
                  (Parent as TDiagBackground).Color,Canvas.Pen.Color,Canvas.Brush.Color,
                  FBitmap,FIcon,False);
end;
procedure DrawAUGroupNode(Canvas:TCanvas;InRect:TRect;Title,Caption,Key:String;BGCol,PenCol,BrushCol:TColor;Bitmap,Icon:TBitmap);
var
   R:TRect;
   DWidth,DHeight:Integer;
begin
   with Canvas do
   begin
      Brush.Color:=BGCol;
      FillRect(InRect);
      if CurrentlyPrinting then
      begin
         InRect.Left:=InRect.Left+Pen.Width;
         InRect.Top :=InRect.Top +Pen.Width;
      end;
               
      Pen.Color:=clSilver;
      Brush.Color:=Pen.Color;
      DWidth :=InRect.Right-InRect.Left;
      DHeight:=InRect.Bottom-InRect.Top;
      if Icon <> nil then
      begin
         R:=Bounds(InRect.Left+DWidth-(Icon.Width+3),InRect.Top+(DHeight-Icon.Height) div 2,Icon.Width,Icon.Height);
         CopyRect(R,Icon.Canvas,Bounds(0,0,Icon.Width,Icon.Height));
      end;

      Brush.Color:=BrushCol;
      if Bitmap <> nil then
      begin
         R:=Bounds(InRect.Left+(DWidth-Bitmap.Width) div 2,InRect.Top+(DHeight-Bitmap.Height) div 2,Bitmap.Width,Bitmap.Height);
         BrushCopy(R,Bitmap,Bounds(0,0,Bitmap.Width,Bitmap.Height),Bitmap.Canvas.Pixels[0,0]);
      end;
      Brush.Color:=BrushCol;

      Pen.Color:=PenCol;
      Font.Style:=[fsBold];
      R:=Bounds(InRect.Left+DWidth div 4,InRect.Top+0,DWidth div 2,DHeight);
      DrawText(Handle,PChar(Caption),-1,R,DT_CENTER or DT_WORDBREAK or DT_CALCRECT);
      OffsetRect(R,(DWidth div 2-(R.Right-R.Left)) div 2,14);
      DrawText(Handle,PChar(Caption),-1,R,DT_CENTER or DT_WORDBREAK);
      Font.Style:=[];
   end;
end;
{TUGroupDesignNode}
procedure TUGroupDesignNode.Paint;
begin
   DrawAUGroupNode(Canvas,ClientRect,
                  FTitle,FCaption,FKey,
                  (Parent as TDiagBackground).Color,Canvas.Pen.Color,Canvas.Brush.Color,
                  FBitmap,FIcon);
end;
procedure DrawADomainNode(Canvas:TCanvas;InRect:TRect;Title,Caption,Key:String;BGCol,PenCol,BrushCol:TColor;Bitmap,Icon:TBitmap);
var
   R:TRect;
   DWidth,DHeight:Integer;
begin
   with Canvas do
   begin
      Brush.Color:=BGCol;
      FillRect(InRect);
      if CurrentlyPrinting then
      begin
         InRect.Left:=InRect.Left+Pen.Width;
         InRect.Top :=InRect.Top +Pen.Width;
      end;
               
      Pen.Color:=clSilver;
      Brush.Color:=Pen.Color;
      DWidth :=InRect.Right-InRect.Left;
      DHeight:=InRect.Bottom-InRect.Top;
      Rectangle(InRect.Left,InRect.Top,InRect.Left+DWidth,InRect.Top+DHeight);
      Dec(DWidth ,2);
      Dec(DHeight,2);

      Brush.Color:=BrushCol;
      Pen.Color:=PenCol;
      Rectangle(InRect.Left,InRect.Top,InRect.Left+DWidth,InRect.Top+DHeight);

      if Icon <> nil then
      begin
         R:=Bounds(InRect.Left+DWidth-(Icon.Width+3),InRect.Top+(DHeight-Icon.Height) div 2,Icon.Width,Icon.Height);
         CopyRect(R,Icon.Canvas,Bounds(0,0,Icon.Width,Icon.Height));
      end;
      TextOut(InRect.Left+2,InRect.Top+2,Title);
      R:=Bounds(InRect.Left+2,InRect.Top+2+TextHeight('Wg'),DWidth-(Icon.Width+3),DHeight-TextHeight('Wg'));
      Font.Style:=[fsBold];
      DrawText(Handle,PChar(Caption),-1,R,DT_WORDBREAK);
      Font.Style:=[];
   end;
end;
{TDomainDesignNode}
procedure TDomainDesignNode.Paint;
begin
   DrawADomainNode(Canvas,ClientRect,
                  FTitle,FCaption,FKey,
                  (Parent as TDiagBackground).Color,Canvas.Pen.Color,Canvas.Brush.Color,
                  FBitmap,FIcon);
end;
procedure DrawASnippetNode(Canvas:TCanvas;InRect:TRect;Title,Caption,Key:String;BGCol,PenCol,BrushCol:TColor;Bitmap,Icon:TBitmap);
var
   R:TRect;
   DWidth,DHeight:Integer;
   SL:TPackStringList;
begin
   with Canvas do
   begin
      Brush.Color:=BGCol;
      FillRect(InRect);
      if CurrentlyPrinting then
      begin
         InRect.Left:=InRect.Left+Pen.Width;
         InRect.Top :=InRect.Top +Pen.Width;
      end;

      Pen.Color:=clSilver;
      Brush.Color:=Pen.Color;
      DWidth :=InRect.Right-InRect.Left;
      DHeight:=InRect.Bottom-InRect.Top;
      Rectangle(InRect.Left,InRect.Top,InRect.Left+DWidth,InRect.Top+DHeight);
      Dec(DWidth ,2);
      Dec(DHeight,2);

      Brush.Color:=BrushCol;
      Pen.Color:=PenCol;
      Rectangle(InRect.Left,InRect.Top,InRect.Left+DWidth,InRect.Top+DHeight);

      if Bitmap <> nil then
      begin
         R:=Bounds(InRect.Left,InRect.Top,Bitmap.Width,Bitmap.Height);
         BrushCopy(R,Bitmap,Bounds(0,0,Bitmap.Width,Bitmap.Height),Bitmap.Canvas.Pixels[0,0]);
      end;
      Brush.Color:=BrushCol;
                         
      if Icon <> nil then
      begin
         R:=Bounds(InRect.Left+DWidth-(Icon.Width+3),InRect.Top+(DHeight-Icon.Height) div 2,Icon.Width,Icon.Height);
         CopyRect(R,Icon.Canvas,Bounds(0,0,Icon.Width,Icon.Height));
      end;
      TextOut(InRect.Left+(Bitmap.Width-4),InRect.Top+2,Title);
      SL:=TPackStringList.Create;
      SL.CommaText:=Caption;
      if SL.Count > 0 then
      begin
         SL[0]:=Copy(SL[0],2,Length(SL[0])-7);
         R:=Bounds(InRect.Left+Bitmap.Width+2,InRect.Top+5+TextHeight('Wg'),(DWidth div 4)*3,DHeight-TextHeight('Wg'));
         DrawText(Handle,PChar(SL[0]),-1,R,DT_WORDBREAK);
      end;
      SL.Free;
   end;
end;
{TSnippetDesignNode}
procedure TSnippetDesignNode.Paint;
begin
   DrawASnippetNode(Canvas,ClientRect,
                  FTitle,FCaption,FKey,
                  (Parent as TDiagBackground).Color,Canvas.Pen.Color,Canvas.Brush.Color,
                  FBitmap,FIcon);
end;
procedure DrawAConstantNode(Canvas:TCanvas;InRect:TRect;Title,Caption:String;BGCol,PenCol,BrushCol:TColor);
var
   DWidth,DHeight:Integer;
begin
   with Canvas do
   begin
      Brush.Color:=BGCol;
      FillRect(InRect);
      if CurrentlyPrinting then
      begin
         InRect.Left:=InRect.Left+Pen.Width;
         InRect.Top :=InRect.Top +Pen.Width;
      end;

      Pen.Color:=clSilver;
      Brush.Color:=Pen.Color;
      DWidth :=InRect.Right-InRect.Left;
      DHeight:=InRect.Bottom-InRect.Top;
      RoundRect(InRect.Left,InRect.Top,InRect.Left+DWidth,InRect.Top+DHeight,DHeight,DHeight);
      Dec(DWidth ,2);
      Dec(DHeight,2);

      Brush.Color:=BrushCol;
      Pen.Color:=PenCol;
      RoundRect(InRect.Left,InRect.Top,InRect.Left+DWidth,InRect.Top+DHeight,DHeight,DHeight);
      TextOut(InRect.Left+(DWidth-TextWidth(Title)) div 2,InRect.Top+1,Title);
      Font.Style:=[fsBold];
      TextOut(InRect.Left+(DWidth-TextWidth(Caption)) div 2,InRect.Top+1+TextHeight('Wg'),Caption);
      Font.Style:=[];
   end;
end;
{TSnippetDesignNode}
procedure TConstantDesignNode.Paint;
begin
   DrawAConstantNode(Canvas,ClientRect,
                  FTitle,FCaption,
                  (Parent as TDiagBackground).Color,Canvas.Pen.Color,Canvas.Brush.Color);
end;
procedure DrawACustDispNode(Canvas:TCanvas;InRect:TRect;Title,Caption:String;BGCol,PenCol,BrushCol:TColor;Bitmap:TBitmap);
var
   R:TRect;
   FF:TFont;
begin
   with Canvas do
   begin
      FF:=Font;
      Brush.Color:=BGCol;
      FillRect(InRect);
      if CurrentlyPrinting then
      begin
         InRect.Left:=InRect.Left+Pen.Width;
         InRect.Top :=InRect.Top +Pen.Width;
      end;

      Brush.Color:=BrushCol;
      if Bitmap <> nil then
      begin
         R:=Bounds(InRect.Left,InRect.Top,Bitmap.Width,Bitmap.Height);
         BrushCopy(R,Bitmap,Bounds(0,0,Bitmap.Width,Bitmap.Height),Bitmap.Canvas.Pixels[0,0]);
      end;

      Pen.Color:=PenCol;
      Font.Name:='Courier New';
      if CurrentlyPrinting then
      begin
         Font.Color:=clWhite;
         Font.Style:=[fsBold];
      end
      else
      begin
         Font.Color:=clLime;
      end;
      Brush.Style:=bsClear;
      Brush.Color:=clBlack;
      TextOut(InRect.Left+9,InRect.Top,Title);
      TextOut(InRect.Left+9,InRect.Top+TextHeight('Wg'),Caption);
      Brush.Style:=bsSolid;
      Brush.Color:=BrushCol;
      Font.Style:=[];
      Font:=FF;
   end;
end;
{TCustDispDesignNode}
procedure TCustDispDesignNode.Paint;
begin
   DrawACustDispNode(Canvas,ClientRect,
                  FTitle,FCaption,(Parent as TDiagBackground).Color,Canvas.Pen.Color,Canvas.Brush.Color,FBitmap);
end;

procedure DrawALogFormatNode(Canvas:TCanvas;InRect:TRect;Title,Caption:String;BGCol,PenCol,BrushCol:TColor;Bitmap:TBitmap);
var
   R:TRect;
   SL:TPackStringList;
   S,ValueStr:String;
   I,Ofs:Integer;
begin
   with Canvas do
   begin
      Brush.Color:=BGCol;
      FillRect(InRect);
      if CurrentlyPrinting then
      begin
         InRect.Left:=InRect.Left+Pen.Width;
         InRect.Top :=InRect.Top +Pen.Width;
      end;

      Brush.Color:=BrushCol;
      if Bitmap <> nil then
      begin
         R:=Bounds(InRect.Left,InRect.Top,Bitmap.Width,Bitmap.Height);
         BrushCopy(R,Bitmap,Bounds(0,0,Bitmap.Width,Bitmap.Height),Bitmap.Canvas.Pixels[0,0]);
      end;
      Brush.Color:=BrushCol;
      Pen.Color:=PenCol;
      PolyLine([Point(R.Left,R.Bottom),Point(InRect.Left,InRect.Bottom-1),Point(R.Right-1,InRect.Bottom-1),Point(InRect.Right-1,R.Bottom-1)]);

      Font.Style:=[fsBold];
      Font.Color:=PenCol;
      TextOut(InRect.Left+2,R.Bottom,Title);
      Font.Style:=[];
      SL:=TPackStringList.Create;
      SL.CommaText:=Caption;
      ValueStr:='';
      if SL.Count > 1 then
      begin
         ValueStr:=SL[1];
         SL.CommaText:=SL[0];
      end;
      Ofs:=R.Bottom+TextHeight('Wg');
      S:='';
      for I:=0 to SL.Count-1 do
      begin
         if SL[I] <> '^' then
         begin
            S:=S+' '+SL[I];
         end
         else
         begin
           TextOut(InRect.Left+2,Ofs,S);
           S:='';
           Inc(Ofs,TextHeight('Wg'));
         end;
      end;
      if S <> '' then
         TextOut(InRect.Left+2,Ofs,S);
      TextOut(R.Right-(TextWidth(ValueStr)+2),Ofs+TextHeight('Wg'),ValueStr);
   end;
end;
{TLogFormatDesignNode}
procedure TLogFormatDesignNode.Paint;
begin
   DrawALogFormatNode(Canvas,ClientRect,
                  FTitle,FCaption,(Parent as TDiagBackground).Color,Canvas.Pen.Color,Canvas.Brush.Color,FBitmap);
end;

end.
