unit POBoxCustomerAU;

interface

uses
  Forms,
  POBoxCustomerF,
  GPCSErrorLine,
  SysUtils,
  POBoxManagerAU, Classes, DbTables,
  ComObj, ActiveX, POBoxManager_TLB;

type
  TPOBoxCustomer = class(TAutoObject, IPOBoxCustomer)
  private
    FAddressLines     : WideString;
    FBusinessName     : WideString;
    FCustomerForm     : TPOBoxCustomerForm;
    FCustomerType     : WideString;
    FIdentifier       : Integer;
    FForenames        : WideString;
    FOffice           : IPOBoxOffice;
    FState            : Integer;
    FSurname          : WideString;
    FTelephone        : WideString;
    FFax              : WideString;
    FZipCode          : WideString;
    FIdType           : WideString; //passport, id card etc
    FId               : WideString; //eg, passport number
    FDelegates        : WideString; //named delegates for customer

    BoxCustomerTable  : TTable;
    function UpdateField(FieldName : String; Value : Variant) : Boolean;
  protected
    procedure Initialize; override;
    destructor Destroy; override;

    function Get_AddressLines: WideString; safecall;
    procedure Set_AddressLines(const Value: WideString); safecall;
    function Get_Boxes(BoxNumber: Integer): IPOBox; safecall;
    function Get_BusinessName: WideString; safecall;
    procedure Set_BusinessName(const Value: WideString); safecall;
    function Get_CustomerType: WideString; safecall;
    procedure Set_CustomerType(const Value: WideString); safecall;
    function Get_Identifier: Integer; safecall;
    procedure Set_Identifier(Value: Integer); safecall;
    function Get_Office: IPOBoxOffice; safecall;
    procedure Set_Office(const Value: IPOBoxOffice); safecall;
    function Get_Details: WideString; safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_State: Integer; safecall;
    procedure Set_State(Value: Integer); safecall;
    function Delete: WordBool; safecall;
    function Get_Forenames: WideString; safecall;
    function Get_Surname: WideString; safecall;
    procedure Set_Forenames(const Value: WideString); safecall;
    procedure Set_Surname(const Value: WideString); safecall;
    function Get_Delegates: WideString; safecall;
    function Get_Fax: WideString; safecall;
    function Get_Id: WideString; safecall;
    function Get_IdType: WideString; safecall;
    function Get_Telephone: WideString; safecall;
    function Get_ZipCode: WideString; safecall;
    procedure Set_Delegates(const Value: WideString); safecall;
    procedure Set_Fax(const Value: WideString); safecall;
    procedure Set_Id(const Value: WideString); safecall;
    procedure Set_IdType(const Value: WideString); safecall;
    procedure Set_Telephone(const Value: WideString); safecall;
    procedure Set_ZipCode(const Value: WideString); safecall;
  end;

implementation

uses ComServ2;

procedure TPOBoxCustomer.Initialize;
begin
  try
    Inherited Initialize;
    _AddRef;

    BoxCustomerTable := TTable.Create(nil);
    BoxCustomerTable.DatabaseName := 'PSLPOBox';
    BoxCustomerTable.TableName := 'BoxCustomer.db';
    BoxCustomerTable.Open;
  except
    On E : Exception do
    begin
      RaiseException($1637, E);
    end;
  end;
end;

destructor TPOBoxCustomer.Destroy;
begin
  try
    BoxCustomerTable.Close;
    BoxCustomerTable.Free;
    Inherited Destroy;
  except
    On E : Exception do
    begin
      RaiseException($1638, E);
    end;
  end;
end;

function TPOBoxCustomer.Get_AddressLines: WideString;
begin
  try
    Result := FAddressLines;
  except
    On E : Exception do
    begin
      RaiseException($1638, E);
      Result := '';
    end;
  end;
end;

procedure TPOBoxCustomer.Set_AddressLines(const Value: WideString);
begin
  try
    If Value <> FAddressLines then
    begin
      If UpdateField('BCAddress',Value) then
        FAddressLines := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1639, E);
    end;
  end;
end;

function TPOBoxCustomer.Get_Boxes(BoxNumber: Integer): IPOBox;
var
  Office : IPOBoxOffice;
begin
  try
    Office := (self as IPOBoxCustomer).Office;
    If Office <> nil then
      Result := Office.Boxes[BoxNumber]
    else
      Result := nil;
  except
    On E : Exception do
    begin
      RaiseException($163A, E);
      Result := nil;
    end;
  end;
end;

function TPOBoxCustomer.Get_BusinessName: WideString;
begin
  try
    Result := FBusinessName;
  except
    On E : Exception do
    begin
      RaiseException($163B, E);
      Result := '';
    end;
  end;
end;

procedure TPOBoxCustomer.Set_BusinessName(const Value: WideString);
begin
  try
    If Value <> FBusinessName then
    begin
      If UpdateField('BCBusinessName',Value) then
        FBusinessName := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($163C, E);
    end;
  end;
end;

function TPOBoxCustomer.Get_CustomerType: WideString;
begin
  try
    Result := FCustomerType;
  except
    On E : Exception do
    begin
      RaiseException($163D, E);
      Result := '';
    end;
  end;
end;

procedure TPOBoxCustomer.Set_CustomerType(const Value: WideString);
begin
  try
    If Value <> FCustomerType then
    begin
      If UpdateField('BCType',Value) then
        FCustomerType := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($163E, E);
    end;
  end;
end;

function TPOBoxCustomer.Get_Identifier: Integer;
begin
  try
    Result := FIdentifier;
  except
    On E : Exception do
    begin
      RaiseException($163F, E);
      Result := 0;
    end;
  end;
end;

procedure TPOBoxCustomer.Set_Identifier(Value: Integer);
begin
  try
    If BoxCustomerTable.Locate('BCOffice;BCIdentifier', VarArrayOf([FOffice.Number,Value]), []) then
    begin
      FIdentifier   := Value;
      FForeNames    := BoxCustomerTable.FieldByName('BCForenames').AsString;
      FSurname      := BoxCustomerTable.FieldByName('BCSurname').AsString;
      FBusinessName := BoxCustomerTable.FieldByName('BCBusinessName').AsString;
      FCustomerType := BoxCustomerTable.FieldByName('BCType').AsString;
      FAddressLines := BoxCustomerTable.FieldByName('BCAddress').AsString;
      FState        := BoxCustomerTable.FieldByName('BCState').AsInteger;
      FTelephone    := BoxCustomerTable.FieldByName('BCAddress').AsString;
    end
    else
    begin
      RaiseError($1640, ET_ErrorLoadingComponent, EP_Warning,'Office ' + IntToStr(Value) + ' not found.');
    end;
  except
    On E : Exception do
    begin
      RaiseException($1640, E);
    end;
  end;
end;

function TPOBoxCustomer.Get_Forenames: WideString;
begin
  try
    Result := FForenames;
  except
    On E : Exception do
    begin
      RaiseException($1641, E);
      Result := '';
    end;
  end;
end;

procedure TPOBoxCustomer.Set_Forenames(const Value: WideString);
begin
  try
    If Value <> FForenames then
    begin
      If UpdateField('BCForenames',Value) then
        FForenames := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1642, E);
    end;
  end;
end;

function TPOBoxCustomer.Get_Office: IPOBoxOffice;
begin
  try
    Result := FOffice;
  except
    On E : Exception do
    begin
      RaiseException($1643, E);
      Result := nil;
    end;
  end;
end;

function TPOBoxCustomer.UpdateField(FieldName : String; Value : Variant) : Boolean;
begin
  try
    Result := False;
    If BoxCustomerTable.Locate('BCIdentifier',FIdentifier, []) then
    begin
      BoxCustomerTable.Edit;
      BoxCustomerTable.FieldValues[FieldName] := Value;
      BoxCustomerTable.Post;
      Result := True;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1644, E);
      Result := False;
    end;
  end;
end;

procedure TPOBoxCustomer.Set_Office(const Value: IPOBoxOffice);
begin
  try
    If FOffice <> Value then
    begin
      FOffice := nil;
      FOffice := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1645, E);
    end;
  end;
end;

function TPOBoxCustomer.Get_Details: WideString;
var
  CustomerList : TStringList;
  FieldIndex : Integer;
begin
  try
    CustomerList := TStringList.Create;
    Result := '';
    try
      If BoxCustomerTable.Locate('BCOffice; BCIdentifier',
                                  VarArrayOf([Get_Office.Number,Get_Identifier]), []) then
      begin
        For FieldIndex := 0 to BoxCustomerTable.FieldCount -1 do
        begin
          CustomerList.Add(VarToStr(BoxCustomerTable.Fields[FieldIndex].AsVariant));
        end;
      end;
      Result := CustomerList.CommaText;
    finally
      CustomerList.Free;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1646, E);
      Result := '';
    end;
  end;
end;

function TPOBoxCustomer.Get_Visible: WordBool;
begin
  try
    If (FCustomerForm = nil) or (FCustomerForm.Visible = False) then
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

procedure TPOBoxCustomer.Set_Visible(Value: WordBool);
begin
  try
    If Value <> Get_Visible then
    begin
      If FCustomerForm = nil then
      begin
        FCustomerForm := TPOBoxCustomerForm.Create(Application) ;
        FCustomerForm.Customer := self;
      end;
      FCustomerForm.Visible := Value;
    end;
    If Value = True then
    begin
      FCustomerForm.UpdateFormDetails(self);
      FCustomerForm.BringToFront;
    end;

  except
    On E : Exception do
    begin
      RaiseException($1643,E);
    end;
  end;
end;

function TPOBoxCustomer.Get_State: Integer;
begin
  Result := FState;
end;

procedure TPOBoxCustomer.Set_State(Value: Integer);
begin
  try
    If FState <> Value then
    begin
      If UpdateField('BCState',Value) then
        FState := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1644, E);
    end;
  end;
end;

function TPOBoxCustomer.Delete: WordBool;
begin
  try
    Result := False;
    (self As IPOBoxCustomer).State := (self As IPOBoxCustomer).State or csDeleted;
    Result := True;
  except
    On E : Exception do
    begin
      RaiseException($1645, E);
      Result := False;
    end;
  end;
end;

function TPOBoxCustomer.Get_Surname: WideString;
begin
  try
    Result := FSurname;
  except
    On E : Exception do
    begin
      RaiseException($1646, E);
      Result := '';
    end;
  end;
end;

procedure TPOBoxCustomer.Set_Surname(const Value: WideString);
begin
  try
    If Value <> FSurname then
    begin
      If UpdateField('BCSurname',Value) then
        FSurname := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1647, E);
    end;
  end;
end;

function TPOBoxCustomer.Get_Delegates: WideString;
begin
  try
    Result := FDelegates;
  except
    On E : Exception do
    begin
      RaiseException($1648, E);
      Result := '';
    end;
  end;
end;

function TPOBoxCustomer.Get_Fax: WideString;
begin
  try
    Result := FFax;
  except
    On E : Exception do
    begin
      RaiseException($1649, E);
      Result := '';
    end;
  end;
end;

function TPOBoxCustomer.Get_Id: WideString;
begin
  try
    Result := FId;
  except
    On E : Exception do
    begin
      RaiseException($164A, E);
      Result := '';
    end;
  end;
end;

function TPOBoxCustomer.Get_IdType: WideString;
begin
  try
    Result := FIdType;
  except
    On E : Exception do
    begin
      RaiseException($164B, E);
      Result := '';
    end;
  end;
end;

function TPOBoxCustomer.Get_Telephone: WideString;
begin
  try
    Result := FTelephone;
  except
    On E : Exception do
    begin
      RaiseException($164C, E);
      Result := '';
    end;
  end;
end;

function TPOBoxCustomer.Get_ZipCode: WideString;
begin
  try
    Result := FZipCode;
  except
    On E : Exception do
    begin
      RaiseException($164D, E);
      Result := '';
    end;
  end;
end;

procedure TPOBoxCustomer.Set_Delegates(const Value: WideString);
begin
  try
    If Value <> FDelegates then
    begin
      If UpdateField('BCDelegates',Value) then
        FDelegates := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($164E, E);
    end;
  end;
end;

procedure TPOBoxCustomer.Set_Fax(const Value: WideString);
begin
  try
    If Value <> FFax then
    begin
      If UpdateField('BCFax',Value) then
        FFax := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($164F, E);
    end;
  end;
end;

procedure TPOBoxCustomer.Set_Id(const Value: WideString);
begin
  try
    If Value <> FId then
    begin
      If UpdateField('BCId',Value) then
        FId := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1650, E);
    end;
  end;
end;

procedure TPOBoxCustomer.Set_IdType(const Value: WideString);
begin
  try
    If Value <> FIdType then
    begin
      If UpdateField('BCIdType',Value) then
        FIdType := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1651, E);
    end;
  end;
end;

procedure TPOBoxCustomer.Set_Telephone(const Value: WideString);
begin
  try
    If Value <> FTelephone then
    begin
      If UpdateField('BCTelephone',Value) then
        FTelephone := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1652, E);
    end;
  end;
end;

procedure TPOBoxCustomer.Set_ZipCode(const Value: WideString);
begin
  try
    If Value <> FZipCode then
    begin
      If UpdateField('BCZipCode',Value) then
        FZipCode := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1653, E);
    end;
  end;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TPOBoxCustomer, Class_POBoxCustomer, ciInternal);
end.
