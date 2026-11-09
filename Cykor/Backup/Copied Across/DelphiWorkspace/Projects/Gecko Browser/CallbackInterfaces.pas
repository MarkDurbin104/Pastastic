unit CallbackInterfaces;

interface

uses
  nsXPCOM, nsTypes;

type
  IGeckoCreateWindowTarget = interface
  ['{934D4785-B78A-43D0-ABAD-1CC71AC06E24}']
    function DoCreateChromeWindow(
        chromeFlags: Longword;
        out newChrome: nsIWebBrowserChrome): Longword;
    function GetWebBrowserChrome: nsIWebBrowserChrome;
  end;

procedure AddCreateWindowTarget(target: IGeckoCreateWindowTarget);
procedure RemoveCreateWindowTarget(target: IGeckoCreateWindowTarget);
function InitWindowCreator: Boolean;

implementation

uses
  Classes, SysUtils, nsError, nsXPCOMGlue, GeckoChromeWindow;

type
  TWindowCreator = class(TInterfacedObject,
                         nsIWindowCreator)
    function CreateChromeWindow(parent: nsIWebBrowserChrome;
                                chromeFlags: PRUint32;
                                out _retval: nsIWebBrowserChrome)
                                : Longword; stdcall;
  end;

var
  sTargets: TInterfaceList;
  sTargetInitialized: Boolean = False;

function GetTargetList: TInterfaceList;
begin
  Result := sTargets;
  if not Assigned(Result) and not sTargetInitialized then
  try
    sTargets := TInterfaceList.Create;
    Result := sTargets;
  except
    Result := nil;
  end;
end;

procedure AddCreateWindowTarget(target: IGeckoCreateWindowTarget);
var
  list: TInterfaceList;
begin
  list := GetTargetList;
  if not Assigned(list) then Exit;
  list.Add(target);
end;

procedure RemoveCreateWindowTarget(target: IGeckoCreateWindowTarget);
var
  list: TInterfaceList;
begin
  list := GetTargetList;
  if not Assigned(list) then Exit;
  list.Remove(target);
end;

function FindTarget(chrome: nsIWebBrowserChrome): IGeckoCreateWindowTarget;
var
  list: TInterfaceList;
  target: IGeckoCreateWindowTarget;
  i, cnt: Integer;
begin
  Result := nil;
  list := GetTargetList;
  if not Assigned(list) then Exit;
  cnt := list.Count;
  for i:=0 to cnt-1 do
  begin
    Supports(list.Items[i], IGeckoCreateWindowTarget, target);
    if Assigned(target) and (target.GetWebBrowserChrome=chrome) then
    begin
      Result := target;
      Exit;
    end;
  end;
end;

var
  sWindowCreatorInitialized: Boolean = False;
  sWindowCreator: TWindowCreator = nil;

function InitWindowCreator: Boolean;
const
  NS_WINDOWWATCHER_CONTRACTID = '@mozilla.org/embedcomp/window-watcher;1';
var
  creator: TWindowCreator;
  wwatch: nsIWindowWatcher;
  rv: Longword;
begin
  Result := False;
  if not sWindowCreatorInitialized then
  try
    sWindowCreatorInitialized := True;
    creator := TWindowCreator.Create;
    sWindowCreator := creator;
  except
  end;
  if not Assigned(sWindowCreator) then Exit;

  rv := NS_GetService(NS_WINDOWWATCHER_CONTRACTID, nsIWindowWatcher, wwatch);
  if NS_FAILED(rv) then Exit;

  rv := wwatch.SetWindowCreator(sWindowCreator);
  if NS_SUCCEEDED(rv) then Result := True;
end;

function TWindowCreator.CreateChromeWindow(parent: nsIWebBrowserChrome;
                                           chromeFlags: PRUint32;
                                           out _retval: nsIWebBrowserChrome): Longword;
var
  target: IGeckoCreateWindowTarget;
  chrome: TGeckoChromeForm;
begin
  Result := NS_ERROR_FAILURE;

  if (chromeFlags and CHROME_OPENAS_CHROME)<>0 then
  try
    chrome := TGeckoChromeForm.CreateWithChromeFlags(nil, chromeFlags);
    try
      target := IGeckoCreateWindowTarget(chrome);
      _retval := target.GetWebBrowserChrome;
      Result := NS_OK;
    except
      chrome.Close;
    end;
  except
    Result := NS_ERROR_FAILURE;
  end else
  begin
    target := FindTarget(parent);
    if Assigned(target) then
      Result := target.DoCreateChromeWindow(chromeFlags, _retval);
  end;
end;


end.
