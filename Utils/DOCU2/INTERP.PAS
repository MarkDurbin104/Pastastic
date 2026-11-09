unit Interp;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Grids, Outline, Menus,Print, Buttons;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Outline1: TOutline;
    OpenDialog1: TOpenDialog;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    SEdit: TEdit;
    PEdit: TEdit;
    CEdit: TEdit;
    REdit: TEdit;
    DMemo: TMemo;
    Label6: TLabel;
    PMemo: TMemo;
    Label7: TLabel;
    UEdit: TEdit;
    PopupMenu1: TPopupMenu;
    Add1: TMenuItem;
    Delete1: TMenuItem;
    N1: TMenuItem;
    Update1: TMenuItem;
    SaveDialog1: TSaveDialog;
    Load1: TMenuItem;
    PButton: TBitBtn;
    procedure Outline1Click(Sender: TObject);
    procedure Add1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure Update1Click(Sender: TObject);
    procedure Load1Click(Sender: TObject);
    procedure PButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  PStringList = ^TStringList;

var
  Form1: TForm1;

implementation

{$R *.DFM}
procedure FuncNames(FileName :String); far; external 'INTERP';
procedure FuncCode(FuncName :String); far; external 'INTERP';

procedure TForm1.Outline1Click(Sender: TObject);
var
   FirstL:Boolean;
   i:Integer;
   SL:TStringList;
   Indicator,Line:String;
begin
   FirstL:=TRUE;
   DMemo.Clear;
   PMemo.Clear;
   Memo1.Clear;
   SEdit.Text:='';
   CEdit.Text:='';
   REdit.Text:='';
   UEdit.Text:='';
   if Outline1[Outline1.SelectedItem].Level = 3 then
   begin
      Memo1.Lines.BeginUpdate;
      SL:=TStringList(Outline1[Outline1.SelectedItem].Data);
      for i:=0 to SL.Count-1 do
      begin
           Indicator:=Copy(SL.Strings[i],1,2);
           Line:=Copy(SL.Strings[i],4,999);
           if Indicator = '?S' then
           begin
              SEdit.Text:=Line;
           end
           else if Indicator = '?C' then
           begin
              CEdit.Text:=Line;
           end
           else if Indicator = '?R' then
           begin
              REdit.Text:=Line;
           end
           else if Indicator = '?U' then
           begin
              UEdit.Text:=Line;
           end
           else if Indicator = '?D' then
           begin
              DMemo.Lines.Insert(0,Line);
           end
           else if Indicator = '?P' then
           begin
              PMemo.Lines.Insert(0,Line);
           end
           else 
           begin
              if FirstL then
              begin
                 PEdit.Text:=SL.Strings[i];
                 FirstL:=FALSE;
              end;
              Memo1.Lines.Add(SL.Strings[i]);
           end;
      end;
      Memo1.Lines.EndUpdate;
   end;
end;

procedure TForm1.Add1Click(Sender: TObject);
var
   SLPos,Pos:LongInt;
   i,j:Integer;
   SL:TStringList;
   FL:TStringList;
begin
  OpenDialog1.Options := [ofAllowMultiSelect];
  OpenDialog1.Filter := 'C files (*.C)|*.C';
  if OpenDialog1.Execute then
  begin
    FL:=TStringList.Create;
    FL.Sorted:=TRUE;
    while Outline1[Outline1.SelectedItem].Level <> 1 do { move up to the project }
       Outline1.SelectedItem:=Outline1.SelectedItem-1;
    Outline1.Items[Outline1.SelectedItem].Expand;
    for i:=0 to OpenDialog1.Files.Count-1 do 
    begin
       FuncNames(OpenDialog1.Files[i]);
       FL.LoadFromFile('FuncLen.OPT');
       Pos:=Outline1.Add(Outline1.SelectedItem,OpenDialog1.Files[i]);
       Outline1[Pos].ChangeLevelBy(1);
       for j:=0 to FL.Count-1 do
       begin
          FuncCode(FL.Strings[j]);
          SL:=TStringList.Create;
          SL.LoadFromFile('FuncLen.OPT');
          SLPos:=Outline1.Add(Pos,FL.Strings[j]);
          Outline1.Items[SLPos].data:=SL;
          Outline1[SLPos].ChangeLevelBy(1);
       end;
    end;
    FL.Destroy;
  end;
end;

procedure TForm1.Delete1Click(Sender: TObject);
begin
   if Outline1[Outline1.SelectedItem].Level <> 1 then
   begin
      while Outline1[Outline1.SelectedItem].Level <> 2 do { move up to the file }
         Outline1.SelectedItem:=Outline1.SelectedItem-1;
      Outline1.Delete(Outline1.SelectedItem);
   end;
end;

procedure TForm1.Update1Click(Sender: TObject);
begin
  SaveDialog1.Filter := 'PRJ files (*.PRJ)|*.PRJ';
  if SaveDialog1.Execute then
     Outline1.SaveToFile(SaveDialog1.FileName);
end;

procedure TForm1.Load1Click(Sender: TObject);
var
   SLPos,Pos:LongInt;
   i,j:Integer;
   SL:TStringList;
   FL:TStringList;
   FuncL:TStringList;
   S:String;
begin
  FL:=TStringList.Create;
  FuncL:=TStringList.Create;
  FuncL.Sorted:=TRUE;
  OpenDialog1.Filter := 'PRJ files (*.PRJ)|*.PRJ';
  if OpenDialog1.Execute then
  begin
     Outline1.LoadFromFile(OpenDialog1.FileName);
     for i:=1 to Outline1.Lines.Count-1 do
     begin
        if Outline1.Items[i].Level = 1 then 
        begin
           S:=Copy(Outline1.Lines[i],2,999);
           FL.Add(S);
        end;
     end;
     Outline1.Clear;
     Pos:=Outline1.Add(0,OpenDialog1.FileName);
     Outline1.SelectedItem:=Pos;
     for i:=0 to FL.Count-1 do
     begin
        FuncNames(FL.Strings[i]);
        FuncL.LoadFromFile('FuncLen.OPT');
        Pos:=Outline1.Add(Outline1.SelectedItem,FL.Strings[i]);
        Outline1[Pos].ChangeLevelBy(1);
        for j:=0 to FuncL.Count-1 do
        begin
           FuncCode(FuncL.Strings[j]);
           SL:=TStringList.Create;
           SL.LoadFromFile('FuncLen.OPT');
           SLPos:=Outline1.Add(Pos,FuncL.Strings[j]);
           Outline1.Items[SLPos].data:=SL;
           Outline1[SLPos].ChangeLevelBy(1);
        end;
       FL.Destroy;
       FuncL.Destroy;
     end;
  end;
end;

procedure TForm1.PButtonClick(Sender: TObject);
begin
    Form2.SEdit.Text:=SEdit.Text;
    Form2.PEdit.Text:=PEdit.Text;
    Form2.UEdit.Text:=UEdit.Text;
    Form2.CEdit.Text:=CEdit.Text;
    Form2.REdit.Text:=REdit.Text;
    Form2.DMemo.Text:=DMemo.Text;
    Form2.PMemo.Text:=PMemo.Text;
    Form2.Visible:=TRUE;
    Form2.Print;
{    Form2.Visible:=FALSE; }
end;

end.
 