unit UIClientSinkU;

interface

uses
  Windows, Messages,Forms,ComObj,ComServ2,UIStatesU,GPCSBase_TLB,GPCSBaseAU;
  
const
   WM_KEYPRESSED =WM_USER+1;   
   
type            
   TUIClientSink = class(TAutoObject,IUIClientSink)
   private
      FUIStateEngine:TUIStateEngine;
      WindowHandle:THandle;
   protected
      procedure Initialize; override;
      destructor Destroy; override;
      procedure KeyPress(KeyCode:Integer;SystemKey:WordBool); safecall;
      procedure WMKeyPressed(var Msg:TMessage); message WM_KEYPRESSED;
   public                                          
      procedure WndProc(var Message: TMessage);
      property UIStateEngine:TUIStateEngine read FUIStateEngine write FUIStateEngine;
   end;

implementation

{TUIClientSink}
procedure TUIClientSink.Initialize;
begin
   inherited Initialize;
   _AddRef;
   FUIStateEngine:=nil;
   WindowHandle:=AllocateHWnd(WndProc);
end;
destructor TUIClientSink.Destroy;
begin
   if WindowHandle <> 0 then DeAllocateHWnd(WindowHandle);
end;
procedure TUIClientSink.WndProc(var Message: TMessage);
begin
  try             
    Dispatch(Message);
  except
    Application.HandleException(Self);
  end;
end;
procedure TUIClientSink.KeyPress(KeyCode:Integer;SystemKey:WordBool);
begin
   PostMessage(WindowHandle,WM_KEYPRESSED,Integer(SystemKey),KeyCode);
end;
procedure TUIClientSink.WMKeyPressed(var Msg:TMessage);
begin
   with Msg do
   begin
      if FUIStateEngine <> nil then
         FUIStateEngine.KeyPress(lParam,WordBool(wParam)); // lParam =KeyCode  wParam=SystemKey
   end;
end;

initialization
   TGPCSCompFactory.Create(ComServer,TUIClientSink,
                           StringToGUID('{C54DFF44-D386-4601-B824-E3BD7B9F00CC}'),
                           'TUIClient.UIClientSink','GPCS Internal UIClientSink',ciInternal);
end.
