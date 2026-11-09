unit UIStateAU;

interface

uses
  Windows, Messages,Forms,ComObj,ComServ2,UIStatesU,GPCSBase_TLB,GPCSBaseAU,UIInterfaceU;
  
const
   WM_KEYPRESSED =WM_USER+1;   
   
type            
   TUIState = class(TAutoObject,IUIState)
   private
      WindowHandle:THandle;
   protected
      procedure Initialize; override;
      destructor Destroy; override;
      procedure ShowForm(const Items: IPickItemList; const Product: IProduct; const HItems: IPickItemList; const HText: WideString); safecall;
      function ShowWarning(const WButtons: IPickItemList; const Warning: WideString): Integer; safecall;
      procedure ShowHelp(const HelpText: WideString); safecall;
      procedure ShowInfo(const HelpText: WideString); safecall;
      function PickItem(const Items: IPickItemList; ShowNumbers, Sorted: WordBool; DefaultItem: Integer): Integer; safecall;
      function PickMenuItem(const Items: IPickItemList; const TransactionLog: ITransactionLog): Integer; safecall;
      function Get_CurrentState: FormState; safecall;
      procedure Set_CurrentState(Value: FormState); safecall;
   public                                          
      procedure WndProc(var Message: TMessage);
   end;

implementation

uses
   UITypesFU;
   
{TUIClientSink}
procedure TUIState.Initialize;
begin
   inherited Initialize;
   WindowHandle:=AllocateHWnd(WndProc);
end;
destructor TUIState.Destroy;
begin
   if WindowHandle <> 0 then DeAllocateHWnd(WindowHandle);
end;
procedure TUIState.WndProc(var Message: TMessage);
begin
  try             
    Dispatch(Message);
  except
    Application.HandleException(Self);
  end;
end;
procedure TUIState.ShowForm(const Items: IPickItemList; const Product: IProduct; const HItems: IPickItemList; const HText: WideString);
begin
end;
function TUIState.ShowWarning(const WButtons: IPickItemList; const Warning: WideString): Integer;
begin
   Result:=0;
end;
procedure TUIState.ShowHelp(const HelpText: WideString);
begin
end;
procedure TUIState.ShowInfo(const HelpText: WideString);
begin
end;
function TUIState.PickItem(const Items: IPickItemList; ShowNumbers, Sorted: WordBool; DefaultItem: Integer): Integer;
begin
   Result:=0;
end;
function TUIState.PickMenuItem(const Items: IPickItemList; const TransactionLog: ITransactionLog): Integer;
var
   PickItemList:TIPickItemList;
begin
   Form1.StartUI;
   PickItemList:=TIPickItemList.Create;
   PickItemList.LoadFromInterface(Items);
   Result:=Form1.UIInterface.UIStateEngine.PickMenuItem(PickItemList.PickList,nil,0);
   PickItemList.Free;
end;
function TUIState.Get_CurrentState: FormState;
begin
   Result:=uisNone;
end;
procedure TUIState.Set_CurrentState(Value: FormState);
begin

end;

initialization
   TGPCSCompFactory.Create(ComServer,TUIState,
                           StringToGUID('{B472C07A-0366-45F0-995E-27C4E5C2FB50}'),
                           'Support.UIState','GPCS UIState Support Component',ciMultiInstance);

end.
 