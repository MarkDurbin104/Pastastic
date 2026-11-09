unit GPCSParseFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,ParseNode,PackStrListU;

type
  TProject = class;
  TCompType = (ctNone,ctProduct,ctGroup,ctUser,ctWorkstation,ctPickList,ctLookUp);
  TStrWrap = class(TObject)
  private
     FValue:String;
  public
    constructor Create(Value:String);
    property Value:String read FValue write FValue;
  end;
  TCompNode = class(TObject)
  private
    FTraversed:Boolean;
    FType:TCompType;
    FName:String;
    FTitle:String;
    FItems:TPackStringList;
    function GetItem(Index:Integer):TCompNode;
    procedure SetItem(Index:Integer;Value:TCompNode);
    function GetName(Index:Integer):String;
    function GetCount:Integer;
    function IndexOf(Value:String):Integer;
    procedure SetTraversed(Value:Boolean);
  public
    constructor Create(Node:TNode;Project:TProject); virtual;
    destructor Destroy; override;
    property Item[Index:Integer]:TCompNode read GetItem write SetItem; default;
    property ItemName[Index:Integer]:String read GetName;
    property Name :String read FName  write FName ;  
    property Title:String read FTitle write FTitle;
    property Count:Integer read GetCount;
    property CompType:TCompType read FType write FType;
    property Traversed:Boolean read FTraversed write SetTraversed;
  end;
  TExecNode = class(TCompNode)
  private
    FBitMapFile:String;
  public
    constructor Create(Node:TNode;Project:TProject); override;
    property BitMapFile:String read FBitMapFile write FBitMapFile;
  end;
  TProdNode = class(TExecNode)
  private
    FAttribs:TPackStringList;
    FDomains:TPackStringList;
    FLogAs:String;
  public
    constructor Create(Node:TNode;Project:TProject); override;
    destructor Destroy; override;
    procedure BaseOn(Node:TProdNode);
    property Attribs:TPackStringList read FAttribs write FAttribs;
    property Domains:TPackStringList read FDomains write FDomains;
    property LogAs:String read FLogAs write FLogAs;
  end;    
  TGroupNode = class(TExecNode)
  public
    constructor Create(Node:TNode;Project:TProject); override;
  end;
  TUserNode = class(TCompNode)
  public
    constructor Create(Node:TNode;Project:TProject); override;
  end;
  TWorksNode = class(TUserNode)
  public
    constructor Create(Node:TNode;Project:TProject); override;
  end;
  TProject = class(TObject)
  private
    FTitle:String;
    FGroup:TPackStringList;
    FProd :TPackStringList;
    FUser :TPackStringList;
    FWorks:TPackStringList;
    FLogFormats:TPackStringList;
    function GetGroup(Index:Integer):TGroupNode;
    function GetProd (Index:Integer):TProdNode ;
    function GetUser (Index:Integer):TUserNode ;
    function GetWorks(Index:Integer):TWorksNode;
    function GetGroupCount:Integer;
    function GetProdCount :Integer;
    function GetUserCount :Integer;
    function GetWorksCount:Integer;
    function IndexOfGroup(Value:String):Integer;
    function IndexOfProd (Value:String):Integer;
    function IndexOfUser (Value:String):Integer;
    function IndexOfWorks(Value:String):Integer;
    function GetGroupName(Index:Integer):String;
    function GetProdName (Index:Integer):String;
    function GetUserName (Index:Integer):String;
    function GetWorksName(Index:Integer):String;
  public
    constructor Create(FileName:String); virtual;
    destructor Destroy; override;
    property Group[Index:Integer]:TGroupNode read GetGroup;
    property Prod [Index:Integer]:TProdNode  read GetProd ;
    property User [Index:Integer]:TUserNode  read GetUser ;
    property Works[Index:Integer]:TWorksNode read GetWorks;
    property GroupName[Index:Integer]:String read GetGroupName;
    property ProdName [Index:Integer]:String read GetProdName ;
    property UserName [Index:Integer]:String read GetUserName ;
    property WorksName[Index:Integer]:String read GetWorksName;
    property GroupCount:Integer read GetGroupCount;
    property ProdCount :Integer read GetProdCount ;
    property UserCount :Integer read GetUserCount ;
    property WorksCount:Integer read GetWorksCount;
    property Title:String read FTitle write FTitle;
    property LogFormats:TPackStringList read FLogFormats write FLogFormats;
  end;
  
  TForm1 = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


{TStrWrap}
constructor TStrWrap.Create(Value:String);
begin
   inherited Create;
   FValue:=Value;
end;
{TCompNode}
constructor TCompNode.Create(Node:TNode;Project:TProject);
var
   TitleNode:TNode;
   ItemNode:TNode;
   I:Integer;
begin
   inherited Create;
   FType:=ctNone;
   FItems:=TPackStringList.Create;
   if Node = nil then Exit;
   FName:=Node.NodeName;
   TitleNode:=Node.SelectNode('Title');
   if (TitleNode <> Node) and (TitleNode.Count > 0) then
      FTitle:=Strip(TitleNode.Name[0]);
   ItemNode:=Node.SelectNode('Items');
   if (ItemNode <> Node) then
      for I:=0 to ItemNode.Count-1 do    
         FItems.Add(Strip(ItemNode.Name[I]));
end;
destructor TCompNode.Destroy;
begin
   FItems.Free;
   inherited Destroy;
end;
function TCompNode.GetCount:Integer;
begin
   Result:=FItems.Count;
end;
function TCompNode.GetItem(Index:Integer):TCompNode;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=TCompNode(FItems.Objects[Index])
   else
      Result:=nil;
end;
procedure TCompNode.SetItem(Index:Integer;Value:TCompNode);
begin
   if (Index >= 0) and (Index < Count) then
      FItems.Objects[Index]:=Value;
end;
function TCompNode.GetName(Index:Integer):String;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=FItems[Index]
   else
      Result:='';
end;
function TCompNode.IndexOf(Value:String):Integer;
begin
   Result:=FItems.IndexOf(Value);
end;
procedure TCompNode.SetTraversed(Value:Boolean);
var
   I:Integer;
begin
   if Value then
   begin
      FTraversed:=Value
   end
   else
   begin
      for I:=0 to Count-1 do
         if Item[I] <> nil then
            Item[I].Traversed:=Value;
   end;
end;
{TExecNode}
constructor TExecNode.Create(Node:TNode;Project:TProject);
var
   BMPNode:TNode;
begin
   inherited Create(Node,Project);
   BMPNode:=Node.SelectNode('BitMap');
   if (BMPNode <> Node) and (BMPNode.Count > 0) then
      FBitMapFile:=Strip(BMPNode.Name[0]);
end;
{TProdNode}
constructor TProdNode.Create(Node:TNode;Project:TProject);
var
   BasedOnNode:TNode;
   LogAsNode:TNode;
   DomainsNode:TNode;
   PIndex:Integer;
   I:Integer;
begin         
   inherited Create(Node,Project);
   FAttribs:=TPackStringList.Create;
   FDomains:=TPackStringList.Create;
   FType:=ctProduct;
   DomainsNode:=Node.SelectNode('Domains');
   if (DomainsNode <> Node) and (DomainsNode.Count > 0) then
   begin
      for I:=0 to DomainsNode.Count-1 do
         FDomains.Add(DomainsNode.Name[I]);
   end;
   LogAsNode:=Node.SelectNode('LogAs');
   if (LogAsNode <> Node) and (LogAsNode.Count > 0) then
   begin
      PIndex:=Project.LogFormats.IndexOf(Strip(LogAsNode.Name[0]));
      if PIndex <> -1 then
         FLogAs:=TStrWrap(Project.LogFormats.Objects[PIndex]).Value
      else
         FLogAs:=Strip(LogAsNode.Name[0]);
   end;
   BasedOnNode:=Node.SelectNode('BasedOn');
   if (BasedOnNode <> Node) and (BasedOnNode.Count > 0) then
   begin
      PIndex:=Project.IndexOfProd(Strip(BasedOnNode.Name[0]));
      if PIndex <> -1 then
         BaseOn(Project.Prod[PIndex]);
   end;
   for I:=0 to Node.Count-1 do
   begin
      if ((Node.Name[I] <> 'Title'  )
      and (Node.Name[I] <> 'Items'  )
      and (Node.Name[I] <> 'BasedOn')
      and (Node.Name[I] <> 'Domains')
      and (Node.Name[I] <> 'LogAs'  )
      and (Node.Name[I] <> 'Bitmap' )) then
         FAttribs.Add(Node.Name[I]);
   end;
end;
destructor TProdNode.Destroy;
begin
   FAttribs.Free;
   FDomains.Free;
   inherited Destroy;
end;
procedure TProdNode.BaseOn(Node:TProdNode);
var
   I,Index:Integer;
begin
   if Node = nil then Exit;
   if FTitle      = '' then FTitle     :=Node.Title     ;
   if FBitMapFile = '' then FBitMapFile:=Node.BitMapFile;
   for I:=0 to Node.Count-1 do
   begin
      Index:=IndexOf(Node.ItemName[I]);
      if Index = -1 then
         FItems.AddObject(Node.ItemName[I],Node[I]);
   end;
   for I:=0 to Node.Domains.Count-1 do
      if FDomains.IndexOf(Node.Domains[I]) = -1 then
         FDomains.Add(Node.Domains[I]);
   if FLogAs = '' then
      FLogAs:=Node.LogAs;
end;                                                

{TGroupNode}
constructor TGroupNode.Create(Node:TNode;Project:TProject);
begin
   inherited Create(Node,Project);
   FType:=ctGroup;
end;
{TUserNode}
constructor TUserNode.Create(Node:TNode;Project:TProject);
begin
   inherited Create(Node,Project);
   FType:=ctUser;
end;
{TWSNode}
constructor TWorksNode.Create(Node:TNode;Project:TProject);
begin
   inherited Create(Node,Project);
   FType:=ctWorkstation;
end;
{TProject}
function TProject.GetGroup(Index:Integer):TGroupNode;
begin
   if (Index >= 0) and (Index < GroupCount) then
      Result:=TGroupNode(FGroup.Objects[Index])
   else
      Result:=nil;
end;
function TProject.GetProd (Index:Integer):TProdNode ;
begin
   if (Index >= 0) and (Index < ProdCount) then
      Result:=TProdNode(FProd.Objects[Index])
   else
      Result:=nil;
end;
function TProject.GetUser (Index:Integer):TUserNode ;
begin
   if (Index >= 0) and (Index < UserCount) then
      Result:=TUserNode(FUser.Objects[Index])
   else
      Result:=nil;
end;
function TProject.GetWorks(Index:Integer):TWorksNode;
begin
   if (Index >= 0) and (Index < WorksCount) then
      Result:=TWorksNode(FWorks.Objects[Index])
   else
      Result:=nil;
end;
function TProject.GetGroupCount:Integer;
begin
   Result:=FGroup.Count;
end;
function TProject.GetProdCount :Integer;
begin
   Result:=FProd.Count;
end;
function TProject.GetUserCount :Integer;
begin
   Result:=FUser.Count;
end;
function TProject.GetWorksCount:Integer;
begin
   Result:=FWorks.Count;
end;
function TProject.IndexOfGroup(Value:String):Integer;
begin
   Result:=FGroup.IndexOf(Value);
end;
function TProject.IndexOfProd (Value:String):Integer;
begin
   Result:=FProd.IndexOf(Value);
end;       
function TProject.IndexOfUser (Value:String):Integer;
begin
   Result:=FUser.IndexOf(Value);
end;       
function TProject.IndexOfWorks(Value:String):Integer;
begin
   Result:=FWorks.IndexOf(Value);
end;       
function TProject.GetGroupName(Index:Integer):String;
begin
   if (Index >= 0) and (Index < GroupCount) then
      Result:=FGroup[Index]
   else
      Result:='';
end;
function TProject.GetProdName (Index:Integer):String;
begin
   if (Index >= 0) and (Index < ProdCount) then
      Result:=FProd[Index]
   else
      Result:='';
end;           
function TProject.GetUserName (Index:Integer):String;
begin
   if (Index >= 0) and (Index < UserCount) then
      Result:=FUser[Index]
   else
      Result:='';
end;           
function TProject.GetWorksName(Index:Integer):String;
begin
   if (Index >= 0) and (Index < WorksCount) then
      Result:=FWorks[Index]
   else
      Result:='';
end;           
function CopyType(Name:String):TCompType;
begin
   if Copy(Name,1,6) = 'Group.' then
      Result:=ctGroup
   else if Copy(Name,1,8) = 'Product.' then
      Result:=ctProduct
   else
      Result:=ctNone;
end;   
constructor TProject.Create(FileName:String);
var
   SL:TPackStringList;
   Node:TNode;
   I,J,Index:Integer;
   GNode:TGroupNode;
   PNode:TProdNode;
   UNode:TUserNode;
   WNode:TWorksNode;
   Parser:TParser;
   TitleNode:TNode;
   SW:TStrWrap;
begin
   inherited Create;
   FGroup:=TPackStringList.Create;
   FProd :=TPackStringList.Create;
   FUser :=TPackStringList.Create;
   FWorks:=TPackStringList.Create;
   LogFormats:=TPackStringList.Create;
   
   SL:=TPackStringList.Create;
   SL.LoadFromFile(FileName);
   Parser:=TParser.Create(SL.Text);
   SL.Free;
   TitleNode:=Parser.Nodes.SelectNode('Title');
   if (TitleNode <> Parser.Nodes) and (TitleNode.Count > 0) then
      FTitle:=Strip(TitleNode.Name[0]);
      
   Node:=Parser.Nodes.SelectNode('LogFormats');
   for I:=0 to Node.Count-1 do
   begin
      SW:=TStrWrap.Create(Strip(Node[I].Name[0]));
      LogFormats.AddObject(Node.Name[I],SW);
   end;
   Node:=Parser.Nodes.SelectNode('Groups');
   for I:=0 to Node.Count-1 do
   begin
      GNode:=TGroupNode.Create(Node[I],Self);
      FGroup.AddObject(GNode.Name,GNode);
   end;
   Node:=Parser.Nodes.SelectNode('Products');
   for I:=0 to Node.Count-1 do
   begin
      PNode:=TProdNode.Create(Node[I],Self);
      FProd.AddObject(PNode.Name,PNode);
   end;
   Node:=Parser.Nodes.SelectNode('Users');
   for I:=0 to Node.Count-1 do
   begin
      UNode:=TUserNode.Create(Node[I],Self);
      FUser.AddObject(UNode.Name,UNode);
   end;
   Node:=Parser.Nodes.SelectNode('WorkStations');
   for I:=0 to Node.Count-1 do
   begin
      WNode:=TWorksNode.Create(Node[I],Self);
      FProd.AddObject(WNode.Name,WNode);
   end;
   for I:=0 to GroupCount-1 do
   begin
      for J:=0 to Group[I].Count-1 do
      begin
         case CopyType(Group[I].ItemName[J]) of
            ctGroup   : begin
                           Index:=IndexOfGroup(Copy(Group[I].ItemName[J],7,999));
                           if Index <> -1 then
                              Group[I][J]:=Group[Index];
                        end;
            ctProduct : begin
                           Index:=IndexOfProd(Copy(Group[I].ItemName[J],9,999));
                           if Index <> -1 then
                              Group[I][J]:=Prod[Index];
                        end;
         end;
      end;
   end;
   for I:=0 to UserCount-1 do
   begin
      for J:=0 to User[I].Count-1 do
      begin
         Index:=IndexOfGroup(Copy(User[I].ItemName[J],7,999));
         if Index <> -1 then
            User[I][J]:=Group[Index];
      end;
   end;
   for I:=0 to WorksCount-1 do
   begin
      for J:=0 to Works[I].Count-1 do
      begin
         Index:=IndexOfGroup(Copy(Works[I].ItemName[J],7,999));
         if Index <> -1 then
            Works[I][J]:=Group[Index];
      end;
   end;
   for I:=0 to ProdCount-1 do
   begin
      for J:=0 to Prod[I].Count-1 do
      begin
         case CopyType(Prod[I].ItemName[J]) of
            ctGroup   : begin
                           Index:=IndexOfGroup(Copy(Prod[I].ItemName[J],7,999));
                           if Index <> -1 then
                              Prod[I][J]:=Group[Index];
                        end;
            ctProduct : begin
                           Index:=IndexOfProd(Copy(Prod[I].ItemName[J],9,999));
                           if Index <> -1 then
                              Prod[I][J]:=Prod[Index];
                        end;
         end;
      end;
   end;
end;
destructor TProject.Destroy;
var
   I:Integer;
begin
   for I:=0 to GroupCount-1 do Group[I].Free; FGroup.Free; 
   for I:=0 to ProdCount-1  do Prod [I].Free; FProd .Free; 
   for I:=0 to UserCount-1  do User [I].Free; FUser .Free; 
   for I:=0 to WorksCount-1 do Works[I].Free; FWorks.Free;
   inherited Destroy;
end;
procedure ListNode(Node:TCompNode;List:TStrings;Indent:String);
var
   I:Integer;
begin
   if Node = nil then Exit;
   case Node.CompType of
      ctProduct : List.Add(Indent+'Product.'+Node.Name);
      ctGroup   : List.Add(Indent+'Group.'  +Node.Name);
   end;
   if Node.Traversed then Exit;
   Node.Traversed:=True;        
   for I:=0 to Node.Count-1 do
   begin
       if (Node[I] <> nil) and (Node[I].CompType = ctProduct) then
          ListNode(Node[I],List,Indent+'     ')
       else if (Node[I] <> nil) and (Node[I].CompType = ctGroup) then
          ListNode(Node[I],List,Indent+'     ')
       else
          List.Add(Indent+'     ('+Node.ItemName[I]+')');
   end;
   if Node.CompType = ctProduct then
   begin
      if TProdNode(Node).LogAs <> '' then
         List.Add(Indent+'LogAs :'+TProdNode(Node).LogAs);
      if TProdNode(Node).Domains.Count > 0 then
         List.Add(Indent+'Domains:');
      for I:=0 to TProdNode(Node).Domains.Count-1 do
         List.Add(Indent+'   '+TProdNode(Node).Domains[I]);
      for I:=0 to TProdNode(Node).Attribs.Count-1 do
         List.Add(Indent+'* '+TProdNode(Node).Attribs[I]);
   end; 
end;
procedure TForm1.FormCreate(Sender: TObject);
var
   Project:TProject;
   MainNode:TUserNode;
begin                     
   Project:=TProject.Create('Bermuda.ids');
   Memo1.Clear;
   Memo1.Lines.Add('UGroup.Clerk');
   MainNode:=Project.User[Project.IndexOfUser('Clerk')];
   MainNode.Traversed:=False;
   ListNode(MainNode,Memo1.Lines,'');
   Project.Free;
end;

end.
