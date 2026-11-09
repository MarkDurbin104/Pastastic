unit Erpolyrc;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Exit1: TMenuItem;
    Repaint1: TMenuItem;
    TryAgain1: TMenuItem;
    EraseStyle1: TMenuItem;
    RLE1: TMenuItem;
    QUAD1: TMenuItem;
    BETTERQUAD1: TMenuItem;
    POINT1: TMenuItem;
    Print1: TMenuItem;
    Results: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Repaint1Click(Sender: TObject);
    procedure TryAgain1Click(Sender: TObject);
    procedure RLE1Click(Sender: TObject);
    procedure QUAD1Click(Sender: TObject);
    procedure BETTERQUAD1Click(Sender: TObject);
    procedure POINT1Click(Sender: TObject);
    procedure Print1Click(Sender: TObject);
  private
    { Private declarations }
    FirstX,FirstY:Integer;
    PolyList,XPList,YPList:TStringList;
    XList,YList:TStringList;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
procedure ErasePoints; 
          far; external 'ERASEPLY';
procedure EraseType(Style:Integer); 
          far; external 'ERASEPLY';
           
procedure TForm1.FormCreate(Sender: TObject);
begin
   FirstX:=-1;
   PolyList:=TStringList.Create;
   XPList  :=TStringList.Create;
   YPList  :=TStringList.Create;
   XList   :=TStringList.Create;
   YList   :=TStringList.Create;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   Canvas.Pen.Color:=clRed;
   if FirstX = -1 then      
   begin
      PolyList.Clear;
      XList.Clear;
      YList.Clear;
      PolyList.Add(IntToStr(X) + ',' + IntToStr(Y));
      XList.Add(IntToStr(X));
      YList.Add(IntToStr(Y));
      Canvas.MoveTo(X,Y);
      FirstX:=X;
      FirstY:=Y;
   end
   else
      if (Abs(FirstX-X) < 5) and (Abs(FirstY-Y) < 5) then
      begin
         PolyList.Add(IntToStr(FirstX) + ',' + IntToStr(FirstY));
         XList.Add(IntToStr(FirstX));
         YList.Add(IntToStr(FirstY));
         FirstX:=-1;
         PolyList.SaveToFile('PolyList.Dat');
         PolyList.Clear;
         ErasePoints;
         XPList.Clear;
         XPList.LoadFromFile('XPList.Dat');
         YPList.Clear;
         YPList.LoadFromFile('Results.Dat');
         Results.Caption:=YPList[0];
         YPList.Clear;
         YPList.LoadFromFile('YPList.Dat');
         Invalidate;
      end
      else
      begin
         PolyList.Add(IntToStr(X) + ',' + IntToStr(Y));
         XList.Add(IntToStr(X));
         YList.Add(IntToStr(Y));
         Canvas.LineTo(X,Y);
      end;
   begin
   end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
   PolyList.Destroy;
   XPList.Destroy;
   YPList.Destroy;
   XList.Destroy;
   YList.Destroy;
end;

procedure TForm1.FormPaint(Sender: TObject);
var
   I:Integer;
begin
   if XPList.Count > 0 then
   begin
      Canvas.Pen.Color:=clBlack;
      for I:=0 to XPList.Count-1 do
      begin
         Canvas.Rectangle(StrToInt(XPList[I]),StrToInt(YPList[I]),
                StrToInt(XPList[I+1]),StrToInt(YPList[I+1]));
         I:=I+1;
      end;
   end;  
   if XList.Count > 0 then
   begin
      Canvas.Pen.Color:=clRed;
      Canvas.MoveTo(StrToInt(XList[0]),StrToInt(YList[0]));
      for I:=1 to XList.Count-1 do
      begin
         Canvas.LineTo(StrToInt(XList[I]),StrToInt(YList[I]));
      end;
   end;  
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
   Close;
end;

procedure TForm1.Repaint1Click(Sender: TObject);
begin
   Invalidate;
end;          

procedure TForm1.TryAgain1Click(Sender: TObject);
begin
   ErasePoints;
   XPList.Clear;
   XPList.LoadFromFile('XPList.Dat');
   YPList.Clear;
   YPList.LoadFromFile('Results.Dat');
   Results.Caption:=YPList[0];
   YPList.Clear;
   YPList.LoadFromFile('YPList.Dat');
   Invalidate;
end;

procedure TForm1.RLE1Click(Sender: TObject);
begin
   EraseType(0);
   TryAgain1Click(Self);
end;

procedure TForm1.QUAD1Click(Sender: TObject);
begin
   EraseType(1);
   TryAgain1Click(Self);
end;

procedure TForm1.BETTERQUAD1Click(Sender: TObject);
begin
   EraseType(2);
   TryAgain1Click(Self);
end;


procedure TForm1.POINT1Click(Sender: TObject);
begin
   EraseType(3);
   TryAgain1Click(Self);
end;

procedure TForm1.Print1Click(Sender: TObject);
begin
   Print;
end;

end.
 