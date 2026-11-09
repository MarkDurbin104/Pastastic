unit ThumbnailLib_TLB;

{ This file contains pascal declarations imported from a type library.
  This file will be written during each import or refresh of the type
  library editor.  Changes to this file will be discarded during the
  refresh process. }

{ Wang Image Thumbnail Control }
{ Version 1.0 }

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

const
  LIBID_ThumbnailLib: TGUID = '{E1A6B8A3-3603-101C-AC6E-040224009C02}';

const

{ ScrollConstants }

  Horizontal = 0;
  Vertical = 1;

{ CaptionStyleConstants }

  None = 0;
  Simple = 1;
  SimpleWithAnno = 2;
  Caption = 3;
  CaptionWithAnno = 4;

{ MousePointerConstants }

  Default = 0;
  Arrow = 1;
  Cross = 2;
  IBeam = 3;
  Icon = 4;
  Size = 5;
  SizeNESW = 6;
  SizeNS = 7;
  SizeNWSE = 8;
  SizeWE = 9;
  UpArrow = 10;
  Hourglass = 11;
  NoDrop = 12;
  ArrowAndHourglass = 13;
  ArrowAndQuestion = 14;
  SizeAll = 15;
  Custom = 99;

const

{ Component class GUIDs }
  Class_ImgThumbnail: TGUID = '{E1A6B8A0-3603-101C-AC6E-040224009C02}';

type

{ Forward declarations: Interfaces }
  _DImgThumbnail = dispinterface;
  _DImgThumbnailEvents = dispinterface;

{ Forward declarations: CoClasses }
  ImgThumbnail = _DImgThumbnail;

{ Forward declarations: Enums }
  ScrollConstants = TOleEnum;
  CaptionStyleConstants = TOleEnum;
  MousePointerConstants = TOleEnum;

{ Dispatch interface for Wang Image Thumbnail Control }

  _DImgThumbnail = dispinterface
    ['{E1A6B8A1-3603-101C-AC6E-040224009C02}']
    property ThumbCount: Integer dispid 1;
    property ThumbWidth: Integer dispid 2;
    property ThumbHeight: Integer dispid 3;
    property ScrollDirection: ScrollConstants dispid 4;
    property ThumbCaptionStyle: CaptionStyleConstants dispid 5;
    property ThumbCaptionColor: TColor dispid 6;
    property ThumbCaptionFont: IFontDisp dispid 7;
    property HighlightSelectedThumbs: WordBool dispid 8;
    property SelectedThumbCount: Integer dispid 9;
    property FirstSelectedThumb: Integer dispid 10;
    property LastSelectedThumb: Integer dispid 11;
    property ThumbCaption: WideString dispid 12;
    property HighlightColor: TColor dispid 13;
    property ThumbBackColor: TColor dispid 14;
    property StatusCode: Integer dispid 15;
    property Image: WideString dispid 16;
    property MousePointer: MousePointerConstants dispid 17;
    property MouseIcon: IPictureDisp dispid 18;
    property BackColor: TColor dispid -501;
    property BorderStyle: Smallint dispid -504;
    property Enabled: WordBool dispid -514;
    property hWnd: OLE_HANDLE dispid -515;
    property FirstDisplayedThumb: Integer dispid 19;
    property LastDisplayedThumb: Integer dispid 20;
    procedure SelectAllThumbs; dispid 101;
    procedure DeselectAllThumbs; dispid 102;
    function GetMinimumSize(ThumbCount: Integer; ScrollBar: WordBool): Integer; dispid 103;
    function GetMaximumSize(ThumbCount: Integer; ScrollBar: WordBool): Integer; dispid 104;
    procedure ClearThumbs(PageNumber: OleVariant); dispid 105;
    procedure InsertThumbs(InsertBeforeThumb, InsertCount: OleVariant); dispid 106;
    procedure DeleteThumbs(DeleteAt: Integer; DeleteCount: OleVariant); dispid 107;
    procedure DisplayThumbs(ThumbNumber, Option: OleVariant); dispid 108;
    procedure GenerateThumb(Option: Smallint; PageNumber: OleVariant); dispid 109;
    function ScrollThumbs(Direction, Amount: Smallint): WordBool; dispid 110;
    function UISetThumbSize(Image, Page: OleVariant): WordBool; dispid 111;
    function GetScrollDirectionSize(ScrollDirectionThumbCount, NonScrollDirectionThumbCount, NonScrollDirectionSize: Integer; ScrollBar: WordBool): Integer; dispid 112;
    procedure Refresh; dispid -550;
    function GetThumbPositionX(ThumbNumber: Integer): Integer; dispid 113;
    function GetThumbPositionY(ThumbNumber: Integer): Integer; dispid 114;
    function GetVersion: WideString; dispid 115;
    property ThumbSelected[PageNumber: Integer]: WordBool dispid 200;
    procedure AboutBox; dispid -552;
  end;

{ Event interface for Wang Image Thumbnail Control }

  _DImgThumbnailEvents = dispinterface
    ['{E1A6B8A2-3603-101C-AC6E-040224009C02}']
    procedure Click(ThumbNumber: Integer); dispid 1;
    procedure DblClick(ThumbNumber: Integer); dispid 2;
    procedure MouseDown(Button, Shift: Smallint; x: OLE_XPOS_PIXELS; y: OLE_YPOS_PIXELS; ThumbNumber: Integer); dispid 3;
    procedure MouseUp(Button, Shift: Smallint; x: OLE_XPOS_PIXELS; y: OLE_YPOS_PIXELS; ThumbNumber: Integer); dispid 4;
    procedure MouseMove(Button, Shift: Smallint; x: OLE_XPOS_PIXELS; y: OLE_YPOS_PIXELS; ThumbNumber: Integer); dispid 5;
    procedure Error(Number: Smallint; var Description: WideString; Scode: Integer; const Source, HelpFile: WideString; HelpContext: Integer; var CancelDisplay: WordBool); dispid -608;
    procedure KeyDown(var KeyCode: Smallint; Shift: Smallint); dispid -602;
    procedure KeyUp(var KeyCode: Smallint; Shift: Smallint); dispid -604;
  end;

{ Wang Image Thumbnail Control }

  TImgThumbnailClick = procedure(Sender: TObject; ThumbNumber: Integer) of object;
  TImgThumbnailDblClick = procedure(Sender: TObject; ThumbNumber: Integer) of object;
  TImgThumbnailMouseDown = procedure(Sender: TObject; Button, Shift: Smallint; x: OLE_XPOS_PIXELS; y: OLE_YPOS_PIXELS; ThumbNumber: Integer) of object;
  TImgThumbnailMouseUp = procedure(Sender: TObject; Button, Shift: Smallint; x: OLE_XPOS_PIXELS; y: OLE_YPOS_PIXELS; ThumbNumber: Integer) of object;
  TImgThumbnailMouseMove = procedure(Sender: TObject; Button, Shift: Smallint; x: OLE_XPOS_PIXELS; y: OLE_YPOS_PIXELS; ThumbNumber: Integer) of object;
  TImgThumbnailError = procedure(Sender: TObject; Number: Smallint; var Description: WideString; Scode: Integer; const Source, HelpFile: WideString; HelpContext: Integer; var CancelDisplay: WordBool) of object;

  TImgThumbnail = class(TOleControl)
  private
    FOnClick: TImgThumbnailClick;
    FOnDblClick: TImgThumbnailDblClick;
    FOnMouseDown: TImgThumbnailMouseDown;
    FOnMouseUp: TImgThumbnailMouseUp;
    FOnMouseMove: TImgThumbnailMouseMove;
    FOnError: TImgThumbnailError;
    FIntf: _DImgThumbnail;
    function GetControlInterface: _DImgThumbnail;
    function Get_hWnd: OLE_HANDLE;
    procedure Set_hWnd(var Value: OLE_HANDLE);
    function Get_ThumbSelected(PageNumber: Integer): WordBool;
    procedure Set_ThumbSelected(PageNumber: Integer; Value: WordBool);
  protected
    procedure CreateControl;
    procedure InitControlData; override;
    function GetTOleEnumProp(Index: Integer): TOleEnum;
    procedure SetTOleEnumProp(Index: Integer; Value: TOleEnum);
  public
    procedure SelectAllThumbs;
    procedure DeselectAllThumbs;
    function GetMinimumSize(ThumbCount: Integer; ScrollBar: WordBool): Integer;
    function GetMaximumSize(ThumbCount: Integer; ScrollBar: WordBool): Integer;
    procedure ClearThumbs(PageNumber: OleVariant);
    procedure InsertThumbs(InsertBeforeThumb, InsertCount: OleVariant);
    procedure DeleteThumbs(DeleteAt: Integer; DeleteCount: OleVariant);
    procedure DisplayThumbs(ThumbNumber, Option: OleVariant);
    procedure GenerateThumb(Option: Smallint; PageNumber: OleVariant);
    function ScrollThumbs(Direction, Amount: Smallint): WordBool;
    function UISetThumbSize(Image, Page: OleVariant): WordBool;
    function GetScrollDirectionSize(ScrollDirectionThumbCount, NonScrollDirectionThumbCount, NonScrollDirectionSize: Integer; ScrollBar: WordBool): Integer;
    procedure Refresh;
    function GetThumbPositionX(ThumbNumber: Integer): Integer;
    function GetThumbPositionY(ThumbNumber: Integer): Integer;
    function GetVersion: WideString;
    procedure AboutBox;
    property ControlInterface: _DImgThumbnail read GetControlInterface;
    property ThumbCount: Integer index 1 read GetIntegerProp write SetIntegerProp;
    property SelectedThumbCount: Integer index 9 read GetIntegerProp write SetIntegerProp;
    property FirstSelectedThumb: Integer index 10 read GetIntegerProp write SetIntegerProp;
    property LastSelectedThumb: Integer index 11 read GetIntegerProp write SetIntegerProp;
    property StatusCode: Integer index 15 read GetIntegerProp write SetIntegerProp;
    property FirstDisplayedThumb: Integer index 19 read GetIntegerProp write SetIntegerProp;
    property LastDisplayedThumb: Integer index 20 read GetIntegerProp write SetIntegerProp;
    property ThumbSelected[PageNumber: Integer]: WordBool read Get_ThumbSelected write Set_ThumbSelected;
  published
    property ParentColor;
    property TabStop;
    property Align;
    property DragCursor;
    property DragMode;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property Visible;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnStartDrag;
    property OnKeyUp;
    property OnKeyDown;
    property ThumbWidth: Integer index 2 read GetIntegerProp write SetIntegerProp stored False;
    property ThumbHeight: Integer index 3 read GetIntegerProp write SetIntegerProp stored False;
    property ScrollDirection: ScrollConstants index 4 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property ThumbCaptionStyle: CaptionStyleConstants index 5 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property ThumbCaptionColor: TColor index 6 read GetTColorProp write SetTColorProp stored False;
    property ThumbCaptionFont: TFont index 7 read GetTFontProp write SetTFontProp stored False;
    property HighlightSelectedThumbs: WordBool index 8 read GetWordBoolProp write SetWordBoolProp stored False;
    property ThumbCaption: WideString index 12 read GetWideStringProp write SetWideStringProp stored False;
    property HighlightColor: TColor index 13 read GetTColorProp write SetTColorProp stored False;
    property ThumbBackColor: TColor index 14 read GetTColorProp write SetTColorProp stored False;
    property Image: WideString index 16 read GetWideStringProp write SetWideStringProp stored False;
    property MousePointer: MousePointerConstants index 17 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property MouseIcon: TPicture index 18 read GetTPictureProp write SetTPictureProp stored False;
    property BackColor: TColor index -501 read GetTColorProp write SetTColorProp stored False;
    property BorderStyle: Smallint index -504 read GetSmallintProp write SetSmallintProp stored False;
    property Enabled: WordBool index -514 read GetWordBoolProp write SetWordBoolProp stored False;
    property hWnd: OLE_HANDLE read Get_hWnd write Set_hWnd stored False;
    property OnClick: TImgThumbnailClick read FOnClick write FOnClick;
    property OnDblClick: TImgThumbnailDblClick read FOnDblClick write FOnDblClick;
    property OnMouseDown: TImgThumbnailMouseDown read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TImgThumbnailMouseUp read FOnMouseUp write FOnMouseUp;
    property OnMouseMove: TImgThumbnailMouseMove read FOnMouseMove write FOnMouseMove;
    property OnError: TImgThumbnailError read FOnError write FOnError;
  end;

procedure Register;

implementation

uses ComObj;

procedure TImgThumbnail.InitControlData;
const
  CEventDispIDs: array[0..5] of Integer = (
    $00000001, $00000002, $00000003, $00000004, $00000005, $FFFFFDA0);
  CTFontIDs: array [0..0] of Integer = (
    $00000007);
  CTPictureIDs: array [0..0] of Integer = (
    $00000012);
  CControlData: TControlData = (
    ClassID: '{E1A6B8A0-3603-101C-AC6E-040224009C02}';
    EventIID: '{E1A6B8A2-3603-101C-AC6E-040224009C02}';
    EventCount: 6;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil;
    Flags: $00000009;
    Version: 300;
    FontCount: 1;
    FontIDs: @CTFontIDs;
    PictureCount: 1;
    PictureIDs: @CTPictureIDs);
begin
  ControlData := @CControlData;
end;

procedure TImgThumbnail.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as _DImgThumbnail;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TImgThumbnail.GetControlInterface: _DImgThumbnail;
begin
  CreateControl;
  Result := FIntf;
end;

function TImgThumbnail.GetTOleEnumProp(Index: Integer): TOleEnum;
begin
  Result := GetIntegerProp(Index);
end;

procedure TImgThumbnail.SetTOleEnumProp(Index: Integer; Value: TOleEnum);
begin
  SetIntegerProp(Index, Value);
end;

procedure TImgThumbnail.SelectAllThumbs;
begin
  CreateControl;
  FIntf.SelectAllThumbs;
end;

procedure TImgThumbnail.DeselectAllThumbs;
begin
  CreateControl;
  FIntf.DeselectAllThumbs;
end;

function TImgThumbnail.GetMinimumSize(ThumbCount: Integer; ScrollBar: WordBool): Integer;
begin
  CreateControl;
  Result := FIntf.GetMinimumSize(ThumbCount, ScrollBar);
end;

function TImgThumbnail.GetMaximumSize(ThumbCount: Integer; ScrollBar: WordBool): Integer;
begin
  CreateControl;
  Result := FIntf.GetMaximumSize(ThumbCount, ScrollBar);
end;

procedure TImgThumbnail.ClearThumbs(PageNumber: OleVariant);
begin
  CreateControl;
  FIntf.ClearThumbs(PageNumber);
end;

procedure TImgThumbnail.InsertThumbs(InsertBeforeThumb, InsertCount: OleVariant);
begin
  CreateControl;
  FIntf.InsertThumbs(InsertBeforeThumb, InsertCount);
end;

procedure TImgThumbnail.DeleteThumbs(DeleteAt: Integer; DeleteCount: OleVariant);
begin
  CreateControl;
  FIntf.DeleteThumbs(DeleteAt, DeleteCount);
end;

procedure TImgThumbnail.DisplayThumbs(ThumbNumber, Option: OleVariant);
begin
  CreateControl;
  FIntf.DisplayThumbs(ThumbNumber, Option);
end;

procedure TImgThumbnail.GenerateThumb(Option: Smallint; PageNumber: OleVariant);
begin
  CreateControl;
  FIntf.GenerateThumb(Option, PageNumber);
end;

function TImgThumbnail.ScrollThumbs(Direction, Amount: Smallint): WordBool;
begin
  CreateControl;
  Result := FIntf.ScrollThumbs(Direction, Amount);
end;

function TImgThumbnail.UISetThumbSize(Image, Page: OleVariant): WordBool;
begin
  CreateControl;
  Result := FIntf.UISetThumbSize(Image, Page);
end;

function TImgThumbnail.GetScrollDirectionSize(ScrollDirectionThumbCount, NonScrollDirectionThumbCount, NonScrollDirectionSize: Integer; ScrollBar: WordBool): Integer;
begin
  CreateControl;
  Result := FIntf.GetScrollDirectionSize(ScrollDirectionThumbCount, NonScrollDirectionThumbCount, NonScrollDirectionSize, ScrollBar);
end;

procedure TImgThumbnail.Refresh;
begin
  CreateControl;
  FIntf.Refresh;
end;

function TImgThumbnail.GetThumbPositionX(ThumbNumber: Integer): Integer;
begin
  CreateControl;
  Result := FIntf.GetThumbPositionX(ThumbNumber);
end;

function TImgThumbnail.GetThumbPositionY(ThumbNumber: Integer): Integer;
begin
  CreateControl;
  Result := FIntf.GetThumbPositionY(ThumbNumber);
end;

function TImgThumbnail.GetVersion: WideString;
begin
  CreateControl;
  Result := FIntf.GetVersion;
end;

procedure TImgThumbnail.AboutBox;
begin
  CreateControl;
  FIntf.AboutBox;
end;

function TImgThumbnail.Get_hWnd: OLE_HANDLE;
begin
  CreateControl;
  Result := FIntf.hWnd;
end;

procedure TImgThumbnail.Set_hWnd(var Value: OLE_HANDLE);
begin
  CreateControl;
  FIntf.hWnd := Value;
end;

function TImgThumbnail.Get_ThumbSelected(PageNumber: Integer): WordBool;
begin
  CreateControl;
  Result := FIntf.ThumbSelected[PageNumber];
end;

procedure TImgThumbnail.Set_ThumbSelected(PageNumber: Integer; Value: WordBool);
begin
  CreateControl;
  FIntf.ThumbSelected[PageNumber] := Value;
end;


procedure Register;
begin
  RegisterComponents('Wang', [TImgThumbnail]);
end;

end.
