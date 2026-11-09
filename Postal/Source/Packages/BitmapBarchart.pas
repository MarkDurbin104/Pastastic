unit BitmapBarchart;

interface

uses
  stdctrls,
  PackStrListU, Math,
  ExtCtrls,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type

  TSafeBits = class(TBits)
  private
      FOnChange  : TNotifyEvent;
      FRunLengthEncode : TPackStringList;
      function GetBit(Index:Integer):Boolean;
      procedure SetBit(Index:Integer;Value:Boolean);
      procedure SetRunLengthEncode(NewValue : String);
      function GetRunLengthEncode : string;
      procedure RecalcRLE;

  public
    constructor Create;
    destructor Destroy; override;
    property Bits[Index:Integer]:Boolean read GetBit write SetBit; default;
    property RunLengthEncode : String read GetRunLengthEncode write SetRunLengthEncode;
    property OnChange : TNotifyEvent read FOnChange write FOnChange;
  end;

  TBitMapBar = class(TGraphicControl)
  private
    { Private declarations }
    FBits     : TSafeBits;
    FMaxBits  : Integer;
    FForeColor: TColor;
    FBackColor: TColor;
    FGrid     : Integer;

  protected
    { Protected declarations }
    procedure BitsChange(Sender : TObject);
    procedure Paint; override;
    procedure PaintBackground(AnImage: TBitmap);
    procedure SetForeColor(Value: TColor);
    procedure SetBackColor(Value: TColor);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property BackColor  : TColor    read FBackColor   write SetBackColor default clWhite;
    property Bits       : TSafeBits read FBits        write FBits;
    property Caption;
    property ForeColor  : TColor    read FForeColor   write SetForeColor default clBlack;
    property Grid       : Integer   read FGrid        write FGrid;
    property MaxBits    : Integer   read FMaxBits     write FMaxBits;
  end;

  TBitMapBarChart = class(TPanel)
  private
    FGrid     : Integer;
    FMaxBits   : Integer;
    procedure SetMaxBits(Value  : Integer);
  protected
    function GetBar(Index : variant) : TBitMapBar;
    procedure SetGrid(NewValue : Integer);
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  public
    Bars      : TListBox;
    BarPanel  : TPanel;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Bar[Index : Variant] : TBitMapBar read GetBar;
  published
    property Grid       : Integer   read FGrid      write SetGrid;
    property MaxBits    : Integer   read FMaxBits write SetMaxBits;
    function CreateBar(Name : String) : TBitmapBar;
  end;


procedure Register;

implementation

constructor TSafeBits.Create;
begin
  Inherited Create;
  FRunLengthEncode := TPackStringList.Create;
end;

destructor TSafeBits.Destroy;
begin
  FRunLengthEncode.Free;
  Inherited Destroy;
end;

function TSafeBits.GetBit(Index:Integer):Boolean;
begin
   if (Index >= 0) and (Index < Size) then
      Result:=inherited Bits[Index]
   else
      Result:=False;
end;

procedure TSafeBits.SetBit(Index:Integer;Value:Boolean);
begin
   if (Index >= 0) then
      inherited Bits[Index]:=Value;
end;

procedure TSafeBits.RecalcRLE;
var
  BitIndex          : Integer;
  EndOfPreviousRun  : Integer;
  BitSet            : Boolean;
begin
  //RLE starts with no of zeroes
  FRunLengthEncode.Clear;
  EndOfPreviousRun  := 0;
  For BitIndex := 0 to Size-1 do
  begin
    //determine whether looking for set/unset bits
    BitSet := (FRunLengthEncode.Count and 1) = 1;

    If Bits[BitIndex] <> BitSet then
      FRunLengthEncode.Add(IntToStr(BitIndex-EndOfPreviousRun));
    EndOfPreviousRun := BitIndex;
  end;
end;

function TSafeBits.GetRunLengthEncode : string;
begin
  RecalcRLE;
  Result := FRunLengthEncode.CommaText;
end;

procedure TSafeBits.SetRunLengthEncode(NewValue : String);
var
  BitIndex    : Integer;
  RunIndex    : Integer;
  RunLength   : Integer;
  RunPosition : Integer;
  BitSet      : Boolean;
begin
  FRunLengthEncode.CommaText := NewValue;
  RunPosition := 0; //start of bitmap
  //every run
  For RunIndex := 0 to FRunLengthEncode.Count -1 do
  begin
    RunLength := StrToInt(FRunLengthEncode[RunIndex]);  //extract length of this run
    BitSet  := (RunIndex and 1) = 1;  //determine run is true/false
    For BitIndex := RunPosition to (RunPosition + RunLength -1) do  //set bits
      Bits[BitIndex] := BitSet;
    Inc(RunPosition, RunLength);
  end;
end;

procedure TBitMapBar.BitsChange(Sender : TObject);
begin
  Repaint;
end;

constructor TBitMapBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMaxBits := 1;
  FBits := TSafeBits.Create;
  FBits.OnChange := BitsChange;
  ForeColor := clBlack;
  Height := 12;
end;

destructor TBitMapBar.Destroy;
begin
  FBits.Free;
  Inherited Destroy;
end;

procedure TBitMapBar.SetForeColor(Value: TColor);
begin
  if Value <> FForeColor then
  begin
    FForeColor := Value;
    Refresh;
  end;
end;

procedure TBitMapBar.SetBackColor(Value: TColor);
begin
  if Value <> FBackColor then
  begin
    FBackColor := Value;
    Refresh;
  end;
end;


procedure TBitMapBar.PaintBackground(AnImage: TBitmap);
var
  ARect: TRect;
begin
  with AnImage.Canvas do
  begin
    CopyMode := cmBlackness;
    ARect := Rect(0, 0, Width, Height);
    CopyRect(ARect, Animage.Canvas, ARect);
    CopyMode := cmSrcCopy;
  end;
end;



procedure TBitMapBar.Paint;
var
  BitIndex          : Integer;
  GridIndex         : Integer;
  RunStart, RunEnd  : Integer;
  TheImage          : TBitmap;
  Scale             : Double;
begin
  //determine scaling
  Scale := Width / FMaxBits;

  with Canvas do
  begin

    TheImage :=TBitmap.Create;
    try
      TheImage.Height := Height;
      TheImage.Width := Width;

      //draw grid
      If FGrid > 0 then
      begin
        TheImage.Canvas.Pen.Color := clSilver;
        TheImage.Canvas.Rectangle(0,0,TheImage.Width+1, TheImage.Height+1); 

        GridIndex := 0;
        While GridIndex <= MaxBits do
        begin
          TheImage.Canvas.MoveTo(Trunc(GridIndex * Scale), 0 );
          If (GridIndex mod (Grid * 10)) = 0 then TheImage.Canvas.Pen.Color := clBlack
          else TheImage.Canvas.Pen.Color := clSilver;
          TheImage.Canvas.LineTo(Trunc(GridIndex * Scale), Height );
          Inc(GridIndex,Grid);
        end
      end;

      //caption
//      TheImage.Canvas.Pen.Mode := pmMerge;
//      TheImage.Canvas.Font.Name := 'Arial';
//      TheImage.Canvas.Font.Height := Height;
//      TheImage.Canvas.TextOut(0,0, Caption);


      BitIndex := 0;
      While (BitIndex < FBits.Size -1) do
      begin
        //find first 1 bit
        While (BitIndex < FBits.Size -1) and (not FBits[BitIndex]) do
          Inc(BitIndex);
        RunStart := Trunc(BitIndex * Scale);

        //find next zero bit
        While (BitIndex < FBits.Size -1) and FBits[BitIndex]do
          Inc(BitIndex);
        RunEnd := Trunc(BitIndex * Scale);
        If RunEnd < RunStart then RunEnd := RunStart; //last bit set


        TheImage.Canvas.Pen.Color := ForeColor;
        TheImage.Canvas.Pen.Width := 1;
        TheImage.Canvas.Brush.Color := ForeColor;
        TheImage.Canvas.FillRect(Rect(RunStart,2,RunEnd, Height-1));
      end;
      Canvas.CopyMode := cmSrcCopy;
      Canvas.Draw(0, 0, TheImage);
    finally
      TheImage.Destroy;
    end;
  end;
end;

procedure TBitMapBarChart.SetMaxBits(Value  : Integer);
var
  BarIndex : Integer;
begin
  FMaxBits := Value;
  For BarIndex:=0 to Bars.Items.Count -1 do
  begin
    try
      With GetBar(BarIndex) do
      begin
        MaxBits := Value;
        Repaint;
      end;
    except
    end;
  end;
end;

function TBitMapBarChart.GetBar(Index : Variant) : TBitMapBar;
var
  IntIndex : Integer;
begin
  Result := nil;
  IntIndex := -1;
  If VarType(Index) in [varSmallInt, varInteger] then
    IntIndex := Index
  else If VarType(Index) = varString then
    IntIndex := Bars.Items.IndexOf(Index);
  If (IntIndex >= 0) and (Bars.Items.Objects[IntIndex] <> nil) then
    Result := Bars.Items.Objects[IntIndex] as TBitMapBar;
end;

constructor TBitMapBarChart.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  self.Height := 100;

  BarPanel := TPanel.Create(self);
  BarPanel.Parent := self;
  BarPanel.Name := 'BarPanel';
  BarPanel.Caption := '';
  BarPanel.BorderStyle := bsNone;
  BarPanel.BevelOuter := bvNone;
  BarPanel.BevelInner := bvNone;
  BarPanel.Align := alClient;


  Bars := TListBox.Create(self);
  Bars.Parent := self;
  Bars.Style := lbOwnerDrawFixed;
  Bars.ItemHeight := 12;
  Bars.Font.Name := 'Arial';
  Bars.Font.Height  := 12;
  Bars.Align := alLeft;
  Bars.BorderStyle := bsNone;
  Bars.Width := 100;

  With TSplitter.Create(self) do
  begin
    Name := 'Splitter';
    Parent  := Self;
    Align   := alLeft;
    Left    := Bars.Width +10;
  end;
  Caption := '';
end;

destructor TBitMapBarChart.Destroy;
begin
  While Bars.Items.Count > 0 do
  begin
    If Bars.Items.Objects[Bars.Items.Count-1] <> nil then
      Bars.Items.Objects[Bars.Items.Count-1].Free;
    Bars.Items.Delete(Bars.Items.Count-1);
  end;
  Inherited Destroy;
end;

function TBitMapBarChart.CreateBar(Name : String) : TBitmapBar;
var
  BarIndex : Integer;
begin
  Result := Bars.Items.Objects[Bars.Items.AddObject(Name, TBitMapBar.Create(self))]as TBitMapbar;
  Result.Caption  := Name;
  Result.Align    := alTop;
  Result.Parent   := BarPanel;
  Result.Grid     := self.Grid;

  //ensure bar displays at bottom
  For BarIndex := 0 to Bars.Items.Count-1 do
    (Bars.Items.Objects[BarIndex] as TBitmapBar).Top := 1000;;

end;

procedure TBitMapBarChart.SetGrid(NewValue : Integer);
var
  BarIndex : Integer;
begin
  FGrid := NewValue;
  For BarIndex:=0 to Bars.Items.Count -1 do
  begin
    try
      With GetBar(BarIndex) do
      begin
        Grid := NewValue;
//        Invalidate;
      end;
    except
    end;
  end;
end;

procedure TBitMapBarChart.WMSize(var Message: TWMSize);
begin
  Inherited;
end;

procedure Register;
begin
  RegisterComponents('Samples', [TBitMapBar, TBitMapBarChart]);
end;



end.
