unit BaseGroup;

interface

uses
  Windows,Classes,ComObj, ActiveX, SysUtils, GPCSBaseAU, GPCSBase_TLB,
  GPCSErrorLine,GPCSErrorCode,GPCSGUID;

type
  TBaseGroup = class(TGPCSAbstractGroup,IEventSink)
  protected
    FItemList:TItemList;
    FUIEventSink:IUIEventSink;
    function GetResourceString(Index:Integer):String;            virtual; abstract;
    procedure Complete(const EventSource: IExecComponent);       virtual; safecall;
    procedure DesignComplete(const EventSource: IExecComponent); virtual; safecall;
  public
    procedure Initialize; override;
    function Get_Version: Integer;                             override;
    function Design(const Password: WideString; const EVSink: IDesignEventSink): WideString; override;
    procedure TerminateDesign;                                 override;
    procedure TerminateExecute(const TxnLog: ITransactionLog); override;
    procedure CompleteExecute(var Index:Integer;const TxnLog: ITransactionLog);  override;
    function Get_Count: Integer;                               override;
    function Get_Item(Index: Integer): WideString;             override;
    function Get_Key: Integer;                                 override;
    function Get_BitMap: OleVariant;                           override;
    function Get_Caption: WideString;                          override;
    function Get_Price(ScaleReading: Integer): Currency;       override;
    function Get_PMessage: WideString;                         override;
    function Get_Prompt  : WideString;                         override;
    function Get_Title   : WideString;                         override;
    procedure Execute(Quantity,MaxItems:Integer;
                      NoRedraw:WordBool;const UIEventSink:IUIEventSink;
                      const TxnLog:ITransactionLog;Nested:WordBool); override;
    function Get_Name: WideString;                             override;
    function Get_ProjectFiles: WideString;                     override;
    function Get_GUID: WideString;                             override;
    function Get_ProgramID: WideString;                        override;
  end;

implementation
uses
   ComServ2;

{TBaseGroup}
procedure TBaseGroup.Initialize;
begin
  inherited Initialize;
  if ComServer.StartMode = smStandAlone then
     _AddRef;
end;
function TBaseGroup.Get_Version: Integer;
begin
   try
      Result:=StrToIntDef(GetResourceString(riVersion),1);
   except
      on E:Exception do RaiseException(EC_Group_TBaseGroup_Get_Version,E);
   end;
end;
function TBaseGroup.Design(const Password: WideString; const EVSink: IDesignEventSink): WideString;
begin
   Result:='';
end;
procedure TBaseGroup.TerminateDesign;
begin
   try
     // do something
   except
      on E:Exception do RaiseException(EC_Group_TBaseGroup_TerminateDesign,E);
   end;
end;
function TBaseGroup.Get_BitMap: OleVariant;
begin
   try
      Result:=GetResourceString(riBitMap);
   except
      on E:Exception do RaiseException(EC_Group_TBaseGroup_Get_BitMap,E);
   end;
end;
function TBaseGroup.Get_Caption: WideString;
begin
   try
      Result:=GetResourceString(riCaption);
   except
      on E:Exception do RaiseException(EC_Group_TBaseGroup_Get_Caption,E);
   end;
end;
function TBaseGroup.Get_Price(ScaleReading: Integer): Currency;
begin
   try
      Result:=0;
   except
      on E:Exception do RaiseException(EC_Group_TBaseGroup_Get_Price,E);
   end;
end;
function TBaseGroup.Get_Count: Integer;
begin
   try
      Result:=StrToIntDef(GetResourceString(riCount),0);
   except
      on E:Exception do RaiseException(EC_Group_TBaseGroup_Get_Count,E);
   end;
end;
function TBaseGroup.Get_Item(Index: Integer): WideString;
begin
   try
      Result:=GetResourceString(riItemBase+Index);
   except
      on E:Exception do RaiseException(EC_Group_TBaseGroup_Get_Item,E);
   end;
end;
function TBaseGroup.Get_Key: Integer;
begin
   try
      Result:=StrToIntDef(GetResourceString(riKey),0);
   except
      on E:Exception do RaiseException(EC_Group_TBaseGroup_Get_Key,E);
   end;
end;
function TBaseGroup.Get_PMessage: WideString;
begin
   try
      Result:=GetResourceString(riPMessage);
   except
      on E:Exception do RaiseException(EC_GPCSBase_TGPCSExecComponent_Get_PMessage,E);
   end;
end;
function TBaseGroup.Get_Prompt  : WideString;
begin
   try
      Result:=GetResourceString(riPrompt);
   except
      on E:Exception do RaiseException(EC_GPCSBase_TGPCSExecComponent_Get_Prompt,E);
   end;
end;
function TBaseGroup.Get_Title   : WideString;
begin
   try
      Result:=GetResourceString(riTitle);
   except
      on E:Exception do RaiseException(EC_GPCSBase_TGPCSExecComponent_Get_Title,E);
   end;
end;
function TBaseGroup.Get_Name: WideString;        
begin
   try
      Result:=GetResourceString(riName);
   except
      on E:Exception do RaiseException(EC_GPCSBase_TGPCSExecComponent_Get_Title,E);
   end;
end;
function TBaseGroup.Get_ProjectFiles: WideString;
begin
   try
      Result:=GetResourceString(riProjectFiles);
   except
      on E:Exception do RaiseException(EC_GPCSBase_TGPCSExecComponent_Get_Title,E);
   end;
end;
function TBaseGroup.Get_GUID: WideString;        
begin
   try
      Result:=GetResourceString(riGUID);
   except
      on E:Exception do RaiseException(EC_GPCSBase_TGPCSExecComponent_Get_Title,E);
   end;
end;
function TBaseGroup.Get_ProgramID: WideString;   
begin
   try
      Result:=GetResourceString(riProgramID);
   except
      on E:Exception do RaiseException(EC_GPCSBase_TGPCSExecComponent_Get_Title,E);
   end;
end;
procedure TBaseGroup.Execute(Quantity, MaxItems: Integer; NoRedraw: WordBool; 
                  const UIEventSink: IUIEventSink;const TxnLog:ITransactionLog;Nested:WordBool);
var
   I,J:Integer;
   CompMan:ICompMan;
   CurrentItem:IExecComponent;
   S:String;
   CompressedBitmap:Variant;
begin
   if UIEventSink = nil then Exit;
   FUIEventSink:=UIEventSink;

   if FItemList <> nil then FItemList.Free;
   FItemList:=TItemList.Create;

   CompMan:=CreateCompMan;
   for I:=0 to Get_Count-1 do
   begin
      S:=Get_Item(I);
      if (Copy(S,1,8) = 'Product.') or (Copy(S,1,6) = 'Group.') then
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
      if (Copy(S,1,8) = 'Product.') or (Copy(S,1,6) = 'Group.') then
      begin
         if FItemList[J].Instance <>  nil then
         begin
            CurrentItem:=FItemList[J].Instance;
            if not NoRedraw then
            begin
               CompressedBitmap:=CurrentItem.Bitmap;
              // crashes out here
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
end;
procedure TBaseGroup.Complete(const EventSource: IExecComponent);
begin
end;
procedure TBaseGroup.DesignComplete(const EventSource: IExecComponent);
begin
end;
procedure TBaseGroup.TerminateExecute(const TxnLog:ITransactionLog);          
begin
   try
      if FItemList <> nil then 
         FItemList.Free;
      FItemList:=nil;
      FUIEventSink:=nil;
   except
      on E:Exception do RaiseException(EC_Group_TBaseGroup_TerminateExecute+1,E);
   end;
end;
procedure TBaseGroup.CompleteExecute(var Index:Integer;const TxnLog:ITransactionLog);
begin
   TerminateExecute(TxnLog);
end;
//procedure TBaseGroup.NotifyChildClick(const Name: WideString; Index: Integer); 
//begin
//   ;
//end;

end.

