unit DesignNodeBase;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, StdCtrls,Forms;

const
   DefaultNodeWidth    = 120;
   DefaultNodeHeight   = 28;
   DefaultNodeXSpace   = 20;
   DefaultNodeYSpace   = 2;
   DefaultWidth        = DefaultNodeWidth +DefaultNodeXSpace;
   DefaultHeight       = DefaultNodeHeight+DefaultNodeYSpace;
   
type
  TBaseDesignNode = class;
  
  TOnPictureClick = procedure(Sender:TBaseDesignNode) of object;
  TOnDrawItem     = procedure(Sender:TBaseDesignNode;Canvas:TCanvas;Dest:TRect;High,Mid,Low:TColor) of object;
  TOnMeasureItem  = procedure(Sender:TBaseDesignNode;var WidthValue,HeightValue:Integer) of object;
  
  TPictureState = set of (psFlat,psRaised,psLowered,psHighLight,psHidden);
  TBaseDesignNode = class(TGraphicControl)
  private
     InPlaceEdit:TEdit;
     FNodeWidth :Integer;
     FNodeHeight:Integer;
     FExpanded:Integer;
     FPicture1:TPicture;
     FPicture2:TPicture;
     FPictureState1:TPictureState;
     FPictureState2:TPictureState;
     FNodeParent:TBaseDesignNode;
     FNodeChild :TBaseDesignNode;
     FNodeNext  :TBaseDesignNode;
     FNodePrev  :TBaseDesignNode;
     FOnPicture1Click:TOnPictureClick;
     FOnPicture2Click:TOnPictureClick;
     FOnDrawItem1:TOnDrawItem;
     FOnDrawItem2:TOnDrawItem;
     FOnMeasureItem1:TOnMeasureItem;
     FOnMeasureItem2:TOnMeasureItem;
     FReadOnly:Boolean;
     function  GetCaption:TCaption;
     procedure SetCaption(Value:TCaption);
     function  GetVisible:Boolean;
     procedure SetPicture(Index:Integer;Picture:TPicture);
     procedure SetPictureState(Index:Integer;PictureState:TPictureState);
     procedure SetAssociatedNode(Index:Integer;Node:TBaseDesignNode);
     function  GetLastNodeInCol(Node:TBaseDesignNode):TBaseDesignNode;
     procedure SetColWidths(Node:TBaseDesignNode);
     function AtTopLevel:Boolean;
     function  SetNodeHeight(Node:TBaseDesignNode):Integer;
     function  MouseOnPict(Picture:Integer;Message:TWMMouse;var Dest:TRect):Boolean;
     procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
     procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
     procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
     procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
     procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
     procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
     procedure WMMove(var Message: TWMMove); message WM_MOVE;
     function TopNode:TBaseDesignNode;
     
     procedure ClearInPlace(Node:TBaseDesignNode);
     procedure CreateInPlace;
     procedure InPlaceExit(Sender:TObject);
     procedure InPlaceKeyPress(Sender:TObject;var Key:Char);
     
     procedure DrawPicture(XPos:Integer;Picture:TPicture;State:TPictureState);
     procedure DrawBEdge(Dest:TRect;High,Low:TColor);
  protected
     Low :TColor;
     Mid :TColor;
     High:TColor;
     procedure Paint; override;
     function MeasureHeight:Integer;
     procedure Get3Colours(Color:TColor;var Low,Mid,High:TColor);
     procedure SetVisible(Value:Boolean);  virtual;
     procedure SetExpanded(Value:Integer); virtual;
     procedure DoOnPicture1Click;          virtual;
     procedure DoOnPicture2Click;          virtual;
     procedure DoOnDrawItem(Dest:TRect);   virtual;
     procedure CheckPosition;              virtual;
     procedure CreateDropdown;             virtual;
     procedure FreeDropDown;               virtual;
     procedure DoOnMeasureItem(var WidthValue,HeightValue:Integer); virtual;
  public
     constructor Create(AOwner: TComponent); override;
     destructor Destroy; override;
     property OnPicture1Click:TOnPictureClick read FOnPicture1Click write FOnPicture1Click;
     property OnPicture2Click:TOnPictureClick read FOnPicture2Click write FOnPicture2Click;
     property OnDrawItem1:TOnDrawItem read FOnDrawItem1 write FOnDrawItem1;
     property OnDrawItem2:TOnDrawItem read FOnDrawItem2 write FOnDrawItem2;
     property OnMeasureItem1:TOnMeasureItem read FOnMeasureItem1 write FOnMeasureItem1;
     property OnMeasureItem2:TOnMeasureItem read FOnMeasureItem2 write FOnMeasureItem2;
     property Picture1:TPicture index 0 read FPicture1 write SetPicture stored True;
     property Picture2:TPicture index 1 read FPicture2 write SetPicture stored True;
     property PictureState1:TPictureState index 0 read FPictureState1 write SetPictureState;
     property PictureState2:TPictureState index 1 read FPictureState2 write SetPictureState;
     property Color;
     property ParentColor;
     property NodeParent:TBaseDesignNode index 0 read FNodeParent write SetAssociatedNode;
     property NodeChild :TBaseDesignNode index 1 read FNodeChild  write SetAssociatedNode;
     property NodeNext  :TBaseDesignNode index 2 read FNodeNext   write SetAssociatedNode;
     property NodePrev  :TBaseDesignNode index 3 read FNodePrev   write SetAssociatedNode;
  published
     property Caption:TCaption read GetCaption write SetCaption;
     property Visible:Boolean read GetVisible write SetVisible;
     property Font;
     property ParentFont;
     property Expanded:Integer read FExpanded write SetExpanded;
     property NodeWidth :Integer read FNodeWidth  write FNodeWidth ;
     property NodeHeight:Integer read FNodeHeight write FNodeHeight;
     property ReadOnly:Boolean read FReadOnly write FReadOnly;
  end;         
  TDesignNode = class(TBaseDesignNode)
  published
     property OnPicture1Click;
     property OnPicture2Click;
     property OnDrawItem1;
     property OnDrawItem2;
     property OnMeasureItem1;
     property OnMeasureItem2;
     property Picture1;
     property Picture2;
     property PictureState1;
     property PictureState2;
     property Color;
     property ParentColor;
  end;

implementation

{TBaseDesignNode}
procedure TBaseDesignNode.CheckPosition;
begin
end;
procedure TBaseDesignNode.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
   inherited;
   CheckPosition;
end;
procedure TBaseDesignNode.WMMove(var Message: TWMMove);
begin
   inherited;
   CheckPosition;
end;
constructor TBaseDesignNode.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   FReadOnly:=False;
   ControlStyle:=ControlStyle - [csSetCaption];
   Width :=DefaultWidth ;
   Height:=DefaultHeight;
   NodeWidth :=DefaultNodeWidth ;
   NodeHeight:=DefaultNodeHeight;
   FPicture1:=TPicture.Create;
   FPicture2:=TPicture.Create;
   FPictureState1:=[];
   FPictureState2:=[];
   FExpanded:=0;
   FNodeChild:=nil;
   FNodeParent:=nil;
   FNodePrev:=nil;
   FNodeNext:=nil;
end; 
procedure TBaseDesignNode.CreateInPlace;
begin            
   InPlaceEdit:=TEdit.Create(nil);
   if (Parent <> nil) then Parent.InsertControl(InPlaceEdit);
   with InPlaceEdit do
   begin
      Name       :='InPlaceEdit';
      Ctl3D      :=False;
      BorderStyle:=bsNone;
      Font       :=Self.Font;
      Color      :=Mid;
      TabOrder   :=0;
      Visible    :=True;
      Enabled    :=True;
      Left       :=Self.Left+(Self.Width-NodeWidth)+4;
      Width      :=(NodeWidth-FPicture1.Width)-12;
      Top        :=Self.Top+7;
      Height     :=17;
      OnExit     :=InPlaceExit;
      OnKeyPress :=InPlaceKeyPress;
      Text       :=Caption;
      SetFocus;
   end;
end;
procedure TBaseDesignNode.InPlaceKeyPress(Sender:TObject;var Key:Char);
begin
   if Key = #27 then 
   begin 
      InPlaceEdit.Text:=Caption; 
      InPlaceEdit.SelectAll; 
   end else if Key = #13 then 
   begin 
      PostMessage(InPlaceEdit.Handle,CM_EXIT,0,0); // Post call to InPlaceExit()
   end;
end;    
procedure TBaseDesignNode.InPlaceExit(Sender:TObject);
begin
  if InPlaceEdit = nil then Exit;
  if (Parent <> nil) and Parent.ContainsControl(InPlaceEdit) then 
     Parent.RemoveControl(InPlaceEdit);
  Caption:=InPlaceEdit.Text;
  InPlaceEdit.Free;
  InPlaceEdit:=nil;
end;
procedure TBaseDesignNode.ClearInPlace(Node:TBaseDesignNode);
begin
   if Node = nil then Exit;
   repeat
      Node.InPlaceExit(Node.InPlaceEdit);
      if Node.NodeChild <> nil then ClearInPlace(Node.NodeChild);
      Node:=Node.NodeNext;
   until (Node = nil);
end;  
destructor TBaseDesignNode.Destroy;
begin
//   if (NodePrev <> nil) and (NodeNext <> nil) then NodeNext.NodePrev:=NodePrev;
//   NodeChild.NodeParent:=nil;
//   NodeParent.NodeChild:=nil;
//   NodePrev.NodeNext:=nil;
//   NodeNext.NodePrev:=nil;
   FPicture1.Free;           
   FPicture2.Free;
   inherited Destroy;       
end;
function TBaseDesignNode.SetNodeHeight(Node:TBaseDesignNode):Integer;
var
   CalcHeight:Integer;
   WorkNode:TBaseDesignNode;
   function Max(A,B:Integer):Integer; begin if A > B then Result:=A else Result:=B; end;
begin                                                     
   Result:=0;
   if Node = nil then Exit;
   WorkNode:=Node;
   if (WorkNode.NodeChild <> nil) and (WorkNode.NodeChild.Visible) then
   begin
      WorkNode.NodeChild.Top:=WorkNode.Top;
      WorkNode.NodeChild.Left:=WorkNode.Left+WorkNode.Width;
      WorkNode:=WorkNode.NodeChild;
      CalcHeight:=0;
      while WorkNode <> nil do 
      begin
         CalcHeight:=CalcHeight+SetNodeHeight(WorkNode);
         WorkNode:=WorkNode.NodeNext;
      end;
      Node.Height:=Max(CalcHeight,Node.NodeHeight+DefaultNodeYSpace+Node.MeasureHeight);
   end
   else
   begin
      Node.Height:=Node.NodeHeight+DefaultNodeYSpace+Node.MeasureHeight;
   end;
   if Node.NodeNext <> nil then
   begin
      Node.NodeNext.Top:=Node.Top+Node.Height;
      Node.NodeNext.Left:=Node.Left;
   end;
   Result:=Node.Height;
end;
procedure TBaseDesignNode.SetColWidths(Node:TBaseDesignNode);
begin
   repeat
      SetNodeHeight(Node);
      Node:=Node.NodeNext;
   until (Node = nil);
end;
function TBaseDesignNode.TopNode:TBaseDesignNode;
begin
   Result:=Self;
   while (Result.NodePrev <> nil) or (Result.NodeParent <> nil) do 
   begin
      if Result.NodePrev <> nil then
         Result:=Result.NodePrev
      else
         Result:=Result.NodeParent;
   end;
end;  
function TBaseDesignNode.GetLastNodeInCol(Node:TBaseDesignNode):TBaseDesignNode;
begin
   Result:=Node;
   if Node = nil then Exit;
   while Node.NodeNext <> nil do Node:=Node.NodeNext;
   Result:=Node;
end;     
procedure TBaseDesignNode.SetAssociatedNode(Index:Integer;Node:TBaseDesignNode);
begin
   case Index of
      0 : begin // set Parent
             if FNodeParent = Node then Exit;
             if FNodeParent <> nil then 
                FNodeParent.FNodeChild :=nil;
             NodePrev:=nil;
             FNodeParent:=Node;
             if Node <> nil then 
             begin
                Node.FNodeChild :=Self; 
                Node.Invalidate;
             end;
          end;    
      1 : begin // set Child
             if FNodeChild = Node then Exit;
             if FNodeChild <> nil then 
                FNodeChild.FNodeParent:=nil; 
             FNodeChild:=Node; 
             if Node <> nil then 
                Node.FNodeParent:=Self; 
             Invalidate;
          end;
      2 : begin // set Next
             if FNodeNext = Node then Exit;
             if FNodeNext <> nil then 
                FNodeNext.FNodePrev:=nil; 
             FNodeNext:=Node; 
             if Node <> nil then 
                Node.FNodePrev:=Self; 
          end;
      3 : begin // set Previous
             if FNodePrev = Node then Exit;
             if FNodePrev <> nil then 
                FNodePrev.FNodeNext:=nil; 
             NodeParent:=nil;
             FNodePrev:=GetLastNodeInCol(Node);
             if FNodePrev <> nil then 
                FNodePrev.FNodeNext:=Self; 
          end;
   end;
   SetColWidths(TopNode);
end;
procedure TBaseDesignNode.SetPicture(Index:Integer;Picture:TPicture);
begin
   case Index of
      0 : FPicture1.Assign(Picture);
      1 : FPicture2.Assign(Picture);
   end;
   Invalidate;
end;
procedure TBaseDesignNode.SetPictureState(Index:Integer;PictureState:TPictureState);
begin
   case Index of
      0 : FPictureState1:=PictureState;
      1 : FPictureState2:=PictureState;
   end;
   Invalidate;
end;
function TBaseDesignNode.GetCaption:TCaption;
begin
   Result:=inherited Caption;
end;
procedure TBaseDesignNode.SetCaption(Value:TCaption);
begin
   inherited Caption:=Value;
   Invalidate;
end;
function TBaseDesignNode.MeasureHeight:Integer;
var
   WidthValue:Integer;
begin
   WidthValue:=Width;
   DoOnMeasureItem(WidthValue,Result);
   if Width <> WidthValue then
      Width:=WidthValue;
end;   
function TBaseDesignNode.GetVisible:Boolean;
begin
   Result:=inherited Visible;
end;
procedure TBaseDesignNode.SetVisible(Value:Boolean);
var
   Node:TBaseDesignNode;
begin
   if Visible <> Value then
   begin
      inherited Visible:=Value;
      Node:=Self;
      if  ((not Value) or (csDesigning in ComponentState)) 
      and (Node.NodeChild <> nil)                         then 
         Node.NodeChild.Visible:=Value;
      while Node.NodeNext <> nil do 
      begin
         Node:=Node.NodeNext;
         Node.Visible:=Value;
         if  ((not Value) or (csDesigning in ComponentState)) 
         and (Node.NodeChild <> nil)                         then 
            Node.NodeChild.Visible:=Value;
      end;
      SetColWidths(TopNode);
   end;
end;
procedure TBaseDesignNode.Get3Colours(Color:TColor;var Low,Mid,High:TColor);
var
   R,G,B:Byte;
   ColRGB:Integer;
begin
   ColRGB:=ColorToRGB(Color);
   R:=((ColRGB       ) and $FF) div 2;
   G:=((ColRGB shr 8 ) and $FF) div 2;
   B:=((ColRGB shr 16) and $FF) div 2;
   Low :=RGB(R,G,B);
   Mid :=RGB(R+64,G+64,B+64);
   High:=RGB(R+127,G+127,B+127);
end;
procedure TBaseDesignNode.DrawBEdge(Dest:TRect;High,Low:TColor);
begin
    with Canvas,Dest do
    begin
      Pen.Color:=High;
      PolyLine([Point(Left,Bottom-1),Point(Left,Top),Point(Right,Top)]);
      Pen.Color:=Low;
      PolyLine([Point(Left,Bottom-1),Point(Right-1,Bottom-1),Point(Right-1,Top)]);
   end;
end;     
procedure TBaseDesignNode.DrawPicture(XPos:Integer;Picture:TPicture;State:TPictureState);
var
   Source:TRect;
   Dest:  TRect;
   Wid:Integer;
begin
   if psHidden in State then Exit;
   if Picture.Width <> 0 then
   begin
      Wid:=Picture.Width div 2;
      Dest:=Bounds(XPos,(NodeHeight-Picture.Height) div 2,Wid,Picture.Height);
      with Picture do 
      begin
         if psHighLight in State then
            Source:=Bounds(Wid,0,Wid,Height)
         else
            Source:=Bounds(0,0,Wid,Height);
         Canvas.BrushCopy(Dest,BitMap,Source,BitMap.TransparentColor);
      end;
      if psRaised in State then
         DrawBEdge(Dest,High,Low)
      else if psLowered in State then
         DrawBEdge(Dest,Low,High);
   end;                      
end;
function TBaseDesignNode.AtTopLevel:Boolean;
var
   Node:TBaseDesignNode;
begin
   Node:=Self;
   while Node.NodePrev <> nil do Node:=Node.NodePrev;
   Result:=Node.NodeParent = nil;
end;
procedure TBaseDesignNode.Paint;
var
  Dest:TRect;
  TWidth:Integer;
  LOfs:Integer;
begin
   Get3Colours(Color,Low,Mid,High);
   Canvas.Font:=Font;
   LOfs:=Width-NodeWidth;
   TWidth:=LOfs+((NodeWidth-(FPicture1.Width+FPicture2.Width) div 2)-6);
   with Canvas do
   begin
      Pen.Color:=clBlack;
      
      Brush.Color:=Mid;
      Rectangle(LOfs,0,LOfs+NodeWidth,NodeHeight);
      if not AtTopLevel then
      begin
         if NodeParent <> nil then
         begin
            PolyLine([Point(LOfs,NodeHeight div 2),Point(-1,NodeHeight div 2)]);
            PolyLine([Point(LOfs,NodeHeight div 2+1),Point(-1,NodeHeight div 2+1)]);
         end
         else if (NodeNext <> nil) or (NodePrev <> nil) then
         begin
            PolyLine([Point(LOfs,NodeHeight div 2),Point(Lofs div 2,NodeHeight div 2)]);
            PolyLine([Point(LOfs,NodeHeight div 2+1),Point(Lofs div 2,NodeHeight div 2+1)]);
         end;
         if (NodeNext <> nil) then
         begin
            PolyLine([Point(Lofs div 2,NodeHeight div 2),Point(Lofs div 2,Height+1)]);
            PolyLine([Point(Lofs div 2+1,NodeHeight div 2),Point(Lofs div 2+1,Height+1)]);
         end;
         if (NodePrev <> nil) then
         begin
            PolyLine([Point(Lofs div 2,NodeHeight div 2),Point(Lofs div 2,-1)]);
            PolyLine([Point(Lofs div 2+1,NodeHeight div 2),Point(Lofs div 2+1,-1)]);
         end;
      end;   
                                                      
      Dest:=Bounds(LOfs+1,1,NodeWidth-2,NodeHeight-2);
      DrawBEdge(Dest,High,Low);
      Dest:=Bounds(LOfs+2,2,NodeWidth-4,NodeHeight-4);
      DrawBEdge(Dest,High,Low);
      
      Dest:=Bounds(LOfs+4,2,TWidth,NodeHeight-4);
      DrawText(Canvas.Handle,PChar(Caption),Length(Caption),Dest,DT_SINGLELINE or DT_VCENTER);
      
      DrawPicture(TWidth                  ,FPicture1,FPictureState1);
      DrawPicture(TWidth+(FPicture1.Width div 2)+1,FPicture2,FPictureState2);
      if Expanded > 0 then
      begin
         Dest:=Bounds(LOfs+1,NodeHeight,NodeWidth-2,MeasureHeight);
         DoOnDrawItem(Dest);
      end;
   end;
end;
function TBaseDesignNode.MouseOnPict(Picture:Integer;Message:TWMMouse;var Dest:TRect):Boolean;
var
  TWidth:Integer;
begin
  Result:=True;
  if Picture = 1 then
     TWidth:=Width-NodeWidth+(NodeWidth-(FPicture1.Width+FPicture2.Width) div 2)-6
  else
     TWidth:=Width-NodeWidth+(NodeWidth-FPicture2.Width div 2)-5;
  with Message do 
  begin
     Dest:=Bounds(TWidth,(NodeHeight-FPicture1.Height) div 2,FPicture1.Width div 2,FPicture1.Height);
     if  (XPos >= Dest.Left) and (XPos <= Dest.Right )
     and (YPos >= Dest.Top ) and (YPos <= Dest.Bottom) then
        Exit;
  end;
  Result:=False;
end;
procedure TBaseDesignNode.WMMouseMove(var Message: TWMMouseMove);
var
  Dest:TRect;
  NewState:TPictureState;
begin
  inherited;
  NewState:=FPictureState1;
  if MouseOnPict(1,Message,Dest) then
     NewState:=NewState + [psHighLight]
  else
     NewState:=NewState - [psHighLight];
  if NewState <> FPictureState1 then
  begin
     FPictureState1:=NewState;
     DrawPicture(Dest.Left,FPicture1,FPictureState1);
  end;
  
  NewState:=FPictureState2;
  if MouseOnPict(2,Message,Dest) then
     NewState:=NewState + [psHighLight]
  else
     NewState:=NewState - [psHighLight];
  if NewState <> FPictureState2 then
  begin
     FPictureState2:=NewState;
     DrawPicture(Dest.Left,FPicture2,FPictureState2);
  end;
end;
procedure TBaseDesignNode.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if psHighLight in FPictureState1 then
  begin
     FPictureState1:=FPictureState1 - [psHighLight];
     DrawPicture((Width-(FPicture1.Width+FPicture2.Width) div 2)-6,FPicture1,FPictureState1);
  end;
  if psHighLight in FPictureState2 then
  begin
     FPictureState2:=FPictureState2 - [psHighLight];
     DrawPicture((Width-FPicture2.Width div 2)-5,FPicture2,FPictureState2);
  end;
end;
procedure TBaseDesignNode.WMLButtonDblClk(var Message: TWMLButtonDblClk);
var
   Dest:TRect;
begin
  inherited;
  if (MouseOnPict(1,Message,Dest)) or (MouseOnPict(2,Message,Dest)) then 
  begin
     WMLButtonDown(Message);
     Exit;
  end;
  if not FReadOnly then CreateInPlace;
end;
procedure TBaseDesignNode.WMLButtonDown(var Message: TWMLButtonDown);
var
   Dest:TRect;
begin
  inherited;
  ClearInPlace(TopNode);
  if MouseOnPict(1,Message,Dest) then
  begin
     if psRaised in FPictureState1 then
     begin
        FPictureState1:=FPictureState1 - [psRaised];
        FPictureState1:=FPictureState1 + [psLowered];
     end
     else
     begin
        FPictureState1:=FPictureState1 + [psRaised];
        FPictureState1:=FPictureState1 - [psLowered];
     end;
     DoOnPicture1Click;
     DrawPicture((Width-(FPicture1.Width+FPicture2.Width) div 2)-6,FPicture1,FPictureState1);
  end
  else if MouseOnPict(2,Message,Dest) then
  begin
     if psRaised in FPictureState2 then
     begin
        FPictureState2:=FPictureState2 - [psRaised];
        FPictureState2:=FPictureState2 + [psLowered];
     end
     else
     begin
        FPictureState2:=FPictureState2 + [psRaised];
        FPictureState2:=FPictureState2 - [psLowered];
     end;
     DoOnPicture2Click;
     DrawPicture((Width-FPicture2.Width div 2)-5,FPicture2,FPictureState2);
  end;
end;  
procedure TBaseDesignNode.WMLButtonUp(var Message: TWMLButtonDown);
begin
  inherited;
end;
procedure TBaseDesignNode.SetExpanded(Value:Integer);
begin
   if FExpanded <> Value then
   begin
      FExpanded:=Value;
      Invalidate;
      SetColWidths(TopNode);
      if Expanded > 0 then
         CreateDropDown
      else
         FreeDropDown;
   end;                
end;                
procedure TBaseDesignNode.DoOnPicture1Click;
begin
   if Assigned(OnPicture1Click) then OnPicture1Click(Self);
   SetColWidths(TopNode);
end;                                 
procedure TBaseDesignNode.DoOnPicture2Click;
begin
   if Assigned(OnPicture2Click) then OnPicture2Click(Self);
   SetColWidths(TopNode);
end;                            
procedure TBaseDesignNode.DoOnDrawItem(Dest:TRect);
begin
   with Canvas do
   begin
      Pen.Color:=clBlack;
      Brush.Color:=Mid;
      if (Assigned(FOnDrawItem1)) and (Expanded = 1) then 
         FOnDrawItem1(Self,Canvas,Dest,High,Mid,Low)
      else if (Assigned(FOnDrawItem2)) and (Expanded = 2) then 
         FOnDrawItem2(Self,Canvas,Dest,High,Mid,Low)
      else 
         with Dest do Rectangle(Left,Top,Right,Bottom);
         
      Pen.Color:=clBlack;
      Brush.Color:=Mid;
   end;    
end;
procedure TBaseDesignNode.DoOnMeasureItem(var WidthValue,HeightValue:Integer);
begin
   WidthValue:=Width;
   HeightValue:=100;
   if Expanded = 1 then
   begin
      if Assigned(FOnMeasureItem1) then FOnMeasureItem1(Self,WidthValue,HeightValue);
   end    
   else if Expanded = 2 then
   begin
      if Assigned(FOnMeasureItem2) then FOnMeasureItem2(Self,WidthValue,HeightValue);;
   end
   else
   begin
      WidthValue:=Width;
      HeightValue:=0;
   end;
end;
procedure TBaseDesignNode.CreateDropdown;
begin
end;
procedure TBaseDesignNode.FreeDropDown;
begin
end;

end.
