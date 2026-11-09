unit nsStream;

interface

uses
  Classes, nsXPCOM;

function NS_NewByteArrayInputStream(out stream: nsIInputStream; const Buffer: Pointer; Size: Longword): Longword;

implementation

uses
  Math, nsMemory, nsError, nsUtil;

type
  nsByteArrayInputStream = class(TInterfacedObject,
                                 nsIInputStream)
    FBuffer: PByte;
    FNBytes: Longword;
    FPos: Longword;

    constructor Create(const Buffer: Pointer; nBytes: Longword);
    destructor Destroy; override;

    function Close(): Longword; stdcall;
    function Available(out _retval: Longword): Longword; stdcall;
    function Read(aBuf: PAnsiChar; aCount: Longword; out _retval: Longword): Longword; stdcall;
    function ReadSegments(aWriter: nsWriteSegmentFun; aClosure: Pointer; aCount: Longword; out _retval: Longword): Longword; stdcall;
    function IsNonBlocking(out _retval: LongBool): Longword; stdcall;
  end;

constructor nsByteArrayInputStream.Create(const Buffer: Pointer; nBytes: Longword);
begin
  inherited Create;
  FBuffer := PByte(Buffer);
  FNBytes := nBytes;
  FPos := 0;
end;

destructor nsByteArrayInputStream.Destroy;
begin
  if Assigned(FBuffer) then
    nsMemory.Free(FBuffer);
  inherited;
end;

function nsByteArrayInputStream.Available(out _retval: Longword): Longword;
begin
  if (FNBytes=0) or not Assigned(FBuffer) then
    _retval := 0
  else
    _retval := FNBytes - FPos;
  Result := NS_OK;
end;

function nsByteArrayInputStream.Read(aBuf: PAnsiChar;
                                     aCount: Longword;
                                     out _retval: Longword): Longword;
begin
  Result := NS_ERROR_NULL_POINTER;
  if not Assigned(aBuf) then Exit;

  Result := NS_ERROR_FAILURE;
  if FNBytes = 0 then Exit;

  if (aCount=0) or (FPos = FNBytes) then
    _retval := 0
  else
  begin
    Assert(Assigned(FBuffer), 'Stream buffer has been released - there''s an ownership problem somewhere!');
    if not Assigned(FBuffer) then
      _retval := 0
    else
      if aCount > (FNBytes - FPos) then
      begin
        _retval := FNBytes - FPos;
        NS_MEMCPY(aBuf, FBuffer, _retval);
        FPos := FNBytes;
      end else
      begin
        _retval := aCount;
        NS_MEMCPY(aBuf, FBuffer, _retval);
        Inc(FPos, aCount);
      end;
  end;
  Result := NS_OK;
end;

function nsByteArrayInputStream.ReadSegments(aWriter: nsWriteSegmentFun;
                                             aClosure: Pointer;
                                             aCount: Longword;
                                             out _retval: Longword): Longword;
var
  readCount: Longword;
  rv: Longword;
  newPtr: PByte;
begin
  if FNBytes=0 then
  begin
    Result := NS_ERROR_FAILURE;
    Exit;
  end;

  if (aCount=0) or (FNBytes = FPos) then
    _retval := 0
  else
  begin
    Assert(Assigned(FBuffer), 'Stream buffer has been released - there''s an ownership problem somewhere!');
    readCount := Min(aCount, FNBytes - FPos);
    if not Assigned(FBuffer) then
      _retval := 0
    else
    begin
      newPtr := FBuffer;
      Inc(newPtr, FPos);
      rv := aWriter(Self, aClosure, PChar(newPtr), FPos, readCount, _retval);
      if NS_SUCCEEDED(rv) then
        Inc(FPos, readCount);
    end;
  end;
  Result := NS_OK;
end;

function nsByteArrayInputStream.IsNonBlocking(out _retval: LongBool): Longword;
begin
  _retval := True;
  Result := NS_OK;
end;

function nsByteArrayInputStream.Close: Longword;
begin
  if Assigned(FBuffer) then
  begin
    nsMemory.Free(FBuffer);
    FBuffer := nil;
    FNBytes := 0;
    Result := NS_OK;
  end else
    Result := NS_ERROR_FAILURE;
end;

function NS_NewByteArrayInputStream(out stream: nsIInputStream; const Buffer: Pointer; Size: Longword): Longword;
begin
  try
    stream := nsByteArrayInputStream.Create(Buffer, Size);
  except
    Result := NS_ERROR_OUT_OF_MEMORY;
    Exit;
  end;

  Result := NS_OK;
end;

end.
