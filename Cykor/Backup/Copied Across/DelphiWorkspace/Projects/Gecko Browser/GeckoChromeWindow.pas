unit GeckoChromeWindow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CallbackInterfaces, nsXPCOM, nsTypes;

type
  TGeckoChromeForm = class(TForm,
                           IGeckoCreateWindowTarget,
                           nsIWebBrowserChrome,
                           nsIEmbeddingSiteWindow,
                           nsIWebProgressListener,
                           nsIInterfaceRequestor,
                           nsIWeakReference,
                           nsISupportsWeakReference)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private êÈåæ }
    FWebBrowser: nsIWebBrowser;
    FChromeFlags: Longword;

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
    // nsIWebProgressListener
    function OnStateChange(aWebProgress: nsIWebProgress; aRequest: nsIRequest; aStateFlags: PRUint32; aStatus: nsresult): nsresult; stdcall;
    function OnProgressChange(aWebProgress: nsIWebProgress; aRequest: nsIRequest; aCurSelfProgress: PRInt32; aMaxSelfProgress: PRInt32; aCurTotalProgress: PRInt32; aMaxTotalProgress: PRInt32): nsresult; stdcall;
    function OnLocationChange(aWebProgress: nsIWebProgress; aRequest: nsIRequest; location: nsIURI): nsresult; stdcall;
    function OnStatusChange(aWebProgress: nsIWebProgress; aRequest: nsIRequest; aStatus: nsresult; const aMessage: PWideChar): nsresult; stdcall;
    function OnSecurityChange(aWebProgress: nsIWebProgress; aRequest: nsIRequest; state: PRUint32): nsresult; stdcall;
    // nsIInterfaceRequestor
    function GetInterface(const uuid: TGUID; out Intf): Longword; stdcall;
    // for nsIWeakReference
    function QueryReferent(const IID: TGUID; out Obj): Longword; stdcall;
    // for nsISupportsWeakReference
    function GetWeakReference(out _Retval: nsIWeakReference): Longword; stdcall;

    function InitWebBrowser: Boolean;
    procedure UpdateChrome;
    procedure ContentFinishedLoading;
  public
    { Public êÈåæ }
    constructor CreateWithChromeFlags(AOwner: TComponent; aChromeFlags: Longword);

    // IGeckoCreateWindowTarget
    function DoCreateChromeWindow(chromeFlags: Longword; out newChrome: nsIWebBrowserChrome): Longword;
    function GetWebBrowserChrome: nsIWebBrowserChrome;
  end;

var
  GeckoChromeForm: TGeckoChromeForm;

implementation

{$R *.dfm}

uses
  nsXPCOMGlue, nsError, BrowserSupports;

constructor TGeckoChromeForm.CreateWithChromeFlags(AOwner: TComponent; AChromeFlags: Longword);
begin
  inherited Create(AOwner);
  FChromeFlags := aChromeFlags;
  UpdateChrome;
end;

procedure TGeckoChromeForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

function TGeckoChromeForm.InitWebBrowser: Boolean;
var
  rv: Longword;
  base: nsIBaseWindow;
begin
  Result := False;

  rv := NS_CreateInstance(NS_WEBBROWSER_CID, nsIWebBrowser, FWebBrowser);
  if NS_FAILED(rv) then Exit;

  rv := FWebBrowser.SetContainerWindow(Self);
  if NS_FAILED(rv) then Exit;

  if not Supports(FWebBrowser, nsIBaseWindow, base) then Exit;

  rv := base.InitWindow(Handle, nil, 0, 0, ClientWidth, ClientHeight);
  if NS_FAILED(rv) then Exit;

  rv := base.Create;
  if NS_FAILED(rv) then Exit;

  if NS_FAILED(FWebBrowser.AddWebBrowserListener(Self, nsIWebProgressListener)) then Exit;

  base.SetVisibility(True);

  Result := True;
end;

procedure TGeckoChromeForm.UpdateChrome;
begin
  {if (FChromeFlags and CHROME_WINDOW_BORDERS)<>0 then
    if (FChromeFlags and CHROME_WINDOW_RESIZE)<>0 then
      BorderStyle := bsSizeable
    else
      if (FChromeFlags and CHROME_OPENAS_DIALOG)<>0 then
        BorderStyle := bsDialog
      else
        BorderStyle := bsSingle
  else
    BorderStyle := bsNone;}
  BorderStyle := bsSizeable;

  {
  if (FChromeFlags and CHROME_WINDOW_CLOSE)<>0 then
    BorderIcons := BorderIcons + [biClose]
  else
    BorderIcons := BorderIcons - [biClose];
  }

  if (FChromeFlags and CHROME_SCROLLBARS)<>0 then
    AutoScroll := True
  else
    AutoScroll := False;

  {
  if (FChromeFlags and CHROME_TITLEBAR)<>0 then
    BorderIcons := BorderIcons + [biSystemMenu]
  else
    BorderIcons := BorderIcons - [biSystemMenu];
  }

end;

function TGeckoChromeForm.DoCreateChromeWindow(chromeFlags: Longword; out newChrome: nsIWebBrowserChrome): Longword;
begin
  Result := NS_ERROR_NOT_IMPLEMENTED;
end;

function TGeckoChromeForm.GetWebBrowserChrome: nsIWebBrowserChrome;
begin
  Result := Self;
end;

function TGeckoChromeForm.SetStatus(statusType: Longword; const status: PWideChar): Longword;
begin
  Result := NS_ERROR_NOT_IMPLEMENTED;
end;

function TGeckoChromeForm.GetWebBrowser(out aWebBrowser: nsIWebBrowser): Longword;
begin
  Result := FWebBrowser.QueryInterface(nsIWebBrowser, aWebBrowser);
end;

function TGeckoChromeForm.SetWebBrowser(aWebBrowser: nsIWebBrowser): Longword;
begin
  Result := NS_ERROR_FAILURE;
end;

function TGeckoChromeForm.GetChromeFlags(out aChromeFlags: Longword): Longword;
begin
  aChromeFlags := FChromeFlags;
  Result := NS_OK;
end;

function TGeckoChromeForm.SetChromeFlags(aChromeFlags: Longword): Longword;
begin
  FChromeFlags := aChromeFlags;
  UpdateChrome;
  Result := NS_OK;
end;

function TGeckoChromeForm.DestroyBrowserWindow: Longword;
begin
  Close;
  Result := NS_OK;
end;

function TGeckoChromeForm.SizeBrowserTo(aCX, aCY: Integer): Longword;
var
  dx, dy: Integer;
begin
  dx := Width - ClientWidth;
  dy := Height - ClientHeight;
  SetBounds(Left, Top, aCX+dx, aCY+dy);
  Result := NS_OK;
end;

function TGeckoChromeForm.ShowAsModal: Longword;
begin
  Visible := False;
  ShowModal;
  Result := NS_OK;
end;

function TGeckoChromeForm.IsWindowModal(out _retval: LongBool): Longword;
begin
  _retval := False;
  Result := NS_ERROR_NOT_IMPLEMENTED;
end;

function TGeckoChromeForm.ExitModalEventLoop(aStatus: Longword): Longword;
begin
  ModalResult := 1;
  Result := NS_OK;
end;

function TGeckoChromeForm.SetDimensions(flags: Longword; x, y, cx, cy: Longint): Longword;
const
  FLAGS_POSITION   = NS_IEMBEDDINGSITEWINDOW_DIM_FLAGS_POSITION;
  FLAGS_SIZE_INNER = ns_IEmbeddingSiteWindow_DIM_FLAGS_SIZE_INNER;
  FLAGS_SIZE_OUTER = ns_IEmbeddingSiteWindow_DIM_FLAGS_SIZE_OUTER;
var
  dx, dy: Integer;
begin
  dx := Width - ClientWidth;
  dy := Height - ClientHeight;

  if (flags and FLAGS_POSITION)<>0 then
  begin
    if (flags and FLAGS_SIZE_INNER)<>0 then
    begin
      Bounds(x, y, cx+dx, cy+dy);
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
    Bounds(Left, Top, cx+dx, cy+dy);
  end else
  if (flags and FLAGS_SIZE_OUTER)<>0 then
  begin
    Bounds(Left, Top, cx, cy);
  end;
  Result := NS_OK;
end;

function TGeckoChromeForm.GetDimensions(flags: Longword; out x, y, cx, cy: Longint): Longword;
const
  FLAGS_POSITION   = ns_IEmbeddingSiteWindow_DIM_FLAGS_POSITION;
  FLAGS_SIZE_INNER = ns_IEmbeddingSiteWindow_DIM_FLAGS_SIZE_INNER;
  FLAGS_SIZE_OUTER = ns_IEmbeddingSiteWindow_DIM_FLAGS_SIZE_OUTER;
begin
  Result := NS_ERROR_INVALID_ARG;
  if (flags and FLAGS_POSITION)<>0 then
  begin
    if (@x=nil) or (@y=nil) then Exit;
    x := Left;
    y := Top;
  end;

  if (flags and FLAGS_SIZE_INNER)<>0 then
  begin
    if (@cx=nil) or (@cy=nil) then Exit;
    cx := ClientWidth;
    cy := ClientHeight;
  end else
  if (flags and FLAGS_SIZE_OUTER)<>0 then
  begin
    if (@cx=nil) or (@cy=nil) then Exit;
    cx := Width;
    cy := Height;
  end;
  Result := NS_OK;
end;

function TGeckoChromeForm.SetFocus: Longword;
begin
  Result := NS_ERROR_NOT_IMPLEMENTED;
end;

function  TGeckoChromeForm.GetVisibility(out Value: LongBool): Longword;
begin
  Value := True;
  Result := NS_OK;
end;

function TGeckoChromeForm.SetVisibility(Value: LongBool): Longword;
begin
  //Visible := Value;
  Result := NS_OK;
end;

function TGeckoChromeForm.GetTitle(out Value: PWideChar): Longword;
begin
  Value := nil;
  Result := NS_ERROR_NOT_IMPLEMENTED;
end;

function TGeckoChromeForm.SetTitle(const Value: PWideChar): Longword;
begin
  Caption := WideString(Value);
  Result := NS_OK;
end;

function TGeckoChromeForm.GetSiteWindow(out Value: Pointer): Longword;
begin
  Value := Pointer(Handle);
  Result := NS_OK;
end;

function TGeckoChromeForm.OnStateChange(aWebProgress: nsIWebProgress; aRequest: nsIRequest; aStateFlags: PRUint32; aStatus: nsresult): nsresult;
begin
  if ((aStateFlags and NS_IWEBPROGRESSLISTENER_STATE_STOP)<>0) and
     ((aStateFlags and NS_IWEBPROGRESSLISTENER_STATE_IS_DOCUMENT)<>0) then
  begin
    ContentFinishedLoading();
  end;
  Result := NS_OK;
end;

function TGeckoChromeForm.OnProgressChange(aWebProgress: nsIWebProgress; aRequest: nsIRequest; aCurSelfProgress: PRInt32; aMaxSelfProgress: PRInt32; aCurTotalProgress: PRInt32; aMaxTotalProgress: PRInt32): nsresult;
begin
  Result := NS_ERROR_NOT_IMPLEMENTED;
end;

function TGeckoChromeForm.OnLocationChange(aWebProgress: nsIWebProgress; aRequest: nsIRequest; location: nsIURI): nsresult;
begin
  Result := NS_ERROR_NOT_IMPLEMENTED;
end;

function TGeckoChromeForm.OnStatusChange(aWebProgress: nsIWebProgress; aRequest: nsIRequest; aStatus: nsresult; const aMessage: PWideChar): nsresult;
begin
  Result := NS_ERROR_NOT_IMPLEMENTED;
end;

function TGeckoChromeForm.OnSecurityChange(aWebProgress: nsIWebProgress; aRequest: nsIRequest; state: PRUint32): nsresult;
begin
  Result := NS_ERROR_NOT_IMPLEMENTED;
end;


function TGeckoChromeForm.GetInterface(const uuid: TGUID; out Intf): Longword;
var
  domwin: nsIDOMWindow;
begin
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

function TGeckoChromeForm.QueryReferent(const IID: TGUID; out Obj): Longword;
begin
  Result := QueryInterface(IID, Obj);
end;

function TGeckoChromeForm.GetWeakReference(out _retval: nsIWeakReference): Longword;
begin
  Result := QueryInterface(nsIWeakReference, _retval);
end;

procedure TGeckoChromeForm.FormCreate(Sender: TObject);
begin
  InitWebBrowser;
end;

procedure TGeckoChromeForm.FormResize(Sender: TObject);
var
  baseWin: nsIBaseWindow;
begin
  //
  baseWin:=FWebBrowser as nsIBaseWindow;
  baseWin.SetPositionAndSize(0, 0, ClientWidth, ClientHeight, True);
  baseWin.SetVisibility(True);
end;

procedure TGeckoChromeForm.ContentFinishedLoading;
var
  contentWin: nsIDOMWindow;
begin
  if Assigned(FWebBrowser) then
  begin
    if NS_SUCCEEDED(FWebBrowser.GetContentDOMWindow(contentWin)) then
    begin
      contentWin.SizeToContent;
    end;
    Visible := True;
  end;
end;

end.
