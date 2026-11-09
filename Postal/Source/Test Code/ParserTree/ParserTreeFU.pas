unit ParserTreeFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ComCtrls, StdCtrls, ExtCtrls,ParseNodeU,PackStrListU,
  CompInspector,GPCSGUID;
const
   TEXPType:Array[0..67,0..3] of String = (
      ('IDS','Users'       ,'Items'        ,'List'    ),
      
      ('IDS','WorkStations','Items'        ,'List'    ),
      
      ('IDS','Groups'      ,'BitMap'       ,'Image'   ),
      ('IDS','Groups'      ,'Title'        ,'Text'    ),
      ('IDS','Groups'      ,'Caption'      ,'Text'    ),
      ('IDS','Groups'      ,'Description'  ,'Text'    ),
      ('IDS','Groups'      ,'DontBuild'    ,'Boolean' ),
      ('IDS','Groups'      ,'Items'        ,'List'    ),
      
      ('IDS','Products'    ,'BitMap'       ,'Image'   ),
      ('IDS','Products'    ,'Title'        ,'Text'    ),
      ('IDS','Products'    ,'Caption'      ,'Text'    ),
      ('IDS','Products'    ,'Description'  ,'Text'    ),
      ('IDS','Products'    ,'Items'        ,'List'    ),
      ('IDS','Products'    ,'Customer'     ,'List'    ),
      ('IDS','Products'    ,'Domains'      ,'List'    ),
      ('IDS','Products'    ,'DontBuild'    ,'Boolean' ),
      ('IDS','Products'    ,'Endorse'      ,'List'    ),
      ('IDS','Products'    ,'Hint'         ,'Text'    ),
      ('IDS','Products'    ,'LogAs'        ,'Text'    ),
      ('IDS','Products'    ,'OCRCode'      ,'Text'    ),
      ('IDS','Products'    ,'PLU'          ,'Text'    ),
      ('IDS','Products'    ,'Price'        ,'Currency'),
      ('IDS','Products'    ,'PrintList'    ,'List'    ),
      ('IDS','Products'    ,'Prompt'       ,'Text'    ),
      ('IDS','Products'    ,'Snippets'     ,'List'    ),
      ('IDS','Products'    ,'SubGroup'     ,'Text'    ),
      ('IDS','Products'    ,'UnitPrice'    ,'Currency'),
      
      ('IDS','LookUps'     ,'Range'        ,'List'    ),
      ('IDS','LookUps'     ,'DontBuild'    ,'Boolean' ),
      ('IDS','LookUps'     ,'SubGroup'     ,'Text'    ),
      ('IDS','LookUps'     ,'All'          ,'List'    ),
      
      ('IDS','PickLists'   ,'DontBuild'    ,'Boolean' ),
      ('IDS','PickLists'   ,'Sorted'       ,'Boolean' ),
      ('IDS','PickLists'   ,'Default'      ,'Text'    ),
      ('IDS','PickLists'   ,'SubGroup'     ,'Text'    ),
      ('IDS','PickLists'   ,'All'          ,'List'    ),
                                           
      ('IDS','Snippets'    ,'SubGroup'     ,'Text'    ),
      ('IDS','Snippets'    ,'CodeBlock'    ,'List'    ),
      ('IDS','Snippets'    ,'InsertBetween','List'    ),
      
      ('IDS','Domains'     ,'TotalIn'      ,'Text'    ),
      ('IDS','Domains'     ,'DefaultValue' ,'Text'    ),
      ('IDS','Domains'     ,'Error'        ,'Text'    ),
      ('IDS','Domains'     ,'Format'       ,'List'    ),
      ('IDS','Domains'     ,'Hint'         ,'Text'    ),
      ('IDS','Domains'     ,'InputFrom'    ,'List'    ),
      ('IDS','Domains'     ,'Prompt'       ,'Text'    ),
      ('IDS','Domains'     ,'Title'        ,'Text'    ),
      ('IDS','Domains'     ,'SubGroup'     ,'Text'    ),
      
      ('ORI','Offices'     ,'All'          ,'List'    ),
      ('ORI','Routes'      ,'All'          ,'List'    ),
      
      ('UDD','Menus'       ,'Items'        ,'List'    ),
      ('UDD','Menus'       ,'Title'        ,'Text'    ),
      ('UDD','Menus'       ,'Prompt'       ,'Text'    ),
      ('UDD','Menus'       ,'Hint'         ,'Text'    ),
      ('UDD','Menus'       ,'Form'         ,'Text'    ),
      
      ('UDD','Forms'       ,'Title'        ,'Text'    ),
      ('UDD','Forms'       ,'Domains'      ,'List'    ),
      
      ('UDD','Functions'   ,'Title'        ,'Text'    ),
      
      ('UDD','Domains'     ,'Title'        ,'Text'    ),
      ('UDD','Domains'     ,'Prompt'       ,'Text'    ),
      ('UDD','Domains'     ,'Hint'         ,'Text'    ),
      ('UDD','Domains'     ,'ReadOnly'     ,'Boolean' ),
      ('UDD','Domains'     ,'Default'      ,'Text'    ),
      ('UDD','Domains'     ,'Error'        ,'Text'    ),
      ('UDD','Domains'     ,'Type'         ,'Text'    ),
      ('UDD','Domains'     ,'CheckWith'    ,'Text'    ),
      
      ('UDD','System'      ,'Bitmap'       ,'Image'   ),
      ('UDD','System'      ,'LUButton'     ,'Image'   ) 
   );                                                
   
type
  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Panel3: TPanel;
    Splitter2: TSplitter;
    TreeView: TTreeView;
    Panel5: TPanel;
    Memo1: TMemo;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    TreePop: TPopupMenu;
    ItemPop: TPopupMenu;
    Nill1: TMenuItem;
    Nill2: TMenuItem;
    Panel6: TPanel;
    ImageList1: TImageList;
    ComboBox1: TComboBox;
    Button1: TButton;
    OD: TOpenDialog;
    Panel1: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    ODiag: TTabSheet;
    Panel4: TPanel;
    Panel7: TPanel;
    CompInspector1: TCompInspector;
    ScrollBox1: TScrollBox;
    PaintBox1: TPaintBox;
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TreeViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure FormDestroy(Sender: TObject);
    procedure Splitter2Moved(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ComboBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ComboBox1Change(Sender: TObject);
  public
     ParseNode:TParseNode;
     function ShouldExpandNode(Node:TCorvusNode;var NodeType:String):Boolean;
     procedure GetNodeTree(Node:TCorvusNode;Tree:TTreeNodes;TreeNode:TTreeNode;Depth:String);
     procedure LoadRegSettings;
     procedure SaveRegSettings;
     procedure LoadParamFiles;
     procedure PopulateDiag(CorvusNode:TCorvusNode);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Exit1Click(Sender: TObject);
begin
   Close;
end;

procedure TForm1.About1Click(Sender: TObject);
begin
   ShowMessage('Version 0.1');
end;
function TopLevel(FileType,CompType:String):Boolean;
var
   I:Integer;
begin
   Result:=False;
   if Copy(FileType,1,1) = '.' then
     FileType:=Copy(FileType,2,Length(FileType));
   FileType:=UpperCase(FileType);
   for I:=Low(TEXPType) to High(TEXPType) do
   begin 
      if (FileType = TEXPType[I,0]) and (CompType = TEXPType[I,1]) then
      begin
         Result:=True;
         break;
      end;
   end;
end;
function GetEXPType(FileType,CompType,AttribName:String):String;
var
   I:Integer;
begin
   Result:='';
   if Copy(FileType,1,1) = '.' then
     FileType:=Copy(FileType,2,Length(FileType));
   FileType:=UpperCase(FileType);
   for I:=Low(TEXPType) to High(TEXPType) do
   begin 
      if  (FileType   = TEXPType[I,0])
      and (CompType   = TEXPType[I,1])
      and ((AttribName = TEXPType[I,2]) or (TEXPType[I,2] = 'All')) then
      begin
         Result:=TEXPType[I,3];
         break;
      end;
   end;
end;
function TForm1.ShouldExpandNode(Node:TCorvusNode;var NodeType:String):Boolean;
begin
   NodeType:='List';
   Result:=False;
   if (Node <> nil) and (Node.ParentNode <> nil) then
   begin
      if (Node.ParentNode.Name = 'RootNode') 
      or (Node.Name = 'RootNode') then
      begin
         Result:=True;
      end
      else
      begin
         if (Node.ParentNode.ParentNode.Name = 'RootNode') then
         begin
            if (Node.ParentNode.Name = 'System') then 
               Result:=False
            else if TopLevel(ExtractFileExt(OD.FileName),Node.ParentNode.Name) then
               Result:=True
            else if (Node.ParentNode.Name = 'BuildOptions') and (Node.Count > 1) then 
               Result:=True
            else if (Node.ParentNode.Name <> 'Constants') then 
            begin
               NodeType:=GetEXPType(ExtractFileExt(OD.FileName),Node.ParentNode.Name,Node.Name);
               if NodeType = 'List' then
                  Result:=True;
            end;
         end
         else
         begin
            NodeType:=GetEXPType(ExtractFileExt(OD.FileName),Node.ParentNode.ParentNode.Name,Node.Name);
            if NodeType = 'List' then
               Result:=True;
         end;                              
      end;
   end;
end;
procedure TForm1.GetNodeTree(Node:TCorvusNode;Tree:TTreeNodes;TreeNode:TTreeNode;Depth:String);
var
  I:Integer;
  Child:TTreeNode;
  NodeType:String;
begin
   if (Node = nil) or (Node.Name = #39#39) then Exit;
   if (Node is TParseNode) then
   begin
      Child:=Tree.AddChildObject(TreeNode,ExtractFileName(Node.FileName),Node);
      Child.ImageIndex:=0;
      Child.SelectedIndex:=0;
   end                    
   else
   begin
      Child:=Tree.AddChildObject(TreeNode,Node.Name,Node);
      if TreeNode.Parent = nil then
      begin
              if Child.Text = 'Groups'       then Child.ImageIndex:=1
         else if Child.Text = 'Products'     then Child.ImageIndex:=4
         else if Child.Text = 'Users'        then Child.ImageIndex:=7
         else if Child.Text = 'WorkStations' then Child.ImageIndex:=10
         else if Child.Text = 'Domains'      then Child.ImageIndex:=13
         else if Child.Text = 'PickLists'    then Child.ImageIndex:=16
         else if Child.Text = 'LookUps'      then Child.ImageIndex:=19
         else if Child.Text = 'Snippets'     then Child.ImageIndex:=22
         else if Child.Text = 'LogFormats'   then Child.ImageIndex:=25
         else if Child.Text = 'BuildOptions' then Child.ImageIndex:=31
         else Child.ImageIndex:=1;
         
         Child.SelectedIndex:=Child.ImageIndex;                      
         if Child.Text = 'Constants' then 
         begin 
            Child.ImageIndex:=29; 
            Child.SelectedIndex:=30 
         end;
      end
      else if TreeNode.Parent.Parent = nil then
      begin
         Child.ImageIndex   :=TreeNode.ImageIndex+1;
         Child.SelectedIndex:=TreeNode.ImageIndex+2;
      end
      else
      begin
         Child.ImageIndex:=34;
         Child.SelectedIndex:=34;
      end;
      
   end;
   Depth:=Depth+' ';
   Node.Sort;
   for I:=0 to Node.Count-1 do
   begin
      if ShouldExpandNode(Node.Node[I],NodeType) then
         GetNodeTree(Node.Node[I],Tree,Child,Depth);
   end;
   if (Node is TParseNode) then
      Child.Expand(False);
end;
procedure TForm1.LoadRegSettings;
var
   S:String;
begin
   ComboBox1.Items.CommaText:=GetGPCSRegNames('Designer\Files','');
   S:=GetGPCSRegString('Designer','Last File','');
//   MenuState:=GetGPCSRegString('Designer','Menus','Automatic');
   ComboBox1.ItemIndex:=ComboBox1.Items.IndexOf(S);
   if ComboBox1.ItemIndex <> -1 then
      ComboBox1.Text:=S;
end;
procedure TForm1.SaveRegSettings;
begin
   SetGPCSRegNames('Designer\Files',ComboBox1.Items.CommaText);
   SetGPCSRegString('Designer','Last File',ComboBox1.Text);
//   SetGPCSRegString('Designer','Menus',MenuState);
end;
procedure TForm1.LoadParamFiles;
var
   I:Integer;
begin
   for I:=1 to ParamCount do
   begin
     OD.FileName:=ParamStr(I);
     if ComboBox1.Items.IndexOf(OD.FileName) = -1 then
        ComboBox1.Items.Add(OD.FileName);
     ComboBox1.ItemIndex:=ComboBox1.Items.IndexOf(OD.FileName);
     ComboBox1.Text:=OD.FileName;
     ComboBox1Change(ComboBox1);
   end;
end;
procedure TForm1.FormCreate(Sender: TObject);
begin
   LoadRegSettings;
   LoadParamFiles;
   if ComboBox1.Text <> '' then
      ComboBox1Change(ComboBox1);
end;
procedure TForm1.FormDestroy(Sender: TObject);
begin
   SaveRegSettings;
   while ComboBox1.Items.Count > 0 do
   begin
      if ComboBox1.Items.Objects[0] <> nil then
         TParseNode(ComboBox1.Items.Objects[0]).Free;
      ComboBox1.Items.Delete(0);
   end;                                              
end;

procedure TForm1.TreeViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Node:TTreeNode;
  
begin
  if Button = mbRight then
  begin
     TreeViewChange(nil,TreeView.GetNodeAt(X,Y));
  end
  else if (Button = mbLeft) and (ssShift in Shift) then
  begin
     Node:=TreeView.GetNodeAt(X,Y);
     if Node <> nil then
     begin
        TreeView.Items.BeginUpdate;
        if Node.Expanded then
           Node.Expand(True)
        else
           Node.Collapse(True);
        TreeView.Items.EndUpdate;
     end;
  end;                         
end;          

procedure TForm1.TreeViewChange(Sender: TObject; Node: TTreeNode);
var
   CorvusNode:TCorvusNode;
   NodeType:String;
   I:Integer; 
begin
   if Node = nil then Exit;
   Node.Selected:=True;
   CorvusNode:=TCorvusNode(Node.Data);
   PopulateDiag(CorvusNode);
   if CorvusNode <> nil then
   begin
      CompInspector1.Clear;
      for I:=0 to CorvusNode.Count-1 do
      begin
         if not ShouldExpandNode(CorvusNode.Node[I],NodeType) then
         begin
            if NodeType = 'List' then
            begin
               if (CorvusNode.Node[I] <> nil) and (CorvusNode.Node[I].Count > 0) then
               begin
                  CompInspector1.Add(CorvusNode[I],itString,Trim(CorvusNode.Node[I].Text))
               end
               else
                  CompInspector1.Add(CorvusNode[I],itBoolean,'');
            end
            else
            begin
               if (CorvusNode.Node[I] <> nil) and (CorvusNode.Node[I].Count > 0) then
               begin
                  if GetEXPType(ExtractFileExt(OD.FileName),CorvusNode.Name,CorvusNode.Node[I].Name) = 'Text' then
                     CompInspector1.Add(CorvusNode[I],itString,Trim(CorvusNode.Node[I].Text))
                  else if GetEXPType(ExtractFileExt(OD.FileName),CorvusNode.Name,CorvusNode.Node[I].Name) = 'Image' then
                     CompInspector1.Add(CorvusNode[I],itBitmap,Trim(CorvusNode.Node[I].Text))
                  else
                     CompInspector1.Add(CorvusNode[I],itString,Trim(CorvusNode.Node[I].Text));
               end
               else
                  CompInspector1.Add(CorvusNode[I],itBoolean,'True');
            end; 
         end;
      end;  
   end;
end;


procedure TForm1.Splitter2Moved(Sender: TObject);
begin
   Button1.Left:=Splitter2.Left-Button1.Width;
   ComboBox1.Width:=Splitter2.Left-Button1.Width;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
   if OD.Execute then
   begin
      ParseNode:=TParseNode.Create('RootNode',OD.FileName,1);
      ParseNode.ParseFile(ExtractFilePath(OD.FileName),ExtractFileName(OD.FileName),1);
      ComboBox1.Items.AddObject(OD.FileName,ParseNode);
      ComboBox1.Text:=OD.FileName;
      ComboBox1.ItemIndex:=ComboBox1.Items.IndexOf(OD.FileName);
      TreeView.Items.Clear;
      GetNodeTree(ParseNode,TreeView.Items,nil,'');
   end;
end;

procedure TForm1.ComboBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
   FN:String;
begin
   with ComboBox1.Canvas do
   begin
      FillRect(Rect);
      FN:=ExtractFileName(ComboBox1.Items[Index]);          // remove path
//      FN:=Copy(FN,1,Length(FN)-Length(ExtractFileExt(FN))); // remove extension
      TextOut(Rect.Left+2,Rect.Top,FN);
   end;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
   OD.FileName:=ComboBox1.Text;
   if ComboBox1.Items.Objects[ComboBox1.ItemIndex] <> nil then
   begin
      ParseNode:=TParseNode(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
   end
   else
   begin
      ParseNode:=TParseNode.Create('RootNode',OD.FileName,1);
      ComboBox1.Items.Objects[ComboBox1.ItemIndex]:=ParseNode;
      ParseNode.ParseFile(ExtractFilePath(OD.FileName),ExtractFileName(OD.FileName),1);
   end;
   TreeView.Items.Clear;
   GetNodeTree(ParseNode,TreeView.Items,nil,'');
end;
procedure TForm1.PopulateDiag(CorvusNode:TCorvusNode);
begin
end;
end.
