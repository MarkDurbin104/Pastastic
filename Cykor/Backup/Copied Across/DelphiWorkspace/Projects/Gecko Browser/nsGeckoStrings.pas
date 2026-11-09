unit nsGeckoStrings;

interface

uses
  nsConsts;

{$IF MOZILLA_VERSION < 1.7}
type
  PBufferHandleW = ^nsBufferHandleW;
  nsBufferHandleW = record
    DataStart: PWideChar;
    DataEnd: PWideChar;
  end;
  PSharedBufferHandleW = ^nsSharedBufferHandleW;
  nsSharedBufferHandleW = record
    DataStart: PWideChar;
    DataEnd: PWideChar;
    Flags: Longword;
    StorageLength: Longword;
  end;
  PBufferHandleA = ^nsBufferHandleA;
  nsBufferHandleA = record
    DataStart: PAnsiChar;
    DataEnd: PAnsiChar;
  end;
  PSharedBufferHandleA = ^nsSharedBufferHandleA;
  nsSharedBufferHandleA = record
    DataStart: PAnsiChar;
    DataEnd: PAnsiChar;
    Flags: Longword;
    StorageLength: Longword;
  end;

  nsReadableFragmentW = record
    DataStart: PWideChar;
    DataEnd: PWideChar;
    FragmentIdentifier: Pointer;
  end;
  nsWritableFragmentW = record
    DataStart: PWideChar;
    DataEnd: PWideChar;
    FragmentIdentifier: Pointer;
  end;
  nsReadableFragmentA = record
    DataStart: PAnsiChar;
    DataEnd: PAnsiChar;
    FragmentIdentifier: Pointer;
  end;
  nsWritableFragmentA = record
    DataStart: PAnsiChar;
    DataEnd: PAnsiChar;
    FragmentIdentifier: Pointer;
  end;

  nsAString = class(TObject)
  protected
    procedure __Destruct(Dummy: Cardinal; This: nsAString); virtual;
    function __GetImplementationFlags(Dummy: Cardinal; This: nsAString): Longword; virtual;
    function __GetFlatBufferHandle(Dummy: Cardinal; This: nsAString): PBufferHandleW; virtual;
    function __GetBufferHandle(Dummy: Cardinal; This: nsAString): PBufferHandleW; virtual;
    function __GetSharedBufferHandle(Dummy: Cardinal; This: nsAString): PSharedBufferHandleW; virtual;
    function __GetLength(Dummy: Cardinal; This: nsAString): Longword; virtual;
    function __IsVoid(Dummy: Cardinal; This: nsAString): LongBool; virtual;
    procedure __SetVoid(Dummy: Cardinal; This: nsAString; aVoid: LongBool); virtual;
    procedure __SetCapacity(Dummy: Cardinal; This: nsAString; aCapacity: Longword); virtual;
    procedure __SetLength(Dummy: Cardinal; This: nsAString; aLength: Longword); virtual;
    procedure __Cut(Dummy: Cardinal; This: nsAString; cutLength, cutStart: Longword); virtual;
    procedure __Assign(Dummy: Cardinal; This: nsAString; const Source: nsAString); overload; virtual;
    procedure __Assign(Dummy: Cardinal; This: nsAString; Source: PWideChar); overload; virtual;
    procedure __Assign(Dummy: Cardinal; This: nsAString; aLength: Longword; Source: PWideChar); overload; virtual;
    procedure __Assign(Dummy: Cardinal; This: nsAString; Source: WideChar); overload; virtual;
    procedure __Append(Dummy: Cardinal; This: nsAString; const Source: nsAString); overload; virtual;
    procedure __Append(Dummy: Cardinal; This: nsAString; Source: PWideChar); overload; virtual;
    procedure __Append(Dummy: Cardinal; This: nsAString; aLength: Longword; Source: PWideChar); overload; virtual;
    procedure __Append(Dummy: Cardinal; This: nsAString; Source: WideChar); overload; virtual;
    procedure __Insert(Dummy: Cardinal; This: nsAString; aPosition: Longword; const Source: nsAString); overload; virtual;
    procedure __Insert(Dummy: Cardinal; This: nsAString; aPosition: Longword; Source: PWideChar); overload; virtual;
    procedure __Insert(Dummy: Cardinal; This: nsAString; aLength, aPosition: Longword; Source: PWideChar); overload; virtual;
    procedure __Insert(Dummy: Cardinal; This: nsAString; aPosition: Longword; Source: WideChar); overload; virtual;
    procedure __Replace(Dummy: Cardinal; This: nsAString; const Source: nsAString; aLength, aPosition: Longword); virtual;
    function __GetReadableFragment(Dummy: Cardinal; This: nsAString; aPosition, aRequest: Longword; var aFragment: nsReadableFragmentW): PWideChar; virtual;
    function __GetWritableFragment(Dummy: Cardinal; This: nsAString; aPosition, aRequest: Longword; var aFragment: nsWritableFragmentW): PWideChar; virtual;
  public
    function GetImplementationFlags(): Longword; virtual;
    function GetFlatBufferHandle(): PBufferHandleW; virtual;
    function GetBufferHandle(): PBufferHandleW; virtual;
    function GetSharedBufferHandle(): PSharedBufferHandleW; virtual;
    function GetLength(): Longword; virtual; abstract;
    function IsVoid(): LongBool; virtual;
    procedure SetVoid(aVoid: LongBool); virtual;
    procedure SetCapacity(aCapacity: Longword); virtual;
    procedure SetLength(aLength: Longword); virtual;
    procedure Cut(cutStart: Longword; cutLength: Longword); virtual;
    procedure Assign(const Source: nsAString); overload; virtual;
    procedure Assign(Source: PWideChar); overload; virtual;
    procedure Assign(Source: PWideChar; aLength: Longword); overload; virtual;
    procedure Assign(Source: WideChar); overload; virtual;
    procedure Append(const Source: nsAString); overload; virtual;
    procedure Append(Source: PWideChar); overload; virtual;
    procedure Append(Source: PWideChar; aLength: Longword); overload; virtual;
    procedure Append(Source: WideChar); overload; virtual;
    procedure Insert(const Source: nsAString; aPosition: Longword); overload; virtual;
    procedure Insert(Source: PWideChar; aPosition: Longword); overload; virtual;
    procedure Insert(Source: PWideChar; aPosition, aLength: Longword); overload; virtual;
    procedure Insert(Source: WideChar; aPosition: Longword); overload; virtual;
    procedure Replace(aPosition, aLength: Longword; const Source: nsAString); virtual;
    function GetReadableFragment(var aFragment: nsReadableFragmentW; aRequest: Longword; aPosition: Longword = 0): PWideChar; virtual;  abstract;
    function GetWritableFragment(var aFragment: nsWritableFragmentW; aRequest: Longword; aPosition: Longword = 0): PWideChar; virtual;  abstract;

    procedure Assign(Source: WideString); overload;
    procedure Assign(Source: WideString; aLength: Longword); overload;
    procedure Append(Source: WideString); overload;
    procedure Append(Source: WideString; aLength: Longword); overload;
    procedure Insert(Source: WideString; aPosition: Longword); overload;
    procedure Insert(Source: WideString; aPosition, aLength: Longword); overload;
  private
    function IsDependentOn(const Source: nsAString): LongBool;
    procedure UncheckedAssign(const Source: nsAString);
    procedure UncheckedAppend(const Source: nsAString);
    procedure UncheckedInsert(const Source: nsAString; aPosition: Longword);
    procedure UncheckedReplace(aPosition, aLength: Longword; const Source: nsAString);
  public
    //property Length: Longword read GetLength write SetLength;
  end;

  nsASingleFragmentString = class(nsAString)
  public
    function GetLength(): Longword; override;
    function GetReadableFragment(var aFragment: nsReadableFragmentW; aRequest, aPosition: Longword): PWideChar; override;
    function GetWritableFragment(var aFragment: nsWritableFragmentW; aRequest, aPosition: Longword): PWideChar; override;
  end;

  nsAFlatString = class(nsASingleFragmentString)
  public
    function GetPtr(): PWideChar; virtual; 
    property Ptr: PWideChar read GetPtr;
  end;

  nsACString = class(TObject)
  protected
    procedure __Destruct(Dummy: Cardinal; This: nsACString); virtual;
    function __GetImplementationFlags(Dummy: Cardinal; This: nsACString): Longword; virtual;
    function __GetFlatBufferHandle(Dummy: Cardinal; This: nsACString): PBufferHandleA; virtual;
    function __GetBufferHandle(Dummy: Cardinal; This: nsACString): PBufferHandleA; virtual;
    function __GetSharedBufferHandle(Dummy: Cardinal; This: nsACString): PSharedBufferHandleA; virtual;
    function __GetLength(Dummy: Cardinal; This: nsACString): Longword; virtual;
    function __IsVoid(Dummy: Cardinal; This: nsACString): LongBool; virtual;
    procedure __SetVoid(Dummy: Cardinal; This: nsACString; aVoid: LongBool); virtual;
    procedure __SetCapacity(Dummy: Cardinal; This: nsACString; aCapacity: Longword); virtual;
    procedure __SetLength(Dummy: Cardinal; This: nsACString; aLength: Longword); virtual;
    procedure __Cut(Dummy: Cardinal; This: nsACString; cutLength, cutStart: Longword); virtual;
    procedure __Assign(Dummy: Cardinal; This: nsACString; const Source: nsACString); overload; virtual;
    procedure __Assign(Dummy: Cardinal; This: nsACString; Source: PAnsiChar); overload; virtual;
    procedure __Assign(Dummy: Cardinal; This: nsACString; aLength: Longword; Source: PAnsiChar); overload; virtual;
    procedure __Assign(Dummy: Cardinal; This: nsACString; Source: AnsiChar); overload; virtual;
    procedure __Append(Dummy: Cardinal; This: nsACString; const Source: nsACString); overload; virtual;
    procedure __Append(Dummy: Cardinal; This: nsACString; Source: PAnsiChar); overload; virtual;
    procedure __Append(Dummy: Cardinal; This: nsACString; aLength: Longword; Source: PAnsiChar); overload; virtual;
    procedure __Append(Dummy: Cardinal; This: nsACString; Source: AnsiChar); overload; virtual;
    procedure __Insert(Dummy: Cardinal; This: nsACString; aPosition: Longword; const Source: nsACString); overload; virtual;
    procedure __Insert(Dummy: Cardinal; This: nsACString; aPosition: Longword; Source: PAnsiChar); overload; virtual;
    procedure __Insert(Dummy: Cardinal; This: nsACString; aLength, aPosition: Longword; Source: PAnsiChar); overload; virtual;
    procedure __Insert(Dummy: Cardinal; This: nsACString; aPosition: Longword; Source: AnsiChar); overload; virtual;
    procedure __Replace(Dummy: Cardinal; This: nsACString; const Source: nsACString; aLength, aPosition: Longword); virtual;
    function __GetReadableFragment(Dummy: Cardinal; This: nsACString; aPosition, aRequest: Longword; var aFragment: nsReadableFragmentA): PAnsiChar; virtual;
    function __GetWritableFragment(Dummy: Cardinal; This: nsACString; aPosition, aRequest: Longword; var aFragment: nsWritableFragmentA): PAnsiChar; virtual;
  public
    function GetImplementationFlags(): Longword; virtual;
    function GetFlatBufferHandle(): PBufferHandleA; virtual; 
    function GetBufferHandle(): PBufferHandleA; virtual; 
    function GetSharedBufferHandle(): PSharedBufferHandleA; virtual; 
    function GetLength(): Longword; virtual; abstract;
    function IsVoid(): LongBool; virtual; 
    procedure SetVoid(aVoid: LongBool); virtual; 
    procedure SetCapacity(aCapacity: Longword); virtual;
    procedure SetLength(aLength: Longword); virtual; 
    procedure Cut(cutStart: Longword; cutLength: Longword); virtual; 
    procedure Assign(const Source: nsACString); overload; virtual;
    procedure Assign(Source: PAnsiChar); overload; virtual;
    procedure Assign(Source: PAnsiChar; aLength: Longword); overload; virtual;
    procedure Assign(Source: AnsiChar); overload; virtual;
    procedure Append(const Source: nsACString); overload; virtual;
    procedure Append(Source: PAnsiChar); overload; virtual;
    procedure Append(Source: PAnsiChar; aLength: Longword); overload; virtual;
    procedure Append(Source: AnsiChar); overload; virtual;
    procedure Insert(const Source: nsACString; aPosition: Longword); overload; virtual;
    procedure Insert(Source: PAnsiChar; aPosition: Longword); overload; virtual;
    procedure Insert(Source: PAnsiChar; aPosition, aLength: Longword); overload; virtual;
    procedure Insert(Source: AnsiChar; aPosition: Longword); overload; virtual;
    procedure Replace(aPosition, aLength: Longword; const Source: nsACString); virtual;
    function GetReadableFragment(var aFragment: nsReadableFragmentA; aRequest: Longword; aPosition: Longword = 0): PAnsiChar; virtual;  abstract;
    function GetWritableFragment(var aFragment: nsWritableFragmentA; aRequest: Longword; aPosition: Longword = 0): PAnsiChar; virtual;  abstract;

    procedure Assign(Source: AnsiString); overload;
    procedure Assign(Source: AnsiString; aLength: Longword); overload;
    procedure Append(Source: AnsiString); overload;
    procedure Append(Source: AnsiString; aLength: Longword); overload;
    procedure Insert(Source: AnsiString; aPosition: Longword); overload;
    procedure Insert(Source: AnsiString; aPosition, aLength: Longword); overload;
  private
    function IsDependentOn(const Source: nsACString): LongBool;
    procedure UncheckedAssign(const Source: nsACString);
    procedure UncheckedAppend(const Source: nsACString);
    procedure UncheckedInsert(const Source: nsACString; aPosition: Longword);
    procedure UncheckedReplace(aPosition, aLength: Longword; const Source: nsACString);
  public
    //property Length: Longword read GetLength write SetLength;
  end;

  nsASingleFragmentCString = class(nsACString)
  public
    function GetLength(): Longword; override;
    function GetReadableFragment(var aFragment: nsReadableFragmentA; aRequest, aPosition: Longword): PAnsiChar; override;
    function GetWritableFragment(var aFragment: nsWritableFragmentA; aRequest, aPosition: Longword): PAnsiChar; override;
  end;

  nsAFlatCString = class(nsASingleFragmentCString)
  public
    function GetPtr(): PAnsiChar; virtual;
    property Ptr: PAnsiChar read GetPtr;
  end;

  IInterfacedString = interface;
  IInterfacedCString = interface;

  IInterfacedString = interface
    function GetImplementationFlags: Longword;
    function GetFlatBufferHandle: PBufferHandleW;
    function GetBufferHandle: PBufferHandleW;
    function GetSharedBufferHandle: PSharedBufferHandleW;
    function GetLength: Longword;
    procedure SetLength(aLength: Longword);
    function GetIsVoid: Boolean;
    procedure SetIsVoid(aIsVoid: Boolean);
    procedure SetCapacity(aCapacity: Longword);
    procedure Cut(cutStart, cutLength: Longword);
    procedure Assign(Source: IInterfacedString); overload;
    procedure Assign(const Source: nsAString); overload;
    procedure Assign(Source: WideString); overload;
    procedure Append(Source: IInterfacedString); overload;
    procedure Append(const Source: nsAString); overload;
    procedure Append(Source: WideString); overload;
    procedure Insert(Source: IInterfacedString; aPosition: Longword); overload;
    procedure Insert(const Source: nsAString; aPosition: Longword); overload;
    procedure Insert(Source: WideString; aPosition: Longword); overload;
    procedure Replace(aPosition, aLength: Longword; const Source: nsAString); overload;
    procedure Replace(aPosition, aLength: Longword; Source: IInterfacedString); overload;
    function GetReadableFragment(var aFragment: nsReadableFragmentW; aRequest: Longword; aPosition: Longword = 0): PWideChar;
    function GetWritableFragment(var aFragment: nsWritableFragmentW; aRequest: Longword; aPosition: Longword = 0): PWideChar;
    function AString: nsAString;
    function ToString: WideString;

    property Length: Longword read GetLength write SetLength;
    property IsVoid: Boolean read GetIsVoid write SetIsVoid;
  end;

  IInterfacedCString = interface
    function GetImplementationFlags: Longword;
    function GetFlatBufferHandle: PBufferHandleA;
    function GetBufferHandle: PBufferHandleA;
    function GetSharedBufferHandle: PSharedBufferHandleA;
    function GetLength: Longword;
    procedure SetLength(aLength: Longword);
    function GetIsVoid: Boolean;
    procedure SetIsVoid(aIsVoid: Boolean);
    procedure SetCapacity(aCapacity: Longword);
    procedure Cut(cutStart, cutLength: Longword);
    procedure Assign(Source: IInterfacedCString); overload;
    procedure Assign(const Source: nsACString); overload;
    procedure Assign(Source: AnsiString); overload;
    procedure Append(Source: IInterfacedCString); overload;
    procedure Append(const Source: nsACString); overload;
    procedure Append(Source: AnsiString); overload;
    procedure Insert(Source: IInterfacedCString; aPosition: Longword); overload;
    procedure Insert(const Source: nsACString; aPosition: Longword); overload;
    procedure Insert(Source: AnsiString; aPosition: Longword); overload;
    procedure Replace(aPosition, aLength: Longword; const Source: nsACString); overload;
    procedure Replace(aPosition, aLength: Longword; Source: IInterfacedCString); overload;
    function GetReadableFragment(var aFragment: nsReadableFragmentA; aRequest: Longword; aPosition: Longword = 0): PAnsiChar;
    function GetWritableFragment(var aFragment: nsWritableFragmentA; aRequest: Longword; aPosition: Longword = 0): PAnsiChar;
    function ACString: nsACString;
    function ToString: AnsiString;

    property Length: Longword read GetLength write SetLength;
    property IsVoid: Boolean read GetIsVoid write SetIsVoid;
  end;

const
  sbhIsImmutable                  = $01000000;
  sbhIsSingleAllocationWithBuffer = $02000000;
  sbhIsUserAllocator              = $04000000;
  sbhIsNull                       = $80000000;
  sbhImplementationFlagsMask      = $f0000000;
  sbhFlagsMask                    = $ff000000;
  sbhRefCountMask                 = $00ffffff;

  gfPrevFragment = 0;
  gfFirstFragment = 1;
  gfLastFragment = 2;
  gfNextFragment = 3;
  gfFragmentAt = 4;

{$ELSE}         // MOZILLA_VERSION >= 1.7
  type
    nsAString = ^nsStringContainer;
    nsString = nsAString;
    nsStringContainer = record
      v: Pointer;
      d1: Pointer;
      d2: Longword;
      d3: Pointer;
    end;
    nsACString = ^nsCStringContainer;
    nsCString = nsACString;
    nsCStringContainer = record
      v: Pointer;
      d1: Pointer;
      d2: Longword;
      d3: Pointer;
    end;

  IInterfacedString = interface;
  IInterfacedCString = interface;

  IInterfacedString = interface
    function Length: Longword;
    procedure Cut(cutStart, cutLength: Longword);
    procedure Assign(Source: IInterfacedString); overload;
    procedure Assign(const Source: nsAString); overload;
    procedure Assign(Source: WideString); overload;
    procedure Append(Source: IInterfacedString); overload;
    procedure Append(const Source: nsAString); overload;
    procedure Append(Source: WideString); overload;
    procedure Insert(Source: IInterfacedString; aPosition: Longword); overload;
    procedure Insert(const Source: nsAString; aPosition: Longword); overload;
    procedure Insert(Source: WideString; aPosition: Longword); overload;
    procedure Replace(aPosition, aLength: Longword; const Source: nsAString); overload;
    procedure Replace(aPosition, aLength: Longword; Source: IInterfacedString); overload;
    function AString: nsAString;
    function ToString: WideString;
  end;

  IInterfacedCString = interface
    function Length: Longword;
    procedure Cut(cutStart, cutLength: Longword);
    procedure Assign(Source: IInterfacedCString); overload;
    procedure Assign(const Source: nsACString); overload;
    procedure Assign(Source: AnsiString); overload;
    procedure Append(Source: IInterfacedCString); overload;
    procedure Append(const Source: nsACString); overload;
    procedure Append(Source: AnsiString); overload;
    procedure Insert(Source: IInterfacedCString; aPosition: Longword); overload;
    procedure Insert(const Source: nsACString; aPosition: Longword); overload;
    procedure Insert(Source: AnsiString; aPosition: Longword); overload;
    procedure Replace(aPosition, aLength: Longword; const Source: nsACString); overload;
    procedure Replace(aPosition, aLength: Longword; Source: IInterfacedCString); overload;
    function ACString: nsACString;
    function ToString: AnsiString;
  end;

{$IFEND}

function Compare(const lhs, rhs: nsAString): Integer; overload;
function Compare(const lhs, rhs: nsACString): Integer; overload;

function NewString: IInterfacedString; overload;
function NewString(src: PWideChar): IInterfacedString; overload;
function NewString(src: WideString): IInterfacedString; overload;
function NewString(src: nsAString): IInterfacedString; overload;

function NewCString: IInterfacedCString; overload;
function NewCString(src: PAnsiChar): IInterfacedCString; overload;
function NewCString(src: AnsiString): IInterfacedCString; overload;
function NewCString(src: nsACString): IInterfacedCString; overload;

function RelateString(src: nsAString; own: Boolean=False): IInterfacedString;
function RelateCString(src: nsACString; own: Boolean=False): IInterfacedCString;

implementation

{$IF MOZILLA_VERSION < 1.7}
uses
  nsMemory, nsXPCOMGlue;

type
type
  nsDependentString = class(nsAFlatString)
  private
    FHandle: nsBufferHandleW;
  public
    procedure Rebind(aPtr: PWideChar); overload;
    procedure Rebind(aStartPtr, aEndPtr: PWideChar); overload;
    procedure Rebind(aPtr: PWideChar; aLength: Longword); overload;
    constructor Create(aPtr: PWideChar); overload;
    constructor Create(aStartPtr, aEndPtr: PWideChar); overload;
    constructor Create(aPtr: PWideChar; aLength: Longword); overload;
    function GetBufferHandle(): PBufferHandleW; override;
    function GetFlatBufferHandle(): PBufferHandleW; override;
  end;

  nsDependentCString = class(nsAFlatCString)
  private
    FHandle: nsBufferHandleA;
  public
    procedure Rebind(aPtr: PAnsiChar); overload;
    procedure Rebind(aStartPtr, aEndPtr: PAnsiChar); overload;
    procedure Rebind(aPtr: PAnsiChar; aLength: Longword); overload;
    constructor Create(aPtr: PAnsiChar); overload;
    constructor Create(aStartPtr, aEndPtr: PAnsiChar); overload;
    constructor Create(aPtr: PAnsiChar; aLength: Longword); overload;
    function GetBufferHandle(): PBufferHandleA; override;
    function GetFlatBufferHandle(): PBufferHandleA; override;
  end;

type
  nsString = class(nsAFlatString)
  private
    FStr: PWideChar;
    FLength: Longword;
    FCapacity: Longword;
  public
    function GetFlatBufferHandle(): PBufferHandleW; override;
    function GetLength(): Longword; override;
    procedure SetCapacity(aCapacity: Longword); override;
    procedure SetLength(aLength: Longword); override;
    function GetReadableFragment(var aFragment: nsReadableFragmentW; aRequest: Longword; aPosition: Longword = 0): PWideChar; override;
    function GetWritableFragment(var aFragment: nsWritableFragmentW; aRequest: Longword; aPosition: Longword = 0): PWideChar; override;

    constructor Create(); overload;
    constructor Create(const Source: nsAString); overload;
    constructor Create(const Source: nsString); overload;
    constructor Create(Source: PWideChar); overload;
    constructor Create(Source: WideString); overload;
    constructor Create(Source: PWideChar; aLength: Longword); overload;
    destructor Destroy(); override;
  private
    procedure Init();
    procedure _Destroy();
    procedure _Free();
    function Realloc(aNewSize: Longword): LongBool;
    function EnsureCapacity(aNewCapacity: Longword): LongBool;
    function GrowCapacity(aNewCapacity: Longword): LongBool;
    procedure AddNullTerminator();

    function GetValue: WideString;
  public
    property Capacity: Longword read FCapacity write SetCapacity;
    property Value: WideString read GetValue;
  end;

  nsCString = class(nsAFlatCString)
  private
    FStr: PAnsiChar;
    FLength: Longword;
    FCapacity: Longword;
  public
    function GetFlatBufferHandle(): PBufferHandleA; override;
    function GetLength(): Longword; override;
    procedure SetCapacity(aCapacity: Longword); override;
    procedure SetLength(aLength: Longword); override;
    function GetReadableFragment(var aFragment: nsReadableFragmentA; aRequest: Longword; aPosition: Longword = 0): PAnsiChar; override;
    function GetWritableFragment(var aFragment: nsWritableFragmentA; aRequest: Longword; aPosition: Longword = 0): PAnsiChar; override;

    constructor Create(); overload;
    constructor Create(const Source: nsACString); overload;
    constructor Create(const Source: nsCString); overload;
    constructor Create(Source: PAnsiChar); overload;
    constructor Create(Source: AnsiString); overload;
    constructor Create(Source: PAnsiChar; aLength: Longword); overload;
    destructor Destroy(); override;
  private
    procedure Init();
    procedure _Destroy();
    procedure _Free();
    function Realloc(aNewSize: Longword): LongBool;
    function EnsureCapacity(aNewCapacity: Longword): LongBool;
    function GrowCapacity(aNewCapacity: Longword): LongBool;
    procedure AddNullTerminator();

    function GetValue: String;
  public
    property Capacity: Longword read FCapacity write SetCapacity;
    property Value: String read GetValue;
  end;

procedure Copy(dst, src: PWideChar; lengthToCopy: Longword); overload;
asm
  push edi
  push esi

  mov edi, eax
  mov esi, edx
  cld
  rep movsw

  pop esi
  pop edi
end;

procedure Copy(Dst: nsAString; dstPos: Longword;  Src: nsAString; srcPos, srcLen: Longword); overload;
var
  srcFragment: nsReadableFragmentW;
  dstFragment: nsWritableFragmentW;
  srcPtr, dstPtr: PWideChar;
  fragmentLength: Longword;
  lengthAvailable: Longword;
  d, s: Longword;
begin
  dstPtr := Dst.__GetWritableFragment(0, Dst, 0, gfFirstFragment, dstFragment);
  if not Assigned(dstPtr) then Exit;
  while dstPos > 0 do
  begin
    fragmentLength := dstFragment.DataEnd - dstFragment.DataStart;
    if dstPos < fragmentLength then
    begin
      dstPtr := dstPtr + dstPos;
      Break;
    end;
    dstPtr := Dst.__GetWritableFragment(0, Dst, 0, gfNextFragment, dstFragment);
    if not Assigned(dstPtr) then Exit;
  end;

  srcPtr := Src.__GetReadableFragment(0, Src, 0, gfFirstFragment, srcFragment);
  if not Assigned(srcPtr) then Exit;
  while srcPos > 0 do
  begin
    fragmentLength := srcFragment.DataEnd - srcFragment.DataStart;
    if srcPos < fragmentLength then
    begin
      srcPtr := srcPtr + srcPos;
      Break;
    end;
    srcPtr := Src.__GetReadableFragment(0, Src, 0, gfNextFragment, srcFragment);
    if not Assigned(srcPtr) then Exit;
  end;

  while srcLen > 0 do
  begin
    d := dstFragment.DataEnd - dstPtr;
    s := srcFragment.DataEnd - srcPtr;
    if s>d then lengthAvailable:=d else lengthAvailable:=s;
    if srcLen < lengthAvailable then lengthAvailable := srcLen;
    Copy(dstPtr, srcPtr, lengthAvailable);
    Inc(dstPtr, lengthAvailable);
    Inc(srcPtr, lengthAvailable);
    Dec(srcLen, lengthAvailable);
    if dstPtr = dstFragment.DataEnd then
    begin
      if Dst.__GetWritableFragment(0, Dst, 0, gfNextFragment, dstFragment)=nil then Break;
      dstPtr := dstFragment.DataStart;
    end;
    if srcPtr = srcFragment.DataEnd then
    begin
      if Src.__GetReadableFragment(0, Src, 0, gfNextFragment, srcFragment)=nil then Break;
      srcPtr := srcFragment.DataStart;
    end;
  end;
end;

procedure Copy(dstPtr: PWideChar; Src: nsAString; srcPos, srcLen: Longword); overload;
var
  srcFragment: nsReadableFragmentW;
  srcPtr: PWideChar;
  fragmentLength: Longword;
  s: Longword;
begin
  srcPtr := Src.__GetReadableFragment(0, Src, 0, gfFirstFragment, srcFragment);
  if not Assigned(srcPtr) then Exit;
  while srcPos > 0 do
  begin
    fragmentLength := srcFragment.DataEnd - srcFragment.DataStart;
    if srcPos < fragmentLength then
    begin
      srcPtr := srcPtr + srcPos;
      Break;
    end;
    srcPtr := Src.__GetReadableFragment(0, Src, 0, gfNextFragment, srcFragment);
    if not Assigned(srcPtr) then Exit;
  end;

  while srcLen > 0 do
  begin
    s := srcFragment.DataEnd - srcPtr;
    if s>srcLen then s := srcLen;
    Copy(dstPtr, srcPtr, s);
    Inc(dstPtr, s); Inc(srcPtr, s); Dec(srcLen, s);
    if srcPtr = srcFragment.DataEnd then
    begin
      if Src.__GetReadableFragment(0, Src, 0, gfNextFragment, srcFragment)=nil then Break;
      srcPtr := srcFragment.DataStart;
    end;
  end;
end;

procedure CopyBack(dst, src: PWideChar; lengthToCopy: Longword); overload;
asm
  push edi
  push esi

  mov edi, eax
  mov esi, edx
  sub edi, 2
  sub esi, 2
  
  std
  rep movsw

  pop esi
  pop edi
end;

procedure CopyBack(Dst: nsAString; dstPos: Longword;  Src: nsAString; srcPos, srcLen: Longword); overload;
var
  srcFragment: nsReadableFragmentW;
  dstFragment: nsWritableFragmentW;
  srcPtr, dstPtr: PWideChar;
  fragmentLength: Longword;
  s, d: Longword;
  lengthAvailable: Longword;
begin
  Inc(srcPos, srcLen);
  Inc(dstPos, srcLen);
  if (srcPos>Src.__GetLength(0, Src)) or (dstPos>Dst.__GetLength(0, Dst)) then Exit;

  dstPtr := Dst.__GetWritableFragment(0, Dst, 0, gfFirstFragment, dstFragment);
  if not Assigned(dstPtr) then Exit;
  while dstPos > 0 do
  begin
    fragmentLength := dstFragment.DataEnd - dstFragment.DataStart;
    if dstPos <= fragmentLength then
    begin
      dstPtr := dstPtr + dstPos;
      Break;
    end;
    dstPtr := Dst.__GetWritableFragment(0, Dst, 0, gfNextFragment, dstFragment);
    if not Assigned(dstPtr) then Exit;
  end;

  srcPtr := Src.__GetReadableFragment(0, Src, 0, gfFirstFragment, srcFragment);
  if not Assigned(srcPtr) then Exit;
  while srcPos > 0 do
  begin
    fragmentLength := srcFragment.DataEnd - srcFragment.DataStart;
    if srcPos <= fragmentLength then
    begin
      srcPtr := srcPtr + srcPos;
      Break;
    end;
    srcPtr := Src.__GetReadableFragment(0, Src, 0, gfNextFragment, srcFragment);
    if not Assigned(srcPtr) then Exit;
  end;

  while srcLen > 0 do
  begin
    d := dstPtr - dstFragment.DataStart;
    s := srcPtr - srcFragment.DataStart;
    if d<s then lengthAvailable:=d else lengthAvailable:=s;
    if lengthAvailable>srcLen then lengthAvailable:=srcLen;
    CopyBack(dstPtr, srcPtr, lengthAvailable);
    Dec(dstPtr, lengthAvailable);
    Dec(srcPtr, lengthAvailable);
    Dec(srcLen, lengthAvailable);
    if dstPtr = dstFragment.DataStart then
    begin
      if Dst.__GetWritableFragment(0, Dst, 0, gfPrevFragment, dstFragment)=nil then Break;
      dstPtr := dstFragment.DataEnd;
    end;
    if srcPtr = srcFragment.DataStart then
    begin
      if Src.__GetReadableFragment(0, Src, 0, gfPrevFragment, srcFragment)=nil then Break;
      srcPtr := srcFragment.DataEnd;
    end;
  end;
end;

procedure nsAString.SetCapacity(aCapacity: Longword);
begin
  // no operation for nsAString
end;

procedure nsAString.SetLength(aLength: Longword);
begin
  // no operation for nsAString
end;

function nsAString.GetSharedBufferHandle(): PSharedBufferHandleW;
begin
  Result := nil;
end;

function nsAString.GetFlatBufferHandle(): PBufferHandleW;
begin
  Result := PBufferHandleW(GetSharedBufferHandle);
end;

function nsAString.GetBufferHandle(): PBufferHandleW;
begin
  Result := PBufferHandleW(GetSharedBufferHandle);
end;

function nsAString.GetImplementationFlags(): Longword;
begin
  Result := 0;
end;

function nsAString.IsVoid(): LongBool;
begin
  Result := False;
end;

procedure nsAString.SetVoid(aVoid: LongBool);
begin
  // |SetIsVoid| is ignored by default
end;

function nsAString.IsDependentOn(const Source: nsAString): LongBool;
var
  p1, p2: PWideChar;
  f1, f2: nsReadableFragmentW;
begin
  p1 := __GetReadableFragment(0, Self, 0, gfFirstFragment, f1);
  while Assigned(p1) do
  begin
    p2 := Source.__GetReadableFragment(0, Source, 0, gfFirstFragment, f2);
    while Assigned(p2) do
    begin
      if (f2.DataStart < f1.DataEnd) and (f2.DataEnd > f1.DataStart) then
      begin
        Result := True;
        Exit;
      end;
      p2 := Source.__GetReadableFragment(0, Source, 0, gfNextFragment, f2);
    end;
    p1 := __GetReadableFragment(0, Self, 0, gfNextFragment, f1);
  end;
  Result := False;
end;

procedure nsAString.Assign(const Source: nsAString);
var
  srcLength: Longword;
  temp: nsAString;
  buffer: PWideChar;
begin
  if Source = Self then Exit;
  if not Source.IsDependentOn(Self) then
    UncheckedAssign(Source)
  else
  begin
    srcLength := Source.__GetLength(0, Source);
    try
      GetMem(buffer, srcLength * SizeOf(WideChar));
    except
      Exit;
    end;
    Copy(buffer, Self, 0, __GetLength(0, Self));
    temp := nsDependentString.Create(buffer, srcLength);
    UncheckedAssign(temp);
    temp.Free;
    FreeMem(buffer);
  end;
end;

procedure nsAString.UncheckedAssign(const Source: nsAString);
var
  srcLength: Longword;
begin
  __SetLength(0, Self, 0);
  srcLength := Source.__GetLength(0, Source);
  if srcLength > 0 then
  begin
    __SetLength(0, Self, srcLength);
    Copy(Self, 0, Source, 0, srcLength);
  end;
end;

procedure nsAString.Assign(Source: PWideChar);
var
  temp: nsAString;
begin
  temp := nsDependentString.Create(Source);
  Assign(temp);
  temp.Free;
end;

procedure nsAString.Assign(Source: PWideChar; aLength: Longword);
var
  temp: nsAString;
begin
  temp := nsDependentString.Create(Source, aLength);
  Assign(temp);
  temp.Free;
end;

procedure nsAString.Assign(Source: WideChar);
var
  temp: nsAString;
begin
  temp := nsDependentString.Create(@Source, 1);
  Assign(temp);
  temp.Free;
end;

procedure nsAString.Append(const Source: nsAString);
var
  srcLength: Longword;
  temp: nsAString;
  buffer: PWideChar;
begin
  if not Source.IsDependentOn(Self) then
    UncheckedAppend(Source)
  else
  begin
    srcLength := Source.__GetLength(0, Source);
    try
      GetMem(buffer, srcLength * SizeOf(WideChar));
    except
      Exit;
    end;
    Copy(buffer, Self, 0, __GetLength(0, Self));
    temp := nsDependentString.Create(buffer, srcLength);
    UncheckedAppend(temp);
    temp.Free;
    FreeMem(buffer);
  end;
end;

procedure nsAString.UncheckedAppend(const Source: nsAString);
var
  srcLength: Longword;
  newLength: Longword;
  oldLength: Longword;
begin
  srcLength := Source.__GetLength(0, Source);
  if srcLength > 0 then
  begin
    oldLength := __GetLength(0, Self);
    newLength := srcLength + oldLength;
    __SetLength(0, Self, newLength);
    Copy(Self, oldLength, Source, 0, srcLength);
  end;
end;

procedure nsAString.Append(Source: PWideChar);
var
  temp: nsAString;
begin
  temp := nsDependentString.Create(Source);
  Append(temp);
  temp.Free;
end;

procedure nsAString.Append(Source: PWideChar; aLength: Longword);
var
  temp: nsAString;
begin
  temp := nsDependentString.Create(Source, aLength);
  Append(temp);
  temp.Free;
end;

procedure nsAString.Append(Source: WideChar);
var
  temp: nsAString;
begin
  temp := nsDependentString.Create(@Source, 1);
  Append(temp);
  temp.Free;
end;

procedure nsAString.Insert(const Source: nsAString; aPosition: Longword);
var
  srcLength: Longword;
  temp: nsAString;
  buffer: PWideChar;
begin
  if not Source.IsDependentOn(Self) then
    UncheckedInsert(Source, aPosition)
  else
  begin
    srcLength := Source.__GetLength(0, Source);
    try
      GetMem(buffer, srcLength * SizeOf(WideChar));
    except
      Exit;
    end;
    Copy(buffer, Self, 0, __GetLength(0, Self));
    temp := nsDependentString.Create(buffer, srcLength);
    UncheckedInsert(temp, aPosition);
    temp.Free;
    FreeMem(buffer);
  end;
end;

procedure nsAString.UncheckedInsert(const Source: nsAString; aPosition: Longword);
var
  srcLength: Longword;
  newLength: Longword;
  oldLength: Longword;
begin
  srcLength := Source.__GetLength(0, Source);
  if srcLength > 0 then
  begin
    oldLength := __GetLength(0, Self);
    if aPosition>__GetLength(0, Self) then aPosition := oldLength;
    newLength := srcLength + oldLength;
    __SetLength(0, Self, newLength);
    CopyBack(Self, aPosition+srcLength, Self, aPosition, oldLength-aPosition);
    Copy(Self, aPosition, Source, 0, srcLength);
  end;
end;

procedure nsAString.Insert(Source: PWideChar; aPosition: Longword);
var
  temp: nsAString;
begin
  temp := nsDependentString.Create(Source);
  Insert(temp, aPosition);
  temp.Free;
end;

procedure nsAString.Insert(Source: PWideChar; aPosition, aLength: Longword);
var
  temp: nsAString;
begin
  temp := nsDependentString.Create(Source, aLength);
  Insert(temp, aPosition);
  temp.Free;
end;

procedure nsAString.Insert(Source: WideChar; aPosition: Longword);
var
  temp: nsAString;
begin
  temp := nsDependentString.Create(@Source, 1);
  Insert(temp, aPosition);
  temp.Free;
end;

procedure nsAString.Replace(aPosition, aLength: Longword; const Source: nsAString);
var
  srcLength: Longword;
  temp: nsAString;
  buffer: PWideChar;
begin
  if not Source.IsDependentOn(Self) then
    UncheckedReplace(aPosition, aLength, Source)
  else
  begin
    srcLength := Source.__GetLength(0, Source);
    try
      GetMem(buffer, srcLength * SizeOf(WideChar));
    except
      Exit;
    end;
    Copy(buffer, Self, 0, __GetLength(0, Self));
    temp := nsDependentString.Create(buffer, srcLength);
    UncheckedReplace(aPosition, aLength, temp);
    temp.Free;
    FreeMem(buffer);
  end;
end;

procedure nsAString.UncheckedReplace(aPosition, aLength: Longword; const Source: nsAString);
var
  srcLength: Longword;
  newLength: Longword;
  oldLength: Longword;
begin
  srcLength := Source.__GetLength(0, Source);
  if srcLength > 0 then
  begin
    oldLength := __GetLength(0, Self);
    if aPosition>oldLength then Exit;
    if aPosition+aLength>oldLength then aLength := oldLength - aPosition;

    newLength := srcLength + oldLength - aLength;
    if newLength > oldLength then
    begin
      __SetLength(0, Self, newLength);
      CopyBack(Self, aPosition+srcLength, Self, aPosition+aLength, oldLength-aPosition-aLength);
      Copy(Self, aPosition, Source, 0, srcLength);
    end else
    begin
      Copy(Self, aPosition+srcLength, Self, aPosition+aLength, oldLength-aPosition-aLength);
      Copy(Self, aPosition, Source, 0, srcLength);
      __SetLength(0, Self, newLength);
    end;
  end;
end;

procedure nsAString.Cut(cutStart, cutLength: Longword);
var
  oldLength, newLength: Longword;
begin
  oldLength := __GetLength(0, Self);
  if cutStart > oldLength then Exit;
  if cutStart + cutLength > oldLength then cutLength := oldLength - cutStart;

  newLength := oldLength - cutLength;
  Copy(Self, cutStart, Self, cutStart+cutLength, oldLength-cutLength-cutStart);
  __SetLength(0, Self, newLength);
end;

function nsASingleFragmentString.GetLength(): Longword;
var
  handle: PBufferHandleW;
begin
  handle := __GetBufferHandle(0, Self);
  if Assigned(handle) then
    Result := handle^.DataEnd - handle^.DataStart
  else
    Result := 0;
end;

function nsASingleFragmentString.GetReadableFragment(var aFragment: nsReadableFragmentW; aRequest, aPosition: Longword): PWideChar;
var
  handle: PBufferHandleW;
begin
  case aRequest of
  gfFirstFragment, gfLastFragment, gfFragmentAt:
    begin
      handle := __GetBufferHandle(0, Self);
      if not Assigned(handle) then
      begin
        Result := nil;
        Exit;
      end;
      aFragment.DataStart := handle.DataStart;
      aFragment.DataEnd := handle.DataEnd;
      Result := handle.DataStart + aPosition;
    end;
  else
    Result := nil;
  end;
end;

function nsASingleFragmentString.GetWritableFragment(var aFragment: nsWritableFragmentW; aRequest, aPosition: Longword): PWideChar;
var
  handle: PBufferHandleW;
begin
  case aRequest of
  gfFirstFragment, gfLastFragment, gfFragmentAt:
    begin
      handle := __GetBufferHandle(0, Self);
      if not Assigned(handle) then
      begin
        Result := nil;
        Exit;
      end;
      aFragment.DataStart := handle.DataStart;
      aFragment.DataEnd := handle.DataEnd;
      Result := handle.DataStart + aPosition;
    end;
  else
    Result := nil;
  end;
end;

function nsAFlatString.GetPtr(): PWideChar;
var
  fragment: nsReadableFragmentW;
begin
  __GetReadableFragment(0, Self, 0, gfFirstFragment, fragment);
  Result := fragment.DataStart;
end;

procedure Copy(dst, src: PAnsiChar; lengthToCopy: Longword); overload;
asm
  push edi
  push esi

  mov edi, eax
  mov esi, edx
  cld
  rep movsb

  pop esi
  pop edi
end;

procedure Copy(Dst: nsACString; dstPos: Longword;  Src: nsACString; srcPos, srcLen: Longword); overload;
var
  srcFragment: nsReadableFragmentA;
  dstFragment: nsWritableFragmentA;
  srcPtr, dstPtr: PAnsiChar;
  fragmentLength: Longword;
  lengthAvailable: Longword;
  d, s: Longword;
begin
  dstPtr := Dst.__GetWritableFragment(0, Dst, 0, gfFirstFragment, dstFragment);
  if not Assigned(dstPtr) then Exit;
  while dstPos > 0 do
  begin
    fragmentLength := dstFragment.DataEnd - dstFragment.DataStart;
    if dstPos < fragmentLength then
    begin
      dstPtr := dstPtr + dstPos;
      Break;
    end;
    dstPtr := Dst.__GetWritableFragment(0, Dst, 0, gfNextFragment, dstFragment);
    if not Assigned(dstPtr) then Exit;
  end;

  srcPtr := Src.__GetReadableFragment(0, Src, 0, gfFirstFragment, srcFragment);
  if not Assigned(srcPtr) then Exit;
  while srcPos > 0 do
  begin
    fragmentLength := srcFragment.DataEnd - srcFragment.DataStart;
    if srcPos < fragmentLength then
    begin
      srcPtr := srcPtr + srcPos;
      Break;
    end;
    srcPtr := Src.__GetReadableFragment(0, Src, 0, gfNextFragment, srcFragment);
    if not Assigned(srcPtr) then Exit;
  end;

  while srcLen > 0 do
  begin
    d := dstFragment.DataEnd - dstPtr;
    s := srcFragment.DataEnd - srcPtr;
    if s>d then lengthAvailable:=d else lengthAvailable:=s;
    if srcLen < lengthAvailable then lengthAvailable := srcLen;
    Copy(dstPtr, srcPtr, lengthAvailable);
    Inc(dstPtr, lengthAvailable);
    Inc(srcPtr, lengthAvailable);
    Dec(srcLen, lengthAvailable);
    if dstPtr = dstFragment.DataEnd then
    begin
      if Dst.__GetWritableFragment(0, Dst, 0, gfNextFragment, dstFragment)=nil then Break;
      dstPtr := dstFragment.DataStart;
    end;
    if srcPtr = srcFragment.DataEnd then
    begin
      if Src.__GetReadableFragment(0, Src, 0, gfNextFragment, srcFragment)=nil then Break;
      srcPtr := srcFragment.DataStart;
    end;
  end;
end;

procedure Copy(dstPtr: PAnsiChar; Src: nsACString; srcPos, srcLen: Longword); overload;
var
  srcFragment: nsReadableFragmentA;
  srcPtr: PAnsiChar;
  fragmentLength: Longword;
  s: Longword;
begin
  srcPtr := Src.__GetReadableFragment(0, Src, 0, gfFirstFragment, srcFragment);
  if not Assigned(srcPtr) then Exit;
  while srcPos > 0 do
  begin
    fragmentLength := srcFragment.DataEnd - srcFragment.DataStart;
    if srcPos < fragmentLength then
    begin
      srcPtr := srcPtr + srcPos;
      Break;
    end;
    srcPtr := Src.__GetReadableFragment(0, Src, 0, gfNextFragment, srcFragment);
    if not Assigned(srcPtr) then Exit;
  end;

  while srcLen > 0 do
  begin
    s := srcFragment.DataEnd - srcPtr;
    if s>srcLen then s := srcLen;
    Copy(dstPtr, srcPtr, s);
    Inc(dstPtr, s); Inc(srcPtr, s); Dec(srcLen, s);
    if srcPtr = srcFragment.DataEnd then
    begin
      if Src.__GetReadableFragment(0, Src, 0, gfNextFragment, srcFragment)=nil then Break;
      srcPtr := srcFragment.DataStart;
    end;
  end;
end;

procedure CopyBack(dst, src: PAnsiChar; lengthToCopy: Longword); overload;
asm
  push edi
  push esi

  mov edi, eax
  mov esi, edx
  dec edi
  dec esi

  std
  rep movsb

  pop esi
  pop edi
end;

procedure CopyBack(Dst: nsACString; dstPos: Longword;  Src: nsACString; srcPos, srcLen: Longword); overload;
var
  srcFragment: nsReadableFragmentA;
  dstFragment: nsWritableFragmentA;
  srcPtr, dstPtr: PAnsiChar;
  fragmentLength: Longword;
  s, d: Longword;
  lengthAvailable: Longword;
begin
  Inc(srcPos, srcLen);
  Inc(dstPos, srcLen);
  if (srcPos>Src.__GetLength(0, Src)) or (dstPos>Dst.__GetLength(0, Dst)) then Exit;

  dstPtr := Dst.__GetWritableFragment(0, Dst, 0, gfFirstFragment, dstFragment);
  if not Assigned(dstPtr) then Exit;
  while dstPos > 0 do
  begin
    fragmentLength := dstFragment.DataEnd - dstFragment.DataStart;
    if dstPos <= fragmentLength then
    begin
      dstPtr := dstPtr + dstPos;
      Break;
    end;
    dstPtr := Dst.__GetWritableFragment(0, Dst, 0, gfNextFragment, dstFragment);
    if not Assigned(dstPtr) then Exit;
  end;

  srcPtr := Src.__GetReadableFragment(0, Src, 0, gfFirstFragment, srcFragment);
  if not Assigned(srcPtr) then Exit;
  while srcPos > 0 do
  begin
    fragmentLength := srcFragment.DataEnd - srcFragment.DataStart;
    if srcPos <= fragmentLength then
    begin
      srcPtr := srcPtr + srcPos;
      Break;
    end;
    srcPtr := Src.__GetReadableFragment(0, Src, 0, gfNextFragment, srcFragment);
    if not Assigned(srcPtr) then Exit;
  end;

  while srcLen > 0 do
  begin
    d := dstPtr - dstFragment.DataStart;
    s := srcPtr - srcFragment.DataStart;
    if d<s then lengthAvailable:=d else lengthAvailable:=s;
    if lengthAvailable>srcLen then lengthAvailable:=srcLen;
    CopyBack(dstPtr, srcPtr, lengthAvailable);
    Dec(dstPtr, lengthAvailable);
    Dec(srcPtr, lengthAvailable);
    Dec(srcLen, lengthAvailable);
    if dstPtr = dstFragment.DataStart then
    begin
      if Dst.__GetWritableFragment(0, Dst, 0, gfPrevFragment, dstFragment)=nil then Break;
      dstPtr := dstFragment.DataEnd;
    end;
    if srcPtr = srcFragment.DataStart then
    begin
      if Src.__GetReadableFragment(0, Src, 0, gfPrevFragment, srcFragment)=nil then Break;
      srcPtr := srcFragment.DataEnd;
    end;
  end;
end;

procedure nsACString.SetCapacity(aCapacity: Longword);
begin
  // no operation for nsACString
end;

procedure nsACString.SetLength(aLength: Longword);
begin
  // no operation for nsACString
end;

function nsACString.GetSharedBufferHandle(): PSharedBufferHandleA;
begin
  Result := nil;
end;

function nsACString.GetFlatBufferHandle(): PBufferHandleA;
begin
  Result := PBufferHandleA(GetSharedBufferHandle);
end;

function nsACString.GetBufferHandle(): PBufferHandleA;
begin
  Result := PBufferHandleA(GetSharedBufferHandle);
end;

function nsACString.GetImplementationFlags(): Longword;
begin
  Result := 0;
end;

function nsACString.IsVoid(): LongBool;
begin
  Result := False;
end;

procedure nsACString.SetVoid(aVoid: LongBool);
begin
  // |SetIsVoid| is ignored by default
end;

function nsACString.IsDependentOn(const Source: nsACString): LongBool;
var
  p1, p2: PAnsiChar;
  f1, f2: nsReadableFragmentA;
begin
  p1 := __GetReadableFragment(0, Self, 0, gfFirstFragment, f1);
  while Assigned(p1) do
  begin
    p2 := Source.__GetReadableFragment(0, Source, 0, gfFirstFragment, f2);
    while Assigned(p2) do
    begin
      if (f2.DataStart < f1.DataEnd) and (f2.DataEnd > f1.DataStart) then
      begin
        Result := True;
        Exit;
      end;
      p2 := Source.__GetReadableFragment(0, Source, 0, gfNextFragment, f2);
    end;
    p1 := __GetReadableFragment(0, Self, 0, gfNextFragment, f1);
  end;
  Result := False;
end;

procedure nsACString.Assign(const Source: nsACString);
var
  srcLength: Longword;
  temp: nsACString;
  buffer: PAnsiChar;
begin
  if Source = Self then Exit;
  if not Source.IsDependentOn(Self) then
    UncheckedAssign(Source)
  else
  begin
    srcLength := Source.__GetLength(0, Source);
    try
      GetMem(buffer, srcLength * SizeOf(AnsiChar));
    except
      Exit;
    end;
    Copy(buffer, Self, 0, __GetLength(0, Self));
    temp := nsDependentCString.Create(buffer, srcLength);
    UncheckedAssign(temp);
    temp.Free;
    FreeMem(buffer);
  end;
end;

procedure nsACString.UncheckedAssign(const Source: nsACString);
var
  srcLength: Longword;
begin
  __SetLength(0, Self, 0);
  srcLength := Source.__GetLength(0, Source);
  if srcLength > 0 then
  begin
    __SetLength(0, Self, srcLength);
    Copy(Self, 0, Source, 0, srcLength);
  end;
end;

procedure nsACString.Assign(Source: PAnsiChar);
var
  temp: nsACString;
begin
  temp := nsDependentCString.Create(Source);
  Assign(temp);
  temp.Free;
end;

procedure nsACString.Assign(Source: PAnsiChar; aLength: Longword);
var
  temp: nsACString;
begin
  temp := nsDependentCString.Create(Source, aLength);
  Assign(temp);
  temp.Free;
end;

procedure nsACString.Assign(Source: AnsiChar);
var
  temp: nsACString;
begin
  temp := nsDependentCString.Create(@Source, 1);
  Assign(temp);
  temp.Free;
end;

procedure nsACString.Append(const Source: nsACString);
var
  srcLength: Longword;
  temp: nsACString;
  buffer: PAnsiChar;
begin
  if not Source.IsDependentOn(Self) then
    UncheckedAppend(Source)
  else
  begin
    srcLength := Source.__GetLength(0, Source);
    try
      GetMem(buffer, srcLength * SizeOf(AnsiChar));
    except
      Exit;
    end;
    Copy(buffer, Self, 0, __GetLength(0, Self));
    temp := nsDependentCString.Create(buffer, srcLength);
    UncheckedAppend(temp);
    temp.Free;
    FreeMem(buffer);
  end;
end;

procedure nsACString.UncheckedAppend(const Source: nsACString);
var
  srcLength: Longword;
  newLength: Longword;
  oldLength: Longword;
begin
  srcLength := Source.__GetLength(0, Source);
  if srcLength > 0 then
  begin
    oldLength := __GetLength(0, Self);
    newLength := srcLength + oldLength;
    __SetLength(0, Self, newLength);
    Copy(Self, oldLength, Source, 0, srcLength);
  end;
end;

procedure nsACString.Append(Source: PAnsiChar);
var
  temp: nsACString;
begin
  temp := nsDependentCString.Create(Source);
  Append(temp);
  temp.Free;
end;

procedure nsACString.Append(Source: PAnsiChar; aLength: Longword);
var
  temp: nsACString;
begin
  temp := nsDependentCString.Create(Source, aLength);
  Append(temp);
  temp.Free;
end;

procedure nsACString.Append(Source: AnsiChar);
var
  temp: nsACString;
begin
  temp := nsDependentCString.Create(@Source, 1);
  Append(temp);
  temp.Free;
end;

procedure nsACString.Insert(const Source: nsACString; aPosition: Longword);
var
  srcLength: Longword;
  temp: nsACString;
  buffer: PAnsiChar;
begin
  if not Source.IsDependentOn(Self) then
    UncheckedInsert(Source, aPosition)
  else
  begin
    srcLength := Source.__GetLength(0, Source);
    try
      GetMem(buffer, srcLength * SizeOf(AnsiChar));
    except
      Exit;
    end;
    Copy(buffer, Self, 0, __GetLength(0, Self));
    temp := nsDependentCString.Create(buffer, srcLength);
    UncheckedInsert(temp, aPosition);
    temp.Free;
    FreeMem(buffer);
  end;
end;

procedure nsACString.UncheckedInsert(const Source: nsACString; aPosition: Longword);
var
  srcLength: Longword;
  newLength: Longword;
  oldLength: Longword;
begin
  srcLength := Source.__GetLength(0, Source);
  if srcLength > 0 then
  begin
    oldLength := __GetLength(0, Self);
    if aPosition>__GetLength(0, Self) then aPosition := oldLength;
    newLength := srcLength + oldLength;
    __SetLength(0, Self, newLength);
    CopyBack(Self, aPosition+srcLength, Self, aPosition, oldLength-aPosition);
    Copy(Self, aPosition, Source, 0, srcLength);
  end;
end;

procedure nsACString.Insert(Source: PAnsiChar; aPosition: Longword);
var
  temp: nsACString;
begin
  temp := nsDependentCString.Create(Source);
  Insert(temp, aPosition);
  temp.Free;
end;

procedure nsACString.Insert(Source: PAnsiChar; aPosition, aLength: Longword);
var
  temp: nsACString;
begin
  temp := nsDependentCString.Create(Source, aLength);
  Insert(temp, aPosition);
  temp.Free;
end;

procedure nsACString.Insert(Source: AnsiChar; aPosition: Longword);
var
  temp: nsACString;
begin
  temp := nsDependentCString.Create(@Source, 1);
  Insert(temp, aPosition);
  temp.Free;
end;

procedure nsACString.Replace(aPosition, aLength: Longword; const Source: nsACString);
var
  srcLength: Longword;
  temp: nsACString;
  buffer: PAnsiChar;
begin
  if not Source.IsDependentOn(Self) then
    UncheckedReplace(aPosition, aLength, Source)
  else
  begin
    srcLength := Source.__GetLength(0, Source);
    try
      GetMem(buffer, srcLength * SizeOf(AnsiChar));
    except
      Exit;
    end;
    Copy(buffer, Self, 0, __GetLength(0, Self));
    temp := nsDependentCString.Create(buffer, srcLength);
    UncheckedReplace(aPosition, aLength, temp);
    temp.Free;
    FreeMem(buffer);
  end;
end;

procedure nsACString.UncheckedReplace(aPosition, aLength: Longword; const Source: nsACString);
var
  srcLength: Longword;
  newLength: Longword;
  oldLength: Longword;
begin
  srcLength := Source.__GetLength(0, Source);
  if srcLength > 0 then
  begin
    oldLength := __GetLength(0, Self);
    if aPosition>oldLength then Exit;
    if aPosition+aLength>oldLength then aLength := oldLength - aPosition;

    newLength := srcLength + oldLength - aLength;
    if newLength > oldLength then
    begin
      __SetLength(0, Self, newLength);
      CopyBack(Self, aPosition+srcLength, Self, aPosition+aLength, oldLength-aPosition-aLength);
      Copy(Self, aPosition, Source, 0, srcLength);
    end else
    begin
      Copy(Self, aPosition+srcLength, Self, aPosition+aLength, oldLength-aPosition-aLength);
      Copy(Self, aPosition, Source, 0, srcLength);
      __SetLength(0, Self, newLength);
    end;
  end;
end;

procedure nsACString.Cut(cutStart, cutLength: Longword);
var
  oldLength, newLength: Longword;
begin
  oldLength := __GetLength(0, Self);
  if cutStart > oldLength then Exit;
  if cutStart + cutLength > oldLength then cutLength := oldLength - cutStart;

  newLength := oldLength - cutLength;
  Copy(Self, cutStart, Self, cutStart+cutLength, oldLength-cutLength-cutStart);
  __SetLength(0, Self, newLength);
end;

function nsASingleFragmentCString.GetLength(): Longword;
var
  handle: PBufferHandleA;
begin
  handle := __GetBufferHandle(0, Self);
  if Assigned(handle) then
    Result := handle^.DataEnd - handle^.DataStart
  else
    Result := 0;
end;

function nsASingleFragmentCString.GetReadableFragment(var aFragment: nsReadableFragmentA; aRequest, aPosition: Longword): PAnsiChar;
var
  handle: PBufferHandleA;
begin
  case aRequest of
  gfFirstFragment, gfLastFragment, gfFragmentAt:
    begin
      handle := __GetBufferHandle(0, Self);
      if not Assigned(handle) then
      begin
        Result := nil;
        Exit;
      end;
      aFragment.DataStart := handle.DataStart;
      aFragment.DataEnd := handle.DataEnd;
      Result := handle.DataStart + aPosition;
    end;
  else
    Result := nil;
  end;
end;

function nsASingleFragmentCString.GetWritableFragment(var aFragment: nsWritableFragmentA; aRequest, aPosition: Longword): PAnsiChar;
var
  handle: PBufferHandleA;
begin
  case aRequest of
  gfFirstFragment, gfLastFragment, gfFragmentAt:
    begin
      handle := __GetBufferHandle(0, Self);
      if not Assigned(handle) then
      begin
        Result := nil;
        Exit;
      end;
      aFragment.DataStart := handle.DataStart;
      aFragment.DataEnd := handle.DataEnd;
      Result := handle.DataStart + aPosition;
    end;
  else
    Result := nil;
  end;
end;

function nsAFlatCString.GetPtr(): PAnsiChar;
var
  fragment: nsReadableFragmentA;
begin
  GetReadableFragment(fragment, gfFirstFragment, 0);
  Result := fragment.DataStart;
end;

function Compare(lhs, rhs: PWideChar; lengthToCompare: Longword): Integer; overload;
asm
  push edi
  push esi

  mov esi, eax
  mov edi, edx

  cld

@Loop1:
  lodsw
  scasw
  jne @LoopOut
  loop @Loop1

@LoopOut:
  sub ax, [edi-2]
  movsx eax, ax

  pop esi
  pop edi
end;

function Compare(const lhs, rhs: nsAString): Integer;
var
  lLength, rLength: Longword;
  lFragment, rFragment: nsReadableFragmentW;
  lPtr, rPtr: PWideChar;
  lengthToCompare, lengthAvailable: Longword;
  lTemp, rTemp: Longword;
begin
  lLength := lhs.__GetLength(0, lhs);
  rLength := rhs.__GetLength(0, rhs);
  if lLength<rLength then
    lengthToCompare := lLength
  else
    lengthToCompare := rLength;

  lPtr := lhs.__GetReadableFragment(0, lhs, 0, gfFirstFragment, lFragment);
  rPtr := rhs.__GetReadableFragment(0, rhs, 0, gfFirstFragment, rFragment);

  while lengthToCompare > 0 do
  begin
    lTemp := lFragment.DataEnd - lPtr;
    rTemp := rFragment.DataEnd - rPtr;
    if lTemp<rTemp then
      lengthAvailable := lTemp
    else
      lengthAvailable := rTemp;
    if lengthAvailable > lengthToCompare then
      lengthAvailable := lengthToCompare;

    Result := Compare(lPtr, rPtr, lengthAvailable);
    if Result <> 0 then Exit;

    Inc(lPtr, lengthAvailable);
    Inc(rPtr, lengthAvailable);
    if lPtr = lFragment.DataEnd then
      lPtr := lhs.__GetReadableFragment(0, lhs, 0, gfNextFragment, lFragment);
    if rPtr = rFragment.DataEnd then
      rPtr := rhs.__GetReadableFragment(0, rhs, 0, gfNextFragment, rFragment);
    Dec(lengthToCompare, lengthAvailable);
  end;

  if lLength < rLength then
    Result := -1
  else
  if lLength > rLength then
    Result := 1
  else
    Result := 0;
end;

function Compare(lhs, rhs: PAnsiChar; lengthToCompare: Longword): Integer; overload;
asm
  push edi
  push esi

  mov esi, eax
  mov edi, edx

  cld

@Loop1:
  lodsb
  scasb
  jne @LoopOut
  loop @Loop1

@LoopOut:
  sub al, [edi-1]
  movsx eax, al

  pop esi
  pop edi
end;

function Compare(const lhs, rhs: nsACString): Integer;
var
  lLength, rLength: Longword;
  lFragment, rFragment: nsReadableFragmentA;
  lPtr, rPtr: PAnsiChar;
  lengthToCompare, lengthAvailable: Longword;
  lTemp, rTemp: Longword;
begin
  lLength := lhs.__GetLength(0, lhs);
  rLength := rhs.__GetLength(0, rhs);
  if lLength<rLength then
    lengthToCompare := lLength
  else
    lengthToCompare := rLength;

  lPtr := lhs.__GetReadableFragment(0, lhs, 0, gfFirstFragment, lFragment);
  rPtr := rhs.__GetReadableFragment(0, rhs, 0, gfFirstFragment, rFragment);

  while lengthToCompare > 0 do
  begin
    lTemp := lFragment.DataEnd - lPtr;
    rTemp := rFragment.DataEnd - rPtr;
    if lTemp<rTemp then
      lengthAvailable := lTemp
    else
      lengthAvailable := rTemp;
    if lengthAvailable > lengthToCompare then
      lengthAvailable := lengthToCompare;

    Result := Compare(lPtr, rPtr, lengthAvailable);
    if Result <> 0 then Exit;

    Inc(lPtr, lengthAvailable);
    Inc(rPtr, lengthAvailable);
    if lPtr = lFragment.DataEnd then
      lPtr := lhs.__GetReadableFragment(0, lhs, 0, gfNextFragment, lFragment);
    if rPtr = rFragment.DataEnd then
      rPtr := rhs.__GetReadableFragment(0, rhs, 0, gfNextFragment, rFragment);
    Dec(lengthToCompare, lengthAvailable);
  end;

  if lLength < rLength then
    Result := -1
  else
  if lLength > rLength then
    Result := 1
  else
    Result := 0;
end;

procedure nsAString.__Destruct(Dummy: Cardinal; This: nsAString);
begin
  This.Free;
end;

procedure nsAString.__SetVoid(Dummy: Cardinal; This: nsAString; aVoid: LongBool);
begin
  This.SetVoid(aVoid);
end;

procedure nsAString.__SetCapacity(Dummy: Cardinal; This: nsAString; aCapacity: Longword);
begin
  This.SetCapacity(aCapacity);
end;

procedure nsAString.__SetLength(Dummy: Cardinal; This: nsAString; aLength: Longword);
begin
  This.SetLength(aLength);
end;

procedure nsAString.__Cut(Dummy: Cardinal; This: nsAString; cutLength, cutStart: Longword);
begin
  This.Cut(cutStart, cutLength);
end;

procedure nsAString.__Assign(Dummy: Cardinal; This: nsAString; const Source: nsAString);
begin
  This.Assign(Source);
end;

procedure nsAString.__Assign(Dummy: Cardinal; This: nsAString; Source: PWideChar);
begin
  This.Assign(Source);
end;

procedure nsAString.__Assign(Dummy: Cardinal; This: nsAString; aLength: Longword; Source: PWideChar);
begin
  This.Assign(Source, aLength);
end;

procedure nsAString.__Assign(Dummy: Cardinal; This: nsAString; Source: WideChar);
begin
  This.Assign(Source);
end;

procedure nsAString.__Append(Dummy: Cardinal; This: nsAString; const Source: nsAString);
begin
  This.Append(Source);
end;

procedure nsAString.__Append(Dummy: Cardinal; This: nsAString; Source: PWideChar);
begin
  This.Append(Source);
end;

procedure nsAString.__Append(Dummy: Cardinal; This: nsAString; aLength: Longword; Source: PWideChar);
begin
  This.Append(Source, aLength);
end;

procedure nsAString.__Append(Dummy: Cardinal; This: nsAString; Source: WideChar);
begin
  This.Append(Source);
end;

procedure nsAString.__Insert(Dummy: Cardinal; This: nsAString; aPosition: Longword; const Source: nsAString);
begin
  This.Insert(Source, aPosition);
end;

procedure nsAString.__Insert(Dummy: Cardinal; This: nsAString; aPosition: Longword; Source: PWideChar);
begin
  This.Insert(Source, aPosition);
end;

procedure nsAString.__Insert(Dummy: Cardinal; This: nsAString; aLength, aPosition: Longword; Source: PWideChar);
begin
  This.Insert(Source, aPosition, aLength);
end;

procedure nsAString.__Insert(Dummy: Cardinal; This: nsAString; aPosition: Longword; Source: WideChar);
begin
  This.Insert(Source, aPosition);
end;

procedure nsAString.__Replace(Dummy: Cardinal; This: nsAString; const Source: nsAString; aLength, aPosition: Longword);
begin
  This.Replace(aPosition, aLength, Source);
end;

function nsAString.__GetImplementationFlags(Dummy: Cardinal; This: nsAString): Longword;
begin
  Result := This.GetImplementationFlags;
end;

function nsAString.__GetFlatBufferHandle(Dummy: Cardinal; This: nsAString): PBufferHandleW;
begin
  Result := This.GetFlatBufferHandle;
end;

function nsAString.__GetBufferHandle(Dummy: Cardinal; This: nsAString): PBufferHandleW;
begin
  Result := This.GetBufferHandle;
end;

function nsAString.__GetSharedBufferHandle(Dummy: Cardinal; This: nsAString): PSharedBufferHandleW;
begin
  Result := This.GetSharedBufferHandle;
end;

function nsAString.__GetLength(Dummy: Cardinal; This: nsAString): Longword;
begin
  Result := This.GetLength;
end;

function nsAString.__IsVoid(Dummy: Cardinal; This: nsAString): LongBool;
begin
  Result := This.IsVoid;
end;

function nsAString.__GetReadableFragment(Dummy: Cardinal; This: nsAString; aPosition, aRequest: Longword;  var aFragment: nsReadableFragmentW): PWideChar;
begin
  Result := This.GetReadableFragment(aFragment, aRequest, aPosition);
end;

function nsAString.__GetWritableFragment(Dummy: Cardinal; This: nsAString; aPosition, aRequest: Longword; var aFragment: nsWritableFragmentW): PWideChar;
begin
  Result := This.GetWritableFragment(aFragment, aRequest, aPosition);
end;


procedure nsACString.__Destruct(Dummy: Cardinal; This: nsACString);
begin
  This.Free;
end;

procedure nsACString.__SetVoid(Dummy: Cardinal; This: nsACString; aVoid: LongBool);
begin
  This.SetVoid(aVoid);
end;

procedure nsACString.__SetCapacity(Dummy: Cardinal; This: nsACString; aCapacity: Longword);
begin
  This.SetCapacity(aCapacity);
end;

procedure nsACString.__SetLength(Dummy: Cardinal; This: nsACString; aLength: Longword);
begin
  This.SetLength(aLength);
end;

procedure nsACString.__Cut(Dummy: Cardinal; This: nsACString; cutLength, cutStart: Longword);
begin
  This.Cut(cutStart, cutLength);
end;

procedure nsACString.__Assign(Dummy: Cardinal; This: nsACString; const Source: nsACString);
begin
  This.Assign(Source);
end;

procedure nsACString.__Assign(Dummy: Cardinal; This: nsACString; Source: PAnsiChar);
begin
  This.Assign(Source);
end;

procedure nsACString.__Assign(Dummy: Cardinal; This: nsACString; aLength: Longword; Source: PAnsiChar);
begin
  This.Assign(Source, aLength);
end;

procedure nsACString.__Assign(Dummy: Cardinal; This: nsACString; Source: AnsiChar);
begin
  This.Assign(Source);
end;

procedure nsACString.__Append(Dummy: Cardinal; This: nsACString; const Source: nsACString);
begin
  This.Append(Source);
end;

procedure nsACString.__Append(Dummy: Cardinal; This: nsACString; Source: PAnsiChar);
begin
  This.Append(Source);
end;

procedure nsACString.__Append(Dummy: Cardinal; This: nsACString; aLength: Longword; Source: PAnsiChar);
begin
  This.Append(Source, aLength);
end;

procedure nsACString.__Append(Dummy: Cardinal; This: nsACString; Source: AnsiChar);
begin
  This.Append(Source);
end;

procedure nsACString.__Insert(Dummy: Cardinal; This: nsACString; aPosition: Longword; const Source: nsACString);
begin
  This.Insert(Source, aPosition);
end;

procedure nsACString.__Insert(Dummy: Cardinal; This: nsACString; aPosition: Longword; Source: PAnsiChar);
begin
  This.Insert(Source, aPosition);
end;

procedure nsACString.__Insert(Dummy: Cardinal; This: nsACString; aLength, aPosition: Longword; Source: PAnsiChar);
begin
  This.Insert(Source, aPosition, aLength);
end;

procedure nsACString.__Insert(Dummy: Cardinal; This: nsACString; aPosition: Longword; Source: AnsiChar);
begin
  This.Insert(Source, aPosition);
end;

procedure nsACString.__Replace(Dummy: Cardinal; This: nsACString; const Source: nsACString; aLength, aPosition: Longword);
begin
  This.Replace(aPosition, aLength, Source);
end;

function nsACString.__GetImplementationFlags(Dummy: Cardinal; This: nsACString): Longword;
begin
  Result := This.GetImplementationFlags;
end;

function nsACString.__GetFlatBufferHandle(Dummy: Cardinal; This: nsACString): PBufferHandleA;
begin
  Result := This.GetFlatBufferHandle;
end;

function nsACString.__GetBufferHandle(Dummy: Cardinal; This: nsACString): PBufferHandleA;
begin
  Result := This.GetBufferHandle;
end;

function nsACString.__GetSharedBufferHandle(Dummy: Cardinal; This: nsACString): PSharedBufferHandleA;
begin
  Result := This.GetSharedBufferHandle;
end;

function nsACString.__GetLength(Dummy: Cardinal; This: nsACString): Longword;
begin
  Result := This.GetLength;
end;

function nsACString.__IsVoid(Dummy: Cardinal; This: nsACString): LongBool;
begin
  Result := This.IsVoid;
end;

function nsACString.__GetReadableFragment(Dummy: Cardinal; This: nsACString; aPosition, aRequest: Longword;  var aFragment: nsReadableFragmentA): PAnsiChar;
begin
  Result := This.GetReadableFragment(aFragment, aRequest, aPosition);
end;

function nsACString.__GetWritableFragment(Dummy: Cardinal; This: nsACString; aPosition, aRequest: Longword; var aFragment: nsWritableFragmentA): PAnsiChar;
begin
  Result := This.GetWritableFragment(aFragment, aRequest, aPosition);
end;

procedure nsAString.Assign(Source: WideString);
begin
  Assign(PWideChar(Source));
end;

procedure nsAString.Assign(Source: WideString; aLength: Cardinal);
begin
  Assign(PWideChar(Source), aLength);
end;

procedure nsAString.Append(Source: WideString);
begin
  Assign(PWideChar(Source));
end;

procedure nsAString.Append(Source: WideString; aLength: Cardinal);
begin
  Assign(PWideChar(Source), aLength);
end;

procedure nsAString.Insert(Source: WideString; aPosition: Cardinal);
begin
  Insert(PWideChar(Source), aPosition);
end;

procedure nsAString.Insert(Source: WideString; aPosition, aLength: Cardinal);
begin
  Insert(PWideChar(Source),aPosition, aLength);
end;

procedure nsACString.Assign(Source: AnsiString);
begin
  Assign(PAnsiChar(Source));
end;

procedure nsACString.Assign(Source: AnsiString; aLength: Cardinal);
begin
  Assign(PAnsiChar(Source), aLength);
end;

procedure nsACString.Append(Source: AnsiString);
begin
  Assign(PAnsiChar(Source));
end;

procedure nsACString.Append(Source: AnsiString; aLength: Cardinal);
begin
  Assign(PAnsiChar(Source), aLength);
end;

procedure nsACString.Insert(Source: AnsiString; aPosition: Cardinal);
begin
  Insert(PAnsiChar(Source), aPosition);
end;

procedure nsACString.Insert(Source: AnsiString; aPosition, aLength: Cardinal);
begin
  Insert(PAnsiChar(Source),aPosition, aLength);
end;

type
  TIStringImpl = class(TInterfacedObject, IInterfacedString)
    FString: nsAString;
    FOwn: Boolean;

    constructor Create; overload;
    constructor Create(src: PWideChar); overload;
    constructor Create(src: WideString); overload;
    constructor Create(src: nsAString); overload;
    constructor Relate(src: nsAString; own: Boolean);
    destructor Destroy; override;

    function GetImplementationFlags: Longword;
    function GetFlatBufferHandle: PBufferHandleW;
    function GetBufferHandle: PBufferHandleW;
    function GetSharedBufferHandle: PSharedBufferHandleW;
    function GetLength: Longword;
    procedure SetLength(aLength: Longword);
    function GetIsVoid: Boolean;
    procedure SetIsVoid(aIsVoid: Boolean);
    procedure SetCapacity(aCapacity: Longword);
    procedure Cut(cutStart, cutLength: Longword);
    procedure Assign(Source: IInterfacedString); overload;
    procedure Assign(const Source: nsAString); overload;
    procedure Assign(Source: WideString); overload;
    procedure Append(Source: IInterfacedString); overload;
    procedure Append(const Source: nsAString); overload;
    procedure Append(Source: WideString); overload;
    procedure Insert(Source: IInterfacedString; aPosition: Longword); overload;
    procedure Insert(const Source: nsAString; aPosition: Longword); overload;
    procedure Insert(Source: WideString; aPosition: Longword); overload;
    procedure Replace(aPosition, aLength: Longword; const Source: nsAString); overload;
    procedure Replace(aPosition, aLength: Longword; Source: IInterfacedString); overload;
    function GetReadableFragment(var aFragment: nsReadableFragmentW; aRequest: Longword; aPosition: Longword = 0): PWideChar;
    function GetWritableFragment(var aFragment: nsWritableFragmentW; aRequest: Longword; aPosition: Longword = 0): PWideChar;
    function AString: nsAString;
    function ToString: WideString;
  end;

function NewString: IInterfacedString;
begin
  Result := TIStringImpl.Create;
end;

function NewString(src: PWideChar): IInterfacedString;
begin
  Result := TIStringImpl.Create(src);
end;

function NewString(src: WideString): IInterfacedString;
begin
  Result := TIStringImpl.Create(src);
end;

function NewString(src: nsAString): IInterfacedString;
begin
  Result := TIStringImpl.Create(src);
end;

function RelateString(src: nsAString; own: Boolean): IInterfacedString;
begin
  Result := TIStringImpl.Create(src, own);
end;

constructor TIStringImpl.Create;
begin
  inherited Create;
  FString := nsString.Create;
  FOwn := True;
end;

constructor TIStringImpl.Create(src: PWideChar);
begin
  inherited Create;
  FString := nsString.Create(src);
  FOwn := True;
  nsMemory.Free(src);
end;

constructor TIStringImpl.Create(src: WideString);
begin
  inherited Create;
  FString := nsString.Create(src);
  FOwn := True;
end;

constructor TIStringImpl.Create(src: nsAString);
begin
  inherited Create;
  FString := nsString.Create(src);
  FOwn := True;
end;

constructor TIStringImpl.Relate(src: nsAString; own: Boolean);
begin
  inherited Create;
  FString := src;
  FOwn := own;
end;

destructor TIStringImpl.Destroy;
begin
  if FOwn then FString.Free;
  inherited Destroy;
end;

function TIStringImpl.GetImplementationFlags: Longword;
begin
  Result := FString.__GetImplementationFlags(0, FString);
end;

function TIStringImpl.GetFlatBufferHandle: PBufferHandleW;
begin
  Result := FString.__GetFlatBufferHandle(0, FString);
end;

function TIStringImpl.GetBufferHandle: PBufferHandleW;
begin
  Result := FString.__GetBufferHandle(0, FString);
end;

function TIStringImpl.GetSharedBufferHandle: PSharedBufferHandleW;
begin
  Result := FString.__GetSharedBufferHandle(0, FString);
end;

function TIStringImpl.GetLength: Longword;
begin
  Result := FString.__GetLength(0, FString);
end;

procedure TIStringImpl.SetLength(aLength: Longword);
begin
  FString.__SetLength(0, FString, aLength);
end;

function TIStringImpl.GetIsVoid: Boolean;
begin
  Result := FString.__IsVoid(0, FString);
end;

procedure TIStringImpl.SetIsVoid(aIsVoid: Boolean);
begin
  FString.__SetVoid(0, FString, aIsVoid);
end;

procedure TIStringImpl.SetCapacity(aCapacity: Longword);
begin
  FString.__SetCapacity(0, FString, aCapacity);
end;

procedure TIStringImpl.Cut(cutStart, cutLength: Longword);
begin
  FString.__Cut(0, FString, cutLength, cutStart);
end;

procedure TIStringImpl.Assign(Source: IInterfacedString);
var
  AString: nsAString;
begin
  AString := Source.AString;
  FString.__Assign(0, FString, AString);
end;

procedure TIStringImpl.Assign(const Source: nsAString);
begin
  FString.__Assign(0, FString, Source);
end;

procedure TIStringImpl.Assign(Source: WideString);
begin
  FString.__Assign(0, FString, PWideChar(Source));
end;

procedure TIStringImpl.Append(Source: IInterfacedString);
var
  AString: nsAString;
begin
  AString := Source.AString;
  FString.__Append(0, FString, AString);
end;

procedure TIStringImpl.Append(const Source: nsAString);
begin
  FString.__Append(0, FString, Source);
end;

procedure TIStringImpl.Append(Source: WideString);
begin
  FString.__Append(0, FString, PWideChar(Source));
end;

procedure TIStringImpl.Insert(Source: IInterfacedString; aPosition: Longword);
var
  AString: nsAString;
begin
  AString := Source.AString;
  FString.__Insert(0, FString, aPosition, AString);
end;

procedure TIStringImpl.Insert(const Source: nsAString; aPosition: Longword);
begin
  FString.__Insert(0, FString, aPosition, Source);
end;

procedure TIStringImpl.Insert(Source: WideString; aPosition: Longword);
begin
  FString.__Insert(0, FString, aPosition, PWideChar(Source));
end;

procedure TIStringImpl.Replace(aPosition, aLength: Longword; Source: IInterfacedString);
var
  AString: nsAString;
begin
  AString := Source.AString;
  FString.__Replace(0, FString, AString, aLength, aPosition);
end;

procedure TIStringImpl.Replace(aPosition, aLength: Longword; const Source: nsAString);
begin
  FString.__Replace(0, FString, Source, aLength, aPosition);
end;

function TIStringImpl.GetReadableFragment(var aFragment: nsReadableFragmentW; aRequest: Longword; aPosition: Longword): PWideChar;
begin
  Result := FString.__GetReadableFragment(0, FString, aPosition, aRequest, aFragment);
end;

function TIStringImpl.GetWritableFragment(var aFragment: nsWritableFragmentW; aRequest: Longword; aPosition: Longword): PWideChar;
begin
  Result := FString.__GetWritableFragment(0, FString, aPosition, aRequest, aFragment);
end;

function TIStringImpl.AString: nsAString;
begin
  Result := FString;
end;

function TIStringImpl.ToString: WideString;
var
  ptr, dst: PWideChar;
  len, pos, frag_len: Longword;
  fragment: nsReadableFragmentW;
begin
  len := FString.__GetLength(0, FString);
  pos := 0;
  System.SetLength(Result, len);
  ptr := GetReadableFragment(fragment, gfFirstFragment);
  dst := PWideChar(Result);
  while (pos<len) and Assigned(ptr) do
  begin
    frag_len := (Cardinal(fragment.DataEnd) - Cardinal(fragment.DataStart)) div SizeOf(WideChar);
    Copy(dst, ptr, frag_len);
    Inc(dst, frag_len);
    ptr := GetReadableFragment(fragment, gfNextFragment);
  end;
end;

type
  TICStringImpl = class(TInterfacedObject, IInterfacedCString)
    FString: nsACString;
    FOwn: Boolean;

    constructor Create; overload;
    constructor Create(src: PAnsiChar); overload;
    constructor Create(src: AnsiString); overload;
    constructor Create(src: nsACString); overload;
    constructor Relate(src: nsACString; own: Boolean);
    destructor Destroy; override;

    function GetImplementationFlags: Longword;
    function GetFlatBufferHandle: PBufferHandleA;
    function GetBufferHandle: PBufferHandleA;
    function GetSharedBufferHandle: PSharedBufferHandleA;
    function GetLength: Longword;
    procedure SetLength(aLength: Longword);
    function GetIsVoid: Boolean;
    procedure SetIsVoid(aIsVoid: Boolean);
    procedure SetCapacity(aCapacity: Longword);
    procedure Cut(cutStart, cutLength: Longword);
    procedure Assign(Source: IInterfacedCString); overload;
    procedure Assign(const Source: nsACString); overload;
    procedure Assign(Source: AnsiString); overload;
    procedure Append(Source: IInterfacedCString); overload;
    procedure Append(const Source: nsACString); overload;
    procedure Append(Source: AnsiString); overload;
    procedure Insert(Source: IInterfacedCString; aPosition: Longword); overload;
    procedure Insert(const Source: nsACString; aPosition: Longword); overload;
    procedure Insert(Source: AnsiString; aPosition: Longword); overload;
    procedure Replace(aPosition, aLength: Longword; const Source: nsACString); overload;
    procedure Replace(aPosition, aLength: Longword; Source: IInterfacedCString); overload;
    function GetReadableFragment(var aFragment: nsReadableFragmentA; aRequest: Longword; aPosition: Longword = 0): PAnsiChar;
    function GetWritableFragment(var aFragment: nsWritableFragmentA; aRequest: Longword; aPosition: Longword = 0): PAnsiChar;
    function ACString: nsACString;
    function ToString: AnsiString;
  end;

function NewCString: IInterfacedCString;
begin
  Result := TICStringImpl.Create;
end;

function NewCString(src: PAnsiChar): IInterfacedCString;
begin
  Result := TICStringImpl.Create(src);
end;

function NewCString(src: AnsiString): IInterfacedCString;
begin
  Result := TICStringImpl.Create(src);
end;

function NewCString(src: nsACString): IInterfacedCString;
begin
  Result := TICStringImpl.Create(src);
end;

function RelateCString(src: nsACString; own: Boolean): IInterfacedString;
begin
  Result := TICStringImpl.Relate(src, own);
end;

constructor TICStringImpl.Create;
begin
  inherited Create;
  FString := nsCString.Create;
  FOwn := True;
end;

constructor TICStringImpl.Create(src: PAnsiChar);
begin
  inherited Create;
  FString := nsCString.Create(src);
  FOwn := True;
  nsMemory.Free(src);
end;

constructor TICStringImpl.Create(src: AnsiString);
begin
  inherited Create;
  FString := nsCString.Create(src);
  FOwn := True;
end;

constructor TICStringImpl.Create(src: nsACString);
begin
  inherited Create;
  FString := nsCString.Create(src);
  FOwn := True;
end;

constructor TICStringImpl.Relate(src: nsACString; own: Boolean);
begin
  inherited Create;
  FString := src;
  FOwn := own;
end;

destructor TICStringImpl.Destroy;
begin
  if FOwn then FString.Free;
  inherited Destroy;
end;

function TICStringImpl.GetImplementationFlags: Longword;
begin
  Result := FString.__GetImplementationFlags(0, FString);
end;

function TICStringImpl.GetFlatBufferHandle: PBufferHandleA;
begin
  Result := FString.__GetFlatBufferHandle(0, FString);
end;

function TICStringImpl.GetBufferHandle: PBufferHandleA;
begin
  Result := FString.__GetBufferHandle(0, FString);
end;

function TICStringImpl.GetSharedBufferHandle: PSharedBufferHandleA;
begin
  Result := FString.__GetSharedBufferHandle(0, FString);
end;

function TICStringImpl.GetLength: Longword;
begin
  Result := FString.__GetLength(0, FString);
end;

procedure TICStringImpl.SetLength(aLength: Longword);
begin
  FString.__SetLength(0, FString, aLength);
end;

function TICStringImpl.GetIsVoid: Boolean;
begin
  Result := FString.__IsVoid(0, FString);
end;

procedure TICStringImpl.SetIsVoid(aIsVoid: Boolean);
begin
  FString.__SetVoid(0, FString, aIsVoid);
end;

procedure TICStringImpl.SetCapacity(aCapacity: Longword);
begin
  FString.__SetCapacity(0, FString, aCapacity);
end;

procedure TICStringImpl.Cut(cutStart, cutLength: Longword);
begin
  FString.__Cut(0, FString, cutLength, cutStart);
end;

procedure TICStringImpl.Assign(Source: IInterfacedCString);
var
  AString: nsACString;
begin
  AString := Source.ACString;
  FString.__Assign(0, FString, AString);
end;

procedure TICStringImpl.Assign(const Source: nsACString);
begin
  FString.__Assign(0, FString, Source);
end;

procedure TICStringImpl.Assign(Source: AnsiString);
begin
  FString.__Assign(0, FString, PAnsiChar(Source));
end;

procedure TICStringImpl.Append(Source: IInterfacedCString);
var
  AString: nsACString;
begin
  AString := Source.ACString;
  FString.__Append(0, FString, AString);
end;

procedure TICStringImpl.Append(const Source: nsACString);
begin
  FString.__Append(0, FString, Source);
end;

procedure TICStringImpl.Append(Source: AnsiString);
begin
  FString.__Append(0, FString, PAnsiChar(Source));
end;

procedure TICStringImpl.Insert(Source: IInterfacedCString; aPosition: Longword);
var
  AString: nsACString;
begin
  AString := Source.ACString;
  FString.__Insert(0, FString, aPosition, AString);
end;

procedure TICStringImpl.Insert(const Source: nsACString; aPosition: Longword);
begin
  FString.__Insert(0, FString, aPosition, Source);
end;

procedure TICStringImpl.Insert(Source: AnsiString; aPosition: Longword);
begin
  FString.__Insert(0, FString, aPosition, PAnsiChar(Source));
end;

procedure TICStringImpl.Replace(aPosition, aLength: Longword; Source: IInterfacedCString);
var
  AString: nsACString;
begin
  AString := Source.ACString;
  FString.__Replace(0, FString, AString, aLength, aPosition);
end;

procedure TICStringImpl.Replace(aPosition, aLength: Longword; const Source: nsACString);
begin
  FString.__Replace(0, FString, Source, aLength, aPosition);
end;

function TICStringImpl.GetReadableFragment(var aFragment: nsReadableFragmentA; aRequest: Longword; aPosition: Longword): PAnsiChar;
begin
  Result := FString.__GetReadableFragment(0, FString, aPosition, aRequest, aFragment);
end;

function TICStringImpl.GetWritableFragment(var aFragment: nsWritableFragmentA; aRequest: Longword; aPosition: Longword): PAnsiChar;
begin
  Result := FString.__GetWritableFragment(0, FString, aPosition, aRequest, aFragment);
end;

function TICStringImpl.ACString: nsACString;
begin
  Result := FString;
end;

function TICStringImpl.ToString: AnsiString;
var
  ptr, dst: PAnsiChar;
  len, pos, frag_len: Longword;
  fragment: nsReadableFragmentA;
begin
  len := FString.__GetLength(0, FString);
  pos := 0;
  System.SetLength(Result, len);
  ptr := GetReadableFragment(fragment, gfFirstFragment);
  dst := PAnsiChar(Result);
  while (pos<len) and Assigned(ptr) do
  begin
    frag_len := (Cardinal(fragment.DataEnd) - Cardinal(fragment.DataStart)) div SizeOf(AnsiChar);
    Copy(dst, ptr, frag_len);
    Inc(dst, frag_len);
    ptr := GetReadableFragment(fragment, gfNextFragment);
  end;
end;

constructor nsDependentString.Create(aPtr: PWideChar);
begin
  inherited Create();
  Rebind(aPtr);
end;

constructor nsDependentString.Create(aStartPtr, aEndPtr: PWideChar);
begin
  inherited Create();
  Rebind(aStartPtr, aEndPtr);
end;

constructor nsDependentString.Create(aPtr: PWideChar; aLength: Longword);
begin
  inherited Create();
  Rebind(aPtr, aLength);
end;

procedure nsDependentString.Rebind(aPtr: PWideChar);
begin
  FHandle.DataStart := aPtr;
  if Assigned(aPtr) then
    FHandle.DataEnd := aPtr + System.Length(aPtr)
  else
    FHandle.DataEnd := nil;
end;

procedure nsDependentString.Rebind(aStartPtr, aEndPtr: PWideChar);
begin
  FHandle.DataStart := aStartPtr;
  FHandle.DataEnd := aEndPtr;
end;

procedure nsDependentString.Rebind(aPtr: PWideChar; aLength: Longword);
begin
  FHandle.DataStart := aPtr;
  FHandle.DataEnd := aPtr + aLength;
end;

function nsDependentString.GetBufferHandle(): PBufferHandleW;
begin
  Result := @FHandle;
end;

function nsDependentString.GetFlatBufferHandle(): PBufferHandleW;
begin
  Result := @FHandle;
end;

constructor nsDependentCString.Create(aPtr: PAnsiChar);
begin
  inherited Create();
  Rebind(aPtr);
end;

constructor nsDependentCString.Create(aStartPtr, aEndPtr: PAnsiChar);
begin
  inherited Create();
  Rebind(aStartPtr, aEndPtr);
end;

constructor nsDependentCString.Create(aPtr: PAnsiChar; aLength: Longword);
begin
  inherited Create();
  Rebind(aPtr, aLength);
end;

procedure nsDependentCString.Rebind(aPtr: PAnsiChar);
begin
  FHandle.DataStart := aPtr;
  if Assigned(aPtr) then
    FHandle.DataEnd := aPtr + System.Length(aPtr)
  else
    FHandle.DataEnd := nil;
end;

procedure nsDependentCString.Rebind(aStartPtr, aEndPtr: PAnsiChar);
begin
  FHandle.DataStart := aStartPtr;
  FHandle.DataEnd := aEndPtr;
end;

procedure nsDependentCString.Rebind(aPtr: PAnsiChar; aLength: Longword);
begin
  FHandle.DataStart := aPtr;
  FHandle.DataEnd := aPtr + aLength;
end;

function nsDependentCString.GetBufferHandle(): PBufferHandleA;
begin
  Result := @FHandle;
end;

function nsDependentCString.GetFlatBufferHandle(): PBufferHandleA;
begin
  Result := @FHandle;
end;

const
  gCommandEmptyBuffer: Word = 0;

constructor nsString.Create();
begin
  inherited Create;
  Init();
end;

constructor nsString.Create(const Source: nsAString);
begin
  inherited Create;
  Init();
  Assign(Source);
end;

constructor nsString.Create(const Source: nsString);
begin
  inherited Create;
  Init();
  Assign(Source);
end;

constructor nsString.Create(Source: PWideChar);
begin
  inherited Create;
  Init();
  Assign(Source);
end;

constructor nsString.Create(Source: WideString);
begin
  inherited Create;
  Init();
  Assign(PWideChar(Source));
end;

constructor nsString.Create(Source: PWideChar; aLength: Longword);
begin
  inherited Create;
  Init();
  Assign(Source, aLength);
end;

destructor nsString.Destroy();
begin
  _Destroy();
  inherited Destroy;
end;

procedure nsString.Init();
begin
  FStr := PWideChar(@gCommandEmptyBuffer);
  FLength := 0;
  FCapacity := 0;
end;

procedure nsString._Destroy();
begin
  _Free();
end;

procedure nsString._Free();
begin
  if (FStr <> @gCommandEmptyBuffer) and (FStr<>nil) then
    FreeMem(FStr);
end;

function nsString.Realloc(aNewSize: Longword): LongBool;
begin
  Result := True;
  if FStr <> @gCommandEmptyBuffer then
  begin
    ReallocMem(FStr, (aNewSize+1)*SizeOf(WideChar));
    FCapacity := aNewSize;
  end else
  begin
    GetMem(FStr, (aNewSize+1)*SizeOf(WideChar));
    FCapacity := aNewSize;
    FStr^ := WideChar(0);
  end;
end;

function nsString.EnsureCapacity(aNewCapacity: Longword): LongBool;
begin
  Result := True;
  if aNewCapacity > FCapacity then
  begin
    Result := Realloc(aNewCapacity);
    if Result then AddNullTerminator();
  end;
end;

function nsString.GrowCapacity(aNewCapacity: Longword): LongBool;
var
  newCapacity: Longword;
  temp: nsString;
begin
  if FCapacity > 0 then
  begin
    newCapacity := FCapacity;
    while newCapacity < aNewCapacity do
      newCapacity := newCapacity shl 1;
    aNewCapacity := newCapacity;
  end;

  temp := nsString.Create();
  Result := temp.EnsureCapacity(aNewCapacity);

  if Result then
  begin
    if FLength > 0 then
      temp.Assign(Self);
    _Free();
    FStr := temp.FStr;
    temp.FStr := nil;
    FLength := temp.FLength;
    FCapacity := temp.FCapacity;
  end;
  temp.Free;
end;

procedure nsString.AddNullTerminator();
begin
  (FStr + FLength)^ := WideChar(0);
end;

function nsString.GetFlatBufferHandle(): PBufferHandleW;
begin
  Result := nil;
end;

function nsString.GetLength(): Longword;
begin
  Result := FLength;
end;

procedure nsString.SetCapacity(aCapacity: Longword);
begin
  if aCapacity > 0 then
  begin
    if aCapacity > FCapacity then
      GrowCapacity(aCapacity);
  end else
  begin
    _Destroy();
    Init();
  end;
end;

procedure nsString.SetLength(aLength: Longword);
begin
  if aLength > FCapacity then
    GrowCapacity(aLength);

  FLength := aLength;
  if FStr <> @gCommandEmptyBuffer then
    AddNullTerminator();
end;

function nsString.GetReadableFragment(var aFragment: nsReadableFragmentW; aRequest, aPosition: Longword): PWideChar;
begin
  case aRequest of
  gfFirstFragment, gfLastFragment, gfFragmentAt:
    begin
      aFragment.DataStart := FStr;
      aFragment.DataEnd := FStr + FLength;
      Result := FStr + aPosition;
    end;
  else
    Result := nil;
  end;
end;

function nsString.GetWritableFragment(var aFragment: nsWritableFragmentW; aRequest, aPosition: Longword): PWideChar;
begin
  case aRequest of
  gfFirstFragment, gfLastFragment, gfFragmentAt:
    begin
      aFragment.DataStart := FStr;
      aFragment.DataEnd := FStr + FLength;
      Result := FStr + aPosition;
    end;
  else
    Result := nil;
  end;
end;

constructor nsCString.Create();
begin
  inherited Create;
  Init();
end;

constructor nsCString.Create(const Source: nsACString);
begin
  inherited Create;
  Init();
  Assign(Source);
end;

constructor nsCString.Create(const Source: nsCString);
begin
  inherited Create;
  Init();
  Assign(Source);
end;

constructor nsCString.Create(Source: PAnsiChar);
begin
  inherited Create;
  Init();
  Assign(Source);
end;

constructor nsCString.Create(Source: AnsiString);
begin
  inherited Create;
  Init();
  Assign(PAnsiChar(Source));
end;


constructor nsCString.Create(Source: PAnsiChar; aLength: Longword);
begin
  inherited Create;
  Init();
  Assign(Source, aLength);
end;

destructor nsCString.Destroy();
begin
  _Destroy();
  inherited Destroy;
end;

procedure nsCString.Init();
begin
  FStr := PAnsiChar(@gCommandEmptyBuffer);
  FLength := 0;
  FCapacity := 0;
end;

procedure nsCString._Destroy();
begin
  _Free();
end;

procedure nsCString._Free();
begin
  if (FStr <> @gCommandEmptyBuffer) and (FStr<>nil) then
    FreeMem(FStr);
end;

function nsCString.Realloc(aNewSize: Longword): LongBool;
begin
  Result := True;
  if FStr <> @gCommandEmptyBuffer then
  begin
    ReallocMem(FStr, (aNewSize+1)*SizeOf(AnsiChar));
    FCapacity := aNewSize;
  end else
  begin
    GetMem(FStr, (aNewSize+1)*SizeOf(AnsiChar));
    FCapacity := aNewSize;
    FStr^ := AnsiChar(0);
  end;
end;

function nsCString.EnsureCapacity(aNewCapacity: Longword): LongBool;
begin
  Result := True;
  if aNewCapacity > FCapacity then
  begin
    Result := Realloc(aNewCapacity);
    if Result then AddNullTerminator();
  end;
end;

function nsCString.GrowCapacity(aNewCapacity: Longword): LongBool;
var
  newCapacity: Longword;
  temp: nsCString;
begin
  if FCapacity > 0 then
  begin
    newCapacity := FCapacity;
    while newCapacity < aNewCapacity do
      newCapacity := newCapacity shl 1;
    aNewCapacity := newCapacity;
  end;

  temp := nsCString.Create();
  Result := temp.EnsureCapacity(aNewCapacity);

  if Result then
  begin
    if FLength > 0 then
      temp.Assign(Self);
    _Free();
    FStr := temp.FStr;
    temp.FStr := nil;
    FLength := temp.FLength;
    FCapacity := temp.FCapacity;
  end;
  temp.Free;
end;

procedure nsCString.AddNullTerminator();
begin
  (FStr + FLength)^ := AnsiChar(0);
end;

function nsCString.GetFlatBufferHandle(): PBufferHandleA;
begin
  Result := nil;
end;

function nsCString.GetLength(): Longword;
begin
  Result := FLength;
end;

procedure nsCString.SetCapacity(aCapacity: Longword);
begin
  if aCapacity > 0 then
  begin
    if aCapacity > FCapacity then
      GrowCapacity(aCapacity);
  end else
  begin
    _Destroy();
    Init();
  end;
end;

procedure nsCString.SetLength(aLength: Longword);
begin
  if aLength > FCapacity then
    GrowCapacity(aLength);

  FLength := aLength;
  if FStr <> @gCommandEmptyBuffer then
    AddNullTerminator();
end;

function nsCString.GetReadableFragment(var aFragment: nsReadableFragmentA; aRequest, aPosition: Longword): PAnsiChar;
begin
  case aRequest of
  gfFirstFragment, gfLastFragment, gfFragmentAt:
    begin
      aFragment.DataStart := FStr;
      aFragment.DataEnd := FStr + FLength;
      Result := FStr + aPosition;
    end;
  else
    Result := nil;
  end;
end;

function nsCString.GetWritableFragment(var aFragment: nsWritableFragmentA; aRequest, aPosition: Longword): PAnsiChar;
begin
  case aRequest of
  gfFirstFragment, gfLastFragment, gfFragmentAt:
    begin
      aFragment.DataStart := FStr;
      aFragment.DataEnd := FStr + FLength;
      Result := FStr + aPosition;
    end;
  else
    Result := nil;
  end;
end;

function nsString.GetValue: WideString;
begin
  Result := FStr;
end;

function nsCString.GetValue: String;
begin
  Result := FStr;
end;

{$ELSE}         // MOZILLA_VERSION >= 1.7

uses
  SysUtils, nsXPCOMGlue, nsMemory, nsError;

function Compare(const lhs, rhs: nsAString): Integer;
var
  p1, p2: PWideChar;
  l1, l2: Longword;
begin
  l1 := NS_StringGetData(lhs, p1);
  l2 := NS_StringGetData(rhs, p2);

  while (l1>0) and (l2>0) do
  begin
    Result := Ord(p1^) - Ord(p2^);
    if Result <> 0 then Exit;
    Dec(l1);
    Dec(l2);
    Inc(p1);
    Inc(p2);
  end;
  Result := l1 - l2;
end;

function Compare(const lhs, rhs: nsACString): Integer;
var
  p1, p2: PAnsiChar;
  l1, l2: Longword;
begin
  l1 := NS_CStringGetData(lhs, p1);
  l2 := NS_CStringGetData(rhs, p2);

  while (l1>0) and (l2>0) do
  begin
    Result := Ord(p1^) - Ord(p2^);
    if Result <> 0 then Exit;
    Dec(l1);
    Dec(l2);
    Inc(p1);
    Inc(p2);
  end;
  Result := l1 - l2;
end;

type
  TIStringImpl = class(TInterfacedObject, IInterfacedString)
    FContainer: nsStringContainer;
    FString: nsString;
    FOwn: Boolean;

    constructor Create; overload;
    constructor Create(src: PWideChar); overload;
    constructor Create(src: WideString); overload;
    constructor Create(src: nsAString); overload;
    constructor Relate(src: nsAString; own: Boolean);
    destructor Destroy; override;

    function Length: Longword;
    procedure Cut(cutStart, cutLength: Longword);
    procedure Assign(Source: IInterfacedString); overload;
    procedure Assign(const Source: nsAString); overload;
    procedure Assign(Source: WideString); overload;
    procedure Append(Source: IInterfacedString); overload;
    procedure Append(const Source: nsAString); overload;
    procedure Append(Source: WideString); overload;
    procedure Insert(Source: IInterfacedString; aPosition: Longword); overload;
    procedure Insert(const Source: nsAString; aPosition: Longword); overload;
    procedure Insert(Source: WideString; aPosition: Longword); overload;
    procedure Replace(aPosition, aLength: Longword; const Source: nsAString); overload;
    procedure Replace(aPosition, aLength: Longword; Source: IInterfacedString); overload;
    function AString: nsAString;
    function ToString: WideString;
  end;

function NewString: IInterfacedString;
begin
  Result := TIStringImpl.Create;
end;

function NewString(src: PWideChar): IInterfacedString;
begin
  Result := TIStringImpl.Create(src);
end;

function NewString(src: WideString): IInterfacedString;
begin
  Result := TIStringImpl.Create(src);
end;

function NewString(src: nsAString): IInterfacedString;
begin
  Result := TIStringImpl.Create(src);
end;

function RelateString(src: nsAString; own: Boolean): IInterfacedString;
begin
  Result := TIStringImpl.Relate(src, own);
end;

constructor TIStringImpl.Create;
begin
  inherited Create;
  if NS_FAILED(NS_StringContainerInit(FContainer)) then
    raise Exception.Create('FAILURE: NS_StringContainerInit');
  FOwn := True;
  FString := @FContainer;
end;

constructor TIStringImpl.Create(src: PWideChar);
begin
  inherited Create;
  if NS_FAILED(NS_StringContainerInit(FContainer)) then
    raise Exception.Create('FAILURE: NS_StringContainerInit');
  FOwn := True;
  FString := @FContainer;
  Assign(src);
  nsMemory.Free(src);
end;

constructor TIStringImpl.Create(src: WideString);
begin
  inherited Create;
  if NS_FAILED(NS_StringContainerInit(FContainer)) then
    raise Exception.Create('FAILURE: NS_StringContainerInit');
  FOwn := True;
  FString := @FContainer;
  Assign(src);
end;

constructor TIStringImpl.Create(src: nsAString);
begin
  inherited Create;
  if NS_FAILED(NS_StringContainerInit(FContainer)) then
    raise Exception.Create('FAILURE: NS_StringContainerInit');
  FOwn := True;
  FString := @FContainer;
  Assign(src);
end;

constructor TIStringImpl.Relate(src: nsAString; own: Boolean);
begin
  inherited Create;
  FString := src;
  FOwn := own;
end;

destructor TIStringImpl.Destroy;
begin
  if FOwn then
    NS_StringContainerFinish(FString^);
  inherited Destroy;
end;

function TIStringImpl.Length: Longword;
var
  temp: PWideChar;
begin
  Result := NS_StringGetData(FString, temp);
  //nsMemory.Free(temp);
end;

procedure TIStringImpl.Cut(cutStart, cutLength: Longword);
begin
  NS_StringCutData(FString, cutStart, cutLength);
end;

procedure TIStringImpl.Assign(Source: IInterfacedString);
begin
  NS_StringCopy(FString, Source.AString);
end;

procedure TIStringImpl.Assign(const Source: nsAString);
begin
  NS_StringCopy(FString, Source);
end;

procedure TIStringImpl.Assign(Source: WideString);
begin
  NS_StringSetData(FString, PWideChar(Source));
end;

procedure TIStringImpl.Append(Source: IInterfacedString);
begin
  NS_StringAppendData(FString, PWideChar(Source.ToString));
end;

procedure TIStringImpl.Append(const Source: nsAString);
var
  src2: IInterfacedString;
begin
  src2 := NewString(Source);
  Append(src2);
end;

procedure TIStringImpl.Append(Source: WideString);
var
  src2: IInterfacedString;
begin
  src2 := NewString(Source);
  Append(src2);
end;

procedure TIStringImpl.Insert(Source: IInterfacedString; aPosition: Longword);
begin
  NS_StringInsertData(FString, aPosition, PWideChar(Source.ToString));
end;

procedure TIStringImpl.Insert(const Source: nsAString; aPosition: Longword);
var
  src2: IInterfacedString;
begin
  src2 := NewString(Source);
  Insert(src2, aPosition);
end;

procedure TIStringImpl.Insert(Source: WideString; aPosition: Longword);
var
  src2: IInterfacedString;
begin
  src2 := NewString(Source);
  Insert(src2, aPosition);
end;

procedure TIStringImpl.Replace(aPosition, aLength: Longword; Source: IInterfacedString);
begin
  NS_StringSetDataRange(FString, aPosition, aLength, PWideChar(Source.ToString));
end;

procedure TIStringImpl.Replace(aPosition, aLength: Longword; const Source: nsAString);
var
  src2: IInterfacedString;
begin
  src2 := NewString(Source);
  Replace(aPosition, aLength, Src2);
end;

function TIStringImpl.AString: nsAString;
begin
  Result := FString;
end;

function TIStringImpl.ToString: WideString;
var
  p: PWideChar;
  l: Longword;
  i: Longword;
begin
  l := NS_StringGetData(FString, p);
  SetLength(Result, l);
  for i:=1 to l do
  begin
    Result[i] := p^;
    Inc(p);
  end;
end;

type
  TICStringImpl = class(TInterfacedObject, IInterfacedCString)
    FContainer: nsCStringContainer;
    FString: nsCString;
    FOwn: Boolean;

    constructor Create; overload;
    constructor Create(src: PAnsiChar); overload;
    constructor Create(src: AnsiString); overload;
    constructor Create(src: nsACString); overload;
    constructor Relate(src: nsACString; own: Boolean);
    destructor Destroy; override;

    function Length: Longword;
    procedure Cut(cutStart, cutLength: Longword);
    procedure Assign(Source: IInterfacedCString); overload;
    procedure Assign(const Source: nsACString); overload;
    procedure Assign(Source: AnsiString); overload;
    procedure Append(Source: IInterfacedCString); overload;
    procedure Append(const Source: nsACString); overload;
    procedure Append(Source: AnsiString); overload;
    procedure Insert(Source: IInterfacedCString; aPosition: Longword); overload;
    procedure Insert(const Source: nsACString; aPosition: Longword); overload;
    procedure Insert(Source: AnsiString; aPosition: Longword); overload;
    procedure Replace(aPosition, aLength: Longword; const Source: nsACString); overload;
    procedure Replace(aPosition, aLength: Longword; Source: IInterfacedCString); overload;
    function ACString: nsACString;
    function ToString: AnsiString;
  end;

function NewCString: IInterfacedCString;
begin
  Result := TICStringImpl.Create;
end;

function NewCString(src: PAnsiChar): IInterfacedCString;
begin
  Result := TICStringImpl.Create(src);
end;

function NewCString(src: AnsiString): IInterfacedCString;
begin
  Result := TICStringImpl.Create(src);
end;

function NewCString(src: nsACString): IInterfacedCString;
begin
  Result := TICStringImpl.Create(src);
end;

function RelateCString(src: nsACString; own: Boolean): IInterfacedCString;
begin
  Result := TICStringImpl.Relate(src, own);
end;

constructor TICStringImpl.Create;
begin
  inherited Create;
  if NS_FAILED(NS_CStringContainerInit(FContainer)) then
    raise Exception.Create('FAILURE: NS_CStringContainerInit');
  FOwn := True;
  FString := @FContainer;
end;

constructor TICStringImpl.Create(src: PAnsiChar);
begin
  inherited Create;
  if NS_FAILED(NS_CStringContainerInit(FContainer)) then
    raise Exception.Create('FAILURE: NS_CStringContainerInit');
  FOwn := True;
  FString := @FContainer;
  Assign(src);
  nsMemory.Free(src);
end;

constructor TICStringImpl.Create(src: AnsiString);
begin
  inherited Create;
  if NS_FAILED(NS_CStringContainerInit(FContainer)) then
    raise Exception.Create('FAILURE: NS_CStringContainerInit');
  FOwn := True;
  FString := @FContainer;
  Assign(src);
end;

constructor TICStringImpl.Create(src: nsACString);
begin
  inherited Create;
  if NS_FAILED(NS_CStringContainerInit(FContainer)) then
    raise Exception.Create('FAILURE: NS_CStringContainerInit');
  FOwn := True;
  FString := @FContainer;
  Assign(src);
end;

constructor TICStringImpl.Relate(src: nsACString; own: Boolean);
begin
  inherited Create;
  FString := src;
  FOwn := own;
end;

destructor TICStringImpl.Destroy;
begin
  if FOwn then
    NS_CStringContainerFinish(FString^);
  inherited Destroy;
end;

function TICStringImpl.Length: Longword;
var
  temp: PAnsiChar;
begin
  Result := NS_CStringGetData(FString, temp);
  //nsMemory.Free(temp);
end;

procedure TICStringImpl.Cut(cutStart, cutLength: Longword);
begin
  NS_CStringCutData(FString, cutStart, cutLength);
end;

procedure TICStringImpl.Assign(Source: IInterfacedCString);
begin
  NS_CStringCopy(FString, Source.ACString);
end;

procedure TICStringImpl.Assign(const Source: nsACString);
begin
  NS_CStringCopy(FString, Source);
end;

procedure TICStringImpl.Assign(Source: AnsiString);
begin
  NS_CStringSetData(FString, PAnsiChar(Source));
end;

procedure TICStringImpl.Append(Source: IInterfacedCString);
begin
  NS_CStringAppendData(FString, PAnsiChar(Source.ToString));
end;

procedure TICStringImpl.Append(const Source: nsACString);
var
  src2: IInterfacedCString;
begin
  src2 := NewCString(Source);
  Append(src2);
end;

procedure TICStringImpl.Append(Source: AnsiString);
var
  src2: IInterfacedCString;
begin
  src2 := NewCString(Source);
  Append(src2);
end;

procedure TICStringImpl.Insert(Source: IInterfacedCString; aPosition: Longword);
begin
  NS_CStringInsertData(FString, aPosition, PAnsiChar(Source.ToString));
end;

procedure TICStringImpl.Insert(const Source: nsACString; aPosition: Longword);
var
  src2: IInterfacedCString;
begin
  src2 := NewCString(Source);
  Insert(src2, aPosition);
end;

procedure TICStringImpl.Insert(Source: AnsiString; aPosition: Longword);
var
  src2: IInterfacedCString;
begin
  src2 := NewCString(Source);
  Insert(src2, aPosition);
end;

procedure TICStringImpl.Replace(aPosition, aLength: Longword; Source: IInterfacedCString);
begin
  NS_CStringSetDataRange(FString, aPosition, aLength, PAnsiChar(Source.ToString));
end;

procedure TICStringImpl.Replace(aPosition, aLength: Longword; const Source: nsACString);
var
  src2: IInterfacedCString;
begin
  src2 := NewCString(Source);
  Replace(aPosition, aLength, Src2);
end;

function TICStringImpl.ACString: nsACString;
begin
  Result := FString;
end;

function TICStringImpl.ToString: AnsiString;
var
  p: PAnsiChar;
  l: Longword;
  i: Longword;
begin
  l := NS_CStringGetData(FString, p);
  SetLength(Result, l);
  for i:=1 to l do
  begin
    Result[i] := p^;
    Inc(p);
  end;
end;

{$IFEND}

end.
