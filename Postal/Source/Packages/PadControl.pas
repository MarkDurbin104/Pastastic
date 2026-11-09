unit PadControl;

interface

uses
   Windows,Messages,Controls,Classes,Graphics,ExtCtrls,SysUtils,PackStrListU;
   
type
   TDrawItem    = procedure (Data:String;Canvas:TCanvas;ItemRect:TRect;Row,Col:Integer) of Object;
   TMeasureItem = function  (Index:Integer):Integer of Object;
   TPadType    = (ptPick,ptTxnLog,ptHelp,ptForm,ptInfo,ptError);
   
   TPadControl = class(TGraphicControl)
   private
     FIsTxnLog:Boolean;
     FListRect:TRect;
     FItemIndex:Integer;
     FTopIndex:Integer;
     FBackGround:TPicture;
     FItems:TStrings;
     FRowOffsets:TStrings;
     FColOffsets:TStrings;
     FRowStates:TStrings;
     FDisableColor  :TColor;
     FHighLightColor:TColor;
     FLowLightColor :TColor;
     FOnDrawItem:TDrawItem;
     FOnMeasureItem:TMeasureItem;
     FStopOnDisabled:Boolean;
     FKeepInView:Boolean;
     FMaxRowCount:Integer;
     procedure SetBoolean(Index:Integer;Value:Boolean);
     procedure SetItems(Index:Integer;Value:TStrings);
     function  GetItems(Index:Integer):TStrings;
     procedure SetBackGround(Value:TPicture);
     procedure SetInteger(Index:Integer;Value:Integer);
     function  GetInteger(Index:Integer):Integer;
     procedure SetColor(Index:Integer;Value:TColor);
   protected
     procedure UpdateView(Sender:TObject);
     procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_EraseBkgnd;
     procedure CalcVisibleRows;   
     procedure Paint; override;
   public
     constructor Create(AOwner: TComponent); override;
     destructor Destroy; override;
   published  
     property Align;
     property Font;
     property ParentFont;
     property Color;
     property ParentColor;
     property BackGround:TPicture         read FBackGround write SetBackGround;
     
     property Items     :TStrings index 0 read GetItems    write SetItems;
     property RowOffsets:TStrings index 1 read GetItems    write SetItems;
     property ColOffsets:TStrings index 2 read GetItems    write SetItems;
     property RowStates :TStrings index 3 read GetItems    write SetItems;
     
     property ListLeft  :Integer  index 0 read GetInteger  write SetInteger;
     property ListTop   :Integer  index 1 read GetInteger  write SetInteger;
     property ListRight :Integer  index 2 read GetInteger  write SetInteger;
     property ListBottom:Integer  index 3 read GetInteger  write SetInteger;
     property ItemIndex :Integer  index 4 read GetInteger  write SetInteger;
     property TopIndex  :Integer  index 5 read GetInteger  write SetInteger;
     
     property DisableColor  :TColor index 0 read FDisableColor   write SetColor;
     property HighLightColor:TColor index 1 read FHighLightColor write SetColor;
     property LowLightColor :TColor index 2 read FLowLightColor  write SetColor;
     
     property StopOnDisabled:Boolean index 0 read FStopOnDisabled write SetBoolean;
     property KeepInView    :Boolean index 1 read FKeepInView     write SetBoolean;
     property IsTxnLog      :Boolean index 2 read FIsTxnLog       write SetBoolean;
              
     property OnDrawItem   :TDrawItem    read FOnDrawItem    write FOnDrawItem;
     property OnMeasureItem:TMeasureItem read FOnMeasureItem write FOnMeasureItem;
   end;                       
   
   TPadController = class(TPanel)
   private
     FCurrentPad:TPadControl;
     procedure SetPadControl(Pad:TPadControl);
   public
     property CurrentPad:TPadControl read FCurrentPad write SetPadControl;
   end;        

procedure Register;
 
implementation
{TPadController}
procedure TPadController.SetPadControl(Pad:TPadControl);
var
   I:Integer;
begin
   if Pad <> nil then 
   begin
      FCurrentPad:=Pad;
      if Pad.BackGround <> nil then
      begin
         if Pad.Width <> Pad.BackGround.Width then
            Pad.Width :=Pad.FBackGround.Width;
         if Pad.Height <> (Pad.FBackGround.Height-1) then
            Pad.Height:=(Pad.FBackGround.Height-1);
      end;
      Pad.Visible:=True;
      Pad.BringToFront;
      Pad.Left:=0;
      Pad.Top:=Parent.ClientHeight-Pad.Height;
   end;
   for I:=0 to Parent.ControlCount-1 do
   begin
      if (Parent.Controls[I] is TPadControl) and (Parent.Controls[I] <> Pad) then 
         Parent.Controls[I].Visible:=False;
   end;
end;
{TPadControl}
procedure TPadControl.UpdateView(Sender:TObject);
var
   ChangeRect:TRect;
begin
   ChangeRect:=FListRect;
   OffsetRect(ChangeRect,Left,Top);
   InvalidateRect(Parent.Handle,@ChangeRect,False);
end;  
procedure TPadControl.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
//  FillRect(Message.DC, ClientRect, FBrush.Handle);
  Message.Result := 1;
end;
constructor TPadControl.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   ParentColor:=False;
   Color:=clWindow;
   FDisableColor:=clBtnFace;
   FHighLightColor:=clRed;
   FLowLightColor:=clBlue;
   FStopOnDisabled:=False;
   FKeepInView:=True;
   FItemIndex:=-1;
   FTopIndex:=0;
   Width:=400;
   Height:=400;
   FBackGround:=TPicture.Create;
   FItems:=TPackStringList.Create;
   FRowOffsets:=TPackStringList.Create;
   FColOffsets:=TPackStringList.Create;
   FRowStates :=TPackStringList.Create;
   
   (FItems      as TPackStringList).OnChange:=UpdateView;
   (FRowOffsets as TPackStringList).OnChange:=UpdateView;
   (FColOffsets as TPackStringList).OnChange:=UpdateView;
   (FRowStates  as TPackStringList).OnChange:=UpdateView;
   
   FIsTxnLog:=False;
end;           
destructor TPadControl.Destroy;
begin
   FItems.Free;
   FRowOffsets.Free;
   FRowStates.Free;
   FColOffsets.Free;
   FBackGround.Free;
   inherited Destroy;
end;
function TPadControl.GetInteger(Index:Integer):Integer;
begin
   case Index of
      0 : Result:=FListRect.Left  ;
      1 : Result:=FListRect.Top   ;
      2 : Result:=FListRect.Right ;
      3 : Result:=FListRect.Bottom;
      4 : Result:=FItemIndex ;
      5 : Result:=FTopIndex  ;
      else Result:=0;
   end;
end;
procedure TPadControl.SetBoolean(Index:Integer;Value:Boolean);
type
   PBoolean = ^Boolean;
var
   Item:PBoolean;
begin
   case Index of
      0 : Item:=@FStopOnDisabled;
      1 : Item:=@FKeepInView;
      2 : Item:=@FIsTxnLog;
      else Exit;
   end;
   if Item^ <> Value then
   begin
      Item^:=Value;
      UpdateView(nil);
   end;
end;
procedure TPadControl.SetColor(Index:Integer;Value:TColor);
type
   PColor = ^TColor;
var
   Item:PColor;
begin
   case Index of
      0 : Item:=@FDisableColor  ;
      1 : Item:=@FHighLightColor;
      2 : Item:=@FLowLightColor ;
      else Exit;
   end;
   if Item^ <> Value then
   begin
      Item^:=Value;
      UpdateView(nil);
   end;
end;
procedure TPadControl.SetInteger(Index:Integer;Value:Integer);
var
   Item:PInteger;
begin
   case Index of
      0 : Item:=@FListRect.Left  ;
      1 : Item:=@FListRect.Top   ;
      2 : Item:=@FListRect.Right ;
      3 : Item:=@FListRect.Bottom;
      4 : 
         begin
            Item:=@FItemIndex;
            if (FKeepInView) then
            begin
               if Value < 0 then 
                  Value:=0
               else if Value >= FItems.Count then 
                  Value:=FItems.Count-1;
            end   
            else
            begin
               if (Value < -1) or (Value >= FItems.Count) then Exit;
            end;
            if (not FStopOnDisabled) and (Value <> -1) then
            begin
               // if new row is disabled
               if (Value < FRowStates.Count) and (FRowStates[Value] <> '') and ((FRowStates[Value][1] = 'D') or (FRowStates[Value][1] = 'd')) then
               begin
                  if FItemIndex < Value then // moving down
                  begin
                     // move down until enabled or end of list
                     while (Value < FRowStates.Count) and (FRowStates[Value] <> '') and ((FRowStates[Value][1] = 'D') or (FRowStates[Value][1] = 'd')) do
                     begin 
                        Inc(Value);
                     end;
                     if (Value >= FRowStates.Count) and (Value >= FItems.Count) then
                        Value:=FItemIndex;
                  end
                  else // moving up
                  begin
                     while (Value > 0) and (FRowStates[Value] <> '') and ((FRowStates[Value][1] = 'D') or (FRowStates[Value][1] = 'd')) do
                     begin 
                        Dec(Value);
                     end;
                     if (Value = 0) and (FRowStates[Value] <> '') and ((FRowStates[Value][1] = 'D') or (FRowStates[Value][1] = 'd')) then
                        Value:=-1;
                  end;
               end;
            end;
            if FKeepInView then
            begin
               if Value < FTopIndex then 
                  TopIndex:=Value
               else if Value > (FTopIndex + FMaxRowCount) then 
                  TopIndex:=Value-FMaxRowCount-1;
            end;
         end;
      5 :
         begin 
            if (Value < 0) or (Value >= FItems.Count) then Exit;
            Item:=@FTopIndex;
         end;
      else Exit;
   end;
   if Item^ <> Value then
   begin
      Item^:=Value;
      UpdateView(nil);
   end;
end;
procedure TPadControl.SetItems(Index:Integer;Value:TStrings);
type
   PStrings = ^TStrings;
var
   Item:PStrings;
begin
   case Index of
      0 : Item:=@FItems;
      1 : Item:=@FRowOffsets;
      2 : Item:=@FColOffsets;
      3 : Item:=@FRowStates;
      else Exit;
   end;
   if Item^ <> Value then
   begin
      Item^.Assign(Value);
      UpdateView(nil);
   end;
end;
function TPadControl.GetItems(Index:Integer):TStrings;
begin
   case Index of
      0 : Result:=FItems  ;
      1 : Result:=FRowOffsets;
      2 : Result:=FColOffsets;
      3 : Result:=FRowStates;
      else Result:=nil;
   end;
end;
procedure TPadControl.SetBackGround(Value:TPicture);
begin
   if FBackGround <> Value then
   begin
     FBackGround.Assign(Value);
     Invalidate;
   end;
end;
procedure TPadControl.CalcVisibleRows;
var
   RowCount:Integer;
   YOffset:Integer;
   ItemHeight:Integer;
   ItemHeightDef:Integer;
begin
   RowCount:=0;
   YOffset:=FListRect.Top;
   ItemHeightDef:=Canvas.TextHeight('Wg');
   while YOffset < FListRect.Bottom do
   begin
      if Assigned(OnMeasureItem) then 
         ItemHeight:=OnMeasureItem(RowCount)
      else if RowCount < FRowOffsets.Count then
         ItemHeight:=StrToIntDef(FRowOffsets[RowCount],ItemHeightDef)
      else if FRowOffsets.Count > 0 then
         ItemHeight:=StrToIntDef(FRowOffsets[0],ItemHeightDef)
      else                          
         ItemHeight:=ItemHeightDef;
      Inc(YOffset,ItemHeight);
      Inc(RowCount);
   end;
   FMaxRowCount:=RowCount-3;
end;
procedure TPadControl.Paint;
var
  BGRect:TRect;
  ItemHeight:Integer;
  TopOffset:Integer;
  YOffset:Integer;
  XOffset:Integer;
  RowIndex:Integer;
  ColIndex:Integer;
  ItemWidth:Integer;
  LeftOffset:Integer;
  Hgt:Integer;
  BlockHeight:Integer;
  ItemHeightDef:Integer;
  ItemWidthDef:Integer;
  LineList:TPackStringList;
  Justify:Integer;
  StateColor:TColor;
  NormRowColor:TColor;
  AltRowColor :TColor;
  CurrRowIsNorm:Boolean;
begin

   CurrRowIsNorm:=True;
   NormRowColor:=clWindow;
   AltRowColor :=clBtnFace;
   BlockHeight:=0;
   if FIsTxnLog then
   begin
      if FBackGround <> nil then
      begin
         NormRowColor:=FBackGround.BitMap.Canvas.Pixels[FListRect.Left+4,FListRect.Top+4];
         AltRowColor :=FBackGround.BitMap.Canvas.Pixels[32,14];
      end;
   end;
   CalcVisibleRows;
   LineList:=TPackStringList.Create;
   TopOffset:=FListRect.Top;
   LeftOffset:=FListRect.Left;
   with Canvas do
   begin
      if CsDesigning in ComponentState then
      begin
         Font.Name:='Arial';
         Font.Style:=[];
         Font.Size:=8;
         Brush:=Parent.Brush;
         Font.Color:=clBlack;
         Pen.Color:=clBlack;
         Rectangle(0,0,Width,Height);
         TextOut(2,1,Name);
         Font:=Self.Font;
         Pen.Color:=clBlack;
      end;
      ItemHeightDef:=TextHeight('Wg');
      if FBackGround <> nil then
      begin
         with FBackGround.BitMap do
            BGRect:=Bounds(0,0,Width,Height);
         CopyRect(BGRect,FBackGround.BitMap.Canvas,BGRect);
      end;
      YOffset:=TopOffset;
      if FTopIndex < 0 then TopIndex:=0;
      for RowIndex:=FTopIndex to FItems.Count-1 do
      begin
         Font:=Self.Font;
         if Assigned(OnMeasureItem) then 
            ItemHeight:=OnMeasureItem(RowIndex)
         else if (RowIndex-FTopIndex) < FRowOffsets.Count then
            ItemHeight:=StrToIntDef(FRowOffsets[(RowIndex-FTopIndex)],ItemHeightDef)
         else if FRowOffsets.Count > 0 then
            ItemHeight:=StrToIntDef(FRowOffsets[0],ItemHeightDef)
         else                          
            ItemHeight:=ItemHeightDef;
            
         StateColor:=Font.Color;
         if RowIndex < FRowStates.Count then
         begin
            if FRowStates[RowIndex] <> '' then
            begin
               case FRowStates[RowIndex][1] of
                  'D' : StateColor:=FDisableColor;
                  'H' : StateColor:=FHighLightColor;
                  'L' : StateColor:=FLowLightColor;
               end;
            end; 
         end;
         if RowIndex = FItemIndex then
         begin
            BGRect:=Bounds(LeftOffset,YOffset,(FListRect.Right-FListRect.Left),ItemHeight);
            if (Length(FItems[RowIndex]) <> 0) and (FItems[RowIndex][1] = '*') then
            begin
               BlockHeight:=1;
               while (FItems.Count > RowIndex+BlockHeight) and (Length(FItems[RowIndex+BlockHeight]) <> 0) and (FItems[RowIndex+BlockHeight][1] = '*') do
               begin
                  Inc(BlockHeight);
               end;
               Inc(BlockHeight);
               BGRect:=Bounds(LeftOffset,YOffset,(FListRect.Right-FListRect.Left),ItemHeight*BlockHeight);
            end;
            if BGRect.Bottom > FListRect.Bottom then 
               BGRect.Bottom:=FListRect.Bottom;
            Brush.Style:=bsSolid;
            Brush.Color:=StateColor;
            Font.Color:=Self.Color;
            FillRect(BGRect);
         end                     
         else
         begin
            Dec(BlockHeight);
            Brush.Style:=bsSolid;
            Brush.Color:=StateColor;
            Font.Color:=Self.Color;
            if BlockHeight <= 0 then
            begin
               if FIsTxnLog then
               begin
                  BGRect:=Bounds(LeftOffset,YOffset,(FListRect.Right-FListRect.Left),ItemHeight);
                  if BGRect.Bottom > FListRect.Bottom then 
                     BGRect.Bottom:=FListRect.Bottom;
                  Brush.Style:=bsSolid;
                  if CurrRowIsNorm then
                     Brush.Color:=NormRowColor
                  else
                     Brush.Color:=AltRowColor;
                  Font.Color:=StateColor;
                  FillRect(BGRect);
               end
               else
               begin
                  Font.Color:=StateColor;
                  Brush.Color:=Self.Color;
                  Brush.Style:=bsClear;
               end;
            end;
         end;
         if (Length(FItems[RowIndex]) <> 0) and (FItems[RowIndex][1] = '*') then
            LineList.CommaText:=Copy(FItems[RowIndex],2,Length(FItems[RowIndex]))
         else
            LineList.CommaText:=FItems[RowIndex];
         if LineList.Count < 1 then
         begin
            ItemWidth:=(FListRect.Right-FListRect.Left);
            XOffset:=LeftOffset;
            BGRect:=Bounds(XOffset,YOffset,ItemWidth,ItemHeight);
            if Assigned(OnDrawItem) then 
            begin
               OnDrawItem(FItems[RowIndex],Canvas,BGRect,RowIndex,0)
            end
            else
            begin
               Hgt:=DrawText(Canvas.Handle,PChar(FItems[RowIndex]),Length(FItems[RowIndex]),BGRect,DT_CALCRECT);
               OffsetRect(BGRect,0,(ItemHeight-Hgt) div 2);
               if BGRect.Bottom > FListRect.Bottom then 
                  BGRect.Bottom:=FListRect.Bottom;
               DrawText(Canvas.Handle,PChar(FItems[RowIndex]),Length(FItems[RowIndex]),BGRect,0);
            end;
         end
         else
         begin
            ItemWidthDef:=(FListRect.Right-FListRect.Left) div LineList.Count;
            XOffset:=LeftOffset;
            for ColIndex:=0 to LineList.Count-1 do
            begin
               Justify:=DT_LEFT;
               if ColIndex < FColOffsets.Count then
               begin
                  if FColOffsets[ColIndex][1] > '9' then
                  begin
                     if FColOffsets[ColIndex][1] = 'R' then 
                        Justify:=DT_RIGHT
                     else if FColOffsets[ColIndex][1] = 'C' then 
                        Justify:=DT_CENTER;
                     ItemWidth:=StrToIntDef(Copy(FColOffsets[ColIndex],2,999),ItemWidthDef);
                  end                                   
                  else
                  begin
                     ItemWidth:=StrToIntDef(FColOffsets[ColIndex],ItemWidthDef);
                  end;                                    
               end   
               else if FColOffsets.Count > 0 then
               begin
                  if FColOffsets[0][1] > '9' then
                  begin
                     if FColOffsets[0][1] = 'R' then 
                        Justify:=DT_RIGHT
                     else if FColOffsets[0][1] = 'C' then 
                        Justify:=DT_CENTER;
                     ItemWidth:=StrToIntDef(Copy(FColOffsets[0],2,999),ItemWidthDef)
                  end                                   
                  else
                  begin
                     ItemWidth:=StrToIntDef(FColOffsets[0],ItemWidthDef)
                  end;                                    
               end
               else                          
                  ItemWidth:=ItemWidthDef;
               BGRect:=Bounds(XOffset,YOffset,ItemWidth,ItemHeight);
               if Assigned(OnDrawItem) then 
               begin
                  OnDrawItem(LineList.Strings[ColIndex],Canvas,BGRect,RowIndex,ColIndex)
               end
               else
               begin
                  Hgt:=DrawText(Canvas.Handle,PChar(LineList.Strings[ColIndex]),Length(LineList.Strings[ColIndex]),BGRect,DT_CALCRECT or Justify);
                  BGRect:=Bounds(XOffset,YOffset,ItemWidth,ItemHeight);
                  OffsetRect(BGRect,0,(ItemHeight-Hgt) div 2);
                  if BGRect.Bottom > FListRect.Bottom then 
                  begin
                     BGRect.Bottom:=FListRect.Bottom;
                     DrawText(Canvas.Handle,PChar(LineList.Strings[ColIndex]),Length(LineList.Strings[ColIndex]),BGRect,Justify);
                  end
                  else
                  begin
                     DrawText(Canvas.Handle,PChar(LineList.Strings[ColIndex]),Length(LineList.Strings[ColIndex]),BGRect,Justify or DT_NOCLIP);
                  end;
               end;
               Inc(XOffset,ItemWidth);
            end;
         end;
         Inc(YOffset,ItemHeight);
         if YOffset > FListRect.Bottom then Break;
         if csDesigning in ComponentState then
         begin
            Pen.Color:=clBlack;
            Pen.Style:=psDot;
            with FListRect do PolyLine([Point(Left,YOffset),Point(Right,YOffset)]);
            Pen.Style:=psSolid;
         end;
         if FIsTxnLog and ((Length(FItems[RowIndex]) = 0) or (FItems[RowIndex][1] <> '*')) then
            CurrRowIsNorm:=not CurrRowIsNorm;
      end;
      if csDesigning in ComponentState then
      begin
         Pen.Style:=psDot;
         Pen.Color:=clBlack;
         Brush.Style:=bsClear;
         with FListRect do
            Rectangle(Left,Top,Right,Bottom);
         Pen.Style:=psSolid;
         Brush.Style:=bsSolid;
      end;             
   end;
   LineList.Free;
end;
procedure Register;
begin
  RegisterComponents('CorvusVCL', [TPadControl,TPadController]);
end;
end.
