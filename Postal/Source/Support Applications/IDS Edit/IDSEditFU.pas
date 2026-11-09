unit IDSEditFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,TokenParser,
  ExtCtrls, StdCtrls,PackStrListU, Menus,Printers,SavePosFormU,DesignNodeU,ParseNodeU;
const
   EmbedForms = True;
type
  TForm1 = class(TSavePosForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel4: TPanel;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    N1: TMenuItem;
    Print1: TMenuItem;
    Exit1: TMenuItem;
    Froms1: TMenuItem;
    Group1: TMenuItem;
    Product1: TMenuItem;
    WUGroup1: TMenuItem;
    Selector1: TMenuItem;
    MonitorTimer: TTimer;
    Panel3: TPanel;
    Splitter1: TSplitter;
    Errors1: TMenuItem;
    Domains1: TMenuItem;
    Snippets1: TMenuItem;
    PrintAll1: TMenuItem;
    N2: TMenuItem;
    ReLoad1: TMenuItem;
    CheckIntegrity1: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    FileMonitor2: TMenuItem;
    None1: TMenuItem;
    Prompt1: TMenuItem;
    Automatic1: TMenuItem;
    Save1: TMenuItem;
    Save7As1: TMenuItem;
    Tools1: TMenuItem;
    Build1: TMenuItem;
    Make1: TMenuItem;
    BuildAll1: TMenuItem;
    N3: TMenuItem;
    Products1: TMenuItem;
    Groups1: TMenuItem;
    Users1: TMenuItem;
    Workstations1: TMenuItem;
    PickLists1: TMenuItem;
    LookUps1: TMenuItem;
    ComponentList1: TMenuItem;
    Documents1: TMenuItem;
    ComponentList2: TMenuItem;
    HelpSkeleton1: TMenuItem;
    TextList1: TMenuItem;
    PrintGroups1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure Group1Click(Sender: TObject);
    procedure Product1Click(Sender: TObject);
    procedure WUGroup1Click(Sender: TObject);
    procedure Selector1Click(Sender: TObject);
    procedure Automatic1Click(Sender: TObject);
    procedure MonitorTimerTimer(Sender: TObject);
    procedure Errors1Click(Sender: TObject);
    procedure Domains1Click(Sender: TObject);
    procedure Snippets1Click(Sender: TObject);
    procedure PrintAll1Click(Sender: TObject);
    procedure ReLoad1Click(Sender: TObject);
    procedure CheckIntegrity1Click(Sender: TObject);
    procedure HelpSkeleton1Click(Sender: TObject);
    procedure ComponentList2Click(Sender: TObject);
    procedure TextList1Click(Sender: TObject);
    procedure PrintGroups1Click(Sender: TObject);
    procedure Groups1Click(Sender: TObject);
  public
    CurrentForm:TForm;
    procedure CompClick(Sender: TObject);
    procedure LoadRegEntries;
    procedure PrintCurrentDiag(PrintPageNos:Boolean;var PageNo:Integer);
    procedure PrintCompStruct(CompName:String;var PageNo:Integer);
    procedure PrintGroupStruct(CompName:String;var PageNo:Integer);
  end;

var
  Form1: TForm1;

implementation

uses ProjectFormFU, ErrorFormFU, GroupDesFU, ProductDesFU, PropertyEditFU,
  UWGroupDesFU, DomainDesFU, SnippetDesFU, ListOutputFU;

{$R *.DFM}


procedure TForm1.CompClick(Sender: TObject);
begin
   if ProjectsForm.CompList.ItemIndex < 0 then Exit;

   ProjectsForm.CompList.SetFocus;
   if ProjectsForm.CompTypeName = 'Group' then
   begin
      CurrentForm:=GroupDes;
      if EmbedForms then
      begin
         if ProductDes.Parent <> nil then ProductDes.Hide;
         if UWGroupDes.Parent <> nil then UWGroupDes.Hide;
         if DomainDes.Parent <> nil then DomainDes.Hide;
         if SnippetDes.Parent <> nil then SnippetDes.Hide;
         if ListOutput.Parent <> nil then ListOutput.Hide;
      end;
      GroupDes.Show;
      GroupDes.SetGroup;
   end
   else if ProjectsForm.CompTypeName = 'User' then
   begin
      CurrentForm:=UWGroupDes;
      if EmbedForms then
      begin
         if ProductDes.Parent <> nil then ProductDes.Hide;
         if GroupDes.Parent <> nil then UWGroupDes.Hide;
         if DomainDes.Parent <> nil then DomainDes.Hide;
         if SnippetDes.Parent <> nil then SnippetDes.Hide;
         if ListOutput.Parent <> nil then ListOutput.Hide;
      end;
      UWGroupDes.Show;
      UWGroupDes.SetUGroup;
   end
   else if ProjectsForm.CompTypeName = 'WorkStation' then
   begin
      CurrentForm:=UWGroupDes;
      if EmbedForms then
      begin
         if ProductDes.Parent <> nil then ProductDes.Hide;
         if GroupDes.Parent <> nil then UWGroupDes.Hide;
         if DomainDes.Parent <> nil then DomainDes.Hide;
         if SnippetDes.Parent <> nil then SnippetDes.Hide;
         if ListOutput.Parent <> nil then ListOutput.Hide;
      end;
      UWGroupDes.Show;
      UWGroupDes.SetWGroup;
   end
   else if ProjectsForm.CompTypeName = 'Product' then
   begin
      CurrentForm:=ProductDes;
      if EmbedForms then
      begin
         if UWGroupDes.Parent <> nil then UWGroupDes.Hide;
         if GroupDes.Parent <> nil then UWGroupDes.Hide;
         if DomainDes.Parent <> nil then DomainDes.Hide;
         if SnippetDes.Parent <> nil then SnippetDes.Hide;
         if ListOutput.Parent <> nil then ListOutput.Hide;
      end;
      ProductDes.Show;
      ProductDes.SetProduct;
   end
   else if ProjectsForm.CompTypeName = 'Domain' then
   begin
      CurrentForm:=DomainDes;
      if EmbedForms then
      begin
         if UWGroupDes.Parent <> nil then UWGroupDes.Hide;
         if GroupDes.Parent <> nil then UWGroupDes.Hide;
         if ProductDes.Parent <> nil then ProductDes.Hide;
         if SnippetDes.Parent <> nil then SnippetDes.Hide;
         if ListOutput.Parent <> nil then ListOutput.Hide;
      end;
      DomainDes.Show;
      DomainDes.SetDomain;
   end
   else if ProjectsForm.CompTypeName = 'Snippet' then
   begin
      CurrentForm:=SnippetDes;
      if EmbedForms then
      begin
         if UWGroupDes.Parent <> nil then UWGroupDes.Hide;
         if GroupDes.Parent <> nil then UWGroupDes.Hide;
         if ProductDes.Parent <> nil then ProductDes.Hide;
         if DomainDes.Parent <> nil then DomainDes.Hide;
         if ListOutput.Parent <> nil then ListOutput.Hide;
      end;
      SnippetDes.Show;
      SnippetDes.SetSnippet;
   end
   else
   begin
      if EmbedForms then
      begin
         if ProductDes.Parent <> nil then ProductDes.Hide;
         if UWGroupDes.Parent <> nil then UWGroupDes.Hide;
         if GroupDes.Parent <> nil then UWGroupDes.Hide;
         if DomainDes.Parent <> nil then DomainDes.Hide;
         if SnippetDes.Parent <> nil then SnippetDes.Hide;
         if ListOutput.Parent <> nil then ListOutput.Hide;
      end;
   end;
end;
procedure TForm1.FormShow(Sender: TObject);
begin
   LoadRegEntries;

   if EmbedForms then
      ListOutput.PutOn(Panel4);

   if EmbedForms then
      DomainDes.PutOn(Panel4);
   DomainDes.PEIcon:=ProjectsForm.PEIcon.Picture.Bitmap;
   DomainDes.UDomain:=ProjectsForm.UGroup.Picture.Bitmap;
   DomainDes.WDomain:=ProjectsForm.WGroup.Picture.Bitmap;
   DomainDes.Snippet:=ProjectsForm.Snippet.Picture.Bitmap;
   if EmbedForms then
      DomainDes.Hide;

   if EmbedForms then
      SnippetDes.PutOn(Panel4);
   SnippetDes.PEIcon:=ProjectsForm.PEIcon.Picture.Bitmap;
   SnippetDes.USnippet:=ProjectsForm.UGroup.Picture.Bitmap;
   SnippetDes.WSnippet:=ProjectsForm.WGroup.Picture.Bitmap;
   SnippetDes.Snippet:=ProjectsForm.Snippet.Picture.Bitmap;
   if EmbedForms then
      SnippetDes.Hide;

   if EmbedForms then
      GroupDes.PutOn(Panel4);
   GroupDes.PEIcon:=ProjectsForm.PEIcon.Picture.Bitmap;
   GroupDes.UGroup:=ProjectsForm.UGroup.Picture.Bitmap;
   GroupDes.WGroup:=ProjectsForm.WGroup.Picture.Bitmap;
   GroupDes.Snippet:=ProjectsForm.Snippet.Picture.Bitmap;
   if EmbedForms then
      GroupDes.Hide;

   if EmbedForms then
      UWGroupDes.PutOn(Panel4);
   UWGroupDes.PEIcon:=ProjectsForm.PEIcon.Picture.Bitmap;
   UWGroupDes.UGroup:=ProjectsForm.UGroup.Picture.Bitmap;
   UWGroupDes.WGroup:=ProjectsForm.WGroup.Picture.Bitmap;
   UWGroupDes.Snippet:=ProjectsForm.Snippet.Picture.Bitmap;
   if EmbedForms then
      UWGroupDes.Hide;

   if EmbedForms then
      ProductDes.PutOn(Panel4);
   ProductDes.PEIcon:=ProjectsForm.PEIcon.Picture.Bitmap;
   ProductDes.UGroup:=ProjectsForm.UGroup.Picture.Bitmap;
   ProductDes.WGroup:=ProjectsForm.WGroup.Picture.Bitmap;
   ProductDes.Snippet:=ProjectsForm.Snippet.Picture.Bitmap;
   ProductDes.CustDisp:=ProjectsForm.CustDisp.Picture.Bitmap;
   ProductDes.Receipt:=ProjectsForm.Receipt.Picture.Bitmap;

   if EmbedForms then
      ProductDes.Hide;

   ProjectsForm.CompList.OnDblClick:=CompClick;
//   ProjectsForm.CompList.OnClick:=CompClick;
   if EmbedForms then
      ProjectsForm.PutOn(Panel1)
   else
      ProjectsForm.PutOn(nil);

   if EmbedForms then
      ErrorForm.PutOn(Panel3)
   else
      ErrorForm.PutOn(nil);
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
//   ProjectsForm.Comps.SaveAs(Edit1.Text,Edit2.Text);
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
   Close;
end;
procedure PrintControl(Title:String;Control:TWinControl;PrintSelf,PrintPageNos:Boolean;var PageNo:Integer);
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
   PN:String;
   Divisor:Integer;
begin
   if Control <> nil then
   begin
      FirstComp:=True;
      for I:=0 to Control.ControlCount-1 do
      begin
         if Control.Controls[I] is TWinControl then
         begin
            Comp:=TWinControl(Control.Controls[I]);
            if Comp.Visible then
            begin
               if FirstComp then
               begin
                  FirstComp    :=False;
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
      if PageNo < 1 then
      begin
         Printer.Title:=Title;
         Printer.BeginDoc;
      end;
      Printer.Canvas.CopyMode:=cmSrcCopy;
      SetMapMode(Printer.Handle,MM_HIMETRIC);
      GetWindowExtEx(Printer.Canvas.Handle,Size);
      SetMapMode(Printer.Handle,MM_ANISOTROPIC);
      Divisor:=Size.cx div (NodeSpacing*5+NodeWidth*4);
      Size.cx:=Size.cx div Divisor;
      Size.cy:=Size.cy div Divisor;
      SetWindowExtEx(Printer.Canvas.Handle,Size.cx,0-Size.cy,@OSize);
//      Size.cx:=Size.cx-20; // add an overlap margin
      Size.cy:=Size.cy-20; // add an overlap margin
      MaxX:=((Extent.Right-Extent.Left) div Size.cx); // pages across
      MaxY:=((Extent.Bottom-Extent.Top) div Size.cy); // pages down
      for X:=0 to MaxX do // pages across
      begin
         XOfs:=0-(Extent.Left+X*Size.cx);
         for Y:=0 to MaxY do // pages down
         begin
            YOfs:=0-(Extent.Top+Y*Size.cy);
            if PrintSelf then
               Control.PaintTo(Printer.Canvas.Handle,XOfs+Control.Left,YOfs+Control.Top);
            if PageNo <> -1 then Inc(PageNo);
            if PrintPageNos then
            begin
               if PageNo > 0 then
                  PN:='Page '+IntToStr(PageNo)
               else
                  PN:='Page '+IntToStr((Y+1)+(X*MaxY))+' of '+IntToStr((MaxX+1)*(MaxY+1));
               Printer.Canvas.Font.Height:=-15;
               Printer.Canvas.TextOut(Size.cx-Printer.Canvas.TextWidth(PN),0,PN);
            end;
            for I:=0 to Control.ControlCount-1 do
            begin
               if Control.Controls[I] is TWinControl then
               begin
                  Comp:=TWinControl(Control.Controls[I]);
                  if Comp.Visible then
                  begin
                     Comp.PaintTo(Printer.Canvas.Handle,XOfs+Comp.Left,YOfs+Comp.Top);
                  end;
               end;
            end;
            if (X <> MaxX) or (Y <> MaxY) then // not last page
               Printer.NewPage;
         end;
      end;
      SetWindowExtEx(Printer.Canvas.Handle,OSize.cx,OSize.cy,@Size); // restore printer settings
      if PageNo < 1 then
         Printer.EndDoc
      else
         Printer.NewPage;
   end;
end;
procedure TForm1.PrintCurrentDiag(PrintPageNos:Boolean;var PageNo:Integer);
var
   SB:TScrollBox;
   I:Integer;
   DiagBackground:TDiagBackground;
   Title:String;
begin
   DiagBackground:=nil;
   SB:=nil;
   if CurrentForm = GroupDes then
   begin
      SB:=GroupDes.ScrollBox1;
      Title:='IDSEdit Group Diagram';
   end
   else if CurrentForm = ProductDes then
   begin
      SB:=ProductDes.ScrollBox1;
      Title:='IDSEdit Product Diagram';
   end
   else if CurrentForm = DomainDes then
   begin
      SB:=DomainDes.ScrollBox1;
      Title:='IDSEdit Domain Diagram';
   end
   else if CurrentForm = SnippetDes then
   begin
      SB:=SnippetDes.ScrollBox1;
      Title:='IDSEdit Snippet Diagram';
   end
   else if CurrentForm = UWGroupDes then
   begin
      SB:=UWGroupDes.ScrollBox1;
      Title:='IDSEdit W/S-User Group Diagram';
   end;
   if SB <> nil then
   begin
      for I:=0 to SB.ComponentCount do
      begin
         if (SB.Controls[I] is TDiagBackground) then
         begin
            DiagBackground:=TDiagBackground(SB.Controls[I]);
            break;
         end;
      end;
   end;
   DiagBackground.Color:=clWhite;
   CurrentlyPrinting:=True;
   PrintControl(Title,DiagBackground,True,PrintPageNos,PageNo);
   CurrentlyPrinting:=False;
   DiagBackground.Color:=clWindow;
end;
procedure TForm1.Print1Click(Sender: TObject);
var
   PageNo:Integer;
begin
   PageNo:=-1;
   PrintCurrentDiag(True,PageNo);
end;
procedure TForm1.PrintCompStruct(CompName:String;var PageNo:Integer);
var
   Comp:TImageNode;
   Sub:TImageNode;
   I:Integer;
begin
   ProjectsForm.Select(CompName);
   PrintCurrentDiag(True,PageNo);
   Comp:=TImageNode(ProjectsForm.Comps.NodeNamed(CompName));
   if Comp is TGroupNode then
   begin
      for I:=0 to Comp.GetItemNodeCount-1 do
      begin
         Sub:=TImageNode(Comp.ItemNode[I]);
         if Sub <> nil then
         begin
            if Sub is TGroupNode then
               PrintCompStruct('Group.'+Sub.Name,PageNo)
            else if Sub is TProductNode then
               PrintCompStruct('Product.'+Sub.Name,PageNo);
         end;
      end;
   end;
end;
procedure TForm1.PrintGroupStruct(CompName:String;var PageNo:Integer);
var
   Comp:TImageNode;
   Sub:TImageNode;
   I:Integer;
begin
   ProjectsForm.Select(CompName);
   PrintCurrentDiag(True,PageNo);
   Comp:=TImageNode(ProjectsForm.Comps.NodeNamed(CompName));
   if Comp is TGroupNode then
   begin
      for I:=0 to Comp.GetItemNodeCount-1 do
      begin
         Sub:=TImageNode(Comp.ItemNode[I]);
         if Sub <> nil then
         begin
            if Sub is TGroupNode then
               PrintGroupStruct('Group.'+Sub.Name,PageNo)
         end;
      end;
   end;
end;

procedure TForm1.Group1Click(Sender: TObject);
var
   R:TRect;
begin
   Group1.Checked:=not Group1.Checked;
   if Group1.Checked then
      GroupDes.PutOn(Panel4)
   else
   begin
      R:=GroupDes.ClientRect;
      GroupDes.PutOn(nil);
      R.TopLeft:=ClientToScreen(R.TopLeft);
      R.BottomRight:=ClientToScreen(R.BottomRight);
      OffsetRect(R,Panel2.Left,0);
      GroupDes.SetBounds(R.Left,R.Top,R.Right-R.Left,R.Bottom-R.Top);
   end;
end;

procedure TForm1.Product1Click(Sender: TObject);
var
   R:TRect;
begin
   Product1.Checked:=not Product1.Checked;
   if Product1.Checked then
      ProductDes.PutOn(Panel4)
   else
   begin
      R:=ProductDes.ClientRect;
      ProductDes.PutOn(nil);
      R.TopLeft:=ClientToScreen(R.TopLeft);
      R.BottomRight:=ClientToScreen(R.BottomRight);
      OffsetRect(R,Panel2.Left,0);
      ProductDes.SetBounds(R.Left,R.Top,R.Right-R.Left,R.Bottom-R.Top);
   end;
end;

procedure TForm1.WUGroup1Click(Sender: TObject);
var
   R:TRect;
begin
   WUGroup1.Checked:=not WUGroup1.Checked;
   if WUGroup1.Checked then
      UWGroupDes.PutOn(Panel4)
   else
   begin
      R:=UWGroupDes.ClientRect;
      UWGroupDes.PutOn(nil);
      R.TopLeft:=ClientToScreen(R.TopLeft);
      R.BottomRight:=ClientToScreen(R.BottomRight);
      OffsetRect(R,Panel2.Left,0);
      UWGroupDes.SetBounds(R.Left,R.Top,R.Right-R.Left,R.Bottom-R.Top);
   end;
end;

procedure TForm1.Selector1Click(Sender: TObject);
var
   R:TRect;
begin
   Selector1.Checked:=not Selector1.Checked;
   if Selector1.Checked then
      ProjectsForm.PutOn(Panel1)
   else
   begin
      R:=ProjectsForm.ClientRect;
      ProjectsForm.PutOn(nil);
      R.Right:=R.Left+ProjectsForm.Width;
      R.TopLeft:=ClientToScreen(R.TopLeft);
      R.BottomRight:=ClientToScreen(R.BottomRight);
      ProjectsForm.SetBounds(R.Left-4,R.Top,(R.Right-R.Left)+7,R.Bottom-R.Top);
   end;
end;

procedure TForm1.Automatic1Click(Sender: TObject);
begin
   if not (Sender is TMenuItem) then Exit;

   (Sender as TMenuItem).Checked:=True;

   if None1.Checked then
      MonitorTimer.Enabled:=False
   else
      MonitorTimer.Enabled:=True;
   ProjectsForm.MenuState:=(Sender as TMenuItem).Caption;
end;

procedure TForm1.MonitorTimerTimer(Sender: TObject);
var
   I,J:Integer;
   Project:TRootNode;
   AttA,AttB:Integer;
   SearchRec:TSearchRec;
   ProjectChanged:Boolean;
   CurrentComp:String;
   SavedComps:TRootNode;
   Update:Boolean;
begin
   MonitorTimer.Enabled:=False;
   try
      for I:=0 to ProjectsForm.ComboBox1.Items.Count-1 do
      begin
         Project:=TRootNode(ProjectsForm.ComboBox1.Items.Objects[I]);
         if (Project <> nil) and (Project.FileList <> nil) then
         begin
            ProjectChanged:=False;
            for J:=0 to Project.FileList.Count-1 do
            begin
               AttB:=0;
               if FindFirst(Project.FileList[J],$FFFF,SearchRec) = 0 then
                  AttB:=SearchRec.Time xor SearchRec.Size;
               AttA:=Integer(Project.FileList.Objects[J]);
               if AttA <> AttB then
               begin
                  ProjectChanged:=True;
                  Project.FileList.Objects[J]:=TObject(AttB);
               end;
            end;
            if ProjectChanged then
            begin
               Update:=True;
               if Prompt1.Checked then
               begin
                  if MessageDlg('Project '+ProjectsForm.ComboBox1.Items[I]+' has changed - re-load?',mtConfirmation,[mbYes,mbNo],0) <> mrYes then
                     Update:=False;
               end;
               if Update then
               begin
                  if I = ProjectsForm.ComboBox1.ItemIndex then
                  begin
                     CurrentComp:=ProjectsForm.CompTypeName+'.'+
                                  ProjectsForm.CompList.Items[ProjectsForm.CompList.itemIndex];
                     SavedComps:=nil;
                  end
                  else
                  begin
                     CurrentComp:='';
                     SavedComps:=ProjectsForm.Comps;
                  end;
                  Project.Free;
                  ProjectsForm.Comps:=nil;
                  ProjectsForm.LoadFile(ProjectsForm.ComboBox1.Items[I]);
                  ProjectsForm.ComboBox1.Items.Objects[I]:=ProjectsForm.Comps;
                  if CurrentComp <> '' then
                  begin
                     ProductDes.SetProductTo(ProductDes.CurrentProd);
                     GroupDes.SetGroupTo(GroupDes.CurrentGroup);
                     UWGroupDes.SetGroupTo(UWGroupDes.CurrentGroup);
                     ProjectsForm.Select(CurrentComp);
                  end
                  else
                  begin
                     ProjectsForm.Comps:=SavedComps;
                  end;
               end;
            end;
         end;
      end;
   except
      ;
   end;
   MonitorTimer.Enabled:=True;
end;

procedure TForm1.LoadRegEntries;
begin
   if ProjectsForm.MenuState = '&Prompt' then
      Prompt1.Checked:=True
   else if ProjectsForm.MenuState = '&Automatic' then
      Automatic1.Checked:=True
   else
      None1.Checked:=True;

   if None1.Checked then
      MonitorTimer.Enabled:=False
   else
      MonitorTimer.Enabled:=True;
end;

procedure TForm1.Errors1Click(Sender: TObject);
var
   R:TRect;
begin
   Errors1.Checked:=not Errors1.Checked;
   if Errors1.Checked then
      ErrorForm.PutOn(Panel3)
   else
   begin
      R:=ErrorForm.ClientRect;
      ErrorForm.PutOn(nil);
      R.TopLeft:=ClientToScreen(R.TopLeft);
      R.BottomRight:=ClientToScreen(R.BottomRight);
      OffsetRect(R,Panel2.Left,Panel3.Top);
      ErrorForm.SetBounds(R.Left,R.Top,R.Right-R.Left,R.Bottom-R.Top);
   end;
end;

procedure TForm1.Domains1Click(Sender: TObject);
var
   R:TRect;
begin
   Domains1.Checked:=not Domains1.Checked;
   if Domains1.Checked then
      DomainDes.PutOn(Panel4)
   else
   begin
      R:=DomainDes.ClientRect;
      DomainDes.PutOn(nil);
      R.TopLeft:=ClientToScreen(R.TopLeft);
      R.BottomRight:=ClientToScreen(R.BottomRight);
      OffsetRect(R,Panel2.Left,0);
      DomainDes.SetBounds(R.Left,R.Top,R.Right-R.Left,R.Bottom-R.Top);
   end;
end;

procedure TForm1.Snippets1Click(Sender: TObject);
var
   R:TRect;
begin
   Snippets1.Checked:=not Snippets1.Checked;
   if Snippets1.Checked then
      SnippetDes.PutOn(Panel4)
   else
   begin
      R:=SnippetDes.ClientRect;
      SnippetDes.PutOn(nil);
      R.TopLeft:=ClientToScreen(R.TopLeft);
      R.BottomRight:=ClientToScreen(R.BottomRight);
      OffsetRect(R,Panel2.Left,0);
      SnippetDes.SetBounds(R.Left,R.Top,R.Right-R.Left,R.Bottom-R.Top);
   end;
end;

procedure TForm1.PrintAll1Click(Sender: TObject);
var
   Comp:String;
   PageNo:Integer;
begin
   Comp:='Group.'+TGroupNode(TUserNode(ProjectsForm.Comps.NodeNamed('User.Clerk')).ItemNode[0]).Name;
   PageNo:=0;
   PrintCompStruct(Comp,PageNo);
   Printer.EndDoc;
end;

procedure TForm1.ReLoad1Click(Sender: TObject);
var
   CurrentComp:String;
begin
   CurrentComp:=ProjectsForm.CompTypeName+'.'+
                ProjectsForm.CompList.Items[ProjectsForm.CompList.itemIndex];
                
   ProjectsForm.Comps.Free;
   ProjectsForm.Comps:=nil;
   ProjectsForm.LoadFile(ProjectsForm.ComboBox1.Items[ProjectsForm.ComboBox1.itemIndex]);
   ProjectsForm.ComboBox1.Items.Objects[ProjectsForm.ComboBox1.itemIndex]:=ProjectsForm.Comps;

   ProductDes.SetProductTo(ProductDes.CurrentProd);
   GroupDes.SetGroupTo(GroupDes.CurrentGroup);
   UWGroupDes.SetGroupTo(UWGroupDes.CurrentGroup);

   ProjectsForm.Select(CurrentComp);
end;

procedure TForm1.CheckIntegrity1Click(Sender: TObject);
begin
   ErrorForm.Errors.Lines.Clear;
   ProjectsForm.IntegrityCheck(ErrorForm.Errors.Lines);
end;

procedure AddGroupHelpToList(Group:TGroupNode;SL:TStrings);
var
  S:String;
  I,J:Integer;
  ProductNode:TProductNode;
  Domains:TPackStringList;
begin

   S:='^Group.'+Group.Name;
   if SL.IndexOf(S) = -1 then
   begin
      SL.Add(S);
      SL.Add(Group.Title+' Help');
      SL.Add('');
      for I:=0 to Group.GetItemNodeCount-1  do
      begin
         if Group.ItemNode[I] <> nil then
            SL.Add('Press F'+IntToStr(I+1)+' for '+TImageNode(Group.ItemNode[I]).Title)
         else
            SL.Add('Press F'+IntToStr(I+1)+' for '+Group.NodeName[I]);
      end;
   end;
   for I:=0 to Group.Count-1 do
   begin
      if (Group.ItemNode[I] is TGroupNode) then
      begin
         AddGroupHelpToList(TGroupNode(Group.ItemNode[I]),SL);
      end
      else if (Group.ItemNode[I] is TProductNode) then
      begin
         ProductNode:=TProductNode(Group.ItemNode[I]);
         S:='^Product.'+ProductNode.Name;
         if SL.IndexOf(S) = -1 then
         begin
            SL.Add(S);
            SL.Add(ProductNode.Title+' Help');
            SL.Add('');
            Domains:=TPackStringList.Create;
            Domains.CommaText:=ProductNode.Domains;
            for J:=0 to Domains.Count-1  do
            begin
               if ProjectsForm.Comps.NodeNamed('Domain.'+Domains[J]) <> nil then
                  SL.Add(TDomainNode(ProjectsForm.Comps.NodeNamed('Domain.'+Domains[J])).Title)
               else
                  SL.Add(Domains[J]);
            end;
            Domains.Free;
            for J:=0 to ProductNode.GetItemNodeCount-1  do
            begin
               if ProductNode.ItemNode[J] <> nil then
                  SL.Add('Press F'+IntToStr(J+1)+' for '+TImageNode(ProductNode.ItemNode[J]).Title)
               else
                  if ProductNode.Items[J] = 'Complete' then
                     SL.Add('Press F'+IntToStr(J+1)+' when '+ProductNode.Items[J])
                  else
                     SL.Add('Press F'+IntToStr(J+1)+' for '+ProductNode.Items[J]);
            end;
         end;
      end;
   end;
end;
procedure TForm1.HelpSkeleton1Click(Sender: TObject);
var
  UN:TUserNode;
  I:Integer;
begin
   ListOutput.List.Lines.Clear;
   for I:=0 to ProjectsForm.Comps.Users.Count-1 do
   begin
      UN:=TUserNode(ProjectsForm.Comps.Users.Objects[I]);
      if UN.GetItemNodeCount > 0 then
         AddGroupHelpToList(TGroupNode(UN.ItemNode[0]),ListOutput.List.Lines);
   end;
   ListOutput.Show;
end;

procedure TForm1.ComponentList2Click(Sender: TObject);
begin
   ListOutput.List.Lines.Clear;
   ListOutput.Show;
end;

procedure AddDomains(ProductNode:TProductNode;SL,DL:TStrings);
var
  J:Integer;
  Domains:TPackStringList;
begin
   if ProjectsForm.Comps.NodeNamed('Product.'+ProductNode.BasedOn) <> nil then
      AddDomains(TProductNode(ProjectsForm.Comps.NodeNamed('Product.'+ProductNode.BasedOn)),SL,DL);
   Domains:=TPackStringList.Create;
   Domains.CommaText:=ProductNode.Domains;
   for J:=0 to Domains.Count-1  do
   begin
      if SL[SL.Count-1] = #9+'DOMAINS - ' then
         SL[SL.Count-1]:=SL[SL.Count-1]+Domains[J]
      else
         SL[SL.Count-1]:=SL[SL.Count-1]+', '+Domains[J];
      if DL.IndexOf(Domains[J]) = -1 then
      begin
         DL.Add(Domains[J]);
      end;
   end;
   Domains.Free;
end;
procedure ListDomains(SL,DL:TStrings);
var
  J:Integer;
  DomainNode:TDomainNode;
begin
   for J:=0 to DL.Count-1  do
   begin
      if ProjectsForm.Comps.NodeNamed('Domain.'+DL[J]) <> nil then
      begin
         DomainNode:=TDomainNode(ProjectsForm.Comps.NodeNamed('Domain.'+DL[J]));
         SL.Add(#9+'Domain - '+DL[J]);
         if DomainNode <> nil then
         begin
            SL.Add(#9#9+'Title:        "'+DomainNode.Title   +'"');
            SL.Add(#9#9+'Prompt:       "'+DomainNode.Prompt  +'"');
            SL.Add(#9#9+'Hint:         "'+DomainNode.Hint    +'"');
            SL.Add(#9#9+'Error:        "'+DomainNode.ErrorStr+'"');
            SL.Add(#9#9+'Format:       "'+DomainNode.Format  +'"');
            SL.Add(#9#9+'DefaultValue: "'+DomainNode.DefaultValue+'"');
            SL.Add(#9#9+'InputFrom:    "'+DomainNode.InputFrom+'"');
            SL.Add(#9#9+'Locale:       "'+DomainNode.Locale+'"');
            SL.Add('');
         end;
      end;
   end;
end;
procedure AddGroupTextToList(Group:TGroupNode;SL,DL:TStrings);
var
  S:String;
  I:Integer;
  ProductNode:TProductNode;
begin
   S:='^Group.'+Group.Name;
   for I:=0 to Group.Count-1 do
   begin
      if (Group.ItemNode[I] is TGroupNode) then
      begin
         AddGroupTextToList(TGroupNode(Group.ItemNode[I]),SL,DL);
      end
      else if (Group.ItemNode[I] is TProductNode) then
      begin
         ProductNode:=TProductNode(Group.ItemNode[I]);
         S:='Product - '+ProductNode.Name;
         if SL.IndexOf(S) = -1 then
        begin
            SL.Add(S);
            SL.Add(#9+'Title:        "'+ProductNode.Title      +'"');
            SL.Add(#9+'Description:  "'+ProductNode.Description+'"');
            SL.Add(#9+'Caption:      "'+ProductNode.Caption    +'"');
            SL.Add('');
         end;
         SL.Add(#9+'DOMAINS - ');
         AddDomains(ProductNode,SL,DL);
         SL.Add('');
      end;
   end;
end;
procedure TForm1.TextList1Click(Sender: TObject);
var
  UN:TUserNode;
  I:Integer;
  DL:TStringList;
begin
   DL:=TStringList.Create;
   ListOutput.List.Lines.Clear;
   ListOutput.List.Lines.Add('--------------------- PRODUCTS ------------------------');
   for I:=0 to ProjectsForm.Comps.Users.Count-1 do
   begin
      UN:=TUserNode(ProjectsForm.Comps.Users.Objects[I]);
      if UN.GetItemNodeCount > 0 then
         AddGroupTextToList(TGroupNode(UN.ItemNode[0]),ListOutput.List.Lines,DL);
   end;
   ListOutput.List.Lines.Add('--------------------- DOMAINS ------------------------');
   DL.Sort;
   ListDomains(ListOutput.List.Lines,DL);
   DL.Free;
   ListOutput.Show;
end;

procedure TForm1.PrintGroups1Click(Sender: TObject);
var
   Comp:String;
   PageNo:Integer;
begin
   Comp:='Group.'+TGroupNode(TUserNode(ProjectsForm.Comps.NodeNamed('User.Clerk')).ItemNode[0]).Name;
   PageNo:=0;
   PrintGroupStruct(Comp,PageNo);
   Comp:='Group.'+TGroupNode(TUserNode(ProjectsForm.Comps.NodeNamed('User.Supervisor')).ItemNode[0]).Name;
   PageNo:=0;
   PrintGroupStruct(Comp,PageNo);
   Printer.EndDoc;
end;
procedure GetFileNames(InputNode:TCorvusNode;var GPFileName,GAFileName,GFFileName,GCFileName:String);
var
   Node:TCorvusNode;
   Path:String;
begin
   Node:=InputNode.NodeNamed('Directory');
   Path:=Node[0];
   Node:=InputNode.NodeNamed('Files');
   if Node.NodeNamed('Project'   ) <> nil then GPFileName:=Path+'\'+Node.NodeNamed('Project'   )[0];
   if Node.NodeNamed('Constants' ) <> nil then GCFileName:=Path+'\'+Node.NodeNamed('Constants' )[0];
   if Node.NodeNamed('Automation') <> nil then GAFileName:=Path+'\'+Node.NodeNamed('Automation')[0];
   if Node.NodeNamed('Form'      ) <> nil then GFFileName:=Path+'\'+Node.NodeNamed('Form'      )[0];
end; 
procedure ModGroupSource(FileName:String);
var
  I:Integer;
  GlyphDefs:TPackStringList;
  ItemDefs :TPackStringList;
  InitDefs :TPackStringList;
begin
(*   if PGUID = '' then PGUID:=GenerateGUID;
   ReplaceTokenAfter('{PClass}'  ,PClass);
   ReplaceTokenAfter('{PName}'   ,PName);
   ReplaceTokenAfter('{UName}'   ,UName);
   ReplaceTokenAfter('{UFile}'   ,#39+UFile   +#39);
   ReplaceTokenAfter('{PGUID}'   ,#39+PGUID   +#39);
   ReplaceTokenAfter('{PProgID}' ,#39+PProgID +#39);
   ReplaceTokenAfter('{PRegDesc}',#39+PRegDesc+#39);
   if UpperCase(ExtractFileExt(FileName)) <> '.DPR' then
   begin
      GlyphDefs:=TPackStringList.Create;
      ItemDefs :=TPackStringList.Create;
      InitDefs :=TPackStringList.Create;
      ItemDefs.Add('');
      InitDefs.Add('');
      for I:=0 to Items.Count-1 do
      begin
         ItemDefs .Add(ItemLine(Items[I],I));
         GlyphDefs.Add(GlyphLines(BitMaps[I],I));
         InitDefs.Add('     FGroupInfo.AddObject(''Group.'+Names[I]+''',TGroupDetails.Create('''+Captions[I]+''','''+Titles[I]+''',Items'+IntToStr(I)+',Glyph'+IntToStr(I)+'));');
      end;       
      ReplaceTextBetweenTokens('{ItemDataStart}','{ItemDataEnd}',ItemDefs.Text);
      ReplaceTextBetweenTokens('{GlyphDataStart}','{GlyphDataEnd}',GlyphDefs.Text);
      ReplaceTextBetweenTokens('{SetupGroupsStart}','{SetupGroupsEnd}',InitDefs.Text);
      GlyphDefs.Free;
      ItemDefs .Free;
      InitDefs .Free;      
   end;
   inherited SaveToFile(FileName);*)
end;

procedure TForm1.Groups1Click(Sender: TObject);
var
   CompList:TStringList;
   I:Integer;
   TokenList:TTokenList;
   GF,GP:String;
   GPFileName:String;
   GAFileName:String;
   GFFileName:String;
   GCFileName:String;
   CList:TStringList;
begin                    
   TokenList:=TTokenList.Create('');
   CompList:=TStringList.Create;
   
   for I:=0 to ProjectsForm.Comps.Groups.Count-1 do
       CompList.Add('"Group","'+ProjectsForm.Comps.Groups[I]+'"');
       
   GetFileNames(ProjectsForm.Comps.BuildOptions.NodeNamed('GroupInput'),GPFileName,GAFileName,GFFileName,GCFileName);
   CList:=TStringList.Create;
   CList.LoadFromFile(GPFileName);
   GP:=CList.Text;
   CList.LoadFromFile(GFFileName);
   GF:=CList.Text;
   CList.Free;

   TokenList.LoadFromString(GP);
   TokenList.ReplaceTokenAfter('','');
//   Builder.GenNewSource(CompList.Text,IDSDiag.Parser.Nodes);
//   Builder.BuildComponent(CompList.Text,IDSDiag.Parser.Nodes,UnRegReRegOnBuild1.Checked or UnRegReRegOnBuildRegServer1.Checked,DebugInfoinBinaries1.Checked);
   TokenList.Free;                 
   CompList.Free;                 
end;

end.
