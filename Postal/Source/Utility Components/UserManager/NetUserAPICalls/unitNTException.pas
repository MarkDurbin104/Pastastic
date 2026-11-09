unit unitNTException;

interface

uses SysUtils;

type
  ENTException = class (Exception)
  private
    fCode : Integer;
    function GetError : string;
  public
    constructor Create (status : integer);
    constructor CreateLastError;
    property Code : Integer read fCode;
  end;

implementation

uses Windows;

function ENTException.GetError : string;
var
  msg : string;

  function GetErrorMessage (code : Integer) : string;
  var
    hErrLib : THandle;
    msg : PChar;
    flags : Integer;

    function MAKELANGID (p, s : word) : Integer;
    begin
      result := (s shl 10) or p
    end;

  begin
    hErrLib := LoadLibraryEx ('netmsg.dll', 0, LOAD_LIBRARY_AS_DATAFILE);

    try

      flags := FORMAT_MESSAGE_ALLOCATE_BUFFER or
               FORMAT_MESSAGE_IGNORE_INSERTS or
               FORMAT_MESSAGE_FROM_SYSTEM;

      if hErrLib <> 0 then
        flags := flags or FORMAT_MESSAGE_FROM_HMODULE;

      if FormatMessage (flags, pointer (hErrLib), code,
                        MAKELANGID (LANG_NEUTRAL, SUBLANG_DEFAULT),
                        PChar (@msg), 0, Nil) <> 0 then
        try
          result := msg;

        finally
          LocalFree (Integer (msg));
        end

    finally
      if hErrLib <> 0 then
        FreeLibrary (hErrLib)
    end
  end;

begin
  msg := GetErrorMessage (fCode);
  if msg = '' then
    result := Format ('Error %d', [fCode])
  else
    result := Format ('Error %d : %s', [fCode, msg])
end;

constructor ENTException.Create (status : Integer);
begin
  fCode := status;
  inherited Create (GetError);
end;

constructor ENTException.CreateLastError;
begin
  fCode := GetLastError;
  inherited Create (GetError)
end;

end.
