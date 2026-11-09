unit ScanLib_TLB;

{ This file contains pascal declarations imported from a type library.
  This file will be written during each import or refresh of the type
  library editor.  Changes to this file will be discarded during the
  refresh process. }

{ Wang Image Scan Control }
{ Version 1.0 }

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

const
  LIBID_ScanLib: TGUID = '{84926CA3-2941-101C-816F-0E6013114B7F}';

const

{ FileTypeConstants }

  TIFF = 1;
  AWD_MicrosoftFax = 2;
  BMP_Bitmap = 3;

{ CompressionTypeConstants }

  NoCompression = 1;
  CCITTGroup3_1d_Fax = 2;
  CCITTGroup3_1d_ModifiedHuffman = 3;
  PackedBits = 4;
  CCITTGroup4_2d_Fax = 5;
  JPEG = 6;

{ PageOptionConstants }

  CreateNewFile = 0;
  PromptToCreateNewFile = 1;
  AppendPages = 2;
  InsertPages = 3;
  OverwritePages = 4;
  PromptToOverwritePages = 5;
  OverwriteAllPages = 6;

{ PageTypeConstants }

  BlackAndWhite = 1;
  Gray16Shades = 2;
  Gray256Shades = 3;
  Color16Count = 4;
  Color256Count = 5;
  TrueColor24bit = 6;
  HighColor24bit = 7;

{ ScanToConstants }

  DisplayOnly = 0;
  DisplayAndFile = 1;
  FileOnly = 2;
  DisplayAndUseFileTemplate = 3;
  UseFileTemplateOnly = 4;
  FaxOnly = 5;

const

{ Component class GUIDs }
  Class_ImgScan: TGUID = '{84926CA0-2941-101C-816F-0E6013114B7F}';

type

{ Forward declarations: Interfaces }
  _DImgScan = dispinterface;
  _DImgScanEvents = dispinterface;

{ Forward declarations: CoClasses }
  ImgScan = _DImgScan;

{ Forward declarations: Enums }
  FileTypeConstants = TOleEnum;
  CompressionTypeConstants = TOleEnum;
  PageOptionConstants = TOleEnum;
  PageTypeConstants = TOleEnum;
  ScanToConstants = TOleEnum;

{ Dispatch interface for Scan Control }

  _DImgScan = dispinterface
    ['{84926CA1-2941-101C-816F-0E6013114B7F}']
    property Image: WideString dispid 1;
    property DestImageControl: WideString dispid 2;
    property Scroll: WordBool dispid 3;
    property StopScanBox: WordBool dispid 4;
    property Page: Integer dispid 5;
    property PageOption: PageOptionConstants dispid 6;
    property PageCount: Integer dispid 7;
    property StatusCode: Integer dispid 8;
    property FileType: FileTypeConstants dispid 9;
    property PageType: PageTypeConstants dispid 10;
    property CompressionType: CompressionTypeConstants dispid 11;
    property CompressionInfo: Integer dispid 12;
    property MultiPage: WordBool dispid 13;
    property ScanTo: ScanToConstants dispid 14;
    property Zoom: Single dispid 15;
    property ShowSetupBeforeScan: WordBool dispid 16;
    function OpenScanner: Integer; dispid 100;
    function ShowScannerSetup: Integer; dispid 101;
    function StartScan: Integer; dispid 102;
    function CloseScanner: Integer; dispid 103;
    function ScannerAvailable: WordBool; dispid 104;
    function ShowSelectScanner: Integer; dispid 105;
    function StopScan: Integer; dispid 106;
    function ResetScanner: Integer; dispid 107;
    function ShowScanNew(Modal: OleVariant): Integer; dispid 108;
    function ShowScanPage(Modal: OleVariant): Integer; dispid 109;
    procedure SetExternalImageName(const szImageTitle: WideString); dispid 110;
    function GetVersion: WideString; dispid 111;
    function ShowScanPreferences: Integer; dispid 112;
    procedure AboutBox; dispid -552;
  end;

{ Event interface for Wang Image Scan Control }

  _DImgScanEvents = dispinterface
    ['{84926CA2-2941-101C-816F-0E6013114B7F}']
    procedure ScanStarted; dispid 1;
    procedure ScanDone; dispid 2;
    procedure PageDone(PageNumber: Integer); dispid 3;
  end;

{ Wang Image Scan Control }

  TImgScanPageDone = procedure(Sender: TObject; PageNumber: Integer) of object;

  TImgScan = class(TOleControl)
  private
    FOnScanStarted: TNotifyEvent;
    FOnScanDone: TNotifyEvent;
    FOnPageDone: TImgScanPageDone;
    FIntf: _DImgScan;
    function GetControlInterface: _DImgScan;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
    function GetTOleEnumProp(Index: Integer): TOleEnum;
    procedure SetTOleEnumProp(Index: Integer; Value: TOleEnum);
  public
    function OpenScanner: Integer;
    function ShowScannerSetup: Integer;
    function StartScan: Integer;
    function CloseScanner: Integer;
    function ScannerAvailable: WordBool;
    function ShowSelectScanner: Integer;
    function StopScan: Integer;
    function ResetScanner: Integer;
    function ShowScanNew(Modal: OleVariant): Integer;
    function ShowScanPage(Modal: OleVariant): Integer;
    procedure SetExternalImageName(const szImageTitle: WideString);
    function GetVersion: WideString;
    function ShowScanPreferences: Integer;
    procedure AboutBox;
    property ControlInterface: _DImgScan read GetControlInterface;
  published
    property Image: WideString index 1 read GetWideStringProp write SetWideStringProp stored False;
    property DestImageControl: WideString index 2 read GetWideStringProp write SetWideStringProp stored False;
    property Scroll: WordBool index 3 read GetWordBoolProp write SetWordBoolProp stored False;
    property StopScanBox: WordBool index 4 read GetWordBoolProp write SetWordBoolProp stored False;
    property Page: Integer index 5 read GetIntegerProp write SetIntegerProp stored False;
    property PageOption: PageOptionConstants index 6 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property PageCount: Integer index 7 read GetIntegerProp write SetIntegerProp stored False;
    property StatusCode: Integer index 8 read GetIntegerProp write SetIntegerProp stored False;
    property FileType: FileTypeConstants index 9 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property PageType: PageTypeConstants index 10 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property CompressionType: CompressionTypeConstants index 11 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property CompressionInfo: Integer index 12 read GetIntegerProp write SetIntegerProp stored False;
    property MultiPage: WordBool index 13 read GetWordBoolProp write SetWordBoolProp stored False;
    property ScanTo: ScanToConstants index 14 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property Zoom: Single index 15 read GetSingleProp write SetSingleProp stored False;
    property ShowSetupBeforeScan: WordBool index 16 read GetWordBoolProp write SetWordBoolProp stored False;
    property OnScanStarted: TNotifyEvent read FOnScanStarted write FOnScanStarted;
    property OnScanDone: TNotifyEvent read FOnScanDone write FOnScanDone;
    property OnPageDone: TImgScanPageDone read FOnPageDone write FOnPageDone;
  end;

procedure Register;

implementation

uses ComObj;

procedure TImgScan.InitControlData;
const
  CEventDispIDs: array[0..2] of Integer = (
    $00000001, $00000002, $00000003);
  CControlData: TControlData = (
    ClassID: '{84926CA0-2941-101C-816F-0E6013114B7F}';
    EventIID: '{84926CA2-2941-101C-816F-0E6013114B7F}';
    EventCount: 3;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil;
    Flags: $00000000;
    Version: 300);
begin
  ControlData := @CControlData;
end;

procedure TImgScan.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as _DImgScan;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TImgScan.GetControlInterface: _DImgScan;
begin
  CreateControl;
  Result := FIntf;
end;

function TImgScan.GetTOleEnumProp(Index: Integer): TOleEnum;
begin
  Result := GetIntegerProp(Index);
end;

procedure TImgScan.SetTOleEnumProp(Index: Integer; Value: TOleEnum);
begin
  SetIntegerProp(Index, Value);
end;

function TImgScan.OpenScanner: Integer;
begin
  CreateControl;
  Result := FIntf.OpenScanner;
end;

function TImgScan.ShowScannerSetup: Integer;
begin
  CreateControl;
  Result := FIntf.ShowScannerSetup;
end;

function TImgScan.StartScan: Integer;
begin
  CreateControl;
  Result := FIntf.StartScan;
end;

function TImgScan.CloseScanner: Integer;
begin
  CreateControl;
  Result := FIntf.CloseScanner;
end;

function TImgScan.ScannerAvailable: WordBool;
begin
  CreateControl;
  Result := FIntf.ScannerAvailable;
end;

function TImgScan.ShowSelectScanner: Integer;
begin
  CreateControl;
  Result := FIntf.ShowSelectScanner;
end;

function TImgScan.StopScan: Integer;
begin
  CreateControl;
  Result := FIntf.StopScan;
end;

function TImgScan.ResetScanner: Integer;
begin
  CreateControl;
  Result := FIntf.ResetScanner;
end;

function TImgScan.ShowScanNew(Modal: OleVariant): Integer;
begin
  CreateControl;
  Result := FIntf.ShowScanNew(Modal);
end;

function TImgScan.ShowScanPage(Modal: OleVariant): Integer;
begin
  CreateControl;
  Result := FIntf.ShowScanPage(Modal);
end;

procedure TImgScan.SetExternalImageName(const szImageTitle: WideString);
begin
  CreateControl;
  FIntf.SetExternalImageName(szImageTitle);
end;

function TImgScan.GetVersion: WideString;
begin
  CreateControl;
  Result := FIntf.GetVersion;
end;

function TImgScan.ShowScanPreferences: Integer;
begin
  CreateControl;
  Result := FIntf.ShowScanPreferences;
end;

procedure TImgScan.AboutBox;
begin
  CreateControl;
  FIntf.AboutBox;
end;


procedure Register;
begin
  RegisterComponents('Wang', [TImgScan]);
end;

end.
