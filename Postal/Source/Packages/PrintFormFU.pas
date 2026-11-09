unit PrintFormFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls,Printers, StdCtrls;

type
  TPrintForm = class(TForm)
    Image1: TImage;
  public
    procedure print2x2(Title,Desc1,Desc2,Office,DataCommatext:String);
  end;

var
  PrintForm: TPrintForm;

implementation

{$R *.DFM}

procedure PrintOnCanvas(BitMap:TBitMap;Canvas:TCanvas;Title,Desc1,Desc2,Office:String;Data:TStrings;Width,Height:Integer;Scale:Boolean);
var
   CentreX:Integer;
   TopOfs :Integer;
   ColTopOfs:Integer;
   LineData:TStringList;
   OfficeData:TStringList;
   CurCol,CurRow:Integer;
   RowHeight,I:Integer;
   FS:Integer;
   FN:String;
   CHgt:Integer;
begin
   LineData:=TStringList.Create;
   OfficeData:=TStringList.Create;
   OfficeData.CommaText:=Office;
   
   CentreX:=Width div 2;
   with Canvas do
   begin
      Font.Style:=[fsBold];
      FS:=Font.Size;
      FN:=Font.Name;
      Font.Name:='Arial';
      while TextWidth(Title) < CentreX do Font.Size:=Font.Size+1;
      while TextWidth(Title) > CentreX do Font.Size:=Font.Size-1;
      TextOut(CentreX-(TextWidth(Title) div 2),TextHeight(Title) div 2,Title);
      if Scale then
      begin
         TopOfs:=TextHeight(Title)*2;
         BrushCopy(Bounds(30,30,TopOfs-30,TopOfs-30),Bitmap,Bounds(0,0,BitMap.Width,BitMap.Height),BitMap.TransparentColor);
      end
      else
      begin
         TopOfs:=BitMap.Height+50;
         BrushCopy(Bounds(30,30,BitMap.Width,BitMap.Height),Bitmap,Bounds(0,0,BitMap.Width,BitMap.Height),BitMap.TransparentColor);
      end;
      Font.Size:=18;
      RowHeight:=(Height-TopOfs) div 65;
      while TextHeight('Wg') < RowHeight do Font.Size:=Font.Size+1;
      while TextHeight('Wg') > RowHeight do Font.Size:=Font.Size-1;
      while TextWidth('888888888888888888888888888888888888888888888888888888') > CentreX do Font.Size:=Font.Size-1;
      TextOut(30        ,TopOfs,Desc1); TextOut(CentreX    -(TextWidth(Desc2)+30),TopOfs,Desc2);
      TextOut(30+CentreX,TopOfs,Desc1); TextOut((CentreX*2)-(TextWidth(Desc2)+30),TopOfs,Desc2);
      ColTopOfs:=TopOfs+RowHeight*2;
      CurCol:=0;
      CurRow:=0;
      for I:=0 to Data.Count-1 do
      begin
         LineData.CommaText:=Data[I];
         TextOut(CurCol+30,ColTopOfs+CurRow*RowHeight,LineData[0]);
         TextOut((CurCol+CentreX)-(TextWidth(' '+LineData[1])+30),ColTopOfs+CurRow*RowHeight,' '+LineData[1]);
         Inc(CurRow);
         if (CurCol = 0) and (I+2 >= ((Height-ColTopOfs) div RowHeight)) then
         begin
            CurCol:=CentreX;
            CurRow:=0;
         end;
      end;
      Font.Style:=[];
      Rectangle(CentreX+300,(Height-TextHeight('Wg')*20)-20,Width-30,(Height-TextHeight('Wg')*6)+20);
      Rectangle(CentreX+300,(Height-TextHeight('Wg')*13),Width-30,(Height-TextHeight('Wg')*10)+20);
      CHgt:=TextHeight('Wg')*6;
      ellipse(Width-(CHgt+50),(Height-TextHeight('Wg')*20)+20,Width-50,(Height-TextHeight('Wg')*20)+20+CHgt);
      TextOut((Width-(CHgt+50))+(CHgt-TextWidth('Offical Stamp')) div 2,(Height-TextHeight('Wg')*17),'Offical Stamp');
      TextOut(CentreX+310,Height-TextHeight('Wg')*20,Title);
      TextOut(CentreX+310,Height-TextHeight('Wg')*19,'Printed on - '+DateToStr(Now)+' at '+TimeToStr(Now));
      TextOut(CentreX+310,Height-TextHeight('Wg')*18,'Tanzania Posts Corporation');
      TextOut(CentreX+310,Height-TextHeight('Wg')*17,OfficeData[0]);
      TextOut(CentreX+310,Height-TextHeight('Wg')*16,OfficeData[1]);
      TextOut(CentreX+310,Height-TextHeight('Wg')*15,OfficeData[2]);
      TextOut(CentreX+310,Height-TextHeight('Wg')*11,'Name');
      TextOut(CentreX+310,Height-TextHeight('Wg')*7 ,'Signed');
      Font.Size:=FS;
      Font.Name:=FN;
   end;
   LineData.Free;
   OfficeData.Free;
end;
procedure TPrintForm.print2x2(Title,Desc1,Desc2,Office,DataCommatext:String);
var
  Data:TStringList;
begin
   Data:=TStringList.Create;
   Data.CommaText:=DataCommaText;
   Printer.BeginDoc;
   PrintOnCanvas(Image1.Picture.Bitmap,Printer.Canvas,Title,Desc1,Desc2,Office,Data,Printer.PageWidth,Printer.PageHeight,False);
   Printer.EndDoc;
   Data.Free;
end;
end.
