unit GroupDesFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls,PackStrListU,
  StdCtrls,ParseNodeU,ErrorFormFU,DesignNodeU;

type
  TGroupDes = class(TForm)
    ScrollBox1: TScrollBox;
  public
    PEIcon:TBitmap;
    UGroup:TBitmap;
    WGroup:TBitmap;
    Snippet:TBitmap;
    CurrentGroup:String;
    procedure PutOn(Panel:TPanel);
    procedure SetGroup;
    procedure SetGroupTo(GroupName:String);
    procedure InsertGroupDiag(GroupNode:TGroupNode;ScrollBox:TScrollBox);
    procedure DBMouseMove(Sender:TObject;Shift:TShiftState;X,Y:Integer);
    procedure DBDragOver(Sender,Source:TObject;X,Y:Integer;State:TDragState;var Accept:Boolean);
    procedure DBDragDrop(Sender,Source:TObject;X,Y:Integer);
//    procedure DBClick(Sender: TObject);
  end;

var
  GroupDes: TGroupDes;

const
   NodeWidth   = 160;
   NodeHeight  = 100;
   NodeSpacing = 10;

implementation

uses PropertyEditFU, ProjectFormFU;


{$R *.DFM}

procedure TGroupDes.DBDragOver(Sender,Source:TObject;X,Y:Integer;State:TDragState;var Accept:Boolean);
begin
   Accept:=(Source = ProjectsForm.CompList) and
           (TCorvusNode(ProjectsForm.Comps.NodeNamed(CurrentGroup)).DragOver(ProjectsForm.CompType));
end;

procedure TGroupDes.DBDragDrop(Sender,Source:TObject;X,Y:Integer);
var
   CurrentNode:TCorvusNode;
   DroppedComp:String;
   DroppedNode:TCorvusNode;
begin
   DroppedComp:=ProjectsForm.CompList.Items[ProjectsForm.CompList.itemIndex];
   DroppedNode:=ProjectsForm.Comps.NodeNamed(ProjectsForm.CompTypeName+'.'+DroppedComp);

   CurrentNode:=TCorvusNode(ProjectsForm.Comps.NodeNamed(CurrentGroup));
   CurrentNode.DragDrop(DroppedNode,DroppedComp);

   SetGroupTo(CurrentGroup);
end;
procedure TGroupDes.PutOn(Panel:TPanel);
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
procedure TGroupDes.DBMouseMove(Sender:TObject;Shift:TShiftState;X,Y:Integer);
begin
   if (X < TGroupDesignNode(Sender).Width-(PEIcon.Width+3)) then
      TGroupDesignNode(Sender).Cursor:=crIBeam
   else
      TGroupDesignNode(Sender).Cursor:=crDefault;
end;
procedure DBClick(Sender: TObject);
begin
   if TGroupDesignNode(Sender).Cursor = crIBeam then
      
end;
procedure TGroupDes.InsertGroupDiag(GroupNode:TGroupNode;ScrollBox:TScrollBox);
var
   Shape1:TDesignNode;
   Shape:TDesignNode;
   DiagBackground:TDiagBackground;
   I,Ofs:Integer;
   Node:TCorvusNode;
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
   if GroupNode = nil then Exit;
   DiagBackground:=TDiagBackground.Create(nil);
   DiagBackground.OnNodeClicked:=ProjectsForm.NodeClicked;
   ScrollBox.InsertControl(DiagBackground);
   DiagBackground.LinkType:=ltJRDown;
   DiagBackground.Left:=0;
   DiagBackground.Top:=0;
   DiagBackground.Color:=clWindow;
   Shape1:=TGroupDesignNode.Create(nil);
   DiagBackground.InsertControl(Shape1);
   Shape1.Top:=NodeSpacing;
   Shape1.Width:=NodeWidth;
   Shape1.Height:=NodeHeight;
   Shape1.Bitmap:=GroupNode.Image;
   Shape1.Title:=GroupNode.Name;
   Shape1.Caption:=GroupNode.Title;
   Shape1.Icon:=PEIcon;
   Shape1.OnDragOver :=DBDragOver;
   Shape1.OnDragDrop :=DBDragDrop;
   Shape1.OnMouseMove:=DBMouseMove;
   DiagBackground.NotifyPos(Shape1);
   if GroupNode.InvokedBy.Count <> 0 then
   begin
      Ofs:=NodeSpacing;
      Shape1.Left:=NodeWidth+NodeSpacing*2;
      DiagBackground.NotifyPos(Shape1);
      for I:=0 to GroupNode.InvokedBy.Count-1 do
      begin
         Node:=GroupNode.InvokedBy[I];
         if Node is TGroupNode then
         begin
            Shape:=TGroupDesignNode.Create(nil);
            Shape.Height:=NodeHeight;
            Shape.Bitmap:=(Node as TGroupNode).Image;
            Shape.Title:=(Node as TGroupNode).Name;
            Shape.Caption:=(Node as TGroupNode).Title;
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
         else if Node is TWorkstationNode then
         begin
            Shape:=TWGroupDesignNode.Create(nil);
            Shape.Height:=60;
            Shape.Bitmap:=WGroup;
            Shape.Title:=(Node as TUserNode).Name;
            Shape.Caption:=(Node as TUserNode).Name;
            Shape.Icon:=PEIcon;
         end
         else if Node is TUserNode then
         begin
            Shape:=TUGroupDesignNode.Create(nil);
            Shape.Height:=60;
            Shape.Bitmap:=UGroup;
            Shape.Title:=(Node as TUserNode).Name;
            Shape.Caption:=(Node as TUserNode).Name;
            Shape.Icon:=PEIcon;
         end
         else
         begin
            if GroupNode.NodeName[I] <> '' then
            begin
               Shape:=TFunctionDesignNode.Create(nil);
               Shape.Height:=NodeHeight;
               Shape.Caption:=GroupNode.NodeName[I];
               Shape.Bitmap:=GetPictureFromServer(GroupNode.NodeName[I]);
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
   end
   else
   begin
      Shape1.Left:=(NodeSpacing div 2);
   end;
   Ofs:=NodeSpacing+(NodeHeight div 2);
   for I:=0 to 9 do
   begin
      Node:=GroupNode.ItemNode[I];
      if Node is TGroupNode then
      begin
         Shape:=TGroupDesignNode.Create(nil);
         Shape.Bitmap:=(Node as TGroupNode).Image;
         Shape.Title:=(Node as TGroupNode).Name;
         Shape.Caption:=(Node as TGroupNode).Title;
         Shape.Icon:=PEIcon;
      end
      else if Node is TProductNode then
      begin
         Shape:=TProductDesignNode.Create(nil);
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
         if GroupNode.NodeName[I] <> '' then
         begin
            Shape:=TFunctionDesignNode.Create(nil);
            Shape.Caption:=GroupNode.NodeName[I];
            Shape.Bitmap:=GetPictureFromServer(GroupNode.NodeName[I]);
            Shape.Icon:=PEIcon;
         end
         else
            Shape:=nil;
      end;
      if Shape <> nil then
      begin
         Shape.Height:=NodeHeight;
         Shape.Width:=NodeWidth;
         Shape.Top:=Ofs-Shape.Height div 2;
         Shape.Key:='F'+IntToStr(I+1);
         if I mod 2 = 0 then
            Shape.Left:=Shape1.Left+Shape1.Width+(NodeSpacing * 2)
         else
            Shape.Left:=Shape1.Left+(Shape1.Width*2)+(NodeSpacing * 2)+(NodeSpacing div 2);
         DiagBackground.InsertControl(Shape);
         Shape1.JoinTo(Shape);
         Ofs:=Shape.Top+Shape.Height+(NodeSpacing div 2);
      end;
   end;
end;
procedure TGroupDes.SetGroupTo(GroupName:String);
var
    GroupNode:TGroupNode;
begin
   if GroupName <> '' then
   begin
      GroupNode:=TGroupNode(ProjectsForm.Comps.NodeNamed(CurrentGroup));
      InsertGroupDiag(GroupNode,ScrollBox1);
      if GroupNode <> nil then
      begin
         if not PropEdit.Visible then PropEdit.Show;
         PropEdit.PropList.CurObj:=GroupNode;
         PropEdit.Memo1.Text:=GroupNode.ListDetails;
         PropEdit.Memo1.Lines.Insert(0,'Groups {');
         PropEdit.Memo1.Lines.Add('}');
      end
      else
         CurrentGroup:='';
   end
   else
   begin
      InsertGroupDiag(nil,ScrollBox1);
   end;
end;
procedure TGroupDes.SetGroup;
begin
   CurrentGroup:='';
   if (ProjectsForm.Comps <> nil)
   and (ProjectsForm.CompTypeName = 'Group')
   and (ProjectsForm.CompList.itemIndex >= 0)
   and (ProjectsForm.CompList.SelCount > 0) then
   begin
      CurrentGroup:=ProjectsForm.CompTypeName+'.'+
                   ProjectsForm.CompList.Items[ProjectsForm.CompList.itemIndex];
   end;
   SetGroupTo(CurrentGroup);
end;
end.
