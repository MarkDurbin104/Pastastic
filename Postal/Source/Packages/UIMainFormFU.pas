
unit UIMainFormFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, KGButton,Comctrls,PackStrListU,UIDLLSupportU,
  MOSupportU,Preview,MODefinitionsU,Code128Consts,TestParseU,Printers,
  DB,DBTables,GPCSErrorLine,GPCSGUID,GPCSBaseAU,GPCSBase_TLB,UserListFU,
  I3UIParseU,ParseNodeU,StringUtil,ShareDataU,ReportIDSU, Grids;

const
   FileName    :String = 'Tanzania HPO MO.udd';
   RepFileName :String = 'Tanzania HPO MO.rdd';
   TestFileName:String = 'Tanzania HPO MO.tdd';
   ReportCount:Integer = 0;
   
type     
  TFormTimer = procedure;
  TOnCreateFunc = procedure;
  TOnDestroyFunc = procedure;
  TI3UIForm = class(TForm)
    TopPanel: TPanel;
    DateLabel: TLabel;
    TitleLabel: TLabel;
    BottomPanel: TPanel;
    PromptLabel: TLabel;
    HintLabel: TLabel;
    Logo: TImage;
    CancelButton: TKGButton;
    HelpButton: TKGButton;
    ILogo: TImage;
    CentrePanel: TPanel;
    Func5Button: TKGButton;
    Func4Button: TKGButton;
    Func3Button: TKGButton;
    Func2Button: TKGButton;
    Func1Button: TKGButton;
    SystemClock: TTimer;
    ButtonFontLabel: TLabel;
    PadImage: TImage;
    PadBox: TPaintBox;
    PrintPanel: TPanel;

    PSLDatabase: TDatabase;
    TUPanel: TPanel;
    PB: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure SystemClockTimer(Sender: TObject);
    procedure PadBoxPaint(Sender: TObject);
    procedure Func1ButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  public
    PrintPreview:TPrintPreview;
    CurrentControl:TWinControl;
    I3UINode:TI3UINode;
    DLLList:TStringList;
    FuncList:TStringList;
    FUserName:String;
    FUserID:String;
    FRealUserName:String;
    FUserGroup:String;
    FWorkStation:String;
    FOffice:String;
    FUsers:String;
    ItemStack:TStringList;
    CurrentItem:String;
    InModalDialog:Boolean;
    InUserList:Boolean;
    InPreviewDialog:Boolean;
    ModalResult:String;
    FFormTimer:TFormTimer;
    CurrentForm:TUIFormNode;
    ReportsNode:TReportsNode;
    TestNode:TTestNode;
    TestTimer:TTimer;
    TxnLog:ITransactionLog;
    Period:IPeriod;
    Stock:IStock;
    procedure SetTitleLabelCaption(Value:String);
    procedure ExecSeq(Seq:TCorvusNode;Count:Integer);
    procedure TestCodeRun(Sender:TObject);
    procedure PreviewFunction(Name:String);
    procedure AssignFormTimer(Name:String);
    procedure ExecuteOnCreateFunc(Name:String);
    procedure ExecuteOnDestroyFunc(Name:String);
    procedure PopItem;
    procedure PushItem;
    procedure ShowMenu(Name:String);
    procedure ShowForm(Name:String);
    procedure RunReport(Name:String);
    function  ExecuteFunction(Name:String):Integer;
    function  ExecRepFootHeadCallBackDllFunc(CallBackName,ReportName:String;PrintRect:TRect;Canvas:TCanvas;PageNo,NoPages:Integer):String;
    function  ExecRepCallBackDllFunc(CallBackName,ColumnName,ReportName,Value:String):String;
    function  ExecDllFunc(UIFunctionNode:TUIFunctionNode):Integer;
    function  GetDLLFuncPointer(UIFunctionNode:TUIFunctionNode):Pointer;
    function  GetDLLFuncPointerByName(DLL,Func:String):Pointer;
    procedure PrintBarData(BarRect:TRect;Series:String);
    procedure PrintBarCodePages(Barcodes:TStrings);
    procedure SetupDLLCall;
    procedure ReturnFromDLLCall;
    function  Exec(Name:String;Modal:Boolean):Integer;
    procedure ReprintReport; 
    procedure PopAllButtons;
    function  UnExec(Name:String):Integer;
    function  ProcessKey(var Key:Integer):Boolean;
    function  ListEqualOfffices(ThisOffice:Integer):String;
    function  ListSubOfffices(ThisOffice:Integer):String;
    function  ListOffficeNames(PackCodeList:String):String;
    procedure AppMessage(var Msg:TMsg;var Handled:Boolean);
    procedure SetUpPositions;
    procedure MonitorFileChanges;
    procedure SetupUserInterface;
    procedure ShowProgressBar(Caption:String;MinPos,MaxPos,CurrentPos:Integer);
    procedure DrawCell(Sender:TObject;Col,Row:Integer;Rect:TRect;State:TGridDrawState);
    procedure DrawList(Control:TWinControl;Index:Integer;Rect:TRect;State:TOwnerDrawState);
    procedure AttachTo(Form:TUIFormNode;Left,Top,Spacing:Integer;ParentWindow:TWinControl);
    procedure SetPromptHint(Sender:TObject);
    procedure ExitValidate(Sender:TObject);
    procedure OnChangeFunc(Sender:TObject);
    procedure StringGridSetEditText(Sender:TObject;ACol,ARow:Integer;const Value:String);
    procedure OnEnterFunc(Sender:TObject);
    procedure ExceptionEvent(Sender: TObject; E: Exception);
    procedure PickNewUser;
    procedure BarCodeFunction(Data:String);
    procedure SelectMainMenu;
  end;

procedure LogOff;
  
var
  I3UIForm:TI3UIForm;
  ErrorTimeCount:Integer;
  ErrorText:String;
  WarningText:String;
  ThisOffice:Integer;
    
implementation
{$R *.DFM}
function GetControlNamed(Name:String;ParentWindow:TWinControl):TWinControl;
var
   I:Integer;
begin
   for I:=0 to ParentWindow.ControlCount-1 do
   begin
      if (ParentWindow.Controls[I] is TWinControl) then
      begin
         Result:=ParentWindow.Controls[I] as TWinControl;
         if Result.Name = Name then Exit;
      end;   
   end;   
   Result:=nil
end;
function GetFormDetails(ParentWindow:TWinControl):String;
var
   I,J:Integer;
   Control:TWinControl;
   SL:TPackStringList;
   LSL:TPackStringList;
   SGSL:TPackStringList;
   Text:String;
begin
   SL:=TPackStringList.Create;
   LSL:=TPackStringList.Create;
   SGSL:=TPackStringList.Create;
   for I:=0 to ParentWindow.ControlCount-1 do
   begin
      if (ParentWindow.Controls[I] is TWinControl) then
      begin
         Control:=ParentWindow.Controls[I] as TWinControl;
         if (Control.Tag = 98765) then
         begin
            if (Control is TEdit) then
               Text:=(Control as TEdit).Text
            else if (Control is TStringGrid) then
            begin
               for J:=0 to (Control as TStringGrid).ColCount-1 do
               begin
                  SGSL.CommaText:=(Control as TStringGrid).Cols[J].CommaText;
                  LSL.Add(SGSL.PackText);
               end;
               Text:=LSL.PackText;
               LSL.Clear;
            end
            else if (Control is TMemo) then
               Text:=(Control as TMemo).Text
            else if (Control is TComboBox) then
               Text:=(Control as TComboBox).Text
            else if (Control is TDateTimePicker) then
               Text:=DateToStr((Control as TDateTimePicker).Date)
            else if (Control is TListBox) then
               Text:=(Control as TListBox).Items.Text;
            LSL.Add(Control.Name);
            LSL.Add(Text);
            if Control.Focused then
               LSL.Add('Focused');
            SL.Add(LSL.PackText);
            LSL.Clear;
         end;
      end;
   end;
   Result:=SL.PackText;
   SL.Free;
   LSL.Free;               
   SGSL.Free;
end;   

function GetButtonStates(ParentWindow:TWinControl):String;
var
   Button : TKGButton;
   ButtonState : TButtonState;
   ButtonStates: TPackStringList;
   I:Integer;
begin
   ButtonStates:=TPackStringList.Create;
   for I:=0 to ParentWindow.ControlCount-1 do
   begin
      if (ParentWindow.Controls[I] is TKGButton) then
      begin
         Button:=ParentWindow.Controls[I] as TKGButton;
         if Button.Visible then
         begin
            ButtonState:=TButtonState.Create;
            ButtonState.IsUp:=Button.ButtonIsUp;
            ButtonState.Caption:=Button.Caption;
            ButtonStates.Add(ButtonState.PackText);
         end;
      end;
   end;
   Result:=ButtonStates.PackText;
   ButtonStates.Free;
end;
procedure SetControlText(ParentWindow:TWinControl;ControlName,Value:String);
var
  I:Integer;
  Control:TWinControl;
begin
   for I:=0 to ParentWindow.ControlCount-1 do
   begin
      if ParentWindow.Controls[I].Name = ControlName then
      begin
         Control:=TWinControl(ParentWindow.Controls[I]);
         if (Control is TEdit) then
            (Control as TEdit).Text:=Value
         else if (Control is TMemo) then
            (Control as TMemo).Text:=Value
         else if (Control is TComboBox) then
         begin
            if Value[1] in ['0'..'9'] then
            begin
               if StrToInt(Value) < (Control as TComboBox).Items.Count then
                  (Control as TComboBox).ItemIndex:=StrToInt(Value)
               else
                  (Control as TComboBox).ItemIndex:=1;
               (Control as TComboBox).Text:=(Control as TComboBox).Items[(Control as TComboBox).ItemIndex];
            end
            else
            begin
               (Control as TComboBox).Text:=Value;
               (Control as TComboBox).ItemIndex:=(Control as TComboBox).Items.IndexOf(Value);
            end;
         end
         else if (Control is TDateTimePicker) then
            (Control as TDateTimePicker).Date:=StrToDateTime(Value)
         else if (Control is TListBox) then
         begin
            (Control as TListBox).Clear;
            (Control as TListBox).Items.Text:=Value;
         end;
         Exit;
      end;
   end;
end;     
procedure SetComboList(ParentWindow:TWinControl;ControlName:String;Details:TStrings);
var
  I:Integer;
begin
   for I:=0 to ParentWindow.ControlCount-1 do
   begin
      if ParentWindow.Controls[I].Name = ControlName then
      begin
         if (ParentWindow.Controls[I] is TComboBox) then
            (ParentWindow.Controls[I] as TComboBox).Items.Assign(Details);
         Exit;
      end;
   end;
end;     
function GetControlValue(Control:TWinControl):String;
var
   LSL :TPackStringList;
   SGSL:TPackStringList;
   J:Integer;
begin
   Result:='';
   if Control = nil then Exit;
   
   LSL :=TPackStringList.Create;
   SGSL:=TPackStringList.Create;
   
   if (Control is TEdit) then
      Result:=(Control as TEdit).Text
   else if (Control is TStringGrid) then
   begin
      for J:=0 to (Control as TStringGrid).ColCount-1 do
      begin
         SGSL.CommaText:=(Control as TStringGrid).Cols[J].CommaText;
         LSL.Add(SGSL.PackText);
      end;
      Result:=LSL.PackText;
   end
   else if (Control is TMemo) then
      Result:=(Control as TMemo).Text
   else if (Control is TComboBox) then
      Result:=(Control as TComboBox).Text
   else if (Control is TDateTimePicker) then
      Result:=DateToStr((Control as TDateTimePicker).Date)
   else if (Control is TListBox) then
      Result:=(Control as TListBox).Items.Text;
      
   LSL.Free;
   SGSL.Free;
end;
procedure SetControlValue(Control:TWinControl;Text:String);
var
   J:Integer;                    
   SGSL:TPackStringList;
   LSL:TPackStringList;
begin
   if Control = nil then Exit;
   
   LSL:=TPackStringList.Create;
   SGSL:=TPackStringList.Create;
   
   if (Control is TEdit) then
      (Control as TEdit).Text:=Text
   else if (Control is TStringGrid) then
   begin
      LSL.PackText:=Text;
      (Control as TStringGrid).ColCount:=LSL.Count;
      (Control as TStringGrid).RowCount:=1;
      for J:=0 to LSL.Count-1 do
      begin
         SGSL.PackText:=LSL[J];
         if SGSL.Count > (Control as TStringGrid).RowCount then
            (Control as TStringGrid).RowCount:=SGSL.Count;
         (Control as TStringGrid).Cols[J].CommaText:=SGSL.CommaText;
      end;
   end
   else if (Control is TMemo) then
      (Control as TMemo).Text:=Text
   else if (Control is TComboBox) then
   begin
      (Control as TComboBox).Text:=Text;
      (Control as TComboBox).ItemIndex:=(Control as TComboBox).Items.IndexOf(Text);
   end
   else if (Control is TDateTimePicker) then
   begin
      (Control as TDateTimePicker).Date:=StrToDateDef(Text, Now)
   end
   else if (Control is TListBox) then
   begin
      (Control as TListBox).Clear;
      (Control as TListBox).Items.Text:=Text;
   end;
   LSL.Free;
   SGSL.Free;
end;
function GetDomainControl(ParentWindow:TWinControl;Name:String):TWinControl;
var
   I:Integer;                    
begin
   for I:=0 to ParentWindow.ControlCount-1 do
   begin
      if (ParentWindow.Controls[I] is TWinControl) then
      begin
         Result:=ParentWindow.Controls[I] as TWinControl;
         if (Result.Tag = 98765) and (Result.Name = Name) then
            Exit;
      end;
   end;
   Result:=nil;
end;
procedure SetFormDetails(ParentWindow:TWinControl;Details:String);
var
   Idx,I:Integer;                    
   Control:TWinControl;
   SL:TPackStringList;
   LSL:TPackStringList;
   FocusedIndex:Integer;
begin
   FocusedIndex:=-1;
   SL:=TPackStringList.Create;
   LSL:=TPackStringList.Create;
        
   SL.PackText:=Details;
   for I:=0 to SL.Count-1 do
   begin
      LSL.PackText:=SL[I];
      if LSL.Count > 1 then
      begin
         SL[I]:=LSL[0];
         SL.Objects[I]:=TStringObject.Create(LSL[1]);
         if (LSL.Count > 2) and (LSL[2] = 'Focused') then
            FocusedIndex:=I;
      end;
   end;
   for I:=0 to ParentWindow.ControlCount-1 do
   begin
      if (ParentWindow.Controls[I] is TWinControl) then
      begin
         Control:=ParentWindow.Controls[I] as TWinControl;
         if (Control.Tag = 98765) then
         begin
            Idx:=SL.IndexOf(Control.Name);
            if Idx <> -1 then
            begin
               SetControlValue(Control,TStringObject(SL.Objects[Idx]).Value);
               if FocusedIndex = Idx then
               begin
                  if Control.Enabled then
                     Control.SetFocus;
               end;
            end;
         end;
      end;
   end;
   for I:=0 to SL.Count-1 do
      if SL.Objects[I] <> nil then
         TStringObject(SL.Objects[I]).Free;
   SL.Free;
   LSL.Free;
end;    
procedure TriggerError;
const
   ErrorTimeLimit = 6;
var
   ET:String;
begin
   if GetGPCSRegString(SystemType,'Mute Beep','0') = '0' then
      Windows.Beep(2000,400);
   ET:=ErrorText;
   ErrorText:=I3UIForm.PromptLabel.Caption;
   I3UIForm.PromptLabel.Caption:=ET;

   I3UIForm.PromptLabel.Font.Color:=clRed;
   I3UIForm.HintLabel.Font.Color:=clRed;
   ErrorTimeCount:=ErrorTimeLimit;
end;

procedure StretchBMP(Canvas:TCanvas;Bitmap:TBitmap;InRect:TRect;CentreLine:Integer);
var
   SR,DR:TRect;
begin
   with Canvas do
   begin
      SR:=Bounds(0,0,CentreLine,Bitmap.Height);
      DR:=Bounds(InRect.Left,InRect.Top,CentreLine,InRect.Bottom-InRect.Top);
      CopyRect(DR,Bitmap.Canvas,SR);

      SR:=Bounds(CentreLine-1,0,1,Bitmap.Height);
      DR:=Bounds(InRect.Left+CentreLine,InRect.Top,(InRect.Right-InRect.Left)-(CentreLine+(Bitmap.Width-CentreLine)),InRect.Bottom-InRect.Top);
      CopyRect(DR,Bitmap.Canvas,SR);

      SR:=Rect(CentreLine,0,Bitmap.Width,Bitmap.Height);
      DR:=Bounds(InRect.Right-(Bitmap.Width-CentreLine),InRect.Top,(Bitmap.Width-CentreLine),InRect.Bottom-InRect.Top);
      CopyRect(DR,Bitmap.Canvas,SR);
   end;
end;
function CallBackFunction(Name:String;Modal:Boolean):Integer;
var
   Destination:Integer;
   Office:TOffice;
   OType,ControlName:String;
   SL:TPackStringList;
begin
   Result:=0;
   if UpperCase(Copy(Name,1,12)) = 'MODALRESULT=' then
   begin
      I3UIForm.ModalResult:=Copy(Name,13,Length(Name));
      I3UIForm.InModalDialog:=False;
   end
   else if UpperCase(Copy(Name,1,11)) = 'OFFICECODE.' then
   begin
      Result:=0;
      Office:=I3UIForm.I3UINode.OfficeNode.OfficeNamed(Copy(Name,12,Length(Name)));
      if Office <> nil then
         Result:=Office.Code;
   end
   else if UpperCase(Copy(Name,1,11)) = 'OFFICETYPE.' then
   begin
      OType:='NN';
      Office:=I3UIForm.I3UINode.OfficeNode.OfficeCoded(StrToIntDef(Copy(Name,12,Length(Name)),0));
      if Office <> nil then 
      begin
         if Office.IsAutomated then OType:='A'       else OType:='N';
         if Office.IsSorting   then OType:=OType+'S' else OType:=OType+'N';
      end;
      SharedData.SetVariable('OfficeType',OType);
   end
   else if UpperCase(Copy(Name,1,11)) = 'OFFICENAME.' then
   begin
      Result:=0;
      Office:=I3UIForm.I3UINode.OfficeNode.OfficeCoded(StrToIntDef(Copy(Name,12,Length(Name)),0));
      if Office <> nil then 
         SharedData.SetVariable(Name,Office.Name);
   end
   else if UpperCase(Name) = 'PAGEBARCODES' then
   begin
      Result:=0;
      SL:=TPackStringList.Create;
      SL.PackText:=SharedData.GetVariable('BarCodeData');
      I3UIForm.PrintBarCodePages(SL);
      SL.Free;
   end
   else if UpperCase(Copy(Name,1,11)) = 'NEXTOFFICE.' then
   begin
      Destination:=StrToInt(Copy(Name,12,Length(Name)));
      Result:=FindNextOffice(I3UIForm.I3UINode,StrToIntDef(I3UIForm.FOffice,0),Destination);
   end
   else if UpperCase(Copy(Name,1,11)) = 'PROGRESSBAR' then
   begin
      SL:=TPackStringList.Create;
      SL.CommaText:=Name;
      if SL.Count > 4 then
         I3UIForm.ShowProgressBar(SL[1],StrToIntDef(SL[2],0),StrToIntDef(SL[3],0),StrToIntDef(SL[4],0));
      SL.Free;
   end                        
   else if UpperCase(Copy(Name,1,13)) = 'POPULATECOMBO' then
   begin
      SL:=TPackStringList.Create;
      SL.PackText:=Copy(Name,14,Length(Name));
      if SL.Count > 0 then
      begin
         ControlName:=SL[0]; SL.Delete(0);
         SetComboList(I3UIForm.CentrePanel,ControlName,SL);
      end;
      SL.Free;
   end                        
   else 
   begin
      I3UIForm.ModalResult:='';
      Result:=I3UIForm.Exec(Name,Modal);
      if I3UIForm.ModalResult <> 'Cancel' then
         Result:=1;
   end; 
end;
function OfficeCodeToName(Code:Integer):String;
var
   I:Integer;
   
begin
   Result:=IntToStr(Code);
   
   if (I3UIForm = nil) 
   or (I3UIForm.I3UINode = nil) 
   or (I3UIForm.I3UINode.OfficeNode = nil)then Exit;
   
   for I:=0 to I3UIForm.I3UINode.OfficeNode.Count-1 do
   begin
      if I3UIForm.I3UINode.OfficeNode.Office[I].Code = Code then
      begin
         Result:=I3UIForm.I3UINode.OfficeNode.Office[I].Name;
         Exit;
      end;
   end;
end;
procedure TI3UIForm.ShowProgressBar(Caption:String;MinPos,MaxPos,CurrentPos:Integer);
begin
   if MaxPos = 0 then 
   begin
      PB.Visible:=False;
      Exit;
   end;
   if not PB.Visible then
   begin
      HintLabel.Caption:='';
      PB.SetBounds(HintLabel.Left,HintLabel.Top+(HintLabel.Height div 4),HintLabel.Width,HintLabel.Height div 2);
      PB.Visible:=True;
   end;
   if PB.Min <> MinPos then PB.Min:=MinPos;
   if PB.Max <> MaxPos then PB.Max:=MaxPos;
   
   PromptLabel.Caption:=Caption;
   PB.Position:=CurrentPos;
   Application.ProcessMessages;
   if Application.Terminated then
      Close;
end;    
procedure TI3UIForm.SetTitleLabelCaption(Value:String);
var
   BMP:TBitmap;
begin
   BMP:=TBitmap.Create;
   BMP.Height:=100;
   BMP.Width:=1024;
   TitleLabel.Font.Size:=36;
   BMP.Canvas.Font:=TitleLabel.Font;
   while (BMP.Canvas.Font.Size > 8) 
   and (BMP.Canvas.TextWidth(Value) > TitleLabel.Width) do
      BMP.Canvas.Font.Size:=BMP.Canvas.Font.Size-1;
   if (BMP.Canvas.Font.Size > 8) and (BMP.Canvas.Font.Size < 36) then
      TitleLabel.Font.Size:=BMP.Canvas.Font.Size;
   BMP.Free;
   TitleLabel.Caption:=Value;
end;
procedure TI3UIForm.PrintBarData(BarRect:TRect;Series:String);
var
  SerialNo :String;
  Value    :Currency;
  Clerk    :Integer;
  IOffice  :Integer;
  POffice  :Integer;
  TOfs,Len,I :Integer;
  MOType   :TMOType;
  IssueDate:TDateTime;
  BarData  :String;
  S,EncBarString:String;
  BR:TRect;
  MP:Integer;
begin 
   OffsetRect(BarRect,
      0-StrToIntDef(GetGPCSRegString('Reports','Portrait X Adjust','0'),0),
      StrToIntDef(GetGPCSRegString('Reports','Portrait Y Adjust','0'),0));
      
   with PrintPreview.Canvas do
   begin
      Font.Name:='Arial';
      Font.Style:=[fsBold];       
      Font.Size:=300;
      InflateRect(BarRect,-100,-100);
      MP:=BarRect.Left+((BarRect.Right-BarRect.Left) div 2);
      Rectangle(BarRect.Left,BarRect.Top,BarRect.Right,BarRect.Bottom);
      InflateRect(BarRect,-100,-100);
      TextOut(MP-(TextWidth(Series+'   ') div 2),BarRect.Top,
         Copy(Series,1,5)+' '+Copy(Series,6,5)+' '+Copy(Series,11,5)+' '+Copy(Series,16,5));
   end;
   if DecodeMoneyOrder(Series,SerialNo,Value,IOffice,POffice,Clerk,MOType,IssueDate) then
   begin
      BarData:=MOSeriesToCode128(Series);
      S:=STARTBARA;
      for I:=0 to (Length(BarData) div 2)-1 do
         S:=S+Char(StrToInt(Copy(BarData,I*2+1,2)));
      S:=S+Calc128CRC(S);
      S:=S+STOPBARCODE;
      EncBarString:='';
      for I:=1 to Length(S) do EncBarString:=EncBarString+BCData[Integer(S[I]),3];
      Len:=0;
      for I:=1 to Length(EncBarString) do Inc(Len,(Integer(EncBarString[I])-48));
      Len:=Len*30;
      
      BR:=Bounds(MP-(Len div 2),
                 BarRect.Top+PrintPreview.Canvas.TextHeight(Series),
                 Len,
                 ((BarRect.Bottom-BarRect.Top) div 3)-PrintPreview.Canvas.TextHeight('Wg'));
      EncStringCanvasPixels(PrintPreview.Canvas,BR,EncBarString,30);
      with PrintPreview.Canvas do
      begin
         TOfs:=BR.Bottom;
         TextOut(MP-TextWidth('Tanzania Posts Corporation') div 2,TOfs,'Tanzania Posts Corporation');
         Inc(TOfs,TextHeight('Wg'));
         TextOut(MP-TextWidth('Money Order Authorisation Form') div 2,TOfs,'Money Order Authorisation Form');
         Inc(TOfs,TextHeight('Wg'));
         TextOut(BarRect.Left+200,TOfs,'Serial Number :' );
         TextOut(BarRect.Left+TextWidth('Serial Number :  '),TOfs,LeftPad(SerialNo,7,'0'));
         Inc(TOfs,TextHeight('Wg'));
         TextOut(BarRect.Left+200,TOfs,'Value :'         );
         TextOut(BarRect.Left+TextWidth('Serial Number :  '),TOfs,CurrToStrF(Value,ffNumber,2));
         Inc(TOfs,TextHeight('Wg'));
         TextOut(BarRect.Left+200,TOfs,'Issue Office :'  );
         TextOut(BarRect.Left+TextWidth('Serial Number :  '),TOfs,OfficeCodeToName(IOffice));
         Inc(TOfs,TextHeight('Wg'));
         TextOut(BarRect.Left+200,TOfs,'Pay Office :'    );
         TextOut(BarRect.Left+TextWidth('Serial Number :  '),TOfs,OfficeCodeToName(POffice));
      end;                                                    
   end;                                                         
end;
procedure TI3UIForm.PrintBarCodePages(Barcodes:TStrings);
var
  I:Integer;
  BarRect:TRect;
  BarPos:Integer;
  PW,PH:Integer;
const
   LabelPerPage = 12;
begin
   BarPos:=0;
   if not MultiSection then
   begin
      ReportCount:=0;
      PrintPreview:=TPrintPreview.Create(nil);
      PrintPanel.Visible:=True;
      PrintPanel.BringToFront;
      PrintPanel.InsertControl(PrintPreview);
    //  PrintPreview.Paper.ShadowColor:=BottomPanel.Color;
    //  PrintPreview.Paper.ShadowSize:=5;
      PrintPreview.Name:='pp';
      PrintPreview.ZoomState:=zsZoomToWidth;
   end;
   PW:=PrintPreview.PaperWidth div 2;
   PH:=PrintPreview.PaperHeight div (LabelPerPage div 2);
   
   if ReportCount = 0 then
   begin
      PrintPreview.Orientation:=poPortrait;
      PrintPreview.BeginDoc;      
   end
   else
      PrintPreview.NewPage;
      
   for I:=0 to BarCodes.Count-1 do
   begin
      if BarPos = LabelPerPage then 
      begin
         BarPos:=0;
         PrintPreview.NewPage;
      end;
      BarRect:=Bounds((BarPos mod 2)*PW,(BarPos div 2)*PH,PW,PH);
      PrintBarData(BarRect,BarCodes[I]);
      Inc(BarPos);
   end;

   Inc(ReportCount);
   if not MultiSection then
   begin
      PrintPreview.EndDoc;
      PreviewFunction('Preview');
   end;
end;
procedure TI3UIForm.SetupDLLCall;
var
  UserInfo : TStringList;
begin
   try
      UserInfo:=TStringList.Create;
      UserInfo.CommaText:=FUserID;
      If UserInfo.Count > 0 then SharedData.SetVariable('ClerkCode'      ,IntToStr(StrToIntDef(UserInfo[0],0)))
      else SharedData.SetVariable('ClerkCode'      ,'0');
      If UserInfo.Count > 1 then SharedData.SetVariable('ClerkOfficeCode',IntToStr(StrToIntDef(UserInfo[1],0)))
      else SharedData.SetVariable('ClerkOfficeCode','0');
      UserInfo.Free;
      SharedData.SetVariable('FormData'    ,GetFormDetails(CentrePanel));
      SharedData.SetVariable('ButtonStates',GetButtonStates(CentrePanel));
      SharedData.SetVariable('ClerkName'   ,FUserName);
      SharedData.SetVariable('OfficeCode'  ,FOffice);
      SharedData.SetVariable('Workstation' ,FWorkstation);
   except
      on E : Exception do RaiseGUIDException('{BEBF4031-BBF3-4540-BAF4-156C413CE85C}',E);
   end;
end;
procedure TI3UIForm.ReturnFromDLLCall;
var
  FD:String;
begin
  // showmessage(GetFocusedFieldName);
   FD:=SharedData.GetVariable('FormData');
   if FD <> GetFormDetails(CentrePanel) then
      SetFormDetails(CentrePanel,FD);
   ErrorText:=SharedData.GetVariable('ErrorString');
  // WarningText:=SharedData.GetVariable('WarningString');
   if ErrorText <> '' then
   begin
      SharedData.SetVariable('ErrorString','');
      TriggerError;
   end;
end;
procedure TI3UIForm.PickNewUser;
var
   SL:TPackStringList;
   I:Integer;
begin
   if (not InPreviewDialog) and (not InModalDialog) and (not InUserList)
   and (GetGPCSRegString('Workstation','Switch','No') <> 'No') then
   begin
      SL:=TPackStringList.Create;
      FUserName:=FRealUserName;
      SL.PackText:=FUsers;
      I:=SL.IndexOf(FUserName);
      if (I = -1) and (SL.Count > 0) then I:=0;
      if I >= 0 then
      begin
        //show user selection form
        UserList.UsersListBox.Items.Assign(SL);
        UserList.UsersListBox.ItemIndex := I;
        InUserList:=True;
        If UserList.ShowModal = mrOK then
        begin
          InUserList:=False;
          I := UserList.UsersListBox.ItemIndex;
          if I < SL.Count then
            FUserName:=SL[I]
          else
            FUserName:=SL[0];
          UserList.GetUserDetails(FUserName,FRealUserName,FUserID,FUserGroup,FWorkStation,FOffice,FUsers);
          SelectMainMenu;
        end;
        InUserList:=False;
      end
      else
      begin
         ShowMessage('No Other Users Found!');
      end;
      SL.Free;
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

function TI3UIForm.ProcessKey(var Key:Integer):Boolean;
var
   Shift:Boolean;
   C:Char;
const       
   CollectingTrigger:Boolean = False;
   TriggerData:String = '';
begin
   Result:=False;
   if InUserList then Exit;
   if InPreviewDialog then
   begin
      case Key of
         VK_F2     : Func1Button .ForceClick;
         VK_F3     : Func2Button .ForceClick;
         VK_F4     : if (GetKeyState(VK_MENU) >= 0) then Func3Button.ForceClick;
         VK_F5     : Func4Button .ForceClick;
         VK_F6     : Func5Button .ForceClick;
         VK_ESCAPE : CancelButton.ForceClick;
         VK_PRIOR  : PreviewFunction('Previous Page');
         VK_NEXT   : PreviewFunction('Next Page');
         VK_DOWN   : PreviewFunction('Bottom of Page');
         VK_UP     : PreviewFunction('Top of Page');
         VK_HOME   : PreviewFunction('First Page');
         VK_END    : PreviewFunction('Last Page');
      end;
      Result:=True;
      Exit;
   end;
   
   // Alt Pressed without a function key
   if (GetKeyState(VK_MENU) < 0) then // and (Key <> VK_F4) then
      Exit;
   Shift:=GetKeyState(VK_SHIFT) < 0;
   Result:=True;
   if CollectingTrigger then
   begin
      if (((Shift) and (Key in [55,56])) or(not(Shift) and (Key in [219,221]) )) then
      begin
         CollectingTrigger:=False;
         BarCodeFunction(TriggerData);
         TriggerData:='';
      end
      else
      begin
         C:=MapKey(Key,Shift);
         if (C > #31) then TriggerData:=TriggerData+C;
      end;                  
   end 
   else
   begin
      case Key of
         VK_F1     : HelpButton.ForceClick;
         VK_F2     : Func1Button .ForceClick;
         VK_F3     : Func2Button .ForceClick;
         VK_F4     : if (GetKeyState(VK_MENU) >= 0) then Func3Button.ForceClick;
         VK_F5     : Func4Button .ForceClick;
         VK_F6     : Func5Button .ForceClick;
         VK_ESCAPE : CancelButton.ForceClick;
         VK_RETURN : if (ActiveControl is TMemo) then
                     begin
                        Result:=False
                     end
                     else if (ActiveControl is TStringGrid) then
                     begin
                        Key:=VK_DOWN;
                        Result:=False;
                     end
                     else    
                     begin
                        SelectNext(ActiveControl,True,True);
                     end;
         VK_DOWN    : begin
                        if (ActiveControl is TListBox)
                        or (ActiveControl is TMemo)
                        or (ActiveControl is TStringGrid)
                        or ((ActiveControl is TComboBox) and (ActiveControl as TComboBox).DroppedDown) then
                           Result:=False
                        else
                           SelectNext(ActiveControl,True,True);
                     end;
         VK_UP     : begin
                        if (ActiveControl is TListBox)
                        or (ActiveControl is TMemo)
                        or (ActiveControl is TStringGrid)
                        or ((ActiveControl is TComboBox) and (ActiveControl as TComboBox).DroppedDown) then
                           Result:=False
                        else
                           SelectNext(ActiveControl,False,True);
                     end;
         VK_HOME   : while ItemStack.Count > 0 do
                        CancelButton.ForceClick;
         VK_END    : PickNewUser;
   //      VK_SPACE  :
   //      VK_PRIOR  :
   //      VK_NEXT   :
            55, 56,
            219,221   : if ((   (Shift) and (Key in [55,56]  )) 
                        or  (not(Shift) and (Key in [219,221]))) then
                           CollectingTrigger:=True
                        else
                           Result:=False;
         else              
            Result:=False;
      end;
   end;
end;

procedure TI3UIForm.AppMessage(var Msg:TMsg;var Handled:Boolean);
var
   MessageType:Integer;
begin
   Handled:=False;
//   if Complete then Exit;
   MessageType:=Msg.Message;
   if (MessageType >= WM_KEYFIRST) and (MessageType <= WM_KEYLAST) then
   begin
      case MessageType of
          WM_KEYDOWN,
          WM_SYSKEYDOWN :
             if ProcessKey(Msg.WParam) then
                Handled:=True;
      end;
   end;
end;
procedure TI3UIForm.SetUpPositions;
var
   TOfs:Integer;
   LogoWidth:Integer;
begin
   Application.OnMessage:=AppMessage;
   if Screen.Width = 1024 then
   begin
      Left:=0;
      Top:=0;
      BorderIcons:=[];
      BorderStyle:=bsNone;
      Width:=1024;
      Height:=768;
   end
   else
   begin
      Width:=(Width-ClientWidth)+1024;
      Height:=(Height-ClientHeight)+768;
   end;
   HelpButton.Left:=Width-HelpButton.Width;
   ILogo.Left:=HelpButton.Left-(ILogo.Width+10);
   ILogo.Top:=(TopPanel.Height-ILogo.Height) div 2;
   TOfs:=(CentrePanel.Height-(Func1Button.Height * 5)) div 2;
   Func2Button.UpBitMap:=Func1Button.UpBitMap; Func2Button.DownBitMap:=Func1Button.DownBitMap;
   Func3Button.UpBitMap:=Func1Button.UpBitMap; Func3Button.DownBitMap:=Func1Button.DownBitMap;
   Func4Button.UpBitMap:=Func1Button.UpBitMap; Func4Button.DownBitMap:=Func1Button.DownBitMap;
   Func5Button.UpBitMap:=Func1Button.UpBitMap; Func5Button.DownBitMap:=Func1Button.DownBitMap;
   Func1Button.Left:=Width-(Func1Button.Width+TOfs); Func1Button.Top:=TOfs;
   Func2Button.Left:=Width-(Func2Button.Width+TOfs); Func2Button.Top:=Func1Button.Top+Func1Button.Height;
   Func3Button.Left:=Width-(Func3Button.Width+TOfs); Func3Button.Top:=Func2Button.Top+Func2Button.Height;
   Func4Button.Left:=Width-(Func4Button.Width+TOfs); Func4Button.Top:=Func3Button.Top+Func3Button.Height;
   Func5Button.Left:=Width-(Func5Button.Width+TOfs); Func5Button.Top:=Func4Button.Top+Func4Button.Height;
   LogoWidth:=Logo.Width;
   DateLabel  .SetBounds(LogoWidth+Logo.Left,3,600,30);
   TitleLabel .SetBounds(LogoWidth+Logo.Left,30,ILogo.Left-(Logo.Width+Logo.Left+10),59);
   PromptLabel.SetBounds(140,-6,884,39);
   HintLabel  .SetBounds(140,31,884,63);
   PadImage.Top:=(CentrePanel.Height-PadImage.Height) div 2;
   PadBox.Height:=PadImage.Height;
   PadBox.Top   :=PadImage.Top;
   PadBox.Left  :=PadImage.Left;
   PadBox.Width :=Func5Button.Left-PadBox.Left*2;
   PrintPanel.Left  :=PadBox.Left;
   PrintPanel.Top   :=PadBox.Top;
   PrintPanel.Width :=PadBox.Width;
   PrintPanel.Height:=PadBox.Height;
end;
procedure TI3UIForm.ExecSeq(Seq:TCorvusNode;Count:Integer);
var
   I,SP:Integer;
   CN:TCorvusNode;
   S:String;
begin
   for I:=0 to Count-1 do
   begin
      Application.ProcessMessages;
      if Application.Terminated then Exit;
      SP:=0;
      while SP < SEQ.Count do
      begin
         if Copy(Seq[SP],1,4) = 'Loop' then
         begin
            CN:=TCorvusNode(Seq.Objects[SP]);
            if CN.Count > 0 then
            begin
               ExecSeq(CN,StrToInt(CN[0]));
            end;
         end
         else if Copy(Seq[SP],1,4) = 'Exec' then
         begin
            if Seq.Objects[SP] <> nil then
            begin
               Refresh;
               CN:=TCorvusNode(Seq.Objects[SP]);
               Exec(CN[0],False);
            end
            else
            begin
               Refresh;                                   
               Inc(SP);
               if SP < SEQ.Count then
                  Exec(Seq[SP],False);
            end;       
         end
         else if Copy(Seq[SP],1,5) = 'Input' then
         begin
            if Seq.Objects[SP] <> nil then
            begin
               CN:=TCorvusNode(Seq.Objects[SP]);
               Exec(CN[0],False)
            end
            else
            begin
               Inc(SP); 
               S:='';
               if (Seq[SP+1] <> '') and (Seq[SP+1][1] = '*') then
                  S:=IntToStr(Random(StrToInt(Copy(Seq[SP+1],2,Length(Seq[SP+1])))))
               else
                  S:=Seq[SP+1];
               SetControlText(CentrePanel,Seq[SP],S);
               Inc(SP);
            end;
         end; 
         Inc(SP);
      end;
   end; 
end;
procedure TI3UIForm.TestCodeRun(Sender:TObject);
var
   I:Integer;
   Seq:TCorvusNode;
begin
   
   Randomize;
   TestTimer.Enabled:=False;
   if TestNode <> nil then
   begin
      for I:=0 to TestNode.Tests.Count-1 do
      begin
         Seq:=TUITestNode(TestNode.Tests.Objects[I]);// TCorvusNode().Objects[0]);
         ExecSeq(Seq,1);
      end;
   end;
end;
procedure TI3UIForm.SelectMainMenu;
begin
   while ItemStack.Count > 0 do CancelButton.ForceClick;
   if I3UINode.Menus.Count > 0 then
   begin
      if (UpperCase(FRealUserName) = 'ADMINISTRATOR')
      and (I3UINode.Menus.IndexOf('Administrator') <> -1) then
      begin
         ShowMenu('Menu.'+I3UINode.Menus[I3UINode.Menus.IndexOf('Administrator')]);
      end
      else
      begin
         if I3UINode.Menus.IndexOf(FUserGroup) <> -1 then
            ShowMenu('Menu.'+I3UINode.Menus[I3UINode.Menus.IndexOf(FUserGroup)])
         else
            ShowMenu('Menu.'+I3UINode.Menus[0]);
      end;
   end;
end;
procedure TI3UIForm.MonitorFileChanges;
var
   J:Integer;
   AttA,AttB:Integer;
   SearchRec:TSearchRec;
   ProjectChanged:Boolean;
const
   Checking:Boolean = False;
   LastCheck:Integer = 8;
begin
   Dec(LastCheck);
   if LastCheck < 1 then
   begin
      if Checking then Exit;
      Checking:=True;
      try
         ProjectChanged:=False;
         if (I3UINode <> nil) and (I3UINode.FileList <> nil) then
         begin
            for J:=0 to I3UINode.FileList.Count-1 do
            begin
               AttB:=0;
               if FindFirst(I3UINode.FileList[J],$FFFF,SearchRec) = 0 then
                  AttB:=SearchRec.Time xor SearchRec.Size;
               AttA:=Integer(I3UINode.FileList.Objects[J]);
               if AttA <> AttB then
               begin
                  ProjectChanged:=True;
                  break;
               end;
            end;
         end;
         if ProjectChanged then
         begin
            CurrentForm:=nil;
            I3UINode.Free;
            I3UINode:=nil;
            MOSupportU.I3UINode:=nil;
            ReportsNode.Free;
            ReportsNode:=nil;
            MOSupportU.ReportsNode:=nil;
            ItemStack.Clear;
            SetupUserInterface;
            SelectMainMenu;
         end
         else
         begin
            if (ReportsNode <> nil) and (ReportsNode.FileList <> nil) then
            begin
               for J:=0 to ReportsNode.FileList.Count-1 do
               begin
                  AttB:=0;
                  if FindFirst(ReportsNode.FileList[J],$FFFF,SearchRec) = 0 then
                     AttB:=SearchRec.Time xor SearchRec.Size;
                  AttA:=Integer(ReportsNode.FileList.Objects[J]);
                  if AttA <> AttB then
                  begin
                     ProjectChanged:=True;
                     break;
                  end;
               end;
            end;
            if ProjectChanged then
            begin
               ReportsNode.Free;
               ReportsNode:=nil;
               MOSupportU.ReportsNode:=nil;
               ReportsNode:=GetI3ReportsNode;
            end
         end;
      finally
         LastCheck:=8;
         Checking:=False;
      end;
   end;
end;
procedure TI3UIForm.SetupUserInterface;
begin
  if SharedData <> nil then
     SharedData.Free;
  I3UINode     := CreateI3UINode(GetGPCSRegString(SystemType, 'MOTypes', ''));
  ReportsNode  := GetI3ReportsNode;

  SharedData:=TSharedData.Create('CorvusReportShare',False);

  if Assigned(I3UINode) then
  begin
     Caption:=I3UINode.System.Title;
     if FileExists(I3UINode.System.Bitmap) then
     begin
        Logo.Picture.Bitmap.LoadFromFile(I3UINode.System.Bitmap);
        DateLabel.Left:=Logo.Picture.Bitmap.Width+2;
     end;
     if FileExists(I3UINode.System.SUButton) then
        HelpButton.UpBitmap.LoadFromFile(I3UINode.System.SUButton);
     if FileExists(I3UINode.System.SDButton) then
     begin
        HelpButton.DownBitmap.LoadFromFile(I3UINode.System.SDButton);
        TopPanel.Color:=HelpButton.DownBitmap.Canvas.Pixels[0,0];
     end;
     if FileExists(I3UINode.System.MUButton) then
        CancelButton.UpBitmap.LoadFromFile(I3UINode.System.MUButton);
     if FileExists(I3UINode.System.MDButton) then
     begin
        CancelButton.DownBitmap.LoadFromFile(I3UINode.System.MDButton);
        BottomPanel.Color:=CancelButton.DownBitmap.Canvas.Pixels[0,0];
     end;
     if FileExists(I3UINode.System.LUButton) then
        Func1Button.UpBitmap.LoadFromFile(I3UINode.System.LUButton);
     if FileExists(I3UINode.System.LDButton) then
     begin
        Func1Button.DownBitmap.LoadFromFile(I3UINode.System.LDButton);
        CentrePanel.Color:=Func1Button.DownBitmap.Canvas.Pixels[0,0];
     end;
     if FileExists(I3UINode.System.Pad) then
        PadImage.Picture.Bitmap.LoadFromFile(I3UINode.System.Pad);
     if FileExists(I3UINode.System.Logo) then
        ILogo.Picture.Bitmap.LoadFromFile(I3UINode.System.Logo);
     if I3UINode.System.HColour <> '' then
     begin
        DateLabel.Font.Color:=StrToInt(I3UINode.System.HColour);
        TitleLabel.Font.Color:=StrToInt(I3UINode.System.HColour);
     end;
     if I3UINode.System.FColour <> '' then
     begin
        PromptLabel.Font.Color:=StrToInt(I3UINode.System.FColour);
        HintLabel.Font.Color:=StrToInt(I3UINode.System.FColour);
     end;
     if I3UINode.System.TUPanel <> '' then
        TUPanel.Color:=StrToInt(I3UINode.System.TUPanel);
  end;
  SetUpPositions;
end;
procedure TI3UIForm.FormCreate(Sender: TObject);
var
  SL:TPackStringlist;
begin
  Application.OnException:=ExceptionEvent;
  UserList:=TUserList.Create(nil);
  TxnLog:=CreateTransactionLog;
  Period:=CreatePeriod;
  Stock :=CreateStock;
  if GetGPCSRegString('Workstation','DBType','Paradox') = 'Oracle' then
  begin
    PSLDataBase.Params.Add('USER NAME='+GetGPCSRegString('','UserName','psl'   ));
    PSLDataBase.Params.Add('PASSWORD=' +GetGPCSRegString('','Password','suvroc'));
  end;

  DLLList   :=TStringList.Create;
  FuncList  :=TStringList.Create;
  ItemStack :=TStringList.Create;
  UserList.GetUserDetails(FUserName,FRealUserName,FUserID,FUserGroup,FWorkStation,FOffice,FUsers);
  ThisOffice:=StrToIntDef(FOffice,ThisOffice);

  ReportsLogoKeyName:=SystemType+'\Reports';
  SetupUserInterface;
  SelectMainMenu;

  SystemClockTimer(nil);

  TestFileName:=GetGPCSRegString(SystemType,'Test Definition Data',TestFileName);
  if (Copy(TestFileName,1,1) <> '\') and (Copy(TestFileName,2,1) <> ':') then
    TestFileName:=ApplicationRootPath+TestFileName;
  if FileExists(TestFileName) then
  begin
    TestNode:=TTestNode.Create('Test',TestFileName,1);
    TestNode.ParseFile(ExtractFilePath(TestFileName),TestFileName,1);
    TestTimer:=TTimer.Create(nil);
    TestTimer.Enabled:=False;
    TestTimer.Interval:=500;
    TestTimer.OnTimer:=TestCodeRun;
    TestTimer.Enabled:=True;
  end;

  // Test to check whether UserInfo is valid ie - in the format 9999999,99
  try
     SL:=TPackStringlist.Create;
     SL.CommaText:=FUserID;
     if SL.Count > 0 then SharedData.SetVariable('ClerkCode'      ,SL[0]);
     if SL.Count > 1 then SharedData.SetVariable('ClerkOfficeCode',SL[1]);
     if SL.Count < 2 then
     begin
        RaiseGUIDError('{187C1420-65E4-4BBF-8E82-32D7BC5D453C}','User Info not supplied for user '+FUserName);
     end;
     SL.Free;
  except
     on E : Exception do RaiseGUIDException('{DA5B17C8-5FC6-4AA4-AF24-1B92F7E2CC6C}',E);
  end;
end;

function TI3UIForm.ListOffficeNames(PackCodeList:String):String;
var
   SL:TPackStringList;
   I:Integer;
begin
   Result:=PackCodeList;
   if  (I3UINode <> nil)
   and (I3UINode.OfficeNode <> nil) then
   begin
      SL:=TPackStringList.Create;
      SL.PackText:=PackCodeList;
      for I:=0 to SL.Count-1 do
      begin
         SL[I]:=I3UINode.OfficeNode.OfficeCoded(StrToIntDef(SL[I],0)).Name;
      end;
      Result:=SL.PackText;
   end;         
end;
function TI3UIForm.ListSubOfffices(ThisOffice:Integer):String;
var
   SL:TPackStringList;
   I:Integer;
begin
   Result:='';
   if  (I3UINode <> nil)
   and (I3UINode.OfficeNode <> nil) then
   begin
      SL:=TPackStringList.Create;
      for I:=0 to I3UINode.OfficeNode.Count-1 do
      begin
         if I3UINode.OfficeNode.Office[I].ParentNode = ThisOffice then
         begin
            SL.Add(IntToStr(I3UINode.OfficeNode.Office[I].Code));
         end;
      end;
      Result:=SL.PackText;
   end;
end;
function TI3UIForm.ListEqualOfffices(ThisOffice:Integer):String;
var
   SL:TPackStringList;
   I:Integer;
   ThisOfficeParent:Integer;
begin
   Result:='';
   if  (I3UINode <> nil)
   and (I3UINode.OfficeNode <> nil) then
   begin
      ThisOfficeParent:=I3UINode.OfficeNode.OfficeCoded(ThisOffice).ParentNode;
      if ThisOfficeParent = 0 then Exit;
      
      SL:=TPackStringList.Create;    
      for I:=0 to I3UINode.OfficeNode.Count-1 do 
      begin
         if (I3UINode.OfficeNode.Office[I].ParentNode = ThisOfficeParent)
         and (I3UINode.OfficeNode.Office[I].Code <> ThisOffice) then
         begin
            SL.Add(IntToStr(I3UINode.OfficeNode.Office[I].Code));
         end;
      end;
      Result:=SL.PackText;
   end;
end;
procedure TI3UIForm.SystemClockTimer(Sender: TObject);
var
   S:String;
begin
   if ErrorTimeCount > 0 then
   begin
      Dec(ErrorTimeCount);
      if ErrorTimeCount = 0 then
      begin
         PromptLabel.Caption:=ErrorText;
         if I3UINode.System.FColour = '' then
         begin
            PromptLabel.Font.Color:=$00D2DEE0;
            HintLabel.Font.Color  :=$00DDE7E9;  
         end
         else
         begin
            PromptLabel.Font.Color:=StrToInt(I3UINode.System.FColour);
            HintLabel.Font.Color:=StrToInt(I3UINode.System.FColour);
         end;                
      end;
   end;
   S:=FormatDateTime('dddd, dd mmmm yyyy, hh:nn',Now) +
         '  U.'+FUserName+
          ' P.'+FWorkStation+
          ' O.'+FOffice;
   if S <> DateLabel.Caption then
      DateLabel.Caption:=S;
   if Assigned(FFormTimer) then
   begin
      SetupDLLCall;
      FFormTimer;
      ReturnFromDLLCall;
   end;
   MonitorFileChanges;
end;
procedure TI3UIForm.ExecuteOnDestroyFunc(Name:String);
var
   UIFunctionNode:TUIFunctionNode;
   OnDestroyFunc:TOnDestroyFunc;
begin
    UIFunctionNode:=TUIFunctionNode(I3UINode.NodeNamed('Function.'+Name));
    if (UIFunctionNode <> nil) and (UIFunctionNode.ExecuteType = 'OnDestroy') then
    begin
       @OnDestroyFunc:=GetDLLFuncPointer(UIFunctionNode);
       if @OnDestroyFunc <> nil then
       begin
          SetupDLLCall;
          OnDestroyFunc;
          ReturnFromDLLCall;
       end;
    end;
end;
procedure TI3UIForm.ExecuteOnCreateFunc(Name:String);
var
   UIFunctionNode:TUIFunctionNode;
   OnCreateFunc:TOnCreateFunc;
begin
    UIFunctionNode:=TUIFunctionNode(I3UINode.NodeNamed('Function.'+Name));
    if (UIFunctionNode <> nil) and (UIFunctionNode.ExecuteType = 'OnCreate') then
    begin
       @OnCreateFunc:=GetDLLFuncPointer(UIFunctionNode);
       if @OnCreateFunc <> nil then
       begin
          SetupDLLCall;
          OnCreateFunc;
          ReturnFromDLLCall;
       end;
    end;
end;
procedure TI3UIForm.AssignFormTimer(Name:String);
var
   UIFunctionNode:TUIFunctionNode;
begin
    UIFunctionNode:=TUIFunctionNode(I3UINode.NodeNamed('Function.'+Name));
    if (UIFunctionNode <> nil) and (UIFunctionNode.ExecuteType = 'Timer') then
    begin
       FFormTimer:=GetDLLFuncPointer(UIFunctionNode);
    end
    else
       FFormTimer:=nil;
end;

procedure TI3UIForm.PadBoxPaint(Sender: TObject);
const
   Emboss:TBitmap = nil;
begin
   StretchBMP(PadBox.Canvas,PadImage.Picture.Bitmap,Bounds(0,0,PadBox.Width,PadBox.Height),37);
   if (Emboss = nil) and (I3UINode.System.Emboss <> '') and (FileExists(I3UINode.System.Emboss)) then
   begin
      Emboss:=TBitmap.Create;
      Emboss.LoadFromFile(I3UINode.System.Emboss);
   end;
   if Emboss <> nil then
   begin
      PadBox.Canvas.Brush.Style:=bsClear;
      PadBox.Canvas.BrushCopy(Bounds((PadBox.Width-Emboss.Width)-20,(PadBox.Height-Emboss.Height)-12,Emboss.Width,Emboss.Height),Emboss,Bounds(0,0,Emboss.Width,Emboss.Height),Emboss.Canvas.Pixels[0,0]);
      PadBox.Canvas.Brush.Style:=bsSolid;
   end;
end;
procedure RemoveFrom(ParentWindow:TWinControl);
var
   I:Integer;
   ALabel:TLabel;
   AnImage:TImage;
   Control:TWinControl;
begin
   I:=0;
   while I < ParentWindow.ControlCount do
   begin
      if (ParentWindow.Controls[I] is TLabel) then
      begin
         ALabel:=ParentWindow.Controls[I] as TLabel;
         if (ALabel.Tag = 98765) then
         begin
            ParentWindow.RemoveControl(ALabel);
            ALabel.Free;
            Dec(I);
         end;
      end
      else if (ParentWindow.Controls[I] is TImage) then
      begin
         AnImage:=ParentWindow.Controls[I] as TImage;
         if (AnImage.Tag = 98765) then
         begin
            ParentWindow.RemoveControl(AnImage);
            AnImage.Free;
            Dec(I);
         end;
      end
      else if (ParentWindow.Controls[I] is TWinControl) then
      begin
         Control:=ParentWindow.Controls[I] as TWinControl;
         if (Control.Tag = 98765) then
         begin
            ParentWindow.RemoveControl(Control);
            Control.Free;
            Dec(I);
         end;
      end;
      Inc(I);
   end;
//   for I:=0 to Fields.Count-1 do
//      ParentWindow.RemoveControl(Control[I]);
end;

procedure TI3UIForm.OnEnterFunc(Sender:TObject);
var
   UIDomainNode:TUIDomainNode;
   UIFunctionNode:TUIFunctionNode;
   Res:Integer;
begin
   SetPromptHint(Sender);
   UIDomainNode:=TUIDomainNode(I3UINode.NodeNamed('Domain.'+(Sender as TWinControl).Name));
   if (UIDomainNode <> nil) and (UIDomainNode.OnEnter <> '') then
   begin
       UIFunctionNode:=TUIFunctionNode((I3UINode.NodeNamed('Function.'+UIDomainNode.OnEnter)));
       if (UIFunctionNode <> nil) and ((UIFunctionNode.ExecuteType = 'OnEnter' ) 
                                   or  (UIFunctionNode.ExecuteType = 'OnChange') 
                                   or  (UIFunctionNode.ExecuteType = 'Validate')) then
       begin
          Res:=ExecDllFunc(UIFunctionNode);
          if Res = 0 then
          begin
             if UIDomainNode.ErrorS <> '' then
                ErrorText:=UIDomainNode.ErrorS
             else
                ErrorText:=UIDomainNode.Prompt;
             TriggerError;
          end;
       end;
   end;
end;
procedure TI3UIForm.OnChangeFunc(Sender:TObject);
var
   UIDomainNode:TUIDomainNode;
   UIFunctionNode:TUIFunctionNode;
   Res:Integer;
begin
   UIDomainNode:=TUIDomainNode(I3UINode.NodeNamed('Domain.'+(Sender as TWinControl).Name));
   if (UIDomainNode <> nil) and (UIDomainNode.OnChange <> '') then
   begin
       UIFunctionNode:=TUIFunctionNode((I3UINode.NodeNamed('Function.'+UIDomainNode.OnChange)));
       if (UIFunctionNode <> nil) and ((UIFunctionNode.ExecuteType = 'OnChange') 
                                    or (UIFunctionNode.ExecuteType = 'OnEnter' ) 
                                    or (UIFunctionNode.ExecuteType = 'Validate')) then
       begin
          Res:=ExecDllFunc(UIFunctionNode);
          if Res = 0 then
          begin
             if UIDomainNode.ErrorS <> '' then
                ErrorText:=UIDomainNode.ErrorS
             else
                ErrorText:=UIDomainNode.Prompt;
             TriggerError;
          end;
       end;
   end;
end;
procedure TI3UIForm.StringGridSetEditText(Sender:TObject;ACol,ARow:Integer;const Value:String);
begin
   // setup Shared Vars
   SharedData.SetVariable('SGCurrentCol' ,ACol);
   SharedData.SetVariable('SGCurrentRow' ,ARow);
   SharedData.SetVariable('SGCurrentValue',Value);

   // Call handler (if any)
   OnChangeFunc(Sender);
   
   // set value from Handler
   if Value <> SharedData.GetVariable('SGCurrentValue') then
      (Sender as TStringGrid).Cells[ACol,ARow]:=SharedData.GetVariable('SGCurrentValue');
   
   // clean up Shared Vars
   SharedData.RemoveVariable('SGCurrentCol');
   SharedData.RemoveVariable('SGCurrentRow');
   SharedData.RemoveVariable('SGCurrentValue');
end;                                          
procedure TI3UIForm.ExitValidate(Sender:TObject);
var
   UIDomainNode:TUIDomainNode;
   UIFunctionNode:TUIFunctionNode;
   Res:Integer;
begin
   UIDomainNode:=TUIDomainNode(I3UINode.NodeNamed('Domain.'+(Sender as TWinControl).Name));
   if (UIDomainNode <> nil) and (UIDomainNode.CheckWith <> '') then
   begin
       UIFunctionNode:=TUIFunctionNode((I3UINode.NodeNamed('Function.'+UIDomainNode.CheckWith)));
       if (UIFunctionNode <> nil) and ((UIFunctionNode.ExecuteType = 'OnChange') 
                                    or (UIFunctionNode.ExecuteType = 'OnEnter' ) 
                                    or (UIFunctionNode.ExecuteType = 'Validate')) then
       begin
          Res:=ExecDllFunc(UIFunctionNode);
          if Res = 0 then
          begin
             if (Sender as TWinControl).Enabled then
                (Sender as TWinControl).SetFocus;
             if UIDomainNode.ErrorS <> '' then
                ErrorText:=UIDomainNode.ErrorS
             else
                ErrorText:=UIDomainNode.Prompt;
             TriggerError;
          end;
       end;   
   end;
end;
procedure TI3UIForm.SetPromptHint(Sender:TObject);
var
   UIDomainNode:TUIDomainNode;
begin
   CurrentControl:=(Sender as TWinControl);
   UIDomainNode:=TUIDomainNode(I3UINode.NodeNamed('Domain.'+(Sender as TWinControl).Name));
   if UIDomainNode <> nil then
   begin
      PromptLabel.Caption:=UIDomainNode.Prompt;
      HintLabel.Caption:=UIDomainNode.Hint;
      ErrorText:=UIDomainNode.ErrorS;
      if ErrorText = '' then
         ErrorText:=UIDomainNode.Prompt;
   end;
end;
procedure TI3UIForm.DrawList(Control:TWinControl;Index:Integer;Rect:TRect;State:TOwnerDrawState);
type
   TDrawItem = procedure(Control:TWinControl;Index:Integer;Rect:TRect;State:TOwnerDrawState);
var
   UIDomainNode:TUIDomainNode;
   UIFunctionNode:TUIFunctionNode;
   DrawEvent:TDrawItem;
begin
   UIDomainNode:=TUIDomainNode(I3UINode.NodeNamed('Domain.'+Control.Name));
   if (UIDomainNode <> nil) and (UIDomainNode.DrawWith <> '') then
   begin
      UIFunctionNode:=TUIFunctionNode(I3UINode.NodeNamed('Function.'+UIDomainNode.DrawWith));
      if (UIFunctionNode <> nil) and (UIFunctionNode.ExecuteType ='Draw') then
      begin
         @DrawEvent:=GetDLLFuncPointer(UIFunctionNode);
         SetupDLLCall;
         DrawEvent(Control,Index,Rect,State);
         ReturnFromDLLCall;
      end;
   end;
end;

procedure TI3UIForm.DrawCell(Sender:TObject;Col,Row:Integer;Rect:TRect;State:TGridDrawState);
var
   SG:TStringGrid;
begin
   SG:=Sender as TStringGrid;
   SG.Canvas.Font:=Font;
   with SG.Canvas do
   begin
      FillRect(Rect);
      if Col = 0 then
      begin
         Font.Color:=clNavy;
         TextOut((Rect.Right-5)-TextWidth(SG.Cells[Col,Row]),Rect.Top,SG.Cells[Col,Row]);
      end
      else
      begin
         Font.Color:=clBlack;
         TextOut(Rect.Left+5,Rect.Top,SG.Cells[Col,Row]);
      end;
   end;
   if gdFocused in State then
      SG.EditorMode:=True;
end;

procedure TI3UIForm.AttachTo(Form:TUIFormNode;Left,Top,Spacing:Integer;ParentWindow:TWinControl);
var
   K,J,I,TopOffset:Integer;
   ALabel:TLabel;
   BMPFile:String;
   AnImage:TImage;
   MW:Integer;
   SL:TStringList;
   Grid,Line:TPackStringList;
   UIDomainNode:TUIDomainNode;
   UIFunctionNode:TUIFunctionNode;
   UIListNode:TUIListNode;
   Control:TWinControl;
   FirstControl:TWinControl;
   TW,NumbCols,ColWidth,NumbLines:Integer;
begin
   if CurrentForm <> nil then
      ExecuteOnDestroyFunc(CurrentForm.OnDestroy);
   CurrentForm:=Form;

   RemoveFrom(ParentWindow);
   FirstControl:=nil;
   if Form = nil then Exit;
   MW:=0;
   SL:=TStringList.Create;
   SL.CommaText:=Form.Domains;
   TopOffset:=Top+2;
   for I:=0 to SL.Count-1 do
   begin
      UIDomainNode:=TUIDomainNode(I3UINode.NodeNamed('Domain.'+SL[I]));
      if UIDomainNode <> nil then
      begin
         if UIDomainNode.CompType = 'Bitmap' then
         begin
            if (Copy(UIDomainNode.Title,1,1) <> '\') and (Copy(UIDomainNode.Title,2,1) <> ':') then
               BMPFile:=ApplicationRootPath+UIDomainNode.Title
            else
               BMPFile:=UIDomainNode.Title;
            if FileExists(BMPFile) then
            begin
               AnImage:=TImage.Create(nil);
               AnImage.Visible:=False;
               ParentWindow.InsertControl(AnImage);
               AnImage.Left:=Left;
               AnImage.Top:=TopOffset;
               AnImage.Picture.Bitmap.LoadFromFile(BMPFile);
               Inc(TopOffset,AnImage.Height);
               AnImage.AutoSize:=True;
               AnImage.Tag:=98765;
               AnImage.Visible:=True;
               if AnImage.Width > MW then MW:=AnImage.Width;
            end;              
         end
         else if UpperCase(Copy(UIDomainNode.CompType,1,4)) = 'GRID'  then
         begin
            Grid:=TPackStringList.Create;
            Line:=TPackStringList.Create;
            Grid.CommaText:=UIDomainNode.DefaultValue;
            for J:=0 to Grid.Count-1 do                 
            begin
               Line.CommaText:=Grid[J];
               if (Line.Count > 0) then
               begin
                  if Line[0][Length(Line[0])] <> ':' then
                     Line[0]:=Line[0]+':';
                  if Canvas.TextWidth(Line[0]) > MW then
                  MW:=Canvas.TextWidth(Line[0]);
               end;
            end;
            Line.Free;
            Grid.Free;
         end
         else
         begin
            ALabel:=TLabel.Create(nil);
            ALabel.Visible:=False;
            ParentWindow.InsertControl(ALabel);
            ALabel.Left:=Left;
            ALabel.Top:=TopOffset;
            Inc(TopOffset,Spacing);
            ALabel.AutoSize:=True;
            if Copy(UIDomainNode.Title,Length(UIDomainNode.Title),1) <> ':' then
               ALabel.Caption:=UIDomainNode.Title+':'
            else
               ALabel.Caption:=UIDomainNode.Title;
            ALabel.Transparent:=True;
            ALabel.ParentFont:=True;
            ALabel.Font.Color:=clNavy;
            ALabel.Tag:=98765;
            ALabel.Visible:=True;
            if ALabel.Width > MW then MW:=ALabel.Width;
         end;
      end;
   end;  
   for I:=0 to ParentWindow.ControlCount-1 do
   begin
      if (ParentWindow.Controls[I] is TLabel) then
      begin
         ALabel:=ParentWindow.Controls[I] as TLabel;
         if (ALabel.Tag = 98765) then
            ALabel.Left:=(Left+MW)-ALabel.Width;
      end
      else if (ParentWindow.Controls[I] is TImage) then
      begin
         AnImage:=ParentWindow.Controls[I] as TImage;
         if (AnImage.Tag = 98765) then
            AnImage.Left:=(Left+MW)-AnImage.Width;
      end;
   end;
   Control:=nil;
   TopOffset:=Top+2;
   for I:=0 to SL.Count-1 do
   begin
      UIDomainNode:=TUIDomainNode(I3UINode.NodeNamed('Domain.'+SL[I]));
      if UIDomainNode <> nil then
      begin
         if UIDomainNode.CompType = 'Text' then
         begin
            Control:=TEdit.Create(nil); 
            Control.Visible:=False;
            Control.Name:=UIDomainNode.Name;
            ParentWindow.InsertControl(Control);
            Control.Left:=Left+MW+10;
            Control.Tag:=98765;
            (Control as TEdit).OnExit  :=ExitValidate;
            (Control as TEdit).OnChange:=OnChangeFunc;
            (Control as TEdit).OnEnter :=OnEnterFunc;
            if UIDomainNode.IsReadOnly then Control.Enabled:=False;
            
            (Control as TEdit).BorderStyle:=bsNone;
            (Control as TEdit).Text:=UIDomainNode.DefaultValue;
            Control.Width:=670-MW;
            Control.Height:=Spacing-1;
            Control.Top:=TopOffset; Inc(TopOffset,Spacing);
            Control.Visible:=True;
         end
         else if UpperCase(Copy(UIDomainNode.CompType,1,4)) = 'GRID'  then
         begin
            NumbLines:=StrToIntDef(Copy(UIDomainNode.CompType,5,Length(UIDomainNode.CompType)),5);
            Control:=TStringGrid.Create(nil);
            Control.Visible:=False;
            Control.Name:=UIDomainNode.Name;
            ParentWindow.InsertControl(Control);
            Control.Left:=Left;
            Control.Tag:=98765;
            (Control as TStringGrid).OnExit  :=ExitValidate;
            (Control as TStringGrid).OnSetEditText:=StringGridSetEditText;
            (Control as TStringGrid).OnEnter :=OnEnterFunc;
            if UIDomainNode.IsReadOnly then Control.Enabled:=False;
            (Control as TStringGrid).DefaultRowHeight:=Spacing-1;
            (Control as TStringGrid).BorderStyle:=bsNone;
            (Control as TStringGrid).DefaultDrawing:=False;
            (Control as TStringGrid).OnDrawCell:=DrawCell;
            (Control as TStringGrid).ParentFont:=True;
            (Control as TStringGrid).Options:=[goFixedHorzLine,goVertLine,goHorzLine, 
                                               goRangeSelect,goDrawFocusSelected,  
                                               goThumbTracking];
            (Control as TStringGrid).EditorMode:=True;
            Grid:=TPackStringList.Create;
            Grid.CommaText:=UIDomainNode.DefaultValue;
            (Control as TStringGrid).RowCount:=Grid.Count;
            NumbCols:=2;
            (Control as TStringGrid).ColCount:=NumbCols;
            for J:=0 to Grid.Count-1 do                 
            begin
               (Control as TStringGrid).Rows[J].CommaText:=Grid[J];
               if  ((Control as TStringGrid).Rows[J].Count > NumbCols) then
                  NumbCols:=(Control as TStringGrid).Rows[J].Count;
               if (J = 0) then
               begin
//                  if ((Control as TStringGrid).Cols[J].Count > 1) then
//                     (Control as TStringGrid).FixedRows:=1
//                  else
                     (Control as TStringGrid).FixedRows:=0;
               end;
            end;
            (Control as TStringGrid).ColWidths[0]:=MW+5;
            (Control as TStringGrid).ColCount:=NumbCols;
            for K:=0 to Grid.Count-1 do
            begin
               if (Control as TStringGrid).Cells[0,K][Length((Control as TStringGrid).Cells[0,K])] <> ':' then
                  (Control as TStringGrid).Cells[0,K]:=(Control as TStringGrid).Cells[0,K]+':';
            end;
            for J:=1 to (Control as TStringGrid).ColCount-2 do
            begin
               ColWidth:=1;
               for K:=0 to Grid.Count-1 do
               begin
                  TW:=Canvas.TextWidth((Control as TStringGrid).Cells[J,K]);
                  if TW > ColWidth then
                     ColWidth:=TW+2;
               end;
               (Control as TStringGrid).ColWidths[J]:=ColWidth;
            end; 
            TW:=0;
            for J:=1 to (Control as TStringGrid).ColCount-2 do
               Inc(TW,(Control as TStringGrid).ColWidths[J]);
            ColWidth:=680-TW;
            (Control as TStringGrid).ColWidths[(Control as TStringGrid).ColCount-1]:=ColWidth;
            
            if not UIDomainNode.IsReadOnly then 
               (Control as TStringGrid).Options:=(Control as TStringGrid).Options+[goEditing,goAlwaysShowEditor];
            
            Grid.Free;             
            
            Control.Width:=680;
            Control.Height:=(Spacing*NumbLines)-1;
            Control.Top:=TopOffset; Inc(TopOffset,Spacing*NumbLines);
            Control.Visible:=True;
         end
         else if UpperCase(Copy(UIDomainNode.CompType,1,4)) = 'MEMO'  then
         begin
            NumbLines:=StrToIntDef(Copy(UIDomainNode.CompType,5,Length(UIDomainNode.CompType)),5);
            Control:=TMemo.Create(nil);
            Control.Visible:=False;
            Control.Name:=UIDomainNode.Name;
            ParentWindow.InsertControl(Control);
            Control.Left:=Left+MW+10;
            Control.Tag:=98765;
            (Control as TMemo).OnExit  :=ExitValidate;
            (Control as TMemo).OnChange:=OnChangeFunc;
            (Control as TMemo).OnEnter :=OnEnterFunc;
            if UIDomainNode.IsReadOnly then Control.Enabled:=False;

            (Control as TMemo).Text:=UIDomainNode.DefaultValue;
            Control.Width:=670-MW;
            Control.Height:=(Spacing*NumbLines)-1;
            Control.Top:=TopOffset; Inc(TopOffset,Spacing*NumbLines);
            Control.Visible:=True;
         end
         else if (UIDomainNode.CompType = 'PickList'        )
              or (UIDomainNode.CompType = 'UnSortedPickList') then
         begin
            Control:=TComboBox.Create(nil);
            Control.Visible:=False;
            Control.Name:=UIDomainNode.Name;
            ParentWindow.InsertControl(Control);
            Control.Left:=Left+MW+10;
            Control.Tag:=98765;

            if UIDomainNode.IsReadOnly then Control.Enabled:=False;

            (Control as TComboBox).OnExit :=ExitValidate;
            (Control as TComboBox).OnChange:=OnChangeFunc;
            (Control as TComboBox).OnEnter :=OnEnterFunc;
            (Control as TComboBox).ItemHeight:=Spacing-4;
            (Control as TComboBox).Style:=csOwnerDrawFixed;

            (Control as TComboBox).Items.Text:=UIDomainNode.DefaultValue;

            if (UIDomainNode.ListName <> '') then
            begin
               if (UIDomainNode.ListName = 'ReportReprintList') then
               begin
                  PopulateReprintList((Control as TComboBox).Items);
                  (Control as TComboBox).Text:=(Control as TComboBox).Items[(Control as TComboBox).Items.Count-1];
                  (Control as TComboBox).ItemIndex:=(Control as TComboBox).Items.Count-1;
               end
               else if (I3UINode.NodeNamed('List.'+UIDomainNode.ListName) <> nil) then
               begin
                  UIListNode:=TUIListNode(I3UINode.NodeNamed('List.'+UIDomainNode.ListName));
                  K:=TCorvusNode(UIListNode.Objects[0]).IndexOf('Office Name');
                  if K < 0 then K:=0;
                  for J:=1 to UIListNode.Count-1 do
                  begin
                     if (UIListNode.Objects[J] <> nil) and (TCorvusNode(UIListNode.Objects[J]).Count > K) then
                        (Control as TComboBox).Items.Add(TCorvusNode(UIListNode.Objects[J])[K]);
                  end;
               end;
            end;
            if UIDomainNode.CompType = 'PickList' then
               (Control as TComboBox).Sorted:=True
            else
               (Control as TComboBox).Sorted:=False;
            (Control as TComboBox).ItemIndex:=(Control as TComboBox).Items.IndexOf((Control as TComboBox).Items.Text);

            Control.Width:=670-MW;
            Control.Height:=Spacing-3;
            Control.Top:=TopOffset; Inc(TopOffset,Spacing);
            Control.Visible:=True;
         end
         else if (UIDomainNode.CompType = 'DateTime'       )
              or (UIDomainNode.CompType = 'DateTimePreNow' )
              or (UIDomainNode.CompType = 'DateTimePostNow') then
         begin
            Control:=TDateTimePicker.Create(nil);
            Control.Visible:=False;
            Control.Name:=UIDomainNode.Name;
            ParentWindow.InsertControl(Control);
            Control.Left:=Left+MW+10;
            Control.Tag:=98765;
            if UIDomainNode.IsReadOnly then Control.Enabled:=False;

            (Control as TDateTimePicker).OnExit :=ExitValidate;
            (Control as TDateTimePicker).OnChange:=OnChangeFunc;
            (Control as TDateTimePicker).OnEnter :=OnEnterFunc;
            (Control as TDateTimePicker).Date:=now;
            if UIDomainNode.CompType = 'DateTimePreNow' then
               (Control as TDateTimePicker).MaxDate:=Now;
            if UIDomainNode.CompType = 'DateTimePostNow' then
               (Control as TDateTimePicker).MinDate:=Now-1;
            Control.Width:=670-MW;
            Control.Height:=Spacing+1;
            Control.Top:=TopOffset; Inc(TopOffset,Spacing);
            Control.Visible:=True;
         end
         else if UpperCase(Copy(UIDomainNode.CompType,1,4)) = 'LIST'  then
         begin
            NumbLines:=StrToIntDef(Copy(UIDomainNode.CompType,5,Length(UIDomainNode.CompType)),5);
            Control:=TListBox.Create(nil);
            Control.Visible:=False;
            Control.Name:=UIDomainNode.Name;
            ParentWindow.InsertControl(Control);
            Control.Left:=Left+MW+10;
            Control.Tag:=98765;
            if UIDomainNode.IsReadOnly then Control.Enabled:=False;

            (Control as TListBox).OnExit :=ExitValidate;
            (Control as TListBox).OnClick:=OnChangeFunc;
            (Control as TListBox).OnEnter :=OnEnterFunc;
            (Control as TListBox).ItemHeight:=Spacing-2;

            UIFunctionNode:=TUIFunctionNode(I3UINode.NodeNamed('Function.'+UIDomainNode.DrawWith));
            if (UIFunctionNode <> nil) and (UIFunctionNode.ExecuteType ='Draw') then
            begin
               (Control as TListBox).OnDrawItem:=DrawList;
               (Control as TListBox).Style:=lbOwnerDrawFixed;
            end;
            Control.Left:=Left;
            Control.Width:=680;
            Control.Height:=Spacing*NumbLines;
            Control.Top:=TopOffset; Inc(TopOffset,Spacing);
            Control.Visible:=True;
         end
         else if UIDomainNode.CompType = 'Bitmap' then
         begin
            Inc(TopOffset,50);
         end
         else
            ShowMessage('Domain '+UIDomainNode.Name+' - Unknown Type'); //Control.Top:=TopOffset; Inc(TopOffset,Spacing);
      end;
      if (FirstControl = nil) and (Control <> nil) and (Control.Enabled) then
         FirstControl:=Control;
   end;
   if FirstControl <> nil then 
   begin
      FirstControl.SetFocus;
   end;
   SL.Free;
end;
function TI3UIForm.GetDLLFuncPointerByName(DLL,Func:String):Pointer;
type
   TUIDLLStartup = procedure(var SystemName:String;CallBackFunction:TCallBack);
var
   DLLIdx:Integer;
   FuncIdx:Integer;
   DLLHandle:THandle;
   UIDLLStartup:TUIDLLStartup;
   SystemName:String;
begin
   Result:=nil;
   
   DLLIdx:=DLLList.IndexOf(DLL);
   if DLLIdx = -1 then
   begin
      try
         DLLHandle:=LoadLibrary(PChar(DLL));
         if DLLHandle <> 0 then
         begin
            DLLIdx:=DLLList.AddObject(DLL,TObject(DLLHandle));
            @UIDLLStartup:=GetProcAddress(DLLHandle,'UIDLLStartup');
            if @UIDLLStartup <> nil then 
               UIDLLStartup(SystemName,CallBackFunction);
         end;
      except
      end;
   end;
   if DLLIdx <> -1 then
   begin
      DLLHandle:=THandle(DLLList.Objects[DLLIdx]);
      FuncIdx:=FuncList.IndexOf(DLL+'.'+Func);
      if FuncIdx = -1 then
      begin
         try
            Result:=GetProcAddress(DLLHandle,PChar(Func));
            if Result <> nil then
               FuncList.AddObject(DLL+'.'+Func,TObject(Result));
         except
         end;
      end
      else
         Result:=FuncList.Objects[FuncIdx];
   end;
end;
function TI3UIForm.GetDLLFuncPointer(UIFunctionNode:TUIFunctionNode):Pointer;
begin
   Result:=nil;
   if UIFunctionNode = nil then Exit;
   Result:=GetDLLFuncPointerByName(UIFunctionNode.DLL,UIFunctionNode.Func);
end;
function TI3UIForm.ExecRepFootHeadCallBackDllFunc(CallBackName,ReportName:String;PrintRect:TRect;Canvas:TCanvas;PageNo,NoPages:Integer):String;
type
   TRepFootCallBack = procedure(ReportName:String;PrintRect:TRect;Canvas:TCanvas;PageNo,NoPages:Integer);
const
   LastError:String = '';
var      
   TheDLLFunction:TRepFootCallBack;
   DLLName :String;
   FuncName:String;
begin
   if Pos('.',CallBackName) = 0 then Exit;
   
   DLLName :=Copy(CallBackName,1,Pos('.',CallBackName)-1);
   FuncName:=Copy(CallBackName,Pos('.',CallBackName)+1,Length(CallBackName));
   
   @TheDLLFunction:=GetDLLFuncPointerByName(DLLName,FuncName);
    
   if @TheDLLFunction <> nil then
   begin
      TheDLLFunction(ReportName,PrintRect,Canvas,PageNo,NoPages);
   end
   else if LastError <> 'Report Footer Callback function '+DLLName+'.'+FuncName+' does not exist' then
   begin
      LastError:='Report Footer Callback function '+DLLName+'.'+FuncName+' does not exist';
      ShowMessage(LastError);
   end;
end;
function TI3UIForm.ExecRepCallBackDllFunc(CallBackName,ColumnName,ReportName,Value:String):String;
type
   TDLLRepCallBack = function(ColumnName,ReportName,Value:String):String;
const
   LastError:String = '';
var      
   TheDLLFunction:TDLLRepCallBack;
   DLLName :String;
   FuncName:String;
begin
   Result:=Value;
   if Pos('.',CallBackName) = 0 then Exit;
   
   DLLName :=Copy(CallBackName,1,Pos('.',CallBackName)-1);
   FuncName:=Copy(CallBackName,Pos('.',CallBackName)+1,Length(CallBackName));
   
   @TheDLLFunction:=GetDLLFuncPointerByName(DLLName,FuncName);
    
   if @TheDLLFunction <> nil then
   begin
      Result:=TheDLLFunction(ColumnName,ReportName,Value);
   end
   else if LastError <> 'Report Callback function '+DLLName+'.'+FuncName+' does not exist' then
   begin
      LastError:='Report Callback function '+DLLName+'.'+FuncName+' does not exist';
      ShowMessage(LastError);
   end;
end;
function TI3UIForm.ExecDllFunc(UIFunctionNode:TUIFunctionNode):Integer;
type
   TDLLFunction = function:Integer;
   TDLLValidate = function(Control:TWinControl):Boolean;
var      
   TheDLLFunction:TDLLFunction;
   TheDLLValidate:TDLLValidate;
begin
   Result:=-1;
   if UIFunctionNode = nil then Exit;

   @TheDLLFunction:=GetDLLFuncPointer(UIFunctionNode);
    
   if @TheDLLFunction <> nil then
   begin
      SetupDLLCall;
      if (UIFunctionNode.ExecuteType = 'Validate')
      or (UIFunctionNode.ExecuteType = 'OnChange')
      or (UIFunctionNode.ExecuteType = 'OnEnter' ) then
      begin
         if CurrentControl <> nil then
         begin
            @TheDLLValidate:=@TheDLLFunction;
            if TheDLLValidate(CurrentControl) then
               Result:=1
            else
               Result:=0;
         end;
      end
      else                        
      begin
         Result:=TheDLLFunction; // execute it!
      end;
      ReturnFromDLLCall;
   end
   else
      ShowMessage(UIFunctionNode.DLL+'.'+UIFunctionNode.Func+' does not exist');
end;
function TI3UIForm.ExecuteFunction(Name:String):Integer;
var
   UIFunctionNode:TUIFunctionNode;
begin
   if Copy(Name,1,9) <> 'Function.' then
      Name:='Function.'+Name;
   UIFunctionNode:=TUIFunctionNode(I3UINode.NodeNamed(Name));
   Result:=ExecDllFunc(UIFunctionNode);
   if (Result = 1) then PopItem;
end;
procedure BCOnCanvas(Series:String;Canvas:TCanvas;BR:TRect);
var
   S,BarData:String;
   Len,Magnification,I:Integer;
begin
   BarData:=MOSeriesToCode128(Series);
   S:=STARTBARA;
   for I:=0 to (Length(BarData) div 2)-1 do
      S:=S+Char(StrToInt(Copy(BarData,I*2+1,2)));
   S:=S+Calc128CRC(S);
   S:=S+STOPBARCODE;
   BarData:='';
   for I:=1 to Length(S) do BarData:=BarData+BCData[Integer(S[I]),3];
   Len:=0;
   for I:=1 to Length(BarData) do Inc(Len,(Integer(BarData[I])-48));
   Magnification:=(BR.Right-BR.Left) div Len;
   BR.Left:=BR.Left+((BR.Right-BR.Left)-(Magnification*Len)) div 2;
   BR.Right:=BR.Left+Magnification*Len;
   EncStringCanvasPixels(Canvas,BR,BarData,Magnification);
end;
procedure RepFootCallBack(CallBackName,ReportName:String;PrintRect:TRect;Canvas:TCanvas;PageNo,NoPages:Integer);
var
   S:String;
   CP,FS,TW:Integer;
   YOfs :Integer;
begin
   if Pos('.',CallbackName) <> 0 then
   begin
      I3UIForm.ExecRepFootHeadCallBackDllFunc(CallBackName,ReportName,PrintRect,Canvas,PageNo,NoPages);
      Exit;
   end;
   if CallBackName = 'TransferAckFoot' then
   begin
      with Canvas do
      begin
         FS:=Font.Size;
         Font.Size:=FS div 2;
         CP:=PrintRect.Left+(PrintRect.Right-PrintRect.Left) div 2;
         YOfs:=PrintRect.Top;
         Inc(YOfs,TextHeight('Wg'));
         
         S:='Despatching Supervisor / Postmaster';
         TW:=TextWidth(S);
         TextOut(PrintRect.Left+(CP-TW) div 2,YOfs,S);
         Inc(YOfs,TextHeight('Wg'));
         PolyLine([Point(PrintRect.Left+(CP-TW) div 2,YOfs),Point(PrintRect.Left+(CP-TW) div 2+TW,YOfs)]);
         Dec(YOfs,TextHeight('Wg'));
                                  
         S:='Receiving Supervisor / Postmaster';
         TW:=TextWidth(S);
         TextOut(CP+(CP-TW) div 2,YOfs,S);
         Inc(YOfs,TextHeight('Wg'));
         PolyLine([Point(CP+(CP-TW) div 2,YOfs),Point(CP+(CP-TW) div 2+TW,YOfs)]);
         Inc(YOfs,TextHeight('Wg')*2);
         
         TextOut(PrintRect.Left+500,YOfs,'Name');         
         TextOut(PrintRect.Left+CP div 2+1500,YOfs,'PF');
         TextOut(CP            +500,YOfs,'Name');
         TextOut(CP            +CP div 2+1500,YOfs,'PF');
         Inc(YOfs,TextHeight('Wg'));
         PolyLine([Point(PrintRect.Left+500,YOfs),Point(CP-500,YOfs)]);
         PolyLine([Point(CP+500,YOfs),Point(PrintRect.Right-500,YOfs)]);
         Inc(YOfs,TextHeight('Wg')*2);

         TextOut(PrintRect.Left+500,YOfs,'Signature');
         TextOut(PrintRect.Left+CP div 2+500,YOfs,'Date');
         TextOut(CP            +500,YOfs,'Signature');
         TextOut(CP            +CP div 2+500,YOfs,'Date');
         Inc(YOfs,TextHeight('Wg'));
         PolyLine([Point(PrintRect.Left+500,YOfs),Point(CP-500,YOfs)]);
         PolyLine([Point(CP+500,YOfs),Point(PrintRect.Right-500,YOfs)]);
         Inc(YOfs,TextHeight('Wg')*3);
         
         TextOut  (PrintRect.Left+500 ,YOfs,'Office Date Stamp');
         Rectangle(PrintRect.Left+1000+TextWidth('Office Date Stamp'),(YOfs-TextHeight('Wg')*2)+TextHeight('Wg') div 2,
                   PrintRect.Left+2300+TextWidth('Office Date Stamp'),(YOfs+TextHeight('Wg')*2)+TextHeight('Wg') div 2);

         TextOut  (CP+5000,YOfs,'Office Date Stamp');
         Rectangle(CP+5500+TextWidth('Office Date Stamp'),(YOfs-TextHeight('Wg')*2)+TextHeight('Wg') div 2,
                   CP+6800+TextWidth('Office Date Stamp'),(YOfs+TextHeight('Wg')*2)+TextHeight('Wg') div 2);

         Font.Size:=FS;
         Dec(YOfs,TextHeight('Wg'));
         S:='Page '+IntToStr(PageNo)+' of '+IntToStr(NoPages);
         TextOut(CP-TextWidth(S) div 2,YOfs,S);
         Inc(YOfs,TextHeight('Wg'));
         S:=SharedData.GetVariable('TransferAckSeries');
         TextOut(CP-TextWidth(S) div 2,YOfs,S);
         Font.Size:=FS;
      end;
   end
   else if CallBackName = 'MFJournalFoot' then
   begin
      with Canvas do
      begin
         FS:=Font.Size;
         Font.Size:=(FS *2) div 3;
         CP:=PrintRect.Left+(PrintRect.Right-PrintRect.Left) div 2;
         YOfs:=PrintRect.Top;
         Inc(YOfs,TextHeight('Wg')*2);

         S:='Sheet No.';
         TextOut(PrintRect.Left,YOfs,S);
         S:='Name of Supervisor';
         TextOut(CP,YOfs,S);
         Inc(YOfs,TextHeight('Wg'));
         PolyLine([Point(PrintRect.Left,YOfs),Point(PrintRect.Right,YOfs)]);
         Inc(YOfs,TextHeight('Wg'));

         S:='Date: '+DateToStr(Now);
         TextOut(PrintRect.Left,YOfs,S);
         Inc(YOfs,TextHeight('Wg'));
         S:='Prepared by: ';
         TextOut(PrintRect.Left,YOfs,S);
         S:='Signature';
         TextOut(CP,YOfs,S);
         Inc(YOfs,TextHeight('Wg'));
         PolyLine([Point(PrintRect.Left,YOfs),Point(PrintRect.Right,YOfs)]);
         Inc(YOfs,TextHeight('Wg')*2);

         S:='ZPM: ';
         TextOut(PrintRect.Left,YOfs,S);
         S:='PPO:';
         TextOut(CP,YOfs,S);
         Inc(YOfs,TextHeight('Wg'));
         PolyLine([Point(PrintRect.Left,YOfs),Point(PrintRect.Right,YOfs)]);
         Inc(YOfs,TextHeight('Wg'));
         S:='This Journal has to be sent daily to EMS headquarters';
         TextOut(PrintRect.Left,YOfs,S);
         Font.Size:=FS;
      end;
   end;
end;
procedure RepHeadCallBack(CallBackName,ReportName:String;PrintRect:TRect;Canvas:TCanvas;PageNo,NoPages:Integer);
var
   FS:Integer;
   YOfs:Integer;
   S:String;
   BMP:TBitmap;
begin
   if Pos('.',CallbackName) <> 0 then
   begin
      I3UIForm.ExecRepFootHeadCallBackDllFunc(CallBackName,ReportName,PrintRect,Canvas,PageNo,NoPages);
      Exit;
   end;
   if CallBackName = 'TransferAckHead' then
   begin
      Canvas.Pen.Color:=$00808080;
      FS:=Canvas.Font.Size;
      YOfs:=PrintRect.Top;
      S:='AC300';
      Canvas.TextOut(PrintRect.Right-Canvas.TextWidth(S),YOfs,S);
      if I3UIForm.ReportsNode.Logo <> nil then
      begin
         Canvas.CopyRect(Bounds(PrintRect.Left,PrintRect.Top,I3UIForm.ReportsNode.Logo.Width*10,I3UIForm.ReportsNode.Logo.Height*10),I3UIForm.ReportsNode.Logo.Canvas,Bounds(0,0,I3UIForm.ReportsNode.Logo.Width,I3UIForm.ReportsNode.Logo.Height));
      end;
      S:=SharedData.GetVariable('TransferAckSeries');
      BCOnCanvas(S,Canvas,Bounds(PrintRect.Left+((PrintRect.Right-PrintRect.Left)-6000) div 2,YOfs,6000,700)); // (60mm x 7mm)

      Inc(YOfs,700);

      Canvas.Font.Size:=(FS*3) div 2;
      S:='TANZANIA POSTS CORPORATION';
      Canvas.TextOut(PrintRect.Left+((PrintRect.Right-PrintRect.Left)-Canvas.TextWidth(S)) div 2,YOfs,S);
      Inc(YOfs,Canvas.TextHeight('Wg'));

      Canvas.Font.Size:=FS;
      Dec(YOfs,Canvas.TextHeight('Wg'));
      S:='ORIGINAL';
      Canvas.TextOut(PrintRect.Right-Canvas.TextWidth(S),YOfs,S);
      Inc(YOfs,Canvas.TextHeight('Wg'));

      Canvas.Font.Size:=(FS*2) div 3;
      S:='TRANSFER AND ACKNOWLEDGEMENT FORM FOR EXPRESS MONEY ORDER ADVICE';
      Canvas.TextOut(PrintRect.Left+((PrintRect.Right-PrintRect.Left)-Canvas.TextWidth(S)) div 2,YOfs,S);
      Inc(YOfs,Canvas.TextHeight('Wg'));
//      S:='FOR EXPRESS MONEY ORDER ADVICE';
//      Canvas.TextOut(PrintRect.Left+((PrintRect.Right-PrintRect.Left)-Canvas.TextWidth(S)) div 2,YOfs,S);
//      Inc(YOfs,Canvas.TextHeight('Wg'));
      Canvas.Font.Size:=FS;
      S:=SharedData.GetVariable('TransferAckNo');
      S:='No. '+LeftPad(IntToStr(StrToIntDef(S,0)),6,'0');
      Canvas.TextOut(PrintRect.Right-Canvas.TextWidth(S),YOfs,S);
      
      S:=SharedData.GetVariable('TransferAckSeries');
      Canvas.TextOut(PrintRect.Left+((PrintRect.Right-PrintRect.Left)-Canvas.TextWidth(S)) div 2,YOfs,S);
      Inc(YOfs,Canvas.TextHeight('Wg'));
             
      Canvas.TextOut(PrintRect.Left,YOfs,'From: '+
                     SharedData.GetVariable('FromOffice')+'    (Dispatching Office)');
      S:='Page: '+IntToStr(PageNo)+' of '+IntToStr(NoPages);
      Canvas.TextOut(PrintRect.Right-Canvas.TextWidth(S),YOfs,S);
      
      Inc(YOfs,Canvas.TextHeight('Wg'));
      Canvas.TextOut(PrintRect.Left,YOfs,'To:');
      Canvas.TextOut(PrintRect.Left+Canvas.TextWidth('From: '),YOfs,
                     SharedData.GetVariable('ToOffice')+'    (Receiving Office)');
                     
      S:='Date: '+DateToStr(Now);
      Canvas.TextOut(PrintRect.Right-Canvas.TextWidth(S),YOfs,S);
   end
   else if (CallBackName = 'MFJournalHead') or (CallBackName = 'MFJournalHeadG2K') then
   begin
//      Canvas.Pen.Color:=$00808080;
      FS:=Canvas.Font.Size;
      YOfs:=PrintRect.Top;
      if I3UIForm.ReportsNode.Logo <> nil then
      begin
         Canvas.CopyRect(Bounds(PrintRect.Left,PrintRect.Top,I3UIForm.ReportsNode.Logo.Width*10,I3UIForm.ReportsNode.Logo.Height*10),I3UIForm.ReportsNode.Logo.Canvas,Bounds(0,0,I3UIForm.ReportsNode.Logo.Width,I3UIForm.ReportsNode.Logo.Height));
      end;

         S:='Page: '+IntToStr(PageNo)+' of '+IntToStr(NoPages);
      if FileExists('C:\Tan\EMS.bmp') then
      begin
         BMP:=TBitmap.Create;
         BMP.LoadFromFile('C:\Tan\EMS.bmp');
         Canvas.CopyRect(Bounds(PrintRect.Right-BMP.Width*4,YOfs,BMP.Width*4,BMP.Height*4),BMP.Canvas,Bounds(0,0,BMP.Width,BMP.Height));
         BMP.Free;
         Inc(YOfs,Canvas.TextHeight('Wg'));
         Canvas.TextOut(PrintRect.Right-Canvas.TextWidth(S),YOfs,S);
         Dec(YOfs,Canvas.TextHeight('Wg'));
      end
      else
      begin
         Canvas.TextOut(PrintRect.Right-Canvas.TextWidth(S),YOfs,S);
      end;

      Canvas.Font.Size:=(FS*3) div 2;
      S:='EMS MONEY FAX';
      Canvas.TextOut(PrintRect.Left+((PrintRect.Right-PrintRect.Left)-Canvas.TextWidth(S)) div 2,YOfs,S);
      Inc(YOfs,Canvas.TextHeight('Wg'));
      Canvas.Font.Size:=FS;

      S:='TANZANIA POSTS CORPORATION';
      Canvas.TextOut(PrintRect.Left+((PrintRect.Right-PrintRect.Left)-Canvas.TextWidth(S)) div 2,YOfs,S);
      Inc(YOfs,Canvas.TextHeight('Wg'));
      Canvas.Font.Style:=[];
      S:='MONEYFAX RECEIVED JOURNAL';
      Canvas.TextOut(PrintRect.Left+((PrintRect.Right-PrintRect.Left)-Canvas.TextWidth(S)) div 2,YOfs,S);
      Canvas.Font.Style:=[fsBold];
      if (CallBackName = 'MFJournalHeadG2K') then
      begin
         Inc(YOfs,Canvas.TextHeight('Wg'));
         S:='TO BE AUTHORISED BY HEAD OFFICE';
         Canvas.TextOut(PrintRect.Left+((PrintRect.Right-PrintRect.Left)-Canvas.TextWidth(S)) div 2,YOfs,S);
      end;
      If not VarIsEmpty(SharedData.GetVariable('Reprint'))
      and (SharedData.GetVariable('Reprint') = True) then
      begin;
        Inc(YOfs,Canvas.TextHeight('Wg'));
        S:='JOURNAL REPRINT';
        Canvas.TextOut(PrintRect.Left+((PrintRect.Right-PrintRect.Left)-Canvas.TextWidth(S)) div 2,YOfs,S);
      end;

   end;
end;
function RepCallBack(CallBackName,ColumnName,ReportName,Value:String):String;
var
   OC,I:Integer;
   SL:TPackStringList;
   LSL:TPackStringList;
   SerialNo:String;
   V,TV:Currency;
   IO,PO,C:Integer;
   MT:TMOType;
   ID:TDateTime;
   Person:TPerson;
   MODetail:TMODetail;
begin
   Result:=Value;
   if Pos('.',CallBackName) <> 0 then
   begin
      Result:=I3UIForm.ExecRepCallBackDllFunc(CallBackName,ColumnName,ReportName,Value);
      Exit;
   end;
   if CallBackName = 'OfficeCodeAsName' then
   begin
      Result:=LeftPad(Value,4,'0');
      OC:=StrToIntDef(Value,0);
      if OC <> 0 then
      begin
         for I:=0 to I3UIForm.I3UINode.OfficeNode.Count-1 do
         begin
            if I3UIForm.I3UINode.OfficeNode.Office[I].Code = OC then
            begin
               Result:=I3UIForm.I3UINode.OfficeNode.Office[I].Name;
               Exit;
            end;
         end;
      end;
   end
   else if CallBackName = 'NameFromSeries' then
   begin
      Result:='';
      MODetail:=TMODetail.Create;
      MODetail.LoadFromTable(Value,'PSL');
      if (MODetail.Recipient <> nil) and (MODetail.Recipient.Name <> nil) then
      begin
         with MODetail.Recipient.Name do
         if Trim(Others) <> '' then
            Result:=Trim(Trim(Given)+' '+Trim(Others)+' '+Trim(Family))
         else
            Result:=Trim(Trim(Given)+' '+Trim(Family));
      end;
      MODetail.Free;
   end
   else if CallBackName = 'NameFromPerson' then
   begin
      Person:=TPerson.Create;
      Person.AsString:=Value;
      with Person.Name do
         if Trim(Others) <> '' then
            Result:=Trim(Trim(Given)+' '+Trim(Others)+' '+Trim(Family))
         else
            Result:=Trim(Trim(Given)+' '+Trim(Family));
      Person.Free;
   end
   else if CallBackName = 'AddressFromPerson' then
   begin
      Person:=TPerson.Create;
      Person.AsString:=Value;
      with Person.Address do
      Result:=Trim(
              Trim(MainLine)+' '+Trim(OtherLine)+' '+
              Trim(Telephone)+' '+Trim(IntToStr(POBox)));
      Person.Free;
   end
   else if CallBackName = 'OfficeCodeAsSCode' then
   begin
      Result:=LeftPad(Value,4,'0');
      OC:=StrToIntDef(Value,0);
      if OC <> 0 then
      begin
         for I:=0 to I3UIForm.I3UINode.OfficeNode.Count-1 do
         begin
            if I3UIForm.I3UINode.OfficeNode.Office[I].Code = OC then
            begin
               Result:=I3UIForm.I3UINode.OfficeNode.Office[I].SCode;
               Exit;
            end;
         end;
      end;
   end
   else if CallBackName = 'Dispatched' then
   begin
      if Value = '0' then
        Result:='No'
      else
        Result:='Yes';
   end
   else if CallBackName = 'MoneyOrderType' then
   begin
      Result:=Value;
      case StrToInt(Value) of
          0 : Result:='ORD';
          2 : Result:='FAX';
          3 : Result:='MTL';
          6 : Result:='TXA';
          7 : Result:='JNL';
      end;
   end
   else if CallBackName = 'MoneyOrderEventType' then
   begin
      Result:=Value;
      case TMOEventType(StrToInt(Value)) of
         evIssued      : Result:='ISSUED';
         evIssueLodged : Result:='ISSUE LODGE';
         evAt          : Result:='AT';
         evPrinted     : Result:='PRINT';
         evPaid        : Result:='PAID';
         evPayLodged   : Result:='PAY LODGE';
      end;
   end
   else if CallBackName = 'MoneyOrderFeeType' then
   begin
      Result:=Value;
      case StrToInt(Value) of
         0 : Result:='COMM';
         1 : Result:='XMIT';
         2 : Result:='ADVD';
         3 : Result:='TELN';
         4 : Result:='MOBN';
         5 : Result:='FAXN';
         6 : Result:='EMAIL';
      end;
   end
   else if CallBackName = 'DispatchItemValue' then
   begin
      SL:=TPackStringList.Create;
      LSL:=TPackStringList.Create;
      SL.PackText:=Value;
      TV:=0;
      for I:=0 to SL.Count-1 do
      begin
         LSL.PackText:=SL[I];
         if LSL.Count > 0 then
         begin
            if DecodeMoneyOrder(LSL[0],SerialNo,V,IO,PO,C,MT,ID) then
               TV:=TV+V;
         end;
      end;
      Result:=CurrToStrF(TV,ffNumber,2);
      SL.Free;
      LSL.Free;
   end
   else if CallBackName = 'DispatchItemCount' then
   begin
      SL:=TPackStringList.Create;
      SL.PackText:=Value;
      Result:=IntToStr(SL.Count);
      SL.Free;
   end
   else if CallBackName = 'DispatchInfo' then
   begin
      Result:='';
      SL:=TPackStringList.Create;
      LSL:=TPackStringList.Create;
      SL.PackText:=Value;
      TV:=0;
      for I:=0 to SL.Count-1 do
      begin
         LSL.PackText:=SL[I];
         if LSL.Count > 0 then
         begin
            if DecodeMoneyOrder(LSL[0],SerialNo,V,IO,PO,C,MT,ID) then
            begin
               TV:=TV+V;
               if Result = '' then
                  Result:=LeftPad(SerialNo,7,'0')
               else
                  Result:=Result+' '+LeftPad(SerialNo,7,'0');
            end;
         end;
      end;
      Result:=IntToStr(SL.Count)+' Money Orders with a Total Value of '+CurrToStrF(TV,ffNumber,2)+' Numbers:'+#10#13+Result;
      SL.Free;
      LSL.Free;
   end
   else if CallBackName = 'SeriesAsSerialNo' then
   begin
      Result:='Value';
      if DecodeMoneyOrder(Value,SerialNo,V,IO,PO,C,MT,ID) then
         Result:=LeftPad(SerialNo,7,'0');
   end;


end;
procedure TI3UIForm.RunReport(Name:String);
var
   ReportNode : TReportNode;
   FromPeriod : Integer;
   ToPeriod   : Integer;
   FromMoment : Integer;
   ToMoment   : Integer;
const
   LastReportFound:String = '';
begin
   if ReportsNode = nil then Exit;
   ReportNode:=ReportsNode.ReportNamed(Name);
   if ReportNode <> nil then
   begin
      LastReportFound:=ReportNode.Title;
      if SharedData = nil then
         SharedData:=TSharedData.Create('CorvusReportShare',False);
      ShowEmptyReports:=True;
      UsingNewExecute:=True;
      SetupDLLCall;
      if GetFieldContents('FromDate') = '' then
      begin
         FromPeriod := 0;
         FromMoment := 0;
      end
      else
      begin
         FromPeriod := DateToPeriod(StrToDateTime(GetFieldContents('FromDate')));
         FromMoment := DateTimeToMoment(StrToDateTime(GetFieldContents('FromDate')));
      end;

      if GetFieldContents('ToDate') = '' then
      begin
         ToPeriod := 0;
         ToMoment := 0;
      end
      else
      begin
         ToPeriod := DateToPeriod(StrToDateTime(GetFieldContents('ToDate')));
         ToMoment := DateTimeToMoment(StrToDateTime(GetFieldContents('ToDate')) + 1);
      end;

      if FromPeriod = 0 then
      begin
        FromPeriod := TodayAsPeriod;
        FromMoment := DateTimeToMoment(Trunc(Now));
      end;

      if ToPeriod = 0 then
      begin
        ToPeriod := FromPeriod;
        ToMoment := DateTimeToMoment(Trunc(Now) + 1);
      end;

      SharedData.SetVariable('FromPeriod' ,FromPeriod);
      SharedData.SetVariable('ToPeriod'   ,ToPeriod);
      SharedData.SetVariable('FromMoment', FromMoment);
      SharedData.SetVariable('ToMoment',   ToMoment);
      SharedData.SetVariable('Teller'     ,FUserName);
      SharedData.SetVariable('Office'     ,FOffice);
      SharedData.SetVariable('WorkStation',0);

      if not MultiSection then
      begin
         ReportCount:=0;
         PrintPreview:=TPrintPreview.Create(nil);
         PrintPanel.Visible:=True;
         PrintPanel.BringToFront;
         PrintPanel.InsertControl(PrintPreview);
    //     PrintPreview.Paper.ShadowColor:=BottomPanel.Color;
    //     PrintPreview.Paper.ShadowSize:=5;
    //     PrintPreview.Paper.Repaint;
         PrintPreview.Repaint;
         PrintPreview.Name:='pp';
         PrintPreview.ZoomState:=zsZoomToWidth;
         PrintPreview.PrintJobTitle:=ReportNode.Title;
      end;
      if ReportCount = 0 then
      begin
         if ReportNode.Landscape then
            PrintPreview.Orientation:=poLandscape
         else
            PrintPreview.Orientation:=poPortrait;
         PrintPreview.BeginDoc;      
         SetTitleLabelCaption('Collecting Data');
      end
      else
         PrintPreview.NewPage;
         
      SetupDLLCall;
      ReportNode.ExecuteOn(FUserName,StrToInt(FOffice),0,FromPeriod,ToPeriod,False,RepCallBack,RepHeadCallBack,RepFootCallBack,PrintPreview);
      Inc(ReportCount);
      if not MultiSection then
      begin
         SetTitleLabelCaption(ReportNode.Title+' Preview');
//         TitleLabel.Caption:=ReportNode.Title;
         PreviewFunction('Preview');
      end;
   end
   else
   begin
      if Name = 'Report.MultiSectionOn' then
      begin
         MultiSection:=True;
         ReportCount:=0;
         PrintPreview:=TPrintPreview.Create(nil);
         PrintPanel.Visible:=True;
         PrintPanel.BringToFront;
         PrintPanel.InsertControl(PrintPreview);
       //  PrintPreview.Paper.ShadowColor:=BottomPanel.Color;
       //  PrintPreview.Paper.ShadowSize:=5;
       //  PrintPreview.Paper.Repaint;
         PrintPreview.Repaint;
         PrintPreview.Name:='pp';
         SetTitleLabelCaption('Colecting Data');
         PrintPreview.ZoomState:=zsZoomToWidth;
      end
      else if Name = 'Report.MultiSectionOff' then
      begin
         MultiSection:=False;
         PrintPreview.EndDoc;
         SetTitleLabelCaption(LastReportFound+' Preview');
         PreviewFunction('Preview');
      end;
   end;
end;
procedure TI3UIForm.ShowForm(Name:String);
var
   UIFormNode:TUIFormNode;
begin
   if Copy(Name,1,5) <> 'Form.' then
      Name:='Form.'+Name;

   UIFormNode:=TUIFormNode(I3UINode.NodeNamed(Name));
   AttachTo(UIFormNode,60,PadImage.Top+47,21,CentrePanel);
   SetupDLLCall;
   if UIFormNode <> nil then
   begin
      ExecuteOnCreateFunc(UIFormNode.OnCreate);
      AssignFormTimer(UIFormNode.Timer)
   end
   else
   begin
      AssignFormTimer('');
   end;
end;
procedure TI3UIForm.BarCodeFunction(Data:String);
var
   I:Integer;
   SL:TStringList;
   Control:TWinControl;
   UIDomainNode:TUIDomainNode;
   Form:TUIFormNode;
   Menu:TUIMenuNode;
   S:String;
begin
   if CurrentForm = nil then
   begin
      for I:=0 to I3UINode.Menus.count-1 do
      begin
         S:=TUIMenuNode(I3UINode.Menus.Node[I]).BarCodeFormat;
         if S <> '' then
         begin
            if CurrentItem <> 'Menu.'+TUIMenuNode(I3UINode.Menus.Node[I]).Name then
            begin
               PushItem;
               ShowMenu('Menu.'+TUIMenuNode(I3UINode.Menus.Node[I]).Name);
            end;
            break;
         end;
      end;
   end;
   Form:=CurrentForm;
   if Form <> nil then
   begin
      Menu:=TUIMenuNode(I3UINode.NodeNamed(CurrentItem));
      SL:=TStringList.Create;
      SL.CommaText:=CurrentForm.Domains;
      for I:=0 to SL.Count-1 do
      begin
         UIDomainNode:=TUIDomainNode(I3UINode.NodeNamed('Domain.'+SL[I]));
         if UIDomainNode <> nil then
         begin
            if UIDomainNode.BarCodeFormat <> '' then
            begin
               Control:=GetDomainControl(CentrePanel,UIDomainNode.Name);
               if Control <> nil then
               begin
                  if (GetControlValue(Control) <> '') 
                  and (Menu <> nil )
                  and (Menu.AutoCompletWith <> '')
                  then
                     Exec(Menu.AutoCompletWith,False);
                     
                  SetControlValue(Control,Data);
                  if Control.Enabled then
                  begin
                     Control.SetFocus;
                     ExitValidate(Control);
                  end;
               end;
            end;
         end;
      end;
   end;
end;
procedure TI3UIForm.ShowMenu(Name:String);
var
   ItemsNode:TCorvusNode;
   I:Integer;
   Button:TKGButton;
   UIMenuNode:TUIMenuNode;
begin
   if Name = 'Print Preview' then
   begin
      PushItem;
      HintLabel  .Caption:='Preview the report using [Next], [Previous], [Top] && [Bottom]. Select [Print] or [Cancel] when complete';
      Func1Button.Caption:='Top of Page';    Func1Button.Visible:=True; Func1Button.ButtonIsUp:=True; Func1Button.Refresh;
      Func2Button.Caption:='Bottom of Page'; Func2Button.Visible:=True; Func2Button.ButtonIsUp:=True; Func2Button.Refresh;
      Func3Button.Caption:='Next Page';      Func3Button.Visible:=True; Func3Button.ButtonIsUp:=True; Func3Button.Refresh;
      Func4Button.Caption:='Previous Page';  Func4Button.Visible:=True; Func4Button.ButtonIsUp:=True; Func4Button.Refresh;
      Func5Button.Caption:='Print';          Func5Button.Visible:=True; Func5Button.ButtonIsUp:=True; Func5Button.Refresh;

      InPreviewDialog:=True;
      while (not Application.Terminated) and InPreviewDialog do
      begin
         Sleep(1);
         Application.ProcessMessages;
      end;

      PopItem;
   end;
   UIMenuNode:=TUIMenuNode(I3UINode.NodeNamed(Name));
   if UIMenuNode = nil then Exit;
   CurrentItem:=Name;
   SetTitleLabelCaption(UIMenuNode.Title);
   PromptLabel.Caption:=UIMenuNode.Prompt;
   HintLabel  .Caption:=UIMenuNode.Hint;
   ItemsNode:=TCorvusNode(UIMenuNode.NodeNamed('Items'));
   for I:=0 to 4 do
   begin
      case I of
         1  : Button:=Func2Button;
         2  : Button:=Func3Button;
         3  : Button:=Func4Button;
         4  : Button:=Func5Button;
         else Button:=Func1Button;
      end;
      if (ItemsNode <> nil) and (I < ItemsNode.Count) then
      begin
         if I3UINode.NodeNamed(ItemsNode[I]) <> nil then
         begin
            Button.Caption:=TUINode(I3UINode.NodeNamed(ItemsNode[I])).Title;
         end
         else
         begin
            if (ReportsNode <> nil ) and (ReportsNode.ReportNamed(ItemsNode[I]) <> nil) then
            begin
               Button.Caption:=TReportNode(ReportsNode.ReportNamed(ItemsNode[I])).Title;
            end
            else if ItemsNode[I] = 'ReprintReport' then
            begin
               Button.Caption:='Reprint Report';
            end
            else
            begin
               Button.Caption:=ItemsNode[I];
            end;
         end;
         Button.Visible:=True;
         Button.ButtonIsUp:=True;
         Button.Refresh;
      end
      else
      begin
         Button.Visible:=False;
      end;
   end;
   ShowForm(UIMenuNode.Form);
   if (UIMenuNode.Select <> '') and (ItemsNode.indexOf(UIMenuNode.Select) <> -1) then
   begin
      case ItemsNode.indexOf(UIMenuNode.Select) of
         0 : Func1Button.ForceClick;
         1 : Func2Button.ForceClick;
         2 : Func3Button.ForceClick;
         3 : Func4Button.ForceClick;
         4 : Func5Button.ForceClick;
      end;
   end;
end;

procedure TI3UIForm.PopItem;
var
   SO:TStringObject;
begin
   CancelButton.ButtonIsUp:=True;
   CancelButton.Refresh;
   if ItemStack.Count > 0 then
   begin
      SO:=TStringObject(ItemStack.Objects[ItemStack.Count-1]);
      ShowMenu(ItemStack[ItemStack.Count-1]);
      ItemStack.Delete(ItemStack.Count-1);
      if SO <> nil then
      begin
         SetFormDetails(CentrePanel,SO.Value);
         SharedData.SetVariable('FormData',SO.Value);
         SO.Free;
      end;
   end;
end;
procedure TI3UIForm.PushItem;
begin
   if CurrentItem <> '' then
      ItemStack.AddObject(CurrentItem,TStringObject.Create(GetFormDetails(CentrePanel)));
end;
procedure TI3UIForm.ReprintReport; 
var
   ReportNode : TReportNode;
   FileName:String;
   SL:TStringList;
   I:Integer;
   S:String;
   Control:TWinControl;
   UIDomainNode:TUIDomainNode;
const
   LastReportFound:String = '';
begin
   if SharedData = nil then
      SharedData:=TSharedData.Create('CorvusReportShare',False);
   
   SL:=TStringList.Create;
   SL.CommaText:=CurrentForm.Domains;
   FileName:='';
   for I:=0 to SL.Count-1 do
   begin
      UIDomainNode:=TUIDomainNode(I3UINode.NodeNamed('Domain.'+SL[I]));
      if UIDomainNode <> nil then
      begin
         if (UIDomainNode.CompType = 'PickList') and (UIDomainNode.ListName = 'ReportReprintList') then
         begin
            Control:=GetControlNamed(UIDomainNode.Name,CentrePanel);
            if Control <> nil then
            begin
               S:=(Control as TComboBox).Text;
               //convert DD/MM/YY HH:MM:SS Name
               //to      C:\Saved Reports\Name.YYMMDDHHMMSS.Rep
               FileName:=SavedReports+'\'+Copy(S,19,Length(S))+'.'+Copy(S,7,2)+Copy(S,4,2)+Copy(S,1,2)+Copy(S,10,2)+Copy(S,13,2)+Copy(S,16,2)+'.Rep';
               break;
            end;   
         end;
      end;
   end;
   ReportNode:=ReportsNode.ReportNamed(ExtractFileName(Copy(FileName,1,Length(FileName)-17)));
   if ReportNode <> nil then
   begin
      UsingNewExecute:=True;
      PrintPreview:=TPrintPreview.Create(nil);
      PrintPanel.Visible:=True;
      PrintPanel.BringToFront;
      PrintPanel.InsertControl(PrintPreview);
      PrintPreview.Repaint;
      PrintPreview.Name:='pp';
      PrintPreview.ZoomState:=zsZoomToWidth;
      PrintPreview.PrintJobTitle:=ReportNode.Title+' Reprint';
   
      if ReportNode.Landscape then
         PrintPreview.Orientation:=poLandscape
      else
         PrintPreview.Orientation:=poPortrait;
      
      PrintPreview.BeginDoc;      
      SetTitleLabelCaption('Collecting Data');
      SetupDLLCall;
      ReportsNode.ReprintSavedReportOn(FileName,RepCallBack,RepHeadCallBack,RepFootCallBack,PrintPreview);
      SetTitleLabelCaption(ReportNode.Title+' Preview');
      PreviewFunction('Preview');
   end;
end;
function TI3UIForm.Exec(Name:String;Modal:Boolean):Integer; 
var
   UINode:TUINode;
   S:String;
begin
   Result:=0;
   if Name = 'Exit' then 
   begin
      LogOff;
      Exit;
   end;
   if (Name = 'ReprintReport') and (ReportsNode <> nil) then
   begin
      ReprintReport;
      Exit;
   end;    
   UINode:=TUINode(I3UINode.NodeNamed(Name));  
   if (UINode is TUIMenuNode) then
   begin
      PushItem;
      ShowMenu(Name);
      if Modal then
      begin
         InModalDialog:=True;
         while (not Application.Terminated) and InModalDialog do
         begin
            Sleep(1);
            Application.ProcessMessages;
         end;
         PopItem;
      end;
   end
   else if (UINode is TUIFormNode) then
   begin
      S:=GetFormDetails(CentrePanel);
      ShowForm(Name);
      SetFormDetails(CentrePanel,S);
//      PopAllButtons;
      Result:=1;
   end               
   else if (UINode is TUIFunctionNode) then
   begin
      Result:=ExecuteFunction(Name);
      if Result = 2 then PopAllButtons;
   end
   else if ReportsNode <> nil  then
   begin
      RunReport(Name);
      Result:=3;
   end;
end;

// -- Repopulate original form when another (optional) form has been deselected --
// eg Issue Money order with Issue company money order selected and then deselected.
function TI3UIForm.UnExec(Name:String):Integer;
var
   UINode:TUINode;
   S:String;
begin
   Result:=0;
   UINode:=TUINode(I3UINode.NodeNamed(Name));
   if (UINode is TUIFormNode) then
   begin
      S:=GetFormDetails(CentrePanel);
      UINode:=TUINode(I3UINode.NodeNamed(CurrentItem));
      if (UINode is TUIMenuNode) and ((UINode as TUIMenuNode).Form <> '') then
         ShowForm((UINode as TUIMenuNode).Form);
      SetFormDetails(CentrePanel,S);
   end
end;
procedure Centre(Canvas:TCanvas;Width,YPos:Integer;S:String);
begin
   Canvas.TextOut((Width-Canvas.TextWidth(S)) div 2,YPos,S);
end;

procedure TI3UIForm.PopAllButtons;
begin
   Func1Button.ButtonIsUp:=True;
   Func2Button.ButtonIsUp:=True;
   Func3Button.ButtonIsUp:=True;
   Func4Button.ButtonIsUp:=True;
   Func5Button.ButtonIsUp:=True;
end;
procedure TI3UIForm.PreviewFunction(Name:String);
var
   PrintAns :integer;
begin
   if PrintPreview = nil then Exit;
   if Name = 'Preview' then
   begin
      PromptLabel.Caption:='Preview Page '+IntToStr(PrintPreview.CurrentPage)+' of '+IntToStr(PrintPreview.TotalPages);
      ShowMenu('Print Preview');
   end
   else if Name = 'Cancel Operation' then
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
      PrintAns := mrNo ;
      while (PrintAns = mrNo) do
      begin
         PrintPreview.Print;
         if GetGPCSRegString(SystemType+'\Reports','Print Confirmation','Y') = 'Y' then
            PrintAns:=MessageDlg('Did it print successfully?', mtConfirmation, [mbYes,mbNo,mbCancel	], 0)
         else
            PrintAns:=mrYes;
         Application.ProcessMessages;
      end ;
      PrintPanel.RemoveControl(PrintPreview);
      PrintPanel.Visible:=False;
      PrintPreview.Free;
      PrintPreview:=nil;
      InPreviewDialog:=False;

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
      PromptLabel.Caption:='Preview Page '+IntToStr(PrintPreview.CurrentPage)+' of '+IntToStr(PrintPreview.TotalPages)
   end
   else if Name = 'Previous Page' then
   begin
      if PrintPreview.CurrentPage > 1 then
         PrintPreview.CurrentPage:=PrintPreview.CurrentPage-1;
      PromptLabel.Caption:='Preview Page '+IntToStr(PrintPreview.CurrentPage)+' of '+IntToStr(PrintPreview.TotalPages)
   end
   else if Name = 'First Page' then
   begin
      PrintPreview.VertScrollBar.Position:=0;
      PrintPreview.CurrentPage:=1;
      PromptLabel.Caption:='Preview Page '+IntToStr(PrintPreview.CurrentPage)+' of '+IntToStr(PrintPreview.TotalPages)
   end
   else if Name = 'Last Page' then
   begin
      PrintPreview.VertScrollBar.Position:=0;
      PrintPreview.CurrentPage:=PrintPreview.TotalPages;
      PromptLabel.Caption:='Preview Page '+IntToStr(PrintPreview.CurrentPage)+' of '+IntToStr(PrintPreview.TotalPages)
   end;
end;  
procedure TI3UIForm.Func1ButtonClick(Sender: TObject);
var
   UIMenuNode:TUIMenuNode;
   ItemsNode:TCorvusNode;
   ButtonState:Boolean;
   Res:Integer;
begin
   if InPreviewDialog then
   begin
         PreviewFunction((Sender as TKGButton).Caption);
         (Sender as TKGButton).ButtonIsUp:=True;
         //Application.MessageBox( 'Did it print successfully?','', IDOK+ IDNO+ IDCANCEL );
      //Exit;
   end;
   if InModalDialog then
   begin
      ModalResult:='Cancel';
      ItemsNode:=nil;
      UIMenuNode:=TUIMenuNode(I3UINode.NodeNamed(CurrentItem));
      if UIMenuNode <> nil then
         ItemsNode:=TCorvusNode(UIMenuNode.NodeNamed('Items'));
      if  (ItemsNode <> nil)
      and (Sender is TKGButton)
      and ((Sender as TKGButton).Tag <= ItemsNode.Count) then
         ModalResult:=ItemsNode[(Sender as TKGButton).Tag-1];

      InModalDialog:=False;
      Exit;
   end;
   UIMenuNode:=TUIMenuNode(I3UINode.NodeNamed(CurrentItem));
   ItemsNode:=TCorvusNode(UIMenuNode.NodeNamed('Items'));
   if (Sender as TKGButton).Tag = 0 then  // Help
   begin
      (Sender as TKGButton).ButtonIsUp:=not (Sender as TKGButton).ButtonIsUp;
   end
   else if (ItemsNode <> nil) then                    
   begin 
      if (Sender as TKGButton).Tag <= ItemsNode.Count then
      begin
         ButtonState:=(Sender as TKGButton).ButtonIsUp;
         if ButtonState then 
            Res:=UnExec(ItemsNode[(Sender as TKGButton).Tag-1])
         else
            Res:=Exec(ItemsNode[(Sender as TKGButton).Tag-1],False);
         if Res >= 2 then
            (Sender as TKGButton).ButtonIsUp:=not ButtonState;
      end;
   end;
   if (Sender as TKGButton).Tag = 6 then 
     PopItem;
end;

procedure SetShutdownPrivilege;
var
   ProcHandle:THandle;
   TokHandle:THandle;
   TmpLUID:TLargeInteger;
   TokPriv:TTokenPrivileges;
   TokNew:TTokenPrivileges;
   BufferNeeded:DWord;
begin
   ProcHandle:=GetCurrentProcess;
   OpenProcessToken(ProcHandle,TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,TokHandle);
   LookupPrivilegeValue('','SeShutdownPrivilege',TmpLUID);
   TokPriv.PrivilegeCount:=1;
   TokPriv.Privileges[0].LUID:=TmpLUID;
   TokPriv.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED;
   AdjustTokenPrivileges(TokHandle,False,TokPriv,Sizeof(TokNew),TokNew,BufferNeeded);
end;                  
procedure LogOff;
begin
   if GetGPCSRegString(SystemType,'Logoff on Exit','Yes') <> 'No' then
   begin
      SetShutdownPrivilege;
      ExitWindowsEx(EWX_LOGOFF or EWX_FORCE,0);
   end;
   Application.MainForm.Close;
end;

procedure TI3UIForm.FormDestroy(Sender: TObject);
type
   TUIDLLShutdown = procedure;
var
   UIDLLShutdown:TUIDLLShutdown;
begin
   UserList.Free;
   UserList:=nil;
   Txnlog:=nil;
   Period:=nil;
   Stock :=nil;

   try if ItemStack <> nil then ItemStack.Free; except end;
   try if I3UINode  <> nil then I3UINode .Free; except end;
   try if FuncList  <> nil then FuncList .Free; except end;
   try
      if DLLList <> nil then
      begin
         while DLLList.Count > 0 do
         begin
            try
               @UIDLLShutdown:=GetProcAddress(THandle(DLLList.Objects[0]),'UIDLLShutdown');
               if @UIDLLShutdown <> nil then UIDLLShutdown;
            except
            end;
            try
               FreeLibrary(THandle(DLLList.Objects[0]));
            except
            end;
            DLLList.Delete(0);
         end;
         DLLList.Free;
      end;
   except
   end;
   try if SharedData <> nil then SharedData.Free; except end;
end;
procedure TI3UIForm.ExceptionEvent(Sender: TObject; E: Exception);
begin
   GlobalExceptionEvent(Sender,E);
end;

end.
