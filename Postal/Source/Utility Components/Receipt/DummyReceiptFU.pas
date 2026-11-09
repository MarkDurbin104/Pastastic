unit DummyReceiptFU;

interface

uses
  Registry,registryEx,
  SavePosFormEx,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ToolWin;

type
  TReceiptForm = class(TSavePosForm)
    Memo: TMemo;
    ToolBar: TToolBar;
    ClearToolButton: TToolButton;
    ToolbarImageList: TImageList;
    FontToolButton: TToolButton;
    FontDialog: TFontDialog;
    HeightToolButton: TToolButton;
    procedure FontToolButtonClick(Sender: TObject);
    procedure ClearToolButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure HeightToolButtonClick(Sender: TObject);
  private
    { Private declarations }
    RealRect : TRect;
  public
    { Public declarations }
  end;

var
  ReceiptForm: TReceiptForm;

type
  TFontRec = record
    LogFont : TLogFont;
  end;

implementation

{$R *.DFM}

procedure TReceiptForm.FontToolButtonClick(Sender: TObject);
var
  FontRec  : TFontRec;
begin
  FontDialog.Font.Assign(Memo.Font);
  If FontDialog.Execute then
    Memo.Font.Assign(FontDialog.Font);

  //write font to registry
  if Windows.GetObject(Memo.Font.Handle, SizeOf(FontRec.LogFont), @FontRec.LOgFont) > 0 then
  begin
    With TRegistry.Create do
    begin
      try
        If OpenKey('\Software\PSL\DummyReceipt',True) then
          WriteBinaryData('Font',FontRec,SizeOf(FontRec));
      finally
        CloseKey;
        Free;
      end;
    end;
  end;
end;

procedure TReceiptForm.ClearToolButtonClick(Sender: TObject);
begin
  Memo.Clear;
end;

procedure TReceiptForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := False;
end;

procedure TReceiptForm.FormShow(Sender: TObject);
var
  FontRec : TFontRec;
begin
  With TRegistry.Create do
  begin
    try
      If OpenKey('\Software\PSL\DummyReceipt',False) then
        If ReadBinaryData('Font',FontRec,SizeOf(FontRec)) = SizeOf(FontRec) then
        begin
          Memo.Font.Handle := CreateFontIndirect(FontRec.LogFont);
        end;
    finally
      CloseKey;
      Free;
    end;
  end;
end;


procedure TReceiptForm.FormResize(Sender: TObject);
begin
  If not HeightToolButton.Down then
    RealRect := BoundsRect;
end;

procedure TReceiptForm.HeightToolButtonClick(Sender: TObject);
begin
  If HeightToolButton.Down then
  begin
    RealRect  := BoundsRect;
    Height    := Screen.Height;
    Top       := 0;
  end
  else
  begin
    BoundsRect := RealRect;
  end;
end;

end.
