unit AssetDropF;

interface

uses

  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, Db, DBTables, StdCtrls, Mask, DBCtrls;

type
  TAssetDropForm = class(TForm)
    CodeLabel: TLabel;
    DescriptionLabel: TLabel;
    CodeEdit: TEdit;
    DescriptionEdit: TEdit;
    procedure FormShow(Sender: TObject);
    procedure DescriptionEditChange(Sender: TObject);
    procedure CodeEditClick(Sender: TObject);
    procedure DescriptionEditClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AssetDropForm: TAssetDropForm;

implementation

uses
  AssetManager_TLB,
  StructureNodeU, StructureNodeButtonU,
  AssetNodeU;

{$R *.DFM}

procedure TAssetDropForm.FormShow(Sender: TObject);
var
  Asset : IAsset;
  DropDownButton : TStructureNodeButton;
begin
  //ensure drop button is synched - esp. after streaming in
  DropDownButton := TStructureNodeButton((Parent As TStructureNode).Buttons[0]);
  DropDownButton.Down := True;
  DropDownButton.Update;

  ParentFont := True;

  If (Parent As TAssetNode).AssociatedObject As IAsset <> nil then
  begin
    Asset := (Parent As TAssetNode).AssociatedObject As IAsset;
    CodeEdit.Text         := Asset.Code;
    DescriptionEdit.Text  := Asset.Description
  end;
end;


procedure TAssetDropForm.DescriptionEditChange(Sender: TObject);
begin
  ((Parent As TAssetNode).AssociatedObject as IAsset).Description := DescriptionEdit.Text;
end;

procedure TAssetDropForm.CodeEditClick(Sender: TObject);
begin
  (Sender as TEdit).SetFocus;
end;

procedure TAssetDropForm.DescriptionEditClick(Sender: TObject);
begin
  (Sender as TEdit).SetFocus;
end;


end.
