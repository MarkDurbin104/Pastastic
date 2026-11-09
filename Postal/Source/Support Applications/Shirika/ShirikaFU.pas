unit ShirikaFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ComCtrls, Buttons, Menus, WinSvc, ExtCtrls, StdCtrls, Dialogs,
  FileTxStatusU,StatusMonitorU,MsgFileAccessU,OsmiumSupportU,
  PackStrListU,ServiceControlU,MsgConfigU,GPCSGUID,FileCtrl,
  SavePosFormU,StringWrapperU,CoolTrayIcon,MsgFileMaintU;

const
    clOrange = $000080FF;
    
type
  TMsgViewBox = class;
  TTxnLogLineFlags = class(TTxnLogLine)
    public
     property Flags:Variant Index 17 read GetElement write SetElement;
  end;
  TMsgViewBoxDrawItem = procedure(MsgViewBox:TMsgViewBox;Index:Integer;Rect:TRect;State:TOwnerDrawState) of object;
  TMsgViewBoxMeasureItem = procedure(MsgViewBox:TMsgViewBox;Index:Integer;var Height,Width:Integer) of object;
  TMsgViewBox = class(TCustomControl)
    private
       FItems:TPackStringList;
       FItemHeight:Integer;
       FTopIndex:Integer;
       FLeftIndex:Integer;
       FOnDrawItem:TMsgViewBoxDrawItem;
       FOnMeasureItem:TMsgViewBoxMeasureItem;
       FVertScrollBar:TScrollBar;
       FHorizScrollBar:TScrollBar;
    protected
       procedure ItemsChanged(Sender: TObject); virtual;
       procedure VSBChanged(Sender: TObject); virtual;
       procedure HSBChanged(Sender: TObject);
       function GetItem(Index:Integer):String; virtual;
       procedure SetItem(Index:Integer;Value:String); virtual;
       function GetItems:TStrings; virtual;
       procedure SetItems(Value:TStrings); virtual;    
    public                            
       constructor Create(AOwner:TComponent); override;
       destructor Destroy; override;
       procedure Paint; override;
       property VertScrollBar:TScrollBar read FVertScrollBar;
       property HorizScrollBar:TScrollBar read FHorizScrollBar;
    published
      property Align;
      property Color;
      property ItemHeight:Integer read FItemHeight write FItemHeight; 
      property TopIndex:Integer read FTopIndex write FTopIndex;
      property LeftIndex:Integer read FLeftIndex write FLeftIndex;
      property Items:TStrings read GetItems write SetItems;
      property Item[Index:Integer]:String read GetItem write SetItem; default;
      property OnDrawItem:TMsgViewBoxDrawItem read FOnDrawItem write FOnDrawItem;
      property OnMeasureItem:TMsgViewBoxMeasureItem read FOnMeasureItem write FOnMeasureItem;
  end;                 
  TMainForm = class(TSavePosForm)
    Panel1: TPanel;
    MainMenu1: TMainMenu;
    Service1: TMenuItem;
    Start1: TMenuItem;
    Stop1: TMenuItem;
    N1: TMenuItem;
    Install1: TMenuItem;
    Uninstall1: TMenuItem;
    View1: TMenuItem;
    Status1: TMenuItem;
    ContactLog1: TMenuItem;
    StoreContents1: TMenuItem;
    Fil1: TMenuItem;
    Ecit1: TMenuItem;
    Install: TSpeedButton;
    Start: TSpeedButton;
    Stop: TSpeedButton;
    Remove: TSpeedButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Panel3: TPanel;
    ListBox1: TListBox;
    ScrollBox2: TScrollBox;
    PaintBox1: TPaintBox;
    Timer1: TTimer;
    Edit1: TEdit;
    StatInd: TPanel;
    Image1: TImage;
    Memo1: TMemo;
    BImage: TImage;
    RImage: TImage;
    YImage: TImage;
    GImage: TImage;
    PopupMenu1: TPopupMenu;
    Install2: TMenuItem;
    Start2: TMenuItem;
    Stop2: TMenuItem;
    Remove1: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    Show1: TMenuItem;
    TabSheet4: TTabSheet;
    Button1: TButton;
    Button2: TButton;
    ProgressBar: TProgressBar;
    Button3: TButton;
    Edit2: TEdit;
    Button4: TButton;
    Button5: TButton;
    SD: TSaveDialog;
    Button6: TButton;
    OD: TOpenDialog;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure InstallClick(Sender: TObject);
    procedure StartClick(Sender: TObject);
    procedure StopClick(Sender: TObject);
    procedure RemoveClick(Sender: TObject);
    procedure Ecit1Click(Sender: TObject);
    procedure Status1Click(Sender: TObject);
    procedure ContactLog1Click(Sender: TObject);
    procedure StoreContents1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TabSheet3Enter(Sender: TObject);
    procedure TabSheet3Exit(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Show1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
  public
    ColWidths:TTxnLogLineFlags;
    MessageList:TMsgViewBox;
    ServiceRunning:Boolean;
    ThisOfficeID:Integer;
    Workstation :Integer;
    NumWSLines:Integer;
    CoolTrayIcon:TCoolTrayIcon;
    procedure ProgBar(PhaseNo,PhaseOf,Max,Pos:Integer);
    procedure CheckMemoData;
    procedure MessageListDrawItem   (MsgViewBox:TMsgViewBox;Index:Integer;InRect:TRect;State:TOwnerDrawState);
    procedure MessageListMeasureItem(MsgViewBox:TMsgViewBox;Index:Integer;var Height,Width:Integer);
    procedure TrayIconMouseDown(Sender:TObject;Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
  end;

var
  MainForm: TMainForm;

implementation
uses
   MODefinitionsU;
   
{$R *.DFM}

procedure PopulateLBFrom(WSIdx:Integer;Items:TStrings;Canvas:TCanvas;ColWidths:TTxnLogLineFlags;FSMon:TFileStatusMon;OldList:TStringList;Force:Boolean);
var                                                                                                                    
  MsgIndex:Integer;
  I,Off,WS:Integer;
  Status:TStatusBits;
  MessageData:TMessageAccess;
  TxnLines:TTxnLogLines;
  TxnLine:TTxnLogLineFlags;
  Flags:Integer;       
  TW,J:Integer;
  PensionData:TPackStringList;
  PensionPayment:TMinPensionPayment;
  AA,PA:Currency;
  S:String;
begin
   if Force then 
   begin
      OldList.Free;
      OldList:=nil;
   end;
   if OldList <> nil then
   begin
      Items.Clear;
      Items.BeginUpdate;
      Items.Assign(OldList);
      Items.EndUpdate;
      Exit;                    
   end;
   Items.Clear;
   ColWidths.Clear;
   Status:=TStatusBits.Create;
   Status.State:=FSMon.FileBlockMgr.GetStatus;

   TxnLines:=TTxnLogLines.Create;
   TxnLine:=TTxnLogLineFlags.Create;
   TxnLine.RecordID   :='ID'   ;
   TxnLine.WSNumber   :='WS'   ;
   TxnLine.DateTime   :='DateTime'   ;
   TxnLine.RecType    :='RecType'    ;
   TxnLine.Period     :='Period'     ;
   TxnLine.RecIndex   :='Index'   ;
   TxnLine.Office     :='Office'     ;
   TxnLine.Teller     :='Teller'     ;
   TxnLine.PLU        :='PLU'        ;
   TxnLine.Prod       :='Prod'       ;
   TxnLine.Price      :='Price'      ;
   TxnLine.Quantity   :='Quantity'   ;
   TxnLine.TxnValue   :='Value'   ;
   TxnLine.Description:='Desc';
   TxnLine.Info       :='Info'       ;
   TxnLine.Ident      :='Ident'      ;
   TxnLine.DomInfo    :='DomInfo'    ;
   Items.Add(TxnLine.PackText);
   while ColWidths.Count < TxnLine.Count do 
      ColWidths.Add('0');
   for J:=0 to TxnLine.Count-1 do
   begin
      TW:=Canvas.TextWidth(TxnLine[J]);
      if  TW > StrToInt(ColWidths[J]) then
         ColWidths[J]:=IntToStr(TW);
   end;
   
   WS:=Status.WSNumber(WSIdx);
   Off:=Status.OfficeCode(WSIdx);
   Items.BeginUpdate;
   for MsgIndex:=0 to Status.Size(Off,WS)-1 do
   begin
      try
         Flags:=FSMon.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
         // is it a transaction message
         if (Flags and TransactionMsg) = TransactionMsg then
         begin
            MessageData:=FSMon.FileBlockMgr.GetMessage(Off,WS,MsgIndex);
            if MessageData <> nil then
            begin
               S:=MessageData.MessageData;
               if (S <> '') and (S[1] = #1) then
                  TxnLines.PackText:=#2+S
               else                       
                  TxnLines.PackText:=S;
               if not MessageData.GoodCRC then 
                  ShowMessage('Bad CRC in Message (Office '+IntToStr(Off)+' WS '+IntToStr(WS)+' Idx '+IntToStr(MsgIndex)+')');
               if TxnLines.Count = 0 then
               begin
                  TxnLine.PackText:='';
                  if MessageData.DestinationOffice <> 0 then
                     TxnLine.RecordID:=IntToStr(MsgIndex)+' '+IntToStr(MessageData.DestinationOffice)
                  else
                     TxnLine.RecordID:=IntToStr(MsgIndex);
                  TxnLine.Flags:=Flags;
                  TxnLine.WSNumber:=IntToStr(Integer(MessageData.GoodCRC))+' '+IntToStr(WS);
                  TxnLine.Office:=IntToStr(Off);
                  Items.Add(TxnLine.PackText);
                  while ColWidths.Count < TxnLine.Count do 
                     ColWidths.Add('0');
                  for J:=0 to TxnLine.Count-1 do
                  begin
                     TW:=Canvas.TextWidth(TxnLine[J]);
                     if  TW > StrToInt(ColWidths[J]) then
                        ColWidths[J]:=IntToStr(TW);
                  end;
               end
               else
               begin
                  try
                     TxnLine.PackText:=TxnLines[0];
                     for I:=0 to TxnLines.Count-1 do
                     begin
                        TxnLine.PackText:=TxnLines[I];
                        if (TxnLine.RecordID <> '') 
                        or (TxnLine.WSNumber <> '')
                        and (TxnLine.DateTime <> '') then 
                        begin
                           if TxnLine.Price = '' then TxnLine.Price:=0;
                           if TxnLine.TxnValue = '' then TxnLine.TxnValue:=0;
                           if TxnLine.Quantity = '' then TxnLine.Quantity:=0;
                           TxnLine.RecordID:=IntToStr(MsgIndex)+' '+IntToStr(TxnLine.RecordID);
                           TxnLine.WSNumber:=IntToStr(Integer(MessageData.GoodCRC))+' '+IntToStr(TxnLine.WSNumber);
                           TxnLine.DateTime:=FormatDateTime('ddmmyy hhnnss',TDateTime(TxnLine.DateTime));
                           TxnLine.Price:=CurrToStrF(TxnLine.Price,ffNumber,2);
                           TxnLine.TxnValue:=CurrToStrF(TxnLine.TxnValue,ffNumber,2);
                           TxnLine.Flags:=Flags;
                           TxnLines[I]:=TxnLine.PackText;
                     
                           Items.Add(TxnLines[I]);
                     
                           while ColWidths.Count < TxnLine.Count do 
                              ColWidths.Add('0');
                           for J:=0 to TxnLine.Count-1 do
                           begin
                              TW:=Canvas.TextWidth(TxnLine[J]);
                              if  TW > StrToInt(ColWidths[J]) then
                                 ColWidths[J]:=IntToStr(TW);
                           end;
                        end
                        else
                        begin
                           ShowMessage(TxnLines.CommaText);
                        end;
                     end;
                  except
//                     on E:Exception do
//                        ShowMessage(E.Message+TxnLines.Text);
                  end;
               end;
               MessageData.Free;
            end;
         end
         else if (Flags and PensionMsg) = PensionMsg then
         begin
            MessageData:=FSMon.FileBlockMgr.GetMessage(Off,WS,MsgIndex);
            if MessageData <> nil then
            begin
               TxnLine.PackText:='';
               if MessageData.DestinationOffice <> 0 then
                  TxnLine.RecordID:=IntToStr(MsgIndex)+' '+IntToStr(MessageData.DestinationOffice)
               else
                  TxnLine.RecordID:=IntToStr(MsgIndex);
               TxnLine.WSNumber:=IntToStr(Integer(MessageData.GoodCRC))+' '+IntToStr(WS);
               TxnLine.RecType:='Pension';
               TxnLine.DateTime:=FormatDateTime('ddmmyy hhnnss',MessageData.SendBy-7);
               TxnLine.Period:=Trunc(MessageData.ExpiryDate-90)-DaysUntil_010198;
               TxnLine.Description:=FSMon.OfficeTitleFromCode(MessageData.DestinationOffice);
               TxnLine.Flags:=Flags;
               PensionData:=TPackStringList.Create;
               PensionData.PackText:=MessageData.MessageData;
               PensionPayment:=TMinPensionPayment.Create;
               AA:=0;
               PA:=0;
               for I:=0 to PensionData.Count-1 do
               begin
                  PensionPayment.PackData:=PensionData[I];
                  if (PensionPayment.PensionType = ptOAPArrears)
                  or (PensionPayment.PensionType = ptWWVArrears)
                  or (PensionPayment.PensionType = ptDCAArrears) then
                     AA:=AA+PensionPayment.Amount
                  else
                     PA:=PA+PensionPayment.Amount;
               end;
               PensionPayment.Free;
               TxnLine.TxnValue:=AA;
               TxnLine.Price:=PA;
               TxnLine.Quantity:=PensionData.Count;
               PensionData.Free;
   //            TxnLine.DomInfo:=MessageData.MessageData;
               Items.Add(TxnLine.PackText);
               while ColWidths.Count < TxnLine.Count do 
                  ColWidths.Add('0');
               for J:=0 to TxnLine.Count-1 do
               begin
                  TW:=Canvas.TextWidth(TxnLine[J]);
                  if  TW > StrToInt(ColWidths[J]) then
                     ColWidths[J]:=IntToStr(TW);
               end;
               MessageData.Free;
            end;     
         end
         else if (Flags and MoneyOrderMsg) = MoneyOrderMsg then
         begin
            MessageData:=FSMon.FileBlockMgr.GetMessage(Off,WS,MsgIndex);
            if MessageData <> nil then
            begin
               TxnLine.PackText:='';
               if MessageData.DestinationOffice <> 0 then
                  TxnLine.RecordID:=IntToStr(MsgIndex)+' '+IntToStr(MessageData.DestinationOffice)
               else
                  TxnLine.RecordID:=IntToStr(MsgIndex);
               TxnLine.WSNumber:=IntToStr(Integer(MessageData.GoodCRC))+' '+IntToStr(WS);
               TxnLine.RecType:='MoneyOrder';
               TxnLine.DateTime:=FormatDateTime('ddmmyy hhnnss',MessageData.SendBy-7);
               TxnLine.Period:=Trunc(MessageData.ExpiryDate-90)-DaysUntil_010198;
               TxnLine.Description:=FSMon.OfficeTitleFromCode(MessageData.DestinationOffice);
               TxnLine.Flags:=Flags;
               TxnLine.TxnValue:=0;
               TxnLine.Price:=0;
               TxnLine.Quantity:=0;
               TxnLine.DomInfo:=MessageData.MessageData;
               Items.Add(TxnLine.PackText);
               while ColWidths.Count < TxnLine.Count do 
                  ColWidths.Add('0');
               for J:=0 to TxnLine.Count-1 do
               begin
                  TW:=Canvas.TextWidth(TxnLine[J]);
                  if  TW > StrToInt(ColWidths[J]) then
                     ColWidths[J]:=IntToStr(TW);
               end;
               MessageData.Free;
            end;     
         end;     
      except
      end;
   end;
   for J:=0 to ColWidths.Count-1 do
   begin
      TW:=StrToInt(ColWidths[J])+10;
      ColWidths[J]:=IntToStr(TW);
   end;
   Items.EndUpdate;
   TxnLines.Free;
   TxnLine.Free;
   Status.Free;
end;
procedure DrawCLine(Canvas:TCanvas;Index:Integer;Rect:TRect;Colour:TColor);
var
   BC,PC:TColor;
begin
   PC:=Canvas.Pen  .Color;
   BC:=Canvas.Brush.Color;
   Canvas.Pen  .Color:=Colour;
   Canvas.Brush.Color:=Colour;
   Canvas.PolyGon([Point(Rect.Left+Index*4,Rect.Top)     ,Point(Rect.Left+Index*4,Rect.Bottom),
                    Point(Rect.Left+Index*4+3,Rect.Bottom),Point(Rect.Left+Index*4+3,Rect.Top),
                    Point(Rect.Left+Index*4,Rect.Top)]);
   Canvas.Pen  .Color:=PC;
   Canvas.Brush.Color:=BC;
end;
procedure DrawItem(Items:TStrings;Canvas:TCanvas;Index:Integer;Rect:TRect;State:TOwnerDrawState;ColWidths:TTxnLogLineFlags);
var                       
   TxnLine:TTxnLogLineFlags;
   J,LOfs:Integer;
   BC:TColor;
   S:String;
   DomInfoLines:TDomInfoLines;
   DomInfoLine:TDomInfoLine;
begin
   TxnLine:=TTxnLogLineFlags.Create;
   TxnLine.PackText:=Items[Index];
   BC:=Canvas.Brush.Color;
   with Canvas do
   begin
      if not (odSelected in State) then
      begin
         if (TxnLine.RecType = 'TxnLine') 
         or (TxnLine.RecType = 'TxnTotal')
         or (TxnLine.RecType = 'MOPaid')
         or (TxnLine.RecType = 'MOIssue')
         or (TxnLine.RecType = 'SaveStk')
         or (TxnLine.RecType = 'StockUsed') then    
            Brush.Color:=$00CEFDF8
         else if (TxnLine.RecType = 'AppStart')
         or (TxnLine.RecType = 'AppEnd') then
            Brush.Color:=clAqua
         else if (TxnLine.RecType = 'StartDay')     
         or (TxnLine.RecType = 'EndDay') then 
            Brush.Color:=clYellow
         else if (TxnLine.RecType = 'Pension') then
            Brush.Color:=$00FFE0E0
         else if (TxnLine.RecType = 'Money Order') then
            Brush.Color:=$00C0FFC0
         else if (index = 0) then 
            Brush.Color:=clSilver;
      end;   
      FillRect(Rect);   
      
      if not (odSelected in State) then
      begin
         if TxnLine.RecType = 'StockTx' then
            Font.Color:=clNavy
         else if TxnLine.RecType = 'SaveStk' then
            Font.Color:=clRed
         else if (TxnLine.RecType = 'TxnLine') and (TxnLine.RecIndex = 0) then
            Font.Color:=clRed
         else if (TxnLine.RecType = 'TxnTotal') then
            Font.Color:=clGreen
         else if (TxnLine.RecType = 'StockUsed') then
            Font.Color:=clBlue
         else if (TxnLine.RecType = 'MOPaid') or (TxnLine.RecType = 'MOIssue') then
            Font.Color:=clMaroon
         else if (TxnLine.RecType = 'MBlkStart') or (TxnLine.RecType = 'MBlkEnd') then
            Font.Color:=clSilver
         else if (TxnLine.RecType = 'Pension') then
            Font.Color:=clNavy;
      end;  
      
      LOfs:=Rect.Left;
      if not VarIsEmpty(TxnLine.Flags) and (TxnLine.Flags <> '') then
      begin                                                                   
         if (TxnLine.Flags and TransactionMsg   ) <> 0 then DrawCLine(Canvas, 0,Rect,clYellow );
         if (TxnLine.Flags and PensionMsg       ) <> 0 then DrawCLine(Canvas, 1,Rect,clBlue   );
         if (TxnLine.Flags and MoneyOrderMsg    ) <> 0 then DrawCLine(Canvas, 2,Rect,clGreen  );
         if (TxnLine.Flags and MessageProcessed ) <> 0 then DrawCLine(Canvas, 3,Rect,clMaroon );
         if (TxnLine.Flags and MessageTransfered) <> 0 then DrawCLine(Canvas, 4,Rect,clAqua	 );
         if (TxnLine.Flags and TransferMsg      ) <> 0 then DrawCLine(Canvas, 5,Rect,clFuchsia);
         if (TxnLine.Flags and MessageHasGoodCRC) <> 0 then DrawCLine(Canvas, 6,Rect,clOrange );
         if (TxnLine.Flags and BadMessageBlock  ) <> 0 then DrawCLine(Canvas, 7,Rect,clRed    );
         if (TxnLine.Flags and MessageCompressed) <> 0 then DrawCLine(Canvas, 8,Rect,clLime	 );
         if (TxnLine.Flags and PenDataProcessed ) <> 0 then DrawCLine(Canvas, 9,Rect,clBlue   );
         if (TxnLine.Flags and MODataProcessed  ) <> 0 then DrawCLine(Canvas,10,Rect,clGreen  );
{
         if (TxnLine.Flags and PBoxDataProcessed) <> 0 then DrawCLine(Canvas,11,Rect,clMaroon );
         if (TxnLine.Flags and ConfigurationMsg ) <> 0 then DrawCLine(Canvas,12,Rect,clYellow );
         if (TxnLine.Flags and StatusMsg        ) <> 0 then DrawCLine(Canvas,13,Rect,clBlue   );
         if (TxnLine.Flags and StockMsg         ) <> 0 then DrawCLine(Canvas,14,Rect,clGreen  );
         if (TxnLine.Flags and RegistryMsg      ) <> 0 then DrawCLine(Canvas,15,Rect,clNavy	 );
         if (TxnLine.Flags and POBoxMsg         ) <> 0 then DrawCLine(Canvas,16,Rect,clMaroon );
         if (TxnLine.Flags and PhilMsg          ) <> 0 then DrawCLine(Canvas,17,Rect,clFuchsia);
         if (TxnLine.Flags and UserMsg          ) <> 0 then DrawCLine(Canvas,18,Rect,clLime	 );
         if (TxnLine.Flags and MailEventMsg     ) <> 0 then DrawCLine(Canvas,19,Rect,clRed	 ); 
}
      end;                                                                           
//      Inc(LOfs,80);
      Inc(LOfs,42);
      
      TextOut(LOfs+1,Rect.Top+1,TxnLine.RecordID);
      PolyLine([Point(LOfs+ColWidths.RecordID-5,Rect.Top),Point(LOfs+ColWidths.RecordID-5,Rect.Bottom)]);
      Inc(LOfs,Integer(ColWidths.RecordID));
      
      TextOut(LOfs+1,Rect.Top+1,TxnLine.WSNumber);
      PolyLine([Point(LOfs+ColWidths.WSNumber-5,Rect.Top),Point(LOfs+ColWidths.WSNumber-5,Rect.Bottom)]);
      Inc(LOfs,Integer(ColWidths.WSNumber));
         
      TextOut(LOfs+1,Rect.Top+1,TxnLine.DateTime);
      PolyLine([Point(LOfs+ColWidths.DateTime-5,Rect.Top),Point(LOfs+ColWidths.DateTime-5,Rect.Bottom)]);
      Inc(LOfs,Integer(ColWidths.DateTime));
         
      TextOut(LOfs+1,Rect.Top+1,TxnLine.Period);
      PolyLine([Point(LOfs+ColWidths.Period-5,Rect.Top),Point(LOfs+ColWidths.Period-5,Rect.Bottom)]);
      Inc(LOfs,Integer(ColWidths.Period));
         
      TextOut(LOfs+1,Rect.Top+1,TxnLine.RecType);
      PolyLine([Point(LOfs+ColWidths.RecType-5,Rect.Top),Point(LOfs+ColWidths.RecType-5,Rect.Bottom)]);
      Inc(LOfs,Integer(ColWidths.RecType));
         
      TextOut(LOfs+1,Rect.Top+1,TxnLine.Description);
      PolyLine([Point(LOfs+ColWidths.Description-5,Rect.Top),Point(LOfs+ColWidths.Description-5,Rect.Bottom)]);
      Inc(LOfs,Integer(ColWidths.Description));
         
      TextOut(LOfs-10+ColWidths.Quantity-TextWidth(TxnLine.Quantity),Rect.Top+1,TxnLine.Quantity);
      PolyLine([Point(LOfs+ColWidths.Quantity-5,Rect.Top),Point(LOfs+ColWidths.Quantity-5,Rect.Bottom)]);
      Inc(LOfs,Integer(ColWidths.Quantity));
         
      TextOut(LOfs-10+ColWidths.Price-TextWidth(TxnLine.Price),Rect.Top+1,TxnLine.Price);
      PolyLine([Point(LOfs+ColWidths.Price-5,Rect.Top),Point(LOfs+ColWidths.Price-5,Rect.Bottom)]);
      Inc(LOfs,Integer(ColWidths.Price));
         
      TextOut(LOfs-10+ColWidths.TxnValue-TextWidth(TxnLine.TxnValue),Rect.Top+1,TxnLine.TxnValue);
      PolyLine([Point(LOfs+ColWidths.TxnValue-5,Rect.Top),Point(LOfs+ColWidths.TxnValue-5,Rect.Bottom)]);
      Inc(LOfs,Integer(ColWidths.TxnValue));
         
      TextOut(LOfs+1,Rect.Top+1,TxnLine.Teller);
      PolyLine([Point(LOfs+ColWidths.Teller-5,Rect.Top),Point(LOfs+ColWidths.Teller-5,Rect.Bottom)]);
      Inc(LOfs,Integer(ColWidths.Teller));
         
      TextOut(LOfs+1,Rect.Top+1,TxnLine.Office);
      PolyLine([Point(LOfs+ColWidths.Office-5,Rect.Top),Point(LOfs+ColWidths.Office-5,Rect.Bottom)]);
      Inc(LOfs,Integer(ColWidths.Office));
      
      TextOut(LOfs+1,Rect.Top+1,TxnLine.PLU);
      PolyLine([Point(LOfs+ColWidths.PLU-5,Rect.Top),Point(LOfs+ColWidths.PLU-5,Rect.Bottom)]);
      Inc(LOfs,Integer(ColWidths.PLU));
         
      TextOut(LOfs+1,Rect.Top+1,TxnLine.Prod);
      PolyLine([Point(LOfs+ColWidths.Prod-5,Rect.Top),Point(LOfs+ColWidths.Prod-5,Rect.Bottom)]);
      Inc(LOfs,Integer(ColWidths.Prod));
         
      TextOut(LOfs+1,Rect.Top+1,TxnLine.Info);
      PolyLine([Point(LOfs+ColWidths.Info-5,Rect.Top),Point(LOfs+ColWidths.Info-5,Rect.Bottom)]);
      Inc(LOfs,Integer(ColWidths.Info));
         
      TextOut(LOfs+1,Rect.Top+1,TxnLine.Ident);
      PolyLine([Point(LOfs+ColWidths.Ident-5,Rect.Top),Point(LOfs+ColWidths.Ident-5,Rect.Bottom)]);
      Inc(LOfs,Integer(ColWidths.Ident));
         
      if (TxnLine.RecType = 'TxnLine') and (TxnLine.RecIndex = 0) then
      begin
         PolyLine([Point(Rect.Left,Rect.Top),Point(LOfs-5,Rect.Top)]);
      end
      else if (TxnLine.RecType = 'TxnTotal') then
      begin
         PolyLine([Point(Rect.Left,Rect.Bottom-3),Point(LOfs-5,Rect.Bottom-3)]);
         PolyLine([Point(Rect.Left,Rect.Bottom-2),Point(LOfs-5,Rect.Bottom-2)]);
      end;
      if not VarIsEmpty(TxnLine.DomInfo) then
      begin
         if (TxnLine.RecType <> 'SaveStk') then
         begin
            DomInfoLines:=TDomInfoLines.Create;
            DomInfoLine:=TDomInfoLine.Create;
            DomInfoLines.PackText:=TxnLine.DomInfo;
            for J:=0 to DomInfoLines.Count-1 do
            begin
               S:='';
               if Trim(DomInfoLines[J]) <> 'DomInfo' then
               begin
                  DomInfoLine.PackText:=DomInfoLines[J];
                  try
                     S:=DomInfoLine.Prompt+'='+DomInfoLine.Text+' ';
                  except
                     S:=DomInfoLines[J];
                  end;
               end;
               TextOut(LOfs+1,Rect.Top+1,S);
               Inc(LOfs,TextWidth(S));
            end;
//            Inc(LOfs,30);
//            TextOut(LOfs+1,Rect.Top+1,TxnLine.DomInfo);
            DomInfoLines.Free;
            DomInfoLine .Free;
         end
         else
         begin
            TextOut(LOfs+1,Rect.Top+1,'Stock definition data...');
         end;
      end;
   end;                                         
   TxnLine.Free;
   Canvas.Brush.Color:=BC;
end;
procedure MeasureItem(Items:TStrings;Index:Integer;var Height:Integer);
//var
//   TxnLine:TTxnLogLineFlags;
begin
   Height:=16;
{   if Index = 0 then 
      Height:=18
   else
   begin
      TxnLine:=TTxnLogLineFlags.Create;
      TxnLine.PackText:=Items[Index];
      if (TxnLine.RecType = 'TxnTotal') then  Height:=17;
      TxnLine.Free
   end;}
end;
{TMsgViewBox}
constructor TMsgViewBox.Create(AOwner:TComponent);
begin
   inherited Create(AOwner);
   Color:=clWindow;
   FItems:=TPackStringList.Create;
   FItems.OnChange:=ItemsChanged;
   FItemHeight:=13;
   FVertScrollBar:=TScrollBar.Create(Self);
   InsertControl(FVertScrollBar);
   FVertScrollBar.Align:=alRight;
   FVertScrollBar.Kind:=sbVertical;
   FVertScrollBar.Visible:=False;
   FVertScrollBar.Min:=0;
   FVertScrollBar.Position:=0;
   FVertScrollBar.OnChange:=VSBChanged;
   FHorizScrollBar:=TScrollBar.Create(Self);
   InsertControl(FHorizScrollBar);
   FHorizScrollBar.Align:=alBottom;
   FHorizScrollBar.Kind:=sbHorizontal;
   FHorizScrollBar.Visible:=False;
   FHorizScrollBar.Min:=0;
   FHorizScrollBar.Max:=100;
   FHorizScrollBar.SmallChange:=1;
   FHorizScrollBar.LargeChange:=10;
   FHorizScrollBar.Position:=0;
   FHorizScrollBar.OnChange:=HSBChanged;
end;                             
destructor TMsgViewBox.Destroy;
begin
   RemoveControl(FHorizScrollBar);
   FHorizScrollBar.Free;
   FHorizScrollBar:=nil;
   RemoveControl(FVertScrollBar);
   FVertScrollBar.Free;
   FVertScrollBar:=nil;
   FItems.Free;  
   FItems:=nil;
   inherited Destroy;
end;                
procedure TMsgViewBox.VSBChanged(Sender: TObject);
var
   R:TRect;
begin
{   if FVertScrollBar.Position > ((FVertScrollBar.Max+2) -(Height div 16)) then
   begin
      FVertScrollBar.Position:=(FVertScrollBar.Max+2) -(Height div 16);
      Exit;
   end;}
   FTopIndex:=FVertScrollBar.Position;
   R:=Bounds(0,0,Width-FVertScrollBar.Width,Height);
   InvalidateRect(Handle,@R,True);
end;
procedure TMsgViewBox.HSBChanged(Sender: TObject);
var
   R:TRect;
begin
   FLeftIndex:=FHorizScrollBar.Position;
   R:=Bounds(0,0,Width-FVertScrollBar.Width,Height-FHorizScrollBar.Height);
   InvalidateRect(Handle,@R,True);
end;
procedure TMsgViewBox.ItemsChanged(Sender: TObject);
var
   R:TRect;
begin
   if FVertScrollBar.Visible <> (FItems.Count > 0) then
      FVertScrollBar.Visible:=FItems.Count > 0;
   FHorizScrollBar.Visible:=FVertScrollBar.Visible;
   if FItems.Count > ((Height div 16)-2) then
      FVertScrollBar.Max:=FItems.Count-((Height div 16)-2)
   else
      FVertScrollBar.Max:=FItems.Count;
   FVertScrollBar.LargeChange:=Height div FItemHeight;
   if FItems.Count = 0 then
      Repaint
   else
   begin
      R:=Bounds(0,0,Width-FVertScrollBar.Width,Height-FHorizScrollBar.Height);
      InvalidateRect(Handle,@R,True);
   end;
end;
function TMsgViewBox.GetItem(Index:Integer):String;
begin
   if (Index >= 0) and (Index < FItems.Count) then
      Result:=FItems[Index]
   else
      Result:='';
end;
procedure TMsgViewBox.SetItem(Index:Integer;Value:String);
begin
   if (Index >= 0) and (Index < FItems.Count) then
      FItems[Index]:=Value;
end;             
function TMsgViewBox.GetItems:TStrings;
begin
   Result:=FItems;
end;
procedure TMsgViewBox.SetItems(Value:TStrings);
begin
   FItems.Assign(Value);
end;
procedure TMsgViewBox.Paint;
var
   I:Integer;
   YOfs:Integer;
   ItemHgt,ItemWid:Integer;
   R:TRect;
begin
   R:=Bounds(1,1,Width-2,Height-1);
   if FVertScrollBar.Visible then
      R.Right:=R.Right-(FVertScrollBar.Width+1);
   ItemHgt:=FItemHeight;
   Canvas.Font:=Self.Font;
   Canvas.Brush:=Self.Brush;
   ItemWid:=R.Right-R.Left;
   with Canvas do
   begin
      InflateRect(R,-1,-1);
      YOfs:=0;
      I:=0;
      while YOfs < Height do
      begin
         if (I+FTopIndex) < FItems.Count then
         begin
            if Assigned(FOnMeasureItem) then
               FOnMeasureItem(Self,I+FTopIndex,ItemHgt,ItemWid);
            if Assigned(FOnDrawItem) then
            begin
               FOnDrawItem(Self,I+FTopIndex,Rect(R.Left-(FHorizScrollBar.Position*50),R.Top+YOfs,R.Right,R.Top+YOfs+ItemHgt),[]);
               Canvas.Font:=Self.Font;
               Canvas.Brush:=Self.Brush;
            end
            else
               TextOut(0,YOfs,FItems[I]);
         end
         else
         begin
            ItemHgt:=Height-YOfs;
            FillRect(Bounds(R.Left,R.Top+YOfs,R.Right,ItemHgt));
         end;
         Inc(YOfs,ItemHgt);
         Inc(I);
      end;
      InflateRect(R,1,1);
      Pen.Color:=clBlack;
      PolyLine([Point(R.Left,R.Top),Point(R.Right,R.Top),Point(R.Right,R.Bottom),Point(R.Left,R.Bottom),Point(R.Left,R.Top)]);
   end; 
end;  
procedure TMainForm.MessageListDrawItem(MsgViewBox:TMsgViewBox; Index: Integer;
  InRect: TRect; State: TOwnerDrawState);
begin
   DrawItem(MsgViewBox.Items,MsgViewBox.Canvas,Index,InRect,State,ColWidths);
end;
procedure TMainForm.MessageListMeasureItem(MsgViewBox:TMsgViewBox;Index:Integer;var Height,Width:Integer);
var
   I:Integer;
begin
   MeasureItem(MsgViewBox.Items,Index,Height);
   if ColWidths.Count = 18 then
   begin
      Width:=0;
      for I:=0 to ColWidths.Count-1 do
         Width:=Width+StrToIntDef(ColWidths[I],1);
      ColWidths.Add(IntToStr(Width));
   end
   else
   begin
      Width:=StrToIntDef(ColWidths[ColWidths.Count-1],1);
   end;
end;
function GetStatus:String;
var
  FA:Integer;
  SL:TPackStringList;
const
   LastFileAge:Integer=-1;
   LastData:String='';
begin
   FA:=FileAge(LogFileDirectory+'\'+StatusFile);
   try    
      if (FA <> LastFileAge) and FileExists(LogFileDirectory+'\'+StatusFile) then
      begin
         SL:=TPackStringList.Create;
         SL.LoadFromFile(LogFileDirectory+'\'+StatusFile);
         LastData:=SL.Text;
         SL.Free;
      end;
   except
   end;
   Result:=LastData;
end;
procedure TMainForm.PaintBox1Paint(Sender: TObject);
var
   StatusBits:TStatusBits;
   SL:TPackStringList;
   WSList:TPackStringList;
   AWidth,Interval,I:Integer;
   WSIdx:Integer;
begin
   PaintBox1.Canvas.Font:=Panel1.Font;
   PaintBox1.Canvas.Pen.Color:=Panel1.Font.Color;
   PaintBox1.Canvas.Brush.Color:=Panel1.Color;
   if ServiceRunning then
   begin
      SL:=TPackStringList.Create;
      SL.Text:=GetStatus;
      if (SL.Count > 0) then
      begin
         PaintBox1.Canvas.FillRect(PaintBox1.ClientRect);
         StatusBits:=TStatusBits.Create;
         StatusBits.State:=Trim(SL.Text);
         AWidth:=StatusBits.Width;
         Interval:=1;
         while AWidth > 10 do
         begin
            Interval:=Interval*10;
            AWidth:=AWidth div 10;
         end;
         WSList:=TPackStringList.Create;
         for I:=0 to StatusBits.WSList.Count-1 do
         begin
            if (WSList.IndexOf(Copy(StatusBits.WSList[I],1,6)) = -1) then
               WSList.Add(Copy(StatusBits.WSList[I],1,6));
         end;
         WSList.Sort;
         Canvas.Pen.Color:=clBlack;
         StatusBits.DrawOn(ThisOfficeID,PaintBox1.Canvas,PaintBox1.ClientRect,0,Interval,False,Workstation,ThisOfficeID,WSList);
         SL.Clear;
         for WSIdx:=0 to WSList.Count-1 do
            SL.Add('O'+IntToStr(StrToInt('$'+Copy(WSList[WSIdx],1,4)))+' W'+IntToStr(StrToInt('$'+Copy(WSList[WSIdx],5,2))));
         if (NumWSLines <> WSList.Count+1) or (SL.Text <> ListBox1.Items.Text) then
         begin
            NumWSLines:=WSList.Count+1;
            PaintBox1.Height:=NumWSLines*PaintBox1.Canvas.TextHeight('Wg');
            ListBox1.Items.Clear;
            for WSIdx:=0 to WSList.Count-1 do
               ListBox1.Items.Add('O'+IntToStr(StrToInt('$'+Copy(WSList[WSIdx],1,4)))+' W'+IntToStr(StrToInt('$'+Copy(WSList[WSIdx],5,2))));
         end;
         StatusBits.Free;
         WSList.Free;
      end;
      SL.Free;
   end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  WSIdx:Integer;
  Status:TStatusBits;
  FileStatusMon:TFileStatusMon;
  X,Y:Integer;
begin            
   CoolTrayIcon:=TCoolTrayIcon.Create(nil);
   InsertComponent(CoolTrayIcon);
   CoolTrayIcon.icon:=Application.Icon;
   CoolTrayIcon.Enabled:=True;
   CoolTrayIcon.IconVisible:=True;
   CoolTrayIcon.PopupMenu:=PopupMenu1;
   CoolTrayIcon.OnMouseDown:=TrayIconMouseDown;
   Application.Title:='Shirika Service Controller';
   ForceDirectories(LogFileDirectory);
   ThisOfficeID:=StrToIntDef(GetGPCSRegString('OfficeInfo','Office ID','3201'),3201);
   Workstation :=StrToIntDef(GetGPCSRegString('WorkStation','Ident','10'),10);
   NumWSLines:=-1;
   MessageList:=TMsgViewBox.Create(nil);
   Panel3.InsertControl(MessageList);
   MessageList.Align:=alClient;
   MessageList.Color:=clWhite;
   MessageList.OnDrawItem:=MessageListDrawItem;
   MessageList.OnMeasureItem:=MessageListMeasureItem;
   MessageList.OnEnter:=TabSheet3Enter;
   MessageList.OnExit :=TabSheet3Exit ;

   FileStatusMon:=TFileStatusMon.Create(nil);
   FileStatusMon.Active:=False;
//   TTxnTransfer.FindPensionMessages(FileStatusMon);
//   TTxnTransfer.FindMOMessages(FileStatusMon);
   ColWidths:=TTxnLogLineFlags.Create;
   
   Status:=TStatusBits.Create;
   Status.State:=FileStatusMon.FileBlockMgr.GetStatus;

   for WSIdx:=0 to Status.Count-1 do
     ListBox1.Items.Add('O'+IntToStr(Status.OfficeCode(WSIdx))+' W'+IntToStr(Status.WSNumber(WSIdx)));
   Status.Free;
   FileStatusMon.Free;
   Image1.Picture.Bitmap.Width:=320;
   Image1.Picture.Bitmap.Height:=28;
   with Image1.Picture.Bitmap.Canvas do
   begin
      Brush.Color:=clBtnFace;
      FillRect(Bounds(0,0,Image1.Picture.Bitmap.Width,Image1.Picture.Bitmap.Height));
      Font.Name:='Small Fonts';
      Font.Size:=6;
      X:=0; Y:=-2;
      Font.Color:=clYellow ; TextOut(X,Y,'TransactionMsg'   ); Inc(Y,TextHeight('Wg')-1);
      Font.Color:=clBlue   ; TextOut(X,Y,'PensionMsg'       ); Inc(Y,TextHeight('Wg')-1);
      Font.Color:=clGreen  ; TextOut(X,Y,'MoneyOrderMsg'    ); 
      X:=70; Y:=0;
      Font.Color:=clMaroon ; TextOut(X,Y,'MessageProcessed' ); Inc(Y,TextHeight('Wg')-1);
      Font.Color:=clAqua   ; TextOut(X,Y,'MessageTransfered'); Inc(Y,TextHeight('Wg')-1);
      Font.Color:=clFuchsia; TextOut(X,Y,'TransferMsg'      );
      X:=150; Y:=0;
      Font.Color:=clOrange ; TextOut(X,Y,'MessageHasGoodCRC'); Inc(Y,TextHeight('Wg')-1);
      Font.Color:=clRed    ; TextOut(X,Y,'BadMessageBlock'  ); Inc(Y,TextHeight('Wg')-1);
      Font.Color:=clLime   ; TextOut(X,Y,'MessageCompressed');
      X:=240; Y:=0;
      Font.Color:=clBlue   ; TextOut(X,Y,'PenDataProcessed' ); Inc(Y,TextHeight('Wg')-1);
      Font.Color:=clGreen  ; TextOut(X,Y,'MODataProcessed'  );
   end;
   Image1.Visible:=False;
end;                    

procedure TMainForm.FormResize(Sender: TObject);
begin
   PaintBox1.Width:=ScrollBox2.ClientWidth;
   if NumWSLines > 0 then
      PaintBox1.Height:=NumWSLines*PaintBox1.Canvas.TextHeight('Wg');
end;

procedure TMainForm.CheckMemoData;
var
   CurrentState:Integer;
   FA:Integer;
   SL:TStringList;
   Loaded:Boolean;
const
   State:Integer = -1;
   LastFileDate:Integer =-1;
begin
   if not ServiceRunning then
   begin
      if Memo1.Lines.Count > 0 then
         Memo1.Lines.Clear;
      StatInd.Color:=clBtnFace;
      Exit;
   end;
   Loaded:=False;
   SL:=TStringList.Create;
   FA:=FileAge(LogFileDirectory+'\'+ContactFile);
   if (FA <> LastFileDate) and FileExists(LogFileDirectory+'\'+ContactFile) then
   begin
      LastFileDate:=FA;
      try
         SL.LoadFromFile(LogFileDirectory+'\'+ContactFile);
         Loaded:=True;
         SL.Text:=Trim(SL.Text);
      except
      end;
   end;
   if (SL.Count > 0) and (SL[0] <> '') and (SL[0][1] = '*') then
   begin
      CurrentState:=StrToIntDef('$'+Copy(SL[0],2,8),0);
      SL.Delete(0);
      if CurrentState <> State then
         if Visible then Windows.Beep(3000,5);
      State:=CurrentState;
      if State = 0 then 
      begin
         Edit1.Text:='Shirika is running.';
         StatInd.Color:=clBtnFace;
      end
      else
      begin
         case (State and 3) of
            1 : begin Edit1.Text:='TxnLog writes due';              StatInd.Color:=clRed;    end;
            2 : begin Edit1.Text:='New Messages due';               StatInd.Color:=clYellow; end;
            3 : begin Edit1.Text:='TxnLog writes and Messages due'; StatInd.Color:=clOrange; end;
         end;
         if ((State and 4) <> 0) then
            begin Edit1.Text:='Rebuilding Txnlog'; StatInd.Color:=clMaroon; end
         else if ((State and 8) <> 0) then
            begin Edit1.Text:='Finding Messages'; StatInd.Color:=clGreen;    end 
         else if ((State and 16) <> 0) then
            begin Edit1.Text:='Processing Messages'; StatInd.Color:=clNavy;  end
         else if ((State and 32) <> 0) then
            begin Edit1.Text:='Monitoring Txnlog'; StatInd.Color:=clRed;    end;
      end;
   end;
   if Loaded and (Memo1.Lines.Text <> SL.Text) then
   begin
      Memo1.Lines.Text:=Trim(SL.Text);
      Memo1.SelStart:=Length(Memo1.Lines.Text)-1;
      Memo1.SelLength:=0;
   end;
   SL.Free;
end;
procedure TMainForm.Timer1Timer(Sender: TObject);
var
   ServiceStatus:TServiceStatus;
   S:String;
   SStat:String;
const
   LastStatus   :Integer = -1;
   CallCounter  :Integer = -1;
   LastStatusStr:String  = '';
begin
   S:=GetStatus;
   if S <> LastStatusStr then
   begin
      LastStatusStr:=S;
      PaintBox1.Invalidate;
   end;
   Memo1.Color:=Panel2.Color;
   
   Inc(CallCounter);
   if (CallCounter mod 8) = 0 then // check service status every 2 seconds
   begin
      ServiceStatus:=CtrlService(ctStatus);
      case ServiceStatus.dwCurrentState of   
         0                        : begin
                                       SStat:='Shirika is not installed.';
                                       Install.Enabled:=True;
                                       Start  .Enabled:=False;
                                       Stop   .Enabled:=False;
                                       Remove .Enabled:=False;
                                       ServiceRunning:=False;
                                       Application.Icon.Assign(BImage.Picture.Icon);
                                    end;
         SERVICE_STOPPED	       : begin
                                       SStat:='Shirika is not running.';
                                       Install.Enabled:=False;
                                       Start  .Enabled:=True;
                                       Stop   .Enabled:=False;
                                       Remove .Enabled:=True;
                                       ServiceRunning:=False;
                                       Application.Icon.Assign(RImage.Picture.Icon);
                                    end;
         SERVICE_START_PENDING	 : begin  
                                       SStat:='Shirika is starting.';
                                       ServiceRunning:=False;
                                       Install.Enabled:=False;
                                       Start  .Enabled:=False;
                                       Stop   .Enabled:=False;
                                       Remove .Enabled:=False;
                                       Application.Icon.Assign(YImage.Picture.Icon);
                                    end;                   
         SERVICE_STOP_PENDING	    : begin  
                                       SStat:='Shirika is stopping.';
                                       ServiceRunning:=False;
                                       Install.Enabled:=False;
                                       Start  .Enabled:=False;
                                       Stop   .Enabled:=False;
                                       Remove .Enabled:=False;
                                       Application.Icon.Assign(YImage.Picture.Icon);
                                    end;                   
         SERVICE_RUNNING	       : begin  
                                       SStat:='Shirika is running.';
                                       ServiceRunning:=True;
                                       Install.Enabled:=False;
                                       Start  .Enabled:=False;
                                       Stop   .Enabled:=True;
                                       Remove .Enabled:=False;
                                       Application.Icon.Assign(GImage.Picture.Icon);
                                    end;
         SERVICE_CONTINUE_PENDING : begin  
                                       SStat:='Shirika continue is pending.';
                                       ServiceRunning:=False;
                                       Application.Icon.Assign(YImage.Picture.Icon);
                                    end;                     
         SERVICE_PAUSE_PENDING	 : begin  
                                       SStat:='Shirika pause is pending.';
                                       ServiceRunning:=False;
                                       Application.Icon.Assign(YImage.Picture.Icon);
                                    end;                     
         SERVICE_PAUSED	          : begin
                                       SStat:='Shirika is paused.';
                                       ServiceRunning:=False;
                                       Application.Icon.Assign(YImage.Picture.Icon);
                                    end;                     
         else	                     begin
                                       Install.Enabled:=False;
                                       Start  .Enabled:=True;
                                       Stop   .Enabled:=False;
                                       Remove .Enabled:=True;
                                       SStat:='Stopped '+IntToHex(ServiceStatus.dwCurrentState,8);
                                       ServiceRunning:=False;
                                       Application.Icon.Assign(RImage.Picture.Icon);
                                    end;
      end;
      if LastStatus <> ServiceStatus.dwCurrentState then
      begin
         CoolTrayIcon.icon:=Application.Icon;
         CoolTrayIcon.Hint:=SStat;
         LastStatus:=ServiceStatus.dwCurrentState;
         Edit1.Text:=SStat;
         PaintBox1.Invalidate;
         Install1.Enabled:=Install.Enabled;
         Start1.Enabled:=Start.Enabled;
         Stop1.Enabled:=Stop.Enabled;
         Uninstall1.Enabled:=Remove.Enabled;
      end;
   end;
   CheckMemoData;
   Application.Title:=Edit1.Text;
end;

procedure TMainForm.InstallClick(Sender: TObject);
begin
   InstallService;
end;

procedure TMainForm.StartClick(Sender: TObject);
begin
   CtrlService(ctStart);
end;

procedure TMainForm.StopClick(Sender: TObject);
begin
   CtrlService(ctStop);
end;

procedure TMainForm.RemoveClick(Sender: TObject);
begin
   RemoveService;
end;

procedure TMainForm.Ecit1Click(Sender: TObject);
begin
   Close;
end;

procedure TMainForm.Status1Click(Sender: TObject);
begin
   PageControl1.ActivePage:=TabSheet1;
end;

procedure TMainForm.ContactLog1Click(Sender: TObject);
begin
   PageControl1.ActivePage:=TabSheet2;
end;

procedure TMainForm.StoreContents1Click(Sender: TObject);
begin
   PageControl1.ActivePage:=TabSheet3;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
   PaintBox1.Repaint;
   PaintBox1.Width:=ScrollBox2.ClientWidth;
   if NumWSLines > 0 then
      PaintBox1.Height:=NumWSLines*PaintBox1.Canvas.TextHeight('Wg');
end;

procedure TMainForm.ListBox1Click(Sender: TObject);
var
  FileStatusMon:TFileStatusMon;
begin
   if Listbox1.ItemIndex < 0 then Exit;
   FileStatusMon:=TFileStatusMon.Create(nil);
   FileStatusMon.Active:=False;
   PopulateLBFrom(Listbox1.ItemIndex,MessageList.Items,MessageList.Canvas,ColWidths,FileStatusMon,TStringList(Listbox1.Items.Objects[Listbox1.ItemIndex]),False);
   FileStatusMon.Free;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Application.Minimize;
   CoolTrayIcon.HideMainForm;
   Action:=caNone;
   if Application.Terminated then
   begin
      Application.Title:='Shirika Service Controller';
      Timer1.Enabled:=False;
      Action:=caFree;
   end;
end;

procedure TMainForm.TabSheet3Enter(Sender: TObject);
begin
   Image1.Visible:=True;
end;

procedure TMainForm.TabSheet3Exit(Sender: TObject);
begin
   Image1.Visible:=False;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
   CoolTrayIcon.Free;
   CoolTrayIcon:=nil;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
   Application.Title:='Shirika Service Controller';
   Application.Terminate;
   Close;
end;

procedure TMainForm.Show1Click(Sender: TObject);
begin
   if Visible then
   begin
      Application.Minimize;
      CoolTrayIcon.HideMainForm;
   end
   else
   begin
      CoolTrayIcon.ShowMainForm;
   end;
end;

procedure TMainForm.TrayIconMouseDown(Sender:TObject;Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
begin
   if Button = mbLeft then
      Show1Click(Sender);
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
   SetPSLRegString('Message Transfer','Last Rebuild','0');
end;
procedure TMainForm.ProgBar(PhaseNo,PhaseOf,Max,Pos:Integer);
var
   Divs:Integer;
begin
   try
      if Pos = 0 then 
      begin
         ProgressBar.Min:=0;              
         ProgressBar.Max:=Max;
         ProgressBar.Visible:=True;
      end
      else if Max = Pos+1 then 
      begin
         ProgressBar.Visible:=False;
      end;
      Divs:=Max div 200;
      if Divs = 0 then Divs:=100;
      if (Pos mod Divs) = 0 then
      begin
         ProgressBar.Position:=Pos;
         Application.ProcessMessages;
      end;          
      if (Pos div 100) = 0 then
         Application.ProcessMessages;
   except 
   end;
end;
procedure TMainForm.Button2Click(Sender: TObject);
begin
   CtrlService(ctStop);
   SpecialProcessing:=True;
   RebuildTxnlogAndStock(ProgBar);
   SpecialProcessing:=False;
end;

procedure TMainForm.Button3Click(Sender: TObject);
var
   MoneyOrders:TMoneyOrders;
begin
   MoneyOrders:=TMoneyOrders.Create;
   MoneyOrders.CheckTables('PSL');
   MoneyOrders.Free;
end;

procedure TMainForm.Edit2Change(Sender: TObject);
begin
   if Edit2.Text = 'Shirika' then 
   begin
      Button2.Visible:=True;
      Button3.Visible:=True;
      Button4.Visible:=True;
      Button5.Visible:=True;
      Button6.Visible:=True;
      Button7.Visible:=True;
      Button8.Visible:=True;
      Button9.Visible:=True;
   end       
   else
   begin
      Button2.Visible:=False;
      Button3.Visible:=False;
      Button4.Visible:=False;
      Button5.Visible:=False;
      Button6.Visible:=False;
      Button7.Visible:=False;
      Button8.Visible:=False;
      Button9.Visible:=False;
   end;                       
end;

procedure TMainForm.Button4Click(Sender: TObject);
var
   MoneyOrders:TMoneyOrders;
begin
   MoneyOrders:=TMoneyOrders.Create;
   MoneyOrders.CheckIndex('PSL');
   MoneyOrders.Free;
end;

procedure TMainForm.Button5Click(Sender: TObject);
begin
   if SD.Execute then
   begin
      RequestServiceData('SaveStockIDS',SD.FileName);
   end;
end;

procedure TMainForm.Button6Click(Sender: TObject);
begin
   if OD.Execute then
   begin
      RequestServiceData('LoadStockIDS',OD.FileName);
   end;
end;

procedure TMainForm.Button7Click(Sender: TObject);
begin
   Button7.Enabled:=False;
   RequestServiceData('RepairMessageStore','');
   Button7.Enabled:=True;
end;

procedure TMainForm.Button8Click(Sender: TObject);
begin
   OD.DefaultExt:='CSV';
   OD.Filter:='CSV Files|*.CSV|All Files|*.*';
   if OD.Execute then
      RequestServiceData('UpdateStockCSV',OD.FileName);
   OD.DefaultExt:='IDS';
   OD.Filter:='IDS Files|*.IDS|All Files|*.*';
end;

procedure TMainForm.Button9Click(Sender: TObject);
begin
   SD.DefaultExt:='CSV';
   SD.Filter:='CSV Files|*.CSV|All Files|*.*';
   if SD.Execute then
      RequestServiceData('SaveStockCSV',SD.FileName);
   SD.DefaultExt:='IDS';
   SD.Filter:='IDS Files|*.IDS|All Files|*.*';
end;

end.























              
