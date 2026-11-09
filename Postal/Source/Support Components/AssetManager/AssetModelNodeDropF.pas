unit AssetModelNodeDropF;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TAssetModelNodeDropForm = class(TForm)
    Memo: TMemo;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AssetModelNodeDropForm: TAssetModelNodeDropForm;

implementation
uses
	AssetManager_TLB,
	AssetModelNodeU;

{$R *.DFM}
procedure TAssetModelNodeDropForm.FormShow(Sender: TObject);
var
  AssetModelNode : TAssetModelNode;
begin
  AssetModelNode := (Parent as TAssetModelNode);
  If AssetModelNode.AssociatedObject = nil then
  	If AssetModelNode.AssetManager <> nil then
    	AssetModelNode.AssociatedObject := AssetModelNode.AssetManager.AssetModels[AssetModelNode.Caption];

  If AssetModelNode.AssociatedObject <> nil then
    Memo.Text := (AssetModelNode.AssociatedObject As IAssetModel).FileName;
end;

initialization
  RegisterClass(TAssetModelNodeDropForm);

end.
