unit TableViewF;

interface

uses
  SAvePosFormU,
  MemoFieldViewF,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, Db, DBTables, StdCtrls, DBCtrls;

type
  TTableViewForm = class(TSavePosForm)
    DataSource: TDataSource;
    Table: TTable;
    DBGrid: TDBGrid;
    procedure DBGridColEnter(Sender: TObject);
    procedure DBGridColExit(Sender: TObject);
  private
    { Private declarations }
    FTableName : String;
    FDatabaseName : String;

    MemoViewForm : TMemoFieldViewForm;

    procedure SetupTable(DatabaseName , TableName : String);
    procedure SetDatabaseName(Value : String);
    procedure SetTableName(Value : String);
  public
    { Public declarations }
  published
    property DatabaseName : String read FDatabaseName write SetDatabaseName;
    property TableName    : String read FTableName write SetTableName;
  end;

procedure Register;

var
  TableViewForm: TTableViewForm;

implementation

{$R *.DFM}


procedure TTableViewForm.SetUpTable(DatabaseName , TableName : String);
begin
  Table.Close;
  Table.DatabaseName := DatabaseName;
  Table.TableName := TableName;
  Caption := DatabaseName + ' - ' + Tablename;
  If (DatabaseName <> '') and (TableName <> '') then
    Table.Open;
end;

procedure TTableViewForm.SetDatabaseName(Value : String);
begin
  If FDatabaseName <> Value then
  begin
    FDatabaseName := Value;
    SetUpTable(Value,FTableName);
  end;
end;

procedure TTableViewForm.SetTableName(Value : String);
begin
  If FTableName <> Value then
  begin
    FTableName := Value;
    SetUpTable(FDatabaseName, Value);
  end;
end;

procedure Register;
begin
  RegisterComponents('P.S.L.',[TTableViewForm]);
end;

procedure TTableViewForm.DBGridColEnter(Sender: TObject);
var
  SelField : TField;
begin
  SelField := DBGrid.SelectedField;
  If SelField is TMemoField then
  begin
    If MemoViewForm = nil then
      MemoViewForm := TMemoFieldViewForm.Create(self);
    MemoViewForm.DBMemo.DataSource := self.DataSource;
    MemoViewForm.DBMemo.DataField := SelField.FieldName;
    MemoViewForm.Visible := True;
  end;

end;

procedure TTableViewForm.DBGridColExit(Sender: TObject);
begin
  If MemoViewForm <> nil then
    MemoViewForm.Visible := false;
end;

end.
