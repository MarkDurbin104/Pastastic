unit MSGSViewerFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls,PackStrListU,GPCSGUID,StringUtil,DirectoryU,
  MsgConfigU,StringWrapperU,MsgFileAccessU,StatusMonitorU,FileTxStatusU,OsmiumSupportU,
  checklst,DB,DBTables,Utils,FileCtrl,MsgFileMaintU,DTSocketU;

const
    clOrange = $000080FF;
    
type
  TTxnLogLineFlags = class(TTxnLogLine)
    public
     property Flags:Variant Index 17 read GetElement write SetElement;
  end;
  TMsgViewBox = class;
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
  TMSVForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Panel1: TPanel;
    Splitter1: TSplitter;
    CheckID: TCheckBox;
    CheckWS: TCheckBox;
    CheckDate: TCheckBox;
    CheckPeriod: TCheckBox;
    CheckType: TCheckBox;
    CheckDesc: TCheckBox;
    CheckQty: TCheckBox;
    CheckPrice: TCheckBox;
    CheckValue: TCheckBox;
    CheckUser: TCheckBox;
    CheckPLU: TCheckBox;
    CheckProd: TCheckBox;
    CheckInfo: TCheckBox;
    CheckIdent: TCheckBox;
    CheckDomInfo: TCheckBox;
    Panel2: TPanel;
    VTList: TCheckListBox;
    VPList: TCheckListBox;
    Panel3: TPanel;
    Update: TCheckBox;
    Panel4: TPanel;
    UpdateP: TCheckBox;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    ListBox1: TListBox;
    TabSheet2: TTabSheet;
    Panel5: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button6: TButton;
    Panel6: TPanel;
    ListBox4: TListBox;
    OD: TOpenDialog;
    TabSheet3: TTabSheet;
    OfficeList: TListBox;
    Splitter4: TSplitter;
    Panel7: TPanel;
    Label1: TLabel;
    OCode: TEdit;
    OSCode: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    OPCode: TEdit;
    Label4: TLabel;
    OI3Code: TEdit;
    Label5: TLabel;
    OAccessVia: TEdit;
    Label6: TLabel;
    OAutomated: TEdit;
    Label7: TLabel;
    OName: TEdit;
    Label8: TLabel;
    OAddress: TEdit;
    Label9: TLabel;
    OPhone: TEdit;
    Label10: TLabel;
    OPOBox: TEdit;
    Label11: TLabel;
    TabSheet4: TTabSheet;
    POffices: TListBox;
    Pensions: TListBox;
    Button8: TButton;
    Button7: TButton;
    Button3: TButton;
    Button4: TButton;
    ProgressBar1: TProgressBar;
    Route: TButton;
    RouteMemo: TMemo;
    Button5: TButton;
    MergeWS: TEdit;
    Button9: TButton;
    Button10: TButton;
    CheckOffice: TCheckBox;
    OfficeCode: TEdit;
    Button11: TButton;
    Panel8: TPanel;
    Button12: TButton;
    TabSheet5: TTabSheet;
    Panel9: TPanel;
    Panel10: TPanel;
    MoneyOrders: TMemo;
    Button13: TButton;
    Button14: TButton;
    Stock: TTabSheet;
    Panel11: TPanel;
    Memo1: TMemo;
    Button15: TButton;
    TabSheet6: TTabSheet;
    Label12: TLabel;
    User: TEdit;
    Label13: TLabel;
    Pass: TEdit;
    Label14: TLabel;
    Alias: TEdit;
    Label15: TLabel;
    Query: TMemo;
    Host: TEdit;
    Label16: TLabel;
    Timeout: TEdit;
    Label17: TLabel;
    Results: TMemo;
    Label18: TLabel;
    Button16: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure CheckIDClick(Sender: TObject);
    procedure UpdateClick(Sender: TObject);
    procedure UpdatePClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ListBox4Click(Sender: TObject);
    procedure OfficeListClick(Sender: TObject);
    procedure POfficesClick(Sender: TObject);
    procedure PensionsDblClick(Sender: TObject);
    procedure PensionsClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure RouteClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure POfficesDblClick(Sender: TObject);
    procedure POfficesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button10Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
  private
    { Private declarations }
  public
     FileStatusMon:TFileStatusMon;
     ColWidths:TTxnLogLineFlags;
     TmpColWidths:TTxnLogLineFlags;
     MsgViewBox:TMsgViewBox;
     MessageList:TMsgViewBox;
     procedure MsgViewBoxDrawItem    (MsgViewBox:TMsgViewBox;Index:Integer;InRect:TRect;State:TOwnerDrawState);
     procedure MsgViewBoxMeasureItem (MsgViewBox:TMsgViewBox;Index:Integer;var Height,Width:Integer);
     procedure MessageListDrawItem   (MsgViewBox:TMsgViewBox;Index:Integer;InRect:TRect;State:TOwnerDrawState);
     procedure MessageListMeasureItem(MsgViewBox:TMsgViewBox;Index:Integer;var Height,Width:Integer);
     procedure ProgBar(PhaseNo,PhaseOf,Max,Pos:Integer);
     procedure Refresh;
     procedure ProcessList(List:String);
  end;
  TStringObject = class(TObject)
  public
    Value:String;
    constructor Create(Str:String);
  end;

var
  MSVForm: TMSVForm;

implementation
uses
   MOSupportU,MODefinitionsU;
{$R *.DFM}

constructor TStringObject.Create(Str:String);
begin
   inherited Create;
   Value:=Str;
end;


procedure PopulateLBFrom(WSIdx:Integer;Items:TStrings;Canvas:TCanvas;ColWidths:TTxnLogLineFlags;FSMon:TFileStatusMon;OldList:TStringList;VTList,VPList:TCheckListBox;Force:Boolean);
var                                                                                                                    
  MsgIndex:Integer;
  I,Off,WS:Integer;
  Status:TStatusBits;
  MessageData:TMessageAccess;
  TxnLines:TTxnLogLines;
  TxnLine:TTxnLogLineFlags;
  Flags:Integer;       
  TW,J,Idx,PIdx:Integer;
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
                     PIdx:=VPList.Items.IndexOf(TxnLine.Period);
                     if (PIdx = -1) or (VPList.Checked[PIdx]) then
                     begin
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
                     
                              Idx:=VTList.Items.IndexOf(TxnLine.RecType);
                              if Idx = -1 then
                              begin
                                 Idx:=VTList.Items.Add(TxnLine.RecType);
                                 VTList.State[Idx]:=cbChecked;
                              end;
                              PIdx:=VPList.Items.IndexOf(TxnLine.Period);
                              if PIdx = -1 then
                              begin
                                 PIdx:=VPList.Items.Add(TxnLine.Period);
                                 VPList.State[PIdx]:=cbChecked;
                              end;
                              if VTList.Checked[Idx] and VPList.Checked[PIdx] then
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
               TxnLine.RecType:='Money Order';
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
procedure DrawItem(Items:TStrings;Canvas:TCanvas;Index:Integer;Rect:TRect;State:TOwnerDrawState;ColWidths:TTxnLogLineFlags;
                   ShowID     ,ShowWS     ,ShowDate   ,ShowPeriod ,ShowType   ,ShowDesc   ,
                   ShowQty    ,ShowPrice  ,ShowValue  ,ShowUser   ,ShowPLU    ,ShowProd   ,
                   ShowInfo   ,ShowIdent  ,ShowDomInfo,ShowOffice :Boolean);
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
      if ShowID then
      begin
         TextOut(LOfs+1,Rect.Top+1,TxnLine.RecordID);
         PolyLine([Point(LOfs+ColWidths.RecordID-5,Rect.Top),Point(LOfs+ColWidths.RecordID-5,Rect.Bottom)]);
         Inc(LOfs,Integer(ColWidths.RecordID));
      end;
      
      if ShowWS then
      begin
         TextOut(LOfs+1,Rect.Top+1,TxnLine.WSNumber);
         PolyLine([Point(LOfs+ColWidths.WSNumber-5,Rect.Top),Point(LOfs+ColWidths.WSNumber-5,Rect.Bottom)]);
         Inc(LOfs,Integer(ColWidths.WSNumber));
      end;
         
      if ShowDate then
      begin
         TextOut(LOfs+1,Rect.Top+1,TxnLine.DateTime);
         PolyLine([Point(LOfs+ColWidths.DateTime-5,Rect.Top),Point(LOfs+ColWidths.DateTime-5,Rect.Bottom)]);
         Inc(LOfs,Integer(ColWidths.DateTime));
      end;
         
      if ShowPeriod then
      begin
         TextOut(LOfs+1,Rect.Top+1,TxnLine.Period);
         PolyLine([Point(LOfs+ColWidths.Period-5,Rect.Top),Point(LOfs+ColWidths.Period-5,Rect.Bottom)]);
         Inc(LOfs,Integer(ColWidths.Period));
      end;
         
      if ShowType then
      begin
         TextOut(LOfs+1,Rect.Top+1,TxnLine.RecType);
         PolyLine([Point(LOfs+ColWidths.RecType-5,Rect.Top),Point(LOfs+ColWidths.RecType-5,Rect.Bottom)]);
         Inc(LOfs,Integer(ColWidths.RecType));
      end;
         
      if ShowDesc then
      begin
         TextOut(LOfs+1,Rect.Top+1,TxnLine.Description);
         PolyLine([Point(LOfs+ColWidths.Description-5,Rect.Top),Point(LOfs+ColWidths.Description-5,Rect.Bottom)]);
         Inc(LOfs,Integer(ColWidths.Description));
      end;
         
      if ShowQty then
      begin
         TextOut(LOfs-10+ColWidths.Quantity-TextWidth(TxnLine.Quantity),Rect.Top+1,TxnLine.Quantity);
         PolyLine([Point(LOfs+ColWidths.Quantity-5,Rect.Top),Point(LOfs+ColWidths.Quantity-5,Rect.Bottom)]);
         Inc(LOfs,Integer(ColWidths.Quantity));
      end;
         
      if ShowPrice then
      begin
         TextOut(LOfs-10+ColWidths.Price-TextWidth(TxnLine.Price),Rect.Top+1,TxnLine.Price);
         PolyLine([Point(LOfs+ColWidths.Price-5,Rect.Top),Point(LOfs+ColWidths.Price-5,Rect.Bottom)]);
         Inc(LOfs,Integer(ColWidths.Price));
      end;
         
      if ShowValue then
      begin
         TextOut(LOfs-10+ColWidths.TxnValue-TextWidth(TxnLine.TxnValue),Rect.Top+1,TxnLine.TxnValue);
         PolyLine([Point(LOfs+ColWidths.TxnValue-5,Rect.Top),Point(LOfs+ColWidths.TxnValue-5,Rect.Bottom)]);
         Inc(LOfs,Integer(ColWidths.TxnValue));
      end;
         
      if ShowUser then
      begin
         TextOut(LOfs+1,Rect.Top+1,TxnLine.Teller);
         PolyLine([Point(LOfs+ColWidths.Teller-5,Rect.Top),Point(LOfs+ColWidths.Teller-5,Rect.Bottom)]);
         Inc(LOfs,Integer(ColWidths.Teller));
      end;
         
      if ShowOffice then
      begin
         TextOut(LOfs+1,Rect.Top+1,TxnLine.Office);
         PolyLine([Point(LOfs+ColWidths.Office-5,Rect.Top),Point(LOfs+ColWidths.Office-5,Rect.Bottom)]);
         Inc(LOfs,Integer(ColWidths.Office));
      end;
      
      if ShowPLU then
      begin
         TextOut(LOfs+1,Rect.Top+1,TxnLine.PLU);
         PolyLine([Point(LOfs+ColWidths.PLU-5,Rect.Top),Point(LOfs+ColWidths.PLU-5,Rect.Bottom)]);
         Inc(LOfs,Integer(ColWidths.PLU));
      end;
         
      if ShowProd then
      begin
         TextOut(LOfs+1,Rect.Top+1,TxnLine.Prod);
         PolyLine([Point(LOfs+ColWidths.Prod-5,Rect.Top),Point(LOfs+ColWidths.Prod-5,Rect.Bottom)]);
         Inc(LOfs,Integer(ColWidths.Prod));
      end;
         
      if ShowInfo then
      begin
         TextOut(LOfs+1,Rect.Top+1,TxnLine.Info);
         PolyLine([Point(LOfs+ColWidths.Info-5,Rect.Top),Point(LOfs+ColWidths.Info-5,Rect.Bottom)]);
         Inc(LOfs,Integer(ColWidths.Info));
      end;
         
      if ShowIdent then
      begin
         TextOut(LOfs+1,Rect.Top+1,TxnLine.Ident);
         PolyLine([Point(LOfs+ColWidths.Ident-5,Rect.Top),Point(LOfs+ColWidths.Ident-5,Rect.Bottom)]);
         Inc(LOfs,Integer(ColWidths.Ident));
      end;
         
      if (TxnLine.RecType = 'TxnLine') and (TxnLine.RecIndex = 0) then
      begin
         PolyLine([Point(Rect.Left,Rect.Top),Point(LOfs-5,Rect.Top)]);
      end
      else if (TxnLine.RecType = 'TxnTotal') then
      begin
         PolyLine([Point(Rect.Left,Rect.Bottom-3),Point(LOfs-5,Rect.Bottom-3)]);
         PolyLine([Point(Rect.Left,Rect.Bottom-2),Point(LOfs-5,Rect.Bottom-2)]);
      end;
      if ShowDomInfo then
      begin
         if not VarIsEmpty(TxnLine.DomInfo) then
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
            Inc(LOfs,30);
         
            TextOut(LOfs+1,Rect.Top+1,TxnLine.DomInfo);
//            Inc(LOfs,TextWidth(TxnLine.DomInfo));
         
            DomInfoLines.Free;
            DomInfoLine .Free;
         end;
      end; 
   end;                                         
   TxnLine.Free;
   Canvas.Brush.Color:=BC;
end;
procedure MeasureItem(Items:TStrings;Index:Integer;var Height:Integer);
var
   TxnLine:TTxnLogLineFlags;
begin
   Height:=13;
   if Index = 0 then 
      Height:=18
   else
   begin
      TxnLine:=TTxnLogLineFlags.Create;
      TxnLine.PackText:=Items[Index];
      if (TxnLine.RecType = 'TxnTotal') then  Height:=17;
      TxnLine.Free
   end;
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
   FHorizScrollBar.LargeChange:=20;
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
   ItemWid:=Width;
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
               FOnDrawItem(Self,I+FTopIndex,Rect(R.Left-((ItemWid * FHorizScrollBar.Position) div 100),R.Top+YOfs,R.Right,R.Top+YOfs+ItemHgt),[]);
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
procedure TMSVForm.MsgViewBoxDrawItem(MsgViewBox:TMsgViewBox;Index:Integer;InRect:TRect;State:TOwnerDrawState);
begin
   DrawItem(MsgViewBox.Items,MsgViewBox.Canvas,
            Index,InRect,State,TmpColWidths,
            True,True,True,True,True,True,True,True,True,True,True,True,True,True,True,True);
end;
procedure TMSVForm.MsgViewBoxMeasureItem(MsgViewBox:TMsgViewBox;Index:Integer;var Height,Width:Integer);
var
   I:Integer;
begin
   MeasureItem(MsgViewBox.Items,Index,Height);
   if TmpColWidths.Count = 17 then
   begin
      Width:=42;
      for I:=0 to TmpColWidths.Count-1 do
         Width:=Width+StrToIntDef(TmpColWidths[I],1);
      TmpColWidths.Add(IntToStr(Width));
   end
   else
   begin
      Width:=StrToIntDef(TmpColWidths[17],1);
   end;
end;                                
procedure TMSVForm.FormCreate(Sender: TObject);
var
  WSIdx:Integer;
  Status:TStatusBits;
begin
   ProgressBar1.Visible:=False;
   MsgViewBox:=TMsgViewBox.Create(nil);
   TabSheet2.InsertControl(MsgViewBox);
   MsgViewBox.Align:=alClient;
   MsgViewBox.Color:=clWhite;
   MsgViewBox.OnDrawItem:=MsgViewBoxDrawItem;
   MsgViewBox.OnMeasureItem:=MsgViewBoxMeasureItem;
   MessageList:=TMsgViewBox.Create(nil);
   TabSheet1.InsertControl(MessageList);
   MessageList.Align:=alClient;
   MessageList.Color:=clWhite;
   MessageList.OnDrawItem:=MessageListDrawItem;
   MessageList.OnMeasureItem:=MessageListMeasureItem;
              
   FileStatusMon:=TFileStatusMon.Create(nil);
   FileStatusMon.Active:=False;
   TTxnTransfer.FindPensionMessages(FileStatusMon);
   TTxnTransfer.FindMOMessages(FileStatusMon);
   ColWidths:=TTxnLogLineFlags.Create;
   TmpColWidths:=TTxnLogLineFlags.Create;
   
   Status:=TStatusBits.Create;
   Status.State:=FileStatusMon.FileBlockMgr.GetStatus;

   for WSIdx:=0 to Status.Count-1 do
     ListBox1.Items.Add('O'+IntToStr(Status.OfficeCode(WSIdx))+' W'+IntToStr(Status.WSNumber(WSIdx)));
   OfficeList.Items.Text:=FileStatusMon.OfficeList;
   POffices.Items.Assign(OfficeList.Items);
   Status.Free;
   PageControl1.ActivePage:=TabSheet1;
end;

procedure TMSVForm.FormDestroy(Sender: TObject);
begin
  FileStatusMon.Free;
  ColWidths.Free;
  TmpColWidths.Free;
end;
procedure TMSVForm.ListBox1Click(Sender: TObject);
begin
   if Listbox1.ItemIndex < 0 then Exit;
   PopulateLBFrom(Listbox1.ItemIndex,MessageList.Items,MessageList.Canvas,ColWidths,FileStatusMon,TStringList(Listbox1.Items.Objects[Listbox1.ItemIndex]),VTList,VPList,False);
   if Listbox1.ItemIndex < Listbox1.Items.Count then
   begin
     Listbox1.Items.Objects[Listbox1.ItemIndex]:=TStringList.Create;
     TStringList(Listbox1.Items.Objects[Listbox1.ItemIndex]).Assign(MessageList.Items);
   end;
end;
procedure TMSVForm.MessageListDrawItem(MsgViewBox:TMsgViewBox; Index: Integer;
  InRect: TRect; State: TOwnerDrawState);
begin
   DrawItem(MsgViewBox.Items,MsgViewBox.Canvas,Index,InRect,State,ColWidths,
            CheckID.Checked     ,CheckWS.Checked     ,CheckDate.Checked   ,
            CheckPeriod.Checked ,CheckType.Checked   ,CheckDesc.Checked   ,
            CheckQty.Checked    ,CheckPrice.Checked  ,CheckValue.Checked  ,
            CheckUser.Checked   ,CheckPLU.Checked    ,CheckProd.Checked   ,
            CheckInfo.Checked   ,CheckIdent.Checked  ,CheckDomInfo.Checked,CheckOffice.Checked);
end;
procedure TMSVForm.MessageListMeasureItem(MsgViewBox:TMsgViewBox;Index:Integer;var Height,Width:Integer);
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

procedure TMSVForm.CheckIDClick(Sender: TObject);
begin
   MessageList.Invalidate;
end;

procedure TMSVForm.UpdateClick(Sender: TObject);
var
   I:Integer;
begin
   for I:=0 to VTList.Items.Count-1 do
   begin
      if Update.Checked then
         VTList.State[I]:=cbChecked
      else
         VTList.State[I]:=cbUnchecked;
   end;
end;                    

procedure TMSVForm.UpdatePClick(Sender: TObject);
var
   I:Integer;
begin
   for I:=0 to VPList.Items.Count-1 do
   begin
      if UpdateP.Checked then
         VPList.State[I]:=cbChecked
      else
         VPList.State[I]:=cbUnchecked;
   end;
end;

procedure TMSVForm.FormShow(Sender: TObject);
begin
{   if ListBox1.Items.Count > 0 then
   begin
      ListBox1.ItemIndex:=0;
      ListBox1Click(ListBox1);
   end;}
end;

procedure TMSVForm.Button2Click(Sender: TObject);
var
   Mon:TFileStatusMon;
   TempMessageDir:String;
   WSIdx:Integer;
   Status:TStatusBits;
begin
   if OD.Execute then
   begin
      TempMessageDir:=MessageDir;
      MessageDir:=ExtractFilePath(OD.FileName);
      Mon:=TFileStatusMon.Create(nil);
   
      Status:=TStatusBits.Create;
      Status.State:=Mon.FileBlockMgr.GetStatus;
   
      ListBox4.Items.Clear;
      for WSIdx:=0 to Status.Count-1 do
        ListBox4.Items.Add('O'+IntToStr(Status.OfficeCode(WSIdx))+' W'+IntToStr(Status.WSNumber(WSIdx)));

      Status.Free;
      Mon.Free;
      MessageDir:=TempMessageDir;
   end;
end;

procedure TMSVForm.ListBox4Click(Sender: TObject);
var
  TempMessageDir:String;
  Mon:TFileStatusMon;
begin
   if ListBox4.ItemIndex < 0 then Exit;
   TempMessageDir:=MessageDir;
   MessageDir:=ExtractFilePath(OD.FileName);
   Mon:=TFileStatusMon.Create(nil);

   PopulateLBFrom(ListBox4.ItemIndex,MsgViewBox.Items,MsgViewBox.Canvas,TmpColWidths,Mon,TStringList(ListBox4.Items.Objects[ListBox4.ItemIndex]),VTList,VPList,False);
   MsgViewBox.Repaint;
   ListBox4.Items.Objects[ListBox4.ItemIndex]:=TStringList.Create;
   TStringList(ListBox4.Items.Objects[ListBox4.ItemIndex]).Assign(MsgViewBox.Items);

   Mon.Free;
   MessageDir:=TempMessageDir;
end;                                                  

procedure TMSVForm.OfficeListClick(Sender: TObject);
var
   OffCodeRef:TOffCodeRef;
begin
   OffCodeRef:=TOffCodeRef.Create;
   OCode.Text:=IntToStr(FileStatusMon.OfficeCodeFromTitle(OfficeList.Items[OfficeList.ItemIndex])); 
   OffCodeRef.PackText:=FileStatusMon.OfficeCodeRef(StrToInt(OCode.Text)); 
   OSCode    .Text:=OffCodeRef.OfficeSCode    ;
   OPCode    .Text:=OffCodeRef.OfficePCode    ;
   OI3Code   .Text:=OffCodeRef.OfficeI3Code   ;
   OName     .Text:=OffCodeRef.OfficeName     ;
   OAccessVia.Text:=OffCodeRef.OfficeAccessVia;
   OAutomated.Text:=OffCodeRef.OfficeAutomated;
   OAddress  .Text:=OffCodeRef.OfficeAddress  ;
   OPhone    .Text:=OffCodeRef.OfficePhone    ;
   OPOBox    .Text:=OffCodeRef.OfficePOBox    ;
   OffCodeRef.Free;
end;                                          
procedure TMSVForm.ProcessList(List:String);
var
   PensionData:TPackStringList;
   PensionPayment:TMinPensionPayment;
   I:Integer;
   S:String;
begin
   Pensions.Items.Clear;
   PensionData:=TPackStringList.Create;
   PensionData.PackText:=List;
   PensionPayment:=TMinPensionPayment.Create;
   for I:=0 to PensionData.Count-1 do
   begin
      PensionPayment.PackData:=PensionData[I];
      S:='Payment to '+PensionPayment.PayeeName+
         ' Identifier '+PensionPayment.PayeeIdentifier+
         ' Voucher No '+PensionPayment.VoucherNumber  +
         ' Amount     '+PensionPayment.Amount         +
         ' Type       '+PensionPayment.PensionType    ;
      if VarIsEmpty(PensionPayment.ProxyIdentifier) then
      S:=S+' Proxy      '+PensionPayment.ProxyName      +
           ' Identifier '+PensionPayment.ProxyIdentifier;
      Pensions.Items.Add(S);
      
   end;
   PensionPayment.Free;
   Pensions.Items.Insert(0,IntToStr(PensionData.Count));
   PensionData.Free;
end;
procedure TMSVForm.POfficesClick(Sender: TObject);
var
   OCode:Integer;
begin
   OCode:=FileStatusMon.OfficeCodeFromTitle(POffices.Items[POffices.ItemIndex]); 
   ProcessList(FileStatusMon.FullPensionList(OCode));
end;

procedure TMSVForm.PensionsDblClick(Sender: TObject);
var
   OCode:Integer;
   PensionPayment:TMinPensionPayment;
   PensionData:TPackStringList;
begin
   if POffices.ItemIndex < 0 then Exit;
   PensionPayment:=TMinPensionPayment.Create;
   PensionPayment.PackData:=Pensions.Items[Pensions.ItemIndex];
   OCode:=FileStatusMon.OfficeCodeFromTitle(POffices.Items[POffices.ItemIndex]); 
   PensionData:=TPackStringList.Create;
   PensionData.PackText:=FileStatusMon.PensionList(OCode,PensionPayment.PayeeIdentifier);
   Pensions.Items.Text:=PensionData.Text;
   PensionData.Free;
   PensionPayment.Free;
end;

procedure TMSVForm.PensionsClick(Sender: TObject);
var
   PensionPayment:TMinPensionPayment;
begin
   PensionPayment:=TMinPensionPayment.Create;
   PensionPayment.PackData:=Pensions.Items[Pensions.ItemIndex];
   Pensions.Hint:='Payment to '+PensionPayment.PayeeName      +#13#10+
                  'Identifier '+PensionPayment.PayeeIdentifier+#13#10+
                  'Voucher No '+PensionPayment.VoucherNumber  +#13#10+
                  'Amount     '+PensionPayment.Amount         +#13#10+
                  'Type       '+PensionPayment.PensionType    ;
   if VarIsEmpty(PensionPayment.ProxyIdentifier) then
   Pensions.Hint:=Pensions.Hint+#13#10+
                  'Proxy      '+PensionPayment.ProxyName      +#13#10+
                  'Identifier '+PensionPayment.ProxyIdentifier;

   PensionPayment.Free;
end;
procedure TMSVForm.Refresh;
var
   Status:TStatusBits;
   I:Integer;
begin       
   if FileStatusMon <> nil then
      FileStatusMon.Free;
   FileStatusMon:=TFileStatusMon.Create(nil);
   FileStatusMon.Active:=False;
   Status:=TStatusBits.Create;
   Status.State:=FileStatusMon.FileBlockMgr.GetStatus;
   ListBox1.Items.Clear;
   for I:=0 to Status.Count-1 do
     ListBox1.Items.Add('O'+IntToStr(Status.OfficeCode(I))+' W'+IntToStr(Status.WSNumber(I)));
   Status.Free;
   PageControl1.ActivePage:=TabSheet1;
end;
procedure TMSVForm.Button6Click(Sender: TObject);
var
   MainSL:TPackStringList;
   LastTxnType :String;
   LastWSNumber:Integer;
   TxnLine:TTxnLogLineFlags;
   MessageList:TTxnLogLines;
   I:Integer;
   S:String;
   FileTxStatus:TFileStatusMonW;
   CurrentRecordID:Integer;
   ThisOffice:Integer;
begin
   Button6.Enabled:=False;
   ThisOffice:=StrToIntDef(GetGPCSRegString('OfficeInfo','Office Id','1000'),1000);
   MainSL:=GetMergeDataFrom(MessageDir);
   Windows.Beep(5000,20);
   MainSL.Sort;
   Windows.Beep(5000,20);
   
   S:='';
   I:=0;
   while I < MainSL.Count do
   begin
      if MainSL[I] <> S then
      begin
         S:=MainSL[I];
         if MainSL.Objects[I] <> nil then
            MainSL[I]:=TStringObject(MainSL.Objects[I]).Value;
         Inc(I);
      end
      else
      begin
         if MainSL.Objects[I] <> nil then
            TStringObject(MainSL.Objects[I]).Free;
         MainSL.Delete(I);
      end;
   end;
   FileStatusMon.Free;
   FileStatusMon:=nil;
   EraseMessages(MessageDir);
   FileTxStatus:=TFileStatusMonW.Create(nil);
   LastTxnType :='';
   LastWSNumber:=-1;
   CurrentRecordID:=0;
   MessageList:=TTxnLogLines.Create;
   while MainSL.Count > 0 do
   begin
      if MainSL[0] <> '' then
      begin
         try
            TxnLine:=TTxnLogLineFlags.Create;
            TxnLine.PackText:=MainSL[0];
            
            if LastWSNumber <> TxnLine.WSNumber then
               CurrentRecordID:=0;
               
            TxnLine.RecordID:=CurrentRecordID;
            TxnLine.Office:=ThisOffice;
            Inc(CurrentRecordID);
            MessageList.Add(TxnLine.PackText);
            if  (I = MainSL.Count-1)
            or (LastWSNumber <> TxnLine.WSNumber)
            or ((TxnLine.RecType <> LastTxnType)
             and (LastTxnType <> 'TxnLine'  ) and (LastTxnType <> 'TxnTotal'   )
             and (LastTxnType <> 'TxStockTo') and (LastTxnType <> 'TxStockFrom')
             and (LastTxnType <> 'StockUsed') and (LastTxnType <> 'StockTx'    )
             and (LastTxnType <> 'StockDec' ) and (LastTxnType <> 'PrLabel'    ))
            or ((TxnLine.RecType='TxnTotal') and (TxnLine.Prod = 'Product.Cash'))  then
            begin
              FileTxStatus.FileBlockMgr.AppendMessage(
                 TxnLine.Office,TxnLine.WSNumber,
                 dtTransaction,0,Now+1,Now+500,'Data','Data',mtTransaction,0,'',
                 MessageList.PackText,True);
              MessageList.Clear;
            end;
            LastWSNumber:=TxnLine.WSNumber;
            LastTxnType :=TxnLine.RecType;
            TxnLine.Free;
         except
            on E:Exception do ShowMessage(E.Message+' '+MainSL[0]);
         end;
      end;
      if MainSL.Objects[0] <> nil then
         TStringObject(MainSL.Objects[0]).Free;
      MainSL.Delete(0);
   end;
   Windows.Beep(5000,20);
   MainSL.Free;            
   MessageList.Free;
   FileTxStatus.Free;
   Button6.Enabled:=True;
   Refresh;
end;
procedure TMSVForm.Button1Click(Sender: TObject);
var
   TxnLog:TQuery;
   FileTxStatus:TFileTxStatus;
begin    
   Button1.Enabled:=False;
   FileTxStatus:=TFileTxStatus.Create(nil);
   FileTxStatus.Active:=False;
   TxnLog:=TQuery.Create(nil);
   TxnLog.DatabaseName:='PSL';
   TxnLog.SessionName:='Default';
   TxnLog.SQL.Text:='UPDATE TXNLOG SET OFFICE = '''+GetGPCSRegString('OfficeInfo','Office Id','1000')+'''';
   TxnLog.ExecSQL;
   TxnLog.SQL.Text:='select * from Txnlog order by WSNumber,RecordID';
   TTxnTransfer.BuildStoreFromTxnLog(TxnLog,FileTxStatus,nil);
   TxnLog.Free;
   FileTxStatus.Free;
   Button1.Enabled:=True;
   Refresh;
end;

procedure TMSVForm.Button7Click(Sender: TObject);
begin
   Button7.Enabled:=False;
   if OD.Execute then
      Fix(MessageDir,ExtractFilePath(OD.FileName),0);
   Button7.Enabled:=True;
   Refresh;
end;                      

procedure TMSVForm.Button8Click(Sender: TObject);
begin
   Button8.Enabled:=False;
   if OD.Execute then
      Merge(MessageDir,ExtractFilePath(OD.FileName),0);
   Button8.Enabled:=True;
   Refresh;
end;      

procedure TMSVForm.ProgBar(PhaseNo,PhaseOf,Max,Pos:Integer);
var
   Divs:Integer;
begin
   try
      if Pos = 0 then 
      begin
         ProgressBar1.Min:=0;              
         ProgressBar1.Max:=Max;
         ProgressBar1.Visible:=True;
      end
      else if Max = Pos+1 then 
      begin
         ProgressBar1.Visible:=False;
//         Panel8.Caption:='';
      end;
      Divs:=Max div 200;
      if Divs = 0 then Divs:=100;
      if (Pos mod Divs) = 0 then
      begin
         ProgressBar1.Position:=Pos;
//         case PhaseNo of
//            1 : Panel8.Caption:='Marking Transactions as UnProcessed...';
//            2 : Panel8.Caption:='Listing UnProcessed Data...';
//            3 : Panel8.Caption:='Transfering Data...';
//         end;      
//         Panel8.Repaint;
         Application.ProcessMessages;
      end;          
      if (Pos div 100) = 0 then
         Application.ProcessMessages;
   except 
   end;
end;
procedure TMSVForm.Button3Click(Sender: TObject);
begin
   Button3.Enabled:=False;
   SpecialProcessing:=True;
   RebuildTxnlogAndStock(ProgBar);
   SpecialProcessing:=False;
   Button3.Enabled:=True;
end;      

procedure TMSVForm.Button4Click(Sender: TObject);
begin
   Button4.Enabled:=False;
   FileStatusMon.Free;
   FileStatusMon:=nil;
   Repair(0);
   Button4.Enabled:=True;
   Refresh;
end;       

procedure TMSVForm.RouteClick(Sender: TObject);
var
   I:Integer;
   O1,O2:Integer;
begin
   if OfficeList.SelCount = 2 then
   begin
      O1:=0;
      O2:=0;
      for I:=0 to OfficeList.Items.Count-1 do
      begin
         if OfficeList.Selected[I] then
         begin
            if O1 = 0 then 
            begin
               O1:=FileStatusMon.OfficeCodeFromTitle(OfficeList.Items[I]); 
            end
            else
            begin
               O2:=FileStatusMon.OfficeCodeFromTitle(OfficeList.Items[I]); 
               break;
            end;
         end;                    
      end;
      RouteMemo.Text:=FileStatusMon.GetRoute(O1,O2,'Data');
   end;
end;

procedure TMSVForm.Button5Click(Sender: TObject);
var
   I:Integer;
   O1,O2:Integer;
begin
   if OfficeList.SelCount = 2 then
   begin
      O1:=0;
      O2:=0;
      for I:=0 to OfficeList.Items.Count-1 do
      begin
         if OfficeList.Selected[I] then
         begin
            if O1 = 0 then 
            begin
               O1:=FileStatusMon.OfficeCodeFromTitle(OfficeList.Items[I]); 
            end
            else
            begin
               O2:=FileStatusMon.OfficeCodeFromTitle(OfficeList.Items[I]); 
               break;
            end;
         end;                    
      end;
      RouteMemo.Text:=FileStatusMon.OfficeTitleFromCode(FileStatusMon.NextOffice(O1,O2,'Data'));
   end;
end;

procedure TMSVForm.Button9Click(Sender: TObject);
begin
   MergeWS.Enabled:=False;
   if OD.Execute then
      Merge(MessageDir,ExtractFilePath(OD.FileName),StrToIntDef(MergeWS.Text,0));
   MergeWS.Enabled:=True;
   Refresh;
end;

procedure TMSVForm.POfficesDblClick(Sender: TObject);
var
   OCode:Integer;
begin
   OCode:=FileStatusMon.OfficeCodeFromTitle(POffices.Items[POffices.ItemIndex]); 
   ProcessList(FileStatusMon.PensionTxnList(OCode));
end;

procedure TMSVForm.POfficesMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   OCode:Integer;
begin
   OCode:=FileStatusMon.OfficeCodeFromTitle(POffices.Items[POffices.ItemIndex]); 
   if (Button = mbRight) and (POffices.ItemIndex >= 0) then
   begin
      ProcessList(FileStatusMon.UnpaidPensionList(OCode,''));
   end;
end;                   

procedure TMSVForm.Button10Click(Sender: TObject);
var
   Dir1:String;
   Dir2:String;
   TempMessageDir:String;
   FSM1,FSM2:TFileStatusMon;
   I:Integer;
   WS,Off,MsgIndex:Integer;
   Status1,Status2:TStatusBits;
   ErrorList:TStringList;
   Flags1,Flags2:Integer;
begin
   TempMessageDir:=MessageDir;
   try
      MessageDir:=ExtractFilePath(OD.FileName);
      OD.Title:='Compare Directory 1';
      if OD.Execute then
      begin
         Dir1:=ExtractFilePath(OD.FileName);
         OD.Title:='Compare Directory 2';
         if OD.Execute then
         begin
            ErrorList:=TStringList.Create;
            Dir2:=ExtractFilePath(OD.FileName);
            OD.Title:='Open';
            MessageDir:=Dir1;
            FSM1:=TFileStatusMon.Create(nil);
            MessageDir:=Dir2;
            FSM2:=TFileStatusMon.Create(nil);
            MessageDir:=TempMessageDir;
            Status1:=TStatusBits.Create;
            Status2:=TStatusBits.Create;
            Status1.State:=FSM1.FileBlockMgr.GetStatus;
            Status2.State:=FSM2.FileBlockMgr.GetStatus;
            for I:=0 to Status1.Count-1 do
            begin
               WS:=Status1.WSNumber(I);
               Off:=Status1.OfficeCode(I);
               if Status2.Size(Off,WS) = 0 then
               begin
                  ErrorList.Add('N'+IntToStr(Off)+'^'+IntToStr(WS));
               end
               else
               begin
                  for MsgIndex:=0 to Status1.Size(Off,WS) do
                  begin
                     Flags1:=FSM1.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
                     Flags2:=FSM2.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
                     if Flags1 <> Flags2 then
                     begin
                        if Flags1 <> 0 then
                           ErrorList.Add('E'+IntToStr(Off)+'^'+IntToStr(WS)+'^'+IntToStr(MsgIndex))
                        else
                           ErrorList.Add('M'+IntToStr(Off)+'^'+IntToStr(WS)+'^'+IntToStr(MsgIndex));
                     end;
                  end;
               end;
            end;
            FSM2.Free;
            FSM1.Free;
            if Trim(ErrorList.Text) = '' then
               ErrorList.Add('No Errors Found');
            ShowMessage(ErrorList.Text);
            ErrorList.Free;
         end;                             
      end;                             
      OD.Title:='Open';
   finally
      MessageDir:=TempMessageDir;
   end;
end;   

procedure TMSVForm.ListBox1DblClick(Sender: TObject);
begin
   if Listbox1.ItemIndex < 0 then Exit;
   PopulateLBFrom(Listbox1.ItemIndex,MessageList.Items,MessageList.Canvas,ColWidths,FileStatusMon,TStringList(Listbox1.Items.Objects[Listbox1.ItemIndex]),VTList,VPList,True);
   Listbox1.Items.Objects[Listbox1.ItemIndex]:=TStringList.Create;
   TStringList(Listbox1.Items.Objects[Listbox1.ItemIndex]).Assign(MessageList.Items);
end;

procedure TMSVForm.Button11Click(Sender: TObject);
begin
   Button11.Enabled:=False;
   FileStatusMon.Free;
   FileStatusMon:=nil;
   Repair(StrToIntDef(OfficeCode.Text,0));
   Button11.Enabled:=True;
   Refresh;
end;

procedure TMSVForm.Button12Click(Sender: TObject);
var
   FileTxStatus:TFileTxStatus;
begin                     
   FileTxStatus:=TFileTxStatus.Create(nil);
   FileTxStatus.Active:=False;
   TTxnTransfer.MarkAllMessages(nil,FileTxStatus);
   FileTxStatus.Free;
end;

procedure TMSVForm.Button13Click(Sender: TObject);
var
   SL:TPackStringList;
   I:Integer;
   MODetails:TMODetails;
begin
   MODetails:=TMODetails.Create;
   SL:=TPackStringList.Create;                                // SCFNN
   SL.PackText:=RequestServiceData('MoneyOrderPayList','31'); // 11111 
   MoneyOrders.Lines.Clear;
   for I:=0 to SL.Count-1 do
   begin
      MODetails.PackText:=SL[I];
      MoneyOrders.Lines.Add(
      'IssuePay '+MODetails.IssuePay +' '+
      'Series '  +MODetails.Series   +' '+
      'SerialNo '+MODetails.SerialNo +' '+
      'IOffice ' +MODetails.IOffice  +' '+
      'IClerk '  +MODetails.IClerk   +' '+
      'IDate '   +DateTimeToStr(MODetails.IDate)+' '+
      'IName '   +MODetails.IName    +' '+
      'Value '   +MODetails.Value    +' '+
      'MOType '  +MODetails.MOType   +' '+
      'POffice ' +MODetails.POffice  +' '+
      'PName '   +MODetails.PName    +' '+
      'PPOBox '  +MODetails.PPOBox   +' '+
      'PMessage '+MODetails.PMessage );
   end;
   SL.Free;
   MODetails.Free;
end;

procedure TMSVForm.Button14Click(Sender: TObject);
var
   FileTxStatus:TFileTxStatus;
begin                     
   Button14.Enabled:=False;
   FileTxStatus:=TFileTxStatus.Create(nil);
   FileTxStatus.Active:=False;
   TTxnTransfer.PutInMoneyOrderMessages(nil,FileTxStatus);
   FileTxStatus.Free;
   Button14.Enabled:=True;
   Refresh;
end;

procedure TMSVForm.Button15Click(Sender: TObject);
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Add('All');
   SL.Add('');
   SL.Add(IntToStr(Integer(False)));
   SL.PackText:=RequestServiceData('ListStock',SL.PackText);
   Memo1.Text:=SL.Text;
   SL.Free
end;

procedure TMSVForm.Button16Click(Sender: TObject);
begin
   Results.Lines.CommaText:=
      ExecRemoteQuery(User.Text,Pass.Text,Alias.Text,Query.Lines.CommaText,
                      Host.Text,StrToIntDef(TimeOut.Text,60000),True);
end;

end.
