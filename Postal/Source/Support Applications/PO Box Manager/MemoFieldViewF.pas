unit MemoFieldViewF;

interface

uses
  SavePosFormU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls;

type
  TMemoFieldViewForm = class(TSavePosForm)
    DBMemo: TDBMemo;
    procedure DBMemoChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MemoFieldViewForm: TMemoFieldViewForm;

implementation

{$R *.DFM}

procedure TMemoFieldViewForm.DBMemoChange(Sender: TObject);
begin
  Caption := DBMemo.DataField;
end;

end.
