unit AssetBalanceF;

interface

uses
  AssetManagerDM,
  SavePosFormU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Db, DBTables, ToolWin, Grids, DBGrids;

type
  TAssetBalanceForm = class(TSavePosForm)
    MainPageControl: TPageControl;
    DataTabSheet: TTabSheet;
    AssetBalanceDBGrid: TDBGrid;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AssetBalanceForm: TAssetBalanceForm;

implementation

uses MainF;

{$R *.DFM}

procedure TAssetBalanceForm.FormCreate(Sender: TObject);
begin
  //determine whether to show or not
  Visible := MainForm.AssetToolButton.Down;
end;

end.
