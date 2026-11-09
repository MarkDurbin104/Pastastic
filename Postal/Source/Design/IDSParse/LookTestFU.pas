unit LookTestFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls,GPCSGUID,GPCSBase_TLB,ComObj, Grids, ComCtrls;

type
  TLookTest = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    LookUpList: TListBox;
    Splitter1: TSplitter;
    Panel2: TPanel;
    Panel4: TPanel;
    Refresh: TButton;
    Panel5: TPanel;
    Splitter2: TSplitter;
    Label2: TLabel;
    Ranges: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    ResultsGrid: TStringGrid;
    Graph: TTabSheet;
    ScrollBox1: TScrollBox;
    GraphPB: TPaintBox;
    Panel3: TPanel;
    ListBox1: TListBox;
    Splitter3: TSplitter;
    procedure FormShow(Sender: TObject);
    procedure RefreshClick(Sender: TObject);
    procedure RangesChange(Sender: TObject);
    procedure LookUpListClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure GraphPBPaint(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
  private
    procedure ReCalc;
  public
    { Public declarations }
  end;

var
  LookTest: TLookTest;

implementation

{$R *.DFM}
uses IDSParseFU;
function LoadComponent(ProgID:String):IComponent;
begin
   Result:=nil;
   try
      Result:=CreateComObject(ProgIDToClassID(ProgID)) as IComponent;
   except
   end;
end;

procedure TLookTest.ReCalc;
var
   LookUp:ILookUp;
   I:Integer;
   J:Integer;
   TestVal:Integer;
begin
   if LookUpList.ItemIndex >=0 then
   begin
      LookUp:=LoadComponent('LookUp.'+LookUpList.Items[LookUpList.ItemIndex]) as ILookUp;
      ListBox1.Clear;
      ResultsGrid.RowCount:=Ranges.Lines.Count+1;
      if LookUp <> nil then
      begin
         ResultsGrid.ColCount:=1+LookUp.ColumnCount;
         for I:=0 to Ranges.Lines.Count-1 do
            ResultsGrid.Cells[0,I+1]:=IntToStr(StrToIntDef(Ranges.Lines[I],-1));
         for J:=0 to ResultsGrid.ColCount-2 do
         begin
            try
               ResultsGrid.Cells[J+1,0]:=LookUp.ColumnName[J];
               ListBox1.Items.Add(ResultsGrid.Cells[J+1,0]);
               try
                  LookUp.CurrentColumn:=LookUp.ColumnName[J];
                  for I:=0 to Ranges.Lines.Count-1 do
                  begin
                     TestVal:=StrToIntDef(Ranges.Lines[I],-1);
                     ResultsGrid.Cells[1+J,I+1]:=LookUp.Value[TestVal];
                  end;
               except
                  for I:=0 to Ranges.Lines.Count-1 do
                     ResultsGrid.Cells[1+J,I+1]:='?';
               end;
            except
               for I:=0 to Ranges.Lines.Count-1 do
                  ResultsGrid.Cells[1+J,I+1]:='?';
            end;
         end;  
         LookUp:=nil;
      end;
   end;
   GraphPB.Invalidate;
end;

procedure TLookTest.FormShow(Sender: TObject);
begin
   RefreshClick(Refresh);
end;

procedure TLookTest.RefreshClick(Sender: TObject);
var
   I:Integer;
begin
   LookUpList.Clear;
   with MainForm.IDSDiag.Parser do
   begin
      for I:=0 to Nodes.LookUps.Count-1 do
      begin
         LookUpList.Items.Add(Nodes.LookUps.Name[I]);
      end;
   end;
end;

procedure TLookTest.RangesChange(Sender: TObject);
begin
   ReCalc;
end;

procedure TLookTest.LookUpListClick(Sender: TObject);
begin
   ReCalc;
end;

procedure TLookTest.Button1Click(Sender: TObject);
begin
   Close;
end;

procedure TLookTest.GraphPBPaint(Sender: TObject);
const
   Colour:Array[0..6] of TColor =(clBlack,clNavy,clRed,clGreen,clAqua,clYellow,clGray);
var
   I,J,CellVal:Integer;
   MinYR,MaxYR:Integer;
   MinXR,MaxXR:Integer;
   ScaleX,ScaleY:Extended;
   XPoint,YPoint:Integer;
   GWid,GHgt:Integer;
begin
   if LookUpList.ItemIndex < 0 then Exit;
   GWid:=GraphPB.Width -150;
   GHgt:=GraphPB.Height-20;
   MinYR:=MAXINT; MaxYR:=0-MAXINT;
   MinXR:=MAXINT; MaxXR:=0-MAXINT;
   for I:=1 to ResultsGrid.RowCount-1 do
   begin
      CellVal:=StrToIntDef(ResultsGrid.Cells[0,I],0);
      if MinXR > CellVal then MinXR:=CellVal;
      if MaxXR < CellVal then MaxXR:=CellVal;
      for J:=1 to ResultsGrid.ColCount-1 do
      begin
         CellVal:=Trunc(StrToCurrDef(ResultsGrid.Cells[J,I],0));
         if MinYR > CellVal then MinYR:=CellVal;
         if MaxYR < CellVal then MaxYR:=CellVal;
      end;
   end;
   ScaleX:=GWid  / ((MaxXR-MinXR)+1);
   ScaleY:=GHgt / ((MaxYR-MinYR)+1);
   with GraphPB.Canvas do
   begin
      for J:=0 to 10 do
      begin
         TextOut(50+(GWid div 10)*J,GHgt,IntToStr(MinXR+((MaxXR-MinXR) div 10)*J));
         TextOut(0,GHgt-((GHgt div 10)*J),CurrToStr((MinYR+1)+((MaxYR-MinYR) / 10)*J));
      end;
      Brush.Style:=bsClear;
      for J:=1 to ResultsGrid.ColCount-1 do
      begin
         if (ListBox1.SelCount = 0) or (ListBox1.Selected[J-1]) then
         begin
            Pen.Color:=Colour[J mod 7];
            Font.Color:=Colour[J mod 7];
            YPoint:=0;
            for I:=1 to ResultsGrid.RowCount-1 do
            begin
               XPoint:=50+Trunc(StrToIntDef(ResultsGrid.Cells[0,I],1)*ScaleX);
//               YPoint:=0;
               if StrToCurrDef(ResultsGrid.Cells[J,I],0) >= 0 then
               begin
                  YPoint:=GHgt-Trunc((StrToCurrDef(ResultsGrid.Cells[J,I],0)-MinYR)*ScaleY);
                  if I = 1 then MoveTo(45,YPoint);
                  LineTo(XPoint,YPoint);
               end;
               if I = ResultsGrid.RowCount-1 then
                  TextOut(XPoint+5,YPoint,ResultsGrid.Cells[J,0]);
            end;
         end; 
      end;
      Brush.Style:=bsSolid;
   end;
end;

procedure TLookTest.ListBox1Click(Sender: TObject);
begin
   GraphPB.Invalidate;
end;

end.
