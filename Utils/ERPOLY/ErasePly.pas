unit Eraseply;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Menus;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Exit1: TMenuItem;
    Refresh1: TMenuItem;
    Generate1: TMenuItem;
    procedure Exit1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormHide(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure Generate1Click(Sender: TObject);
  private
    { Private declarations }
    Drawing:Boolean;
    XList,YList:TStringList;
    XPList,YPList:TStringList;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure ErasePoints(Handle:Hwnd);
         far; external 'POLYUTIL';
         
procedure TForm1.Exit1Click(Sender: TObject);
begin
   Close;
end;

procedure TForm1.FormShow(Sender: TObject);
var
   I,J:Integer;
   Pnt:String;
begin
   Drawing:=False;
   XList:=TStringList.Create;
   YList:=TStringList.Create;
   XPList:=TStringList.Create;
   YPList:=TStringList.Create;
   for I:=0 to Width div 8 do
   begin
      for J:=0 to Height div 8 do
      begin
         Pnt:=IntToStr(I*8); XPList.Add(Pnt);
         Pnt:=IntToStr(J*8); YPList.Add(Pnt);
      end;
   end;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   ThePoint:String;
begin
   Drawing:=True;
   Canvas.MoveTo(X,Y);
   YList.Clear; XList.Clear;
   ThePoint:=IntToStr(X); XList.Add(ThePoint);
   ThePoint:=IntToStr(Y); YList.Add(ThePoint);
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   ThePoint:String;
begin            
   ThePoint:=IntToStr(X); XList.Add(ThePoint);
   ThePoint:=IntToStr(Y); YList.Add(ThePoint);
   ThePoint:=XList[0]; XList.Add(ThePoint);
   ThePoint:=YList[0]; YList.Add(ThePoint);
   Drawing:=False;
   XPList.SaveToFile('XPList.Dat');
   YPList.SaveToFile('YPList.Dat');
   XList.SaveToFile ('XList.Dat' );
   YList.SaveToFile ('YList.Dat' );
   ErasePoints(Handle);
   XPList.Clear;
   YPList.Clear;
   XPList.LoadFromFile('XPList.Dat');
   YPList.LoadFromFile('YPList.Dat');
   Invalidate;
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
   ThePoint:String;
begin
   if Drawing then
   begin
      Canvas.LineTo(X,Y);
      ThePoint:=IntToStr(X); XList.Add(ThePoint);
      ThePoint:=IntToStr(Y); YList.Add(ThePoint);
   end;
end;

procedure TForm1.FormHide(Sender: TObject);
begin
   XList.Free;
   YList.Free;
   XPList.Free;
   YPList.Free;
end;

procedure TForm1.FormPaint(Sender: TObject);
var
   I:Integer;
begin
   if XPList.Count > 0 then
   begin
      Canvas.Pen.Color:=clRed;
      for I:=0 to XPList.Count-1 do
      begin
         Canvas.Rectangle(StrToInt(XPList[I]),StrToInt(YPList[I]),
                StrToInt(XPList[I])+2,StrToInt(YPList[I])+2);
      end;
   end;  
   
   Canvas.Pen.Color:=clBlack;
   if XList.Count > 0 then
   begin
      Canvas.Moveto(StrToInt(XList[0]),StrToInt(YList[0]));
      for I:=1 to XList.Count-1 do
      begin
         Canvas.Lineto(StrToInt(XList[I]),StrToInt(YList[I]));
      end;
   end;  
end;

procedure TForm1.Refresh1Click(Sender: TObject);
var
   I,J:Integer;
   Pnt:String;
begin
   XPList.Clear;
   YPList.Clear;
   XList.Clear;
   YList.Clear;
   for I:=0 to Width div 8 do
   begin
      for J:=0 to Height div 8 do
      begin
         Pnt:=IntToStr(I*8); XPList.Add(Pnt);
         Pnt:=IntToStr(J*8); YPList.Add(Pnt);
      end;
   end;
   InValidate;
end;

procedure TForm1.Generate1Click(Sender: TObject);
begin
   XList.Clear;
   YList.Clear;
   XList.LoadFromFile('XList.Gen');
   YList.LoadFromFile('YList.Gen');
   Drawing:=False;
   XPList.SaveToFile('XPList.Dat');
   YPList.SaveToFile('YPList.Dat');
   XList.SaveToFile ('XList.Dat' );
   YList.SaveToFile ('YList.Dat' );
   ErasePoints(Handle);
   XPList.Clear;
   YPList.Clear;
   XPList.LoadFromFile('XPList.Dat');
   YPList.LoadFromFile('YPList.Dat');
   Invalidate;
end;

end.
 