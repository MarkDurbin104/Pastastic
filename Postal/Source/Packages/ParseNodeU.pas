unit ParseNodeU;

interface

uses
   Windows,Graphics,Forms,SysUtils,Classes,FileCtrl,comctrls,
   PackStrListU;
   
type
  TRootNode = class;
  TCorvusNode = class(TPackStringList)
  private
     FModified:Boolean;
     FInvokedBy:TList;
     FUsed:Boolean;
     function IDSQuote(S:String):String;
  protected
     FHeight:Integer;
     FWidth:Integer;
     FIsLoaded:Boolean;
     FName:String;
     FParentNode:TCorvusNode;
     FFileName:String;
     FLineNumber:Integer;
     FBasedOn:String;
     FBasedOnNode:TCorvusNode;
     function AddToTree(TreeNodes:TTreeNodes;TreeNode:TTreeNode):TTreeNode; virtual;
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; virtual;
     function GetNode(Index:Integer):TCorvusNode;
     procedure AddItems(Root:TCorvusNode;List:TStrings;Items,IType:String);
     function IDSText(Indent:Integer;OnePerLine:Boolean):String;
     procedure StructureString(Depth:String;List:TStrings);
  public
     function SubItemDetails(List:TStrings):String; virtual;
     function ListDetails:String; virtual;
     property Node[Index:Integer]:TCorvusNode read GetNode;
     function AddObject(const S: string; AObject: TObject): Integer; override;
     function NodeNamed(Name:String):TCorvusNode; virtual;
     function AnySubNodeNamed(Name:String):TCorvusNode; virtual;
     constructor Create(Name,FileName:String;LineNumber:Integer); virtual;
     destructor Destroy; override;
     property InvokedBy:TList read FInvokedBy write FInvokedBy;
     property LineNumber:Integer read FLineNumber write FLineNumber;
     function StructureAsString:String;
     procedure SetBasedOn(RootNode:TRootNode);
     property BasedOnNode:TCorvusNode read FBasedOnNode write FBasedOnNode;
     property BasedOn  :String read FBasedOn    write FBasedOn  ;
     function DragOver(CompType:Integer):Boolean; virtual;
     procedure DragDrop(Node:TCorvusNode;CompName:String); virtual;
     property ParentNode:TCorvusNode read FParentNode write FParentNode;
  published
     property Name:String read FName write FName;
     property FileName  :String  read FFileName   write FFileName  ;
     property Used:Boolean read FUsed write FUsed;
  end;
  TParseNode = class(TCorvusNode)
  private
     TotalLines:Integer;
     TokenPtr:PChar;
     FFileList:TStringList;
     function RemQuotes(S:String):String;
  protected
     procedure Parse(Path,FileName:String;Data:PChar;LineNumber:Integer);
     procedure InterpretTok(Tok:String;IsIdent:Boolean;FileName:String;LineNumber:Integer);
     function GetToken(var P:PChar;var IsIdent:Boolean;var LineNumber:Integer):String;
  public
     destructor Destroy; override;
     function NewCompType(CurrCompType:TCorvusNode;CurrCompTypeName,Tok,FileName:String;LineNumber:Integer):Integer; virtual;
     procedure ParseFile(Path,FileName:String;LineNumber:Integer);
     property FileList:TStringList  read FFileList write FFileList;
  end;
  TRootNode = class(TParseNode)
  private
     FFunctions   :TCorvusNode;
     FBuildOptions:TCorvusNode;
     FConstants   :TCorvusNode;
     FDomains     :TCorvusNode;
     FGroups      :TCorvusNode;
     FLogFormats  :TCorvusNode;
     FLookUps     :TCorvusNode;
     FPickLists   :TCorvusNode;
     FProducts    :TCorvusNode;
     FSnippets    :TCorvusNode;
     FUsers       :TCorvusNode;
     FWorkStations:TCorvusNode;
  protected
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
  public
     constructor Create(Name,FileName:String;LineNumber:Integer); override;
     function ListDetails:String; override;
     function NodeNamed(Name:String):TCorvusNode; override;
     function SubItemDetails(List:TStrings):String; override;
     procedure SaveAs(Path,BaseName:String);
     property Functions   :TCorvusNode read FFunctions    write FFunctions   ;
     property BuildOptions:TCorvusNode read FBuildOptions write FBuildOptions;
     property Constants   :TCorvusNode read FConstants    write FConstants   ;
     property Domains     :TCorvusNode read FDomains      write FDomains     ;
     property Groups      :TCorvusNode read FGroups       write FGroups      ;
     property LogFormats  :TCorvusNode read FLogFormats   write FLogFormats  ;
     property LookUps     :TCorvusNode read FLookUps      write FLookUps     ;
     property PickLists   :TCorvusNode read FPickLists    write FPickLists   ;
     property Products    :TCorvusNode read FProducts     write FProducts    ;
     property Snippets    :TCorvusNode read FSnippets     write FSnippets    ;
     property Users       :TCorvusNode read FUsers        write FUsers       ;
     property WorkStations:TCorvusNode read FWorkStations write FWorkStations;
  end;

  TBuildOptionsNode = class(TCorvusNode)
  private
    FAliases         :String;
    FBuildAllUnits   :String;
    FCommandLine     :String;
    FDCUOutputDir    :String;
    FEXEOutputDir    :String;
    FGroupInput      :String;
    FLibraryPath     :String;
    FLookUpInput     :String;
    FPackages        :String;
    FPickListInput   :String;
    FProductInput    :String;
    FRootSrcOutputDir:String;
    FSearchPath      :String;
    FUserInput       :String;
    FWorkStationInput:String;
  protected
    function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
  public
    function SubItemDetails(List:TStrings):String; override;
    function ListDetails:String; override;
  published
    property Aliases         :String read FAliases          write FAliases         ;
    property BuildAllUnits   :String read FBuildAllUnits    write FBuildAllUnits   ;
    property CommandLine     :String read FCommandLine      write FCommandLine     ;
    property DCUOutputDir    :String read FDCUOutputDir     write FDCUOutputDir    ;
    property EXEOutputDir    :String read FEXEOutputDir     write FEXEOutputDir    ;
    property GroupInput      :String read FGroupInput       write FGroupInput      ;
    property LibraryPath     :String read FLibraryPath      write FLibraryPath     ;
    property LookUpInput     :String read FLookUpInput      write FLookUpInput     ;
    property Packages        :String read FPackages         write FPackages        ;
    property PickListInput   :String read FPickListInput    write FPickListInput   ;
    property ProductInput    :String read FProductInput     write FProductInput    ;
    property RootSrcOutputDir:String read FRootSrcOutputDir write FRootSrcOutputDir;
    property SearchPath      :String read FSearchPath       write FSearchPath      ;
    property UserInput       :String read FUserInput        write FUserInput       ;
    property WorkStationInput:String read FWorkStationInput write FWorkStationInput;
  end;
  TLogFormatNode = class(TCorvusNode)
  protected
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
  public
     function SubItemDetails(List:TStrings):String; override;
     function ListDetails:String; override;
  end;
  TConstantNode = class(TCorvusNode)
  protected
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
  public
     function SubItemDetails(List:TStrings):String; override;
     function ListDetails:String; override;
  end;
  TFunctionNode = class(TCorvusNode)
  private
    FTitle       :String;
  protected
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
  public
     function SubItemDetails(List:TStrings):String; override;
     function ListDetails:String; override;
  published
     property Title       :String read FTitle        write FTitle       ;
  end;

  TLookUpNode = class(TCorvusNode)
  private
     FDontBuild:String;
     FRange    :String;
     FSubGroup :String;
     function GetSubGroup:String;
  protected
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
  public
     function SubItemDetails(List:TStrings):String; override;
     function ListDetails:String; override;
  published
     property SubGroup :String read GetSubGroup write FSubGroup ;
     property DontBuild:String read FDontBuild  write FDontBuild;
     property Range    :String read FRange      write FRange    ;
  end;

  TPickListNode = class(TCorvusNode)
  private
    FDontBuild:String;
    FSorted   :String;
    FDefault  :String;
    FSubGroup :String;
  protected
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
  public
     function SubItemDetails(List:TStrings):String; override;
     function ListDetails:String; override;
  published
     property SubGroup   :String read FSubGroup   write FSubGroup ;
     property BasedOn;
     property DontBuild  :String read FDontBuild  write FDontBuild;
     property Sorted     :String read FSorted     write FSorted   ;
     property DefaultItem:String read FDefault    write FDefault  ;
  end;

  TDomainNode = class(TCorvusNode)
  private
    FTotalIn     :String;
    FDefaultValue:String;
    FError       :String;
    FFormat      :String;
    FHint        :String;
    FInputFrom   :String;
    FLocale      :String;
    FPrompt      :String;
    FTitle       :String;
    FSubGroup    :String;
  protected
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
  public
     function SubItemDetails(List:TStrings):String; override;
     function ListDetails:String; override;
  published
     property SubGroup    :String read FSubGroup     write FSubGroup    ;
     property BasedOn;
     property TotalIn     :String read FTotalIn      write FTotalIn     ;
     property DefaultValue:String read FDefaultValue write FDefaultValue;
     property ErrorStr    :String read FError        write FError       ;
     property Format      :String read FFormat       write FFormat      ;
     property Hint        :String read FHint         write FHint        ;
     property InputFrom   :String read FInputFrom    write FInputFrom   ;
     property Locale      :String read FLocale       write FLocale      ;
     property Prompt      :String read FPrompt       write FPrompt      ;
     property Title       :String read FTitle        write FTitle       ;
  end;

  TImageNode = class(TCorvusNode)
    private
       function GetImage:TBitMap;
    protected
       FBitMap     :String;
       FTitle      :String;
       FCaption    :String;
       FDescription:String;
       FImage      :TBitMap;
       FItemNodes  :TPackStringList;
       FItems      :String;
       function GetItemNode(Index:Integer):TCorvusNode;
       function GetItemNodeName(Index:Integer):String;
       procedure SetItems(Value:String);
    public
       destructor Destroy; override;
       function GetItemNodeCount:Integer;
       procedure UnLink;
       property ItemNode[Index:Integer]:TCorvusNode  read GetItemNode;
       property NodeName[Index:Integer]:String  read GetItemNodeName;
       property ItemNodes:TPackStringList read FItemNodes write FItemNodes;
    published
       property Image      :TBitmap read GetImage     write FImage      ;
       property BitMap     :String  read FBitMap      write FBitMap     ;
       property Title      :String  read FTitle       write FTitle      ;
       property Caption    :String  read FCaption     write FCaption    ;
       property Description:String  read FDescription write FDescription;
       property Items :String read FItems write SetItems;
  end;
  TGroupNode = class(TImageNode)
  private
    FRegDesc    :String;
    FDontBuild  :String;
    FHint       :String;
    FPrompt     :String;
    FSubGroup   :String;
  protected
     function AddToTree(TreeNodes:TTreeNodes;TreeNode:TTreeNode):TTreeNode; override;
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
  public
     function SubItemDetails(List:TStrings):String; override;
     function ListDetails:String; override;
     function DragOver(CompType:Integer):Boolean; override;
     procedure DragDrop(Node:TCorvusNode;CompName:String); override;
   published
     property RegDesc  :String  read FRegDesc   write FRegDesc  ;
     property BasedOn;
     property DontBuild:String  read FDontBuild write FDontBuild;
     property Hint     :String  read FHint      write FHint     ;
     property Prompt   :String  read FPrompt    write FPrompt   ;
     property SubGroup :String  read FSubGroup  write FSubGroup ;
  end;
  TProductNode = class(TImageNode)
  private
    FRegDesc    :String;
    FVersion    :String;
    FProgID     :String;
    FAccount    :String;
    FLine       :String;
    FCustomer   :String;
    FDomains    :String;
    FDontBuild  :String;
    FEndorse    :String;
    FHint       :String;
    FLogAs      :String;
    FOCRCode    :String;
    FPLU        :String;
    FPrice      :String;
    FPrintList  :String;
    FPrompt     :String;
    FRegulations:String;
    FSnippets   :String;
    FSubGroup   :String;
    FUnitPrice  :String;
  protected
     function GetSubGroup:String;
     function AddToTree(TreeNodes:TTreeNodes;TreeNode:TTreeNode):TTreeNode; override;
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
  public
     function SubItemDetails(List:TStrings):String; override;
     function ListDetails:String; override;
     function DragOver(CompType:Integer):Boolean; override;
     procedure DragDrop(Node:TCorvusNode;CompName:String); override;
  published   
     property SubGroup   :String read GetSubGroup  write FSubGroup;
     property RegDesc    :String read FRegDesc     write FRegDesc  ;
     property BasedOn;
     property DontBuild  :String read FDontBuild   write FDontBuild;
     property Hint       :String read FHint        write FHint     ;
     property Prompt     :String read FPrompt      write FPrompt   ;
     property Version    :String read FVersion     write FVersion    ;
     property ProgID     :String read FProgID      write FProgID     ;
     property Account    :String read FAccount     write FAccount    ;
     property Line       :String read FLine        write FLine       ;
     property Customer   :String read FCustomer    write FCustomer   ;
     property Domains    :String read FDomains     write FDomains    ;
     property Endorse    :String read FEndorse     write FEndorse    ;
     property LogAs      :String read FLogAs       write FLogAs      ;
     property OCRCode    :String read FOCRCode     write FOCRCode    ;
     property PLU        :String read FPLU         write FPLU        ;
     property Price      :String read FPrice       write FPrice      ;
     property PrintList  :String read FPrintList   write FPrintList  ;
     property Regulations:String read FRegulations write FRegulations;
     property Snippets   :String read FSnippets    write FSnippets   ;
     property UnitPrice  :String read FUnitPrice   write FUnitPrice  ;
  end;

  TSnippetNode = class(TCorvusNode)
  private
    FSubGroup     :String;
    FCodeBlock    :String;
    FInsertBetween:String;
  protected
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
  public
     function SubItemDetails(List:TStrings):String; override;
     function ListDetails:String; override;
  published
     property SubGroup     :String read FSubGroup      write FSubGroup     ;
     property BasedOn;
     property CodeBlock    :String read FCodeBlock     write FCodeBlock    ;
     property InsertBetween:String read FInsertBetween write FInsertBetween;
  end;

  TUserNode = class(TCorvusNode)
  private
    FSubGroup   :String;
    FDontBuild  :String;
    FItems      :String;
    FRegDesc    :String;
    FVersion    :String;
    FProgID     :String;
    FGUID       :String;
  protected
     FItemNodes  :TPackStringList;
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
     function GetItemNode(Index:Integer):TGroupNode;
     function GetItemNodeName(Index:Integer):String;
     procedure SetItems(Value:String);
  public
     function SubItemDetails(List:TStrings):String; override;
     procedure UnLink;
     function GetItemNodeCount:Integer;
     property ItemNode[Index:Integer]:TGroupNode  read GetItemNode;
     property NodeName[Index:Integer]:String  read GetItemNodeName;
     function ListDetails:String; override;
     function DragOver(CompType:Integer):Boolean; override;
     procedure DragDrop(Node:TCorvusNode;CompName:String); override;
     property ItemNodes:TPackStringList read FItemNodes write FItemNodes;
  published    
     property SubGroup :String read FSubGroup  write FSubGroup ;
     property BasedOn;
     property DontBuild:String read FDontBuild write FDontBuild;
     property Items    :String read FItems     write SetItems  ;
     property RegDesc  :String read FRegDesc   write FRegDesc  ;
     property Version  :String read FVersion   write FVersion  ;
     property ProgID   :String read FProgID    write FProgID   ;
     property GUID     :String read FGUID      write FGUID     ;
  end;

  TWorkStationNode = class(TUserNode)
  public
     function SubItemDetails(List:TStrings):String; override;
  end;

function StrCmp(A,B:String):Boolean;

implementation

uses ErrorFormFU;

{TCorvusNode}
constructor TCorvusNode.Create(Name,FileName:String;LineNumber:Integer);
begin
   inherited Create;
   FUsed:=False;
   FInvokedBy:=TList.Create;
   FFileName:=FileName;
   FLineNumber:=LineNumber;
   FName:=Name;
end;
function TCorvusNode.DragOver(CompType:Integer):Boolean;
begin
   Result:=False;
end;
procedure TCorvusNode.DragDrop(Node:TCorvusNode;CompName:String);
begin
end;
procedure TCorvusNode.SetBasedOn(RootNode:TRootNode);
var
   I:Integer;
   Skip:Boolean;
begin
   if (FBasedOn <> '') and (RootNode <> nil) then
   begin
      Skip:=False;
           if (Self is TDomainNode      ) then FBasedOnNode:=RootNode.NodeNamed('Domain'     +'.'+BasedOn)
      else if (Self is TProductNode     ) then FBasedOnNode:=RootNode.NodeNamed('Product'    +'.'+BasedOn)
      else if (Self is TLookUpNode      ) then FBasedOnNode:=RootNode.NodeNamed('LookUp'     +'.'+BasedOn)
      else if (Self is TGroupNode       ) then FBasedOnNode:=RootNode.NodeNamed('Group'      +'.'+BasedOn)
      else if (Self is TPickListNode    ) then FBasedOnNode:=RootNode.NodeNamed('PickList'   +'.'+BasedOn)
      else if (Self is TConstantNode    ) then FBasedOnNode:=RootNode.NodeNamed('Constant'   +'.'+BasedOn)
      else if (Self is TLogFormatNode   ) then FBasedOnNode:=RootNode.NodeNamed('LogFormat'  +'.'+BasedOn)
      else if (Self is TUserNode        ) then FBasedOnNode:=RootNode.NodeNamed('User'       +'.'+BasedOn)
      else if (Self is TWorkStationNode ) then FBasedOnNode:=RootNode.NodeNamed('WorkStation'+'.'+BasedOn)
      else if (Self is TSnippetNode     ) then FBasedOnNode:=RootNode.NodeNamed('Snippet'    +'.'+BasedOn)
      else Skip:=True;
      if (not Skip) and (FBasedOnNode <> nil) and (FBasedOnNode.FInvokedBy.IndexOf(Self) = -1) then
         FBasedOnNode.FInvokedBy.Add(Self);
   end;
   for I:=0 to Count-1 do
   begin
      if Objects[I] <> nil then
         TCorvusNode(Objects[I]).SetBasedOn(RootNode);
   end;
end;

procedure TCorvusNode.StructureString(Depth:String;List:TStrings);
var
   I:Integer;
begin
   for I:=0 to Count-1 do
   begin
      List.Add(Depth+Get(I));
      if Objects[I] <> nil then
         TCorvusNode(Objects[I]).StructureString(Depth+' ',List);
   end;
end;
function TCorvusNode.StructureAsString:String;
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   StructureString('',SL);
   Result:=SL.Text;
   SL.Free;
end;
destructor TCorvusNode.Destroy;
begin
   if FInvokedBy <> nil then
      FInvokedBy.Free;
   FInvokedBy:=nil;
   while Count > 0 do
   begin
      if Objects[0] <> nil then 
      begin
         Objects[0].Free;
         Objects[0]:=nil;
      end;
      Delete(0);
   end;
   inherited Destroy;
end;
function IsIdent(S:String):Boolean;
var
  P:PChar;
begin
  Result:=False;
  P:=PChar(S);
  if not (P^ in ['A'..'Z','a'..'z','_']) then Exit;
  Inc(P);
  while (P^ <> #0) and (P^ in ['0'..'9','A'..'Z','a'..'z','_']) do
     Inc(P);
  if P^ = #0 then
     Result:=True;
end;
function IsNumber(S:String):Boolean;
var
  P:PChar;
begin
  Result:=False;
  P:=PChar(S);
  while (P^ <> #0) and (P^ in ['0'..'9','-']) do
     Inc(P);
  if P^ = #0 then
     Result:=True;
end;
function IsJustQuotes(S:String):Boolean;
var
  P:PChar;
begin
  Result:=False;
  P:=PChar(S);
  while P^ = #39 do Inc(P);
  if P^ = #0 then
     Result:=True;
end;
function TCorvusNode.IDSQuote(S:String):String;
var
   I:Integer;
begin
  if IsIdent(S) or IsNumber(S) or IsJustQuotes(S) then
     Result:=S
  else
  begin
     Result:=#39;
     for I:=1 to Length(S) do
     begin
        if S[I] = #39 then
           Result:=Result+#39+#39
        else
           Result:=Result+S[I];
     end;
     Result:=Result+#39;
  end;
end;
function TCorvusNode.IDSText(Indent:Integer;OnePerLine:Boolean):String;
var
  S:String;
  IDString:String;
  SP:PChar;
  R:PChar;
  L,I,Count,Ofs,MaxLen:Integer;
  LineWidth:Integer;
begin
  MaxLen:=5000;
  SetLength(IDString,Indent);
  System.FillChar(PChar(IDString)^,Indent,' ');
  Count := GetCount;
  if Count = 0 then
  begin
    Result:='';
  end
  else if (Count = 1) and (Get(0) = '') then
    Result := ''''''
  else
  begin
    LineWidth:=0;
    SetLength(Result,MaxLen);
    SP:=PChar(Result);
    R:=SP;
    for I := 0 to Count - 1 do
    begin
      S:=IDSQuote(Get(I));
      L:=Length(S);
      Inc(LineWidth,L);
      if L+(R-SP)+Indent > MaxLen then
      begin
         Ofs:=(R-SP);
         Inc(MaxLen,5000+L);
         SetLength(Result,MaxLen);
         SP:=PChar(Result);
         R:=SP;
         Inc(R,Ofs);
      end;
      System.Move(PChar(S)^,R^,L);
      Inc(R,L);
      if I < (Count - 1) then
      begin
         R^:=',';
         Inc(R);
      end;
      if (I < Count-1) and ((LineWidth > 160) or OnePerLine) then
      begin
         LineWidth:=Indent;
         System.Move(PChar(#13#10+IDString)^,R^,LineWidth+2);
         Inc(R,LineWidth+2);
      end;
    end;
    if (R-SP) > 0 then
       SetLength(Result,(R-SP))
    else
       SetLength(Result,0);
    if (OnePerLine) and (Count > 1) then Result:=#13#10+IDString+Result+#13#10+Copy(IDString,1,Length(IDString)-4);
  end;
end;
function TCorvusNode.AddObject(const S:String;AObject:TObject):Integer;
begin
   Result:=inherited AddObject(S,AObject);
   if (AObject is TCorvusNode) then
      (AObject as TCorvusNode).FParentNode:=Self;
end;
function TCorvusNode.AddToTree(TreeNodes:TTreeNodes;TreeNode:TTreeNode):TTreeNode;
begin
   Result:=TreeNodes.AddChildObject(TreeNode,Name,Self);
end;
function TCorvusNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
begin
   Result:=IndexOf(Name);
   if Result = -1 then
      Result:=AddObject(Name,TCorvusNode.Create(Name,FileName,LineNumber))
   else if Objects[Result] = nil then
      Objects[Result]:=TCorvusNode.Create(Name,FileName,LineNumber);

   TCorvusNode(Objects[Result]).Add(Trim(Value));
   FIsLoaded:=True;
end;
function TCorvusNode.GetNode(Index:Integer):TCorvusNode;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=TCorvusNode(Objects[Index])
   else
      Result:=nil;
end;
function TCorvusNode.NodeNamed(Name:String):TCorvusNode;
begin
   Result:=GetNode(IndexOf(Name));
end;
function TCorvusNode.AnySubNodeNamed(Name:String):TCorvusNode;
var
   I:Integer;
   SubNode:TCorvusNode;
begin
   Result:=NodeNamed(Name);
   if Result = nil then
   begin
      for I:=0 to Count-1 do
      begin
         SubNode:=GetNode(I);
         if (SubNode <> nil) then
            Result:=SubNode.AnySubNodeNamed(Name);
         if Result <> nil then 
            Exit;
      end;
   end;
end;

function TCorvusNode.ListDetails:String;
var
   SL:TPackStringList;
   I:Integer;
   S:String;
   CN:TCorvusNode;
begin
   SL:=TPackStringList.Create;
   SL.Add('      '+Name+' {');
   for I:=0 to Count-1 do
   begin
      CN:=TCorvusNode(Objects[I]);
      if (CN <> nil) then
      begin
         if CN.Count > 0 then
         begin
           SL.Add(CN.ListDetails);
         end
         else
         begin
            if Trim(CN.Text) = '' then
            begin
               SL.Add('         '+IDSQuote(Get(I)));
            end
            else
            begin
               S:='         '+Get(I)+'  { ';
               SL.Add(S+CN.IDSText(Length(S),False)+' }');
            end;
         end;  
      end
      else
         SL.Add('         '+IDSQuote(Get(I)));
   end;
   SL.Add('      }');
   Result:='      '+Trim(SL.Text);
   SL.Free;
end;
function TCorvusNode.SubItemDetails(List:TStrings):String;
begin
   Result:=Name;
   if List.IndexOf(Result) = -1 then List.Add(Result);
end;
procedure TCorvusNode.AddItems(Root:TCorvusNode;List:TStrings;Items,IType:String);
var
   SNode:TCorvusNode;
   I:Integer;
   SL:TPackStringList;
   S:String;
begin
   SL:=TPackStringList.Create;
   SL.CommaText:=Items;
   if IType <> '' then
   begin
      for I:=0 to SL.Count-1 do
         SL[I]:=IType+'.'+SL[I];
   end;
   while Root.FParentNode <> nil do Root:=Root.FParentNode;
   for I:=0 to SL.Count-1 do
   begin
      if Application.Terminated then Exit;
      SNode:=Root.NodeNamed(SL[I]);
      if SNode <> nil then
         SNode.SubItemDetails(List)
      else
      begin
         if Pos(SL[I]+'#','Complete#Report#Receipt#End Customer#Exit#Shutdown Workstation#Cancel Customer#Shutdown WorkStation#Next Items#') = 0 then
         begin
            S:='Unknown Function: '+SL[I]+' referenced by '+Self.ClassName+'.'+Self.Name;
            if (ErrorForm <> nil) and (ErrorForm.Errors.Lines.IndexOf(S) = -1) then
            begin
               ErrorForm.Errors.Lines.Add(S);
               ErrorForm.Show;
            end;
//         if List.IndexOf('Function('+SL[I]+')') = -1 then List.Add('Function('+SL[I]+')');
         end;
      end;
   end;
   SL.Free;
end;

function StrCmp(A,B:String):Boolean;
begin
   Result:=UpperCase(A) = UpperCase(B);
end;
{TBuildOptionsNode}
function TBuildOptionsNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
var
   S:^String;
   Temp:String;
begin
   Result:=0;
        if StrCmp(Name,'Aliases'         ) then S:=@FAliases
   else if StrCmp(Name,'BuildAllUnits'   ) then S:=@FBuildAllUnits
   else if StrCmp(Name,'CommandLine'     ) then S:=@FCommandLine
   else if StrCmp(Name,'DCUOutputDir'    ) then S:=@FDCUOutputDir
   else if StrCmp(Name,'EXEOutputDir'    ) then S:=@FEXEOutputDir
   else if StrCmp(Name,'GroupInput'      ) then S:=@FGroupInput
   else if StrCmp(Name,'LibraryPath'     ) then S:=@FLibraryPath
   else if StrCmp(Name,'LookUpInput'     ) then S:=@FLookUpInput
   else if StrCmp(Name,'Packages'        ) then S:=@FPackages
   else if StrCmp(Name,'PickListInput'   ) then S:=@FPickListInput
   else if StrCmp(Name,'ProductInput'    ) then S:=@FProductInput
   else if StrCmp(Name,'RootSrcOutputDir') then S:=@FRootSrcOutputDir
   else if StrCmp(Name,'SearchPath'      ) then S:=@FSearchPath
   else if StrCmp(Name,'UserInput'       ) then S:=@FUserInput
   else if StrCmp(Name,'WorkStationInput') then S:=@FWorkStationInput
   else S:=@Temp;

   if IndexOf(Name) = -1 then
      Result:=Add(Name);
   TCorvusNode(Objects[IndexOf(Name)]).Add(Trim(Value));
   if S^ = '' then S^:=Value else S^:=S^+','+Value;
end;
function TBuildOptionsNode.ListDetails:String;
begin
   Result:=inherited ListDetails;
end;
function TBuildOptionsNode.SubItemDetails(List:TStrings):String;
begin
   Result:='BuildOption.'+Name;
   if List.IndexOf(Result) = -1 then List.Add(Result);
end;
{TConstantNode}
function TConstantNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
var
   S:^String;
   Temp:String;
begin
   Result:=0;
   S:=@Temp;

   if S^ = '' then S^:=Value else S^:=S^+','+Value;
   if S = @Temp then
      Result:=Add(Value);
   FIsLoaded:=False;
end;
function TConstantNode.ListDetails:String;
begin
   Result:='   '+Name+' { '+Trim(Text)+' }';
end;
function TConstantNode.SubItemDetails(List:TStrings):String;
begin
   Result:='Constant.'+Name;
   if List.IndexOf(Result) = -1 then List.Add(Result);
end;
{TLogFormatNode}
function TLogFormatNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
var
   S:^String;
   Temp:String;
begin
   Result:=0;
   S:=@Temp;

   if S^ = '' then S^:=Value else S^:=S^+','+Value;
   if S = @Temp then
      Result:=Add(Value);
   FIsLoaded:=False;
end;
function TLogFormatNode.ListDetails:String;
begin
   if Count = 2 then
      Result:='   '+Name+' { '+IDSQuote(Get(0))+','+Get(1)+' }';
end;
function TLogFormatNode.SubItemDetails(List:TStrings):String;
begin
   Result:='LogFormat.'+Name;
   if List.IndexOf(Result) = -1 then List.Add(Result);
end;
{TFunctionNode}
function TFunctionNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
var
   S:^String;
   Temp:String;
begin
   Result:=0;
   if StrCmp(Name,'Title'       ) then S:=@FTitle
   else S:=@Temp;

   if IndexOf(Name) = -1 then
      Result:=Add(Name);
   TCorvusNode(Objects[IndexOf(Name)]).Add(Trim(Value));
   if S^ = '' then S^:=Value else S^:=S^+','+Value;
   FIsLoaded:=False;
end;
function TFunctionNode.ListDetails:String;
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;

   SL.Add(Name+' {');
   if FTitle        <> '' then SL.Add('      Title        { '+FTitle       +' }');
   SL.Add('   }');
   Result:='   '+Trim(SL.Text);
   SL.Free;
end;
function TFunctionNode.SubItemDetails(List:TStrings):String;
begin
   Result:='Function.'+Name;
   if List.IndexOf(Result) = -1 then List.Add(Result);
end;
{TLookUpNode}
function TLookUpNode.GetSubGroup:String;
begin
   Result:=Trim(FSubGroup);
   if (Result = '') and
      (Trim(FBasedOn) <> '') and
      (FParentNode <> nil) and
      (FParentNode.NodeNamed(Trim(FBasedOn)) <> nil) then
      Result:=TProductNode(FParentNode.NodeNamed(Trim(FBasedOn))).SubGroup;
   if Result = '' then
      Result:='No SubGroup';
end;
function TLookUpNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
var
   S:^String;
   Temp:String;
begin
   Result:=0;
        if StrCmp(Name,'BasedOn'    ) then S:=@FBasedOn
   else if StrCmp(Name,'DontBuild'  ) then S:=@FDontBuild
   else if StrCmp(Name,'Range'      ) then S:=@FRange
   else if StrCmp(Name,'SubGroup'   ) then S:=@FSubGroup
   else S:=@Temp;

   if IndexOf(Name) = -1 then
      Result:=Add(Name);
   TCorvusNode(Objects[IndexOf(Name)]).Add(Trim(Value));
   if S^ = '' then S^:=Value else S^:=S^+','+Value;
   FIsLoaded:=False;
end;
function TLookUpNode.ListDetails:String;
var
   SL:TPackStringList;
   S:String;
   I:Integer;
   CN:TCorvusNode;
begin
   SL:=TPackStringList.Create;
   SL.Add('   '+Name+' {');
   for I:=0 to Count-1 do
   begin
      CN:=TCorvusNode(Objects[I]);
      if (CN <> nil) then
      begin
         if Trim(CN.Text) = '' then
         begin
            SL.Add('      '+Get(I));
         end
         else
         begin
            S:='      '+Get(I)+'  { ';
            SL.Add(S+CN.IDSText(Length(S),False)+' }');
         end;
      end;
   end;
   SL.Add('   }');
   Result:='   '+Trim(SL.Text);
   SL.Free;
end;
function TLookUpNode.SubItemDetails(List:TStrings):String;
begin
   Result:='LookUp.'+Name;
   if List.IndexOf(Result) = -1 then List.Add(Result);
   AddItems(FParentNode,List,FBasedOn,'LookUp');
end;
{TPickListNode}
function TPickListNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
var
   S:^String;
   Temp:String;
begin
   Temp:='';
   Result:=0;
        if StrCmp(Name,'BasedOn'    ) then S:=@FBasedOn
   else if StrCmp(Name,'DontBuild'  ) then S:=@FDontBuild
   else if StrCmp(Name,'Sorted'     ) then S:=@FSorted
   else if StrCmp(Name,'Default'    ) then S:=@FDefault
   else if StrCmp(Name,'SubGroup'   ) then S:=@FSubGroup
   else S:=@Temp;

   if IndexOf(Name) = -1 then
      Result:=Add(Name);
   TCorvusNode(Objects[IndexOf(Name)]).Add(Trim(Value));

   if S^ = '' then S^:=Value else S^:=S^+','+Value;

   FIsLoaded:=False;
end;
function TPickListNode.ListDetails:String;
var
   SL:TPackStringList;
   I:Integer;
   S:String;
   CN:TCorvusNode;
begin
   SL:=TPackStringList.Create;
   SL.Add('   '+Name+' {');
   for I:=0 to Count-1 do
   begin
      CN:=TCorvusNode(Objects[I]);
      if (CN <> nil) then
      begin
         if Trim(CN.Text) = '' then
         begin
            SL.Add('      '+Get(I));
         end
         else
         begin
            S:='      '+Get(I)+'  { ';
            SL.Add(S+CN.IDSText(Length(S),False)+' }');
         end;
      end;
   end;
   SL.Add('   }');
   Result:='   '+Trim(SL.Text);
   SL.Free;
end;
function TPickListNode.SubItemDetails(List:TStrings):String;
begin
   Result:='PickList.'+Name;
   if List.IndexOf(Result) = -1 then List.Add(Result);
   AddItems(FParentNode,List,FBasedOn,'PickList');
end;
{TDomainNode}
function TDomainNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
var
   S:^String;
   Temp:String;
begin
   Result:=0;
        if StrCmp(Name,'BasedOn'      ) then S:=@FBasedOn
   else if StrCmp(Name,'DefaultValue' ) then S:=@FDefaultValue
   else if StrCmp(Name,'Error'        ) then S:=@FError
   else if StrCmp(Name,'Format'       ) then S:=@FFormat
   else if StrCmp(Name,'Hint'         ) then S:=@FHint
   else if StrCmp(Name,'InputFrom'    ) then S:=@FInputFrom
   else if StrCmp(Name,'Locale'       ) then S:=@FLocale
   else if StrCmp(Name,'Prompt'       ) then S:=@FPrompt
   else if StrCmp(Name,'Title'        ) then S:=@FTitle
   else if StrCmp(Name,'TotalIn'      ) then S:=@FTotalIn
   else if StrCmp(Name,'SubGroup'     ) then S:=@FSubGroup
   else S:=@Temp;

   if IndexOf(Name) = -1 then
      Result:=Add(Name);
   TCorvusNode(Objects[IndexOf(Name)]).Add(Trim(Value));
   if S^ = '' then S^:=Value else S^:=S^+','+Value;

   FIsLoaded:=False;
end;
function TDomainNode.ListDetails:String;
var
   SL:TPackStringList;
   I:Integer;
   S:String;
   CN:TCorvusNode;
begin
   Sort;
   SL:=TPackStringList.Create;
   SL.Add('   '+Name+' {');
   for I:=0 to Count-1 do
   begin
      CN:=TCorvusNode(Objects[I]);
      if (CN <> nil) then
      begin
         if Trim(CN.Text) = '' then
         begin
            SL.Add('      '+Get(I));
         end
         else
         begin
            if StrCmp(Get(I),'Format') and (CN.Count > 0) then
            begin
               SL.Add(CN.ListDetails)
            end
            else
            begin
               S:='      '+Get(I)+'  { ';
               SL.Add(S+CN.IDSText(Length(S),False)+' }');
            end;
         end;
      end;
   end;
   SL.Add('   }');
   Result:='   '+Trim(SL.Text);
   SL.Free;
end;
function TDomainNode.SubItemDetails(List:TStrings):String;
var
   I:Integer;
   SL:TPackStringList;
begin
   Result:='Domain.'+Name;
   if List.IndexOf(Result) = -1 then List.Add(Result);
   AddItems(FParentNode,List,FBasedOn,'Domain');
   AddItems(FParentNode,List,FTotalIn,'Domain');
   SL:=TPackStringList.Create;
   SL.CommaText:=FFormat;
   for I:=0 to SL.Count-1 do
   begin
      if StrCmp(Copy(SL[I],1,9),'PickList.') then
      begin
         if List.IndexOf(SL[I]) = -1 then List.Add(SL[I]);
      end;
   end;
end;
{TImageNode}
destructor TImageNode.Destroy;
begin
   if FImage     <> nil then FImage.Free;
   if FItemNodes <> nil then FItemNodes.Free;
   FImage    :=nil;
   FItemNodes:=nil;
end;
procedure TImageNode.UnLink;
var
  I,Idx:Integer;
  Root:TCorvusNode;
  Basis:TCorvusNode;
  SL:TPackStringList;
begin
   if FItemNodes = nil then
      Exit;
   Root:=Self;
   while Root.FParentNode <> nil do Root:=Root.FParentNode;
   SL:=TPackStringList.Create;
   SL.CommaText:=FItems;
   if ((Self is TGroupNode  ) and ((Self as TGroupNode  ).BasedOn <> ''))
   or ((Self is TProductNode) and ((Self as TProductNode).BasedOn <> '')) then
   begin
      if (Self is TGroupNode) then
         Basis:=Root.NodeNamed('Group.'  +(Self as TGroupNode  ).FBasedOn)
      else
         Basis:=Root.NodeNamed('Product.'+(Self as TProductNode).FBasedOn);
      if Basis <> nil then
      begin
         Idx:=Basis.InvokedBy.IndexOf(Self);
         if Idx <> -1 then
            Basis.InvokedBy.Delete(Idx);
      end;
   end;
   if ((Self is TProductNode) and ((Self as TProductNode).Domains <> '')) then
   begin
      SL.CommaText:=(Self as TProductNode).Domains;
      for I:=0 to SL.Count-1 do
      begin
         Basis:=Root.NodeNamed('Domain.'+SL[I]);
         if Basis <> nil then
         begin
            Idx:=Basis.InvokedBy.IndexOf(Self);
            if Idx <> -1 then
               Basis.InvokedBy.Delete(Idx);
         end;
      end;
   end;
   if ((Self is TProductNode) and ((Self as TProductNode).Snippets <> '')) then
   begin
      SL.CommaText:=(Self as TProductNode).Snippets;
      for I:=0 to SL.Count-1 do
      begin
         Basis:=Root.NodeNamed('Snippet.'+SL[I]);
         if Basis <> nil then
         begin
            Idx:=Basis.InvokedBy.IndexOf(Self);
            if Idx <> -1 then
               Basis.InvokedBy.Delete(Idx);
         end;
      end;
   end;
   for I:=0 to SL.Count-1 do
   begin
      Basis:=Root.NodeNamed(SL[I]);
      if Basis <> nil then
      begin
         Idx:=Basis.InvokedBy.IndexOf(Self);
         if Idx <> -1 then
            Basis.InvokedBy.Delete(Idx);
      end;
   end;
   SL.Free;
   FItemNodes.Free;
   FItemNodes:=nil;
end;
function TImageNode.GetItemNodeCount:Integer;
var
  I:Integer;
  Root:TCorvusNode;
  Basis:TCorvusNode;
  SL:TPackStringList;
begin
   if FItemNodes = nil then
   begin
      Root:=Self;
      while Root.FParentNode <> nil do Root:=Root.FParentNode;
      FItemNodes:=TPackStringList.Create;
      FItemNodes.CommaText:=FItems;
      if ((Self is TGroupNode  ) and ((Self as TGroupNode  ).BasedOn <> ''))
      or ((Self is TProductNode) and ((Self as TProductNode).BasedOn <> '')) then
      begin
         if (Self is TGroupNode) then
            Basis:=Root.NodeNamed('Group.'  +(Self as TGroupNode  ).FBasedOn)
         else
            Basis:=Root.NodeNamed('Product.'+(Self as TProductNode).FBasedOn);
         if Basis <> nil then
            Basis.InvokedBy.Add(Self);
      end;
      if ((Self is TProductNode) and ((Self as TProductNode).Domains <> '')) then
      begin
         SL:=TPackStringList.Create;
         SL.CommaText:=(Self as TProductNode).Domains;
         for I:=0 to SL.Count-1 do
         begin
            Basis:=Root.NodeNamed('Domain.'+SL[I]);
            if Basis <> nil then
               Basis.InvokedBy.Add(Self);
         end;
         SL.Free;
      end;
      if ((Self is TProductNode) and ((Self as TProductNode).Snippets <> '')) then
      begin
         SL:=TPackStringList.Create;
         SL.CommaText:=(Self as TProductNode).Snippets;
         for I:=0 to SL.Count-1 do
         begin
            Basis:=Root.NodeNamed('Snippet.'+SL[I]);
            if Basis <> nil then
               Basis.InvokedBy.Add(Self);
         end;
         SL.Free;
      end;
      for I:=0 to FItemNodes.Count-1 do
      begin
         FItemNodes.Objects[I]:=Root.NodeNamed(FItemNodes[I]);
         if FItemNodes.Objects[I] <> nil then
            TCorvusNode(FItemNodes.Objects[I]).InvokedBy.Add(Self);
      end;
   end;
   Result:=FItemNodes.Count;
end;
function TImageNode.GetItemNode(Index:Integer):TCorvusNode;
begin
   GetItemNodeCount;
   if (Index >= 0) and (Index < FItemNodes.Count) then
      Result:=TCorvusNode(FItemNodes.Objects[Index])
   else
      Result:=nil;
end;
function TImageNode.GetItemNodeName(Index:Integer):String;
begin
   GetItemNodeCount;
   if (Index >= 0) and (Index < FItemNodes.Count) then
      Result:=FItemNodes[Index]
   else
      Result:='';
end;
procedure TImageNode.SetItems(Value:String);
begin
   FModified:=True;
   FItems:=Value;
end;
function TImageNode.GetImage:TBitMap;
const
   BMPWidth  = 75;
   BMPHeight = 50;
var
   S:String;
   R:TRect;
begin
   if FImage = nil then
   begin
      FImage:=TBitmap.Create;
      FImage.Width:=0;

      if FCaption     = '' then FCaption    :=FTitle      ;
      if FCaption     = '' then FCaption    :=FDescription;
      if FCaption     = '' then FCaption    :=Self.Name;
      if FTitle       = '' then FTitle      :=FCaption    ;
      if FDescription = '' then FDescription:=FCaption    ;

//      if Trim(FBitmap) = '' then
//         FBitmap:=Self.Name+'.bmp';
      if FileExists(ExtractFilePath(FFileName)+FBitmap) then
      begin
         try
            FImage.LoadFromFile(ExtractFilePath(FFileName)+FBitmap);
         except
         end;
      end;
      if FImage.Width = 0 then
      begin
         FImage.Width :=BMPWidth ;
         FImage.Height:=BMPHeight;
         with FImage.Canvas do
         begin
            Brush.Color:=clNavy;
            Brush.Style:=bsSolid;
            FillRect(Bounds(0,0,BMPWidth,BMPHeight));
            Brush.Color:=clYellow;
            Pen.Color:=clBlack;
            RoundRect(0,0,BMPWidth,BMPHeight,10,10);
            Font.Name:='Arial';
            Font.Color:=clBlack;
            Font.Size:=6;
            if FTitle <> '' then
               S:=FTitle
            else
               S:=Self.Name;
            R:=Bounds(5,5,BMPWidth-10,BMPHeight-10);
            DrawText(Handle,PChar(S),Length(S),R,DT_WORDBREAK or DT_CENTER);
         end;
      end;
   end;
   Result:=FImage;
end;
{TGroupNode}
function TGroupNode.DragOver(CompType:Integer):Boolean;
begin
   Result:=CompType in [0,1,11];
end;
procedure TGroupNode.DragDrop(Node:TCorvusNode;CompName:String);
var
   SL:TPackStringList;
   CN:TCorvusNode;
begin
   if (Node is TFunctionNode) and ((Node as TFunctionNode).FileName = 'P') then
   begin
      MessageBeep(MB_ICONEXCLAMATION);
      Exit;
   end;
   SL:=TPackStringList.Create;
   if IndexOf('Items') = -1 then
      AddObject('Items',TCorvusNode.Create('Items','',0));
   CN:=TCorvusNode(Objects[IndexOf('Items')]);
   SL.CommaText:=FItems;

   if (Node is TGroupNode) then CompName:='Group.'+CompName
   else if (Node is TProductNode) then CompName:='Product.'+CompName;

   if (CN.IndexOf(CompName) = -1) and (SL.Count < 10) then
   begin
      UnLink;
      CN.Add(CompName);
      SL.Add(CompName);
      FItems:=SL.CommaText;
      GetItemNodeCount;
   end
   else
      MessageBeep(MB_ICONEXCLAMATION);

   SL.Free;
end;
function TGroupNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
var
   S:^String;
   Temp:String;
begin
   Result:=0;
        if StrCmp(Name,'BasedOn'    ) then S:=@FBasedOn
   else if StrCmp(Name,'DontBuild'  ) then S:=@FDontBuild
   else if StrCmp(Name,'BitMap'     ) then S:=@FBitMap
   else if StrCmp(Name,'Caption'    ) then S:=@FCaption
   else if StrCmp(Name,'Description') then S:=@FDescription
   else if StrCmp(Name,'Hint'       ) then S:=@FHint
   else if StrCmp(Name,'Items'      ) then S:=@FItems
   else if StrCmp(Name,'Prompt'     ) then S:=@FPrompt
   else if StrCmp(Name,'Title'      ) then S:=@FTitle
   else if StrCmp(Name,'RegDesc'    ) then S:=@FRegDesc
   else if StrCmp(Name,'SubGroup'   ) then S:=@FSubGroup
   else S:=@Temp;

   if IndexOf(Name) = -1 then
      Result:=Add(Name);
   TCorvusNode(Objects[IndexOf(Name)]).Add(Trim(Value));
   if S^ = '' then S^:=Value else S^:=S^+','+Value;

end;
function TGroupNode.AddToTree(TreeNodes:TTreeNodes;TreeNode:TTreeNode):TTreeNode;
var
   I:Integer;
   SL:TPackStringList;
begin
   Result:=inherited AddToTree(TreeNodes,TreeNode);
   SL:=TPackStringList.Create;
   SL.CommaText:=FItems;
   for I:=0 to SL.Count-1 do
      TreeNodes.AddChildObject(Result,SL[I],nil);
   SL.Free;
end;
function TGroupNode.ListDetails:String;
var
   SL:TPackStringList;
   S:String;
   I:Integer;
   CN:TCorvusNode;
begin
   Sort;
   SL:=TPackStringList.Create;
   SL.Add('   '+Name+' {');
   for I:=0 to Count-1 do
   begin
      CN:=TCorvusNode(Objects[I]);
      if (CN <> nil) then
      begin
         if Trim(CN.Text) = '' then
         begin
            SL.Add('      '+Get(I));
         end
         else
         begin
            S:='      '+Get(I)+'  { ';
            SL.Add(S+CN.IDSText(9,True)+' }');
         end;
      end;
   end;
   SL.Add('   }');
   Result:='   '+Trim(SL.Text);
   SL.Free;
end;
function TGroupNode.SubItemDetails(List:TStrings):String;
begin
   Result:='Group.'+Name;
   if List.IndexOf(Result) = -1 then List.Add(Result);
   AddItems(FParentNode,List,FBasedOn,'Group');
   if FParentNode <> nil then
      AddItems(FParentNode,List,FItems,'');
end;
{TProductNode}
function TProductNode.DragOver(CompType:Integer):Boolean;
begin
   Result:=CompType in [1,6,7,8,9,11];
end;
procedure TProductNode.DragDrop(Node:TCorvusNode;CompName:String);
var
   SL:TPackStringList;
   CN:TCorvusNode;
begin
   if (Node is TFunctionNode) and ((Node as TFunctionNode).FileName = 'M') then
   begin
      MessageBeep(MB_ICONEXCLAMATION);
      Exit;
   end;
   SL:=TPackStringList.Create;
   if (Node is TFunctionNode) or (Node is TProductNode) then
   begin
      if IndexOf('Items') = -1 then
         AddObject('Items',TCorvusNode.Create('Items','',0));
      CN:=TCorvusNode(Objects[IndexOf('Items')]);

      if (Node is TGroupNode) then CompName:='Group.'+CompName
      else if (Node is TProductNode) then CompName:='Product.'+CompName;

      SL.CommaText:=FItems;
      if (CN.IndexOf(CompName) = -1) and (SL.Count < 10) then
      begin
         UnLink;
         CN.Add(CompName);
         SL.Add(CompName);
         FItems:=SL.CommaText;
         GetItemNodeCount;
      end
      else
         MessageBeep(MB_ICONEXCLAMATION);
   end
   else if (Node is TDomainNode) then
   begin
      if IndexOf('Domains') = -1 then
         AddObject('Domains',TCorvusNode.Create('Domains','',0));
      CN:=TCorvusNode(Objects[IndexOf('Domains')]);
      SL.CommaText:=FDomains;
      if (CN.IndexOf(CompName) = -1) then
      begin
         UnLink;
         CN.Add(CompName);
         SL.Add(CompName);
         FDomains:=SL.CommaText;
         GetItemNodeCount;
      end
      else
         MessageBeep(MB_ICONEXCLAMATION);
   end
   else if (Node is TSnippetNode) then
   begin
      if IndexOf('Snippets') = -1 then
         AddObject('Snippets',TCorvusNode.Create('Snippets','',0));
      CN:=TCorvusNode(Objects[IndexOf('Snippets')]);
      SL.CommaText:=FSnippets;
      if (CN.IndexOf(CompName) = -1) then
      begin
         UnLink;
         CN.Add(CompName);
         SL.Add(CompName);
         FSnippets:=SL.CommaText;
         GetItemNodeCount;
      end
      else
         MessageBeep(MB_ICONEXCLAMATION);
   end
//   else if (Node is TConstantNode) then
//   begin
//      if IndexOf('Constants') = -1 then
//         AddObject('Constants',TCorvusNode.Create('Constants','',0));
//      CN:=TCorvusNode(Objects[IndexOf('Constants')]);
//      SL.CommaText:=FConstants;
//      if (CN.IndexOf(CompName) = -1) then
//      begin
//         UnLink;
//         CN.Add(CompName);
//         SL.Add(CompName);
//         FConstants:=SL.CommaText;
//         GetItemNodeCount;
//      end
//      else
//         MessageBeep(MB_ICONEXCLAMATION);
//   end
   else
      MessageBeep(MB_ICONEXCLAMATION);

   SL.Free;
end;
function TProductNode.AddToTree(TreeNodes:TTreeNodes;TreeNode:TTreeNode):TTreeNode;
var
   I:Integer;
   SL:TPackStringList;
begin
   Result:=inherited AddToTree(TreeNodes,TreeNode);
   SL:=TPackStringList.Create;
   SL.CommaText:=FItems;
   for I:=0 to SL.Count-1 do
      TreeNodes.AddChildObject(Result,SL[I],nil);
   SL.Free;
end;
function TProductNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
var
   S:^String;
   Temp:String;
begin
   Result:=0;
        if StrCmp(Name,'BasedOn'    ) then S:=@FBasedOn
   else if StrCmp(Name,'Customer'   ) then S:=@FCustomer
   else if StrCmp(Name,'Description') then S:=@FDescription
   else if StrCmp(Name,'Domains'    ) then S:=@FDomains
   else if StrCmp(Name,'Endorse'    ) then S:=@FEndorse
   else if StrCmp(Name,'LogAs'      ) then S:=@FLogAs
   else if StrCmp(Name,'OCRCode'    ) then S:=@FOCRCode
   else if StrCmp(Name,'PLU'        ) then S:=@FPLU
   else if StrCmp(Name,'Price'      ) then S:=@FPrice
   else if StrCmp(Name,'PrintList'  ) then S:=@FPrintList
   else if StrCmp(Name,'Regulations') then S:=@FRegulations
   else if StrCmp(Name,'Snippets'   ) then S:=@FSnippets
   else if StrCmp(Name,'UnitPrice'  ) then S:=@FUnitPrice
   else if StrCmp(Name,'DontBuild'  ) then S:=@FDontBuild
   else if StrCmp(Name,'BitMap'     ) then S:=@FBitMap
   else if StrCmp(Name,'Caption'    ) then S:=@FCaption
   else if StrCmp(Name,'Hint'       ) then S:=@FHint
   else if StrCmp(Name,'Items'      ) then S:=@FItems
   else if StrCmp(Name,'Prompt'     ) then S:=@FPrompt
   else if StrCmp(Name,'Title'      ) then S:=@FTitle
   else if StrCmp(Name,'SubGroup'   ) then S:=@FSubGroup
   else if StrCmp(Name,'RegDesc'    ) then S:=@FRegDesc
   else if StrCmp(Name,'ProgID'     ) then S:=@FProgID
   else if StrCmp(Name,'Version'    ) then S:=@FVersion
   else if StrCmp(Name,'Account'    ) then S:=@FAccount
   else if StrCmp(Name,'Line'       ) then S:=@FLine
   else S:=@Temp;

   if IndexOf(Name) = -1 then
      Result:=Add(Name);
   TCorvusNode(Objects[IndexOf(Name)]).Add(Trim(Value));
   if S^ = '' then S^:=Value else S^:=S^+','+Value;
   FIsLoaded:=False;

{   begin
      if (Length(Value) > 1) and ((Value[1] = '\') or (Value[2] = ':')) then
         FBitMap   :=Value
      else
         FBitMap   :=ExtractFilePath(FileName)+Value;
   end }
end;
function TProductNode.GetSubGroup:String;
begin
   Result:=Trim(FSubGroup);
   if (Result = '') and
      (Trim(FBasedOn) <> '') and
      (FParentNode <> nil) and
      (FParentNode.NodeNamed(Trim(FBasedOn)) <> nil) then
      Result:=TProductNode(FParentNode.NodeNamed(Trim(FBasedOn))).SubGroup;
   if Result = '' then
      Result:='No SubGroup';
end;

function TProductNode.ListDetails:String;
var
   SL:TPackStringList;
   S:String;
   I:Integer;
   CN:TCorvusNode;
begin
   Sort;
   SL:=TPackStringList.Create;
//   SL.Add('   '+Name+' { // '+FileName+' ('+IntToStr(LineNumber)+')');
   SL.Add('   '+Name+' { ');
   for I:=0 to Count-1 do
   begin
      CN:=TCorvusNode(Objects[I]);
      if (CN <> nil) then
      begin
         if Trim(CN.Text) = '' then
         begin
            SL.Add('      '+Get(I));
         end
         else
         begin
            S:='      '+Get(I)+'  { ';
            if StrCmp(Get(I),'Customer') 
            or StrCmp(Get(I),'Endorse') 
            or StrCmp(Get(I),'PrintList') then
               SL.Add(S+CN.IDSText(Length(S),False)+' }')
            else if StrCmp(Get(I),'Domains') and (CN.Count > 0) then
               SL.Add(CN.ListDetails)
            else
               SL.Add(S+CN.IDSText(9,True)+' }');
         end;
      end;
   end;
   SL.Add('   }');
   Result:='   '+Trim(SL.Text);
   SL.Free;
end;
function TProductNode.SubItemDetails(List:TStrings):String;
var
   SL:TPackStringList;
   I:Integer;
begin
   Result:='Product.'+Name;
   if List.IndexOf(Result) = -1 then List.Add(Result);
   AddItems(FParentNode,List,FBasedOn,'Product');
   if FParentNode <> nil then
   begin
      if Application.Terminated then Exit;
      AddItems(FParentNode,List,FItems   ,'');
      AddItems(FParentNode,List,FSnippets,'Snippet');
      AddItems(FParentNode,List,FLogAs,'LogFormat');
      SL:=TPackStringList.Create;
      SL.CommaText:=FDomains;
      I:=0;
      while I < SL.Count do
      begin
         if StrCmp(Copy(SL[I],1,6),'LookUp') then
         begin
            if List.IndexOf(SL[I]) = -1 then List.Add(SL[I]);
            SL.Delete(I)
         end
         else if StrCmp(Copy(SL[I],1,9),'UnitPrice') then
            SL.Delete(I)
         else
            Inc(I);
      end;
      AddItems(FParentNode,List,SL.CommaText,'Domain');
      AddItems(FParentNode,List,FPLU,'Constant');
      SL.Free;
   end;
end;
{TSnippetNode}
function TSnippetNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
var
   S:^String;
   Temp:String;
begin
   Result:=0;
        if StrCmp(Name,'BasedOn'      ) then S:=@FBasedOn
   else if StrCmp(Name,'CodeBlock'    ) then S:=@FCodeBlock
   else if StrCmp(Name,'InsertBetween') then S:=@FInsertBetween
   else if StrCmp(Name,'SubGroup'     ) then S:=@FSubGroup
   else S:=@Temp;

   if IndexOf(Name) = -1 then
      Result:=Add(Name);
   TCorvusNode(Objects[IndexOf(Name)]).Add(Trim(Value));
   if S^ = '' then S^:=Value else S^:=S^+','+Value;
   FIsLoaded:=False;
end;
function TSnippetNode.ListDetails:String;
var
   SL:TPackStringList;
   S:String;
   I:Integer;
   CN:TCorvusNode;
begin
   SL:=TPackStringList.Create;
   SL.Add('   '+Name+' {');
   for I:=0 to Count-1 do
   begin
      CN:=TCorvusNode(Objects[I]);
      if (CN <> nil) then
      begin
         S:='      '+Get(I)+'  { ';
         if StrCmp(Get(I),'CodeBlock') then
            SL.Add(S+CN.Text+'      }')
         else
            SL.Add(S+CN.IDSText(Length(S),False)+' }');
      end;
   end;
   SL.Add('   }');
   Result:='   '+Trim(SL.Text);
   SL.Free;
end;
function TSnippetNode.SubItemDetails(List:TStrings):String;
begin
   Result:='Snippet.'+Name;
   if List.IndexOf(Result) = -1 then List.Add(Result);
   AddItems(FParentNode,List,FBasedOn,'Snippet');
end;                                         
{TUserNode}
function TUserNode.DragOver(CompType:Integer):Boolean;
begin
   Result:=CompType in [0];
end;
procedure TUserNode.DragDrop(Node:TCorvusNode;CompName:String);
var
   SL:TPackStringList;
   CN:TCorvusNode;
begin
   SL:=TPackStringList.Create;
   if IndexOf('Items') = -1 then
      AddObject('Items',TCorvusNode.Create('Items','',0));
   CN:=TCorvusNode(Objects[IndexOf('Items')]);
   SL.CommaText:=FItems;
   CompName:='Group.'+CompName;

   if (CN.IndexOf(CompName) = -1) and (SL.Count < 10) then
   begin
      UnLink;
      CN.Add(CompName);
      SL.Add(CompName);
      FItems:=SL.CommaText;
      GetItemNodeCount;
   end
   else
      MessageBeep(MB_ICONEXCLAMATION);

   SL.Free;
end;
function TUserNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
var
   S:^String;
   Temp:String;
begin
   Result:=0;
        if StrCmp(Name,'BasedOn'  ) then S:=@FBasedOn
   else if StrCmp(Name,'DontBuild') then S:=@FDontBuild
   else if StrCmp(Name,'Items'    ) then S:=@FItems
   else if StrCmp(Name,'RegDesc'  ) then S:=@FRegDesc
   else if StrCmp(Name,'ProgID'   ) then S:=@FProgID
   else if StrCmp(Name,'Version'  ) then S:=@FVersion
   else if StrCmp(Name,'GUID'     ) then S:=@FGUID
   else if StrCmp(Name,'SubGroup'   ) then S:=@FSubGroup
   else S:=@Temp;

   if IndexOf(Name) = -1 then
      Result:=Add(Name);
   TCorvusNode(Objects[IndexOf(Name)]).Add(Trim(Value));
   if S^ = '' then S^:=Value else S^:=S^+','+Value;
   FIsLoaded:=False;
end;
function TUserNode.ListDetails:String;
var
   SL:TPackStringList;
   S:String;
   I:Integer;
   CN:TCorvusNode;
begin
   Sort;
   SL:=TPackStringList.Create;
   SL.Add('   '+Name+' {');
   for I:=0 to Count-1 do
   begin
      CN:=TCorvusNode(Objects[I]);
      if (CN <> nil) then
      begin
//         if StrCmp(Get(I),'Items') then CN.Sort;
         S:='      '+Get(I)+'  { ';
         SL.Add(S+CN.IDSText(9,True)+' }');
      end;
   end;
   SL.Add('   }');
   Result:='   '+Trim(SL.Text);
   SL.Free;
end;
function TUserNode.SubItemDetails(List:TStrings):String;
begin
   Result:='User.'+Name;
   if List.IndexOf(Result) = -1 then List.Add(Result);
   AddItems(FParentNode,List,FBasedOn,'User');
   if FParentNode <> nil then
      AddItems(FParentNode,List,FItems,'');
end;
function TUserNode.GetItemNodeCount:Integer;
var
  I:Integer;
  Root:TCorvusNode;
begin
   if FItemNodes = nil then
   begin
      Root:=Self;
      while Root.FParentNode <> nil do Root:=Root.FParentNode;
      FItemNodes:=TPackStringList.Create;
      FItemNodes.CommaText:=FItems;
      for I:=0 to FItemNodes.Count-1 do
      begin
         FItemNodes.Objects[I]:=Root.NodeNamed(FItemNodes[I]);
         if FItemNodes.Objects[I] <> nil then
            TCorvusNode(FItemNodes.Objects[I]).InvokedBy.Add(Self);
      end;
   end;
   Result:=FItemNodes.Count;
end;
procedure TUserNode.UnLink;
var
  I,Idx:Integer;
  Root:TCorvusNode;
  Basis:TCorvusNode;
  SL:TPackStringList;
begin
   if FItemNodes = nil then
      Exit;
   Root:=Self;
   while Root.FParentNode <> nil do Root:=Root.FParentNode;
   SL:=TPackStringList.Create;
   SL.CommaText:=FItems;
   for I:=0 to SL.Count-1 do
   begin
      Basis:=Root.NodeNamed(SL[I]);
      if Basis <> nil then
      begin
         Idx:=Basis.InvokedBy.IndexOf(Self);
         if Idx <> -1 then
            Basis.InvokedBy.Delete(Idx);
      end;
   end;
   SL.Free;
   FItemNodes.Free;
   FItemNodes:=nil;
end;
function TUserNode.GetItemNode(Index:Integer):TGroupNode;
begin
   GetItemNodeCount;
   if (Index >= 0) and (Index < FItemNodes.Count) then
      Result:=TGroupNode(FItemNodes.Objects[Index])
   else
      Result:=nil;
end;
function TUserNode.GetItemNodeName(Index:Integer):String;
begin
   GetItemNodeCount;
   if (Index >= 0) and (Index < FItemNodes.Count) then
      Result:=FItemNodes[Index]
   else
      Result:='';
end;
procedure TUserNode.SetItems(Value:String);
begin
   FModified:=True;
   FItems:=Value;
end;
{TWorkStationNode}
function TWorkStationNode.SubItemDetails(List:TStrings):String;
begin
   Result:='WorkStation.'+Name;
   if List.IndexOf(Result) = -1 then List.Add(Result);
   AddItems(FParentNode,List,FBasedOn,'WorkStation');
   if FParentNode <> nil then
      AddItems(FParentNode,List,FItems,'');
end;

{TParseNode}
destructor TParseNode.Destroy;
begin
   InterpretTok('EndInterpretTokProcess',False,'',0);
   if FFileList <> nil then FFileList.Free;
   FFileList:=nil;
   inherited Destroy;
end;
function TParseNode.RemQuotes(S:String):String;
var
   P:PChar;
   R:PChar;
begin
   Result:='';
   if (S = '') then Exit;
   
   if IsJustQuotes(S) then 
   begin
      Result:='''''';
      Exit;
   end;
   
   P:=PChar(S);
   SetLength(Result,Length(S)+2);
   R:=PChar(Result);
   while P^ <> #0 do
   begin
      if P^ = '''' then Inc(P);
      if P^ <> #0 then
      begin
         R^:=P^;         
         Inc(P);
         Inc(R);
      end;
   end;
   R^:=P^;
   SetLength(Result,(R-PChar(Result)));
end;
function TParseNode.GetToken(var P:PChar;var IsIdent:Boolean;var LineNumber:Integer):String;
var
  Last:Char;
  IsCodeBlock : Boolean;  //dont remove quotes
begin
  IsCodeBlock := False; //reset
  Result:='';
  IsIdent:=False;
  while ((P^ <> #0) and (P^ <= ' ')) or (P^ = ',') do  // remove whitespace
  begin
     if P^ = #10 then begin Inc(LineNumber); Inc(TotalLines); end;
     Inc(P);
  end;
  while (P^ = '/') do // remove commenting
  begin
     Inc(P);
     if (P^ = '/') then // single line commenting '// .. EOL'
     begin
        while (P^ <> #0) and (P^ <> #10) do Inc(P);
     end
     else // multiple line commenting '/* .. */'
     begin
        Inc(P);
        while (P^ <> #0) do 
        begin
           if (P^ = '*') and ((P+1)^ = '/') then 
           begin
              Inc(P,2);
              break;
           end;
           if P^ = #10 then begin Inc(LineNumber); Inc(TotalLines); end;
           Inc(P);
        end;
     end;
     while ((P^ <> #0) and (P^ <= ' ')) or (P^ = ',') do  // remove whitespace
     begin
        if P^ = #10 then begin Inc(LineNumber); Inc(TotalLines); end;
        Inc(P);
     end;
  end;
  TokenPtr := P;
  case P^ of
    'A'..'Z', 'a'..'z', '_', #$81..#$fe:
      begin
        Inc(P);
        while P^ in ['0'..'9','A'..'Z','a'..'z','_','-',#$81..#$fe] do Inc(P);
        IsIdent:=True;
      end;
    '[':
      begin
        Inc(P);
        if P^ = '*' then
        begin
           IsCodeBlock := True; //dont remove quotes in RemQuotes
           Inc(P);
           Last:=' ';
           while True do
           begin
             if P^ = #0 then Exit;
             if P^ = #10 then begin Inc(LineNumber); Inc(TotalLines); end;
             if (P^ = ']') and (Last = '*') then Break;
             Last:=P^;
             Inc(P);
           end;
           Inc(P);
        end;
      end;
    '''':
      begin
        Inc(P);
        while True do
        begin
          if P^ = #0 then Exit;
          if P^ = #10 then begin Inc(LineNumber); Inc(TotalLines); end;
          if P^ = '''' then
          begin
            Inc(P);
            if P^ <> '''' then Break;
          end;
          Inc(P);
        end;
      end;
    '+','-','0'..'9':
      begin
        Inc(P);                                                                                 
        while P^ in ['0'..'9', '.', 'e', 'E', '+', '-'] do Inc(P);
      end;
    '{','}':
      begin
        Inc(P);
      end;
    '<':
      begin
        Inc(P);
        case P^ of
          '=':
            begin
              Inc(P);
            end;
          '>':
            begin
              Inc(P);
            end;
        end;
      end;
    '=':
      begin
        Inc(P);
      end;
    '>':
      begin
        Inc(P);
        if P^ = '=' then
        begin
          Inc(P);
        end
      end;
    else
       Inc(P);
  end;
  if P <> TokenPtr then
  begin
     SetString(Result,TokenPtr,P-TokenPtr);
     If not IsCodeBlock then
       Result:=RemQuotes(Result);
  end;
end;

function TParseNode.NewCompType(CurrCompType:TCorvusNode;CurrCompTypeName,Tok,FileName:String;LineNumber:Integer):Integer;
begin
   if Pos('.'+Tok+'.','.BuildOptions.Constants.Domains.Groups.LogFormats.LookUps.PickLists.Products.Snippets.Users.WorkStations.') <> 0 then
   begin
      if (ErrorForm <> nil) then 
         ErrorForm.Errors.Lines.Add(CurrCompTypeName+' contains component named '+Tok+' in File '+FileName+'('+IntToStr(LineNumber)+')');
   end;
   
        if CurrCompTypeName = 'BuildOptions' then Result:=CurrCompType.AddObject(Tok,TBuildOptionsNode.Create(Tok,FileName,LineNumber))
   else if CurrCompTypeName = 'Functions'    then Result:=CurrCompType.AddObject(Tok,TFunctionNode    .Create(Tok,FileName,LineNumber))
   else if CurrCompTypeName = 'Constants'    then Result:=CurrCompType.AddObject(Tok,TConstantNode    .Create(Tok,FileName,LineNumber))
   else if CurrCompTypeName = 'LogFormats'   then Result:=CurrCompType.AddObject(Tok,TLogFormatNode   .Create(Tok,FileName,LineNumber))
   else if CurrCompTypeName = 'Domains'      then Result:=CurrCompType.AddObject(Tok,TDomainNode      .Create(Tok,FileName,LineNumber))
   else if CurrCompTypeName = 'Groups'       then Result:=CurrCompType.AddObject(Tok,TGroupNode       .Create(Tok,FileName,LineNumber))
   else if CurrCompTypeName = 'LookUps'      then Result:=CurrCompType.AddObject(Tok,TLookUpNode      .Create(Tok,FileName,LineNumber))
   else if CurrCompTypeName = 'PickLists'    then Result:=CurrCompType.AddObject(Tok,TPickListNode    .Create(Tok,FileName,LineNumber))
   else if CurrCompTypeName = 'Products'     then Result:=CurrCompType.AddObject(Tok,TProductNode     .Create(Tok,FileName,LineNumber))
   else if CurrCompTypeName = 'Snippets'     then Result:=CurrCompType.AddObject(Tok,TSnippetNode     .Create(Tok,FileName,LineNumber))
   else if CurrCompTypeName = 'Users'        then Result:=CurrCompType.AddObject(Tok,TUserNode        .Create(Tok,FileName,LineNumber))
   else if CurrCompTypeName = 'WorkStations' then Result:=CurrCompType.AddObject(Tok,TWorkStationNode .Create(Tok,FileName,LineNumber))
   else                                           Result:=CurrCompType.AddObject(Tok,TCorvusNode      .Create(Tok,FileName,LineNumber));
   
end;

procedure TParseNode.InterpretTok(Tok:String;IsIdent:Boolean;FileName:String;LineNumber:Integer);
const
   Depth           :Integer    =0  ;
   CurrCompType    :TCorvusNode=nil;
   CurrComp        :TCorvusNode=nil;
   CurrAttrib      :TCorvusNode=nil;
   CurrParam       :TCorvusNode=nil;
   CurrElem0       :TCorvusNode=nil;
   CurrElem1       :TCorvusNode=nil;
   CurrElem2       :TCorvusNode=nil;
   CurrElem3       :TCorvusNode=nil;
   CurrCompTypeName:String     ='' ;
   CurrCompName    :String     ='' ;
   CurrAttribName  :String     ='' ;
   CurrParamName   :String     ='' ;
   CurrElem0Name   :String     ='' ;
   CurrElem1Name   :String     ='' ;
   CurrElem2Name   :String     ='' ;
   CurrElem3Name   :String     ='' ;
var
   CompIndex :Integer;
   LineIndex :Integer;
   ParamIndex:Integer;
   ElemIndex :Integer; 
begin
   Tok:=Trim(Tok);
   if Tok = '' then Exit;

   if Tok = 'EndInterpretTokProcess' then
   begin
      Depth           :=0  ;
      CurrCompType    :=nil;
      CurrComp        :=nil;
      CurrAttrib      :=nil;
      CurrParam       :=nil;
      CurrElem0       :=nil;
      CurrElem1       :=nil;
      CurrElem2       :=nil;
      CurrElem3       :=nil;
      CurrCompTypeName:='' ;
      CurrCompName    :='' ;
      CurrAttribName  :='' ;
      CurrParamName   :='' ;
      CurrElem0Name   :='' ;
      CurrElem1Name   :='' ;
      CurrElem2Name   :='' ;
      CurrElem3Name   :='' ;
      Exit;
   end;

   if Tok = '{' then
   begin
      Inc(Depth);
   end
   else if Tok = '}' then
   begin
      Dec(Depth);
   end
   else
   begin
      case Depth of
         0 : begin
               CompIndex:=IndexOf(Tok);
               if CompIndex = -1 then
               begin
                  CompIndex:=AddObject(Tok,TCorvusNode.Create(Tok,FileName,LineNumber));
                  if (ErrorForm <> nil) then 
                     ErrorForm.Errors.Lines.Add('Top Level component named '+Tok+' in File '+FileName+'('+IntToStr(LineNumber)+')');
               end;
               CurrCompType:=TCorvusNode(Objects[CompIndex]);
               CurrCompTypeName:=Tok;
             end;
          1: begin
                CompIndex:=CurrCompType.IndexOf(Tok);
                if CompIndex = -1 then
                   CompIndex:=NewCompType(CurrCompType,CurrCompTypeName,Tok,FileName,LineNumber);
                CurrComp:=TCorvusNode(CurrCompType.Objects[CompIndex]);
                CurrCompName:=Tok;

                if not IsIdent then
                  if (ErrorForm <> nil) then
                   ErrorForm.Errors.Lines.Add(CurrCompTypeName+' contains component '+Tok+' in File '+FileName+'('+IntToStr(LineNumber)+')');
             end;
          2: begin
                LineIndex:=CurrComp.IndexOf(Tok);    // find attribute in component
                if LineIndex = -1 then
                   LineIndex:=CurrComp.AddObject(Tok,TCorvusNode.Create(Tok,FileName,LineNumber));
                CurrAttrib:=TCorvusNode(CurrComp.Objects[LineIndex]);
                CurrAttribName:=Tok;
             end;
          3: begin
                CurrComp.AddAttr(FileName,LineNumber,CurrAttribName,Tok);
                ParamIndex:=CurrAttrib.IndexOf(Tok);    // find attribute in component
                if ParamIndex = -1 then
                   ParamIndex:=CurrAttrib.AddObject(Tok,TCorvusNode.Create(Tok,FileName,LineNumber));
                CurrParam:=TCorvusNode(CurrAttrib.Objects[ParamIndex]);
                CurrParamName:=Tok;
             end;
          4: begin
                if CurrParam = nil then
                begin
                   CurrParam:=TCorvusNode.Create(CurrParamName,FileName,LineNumber);
                   ElemIndex:=CurrAttrib.IndexOf(CurrParamName);
                   if ElemIndex = -1 then
                      CurrAttrib.AddObject(CurrParamName,CurrParam)
                   else
                      CurrAttrib.Objects[ElemIndex]:=CurrParam;
                end;
                CurrAttrib.AddAttr(FileName,LineNumber,CurrParamName,Tok);
                ElemIndex:=CurrParam.IndexOf(Tok);
                if ElemIndex = -1 then
                   ElemIndex:=CurrParam.AddObject(Tok,TCorvusNode.Create(Tok,FileName,LineNumber));
                CurrElem0:=TCorvusNode(CurrParam.Objects[ElemIndex]);
                CurrElem0Name:=Tok;
             end;
          5: begin
                if CurrElem0 = nil then
                begin
                   CurrElem0:=TCorvusNode.Create(CurrElem0Name,FileName,LineNumber);
                   ElemIndex:=CurrParam.IndexOf(CurrElem0Name);
                   if ElemIndex = -1 then
                      CurrParam.AddObject(CurrElem0Name,CurrElem0)
                   else
                      CurrParam.Objects[ElemIndex]:=CurrElem0;
                end;
                CurrParam.AddAttr(FileName,LineNumber,CurrElem0Name,Tok);
                ElemIndex:=CurrElem0.IndexOf(Tok);
                if ElemIndex = -1 then
                   ElemIndex:=CurrElem0.AddObject(Tok,TCorvusNode.Create(Tok,FileName,LineNumber));
                CurrElem1:=TCorvusNode(CurrElem0.Objects[ElemIndex]);
                CurrElem1Name:=Tok;
             end;
          6: begin
                if CurrElem1 = nil then
                begin
                   CurrElem1:=TCorvusNode.Create(CurrElem1Name,FileName,LineNumber);
                   ElemIndex:=CurrElem0.IndexOf(CurrElem1Name);
                   if ElemIndex = -1 then
                      CurrElem0.AddObject(CurrElem1Name,CurrElem1)
                   else
                      CurrElem0.Objects[ElemIndex]:=CurrElem1;
                end;
                CurrElem0.AddAttr(FileName,LineNumber,CurrElem1Name,Tok);
                ElemIndex:=CurrElem1.IndexOf(Tok);
                if ElemIndex = -1 then
                   ElemIndex:=CurrElem1.AddObject(Tok,TCorvusNode.Create(Tok,FileName,LineNumber));
                CurrElem2:=TCorvusNode(CurrElem1.Objects[ElemIndex]);
                CurrElem2Name:=Tok;
             end;
          7: begin
                if CurrElem2 = nil then
                begin
                   CurrElem2:=TCorvusNode.Create(CurrElem2Name,FileName,LineNumber);
                   ElemIndex:=CurrElem1.IndexOf(CurrElem2Name);
                   if ElemIndex = -1 then
                      CurrElem1.AddObject(CurrElem2Name,CurrElem2)
                   else
                      CurrElem1.Objects[ElemIndex]:=CurrElem2;
                end;
                CurrElem1.AddAttr(FileName,LineNumber,CurrElem2Name,Tok);
                ElemIndex:=CurrElem2.IndexOf(Tok);
                if ElemIndex = -1 then
                   ElemIndex:=CurrElem2.AddObject(Tok,TCorvusNode.Create(Tok,FileName,LineNumber));
                CurrElem3:=TCorvusNode(CurrElem2.Objects[ElemIndex]);
                CurrElem3Name:=Tok;
             end;
          else
          begin
             CurrElem2.AddAttr(FileName,LineNumber,CurrElem3Name,Tok);
          end;
      end
   end;
end;
procedure TParseNode.Parse(Path,FileName:String;Data:PChar;LineNumber:Integer);
var
   Tok:String;
   IsIdent:Boolean;
begin
   while (Data^ <> #0) do
   begin
      Tok:=GetToken(Data,IsIdent,LineNumber);
      if Tok = 'Include' then
      begin
         Tok:=GetToken(Data,IsIdent,LineNumber);
         if Tok <> '' then
            ParseFile(Path,Tok,1);
      end
      else
      begin
         InterpretTok(Tok,IsIdent,FileName,LineNumber);
      end;
   end;
end;
procedure TParseNode.ParseFile(Path,FileName:String;LineNumber:Integer);
var
   MS:TMemoryStream;
   A:Integer;
   SearchRec:TSearchRec;
begin
   if (FileName = '') then Exit;
   if FileName[1] = #39 then
      FileName:=Copy(FileName,2,Length(FileName)-2);
   if (Path <> '')  and (FileName[1] <> '\') and (Length(FileName) > 2) and (FileName[2] <> ':') then
   begin
      if Path[Length(Path)] = '\' then
         FileName:=Path+FileName
      else
         FileName:=Path+'\'+FileName;
   end
   else
      Path:=ExtractFilePath(FileName);

   if FileExists(FileName) then
   begin
      if FFileList = nil then FFileList:=TStringList.Create;
      if FFileList.IndexOf(FileName) = -1 then
      begin
         if FindFirst(FileName,$FFFF,SearchRec) = 0 then
            FFileList.AddObject(FileName,TObject(SearchRec.Time xor SearchRec.Size));
         FindClose(SearchRec);

         MS:=TMemoryStream.Create;
         MS.LoadFromFile(FileName);
         MS.Position:=MS.Size;
         A:=0;
         MS.Write(A,sizeof(Integer)); // zero terminate
         MS.Position:=0;
         try
            Parse(Path,FileName,MS.Memory,LineNumber);
         finally
            MS.Free;
         end;
      end
      else
      begin
         if (ErrorForm <> nil) then 
            ErrorForm.Errors.Lines.Add('File '+FileName+' Included more than once');
      end;
   end
   else
   begin
      if (ErrorForm <> nil) then 
         ErrorForm.Errors.Lines.Add('Can''t Open file '+FileName);
   end;
end;
{TRootNode}
procedure TRootNode.SaveAs(Path,BaseName:String);
var
   SL:TPackStringList;
   SGSL:TPackStringList;
   LSGSL:TPackStringList;
   I,J:Integer;
begin
   if not FileExists(Path+'\IDS') then ForceDirectories(Path+'\IDS');
   if not FileExists(Path+'\Images') then ForceDirectories(Path+'\Images');
   SL:=TPackStringList.Create;
   SGSL:=TPackStringList.Create;
   LSGSL:=TPackStringList.Create;
   SL.Text:=FBuildOptions.ListDetails; SL.SaveToFile(Path+'\IDS\'+BaseName+' BuildOptions.ids' );
   SL.Clear; SL.Add('Constants    {'); for I:=0 to FConstants   .Count-1 do  SL.Add(TCorvusNode(FConstants   .Objects[I]).ListDetails); SL.Add('}'); SL.SaveToFile(Path+'\IDS\'+BaseName+' Constants.ids'    );
   SL.Clear; SL.Add('Domains      {'); for I:=0 to FDomains     .Count-1 do  SL.Add(TCorvusNode(FDomains     .Objects[I]).ListDetails); SL.Add('}'); SL.SaveToFile(Path+'\IDS\'+BaseName+' Domains.ids'      );
   SL.Clear; SL.Add('Groups       {'); for I:=0 to FGroups      .Count-1 do  SL.Add(TCorvusNode(FGroups      .Objects[I]).ListDetails); SL.Add('}'); SL.SaveToFile(Path+'\IDS\'+BaseName+' Groups.ids'       );
   SL.Clear; SL.Add('LogFormats   {'); for I:=0 to FLogFormats  .Count-1 do  SL.Add(TCorvusNode(FLogFormats  .Objects[I]).ListDetails); SL.Add('}'); SL.SaveToFile(Path+'\IDS\'+BaseName+' LogFormats.ids'   );
   SL.Clear; SL.Add('PickLists    {'); for I:=0 to FPickLists   .Count-1 do  SL.Add(TCorvusNode(FPickLists   .Objects[I]).ListDetails); SL.Add('}'); SL.SaveToFile(Path+'\IDS\'+BaseName+' PickLists.ids'    );
   SL.Clear; SL.Add('Snippets     {'); for I:=0 to FSnippets    .Count-1 do  SL.Add(TCorvusNode(FSnippets    .Objects[I]).ListDetails); SL.Add('}'); SL.SaveToFile(Path+'\IDS\'+BaseName+' Snippets.ids'     );
   SL.Clear; SL.Add('Users        {'); for I:=0 to FUsers       .Count-1 do  SL.Add(TCorvusNode(FUsers       .Objects[I]).ListDetails); SL.Add('}'); SL.SaveToFile(Path+'\IDS\'+BaseName+' Users.ids'        );
   SL.Clear; SL.Add('WorkStations {'); for I:=0 to FWorkStations.Count-1 do  SL.Add(TCorvusNode(FWorkStations.Objects[I]).ListDetails); SL.Add('}'); SL.SaveToFile(Path+'\IDS\'+BaseName+' WorkStations.ids' );

   for I:=0 to FGroups.Count-1 do
   begin
      try
         if (TGroupNode(FGroups.Objects[I]).Image <> nil) and (TGroupNode(FGroups.Objects[I]).FBitmap <> '') then
            TGroupNode(FGroups.Objects[I]).Image.SaveToFile(Path+'\Images\'+ExtractFileName(TGroupNode(FGroups.Objects[I]).FBitmap));
      except
      end;
   end;
   for I:=0 to FProducts.Count-1 do
   begin
      try
         if (TProductNode(FProducts.Objects[I]).Image <> nil) and (TProductNode(FProducts.Objects[I]).FBitmap <> '') then
            TProductNode(FProducts.Objects[I]).Image.SaveToFile(Path+'\Images\'+ExtractFileName(TProductNode(FProducts.Objects[I]).FBitmap));
      except
      end;
      if SGSL.IndexOf(TProductNode(FProducts.Objects[I]).SubGroup) = -1 then
         SGSL.Add(TProductNode(FProducts.Objects[I]).SubGroup);
   end;
   for J:=0 to SGSL.Count-1 do
   begin
      SL.Clear; SL.Add('Products { ');
      for I:=0 to FProducts    .Count-1 do
      begin
         if TProductNode(FProducts.Objects[I]).SubGroup = SGSL[J] then
            SL.Add(TCorvusNode(FProducts.Objects[I]).ListDetails);
      end;
      SL.Add('}');
      SL.SaveToFile(Path+'\IDS\'+BaseName+' '+SGSL[J]+' Products.ids'     );
   end;

   for I:=0 to FLookUps.Count-1 do
      if LSGSL.IndexOf(TLookUpNode(FLookUps.Objects[I]).SubGroup) = -1 then
         LSGSL.Add(TLookUpNode(FLookUps.Objects[I]).SubGroup);
   for J:=0 to LSGSL.Count-1 do
   begin
      SL.Clear; SL.Add('LookUps     {');
      for I:=0 to FLookUps    .Count-1 do
      begin
         if TLookUpNode(FLookUps.Objects[I]).SubGroup = LSGSL[J] then
            SL.Add(TCorvusNode(FLookUps.Objects[I]).ListDetails);
      end;
      SL.Add('}');
      SL.SaveToFile(Path+'\IDS\'+BaseName+' '+LSGSL[J]+' LookUps.ids'     );
   end;

   SL.Clear;
   SL.Add('Include '''+BaseName+' BuildOptions.ids''' );
   SL.Add('Include '''+BaseName+' Constants.ids'''    );
   SL.Add('Include '''+BaseName+' Domains.ids'''      );
   SL.Add('Include '''+BaseName+' Groups.ids'''       );
   SL.Add('Include '''+BaseName+' LogFormats.ids'''   );
   for J:=0 to LSGSL.Count-1 do
      SL.Add('Include '''+BaseName+' '+LSGSL[J]+' LookUps.ids'''     );
   SL.Add('Include '''+BaseName+' PickLists.ids'''    );
   for J:=0 to SGSL.Count-1 do
      SL.Add('Include '''+BaseName+' '+SGSL[J]+' Products.ids'''     );
   SL.Add('Include '''+BaseName+' Snippets.ids'''     );
   SL.Add('Include '''+BaseName+' Users.ids'''        );
   SL.Add('Include '''+BaseName+' WorkStations.ids''' );
   SL.SaveToFile(Path+'\IDS\'+BaseName+'.ids' );
   SGSL.Free;
   LSGSL.Free;
   SL.Free;
end;
constructor TRootNode.Create(Name,FileName:String;LineNumber:Integer);
begin
   inherited Create(Name,FileName,LineNumber);
   FFunctions   :=TCorvusNode.Create('Functions'   ,FileName,LineNumber); AddObject('Functions'   ,FFunctions   );
   FBuildOptions:=TCorvusNode.Create('BuildOptions',FileName,LineNumber); AddObject('BuildOptions',FBuildOptions);
   FConstants   :=TCorvusNode.Create('Constants'   ,FileName,LineNumber); AddObject('Constants'   ,FConstants   );
   FDomains     :=TCorvusNode.Create('Domains'     ,FileName,LineNumber); AddObject('Domains'     ,FDomains     );
   FGroups      :=TCorvusNode.Create('Groups'      ,FileName,LineNumber); AddObject('Groups'      ,FGroups      );
   FLogFormats  :=TCorvusNode.Create('LogFormats'  ,FileName,LineNumber); AddObject('LogFormats'  ,FLogFormats  );
   FLookUps     :=TCorvusNode.Create('LookUps'     ,FileName,LineNumber); AddObject('LookUps'     ,FLookUps     );
   FPickLists   :=TCorvusNode.Create('PickLists'   ,FileName,LineNumber); AddObject('PickLists'   ,FPickLists   );
   FProducts    :=TCorvusNode.Create('Products'    ,FileName,LineNumber); AddObject('Products'    ,FProducts    );
   FSnippets    :=TCorvusNode.Create('Snippets'    ,FileName,LineNumber); AddObject('Snippets'    ,FSnippets    );
   FUsers       :=TCorvusNode.Create('Users'       ,FileName,LineNumber); AddObject('Users'       ,FUsers       );
   FWorkStations:=TCorvusNode.Create('WorkStations',FileName,LineNumber); AddObject('WorkStations',FWorkStations);
end;
function TRootNode.NodeNamed(Name:String):TCorvusNode;
begin
        if StrCmp(Copy(Name,1,4),'Func') then  Result:=FFunctions   .NodeNamed(Copy(Name,10,Length(Name)))
   else if StrCmp(Copy(Name,1,4),'Buil') then  Result:=FBuildOptions.NodeNamed(Copy(Name,13,Length(Name)))
   else if StrCmp(Copy(Name,1,4),'Cons') then  Result:=FConstants   .NodeNamed(Copy(Name,10,Length(Name)))
   else if StrCmp(Copy(Name,1,4),'Doma') then  Result:=FDomains     .NodeNamed(Copy(Name, 8,Length(Name)))
   else if StrCmp(Copy(Name,1,4),'Grou') then  Result:=FGroups      .NodeNamed(Copy(Name, 7,Length(Name)))
   else if StrCmp(Copy(Name,1,4),'LogF') then  Result:=FLogFormats  .NodeNamed(Copy(Name,11,Length(Name)))
   else if StrCmp(Copy(Name,1,4),'Look') then  Result:=FLookUps     .NodeNamed(Copy(Name, 8,Length(Name)))
   else if StrCmp(Copy(Name,1,4),'Pick') then  Result:=FPickLists   .NodeNamed(Copy(Name,10,Length(Name)))
   else if StrCmp(Copy(Name,1,4),'Prod') then  Result:=FProducts    .NodeNamed(Copy(Name, 9,Length(Name)))
   else if StrCmp(Copy(Name,1,4),'Swap') then  Result:=FProducts    .NodeNamed(Copy(Name, 8,Length(Name)))
   else if StrCmp(Copy(Name,1,4),'Snip') then  Result:=FSnippets    .NodeNamed(Copy(Name, 9,Length(Name)))
   else if StrCmp(Copy(Name,1,4),'User') then  Result:=FUsers       .NodeNamed(Copy(Name, 6,Length(Name)))
   else if StrCmp(Copy(Name,1,4),'Work') then  Result:=FWorkStations.NodeNamed(Copy(Name,13,Length(Name)))
   else                                        Result:=nil;
end;
function TRootNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
begin
   Result:=0;
end;
function TRootNode.ListDetails:String;
begin
   Result:='';
end;
function TRootNode.SubItemDetails(List:TStrings):String;
begin
   Result:='';
end;

end.
