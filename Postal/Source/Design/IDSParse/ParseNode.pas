unit ParseNode;

interface

uses
  clipbrd,
  Stringutil,
   Windows,Forms,Classes,Graphics,SysUtils,Controls,Dialogs,ParseErrorFU;
   
const
   ttDomains      = 'Domains';
   ttCaption      = 'Caption';
   ttConstants    = 'Constants';
   ttSnippets     = 'Snippets';
   ttProducts     = 'Products';
   ttGroups       = 'Groups';
   ttLookUps      = 'LookUps';
   ttPickLists    = 'PickLists';
   ttUsers        = 'Users';
   ttWorkStations = 'WorkStations';
   ttBuildOptions = 'BuildOptions';
   ttTitle        = 'Title';
   ttBitmap       = 'Bitmap';
   ttItems        = 'Items';
   ttError        = 'Error';
   ttDefaultValue = 'DefaultValue';
   ttFormat       = 'Format';
   ttTotalIn      = 'TotalIn';
   ttInputFrom    = 'InputFrom';
   ttLocale       = 'Locale';
   ttGUID         = 'GUID';
   ttRegDesc      = 'RegDesc';
   ttProgID       = 'ProgID';
   ttVersion      = 'Version';
   ttBarCode      = 'BarCode';
   ttDescription  = 'Description';
   ttEndDate      = 'EndDate';
   ttHighDays     = 'HighDays';
   ttMCRCode      = 'MCRCode';
   ttOCRCode      = 'OCRCode';
   ttOtherCode    = 'OtherCode';
   ttRegulations  = 'Regulations';
   ttStartDate    = 'StartDate';
   ttUseDays      = 'UseDays';
   ttTaxes        = 'Taxes';
   ttMOPs         = 'MOPs';
   ttAvailAfterEOD= 'AvailAfterEOD';
   ttPrompt       = 'Prompt';
   ttProjectFiles = 'ProjectFiles';
   ttDontBuild    = 'DontBuild';
   ttHint         = 'Hint';
   ttUnitQuantity = 'UnitQuantity';
   ttMaxQuantity  = 'MaxQuantity';
   ttMinQuantity  = 'MinQuantity';
   ttPLU          = 'PLU';
   ttUnitPrice    = 'UnitPrice';
   ttPrintList    = 'PrintList';
   ttFillList     = 'FillList';
   ttEndorse      = 'Endorse';
   ttCustomer     = 'Customer';
   ttSubGroup     = 'SubGroup';
   ttLogAs        = 'LogAs';
   ttLogFormats   = 'LogFormats';
   ttSrcDir       = 'RootSrcOutputDir';
   ttEXEDir       = 'EXEOutputDir';
   ttDCUDir       = 'DCUOutputDir';
   ttBldAll       = 'BuildAllUnits';
   ttCmdLine      = 'CommandLine';
   ttAliases      = 'Aliases';
   ttLibPath      = 'LibraryPath';
   ttSrchPath     = 'SearchPath';
   ttPackages     = 'Packages';
   ttProductIn    = 'ProductInput';
   ttGroupIn      = 'GroupInput';
   ttUGroupIn     = 'UserInput';
   ttWGroupIn     = 'WorkStationInput';
   ttLookUpIn     = 'LookUpInput';
   ttPickListIn   = 'PickListInput';
   ttDependencies = 'Dependencies';
   ttOutputFile   = 'ConstantOutputFile';
   ttCurrDecimal  = 'CurrencyDecimals';

type             

  TTermType = (ttIgnore,ttContinue,ttReload,ttAbort);
  
  TConstantsNode = class;
{$M+}
{$WARNINGS OFF}
  TNodeObject = class(TComponent)
  protected 
      procedure AddObjectToString(Obj:TNodeObject;var Str:String);
  public
     constructor Create; // reintroduce; Delphi5 only
  published
     property Name;
  end;
{$WARNINGS ON}
{$M-}
  TNode = class(TNodeObject)
  private
     FModified:Boolean;
     FModText:String;
     FWidth :Integer;
     FIndent :Integer;
     FExpWidth :Integer;
     FHeight:Integer;
     FXCoord:Integer;
     FYCoord:Integer;
     FNodeName:String;
     FFileName:String;
     FLineNo:Integer;
     FDPtr:PChar;
     FEndDPtr:PChar;
     FNodeList:TStringList;
     FCurrentNode:TNode;
     FParentNode:TNode;
     FIsExpanded:Boolean;
     FIsSelected:Boolean;
     FHasChild  :Boolean;
     FBaseColor:TColor;
     FBasisNode:TNode;
     FUsedBy :String;
     function GetNode(Index:Integer):TNode;
     function GetName(Index:Integer):String;
     procedure SetNodeName(Value:String);
     procedure SetNName(Index:Integer;Value:String);
     function GetCount:Integer;
     procedure GetStringData(var Data:String;Depth:Integer);
     procedure GetObjectData(var Data:String);
     function RootNode:TNode;
  protected
     procedure SetConstants(Constants:TConstantsNode);
     procedure SetExpanded(Value:Boolean); virtual;
     procedure SetSelected(Value:Boolean); virtual;
  public
     function GetItemData(Name:String;MultiLine:Boolean):String; virtual;
     constructor Create(Parent:TNode;Name,FileName:String); virtual;
     destructor Destroy; override;
     procedure ResetUsedBy;
     function Add(NodeName,FileName:String):Integer;
     procedure Delete(NodeName:String);
     function SelectNode(NodeName:String):TNode;
     procedure Sort;
     function FindNode(X,Y:Integer;var OnExpand:Boolean):TNode;
     function AsString:String;
     function AsObject:String;
     procedure Expander(Canvas:TCanvas;FXCoord,FYCoord,FExpWidth:Integer;HasChild,IsExpanded:Boolean);
     procedure DrawNode(Canvas:TCanvas;JustSubs:Boolean); virtual;
     function GetWidth(Canvas:TCanvas;Indent:Integer):Integer; virtual;
     function GetHeight(Canvas:TCanvas;YOffset:Integer):Integer; virtual;
     procedure SetDataElements(RootNode:TNode); virtual;
     property Modified:Boolean read FModified write FModified;
     property ModText:String read FModText write FModText;
     property DPtr:PChar read FDPtr write FDPtr;
     property EndDPtr:PChar read FEndDPtr write FEndDPtr;
     property LineNo:Integer read FLineNo write FLineNo;
     property Node[Index:Integer]:TNode read GetNode; default;
     property Name[Index:Integer]:String read GetName write SetNName;
     property Count:Integer read GetCount;
     property FileName:String read FFileName write FFileName;
     property CurrentNode:TNode read FCurrentNode write FCurrentNode;
     property ParentNode:TNode read FParentNode write FParentNode;
     property IsExpanded:Boolean read FIsExpanded write SetExpanded;
     property IsSelected:Boolean read FIsSelected write SetSelected;
     property BasisNode:TNode read FBasisNode write FBasisNode;
     property HasChild  :Boolean read FHasChild   write FHasChild  ;
     property UsedBy    :String read FUsedBy write FUsedBy;
     property BaseColor :TColor read FBaseColor write FBaseColor;
  published
     property NodeName:String read FNodeName write SetNodeName;
  end;
  TBldCompNode = class(TNode)
  private
     FDirectory:String;
     FProjFile :String;
     FConstFile :String;
     FAutoFile :String;
     FFormFiles:TStringList;
     FDependencies:TStringList;
  public
     constructor Create(Parent:TNode;Name,FileName:String); override;
     destructor Destroy; override;
     procedure SetDataElements(RootNode:TNode); override;
  published
     property Directory   :String      read FDirectory    write FDirectory;
     property ProjFile    :String      read FProjFile     write FProjFile ;
     property ContsFile   :String      read FConstFile    write FConstFile;
     property AutoFile    :String      read FAutoFile     write FAutoFile ;
     property FormFiles   :TStringList read FFormFiles    write FFormFiles;
     property Dependencies:TStringList read FDependencies write FDependencies;
  end;
  TOptionsNode = class(TNode)
  private
     FSrcDir   :String;
     FEXEDir   :String;
     FDCUDir   :String;
     FBldAll   :String;
     FCmdLine  :String;
     FAliases  :TStringList;
     FLibPath  :TStringList;
     FSrchPath :TStringList;
     FPackages :TStringList;
     FProduct  :TBldCompNode;
     FGroup    :TBldCompNode;
     FUGroup   :TBldCompNode;
     FWGroup   :TBldCompNode;
     FLookUp   :TBldCompNode;
     FPickList :TBldCompNode;
     FOutConstName:String;
     FCurrDecimals:string ;     
  public
     constructor Create(Parent:TNode;Name,FileName:String); override;
     destructor Destroy; override;
     procedure SetDataElements(RootNode:TNode); override;
  published
     property OutConstName:String    read FOutConstName write FOutConstName;
     property CurrDecimals:string    read FCurrDecimals write FCurrDecimals;
     property SrcDir   :String       read FSrcDir   write FSrcDir  ;
     property EXEDir   :String       read FEXEDir   write FEXEDir  ;
     property DCUDir   :String       read FDCUDir   write FDCUDir  ;
     property BldAll   :String       read FBldAll   write FBldAll  ;
     property CmdLine  :String       read FCmdLine  write FCmdLine ;
     property Aliases  :TStringList  read FAliases  write FAliases ;
     property LibPath  :TStringList  read FLibPath  write FLibPath ;
     property SrchPath :TStringList  read FSrchPath write FSrchPath;
     property Packages :TStringList  read FPackages write FPackages;
     property Product  :TBldCompNode read FProduct  write FProduct ;
     property Group    :TBldCompNode read FGroup    write FGroup   ;
     property UGroup   :TBldCompNode read FUGroup   write FUGroup  ;
     property WGroup   :TBldCompNode read FWGroup   write FWGroup  ;
     property LookUp   :TBldCompNode read FLookUp   write FLookUp  ;
     property PickList :TBldCompNode read FPickList write FPickList;
  end;
  TCompNode = class(TNode)
  private
     FGUID        :String;
     FRegDesc     :String;
     FProgID      :String;
     FVersion     :String;
     FSubGroup    :String;
     FProjectFiles:String;
     FDontBuild   :Boolean;
  public
     procedure SetDataElements(RootNode:TNode); override;
  published
     property GUID        :String  read FGUID         write FGUID        ;
     property RegDesc     :String  read FRegDesc      write FRegDesc     ;
     property ProgID      :String  read FProgID       write FProgID      ;
     property Version     :String  read FVersion      write FVersion     ;
     property SubGroup    :String  read FSubGroup     write FSubGroup    ;
     property ProjectFiles:String  read FProjectFiles write FProjectFiles;
     property DontBuild   :Boolean read FDontBuild    write FDontBuild   ;
  end;
  TExecNode = class;
  TElemNode = class(TCompNode)
  private
     FItems:TStringList;
     function GetItem(Index:Integer):String;
     procedure SetItem(Index:Integer;Value:String);
     function GetItemNode(Index:Integer):TExecNode;
     function GetCount:Integer;
  public
     constructor Create(Parent:TNode;Name,FileName:String); override;
     destructor Destroy; override;
     procedure SetDataElements(RootNode:TNode); override;
     property Item[Index:Integer]:String read GetItem write SetItem;
     property ItemNode[Index:Integer]:TExecNode read GetItemNode; default;
  published
     property Count:Integer read GetCount;
  end;
  TExecNode = class(TElemNode)
  private
     FCaption    :String;
     FTitle       :String;
     FBitmap      :String;
     FImage       :TBitMap;
     function GetImage:TBitMap;
  public
     destructor Destroy; override;
     procedure SetDataElements(RootNode:TNode); override;
  published
     property Title       :String  read FTitle  write FTitle ;
     property Caption     :String read FCaption           write FCaption     ;
     property Bitmap      :String  read FBitmap write FBitmap;
     property Image       :TBitMap read GetImage;
  end;
  TSnippetNode = class(TNode)
  private
     FInsertBetweenStart:String;
     FInsertBetweenEnd:String;
     FCodeBlock:String;
  public
     constructor Create(Parent:TNode;Name,FileName:String); override;
     destructor Destroy; override;
     procedure SetDataElements(RootNode:TNode); override;
  published
     property InsertBetweenStart:String read FInsertBetweenStart write FInsertBetweenStart;
     property InsertBetweenEnd  :String read FInsertBetweenEnd   write FInsertBetweenEnd  ;
     property CodeBlock         :String read FCodeBlock          write FCodeBlock         ;
  end;        
  TConstantNode = class(TNode)
  private
     FValue:String;
     FInUse:Boolean;
  public
     constructor Create(Parent:TNode;Name,FileName:String); override;
     destructor Destroy; override;
     procedure SetDataElements(RootNode:TNode); override;
  published
     property InUse:Boolean read FInUse write FInUse;
     property Value:String read FValue write FValue;
  end;        
  TDomainNode = class(TNode)
  private
     FSubGroup    :String;
     FTitle       :String;
     FPrompt      :String;
     FHint        :String;
     FError       :String;
     FDefaultValue:String;
     FFormat      :String;
     FTotalIn     :String;
     FInputFrom   :String;
     FLocale       :String;
     FFmtData     :String;
     FAction      :String;
     FTotalInDomain:TDomainNode;
     function GetDomType:String;
  public
     procedure SetDataElements(RootNode:TNode); override;
  published
     property Title       :String read FTitle        write FTitle       ;
     property Prompt      :String read FPrompt       write FPrompt      ;
     property Hint        :String read FHint         write FHint        ;
     property Error       :String read FError        write FError       ;
     property DefaultValue:String read FDefaultValue write FDefaultValue;
     property Format      :String read FFormat       write FFormat      ;
     property FmtData     :String read FFmtData      write FFmtData     ;
     property Action      :String read FAction       write FAction      ;
     property InputFrom   :String read FInputFrom    write FInputFrom   ;
     property Locale      :String read FLocale       write FLocale      ;
     property TotalIn     :String read FTotalIn      write FTotalIn     ;
     property SubGroup    :String read FSubGroup     write FSubGroup    ;
     property TotalInDomain:TDomainNode read FTotalInDomain write FTotalInDomain;
  end;
  TProdNode = class(TExecNode)
  private
     FBarCode     :String;
     FDescription :String;
     FEndDate     :String;
     FHighDays    :String;
     FMCRCode     :String;
     FOCRCode     :String;
     FOtherCode   :String;
     FRegulations :String;
     FStartDate   :String;
     FUseDays     :String;
     FTaxes        :String;
     FMOPs         :String;
     FAvailAfterEOD:Boolean;
     FPrompt      :String;
     FHint        :String;
     FUnitQuantity:String;
     FMaxQuantity :String;
     FMinQuantity :String;
     FPLU         :String;
     FUnitPrice   :String;
     FLogAs       :String;
     FDomains     :TStringList;
     FDomainParams:TStringList;
     FPrintList :String;
     FFillList :String;
     FEndorse   :String;
     FCustomer  :String;
     FSnippets   :TStringList;
     function GetDomain(Index:Integer):TDomainNode;
     function GetSnippet(Index:Integer):TSnippetNode;
     function GetItemNode(Index:Integer):TProdNode;
  public                                      
     constructor Create(Parent:TNode;Name,FileName:String); override;
     destructor Destroy; override;
     procedure SetSelected(Value:Boolean); override;
     procedure DrawNode(Canvas:TCanvas;JustSubs:Boolean); override;
     function GetWidth(Canvas:TCanvas;Indent:Integer):Integer; override;
     function GetHeight(Canvas:TCanvas;YOffset:Integer):Integer; override;
     procedure SetDataElements(RootNode:TNode); override;
     property Domain[Index:Integer]:TDomainNode read GetDomain;
     property ItemNode[Index:Integer]:TProdNode read GetItemNode; default;
     property Snippet[Index:Integer]:TSnippetNode read GetSnippet;
  published
     property BarCode     :String read FBarCode           write FBarCode     ;
     property Description :String read FDescription       write FDescription ;
     property EndDate     :String read FEndDate           write FEndDate     ;
     property HighDays    :String read FHighDays          write FHighDays    ;
     property MCRCode     :String read FMCRCode           write FMCRCode     ;
     property OCRCode     :String read FOCRCode           write FOCRCode     ;
     property OtherCode   :String read FOtherCode         write FOtherCode   ;
     property Regulations :String read FRegulations       write FRegulations ;
     property StartDate   :String read FStartDate         write FStartDate   ;
     property UseDays     :String read FUseDays           write FUseDays     ;
     property Taxes        :String read FTaxes            write FTaxes         ;
     property MOPs         :String read FMOPs             write FMOPs          ;
     property AvailAfterEOD:Boolean read FAvailAfterEOD    write FAvailAfterEOD ;
     property Prompt      :String read FPrompt            write FPrompt      ;
     property Hint        :String read FHint              write FHint        ;
     property UnitQuantity:String read FUnitQuantity      write FUnitQuantity;
     property MaxQuantity :String read FMaxQuantity       write FMaxQuantity ;
     property MinQuantity :String read FMinQuantity       write FMinQuantity ;
     property PLU         :String read FPLU               write FPLU         ;
     property UnitPrice   :String read FUnitPrice         write FUnitPrice   ;
     property LogAs       :String read FLogAs             write FLogAs       ;
     property Domains     :TStringList read FDomains      write FDomains     ;
     property DomainParams:TStringList read FDomainParams write FDomainParams;
     property PrintList :String read FPrintList write FPrintList;
     property FillList :String read FFillList write FFillList;
     property Endorse   :String read FEndorse   write FEndorse  ;
     property Customer  :String read FCustomer  write FCustomer ;
     property Snippets:TStringList read FSnippets write FSnippets;

  end;
  TGroupNode = class(TExecNode)
  private
     FPrompt  :String;
     FHint    :String;
  public
     procedure SetDataElements(RootNode:TNode); override;
  published
     property Prompt  :String      read FPrompt   write FPrompt  ;
     property Hint    :String      read FHint     write FHint    ;
  end;
  TWUGroupNode = class(TElemNode)
  public
     function GetWidth(Canvas:TCanvas;Indent:Integer):Integer; override;
     function GetHeight(Canvas:TCanvas;YOffset:Integer):Integer; override;
  end;
  TWGroupNode = class(TWUGroupNode)
  public
     procedure DrawNode(Canvas:TCanvas;JustSubs:Boolean); override;
  end;
  TUGroupNode = class(TWUGroupNode)
  public
     procedure DrawNode(Canvas:TCanvas;JustSubs:Boolean); override;
  end;
  TPickListNode = class(TCompNode)
  private
     FSorted:Boolean;
     FDefaultItem:String;
     FItems     :TStringList;
     FZones     :TStringList;
  public
     constructor Create(Parent:TNode;Name,FileName:String); override;
     destructor Destroy; override;
     procedure SetDataElements(RootNode:TNode); override;
  published
     property DefaultItem:String      read FDefaultItem write FDefaultItem;
     property Items      :TStringList read FItems       write FItems      ;
     property Zones      :TStringList read FZones       write FZones      ;
     property Sorted     :Boolean     read FSorted      write FSorted     ;
  end;        
  TLookUpNode = class(TCompNode)
  private
     FRanges   :TStringList;
     FZones    :TStringList;
     FZoneNames:TStringList;
  public
     constructor Create(Parent:TNode;Name,FileName:String); override;
     destructor Destroy; override;
     procedure SetDataElements(RootNode:TNode); override;
  published
     property Ranges   :TStringList read FRanges    write FRanges   ;
     property ZoneNames:TStringList read FZoneNames write FZoneNames;
     property Zones    :TStringList read FZones     write FZones    ;
  end;        
  TConstantsNode = class(TNode)
  private
     function GetNode(Index:Integer):TConstantNode;
  public
     function GetItemByName(Name:String):TConstantNode;
     property Node[Index:Integer]:TConstantNode read GetNode; default;
     function AsString:String;
  end;   
  TSnippetsNode = class(TNode)
  private
     function GetNode(Index:Integer):TSnippetNode;
  public
     function GetItemByName(Name:String):TSnippetNode;
     property Node[Index:Integer]:TSnippetNode read GetNode; default;
  end;
  TProductsNode = class(TNode)
  private
     function GetNode(Index:Integer):TProdNode;
  public
     function GetItemByName(Name:String):TProdNode;
     property Node[Index:Integer]:TProdNode read GetNode; default;
  end;
  TGroupsNode = class(TNode)
  private
     function GetNode(Index:Integer):TGroupNode;
  public
     function GetItemByName(Name:String):TGroupNode;
     property Node[Index:Integer]:TGroupNode read GetNode; default;
  end;
  TDomainsNode = class(TNode)
  private
     function GetNode(Index:Integer):TDomainNode;
  public
     function GetItemByName(Name:String):TDomainNode;
     property Node[Index:Integer]:TDomainNode read GetNode; default;
  end;
  TUsersNode = class(TNode)
  private
     function GetNode(Index:Integer):TUGroupNode;
  public
     function GetItemByName(Name:String):TUGroupNode;
     property Node[Index:Integer]:TUGroupNode read GetNode; default;
  end;
  TWorkStationsNode = class(TNode)
  private
     function GetNode(Index:Integer):TWGroupNode;
  public
     function GetItemByName(Name:String):TWGroupNode;
     property Node[Index:Integer]:TWGroupNode read GetNode; default;
  end;
  TLookUpsNode = class(TNode)
  private
     function GetNode(Index:Integer):TLookUpNode;
  public
     function GetItemByName(Name:String):TLookUpNode;
     property Node[Index:Integer]:TLookUpNode read GetNode; default;
  end;
  TPickListsNode = class(TNode)
  private
     function GetNode(Index:Integer):TPickListNode;
  public
     function GetItemByName(Name:String):TPickListNode;
     property Node[Index:Integer]:TPickListNode read GetNode; default;
  end;
  TLogFormatNode = class(TNode)
  private
     FFormat:String;
  public
     procedure SetDataElements(RootNode:TNode); override;
     property Format:String read FFormat write FFormat;
  end;
  TLogFormatsNode = class(TNode)
  private
     function GetNode(Index:Integer):TLogFormatNode;
  public
     function GetItemByName(Name:String):TLogFormatNode;
     property Node[Index:Integer]:TLogFormatNode read GetNode; default;
  end;
  TRootNode = class(TNode)
  private
     FDomains     :TDomainsNode     ;
     FProducts    :TProductsNode    ;
     FSnippets    :TSnippetsNode     ;
     FConstants   :TConstantsNode     ;
     FGroups      :TGroupsNode      ;
     FLookUps     :TLookUpsNode     ;
     FPickLists   :TPickListsNode   ;
     FUsers       :TUsersNode       ;
     FWorkStations:TWorkStationsNode;
     FBuildOptions:TOptionsNode     ;
     FLogFormats  :TLogFormatsNode  ;
  public
     procedure SetDataElements(RootNode:TNode); override;
  published
     property Domains     :TDomainsNode      read FDomains      write FDomains     ;
     property Products    :TProductsNode     read FProducts     write FProducts    ;
     property Snippets    :TSnippetsNode     read FSnippets     write FSnippets    ;
     property Constants   :TConstantsNode    read FConstants    write FConstants   ;
     property Groups      :TGroupsNode       read FGroups       write FGroups      ;
     property LookUps     :TLookUpsNode      read FLookUps      write FLookUps     ;
     property PickLists   :TPickListsNode    read FPickLists    write FPickLists   ;
     property Users       :TUsersNode        read FUsers        write FUsers       ;
     property WorkStations:TWorkStationsNode read FWorkStations write FWorkStations;
     property BuildOptions:TOptionsNode      read FBuildOptions write FBuildOptions;
     property LogFormats  :TLogFormatsNode   read FLogFormats   write FLogFormats  ;
  end;                              
  TParser = class(TObject)
  private
     procedure Parse;
     procedure PreParse(Path:string);
     procedure ParseNode(var Text:PChar);
     function GetToken(var P:PChar;var IsIdent:Boolean):String;
     procedure EnterFile(FileName:String);
     procedure ExitFile(FileName:String);
  public                                      
     CurrentFileList:TStringList;
     CurrentFile:String;
     Nodes:TRootNode;
     procedure ReParseNode(Node:TNode;var Text:PChar);
     function FindNode(X,Y:Integer;var OnExpand:Boolean):TNode;
     procedure DrawNodes(Canvas:TCanvas);
     function GetWidth(Canvas:TCanvas):Integer;
     function GetHeight(Canvas:TCanvas):Integer;
     constructor Create(FileName:String);
     destructor Destroy; override;
     function AsString:String;
  end;
  
function Strip(Value:String):String;
var
   Terminate:TTermType;
   TokenPtr:PChar;
   TextBuffer:String;
   
implementation

function Strip(Value:String):String;
begin
   if (Value <> '') and (Value[1] = #39) then
      Result:=Copy(Value,2,Length(Value)-2)
   else
      Result:=Value;
end;
{TNodeObject}
constructor TNodeObject.Create;
begin
   inherited Create(nil);
end;
procedure TNodeObject.AddObjectToString(Obj:TNodeObject;var Str:String);
var
   MS:TMemoryStream;
   OS:TStringStream;
begin
   MS:=TMemoryStream.Create;
   OS:=TStringStream.Create('');
   MS.WriteComponent(Obj);
   MS.Position:=0;
   ObjectBinaryToText(MS,OS);
   Str:=Str+OS.DataString;
   MS.Free;
   OS.Free;
end;
{TNode}
procedure TNode.SetConstants(Constants:TConstantsNode);
var
   I:Integer;
   ConstantNode:TConstantNode;
begin
   if Constants = Self then Exit;
   
   ConstantNode:=Constants.GetItemByName(NodeName);
   if ConstantNode <> nil then 
   begin
      NodeName:=ConstantNode.Value;
      ConstantNode.InUse:=True;
   end
   else
   begin
      for I:=0 to Count-1 do
          Node[I].SetConstants(Constants);
   end;
end;   
procedure TNode.SetSelected(Value:Boolean);
var
   I:Integer;
begin
   if FIsSelected <> Value then
   begin
      FIsSelected:=Value;
      if not FIsExpanded then
         for I:=0 to Count-1 do 
            Node[I].IsSelected:=Value;
   end;
end;
procedure TNode.SetExpanded(Value:Boolean);
var
   I:Integer;
begin
   if FIsExpanded <> Value then
   begin
      FIsExpanded:=Value;
      if not FIsExpanded then
         for I:=0 to Count-1 do
            Node[I].IsExpanded:=Value;
   end;
end;
procedure TNode.Sort;
begin
  FNodeList.Sort;
end;
procedure TNode.ResetUsedBy;
var
   I:Integer;
begin
   FUsedBy:='';
   for I:=0 to Count-1 do
        Node[I].ResetUsedBy;
end;
function ValidName(S:String):String;
var
   I:Integer;
begin
   Result:='';
   for I:=1 to Length(S) do
   begin
      if S[I] in ['0'..'9','A'..'Z','a'..'z','_'] then
         Result:=Result+S[I];
   end;
   if (Result = '') or (Result[1] in ['0'..'9']) then
      Result:='Q'+Result;
end;
constructor TNode.Create(Parent:TNode;Name,FileName:String);
begin
   inherited Create;
   FNodeName:=Name;
   inherited Name:=ValidName(Name);
   FFileName:=FileName;
   FCurrentNode:=Self;
   FParentNode:=Parent;
//   if (FParentNode <> nil) and (FParentNode.ParentNode <> nil) and
//      (FParentNode.ParentNode <> RootNode) and
//      (FParentNode.FileName <> FileName) then
//      ShowMessage('Possible Missing ''{'' in Node '+ParentNode.NodeName+'.'+NodeName+' ('+FileName+')');
   FNodeList:=TStringList.Create;
   FIsExpanded:=False;
   FIsSelected:=False;
   FHasChild  :=False;
   FWidth :=0;
   FBaseColor:=clWindow;
   FExpWidth :=0;
   FHeight:=0;
   FXCoord:=0;
   FIndent:=0;
   FYCoord:=0;
end;
destructor TNode.Destroy;
var
   I:Integer;
begin
   for I:=0 to Count-1 do Node[I].Free;
   FNodeList.Free;
   inherited Destroy;
end;
function TNode.GetCount:Integer;
begin
   Result:=FNodeList.Count;
end;
procedure TNode.SetNName(Index:Integer;Value:String);
begin
   if (Index >= 0) and (Index < Count) then
      FNodeList[Index]:=Value;
end;   
procedure TNode.SetNodeName(Value:String);
var
  I:Integer;
begin
   if ParentNode <> nil then
   begin
      for I:=0 to ParentNode.Count-1 do
      begin
         if Self = ParentNode.Node[I] then
         begin
            ParentNode.Name[I]:=Value;
            break;
         end;
      end;
   end;
   FNodeName:=Value;
end;
function TNode.GetName(Index:Integer):String;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=FNodeList[Index]
   else
      Result:=''
end;   
function TNode.GetNode(Index:Integer):TNode;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=TNode(FNodeList.Objects[Index])
   else
      Result:=nil
end;   
procedure TNode.SetDataElements(RootNode:TNode);
var
   I:Integer;
begin
   for I:=0 to Count-1 do 
      Node[I].SetDataElements(RootNode);
end;
procedure TNode.Delete(NodeName:String);
var
   Idx:Integer;
begin
   Idx:=FNodeList.IndexOf(NodeName);
   if Idx >= 0 then
   begin
      Node[Idx].Free;
      FNodeList.Delete(Idx);
   end;
end;
procedure FindFilePos(Ptr:PChar;FileName:String;var LinePtr:PChar;var LineNo:Integer);
begin
   LineNo:=0;
   while (Ptr <> PChar(TextBuffer)) and (Ptr^ <> #10) do
      Dec(Ptr);
   LinePtr:=Ptr+1;
   while (Ptr <> PChar(TextBuffer)) and not ((Ptr^ = '#') and ((Ptr-1)^ = '/')) do
   begin
      if Ptr^ = #10 then Inc(LineNo);
      Dec(Ptr);
   end;
end;
function TNode.Add(NodeName,FileName:String):Integer;
var
   LineNo:Integer;
   LinePtr:PChar;
const
   S:String = '';
begin
   Result:=FNodeList.IndexOf(NodeName);
   if (Result = -1) or ((self.parentnode <> nil) and (self.parentnode.classtype = TLookUpNode)) then //allow duplicate values in lookups
   begin
      if Self is TRootNode then
      begin
         if NodeName = ttProducts then
            Result:=FNodeList.AddObject(NodeName,TProductsNode.Create(Self,NodeName,FileName))
         else if NodeName = ttConstants then
            Result:=FNodeList.AddObject(NodeName,TConstantsNode.Create(Self,NodeName,FileName))
         else if NodeName = ttSnippets then
            Result:=FNodeList.AddObject(NodeName,TSnippetsNode.Create(Self,NodeName,FileName))
         else if NodeName = ttGroups then
            Result:=FNodeList.AddObject(NodeName,TGroupsNode.Create(Self,NodeName,FileName))
         else if NodeName = ttUsers then
            Result:=FNodeList.AddObject(NodeName,TUsersNode.Create(Self,NodeName,FileName))
         else if NodeName = ttWorkStations then
            Result:=FNodeList.AddObject(NodeName,TWorkstationsNode.Create(Self,NodeName,FileName))
         else if NodeName = ttPickLists then
            Result:=FNodeList.AddObject(NodeName,TPickListsNode.Create(Self,NodeName,FileName))
         else if NodeName = ttLogFormats then
            Result:=FNodeList.AddObject(NodeName,TLogFormatsNode.Create(Self,NodeName,FileName))
         else if NodeName = ttLookUps then
            Result:=FNodeList.AddObject(NodeName,TLookUpsNode.Create(Self,NodeName,FileName))
         else if NodeName = ttDomains then
            Result:=FNodeList.AddObject(NodeName,TDomainsNode.Create(Self,NodeName,FileName))
         else if NodeName = ttBuildOptions then
            Result:=FNodeList.AddObject(NodeName,TOptionsNode.Create(Self,NodeName,FileName))
         else                            
         begin
            Result:=FNodeList.AddObject(NodeName,TNode.Create(Self,NodeName,FileName));
            if (Terminate = ttIgnore) and (NodeName <> 'ProjectInfo') then
            begin
               ParseError.ErrorMessage.Caption:='Extra Root Node '+NodeName+#10+' in '+FileName+' '+#10+'Possible Extra ''}''';
               ParseError.ShowModal;
               case ParseError.ModalResult of
                  mrOK     : Terminate:=ttContinue;
                  mrIgnore : Terminate:=ttIgnore;
                  mrRetry  : Terminate:=ttReload;
                  mrAbort  : Terminate:=ttAbort;
                  else Terminate:=ttContinue;
               end;
            end;
         end;
      end
      else if FNodeName = ttProducts then                  
         Result:=FNodeList.AddObject(NodeName,TProdNode.Create(Self,NodeName,FileName))
      else if FNodeName = ttConstants then                  
         Result:=FNodeList.AddObject(NodeName,TConstantNode.Create(Self,NodeName,FileName))
      else if FNodeName = ttSnippets then                  
         Result:=FNodeList.AddObject(NodeName,TSnippetNode.Create(Self,NodeName,FileName))
      else if FNodeName = ttGroups then
         Result:=FNodeList.AddObject(NodeName,TGroupNode.Create(Self,NodeName,FileName))
      else if FNodeName = ttUsers then
         Result:=FNodeList.AddObject(NodeName,TUGroupNode.Create(Self,NodeName,FileName))
      else if FNodeName = ttWorkStations then
         Result:=FNodeList.AddObject(NodeName,TWGroupNode.Create(Self,NodeName,FileName))
      else if FNodeName = ttDomains then
         Result:=FNodeList.AddObject(NodeName,TDomainNode.Create(Self,NodeName,FileName))
      else if FNodeName = ttPickLists then
         Result:=FNodeList.AddObject(NodeName,TPickListNode.Create(Self,NodeName,FileName))
      else if FNodeName = ttLookUps then
         Result:=FNodeList.AddObject(NodeName,TLookUpNode.Create(Self,NodeName,FileName))
      else if FNodeName = ttLogFormats then
         Result:=FNodeList.AddObject(NodeName,TLogFormatNode.Create(Self,NodeName,FileName))
      else if (FNodeName = ttBuildOptions) and 
                 ((NodeName = ttProductIn)
               or (NodeName = ttGroupIn)
               or (NodeName = ttUGroupIn)
               or (NodeName = ttWGroupIn)
               or (NodeName = ttLookUpIn)
               or (NodeName = ttPickListIn)) then
                  Result:=FNodeList.AddObject(NodeName,TBldCompNode.Create(Self,NodeName,FileName))
      else 
         Result:=FNodeList.AddObject(NodeName,TNode.Create(Self,NodeName,FileName));
      FHasChild:=True;          
      if (FNodeList.Objects[Result] <> nil) and (not TNode(FNodeList.Objects[Result]).Modified) then
      begin
         FindFilePos(TokenPtr,FileName,LinePtr,LineNo);
         TNode(FNodeList.Objects[Result]).LineNo:=LineNo;
         TNode(FNodeList.Objects[Result]).DPtr:=LinePtr;
      end;
   end
   else if TNode(FNodeList.Objects[Result]).Count > 0 then
   begin
      if (FNodeName = ttProducts    )
      or (FNodeName = ttConstants   )
      or (FNodeName = ttSnippets    )
      or (FNodeName = ttGroups      )
      or (FNodeName = ttUsers       )
      or (FNodeName = ttWorkStations)
      or (FNodeName = ttDomains     )
      or (FNodeName = ttPickLists   )
      or (FNodeName = ttLookUps     )
      or (FNodeName = ttLogFormats  ) then
      begin
         if Pos(FNodeName+'.'+NodeName,S) = 0 then
         begin
            ShowMessage('Node '+FNodeName+'.'+NodeName+' defined in two places'+#13#10+FileName+#13#10+TNode(FNodeList.Objects[Result]).FileName);
            S:=S+' '+FNodeName+'.'+NodeName;
         end;
      end;
   end;
//   if TNode(FNodeList.Objects[Result]) <> nil then
//      TNode(FNodeList.Objects[Result]).Parent:=Self;
end;
function TNode.RootNode:TNode;
begin
   Result:=Self;
   while Result.ParentNode <> nil do Result:=Result.ParentNode;
end;
function TNode.SelectNode(NodeName:String):TNode;
var
   I:Integer;
begin
   Result:=Self;
   if NodeName = '' then Exit;
   I:=FNodeList.IndexOf(NodeName);
   if I <> -1 then
      RootNode.CurrentNode:=Node[I]
   else
   begin
      if (NodeName[1] = 'P') and (FNodeName = ttProducts) and (Copy(NodeName,1,8) = 'Product.') then
      begin
         I:=FNodeList.IndexOf(Copy(NodeName,9,999));
         if I <> -1 then
            RootNode.CurrentNode:=Node[I]
         else
            RootNode.CurrentNode:=Self;
      end
      else
      begin
         RootNode.CurrentNode:=Self;
      end;
   end;
   Result:=RootNode.CurrentNode;
end;

procedure TNode.GetStringData(var Data:String;Depth:Integer);
var
   I:Integer;
   S:String;
   Item:String;
begin
   for I:=0 to Depth do S:=S+' ';
   for I:=0 to Count-1 do
   begin
      if (FNodeList[I]<> '') and (FNodeList[I][1] = #39) then
         Item:=Copy(FNodeList[I],2,Length(FNodeList[I])-2)
      else
         Item:=FNodeList[I];
      if (Node[I].Count = 1) and (Node[I].Node[0].Count = 0) then
      begin
         Data:=Data+S+Item+' {'+Node[I].Name[0]+'}'+#13#10;
      end
      else
      begin
         if Node[I].Count > 0 then
         begin
            Data:=Data+S+Item+' {'#13#10;
         end
         else
         begin
            Data:=Data+S+FNodeList[I]+#13#10;
         end;
         Node[I].GetStringData(Data,Depth+3);
         if Node[I].Count > 0 then
            Data:=Data+S+'}'#13#10;
      end;
   end;
end; 
function TNode.AsString:String;
begin
   Result:='';
   GetStringData(Result,0);
end;
procedure TNode.GetObjectData(var Data:String);
var
   I:Integer;
begin
   AddObjectToString(Self,Data);
   for I:=0 to Count-1 do
   begin
      Node[I].GetObjectData(Data);
   end;
end; 
function TNode.AsObject:String;
begin
   Result:='';
   GetObjectData(Result);
end;
function TNode.FindNode(X,Y:Integer;var OnExpand:Boolean):TNode;
var
   I:Integer;
begin
   Result:=nil;
   if (Y >= FYCoord) and (Y <= FYCoord+FHeight) then
   begin
      if (X >= FXCoord) then
      begin
         Result:=Self;
         if (X >= FXCoord) and (X <= FXCoord+FExpWidth) then
            OnExpand:=True;
      end;
   end
   else
   begin
      if IsExpanded then
      begin
         for I:=0 to Count-1 do
         begin
            Result:=Node[I].FindNode(X,Y,OnExpand);
            if Result <> nil then break;
         end;
      end;
   end;
end;
function TNode.GetWidth(Canvas:TCanvas;Indent:Integer):Integer;
var
   W,I:Integer;
begin
   FWidth :=Canvas.TextWidth(FNodeName);
   if HasChild then
      FExpWidth:=Canvas.TextHeight('Wg')
   else
      FExpWidth :=0;
   FIndent:=Indent-1;
   FXCoord:=FIndent*Canvas.TextHeight('Wg');
   Result:=FXCoord+FWidth+FExpWidth;
   if IsExpanded then
   begin
      for I:=0 to Count-1 do
      begin
         W:=Node[I].GetWidth(Canvas,Indent+1);
         if W > Result then Result:=W;
      end;
   end;
end;
function TNode.GetHeight(Canvas:TCanvas;YOffset:Integer):Integer;
var
   I:Integer;
begin
   if NodeName = '' then
      FHeight:=0
   else
      FHeight:=Canvas.TextHeight('Wg');
      
   FYCoord:=YOffset;
   Result:=FYCoord+FHeight;
   
   if IsExpanded then
   begin
      for I:=0 to Count-1 do
         Result:=Node[I].GetHeight(Canvas,Result);
   end;
end;

procedure TNode.Expander(Canvas:TCanvas;FXCoord,FYCoord,FExpWidth:Integer;HasChild,IsExpanded:Boolean);
begin
   with Canvas do
   begin
      if HasChild then
      begin
         Rectangle(FXCoord+1,FYCoord+1,FXCoord+FExpWidth-1,FYCoord+FExpWidth-1);
         MoveTo(FXCoord+3,FYCoord+FExpWidth div 2); LineTo(FXCoord+FExpWidth-3,FYCoord+FExpWidth div 2);
         if not IsExpanded then
         begin
            MoveTo(FXCoord+FExpWidth div 2,FYCoord+3); LineTo(FXCoord+FExpWidth div 2,FYCoord+FExpWidth-3);
         end;
      end;         
   end;         
end;
procedure TNode.DrawNode(Canvas:TCanvas;JustSubs:Boolean);
var
   I:Integer;
   BC,FC:TColor;
begin                              
   with Canvas do
   begin
      BC:=Brush.Color;
      FC:=Font.Color;
      if not JustSubs then
      begin
         Expander(Canvas,FXCoord,FYCoord,FExpWidth,HasChild,IsExpanded);
         if IsSelected then
         begin
            Brush.Color:=FC;
            Font.Color:=BC;
         end;
         TextOut(FXCoord+FExpWidth,FYCoord,NodeName);
      end;
      Brush.Color:=BC;
      Font.Color:=FC;
      if IsExpanded then
         for I:=0 to Count-1 do
            Node[I].DrawNode(Canvas,False);
   end;                                    
end;                                    
function TNode.GetItemData(Name:String;MultiLine:Boolean):String;
var
   TargetNode:TNode;
   SL:TStringList;
   BSL:TStringList;
   I,Idx:Integer;
   FoundItem:String;
begin
   BSL:=TStringList.Create;
   if BasisNode = nil then
   begin
      BasisNode:=SelectNode('BasedOn');
      if BasisNode <> Self then
         BasisNode:=ParentNode.SelectNode(BasisNode.Name[0]);
   end;
   Result:='';
   if (BasisNode <> Self) and (BasisNode <> ParentNode) then
   begin
      if Multiline then
         BSL.CommaText:=BasisNode.GetItemData(Name,Multiline)
      else
         BSL.Text:=BasisNode.GetItemData(Name,Multiline);
      I:=0;
      while I < BSL.Count do
         if BSL[I] = 'DontBuild' then BSL.Delete(I) else Inc(I);
   end;  
   TargetNode:=SelectNode(Name);
   if TargetNode <> Self then
   begin
      SL:=TStringList.Create;
      if (MultiLine) or (TargetNode.Count < 1) then
         SL.CommaText:=BSL.CommaText;
      for I:=0 to TargetNode.Count-1 do
      begin
         FoundItem:=TargetNode.Name[I];
         if (FoundItem <> '') and (FoundItem[1] = #39) then
            FoundItem:=Copy(FoundItem,2,Length(FoundItem)-2);
         Idx:=SL.IndexOf(FoundItem);
         if Idx = -1 then
            SL.Add(FoundItem);
      end;
      if (SL.Count > 1) or (Multiline) then
         Result:=SL.CommaText
      else
         Result:=Trim(SL.Text);
      SL.Free;
   end
   else
   begin
      if (BSL.Count > 1) or (Multiline) then
         Result:=BSL.CommaText
      else
         Result:=Trim(BSL.Text);
   end; 
   BSL.Free;
end;       
{TBldCompNode}
constructor TBldCompNode.Create(Parent:TNode;Name,FileName:String);
begin
   inherited Create(Parent,Name,FileName);
   FFormFiles:=TStringList.Create;
   FDependencies:=TStringList.Create;
end;           
destructor TBldCompNode.Destroy;
begin
   FFormFiles.Free;
   FDependencies.Free;
   inherited Destroy;
end;           
procedure TBldCompNode.SetDataElements(RootNode:TNode);
var
   FilesNode:TNode;
begin
   inherited SetDataElements(RootNode);
   FDirectory:=GetItemData('Directory',False);
   FDependencies.CommaText:=GetItemData(ttDependencies,True);
   FilesNode:=SelectNode('Files');
   if FilesNode <> Self then
   begin
      FProjFile :=FilesNode.GetItemData('Project'   ,False);
      FAutoFile :=FilesNode.GetItemData('Automation',False);
      FConstFile:=FilesNode.GetItemData('Constants',False);
      FFormFiles.CommaText:=FilesNode.GetItemData('Form',True);
   end;
end;
{TOptionsNode}
constructor TOptionsNode.Create(Parent:TNode;Name,FileName:String);
begin
   inherited Create(Parent,Name,FileName);
   FAliases  :=TStringList.Create;
   FLibPath  :=TStringList.Create;
   FSrchPath :=TStringList.Create;
   FPackages :=TStringList.Create;
end;
destructor TOptionsNode.Destroy;
begin
   FAliases  .Free;
   FLibPath  .Free;
   FSrchPath .Free;
   FPackages .Free;
   inherited Destroy;
end;           
procedure TOptionsNode.SetDataElements(RootNode:TNode);
var
   ANode:TNode;
   I:Integer;
begin
   inherited SetDataElements(RootNode);
   FSrcDir            :=GetItemData(ttSrcDir  ,False);
   FEXEDir            :=GetItemData(ttEXEDir  ,False);
   FDCUDir            :=GetItemData(ttDCUDir  ,False);
   FBldAll            :=GetItemData(ttBldAll  ,False);
   FCmdLine           :=GetItemData(ttCmdLine ,False);
   FOutConstName      :=GetItemData(ttOutputFile,False );
   FCurrDecimals      :=GetItemData(ttCurrDecimal,False);
   if FCurrDecimals = '' then FCurrDecimals := '2';
    
   FAliases .CommaText:=GetItemData(ttAliases ,True);
   ANode:=SelectNode(ttAliases);
   if ANode <> Self then
   begin
      for I:=0 to FAliases.Count-1 do
         FAliases[I]:=FAliases[I]+'='+ANode.GetItemData(FAliases[I],False);
   end;
   FLibPath .CommaText:=GetItemData(ttLibPath ,True);
   FSrchPath.CommaText:=GetItemData(ttSrchPath,True);
   FPackages.CommaText:=GetItemData(ttPackages,True);
   FProduct  :=TBldCompNode(SelectNode(ttProductIn)); 
   if FProduct  = TBldCompNode(Self) then FProduct :=nil;
   FGroup    :=TBldCompNode(SelectNode(ttGroupIn)); 
   if FGroup    = TBldCompNode(Self) then FGroup   :=nil;
   FUGroup   :=TBldCompNode(SelectNode(ttUGroupIn)); 
   if FUGroup   = TBldCompNode(Self) then FUGroup  :=nil;
   FWGroup   :=TBldCompNode(SelectNode(ttWGroupIn)); 
   if FWGroup   = TBldCompNode(Self) then FWGroup  :=nil;
   FLookUp   :=TBldCompNode(SelectNode(ttLookUpIn)); 
   if FLookUp   = TBldCompNode(Self) then FLookUp  :=nil;
   FPickList :=TBldCompNode(SelectNode(ttPickListIn)); 
   if FPickList = TBldCompNode(Self) then FPickList:=nil;
end;            
                
                
{TDomainNode}      
function TDomainNode.GetDomType:String;
var
   SL:TStringList;
   I:Integer;
begin
   SL:=TStringList.Create;
   SL.CommaText:=GetItemData(ttFormat,True);
   Result:='Show';
   if SL.Count <> 0 then
   begin
      if SL[0] = 'List' then 
      begin
         Result:='ListFill'
      end
      else if SL[0] = 'PickList' then 
      begin
         Result:='ListPick';
      end
      else 
      begin
         SL.CommaText:=GetItemData('InputFrom',True);
         I:=SL.IndexOf('Keyboard');
         if I <> -1 then SL.Delete(I);
         if SL.Count <> 0 then
         begin
            if SL[0] = 'Barcode' then
               Result:='Scan\Input'
            else if SL[0] = 'Scale' then
               Result:='Weigh\Input'
            else if (SL[0] <> '') and (SL[0][1] = '?') then
               Result:='Input'
            else
               Result:=SL[0]+'\Input';                     
         end    
         else
         begin
            Result:='Input';
         end;
      end;
   end;
   SL.Free;
end;
procedure TDomainNode.SetDataElements(RootNode:TNode);
var
   InputData:String;
   DomainsNode:TNode;
begin
   inherited SetDataElements(RootNode);
   FTitle        :=GetItemData(ttTitle    ,False);
   FPrompt       :=GetItemData(ttPrompt   ,False);
   FHint         :=GetItemData(ttHint     ,False);
   FError        :=GetItemData(ttError    ,False);
   FDefaultValue :=GetItemData(ttDefaultValue,False);
   FFormat       :=GetItemData(ttFormat   ,False);
   FTotalIn      :=GetItemData(ttTotalIn  ,False);
   FTotalInDomain:=nil;
   if FTotalIn <> '' then
   begin
      DomainsNode:=RootNode.SelectNode(ttDomains);
      FTotalInDomain:=TDomainNode(DomainsNode.SelectNode(FTotalIn));
      if FTotalInDomain = DomainsNode then
         FTotalInDomain:=nil;
   end;

   FInputFrom:=GetItemData(ttInputFrom,False);
   FLocale   :=GetItemData(ttLocale,False);
   InputData:=SelectNode(ttInputFrom).GetItemData(FInputFrom,True);
   if InputData <> '' then
      FInputFrom:=FInputFrom+'('+InputData+')';
   FSubGroup :=GetItemData(ttSubGroup ,False);
   FFmtData:=SelectNode(ttFormat).GetItemData(FFormat,False);
   if (FFmtData = '') or (FFmtData[1] = '?') then
      FFmtData:='';
//   else
//      FFmtData:='('+FFmtData+')';
   FAction:=GetDomType;
end;
{TCompNode}
procedure TCompNode.SetDataElements(RootNode:TNode);
var
   CType:String;
begin
   inherited SetDataElements(RootNode);
   FGUID        :=GetItemData(ttGUID        ,False);
   FRegDesc     :=GetItemData(ttRegDesc     ,False);
   FProgID      :=GetItemData(ttProgID      ,False);
   FVersion     :=GetItemData(ttVersion     ,False);
   FSubGroup    :=GetItemData(ttSubGroup    ,False);
   FProjectFiles:=GetItemData(ttProjectFiles,True );
   if SelectNode(ttDontBuild) <> Self then 
      FDontBuild:=True 
   else 
      FDontBuild:=False;
   if Self.ClassType = TProdNode then
      CType:='Product'
   else if Self.ClassType = TGroupNode then
      CType:='Group'
   else if Self.ClassType = TWGroupNode then
      CType:='WGroup'
   else if Self.ClassType = TUGroupNode then
      CType:='UGroup'
   else if Self.ClassType = TPickListNode then
      CType:='PickList'
   else if Self.ClassType = TLookUpNode then
      CType:='LookUp'
   else
      CType:='Comp';
//   if RegDesc = '' then 
//      RegDesc:='CORVUS '+Title+' '+CType
//   else if Copy(RegDesc,1,7) <> 'CORVUS ' then
//      RegDesc:='CORVUS '+RegDesc;
   ProgID:=CType+'.'+NodeName;
end;                       
{TElemNode}
constructor TElemNode.Create(Parent:TNode;Name,FileName:String);
begin
   inherited Create(Parent,Name,FileName);
   FItems:=TStringList.Create;
end;
destructor TElemNode.Destroy;
begin
   FItems.Free;
   inherited Destroy;
end;
procedure TElemNode.SetItem(Index:Integer;Value:String);
var
   ItemsNode:TNode;
   ItemNode:TNode;
   I:Integer;
   CompType:String;
   CompName:String;
   SP,DP:PChar;
begin
   ItemsNode:=SelectNode(ttItems);
   if ItemsNode <> Self then
   begin
      ItemNode:=ItemsNode;
      if Index < FItems.Count then
         ItemNode:=ItemsNode.SelectNode(#39+FItems[Index]+#39);
      if ItemNode <> ItemsNode then
      begin
         ItemNode.NodeName:=#39+Value+#39;
      end
      else
      begin
         ItemsNode.Add(#39+Value+#39,FFileName);
      end;
   end;
   FItems.CommaText:=GetItemData(ttItems,True);
   for I:=0 to FItems.Count-1 do
   begin
      SP:=PChar(FItems[I]);
      DP:=StrScan(SP,'.');
      if DP <> nil then
      begin
         CompType:=Copy(FItems[I],1,Integer(DP-SP))+'s';
         CompName:=Copy(FItems[I],Integer(DP-SP)+2,Length(FItems[I]));
         ItemsNode:=RootNode.SelectNode(CompType);
         if ItemsNode <> RootNode then
         begin
            ItemNode:=ItemsNode.SelectNode(CompName);
            if ItemNode <> ItemsNode then
               FItems.Objects[I]:=ItemNode;
         end;
      end;
   end;
end;
function TElemNode.GetItem(Index:Integer):String;
begin
   if (Index >= 0) and (Index < FItems.Count) then
      Result:=FItems[Index]
   else
      Result:='';
end;
function TElemNode.GetItemNode(Index:Integer):TExecNode;
begin
   if (Index >= 0) and (Index < FItems.Count) then
      Result:=TExecNode(FItems.Objects[Index])
   else
      Result:=nil;
end;
function TElemNode.GetCount:Integer;
begin
   Result:=FItems.Count;
end;

procedure TElemNode.SetDataElements(RootNode:TNode);
var
   ItemsNode:TNode;
   ItemNode:TNode;
   I:Integer;
   CompType:String;
   CompName:String;
   SP,DP:PChar;
begin
   inherited SetDataElements(RootNode);
   FItems.CommaText:=GetItemData(ttItems,True);
   for I:=0 to FItems.Count-1 do
   begin
      SP:=PChar(FItems[I]);
      DP:=StrScan(SP,'.');
      if DP <> nil then
      begin
         CompType:=Copy(FItems[I],1,Integer(DP-SP))+'s';
         CompName:=Copy(FItems[I],Integer(DP-SP)+2,Length(FItems[I]));
         ItemsNode:=RootNode.SelectNode(CompType);
         if ItemsNode <> RootNode then
         begin
            ItemNode:=ItemsNode.SelectNode(CompName);
            if ItemNode <> ItemsNode then
               FItems.Objects[I]:=ItemNode;
         end;   
      end;
   end;
end;    
{TExecNode}
destructor TExecNode.Destroy;
begin
   if FImage <> nil then FImage.Free;
   FImage:=nil;
   inherited Destroy;
end;
function TExecNode.GetImage:TBitMap;
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
      if FileExists(FBitmap) then
      begin
         try
            FImage.LoadFromFile(FBitmap);
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
               S:=Self.FNodeName;
            R:=Bounds(5,5,BMPWidth-10,BMPHeight-10);
            DrawText(Handle,PChar(S),Length(S),R,DT_WORDBREAK or DT_CENTER);
         end;
      end;
   end;
   Result:=FImage;
end; 
procedure TExecNode.SetDataElements(RootNode:TNode);
begin
   inherited SetDataElements(RootNode);
   FCaption     :=GetItemData(ttCaption     ,False);
   FTitle       :=GetItemData(ttTitle       ,False);
   FBitmap      :=GetItemData(ttBitmap      ,False);
end;    
{TSnippetNode}
constructor TSnippetNode.Create(Parent:TNode;Name,FileName:String);
begin
   inherited Create(Parent,Name,FileName);
end;
destructor TSnippetNode.Destroy;
begin
   inherited Destroy;
end;
procedure TSnippetNode.SetDataElements(RootNode:TNode);
var
   Lines:TStringList;
begin
   inherited SetDataElements(RootNode);
   Lines:=TStringList.Create;
   Lines.CommaText:=GetItemData('InsertBetween',True);
   if Lines.Count >= 2 then
   begin
      FInsertBetweenStart:=Lines[0];
      FInsertBetweenEnd  :=Lines[1];
   end;
   Lines.Free;
   FCodeBlock:=GetItemData('CodeBlock',False);
   FCodeBlock:=#13#10 + '{ Snippet : ' + FNodeName + ' }'   + #13#10  //name of snippet in generated code
              + Copy(FCodeBlock,4,Length(FCodeBlock)-6) + #13#10
              + #13#10 + '{ Snippet : ' + FNodeName + ' }'  + #13#10 ;
end;
{TConstantNode}
constructor TConstantNode.Create(Parent:TNode;Name,FileName:String);
begin
   inherited Create(Parent,Name,FileName);
end;
destructor TConstantNode.Destroy;
begin
   inherited Destroy;
end;
procedure TConstantNode.SetDataElements(RootNode:TNode);
begin
   inherited SetDataElements(RootNode);
   FValue:=ParentNode.GetItemData(NodeName,False);
end;
{TProdNode}
constructor TProdNode.Create(Parent:TNode;Name,FileName:String);
begin
   inherited Create(Parent,Name,FileName);
   FBaseColor:=clBtnFace;
   FDomains:=TStringList.Create;
   FDomainParams:=TStringList.Create;
   FSnippets:=TStringList.Create;
end;
destructor TProdNode.Destroy;
begin
   FDomains.Free;
   FDomainParams.Free;
   FSnippets.Free;
   inherited Destroy;
end;
function TProdNode.GetItemNode(Index:Integer):TProdNode;
begin
   Result:=TProdNode(inherited GetItemNode(Index));
end;

procedure TProdNode.SetSelected(Value:Boolean);
begin
   if FIsSelected <> Value then
      FIsSelected:=Value;
end;
function TProdNode.GetSnippet(Index:Integer):TSnippetNode;
begin
   if (Index >= 0) and (Index < FSnippets.Count) then
      Result:=TSnippetNode(FSnippets.Objects[Index])
   else
      Result:=nil;
end;
function TProdNode.GetDomain(Index:Integer):TDomainNode;
begin
   if (Index >= 0) and (Index < FDomains.Count) then
      Result:=TDomainNode(FDomains.Objects[Index])
   else
      Result:=nil;
end;
procedure TProdNode.DrawNode(Canvas:TCanvas;JustSubs:Boolean);
var
   ProdR:TRect;
   PC,BC,FC:TColor;
begin
   Expander(Canvas,FXCoord,FYCoord,FExpWidth,HasChild,IsExpanded);
   with Canvas do
   begin
      PC:=Pen.Color;
      FC:=Font.Color;
      BC:=Brush.Color;
      ProdR:=Rect(FXCoord+FExpWidth,FYCoord+1,GetWidth(Canvas,FIndent+1)-1,GetHeight(Canvas,FYCoord)-3);
      Brush.Color:=BaseColor;
      Pen.Color:=BaseColor;
      with ProdR do
      begin
         Rectangle(Left,Top,Right,Bottom);
         InflateRect(ProdR,-1,-1);
         if IsSelected then Pen.Color:=clBtnShadow else Pen.Color:=clBtnHighLight;
         PolyLine([Point(Left,Bottom),Point(Left,Top),Point(Right,Top)]);
         if IsSelected then Pen.Color:=clBtnHighLight else Pen.Color:=clBtnShadow;
         PolyLine([Point(Left,Bottom),Point(Right,Bottom),Point(Right,Top)]);
         
         InflateRect(ProdR,-1,-1);
         if IsSelected then Pen.Color:=clBtnShadow else Pen.Color:=clBtnHighLight;
         PolyLine([Point(Left,Bottom),Point(Left,Top),Point(Right,Top)]);
         if IsSelected then Pen.Color:=clBtnHighLight else Pen.Color:=clBtnShadow;
         PolyLine([Point(Left,Bottom),Point(Right,Bottom),Point(Right,Top)]);
      end;
      Font.Color:=clBlack;
      Font.Style:=[fsBold];
      TextOut(FXCoord+FExpWidth+5,FYCoord+4,NodeName);
      Font.Style:=[];
      Font.Color:=FC;
      Pen.Color:=PC;
      inherited DrawNode(Canvas,True);
      Brush.Color:=BC;
   end;
end;
function TProdNode.GetWidth(Canvas:TCanvas;Indent:Integer):Integer;
var
   W,I:Integer;
begin
   Canvas.Font.Style:=[fsBold];
   FWidth:=Canvas.TextWidth(FNodeName)+6;
   Canvas.Font.Style:=[];
   if HasChild then
      FExpWidth:=Canvas.TextHeight('Wg')
   else
      FExpWidth :=0;
   FIndent:=Indent-1;
   FXCoord:=FIndent*Canvas.TextHeight('Wg');
   Result:=FXCoord+FWidth+FExpWidth;
   if IsExpanded then
   begin
      for I:=0 to Count-1 do
      begin
         W:=Node[I].GetWidth(Canvas,Indent+2);
         if W > Result then Result:=W;
      end;
   end;
   Inc(Result,4);
end;
function TProdNode.GetHeight(Canvas:TCanvas;YOffset:Integer):Integer;
var
   I:Integer;
begin
   Canvas.Font.Style:=[fsBold];
   FHeight:=Canvas.TextHeight('Wg')+6;
   Canvas.Font.Style:=[];
      
   FYCoord:=YOffset;
   Result:=FYCoord+FHeight;
   
   if IsExpanded then
   begin
      for I:=0 to Count-1 do
         Result:=Node[I].GetHeight(Canvas,Result);
      Inc(Result,6);
   end
   else
   begin
      Inc(Result,4);
   end;
end;   
procedure TProdNode.SetDataElements(RootNode:TNode);
var
   DomainsNode:TNode;
   SnippetsNode:TNode;
   I:Integer;
begin
   inherited SetDataElements(RootNode);
   FBarCode     :=GetItemData(ttBarCode     ,False);
   FDescription :=GetItemData(ttDescription ,False);
   FEndDate     :=GetItemData(ttEndDate     ,False);
   FHighDays    :=GetItemData(ttHighDays    ,False);
   FMCRCode     :=GetItemData(ttMCRCode     ,False);
   FOCRCode     :=GetItemData(ttOCRCode     ,False);
   FOtherCode   :=GetItemData(ttOtherCode   ,False);
   FRegulations :=GetItemData(ttRegulations ,True);
   FStartDate   :=GetItemData(ttStartDate   ,False);
   FUseDays     :=GetItemData(ttUseDays     ,False);
   FTaxes        :=GetItemData(ttTaxes        ,False);
   FMOPs         :=GetItemData(ttMOPs         ,False);
   if SelectNode(ttAvailAfterEOD) <> Self then
      FAvailAfterEOD:=True
   else
      FAvailAfterEOD:=False;
   FPrompt      :=GetItemData(ttPrompt      ,False);
   FHint        :=GetItemData(ttHint        ,False);
   FUnitQuantity:=GetItemData(ttUnitQuantity,False);
   FMaxQuantity :=GetItemData(ttMaxQuantity ,False);
   FMinQuantity :=GetItemData(ttMinQuantity ,False);
   FPLU         :=GetItemData(ttPLU         ,False);
   FUnitPrice   :=GetItemData(ttUnitPrice   ,False);
   FLogAs       :=GetItemData(ttLogAs       ,False);
   FPrintList   :=GetItemData(ttPrintList   ,True);
   FFillList    :=GetItemData(ttFillList   ,True);
   FEndorse     :=GetItemData(ttEndorse     ,True);
   FCustomer    :=GetItemData(ttCustomer    ,True);
   FDomains.CommaText:=GetItemData(ttDomains,True );
   FSnippets.CommaText:=GetItemData(ttSnippets,True );
   for I:=0 to FDomains.Count-1 do
   begin
      DomainsNode:=SelectNode(ttDomains);
      if DomainsNode <> Self then
         FDomainParams.Add(Trim(DomainsNode.GetItemData(FDomains[I],True)))
      else
         FDomainParams.Add('');
   end;   
   DomainsNode:=RootNode.SelectNode(ttDomains);
   if DomainsNode <> RootNode then
   begin
       for I:=0 to FDomains.Count-1 do
       begin
          if DomainsNode.SelectNode(FDomains[I]) <> DomainsNode then
          FDomains.Objects[I]:=DomainsNode.SelectNode(FDomains[I]);
       end;
   end;
   SnippetsNode:=RootNode.SelectNode(ttSnippets);
   if SnippetsNode <> RootNode then
   begin
       for I:=0 to FSnippets.Count-1 do
       begin
          if SnippetsNode.SelectNode(FSnippets[I]) <> SnippetsNode then
          FSnippets.Objects[I]:=SnippetsNode.SelectNode(FSnippets[I]);
       end;
   end;
   if Title = '' then 
   begin
      if Description <> '' then
         Title:=Description
      else if Caption <> '' then
         Title:=Caption
      else if RegDesc <> '' then
         Title:=RegDesc
      else
         Title:=NodeName+' Product'
   end;
   if Description = '' then Description:=Title;
end;
{TGroupNode}
procedure TGroupNode.SetDataElements(RootNode:TNode);
begin
   inherited SetDataElements(RootNode);
   FPrompt  :=GetItemData(ttPrompt  ,False); 
   FHint    :=GetItemData(ttHint    ,False);
   if Title = '' then 
   begin
      if RegDesc <> '' then
         Title:=RegDesc
      else
         Title:=NodeName+' Product';
   end;
end;
{TWUGroupNode}
function TWUGroupNode.GetWidth(Canvas:TCanvas;Indent:Integer):Integer;
begin
   Result:=inherited GetWidth(Canvas,Indent);
end;
function TWUGroupNode.GetHeight(Canvas:TCanvas;YOffset:Integer):Integer;
begin
   Result:=inherited GetHeight(Canvas,YOffset);
end;
{TWGroupNode}
procedure TWGroupNode.DrawNode(Canvas:TCanvas;JustSubs:Boolean);
begin
   inherited DrawNode(Canvas,JustSubs);
end;
{TUGroupNode}
procedure TUGroupNode.DrawNode(Canvas:TCanvas;JustSubs:Boolean);
begin
   Canvas.Pen.Color:=clBlue;
   inherited DrawNode(Canvas,JustSubs);
end;
{TPickListNode}
constructor TPickListNode.Create(Parent:TNode;Name,FileName:String);
begin
   inherited Create(Parent,Name,FileName);
   FItems:=TStringList.Create;
   FZones:=TStringList.Create;
   FSorted:=False;
end;
destructor TPickListNode.Destroy;
begin
   FItems.Free;
   FZones.Free;
   inherited Destroy;
end;     
procedure TPickListNode.SetDataElements(RootNode:TNode);
var
   I,J:Integer;
   SL:TStringList;
begin
   inherited SetDataElements(RootNode);
   FDefaultItem:=GetItemData('Default',False);
   for I:=0 to Count-1 do
   begin
      if (Name[I] <> 'Default') and (Name[I] <> 'Sorted') and (Name[I] <> ttSubGroup) then
      begin                        
         for J:=0 to Node[I].Count-1 do
         begin
            if Strip(Node[I].Name[J]) = FDefaultItem then
               FItems.AddObject(' '+Strip(Node[I].Name[J]),TObject(FItems.Count))
            else
               FItems.AddObject(Strip(Node[I].Name[J]),TObject(FItems.Count));
            FZones.Add(Name[I]);
         end;
      end
      else if Name[I] = 'Sorted' then
      begin
         FSorted:=True;
      end;
   end;
   if FSorted then
   begin
      SL:=TStringList.Create;
      FItems.Sort;
      for I:=0 to FItems.Count-1 do SL.Add('');
      for I:=0 to FItems.Count-1 do SL[I]:=FZones[Integer(FItems.Objects[I])];
      for I:=0 to FItems.Count-1 do 
      begin
         FItems[I]:=Trim(FItems[I]);
         FZones[I]:=SL[I];
      end;
      SL.Free;
   end;
end;
constructor TLookUpNode.Create(Parent:TNode;Name,FileName:String);
begin
   inherited Create(Parent,Name,FileName);
   FRanges   :=TStringList.Create;
   FZones    :=TStringList.Create;
   FZoneNames:=TStringList.Create;
end;
destructor TLookUpNode.Destroy;
begin
   FRanges   .Free;
   FZones    .Free;
   FZoneNames.Free;
   inherited Destroy;
end;     
procedure TLookUpNode.SetDataElements(RootNode:TNode);
var
   I,J:Integer;
begin
   inherited SetDataElements(RootNode);
   for I:=0 to Count-1 do            
   begin
      if Name[I] = 'Range' then
      begin
         for J:=0 to Node[I].Count-1 do
            FRanges.Add(Strip(Node[I].Name[J]));
      end
      else if Name[I] <> ttSubGroup then
      begin
         FZoneNames.Add(Name[I]);
         for J:=0 to Node[I].Count-1 do
            FZones.Add(Strip(Node[I].Name[J]));
      end;
   end;
end;

{TConstantsNode}
function TConstantsNode.GetItemByName(Name:String):TConstantNode;
var
   Node:TNode;
begin
   Result:=nil;
   if Name = '' then Exit;
   Node:=SelectNode(Name);
   if Node = Self then Node:=nil;
   Result:=TConstantNode(Node);
end;
function TConstantsNode.AsString:String;
var
   SL:TStringList;
   CN:TConstantNode;
   I:Integer;
begin
   Result:='';
   if Count < 1 then Exit; 
   SL:=TStringList.Create;
   SL.Add('');
   SL.Add('const');
   for I:=0 to Count-1 do
   begin
      CN:=TConstantNode(Node[I]);
      SL.Add('   '+CN.NodeName+' = '''+CN.Value+''';');
   end;
   SL.Add('');
   Result:=SL.Text;
   SL.Free;
end;
function TConstantsNode.GetNode(Index:Integer):TConstantNode;
begin
   Result:=TConstantNode(inherited Node[Index]);
end;       
{TSnippetsNode}
function TSnippetsNode.GetItemByName(Name:String):TSnippetNode;
var
   Node:TNode;
begin
   Node:=SelectNode(Name);
   if Node = Self then Node:=nil;
   Result:=TSnippetNode(Node);
end;
function TSnippetsNode.GetNode(Index:Integer):TSnippetNode;
begin
   Result:=TSnippetNode(inherited Node[Index]);
end;       
{TProductsNode}
function TProductsNode.GetItemByName(Name:String):TProdNode;
var
   Node:TNode;
begin
   Node:=SelectNode(Name);
   if Node = Self then Node:=nil;
   Result:=TProdNode(Node);
end;
function TProductsNode.GetNode(Index:Integer):TProdNode;
begin
   Result:=TProdNode(inherited Node[Index]);
end;
{TGroupsNode}
function TGroupsNode.GetItemByName(Name:String):TGroupNode;
var
   Node:TNode;
begin
   Node:=SelectNode(Name);
   if Node = Self then Node:=nil;
   Result:=TGroupNode(Node);
end;
function TGroupsNode.GetNode(Index:Integer):TGroupNode;
begin
   Result:=TGroupNode(inherited Node[Index]);
end;
{TDomainsNode}
function TDomainsNode.GetNode(Index:Integer):TDomainNode;
begin
   Result:=TDomainNode(inherited GetNode(Index));
end;
function TDomainsNode.GetItemByName(Name:String):TDomainNode;
var
   Node:TNode;
begin
   Node:=SelectNode(Name);
   if Node = Self then Node:=nil;
   Result:=TDomainNode(Node);
end;
{TUsersNode}
function TUsersNode.GetNode(Index:Integer):TUGroupNode;
begin
   Result:=TUGroupNode(inherited Node[Index]);
end;
function TUsersNode.GetItemByName(Name:String):TUGroupNode;
var
   Node:TNode;
begin
   Node:=SelectNode(Name);
   if Node = Self then Node:=nil;
   Result:=TUGroupNode(Node);
end;
{TWorkStationsNode}
function TWorkStationsNode.GetNode(Index:Integer):TWGroupNode;
begin
   Result:=TWGroupNode(inherited Node[Index]);
end;
function TWorkStationsNode.GetItemByName(Name:String):TWGroupNode;
var
   Node:TNode;
begin
   Node:=SelectNode(Name);
   if Node = Self then Node:=nil;
   Result:=TWGroupNode(Node);
end;
{TLookUpsNode}
function TLookUpsNode.GetItemByName(Name:String):TLookUpNode;
var
   Node:TNode;
begin
   Node:=SelectNode(Name);
   if Node = Self then Node:=nil;
   Result:=TLookUpNode(Node);
end;
function TLookUpsNode.GetNode(Index:Integer):TLookUpNode;
begin
   Result:=TLookUpNode(inherited Node[Index]);
end;
{TPickListsNode}
function TPickListsNode.GetItemByName(Name:String):TPickListNode;
var
   Node:TNode;
begin
   Node:=SelectNode(Name);
   if Node = Self then Node:=nil;
   Result:=TPickListNode(Node);
end;
function TPickListsNode.GetNode(Index:Integer):TPickListNode;
begin
   Result:=TPickListNode(inherited Node[Index]);
end;
procedure TRootNode.SetDataElements(RootNode:TNode);
var
   Node:TNode;
begin
   Node:=SelectNode(ttConstants); 
   if Node = Self then 
   begin
      FConstants:=nil
   end
   else 
   begin
      FConstants:=TConstantsNode(Node);
      FConstants.SetDataElements(RootNode);
      SetConstants(FConstants);
   end;
   inherited SetDataElements(RootNode);
   Node:=SelectNode(ttDomains     ); if Node = Self then FDomains     :=nil else FDomains     :=TDomainsNode     (Node);
   Node:=SelectNode(ttProducts    ); if Node = Self then FProducts    :=nil else FProducts    :=TProductsNode    (Node);
   Node:=SelectNode(ttSnippets     ); if Node = Self then FSnippets     :=nil else FSnippets     :=TSnippetsNode     (Node);
   Node:=SelectNode(ttGroups      ); if Node = Self then FGroups      :=nil else FGroups      :=TGroupsNode      (Node);
   Node:=SelectNode(ttLookUps     ); if Node = Self then FLookUps     :=nil else FLookUps     :=TLookUpsNode     (Node);
   Node:=SelectNode(ttPickLists   ); if Node = Self then FPickLists   :=nil else FPickLists   :=TPickListsNode   (Node);
   Node:=SelectNode(ttUsers       ); if Node = Self then FUsers       :=nil else FUsers       :=TUsersNode       (Node);
   Node:=SelectNode(ttWorkStations); if Node = Self then FWorkStations:=nil else FWorkStations:=TWorkStationsNode(Node);
   Node:=SelectNode(ttBuildOptions); if Node = Self then FBuildOptions:=nil else FBuildOptions:=TOptionsNode     (Node);
   Node:=SelectNode(ttLogFormats  ); if Node = Self then FLogFormats  :=nil else FLogFormats  :=TLogFormatsNode  (Node);
end;
{TLogFormatNode}
procedure TLogFormatNode.SetDataElements(RootNode:TNode);
begin
   inherited SetDataElements(RootNode);
   FFormat:=ParentNode.GetItemData(NodeName,True);
end;
{TLogFormatsNode}
function TLogFormatsNode.GetNode(Index:Integer):TLogFormatNode;
begin
   Result:=TLogFormatNode(inherited Node[Index]);
end;
function TLogFormatsNode.GetItemByName(Name:String):TLogFormatNode;
var
   Node:TNode;
begin
   Node:=SelectNode(Name);
   if Node = Self then Node:=nil;
   Result:=TLogFormatNode(Node);
end;
  
{TParser}
constructor TParser.Create(FileName:String);
var
   SL:TStringList;
begin
   inherited Create;
   CurrentFileList:=TStringList.Create;
   SL:=TStringList.Create;
   Nodes:=nil;
   Terminate:=ttReload;
   while (Terminate = ttReload) do
   begin
      Terminate:=ttIgnore;
      CurrentFileList.Clear;
      EnterFile(FileName);
      SL.LoadFromFile(FileName);
      TextBuffer:=SL.Text;
      if Nodes <> nil then
         Nodes.Free;
      Nodes:=TRootNode.Create(nil,'',FileName);
      PreParse(ExtractFilePath(FileName));
      Parse;
   end;
   Nodes.SetDataElements(Nodes);
   Nodes.IsExpanded:=True;
   SL.Free;
end;                 
destructor TParser.Destroy;
begin
   CurrentFileList.Free;
   Nodes.Free;
   inherited Destroy;
end;
function TParser.AsString:String;
begin
   Result:=Nodes.AsString;
end;
procedure TParser.EnterFile(FileName:String);
begin
   CurrentFileList.Add(FileName);
   CurrentFile:=FileName;
end;
procedure TParser.ExitFile(FileName:String);
begin
   if FileName <> CurrentFile then 
   begin
      if Terminate = ttIgnore then
      begin
         ParseError.ErrorMessage.Caption:='Error on exit from '+#10+FileName+#10+' Possible missing ''}''';
         ParseError.ShowModal;
         case ParseError.ModalResult of
            mrOK     : Terminate:=ttContinue;
            mrIgnore : Terminate:=ttIgnore;
            mrRetry  : Terminate:=ttReload;
            mrAbort  : Terminate:=ttAbort;
            else Terminate:=ttContinue;
         end;      
      end;
   end;
   CurrentFileList.Delete(CurrentFileList.Count-1);
   CurrentFile:=CurrentFileList[CurrentFileList.Count-1];
end;
function TParser.GetToken(var P:PChar;var IsIdent:Boolean):String;
var
  Last:Char;
  FileName:String;
begin
  Result:='';
  IsIdent:=False;
  while ((P^ <> #0) and (P^ <= ' ')) or (P^ = ',') do Inc(P); // remove whitespace
  while (P^ = '/') do // remove commenting
  begin
     Inc(P);
     if (P^ = '/') then // single line commenting '// .. EOL'
     begin
        while (P^ <> #0) and (P^ <> #10) do Inc(P);
     end
     else if (P^ = '#') then // Start Of File Marker
     begin
        Inc(P);
        FileName:='';
        while (P^ <> #0) and (P^ <> '#') do
        begin
           FileName:=FileName+P^;
           Inc(P);
        end;
        if (P^ = '#') then Inc(P);
        EnterFile(FileName);
     end
     else if (P^ = '$') then // End Of File Marker
     begin
        Inc(P);
        FileName:='';
        while (P^ <> #0) and (P^ <> '$') do
        begin
           FileName:=FileName+P^;
           Inc(P);
        end;
        if (P^ = '$') then Inc(P);
        ExitFile(FileName);
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
           Inc(P);
        end;
     end;
     while (P^ <> #0) and (P^ <= ' ') do Inc(P); // remove whitespace
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
           Inc(P);
           Last:=' ';
           while True do
           begin
             if P^ = #0 then Exit;
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
    #0 :
      ; //end of file
    else
      begin
        ShowMessage('Invalid Token  in ' + CurrentFile + ' Token <<' + DelimitedString(PChar(P),#13,False) + '>>');
        Clipboard.AsText := DelimitedString(PChar(P),#13,False);
      end;


  end;
  if P <> TokenPtr then
  begin
     SetString(Result,TokenPtr,P-TokenPtr);
  end
end;
procedure TParser.ReParseNode(Node:TNode;var Text:PChar);
begin
   Nodes.CurrentNode:=Node.ParentNode;
   while Node.Count > 0 do
      Node.Delete(Node.Name[0]);
   Node.Modified:=True;
   ParseNode(Text);   
   Node.SetDataElements(Nodes);
end;   
procedure TParser.ParseNode(var Text:PChar);
var
   S:String;
   NodeName:String;
   IsIdent:Boolean;
   LastTok:PChar;
   LastID:PChar;
   CN:TNode;
begin
   CN:=Nodes.CurrentNode;
   NodeName:=GetToken(Text,IsIdent);
   if NodeName <> '' then
   begin
      Nodes.CurrentNode.Add(NodeName,CurrentFile);
      Nodes.CurrentNode.SelectNode(NodeName);
      LastTok:=Text;
      if IsIdent then
      begin
         if GetToken(Text,IsIdent) = '{' then
         begin
            S:=' ';
            while (S <> '}') and (S <> '') do
            begin
               LastTok:=Text;
               S:=GetToken(Text,IsIdent);
               if (S <> '{') and (S <> '}') then 
                  Nodes.CurrentNode.Add(S,CurrentFile);
               if IsIdent then 
               begin
                  LastID:=LastTok;
               end                    
               else if S = '{' then 
               begin
                  ParseNode(LastID);
                  Nodes.CurrentNode:=CN;
                  Nodes.CurrentNode.SelectNode(NodeName);
                  Text:=LastID;
               end;
            end;
            if not Nodes.CurrentNode.Modified then
               Nodes.CurrentNode.EndDPtr:=Text;
            if S = '' then 
               Text^:=#0; // Exit
         end
         else
         begin
            Text:=LastTok;
         end;
      end;
   end;
   Nodes.CurrentNode:=CN;
end;   
procedure TParser.PreParse(Path:String);
var
   FileList:TStringList;
   SL:TStringList;
   ISL:TStringList;
   I:Integer;
   FileName:String;
begin
   FileList:=TStringList.Create;
   ISL:=TStringList.Create;
   SL:=TStringList.Create;
   SL.Text:=TextBuffer;
   I:=0;
   while I < SL.Count do
   begin
      if Copy(Trim(SL[I]),1,7) = 'Include' then
      begin
         FileName:=Strip(Trim(Copy(Trim(SL[I]),8,Length(SL[I]))));
         if (Path <> '') and (FileName[1] <> '\') and (Length(FileName) > 2) and (FileName[2] <> ':') then
         begin
            if Path[Length(Path)] = '\' then
               FileName:=Path+FileName
            else
               FileName:=Path+'\'+FileName;
         end;
         SL.Delete(I);
         try
            if FileList.IndexOf(FileName) = -1 then
            begin
               FileList.Add(FileName);
               if FileExists(FileName) then
               begin
                  ISL.LoadFromFile(FileName);
                  SL.Insert(I,'/#'+FileName+'#');
                  SL.Insert(I+1,'/$'+FileName+'$');
                  SL.Insert(I+1,ISL.Text);
                  SL.Text:=SL.Text; // force Update of line count
               end
               else
               begin
                  ShowMessage('Can''t include file "'+FileName+'"');
               end;
               ISL.Clear;
            end;
         except
         end;
      end
      else
      begin
         Inc(I);
      end;
   end;
   TextBuffer:=SL.Text;
//   SL.SaveToFile('~PreParse.DAT');
   SL.Free;
   ISL.Free;
   FileList.Free;
end;
procedure TParser.Parse;
var
   DataPtr:PChar;
begin
   DataPtr:=PChar(TextBuffer);
   while (Terminate = ttIgnore) and (DataPtr^ <> #0) do
      ParseNode(DataPtr);
   if Terminate = ttAbort then
     Application.Terminate;
end;
function TParser.GetHeight(Canvas:TCanvas):Integer;
begin                              
   Result:=Nodes.GetHeight(Canvas,0);
end;                                    
function TParser.GetWidth(Canvas:TCanvas):Integer;
begin                              
   Result:=Nodes.GetWidth(Canvas,0);
end;                                    
procedure TParser.DrawNodes(Canvas:TCanvas);
begin
   Nodes.DrawNode(Canvas,False);
end;
function TParser.FindNode(X,Y:Integer;var OnExpand:Boolean):TNode;
begin 
   Result:=Nodes.FindNode(X,Y,OnExpand);
end;

end.
