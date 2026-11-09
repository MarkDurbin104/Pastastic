(*
  InPlace editor for OutBar
  Copyright (C) 1999 by Sylvain Frere
  e-mail: fbrother@club-internet.fr
*)
unit Inpledt;
interface
uses SysUtils, Messages, Windows, Classes, Graphics, Menus, Controls, Forms,
  StdCtrls, Mask;

Type
  TInplaceEdit = class(TCustomMaskEdit)
  private
    FClickTime : Longint;
    FMResult : TModalResult;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMPaste(var Message); message WM_PASTE;
    procedure WMCut(var Message); message WM_CUT;
    procedure WMClear(var Message); message WM_CLEAR;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DblClick; override;
    function EditCanModify: Boolean; override;
    procedure KeyPress(var Key: Char); override;
    procedure BoundsChanged; virtual;
    procedure UpdateContents; virtual;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent; iRC:TRect; const iText:String);
    procedure Deselect;
    procedure SetFocus;
    property ModalResult:TModalResult read FMResult;
  end;

implementation
type
  TSelection = record
    StartPos, EndPos: Integer;
  end;

constructor TInplaceEdit.Create(AOwner: TComponent; iRC:TRect; const iText:String);
begin
  inherited Create(AOwner);
  if aOwner is TWincontrol then Parent := TWinControl(aOwner);
  ParentCtl3D := False;
  Ctl3D := False;
  TabStop := False;
  BorderStyle := bsNone;
  FMResult:=mrNone;
  with iRC do
    SetBounds(Left,Top,Right-Left,Bottom-Top);
  Text := iText;
end;

procedure TInplaceEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or ES_MULTILINE or ES_CENTER;
end;

procedure TInplaceEdit.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  //if goTabs in Grid.Options then
    //Message.Result := Message.Result or DLGC_WANTTAB;
end;

procedure TInplaceEdit.WMPaste(var Message);
begin
  if not EditCanModify then Exit;
  inherited
end;

procedure TInplaceEdit.WMClear(var Message);
begin
  if not EditCanModify then Exit;
  inherited;
end;

procedure TInplaceEdit.WMCut(var Message);
begin
  if not EditCanModify then Exit;
  inherited;
end;

procedure TInplaceEdit.DblClick;
begin
end;

function TInplaceEdit.EditCanModify: Boolean;
begin
  Result := TRUE;
end;

procedure TInplaceEdit.KeyPress(var Key: Char);
var Selection: TSelection;
begin
  case Key of
    #9, #27: begin FMResult := mrCancel; Key := #0; end;
    #13:
      begin
        SendMessage(Handle, EM_GETSEL, Longint(@Selection.StartPos), Longint(@Selection.EndPos));
        if (Selection.StartPos = 0) and (Selection.EndPos = GetTextLen)
           then Deselect
           else SelectAll;
        FMResult := mrOK;
        Key := #0;
      end;
  end;

  if Key <> #0 then inherited KeyPress(Key);
end;

procedure TInplaceEdit.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_SETFOCUS:
      begin
        Dispatch(Message);
        Exit;
      end;
    WM_LBUTTONDOWN:
      begin
        if GetMessageTime - FClickTime < GetDoubleClickTime then
          Message.Msg := WM_LBUTTONDBLCLK;
        FClickTime := 0;
      end;
  end;
  inherited WndProc(Message);
end;

procedure TInplaceEdit.Deselect;
begin
  SendMessage(Handle, EM_SETSEL, $7FFFFFFF, Longint($FFFFFFFF));
end;

procedure TInplaceEdit.BoundsChanged;
var R: TRect;
begin
  R := Rect(2, 2, Width - 2, Height);
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@R));
  SendMessage(Handle, EM_SCROLLCARET, 0, 0);
end;

procedure TInplaceEdit.SetFocus;
begin
  if IsWindowVisible(Handle) then
    Windows.SetFocus(Handle);
end;

procedure TInplaceEdit.UpdateContents;
begin
end;

end.
