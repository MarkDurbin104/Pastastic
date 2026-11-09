unit POBoxCustomerF;

interface

uses
  POBoxManager_TLB,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, EditCheckListBoxU;

type
  TPOBoxCustomerForm = class(TForm)
    CustomerClientPanel: TPanel;
    CustomerForenamesLabel: TLabel;
    CustomerBusienessNameLabel: TLabel;
    CustomerTypeLabel: TLabel;
    CustomerAddressLabel: TLabel;
    CustomerForenamesEdit: TEdit;
    CustomerBusinessNameEdit: TEdit;
    CustomerTypeEdit: TEdit;
    CustomerAddressMemo: TMemo;
    CustomerBottomPanel: TPanel;
    CustomerUpdateButton: TButton;
    CustomerStateEditCheckListBox: TEditCheckListBox;
    StateLabel: TLabel;
    DeleteButton: TButton;
    CustomerSurnameLabel: TLabel;
    CustomerSurnameEdit: TEdit;
    CustomerTelephoneEdit: TEdit;
    CustomerTelephoneLabel: TLabel;
    CustomerFaxLabel: TLabel;
    CustomerFaxEdit: TEdit;
    CustomerZipCodeLabel: TLabel;
    CustomerZipCodeEdit: TEdit;
    CustomerIdTypeLabel: TLabel;
    CustomerIdTypeEdit: TEdit;
    CustomerIdLabel: TLabel;
    CustomerIdEdit: TEdit;
    CustomerDelegatesLabel: TLabel;
    CustomerDelegatesEdit: TEdit;
    procedure CustomerUpdateButtonClick(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
  private
    { Private declarations }
    FPOBoxCustomer : IPOBoxCustomer;
    procedure SetPOBoxCustomer(Value : IPOBoxCustomer);
  public
    { Public declarations }
    property Customer : IPOBoxCustomer read FPOBoxCustomer write SetPOBoxCustomer;
    procedure UpdateFormDetails(Customer : IPOBoxCustomer);
  end;

var
  POBoxCustomerForm: TPOBoxCustomerForm;

implementation

{$R *.DFM}

procedure TPOBoxCustomerForm.CustomerUpdateButtonClick(Sender: TObject);
begin
  If Customer <> nil then
  begin
    Customer.Forenames    := CustomerForenamesEdit.Text;
    Customer.Surname      := CustomerSurnameEdit.Text;
    Customer.BusinessName := CustomerBusinessNameEdit.Text;
    Customer.CustomerType := CustomerTypeEdit.Text;
    Customer.AddressLines := CustomerAddressMemo.Lines.CommaText;
    Customer.State        := CustomerStateEditCheckListBox.Value;
    Customer.Telephone    := CustomerTelephoneEdit.Text;
    Customer.Fax          := CustomerFaxEdit.Text;
    Customer.ZipCode      := CustomerZipCodeEdit.Text;
    Customer.IdType       := CustomerIdTypeEdit.Text;
    Customer.Id           := CustomerIdEdit.Text;
    Customer.Delegates    := CustomerDelegatesEdit.Text;
  end;
end;

procedure TPOBoxCustomerForm.SetPOBoxCustomer(Value : IPOBoxCustomer);
begin
  If FPOBoxCustomer <> Value then
  begin
    FPOBoxCustomer := nil;
    FPOBoxCustomer := Value;
    UpdateFormDetails(FPOBoxCustomer);
  end;
end;

procedure TPOBoxCustomerForm.UpdateFormDetails(Customer : IPOBoxCustomer);
begin
  If Customer <> nil then
  begin
    Caption                             := 'PO Box Customer ' + IntToStr(Customer.Identifier);
    CustomerForenamesEdit.Text          := Customer.Forenames;
    CustomerSurnameEdit.Text            := Customer.Surname;
    CustomerBusinessNameEdit.Text       := Customer.BusinessName;
    CustomerTypeEdit.Text               := Customer.CustomerType;
    CustomerAddressMemo.Lines.CommaText := Customer.AddressLines;
    CustomerStateEditCheckListBox.Value := Customer.State;
    CustomerTelephoneEdit.Text          := Customer.Telephone;
    CustomerFaxEdit.Text                := Customer.Fax;
    CustomerZipCodeEdit.Text            := Customer.ZipCode;
    CustomerIdTypeEdit.Text             := Customer.IdType;
    CustomerIdEdit.Text                 := Customer.Id;
    CustomerDelegatesEdit.Text          := Customer.Delegates;
  end
  else
  begin
    Caption                             := 'PO Box Customer (none)';
    CustomerForenamesEdit.Text          := '';
    CustomerSurnameEdit.Text            := '';
    CustomerBusinessNameEdit.Text       := '';
    CustomerTypeEdit.Text               := '';
    CustomerAddressMemo.Lines.CommaText := '';
    CustomerStateEditCheckListBox.Value := 0;
    CustomerTelephoneEdit.Text          := '';
    CustomerFaxEdit.Text                := '';
    CustomerZipCodeEdit.Text            := '';
    CustomerIdTypeEdit.Text             := '';
    CustomerIdEdit.Text                 := '';
    CustomerDelegatesEdit.Text          := '';
  end;
end;

procedure TPOBoxCustomerForm.DeleteButtonClick(Sender: TObject);
begin
  If FPOBoxCustomer <> nil then
  begin
    FPOBoxCustomer.Delete;
  end;
  UpdateFormDetails(FPOBoxCustomer);

end;

end.
