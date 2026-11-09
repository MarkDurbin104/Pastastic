unit ComponentPalletteFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,ParseNode,
  StdCtrls, ComCtrls,ExtCtrls,DrawNodeU,Utils,Printers,DrawButtonU, Grids,
  Menus;

type

  TForm1 = class(TForm)
    Splitter1: TSplitter;
    ScrollBox1: TScrollBox;
    Panel1: TPanel;
    StringGrid1: TStringGrid;
    PageControl1: TPageControl;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    OD: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ScrollBox1DblClick(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; Col, Row: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StringGrid1SelectCell(Sender: TObject; Col, Row: Integer;
      var CanSelect: Boolean);
    procedure Panel1Resize(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
  private
    FileName:String;
    Parser:TParser;
    GDrawNode:TGroupDrawNode;
    PDrawNode:TProductDrawNode;
    procedure EmptyScrollBox;
  public
     procedure LoadFile(FileName:String);
     procedure ProdDrawItem    (Control:TWinControl;Index:Integer;Rect:TRect;State:TOwnerDrawState);
     procedure GroupDrawItem   (Control:TWinControl;Index:Integer;Rect:TRect;State:TOwnerDrawState);
     procedure DomainDrawItem  (Control:TWinControl;Index:Integer;Rect:TRect;State:TOwnerDrawState);
     procedure GroupListBoxDblClick(Sender: TObject);
     procedure ProductListBoxDblClick(Sender: TObject);
  end;

var
  Form1: TForm1;
  ProdPC:TPageControl;
  ProdSG:TStringGrid;
implementation

{$R *.DFM}


procedure TForm1.ProdDrawItem(Control:TWinControl;Index:Integer;Rect:TRect;State:TOwnerDrawState);
var
   LB:TListBox;
   Node:TProdNode;
   R:TRect;
   H:Integer;
begin
   LB:=(Control as TListBox);
   Node:=TProdNode(LB.Items.Objects[Index]);
   if Node = nil then Exit;
   with LB.Canvas do
   begin
      R:=Rect;
      InflateRect(R,-2,-2);
      PaintButton(R,LB.Canvas,Brush.Color);
      Brush.Style:=bsClear;
      BrushCopy(Bounds(R.Left+2,R.Top+2,37,25),Node.Image,Bounds(0,0,Node.Image.Width,Node.Image.Height),Node.Image.Canvas.Pixels[0,0]);
      R.Left:=R.Left+41;
      H:=CentreTextH(LB.Canvas,R,Node.Title);
      OffsetRect(R,0,H);
      CentreTextH(LB.Canvas,R,Node.NodeName);
      Brush.Style:=bsSolid;
   end;
end;

procedure TForm1.GroupDrawItem(Control:TWinControl;Index:Integer;Rect:TRect;State:TOwnerDrawState);
var
   LB:TListBox;
   Node:TGroupNode;
   R:TRect;
   H:Integer;
begin
   LB:=(Control as TListBox);
   Node:=TGroupNode(LB.Items.Objects[Index]);
   if Node = nil then Exit;
   with LB.Canvas do
   begin
      R:=Rect;
      InflateRect(R,-2,-2);
      PaintButton(R,LB.Canvas,Brush.Color);
      Brush.Style:=bsClear;
      BrushCopy(Bounds(R.Left+2,R.Top+2,37,25),Node.Image,Bounds(0,0,Node.Image.Width,Node.Image.Height),Node.Image.Canvas.Pixels[0,0]);
      R.Left:=R.Left+41;
      H:=CentreTextH(LB.Canvas,R,Node.Title);
      OffsetRect(R,0,H);
      CentreTextH(LB.Canvas,R,Node.NodeName);
      Brush.Style:=bsSolid;
   end;
end;

procedure TForm1.DomainDrawItem(Control:TWinControl;Index:Integer;Rect:TRect;State:TOwnerDrawState);
var
   LB:TListBox;
   Node:TDomainNode;
   R:TRect;
   H:Integer;
begin
   LB:=(Control as TListBox);
   Node:=TDomainNode(LB.Items.Objects[Index]);
   if Node = nil then Exit;
   with LB.Canvas do
   begin
      FillRect(Rect);
      with Rect do R:=Classes.Rect(Left,Top,Right,Bottom);
      OffsetRect(R,0,TextHeight('Wg') div 2);
      R.Bottom:=R.Top+TextHeight(Node.NodeName);
      H:=CentreTextH(LB.Canvas,R,Node.NodeName);
      OffsetRect(R,0,H);
      CentreTextH(LB.Canvas,R,Node.Title);
   end;
end;

procedure TForm1.LoadFile(FileName:String);
var
   I,J:Integer;
   TabSheet:TTabSheet;
   ListBox:TListBox;
   Node:TNode;
   SL:TStringList;
   SSL:TStringList;
   PNode:TProdNode;
   PageIndex:Integer;
   B:Boolean;
   Comp:TComponent;
begin
   if Parser <> nil then Parser.Free;
   while PageControl1.ComponentCount > 0 do
   begin
      Comp:=PageControl1.Components[0];
      PageControl1.RemoveComponent(Comp);
      Comp.Free;
   end;
   ChDir(ExtractFilePath(FileName));
   Parser:=TParser.Create(FileName);
   SL:=TStringList.Create;
   for I:=0 to Parser.Nodes.Count-1 do
   begin
      if Trim(Parser.Nodes.Name[I]) <> '' then
         SL.Add(Trim(Parser.Nodes.Name[I]));
   end;
   SL.Sort;
   for I:=0 to SL.Count-1 do
   begin
      TabSheet:=TTabSheet.Create(PageControl1);
      TabSheet.TabVisible:=False;
      TabSheet.PageControl:=PageControl1;
      TabSheet.Name:='TS'+SL[I];
      TabSheet.Caption:=SL[I];
      Node:=Parser.Nodes.SelectNode(SL[I]);
      if Node <> Parser.Nodes then
      begin
         if Node is TProductsNode then
         begin
            SSL:=TStringList.Create;
            ProdPC:=TPageControl.Create(TabSheet);
            TabSheet.InsertControl(ProdPC);
            ProdSG:=TStringGrid.Create(TabSheet);
            TabSheet.InsertControl(ProdSG);
            ProdSG.Align:=alBottom;
            ProdSG.BorderStyle := bsNone;
            ProdSG.Color := clBtnFace;
            ProdSG.DefaultColWidth := 120;
            ProdSG.DefaultRowHeight := 16;
            ProdSG.DefaultDrawing := False;
            ProdSG.FixedCols := 0;
            ProdSG.FixedRows := 0;
            ProdSG.Options := [goVertLine, goHorzLine, goRangeSelect];
            ProdSG.ScrollBars := ssNone;
            ProdSG.OnDrawCell := StringGrid1DrawCell;
            ProdSG.OnSelectCell := StringGrid1SelectCell;

            ProdPC.Align:=alClient;
            ProdSG.RowCount:=50;
            ProdSG.ColCount:=2;

//            PageControl.MultiLine:=True;
            for J:=0 to Node.Count-1 do
            begin
               PNode:=Node[J] as TProdNode;
               if PNode.DontBuild then PNode.SubGroup:='Don''t Build';
               PageIndex:=SSL.IndexOf(PNode.SubGroup);
               if PageIndex = -1 then
               begin
                  TabSheet:=TTabSheet.Create(ProdPC);
                  TabSheet.PageControl:=ProdPC;
                  TabSheet.TabVisible:=False;
                  TabSheet.Name:='PTS'+IntToStr(J);
                  TabSheet.Caption:=PNode.SubGroup;
                  ListBox:=TListBox.Create(TabSheet);
                  TabSheet.InsertControl(ListBox);
                  ListBox.Sorted:=True;
                  ListBox.DragMode:=dmAutomatic;
                  ListBox.Align:=alClient;
                  ListBox.MultiSelect:=True;
                  SSL.AddObject(PNode.SubGroup,TabSheet);
                  ListBox.ItemHeight:=ListBox.Canvas.TextHeight('Wg')*3;
                  ListBox.OnDrawItem:=ProdDrawItem    ;
                  ListBox.Style     :=lbOwnerDrawFixed;
                  ListBox.OnDblClick:=ProductListBoxDblClick;
               end
               else
               begin
                  TabSheet:=ProdPC.Pages[PageIndex];
                  ListBox:=TabSheet.Components[0] as TListBox;
               end;
               ListBox.Items.AddObject(TProdNode(Node[J]).Title,Node[J]);
            end;
            ProdSG.RowCount:=(ProdPC.PageCount div 2);
            if ((ProdSG.RowCount*2) <> ProdPC.PageCount) then
               ProdSG.RowCount:=ProdSG.RowCount+1;
            ProdSG.Height:=ProdSG.DefaultRowHeight*ProdSG.RowCount+8;
            ProdSG.DefaultColWidth :=(PageControl1.Width-8) div ProdSG.ColCount;
            ProdSG.DefaultRowHeight:=(ProdSG.Height-6) div ProdSG.RowCount;
            SSL.Sort;
            for J:=0 to SSL.Count-1 do
            begin
               ProdSG.Cells[J mod 2,J div 2]:=SSL[J];
            end;
            ProdSG.Invalidate;
            SSL.Free;
         end
         else
         begin
            ListBox:=TListBox.Create(TabSheet);
            TabSheet.InsertControl(ListBox);
            ListBox.Sorted:=True;
            ListBox.DragMode:=dmAutomatic;
            ListBox.Align:=alClient;
            ListBox.MultiSelect:=True;
            if Node is TGroupsNode then
            begin
               ListBox.ItemHeight:=ListBox.Canvas.TextHeight('Wg')*3;
               ListBox.OnDrawItem:=GroupDrawItem   ;
               ListBox.Style     :=lbOwnerDrawFixed;
               ListBox.OnDblClick:=GroupListBoxDblClick;
               for J:=0 to Node.Count-1 do
                  ListBox.Items.AddObject(TGroupNode(Node[J]).Title,Node[J]);
            end
            else if Node is TDomainsNode then
            begin
               ListBox.ItemHeight:=ListBox.Canvas.TextHeight('Wg')*3;
               ListBox.OnDrawItem:=DomainDrawItem  ;
               ListBox.Style     :=lbOwnerDrawFixed;
               for J:=0 to Node.Count-1 do
                  ListBox.Items.AddObject(Node[J].NodeName,Node[J]);
            end;
         end;
      end;
   end;
   SL.Free;
   StringGrid1SelectCell(StringGrid1,0,0,B);
   StringGrid1SelectCell(ProdSG,0,0,B);
end;
procedure TForm1.FormCreate(Sender: TObject);
begin
   StringGrid1.RowCount:=4;
   StringGrid1.ColCount:=3;
   StringGrid1.DefaultColWidth :=(StringGrid1.Width -4) div StringGrid1.ColCount;
   StringGrid1.DefaultRowHeight:=(StringGrid1.Height-4) div StringGrid1.RowCount;
   StringGrid1.Width :=(StringGrid1.DefaultColWidth  * StringGrid1.ColCount)+4;
   StringGrid1.Height:=(StringGrid1.DefaultRowHeight * StringGrid1.RowCount)+4;

   StringGrid1.Cells[0,0]:='Groups';
   StringGrid1.Cells[1,0]:='Products';
   StringGrid1.Cells[2,0]:='Users';
   StringGrid1.Cells[0,1]:='PickLists';
   StringGrid1.Cells[1,1]:='LookUps';
   StringGrid1.Cells[2,1]:='WorkStations';
   StringGrid1.Cells[0,2]:='Domains';
   StringGrid1.Cells[1,2]:='Snippets';
   StringGrid1.Cells[2,2]:='Constants';
   StringGrid1.Cells[0,3]:='LogFormats';
   StringGrid1.Cells[1,3]:='BuildOptions';
   StringGrid1.Cells[2,3]:='ProjectInfo';

   if ParamCount <> 0 then
   begin
      FileName:=ParamStr(1);
      LoadFile(FileName);
   end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
   I:Integer;
begin
   Parser.Free;
   PictureServer:=nil;
   if PictureList <> nil then
   begin
      for I:=0 to PictureList.Count-1 do
      begin
         if PictureList.Objects[I] <> nil then
            TBitmap(PictureList.Objects[I]).Free;
      end;
      PictureList.Free;
   end;
   PictureServer:=nil;
end;
procedure TForm1.EmptyScrollBox;
var
   Control:TControl;
begin
   while ScrollBox1.ControlCount > 0 do
   begin
      Control:=ScrollBox1.Controls[0];
      ScrollBox1.RemoveControl(Control);
      Control.Free;
   end;
end;
procedure TForm1.GroupListBoxDblClick(Sender: TObject);
var
   LB:TListBox;
   Node:TGroupNode;
begin
   LB:=(Sender as TListBox);
   Node:=TGroupNode(LB.Items.Objects[LB.ItemIndex]);
   if Node = nil then Exit;
   EmptyScrollBox;
   GDrawNode:=TGroupDrawNode.Create(nil);
   GDrawNode.Visible:=True;
   ScrollBox1.InsertControl(GDrawNode);
   GDrawNode.Left:=10;
   GDrawNode.Top:=10;
   GDrawNode.Caption:=Node.Title;
   GDrawNode.SetNode(Node);
   GDrawNode.AddNodes(Parser);
end;
procedure TForm1.ProductListBoxDblClick(Sender: TObject);
var
   LB:TListBox;
   Node:TProdNode;
begin
   LB:=(Sender as TListBox);
   Node:=TProdNode(LB.Items.Objects[LB.ItemIndex]);
   if Node = nil then Exit;
   EmptyScrollBox;
   PDrawNode:=TProductDrawNode.Create(nil);
   PDrawNode.Visible:=True;
   ScrollBox1.InsertControl(PDrawNode);
   PDrawNode.Left:=10;
   PDrawNode.Top:=10;
   PDrawNode.Caption:=Node.Title;
   PDrawNode.SetNode(Node);
   PDrawNode.AddNodes(Parser);
end;

procedure TForm1.ScrollBox1DblClick(Sender: TObject);
var
   I:Integer;
   Comp:TWinControl;
   Size:TSize;
   OSize:TSize;
   Extent:TRect;
   FirstComp:Boolean;
   X,Y:Integer;
   MaxX,MaxY:Integer;
   XOfs,YOfs:Integer;
begin
   FirstComp:=True;
   for I:=0 to ScrollBox1.ControlCount-1 do
   begin
      if ScrollBox1.Controls[I] is TWinControl then
      begin
         Comp:=TWinControl(ScrollBox1.Controls[I]);
         if Comp.Visible then
         begin
            if FirstComp then
            begin
               FirstComp:=False;
               Extent.Left  :=Comp.Left;
               Extent.Top   :=Comp.Top ;
               Extent.Right :=Comp.Left+Comp.Width ;
               Extent.Bottom:=Comp.Top +Comp.Height;
            end;
            if Comp.Left < Extent.Left               then Extent.Left  :=Comp.Left;
            if Comp.Top  < Extent.Top                then Extent.Top   :=Comp.Top ;
            if Comp.Left+Comp.Width  > Extent.Right  then Extent.Right :=Comp.Left+Comp.Width ;
            if Comp.Top +Comp.Height > Extent.Bottom then Extent.Bottom:=Comp.Top +Comp.Height;
         end;
      end;
   end;
   Printer.BeginDoc;
   Printer.Title:='Component Diagram';
   SetMapMode(Printer.Handle,MM_HIMETRIC);
   GetWindowExtEx(Printer.Canvas.Handle,Size);
   SetMapMode(Printer.Handle,MM_ANISOTROPIC);
   Size.cx:=Size.cx div 15;
   Size.cy:=Size.cy div 15;
   SetWindowExtEx(Printer.Canvas.Handle,Size.cx,0-Size.cy,@OSize);
   Size.cx:=Size.cx-40;
   Size.cy:=Size.cy-40;
   MaxX:=((Extent.Right-Extent.Left) div Size.cx);
   MaxY:=((Extent.Bottom-Extent.Top) div Size.cy);
   for X:=0 to MaxX do
   begin
      XOfs:=0-(Extent.Left+X*Size.cx);
      for Y:=0 to MaxY do
      begin
         YOfs:=0-(Extent.Top+Y*Size.cy);
         for I:=0 to ScrollBox1.ControlCount-1 do
         begin
            if ScrollBox1.Controls[I] is TWinControl then
            begin
               Comp:=TWinControl(ScrollBox1.Controls[I]);
               if Comp.Visible then
                  Comp.PaintTo(Printer.Canvas.Handle,XOfs+Comp.Left,YOfs+Comp.Top);
            end;
         end;
         if (X <> MaxX) or (Y <> MaxY) then
            Printer.NewPage;
      end;
   end;
   SetWindowExtEx(Printer.Canvas.Handle,OSize.cx,OSize.cy,@Size);
   Printer.EndDoc;
end;

procedure TForm1.StringGrid1DrawCell(Sender: TObject; Col, Row: Integer;
  Rect: TRect; State: TGridDrawState);
var
   H:Integer;
   R:TRect;
begin
   if (Sender is TStringGrid) then
   begin
      (Sender as TStringGrid).Canvas.Font.Color:=clBtnText;
      if (gdSelected in State) and (gdFocused in State) then
      begin
         DrawButtonBG((Sender as TStringGrid).Canvas,Rect,clActiveCaption,5,50,False,0);
         (Sender as TStringGrid).Canvas.Font.Color:=clCaptionText;
      end
      else if (gdSelected in State) then
         DrawButtonBG((Sender as TStringGrid).Canvas,Rect,Color,5,50,False,0)
      else
         DrawButtonBG((Sender as TStringGrid).Canvas,Rect,Color,3,50,False,0);
      R:=Rect;
      H:=DrawText((Sender as TStringGrid).Canvas.Handle,PChar((Sender as TStringGrid).Cells[Col,Row]),-1,R,DT_CALCRECT or DT_WORDBREAK or DT_CENTER);
      OffsetRect(R,((Rect.Right-Rect.Left)-(R.Right-R.Left)) div 2,((Rect.Bottom-Rect.Top)-H) div 2);
      DrawText((Sender as TStringGrid).Canvas.Handle,PChar((Sender as TStringGrid).Cells[Col,Row]),-1,R,DT_WORDBREAK or DT_CENTER);
   end;
end;

procedure TForm1.StringGrid1SelectCell(Sender: TObject; Col, Row: Integer;
  var CanSelect: Boolean);
var
   I:Integer;
begin
   if Sender = StringGrid1 then
   begin
      for I:=0 to PageControl1.PageCount-1 do
      begin
         if PageControl1.Pages[I].Name = 'TS'+StringGrid1.Cells[Col,Row] then
         begin
            PageControl1.ActivePage:=PageControl1.Pages[I];
            break;
         end;
      end;
   end
   else if Sender = ProdSG then
   begin
      for I:=0 to ProdPC.PageCount-1 do
      begin
         if ProdPC.Pages[I].Caption = ProdSG.Cells[Col,Row] then
         begin
            ProdPC.ActivePage:=ProdPC.Pages[I];
            break;
         end;
      end;
   end;
end;

procedure TForm1.Panel1Resize(Sender: TObject);
begin
   StringGrid1.RowCount:=4;
   StringGrid1.ColCount:=3;
   StringGrid1.DefaultColWidth :=(StringGrid1.Width -4) div StringGrid1.ColCount;
   StringGrid1.DefaultRowHeight:=(StringGrid1.Height-4) div StringGrid1.RowCount;
   if ProdSG <> nil then
   begin
      ProdSG.DefaultColWidth :=(PageControl1.Width-8) div ProdSG.ColCount;
      ProdSG.DefaultRowHeight:=(ProdSG.Height-4) div ProdSG.RowCount;
      PageControl1.Invalidate;
   end;
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
   Close;
end;

procedure TForm1.Open1Click(Sender: TObject);
begin
   if OD.Execute then
   begin
      LoadFile(OD.FileName);
   end;
end;

end.
