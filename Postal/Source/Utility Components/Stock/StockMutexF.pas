unit StockMutexF;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TStockMutexForm = class(TForm)
    RetryButton: TButton;
    ShutdownButton: TButton;
    WarningLabel: TLabel;
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  StockMutexForm: TStockMutexForm;

implementation

{$R *.DFM}

end.
