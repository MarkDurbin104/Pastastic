unit EvSinkBaseU;

interface

uses
   ComObj,GPCSBase_TLB,GPCSBaseAU,GPCSGUID;

type
  TUIEventSinkBase = class(TGPCSBaseComponent,IUIEventSink)
    private
      FParentSink:IUIEventSink;
    protected               
      procedure DisplayItemInfo(const EventSource: IExecComponent; Index: Integer; BitMap:OleVariant;const Caption: WideString; Price: Currency; State: Integer;Notify,Nested:WordBool); safecall;
      procedure Restore; safecall;
      procedure DisplayInstructions(Style: InstructStyle; const Text:WideString; BitMap:OleVariant); safecall;
      procedure DataChanged(const EventSource: IExecComponent;const Value: WideString; FlagError: WordBool); virtual; safecall;
      function GetComponentReference(const Name: WideString): IDispatch; safecall;
      function CurrentDetails:WideString; safecall;
      function  Translate(const Value: WideString):WideString; safecall;
      function Endorse(X,Y,ColCount:Integer;const CommaText:WideString):WordBool; safecall; 
      procedure WaitFor(DeviceStatus: DeviceStatusType); safecall;
      procedure SwapTo(const ProgID, PassData: WideString); safecall;
      function Get_User:WideString; safecall;
      function Get_Workstation:Integer; safecall;
      function Get_Office:Integer; safecall;
      function  ReferenceData(const Name: WideString):WideString; safecall;
      function CurrentLine: Integer; safecall;
      procedure Print2x2(const Title,Desc1,Desc2,Office,DataCommatext:WideString); safecall;
      function Get_HookUp:IHookUp; safecall;
      procedure TransferTxnsToDiskette; safecall;
      procedure TransferTxnsFromDiskette; safecall;
      
      procedure ProgressBar(const Title:WideString;Min,Max,Pos,Auto:Integer); safecall;
      procedure OpenCashDrawer; safecall;
    public
      procedure Initialize; override;
      destructor Destroy; override;
      property ParentSink:IUIEventSink read FParentSink write FParentSink;
  end;

implementation

uses
   ComServ2;

{TUIEventSinkBase}
procedure TUIEventSinkBase.DisplayItemInfo(const EventSource: IExecComponent; Index: Integer; BitMap:OleVariant;const Caption: WideString; Price: Currency; State: Integer;Notify,Nested:WordBool);
begin
//   if FParentSink <> nil then
//      FParentSink.DisplayItemInfo(EventSource,Index,BitMap,Caption,Price,State,Notify,Nested);
end;
procedure TUIEventSinkBase.Restore;
begin
//   if FParentSink <> nil then
//      FParentSink.Restore;
end;
procedure TUIEventSinkBase.DisplayInstructions(Style: InstructStyle; const Text:WideString;BitMap:OleVariant);
begin
   if FParentSink <> nil then
      FParentSink.DisplayInstructions(Style,Text,BitMap);
end;
procedure TUIEventSinkBase.DataChanged(const EventSource: IExecComponent;const Value: WideString; FlagError: WordBool);
begin
//   if FParentSink <> nil then
//      FParentSink.DataChanged(EventSource,Value,FlagError);
end;
function TUIEventSinkBase.GetComponentReference(const Name: WideString): IDispatch;
begin
   if FParentSink <> nil then
      Result:=FParentSink.GetComponentReference(Name)
   else
      Result:=nil;
end;
function TUIEventSinkBase.CurrentDetails:WideString;
begin
   if FParentSink <> nil then
      Result:=FParentSink.CurrentDetails
   else
      Result:='';
end;
function TUIEventSinkBase.Translate(const Value: WideString):WideString;
begin
   if FParentSink <> nil then
      Result:=FParentSink.Translate(Value)
   else
      Result:='';
end;
function TUIEventSinkBase.Endorse(X,Y,ColCount:Integer;const CommaText:WideString):WordBool;
begin
   if FParentSink <> nil then
      Result:=FParentSink.Endorse(X,Y,ColCount,CommaText)
   else
      Result:=True;
end;
procedure TUIEventSinkBase.WaitFor(DeviceStatus: DeviceStatusType);
begin
   if FParentSink <> nil then
      FParentSink.WaitFor(DeviceStatus);
end;
procedure TUIEventSinkBase.SwapTo(const ProgID, PassData: WideString);
begin
   if FParentSink <> nil then
      FParentSink.SwapTo(ProgID,PassData);
end;
function TUIEventSinkBase.Get_User:WideString;
begin
   if FParentSink <> nil then
      Result:=FParentSink.Get_User
   else
      Result:='';
end;
function TUIEventSinkBase.Get_Workstation:Integer;
begin
   if FParentSink <> nil then
      Result:=FParentSink.Get_Workstation
   else
      Result:=0;
end;
function TUIEventSinkBase.Get_Office:Integer;
begin
   if FParentSink <> nil then
      Result:=FParentSink.Get_Office
   else
      Result:=0;
end;
function TUIEventSinkBase.ReferenceData(const Name: WideString):WideString;
begin
   if FParentSink <> nil then
      Result:=FParentSink.ReferenceData(Name)
   else
      Result:='';
end;
function TUIEventSinkBase.CurrentLine: Integer;
begin
   if FParentSink <> nil then
      Result:=FParentSink.CurrentLine
   else
      Result:=0;
end;
procedure TUIEventSinkBase.Print2x2(const Title,Desc1,Desc2,Office,DataCommatext:WideString);
begin
   if FParentSink <> nil then
      FParentSink.Print2x2(Title,Desc1,Desc2,Office,DataCommatext);
end;
function TUIEventSinkBase.Get_HookUp:IHookUp;
begin
   if FParentSink <> nil then
      Result:=FParentSink.Get_HookUp
   else
      Result:=nil;
end;
procedure TUIEventSinkBase.Initialize;
begin
   inherited Initialize;
   _AddRef;
end;
destructor TUIEventSinkBase.Destroy;
begin
   if FParentSink <> nil then
      FParentSink:=nil;
end;
procedure TUIEventSinkBase.TransferTxnsFromDiskette;
begin
   if FParentSink <> nil then
      FParentSink.TransferTxnsFromDiskette;
end;
procedure TUIEventSinkBase.TransferTxnsToDiskette;
begin
   if FParentSink <> nil then
      FParentSink.TransferTxnsToDiskette;
end;
procedure TUIEventSinkBase.ProgressBar(const Title:WideString;Min,Max,Pos,Auto:Integer);
begin
   if FParentSink <> nil then
      FParentSink.ProgressBar(Title,Min,Max,Pos,Auto);
end;
procedure TUIEventSinkBase.OpenCashDrawer;
begin
   if FParentSink <> nil then
      FParentSink.OpenCashDrawer;
end;

end. 
