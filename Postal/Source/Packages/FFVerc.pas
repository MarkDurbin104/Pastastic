
// THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
// ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED
// TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.


// ANTS TFloppyFormat Delphi/C++ Builder Component
// Ver. 1.22
// © 1999 Alexander Turin (ANT Systems).


unit FFVerc;
interface

uses
  Windows;

{$IFDEF VER110}
  {$ObjExportAll On} // C++Builder 3+ requires this.
{$ENDIF}

const
  Vc2100: Boolean = True;
  Win95: Integer = 0;
  WinNT: Integer = 0;

function SetSecDDV: string;
procedure CheckCorrect;
function MDIOC(hDevice: THandle; dwIoControlCode: DWORD; lpInBuffer: Pointer;
  nInBufferSize: DWORD; lpOutBuffer: Pointer; nOutBufferSize: DWORD;
  lpBytesReturned: LPDWORD; lpOverlapped: Pointer): Boolean;

implementation

function MDeviceIoControl(hDevice: THandle; dwIoControlCode: DWORD; lpInBuffer: Pointer;
  nInBufferSize: DWORD; lpOutBuffer: Pointer; nOutBufferSize: DWORD;
  lpBytesReturned: LPDWORD; lpOverlapped: Pointer): LONGBOOL; stdcall;
  external kernel32 name 'DeviceIoControl';

const
  DDVS = 'TFloppyFormat V1.22. © 1999 Alexander Turin (http://hey.to/ants)';

procedure CheckCorrect;
begin
  // was used for shareware protection only
end;

function SetSecDDV: string;
begin
  Result:=DDVS;
end;

function MDIOC(hDevice: THandle; dwIoControlCode: DWORD; lpInBuffer: Pointer;
  nInBufferSize: DWORD; lpOutBuffer: Pointer; nOutBufferSize: DWORD;
  lpBytesReturned: LPDWORD; lpOverlapped: Pointer): Boolean;
begin
  Result:=MDeviceIoControl(hDevice, dwIoControlCode, lpInBuffer,
    nInBufferSize, lpOutBuffer, nOutBufferSize,
    lpBytesReturned, lpOverlapped);
end;

end.
