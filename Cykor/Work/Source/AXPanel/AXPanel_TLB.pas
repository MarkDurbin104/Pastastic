unit AXPanel_TLB;

{ This file contains pascal declarations imported from a type library.
  This file will be written during each import or refresh of the type
  library editor.  Changes to this file will be discarded during the
  refresh process. }

{ AXPanel Library }
{ Version 1.0 }

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

const
  LIBID_AXPanel: TGUID = '{2C07D488-560C-485E-B5AA-3ECEF23734AF}';

const

{ TxAlignment }

  taLeftJustify = 0;
  taRightJustify = 1;
  taCenter = 2;

{ TxPanelBevel }

  bvNone = 0;
  bvLowered = 1;
  bvRaised = 2;

{ TxBorderStyle }

  bsNone = 0;
  bsSingle = 1;

{ TxDragMode }

  dmManual = 0;
  dmAutomatic = 1;

{ TxMouseButton }

  mbLeft = 0;
  mbRight = 1;
  mbMiddle = 2;

const

{ Component class GUIDs }
  Class_PanelX: TGUID = '{D3A44CEA-23A1-4CB2-AD3A-96D059EF9E8E}';

type

{ Forward declarations: Interfaces }
  IPanelX = interface;
  IPanelXDisp = dispinterface;
  IPanelXEvents = dispinterface;

{ Forward declarations: CoClasses }
  PanelX = IPanelX;

{ Forward declarations: Enums }
  TxAlignment = TOleEnum;
  TxPanelBevel = TOleEnum;
  TxBorderStyle = TOleEnum;
  TxDragMode = TOleEnum;
  TxMouseButton = TOleEnum;

{ Dispatch interface for PanelX Control }

  IPanelX = interface(IDispatch)
    ['{8F74C763-9848-4A3B-9D72-10940B0E442B}']
    function Get_Alignment: TxAlignment; safecall;
    procedure Set_Alignment(Value: TxAlignment); safecall;
    function Get_BevelInner: TxPanelBevel; safecall;
    procedure Set_BevelInner(Value: TxPanelBevel); safecall;
    function Get_BevelOuter: TxPanelBevel; safecall;
    procedure Set_BevelOuter(Value: TxPanelBevel); safecall;
    function Get_BevelWidth: Integer; safecall;
    procedure Set_BevelWidth(Value: Integer); safecall;
    function Get_BorderWidth: Integer; safecall;
    procedure Set_BorderWidth(Value: Integer); safecall;
    function Get_BorderStyle: TxBorderStyle; safecall;
    procedure Set_BorderStyle(Value: TxBorderStyle); safecall;
    function Get_DragCursor: Smallint; safecall;
    procedure Set_DragCursor(Value: Smallint); safecall;
    function Get_DragMode: TxDragMode; safecall;
    procedure Set_DragMode(Value: TxDragMode); safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    function Get_FullRepaint: WordBool; safecall;
    procedure Set_FullRepaint(Value: WordBool); safecall;
    function Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    function Get_Color: Integer; safecall;
    procedure Set_Color(Value: Integer); safecall;
    function Get_Ctl3D: WordBool; safecall;
    procedure Set_Ctl3D(Value: WordBool); safecall;
    function Get_Locked: WordBool; safecall;
    procedure Set_Locked(Value: WordBool); safecall;
    function Get_ParentColor: WordBool; safecall;
    procedure Set_ParentColor(Value: WordBool); safecall;
    function Get_ParentCtl3D: WordBool; safecall;
    procedure Set_ParentCtl3D(Value: WordBool); safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_Cursor: Smallint; safecall;
    procedure Set_Cursor(Value: Smallint); safecall;
    procedure AboutBox; safecall;
    function Get_TabOrder: Integer; safecall;
    procedure Set_TabOrder(Value: Integer); safecall;
    property Alignment: TxAlignment read Get_Alignment write Set_Alignment;
    property BevelInner: TxPanelBevel read Get_BevelInner write Set_BevelInner;
    property BevelOuter: TxPanelBevel read Get_BevelOuter write Set_BevelOuter;
    property BevelWidth: Integer read Get_BevelWidth write Set_BevelWidth;
    property BorderWidth: Integer read Get_BorderWidth write Set_BorderWidth;
    property BorderStyle: TxBorderStyle read Get_BorderStyle write Set_BorderStyle;
    property DragCursor: Smallint read Get_DragCursor write Set_DragCursor;
    property DragMode: TxDragMode read Get_DragMode write Set_DragMode;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property FullRepaint: WordBool read Get_FullRepaint write Set_FullRepaint;
    property Caption: WideString read Get_Caption write Set_Caption;
    property Color: Integer read Get_Color write Set_Color;
    property Ctl3D: WordBool read Get_Ctl3D write Set_Ctl3D;
    property Locked: WordBool read Get_Locked write Set_Locked;
    property ParentColor: WordBool read Get_ParentColor write Set_ParentColor;
    property ParentCtl3D: WordBool read Get_ParentCtl3D write Set_ParentCtl3D;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Cursor: Smallint read Get_Cursor write Set_Cursor;
    property TabOrder: Integer read Get_TabOrder write Set_TabOrder;
  end;

{ DispInterface declaration for Dual Interface IPanelX }

  IPanelXDisp = dispinterface
    ['{8F74C763-9848-4A3B-9D72-10940B0E442B}']
    property Alignment: TxAlignment dispid 1;
    property BevelInner: TxPanelBevel dispid 2;
    property BevelOuter: TxPanelBevel dispid 3;
    property BevelWidth: Integer dispid 4;
    property BorderWidth: Integer dispid 5;
    property BorderStyle: TxBorderStyle dispid 6;
    property DragCursor: Smallint dispid 7;
    property DragMode: TxDragMode dispid 8;
    property Enabled: WordBool dispid 9;
    property FullRepaint: WordBool dispid 10;
    property Caption: WideString dispid 11;
    property Color: Integer dispid 12;
    property Ctl3D: WordBool dispid 13;
    property Locked: WordBool dispid 14;
    property ParentColor: WordBool dispid 15;
    property ParentCtl3D: WordBool dispid 16;
    property Visible: WordBool dispid 17;
    property Cursor: Smallint dispid 18;
    procedure AboutBox; dispid -552;
    property TabOrder: Integer dispid 19;
  end;

{ Events interface for PanelX Control }

  IPanelXEvents = dispinterface
    ['{9B3E27F6-6ED8-48C7-87F9-DDB76061DD52}']
    procedure OnClick; dispid 1;
    procedure OnDblClick; dispid 2;
    procedure OnResize; dispid 3;
  end;

{ PanelXControl }

  TPanelX = class(TOleControl)
  private
    FOnClick: TNotifyEvent;
    FOnDblClick: TNotifyEvent;
    FOnResize: TNotifyEvent;
    FIntf: IPanelX;
    function GetControlInterface: IPanelX;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
    function GetTOleEnumProp(Index: Integer): TOleEnum;
    procedure SetTOleEnumProp(Index: Integer; Value: TOleEnum);
  public
    procedure AboutBox;
    property ControlInterface: IPanelX read GetControlInterface;
  published
    property Align;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnStartDrag;
    property Alignment: TxAlignment index 1 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property BevelInner: TxPanelBevel index 2 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property BevelOuter: TxPanelBevel index 3 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property BevelWidth: Integer index 4 read GetIntegerProp write SetIntegerProp stored False;
    property BorderWidth: Integer index 5 read GetIntegerProp write SetIntegerProp stored False;
    property BorderStyle: TxBorderStyle index 6 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property DragCursor: Smallint index 7 read GetSmallintProp write SetSmallintProp stored False;
    property DragMode: TxDragMode index 8 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property Enabled: WordBool index 9 read GetWordBoolProp write SetWordBoolProp stored False;
    property FullRepaint: WordBool index 10 read GetWordBoolProp write SetWordBoolProp stored False;
    property Caption: WideString index 11 read GetWideStringProp write SetWideStringProp stored False;
    property Color: Integer index 12 read GetIntegerProp write SetIntegerProp stored False;
    property Ctl3D: WordBool index 13 read GetWordBoolProp write SetWordBoolProp stored False;
    property Locked: WordBool index 14 read GetWordBoolProp write SetWordBoolProp stored False;
    property ParentColor: WordBool index 15 read GetWordBoolProp write SetWordBoolProp stored False;
    property ParentCtl3D: WordBool index 16 read GetWordBoolProp write SetWordBoolProp stored False;
    property Visible: WordBool index 17 read GetWordBoolProp write SetWordBoolProp stored False;
    property Cursor: Smallint index 18 read GetSmallintProp write SetSmallintProp stored False;
    property TabOrder: Integer index 19 read GetIntegerProp write SetIntegerProp stored False;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnResize: TNotifyEvent read FOnResize write FOnResize;
  end;

procedure Register;

implementation

uses ComObj;

procedure TPanelX.InitControlData;
const
  CEventDispIDs: array[0..2] of Integer = (
    $00000001, $00000002, $00000003);
  CControlData: TControlData = (
    ClassID: '{D3A44CEA-23A1-4CB2-AD3A-96D059EF9E8E}';
    EventIID: '{9B3E27F6-6ED8-48C7-87F9-DDB76061DD52}';
    EventCount: 3;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil;
    Flags: $00000000;
    Version: 300);
begin
  ControlData := @CControlData;
end;

procedure TPanelX.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IPanelX;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TPanelX.GetControlInterface: IPanelX;
begin
  CreateControl;
  Result := FIntf;
end;

function TPanelX.GetTOleEnumProp(Index: Integer): TOleEnum;
begin
  Result := GetIntegerProp(Index);
end;

procedure TPanelX.SetTOleEnumProp(Index: Integer; Value: TOleEnum);
begin
  SetIntegerProp(Index, Value);
end;

procedure TPanelX.AboutBox;
begin
  CreateControl;
  FIntf.AboutBox;
end;


procedure Register;
begin
  RegisterComponents('ActiveX', [TPanelX]);
end;

end.
