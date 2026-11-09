unit setform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, DB, DBTables, DBCtrls, Mask,
  Grids, DBGrids, Language;

type

  TFormFunc = function(Name:PChar) : TForm;

  TForm1 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    DBGrid1: TDBGrid;
    Table1: TTable;
    DataSource1: TDataSource;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    DBNavigator1: TDBNavigator;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    DBEdit4: TDBEdit;
    DBEdit5: TDBEdit;
    DBEdit6: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    DBImage1: TDBImage;
    DBImage2: TDBImage;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    OpenDialog1: TOpenDialog;
    TestBtn: TBitBtn;
    Timer1: TTimer;
    testBtn2: TBitBtn;
    Label9: TLabel;
    Label10: TLabel;
    Bevel1: TBevel;
    DBText1: TDBText;
    DBGrid2: TDBGrid;
    Table2: TTable;
    DataSource2: TDataSource;
    ColorDialog1: TColorDialog;
    DBColour: TDBEdit;
    Button1: TPanel;
    DBNavigator2: TDBNavigator;
    Table3: TTable;
    DataSource3: TDataSource;
    DBGrid3: TDBGrid;
    DBNavigator3: TDBNavigator;
    Panel1: TPanel;
    FormList: TListBox;
    DLLList: TListBox;
    Image1: TImage;
    LangSwitch1: TLangSwitch;
    procedure BitBtn1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure DBColourChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DLLListClick(Sender: TObject);
    procedure FormListClick(Sender: TObject);
    procedure TestBtnClick(Sender: TObject);
  private
    { Private declarations }
    FormsList:TStringList;     
  public
    { Public declarations }
  end;

var
  Form1: TForm1;


procedure CreateFormList(FileName:PChar) stdcall; external 'COUNTERS';
implementation

{$R *.DFM}

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
    if sender = BitBtn1 then
    begin
       if OpenDialog1.Execute then
       begin
          DBImage1.Picture.LoadFromFile(OpenDialog1.FileName);
          TestBtn.Glyph.Assign(DBImage1.Picture.Bitmap);
          TestBtn2.Glyph.Assign(DBImage1.Picture.Bitmap);
       end;
    end
    else if sender = BitBtn2 then
    begin
       if OpenDialog1.Execute then
           DBImage2.Picture.LoadFromFile(OpenDialog1.FileName);
    end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
   if TestBtn.Caption <> DBEdit4.Text then
   begin
      if DBImage1.Picture.Bitmap <> nil then
      begin
         TestBtn.Glyph.Assign(DBImage1.Picture.Bitmap);
         TestBtn2.Glyph.Assign(DBImage1.Picture.Bitmap);
      end;
      TestBtn.Caption:=DBEdit4.Text;
      TestBtn2.Caption:=DBEdit4.Text;
   end;           
end;
function GetColour(Text:String): TColor;
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
procedure TForm1.Button1Click(Sender: TObject);
begin
    if DBColour.Text <> '' then
       ColorDialog1.Color:=GetColour(DBColour.Text);
    if ColorDialog1.Execute then
    begin
       DBColour.Text:=IntToStr(ColorDialog1.Color);
       Button1.Color:=ColorDialog1.Color;
    end;
end;

procedure TForm1.DBColourChange(Sender: TObject);
begin
   ColorDialog1.Color:=GetColour(DBColour.Text);
   Button1.Color:=ColorDialog1.Color;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
   I:Integer;
begin
    FormsList:=TStringList.Create;
    CreateFormList(PChar('FormList.Str'));
    FormsList.LoadFromFile('FormList.Str');
    for I:=0 to FormsList.Count-1 do
    begin
        if (I and 1) = 0 then
        begin
            if DLLList.Items.IndexOf(FormsList[I]) = -1 then
               DLLList.Items.Add(FormsList[I]);
        end;
    end;
    DLLList.ItemIndex:=0;
    DLLListClick(DLLList);
end;

procedure TForm1.DLLListClick(Sender: TObject);
var
   I:Integer;
begin
   if DLLList.ItemIndex <> -1 then
   begin
      FormList.Clear;
      for I:=0 to FormsList.Count-1 do
      begin
          if (I and 1) = 0 then
          begin
             if DLLList.Items[DLLList.ItemIndex] = FormsList[I] then
             begin
                FormList.Items.Add(FormsList[I+1]);
             end
          end;
      end;
   end;
end;

procedure TForm1.FormListClick(Sender: TObject);
var 
   Handle:THandle;
   FormImage: TBitmap;
   FarProc:TFarProc;
   Form:TForm;
   A,I:Real;
   W,H:Real;
begin
   if DLLList.ItemIndex <> -1 then
   begin
      if FormList.ItemIndex <> -1 then
      begin
          Handle:=LoadLibrary(PChar(DLLList.Items[DLLList.ItemIndex]));
          FarProc:=GetProcAddress(Handle,'CreateForm');
          if FarProc <> nil then
          begin
             Form:=(TFormFunc(FarProc)(PChar(FormList.Items[FormList.ItemIndex])));
             if Form <> nil then
             begin
                Form.Left:=0-Form.Width;
                Form.Show;
                FormImage := Form.GetFormImage;
                Image1.Picture.Assign(FormImage);
                FormImage.Free;
                Form.Free;
             end;
          end;      
         
      end;                               
   end;                               
end;

procedure TForm1.TestBtnClick(Sender: TObject);
begin
    LangSwitch1.Language:=LangSwitch1.Language+1;
end;

end.
 