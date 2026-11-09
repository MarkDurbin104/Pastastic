unit AccountManagerClientF;

interface

uses
  GridUtil,
  SavePosFormU,
  ComObj,
  AccountManager_TLB,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids;

type
  TAccountManagerClientForm = class(TSavePosForm)
    BottomPanel: TPanel;
    ExitButton: TButton;
    TopPanel: TPanel;
    MachineNameEdit: TEdit;
    MachineNameLabel: TLabel;
    SiteLabel: TLabel;
    SiteEdit: TEdit;
    WorkstationEdit: TEdit;
    WorkstationLabel: TLabel;
    PersonLabel: TLabel;
    PersonEdit: TEdit;
    PeriodEdit: TEdit;
    PeriodLabel: TLabel;
    OPerationPanel: TPanel;
    ResetButton: TButton;
    LogItemButton: TButton;
    GroupEdit: TEdit;
    GroupLabel: TLabel;
    QuantityEdit: TEdit;
    QuantityLabel: TLabel;
    ValueEdit: TEdit;
    ValueLabel: TLabel;
    StringGrid: TStringGrid;
    AccountGroupTotalButton: TButton;
    ParentButton: TButton;
    ItemEdit: TEdit;
    ItemLabel: TLabel;
    AdjustGroupButton: TButton;
    ChildrenButton: TButton;
    DestroyButton: TButton;
    CreateButton: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ExitButtonClick(Sender: TObject);
    procedure ResetButtonClick(Sender: TObject);
    procedure LogItemButtonClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure AccountGroupTotalButtonClick(Sender: TObject);
    procedure ParentButtonClick(Sender: TObject);
    procedure CreateButtonClick(Sender: TObject);
    procedure DestroyButtonClick(Sender: TObject);
    procedure ChildrenButtonClick(Sender: TObject);
    procedure StringGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    AccountManager : IGPCSAccountManager;
  public
    { Public declarations }
  end;

var
  AccountManagerClientForm: TAccountManagerClientForm;

implementation

{$R *.DFM}

procedure TAccountManagerClientForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  AccountManager := nil;
end;

procedure TAccountManagerClientForm.ExitButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TAccountManagerClientForm.ResetButtonClick(Sender: TObject);
begin
  AccountManager.Site := SiteEdit.Text;
  AccountManager.Workstation := WorkstationEdit.Text;
  AccountManager.Person := PersonEdit.Text;
  AccountManager.Period := StrToIntDef(PeriodEdit.Text,0);
  
  If amSuccess <> AccountManager.Reset then
    ShowMessage('Unable to reset accounts');
end;

procedure TAccountManagerClientForm.LogItemButtonClick(Sender: TObject);
begin
  AccountManager.Site := SiteEdit.Text;
  AccountManager.Workstation := WorkstationEdit.Text;
  AccountManager.Person := PersonEdit.Text;
  AccountManager.Period := StrToIntDef(PeriodEdit.Text,0);

  If amSuccess <>AccountManager.LogGroup(ItemEdit.Text,
                          StrToIntDef(QuantityEdit.Text,0),
                          StrToIntDef(ValueEdit.Text,0)) then
    ShowMessage('Unable to log group');

end;

procedure TAccountManagerClientForm.FormResize(Sender: TObject);
begin
  //resize grid cols
  ResizeGridCols(StringGrid);
end;

procedure TAccountManagerClientForm.AccountGroupTotalButtonClick(
  Sender: TObject);
var
  GroupTotalCommaText : String;
begin
  AccountManager.Site := SiteEdit.Text;
  AccountManager.Workstation := WorkstationEdit.Text;
  AccountManager.Person := PersonEdit.Text;
  AccountManager.Period := StrToIntDef(PeriodEdit.Text,0);

  GroupTotalCommaText := AccountManager.AccountGroupTotalCommaText(GroupEdit.Text);
  If Trim(GroupTotalCommaText) <> '' then //children found
    CommaTextIntoGrid(StringGrid, GroupTotalCommaText);
  ResizeGridCols(StringGrid);
end;

procedure TAccountManagerClientForm.ParentButtonClick(
  Sender: TObject);
begin
  AccountManager.Site := SiteEdit.Text;
  AccountManager.Workstation := WorkstationEdit.Text;
  AccountManager.Person := PersonEdit.Text;
  AccountManager.Period := StrToIntDef(PeriodEdit.Text,0);

  CommaTextIntoGrid(StringGrid,
    AccountManager.AccountGroupParents(GroupEdit.Text));
  ResizeGridCols(StringGrid);
end;

procedure TAccountManagerClientForm.CreateButtonClick(Sender: TObject);
begin
//  AccountManager := CoGPCSAccountManager.CreateRemote(MachineNameEdit.Text);
  AccountManager := CoGPCSAccountManager.Create;
  If AccountManager <> nil then
  begin
    self.ResetButton.Enabled := True;
    self.LogItemButton.Enabled := True;
    self.AdjustGroupButton.Enabled := True;
    self.DestroyButton.Enabled := True;
    self.AccountGroupTotalButton.Enabled := True;
    self.ParentButton.Enabled := True;
    self.ChildrenButton.Enabled := True;

  end;
end;

procedure TAccountManagerClientForm.DestroyButtonClick(Sender: TObject);
begin
  AccountManager := nil;
  self.ResetButton.Enabled := False;
  self.LogItemButton.Enabled := False;
  self.AdjustGroupButton.Enabled := False;
  self.DestroyButton.Enabled := False;
  self.AccountGroupTotalButton.Enabled := False;
  self.ParentButton.Enabled := False;
  self.ChildrenButton.Enabled := False;

end;

procedure TAccountManagerClientForm.ChildrenButtonClick(Sender: TObject);
begin
  AccountManager.Site := SiteEdit.Text;
  AccountManager.Workstation := WorkstationEdit.Text;
  AccountManager.Person := PersonEdit.Text;
  AccountManager.Period := StrToIntDef(PeriodEdit.Text,0);

  CommaTextIntoGrid(StringGrid,
    AccountManager.AccountGroupChildren(GroupEdit.Text));
  ResizeGridCols(StringGrid);
end;

procedure TAccountManagerClientForm.StringGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  With StringGrid do
  begin
    GroupEdit.Text :=  Cells[0, Row]; //update group
    if Button = mbLeft then //drill down
    begin
      AccountGroupTotalButtonClick(Sender)
    end
    else if Button = mbRight then //show Parents
    begin
      ParentButtonClick(Sender);
    end;
  end;
end;

end.
