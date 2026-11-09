unit POBoxManager_TLB;

{ This file contains pascal declarations imported from a type library.
  This file will be written during each import or refresh of the type
  library editor.  Changes to this file will be discarded during the
  refresh process. }

{ POBoxManager Library }
{ Version 1.0 }

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

const
  LIBID_POBoxManager: TGUID = '{F098BDA0-DBAE-11D2-A2B8-00A024C16A54}';

const

{ Status of box }

{ POBoxState }

  bsAvailable = 1;
  bsRented = 2;
  bsInDispute = 4;
  bsDeleted = 8;
  bsDamaged = 16;
  bsRedirected = 32;

{ POBoxCustomerState }

  csInDispute = 1;
  csDeleted = 2;

const

{ Component class GUIDs }
  Class_POBoxManagerAuto: TGUID = '{F098BDA2-DBAE-11D2-A2B8-00A024C16A54}';
  Class_POBox: TGUID = '{C6562C03-DC56-11D2-A2B8-00A024C16A54}';
  Class_POBoxOffice: TGUID = '{B99A67A1-DC89-11D2-A2B8-00A024C16A54}';
  Class_POBoxCustomer: TGUID = '{55C57404-E043-11D2-A2B9-00A024C16A54}';

type

{ Forward declarations: Interfaces }
  IPOBoxManagerAuto = interface;
  IPOBoxManagerAutoDisp = dispinterface;
  IPOBox = interface;
  IPOBoxDisp = dispinterface;
  IPOBoxOffice = interface;
  IPOBoxOfficeDisp = dispinterface;
  IPOBoxCustomer = interface;
  IPOBoxCustomerDisp = dispinterface;

{ Forward declarations: CoClasses }
  POBoxManagerAuto = IPOBoxManagerAuto;
  POBox = IPOBox;
  POBoxOffice = IPOBoxOffice;
  POBoxCustomer = IPOBoxCustomer;

{ Forward declarations: Enums }
  POBoxState = TOleEnum;
  POBoxCustomerState = TOleEnum;

{ Dispatch interface for POBoxManagerAuto Object }

  IPOBoxManagerAuto = interface(IDispatch)
    ['{F098BDA1-DBAE-11D2-A2B8-00A024C16A54}']
    function AddChangeBoxStyle(StyleNumber, Width, Height, Depth, PricingStructure: Integer): WordBool; safecall;
    function AddBox(OfficeNumber, BoxNumber, BlockNumber, Style, XCoord, YCoord: Integer; const Features: WideString): IPOBox; safecall;
    function AddOffice(OfficeNumber: Integer; const Name, Address: WideString): IPOBoxOffice; safecall;
    function AmountDueForBox(OfficeNumber, BoxNumber, RenewalPeriod: Integer): Currency; safecall;
    function BoxRenewal(OfficeNumber, BoxNumber, RenewalPeriod: Integer; AmountPaid: Currency): WordBool; safecall;
    function ChangeBoxLock(OfficeNumber, BoxNumber: Integer; AmountPaid: Currency): WordBool; safecall;
    function ChangeBoxOwner(OfficeNumber, BoxNumber: Integer; AmountPaid: Currency; CustomerIdentifier: Integer): WordBool; safecall;
    function ChangeCustomer(OfficeNumber, CustomerIdentifier: Integer; const Forenames, Surname, BusinessName, CustomerType, AddressLines: WideString): WordBool; safecall;
    function DeleteOffice(OfficeNumber: Integer): WordBool; safecall;
    function FindAvailableBox(OfficeNumber, BoxStyle: Integer; const Features: WideString): IPOBox; safecall;
    function FindCustomerByBoxNumber(OfficeNumber, BoxNumber: Integer): IPOBoxCustomer; safecall;
    function FindCustomerByBusinessName(OfficeNumber: Integer; const BusinessName: WideString): WideString; safecall;
    function FindCustomerByName(OfficeNumber: Integer; const Forenames, Surname: WideString): WideString; safecall;
    function FindCustomersByOffice(OfficeNumber: Integer): WideString; safecall;
    function GetCustomerDetails(OfficeNumber, CustomerIdentifier: Integer): WideString; safecall;
    function IssueBoxKey(OfficeNumber, BoxNumber: Integer; AmountPaid: Currency): WordBool; safecall;
    function ListAllBoxesDueBy(OfficeNumber: Integer; DueDate: TDateTime): WideString; safecall;
    function ListAllOverDueBoxes(OfficeNumber: Integer): WideString; safecall;
    function ListBoxes(OfficeNumber, BoxStyle, BoxState: Integer): WideString; safecall;
    function ListBoxStyles: WideString; safecall;
    function ListNewReminders(OfficeNumber: Integer): WideString; safecall;
    function NewBoxRental(OfficeNumber, BoxNumber, RentalPeriod: Integer; AmountPaid: Currency; CustomerIdentifier: Integer): WordBool; safecall;
    function NewCustomer(OfficeNumber: Integer; const Forenames, Surname, BusinessName, CustomerType, AddressLines: WideString): IPOBoxCustomer; safecall;
    function ReceiveBoxDeposit(OfficeNumber, BoxNumber: Integer; AmountPaid: Currency): WordBool; safecall;
    function ReDirectBoxTo(FromOfficeNumber, FromBoxNumber, ToOfficeNumber, ToBoxNumber, ForPeriod: Integer; AmountPaid: Currency): WordBool; safecall;
    function ReturnBoxDeposit(OfficeNumber, BoxNumber: Integer; AmountPaid: Currency): WordBool; safecall;
    function SetBoxState(OfficeNumber, FromBoxNumber, ToBoxNumber, BoxStates: Integer): WordBool; safecall;
    function SetBoxStyle(OfficeNumber, FromBoxNumber, ToBoxNumber, BoxStyle: Integer): WordBool; safecall;
    function Get_Site: Integer; safecall;
    procedure Set_Site(Value: Integer); safecall;
    function Get_Clerk: WideString; safecall;
    procedure Set_Clerk(const Value: WideString); safecall;
    function Get_Customers(OfficeNumber, CustomerIdentifier: Integer): IPOBoxCustomer; safecall;
    function Get_Workstation: Integer; safecall;
    procedure Set_Workstation(Value: Integer); safecall;
    function Get_Boxes(OfficeNumber, BoxNumber: Integer): IPOBox; safecall;
    function Get_Offices(OfficeNumber: Integer): IPOBoxOffice; safecall;
    property Site: Integer read Get_Site write Set_Site;
    property Clerk: WideString read Get_Clerk write Set_Clerk;
    property Customers[OfficeNumber, CustomerIdentifier: Integer]: IPOBoxCustomer read Get_Customers;
    property Workstation: Integer read Get_Workstation write Set_Workstation;
    property Boxes[OfficeNumber, BoxNumber: Integer]: IPOBox read Get_Boxes;
    property Offices[OfficeNumber: Integer]: IPOBoxOffice read Get_Offices;
  end;

{ DispInterface declaration for Dual Interface IPOBoxManagerAuto }

  IPOBoxManagerAutoDisp = dispinterface
    ['{F098BDA1-DBAE-11D2-A2B8-00A024C16A54}']
    function AddChangeBoxStyle(StyleNumber, Width, Height, Depth, PricingStructure: Integer): WordBool; dispid 27;
    function AddBox(OfficeNumber, BoxNumber, BlockNumber, Style, XCoord, YCoord: Integer; const Features: WideString): IPOBox; dispid 13;
    function AddOffice(OfficeNumber: Integer; const Name, Address: WideString): IPOBoxOffice; dispid 18;
    function AmountDueForBox(OfficeNumber, BoxNumber, RenewalPeriod: Integer): Currency; dispid 29;
    function BoxRenewal(OfficeNumber, BoxNumber, RenewalPeriod: Integer; AmountPaid: Currency): WordBool; dispid 3;
    function ChangeBoxLock(OfficeNumber, BoxNumber: Integer; AmountPaid: Currency): WordBool; dispid 6;
    function ChangeBoxOwner(OfficeNumber, BoxNumber: Integer; AmountPaid: Currency; CustomerIdentifier: Integer): WordBool; dispid 5;
    function ChangeCustomer(OfficeNumber, CustomerIdentifier: Integer; const Forenames, Surname, BusinessName, CustomerType, AddressLines: WideString): WordBool; dispid 2;
    function DeleteOffice(OfficeNumber: Integer): WordBool; dispid 19;
    function FindAvailableBox(OfficeNumber, BoxStyle: Integer; const Features: WideString): IPOBox; dispid 31;
    function FindCustomerByBoxNumber(OfficeNumber, BoxNumber: Integer): IPOBoxCustomer; dispid 32;
    function FindCustomerByBusinessName(OfficeNumber: Integer; const BusinessName: WideString): WideString; dispid 33;
    function FindCustomerByName(OfficeNumber: Integer; const Forenames, Surname: WideString): WideString; dispid 34;
    function FindCustomersByOffice(OfficeNumber: Integer): WideString; dispid 35;
    function GetCustomerDetails(OfficeNumber, CustomerIdentifier: Integer): WideString; dispid 11;
    function IssueBoxKey(OfficeNumber, BoxNumber: Integer; AmountPaid: Currency): WordBool; dispid 7;
    function ListAllBoxesDueBy(OfficeNumber: Integer; DueDate: TDateTime): WideString; dispid 37;
    function ListAllOverDueBoxes(OfficeNumber: Integer): WideString; dispid 38;
    function ListBoxes(OfficeNumber, BoxStyle, BoxState: Integer): WideString; dispid 39;
    function ListBoxStyles: WideString; dispid 20;
    function ListNewReminders(OfficeNumber: Integer): WideString; dispid 40;
    function NewBoxRental(OfficeNumber, BoxNumber, RentalPeriod: Integer; AmountPaid: Currency; CustomerIdentifier: Integer): WordBool; dispid 4;
    function NewCustomer(OfficeNumber: Integer; const Forenames, Surname, BusinessName, CustomerType, AddressLines: WideString): IPOBoxCustomer; dispid 1;
    function ReceiveBoxDeposit(OfficeNumber, BoxNumber: Integer; AmountPaid: Currency): WordBool; dispid 8;
    function ReDirectBoxTo(FromOfficeNumber, FromBoxNumber, ToOfficeNumber, ToBoxNumber, ForPeriod: Integer; AmountPaid: Currency): WordBool; dispid 41;
    function ReturnBoxDeposit(OfficeNumber, BoxNumber: Integer; AmountPaid: Currency): WordBool; dispid 9;
    function SetBoxState(OfficeNumber, FromBoxNumber, ToBoxNumber, BoxStates: Integer): WordBool; dispid 42;
    function SetBoxStyle(OfficeNumber, FromBoxNumber, ToBoxNumber, BoxStyle: Integer): WordBool; dispid 43;
    property Site: Integer dispid 10;
    property Clerk: WideString dispid 14;
    property Customers[OfficeNumber, CustomerIdentifier: Integer]: IPOBoxCustomer readonly dispid 12;
    property Workstation: Integer dispid 15;
    property Boxes[OfficeNumber, BoxNumber: Integer]: IPOBox readonly dispid 16;
    property Offices[OfficeNumber: Integer]: IPOBoxOffice readonly dispid 17;
  end;

{ Dispatch interface for POBox Object }

  IPOBox = interface(IDispatch)
    ['{C6562C02-DC56-11D2-A2B8-00A024C16A54}']
    function Get_BlockNumber: Integer; safecall;
    procedure Set_BlockNumber(Value: Integer); safecall;
    function Get_DepositHeld: Currency; safecall;
    procedure Set_DepositHeld(Value: Currency); safecall;
    function Get_Depth: Integer; safecall;
    function Get_Features: WideString; safecall;
    procedure Set_Features(const Value: WideString); safecall;
    function Get_Height: Integer; safecall;
    function Get_KeysIssued: Integer; safecall;
    procedure Set_KeysIssued(Value: Integer); safecall;
    function Get_LockNumber: Integer; safecall;
    procedure Set_LockNumber(Value: Integer); safecall;
    function Get_Number: Integer; safecall;
    procedure Set_Number(Value: Integer); safecall;
    function Get_Office: IPOBoxOffice; safecall;
    procedure Set_Office(const Value: IPOBoxOffice); safecall;
    function Get_Owner: IPOBoxCustomer; safecall;
    procedure Set_Owner(const Value: IPOBoxCustomer); safecall;
    function Get_RenewalDate: TDateTime; safecall;
    procedure Set_RenewalDate(Value: TDateTime); safecall;
    function Get_State: Integer; safecall;
    procedure Set_State(Value: Integer); safecall;
    function Get_Style: Integer; safecall;
    procedure Set_Style(Value: Integer); safecall;
    function Get_Width: Integer; safecall;
    function Get_XCoord: Integer; safecall;
    procedure Set_XCoord(Value: Integer); safecall;
    function Get_YCoord: Integer; safecall;
    procedure Set_YCoord(Value: Integer); safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Delete: WordBool; safecall;
    property BlockNumber: Integer read Get_BlockNumber write Set_BlockNumber;
    property DepositHeld: Currency read Get_DepositHeld write Set_DepositHeld;
    property Depth: Integer read Get_Depth;
    property Features: WideString read Get_Features write Set_Features;
    property Height: Integer read Get_Height;
    property KeysIssued: Integer read Get_KeysIssued write Set_KeysIssued;
    property LockNumber: Integer read Get_LockNumber write Set_LockNumber;
    property Number: Integer read Get_Number write Set_Number;
    property Office: IPOBoxOffice read Get_Office write Set_Office;
    property Owner: IPOBoxCustomer read Get_Owner write Set_Owner;
    property RenewalDate: TDateTime read Get_RenewalDate write Set_RenewalDate;
    property State: Integer read Get_State write Set_State;
    property Style: Integer read Get_Style write Set_Style;
    property Width: Integer read Get_Width;
    property XCoord: Integer read Get_XCoord write Set_XCoord;
    property YCoord: Integer read Get_YCoord write Set_YCoord;
    property Visible: WordBool read Get_Visible write Set_Visible;
  end;

{ DispInterface declaration for Dual Interface IPOBox }

  IPOBoxDisp = dispinterface
    ['{C6562C02-DC56-11D2-A2B8-00A024C16A54}']
    property BlockNumber: Integer dispid 1;
    property DepositHeld: Currency dispid 2;
    property Depth: Integer readonly dispid 3;
    property Features: WideString dispid 4;
    property Height: Integer readonly dispid 5;
    property KeysIssued: Integer dispid 6;
    property LockNumber: Integer dispid 7;
    property Number: Integer dispid 8;
    property Office: IPOBoxOffice dispid 14;
    property Owner: IPOBoxCustomer dispid 15;
    property RenewalDate: TDateTime dispid 16;
    property State: Integer dispid 9;
    property Style: Integer dispid 10;
    property Width: Integer readonly dispid 11;
    property XCoord: Integer dispid 12;
    property YCoord: Integer dispid 13;
    property Visible: WordBool dispid 17;
    function Delete: WordBool; dispid 18;
  end;

{ Dispatch interface for POBoxOffice Object }

  IPOBoxOffice = interface(IDispatch)
    ['{B99A67A0-DC89-11D2-A2B8-00A024C16A54}']
    function Get_Address: WideString; safecall;
    procedure Set_Address(const Value: WideString); safecall;
    function Get_Boxes(BoxNumber: Integer): IPOBox; safecall;
    function Get_Code: WideString; safecall;
    procedure Set_Code(const Value: WideString); safecall;
    function Get_Customers(CustomerIdentifier: Integer): IPOBoxCustomer; safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function Get_Number: Integer; safecall;
    procedure Set_Number(Value: Integer); safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_POBoxManager: IPOBoxManagerAuto; safecall;
    procedure Set_POBoxManager(const Value: IPOBoxManagerAuto); safecall;
    function Application(const User: IPOBoxCustomer): WordBool; safecall;
    function AddBox(const Box: IPOBox): IPOBox; safecall;
    function GetBox(const BoxNumber: WideString): IPOBox; safecall;
    function RemoveBox(IPOBox: Integer): WordBool; safecall;
    function AddUser(const POBoxUser: IPOBoxCustomer): WordBool; safecall;
    function FindAvailableBox(BoxStyle: Integer; const Features: WideString): IPOBox; safecall;
    function FindCustomerByBusinessName(const BusinessName: WideString): WideString; safecall;
    function FindCustomerByName(const Forenames, Surname: WideString): WideString; safecall;
    function FindCustomersByOffice: WideString; safecall;
    function ListAllBoxesDueBy(DueDate: TDateTime): WideString; safecall;
    function ListBoxes(BoxStyle, BoxState: Integer): WideString; safecall;
    function ListCustomers: WideString; safecall;
    function NewCustomer(const Forenames, Surname, BusinessName, CustomerType, AddressLines: WideString): IPOBoxCustomer; safecall;
    property Address: WideString read Get_Address write Set_Address;
    property Boxes[BoxNumber: Integer]: IPOBox read Get_Boxes;
    property Code: WideString read Get_Code write Set_Code;
    property Customers[CustomerIdentifier: Integer]: IPOBoxCustomer read Get_Customers;
    property Name: WideString read Get_Name write Set_Name;
    property Number: Integer read Get_Number write Set_Number;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property POBoxManager: IPOBoxManagerAuto read Get_POBoxManager write Set_POBoxManager;
  end;

{ DispInterface declaration for Dual Interface IPOBoxOffice }

  IPOBoxOfficeDisp = dispinterface
    ['{B99A67A0-DC89-11D2-A2B8-00A024C16A54}']
    property Address: WideString dispid 9;
    property Boxes[BoxNumber: Integer]: IPOBox readonly dispid 6;
    property Code: WideString dispid 19;
    property Customers[CustomerIdentifier: Integer]: IPOBoxCustomer readonly dispid 1;
    property Name: WideString dispid 10;
    property Number: Integer dispid 3;
    property Visible: WordBool dispid 16;
    property POBoxManager: IPOBoxManagerAuto dispid 17;
    function Application(const User: IPOBoxCustomer): WordBool; dispid 8;
    function AddBox(const Box: IPOBox): IPOBox; dispid 18;
    function GetBox(const BoxNumber: WideString): IPOBox; dispid 20;
    function RemoveBox(IPOBox: Integer): WordBool; dispid 5;
    function AddUser(const POBoxUser: IPOBoxCustomer): WordBool; dispid 21;
    function FindAvailableBox(BoxStyle: Integer; const Features: WideString): IPOBox; dispid 2;
    function FindCustomerByBusinessName(const BusinessName: WideString): WideString; dispid 11;
    function FindCustomerByName(const Forenames, Surname: WideString): WideString; dispid 12;
    function FindCustomersByOffice: WideString; dispid 13;
    function ListAllBoxesDueBy(DueDate: TDateTime): WideString; dispid 14;
    function ListBoxes(BoxStyle, BoxState: Integer): WideString; dispid 4;
    function ListCustomers: WideString; dispid 7;
    function NewCustomer(const Forenames, Surname, BusinessName, CustomerType, AddressLines: WideString): IPOBoxCustomer; dispid 15;
  end;

{ Dispatch interface for POBoxCustomer Object }

  IPOBoxCustomer = interface(IDispatch)
    ['{55C57403-E043-11D2-A2B9-00A024C16A54}']
    function Get_AddressLines: WideString; safecall;
    procedure Set_AddressLines(const Value: WideString); safecall;
    function Get_Boxes(BoxNumber: Integer): IPOBox; safecall;
    function Get_BusinessName: WideString; safecall;
    procedure Set_BusinessName(const Value: WideString); safecall;
    function Get_CustomerType: WideString; safecall;
    procedure Set_CustomerType(const Value: WideString); safecall;
    function Get_Delegates: WideString; safecall;
    procedure Set_Delegates(const Value: WideString); safecall;
    function Get_Details: WideString; safecall;
    function Get_Fax: WideString; safecall;
    procedure Set_Fax(const Value: WideString); safecall;
    function Get_Forenames: WideString; safecall;
    procedure Set_Forenames(const Value: WideString); safecall;
    function Get_Id: WideString; safecall;
    procedure Set_Id(const Value: WideString); safecall;
    function Get_Identifier: Integer; safecall;
    procedure Set_Identifier(Value: Integer); safecall;
    function Get_IdType: WideString; safecall;
    procedure Set_IdType(const Value: WideString); safecall;
    function Get_Office: IPOBoxOffice; safecall;
    procedure Set_Office(const Value: IPOBoxOffice); safecall;
    function Get_State: Integer; safecall;
    procedure Set_State(Value: Integer); safecall;
    function Get_Surname: WideString; safecall;
    procedure Set_Surname(const Value: WideString); safecall;
    function Get_Telephone: WideString; safecall;
    procedure Set_Telephone(const Value: WideString); safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_ZipCode: WideString; safecall;
    procedure Set_ZipCode(const Value: WideString); safecall;
    function Delete: WordBool; safecall;
    property AddressLines: WideString read Get_AddressLines write Set_AddressLines;
    property Boxes[BoxNumber: Integer]: IPOBox read Get_Boxes;
    property BusinessName: WideString read Get_BusinessName write Set_BusinessName;
    property CustomerType: WideString read Get_CustomerType write Set_CustomerType;
    property Delegates: WideString read Get_Delegates write Set_Delegates;
    property Details: WideString read Get_Details;
    property Fax: WideString read Get_Fax write Set_Fax;
    property Forenames: WideString read Get_Forenames write Set_Forenames;
    property Id: WideString read Get_Id write Set_Id;
    property Identifier: Integer read Get_Identifier write Set_Identifier;
    property IdType: WideString read Get_IdType write Set_IdType;
    property Office: IPOBoxOffice read Get_Office write Set_Office;
    property State: Integer read Get_State write Set_State;
    property Surname: WideString read Get_Surname write Set_Surname;
    property Telephone: WideString read Get_Telephone write Set_Telephone;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property ZipCode: WideString read Get_ZipCode write Set_ZipCode;
  end;

{ DispInterface declaration for Dual Interface IPOBoxCustomer }

  IPOBoxCustomerDisp = dispinterface
    ['{55C57403-E043-11D2-A2B9-00A024C16A54}']
    property AddressLines: WideString dispid 1;
    property Boxes[BoxNumber: Integer]: IPOBox readonly dispid 2;
    property BusinessName: WideString dispid 3;
    property CustomerType: WideString dispid 4;
    property Delegates: WideString dispid 13;
    property Details: WideString readonly dispid 9;
    property Fax: WideString dispid 14;
    property Forenames: WideString dispid 6;
    property Id: WideString dispid 15;
    property Identifier: Integer dispid 5;
    property IdType: WideString dispid 16;
    property Office: IPOBoxOffice dispid 7;
    property State: Integer dispid 10;
    property Surname: WideString dispid 12;
    property Telephone: WideString dispid 17;
    property Visible: WordBool dispid 8;
    property ZipCode: WideString dispid 18;
    function Delete: WordBool; dispid 11;
  end;

{ GPCS PO Box Manager AutoObject }

  CoPOBoxManagerAuto = class
    class function Create: IPOBoxManagerAuto;
    class function CreateRemote(const MachineName: string): IPOBoxManagerAuto;
  end;

{ GPCS POBoxObject }

  CoPOBox = class
    class function Create: IPOBox;
    class function CreateRemote(const MachineName: string): IPOBox;
  end;

{ POBoxOfficeObject }

  CoPOBoxOffice = class
    class function Create: IPOBoxOffice;
    class function CreateRemote(const MachineName: string): IPOBoxOffice;
  end;

{ POBoxCustomerObject }

  CoPOBoxCustomer = class
    class function Create: IPOBoxCustomer;
    class function CreateRemote(const MachineName: string): IPOBoxCustomer;
  end;



implementation

uses ComObj;

class function CoPOBoxManagerAuto.Create: IPOBoxManagerAuto;
begin
  Result := CreateComObject(Class_POBoxManagerAuto) as IPOBoxManagerAuto;
end;

class function CoPOBoxManagerAuto.CreateRemote(const MachineName: string): IPOBoxManagerAuto;
begin
  Result := CreateRemoteComObject(MachineName, Class_POBoxManagerAuto) as IPOBoxManagerAuto;
end;

class function CoPOBox.Create: IPOBox;
begin
  Result := CreateComObject(Class_POBox) as IPOBox;
end;

class function CoPOBox.CreateRemote(const MachineName: string): IPOBox;
begin
  Result := CreateRemoteComObject(MachineName, Class_POBox) as IPOBox;
end;

class function CoPOBoxOffice.Create: IPOBoxOffice;
begin
  Result := CreateComObject(Class_POBoxOffice) as IPOBoxOffice;
end;

class function CoPOBoxOffice.CreateRemote(const MachineName: string): IPOBoxOffice;
begin
  Result := CreateRemoteComObject(MachineName, Class_POBoxOffice) as IPOBoxOffice;
end;

class function CoPOBoxCustomer.Create: IPOBoxCustomer;
begin
  Result := CreateComObject(Class_POBoxCustomer) as IPOBoxCustomer;
end;

class function CoPOBoxCustomer.CreateRemote(const MachineName: string): IPOBoxCustomer;
begin
  Result := CreateRemoteComObject(MachineName, Class_POBoxCustomer) as IPOBoxCustomer;
end;


end.
