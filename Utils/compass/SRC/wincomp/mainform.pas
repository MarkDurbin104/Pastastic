unit mainform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    ListBox1: TListBox;
    Panel2: TPanel;
    StatusBar1: TStatusBar;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    ScrollBox1: TScrollBox;
    BPanel: TPanel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure MemoEnter(Sender: TObject);
    procedure MemoExit(Sender: TObject);
    procedure MemoDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure MemoDragOver(Sender, Source: TObject; X, Y: Integer; 
                           State: TDragState; var Accept: Boolean);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
const
   ButtonWidth=70;
   ButtonHeight=48;
   
implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
var
   Panel:TPanel;
   Memo:TMemo;
   I,J:Integer;
   StringList:TStringList;
begin
   StringList:=TStringList.Create;
   StringList.LoadFromFile('G:\KEYMAINT\01\LOCALPLU.OMR');
   ListBox1.Clear;
   For I:=0 to StringList.Count-1 do
   begin
      ListBox1.Items.Add(Copy(StringList.Strings[I],11,24));
   end;
   StringList.Free;
   BPanel.Width:=11*(ButtonWidth+2)+2;
   BPanel.Height:=15*(ButtonHeight+2)+2;
   for I:=0 to 10 do
   begin
      for J:=0 to 14 do
      begin
         Panel:=TPanel.Create(Self);
         BPanel.InsertControl(Panel);
         Panel.Width:=ButtonWidth;
         Panel.Height:=ButtonHeight;
         Panel.Caption:='';
         Panel.BevelOuter:=bvLowered;
         Panel.Left:=I*(ButtonWidth+2)+2;
         Panel.Top:=J*(ButtonHeight+2)+2;
         Memo:=TMemo.Create(Self);
         Panel.InsertControl(Memo);
         Memo.Align:=alClient;
         Memo.Alignment:=taCenter;
         Memo.BorderStyle:=bsNone;
         Memo.Font.Name:='Arial';
         Memo.Font.Size:=8;
         Memo.OnEnter   :=MemoEnter;
         Memo.OnExit    :=MemoExit;
         Memo.OnDragOver:=MemoDragOver;
         Memo.OnDragDrop :=MemoDragDrop;
         Memo.MaxLength:=12;
         if I*15+J > 95 then 
         begin
            Memo.Enabled:=False;
            Memo.Color:=clSilver;
            Panel.BevelWidth:=1;
         end
         else
         begin
            Memo.Enabled:=true;
            Memo.Color:=$00D9F7F4;
            Memo.Lines.Add('MENU');
            Panel.BevelWidth:=3;
         end;
      end;
   end;
end;

procedure TForm1.MemoEnter(Sender: TObject);
begin
    (Sender as TMemo).SelectAll;
    ((Sender as TMemo).Parent as TPanel).BevelOuter:=bvRaised;
end;
procedure TForm1.MemoExit(Sender: TObject);
begin
    ((Sender as TMemo).Parent as TPanel).BevelOuter:=bvLowered;
    if (Sender as TMemo).Modified then
    begin
       (Sender as TMemo).Color:=clYellow;
    end;
end;

procedure TForm1.MemoDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
   if Sender = ListBox1 then Accept:=True; 
end;

procedure TForm1.MemoDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
   if Source = ListBox1 then 
   begin
      (Sender as TMemo).Clear;
      (Sender as TMemo).Lines.Add(Copy(ListBox1.Items[ListBox1.ItemIndex],1,12));
   end;
end;

end.
 