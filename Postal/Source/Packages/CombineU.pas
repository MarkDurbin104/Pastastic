unit CombineU;

interface

uses
  Forms,Classes,ComObj,EvSinkBaseU,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,PackStrListU,Dialogs,SysUtils;

type
  TCompRef = class(TUIEventSinkBase)
    private
      FProgId        :String;
      FProdInterface :IProduct;
      FIncluded      :Boolean; // Include By Code     
      FForceInc      :Boolean; // Include By KeyPress if logical OR for down
      FEnabled       :Boolean;
      FLineCount     :Integer;
      FDispIndex     :Integer;
      FTotal         :Currency;
      function  GetInterface:IProduct;
    protected
    public
      procedure Initialize; override;
      destructor Destroy; override;
      property ProgId        :String   read FProgId      write FProgId     ;
      property ProdInterface :IProduct read GetInterface write FProdInterface;
      property Included      :Boolean  read FIncluded    write FIncluded   ;
      property ForceInc      :Boolean  read FForceInc    write FForceInc   ;
      property Enabled       :Boolean  read FEnabled     write FEnabled    ;
      property LineCount     :Integer  read FLineCount   write FLineCount  ;
      property DispIndex     :Integer  read FDispIndex   write FDispIndex  ;
      property Total         :Currency read FTotal       write FTotal      ;
      function  GetData:String;
      procedure SetData(Value:WideString;var FlagError:WordBool);
      procedure DataChanged(const EventSource: IExecComponent;const Value: WideString; FlagError: WordBool); override;
  end;
  TCombineList = class(TObject)
    private
      FParentSink:IUIEventSink;
      ProdList:TPackStringList;
      FValid:Boolean;
      FBaseProduct:TGPCSAbstractProduct;
    protected
       procedure SetParentSink(Value:IUIEventSink);
       function GetButtonFlags:String;
       procedure SetButtonFlags(Value:String);
    public
       constructor Create(ProgIDList:String);
       destructor Destroy; override;
       procedure Toggle(ProgID:String);
       procedure Enable(ProgID:String);
       procedure Disable(ProgID:String);
       procedure SetEnabled(ProgId:String;Condition:Boolean);       
       procedure Select(ProgID:String);
       procedure DeSelect(ProgID:String);
       procedure ForceSelect(ProgID:String);
       procedure ForceDeSelect(ProgID:String);
       function IsEnabled(ProgID:String):Boolean;
       function IsSelected(ProgID:String):Boolean;
       function IsForceSelected(ProgID:String):Boolean;
       function IsAutoSelected(ProgID:String):Boolean;
       function IndexOf(ProgID:String):Integer;
       function TotalOf(ProgID:String):Currency;
       procedure LogTransactions(var Index:Integer;const TxnLog: ITransactionLog);
       function InsertPackText(Value:string;InsertAtLine:Integer;var Total:Currency):String;
       function RemovePackText(Value:string;RemoveFromLine:Integer):String;
       function InstanceOf(ProgID:String):IProduct;
       function ItemName(DisplayIndex:Integer;DefaultStr:String):String;
       property ParentSink:IUIEventSink read FParentSink write SetParentSink;
       property Valid:Boolean read FValid write FValid;
       property ButtonFlags:String read GetButtonFlags write SetButtonFlags;
       property BaseProduct:TGPCSAbstractProduct read FBaseProduct write FBaseProduct;
  end;
implementation
uses
   ComServ2;
function GetLines(FLines:String;var Total:Currency):String;
var
   I:Integer;
   SL:TPackStringList;
   LSL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.PackText:=FLines;
   LSL:=TPackStringList.Create;
   I:=0;
   while I < SL.Count do
   begin
      LSL.PackText:=SL[I];
      if (LSL[2] = 'M') and (LSL.Count > 9) and (LSL[9] = 'TotalField') then
      begin
         Total:=Total+StrToCurrDef(LSL[5],0);
         SL.Delete(I);
         Dec(I);
      end;
      Inc(I);
   end;
   LSL.Free;
   Result:=SL.PackText;
   SL.Free;
end;
{TCompRef}
procedure TCompRef.Initialize;
begin
   inherited Initialize;
   FProgId       :='';
   FProdInterface:=nil;
   FIncluded     :=False;
   ForceInc      :=False;
   FEnabled      :=True;
end;
destructor TCompRef.Destroy;
begin
   ParentSink:=nil;
   if FProdInterface <> nil then FProdInterface.TerminateExecute(nil);
   FProdInterface:=nil;
   inherited Destroy;
end;
procedure TCompRef.DataChanged(const EventSource: IExecComponent;const Value: WideString; FlagError: WordBool);
begin
   
end;
function TCompRef.GetInterface:IProduct;
var
   CompMan:ICompMan;
begin
   if (FProdInterface = nil) and (FProgId <> '') then
   begin
      try
         CompMan:=CreateCompMan;
         While not CompMan.Ready do Application.ProcessMessages;
         FProdInterface:=CompMan.LoadComponent(FProgID) as IProduct;
         if FProdInterface <> nil then
            FProdInterface.Execute(1,10,False,Self,nil,True);
      except
         FProdInterface:=nil;
      end;
      CompMan:=nil;
   end;
   Result:=FProdInterface;
end;
function TCompRef.GetData:String;
var
   SL:TPackStringList;
begin
   if (ProdInterface <> nil) and (FIncluded or FForceInc) and (FEnabled) then
      Result:=ProdInterface.GetExecData
   else
      Result:='';

   FTotal:=0;
   Result:=GetLines(Result,FTotal);
   SL:=TPackStringList.Create;
   SL.PackText:=Result;
   FLineCount:=SL.Count;
   SL.Free;
end;
procedure TCompRef.SetData(Value:WideString;var FlagError:WordBool);
begin
   if ProdInterface <> nil then
      ProdInterface.SetExecData(Value,FlagError);
end;

{TCombineList}
constructor TCombineList.Create(ProgIDList:String);
var
   I:Integer;
   CompRef:TCompRef;
begin
   inherited Create;
   FValid:=True;
   ProdList:=TPackStringList.Create;
   ProdList.PackText:=ProgIDList;
   for I:=0 to ProdList.Count-1 do
   begin
      CompRef:=TCompRef.Create;
      CompRef.DispIndex:=StrToInt('$'+Copy(ProdList[I],1,2));
      ProdList[I]:=Copy(ProdList[I],3,Length(ProdList[I]));
      CompRef.ProgId:=ProdList[I];
      CompRef.ParentSink:=nil;
      ProdList.Objects[I]:=CompRef;
   end;
end;         
destructor TCombineList.Destroy;
var
   I:Integer;
   CompRef:TCompRef;
begin
   for I:=0 to ProdList.Count-1 do 
   begin
      CompRef:=TCompRef(ProdList.Objects[I]);
      if CompRef <> nil then
      begin
         CompRef.Free;
      end;
   end;
   ProdList.Free;
   inherited Destroy;
end;
procedure TCombineList.SetParentSink(Value:IUIEventSink);
var
   I:Integer;
   CompRef:TCompRef;
begin
   FParentSink:=Value;
   for I:=0 to ProdList.Count-1 do
   begin
      CompRef:=TCompRef(ProdList.Objects[I]);
      if CompRef <> nil then
         CompRef.ParentSink:=FParentSink;
   end;
end;
procedure TCombineList.LogTransactions(var Index:Integer;const TxnLog: ITransactionLog);
var
   I:Integer;
   CompRef:TCompRef;
begin
   for I:=0 to ProdList.Count-1 do
   begin
      CompRef:=TCompRef(ProdList.Objects[I]);
      if (CompRef.Included or CompRef.FForceInc) and (CompRef.Enabled) then
      begin
         CompRef.ProdInterface.CompleteExecute(Index,Txnlog);
         Inc(Index);
      end
      else
      begin
         CompRef.ProdInterface.TerminateExecute(Txnlog);
      end;
      CompRef.ProdInterface:=nil;
   end;
end;
function TCombineList.IndexOf(ProgID:String):Integer;
begin
   Result:=ProdList.IndexOf(ProgID);
end;

function TCombineList.TotalOf(ProgID:String):Currency;
var
   I:Integer;
begin
   Result:=0;
   I:=ProdList.IndexOf(ProgID);
   if I <> -1 then
      Result:=TCompRef(ProdList.Objects[I]).Total;
end;
function TCombineList.IsAutoSelected(ProgID:String):Boolean;
var
   I:Integer;
begin
   Result:=False;
   I:=ProdList.IndexOf(ProgID);
   if I <> -1 then
      Result:=TCompRef(ProdList.Objects[I]).Included;
end;
function TCombineList.IsForceSelected(ProgID:String):Boolean;
var
   I:Integer;
begin
   Result:=False;
   I:=ProdList.IndexOf(ProgID);
   if I <> -1 then
      Result:=TCompRef(ProdList.Objects[I]).ForceInc;
end;
function TCombineList.IsSelected(ProgID:String):Boolean;
var
   I:Integer;
begin
   Result:=False;
   I:=ProdList.IndexOf(ProgID);
   if I <> -1 then
      Result:= TCompRef(ProdList.Objects[I]).Enabled
              and ( TCompRef(ProdList.Objects[I]).Included or TCompRef(ProdList.Objects[I]).ForceInc );
end;
function TCombineList.GetButtonFlags:String;
var
   I:Integer;
   CompRef:TCompRef;
begin
   Result:='';
   for I:=0 to ProdList.Count-1 do
   begin
      CompRef:=TCompRef(ProdList.Objects[I]);
      if (CompRef.Included or CompRef.FForceInc) then
         Result:=Result+'1'
      else
         Result:=Result+'0'
   end;
//   for I:=0 to ProdList.Count-1 do
//   begin
//      CompRef:=TCompRef(ProdList.Objects[I]);
//      if CompRef.Enabled then
//         Result:=Result+'1'
//      else
//         Result:=Result+'0'
//   end;
end;
procedure TCombineList.SetButtonFlags(Value:String);
var
   I:Integer;
   CompRef:TCompRef;
begin
   for I:=0 to ProdList.Count-1 do
   begin
      CompRef:=TCompRef(ProdList.Objects[I]);
      if Copy(Value,I+1,1) = '1' then
         //CompRef.Included:=True
         CompRef.ForceInc:=True
      else
         CompRef.ForceInc:=False;
         //CompRef.Included:=False;
   end;
//   for I:=0 to ProdList.Count-1 do
//   begin
//      CompRef:=TCompRef(ProdList.Objects[I]);
//      if Copy(Value,I+ProdList.Count+1,1) = '1' then
//         CompRef.Enabled:=True
//      else
//         CompRef.Enabled:=False;
//   end;
end;
procedure TCombineList.ForceSelect(ProgID:String);
var
   I:Integer;
   CompRef:TCompRef;
begin
   I:=ProdList.IndexOf(ProgID);
   if I <> -1 then
   begin
      CompRef:=TCompRef(ProdList.Objects[I]);
      if not (CompRef.ForceInc) then
      begin
         CompRef.ForceInc:=True;
         if FParentSink <> nil then
         begin
            if CompRef.Enabled then
            begin
               if (CompRef.Included or CompRef.FForceInc) then
                  FParentSink.DisplayItemInfo(FBaseProduct,CompRef.DispIndex,'','',0,BUTTON_ENABLED_DOWN,True,True)
               else
                  FParentSink.DisplayItemInfo(FBaseProduct,CompRef.DispIndex,'','',0,BUTTON_ENABLED_UP,True,True);
            end
            else
            begin
               FParentSink.DisplayItemInfo(FBaseProduct,CompRef.DispIndex,'','',0,0,True,True)
            end;
         end;
      end;
   end;
end;
procedure TCombineList.ForceDeSelect(ProgID:String);
var
   I:Integer;
   CompRef:TCompRef;
begin
   I:=ProdList.IndexOf(ProgID);
   if I <> -1 then
   begin
      CompRef:=TCompRef(ProdList.Objects[I]);
      if CompRef.ForceInc then
      begin
         CompRef.ForceInc:=False;
         if FParentSink <> nil then
         begin
            if CompRef.Enabled then
            begin
               if (CompRef.Included or CompRef.FForceInc) then
                  FParentSink.DisplayItemInfo(FBaseProduct,CompRef.DispIndex,'','',0,BUTTON_ENABLED_DOWN,True,True)
               else
                  FParentSink.DisplayItemInfo(FBaseProduct,CompRef.DispIndex,'','',0,BUTTON_ENABLED_UP,True,True);
            end
            else
            begin
               FParentSink.DisplayItemInfo(FBaseProduct,CompRef.DispIndex,'','',0,0,True,True)
            end;
         end;
      end;
   end;
end;
procedure TCombineList.Select(ProgID:String);
var
   I:Integer;
   CompRef:TCompRef;
begin
   I:=ProdList.IndexOf(ProgID);
   if I <> -1 then
   begin
      CompRef:=TCompRef(ProdList.Objects[I]);
      if not (CompRef.Included) then
      begin
         CompRef.Included:=True;
         if FParentSink <> nil then
         begin
            if CompRef.Enabled then
            begin
               if (CompRef.Included or CompRef.FForceInc) then
                  FParentSink.DisplayItemInfo(FBaseProduct,CompRef.DispIndex,'','',0,BUTTON_ENABLED_DOWN,True,True)
               else
                  FParentSink.DisplayItemInfo(FBaseProduct,CompRef.DispIndex,'','',0,BUTTON_ENABLED_UP,True,True);
            end
            else
            begin
               FParentSink.DisplayItemInfo(FBaseProduct,CompRef.DispIndex,'','',0,0,True,True)
            end;
         end;
      end;
   end;
end;
procedure TCombineList.DeSelect(ProgID:String);
var
   I:Integer;
   CompRef:TCompRef;
begin
   I:=ProdList.IndexOf(ProgID);
   if I <> -1 then
   begin
      CompRef:=TCompRef(ProdList.Objects[I]);
      if CompRef.Included then
      begin
         CompRef.Included:=False;
         if FParentSink <> nil then
         begin
            if CompRef.Enabled then
            begin
               if (CompRef.Included or CompRef.FForceInc) then
                  FParentSink.DisplayItemInfo(FBaseProduct,CompRef.DispIndex,'','',0,BUTTON_ENABLED_DOWN,True,True)
               else
                  FParentSink.DisplayItemInfo(FBaseProduct,CompRef.DispIndex,'','',0,BUTTON_ENABLED_UP,True,True);
            end
            else
            begin
               FParentSink.DisplayItemInfo(FBaseProduct,CompRef.DispIndex,'','',0,0,True,True)
            end;
         end;
      end;
   end;
end;
procedure TCombineList.Enable(ProgID:String);
var
   I:Integer;
   CompRef:TCompRef;
begin
   I:=ProdList.IndexOf(ProgID);
   if I <> -1 then
   begin
      CompRef:=TCompRef(ProdList.Objects[I]);
      if not (CompRef.Enabled) then
      begin
         CompRef.Enabled:=True;
         if FParentSink <> nil then
         begin
            FParentSink.DisplayItemInfo(FBaseProduct,CompRef.DispIndex,
                                     CompRef.ProdInterface.Bitmap,
                                     CompRef.ProdInterface.Caption,
                                     CompRef.ProdInterface.Price[0],1,True,True);
            if (CompRef.Included or CompRef.FForceInc) then
               FParentSink.DisplayItemInfo(FBaseProduct,CompRef.DispIndex,'','',0,BUTTON_ENABLED_DOWN,True,True)
            else
               FParentSink.DisplayItemInfo(FBaseProduct,CompRef.DispIndex,'','',0,BUTTON_ENABLED_UP,True,True);
         end;
      end;
   end;
end;
procedure TCombineList.Disable(ProgID:String);
var
   I:Integer;
   CompRef:TCompRef;
begin
   I:=ProdList.IndexOf(ProgID);
   if I <> -1 then
   begin
      CompRef:=TCompRef(ProdList.Objects[I]);
      if CompRef.Enabled then
      begin
         CompRef.Enabled:=False;
         if FParentSink <> nil then
         begin
            FParentSink.DisplayItemInfo(FBaseProduct,CompRef.DispIndex,
                                        '','',0,1,False,False);
         end;
      end;
   end;
end;
procedure TCombineList.SetEnabled(ProgId:String;Condition:Boolean);
begin
  If Condition then Enable(ProgID)
  else Disable(ProgId);
end;
function TCombineList.ItemName(DisplayIndex:Integer;DefaultStr:String):String;
var
  I:Integer;
begin
   Result:=DefaultStr;
   for I:=0 to ProdList.Count-1 do
   begin
      if TCompRef(ProdList.Objects[I]).DispIndex = DisplayIndex then
      begin
         if TCompRef(ProdList.Objects[I]).Enabled then
            Result:=TCompRef(ProdList.Objects[I]).ProgID
         else
            Result:='';
         break;
      end;  
   end;
end;

function TCombineList.IsEnabled(ProgID:String):Boolean;
var
   I:Integer;
begin
   I:=ProdList.IndexOf(ProgID);
   Result:=False;
   if I <> -1 then
      Result:=TCompRef(ProdList.Objects[I]).Enabled;
end;
procedure TCombineList.Toggle(ProgID:String);
var
   I:Integer;
begin
   I:=ProdList.IndexOf(ProgID);
   if I <> -1 then
   begin
      if TCompRef(ProdList.Objects[I]).ForceInc then
         ForceDeSelect(ProgID)
      else
         ForceSelect(ProgID);
   end;
end;
function TCombineList.InsertPackText(Value:string;InsertAtLine:Integer;var Total:Currency):String;
var
   I,J,K:Integer;
   SL:TPackStringList;
   ResSL:TPackStringList;
   CompRef:TCompRef;
   LineSL:TPackStringList;
   RLineSL:TPackStringList;
   Skip:Boolean;
begin
   LineSL:=TPackStringList.Create;
   RLineSL:=TPackStringList.Create;
   ResSL:=TPackStringList.Create;
   ResSL.PackText:=Value;
   if InsertAtLine = -1 then
      InsertAtLine:=ResSL.Count-1;
   SL:=TPackStringList.Create;
   for I:=0 to ProdList.Count-1 do
   begin
      CompRef:=TCompRef(ProdList.Objects[I]);
      SL.PackText:=CompRef.GetData;
      Total:=Total+CompRef.Total;
      for J:=0 to SL.Count-1 do
      begin
         Skip:=False;
         LineSL.PackText:=SL[J];
         for K:=0 to ResSL.Count-1 do
         begin
            RLineSL.PackText:=ResSL[K];
            if RLineSL[3] = LineSL[3] then
            begin
               Skip:=True;
               break;
            end;
         end;
         if not Skip then
         begin
            ResSL.Insert(InsertAtLine,SL[J]);
            Inc(InsertAtLine);
         end;
      end;    
   end;
//   ShowMessage(ResSL.Text);
   SL.Free;
   Result:=ResSL.PackText;
   RLineSL.Free;
   LineSL.Free;
   ResSL.Free;
end;
function TCombineList.RemovePackText(Value:string;RemoveFromLine:Integer):String;
var
   I:Integer;
   CompRef:TCompRef;
   FlagError:WordBool;
begin
   Valid:=True;
   for I:=0 to ProdList.Count-1 do
   begin
      CompRef:=TCompRef(ProdList.Objects[I]);
      FlagError:=False;
      CompRef.SetData(Value,FlagError);
      if (FlagError) and (CompRef.Included or CompRef.FForceInc) then Valid:=False;
   end;
   Result:=Value;
end;
function TCombineList.InstanceOf(ProgID:String):IProduct;
var
   Index:Integer;
begin
   Index:=ProdList.IndexOf(ProgID);
   if Index <> -1 then
      Result:=TCompRef(ProdList.Objects[Index]).ProdInterface
   else
      Result:=nil;
end;

initialization
  TComObjectFactory.Create(ComServer,TCompRef,
                          StringToGUID('{F7201190-9CF0-11D3-9F10-00902707E0A1}'),
                          'Internal.UIEventSink','Internal.UIEventSink',ciInternal);
end.
