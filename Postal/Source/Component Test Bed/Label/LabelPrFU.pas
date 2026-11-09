unit LabelPrFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, ExtCtrls,SavePosFormU;

type
  TForm1 = class(TSavePosForm)
    StringGrid1: TStringGrid;
    Panel1: TPanel;
    Button1: TButton;
    NEdit: TEdit;
    Label1: TLabel;
    WEdit: TEdit;
    Label2: TLabel;
    FEdit: TEdit;
    Label3: TLabel;
    ZEdit: TEdit;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    procedure PrintLabel(ID,Weight,PostCode,Value,DateTime,Clerk,Position,Office:String);
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.PrintLabel(ID,Weight,PostCode,Value,DateTime,Clerk,Position,Office:String);
var
   GridRect:TGridRect;
begin
   StringGrid1.RowCount:=StringGrid1.RowCount+1;
   StringGrid1.Cells[0,StringGrid1.RowCount-2]:=ID      ;
   StringGrid1.Cells[1,StringGrid1.RowCount-2]:=Weight  ;
   StringGrid1.Cells[2,StringGrid1.RowCount-2]:=PostCode;
   StringGrid1.Cells[3,StringGrid1.RowCount-2]:=Value   ;
   StringGrid1.Cells[4,StringGrid1.RowCount-2]:=DateTime;
   StringGrid1.Cells[5,StringGrid1.RowCount-2]:=Clerk   ;
   StringGrid1.Cells[6,StringGrid1.RowCount-2]:=Position;
   StringGrid1.Cells[7,StringGrid1.RowCount-2]:=Office  ;
   GridRect.Top :=StringGrid1.RowCount-2;
   GridRect.Left:=0;
   GridRect.Right:=8;
   GridRect.Bottom:=StringGrid1.RowCount-2;
   StringGrid1.Selection:=GridRect;
end;
procedure TForm1.FormCreate(Sender: TObject);
begin
   StringGrid1.Rows[0].Commatext:='Identifier,Weight,"Post Code",Price,"Date/Time",Clerk,Workstation,Office';
end;

procedure TForm1.Button1Click(Sender: TObject);
var
   I:Integer;
begin
   for I:=1 to StringGrid1.RowCount do StringGrid1.Rows[I].Commatext:=',,,,,,,';
   StringGrid1.RowCount:=2;
end;                       

procedure TForm1.FormShow(Sender: TObject);
begin
   Left:=0-Width;
end;

end.
