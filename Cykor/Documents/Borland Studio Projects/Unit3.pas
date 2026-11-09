unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Borland.Vcl.StdCtrls, Borland.Vcl.ExtCtrls, System.ComponentModel,
  Borland.Vcl.Grids;

type
  TForm3 = class(TForm)
    SG: TStringGrid;
    Panel1: TPanel;
    Button1: TButton;
    ScrollBox1: TScrollBox;
    PaintBox1: TPaintBox;
    procedure PaintBox1Paint(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.nfm}
function ConvertDate(D:String):String;
begin
   Result:=Copy(D,7,4)+Copy(D,4,2)+Copy(D,1,2);
end;
function ConvertDateBack(D:String):String;
begin
   Result:=Copy(D,7,2)+'/'+Copy(D,5,2)+'/'+Copy(D,1,4);
end;
procedure TForm3.Button1Click(Sender: TObject);
var
   SL:TStringList;
   CSL:TStringList;
   S:String;
   I,J,W,MW,MOW:Integer;
begin
  SL:=TStringList.Create;
  CSL:=TStringList.Create;
  SL.LoadFromFile('C:\Tools\Shipping.txt');
  SG.RowCount:=SL.Count;
  for I := 0 to SL.Count-1 do
  begin
    S:='';
    for J := 1 to Length(SL[I]) do
    begin
      if SL[I][J] = #9 then
      begin
         CSL.Add(S);
         S:='';
      end
      else
      begin
         S:=S+SL[I][J];
      end;
    end;
    CSL.Add(S);
    if SG.ColCount < CSL.Count then
      SG.ColCount:=CSL.Count;
    SG.Rows[I].CommaText:=CSL.CommaText;
    CSL.Clear;
  end;
  SL.Free;
  CSL.Free;
  while Trim(SG.Cols[SG.ColCount-1].Text) = '' do
    SG.ColCount:=SG.ColCount-1;
  MOW:=0;
  for I:=0 to SG.ColCount-1 do
  begin
    MW:=0;
    for J := 0 to SG.RowCount-1 do
    begin
       W:=Canvas.TextWidth(SG.Cells[I,J]);
       if W > MW then MW:=W;
    end;
    SG.ColWidths[I]:=MW+4;
    if (I < SG.ColCount-1) and (MW > MOW) then MOW:=MW;
  end;
  PaintBox1.Width:=SG.ColCount*SG.ColWidths[0];
  PaintBox1.Height:=1000;
  for I:=1 to SG.ColCount-2 do
  begin
    for J := 1 to SG.RowCount-1 do
    begin
       SG.Cells[I,J]:=ConvertDate(SG.Cells[I,J]);
    end;
  end;
end;

procedure TForm3.PaintBox1Paint(Sender: TObject);
var
   W,MW,I,J,K,XOfs,Ofs,COfs,Orig:Integer;
   Wid,Idx:Integer;
   DateList:TStringList;
begin
  COfs:=4;
  with PaintBox1.Canvas do
  begin
    DateList:=TStringList.Create;
    for I:=1 to SG.ColCount-2 do
    begin
       for J:=0 to DateList.Count-1 do
          if DateList.Objects[J] <> nil then
             TStringList(DateList.Objects[J]).Free;
       DateList.Clear;
       Ofs:=0;
       for J := 2 to SG.RowCount-1 do
       begin
          if Trim(SG.Cells[I,J]) <> '' then
          begin
             Idx:=DateList.IndexOf(Trim(SG.Cells[I,J]));
             if Idx = -1 then
                Idx:=DateList.Add(Trim(SG.Cells[I,J]));
             if DateList.Objects[Idx] = nil then
                DateList.Objects[Idx]:=TStringList.Create;
             TStringList(DateList.Objects[Idx]).Add(SG.Cells[0,J]);
          end;
       end;
       DateList.Sort;
       Ofs:=0;
       Orig:=0;
       MW:=0;
       for J:=DateList.Count-1 downto 0 do
       begin
          Font.Color:=clBlack;
          XOfs:=COfs;
           if J = DateList.Count-1 then
           begin
             Brush.Color:=$00FFE0E0;
             Rectangle(COfs-2,Orig+2,COfs+SG.ColWidths[0],Orig+4+(TStringList(DateList.Objects[J]).Count+2)*16);
             Font.Style:=[fsBold];
             TextOut(COfs,4,SG.Cells[I,0]);
             Font.Style:=[];
             Inc(Ofs,4);
           end
           else
           begin
             Brush.Color:=$00E0FFFF;
             Rectangle(COfs-2,Orig-2,COfs+SG.ColWidths[0],Orig+(TStringList(DateList.Objects[J]).Count+1)*16);
           end;
//             Brush.Color:=clWindow;

          for K:=0 to TStringList(DateList.Objects[J]).Count-1 do
          begin
             Inc(Ofs,16);
             if K = 0 then
             begin
               Font.Style:=[fsBold];
               Font.Color:=clNavy;
               TextOut(XOfs,Ofs,ConvertDateBack(DateList[J]));
               W:=TextWidth(ConvertDateBack(DateList[J])); if W > MW then MW:=W;
               Font.Color:=clBlack;
               Font.Style:=[];
               Inc(Ofs,16);
             end;
             TextOut(XOfs,Ofs,TStringList(DateList.Objects[J])[K]);
             W:=TextWidth(TStringList(DateList.Objects[J])[K]); if W > MW then MW:=W;
          end;
          Inc(Ofs,4);

          Orig:=Ofs+16;
       end;
       Inc(COfs,SG.ColWidths[0]+8);
    end;
  end;
end;

end.
