unit DesInterfaceU;

interface

uses
   ComObj,ComServ2,GPCSBase_TLB,Windows,Messages,Forms;
const
   WM_CANCELDESIGN =  WM_USER+1;
type
   TDesInterface = class(TAutoObject,IDesignEventSink)
   private
      FComponent:IComponent;
      WindowHandle:THandle;
      FParent:THandle;
      FBuildParams:String;
      FDataChange:String;
      procedure WndProc(var Message: TMessage);
      procedure WMCancelDesign(var Msg:TMessage); message WM_CANCELDESIGN;
   public
      procedure Initialize; override;
      destructor Destroy; override;
      function Get_Parent: Integer; safecall;
      procedure Set_Parent(Value: Integer); safecall;
      function Get_BuildParams: WideString; safecall;
      procedure Set_BuildParams(const Value: WideString); safecall;
      function Get_DataChange: WideString; safecall;
      procedure Set_DataChange(const Value: WideString); safecall;
      procedure Cancel; safecall;
      function ReBuild: WordBool; safecall;
      function Attach(const Component: IComponent): WordBool; safecall;
   end;
   
implementation

{TDesInterface}
procedure TDesInterface.WndProc(var Message: TMessage);
begin
  try
    Dispatch(Message);
  except
//      on E:Exception do RaiseException(8,E);
  end;
end;
procedure TDesInterface.WMCancelDesign(var Msg:TMessage);
begin
   try
      if FComponent <> nil then
         FComponent.TerminateDesign;
   except
//      on E:Exception do RaiseException(21,E);
   end;
   FComponent:=nil;
end;  
procedure TDesInterface.Initialize;
begin
   inherited Initialize;
   WindowHandle:=AllocateHWnd(WndProc);
   _AddRef;                
end;
destructor TDesInterface.Destroy;
begin
   if WindowHandle <> 0 then DeAllocateHWnd(WindowHandle);
   inherited Destroy;
end;
function TDesInterface.Get_Parent: Integer;
begin
   Result:=FParent;
end;
procedure TDesInterface.Set_Parent(Value: Integer);
begin
   FParent:=Value;
end;
function TDesInterface.Get_BuildParams: WideString;
begin
   Result:=FBuildParams;
end;
procedure TDesInterface.Set_BuildParams(const Value: WideString);
begin
   FBuildParams:=Value;
end;
function TDesInterface.Get_DataChange: WideString;
begin
   Result:=FDataChange;
end;
procedure TDesInterface.Set_DataChange(const Value: WideString);
begin
   FDataChange:=Value;
end;
procedure TDesInterface.Cancel;
begin
   PostMessage(WindowHandle,WM_CANCELDESIGN,0,0);
end;
function TDesInterface.ReBuild: WordBool;
begin
   PostMessage(WindowHandle,WM_CANCELDESIGN,0,0);
end;
function TDesInterface.Attach(const Component: IComponent): WordBool;
begin
   FComponent:=Component;
end;

initialization
  TComObjectFactory.Create(ComServer,TDesInterface,
                           StringToGUID('{CD6B5B60-D692-11D2-AA05-00A0CC3A61B2}'),
                           'DesInterface,TDesInterface','TDesInterface',ciInternal);
end.     
