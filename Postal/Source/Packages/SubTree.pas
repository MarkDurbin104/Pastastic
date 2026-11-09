{  <Synopsis>      SubTree
   <Unit>          VCL Component
   <Copyright(c)>  Postal Solutions Limited 1996..1998
   <Author>        MJD
   <Description>   Show a tree component of the Corvus registry enrties
                   and support loading components by name via the
                   component loader
   <Modifications> 02/01/98 - MJD
                              Original Release
                   09/01/98 - MJD
                              Added commenting
                   13/02/99 - MJD
                              Change Commenting format
}
unit SubTree;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,Registry,ComObj,GPCSBase_TLB,GPCSGUID,PackStrListU,UDPMessageU ;

const
   WMSTARTCM  = WM_USER;
type
  // LoadComponent Status
  TLoadState = ( lsNotLoaded, // LoadComponent hasn't been called
                 lsLoadedOK,  // LoadComponent ran successfully
                 lsError      // LoadComponent failed
                );
  // The Physical Tree Structure
  TTreeBox = class;
  TSubTree = class(TObject)
  protected
    FItems    :TPackStringList; // the List of Items (and Objects) in the tree
    FExpanded :Boolean;     // this tree node has been expanded
    FSelected :Boolean;     // this tree node has been selected
    FObject   :TObject;     // attached object

    function  Max(A,B:Integer):Integer;
    function  GetCount:Integer;
    function  GetHeight:Integer;
    function  GetItemHeight(Index:Integer):Integer;
    function  GetItemWidth(Index,Depth:Integer;Canvas:TCanvas):Integer;
    function  GetItems:TStrings;
    procedure PutItems(Value:TStrings);
    function  GetObjects(Index:Integer):TSubTree;
    procedure PutObjects(Index:Integer;Value:TSubTree);
    procedure SetExpanded(Value:Boolean);
    procedure SetSelected(Value:Boolean);
    function  FindItem(Depth:Integer;Canvas:TCanvas;var OnExpand:Boolean;var YPos:Integer;XPos,X,Y:Integer):TSubTree;
  public
    ItemHeight:Integer;   // the height of each tree node
    constructor Create;
    destructor Destroy; override;
    function  Width(Depth:Integer;Canvas:TCanvas):Integer;
    function  Add(Item:String):TSubTree;
    function  AddObject(Item:String;Obj:TSubTree):TSubTree;
    procedure ClearSelect;
    procedure Paint(Canvas:TCanvas;XPos:Integer;var YPos:Integer);
    function MouseDown(Canvas:TCanvas;X,Y:Integer;Shift:TShiftState;Button:TMouseButton):TSubTree;
    property  Count:Integer                     read GetCount;
    property  Expanded:Boolean                  read FExpanded  write SetExpanded;
    property  Selected:Boolean                  read FSelected  write SetSelected;
    property  Height:Integer                    read GetHeight;
    property  Items:TStrings                    read GetItems   write PutItems;
    property  Objects[Index:Integer]:TSubTree   read GetObjects write PutObjects;
    property  TheObject:TObject                 read FObject    write FObject;
  end;

  // One Corvus Entry from the Registry
  TGPCSRegistryEntry = class(TObject)
  protected
    FGUID          :String; // The Component's Globally Unique Identifier
    FDescription   :String; // The Component's Description
    FComponentType :String; // The Component's Type
    FServerBinary1 :String; // The Component's Binary File Name InProcess
    FServerBinary2 :String; // The Component's Binary File Name Local
    FServerBinary3 :String; // The Component's Binary File Name Remote
    FProgID        :String; // The Component's Program Identifier
    FName          :String; // The Component's Name
    FVersion       :String; // The Component's Version Number
    FLoadState:TLoadState;  // The Status of the last LoadComponent() operation
    FDLLHandle     :THandle;
    function  GetGUID         :String;
    function  GetDescription  :String;
    function  GetComponentType:String;
    function  GetServerBinary1:String;
    function  GetServerBinary2:String;
    function  GetServerBinary3:String;
    function  GetProgID       :String;
    function  GetName         :String;
    function  GetVersion      :String;
    function  GetObject       :IUnknown;
  public
    constructor Create(Key:TRegistry;CLSID,Desc:String);
    destructor Destroy; override;
    property GUID          :String     read GetGUID         ;
    property Description   :String     read GetDescription  ;
    property ComponentType :String     read GetComponentType;
    property ServerBinary1 :String     read GetServerBinary1;
    property ServerBinary2 :String     read GetServerBinary2;
    property ServerBinary3 :String     read GetServerBinary3;
    property ProgID        :String     read GetProgID       ;
    property Name          :String     read GetName         ;
    property Version       :String     read GetVersion      ;
    property Instance      :IUnknown   read GetObject       ;
    property DLLHandle     :THandle    read FDLLHandle;
    property LoadState     :TLoadState read FLoadState write FLoadState;
  end;
  // The list of all Corvus Entries arranged as a Tree
  TGPCSRegistryList = class(TSubTree)
  private
    FBackgroundLoad:Boolean;
    FReady:Boolean;
    ParentTree:TTreeBox;
    LazyI, LazyJ : integer ;
    PreLoadIntList : TStringList ;
  public
     LazyTime : TTimer ;   // by ddb, to add objects using Lazy Load
     WindowHandle:THandle;
     CurrentEntry:TGPCSRegistryEntry; // The currently selected (or clicked) Entry
     constructor Create(ComponentList:TTreeBox);
     destructor Destroy; override;
     procedure Startup(var Message:TMessage); message WMSTARTCM;
     procedure WndProc(var Message: TMessage);
     procedure AddEntry(Key:TRegistry;CLSID,Desc:String); // add a new TGPCSRegistryEntry from the Registry
     procedure LazyLoadObject(Sender: TObject) ;
     procedure LoadObjects ;
     property BackgroundLoad:Boolean read FBackgroundLoad write FBackgroundLoad;
     property Ready:Boolean read FReady;
  end;
  // The Visible Tree Structure
  TTreeBox = class(TPaintBox)
  private
    FReady:Boolean;
    function GetReady:Boolean;
  protected
    procedure Paint; override;
    procedure MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer); override;
  public
    RegList:TGPCSRegistryList; // Physical Memory Structure
    Branch:TSubTree; // Currently seleted Branch (Only valid during OnMouseDown)
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Component:TGPCSRegistryEntry;
    procedure ShowCompLoad(OnOff:Boolean);
    function GetNamedNode(Name:String):TGPCSRegistryEntry;
    procedure ReleaseAll;
  published
    property Ready:Boolean read GetReady write FReady;
  end;

procedure Register;

var
   CompLoad:ICompLoad;

implementation

uses
   ComServ2;
function GetFileDateTime(FileName: string):String;
var
   Res:Integer;
   SR:TSearchRec;
begin
   Result:='1';
   Res:=FindFirst(FileName,$FFFF,SR);
   if Res = 0 then
   begin
      Result:=IntToStr(SR.Time);
      FindClose(SR);
   end;
end;

{ TSubTree }

{===============================================================================
  Class        TSubTree
  Method       Max
  Description  Return the Maximum of two integers
  Params       Two integers
  Result       The largest
________________________________________________________________________________}
function TSubTree.Max(A,B:Integer):Integer;
begin
   if A > B then Result:=A else Result:=B;
end;
{===============================================================================
  Class        TSubTree
  Method       Create
  Description  creation/initialisation routine
  Params       None
  Result       None
________________________________________________________________________________}
constructor TSubTree.Create;
begin
   FItems:=TPackStringList.Create; // a list of items
   FExpanded:=False;           // not expanded
   FSelected:=False;           // not selected
   FObject:=nil;               // with no object attached
   ItemHeight:=14;             // and a default height of 14 pixels

end;
{===============================================================================
  Class        TSubTree
  Method       Destroy
  Description  cleanup/free routine
  Params       None
  Result       None
________________________________________________________________________________}
destructor TSubTree.Destroy;
var
   I:Integer;
begin
   for I:=0 to Count-1 do // go through list freeing any associated objects
   begin
      if Objects[I] <> nil then
      begin
         Objects[I].Free;
         Objects[I]:=nil;
      end;
   end;
   FItems.Free; // free list
   FItems:=nil;
   if FObject <> nil then FObject.Free; // free any associated object
   FObject:=nil;
   inherited Destroy;
end;
{===============================================================================
  Class        TSubTree
  Method       GetHeight
  Description  Returns the height of this node in lines of text
               i.e. the returned value must be multiplied by 'ItemHeight'
                    to calculate the Painted height
  Params       None
  Result       height of this node in lines
________________________________________________________________________________}
function TSubTree.GetHeight:Integer;
var
   I:Integer;
begin
   Result:=1;
   for I:=0 to Count-1 do
      Inc(Result,GetItemHeight(I)); // call Get Item Height for each branch
end;
{===============================================================================
  Class        TSubTree
  Method       GetItemHeight
  Description  Calculate the height (in lines) of a branch
  Params       the index of the branch in the tree
  Result       the height (0 if Index out of range)
________________________________________________________________________________}
function TSubTree.GetItemHeight(Index:Integer):Integer;
begin
   Result:=0;                           // set height to Zero
   
   if (Index < 0) 
   or (Index >= Count) then Exit;       // Index out of range
      
   if  (Objects[Index] <> nil   )       // if there is a connected object
   and (Objects[Index].Count > 0)       // and it has more than 0 items 
   and (Objects[Index].Expanded ) then  // and it is currently expanded
      Inc(Result,Objects[Index].Height) // then calculate it's height
   else
      Inc(Result);                      // otherwise the height is 1
end;
{===============================================================================
  Class        TSubTree
  Method       Width
  Description  Return the Painted Width of a Tree
  Params       Depth : The depth of the node indentation
               Canvas: The canvas it is painted on (needed for 'TextWidth')
  Result       The Width of a Tree node
________________________________________________________________________________}
function TSubTree.Width(Depth:Integer;Canvas:TCanvas):Integer;
var
   I:Integer;
begin
   Result:=1;
   for I:=0 to Count-1 do // Get the maximum width of each Branch
      Result:=Max(Result,GetItemWidth(I,Depth,Canvas)); 
   Inc(Result,5) // add a border to the paintbox
end;
{===============================================================================
  Class        TSubTree
  Method       GetItemWidth
  Description  Return a Tree Node width
  Params       Index : The index of the node in the list
               Depth : The depth of the node indentation
               Canvas: The canvas it is painted on (needed for 'TextWidth')
  Result       The Tree Node width (0 if Index out of range)
________________________________________________________________________________}
function TSubTree.GetItemWidth(Index,Depth:Integer;Canvas:TCanvas):Integer;
begin
   Result:=0;                           // set height to Zero
   
   if (Index < 0) 
   or (Index >= Count) then Exit;       // Index out of range
   
   if  (Objects[Index] <> nil   )       // if there is a connected object
   and (Objects[Index].Count > 0)       // and it has more than 0 items 
   and (Objects[Index].Expanded ) then  // and it is currently expanded
      Result:=Max(Result,Objects[Index].Width(Depth+1,Canvas)) // Calculate width
   else // otherwise calculate Textwidth + area for Box
      Result:=Max(Result,ItemHeight+Depth*ItemHeight+Canvas.TextWidth(Items[Index]));
end;
{===============================================================================
  Class        TSubTree
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
procedure TSubTree.ClearSelect;
var
   I:Integer;
begin
   for I:=0 to Count-1 do
      if Objects[I] <> nil then Objects[I].ClearSelect;
   Selected:=False;
end;
{===============================================================================
  Class        TSubTree
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
function TSubTree.GetItems:TStrings;
begin
   Result:=FItems;
end;
{===============================================================================
  Class        TSubTree
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
procedure TSubTree.PutItems(Value:TStrings);
begin
   FItems.Free;
   FItems:=nil;
   FItems:=TPackStringList.Create;
   FItems.Assign(Value);
end;        
{===============================================================================
  Class        TSubTree
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
function TSubTree.GetObjects(Index:Integer):TSubTree;
begin
   if Index < Count then
      Result:=TSubTree(FItems.Objects[Index])
   else
      Result:=nil;
end;
{===============================================================================
  Class        TSubTree
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
procedure TSubTree.PutObjects(Index:Integer;Value:TSubTree);
begin
   if Index < Count then
      FItems.Objects[Index]:=Value;
end;
{===============================================================================
  Class        TSubTree
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
function TSubTree.Add(Item:String):TSubTree;
begin
   Result:=TSubTree.Create;
   FItems.AddObject(Item,Result);
end;
{===============================================================================
  Class        TSubTree
  Method
  Description
  Params       None
  Result       None
________________________________________________________________________________}
function TSubTree.AddObject(Item:String;Obj:TSubTree):TSubTree;
begin
   Result:=Obj;
   FItems.AddObject(Item,Result);
end;
{===============================================================================
  Class        TSubTree
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
procedure TSubTree.SetExpanded(Value:Boolean);
begin
   if FExpanded <> Value then
   begin
      FExpanded:=Value;
   end;
end;
{===============================================================================
  Class        TSubTree
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
procedure TSubTree.SetSelected(Value:Boolean);
begin
   if FSelected <> Value then
   begin
      FSelected:=Value;
   end;
end;
{===============================================================================
  Class        TSubTree
  Method
  Description
  Params       None
  Result       None
________________________________________________________________________________}
procedure TSubTree.Paint(Canvas:TCanvas;XPos:Integer;var YPos:Integer);
var
   I:Integer;
   BC:TColor;
   FC:TColor;
   TopYPos:Integer;
   LoadState:TLoadState;
begin
   with Canvas do
   begin
      BC:=Brush.Color;
      FC:=Font.Color;
      for I:=0 to Count-1 do
      begin
         if (Objects[I] <> nil) and (Objects[I].Selected) then
         begin
            Font.Color :=clHighLightText;
            if Objects[I].TheObject <> nil then
            begin
               LoadState:=TGPCSRegistryEntry(Objects[I].TheObject).LoadState;
               if LoadState = lsLoadedOK then
                  Font.Color :=clLime
               else if LoadState = lsError then
                  Font.Color :=clRed;
            end;
            Brush.Color:=clHighLight;
            if Objects[I].Count > 0 then
               TextOut(XPos+ItemHeight,YPos*ItemHeight,FItems.Strings[I])
            else
               TextOut(XPos+2,YPos*ItemHeight,FItems.Strings[I]);
            Brush.Color:=BC;
            Font.Color :=FC;
         end
         else
         begin
            if (Objects[I] <> nil) and (Objects[I].Count > 0) then
            begin
               if Objects[I].TheObject <> nil then
               begin
                  LoadState:=TGPCSRegistryEntry(Objects[I].TheObject).LoadState;
                  if LoadState = lsLoadedOK then
                     Font.Color :=clGreen
                  else if LoadState = lsError then
                     Font.Color :=clRed;
                  TextOut(XPos+ItemHeight,YPos*ItemHeight,FItems.Strings[I]);
                  Font.Color :=FC;
               end
               else
               begin
                  TextOut(XPos+ItemHeight,YPos*ItemHeight,FItems.Strings[I])
               end;
            end
            else
            begin
               TextOut(XPos+2,YPos*ItemHeight,FItems.Strings[I]);
            end;
         end;   
         TopYPos:=YPos;
         Inc(YPos);
         if (Objects[I] <> nil) and (Objects[I].Count > 0) then
         begin
            Pen.Color:=clBlue;
            Rectangle(XPos+1,(YPos-1)*ItemHeight+2,XPos+ItemHeight-2,(YPos)*ItemHeight-1);
            MoveTo(XPos+3,((YPos-1)*ItemHeight)+(ItemHeight div 2));
            LineTo(XPos+ItemHeight-4,((YPos-1)*ItemHeight)+(ItemHeight div 2));
            if Objects[I].Expanded then 
            begin
               Objects[I].Paint(Canvas,XPos+ItemHeight,YPos)
            end
            else
            begin
               MoveTo(XPos+(ItemHeight div 2)-1,(YPos-1)*ItemHeight+4);
               LineTo(XPos+(ItemHeight div 2)-1,(YPos)*ItemHeight-3);
            end;
         end;
         if XPos <> 0 then
         begin
            MoveTo(XPos+1,(TopYPos*ItemHeight)+(ItemHeight div 2));
            LineTo(XPos-((ItemHeight div 2)+1),(TopYPos*ItemHeight)+(ItemHeight div 2));
            if ((Count = 1) or (I <> Count-1)) then
            begin
               if Count = 1 then
               begin
                  MoveTo(XPos-((ItemHeight div 2)+1),TopYPos*ItemHeight-1);
                  LineTo(XPos-((ItemHeight div 2)+1),TopYPos*ItemHeight+(ItemHeight div 2)+1);
               end
               else
               begin
                  MoveTo(XPos-((ItemHeight div 2)+1),TopYPos*ItemHeight-1);
                  LineTo(XPos-((ItemHeight div 2)+1),YPos*ItemHeight+(ItemHeight div 2)+1);
               end;
            end;
         end;
      end;  
   end;
end;
{===============================================================================
  Class        TSubTree
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
function TSubTree.GetCount:Integer;
begin
   if FItems <> nil then
   begin
      try
         Result:=FItems.Count;
      except
         Result:=0;
      end;
   end
   else
   begin
      Result:=0;
   end;
end;
{===============================================================================
  function
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
function Within(Rect:TRect;Point:TPoint):Boolean;
begin
   Result:=     (Point.X >= Rect.Left) and (Point.X <= Rect.Right )
            and (Point.Y >= Rect.Top ) and (Point.Y <= Rect.Bottom);
end;
{===============================================================================
  Class        TSubTree
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
function TSubTree.FindItem(Depth:Integer;Canvas:TCanvas;var OnExpand:Boolean;var YPos:Integer;XPos,X,Y:Integer):TSubTree;
var
   W,I:Integer;
   R:TRect;
begin
   Result:=nil;
   for I:=0 to Count-1 do
   begin
      W:=ItemHeight+Canvas.TextWidth(Items[I]);
      R:=Bounds(XPos,YPos*ItemHeight,W,ItemHeight);
      if Within(R,Point(X,Y)) then 
      begin 
         R.Right:=R.Left+ItemHeight;
         if Within(R,Point(X,Y)) then OnExpand:=True;
         Result:=Objects[I];
         Exit;
      end;
      Inc(YPos);
      if (Objects[I] <> nil) and (Objects[I].Expanded) then
      begin
         Result:=Objects[I].FindItem(Depth+1,Canvas,OnExpand,YPos,XPos+ItemHeight,X,Y);
         if Result <> nil then 
            Exit;
      end;            
   end;
end;
{===============================================================================
  Class        TSubTree
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
function TSubTree.MouseDown(Canvas:TCanvas;X,Y:Integer;Shift:TShiftState;Button:TMouseButton):TSubTree;
var
   OnExpand:Boolean;
   Depth:Integer;
   YPos:Integer;
begin
   OnExpand:=False;
   YPos:=0;
   Depth:=0;
   Result:=FindItem(Depth,Canvas,OnExpand,YPos,0,X,Y);
   if Result <> nil then
   begin
      if not (ssCtrl in Shift) then ClearSelect;
      if OnExpand then 
      begin
         if Result.Expanded then
            Result.Expanded:=False
         else
            Result.Expanded:=True;
      end
      else
      begin
         Result.Selected:=True;
      end;
   end;
end;          

{===============================================================================
  Class        TGPCSRegistryEntry
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
constructor TGPCSRegistryEntry.Create(Key:TRegistry;CLSID,Desc:String);
var
   I:Integer;
begin
   FGUID          :=CLSID;
   FDescription   :=Desc;
   FVersion       :='1';
   FLoadState     :=lsNotLoaded;
   FDLLHandle     :=0;
   with Key do
   begin
      if OpenKey('CLSID\'+CLSID+'\GPCS',False) then
      begin
         FComponentType:=ReadString('');
         CloseKey;
      end;
      if OpenKey('CLSID\'+CLSID+'\GPCS\Version',False) then
      begin
         FVersion:=ReadString('');
         CloseKey;
      end;
      if OpenKey('CLSID\'+CLSID+'\ProgID',False) then
      begin
         FProgID:=ReadString('');
         CloseKey;
      end;
      if OpenKey('CLSID\'+CLSID+'\RemoteServer32',False) then
      begin
         FServerBinary3:=ReadString('');
         CloseKey;
         FVersion:=GetFileDateTime(FServerBinary3);
      end;
      if OpenKey('CLSID\'+CLSID+'\LocalServer32',False) then
      begin
         FServerBinary2:=ReadString('');
         CloseKey;
         FVersion:=GetFileDateTime(FServerBinary2);
      end;
      if OpenKey('CLSID\'+CLSID+'\InProcServer32',False) then
      begin
         FServerBinary1:=ReadString('');
         CloseKey;
         FVersion:=GetFileDateTime(FServerBinary1);
      end;
   end;
   for I:=1 to Length(ProgID) do
   begin
      if ProgID[I] = '.' then
      begin
         if ComponentType = '' then
           FComponentType:=Copy(ProgID,1,I-1);
         FName:=Copy(ProgID,I+1,999);
         break;
      end;
   end;
end;
{===============================================================================
  Class        TGPCSRegistryEntry
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
destructor TGPCSRegistryEntry.Destroy;
begin
   inherited Destroy;
end;
{===============================================================================
  Class        TGPCSRegistryEntry
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
function TGPCSRegistryEntry.GetGUID:String;
begin
   Result:=FGUID;
end;
{===============================================================================
  Class        TGPCSRegistryEntry
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
function TGPCSRegistryEntry.GetDescription:String;
begin
   Result:=FDescription;
end;
{===============================================================================
  Class        TGPCSRegistryEntry
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
function TGPCSRegistryEntry.GetComponentType:String;
begin
   Result:=FComponentType;
end;
{===============================================================================
  Class        TGPCSRegistryEntry
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
function TGPCSRegistryEntry.GetServerBinary1:String;
begin
   Result:=FServerBinary1;
end;
function TGPCSRegistryEntry.GetServerBinary2:String;
begin
   Result:=FServerBinary2;
end;
function TGPCSRegistryEntry.GetServerBinary3:String;
begin
   Result:=FServerBinary3;
end;
{===============================================================================
{===============================================================================
  Class        TGPCSRegistryEntry
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
function TGPCSRegistryEntry.GetProgID:String;
begin
   Result:=FProgID;
end;
{===============================================================================
  Class        TGPCSRegistryEntry
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
function TGPCSRegistryEntry.GetName:String;
begin
   Result:=FName;
end;
{===============================================================================
  Class        TGPCSRegistryEntry
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
function TGPCSRegistryEntry.GetVersion:String;
begin
   Result:=FVersion;
end;
{===============================================================================
  Class        TGPCSRegistryEntry
  Method
  Description
  Params       None
  Result       None
________________________________________________________________________________}
function TGPCSRegistryEntry.GetObject:IUnknown;
type
   TGetIComponent = function:IComponent;
var
   GetIComponent:TGetIComponent;
begin
   Result:=nil;
   if  ((GetGPCSRegString('Component Manager\Loading','Type','') <> 'CompLoad')
        and(Copy(OSVersion, 0, 2) <> 'NT')) // always use compload for NT to avoid runtime 226 TLS error
   and (Copy(ExtractFileName(FServerBinary1),2,1) = '_') then
   begin
      if DLLHandle = 0 then
         FDLLHandle:=LoadLibrary(PChar(FServerBinary1));
      @GetIComponent:=GetProcAddress(DLLHandle,'GetIComponent');
      if @GetIComponent <> nil then
      begin
         Result:=GetIComponent;
      end
      else
      begin
         if CompLoad = nil then
            CompLoad:=CreateOleObject('Support.CompLoad') as ICompLoad;
         Result:=CompLoad.LoadComponent(FGUID);
      end;
   end
   else
   begin
      if CompLoad = nil then
         CompLoad:=CreateOleObject('Support.CompLoad') as ICompLoad;
      Result:=CompLoad.LoadComponent(FGUID);
   end;
   if VarIsEmpty(Result) then
      FLoadState:=lsError
   else
      FLoadState:=lsLoadedOK;
end;
{===============================================================================
  Class        TTreeBox
  Method
  Description
  Params       None
  Result       None
________________________________________________________________________________}
constructor TTreeBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Canvas.Brush.Color := clWindow;
  RegList:=TGPCSRegistryList.Create(Self);

end;
{===============================================================================
  Class        TTreeBox
  Method
  Description
  Params       None
  Result       None
________________________________________________________________________________}
destructor TTreeBox.Destroy;
begin

  if RegList <> nil then
     RegList.Free;

  CompLoad:=nil;
  
  inherited Destroy;

end;
function TTreeBox.GetReady:Boolean;
begin
   if (RegList = nil) or (not RegList.Ready) then
      Result:=False
   else
      Result:=True
end;   
{===============================================================================
  Class        TTreeBox
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
procedure TTreeBox.Paint;
var
   YPos:Integer;
begin
   if (RegList = nil) or (not RegList.Ready) then
   begin
      with Canvas do
         TextOut(0,0,'Reading Registry...');
   end
   else
   begin
      Height:=RegList.Height*RegList.ItemHeight;
      Width:=RegList.Width(0,Canvas);
      YPos:=0;
      RegList.Paint(Canvas,0,YPos);
      if Assigned(OnPaint) then OnPaint(Self);
   end;
end;
{===============================================================================
  Class        TTreeBox
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
procedure TTreeBox.MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
begin
   if (RegList = nil) or (not RegList.Ready) then Exit;
   Branch:=RegList.MouseDown(Canvas,X,Y,Shift,Button);
   if Assigned(OnMouseDown) then OnMouseDown(Self,Button,Shift,X,Y);
   Branch:=nil;
   Invalidate;
end;
{===============================================================================
  Class        TTreeBox
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
function TTreeBox.Component:TGPCSRegistryEntry;
begin
   if Branch <> nil then
      Result:=TGPCSRegistryEntry(Branch.TheObject)
   else
      Result:=nil;
end;
procedure TTreeBox.ReleaseAll;
var
   I:Integer;
   J:Integer;
   RE:TGPCSRegistryEntry;
begin
   with RegList do
   begin
      for I:=0 to Items.Count-1 do
      begin
         for J:=0 to Objects[I].Items.Count-1 do
         begin
            RE:=TGPCSRegistryEntry(Objects[I].Objects[J].TheObject);
            if RE.DLLHandle <> 0 then 
            try
               FreeLibrary(RE.DLLHandle);
               RE.FDLLHandle:=0;
            except
            end;
         end;  
      end;  
   end;
end;
{===============================================================================
  Class        TTreeBox
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
procedure TTreeBox.ShowCompLoad(OnOff:Boolean);
begin
   if VarIsEmpty(CompLoad) then Exit;
   if OnOff then CompLoad.Show else CompLoad.Hide;
end;
{===============================================================================
  Class        TTreeBox
  Method       
  Description  
  Params       None
  Result       None
________________________________________________________________________________}
function TTreeBox.GetNamedNode(Name:String):TGPCSRegistryEntry;
var
  I,J:Integer;
  CType:String;
  CName:String;
begin
   Result:=nil;
   if (RegList = nil) or (not RegList.Ready) then Exit;
   CType:='';
   CName:='';
   for I:=1 to Length(Name) do
   begin
      if Name[I] = '.' then
      begin
         CType:=Copy(Name,1,I-1);
         CName:=Copy(Name,I+1,999);
         break;
      end;
   end;
   if (CType = '') or (CName = '') then Exit;
   with RegList do
   begin
      I:=Items.IndexOf(CType);
      if I <> -1 then
      begin
         J:=Objects[I].Items.IndexOf(CName);
         if J <> -1 then
         begin
            Result:=TGPCSRegistryEntry(Objects[I].Objects[J].TheObject);
            Exit;
         end;  
      end;  
   end;
end;
{===============================================================================
  Class        TGPCSRegistryList
  Method       
  Description
  Params       None
  Result       None
________________________________________________________________________________}
constructor TGPCSRegistryList.Create(ComponentList:TTreeBox);
begin
   inherited Create;
   ParentTree:=ComponentList;
   FReady:=False;
   WindowHandle:=AllocateHWnd(WndProc);
   PostMessage(WindowHandle,WMSTARTCM,0,0);
   LazyTime := TTimer.Create( nil ) ;
   LazyTime.Interval := 30000 ;
   LazyTime.Enabled := FALSE ;
   LazyTime.OnTimer := LazyLoadObject ;
   LazyI := 0;
   LazyJ := 0;
end;
procedure TGPCSRegistryList.LazyLoadObject(Sender: TObject) ;
begin

   if not Ready then
      Exit ;

   LazyTime.Enabled := FALSE ;
   if LazyTime.Interval <> 100 then
      LazyTime.Interval := 100 ;

   LoadObjects ;

   if  ( LazyI <> Count ) then
      LazyTime.Enabled := TRUE ;

end ;
procedure TGPCSRegistryList.LoadObjects ;
//var
//    v : IUNKnown ;
begin

   if ( TGPCSRegistryEntry(Objects[LazyI].Objects[LazyJ].TheObject ).ComponentType <> 'Application') and
   ( TGPCSRegistryEntry(Objects[LazyI].Objects[LazyJ].TheObject ).ProgID <> 'Support.CompMan')    and
   ( TGPCSRegistryEntry(Objects[LazyI].Objects[LazyJ].TheObject ).ProgID <> 'Support.CompLoad')
   then
      TGPCSRegistryEntry(Objects[LazyI].Objects[LazyJ].TheObject).GetObject ;

   // v := nil ;
   Inc( LazyJ ) ;
   if ( LazyJ = Objects[LazyI].Count ) then
   begin
      Inc( LazyI ) ;
      LazyJ := 0 ;
   end ;

end ;
procedure TGPCSRegistryList.Startup(var Message:TMessage);
var
   Registry:TRegistry;
   I:Integer;
   Value:String;
   CLSIDs:TPackStringList;
begin
   Registry:=TRegistry.Create;
   with Registry do
   begin
      RootKey:=HKEY_CLASSES_ROOT;
      if (OpenKey('CLSID',False)) and (HasSubKeys) then
      begin
         CLSIDs:=TPackStringList.Create;
         GetKeyNames(CLSIDs);
         CloseKey;
         for I:=0 to CLSIDs.Count-1 do
         begin
            if OpenKey('CLSID\'+CLSIDs.Strings[I],False) then
            begin
               Value:=ReadString('');
               CloseKey;
               if (Value <> '') and ((Copy(Value,1,5) = 'GPCS ') or (Copy(Value,1,7) = 'Corvus ') or (Copy(Value,1,7) = 'CORVUS ')) then
               begin
                   AddEntry(Registry,CLSIDs[I],Value);
                   Application.ProcessMessages;
                   if Application.Terminated then Exit;
               end;
            end;
         end;
         CLSIDs.Free;
      end;
   end;
   Registry.Free;
   FReady:=True;
   ParentTree.Repaint;
end;
procedure TGPCSRegistryList.WndProc(var Message: TMessage);
begin
  try
    Dispatch(Message);
  except
    Application.HandleException(Self);
  end;
end;
{===============================================================================
  Class        TGPCSRegistryList
  Method       Destroy
  Description
  Params       None
  Result       None
________________________________________________________________________________}
destructor TGPCSRegistryList.Destroy;
begin
   if WindowHandle <> 0 then DeAllocateHWnd(WindowHandle);
  LazyTime.Free ;
  if PreLoadIntList <> nil then
  begin
     PreLoadIntList.Free ;
     PreLoadIntList := nil ;
  end ;

  inherited Destroy;
end;
{===============================================================================
  Class        TGPCSRegistryList
  Method       AddEntry
  Description
  Params       None
  Result       None
________________________________________________________________________________}
procedure TGPCSRegistryList.AddEntry(Key:TRegistry;CLSID,Desc:String);
var
   RegEntry:TGPCSRegistryEntry;
   OldRegEntry:TGPCSRegistryEntry;
   Index:Integer;
   V:String;
   SubTree:TSubTree;
   SortList:TPackStringList;
begin
   RegEntry:=TGPCSRegistryEntry.Create(Key,CLSID,Desc);
   Index:=Items.IndexOf(RegEntry.ComponentType);
   if Index = -1 then
      SubTree:=Add(RegEntry.ComponentType)
   else
      SubTree:=Objects[Index];
   FItems.Sort;
   Index:=SubTree.Items.IndexOf(RegEntry.Name);
   SortList:=SubTree.FItems;
   if Index <> -1 then
   begin
      V:=GetFileDateTime(TSubTree(SubTree.Objects[Index]).Items[2]);
//      V:=TSubTree(SubTree.Objects[Index]).Items[3];
      if StrToIntDef(V,0) < StrToIntDef(RegEntry.Version,0) then
      begin
        SubTree:=TSubTree(SubTree.Objects[Index]);
        OldRegEntry:=TGPCSRegistryEntry(SubTree.TheObject);
        OldRegEntry.Free;
        SubTree.Items.Clear;
      end
      else
      begin
         RegEntry.Free;
         Exit;
      end;
   end
   else
      SubTree:=SubTree.Add(RegEntry.Name);

   SubTree.TheObject:=RegEntry;
   SubTree.Add(RegEntry.GUID);
   SubTree.Add(RegEntry.ProgID);
   if RegEntry.ServerBinary1 <> '' then SubTree.Add(RegEntry.ServerBinary1);
   if RegEntry.ServerBinary2 <> '' then SubTree.Add(RegEntry.ServerBinary2);
   if RegEntry.ServerBinary3 <> '' then SubTree.Add(RegEntry.ServerBinary3);
   SubTree.Add(RegEntry.Version);
   if RegEntry.ServerBinary1 <> '' then
   begin
      if (RegEntry.ServerBinary2 <> '') or (RegEntry.ServerBinary3 <> '') then
         MessageDlg('!!!!   Server Conflict   !!!!'+#13+'More than 1 binary associated with'+#13+RegEntry.ProgID,mtWarning,[mbOK],0);
   end
   else if RegEntry.ServerBinary2 <> '' then
   begin
      if (RegEntry.ServerBinary3 <> '') then
         MessageDlg('!!!!   Server Conflict   !!!!'+#13+'More than 1 binary associated with'+#13+RegEntry.ProgID,mtWarning,[mbOK],0);
   end;
   if GPCSGUID.GetGPCSRegString('Component Manager\Loading','Type','Load On Request') = 'Pre Load' then
   begin
//     if (ComServer.StartMode <> smRegServer) and
      if ( ComServer.StartMode = smAutomation ) and
        ( RegEntry.ComponentType <> 'Application') and
        ( RegEntry.ProgID <> 'Support.CompMan')    and
        ( RegEntry.ProgID <> 'Support.CompLoad') then
         RegEntry.GetObject;
   end
   else if GPCSGUID.GetGPCSRegString('Component Manager\Loading','Type','Load On Request') = 'Lazy Load' then
   begin
      if ( ComServer.StartMode = smAutomation ) then
        if not LazyTime.Enabled then
            LazyTime.Enabled := TRUE ;
     // setup lazy load timer !!
   end
   else
   begin
      if PreLoadIntList = nil then
      begin
         PreLoadIntList := TStringList.Create ;
         PreLoadIntList.CommaText := GetGPCSRegNames( 'Component Manager\Loading', '' );
      end ;

      if ( ComServer.StartMode = smAutomation ) then
         if PreLoadIntList.IndexOf( RegEntry.ProgID ) <> -1 then
            RegEntry.GetObject;
   end ;
   SortList.Sort;
end;
{==============================================================================}
procedure Register;
begin
  RegisterComponents('CorvusVCL', [TTreeBox]);
end;
end.
