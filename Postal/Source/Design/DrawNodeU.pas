unit DrawNodeU;

interface

uses
   Windows,Graphics,Classes,Controls,SysUtils,
   Utils,ParseNode,GPCSGUID,GPCSBase_TLB,Compress,Bin2String,CompressU,CompInspector;
const
   NodeWidth      = 200;   
   NodeHeight     = 36;   
   NodeVSpace     = 10;   
   NodeHSpace     = 10;   
   HalfNodeVSpace = NodeVSpace div 2;
   HalfNodeHSpace = NodeHSpace div 2;
   ButtonWidth    = 15;
   
   GroupColor     = $00C00000; // 0BRG
   ProductColor   = $000000C0;
   SwapToColor    = $000040C0;
   FunctionColor  = $0000C0C0;
   DomainColor    = $00C0C000;
   
   ShowBitmaps:Boolean = True;
   PictureServer:IPictureServer = nil;
   PictureList  :TStringList    = nil;
   
type
  TDrawNode = class(TCustomControl)
  protected
     HintRect:TRect;
     FChildren:TList;
     FParentDNode:TDrawNode;
     FNodeColor:TColor;
     FFlagAsError:Boolean;
     FExpanded:Boolean;
     FGraphic:TBitmap;
     CompInspector:TCompInspector;
  protected
     procedure Paint; override;
     procedure SetExpanded(Value:Boolean);
     procedure ForceExpanded(Value:Boolean);
     function GetChild(Index:Integer):TDrawNode;
     function GetCount:Integer;
     function GetHeight:Integer;
     procedure SetHeight(Value:Integer);
     procedure SetVisible(Value:Boolean);
     function  GetVisible:Boolean;
     procedure ToggleExpand(Recurse:Boolean);
     procedure ToggleCompInspector(Recurse:Boolean);
     procedure ReCalcFromTop;
     procedure ReCalc;
  public         
     constructor Create(Owner:TComponent); override;
     destructor Destroy; override;
     procedure MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer); override;
     procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
     procedure SetCompInspectorData; virtual;
     function Add(Child:TDrawNode):Integer;
     procedure Delete(Index:Integer);
     procedure SetNode(Node:TNode); virtual; abstract;
     property Count:Integer read GetCount;
     property Child[Index:Integer]:TDrawNode read GetChild;
     property ParentDNode:TDrawNode read FParentDNode write FParentDNode;
     procedure PaintHintRect(Canvas:TCanvas); virtual;
     function  CalcHintRect(Canvas:TCanvas;MaxWidth:Integer):TRect; virtual;
  published  
     property ParentFont;
     property ParentColor;
     property Color;
     property Font;
     property Caption;
     property Height:Integer read GetHeight write SetHeight;
     property FlagAsError:Boolean read FFlagAsError write FFlagAsError;
     property Expanded:Boolean read FExpanded write SetExpanded;
     property Visible:Boolean read GetVisible write SetVisible;
  end;
  TGroupDrawNode = class(TDrawNode)
  private
     FNode:TGroupNode;
  public
     constructor Create(Owner:TComponent); override;
     procedure SetNode(Node:TNode); override;
     procedure SetCompInspectorData; override;
     property Node:TGroupNode read FNode;
     procedure PaintHintRect(Canvas:TCanvas); override;
     function  CalcHintRect(Canvas:TCanvas;MaxWidth:Integer):TRect; override;
     procedure AddNodes(Parser:TParser);
  end;
  TProductDrawNode = class(TDrawNode)
  private
     FNode:TProdNode;
  public
     constructor Create(Owner:TComponent); override;
     procedure SetNode(Node:TNode); override;
     procedure SetCompInspectorData; override;
     property Node:TProdNode read FNode;
     procedure PaintHintRect(Canvas:TCanvas); override;
     function  CalcHintRect(Canvas:TCanvas;MaxWidth:Integer):TRect; override;
     procedure AddNodes(Parser:TParser);
  end;         
  TSwapToDrawNode = class(TProductDrawNode)
  public
     constructor Create(Owner:TComponent); override;
  end;
  TFunctionDrawNode = class(TDrawNode)
  public
     constructor Create(Owner:TComponent); override;
     procedure SetNode(Node:TNode); override;
  end;
  TDomainDrawNode = class(TDrawNode)
  private
     FNode:TDomainNode;
  public
     constructor Create(Owner:TComponent); override;
     procedure SetNode(Node:TNode); override;
     procedure SetCompInspectorData; override;
     property Node:TDomainNode read FNode;
  end;
  TDrawNodeHint = class(THintWindow)
  protected
    procedure Paint; override;
  public
    function CalcHintRect(MaxWidth: Integer; const AHint: string; AData: Pointer): TRect; override;
  end;
  
var
  CurrentNode:TDrawNode;
  DrawNodeHint:TDrawNodeHint;
  
implementation
{TDrawNodeHint}
procedure TDrawNodeHint.Paint;
begin
   if CurrentNode = nil then
      inherited Paint
   else
     CurrentNode.PaintHintRect(Canvas);
end;
function TDrawNodeHint.CalcHintRect(MaxWidth: Integer; const AHint: string; AData: Pointer): TRect;
begin
   if CurrentNode = nil then
      Result:=inherited CalcHintRect(MaxWidth,AHint,AData)
   else
      Result:=CurrentNode.CalcHintRect(Canvas,MaxWidth);
end;
{TDrawNode}
constructor TDrawNode.Create(Owner:TComponent);
begin
   inherited Create(Owner);
   Width:=NodeWidth+NodeHSpace;
   Inherited Height:=NodeHeight+NodeVSpace div 2;
   FChildren:=TList.Create;
   FFlagAsError:=False;
   FExpanded:=False;
   Visible:=False;
   FGraphic:=nil;
   FNodeColor:=$FFFFFF;
   ShowHint:=True;
end;
destructor TDrawNode.Destroy;
begin
   FChildren.Free;
   inherited Destroy;
end;
procedure TDrawNode.PaintHintRect(Canvas:TCanvas);
begin
end;
function TDrawNode.CalcHintRect(Canvas:TCanvas;MaxWidth:Integer):TRect;
begin
   Result:=Rect(0,0,0,0);
end;
procedure TDrawNode.ReCalc;
var
   I:Integer;
begin
   if CompInspector <> nil then
   begin
      CompInspector.Left:=Left+HalfNodeHSpace;
      CompInspector.Top:=Top+NodeHeight;
   end;
   if (Count > 0) then
   begin
      for I:=0 to Count-1 do Child[I].ReCalc;
      Child[0].Top:=Top;
      for I:=1 to Count-1 do 
      begin
         Child[I].Left:=Left+Width;
         Child[I].Top:=Child[I-1].Top+Child[I-1].Height;

         
      end;
      for I:=0 to Count-1 do Child[I].ReCalc;
   end;                                  
   Height:=Height;
end;
procedure TDrawNode.ReCalcFromTop;
var
   TopNode:TDrawNode;
begin
   TopNode:=Self;
   while TopNode.ParentDNode <> nil do TopNode:=TopNode.ParentDNode;
   TopNode.ReCalc;
end;
procedure TDrawNode.SetVisible(Value:Boolean);
var                          
   I:Integer;
begin
   if inherited Visible <> Value then
   begin
      inherited Visible:=Value;
      if (CompInspector <> nil) and (not Value) and CompInspector.Visible then
         CompInspector.Visible:=False;
      if FExpanded then
         for I:=0 to Count-1 do
            Child[I].Visible:=Value;
   end;
end;
function TDrawNode.GetVisible:Boolean;
begin
   Result:=inherited Visible;
end;
procedure TDrawNode.ForceExpanded(Value:Boolean);
var
   I:Integer;
begin
   FExpanded:=Value;
   Visible:=Value;
   for I:=0 to Count-1 do Child[I].ForceExpanded(Value);
end;
procedure TDrawNode.SetExpanded(Value:Boolean);
var
   I:Integer;
begin
   if FExpanded <> Value then
   begin
      if Value then FExpanded:=Value;
      for I:=0 to Count-1 do
         Child[I].Visible:=Value;
      FExpanded:=Value;
      ReCalcFromTop;
      Invalidate;
      Parent.Invalidate;
   end;
end;
procedure TDrawNode.ToggleExpand(Recurse:Boolean);
begin
   if Recurse then
   begin
      ForceExpanded(not Expanded);
      Visible:=True;
      Expanded:=not Expanded;
      Expanded:=not Expanded;
   end
   else
      Expanded:=not Expanded;
end;
procedure TDrawNode.ToggleCompInspector(Recurse:Boolean);
begin
   if CompInspector = nil then
   begin
      CompInspector:=TCompInspector.Create(nil);
      Parent.InsertControl(CompInspector);
      CompInspector.Width:=NodeWidth;
      CompInspector.Height:=300;
      CompInspector.Visible:=True;
      CompInspector.Color:=FaceColor(FNodeColor);
      SetCompInspectorData;
   end
   else
   begin
      CompInspector.Visible:=not CompInspector.Visible;
   end;
   CompInspector.Left:=Left+HalfNodeHSpace;
   CompInspector.Top:=Top+NodeHeight;
   ReCalcFromTop;
   Invalidate;
   if FParentDNode <> nil then
      ParentDNode.Invalidate;
end;
procedure TDrawNode.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
   if  (X > HalfNodeHSpace)
   and (X < (NodeWidth+HalfNodeHSpace))
   and (Y > 1)
   and (Y < NodeHeight) then
   begin
     Hint:='a';
     CurrentNode:=Self
   end
   else
   begin
     Hint:='';
     CurrentNode:=nil;
   end;
  Inherited MouseMove(Shift,X,Y);
end;
procedure TDrawNode.MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
begin
   if (Count > 0) 
   and (X > (NodeWidth+HalfNodeHSpace)-(ButtonWidth+3))
   and (X < (NodeWidth+HalfNodeHSpace)-5)
   and (Y > 3)
   and (Y < ButtonWidth) then
      ToggleExpand(ssShift in Shift)
   else if not (Self is TFunctionDrawNode)
   and (X > (NodeWidth+HalfNodeHSpace)-(ButtonWidth+3))
   and (X < (NodeWidth+HalfNodeHSpace)-5)
   and (Y > ButtonWidth+5)
   and (Y < ButtonWidth*2+5) then
      ToggleCompInspector(ssShift in Shift)
   else
      Inherited MouseDown(Button,Shift,X,Y);
end;
function TDrawNode.GetHeight:Integer;
var
   I,H:Integer;
begin
   if FExpanded and (Count > 0) then
   begin
      H:=0;
      for I:=0 to Count-1 do
         H:=H+Child[I].Height;
       if (CompInspector <> nil) and CompInspector.Visible and (H < NodeHeight+HalfNodeVSpace+CompInspector.Height) then
          H:=NodeHeight+HalfNodeVSpace+CompInspector.Height;
       if H < NodeHeight+HalfNodeVSpace then
          H:=NodeHeight+HalfNodeVSpace;
   end
   else
      if (CompInspector <> nil) and CompInspector.Visible then
         H:=NodeHeight+HalfNodeVSpace+CompInspector.Height
      else
         H:=NodeHeight+HalfNodeVSpace;
   Result:=H;
end;
procedure TDrawNode.SetHeight(Value:Integer);
begin
   Inherited Height:=Value;
end;
function TDrawNode.GetChild(Index:Integer):TDrawNode;
begin
   if Index < Count then
      Result:=TDrawNode(FChildren[Index])
   else
      Result:=nil;
end;   
function TDrawNode.GetCount:Integer;
begin
   Result:=FChildren.Count;
end;
function TDrawNode.Add(Child:TDrawNode):Integer;
begin
   Result:=FChildren.Add(Child);
   Child.ParentDNode:=Self;
   Child.Left:=Left+Width;
   if Result = 0 then
      Child.Top:=Top
   else
      Child.Top:=GetChild(Result-1).Top+GetChild(Result-1).Height;
   if not FExpanded then
      Child.Visible:=False;
end;  
procedure TDrawNode.Delete(Index:Integer);
begin
   if Index < FChildren.Count then
   begin
      if Child[Index].Parent <> nil then
         Child[Index].Parent.RemoveControl(Child[Index]);
      Child[Index].Free;
      FChildren.Delete(Index);
   end;
end;
procedure TDrawNode.Paint;
var
   R:TRect;
   Le,Ri,CH,I:Integer;
begin
   if inherited Height <> Height then
      Height:=Height;
   if Parent <> nil then
      Canvas.Brush.Color:=Parent.Brush.Color;
   Canvas.FillRect(ClientRect);
   if FFlagAsError then
     Canvas.Font.Color:=clRed
   else
      Canvas.Font.Color:=clWhite;
   Canvas.Font.Style:=[fsBold];
   R:=Bounds(HalfNodeHSpace,0,NodeWidth,NodeHeight);
   PaintButton(R,Canvas,FNodeColor);
   if (ShowBitmaps) and (FGraphic <> nil) then
   begin
      Brush.Style:=bsClear;
      Canvas.BrushCopy(Bounds(R.Left+2,R.Top+2,37,25),FGraphic,Bounds(0,0,FGraphic.Width,FGraphic.Height),FGraphic.Canvas.Pixels[0,0]);
      Brush.Style:=bsSolid;
      R.Right:=(R.Right-ButtonWidth);
      R.Left:=R.Left+40;
   end
   else
   begin
      R.Right:=R.Right-ButtonWidth;
   end;
   CentreTextHV(Canvas,R,Caption);
   Canvas.Brush.Color:=Color;
   if (Count > 0) then
   begin
      Le:=R.Right+1;
      Ri:=R.Top+1;
      Canvas.Rectangle(Le,Ri,R.Right+ButtonWidth-2,R.Top+ButtonWidth-2);
      Canvas.PolyLine([Point(Le+2,Ri+ButtonWidth div 2-1),
                       Point(Le+ButtonWidth-5,Ri+ButtonWidth div 2-1)]);
      Canvas.PolyLine([Point(Le+2,Ri+ButtonWidth div 2-2),
                       Point(Le+ButtonWidth-5,Ri+ButtonWidth div 2-2)]);
      if not FExpanded then
      begin
         Canvas.PolyLine([Point(Le+ButtonWidth div 2-2,Ri+2),
                          Point(Le+ButtonWidth div 2-2,Ri+ButtonWidth-5)]);
         Canvas.PolyLine([Point(Le+ButtonWidth div 2-1,Ri+2),
                          Point(Le+ButtonWidth div 2-1,Ri+ButtonWidth-5)]);
      end;
   end;
   if not (Self is TFunctionDrawNode) then
   begin
      if (CompInspector = nil) or (not CompInspector.Visible) then
         Canvas.PolyGon([Point(R.Right+1,R.Top+ButtonWidth+2),
                         Point(R.Right+((ButtonWidth-2) div 2),R.Top+(ButtonWidth*2)-1),
                         Point(R.Right+(ButtonWidth-2),R.Top+ButtonWidth+2),
                         Point(R.Right+1,R.Top+ButtonWidth+2)])
      else
         Canvas.PolyGon([Point(R.Right+1,R.Top+(ButtonWidth*2)-1),
                         Point(R.Right+((ButtonWidth-2) div 2),R.Top+ButtonWidth+2),
                         Point(R.Right+(ButtonWidth-2),R.Top+(ButtonWidth*2)-1),
                         Point(R.Right+1,R.Top+(ButtonWidth*2)-1)])
//         Canvas.Rectangle(R.Right+1,R.Top+ButtonWidth+2,R.Right+ButtonWidth-2,R.Top+(ButtonWidth*2)-1);
   end;
   if (Count > 0) and FExpanded then
   begin
      CH:=0;
      for I:=0 to Count-2 do Inc(CH,Child[I].Height);
      Canvas.PolyLine([Point(NodeWidth+HalfNodeHSpace,NodeHeight div 2),
                       Point(Width-1,NodeHeight div 2),
                       Point(Width-1,CH+(NodeHeight div 2)+1)]);
   end;
   if Self.FParentDNode <> nil then
      Canvas.PolyLine([Point(0,NodeHeight div 2),Point(HalfNodeHSpace,NodeHeight div 2)]);
end;
procedure TDrawNode.SetCompInspectorData;
var
   I:Integer;
   H:Integer;
begin
   CompInspector.RePaint;
   H:=0;
   for I:=0 to CompInspector.Count-1 do
       Inc(H,CompInspector.Items[I].ItemHeight);
   if H < 31 then H:=31;
   CompInspector.Height:=H+5;
end;
{TGroupDrawNode}
constructor TGroupDrawNode.Create(Owner:TComponent);
begin
   inherited Create(Owner);
   FNodeColor:=GroupColor;
end;
procedure TGroupDrawNode.SetNode(Node:TNode);
begin
   FNode:=TGroupNode(Node);
   if (FGraphic = nil) and (FNode <> nil) then
      FGraphic:=FNode.Image;
end;
procedure TGroupDrawNode.SetCompInspectorData;
begin
   if FNode <> nil then
   begin
      CompInspector.Add      ('Name'        ,itString,FNode.NodeName );
      CompInspector.Add      ('Title'       ,itString,FNode.Title    );
      CompInspector.Add      ('Prompt'      ,itString,FNode.Prompt   );
      CompInspector.Add      ('Hint'        ,itString,FNode.Hint     );
      CompInspector.AddBitMap('Image'       ,FNode.BitMap,FNode.Image);
      CompInspector.Add      ('GUID'        ,itString,FNode.GUID        );
      CompInspector.Add      ('RegDesc'     ,itString,FNode.RegDesc     );
      CompInspector.Add      ('ProgID'      ,itString,FNode.ProgID      );
      CompInspector.Add      ('Version'     ,itString,FNode.Version     );
      CompInspector.Add      ('ProjectFiles',itString,FNode.ProjectFiles);
      CompInspector.Add      ('SubGroup'    ,itString,FNode.SubGroup    );
      if FNode.DontBuild then
         CompInspector.Add      ('Build',itComboBox,'False,True,False')
      else
         CompInspector.Add      ('Build',itComboBox,'True,True,False');
   end;
   inherited SetCompInspectorData;
end;
procedure TGroupDrawNode.PaintHintRect(Canvas:TCanvas);
var
   I:Integer;
begin
   Canvas.Font.Color:=clInfoText;
   with Canvas do
   begin
      Font.Style:=[fsBold];
      TextOut((HintRect.Right-TextWidth(Caption)) div 2,2,Caption);
      PolyLine([Point(0,TextHeight(Caption)+4),Point(HintRect.Right,TextHeight(Caption)+4)]);
      Font.Style:=[];
      for I:=0 to Count-1 do
         TextOut(5,10+(I+1)*TextHeight('Wg'),'F'+IntToStr(I+1)+' '+Child[I].Caption);
   end; 
end;
function  TGroupDrawNode.CalcHintRect(Canvas:TCanvas;MaxWidth:Integer):TRect;
var
   I,W,TW:Integer;
begin
   with Canvas do
   begin
      Font.Style:=[fsBold];
      W:=TextWidth(Caption);    
      Font.Style:=[];
      for I:=0 to Count-1 do
      begin
         TW:=TextWidth('F'+IntToStr(I+1)+' '+Child[I].Caption);
         if TW > W then W:=TW;
      end;
      Result:=Bounds(0,0,W+10,TextHeight('Wg')*(Count+1)+14);
      HintRect:=Result;
   end;
end;    
procedure TGroupDrawNode.AddNodes(Parser:TParser);
var
   SGDrawNode:TGroupDrawNode;
   SPDrawNode:TProductDrawNode;
   SFDrawNode:TFunctionDrawNode;
   I:Integer;                 
begin
   for I:=0 to Node.Count-1 do
   begin
      if Node.ItemNode[I] is TGroupNode then
      begin
         SGDrawNode:=TGroupDrawNode.Create(nil);
         Parent.InsertControl(SGDrawNode);
         SGDrawNode.Caption:=Node.ItemNode[I].Title;
         SGDrawNode.SetNode(Node.ItemNode[I]);
         Add(SGDrawNode);
         SGDrawNode.AddNodes(Parser);
      end
      else if Node.ItemNode[I] is TProdNode then
      begin
         SPDrawNode:=TProductDrawNode.Create(nil);
         Parent.InsertControl(SPDrawNode);
         SPDrawNode.Caption:=Node.ItemNode[I].Title;
         SPDrawNode.SetNode(Node.ItemNode[I]);
         Add(SPDrawNode);
         SPDrawNode.AddNodes(Parser);
      end
      else
      begin
         SFDrawNode:=TFunctionDrawNode.Create(nil);
         Parent.InsertControl(SFDrawNode);
         SFDrawNode.Caption:=Node.Item[I];
         SFDrawNode.SetNode(nil);
         Add(SFDrawNode);       
      end;
   end;
end;
{TProductDrawNode}
constructor TProductDrawNode.Create(Owner:TComponent);
begin
   inherited Create(Owner);
   FNodeColor:=ProductColor;
end;
procedure TProductDrawNode.AddNodes;
var
   SPDrawNode:TProductDrawNode;
   SFDrawNode:TFunctionDrawNode;
   SDDrawNode:TDomainDrawNode;
   SSDrawNode:TSwapToDrawNode;
   Node:TNode;
   TotalDomain:TDomainNode;
   I:Integer;
begin
   if FNode = nil then Exit;
   TotalDomain:=nil;
   for I:=0 to FNode.Domains.Count-1 do
   begin
      SDDrawNode:=TDomainDrawNode.Create(nil);
      Parent.InsertControl(SDDrawNode);
      if FNode.Domain[I] = nil then
      begin
         SDDrawNode.FlagAsError:=True;
         SDDrawNode.Caption:=FNode.Domains[I];
      end
      else
      begin
         SDDrawNode.Caption:=FNode.Domain[I].Title;
         if FNode.Domain[I].TotalInDomain <> nil then
            TotalDomain:=FNode.Domain[I].TotalInDomain;
         SDDrawNode.SetNode(FNode.Domain[I]);
      end;
      Add(SDDrawNode);
   end;
   for I:=0 to FNode.Count-1 do
   begin
      if FNode.ItemNode[I] is TProdNode then
      begin
         if Copy(FNode.Item[I],1,7) = 'SwapTo.' then
         begin
            Node:=Parser.Nodes.Products.GetItemByName(Copy(FNode.Item[I],8,999));
            if Node <> nil then
            begin
               SSDrawNode:=TSwapToDrawNode.Create(nil);
               SSDrawNode.SetNode(Node);
               Parent.InsertControl(SSDrawNode);
               SSDrawNode.Caption:=SSDrawNode.Node.Title;
               Add(SSDrawNode);
               SSDrawNode.AddNodes(Parser);
            end;
         end
         else if FNode.ItemNode[I] = nil then
         begin
            SFDrawNode:=TFunctionDrawNode.Create(nil);
            Parent.InsertControl(SFDrawNode);
            SFDrawNode.Caption:=FNode.Item[I];
            SFDrawNode.SetNode(nil);
            Add(SFDrawNode);
         end
         else
         begin
            SPDrawNode:=TProductDrawNode.Create(nil);
            Parent.InsertControl(SPDrawNode);
            SPDrawNode.Caption:=FNode.ItemNode[I].Title;
            SPDrawNode.SetNode(FNode.ItemNode[I]);
            Add(SPDrawNode);
            SPDrawNode.AddNodes(Parser);
         end;
      end;
   end;
   if TotalDomain <> nil then
   begin
      SDDrawNode:=TDomainDrawNode.Create(nil);
      Parent.InsertControl(SDDrawNode);
      SDDrawNode.Caption:=TotalDomain.Title;
      Add(SDDrawNode);
      SDDrawNode.SetNode(TotalDomain);
   end;
end;
procedure TProductDrawNode.SetNode(Node:TNode);
begin
   FNode:=TProdNode(Node);
   if (FGraphic = nil) and (FNode <> nil) then
      FGraphic:=FNode.Image;
end;
procedure TProductDrawNode.PaintHintRect(Canvas:TCanvas);
var
   I,J:Integer;
   DNode:TDomainDrawNode;
   PW,W:Integer;
begin
   Canvas.Font.Color:=clInfoText;
   with Canvas do
   begin
      Font.Style:=[fsBold];
      TextOut((HintRect.Right-TextWidth(Caption)) div 2,2,Caption);
      PolyLine([Point(0,TextHeight(Caption)+4),Point(HintRect.Right,TextHeight(Caption)+4)]);
      Font.Style:=[];
      PW:=0;
      for I:=0 to Count-1 do
      begin
         if Child[I] is TDomainDrawNode then
         begin
            W:=TextWidth((Child[I] as TDomainDrawNode).FNode.Prompt+':');
            if W > PW then PW:=W;
         end;
      end;
      J:=0;
      for I:=0 to Count-1 do
      begin
         if Child[I] is TDomainDrawNode then
         begin
            DNode:=Child[I] as TDomainDrawNode;
            if DNode.FNode.FmtData <> '' then
               TextOut(5+PW-TextWidth(DNode.FNode.Prompt+':'),10+(J+1)*TextHeight('Wg'),DNode.FNode.Prompt+': '+DNode.FNode.Format+'('+DNode.FNode.FmtData+')')
            else
            begin
               if J < FNode.DomainParams.Count then
                  TextOut(5+PW-TextWidth(DNode.FNode.Prompt+':'),10+(J+1)*TextHeight('Wg'),DNode.FNode.Prompt+': '+DNode.FNode.Format+'<-'+FNode.DomainParams[J])
               else
                  TextOut(5+PW-TextWidth(DNode.FNode.Prompt+':'),10+(J+1)*TextHeight('Wg'),DNode.FNode.Prompt+': '+DNode.FNode.Format);
            end;
            Inc(J);
         end;
      end;
   end; 
end;
function  TProductDrawNode.CalcHintRect(Canvas:TCanvas;MaxWidth:Integer):TRect;
var
   PW,J,I,W,TW:Integer;
   DNode:TDomainDrawNode;
begin       
   with Canvas do
   begin
      PW:=0;
      for I:=0 to Count-1 do
      begin
         if Child[I] is TDomainDrawNode then
         begin
            W:=TextWidth((Child[I] as TDomainDrawNode).FNode.Prompt+':');
            if W > PW then PW:=W;
         end;
      end;
      Font.Style:=[fsBold];
      W:=TextWidth(Caption);    
      Font.Style:=[];
      J:=0;
      for I:=0 to Count-1 do
      begin
         if Child[I] is TDomainDrawNode then
         begin
            DNode:=Child[I] as TDomainDrawNode;
            if DNode.FNode.FmtData <> '' then
               TW:=PW+TextWidth(' '+DNode.FNode.Format+'('+DNode.FNode.FmtData+')')
            else
            begin
               if J < FNode.DomainParams.Count then
                  TW:=PW+TextWidth(' '+DNode.FNode.Format+' <-'+FNode.DomainParams[J])
               else
                  TW:=PW+TextWidth(' '+DNode.FNode.Format);
            end;
            if TW > W then W:=TW;
            Inc(J);
         end;
      end;
      Result:=Bounds(0,0,W+10,TextHeight('Wg')*(J+1)+14);
      HintRect:=Result;
   end;
end;    
procedure TProductDrawNode.SetCompInspectorData;
begin
   if FNode <> nil then
   begin
      CompInspector.Add      ('Name'        ,itString,FNode.NodeName    );
      CompInspector.Add      ('Title'       ,itString,FNode.Title       );
      CompInspector.Add      ('Prompt'      ,itString,FNode.Prompt      );
      CompInspector.Add      ('Hint'        ,itString,FNode.Hint        );
      CompInspector.AddBitMap('Image'       ,FNode.BitMap,FNode.Image   );
      CompInspector.Add      ('GUID'        ,itString,FNode.GUID        );
      CompInspector.Add      ('RegDesc'     ,itString,FNode.RegDesc     );
      CompInspector.Add      ('ProgID'      ,itString,FNode.ProgID      );
      CompInspector.Add      ('Version'     ,itString,FNode.Version     );
      CompInspector.Add      ('ProjectFiles',itString,FNode.ProjectFiles);
      CompInspector.Add      ('SubGroup'    ,itString,FNode.SubGroup    );
      CompInspector.Add      ('BarCode'     ,itString,FNode.BarCode     );
      CompInspector.Add      ('Description' ,itString,FNode.Description );
      CompInspector.Add      ('StartDate'   ,itString,FNode.StartDate   );
      CompInspector.Add      ('EndDate'     ,itString,FNode.EndDate     );
      CompInspector.Add      ('HighDays'    ,itString,FNode.HighDays    );
      CompInspector.Add      ('MCRCode'     ,itString,FNode.MCRCode     );
      CompInspector.Add      ('OCRCode'     ,itString,FNode.OCRCode     );
      CompInspector.Add      ('OtherCode'   ,itString,FNode.OtherCode   );
      CompInspector.Add      ('Regulations' ,itString,FNode.Regulations );
      CompInspector.Add      ('UseDays'     ,itString,FNode.UseDays     );
      CompInspector.Add      ('UnitQuantity',itString,FNode.UnitQuantity);
      CompInspector.Add      ('MaxQuantity' ,itString,FNode.MaxQuantity );
      CompInspector.Add      ('MinQuantity' ,itString,FNode.MinQuantity );
      CompInspector.Add      ('PLU'         ,itString,FNode.PLU         );
      CompInspector.Add      ('UnitPrice'   ,itString,FNode.UnitPrice   );
      CompInspector.Add      ('LogAs'       ,itString,FNode.LogAs       );
      CompInspector.Add      ('Endorse'     ,itString,FNode.Endorse     );
      CompInspector.Add      ('Customer'    ,itString,FNode.Customer    );
      if FNode.DontBuild then
         CompInspector.Add      ('Build',itComboBox,'False,True,False')
      else
         CompInspector.Add      ('Build',itComboBox,'True,True,False');
   end;
   inherited SetCompInspectorData;
end;
{TSwapToDrawNode}
constructor TSwapToDrawNode.Create(Owner:TComponent);
begin
   inherited Create(Owner);
   FNodeColor:=SwapToColor;
end;
  
{TFunctionDrawNode}
function GetBitmap(Value:OleVariant;BType:Boolean):TBitMap;
var
   SStream:TStringStream;
   Compress:TCompress;
   Compressor:TCompressor;
begin
   result:=nil;
   if BType then
   begin
      try
         if Value = '' then Exit;
         Compress:=TCompress.Create;
         Value:=StringToBinary(Value);
         Value:=Compress.CompressString(Value);
         Compress.Free;
         SStream:=TStringStream.Create(Value);
         SStream.Position:=0;
         Result:=TBitMap.Create;
         Result.LoadFromStream(SStream);
         SStream.Free;
      except
      end;
   end
   else
   begin
      if VarIsArray(Value) then
      begin
         Compressor:=TCompressor.Create;
         Result:=Compressor.CreateBitmapFromArray(Value);
         Compressor.Free;
      end;
   end;
end;  
function GetPictureFromServer(Value:String):TBitMap;
var
   BMPString:String;
   Index:Integer;
begin
   if PictureList= nil then
      PictureList:=TStringList.Create;
   Result:=nil;
   Index:=PictureList.IndexOf(Value);
   if Index = -1 then
   begin
      try
      if PictureServer = nil then
         PictureServer:=CreatePictureServer;
      if PictureServer <> nil then
      begin
         BMPString:=PictureServer.Bitmap(Value);
         if BMPString <> '' then 
            Result:=GetBitmap(BMPString,True);
      end;
      except
      end;
      PictureList.AddObject(Value,Result);
   end
   else
      Result:=TBitMap(PictureList.Objects[Index]);
end;
constructor TFunctionDrawNode.Create(Owner:TComponent);
begin
   inherited Create(Owner);
   FNodeColor:=FunctionColor;
end;
procedure TFunctionDrawNode.SetNode(Node:TNode);
begin
   if (ShowBitmaps) and (FGraphic = nil) and (Caption <> '') then
      FGraphic:=GetPictureFromServer(Caption);
end;
{TDomainDrawNode}
constructor TDomainDrawNode.Create(Owner:TComponent);
begin
   inherited Create(Owner);
   FNodeColor:=DomainColor;
end;
procedure TDomainDrawNode.SetNode(Node:TNode);
begin
   FNode:=TDomainNode(Node);
end;
procedure TDomainDrawNode.SetCompInspectorData;
begin
   if FNode <> nil then
   begin
      CompInspector.Add('Name'        ,itString,FNode.NodeName     );
      CompInspector.Add('Title'       ,itString,FNode.Title        );
      CompInspector.Add('Prompt'      ,itString,FNode.Prompt       );
      CompInspector.Add('Hint'        ,itString,FNode.Hint         );
      CompInspector.Add('Error'       ,itString,FNode.Error        );
      CompInspector.Add('DefaultValue',itString,FNode.DefaultValue );
      CompInspector.Add('Format'      ,itString,FNode.Format       );
      CompInspector.Add('FormatData'  ,itString,FNode.FmtData      );
      CompInspector.Add('InputFrom'   ,itString,FNode.InputFrom    );
      CompInspector.Add('TotalIn'     ,itString,FNode.TotalIn      );
   end;
   inherited SetCompInspectorData;
end;
   
end.
