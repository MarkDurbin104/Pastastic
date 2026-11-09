unit CalendarFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,Preview,
  StdCtrls, ExtCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    DTP1: TDateTimePicker;
    DTP2: TDateTimePicker;
    Button3: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    PrintPreview:TPrintPreview;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
procedure PrintDiary(PrintPreview:TPrintPreview;PR:TRect;FD,TD:TDate);
var
  W,H,I:Integer; 
  M:Integer;
  BR:TRect;
begin
   W:=PR.Right-PR.Left;
   H:=(PR.Bottom-PR.Top) div 3;
   M:=W div 5;
   for I:=0 to Trunc(TD-FD) do
   begin
      if ((I mod 7) = 0) or ((I mod 7) = 3) then
         PrintPreview.NewPage; 
      case (I mod 7) of
         0 : BR:=Bounds(PR.Left            ,PR.Top    ,(W-M)      ,H);
         1 : BR:=Bounds(PR.Left            ,PR.Top+H  ,(W-M)      ,H);
         2 : BR:=Bounds(PR.Left            ,PR.Top+H*2,(W-M)      ,H);
         3 : BR:=Bounds((PR.Left+M)        ,PR.Top    ,(W-M)      ,H);
         4 : BR:=Bounds((PR.Left+M)        ,PR.Top+H  ,(W-M)      ,H);
         5 : BR:=Bounds((PR.Left+M)        ,PR.Top+H*2,(W-M) div 2,H);
         6 : BR:=Bounds((PR.Left+M)+(W-M) div 2,PR.Top+H*2,(W-M) div 2,H);
      end;
      PrintPreview.Canvas.Brush.Style:=bsClear;
      PrintPreview.Canvas.Font.Style:=[fsBold];
      PrintPreview.Canvas.Font.Size:=300;
      PrintPreview.Canvas.Rectangle(BR.Left,BR.Top,BR.Left+(BR.Right-BR.Left),BR.Top+(BR.Bottom-BR.Top));
      if (I mod 7) < 3 then
         PrintPreview.Canvas.TextOut(BR.Left+200,BR.Top+100,FormatDateTime('dddd dd mmmm yyyy',(I+FD)))
      else
         PrintPreview.Canvas.TextOut((BR.Right-PrintPreview.Canvas.Textwidth(FormatDateTime('dddd dd mmmm yyyy',(I+FD))))-200,BR.Top+100,FormatDateTime('dddd dd mmmm yyyy',(I+FD)));
   end;
   PrintPreview.Canvas.Font.Style:=[];
   PrintPreview.Canvas.Brush.Style:=bsSolid;
end;
procedure TForm1.Button1Click(Sender: TObject);
begin
   PrintPreview:=TPrintPreview.Create(nil);
   Panel2.InsertControl(PrintPreview);
   PrintPreview.Align:=alClient;
   PrintPreview.BeginDoc;
   PrintPreview.Canvas.Font.Size:=1600;
   PrintPreview.Canvas.TextOut(PrintPreview.PageRect.Left+((PrintPreview.PageRect.Right-PrintPreview.PageRect.Left)-PrintPreview.Canvas.TextWidth('Jasper''s Diary')) div 2,5000,'Jasper''s Diary');
   PrintPreview.Canvas.Font.Size:=1000;
   PrintPreview.Canvas.TextOut(PrintPreview.PageRect.Left+((PrintPreview.PageRect.Right-PrintPreview.PageRect.Left)-PrintPreview.Canvas.TextWidth('Private Property')) div 2,10000,'Private Property');
   PrintPreview.ZoomState:=zsZoomToWidth;
   PrintDiary(PrintPreview,PrintPreview.PageRect,DTP1.Date,DTP2.Date);
   PrintPreview.EndDoc;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
   if PrintPreview <> nil then PrintPreview.Print;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
   if PrintPreview <> nil then PrintPreview.CurrentPage:=PrintPreview.CurrentPage+1;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
   if PrintPreview <> nil then PrintPreview.CurrentPage:=PrintPreview.CurrentPage-1;
end;

end.
