unit CommaTextEditMemoU;

interface

uses
  StdCtrls, ExtCtrls,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TCommaTextEditMemo = class(TPanel)
  private
    { Private declarations }
    FExpandHeight : Integer;
    Edit : TEdit;
    Memo : TMemo;
    procedure EditChange(Sender : TObject);
    procedure EditEnter(Sender : TObject);
    procedure MemoChange(Sender : TObject);
    procedure MemoExit(Sender : TObject);
    function GetLines : TStrings;
    procedure SetLines(Value : TStrings);
    function GetScrollBars : TScrollStyle;
    procedure SetScrollBars(Value : TScrollStyle);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
  published
    { Published declarations }
    property ExpandHeight : Integer read FExpandHeight write FExpandHeight;
    property Lines: TStrings read GetLines write SetLines;
    property ScrollBars: TScrollStyle read GetScrollBars write SetScrollBars default ssNone;
  end;

procedure Register;

implementation

constructor TCommaTextEditMemo.Create(AOwner : TComponent);
begin
  Inherited Create(AOWner);
  Width := 120;
  Height := 21;
  ExpandHeight := 120;
  Edit := TEdit.Create(self);
  With Edit do
  begin
    Parent := self;
    Align := alClient;
    OnChange := EditChange;
    OnEnter := EditEnter;
  end;

  Memo := TMemo.Create(self);
  With Memo do
  begin
    Parent    := self;
    Visible   := False;
    Align     := alClient;
    OnChange  := MemoChange;
    OnExit    := MemoExit;
  end;
end;

procedure TCommaTextEditMemo.EditChange(Sender : TObject);
begin
  If Memo.Lines.CommaText <> Edit.Text then
    Memo.Lines.CommaText  := Edit.Text;
end;

procedure TCommaTextEditMemo.EditEnter(Sender : TObject);
begin
  Height := Height + ExpandHeight;
  Memo.Lines.CommaText  := Edit.Text;
  Memo.Visible          := True;
  BringToFront;
  Memo.SetFocus;
end;

function TCommaTextEditMemo.GetLines : TStrings;
begin
  Result := Memo.Lines;
end;

procedure TCommaTextEditMemo.SetLines(Value : TStrings);
begin
  If Memo.Lines <> Value then
    Memo.Lines.Assign(Value);
end;

procedure TCommaTextEditMemo.MemoChange(Sender : TObject);
begin
  If Edit.Text <> Memo.Lines.CommaText then
    Edit.Text := Memo.Lines.CommaText;
end;

procedure TCommaTextEditMemo.MemoExit(Sender : TObject);
begin
  Memo.Visible := False;
  Height := Height - ExpandHeight;
end;

function TCommaTextEditMemo.GetScrollBars : TScrollStyle;
begin
  Result := Memo.ScrollBars;
end;

procedure TCommaTextEditMemo.SetScrollBars(Value : TScrollStyle);
begin
  If Memo.ScrollBars <> Value then
    Memo.ScrollBars := Value;
end;

procedure Register;
begin
  RegisterComponents('P.S.L.', [TCommaTextEditMemo]);
end;

end.
