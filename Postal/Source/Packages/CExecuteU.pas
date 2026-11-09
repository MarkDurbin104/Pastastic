unit CExecuteU;

interface

uses
  Windows,Classes,Forms,Messages,Controls,ComObj,SysUtils,Graphics,ExtCtrls,
  GPCSBase_TLB,CompressU,Bin2String,GPCSGUID,GPCSErrorCode,GPCSErrorLine;
  
const
  WM_RESTOREPREVIOUS = WM_USER+1;
  WM_CANCELPREVIOUS  = WM_USER+2;
    
type
  TGetButtonRef     = function (Index:Integer):TControl               of object;
  TGetButtonIndex   = function (Button:TControl):Integer              of object;
  TSetButtonBitMap  = procedure(Button:TControl;BitMap :TBitMap )     of object;
  TSetButtonCaption = procedure(Button:TControl;Caption:String  )     of object;
  TSetButtonPrice   = procedure(Button:TControl;Price  :Currency)     of object;
  TSetButtonOnClick = procedure(Button:TControl;Handler:TNotifyEvent) of object;
  TGetButtonOnClick = function (Button:TControl):TNotifyEvent         of object;
  TSetTextItem      = procedure(Caption:String)                       of object;
  TSetBitMap        = procedure(BitMap:TBitMap)                       of object;
  TFuncKeyPress     = procedure(FKey:Integer)                         of object;
  TSaveData = class
     BitMap  :array[0..20] of TBitMap;
     Caption :array[0..20] of String;
     Price   :array[0..20] of Currency;
     BEnabled:array[0..20] of Boolean;
  end;
  
  TCExecute = Class(TAutoObject,IUIEventSink,ITxnEventSink)
  private
    ReturnedAlready:Boolean;
    SaveList:TStringList;
    WindowHandle:THandle;
    CurrentExec:String;
    ItemList:TStringList;
    Item:IExecComponent;           
    CompMan:ICompMan;
    TxnLog:ITransactionLog;
    FQuantity:Integer;
    FMaxItems:Integer;
    FGroupSuffix:String;
    FOnGetButtonRef    :TGetButtonRef;
    FOnGetButtonIndex  :TGetButtonIndex;
    FOnSetButtonBitMap :TSetButtonBitMap;
    FOnSetButtonCaption:TSetButtonCaption;
    FOnSetButtonPrice  :TSetButtonPrice;
    FOnSetButtonOnClick:TSetButtonOnClick;
    FOnGetButtonOnClick:TGetButtonOnClick;
    FOnSetTitle        :TSetTextItem;
    FOnSetPrompt       :TSetTextItem;
    FOnSetPMessage     :TSetTextItem;
    FOnSetTransactions :TSetTextItem;
    FOnSetFormData     :TSetTextItem;
    FOnSetScale        :TSetTextItem;
    FOnSetBitMap       :TSetBitMap;
    DontRePaint:Boolean;
    FWorkStation:String;
    FUserGroup  :String;
    WUGroup:IWUGroup;
    Scale:Variant;
    ScaleTimer:TTimer;
    InExecFromList:Boolean;
    procedure WMCancelPrevious(var Msg:TMessage); message WM_CANCELPREVIOUS;
    procedure WMRestorePrevious(var Msg:TMessage); message WM_RESTOREPREVIOUS;
    procedure WndProc(var Message: TMessage);
    procedure SetWorkStation(Value:String);
    procedure SetUserGroup  (Value:String);
    function CanExecute(GroupName:String):Boolean;
    procedure ScaleTick(Sender:TObject);
  protected
    procedure EmptySaveList;
    function  PutBack(Name:String):Boolean;
    procedure DisplayItemInfo(const EventSource: IExecComponent; Index: Integer; const BitMap, Caption: WideString; Price: Currency; State: Integer); safecall;
    function  InternalFunction(FuncName:String):Boolean;
    procedure OnChange(const EventSource:ITransactionLog); safecall;
    procedure ItemSelected(Index:Integer);
  public  
    FCompleteBitmap:TBitMap;
    procedure ExecFromList(List:TStrings);
    function  GetBitmap(Value:String):TBitMap;
    procedure Initialize; override;
    destructor Destroy; override;
    procedure Restore; safecall;
    procedure Cancel;
    procedure CancelToTop;
    procedure EndCustomer;
    procedure SetTxnLogParent(Value:THandle);
    procedure ItemClicked(Sender:TObject);
    procedure Execute(Name:String);
    property WorkStation:String read FWorkStation write SetWorkStation;
    property UserGroup  :String read FUserGroup   write SetUserGroup  ;
    property OnGetButtonRef    :TGetButtonRef     read FOnGetButtonRef     write FOnGetButtonRef    ;
    property OnGetButtonIndex  :TGetButtonIndex   read FOnGetButtonIndex   write FOnGetButtonIndex  ;
    property OnSetButtonBitMap :TSetButtonBitMap  read FOnSetButtonBitMap  write FOnSetButtonBitMap ;
    property OnSetButtonCaption:TSetButtonCaption read FOnSetButtonCaption write FOnSetButtonCaption;
    property OnSetButtonPrice  :TSetButtonPrice   read FOnSetButtonPrice   write FOnSetButtonPrice  ;
    property OnSetButtonOnClick:TSetButtonOnClick read FOnSetButtonOnClick write FOnSetButtonOnClick;
    property OnGetButtonOnClick:TGetButtonOnClick read FOnGetButtonOnClick write FOnGetButtonOnClick;
    property OnSetTitle        :TSetTextItem      read FOnSetTitle         write FOnSetTitle        ;
    property OnSetPrompt       :TSetTextItem      read FOnSetPrompt        write FOnSetPrompt       ;
    property OnSetPMessage     :TSetTextItem      read FOnSetPMessage      write FOnSetPMessage     ;
    property OnSetTransactions :TSetTextItem      read FOnSetTransactions  write FOnSetTransactions ;
    property OnSetFormData     :TSetTextItem      read FOnSetFormData      write FOnSetFormData     ;
    property OnSetScale        :TSetTextItem      read FOnSetScale         write FOnSetScale        ;
    property OnSetBitMap       :TSetBitMap        read FOnSetBitMap        write FOnSetBitMap       ;
    property MaxItems:Integer read FMaxItems write FMaxItems;
    property Quantity:Integer read FQuantity write FQuantity;
    property TxnLogParent:THandle write SetTxnLogParent;
    property GroupSuffix:String read FGroupSuffix write FGroupSuffix;
  end;
  TUICExecute = Class(TComponent)
  private
    FWorkStation:String;
    FUserGroup  :String;
    FQuantity   :Integer;
    FMaxItems   :Integer;
    FGroupSuffix:String;
    CExecute:TCExecute;
    FOnGetButtonRef    :TGetButtonRef;
    FOnGetButtonIndex  :TGetButtonIndex;
    FOnSetButtonBitMap :TSetButtonBitMap;
    FOnSetButtonCaption:TSetButtonCaption;
    FOnSetButtonPrice  :TSetButtonPrice;
    FOnSetButtonOnClick:TSetButtonOnClick;
    FOnGetButtonOnClick:TGetButtonOnClick;
    FOnSetTitle        :TSetTextItem;
    FOnSetPrompt       :TSetTextItem;
    FOnSetPMessage     :TSetTextItem;
    FOnSetTransactions :TSetTextItem;
    FOnSetFormData     :TSetTextItem;
    FOnSetScale        :TSetTextItem;
    FOnSetBitMap       :TSetBitMap;
    function GetWorkStation:String;
    function GetUserGroup  :String;
    function GetGroupSuffix:String;
    function GetMaxItems   :Integer;
    function GetQuantity   :Integer;
    procedure SetWorkStation(Value:String);
    procedure SetUserGroup  (Value:String);
    procedure SetGroupSuffix(Value:String);
    procedure SetMaxItems   (Value:Integer);
    procedure SetQuantity   (Value:Integer);
    procedure SetTxnLogParent(Value:Integer);
    procedure SetCompleteBitmap(Value:TBitMap);
  protected
    function GetButtonRef(Index:Integer):TControl;
    function GetButtonIndex(Button:TControl):Integer;
    function GetButtonOnClick(Button:TControl):TNotifyEvent;
    procedure SetButtonBitMap (Button:TControl;BitMap :TBitMap );
    procedure SetButtonPrice(Button:TControl;Price:Currency);
    procedure SetButtonCaption(Button:TControl;Caption:String  );
    procedure SetButtonOnClick(Button:TControl;Handler:TNotifyEvent);
    procedure SetTitle   (Caption:String);
    procedure SetPrompt  (Caption:String);
    procedure SetPMessage(Caption:String);
    procedure SetTransactions(Caption:String);
    procedure SetFormData(Caption:String);
    procedure SetBitMap(BitMap:TBitMap);
    procedure SetScale(Reading:String);
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    function  GetBitmap(Value:String):TBitMap;
    procedure Cancel;
    procedure CancelToTop;
    property TxnLogParent:Integer write SetTxnLogParent;
  published
    property OnGetButtonRef    :TGetButtonRef     read FOnGetButtonRef     write FOnGetButtonRef    ;
    property OnGetButtonIndex  :TGetButtonIndex   read FOnGetButtonIndex   write FOnGetButtonIndex  ;
    property OnSetButtonBitMap :TSetButtonBitMap  read FOnSetButtonBitMap  write FOnSetButtonBitMap ;
    property OnSetButtonCaption:TSetButtonCaption read FOnSetButtonCaption write FOnSetButtonCaption;
    property OnSetButtonPrice  :TSetButtonPrice   read FOnSetButtonPrice   write FOnSetButtonPrice  ;
    property OnSetButtonOnClick:TSetButtonOnClick read FOnSetButtonOnClick write FOnSetButtonOnClick;
    property OnGetButtonOnClick:TGetButtonOnClick read FOnGetButtonOnClick write FOnGetButtonOnClick;
    property OnSetTitle        :TSetTextItem      read FOnSetTitle         write FOnSetTitle        ;
    property OnSetPrompt       :TSetTextItem      read FOnSetPrompt        write FOnSetPrompt       ;
    property OnSetPMessage     :TSetTextItem      read FOnSetPMessage      write FOnSetPMessage     ;
    property OnSetTransactions :TSetTextItem      read FOnSetTransactions  write FOnSetTransactions ;
    property OnSetFormData     :TSetTextItem      read FOnSetFormData      write FOnSetFormData     ;
    property OnSetScale        :TSetTextItem      read FOnSetScale         write FOnSetScale        ;
    property OnSetBitMap       :TSetBitMap        read FOnSetBitMap        write FOnSetBitMap       ;
    property WorkStation :String  read GetWorkStation write SetWorkStation;
    property UserGroup   :String  read GetUserGroup   write SetUserGroup  ;
    property GroupSuffix :String  read GetGroupSuffix write SetGroupSuffix;
    property MaxItems    :Integer read GetMaxItems    write SetMaxItems   ;
    property Quantity    :Integer read GetQuantity    write SetQuantity   ;
    property CompleteBitmap:TBitMap write SetCompleteBitmap;
    
  end;
  
procedure Register;
  
implementation
uses
   ComServ2;

procedure TCExecute.WndProc(var Message: TMessage);
begin
  try
    Dispatch(Message);
  except
      on E:Exception do RaiseException(8,E);
  end;
end;
procedure TCExecute.ScaleTick(Sender:TObject);
var
   Reading:Integer;
begin
   if Assigned(OnSetScale) and (not VarIsEmpty(Scale)) then
   begin
      try
         Reading:=Scale.ReadScale;
         if Reading >= 0 then
            OnSetScale(IntToStr(Reading))
         else
            OnSetScale('NONE');
      except 
      end;
   end;         
end;
procedure TCExecute.Initialize;
begin
   try
   SaveList:=TStringList.Create;
   CompMan:=CreateCompMan;
   TxnLog:=CreateTransactionLog;
   TxnLog.SetEventSink(Self);
   _AddRef;
   ItemList:=TStringList.Create;
   WindowHandle:=AllocateHWnd(WndProc);
   DontRePaint:=False;
   GroupSuffix:='';
   Scale:=CreateOleObject('Utility.Scale');
   if Not VarIsEmpty(Scale) then
   begin
      ScaleTimer:=TTimer.Create(nil);
      ScaleTimer.Enabled:=False;
      ScaleTimer.Interval:=500;
      ScaleTimer.OnTimer:=ScaleTick;
      ScaleTimer.Enabled:=True;
   end;
   except
      on E:Exception do RaiseException(9,E);
   end;
end;                     
destructor TCExecute.Destroy;
begin
   try
   if ScaleTimer <> nil then ScaleTimer.Free;
   if Not VarIsEmpty(Scale) then Scale:=Unassigned;
   if WindowHandle <> 0 then DeAllocateHWnd(WindowHandle);
   if Item <> nil then
      Item.TerminateExecute(TxnLog);
   Item:=nil;
   ItemList.Free;
   EmptySaveList;
   SaveList.Free;
   TxnLog:=nil;
   CompMan:=nil;
   inherited Destroy;
   except
      on E:Exception do RaiseException(10,E);
   end;
end;  
procedure TCExecute.EmptySaveList;
var
   I:Integer;
begin
   try
   for I:=0 to SaveList.Count-1 do
      if SaveList.Objects[I] <> nil then TSaveData(SaveList.Objects[I]).Free;
   SaveList.Clear;
   except
      on E:Exception do RaiseException(11,E);
   end;
end;  
procedure TCExecute.SetWorkStation(Value:String);
begin
   try
   if FWorkStation <> Value then
   begin
      EmptySaveList;
      SaveList.Clear;
      FWorkStation:=Value;
      WUGroup:=CompMan.LoadComponent(Value) as IWUGroup;
      if (WUGroup <> nil) and (FUserGroup <> '') then
      begin
         WUGroup.ApplyGroup(FUserGroup);
         ItemList.Clear;
         if Item <> nil then
         begin
            Item.CompleteExecute(TxnLog);
            Item:=nil;
         end;
         Execute('');
      end;
   end;
   except
      on E:Exception do RaiseException(12,E);
   end;
end;  
procedure TCExecute.SetUserGroup  (Value:String);
begin
   try
//   if FUserGroup <> Value then
   begin
      EmptySaveList;
      FUserGroup:=Value;
      if (WUGroup <> nil) and (FUserGroup <> '') then
      begin
         WUGroup.ApplyGroup(FUserGroup);
         ItemList.Clear;
         if Item <> nil then
         begin
            Item.CompleteExecute(TxnLog);
            Item:=nil;
         end;
         Execute('');
      end;
   end;
   except
      on E:Exception do RaiseException(13,E);
   end;
end;  
function TCExecute.CanExecute(GroupName:String):Boolean;
var
  I:Integer;
begin   
   Result:=False;
   try
   if (Copy(GroupName,1,5) = 'Group') and (WUGroup <> nil) then
   begin
      for I:=0 to WUGroup.Count-1 do
      begin
         if WUGroup.Item[I] = GroupName then
         begin
            Result:=True;
            Exit;
         end;
      end;
      Result:=False;
   end
   else
   begin
      Result:=True;
   end;
   except
      on E:Exception do RaiseException(14,E);
   end;
end;  
function TCExecute.GetBitmap(Value:String):TBitMap;
var
   SStream:TStringStream;
   Compressor:TCompress;
begin
   result:=nil;
   try
      Compressor:=TCompress.Create;
      Value:=StringToBinary(Value);
      Value:=Compressor.CompressString(Value);
      Compressor.Free;
      SStream:=TStringStream.Create(Value);
      SStream.Position:=0;
      Result:=TBitMap.Create;
      Result.LoadFromStream(SStream);
      SStream.Free;
   except
      on E:Exception do RaiseException(15,E);
   end;
end;  
function TCExecute.InternalFunction(FuncName:String):Boolean;
begin
   Result:=True;
   if FuncName = 'Cancel' then 
      Cancel
   else if FuncName = 'Complete' then 
      Restore
   else if FuncName = 'Exit' then
      Application.Terminate
   else if FuncName = 'End Customer' then
      EndCustomer
   else 
      Result:=False;
end;         
procedure TCExecute.ExecFromList(List:TStrings);
begin
   InExecFromList:=True;
end;
procedure TCExecute.ItemSelected(Index:Integer);
begin
   InExecFromList:=False;
end;                    
procedure TCExecute.ItemClicked(Sender:TObject);
var
   Index:Integer;
   CompToExec:String;
begin
   try
   if not Assigned(OnGetButtonIndex) then Exit;
   Index:=OnGetButtonIndex(Sender as TControl);
   if InExecFromList then
   begin
      ItemSelected(Index);
      Exit;
   end;
   CompToExec:=Item.Item[Index];
   if (CompToExec <> '') then
   begin
      if InternalFunction(CompToExec) then Exit;
      if not CanExecute(CompToExec) then
         Exit;
      ItemList.Add(CurrentExec);
      Item.CompleteExecute(TxnLog);
      Item:=nil;
      Execute(CompToExec);
   end;
   except
      on E:Exception do RaiseException(16,E);
   end;
end;  
procedure TCExecute.DisplayItemInfo(const EventSource: IExecComponent; Index: Integer; const BitMap, Caption: WideString; Price: Currency; State: Integer);
var
    Button:TControl;
    BMP:TBitMap;
    I,J:Integer;
    CurData:TSaveData;
    ItemName:String;
    ButtonCaption:String;
    BMPString:String;
begin
   BMP:=nil;
   try
   ButtonCaption:=Caption;
   BMPString:=BitMap;
   if BMPString <> '' then
      BMP:=GetBitMap(BMPString);
   if BMP = nil then 
      BMPString:='';
   DontRePaint:=False;
   if not Assigned(OnGetButtonRef) then Exit;
   Button:=OnGetButtonRef(Index);
   if Button = nil then Exit;
   ItemName:='';
   if (Index < Item.Count) then
      ItemName:=Item.Item[Index];

   if (ItemName <> '') and CanExecute(ItemName) then
      Button.Enabled:=True
   else
      Button.Enabled:=False;
   if (BMPString = '') and (ButtonCaption = '') then
   begin
      if Assigned(FOnSetButtonBitMap ) then FOnSetButtonBitMap (Button,nil);
      if Assigned(FOnSetButtonCaption) then FOnSetButtonCaption(Button,'' );
      if Assigned(FOnSetButtonPrice  ) then FOnSetButtonPrice  (Button,0  );
      if Assigned(FOnSetButtonOnClick) then FOnSetButtonOnClick(Button,nil);
      Button.Enabled:=False;
   end                
   else
   begin
      if Copy(ItemName,1,5) = 'Group' then ButtonCaption:=ButtonCaption+GroupSuffix;
      if (Copy(ItemName,1,8) = 'Complete')  then 
      begin
         BMP:=TBitMap.Create;
         BMP.Assign(FCompleteBitmap);
      end;
      if Assigned(FOnSetButtonBitMap ) then FOnSetButtonBitMap (Button,BMP    );
      if Assigned(FOnSetButtonCaption) then FOnSetButtonCaption(Button,ButtonCaption);
      if Assigned(FOnSetButtonPrice  ) then FOnSetButtonPrice  (Button,Price  );
   end;
   I:=SaveList.IndexOf(CurrentExec);
   if I <> -1 then
   begin
      if SaveList.Objects[I] = nil then
      begin
         SaveList.Objects[I]:=TSaveData.Create;
         CurData:=TSaveData(SaveList.Objects[I]);
         for J:=0 to MaxItems-1 do
         begin
            if CurData.BitMap[J] <> nil then CurData.BitMap[J].Free;
            CurData.BitMap  [J]:=nil;
            CurData.Caption [J]:='';
            CurData.Price   [J]:=0;
            CurData.BEnabled[J]:=False;
         end;
      end;
      CurData:=TSaveData(SaveList.Objects[I]);
      if CurData <> nil then
      begin
         if CurData.BitMap[Index] <> nil then CurData.BitMap[Index].Free;
         if BMP <> nil then
         begin
            CurData.BitMap[Index]:=TBitMap.Create;
            CurData.BitMap[Index].Assign(BMP);
         end
         else
         begin
            CurData.BitMap[Index]:=nil;
         end;
         CurData.Caption [Index]:=ButtonCaption;
         CurData.Price   [Index]:=Price  ;
         CurData.BEnabled[Index]:=Button.Enabled;
      end;
   end;
   except
      on E:Exception do RaiseException(17,E);
   end;
   if BMP <> nil then
      BMP.Free;
end;   
function TCExecute.PutBack(Name:String):Boolean;
var
   Index:Integer;
   I:Integer;
   BitMap :TBitMap;
   Caption:String;
   Price  :Currency;
   Button:TControl;
   SaveData:TSaveData;
begin
   Result:=False;
   try
   I:=SaveList.IndexOf(Name);
   if (I <> -1) and (SaveList.Objects[I] <> nil) then
   begin
      SaveData:=TSaveData(SaveList.Objects[I]);
      Result:=True;
      if DontRePaint then Exit;
      for Index:=0 to MaxItems-1 do
      begin
         BitMap :=SaveData.BitMap [Index];
         Caption:=SaveData.Caption[Index];
         Price  :=SaveData.Price  [Index];

         Button:=OnGetButtonRef(Index);
         if Button = nil then Exit;
         
         Button.Enabled:=SaveData.BEnabled[Index];
         if Button.Enabled then
         begin
            if Assigned(FOnSetButtonOnClick) then FOnSetButtonOnClick(Button,ItemClicked);
         end
         else
         begin
            if Assigned(FOnSetButtonOnClick) then FOnSetButtonOnClick(Button,nil);
         end;
         
         if Assigned(FOnSetButtonBitMap ) then FOnSetButtonBitMap (Button,BitMap);
         if Assigned(FOnSetButtonCaption) then FOnSetButtonCaption(Button,Caption);
         if Assigned(FOnSetButtonPrice  ) then FOnSetButtonPrice  (Button,Price);
      end;                                                                     
   end;
   except
      on E:Exception do RaiseException(18,E);
   end;
end;  
procedure TCExecute.WMRestorePrevious(var Msg:TMessage);
var
   S:String;
begin
   try
   if ItemList.Count = 0 then Exit;
   S:=ItemList[ItemList.Count-1];
   ItemList.Delete(ItemList.Count-1);
   Item.CompleteExecute(TxnLog);
   Item:=nil;
   Execute(S);
   except
      on E:Exception do RaiseException(19,E);
   end;
end;  
procedure TCExecute.Restore; 
begin
   try
      PostMessage(WindowHandle,WM_RESTOREPREVIOUS,0,0);
      ReturnedAlready:=True;
   except
      on E:Exception do RaiseException(20,E);
   end;
end;  
procedure TCExecute.WMCancelPrevious(var Msg:TMessage);
var              
   S:String;
begin
   try
   if ItemList.Count = 0 then Exit;
   S:=ItemList[ItemList.Count-1];
   ItemList.Delete(ItemList.Count-1);
   Item.TerminateExecute(TxnLog);
   Item:=nil;
   Execute(S);
   except
      on E:Exception do RaiseException(21,E);
   end;
end;  
procedure TCExecute.Cancel; 
begin
   try
      PostMessage(WindowHandle,WM_CANCELPREVIOUS,0,0);
      ReturnedAlready:=True;
   except
      on E:Exception do RaiseException(22,E);
   end;
end;  
procedure TCExecute.CancelToTop;
var              
   S:String;
begin
   try
      if ItemList.Count = 0 then Exit;
      S:=ItemList[0];
      ItemList.Clear;
      Item.TerminateExecute(TxnLog);
      Item:=nil;
      Execute(S);
   except
      on E:Exception do RaiseException(21,E);
   end;
end;  
procedure TCExecute.Execute(Name:String);
var
   I:Integer;
   CurrDontRePaint:Boolean;
   BMP:TBitMap;
begin
   try
      if (Name = '') and (WUGroup <> nil) then
         Name:=WUGroup.Item[0];
      if PutBack(Name) then DontRePaint:=True;
      CurrentExec:=Name;
      if RefCount < 1 then Exit;
      Item:=CompMan.LoadComponent(Name) as IExecComponent;
      if Assigned(OnGetButtonRef) then
      begin
         I:=0;
         while (I < MaxItems) and (I < Item.Count) do
         begin
            if Assigned(FOnSetButtonOnClick) then FOnSetButtonOnClick(OnGetButtonRef(I),ItemClicked);
            Inc(I);
         end;
         while I < MaxItems do
         begin
            if Assigned(FOnSetButtonOnClick) then FOnSetButtonOnClick(OnGetButtonRef(I),nil);
            Inc(I);
         end;
      end;
      if SaveList.IndexOf(CurrentExec) = -1 then
      begin
         SaveList.AddObject(CurrentExec,nil);
      end;
      CurrDontRePaint:=DontRePaint;
      DontRePaint:=True;
      ReturnedAlready:=False;
      Item.Execute(FQuantity,FMaxItems,CurrDontRePaint,Self,TxnLog);
      if CurrDontRePaint then
         DontRePaint:=False;
      if not ReturnedAlready then
      begin
         try
            if Assigned(OnSetTitle   ) then OnSetTitle   (Item.Title   );
            if Assigned(OnSetPrompt  ) then OnSetPrompt  (Item.Prompt  );
            if Assigned(OnSetPMessage) then OnSetPMessage(Item.PMessage);
            if Assigned(OnSetBitMap  ) then 
            begin
               BMP:=GetBitMap(Item.BitMap);
               OnSetBitMap(BMP);
               BMP.Free;
            end;
            try
               if (Copy(Name,1,7) = 'Product') and Assigned(OnSetFormData) then 
                  OnSetFormData((Item as IProduct).GetExecData);
            except
               ;
            end;
         except
            on E:Exception do RaiseException(99,E);
         end;
      end;
   except
      on E:Exception do RaiseException(23,E);
   end;
end;                      
procedure TCExecute.EndCustomer;
begin
   try
   TxnLog.EndCustomer
   except
      on E:Exception do RaiseException(24,E);
   end;
end;  
procedure TCExecute.SetTxnLogParent(Value:THandle);
begin
   try
   TxnLog.Parent:=Value;
   except
      on E:Exception do RaiseException(25,E);
   end;
end;  
procedure TCExecute.OnChange(const EventSource:ITransactionLog);
begin
   try
      if Assigned(OnSetTransactions) then OnSetTransactions('Transaction Item');
   except
      on E:Exception do RaiseException(26,E);
   end;
end;  
constructor TUICExecute.Create(AOwner:TComponent);
begin
   inherited Create(AOwner);
   if csDesigning in ComponentState then
   begin
      FWorkStation:='WGroup.Dynakey';
      FMaxItems:=8;
      FQuantity:=1;
      FGroupSuffix:='...';
      FUserGroup:='UGroup.Supervisor';
      CExecute:=nil;
      Exit;
   end;
   
   CExecute:=TCExecute.Create;
   CExecute.OnGetButtonRef    :=GetButtonRef;
   CExecute.OnGetButtonIndex  :=GetButtonIndex;
   CExecute.OnSetButtonCaption:=SetButtonCaption;
   CExecute.OnSetButtonBitMap :=SetButtonBitMap;
   CExecute.OnSetButtonPrice  :=SetButtonPrice;
   CExecute.OnSetButtonOnClick:=SetButtonOnClick;
   CExecute.OnGetButtonOnClick:=GetButtonOnClick;
   CExecute.OnSetTitle        :=SetTitle   ;
   CExecute.OnSetPrompt       :=SetPrompt  ;
   CExecute.OnSetPMessage     :=SetPMessage;
   CExecute.OnSetTransactions :=SetTransactions;
   CExecute.OnSetFormData     :=SetFormData;
   
   CExecute.OnSetBitMap       :=SetBitMap;
   CExecute.OnSetScale        :=SetScale;
   
   CExecute.WorkStation:='WGroup.Dynakey';
   CExecute.MaxItems:=8;
   CExecute.Quantity:=1;
   CExecute.GroupSuffix:='...';
   CExecute.UserGroup:='UGroup.Supervisor';
end;
destructor TUICExecute.Destroy;
begin
   if not (csDesigning in ComponentState) then 
   begin
      CExecute.Free;
   end;
   inherited Destroy;
end;               
procedure TUICExecute.SetCompleteBitmap(Value:TBitMap);
begin
   if csDesigning in ComponentState then Exit;
   CExecute.FCompleteBitmap:=Value;
end;
function TUICExecute.GetButtonRef(Index:Integer):TControl;
begin
   Result:=nil;
   if csDesigning in ComponentState then Exit;
   if Assigned(FOnGetButtonRef) then Result:=FOnGetButtonRef(Index);
end;
function TUICExecute.GetButtonIndex(Button:TControl):Integer;
begin
   Result:=0;
   if csDesigning in ComponentState then Exit;
   if Assigned(FOnGetButtonIndex) and (Button <> nil) then Result:=FOnGetButtonIndex(Button);
end;
function TUICExecute.GetButtonOnClick(Button:TControl):TNotifyEvent;
begin
   Result:=nil;
   if csDesigning in ComponentState then Exit;
   if Assigned(FOnGetButtonOnClick) and (Button <> nil)  then Result:=FOnGetButtonOnClick(Button);
end;
procedure TUICExecute.SetButtonBitMap(Button:TControl;BitMap :TBitMap );
begin
   if csDesigning in ComponentState then Exit;
   if Assigned(FOnSetButtonBitMap) and (Button <> nil)  then FOnSetButtonBitMap(Button,BitMap);
end;
procedure TUICExecute.SetButtonPrice(Button:TControl;Price:Currency);
begin
   if csDesigning in ComponentState then Exit;
   if Assigned(FOnSetButtonPrice) and (Button <> nil)  then FOnSetButtonPrice(Button,Price);
end;
procedure TUICExecute.SetButtonCaption(Button:TControl;Caption:String  );
begin
   if csDesigning in ComponentState then Exit;
   if Assigned(FOnSetButtonCaption) and (Button <> nil)  then FOnSetButtonCaption(Button,Caption);
end;
procedure TUICExecute.SetButtonOnClick(Button:TControl;Handler:TNotifyEvent);
begin
   if csDesigning in ComponentState then Exit;
   if Assigned(FOnSetButtonOnClick) and (Button <> nil)  then FOnSetButtonOnClick(Button,Handler);
end;
procedure TUICExecute.SetTitle(Caption:String);
begin
   if csDesigning in ComponentState then Exit;
   if Assigned(FOnSetTitle) then FOnSetTitle(Caption);
end;
procedure TUICExecute.SetPrompt(Caption:String);
begin
   if csDesigning in ComponentState then Exit;
   if Assigned(FOnSetPrompt) then FOnSetPrompt(Caption);
end;
procedure TUICExecute.SetPMessage(Caption:String);
begin
   if csDesigning in ComponentState then Exit;
   if Assigned(FOnSetPMessage) then FOnSetPMessage(Caption);
end;
procedure TUICExecute.SetFormData(Caption:String);
begin
   if csDesigning in ComponentState then Exit;
   if Assigned(FOnSetFormData) then FOnSetFormData(Caption);
end;
procedure TUICExecute.SetTransactions(Caption:String);
begin
   if csDesigning in ComponentState then Exit;
   if Assigned(FOnSetTransactions) then FOnSetTransactions(Caption);
end;
procedure TUICExecute.SetBitMap(BitMap:TBitMap);
begin
   if csDesigning in ComponentState then Exit;
   if Assigned(FOnSetBitMap) then FOnSetBitMap(BitMap);
end;
procedure TUICExecute.SetScale(Reading:String);
begin
   if csDesigning in ComponentState then Exit;
   if Assigned(FOnSetScale) then FOnSetScale(Reading);
end;
function TUICExecute.GetWorkStation:String;
begin
   if csDesigning in ComponentState then
      Result:=FWorkStation
   else
      Result:=CExecute.WorkStation;
end;
procedure TUICExecute.SetWorkStation(Value:String);
begin
   if csDesigning in ComponentState then
      FWorkStation:=Value
   else
      CExecute.WorkStation:=Value;
end;
function TUICExecute.GetUserGroup:String;
begin
   if csDesigning in ComponentState then
      Result:=FUserGroup
   else
      Result:=CExecute.UserGroup;
end;
procedure TUICExecute.SetUserGroup(Value:String);
begin
   if csDesigning in ComponentState then
      FUserGroup:=Value
   else
      CExecute.UserGroup:=Value;
end;
function TUICExecute.GetGroupSuffix:String;
begin
   if csDesigning in ComponentState then
      Result:=FGroupSuffix
   else
      Result:=CExecute.GroupSuffix;
end;                
procedure TUICExecute.SetGroupSuffix(Value:String);
begin
   if csDesigning in ComponentState then
      FGroupSuffix:=Value
   else
      CExecute.GroupSuffix:=Value;
end;
function TUICExecute.GetMaxItems:Integer;
begin               
   if csDesigning in ComponentState then
      Result:=FMaxItems
   else
      Result:=CExecute.MaxItems;
end;
procedure TUICExecute.SetMaxItems(Value:Integer);
begin
   if csDesigning in ComponentState then
      FMaxItems:=Value
   else
      CExecute.MaxItems:=Value;
end;
function TUICExecute.GetQuantity:Integer;
begin
   if csDesigning in ComponentState then
      Result:=FQuantity
   else
      Result:=CExecute.Quantity;
end;
procedure TUICExecute.SetQuantity(Value:Integer);
begin
   if csDesigning in ComponentState then
      FQuantity:=Value
   else
      CExecute.Quantity:=Value;
end;
procedure TUICExecute.SetTxnLogParent(Value:Integer);
begin
   if csDesigning in ComponentState then Exit;
   CExecute.TxnLogParent:=Value;
end;
function TUICExecute.GetBitmap(Value:String):TBitMap;
begin
   Result:=nil;
   if csDesigning in ComponentState then Exit;
   Result:=CExecute.GetBitmap(Value);
end;
procedure TUICExecute.Cancel;
begin
   if csDesigning in ComponentState then Exit;
   CExecute.Cancel;
end;
procedure TUICExecute.CancelToTop;
begin
   if csDesigning in ComponentState then Exit;
   CExecute.CancelToTop;
end;
 
procedure Register;
begin
   RegisterComponents('Kyrgystan',[TUICExecute]);
end;
 
initialization
  TComObjectFactory.Create(ComServer,TCExecute,
                          StringToGUID('{55584140-CBC8-11D1-8A92-080000223037}'),
                          'Event.EventSink','Event.EventSink',ciInternal);
end.
 
