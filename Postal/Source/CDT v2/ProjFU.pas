unit ProjFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TForm1 = class(TForm)
    ButtonPanel: TPanel;
    Panel4: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    CPanel: TPanel;
    ListBox1: TListBox;
    Panel1: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel13: TPanel;
    Panel14: TPanel;
    Panel15: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel16: TPanel;
    Panel17: TPanel;
    Panel18: TPanel;
    Panel20: TPanel;
    Panel21: TPanel;
    Panel22: TPanel;
    Panel23: TPanel;
    Panel24: TPanel;
    Panel25: TPanel;
    Panel26: TPanel;
    Panel27: TPanel;
    Panel28: TPanel;
    Panel29: TPanel;
    Panel19: TPanel;
    Panel30: TPanel;
    Panel31: TPanel;
    Panel32: TPanel;
    Panel33: TPanel;
    Image1: TImage;
    procedure SpeedButton1Click(Sender: TObject);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
   SpeedButton1.Font.Color:=clBlack;
   SpeedButton2.Font.Color:=clBlack;
   SpeedButton3.Font.Color:=clBlack;
   SpeedButton4.Font.Color:=clBlack;
   SpeedButton5.Font.Color:=clBlack;
   SpeedButton6.Font.Color:=clBlack;
   SpeedButton7.Font.Color:=clBlack;
   SpeedButton8.Font.Color:=clBlack;
   (Sender as TSpeedButton).Font.Color:=clNavy;
end;

procedure TForm1.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
   R:TRect;
   H:Integer;
   S:String;
begin                                                                                                                                   
   with ListBox1.Canvas do
   begin                      
      FillRect(Rect);
      Pen.Color:=clBlack;
      MoveTo(5,Rect.Bottom-1);
      LineTo(Rect.Right-5,Rect.Bottom-1);
      R:=Bounds(Rect.Left+((Rect.Right-Rect.Left)-Image1.Width) div 2,Rect.Top,Image1.Width,Image1.Height);
      BrushCopy(R,Image1.Picture.Bitmap,Image1.ClientRect,Image1.Picture.Bitmap.TransparentColor);
      Font.Style:=[fsBold];
      R:=Bounds(Rect.Left,Rect.Top+Image1.Height+2,Rect.Right-Rect.Left,Rect.Bottom-(Rect.Top+Image1.Height));
      S:='This is the Description of the Product';
      H:=DrawText(ListBox1.Canvas.Handle,PChar(S),Length(S),R,DT_CENTER or DT_CALCRECT or DT_WORDBREAK );
      R:=Bounds(Rect.Left,Rect.Top+Image1.Height+2,Rect.Right-Rect.Left,Rect.Bottom-(Rect.Top+Image1.Height));
      DrawText(ListBox1.Canvas.Handle,PChar(S),Length(S),R,DT_CENTER or DT_WORDBREAK );
      Font.Style:=[];
      TextOut(Rect.Left+((Rect.Right-Rect.Left)-TextWidth(ListBox1.Items[Index])) div 2,Rect.Top+Image1.Height+H,ListBox1.Items[Index]);
      TextOut(Rect.Left+2,Rect.Top+2,IntToStr(Index));
   end;            
end;

end.
