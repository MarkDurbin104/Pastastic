unit AdminLib_TLB;

{ This file contains pascal declarations imported from a type library.
  This file will be written during each import or refresh of the type
  library editor.  Changes to this file will be discarded during the
  refresh process. }

{ Wang Image Admin Control }
{ Version 1.0 }

{ Conversion log:
  Warning: 'Object' is a reserved word. Parameter 'Object' in _DImgAdmin.Delete changed to 'Object_'
 }

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

const
  LIBID_AdminLib: TGUID = '{009541A3-3B81-101C-92F3-040224009C02}';

const

{ FileTypeValue }

  FileTypeUnk = 0;
  FileTypeTIFF = 1;
  FileTypeBMP = 3;
  FileTypePCX = 4;
  FileTypeDCX = 5;
  FileTypeJPEG = 6;
  FIleTypeXIF = 7;

{ PageTypeValue }

  PageTypeUnk = 0;
  PageTypeBW = 1;
  PageTypeGray4 = 2;
  PageTypeGray8 = 3;
  PageTypePal4 = 4;
  PageTypePal8 = 5;
  PageTypeRGB24 = 6;
  PageTypeBGR24 = 7;

{ CompTypeValue }

  CompTypeUnk = 0;
  CompTypeNone = 1;
  CompTypeGroup3 = 2;
  CompTypeGroup3Huff = 3;
  CompTypePacked = 4;
  CompTypeGroup4 = 5;
  CompTypeJPEG = 6;
  CompTypeGroup32DFax = 8;
  CompTypeLZW = 9;

{ PrintFormatValue }

  OutPixel = 0;
  OutActualSize = 1;
  OutFitPage = 2;

{ RangeValue }

  PrintAll = 0;
  PrintRange = 1;
  PrintCurrent = 2;

{ DlgOptionValue }

  OpenDlg = 0;
  SaveDlg = 1;

{ VerifyValue }

  VerifyExists = 0;
  VerifyRead = 1;
  VerifyWrite = 2;
  VerifyReadWrite = 3;

const

{ Component class GUIDs }
  Class_ImgAdmin: TGUID = '{009541A0-3B81-101C-92F3-040224009C02}';

type

{ Forward declarations: Interfaces }
  _DImgAdmin = dispinterface;
  _DImgAdminEvents = dispinterface;

{ Forward declarations: CoClasses }
  ImgAdmin = _DImgAdmin;

{ Forward declarations: Enums }
  FileTypeValue = TOleEnum;
  PageTypeValue = TOleEnum;
  CompTypeValue = TOleEnum;
  PrintFormatValue = TOleEnum;
  RangeValue = TOleEnum;
  DlgOptionValue = TOleEnum;
  VerifyValue = TOleEnum;

{ Dispatch interface for Wang Image Admin Control }

  _DImgAdmin = dispinterface
    ['{009541A1-3B81-101C-92F3-040224009C02}']
    property Filter: WideString dispid 1;
    property HelpFile: WideString dispid 2;
    property Flags: Integer dispid 3;
    property Image: WideString dispid 4;
    property StatusCode: Integer dispid 5;
    property DefaultExt: WideString dispid 6;
    property InitDir: WideString dispid 7;
    property CompressionInfo: Integer dispid 8;
    property FileType: FileTypeValue dispid 9;
    property FilterIndex: Integer dispid 10;
    property HelpCommand: Smallint dispid 11;
    property PageCount: Integer dispid 12;
    property PageNumber: Integer dispid 13;
    property PageType: PageTypeValue dispid 14;
    property PrintRangeOption: RangeValue dispid 15;
    property PrintOutputFormat: PrintFormatValue dispid 16;
    property ImageHeight: Integer dispid 17;
    property ImageWidth: Integer dispid 18;
    property ImageResolutionX: Integer dispid 19;
    property ImageResolutionY: Integer dispid 20;
    property CompressionType: CompTypeValue dispid 21;
    property DialogTitle: WideString dispid 22;
    property CancelError: WordBool dispid 23;
    property HelpContextId: Smallint dispid 24;
    property HelpKey: WideString dispid 25;
    property PrintNumCopies: Integer dispid 26;
    property PrintAnnotations: WordBool dispid 27;
    property PrintEndPage: Integer dispid 28;
    property PrintStartPage: Integer dispid 29;
    property PrintToFile: WordBool dispid 30;
    function GetUniqueName(const Path, Template, Extension: WideString): WideString; dispid 101;
    procedure CreateDirectory(const lpszPath: WideString); dispid 102;
    procedure Delete(const Object_: WideString); dispid 103;
    procedure ShowPrintDialog(hParentWnd: OleVariant); dispid 104;
    procedure Append(const Source: WideString; SourcePage, NumPages: Integer; CompressionType, CompressionInfo: OleVariant); dispid 105;
    function GetSysCompressionType(ImageType: Smallint): CompTypeValue; dispid 106;
    function GetSysCompressionInfo(ImageType: Smallint): Integer; dispid 107;
    function GetSysFileType(ImageType: Smallint): FileTypeValue; dispid 108;
    procedure DeletePages(StartPage, NumPages: Integer); dispid 109;
    procedure Insert(const Source: WideString; SourcePage, DestinationPage, NumPages: Integer; CompressionType, CompressionInfo: OleVariant); dispid 110;
    procedure Replace(const Source: WideString; SourcePage, DestinationPage, NumPages: Integer; CompressionType, CompressionInfo: OleVariant); dispid 111;
    procedure SetSystemFileAttributes(PageType: PageTypeValue; FileType: FileTypeValue; CompressionType: CompTypeValue; CompressionInfo: Integer); dispid 112;
    procedure ShowFileDialog(DialogOption: DlgOptionValue; hParentWnd: OleVariant); dispid 113;
    function VerifyImage(sOption: VerifyValue): WordBool; dispid 114;
    function GetVersion: WideString; dispid 115;
    procedure AboutBox; dispid -552;
  end;

{ Event interface for Wang Image Admin Control }

  _DImgAdminEvents = dispinterface
    ['{009541A2-3B81-101C-92F3-040224009C02}']
  end;

{ Wang Image Admin Control }

  TImgAdmin = class(TOleControl)
  private
    FIntf: _DImgAdmin;
    function GetControlInterface: _DImgAdmin;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
    function GetTOleEnumProp(Index: Integer): TOleEnum;
    procedure SetTOleEnumProp(Index: Integer; Value: TOleEnum);
  public
    function GetUniqueName(const Path, Template, Extension: WideString): WideString;
    procedure CreateDirectory(const lpszPath: WideString);
    procedure Delete(const Object_: WideString);
    procedure ShowPrintDialog(hParentWnd: OleVariant);
    procedure Append(const Source: WideString; SourcePage, NumPages: Integer; CompressionType, CompressionInfo: OleVariant);
    function GetSysCompressionType(ImageType: Smallint): CompTypeValue;
    function GetSysCompressionInfo(ImageType: Smallint): Integer;
    function GetSysFileType(ImageType: Smallint): FileTypeValue;
    procedure DeletePages(StartPage, NumPages: Integer);
    procedure Insert(const Source: WideString; SourcePage, DestinationPage, NumPages: Integer; CompressionType, CompressionInfo: OleVariant);
    procedure Replace(const Source: WideString; SourcePage, DestinationPage, NumPages: Integer; CompressionType, CompressionInfo: OleVariant);
    procedure SetSystemFileAttributes(PageType: PageTypeValue; FileType: FileTypeValue; CompressionType: CompTypeValue; CompressionInfo: Integer);
    procedure ShowFileDialog(DialogOption: DlgOptionValue; hParentWnd: OleVariant);
    function VerifyImage(sOption: VerifyValue): WordBool;
    function GetVersion: WideString;
    procedure AboutBox;
    property ControlInterface: _DImgAdmin read GetControlInterface;
    property StatusCode: Integer index 5 read GetIntegerProp write SetIntegerProp;
    property CompressionInfo: Integer index 8 read GetIntegerProp write SetIntegerProp;
    property FileType: FileTypeValue index 9 read GetTOleEnumProp write SetTOleEnumProp;
    property PageCount: Integer index 12 read GetIntegerProp write SetIntegerProp;
    property PageNumber: Integer index 13 read GetIntegerProp write SetIntegerProp;
    property PageType: PageTypeValue index 14 read GetTOleEnumProp write SetTOleEnumProp;
    property ImageHeight: Integer index 17 read GetIntegerProp write SetIntegerProp;
    property ImageWidth: Integer index 18 read GetIntegerProp write SetIntegerProp;
    property ImageResolutionX: Integer index 19 read GetIntegerProp write SetIntegerProp;
    property ImageResolutionY: Integer index 20 read GetIntegerProp write SetIntegerProp;
    property CompressionType: CompTypeValue index 21 read GetTOleEnumProp write SetTOleEnumProp;
    property PrintEndPage: Integer index 28 read GetIntegerProp write SetIntegerProp;
    property PrintStartPage: Integer index 29 read GetIntegerProp write SetIntegerProp;
  published
    property Filter: WideString index 1 read GetWideStringProp write SetWideStringProp stored False;
    property HelpFile: WideString index 2 read GetWideStringProp write SetWideStringProp stored False;
    property Flags: Integer index 3 read GetIntegerProp write SetIntegerProp stored False;
    property Image: WideString index 4 read GetWideStringProp write SetWideStringProp stored False;
    property DefaultExt: WideString index 6 read GetWideStringProp write SetWideStringProp stored False;
    property InitDir: WideString index 7 read GetWideStringProp write SetWideStringProp stored False;
    property FilterIndex: Integer index 10 read GetIntegerProp write SetIntegerProp stored False;
    property HelpCommand: Smallint index 11 read GetSmallintProp write SetSmallintProp stored False;
    property PrintRangeOption: RangeValue index 15 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property PrintOutputFormat: PrintFormatValue index 16 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property DialogTitle: WideString index 22 read GetWideStringProp write SetWideStringProp stored False;
    property CancelError: WordBool index 23 read GetWordBoolProp write SetWordBoolProp stored False;
    property HelpContextId: Smallint index 24 read GetSmallintProp write SetSmallintProp stored False;
    property HelpKey: WideString index 25 read GetWideStringProp write SetWideStringProp stored False;
    property PrintNumCopies: Integer index 26 read GetIntegerProp write SetIntegerProp stored False;
    property PrintAnnotations: WordBool index 27 read GetWordBoolProp write SetWordBoolProp stored False;
    property PrintToFile: WordBool index 30 read GetWordBoolProp write SetWordBoolProp stored False;
  end;

procedure Register;

implementation

uses ComObj;

procedure TImgAdmin.InitControlData;
const
  CControlData: TControlData = (
    ClassID: '{009541A0-3B81-101C-92F3-040224009C02}';
    EventIID: '';
    EventCount: 0;
    EventDispIDs: nil;
    LicenseKey: nil;
    Flags: $00000000;
    Version: 300);
begin
  ControlData := @CControlData;
end;

procedure TImgAdmin.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as _DImgAdmin;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TImgAdmin.GetControlInterface: _DImgAdmin;
begin
  CreateControl;
  Result := FIntf;
end;

function TImgAdmin.GetTOleEnumProp(Index: Integer): TOleEnum;
begin
  Result := GetIntegerProp(Index);
end;

procedure TImgAdmin.SetTOleEnumProp(Index: Integer; Value: TOleEnum);
begin
  SetIntegerProp(Index, Value);
end;

function TImgAdmin.GetUniqueName(const Path, Template, Extension: WideString): WideString;
begin
  CreateControl;
  Result := FIntf.GetUniqueName(Path, Template, Extension);
end;

procedure TImgAdmin.CreateDirectory(const lpszPath: WideString);
begin
  CreateControl;
  FIntf.CreateDirectory(lpszPath);
end;

procedure TImgAdmin.Delete(const Object_: WideString);
begin
  CreateControl;
  FIntf.Delete(Object_);
end;

procedure TImgAdmin.ShowPrintDialog(hParentWnd: OleVariant);
begin
  CreateControl;
  FIntf.ShowPrintDialog(hParentWnd);
end;

procedure TImgAdmin.Append(const Source: WideString; SourcePage, NumPages: Integer; CompressionType, CompressionInfo: OleVariant);
begin
  CreateControl;
  FIntf.Append(Source, SourcePage, NumPages, CompressionType, CompressionInfo);
end;

function TImgAdmin.GetSysCompressionType(ImageType: Smallint): CompTypeValue;
begin
  CreateControl;
  Result := FIntf.GetSysCompressionType(ImageType);
end;

function TImgAdmin.GetSysCompressionInfo(ImageType: Smallint): Integer;
begin
  CreateControl;
  Result := FIntf.GetSysCompressionInfo(ImageType);
end;

function TImgAdmin.GetSysFileType(ImageType: Smallint): FileTypeValue;
begin
  CreateControl;
  Result := FIntf.GetSysFileType(ImageType);
end;

procedure TImgAdmin.DeletePages(StartPage, NumPages: Integer);
begin
  CreateControl;
  FIntf.DeletePages(StartPage, NumPages);
end;

procedure TImgAdmin.Insert(const Source: WideString; SourcePage, DestinationPage, NumPages: Integer; CompressionType, CompressionInfo: OleVariant);
begin
  CreateControl;
  FIntf.Insert(Source, SourcePage, DestinationPage, NumPages, CompressionType, CompressionInfo);
end;

procedure TImgAdmin.Replace(const Source: WideString; SourcePage, DestinationPage, NumPages: Integer; CompressionType, CompressionInfo: OleVariant);
begin
  CreateControl;
  FIntf.Replace(Source, SourcePage, DestinationPage, NumPages, CompressionType, CompressionInfo);
end;

procedure TImgAdmin.SetSystemFileAttributes(PageType: PageTypeValue; FileType: FileTypeValue; CompressionType: CompTypeValue; CompressionInfo: Integer);
begin
  CreateControl;
  FIntf.SetSystemFileAttributes(PageType, FileType, CompressionType, CompressionInfo);
end;

procedure TImgAdmin.ShowFileDialog(DialogOption: DlgOptionValue; hParentWnd: OleVariant);
begin
  CreateControl;
  FIntf.ShowFileDialog(DialogOption, hParentWnd);
end;

function TImgAdmin.VerifyImage(sOption: VerifyValue): WordBool;
begin
  CreateControl;
  Result := FIntf.VerifyImage(sOption);
end;

function TImgAdmin.GetVersion: WideString;
begin
  CreateControl;
  Result := FIntf.GetVersion;
end;

procedure TImgAdmin.AboutBox;
begin
  CreateControl;
  FIntf.AboutBox;
end;


procedure Register;
begin
  RegisterComponents('Wang', [TImgAdmin]);
end;

end.
