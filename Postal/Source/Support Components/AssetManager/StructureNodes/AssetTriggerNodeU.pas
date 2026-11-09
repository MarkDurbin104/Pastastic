unit AssetTriggerNodeU;

interface

uses
  AssetManagerStructureNodeU,
  AssetManager_TLB,
  AssetTriggerDropF,Dialogs, Controls,
  SysUtils,Graphics,Windows,Classes,StructureNodeU, DropDownStructureNodeU,StructureNodeButtonU;

type
  TAssetTriggerNode = class(TAssetManagerStructureNode)
  protected
    procedure Set_AssetManager(Value : IAssetManager); override;
    procedure DragOver(Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean); override;
  public
    constructor Create(AOwner : TComponent); override;
    function LogAssetEntry(const AssetEntry : IAssetEntry) : AMStatus;
  end;


//{$R *.RES}

implementation

uses
  ComObj,
  ComServ2,
  AssetNodeU,
  AssetModelNodeU;

procedure TAssetTriggerNode.Set_AssetManager(Value : IAssetManager);
begin
  Inherited;
  If AssetManager <> nil then
    AssociatedObject := AssetManager.Trigger[Caption];
end;

constructor TAssetTriggerNode.Create(AOwner : TComponent);
begin
  Inherited Create(AOwner);

  //default props
  Font.Color := clBlack;
  Color := clYellow;
  Width := 200;
  DropFormClass := TAssetTriggerDropForm;
end;

procedure TAssetTriggerNode.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Inherited;
  If (Source is TAssetNode)
  or  (Source is TAssetModelNode)then
    Accept := True
  else
    Accept := False;
end;

function TAssetTriggerNode.LogAssetEntry(const AssetEntry : IAssetEntry) : AMStatus;
var
  AssetTrigger  	: IAssetTrigger;
	Connector				: TStructureNodeConnector;
  ConnectorIndex 	: Integer;
  OrigAmount    	: Currency;
begin
  Color := Color + (clRed + clBlue + clGreen);
  Refresh;
  Sleep(100);
  Color := Color - (clRed + clBlue + clGreen);
  Refresh;

  //save original value
  OrigAmount := AssetEntry.AssetQuantity.Amount;

  //adjust value
  AssetTrigger := (AssociatedObject As IAssetTrigger);
  AssetEntry.AssetQuantity.Amount := AssetTrigger.TriggerValue(AssetEntry.AssetQuantity.Amount);

	//bounce entry upstream
  Result := amSuccess;
  For ConnectorIndex := 0 to ConnectorsOut.Count -1 do
  begin
  	Connector := TStructureNodeConnector(ConnectorsOut[ConnectorIndex]);
    If Connector <> nil then
      if (Connector.ParentNode is TAssetNode) then
        Result := (Connector.ParentNode as TAssetNode).LogAssetEntry(AssetEntry)
      else if (Connector.ParentNode is TAssetModelNode) then
        Result := (Connector.ParentNode as TAssetModelNode).LogAssetEntry(AssetEntry);
  end;

  //restore original amount
  AssetEntry.AssetQuantity.Amount := OrigAmount;
end;

initialization
  RegisterClass(TAssetTriggerNode);

end.
