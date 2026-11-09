unit TryForm1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ComCtrls, Buttons, StdCtrls, Tabs, DBTables, DB;

type
  TFormFunc = function(Name:PChar) : TForm;

  TForm1 = class(TForm)
    ButPanel: TPanel;
    GroupPanel: TPanel;
    FillPanel: TPanel;
    Panel1: TPanel;
    PressPanel: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel2: TPanel;
    FastPanel: TPanel;
    Panel5: TPanel;
    SelPanel: TPanel;
    Panel6: TPanel;
    FuncKey: TPanel;
    Panel7: TPanel;
    Panel9: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel13: TPanel;
    StatusBar1: TStatusBar;
    Panel8: TPanel;
    Panel14: TPanel;
    OfferMemo: TMemo;
    ProdImage: TImage;
    Panel16: TPanel;
    Panel17: TPanel;
    TotalPanel: TPanel;
    PromptMemo: TMemo;
    TxLogPanel: TPanel;
    WorkOuter: TPanel;
    TitlePanel: TPanel;
    WorkWindow: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    SpeedButton12: TSpeedButton;
    GroupTab: TTable;
    GroupTabGROUP: TSmallintField;
    GroupTabLANGUAGE: TSmallintField;
    GroupTabNAME: TStringField;
    GroupTabKEY: TStringField;
    GroupTabCOLOUR: TIntegerField;
    GroupMapTab: TTable;
    GroupMapTabGROUP: TSmallintField;
    GroupMapTabLANGUAGE: TSmallintField;
    GroupMapTabPLU: TIntegerField;
    GroupMapTabKEYPOS: TSmallintField;
    FormTab: TTable;
    FormTabPLU: TIntegerField;
    FormTabLANGUAGE: TSmallintField;
    FormTabTITLE: TStringField;
    FormTabSHORTDESC: TStringField;
    FormTabPICTURE: TGraphicField;
    FormTabICON: TGraphicField;
    FormTabFORMNAME: TStringField;
    FormTabFORMLIB: TStringField;
    Edit1: TEdit;
    BitBtn1: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    LibrarysLoaded:TStringList;
    FormsLoaded:TStringList;
    procedure PanelBClick(Sender: TObject);
    procedure BClick(Sender: TObject);
    function  GetColour(Text:String): TColor;
    procedure LoadForm(Name,Lib:String;Panel:Tpanel);
  public  
    { Public declarations }
  end;

var
  Form1: TForm1;


implementation

{$R *.DFM}

procedure TForm1.LoadForm(Name,Lib:String;Panel:Tpanel);
var
   Form:TForm;
   P,Q:TPoint;
   Index:Integer;
   Handle:THandle;
   FarProc:TFarProc;
begin
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
          Form.Show;
      end;
   end;
end;

procedure TForm1.BClick(Sender: TObject);
var
   PLUFound:Boolean;
   FormName,FormLib:String;
begin              
   PLUFound:=False;
   FormName:='';
   FormLib :='';
   FormTab.Open;
   FormTab.First;
   While FormTab.EOF <> True  do
   begin
      if (FormTabLANGUAGE.Value = 0) and (FormTabPLU.Value = (Sender as TBitBtn).HelpContext) then
      begin
         PLUFound:=True;
         ProdImage.Picture.Bitmap.Assign(FormTabPICTURE);
         FormName:=FormTabFORMNAME.Value;
         FormLib :=FormTabFORMLIB.Value;
      end;
      FormTab.Next;
   end;
   FormTab.Close;
   
   if PLUFound = False then 
      ProdImage.Picture.Bitmap.Assign((Sender as TBitBtn).Glyph);
      
   if (Sender as TBitBtn).Hint = '' then
      TitlePanel.Caption:=(Sender as TBitBtn).Caption
   else
      TitlePanel.Caption:=(Sender as TBitBtn).Hint;

    LoadForm(FormName,FormLib,WorkWindow);
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

procedure TForm1.FormCreate(Sender: TObject);
var
   Panel1:TPanel;
   Panel2:TPanel;
   I,J:Integer;
   R,G,B:Integer;
   TabSheet:TTabSheet;
   BitBtn:TBitBtn;
   FileStream:TFileStream;
   TestForm:TForm;
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

    
    for I:=1 to 10 do
    begin
       Panel1:=TPanel.Create(Self);
       FuncKey.InsertControl(Panel1);
       Panel1.Align:=alTop;
       Panel1.Height:=4;
       Panel1.BevelOuter:=bvNone;
       Panel1:=TPanel.Create(Self);
       FuncKey.InsertControl(Panel1);
       Panel1.Align:=alTop;
       Panel1.Height:=64;
       Panel1.BevelWidth:=1;
       Panel1.BevelOuter:=bvLowered;
       Panel1.Caption:='F'+IntToStr(I);
    end;
    
    Panel1:=TPanel.Create(Self);
    GroupPanel.InsertControl(Panel1);
    Panel1.Align:=alTop;
    Panel1.Height:=10;
    Panel1.BevelWidth:=2;
                        
    for J:=0 to 9 do
    begin
       BitBtn:=TBitBtn.Create(Self);
       FastPanel.InsertControl(BitBtn);
       BitBtn.Left:=1;
       BitBtn.Top:=4 + J * 68;
       BitBtn.Width:=64;
       BitBtn.Height:=64;
       BitBtn.Layout:=blGlyphTop;
       BitBtn.TabStop:=False;
//       BitBtn.Enabled:=False;
       BitBtn.OnClick:=BClick;
       if J = 0 then
       begin
          BitBtn.Glyph.LoadFromFile('g:\UI\images\1Letter.bmp');
          BitBtn.Caption:='1st Class';
       end                                                      
       else if J = 1 then
       begin
          BitBtn.Glyph.LoadFromFile('g:\UI\images\Franking.bmp');
          BitBtn.Caption:='2nd Class';
       end                           
       else if J = 2 then
       begin
          BitBtn.Glyph.LoadFromFile('g:\UI\images\ALetter.bmp');
          BitBtn.Caption:='Air Mail';
       end                    
       else if J = 3 then
       begin
          BitBtn.Glyph.LoadFromFile('g:\UI\images\RLetter.bmp');
          BitBtn.Caption:='Registered';
       end                         
       else if J = 4 then
       begin
          BitBtn.Glyph.LoadFromFile('g:\UI\images\ILetter.bmp');
          BitBtn.Caption:='Insured';
       end                           
       else if J = 5 then
       begin
          BitBtn.Glyph.LoadFromFile('g:\UI\images\ELetter.bmp');
          BitBtn.Caption:='E.M.S.';
       end                           
       else if J = 6 then
       begin
          BitBtn.Glyph.LoadFromFile('g:\UI\images\1Stamp.bmp');
          BitBtn.Caption:='1st Class';
       end                           
       else if J = 7 then
       begin
          BitBtn.Glyph.LoadFromFile('g:\UI\images\2Stamp.bmp');
          BitBtn.Caption:='2nd Class';
       end                           
       else if J = 8 then
       begin
          BitBtn.Glyph.LoadFromFile('g:\UI\images\MStamp.bmp');
          BitBtn.Caption:='Philatelic';
       end                           
       else         
       begin
          BitBtn.Caption:='Button ' + IntToStr(J);
          BitBtn.Enabled:=False;
       end;
//       BitBtn.Caption:='F' + IntToStr(J+1);
    end;                                           
end;                                   

procedure TForm1.FormDestroy(Sender: TObject);
var
   Index:Integer;
begin
    for Index:=0 to LibrarysLoaded.Count-1 do
        FreeLibrary(THandle(LibrarysLoaded.Objects[Index]));
end;

end.
 


