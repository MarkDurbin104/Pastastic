unit DragLabelU;

interface

uses
	Math,
	Classes,
	Controls,
	Forms,
  Messages,
	Windows,
	StdCtrls;

type
	TDragLabel = class(TStaticText)
  private
  	FDragEnabled : Boolean;
    LastMouseDown : TPoint;

    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
  public
		Dragging			: Boolean;
	published
		property DragEnabled : Boolean read FDragEnabled write FDragEnabled;
  end;

implementation

procedure TDragLabel.WMLButtonDown(var Message: TWMLButtonDown);
begin
  Inherited;
  If not DragEnabled then Exit;
  LastMouseDown.x := Message.Pos.x;
  LastMouseDown.y := Message.Pos.y;
  If Message.Keys = MK_LBUTTON 	then	//no shift/ctrl
  begin
    BringToFront;
    If FocusControl <> nil then FocusControl.BringToFront;
 		Dragging := True;
  end;
end;

procedure TDragLabel.WMLButtonUp(var Message: TWMLButtonUp);
begin
  Inherited;
  If not DragEnabled then Exit;
  Dragging := False;
  Cursor := crDefault;
end;

procedure TDragLabel.WMMouseMove(var Message: TWMMouseMove);
var
	FocusControlOffset 	: TPoint;
  MousePoint   				: TPoint;
  OffSet 			 				: TPoint;
  ParentPoint 				: TPoint;
  ScreenPoint 				: TPoint;
begin
  Inherited;
  If not DragEnabled then Exit;
  Hint := Caption;

  MousePoint := Point(Message.XPos,Message.YPos);
  ScreenPoint := self.ClientToScreen(MousePoint);
  ParentPoint := Parent.ScreenToClient(ScreenPoint);
  If (ParentPoint.X <0) or (ParentPoint.Y <0) then Exit;	

  If Dragging then
  begin
  	Offset.X := ParentPoint.X - LastMouseDown.X - Left;
    Offset.Y := ParentPoint.Y - LastMouseDown.Y - Top;

    If 	((Offset.X < 0) and (Left <= 0)) 	then Offset.X := 0;
    If 	((Offset.Y < 0) and (Top <= 0)) 	then Offset.Y := 0;

    If FocusControl <> nil then
    begin
    	//move focus control in case label has been resized
      FocusControl.Left := Left + Width + 10;

    	//store focus control offset
			FocusControlOffset := Point(FocusControl.Left - Left,
      														FocusControl.Top	- Top );

      //snap focus control to grid
      FocusControl.SetBounds(Round((FocusControl.Left + Offset.X) / 10) * 10,
                             Round((FocusControl.Top  + Offset.Y) / 10) * 10,
                             FocusControl.Width,
                             FocusControl.Height);


      //adjust label
      SetBounds(FocusControl.Left - FocusControlOffset.X,
                FocusControl.Top	- FocusControlOffset.Y,
                Width, Height);
    end;
  end;
end;


end.
