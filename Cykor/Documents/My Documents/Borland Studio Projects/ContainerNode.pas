unit ContainerNode;

interface

uses  Windows,Messages,Classes,Graphics,Controls,
      DesignNode;
const
   NodeXSpacing = 10;
   NodeYSpacing = 10;

type
  THierarchyDesignNode = class(TDesignNode)
  private
    SubNodes:TList;
    FNodeParent: THierarchyDesignNode;
    FPresidence: Integer;
    procedure SetNodeParent(const Value: THierarchyDesignNode);
    procedure SetPresidence(const Value: Integer);
    function OrderNodes(Top:Integer):Integer;
  public
     property Presidence:Integer read FPresidence write SetPresidence;
     property NodeParent:THierarchyDesignNode read FNodeParent write SetNodeParent;
     function AddChild(ANode:THierarchyDesignNode):Integer;
     function SubNodeCount:Integer;
     constructor Create(AOwner:TComponent); override;
     destructor Destroy; override;
  end;

  TContainerDesignNode = class(THierarchyDesignNode)
  public
     procedure Paint; override;
  end;

procedure DrawAContainerNode(Canvas:TCanvas;InRect:TRect;Title,Caption:String;BGCol,PenCol,BrushCol:TColor;Bitmap,Icon:TBitmap);

implementation

procedure DrawAContainerNode(Canvas:TCanvas;InRect:TRect;Title,Caption:String;BGCol,PenCol,BrushCol:TColor;Bitmap,Icon:TBitmap);
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

   end;
end;
{TGroupDesignNode}
procedure TContainerDesignNode.Paint;
begin
   DrawAContainerNode(Canvas,ClientRect,
                  Title,Caption,
                  (Parent as TDiagBackground).Color,Canvas.Pen.Color,Canvas.Brush.Color,
                  Bitmap,Icon);
end;

{ THierarchyDesignNode }

function THierarchyDesignNode.AddChild(ANode:THierarchyDesignNode):Integer;
begin
   Result:=SubNodes.Add(ANode);
   ANode.NodeParent:=Self;
end;

constructor THierarchyDesignNode.Create(AOwner: TComponent);
begin
   inherited;
   SubNodes:=TList.Create;
end;

destructor THierarchyDesignNode.Destroy;
begin
  SubNodes.Free;
  inherited;
end;

function CompareNodes(Item1, Item2: Pointer): Integer;
begin
   Result:=(TObject(Item2) as THierarchyDesignNode).Presidence
          -(TObject(Item2) as THierarchyDesignNode).Presidence;
end;
function THierarchyDesignNode.OrderNodes(Top:Integer):Integer;
var
   I:Integer;
   CurrentNode:THierarchyDesignNode;
   NP:THierarchyDesignNode;
begin
   SubNodes.Sort(CompareNodes);

   Result:=Top;
   for I:=0 to SubNodes.Count-1 do
   begin
      CurrentNode:=THierarchyDesignNode(SubNodes[I]);
      if CurrentNode <> nil then
      begin
          NP:=CurrentNode.NodeParent;
          if NP <> nil then
          begin
             CurrentNode.Left:=NP.Left+NP.Width+NodeXSpacing;
             CurrentNode.Top :=Top;
             CurrentNode.Width:=NP.Width;
             CurrentNode.Height:=NP.Height;
             (Parent as TDiagBackground).NotifyPos(CurrentNode);
             Top:=CurrentNode.OrderNodes(Top);
             Inc(Top,NodeYSpacing);
          end;
      end;
   end;
   if Top = Result then
      Result:=Top+Height
   else
      Result:=Top-NodeYSpacing;
end;
function THierarchyDesignNode.SubNodeCount:Integer;
begin
   Result:=SubNodes.Count;
end;
procedure THierarchyDesignNode.SetNodeParent(const Value: THierarchyDesignNode);
var
   RootParent:THierarchyDesignNode;
begin
  if FNodeParent <> Value then
  begin
     FNodeParent:=Value;
     if FNodeParent <> nil then
     begin
        RootParent:=Value;
        while RootParent.NodeParent <> nil do
           RootParent:=RootParent.NodeParent;
        RootParent.OrderNodes(NodeYSpacing);
        Parent.Invalidate;
     end;
  end;
end;

procedure THierarchyDesignNode.SetPresidence(const Value: Integer);
var
   RootParent:THierarchyDesignNode;
begin
  if FPresidence <> Value then
  begin
     FPresidence:=Value;
     RootParent:=Self;
     while RootParent.NodeParent <> nil do
        RootParent:=RootParent.NodeParent;
     RootParent.OrderNodes(NodeYSpacing);
     Parent.Invalidate;
  end;
end;

end.
