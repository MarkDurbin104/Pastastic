
// THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
// ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED
// TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.


// ANTS TFloppyFormat Delphi/C++ Builder Component
// Ver. 1.22
// © 1999 Alexander Turin (ANT Systems).


unit FFormat;

{$DEFINE nDESIGN}

interface

uses
  Windows, Messages, SysUtils, Classes,  Forms, FFVerc;

{$IFNDEF DESIGN}
{$Y-}
{$D-}
{$L-}
{$C-}
{$ENDIF}
{$Q-}

{$IFDEF VER110}
  {$ObjExportAll On} // C++Builder 3+ requires this.
{$ENDIF}

type
  Efex = class(Exception)
    Ind: Integer;
    constructor CreateI(IndNo: Integer);
  end;

  DiskInformation = packed record
    BytesPerSector : Word;
    SectorsPerCluster : Byte;
    ReservedSectors : Word;
    FATs : Byte;
    RootDirectories : Word;
    TotalSectors : Word;
    MediaDescriptor : Byte;
    SectorsPerFAT : Word;
    SectorsPerTrack : Word;
    Heads : Word;
  end;

  TrackTableInformation = packed record
    Track : Byte;
    Head : Byte;
    Sector : Byte;
    SectorSizeCode : Byte;
  end;

const
  MaxSectorOnTrack = 18;
  MaxArrayValue = $10000;
  FloppySectorSize = 512;

type
  FormatParamBlock = packed record
    SpecialFunc : BYTE; // 05
    DeviceType : BYTE;  //00: 320K/360K; 01: 1.2 M; 02: 720 K; 05: Fixed; 07: 1.44 M
    DeviceAttr : WORD;  // $0002
    NumOfCyls : WORD;   // $0050  //80 tracks
    MediaType : BYTE;
    BPB : DiskInformation;
    HiddenSecs : WORD;
    HiddenSecsHi : WORD;
    BTotalSecs : WORD;
    BTotalSecsHi : WORD;
    BSecsPerFat : WORD;
    BSecsPerFatHi : WORD;
    ExtFlags : WORD;

    NumSecsPerTrack : WORD;
    PairsNumSizeSec : packed array[0..2*MaxSectorOnTrack-1] of WORD;
  end;

  BootInformation = packed record
    Name : array[1..8] of Char;
    DiskInfo : DiskInformation;
    HiddenSectors : LongInt;
    SecsInLogicalVol : LongInt;
    DriveNumber : Byte;
    Reserved : Byte;
    BootSignature : Byte;
    SerialNumber : LongInt;
    Volume : array[1..11] of Char;
    FatType : array[1..8] of Char;
  end;

  BootArray = array[1..FloppySectorSize] of Byte;
  TMediaType = (FUnknown,F360,F1200,F720,F1440);
  DiskInfoArray = array[TMediaType] of DiskInformation;
  TrackTableArray = array[1..MaxSectorOnTrack] of TrackTableInformation;
  TrackTablePtr = ^TrackTableArray;
  MaxArray = array[1..MaxArrayValue] of Byte;
  MaxArrayPtr = ^MaxArray;

  TDiskDrive = (DriveA,DriveB);
  TFormatCondition = (Always,Never,WhenNeeded);
  TSystemLocation = (DriveC,DriveD,DriveE,DriveF,DriveG,DriveH,DriveI,DriveJ,DriveK,DriveL,DriveM,
    DriveN,DriveO,DriveP,DriveQ,DriveR,DriveS,DriveT,DriveU,DriveV,DriveW,DriveX,DriveY,DriveZ);
  TRetries = 1..25;
  TVerify = (VerAlways,VerNever,VerWhenFormatting,VerOnly);
  StringEight = String[8];
  StringEleven = String[11];

  TFloppyFormat = class(TComponent)
  private
    { Published Properties }
    DDV: String;
    FSerialNumber: StringEight;
    FCustomSerNum: StringEight; //ShortString;
    SerNum: LongInt;
    FClearDisk: Boolean;
    FDrive: TDiskDrive;
    FFormatCondition: TFormatCondition;
    FMakeBootable: Boolean;
    FUseCustomSerNum: Boolean;
    FMediaType: TMediaType;
    FRetries: TRetries;
    FSystemLocation: TSystemLocation;
    FVerify: TVerify;
    FVolumeLabel: StringEleven;
    FOnBootWrite: TNotifyEvent;
    FOnFatWrite: TNotifyEvent;
    FOnRootWrite: TNotifyEvent;
    FOnSystemWrite: TNotifyEvent;
    FOnTrackFormat: TNotifyEvent;
    FOnVerify: TNotifyEvent;
    { RunTime Properties }
    FActive: Boolean;
    FDriveType: TMediaType;
    FErrNoMessage: String;
    FErrNo: Integer;
    FErrorMessage: String;
    FCurrentHead: Byte;
    FCurrentTrack: Byte;
    FHeads: Byte;
    FTracks: Byte;
    FSectors: Byte;
    FProgress: Integer;
    FFirstTracksOnly: Boolean;
    FDiskInDrive: Boolean;
    { Private variables }
    BootInfo: BootInformation;
    TrackTable: TrackTablePtr;
    procedure SetDDV(NewDDV: String);
    procedure SetVolLabel(LabelVal: StringEleven);
    function GetDiskHandle(ADrive: Byte): Boolean;
    function GetDeviceHandle: Boolean;
    procedure FreeHandle;
    function LockVolume(Drive: Byte): Boolean;
    function UnLockVolume(Drive: Byte): Boolean;
    function GetPermission(Drive: Byte): SmallInt;
    function SetMediaType(Drive, Tracks, Sectors: Byte): Integer;
//    function GetMediaType(Drive, Tracks, Sectors: Byte): Integer;
    function FormatATrack(Drive, Sectors, Track, Head, SectorSizeCode: Byte;
             TrackTable: TrackTablePtr): Integer;
    function VerifyTrack(Drive, Sectors, Track, Head: Byte): Integer;
    function WriteBoot(Drive: Byte; var Buffer: MaxArrayPtr): Integer;
    function WriteFats(Drive: Byte; var Buffer: MaxArrayPtr): Integer;
    function WriteRoot(Drive: Byte; Buffer: MaxArrayPtr): Integer;
    function WriteDisk(Drive, Head, Track, Sector, NumSecs: Byte; Buffer: Pointer): Integer;
    function ReadDisk(Drive, Head, Track, Sector: Byte; ReadBuffer: Pointer): Integer;
    function SetSerialNumber: LongInt;
    function MakeBootDisk(Drive: Char): Boolean;
    function CheckFormatConditions(Drive: Byte; var TempFormatCondition: TFormatCondition): Integer;
    function CompareMemory(Value1, Value2: MaxArrayPtr; Size: Integer): Integer;
    function GetBiosErrorMessage(ErrNo: Integer): string;
    function GetErrorMessage(Error: Integer): string;
    procedure DismountVolume(Drive: Byte);
    procedure SetCustomSerNum(Str8SerNum: StringEight);
    function RSNT(Drive: Byte; FirstSector, Sectors: Integer; Buffer: Pointer): Boolean;
    function WSNT(Drive: Byte; FirstSector, Sectors: Integer; Buffer: Pointer): Boolean;
    function VSNT(Drive: Byte; FirstSector, Sectors: Integer): Boolean;
    function WriteLogicalSector(Drive: Byte; LogicalSector: Integer; Buffer: Pointer): Integer;
    function ReadLogicalSector(Drive: Byte; LogicalSector: Integer; Buffer: Pointer): Integer;
    function ResetDrive(Drive: Byte) : Integer;
    function FGetDriveType: TMediaType;
    // end Private declarations
  protected
    { Protected declarations }
  public
    Cancel: Boolean;
    constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
    property IsActive: Boolean read FActive;
    property DriveType: TMediaType read FGetDriveType;
    property BiosErrorMessage: string read FErrnoMessage;
    property BiosErrorNo: Integer read FErrNo;
    property ErrorMessage: string read FErrorMessage;
    property CurrentHead: Byte read FCurrentHead;
    property CurrentTrack: Byte read FCurrentTrack;
    property Heads: Byte read FHeads;
    property Tracks: Byte read FTracks;
    property Sectors: Byte read FSectors;
    property SerialNumber: StringEight read FSerialNumber;
    property Progress: Integer read FProgress;
    function CopyFile(Source, Target: string): Boolean;
    property DiskInDrive: Boolean read FDiskInDrive write FDiskInDrive;
    function FormatDisk: Integer;
    function FormatTrack(Track, Head: Byte): Boolean;
    function PhysToLogical(Track, Head, PhysSector: Byte): Integer;
    function ReadSector(LogicalSector: Integer; Buffer: Pointer): Integer;
    function WriteSector(LogicalSector: Integer; Buffer: Pointer): Integer;
    function GetDriveType(Drive: Byte; var DriveType: Byte): Integer;
    // end Public declarations
  published
    property About: string read DDV write SetDDV;
    property VolumeLabel: StringEleven read FVolumeLabel write SetVolLabel;
    property DiskDrive: TDiskDrive read FDrive write FDrive default DriveA;
    property MakeBootable: Boolean read FMakeBootable write FMakeBootable default False;
    property CustomSerNum: StringEight read FCustomSerNum write SetCustomSerNum;
    property UseCustomSerNum: Boolean read FUseCustomSerNum write FUseCustomSerNum Default False;
    property MediaType: TMediaType read FMediaType write FMediaType default F1440;
    property Retries: TRetries read FRetries write FRetries default 5;
    property SystemLocation: TSystemLocation read FSystemLocation write FSystemLocation default DriveC;
    property Verify: TVerify read FVerify write FVerify default VerNever;
    property FormatCondition: TFormatCondition read FFormatCondition write FFormatCondition;
    property FirstTracksOnly: Boolean read FFirstTracksOnly write FFirstTracksOnly;
    property OnBootWrite: TNotifyEvent read FOnBootWrite write FOnBootWrite;
    property OnFatWrite: TNotifyEvent read FOnFatWrite write FOnFatWrite;
    property OnRootWrite: TNotifyEvent read FOnRootWrite write FOnRootWrite;
    property OnSystemWrite: TNotifyEvent read FOnSystemWrite write FOnSystemWrite;
    property OnTrackFormat: TNotifyEvent read FOnTrackFormat write FOnTrackFormat;
    property OnVerify: TNotifyEvent read FOnVerify write FOnVerify;
    // end Published declarations
  end;

procedure Register;

implementation

type
  TDiocRegisters = record    //DIOC_REGISTERS
    reg_EBX : DWORD;   // EBX register
    reg_EDX : DWORD;   // EDX register
    reg_ECX : DWORD;   // ECX register
    reg_EAX : DWORD;   // EAX register
    reg_EDI : DWORD;   // EDI register
    reg_ESI : DWORD;   // ESI register
    reg_Flags : DWORD; // Flags register
  end;

  TRegisters = packed record
    AX, BX, CX, DX, BP, SI, DI, DS, ES, Flags : DWORD;
    AL, AH, BL, BH, CL, CH, DL, DH : Byte;
  end;

  TMEDIA_TYPE = (
  Unknown,        // Format is unknown
    F5_1Pt2_512,    // 5.25", 1.2MB,  512 bytes/sector
    F3_1Pt44_512,   // 3.5",  1.44MB, 512 bytes/sector
    F3_2Pt88_512,   // 3.5",  2.88MB, 512 bytes/sector
    F3_20Pt8_512,   // 3.5",  20.8MB, 512 bytes/sector
    F3_720_512,     // 3.5",  720KB,  512 bytes/sector
    F5_360_512,     // 5.25", 360KB,  512 bytes/sector
    F5_320_512,     // 5.25", 320KB,  512 bytes/sector
    F5_320_1024,    // 5.25", 320KB,  1024 bytes/sector
    F5_180_512,     // 5.25", 180KB,  512 bytes/sector
    F5_160_512,     // 5.25", 160KB,  512 bytes/sector
    RemovableMedia, // Removable media other than floppy
    FixedMedia      // Fixed hard disk media
  );

  TDISK_GEOMETRY = packed record
    Cylinders : DWORD;
    Cylinders0 : DWORD;
    MediaType : TMEDIA_TYPE;
    MediaType0 : array[1..3] of Byte;
    TracksPerCylinder : DWORD;
    SectorsPerTrack : DWORD;
    BytesPerSector : DWORD;
  end;

  TFORMAT_PARAMETERS = packed record
    MediaType : TMEDIA_TYPE;
    MediaType0 : array[1..3] of Byte;
    StartCylinderNumber : DWORD;
    EndCylinderNumber : DWORD;
    StartHeadNumber : DWORD;
    EndHeadNumber : DWORD;
  end;

  TVERIFY_INFORMATION = packed record
    StartingOffset : DWORD;
    StartingOffset0 : DWORD;
    VerifyLength : DWORD;
    VerifyLength0 : DWORD;
  end;

Const
  hDevice: THandle = INVALID_HANDLE_VALUE;
  DiskHandle: THandle = INVALID_HANDLE_VALUE;
  NeedCloseHandle: Boolean = False;
  LockLevel: SmallInt = -1;
  Permission: SmallInt = -1;
  IOSYS: string[13] = '\IO.SYS';
  MSDOSSYS: string[13] = '\MSDOS.SYS';
  IBMBIOSYS: string[13] = '\IBMBIO.SYS';
  IBMDOSSYS: string[13] = '\IBMDOS.SYS';

  BootSector: BootArray = (
  $EB,$3C,$90,$28,$7E,$7C,$2F,$5A,$49,$48,$43,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20,$20,$20,$20,$20,
  $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,
  $FA,$33,
  $C9,$8E,$D1,$BC,$FC,$7B,$16,$07,$BD,$78,$00,$C5,$76,$00,$1E,$56,
  $16,$55,$BF,$22,$05,$89,$7E,$00,$89,$4E,$02,$B1,$0B,$FC,$F3,$A4,
  $06,$1F,$BD,$00,$7C,$C6,$45,$FE,$0F,$8B,$46,$18,$88,$45,$F9,$38,
  $4E,$24,$7D,$22,$8B,$C1,$99,$E8,$77,$01,$72,$1A,$83,$EB,$3A,$66,
  $A1,$1C,$7C,$66,$3B,$07,$8A,$57,$FC,$75,$06,$80,$CA,$02,$88,$56,
  $02,$80,$C3,$10,$73,$ED,$33,$C9,$8A,$46,$10,$98,$F7,$66,$16,$03,
  $46,$1C,$13,$56,$1E,$03,$46,$0E,$13,$D1,$8B,$76,$11,$60,$89,$46,
  $FC,$89,$56,$FE,$B8,$20,$00,$F7,$E6,$8B,$5E,$0B,$03,$C3,$48,$F7,
  $F3,$01,$46,$FC,$11,$4E,$FE,$61,$BF,$00,$07,$E8,$23,$01,$72,$39,
  $38,$2D,$74,$17,$60,$B1,$0B,$BE,$D8,$7D,$F3,$A6,$61,$74,$39,$4E,
  $74,$09,$83,$C7,$20,$3B,$FB,$72,$E7,$EB,$DD,$BE,$7F,$7D,$AC,$98,
  $03,$F0,$AC,$84,$C0,$74,$17,$3C,$FF,$74,$09,$B4,$0E,$BB,$07,$00,
  $CD,$10,$EB,$EE,$BE,$82,$7D,$EB,$E5,$BE,$80,$7D,$EB,$E0,$98,$CD,
  $16,$5E,$1F,$66,$8F,$04,$CD,$19,$BE,$81,$7D,$8B,$7D,$1A,$8D,$45,
  $FE,$8A,$4E,$0D,$F7,$E1,$03,$46,$FC,$13,$56,$FE,$B1,$04,$E8,$C1,
  $00,$72,$D6,$EA,$00,$02,$70,$00,$B4,$42,$EB,$2D,$60,$66,$6A,$00,
  $52,$50,$06,$53,$6A,$01,$6A,$10,$8B,$F4,$74,$EC,$91,$92,$33,$D2,
  $F7,$76,$18,$91,$F7,$76,$18,$42,$87,$CA,$F7,$76,$1A,$8A,$F2,$8A,
  $E8,$C0,$CC,$02,$0A,$CC,$B8,$01,$02,$8A,$56,$24,$CD,$13,$8D,$64,
  $10,$61,$72,$0A,$40,$75,$01,$42,$03,$5E,$0B,$49,$75,$77,$C3,$03,
  $18,$01,$27,$0D,$0A,$49,$6E,$76,$61,$6C,$69,$64,$20,$73,$79,$73,
  $74,$65,$6D,$20,$64,$69,$73,$6B,$FF,$0D,$0A,$44,$69,$73,$6B,$20,
  $49,$2F,$4F,$20,$65,$72,$72,$6F,$72,$FF,$0D,$0A,$52,$65,$70,$6C,
  $61,$63,$65,$20,$74,$68,$65,$20,$64,$69,$73,$6B,$2C,$20,$61,$6E,
  $64,$20,$74,$68,$65,$6E,$20,$70,$72,$65,$73,$73,$20,$61,$6E,$79,
  $20,$6B,$65,$79,$0D,$0A,$00,$00,$49,$4F,$20,$20,$20,$20,$20,$20,
  $53,$59,$53,$4D,$53,$44,$4F,$53,$20,$20,$20,$53,$59,$53,$7F,$01,
  $00,$41,$BB,$00,$07,$80,$7E,$02,$0E,$E9,$40,$FF,$00,$00,$55,$AA
  );

  DiskInfo: DiskInfoArray =
  (
  (BytesPerSector : 512; SectorsPerCluster : 1; ReservedSectors : 1; Fats : 2; RootDirectories : 224;
  TotalSectors : 2880; MediaDescriptor : $f0; SectorsPerFAT : 9; SectorsPerTrack : 18; Heads : 2),
  // Setup DiskInfo for a 360K
  (BytesPerSector : 512; SectorsPerCluster : 2; ReservedSectors : 1; Fats : 2; RootDirectories : 112;
  TotalSectors : 720; MediaDescriptor : $fd; SectorsPerFAT : 2; SectorsPerTrack : 9; Heads : 2),
  // Setup DiskInfo for a 1.2M
  (BytesPerSector : 512; SectorsPerCluster : 1; ReservedSectors : 1; Fats : 2; RootDirectories : 224;
  TotalSectors : 2400; MediaDescriptor : $f9; SectorsPerFAT : 7; SectorsPerTrack : 15; Heads : 2),
  // Setup DiskInfo for a 720K
  (BytesPerSector : 512; SectorsPerCluster : 2; ReservedSectors : 1; Fats : 2; RootDirectories : 112;
  TotalSectors : 1440; MediaDescriptor : $f9; SectorsPerFAT : 3; SectorsPerTrack : 9; Heads : 2),
  // Setup DiskInfo for a 1.4M
  (BytesPerSector : 512; SectorsPerCluster : 1; ReservedSectors : 1; Fats : 2; RootDirectories : 224;
  TotalSectors : 2880; MediaDescriptor : $f0; SectorsPerFAT : 9; SectorsPerTrack : 18; Heads : 2)
  );

procedure Register;
begin
//  RegisterComponents('ANTS', [TFloppyFormat]);
end;

constructor Efex.CreateI(IndNo: Integer);
begin
  Ind := IndNo;
end;

constructor TFloppyFormat.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDiskInDrive:=true;
  FirstTracksOnly:=false;
  FActive := False;
  FClearDisk := True;
  DiskDrive := DriveA;
  FormatCondition := Always;
  MakeBootable := False;
  MediaType := F1440;
  FSerialNumber := '        ';
  CustomSerNum := '12345678';
  UseCustomSerNum := False;
  Retries := 2;
  SystemLocation := DriveC;
  Verify := VerNever;
  Cancel := False;
  TrackTable := nil;
  SetDDV('');
  FVolumeLabel := 'NO NAME    ';
  if Vc2100 then begin
    Win95 := VER_PLATFORM_WIN32_WINDOWS;
    WinNT := VER_PLATFORM_WIN32_NT;
  end;
  FErrNo := 0;
  FErrNoMessage := 'OK';
  FErrorMessage := 'OK';
end;

Destructor TFloppyFormat.Destroy;
begin
  if TrackTable<>nil then FreeMem(TrackTable);
  FreeHandle;
  inherited Destroy;
end;

function TFloppyFormat.FGetDriveType: TMediaType;
var
  DrvByte: Byte;
begin
  if GetDriveType(Byte(DiskDrive), DrvByte)=0
  then // if no errors
    Result := TMediaType(DrvByte)
  else Result := FUnknown;
end;

procedure TFloppyFormat.SetVolLabel(LabelVal: StringEleven);
begin
  FVolumeLabel := AnsiUpperCase(LabelVal);
end;

procedure TFloppyFormat.SetDDV(NewDDV: String);
begin
  DDV := FFVerc.SetSecDDV;
end;

function TFloppyFormat.PhysToLogical(Track, Head, PhysSector: Byte): Integer;
{ For supported MediaTypes:
    Track in [0..79],
    Head in [0..1],
    Sector in [1..18].
  If logical sector is available with current MediaType,
  Result=Logical Sector Number, else Result=-1 }
begin
  if Head>(DiskInfo[FMediaType].Heads-1) then begin
    Result := -1;
  end else begin
    if PhysSector>DiskInfo[FMediaType].SectorsPerTrack then begin
      Result := -1;
    end else begin
      Result := Word(PhysSector)-1+
        Integer(Head)*DiskInfo[FMediaType].SectorsPerTrack+
        Integer(Track)*DiskInfo[FMediaType].SectorsPerTrack*
          DiskInfo[FMediaType].Heads;
    end;
  end;
  if Result>(DiskInfo[FMediaType].TotalSectors-1) then Result := -1;
end;

procedure Intr(IntNo: Byte; var Regs: TRegisters);
var
  reg: TDiocRegisters;
  Cb: DWORD;
begin
  reg.reg_EBX := Regs.BX;
  reg.reg_EDX := (Regs.DH shl 8) or Regs.DL;
  reg.reg_ECX := (Regs.CH shl 8) or Regs.CL;
  reg.reg_EAX := (Regs.AH shl 8) or Regs.AL;
  reg.reg_EDI := Regs.DI;
  reg.reg_ESI := Regs.SI;
  reg.reg_Flags := 1;

  if not MDIOC(hDevice,
      4, // VWIN32_DIOC_DOS_INT13
      @reg, SizeOf(reg),
      @reg, SizeOf(reg),
      @cb,  nil)    //cb=28
  then Regs.AH := $FF else begin
    if (reg.reg_Flags and 1)=1 then
      Regs.AH := Byte(reg.reg_EAX shr 8)
    else
      Regs.AH := 0;
    Regs.BL := Byte(reg.reg_EBX);
  end;
end;

function DosioGetExtendedError: Boolean;
var
  reg: TDiocRegisters;
  Cb: DWORD;
  fResult: Boolean;
begin
  if hDevice<>INVALID_HANDLE_VALUE then begin
    //========================================================
    reg.reg_EAX := $5900;
    reg.reg_EBX := 0;
    reg.reg_ECX := 0;
    reg.reg_EDX := 0;
    reg.reg_Flags := $0001;
    //========================================================
    fResult := MDIOC(hDevice,
             1, // VWIN32_DIOC_DOS_IOCTL
             @reg, SizeOf(reg),
             @reg, SizeOf(reg),
             @cb,  nil);
    Result := fResult and ((reg.reg_Flags mod 2)=0);
  end else Result := False;
end;

function DosioGetFormatInfo(var Regs: TRegisters): Boolean;
var
  reg: TDiocRegisters;
  Cb: DWORD;
  fResult: Boolean;
begin

  if hDevice<>INVALID_HANDLE_VALUE then begin
    //========================================================
    reg.reg_EAX := $440D;
    reg.reg_EBX := DWORD(Regs.dl)+1;
    reg.reg_ECX := $0860;
    reg.reg_EDX := Regs.dx;
    reg.reg_Flags := $0001;
    //========================================================
    fResult := MDIOC(hDevice,
             1, // VWIN32_DIOC_DOS_IOCTL
             @reg, SizeOf(reg),
             @reg, SizeOf(reg),
             @cb,  nil);
    Result := fResult and ((reg.reg_Flags mod 2)=0);
    Regs.AH := Byte(reg.reg_EAX);  // Last Error Number
  end else Result := False;
end;

function DosioSetFormatInfo(var Regs: TRegisters): Boolean;
var
  reg: TDiocRegisters;
  Cb: DWORD;
  fResult: Boolean;
begin

  if hDevice<>INVALID_HANDLE_VALUE then begin
    //========================================================
    reg.reg_EAX := $440D;
    reg.reg_EBX := DWORD(Regs.dl)+1;
    reg.reg_ECX := $0840;
    reg.reg_EDX := Regs.dx;
    reg.reg_Flags := $0001;
    //========================================================
    fResult := MDIOC(hDevice,
             1, // VWIN32_DIOC_DOS_IOCTL
             @reg, SizeOf(reg),
             @reg, SizeOf(reg),
             @cb,  nil);
    Result := fResult and ((reg.reg_Flags mod 2)=0);
    Regs.AH := Byte(reg.reg_EAX);  // Last Error Number
  end else Result := False;
end;

function TFloppyFormat.LockVolume(Drive: Byte): Boolean;
var
  reg: TDiocRegisters;
  Cb: DWORD;
begin
  if hDevice=INVALID_HANDLE_VALUE then
    NeedCloseHandle := GetDeviceHandle;
  if hDevice<>INVALID_HANDLE_VALUE then begin
    if Permission<4 then Permission := 4;
    if LockLevel<0 then Permission := 0;
    FillChar(reg,SizeOf(reg),0);
    //========================================================
    reg.reg_EAX := $440D;
    reg.reg_EBX := DWORD(Drive);
    reg.reg_ECX := $084B;  //Lock the physical volume
    reg.reg_EDX := Permission;
    reg.reg_Flags := $0001;
    //========================================================
    Result := MDIOC(hDevice,
            1, // VWIN32_DIOC_DOS_IOCTL
            @reg, sizeof(reg),
            @reg, sizeof(reg),
            @cb,  Nil);
    if Result then LockLevel := 0;
    if NeedCloseHandle then FreeHandle;
  end else Result := False;
end;

function TFloppyFormat.UnLockVolume(Drive: Byte): Boolean;
var
  reg: TDiocRegisters;
  Cb: DWORD;
begin
  if hDevice=INVALID_HANDLE_VALUE then
    NeedCloseHandle := GetDeviceHandle;

  if hDevice<>INVALID_HANDLE_VALUE then begin
    FillChar(reg,SizeOf(reg),0);
    //========================================================
    reg.reg_EAX := $440D;
    reg.reg_EBX := DWORD(Drive);
    reg.reg_ECX := $086B;  //Unlock the physical volume
    reg.reg_Flags := $0001;
    //========================================================
    Result := MDIOC(hDevice,
            1, // VWIN32_DIOC_DOS_IOCTL
            @reg, sizeof(reg),
            @reg, sizeof(reg),
            @cb,  Nil);
    if NeedCloseHandle then FreeHandle;
    if Permission>0 then begin
      Permission := 0;
    end else begin
      Permission := -1;
      LockLevel := -1;
    end;
  end else Result := False;
end;

function TFloppyFormat.GetPermission(Drive: Byte): SmallInt;
var
  reg: TDiocRegisters;
  Cb: DWORD;
begin
  if hDevice=INVALID_HANDLE_VALUE then
    NeedCloseHandle := GetDeviceHandle;

  if hDevice<>INVALID_HANDLE_VALUE then begin
    FillChar(reg,SizeOf(reg),0);
    //========================================================
    reg.reg_EAX := $440D; // VWIN32_DIOC_DOS_IOCTL
    reg.reg_EBX := DWORD(Drive)+1;
    reg.reg_ECX := $0870; //Current permission
    reg.reg_Flags := $0001;
    //========================================================
    if MDIOC(hDevice,
         1,
         @reg, sizeof(reg),
         @reg, sizeof(reg),
         @cb,  Nil) then begin
      LockLevel := SmallInt(reg.reg_EAX);
      if LockLevel=0 then Result := SmallInt(reg.reg_ECX) else Result := -1;
    end else Result := -1;
    if NeedCloseHandle then FreeHandle;
  end else Result := -1; //if hDevice=INVALID_HANDLE_VALUE
  Permission := Result;
end;

function TFloppyFormat.WriteSector(LogicalSector: Integer; Buffer: Pointer): Integer;
var TempDrive: Byte;
begin
  TempDrive := Ord(DiskDrive);
  CheckCorrect;
  if LogicalSector>(DiskInfo[FMediaType].TotalSectors-1) then begin
    Result := $FF;
    FErrorMessage := GetErrorMessage(18);
    FErrNo := Result;
    FErrNoMessage := GetBiosErrorMessage(FErrno);
    Exit;
  end else
    try
      if Win32Platform=Win95 then begin
        NeedCloseHandle := False;
        GetDeviceHandle;
        if hDevice=INVALID_HANDLE_VALUE then raise Efex.CreateI(16); // No Device Handle
        GetPermission(TempDrive);
        if (LockLevel>=0) or
           ((LockLevel<0) and not LockVolume(TempDrive))
        then raise Efex.CreateI(15); // Disk access violation
        if ((LockLevel=0) and not LockVolume(TempDrive))
        then raise Efex.CreateI(15); // Disk access violation
      end;

      Result := WriteLogicalSector(TempDrive, LogicalSector, Buffer);
      FErrNo := Result;
      FErrNoMessage := GetBiosErrorMessage(FErrno);

    except on EfexMes:Efex do Result := EfexMes.Ind;
    end; // try
  if Win32Platform=WinNT then begin
    DismountVolume(TempDrive);
  end else begin
    UnLockVolume(TempDrive);
    UnLockVolume(Ord(FDrive));
  end;
  FreeHandle;
  Application.ProcessMessages;
end;

function TFloppyFormat.ReadSector(LogicalSector: Integer; Buffer: Pointer): Integer;
begin
  Result := $FF;
  CheckCorrect;
  try
  {  if LogicalSector>(DiskInfo[FMediaType].TotalSectors-1) then begin
      Result := 18;
    end else begin }
      Result := ReadLogicalSector(Ord(DiskDrive), LogicalSector, Buffer);
      Application.ProcessMessages;
  {  end;}
  except;
  end; // try
  if Result=$80 then Exit;
  if (Result=0) or (Result=18) then FErrorMessage := GetErrorMessage(Result)
  else FErrorMessage := GetErrorMessage($FF);
  if Result=18 then FErrNo := $FF else FErrNo := Result;
  FErrNoMessage := GetBiosErrorMessage(FErrno);
end;

procedure TFloppyFormat.SetCustomSerNum(Str8SerNum: StringEight);
begin
  SerNum := StrToInt('$'+Str8SerNum);
  FCustomSerNum := Str8SerNum;
end;

procedure TFloppyFormat.DismountVolume(Drive: Byte);
var
  cb: DWORD;
begin
  if Win32Platform=WinNT then begin
    if DiskHandle=INVALID_HANDLE_VALUE then
      NeedCloseHandle := GetDiskHandle(Drive);

    if DiskHandle<>INVALID_HANDLE_VALUE then begin
      MDIOC(DiskHandle,
        $00090020, // FSCTL_DISMOUNT_VOLUME
        nil, 0,
        nil, 0,
        @cb,  nil);
    end; // if DiskHandle<>INVALID_HANDLE_VALUE
    if NeedCloseHandle then FreeHandle;
  end; // for Win NT
end;

function TFloppyFormat.FormatDisk: Integer;
var
  Buffer: MaxArrayPtr;
  CurTrack: Byte;
  CurHead: Byte;
  CurSector: Byte;
  SectorSizeCode: Byte;
  TempDriveType: Byte;
  TempFormatCondition: TFormatCondition;
  TempDrive: Byte;
  Retry: TRetries;
  MaxCurTrack: integer;
begin
  Buffer := nil;
  TrackTable := nil;
  TempDrive := Ord(FDrive);
  Result := 0;

  try
    if FActive then begin
      Result := 98;
      FErrorMessage := GetErrorMessage(Result);
      FErrNo := 0;
      GetBiosErrorMessage(FErrNo);
      FActive := False;
      exit;
    end;

    if ((Win32Platform=WinNT) and not GetDiskHandle(TempDrive)) then begin
      Result := 15;
      FErrorMessage := GetErrorMessage(Result);
      exit;
    end;

    try
      FActive := True;
      FProgress := 0;
      FErrNo := 0;
      Cancel := False;

      // Reset the Drive controller
      FErrNo := ResetDrive(TempDrive);
      if FErrNo<>0 then raise Efex.CreateI(1); // Reset failed

      if Win32Platform=Win95 then begin
        // if Windows 95
        // =================================
        NeedCloseHandle := False;
        GetDeviceHandle;
        if hDevice=INVALID_HANDLE_VALUE then raise Efex.CreateI(16); // No Device Handle
        GetPermission(TempDrive);
        if (LockLevel>=0) or
           ((LockLevel<0) and not LockVolume(TempDrive))
        then raise Efex.CreateI(15); // Disk access violation

        // Get Drive type
        try
          FErrNo := GetDriveType(TempDrive,TempDriveType);
        except; end;

        if FErrNo<>0 then FDriveType := FMediaType // if unable to get drive type
        else FDriveType := TMediaType(TempDriveType);

        if FDriveType<=F360 then raise Efex.CreateI(3); // No such drive

        if FDriveType>F1440 then raise Efex.CreateI(4); // Unknown drive type

        if ((LockLevel=0) and not LockVolume(TempDrive))
        then raise Efex.CreateI(15); // Disk access violation

      end else begin
        // if Windows NT
        // =================================
        if FMediaType<>FUnknown then begin
          FDriveType := FMediaType;
        end else raise Efex.CreateI(4); // Unknown drive type

      end; // if WinPlatform...

      TempFormatCondition := FFormatCondition;
      Result := CheckFormatConditions(TempDrive,TempFormatCondition);
      if Result<>0 then raise Efex.CreateI(Result);

      FTracks := DiskInfo[FMediaType].TotalSectors
        div DiskInfo[FMediaType].SectorsPerTrack
        div DiskInfo[FMediaType].Heads;
      FSectors := DiskInfo[FMediaType].SectorsPerTrack;
      FHeads := DiskInfo[FMediaType].Heads;

      FErrNo := SetMediaType(TempDrive,FTracks,FSectors);
      if FErrNo<>0 then raise Efex.CreateI(7); // Unable to set media type

      // Create TrackTable
      GetMem(TrackTable, SizeOf(TrackTableInformation)*FSectors);

      // Sector size code 0 = 128 bytes, 1=256 Bytes, 2=512 Bytes, 3=1024 Bytes }
      SectorSizeCode := 2;

      // Do this once
      for CurSector:=1 to FSectors do begin
        TrackTable^[CurSector].Sector := CurSector;
        TrackTable^[CurSector].SectorSizeCode := SectorSizeCode;
      end;

      // Here's where we Format the tracks
      if FirstTracksOnly then MaxCurTrack:=1
      else MaxCurTrack:=FTracks-1;

      for CurTrack:=0 to MaxCurTrack do begin
        FCurrentTrack := CurTrack;
        for CurHead:=0 to FHeads-1 do begin
          FCurrentHead := CurHead;

          FProgress := (100*(CurTrack*FHeads+CurHead+1)) div (FTracks*FHeads);

          if TempFormatCondition=Always then begin
            if Assigned(FOnTrackFormat) then FOnTrackFormat(Self);
            Application.ProcessMessages;
            if Cancel then break;

            if Verify<>VerOnly then begin
              FDiskInDrive:=true;
              for Retry:=1 to Retries do begin
                if FDiskInDrive then
                {!!!}   FErrNo := FormatATrack(TempDrive,FSectors,CurTrack,CurHead,SectorSizeCode,TrackTable);
                if (FErrNo<>0) and FDiskInDrive then
                  FErrNo := FormatATrack(TempDrive,FSectors,CurTrack,CurHead,SectorSizeCode,TrackTable);
                if FErrNo=0 then break;
                if FDiskInDrive then
                  SetMediaType(TempDrive,FTracks,FSectors);
              end; // for Retry
              if FErrNo<>0 then raise Efex.CreateI(8);
            end;

            // Verify for first track
            if FDiskInDrive then
            if (CurTrack=0) and (Verify<>VerOnly) then begin
              // Get space for sector
              GetMem(Buffer,DiskInfo[FMediaType].BytesPerSector);
              if ReadLogicalSector(TempDrive, 0, Buffer)<>0
              then raise Efex.CreateI(8);
              if WriteLogicalSector(TempDrive, 0, Buffer)<>0
              then raise Efex.CreateI(8);
              FreeMem(Buffer);
              Buffer := nil;
            end; // if CurTrack=0
          end; // if TempFormatCondition=Always

          if FDiskInDrive then
          if (Verify=VerAlways)
            or (Verify=VerOnly)
            or ((Verify=VerWhenFormatting)
                and (TempFormatCondition=Always)) then
          begin
            if Assigned(FOnVerify) then FOnVerify(Self);
            Application.ProcessMessages;
            if Cancel then break;

            FErrNo := VerifyTrack(TempDrive,FSectors,CurTrack,CurHead);
            if FErrNo<>0 then begin
              Result := 9;
              break;
            end;
          end;
        end;

        if Cancel then break;

        if FErrNo<>0 then	break;
      end;  // for CurTrack:=0 to FTracks-1

      if FDiskInDrive then
      if Verify<>VerOnly then
        if (not Cancel) and (FErrNo=0)
          and ((TempFormatCondition=Always)
          or ((TempFormatCondition in [Never,WhenNeeded]) and FClearDisk)) then
        begin
          // Get space for sector
          GetMem(Buffer,DiskInfo[FMediaType].BytesPerSector);

          if Assigned(FOnBootWrite) then FOnBootWrite(Self);
          Application.ProcessMessages;
          if not Cancel then begin
            FErrNo := WriteBoot(TempDrive,Buffer);
            if FErrNo=0 then begin
              if Assigned(FOnFatWrite) then FOnFatWrite(Self);
              Application.ProcessMessages;
              if not Cancel then begin
                FErrNo := WriteFats(TempDrive,Buffer);
                if FErrNo=0 then begin
                  if Assigned(FOnRootWrite) then FOnRootWrite(Self);
                  Application.ProcessMessages;
                  if not Cancel then begin
                    FErrNo := WriteRoot(TempDrive,Buffer);
                    if FErrNo<>0 then Result := 12;
                  end;
                end	else begin
                  Result := 11;
                end;
              end;
            end else begin
              Result := 10;
            end;
          end;

        end;

      if Cancel then Result := 99;

      // Format finally
      // =============================================
    except on EfexMes:Efex do Result := EfexMes.Ind;
    end; // try
    FErrorMessage := GetErrorMessage(Result);
    if Buffer<>nil then FreeMem(Buffer);
    if TrackTable<>nil then FreeMem(TrackTable);
    TrackTable := nil;
    FActive := False;
    if Win32Platform=WinNT then begin
      DismountVolume(TempDrive);
    end else begin
      UnLockVolume(TempDrive);
      UnLockVolume(TempDrive);
    end;

    FreeHandle;
    ResetDrive(TempDrive);

    if (FErrNo=0) and (not Cancel) and FMakeBootable then
    begin
      if Assigned(FOnSystemWrite) then FOnSystemWrite(Self);
      Application.ProcessMessages;
      if not Cancel then begin
        if MakeBootDisk(Char(Integer('A')+TempDrive)) then FErrNo := 0 else FErrNo := 1;
        if FErrNo<>0 then Result := 13;
        FErrorMessage := GetErrorMessage(Result);
      end;
    end;

    if (Result<>0) and (Result<99) and (FErrNo=0) then FErrNo := $FF;
    FErrNoMessage := GetBiosErrorMessage(FErrNo);

  except;
  end; // try
  FirstTracksOnly:=false;
end; // FormatDisk

function TFloppyFormat.ResetDrive(Drive : Byte) : Integer;
var
  Retry: Integer;
  Regs: TRegisters;
begin
  Result := $FF;
  if Win32Platform=Win95 then begin
    if hDevice=INVALID_HANDLE_VALUE then
      NeedCloseHandle := GetDeviceHandle;
    if hDevice<>INVALID_HANDLE_VALUE then begin
      for Retry:=1 to Retries do begin
        FillChar(Regs,SizeOf(Regs),0);
        Regs.ah := 0;
        Regs.dl := Drive;
        Intr($13,Regs);
        Result := Regs.ah;
        DosioGetExtendedError;
        if Result=0 then break;
      end;
    end else Result := $FF;
    if NeedCloseHandle then FreeHandle;
  end else Result := 0;
end;

function TFloppyFormat.GetDriveType(Drive: Byte; var DriveType: Byte): Integer;
var
  Regs: TRegisters;
  fResult: Boolean;
  DiskGeometry: TDISK_GEOMETRY;
  cb: DWORD;
begin
  Result := $FF;
  if Win32Platform=Win95 then begin
    if hDevice=INVALID_HANDLE_VALUE then
      NeedCloseHandle := GetDeviceHandle;
    if hDevice<>INVALID_HANDLE_VALUE then begin
      FillChar(Regs,SizeOf(Regs),0);
      Regs.ah := $8;
      Regs.dl := Drive;
      Intr($13,Regs);
      Result := Regs.ah;
      if Result=0 then
        DriveType := Regs.bl
      else
        DriveType := 0;
    end else DriveType := 0; // if hDevice=INVALID_HANDLE_VALUE
    if NeedCloseHandle then FreeHandle;
  end else
    if Win32Platform=WinNT then begin
      if DiskHandle=INVALID_HANDLE_VALUE then
        NeedCloseHandle := GetDiskHandle(Drive);

      if DiskHandle<>INVALID_HANDLE_VALUE then begin
        fResult := MDIOC(DiskHandle,
          $00070000,  //IOCTL_DISK_GET_DRIVE_GEOMETRY
          nil, 0,
          @DiskGeometry,
          SizeOf(DiskGeometry),
          @cb,  nil);
      end  else fResult := False;  // if DiskHandle<>INVALID_HANDLE_VALUE
      if NeedCloseHandle then FreeHandle;

      if fResult then begin
        case DiskGeometry.MediaType of
          F5_1Pt2_512  : DriveType := 2; //5.25", 1.2MB
          F3_1Pt44_512 : DriveType := 4; //3.5",  1.44MB
          F3_720_512   : DriveType := 3; //3.5",  720KB
          F5_360_512   : DriveType := 1; //5.25", 360KB
        else DriveType := 0;
        end;
        Result := 0;
      end else begin
        DriveType := 0;
        Result := $FF;
      end; // if fResult else
    end; // if WinPlatform=WinNT
end;

function TFloppyFormat.SetMediaType(Drive ,Tracks, Sectors: Byte): Integer;
var
  Retry: Integer;
  Regs: TRegisters;
  FormatBlock: FormatParamBlock;
  i: Integer;
begin
  Result := $FF;
  if Win32Platform=Win95 then begin
    FillChar(FormatBlock,SizeOf(FormatBlock),0);
    with FormatBlock do begin
      BPB := DiskInfo[FMediaType];
      SpecialFunc := 5;
      case FMediaType of
        F360:  DeviceType := 0;
        F1200: DeviceType := 1;
        F720:  DeviceType := 2;
      else
        DeviceType := 7;
      end; //case
      DeviceAttr := 2;
      NumOfCyls := BPB.TotalSectors div (BPB.SectorsPerTrack * BPB.Heads);
      MediaType := BPB.MediaDescriptor;
      NumSecsPerTrack := BPB.SectorsPerTrack;
      for i := 1 to NumSecsPerTrack do begin
        PairsNumSizeSec[(i-1)*2] := i;
        PairsNumSizeSec[i*2-1] := $0200;
      end; // for
    end; // with FormatBlock

      Regs.dl := Drive;
      Regs.dx := DWORD(@FormatBlock);

    for Retry:=1 to Retries do begin
      Regs.dl := Drive;
      Regs.dx := DWORD(@FormatBlock);
      if DosioSetFormatInfo(Regs) then Result := 0 else Result := $FF;
    end;
  end else Result := 0;
end;

function TFloppyFormat.GetDiskHandle(ADrive: Byte): Boolean;
begin
  if DiskHandle=INVALID_HANDLE_VALUE then begin
    SetErrorMode(SEM_FAILCRITICALERRORS);
    DiskHandle := CreateFile(PChar('\\.\'+Char(Ord('A')+ADrive)+':'),
                GENERIC_READ or GENERIC_WRITE,
                FILE_SHARE_READ or FILE_SHARE_WRITE,
                nil, OPEN_EXISTING, 0, 0);
    SetErrorMode(SEM_NOALIGNMENTFAULTEXCEPT);
  end;
  Result := DiskHandle<>INVALID_HANDLE_VALUE;
end;

function TFloppyFormat.GetDeviceHandle: Boolean;
begin
  if hDevice=INVALID_HANDLE_VALUE then begin
    SetErrorMode(SEM_FAILCRITICALERRORS);
    hDevice := CreateFile('\\.\vwin32',
             GENERIC_READ or GENERIC_WRITE,
             FILE_SHARE_READ or FILE_SHARE_WRITE,
             nil, OPEN_EXISTING, 0, 0);
    SetErrorMode(SEM_NOALIGNMENTFAULTEXCEPT);
  end;
  Result := hDevice<>INVALID_HANDLE_VALUE;
end;

procedure TFloppyFormat.FreeHandle;
begin
  if DiskHandle<>INVALID_HANDLE_VALUE then CloseHandle(DiskHandle);
  if hDevice<>INVALID_HANDLE_VALUE then CloseHandle(hDevice);
  NeedCloseHandle := False;
  DiskHandle := INVALID_HANDLE_VALUE;
  hDevice := INVALID_HANDLE_VALUE;
end;

function TFloppyFormat.FormatTrack(Track, Head: Byte): Boolean;
var
  Retry: TRetries;
  TempDrive: Byte;
  SectorSizeCode: Byte;
  CurSector: Byte;
  Res: Integer;
begin
  TrackTable := nil;
  Res := 0;

  if FActive then begin
    FErrorMessage := GetErrorMessage(98);
    Result := False;
    exit;
  end;

  CheckCorrect;
  FActive := True;
  TempDrive := Ord(DiskDrive);
  FTracks := DiskInfo[FMediaType].TotalSectors
    div DiskInfo[FMediaType].SectorsPerTrack
    div DiskInfo[FMediaType].Heads;
  FSectors := DiskInfo[FMediaType].SectorsPerTrack;
  FHeads := DiskInfo[FMediaType].Heads;

  try
    // Reset the Drive controller
    FErrNo := ResetDrive(TempDrive);
    if FErrNo<>0 then raise Efex.CreateI(1); // Reset failed

    if Win32Platform=Win95 then begin
      // if Windows 95
      // =================================
      NeedCloseHandle := False;
      GetDeviceHandle;
      if hDevice=INVALID_HANDLE_VALUE then raise Efex.CreateI(16); // No Device Handle

      if FMediaType<>FUnknown then begin
        FDriveType := FMediaType;
      end else raise Efex.CreateI(4); // Unknown drive type

      GetPermission(TempDrive);
      if (LockLevel>=0) or
         ((LockLevel<0) and not LockVolume(TempDrive))
      then raise Efex.CreateI(15); // Disk access violation

      if ((LockLevel=0) and not LockVolume(TempDrive))
      then raise Efex.CreateI(15); // Disk access violation

    end else begin
      // if Windows NT
      // =================================
      NeedCloseHandle := False;
      GetDiskHandle(TempDrive);
      if DiskHandle=INVALID_HANDLE_VALUE then raise Efex.CreateI(16); // No Device Handle
      if FMediaType<>FUnknown then begin
        FDriveType := FMediaType;
      end else raise Efex.CreateI(4); // Unknown drive type

    end; // if WinPlatform...

    FErrNo := SetMediaType(TempDrive,FTracks,FSectors);
    if FErrNo<>0 then raise Efex.CreateI(7); // Unable to set media type

    if Head>(FHeads-1) then raise Efex.CreateI(19); // Track does not exist
    if Track>(FTracks-1) then raise Efex.CreateI(19);

    // Create TrackTable
    GetMem(TrackTable, SizeOf(TrackTableInformation)*FSectors);

    // Sector size code 0 = 128 bytes, 1=256 Bytes, 2=512 Bytes, 3=1024 Bytes }
    SectorSizeCode := 2;

    for CurSector:=1 to FSectors do begin
      TrackTable^[CurSector].Sector := CurSector;
      TrackTable^[CurSector].SectorSizeCode := SectorSizeCode;
    end;


    for Retry:=1 to Retries do begin
      FErrNo := FormatATrack(TempDrive,FSectors,Track,Head,SectorSizeCode,TrackTable);
    end; // for Retry
    if FErrNo<>0 then raise Efex.CreateI(8);

  except on EfexMes:Efex do Res := EfexMes.Ind;
  end; // try
  FErrorMessage := GetErrorMessage(Res);
  if TrackTable<>nil then FreeMem(TrackTable);
  TrackTable := nil;
  FActive := False;
  if Win32Platform=WinNT then begin
    DismountVolume(TempDrive);
  end else begin
  UnLockVolume(TempDrive);
  UnLockVolume(Ord(FDrive));
  end;
  if (Res<>0) and (Res<99) and (FErrNo=0) then FErrNo := $FF;
  FErrNoMessage := GetBiosErrorMessage(FErrNo);
  Result := (Res=0) and (FErrNo=0);

  FreeHandle;
  ResetDrive(TempDrive);
end;

function TFloppyFormat.FormatATrack(Drive, Sectors, Track,
         Head, SectorSizeCode: Byte; TrackTable: TrackTablePtr): Integer;
var
  Retry: Integer;
  Regs: TRegisters;
  CurSector: Byte;
  FORMAT_PARAMETERS: TFORMAT_PARAMETERS;
  fResult: LongBool;
  cb: DWORD;
begin
  if Win32Platform=Win95 then begin
    Result := $FF;
    if TrackTable=nil then exit;
    if hDevice<>INVALID_HANDLE_VALUE then begin
      for CurSector:=1 to Sectors do begin
        TrackTable^[CurSector].Track := Track;
        TrackTable^[CurSector].Head := Head;
      end;

      for Retry:=1 to Retries do begin
        FillChar(Regs,SizeOf(Regs),0);
        Regs.ah := $5;
        Regs.al := Sectors;
        Regs.ch := Track;
        Regs.dh := Head;
        Regs.bx := DWORD(TrackTable);
        Regs.dl := Drive;
        if Regs.dl<=1 then
          intr($13,Regs);
        Result := Regs.ah;
        if Result=0 then break;
      end; // for Retry
      FDiskInDrive:=Result<>$80;
    end else Result := $FF; // hDevice=INVALID_HANDLE_VALUE

  end else
    if Win32Platform=WinNT then begin
      with FORMAT_PARAMETERS do begin
        case Ord(FDriveType) of
          1: MediaType := F5_360_512;
          2: MediaType := F5_1Pt2_512;
          3: MediaType := F3_720_512;
          4: MediaType := F3_1Pt44_512;
        else MediaType := F3_1Pt44_512;
        end; // case
        MediaType0[1] := 0; MediaType0[2] := 0; MediaType0[3] := 0;

        StartCylinderNumber := Track;
        EndCylinderNumber := Track;
        StartHeadNumber := Head;
        EndHeadNumber := Head;
      end; // with FORMAT_PARAMETERS

      if DiskHandle<>INVALID_HANDLE_VALUE then begin
        fResult := True;

        fResult := fResult and MDIOC(DiskHandle,
          $0007C018,  //IOCTL_DISK_FORMAT_TRACKS
          @FORMAT_PARAMETERS,
          SizeOf(FORMAT_PARAMETERS),
          nil, 0,
          @cb,  nil);

        if fResult then Result := 0 else Result := $FF;
      end   // if DiskHandle<>INVALID_HANDLE_VALUE
      else Result := $FF;
    end else Result := $FF;
end;

function TFloppyFormat.VerifyTrack(Drive, Sectors, Track, Head: Byte): Integer;
var
  Retry: Integer;
  Regs: TRegisters;
  FirstSector: Word;
begin
  Result := $FF;
  if Win32Platform=Win95 then begin
    if hDevice=INVALID_HANDLE_VALUE then
      NeedCloseHandle := GetDeviceHandle;
    if hDevice<>INVALID_HANDLE_VALUE then begin
      for Retry:=1 to Retries do begin
        FillChar(Regs,SizeOf(Regs),0);
        Regs.ah := $4;
        Regs.al := Sectors;
        Regs.cl := 1;
        Regs.ch := Track;
        Regs.dh := Head;
        Regs.dl := Drive;
        intr($13,Regs);
        Result := Regs.ah;
        if Result=0 then break;
      end;
    end else Result := $FF; // if hDevice=INVALID_HANDLE_VALUE
    if NeedCloseHandle then FreeHandle;

  end else
    if Win32Platform=WinNT then begin
      with DiskInfo[FMediaType] do
        FirstSector := Head*SectorsPerTrack+Track*SectorsPerTrack*Heads;
      if VSNT(Drive, FirstSector, Sectors) then Result := 0 else Result := $FF;
    end else Result := 0;
end;

function TFloppyFormat.WriteBoot(Drive: Byte; var Buffer: MaxArrayPtr): Integer;
var i: Integer;
begin
  // Move our 512 byte sector into complete sector
  Move(BootSector,Buffer^,FloppySectorSize);

  // Fill Remainder with zeros
  FillChar(Buffer^[SizeOf(BootSector)+3],DiskInfo[FMediaType].BytesPerSector-SizeOf(BootSector),0);

  // But signature at the end
  Buffer^[DiskInfo[FMediaType].BytesPerSector-1] := $55;
  Buffer^[DiskInfo[FMediaType].BytesPerSector] := $AA;

  // Setup BootInfo
  FillChar(BootInfo,SizeOf(BootInfo),0);
  BootInfo.DiskInfo := DiskInfo[FMediaType];
  BootInfo.BootSignature := $29;
  BootInfo.SerialNumber := SetSerialNumber;
  BootInfo.FatType := 'FAT12   ';

  // Put name of format
  BootInfo.Name := 'Floppy  ';

  // Put Volume Id }
  FillChar(BootInfo.Volume,SizeOf(BootInfo.Volume),' ');
  if Length(FVolumeLabel)>0 then begin
    BootInfo.Volume := '           ';
    for i:=1 to Length(FVolumeLabel) do
      BootInfo.Volume[i] := FVolumeLabel[i];
  end else
    BootInfo.Volume := 'NO NAME    ';

  // Put BootInfo into complete boot sector info
  Move(BootInfo,Buffer^[4],SizeOf(BootInfo));

  // Write out complete sector
  Result := WriteLogicalSector(Drive,0,Buffer);
  if Result=0 then FSerialNumber := IntToHex(BootInfo.SerialNumber,8);
end;

function TFloppyFormat.WriteFats(Drive: Byte; var Buffer: MaxArrayPtr): Integer;
var
  Fat: Byte;
  SecInFat: Byte;
  LogicalSector, SectorOffset: Integer;
  NeedMem: Integer;
  Buf: MaxArrayPtr;
  Offset: Integer;

  procedure PutInfoInFatSectors;
  begin
    with DiskInfo[FMediaType] do begin
      // Clear Buffer
      FillChar(Buffer^,BytesPerSector,0);
      if SecInFat=1 then begin
        Buffer^[1] := MediaDescriptor;
        Buffer^[2] := $ff;
        Buffer^[3] := Buffer^[2];
      end;
    end;
  end; // procedure PutInfoInFatSectors

begin  // function TFloppyFormat.WriteFats
  Result := $FF;
  with DiskInfo[FMediaType] do begin
    if Win32Platform=Win95 then begin
      for Fat:=1 to Fats do begin
        // Write as many sectors needed for each fat
        for SecInFat:=1 to SectorsPerFat do begin
          PutInfoInFatSectors;
          LogicalSector := ReservedSectors+((Fat-1)*SectorsPerFat)+(SecInFat-1);
          Result := WriteLogicalSector(Drive,LogicalSector,Buffer);
          if Result<>0 then exit;
        end; // for SecInFat
      end; // for Fat
    end else

      if Win32Platform=WinNT then begin
        NeedMem := SectorsPerFat*Fats*DiskInfo[FMediaType].BytesPerSector;
        GetMem(Buf,NeedMem);
        try
          for Fat:=1 to Fats do begin
            // Write as many sectors needed for each fat
            for SecInFat:=1 to SectorsPerFat do begin
              PutInfoInFatSectors;
              SectorOffset := (Fat-1)*SectorsPerFat+(SecInFat-1);
              Offset := SectorOffset*DiskInfo[FMediaType].BytesPerSector+1;
              Move(Buffer^[1],Buf^[Offset],DiskInfo[FMediaType].BytesPerSector);
            end; // for SecInFat
          end; // for Fat
          if WSNT(Drive,ReservedSectors,SectorsPerFat*Fats,Buf)
          then Result := 0 else Result := $FF;
        finally
          FreeMem(Buf);
        end;
      end // if WinPlatform=WinNT
      else Result := $FF;
  end; // with DiskInfo
end;

function TFloppyFormat.WriteRoot(Drive: Byte; Buffer: MaxArrayPtr): Integer;
var
  StartSector: Integer;
  EndSector: Integer;
  NeedMem: Integer;
  LogicalSector: Integer;
  FileTime: LongInt;
  Offset: Integer;
  Buf: MaxArrayPtr;

  procedure PutInfoInRootSectors;
  var i, LengthFVolumeLabel: Integer;
  begin
    with DiskInfo[FMediaType] do begin
      FillChar(Buffer^,BytesPerSector,0);
      LengthFVolumeLabel := Length(FVolumeLabel);
      if (LogicalSector=StartSector) and (LengthFVolumeLabel>0) then
      begin // DiskLabel
        if not FMakeBootable then Offset := 0
        else Offset := 32*3; // Leave Room for System
        for i:=1 to LengthFVolumeLabel do
          Buffer^[Offset+i] := Byte(FVolumeLabel[i]);
        for i:=LengthFVolumeLabel+1 to 11 do
          Buffer^[Offset+i] := Byte(' ');
        Buffer^[Offset+12] := $28;  // File Attribute
        FileTime := SysUtils.DateTimeToFileDate(SysUtils.Now);
        Move(FileTime,Buffer^[Offset+23],SizeOf(LongInt));
      end; // DiskLabel
    end; // with DiskInfo
  end; // procedure PutInfoInRootSectors

begin  // function TFloppyFormat.WriteRoot
  Result := $FF;
  with DiskInfo[FMediaType] do begin
    StartSector := ReservedSectors + Fats * SectorsPerFat;
    EndSector := (RootDirectories * 32) div BytesPerSector + StartSector;
    if Win32Platform=Win95 then begin
      for LogicalSector:=StartSector to EndSector do begin
        PutInfoInRootSectors;
        Result := WriteLogicalSector(Drive,LogicalSector,Buffer);
        if Result<>0 then exit;
      end; // for LogicalSector
    end else

      if Win32Platform=WinNT then begin
        NeedMem := (EndSector-StartSector+1)*DiskInfo[FMediaType].BytesPerSector;
        GetMem(Buf,NeedMem);
        try
          for LogicalSector:=StartSector to EndSector do begin
            PutInfoInRootSectors;
            Offset := (LogicalSector-StartSector)*DiskInfo[FMediaType].BytesPerSector+1;
            Move(Buffer^[1],Buf^[Offset],DiskInfo[FMediaType].BytesPerSector);
          end; // for LogicalSector
          if WSNT(Drive,StartSector,EndSector-StartSector+1,Buf)
          then Result := 0 else Result := $FF;
        finally
          FreeMem(Buf);
        end;
      end // if WinPlatform=WinNT
      else Result := $FF;
  end;
end;

function TFloppyFormat.WriteDisk(Drive: Byte; Head: Byte; Track: Byte;
         Sector: Byte; NumSecs: Byte; Buffer: Pointer): Integer;
var
  Retry: Integer;
  Regs: TRegisters;
begin
  Result := $FF;
  if hDevice=INVALID_HANDLE_VALUE then
    NeedCloseHandle := GetDeviceHandle;
  if hDevice<>INVALID_HANDLE_VALUE then begin
    for Retry:=1 to Retries do begin
      FillChar(Regs,SizeOf(Regs),0);
      Regs.ah := $3;
      Regs.al := NumSecs;
      Regs.cl := Sector;
      Regs.ch := Track;
      Regs.dh := Head;
      Regs.bx := DWORD(Buffer);
      Regs.dl := Drive;
      if Regs.dl<=1 then // floppy
        intr($13,Regs);
      Result := Regs.ah;
      if Result=0 then break;
      ResetDrive(Drive);
    end;
  end else Result := $FF; // if hDevice=INVALID_HANDLE_VALUE
  if NeedCloseHandle then FreeHandle;
end;

function TFloppyFormat.WriteLogicalSector(Drive: Byte;
         LogicalSector: Integer; Buffer: Pointer): Integer;
var
  Head, Track, Sector: Byte;
begin
  with DiskInfo[FMediaType] do begin
    if Win32Platform=Win95 then begin
      Head := (LogicalSector div SectorsPerTrack) mod Heads;
      Track := (LogicalSector div SectorsPerTrack) div Heads;
      Sector := (LogicalSector mod SectorsPerTrack) + 1;
      Result := WriteDisk(Drive, Head, Track, Sector, 1, Buffer);
    end else
      if Win32Platform=WinNT then begin
        if WSNT(Drive, LogicalSector, 1, Buffer) then Result := 0
        else Result := $FF;
      end else Result := $FF;
  end;
end;

function TFloppyFormat.ReadLogicalSector(Drive: Byte;
                  LogicalSector: Integer;
                  Buffer: Pointer): Integer;
var
  Head, Track, Sector: Byte;
begin
  try
    with DiskInfo[FMediaType] do begin
      if Win32Platform=Win95 then begin
        Head := (LogicalSector div SectorsPerTrack) mod Heads;
        Track := (LogicalSector div SectorsPerTrack) div Heads;
        Sector := (LogicalSector mod SectorsPerTrack) + 1;
        Result := ReadDisk(Drive, Head, Track, Sector, Buffer);
      end else
        if Win32Platform=WinNT then begin
          if RSNT(Drive, LogicalSector, 1, Buffer) then Result := 0
          else Result := $FF;
        end else Result := $FF;
    end;
  except Result := $FF;
  end; // try
end;

function TFloppyFormat.ReadDisk(Drive, Head, Track, Sector: Byte;
         ReadBuffer: Pointer): Integer;
var
  Retry: Integer;
  Regs: TRegisters;
begin
  Result := $FF;
  if hDevice=INVALID_HANDLE_VALUE then
    NeedCloseHandle := GetDeviceHandle;
  if hDevice<>INVALID_HANDLE_VALUE then begin
    for Retry:=1 to Retries do begin
      FillChar(Regs,SizeOf(Regs),0);
      Regs.ah := $2;
      Regs.al := 1;  //Num Secs
      Regs.cl := Sector;
      Regs.ch := Track;
      Regs.dh := Head;
      Regs.bx := DWORD(ReadBuffer);
      Regs.dl := Drive;
      intr($13,Regs);
      Result := Regs.ah;
      if Result=0 then break;
      ResetDrive(Drive);
    end;
  end else Result := $FF; // if hDevice=INVALID_HANDLE_VALUE
  if NeedCloseHandle then FreeHandle;
end;

function TFloppyFormat.SetSerialNumber : LongInt;
var
  Year, Month, Day: Word;
  Hour, Min, Sec, MSec: Word;
  SerialNumber1, SerialNumber2: SmallInt;
begin
  if UseCustomSerNum {and (FCustomSerNum<>'')} then
    Result := SerNum
  else begin
    SysUtils.DecodeDate(SysUtils.Date,Year,Month,Day);
    SysUtils.DecodeTime(SysUtils.Time,Hour,Min,Sec,MSec);
    SerialNumber1 := Year + ((Hour shl 8) or Min);
    SerialNumber2 := ((Month shl 8) or Day) + ((Sec shl 8)or MSec);
    Result := (LongInt(SerialNumber1) shl $10) + SerialNumber2;
  end;
end;

function TFloppyFormat.MakeBootDisk(Drive: Char):Boolean;
var
  VarPChar: PChar;

  FileName: String[13];
  Source: String;
  Dest: String;
begin
  // Lets Remove any system file that may exist
  Dest := Drive + ':' + IOSYS;
  FileSetAttr(Dest,0);
  SysUtils.DeleteFile(Dest);
  Dest := Drive + ':' + MSDOSSYS;
  FileSetAttr(Dest,0);
  SysUtils.DeleteFile(Dest);
  Dest := Drive + ':' + IBMBIOSYS;
  FileSetAttr(Dest,0);
  SysUtils.DeleteFile(Dest);
  Dest := Drive + ':' + IBMDOSSYS;
  FileSetAttr(Dest,0);
  SysUtils.DeleteFile(Dest);

  FileName := IOSYS;
  Source := Char(Integer('C')+Ord(FSystemLocation)) + ':' + FileName;
  Dest := Drive + ':' + FileName;
  if FileExists(Source) then Result := CopyFile(Source,Dest)
  else Result := False;

  if Result then begin
    FileName := MSDOSSYS;
    Source := Char(Integer('C')+Ord(FSystemLocation)) + ':' + FileName;
    Dest := Drive + ':' + FileName;
    if FileExists(Source) then Result := CopyFile(Source,Dest)
    else Result := False;
  end;

  if Result then begin
    VarPChar := StrAlloc(MAX_PATH);
    GetEnvironmentVariable('COMSPEC',VarPChar,MAX_PATH);
    Source := StrPas(VarPChar);
    StrDispose(VarPChar);

    Dest := Drive + ':' + '\COMMAND.COM';
    if FileExists(Source) then Result := CopyFile(Source,Dest)
    else Result := False;
  end;
end;

function TFloppyFormat.CopyFile(Source, Target: string): Boolean;
begin
  Result := Windows.CopyFile(PChar(Source),PChar(Target),False);
end;

function TFloppyFormat.CheckFormatConditions(Drive: Byte;
                 var TempFormatCondition: TFormatCondition): Integer;
var
  CheckBuffer: MaxArrayPtr;
  Error: Integer;
  CurrentDiskInfo: DiskInformation;
  Matched: TMediaType;
begin
  Result := 0;
  if (TempFormatCondition=WhenNeeded) or ((TempFormatCondition=Never) and FClearDisk) then
  begin
    GetMem(CheckBuffer,2048);
    try
      // Read in boot sector
      Error := ReadLogicalSector(Drive,0,CheckBuffer);
      if Error<>0 then Error := ReadLogicalSector(Drive,0,CheckBuffer);
      Move(CheckBuffer^[12],CurrentDiskInfo,SizeOf(CurrentDiskInfo));

    for Matched:=F360 to F1440 do begin
      if (CompareMemory(MaxArrayPtr(@CurrentDiskInfo),MaxArrayPtr(@DiskInfo[Matched]),SizeOf(DiskInformation)) = 0)
          or (Error<>0)
      then break;
    end;

    finally
      FreeMem(CheckBuffer);
    end;

    if TempFormatCondition = Never then	begin
      if (Error<>0) or (FMediaType<>Matched) then begin
        // Error or Boot does not match current MediaType
        Result := 14;
        exit;
      end;
    end else if (Error<>0) or (FMediaType<>Matched) then
      // Error or Boot does not match current MediaType
        TempFormatCondition := Always;
  end;
end;

function TFloppyFormat.CompareMemory(Value1, Value2: MaxArrayPtr; Size: Integer): Integer;
var Pos: Integer;
begin
  Result := 0;
  for Pos := 1 to Size do begin
    if Value1^[Pos]>Value2^[Pos] then begin
      Result := 1;
      break;
    end;
    if Value1^[Pos]<Value2^[Pos] then begin
      Result := -1;
      break;
    end;
  end;
end;

function TFloppyFormat.RSNT(Drive: Byte;
          FirstSector, Sectors: Integer;
          Buffer: Pointer): Boolean;
type TP = Pointer;
  TPPtr = TP;
var
  fResult: Boolean;
  BytesNumberRW: DWord;
  AFirstByte: Integer;
begin
  AFirstByte := FirstSector*DiskInfo[FMediaType].BytesPerSector;

  if DiskHandle=INVALID_HANDLE_VALUE then
    NeedCloseHandle := GetDiskHandle(Drive);

  if DiskHandle<>INVALID_HANDLE_VALUE then begin
    SetFilePointer(DiskHandle, AFirstByte, nil, 0);
    fResult := ReadFile(
      DiskHandle,	  // handle of file to read
      Buffer^,   // address of buffer that receives data
      FloppySectorSize*Sectors,	// number of bytes to read
      BytesNumberRW,	// address of number of bytes read
      nil); 	   // address of structure for data
  end   //if DiskHandle<>INVALID_HANDLE_VALUE
  else fResult := False;
  if NeedCloseHandle then FreeHandle;

  Result := fResult;
end;

Function TFloppyFormat.VSNT(Drive: Byte;
          FirstSector, Sectors: Integer): Boolean;
var
  Buf: Pointer;
begin
  GetMem(Buf,Sectors*DiskInfo[FMediaType].BytesPerSector);
  try Result := RSNT(Drive, FirstSector, Sectors, Buf);
  finally
    FreeMem(Buf);
  end;
end;

Function TFloppyFormat.WSNT(Drive: Byte;
          FirstSector, Sectors: Integer;
          Buffer: Pointer): Boolean;
var
  fResult: Boolean;
  BytesNumberRW: DWord;
  AFirstByte: Integer;
begin
  AFirstByte := FirstSector*DiskInfo[FMediaType].BytesPerSector;
  if DiskHandle=INVALID_HANDLE_VALUE then
    NeedCloseHandle := GetDiskHandle(Drive);

  if DiskHandle<>INVALID_HANDLE_VALUE then begin
    SetErrorMode(SEM_FAILCRITICALERRORS);
    SetFilePointer(DiskHandle, AFirstByte, nil, 0);
    fResult := WriteFile(
      DiskHandle,	  // handle of file to write
      Buffer^,   // address of buffer that receives data
      FloppySectorSize*Sectors,	// number of bytes to write
      BytesNumberRW,	// address of number of bytes write
      nil); 	   // address of structure for data
    SetErrorMode(SEM_NOALIGNMENTFAULTEXCEPT);
  end   //if DiskHandle<>INVALID_HANDLE_VALUE
  else fResult := False;
  if NeedCloseHandle then FreeHandle;

  Result := fResult;
end;

function TFloppyFormat.GetBiosErrorMessage(ErrNo: Integer): String;
begin
  case ErrNo of
    $00: Result := 'OK';
    $01: Result := 'Invalid command';
    $02: Result := 'Address not found';
    $03: Result := 'Disk write protected';
    $04: Result := 'Sector not found';
    $06: Result := 'Floppy disk removed';
    $08: Result := 'DMA overflow';
    $09: Result := 'DMA boundary error';
    $0C: Result := 'Unsupported track or invalid media';
    $10: Result := 'Read Error';
    $20: Result := 'Controller failed';
    $40: Result := 'Seek failed';
    $80: Result := 'Disk timed out';
  else
    Result := 'Unknown error '+ IntToStr(ErrNo);
  end;
end;

function TFloppyFormat.GetErrorMessage(Error: Integer): String;
begin
  case Error of
    0:  Result := 'OK';
    01: Result := 'Reset failed';
    02: Result := 'Unable to get drive type';
    03: Result := 'No such drive';
    04: Result := 'Unknown drive type';
    05: Result := 'Incompatible media types';
    06: Result := 'Unable to set disk type';
    07: Result := 'Unable to set media type';
    08: Result := 'Error formatting track';
    09: Result := 'Error verifying track';
    10: Result := 'Error writing boot sector';
    11: Result := 'Error writing fat';
    12: Result := 'Error writing root';
    13: Result := 'Error creating system';
    14: Result := 'Unable to clear disk';
    15: Result := 'Disk access violation';
    16: Result := 'System error';
    17: Result := 'No memory';
    18: Result := 'Sector does not exist';
    19: Result := 'Track does not exist';
    98: Result := 'Process already running';
    99: Result := 'Canceled by user';
  else
    Result := 'Unknown error '+ IntToStr(Error);
  end;
end;

end.
