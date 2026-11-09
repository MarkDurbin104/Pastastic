unit AssetNodeU;

interface

uses
  AssetManagerStructureNodeU,
  AssetManager_TLB,
  Forms,
  AssetDropF,Dialogs, Controls,
  SysUtils,Graphics,Windows, Classes,StructureNodeU, DropDownStructureNodeU,StructureNodeButtonU;

type
  TAssetNode = class(TAssetManagerStructureNode)
  protected
    procedure Set_AssetManager(Value : IAssetManager); override;
    procedure DragOver(Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean); override;
  public
    constructor Create(AOwner : TComponent); override;
    function LogAssetEntry(const AssetEntry : IAssetEntry) : AMStatus;
  end;

{$R *.RES}

implementation

uses
  AssetEntryU,
  AssetTriggerNodeU;

procedure TAssetNode.Set_AssetManager(Value : IAssetManager);
begin
  Inherited;
  If AssetManager <> nil then
    AssociatedObject := AssetManager.Asset[Caption];
end;

constructor TAssetNode.Create(AOwner : TComponent);
begin
  Inherited Create(AOwner);

  //default props
  Font.Color := clWhite;
  Color := clRed;
  Width := 100;
  DroppedWidth := Width;
  DroppedHeight := 50;
  DropFormClass := TAssetDropForm;
end;

procedure TAssetNode.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Inherited;
  If Source is TAssetTriggerNode then
    Accept := True
  else
    Accept := False;
end;

function TAssetNode.LogAssetEntry(const AssetEntry : IAssetEntry) : AMStatus;
var
  Asset       : IAsset;
	Connector				: TStructureNodeConnector;
  ConnectorIndex 	: Integer;
  OrigCode    : WideString;
begin
  Color := Color + (clRed + clBlue + clGreen);
  Refresh;
  Sleep(100);
  Color := Color - (clRed + clBlue + clGreen);
  Refresh;

  //save original asset code;
  OrigCode := AssetEntry.Code;

  //log the asset entry for this asset
  Asset := AssociatedObject as IAsset;
  //change code to this asset
  AssetEntry.Code := Asset.Code;
  AssetEntry.Log;

	//bounce entry upstream
  Result := amSuccess;

  For ConnectorIndex := 0 to ConnectorsOut.Count -1 do
  begin
  	Connector := TStructureNodeConnector(ConnectorsOut[ConnectorIndex]);
    If Connector <> nil then
      if (Connector.ParentNode is TAssetTriggerNode) then
        Result := (Connector.ParentNode as TAssetTriggerNode).LogAssetEntry(AssetEntry);
  end;

  AssetEntry.Code := OrigCode;
end;

initialization

  RegisterClass(TAssetNode);
  RegisterClass(TAssetDropForm);

end.
