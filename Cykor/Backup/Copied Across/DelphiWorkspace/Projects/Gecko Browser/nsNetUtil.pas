unit nsNetUtil;

interface

uses
  nsXPCOM, nsGeckoStrings, nsConsts;

function NS_GetIOService(out ioservice: nsIIOService): Longword;

function NS_NewURI(out uri: nsIURI;
                   const spec: nsACString;
                   const charset: AnsiString='';
                   baseURI: nsIURI=nil; ioService:
                   nsIIOService=nil): Longword; overload;
function NS_NewURI(out uri: nsIURI;
                   const spec: AnsiString;
                   baseURI: nsIURI=nil;
                   ioService: nsIIOService=nil): Longword; overload;
function NS_NewFileURI(out uri: nsIURI;
                       spec: nsIFile; ioService:
                       nsIIOService=nil): Longword;
function NS_NewChannel(out channel: nsIChannel;
                       uri: nsIURI; ioService:
                       nsIIOService=nil;
                       loadGroup: nsILoadGroup=nil;
                       callbacks: nsIInterfaceRequestor=nil;
                       loadFlags: Longword=NS_IREQUEST_LOAD_NORMAL): Longword;
function NS_OpenURI(out stream: nsIInputStream;
                    uri: nsIURI; ioService:
                    nsIIOService=nil;
                    loadGroup: nsILoadGroup=nil;
                    callbacks: nsIInterfaceRequestor=nil;
                    loadFlags: Longword=NS_IREQUEST_LOAD_NORMAL): Longword; overload;
function NS_OpenURI(listener: nsIStreamListener;
                    context: nsISupports; uri:
                    nsIURI; ioService: nsIIOService=nil;
                    loadGroup: nsILoadGroup=nil;
                    callbacks: nsIInterfaceRequestor=nil;
                    loadFlags: Longword=NS_IREQUEST_LOAD_NORMAL): Longword; overload;
function NS_MakeAbsoluteURI(uri: nsACString;
                            const spec: nsACString;
                            baseURI: nsIURI;
                            ioService: nsIIOService=nil): Longword; overload;
function NS_MakeAbsoluteURI(out uri: AnsiString;
                            const spec: AnsiString;
                            baseURI: nsIURI;
                            ioService: nsIIOService=nil): Longword; overload;
function NS_NewLoadGroup(out loadGroup: nsILoadGroup;
                         obs: nsIRequestObserver): Longword;


{$IF MOZILLA_VERSION>=1.7}
function NS_NewURI(out uri: nsIURI; const spec: nsAString; const charset: AnsiString=''; baseURI: nsIURI=nil; ioService: nsIIOService=nil): Longword; overload;
function NS_MakeAbsoluteURI(uri: nsAString; const spec: nsAString; baseURI: nsIURI; ioService: nsIIOService=nil): Longword; overload
{$IFEND}
implementation

uses
  nsXPCOMGlue, nsError;

function NS_GetIOService(out ioservice: nsIIOService): Longword;
const
  kIOServiceCID:TGUID = '{9ac9e770-18bc-11d3-9337-00104ba0fd40}';
begin
  Result := NS_GetService(kIOServiceCID, nsIIOService, ioservice);
end;

function EnsureIOService(ios: nsIIOService; out grip: nsIIOService): Longword;
begin
  if not Assigned(ios) then
  begin
    Result := NS_GetIOService(grip)
  end else
  begin
    Result := NS_OK;
    grip := ios;
  end;
end;

function NS_NewURI(out uri: nsIURI; const spec: nsACString; const charset: AnsiString; baseURI: nsIURI; ioService: nsIIOService): Longword;
var
  charsetPtr: PAnsiChar;
  grip: nsIIOService;
begin
  if Length(charset)>0 then
    charsetPtr := PAnsiChar(charset)
  else
    charsetPtr := nil;

  Result := EnsureIOService(ioService, grip);
  if Assigned(grip) then
    Result := grip.NewURI(spec, charsetPtr, baseURI, uri);
end;

{$IF MOZILLA_VERSION>=1.7}
function NS_NewURI(out uri: nsIURI; const spec: nsAString; const charset: AnsiString; baseURI: nsIURI; ioService: nsIIOService): Longword;
var
  spec2: IInterfacedCString;
begin
  try
    spec2 := NewCString;
  except
    Result := NS_ERROR_OUT_OF_MEMORY;
    Exit;
  end;
  Result := NS_UTF16ToCString(spec, NS_ENCODING_UTF8, spec2.ACString);
  if NS_FAILED(Result) then Exit;
  Result := NS_NewURI(uri, spec2.ACString, charset, baseURI, ioService);
end;
{$IFEND}

function NS_NewURI(out uri: nsIURI; const spec: AnsiString; baseURI: nsIURI; ioService: nsIIOService): Longword;
var
  spec2: IInterfacedCString;
begin
  try
    spec2 := NewCString(PChar(spec));
  except
    Result := NS_ERROR_OUT_OF_MEMORY;
    Exit;
  end;
  Result := NS_NewURI(uri, spec2.ACString, '', baseURI, ioService);
end;

function NS_NewFileURI(out uri: nsIURI;
                       spec: nsIFile; ioService:
                       nsIIOService): Longword;
var
  grip: nsIIOService;
begin
  Result := EnsureIOService(ioService, grip);
  if Assigned(grip) then
    Result := grip.NewFileURI(spec, uri);
end;

function NS_NewChannel(out channel: nsIChannel;
                       uri: nsIURI;
                       ioService: nsIIOService;
                       loadGroup: nsILoadGroup;
                       callbacks: nsIInterfaceRequestor;
                       loadFlags: Longword): Longword;
var
  grip: nsIIOService;
  chan: nsIChannel;
begin
  Result := EnsureIOService(ioService, grip);
  if Assigned(grip) then
  begin
    Result := grip.NewChannelFromURI(uri, chan);
    if NS_SUCCEEDED(Result) then
    begin
      if Assigned(loadGroup) then
        Result := Result or chan.SetLoadGroup(loadGroup);
      if Assigned(callbacks) then
        Result := Result or chan.SetNotificationCallbacks(callbacks);
      if loadFlags <> NS_IREQUEST_LOAD_NORMAL then
        Result := Result or chan.SetLoadFlags(loadFlags);
      if NS_SUCCEEDED(Result) then
        channel :=  chan;
    end;
  end;
end;

function NS_OpenURI(out stream: nsIInputStream;
                    uri: nsIURI;
                    ioService: nsIIOService;
                    loadGroup: nsILoadGroup;
                    callbacks: nsIInterfaceRequestor;
                    loadFlags: Longword): Longword;
var
  channel: nsIChannel;
  st: nsIInputStream;
begin
  Result := NS_NewChannel(channel, uri, ioService, loadGroup, callbacks, loadFlags);
  if NS_SUCCEEDED(Result) then
  begin
    Result := channel.Open(st);
    if NS_SUCCEEDED(Result) then
      stream := st;
  end;
end;

function NS_OpenURI(listener: nsIStreamListener;
                    context: nsISupports; uri:
                    nsIURI; ioService: nsIIOService;
                    loadGroup: nsILoadGroup;
                    callbacks: nsIInterfaceRequestor;
                    loadFlags: Longword): Longword;
var
  channel: nsIChannel;
begin
  Result := NS_NewChannel(channel, uri, ioService, loadGroup, callbacks, loadFlags);
  if NS_SUCCEEDED(Result) then
    Result := channel.AsyncOpen(listener, context);
end;

function NS_MakeAbsoluteURI(uri: nsACString;
                            const spec: nsACString;
                            baseURI: nsIURI;
                            ioService: nsIIOService): Longword;
var
  uri2, spec2: IInterfacedCString;
begin
  try
    uri2 := RelateCString(uri);
    spec2 := RelateCString(spec);
  except
    Result := NS_ERROR_OUT_OF_MEMORY;
    Exit;
  end;

  if not Assigned(baseURI) then
  begin
    Result := NS_OK;
    uri2.Assign(spec2);
  end else
  if uri2.Length()=0 then
    Result := baseURI.GetSpec(uri2.ACString)
  else
    Result := baseURI.Resolve(spec2.ACString, uri2.ACString);
end;

{$IF MOZILLA_VERSION>=1.7}
function NS_MakeAbsoluteURI(uri: nsAString; const spec: nsAString; baseURI: nsIURI; ioService: nsIIOService=nil): Longword;
var
  uri2, spec2: IInterfacedString;
  buf1, buf2: IInterfacedCString;
begin
  try
    uri2 := RelateString(uri);
    spec2 := RelateString(spec);
    buf1 := NewCString;
    buf2 := NewCString;
  except
    Result := NS_ERROR_OUT_OF_MEMORY;
    Exit;
  end;

  if not Assigned(baseURI) then
  begin
    Result := NS_OK;
    uri2.Assign(spec2);
  end else
  begin
    if uri2.Length()=0 then
      Result := baseURI.GetSpec(buf1.ACString)
    else
    begin
      Result := NS_UTF16ToCString(spec,NS_ENCODING_UTF8,buf2.ACString);
      Result := Result or baseURI.Resolve(buf2.ACString, buf1.ACString);
    end;
    if NS_SUCCEEDED(Result) then
      Result := NS_CStringToUTF16(buf1.ACString, NS_ENCODING_UTF8, uri)
  end;
end;
{$IFEND}

function NS_MakeAbsoluteURI(out uri: AnsiString;
                            const spec: AnsiString;
                            baseURI: nsIURI;
                            ioService: nsIIOService): Longword;
var
  uri2, spec2: IInterfacedCString;
begin
  try
    uri2 := NewCString();
    spec2 := NewCString(spec);
  except
    Result := NS_ERROR_OUT_OF_MEMORY;
    Exit;
  end;

  Result := NS_MakeAbsoluteURI(uri2.ACString, spec2.ACString, baseURI, ioService);
  if NS_SUCCEEDED(Result) then
    uri := uri2.ToString;
end;

function NS_NewLoadGroup(out loadGroup: nsILoadGroup;
                         obs: nsIRequestObserver): Longword;
const
  kLoadGroupCID: TGUID = '{e1c61582-2a84-11d3-8cce-0060b0fc14a3}';
var
  group: nsILoadGroup;
begin
  Result := NS_CreateInstance(kLoadGroupCID,nsILoadGroup,group);
  if NS_SUCCEEDED(Result) then
  begin
    Result := group.SetGroupObserver(obs);
    if NS_SUCCEEDED(Result) then
      loadGroup := group;
  end;
end;

end.
