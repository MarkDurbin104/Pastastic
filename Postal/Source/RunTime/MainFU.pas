unit MainFU;

interface

uses
  UsersF,FileTxStatusU,MsgConfigU,TaskKillerU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, Mask2, IPControl, CompExecU, PadLines,ComObj,
  StretchU,KGButton,GPCSGUID,GPCSErrorLine,GPCSErrorCode, Domain,
  ComCtrls,PackStrListU,Dialogs,GPCSBase_TLB,StringUtil,CRC32,WinExecU,
  DBUtil,DB,DBTables,UDPMessageU,ReportIDSU,ShareDataU,Preview,Printers;

type
  TPType =(ptForm,ptError,ptHelp,ptInfo,ptPick,ptTrans,ptAcct,ptCancel);
  TColProgressBar = class (TProgressBar)
  published
     property Color;
  end;
  TSaveButton = class(TObject)
    Price            :String;
    Caption          :String;
    Glyph            :TBitmap;
    ToggleWhenClicked:Boolean;
    ButtonIsUp       :Boolean;
    IsAvailable      :Boolean;
    Flashing         :Boolean;
    Enabled          :Boolean;
    SetFrom          :TKGButton;
    OnClick          :TNotifyEvent;
    ShowPrice        :Boolean;
    procedure SetValues(From:TKGButton);
    procedure Restore;
    destructor Destroy; override;
  end;

  TMainForm = class(TForm)
    B1: TKGButton;
    B2: TKGButton;
    B3: TKGButton;
    B4: TKGButton;
    B5: TKGButton;
    B6: TKGButton;
    B7: TKGButton;
    B8: TKGButton;
    B9: TKGButton;
    B10: TKGButton;
    B11: TKGButton;
    B12: TKGButton;
    CornLogo: TImage;
    Image2: TImage;
    Title: TLabel;
    Time: TLabel;
    Prompt: TLabel;
    Hint1: TLabel;
    Hint2: TLabel;
    ScaleOK: TImage;
    InputImage: TImage;
    IPControl1: TIPControl;
    SystemClock: TTimer;
    KU: TKGButton;
    KD: TKGButton;
    KC: TKGButton;
    KT: TKGButton;
    FPad: TImage;
    EPad: TImage;
    HPad: TImage;
    IPad: TImage;
    PPad: TImage;
    PadLines: TPadLines;
    Scale: TLabel;
    ScaleError: TImage;
    InstImage: TImage;
    TPad: TImage;
    APad: TImage;
    EODWarning: TLabel;
    CompExec: TUICompExec;
    GrammesLabel: TLabel;
    ScaleIndicator: TShape;
    Reference: TLabel;
    Label1: TLabel;
    PrintPanel: TPanel;
    procedure FormShow(Sender: TObject);
    procedure B1Click(Sender: TObject);
    procedure B2Click(Sender: TObject);
    function CompExecGetButtonIndex(Button: TControl): Integer;
    function CompExecGetButtonOnClick(Button: TControl): TNotifyEvent;
    procedure CompExecSetButtonOnClick(Button: TControl;
      Handler: TNotifyEvent);
    function CompExecGetButtonRef(Index: Integer): TControl;
    procedure CompExecSetButtonBitMap(Button: TControl;
      var BitMap: TBitmap);
    procedure CompExecSetButtonCaption(Button: TControl;
      Caption: String);
    procedure CompExecSetBitMap(BitMap: TBitmap);
    procedure CompExecSetPMessage(Caption: String);
    procedure CompExecSetPrompt(Caption: String);
    procedure CompExecSetTitle(Caption: String);
    procedure SystemClockTimer(Sender: TObject);
    procedure CompExecSetButtonPrice(Button: TControl; Price: Currency);
    procedure IPControl1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure KCClick(Sender: TObject);
    procedure KTClick(Sender: TObject);
    procedure KDClick(Sender: TObject);
    procedure IPControl1SelectItem(var Value: Integer);
    procedure IPControl1ItemPicked(var Value: String; Index: Integer);
    procedure CompExecSetFormData(Caption: String;FlagError,NewForm,DontUpdate:Boolean);
    procedure IPControl1SetList(var Value: String);
    procedure IPControl1SetPrompt(var Value: String);
    procedure IPControl1SetHint(var Value: String);
    procedure IPControl1SetMode(var Value: TIPMode);
    procedure FormDestroy(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure IPControl1SetError(var Value: String);
    procedure CompExecSetScale(Caption: String);
    function IPControl1DataChange(var Value: String): Boolean;
    procedure CompExecDisplayInstruct(Text, BitMap: String);
    procedure KUClick(Sender: TObject);
    procedure CompExecSetTransactions(Caption: String);
    procedure CompExecSetButtonToggle(Button: TControl; State: Integer);
    procedure FormCreate(Sender: TObject);
    procedure CompExecSetAccounts(Caption: String);
    procedure SaveCurrentState(Restore:Boolean);
    procedure IPControl1Execute(ProgID: String);
    function CompExecGetFormIndex: Integer;
    procedure CEModalDialog(PType:TPType;Text,DlgPrompt,DlgHint:String;B1,B2,B3:TControl;B1C,B2C,B3C:String);
    procedure CompExecModalDialog(PType: TPType; Text, DlgPrompt,
      DlgHint: String; B1, B2, B3: TControl; B1C, B2C, B3C: String);
    procedure CompExecProgress(Title:String;Min,Max,Pos:Integer);
    procedure IPControl1PopUp(ShiftState: Integer);
    procedure IPControl1Exit(Sender: TObject);
  private
    PrintPreview:TPrintPreview;
    //InPreviewDialog:Boolean;
    PreviewReady:Boolean;
    ModalResult:String;
    ColProgressBar:TColProgressBar;
    Users:String;
    TempHide:Boolean;
    KUCaption:String;
    KDCaption:String;
    KTCaption:String;
    KCCaption:String;
    B1Caption:String;
    B2Caption:String;
    UserFormCaption  :String;
    UserFormTitle    :String;
    UserFormNameL    :String;
    UserFormPasswordL:String;
    ExecuteNext:String;
    TriggerValue:String;
    InForm:Boolean;
    InList:Boolean;
    hTaskBar:THandle;
    LAScale:TBitMap;
    RAScale:TBitMap;
    PSLDatabase:TDatabase;
    procedure SetEODWarning(Title:String;State:Boolean);
    procedure SetupImages;
    procedure AppDeactivate(Sender: TObject);
    procedure TurnSysKeysOff;
    procedure TurnSysKeysOn;
    function HidePads:TPType;
    function ShowPad(PType:TPType):TPType;
    procedure ModalButtonPressed(Sender:TObject);
    procedure ShowModalDialog(PType:TPType;Text,DlgPrompt,DlgHint:String;B1,B2,B3:TKGButton;B1C,B2C,B3C:String);
    procedure PrintButtonPressed(Sender:TObject);
    procedure SetButtonCap(Button:TKGButton;Caption:String);
    procedure ShowPrintDialog;
    procedure ToggleButtonState(Back:Boolean);
    procedure ExecuteByMask(MaskVal:String);
    procedure ExceptionEvent(Sender: TObject; E: Exception);
    function  ReportPreview(Name:String;JustData:Boolean):String;
    procedure PreviewFunction(Name:String);
  public
    UserGroup:String;
    TriggerTimeOut: integer ;
    TriggerStartTime: TTimeStamp;
    procedure GetUserDetails(var UserName,RealUserName,UserGroup,WorkStation,Office:String;var ClerkCode,ClerkOfficeCode,ClerkLevel:Integer);
    procedure FlipSides;
    function SelectHelp(HelpFile,CurrentExec:String):String;
  end;
  
function LoneProcess:Boolean;

var
  MainForm: TMainForm;
  MOUSEXY:TPoint;
  ReportsNode:TReportsNode;
const
  LoggingKeyPresses:Boolean = False;


implementation

uses UserFormFU, SplashFU, BaseProduct, ServiceBusyFU, BarCD3;

function LoneProcess:Boolean;
begin
   Result:=True;
   if CountOfThisProcess > 1 then
   begin
      Splash.WarningLabel.Caption:='PROCESS ALREADY RUNNING !';
      Splash.SetBounds((Screen.Width div 2)-350,(Screen.Height div 2)-80,700,160);
      Splash.Repaint;
      Sleep(3000);
      Result:=False;
   end;           
end;

{TSaveButton}
procedure TSaveButton.SetValues(From:TKGButton);
begin
    SetFrom:=From;
    Price            :=SetFrom.Price            ;
    ShowPrice        :=SetFrom.ShowPrice        ;
    OnClick          :=SetFrom.OnClick          ;
    Caption          :=SetFrom.Caption          ;
    ToggleWhenClicked:=SetFrom.ToggleWhenClicked;
    ButtonIsUp       :=SetFrom.ButtonIsUp       ;
    IsAvailable      :=SetFrom.IsAvailable      ;
    Flashing         :=SetFrom.Flashing         ;
    Enabled          :=SetFrom.Enabled          ;
    
    Glyph:=TBitMap.Create;
    Glyph.Assign(SetFrom.Glyph);
end;
procedure TSaveButton.Restore;
begin
   SetFrom.Price            :=Price            ;
   SetFrom.ShowPrice        :=ShowPrice        ;
   SetFrom.OnClick          :=OnClick          ;
   SetFrom.Caption          :=Caption          ;
   SetFrom.ToggleWhenClicked:=ToggleWhenClicked;
   SetFrom.ButtonIsUp       :=ButtonIsUp       ;
   SetFrom.IsAvailable      :=IsAvailable      ;
   SetFrom.Flashing         :=Flashing         ;
   SetFrom.Glyph            :=Glyph            ;
   SetFrom.Enabled          :=Enabled          ;
end;                                            
destructor TSaveButton.Destroy;
begin
   if Glyph <> nil then Glyph.Free;
   inherited Destroy;
end;
{$R *.DFM}
procedure TMainForm.TurnSysKeysOff;
var
  OldVal:LongInt;
begin
  Application.OnDeactivate:=AppDeactivate;
  SystemParametersInfo(SPI_SCREENSAVERRUNNING,Word(True),@OldVal,0);
  hTaskBar:=FindWindow('Shell_TrayWnd', nil);
  ShowWindow(hTaskBar,SW_HIDE);
end;
procedure TMainForm.TurnSysKeysOn;
var
  OldVal:LongInt;
begin
  SystemParametersInfo(SPI_SCREENSAVERRUNNING,Word(False),@OldVal,0);
  ShowWindow(hTaskBar,SW_SHOW);
end;
procedure TMainForm.SetupImages;
var
   BMP:TBitMap;
   R,G,B:Integer;
begin
   R:=B1.AdjRed;
   G:=B1.AdjGreen;
   B:=B1.AdjBlue ;

   KU.AdjRed  :=R; KU.AdjGreen:=G; KU.AdjBlue :=B;
   BMP:=CompExec.GetPictureFromServer('LUButton');    B1.UpBitMap  :=BMP; BMP.Free;
   BMP:=CompExec.GetPictureFromServer('LDButton');    B1.DownBitMap:=BMP; BMP.Free;
   BMP:=CompExec.GetPictureFromServer('SUButton');    KU.UpBitMap  :=BMP; BMP.Free;
   BMP:=CompExec.GetPictureFromServer('SDButton');    KU.DownBitMap:=BMP; BMP.Free;
   
   BMP:=CompExec.GetPictureFromServer('Help');        AdjustColor(BMP,R,G,B); B1.Glyph     :=BMP; BMP.Free;
   BMP:=CompExec.GetPictureFromServer('Information'); AdjustColor(BMP,R,G,B); B2.Glyph     :=BMP; BMP.Free;
   BMP:=CompExec.GetPictureFromServer('UP');          AdjustColor(BMP,R,G,B); KU.Glyph     :=BMP; BMP.Free;
   BMP:=CompExec.GetPictureFromServer('Down');        AdjustColor(BMP,R,G,B); KD.Glyph     :=BMP; BMP.Free;
   BMP:=CompExec.GetPictureFromServer('Cancel');      AdjustColor(BMP,R,G,B); KC.Glyph     :=BMP; BMP.Free;
   BMP:=CompExec.GetPictureFromServer('Top Menu');    AdjustColor(BMP,R,G,B); KT.Glyph     :=BMP; BMP.Free;
                                                     
   BMP:=CompExec.GetPictureFromServer('IPad'); AdjustColor(BMP,R,G,B); IPad.Picture.Bitmap.Assign(BMP); BMP.Free;
   BMP:=CompExec.GetPictureFromServer('Pad' ); AdjustColor(BMP,R,G,B); PPad.Picture.Bitmap.Assign(BMP); BMP.Free;
   BMP:=CompExec.GetPictureFromServer('TPad'); AdjustColor(BMP,R,G,B); TPad.Picture.Bitmap.Assign(BMP); BMP.Free;
   if GetGPCSRegString('','System Name','Tanzania Post') = 'Botswana Post' then
   begin
      BMP:=CompExec.GetPictureFromServer('BotsPad' ); 
      if BMP <> nil then
      begin
         AdjustColor(BMP,R,G,B); 
         PPad.Picture.Bitmap.Assign(BMP); 
         BMP.Free;
      end;
      BMP:=CompExec.GetPictureFromServer('BotsTPad' ); 
      if BMP <> nil then
      begin
         AdjustColor(BMP,R,G,B); 
         TPad.Picture.Bitmap.Assign(BMP); 
         BMP.Free;
      end;
   end;
   BMP:=CompExec.GetPictureFromServer('APad'); AdjustColor(BMP,R,G,B); APad.Picture.Bitmap.Assign(BMP); BMP.Free;
   BMP:=CompExec.GetPictureFromServer('FPad'); AdjustColor(BMP,R,G,B); FPad.Picture.Bitmap.Assign(BMP); BMP.Free;
   BMP:=CompExec.GetPictureFromServer('EPad'); AdjustColor(BMP,R,G,B); EPad.Picture.Bitmap.Assign(BMP); BMP.Free;
   BMP:=CompExec.GetPictureFromServer('HPad'); AdjustColor(BMP,R,G,B); HPad.Picture.Bitmap.Assign(BMP); BMP.Free;
   BMP:=CompExec.GetPictureFromServer('CornLogo'); AdjustColor(BMP,R,G,B); CornLogo.Picture.Bitmap.Assign(BMP); BMP.Free;
   LAScale:=CompExec.GetPictureFromServer('Scale'); AdjustColor(LAScale,R,G,B); ScaleOK.Picture.Bitmap.Assign(LAScale);
   RAScale:=CompExec.GetPictureFromServer('RAScale'); AdjustColor(RAScale,R,G,B);
   BMP:=CompExec.GetPictureFromServer('ScaleError'); AdjustColor(BMP,R,G,B); ScaleError.Picture.Bitmap.Assign(BMP); BMP.Free;
   BMP:=CompExec.GetPictureFromServer('Input'); AdjustColor(BMP,R,G,B); InputImage.Picture.Bitmap.Assign(BMP); BMP.Free;
   
   Color:=B1.UpBitMap.Canvas.Pixels[0,0];                             
   B3 .Left:=1024-169*2; B4 .Left:=1024-169; B3 .Top:=0    ; B4 .Top:=0    ;
   B5 .Left:=1024-169*2; B6 .Left:=1024-169; B5 .Top:=128  ; B6 .Top:=128  ;
   B7 .Left:=1024-169*2; B8 .Left:=1024-169; B7 .Top:=128*2; B8 .Top:=128*2;
   B9 .Left:=1024-169*2; B10.Left:=1024-169; B9 .Top:=128*3; B10.Top:=128*3;
   B11.Left:=1024-169*2; B12.Left:=1024-169; B11.Top:=128*4; B12.Top:=128*4;
   B1 .Left:=1024-169*2; B2 .Left:=1024-169; B1 .Top:=128*5; B2 .Top:=128*5;
   B1.KeyName:='F11';
   B2 .UpBitMap:=B1.UpBitMap; B2 .DownBitMap:=B1.DownBitMap; B2 .KeyName:='F12';
   B3 .UpBitMap:=B1.UpBitMap; B3 .DownBitMap:=B1.DownBitMap; B3 .KeyName:='F1';
   B4 .UpBitMap:=B1.UpBitMap; B4 .DownBitMap:=B1.DownBitMap; B4 .KeyName:='F2';
   B5 .UpBitMap:=B1.UpBitMap; B5 .DownBitMap:=B1.DownBitMap; B5 .KeyName:='F3';
   B6 .UpBitMap:=B1.UpBitMap; B6 .DownBitMap:=B1.DownBitMap; B6 .KeyName:='F4';
   B7 .UpBitMap:=B1.UpBitMap; B7 .DownBitMap:=B1.DownBitMap; B7 .KeyName:='F5';
   B8 .UpBitMap:=B1.UpBitMap; B8 .DownBitMap:=B1.DownBitMap; B8 .KeyName:='F6';
   B9 .UpBitMap:=B1.UpBitMap; B9 .DownBitMap:=B1.DownBitMap; B9 .KeyName:='F7';
   B10.UpBitMap:=B1.UpBitMap; B10.DownBitMap:=B1.DownBitMap; B10.KeyName:='F8';
   B11.UpBitMap:=B1.UpBitMap; B11.DownBitMap:=B1.DownBitMap; B11.KeyName:='F9';
   B12.UpBitMap:=B1.UpBitMap; B12.DownBitMap:=B1.DownBitMap; B12.KeyName:='F10';
   KD .UpBitMap:=KU.UpBitMap; KD .DownBitMap:=KU.DownBitMap;
   KC .UpBitMap:=KU.UpBitMap; KC .DownBitMap:=KU.DownBitMap;
   KT .UpBitMap:=KU.UpBitMap; KT .DownBitMap:=KU.DownBitMap;
   
   KUCaption:=KU.Caption;
   KDCaption:=KD.Caption;
   KTCaption:=KT.Caption;
   KCCaption:=KC.Caption;
   B1Caption:=B1.Caption;
   B2Caption:=B2.Caption;
   
   KU.Caption:=CompExec.TranslateString('Main',KUCaption,1,0,1);
   KD.Caption:=CompExec.TranslateString('Main',KDCaption,1,1,1);
   KT.Caption:=CompExec.TranslateString('Main',KTCaption,1,2,1);
   KC.Caption:=CompExec.TranslateString('Main',KCCaption,1,3,1);
   B1.Caption:=CompExec.TranslateString('Main',B1Caption,1,4,1);
   B2.Caption:=CompExec.TranslateString('Main',B2Caption,1,5,1);

   UserFormCaption  :=UserForm.Caption;
   UserFormTitle    :=UserForm.Title.Caption;
   UserFormNameL    :=UserForm.NameL.Caption;
   UserFormPasswordL:=UserForm.PasswordL.Caption; 
end;
function GetWorkstationEntry:String;
begin
   Result:=Copy(GetLocalMachineName,3,999);
//   Result:=GetGPCSRegString('Workstation','Style','FrontOffice1');
end;
function GetZipCodeEntry:String;
begin
   Result:=GetGPCSRegString('OfficeInfo','Office ID','3211');
end;
procedure SetZipCodeEntry(Value:String);
begin
   SetGPCSRegString('OfficeInfo','Office ID',Value);
end;
procedure TMainForm.FlipSides;
var
   I:Integer;
begin

   if GetGPCSRegString('Language','TranslationOn','0') = '1' then
   begin

      for I:=0 to ControlCount-1 do
      begin
         Controls[I].SetBounds(ClientWidth-(Controls[I].Left+Controls[I].Width),Controls[I].Top,Controls[I].Width,Controls[I].Height);
         if (Controls[I] is TLabel) and (Controls[I] <> Scale) then
         begin
            case (Controls[I] as TLabel).Alignment  of
              taLeftJustify  : (Controls[I] as TLabel).Alignment :=taRightJustify;
              taRightJustify : (Controls[I] as TLabel).Alignment :=taLeftJustify ;
            end;
            (Controls[I] as TLabel).Font.Charset:=ARABIC_CHARSET;
         end
         else if Controls[I] is TIPControl then
         begin
            (Controls[I] as TIPControl).RightAnchor:=not (Controls[I] as TIPControl).RightAnchor;
            (Controls[I] as TIPControl).Font.Charset:=ARABIC_CHARSET;
         end
         else if Controls[I] is TPadLines then
         begin
            (Controls[I] as TPadLines).RightAnchor:=not (Controls[I] as TPadLines).RightAnchor;
            (Controls[I] as TPadLines).Font.Charset:=ARABIC_CHARSET;
         end
         else if Controls[I] is TKGButton then
         begin
            (Controls[I] as TKGButton).RightAnchor:=not (Controls[I] as TKGButton).RightAnchor;
            (Controls[I] as TKGButton).Font.Charset:=ARABIC_CHARSET;
         end;
      end;
      with UserForm do
      begin
         for I:=0 to ControlCount-1 do
         begin
            Controls[I].SetBounds(ClientWidth-(Controls[I].Left+Controls[I].Width),Controls[I].Top,Controls[I].Width,Controls[I].Height);
            if (Controls[I] is TLabel) then
            begin
               case (Controls[I] as TLabel).Alignment  of
                 taLeftJustify  : (Controls[I] as TLabel).Alignment :=taRightJustify;
                 taRightJustify : (Controls[I] as TLabel).Alignment :=taLeftJustify ;
               end;
               (Controls[I] as TLabel).Font.Charset:=ARABIC_CHARSET;
            end
         end;
      end;
      UserForm.Caption:=CompExec.TranslateString('Main',UserFormCaption,1,0,1);
      UserForm.Title.Caption:=CompExec.TranslateString('Main',UserFormTitle,1,0,1);
      UserForm.NameL.Caption:=CompExec.TranslateString('Main',UserFormNameL,1,0,1);
      UserForm.PasswordL.Caption:=CompExec.TranslateString('Main',UserFormPasswordL,1,0,1);

      if KU.RightAnchor then
      begin
         SetThreadLocale($00000401);
         LoadKeyboardLayout('00000401',KLF_ACTIVATE);
         Font.Charset:=ARABIC_CHARSET;
         GrammesLabel.Caption:=GrammesSymbol;
         ScaleOK.Picture.Bitmap.Assign(RAScale);
      end
      else
      begin
         if not SetThreadLocale($00000809) then
            SetThreadLocale($00000409);
         if LoadKeyboardLayout('00000809',KLF_ACTIVATE) = 0 then
            LoadKeyboardLayout('00000409',KLF_ACTIVATE);
         GrammesLabel.Caption:='g';
         ScaleOK.Picture.Bitmap.Assign(LAScale);
      end;
      KU.Caption:=CompExec.TranslateString('Main',KUCaption,1,0,1);
      KD.Caption:=CompExec.TranslateString('Main',KDCaption,1,1,1);
      KT.Caption:=CompExec.TranslateString('Main',KTCaption,1,2,1);
      KC.Caption:=CompExec.TranslateString('Main',KCCaption,1,3,1);
      B1.Caption:=CompExec.TranslateString('Main',B1Caption,1,4,1);
      B2.Caption:=CompExec.TranslateString('Main',B2Caption,1,5,1);
      
      IPControl1.GetLngValues;

   end;

end;
procedure TMainForm.PreviewFunction(Name:String);
begin
   if PrintPreview = nil then
   begin
      InPreviewDialog:=False;
      Exit;
   end;
   if Name = 'Preview' then
   begin
      try
         ModalResult:='';
         Title.Caption:='Preview Page '+IntToStr(PrintPreview.CurrentPage)+' of '+IntToStr(PrintPreview.TotalPages);
         InPreviewDialog:=True;
         ShowPrintDialog;
      except
         InPreviewDialog:=False;
      end;
   end                         
   else if (Name = 'Cancel Operation') or (Name = 'Cancel') then
   begin
      PrintPanel.RemoveControl(PrintPreview);
      PrintPanel.Visible:=False;
      PrintPreview.Free;
      PrintPreview:=nil;
      InPreviewDialog:=False;
      ModalResult:='Cancel';
   end                
   else if Name = 'Print' then
   begin
      PrintPreview.Print;
      PrintPanel.RemoveControl(PrintPreview);
      PrintPanel.Visible:=False;
      PrintPreview.Free;
      PrintPreview:=nil;
      InPreviewDialog:=False;
      ModalResult:='';
   end
   else if Name = 'Top of Page' then  
   begin
      PrintPreview.VertScrollBar.Position:=0;
   end
   else if Name = 'Bottom of Page' then
   begin
      PrintPreview.VertScrollBar.Position:=PrintPreview.VertScrollBar.Range;
   end
   else if Name = 'Next Page' then
   begin
      if PrintPreview.CurrentPage < PrintPreview.TotalPages then
         PrintPreview.CurrentPage:=PrintPreview.CurrentPage+1;
      Title.Caption:='Preview Page '+IntToStr(PrintPreview.CurrentPage)+' of '+IntToStr(PrintPreview.TotalPages)
   end
   else if Name = 'Previous Page' then
   begin
      if PrintPreview.CurrentPage > 1 then
         PrintPreview.CurrentPage:=PrintPreview.CurrentPage-1;
      Title.Caption:='Preview Page '+IntToStr(PrintPreview.CurrentPage)+' of '+IntToStr(PrintPreview.TotalPages)
   end
   else if Name = 'First Page' then
   begin
      PrintPreview.VertScrollBar.Position:=0;
      PrintPreview.CurrentPage:=1;
      Title.Caption:='Preview Page '+IntToStr(PrintPreview.CurrentPage)+' of '+IntToStr(PrintPreview.TotalPages)
   end
   else if Name = 'Last Page' then
   begin
      PrintPreview.VertScrollBar.Position:=PrintPreview.VertScrollBar.Range;
      PrintPreview.CurrentPage:=PrintPreview.TotalPages;
      Title.Caption:='Preview Page '+IntToStr(PrintPreview.CurrentPage)+' of '+IntToStr(PrintPreview.TotalPages)
   end;
end;

procedure CentreText(Canvas:TCanvas;LeftPos,RightPos,TopPos:Integer;Text:String);
begin
   Canvas.TextOut(LeftPos+((RightPos-LeftPos)-Canvas.TextWidth(Text)) div 2,TopPos,Text);
end;


function DateToPeriod(FromDate:TDateTime):Integer;
begin
   Result:=Trunc(FromDate)-DaysUntil_010198;
end;
function PeriodToDate(FromPeriod:Integer):TDateTime;
begin
   Result:=DaysUntil_010198+FromPeriod;
end;
function DateToWeekNo(FromDate:TDateTime):Integer;
const
   Days_Until_01042002 = 37347;
begin
   // week 1 starts on 01/04/2002 so
   // take off the days until then
   // div 7 gives weeks since then
   // mod 52 restarts at 0 each year
   // add 1 because this calc is zero based
   Result:=(((Trunc(FromDate)-Days_Until_01042002) div 7) mod 52)+1;
end;
function PeriodToWeekNo(FromPeriod:Integer):Integer;
begin
   Result:=DateToWeekNo(PeriodToDate(FromPeriod));
end;
function StartOfMonth(FromPeriod:Integer):Integer;
var
   d,m,y:Word;
begin
   DecodeDate(PeriodToDate(FromPeriod),y,m,d);
   Result:=Trunc(EncodeDate(y,m,1));
end;
function EndOfMonth(FromPeriod:Integer):Integer; // (var DaysInWeek:Integer)
var
   d,m,y:Word;
const
   NumbDays:Array[1..12] of Integer = (31,28,31,30,31,30,31,31,30,31,30,31);
begin
   DecodeDate(PeriodToDate(FromPeriod),y,m,d);
   if ((y mod 4) = 0) and (m = 2) then // Feb. in leap year 
      Result:=Trunc(EncodeDate(y,m,NumbDays[m]+1))
   else
      Result:=Trunc(EncodeDate(y,m,NumbDays[m]));
end;
function StartWeek(FromPeriod:Integer):Integer;
begin
   Result:=DateToWeekNo(StartOfMonth(FromPeriod));
end;
function EndWeek(FromPeriod:Integer):Integer; // (var DaysInWeek:Integer)
begin
   Result:=DateToWeekNo(EndOfMonth(FromPeriod));
end;
function DayNumber(Date:TDateTime):Integer;
const
   Days_Until_01042002 = 37347;
begin
   // 01/04/2002 is a Monday (Day 1)
   Result:=((Trunc(Date)-Days_Until_01042002) mod 7)+1;
end;
function CurrentMonth:String;
begin
   Result:=FormatDateTime('mmmm',PeriodToDate(LocalSharedData.GetVariable('FromPeriod')));
end;
function CurrentYear:String;
begin
   Result:=FormatDateTime('yyyy',PeriodToDate(LocalSharedData.GetVariable('FromPeriod')));
end;

function WeekStartingDate(FromPeriod:Integer):TDate;
begin
   if DayOfWeek( PeriodToDate(FromPeriod) ) = 1 then  // Sunday
      FromPeriod := FromPeriod - 6
   else
   FromPeriod := FromPeriod - DayOfWeek( PeriodToDate(FromPeriod) )+2;
   Result := PeriodToDate( FromPeriod ) ;
   //Result:=((FromPeriod div 7)*7)+4;
end;

procedure RepFootCallBack(CallBackName,ReportName:String;PrintRect:TRect;Canvas:TCanvas;PageNo,NoPages:Integer);
begin
  //swaziland
  if CallBackName = 'SwaziStandardFooter' then
  begin
    CentreText(Canvas,PrintRect.Left,PrintRect.Right,PrintRect.Bottom-Canvas.TextHeight('Wg'),'Page ' + IntToStr(PageNo) + ' of ' + IntToStr(NoPages));
  end;
end;

procedure RepHeadCallBack(CallBackName,ReportName:String;PrintRect:TRect;Canvas:TCanvas;PageNo,NoPages:Integer);
var
  FS:Integer;
  YOfs,XOfs,I:Integer;
  S:String;
  SW,EW:Integer;
  NDFW,NDLW:Integer;
  Logo:TBitmap;
  ABitmap : TBitmap;
  TempString : string;
  Barcode : TprintBarcode;
const
   Days:Array[0..6] of String = ('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Weekly Total');
begin

   if LocalSharedData = nil then
      LocalSharedData:=TSharedData.Create('CorvusReportShare',False);

   FS:=Canvas.Font.Size;
   YOfs:=PrintRect.Top;
   if ( CallBackName = 'WeeklyProdAve') or (CallBackName = 'WeeklyUserAve') then
   begin
      if (ReportsNode <> nil) and (ReportsNode.Logo <> nil) then
      begin
         Logo:=ReportsNode.Logo;
         Canvas.CopyRect(Bounds(PrintRect.Left,PrintRect.Top,Logo.Width*10,Logo.Height*10),Logo.Canvas,Bounds(0,0,Logo.Width,Logo.Height));
      end;

      Canvas.Font.Size:=(FS*2);
      if GetGPCSRegString('','System Name','Tanzania Post') = 'Botswana Post' then
         S:='Botswana Post  -  Weekly Average Txn Value -  CONFIDENTIAL'
      else
         S:='Guernsey Post Ltd.  -  Weekly Average Txn Value -  CONFIDENTIAL';
      XOfs:=PrintRect.Left+((PrintRect.Right-PrintRect.Left)-Canvas.TextWidth(S)) div 2;
      Canvas.TextOut(XOfs,YOfs,S);
      Inc(YOfs,Canvas.TextHeight('Wg'));

      Canvas.Font.Size:=(FS*3) div 2;

      S:='Office Name: '+GetGPCSRegString('OfficeInfo','Office Name','Test')+'    '+
         'Office Code: '+MainForm.CompExec.CompExec.Office                  +'    '+
         //'Week No.: '   +IntToStr(DateToWeekNo(Now))                        +'    '+
         'Week No.: '   +IntToStr(DateToWeekNo( PeriodToDate(LocalSharedData.GetVariable('FromPeriod')) )) +'    '+
         //'Start Date: ' +FormatDateTime('dd/mm/yyyy',Now-(DayNumber(Now)-1));
         'Start Date: ' +FormatDateTime('dd/mm/yyyy',WeekStartingDate( LocalSharedData.GetVariable('FromPeriod')) ) ;

      Canvas.TextOut(XOfs,YOfs,S);
//      Inc(YOfs,Canvas.TextHeight('Wg'));

      Canvas.Font.Size:=FS;

      YOfs:=(PrintRect.Top+3000)-Canvas.TextHeight('Wg')*3;
      XOfs:=PrintRect.Left+4800;
      if (CallBackName = 'WeeklyUserAve') then CentreText(Canvas,XOfs-4800,XOfs,YOfs,'Name');
      for I:=0 to 6 do
      begin
         Canvas.PolyLine([Point(XOfs,YOfs+Canvas.TextHeight('Wg')*2),Point(XOfs,YOfs)]);
         CentreText(Canvas,XOfs,XOfs+2700,YOfs,Days[I]);
         Inc(XOfs,2700);
      end;
      Canvas.PolyLine([Point(PrintRect.Left,YOfs+Canvas.TextHeight('Wg')*2),Point(PrintRect.Left,YOfs),Point(XOfs,YOfs),Point(XOfs,YOfs+Canvas.TextHeight('Wg')*2)]);

      Inc(YOfs,(Canvas.TextHeight('Wg')*3) div 2);
      XOfs:=PrintRect.Left+4800;
      for I:=0 to 6 do
      begin
         if GetGPCSRegString('','System Name','Tanzania Post') = 'Guernsey Post' then
            CentreText(Canvas,XOfs,XOfs+2700,YOfs,'Value £')
         else
            CentreText(Canvas,XOfs,XOfs+2700,YOfs,'Value');
         Inc(XOfs,2700);
      end;
   end
	 else if CallBackName = 'EResidentReceipt' then
	 begin
  // fonts "fixed" so now 240 = 16, ie 1/15
//			Canvas.TextOut(XOfs,YOfs,'General Postal Corporation Doha Qatar');
//     Showmessage('Font size = '+ IntToStr(Canvas.Font.Size)); // returned 250
     Canvas.Font.Name := 'Times New Roman';
     Canvas.Font.Style := [fsBold];
//     Canvas.Font.Size := 8*46; 368
//     Canvas.Font.Size := 24;   15
//     Canvas.Font.Size := 18;   20
     Canvas.Font.Size := 14;  // 24  ?15
			Canvas.TextOut(3500,1900,'General Postal Corporation Doha Qatar');
			Canvas.MoveTo(950,2500);
			Canvas.LineTo(13650,2500);
			if (ReportsNode <> nil) and (ReportsNode.Logo <> nil) then
			begin
				Logo:=ReportsNode.Logo;
				Canvas.CopyRect(Bounds(PrintRect.Left,PrintRect.Top,Logo.Width*6,Logo.Height*6),Logo.Canvas,Bounds(0,0,Logo.Width,Logo.Height));
			end;
     ABitMap := Nil;
     try
       ABitMap := TBitmap.Create;
       // Please Bring ..
       if FileExists('c:\Qatar\Pleasebring.bmp') then
       begin                                             //10150  *18 *16
         ABitMap.LoadfromFile('c:\Qatar\Pleasebring.bmp');                // 20
         Canvas.CopyRect(Bounds(4300,10200,ABitMap.Width*19,ABitMap.Height*16),ABitMap.Canvas,Bounds(0,0,ABitMap.Width,ABitMap.Height));
       end;
       // Name
       if FileExists('c:\Qatar\Name.bmp') then
       begin
         ABitMap.LoadfromFile('c:\Qatar\Name.bmp');
         Canvas.CopyRect(Bounds(12200,15700,ABitMap.Width*5,ABitMap.Height*5),ABitMap.Canvas,Bounds(0,0,ABitMap.Width,ABitMap.Height));
       end;
       // ID No
       if FileExists('c:\Qatar\ID_No.bmp') then
       begin
         ABitMap.LoadfromFile('c:\Qatar\ID_No.bmp');
         Canvas.CopyRect(Bounds(12200,16600,ABitMap.Width*5,ABitMap.Height*5),ABitMap.Canvas,Bounds(0,0,ABitMap.Width,ABitMap.Height));
       end;
       // Date
       if FileExists('c:\Qatar\Date.bmp') then
       begin
         ABitMap.LoadfromFile('c:\Qatar\Date.bmp');
         Canvas.CopyRect(Bounds(12200,17450,ABitMap.Width*5,ABitMap.Height*5),ABitMap.Canvas,Bounds(0,0,ABitMap.Width,ABitMap.Height));
       end;
     finally
       if ABitmap <> Nil then
         ABitmap.Free;
     end;
     //Canvas.Font.Name := 'Arial Narrow';
     Canvas.Font.Name := 'Impact';
//     Canvas.Font.Size := 8*66; //528
     Canvas.Font.Size := 18; // 20 19
			Canvas.TextOut(4800,2900,'e_resident qatar');  //2800
     Canvas.Font.Name := 'Times New Roman';
     Canvas.Font.Style := [fsBold,fsItalic];
//     Canvas.Font.Size := 8*50;
     Canvas.Font.Size := 14;  // 17
			Canvas.TextOut(3550,3750,'Residence Permit Renewal Scheme');  // 3750   3850
     Canvas.Font.Style := [];
//     Canvas.Font.Size := 280;
     Canvas.Font.Size := 10;   // 12
		 	Canvas.TextOut(5350,4300,FormatDateTime('dd  mmm  yyyy      hh:mm', Now)); //4250    4150
//     Canvas.Font.Size := 260;
     Canvas.Font.Size := 10;  // 11 9
     Canvas.Font.Name := 'Arial';
     Canvas.Font.Style := [fsBold, fsUnderline];
			Canvas.TextOut(5400,5100,'CUSTOMER RECEIPT');
//     Canvas.Font.Size := 280;
     Canvas.Font.Size := 11;  //12  10
     Canvas.Font.Name := 'Times New Roman';
     Canvas.Font.Style := [fsBold];
			Canvas.TextOut(1500,5900,'Name');
			Canvas.TextOut(3100,5900,':');
			Canvas.TextOut(1500,6450,'P O Box'); //6500
			Canvas.TextOut(3100,6450,':');
			Canvas.TextOut(5400,6450,'Telephone :');
     Canvas.Font.Size := 10;  //12  11
			Canvas.TextOut(4600,7400,'Immigration Charge');   //4550
			Canvas.TextOut(4780,7850,'Processing Charge');    //4900
			Canvas.TextOut(4400,8300,'QPP Delivery Charge');  //4400
			Canvas.TextOut(6850,9200,'Total');                //7000
     Canvas.Font.Style := [];
     Canvas.Font.Size := 11;  //12  10 11
			Canvas.TextOut(3600,5900,ReplaceParams(':',':Form.BoxCustomerName:'));       // data replace
			Canvas.TextOut(3600,6450,ReplaceParams(':',':Form.BoxNumber:'));            // data replace
			Canvas.TextOut(7850,6450,ReplaceParams(':',':Form.CustomerTelNo:'));  // data replace
//     Canvas.Font.Size := 250;
     Canvas.Font.Size := 10;  //11 9
     TempString := CurrToStrF(StrToCurrDef(ReplaceParams(':',':Form.ImmigrationCharge:'),0),ffNumber,2);
			Canvas.TextOut(8300+(2500-Canvas.TextWidth(TempString)),7400,TempString);      // data replace
     TempString := CurrToStrF(StrToCurrDef(ReplaceParams(':',':Form.ProcessingCharge:'),0),ffNumber,2);
			Canvas.TextOut(8300+(2500-Canvas.TextWidth(TempString)),7850,TempString);      // data replace
     TempString := CurrToStrF(StrToCurrDef(ReplaceParams(':',':Form.QPPDelivery:'),0),ffNumber,2);
			Canvas.TextOut(8300+(2500-Canvas.TextWidth(TempString)),8300,TempString);      // data replace
     Canvas.Font.Style := [fsBold];
     TempString := ReplaceParams(':',':Form.eResidentFee:');
			Canvas.TextOut(8300+(2500-Canvas.TextWidth(TempString)),9200,TempString);      // data replace
     Canvas.Font.Style := [];
//     Canvas.Font.Size := 150;
     Canvas.Font.Size := 6;
     //draw box - charges
     Canvas.Polygon([Point(3700,7300), Point(11200,7300), Point(11200,9700), Point(3700,9700)]);
     // draw horiz line in box
			Canvas.MoveTo(3700,9000);
			Canvas.LineTo(11200,9000);
     // draw vert line in box
			Canvas.MoveTo(8350,7300);
			Canvas.LineTo(8350,9700);
     //draw box - Counter
     Canvas.Polygon([Point(4900,11850), Point(10000,11850), Point(10000,12400), Point(4900,12400)]);
     //draw box - Item ID
     Canvas.Polygon([Point(4900,12700), Point(10000,12700), Point(10000,14500), Point(4900,14500)]);
     //draw box - Collection
     Canvas.Polygon([Point(900,14850), Point(13800,14850), Point(13800,18250), Point(900,18250)]);
     // draw horiz lines in collection box
			Canvas.MoveTo(2450,16200);
			Canvas.LineTo(12200,16200);
			Canvas.MoveTo(2450,17100);
			Canvas.LineTo(12200,17100);
			Canvas.MoveTo(2450,18000);
			Canvas.LineTo(12200,18000);
     // draw dotted line
     Canvas.Pen.Style := psDot;
			Canvas.MoveTo(950,10250);
			Canvas.LineTo(13650,10250);
     Canvas.Pen.Style := psSolid;
//			Canvas.TextOut(950,10000,'--------------------------------------------------------------------------------------------');
     Canvas.Font.Name := 'Times New Roman';
//     Canvas.Font.Size := 280;
     Canvas.Font.Size := 11;  //12 10  12
			Canvas.TextOut(3800,10900,'Please bring this receipt for collecting the item');
     Canvas.Font.Size := 10;  //12 10  11
     Canvas.TextOut(6450,11930,'COUNTER');
     Canvas.TextOut(6550,12780,'ITEM ID.');
     TempString := ReplaceParams(':',':Form.ShippingID:');
     // barcode using a font
     //Canvas.Font.Name := '3 of 9 Barcode';
     //Canvas.Font.Size := 400; //350 340
     //Canvas.TextOut(5100,13200,'*'+TempString+'*');
     //Canvas.TextOut(5100,13450,'*'+TempString+'*');
     //Canvas.TextOut(5100,13650,'*'+TempString+'*');
     // barcode using component - warning don't change the order of properties as it affects the outcome ***
     Barcode := Nil;
     try
       Barcode := TprintBarcode.Create(MainForm);
       Barcode.Parent := MainForm;
       Barcode.Visible := False;
       Barcode.Text := TempString;
       Barcode.AutoSizing := false;
       Barcode.Magnification := 0.1;
       Barcode.Left := 0;
       Barcode.Width := Barcode.Width * 7; // multiplying it actually makes it smaller ??
       Barcode.Top := 0;
       //Barcode.Height := Barcode.Height * 2;
       Barcode.Text := TempString;
       Barcode.ClearZone := false;
       Barcode.Magnification := 0.1;
       //Barcode.Magnification := 0.3;
       Barcode.BarcodeType := EAN128;
       //Barcode.BarcodeType := Code128;
       //Barcode.AutoSizing := True;
       ABitMap := TBitmap.Create;
       ABitmap.Width := Barcode.width;
       ABitmap.Height := Barcode.Height;
       Barcode.DrawBarCode(ABitmap.Canvas,0);
       Canvas.CopyRect(Rect(5800,13200,9100,14100), ABitmap.Canvas, Bounds(0, 0, ABitmap.Width, ABitmap.Height));
     finally
       if Barcode <> Nil then
         Barcode.Free;
       if ABitmap <> Nil then
         ABitmap.Free;
     end;
     // barcode end
     Canvas.Font.Name := 'Times New Roman';
//     Canvas.Font.Size := 280;
     Canvas.Font.Size := 10;  //12 10 11
     Canvas.TextOut(6050,14080,TempString);
     //Canvas.Font.Size := 320;
     Canvas.Font.Size := 11;  //12 10 11
     Canvas.Font.Name := 'Arial';
     Canvas.Font.Style := [fsBold, fsUnderline];
     Canvas.TextOut(5900,14950,'Collection Form');
     Canvas.Font.Style := [fsBold];
     Canvas.TextOut(1000,15700,'Name  :');
     Canvas.TextOut(1000,16600,'ID No  :');
     Canvas.TextOut(1000,17500,'Date   :');
     Canvas.Font.Name := 'Times New Roman';
     Canvas.Font.Style := [];
//     Canvas.Font.Size := 280;
     Canvas.Font.Size := 11;   //12  10
     Canvas.TextOut(950,18400,'Operator : '+ MainForm.CompExec.User); // + User
     // reset to default
     Canvas.Font.Name := 'Arial';
     Canvas.Font.Style := [];
//     Canvas.Font.Size := 250;
     Canvas.Font.Size := 8;  // 10
	 end
   else if (CallBackName = 'WeeklyProdSum') or (CallBackName = 'WeeklyUserSum') then
   begin
      if (ReportsNode <> nil) and (ReportsNode.Logo <> nil) then
      begin
         Logo:=ReportsNode.Logo;
         Canvas.CopyRect(Bounds(PrintRect.Left,PrintRect.Top,Logo.Width*10,Logo.Height*10),Logo.Canvas,Bounds(0,0,Logo.Width,Logo.Height));
      end;

      Canvas.Font.Size:=(FS*2);
      if GetGPCSRegString('','System Name','Tanzania Post') = 'Botswana Post' then
         S:='Botswana Post  -  Weekly Sales Summary -  CONFIDENTIAL'
      else
         S:='Guernsey Post Ltd.  -  Weekly Sales Summary  -  CONFIDENTIAL';
      XOfs:=PrintRect.Left+((PrintRect.Right-PrintRect.Left)-Canvas.TextWidth(S)) div 2;
      Canvas.TextOut(XOfs,YOfs,S);
      Inc(YOfs,Canvas.TextHeight('Wg'));

      Canvas.Font.Size:=(FS*3) div 2;

      S:='Office Name: '+GetGPCSRegString('OfficeInfo','Office Name','Test')+'    '+
         'Office Code: '+MainForm.CompExec.CompExec.Office                  +'    '+
         //'Week No.: '   +IntToStr(DateToWeekNo(Now))                        +'    '+
         //'Start Date: ' +FormatDateTime('dd/mm/yyyy',Now-(DayNumber(Now)-1));
         'Week No.: '   +IntToStr(DateToWeekNo( PeriodToDate(LocalSharedData.GetVariable('FromPeriod')) ))  +'    '+
         'Start Date: ' +FormatDateTime('dd/mm/yyyy',WeekStartingDate( LocalSharedData.GetVariable('FromPeriod')) );

//         'Printed by: ' +MainForm.CompExec.CompExec.RealUser                        ;

      Canvas.TextOut(XOfs,YOfs,S);
//      Inc(YOfs,Canvas.TextHeight('Wg'));

      Canvas.Font.Size:=FS;

      YOfs:=(PrintRect.Top+3000)-Canvas.TextHeight('Wg')*3;
      XOfs:=PrintRect.Left+4800;
      if (CallBackName = 'WeeklyUserSum') then CentreText(Canvas,XOfs-4800,XOfs,YOfs,'Name');
      for I:=0 to 6 do
      begin
         Canvas.PolyLine([Point(XOfs,YOfs+Canvas.TextHeight('Wg')*2),Point(XOfs,YOfs)]);
         CentreText(Canvas,XOfs,XOfs+3100,YOfs,Days[I]);
         Inc(XOfs,3100);
         if I = 6 then Inc(XOfs,200);
      end;
      Canvas.PolyLine([Point(PrintRect.Left,YOfs+Canvas.TextHeight('Wg')*2),Point(PrintRect.Left,YOfs),Point(XOfs,YOfs),Point(XOfs,YOfs+Canvas.TextHeight('Wg')*2)]);

      Inc(YOfs,(Canvas.TextHeight('Wg')*3) div 2);
      XOfs:=PrintRect.Left+4800;
      for I:=0 to 6 do
      begin
         if GetGPCSRegString('','System Name','Tanzania Post') = 'Guernsey Post' then
            CentreText(Canvas,XOfs,XOfs+1700,YOfs,'Value £')
         else
            CentreText(Canvas,XOfs,XOfs+1700,YOfs,'Value');
         Inc(XOfs,1700);
         if I = 6 then Inc(XOfs,100);
         CentreText(Canvas,XOfs,XOfs+1400,YOfs,'Qty.'   ); Inc(XOfs,1400);
      end;
   end
   else if ( CallBackName = 'MonthlyProdAve') or (CallBackName = 'MonthlyUserAve') then
   begin
      if (ReportsNode <> nil) and (ReportsNode.Logo <> nil) then
      begin
         Logo:=ReportsNode.Logo;
         Canvas.CopyRect(Bounds(PrintRect.Left,PrintRect.Top,Logo.Width*10,Logo.Height*10),Logo.Canvas,Bounds(0,0,Logo.Width,Logo.Height));
      end;

      Canvas.Font.Size:=(FS*2);
      if GetGPCSRegString('','System Name','Tanzania Post') = 'Botswana Post' then
         S:='Botswana Post  -  Monthly Sales Averages -  CONFIDENTIAL'
      else
         S:='Guernsey Post Ltd.  -  Monthly Sales Averages  -  CONFIDENTIAL';
      XOfs:=PrintRect.Left+((PrintRect.Right-PrintRect.Left)-Canvas.TextWidth(S)) div 2;
      Canvas.TextOut(XOfs,YOfs,S);
      Inc(YOfs,Canvas.TextHeight('Wg'));

      Canvas.Font.Size:=(FS*3) div 2;

      S:='Office Name: '+GetGPCSRegString('OfficeInfo','Office Name','Test')+'    '+
         'Office Code: '+MainForm.CompExec.CompExec.Office                  +'    '+
         CurrentMonth                                                       +' '  +
         CurrentYear                                                        +'  '  +
         'Printed by: ' +MainForm.CompExec.CompExec.RealUser                       ;

      Canvas.TextOut(XOfs,YOfs,S);
//      Inc(YOfs,Canvas.TextHeight('Wg'));

      Canvas.Font.Size:=FS;

      YOfs:=(PrintRect.Top+3000)-Canvas.TextHeight('Wg')*3;
      XOfs:=PrintRect.Left+4800;
      SW:=StartWeek(LocalSharedData.GetVariable('FromPeriod'));
      EW:=EndWeek(LocalSharedData.GetVariable('FromPeriod'));
      NDFW:=8-DayNumber(StartOfMonth(LocalSharedData.GetVariable('FromPeriod')));
      NDLW:=DayNumber(EndOfMonth(LocalSharedData.GetVariable('FromPeriod')));
      if (CallBackName = 'MonthlyUserAve') then  CentreText(Canvas,XOfs-3000,XOfs,YOfs,'Name');
      for I:=SW to SW+6 do
      begin
         Canvas.PolyLine([Point(XOfs,YOfs+Canvas.TextHeight('Wg')*2),Point(XOfs,YOfs)]);
         if I = SW+6 then
         begin
            CentreText(Canvas,XOfs,XOfs+3000,YOfs,'Monthly Totals');
         end
         else if I <= EW then
         begin
            if (I = SW) and (NDFW < 7) then
            begin
               if NDFW = 1 then
                  CentreText(Canvas,XOfs,XOfs+3000,YOfs,'Week '+IntToStr(I)+' ('+IntToStr(NDFW)+' Day)')
               else
                  CentreText(Canvas,XOfs,XOfs+3000,YOfs,'Week '+IntToStr(I)+' ('+IntToStr(NDFW)+' Days)');
            end
            else if (I = EW) and (NDLW < 7) then
            begin
               if NDLW = 1 then
                  CentreText(Canvas,XOfs,XOfs+3000,YOfs,'Week '+IntToStr(I)+' ('+IntToStr(NDLW)+' Day)')
               else
                  CentreText(Canvas,XOfs,XOfs+3000,YOfs,'Week '+IntToStr(I)+' ('+IntToStr(NDLW)+' Days)');
            end
            else
            begin
               CentreText(Canvas,XOfs,XOfs+3000,YOfs,'Week '+IntToStr(I));
            end;
         end;
         Inc(XOfs,3000);
      end;
      Canvas.PolyLine([Point(PrintRect.Left,YOfs+Canvas.TextHeight('Wg')*2),Point(PrintRect.Left,YOfs),Point(XOfs,YOfs),Point(XOfs,YOfs+Canvas.TextHeight('Wg')*2)]);

      Inc(YOfs,(Canvas.TextHeight('Wg')*3) div 2);
      XOfs:=PrintRect.Left+4800;
      for I:=SW to SW+6 do
      begin
         if GetGPCSRegString('','System Name','Tanzania Post') = 'Guernsey Post' then
            CentreText(Canvas,XOfs,XOfs+3000,YOfs,'Value £')
         else
            CentreText(Canvas,XOfs,XOfs+3000,YOfs,'Value');
         Inc(XOfs,3000);
      end;
   end
   else if (CallBackName = 'MonthlyProdSum') or (CallBackName = 'MonthlyUserSum') then
   begin
      if (ReportsNode <> nil) and (ReportsNode.Logo <> nil) then
      begin
         Logo:=ReportsNode.Logo;
         Canvas.CopyRect(Bounds(PrintRect.Left,PrintRect.Top,Logo.Width*10,Logo.Height*10),Logo.Canvas,Bounds(0,0,Logo.Width,Logo.Height));
      end;

      Canvas.Font.Size:=(FS*2);
      if GetGPCSRegString('','System Name','Tanzania Post') = 'Botswana Post' then
         S:='Botswana Post  -  Monthly Sales Summary -  CONFIDENTIAL'
      else
         S:='Guernsey Post Ltd.  -  Monthly Sales Summary  -  CONFIDENTIAL';
      XOfs:=PrintRect.Left+((PrintRect.Right-PrintRect.Left)-Canvas.TextWidth(S)) div 2;
      Canvas.TextOut(XOfs,YOfs,S);
      Inc(YOfs,Canvas.TextHeight('Wg'));

      Canvas.Font.Size:=(FS*3) div 2;

      S:='Office Name: '+GetGPCSRegString('OfficeInfo','Office Name','Test')+'    '+
         'Office Code: '+MainForm.CompExec.CompExec.Office                  +'    '+
         CurrentMonth                                                       +' '  +
         CurrentYear                                                        +'  '  +
         'Printed by: ' +MainForm.CompExec.CompExec.RealUser                       ;

      Canvas.TextOut(XOfs,YOfs,S);
//      Inc(YOfs,Canvas.TextHeight('Wg'));

      Canvas.Font.Size:=FS;

      YOfs:=(PrintRect.Top+3000)-Canvas.TextHeight('Wg')*3;
      XOfs:=PrintRect.Left+4800;
      SW:=StartWeek(LocalSharedData.GetVariable('FromPeriod'));
      EW:=EndWeek(LocalSharedData.GetVariable('FromPeriod'));
      NDFW:=8-DayNumber(StartOfMonth(LocalSharedData.GetVariable('FromPeriod')));
      NDLW:=DayNumber(EndOfMonth(LocalSharedData.GetVariable('FromPeriod')));

      if (CallBackName = 'MonthlyUserSum') then CentreText(Canvas,XOfs-3000,XOfs,YOfs,'Name');

      for I:=SW to SW+6 do
      begin
         Canvas.PolyLine([Point(XOfs,YOfs+Canvas.TextHeight('Wg')*2),Point(XOfs,YOfs)]);
         if I = SW+6 then
         begin
            CentreText(Canvas,XOfs,XOfs+3300,YOfs,'Monthly Totals');
         end
         else if I <= EW then
         begin
            if (I = SW) and (NDFW < 7) then
            begin
               if NDFW = 1 then
                  CentreText(Canvas,XOfs,XOfs+3100,YOfs,'Week '+IntToStr(I)+' ('+IntToStr(NDFW)+' Day)')
               else
                  CentreText(Canvas,XOfs,XOfs+3100,YOfs,'Week '+IntToStr(I)+' ('+IntToStr(NDFW)+' Days)');
            end
            else if (I = EW) and (NDLW < 7) then
            begin
               if NDLW = 1 then
                  CentreText(Canvas,XOfs,XOfs+3100,YOfs,'Week '+IntToStr(I)+' ('+IntToStr(NDLW)+' Day)')
               else
                  CentreText(Canvas,XOfs,XOfs+3100,YOfs,'Week '+IntToStr(I)+' ('+IntToStr(NDLW)+' Days)');
            end
            else
            begin
               CentreText(Canvas,XOfs,XOfs+3100,YOfs,'Week '+IntToStr(I));
            end;
         end;
         Inc(XOfs,3100);
         if I = SW+6 then Inc(XOfs,200);
      end;
      Inc(YOfs,(Canvas.TextHeight('Wg')*3) div 2);
      XOfs:=PrintRect.Left+4800;
      for I:=0 to 6 do
      begin
         if GetGPCSRegString('','System Name','Tanzania Post') = 'Guernsey Post' then
            CentreText(Canvas,XOfs,XOfs+1700,YOfs,'Value £')
         else
            CentreText(Canvas,XOfs,XOfs+1700,YOfs,'Value');
         Inc(XOfs,1700);
         if I = 6 then Inc(XOfs,100);
         CentreText(Canvas,XOfs,XOfs+1400,YOfs,'Qty.'   ); Inc(XOfs,1400);
      end;

   end
   else if (CallBackName = 'SwazilandCashAccount') or (CallBackName = 'SwazilandStockAccount') then
   begin

      SW:= DateToPeriod( WeekStartingDate( LocalSharedData.GetVariable('FromPeriod') ) );
      if (ReportsNode <> nil) and (ReportsNode.Logo <> nil) then
      begin
         Logo:=ReportsNode.Logo;
         Canvas.CopyRect(Bounds(PrintRect.Left,PrintRect.Top,Logo.Width*10,Logo.Height*10),Logo.Canvas,Bounds(0,0,Logo.Width,Logo.Height));
      end;

      Canvas.Font.Size:=(FS*2);
      if (CallBackName = 'SwazilandCashAccount')then
         S:='SwaziPost  -  AC1 Transactions for Office : ' + ReplaceParams(':',':Form.ReportOffice:')
      else
         S:='SwaziPost  -  AC1 Stock';

      XOfs:=PrintRect.Left+((PrintRect.Right-PrintRect.Left)-Canvas.TextWidth(S)) div 2;
      Canvas.TextOut(XOfs,YOfs,S);
      Inc(YOfs,Canvas.TextHeight('Wg'));

      Canvas.Font.Size:=(FS*3) div 2;

      S:='Printed at Office : '+GetGPCSRegString('OfficeInfo','Office Name','Test')+'    '+
      'Office Code: '+MainForm.CompExec.CompExec.Office                  +'    '+
      CurrentMonth                                                       +' '  +
      CurrentYear                                                        +'  '  +
      'Printed by: ' +MainForm.CompExec.CompExec.RealUser                       ;
      XOfs:=PrintRect.Left+3500+((PrintRect.Right-(PrintRect.Left+3500))-Canvas.TextWidth(S)) div 2;
      Canvas.TextOut(XOfs,YOfs,S);
      Inc(YOfs,Canvas.TextHeight('Wg'));

      Canvas.Font.Size:=FS;

      XOfs:= PrintRect.Left+4600+ 200 ;
      //YOfs:=(PrintRect.Top+1000)-Canvas.TextHeight('Wg')*3;
      // Rectagle box for Dates
      Inc( YOfs, 400 ) ;
      Canvas.PolyLine(
                      [Point(XOfs,YOfs),
                       Point(XOfs,YOfs+( Canvas.TextHeight('Wg')+100  ) ),
                       Point(XOfs+ ( (2700+200)*8 ),YOfs+( Canvas.TextHeight('Wg')+100  )),
                       Point(XOfs+ ( (2700+200)*8 ),YOfs),Point(XOfs,YOfs)]
                      );
      Inc( YOfs, 100 ) ;

      for I:=0 to 6 do
      begin

         S:= PeriodToDateStr( SW + I );
         Canvas.TextOut(XOfs+ 800,YOfs,PeriodToDateStr( Sw+I) );  //Printing the dates
         Inc( XOfs, 2700 + 200 );
         Canvas.PolyLine(
                         [Point(XOfs,YOfs-100),
                          Point(XOfs,YOfs+( Canvas.TextHeight('Wg') +100 ) )]
                         );
      end;

   end ;

end;

function RepCallBack(CallBackName,ColumnName,ReportName,Value:String):String;
begin
   Result:=Value;
   if CallBackName = 'MoneyOrderType' then
   begin
      Result:=Value;
      case StrToInt(Value) of
          0 : Result:='ORD';
          2 : Result:='FAX';
          3 : Result:='MTL';
          6 : Result:='TXA';
          7 : Result:='JNL';
      end;
   end;
end;
function  TMainForm.ReportPreview(Name:String;JustData:Boolean):String;
var
   ReportNode:TReportNode;
   RepNode:TReportNode;
   RepList:TStringList;
   RepFileName:String;
   FD,TD,I:Integer;
   User:String;
   Office:Integer;
   V:Variant;
begin
   if (SubString(Name,'?','?') <> '') then
   begin
     RepFileName:=SubString(Name,'?','?');
     Name := 'Report.'+DelimitedString(Name, RepFileName+'?', True);
   end
   else
      RepFileName:=GetGPCSRegString('Reports','Definition File','Reports.ids');
   if (Copy(RepFileName,1,1) <> '\') and (Copy(RepFileName,2,1) <> ':') then
      RepFileName:=ApplicationRootPath+RepFileName;
   if not FileExists(RepFileName) then
   begin
      RaiseGUIDError('{34B1F01A-7B0D-44E6-B523-7560C8FCB220}', 'Report file not found : ' + RepFileName);
   end
   else                       //file exists
   begin
      ReportsNode:=TReportsNode.Create('Reports',RepFileName,1);
      ReportsNode.ParseFile(ExtractFilePath(RepFileName),RepFileName,1);
      ReportNode:=ReportsNode.ReportNamed(Name);
      if ReportNode <> nil then
      begin
         if LocalSharedData = nil then
            LocalSharedData:=TSharedData.Create('CorvusReportShare',False);
         ShowEmptyReports:=True;

         V:=LocalSharedData.GetVariable('FromPeriod');
         if VarIsEmpty(V) then
         begin
            FD:=GetTodayasPeriod;
            TD:=FD;
            LocalSharedData.SetVariable('FromPeriod',FD);
            LocalSharedData.SetVariable('ToPeriod'  ,TD);
         end
         else
         begin
            FD:=LocalSharedData.GetVariable('FromPeriod');
            TD:=LocalSharedData.GetVariable('ToPeriod'  );
            If TD = 0 then TD := FD;
         end;

         V:=LocalSharedData.GetVariable('Teller');
         if VarIsEmpty(V) then
         begin
            User:=CompExec.CompExec.User;
            If User = 'Supervisor' then User := 'All'; //default to all users
            LocalSharedData.SetVariable('Teller',User);
         end               
         else
         begin
            User:=V;
         end;
         if (UpperCase(User) = 'ALL') or (User = '') then
            LocalSharedData.SetVariable('TellerCondition','(Teller is not null)')
         else
            LocalSharedData.SetVariable('TellerCondition','(Teller = '''+User+''')');

         V:=LocalSharedData.GetVariable('Office');
         if VarIsEmpty(V) then
         begin
            Office:=StrToInt(CompExec.CompExec.Office);
            LocalSharedData.SetVariable('Office',Office);
         end
         else
         begin
            Office:=V;
         end;
         if JustData then
         begin
            UseMsgStoreData:=GetGPCSRegString('Reports','Report Over Message Store','Y') = 'Y';
            JustGetReportData:=True;
            try
               Result:=ReportNode.ExecuteOn(User,Office,0,FD,TD,False,RepCallBack,RepHeadCallBack,RepFootCallBack,nil);
            except
               Result:='';
            end;
            JustGetReportData:=False;
            UseMsgStoreData:=False;
         end
         else
         begin
            InPreviewDialog:=True;
            PreviewReady:=False;
            try
               PrintPreview:=TPrintPreview.Create(nil);
               PrintPanel.Visible:=True;
               PrintPanel.BringToFront;
               PrintPanel.InsertControl(PrintPreview);
               If ReportNode.PaperType = 'A5' then
                  PrintPreview.PaperType := pA5;
               PrintPreview.Align:=alClient;
   //            PrintPreview.Paper.ShadowSize:=5;
   //            PrintPreview.Paper.Repaint;
               PrintPreview.Repaint;
               PrintPreview.Name:='pp';
               PrintPreview.ZoomState:=zsZoomToWidth;
               UsingNewExecute:=True;
               PrintPreview.PrintJobTitle:=ReportNode.Title;
               
               if ReportNode.AllLandscape or ReportNode.AllPortrait then
               begin
                  RepList:=TStringList.Create;
                  for I:=0 to ReportsNode.RepCount-1 do
                  begin
                     if  (not ReportsNode.Report[I].AllLandscape)
                     and (not ReportsNode.Report[I].AllPortrait)
                     and (ReportsNode.Report[I].DataExtractor = '') then                 
                     begin
                        if ReportNode.AllLandscape and ReportsNode.Report[I].Landscape then
                           RepList.Add(ReportsNode.Report[I].Name)
                        else if (ReportNode.AllPortrait) and (not ReportsNode.Report[I].Landscape) then
                           RepList.Add(ReportsNode.Report[I].Name);
                     end;
                  end;
                  
                  if ReportNode.AllLandscape then
                     PrintPreview.Orientation:=poLandscape
                  else
                     PrintPreview.Orientation:=poPortrait;
                  UseMsgStoreData:=GetGPCSRegString('Reports','Report Over Message Store','Y') = 'Y';
                  UseLastResults:=False;
                  MultiSection:=True;
                  ShowEmptyReports:=False;
                  PrintPreview.BeginDoc;
                  for I:=0 to RepList.Count-1 do
                  begin
                     RepNode:=ReportsNode.ReportNamed(RepList[I]);
                     Prompt.Caption:='Processing Report '+IntToStr(I+1)+' of '+IntToStr(RepList.Count);
                     Hint1.Caption:=RepNode.Title;
                     Hint2.Caption:='Please wait...';
                     Repaint;
                     Application.ProcessMessages;
                     RepNode.RightAnchor:=KU.RightAnchor;
                     RepNode.ExecuteOn(User,Office,0,FD,TD,False,RepCallBack,RepHeadCallBack,RepFootCallBack,PrintPreview);
                     if  (RepNode.Query = '') 
                     and (RepNode.FirstQuery = '') 
                     and (RepNode.CSVFile = '') 
                     and (RepNode.DataExtractor = '') then
                        UseLastResults:=True;
                     if PagePrinted and (I <> RepList.Count-1) then
                        PrintPreview.NewPage;
                  end;   
                  RepList.Free;
                  PrintPreview.EndDoc;
                  MultiSection:=False;
                  ShowEmptyReports:=True;
                  UseLastResults:=False;
               end                               
               else
               begin
                  MultiSection:=False;
                  PrintPreview.PrintJobTitle:=ReportNode.Title;
                  if ReportNode.Landscape then
                     PrintPreview.Orientation:=poLandscape
                  else
                     PrintPreview.Orientation:=poPortrait;
                     
                  Prompt.Caption:='Processing Report';
                  Hint1.Caption:=ReportNode.Title;
                  Hint2.Caption:='Please wait...';
                  Repaint;
                  PrintPreview.BeginDoc;
                  UseMsgStoreData:=GetGPCSRegString('Reports','Report Over Message Store','Y') = 'Y';
                  ReportNode.ExecuteOn(User,Office,0,FD,TD,False,RepCallBack,RepHeadCallBack,RepFootCallBack,PrintPreview);
               end;   
               UseMsgStoreData:=False;
               Title.Caption:=ReportNode.Title+' Preview';
               PreviewFunction('Preview');
            except
               PreviewReady:=True;
            end;
         end;
      end;
      if ReportsNode <> nil then
      begin
         try
            ReportsNode.Free;
         except
         end;
         ReportsNode:=nil;
      end;
   end;
end;
procedure TMainForm.FormShow(Sender: TObject);
begin
//   CompExec.UserGroup:='UGroup.Supervisor';
//   CompExec.WorkstationGroup:='WGroup.Dynakey';
   //Tanzania 14/01/99
   TriggerTimeOut := StrToIntDef( GetGPCSRegString('','TriggerTimeOut','4000'), 4000 );

   if not TempHide then
   begin
      CompExec.WorkstationGroup:=GetGPCSRegString('Workstation','Group','WGroup.Dynakey');
      SetupImages;
      if (GetGPCSRegString('Workstation','Login','N') = 'Y') then
      begin
         UserForm.ShowModal;
         CompExec.UserGroup:=UserForm.UserGroup;
         UserGroup:=Copy(UserForm.UserGroup,8,999);
      end;
      if CompExec.TranslationOn then
         FlipSides;

      if (Splash <> nil) and (Splash.Visible) then
      begin
         Splash.Hide;
      end;
   end;
   Compexec.CompExec.OnReportPreview:=ReportPreview;
end;
procedure TMainForm.AppDeactivate(Sender: TObject);
begin
   FormDeactivate(Sender);
end;
function TMainForm.SelectHelp(HelpFile,CurrentExec:String):String;
var
   SL:TPackStringList;
   ResSL:TPackStringList;
   I:Integer;
begin
   HelpFile:=ApplicationRootPath+ExtractFileName(HelpFile);
   SL:=TPackStringList.Create;
   if FileExists(HelpFile) then
   begin
      try
         SL.LoadFromFile(HelpFile);
      except
         ;
      end;
   end;
   I:=0;
   while I < SL.Count do
   begin
      if (SL[I] <> '') and (SL[I][1] ='^') then
      begin
//        If Pos('^' + CurrentExec, SL[I]) > 0 then
         if Trim(Copy(SL[I],2,Length(SL[I]))) = CurrentExec then
         begin
            ResSL:=TPackStringList.Create;
            Inc(I);
            while (Copy(SL[I],1,1) = '^') and (I < SL.Count) do
              Inc(I);
            while I < SL.Count do
            begin
               if (SL[I] <> '') and (SL[I][1] ='^') then break;
               ResSL.Add(SL[I]);
               Inc(I);
            end;
            Result:=ResSL.PackText;
            ResSL.Free;
            SL.Free;
            Exit;
         end;
      end;
      Inc(I);
   end;
   I:=0;
   while I < SL.Count do
   begin
      if (SL[I] <> '') and (SL[I][1] ='^') then
      begin
         ResSL:=TPackStringList.Create;
         Inc(I);
         while I < SL.Count do
         begin
            if (SL[I] <> '') and (SL[I][1] ='^') then break;
            ResSL.Add(SL[I]);
            Inc(I);
         end;
         Result:=ResSL.PackText;
         ResSL.Free;
         SL.Free;
         Exit;
      end;
      Inc(I);
   end;
   Result:='No '+Copy(ExtractFileName(HelpFile),1,Length(ExtractFileName(HelpFile))-4)+' Available';
   SL.Free;
end;
procedure TMainForm.B1Click(Sender: TObject);
begin 
   ShowModalDialog(ptHelp,
   SelectHelp('Help.txt',CompExec.CurrentExec),
   CompExec.TranslateString('Main','Help',1,10,1),
   CompExec.TranslateString('Main','Use Up and Down to move^Then press F11 again to Exit Help',1,8,1),
   B1,nil,nil,'Help','','');
end;

procedure TMainForm.B2Click(Sender: TObject);
begin         
   ShowModalDialog(ptInfo,
      SelectHelp('Regulations.txt',CompExec.CurrentExec),
      CompExec.TranslateString('Main','Information',1,10,1),
      CompExec.TranslateString('Main','Use Up and Down to move^Then press F12 again to Exit Information',1,8,1),
      B2,nil,nil,'Information','','');
end;

function TMainForm.CompExecGetButtonIndex(Button: TControl): Integer;
begin
   Result:=StrToIntDef(Copy((Button as TKGButton).Name,2,5),3)-3;
end;

function TMainForm.CompExecGetButtonOnClick(
  Button: TControl): TNotifyEvent;
begin
   Result:=(Button as TKGButton).OnClick;
end;

procedure TMainForm.CompExecSetButtonOnClick(Button: TControl;
  Handler: TNotifyEvent);
begin
   (Button as TKGButton).OnClick:=Handler;
end;

function TMainForm.CompExecGetButtonRef(Index: Integer): TControl;
begin
   case Index of
      0  : Result:=B3 ;
      1  : Result:=B4 ;
      2  : Result:=B5 ;
      3  : Result:=B6 ;
      4  : Result:=B7 ;
      5  : Result:=B8 ;
      6  : Result:=B9 ;
      7  : Result:=B10;
      8  : Result:=B11;
      9  : Result:=B12;
      else Result:=B3;  
   end;
end;  

procedure TMainForm.CompExecSetButtonBitMap(Button: TControl;
  var BitMap: TBitmap);
begin
   (Button as TKGButton).Glyph:=BitMap;
   if BitMap <> nil then
      BitMap.Assign((Button as TKGButton).Glyph);
end;

procedure TMainForm.CompExecSetButtonCaption(Button: TControl;
  Caption: String);
var
   Index:Integer;
   SL:TPackStringList;
begin
   (Button as TKGButton).Caption:=Caption;
   if Caption = '' then 
      (Button as TKGButton).IsAvailable:=False 
   else 
      (Button as TKGButton).IsAvailable:=True;
   Index:=StrToIntDef(Copy((Button as TKGButton).Name,2,5),99)-3;
   if (Copy(CompExec.CurrentExec,1,1) = 'G') and (PadLines <> nil) then
   begin
      if Index =0 then PadLines.Clear;
      if Caption <> '' then
//         PadLines.SetLine(IntToStr(Index+1)+'    '+Caption,Index)
         PadLines.SetLine(Caption,Index)
      else
         PadLines.SetLine(Caption,Index);
      if  (CompExec <> nil) 
      and (CompExec.TransactionLog <> nil) 
      and (CompExec.TransactionLog.ItemCount <> 0) then
      begin // Stop Multiple Entries
         PadLines.PadMode:=pmTrans;
         TPad.Visible:=True;
         PPad.Visible:=False;
         SL:=TPackStringList.Create;
         SL.PackText:=CompExec.TransactionLog.Contents;
         SL.Insert(0,#1'0'#1'1'#1'0'#1'0'#1'0'#1'0'#1'0"');
         SL.PackText:=CompExec.Translate('<COLUM:1>'+SL.PackText);
         SL.Delete(0);             
         IPControl1.TxnLog(SL.PackText,'','');
         SL.Free;
      end
      else
      begin
         PadLines.PadMode:=pmPick;
         TPad.Visible:=False;
         PPad.Visible:=True;
         IPControl1.PickFrom(PadLines.GetLines,'','','');
      end;
   end;
end;

procedure TMainForm.CompExecSetBitMap(BitMap:TBitmap);
var
   R:TRect;
   BMP:TBitmap;
begin
   BMP:=TBitmap.Create;
//   BMP.PixelFormat:=pf24Bit;
//   BitMap.PixelFormat:=pf24Bit;
   BMP.Width:=BitMap.Width;
   BMP.Height:=BitMap.Height;
   with BMP do R:=Bounds(0,0,Width,Height);
   BMP.Canvas.Brush.Color:=Color;
   BMP.Canvas.FillRect(R);
   PlaceGlyphAt(BMP.Canvas,R,BitMap);
   Image2.Picture.Bitmap.Assign(BMP);
   BMP.Free;
end;

procedure TMainForm.CompExecSetPMessage(Caption:String);
var
   I:Integer;
begin
   for I:=1 to Length(Caption) do
   begin
      if Caption[I] = #13 then
      begin
         Hint1.Caption:=Copy(Caption,1,I-1)+' ';
         Hint2.Caption:=Copy(Caption,I+2,Length(Caption))+' ';
         Exit;
      end;
      if Caption[I] = '^' then
      begin
         Hint1.Caption:=Copy(Caption,1,I-1)+' ';
         Hint2.Caption:=Copy(Caption,I+1,Length(Caption))+' ';
         Exit;
      end;
   end;
   Hint1.Caption:=Caption+' ';
   Hint2.Caption:='';
   IPControl1.Hint:=Caption;
end;

procedure TMainForm.CompExecSetPrompt(Caption: String);
begin
   Prompt.Caption:=Caption+' ';   
end;

procedure TMainForm.CompExecSetTitle(Caption: String);
begin
   Title.Caption:=Caption;
end;
procedure TMainForm.ExceptionEvent(Sender: TObject; E: Exception);
begin
   GlobalExceptionEvent(Sender,E);
end;
procedure TMainForm.SystemClockTimer(Sender: TObject);
var
   S,SplashImageFile:String;
   SystemTime:TSystemTime;
   Buffer:array[0..200] of Char;
   PutBackSplash:Boolean;
const StartTime:TTime = 0;
begin
   if (CompExec <> nil) and (CompExec.CompExec <> nil) and (CompExec.CompExec.Exiting) then Exit;
   try
      if StartTime = 0 then StartTime:=Now;
      if IsServiceBusy then
      begin
         Splash.WarningLabel.Caption:=' ';
         PutBackSplash:=False; 
         if Splash.Visible then PutBackSplash:=True;
         SystemClock.Enabled:=False;
         SplashImageFile:=GetGPCSRegString('','Transaction Update Splash',ApplicationRootPath+'\TUpLogo.bmp');
         if FileExists(SplashImageFile) then
            Splash.Image1.Picture.Bitmap.LoadFromFile(SplashImageFile);
         Splash.RePaint;
         Splash.Show;
         Application.ProcessMessages;
         while IsServiceBusy do
         begin
            Sleep(100);
            Application.ProcessMessages;
            if Application.Terminated then
               Exit;
         end;
         SplashImageFile:=GetGPCSRegString('','Splash',ApplicationRootPath+'\Splash.bmp');
         if FileExists(SplashImageFile) then
            Splash.Image1.Picture.Bitmap.LoadFromFile(SplashImageFile);
         Splash.RePaint;
         if not PutBackSplash then
            Splash.Hide;
         Application.ProcessMessages;
         SystemClock.Enabled:=True;
         Exit;
      end;           
   finally
   end;
   try
      SystemClock.Interval:=500;
      Splash.WarningLabel.Caption:=' ';
      if GetGPCSRegString('','Show Reference','0') = '1' then
      begin
         Label1.Caption:=DateTimeToStr(FileDateToDateTime(FileAge(Application.ExeName)));
         Reference.Caption:=CompExec.CurrentExec;
      end
      else
      begin
         Label1.Caption:='';
         Reference.Caption:='';
      end;
      if CompExec.TranslationOn then
      begin
         S:=FormatDateTime('dddd',Now);
         DateTimeToSystemTime(Now,SystemTime);
   {$ifdef SAUDI}      
         GetDateFormat($00000401,DATE_LONGDATE,@SystemTime,nil,Buffer,SizeOf(Buffer));
   {$else}
         GetDateFormat(GetThreadLocale,DATE_LONGDATE,@SystemTime,nil,Buffer,SizeOf(Buffer));
   {$endif}
         S:=S+'  '+Buffer;
         S:=S+'  '+FormatDateTime('hh:nn',Now);
         S:=S+'    '+CompExec.User;
         S:=S+' '+CompExec.Workstation;
         S:=S+' '+CompExec.Office;
      end
      else
      begin
         S:=FormatDateTime('dddd, dd mmmm yyyy, hh:nn',Now) +
            '  U.'+CompExec.User +
             ' P.'+CompExec.Workstation +
             ' O.'+CompExec.Office;
      end;
      if not ValidInstall then
         S:='Evaluation Copy';
      if Time.Caption <> S then
         Time.Caption:=S;
      if Now > (StartTime+(2*OneMinute)) then
   //   B2.Flashing := not B2.Flashing;
  finally
  end;
end;

procedure TMainForm.CompExecSetButtonPrice(Button: TControl; Price: Currency);
var
   Value:String;
begin
   if Price <> 0 then
   begin
     Price := Abs(Price); //always show as +ve
     If Frac(Price) = 0 then
       Value:=CurrToStr(Price)  //no decimals shown
     else
       Value := CurrToStrF(Price, ffFixed, CurrencyDecimals); //defined by control panel
//      Str(Price:15:2,Value);
      Value:=Trim(Value);
      (Button as TKGButton).Price:=Value;
   end
   else
   begin
      (Button as TKGButton).Price:='';
   end;
end;

function MapKey(VK:Integer;Shift:Boolean):Char;
var
   ScanCode:Integer;
begin
  // Result:=Char(VK));
  // Exit;

   Result:=Char(MapVirtualKey(VK,2));
   ScanCode:=MapVirtualKey(VK,0);
   if Shift then
   begin
      case ScanCode of
          $001E : Result:='A'; // a
          $0030 : Result:='B'; // b
          $002E : Result:='C'; // c
          $0020 : Result:='D'; // d
          $0012 : Result:='E'; // e
          $0021 : Result:='F'; // f
          $0022 : Result:='G'; // g
          $0023 : Result:='H'; // h
          $0017 : Result:='I'; // i
          $0024 : Result:='J'; // j
          $0025 : Result:='K'; // k
          $0026 : Result:='L'; // l
          $0032 : Result:='M'; // m
          $0031 : Result:='N'; // n
          $0018 : Result:='O'; // o
          $0019 : Result:='P'; // p
          $0010 : Result:='Q'; // q
          $0013 : Result:='R'; // r
          $001F : Result:='S'; // s
          $0014 : Result:='T'; // t
          $0016 : Result:='U'; // u
          $002F : Result:='V'; // v
          $0011 : Result:='W'; // w
          $002D : Result:='X'; // x
          $0015 : Result:='Y'; // y
          $002C : Result:='Z'; // z
          $0002 : Result:='!'; // 1
          $0003 : Result:='"'; // 2
          $0004 : Result:='£'; // 3
          $0005 : Result:='$'; // 4
          $0006 : Result:='%'; // 5
          $0007 : Result:='^'; // 6
          $0008 : Result:='&'; // 7
          $0009 : Result:='*'; // 8
          $000A : Result:='('; // 9
          $000B : Result:=')'; // 0
          $000D : Result:='+'; // +
      end;
   end
   else // no shift
   begin
      case ScanCode of
         79,$0002 : Result:='1'; // 1
         80,$0003 : Result:='2'; // 2
         81,$0004 : Result:='3'; // 3
         75,$0005 : Result:='4'; // 4
         76,$0006 : Result:='5'; // 5
         77,$0007 : Result:='6'; // 6
         71,$0008 : Result:='7'; // 7
         72,$0009 : Result:='8'; // 8
         73,$000A : Result:='9'; // 9
         82,$000B : Result:='0'; // 0
         $000D : Result:='='; // +
         $0039 : Result:=' '; //
         $000C : Result:='-'; // -
         $0034 : Result:='.'; // .
         $0035 : Result:='/'; // /
      end;
   end;
end;
const
  CompStr='$%+ -./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
function B43toCurr(S:String):Currency;
var
   I,J:Integer;
begin
   Result:=0;
   for I:=Length(S) downto 1 do
   begin
       Result:=Result*43.0;
       for J:=1 to 43 do
       begin
          if S[I] = CompStr[J] then
          begin
             Result:=Result+(J-1);
             break;
          end;
       end;
   end;
end;
function FormatTrigger(Value:String; Source:TriggerSource):String;
begin
   //if Length(Value) = 8 then
   //begin
   //   Try
   //      Result:=CurrToStr(B43ToCurr(Value));
   //   except
   //      ;
   //   end;
   //end
   //else
   //   Result:=Value;
   //
   //Result:=','+Result+',';

   if Source=tsMCRReader then
      Result:='&'+Value+'&'
   else
      Result:=','+Value+','; // assume Source=tsBarcode
end;
procedure LogKeyPress(Key: Word;Shift:TShiftState);
var
   FS:TFileStream;
begin
   if FileExists('C:\KeyStrokes.log') then
      FS:=TFileStream.Create('C:\KeyStrokes.log',fmOpenReadWrite)
   else
      FS:=TFileStream.Create('C:\KeyStrokes.log',fmCreate);
   FS.Position:=FS.Size;

   FS.Write(Key  ,sizeof(Key));
   FS.Write(Shift,sizeof(Shift));
   FS.Free;
end;
procedure TMainForm.IPControl1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
   ClearKey:Boolean;
   C:Char;
   SL:TPackStringList;
   I:Integer;
   RealUserName,UserName,WorkStation,Office:String;
   ClerkCode,ClerkOfficeCode,ClerkLevel:Integer;
const
   CollectingTrigger:Boolean = False;
   CancelIgnore     :Boolean = False;
   Source           :TriggerSource = tsBarcode;
   CurrentTrigger   :Word = 0;
begin

   if CollectingTrigger and ((DateTimeToTimeStamp(Now).Time-TriggerStartTime.Time) > TriggerTimeOut) then
   begin
      TDomainEdit(Sender).StateTrigger:= noTriggerCode;
   end ;
   
   if TDomainEdit(Sender).StateTrigger=noTriggerCode then
      CollectingTrigger := False;

   if LoggingKeyPresses then
      LogKeyPress(Key,Shift);
   if InPreviewDialog then
   begin
      if PreviewReady then
      begin
         case Key of
            VK_F1     : B3.ForceClick;
            VK_F3     : B5.ForceClick;
            VK_F4     : B6.ForceClick;
            VK_F5     : B7.ForceClick;
            VK_F6     : B8.ForceClick;
            VK_F7     : B9.ForceClick;
            VK_F8     : B10.ForceClick;
            VK_ESCAPE : KC.ForceClick;
            VK_PRIOR  : PreviewFunction('Previous Page');
            VK_NEXT   : PreviewFunction('Next Page');
            VK_DOWN   : PreviewFunction('Bottom of Page');
            VK_UP     : PreviewFunction('Top of Page');
            VK_HOME   : PreviewFunction('First Page');
            VK_END    : PreviewFunction('Last Page');
         end;
      end;
      Key:=0;
      Exit;
   end;
   CompExec.SetKeyHit;
   ClearKey:=True;

   if TDomainEdit(Sender).StateTrigger=CancelTriggerCode then //ReadyToStart then
   begin
      IPControl1.Ignore:=False;
      TDomainEdit(Sender).StateTrigger:=noTriggerCode;
//      RaiseGUIDError('Pass-7 IPControlKey Down free it ', IntToStr(Key) );
   end;
   if (CancelIgnore) and (Key <> 37) then
   begin
      IPControl1.Ignore:=False;
      CancelIgnore:=False;
   end;
   // if not in a dropdown list or key=a number
   if not((PadLines.PadMode = pmPick) and (IPControl1.InSwapTo)) or (Key in [48..57]) then
   begin
      case Key of
         VK_F1      : B3 .ForceClick;
         VK_F2      : B4 .ForceClick;
         VK_F3      : B5 .ForceClick;
         VK_F4      : B6 .ForceClick;
         VK_F5      : B7 .ForceClick;
         VK_F6      : B8 .ForceClick;
         VK_F7      : B9 .ForceClick;
         VK_F8      : B10.ForceClick;
         VK_F9      : B11.ForceClick;
         VK_F10     : B12.ForceClick;
         VK_F11     : B1 .ForceClick;
         VK_F12     : B2 .ForceClick;
         VK_HOME    : KT.ForceClick;
         VK_UP      : if IPControl1.InModal then KU.ForceClick;
         VK_DOWN    : if IPControl1.InModal then KD.ForceClick;
//         VK_PRIOR   : ClearKey:=False;
//         VK_NEXT    : ClearKey:=False;
         VK_ESCAPE  : KC.ForceClick;
         VK_SCROLL : FLipSides;
         VK_END     : begin
                         if  (Copy(CompExec.CurrentExec,1,8) <> 'Product.')
                         and (GetGPCSRegString('Workstation','Switch','No') <> 'No') then
                         begin
                            SL:=TPackStringList.Create;
                            UserName:=CompExec.CompExec.RealUser;
                            SL.PackText:=CompExec.CompExec.Users;
                            I:=SL.IndexOf(UserName);
                            if (I = -1) and (SL.Count > 0) then I:=0;
                            if I >= 0 then
                            begin
                              //show user selection form
                              UsersForm.UsersListBox.Items.Assign(SL);
                              UsersForm.UsersListBox.ItemIndex := I;
                              If mrOK = UsersForm.ShowModal then
                              begin
                                I := UsersForm.UsersListBox.ItemIndex;
                                if I < SL.Count then
                                  UserName:=SL[I]
                                else
                                  UserName:=SL[0];
                                GetUserDetails(UserName,RealUserName,UserGroup,WorkStation,Office,ClerkCode,ClerkOfficeCode,ClerkLevel);
                                CompExec.User:=UserName;
                                CompExec.CompExec.ClerkCode      :=ClerkCode      ;
                                CompExec.CompExec.ClerkOfficeCode:=ClerkOfficeCode;
                                CompExec.CompExec.ClerkLevel     :=ClerkLevel     ;
                                CompExec.CompExec.RealUser:=RealUserName;
                                CompExec.CompExec.Users:=Users;
                                CompExec.UserGroup:='UGroup.'+UserGroup;
                                CompExec.WorkStation:=WorkStation;
                                CompExec.Office:=Office;
                                CompExec.CompExec.Txnlog.User:=UserName;
                                CompExec.CompExec.CheckStartOfDay(True);
                              end;        
                            end
                            else
                            begin
                               ShowMessage('No Other Users Found!');
                            end;
                            SL.Free;
                         end;
                      end;
         55, 56,
         //219,221   : if (((ssShift in Shift) and (Key in [55,56])) or
         219   : if (((ssShift in Shift) and (Key in [55,56])) or
                     //  (not(ssShift in Shift) and (Key in [219,221]) )) then  // Reading either a new trigger or a matching trigger Char
                       (not(ssShift in Shift) and (Key in [219]) )) then  // Reading either a new trigger or a matching trigger Char
                      begin
                        //  Key:=0;
                          if CollectingTrigger and (Key in [55,56,219]) then // Suffix Trigger Char
                          begin
                             CollectingTrigger:=False;
                             //TDomainEdit(Sender).DontGetText:=True;
                             TDomainEdit(Sender).StateTrigger:= CancelTriggerCode;
//                             RaiseGUIDError('Pass-8 IPControlKey Down Cancel  ', IntToStr(Key) );
                             CancelIgnore:=True;
                             if InList then
                             begin
                                CompExec.FireTrigger(FormatTrigger(TriggerValue, Source));
                             end
                             else
                             begin
                                if CompExec.CurrentExec[1] <> 'P' then
                                begin
                                   ExecuteByMask(FormatTrigger(TriggerValue, Source))
                                end
                                else
                                begin
                                   //TDomainEdit(Sender).Text := '';
                                   CompExec.FireTrigger(FormatTrigger(TriggerValue, Source));
                                end;
                             end;

                             CurrentTrigger:=0;
                             Key:=0;
                          end
                          else if not CollectingTrigger and (Key in [55,56]) then // ,221]) then // Prefix Trigger Char
                          begin
                            TDomainEdit(Sender).StateTrigger:=GetTriggerCode;
//                             RaiseGUIDError('Pass-8 IPControlKey Set it to GetTriggerCode ', IntToStr(Key) );
                             IPControl1.Ignore:=true;
                             TriggerStartTime := DateTimeToTimeStamp(Now);
                             IPControl1.Ignore:=True;
                             CollectingTrigger:=True;
                             case Key of
                                55  : Source:=tsMCRReader;  // shift + 55  = '&'  Track1 MCR Prefix
                                // 221 : Source:=tsMCRReader;  // shift + 221 = ']'  Track2 MCR Prefix
                                56  : Source:=tsBarCode;    // shift + 56  = '*'  BarCode Prefix
                             end;
                             CurrentTrigger:=Key;
                          end;
                          TriggerValue:='';
                      end
                      else
                      begin
                         C:=MapKey(Key,ssShift in Shift);
                         if (CollectingTrigger) and (C > #31) then
                            TriggerValue:=TriggerValue+C;
                         Key:=0;
                      end;
         else
             if CollectingTrigger    then
             begin
                C:=MapKey(Key,ssShift in Shift);
                if (C > #31) then
                   TriggerValue:=TriggerValue+C;
             end
             else
             begin
                ClearKey:=False;
             end;
      end;
      if ClearKey or InList then Key:=0;

   end;
end;

procedure TMainForm.KCClick(Sender: TObject);
begin
        if not B1.ButtonIsUp then B1.ForceClick
   else if not B2.ButtonIsUp then B2.ForceClick
   else
   begin
      if (Copy(CompExec.CurrentExec,1,8) = 'Product.') and (IPControl1.FormModified) then
      begin
         KC.ButtonIsUp:=True;
         ShowModalDialog(ptError,
            #1+CompExec.TranslateString('Main','Warning',0,0,0)
              +#1+CompExec.TranslateString('Main','Pressing this key will Cancel the',0,0,0)+' '
              +#1+Title.Caption
              +#1+CompExec.TranslateString('Main',' operation !',0,0,0)
              +#1+CompExec.TranslateString('Main','Press <ESC> "Cancel" again to Confirm',0,0,0)
              +#1+CompExec.TranslateString('Main','Press <F1> "Return" to go back',0,0,0),
            CompExec.TranslateString('Main','Error',1,10,1),
            CompExec.TranslateString('Main','Press <ESC> again to Confirm^Press <F1> to go back',1,8,1),
            KC,B3,nil,'Cancel','Return','');
      end
      else
      begin
         CompExec.Cancel;
      end;
   end;
end;

procedure TMainForm.KTClick(Sender: TObject);
begin
   if (Copy(CompExec.CurrentExec,1,8) = 'Product.') and (IPControl1.FormModified) then
   begin
      KT.ButtonIsUp:=True;
      ShowModalDialog(ptError,
            #1+CompExec.TranslateString('Main','Warning',0,0,0)
            +#1+CompExec.TranslateString('Main','Pressing this key will Cancel the',0,0,0)+' '
            +#1+Title.Caption
            +#1+CompExec.TranslateString('Main',' operation !',0,0,0)
            +#1+CompExec.TranslateString('Main','Press <Home> "Top Menu" again to Confirm',0,0,0)
            +#1+CompExec.TranslateString('Main','Press <F1> "Return" to go back',0,0,0),
         CompExec.TranslateString('Main','Error',1,10,1),
         CompExec.TranslateString('Main','Press <Home> again to Confirm^Press <F1> to go back',1,8,1),
         KT,B3,nil,'Top Menu','Return','');
   end
   else 
   begin
      CompExec.CancelToTop;
   end;
end;

procedure TMainForm.KDClick(Sender: TObject);
begin
   IPControl1.MoveKey(VK_DOWN);
end;

procedure TMainForm.IPControl1SelectItem(var Value: Integer);
begin
   PadLines.Highlight(Value);
end;

function MaskMatches(Mask,Value:String):Boolean;
var
   I:Integer;
begin
   Value:=Copy(Value,2,Length(Value)-2);
   Result:=False;
   if Length(Mask) <> Length(Value) then Exit; // Mismatch on size
   for I:=1 to Length(Mask) do
   begin
      case Mask[I] of
         'A' : if not (Value[I] in ['A'..'Z']) then Exit; // Mismatch on char Field
         'X' : if not (Value[I] in ['0'..'9','A'..'Z']) then Exit; // Mismatch on alnumb Field
         '9' : if not (Value[I] in ['0'..'9']) then Exit; // Mismatch on numb Field
         else  if Value[I] <> Mask[I] then Exit;          // Mismatch on same Field
      end;
   end;
   Result:=True;
end;

procedure TMainForm.ExecuteByMask(MaskVal:String);
var
  TriggerList:TPackStringList;
  I:Integer;
const
   BVI:Boolean = False;

begin
   if MaskVal = '' then Exit;
   if BVI then
   begin
      if (IsNumber(Copy(MaskVal,2,Length(MaskVal)-2))) and (Length(MaskVal) > 9) then
      begin
         MaskVal:=Copy(MaskVal,2,Length(MaskVal)-2);
         MaskVal:=','+LeftPad(IntToStr((CalcCCITTCRC(MaskVal) and $3FFFFFF) xor (CalcCCITTCRC(MaskVal) shr 6) and $3FFFFFF),8,'0')+',';
         CompExec.CompExec.ReferenceData('SET(TRIGGER,'+Copy(MaskVal,2,Length(MaskVal)-2)+')');
      end;
   end; 
   TriggerList:=TPackStringList.Create;
   TriggerList.CommaText:=GetGPCSRegNames('Triggers','');
   for I:=0 to TriggerList.Count-1 do
   begin
      if MaskMatches(TriggerList[I],MaskVal) then
      begin
            CompExec.TriggerValue:=MaskVal;
            CompExec.Execute(GetGPCSRegString('Triggers',TriggerList[I],''),False);
            CompExec.TriggerValue:='';
         Break;            
      end;
   end;
   TriggerList.Free;
end;
procedure TMainForm.IPControl1ItemPicked(var Value: String; Index: Integer);
var
  ExecData:String;
  ProgID:WideString;
begin
   if InList then
   begin
      CompExec.FireTrigger(','+Value+',');
   end
   else if PadLines.PadMode = pmAcct then
   begin
      CompExec.SelectAccount(Value);
   end
   else if PadLines.PadMode = pmTrans then
   begin
       if Value = 'Delete' then
       begin
          CompExec.TransactionLog.Delete(Index);
       end
       else
       begin
          ExecData:=CompExec.TransactionLog.GetExecData(Index,ProgID);
          if ExecData <> '' then
          begin
             CompExec.TransactionLog.Delete(Index);
             CompExec.ExecuteWith(ProgID,ExecData);
             IPControl1.FormModified:=True;
          end;
       end  
   end     
   else
   begin
      case Index of
         0 : B3 .ForceClick;
         1 : B4 .ForceClick;
         2 : B5 .ForceClick;
         3 : B6 .ForceClick;
         4 : B7 .ForceClick;
         5 : B8 .ForceClick;
         6 : B9 .ForceClick;
         7 : B10.ForceClick;
         8 : B11.ForceClick;
         9 : B12.ForceClick;
      end; 
   end;
end;

procedure TMainForm.CompExecSetFormData(Caption: String;FlagError,NewForm,DontUpdate:Boolean);
begin
   if not IPControl1.InSwapTo then 
   begin
      IPControl1.DontUpdate:=DontUpdate;
      if NewForm then IPControl1.FormModified:=False;
      IPControl1.ShowForm(Caption,FlagError,NewForm);
      IPControl1.DontUpdate:=False;
   end;
end;

procedure TMainForm.IPControl1SetList(var Value: String);
begin
   PadLines.SetLines(Value,InForm);
end;

procedure TMainForm.IPControl1SetPrompt(var Value: String);
begin
   if (Value <> '') and ((Value[1] = 'M') or (Value[1] = 'S')) then
      CompExecSetPrompt(CompExec.TranslateString('Main',Value,0,0,0))
   else
      CompExecSetPrompt(Value);                               
end;

procedure TMainForm.IPControl1SetHint(var Value: String);
begin
   Hint1.Font.Color:=Time.Font.Color;
   Hint2.Font.Color:=Time.Font.Color;
   if (Value <> '') and ((Value[1] = 'M') or (Value[1] = 'S')) then
      CompExecSetPMessage(CompExec.TranslateString('Main',Value,0,0,0))
   else
      CompExecSetPMessage(Value);
end;

procedure TMainForm.IPControl1SetMode(var Value: TIPMode);
begin
  //PadLines.RightAnchor:=RightAnchor;
   if Value = ipmPick then
   begin
      PPad.Visible:=True;
      TPad.Visible:=False;
      FPad.Visible:=False;
      APad.Visible:=False;
      PadLines.PadMode:=pmPick;
      InForm:=False;
      InList:=False;
   end
   else if Value = ipmAcct then
   begin
      PPad.Visible:=False;
      APad.Visible:=True;
      FPad.Visible:=False;
      TPad.Visible:=False;
      PadLines.PadMode:=pmAcct;
      InForm:=False;
      InList:=False;  
   end
   else if Value = ipmTrans then
   begin
      PPad.Visible:=False;
      TPad.Visible:=True;
      FPad.Visible:=False;
      APad.Visible:=False;
      PadLines.PadMode:=pmTrans;
      InForm:=False;
      InList:=False;  
   end
   else if Value = ipmList then
   begin
      PPad.Visible:=True;
      TPad.Visible:=False;
      APad.Visible:=False;
      FPad.Visible:=False;
      PadLines.PadMode:=pmPick;
      InForm:=False;
      InList:=True;  
   end
   else if Value = ipmCols then
   begin
      PPad.Visible:=True;
      FPad.Visible:=False;
      TPad.Visible:=False;
      APad.Visible:=False;
      PadLines.PadMode:=pmCols;
      InForm:=False;
      InList:=True;  
   end
   else if Value = ipmForm then
   begin
      InForm:=True;
      PPad.Visible:=False;
      TPad.Visible:=False;
      FPad.Visible:=True;
      APad.Visible:=False;
      PadLines.PadMode:=pmForm;
      InList:=False;  
   end;                        
end;    
        
procedure TMainForm.FormDestroy(Sender: TObject);
var
  CMouse:TPoint;
begin
   Application.OnException:=nil;
   try
      SystemClock.Enabled:=False;
      If CompExec.CompExec.Stock <> nil then 
         CompExec.CompExec.Stock.ClearTempAdjustments(CompExec.CompExec.User);
      if LAScale <> nil then LAScale.Free;
      if RAScale <> nil then RAScale.Free;
      TurnSysKeysOn;
      PSLDatabase.Free;
      GetCursorPos(CMouse);
      if (CMouse.X = Screen.Width-1) and (CMouse.Y = Screen.Height-1) then
         SetCursorPos(MOUSEXY.X,MOUSEXY.Y);
      CompExec.CompExec.CloseAllLinks;
   except
   end;
   Sleep(5000);
   KillCorvusSubs;
   Sleep(2000);
   KillApp(ExtractFileName(ParamStr(0)));
end;                           

procedure TMainForm.FormDeactivate(Sender: TObject);
begin
//   SetForegroundWindow(Handle);
end;

procedure TMainForm.IPControl1SetError(var Value: String);
begin
   Hint1.Font.Color:=clRed;
   Hint2.Font.Color:=clRed;
   if CompExec.CompExec.ReferenceData('GET(ErrorText)') <> '' then
      Value:=CompExec.CompExec.ReferenceData('GET(ErrorText)');
   CompExecSetPMessage(Value);
   CompExec.CompExec.ReferenceData('SET(ErrorText,)');
end;


procedure TMainForm.CompExecSetScale(Caption: String);
begin
   if (CompExec.CompExec.ScaleReading >= 0) and (not CompExec.CompExec.UnderRemoteControl) then
   begin
      ScaleIndicator.Brush.Color:=clLime;
      ScaleIndicator.Visible:=True;
   end
   else if (CompExec.CompExec.ScaleReading = -2) then
   begin
      ScaleIndicator.Brush.Color:=clRed;
      ScaleIndicator.Visible:=True;
   end
   else
   begin
      ScaleIndicator.Visible:=False;
   end;

   if Caption = 'NONE' then
   begin
      if ScaleOK   .Visible <> False then ScaleOK   .Visible:=False;
      if ScaleError.Visible <> True  then ScaleError.Visible:=True ;
      Scale.Caption:='';
   end
   else
   begin
      if ScaleOK   .Visible <> True  then ScaleOK   .Visible:=True ;
      if ScaleError.Visible <> False then ScaleError.Visible:=False;
      Scale.Caption:=Caption;
   end;
end;

function TMainForm.IPControl1DataChange(var Value: String): Boolean;
begin
   Result:=CompExec.FormDataChanged(Value);
end;

procedure TMainForm.CompExecDisplayInstruct(Text, BitMap: String);
var
   BMP:TBitMap;
   I:Integer;
begin
   if Text = 'HELP' then
   begin
      if IPControl1.ModalExcept = '' then IPControl1.ModalExcept:='Help' else IPControl1.ModalExcept:='';
      B1.ForceClick;
   end
   else if Text = 'INFO' then
   begin
      if IPControl1.ModalExcept = '' then IPControl1.ModalExcept:='Information' else IPControl1.ModalExcept:='';
      B2.ForceClick;
   end
   else if Text = 'CANCEL' then
   begin
      KC.ForceClick;
   end
   else if Text = 'TOPMENU' then
   begin
      KT.ForceClick;
   end
   else if Text = '****' then
   begin
      if KU.RightAnchor then
         CompExec.TranslationOn:=False
      else
         CompExec.TranslationOn:=True;
      FlipSides;
      CompExec.WorkstationGroup:=CompExec.WorkstationGroup;
   end     
   else if Text = '***' then
   begin
      PadLines.SetLines('',False);
      PadLines.PadMode:=pmPick;
      PPad.Visible:=True;
      IPad.Visible:=False;
      InstImage.Picture.Bitmap.Assign(nil);
      for I:=0 to ComponentCount-1 do
      begin
         if (Components[I] is TKGButton) then
         begin
            (Components[I] as TKGButton).Enabled:=True;
            (Components[I] as TKGButton).IsAvailable:=True;
            (Components[I] as TKGButton).ToggleWhenClicked:=True;
            (Components[I] as TKGButton).ToggleWhenClicked:=False;
            (Components[I] as TKGButton).Flashing:=False;
         end;
      end;
      ToggleButtonState(True);
      CompExec.PutBack;
      RePaint;
   end
   else if Text = '' then
   begin
      ToggleButtonState( TRUE );
      IPControl1.KeyBoardDisabled := FALSE ;
      IPControl1.InModal := FALSE ;
      CompExec.DontTrigger:=FALSE;
      PadLines.SetLines('',False);
      PadLines.PadMode:=pmPick;
      PPad.Visible:=True;
      IPad.Visible:=False;
      InstImage.Picture.Bitmap.Assign(nil);
      CompExec.PutBack;
      RePaint;
   end
   else
   begin
      ToggleButtonState( FALSE );
      IPControl1.KeyBoardDisabled := TRUE ;
      IPControl1.InModal := TRUE ;
      CompExec.DontTrigger:=TRUE;
      Prompt.Caption:='';
      Hint1.Caption:='';
      Hint2.Caption:='';
      FPad.Visible:=False;
      PPad.Visible:=False;
      IPad.Visible:=True;
      PadLines.Highlight(-1);
      PadLines.SetLines(Text,False); // Tanzania
      PadLines.PadMode:=pmInst;
      BMP:=CompExec.GetPictureFromServer(BitMap);
      InstImage.Picture.Bitmap.Assign(BMP);
      InstImage.Repaint;
      PadLines.Paint;
      BMP.Free;
   end;
end;

procedure TMainForm.KUClick(Sender: TObject);
begin
   IPControl1.MoveKey(VK_UP);
end;

procedure TMainForm.CompExecSetTransactions(Caption: String);
var
   SL:TPackStringList;
begin
   if Caption <> '' then
   begin
      SL:=TPackStringList.Create;
      SL.PackText:=Caption;
      SL.Insert(0,#1'0'#1'1'#1'0'#1'0'#1'0'#1'0'#1'0');
      SL.PackText:=CompExec.Translate('<COLUM:1>'+SL.PackText);
      SL.Delete(0);
      IPControl1.TxnLog(SL.PackText,'','');
      SL.Free;
   end
   else
   begin
      CompExec.ReFreshUI;
      PadLines.PadMode:=pmPick;
      TPad.Visible:=False;
      PPad.Visible:=True;
   end;
end;

procedure TMainForm.CompExecSetButtonToggle(Button: TControl; State: Integer);
begin
   case State of
     BUTTON_UP               : (Button as TKGButton).ButtonIsUp:=True ;
     BUTTON_DOWN             : (Button as TKGButton).ButtonIsUp:=False;
     BUTTON_TOGGLE           : (Button as TKGButton).ToggleWhenClicked:=True;
     BUTTON_ENABLED          : ;
     BUTTON_DISABLED         : ;
     BUTTON_ENABLED_UP       : begin (Button as TKGButton).Enabled:=True;  (Button as TKGButton).ButtonIsUp:=True;       (Button as TKGButton).ToggleWhenClicked:=True;  end;
     BUTTON_ENABLED_DOWN     : begin (Button as TKGButton).Enabled:=True;  (Button as TKGButton).ButtonIsUp:=False;        end;
     BUTTON_ENABLED_TOGGLE   : begin (Button as TKGButton).Enabled:=True;  (Button as TKGButton).ToggleWhenClicked:=True;  end;
     BUTTON_DISABLED_UP      : begin { (Button as TKGButton).Enabled:=False; } (Button as TKGButton).ButtonIsUp:=True;       (Button as TKGButton).ToggleWhenClicked:=True;  end;
     BUTTON_DISABLED_DOWN    : begin { (Button as TKGButton).Enabled:=False; } (Button as TKGButton).ButtonIsUp:=False;        end;
     BUTTON_DISABLED_TOGGLE  : begin { (Button as TKGButton).Enabled:=False; } (Button as TKGButton).ToggleWhenClicked:=False; end;
   end;
end;
procedure TMainForm.GetUserDetails(var UserName,RealUserName,UserGroup,WorkStation,Office:String;var ClerkCode,ClerkOfficeCode,ClerkLevel:Integer);
var
   SL:TPackStringList;
   I:Integer;
//   State:esState;
const
   UseLocalMachine:Boolean = False;
begin
   if UserName = '' then
      UserName:=GetUserLoginName;
   Users:=UserName;
   SL:=TPackStringList.Create;
   UserGroup:='';
   try
      if GetGPCSRegString('','Primary Domain Controller','') = 'None' then
         UseLocalMachine:=True;
      if UseLocalMachine then
         ServerName:=''
      else
      begin
        ServerName:=GetGPCSRegString('', 'Primary Domain Controller', '');
        If ServerName = '' then
          ServerName:=CompExec.CompExec.NetManager.GetPDC;
        SetGPCSRegString('', 'Primary Domain Controller', ServerName);
      end;

      if ServerName = '' then
      begin
         UseLocalMachine:=True;
         ServerName:=GetLocalMachineName;
         Users:=CompExec.CompExec.NetManager.GetUsers(ServerName);
         CompExec.CompExec.Users:=Users;
         SL.CommaText:=CompExec.CompExec.NetManager.GetMemberLocalGroups(ServerName,UserName);
         //CompExec.CompExec.NetUser.SetUser(ServerName,UserName);
         //CompExec.CompExec.NetUser.GetUserInformation ;
         //SL.CommaText:=CompExec.CompExec.NetUser.MemberOfLocal;

      end
      else
      begin
         Users:=CompExec.CompExec.NetManager.GetUsers(ServerName);
         CompExec.CompExec.Users:=Users;
         SL.CommaText:=CompExec.CompExec.NetManager.GetMemberGlobalGroups(ServerName,UserName);;
         //CompExec.CompExec.NetUser.SetUser(ServerName,UserName);
         //CompExec.CompExec.NetUser.GetUserInformation ;
         //SL.CommaText:=CompExec.CompExec.NetUser.MemberOfGlobal;

      end;
      for I:=0 to SL.Count-1 do
      begin
         if UpperCase(Copy(SL[I],1,4)) = 'GPCS' then
         begin
            UserGroup:=UpperCase(Copy(SL[I],6,1)) + LowerCase(Copy(SL[I],7,999));
            break;
         end;
      end;
   except
      // may be windows 9X or NT error
     Users:=UserName;//use the single username as the list of all users
   end;

   SL.CommaText:=CompExec.CompExec.NetManager.GetComment(ServerName,UserName);
   if SL.Count > 0 then ClerkCode      :=StrToIntDef(SL[0],0);
   if SL.Count > 1 then ClerkOfficeCode:=StrToIntDef(SL[1],0);
   if SL.Count > 2 then ClerkLevel     :=StrToIntDef(SL[2],0);

   UserName:=UpperCase(Copy(UserName,1,1))+LowerCase(Copy(UserName,2,999));
   RealUserName:=UserName;
   if UserGroup = '' then
      UserGroup:=GetGPCSRegString('','DefaultUserGroup','Clerk');
   SL.CommaText:=Users;
   if SL.Count > 0 then // don't show Administrator, Guest or SQL Users in user list
   begin
      I:=0;
      while I < SL.Count do
      begin
         SL[I]:=UpperCase(Copy(SL[I],1,1))+LowerCase(Copy(SL[I],2,Length(SL[I])));
         if (AnsiUpperCase(SL[I]) = 'ADMINISTRATOR')
         or (AnsiUpperCase(SL[I]) = 'GUEST')
         or (AnsiUpperCase(Copy(SL[I],1,3)) = 'SQL') then
            SL.Delete(I)
         else
            Inc(I);
      end;
      Users:=SL.PackText;
   end;
   WorkStation:=GetGPCSRegString('WorkStation','Ident','2');
   Office:=GetZipCodeEntry;
   SL.Free;

   if UserGroup = 'Supervisor' then
   begin
      UserName := 'Supervisor' ;
      CompExec.User:='Supervisor';
   end
   else if UserGroup = 'Admin' then
   begin
      UserName := 'Admin' ;
      CompExec.User:=UserName;
   end
   else
      CompExec.User:=UserName;
end;
procedure TMainForm.SetEODWarning(Title:String;State:Boolean);
begin
   EODWarning.Caption:=Title;
   EODWarning.Visible:=State;
end;
procedure DeleteOldTransactionLogData;
var
   TxnLogTable : TTable;
   Query:TQuery;
   KeepPeriod,LastPeriod,
   WorkStation,LastRecordID:Integer;
   SL:TPackStringList;
begin
   // get last record ID in case all transactions are deleted
   WorkStation:=StrToIntDef(GetGPCSRegString('WorkStation','Ident','999'),999);
   LastRecordID:=0;
   SL:=TPackStringList.Create;
   SL.PackText:=QueryToPackText('Select max(RecordID) from txnlog where WSNumber = '+IntToStr(WorkStation));
   if SL.Count > 0 then
   begin
      SL.PackText:=SL[0];
      if SL.Count > 0 then
         LastRecordID:=StrToIntDef(SL[0],-1)+1;
   end;
   SL.Clear;
   
   // check if anything to delete
   KeepPeriod:=StrToIntDef(GetGPCSRegString('','Transaction Periods To Keep','0'),0);
   if (KeepPeriod > 0) then
   begin
      Query:=TQuery.Create(nil);
      try
         try
            Query.DatabaseName:='PSL';
            SL.PackText:=QueryToPackText('Select max(period) from txnlog');
            if SL.Count > 0 then
            begin
               SL.PackText:=SL[0];
               if SL.Count > 0 then
               begin
                  LastPeriod:=StrToIntDef(SL[0],-1)-KeepPeriod;
                  if StrToIntDef(SL[0],-1) >= 0 then
                  begin
                     Query.SQL.Text:='delete from txnlog where Period < '+IntToStr(LastPeriod);
                     Query.ExecSQL;
                   end;
                end;
            end;
            SL.Free;
         finally
            Query.Free;
         end;
      except
         on E : Exception do RaiseGUIDException('{55D96207-9FAE-42E1-A4CB-0711575A1960}',E);
      end;
   end;
   
   // add appstart record as last record for this Workstation
   TxnLogTable:=TTable.Create(nil);
   TxnLogTable.DatabaseName:='PSL';
   TxnLogTable.TableName   :='TXNLOG';
   
   if GetGPCSRegString('WorkStation','DBType','Paradox') <> 'Paradox' then
      TxnLogTable.IndexName:='TXNLOG_PINDEX';
      
   if GetGPCSRegString('WorkStation','DBType','Paradox') = 'SQLServer' then
      TxnLogTable.TableName   :='dbo.TXNLOG';
   With TxnLogTable do
   begin
     try
        Active:=True;
        Append;
        FieldByName('RECORDID')   .Value:=LastRecordID;
        FieldByName('WSNUMBER')   .Value:=WorkStation;
        FieldByName('DATETIME')   .Value:=Now;
        FieldByName('PERIOD')     .Value:=GetTodayasPeriod;
        FieldByName('RECTYPE')    .Value:='AppStart';
        FieldByName('RECINDEX')   .Value:=0;
        FieldByName('PLU')        .Value:=0;
        FieldByName('Office')     .AsString:=GetGPCSRegString('OfficeInfo','OfficeID','0');
        Post;                       
        Active:=False;
     except
         on E : Exception do RaiseGUIDException('{55D96207-9FAE-42E1-A4CB-0711575A1960}',E);
     end;
     TxnLogTable.Free;
  end;
end;
procedure TableReStructure;
var
  TxnLogTable : TTable;
  ChangeRecord:ChangeRec;
  IndexDef:TIndexDef;
  FieldType:TFieldType;
begin

   if GetGPCSRegString('WorkStation','DBType','Paradox') <> 'Paradox' then
      Exit;
  //change table structure
  try
    TxnLogTable := TTable.Create(nil);
    With TxnLogTable do
    begin
      try
         DatabaseName := 'PSL';
         TableName    := 'TXNLOG';   

        // must re-open table for every field change.  If one field is changed then the second
        // field change will throw an exception (cant find the field).
        // -----------------------------check office field type---------------------------
        try
          TxnLogTable.Exclusive := True;
          TxnLogTable.Open;
          TxnLogTable.FieldDefs.Update;
          FieldType:=TxnLogTable.FieldByName('Office').DataType;
          If not(FieldType in [ftInteger,ftFloat]) then // ftFloat = Oracle
          begin
            Fillchar(ChangeRecord, sizeof(ChangeRecord), 0);
            ChangeRecord.szName := 'Office';
            ChangeRecord.iType  := 6; //longint
            ChangeField(TxnLogTable, TxnLogTable.FieldByName('Office'), ChangeRecord);
          end;
        finally
          TxnLogTable.Close;
          TxnLogTable.Exclusive := False;
        end;
        // -----------------------------change "Type" field name---------------------------------
        try
          TxnLogTable.Exclusive := True;
          TxnLogTable.Open;
          TxnLogTable.FieldDefs.Update;
          if TxnLogTable.FieldDefs.Indexof('Type') <> -1 then // field exists
          begin
            Fillchar(ChangeRecord, sizeof(ChangeRecord), 0); {fill packed rec with zeros}
            StrPCopy(ChangeRecord.szName,'RecType');         {new fieldname}
            ChangeField(TxnLogTable, TxnLogTable.FieldbyName('Type'), ChangeRecord); {old field name --> new fieldname}
          end;
        finally
          TxnLogTable.Close;
          TxnLogTable.Exclusive := False;
        end;
        // -----------------------------change "Index" field name---------------------------------
        try
          TxnLogTable.Exclusive := True;
          TxnLogTable.Open;
          TxnLogTable.FieldDefs.Update;
          if TxnLogTable.FieldDefs.Indexof('Index') <> -1 then
          begin
            Fillchar(ChangeRecord, sizeof(ChangeRecord), 0);
            StrPCopy(ChangeRecord.szName,'RecIndex');
            ChangeField(TxnLogTable, TxnLogTable.FieldbyName('Index'), ChangeRecord);
          end;
        finally
          TxnLogTable.Close;
          TxnLogTable.Exclusive := False;
        end;
        // -----------------------------change "Value" field name---------------------------------
        try
          TxnLogTable.Exclusive := True;
          TxnLogTable.Open;
          TxnLogTable.FieldDefs.Update;
          if TxnLogTable.FieldDefs.Indexof('Value') <> -1 then
          begin
            Fillchar(ChangeRecord, sizeof(ChangeRecord), 0);
            StrPCopy(ChangeRecord.szName,'TxnValue');
            ChangeField(TxnLogTable, TxnLogTable.FieldbyName('Value'), ChangeRecord);
          end;
        finally
          TxnLogTable.Close;
          TxnLogTable.Exclusive := False;
        end;
        //--------------------Ensure Indexes exists in Txnlog------------------
        IndexDefs.Update;
        // ---------------------------- primary index -------------------------
        IndexDef:=nil;
        try
        // If TxnLogTable.IndexDefs.IndexOf('RecordID;WSNumber') < 0 then
        //   ShowMessage(IntToStr(Txnlogtable.IndexDefs.Count));
           IndexDef := TxnLogTable.IndexDefs.FindIndexForFields('RECORDID;WSNUMBER');
        except
           on E:Exception do
              RaiseGUIDException('{36031CDC-A3F9-45B8-92C7-DC10B75D98D2}',E);
        end;
        if ((IndexDef <> nil) and (UpperCase(IndexDef.Fields) <> 'RECORDID;WSNUMBER')) or
           (IndexDef = nil)  then
           AddIndex('PriIdx', 'RECORDID;WSNUMBER', [ixPrimary, ixUnique]);

        // ---------------------------- Period --------------------------------
        IndexDef:=nil;
        try
           IndexDef := TxnLogTable.IndexDefs.FindIndexForFields('PERIOD');
        except
           on E:Exception do
              RaiseGUIDException('{3F077C72-FDD7-4C1F-9FF3-7F8B61861AE1}',E);
        end;
        if ((IndexDef <> nil) and (UpperCase(IndexDef.Fields) <> 'PERIOD')) or
           ( IndexDef = nil )  then
//         If TxnLogTable.IndexDefs.IndexOf('PeriodIdx') < 0 then
           AddIndex('PeriodIdx', 'PERIOD', [ixCaseInsensitive	]);

        // ---------------------------- PeriodTellerType --------------------------------
        IndexDef:=nil;
        try
           IndexDef := TxnLogTable.IndexDefs.FindIndexForFields('PERIOD;TELLER;RECTYPE');
        except
           on E:Exception do
              RaiseGUIDException('{63987831-ED17-4D1C-BBF9-A9D0CA3317B9}',E);
        end;
        if ((IndexDef <> nil) and (UpperCase(IndexDef.Fields) <> 'PERIOD;TELLER;RECTYPE' )) or
           ( IndexDef = nil )  then
//         if TxnLogTable.IndexDefs.IndexOf('Period;Teller;Type') < 0 then
           AddIndex('PeriodTellerTypeIdx', 'PERIOD;TELLER;RECTYPE', [ixCaseInsensitive	]);
      finally
        TxnLogTable.Free;
      end;
    end;
  except
    On E : Exception do
      RaiseGUIDException('{6C82FFAF-7527-462D-9CD5-E869C02F7FBB}', E);
  end;
end;
procedure TMainForm.FormCreate(Sender: TObject);
var
   UserName,RealUserName,WorkStation,Office,SplashImageFile:String;
   ClerkCode,ClerkOfficeCode,ClerkLevel:Integer;
   TimeOut:Integer;
   S:String;
begin                   
    Application.OnException:=ExceptionEvent;
    if not IsServiceRunning then
    begin
       Splash.WarningLabel.Caption:='The Shirika Service is NOT Running';
       Splash.WarningLabel.Repaint;
       Sleep(2000);
       if not IsServiceRunning then
       begin
          Splash.WarningLabel.Caption:='Starting Shirika Service';
          Splash.WarningLabel.Repaint;
          WinExecAndWait('C:\CorvusService\ReStartService.exe',S,False);
          TimeOut:=10;
          while (not IsServiceRunning) and (TimeOut > 0) do
          begin
             Sleep(2000); 
             if not IsServiceRunning then
                Splash.WarningLabel.Caption:='Shirika Service Not Responding'
             else
                Splash.WarningLabel.Caption:=' ';
             Dec(TimeOut);
          end;
       end
       else
          Splash.WarningLabel.Caption:=' ';
       Splash.WarningLabel.Repaint;
    end;                        
      
    if GetGPCSRegString('','Log Key Presses','0') = '1' then
       LoggingKeyPresses:=True;
    GetCursorPos(MOUSEXY);
    SetCursorPos(Screen.Width-1,Screen.Height-1);
    PSLDatabase:=TDatabase.Create(nil);
    PSLDatabase.AliasName   :='PSL';
    PSLDatabase.DatabaseName:='PSL';
    PSLDatabase.LoginPrompt :=False;
    PSLDatabase.SessionName :='Default';
    PSLDataBase.Params.Add('USER NAME='+GetGPCSRegString('','UserName','psl'   ));
    PSLDataBase.Params.Add('PASSWORD=' +GetGPCSRegString('','Password','suvroc'));
    if IsServiceBusy then
    begin
       Splash.WarningLabel.Caption:=' ';
       SplashImageFile:=GetGPCSRegString('','Transaction Update Splash',ApplicationRootPath+'\TUpLogo.bmp');
       if FileExists(SplashImageFile) then
          Splash.Image1.Picture.Bitmap.LoadFromFile(SplashImageFile);
       Splash.RePaint;
       Application.ProcessMessages;
       while IsServiceBusy do
       begin
          Sleep(1000);
          if FileExists(SplashImageFile) then
             Splash.Image1.Picture.Bitmap.LoadFromFile(SplashImageFile);
          Splash.RePaint;
          Application.ProcessMessages;
          if Application.Terminated then
             Exit;
       end;
       SplashImageFile:=GetGPCSRegString('','Splash',ApplicationRootPath+'\Splash.bmp');
       if FileExists(SplashImageFile) then
          Splash.Image1.Picture.Bitmap.LoadFromFile(SplashImageFile);
       Splash.RePaint;
       Application.ProcessMessages;
    end;           
    if IsServiceRunning then Splash.WarningLabel.Caption:=' ';
    CompExec.CompExec.Activate;
    if IsServiceRunning then Splash.WarningLabel.Caption:=' ';
//    TableReStructure;
//    DeleteOldTransactionLogData;
    with ScaleOK do begin      Left:=4  ; Top:=155; Width:=144; Height:=68 ; end;
    with ScaleError do begin   Left:=4  ; Top:=155; Width:=144; Height:=68 ; end;
    with APad do begin         Left:=8  ; Top:=223; Width:=667; Height:=455; end;
    with TPad do begin         Left:=8  ; Top:=223; Width:=667; Height:=455; end;
    with HPad do begin         Left:=8  ; Top:=223; Width:=667; Height:=455; end;
    with EPad do begin         Left:=8  ; Top:=223; Width:=667; Height:=455; end;
    with FPad do begin         Left:=8  ; Top:=223; Width:=667; Height:=455; end;
    with PPad do begin         Left:=8  ; Top:=223; Width:=667; Height:=455; end;
    with IPad do begin         Left:=8  ; Top:=223; Width:=667; Height:=455; end;
    with CornLogo do begin     Left:=120; Top:=60 ; Width:=115; Height:=99 ; end;
    with Image2 do begin       Left:=0  ; Top:=0  ; Width:=120; Height:=120; end;
    with Title do begin        Left:=120; Top:=4  ; Width:=520; Height:=32 ; end;
    with Time do begin         Left:=120; Top:=36 ; Width:=520; Height:=19 ; end;
    with Prompt do begin       Left:=120; Top:=68 ; Width:=520; Height:=32 ; end;
    with Hint1 do begin        Left:=120; Top:=104; Width:=520; Height:=23 ; end;
    with Hint2 do begin        Left:=120; Top:=128; Width:=520; Height:=23 ; end;
    with InputImage do begin   Left:=156; Top:=155; Width:=496; Height:=69 ; end;
    with KU do begin           Left:=1  ; Top:=680; Width:=171; Height:=89 ; end;
    with KD do begin           Left:=172; Top:=680; Width:=171; Height:=89 ; end;
    with KC do begin           Left:=343; Top:=680; Width:=171; Height:=89 ; end;
    with KT do begin           Left:=514; Top:=680; Width:=171; Height:=89 ; end;
    with PadLines do begin     Left:=15 ; Top:=280; Width:=652; Height:=380; end;
    with Scale do begin        Left:=26 ; Top:=176; Width:=80 ; Height:=32 ; end;
    with InstImage do begin    Left:=12 ; Top:=264; Width:=485; Height:=409; end;
    with EODWarning do begin   Left:=120; Top:=52 ; Width:=520; Height:=23 ; end;
    ColProgressBar:=TColProgressBar.Create(nil);
    ColProgressBar.Parent:=Self;
    ColProgressBar.Visible:=False;
    ColProgressBar.Color:=$00BFEFFF;
    with ColProgressBar do begin  Left:=120; Top:=55 ; Width:=520; Height:=20 ; end;
    with GrammesLabel do begin Left:=118; Top:=176; Width:=24 ; Height:=32 ; end;
    with IPControl1 do begin   Left:=172; Top:=168; Width:=465; Height:=43 ; end;
  Application.OnException:=ExceptionEvent;
   CompExec.CompExec.EODWarning:=SetEODWarning;
   CompExec.CompExec.IPControl := IPControl1;  
   {   CompExec:=TUICompExec.Create(nil);
   CompExec.OnGetButtonRef      :=CompExecGetButtonRef;
   CompExec.OnGetFormIndex      :=CompExecGetFormIndex;
   CompExec.OnGetButtonIndex    :=CompExecGetButtonIndex;
   CompExec.OnSetButtonBitMap   :=CompExecSetButtonBitMap;
   CompExec.OnSetButtonCaption  :=CompExecSetButtonCaption;
   CompExec.OnSetButtonPrice    :=CompExecSetButtonPrice;
   CompExec.OnSetButtonToggle   :=CompExecSetButtonToggle;
   CompExec.OnSetButtonOnClick  :=CompExecSetButtonOnClick;
   CompExec.OnGetButtonOnClick  :=CompExecGetButtonOnClick;
   CompExec.OnSaveCurrentState  :=SaveCurrentState;
   CompExec.OnSetTitle          :=CompExecSetTitle;
   CompExec.OnSetPrompt         :=CompExecSetPrompt;
   CompExec.OnSetPMessage       :=CompExecSetPMessage;
   CompExec.OnSetTransactions   :=CompExecSetTransactions;
   CompExec.OnSetAccounts       :=CompExecSetAccounts;
   CompExec.OnSetFormData       :=CompExecSetFormData;
   CompExec.OnSetScale          :=CompExecSetScale;
   CompExec.OnSetBitMap         :=CompExecSetBitMap;
   CompExec.OnDisplayInstruct   :=CompExecDisplayInstruct;
   CompExec.OnModalDialog       :=CompExecModalDialog; }
   
   if win32Platform = VER_PLATFORM_WIN32_WINDOWS then 
      TurnSysKeysOff;
   BorderStyle:=bsNone;
   BorderIcons:=[];
   Top:=0;
   Left:=0;
   Width:=1024;
   Height:=768;
   TriggerValue:='';
   UserName:='';
   GetUserDetails(UserName,RealUserName,UserGroup,WorkStation,Office,ClerkCode,ClerkOfficeCode,ClerkLevel);
   CompExec.User:=UserName;
   CompExec.CompExec.ClerkCode      :=ClerkCode      ;
   CompExec.CompExec.ClerkOfficeCode:=ClerkOfficeCode;
   CompExec.CompExec.ClerkLevel     :=ClerkLevel     ;
   CompExec.CompExec.RealUser:=RealUserName;
   CompExec.CompExec.Users:=Users;
   CompExec.UserGroup:='UGroup.'+UserGroup;
   CompExec.WorkStation:=WorkStation;
   CompExec.Office:=Office;    
   CompExec.CompExec.TxnLog.WriteTransaction( '*AppStart',0,0,0, 0,0,'Application Start','','','');
   CompExec.CompExec.CheckStartOfDay(True);
end;                       
function TMainForm.HidePads:TPType;
begin
   Result:=ptPick;
   if FPad.Visible then Result:=ptForm ;
   if EPad.Visible then Result:=ptError;
   if HPad.Visible then Result:=ptHelp ;
   if IPad.Visible then Result:=ptInfo ;
   if PPad.Visible then Result:=ptPick ;
   if TPad.Visible then Result:=ptTrans;
   if APad.Visible then Result:=ptAcct;
   FPad.Visible:=False;
   EPad.Visible:=False;
   HPad.Visible:=False;
   IPad.Visible:=False;
   PPad.Visible:=False;
   TPad.Visible:=False;
   APad.Visible:=False;
end;
function TMainForm.ShowPad(PType:TPType):TPType;
begin
   Result:=ptPick;
   if FPad.Visible then Result:=ptForm ;
   if EPad.Visible then Result:=ptError;
   if HPad.Visible then Result:=ptHelp ;
   if IPad.Visible then Result:=ptInfo ;
   if PPad.Visible then Result:=ptPick ;
   if TPad.Visible then Result:=ptTrans;
   if APad.Visible then Result:=ptAcct;
   FPad.Visible:=False;
   EPad.Visible:=False;
   HPad.Visible:=False;
   IPad.Visible:=False;
   PPad.Visible:=False;
   TPad.Visible:=False;
   APad.Visible:=False;
   case PType of
      ptForm  : FPad.Visible:=True;
      ptError : EPad.Visible:=True;
      ptHelp  : HPad.Visible:=True;
      ptInfo  : IPad.Visible:=True;
      ptPick  : PPad.Visible:=True;
      ptTrans : TPad.Visible:=True;
      ptAcct  : APad.Visible:=True;
   end;
end;
procedure TMainForm.ToggleButtonState(Back:Boolean);
var
   SaveButton:TSaveButton;
   I,J:Integer;
   KGButton:TKGButton;
const
   SL:TPackStringList = nil;
begin
   if SL = nil then
   begin
      if Back then Exit;
      SL:=TPackStringList.Create;
      for I:=0 to ComponentCount-1 do
      begin
         if Components[I] is TKGButton then
         begin
            KGButton:=(Components[I] as TKGButton);
            begin
               SaveButton:=TSaveButton.Create;
               SaveButton.SetValues(KGButton);
               SL.AddObject(KGButton.Name,SaveButton);
               KGButton.Caption          :='';
               KGButton.Glyph            :=nil;
               KGButton.ToggleWhenClicked:=False;
               KGButton.ButtonIsUp       :=True;
               KGButton.IsAvailable      :=False;
               KGButton.Flashing         :=False;
               KGButton.OnClick          :=nil;
               KGButton.Price            :='';
            end;
         end;
      end;
   end
   else
   begin
      for I:=0 to ComponentCount-1 do
      begin
         if Components[I] is TKGButton then
         begin
            KGButton:=(Components[I] as TKGButton);
            J:=SL.IndexOf(KGButton.Name);
            if J <> -1 then
            begin
               SaveButton:=SL.Objects[J] as TSaveButton;
               SaveButton.Restore;
               SaveButton.Free;
               SL.Objects[J]:=nil;
            end;
         end;
      end;
      SL.Free;
      SL:=nil;
   end;
end;
procedure TMainForm.ModalButtonPressed(Sender:TObject);
var
   Capt:String;
   I:Integer;
begin
    if Sender = B3 then
       CompExec.CompExec.ModalSelection:=1
    else if Sender = B4 then
       CompExec.CompExec.ModalSelection:=2
    else if Sender = B5 then
       CompExec.CompExec.ModalSelection:=3
    else 
       CompExec.CompExec.ModalSelection:=4;
                    
    Capt:=(Sender as TKGButton).Caption;
    ShowModalDialog(ptPick,'','','',nil,nil,nil,'','','');
    if Capt = CompExec.TranslateString('Main','Cancel',0,0,0) then
    begin
       if ExecuteNext <> '' then 
       begin
          CompExec.Execute(ExecuteNext,True);
          ExecuteNext:='';
       end
       else 
       begin
          CompExec.Cancel;
       end;
    end
    else if Capt = CompExec.TranslateString('Main','Top Menu',0,0,0) then
    begin
       CompExec.CancelToTop;
    end
    else if Capt = CompExec.TranslateString('Main','Exit',0,0,0) then
    begin
       if (GetGPCSRegString('Workstation','Login','N') = 'Y') then
       begin
          TempHide:=True;
          Splash.Show;
          Splash.RePaint;
          Hide;
          Application.ProcessMessages;
          UserForm.Password.Text:='';
          UserForm.ShowModal;
          for I:=0 to ComponentCount-1 do
          begin
             if (Components[I] is TKGButton) then
             begin
                (Components[I] as TKGButton).Enabled:=True;
                (Components[I] as TKGButton).IsAvailable:=True;
                (Components[I] as TKGButton).ToggleWhenClicked:=True;
                (Components[I] as TKGButton).ToggleWhenClicked:=False;
                (Components[I] as TKGButton).Flashing:=False;
             end;
          end;
          ToggleButtonState(True);
          CompExec.UserGroup:=UserForm.UserGroup;
          UserGroup:=Copy(UserForm.UserGroup,8,999);
          Show;
          TempHide:=False;
          Splash.Hide;
          if UserForm.Name ='REG' then
             CompExec.Execute('LogOff',False);
       end
       else
          CompExec.Execute('LogOff',False);
    end
    else if Capt = CompExec.TranslateString('Main','Cancel Customer',0,0,0) then
    begin
       CompExec.Execute('CancelCustomer',False);
    end
    else if Capt = CompExec.TranslateString('Main','Shutdown Workstation',0,0,0) then
    begin
       CompExec.Execute('ShutdownWorkstation',False);
    end
    else if Capt = CompExec.TranslateString('Main','Shutdown All Workstations',0,0,0) then
    begin
       CompExec.Execute('ShutdownAllWorkstations',False);
    end
    else if Capt = CompExec.TranslateString('Main','OK',0,0,0) then
    begin
       CompExec.Execute('ModalOK',False);
    end
    else if Capt = CompExec.TranslateString('Main','CANCEL',0,0,0) then
    begin
       CompExec.Execute('ModalCANCEL',False);
    end
    else if Capt = CompExec.TranslateString('Main','Return',0,0,0) then
    begin
       CompExec.Execute('ModalReturn',False);
    end;
end;   
procedure TMainForm.SaveCurrentState(Restore:Boolean);
const
   SessionSaved:Boolean = False;
   LastPad:TPType       = ptPick;
   LastPadMode:TPadMode = pmPick;
   LastPrompt:String    = '';
   LastHint:String      = '';
begin
   if Restore and SessionSaved then
   begin
      SessionSaved:=False;
      ShowPad(LastPad);
      PadLines.PadMode:=LastPadMode;
      PadLines.RestorePadText;
      Prompt.Caption:=LastPrompt;
      CompExecSetPMessage(LastHint);
      ToggleButtonState(True);
      CompExec.PutBack;
   end
   else
   begin
      SessionSaved:=True;
      LastPad:=HidePads;
      PadLines.SavePadText;
      LastPadMode:=PadLines.PadMode;
      LastPrompt:=Prompt.Caption;
      LastHint:=Hint1.Caption+'^'+Hint2.Caption;
      ToggleButtonState(False);
   end;
end;
procedure TMainForm.PrintButtonPressed(Sender:TObject);
begin
   PreviewFunction((Sender as TKGButton).Caption);
end;   
procedure TMainForm.SetButtonCap(Button:TKGButton;Caption:String);
var
   BMP:TBitMap;
begin
   Button.OnClick:=PrintButtonPressed;
   Button.Caption:=Caption;
   BMP:=CompExec.GetPictureFromServer(Caption); Button.Glyph:=BMP; BMP.Free;
   Button.IsAvailable:=True;
   Button.Enabled:=True;
end;
procedure TMainForm.ShowPrintDialog;
var
   LastPad:TPType;
   LastPadMode:TPadMode;
   LastPrompt:String;
   LastHint:String;
begin
   CompExec.DontTrigger:=True;
   LastPad:=HidePads;
   LastPadMode:=PadLines.PadMode;
   try
      PadLines.SavePadText;
      LastPrompt:=Prompt.Caption;
      LastHint:=Hint1.Caption+'^'+Hint2.Caption;
      ToggleButtonState(False);
   
      Prompt.Caption:='Preview Report';
      Hint1.Caption:='Preview using [Top],[Bottom],[Previous] && [Next]';
      Hint2.Caption:='press [Print] or [Cancel] when complete';
      SetButtonCap(KC ,'Cancel'        );
      SetButtonCap(B3 ,'Print'         );
      SetButtonCap(B5 ,'Top of Page'   );
      SetButtonCap(B6 ,'Bottom of Page');
      SetButtonCap(B7 ,'Next Page'     );
      SetButtonCap(B8 ,'Previous Page' );
      SetButtonCap(B9 ,'First Page'    );
      SetButtonCap(B10,'Last Page'     );
      InPreviewDialog:=True;
   except
      InPreviewDialog:=False;
   end;
   PreviewReady:=True;
   while (not Application.Terminated) and InPreviewDialog do
   begin
      Sleep(1);
      Application.ProcessMessages;
   end;
   try   
      CompExec.DontTrigger:=False;
      IPControl1.InModal:=False;
      ShowPad(LastPad);
      PadLines.PadMode:=LastPadMode;
      PadLines.RestorePadText;
      Prompt.Caption:=LastPrompt;
      CompExecSetPMessage(LastHint);
      ToggleButtonState(True);
      CompExec.PutBack;
      Refresh;
   except
   end;
   InPreviewDialog:=False;
end;          

procedure TMainForm.ShowModalDialog(PType:TPType;Text,DlgPrompt,DlgHint:String;B1,B2,B3:TKGButton;B1C,B2C,B3C:String);
var
   BMP:TBitMap;
   SL:TPackStringList;
const
   InModal:Boolean      = False;
   LastPad:TPType       = ptPick;
   LastPadMode:TPadMode = pmPick;
   LastPrompt:String    = '';
   LastHint:String      = '';
begin
   if (not InModal) and (PType <> ptCancel) then
   begin
      CompExec.CompExec.ModalSelection:=0;
      IPControl1.InModal:=True;
      CompExec.DontTrigger:=True;
      LastPad:=ShowPad(PType);
      if (PType = ptInfo) and (DlgPrompt = 'Diskette') then
      begin
         BMP:=CompExec.GetPictureFromServer(DlgPrompt);
         InstImage.Picture.Bitmap.Assign(BMP);
         BMP.Free;
         InstImage.Repaint;
      end;
      PadLines.SavePadText;
      LastPadMode:=PadLines.PadMode;
      if PType = ptAcct then
         PadLines.PadMode:=pmAcct
      else
         PadLines.PadMode:=pmHelp;
         
      PadLines.Clear;
      PadLines.SetLines(Text,False);
      LastPrompt:=Prompt.Caption;
      if DlgPrompt <> 'Diskette' then
         Prompt.Caption:=DlgPrompt
      else
         Prompt.Caption:='';
      LastHint:=Hint1.Caption+'^'+Hint2.Caption;
      CompExecSetPMessage(DlgHint);
      InModal:=True;
      ToggleButtonState(False);
      if B1 <> nil then
      begin
         B1.OnClick:=ModalButtonPressed;
         B1.Caption:=CompExec.TranslateString('Main',B1C,0,0,0);
         BMP:=CompExec.GetPictureFromServer(B1C); B1.Glyph:=BMP; BMP.Free;
         B1.IsAvailable:=True;
         B1.Enabled:=True;
      end;
      if B2 <> nil then
      begin
         B2.OnClick:=ModalButtonPressed;
         B2.Caption:=CompExec.TranslateString('Main',B2C,0,0,0);
         BMP:=CompExec.GetPictureFromServer(B2C); B2.Glyph:=BMP; BMP.Free;
         B2.IsAvailable:=True;
         B2.Enabled:=True;
      end;
      if B3 <> nil then
      begin
         B3.OnClick:=ModalButtonPressed;
         B3.Caption:=CompExec.TranslateString('Main',B3C,0,0,0);
         BMP:=CompExec.GetPictureFromServer(B3C); B3.Glyph:=BMP; BMP.Free;
         B3.IsAvailable:=True;
      end; 
      SL:=TPackStringList.Create;
      SL.PackText:=Text;
      if SL.Count > 12 then
      begin
         KU.IsAvailable:=True;
         BMP:=CompExec.GetPictureFromServer('Up'); KU.Glyph:=BMP; BMP.Free;
         KU.Caption:=CompExec.TranslateString('Main',KUCaption,1,0,1);
         KU.OnClick:=KUClick;
         KD.IsAvailable:=True;
         BMP:=CompExec.GetPictureFromServer('Down'); KD.Glyph:=BMP; BMP.Free;
         KD.Caption:=CompExec.TranslateString('Main',KDCaption,1,1,1);
         KD.OnClick:=KDClick;
      end;
      SL.Free;
      Refresh;            
      if PType = ptAcct then
      begin
         IPControl1.AcctLog(Text,DlgPrompt,DlgHint);
         while (CompExec.CompExec.ModalSelection = 0) and (not Application.Terminated) do
         begin
            Application.ProcessMessages;
         end;
      end
      else
         IPControl1.ShowInfo(Text);
   end
   else
   begin
      CompExec.DontTrigger:=False;
      InstImage.Picture.Bitmap.Assign(nil);
      IPControl1.ModalExcept:='';
      IPControl1.InModal:=False;
      if PadLines.PadMode <> pmAcct then
         IPControl1.ShowInfo('');
      ShowPad(LastPad);
      PadLines.PadMode:=LastPadMode;
      PadLines.RestorePadText;
      Prompt.Caption:=LastPrompt;
      CompExecSetPMessage(LastHint);
      InModal:=False;
      ToggleButtonState(True);
      Refresh;
   end;                         
end;
procedure TMainForm.CompExecSetAccounts(Caption: String);
var
   SL:TPackStringList;
begin
   if Caption <> '' then
   begin
      SL:=TPackStringList.Create;
      SL.PackText:=Caption;
      SL.Insert(0,#1'0'#1'1'#1'0'#1'0'#1'0'#1'0'#1'0');
      SL.PackText:=CompExec.Translate(SL.PackText);
      SL.Delete(0);
      IPControl1.AcctLog(SL.PackText,'Cash Account','Press [Enter] to examine details');
      SL.Free;
   end
   else
   begin
      PadLines.PadMode:=pmPick;
      APad.Visible:=False;
      PPad.Visible:=True;
   end;
end;

procedure TMainForm.IPControl1Execute(ProgID: String);
begin
   if ProgID = 'Information' then
   begin
      if IPControl1.ModalExcept = '' then IPControl1.ModalExcept:=ProgID else IPControl1.ModalExcept:='';
      B2.ForceClick;
   end
   else if ProgID = 'Help' then
   begin
      if IPControl1.ModalExcept = '' then IPControl1.ModalExcept:=ProgID else IPControl1.ModalExcept:='';
      B1.ForceClick;
   end
   else if ProgID = 'Toggle Scale' then
   begin
      if CompExec.CompExec.ScaleReading <> -1 then
         CompExec.CompExec.ScaleReading:=-1
      else
         CompExec.CompExec.ScaleReading:=-2;
   end
   else if ProgID = 'Freeze Scale' then
   begin
      if CompExec.CompExec.ScaleReading <> -1 then
         CompExec.CompExec.ScaleReading:=-1
      else
         CompExec.CompExec.ScaleReading:=CompExec.CompExec.LastScaleReading;
   end
   else if ProgID = 'Zero Scale' then
   begin
      CompExec.CompExec.ZeroScale;
   end
   else if CompExec.CurrentExec <> ProgID then
   begin
      Caption:=ProgID;
      if Copy(CompExec.CurrentExec,1,8) = 'Product.' then
      begin
         if IPControl1.FormModified then
         begin
            ExecuteNext:=ProgID;
            KC.ForceClick;
         end
         else
         begin
            CompExec.Execute(ProgID,True);
         end;
      end
      else
      begin
         ExecuteNext:='';
         CompExec.Execute(ProgID,False);
      end;
   end;
end;

function TMainForm.CompExecGetFormIndex: Integer;
begin
   Result:=IPControl1.CurrentItem;
end;

procedure TMainForm.CEModalDialog(PType:TPType;Text,DlgPrompt,DlgHint:String;B1,B2,B3:TControl;B1C,B2C,B3C:String);
begin
   ShowModalDialog(PType,Text,DlgPrompt,DlgHint,TKGButton(B1),TKGButton(B2),TKGButton(B3),B1C,B2C,B3C);
end;
procedure TMainForm.CompExecModalDialog(PType: TPType; Text, DlgPrompt,
  DlgHint: String; B1, B2, B3: TControl; B1C, B2C, B3C: String);
begin
   ShowModalDialog(PType,Text,DlgPrompt,DlgHint,TKGButton(B1),TKGButton(B2),TKGButton(B3),B1C,B2C,B3C);
end;

procedure TMainForm.CompExecProgress(Title:String;Min,Max,Pos:Integer);
begin
   if (Min = Max) then 
   begin
      ColProgressBar.Visible:=False;
      ColProgressBar.Position:=0;
   end
   else 
   begin
      ColProgressBar.Min:=Min;
      ColProgressBar.Max:=Max;
      ColProgressBar.Position:=Pos;
      ColProgressBar.Visible:=True;
   end;
   Self.Title.Caption:=Title;
   Application.ProcessMessages;
end;

procedure TMainForm.IPControl1PopUp(ShiftState: Integer);
var
   GroupToExec:String;
   Msg:TMessage;
const
   LastShift:Integer=-1;
   UserGroup:String ='Clerk';
   Executed:Integer = 0;
begin
   if (LastShift <> ShiftState) and (Copy(CompExec.CurrentExec,1,6) = 'Group.') then
   begin
      LastShift:=ShiftState;
      GroupToExec:='';
      case ShiftState of
          0 : {___} if (Executed > 0) and (InHotMenu) then begin CompExec.CompExec.WMCancelPrevious(Msg); Dec(Executed); end;
          1 : {__A} GroupToExec:='Group.'+Self.UserGroup+'__A'; 
          2 : {_C_} GroupToExec:='Group.'+Self.UserGroup+'_C_'; 
          3 : {_CA} GroupToExec:='Group.'+Self.UserGroup+'_CA'; 
          4 : {S__} GroupToExec:='Group.'+Self.UserGroup+'S__'; 
          5 : {S_A} GroupToExec:='Group.'+Self.UserGroup+'S_A'; 
          6 : {SC_} GroupToExec:='Group.'+Self.UserGroup+'SC_'; 
          7 : {SCA} GroupToExec:='Group.'+Self.UserGroup+'SCA'; 
      end;
      if (GroupToExec <> '') and CompExec.CompExec.CanExecute(GroupToExec) then
      begin
         while Executed > 0 do 
         begin 
            if (InHotMenu) then CompExec.CompExec.WMCancelPrevious(Msg);
            Dec(Executed); 
         end;
         Inc(Executed);
         CompExec.Execute(GroupToExec,False);
         InHotMenu:=True;
      end;
   end;
end;
function HexIPToIP(S:String):String;
begin
   Result:=IntToStr(StrToIntDef('$'+Copy(S,2,2),0))+'.'+
           IntToStr(StrToIntDef('$'+Copy(S,4,2),0))+'.'+
           IntToStr(StrToIntDef('$'+Copy(S,6,2),0))+'.'+
           IntToStr(StrToIntDef('$'+Copy(S,8,2),0));
end;

procedure TMainForm.IPControl1Exit(Sender: TObject);
begin
   if (ActiveControl.Name <> 'IPControl1') and IPControl1.Enabled  then
      IPControl1.SetFocus ;
end;

end.
