unit breport;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBTables, DB, Grids, DBGrids, ExtCtrls, DBCtrls;

type
  TForm2 = class(TForm)
    DataSource1: TDataSource;
    Table1: TTable;
    DBGrid1: TDBGrid;
    Table1Country: TStringField;
    Table1Date: TDateField;
    Table1StartLabel: TStringField;
    Table1EndLabel: TStringField;
    Table1LabelCount: TIntegerField;
    Table1BadLabels: TSmallintField;
    Button1: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.DFM}

end.
 