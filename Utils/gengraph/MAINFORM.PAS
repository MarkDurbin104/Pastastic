unit Mainform;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Menus, Printers,About,BTManU, Buttons;

type
  TGGForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    OpenTable1: TMenuItem;
    Print1: TMenuItem;
    PrintPreview1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    Diagram1: TMenuItem;
    BFT1: TMenuItem;
    Help1: TMenuItem;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Label1: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Group: TCheckBox;
    FromTo: TCheckBox;
    ACPs: TCheckBox;
    CrossLines: TRadioButton;
    MixTubes: TRadioButton;
    ListBox1: TListBox;
    OpenDialog1: TOpenDialog;
    ScrollBox1: TScrollBox;
    PaintBox1: TPaintBox;
    About1: TMenuItem;
    SpeedButton1: TSpeedButton;
    TermNap: TCheckBox;
    Primary1: TMenuItem;
    Secondary1: TMenuItem;
    PON1: TMenuItem;
    PopupMenu1: TPopupMenu;
    Force1: TMenuItem;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    procedure Exit1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OpenTable1Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Force1Click(Sender: TObject);
  private
    { Private declarations }
    Setup:Boolean;
    CompList:TStringList;
    function DrawDiag(TheCanvas:TCanvas;Width,Height,XOfs,YOfs:Integer): Boolean;
  public               
    { Public declarations }
  end;

var
  GGForm: TGGForm;

implementation

{$R *.DFM}
procedure Traverse(FeatNumb :String;Group,FromTo:Boolean); far;
          external 'GETDATA';
function  MaxWidth: Integer; far;
          external 'GETDATA';
function  MaxHeight: Integer; far;
          external 'GETDATA';

function TGGForm.DrawDiag(TheCanvas:TCanvas;Width,Height,XOfs,YOfs:Integer): Boolean;
var
   Param  : array[0..7] of Integer;
   SParam : String;
   i,j    : Integer;
   CType  : Integer;
   PCount : Integer;
   ScaleM : Integer;
   ScaleD : Integer;  
   Scale  : Boolean;  
   SomeDat: Boolean;  
begin
   SomeDat:=False;
   with TheCanvas do
   begin
      if (Width <> PaintBox1.Width) or (Height <> PaintBox1.Height) then
      begin
         Scale:=True;
         ScaleM:=5;
         ScaleD:=2;
         Brush.Style:=bsClear;
         Pen.Color:=clBlack;
         Pen.Width:=4;
         Font.Name:='Courier New'; {'Small Fonts'}
         Font.Color:=clBlack; 
         Font.Size:=7;
         Font.Style:=[fsBold];
      end
      else
      begin
         Brush.Style:=bsSolid;
         Pen.Color:=clWhite; 
         Rectangle(0,0,Width,Height);
         Brush.Style:=bsClear;
         Scale:=False;
         Pen.Width:=1;
         Pen.Color:=clBlack;
         Font.Name:='Courier New'; {'Small Fonts'}
         Font.Color:=clBlack; 
         Font.Size:=8;
         Font.Style:=[];
      end;
   end;
   if CompList.Count > 0 then 
   begin
      for i:=0 to CompList.Count-1 do
      begin
         PCount:=0;
         CType:=StrToInt(Copy(CompList.Strings[i],1,1));;
         case CType of                        
            1 : PCount:=4;
            2 : PCount:=4;
            3 : PCount:=2;
            4 : PCount:=4;
            5 : PCount:=8;
            8 : Panel5.Caption:=Copy(CompList.Strings[i],2,999);
         end;
         if PCount > 0 then
         begin
            for j:=0 to PCount-1 do
            begin
               if Scale then
                  Param[j]:=(StrToInt(Copy(CompList.Strings[i],2+j*5,5))*ScaleM) div ScaleD
               else
                  Param[j]:=StrToInt(Copy(CompList.Strings[i],2+j*5,5));
               if not SomeDat then
                  case j of
                     0,2,4 : if (Param[j] > 0) and (Param[j] < Width ) then SomeDat:=True;
                     1,3,5 : if (Param[j] > 0) and (Param[j] < Height) then SomeDat:=True;
                  end;
            end;   
            case CType of
               1 : 
                  TheCanvas.Rectangle(Param[0]-XOfs,Param[1]-YOfs,
                            Param[2]-XOfs,Param[3]-YOfs);
               2 : 
                  begin 
                     TheCanvas.MoveTo(Param[0]-XOfs,Param[1]-YOfs); 
                     TheCanvas.LineTo(Param[2]-XOfs,Param[3]-YOfs); 
                  end;
               3 : 
                  begin 
                     SParam:=Copy(CompList.Strings[i],12,999); 
                     TheCanvas.TextOut((Param[0]-(TheCanvas.TextWidth(SParam) div 2))-XOfs,
                             Param[1]-YOfs,SParam); 
                  end;
               4 : 
                  TheCanvas.Ellipse(Param[0]-XOfs,Param[1]-YOfs,
                          Param[2]-XOfs,Param[3]-YOfs);
               5 : 
                  TheCanvas.Arc(Param[0]-XOfs,Param[1]-YOfs,
                      Param[2]-XOfs,Param[3]-YOfs,
                      Param[4]-XOfs,Param[5]-YOfs,
                      Param[6]-XOfs,Param[7]-YOfs);
            end;
         end;
      end;
   end
   else
   begin
      TheCanvas.TextOut(10,10,'No Diagram Information Available!'); 
   end;
   TheCanvas.Brush.Style:=bsSolid;
   Result:=SomeDat;
end;                           

procedure TGGForm.Exit1Click(Sender: TObject);
begin
   Close;
end;

procedure TGGForm.FormCreate(Sender: TObject);
begin
  CompList:=TStringList.Create;
  Setup:=False;
end;

procedure TGGForm.Print1Click(Sender: TObject);
var
   Xc,Yc:Integer;
   Xs,Ys:Integer;
   Xi,Yi:Integer;
   Pages:Integer;
   SomeDat:Boolean;
begin
   if Printer.Orientation = poPortrait then
      Printer.Orientation:=poLandscape;
   Xs:=(PaintBox1.Width*5) div 2;
   Ys:=(PaintBox1.Height*5) div 2;
   if Printer.PageWidth < Xs then
      Xc:=(Xs div Printer.PageWidth)+1
   else
      Xc:=1;
   if Printer.PageHeight < Ys then
      Yc:=(Ys div Printer.PageHeight)+1
   else
      Yc:=1;
   Pages:=Xc*Yc;
   Xs:=Printer.PageWidth-10;
   Ys:=Printer.PageHeight-10;
   Printer.BeginDoc;
   for Xi:=1 to Xc do
   begin
      for Yi:=1 to Yc do
      begin
         SomeDat:=DrawDiag(Printer.Canvas,
                  Printer.PageWidth,
                  Printer.PageHeight,
                  (Xi-1)*Xs,
                  (Yi-1)*Ys);
         if (Printer.PageNumber < Pages) and SomeDat then Printer.NewPage;
      end;
   end;
   Printer.EndDoc;
end;

procedure TGGForm.FormDestroy(Sender: TObject);
begin
   CompList.Destroy;
end;

procedure TGGForm.OpenTable1Click(Sender: TObject);
begin
   OpenDialog1.FileName:='*.ifd';
   if OpenDialog1.Execute then
   begin
      Setup:=False;
      ListBox1.Clear;
      PaintBox1.Invalidate;
      WaitForm.FileName:=OpenDialog1.FileName;
      WaitForm.ShowModal;;
      ListBox1.Items.LoadFromFile('TT.GGF');
      if ListBox1.Items.Count > 0 then Panel5.Caption:=ListBox1.Items[0];
      ListBox1.Items.LoadFromFile('TUNITLST.GGF');
   end;
end;

procedure TGGForm.ListBox1Click(Sender: TObject);
begin
   if ListBox1.ItemIndex >= 0 then
   begin
      Traverse(ListBox1.Items[ListBox1.ItemIndex],Group.Checked,FromTo.Checked);
      CompList.LoadFromFile('COMPNT.GGF');
      PaintBox1.Width:=MaxWidth;        
      PaintBox1.Height:=MaxHeight;
      if ScrollBox1.HorzScrollBar.Position <> 0 then 
         ScrollBox1.HorzScrollBar.Position:=0;
      if ScrollBox1.VertScrollBar.Position <> 0 then 
         ScrollBox1.VertScrollBar.Position:=0;
      Setup:=True;
      PaintBox1.Invalidate;
   end;
end;

procedure TGGForm.PaintBox1Paint(Sender: TObject);
begin
   if Setup then DrawDiag(PaintBox1.Canvas,PaintBox1.Width,PaintBox1.Height,0,0);
end;

procedure TGGForm.About1Click(Sender: TObject);
begin
   AboutBox.Timer1.Interval:=0;
   AboutBox.ShowModal;
end;

procedure TGGForm.FormShow(Sender: TObject);
var
   About:TAboutBox;
begin
   About:=TAboutBox.Create(Self);
   try
      About.Timer1.Interval:=4000; 
      About.ShowModal;
   finally
      About.Destroy;
   end;
end;

procedure TGGForm.Force1Click(Sender: TObject);
begin
   CompList.LoadFromFile('COMPNT.GGF');
   PaintBox1.Width:=10000;        
   PaintBox1.Height:=10000;
   Setup:=True;
   PaintBox1.Invalidate;
end;

end.
 