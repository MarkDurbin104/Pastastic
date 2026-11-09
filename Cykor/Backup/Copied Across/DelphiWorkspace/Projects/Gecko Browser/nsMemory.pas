unit nsMemory;

interface

uses
  nsXPCOM;

const
  NS_MEMORY_CONTRACTID = '@mozilla.org/xpcom/memory-service;1';
  NS_MEMORY_CLASSNAME = 'Global Memory Service';
  NS_MEMORY_CID: TGUID = '{30a04e40-38e7-11d4-8cf5-0060b0fc14a3}';

function Alloc(size: Integer): Pointer;
function Realloc(ptr: Pointer; size: Integer): Pointer;
function Free(ptr: Pointer): Integer;
function HeapMinimize(aImmediate: Boolean): Longword;
function Clone(Ptr: Pointer; size: Longword): Pointer;
function GetGlobalMemoryService: nsIMemory;

function GlueStartupMemory: Longword;
procedure GlueShutdownMemory;
implementation

uses
  SysUtils, nsError, nsXPCOMGlue;

var
  gMemory: nsIMemory;

procedure FreeGlobalMemory;
begin
  gMemory := nil;
end;

function SetupGlobalMemory: nsIMemory;
begin
  if Assigned(gMemory) then Exit;
  nsXPCOMGlue.NS_GetMemoryManager(gMemory);
  if not Assigned(gMemory) then Exit;
  Result := gMemory;
end;

function GlueStartupMemory: Longword;
begin
  Result := NS_ERROR_FAILURE;
  if Assigned(gMemory) then Exit;
  nsXPCOMGlue.NS_GetMemoryManager(gMemory);
  if not Assigned(gMemory) then Exit;
  Result := NS_OK;
end;

procedure GlueShutdownMemory;
begin
  gMemory := nil;
end;

function ENSURE_ALLOCATOR: Boolean;
begin
  Result := True;
  if not Assigned(gMemory) and not Assigned(SetupGlobalMemory()) then
    Result := False;
end;

function Alloc(size: Integer): Pointer;
begin
  Result := nil;
  if ENSURE_ALLOCATOR then
    Result := gMemory.Alloc(size);
end;

function Realloc(ptr: Pointer; size: Integer): Pointer;
begin
  Result := nil;
  if ENSURE_ALLOCATOR then
    Result := gMemory.Realloc(ptr, size);
end;

function Free(ptr: Pointer): Integer;
begin
  Result := NS_OK;
  if ENSURE_ALLOCATOR then gMemory.Free(ptr)
  else
    Result := Integer(NS_ERROR_UNEXPECTED);
end;

function HeapMinimize(aImmediate: Boolean): Longword;
begin
  Result := NS_ERROR_FAILURE;
  if ENSURE_ALLOCATOR then
    Result := gMemory.HeapMinimize(aImmediate);
end;

function Clone(ptr: Pointer; size: Longword): Pointer;
begin
  Result := nil;
  if ENSURE_ALLOCATOR then
    Result := Clone(Ptr, size);
end;

function GetGlobalMemoryService: nsIMemory;
begin
  Result := nil;
  if not ENSURE_ALLOCATOR then Exit;
  Result := gMemory;
end;

end.
