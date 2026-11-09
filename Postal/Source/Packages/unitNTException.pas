unit unitNTException;

interface

uses SysUtils;

type
  ENTException = class (Exception)
  public
    constructor Create (status : integer);
    constructor CreateLastError;
  end;

implementation

uses Windows;

function MAKELANGID (p, s : word) : Integer;
begin
  result := (s shl 10) or p
end;

function GetErrorMessage (code : Integer) : string;
var
  hErrLib : THandle;
  msg : PChar;
  flags : Integer;
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
                      @msg, 0, Nil) <> 0 then
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

constructor ENTException.Create (status : Integer);
var
  msg : string;
begin
  msg := GetErrorMessage (status);
  if msg = '' then
    inherited CreateFmt ('Error %d', [status])
  else
    inherited CreateFmt ('Error %d : %s', [status, msg])
end;

constructor ENTException.CreateLastError;
begin
  Create (GetLastError)
end;

end.
