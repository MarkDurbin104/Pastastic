unit AssetTriggerDropF;

interface

uses
  AssetManager_TLB,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TAssetTriggerDropForm = class(TForm)
    Memo: TMemo;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AssetTriggerDropForm: TAssetTriggerDropForm;

implementation
uses
  ComObj,
  AssetTriggerNodeU;
{$R *.DFM}



procedure TAssetTriggerDropForm.FormShow(Sender: TObject);
var
  AssetTriggerNode : TAssetTriggerNode;
begin
  AssetTriggerNode := (Parent as TAssetTriggerNode);
  If AssetTriggerNode.AssociatedObject = nil then
  	If AssetTriggerNode.AssetManager <> nil then
    begin
    	AssetTriggerNode.AssociatedObject := AssetTriggerNode.AssetManager.Trigger[AssetTriggerNode.Caption]
    end;

  If AssetTriggerNode.AssociatedObject <> nil then
    Memo.Text := (AssetTriggerNode.AssociatedObject As IAssetTrigger).TriggerCode;
end;

end.
