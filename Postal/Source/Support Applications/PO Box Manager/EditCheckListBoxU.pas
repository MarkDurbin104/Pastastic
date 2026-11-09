unit EditCheckListBoxU;

interface

uses
  Math,
  CheckLst,
  StdCtrls,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TEditCheckListBox = class(TPanel)
  private
    { Private declarations }
    FExpandHeight : Integer;
    Edit          : TEdit;
    CheckListBox  : TCheckListBox;
    procedure EditChange(Sender : TObject);
    procedure EditEnter(Sender : TObject);
    procedure UpdateCheckListBox;
    procedure CheckListBoxClickCheck(Sender : TObject);
    procedure CheckListBoxExit(Sender : TObject);
    function GetItems : TStrings;
    procedure SetItems(Value : TStrings);
    function GetValue : Integer;
    procedure SetValue(Value : Integer);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
  published
    { Published declarations }
    property ExpandHeight : Integer read FExpandHeight write FExpandHeight;
    property Items : TStrings read GetItems write SetItems;
    property Value : Integer read GetValue write SetValue;
  end;

procedure Register;

implementation

constructor TEditCheckListBox.Create(AOwner : TComponent);
begin
  Inherited Create(AOWner);
  Width := 120;
  Height := 21;
  ExpandHeight := 120;

  Edit := TEdit.Create(self);
  With Edit do
  begin
    Parent    := self;
    Align     := alClient;
    OnChange  := EditChange;
    OnEnter   := EditEnter;
  end;

  CheckListBox := TCheckListBox.Create(self);
  With CheckListBox do
  begin
    Parent        := self;
    Visible       := False;
    Align         := alClient;
    OnClickCheck  := CheckListBoxClickCheck;
    OnExit        := CheckListBoxExit;
  end;
end;

procedure TEditCheckListBox.EditChange(Sender : TObject);
begin
  UpdateCheckListBox;
end;

procedure TEditCheckListBox.EditEnter(Sender : TObject);
begin
  Height := Height + ExpandHeight;
  UpdateCheckListBox;
  CheckListBox.Visible          := True;
  BringToFront;
  CheckListBox.SetFocus;
end;

function TEditCheckListBox.GetItems : TStrings;
begin
  Result := CheckListBox.Items;
end;

procedure TEditCheckListBox.SetItems(Value : TStrings);
begin
  If CheckListBox.Items <> Value then
    CheckListBox.Items.Assign(Value);
end;

procedure TEditCheckListBox.CheckListBoxClickCheck(Sender : TObject);
var
  Value : Integer;
  BitValue : Integer;
  BitIndex : Integer;
begin
  Value :=0;
  For BitIndex := 0 to CheckListBox.Items.Count -1 do
  begin
    If CheckListBox.Checked[BitIndex] then
    begin
      BitValue := Trunc(IntPower(2,BitIndex));
      Inc(Value, BitValue);
    end;
  end;
  Edit.Text := IntToStr(Value);
end;

procedure TEditCheckListBox.CheckListBoxExit(Sender : TObject);
begin
  CheckListBox.Visible := False;
  Height := Height - ExpandHeight;
end;

procedure TEditCheckListBox.UpdateCheckListBox;
var
  Value : Integer;
  BitValue : Integer;
  BitIndex : Integer;
begin
  Value := StrToIntDef(Edit.Text,0);
  For BitIndex := 0 to CheckListBox.Items.Count -1 do
  begin
    BitValue := Trunc(IntPower(2,BitIndex));
    If (Value and BitValue) = BitValue then
      CheckListBox.Checked[BitIndex] := True
    else
      CheckListBox.Checked[BitIndex] := False;
  end;
end;

function TEditCheckListBox.GetValue : Integer;
begin
  Result := StrToIntDef(Edit.Text,0);
end;


procedure TEditCheckListBox.SetValue(Value : Integer);
begin
  If Value <> StrToIntDef(Edit.Text,0) then
  begin
    Edit.Text := IntToStr(Value);
  end;
end;


procedure Register;
begin
  RegisterComponents('P.S.L.', [TEditCheckListBox]);
end;

end.
