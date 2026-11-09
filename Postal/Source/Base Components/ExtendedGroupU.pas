unit ExtendedGroupU;

interface

uses
  Windows,Classes,SysUtils,BaseGroup,GPCSBase_TLB,GPCSErrorLine,GPCSBaseAU,GPCSGUID,PackStrListU;

type
  IExtGroup = interface(IGroup)
    ['{807EAA35-E2A8-4D94-A5DE-ACD3B7A26D4F}']
    procedure SetProgID(ProgID:WideString);
  end;
  TGroupDetails = Class(TPersistent)
  public
     Caption:String;
     Title        :String;
     Count        :Integer;
     Glyph        :Variant;
     GlyphAsString:String;
     Items        :TPackStringList;
     constructor Create(ACaption,ATitle,AItems:String;AGlyph:Array of Byte);
     destructor Destroy; override;
  end;
  TGroupList = Class(TPackStringList)
   private
     function  GetGroup(Index:Integer):TGroupDetails;
     procedure SetGroup(Index:Integer;Group:TGroupDetails);
   public
     property Objects[Index:Integer]:TGroupDetails read GetGroup write SetGroup;
  end;
  TBaseMultiGroup = class(TBaseGroup,IExtGroup)
  protected
    FCurrentProgID:String;
    FGroupInfo:TGroupList;
    FCurrentGroup:TGroupDetails;
    function GetResourceString(Index:Integer):String; override;
    procedure SetProgID(ProgID:WideString); virtual;
  public
    destructor Destroy; override;
    function Get_BitMap: OleVariant; override;
    procedure Execute(Quantity,MaxItems:Integer;NoRedraw:WordBool;const UIEventSink:IUIEventSink;const TxnLog:ITransactionLog;Nested:WordBool); override;
  end;

implementation
{TGroupDetails}
constructor TGroupDetails.Create(ACaption,ATitle,AItems:String;AGlyph:Array of Byte);
var
   Data:PChar;
   GlyphSize:Integer;
begin
   inherited Create;
   Caption:=ACaption;
   Title  :=ATitle  ;
   Items:=TPackStringList.Create;
   Items.PackText:=AItems;
   GlyphSize:=High(AGlyph);
   Glyph:=VarArrayCreate([0,GlyphSize],varByte);
   try
      Data:=VarArrayLock(Glyph);
      CopyMemory(Data,@AGlyph,GlyphSize);
   except
   end;
   VarArrayUnlock(Glyph);
   SetLength(GlyphAsString,GlyphSize);
   CopyMemory(@GlyphAsString[1],@AGlyph,GlyphSize);
end;
destructor TGroupDetails.Destroy;
begin
   Items.Free;
   Glyph:=Unassigned;
   GlyphAsString:='';
   inherited Destroy;
end;
{TGroupList}
function  TGroupList.GetGroup(Index:Integer):TGroupDetails;
begin
   Result:=TGroupDetails(inherited Objects[Index]);
end;
procedure TGroupList.SetGroup(Index:Integer;Group:TGroupDetails);
begin
   inherited Objects[Index]:=Group;
end;
{TBaseMultiGroup}
destructor TBaseMultiGroup.Destroy;
begin
   try
      if FGroupInfo <> nil then
      begin
         FGroupInfo.Free;
         FGroupInfo:=nil;
      end;
   except
      on E:Exception do
         RaiseGUIDException('{711112CA-26E3-4716-A1DE-B2E8E28EE6A4}',E);
   end;         
   inherited Destroy;
end;
procedure TBaseMultiGroup.SetProgID(ProgID:WideString);
var
   Index:Integer;
begin
   try
      if FGroupInfo <> nil then
      begin
         FCurrentProgID:=ProgID;
         Index:=FGroupInfo.IndexOf(ProgID);
         if Index < 0 then Index:=0;
         FCurrentGroup:=FGroupInfo.Objects[Index];
      end;          
   except
      on E:Exception do
         RaiseGUIDException('{CF5B4C11-AEC4-4704-BCC8-0FA72583FD91}',E);
   end;         
end;
function TBaseMultiGroup.Get_BitMap: OleVariant;
begin
   try 
      Result:=FCurrentGroup.Glyph;
   except
      on E:Exception do
         RaiseGUIDException('{92C7D75F-AF2B-4B27-86B5-8D383B2574C8}',E);
   end;         
end;
function TBaseMultiGroup.GetResourceString(Index:Integer):String;
begin
   try
      case Index of
         riVersion                   : Result:='1';
         riCaption                   : Result:=FCurrentGroup.Caption;
         riBitMap                    : Result:=FCurrentGroup.GlyphAsString;
         riKey                       : Result:='a';
         riCount                     : Result:=IntToStr(FCurrentGroup.Items.Count);
         riItemBase..(riItemBase+99) : Result:=FCurrentGroup.Items[Index-riItemBase];
         riTitle                     : Result:=FCurrentGroup.Title;
         riPrompt                    : Result:='Select a Menu Item:';
         riPMessage                  : Result:='Select a menu item by pressing the Function Key^or by using the UP/DOWN arrows and [Enter]';
      end;
   except
      on E:Exception do
         RaiseGUIDException('{2BC52683-76D9-4476-BF01-97EE324F24D5}',E);
   end;         
end;
procedure TBaseMultiGroup.Execute(Quantity, MaxItems: Integer; NoRedraw: WordBool; 
                  const UIEventSink: IUIEventSink;const TxnLog:ITransactionLog;Nested:WordBool);
var
   I,J:Integer;
   CompMan:ICompMan;
   CurrentItem:IExecComponent;
   S:String;
   CompressedBitmap:Variant;
   TmpProgID:String;
   Index:Integer;
   CurrentGroup:TGroupDetails;
begin
   TmpProgID:=FCurrentProgID;
   if UIEventSink = nil then Exit;
   FUIEventSink:=UIEventSink;

   if FItemList <> nil then FItemList.Free;
   FItemList:=TItemList.Create;

   CompMan:=CreateCompMan;
   for I:=0 to Get_Count-1 do
   begin
      S:=Get_Item(I);
      if (Copy(S,1,8) = 'Product.') then
      begin
         FItemList.Add(CompMan.LoadComponent(S) as IExecComponent,S);
      end;
   end;
   CompMan:=nil;

   I:=0;
   J:=0;
   while (I < MaxItems) and (I < Get_Count) do
   begin
      S:=Get_Item(I);
      if (Copy(S,1,8) = 'Product.') then
      begin
         if FItemList[J].Instance <>  nil then
         begin
            CurrentItem:=FItemList[J].Instance;
            if not NoRedraw then
            begin
               CompressedBitmap:=CurrentItem.Bitmap;
               FUIEventSink.DisplayItemInfo(Self,I,CompressedBitmap,
                                                   CurrentItem.Caption,
                                                   CurrentItem.Price[0],0,False,False);
               CompressedBitmap:=Unassigned;
            end;
            CurrentItem.EventSink:=Self;
         end
         else
         begin
            if not NoRedraw then
            begin
               FUIEventSink.DisplayItemInfo(Self,I,'','Error in '+S,0,0,False,False);
            end;
         end;    
         Inc(J);
         Inc(I);
      end
      else if (Copy(S,1,6) = 'Group.') then
      begin
         Index:=FGroupInfo.IndexOf(S);
         if Index >= 0 then 
         begin
            CurrentGroup:=FGroupInfo.Objects[Index];
            if not NoRedraw then
            begin
               FUIEventSink.DisplayItemInfo(Self,I,CurrentGroup.Glyph,
                                                   CurrentGroup.Caption,
                                                   0,0,False,False);
            end;
         end
         else
         begin
            if not NoRedraw then
            begin
               FUIEventSink.DisplayItemInfo(Self,I,'','Error in '+S,0,0,False,False);
            end;
         end;    
         Inc(I);
      end  
      else
      begin
         if not NoRedraw then
         begin
            FUIEventSink.DisplayItemInfo(Self,I,'',S,0,0,False,False);
         end;
         Inc(I);
      end;
   end;  
   if not NoRedraw then
   begin
      while (I < MaxItems) do
      begin
         FUIEventSink.DisplayItemInfo(Self,I,'','',0,0,False,False);
         Inc(I);
      end;
   end;
   SetProgID(TmpProgID);
end;       

end.
