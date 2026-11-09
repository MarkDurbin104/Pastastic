unit Unit2;

interface

implementation

// -------------------------------------------------------------------------------
// Low level staff
{


>> Forum: borland.public.delphi.winapi

   >> Thread: Format a Disk with Delhpi: several O.S.

     >> Message 1 of 1




Subject:  Re: Format a Disk with Delhpi: several O.S.
Date: 01/28/1999
Author: (Steve Schafer (TeamB)) <pandeng@telepath.com>


 Save this thread


On Wed, 27 Jan 1999 11:01:42 -0500, "Leonar Narvaez"
<lnarvaez@delfin.udes.edu.co> wrote:

>Thanks Steve, but I don't know how to implement these functions, and i don't
>have this Guide, if you can send me a little sample code, i'll really
>appreciate it,

Here are some sample functions that show how to make IOCTL codes from a Win32 application. Actually using these functions to format tracks, etc., is left as an exercise for the reader. You need to have detailed knowledge of all of the low-level details of how disks work before you can successfully use these functions. There is plenty of information available in books and downloadable from the Internet to get you started.

type
  TDiocRegisters = record
    EBX, EDX, ECX, EAX, EDI, ESI, Flags: DWORD;
    end;
 
  TVWin32CtlCode = (ccNone, ccVWin32IntIoctl, ccVWin32Int26,
    ccVWin32Int25, ccVWin32Int13);
 
  TBiosParamBlock = packed record
    BytesPerSector: Word;
    SectorsPerCluster: Byte;
    ReservedSectors: Word;
    NumFats: Byte;
    NumRootEntries: Word;
    NumSectors: Word;
    MediaID: Byte;
    SectorsPerFat: Word;
    SectorsPerTrack: Word;
    NumHeads: Word;
    HiddenSectors: Word;
    Dummy1: Word;
    TotalSectors: LongInt;
    Dummy2: array[0..5] of Byte;
    end;
 
  TDeviceParamBlock = packed record
    Special: Byte;
    DeviceType: Byte;
    DeviceAttr: Word;
    NumCylinders: Word;
    MediaType: Byte;
    BiosParamBlock: TBiosParamBlock;
    end;

  TFormatParamBlock = packed record
    Reserved: Byte;
    Head: Word;
    Cylinder: Word;
    end;
 
function VWin32(CtlCode: TVWin32CtlCode; var Regs: TDiocRegisters): Boolean;
var
  hDevice: THandle;
  Count: DWORD;
begin
hDevice := CreateFile('\\.\VWIN32', 0, 0, nil, 0,
  FILE_FLAG_DELETE_ON_CLOSE, 0);
Result := DeviceIoControl(hDevice, Ord(CtlCode), @Regs, SizeOf(Regs),   @Regs, SizeOf(Regs), Count, nil);
CloseHandle(hDevice);
end;
 
function GetDeviceParamBlock(Drive: Char; 
  var ParamBlock: TDeviceParamBlock): Word;
var
  Regs: TDiocRegisters;
begin
with Regs do
  begin
  EAX := $440D;
  EBX := Ord(UpCase(Drive)) - Ord('@');
  ECX := $0860;
  EDX := LongInt(@ParamBlock);
  VWin32(ccVWin32IntIoctl, Regs);
  if (Flags and 1) <> 0 then
    Result := LoWord(EAX)
  else
    Result := 0;
  end;
end;
 
function SetDeviceParamBlock(Drive: Char; 
  var ParamBlock: TDeviceParamBlock): Word;
var
  Regs: TDiocRegisters;
begin
with Regs do
  begin
  EAX := $440D;
  EBX := Ord(UpCase(Drive)) - Ord('@');
  ECX := $0840;
  EDX := LongInt(@ParamBlock);
  VWin32(ccVWin32IntIoctl, Regs);
  if (Flags and 1) <> 0 then
    Result := LoWord(EAX)
  else
    Result := 0;
  end;
end;

function FormatTrack(Drive: Char;
  var ParamBlock: TFormatParamBlock): Word;
var
  Regs: TDiocRegisters;
begin
with Regs do
  begin
  EAX := $440D;
  EBX := Ord(UpCase(Drive)) - Ord('@');
  ECX := $0842;
  EDX := LongInt(@ParamBlock);
  VWin32(ccVWin32IntIoctl, Regs);
  if (Flags and 1) <> 0 then
    Result := LoWord(EAX)
  else
    Result := 0;
  end;
end;




}
// -------------------------------------------------------------------------------
{
GetDiskFreeSpaceEx Delphi 4

FreeClusters and TotalClusters returned by GetDiskFreeSpace
will be at most 65526 and the free space can never exceed
2,147,155,968 bytes.  This is a limitation of the Win32 API.
See GetDiskFreeSpaceEx.
FUNCTION FreeSpace(Drive: BYTE): Integer;
  VAR
    BytesPerCluster   : Integer;
    RootPath              : ARRAY[0..4] OF CHAR;
    RootPtr                : pChar;
    SectorsPerCluster:  DWORD ;    // for both D3 and D4
    BytesPerSector   :  DWORD;
    FreeClusters        :  DWORD;
    TotalClusters        :  DWORD;
BEGIN
  RootPtr := NIL;
  IF        Drive > 0
  THEN BEGIN
    StrCopy(RootPath, 'A:\');
    RootPath[0] := CHR(Drive + ORD('A') - 1);
    RootPtr := RootPath
  END;
  IF GetDiskFreeSpace(RootPtr, SectorsPerCluster, BytesPerSector,
                                     FreeClusters, TotalClusters)
  THEN BEGIN
    BytesPerCluster := SectorsPerCluster * BytesPerSector;

    RESULT := BytesPerCluster * FreeClusters
  END
  ELSE RESULT := -1
END {FreeSpace}


// -------------------------------------------------------------------------------
{
GetDiskFreeSpaceEx Delphi 4

FreeClusters and TotalClusters returned by GetDiskFreeSpace
will be at most 65526 and the free space can never exceed
2,147,155,968 bytes.  This is a limitation of the Win32 API.
See GetDiskFreeSpaceEx.
FUNCTION FreeSpace(Drive: BYTE): Integer;
  VAR
    BytesPerCluster   : Integer;
    RootPath              : ARRAY[0..4] OF CHAR;
    RootPtr                : pChar;
    SectorsPerCluster:  DWORD ;    // for both D3 and D4
    BytesPerSector   :  DWORD;
    FreeClusters        :  DWORD;
    TotalClusters        :  DWORD;
BEGIN
  RootPtr := NIL;
  IF        Drive > 0
  THEN BEGIN
    StrCopy(RootPath, 'A:\');
    RootPath[0] := CHR(Drive + ORD('A') - 1);
    RootPtr := RootPath
  END;
  IF GetDiskFreeSpace(RootPtr, SectorsPerCluster, BytesPerSector,
                                     FreeClusters, TotalClusters)
  THEN BEGIN
    BytesPerCluster := SectorsPerCluster * BytesPerSector;

    RESULT := BytesPerCluster * FreeClusters
  END
  ELSE RESULT := -1
END {FreeSpace}



// ----------------------------------------------------------------------------------------
//volumen
{
Rodrigo: quizas esto te sirva.

*-----------------------------------------------
FUNCTION GetVol(lpRoot)
*-----------------------------------------------
* Nuestra información del volumen
* USO: GetVol("C:\")
* PARAMETRO: lpRoot = LetraDrive + ":\"
*-----------------------------------------------
LOCAL lnRet, lcString, lpVolName, ;
  nVolSize, lpVolNumber, ;
  lpMaxComp, lpFlags, ;
  lpFSName, nFSSize

IF EMPTY(lpRoot)
  lpRoot = "d:\"
ENDIF
lpVolName = SPACE(256)
nVolSize = 256
lpVolNumber = 0
lpMaxComp = 256
lpFlags = 0
lpFSName = SPACE(256)
nFSSize = 256

DECLARE INTEGER GetVolumeInformation IN Win32API AS GetVolInfo ;   STRING  @lpRoot, ;
  STRING  @lpVolName, ;
  INTEGER nVolSize, ;
  INTEGER @lpVolNumber, ;
  INTEGER @lpMaxComp, ;
  INTEGER @lpFlags, ;
  STRING  @lpFSName, ;
  INTEGER nFSSize

lnRet=GetVolInfo(@lpRoot, @lpVolName, ;
  nVolSize, @lpVolNumber, ;
  @lpMaxComp, @lpFlags, ;
  @lpFSName, nFSSize)

IF lnRet > 0
  lcString = "Drive name: " + ;
    ALLT(lpRoot)+CHR(13)+ ;
    "Vol name: " + ;
    LEFT(ALLT(lpVolName),LEN(ALLT(lpVolName))-1)+CHR(13)+ ;
    "Max #/chars in vol name: " + ;
    ALLT(STR(nVolSize))+CHR(13)+ ;
    "Vol Serial #: " + ;
    ALLT(STR(lpVolNumber))+CHR(13)+ ;
    "Max #/chars in dir/file names: " + ;
    ALLT(STR(lpMaxComp))+CHR(13)+ ;
    "File Sys Flags: " + ;
    ALLT(STR(lpFlags))+CHR(13)+ ;
    "File Sys type: " + ;
    LEFT(ALLT(lpFSName),LEN(ALLT(lpFSName))-1)+CHR(13)+ ;
    "File Sys Name Size: " + ;
    ALLT(STR(nFSSize))
ELSE
  lcString = "No se pudo ver información"
ENDIF
=MESSAGEBOX(lcString, "Información del volumen")
RETURN ""
ENDFUNC
}


end.
