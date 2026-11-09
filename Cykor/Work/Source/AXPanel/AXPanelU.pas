unit AXPanelU;

interface

uses
  Windows, ActiveX, Classes, Controls, Graphics, Menus, Forms, StdCtrls,
  ComServ, StdVCL, AXCtrls, AXPanel_TLB, ExtCtrls;

type
  TPanelX = class(TActiveXControl, IPanelX)
  private
    { Private declarations }
    FDelphiControl: TPanel;
    FEvents: IPanelXEvents;
    procedure ClickEvent(Sender: TObject);
    procedure DblClickEvent(Sender: TObject);
    procedure ResizeEvent(Sender: TObject);
  protected
    { Protected declarations }
    procedure InitializeControl; override;
    procedure EventSinkChanged(const EventSink: IUnknown); override;
    procedure DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage); override;
    function Get_Alignment: TxAlignment; safecall;
    function Get_BevelInner: TxPanelBevel; safecall;
    function Get_BevelOuter: TxPanelBevel; safecall;
    function Get_BevelWidth: Integer; safecall;
    function Get_BorderStyle: TxBorderStyle; safecall;
    function Get_BorderWidth: Integer; safecall;
    function Get_Caption: WideString; safecall;
    function Get_Color: Integer; safecall;
    function Get_Ctl3D: WordBool; safecall;
    function Get_Cursor: Smallint; safecall;
    function Get_DragCursor: Smallint; safecall;
    function Get_DragMode: TxDragMode; safecall;
    function Get_Enabled: WordBool; safecall;
    function Get_FullRepaint: WordBool; safecall;
    function Get_Locked: WordBool; safecall;
    function Get_ParentColor: WordBool; safecall;
    function Get_ParentCtl3D: WordBool; safecall;
    function Get_Visible: WordBool; safecall;
    procedure AboutBox; safecall;
    procedure Set_Alignment(Value: TxAlignment); safecall;
    procedure Set_BevelInner(Value: TxPanelBevel); safecall;
    procedure Set_BevelOuter(Value: TxPanelBevel); safecall;
    procedure Set_BevelWidth(Value: Integer); safecall;
    procedure Set_BorderStyle(Value: TxBorderStyle); safecall;
    procedure Set_BorderWidth(Value: Integer); safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    procedure Set_Color(Value: Integer); safecall;
    procedure Set_Ctl3D(Value: WordBool); safecall;
    procedure Set_Cursor(Value: Smallint); safecall;
    procedure Set_DragCursor(Value: Smallint); safecall;
    procedure Set_DragMode(Value: TxDragMode); safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    procedure Set_FullRepaint(Value: WordBool); safecall;
    procedure Set_Locked(Value: WordBool); safecall;
    procedure Set_ParentColor(Value: WordBool); safecall;
    procedure Set_ParentCtl3D(Value: WordBool); safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_TabOrder: Integer; safecall;
    procedure Set_TabOrder(Value: Integer); safecall;
  end;

implementation

uses AXPanelAbout;

{ TPanelX }

procedure TPanelX.InitializeControl;
begin
  FDelphiControl := Control as TPanel;
  FDelphiControl.OnClick := ClickEvent;
  FDelphiControl.OnDblClick := DblClickEvent;
  FDelphiControl.OnResize := ResizeEvent;
end;

procedure TPanelX.EventSinkChanged(const EventSink: IUnknown);
begin
  FEvents := EventSink as IPanelXEvents;
end;

procedure TPanelX.DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage);
begin
  { Define property pages here.  Property pages are defined by calling
    DefinePropertyPage with the class id of the page.  For example,
      DefinePropertyPage(Class_PanelXPage); }
end;

function TPanelX.Get_Alignment: TxAlignment;
begin
  Result := Ord(FDelphiControl.Alignment);
end;

function TPanelX.Get_BevelInner: TxPanelBevel;
begin
  Result := Ord(FDelphiControl.BevelInner);
end;

function TPanelX.Get_BevelOuter: TxPanelBevel;
begin
  Result := Ord(FDelphiControl.BevelOuter);
end;

function TPanelX.Get_BevelWidth: Integer;
begin
  Result := Integer(FDelphiControl.BevelWidth);
end;

function TPanelX.Get_BorderStyle: TxBorderStyle;
begin
  Result := Ord(FDelphiControl.BorderStyle);
end;

function TPanelX.Get_BorderWidth: Integer;
begin
  Result := Integer(FDelphiControl.BorderWidth);
end;

function TPanelX.Get_Caption: WideString;
begin
  Result := WideString(FDelphiControl.Caption);
end;

function TPanelX.Get_Color: Integer;
begin
  Result := Integer(FDelphiControl.Color);
end;

function TPanelX.Get_Ctl3D: WordBool;
begin
  Result := FDelphiControl.Ctl3D;
end;

function TPanelX.Get_Cursor: Smallint;
begin
  Result := Smallint(FDelphiControl.Cursor);
end;

function TPanelX.Get_DragCursor: Smallint;
begin
  Result := Smallint(FDelphiControl.DragCursor);
end;

function TPanelX.Get_DragMode: TxDragMode;
begin
  Result := Ord(FDelphiControl.DragMode);
end;

function TPanelX.Get_Enabled: WordBool;
begin
  Result := FDelphiControl.Enabled;
end;

function TPanelX.Get_FullRepaint: WordBool;
begin
  Result := FDelphiControl.FullRepaint;
end;

function TPanelX.Get_Locked: WordBool;
begin
  Result := FDelphiControl.Locked;
end;

function TPanelX.Get_ParentColor: WordBool;
begin
  Result := FDelphiControl.ParentColor;
end;

function TPanelX.Get_ParentCtl3D: WordBool;
begin
  Result := FDelphiControl.ParentCtl3D;
end;

function TPanelX.Get_Visible: WordBool;
begin
  Result := FDelphiControl.Visible;
end;

procedure TPanelX.AboutBox;
begin
  ShowPanelXAbout;
end;

procedure TPanelX.Set_Alignment(Value: TxAlignment);
begin
  FDelphiControl.Alignment := TAlignment(Value);
end;

procedure TPanelX.Set_BevelInner(Value: TxPanelBevel);
begin
  FDelphiControl.BevelInner := TPanelBevel(Value);
end;

procedure TPanelX.Set_BevelOuter(Value: TxPanelBevel);
begin
  FDelphiControl.BevelOuter := TPanelBevel(Value);
end;

procedure TPanelX.Set_BevelWidth(Value: Integer);
begin
  FDelphiControl.BevelWidth := TBevelWidth(Value);
end;

procedure TPanelX.Set_BorderStyle(Value: TxBorderStyle);
begin
  FDelphiControl.BorderStyle := TBorderStyle(Value);
end;

procedure TPanelX.Set_BorderWidth(Value: Integer);
begin
  FDelphiControl.BorderWidth := TBorderWidth(Value);
end;

procedure TPanelX.Set_Caption(const Value: WideString);
begin
  FDelphiControl.Caption := TCaption(Value);
end;

procedure TPanelX.Set_Color(Value: Integer);
begin
  FDelphiControl.Color := TColor(Value);
end;

procedure TPanelX.Set_Ctl3D(Value: WordBool);
begin
  FDelphiControl.Ctl3D := Value;
end;

procedure TPanelX.Set_Cursor(Value: Smallint);
begin
  FDelphiControl.Cursor := TCursor(Value);
end;

procedure TPanelX.Set_DragCursor(Value: Smallint);
begin
  FDelphiControl.DragCursor := TCursor(Value);
end;

procedure TPanelX.Set_DragMode(Value: TxDragMode);
begin
  FDelphiControl.DragMode := TDragMode(Value);
end;

procedure TPanelX.Set_Enabled(Value: WordBool);
begin
  FDelphiControl.Enabled := Value;
end;

procedure TPanelX.Set_FullRepaint(Value: WordBool);
begin
  FDelphiControl.FullRepaint := Value;
end;

procedure TPanelX.Set_Locked(Value: WordBool);
begin
  FDelphiControl.Locked := Value;
end;

procedure TPanelX.Set_ParentColor(Value: WordBool);
begin
  FDelphiControl.ParentColor := Value;
end;

procedure TPanelX.Set_ParentCtl3D(Value: WordBool);
begin
  FDelphiControl.ParentCtl3D := Value;
end;

procedure TPanelX.Set_Visible(Value: WordBool);
begin
  FDelphiControl.Visible := Value;
end;

procedure TPanelX.ClickEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnClick;
end;

procedure TPanelX.DblClickEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnDblClick;
end;

procedure TPanelX.ResizeEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnResize;
end;

function TPanelX.Get_TabOrder: Integer;
begin
   result:=0;
end;

procedure TPanelX.Set_TabOrder(Value: Integer);
begin

end;

initialization
  TActiveXControlFactory.Create(
    ComServer,
    TPanelX,
    TPanel,
    Class_PanelX,
    1,
    '{2C07D488-560C-485E-B5AA-3ECEF23734AF}',
    OLEMISC_SIMPLEFRAME or OLEMISC_ACTSLIKELABEL);
end.
