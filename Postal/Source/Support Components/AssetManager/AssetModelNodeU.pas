unit AssetModelNodeU;

interface

uses
  AssetManagerStructureNodeU,
  AssetManager_TLB,
	Windows,
  Classes,
  Controls,
  Graphics;


type
  TAssetModelNode = class(TAssetManagerStructureNode)
  protected
		procedure Paint; override;
    procedure Set_AssetManager(Value : IAssetManager); override;
    procedure DragOver(Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean); override;
  public
    constructor Create(AOwner : TComponent); override;
    function LogAssetEntry(const AssetEntry : IAssetEntry) : AMStatus;
  published
  end;

implementation

uses
	SysUtils,
	AssetTriggerNodeU,
  StructureNodeU,
	AssetModelNodeDropF;

procedure TAssetModelNode.Set_AssetManager(Value : IAssetManager);
begin
  Inherited;
  If AssetManager <> nil then
    AssociatedObject := AssetManager.AssetModels[Caption];
end;

constructor TAssetModelNode.Create(AOwner : TComponent);
begin
  Inherited Create(AOwner);

  //default props
  Font.Color := clWhite;
  Color := clBlue;
  Width := 100;
  DropFormClass := TAssetModelNodeDropForm;
end;

procedure TAssetModelNode.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Inherited;
  If Source is TAssetTriggerNode then
    Accept := True
  else
    Accept := False;
end;

function TAssetModelNode.LogAssetEntry(const AssetEntry : IAssetEntry) : AMStatus;
var
  AssetModel  		: IAssetModel;
  ConnectorIndex  : Integer;
  OrigCode    		: WideString;
  TriggerNode : TAssetTriggerNode;
begin
  Color := Color + (clRed + clBlue + clGreen);
  Refresh;
  Sleep(100);
  Color := Color - (clRed + clBlue + clGreen);
  Refresh;

  //save original asset code;
  OrigCode := AssetEntry.Code;

  //log the asset entry in this assetmodel
  AssetModel := AssociatedObject as IAssetModel;
  AssetModel.LogAssetEntry(AssetEntry);

	//restore
	AssetEntry.Code := OrigCode;

  //bounce up stream
  For ConnectorIndex := 0 to ConnectorsOut.Count -1 do
  begin
    If TStructureNodeConnector(ConnectorsOut[ConnectorIndex]).ParentNode is TAssetTriggerNode then
    begin
      TriggerNode := TStructureNodeConnector(ConnectorsOut[ConnectorIndex]).ParentNode as TAssetTriggerNode;
      TriggerNode.LogAssetEntry(AssetEntry);
    end;
  end;
  Result := amSuccess;
end;

procedure TAssetModelNode.Paint;
var
	RealCaption : String;
begin
	//adjust caption for display
  RealCaption := Caption;
  Caption := Copy(Caption,LastDelimiter('\',Caption)+1,Length(Caption));
	Inherited;
  Caption := RealCaption;

end;

initialization
  RegisterClass(TAssetModelNode);

end.
