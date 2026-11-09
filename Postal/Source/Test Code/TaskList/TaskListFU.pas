unit TaskListFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,SavePosFormU,TaskKillerU;

type
  TForm1 = class(TSavePosForm)
    LB: TListBox;
    Panel1: TPanel;
    Button1: TButton;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure LBDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;



implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
   FillList(LB.Items);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
   Button1.Enabled:=False;
   KillCorvus;
   FillList(LB.Items);
   Button1.Enabled:=True;
end;

procedure TForm1.LBDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
   with LB.Canvas do
   begin
      FillRect(Rect);
      if Copy(LB.Items[Index],1,1) = '*' then
      begin
         Font.Color:=clBlack;
         TextOut(Rect.Left+1,Rect.Top+1,Copy(LB.Items[Index],2,99));
      end
      else
      begin
         Font.Color:=clMaroon;
         TextOut(Rect.Left+1,Rect.Top+1,LB.Items[Index]);
      end;
   end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
   FillList(LB.Items);
end;

end.
