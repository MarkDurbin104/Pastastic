unit StretchU;

interface

uses Classes,Math,Windows,Graphics;

procedure PlacePictAt(Canvas:TCanvas;Dest:TRect;BitMap:TBitMap;BGColor:TColor);
procedure PlaceGlyphAt(Canvas:TCanvas;Dest:TRect;BitMap:TBitMap);
procedure AdjustRatio(var Rect:TRect;IW,IH:Integer;DontEnlarge:Boolean);
procedure Stretch(Src, Dst: TBitmap);

implementation
type
  TContributor = record
    pixel: integer;		// Source pixel
    weight: single;		// Pixel weight
  end;

  TContributorList = array[0..0] of TContributor;
  PContributorList = ^TContributorList;

  // List of source pixels contributing to a destination pixel
  TCList = record
    n		: integer;
    p		: PContributorList;
  end;

  TCListList = array[0..0] of TCList;
  PCListList = ^TCListList;

  TRGB = packed record
    r, g, b	: single;
  end;

  // Physical bitmap pixel
  TColorRGB = packed record
    r, g, b	: BYTE;
  end;
  PColorRGB = ^TColorRGB;

  // Physical bitmap scanline (row)
  TRGBList = packed array[0..0] of TColorRGB;
  PRGBList = ^TRGBList;

function Filter(Value: Single): Single;
begin
  if (Value < 0.0) then
    Value := -Value;
  if (Value < 0.5) then
    Result := 0.75 - Sqr(Value)
  else if (Value < 1.5) then
  begin
    Value := Value - 1.5;
    Result := 0.5 * Sqr(Value);
  end else
    Result := 0.0;
end;
procedure Stretch(Src, Dst: TBitmap);
var
  xscale, yscale	: single;		// Zoom scale factors
  i, j, k		: integer;		// Loop variables
  center		: single;		// Filter calculation variables
  width, fscale, weight	: single;		// Filter calculation variables
  left, right		: integer;		// Filter calculation variables
  n			: integer;		// Pixel number
  Work			: TBitmap;
  contrib		: PCListList;
  rgb			: TRGB;
  color			: TColorRGB;
  SourceLine		,
  DestLine		: PRGBList;
  SourcePixel		,
  DestPixel		: PColorRGB;
  Delta			,
  DestDelta		: integer;
  SrcWidth		,
  SrcHeight		,
  DstWidth		,
  DstHeight		: integer;
  SR:TRect;
  DR:TRect;

  function Color2RGB(Color: TColor): TColorRGB;
  begin
    Result.r := Color AND $000000FF;
    Result.g := (Color AND $0000FF00) SHR 8;
    Result.b := (Color AND $00FF0000) SHR 16;
  end;

  function RGB2Color(Color: TColorRGB): TColor;
  begin
    Result := Color.r OR (Color.g SHL 8) OR (Color.b SHL 16);
  end;

begin
  if Src = nil then Exit;
  if Dst = nil then Exit;
  DstWidth := Dst.Width;
  DstHeight := Dst.Height;
  SrcWidth := Src.Width;
  SrcHeight := Src.Height;
  try
     if (SrcWidth < 3) or (SrcHeight < 3) or
        (DstWidth < 3) or (DstHeight < 3) then
     begin
        SR:=Bounds(0,0,SrcWidth,SrcHeight);
        DR:=Bounds(0,0,DstWidth,DstHeight);
        Dst.Canvas.CopyRect(DR,Src.Canvas,SR);
        Exit;
     end;
     if (SrcWidth = DstWidth) and (SrcHeight = DstHeight) then
     begin
        SR:=Bounds(0,0,SrcWidth,SrcHeight);
        Dst.Canvas.CopyRect(SR,Src.Canvas,SR);
        Exit;
     end;
  except
     Exit;
  end;
  Work := TBitmap.Create;
  try
    Work.Height := SrcHeight;
    Work.Width := DstWidth;
    if (SrcWidth = 1) then
      xscale:= DstWidth / SrcWidth
    else
      xscale:= (DstWidth - 1) / (SrcWidth - 1);
    if (SrcHeight = 1) then
      yscale:= DstHeight / SrcHeight
    else
      yscale:= (DstHeight - 1) / (SrcHeight - 1);
    Src.PixelFormat := pf24bit;
    Dst.PixelFormat := Src.PixelFormat;
    Work.PixelFormat := Src.PixelFormat;

    GetMem(contrib, DstWidth* sizeof(TCList));
    if (xscale < 1.0) then
    begin
      width := 1.5 / xscale;
      fscale := 1.0 / xscale;
      for i := 0 to DstWidth-1 do
      begin
        contrib^[i].n := 0;
        GetMem(contrib^[i].p, trunc(width * 2.0 + 1) * sizeof(TContributor));
        center := i / xscale;
        left := floor(center - width);
        right := ceil(center + width);
        for j := left to right do
        begin
          weight := filter((center - j) / fscale) / fscale;
          if (weight = 0.0) then
            continue;
          if (j < 0) then
            n := -j
          else if (j >= SrcWidth) then
            n := SrcWidth - j + SrcWidth - 1
          else
            n := j;
          k := contrib^[i].n;
          contrib^[i].n := contrib^[i].n + 1;
          contrib^[i].p^[k].pixel := n;
          contrib^[i].p^[k].weight := weight;
        end;
      end;
    end else
    begin
      for i := 0 to DstWidth-1 do
      begin
        contrib^[i].n := 0;
        GetMem(contrib^[i].p, 4 * sizeof(TContributor));
        center := i / xscale;
        left := floor(center - 1.5);
        right := ceil(center + 1.5);
        for j := left to right do
        begin
          weight := filter(center - j);
          if (weight = 0.0) then
            continue;
          if (j < 0) then
            n := -j
          else if (j >= SrcWidth) then
            n := SrcWidth - j + SrcWidth - 1
          else
            n := j;
          k := contrib^[i].n;
          contrib^[i].n := contrib^[i].n + 1;
          contrib^[i].p^[k].pixel := n;
          contrib^[i].p^[k].weight := weight;
        end;
      end;
    end;

    for k := 0 to SrcHeight-1 do
    begin
      SourceLine := Src.ScanLine[k];
      DestPixel := Work.ScanLine[k];
      for i := 0 to DstWidth-1 do
      begin
        rgb.r := 0.0;
        rgb.g := 0.0;
        rgb.b := 0.0;
        for j := 0 to contrib^[i].n-1 do
        begin
          color := SourceLine^[contrib^[i].p^[j].pixel];
          weight := contrib^[i].p^[j].weight;
          if (weight = 0.0) then
            continue;
          rgb.r := rgb.r + color.r * weight;
          rgb.g := rgb.g + color.g * weight;
          rgb.b := rgb.b + color.b * weight;
        end;
        if (rgb.r > 255.0) then
          color.r := 255
        else if (rgb.r < 0.0) then
          color.r := 0
        else
          color.r := round(rgb.r);
        if (rgb.g > 255.0) then
          color.g := 255
        else if (rgb.g < 0.0) then
          color.g := 0
        else
          color.g := round(rgb.g);
        if (rgb.b > 255.0) then
          color.b := 255
        else if (rgb.b < 0.0) then
          color.b := 0
        else
          color.b := round(rgb.b);
        DestPixel^ := color;
        inc(DestPixel);
      end;
    end;

    for i := 0 to DstWidth-1 do
      FreeMem(contrib^[i].p);

    FreeMem(contrib);

    GetMem(contrib, DstHeight* sizeof(TCList));
    if (yscale < 1.0) then
    begin
      width := 1.5 / yscale;
      fscale := 1.0 / yscale;
      for i := 0 to DstHeight-1 do
      begin
        contrib^[i].n := 0;
        GetMem(contrib^[i].p, trunc(width * 2.0 + 1) * sizeof(TContributor));
        center := i / yscale;
        left := floor(center - width);
        right := ceil(center + width);
        for j := left to right do
        begin
          weight := filter((center - j) / fscale) / fscale;
          if (weight = 0.0) then
            continue;
          if (j < 0) then
            n := -j
          else if (j >= SrcHeight) then
            n := SrcHeight - j + SrcHeight - 1
          else
            n := j;
          k := contrib^[i].n;
          contrib^[i].n := contrib^[i].n + 1;
          contrib^[i].p^[k].pixel := n;
          contrib^[i].p^[k].weight := weight;
        end;
      end
    end else
    begin
      for i := 0 to DstHeight-1 do
      begin
        contrib^[i].n := 0;
        GetMem(contrib^[i].p, 4 * sizeof(TContributor));
        center := i / yscale;
        left := floor(center - 1.5);
        right := ceil(center + 1.5);
        for j := left to right do
        begin
          weight := filter(center - j);
          if (weight = 0.0) then
            continue;
          if (j < 0) then
            n := -j
          else if (j >= SrcHeight) then
            n := SrcHeight - j + SrcHeight - 1
          else
            n := j;
          k := contrib^[i].n;
          contrib^[i].n := contrib^[i].n + 1;
          contrib^[i].p^[k].pixel := n;
          contrib^[i].p^[k].weight := weight;
        end;
      end;
    end;

    SourceLine := Work.ScanLine[0];
    Delta := integer(Work.ScanLine[1]) - integer(SourceLine);
    DestLine := Dst.ScanLine[0];
    DestDelta := integer(Dst.ScanLine[1]) - integer(DestLine);
    for k := 0 to DstWidth-1 do
    begin
      DestPixel := pointer(DestLine);
      for i := 0 to DstHeight-1 do
      begin
        rgb.r := 0;
        rgb.g := 0;
        rgb.b := 0;
        for j := 0 to contrib^[i].n-1 do
        begin
          color := PColorRGB(integer(SourceLine)+contrib^[i].p^[j].pixel*Delta)^;
          weight := contrib^[i].p^[j].weight;
          if (weight = 0.0) then
            continue;
          rgb.r := rgb.r + color.r * weight;
          rgb.g := rgb.g + color.g * weight;
          rgb.b := rgb.b + color.b * weight;
        end;
        if (rgb.r > 255.0) then
          color.r := 255
        else if (rgb.r < 0.0) then
          color.r := 0
        else
          color.r := round(rgb.r);
        if (rgb.g > 255.0) then
          color.g := 255
        else if (rgb.g < 0.0) then
          color.g := 0
        else
          color.g := round(rgb.g);
        if (rgb.b > 255.0) then
          color.b := 255
        else if (rgb.b < 0.0) then
          color.b := 0
        else
          color.b := round(rgb.b);
        DestPixel^ := color;
        inc(integer(DestPixel), DestDelta);
      end;
      Inc(SourceLine, 1);
      Inc(DestLine, 1);
    end;

    for i := 0 to DstHeight-1 do
      FreeMem(contrib^[i].p);

    FreeMem(contrib);

  except
  end;
  Work.Free;
end;
procedure AdjustRatio(var Rect:TRect;IW,IH:Integer;DontEnlarge:Boolean);
var
 IRatio:Real;
 MRatio:Real;
 MW,MH:Integer;
begin
  MW:=Rect.Right-Rect.Left;
  MH:=Rect.Bottom-Rect.Top;

  if (IH = 0) or (MH = 0)  or (IW = 0)  or (MW = 0) then Exit;
  if DontEnlarge and (IH < MH) and (IW < MW) then
  begin
     Rect:=Bounds(Rect.Left,Rect.Top,IW,IH);
     OffsetRect(Rect,(MW-IW) div 2,(MH-IH) div 2);
     Exit;
  end;
  IRatio:=IW/IH;
  MRatio:=MW/MH;
  if IRatio > MRatio then
  begin
   Rect.Top  :=Rect.Top +((MH-Trunc(MW/IRatio)) div 2);
   Rect.Right :=Rect.Left+MW;
   Rect.Bottom:=Rect.Top +Trunc(MW/IRatio);
  end
  else
  begin
   Rect.Left :=Rect.Left+((MW-Trunc(MH*IRatio)) div 2);
   Rect.Right :=Rect.Left+Trunc(MH*IRatio);
   Rect.Bottom:=Rect.Top +MH;
  end;
end;
function CreateBitmapFromRect(Canvas:TCanvas;Source:TRect):TBitMap;
begin
   Result:=TBitmap.Create;
   with Source do 
   begin
      Result.Width :=Right-Left;
      Result.Height:=Bottom-Top;
   end;
   Result.PixelFormat:=pf24Bit;
   Result.Canvas.CopyRect(Bounds(0,0,Result.Width,Result.Height),Canvas,Source);
end;
   
procedure PlaceGlyphAt(Canvas:TCanvas;Dest:TRect;BitMap:TBitMap);
type
   TRGBList = packed array[0..0] of packed record B,G,R:Byte; end;
   PRGBList = ^TRGBList;
var
   I,J:Integer;
   LineI:PRGBList;
   LineO:PRGBList;
   FR,FG,FB:Byte;
   FromColor:TColor;
   Source:TRect;
   BG:TBitMap;
   CurrentBG:TBitMap;
begin
   BG:=TBitMap.Create;
   try
      CurrentBG:=CreateBitmapFromRect(Canvas,Dest); // current background
   except
      BG.Free;
      Exit;
   end;
   try
      with BitMap do Source:=Rect(0,0,Width,Height);
      BG.Width :=BitMap.Width;
      BG.Height:=BitMap.Height;
      BG.PixelFormat:=pf24Bit;

   //   Stretch(CurrentBG,BG);
      BG.Canvas.CopyRect(Source,CurrentBG.Canvas,Bounds(0,0,CurrentBG.Width,CurrentBG.Height));

      Bitmap.PixelFormat:=pf24Bit;
      FromColor:=Bitmap.Canvas.Pixels[0,0];
      FB:=(FromColor shr 16) and $FF;
      FG:=(FromColor shr  8) and $FF;
      FR:=(FromColor       ) and $FF;
      for I:=0 to Bitmap.Height-1 do
      begin
         LineI:=Bitmap.ScanLine[I];
         LineO:=BG.ScanLine[I];
         for J:=0 to Bitmap.Width-1 do
         begin
            if (LineI[J].R <> FR)
            or (LineI[J].G <> FG)
            or (LineI[J].B <> FB) then
            begin
               LineO[J].R:=LineI[J].R;
               LineO[J].G:=LineI[J].G;
               LineO[J].B:=LineI[J].B;
            end;
         end;
      end;

      Stretch(BG,CurrentBG);

      Canvas.CopyRect(Dest,CurrentBG.Canvas,Bounds(0,0,CurrentBG.Width,CurrentBG.Height));
   except
   end;
   CurrentBG.Free;
   BG.Free;
end;

procedure PlacePictAt(Canvas:TCanvas;Dest:TRect;BitMap:TBitMap;BGColor:TColor);
type
   TRGBList = packed array[0..0] of packed record B,G,R:Byte; end;
   PRGBList = ^TRGBList;
var
   I,J:Integer;
   LineI:PRGBList;
   LineO:PRGBList;
   FR,FG,FB:Byte;
   FromColor:TColor;
   Source:TRect;
   BG:TBitMap;
   NewBMP:TBitMap;
begin
   with BitMap do Source:=Rect(0,0,Width,Height);
   BG:=TBitMap.Create;
   BG.Width :=BitMap.Width;
   BG.Height:=BitMap.Height;
   BG.PixelFormat:=pf24Bit;
   BG.Canvas.Brush.Color:=BGColor;
   BG.Canvas.FillRect(Source);
   
   Bitmap.PixelFormat:=pf24Bit;
   FromColor:=Bitmap.Canvas.Pixels[0,0];
   FB:=(FromColor shr 16) and $FF;
   FG:=(FromColor shr  8) and $FF;
   FR:=(FromColor       ) and $FF;
   for I:=0 to Bitmap.Height-1 do
   begin
      LineI:=Bitmap.ScanLine[I];
      LineO:=BG.ScanLine[I];
      for J:=0 to Bitmap.Width-1 do
      begin
         if (LineI[J].R <> FR) 
         or (LineI[J].G <> FG) 
         or (LineI[J].B <> FB) then
         begin
            LineO[J].R:=LineI[J].R;
            LineO[J].G:=LineI[J].G;
            LineO[J].B:=LineI[J].B;
         end;
      end;
   end;
   
   NewBMP:=TBitmap.Create;
   NewBMP.Width :=Dest.Right-Dest.Left;
   NewBMP.Height:=Dest.Bottom-Dest.Top;
   NewBMP.PixelFormat:=pf24Bit;
   Stretch(BG,NewBMP); 
   BG.Free;
   
   Canvas.Brush.Style:=bsClear;
   Canvas.BrushCopy(Dest,NewBMP,Bounds(0,0,NewBMP.Width,NewBMP.Height),BGColor);
   Canvas.Brush.Style:=bsSolid;
   
   NewBMP.Free;
end;

end.
