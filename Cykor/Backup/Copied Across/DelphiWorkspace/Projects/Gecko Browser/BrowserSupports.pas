unit BrowserSupports;

interface

uses
  nsXPCOM, nsGeckoStrings, nsTypes;

type
  nsIWidget = interface(nsISupports)
  end;

const
  // nsIWebNavigation.idl
  (**
  * Load flags for use with loadURI() and reload()
  *)
  ns_IWebNavigation_LOAD_FLAGS_MASK = 65535;
  (**
  * loadURI() specific flags
  *)
(**
  * Normal load flag.
  *)
  ns_IWebNavigation_LOAD_FLAGS_NONE = 0;
  (**
  * Meta-refresh flag.  The cache is bypassed.  This type of load is
  *                     usually the result of a meta-refresh tag, or a HTTP
  *                     'refresh' header.
  *)
  ns_IWebNavigation_LOAD_FLAGS_IS_REFRESH = 16;
  (**
  * Link-click flag.
  *)
  ns_IWebNavigation_LOAD_FLAGS_IS_LINK = 32;
  (**
  * Bypass history flag.
  *)
  nsIWebNavigation_LOAD_FLAGS_BYPASS_HISTORY = 64;
  (**
  * Replace history entry flag.
  *)
  ns_IWebNavigation_LOAD_FLAGS_REPLACE_HISTORY = 128;
  ns_IWebNavigation_LOAD_FLAGS_BYPASS_CACHE = 256;
  ns_IWebNavigation_LOAD_FLAGS_BYPASS_PROXY = 512;
  ns_IWebNavigation_LOAD_FLAGS_CHARSET_CHANGE = 1024;
  (**
  * Stop() flags:
  *)
(**
  * Stop all network activity.  This includes both active network loads and
  * pending meta-refreshes.
  *)
  ns_IWebNavigation_STOP_NETWORK = 1;
  (**
  * Stop all content activity.  This includes animated images, plugins and
  * pending Javascript timeouts.
  *)
  ns_IWebNavigation_STOP_CONTENT = 2;
  (**
  * Stop all activity.
  *)
  ns_IWebNavigation_STOP_ALL = 3;

  // nsIBaseWindow.idl

type
  // nsIWebNavigation.idl

  // nsIBaseWindow.idl
    PnativeWindow = ^nativeWindow;
    nativeWindow = Longint;


  // nsIWebNavigation.idl
  nsIWebNavigation = interface;

  // nsIBaseWindow.idl
  nsIBaseWindow = interface;


  // nsIWebNavigation.idl
  nsIWebNavigation = interface(nsISupports)
  ['{f5d9e7b0-d930-11d3-b057-00a024ffc08c}']
    (**
  * Indicates if the object can go back.  If true this indicates that
  * there is back session history available for navigation.
  *)
    (* readonly attribute boolean canGoBack; *)
    function GetCanGoBack(out aCanGoBack: LongBool): Longword; stdcall;

    (**
  * Indicates if the object can go forward.  If true this indicates that
  * there is forward session history available for navigation
  *)
    (* readonly attribute boolean canGoForward; *)
    function GetCanGoForward(out aCanGoForward: LongBool): Longword; stdcall;

    (**
  * Tells the object to navigate to the previous session history item.  When
  * a page is loaded from session history, all content is loaded from the
  * cache (if available) and page state (such as form values, scroll position)
  * is restored.
  *
  * @return NS_OK               - Backward navigation was successful.
  *         NS_ERROR_UNEXPECTED - This call was unexpected at this time.  Most
  *                               likely you can't go back right now.
  *)
    (* void goBack (); *)
    function GoBack(): Longword; stdcall;

    (**
  * Tells the object to navigate to the next Forward session history item.
  * When a page is loaded from session history, all content is loaded from
  * the cache (if available) and page state (such as form values, scroll
  * position) is restored.
  *
  * @return NS_OK               - Forward was successful.
  *         NS_ERROR_UNEXPECTED - This call was unexpected at this time.  Most
  *                               likely you can't go forward right now.
  *)
    (* void goForward (); *)
    function GoForward(): Longword; stdcall;

    (**
  * Tells the object to navigate to the session history item at index.
  *
  * @return NS_OK -               GotoIndex was successful.
  *         NS_ERROR_UNEXPECTED - This call was unexpected at this time.  Most
  *                               likely you can't goto that index
  *)
    (* void gotoIndex (in long index); *)
    function GotoIndex(index: Longint): Longword; stdcall;

    (**
  * Loads a given URI.  This will give priority to loading the requested URI
  * in the object implementing	this interface.  If it can't be loaded here
  * however, the URL dispatcher will go through its normal process of content
  * loading.
  *
  * @param uri       - The URI string to load.
  * @param loadFlags - Flags modifying load behaviour. Generally you will pass
  *                    LOAD_FLAGS_NONE for this parameter.
  * @param referrer  - The referring URI.  If this argument is NULL, the
  *                    referring URI will be inferred internally.
  * @param postData  - nsIInputStream containing POST data for the request.
  *)
    (* void loadURI (in wstring uri, in unsigned long loadFlags, in nsIURI referrer, in nsIInputStream postData, in nsIInputStream headers); *)
    function LoadURI(const uri: PWideChar; loadFlags: Longword; referrer: nsIURI; postData: nsIInputStream; headers: nsIInputStream): Longword; stdcall;

    (**
  * Tells the Object to reload the current page.
  *
  * @param reloadFlags - Flags modifying reload behaviour. Generally you will
  *                      pass LOAD_FLAGS_NONE for this parameter.
  *)
    (* void reload (in unsigned long reloadFlags); *)
    function Reload(reloadFlags: Longword): Longword; stdcall;

    (**
  * Stops a load of a URI.
  *
  * @param stopFlags - Flags indicating the stop behavior.
  *)
    (* void stop (in unsigned long stopFlags); *)
    function Stop(stopFlags: Longword): Longword; stdcall;

    (**
  * Retrieves the current DOM document for the frame, or lazily creates a
  * blank document if there is none. This attribute never returns null except
  * for unexpected error situations.
  *)
    (* readonly attribute nsIDOMDocument document; *)
    function GetDocument(out aDocument: nsIDOMDocument): Longword; stdcall;

    (**
  * The currently loaded URI or null.
  *)
    (* readonly attribute nsIURI currentURI; *)
    function GetCurrentURI(out aCurrentURI: nsIURI): Longword; stdcall;

    (**
  * The referring URI.
  *)
    (* readonly attribute nsIURI referringURI; *)
    function GetReferringURI(out aReferringURI: nsIURI): Longword; stdcall;

    (**
  * The session history object used to store the session history for the
  * session.
  *)
    (* attribute nsISHistory sessionHistory; *)
    function GetSessionHistory(out aSessionHistory: nsISHistory): Longword; stdcall;
    function SetSessionHistory(aSessionHistory: nsISHistory): Longword; stdcall;

  end;


  // nsIBaseWindow.idl
(**
 * The nsIBaseWindow describes a generic window and basic operations that 
 * can be performed on it.  This is not to be a complete windowing interface
 * but rather a common set that nearly all windowed objects support.    
 *)
  nsIBaseWindow = interface(nsISupports)
  ['{046bc8a0-8015-11d3-af70-00a024ffc08c}']
    (* [noscript] void initWindow (in nativeWindow parentNativeWindow, in nsIWidget parentWidget, in long x, in long y, in long cx, in long cy); *)
    function InitWindow(parentNativeWindow: nativeWindow; parentWidget: nsIWidget; x: Longint; y: Longint; cx: Longint; cy: Longint): Longword; stdcall;

    (* void create (); *)
    function Create(): Longword; stdcall;

    (* void destroy (); *)
    function Destroy(): Longword; stdcall;

    (* void setPosition (in long x, in long y); *)
    function SetPosition(x: Longint; y: Longint): Longword; stdcall;

    (* void getPosition (out long x, out long y); *)
    function GetPosition(out x: Longint; out y: Longint): Longword; stdcall;

    (* void setSize (in long cx, in long cy, in boolean fRepaint); *)
    function SetSize(cx: Longint; cy: Longint; fRepaint: LongBool): Longword; stdcall;

    (* void getSize (out long cx, out long cy); *)
    function GetSize(out cx: Longint; out cy: Longint): Longword; stdcall;

    (* void setPositionAndSize (in long x, in long y, in long cx, in long cy, in boolean fRepaint); *)
    function SetPositionAndSize(x: Longint; y: Longint; cx: Longint; cy: Longint; fRepaint: LongBool): Longword; stdcall;

    (* void getPositionAndSize (out long x, out long y, out long cx, out long cy); *)
    function GetPositionAndSize(out x: Longint; out y: Longint; out cx: Longint; out cy: Longint): Longword; stdcall;

    (** 
	 * Tell the window to repaint itself
	 * @param aForce - if true, repaint immediately
	 *                 if false, the window may defer repainting as it sees fit.
	 *)
    (* void repaint (in boolean force); *)
    function Repaint(force: LongBool): Longword; stdcall;

    (* [noscript] attribute nsIWidget parentWidget; *)
    function GetParentWidget(out aParentWidget: nsIWidget): Longword; stdcall;
    function SetParentWidget(aParentWidget: nsIWidget): Longword; stdcall;

    (* attribute nativeWindow parentNativeWindow; *)
    function GetParentNativeWindow(out aParentNativeWindow: nativeWindow): Longword; stdcall;
    function SetParentNativeWindow(aParentNativeWindow: nativeWindow): Longword; stdcall;

    (* attribute boolean visibility; *)
    function GetVisibility(out aVisibility: LongBool): Longword; stdcall;
    function SetVisibility(aVisibility: LongBool): Longword; stdcall;

    (* attribute boolean enabled; *)
    function GetEnabled(out aEnabled: LongBool): Longword; stdcall;
    function SetEnabled(aEnabled: LongBool): Longword; stdcall;

    (** set blurSuppression to true to suppress handling of blur events.
     *  set it false to re-enable them. query it to determine whether
     *  blur events are suppressed. The implementation should allow
     *  for blur events to be suppressed multiple times.
     *)
    (* attribute boolean blurSuppression; *)
    function GetBlurSuppression(out aBlurSuppression: LongBool): Longword; stdcall;
    function SetBlurSuppression(aBlurSuppression: LongBool): Longword; stdcall;

    (* [noscript] readonly attribute nsIWidget mainWidget; *)
    function GetMainWidget(out aMainWidget: nsIWidget): Longword; stdcall;

    (**
	* Give the window focus.
	*)
    (* void setFocus (); *)
    function SetFocus(): Longword; stdcall;

    (* attribute wstring title; *)
    function GetTitle(out aTitle: PWideChar): Longword; stdcall;
    function SetTitle(const aTitle: PWideChar): Longword; stdcall;

  end;


const
  nsIContextMenuListener2_CONTEXT_NONE             = 0;
  nsIContextMenuListener2_CONTEXT_LINK             = 1;
  nsIContextMenuListener2_CONTEXT_IMAGE            = 2;
  nsIContextMenuListener2_CONTEXT_DOCUMENT         = 4;
  nsIContextMenuListener2_CONTEXT_TEXT             = 8;
  nsIContextMenuListener2_CONTEXT_INPUT            = 16;
  nsIContextMenuListener2_CONTEXT_BACKGROUND_IMAGE = 32;
type
  nsIContextMenuListener2 = interface;
  nsIContextMenuInfo = interface;
  imgIContainer = interface;
  imgIContainerObserver = interface;
  gfxIImageFrame = interface;

  // nsIContextMenuListener2
  nsIContextMenuListener2 = interface(nsISupports)
  ['{7fb719b3-d804-4964-9596-77cf924ee314}']
    function OnShowContextMenu(aContextFlags: Longword; aUtils: nsIContextMenuInfo): Longword; stdcall;
  end;

  // nsIContextMenuInfo
  nsIContextMenuInfo = interface(nsISupports)
  ['{2f977d56-5485-11d4-87e2-0010a4e75ef2}']
    function GetMouseEvent(out aMouseEvent: nsIDOMEvent): Longword; stdcall;
    function GetTargetNode(out aTargetNode: nsIDOMNode): Longword; stdcall;
    function GetAssociatedLink(aAssociatedLink: nsAString): Longword; stdcall;
    function GetImageContainer(out aImageContainer: imgIContainer): Longword; stdcall;
    function GetImageSrc(out aImageSrc: nsIURI): Longword; stdcall;
    function GetBackgroundImageContainer(out aBackgroundImageContainer: imgIContainer): Longword; stdcall;
    function GetBackgroundImageSrc(out aBackgroundImageSrc: nsIURI): Longword; stdcall;
  end;

  // imgIContainer
  imgIContainer = interface(nsISupports)
  ['{5e8405a4-1dd2-11b2-8385-bc8e3446cad3}']
    function Init(aWidth: Longint; aHeight: Longint; aObserver: imgIContainerObserver): Longword; stdcall;
    function GetPreferredAlphaChannelFormat(out aPreferredAlphaChannelFormat: Longint): Longword; stdcall;
    function GetWidth(out aWidth: Longint): Longword; stdcall;
    function GetHeight(out aHeight: Longint): Longword; stdcall;
    function GetCurrentFrame(out aCurrentFrame: gfxIImageFrame): Longword; stdcall;
    function GetNumFrames(out aNumFrames: Longword): Longword; stdcall;
    function GetAnimationMode(out aAnimationMode: Word): Longword; stdcall;
    function SetAnimationMoade(aAnimationMode: Word): Longword; stdcall;
    function GetFrameAt(index: Longword; _retval: gfxIImageFrame): Longword; stdcall;
    function AppendFrame(item: gfxIImageFrame): Longword; stdcall;
    function RemoveFrame(item: gfxIImageFrame): Longword; stdcall;
    function EndFrameDecode(framenumber: Longword; timeout: Longword): Longword; stdcall;
    function DecodingComplete: Longword; stdcall;
    function Clear: Longword; stdcall;
    function StartAnimation: Longword; stdcall;
    function StopAnimation: Longword; stdcall;
    function ResetAnimation: Longword; stdcall;
    function GetLoopCount(out aLoopCount: Longint): Longword; stdcall;
    function SetLoopCount(aLoopCount: Longint): Longword; stdcall;
  end;

  imgIContainerObserver = interface(nsISupports)
  ['{153f1518-1dd2-11b2-b9cd-b16eb63e0471}']
    function FrameChanged(aContainer: imgIContainer;
                          aFrame: gfxIImageFrame;
                          aDirtyRect: nsRect): Longword; stdcall;
  end;

  gfxIImageFrame = interface(nsISupports)
  ['{51cc27a8-1dd2-11b2-a1aa-dad33ab193b4}']
    function Init(aX: Longint;
                  aY: Longint;
                  aWidth: Longint;
                  aHeight: Longint;
                  aFormat: Longint;
                  aDepth: Smallint): Longword; stdcall;
    function GetMutable(out aMutable: LongBool): Longword; stdcall;
    function SetMutable(aMutable: LongBool): Longword; stdcall;
    function GetX(out aX: Longint): Longword; stdcall;
    function GetY(out aY: Longint): Longword; stdcall;
    function GetWidth(out aWidth: Longint): Longword; stdcall;
    function GetHeight(out aHeight: Longint): Longword; stdcall;
    function GetRect(var rect: nsRect): Longword; stdcall;
    function GetFormat(out aFormat: Longint): Longword; stdcall;
    function GetImageBytesPerRow(out aImageBytesPerRow: Longword): Longword; stdcall;
    function GetImageDataLength(out aImageDataLength: Longword): Longword; stdcall;
    function GetImageData(out bits: PByte; out length: Longword): Longword; stdcall;
    function SetImageData(const bits: PByte; length: Longword; offset: Longint): Longword; stdcall;
    function LockImageData: Longword; stdcall;
    function UnlockImageData: Longword; stdcall;
    function GetAlphaBytesPerRow(out aAlphaBytesPerRow: Longword): Longword; stdcall;
    function GetAlphaDataLength(out aAlphaDataLength: Longword): Longword; stdcall;
    function GetAlphaData(out bits: PByte; out Length: Longword): Longword; stdcall;
    function SetAlphaData(const bits: PByte; Length: Longword; offset: Longint): Longword; stdcall;
    function LockAlphaData: Longword; stdcall;
    function UnlockAlphaData: Longword; stdcall;
    function DrawTo(aDst: gfxIImageFrame;
                    aDX: Longint;
                    aDY: Longint;
                    aDWidth: Longint;
                    aDHeight: Longint): Longword; stdcall;
    function GetTimeout(out aTimeout: Longint): Longword; stdcall;
    function SetTimeout(aTimeout: Longint): Longword; stdcall;
    function GetFrameDisposalMethod(out aFrameDisposalMethod: Longint): Longword; stdcall;
    function SetFrameDisposalMethod(aFrameDisposalMethod: Longint): Longword; stdcall;
    function GetBackgroundColor(out aBackgroundColor: Longword): Longword; stdcall;
    function SetBackgroundColor(aBackgroundColor: Longword): Longword; stdcall;
  end;


  TCtxMenuInfo = class;
  TCtxMenuFlags = set of (cmfLink,
                          cmfImage,
                          cmfDocument,
                          cmfText,
                          cmfInput,
                          cmfBGImage );

  TCtxMenuInfo = class(TObject)
  private
    FInfo: nsIContextMenuInfo;
    FFlags: TCtxMenuFlags;

    // function GetMouseEvent: nsIDOMEvent;
    // function GetTargetNode: nsIDOMNode;
    function GetAssociatedLink: WideString;
    // function GetImageContainer: imgContainer;
    // function GetImageSrc: nsIURI;
    function GetImageURL: AnsiString;
    // function GetBGImageContainer: imgIContainer;
    // function GetBGImageSrc: nsIURI;
    function GetBGImageURL: AnsiString;
  public
    constructor Create(flags: Longword; info: nsIContextMenuInfo);

    property Flags: TCtxMenuFlags read FFlags;
    property AssociatedLink: WideString read GetAssociatedLink;
    property ImageURL: AnsiString read GetImageURL;
    property BGImageURL: AnsiString read GetBGImageURL;
  end;

implementation

uses
  nsError;

constructor TCtxMenuInfo.Create(flags: Longword; info: nsIContextMenuInfo);
begin
  inherited Create;

  FInfo := info;
  FFlags := [];

  if 0<>(flags and nsIContextMenuListener2_CONTEXT_LINK) then
    FFlags := FFlags + [cmfLink];
  if 0<>(flags and nsIContextMenuListener2_CONTEXT_IMAGE) then
    FFlags := FFlags + [cmfImage];
  if 0<>(flags and nsIContextMenuListener2_CONTEXT_DOCUMENT) then
    FFlags := FFlags + [cmfDocument];
  if 0<>(flags and nsIContextMenuListener2_CONTEXT_TEXT) then
    FFlags := FFlags + [cmfText];
  if 0<>(flags and nsIContextMenuListener2_CONTEXT_INPUT) then
    FFlags := FFlags + [cmfInput];
  if 0<>(flags and nsIContextMenuListener2_CONTEXT_BACKGROUND_IMAGE) then
    FFlags := FFlags + [cmfBGImage];
end;

function TCtxMenuInfo.GetAssociatedLink: WideString;
var
  str: IInterfacedString;
begin
  str := NewString;
  if NS_SUCCEEDED(FInfo.GetAssociatedLink(str.AString)) then
    Result := str.ToString;
end;

function TCtxMenuInfo.GetImageURL: String;
var
  str: IInterfacedCString;
  uri: nsIURI;
begin
  str := NewCString;
  if NS_SUCCEEDED(FInfo.GetImageSrc(uri)) then
    if NS_SUCCEEDED(uri.GetSpec(str.ACString)) then
      Result := str.ToString;
end;

function TCtxMenuInfo.GetBGImageURL: String;
var
  str: IInterfacedCString;
  uri: nsIURI;
begin
  str := NewCString;
  if NS_SUCCEEDED(FInfo.GetBackgroundImageSrc(uri)) then
    if NS_SUCCEEDED(uri.GetSpec(str.ACString)) then
      Result := str.ToString;
end;

end.
