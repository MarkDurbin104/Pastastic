unit DeleteNewerFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, StdCtrls,GPCSGUID;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Query1: TQuery;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
   with Query1 do
   begin
      SQL.Text:='Delete from txnlog where Period > '+IntToStr(GetTodayasPeriod+1);
      ExecSQL;
   end;
end;

end.
