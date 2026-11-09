unit DataControlPaletteF;

interface

uses
	SavePosFormU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ToolWin, ComCtrls, DBCompressImageU;

type
  TControlPaletteForm = class(TSavePosForm)
    ToolBar: TToolBar;
    DBGridToolButton: TToolButton;
    DBEditToolButton: TToolButton;
    ImageList: TImageList;
    DBMemoToolButton: TToolButton;
    DBImageToolButton: TToolButton;
    procedure ToolButtonStartDrag(Sender: TObject;
      var DragObject: TDragObject);
  private
    { Private declarations }
  public
    { Public declarations }
    SelectedControlClass : TWinControlClass;
  end;

var
  ControlPaletteForm: TControlPaletteForm;

implementation

{$R *.DFM}

uses
	DBCtrls,
	DBGrids;

procedure TControlPaletteForm.ToolButtonStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
	If Sender = DBGridToolButton then SelectedControlClass := TDBGrid
  else 	If Sender = DBEditToolButton then SelectedControlClass := TDBEdit
  else 	If Sender = DBMemoToolButton then SelectedControlClass := TDBMemo
  else 	If Sender = DBImageToolButton then SelectedControlClass := TDBCompressImage
  else 	SelectedControlClass := nil;
end;

end.
