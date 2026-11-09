unit GeckoBrowser;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, nsConsts, nsXPCOM,
  nsGeckoStrings, BrowserSupports, CallbackInterfaces, nsTypes;

const
  LOAD_FLAGS_NONE = 0;
  LOAD_FLAGS_IS_REFRESH = 16;
  LOAD_FLAGS_IS_LINK = 32;
  LOAD_FLAGS_BYPASS_HISTORY = 64;
  LOAD_FLAGS_REPLACE_HISTORY = 128;
  LOAD_FLAGS_BYPASS_CACHE = 256;
  LOAD_FLAGS_BYPASS_PROXY = 512;
  LOAD_FLAGS_CHARSET_CHANGE = 1024;

type
  TCtxMenuInfo = BrowserSupports.TCtxMenuInfo;
  TCtxMenuFlags = BrowserSupports.TCtxMenuFlags;

  TGeckoBrowser = class;

  TGeckoBrowserContextMenu = procedure (Sender: TObject; aInfo: TCtxMenuInfo) of object;
  TGeckoBrowserStatusChange = procedure (Sender: TObject; aMessage: WideString) of object;
  TGeckoBrowserNewWindow = procedure (Sender: TObject; aChromeFlags: Longword; var newWindow: TGeckoBrowser) of object;
  TGeckoBrowserProgressChange = procedure (Sender: TObject; Progress: Integer; ProgressMax: Integer) of object;
  TGeckoBrowserTitleChange = procedure (Sender: TObject; const Text: WideString) of object;
  TGeckoBrowserVisibleChange = procedure (Sender: TObject; Vislble: Bool) of object;
  TGeckoBrowserLocationChange = procedure (Sender: TObject; const uri: AnsiString) of object;

  TGeckoBrowserHisoty = record
    URI: AnsiString;
    Title: WideString;
    IsSubFrame: Boolean;
  end;

  TGeckoBrowser = class(TCustomControl,
                        IGeckoCreateWindowTarget,
                        nsIWebBrowserChrome,
                        nsIEmbeddingSiteWindow,
                        nsIInterfaceRequestor,
                        nsIWeakReference,
                        nsISupportsWeakReference,
                        nsIWebBrowserChromeFocus,
                        nsIContextMenuListener2,
                        nsIWebProgressListener,
                        nsISHistoryListener)
  private
    { Private 宣言 }
    FWebBrowser: nsIWebBrowser;
    FDocTitle: WideString;

    // イベント
    FOnContextMenu: TGeckoBrowserContextMenu;
    FOnStatusChange: TGeckoBrowserStatusChange;
    FOnNewWindow: TGeckoBrowserNewWindow;
    FOnProgressChange: TGeckoBrowserProgressChange;
    FOnTitleChange: TGeckoBrowserTitleChange;
    FOnVisibleChange: TGeckoBrowserVisibleChange;
    FOnLocationChange: TGeckoBrowserLocationChange;

    function InitWebBrowser: Boolean;
    procedure ShutdownWebBrowser;

    // IGeckoCreateWindowTarget
    function DoCreateChromeWindow(chromeFlags: Longword; out newChrome: nsIWebBrowserChrome): Longword;
    function GetWebBrowserChrome: nsIWebBrowserChrome;

    // nsIWebBrowserChrome
    function SetStatus(statusType: Longword; const status: PWideChar): Longword; stdcall;
    function GetWebBrowser(out aWebBrowser: nsIWebBrowser): Longword; stdcall;
    function SetWebBrowser(aWebBrowser: nsIWebBrowser): Longword; stdcall;
    function GetChromeFlags(out aChromeFlags: Longword): Longword; stdcall;
    function SetChromeFlags(aChromeFlags: Longword): Longword; stdcall;
    function DestroyBrowserWindow(): Longword; stdcall;
    function SizeBrowserTo(aCX: Longint; aCY: Longint): Longword; stdcall;
    function ShowAsModal(): Longword; stdcall;
    function IsWindowModal(out _retval: LongBool): Longword; stdcall;
    function ExitModalEventLoop(aStatus: nsresult): Longword; stdcall;
    // nsIEmbeddingSiteWindow
    function SetDimensions(flags: Longword; x, y, cx, cy: Longint): Longword; stdcall;
    function GetDimensions(flags: Longword; out x, y, cx, cy: Longint): Longword; stdcall;
    function SetFocus: Longword; reintroduce; stdcall;
    function GetVisibility(out Value: LongBool): Longword; stdcall;
    function SetVisibility(Value: LongBool): Longword; stdcall;
    function GetTitle(out Value: PWideChar): Longword; stdcall;
    function SetTitle(const Value: PWideChar): Longword; stdcall;
    function GetSiteWindow(out Value: Pointer): Longword; stdcall;
    // nsIInterfaceRequestor
    function GetInterface(const uuid: TGUID; out Intf): Longword; stdcall;
    // nsIContextMenuListner2
    function OnShowContextMenu(aContextFlags: Longword; aUtils: nsIContextMenuInfo): Longword; stdcall;

    // for nsIWeakReference
    function QueryReferent(const IID: TGUID; out Obj): Longword; stdcall;
    // for nsISupportsWeakReference
    function GetWeakReference(out _Retval: nsIWeakReference): Longword; stdcall;
    // for nsIWebBrowserChromeFocus
    function FocusNextElement(): Longword; stdcall;
    function FocusPrevElement(): Longword; stdcall;

    // nsIWebProgressListener
    function OnStateChange(aWebProgress: nsIWebProgress; aRequest: nsIRequest; aStateFlags: Longword; aStatus: nsresult): Longword; stdcall;
    function nsIWebProgressListener.OnProgressChange = OnProgressChangeListener;
    function nsIWebProgressListener.OnLocationChange = OnLocationChangeListener;
    function OnStatusChange(aWebProgress: nsIWebProgress; aRequest: nsIRequest; aStatus: nsresult; const aMessage: PWideChar): Longword; stdcall;
    function OnSecurityChange(aWebProgress: nsIWebProgress; aRequest: nsIRequest; state: Longword): Longword; stdcall;
    function OnProgressChangeListener(aWebProgress: nsIWebProgress; aRequest: nsIRequest; aCurSelfProgress: Longint; aMaxSelfProgress: Longint; aCurTotalProgress: Longint; aMaxTotalProgress: Longint): Longword; stdcall;
    function OnLocationChangeListener(aWebProgress: nsIWebProgress; aRequest: nsIRequest; location: nsIURI): Longword; stdcall;
    // nsISHistoryListener
    function OnHistoryNewEntry(aNewURI: nsIURI): Longword; stdcall;
    function OnHistoryGoBack(aBackURI: nsIURI; out aContinue: LongBool): Longword; stdcall;
    function OnHistoryGoForward(aForwardURI: nsIURI; out aContinue: LongBool): Longword; stdcall;
    function OnHistoryReload(aReloadURI: nsIURI; aReloadFlags: Longword; out aContinue: LongBool): Longword; stdcall;
    function OnHistoryGotoIndex(aIndex: Longint; aGotoURI: nsIURI; out aContinue: LongBool): Longword; stdcall;
    function OnHistoryPurge(aNumEntries: Longint; out aContinue: LongBool): Longword; stdcall;

    procedure WMKeyDown(var Msg: TMessage); message CN_KEYDOWN;
    procedure WMKeyUp(var Msg: TMessage); message CN_KEYUP;
    procedure WMChar(var Msg: TMessage); message CN_CHAR;

    function GetHistoryEntry(index: Integer): TGeckoBrowserHisoty;
    function GetHistoryPosition: Integer;
    function GetHistoryCount: Integer;
    function GetCanGoBack: Boolean;
    function GetCanGoForward: Boolean;
  protected
    { Protected 宣言 }
    // TControl
    procedure Resize; override;

    // TWinControl
    procedure CreateWnd; override;
    procedure DestroyWnd; override;

  public
    { Public 宣言 }
    // 生成･消滅
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // ナビゲーション
    // nsIWebNavigation
    procedure LoadURI(uri: WideString;
                      loadFlags: Cardinal = LOAD_FLAGS_NONE;
                      referer: String = '';
                      postData: String = '';
                      headers: String = '');
    procedure GoBack;
    procedure GoForward;
    procedure GotoIndex(aIndex: Integer);
    procedure Reload(reloadFlags: Cardinal = LOAD_FLAGS_NONE);

    property HistoryEntry[index: Integer]: TGeckoBrowserHisoty read GetHistoryEntry;
    property HistoryPosition: Integer read GetHistoryPosition;
    property HistoryCount: Integer read GetHistoryCount;
    property CanGoBack: Boolean read GetCanGoBack;
    property CanGoForward: Boolean read GetCanGoForward;
  published
    { Published 宣言 }
    // TWinControl
    property Align;
    property TabOrder;
    property TabStop default True;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BevelWidth;
    //property BorderWidth;

    property OnCanResize;
    //property OnCanMove;

    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;

    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;

    property OnContextMenu: TGeckoBrowserContextMenu read FOnContextMenu write FOnContextMenu;
    property OnStatusTextChange: TGeckoBrowserStatusChange read FOnStatusChange write FOnStatusChange;
    property OnNewWindow: TGeckoBrowserNewWindow read FOnNewWindow write FOnNewWindow;
    property OnProgressChange: TGeckoBrowserProgressChange read FOnProgressChange write FOnProgressChange;
    property OnTitleChange: TGeckoBrowserTitleChange read FOnTitleChange write FOnTitleChange;
    property OnVisible: TGeckoBrowserVisibleChange read FOnVisibleChange write FOnVisibleChange;
    property OnLocationChange: TGeckoBrowserLocationChange read FOnLocationChange write FOnLocationChange;
  end;

procedure Register;

implementation

uses
  nsXPCOMGlue, nsError, nsStream, nsMemory, nsUtil, nsNetUtil,
  Forms;

procedure Register;
begin
  RegisterComponents('Gecko', [TGeckoBrowser]);
end;

constructor TGeckoBrowser.Create(AOwner: TComponent);
var
  rv: Longword;
begin
  inherited Create(AOwner);

  {$IFDEF DEBUG}
  OutputDebugString('TGeckoBrowser.Create');
  {$ENDIF}
  if not (csDesigning in ComponentState) then
  begin
    rv := GRE_Startup;
    if NS_FAILED(rv) then
      raise Exception.Create('Error: GRE_Startup()');
    AddCreateWindowTarget(Self);

  end;
end;

destructor TGeckoBrowser.Destroy;
begin
  {$IFDEF DEBUG}
  OutputDebugString('TGeckoBrowser.Destroy');
  {$ENDIF}
  if not (csDesigning in ComponentState) then
  begin
    RemoveCreateWindowTarget(Self);
    ShutdownWebBrowser;
  end;

  inherited Destroy;
end;

// nsIWebBrowserChrome
function TGeckoBrowser.SetStatus(statusType: Longword; const status: PWideChar): Longword;
begin
  {$IFDEF DEBUG}
  OutputDebugString(PChar(
    'GeckoBrowser.SetStatus('+status+')'
  ));
  {$ENDIF}
  if Assigned(FOnStatusChange) then
    FOnStatusChange(Self, status);
  Result := NS_OK;
end;

function TGeckoBrowser.GetWebBrowser(out aWebBrowser: nsIWebBrowser): Longword;
begin
  if @aWebBrowser = nil then
    Result := NS_ERROR_NULL_POINTER
  else
  begin
    Result := NS_OK;
    aWebBrowser := FWebBrowser;
  end;
end;

function TGeckoBrowser.SetWebBrowser(aWebBrowser: nsIWebBrowser): Longword;
begin
  Result := NS_OK;
  FWebBrowser := aWebBrowser;
end;

function TGeckoBrowser.GetChromeFlags(out aChromeFlags: Longword): Longword;
begin
  Result := NS_ERROR_NOT_IMPLEMENTED;
end;

function TGeckoBrowser.SetChromeFlags(aChromeFlags: Longword): Longword;
begin
  Result := NS_ERROR_NOT_IMPLEMENTED;
end;

function TGeckoBrowser.DestroyBrowserWindow: Longword;
begin
  Result := NS_ERROR_NOT_IMPLEMENTED;
end;

function TGeckoBrowser.SizeBrowserTo(aCX: Longint; aCY: Longint): Longword;
begin
  Result := NS_ERROR_NOT_IMPLEMENTED;
end;

function TGeckoBrowser.ShowAsModal: Longword;
begin
  Result := NS_ERROR_NOT_IMPLEMENTED;
end;

function TGeckoBrowser.IsWindowModal(out _retval: LongBool): Longword;
begin
  Result := NS_ERROR_NOT_IMPLEMENTED;
end;

function TGeckoBrowser.ExitModalEventLoop(aStatus: Longword): Longword;
begin
  Result := NS_ERROR_NOT_IMPLEMENTED;
end;

// nsIEmbeddingSiteWindow
function TGeckoBrowser.SetDimensions(flags: Longword; x, y, cx, cy: Longint): Longword;
const
  FLAGS_POSITION   = ns_IEmbeddingSiteWindow_DIM_FLAGS_POSITION;
  FLAGS_SIZE_INNER = ns_IEmbeddingSiteWindow_DIM_FLAGS_SIZE_INNER;
  FLAGS_SIZE_OUTER = ns_IEmbeddingSiteWindow_DIM_FLAGS_SIZE_OUTER;
begin
  if (flags and FLAGS_POSITION)<>0 then
  begin
    if (flags and FLAGS_SIZE_INNER)<>0 then
    begin
      Left := x;
      Top := y;
      ClientWidth := cx;
      ClientHeight := cy;
    end else
    if (flags and FLAGS_SIZE_OUTER)<>0 then
    begin
      Bounds(x, y, cx, cy);
    end else
    begin
      Bounds(x, y, Width, Height);
    end;
  end else
  if (flags and FLAGS_SIZE_INNER)<>0 then
  begin
    ClientWidth := cx;
    ClientHeight := cy;
  end else
  if (flags and FLAGS_SIZE_OUTER)<>0 then
  begin
    Bounds(Left, Top, cx, cy);
  end;
  Result := NS_OK;
end;

function TGeckoBrowser.GetDimensions(flags: Longword; out x, y, cx, cy: Longint): Longword;
const
  FLAGS_POSITION   = ns_IEmbeddingSiteWindow_DIM_FLAGS_POSITION;
  FLAGS_SIZE_INNER = ns_IEmbeddingSiteWindow_DIM_FLAGS_SIZE_INNER;
  FLAGS_SIZE_OUTER = ns_IEmbeddingSiteWindow_DIM_FLAGS_SIZE_OUTER;
begin
  if (flags and FLAGS_POSITION)<>0 then
  begin
    if (@x = nil) or (@y = nil) then
    begin
      Result := NS_ERROR_INVALID_ARG;
      Exit;
    end;
    x := Left;
    y := Top;
  end;

  if (flags and FLAGS_SIZE_INNER)<>0 then
  begin
    if (@cx = nil) or (@cy = nil) then
    begin
      Result := NS_ERROR_INVALID_ARG;
      Exit;
    end;
    cx := ClientWidth;
    cy := ClientHeight;
  end else
  if (flags and FLAGS_SIZE_OUTER)<>0 then
  begin
    if (@cx = nil) or (@cy = nil) then
    begin
      Result := NS_ERROR_INVALID_ARG;
      Exit;
    end;
    cx := Width;
    cy := Height;
  end;
  Result := NS_OK;
end;

function TGeckoBrowser.SetFocus: Longword;
begin
  Windows.SetFocus(Handle);
  Result := NS_OK;
end;

function TGeckoBrowser.GetVisibility(out Value: LongBool): Longword;
begin
  if @Value = nil then
    Result := NS_ERROR_INVALID_ARG
  else
  begin
    Value := Visible;
    Result := NS_OK;
  end;
end;

function TGeckoBrowser.SetVisibility(Value: LongBool): Longword;
begin
  if Assigned(FOnVisibleChange) then
    FOnVisibleChange(Self, Value);
  Result := NS_OK;
end;

function TGeckoBrowser.GetTitle(out Value: PWideChar): Longword;
begin
  if @Value = nil then
    Result := NS_ERROR_INVALID_ARG
  else
  begin
    Result := NS_OK;
    Value := PWideChar(FDocTitle);
  end;
end;

function TGeckoBrowser.SetTitle(const Value: PWideChar): Longword;
begin
  Result := NS_OK;
  FDocTitle := Value;
  if Assigned(FOnTitleChange) then
    FOnTitleChange(Self, FDocTitle);
end;

function TGeckoBrowser.GetSiteWindow(out Value: Pointer): Longword;
begin
  if @Value = nil then
    Result := NS_ERROR_INVALID_ARG
  else
  begin
    Value := Pointer(Handle);
    Result := NS_OK;
  end;
end;

// nsIInterfaceRequestor
function TGeckoBrowser.GetInterface(const uuid: TGUID; out Intf): Longword;
var
  domwin: nsIDOMWindow;
begin
  if @Intf = nil then
  begin
    Result := NS_ERROR_INVALID_ARG;
    Exit;
  end;
  if IsEqualGUID(uuid, nsIDOMWindow) then
  begin
    if Assigned(FWebBrowser) then
    begin
      Result := FWebBrowser.GetContentDOMWindow(domwin);
      if NS_SUCCEEDED(Result) then
        Result := domwin.QueryInterface(nsIDOMWindow, Intf);
    end else
      Result := NS_ERROR_NOT_INITIALIZED;
  end else
    Result := QueryInterface(uuid, Intf);
end;

// nsIContextMenuListner2
function TGeckoBrowser.OnShowContextMenu(aContextFlags: Longword; aUtils: nsIContextMenuInfo): Longword;
var
  info: TCtxMenuInfo;
begin
  if Assigned(FOnContextMenu) then
  begin
    info := TCtxMenuInfo.Create(aContextFlags, aUtils);
    try
      FOnContextMenu(self, info);
    finally
      info.Free;
    end;
  end;
  Result := NS_OK;
end;

// for nsIWeakReference
function TGeckoBrowser.QueryReferent(const IID: TGUID; out obj): Longword;
begin
  Result := QueryInterface(IID, Obj);
end;

// for nsISupportsWeakReference
function TGeckoBrowser.GetWeakReference(out _Retval: nsIWeakReference): Longword;
begin
  if @_RetVal = nil then
    Result := NS_ERROR_INVALID_ARG
  else
  begin
    Result := NS_OK;
    _Retval := Self;
  end;
end;

// for nsIWebBrowserChromeFocus
function TGeckoBrowser.FocusNextElement: Longword;
var
  parent: TWinControl;
  next: TWinControl;
  focus: nsIWebBrowserFocus;
begin
  Result := NS_OK;
  parent := Self.Parent;
  while not (parent is TForm) do parent := parent.Parent;

  next := TGeckoBrowser(Parent).FindNextControl(Self, False, True, False);
  if Assigned(next) and Supports(FWebBrowser, nsIWebBrowserFocus, focus) then
  begin
    //focus.Deactivate;
    next.SetFocus;
  end;
end;

function TGeckoBrowser.FocusPrevElement: Longword;
var
  parent: TWinControl;
  prev: TWinControl;
  focus: nsIWebBrowserFocus;
begin
  parent := Self.Parent;
  while not (parent is TForm) do parent := parent.Parent;

  prev := TGeckoBrowser(Parent).FindNextControl(Self, True, True, False);
  if Assigned(prev) and Supports(FWebBrowser, nsIWebBrowserFocus, focus) then
  begin
    //focus.Deactivate;
    prev.SetFocus;
  end;
  Result := NS_OK;
end;

// nsIWebProgressListener
// nsIWebProgressListener.OnStateChange
function TGeckoBrowser.OnStateChange(aWebProgress: nsIWebProgress;
                                     aRequest: nsIRequest;
                                     aStateFlags: Longword;
                                     aStatus: Longword): Longword;
{$IFDEF DEBUG}
var
  uri: nsIURI;
  str: IInterfacedCString;
  channel: nsIChannel;
{$ENDIF}
begin
  Result := NS_OK;
  if (aStateFlags and NS_IWEBPROGRESSLISTENER_STATE_IS_DOCUMENT)<>0 then
  begin
    // 状態の変化はドキュメントに対してである
    if (aStateFlags and NS_IWEBPROGRESSLISTENER_STATE_START)<>0 then
    begin
      // ドキュメントの読み込みが開始された
      {$IFDEF DEBUG}
      OutputDebugString('GeckoBrowser.OnDocumentBegin');
      {$ENDIF}
    end else
    if (aStateFlags and NS_IWEBPROGRESSLISTENER_STATE_STOP)<>0 then
    begin
      // ドキュメントの読み込みが完了した
      {$IFDEF DEBUG}
      OutputDebugString('GeckoBrowser.OnDocumentComplete');
      {$ENDIF}
    end;
  end;
  if (aStateFlags and NS_IWEBPROGRESSLISTENER_STATE_IS_NETWORK)<>0 then
  begin
    // 状態の変化はネットワークに対してである
    if (aStateFlags and NS_IWEBPROGRESSLISTENER_STATE_START)<>0 then
    begin
      {$IFDEF DEBUG}
      try
        str := NewCString;
        channel := aRequest as nsIChannel;
        channel.GetURI(uri);
        uri.GetSpec(str.ACString);
        OutputDebugString(
          PChar('GeckoBrowser.OnDownloadBegin('+str.ToString+')'));
      except
      end;
      {$ENDIF}
    end else
    if (aStateFlags and NS_IWEBPROGRESSLISTENER_STATE_STOP)<>0 then
    begin
      {$IFDEF DEBUG}
      try
        str := NewCString;
        channel := aRequest as nsIChannel;
        channel.GetURI(uri);
        uri.GetSpec(str.ACString);
        OutputDebugString(
          PChar('GeckoBrowser.OnDownloadComplete('+str.ToString+')'));
      except
      end;
      {$ENDIF}
      if Assigned(FOnStatusChange) then
        FOnStatusChange(Self, '');
    end;
  end;
end;

// nsIWebProgressListener.OnProgressChange
function TGeckoBrowser.OnProgressChangeListener(aWebProgress: nsIWebProgress;
                                        aRequest: nsIRequest;
                                        aCurSelfProgress: Longint;
                                        aMaxSelfProgress: Longint;
                                        aCurTotalProgress: Longint;
                                        aMaxTotalProgress: Longint): Longword;
begin
  Result := NS_OK;
  if Assigned(FOnProgressChange) then
  begin
    {$IFDEF DEBUG}
    OutputDebugString(PChar(
      'OnProgressListener('+IntToStr(aCurTotalProgress)+'/'+IntToStr(aMaxTotalProgress)+')'
    ));
    {$ENDIF}
    FOnProgressChange(Self, aCurTotalProgress, aMaxTotalProgress);
  end;
end;

function TGeckoBrowser.OnLocationChangeListener(aWebProgress: nsIWebProgress;
                                        aRequest: nsIRequest;
                                        location: nsIURI): Longword;
var
  str: IInterfacedCString;
  rv: nsresult;
begin
  Result := NS_OK;
  try
    str := NewCString;
  except
    Exit;
  end;
  rv := location.GetSpec(str.ACString);
  if NS_FAILED(rv) then Exit;
  {$IFDEF DEBUG}
  OutputDebugString(PChar(
    'GeckoBrowser.LocationChange('+str.ToString+')'
  ));
  {$ENDIF}
  if Assigned(FOnLocationChange) then
    FOnLocationChange(Self, str.ToString);
end;

function TGeckoBrowser.OnStatusChange(aWebProgress: nsIWebProgress;
                                      aRequest: nsIRequest;
                                      aStatus: Longword;
                                      const aMessage: PWideChar): Longword;
begin
  {$IFDEF DEBUG}
  OutputDebugString(PChar(
    'GeckoBrowser.OnStatusChange('+aMessage+')'
  ));
  {$ENDIF}
  if Assigned(FOnStatusChange) then
    FOnStatusChange(Self, aMessage);
  Result := NS_OK;
end;

function TGeckoBrowser.OnSecurityChange(aWebProgress: nsIWebProgress;
                                        aRequest: nsIRequest;
                                        state: Longword): Longword;
begin
  Result := NS_ERROR_NOT_IMPLEMENTED;
end;

// nsISHistoryListener
function TGeckoBrowser.OnHistoryNewEntry(aNewURI: nsIURI): Longword;
begin
  Result := NS_OK;
end;

function TGeckoBrowser.OnHistoryGoBack(aBackURI: nsIURI; out aContinue: LongBool): Longword;
begin
  if @aContinue = nil then
  begin
    Result := NS_ERROR_FAILURE;
    Exit;
  end;
  
  if (HistoryPosition>0) then
    aContinue := True
  else
    aContinue := False;
  Result := NS_OK;
end;

function TGeckoBrowser.OnHistoryGoForward(aForwardURI: nsIURI; out aContinue: LongBool): Longword;
begin
  if @aContinue = nil then
  begin
    Result := NS_ERROR_FAILURE;
    Exit;
  end;

  if (HistoryPosition+1)<HistoryCount then
    aContinue := True
  else
    aContinue := False;

  Result := NS_OK;
end;

function TGeckoBrowser.OnHistoryReload(aReloadURI: nsIURI; aReloadFlags: Longword; out aContinue: LongBool): Longword;
begin
  if @aContinue = nil then
  begin
    Result := NS_ERROR_FAILURE;
    Exit;
  end;

  aContinue := True;
  Result := NS_OK;
end;

function TGeckoBrowser.OnHistoryGotoIndex(aIndex: Longint; aGotoURI: nsIURI; out aContinue: LongBool): Longword;
begin
  if @aContinue = nil then
  begin
    Result := NS_ERROR_FAILURE;
    Exit;
  end;

  if aIndex in [0..HistoryCount-1] then
    aContinue := True
  else
    aContinue := False;

  Result := NS_OK;
end;

function TGeckoBrowser.OnHistoryPurge(aNumEntries: Longint; out aContinue: LongBool): Longword;
begin
  if @aContinue = nil then
  begin
    Result := NS_ERROR_FAILURE;
    Exit;
  end;

  aContinue := False;
  Result := NS_OK;
end;

procedure TGeckoBrowser.WMKeyDown(var Msg: TMessage);
var
  key: TWMKeyDown;
begin
  key := TWMKeyDown(Msg);
  // タブのみ乗っ取る
  if key.CharCode <> 9 then
    inherited;
end;

procedure TGeckoBrowser.WMKeyUp(var Msg: TMessage);
begin
  // WM_KEYDOWN で処理されてしまうため特に乗っ取る必要はない
  inherited;
end;

procedure TGeckoBrowser.WMChar(var Msg: TMessage);
begin
  // 完全に乗っ取る
  //inherited;
end;

// TControl 継承
procedure TGeckoBrowser.Resize;
var
  BaseWindow: nsIBaseWindow;
  rc: TRect;
begin
  inherited Resize;

  if not Assigned(FWebBrowser) then Exit;
  BaseWindow := FWebBrowser as nsIBaseWindow;
  rc := ClientRect;
  BaseWindow.SetPositionAndSize(rc.Left, rc.Top, rc.Right-rc.left, rc.Bottom-rc.Top, False);
end;

// TWinControl 継承
procedure TGeckoBrowser.CreateWnd;
begin
  {$IFDEF DEBUG}
  OutputDebugString('TGeckoBrowser.CreateWnd');
  {$ENDIF}
  inherited CreateWnd;

  if not (csDesigning in ComponentState) then
  begin
    if not InitWebBrowser then
      raise Exception.Create('Error: InitWebBrowser');
  end;
end;

procedure TGeckoBrowser.DestroyWnd;
begin
  inherited DestroyWnd;
  {$IFDEF DEBUG}
  OutputDebugString('TGeckoBrowser.DestroyWnd');
  {$ENDIF}
end;

function TGeckoBrowser.InitWebBrowser: Boolean;
var
  baseWin: nsIBaseWindow;
  focus: nsIWebBrowserFocus;
  rc: TRect;
begin
  Result := False;

  // WindowCreatorの初期化
  if not InitWindowCreator then Exit;

  // ブラウザオブジェクトの初期化
  if NS_FAILED(NS_CreateInstance(NS_WEBBROWSER_CID, nsIWebBrowser, FWebBrowser)) then Exit;

  // ブラウザウィンドウの初期化
  if NS_FAILED(FWebBrowser.SetContainerWindow(Self)) then Exit;
  if not Supports(FWebBrowser, nsIBaseWindow, baseWin) then Exit;
  rc := ClientRect;
  if NS_FAILED(baseWin.InitWindow(Handle,
                                  nil,
                                  rc.Left,
                                  rc.Top,
                                  rc.Right-rc.Left,
                                  rc.Bottom-rc.Top)) then
    Exit;
  if NS_FAILED(baseWin.Create) then Exit;

  // Listener の登録
  if NS_FAILED(FWebBrowser.AddWebBrowserListener(Self, nsIWebProgressListener)) then Exit;
  if NS_FAILED(FWebBrowser.AddWebBrowserListener(Self, nsISHistoryListener)) then Exit;

  // ブラウザの可視化
  if NS_FAILED(baseWin.SetVisibility(True)) then Exit;
  // フォーカス
  if not Supports(FWebBrowser, nsIWebBrowserFocus, focus) then Exit;
  if NS_FAILED(focus.Activate) then Exit;

  Result := True;
end;

procedure TGeckoBrowser.ShutdownWebBrowser;
begin
  if Assigned(FWebBrowser) then
  begin
    FWebBrowser.RemoveWebBrowserListener(Self, nsIWebProgressListener);
    FWebBrowser.RemoveWebBrowserListener(Self, nsISHistoryListener);
    FWebBrowser.SetContainerWindow(nil);
    FWebBrowser := nil;
  end;
end;

// ナビゲーション
// nsIWebNavigation
procedure TGeckoBrowser.LoadURI(uri: WideString; loadFlags: Cardinal;
                                referer: String;
                                postData: String;
                                headers: String);
var
  webNavigation: nsIWebNavigation;
  refererURI: nsIURI;
  postPtr, headPtr: Pointer;
  postLen, headLen: Longword;
  postStream, headStream: nsIInputStream;
begin
  {$IFDEF DEBUG}
  OutputDebugString('TGeckoBrowser.LoadURI');
  {$ENDIF}

  if not Supports(FWebBrowser, nsIWebNavigation, webNavigation) then Exit;

  if Length(referer)>0 then
  begin
    NS_NewURI(refererURI,referer);
  end;

  postLen := Length(postData);
  if postLen>0 then
  begin
    postPtr := nsMemory.Alloc(postLen);
    if Assigned(postPtr) then
    begin
      NS_MEMCPY(postPtr, PChar(postData), postLen);
      NS_NewByteArrayInputStream(postStream, postPtr, postLen);
    end;
  end;

  headLen := Length(headers);
  if headLen>0 then
  begin
    headPtr := nsMemory.Alloc(headLen);
    if Assigned(headPtr) then
    begin
      NS_MEMCPY(headPtr, PChar(headers), headLen);
      NS_NewByteArrayInputStream(headStream, headPtr, headLen);
    end;
  end;

  webNavigation.LoadURI(PWideChar(uri), loadFlags, refererURI, postStream, headStream);
end;

procedure TGeckoBrowser.GoBack;
var
  nav: nsIWebNavigation;
begin
  if not Supports(FWebBrowser, nsIWebNavigation, nav) then Exit;

  nav.GoBack;
end;

procedure TGeckoBrowser.GoForward;
var
  nav: nsIWebNavigation;
begin
  if not Supports(FWebBrowser, nsIWebNavigation, nav) then Exit;
  nav.GoForward;
end;

procedure TGeckoBrowser.GotoIndex(aIndex: Integer);
var
  nav: nsIWebNavigation;
begin
  if not Supports(FWebBrowser, nsIWebNavigation, nav) then Exit;
  nav.GotoIndex(aIndex);
end;

procedure TGeckoBrowser.Reload(reloadFlags: Cardinal);
var
  nav: nsIWebNavigation;
begin
  if not Supports(FWebBrowser, nsIWebNavigation, nav) then Exit;
  nav.Reload(reloadFlags);
end;

// nsIWindowCreator 用
function TGeckoBrowser.DoCreateChromeWindow(chromeFlags: Longword; out newChrome: nsIWebBrowserChrome): Longword;
var
  newBrowser: TGeckoBrowser;
begin
  if @newChrome = nil then
  begin
    Result := NS_ERROR_INVALID_ARG;
    Exit;
  end;

  Result := NS_ERROR_FAILURE;
  if Assigned(FOnNewWindow) then
  begin
    newBrowser := nil;
    FOnNewWindow(Self, chromeFlags, newBrowser);
    if Assigned(newBrowser) then
      Result := newBrowser.QueryInterface(nsIWebBrowserChrome, newChrome);
  end;
end;

function TGeckoBrowser.GetWebBrowserChrome: nsIWebBrowserChrome;
begin
  Result := Self;
end;

function TGeckoBrowser.GetHistoryEntry(index: Integer): TGeckoBrowserHisoty;
var
  rv: Cardinal;
  nav: nsIWebNavigation;
  history: nsISHistory;
  entry: nsIHistoryEntry;
  str: IInterfacedCString;
  wstr: PWideChar;
  uri: nsIURI;
  bool: LongBool;
begin
  Result.URI := '';
  Result.Title := '';
  Result.IsSubFrame := False;

  rv := FWebBrowser.QueryInterface(nsIWebNavigation, nav);
  if NS_FAILED(rv) then Exit;

  rv := nav.GetSessionHistory(history);
  if NS_FAILED(rv) then Exit;

  rv := history.GetEntryAtIndex(index, False, entry);
  if NS_FAILED(rv) then Exit;

  rv := entry.GetURI(uri);
  if NS_FAILED(rv) then Exit;

  str := NewCString;
  rv := uri.GetSpec(str.ACString);
  if NS_FAILED(rv) then Exit;

  rv := entry.GetTitle(wstr);
  if NS_FAILED(rv) then Exit;

  rv := entry.GetIsSubFrame(bool);
  if NS_FAILED(rv) then Exit;

  Result.URI := str.ToString;
  Result.Title := WideString(wstr);
  Result.IsSubFrame := bool;

  nsMemory.Free(wstr);
end;

function TGeckoBrowser.GetHistoryPosition: Integer;
var
  nav: nsIWebNavigation;
  history: nsISHistory;
begin
  Result := -1;
  if NS_FAILED(FWebBrowser.QueryInterface(nsIWebNavigation, nav)) then Exit;
  if NS_FAILED(nav.GetSessionHistory(history)) then Exit;
  history.GetIndex(Result);
end;

function TGeckoBrowser.GetHistoryCount: Integer;
var
  nav: nsIWebNavigation;
  history: nsISHistory;
begin
  Result := 0;
  if NS_FAILED(FWebBrowser.QueryInterface(nsIWebNavigation, nav)) then Exit;
  if NS_FAILED(nav.GetSessionHistory(history)) then Exit;
  history.GetCount(Result);
end;

function TGeckoBrowser.GetCanGoBack: Boolean;
var
  nav: nsIWebNavigation;
  history: nsISHistory;
  index: Integer;
begin
  Result := False;
  if NS_FAILED(FWebBrowser.QueryInterface(nsIWebNavigation, nav)) then Exit;
  if NS_FAILED(nav.GetSessionHistory(history)) then Exit;
  if NS_FAILED(history.GetIndex(index)) then Exit;

  if index>0 then Result := True;
end;

function TGeckoBrowser.GetCanGoForward: Boolean;
var
  nav: nsIWebNavigation;
  history: nsISHistory;
  index, count: Integer;
begin
  Result := False;
  if NS_FAILED(FWebBrowser.QueryInterface(nsIWebNavigation, nav)) then Exit;
  if NS_FAILED(nav.GetSessionHistory(history)) then Exit;
  if NS_FAILED(history.GetCount(count)) then Exit;
  if NS_FAILED(history.GetIndex(index)) then Exit;

  if index+1<count then Result := True;
end;

end.

