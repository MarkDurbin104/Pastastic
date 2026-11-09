unit UWGroupDesFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls,PackStrListU,GPCSGUID,GPCSBase_TLB,Compress,CompressU,Bin2String,
  StdCtrls,ParseNodeU,ErrorFormFU,DesignNodeU;

type
  TUWGroupDes = class(TForm)
    ScrollBox1: TScrollBox;
  public
    PEIcon:TBitmap;
    UGroup:TBitmap;
    WGroup:TBitmap;
    Snippet:TBitmap;
    CurrentGroup:String;
    procedure PutOn(Panel:TPanel);
    procedure SetUGroup;
    procedure SetWGroup;
    procedure SetGroupTo(GroupName:String);
    procedure InsertGroupDiag(GroupNode:TUserNode;ScrollBox:TScrollBox);
    procedure DBDragOver(Sender,Source:TObject;X,Y:Integer;State:TDragState;var Accept:Boolean);
    procedure DBDragDrop(Sender,Source:TObject;X,Y:Integer);
  end;

var
  UWGroupDes: TUWGroupDes;

const
   NodeWidth   = 160;
   NodeHeight  = 100;
   NodeSpacing = 10;

implementation

uses PropertyEditFU, ProjectFormFU;


{$R *.DFM}


procedure TUWGroupDes.DBDragOver(Sender,Source:TObject;X,Y:Integer;State:TDragState;var Accept:Boolean);
begin
   Accept:=(Source = ProjectsForm.CompList) and
           (TCorvusNode(ProjectsForm.Comps.NodeNamed(CurrentGroup)).DragOver(ProjectsForm.CompType));
end;

procedure TUWGroupDes.DBDragDrop(Sender,Source:TObject;X,Y:Integer);
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
procedure TUWGroupDes.PutOn(Panel:TPanel);
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
procedure TUWGroupDes.InsertGroupDiag(GroupNode:TUserNode;ScrollBox:TScrollBox);
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
   if GroupNode is TWorkstationNode then
   begin
      Shape1:=TUGroupDesignNode.Create(nil);
      Shape1.Bitmap:=WGroup
   end
   else
   begin
      Shape1:=TUGroupDesignNode.Create(nil);
      Shape1.Bitmap:=UGroup;
   end;
   DiagBackground.InsertControl(Shape1);
   Shape1.Top:=NodeSpacing;
   Shape1.Width:=NodeWidth;
   Shape1.Height:=60;
   Shape1.Title:=GroupNode.Name;
   Shape1.Caption:=GroupNode.Name;
   Shape1.Icon:=PEIcon;
   Shape1.OnDragOver:=DBDragOver;
   Shape1.OnDragDrop:=DBDragDrop;
   DiagBackground.NotifyPos(Shape1);
   Shape1.Left:=(NodeSpacing div 2);
   Ofs:=NodeSpacing+(NodeHeight div 2);
   for I:=0 to GroupNode.GetItemNodeCount-1 do
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
      else
      begin
         if GroupNode.NodeName[I] <> '' then
         begin
            Shape:=TGroupDesignNode.Create(nil);
            Shape.Caption:=GroupNode.NodeName[I];
            Shape.PenColor:=clRed;
         end
         else
            Shape:=nil;
      end;
      if Shape <> nil then
      begin
         Shape.Height:=NodeHeight;
         Shape.Width:=NodeWidth;
         Shape.Key:='';
         if I mod 3 = 0 then
         begin
            Shape.Left:=Shape1.Left+Shape1.Width+(NodeSpacing * 2);
            Shape.Top:=Ofs-Shape.Height div 2;
         end
         else if I mod 3 = 1 then
         begin
            Shape.Left:=Shape1.Left+(Shape1.Width*3)+(NodeSpacing * 3)+(NodeSpacing div 2);
            Shape.Top:=Ofs-Shape.Height div 2;
            Ofs:=Shape.Top+Shape.Height+(NodeSpacing div 2);
         end
         else
         begin
            Shape.Left:=Shape1.Left+(Shape1.Width*2)+(NodeSpacing * 2)+(NodeSpacing div 2);
            Shape.Top:=Ofs-Shape.Height div 2;
            Ofs:=Shape.Top+Shape.Height+(NodeSpacing div 2);
         end;
         DiagBackground.InsertControl(Shape);
         Shape1.JoinTo(Shape);
      end;
   end;
end;
procedure TUWGroupDes.SetGroupTo(GroupName:String);
var
    GroupNode:TUserNode;
    GType:String;
begin
   if GroupName <> '' then
   begin
      if GroupName[1] = 'W' then
      begin
         GType:='WorkStation';
         GroupNode:=TWorkstationNode(ProjectsForm.Comps.NodeNamed(CurrentGroup));
      end
      else
      begin
         GType:='User';
         GroupNode:=TUserNode(ProjectsForm.Comps.NodeNamed(CurrentGroup));
      end;
      InsertGroupDiag(GroupNode,ScrollBox1);
      if GroupNode <> nil then
      begin
         if not PropEdit.Visible then PropEdit.Show;
         PropEdit.PropList.CurObj:=GroupNode;
         PropEdit.Memo1.Text:=GroupNode.ListDetails;
         PropEdit.Memo1.Lines.Insert(0,GType+'s {');
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

procedure TUWGroupDes.SetUGroup;
begin
   CurrentGroup:='';
   if (ProjectsForm.Comps <> nil)
   and (ProjectsForm.CompTypeName = 'User')
   and (ProjectsForm.CompList.itemIndex >= 0)
   and (ProjectsForm.CompList.SelCount > 0) then
   begin
      CurrentGroup:=ProjectsForm.CompTypeName+'.'+
                   ProjectsForm.CompList.Items[ProjectsForm.CompList.itemIndex];
   end;
   SetGroupTo(CurrentGroup);
end;
procedure TUWGroupDes.SetWGroup;
begin
   CurrentGroup:='';
   if (ProjectsForm.Comps <> nil)
   and (ProjectsForm.CompTypeName = 'WorkStation')
   and (ProjectsForm.CompList.itemIndex >= 0)
   and (ProjectsForm.CompList.SelCount > 0) then
   begin
      CurrentGroup:=ProjectsForm.CompTypeName+'.'+
                   ProjectsForm.CompList.Items[ProjectsForm.CompList.itemIndex];
   end;
   SetGroupTo(CurrentGroup);
end;
end.
