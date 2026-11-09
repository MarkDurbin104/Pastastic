unit BDiffFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;
  
type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  TCharDetails = packed record
     Pos      :Byte;
     Count    :Integer ;
     Sum      :Integer ;
     SumSquare:Extended;
     Mean     :Extended;
     StdDev   :Extended;
     LastPos  :Integer ;
  end;
  PCharDetails=^TCharDetails;
var
  Form1: TForm1;

implementation

{$R *.DFM}

function GetBlockChar(FileName:String):Byte;
var
   MS:TMemoryStream;
   CD:Array[0..255] of TCharDetails;
   CurCD:PCharDetails;
   P:PByte;
   I:Integer;
   Dist:Integer;
   dDist:Extended;
begin
   Result:=0;            
   for I:=0 to 255 do 
   begin
      CD[I].SumSquare:=0;
      CD[I].Sum:=0;
      CD[I].Count:=0;
      CD[I].LastPos:=-1;
      CD[I].Pos:=I;
   end;
   
   if not FileExists(FileName) then exit;
   MS:=TMemoryStream.Create;
   MS.LoadFromFile(FileName);
   MS.Position:=0;
   P:=MS.Memory;
   for I:=0 to MS.Size-1 do
   begin
      CurCD:=@CD[Integer(P^)];
      Dist:=I-CurCD.LastPos;
      CurCD.LastPos:=I;
      dDist:=Dist;
      Inc(CurCD.Count);
      Inc(CurCD.Sum,Dist);
      CurCD.SumSquare:=CurCD.SumSquare+(dDist*dDist);
      Inc(P);
   end;
   CurCD:=nil;
   for I:=0 to 255 do 
   begin
      if CD[I].LastPos = -1 then
      begin
         CD[I].Mean:=MS.Size;
      end
      else
      begin
         CD[I].Mean:=CD[I].Sum / CD[I].Count;
         CD[I].StdDev:=Sqrt((CD[I].SumSquare / CD[I].Count) - (CD[I].Mean*CD[I].Mean));
      end;
      if (CurCD = nil) or ((CD[I].Mean < CurCD.Mean) and (CD[I].StdDev < CurCD.StdDev)) then
         CurCD:=@CD[I];
   end;                  
   MS.Free;
   ShowMessage(IntToHex(CurCD.Pos,2)+' '+FloatToStr(CurCD.Mean)+' '+FloatToStr(CurCD.StdDev));
   Result:=CurCD.Pos;
end;       
procedure TForm1.Button1Click(Sender: TObject);
var
   BlkMarker:Byte;
begin
   BlkMarker:=GetBlockChar(Edit1.Text);
   ShowMessage(IntToHex(BlkMarker,2));
end;

end.
