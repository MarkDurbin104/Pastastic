unit NavOrderF;

interface

uses
	SavePosFormU,
	DataEntryFormF,
	DataEntryMainF, DragLabelU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TNavOrderForm = class(TSavePosForm)
    RightPanel: TPanel;
    MoveUpButton: TButton;
    MoveDownButton: TButton;
    CloseButton: TButton;
    ControlListBox: TListBox;
    procedure FormShow(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure MoveUpButtonClick(Sender: TObject);
    procedure MoveDownButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NavOrderForm: TNavOrderForm;

implementation

{$R *.DFM}

procedure TNavOrderForm.FormShow(Sender: TObject);
var
	DragLabel : TDragLabel;
	ControlIndex : Integer;
begin
	ControlListBox.Clear;
	If DataEntryMainForm.ActiveDataEntryForm <> nil then
  begin
		For ControlIndex := 0 to DataEntryMainForm.ActiveDataEntryForm.ControlCount -1 do
    begin
    	If (DataEntryMainForm.ActiveDataEntryForm.Controls[ControlIndex] is TDragLabel) then
      begin
      	DragLabel := DataEntryMainForm.ActiveDataEntryForm.Controls[ControlIndex]as TDragLabel;
      	ControlListBox.Items.AddObject(DragLabel.Caption, DragLabel.FocusControl);
      end;
    end;
  end;
end;

procedure TNavOrderForm.CloseButtonClick(Sender: TObject);
var
	ControlIndex : Integer;
begin
	//reorder tabs
  For ControlIndex := ControlListBox.Items.Count -1 downto 0 do
  begin
  	(ControlListBox.Items.Objects[ControlIndex] as TWinControl).TabOrder := 0;
  end;
	Close;
end;

procedure TNavOrderForm.MoveUpButtonClick(Sender: TObject);
var
	CurrentItemIndex : Integer;
begin
	If (ControlListBox.ItemIndex > 0) then
  begin
  	CurrentItemIndex := ControlListBox.ItemIndex;
		ControlListBox.Items.Move(ControlListBox.ItemIndex, ControlListBox.ItemIndex-1);
		ControlListBox.ItemIndex := CurrentItemIndex -1;
  end;
end;

procedure TNavOrderForm.MoveDownButtonClick(Sender: TObject);
var
	CurrentItemIndex : Integer;
begin
	If (ControlListBox.ItemIndex > -1) and (ControlListBox.ItemIndex < (ControlListBox.Items.Count-1)) then
  begin
  	CurrentItemIndex := ControlListBox.ItemIndex;
		ControlListBox.Items.Move(ControlListBox.ItemIndex, ControlListBox.ItemIndex+1);
		ControlListBox.ItemIndex := CurrentItemIndex + 1 ;
  end;
end;

end.
