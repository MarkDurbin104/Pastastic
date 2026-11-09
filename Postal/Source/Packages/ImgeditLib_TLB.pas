unit ImgeditLib_TLB;

{ This file contains pascal declarations imported from a type library.
  This file will be written during each import or refresh of the type
  library editor.  Changes to this file will be discarded during the
  refresh process. }

{ Wang Image Edit Controls }
{ Version 1.0 }

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

const
  LIBID_ImgeditLib: TGUID = '{6D940288-9F11-11CE-83FD-02608C3EC08A}';

const

{ AnnotationStyleConstants }

  wiTransparent = 0;
  wiOpaque = 1;

{ PageTypeConstants }

  wiPageTypeBW = 1;
  wiPageTypeGray4 = 2;
  wiPageTypeGray8 = 3;
  wiPageTypePal4 = 4;
  wiPageTypePal8 = 5;
  wiPageTypeRGB24 = 6;
  wiPageTypeBGR24 = 7;

{ AnnotationTypeConstants }

  wiNone = 0;
  wiStraightLine = 1;
  wiFreehandLine = 2;
  wiHollowRect = 3;
  wiFilledRect = 4;
  wiImageEmbedded = 5;
  wiImageReference = 6;
  wiText = 7;
  wiTextStamp = 8;
  wiTextFromFile = 9;
  wiTextAttachment = 10;
  wiAnnotationSelection = 11;

{ DisplayScaleConstants }

  wiScaleNormal = 0;
  wiScaleGray4 = 1;
  wiScaleGray8 = 2;
  wiScaleStamp = 3;
  wiScaleOptimize = 4;

{ ImagePaletteConstants }

  wiPaletteCustom = 0;
  wiPaletteCommon = 1;
  wiPaletteGray8 = 2;
  wiPaletteRGB24 = 3;
  wiPaletteBlackWhite = 4;

{ FileTypeConstants }

  wiFileTypeTIFF = 1;
  wiFileTypeAWD = 2;
  wiFileTypeBMP = 3;
  wiFileTypePCX = 4;
  wiFileTypeDCX = 5;
  wiFileTypeJPG = 6;
  wiFileTypeXIF = 7;

{ MousePointerConstants }

  wiMPDefault = 0;
  wiMPArrow = 1;
  wiMPCross = 2;
  wiMPIBeam = 3;
  wiMPIcon = 4;
  wiMPSize = 5;
  wiMPSizeNESW = 6;
  wiMPSizeNS = 7;
  wiMPSizeNWSE = 8;
  wiMPSizeWE = 9;
  wiMPUpArrow = 10;
  wiMPHourGlass = 11;
  wiMPNoDrop = 12;
  wiMPArrowHourglass = 13;
  wiMPArrowQuestion = 14;
  wiMPSizeAll = 15;
  wiMPFreehandLine = 16;
  wiMPHollowRect = 17;
  wiMPFilledRect = 18;
  wiMPRubberStamp = 19;
  wiMPText = 20;
  wiMPTextFromFile = 21;
  wiMPTextAttachment = 22;
  wiMPHand = 23;
  wiMPSelect = 24;
  wiMPCustom = 99;

const

{ Component class GUIDs }
  Class_ImgEdit: TGUID = '{6D940280-9F11-11CE-83FD-02608C3EC08A}';
  Class_ImgAnnTool: TGUID = '{6D940285-9F11-11CE-83FD-02608C3EC08A}';

type

{ Forward declarations: Interfaces }
  _DImgEdit = dispinterface;
  _DImgEditEvents = dispinterface;
  _DImgAnnTool = dispinterface;
  _DImgAnnToolEvents = dispinterface;

{ Forward declarations: CoClasses }
  ImgEdit = _DImgEdit;
  ImgAnnTool = _DImgAnnTool;

{ Forward declarations: Enums }
  AnnotationStyleConstants = TOleEnum;
  PageTypeConstants = TOleEnum;
  AnnotationTypeConstants = TOleEnum;
  DisplayScaleConstants = TOleEnum;
  ImagePaletteConstants = TOleEnum;
  FileTypeConstants = TOleEnum;
  MousePointerConstants = TOleEnum;

{ Dispatch interface for Wang Image Edit Control }

  _DImgEdit = dispinterface
    ['{6D940281-9F11-11CE-83FD-02608C3EC08A}']
    property Image: WideString dispid 1;
    property ImageControl: WideString dispid 2;
    property AnnotationType: AnnotationTypeConstants dispid 3;
    property AnnotationGroupCount: Smallint dispid 4;
    property Zoom: Single dispid 5;
    property Page: Integer dispid 6;
    property AnnotationBackColor: TColor dispid 7;
    property AnnotationFillColor: TColor dispid 8;
    property AnnotationFillStyle: AnnotationStyleConstants dispid 9;
    property AnnotationFont: IFontDisp dispid 10;
    property AnnotationImage: WideString dispid 11;
    property AnnotationLineColor: TColor dispid 12;
    property AnnotationLineStyle: AnnotationStyleConstants dispid 13;
    property AnnotationLineWidth: Smallint dispid 14;
    property AnnotationStampText: WideString dispid 15;
    property AnnotationTextFile: WideString dispid 16;
    property DisplayScaleAlgorithm: DisplayScaleConstants dispid 17;
    property ImageDisplayed: WordBool dispid 18;
    property ImageHeight: OLE_YSIZE_PIXELS dispid 19;
    property ImageModified: WordBool dispid 20;
    property ImagePalette: ImagePaletteConstants dispid 21;
    property ImageResolutionX: Integer dispid 22;
    property ImageResolutionY: Integer dispid 23;
    property MousePointer: MousePointerConstants dispid 24;
    property PageCount: Integer dispid 25;
    property ScrollBars: WordBool dispid 26;
    property ScrollPositionX: OLE_XPOS_PIXELS dispid 27;
    property ScrollPositionY: OLE_YPOS_PIXELS dispid 28;
    property AnnotationFontColor: TColor dispid 29;
    property CompressionType: Smallint dispid 30;
    property FileType: Smallint dispid 31;
    property ScrollShortcutsEnabled: WordBool dispid 32;
    property SelectionRectangle: WordBool dispid 33;
    property PageType: Smallint dispid 34;
    property CompressionInfo: Integer dispid 35;
    property StatusCode: Integer dispid 36;
    property MouseIcon: IPictureDisp dispid 37;
    property AutoRefresh: WordBool dispid 38;
    property ImageWidth: OLE_XSIZE_PIXELS dispid 39;
    property BorderStyle: Smallint dispid -504;
    property Enabled: WordBool dispid -514;
    property hWnd: OLE_HANDLE dispid -515;
    property ImageScaleHeight: OLE_YSIZE_PIXELS dispid 40;
    property ImageScaleWidth: OLE_XSIZE_PIXELS dispid 41;
    procedure Display; dispid 301;
    function GetAnnotationGroup(Index: Smallint): WideString; dispid 302;
    procedure AddAnnotationGroup(const GroupName: WideString); dispid 303;
    function GetSelectedAnnotationLineColor: TColor; dispid 304;
    procedure ClearDisplay; dispid 305;
    procedure DeleteAnnotationGroup(const GroupName: WideString); dispid 306;
    procedure DeleteImageData(Left, Top, Width, Height: OleVariant); dispid 307;
    procedure ClipboardCopy(Left, Top, Width, Height: OleVariant); dispid 308;
    procedure ClipboardCut(Left, Top, Width, Height: OleVariant); dispid 309;
    procedure DeleteSelectedAnnotations; dispid 310;
    procedure Flip; dispid 311;
    function GetSelectedAnnotationBackColor: TColor; dispid 312;
    function GetSelectedAnnotationFont: IFontDisp; dispid 313;
    function GetSelectedAnnotationImage: WideString; dispid 314;
    function GetSelectedAnnotationLineStyle: Smallint; dispid 315;
    function GetSelectedAnnotationLineWidth: Smallint; dispid 316;
    procedure HideAnnotationToolPalette; dispid 317;
    function IsClipboardDataAvailable: WordBool; dispid 318;
    procedure Refresh; dispid 319;
    procedure RotateLeft; dispid 320;
    procedure RotateRight; dispid 321;
    procedure Save(SaveAtZoom: OleVariant); dispid 322;
    procedure ScrollImage(Direction: Smallint; ScrollAmount: Integer); dispid 323;
    procedure SelectAnnotationGroup(const GroupName: WideString); dispid 324;
    procedure SetImagePalette(Option: Smallint); dispid 325;
    procedure SetSelectedAnnotationFillStyle(Style: Smallint); dispid 326;
    procedure SetSelectedAnnotationFont(const Font: IFontDisp); dispid 327;
    procedure SetSelectedAnnotationLineStyle(Style: Smallint); dispid 328;
    procedure SetSelectedAnnotationLineWidth(Width: Smallint); dispid 329;
    procedure ZoomToSelection; dispid 330;
    function GetAnnotationMarkCount(GroupName, AnnotationType: OleVariant): Smallint; dispid 331;
    function GetSelectedAnnotationFillColor: TColor; dispid 332;
    function GetSelectedAnnotationFontColor: TColor; dispid 333;
    function GetCurrentAnnotationGroup: WideString; dispid 334;
    procedure ConvertPageType(PageType: Smallint; Repaint: OleVariant); dispid 335;
    procedure BurnInAnnotations(Option, MarkOption: Smallint; GroupName: OleVariant); dispid 336;
    procedure Draw(Left: OLE_XPOS_PIXELS; Top: OLE_YSIZE_PIXELS; Width, Height: OleVariant); dispid 337;
    procedure SetSelectedAnnotationLineColor(Color: Integer); dispid 338;
    procedure SetSelectedAnnotationFillColor(Color: Integer); dispid 339;
    procedure HideAnnotationGroup(GroupName: OleVariant); dispid 340;
    procedure ShowAnnotationGroup(GroupName: OleVariant); dispid 341;
    function GetSelectedAnnotationFillStyle: Smallint; dispid 342;
    procedure SaveAs(const Image: WideString; FileType, PageType, CompressionType, CompressionInfo, SaveAtZoom: OleVariant); dispid 343;
    procedure SetSelectedAnnotationBackColor(Color: Integer); dispid 344;
    procedure SetSelectedAnnotationFontColor(Color: Integer); dispid 345;
    procedure DrawSelectionRect(Left: OLE_XPOS_PIXELS; Top: OLE_YPOS_PIXELS; Width: OLE_XSIZE_PIXELS; Height: OLE_YSIZE_PIXELS); dispid 346;
    procedure ShowAnnotationToolPalette(ShowAttrDialog, Left, Top, ToolTipText: OleVariant); dispid 347;
    procedure SelectTool(ToolId: Smallint); dispid 348;
    procedure DisplayBlankImage(ImageWidth, ImageHeight: Integer; ResolutionX, ResolutionY, PageType: OleVariant); dispid 349;
    procedure ClipboardPaste(Left, Top: OleVariant); dispid 350;
    procedure PrintImage(StartPage, EndPage, OutputFormat, Annotations, Printer, Driver, PortNumber: OleVariant); dispid 351;
    procedure FitTo(Option: Smallint; Repaint: OleVariant); dispid 352;
    procedure ShowAttribsDialog; dispid 353;
    procedure ShowRubberStampDialog; dispid 354;
    procedure RotateAll(Degrees: OleVariant); dispid 355;
    procedure CacheImage(const Image: WideString; Page: Integer); dispid 356;
    procedure EditSelectedAnnotationText(Left, Top: Integer); dispid 357;
    procedure CompletePaste; dispid 358;
    procedure RemoveImageCache(const Image: WideString; Page: Integer); dispid 359;
    procedure SetCurrentAnnotationGroup(const GroupName: WideString); dispid 360;
    function GetVersion: WideString; dispid 361;
    procedure PrintImageAs(StartPage, EndPage, OutputFormat, Annotations, JobName, Printer, Driver, PortNumber: OleVariant); dispid 362;
    function RenderAllPages(Option, MarkOption: Smallint): Integer; dispid 363;
    procedure AboutBox; dispid -552;
  end;

{ Event interface for Wang Image Edit Control }

  _DImgEditEvents = dispinterface
    ['{6D940282-9F11-11CE-83FD-02608C3EC08A}']
    procedure KeyDown(var KeyCode: Smallint; Shift: Smallint); dispid -602;
    procedure KeyUp(var KeyCode: Smallint; Shift: Smallint); dispid -604;
    procedure KeyPress(var KeyAscii: Smallint); dispid -603;
    procedure MouseDown(Button, Shift: Smallint; x: OLE_XPOS_PIXELS; y: OLE_YPOS_PIXELS); dispid -605;
    procedure MouseMove(Button, Shift: Smallint; x: OLE_XPOS_PIXELS; y: OLE_YPOS_PIXELS); dispid -606;
    procedure MouseUp(Button, Shift: Smallint; x: OLE_XPOS_PIXELS; y: OLE_YPOS_PIXELS); dispid -607;
    procedure Click; dispid -600;
    procedure DblClick; dispid -601;
    procedure Error(Number: Smallint; var Description: WideString; Scode: Integer; const Source, HelpFile: WideString; HelpContext: Integer; var CancelDisplay: WordBool); dispid -608;
    procedure Close; dispid 1;
    procedure MarkEnd(Left, Top, Width, Height: Integer; MarkType: Smallint; const GroupName: WideString); dispid 2;
    procedure ToolSelected(ToolId: Smallint); dispid 3;
    procedure SelectionRectDrawn(Left, Top, Width, Height: Integer); dispid 4;
    procedure ToolTip(Index: Smallint); dispid 5;
    procedure ToolPaletteHidden(Left, Top: Integer); dispid 6;
    procedure Scroll; dispid 7;
    procedure MarkSelect(Button, Shift: Smallint; Left, Top, Width, Height: Integer; MarkType: Smallint; const GroupName: WideString); dispid 8;
    procedure PasteCompleted; dispid 9;
    procedure Load(Zoom: Double); dispid 10;
  end;

{ Wang Image Annotation Control }

  _DImgAnnTool = dispinterface
    ['{6D940286-9F11-11CE-83FD-02608C3EC08A}']
    property AnnotationBackColor: TColor dispid 1;
    property AnnotationFillColor: TColor dispid 2;
    property AnnotationFillStyle: AnnotationStyleConstants dispid 3;
    property AnnotationFont: IFontDisp dispid 4;
    property AnnotationFontColor: TColor dispid 5;
    property AnnotationImage: WideString dispid 6;
    property AnnotationLineColor: TColor dispid 7;
    property AnnotationLineStyle: AnnotationStyleConstants dispid 8;
    property AnnotationLineWidth: Smallint dispid 9;
    property AnnotationStampText: WideString dispid 10;
    property AnnotationTextFile: WideString dispid 11;
    property AnnotationType: AnnotationTypeConstants dispid 12;
    property DestImageControl: WideString dispid 13;
    property Enabled: WordBool dispid -514;
    property PictureDisabled: IPictureDisp dispid 14;
    property PictureDown: IPictureDisp dispid 15;
    property PictureUp: IPictureDisp dispid 16;
    property Value: WordBool dispid 17;
    property hWnd: OLE_HANDLE dispid -515;
    property StatusCode: Integer dispid 18;
    procedure Draw(Left: OLE_XPOS_PIXELS; Top: OLE_YPOS_PIXELS; Width, Height: OleVariant); dispid 301;
    function GetVersion: WideString; dispid 302;
    procedure AboutBox; dispid -552;
  end;

{ Event interface for Wang Image Annotation Control }

  _DImgAnnToolEvents = dispinterface
    ['{6D940287-9F11-11CE-83FD-02608C3EC08A}']
    procedure Click; dispid -600;
    procedure MouseDown(Button, Shift: Smallint; x: OLE_XPOS_PIXELS; y: OLE_YPOS_PIXELS); dispid -605;
    procedure MouseMove(Button, Shift: Smallint; x: OLE_XPOS_PIXELS; y: OLE_YPOS_PIXELS); dispid -606;
    procedure MouseUp(Button, Shift: Smallint; x: OLE_XPOS_PIXELS; y: OLE_YPOS_PIXELS); dispid -607;
    procedure KeyDown(var KeyCode: Smallint; Shift: Smallint); dispid -602;
    procedure KeyPress(var KeyAscii: Smallint); dispid -603;
    procedure KeyUp(var KeyCode: Smallint; Shift: Smallint); dispid -604;
    procedure Error(Number: Smallint; var Description: WideString; Scode: Integer; const Source, HelpFile: WideString; HelpContext: Integer; var CancelDisplay: WordBool); dispid -608;
  end;

{ Wang Image Edit Control }

  TImgEditError = procedure(Sender: TObject; Number: Smallint; var Description: WideString; Scode: Integer; const Source, HelpFile: WideString; HelpContext: Integer; var CancelDisplay: WordBool) of object;
  TImgEditMarkEnd = procedure(Sender: TObject; Left, Top, Width, Height: Integer; MarkType: Smallint; const GroupName: WideString) of object;
  TImgEditToolSelected = procedure(Sender: TObject; ToolId: Smallint) of object;
  TImgEditSelectionRectDrawn = procedure(Sender: TObject; Left, Top, Width, Height: Integer) of object;
  TImgEditToolTip = procedure(Sender: TObject; Index: Smallint) of object;
  TImgEditToolPaletteHidden = procedure(Sender: TObject; Left, Top: Integer) of object;
  TImgEditMarkSelect = procedure(Sender: TObject; Button, Shift: Smallint; Left, Top, Width, Height: Integer; MarkType: Smallint; const GroupName: WideString) of object;
  TImgEditLoad = procedure(Sender: TObject; Zoom: Double) of object;

  TImgEdit = class(TOleControl)
  private
    FOnError: TImgEditError;
    FOnClose: TNotifyEvent;
    FOnMarkEnd: TImgEditMarkEnd;
    FOnToolSelected: TImgEditToolSelected;
    FOnSelectionRectDrawn: TImgEditSelectionRectDrawn;
    FOnToolTip: TImgEditToolTip;
    FOnToolPaletteHidden: TImgEditToolPaletteHidden;
    FOnScroll: TNotifyEvent;
    FOnMarkSelect: TImgEditMarkSelect;
    FOnPasteCompleted: TNotifyEvent;
    FOnLoad: TImgEditLoad;
    FIntf: _DImgEdit;
    function GetControlInterface: _DImgEdit;
    function Get_ImageHeight: OLE_YSIZE_PIXELS;
    procedure Set_ImageHeight(var Value: OLE_YSIZE_PIXELS);
    function Get_ScrollPositionX: OLE_XPOS_PIXELS;
    procedure Set_ScrollPositionX(var Value: OLE_XPOS_PIXELS);
    function Get_ScrollPositionY: OLE_YPOS_PIXELS;
    procedure Set_ScrollPositionY(var Value: OLE_YPOS_PIXELS);
    function Get_ImageWidth: OLE_XSIZE_PIXELS;
    procedure Set_ImageWidth(var Value: OLE_XSIZE_PIXELS);
    function Get_hWnd: OLE_HANDLE;
    procedure Set_hWnd(var Value: OLE_HANDLE);
    function Get_ImageScaleHeight: OLE_YSIZE_PIXELS;
    procedure Set_ImageScaleHeight(var Value: OLE_YSIZE_PIXELS);
    function Get_ImageScaleWidth: OLE_XSIZE_PIXELS;
    procedure Set_ImageScaleWidth(var Value: OLE_XSIZE_PIXELS);
  protected
    procedure CreateControl;
    procedure InitControlData; override;
    function GetTOleEnumProp(Index: Integer): TOleEnum;
    procedure SetTOleEnumProp(Index: Integer; Value: TOleEnum);
  public
    procedure Display;
    function GetAnnotationGroup(Index: Smallint): WideString;
    procedure AddAnnotationGroup(const GroupName: WideString);
    function GetSelectedAnnotationLineColor: TColor;
    procedure ClearDisplay;
    procedure DeleteAnnotationGroup(const GroupName: WideString);
    procedure DeleteImageData(Left, Top, Width, Height: OleVariant);
    procedure ClipboardCopy(Left, Top, Width, Height: OleVariant);
    procedure ClipboardCut(Left, Top, Width, Height: OleVariant);
    procedure DeleteSelectedAnnotations;
    procedure Flip;
    function GetSelectedAnnotationBackColor: TColor;
    function GetSelectedAnnotationFont: IFontDisp;
    function GetSelectedAnnotationImage: WideString;
    function GetSelectedAnnotationLineStyle: Smallint;
    function GetSelectedAnnotationLineWidth: Smallint;
    procedure HideAnnotationToolPalette;
    function IsClipboardDataAvailable: WordBool;
    procedure Refresh;
    procedure RotateLeft;
    procedure RotateRight;
    procedure Save(SaveAtZoom: OleVariant);
    procedure ScrollImage(Direction: Smallint; ScrollAmount: Integer);
    procedure SelectAnnotationGroup(const GroupName: WideString);
    procedure SetImagePalette(Option: Smallint);
    procedure SetSelectedAnnotationFillStyle(Style: Smallint);
    procedure SetSelectedAnnotationFont(const Font: IFontDisp);
    procedure SetSelectedAnnotationLineStyle(Style: Smallint);
    procedure SetSelectedAnnotationLineWidth(Width: Smallint);
    procedure ZoomToSelection;
    function GetAnnotationMarkCount(GroupName, AnnotationType: OleVariant): Smallint;
    function GetSelectedAnnotationFillColor: TColor;
    function GetSelectedAnnotationFontColor: TColor;
    function GetCurrentAnnotationGroup: WideString;
    procedure ConvertPageType(PageType: Smallint; Repaint: OleVariant);
    procedure BurnInAnnotations(Option, MarkOption: Smallint; GroupName: OleVariant);
    procedure Draw(Left: OLE_XPOS_PIXELS; Top: OLE_YSIZE_PIXELS; Width, Height: OleVariant);
    procedure SetSelectedAnnotationLineColor(Color: Integer);
    procedure SetSelectedAnnotationFillColor(Color: Integer);
    procedure HideAnnotationGroup(GroupName: OleVariant);
    procedure ShowAnnotationGroup(GroupName: OleVariant);
    function GetSelectedAnnotationFillStyle: Smallint;
    procedure SaveAs(const Image: WideString; FileType, PageType, CompressionType, CompressionInfo, SaveAtZoom: OleVariant);
    procedure SetSelectedAnnotationBackColor(Color: Integer);
    procedure SetSelectedAnnotationFontColor(Color: Integer);
    procedure DrawSelectionRect(Left: OLE_XPOS_PIXELS; Top: OLE_YPOS_PIXELS; Width: OLE_XSIZE_PIXELS; Height: OLE_YSIZE_PIXELS);
    procedure ShowAnnotationToolPalette(ShowAttrDialog, Left, Top, ToolTipText: OleVariant);
    procedure SelectTool(ToolId: Smallint);
    procedure DisplayBlankImage(ImageWidth, ImageHeight: Integer; ResolutionX, ResolutionY, PageType: OleVariant);
    procedure ClipboardPaste(Left, Top: OleVariant);
    procedure PrintImage(StartPage, EndPage, OutputFormat, Annotations, Printer, Driver, PortNumber: OleVariant);
    procedure FitTo(Option: Smallint; Repaint: OleVariant);
    procedure ShowAttribsDialog;
    procedure ShowRubberStampDialog;
    procedure RotateAll(Degrees: OleVariant);
    procedure CacheImage(const Image: WideString; Page: Integer);
    procedure EditSelectedAnnotationText(Left, Top: Integer);
    procedure CompletePaste;
    procedure RemoveImageCache(const Image: WideString; Page: Integer);
    procedure SetCurrentAnnotationGroup(const GroupName: WideString);
    function GetVersion: WideString;
    procedure PrintImageAs(StartPage, EndPage, OutputFormat, Annotations, JobName, Printer, Driver, PortNumber: OleVariant);
    function RenderAllPages(Option, MarkOption: Smallint): Integer;
    procedure AboutBox;
    property ControlInterface: _DImgEdit read GetControlInterface;
  published
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
    property OnMouseUp;
    property OnMouseMove;
    property OnMouseDown;
    property OnKeyUp;
    property OnKeyPress;
    property OnKeyDown;
    property OnDblClick;
    property OnClick;
    property Image: WideString index 1 read GetWideStringProp write SetWideStringProp stored False;
    property ImageControl: WideString index 2 read GetWideStringProp write SetWideStringProp stored False;
    property AnnotationType: AnnotationTypeConstants index 3 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property AnnotationGroupCount: Smallint index 4 read GetSmallintProp write SetSmallintProp stored False;
    property Zoom: Single index 5 read GetSingleProp write SetSingleProp stored False;
    property Page: Integer index 6 read GetIntegerProp write SetIntegerProp stored False;
    property AnnotationBackColor: TColor index 7 read GetTColorProp write SetTColorProp stored False;
    property AnnotationFillColor: TColor index 8 read GetTColorProp write SetTColorProp stored False;
    property AnnotationFillStyle: AnnotationStyleConstants index 9 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property AnnotationFont: TFont index 10 read GetTFontProp write SetTFontProp stored False;
    property AnnotationImage: WideString index 11 read GetWideStringProp write SetWideStringProp stored False;
    property AnnotationLineColor: TColor index 12 read GetTColorProp write SetTColorProp stored False;
    property AnnotationLineStyle: AnnotationStyleConstants index 13 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property AnnotationLineWidth: Smallint index 14 read GetSmallintProp write SetSmallintProp stored False;
    property AnnotationStampText: WideString index 15 read GetWideStringProp write SetWideStringProp stored False;
    property AnnotationTextFile: WideString index 16 read GetWideStringProp write SetWideStringProp stored False;
    property DisplayScaleAlgorithm: DisplayScaleConstants index 17 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property ImageDisplayed: WordBool index 18 read GetWordBoolProp write SetWordBoolProp stored False;
    property ImageHeight: OLE_YSIZE_PIXELS read Get_ImageHeight write Set_ImageHeight stored False;
    property ImageModified: WordBool index 20 read GetWordBoolProp write SetWordBoolProp stored False;
    property ImagePalette: ImagePaletteConstants index 21 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property ImageResolutionX: Integer index 22 read GetIntegerProp write SetIntegerProp stored False;
    property ImageResolutionY: Integer index 23 read GetIntegerProp write SetIntegerProp stored False;
    property MousePointer: MousePointerConstants index 24 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property PageCount: Integer index 25 read GetIntegerProp write SetIntegerProp stored False;
    property ScrollBars: WordBool index 26 read GetWordBoolProp write SetWordBoolProp stored False;
    property ScrollPositionX: OLE_XPOS_PIXELS read Get_ScrollPositionX write Set_ScrollPositionX stored False;
    property ScrollPositionY: OLE_YPOS_PIXELS read Get_ScrollPositionY write Set_ScrollPositionY stored False;
    property AnnotationFontColor: TColor index 29 read GetTColorProp write SetTColorProp stored False;
    property CompressionType: Smallint index 30 read GetSmallintProp write SetSmallintProp stored False;
    property FileType: Smallint index 31 read GetSmallintProp write SetSmallintProp stored False;
    property ScrollShortcutsEnabled: WordBool index 32 read GetWordBoolProp write SetWordBoolProp stored False;
    property SelectionRectangle: WordBool index 33 read GetWordBoolProp write SetWordBoolProp stored False;
    property PageType: Smallint index 34 read GetSmallintProp write SetSmallintProp stored False;
    property CompressionInfo: Integer index 35 read GetIntegerProp write SetIntegerProp stored False;
    property StatusCode: Integer index 36 read GetIntegerProp write SetIntegerProp stored False;
    property MouseIcon: TPicture index 37 read GetTPictureProp write SetTPictureProp stored False;
    property AutoRefresh: WordBool index 38 read GetWordBoolProp write SetWordBoolProp stored False;
    property ImageWidth: OLE_XSIZE_PIXELS read Get_ImageWidth write Set_ImageWidth stored False;
    property BorderStyle: Smallint index -504 read GetSmallintProp write SetSmallintProp stored False;
    property Enabled: WordBool index -514 read GetWordBoolProp write SetWordBoolProp stored False;
    property hWnd: OLE_HANDLE read Get_hWnd write Set_hWnd stored False;
    property ImageScaleHeight: OLE_YSIZE_PIXELS read Get_ImageScaleHeight write Set_ImageScaleHeight stored False;
    property ImageScaleWidth: OLE_XSIZE_PIXELS read Get_ImageScaleWidth write Set_ImageScaleWidth stored False;
    property OnError: TImgEditError read FOnError write FOnError;
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
    property OnMarkEnd: TImgEditMarkEnd read FOnMarkEnd write FOnMarkEnd;
    property OnToolSelected: TImgEditToolSelected read FOnToolSelected write FOnToolSelected;
    property OnSelectionRectDrawn: TImgEditSelectionRectDrawn read FOnSelectionRectDrawn write FOnSelectionRectDrawn;
    property OnToolTip: TImgEditToolTip read FOnToolTip write FOnToolTip;
    property OnToolPaletteHidden: TImgEditToolPaletteHidden read FOnToolPaletteHidden write FOnToolPaletteHidden;
    property OnScroll: TNotifyEvent read FOnScroll write FOnScroll;
    property OnMarkSelect: TImgEditMarkSelect read FOnMarkSelect write FOnMarkSelect;
    property OnPasteCompleted: TNotifyEvent read FOnPasteCompleted write FOnPasteCompleted;
    property OnLoad: TImgEditLoad read FOnLoad write FOnLoad;
  end;

{ Wang Image Annotation Control }

  TImgAnnToolError = procedure(Sender: TObject; Number: Smallint; var Description: WideString; Scode: Integer; const Source, HelpFile: WideString; HelpContext: Integer; var CancelDisplay: WordBool) of object;

  TImgAnnTool = class(TOleControl)
  private
    FOnError: TImgAnnToolError;
    FIntf: _DImgAnnTool;
    function GetControlInterface: _DImgAnnTool;
    function Get_hWnd: OLE_HANDLE;
    procedure Set_hWnd(var Value: OLE_HANDLE);
  protected
    procedure CreateControl;
    procedure InitControlData; override;
    function GetTOleEnumProp(Index: Integer): TOleEnum;
    procedure SetTOleEnumProp(Index: Integer; Value: TOleEnum);
  public
    procedure Draw(Left: OLE_XPOS_PIXELS; Top: OLE_YPOS_PIXELS; Width, Height: OleVariant);
    function GetVersion: WideString;
    procedure AboutBox;
    property ControlInterface: _DImgAnnTool read GetControlInterface;
  published
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
    property OnMouseUp;
    property OnMouseMove;
    property OnMouseDown;
    property OnKeyUp;
    property OnKeyPress;
    property OnKeyDown;
    property OnClick;
    property AnnotationBackColor: TColor index 1 read GetTColorProp write SetTColorProp stored False;
    property AnnotationFillColor: TColor index 2 read GetTColorProp write SetTColorProp stored False;
    property AnnotationFillStyle: AnnotationStyleConstants index 3 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property AnnotationFont: TFont index 4 read GetTFontProp write SetTFontProp stored False;
    property AnnotationFontColor: TColor index 5 read GetTColorProp write SetTColorProp stored False;
    property AnnotationImage: WideString index 6 read GetWideStringProp write SetWideStringProp stored False;
    property AnnotationLineColor: TColor index 7 read GetTColorProp write SetTColorProp stored False;
    property AnnotationLineStyle: AnnotationStyleConstants index 8 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property AnnotationLineWidth: Smallint index 9 read GetSmallintProp write SetSmallintProp stored False;
    property AnnotationStampText: WideString index 10 read GetWideStringProp write SetWideStringProp stored False;
    property AnnotationTextFile: WideString index 11 read GetWideStringProp write SetWideStringProp stored False;
    property AnnotationType: AnnotationTypeConstants index 12 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property DestImageControl: WideString index 13 read GetWideStringProp write SetWideStringProp stored False;
    property Enabled: WordBool index -514 read GetWordBoolProp write SetWordBoolProp stored False;
    property PictureDisabled: TPicture index 14 read GetTPictureProp write SetTPictureProp stored False;
    property PictureDown: TPicture index 15 read GetTPictureProp write SetTPictureProp stored False;
    property PictureUp: TPicture index 16 read GetTPictureProp write SetTPictureProp stored False;
    property Value: WordBool index 17 read GetWordBoolProp write SetWordBoolProp stored False;
    property hWnd: OLE_HANDLE read Get_hWnd write Set_hWnd stored False;
    property StatusCode: Integer index 18 read GetIntegerProp write SetIntegerProp stored False;
    property OnError: TImgAnnToolError read FOnError write FOnError;
  end;

procedure Register;

implementation

uses ComObj;

procedure TImgEdit.InitControlData;
const
  CEventDispIDs: array[0..10] of Integer = (
    $FFFFFDA0, $00000001, $00000002, $00000003, $00000004, $00000005,
    $00000006, $00000007, $00000008, $00000009, $0000000A);
  CTFontIDs: array [0..0] of Integer = (
    $0000000A);
  CTPictureIDs: array [0..0] of Integer = (
    $00000025);
  CControlData: TControlData = (
    ClassID: '{6D940280-9F11-11CE-83FD-02608C3EC08A}';
    EventIID: '{6D940282-9F11-11CE-83FD-02608C3EC08A}';
    EventCount: 11;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil;
    Flags: $00000008;
    Version: 300;
    FontCount: 1;
    FontIDs: @CTFontIDs;
    PictureCount: 1;
    PictureIDs: @CTPictureIDs);
begin
  ControlData := @CControlData;
end;

procedure TImgEdit.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as _DImgEdit;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TImgEdit.GetControlInterface: _DImgEdit;
begin
  CreateControl;
  Result := FIntf;
end;

function TImgEdit.GetTOleEnumProp(Index: Integer): TOleEnum;
begin
  Result := GetIntegerProp(Index);
end;

procedure TImgEdit.SetTOleEnumProp(Index: Integer; Value: TOleEnum);
begin
  SetIntegerProp(Index, Value);
end;

procedure TImgEdit.Display;
begin
  CreateControl;
  FIntf.Display;
end;

function TImgEdit.GetAnnotationGroup(Index: Smallint): WideString;
begin
  CreateControl;
  Result := FIntf.GetAnnotationGroup(Index);
end;

procedure TImgEdit.AddAnnotationGroup(const GroupName: WideString);
begin
  CreateControl;
  FIntf.AddAnnotationGroup(GroupName);
end;

function TImgEdit.GetSelectedAnnotationLineColor: TColor;
begin
  CreateControl;
  Result := FIntf.GetSelectedAnnotationLineColor;
end;

procedure TImgEdit.ClearDisplay;
begin
  CreateControl;
  FIntf.ClearDisplay;
end;

procedure TImgEdit.DeleteAnnotationGroup(const GroupName: WideString);
begin
  CreateControl;
  FIntf.DeleteAnnotationGroup(GroupName);
end;

procedure TImgEdit.DeleteImageData(Left, Top, Width, Height: OleVariant);
begin
  CreateControl;
  FIntf.DeleteImageData(Left, Top, Width, Height);
end;

procedure TImgEdit.ClipboardCopy(Left, Top, Width, Height: OleVariant);
begin
  CreateControl;
  FIntf.ClipboardCopy(Left, Top, Width, Height);
end;

procedure TImgEdit.ClipboardCut(Left, Top, Width, Height: OleVariant);
begin
  CreateControl;
  FIntf.ClipboardCut(Left, Top, Width, Height);
end;

procedure TImgEdit.DeleteSelectedAnnotations;
begin
  CreateControl;
  FIntf.DeleteSelectedAnnotations;
end;

procedure TImgEdit.Flip;
begin
  CreateControl;
  FIntf.Flip;
end;

function TImgEdit.GetSelectedAnnotationBackColor: TColor;
begin
  CreateControl;
  Result := FIntf.GetSelectedAnnotationBackColor;
end;

function TImgEdit.GetSelectedAnnotationFont: IFontDisp;
begin
  CreateControl;
  Result := FIntf.GetSelectedAnnotationFont;
end;

function TImgEdit.GetSelectedAnnotationImage: WideString;
begin
  CreateControl;
  Result := FIntf.GetSelectedAnnotationImage;
end;

function TImgEdit.GetSelectedAnnotationLineStyle: Smallint;
begin
  CreateControl;
  Result := FIntf.GetSelectedAnnotationLineStyle;
end;

function TImgEdit.GetSelectedAnnotationLineWidth: Smallint;
begin
  CreateControl;
  Result := FIntf.GetSelectedAnnotationLineWidth;
end;

procedure TImgEdit.HideAnnotationToolPalette;
begin
  CreateControl;
  FIntf.HideAnnotationToolPalette;
end;

function TImgEdit.IsClipboardDataAvailable: WordBool;
begin
  CreateControl;
  Result := FIntf.IsClipboardDataAvailable;
end;

procedure TImgEdit.Refresh;
begin
  CreateControl;
  FIntf.Refresh;
end;

procedure TImgEdit.RotateLeft;
begin
  CreateControl;
  FIntf.RotateLeft;
end;

procedure TImgEdit.RotateRight;
begin
  CreateControl;
  FIntf.RotateRight;
end;

procedure TImgEdit.Save(SaveAtZoom: OleVariant);
begin
  CreateControl;
  FIntf.Save(SaveAtZoom);
end;

procedure TImgEdit.ScrollImage(Direction: Smallint; ScrollAmount: Integer);
begin
  CreateControl;
  FIntf.ScrollImage(Direction, ScrollAmount);
end;

procedure TImgEdit.SelectAnnotationGroup(const GroupName: WideString);
begin
  CreateControl;
  FIntf.SelectAnnotationGroup(GroupName);
end;

procedure TImgEdit.SetImagePalette(Option: Smallint);
begin
  CreateControl;
  FIntf.SetImagePalette(Option);
end;

procedure TImgEdit.SetSelectedAnnotationFillStyle(Style: Smallint);
begin
  CreateControl;
  FIntf.SetSelectedAnnotationFillStyle(Style);
end;

procedure TImgEdit.SetSelectedAnnotationFont(const Font: IFontDisp);
begin
  CreateControl;
  FIntf.SetSelectedAnnotationFont(Font);
end;

procedure TImgEdit.SetSelectedAnnotationLineStyle(Style: Smallint);
begin
  CreateControl;
  FIntf.SetSelectedAnnotationLineStyle(Style);
end;

procedure TImgEdit.SetSelectedAnnotationLineWidth(Width: Smallint);
begin
  CreateControl;
  FIntf.SetSelectedAnnotationLineWidth(Width);
end;

procedure TImgEdit.ZoomToSelection;
begin
  CreateControl;
  FIntf.ZoomToSelection;
end;

function TImgEdit.GetAnnotationMarkCount(GroupName, AnnotationType: OleVariant): Smallint;
begin
  CreateControl;
  Result := FIntf.GetAnnotationMarkCount(GroupName, AnnotationType);
end;

function TImgEdit.GetSelectedAnnotationFillColor: TColor;
begin
  CreateControl;
  Result := FIntf.GetSelectedAnnotationFillColor;
end;

function TImgEdit.GetSelectedAnnotationFontColor: TColor;
begin
  CreateControl;
  Result := FIntf.GetSelectedAnnotationFontColor;
end;

function TImgEdit.GetCurrentAnnotationGroup: WideString;
begin
  CreateControl;
  Result := FIntf.GetCurrentAnnotationGroup;
end;

procedure TImgEdit.ConvertPageType(PageType: Smallint; Repaint: OleVariant);
begin
  CreateControl;
  FIntf.ConvertPageType(PageType, Repaint);
end;

procedure TImgEdit.BurnInAnnotations(Option, MarkOption: Smallint; GroupName: OleVariant);
begin
  CreateControl;
  FIntf.BurnInAnnotations(Option, MarkOption, GroupName);
end;

procedure TImgEdit.Draw(Left: OLE_XPOS_PIXELS; Top: OLE_YSIZE_PIXELS; Width, Height: OleVariant);
begin
  CreateControl;
  FIntf.Draw(Left, Top, Width, Height);
end;

procedure TImgEdit.SetSelectedAnnotationLineColor(Color: Integer);
begin
  CreateControl;
  FIntf.SetSelectedAnnotationLineColor(Color);
end;

procedure TImgEdit.SetSelectedAnnotationFillColor(Color: Integer);
begin
  CreateControl;
  FIntf.SetSelectedAnnotationFillColor(Color);
end;

procedure TImgEdit.HideAnnotationGroup(GroupName: OleVariant);
begin
  CreateControl;
  FIntf.HideAnnotationGroup(GroupName);
end;

procedure TImgEdit.ShowAnnotationGroup(GroupName: OleVariant);
begin
  CreateControl;
  FIntf.ShowAnnotationGroup(GroupName);
end;

function TImgEdit.GetSelectedAnnotationFillStyle: Smallint;
begin
  CreateControl;
  Result := FIntf.GetSelectedAnnotationFillStyle;
end;

procedure TImgEdit.SaveAs(const Image: WideString; FileType, PageType, CompressionType, CompressionInfo, SaveAtZoom: OleVariant);
begin
  CreateControl;
  FIntf.SaveAs(Image, FileType, PageType, CompressionType, CompressionInfo, SaveAtZoom);
end;

procedure TImgEdit.SetSelectedAnnotationBackColor(Color: Integer);
begin
  CreateControl;
  FIntf.SetSelectedAnnotationBackColor(Color);
end;

procedure TImgEdit.SetSelectedAnnotationFontColor(Color: Integer);
begin
  CreateControl;
  FIntf.SetSelectedAnnotationFontColor(Color);
end;

procedure TImgEdit.DrawSelectionRect(Left: OLE_XPOS_PIXELS; Top: OLE_YPOS_PIXELS; Width: OLE_XSIZE_PIXELS; Height: OLE_YSIZE_PIXELS);
begin
  CreateControl;
  FIntf.DrawSelectionRect(Left, Top, Width, Height);
end;

procedure TImgEdit.ShowAnnotationToolPalette(ShowAttrDialog, Left, Top, ToolTipText: OleVariant);
begin
  CreateControl;
  FIntf.ShowAnnotationToolPalette(ShowAttrDialog, Left, Top, ToolTipText);
end;

procedure TImgEdit.SelectTool(ToolId: Smallint);
begin
  CreateControl;
  FIntf.SelectTool(ToolId);
end;

procedure TImgEdit.DisplayBlankImage(ImageWidth, ImageHeight: Integer; ResolutionX, ResolutionY, PageType: OleVariant);
begin
  CreateControl;
  FIntf.DisplayBlankImage(ImageWidth, ImageHeight, ResolutionX, ResolutionY, PageType);
end;

procedure TImgEdit.ClipboardPaste(Left, Top: OleVariant);
begin
  CreateControl;
  FIntf.ClipboardPaste(Left, Top);
end;

procedure TImgEdit.PrintImage(StartPage, EndPage, OutputFormat, Annotations, Printer, Driver, PortNumber: OleVariant);
begin
  CreateControl;
  FIntf.PrintImage(StartPage, EndPage, OutputFormat, Annotations, Printer, Driver, PortNumber);
end;

procedure TImgEdit.FitTo(Option: Smallint; Repaint: OleVariant);
begin
  CreateControl;
  FIntf.FitTo(Option, Repaint);
end;

procedure TImgEdit.ShowAttribsDialog;
begin
  CreateControl;
  FIntf.ShowAttribsDialog;
end;

procedure TImgEdit.ShowRubberStampDialog;
begin
  CreateControl;
  FIntf.ShowRubberStampDialog;
end;

procedure TImgEdit.RotateAll(Degrees: OleVariant);
begin
  CreateControl;
  FIntf.RotateAll(Degrees);
end;

procedure TImgEdit.CacheImage(const Image: WideString; Page: Integer);
begin
  CreateControl;
  FIntf.CacheImage(Image, Page);
end;

procedure TImgEdit.EditSelectedAnnotationText(Left, Top: Integer);
begin
  CreateControl;
  FIntf.EditSelectedAnnotationText(Left, Top);
end;

procedure TImgEdit.CompletePaste;
begin
  CreateControl;
  FIntf.CompletePaste;
end;

procedure TImgEdit.RemoveImageCache(const Image: WideString; Page: Integer);
begin
  CreateControl;
  FIntf.RemoveImageCache(Image, Page);
end;

procedure TImgEdit.SetCurrentAnnotationGroup(const GroupName: WideString);
begin
  CreateControl;
  FIntf.SetCurrentAnnotationGroup(GroupName);
end;

function TImgEdit.GetVersion: WideString;
begin
  CreateControl;
  Result := FIntf.GetVersion;
end;

procedure TImgEdit.PrintImageAs(StartPage, EndPage, OutputFormat, Annotations, JobName, Printer, Driver, PortNumber: OleVariant);
begin
  CreateControl;
  FIntf.PrintImageAs(StartPage, EndPage, OutputFormat, Annotations, JobName, Printer, Driver, PortNumber);
end;

function TImgEdit.RenderAllPages(Option, MarkOption: Smallint): Integer;
begin
  CreateControl;
  Result := FIntf.RenderAllPages(Option, MarkOption);
end;

procedure TImgEdit.AboutBox;
begin
  CreateControl;
  FIntf.AboutBox;
end;

function TImgEdit.Get_ImageHeight: OLE_YSIZE_PIXELS;
begin
  CreateControl;
  Result := FIntf.ImageHeight;
end;

procedure TImgEdit.Set_ImageHeight(var Value: OLE_YSIZE_PIXELS);
begin
  CreateControl;
  FIntf.ImageHeight := Value;
end;

function TImgEdit.Get_ScrollPositionX: OLE_XPOS_PIXELS;
begin
  CreateControl;
  Result := FIntf.ScrollPositionX;
end;

procedure TImgEdit.Set_ScrollPositionX(var Value: OLE_XPOS_PIXELS);
begin
  CreateControl;
  FIntf.ScrollPositionX := Value;
end;

function TImgEdit.Get_ScrollPositionY: OLE_YPOS_PIXELS;
begin
  CreateControl;
  Result := FIntf.ScrollPositionY;
end;

procedure TImgEdit.Set_ScrollPositionY(var Value: OLE_YPOS_PIXELS);
begin
  CreateControl;
  FIntf.ScrollPositionY := Value;
end;

function TImgEdit.Get_ImageWidth: OLE_XSIZE_PIXELS;
begin
  CreateControl;
  Result := FIntf.ImageWidth;
end;

procedure TImgEdit.Set_ImageWidth(var Value: OLE_XSIZE_PIXELS);
begin
  CreateControl;
  FIntf.ImageWidth := Value;
end;

function TImgEdit.Get_hWnd: OLE_HANDLE;
begin
  CreateControl;
  Result := FIntf.hWnd;
end;

procedure TImgEdit.Set_hWnd(var Value: OLE_HANDLE);
begin
  CreateControl;
  FIntf.hWnd := Value;
end;

function TImgEdit.Get_ImageScaleHeight: OLE_YSIZE_PIXELS;
begin
  CreateControl;
  Result := FIntf.ImageScaleHeight;
end;

procedure TImgEdit.Set_ImageScaleHeight(var Value: OLE_YSIZE_PIXELS);
begin
  CreateControl;
  FIntf.ImageScaleHeight := Value;
end;

function TImgEdit.Get_ImageScaleWidth: OLE_XSIZE_PIXELS;
begin
  CreateControl;
  Result := FIntf.ImageScaleWidth;
end;

procedure TImgEdit.Set_ImageScaleWidth(var Value: OLE_XSIZE_PIXELS);
begin
  CreateControl;
  FIntf.ImageScaleWidth := Value;
end;


procedure TImgAnnTool.InitControlData;
const
  CEventDispIDs: array[0..0] of Integer = (
    $FFFFFDA0);
  CTFontIDs: array [0..0] of Integer = (
    $00000004);
  CTPictureIDs: array [0..2] of Integer = (
    $0000000E, $0000000F, $00000010);
  CControlData: TControlData = (
    ClassID: '{6D940285-9F11-11CE-83FD-02608C3EC08A}';
    EventIID: '{6D940287-9F11-11CE-83FD-02608C3EC08A}';
    EventCount: 1;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil;
    Flags: $00000008;
    Version: 300;
    FontCount: 1;
    FontIDs: @CTFontIDs;
    PictureCount: 3;
    PictureIDs: @CTPictureIDs);
begin
  ControlData := @CControlData;
end;

procedure TImgAnnTool.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as _DImgAnnTool;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TImgAnnTool.GetControlInterface: _DImgAnnTool;
begin
  CreateControl;
  Result := FIntf;
end;

function TImgAnnTool.GetTOleEnumProp(Index: Integer): TOleEnum;
begin
  Result := GetIntegerProp(Index);
end;

procedure TImgAnnTool.SetTOleEnumProp(Index: Integer; Value: TOleEnum);
begin
  SetIntegerProp(Index, Value);
end;

procedure TImgAnnTool.Draw(Left: OLE_XPOS_PIXELS; Top: OLE_YPOS_PIXELS; Width, Height: OleVariant);
begin
  CreateControl;
  FIntf.Draw(Left, Top, Width, Height);
end;

function TImgAnnTool.GetVersion: WideString;
begin
  CreateControl;
  Result := FIntf.GetVersion;
end;

procedure TImgAnnTool.AboutBox;
begin
  CreateControl;
  FIntf.AboutBox;
end;

function TImgAnnTool.Get_hWnd: OLE_HANDLE;
begin
  CreateControl;
  Result := FIntf.hWnd;
end;

procedure TImgAnnTool.Set_hWnd(var Value: OLE_HANDLE);
begin
  CreateControl;
  FIntf.hWnd := Value;
end;


procedure Register;
begin
  RegisterComponents('Wang', [TImgEdit, TImgAnnTool]);
end;

end.
