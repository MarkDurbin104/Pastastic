unit SnippetDesFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls,PackStrListU,
  StdCtrls,ParseNodeU,ErrorFormFU,DesignNodeU;

type
  TSnippetDes = class(TForm)
    ScrollBox1: TScrollBox;
  public
    PEIcon:TBitmap;
    USnippet:TBitmap;
    WSnippet:TBitmap;
    Snippet:TBitmap;
    CurrentSnippet:String;
    procedure PutOn(Panel:TPanel);
    procedure SetSnippet;
    procedure SetSnippetTo(SnippetName:String);
    function DrawSnippetDiag(DiagBackground:TDiagBackground;SnippetNode:TSnippetNode;ScrollBox:TScrollBox;ShowInvoke:Boolean;var TOfs:Integer):TDesignNode;
    procedure InsertSnippetDiag(SnippetNode:TSnippetNode;ScrollBox:TScrollBox);
  end;

var
  SnippetDes: TSnippetDes;

const
   NodeWidth   = 160;
   NodeHeight  = 100;
   NodeSpacing = 10;

implementation

uses PropertyEditFU, ProjectFormFU;


{$R *.DFM}

procedure TSnippetDes.PutOn(Panel:TPanel);
begin
   Parent:=Panel;
   if Panel = nil then
      BorderStyle:=bsSizeable
   else
   begin
      BorderStyle:=bsNone;
      Align:=alClient;
   end;
   Show;
end;
function TSnippetDes.DrawSnippetDiag(DiagBackground:TDiagBackground;SnippetNode:TSnippetNode;ScrollBox:TScrollBox;ShowInvoke:Boolean;var TOfs:Integer):TDesignNode;
var
   Shape1:TDesignNode;
   Shape:TDesignNode;
   I,Ofs:Integer;
   Node:TCorvusNode;
begin
   if SnippetNode.BasedOnNode <> nil then
   begin // TProductNode(ProjectsForm.Comps.NodeNamed(ProjectsForm.CompTypeName+'.'+ProductNode.BasedOn))
      DrawSnippetDiag(DiagBackground,
                      TSnippetNode(SnippetNode.BasedOnNode),
                      ScrollBox,False,TOfs);
      Inc(TOfs,NodeHeight div 5);
   end;

   Shape1:=TSnippetDesignNode.Create(nil);
   DiagBackground.InsertControl(Shape1);
   Shape1.Top:=TOfs;
   Shape1.Width:=NodeWidth;
   Shape1.Height:=NodeHeight div 2;
   Shape1.Title:=SnippetNode.Name;
   Shape1.Caption:=SnippetNode.InsertBetween;
   Shape1.Bitmap:=Snippet;
   Shape1.Icon:=PEIcon;
   Shape1.Left:=NodeWidth+NodeSpacing*2;
   DiagBackground.NotifyPos(Shape1);
   if ShowInvoke and (SnippetNode.InvokedBy.Count <> 0) then
   begin
      Ofs:=NodeSpacing;
      DiagBackground.NotifyPos(Shape1);
      for I:=0 to SnippetNode.InvokedBy.Count-1 do
      begin
         Node:=SnippetNode.InvokedBy[I];
         if Node is TProductNode then
         begin
            Shape:=TProductDesignNode.Create(nil);
            Shape.Height:=NodeHeight;
            Shape.Bitmap:=(Node as TProductNode).Image;
            Shape.Title:=(Node as TProductNode).Name;
            Shape.Caption:=(Node as TProductNode).Title;
            TProductDesignNode(Shape).Price:=(Node as TProductNode).UnitPrice;
            if ProjectsForm.Comps.NodeNamed('Constant.'+(Node as TProductNode).PLU) <> nil then
               TProductDesignNode(Shape).PLU:=TConstantNode(ProjectsForm.Comps.NodeNamed('Constant.'+(Node as TProductNode).PLU))[0]
            else
               TProductDesignNode(Shape).PLU:=(Node as TProductNode).PLU;
            Shape.Icon:=PEIcon;
         end
         else
         begin
            if SnippetNode[I] <> '' then
            begin
               Shape:=TFunctionDesignNode.Create(nil);
               Shape.Height:=NodeHeight;
               Shape.Caption:=SnippetNode[I];
               Shape.Bitmap:=GetPictureFromServer(SnippetNode[I]);
               Shape.Icon:=PEIcon;
            end
            else
               Shape:=nil;
         end;
         if Shape <> nil then
         begin
            Shape.PenColor:=clGreen;
            Shape.Width:=NodeWidth;
            Shape.Top:=Ofs;
            Shape.Left:=(NodeSpacing div 2);
            DiagBackground.InsertControl(Shape);
            Shape.JoinTo(Shape1);
            Inc(Ofs,Shape.Height+NodeSpacing);
         end;
      end;
   end;
   Ofs:=NodeSpacing;
   for I:=0 to SnippetNode.Count-1 do
   begin
      Shape:=TFunctionDesignNode.Create(nil);
      Shape.Caption:=SnippetNode[I];
      Shape.Height:=45;
      Shape.Width:=NodeWidth;
      Shape.Left:=Shape1.Left+NodeWidth+NodeSpacing;
      Shape.Icon:=PEIcon;
      DiagBackground.InsertControl(Shape);
      Shape1.JoinTo(Shape);
      Shape.Top:=Ofs;
      Inc(Ofs,Shape.Height+NodeSpacing div 4);
      DiagBackground.NotifyPos(Shape);
   end;

   Result:=Shape1;
end;
procedure TSnippetDes.InsertSnippetDiag(SnippetNode:TSnippetNode;ScrollBox:TScrollBox);
var
   TOfs:Integer;
   I:Integer;
   DiagBackground:TDiagBackground;
begin
   I:=0;
   while I < ScrollBox.ControlCount do
   begin
      if (ScrollBox.Controls[I] is TDiagBackground) then
      begin
         DiagBackground:=TDiagBackground(ScrollBox.Controls[I]);
         ScrollBox.RemoveControl(DiagBackground);
         DiagBackground.Free;
      end
      else
         Inc(I);
   end;
   if SnippetNode <> nil then
   begin
      DiagBackground:=TDiagBackground.Create(nil);
      DiagBackground.OnNodeClicked:=ProjectsForm.NodeClicked;
      ScrollBox.InsertControl(DiagBackground);
      DiagBackground.LinkType:=ltJRDown;
      DiagBackground.Left:=0;
      DiagBackground.Top:=0;
      DiagBackground.Color:=clWindow;
      TOfs:=NodeSpacing;
      DrawSnippetDiag(DiagBackground,SnippetNode,ScrollBox,True,TOfs);
   end;
end;
procedure TSnippetDes.SetSnippetTo(SnippetName:String);
var
    SnippetNode:TSnippetNode;
begin
   if SnippetName <> '' then
   begin
      SnippetNode:=TSnippetNode(ProjectsForm.Comps.NodeNamed(CurrentSnippet));
      InsertSnippetDiag(SnippetNode,ScrollBox1);
      if SnippetNode <> nil then
      begin
         if not PropEdit.Visible then PropEdit.Show;
         PropEdit.PropList.CurObj:=SnippetNode;
         PropEdit.Memo1.Text:=SnippetNode.ListDetails;
         PropEdit.Memo1.Lines.Insert(0,'Snippets {');
         PropEdit.Memo1.Lines.Add('}');
      end
      else
         CurrentSnippet:='';
   end
   else
   begin
      InsertSnippetDiag(nil,ScrollBox1);
   end;
end;
procedure TSnippetDes.SetSnippet;
begin
   CurrentSnippet:='';
   if (ProjectsForm.Comps <> nil)
   and (ProjectsForm.CompTypeName = 'Snippet')
   and (ProjectsForm.CompList.itemIndex >= 0)
   and (ProjectsForm.CompList.SelCount > 0) then
   begin
      CurrentSnippet:=ProjectsForm.CompTypeName+'.'+
                   ProjectsForm.CompList.Items[ProjectsForm.CompList.itemIndex];
   end;
   SetSnippetTo(CurrentSnippet);
end;
end.
