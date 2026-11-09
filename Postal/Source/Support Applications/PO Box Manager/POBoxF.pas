unit POBoxF;

interface

uses
  POBoxManager_TLB,
  Math,
  SavePosFormU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, checklst, ExtCtrls, CommaTextEditMemoU,
  EditCheckListBoxU;

type
  TPOBoxForm = class(TSavePosForm)
    BoxBottomPanel: TPanel;
    BoxUpdateButton: TButton;
    BoxDeleteButton: TButton;
    OwnerButton: TButton;
    BoxDetailsPanel: TPanel;
    BoxBlockNumberLabel: TLabel;
    BoxDepositHeldLabel: TLabel;
    BoxFeaturesLabel: TLabel;
    BoxKeysIssuedLabel: TLabel;
    BoxLockNumberLabel: TLabel;
    BoxStateLabel: TLabel;
    BoxStyleLabel: TLabel;
    BoxXCoordLabel: TLabel;
    BoxYCoordLabel: TLabel;
    BoxWidthLabel: TLabel;
    BoxDepthLabel: TLabel;
    BoxHeightLabel: TLabel;
    BoxOwnerLabel: TLabel;
    BoxRenewalDateLabel: TLabel;
    BoxBlockNumberEdit: TEdit;
    BoxDepositHeldEdit: TEdit;
    BoxKeysIssuedEdit: TEdit;
    BoxLockNumberEdit: TEdit;
    BoxStyleEdit: TEdit;
    BoxXCoordEdit: TEdit;
    BoxYCoordEdit: TEdit;
    BoxWidthEdit: TEdit;
    BoxDepthEdit: TEdit;
    BoxHeightEdit: TEdit;
    BoxOwnerEdit: TEdit;
    BoxRenewalDateEdit: TEdit;
    BoxFeaturesCommaTextEditMemo: TCommaTextEditMemo;
    BoxStateEditCheckListBox: TEditCheckListBox;
    procedure BoxUpdateButtonClick(Sender: TObject);
    procedure BoxDeleteButtonClick(Sender: TObject);
    procedure OwnerButtonClick(Sender: TObject);
  private
    { Private declarations }
    FPOBox : IPOBox;
    procedure SetPOBox(Value : IPOBox);
  public
    { Public declarations }
    property POBox : IPOBox read FPOBox write SetPOBox;
    procedure UpdateFormDetails(Box : IPOBox);    
  end;

var
  POBoxForm: TPOBoxForm;

implementation

{$R *.DFM}

procedure TPOBoxForm.BoxUpdateButtonClick(Sender: TObject);
begin
  If POBox <> nil then
  begin
    POBox.BlockNumber  := StrToInt(BoxBlockNumberEdit.Text);
    POBox.DepositHeld  := StrToCurr(BoxDepositHeldEdit.Text);
    POBox.Features     := BoxFeaturesCommaTextEditMemo.Lines.CommaText;
    POBox.KeysIssued   := StrToInt(BoxKeysIssuedEdit.Text);
    POBox.LockNumber   := StrToInt(BoxLockNumberEdit.Text);
    POBox.RenewalDate  := StrToDateTime(BoxRenewalDateEdit.Text);
    POBox.State        := BoxStateEditCheckListBox.Value;
    POBox.Style        := StrToInt(BoxStyleEdit.Text);
    POBox.XCoord       := StrToInt(BoxXCoordEdit.Text);
    POBox.YCoord       := StrToInt(BoxYCoordEdit.Text);
  end;
  UpdateFormDetails(POBox);
end;

procedure TPOBoxForm.BoxDeleteButtonClick(Sender: TObject);
begin
  If FPOBox <> nil then
  begin
    FPOBox.Delete;
  end;
  UpdateFormDetails(FPOBox);
end;

procedure TPOBoxForm.UpdateFormDetails(Box : IPOBox);
begin
  If FPOBox <> nil then
  begin
    Caption := 'PO Box ' + IntToStr(Box.Number)
              + ' in Office ' + IntToStr(Box.Office.Number);

    BoxBlockNumberEdit.Text  := IntToStr(Box.BlockNumber);
    BoxDepositHeldEdit.Text  := CurrToStr(Box.DepositHeld);
    BoxFeaturesCommaTextEditMemo.Lines.CommaText := Box.Features;
    BoxKeysIssuedEdit.Text   := IntToStr(Box.KeysIssued);
    BoxLockNumberEdit.Text   := IntToStr(Box.LockNumber);
    BoxOwnerEdit.Text        := IntToStr(Box.Owner.Identifier);
    BoxRenewalDateEdit.Text  := DateTimeToStr(Box.RenewalDate);
    BoxStateEditCheckListBox.Value  := Box.State;
    BoxStyleEdit.Text        := IntToStr(Box.Style);
    BoxWidthEdit.Text        := IntToStr(Box.Width);
    BoxDepthEdit.Text        := IntToStr(Box.Depth);
    BoxHeightEdit.Text       := IntToStr(Box.Height);
    BoxXCoordEdit.Text       := IntToStr(Box.XCoord);
    BoxYCoordEdit.Text       := IntToStr(Box.YCoord);
  end
  else
  begin
    Caption := 'PO Box (None)';
    BoxBlockNumberEdit.Text  := '';
    BoxDepositHeldEdit.Text  := '';
    BoxFeaturesCommaTextEditMemo.Lines.Clear;
    BoxKeysIssuedEdit.Text   := '';
    BoxLockNumberEdit.Text   := '';
    BoxOwnerEdit.Text        := '';
    BoxRenewalDateEdit.Text  := '';
    BoxStateEditCheckListBox.Value := 0;
    BoxStyleEdit.Text        := '';
    BoxWidthEdit.Text        := '';
    BoxDepthEdit.Text        := '';
    BoxHeightEdit.Text       := '';
    BoxXCoordEdit.Text       := '';
    BoxYCoordEdit.Text       := '';
  end;
end;

procedure TPOBoxForm.SetPOBox(Value : IPOBox);
begin
  If FPOBox <> Value then
  begin
    FPOBox := nil;
    FPOBox := Value;
    UpdateFormDetails(FPOBox);
  end;
end;


procedure TPOBoxForm.OwnerButtonClick(Sender: TObject);
begin
  FPOBox.Owner.Visible := True;
end;

end.
