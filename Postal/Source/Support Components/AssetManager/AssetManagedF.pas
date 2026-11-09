unit AssetManagedF;

interface

uses
	AssetManager_TLB,
	SavePosFormU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TAssetManagedForm = class(TSavePosForm)
  private
    { Private declarations }
    FAssetManager : IAssetManager;
  protected
    procedure SetAssetManager(Value : IAssetManager); virtual;
  public
    { Public declarations }
    property AssetManager : IAssetManager read FAssetManager write SetAssetManager;
  end;

var
  AssetManagedForm: TAssetManagedForm;

implementation

{$R *.DFM}

procedure TAssetManagedForm.SetAssetManager(Value : IAssetManager);
begin
	If FAssetManager <> Value then
  	FAssetManager := Value;
end;

end.

