unit POBoxOfficeF;

interface

uses
  Math,
  POBoxManager_TLB,
  SavePosFormU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, checklst, CommaTextEditMemoU,
  EditCheckListBoxU;

type
  TPOBoxOfficeForm = class(TSavePosForm)
    PageControl: TPageControl;
    OfficeTabSheet: TTabSheet;
    OfficeTopPanel: TPanel;
    OfficeNameLabel: TLabel;
    OfficeAddressLabel: TLabel;
    OfficeNameEdit: TEdit;
    OfficeAddressMemo: TMemo;
    OfficeBottomPanel: TPanel;
    OfficeListBoxesButton: TButton;
    OfficeListCustomersButton: TButton;
    OfficeUpdateButton: TButton;
    OfficeDeleteButton: TButton;
    BoxesTabSheet: TTabSheet;
    CustomerTabSheet: TTabSheet;
    CreatePanel: TPanel;
    BoxNumberLabel: TLabel;
    BoxEdit: TEdit;
    BoxBottomPanel: TPanel;
    BoxGetButton: TButton;
    AddButton: TButton;
    BoxFindButton: TButton;
    BoxDetailsPanel: TPanel;
    BoxFeaturesLabel: TLabel;
    BoxStateLabel: TLabel;
    BoxFeaturesCommaTextEditMemo: TCommaTextEditMemo;
    BoxStateEditCheckListBox: TEditCheckListBox;
    OfficeBoxesListBox: TListBox;
    OfficeBoxesLabel: TLabel;
    BoxStyleLabel: TLabel;
    BoxStyleEdit: TEdit;
    CustomerBottomPanel: TPanel;
    CustomerGetButton: TButton;
    CustomerAddButton: TButton;
    CustomerBusinessNameButton: TButton;
    CustomerNameButton: TButton;
    CustomerOfficeButton: TButton;
    CustomerClientPanel: TPanel;
    OfficeCustomersListBox: TListBox;
    OfficeCustomersLabel: TLabel;
    CustomerNumberLabel: TLabel;
    CustomerNumberEdit: TEdit;
    ForenamesLabel: TLabel;
    CustomerForenamesEdit: TEdit;
    CustomerBusinessNameEdit: TEdit;
    CustomerBusinessNameLabel: TLabel;
    SurnameLabel: TLabel;
    CustomerSurnameEdit: TEdit;
    procedure OfficeListBoxesButtonClick(Sender: TObject);
    procedure OfficeListCustomersButtonClick(Sender: TObject);
    procedure OfficeUpdateButtonClick(Sender: TObject);
    procedure OfficeDeleteButtonClick(Sender: TObject);
    procedure AddButtonClick(Sender: TObject);
    procedure BoxGetButtonClick(Sender: TObject);
    procedure OfficeBoxesListBoxDblClick(Sender: TObject);
    procedure BoxFindButtonClick(Sender: TObject);
    procedure CustomerAddButtonClick(Sender: TObject);
    procedure CustomerGetButtonClick(Sender: TObject);
//    procedure CustomerUpdateButtonClick(Sender: TObject);
    procedure CustomerNameButtonClick(Sender: TObject);
    procedure CustomerBusinessNameButtonClick(Sender: TObject);
    procedure CustomerOfficeButtonClick(Sender: TObject);
    procedure OfficeCustomersListBoxDblClick(Sender: TObject);
  private
    { Private declarations }
    FPOBoxOffice : IPOBoxOffice;
    procedure GetCustomer(Identifier : Integer);
    procedure GetBox(BoxNumber : Integer);
    procedure SetPOBoxOffice(Value : IPOBoxOffice);
  public
    { Public declarations }
    property Office : IPOBoxOffice read FPOBoxOffice write SetPOBoxOffice;
    procedure UpdateFormDetails(Office : IPOBoxOffice);
  end;

var
  POBoxOfficeForm: TPOBoxOfficeForm;

implementation

{$R *.DFM}
procedure TPOBoxOfficeForm.UpdateFormDetails(Office : IPOBoxOffice);
begin
  If Office <> nil then
  begin
    Caption := 'PO Box Office ' + IntToStr(Office.Number);
    OfficeNameEdit.Text := Office.Name;
    OfficeAddressMemo.Lines.CommaText := Office.Address;
  end
  else
  begin
    Caption := '';
    OfficeNameEdit.Text := '';
    OfficeAddressMemo.Lines.Clear;
  end;
end;

procedure TPOBoxOfficeForm.SetPOBoxOffice(Value : IPOBoxOffice);
begin
  If FPOBoxOffice <> Value then
  begin
    FPOBoxOffice := nil;
    FPOBoxOffice := Value;
    UpdateFormDetails(FPOBoxOffice);
  end;
end;


procedure TPOBoxOfficeForm.OfficeListBoxesButtonClick(Sender: TObject);
begin
  If Office <> nil then
  begin
    OfficeBoxesListBox.Items.CommaText := Office.ListBoxes(0,0);
    PageControl.ActivePage := BoxesTabSheet;
  end
  else
    OfficeBoxesListBox.Items.Clear;
end;

procedure TPOBoxOfficeForm.OfficeListCustomersButtonClick(Sender: TObject);
begin
  If Office <> nil then
  begin
    OfficeCustomersListBox.Items.CommaText := Office.ListCustomers;
    PageControl.ActivePage := CustomerTabSheet;
  end
  else
    OfficeCustomersListBox.Items.Clear;
end;


procedure TPOBoxOfficeForm.OfficeUpdateButtonClick(Sender: TObject);
begin
  If Office <> nil then
  begin
    Office.Name     :=  OfficeNameEdit.Text;
    Office.Address  := OfficeAddressMemo.Lines.CommaText;
  end;
  UpdateFormDetails(Office);
end;

procedure TPOBoxOfficeForm.OfficeDeleteButtonClick(Sender: TObject);
begin
  If not Office.Delete then
    ShowMessage('Unable to delete office ' + IntToStr(Office.Number));

end;

procedure TPOBoxOfficeForm.AddButtonClick(Sender: TObject);
begin
  If nil = Office.AddBox(StrToInt(BoxEdit.Text),
                      0,
                      0,
                      0,
                      0,
                      '') then
    ShowMessage('Unable to add box');

end;

procedure TPOBoxOfficeForm.BoxGetButtonClick(Sender: TObject);
begin
  GetBox(StrToInt(BoxEdit.Text));
end;

procedure TPOBoxOfficeForm.GetBox(BoxNumber : Integer);
var
  Box : IPOBox;
begin
  Box := Office.Boxes[BoxNumber];
  If Box <> nil then
    Box.Visible := True;
end;

procedure TPOBoxOfficeForm.OfficeBoxesListBoxDblClick(Sender: TObject);
begin
  GetBox(StrToInt(OfficeBoxesListBox.Items[OfficeBoxesListBox.ItemIndex]));
end;

procedure TPOBoxOfficeForm.BoxFindButtonClick(Sender: TObject);
var
  AvailableBox : IPOBox;
begin
  AvailableBox :=
    Office.FindAvailableBox(
      StrToIntDef(BoxStyleEdit.Text,0),
      BoxFeaturesCommaTextEditMemo.Lines.CommaText);

  If AvailableBox <> nil then
    AvailableBox.Visible := True;
end;

procedure TPOBoxOfficeForm.CustomerAddButtonClick(Sender: TObject);
var
  NewCustomer : IPOBoxCustomer;
begin
   NewCustomer :=
   Office.NewCustomer(CustomerForenamesEdit.Text,
                      CustomerSurnameEdit.Text,
                      '',
                      '',
                      '');

   If NewCustomer <> nil then
     NewCustomer.Visible
   else
    ShowMessage('Unable to add new customer');
end;

procedure TPOBoxOfficeForm.CustomerGetButtonClick(Sender: TObject);
begin
  GetCustomer(StrToInt(CustomerNumberEdit.Text));
end;

procedure TPOBoxOfficeForm.GetCustomer(Identifier : Integer);
var
  Customer : IPOBoxCustomer;
begin
  Customer := Office.Customers[Identifier];
  If Customer <> nil then
    Customer.Visible := True;
end;


procedure TPOBoxOfficeForm.CustomerNameButtonClick(Sender: TObject);
var
  Customers : String;
begin
  Customers :=
    Office.FindCustomerByName(CustomerForenamesEdit.Text, CustomerSurnameEdit.Text);
  OfficeCustomersListBox.Items.CommaText := Customers;
end;

procedure TPOBoxOfficeForm.CustomerBusinessNameButtonClick(
  Sender: TObject);
var
  Customers : String;
begin
  Customers :=
    Office.FindCustomerByBusinessName(CustomerBusinessNameEdit.Text);
  OfficeCustomersListBox.Items.CommaText := Customers;
end;

procedure TPOBoxOfficeForm.CustomerOfficeButtonClick(Sender: TObject);
var
  Customers : String;
begin
  Customers :=
    Office.FindCustomersByOffice;
  OfficeCustomersListBox.Items.CommaText := Customers;
end;

procedure TPOBoxOfficeForm.OfficeCustomersListBoxDblClick(Sender: TObject);
begin
  GetCustomer(StrToInt(OfficeCustomersListBox.Items[OfficeCustomersListBox.ItemIndex]));

end;

end.
