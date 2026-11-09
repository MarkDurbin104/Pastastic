unit DataEntryDM;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables;

type
  TDataEntryDataModule = class(TDataModule)
    SQLServerDatabase: TDatabase;
    Table: TTable;
    TableDataSource: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataEntryDataModule: TDataEntryDataModule;

implementation

{$R *.DFM}

end.
