unit POBoxManagerAU;

interface

uses
  Db,
  GPCSGUID,
  GPCSBase_TLB,
  GPCSErrorLine,
  DbTables,
  SysUtils,
  Classes,
  ComObj, ActiveX, POBoxManager_TLB;

type
  TPOBoxManagerAuto = class(TAutoObject, IPOBoxManagerAuto)
  private
    FSite         : Integer;
    FClerk        : WideString;
    FWorkstation  : Integer;

    BoxOfficeTable    : TTable;
    BoxStyleTable     : TTable;
    NewSession        : TSession;
    OfficeList        : TStringList;

  protected
    procedure Initialize; override;
    destructor Destroy; override;
    function AddBox(OfficeNumber, BoxNumber, BlockNumber, Style, XCoord,
      YCoord: Integer; const Features: WideString): IPOBox; safecall;
    function AddChangeBoxStyle(StyleNumber, Width, Height, Depth,
      PricingStructure: Integer): WordBool; safecall;
    function AmountDueForBox(OfficeNumber, BoxNumber,
      RenewalPeriod: Integer): Currency; safecall;
    function BoxRenewal(OfficeNumber, BoxNumber, RenewalPeriod: Integer;
      AmountPaid: Currency): WordBool; safecall;
    function ChangeBoxLock(OfficeNumber, BoxNumber: Integer;
      AmountPaid: Currency): WordBool; safecall;
    function ChangeBoxOwner(OfficeNumber, BoxNumber: Integer;
      AmountPaid: Currency; CustomerIdentifier: Integer): WordBool;
      safecall;
    function ChangeCustomer(OfficeNumber, CustomerIdentifier: Integer;
      const Forenames, Surname, BusinessName, CustomerType,
      AddressLines: WideString): WordBool; safecall;
    function DeleteBox(OfficeNumber, BoxNumber: Integer): WordBool; safecall;
    function FindAvailableBox(OfficeNumber, BoxStyle: Integer;
      const Features: WideString): IPOBox; safecall;
    function FindCustomerByBoxNumber(OfficeNumber,
      BoxNumber: Integer): IPOBoxCustomer; safecall;
    function FindCustomerByBusinessName(OfficeNumber: Integer;
      const BusinessName: WideString): WideString; safecall;
    function FindCustomerByName(OfficeNumber: Integer; const Forenames,
      Surname: WideString): WideString; safecall;
    function FindCustomersByOffice(OfficeNumber: Integer): WideString;
      safecall;
    function GetCustomerDetails(OfficeNumber,
      CustomerIdentifier: Integer): WideString; safecall;
    function IssueBoxKey(OfficeNumber, BoxNumber: Integer;
      AmountPaid: Currency): WordBool; safecall;
    function ListAllBoxesDueBy(OfficeNumber: Integer;
      DueDate: TDateTime): WideString; safecall;
    function ListAllOverDueBoxes(OfficeNumber: Integer): WideString; safecall;
    function ListBoxes(OfficeNumber, BoxStyle, BoxState: Integer): WideString;
      safecall;
    function ListNewReminders(OfficeNumber: Integer): WideString; safecall;
    function NewBoxRental(OfficeNumber, BoxNumber, RentalPeriod: Integer;
      AmountPaid: Currency; CustomerIdentifier: Integer): WordBool;
      safecall;
    function NewCustomer(OfficeNumber: Integer; const Forenames, Surname,
      BusinessName, CustomerType,
      AddressLines: WideString): IPOBoxCustomer; safecall;
    function ReceiveBoxDeposit(OfficeNumber, BoxNumber: Integer;
      AmountPaid: Currency): WordBool; safecall;
    function ReDirectBoxTo(FromOfficeNumber, FromBoxNumber, ToOfficeNumber,
      ToBoxNumber, ForPeriod: Integer; AmountPaid: Currency): WordBool;
      safecall;
    function ReturnBoxDeposit(OfficeNumber, BoxNumber: Integer;
      AmountPaid: Currency): WordBool; safecall;
    function SetBoxState(OfficeNumber, FromBoxNumber, ToBoxNumber,
      BoxStates: Integer): WordBool; safecall;
    function SetBoxStyle(OfficeNumber, FromBoxNumber, ToBoxNumber,
      BoxStyle: Integer): WordBool; safecall;

    function Get_Clerk: WideString; safecall;
    function Get_Site: Integer; safecall;
    function Get_Workstation: Integer; safecall;
    procedure Set_Clerk(const Value: WideString); safecall;
    procedure Set_Site(Value: Integer); safecall;
    procedure Set_Workstation(Value: Integer); safecall;
    function Get_Boxes(OfficeNumber, BoxNumber: Integer): IPOBox; safecall;
    function Get_Customers(OfficeNumber,
      CustomerIdentifier: Integer): IPOBoxCustomer; safecall;
    function Get_Offices(OfficeNumber: Integer): IPOBoxOffice; safecall;

    function AddOffice(OfficeNumber: Integer; const Name,
      Address: WideString): IPOBoxOffice; safecall;
    function DeleteOffice(OfficeNumber: Integer): WordBool; safecall;
    function ListBoxStyles: WideString; safecall;
  end;

implementation

uses
  POBoxOfficeAU,POBoxManagerF, ComServ2;

procedure TPOBoxManagerAuto.Initialize;
begin
  try
    OfficeList      := TStringList.Create;
    NewSession := Sessions.OpenSession('Session ' + IntToStr(Sessions.Count + 1));
    NewSession.Active := True;
    POBoxManagerForm.AddLog(NewSession.SessionName + ' Opened');

    BoxStyleTable := TTable.Create(nil);
    BoxStyleTable.DatabaseName := 'PSLPOBox';
    BoxStyleTable.TableName := 'BoxStyle.db';
    BoxStyleTable.SessionName := NewSession.SessionName;
    BoxStyleTable.Open;

    BoxOfficeTable := TTable.Create(nil);
    BoxOfficeTable.DatabaseName := 'PSLPOBox';
    BoxOfficeTable.TableName := 'BoxOffice.db';
    BoxOfficeTable.SessionName := NewSession.SessionName;
    BoxOfficeTable.Open;
  except
    On E : Exception do
    begin
      RaiseException($1500,E);
    end;
  end;
end;

destructor TPOBoxManagerAuto.Destroy;
var
  OfficeIndex   : Integer;
begin
  try
    //destroy offices
    For OfficeIndex := 0 to OfficeList.Count -1 do
    begin
      OfficeList.Objects[OfficeIndex] := nil;
    end;
    OfficeList.Free;

    BoxOfficeTable.Close;
    BoxOfficeTable.Free;
    BoxStyleTable.Close;
    BoxStyleTable.Free;
    NewSession.Close;

    Inherited Destroy;
  except
    On E : Exception do
    begin
      RaiseException($1501,E);
      Inherited Destroy;
    end;
  end;
end;

function TPOBoxManagerAuto.AddBox(OfficeNumber, BoxNumber, BlockNumber,
  Style, XCoord, YCoord: Integer; const Features: WideString): IPOBox;
var
  Office : IPOBoxOffice;
begin
  try
    Result := nil;
    Office := Get_Offices(OfficeNumber);
    If Office <> nil then
      Result := Office.AddBox(BoxNumber, BlockNumber, Style, XCoord, YCoord,Features)
    else
    begin
      RaiseError($1502, ET_ErrorLoadingComponent,EP_Warning,'Office ' + IntToStr(OfficeNumber) + ' unavailable.');
      Result := nil;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1502,E);
      Result := nil;
    end;
  end;
end;

function TPOBoxManagerAuto.AddChangeBoxStyle(StyleNumber, Width, Height,
  Depth, PricingStructure: Integer): WordBool;
begin
  try
    Result := False;
    If BoxStyleTable.Locate('BSNumber', StyleNumber, []) then
    begin
      BoxStyleTable.Edit;
      BoxStyleTable.SetFields([StyleNumber, Width, Depth, Height, PricingStructure]);
      BoxStyleTable.Post;
      Result := True;
    end
    else
    begin
      BoxStyleTable.AppendRecord([StyleNumber, Width, Depth, Height, PricingStructure]);
      Result := True;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1503,E);
      Result := False;
    end;
  end;
end;

function TPOBoxManagerAuto.AmountDueForBox(OfficeNumber, BoxNumber,
  RenewalPeriod: Integer): Currency;
begin
  try
    Result := -1;
  except
    On E : Exception do
    begin
      RaiseException($1504,E);
      Result := -1;
    end;
  end;
end;

function TPOBoxManagerAuto.BoxRenewal(OfficeNumber, BoxNumber,
  RenewalPeriod: Integer; AmountPaid: Currency): WordBool;
begin
  try
    Result := False;
  except
    On E : Exception do
    begin
      RaiseException($1505,E);
      Result := False;
    end;
  end;
end;

function TPOBoxManagerAuto.ChangeBoxLock(OfficeNumber, BoxNumber: Integer;
  AmountPaid: Currency): WordBool;
begin
  try
    Result := False;
  except
    On E : Exception do
    begin
      RaiseException($1506,E);
      Result := False;
    end;
  end;
end;

function TPOBoxManagerAuto.ChangeBoxOwner(OfficeNumber, BoxNumber: Integer;
  AmountPaid: Currency; CustomerIdentifier: Integer): WordBool;
begin
  try
    Result := False;
  except
    On E : Exception do
    begin
      RaiseException($1507,E);
      Result := False;
    end;
  end;
end;

function TPOBoxManagerAuto.ChangeCustomer(OfficeNumber,
  CustomerIdentifier: Integer; const Forenames, Surname, BusinessName,
  CustomerType, AddressLines: WideString): WordBool;
var
  Customer : IPOBoxCustomer;
  Office : IPOBoxOffice;

begin
  try
    Result := False;
    Office := Get_Offices(OfficeNumber);
    If Office <> nil then
    begin
      Customer := Office.Customers[CustomerIdentifier];
      If Customer <> nil then
      begin
        Customer.Office       := Office;
        Customer.Forenames    := Forenames;
        Customer.Surname      := Surname;
        Customer.BusinessName := Businessname;
        Customer.CustomerType := CustomerType;
        Customer.AddressLines := AddressLines;
        Result := True;
      end;  //customer <> nil
    end  //office <> nil
    else
    begin
      RaiseError($1508, ET_ErrorLoadingComponent, EP_Warning, 'Office ' + IntToStr(OfficeNumber) + ' unavailable.');
      Result := False;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1508,E);
      Result := False;
    end;
  end;
end;

function TPOBoxManagerAuto.DeleteBox(OfficeNumber,
  BoxNumber: Integer): WordBool;
var
  Box     : IPOBox;
  Office : IPOBoxOffice;
begin
  try
    Result := False;
    Office := self.Get_Offices(OfficeNumber);
    If Office <> nil then
    begin
      Box := Office.Boxes[BoxNumber];
      If Box <> nil then
        Result := Box.Delete
      else
      begin
        RaiseError($1509, ET_ErrorLoadingComponent, EP_Warning,
          'Box ' + IntToStr(BoxNumber)
          + ' in office ' +  IntToStr(OfficeNumber) + ' unavailable.');
        Result := False;
      end;
    end
    else
    begin
      RaiseError($1509, ET_ErrorLoadingComponent, EP_Warning, 'Office ' + IntToStr(OfficeNumber) + ' unavailable.');
      Result := False;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1509,E);
      Result := False;
    end;
  end;
end;

function TPOBoxManagerAuto.FindAvailableBox(OfficeNumber,
  BoxStyle: Integer; const Features: WideString): IPOBox;
var
  Office : IPOBoxOffice;
begin
  try
    Office := Get_Offices(OfficeNumber);
    If Office <> nil then
      Result := Office.FindAvailableBox(BoxStyle, Features)
    else
    begin
      RaiseError($150A, ET_ErrorLoadingComponent, EP_Warning, 'Office ' + IntToStr(OfficeNumber) + ' unavailable.');
      Result := nil;
    end;
  except
    On E : Exception do
    begin
      RaiseException($150A,E);
      Result := nil;
    end;
  end;
end;

function TPOBoxManagerAuto.FindCustomerByBoxNumber(OfficeNumber,
  BoxNumber: Integer): IPOBoxCustomer;
var
  Office : IPOBoxOffice;
begin
  try
    Office := Get_Offices(OfficeNumber);
    If Office <> nil then
      Result := Office.Boxes[BoxNumber].Owner
    else
    begin
      RaiseError($150B, ET_ErrorLoadingComponent, EP_Warning, 'Office ' + IntToStr(OfficeNumber) + ' unavailable.');
      Result := nil;
    end;
  except
    On E : Exception do
    begin
      RaiseException($150B,E);
      Result := nil;
    end;
  end;
end;

function TPOBoxManagerAuto.FindCustomerByBusinessName(
  OfficeNumber: Integer; const BusinessName: WideString): WideString;
var
  Office : IPOBoxOffice;
begin
  try
    Office := Get_Offices(OfficeNumber);
    If Office <> nil then
      Result := Office.FindCustomerByBusinessName(BusinessName)
    else
    begin
      RaiseError($150C, ET_ErrorLoadingComponent, EP_Warning, 'Office ' + IntToStr(OfficeNumber) + ' unavailable.');
      Result := '';
    end;
  except
    On E : Exception do
    begin
      RaiseException($150C,E);
      Result := '';
    end;
  end;
end;

function TPOBoxManagerAuto.FindCustomerByName(OfficeNumber: Integer;
  const Forenames, Surname: WideString): WideString;
var
  Office : IPOBoxOffice;
begin
  try
    Office := Get_Offices(OfficeNumber);
    If Office <> nil then
      Result := Office.FindCustomerByName(ForeNames,Surname)
    else
    begin
      RaiseError($150D, ET_ErrorLoadingComponent, EP_Warning, 'Office ' + IntToStr(OfficeNumber) + ' unavailable.');
      Result := '';
    end;
  except
    On E : Exception do
    begin
      RaiseException($150D,E);
      Result := '';
    end;
  end;
end;

function TPOBoxManagerAuto.FindCustomersByOffice(
  OfficeNumber: Integer): WideString;
var
  Office : IPOBoxOffice;
begin
  try
    Office := Get_Offices(OfficeNumber);
    If Office <> nil then
      Result := Office.FindCustomersByOffice
    else
    begin
      RaiseError($150E, ET_ErrorLoadingComponent, EP_Warning, 'Office ' + IntToStr(OfficeNumber) + ' unavailable.');
      Result := '';
    end;
  except
    On E : Exception do
    begin
      RaiseException($150E,E);
      Result := '';
    end;
  end;
end;

function TPOBoxManagerAuto.GetCustomerDetails(OfficeNumber,
  CustomerIdentifier: Integer): WideString;
var
  Office        : IPOBoxOffice;
  Customer      : IPOBoxCustomer;
begin
  try
    Result := '';
    Office := Get_Offices(OfficeNumber);
    If Office <> nil then
    begin
      Customer := Office.Customers[CustomerIdentifier];
      If Customer <> nil then
        Result := Customer.Details;
    end
    else
    begin
      RaiseError($150F, ET_ErrorLoadingComponent, EP_Warning,
        'Customer  ' + IntToStr(CustomerIdentifier)
        + ' in Office ' + IntToStr(OfficeNumber) + ' not found.');
      Result := '';
    end;
  except
    On E : Exception do
    begin
      RaiseException($150F,E);
      Result := '';
    end;
  end;
end;

function TPOBoxManagerAuto.IssueBoxKey(OfficeNumber, BoxNumber: Integer;
  AmountPaid: Currency): WordBool;
begin
  try

  except
    On E : Exception do
    begin
      RaiseException($1510,E);
      Result := False;
    end;
  end;

end;

function TPOBoxManagerAuto.ListAllBoxesDueBy(OfficeNumber: Integer;
  DueDate: TDateTime): WideString;
var
  Office : IPOBoxOffice;
begin
  try
    Result := '';
    Office := Get_Offices(OfficeNumber);
    If Office <> nil then
    begin
      Result := Office.ListAllBoxesDueBy(DueDate);
    end
    else
    begin
      RaiseError($1511, ET_ErrorLoadingComponent, EP_Warning, 'Office ' + IntToStr(OfficeNumber) + ' unavailable.');
      Result := '';
    end;

  except
    On E : Exception do
    begin
      RaiseException($1511,E);
      Result := '';
    end;
  end;
end;

function TPOBoxManagerAuto.ListAllOverDueBoxes(
  OfficeNumber: Integer): WideString;
begin
  try
    Result := ListAllBoxesDueBy(OfficeNumber, Now);
  except
    On E : Exception do
    begin
      RaiseException($1512,E);
      Result := '';
    end;
  end;

end;

function TPOBoxManagerAuto.ListBoxes(OfficeNumber, BoxStyle,
  BoxState: Integer): WideString;
var
  Office : IPOBoxOffice;
begin
  try
    Office := Get_Offices(OfficeNumber);
    If Office <> nil then
      Result:= Office.ListBoxes(BoxStyle, BoxState)
    else
    begin
      RaiseError($1513, ET_ErrorLoadingComponent, EP_Warning,
        'Office ' + IntToStr(OfficeNumber) + ' not available.');
      Result := '';
    end;
  except
    On E : Exception do
    begin
      RaiseException($1513,E);
      Result := '';
    end;
  end;
end;

function TPOBoxManagerAuto.ListNewReminders(
  OfficeNumber: Integer): WideString;
begin
  try
  except
    On E : Exception do
    begin
      RaiseException($1514,E);
      Result := '';
    end;
  end;
end;

function TPOBoxManagerAuto.NewBoxRental(OfficeNumber, BoxNumber,
  RentalPeriod: Integer; AmountPaid: Currency;
  CustomerIdentifier: Integer): WordBool;
begin
  try
  except
    On E : Exception do
    begin
      RaiseException($1515,E);
      Result := False;
    end;
  end;

end;

function TPOBoxManagerAuto.NewCustomer(OfficeNumber: Integer;
  const Forenames, Surname, BusinessName, CustomerType,
  AddressLines: WideString): IPOBoxCustomer;
var
  Office : IPOBoxOffice;
begin
  try
    Office := Get_Offices(OfficeNumber);
    If Office <> nil then
      Result:= Office.NewCustomer(Forenames,Surname,BusinessName,CustomerType,AddressLines)
    else
    begin
      RaiseError($1516, ET_ErrorLoadingComponent, EP_Warning,
        'Office ' + IntToStr(OfficeNumber) + ' not available.');
      Result := nil;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1516,E);
      Result := nil;
    end;
  end;
end;

function TPOBoxManagerAuto.ReceiveBoxDeposit(OfficeNumber,
  BoxNumber: Integer; AmountPaid: Currency): WordBool;
begin
  try
  except
    On E : Exception do
    begin
      RaiseException($1517,E);
      Result := False;
    end;
  end;
end;

function TPOBoxManagerAuto.ReDirectBoxTo(FromOfficeNumber, FromBoxNumber,
  ToOfficeNumber, ToBoxNumber, ForPeriod: Integer;
  AmountPaid: Currency): WordBool;
begin
  try
  except
    On E : Exception do
    begin
      RaiseException($1518,E);
      Result := False;
    end;
  end;
end;

function TPOBoxManagerAuto.ReturnBoxDeposit(OfficeNumber,
  BoxNumber: Integer; AmountPaid: Currency): WordBool;
begin
  try
  except
    On E : Exception do
    begin
      RaiseException($1519,E);
      Result := False;
    end;
  end;
end;

function TPOBoxManagerAuto.SetBoxState(OfficeNumber, FromBoxNumber,
  ToBoxNumber, BoxStates: Integer): WordBool;
var
  Box       : IPOBox;
  BoxNumber : Integer;
  Office    : IPOBoxOffice;
begin
  try
    Result := False;
    Office := Get_Offices(OfficeNumber);
    If Office <> nil then
    begin
      Result := True; //assume success
      BoxNumber := FromBoxNumber;
      While (Result) and (BoxNumber <= ToBoxNumber) do
      begin
        Box := Office.Boxes[BoxNumber];
        If Box <> nil then
          Box.State := BoxStates //? use logical OR here?
        else
        begin
          RaiseError($151A, ET_ErrorLoadingComponent, EP_Warning,
            'Box' + IntToStr(BoxNumber) + ' in Office ' + IntToStr(OfficeNumber) + ' not available.');
          Result := False;  //failed to update a box
        end;
        Inc(BoxNumber);
      end;
    end
    else //office = nil
    begin
      RaiseError($151A, ET_ErrorLoadingComponent, EP_Warning,
        'Office ' + IntToStr(OfficeNumber) + ' not available.');
      Result := False;
    end;
  except
    On E : Exception do
    begin
      RaiseException($151A,E);
      Result := False;
    end;
  end;
end;

function TPOBoxManagerAuto.SetBoxStyle(OfficeNumber, FromBoxNumber,
  ToBoxNumber, BoxStyle: Integer): WordBool;
var
  Box       : IPOBox;
  BoxNumber : Integer;
  Office    : IPOBoxOffice;
begin
  try
    Result := False;
    Office := Get_Offices(OfficeNumber);
    If Office <> nil then
    begin
      Result := True; //assume success
      BoxNumber := FromBoxNumber;
      While (Result) and (BoxNumber <= ToBoxNumber) do
      begin
        Box := Office.Boxes[BoxNumber];
        If Box <> nil then
          Box.Style := BoxStyle //? use logical OR here?
        else
        begin
          RaiseError($151B, ET_ErrorLoadingComponent, EP_Warning,
            'Box' + IntToStr(BoxNumber) + ' in Office ' + IntToStr(OfficeNumber) + ' not available.');
          Result := False;  //failed to update a box
        end;
        Inc(BoxNumber);
      end;
    end
    else
    begin
      RaiseError($151B, ET_ErrorLoadingComponent, EP_Warning,
        'Office ' + IntToStr(OfficeNumber) + ' not available.');
      Result := False;
    end;
  except
    On E : Exception do
    begin
      RaiseException($151B,E);
      Result := False;
    end;
  end;
end;

function TPOBoxManagerAuto.Get_Clerk: WideString;
begin
  try
    Result := FClerk;
  except
    On E : Exception do
    begin
      RaiseException($151C,E);
      Result := '';
    end;
  end;
end;

procedure TPOBoxManagerAuto.Set_Clerk(const Value: WideString);
begin
  try
    If FClerk <> Value then
      FClerk  := Value;
  except
    On E : Exception do
    begin
      RaiseException($151D,E);
    end;
  end;
end;

function TPOBoxManagerAuto.Get_Site: Integer;
begin
  try
    Result := FSite;
  except
    On E : Exception do
    begin
      RaiseException($151E,E);
      Result := 0;
    end;
  end;
end;

procedure TPOBoxManagerAuto.Set_Site(Value: Integer);
begin
  try
    If FSite <> Value then
      FSite := Value;
  except
    On E : Exception do
    begin
      RaiseException($151F,E);
    end;
  end;
end;

function TPOBoxManagerAuto.Get_Workstation: Integer;
begin
  try
    Result := FWorkstation;
  except
    On E : Exception do
    begin
      RaiseException($1520,E);
      Result := 0;
    end;
  end;
end;

procedure TPOBoxManagerAuto.Set_Workstation(Value: Integer);
begin
  try
    If FWorkstation <> Value then
      FWorkstation := Value;
  except
    On E : Exception do
    begin
      RaiseException($1521,E);
    end;
  end;
end;

function TPOBoxManagerAuto.Get_Boxes(OfficeNumber, BoxNumber: Integer): IPOBox;
var
  Office : IPOBoxOffice;
begin
  try
    Office := Get_Offices(OfficeNumber);
    If Office <> nil then
      Result := Office.Boxes[BoxNumber]
    else
    begin
      RaiseError($1522, ET_ErrorLoadingComponent, EP_Warning,
        'Office ' + IntToStr(OfficeNumber) + ' not available.');
      Result := nil;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1522,E);
      Result := nil;
    end;
  end;
end;

function TPOBoxManagerAuto.Get_Customers(OfficeNumber,
  CustomerIdentifier: Integer): IPOBoxCustomer;
var
  Office : IPOBoxOffice;
begin
  try
    Office := Get_Offices(OfficeNumber);
    If Office <> nil then
      Result := Office.Customers[CustomerIdentifier]
    else
    begin
       RaiseError($1523, ET_ErrorLoadingComponent, EP_Warning,
        'Office ' + IntToStr(OfficeNumber) + ' not available.');
       Result := nil;
     end;
  except
    On E : Exception do
    begin
      RaiseException($1523,E);
      Result := nil;
    end;
  end;
end;

function TPOBoxManagerAuto.Get_Offices(
  OfficeNumber: Integer): IPOBoxOffice;
var
  NewOffice   : TPOBoxOffice;
  OfficeIndex : Integer;
begin
  try
    OfficeIndex := OfficeList.IndexOf(IntToStr(OfficeNumber));
    If OfficeIndex >=0 then
      Result := (OfficeList.Objects[OfficeIndex]) As TPOBoxOffice
    else
    begin
      NewOffice := TPOBoxOffice.Create;
      (NewOffice As IPOBoxOffice).Number := OfficeNumber;
      If (NewOffice As IPOBoxOffice).Number = OfficeNumber then  //found office
      begin
        (NewOffice As IPOBoxOffice).POBoxManager := self;
        OfficeIndex := OfficeList.AddObject(IntToStr(OfficeNumber),NewOffice);
        Result := TPOBoxOffice(OfficeList.Objects[OfficeIndex]);
      end
      else
      begin
        RaiseError($1524, ET_ErrorLoadingComponent, EP_Warning,
          'Office ' + IntToStr(OfficeNumber) + ' not available.');
        Result := nil;
      end;
    end;

    //update form
    If POBoxManagerForm.Visible then
    begin
      POBoxManagerForm.CacheOfficesListBox.Items.CommaText := OfficeList.CommaText;
      POBoxManagerForm.CacheOfficesListBox.Items.Insert(0, 'Offices:');
    end;
  except
    On E : Exception do
    begin
      RaiseException($1524,E);
      Result := nil;
    end;
  end;
end;

function TPOBoxManagerAuto.AddOffice(OfficeNumber: Integer; const Name,
  Address: WideString): IPOBoxOffice;
begin
  try
    Result := nil;
    If not BoxOfficeTable.Locate('BFNumber', OfficeNumber, []) then
    begin
      BoxOfficeTable.Append;
      BoxOfficeTable.FieldValues['BFNumber']  := OfficeNumber;
      BoxOfficeTable.FieldValues['BFName']    := Name;
      BoxOfficeTable.FieldValues['BFAddress'] := Address;
      BoxOfficeTable.Post;
      Result := self.Get_Offices(OfficeNumber);
    end
    else
    begin
      RaiseError($1525, ET_ErrorLoadingComponent, EP_Warning,
         'Office ' + IntToStr(OfficeNumber) + ' already exists.');
      Result := nil;  //officealready exists
    end;
  except
    On E : Exception do
    begin
      RaiseException($1525,E);
      Result := nil;
    end;
  end;

end;

function TPOBoxManagerAuto.DeleteOffice(OfficeNumber: Integer): WordBool;
var
  Office : IPOBoxOffice;
begin
  try
    Office := Get_Offices(OfficeNumber);
    If Office <> nil then
      Result := Office.Delete
    else
    begin
      RaiseError($1526, ET_ErrorLoadingComponent, EP_Warning,
        'Office ' + IntToStr(OfficeNumber) + ' not available.');
      Result := False;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1526,E);
      Result := False;
    end;
  end;
end;

function TPOBoxManagerAuto.ListBoxStyles: WideString;
begin
  try
    Result := '';
    BoxStyleTable.First;
    While not BoxStyleTable.EOF do
    begin
      Result := Result
        + IntToStr(BoxStyleTable.FieldByName('BSNumber').AsInteger) + ',';
      BoxStyleTable.Next;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1527,E);
      Result := '';
    end;
  end;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TPOBoxManagerAuto, Class_POBoxManagerAuto, ciMultiInstance);
end.
