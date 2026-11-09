unit PropertyEditFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ZPropLst, StdCtrls, ComCtrls,SavePosFormU;

type
  TPropEdit = class(TSavePosForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    PropList:TZPropList;
    { Public declarations }
  end;

var
  PropEdit: TPropEdit;

implementation

{$R *.DFM}

procedure TPropEdit.FormCreate(Sender: TObject);
begin
    PropList:=TZPropList.Create(Self);
    TabSheet1.InsertControl(PropList);
    PropList.Align:=alClient;
end;

end.
