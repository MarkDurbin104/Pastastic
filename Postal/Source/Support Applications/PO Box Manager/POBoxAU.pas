unit POBoxAU;

interface

uses
  Forms,
  POBoxF,
  GPCSErrorLine,
  Dialogs,
  DBTables,
  ComObj, SysUtils, ActiveX, POBoxManager_TLB;

type
  TPOBox = class(TAutoObject, IPOBox)
  private
    FPOBoxForm      : TPOBoxForm;
    FBlockNumber  : Integer;
    FDepositHeld  : Currency;
    FDepth        : Integer;
    FFeatures     : WideString;
    FHeight       : Integer;
    FKeysIssued   : Integer;
    FLockNumber   : Integer;
    FNumber       : Integer;
    FOffice       : IPOBoxOffice;
    FOwner        : IPOBoxCustomer;
    FRenewalDate  : TDateTime;
    FState        : Integer;
    FStyle        : Integer;
    FWidth        : Integer;
    FXCoord       : Integer;
    FYCoord       : Integer;

    BoxTable      : TTable;
    BoxStyleTable : TTable;

    function UpdateField(FieldName : String; Value : VAriant) : Boolean;
    function NullToZero(Value : Variant) : Variant;

  protected
    procedure Initialize; override;
    destructor Destroy; override;

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
    function Get_State: Integer; safecall;
    procedure Set_State(Value: Integer); safecall;
    function Get_Style: Integer; safecall;
    procedure Set_Style(Value: Integer); safecall;
    function Get_Width: Integer; safecall;
    function Get_XCoord: Integer; safecall;
    procedure Set_XCoord(Value: Integer); safecall;
    function Get_YCoord: Integer; safecall;
    procedure Set_YCoord(Value: Integer); safecall;
    function Get_Owner: IPOBoxCustomer; safecall;
    procedure Set_Owner(const Value: IPOBoxCustomer); safecall;
    function Get_RenewalDate: TDateTime; safecall;
    procedure Set_RenewalDate(Value: TDateTime); safecall;
    function Delete : WordBool; safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
  end;

implementation

uses POBoxManagerF,ComServ2;

function TPOBox.Get_BlockNumber: Integer;
begin
  try
    Result := FBlockNumber;
  except
    On E : Exception do
    begin
      RaiseException($1615, E);
      Result := 0;
    end;
  end;
end;

procedure TPOBox.Set_BlockNumber(Value: Integer);
begin
  try
    If Value <> FBlockNumber then
    begin
      If UpdateField('BOBlockNumber',Value) then
        FBlockNumber := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1616, E);
    end;
  end;
end;

function TPOBox.Get_DepositHeld: Currency;
begin
  try
    Result := FDepositHeld;
  except
    On E : Exception do
    begin
      RaiseException($1617, E);
      Result := 0;
    end;
  end;
end;

procedure TPOBox.Set_DepositHeld(Value: Currency);
begin
  try
    If Value <> FDepositHeld then
    begin
      If UpdateField('BODepositHeld',Value) then
        FDepositHeld := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1618, E);
    end;
  end;
end;

function TPOBox.Get_Depth: Integer;
begin
  try
    Result := FDepth;
  except
    On E : Exception do
    begin
      RaiseException($1619, E);
      Result := 0;
    end;
  end;
end;

function TPOBox.Get_Features: WideString;
begin
  try
    Result := FFeatures
  except
    On E : Exception do
    begin
      RaiseException($161A, E);
      Result := '';
    end;
  end;
end;

procedure TPOBox.Set_Features(const Value: WideString);
begin
  try
    If Value <> FFeatures then
    begin
      If UpdateField('BOFeatures',Value) then
        FFeatures := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($161B, E);
    end;
  end;
end;

function TPOBox.Get_Height: Integer;
begin
  try
    Result := FHeight;
  except
    On E : Exception do
    begin
      RaiseException($161C, E);
      Result := 0;
    end;
  end;
end;

function TPOBox.Get_KeysIssued: Integer;
begin
  try
    Result := FKeysIssued;
  except
    On E : Exception do
    begin
      RaiseException($161D, E);
      Result := 0;
    end;
  end;
end;

procedure TPOBox.Set_KeysIssued(Value: Integer);
begin
  try
    If Value <> FKeysIssued then
    begin
      If UpdateField('BOKeysIssued',Value) then
        FKeysIssued := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($161E, E);
    end;
  end;
end;

function TPOBox.Get_LockNumber: Integer;
begin
  try
    Result := FLockNumber;
  except
    On E : Exception do
    begin
      RaiseException($161F, E);
      Result := 0;
    end;
  end;
end;

procedure TPOBox.Set_LockNumber(Value: Integer);
begin
  try
    If Value <> FLockNumber then
    begin
      If UpdateField('BOLockNumber',Value) then
        FLockNumber := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1620, E);
    end;
  end;
end;

function TPOBox.Get_Number: Integer;
begin
  try
    Result := FNumber;
  except
    On E : Exception do
    begin
      RaiseException($1621, E);
      Result := 0;
    end;
  end;
end;

procedure TPOBox.Set_Number(Value: Integer);
begin
  try
    If BoxTable.Locate('BOOffice;BONumber',VarArrayOf([FOffice.Number,Value]), []) then
    begin
      FBlockNumber  :=  NullToZero(BoxTable.FieldValues['BOBlockNumber']);
      FDepositHeld  :=  NullToZero(BoxTable.FieldValues['BODepositHeld']);
      FFeatures     :=  VarToStr(BoxTable.FieldValues['BOFeatures']);
      FKeysIssued   :=  NullToZero(BoxTable.FieldValues['BOKeysIssued']);
      FLockNumber   :=  NullToZero(BoxTable.FieldValues['BOLockNumber']);
      FNumber       :=  Value;
      FOwner        :=  FOffice.Customers[NullToZero(BoxTable.FieldValues['BOOwner'])];
      FRenewalDate  :=  NullToZero(BoxTable.FieldValues['BORenewalDate']);
      FState        :=  NullToZero(BoxTable.FieldValues['BOState']);
      FStyle        :=  NullToZero(BoxTable.FieldValues['BOStyle']);
      FXCoord       :=  NullToZero(BoxTable.FieldValues['BOXCoord']);
      FYCoord       :=  NullToZero(BoxTable.FieldValues['BOYCoord']);
      If BoxStyleTable.Locate('BSNumber',FStyle,[]) then
      begin
        FDepth        := NullToZero(BoxStyleTable.FieldValues['BSDepth']);
        FHeight       := NullToZero(BoxStyleTable.FieldValues['BSHeight']);
        FWidth        := NullToZero(BoxStyleTable.FieldValues['BSWidth']);
      end;
    end
    else
    begin
      FNumber := 0;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1622, E);
    end;
  end;
end;

function TPOBox.Get_Office: IPOBoxOffice;
begin
  try
    Result := FOffice;
  except
    On E : Exception do
    begin
      RaiseException($1623, E);
      Result := nil;
    end;
  end;
end;

procedure TPOBox.Set_Office(const Value: IPOBoxOffice);
begin
  try
    If Value <> FOffice then
    begin
      FOffice := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1624, E);
    end;
  end;
end;

function TPOBox.Get_Owner: IPOBoxCustomer;
begin
  try
    Result := FOwner;
  except
    On E : Exception do
    begin
      RaiseException($1625, E);
      Result := nil;
    end;
  end;
end;

procedure TPOBox.Set_Owner(const Value: IPOBoxCustomer);
begin
  try
    If Value <> FOwner then
    begin
      If UpdateField('BOOwner',Value.Identifier) then
        FOwner := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1626, E);
    end;
  end;
end;

function TPOBox.Get_RenewalDate: TDateTime;
begin
  try
    Result := FRenewalDate;
  except
    On E : Exception do
    begin
      RaiseException($1627, E);
      Result := 0;
    end;
  end;
end;

procedure TPOBox.Set_RenewalDate(Value: TDateTime);
begin
  try
    If Value <> FRenewalDate then
    begin
      If UpdateField('BORenewalDate',Value) then
        FRenewalDate := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1628, E);
    end;
  end;
end;

function TPOBox.Get_State: Integer;
begin
  try
    Result := FState;
  except
    On E : Exception do
    begin
      RaiseException($1629, E);
      Result := 0;
    end;
  end;
end;

procedure TPOBox.Set_State(Value: Integer);
begin
  try
    If Value <> FState then
    begin
      If UpdateField('BOState',Value) then
        FState := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($162A, E);
    end;
  end;
end;

function TPOBox.Get_Style: Integer;
begin
  try
    Result := FStyle;
  except
    On E : Exception do
    begin
      RaiseException($162B, E);
      Result := 0;
    end;
  end;
end;

procedure TPOBox.Set_Style(Value: Integer);
begin
  try
    If Value <> FStyle then
    begin
      If UpdateField('BOStyle',Value) then
      begin
        FStyle := Value;
        If BoxStyleTable.Locate('BSNumber',FStyle, []) then
        begin
          FWidth := NullToZero(BoxStyleTable.FieldValues['BSWidth']);
          FDepth := NullToZero(BoxStyleTable.FieldValues['BSDepth']);
          FHeight := NullToZero(BoxStyleTable.FieldValues['BSHeight']);
        end;
      end;
    end;
  except
    On E : Exception do
    begin
      RaiseException($162C, E);
    end;
  end;
end;

function TPOBox.Get_Width: Integer;
begin
  try
    Result := FWidth;
  except
    On E : Exception do
    begin
      RaiseException($162D, E);
      Result := 0;
    end;
  end;
end;

function TPOBox.Get_XCoord: Integer;
begin
  try
    Result := FXCoord;
  except
    On E : Exception do
    begin
      RaiseException($162E, E);
      Result := 0;
    end;
  end;
end;

procedure TPOBox.Set_XCoord(Value: Integer);
begin
  try
    If Value <> FXCoord then
    begin
      If UpdateField('BOXCoord',Value) then
        FXCoord := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($162F, E);
    end;
  end;
end;

function TPOBox.Get_YCoord: Integer;
begin
  try
    Result := FYCoord;
  except
    On E : Exception do
    begin
      RaiseException($1630, E);
      Result := 0;
    end;
  end;
end;

procedure TPOBox.Set_YCoord(Value: Integer);
begin
  try
    If Value <> FYCoord then
    begin
      If UpdateField('BOYCoord',Value) then
        FYCoord := Value;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1631, E);
    end;
  end;
end;

procedure TPOBox.Initialize;
begin
  try
    Inherited Initialize;
    _AddRef;

    BoxTable := TTable.Create(nil);
    BoxTable.DatabaseName := 'PSLPOBox';
    BoxTable.TableName := 'Box.db';
    BoxTable.Open;

    BoxStyleTable := TTable.Create(nil);
    BoxStyleTable.DatabaseName := 'PSLPOBox';
    BoxStyleTable.TableName := 'BoxStyle.db';
    BoxStyleTable.Open;
  except
    On E : Exception do
    begin
      RaiseException($1632, E);
    end;
  end;
end;

destructor TPOBox.Destroy;
begin
  try
    BoxTable.Close;
    BoxTable.Free;
    BoxStyleTable.Close;
    BoxStyleTable.Free;
    Inherited Destroy;
  except
    On E : Exception do
    begin
      RaiseException($1633, E);
      Inherited Destroy;
    end;
  end;
end;

function TPOBox.UpdateField(FieldName : String; Value : Variant) : Boolean;
begin
  try
    Result := False;
    If BoxTable.Locate('BOOffice;BONumber',VarArrayOf([FOffice.Number,FNumber]), []) then
    begin
      BoxTable.Edit;
      BoxTable.FieldValues[FieldName] := Value;
      BoxTable.Post;
      Result := True;
    end;
  except
    On E : Exception do
    begin
      RaiseException($1634, E);
      Result := False;
    end;
  end;
end;

function TPOBox.NullToZero(Value : Variant) : Variant;
begin
  try
    If VarIsNull(Value) then
      Result := 0
    else
      Result := Value;
  except
    On E : Exception do
    begin
      RaiseException($1635, E);
      Result := null;
    end;
  end;

end;

function TPOBox.Delete: WordBool;
begin
  try
    Result := False;
    (self As IPOBox).State := (self As IPOBox).State or bsDeleted;
    Result := True;
  except
    On E : Exception do
    begin
      RaiseException($1636, E);
      Result := False;
    end;
  end;
end;


function TPOBox.Get_Visible: WordBool;
begin
  try
    If (FPOBoxForm = nil) or (FPOBoxForm.Visible = False) then
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
      RaiseException($1637,E);
      Result := False;
    end;
  end;
end;

procedure TPOBox.Set_Visible(Value: WordBool);
begin
  try
    If Value <> Get_Visible then
    begin
      If FPOBoxForm = nil then
      begin
        FPOBoxForm := TPOBoxForm.Create(Application) ;
        FPOBoxForm.POBox := self;
      end;
      FPOBoxForm.Visible := Value;
    end;
    If Value = True then
    begin
      FPOBoxForm.UpdateFormDetails(FPOBoxForm.POBox);
      FPOBoxForm.BringToFront;
    end;

  except
    On E : Exception do
    begin
      RaiseException($1638,E);
    end;
  end;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TPOBox, Class_POBox, ciMultiInstance);
end.
