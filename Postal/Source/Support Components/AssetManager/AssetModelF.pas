unit AssetModelF;

interface

uses
  AssetManagedU,
  Windows,
  Messages,
  DBTables,
  ComServ2,
  Controls,
  StructureNodeU,
  AssetNodeU,
  AssetTriggerNodeU,
  SysUtils,
  Classes,
  Forms, AssetManager_TLB, ComObj, SavePosFormU, StdCtrls, ComCtrls,
  ExtCtrls;

type
  TStructureNodeClass = class of TStructureNode;

  TAssetModel = class;

  TAssetModelForm = class(TForm)
    NodeListsPageControl: TPageControl;
    AssetsTabSheet: TTabSheet;
    AssetsListBox: TListBox;
    Splitter1: TSplitter;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FormDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormClick(Sender: TObject);
  private
    { Private declarations }
    procedure WMSize(var Message : TWMSize); message WM_SIZE;
  public
    { Public declarations }
    AssetModel : TAssetModel;
  end;

  TAssetModel = class(TAssetManaged, IAssetModel)
  private
    FFileName : WideString;
    Assets : TStringList;
  protected
    function Get_FileName : WideString; safecall;
    procedure Initialize; override;
    destructor Destroy; override;
    procedure Set_Manager(const Value : IAssetManager); override; safecall;
  public
    Form : TAssetModelForm;
    property FileName: WideString read Get_FileName;
    procedure LoadFromFile(const FileName: WideString); safecall;
    function LogAssetEntry(const AssetEntry: IAssetEntry): AMStatus; safecall;
    procedure SaveToFile(const FileName: WideString); safecall;
  end;

implementation

uses
  ComponentUtil,
	AssetManagerAU,
  AssetManagerStructureNodeU,
  AssetModelsF, Dialogs, AssetManagerDM, MainF;

{$R *.DFM}


procedure TAssetModel.Set_Manager(const Value : IAssetManager);
var
  CompIndex : Integer;
begin
  Inherited Set_Manager(Value);

  //update manager for the nodes
  For CompIndex := 0 to Form.ComponentCount -1 do
  begin
    If Form.Components[CompIndex] is TAssetManagerStructureNode then
    begin
      (Form.Components[CompIndex] as TAssetManagerStructureNode).AssetManager := Value;
    end;
  end;
end;

function TAssetModel.Get_FileName : WideString;
begin
  Result := FFileName;
end;

procedure TAssetModel.LoadFromFile(const FileName : WideString);
var
  CompIndex : Integer;
  OpenFile : TFileStream;

  procedure FillNodeList(NodeList : TStringList; NodeClassName : String);
  var
    NodeIndex : Integer;
    StructureNode : TStructureNode;
  begin
    //reset list
    for NodeIndex := 0 to NodeList.Count -1 do
      NodeList.Delete(NodeIndex);

    //fill list
    For NodeIndex := 0 to Form.ControlCount -1 do
    begin
      If Form.Controls[NodeIndex].ClassName = NodeClassName then
      begin
        StructureNode := Form.Controls[NodeIndex] As TStructureNode;
        NodeList.AddObject(StructureNode.Caption, StructureNode);
      end;
    end;
  end;

begin
  If FFileName <> FileName then
  begin
    //free current components
    For CompIndex := Form.ComponentCount-1 downto 0 do
    begin
      Form.Components[CompIndex].Free;
    end;
    Form.Name := '';

    //stream model from file
    OpenFile := TFileStream.Create(FileName, fmOpenRead or fmShareExclusive);
    try
    	OpenFile.ReadComponent(Form);
      //populate lists
      FillNodeList(Assets, 'TAssetNode');
      If Assets <> nil then
      	Form.AssetsListBox.Items.Assign(Assets);

      //update filename
      FFileName := FileName;
      Form.Caption := 'Asset Model - ' + FFileName;
    finally
      OpenFile.Free;
    end;
  end;
end;

procedure TAssetModel.Initialize;
begin
  Inherited;
  _AddRef;
  Form := TAssetModelForm.Create(Application);
  Form.AssetModel := self;
  Assets := TStringList.Create;

end;

destructor TAssetModel.Destroy;
begin
	Form.Visible := False;
  Form.Parent := nil;
  Form.Free;
  Assets.Free;
  Inherited;
end;

function TAssetModel.LogAssetEntry(const AssetEntry: IAssetEntry): AMStatus; safecall;
var
  AssetIndex        : Integer;
  AssetNode         : TAssetNode;
begin
  AssetManagerDataModule.AssetDatabase.StartTransaction;
  try
    //find matching assets
    For AssetIndex := 0 to Assets.Count -1 do
    begin
      If Assets.Strings[AssetIndex] = AssetEntry.Code then
      begin
        AssetNode := (Assets.Objects[AssetIndex] As TAssetNode);
        AssetNode.LogAssetEntry(AssetEntry);
      end;
    end;
    AssetManagerDataModule.AssetDatabase.Commit;
  except
    AssetManagerDataModule.AssetDatabase.Rollback;
  end;
end;

procedure TAssetModel.SaveToFile(const FileName : WideString);
var
  SaveFile : TFileStream;
begin

  //check for valid filename
  If FileName <> '' then
  begin
    SaveFile := TFileStream.Create(FileName, fmCreate or fmShareExclusive);
    try
      //stream components
      SaveFile.WriteComponent(Form);
      Form.Caption := 'Asset Model - ' + FileName;
    finally
      SaveFile.Free;
    end;
  end;
end;

procedure TAssetModelForm.FormActivate(Sender: TObject);
begin
  If Parent is TAssetModelsForm then
    (Parent as TAssetModelsForm).ActiveModel := AssetModel;
end;

procedure TAssetModelForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  If Parent is TAssetModelsForm then
    If (Parent as TAssetModelsForm).ActiveModel = self.AssetModel then
      (Parent as TAssetModelsForm).ActiveModel := nil;

  AssetModel.Manager.CloseModel(AssetModel.FileName);
end;

procedure TAssetModelForm.FormDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  NewNode : TStructureNode;
begin
  //asset node
  If Source is TAssetNode then
  begin
    NewNode := TAssetNode.Create(self);
    With NewNode do
    begin
      Parent := self;
      NewNode.Name := ValidControlName(NewNode);

      Left := X;
      Top := Y;
      Caption := (Source As TAssetNode).Caption;
      (NewNode As TAssetNode).AssetManager := MainForm.AssetManager;
    end;
  end
end;

procedure TAssetModelForm.FormDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  If (Source  is TAssetNode) then
    Accept := True
  else
    Accept := False;
end;

procedure TAssetModelForm.WMSIZE(var Message : TWMSize);
begin
  Inherited ;
  If Message.SizeType = SIZE_MINIMIZED then
  begin
    Parent.Width := Parent.Width + 1;
    Parent.Width := Parent.Width - 1;
  end;
end;

procedure TAssetModelForm.FormMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
	//show Assets
  If ((Width -x) < 20)  then
 		NodeListsPageControl.Visible := True
  else
 		NodeListsPageControl.Visible := False;
end;

procedure TAssetModelForm.FormClick(Sender: TObject);
begin
	BringToFront;
  //force repaint
  Parent.Width := Parent.Width + 1;
  Parent.Width := Parent.Width - 1;
end;

initialization
	RegisterClass(TAssetModelForm);
  TAutoObjectFactory.Create(ComServer, TAssetModel, Class_AssetModel, ciInternal);

end.
