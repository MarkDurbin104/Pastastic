unit DomainDesFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls,PackStrListU,
  StdCtrls,ParseNodeU,ErrorFormFU,DesignNodeU;

type
  TDomainDes = class(TForm)
    ScrollBox1: TScrollBox;
  public
    PEIcon:TBitmap;
    UDomain:TBitmap;
    WDomain:TBitmap;
    Snippet:TBitmap;
    CurrentDomain:String;
    procedure PutOn(Panel:TPanel);
    procedure SetDomain;
    procedure SetDomainTo(DomainName:String);
    function DrawDomainDiag(DiagBackground:TDiagBackground;DomainNode:TDomainNode;ScrollBox:TScrollBox;ShowInvoke:Boolean;var TOfs:Integer):TDesignNode;
    procedure InsertDomainDiag(DomainNode:TDomainNode;ScrollBox:TScrollBox);
  end;

var
  DomainDes: TDomainDes;

const
   NodeWidth   = 160;
   NodeHeight  = 100;
   NodeSpacing = 10;

implementation

uses PropertyEditFU, ProjectFormFU;


{$R *.DFM}

procedure TDomainDes.PutOn(Panel:TPanel);
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
function TDomainDes.DrawDomainDiag(DiagBackground:TDiagBackground;DomainNode:TDomainNode;ScrollBox:TScrollBox;ShowInvoke:Boolean;var TOfs:Integer):TDesignNode;
var
   Shape1:TDesignNode;
   Shape:TDesignNode;
   I,Ofs:Integer;
   Node:TCorvusNode;
begin
   if DomainNode.BasedOnNode <> nil then
   begin
      DrawDomainDiag(DiagBackground,TDomainNode(DomainNode.BasedOnNode),ScrollBox,False,TOfs);
      Inc(TOfs,NodeHeight div 5);
   end;

   Shape1:=TDomainDesignNode.Create(nil);
   DiagBackground.InsertControl(Shape1);
   Shape1.Top:=TOfs;
   Shape1.Width:=NodeWidth;
   Shape1.Height:=NodeHeight div 2;
   Shape1.Title:=DomainNode.Name;
   Shape1.Caption:=DomainNode.Title;
   Shape1.Icon:=PEIcon;
   Shape1.Left:=NodeWidth+NodeSpacing*2;
   DiagBackground.NotifyPos(Shape1);
   if ShowInvoke and (DomainNode.InvokedBy.Count <> 0) then
   begin
      Ofs:=NodeSpacing;
      DiagBackground.NotifyPos(Shape1);
      for I:=0 to DomainNode.InvokedBy.Count-1 do
      begin
         Node:=DomainNode.InvokedBy[I];
         if Node is TDomainNode then
         begin
            Shape:=TDomainDesignNode.Create(nil);
            Shape.Height:=NodeHeight div 2;
            Shape.Title:=(Node as TDomainNode).Name;
            Shape.Caption:=(Node as TDomainNode).Title;
            Shape.Icon:=PEIcon;
         end
         else if Node is TProductNode then
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
            if DomainNode[I] <> '' then
            begin
               Shape:=TFunctionDesignNode.Create(nil);
               Shape.Height:=NodeHeight;
               Shape.Caption:=DomainNode[I];
               Shape.Bitmap:=GetPictureFromServer(DomainNode[I]);
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
   for I:=0 to DomainNode.Count-1 do
   begin
      if (DomainNode[I] = 'Format') and (TCorvusNode(DomainNode.Objects[I])[0] = 'PickList') then
      begin
         Shape:=TDomainDesignNode.Create(nil);
         Shape.Caption:=TCorvusNode(TCorvusNode(DomainNode.Objects[I]).Objects[0])[0];
         Shape.Title:='PickList';
      end
      else if DomainNode[I] = 'InputFrom' then
      begin
         Shape:=TFunctionDesignNode.Create(nil);
         Shape.Caption:=TCorvusNode(DomainNode.Objects[I])[0];
         Shape.Title:='InputFrom';
      end
      else if DomainNode[I] = 'Locale' then
      begin
         Shape:=TFunctionDesignNode.Create(nil);
         Shape.Caption:=TCorvusNode(DomainNode.Objects[I])[0];
         Shape.Title:='Locale';
      end
      else
         Shape:=nil;
      if Shape <> nil then
      begin
         Shape.Caption:=DomainNode[I];
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
   end;

   Result:=Shape1;
end;
procedure TDomainDes.InsertDomainDiag(DomainNode:TDomainNode;ScrollBox:TScrollBox);
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
   if DomainNode <> nil then
   begin
      DiagBackground:=TDiagBackground.Create(nil);
      DiagBackground.OnNodeClicked:=ProjectsForm.NodeClicked;
      ScrollBox.InsertControl(DiagBackground);
      DiagBackground.LinkType:=ltJRDown;
      DiagBackground.Left:=0;
      DiagBackground.Top:=0;
      DiagBackground.Color:=clWindow;
      TOfs:=NodeSpacing;
      DrawDomainDiag(DiagBackground,DomainNode,ScrollBox,True,TOfs);
   end;
end;
procedure TDomainDes.SetDomainTo(DomainName:String);
var
    DomainNode:TDomainNode;
begin
   if DomainName <> '' then
   begin
      DomainNode:=TDomainNode(ProjectsForm.Comps.NodeNamed(CurrentDomain));
      InsertDomainDiag(DomainNode,ScrollBox1);
      if DomainNode <> nil then
      begin
         if not PropEdit.Visible then PropEdit.Show;
         PropEdit.PropList.CurObj:=DomainNode;
         PropEdit.Memo1.Text:=DomainNode.ListDetails;
         PropEdit.Memo1.Lines.Insert(0,'Domains {');
         PropEdit.Memo1.Lines.Add('}');
      end
      else
         CurrentDomain:='';
   end
   else
   begin
      InsertDomainDiag(nil,ScrollBox1);
   end;
end;
procedure TDomainDes.SetDomain;
begin
   CurrentDomain:='';
   if (ProjectsForm.Comps <> nil)
   and (ProjectsForm.CompTypeName = 'Domain')
   and (ProjectsForm.CompList.itemIndex >= 0)
   and (ProjectsForm.CompList.SelCount > 0) then
   begin
      CurrentDomain:=ProjectsForm.CompTypeName+'.'+
                   ProjectsForm.CompList.Items[ProjectsForm.CompList.itemIndex];
   end;
   SetDomainTo(CurrentDomain);
end;
end.
