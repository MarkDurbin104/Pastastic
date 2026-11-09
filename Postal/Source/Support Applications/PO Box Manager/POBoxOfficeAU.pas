unit POBoxOfficeAU;

interface

uses
  Forms,
  POBoxOfficeF,
  GPCSBase_TLB,
  GPCSGUID,
  GPCSErrorLine,
  DBTables,
  POBoxAU,
  SysUtils,
  Classes,
  ComObj, ActiveX, POBoxManager_TLB;

type
  TPOBoxOffice = class(TAutoObject, IPOBoxOffice)
  private
    BoxList           : TStringList;
    BoxOfficeTable    : TTable;
    BoxTable          : TTable;
    BoxCustomerTable  : TTable;

    CustomerList      : TStringList;
    CustomerCounter   : IDevice;
    FName         : String;
    FAddress      : String;
    FNumber       : Integer;
    FOfficeForm   : TPOBoxOfficeForm;
    FPOBoxManager : IPOBoxManagerAuto;

    function UpdateField(FieldName : String; Value : Variant) : Boolean;
  protected
    procedure Initialize; override;
    destructor Destroy; override;
    function Get_Number: Integer; safecall;
    procedure Set_Number(Value: Integer); safecall;
    function FindAvailableBox(BoxStyle: Integer;
      const Features: WideString): IPOBox; safecall;
    function ListBoxes(BoxStyle, BoxState: Integer): WideString; safecall;
    function DeleteBox(BoxNumber: Integer): WordBool; safecall;
    function Get_Boxes(BoxNumber: Integer): IPOBox; safecall;
    function Get_Customers(CustomerIdentifier: Integer): IPOBoxCustomer;
      safecall;
    function ListCustomers: WideString; safecall;
    function AddBox(Box: IPOBox): IPOBox; safecall;
    function Get_Address: WideString; safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Address(const Value: WideString); safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function FindCustomerByBusinessName(
      const BusinessName: WideString): WideString; safecall;
    function FindCustomerByName(const Forenames,
      Surname: WideString): WideString; safecall;
    function FindCustomersByOffice: WideString; safecall;
    function ListAllBoxesDueBy(DueDate: TDateTime): WideString; safecall;
    function NewCustomer(const Forenames, Surname, BusinessName, CustomerType,
      AddressLines: WideString): IPOBoxCustomer; safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_POBoxManager: IPOBoxManagerAuto; safecall;
    procedure Set_POBoxManager(const Value: IPOBoxManagerAuto); safecall;
    function Delete: WordBool; safecall;
    function Get_Code: WideString; safecall;
    procedure Set_Code(const Value: WideString); safecall;
    function AddUser(POBoxUser: IPOBoxCustomer): WordBool; safecall;
    function Application(User: IPOBoxCustomer): WordBool; safecall;
    function GetBox(BoxNumber: WideString): IPOBox; safecall;
    function RemoveBox(IPOBox: Integer): WordBool; safecall;
    function IPOBoxOffice.AddBox = IPOBoxOffice_AddBox;
    function IPOBoxOffice.AddUser = IPOBoxOffice_AddUser;
    function IPOBoxOffice.Application = IPOBoxOffice_Application;
    function IPOBoxOffice.GetBox = IPOBoxOffice_GetBox;
    function IPOBoxOffice_AddBox(const Box: IPOBox): IPOBox; safecall;
    function IPOBoxOffice_AddUser(const POBoxUser: IPOBoxCustomer): WordBool;
      safecall;
    function IPOBoxOffice_Application(const User: IPOBoxCustomer): WordBool;
      safecall;
    function IPOBoxOffice_GetBox(const BoxNumber: WideString): IPOBox;
      safecall;
  end;

implementation

uses POBoxCustomerAU, POBoxManagerF,ComServ2;

procedure TPOBoxOffice.Initialize;
begin
  try
    Inherited Initialize;
    _AddRef;

    CustomerCounter := CreateCounterDevice;
    CustomerCounter.WriteDevice(dcInitialise, 'PO Box Customer Ident', 0);

    BoxList       := TStringList.Create;
    CustomerList  := TStringList.Create;

    BoxOfficeTable := TTable.Create(nil);
    BoxOfficeTable.DatabaseName := 'PSLPOBox';
    BoxOfficeTable.TableName := 'BoxOffice.db';
    BoxOfficeTable.Open;

    BoxTable := TTable.Create(nil);
    BoxTable.DatabaseName := 'PSLPOBox';
    BoxTable.TableName := 'Box.db';
    BoxTable.Open;

    BoxCustomerTable := TTable.Create(nil);
    BoxCustomerTable.DatabaseName := 'PSLPOBox';
    BoxCustomerTable.TableName := 'BoxCustomer.db';
    BoxCustomerTable.Open;
  except
    On E : Exception do
    begin
      RaiseException($1600,E);
    end;
  end;
end;

destructor TPOBoxOffice.Destroy;
var
  BoxIndex      : Integer;
  CustomerIndex : Integer;
begin
  try
    //destroy boxes
    For BoxIndex := 0 to BoxList.Count -1 do
    begin
      BoxList.Objects[BoxIndex] := nil;
    end;
    BoxList.Free;

    //destroy customers
    For CustomerIndex := 0 to CustomerList.Count -1 do
    begin
      CustomerList.Objects[CustomerIndex] := nil;
    end;
    CustomerList.Free;

    //close counter
    If CustomerCounter <> nil then
    begin
      CustomerCounter.WriteDevice(dcShutdown, '',0);
      CustomerCounter := nil;
    end;

    //close form
    FOfficeForm.Free;

    FPOBoxManager := nil;

    //close and free tables
    BoxOfficeTable.Close;
    BoxOfficeTable.Free;
    BoxTable.Close;
    BoxTable.Free;
    BoxCustomerTable.Close;
    BoxCustomerTable.Free;
    Inherited Destroy;
  except
    On E : Exception do
    begin
      RaiseException($1601,E);
    end;
  end;
end;

function TPOBoxOffice.Get_Number: Integer;
begin
  try
    Result := FNumber;
  except
    On E : Exception do
    begin
      RaiseException($1602,E);
      Result := 0;
    end;
  end;
end;

procedure TPOBoxOffice.Set_Number(Value: Integer);
begin
  try
    If BoxOfficeTable.Locate('BFNumber', value, []) then
    begin
      FNumber   := Value;
      FName     :=  BoxOfficeTable.FieldByName('BFName').AsString;
      FAddress  :=  BoxOfficeTable.FieldByName('BFAddress').AsString;
    end
    else
    begin
      RaiseError($1603, ET_ErrorLoadingComponent, EP_Warning,'Office ' + IntToStr(Value) + ' not found.');      
    end;
  except
    On E : Exception do
    begin
      RaiseException($1603, E);
    end;
  end;
end;

function TPOBoxOffice.FindAvailableBox(BoxStyle: Integer;
  const Features: WideString): IPOBox;
var
  BoxFeaturesList : TStringList;
  ReqdFeaturesIndex : Integer;
  ReqdFeaturesList : TStringList;
  FoundAllFeatures : Boolean;
begin
  try
    ReqdFeaturesList  := TStringList.Create;
    BoxFeaturesList   := TStringList.Create;
    try
      Result := nil;
      ReqdFeaturesList.CommaText := Features; //get required features into list
      BoxTable.Filter :=    ' BOOffice = ' + IntToStr(Fnumber)
                          + ' and BOStyle = ' + IntToStr(BoxStyle)
                          + ' and BOOwner = 0';
      BoxTable.Filtered := True;
      try
        BoxTable.First;
        While (Result = nil) and (Not BoxTable.EOF) do
        begin

          //check for required features
          FoundAllFeatures := True;  //assume will not be found
          BoxFeaturesList.CommaText := BoxTable.FieldByName('BOFeatures').AsString;  //get box features
          ReqdFeaturesIndex := 0;
          //check all features
          While (FoundAllFeatures = True) and (ReqdFeaturesIndex <= (ReqdFeaturesList.Count -1)) do
          begin
            FoundAllFeatures := BoxFeaturesList.IndexOf(ReqdFeaturesList[ReqdFeaturesIndex]) >= 0;  //found the feature
            Inc(ReqdFeaturesIndex);
          end;

          If FoundAllFeatures then
            Result := Get_Boxes(BoxTable.FieldValues['BONumber']);

          BoxTable.Next;
        end;  //while not found box

      finally
        //ensure dataset is restored
        BoxTable.Filtered := False;
        BoxTable.Refresh;
      end;

    finally
      ReqdFeaturesList.Free;
      BoxFeaturesList.Free;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1604, E);
      Result := nil;
    end;
  end;
end;

function TPOBoxOffice.ListBoxes(BoxStyle, BoxState: Integer): WideString;
var
  BoxList : TStringList;
begin
  try
    BoxList := TStringList.Create;
    Result := '';
    try
      BoxTable.Filter :=  ' BOOffice = '    + IntToStr(FNumber);
      If BoxStyle <> 0 then //specific style required
        BoxTable.Filter := BoxTable.Filter + ' and BOStyle = ' + IntToStr(BoxStyle);
      BoxTable.Filtered := True;
      try
        BoxTable.First;
        While Not BoxTable.EOF do
        begin
          //test for required state
          If (BoxState = 0)
              or ((BoxTable.FieldValues['BOState'].AsInteger and BoxState) = BoxState) then  //any box state
          begin
            BoxList.Add(BoxTable.FieldValues['BONumber'])
          end;
          BoxTable.Next;
        end;
        Result := BoxList.CommaText;
      finally
        //ensure dateset is refreshed
        BoxTable.Filtered := False;
        BoxTable.Refresh;
      end;
    finally
      BoxList.Free;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1605, E);
      Result := '';
    end;
  end;
end;

function TPOBoxOffice.DeleteBox(BoxNumber: Integer): WordBool;
var
  Box : IPOBox;
begin
  try
    Result := False;
    Box := Get_Boxes(BoxNumber);
    If Box <> nil then
    begin
      Box.Delete;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1605, E);
      Result := False;
    end;
  end;
end;

function TPOBoxOffice.Get_Boxes(BoxNumber: Integer): IPOBox;
var
  BoxIndex : Integer;
  NEwBox    : TPOBox;
begin
  try
  BoxIndex := BoxList.IndexOf(IntToStr(BoxNumber));
  If BoxIndex >=0 then
    Result := (BoxList.Objects[BoxIndex]) As TPOBox
  else
  begin
    NewBox := TPOBox.Create;
    (NewBox As IPOBox).Office := self;
    (NewBox As IPOBox).Number := BoxNumber;
    If (NewBox As IPOBox).Number = BoxNumber then  //box data found
    begin
      BoxIndex := BoxList.AddObject(IntToStr(BoxNumber),NewBox);
      Result := TPOBox(BoxList.Objects[BoxIndex]);
    end
    else
    begin
      NewBox.Free;
      Result := nil;
    end;
  end;

  //update form
  If POBoxManagerForm.Visible then
  begin
    POBoxManagerForm.CacheBoxesListBox.Items.Assign(BoxList);
    POBoxManagerForm.CacheBoxesListBox.Items.Insert(0, 'Boxes:');
  end;
  except
    On E : Exception do
    begin
      RaiseException($1606, E);
      Result := nil;
    end;
  end;
end;

function TPOBoxOffice.Get_Customers(
  CustomerIdentifier: Integer): IPOBoxCustomer;
var
  CustomerIndex : Integer;
  NewCustomer    : TPOBoxCustomer;
begin
  try
    CustomerIndex := CustomerList.IndexOf(IntToStr(CustomerIdentifier));
    If CustomerIndex >=0 then
      Result := (CustomerList.Objects[CustomerIndex]) As TPOBoxCustomer
    else
    begin
      NewCustomer := TPOBoxCustomer.Create;
      (NewCustomer As IPOBoxCustomer).Office := self;
      (NewCustomer As IPOBoxCustomer).Identifier := CustomerIdentifier;
      If (NewCustomer As IPOBoxCustomer).Identifier = CustomerIdentifier then  //Customer data found
      begin
        CustomerIndex := CustomerList.AddObject(IntToStr(CustomerIdentifier),NewCustomer);
        Result := TPOBoxCustomer(CustomerList.Objects[CustomerIndex]);
      end
      else
      begin
        NewCustomer.Free;
        Result := nil;
      end;
    end;

      //update form
    If POBoxManagerForm.Visible then
    begin
      POBoxManagerForm.CacheCustomersListBox.Items.Assign(CustomerList);
      POBoxManagerForm.CacheCustomersListBox.Items.Insert(0, 'Customers:');
    end;
  except
    On E : Exception do
    begin
      RaiseException($1607, E);
      Result := nil;
    end;
  end;
end;

function TPOBoxOffice.ListCustomers: WideString;
var
  CustomerList : TStringList;
begin
  try
    CustomerList := TStringList.Create;
    Result := '';
    try
      BoxCustomerTable.Filter :=  ' BCOffice = '    + IntToStr(FNumber);
      BoxCustomerTable.Filtered := True;
      try
        BoxCustomerTable.First;
        While Not BoxCustomerTable.EOF do
        begin
          //test for required state
          CustomerList.Add(BoxCustomerTable.FieldValues['BCIdentifier']);
          BoxCustomerTable.Next;
        end;
        Result := CustomerList.CommaText;
      finally
        //ensure dateset is refreshed
        BoxCustomerTable.Filtered := False;
        BoxCustomerTable.Refresh;
      end;
    finally
      CustomerList.Free;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1608, E);
      Result := '';
    end;
  end;
end;

function TPOBoxOffice.AddBox(Box: IPOBox): IPOBox;
begin
  try
    Result := nil;
    If not BoxTable.Locate('BOOffice;BONumber', VarArrayOf([FNumber, BoxNumber]), []) then
    begin
      BoxTable.Append;
      BoxTable.FieldValues['BOOffice']      := FNumber;
      BoxTable.FieldValues['BONumber']      := BoxNumber;
      BoxTable.FieldValues['BOStyle']       := Style;
      BoxTable.FieldValues['BOFeatures']    := Features;
      BoxTable.FieldValues['BOState']       := 0;
      BoxTable.FieldValues['BOBlockNumber'] := BlockNumber;
      BoxTable.FieldValues['BOXCoord']      := XCoord;
      BoxTable.FieldValues['BOYCoord']      := YCoord;
      BoxTable.FieldValues['BOOwner']       := 0;
      BoxTable.FieldValues['BOKeysIssued']  := 0;
      BoxTable.FieldValues['BODepositHeld'] := 0;
      BoxTable.FieldValues['BOLockNumber']  := 0;
      BoxTable.FieldValues['BORenewalDate'] := null;   //renewal date
      BoxTable.Post;
      Result := Get_Boxes(BoxNumber);
    end
    else
      Result := nil;  //customer name already exists
  except
    On E : Exception do
    begin
      RaiseException($1609, E);
      Result := nil;
    end;
  end;
end;

function TPOBoxOffice.Get_Address: WideString;
begin
  try
    Result := FAddress;
  except
    On E : Exception do
    begin
      RaiseException($1610, E);
      Result := '';
    end;
  end;
end;

procedure TPOBoxOffice.Set_Address(const Value: WideString);
begin
  try
    If Value <> FAddress then
    begin
      If UpdateField('BFAddress', Value) then
        FAddress := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1611, E);
    end;
  end;
end;

function TPOBoxOffice.Get_Name: WideString;
begin
  try
    Result := FName;
  except
    On E : Exception do
    begin
      RaiseException($1612, E);
      Result := '';
    end;
  end;
end;

procedure TPOBoxOffice.Set_Name(const Value: WideString);
begin
  try
    If Value <> FName then
    begin
      If UpdateField('BFName', Value) then
        FName := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1613, E);
    end;
  end;
end;

function TPOBoxOffice.UpdateField(FieldName : String; Value : Variant) : Boolean;
begin
  try
    Result := False;
    If BoxOfficeTable.Locate('BFNumber',FNumber, []) then
    begin
      BoxOfficeTable.Edit;
      BoxOfficeTable.FieldValues[FieldName] := Value;
      BoxOfficeTable.Post;
      Result := True;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1614, E);
      Result := False;
    end;
  end;
end;


function TPOBoxOffice.FindCustomerByBusinessName(
  const BusinessName: WideString): WideString;
var
  CustomerList : TStringList;
begin
  try
    Result := '';
    CustomerList := TStringList.Create;
    try
      BoxCustomerTable.Filter :=
        'BCOffice = ' + IntToStr(FNumber)  + ' and BCBusinessName = ''' + BusinessName + '*''';
      BoxCustomertable.Filtered := True;
      try
        BoxCustomertable.Refresh;
        BoxCustomertable.First;

        While Not BoxCustomertable.EOF do
        begin
          CustomerList.Add(BoxCustomertable.FieldByName('BCIdentifier').AsString);
          BoxCustomertable.Next;
        end;
      finally
        BoxCustomertable.Filtered := False;
        BoxCustomertable.Refresh;
      end;

      Result := CustomerList.CommaText;
    finally
      CustomerList.Free;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1637,E);
      Result := '';
    end;
  end;
end;

function TPOBoxOffice.FindCustomerByName(const Forenames,
  Surname: WideString): WideString;
var
  CustomerList : TStringList;
begin
  try
    Result := '';
    CustomerList := TStringList.Create;
    try
      BoxCustomertable.Filtered := False;
      BoxCustomerTable.Filter :=
        'BCOffice = ' + IntToStr(FNumber)
        + ' and BCForename = ''*' + ForeNames + '*'''
        + ' and BCSurname  = ''*' + Surname   + '*''';
      BoxCustomertable.Filtered := True;
      try
        BoxCustomertable.Refresh;
        BoxCustomertable.First;

        While Not BoxCustomertable.EOF do
        begin
          CustomerList.Add(BoxCustomertable.FieldByName('BCIdentifier').AsString);
          BoxCustomertable.Next;
        end;
      finally
        BoxCustomerTable.Filtered := False;
        BoxCustomerTable.Refresh;
      end;

      Result := CustomerList.CommaText;
    finally
      CustomerList.Free;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1638,E);
      Result := '';
    end;
  end;
end;

function TPOBoxOffice.FindCustomersByOffice: WideString;
var
  CustomerList : TStringList;
begin
  try
    Result := '';
    CustomerList := TStringList.Create;
    try
      BoxCustomerTable.Filter :=
        'BCOffice = ' + IntToStr(FNumber) ;
      BoxCustomertable.Filtered := True;
      try
        BoxCustomertable.Refresh;
        BoxCustomertable.First;

        While Not BoxCustomertable.EOF do
        begin
          CustomerList.Add(BoxCustomertable.FieldByName('BCIdentifier').AsString);
          BoxCustomertable.Next;
        end;
      finally
        BoxCustomerTable.Filtered := False;
        BoxCustomerTable.Refresh;
      end;

      Result := CustomerList.CommaText;
    finally
      CustomerList.Free;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1639,E);
      Result := '';
    end;
  end;
end;

function TPOBoxOffice.ListAllBoxesDueBy(DueDate: TDateTime): WideString;
var
  BoxList : TStringList;
begin
  try
    BoxList := TStringList.Create;
    Result := '';
    try
      BoxTable.Filter :=    'BOOffice = ' + IntToStr(FNumber)
                          + ' and BORenewalDate <> "' + DateTimeToStr(0) + '"'
                          + ' and BORenewalDate <= "' + DateTimeToStr(DueDate) + '"';
      BoxTable.Filtered := True;
      try
        BoxTable.First;

        While Not BoxTable.EOF do
        begin
          BoxList.Add(BoxTable.FieldValues['BONumber'].AsString);
          BoxTable.Next;
        end;
        Result := BoxList.CommaText;
      finally
        //ensure dataset is refreshed
        BoxTable.Filtered := False;
        BoxTable.Refresh;
      end;
    finally
      BoxList.Free;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1640,E);
      Result := '';
    end;
  end;
end;

function TPOBoxOffice.NewCustomer(const Forenames, Surname, BusinessName,
  CustomerType, AddressLines: WideString): IPOBoxCustomer;
var
  NewCustomerIdentifier : Integer;
begin
  try
    If not BoxCustomerTable.Locate('BCOffice; BCForenames; BCSurname; BCBusinessName', VarArrayOf([FNumber,Forenames, Surname, BusinessName]), []) then
    begin
      //get next customer identifier
      NewCustomerIdentifier := StrToInt(CustomerCounter.GetStatus)+1; //avoid 0 id
      BoxCustomerTable.Append;
      BoxCustomerTable.FieldValues['BCOffice']        := FNumber;
      BoxCustomerTable.FieldValues['BCIdentifier']    := NewCustomerIdentifier;
      BoxCustomerTable.FieldValues['BCForenames']     := Forenames;
      BoxCustomerTable.FieldValues['BCSurname']       := Surname;
      BoxCustomerTable.FieldValues['BCBusinessName']  := BusinessName;
      BoxCustomerTable.FieldValues['BCType']          := CustomerType;
      BoxCustomerTable.FieldValues['BCAddress']       := AddressLines;
      BoxCustomerTable.Post;

      Result := Get_Customers(NewCustomerIdentifier);
    end
    else
    begin
      RaiseError($1641, ET_ErrorLoadingComponent, EP_Warning,
      'Customer  ' + Forenames + ' ' + Surname + ' Business ' + BusinessName
      + ' in Office ' + IntToStr(FNumber) + ' already exists.');
      Result := nil;  //customer name already exists
    end;
  except
    On E : Exception do
    begin
      RaiseException($1641,E);
      Result := nil;
    end;
  end;
end;

function TPOBoxOffice.Get_Visible: WordBool;
begin
  try
    If (FOfficeForm = nil) or (FOfficeForm.Visible = False) then
    begin
      Result := False;
    end
    else
    begin
      Result := True;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1642,E);
      Result := False;
    end;
  end;
end;

procedure TPOBoxOffice.Set_Visible(Value: WordBool);
begin
  try
    If Value <> Get_Visible then
    begin
      If FOfficeForm = nil then
      begin
        FOfficeForm := TPOBoxOfficeForm.Create(Application) ;
        FOfficeForm.Office := self;
      end;

      FOfficeForm.Visible := Value;
    end;
    If Value = True then
    begin
      FOfficeForm.UpdateFormDetails(self);
      FOfficeForm.BringToFront;
    end;

  except
    On E : Exception do
    begin
      RaiseException($1643,E);
    end;                                           
  end;
end;

function TPOBoxOffice.Get_POBoxManager: IPOBoxManagerAuto;
begin
  try
    Result := FPOBoxManager;
  except
    On E : Exception do
    begin
      RaiseException($1644,E);
      Result := nil;
    end;
  end;
end;

procedure TPOBoxOffice.Set_POBoxManager(const Value: IPOBoxManagerAuto);
begin
  try
    If FPOBoxManager <> Value then
    begin
      FPOBoxManager := nil;
      FPOBoxManager := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1645,E);
    end;
  end;
end;

function TPOBoxOffice.Delete: WordBool;
begin
  try
    Result := False;
    If BoxOfficeTable.Locate('BFNumber',FNumber, []) then
    begin
      BoxOfficeTable.Delete;
      self.Free;
      Result := True;
    end
    else
    begin
      RaiseError($1646, ET_ErrorLoadingComponent, EP_Warning,
       'Office ' + IntToStr(FNumber) + ' not available.');
      Result := False;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1646,E);
      Result := False;
    end;
  end;
end;


function TPOBoxOffice.Get_Code: WideString;
begin

end;

procedure TPOBoxOffice.Set_Code(const Value: WideString);
begin

end;

function TPOBoxOffice.AddUser(POBoxUser: IPOBoxCustomer): WordBool;
begin

end;

function TPOBoxOffice.Application(User: IPOBoxCustomer): WordBool;
begin

end;

function TPOBoxOffice.GetBox(BoxNumber: WideString): IPOBox;
begin

end;

function TPOBoxOffice.RemoveBox(IPOBox: Integer): WordBool;
begin

end;

function TPOBoxOffice.IPOBoxOffice_AddBox(const Box: IPOBox): IPOBox;
begin

end;

function TPOBoxOffice.IPOBoxOffice_AddUser(
  const POBoxUser: IPOBoxCustomer): WordBool;
begin

end;

function TPOBoxOffice.IPOBoxOffice_Application(
  const User: IPOBoxCustomer): WordBool;
begin

end;

function TPOBoxOffice.IPOBoxOffice_GetBox(
  const BoxNumber: WideString): IPOBox;
begin

end;

initialization
  TAutoObjectFactory.Create(ComServer, TPOBoxOffice, Class_POBoxOffice, ciInternal);
end.
