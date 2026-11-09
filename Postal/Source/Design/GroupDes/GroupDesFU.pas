unit GroupDesFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus,ParseNode,StdCtrls, ExtCtrls, CompInspector;

type
  TForm1 = class(TForm)
    OD: TOpenDialog;
    SD: TSaveDialog;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    Print1: TMenuItem;
    Exit1: TMenuItem;
    Panel1: TPanel;
    GroupList: TListBox;
    Panel2: TPanel;
    Label1: TLabel;
    Panel3: TPanel;
    ProductList: TListBox;
    Panel4: TPanel;
    Label2: TLabel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Panel5: TPanel;
    Panel6: TPanel;
    Label3: TLabel;
    GName: TCheckBox;
    GTitle: TCheckBox;
    PTitle: TCheckBox;
    PName: TCheckBox;
    Panel7: TPanel;
    Panel8: TPanel;
    SystemList: TListBox;
    Panel9: TPanel;
    Label4: TLabel;
    ScrollBox1: TScrollBox;
    CompInspector: TCompInspector;
    PopupMenu1: TPopupMenu;
    DeleteGroup1: TMenuItem;
    DeleteGroup2: TMenuItem;
    procedure Open1Click(Sender: TObject);
    procedure GNameClick(Sender: TObject);
    procedure GroupListClick(Sender: TObject);
    procedure Panel5Resize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure CompInspectorDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ScrollBox1Exit(Sender: TObject);
    procedure CompInspectorDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure DeleteGroup2Click(Sender: TObject);
    procedure DeleteGroup1Click(Sender: TObject);
  private
    { Private declarations }
   GroupNode:TGroupNode;
  public
    Parser:TParser;
    procedure FillLists;
    procedure LoadFile(FileName:String);
    procedure DataFieldChange(Name,Value:String);
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
procedure TForm1.FillLists;
var
   I:Integer;
   S:String;
begin
   if Parser = nil then Exit;
   GroupList.Clear;
   GroupList.Sorted:=False;
   for I:=0 to Parser.Nodes.Groups.Count-1 do
   begin
      if GName.Checked then
      begin
         S:=Parser.Nodes.Groups[I].NodeName;
         if GTitle.Checked then
            S:=S+' - '+Parser.Nodes.Groups[I].Title;
      end
      else
      begin
         if GTitle.Checked then
            S:=Parser.Nodes.Groups[I].Title
         else
            S:=Parser.Nodes.Groups[I].NodeName;
      end;
      GroupList.Items.AddObject(S,Parser.Nodes.Groups[I]);
   end;
   GroupList.Sorted:=True;
   ProductList.Sorted:=False;
   ProductList.Clear;
   for I:=0 to Parser.Nodes.Products.Count-1 do
   begin
      if not Parser.Nodes.Products[I].DontBuild then
      begin
         if PName.Checked then
         begin
            S:=Parser.Nodes.Products[I].NodeName;
            if PTitle.Checked then
               S:=S+' - '+Parser.Nodes.Products[I].Title;
         end
         else
         begin
            if PTitle.Checked then
               S:=Parser.Nodes.Products[I].Title
            else
               S:=Parser.Nodes.Products[I].NodeName;
         end;
         ProductList.Items.AddObject(S,Parser.Nodes.Products[I]);
      end;
   end;
   ProductList.Sorted:=True;
end;
procedure TForm1.LoadFile(FileName:String);
begin
   if Parser <> nil then Parser.Free;
   GroupNode:=nil;
   Parser:=TParser.Create(FileName);
   FillLists;
end;
procedure TForm1.Open1Click(Sender: TObject);
begin
   if OD.Execute then
   begin
      Cursor:=crHourGlass;
      LoadFile(OD.FileName);
      SD.FileName:=OD.FileName;
      Cursor:=crDefault;
   end;
end;

procedure TForm1.GNameClick(Sender: TObject);
begin
   FillLists;
end;

procedure TForm1.GroupListClick(Sender: TObject);
var
   I:Integer;
begin
   if GroupList.ItemIndex >=0 then
   begin
      GroupNode:=TGroupNode(GroupList.Items.Objects[GroupList.ItemIndex]);
      if GroupNode <> nil then
      begin
         CompInspector.Clear;
         CompInspector.Add      ('Name'        ,itString,GroupNode.NodeName );
         CompInspector.Add      ('Title'       ,itString,GroupNode.Title    );
         CompInspector.Add      ('Prompt'      ,itString,GroupNode.Prompt   );
         CompInspector.Add      ('Hint'        ,itString,GroupNode.Hint     );
         CompInspector.AddBitMap('Image'       ,GroupNode.BitMap,GroupNode.Image);
         CompInspector.Add      ('GUID'        ,itString,GroupNode.GUID        );
         CompInspector.Add      ('RegDesc'     ,itString,GroupNode.RegDesc     );
         CompInspector.Add      ('ProgID'      ,itString,GroupNode.ProgID      );
         CompInspector.Add      ('Version'     ,itString,GroupNode.Version     );
         CompInspector.Add      ('ProjectFiles',itString,GroupNode.ProjectFiles);
         CompInspector.Add      ('SubGroup'    ,itString,GroupNode.SubGroup    );
         if GroupNode.DontBuild then
            CompInspector.Add      ('Build',itComboBox,'False,True,False')
         else
            CompInspector.Add      ('Build',itComboBox,'True,True,False');
         for I:=0 to 9 do
         begin
            if I < GroupNode.Count then
               CompInspector.Add      ('item '+IntToStr(I),itString,GroupNode.Item[I])
            else
               CompInspector.Add      ('item '+IntToStr(I),itString,'');
         end;
      end;
   end;
end;

procedure TForm1.Panel5Resize(Sender: TObject);
begin
   CompInspector.Width:=Panel5.Width-6;
end;
function RemSpace(S:String):String;
var
   I:Integer;
begin
   Result:='';
   for I:=1 to Length(S) do
   begin
      if (S[I] in ['0'..'9','A'..'Z','a'..'z','_']) then
         Result:=Result+S[I];
   end;
end;
procedure TForm1.DataFieldChange(Name,Value:String);
begin
   if GroupNode <> nil then
   begin
      if Name = 'Name'         then begin
                                       Value:=RemSpace(Value);
                                       GroupNode.NodeName    :=Value;
                                       GroupNode.ProgID      :='Group.'+Value;
                                       GroupNode.RegDesc     :='CORVUS '+Value+' Group Component';
                                       FillLists;
                                    end;
      if Name = 'Title'        then begin GroupNode.Title       :=Value; FillLists; end;
      if Name = 'Prompt'       then GroupNode.Prompt      :=Value;
      if Name = 'Hint'         then GroupNode.Hint        :=Value;
      if Name = 'Image'        then GroupNode.BitMap      :=Value;
      if Name = 'GUID'         then GroupNode.GUID        :=Value;
      if Name = 'RegDesc'      then GroupNode.RegDesc     :=Value;
      if Name = 'ProgID'       then GroupNode.ProgID      :=Value;
      if Name = 'Version'      then GroupNode.Version     :=Value;
      if Name = 'ProjectFiles' then GroupNode.ProjectFiles:=Value;
      if Name = 'SubGroup'     then GroupNode.SubGroup    :=Value;
      if Name = 'Build'        then GroupNode.DontBuild   :=Value = 'False';
      if Name = 'item 0'        then GroupNode.Item[0]:=Value;
      if Name = 'item 1'        then GroupNode.Item[1]:=Value;
      if Name = 'item 2'        then GroupNode.Item[2]:=Value;
      if Name = 'item 3'        then GroupNode.Item[3]:=Value;
      if Name = 'item 4'        then GroupNode.Item[4]:=Value;
      if Name = 'item 5'        then GroupNode.Item[5]:=Value;
      if Name = 'item 6'        then GroupNode.Item[6]:=Value;
      if Name = 'item 7'        then GroupNode.Item[7]:=Value;
      if Name = 'item 8'        then GroupNode.Item[8]:=Value;
      if Name = 'item 9'        then GroupNode.Item[9]:=Value;
   end;
end;
procedure TForm1.FormCreate(Sender: TObject);
begin
   CompInspector.OnDataFieldChange:=DataFieldChange;
end;

procedure TForm1.Save1Click(Sender: TObject);
var
  SL:TStringList;
begin
   if SD.Execute then
   begin
      Cursor:=crHourGlass;
      SL:=TStringList.Create;
      SL.Text:=Parser.Nodes.Groups.AsString;
      SL.Insert(0,'Groups {');
      SL.Add('}');
      SL.SaveToFile(SD.FileName);
      SL.Free;
      Cursor:=crDefault;
   end;

end;

procedure TForm1.CompInspectorDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if Source is TListBox then
    Accept:=True
  else
    Accept:=False;
end;

procedure TForm1.ScrollBox1Exit(Sender: TObject);
begin
   CompInspector.HideInPlace;
end;

procedure TForm1.CompInspectorDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  S:String;
  ItemIndex:Integer;
begin
  if Source is TListBox then
  begin
     ItemIndex:=(Source as TListBox).ItemIndex;
     if (Source as TListBox).Items.Objects[ItemIndex] <> nil then
        S:=TExecNode((Source as TListBox).Items.Objects[ItemIndex]).ProgID
     else
        S:=(Source as TListBox).Items[ItemIndex];
     ItemIndex:=CompInspector.MouseToItem(Y);
     CompInspector.Items[ItemIndex].Data:=S;
     DataFieldChange(CompInspector.Items[ItemIndex].Prompt,S);
     GroupListClick(GroupList);
  end;
end;

procedure TForm1.DeleteGroup2Click(Sender: TObject);
begin
   if (GroupList.ItemIndex >= 0) and (GroupNode <> nil) then
   begin
     Parser.Nodes.Groups.Delete(GroupNode.NodeName);
     GroupList.Items.Delete(GroupList.ItemIndex);
     CompInspector.Clear;
     GroupNode:=nil;
   end;
end;

procedure TForm1.DeleteGroup1Click(Sender: TObject);
var
   Idx:Integer;
   Group:TGroupNode;
begin
   Idx:=Parser.Nodes.Groups.Add('NewGroupNode');
   Group:=Parser.Nodes.Groups.Node[Idx];
   Group.SetDataElements(Parser.Nodes);
   Group.Prompt:='Select a menu item:';
   Group.Hint:='Select a menu item by pressing the Function Key^or by using the UP/DOWN arrows and [Enter]';
   GroupList.ItemIndex:=GroupList.Items.AddObject('NewGroupNode - ',Group);
   GroupListClick(GroupList);
end;

end.
