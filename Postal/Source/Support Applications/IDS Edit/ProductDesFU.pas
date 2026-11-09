unit ProductDesFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls,PackStrListU,StdCtrls,ParseNodeU,ErrorFormFU,DesignNodeU;

type
  TProductDes = class(TForm)
    ScrollBox1: TScrollBox;
  public
    PEIcon:TBitmap;
    UGroup:TBitmap;
    WGroup:TBitmap;
    Snippet:TBitmap;
    CustDisp:TBitmap;
    Receipt:TBitmap;
    CurrentProd:String;
    procedure PutOn(Panel:TPanel);
    procedure SetProduct;
    procedure InsertProductDiag(ProductNode:TProductNode;ScrollBox:TScrollBox);
    function DrawProductDiag(DiagBackground:TDiagBackground;ProductNode:TProductNode;ScrollBox:TScrollBox;ShowInvoke:Boolean;var FKey,FKeyOfs,DOfs,TOfs:Integer;DomList,ItemList:TStringList):TDesignNode;
    procedure DrawOnSnippets(ProdDesNode:TDesignNode;DiagBackground:TDiagBackground;ProductNode:TProductNode;ScrollBox:TScrollBox;var FKeyOfs,FKey:Integer);
    procedure SetProductTo(ProdName:String);
    procedure DBDragOver(Sender,Source:TObject;X,Y:Integer;State:TDragState;var Accept:Boolean);
    procedure DBDragDrop(Sender,Source:TObject;X,Y:Integer);
  end;

var
  ProductDes: TProductDes;

const
   NodeWidth   = 160;
   NodeHeight  = 100;
   NodeSpacing = 10;

implementation

uses PropertyEditFU, ProjectFormFU;


{$R *.DFM}


procedure TProductDes.DBDragOver(Sender,Source:TObject;X,Y:Integer;State:TDragState;var Accept:Boolean);
begin
   Accept:=(Source = ProjectsForm.CompList) and
           (TCorvusNode(ProjectsForm.Comps.NodeNamed(CurrentProd)).DragOver(ProjectsForm.CompType));
end;

procedure TProductDes.DBDragDrop(Sender,Source:TObject;X,Y:Integer);
var
   CurrentNode:TCorvusNode;
   DroppedComp:String;
   DroppedNode:TCorvusNode;
begin
   DroppedComp:=ProjectsForm.CompList.Items[ProjectsForm.CompList.itemIndex];
   DroppedNode:=ProjectsForm.Comps.NodeNamed(ProjectsForm.CompTypeName+'.'+DroppedComp);
   
   CurrentNode:=TCorvusNode(ProjectsForm.Comps.NodeNamed(CurrentProd));
   CurrentNode.DragDrop(DroppedNode,DroppedComp);

   SetProductTo(CurrentProd);
end;

procedure TProductDes.PutOn(Panel:TPanel);
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
function TProductDes.DrawProductDiag(DiagBackground:TDiagBackground;ProductNode:TProductNode;ScrollBox:TScrollBox;ShowInvoke:Boolean;var FKey,FKeyOfs,DOfs,TOfs:Integer;DomList,ItemList:TStringList):TDesignNode;
var
   Shape1:TProductDesignNode;
   Shape:TDesignNode;
   I,Ofs:Integer;
   Node:TCorvusNode;
   DomNode:TDomainNode;
   SL:TPackStringList;
   Idx:Integer;
   ShowConst:Boolean;
   TL,BL:String;
   LogNode:TLogFormatNode;
begin
   ShowConst:=False;
   Inc(DOfs,NodeHeight div 5);
   if ShowInvoke and (ProductNode.PLU <> '') and (not (ProductNode.PLU[1] in ['0'..'9'])) then
   begin
      Inc(DOfs,30);
      ShowConst:=True;
   end;
   if ProductNode.BasedOnNode <> nil then
   begin
      DrawProductDiag(DiagBackground,
                      TProductNode(ProductNode.BasedOnNode),
                      ScrollBox,False,FKey,FKeyOfs,DOfs,TOfs,DomList,ItemList);
      Inc(TOfs,NodeHeight div 5);
   end;
   Shape1:=TProductDesignNode.Create(nil);
   DiagBackground.InsertControl(Shape1);
   Shape1.Top:=TOfs;
   Shape1.Width:=NodeWidth;
   Shape1.Height:=NodeHeight;
   Shape1.Bitmap:=ProductNode.Image;
   Shape1.Price:=ProductNode.UnitPrice;
   Shape1.Title:=ProductNode.Name;
   Shape1.Caption:=ProductNode.Title;
   Shape1.Icon:=PEIcon;
   Shape1.OnDragOver:=DBDragOver;
   Shape1.OnDragDrop:=DBDragDrop;
   
   if ProjectsForm.Comps.NodeNamed('Constant.'+ProductNode.PLU) <> nil then
      Shape1.PLU:=TConstantNode(ProjectsForm.Comps.NodeNamed('Constant.'+ProductNode.PLU))[0]
   else
      Shape1.PLU:=ProductNode.PLU;

   if ShowInvoke and (ProductNode.InvokedBy.Count <> 0) then
   begin
      Ofs:=NodeSpacing;
      Shape1.Left:=NodeWidth+NodeSpacing*2;
      DiagBackground.NotifyPos(Shape1);
      for I:=0 to ProductNode.InvokedBy.Count-1 do
      begin
         Node:=ProductNode.InvokedBy[I];
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
            Shape.Icon:=PEIcon;
            if ProjectsForm.Comps.NodeNamed('Constant.'+(Node as TProductNode).PLU) <> nil then
               TProductDesignNode(Shape).PLU:=TConstantNode(ProjectsForm.Comps.NodeNamed('Constant.'+(Node as TProductNode).PLU))[0]
            else
               TProductDesignNode(Shape).PLU:=(Node as TProductNode).PLU;
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
            if ProductNode.NodeName[I] <> '' then
            begin
               Shape:=TFunctionDesignNode.Create(nil);
               Shape.Height:=NodeHeight;
               Shape.Caption:=ProductNode.NodeName[I];
               Shape.Bitmap:=GetPictureFromServer(ProductNode.NodeName[I]);
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
      Shape1.Left:=NodeWidth+NodeSpacing*2;
   end;
   if ShowConst then
   begin
       Node:=ProjectsForm.Comps.NodeNamed('Constant.'+ProductNode.PLU);
       Shape:=TConstantDesignNode.Create(nil);
       if Node = nil then
       begin
          Shape.Title:=ProductNode.PLU;
          Shape.Caption:='????????';
       end
       else
       begin
          Shape.Title:=ProductNode.PLU;
          if Node.Count > 0 then
             Shape.Caption:=Node[0]
          else
             Shape.Caption:='????????';
       end;
       Shape.Height:=30;
       Shape.Width:=Shape1.Width;
       Shape.Left:=Shape1.Left;
       Shape.Top:=Shape1.Top+Shape1.Height+NodeSpacing div 2;
       DiagBackground.InsertControl(Shape);
       Shape1.JoinTo(Shape);
   end;
   DiagBackground.NotifyPos(Shape1);
   for I:=0 to 9 do
   begin
      Node:=ProductNode.ItemNode[I];
      Idx:=ItemList.IndexOf(ProductNode.NodeName[I]);
      if Node is TProductNode then
      begin
         Shape:=TProductDesignNode.Create(nil);
         Shape.Bitmap:=(Node as TProductNode).Image;
         Shape.Title:=(Node as TProductNode).Name;
         Shape.Caption:=(Node as TProductNode).Title;
         if Copy(ProductNode.NodeName[I],1,4) = 'Swap' then
            TProductDesignNode(Shape).IsSwap:=True;
         TProductDesignNode(Shape).Price:=(Node as TProductNode).UnitPrice;
         if ProjectsForm.Comps.NodeNamed('Constant.'+(Node as TProductNode).PLU) <> nil then
            TProductDesignNode(Shape).PLU:=TConstantNode(ProjectsForm.Comps.NodeNamed('Constant.'+(Node as TProductNode).PLU))[0]
         else
            TProductDesignNode(Shape).PLU:=(Node as TProductNode).PLU;
         Shape.Icon:=PEIcon;
      end
      else
      begin
         if ProductNode.NodeName[I] <> '' then
         begin
            Shape:=TFunctionDesignNode.Create(nil);
            Shape.Caption:=ProductNode.NodeName[I];
            Shape.Bitmap:=GetPictureFromServer(ProductNode.NodeName[I]);
            Shape.Icon:=PEIcon;
         end
         else
            Shape:=nil;
      end;
      if Shape <> nil then
      begin
         Shape.Height:=NodeHeight;
         Shape.Width:=NodeWidth;
         if Idx = -1 then
         begin
            Shape.Top:=FKeyOfs-Shape.Height div 2;
            Idx:=ItemList.AddObject(ProductNode.NodeName[I],TObject(Shape.Top));
            FKeyOfs:=Shape.Top+Shape.Height+(NodeSpacing div 2);
            Inc(FKey);
         end
         else
         begin
            Shape.Top:=Integer(ItemList.Objects[Idx]);

         end;
         Shape.Key:='F'+IntToStr(Idx+1);
         if Idx mod 2 = 0 then
            Shape.Left:=Shape1.Left+Shape1.Width+(NodeSpacing * 2)
         else
            Shape.Left:=Shape1.Left+(Shape1.Width*2)+(NodeSpacing * 2)+(NodeSpacing div 2);
         DiagBackground.InsertControl(Shape);
         Shape1.JoinTo(Shape);
      end;
   end;
   SL:=TPackStringList.Create;
   SL.CommaText:=ProductNode.Domains;
   for I:=0 to SL.Count-1 do
   begin
      DomNode:=TDomainNode(ProjectsForm.Comps.NodeNamed('Domain.'+SL[I]));
      if DomNode <> nil then
      begin
         Idx:=DomList.IndexOf(DomNode.Name);
         Shape:=TDomainDesignNode.Create(nil);
         Shape.Caption:=DomNode.Title;
         Shape.Title:=DomNode.Name;
         Shape.Height:=45;
         Shape.Width:=NodeWidth;
         Shape.Left:=Shape1.Left;
         Shape.Icon:=PEIcon;
         DiagBackground.InsertControl(Shape);
         Shape1.JoinTo(Shape);
         if Idx = -1 then
         begin
            Shape.Top:=DOfs;
            DomList.AddObject(DomNode.Name,TObject(DOfs));
            Inc(DOfs,Shape.Height+NodeSpacing div 4);
         end
         else
         begin
            Shape.Top:=Integer(DomList.Objects[Idx]);
         end;
         DiagBackground.NotifyPos(Shape);
      end;
   end;
   if ShowInvoke and (ProductNode.Customer <> '') then
   begin
      SL.CommaText:=ProductNode.Customer;
      Shape:=TCustDispDesignNode.Create(nil);
      I:=0;
      TL:=''; while (I < SL.Count) and (SL[I] <> '^') do begin if TL = '' then TL:=SL[I] else TL:=TL+','+SL[I]; Inc(I); end;
      if (I < SL.Count) then Inc(I);
      BL:=''; while (I < SL.Count)                    do begin if BL = '' then BL:=SL[I] else BL:=BL+','+SL[I]; Inc(I); end;

      Shape.Title:=TL;
      Shape.Caption:=BL;
      Shape.Height:=36;
      Shape.Width:=NodeWidth;
      Shape.Top:=DOfs;
      Shape.Left:=Shape1.Left;
      Shape.Bitmap:=CustDisp;
      DiagBackground.InsertControl(Shape);
      Shape1.JoinTo(Shape);
      Inc(DOfs,Shape.Height+NodeSpacing div 2);
   end;
   if ShowInvoke and (ProductNode.LogAs <> '') then
   begin
      LogNode:=TLogFormatNode(ProjectsForm.Comps.NodeNamed('LogFormat.'+ProductNode.LogAs));
      SL.CommaText:=ProductNode.LogAs;
      Shape:=TLogFormatDesignNode.Create(nil);
      Shape.Title:=ProductNode.LogAs;
      if LogNode <> nil then
         Shape.Caption:=LogNode.CommaText
      else
         Shape.Caption:='"????????","??????????"';
      Shape.Height:=100;
      Shape.Width:=NodeWidth;
      Shape.Top:=DOfs;
      Shape.Left:=Shape1.Left;
      Shape.Bitmap:=Receipt;
      DiagBackground.InsertControl(Shape);
      Shape1.JoinTo(Shape);
      Inc(DOfs,Shape.Height+NodeSpacing div 4);
   end;
   SL.Free;
   Result:=Shape1;
end;
procedure TProductDes.DrawOnSnippets(ProdDesNode:TDesignNode;DiagBackground:TDiagBackground;ProductNode:TProductNode;ScrollBox:TScrollBox;var FKeyOfs,FKey:Integer);
var
   Shape:TDesignNode;
   I:Integer;
   SNode:TSnippetNode;
   SL:TPackStringList;
begin
//   Inc(FKeyOfs,NodeSpacing);
   if ProductNode.BasedOnNode <> nil then
   begin
      DrawOnSnippets(ProdDesNode,DiagBackground,TProductNode(ProductNode.BasedOnNode),
                     ScrollBox,FKeyOfs,FKey);
   end;
   SL:=TPackStringList.Create;
   SL.CommaText:=ProductNode.Snippets;
   for I:=0 to SL.Count-1 do
   begin
      SNode:=TSnippetNode(ProjectsForm.Comps.NodeNamed('Snippet.'+SL[I]));
      if SNode <> nil then
      begin
         Shape:=TSnippetDesignNode.Create(nil);
         Shape.Bitmap:=Snippet;
         Shape.Title:=SNode.Name;
         Shape.Caption:=SNode.InsertBetween;
         Shape.Icon:=PEIcon;
      end
      else
      begin
         Shape:=TSnippetDesignNode.Create(nil);
         Shape.Bitmap:=Snippet;
         Shape.Title:=SL[I];
         Shape.Icon:=PEIcon;
      end;
      if Shape <> nil then
      begin
         Shape.Height:=37;
         Shape.Width:=NodeWidth;
         Shape.Top:=FKeyOfs-Shape.Height div 2;
         if FKey mod 2 = 0 then
            Shape.Left:=ProdDesNode.Left+ProdDesNode.Width+(NodeSpacing * 2)
         else
            Shape.Left:=ProdDesNode.Left+(ProdDesNode.Width*2)+(NodeSpacing * 2)+(NodeSpacing div 2);
         DiagBackground.InsertControl(Shape);
         ProdDesNode.JoinTo(Shape);
         FKeyOfs:=Shape.Top+Shape.Height+(NodeSpacing div 4);
         Inc(FKey);
      end;
   end;
   SL.Free;
end;

procedure TProductDes.InsertProductDiag(ProductNode:TProductNode;ScrollBox:TScrollBox);
var
   FKey:Integer;
   FKeyOfs:Integer;
   DOfs:Integer;
   TOfs:Integer;
   I:Integer;
   DiagBackground:TDiagBackground;
   DomList:TStringList;
   ItemList:TStringList;
   SL:TStringList;
   ProdDesNode:TDesignNode;
   SubProductNode:TProductNode;
   DomainNode:TDomainNode;
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
   if ProductNode <> nil then
   begin
      DiagBackground:=TDiagBackground.Create(nil);
      DiagBackground.OnNodeClicked:=ProjectsForm.NodeClicked;
      ScrollBox.InsertControl(DiagBackground);
      DiagBackground.LinkType:=ltJRDown;
      DiagBackground.Left:=0;
      DiagBackground.Top:=0;
      DiagBackground.Color:=clWindow;
      FKey:=0;
      FKeyOfs:=NodeHeight div 2+NodeSpacing;
      DOfs:=(NodeSpacing div 2)+NodeHeight;
      TOfs:=NodeSpacing;
      DomList:=TStringList.Create;
      ItemList:=TStringList.Create;
      ProdDesNode:=DrawProductDiag(DiagBackground,ProductNode,ScrollBox,True,FKey,FKeyOfs,DOfs,TOfs,DomList,ItemList);
      SL:=TStringList.Create;
      SL.Add(ProductNode.Title);
      for I:=0 to DomList.Count-1 do
      begin
         DomainNode:=TDomainNode(ProjectsForm.Comps.NodeNamed('Domain.'+DomList[I]));
         if DomainNode <> nil then
            SL.Add(DomainNode.Prompt)
         else
            SL.Add('Enter '+DomList[I]);
      end;
      for I:=0 to ItemList.Count-1 do
      begin
         SubProductNode:=TProductNode(ProjectsForm.Comps.NodeNamed(ItemList[I]));
         if SubProductNode <> nil then
            SL.Add('Press F'+IntToStr(I+1)+' for '+SubProductNode.Title)
         else
            SL.Add('Press F'+IntToStr(I+1)+' for '+ItemList[I]);
      end;
      DomList.Free;
      ItemList.Free;
      ErrorForm.Errors.Clear;
      ErrorForm.Errors.Text:=SL.Text;
      SL.Free;
      DrawOnSnippets(ProdDesNode,DiagBackground,ProductNode,ScrollBox,FKeyOfs,FKey);
   end;
end;
procedure TProductDes.SetProductTo(ProdName:String);
var
    ProductNode:TProductNode;
begin
   if ProdName <> '' then
   begin
      ProductNode:=TProductNode(ProjectsForm.Comps.NodeNamed(CurrentProd));
      InsertProductDiag(ProductNode,ScrollBox1);
      if ProductNode <> nil then
      begin
         if not PropEdit.Visible then PropEdit.Show;
         PropEdit.PropList.CurObj:=ProductNode;
         PropEdit.Memo1.Text:=ProductNode.ListDetails;
         PropEdit.Memo1.Lines.Insert(0,'Products {');
         PropEdit.Memo1.Lines.Add('}');
      end
      else
         CurrentProd:='';
   end
   else
   begin
      InsertProductDiag(nil,ScrollBox1);
   end;
end;
procedure TProductDes.SetProduct;
begin
   CurrentProd:='';
   if  (ProjectsForm.Comps <> nil)
   and (ProjectsForm.CompTypeName = 'Product')
   and (ProjectsForm.CompList.itemIndex >= 0)
   and (ProjectsForm.CompList.SelCount > 0)  then
   begin
      CurrentProd:=ProjectsForm.CompTypeName+'.'+
                   ProjectsForm.CompList.Items[ProjectsForm.CompList.itemIndex];
   end;
   SetProductTo(CurrentProd);
end;
end.
