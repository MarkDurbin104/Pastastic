unit MethodNameU;

interface


uses
	Windows,SysUtils,Classes,TypInfo{,S_Vmt},PackStrListU;


type
  { Published method record }
  PVmtMethod = ^TVmtMethod;
  TVmtMethod = packed record
	  Size: Word;
    Address: Pointer;
    Name: ShortString;
  end;
  { Published method table }
  PVmtMethodTable = ^TVmtMethodTable;
  TVmtMethodTable = packed record
    Count: Word;
    Methods: array[0..MaxListSize] of Byte;
    { Methods: array[1..Count] of TVmtMethod; }
  end;

  { Field class table }
  PFieldClassTable = ^TFieldClassTable;
  TFieldClassTable = packed record
    Count: Word;
    Classes: packed array[0..MaxListSize] of ^TClass;
    { Classes: packed array[1..Count] of TClass; }
  end;

  { Published field record }
  PVmtField = ^TVmtField;
  TVmtField = packed record
    Offset: Cardinal;    { Offset of field in the class data. }
    ClassIndex: Word;    { Index in the FieldClassTable. }
    Name: ShortString;
  end;
  { Published field table }
  PVmtFieldTable = ^TVmtFieldTable;
  TVmtFieldTable = packed record
    Count: Word;
    FieldClassTable: PFieldClassTable ;
    Fields: packed array[0..MaxListSize] of Byte;
    { Fields: packed array [1..Count] of TVmtField; }
  end;

  { Dynamic method table }
  PVmtDynMethodTable = ^TVmtDynMethodTable;
  TVmtDynMethodTable = packed record
    Count: Word;
    Data: packed array[0..MaxListSize] of Byte;
    { Indexes: packed array[1..Count] of SmallInt;
      Addresses: packed array[1..Count] of Pointer; }
  end;
  PDynIndexes = ^TDynIndexes;
  TDynIndexes = packed array[0..MaxListSize] of SmallInt;
  PDynAddresses = ^TDynAddresses;
  TDynAddresses = packed array[0..MaxListSize] of Pointer;

  { Initialization/finalization record }
  PTypeKind = ^TTypeKind;
  PVmtInitTable = ^TVmtInitTable;
  PVmtInitRecord = ^TVmtInitRecord;
  TVmtInitRecord = packed record
    InitTable: ^PVmtInitTable;
    Offset: Cardinal;   { offset of field in object }
  end;
  PVmtInitArray = ^TVmtInitArray;
  TVmtInitArray = array[0..MaxListSize] of TVmtInitRecord;

  { Initialization/finalization table }
  TVmtInitTable = packed record
    TypeKind: Byte;
    Data: packed array[0..MaxListSize] of Byte;
    { TypeName: ShortString;
      DataSize: Cardinal;
      Count: Cardinal;
      Records: array[1..Count] of TVmtInitRecord; }
  end;

  { OLE Automation Table (see OleAuto.pas) }
const
  { Parameter type masks }
  atTypeMask = $7F;
  atByRef    = $80;
  MaxAutoEntries = 4095;
  MaxAutoParams = 255;

type
  { Mask the type with atTypeMask to get the variant type code,
    e.g., varEmpty..varVariant. The atByRef bit is set when
    the parameter is passed by reference, e.g., VAR. }
  TAutoType = Byte;
  { Automation entry parameter list }
  PAutoParamList = ^TAutoParamList;
  TAutoParamList = packed record
    ReturnType: TAutoType;
    Count: Byte;
    Types: array[0..MaxAutoParams] of TAutoType;
  end;
  { Automation entry flags }
  TVmtAutoFlag = (afMethod, afPropGet, afPropSet, afVirtual);
  TVmtAutoFlags = set of TVmtAutoFlag;
  { Automation table entry }
  PVmtAutoEntry = ^TVmtAutoEntry;
  TVmtAutoEntry = packed record
    DispID: Integer;
    Name: PShortString;
    Flags: Integer; { Lower byte is TVmtAutoFlags }
    Params: PAutoParamList;
    Address: Pointer;
  end;

  { Automation table layout }
  PVmtAutoTable = ^TVmtAutoTable;
  TVmtAutoTable = packed record
    Count: Integer;
    Entries: array[0..MaxAutoEntries] of TVmtAutoEntry;
  end;

  { Virtual Method Table }
  PVmt = ^TVmt;
  TVmt = record
    SelfPtr:      TClass;
    IntfTable:    PInterfaceTable;
    AutoTable:    PVmtAutoTable;
    InitTable:    PVmtInitTable;
    TypeInfo:      PTypeInfo         ;
    FieldTable:    PVmtFieldTable    ;
    MethodTable:   PVmtMethodTable   ;
    DynMethodTable:PVmtDynMethodTable;
    ClassName:     PShortString      ;
    InstanceSize:   Cardinal;
    ClassParent:   ^TClass ;
    SafeCallException: Pointer;
    DefaultHandler: Pointer; { These four hidden fields point to }
    NewInstance:    Pointer; { special virtual methods that are }
    FreeInstance:   Pointer; { inherited from TObject. }
    Destroy:        Pointer;
    { Here begin the virtual method pointers.
      Each virtual method is stored as a code pointer, e.g.,
      VirtualMethodTable: array[0..Count] of Pointer; }
  end;


function GetMethods(MethodClass : TClass) : String;
function GetMethodAtAddress(MethodClass : TClass; Address : Pointer) : String;

implementation

function GetMethods(MethodClass : TClass ) : String;
var
  I: Integer;
  Meth: PVmtMethod;
	MethodsStringList : TPackStringList;
  Ptr: PByte;
  Vmt: PVmt;
  Table: PVmtMethodTable;
begin
	Result := '';
	MethodsStringList := TPackStringList.Create;
  try
    Vmt := PVmt(MethodClass);
    Dec(Vmt, 1);
    if Vmt^.MethodTable = nil then Exit;
    
    Table := PVmtMethodTable(Vmt^.MethodTable);

    Ptr := PByte(@Table^.Methods);
    for I := 1 to Table^.Count do
    begin
      Meth := PVmtMethod(Ptr);
      with Meth^ do
      begin
        Inc(Ptr, TVmtMethod(Meth^).Size);
        MethodsStringList.Add(Format('%s,%p', [Meth^.Name, Address]));
      end;
    end;
  	Result :=  MethodsStringList.CommaText;
  finally
  	MethodsStringList.Free;
  end;
end;

function GetMethodAtAddress(MethodClass : TClass; Address : Pointer) : String;
var
	MethodsStringList, MethodLineStringList  : TPackStringList;

  MethodIndex : Integer;
begin
	Result := Format('%8.8x',[Integer(Address)]);
	MethodsStringList := TPackStringList.Create;
	MethodLineStringList := TPackStringList.Create;
  try
		//get methods list
  	MethodsStringList.CommaText := GetMethods(MethodClass);

    //find address in list
    For MethodIndex := 0 to MethodsStringList.Count -1 do
    begin
    	MethodLineStringList.CommaText := MethodsStringList[MethodIndex];
			If StrToInt('$' + MethodLineStringList[1]) < Integer(Address) then
      	Result := MethodLineStringList[0];
    end;

  finally
  	MethodsStringList.Free;
   	MethodLineStringList.Free;
  end;

end;


end.
