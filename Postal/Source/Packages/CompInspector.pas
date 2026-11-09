unit CompInspector;

interface

uses
  EditButton,
  extctrls,
  extdlgs,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,ComCtrls,

{$ifdef VERSION2}
  CompressU,Bin2String;
{$else}
  Compress;
{$endif}


const
   K_FONT = '{Font}' ;

type
  TGetDataProc = Procedure( Name, Value : String ) of object ;

  TItemType = (itString,itList,itInteger,itCurrency,itBitmap,itBoolean,itDate,itComboBox, itFont );
  TDesignerItem = class
  private
     FPrompt:String;
     FItemType:TItemType;
     FData:String;
     FFont:TFont ;
     FBitMap:TBitMap;
     FItemHeight:Integer;
     FItems : TStringList ;
     procedure AdjustRatio(var Rect:TRect;IW,IH:Integer);
     function ReadItems : String ;
     procedure SetItems( Items : String );
  public
     function Draw(Canvas:TCanvas;Selected:Boolean;InRect:TRect;PWidth:Integer):Integer;
     constructor Create(Prompt:String;ItemType:TItemType;Data : String);
     constructor CreateFont(Prompt:String;Font : TFont );
     constructor CreateBitMap(Prompt, FBmpFile :String;BitMap : TBitMap );
     destructor  Destroy ; override ;
     property Prompt  :String    read FPrompt   write FPrompt  ;
     property ItemType:TItemType read FItemType write FItemType;
     property Data    :String    read FData     write FData    ;
     property Font    :TFont     read FFont     write FFont    ;
     property BitMap  :TBitMap   read FBitMap   write FBitMap  ;
     property ItemHeight:Integer read FItemHeight write FItemHeight;
     property Items : string     read ReadItems    write SetItems ;
  end;
  TDesignerItemList = class
  private
     FItems:TList;
     FSelected:Integer;
     FPromptWidth:Integer;
     FListHeight:Integer;
     ParentRect:TRect;
     function GetCount:Integer;
     function GetItem(Index:Integer):TDesignerItem;
  public
     constructor Create;
     destructor Destroy; override;
     procedure Draw(Canvas:TCanvas;InRect:TRect);
     function SelectedRect:TRect;
     function MouseToItem(Y:Integer):Integer;
     function Add(Prompt:String;ItemType:TItemType;Data : String ):Integer;
     function AddFont(Prompt:String; Font   : TFont   ):Integer;
     function AddBitMap(Prompt, FBmpFile :String; BitMap : TBitMap ):Integer;
     procedure Clear;
     property Count:Integer read GetCount;
     property Items[Index:Integer]:TDesignerItem read GetItem; default;
     property Selected:Integer read FSelected write FSelected;
     property PromptWidth:Integer read FPromptWidth write FPromptWidth;
     property ListHeight:Integer read FListHeight write FListHeight;
  end;
  TCompInspector = class(TCustomControl)
  private
     MBDown:Boolean;
     MBDblClick:Boolean;
     InPlace:TEdit;
     InPlaceCB : TComboBox ;
     InPlaceDT:TDateTimePicker;
     InPlaceFT: TEditButton ;
     InPlaceIMG: TImage ;
     ItemDsgList:TDesignerItemList;
     FOnDataFieldChange : TGetDataProc ;
     procedure SetPromptWidth(Value:Integer);
     function  GetPromptWidth:Integer;
     procedure SetSelected(Value:Integer);
     function  GetSelected:Integer;
     procedure EditIntKeyPress(Sender: TObject; var Key: Char ) ;
  protected
    procedure SaveIPData;
    procedure CreateInPlace;
    procedure Paint; override;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer); override;
    procedure DblClick ; override;
    procedure MouseMove(Shift:TShiftState;X,Y:Integer); override;
    procedure MouseUp(Button:TMouseButton;Shift:TShiftState;X,Y:Integer); override;
    procedure UpdateInPlace;
  public
    procedure HideInPlace;
    function MouseToItem(Y:Integer):Integer;
    function Add(Prompt:String;ItemType:TItemType;Data : String ):Integer;
    function AddFont(Prompt:String;Font : TFont ):Integer;
    function AddBitMap(Prompt, FBmpFile :String;BitMap : TBitMap ):Integer;
//    procedure Delete(Index:Integer);
//    procedure IndexOf(Prompt:String):Integer;
    procedure Clear;
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    function GetItem(Index:Integer):TDesignerItem;
    function GetCount:Integer;
    procedure InPlaceChange(Sender:TObject);
    procedure ImageDblClick(Sender: TObject);
    procedure EditFont(Sender:TObject) ;
    property Items[Index:Integer]:TDesignerItem read GetItem; default;
    property OnDataFieldChange : TGetDataProc read FOnDataFieldChange write FOnDataFieldChange ;
  published
    property Align;
    property Color;
    property Font;
    property ParentColor;
    property ParentFont;
    property PromptWidth:Integer read GetPromptWidth write SetPromptWidth;
    property Selected:Integer read GetSelected write SetSelected;
    property Count:Integer read GetCount;
    property OnDragOver;
    property OnDragDrop;
  end;

procedure Register;
//function GetBitmap(Value:String):TBitMap;

//{$R Designers.Res}

implementation
{TDesignerItem}

procedure TDesignerItem.AdjustRatio(var Rect:TRect;IW,IH:Integer);
var
 IRatio:Real;
 MRatio:Real;
 MW,MH:Integer;
begin
  MW:=Rect.Right-Rect.Left;
  MH:=Rect.Bottom-Rect.Top;

  if (IH = 0) or (MH = 0)  or (IW = 0)  or (MW = 0) then Exit;
  if (IW <= MW) and (IH <= MH) then
  begin
    Rect.Left :=Rect.Left+((MW-IW) div 2);
    Rect.Top  :=Rect.Top +((MH-IH) div 2);
    Rect.Right :=Rect.Left+IW;
    Rect.Bottom:=Rect.Top +IH;
  end
  else
  begin
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
end;
constructor TDesignerItem.Create(Prompt:String;ItemType:TItemType;Data:String);
begin
   FItems   :=TStringList.Create ;
   FPrompt  :=Prompt ;
   FItemType:=ItemType;
   FItemHeight:=20;
   if ( FItemType = itComboBox ) then
   begin
      FItems.CommaText := Data ;
      if ( FItems.Count > 0 ) then
      begin

         FData  := FItems[0];
         FItems.Delete(0);

      end
      else
         FData := '' ;

   end
   else
      FData  :=Data ;

end;
constructor TDesignerItem.CreateFont(Prompt:String;Font : TFont );
begin
   FPrompt  :=Prompt ;
   ItemType := itFont ;
   FFont := Font ;
   FData := '' ;
end;

constructor TDesignerItem.CreateBitMap(Prompt, FBmpFile :String;BitMap : TBitMap );
begin
   FPrompt  :=Prompt ;
   ItemType := itBitMap ;
   FBitMap := BitMap ;
   FData := FBmpFile ;
end;

destructor TDesignerItem.Destroy ;
begin
   FItems.Free ;
   FFont := nil ;
   FBitMap := nil ;
   //FBitMap.Free ;
   inherited ;
end ;
function TDesignerItem.ReadItems : String ;
begin
   result := FItems.CommaText
end ;
procedure TDesignerItem.SetItems( Items : String );
begin
   FItems.CommaText := Items ;
end ;

// function GetBitmap(Value:String):TBitMap;
// var
// {$ifdef VERSION2}
//    SStream:TStringStream;
//    Compressor:TCompress;
// {$else}
//    Compressor:TCompressor;
// {$endif}
// begin
// {$ifdef VERSION2}
//    Compressor:=TCompress.Create;
//    Value:=StringToBinary(Value);
//    Value:=Compressor.CompressString(Value);
//    Compressor.Free;
//    SStream:=TStringStream.Create(Value);
//    SStream.Position:=0;
//    Result:=TBitMap.Create;
//    Result.LoadFromStream(SStream);
//    SStream.Free;
// {$else}
//    Compressor:=TCompressor.Create;
//    Result:=Compressor.CreateBitmapFromString(Value);
//    Compressor.Free;
// {$endif}
// end;
function TDesignerItem.Draw(Canvas:TCanvas;Selected:Boolean;InRect:TRect;PWidth:Integer):Integer;
var
   BC:TColor;
   FC:TColor;
   //BMP:TBitMap;
   IRTop:Integer;
   Dest:TRect;
begin
   //BMP:=nil;
   with Canvas do
   begin
      if FItemType = itBitMap then
      begin
         FItemHeight:=((InRect.Right-(InRect.Left+PWidth)) div 4) * 3;
         InRect.Bottom:=InRect.Top+FItemHeight;
         try
            //BMP:=GetBitMap(FData);
            Dest:=InRect;
            IRTop:=Dest.Top+2;
            Inc(Dest.Left,PWidth+2);
            //AdjustRatio(Dest,BMP.Width,BMP.Height);
            AdjustRatio(Dest,FBitMap.Width,FBitMap.Height);
            Dec(Dest.Bottom,Dest.Top-IRTop);
            Dest.Top:=IRTop;
            FItemHeight:=(Dest.Bottom-Dest.Top)+4;
            InRect.Bottom:=InRect.Top+FItemHeight;
         except
            //if BMP <> nil then BMP.Free;
            Dest:=InRect;
            FItemHeight:=(Dest.Bottom-Dest.Top)+4;
            //BMP:=nil;
         end;
      end
      else
      begin
         FItemHeight:=TextHeight('Wg')+4;
         InRect.Bottom:=InRect.Top+FItemHeight;
      end;

      BC:=Brush.Color;
      FC:=Font.Color;
      FillRect(InRect);
      if Selected then
      begin
         Pen.Color:=cl3DDkShadow;
         with InRect do PolyLine([Point(Left,Bottom),Point(Left,Top),Point(Right,Top)]);
         Pen.Color:=clBtnHighLight;
         with InRect do PolyLine([Point(Left,Bottom),Point(Right,Bottom)]);
         Brush.Color:=clWindow;
         with InRect do Rectangle(Left+PWidth+1,Top+1,Right,Bottom);
         Brush.Color:=BC;
         Pen.Color:=clBtnShadow;
         with InRect do PolyLine([Point(Left+PWidth,Top+1),Point(Left+PWidth,Bottom)]);
         Pen.Color:=clBtnHighLight;
         with InRect do PolyLine([Point(Left+PWidth+1,Top+1),Point(Left+PWidth+1,Bottom)]);
      end
      else
      begin
         Pen.Color:=clBtnShadow;
         with InRect do PolyLine([Point(Left,Bottom),Point(Right,Bottom)]);
         with InRect do PolyLine([Point(Left+PWidth,Top),Point(Left+PWidth,Bottom)]);
         Pen.Color:=clBtnHighLight;
         with InRect do PolyLine([Point(Left+PWidth+1,Top),Point(Left+PWidth+1,Bottom)]);
      end;

      Font.Color:=clBlack;
      with InRect do TextOut(Left+2,Top+2,FPrompt);

      if Selected then
      begin
         Brush.Color:=clWindow;
      end
      else
      begin
         Font.Color:=FC;
      end;

      if FItemType = itFont then
      begin
         with InRect do TextOut( Left+PWidth+4,Top+2, K_FONT );
      end
      else if FItemType = itBitMap then
      begin
         //if BMP <> nil then
         //begin
            BrushCopy(Dest,FBitMap,Bounds(0,0,FBitMap.Width,FBitMap.Height),FBitMap.TransparentColor);
            //BrushCopy(Dest,BMP,Bounds(0,0,BMP.Width,BMP.Height),BMP.TransparentColor);
            //BMP.Free;
         //end
         //else
         //begin
         //   with InRect do TextOut(Left+PWidth+4,Top+2,'No Picture');
         //   FData:='';
         //end
      end
      else
      begin
         with InRect do TextOut(Left+PWidth+4,Top+2,FData);
      end;

      Brush.Color:=BC;
      Font.Color:=FC;

   end;

   Inc(FItemHeight);
   Result:=FItemHeight;

end;
{TDesignerItemList}
function ListSortCompare(Item1,Item2:Pointer):Integer;
begin
   Result:=StrComp(PChar(TDesignerItem(Item1).Prompt),PChar(TDesignerItem(Item2).Prompt));
end;
constructor TDesignerItemList.Create;
begin
   FItems:=TList.Create;
end;
destructor TDesignerItemList.Destroy;
var
   I:Integer;
begin
   for I:=0 to Count do Items[I].Free;
   FItems.Free;
   inherited Destroy;
end;
function TDesignerItemList.SelectedRect:TRect;
var
   I,Y:Integer;
begin
   if (Selected < 0) or (Selected >= Count) then
   begin
      Result:=Rect(0,0,0,0);
      Exit;
   end;
   Y:=ParentRect.Top;
   for I:=0 to Selected-1 do Inc(Y,Items[I].ItemHeight);
   Result:=Rect(ParentRect.Left,Y,ParentRect.Right,Y+Items[Selected].ItemHeight);
end;
function TDesignerItemList.MouseToItem(Y:Integer):Integer;
var
   I,YPos:Integer;
begin
   YPos:=ParentRect.Top;
   for I:=0 to Count-1 do
   begin
      if (Y >= YPos) and (Y <= (YPos+Items[I].ItemHeight)) then
      begin
         Result:=I;
         Exit;
      end;
      Inc(YPos,Items[I].ItemHeight);
   end;
   Result:=-1;
end;
procedure TDesignerItemList.Draw(Canvas:TCanvas;InRect:TRect);
var
   I:Integer;
   ItemRect:TRect;
   YPos:Integer;
begin
   ParentRect:=InRect;
   with Canvas do
   begin
      YPos:=InRect.Top;
      for I:=0 to Count-1 do
      begin
         ItemRect:=Rect(InRect.Left,YPos,InRect.Right,InRect.Bottom);
         Inc(Ypos,Items[I].Draw(Canvas,I=FSelected,ItemRect,FPromptWidth));
        // if InRect.Top+YPos > InRect.Bottom then Exit;
      end;
   end;
   ListHeight:=YPos-InRect.Top;
end;
procedure TDesignerItemList.Clear;
var
   I:Integer;
begin
   for I:=0 to Count do Items[I].Free;
   FItems.Clear;
end;
function TDesignerItemList.GetCount:Integer;
begin
   Result:=FItems.Count;
end;
function TDesignerItemList.GetItem(Index:Integer):TDesignerItem;
begin
   if Index < FItems.Count then
      Result:=TDesignerItem(FItems[Index])
   else
      Result:=nil;
end;
function TDesignerItemList.Add(Prompt:String;ItemType:TItemType;Data: String ):Integer;
var
   DI:TDesignerItem;
begin
   DI:=TDesignerItem.Create(Prompt,ItemType,Data);
   FItems.Add(DI);
   FItems.Sort(ListSortCompare);
   Result:=FItems.IndexOf(DI);
end;
function TDesignerItemList.AddFont(Prompt:String; Font: TFont ):Integer;
begin
   Result:=FItems.Add(TDesignerItem.CreateFont(Prompt,Font ));
   FItems.Sort(ListSortCompare);
end;
function TDesignerItemList.AddBitMap(Prompt, FBmpFile :String; BitMap: TBitMap ):Integer;
begin
   Result:=FItems.Add(TDesignerItem.CreateBitMap(Prompt,FBmpFile, BitMap ));
   FItems.Sort(ListSortCompare);
end;


procedure TCompInspector.HideInPlace;
begin
   InPlace.Visible:=False;
   InPlace.OnKeyPress := nil ;
   InPlaceDT.Visible:=False;
   InPlaceCB.Visible:=False;
   InPlaceFT.Visible:=False;
end;
procedure TCompInspector.UpdateInPlace;
var
   SelRect:TRect;
   DataInt : integer ;
begin
   if csDesigning in ComponentState then Exit;

   //InPlace.ReadOnly := TRUE ;
   InPlace.Visible:=False;
   InPlace.OnKeyPress := nil ;
   InPlaceDT.Visible:=False;
   InPlaceCB.Visible:=False;
   InPlaceFT.Visible:=False;

   if (ItemDsgList.Selected < ItemDsgList.Count) and (ItemDsgList.Selected >= 0) then
   begin
      SelRect:=ItemDsgList.SelectedRect;
      if ItemDsgList[ItemDsgList.Selected].ItemType = itDate then
      begin
         try
            InPlaceDT.Date:=StrToDate(ItemDsgList[ItemDsgList.Selected].Data);
         except
            InPlaceDT.Date:=Now;
         end;
         InPlaceDT.SetBounds(PromptWidth+3,SelRect.Top,(Width-PromptWidth)-4,SelRect.Bottom-SelRect.Top);
         if Visible then
         begin
            InPlaceDT.Visible:=True;
            if (not (csLoading in ComponentState)) then InPlaceDT.SetFocus;
         end;
      end
      else if ItemDsgList[ItemDsgList.Selected].ItemType = itComboBox then
      begin
         try
            InPlaceCB.Items.CommaText := ItemDsgList[ItemDsgList.Selected].Items ;
            try
               InPlaceCB.ItemIndex := InPlaceCB.Items.Indexof( ItemDsgList[ItemDsgList.Selected].Data );
            except
               InPlaceCB.Text:= '';
            end;
         except
            InPLaceCB.Items.CommaText := '' ;
         end ;
         InPlaceCB.SetBounds(PromptWidth+3,SelRect.Top,(Width-PromptWidth)-4,SelRect.Bottom-SelRect.Top);
         if Visible then
         begin
            InPlaceCB.Visible:=True;
            if (not (csLoading in ComponentState)) then InPlaceCB.SetFocus;
         end;
      end

      else if ItemDsgList[ItemDsgList.Selected].ItemType = itInteger then
      begin
         try
            DataInt := StrToInt( ItemDsgList[ItemDsgList.Selected].Data ) ;
            InPlace.Text:= IntToStr( DataInt );
         except
         end ;
         InPlace.SetBounds(PromptWidth+3,SelRect.Top,(Width-PromptWidth)-4,SelRect.Bottom-SelRect.Top);
         InPlace.Font.Color:=clBlack;
         if Visible then
         begin
            InPlace.OnKeyPress := EditIntKeyPress ;
            InPlace.Visible:=True;
            if (not (csLoading in ComponentState)) then InPlace.SetFocus;
         end;
      end
      else if ItemDsgList[ItemDsgList.Selected].ItemType = itFont then
      begin
         InPlaceFT.Font.Color:=clBlack;
         InPlaceFT.Text:= K_FONT ;
         InPlaceFT.SetBounds(PromptWidth+3,SelRect.Top,(Width-PromptWidth)-4,SelRect.Bottom-SelRect.Top);
         InPlaceFT.PaceCtrl ;
         if Visible then
         begin
            InPlaceFT.Visible:=True;
            if (not (csLoading in ComponentState)) then InPlaceFT.EditBT.SetFocus;
         end;
      end
      else if ItemDsgList[ItemDsgList.Selected].ItemType = itBitMap then
      begin
         //InPlaceIMG.Font.Color:=clBlack;
         //InPlaceIMG.SetBounds(PromptWidth+3,SelRect.Top,(Width-PromptWidth)-3,SelRect.Bottom-SelRect.Top);
         //InPlaceIMG.Visible:=True;
         //if (not (csLoading in ComponentState)) then InPlaceIMG.SetFocus;

      end
      else
      begin
         InPlace.Font.Color:=clBlack;
         InPlace.Text:=ItemDsgList[ItemDsgList.Selected].Data;
         InPlace.SetBounds(PromptWidth+3,SelRect.Top,(Width-PromptWidth)-4,SelRect.Bottom-SelRect.Top);
         if Visible then
         begin
            InPlace.Visible:=True;
            if (not (csLoading in ComponentState)) then InPlace.SetFocus;
         end;
      end ;

   end;
end;
procedure TCompInspector.InPlaceChange(Sender:TObject);
begin
   SaveIPData;
end;

procedure TCompInspector.EditFont(Sender:TObject);
var
   FontDialog : TFontDialog ;
begin
   // SaveIPData;
   FontDialog := TFontDialog.Create( nil ) ;
   try
      FontDialog.Font.Assign(ItemDsgList[ItemDsgList.Selected].Font ) ;
      if FontDialog.Execute then
      begin
         ItemDsgList[ItemDsgList.Selected].Font.Assign( FontDialog.Font );
        // ChangeData := TRUE ;
      end ;
   finally
      FontDialog.Free ;
   end ;

end;

procedure TCompInspector.ImageDblClick(Sender: TObject);
var
 OPDialog : TOpenPictureDialog ;
begin

   if ItemDsgList.Selected >= 0 then
      if ItemDsgList[ItemDsgList.Selected].ItemType = itBitMap then
      begin
         OPDialog := TOpenPictureDialog.Create( nil );
         try
            OPDialog.Options  := [ ofHideReadOnly, ofPathMustExist, ofFileMustExist ] ;
            OPDialog.FileName := ItemDsgList[ItemDsgList.Selected].Data ;
            if OPDialog.Execute then
            begin
               ItemDsgList[ItemDsgList.Selected].Data := OPDialog.FileName ;
               ItemDsgList[ItemDsgList.Selected].BitMap.LoadFromFile( OPDialog.FileName );

               if Assigned( FOnDataFieldChange ) then
                  FOnDataFieldChange( ItemDsgList[ItemDsgList.Selected].Prompt, ItemDsgList[ItemDsgList.Selected].Data ) ;

            end ;

         finally
            OPDialog.Free ;
         end ;

         Invalidate ;
      end ;
end ;


procedure TCompInspector.SaveIPData;
var
   DataInt : integer ;
   ChangeData : boolean ;
begin
   ChangeData := FALSE ;
   if (csDesigning in ComponentState)
   or (csLoading in ComponentState) then Exit;

   if (ItemDsgList.Selected < ItemDsgList.Count) and (ItemDsgList.Selected >= 0) then
   begin
      if ItemDsgList[ItemDsgList.Selected].ItemType = itBitMap then
      else if ItemDsgList[ItemDsgList.Selected].ItemType = itDate then
      begin
         if ItemDsgList[ItemDsgList.Selected].Data <> DateToStr(InPlaceDT.Date) then
         begin
            ItemDsgList[ItemDsgList.Selected].Data:=DateToStr(InPlaceDT.Date);
            ChangeData := TRUE ;
         end;
      end
      else if ItemDsgList[ItemDsgList.Selected].ItemType = itComboBox then
      begin
         if ItemDsgList[ItemDsgList.Selected].Data <> InPlaceCB.Text then
         begin
            ItemDsgList[ItemDsgList.Selected].Data:= InPlaceCB.Text;
            ChangeData := TRUE ;
         end;
      end
      else if ItemDsgList[ItemDsgList.Selected].ItemType = itInteger then
      begin
         try
            DataInt := StrToInt(InPlace.Text) ;
            if ItemDsgList[ItemDsgList.Selected].Data <> IntToStr( DataInt ) then
            begin
               ItemDsgList[ItemDsgList.Selected].Data:= IntToStr( DataInt );
               ChangeData := TRUE ;
            end ;
         except
         end ;
      end
      else if ItemDsgList[ItemDsgList.Selected].ItemType = itString then
      begin
         if ItemDsgList[ItemDsgList.Selected].Data <> InPlace.Text then
         begin
            ItemDsgList[ItemDsgList.Selected].Data:= InPlace.Text;
            ChangeData := TRUE ;
         end ;
      end

      else if ItemDsgList[ItemDsgList.Selected].ItemType = itFont then
      begin
         // It's done though the event in the button.
      end ;

      if ChangeData and Assigned( FOnDataFieldChange ) then
         FOnDataFieldChange( ItemDsgList[ItemDsgList.Selected].Prompt , ItemDsgList[ItemDsgList.Selected].Data ) ;

   end;
end;
procedure TCompInspector.CreateInPlace;
begin
   if csDesigning in ComponentState then Exit;
   InPlace:=TEdit.Create(Self);
   InsertControl(InPlace);
   InPlace.Visible:=False;
   InPlace.ParentFont:=True;
   InPlace.OnChange :=InPlaceChange;
   InPlaceDT:=TDateTimePicker.Create(Self);
   InPlaceDT.OnChange:=InPlaceChange;
   InsertControl(InPlaceDT);
   InPlaceDT.Visible:=False;
   InPlaceDT.CalAlignment:=dtaRight;
   InPlaceCB := TComboBox.Create( Self );
   InPlaceCB.Visible := FALSE ;
   InPlaceCB.Style := csDropDownList ;
   InPlaceCB.OnChange:=InPlaceChange;
   InsertControl(InPlaceCB);
   InPlaceFT := TEditButton.Create( Self ) ;
   InPlaceFT.OnClickButton := EditFont ;
   InPlaceFT.Visible := FALSE ;
   InsertControl(InPlaceFT);
   InPlaceIMG := TImage.Create( Self ) ;
   InPlaceIMG.OnDblClick := ImageDblClick ;
   InsertControl(InPlaceIMG);
end;
procedure TCompInspector.SetPromptWidth(Value:Integer);
begin
   if ItemDsgList.PromptWidth <> Value then
   begin
      ItemDsgList.PromptWidth:=Value;
      UpdateInPlace;
      Invalidate;
   end;
end;
function TCompInspector.GetPromptWidth:Integer;
begin
   Result:=ItemDsgList.PromptWidth;
end;
procedure TCompInspector.SetSelected(Value:Integer);
var
   ItemRect:TRect;
begin
   if ItemDsgList.Selected <> Value then
   begin
      ItemRect:=ItemDsgList.SelectedRect;
      InvalidateRect(Handle,@ItemRect,False);
      SaveIPData;
      ItemDsgList.Selected:=Value;
      ItemRect:=ItemDsgList.SelectedRect;
      InvalidateRect(Handle,@ItemRect,False);
      UpdateInPlace;
   end;
end;
function TCompInspector.GetSelected:Integer;
begin
   Result:=ItemDsgList.Selected;
end;
constructor TCompInspector.Create(AOwner:TComponent);
begin
   inherited Create(AOwner);
   Width:=300;
   Height:=300;
   ParentColor:=True;
   CreateInPlace;
   ItemDsgList:=TDesignerItemList.Create;
   ItemDsgList.PromptWidth:=80;
   ItemDsgList.Selected:=-1;
   MBDblClick := FALSE ;
end;
destructor TCompInspector.Destroy;
begin
   ItemDsgList.Free;
   InPlace.Free;
   InPlaceDT.Free;
   InPlaceFT.Free;
   inherited Destroy;
end;
function TCompInspector.MouseToItem(Y:Integer):Integer;
begin
   Result:=ItemDsgList.MouseToItem(Y);
end;
procedure TCompInspector.MouseDown(Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
begin
   if ( Button = mbLeft ) and not MBDblClick then
   begin
      Selected:=ItemDsgList.MouseToItem(Y);
      MBDown:=True;
   end;
   MBDblClick := FALSE ;
end;
procedure TCompInspector.MouseMove(Shift:TShiftState;X,Y:Integer);
begin
   if MBDown then
   begin
      Selected:=ItemDsgList.MouseToItem(Y);
      MBDown:=True;
   end;
end;
procedure TCompInspector.MouseUp(Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
begin
   MBDown:=False;
end;
procedure TCompInspector.DblClick ;
begin
   MBDblClick := TRUE ;
   ImageDblClick( Self );
   inherited DblClick ;

   MBDown := FALSE ;
end ;

procedure TCompInspector.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
   inherited;
   UpdateInPlace;
end;
procedure TCompInspector.Paint;
begin
   Canvas.Brush.Color:=Color;
   Canvas.Font:=Font;
   ItemDsgList.Draw(Canvas,Rect(3,3,Width-4,Height-3));
   Self.SetBounds(Left,Top,Width,ItemDsgList.ListHeight+6);
   with Canvas do
   begin
      Pen.Color:=clBtnShadow;
      PolyLine([Point(1,Height-2),Point(1,1),Point(Width-1,1)]);
      Pen.Color:=cl3DDkShadow;
      PolyLine([Point(2,Height-3),Point(2,2),Point(Width-2,2)]);
      Pen.Color:=clBtnHighLight;
      PolyLine([Point(1,Height-2),Point(Width-2,Height-2),Point(Width-2,1)]);
      Brush.Style:=bsClear;
      Canvas.Pen.Color:=clBlack;
      Rectangle(0,0,Width,Height);
      Brush.Style:=bsSolid;
   end;
end;
function TCompInspector.Add(Prompt:String;ItemType:TItemType;Data : String ):Integer;
begin
   Result:=ItemDsgList.Add(Prompt,ItemType,Data);
   Invalidate;
end;
function TCompInspector.AddFont(Prompt:String;Font : TFont ):Integer;
begin
   Result:=ItemDsgList.AddFont(Prompt,Font);
   Invalidate;
end;
function TCompInspector.AddBitMap(Prompt, FBmpFile :String;BitMap : TBitMap ):Integer;
begin
   Result:=ItemDsgList.AddBitMap(Prompt, FBmpFile, BitMap);
   Invalidate;
end;

procedure TCompInspector.Clear;
begin
   Selected:=-1;
   ItemDsgList.Clear;
   Invalidate;
end;
function TCompInspector.GetItem(Index:Integer):TDesignerItem;
begin
   Result:=ItemDsgList.Items[Index];
end;
function TCompInspector.GetCount:Integer;
begin
   Result:=ItemDsgList.Count;
end;

procedure TCompInspector.EditIntKeyPress(Sender: TObject; var Key: Char );
begin

   if not ( Key in [ '0'..'9', #8, '-' ] ) then
      Key := Chr(0)
   else if ( Key = '-' ) and
           ( TEdit( Sender ).SelStart > 0 ) then
      Key := Chr(0) ;


end ;

procedure Register;
begin
  RegisterComponents('CorvusVCL', [TCompInspector]);
end;

end.


