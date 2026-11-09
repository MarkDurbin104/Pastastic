unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, StdCtrls, ComCtrls, Printers;
    
type

   TPrintRec = packed record
      Length : Word;
      Data : array [0..255] of Char;
   end;
   
   TControlRec = packed record
      ContType : Char;
      Offset   : array [0..3] of Word;
      Caption  : String;
      Caption2 : String;
   end;
   
  TMainForm = class(TForm)
    ToolBar: TPanel;
    StatusPanel: TPanel;
    MainPanel: TPanel;
    Status1: TPanel;
    Status2: TPanel;
    Status3: TPanel;
    NewButton: TSpeedButton;
    SaveButton: TSpeedButton;
    CutButton: TSpeedButton;
    CopyButton: TSpeedButton;
    PasteButton: TSpeedButton;
    PrintButton: TSpeedButton;
    StringsButton: TSpeedButton;
    DialogsButton: TSpeedButton;
    LanguageCombo: TComboBox;
    Notebook: TNotebook;
    ListBox2: TListBox;
    ListBox1: TListBox;
    Panel2: TPanel;
    CopyLinesButton: TSpeedButton;
    StringEdit: TEdit;
    Label1: TLabel;
    InFile1: TEdit;
    InFile2: TEdit;
    Label2: TLabel;
    OutDir: TEdit;
    SetupButton: TSpeedButton;
    AboutButton: TSpeedButton;
    DSPanel: TPanel;
    Panel4: TPanel;
    DialogList: TListBox;
    DialogPanel: TPanel;
    ScrollBox1: TScrollBox;
    PaintBox2: TPaintBox;
    DWPanel: TPanel;
    PaintBox1: TPaintBox;
    ListBox3: TListBox;
    ListBox4: TListBox;
    Panel3: TPanel;
    SpeedButton2: TSpeedButton;
    DStringLabel: TLabel;
    DStringEdit: TEdit;
    TestImage: TImage;
    Panel1: TPanel;
    Memo1: TMemo;
    Label3: TPaintBox;
    StringLabel: TLabel;
    TickCross: TImage;
    PaintBox3: TPaintBox;
    LPanel: TPanel;
    Label4: TLabel;
    Timer1: TTimer;
    Image1: TImage;
    Label5: TLabel;
    Panel5: TPanel;
    ProgBar: TProgressBar;
    Label6: TLabel;
    Label7: TLabel;
    FontDialog1: TFontDialog;
    Button1: TButton;
    procedure StringsButtonClick(Sender: TObject);
    procedure DialogsButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NotebookPageChanged(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure PaintBox2Paint(Sender: TObject);
    procedure DialogListClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBox1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure SetupButtonClick(Sender: TObject);
    procedure CopyLinesButtonClick(Sender: TObject);
    procedure ListBox2DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure StringEditChange(Sender: TObject);
    procedure ListBox2Click(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure NewButtonClick(Sender: TObject);
    procedure AboutButtonClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Label3Paint(Sender: TObject);
    procedure PaintBox3Paint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure LanguageComboChange(Sender: TObject);
    procedure DialogListDblClick(Sender: TObject);
    procedure Panel2DblClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    OutputStrings,InputStrings:TStringList;
    TheControl  : TControlRec;
    NumbControl : Word;
    Modified,DoneTick,IgnoreChange:Boolean;
    ImageOfs:Integer;
    ImDir:Integer;
    XbaseUnit:Integer;
    YbaseUnit:Integer;
    procedure DrawWindow(Canvas:TCanvas;X,Y,W,H:Integer;Caption,FontName:String;FontSize,DOffset:Integer);
    procedure DrawLabel(TheCanvas:TCanvas;Str:String;X,Y,fg,bg:Integer);
    procedure FillControlRec(DOffset:Integer);
    procedure SaveTimer(Sender: TObject);
    procedure LoadTimer(Sender: TObject);
    procedure NewTimer(Sender: TObject);
    function AdjX(X:Word):Word;
    function AdjY(Y:Word):Word;
  public                                              
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses Fileacc, AbtForm, resload, ModifChk, wait1;

{$R *.DFM}

procedure ListLangs        (if1,if2,of1,basedir:Pointer);  stdcall; external 'TRANS_RC.DLL';
function  SaveResource     (if1,if2,of1,basedir:Pointer): Word;  stdcall; external 'TRANS_RC.DLL';
function  GenStringList    (if1,if2,of1:Pointer;Adj:Integer): Word;  stdcall; external 'TRANS_RC.DLL';
function  GenTransList     (if1,if2,of1,basedir:Pointer;Adj:Integer): Word;  stdcall; external 'TRANS_RC.DLL';
function  GenETransList    (if1,if2,of1:Pointer;Adj:Integer): Word;  stdcall; external 'TRANS_RC.DLL';
function  SplitString      (From,Into:PChar): Word;      stdcall; external 'TRANS_RC.DLL';
function  CheckControlChars(S1,S2:PChar): Word;       stdcall; external 'TRANS_RC.DLL';
                                                                        
procedure TMainForm.StringsButtonClick(Sender: TObject);
begin
    Notebook.PageIndex:=0;
end;

procedure TMainForm.DialogsButtonClick(Sender: TObject);
begin
    Notebook.PageIndex:=1;
end;

procedure TMainForm.FormShow(Sender: TObject);
var
   HintStrings: TStringList;
   I:Integer;
begin        
    I:=GetDialogBaseUnits;
    XbaseUnit:=I and $FFFF;
    YbaseUnit:=(I shr 16) and $FFFF;
    IgnoreChange:=False;
    Modified:=False;
    Notebook.PageIndex:=0;
    HintStrings:=TStringList.Create;
    HintStrings.LoadFromFile('TRANS.LNG');
    if HintStrings.Count > 13 then
    begin
       MainForm.Caption    :=HintStrings.Strings[ 0];
       NewButton.Hint      :=HintStrings.Strings[ 3];
       SaveButton.Hint     :=HintStrings.Strings[ 4];
       CutButton.Hint      :=HintStrings.Strings[ 5];
       CopyButton.Hint     :=HintStrings.Strings[ 6];
       PasteButton.Hint    :=HintStrings.Strings[ 7];
       PrintButton.Hint    :=HintStrings.Strings[ 8];
       StringsButton.Hint  :=HintStrings.Strings[ 9];
       DialogsButton.Hint  :=HintStrings.Strings[10];
       LanguageCombo.Hint  :=HintStrings.Strings[11];
       CopyLinesButton.Hint:=HintStrings.Strings[12];
       SetupButton.Hint    :=HintStrings.Strings[13];
    end;
    HintStrings.Clear;
    HintStrings.LoadFromFile('FILES.LNG');
    if HintStrings.Count > 2 then
    begin
       InFile1.Text        :=HintStrings.Strings[0];
       InFile2.Text        :=HintStrings.Strings[1];
       OutDir.Text         :=HintStrings.Strings[2];
    end;
    HintStrings.Destroy;                                                             
    
    ListLangs(PChar(InFile1.Text),PChar(InFile2.Text),PChar('LANGLIST.STR'),PChar(OutDir.Text));
    LanguageCombo.Items.LoadFromFile('LANGLIST.STR');
    if LanguageCombo.Items.IndexOf('Lang0') < 0 then
       LanguageCombo.Items.Add('Lang0');
    LanguageCombo.Text:='Lang0';
    LanguageCombo.ItemIndex:=LanguageCombo.Items.IndexOf('Lang0');
    if InputStrings <> nil then exit;
    LPanel.Visible:=True;
    Timer1.Interval:=1;
    ImageOfs:=0;
    ImDir:=0;
end;      
procedure TMainForm.DrawWindow(Canvas:TCanvas;X,Y,W,H:Integer;Caption,FontName:String;FontSize,DOffset:Integer);
var
   Index :Word;
   Rect1 :TRect;
   Rect2 :TRect;
begin
   with Canvas do
   begin
      Brush.Color:=clWhite;
      Brush.Style:=bsSolid;   
      Pen.Color:=clWhite;     
      Rectangle(X,Y,X+W+1,Y+H+1);
      Pen.Width:=1;
      Pen.Style := psSolid;
      Pen.Color:=clBlack;     
      Brush.Style:=bsSolid;   
      Brush.Color := clSilver;
      Rectangle(X,Y,X+W,Y+H);
      Brush.Style:=bsClear;
      Rectangle(X,Y,X+23,Y+23);
      Rectangle(X+W-23,Y,X+W,Y+23);
      MoveTo(X    ,Y+H-23); LineTo(X+3,Y+H-23);
      MoveTo(X+W-3,Y+H-23); LineTo(X+W,Y+H-23);
      MoveTo(X+W-23,Y+H-3); LineTo(X+W-23,Y+H);
      MoveTo(X+W-23,Y+H-3); LineTo(X+W-23,Y+H);
      Inc(X,3); Inc(Y,3); Dec(W,6); Dec(H,6);
      Rectangle(X,Y,X+W,Y+H);
      Rectangle(X+W-39,Y,X+W-19,Y+20);
      Brush.Style:=bsSolid;   
      Brush.Color:=clNavy;  
      Rectangle(X+20,Y,X+W-39,Y+20);
          
      Brush.Color := clWhite;
      Pen.Color:=clGray;
      Rectangle(X+5,Y+9,X+17,Y+12);
      Pen.Color:=clBlack;
      Rectangle(X+4,Y+8,X+16,Y+11);
          
      Pen.Color:=clWhite;
      Brush.Style:=bsClear;   
      Rectangle(X+W-38,Y+1,X+W-20,Y+19);
      Rectangle(X+W-19,Y+1,X+W-1,Y+19);
      Pen.Color:=clGray;
      Rectangle(X+W-21,Y+2,X+W-20,Y+19);
      Rectangle(X+W-2,Y+2,X+W-1,Y+19);
      Rectangle(X+W-37,Y+18,X+W-20,Y+19);
      Rectangle(X+W-18,Y+18,X+W-1,Y+19);
          
      Pen.Color:=clBlack;
      MoveTo(X+W- 8,Y+10); LineTo(X+W-15,Y+10);
      MoveTo(X+W- 9,Y+ 9); LineTo(X+W-14,Y+ 9);
      MoveTo(X+W-10,Y+ 8); LineTo(X+W-13,Y+ 8);
      MoveTo(X+W-11,Y+ 7); LineTo(X+W-12,Y+ 7);
          
      MoveTo(X+W-27,Y+ 8); LineTo(X+W-34,Y+ 8);
      MoveTo(X+W-28,Y+ 9); LineTo(X+W-33,Y+ 9);
      MoveTo(X+W-29,Y+10); LineTo(X+W-32,Y+10);
      MoveTo(X+W-30,Y+11); LineTo(X+W-31,Y+11);
                                            
      Brush.Style:=bsClear;
      Font.Color:=clWhite;
      Font.Name:='MS Sans Serif';    
      Font.Size:=7;
      TextOut(X+(((W-60)-TextWidth(Caption)) div 2)+20,Y+((20-TextHeight(Caption)) div 2),Caption);
      Font.Style:=[];         
      Font.Name:=FontName;    
      Font.Size:=FontSize;
      
      NumbControl:=StrToInt(InputStrings.Strings[DOffset+8]);
      if NumbControl <> 0 then
      begin
         Inc(DOffset,9);
         for Index:=0 to NumbControl-1 do
         begin
            FillControlRec(DOffset);
            Inc(DOffset,8);
            Brush.Style:=bsClear;
            Pen.Color:=clRed;
            Font.Color:=clRed;
            if  (TheControl.ContType <> 'P') and (TheControl.ContType <> 'D') 
            and (TheControl.ContType <> 'I') and (TheControl.ContType <> 'T') 
            and (TheControl.ContType <> 'L') and (TheControl.ContType <> 'R') 
            and (TheControl.ContType <> 'C') and (TheControl.ContType <> 'B')
            and (TheControl.ContType <> 'E') and (TheControl.ContType <> 'G')
            and (TheControl.ContType <> '2')
            and (TheControl.ContType <> '3')
            and (TheControl.Caption2 <> 'Static')
            and (TheControl.Caption2 <> 'Button')
            and (TheControl.Caption2 <> 'SysListView32')
            and (TheControl.Caption2 <> 'SysTreeView32')
            and (TheControl.Caption2 <> 'msctls_updown32')
            and (TheControl.Caption2 <> 'SysTabControl32') then
            begin
                Rectangle(TheControl.Offset[0],TheControl.Offset[1],
                          TheControl.Offset[0]+TheControl.Offset[2],
                          TheControl.Offset[1]+TheControl.Offset[3]);
                TextOut(TheControl.Offset[0],TheControl.Offset[1],TheControl.Caption); 
            end;
            if (TheControl.ContType = 'G')
            or (TheControl.ContType = '1') then
            begin
               Pen.Color:=clWhite;
               Rectangle(TheControl.Offset[0],TheControl.Offset[1]+(TextHeight(TheControl.Caption) div 2),
                         TheControl.Offset[0]+TheControl.Offset[2],
                         TheControl.Offset[1]+TheControl.Offset[3]-(TextHeight(TheControl.Caption) div 2));
               Pen.Color:=clGray;
               Rectangle(TheControl.Offset[0]+1,TheControl.Offset[1]+(TextHeight(TheControl.Caption) div 2)+1,
                         TheControl.Offset[0]+TheControl.Offset[2]+1,
                         TheControl.Offset[1]+TheControl.Offset[3]-(TextHeight(TheControl.Caption) div 2)+1);
            end 
            else if TheControl.ContType = 'I' then
            begin
               Rect1.Left  :=TheControl.Offset[0];
               Rect1.Right :=TheControl.Offset[0]+TheControl.Offset[2];
               Rect1.Top   :=TheControl.Offset[1];
               Rect1.Bottom:=TheControl.Offset[1]+TheControl.Offset[3];
               Rect2.Left  :=0;
               Rect2.Right :=TheControl.Offset[2];
               Rect2.Top   :=0;
               Rect2.Bottom:=TheControl.Offset[3];
            
               CopyRect(Rect1,TestImage.Picture.Bitmap.Canvas,Rect2);
            end
            else if TheControl.Caption2 = 'Static' then
            begin
               Pen.Color:=clBlack;
               Font.Color:=clBlack;
               if TheControl.Caption <> '' then
                  TextOut(TheControl.Offset[0],TheControl.Offset[1],TheControl.Caption)
               else
                  Rectangle(TheControl.Offset[0],TheControl.Offset[1],
                            TheControl.Offset[0]+TheControl.Offset[2],
                            TheControl.Offset[1]+TheControl.Offset[3]);
            end;
         end; 
      end; 
   end;
end;

procedure TMainForm.NotebookPageChanged(Sender: TObject);
var
   I:Integer;
begin
   if Notebook.PageIndex = 0 then
   begin
      ListBox1Click(Self);
   end
   else if Notebook.PageIndex = 1 then
   begin
      DialogListClick(Self);
   end;          
end;   

procedure TMainForm.PaintBox1Paint(Sender: TObject);
var
   DOffset:Integer;
begin
   if DialogList.Items.Count < 1 then Exit;
   if DialogList.ItemIndex < 0 then DialogList.ItemIndex:=0;
   DOffset:=Integer(DialogList.Items.Objects[DialogList.ItemIndex]);
   if (DOffset < 0) or (DOffset+7 > InputStrings.Count) then Exit;
   if OutputStrings.Strings[DOffset+1] <> '' then
   begin
      DrawWindow(PaintBox1.Canvas,0,0,
         AdjX(StrToInt(InputStrings.Strings[DOffset+6]))+6,
         AdjY(StrToInt(InputStrings.Strings[DOffset+7]))+26 ,
         OutputStrings.Strings[DOffset+1],
         InputStrings.Strings[DOffset+3],
         StrToInt(InputStrings.Strings[DOffset+2]),DOffset);
   end
   else
   begin
      DrawWindow(PaintBox1.Canvas,0,0,
         AdjX(StrToInt(InputStrings.Strings[DOffset+6]))+6,
         AdjY(StrToInt(InputStrings.Strings[DOffset+7]))+26 ,
         InputStrings.Strings[DOffset+1],
         InputStrings.Strings[DOffset+3],
         StrToInt(InputStrings.Strings[DOffset+2]),DOffset);
   end;
end;

procedure TMainForm.PaintBox2Paint(Sender: TObject);
begin
     with PaintBox2.Canvas do
     begin
        Pen.Color:=clBlack;
        Brush.Color:=clBtnFace;
        Brush.Style:=bsSolid;   
        Rectangle(0,0,PaintBox2.Width-1,PaintBox2.Height-1);
     end;
end;
procedure TMainForm.FillControlRec(DOffset:Integer);
begin
   if (DOffset < 0) or (DOffset > InputStrings.Count) then Exit;
   TheControl.ContType:=InputStrings.Strings[DOffset][1];
   if OutputStrings.Strings[DOffset+1] <> '' then
      TheControl.Caption:=OutputStrings.Strings[DOffset+1]
   else
      TheControl.Caption:=InputStrings.Strings[DOffset+1];
      
   TheControl.Caption2:=InputStrings.Strings[DOffset+2];
   TheControl.Offset[0]:=AdjX(StrToInt(InputStrings.Strings[DOffset+3]))+3;
   TheControl.Offset[1]:=AdjY(StrToInt(InputStrings.Strings[DOffset+4]))+23;
   TheControl.Offset[2]:=AdjX(StrToInt(InputStrings.Strings[DOffset+5]));
   TheControl.Offset[3]:=AdjY(StrToInt(InputStrings.Strings[DOffset+6]));
end;
function TMainForm.AdjX(X:Word):Word;
begin
   result:=(X*XbaseUnit) div 4;
end;
function TMainForm.AdjY(Y:Word):Word;
begin
   result:=(Y*YbaseUnit) div 8;
end;
procedure TMainForm.DialogListClick(Sender: TObject);
var
   Counter:Integer;
   Button:TButton;
   GroupBox:TGroupBox;
   ComboBox:TComboBox;
   ListBox:TListBox;
   TextLabel:TLabel;
   Edit:TEdit;
   CheckBox:TCheckBox;
   RadioButton:TRadioButton;
   TreeView  :TTreeView  ;
   TabControl:TTabControl;
   ListView  :TListView  ;
   UpDown    :TUpDown;
   DOffset   :Integer;
begin                  
   if DialogList.Items.Count < 1 then Exit;
   if DialogList.ItemIndex < 0 then DialogList.ItemIndex:=0;
   DOffset:=Integer(DialogList.Items.Objects[DialogList.ItemIndex]);
   if (DOffset < 0) or (DOffset > InputStrings.Count) then Exit;
   IgnoreChange:=True;
   ListBox3.ItemIndex:=-1;    
   ListBox4.ItemIndex:=-1;
   DStringLabel.Caption:=' ';
   DStringEdit.Text    :=' ';
   PaintBox3.Invalidate;
   IgnoreChange:=False;
 
   NumbControl:=StrToInt(InputStrings.Strings[DOffset+8]);
   DWPanel.Destroy;
   DWPanel:=TPanel.Create(self);
   ScrollBox1.InsertControl(DWPanel);
   DWPanel.Left  :=AdjX(StrToInt(InputStrings.Strings[DOffset+4]))  ;
   DWPanel.Top   :=AdjY(StrToInt(InputStrings.Strings[DOffset+5]))  ;
   DWPanel.Width :=AdjX(StrToInt(InputStrings.Strings[DOffset+6]))+2+6;
   DWPanel.Height:=AdjY(StrToInt(InputStrings.Strings[DOffset+7]))+2+26 ;
   PaintBox1:=TPaintBox.Create(self);
   DWPanel.InsertControl(PaintBox1);
   PaintBox1.Align:=alClient;
   PaintBox1.OnPaint:=PaintBox1Paint;                                               
   Listbox3.Items.BeginUpdate;
   Listbox4.Items.BeginUpdate;
   Listbox3.Items.Clear;
   Listbox4.Items.Clear;
   DWPanel.Visible:=True;                          
   try
      if (InputStrings.Strings[DOffset+1] <> '') then
      begin
         ListBox3.Items.AddObject(InputStrings.Strings[DOffset+1],TObject(DOffset+1));
         ListBox4.Items.AddObject(OutputStrings.Strings[DOffset+1],nil);
      end;
      Inc(DOffset,9);
      for Counter:=0 to NumbControl-1 do
      begin
         FillControlRec(DOffset);
         Inc(DOffset,8);
         if (TheControl.ContType = 'P') or (TheControl.ContType = 'D') or 
            (TheControl.Caption2 = 'Button') then
         begin
            Button:=TButton.Create(Self);
            Button.Left:=TheControl.Offset[0];
            Button.Top:=TheControl.Offset[1];
            Button.Width:=TheControl.Offset[2];
            Button.Height:=TheControl.Offset[3];
            Button.Caption:=TheControl.Caption;
            if (TheControl.Caption <> '') and (TheControl.Caption <> '...') then
            begin
               ListBox3.Items.AddObject(InputStrings.Strings[DOffset-7],TObject(DOffset-7));
               ListBox4.Items.AddObject(OutputStrings.Strings[DOffset-7],Button);
            end;
            Button.Visible:=True;
            DWPanel.InsertControl(Button);
         end
         else if (TheControl.Caption2 = 'Static') and (TheControl.Caption <> '') and (TheControl.Caption <> '...') then
         begin
            ListBox3.Items.AddObject(InputStrings.Strings[DOffset-7],TObject(DOffset-7));
            ListBox4.Items.AddObject(OutputStrings.Strings[DOffset-7],nil);
         end
         else if TheControl.Caption2 = 'SysListView32' then
         begin
            ListView:=TListView.Create(Self);
            ListView.Left:=TheControl.Offset[0];
            ListView.Top:=TheControl.Offset[1];
            ListView.Width:=TheControl.Offset[2];
            ListView.Height:=TheControl.Offset[3];
            ListView.Visible:=True;
            DWPanel.InsertControl(ListView);
         end
         else if TheControl.Caption2 = 'SysTreeView32' then
         begin
            TreeView:=TTreeView.Create(Self);
            TreeView.Left:=TheControl.Offset[0];
            TreeView.Top:=TheControl.Offset[1];
            TreeView.Width:=TheControl.Offset[2];
            TreeView.Height:=TheControl.Offset[3];
            TreeView.Visible:=True;
            DWPanel.InsertControl(TreeView);
         end
         else if TheControl.Caption2 = 'msctls_updown32' then
         begin
            UpDown:=TUpDown.Create(Self);
            UpDown.Left:=TheControl.Offset[0];
            UpDown.Top:=TheControl.Offset[1];
            UpDown.Width:=TheControl.Offset[2];
            UpDown.Height:=TheControl.Offset[3];
            UpDown.Visible:=True;
            DWPanel.InsertControl(UpDown);
         end                          
         else if TheControl.Caption2 = 'SysTabControl32' then
         begin
            TabControl:=TTabControl.Create(Self);
            TabControl.Left:=TheControl.Offset[0];
            TabControl.Top:=TheControl.Offset[1];
            TabControl.Width:=TheControl.Offset[2];
            TabControl.Height:=TheControl.Offset[3];
            TabControl.Visible:=True;
            DWPanel.InsertControl(TabControl);
            TabControl.Tabs.Add('                  Tab1                   ');
            TabControl.Tabs.Add('                  Tab2                   ');
            TabControl.Tabs.Add('                  Tab3                   ');
         end
         else if TheControl.ContType = 'B' then
         begin
            ListBox:=TListBox.Create(Self);
            ListBox.Left:=TheControl.Offset[0];
            ListBox.Top:=TheControl.Offset[1];
            ListBox.Width:=TheControl.Offset[2];
            ListBox.Height:=TheControl.Offset[3];
            ListBox.Visible:=True;
            DWPanel.InsertControl(ListBox);
         end
         else if TheControl.ContType = '2' then
         begin 
            CheckBox:=TCheckBox.Create(Self);
            CheckBox.Caption:=TheControl.Caption;
            CheckBox.Left:=TheControl.Offset[0];
            CheckBox.Top:=TheControl.Offset[1];
            CheckBox.Width:=TheControl.Offset[2];
            CheckBox.Height:=TheControl.Offset[3];
            CheckBox.Visible:=True;
            DWPanel.InsertControl(CheckBox);
            if TheControl.Caption <> '' then
            begin
               ListBox3.Items.AddObject(InputStrings.Strings[DOffset-7],TObject(DOffset-7));
               ListBox4.Items.AddObject(OutputStrings.Strings[DOffset-7],CheckBox);
            end;
         end
         else if TheControl.ContType = '3' then
         begin
            RadioButton:=TRadioButton.Create(Self);
            RadioButton.Caption:=TheControl.Caption;
            RadioButton.Left:=TheControl.Offset[0];
            RadioButton.Top:=TheControl.Offset[1];
            RadioButton.Width:=TheControl.Offset[2];
            RadioButton.Height:=TheControl.Offset[3];
            RadioButton.Visible:=True;
            DWPanel.InsertControl(RadioButton);
            if TheControl.Caption <> '' then
            begin
               ListBox3.Items.AddObject(InputStrings.Strings[DOffset-7],TObject(DOffset-7));
               ListBox4.Items.AddObject(OutputStrings.Strings[DOffset-7],RadioButton);
            end;
         end
         else if TheControl.ContType = 'C' then
         begin
            ComboBox:=TComboBox.Create(Self);
            ComboBox.Left:=TheControl.Offset[0];
            ComboBox.Top:=TheControl.Offset[1];
            ComboBox.Width:=TheControl.Offset[2];
            ComboBox.Height:=TheControl.Offset[3];
            ComboBox.Visible:=True;
            DWPanel.InsertControl(ComboBox);
         end
         else if (TheControl.ContType = 'L') 
              or (TheControl.ContType = 'G') then
         begin
            TextLabel:=TLabel.Create(Self);
            TextLabel.Left:=TheControl.Offset[0];
            if TheControl.ContType = 'L' then 
               TextLabel.AutoSize:=False
            else
               TextLabel.Left:=TheControl.Offset[0]+4;
            TextLabel.Top:=TheControl.Offset[1];
            TextLabel.Width:=TheControl.Offset[2];
            TextLabel.Height:=TheControl.Offset[3]+3;
            TextLabel.Visible:=True;
            TextLabel.Caption:=TheControl.Caption;
            if TheControl.Caption <> '' then
            begin
               ListBox3.Items.AddObject(InputStrings.Strings[DOffset-7],TObject(DOffset-7));
               ListBox4.Items.AddObject(OutputStrings.Strings[DOffset-7],TextLabel);
            end;
            TextLabel.Alignment:=taLeftJustify;
            DWPanel.InsertControl(TextLabel);
         end
         else if TheControl.ContType = 'T' then
         begin
            TextLabel:=TLabel.Create(Self);
            TextLabel.AutoSize:=False;
            TextLabel.Left:=TheControl.Offset[0];
            TextLabel.Top:=TheControl.Offset[1];
            TextLabel.Width:=TheControl.Offset[2];
            TextLabel.Height:=TheControl.Offset[3]+3;
            TextLabel.Visible:=True;
            TextLabel.Caption:=TheControl.Caption;
            if TheControl.Caption <> '' then
            begin
               ListBox3.Items.AddObject(InputStrings.Strings[DOffset-7],TObject(DOffset-7));
               ListBox4.Items.AddObject(OutputStrings.Strings[DOffset-7],TextLabel);
            end;
            TextLabel.Alignment:=taCenter;
            DWPanel.InsertControl(TextLabel);
         end
         else if TheControl.ContType = 'R' then
         begin
            TextLabel:=TLabel.Create(Self);
            TextLabel.AutoSize:=False;
            TextLabel.Left:=TheControl.Offset[0];
            TextLabel.Top:=TheControl.Offset[1];
            TextLabel.Width:=TheControl.Offset[2];
            TextLabel.Height:=TheControl.Offset[3]+3;
            TextLabel.Visible:=True;
            TextLabel.Caption:=TheControl.Caption;
            if TheControl.Caption <> '' then
            begin
               ListBox3.Items.AddObject(InputStrings.Strings[DOffset-7],TObject(DOffset-7));
               ListBox4.Items.AddObject(OutputStrings.Strings[DOffset-7],TextLabel);
            end;
            TextLabel.Alignment:=taRightJustify;
            DWPanel.InsertControl(TextLabel);
         end
         else if TheControl.ContType = 'E' then
         begin
            Edit:=TEdit.Create(Self);
            Edit.Left:=TheControl.Offset[0];
            Edit.Top:=TheControl.Offset[1];
            Edit.Width:=TheControl.Offset[2];
            Edit.Height:=TheControl.Offset[3];
            Edit.Visible:=True;
            Edit.Text:=TheControl.Caption;
            if TheControl.Caption <> '' then
            begin
               ListBox3.Items.AddObject(InputStrings.Strings[DOffset-7],TObject(DOffset-7));
               ListBox4.Items.AddObject(OutputStrings.Strings[DOffset-7],Edit);
            end;
            DWPanel.InsertControl(Edit);
         end;
      end;
   finally
      Listbox3.Items.EndUpdate;
      Listbox4.Items.EndUpdate;
      PaintBox1.Invalidate;
   end;
end;                      


procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
   FileStrings: TStringList;
begin
//   if (Modified = True) and (OutputStrings <> nil) then
//      OutputStrings.SaveToFile('TRANSOPT.STR');
   if InputStrings <> nil then InputStrings.Destroy;
   if OutputStrings <> nil then OutputStrings.Destroy;
   FileStrings:=TStringList.Create;
   FileStrings.Add(InFile1.Text);
   FileStrings.Add(InFile2.Text);
   FileStrings.Add(OutDir.Text );
   FileStrings.SaveToFile('FILES.LNG');
   FileStrings.Destroy;
end;

procedure TMainForm.ListBox1Click(Sender: TObject);
begin
   if Sender = ListBox1 then
   begin
      if (ListBox1.ItemIndex >= 0) and ( ListBox1.SelCount = 1) then
      begin
          StringLabel.Caption:=ListBox1.Items[ListBox1.ItemIndex];
          StringEdit.Text    :=ListBox2.Items[ListBox1.ItemIndex];
          ListBox2.ItemIndex:=ListBox1.ItemIndex;
          Label3.Invalidate;
          if StringEdit.Visible then StringEdit.SetFocus;
      end
      else
      begin
          StringLabel.Caption:=' ';
          StringEdit.Text    :=' ';
          ListBox2.ItemIndex:=-1;
          Label3.Invalidate;
      end;
   end
   else
   begin
      if (ListBox3.ItemIndex >= 0) and ( ListBox3.SelCount = 1) then
      begin
          DStringLabel.Caption:=ListBox3.Items[ListBox3.ItemIndex];
          DStringEdit.Text    :=ListBox4.Items[ListBox3.ItemIndex];
          ListBox4.ItemIndex:=ListBox3.ItemIndex;
          PaintBox3.Invalidate;
          if DStringEdit.Visible then DStringEdit.SetFocus;
      end
      else
      begin
          DStringLabel.Caption:=' ';
          DStringEdit.Text    :=' ';
          ListBox4.ItemIndex:=-1;
          PaintBox3.Invalidate;
      end;        
   end;
end;   

procedure TMainForm.FormResize(Sender: TObject);
begin
   ListBox2.Width   :=MainForm.ClientWidth div 2;
   ListBox4.Width   :=MainForm.ClientWidth div 2;
   StringEdit.Width :=MainForm.ClientWidth - (StringEdit.Left + 10);
   DStringEdit.Width:=MainForm.ClientWidth - (DStringEdit.Left + 10);
   Label3.Width     :=MainForm.ClientWidth - (Label3.Left + 10);
   PaintBox3.Width  :=MainForm.ClientWidth - (PaintBox3.Left + 10);
   AboutButton.Left :=MainForm.ClientWidth - (AboutButton.Width + 10);
   if DialogPanel.Height > 590 then
      DSPanel.Height:=DSPanel.Height+DialogPanel.Height-590
   else
      DSPanel.Height:=141;
end;

procedure TMainForm.SetupButtonClick(Sender: TObject);
begin
    Notebook.PageIndex:=2;
end;

procedure TMainForm.CopyLinesButtonClick(Sender: TObject);
var
   I,TopIndex:Integer;
begin
     ListBox1.Items.BeginUpdate;
     ListBox2.Items.BeginUpdate;
     Modified:=True;
     try
        TopIndex:=ListBox1.TopIndex;
        for i:=0 to ListBox1.Items.Count-1 do
        begin
           if ListBox1.Selected[I] then
           begin
              ListBox2.Items[I]:=ListBox1.Items[I];
              OutputStrings.Strings[Integer(ListBox1.Items.Objects[I])]:=ListBox1.Items[I];
           end;
        end;                             
     finally
        ListBox1.Items.EndUpdate;
        ListBox2.Items.EndUpdate;
        if (ListBox1.ItemIndex >= 0) and ( ListBox1.SelCount = 1) then
        begin
            StringLabel.Caption:=ListBox1.Items[ListBox1.ItemIndex];
            StringEdit.Text    :=ListBox2.Items[ListBox1.ItemIndex];
            Label3.Invalidate;
        end            
        else
        begin
            StringLabel.Caption:=' ';
            StringEdit.Text    :=' ';
            Label3.Invalidate;
        end;                   
        ListBox1.TopIndex:=TopIndex;
        ListBox2.TopIndex:=ListBox1.TopIndex;
     end;
end;             

procedure TMainForm.ListBox2DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
   r1,r2:TRect;
   i:Integer;
   fg1,fg2,bg1,bg2:Integer;
begin
   fg1:=clBlack;
   bg1:=clYellow;
   fg2:=clWhite;
   bg2:=clYellow;
   r1.Left  :=0;
   r1.Right :=19;
   r1.Top   :=0 ;
   r1.Bottom:=12;
   r2.Left  :=Rect.Left  ;
   r2.Right :=Rect.Left+19;
   r2.Top   :=Rect.Top   ;
   r2.Bottom:=Rect.Bottom;
   with (Control as TListBox).Canvas do
   begin
      if Control = ListBox1 then
      begin
          if ListBox2.Items[Index] = '' then
          begin
             fg1:=clMaroon;
             bg1:=clRed;
             r1.Top   :=13 ;
             r1.Bottom:=25;
          end
          else               
          begin
             fg1:=clNavy;
             bg1:=clBlue;
          end;
          ListBox2.TopIndex:=ListBox1.TopIndex;
      end
      else if Control = ListBox2 then
      begin
          fg1:=clBlack;
          if ListBox2.Items[Index] <> '' then
          begin
             if CheckControlChars(PChar(ListBox2.Items[Index]),PChar(ListBox1.Items[Index])) = 0 then
             begin
                r1.Top   :=13 ;
                r1.Bottom:=25;
                fg1:=clMaroon;
                bg1:=clRed;
                fg2:=clRed;
                bg2:=clRed;   
             end 
             else
             begin
                bg1:=clGreen;
                bg2:=clLime;
             end;
          end
          else
          begin
             r1.Top   :=13 ;
             r1.Bottom:=25;
          end;
          ListBox1.TopIndex:=ListBox2.TopIndex;
      end
      else if Control = ListBox3 then
      begin
          if ListBox4.Items[Index] = '' then
          begin
             fg1:=clMaroon;
             bg1:=clRed;
             r1.Top   :=13 ;
             r1.Bottom:=25;
          end
          else               
          begin
             fg1:=clNavy;
             bg1:=clBlue;
          end;
          ListBox4.TopIndex:=ListBox3.TopIndex;
      end
      else if Control = ListBox4 then
      begin
          fg1:=clBlack;
          if ListBox4.Items[Index] <> '' then
          begin
             if CheckControlChars(PChar(ListBox4.Items[Index]),PChar(ListBox3.Items[Index])) = 0 then
             begin
                r1.Top   :=13 ;
                r1.Bottom:=25;
                fg1:=clMaroon;
                bg1:=clRed;
                fg2:=clRed;
                bg2:=clRed;   
             end 
             else
             begin
                bg1:=clGreen;
                bg2:=clLime;
             end;
          end
          else
          begin
             r1.Top   :=13 ;
             r1.Bottom:=25;
          end;
          ListBox3.TopIndex:=ListBox4.TopIndex;
      end;                           
      FillRect(Rect);	{ clear the rectangle }
      if (Control as TListBox).Items[Index] <> '' then
      begin
          (Control as TListBox).Canvas.CopyRect(r2,TickCross.Picture.Bitmap.Canvas,r1);
      end
      else
      begin
         r1.Top   :=13 ;
         r1.Bottom:=25;
         (Control as TListBox).Canvas.CopyRect(r2,TickCross.Picture.Bitmap.Canvas,r1);
      end;
      if (State = [odDisabled]) or (State = []) then
         DrawLabel((Control as TListBox).Canvas,(Control as TListBox).Items[Index],
             Rect.Left+20,Rect.Top,fg1,bg1)
      else     
         DrawLabel((Control as TListBox).Canvas,(Control as TListBox).Items[Index],
             Rect.Left,Rect.Top,fg2,bg2);
   end    
end;

procedure TMainForm.StringEditChange(Sender: TObject);
var
   TopIndex:Integer;
begin
   Modified:=True;
   if Sender = StringEdit then
   begin
      if (ListBox1.ItemIndex >= 0) and ( ListBox1.SelCount = 1) then
      begin
         ListBox1.Items.BeginUpdate;
         ListBox2.Items.BeginUpdate;
         try
            TopIndex:=ListBox1.TopIndex;
            ListBox2.Items[ListBox1.ItemIndex]:=StringEdit.Text;
            OutputStrings.Strings[Integer(ListBox1.Items.Objects[ListBox1.ItemIndex])]:=StringEdit.Text;
         finally                        
            ListBox1.TopIndex:=TopIndex;
            ListBox2.TopIndex:=ListBox1.TopIndex;
            ListBox1.Items.EndUpdate;
            ListBox2.Items.EndUpdate;
         end;
      end;
   end
   else if IgnoreChange <> True then
   begin
      if (ListBox3.ItemIndex >= 0) and ( ListBox3.SelCount = 1) then
      begin
         ListBox3.Items.BeginUpdate;
         ListBox4.Items.BeginUpdate;
         try
            TopIndex:=ListBox3.TopIndex;
            ListBox4.Items[ListBox3.ItemIndex]:=DStringEdit.Text;
            OutputStrings.Strings[Integer(ListBox3.Items.Objects[ListBox3.ItemIndex])]:=DStringEdit.Text;
            if ListBox4.Items.Objects[ListBox3.ItemIndex] <> nil then
            begin
                 if ListBox4.Items.Objects[ListBox3.ItemIndex] is TLabel then
                     (ListBox4.Items.Objects[ListBox3.ItemIndex] as TLabel).Caption:=DStringEdit.Text
                 else if ListBox4.Items.Objects[ListBox3.ItemIndex] is TButton then
                     (ListBox4.Items.Objects[ListBox3.ItemIndex] as TButton).Caption:=DStringEdit.Text
                 else if ListBox4.Items.Objects[ListBox3.ItemIndex] is TRadioButton then
                     (ListBox4.Items.Objects[ListBox3.ItemIndex] as TRadioButton).Caption:=DStringEdit.Text
                 else if ListBox4.Items.Objects[ListBox3.ItemIndex] is TCheckBox then
                     (ListBox4.Items.Objects[ListBox3.ItemIndex] as TCheckBox).Caption:=DStringEdit.Text;
            end 
            else
                PaintBox1.Invalidate;                                                                                     
         finally
            ListBox3.TopIndex:=TopIndex;
            ListBox4.TopIndex:=TopIndex;
            ListBox3.Items.EndUpdate;
            ListBox4.Items.EndUpdate;
         end;
      end;
   end;
end;

procedure TMainForm.ListBox2Click(Sender: TObject);
begin
    if Sender = ListBox2 then
       ListBox2.ItemIndex:=-1
    else
       ListBox4.ItemIndex:=-1;
end;    

procedure TMainForm.SaveTimer(Sender: TObject);
begin
   SaveResource(PChar(InFile1.Text),PChar(InFile2.Text),PChar('ODIALOG.STR'),PChar(OutDir.Text+Save.LangName.Text+'\'));
   WaitForm.Timer1.Interval:=0;
   WaitForm.Timer1.OnTimer:=nil;
   WaitForm.ModalResult:=mrOK;;
end;                                       

procedure TMainForm.LoadTimer(Sender: TObject);
begin
   GenTransList(PChar(InFile1.Text),PChar(InFile2.Text),PChar('ODIALOG.STR'),PChar(OutDir.Text+Save.LangName.Text+'\'),1);
   WaitForm.Timer1.Interval:=0;
   WaitForm.Timer1.OnTimer:=nil;
   WaitForm.ModalResult:=mrOK;;
end;                                       

procedure TMainForm.NewTimer(Sender: TObject);
begin
   GenETransList(PChar(InFile1.Text),PChar(InFile2.Text),PChar('ODIALOG.STR'),1);
   WaitForm.Timer1.Interval:=0;
   WaitForm.Timer1.OnTimer:=nil;
   WaitForm.ModalResult:=mrOK;;
end;                                       

procedure TMainForm.SaveButtonClick(Sender: TObject);
var
   R,Index:Integer;
begin
     Index:=LanguageCombo.Items.IndexOf(Save.LangName.Text);
     R:=Save.ShowModal;
     if R = mrOk then
     begin             
        if Index < 0 then
            LanguageCombo.Items.Add(Save.LangName.Text);
        LanguageCombo.ItemIndex:=LanguageCombo.Items.IndexOf(Save.LangName.Text);
        LanguageCombo.Text:=Save.LangName.Text;
        OutputStrings.SaveToFile('ODIALOG.STR');
        Modified:=False;
        WaitForm.Label1.Caption:='Saving Files to :- ' + OutDir.Text+Save.LangName.Text;
        WaitForm.Timer1.OnTimer:=SaveTimer;
        WaitForm.Timer1.Interval:=2000;
        WaitForm.ShowModal;
     end;
end;

procedure TMainForm.NewButtonClick(Sender: TObject);
var
   I:Integer;
begin
     if Modified = True then 
        if SaveCheck.ShowModal = mrCancel then Exit;
     
     WaitForm.Label1.Caption:='Resetting Text';
     WaitForm.Timer1.OnTimer:=NewTimer;
     WaitForm.Timer1.Interval:=2000;
     WaitForm.ShowModal;
     OutputStrings.Clear;       
     OutputStrings.LoadFromFile('ODIALOG.STR');       
     try
        ListBox2.Items.BeginUpdate;
        ListBox2.Clear;
        ListBox4.Clear;
        DialogList.ItemIndex:=-1;
        for I:=0 to InputStrings.Count-1 do              
        begin
             if Copy(InputStrings.Strings[I],1,4) = 'S<^>' then
             begin
                ListBox2.Items.Add(OutputStrings.Strings[I+1]);
             end
        end;     
     finally
        ListBox2.Items.EndUpdate;
     end;                 
     Modified:=False;
     for I:=0 to 1000 do 
     begin
        Save.LangName.Text:='Lang'+IntToStr(i);
        if LanguageCombo.Items.IndexOf(Save.LangName.Text) < 0 then
        begin
            LanguageCombo.Items.Add(Save.LangName.Text);
            LanguageCombo.ItemIndex:=LanguageCombo.Items.IndexOf(Save.LangName.Text);
            LanguageCombo.Text:=Save.LangName.Text;
            break;
        end;
     end;
end;

procedure TMainForm.AboutButtonClick(Sender: TObject);
begin
     About.ShowModal;
end;

procedure TMainForm.SpeedButton2Click(Sender: TObject);
var
   I,TopIndex:Integer;
begin
     ListBox3.Items.BeginUpdate;
     ListBox4.Items.BeginUpdate;
     try
        Modified:=True;
        TopIndex:=ListBox3.TopIndex;
        for i:=0 to ListBox3.Items.Count-1 do
        begin
           if ListBox3.Selected[I] then
           begin
              ListBox4.Items[I]:=ListBox3.Items[I];
              OutputStrings.Strings[Integer(ListBox3.Items.Objects[I])]:=ListBox3.Items[I];
           end;
        end;
     finally
        ListBox3.Items.EndUpdate;
        ListBox4.Items.EndUpdate;
        if (ListBox3.ItemIndex >= 0) and ( ListBox3.SelCount = 1) then
        begin
            DStringLabel.Caption:=ListBox3.Items[ListBox3.ItemIndex];
            DStringEdit.Text    :=ListBox4.Items[ListBox3.ItemIndex];
            PaintBox3.Invalidate;
        end
        else
        begin
            DStringLabel.Caption:=' ';
            DStringEdit.Text    :=' ';
            PaintBox3.Invalidate;
        end;                   
        ListBox3.TopIndex:=TopIndex;
        ListBox4.TopIndex:=ListBox3.TopIndex;
     end;
end;

procedure TMainForm.DrawLabel(TheCanvas:TCanvas;Str:String;X,Y,fg,bg:Integer);
var
   I,Offset:Integer;
   Name1,Name2 : array[0..255] of Char;
begin
    SplitString(PChar(Str),@Name2);
    Memo1.Lines.Clear;
    Memo1.Lines.Add(Name2);
    Offset:=X;
    TheCanvas.Font.Color := fg;
    for i:=0 to Memo1.Lines.Count-1 do           
    begin
       TheCanvas.TextOut(Offset,Y,Memo1.Lines[I]);
       Offset:=Offset+TheCanvas.TextWidth(Memo1.Lines[I]);
       if TheCanvas.Font.Color = fg then
           TheCanvas.Font.Color:=bg  
       else
           TheCanvas.Font.Color:=fg;
    end;
end;

procedure TMainForm.Label3Paint(Sender: TObject);
begin
   DrawLabel(Label3.Canvas,StringLabel.Caption,0,0,clBlack,clRed);
end;

procedure TMainForm.PaintBox3Paint(Sender: TObject);
begin
   DrawLabel(PaintBox3.Canvas,DStringLabel.Caption,0,0,clBlack,clRed);
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
var
   I:Integer;
begin
    if GenStringList(PChar(InFile1.Text),PChar(InFile2.Text),PChar('IDIALOG.STR'),1) = 1 then 
    begin
       ProgBar.Position:=ProgBar.Position+5;
       Timer1.Interval:=1;
    end
    else
    begin
       GenTransList(PChar(InFile1.Text),PChar(InFile2.Text),PChar('ODIALOG.STR'),PChar(OutDir.Text+Save.LangName.Text+'\'),1);
       ProgBar.Position:=ProgBar.Position+10;
       Timer1.Interval:=0;                 
       InputStrings:=TStringList.Create;       
       OutputStrings:=TStringList.Create; 
       try
          InputStrings.LoadFromFile('IDIALOG.STR');
          OutputStrings.LoadFromFile('ODIALOG.STR');
          ListBox1.Items.BeginUpdate;
          ListBox2.Items.BeginUpdate;
          ListBox1.Clear;
          ListBox2.Clear;
          for I:=0 to InputStrings.Count-1 do
          begin
               if Copy(InputStrings.Strings[I],1,4) = 'S<^>' then
               begin
                  ListBox1.Items.AddObject(InputStrings.Strings[I+1],TObject(I+1));
                  ListBox2.Items.Add(OutputStrings.Strings[I+1]);
               end
               else if Copy(InputStrings.Strings[I],1,4) = 'D<^>' then
               begin
                  ProgBar.Position:=ProgBar.Position+1;
                  DialogList.Items.AddObject(Copy(InputStrings.Strings[I],5,999),TObject(I));
               end;
          end;     
       finally
          ListBox1.Items.EndUpdate;
          ListBox2.Items.EndUpdate;
          ProgBar.Position:=0;
          LPanel.Visible:=False;
       end;                 
    end;         
end;
procedure TMainForm.LanguageComboChange(Sender: TObject);
var
   I:Integer;
begin
     if Modified = True then 
        if SaveCheck.ShowModal = mrCancel then Exit;
     Modified:=False;
     Save.LangName.Text:=LanguageCombo.Text;
     WaitForm.Label1.Caption:='Loading Files from :- ' + OutDir.Text+Save.LangName.Text;
     WaitForm.Timer1.OnTimer:=LoadTimer;
     WaitForm.Timer1.Interval:=2000;
     WaitForm.ShowModal;
     try
        OutputStrings.Clear;       
        OutputStrings.LoadFromFile('ODIALOG.STR');
        ListBox2.Items.BeginUpdate;
        ListBox2.Clear;
        for I:=0 to InputStrings.Count-1 do
        begin
             if Copy(InputStrings.Strings[I],1,4) = 'S<^>' then
             begin
                ListBox2.Items.Add(OutputStrings.Strings[I+1]);
             end
        end;     
     finally
        ListBox2.Items.EndUpdate;
     end;                 
end;

procedure TMainForm.DialogListDblClick(Sender: TObject);
var
   I,TopIndex:Integer;
begin
     DialogListClick(Sender);
     
     ListBox3.Items.BeginUpdate;
     ListBox4.Items.BeginUpdate;
     try
        Modified:=True;
        TopIndex:=ListBox3.TopIndex;
        for i:=0 to ListBox3.Items.Count-1 do
        begin
           ListBox4.Items[I]:=ListBox3.Items[I];
           OutputStrings.Strings[Integer(ListBox3.Items.Objects[I])]:=ListBox3.Items[I];
        end;
     finally
        ListBox3.Items.EndUpdate;
        ListBox4.Items.EndUpdate;
        if (ListBox3.ItemIndex >= 0) and ( ListBox3.SelCount = 1) then
        begin
            DStringLabel.Caption:=ListBox3.Items[ListBox3.ItemIndex];
            DStringEdit.Text    :=ListBox4.Items[ListBox3.ItemIndex];
            PaintBox3.Invalidate;
        end
        else
        begin
            DStringLabel.Caption:=' ';
            DStringEdit.Text    :=' ';
            PaintBox3.Invalidate;
        end;                   
        ListBox3.TopIndex:=TopIndex;
        ListBox4.TopIndex:=ListBox3.TopIndex;
     end;
end;

procedure TMainForm.Panel2DblClick(Sender: TObject);
var
   I,TopIndex:Integer;
begin
     ListBox1.Items.BeginUpdate;
     ListBox2.Items.BeginUpdate;
     Modified:=True;
     try
        TopIndex:=ListBox1.TopIndex;
        for i:=0 to ListBox1.Items.Count-1 do
        begin
           ListBox2.Items[I]:=ListBox1.Items[I];
           OutputStrings.Strings[Integer(ListBox1.Items.Objects[I])]:=ListBox1.Items[I];
        end;                             
     finally
        ListBox1.Items.EndUpdate;
        ListBox2.Items.EndUpdate;
        if (ListBox1.ItemIndex >= 0) and ( ListBox1.SelCount = 1) then
        begin
            StringLabel.Caption:=ListBox1.Items[ListBox1.ItemIndex];
            StringEdit.Text    :=ListBox2.Items[ListBox1.ItemIndex];
            Label3.Invalidate;
        end            
        else
        begin
            StringLabel.Caption:=' ';
            StringEdit.Text    :=' ';
            Label3.Invalidate;
        end;                   
        ListBox1.TopIndex:=TopIndex;
        ListBox2.TopIndex:=ListBox1.TopIndex;
     end;
end;             

procedure TMainForm.Button1Click(Sender: TObject);
begin
    FontDialog1.Font:=Button1.Font;
    if FontDialog1.Execute then
    begin
        Button1.Caption:=FontDialog1.Font.Name;
        Button1.Font:=FontDialog1.Font;
    end
end;

end.
 
