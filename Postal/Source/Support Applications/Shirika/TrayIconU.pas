unit TrayIconU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,  ExtCtrls, Menus, ShellApi;

type
  TRegisterServiceProcess = function(dwProcessID, dwType: Integer): Integer; stdcall;

  TTrayIcon = class(TComponent)
  private
    FActive: Boolean;
    FIcon: TIcon;
    FIc: TNotifyIconData;
    FHandle: THandle;
    FHint: string;
    FPopupMenu: TPopupMenu;
    FOnClick: TMouseEvent;
    FOnDblClick: TMouseEvent;
    FOnMouseMove: TMouseMoveEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseUp: TMouseEvent;
    FVisible: Boolean;
    FAnimated: Boolean;
    FDelay: Cardinal;
    FImgList: TImageList;
    FTimer: TTimer;
    FNumber: Integer;
    FDropDown: TPopupMenu;
    FTask: Boolean;
    FTaskBarRecreate: Integer;
//    FRegisterServiceProcess: TRegisterServiceProcess;
//    FDllHandle: THandle;
    procedure SetActive(Value: Boolean);
    procedure SetHint(Value: string);
    procedure SetIcon(Icon: TIcon);
    procedure SetVisible(Value: Boolean);
    procedure OnAnimate(Sender: TObject);
    procedure SetAnimated(const Value: Boolean);
    procedure SetDelay(const Value: Cardinal);
    procedure SetImgList(const Value: TImageList);
    procedure SetTask(const Value: Boolean);
  public
    procedure IconChanged(Sender: TObject);
    procedure WndProc(var Mesg: TMessage);
    procedure DefaultHandler(var Message); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Active: Boolean read FActive write SetActive default False;
    property Icon: TIcon read FIcon write SetIcon;
    property Hint: string read FHint write SetHint;
    property PopupMenu: TPopupMenu read FPopupMenu write FPopupMenu;
    property ApplicationVisible: Boolean read FVisible write SetVisible default True;
    property Animated: Boolean read FAnimated write SetAnimated default False;
    property Icons: TImageList read FImgList write SetImgList;
    property Delay: Cardinal read FDelay write SetDelay default 100;
    property OnClick: TMouseEvent read FOnClick write FOnClick;
    property OnDblClick: TMouseEvent read FOnDblClick write FOnDblClick;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
    procedure HideApplication;
    procedure ShowApplication;
    property DropDownMenu: TPopupMenu read FDropDown write FDropDown;
    property VisibleInTaskList: Boolean read FTask write SetTask default True;
  end;

implementation

const
  WM_CALLBACKMESSAGE = WM_USER + 1;

{**************************************************}

constructor TTrayIcon.Create(AOwner: TComponent);
begin
  inherited;
  FIcon := TIcon.Create;
  if not (csDesigning in ComponentState) then
    FIcon.Assign(Application.Icon);
  FIcon.OnChange := IconChanged;
  FVisible := True;
  FAnimated := False;
  FDelay := 100;
  FNumber := 0;
  FTimer := TTimer.Create(Self);
  FTImer.Interval := FDelay;
  FTimer.Enabled := FAnimated;
  FTimer.OnTimer := OnAnimate;
  FActive := False;
  FTask := True;
  FTaskBarRecreate:=RegisterWindowMessage('TaskbarCreated');
  
{  if not (csDesigning in ComponentState) then
  begin
    FDllHandle := LoadLibrary('KERNEL32.DLL');
    if FDllHandle <> 0 then
      @FRegisterServiceProcess := GetProcAddress(FDllHandle, 'RegisterServiceProcess')
    else
      @FRegisterServiceProcess := nil;
  end;}
end;

{**************************************************}

procedure TTrayIcon.SetTask(const Value: Boolean);
begin
  if FTask <> Value then
  begin
    FTask := Value;
{    if not (csDesigning in ComponentState) then
      if @FRegisterServiceProcess <> nil then
        if FTask then
          FRegisterServiceProcess(GetCurrentProcessID, 0)
        else
          FRegisterServiceProcess(GetCurrentProcessID, 1);}
  end;
end;

{**************************************************}

destructor TTrayIcon.Destroy;
begin
  if not (csDestroying in Application.ComponentState) then
    SetTask(False);
  FTimer.Free;
  SetActive(False);
  FIcon.Free;
{  if not (csDesigning in ComponentState) then
    if FDllHandle <> 0 then
      FreeLibrary(FDllHandle);}
  inherited;
end;

{**************************************************}

procedure TTrayIcon.DefaultHandler(var Message);
begin
  with TMessage(Message) do
  begin
     if FHandle <> 0 then
     begin
        if Msg = WM_QUIT then
           Active:=False;
        Result:=CallWindowProc(@DefWindowProc,FHandle,Msg,wParam,lParam);
     end;
  end;                   
end;
procedure TTrayIcon.WndProc(var Mesg: TMessage);
var
  po: TPoint;
  ShState: TShiftState;
begin
  try
    with Mesg do
      if Msg = WM_CALLBACKMESSAGE then
      begin
        GetCursorPos(po);
        ShState := [];
        if GetKeyState(VK_SHIFT) < 0 then
          Include(ShState, ssShift);
        if GetKeyState(VK_CONTROL) < 0 then
          Include(ShState, ssCtrl);
        if GetKeyState(VK_LBUTTON) < 0 then
          Include(ShState, ssLeft);
        if GetKeyState(VK_RBUTTON) < 0 then
          Include(ShState, ssRight);
        if GetKeyState(VK_MBUTTON) < 0 then
          Include(ShState, ssMiddle);
        if GetKeyState(VK_MENU) < 0 then
          Include(ShState, ssAlt);
        case LParam of
          WM_MOUSEMOVE:
            begin
              if Assigned(FOnMouseMove) then
                FOnMouseMove(Self, ShState, po.x, po.y);
            end;
          WM_LBUTTONDOWN:
            begin
              if Assigned(FOnMouseDown) then
                FOnMouseDown(Self, mbLeft, ShState, po.x, po.y);
              if FDropDown <> nil then
                FDropDown.Popup(po.x, po.y);
            end;
          WM_LBUTTONUP:
            begin
              if Assigned(FOnMouseUp) then
                FOnMouseUp(Self, mbLeft, ShState, po.x, po.y);
              if Assigned(FOnClick) then
                FOnClick(Self, mbLeft, ShState, po.x, po.y);
            end;
          WM_LBUTTONDBLCLK:
            if Assigned(FOnDblClick) then
              FOnDblClick(Self, mbLeft, ShState, po.x, po.y);
          WM_RBUTTONDOWN:
            if Assigned(FOnMouseDown) then
              FOnMouseDown(Self, mbRight, ShState, po.x, po.y);
          WM_RBUTTONUP:
            begin
              if FPopupMenu <> nil then
                FPopupMenu.Popup(po.x, po.y);
              if Assigned(FOnMouseUp) then
                FOnMouseUp(Self, mbRight, ShState, po.x, po.y);
              if Assigned(FOnClick) then
                FOnClick(Self, mbRight, ShState, po.x, po.y);
            end;
          WM_RBUTTONDBLCLK:
            if Assigned(FOnDblClick) then
              FOnDblClick(Self, mbRight, ShState, po.x, po.y);
          WM_MBUTTONDOWN:
            if Assigned(FOnMouseDown) then
              FOnMouseDown(Self, mbMiddle, ShState, po.x, po.y);
          WM_MBUTTONUP:
            begin
              if Assigned(FOnMouseUp) then
                FOnMouseUp(Self, mbMiddle, ShState, po.x, po.y);
              if Assigned(FOnClick) then
                FOnClick(Self, mbMiddle, ShState, po.x, po.y);
            end;
          WM_MBUTTONDBLCLK:
            if Assigned(FOnDblClick) then
              FOnDblClick(Self, mbMiddle, ShState, po.x, po.y);
          else
             if LParam = FTaskBarRecreate then
             begin
                if FActive then
                  Shell_NotifyIcon(NIM_MODIFY, @fic);
             end;
        end;
      end
      else
      begin
         if Msg = WM_QUIT then
            Active:=False;
         Result := DefWindowProc(FHandle, Msg, wParam, lParam);
      end
  except
    Application.HandleException(Self);
  end;
end;

{**************************************************}

procedure TTrayIcon.IconChanged(Sender: TObject);
begin
  try
     with FIc do
     begin
        if FActive then
        begin
           hIcon:=FIcon.Handle;
           Shell_NotifyIcon(NIM_MODIFY,@fic);
        end;
     end;
   except
   end;
end;

{**************************************************}

procedure TTrayIcon.SetHint(Value: string);
begin
  FHint := Value;
  with FIc do
    StrPLCopy(szTip, GetShortHint(FHint), SizeOf(szTip) - 1);
  if FActive then
    Shell_NotifyIcon(NIM_MODIFY, @fic);
end;

{**************************************************}

procedure TTrayIcon.SetIcon(Icon: TIcon);
begin
  FIcon.Assign(ICon);
  with FIc do
    hIcon := FIcon.Handle;
  if FActive then
    Shell_NotifyIcon(NIM_ADD, @fic);
//    Shell_NotifyIcon(NIM_MODIFY, @fic);
end;

{**************************************************}

procedure TTrayIcon.SetActive(Value: Boolean);
begin
  FActive := Value;
  if not (csDesigning in ComponentState) then
  begin
    if Value then
    begin
      FHandle := AllocateHWnd(WndProc);
      if FIcon = nil then
        FIcon.Assign(Application.Icon);
      with FIc do
      begin
        cbSize := SizeOf(FIc);
        Wnd := FHandle;
        Uid := 1;
        uCallBackMessage := WM_CALLBACKMESSAGE;
        if FIcon <> nil then
          hicon := Ficon.Handle
        else
          FIcon := Application.Icon;
        StrPLCopy(szTip, GetShortHint(FHint), SizeOf(szTip) - 1);
        uflags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
      end;
      FTimer.Enabled:=True;
      Shell_NotifyIcon(NIM_ADD, @FIc);
    end
    else
    begin
      Shell_NotifyIcon(NIM_DELETE, @FIc);
      FTimer.Enabled:=False;
      DeallocateHWnd(FHandle);
      FHandle:=0;
    end;
  end;
end;

{**************************************************}

procedure TTrayIcon.SetVisible(Value: Boolean);
begin
  FVisible := Value;
  if not (csDesigning in ComponentState) then
    if Value then
      ShowApplication
    else
      HideApplication;
end;

{**************************************************}

procedure TTrayIcon.HideApplication;
begin
  ShowWindow(Application.Handle, SW_HIDE);
end;

{**************************************************}

procedure TTrayIcon.ShowApplication;
begin
  ShowWindow(Application.Handle, SW_SHOW);
end;

{**************************************************}

procedure TTrayIcon.OnAnimate(Sender: TObject);
var
  ico: TIcon;
begin
  if (FImglist <> nil) and (FImgList.Count > 0) and FActive then
  begin
    ico := TIcon.Create;
    FNumber := (FNumber + 1) mod FimgList.Count;
    FImgList.GetIcon(FNumber, ico);
    SetIcon(ico);
    ico.Free;
  end;
end;

{**************************************************}

procedure TTrayIcon.SetAnimated(const Value: Boolean);
begin
  FAnimated := Value;
  if not (csDesigning in ComponentState) then
    FTimer.Enabled := FAnimated;
end;

{**************************************************}

procedure TTrayIcon.SetDelay(const Value: Cardinal);
begin
  FDelay := Value;
  FTimer.Interval := FDelay;
end;

{**************************************************}

procedure TTrayIcon.SetImgList(const Value: TImageList);
begin
  FImgList := Value;
end;

end.
