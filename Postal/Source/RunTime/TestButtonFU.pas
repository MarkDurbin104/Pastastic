unit TestButtonFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Mask2, IPControl, CompExecU, PadLines,
  KGButton,GPCSGUID;

type
  TPType =(ptForm,ptError,ptHelp,ptInfo,ptPick,ptTrans,ptAcct);
  TSaveButton = class(TObject)
    Caption          :String;
    Glyph            :TBitmap;
    ToggleWhenClicked:Boolean;
    ButtonIsUp       :Boolean;
    IsAvailable      :Boolean;
    Flashing         :Boolean;
    Enabled          :Boolean;
    SetFrom          :TKGButton;
    OnClick          :TNotifyEvent;
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
    procedure FormShow(Sender: TObject);
    procedure B1Click(Sender: TObject);
    procedure B2Click(Sender: TObject);
    function CompExecGetButtonIndex(Button: TControl): Integer;
    function CompExecGetButtonOnClick(Button: TControl): TNotifyEvent;
    procedure CompExecSetButtonOnClick(Button: TControl;
      Handler: TNotifyEvent);
    function CompExecGetButtonRef(Index: Integer): TControl;
    procedure CompExecSetButtonBitMap(Button: TControl;
      BitMap: TBitmap);
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
    procedure CompExecSetFormData(Caption: String;FlagError,NewForm:Boolean);
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
    procedure CompExecSetButtonToggle(Button: TControl; State: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure CompExecSetAccounts(Caption: String);
    procedure SaveCurrentState(Restore:Boolean);
    procedure IPControl1Execute(ProgID: String);
    function CompExecGetFormIndex: Integer;
    procedure CEModalDialog(PType:TPType;Text,DlgPrompt,DlgHint:String;B1,B2,B3:TControl;B1C,B2C,B3C:String);
    procedure CompExecModalDialog(PType: TPType; Text, DlgPrompt,
      DlgHint: String; B1, B2, B3: TControl; B1C, B2C, B3C: String);
  private
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
    procedure SetupImages;
    procedure AppDeactivate(Sender: TObject);
    procedure TurnSysKeysOff;
    procedure TurnSysKeysOn;
    function HidePads:TPType;
    function ShowPad(PType:TPType):TPType;
    procedure ModalButtonPressed(Sender:TObject);
    procedure ShowModalDialog(PType:TPType;Text,DlgPrompt,DlgHint:String;B1,B2,B3:TKGButton;B1C,B2C,B3C:String);
    procedure ToggleButtonState(Back:Boolean);
  public  
     procedure FlipSides;
     function SelectHelp(HelpFile,CurrentExec:String):String;
  end;
var
  MainForm: TMainForm;

implementation

uses SplashFU, UserFormFU;
{TSaveButton}
procedure TSaveButton.SetValues(From:TKGButton);
begin
    SetFrom:=From;
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
   BMP:=CompExec.GetPictureFromServer('APad'); AdjustColor(BMP,R,G,B); APad.Picture.Bitmap.Assign(BMP); BMP.Free;
   BMP:=CompExec.GetPictureFromServer('FPad'); AdjustColor(BMP,R,G,B); FPad.Picture.Bitmap.Assign(BMP); BMP.Free;
   BMP:=CompExec.GetPictureFromServer('EPad'); AdjustColor(BMP,R,G,B); EPad.Picture.Bitmap.Assign(BMP); BMP.Free;
   BMP:=CompExec.GetPictureFromServer('HPad'); AdjustColor(BMP,R,G,B); HPad.Picture.Bitmap.Assign(BMP); BMP.Free;
   BMP:=CompExec.GetPictureFromServer('CornLogo'); AdjustColor(BMP,R,G,B); CornLogo.Picture.Bitmap.Assign(BMP); BMP.Free;
   BMP:=CompExec.GetPictureFromServer('Scale'); AdjustColor(BMP,R,G,B); ScaleOK.Picture.Bitmap.Assign(BMP); BMP.Free;
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
var
   SL:TStringList;
begin
   Result:='3211';
   SL:=TStringList.Create;
   try
      SL.LoadFromFile(ApplicationRootPath+'Office.Id');
      if SL.Count > 0 then Result:=SL[0];
   except
      ;
   end;
   SL.Free;
end;
procedure SetZipCodeEntry(Value:String);
var
   SL:TStringList;
begin
   SL:=TStringList.Create;
   try
      SL.Add(Value);
      SL.SaveToFile(ApplicationRootPath+'Office.Id');
   except
      ;   
   end;
   SL.Free;
end;
procedure TMainForm.FlipSides;
var
   I:Integer;
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
      end
      else if Controls[I] is TIPControl then
         (Controls[I] as TIPControl).RightAnchor:=not (Controls[I] as TIPControl).RightAnchor
      else if Controls[I] is TPadLines then
         (Controls[I] as TPadLines).RightAnchor:=not (Controls[I] as TPadLines).RightAnchor
      else if Controls[I] is TKGButton then
         (Controls[I] as TKGButton).RightAnchor:=not (Controls[I] as TKGButton).RightAnchor;
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
      LoadKeyboardLayout('00000401',KLF_ACTIVATE)
   end
   else
   begin
      SetThreadLocale($00000809);
      LoadKeyboardLayout('00000809',KLF_ACTIVATE);
   end;
   KU.Caption:=CompExec.TranslateString('Main',KUCaption,1,0,1);
   KD.Caption:=CompExec.TranslateString('Main',KDCaption,1,1,1);
   KT.Caption:=CompExec.TranslateString('Main',KTCaption,1,2,1);
   KC.Caption:=CompExec.TranslateString('Main',KCCaption,1,3,1);
   B1.Caption:=CompExec.TranslateString('Main',B1Caption,1,4,1);
   B2.Caption:=CompExec.TranslateString('Main',B2Caption,1,5,1);
end;
procedure TMainForm.FormShow(Sender: TObject);
begin
//   CompExec.UserGroup:='UGroup.Supervisor';
//   CompExec.WorkstationGroup:='WGroup.Dynakey';
   //Tanzania 14/01/99
   if not TempHide then
   begin
      CompExec.WorkstationGroup:=GetGPCSRegString('Workstation','Group','WGroup.Dynakey');
      SetupImages;
      if not CompExec.TranslationOn then
         FlipSides;
      if (GetGPCSRegString('Workstation','Login','N') = 'Y') then
      begin
         UserForm.ShowModal;
         CompExec.UserGroup:=UserForm.UserGroup;
      end;
      if (Splash <> nil) and (Splash.Visible) then 
      begin
         Splash.Hide;
      end;
   end; 
end;                     
procedure TMainForm.AppDeactivate(Sender: TObject);
begin
   FormDeactivate(Sender);
end;
function TMainForm.SelectHelp(HelpFile,CurrentExec:String):String;
var
   SL:TStringList;
   ResSL:TStringList;
   I:Integer;
begin
   SL:=TStringList.Create;
   try
      SL.LoadFromFile(ApplicationRootPath+HelpFile);
   except
      ;
   end;
   I:=0;
   while I < SL.Count do
   begin
      if (SL[I] <> '') and (SL[I][1] ='^') then
      begin
         if Copy(SL[I],2,Length(SL[I])) = CurrentExec then
         begin
            ResSL:=TStringList.Create;
            Inc(I);
            while I < SL.Count do
            begin
               if (SL[I] <> '') and (SL[I][1] ='^') then break;
               ResSL.Add(SL[I]);
               Inc(I);
            end;
            Result:=ResSL.CommaText;
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
         ResSL:=TStringList.Create;
         Inc(I);
         while I < SL.Count do
         begin
            if (SL[I] <> '') and (SL[I][1] ='^') then break;
            ResSL.Add(SL[I]);
            Inc(I);
         end;
         Result:=ResSL.CommaText;
         ResSL.Free;
         SL.Free;
         Exit;
      end;
      Inc(I);
   end;
   Result:='"No Help Available"';
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
  BitMap: TBitmap);
begin
   (Button as TKGButton).Glyph:=BitMap;
end;

procedure TMainForm.CompExecSetButtonCaption(Button: TControl;
  Caption: String);
var
   Index:Integer;
   SL:TStringList;
begin
   (Button as TKGButton).Caption:=Caption;
   if Caption = '' then 
      (Button as TKGButton).IsAvailable:=False 
   else 
      (Button as TKGButton).IsAvailable:=True;
   Index:=StrToIntDef(Copy((Button as TKGButton).Name,2,5),99)-3;
   if PadLines <> nil then
   begin
      if Index =0 then PadLines.Clear;
      if Caption <> '' then
         PadLines.SetLine(IntToStr(Index+1)+'    '+Caption,Index)
      else
         PadLines.SetLine(Caption,Index);
      if  (CompExec <> nil) 
      and (CompExec.TransactionLog <> nil) 
      and (CompExec.TransactionLog.ItemCount <> 0) then
      begin
         PadLines.PadMode:=pmTrans;
         TPad.Visible:=True;
         PPad.Visible:=False;
         SL:=TStringList.Create;
         SL.CommaText:=CompExec.TransactionLog.Contents;
         SL.Insert(0,'"0","1","0","0","0","0","0"');
         SL.CommaText:=CompExec.Translate(SL.CommaText);
         SL.Delete(0);
         IPControl1.TxnLog(SL.CommaText,'','');
         SL.Free;
      end
      else
      begin
         PadLines.PadMode:=pmPick;
         TPad.Visible:=False;
         PPad.Visible:=True;
         IPControl1.PickFrom(PadLines.GetLines,'','');
      end;
   end;
end;

procedure TMainForm.CompExecSetBitMap(BitMap:TBitmap);
var
   R:TRect;
   BMP:TBitmap;
begin
   BMP:=TBitmap.Create;
   BMP.PixelFormat:=pf24Bit;
   BitMap.PixelFormat:=pf24Bit;
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
         Hint1.Caption:=Copy(Caption,1,I-1);
         Hint2.Caption:=Copy(Caption,I+2,Length(Caption));
         Exit;    
      end;
      if Caption[I] = '^' then
      begin
         Hint1.Caption:=Copy(Caption,1,I-1);
         Hint2.Caption:=Copy(Caption,I+1,Length(Caption));
         Exit;    
      end;
   end;
   Hint1.Caption:=Caption;
   Hint2.Caption:='';
end;

procedure TMainForm.CompExecSetPrompt(Caption: String);
begin
   Prompt.Caption:=Caption;   
end;

procedure TMainForm.CompExecSetTitle(Caption: String);
begin
   Title.Caption:=Caption;
end;

procedure TMainForm.SystemClockTimer(Sender: TObject);
var
   S:String;
   SystemTime:TSystemTime;
   Buffer:array[0..200] of Char;
begin
   SystemClock.Interval:=500;
   if CompExec.TranslationOn then
   begin
      S:=FormatDateTime('dddd',Now);
      DateTimeToSystemTime(Now,SystemTime);  
      GetDateFormat(GetThreadLocale,DATE_LONGDATE,@SystemTime,nil,Buffer,SizeOf(Buffer));
      S:=S+'  '+Buffer;
      S:=S+'  '+FormatDateTime('hh:nn',Now);
      S:=S+'    '+CompExec.User;
      S:=S+' '+CompExec.Workstation;
      S:=S+' '+CompExec.Office;
   end
   else
   begin
      S:=FormatDateTime('dddd, dd mmmm yyyy, hh:nn',Now);
      S:=S+'          U.'+CompExec.User;
      S:=S+' P.'+CompExec.Workstation;
      S:=S+' O.'+CompExec.Office;
   end;
   if Time.Caption <> S then
   begin
      Time.Caption:=S;
      if HookUp <> nil then
         HookUp.KeepAwake;
   end;
//   B2.Flashing := not B2.Flashing;
end;

procedure TMainForm.CompExecSetButtonPrice(Button: TControl; Price: Currency);
var
   Value:String;
begin
   if Price > 0 then
   begin
      Value:=CurrToStr(Price);
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
          $0005 : Result:='$'; // $
          $0006 : Result:='%'; // %
          $000D : Result:='+'; // +
        end;
     end
     else
     begin
        case ScanCode of
           $0002 : Result:='1'; // 1
           $0003 : Result:='2'; // 2
           $0004 : Result:='3'; // 3
           $0005 : Result:='4'; // 4
           $0006 : Result:='5'; // 5
           $0007 : Result:='6'; // 6
           $0008 : Result:='7'; // 7
           $0009 : Result:='8'; // 8
           $000A : Result:='9'; // 9
           $000B : Result:='0'; // 0
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
function FormatTrigger(Value:String):String;
begin
   if Length(Value) = 8 then
   begin
      Try
         Result:=CurrToStr(B43ToCurr(Value));
      except
         ;
      end;
   end
   else
      Result:=Value;
   
   Result:=','+Result+',';
end;
procedure TMainForm.IPControl1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
   ClearKey:Boolean;
   C:Char;
   SW:String;
const
   CollectingTrigger:Boolean = False;
   CancelIgnore     :Boolean = False;
begin
   CompExec.SetKeyHit;
   ClearKey:=True;
   if (CancelIgnore) and (Key <> 37) then
   begin
      IPControl1.Ignore:=False;
      CancelIgnore:=False;
   end;
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
//      VK_UP      : KU.ForceClick;
//      VK_DOWN    : KD.ForceClick;
//      VK_PRIOR   : ClearKey:=False;
//      VK_NEXT    : ClearKey:=False;
      VK_ESCAPE  : KC.ForceClick;
      VK_END     : begin
                      if  (Copy(CompExec.CurrentExec,1,8) <> 'Product.')
                      and (GetGPCSRegString('Workstation','Switch','No') <> 'No') then
                      begin
                         if GetGPCSRegString('Workstation','Switch1','') = CompExec.WorkstationGroup then
                         begin
                            SW:=GetGPCSRegString('Workstation','Switch2','');
                            if (SW <> '') then CompExec.WorkstationGroup:=SW;
                         end
                         else if GetGPCSRegString('Workstation','Switch2','') = CompExec.WorkstationGroup then
                         begin
                            SW:=GetGPCSRegString('Workstation','Switch3','');
                            if (SW <> '') then CompExec.WorkstationGroup:=SW;
                         end
                         else if GetGPCSRegString('Workstation','Switch3','') = CompExec.WorkstationGroup then
                         begin
                            SW:=GetGPCSRegString('Workstation','Switch1','');
                            if (SW <> '') then CompExec.WorkstationGroup:=SW;
                         end
                      end;
                   end;
      56         : if ssShift in Shift then 
                   begin 
                       Key:=0;
                       if CollectingTrigger then
                       begin 
                          CollectingTrigger:=False;
                          CancelIgnore:=True;
                          if InList then
                          begin
                             CompExec.FireTrigger(FormatTrigger(TriggerValue));
                          end
                          else
                          begin
                             CompExec.TriggerValue:=FormatTrigger(TriggerValue);
                             B3.ForceClick;
                          end;
                       end                  
                       else                               
                       begin 
                          IPControl1.Ignore:=True;
                          CollectingTrigger:=True;  
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
          if CollectingTrigger then 
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
            '"'+CompExec.TranslateString('Main','Warning',0,0,0)
               +'","'
               +CompExec.TranslateString('Main','Pressing this key will Cancel the',0,0,0)
               +' ","'+Title.Caption+'","'
               +CompExec.TranslateString('Main',' operation !',0,0,0)+'","'
               +CompExec.TranslateString('Main','Press [Cancel] again to Confirm',0,0,0)+'","'
               +CompExec.TranslateString('Main','Press [Return] to go back',0,0,0)+'"',
            CompExec.TranslateString('Main','Error',1,10,1),
            CompExec.TranslateString('Main','Press [Cancel] again to Confirm^Press [Return] to go back',1,8,1),
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
            '"'+CompExec.TranslateString('Main','Warning',0,0,0)
               +'","'
               +CompExec.TranslateString('Main','Pressing this key will Cancel the',0,0,0)
               +' ","'+Title.Caption+'","'
               +CompExec.TranslateString('Main',' operation !',0,0,0)+'","'
               +CompExec.TranslateString('Main','Press [Top Menu] again to Confirm',0,0,0)+'","'
               +CompExec.TranslateString('Main','Press [Return] to go back',0,0,0)+'"',
         CompExec.TranslateString('Main','Error',1,10,1),
         CompExec.TranslateString('Main','Press [Top Menu] again to Confirm^Press [Return] to go back',1,8,1),
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

procedure TMainForm.CompExecSetFormData(Caption: String;FlagError,NewForm:Boolean);
begin
   if NewForm then IPControl1.FormModified:=False;
   IPControl1.ShowForm(Caption,FlagError);
end;

procedure TMainForm.IPControl1SetList(var Value: String);
begin
   PadLines.SetLines(Value,InForm);
end;

procedure TMainForm.IPControl1SetPrompt(var Value: String);
begin
   CompExecSetPrompt(Value);
end;

procedure TMainForm.IPControl1SetHint(var Value: String);
begin
   Hint1.Font.Color:=Time.Font.Color;
   Hint2.Font.Color:=Time.Font.Color;
   CompExecSetPMessage(Value);
end;

procedure TMainForm.IPControl1SetMode(var Value: TIPMode);
begin
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
begin
//   CompExec.Free;
//   CompExec:=nil;
   TurnSysKeysOn;
end;

procedure TMainForm.FormDeactivate(Sender: TObject);
begin
   SetForegroundWindow(Handle);
end;

procedure TMainForm.IPControl1SetError(var Value: String);
begin
   Hint1.Font.Color:=clRed;
   Hint2.Font.Color:=clRed;
   CompExecSetPMessage(Value);
end;


procedure TMainForm.CompExecSetScale(Caption: String);
begin
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
      Scale.Caption:=Caption;//+'  '+GrammesSymbol;
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
   if Text = '****' then
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
      FPad.Visible:=False;
      PPad.Visible:=False;
      IPad.Visible:=True;
      PadLines.Highlight(-1);
      PadLines.SetLines(Text,False); // Tanzania
//      PadLines.SetLines('"'+Text+'"',False);
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
   SL:TStringList;
begin
   if Caption <> '' then
   begin
      SL:=TStringList.Create;
      SL.CommaText:=Caption;
      SL.Insert(0,'"0","1","0","0","0","0","0"');
      SL.CommaText:=CompExec.Translate(SL.CommaText);
      SL.Delete(0);
      IPControl1.TxnLog(SL.CommaText,'','');
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

procedure TMainForm.CompExecSetButtonToggle(Button: TControl; State: Boolean);
begin
   (Button as TKGButton).ToggleWhenClicked:=State;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
   SL:TStringList;
   UserName:String;
   WSName:String;
   I:Integer;
begin
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
   SL:=TStringList.Create;
   try
      SL.LoadFromFile('C:\TEMP\Password.log');
       if SL.Count < 1 then
      begin
         CompExec.User:='ShortLog';
         CompExec.UserGroup:='UGroup.Clerk';
      end                
      else
      begin
         UserName:=Trim(Copy(SL[SL.Count-1],6,Length(SL[SL.Count-1])));
         for I:=1 to Length(UserName) do
         begin
            if UserName[I] = ' ' then
            begin                       
               UserName:=Copy(UserName,1,I-1);
               break;
            end;
         end;
         UserName:=UpCase(UserName[1])+LowerCase(Copy(UserName,2,999));
         if Length(UserName) < 2 then
         begin
            CompExec.User:='ShortName';
            CompExec.UserGroup:='UGroup.Clerk';
         end
         else
         begin
            case UserName[1] of
               'S','s' : begin
                        UserName:='Supervisor';
                        CompExec.User:='Supervisor';
                        CompExec.UserGroup:='UGroup.Supervisor';
                     end;
               'C','c' : begin
                        UserName:=UpCase(UserName[1])+UpCase(UserName[2])+LowerCase(Copy(UserName,3,999));
                        CompExec.User:=Copy(UserName,2,Length(UserName));
                        CompExec.UserGroup:='UGroup.Clerk';
                     end;
                else          
                     begin
                         CompExec.User:=UserName;
                         CompExec.UserGroup:='UGroup.Clerk';
                     end;
            end;                                    
         end;
      end;
   except
      CompExec.User:='NoLog';
      CompExec.UserGroup:='UGroup.Clerk';
   end;     
   try
      WSName:=GetWorkstationEntry;
      if WSName = 'FRONTOFFICE' then 
         CompExec.WorkStation:='1'
      else if WSName = 'FRONTOFFICE1' then 
         CompExec.WorkStation:='1'
      else if WSName = 'ITEMISING' then 
         CompExec.WorkStation:='2'
      else if WSName = 'FRONTOFFICE2' then 
         CompExec.WorkStation:='2'
      else if WSName = 'FRONTOFFICE3' then 
         CompExec.WorkStation:='3'
      else if WSName = 'FRONTOFFICE4' then 
         CompExec.WorkStation:='4'
      else if WSName = 'FRONTOFFICE5' then 
         CompExec.WorkStation:='5'
      else if WSName = 'FRONTOFFICE6' then 
         CompExec.WorkStation:='6'
      else if WSName = 'GW9100' then 
         CompExec.WorkStation:='7'
      else 
         CompExec.WorkStation:='2';
        
      CompExec.Office:=GetZipCodeEntry;    
   except
      CompExec.WorkStation:='10';
      CompExec.Office:='3211';
   end;     
   SL.Free;
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
   SL:TStringList = nil;
begin
   if SL = nil then
   begin
      if Back then Exit;
      SL:=TStringList.Create;
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
          Show;
          TempHide:=False;
          Splash.Hide;
//          CompExecDisplayInstruct('***','')
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
procedure TMainForm.ShowModalDialog(PType:TPType;Text,DlgPrompt,DlgHint:String;B1,B2,B3:TKGButton;B1C,B2C,B3C:String);
var
   BMP:TBitMap;
const
   InModal:Boolean      = False;
   LastPad:TPType       = ptPick;
   LastPadMode:TPadMode = pmPick;
   LastPrompt:String    = '';
   LastHint:String      = '';
begin
   if not InModal then
   begin
      IPControl1.InModal:=True;
      LastPad:=ShowPad(PType);
      PadLines.SavePadText;
      LastPadMode:=PadLines.PadMode;
      PadLines.PadMode:=pmHelp;
      PadLines.Clear;
      PadLines.SetLines(Text,False);
      LastPrompt:=Prompt.Caption;
      Prompt.Caption:=DlgPrompt;
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
   end
   else
   begin
      IPControl1.InModal:=False;
      ShowPad(LastPad);
      PadLines.PadMode:=LastPadMode;
      PadLines.RestorePadText;
      Prompt.Caption:=LastPrompt;
      CompExecSetPMessage(LastHint);
      InModal:=False;
      ToggleButtonState(True);
   end;                         
end;
procedure TMainForm.CompExecSetAccounts(Caption: String);
var
   SL:TStringList;
begin
   if Caption <> '' then
   begin
      SL:=TStringList.Create;
      SL.CommaText:=Caption;
      SL.Insert(0,'"0","1","0","0","0","0","0"');
      SL.CommaText:=CompExec.Translate(SL.CommaText);
      SL.Delete(0);
      IPControl1.AcctLog(SL.CommaText,'Cash Account','Press [Enter] to examine details');
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

end.
