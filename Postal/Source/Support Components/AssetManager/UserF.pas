unit UserF;

interface

uses
  AssetManager_TLB,
  AssetManagedF,
  AssetManagerAU,
  SavePosFormU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TUserForm = class(TAssetManagedForm)
    SiteLabel: TLabel;
    SiteEdit: TEdit;
    WorkstationLabel: TLabel;
    WorkstationEdit: TEdit;
    UserLabel: TLabel;
    UserEdit: TEdit;
    UpdateButton: TButton;
    CancelButton: TButton;
    PeriodLabel: TLabel;
    PeriodEdit: TEdit;
    procedure FormShow(Sender: TObject);
    procedure UpdateButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
  private
    { Private declarations }
    procedure SetAssetManager(Value : IAssetManager); override;
    procedure UpdateAssetManager;
  public
    { Public declarations }
  end;

var
  UserForm: TUserForm;

implementation

{$R *.DFM}

procedure TUserForm.SetAssetManager(Value : IAssetManager);
begin
	Inherited;
  UpdateAssetManager;
end;

procedure TUserForm.FormShow(Sender: TObject);
begin
  try
    //first time
    SiteEdit.Text         := AssetManager.Site;
    WorkstationEdit.Text  := AssetManager.Workstation;
    UserEdit.Text         := AssetManager.Person.Name;
  except
    ;
  end;
end;

procedure TUserForm.UpdateAssetManager;
begin
  AssetManager.Site := SiteEdit.Text;
  AssetManager.Workstation := WorkstationEdit.Text;
  AssetManager.Person.Name := UserEdit.Text;
  AssetManager.Period := StrToIntDef(PeriodEdit.Text,0);
end;

procedure TUserForm.UpdateButtonClick(Sender: TObject);
begin
  UpdateAssetManager;
  Hide;
end;

procedure TUserForm.CancelButtonClick(Sender: TObject);
begin
  Hide;
end;

end.
