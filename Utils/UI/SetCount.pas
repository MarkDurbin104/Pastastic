unit SetCount;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBTables, DB, ExtCtrls, StdCtrls, Buttons, Menus, ComCtrls, Language,
  FileCtrl;

type
  TFormFunc = function(Name:PChar) : TForm;
  TPLURec = record
     Icon     : TBitMap;
     PLU      : Integer;
     Language : Integer;
     Title    : String;
     Picture  : TBitMap;
     Formname : String;
     Formlib  : String;
  end;
  PPLURec = ^TPLURec;
  
  TForm1 = class(TForm)
    ButPanel: TPanel;
    GroupPanel: TPanel;
    FillPanel: TPanel;
    Panel1: TPanel;
    PressPanel: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    SelPanel: TPanel;
    Panel6: TPanel;
    FormTab: TTable;
    FormTabPLU: TIntegerField;
    FormTabLANGUAGE: TSmallintField;
    FormTabTITLE: TStringField;
    FormTabSHORTDESC: TStringField;
    FormTabPICTURE: TGraphicField;
    FormTabICON: TGraphicField;
    FormTabFORMNAME: TStringField;
    FormTabFORMLIB: TStringField;
    GroupMapTab: TTable;
    GroupMapTabGROUP: TSmallintField;
    GroupMapTabLANGUAGE: TSmallintField;
    GroupMapTabPLU: TIntegerField;
    GroupMapTabKEYPOS: TSmallintField;
    GroupTab: TTable;
    GroupTabGROUP: TSmallintField;
    GroupTabLANGUAGE: TSmallintField;
    GroupTabNAME: TStringField;
    GroupTabKEY: TStringField;
    GroupTabCOLOUR: TIntegerField;
    ButtonPopup: TPopupMenu;
    GroupPopup: TPopupMenu;
    ChangeColour1: TMenuItem;
    AddGroup1: TMenuItem;
    N1: TMenuItem;
    ChangeName1: TMenuItem;
    CahngeName1: TMenuItem;
    ColorDialog1: TColorDialog;
    Panel2: TPanel;
    Delete1: TMenuItem;
    Panel8: TPanel;
    PLUList: TListBox;
    Panel7: TPanel;
    Panel9: TPanel;
    PictImage: TImage;
    IconImage: TImage;
    Label5: TLabel;
    FormEdit: TEdit;
    Label6: TLabel;
    LibEdit: TEdit;
    DescEdit: TEdit;
    TitleEdit: TEdit;
    LangEdit: TEdit;
    Label2: TLabel;
    PLUEdit: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Panel11: TPanel;
    FormPanel: TPanel;
    Panel10: TPanel;
    Panel12: TPanel;
    FileListBox1: TFileListBox;
    DirectoryListBox1: TDirectoryListBox;
    DriveComboBox1: TDriveComboBox;
    Panel13: TPanel;
    QImage: TImage;
    procedure FormCreate(Sender: TObject);
    procedure ChangeColour1Click(Sender: TObject);
    procedure PLUListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure PLUListClick(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure FormPanelResize(Sender: TObject);
    procedure PLUEditExit(Sender: TObject);
    procedure TitleEditExit(Sender: TObject);
    procedure DescEditExit(Sender: TObject);
    procedure FormEditExit(Sender: TObject);
    procedure LibEditExit(Sender: TObject);
    procedure LangEditExit(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure DirectoryListBox1Change(Sender: TObject);
    procedure DriveComboBox1Change(Sender: TObject);
    procedure IconImageDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure IconImageDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FileListBox1Change(Sender: TObject);
  private
    { Private declarations }
    LibrarysLoaded:TStringList;
    FormsLoaded:TStringList;
    function GetColour(Text:String): TColor;
    procedure BClick(Sender: TObject);
    procedure PanelBClick(Sender: TObject);
    procedure LoadForm(Name,Lib:String;Panel:TPanel);
    procedure PanelDragOver(Sender, Source: TObject; X, Y: Integer;
              State: TDragState; var Accept: Boolean);
    procedure PanelDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure UpdateButtons(PLU,Title,Desc:String;Index:Integer;BitMap:TBitMap);
    
  public                                  
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.UpdateButtons(PLU,Title,Desc:String;Index:Integer;BitMap:TBitMap);
var
   I,J:Integer;
begin
    for I:=0 to SelPanel.ControlCount-1 do
    begin
       if SelPanel.Controls[I] is Tpanel then
       begin
          for J:=0 to (SelPanel.Controls[I] as Tpanel).ControlCount-1 do
          begin
             if (SelPanel.Controls[I] as Tpanel).Controls[J] is TBitBtn then
             begin
                if (((SelPanel.Controls[I] as Tpanel).Controls[J] as TBitBtn).Caption = PLUList.Items[Index])
                   and (PPLURec(PLUList.Items.Objects[Index])^.PLU = ((SelPanel.Controls[I] as Tpanel).Controls[J] as TBitBtn).HelpContext) then
                begin
                   ((SelPanel.Controls[I] as Tpanel).Controls[J] as TBitBtn).Caption:=Desc;
                   ((SelPanel.Controls[I] as Tpanel).Controls[J] as TBitBtn).Hint:=Title;
                   ((SelPanel.Controls[I] as Tpanel).Controls[J] as TBitBtn).HelpContext:=StrToInt(PLU);
                   ((SelPanel.Controls[I] as Tpanel).Controls[J] as TBitBtn).Glyph.Assign(BitMap);
                end;
             end;  
          end;  
       end;  
    end;    
end;
procedure TForm1.BClick(Sender: TObject);
var
   Index:Integer;
begin              
   for Index:=0 to PLUList.Items.Count -1 do
   begin
      if ((Sender as TBitBtn).Caption = PLUList.Items[Index]) and
         ((Sender as TBitBtn).HelpContext = PPLURec(PLUList.Items.Objects[Index])^.PLU) then
      begin
          PLUList.ItemIndex:=Index;
          PLUListClick(Self);
          Exit;
      end;
   end;    
end;
procedure TForm1.PanelBClick(Sender: TObject);
var
   I:Integer;
begin
    for I:=0 to GroupPanel.ControlCount-1 do
    begin
         if GroupPanel.Controls[I] is Tpanel then
         begin
            with (GroupPanel.Controls[I] as Tpanel) do
            begin
               if (Align = alTop) and (Caption <> '') then
               begin
                  BevelOuter:=bvRaised;
               end;                             
            end;                             
         end;
    end;    
    (Sender as TPanel).BevelOuter:=bvNone;
    for I:=0 to SelPanel.ControlCount-1 do
    begin
         if SelPanel.Controls[I] is Tpanel then
         begin
            if (SelPanel.Controls[I] as Tpanel).HelpContext = (Sender as TPanel).HelpContext then
            begin
               (SelPanel.Controls[I] as Tpanel).Visible:=True;
               (SelPanel.Controls[I] as Tpanel).Color := (Sender as TPanel).Color;
            end
            else
            begin
               (SelPanel.Controls[I] as Tpanel).Visible:=False;
            end;
         end;  
    end;    
end;

function TForm1.GetColour(Text:String): TColor;
var
  R,G,B:Integer;
  C:LongInt;
begin
   if Text <> '' then
   begin
      C:=StrToInt(Text);
      B:=(C shr 16) and $FF;
      G:=(C shr 8)  and $FF;
      R:= C         and $FF;
   end
   else
      result:=rgb(192,192,192);
      
   result:=rgb(R,G,B);
end;

procedure TForm1.PanelDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if Source = PLUList then
    Accept := True;
end;
procedure TForm1.PanelDragDrop(Sender, Source: TObject; X, Y: Integer);
var
   BitBtn:TBitBtn;
begin
  if Source = PLUList then
  begin
     if (Sender is TBitBtn) then
     begin
         (Sender as TBitBtn).Glyph.Assign(PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.Icon);
         (Sender as TBitBtn).Caption:=PLUList.Items[PLUList.ItemIndex];
         (Sender as TBitBtn).Hint:=PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.Title;
         (Sender as TBitBtn).HelpContext:=PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.PLU;
     end
     else
     begin
        BitBtn:=TBitBtn.Create(Self);
        (Sender as TPanel).InsertControl(BitBtn);
        BitBtn.OnDragOver:=PanelDragOver;
        BitBtn.OnDragDrop:=PanelDragDrop;
        BitBtn.PopupMenu:=ButtonPopup;
        BitBtn.OnClick:=BClick;
        BitBtn.Left:=((((X-(Sender as TPanel).Left)-4) div 68)*68)+4;
        BitBtn.Top :=((((Y-(Sender as TPanel).Top )-4) div 68)*68)+4;
        BitBtn.Width:=64;
        BitBtn.Height:=64;
        BitBtn.TabStop:=False;
        BitBtn.Layout:=blGlyphTop;
        BitBtn.Glyph.Assign(PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.Icon);
        BitBtn.Caption:=PLUList.Items[PLUList.ItemIndex];
        BitBtn.Hint:=PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.Title;
        BitBtn.HelpContext:=PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.PLU;
     end;
  end;
end;
procedure TForm1.FormCreate(Sender: TObject);
var
   Panel1:TPanel;
   Panel2:TPanel;
   I,J:Integer;
   R,G,B:Integer;
   FileStream:TFileStream;
   TestForm:TForm;
   BitBtn:TBitBtn;
   Rect:TRect;
   PLURec:PPLURec;
begin
    LibrarysLoaded:=TStringList.Create;
    FormsLoaded:=TStringList.Create;
    Width:=1024;
    Height:=768;
    SelPanel.Height:=10*68 +4;
    ButPanel.Width:=3*68 + 4 + 32 + 71;
    GroupTab.Open;
    GroupTab.First;
    While GroupTab.EOF <> True do
    begin
       if GroupTabLANGUAGE.Value = 0 then
       begin
          Panel1:=TPanel.Create(Self);
          PressPanel.InsertControl(Panel1);
          Panel1.Align:=alTop;
          Panel1.Height:=32;
          Panel1.BevelOuter:=bvLowered;
          Panel1.BevelWidth:=1;
          Panel1.Caption:=GroupTabKEY.Value;
            
          Panel1:=TPanel.Create(Self);
          GroupPanel.InsertControl(Panel1);
          Panel1.Align:=alTop;
          Panel1.Height:=32;
          Panel1.HelpContext:=GroupTabGROUP.Value;
          Panel1.Color:=GetColour(IntToStr(GroupTabCOLOUR.Value));
          Panel1.PopupMenu:=GroupPopup;
          Panel1.Caption:=GroupTabNAME.Value;
          Panel1.OnClick:=PanelBClick;
          Panel1.BevelWidth:=2;
          
          Panel2:=TPanel.Create(Self);
          SelPanel.InsertControl(Panel2);
          Panel2.Align:=alClient;
          Panel2.HelpContext:=GroupTabGROUP.Value;
          Panel2.BevelOuter:=bvNone;
          Panel2.BevelInner:=bvNone;
          Panel2.Visible:=False;
          Panel2.PopupMenu:=GroupPopup;
          Panel2.OnDragOver:=PanelDragOver;
          Panel2.OnDragDrop:=PanelDragDrop;
          
          GroupMapTab.Open;
          GroupMapTab.First;
          While GroupMapTab.EOF <> True  do
          begin
              if (Panel1.HelpContext = GroupMapTabGROUP.Value) and (GroupMapTabLANGUAGE.Value = 0) then
              begin
                  FormTab.Open;
                  FormTab.First;
                  While FormTab.EOF <> True  do
                  begin
                     if (FormTabLANGUAGE.Value = 0) and (FormTabPLU.Value = GroupMapTabPLU.Value) then
                     begin
                        BitBtn:=TBitBtn.Create(Self);
                        Panel2.InsertControl(BitBtn);
                        BitBtn.OnDragOver:=PanelDragOver;
                        BitBtn.OnDragDrop:=PanelDragDrop;
                        BitBtn.PopupMenu:=ButtonPopup;
                        BitBtn.OnClick:=BClick;
                        BitBtn.Left:=4 + (GroupMapTabKEYPOS.Value div 10) * 68;
                        BitBtn.Top :=4 + (GroupMapTabKEYPOS.Value mod 10) * 68;
                        BitBtn.Width:=64;
                        BitBtn.Height:=64;
                        BitBtn.TabStop:=False;
                        BitBtn.Layout:=blGlyphTop;
                        BitBtn.Glyph.Assign(FormTabICON);
                        BitBtn.Caption:=FormTabSHORTDESC.Value;
                        BitBtn.Hint:=FormTabTITLE.Value;
                        BitBtn.HelpContext:=FormTabPLU.Value;
                     end;
                     FormTab.Next;
                  end;
                  FormTab.Close;
              end;
              GroupMapTab.Next;
          end;    
          GroupMapTab.Close;
          GroupTab.Next;
       end;    
       if GroupTabGROUP.Value = 1 then PanelBClick(Panel1);
    end;    
    GroupTab.Close;
    
    PLUList.Clear;
    FormTab.Open;
    FormTab.First;
    While FormTab.EOF <> True  do
    begin
       PLURec:=new(PPLURec);
       PLURec^.Icon:=TBitMap.Create;
       PLURec^.Icon.Assign(FormTabICON);
       PLURec^.PLU     :=FormTabPLU.Value;
       PLURec^.Language:=FormTabLANGUAGE.Value;
       PLURec^.Title   :=FormTabTITLE.Value;
       PLURec^.Picture :=TBitMap.Create;
       PLURec^.Picture.Assign(FormTabPICTURE);
       PLURec^.Formname:=FormTabFORMNAME.Value;
       PLURec^.Formlib :=FormTabFORMLIB.Value;
       PLUList.Items.AddObject(FormTabSHORTDESC.Value,TObject(PLURec));
       FormTab.Next;
    end;
    FormTab.Close;
    
    Panel1:=TPanel.Create(Self);
    GroupPanel.InsertControl(Panel1);
    Panel1.Align:=alTop;
    Panel1.Height:=10;
    Panel1.BevelWidth:=2;
    
    if PLUList.Items.Count > 0 then 
    begin
       PLUList.ItemIndex:=0;
       PLUListClick(Self);
    end;
end;                                   

procedure TForm1.ChangeColour1Click(Sender: TObject);
var
   I,G:Integer;
   Found:Boolean;
   Panel:TPanel;
   ThePanel:TPanel;
begin
    Found:=False;
    ColorDialog1.Color:=(GroupPopup.PopupComponent as Tpanel).Color;
    if ColorDialog1.Execute then
    begin
       Panel:=(GroupPopup.PopupComponent as Tpanel);
       G:=Panel.HelpContext;
       Panel.Color:=ColorDialog1.Color;
       for I:=0 to SelPanel.ControlCount-1 do
       begin
            if (SelPanel.Controls[I] is Tpanel) then
            begin
               ThePanel:=(SelPanel.Controls[I] as Tpanel);
               if (ThePanel.HelpContext = G) and (Panel <> ThePanel) then
               begin
                  ThePanel.Color := ColorDialog1.Color;
                  Found:=True;
               end;
            end;  
       end;    
       if not Found then
       begin
          for I:=0 to GroupPanel.ControlCount-1 do
          begin
             if GroupPanel.Controls[I] is Tpanel then
             begin
                ThePanel:=(GroupPanel.Controls[I] as Tpanel);
                if (ThePanel.HelpContext = G) and (ThePanel.Caption <> '') and (Panel <> ThePanel) then
                begin
                   ThePanel.Color := ColorDialog1.Color;
                end;
             end;  
          end;    
       end;
    end;
end;

procedure TForm1.PLUListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
   BitMap:TBitMap;
   r1,r2:TRect;
   ih,Topofs,Th:Integer;
begin
    ih:=(Control as TListBox).ItemHeight;
    BitMap:=PPLURec((Control as TListBox).Items.Objects[Index])^.Icon;
    r1.Top   :=0;
    r1.Left  :=0;
    r1.Bottom:=BitMap.Height;
    r1.Right :=BitMap.Width;
    r2.Top   :=Rect.Top + 2;
    r2.Left  :=Rect.Left+(ih-BitMap.Width ) div 2;
    r2.Bottom:=r2.Top +BitMap.Height;
    r2.Right :=r2.Left+BitMap.Width;
    with (Control as TListBox).Canvas do
    begin
       FillRect(Rect);
       Topofs:=2;
       Th:=TextHeight('8gPy')+1;
       TextOut(ih+2,Rect.Top+Topofs,PPLURec((Control as TListBox).Items.Objects[Index])^.Title);
       Inc(Topofs,Th);
       TextOut(ih+2,Rect.Top+Topofs,'PLU ' + IntToStr(PPLURec((Control as TListBox).Items.Objects[Index])^.PLU));
       Inc(Topofs,Th);
       TextOut(ih+2,Rect.Top+Topofs,'Language ' + IntToStr(PPLURec((Control as TListBox).Items.Objects[Index])^.Language));
       Inc(Topofs,Th);
       if PPLURec((Control as TListBox).Items.Objects[Index])^.FormName <> '' then
       TextOut(ih+2,Rect.Top+Topofs,
                PPLURec((Control as TListBox).Items.Objects[Index])^.FormName + ' - ' +
                PPLURec((Control as TListBox).Items.Objects[Index])^.FormLib);
       Brush.Color:=clSilver;
       Brush.Style:=bsSolid;
       Pen.Color:=clSilver;
       Rectangle(Rect.Left+1,Rect.Top+1,Rect.Left+(ih-2),Rect.Top+(ih-2));
       CopyRect(r2,Bitmap.Canvas,r1);
       r2.Left  :=Rect.Left+((Control as TListBox).ItemHeight-TextWidth((Control as TListBox).Items[Index]) ) div 2;
       Font.Color:=clBlack;
       TextOut(r2.Left,r2.Bottom,(Control as TListBox).Items[Index]);
    end;
end;

procedure TForm1.LoadForm(Name,Lib:String;Panel:TPanel);
var
   Form:TForm;
   P,Q:TPoint;
   Index:Integer;
   Handle:THandle;
   FarProc:TFarProc;
begin
   For Index:=0 to FormsLoaded.Count-1 do
       TForm(FormsLoaded.Objects[Index]).Hide;
       
   if Name <> '' then
   begin
      Index:=LibrarysLoaded.IndexOf(Lib);
      if Index = -1 then
      begin
          Handle:=LoadLibrary(PChar(Lib));
          LibrarysLoaded.AddObject(Lib,TObject(Handle));
      end
      else 
      begin
          Handle:=THandle(LibrarysLoaded.Objects[Index]);
      end;
      Index:=FormsLoaded.IndexOf(Lib + '*' + Name);
      if Index = -1 then
      begin
          FarProc:=GetProcAddress(Handle,'CreateForm');
          if FarProc <> nil then
          begin
             Form:=(TFormFunc(FarProc)(PChar(Name)));
             if Form <> nil then
             begin
                Q.X:=0;
                Q.Y:=0;
                P:=Panel.ClientToScreen(Q);
                Form.Left  :=P.X+1;
                Form.Top   :=P.Y+1;
                Form.Height:=Panel.Height-2;
                Form.Width :=Panel.Width -2;
                FormsLoaded.AddObject(Lib + '*' + Name,TObject(Form));
                Form.Show;
             end;
          end;      
      end
      else 
      begin
          Form:=TForm(FormsLoaded.Objects[Index]);
          Q.X:=0;                           
          Q.Y:=0;
          P:=Panel.ClientToScreen(Q);
          Form.Left  :=P.X+1;
          Form.Top   :=P.Y+1;
          Form.Height:=Panel.Height-2;
          Form.Width :=Panel.Width -2;
          Form.Show;
//          FormImage.Picture.Bitmap.Assign(Form.GetFormImage);
      end;
   end;
end;

procedure TForm1.PLUListClick(Sender: TObject);
begin
   if PLUList.ItemIndex >= 0 then
   begin
      IconImage.Picture.BitMap.Assign(PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.Icon);
      PictImage.Picture.BitMap.Assign(PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.Picture);
      PLUEdit  .Text:=IntToStr(PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.PLU);
      LangEdit .Text:=IntToStr(PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.Language);
      TitleEdit.Text:=PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.Title;
      DescEdit .Text:=PLUList.Items[PLUList.ItemIndex];
      FormEdit .Text:=PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.FormName;
      LibEdit  .Text:=PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.FormLib;
      LoadForm(FormEdit.Text,LibEdit.Text,FormPanel);
   end;
end;

procedure TForm1.Delete1Click(Sender: TObject);
begin
    (ButtonPopup.PopupComponent as TBitBtn).Free;
end;

procedure TForm1.FormPanelResize(Sender: TObject);
begin
    LoadForm(FormEdit.Text,LibEdit.Text,FormPanel)
end;

procedure TForm1.PLUEditExit(Sender: TObject);
begin
   if PLUList.ItemIndex >= 0 then
   begin
      UpdateButtons(PLUEdit.Text,TitleEdit.Text,DescEdit.Text,PLUList.ItemIndex,IconImage.Picture.BitMap);
      PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.PLU:=StrToInt(PLUEdit.Text);
      PLUList.Invalidate;
   end;
end;

procedure TForm1.TitleEditExit(Sender: TObject);
begin
   if PLUList.ItemIndex >= 0 then
   begin
      UpdateButtons(PLUEdit.Text,TitleEdit.Text,DescEdit.Text,PLUList.ItemIndex,IconImage.Picture.BitMap);
      PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.Title:=TitleEdit.Text;
      PLUList.Invalidate;
   end;
end;

procedure TForm1.DescEditExit(Sender: TObject);
begin
   if PLUList.ItemIndex >= 0 then
   begin
      UpdateButtons(PLUEdit.Text,TitleEdit.Text,DescEdit.Text,PLUList.ItemIndex,IconImage.Picture.BitMap);
      PLUList.Items[PLUList.ItemIndex]:=DescEdit.Text;
      PLUList.Invalidate;
   end;
end;

procedure TForm1.FormEditExit(Sender: TObject);
begin
   if PLUList.ItemIndex >= 0 then
   begin
      PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.FormName:=FormEdit.Text;
      LoadForm(FormEdit.Text,LibEdit.Text,FormPanel);
      PLUList.Invalidate;
   end;
end;

procedure TForm1.LibEditExit(Sender: TObject);
begin
   if PLUList.ItemIndex >= 0 then
   begin
      PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.FormName:=LibEdit.Text;
      LoadForm(FormEdit.Text,LibEdit.Text,FormPanel);
      PLUList.Invalidate;
   end;
end;

procedure TForm1.LangEditExit(Sender: TObject);
begin
   if PLUList.ItemIndex >= 0 then
   begin
      PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.Language:=StrToInt(LangEdit.Text);
      PLUList.Invalidate;
   end;
end;
procedure TForm1.FormHide(Sender: TObject);
var
   Index:Integer;
begin
   For Index:=0 to FormsLoaded.Count-1 do
       TForm(FormsLoaded.Objects[Index]).Hide;
end;

procedure TForm1.DirectoryListBox1Change(Sender: TObject);
begin
   FileListBox1.Directory:=DirectoryListBox1.Directory;
end;

procedure TForm1.DriveComboBox1Change(Sender: TObject);
begin
   DirectoryListBox1.Drive:=DriveComboBox1.Drive;
end;

procedure TForm1.IconImageDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
    if Source = FileListBox1 then Accept:=True;
end;

procedure TForm1.IconImageDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
    if Source = FileListBox1 then 
    begin
       if Sender = PictImage then
       begin
          PictImage.Picture.BitMap.LoadFromFile(FileListBox1.FileName);
          PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.Picture.Assign(PictImage.Picture.BitMap);
       end
       else
       begin
          IconImage.Picture.BitMap.LoadFromFile(FileListBox1.FileName);
          PPLURec(PLUList.Items.Objects[PLUList.ItemIndex])^.Icon.Assign(IconImage.Picture.BitMap);
          UpdateButtons(PLUEdit.Text,TitleEdit.Text,DescEdit.Text,PLUList.ItemIndex,IconImage.Picture.BitMap);
          PLUList.Invalidate;
       end;
    end;
end;

procedure TForm1.FileListBox1Change(Sender: TObject);
begin
   if FileListBox1.FileName <> '' then
      QImage.Picture.BitMap.LoadFromFile(FileListBox1.FileName);
end;

end.
 