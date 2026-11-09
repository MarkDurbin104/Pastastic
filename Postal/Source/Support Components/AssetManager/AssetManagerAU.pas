unit AssetManagerAU;

interface

uses
  AssetManagerDM,
  AssetModelF,
  AssetOwnerU,
  AssetEntryU,
  Dialogs,
  GPCSBase_TLB,
  GPCSErrorLine,
  Classes,
  DBTables,
  SysUtils,
  ComObj, ActiveX, AssetManager_TLB;

type
  TAssetManager = class(TAutoObject, IAssetManager)
  private
    //database
    CurrentSession : TSession;

    //collections
    Assets  : TStringList;
    Models  : TStringList;
    Owners  : TStringList;
    Sites   : TStringList;
    Triggers: TStringList;

    FAlias : WideString;
    FSite : WideString;
    FWorkstation : WideString;
    FPerson : IAssetOwner;
    FPeriod : Integer;

    procedure UpdateFormCaption;
//    function LogSingleGroup(const AssetGroup: WideString; Quantity: Integer;
//      Value: Currency): amStatus;


//    procedure GetAssetGroupChildren(AssetGroup : String;
//                                                      var ChildrenStringList : TStringList);
    //returns child group names and multiplier commatext

//    procedure GetAssetGroupParents(AssetGroup : String;
//                                                    var ParentsStringList : TStringList);

//    function LogAssetRecurse(const AssetGroup: WideString;
//          Quantity: Integer; Value: Currency): AMStatus;
        //logs group and all parents in hierarchy recursively

  protected
    function Get_InterfaceVersion: Integer; safecall;
    function Get_Version: Integer; safecall;
    function Design(const Password: WideString): WideString; safecall;
    procedure TerminateDesign; safecall;

    destructor Destroy; Override;
    function Get_Person: IAssetOwner; safecall;
    function Get_Site: WideString; safecall;
    function Get_Workstation: WideString; safecall;
    function AddAssetEntry(const Asset: WideString;
      const Quantity: IAssetQuantity): AMStatus; safecall;

    function Reset: AMStatus; safecall;
    procedure Set_Person(const Value: IAssetOwner); safecall;
    procedure Set_Site(const Value: WideString); safecall;
    procedure Set_Workstation(const Value: WideString); safecall;
    function Get_Period: Integer; safecall;
    procedure Set_Period(Value: Integer); safecall;
    function Get_Alias: WideString; safecall;
    procedure Set_Alias(const Value: WideString); safecall;

    procedure Initialize; override;
    function ReceiptCommaText: WideString; safecall;
    function QueryToCommaText(const SQLQueryText: WideString): WideString; safecall;
    function AssetTotalCommaText(const ParentGroup: WideString): WideString;
      safecall;
    function AssetParentHierarchy(const Asset: IAsset): WideString; safecall;
    function AssetParents(const Asset: WideString): WideString; safecall;
    function AssetChildren(const AccountGroup: WideString): WideString;
      safecall;
    function IsAParent(const ParentCandidate: WideString): WordBool; safecall;
    function TransferStock(const SourceStockUnit, DestStockUnit,
      StockCommaTExt: WideString): AMStatus; safecall;
    function AdjustSingleAsset(const Asset: IAsset;
      const Quantity: IAssetQuantity): AMStatus; safecall;
    function AssetByCode(const Code: WideString): IAsset; safecall;
      safecall;
    function Get_AssetModels(const ModelName: WideString): IAssetModel;
      safecall;
    function Get_Asset(const AssetCode: WideString): IAsset; safecall;
    function Get_Owners(const OwnerName: WideString): IAssetOwner; safecall;
    function CreateAssetQuantity(Amount: Currency;
      const UnitsName: WideString): IAssetQuantity; safecall;
    function Get_Trigger(const Code: WideString): IAssetTrigger;
      safecall;


  public
    function CloseModel(const ModelFileName: WideString): AMStatus; safecall;
    function OpenModel(const ModelFileName: WideString): AMStatus; safecall;
    property AssetModels[const ModelName : WideString] : IAssetModel read Get_AssetModels;
  end;

implementation
uses
	AssetModelsPaletteF,
  AssetModelsF,
  AssetTriggerAU, AssetQuantityU, AssetU, MainF,ComServ2;

function TAssetManager.IsAParent(const ParentCandidate: WideString): WordBool;
begin
  Result := False;
end;

destructor TAssetManager.Destroy;

  procedure FreeCollection(Collection : TStringList);
  var
    CollectionIndex : Integer;
  begin
    For CollectionIndex := 0 to Collection.Count -1 do
      (Collection.Objects[CollectionIndex] as TObject).Free;
  end;

begin
  try
    try
      //close database session
      CurrentSession.Close;

      //free collections
      FreeCollection(Models);
      FreeCollection(Assets);
      FreeCollection(Owners);
      FreeCollection(Sites);
      FreeCollection(Triggers);

      //kill person
      FPerson := nil;

    except
      On E : Exception do
      begin
        RaiseException($201,E);
      end;
    end;
  finally
    Inherited Destroy;
  end;
end;

function TAssetManager.AddAssetEntry(const Asset: WideString;
  const Quantity: IAssetQuantity): AMStatus;
var
  ModelIndex : Integer;
  NewAssetEntry : IAssetEntry;
begin
  try
    NewAssetEntry := TAssetEntry.Create;
    NewAssetEntry.Code            := Asset;
    NewAssetEntry.Person          := (self As IAssetManager).Person;
    NewAssetEntry.Creator         := (self As IAssetManager).Person;
    NewAssetEntry.AssetQuantity   := Quantity;
    NewAssetEntry.Site            := FSite;
    NewAssetEntry.Workstation     := FWorkstation;

    For ModelIndex := 0 to Models.Count -1 do
    begin
      Result := (Models.Objects[ModelIndex] As TAssetModel).LogAssetEntry(NewAssetEntry);
    end;

  except
    On E : Exception do
    begin
      Result := amUnexpected;
      RaiseException($201,E);
    end;
  end;

end;

{
function TAssetManager.LogGroupRecurse(const AssetGroup: WideString;
  Quantity: Integer; Value: Currency): AMStatus;
//logs group and all parents in hierarchy recursively
var
  OrigPerson : String;
  ImmediateParents : TStringList;
  ValueMultiplier : Double;
  QuantityMultiplier : Integer;
  ParentStringList : TStringList;
  ParentIndex : Integer;
begin
  try
    Result := amSuccess;
    If AssetGroup <> '' then
    begin
      ImmediateParents := TStringList.Create;
      ParentStringList := TStringList.Create;
      try
        //record actual group
        Result := LogSingleGroup(AssetGroup,Quantity,Value);
        If amSuccess = Result then
        begin

          //get and check immediate parents
          GetAssetGroupParents(AssetGroup,ImmediateParents);
          ParentIndex := 0;
          While (ParentIndex <= (ImmediateParents.Count - 1))
          and (Result = amSuccess) do
          begin
            ParentStringList.CommaText := ImmediateParents[ParentIndex];
            If ParentStringList[0] = AssetGroup then  //check for immediate circular
              Result := amCircular
            else
            begin
              //log parent
              ValueMultiplier := StrToFloat(ParentStringList[1]);
              If ValueMultiplier > 0 then QuantityMultiplier := 1
              else If ValueMultiPlier < 0 then QuantityMultiplier := -1
              else QuantityMultiplier := 0;

              Result := LogGroup(ParentStringList[0],
                                  Integer(Quantity)*QuantityMultiplier, //* multiplier
                                  Value*ValueMultiplier);
            end;
            Inc(ParentIndex);
          end;  //while
        end;  //if Logged actual group

        //log cash Asset
        OrigPerson := FPerson;  //save person
        If ((AssetGroup >= '100001') and (AssetGroup <= '100028')) //receipt
        or ((AssetGroup >= '100041') and (AssetGroup <= '100050'))//payment
         begin
          FPerson := 'ALL'; //maintain ALL user
          Result := LogGroupRecurse(AssetGroup,Quantity,Value);
        end;
        FPerson := OrigPerson;

      finally
        ImmediateParents.Free;
        ParentStringList.Free;
      end;
    end;  //if Assetgroup <>''
  except
    On E : Exception do
    begin
      RaiseException($201,E);
      Result := amUnexpected;
    end;
  end;
end;
}


function TAssetManager.AdjustSingleAsset(const Asset: IAsset;
  const Quantity: IAssetQuantity): AMStatus;

begin
{
  try
    Result := LogSingleGroup(Asset, Quantity, Value);

  except
    On E : Exception do
    begin
      RaiseException($201,E);
      Result := amUnexpected;
    end;
  end;
  Result := amUnexpected;
}
end;


function TAssetManager.Get_Person: IAssetOwner;
begin
  Result := FPerson;
end;

function TAssetManager.Get_Site: WideString;
begin
  Result := FSite;
end;

function TAssetManager.Get_Workstation: WideString;
begin
  Result := FWorkstation;
end;

procedure TAssetManager.Initialize;
begin
  try
    Inherited Initialize;
    _AddRef;  //bug with interface reference counting when used as internal object
    FAlias := 'PSLAsset'; //default
    CurrentSession := Sessions.OpenSession('Session' + DateTimeToStr(Now));

    FPerson := TAssetOwner.Create As IAssetOwner;

{    //start tables
    GroupTotalTable := TTable.Create(nil);
    GroupTable := TTable.Create(nil);
    With GroupTotalTable do
    begin
      DatabaseName := 'PSLAsset';
      TableName := 'AssetGroupTotal';
      Active := True;
    end;
    With GroupTable do
    begin
      DatabaseName := 'PSLAsset';
      TableName := 'AssetGroup';
      Active := True;
    end;
}

    //init collections
    Models   := TStringList.Create;
    Assets   := TStringList.Create;
    Models   := TStringList.Create;
    Owners   := TStringList.Create;
    Sites    := TStringList.Create;
    Triggers := TStringList.Create;

  except
    On E : Exception do
    begin
      RaiseGUIDException('{8989ADCD-5826-4234-844A-DA657EAB8E00}',E);
      If CurrentSession <> nil
        then CurrentSession.Close;
      Free;
    end;
  end;

end;

function TAssetManager.Reset: AMStatus;
var
  ResetQuery : TQuery;
  GroupTotalTable : TTable;
begin
  Result := amUnexpected;
  try
    ResetQuery := TQuery.Create(nil);
    GroupTotalTable := TTable.Create(nil);
    try
      ResetQuery.DatabaseName := FAlias;
      GroupTotalTable.DatabaseName := FAlias;
      GroupTotalTable.TableName := 'AssetGroupTotal';
      GroupTotalTable.Active := True;

      //delete
      ResetQuery.SQL.Text :=
      ' delete from AssetGroupTotal '
    + ' where '
    + ' AGTSite = "' + FSite + '"'
    + ' and AGTPerson = "' + FPerson.Name + '"'
    + ' and AGTPeriod = "' + IntToStr(FPeriod) + '"' ;
     ;
      ResetQuery.ExecSQL;

      //insert zeroed records
      ResetQuery.Close;
      ResetQuery.SQL.Text :=
      ' select ADAsset from AssetDescription';
      ResetQuery.Open;
      While not ResetQuery.EOF do
      begin
        GroupTotalTable.InsertRecord(
          [FSite,FWorkStation,FPerson,FPeriod,
          ResetQuery.FieldByName('ADAsset').AsString,
          0,0]);
        ResetQuery.Next;
      end;
      Result := amSuccess;
    finally
      GroupTotalTable.Close;
      GroupTotalTable.Free;
      ResetQuery.Close;
      ResetQuery.Free;
    end;
  except
    On E : Exception do
    begin
      RaiseGUIDException('{78A7DD32-14C9-4CEC-96ED-22A0A86378C4}',E);
      Result := amUnexpected;
    end;
  end;
end;

procedure TAssetManager.Set_Person(const Value: IAssetOwner);
begin
  If FPerson <> Value then
  begin
    FPerson := Value;
    UpdateFormCaption;
  end;
end;

procedure TAssetManager.Set_Site(const Value: WideString);
begin
  If FSite <> Value then
  begin
    FSite := Value;
    UpdateFormCaption;
  end;
end;

procedure TAssetManager.Set_Workstation(const Value: WideString);
begin
  If FWorkstation <> Value then
  begin
    FWorkstation := Value;
    UpdateFormCaption;
  end;
end;

function TAssetManager.Get_Period: Integer;
begin
  Result := FPeriod;
end;

procedure TAssetManager.Set_Period(Value: Integer);
begin
  If FPeriod <> Value then
  begin
    FPeriod := Value;
    UpdateFormCaption;
  end;
end;

function TAssetManager.Get_Alias: WideString;
begin
  Result := FAlias;
end;

procedure TAssetManager.Set_Alias(const Value: WideString);
begin
  If FAlias <> Value then
    FAlias := Value;
end;


function TAssetManager.QueryToCommaText(
  const SQLQueryText: WideString): WideString;
var
  FieldIndex        : Integer;
  FieldStringList   : TStringList;
  RecordStringList  : TStringList;
  ResultQuery       : TQuery;
begin
  try
    Result := '';
    //build query result stringlists
    FieldStringList   := TStringList.Create;
    RecordStringList  := TStringList.Create;
    With RecordStringList do
    begin
      try
        ResultQuery := TQuery.Create(nil);
        With ResultQuery do
        begin
          try
            Close;
            DatabaseName := FAlias;
            SQL.Text := SQLQueryText;
            Open;
            First;
            While not EOF do
            begin
              For FieldIndex := 0 to FieldCount - 1 do
              begin
                FieldStringList.Add(Fields[FieldIndex].AsString);
              end;
              RecordStringList.Add(FieldStringList.CommaText);
              FieldStringList.Clear;
              Next;
            end;
            Close;
            Result := RecordStringList.CommaText;
          finally
            ResultQuery.Close;
            ResultQuery.Free;
          end;
        end;
      finally
        FieldStringList.Free;
        RecordStringList.Free;
      end;
    end;  //with stringlist
  except
    On E : Exception do
    begin
      RaiseGUIDException('{63DA6973-CFCF-4474-87B2-68C1D21539BA}',E);
      Result := '';
    end;
  end;

end;

{
function TAssetManager.LogSingleGroup(const AssetGroup: WideString; Quantity: Integer;
  Value: Currency): amStatus;
begin
  try
    With GroupTotalTable do
    begin
      If Locate('AGTSite;AGTWorkstation;AGTPerson;AGTPeriod;AGTIdentifier',
                                      VarArrayOf([FSite,FWorkstation,FPerson,FPeriod,String(AssetGroup)]),
                                      []) then
      begin
        Edit;
        FieldByName('AGTQuantity').AsInteger := FieldByName('AGTQuantity').AsInteger + Quantity;
        FieldByName('AGTValue').AsCurrency := FieldByName('AGTValue').AsCurrency + Value;
        Post;
      end
      else
      begin
        GroupTotalTable.InsertRecord([FSite,FWorkstation,FPerson,FPeriod,String(AssetGroup),Quantity,Value]);
      end;
    end;
    AssetManagerForm.AssetGroupTotalDBGrid.Refresh;
    Result := amSuccess;
  except
    On E : Exception do
    begin
      RaiseException($201,E);
      Result := amUnexpected;
    end;
  end;
end;
}

function TAssetManager.AssetTotalCommaText(
  const ParentGroup: WideString): WideString;
//var
//  SQLQueryText : WideString;
//  OrigAlias : String;
begin
{  try
    //NB user SUM flag and unions
    If IsAGroup(ParentGroup) then //has Asset children
    begin
      SQLQueryText :=
        ' select AGTIdentifier, ADDescription, AGTQuantity, AGTValue' //+ ADDisplayOrder, SUm(Quantity), Sum(Value)
      + ' from AssetDescription, AssetGroup, AssetGroupTotal'
      + ' where'
      + ' AGIdentifier = ADAsset'
      + ' and AGTIdentifier = ADAsset'
      + ' and AGParent = ''' + ParentGroup + ''''
      + ' and AGTSite = ''' + FSite + ''''
      + ' and AGTWorkstation = "' + FWorkstation + ''''
      + ' and AGTPerson = ''' + FPerson + ''''  //remove if FPerson = ALL
      + ' and AGTPeriod = ''' + IntToStr(FPeriod) + ''''
      //and where SumFlag = 'SUM'
      //group by all not summed (eg all but Q,V)
      + ''
{
        union
        ' select AGTIdentifier, ADDescription, AGTQuantity, AGTValue' //+ ADDisplayOrder,
      + ' from AssetDescription, AssetGroup, AssetGroupTotal'
      + ' where'
      + ' AGIdentifier = ADAsset'
      + ' and AGTIdentifier = ADAsset'
      + ' and AGParent = ''' + ParentGroup + ''''
      + ' and AGTSite = ''' + FSite + ''''
      + ' and AGTWorkstation = "' + FWorkstation + ''''
      + ' and AGTPerson = ''' + FPerson + ''''  //=Mrs MBaya
      + ' and AGTPeriod = ''' + IntToStr(FPeriod) + ''''
      //and where SumFlag <> 'SUM'                   -

      + ''
}
{
      + ' order by AGTIdentifier';  //ADDisplayOrder, AGTIdentifier
      Result := QueryToCommaText(SQLQueryText);
    end
    else  //single item
    begin
      SQLQueryText :=
        ' select PLU, Description, Sum(Quantity), Sum(TxnValue) from TxnLog '
      + ' where '
      + ' PLU = ''' + ParentGroup +'''' //txn PLU eg 90020 for stamp20
      + ' and Office = ' + FSite
      + ' and Type = ''TxnTotal'''  //txn total for the sale
      + ' and Teller = ''' + FPerson + ''''
      + ' and Position = ' + FWorkstation
      + ' group by  PLU, Description '
      + ' order by PLU';

      OrigAlias := FAlias;
      Set_Alias('PSL'); //PSL for TxnLog
      Result := self.QueryToCommaText(SQLQueryText);
      Set_Alias(OrigAlias);
    end;
  except
    On E : Exception do
    begin
      RaiseException($201,E);
      Result := '';
    end;
  end;
}
end;

function TAssetManager.ReceiptCommaText: WideString;
//not currently used
var
  SQLQueryText : WideString;
  OrigAlias : String;
begin
  try
    SQLQueryText :=
      ' select PLU, Description, Sum(Quantity), Sum(TxnValue) from TxnLog '
    + ' where '
    + ' Office = ' + FSite
    + ' and Type = ''TxnTotal'''
    + ' and Teller = ''' + FPerson.Name + ''''
    + ' and Position = ' + FWorkstation
    + ' group by  PLU, Description '
    + ' order by PLU';

    OrigAlias := FAlias;
    Set_Alias('PSL');
    Result := self.QueryToCommaText(SQLQueryText);
    Set_Alias(OrigAlias);
  except
    On E : Exception do
    begin
      RaiseException($201,E);
      Set_Alias(OrigAlias);
      Result := '';
    end;
  end;

end;


function TAssetManager.AssetParentHierarchy(
  const Asset: IAsset): WideString;
//var
//  ParentHierarchy : TStringList;
begin
{  try
    ParentHierarchy := TStringList.Create;
    try
      If amSuccess = AssetManagerForm.GetAssetGroupParentHierarchy(Asset.Code,ParentHierarchy) then
        Result := ParentHierarchy.CommaText
      else
        Result := 'Duplicate';
    finally
      ParentHierarchy.Free;
    end;
  except
    On E : Exception do
    begin
      RaiseException($201,E);
      Result := '';
    end;
  end;
}
end;

function TAssetManager.Get_InterfaceVersion: Integer;
begin
  Result := 2;
end;

function TAssetManager.Get_Version: Integer;
begin
  Result := 1;
end;

function TAssetManager.Design(const Password: WideString): WideString;
begin
  Result := '';
end;

procedure TAssetManager.TerminateDesign;
begin
end;

{procedure TAssetManager.GetAssetGroupParents(AssetGroup : String;
                                                    var ParentsStringList : TStringList);
//returns parent names and multiplier commatext
var
  ParentStringList  : TStringList; //name of parent
begin

  try
    ParentStringList := TStringList.Create;
    try
      With GroupTable do
      begin
        GroupTable.Filter :=   'AGIdentifier = ''' + AssetGroup + ''''
                  + ' and AGMultiplier <> 0';
        GroupTable.Filtered := True;
        First;
        While Not EOF do
        begin
          ParentStringList.Clear;
          ParentStringList.Add(FieldByName('AGParent').AsString);
          ParentStringList.Add(FieldByName('AGMultiplier').AsString);
          ParentsStringList.Add(ParentStringList.CommaText);
          Next;
        end;
        GroupTable.Filtered := False;
      end;
    finally
      ParentStringList.Free;
    end;

  except
    On E : Exception do
    begin
      RaiseException($201,E);
    end;
  end;
end;
}

{procedure TAssetManager.GetAssetGroupChildren(AssetGroup : String;
                                                    var ChildrenStringList : TStringList);
returns child group names and multiplier commatext
var
  ChildStringList  : TStringList; //name of parent
begin

  try
    ChildStringList := TStringList.Create;
    try
      With GroupTable do
      begin
        GroupTable.Filter :=   'AGParent = ''' + AssetGroup + '''';
        GroupTable.Filtered := True;
        First;
        While Not EOF do
        begin
          ChildStringList.Clear;
          ChildStringList.Add(FieldByName('AGIdentifier').AsString);
          ChildStringList.Add(FieldByName('AGMultiplier').AsString);
          ChildrenStringList.Add(ChildStringList.CommaText);
          Next;
        end;
        GroupTable.Filtered := False;
      end;
    finally
      ChildStringList.Free;
    end;

  except
    On E : Exception do
    begin
      RaiseException($201,E);
    end;
  end;

end;
}

function TAssetManager.AssetChildren(
  const AccountGroup: WideString): WideString;
//var
//  ChildrenStringList: TStringList;
begin
{
  try
    ChildrenStringList := TStringList.Create;
    try
      self.GetAssetGroupChildren(AssetGroup, ChildrenStringList);
      Result := ChildrenStringList.CommaTExt;
    finally
      ChildrenStringList.Free;
    end;
  except
    On E : Exception do
    begin
      RaiseException($201,E);
      Result := '';
    end;
  end;
}
end;

function TAssetManager.AssetParents(const Asset: WideString): WideString;
//var
//  ParentsStringList: TStringList;
begin
{
  try
    ParentsStringList := TStringList.Create;
    try
      self.GetAssetGroupParents(AssetGroup, ParentsStringList);
      Result := ParentsStringList.CommaTExt;
    finally
      ParentsStringList.Free;
    end;
  except
    On E : Exception do
    begin
      RaiseException($201,E);
      Result := '';
    end;
  end;
}
end;



function TAssetManager.TransferStock(const SourceStockUnit,
  DestStockUnit, StockCommaTExt: WideString): AMStatus;
//var
//  StockStringList : TStringList;
//  StockItemStringList : TStringList;
//  StockItemIndex : Integer;
begin
{
  try
    StockStringList := TStringList.Create;
    StockItemStringList := TStringList.Create;
    try
      Result := amSuccess;
      With GroupTotalTable.Database do
      begin
        TransIsolation := tiDirtyRead;
        If not InTransaction then
          StartTransaction;

        //iterate through stock items
        StockStringList.CommaText := StockCommaText;
        StockItemIndex := 0;
        While(StockItemIndex <= StockStringList.Count -1)
              and (Result  = amSuccess) do
        begin
          StockItemStringList.CommaText := StockStringList[StockItemIndex];

          //reduce source stock
          FPerson := SourceStockUnit;
          Result := LogGroupRecurse(StockItemStringList[0],
                                    -StrToInt(StockItemStringList[1]),
                                    -StrToInt(StockItemStringList[2]));
          //increase destination stock
          FPerson := DestStockUnit;
          Result := LogGroupRecurse(StockItemStringList[0],
                                    StrToInt(StockItemStringList[1]),
                                    StrToInt(StockItemStringList[2]));
          Inc(StockItemIndex);
        end;
        If InTransaction then
          If Result = amSuccess then
            Commit
          else
            Rollback;
      end;  //with
    finally
      StockStringList.Free;
      StockItemStringList.Free;
    end;
  except
    On E : Exception do
    begin
      If GroupTotalTable.Database.InTransaction then
        GroupTotalTable.Database.RollBack;
      Result := amUnexpected;
      RaiseException($201,E);
    end;
  end;
}
end;

function TAssetManager.OpenModel(
  const ModelFileName: WideString): AMStatus;
var
	AssetModel : TAssetModel;
begin
  CloseModel(ModelFileName);

  AssetModel := TAssetModel.Create;
  With AssetModel do
  begin
		AssetModel.Form.Visible := True;
		LoadFromFile(ModelFilename);
		AssetModel.Form.Parent := AssetModelsForm;

  	Manager := self;
  	AssetModelsForm.ActiveModel := AssetModel;
  	Models.AddObject(ModelFileName, AssetModel);
    AssetModelsPaletteForm.AddModel(ModelFileName);
  end;
end;

function TAssetManager.AssetByCode(const Code: WideString): IAsset;
begin

end;

function TAssetManager.Get_AssetModels(
  const ModelName: WideString): IAssetModel;
var
  ModelIndex : Integer;
begin
  ModelIndex := Models.IndexOf(ModelName);
  If ModelIndex >= 0 then
    Result := Models.Objects[ModelIndex] As TAssetModel
  else
    Result := nil;
end;

procedure TAssetManager.UpdateFormCaption;
begin
  If MainForm <> nil then
    MainForm.Caption := 'Asset Manager'
                        + ' - Site: ' + FSite
                        + ' - Workstation: ' + FWorkstation
                        + ' - User: ' + FPerson.Name
                        + ' - Period: ' + IntToStr(FPeriod);
end;


function TAssetManager.Get_Asset(const AssetCode: WideString): IAsset;
var
  AssetIndex : Integer;
  NewAsset  : TAsset;
begin
  AssetIndex := Assets.IndexOf(AssetCode);
  If AssetIndex >= 0 then
  begin
    Result := Assets.Objects[AssetIndex] As TAsset;
  end
  else
  begin
    NewAsset := TAsset.Create;
    (NewAsset As IAsset).Code := AssetCode;
    Assets.AddObject(NewAsset.Code, NewAsset);
    Result := NewAsset;
  end;
end;

function TAssetManager.Get_Owners(const OwnerName: WideString): IAssetOwner;
var
  NewOwner   : TAssetOwner;
  OwnerIndex : Integer;
begin
  OwnerIndex := OWners.IndexOf(OwnerName);
  If OwnerIndex >= 0 then
    Result := Owners.Objects[OwnerIndex] As TAssetOwner
  else
  begin
    NewOwner := TAssetOwner.Create;
    (NewOwner as IAssetOwner).Name := OwnerName;
    (NewOwner as IAssetOwner).Site := FSite;
    Owners.AddObject(OwnerName, NewOwner);
    Result := NewOwner;
  end;
end;

function TAssetManager.CreateAssetQuantity(Amount: Currency;
  const UnitsName: WideString): IAssetQuantity;
var
  NewAssetQuantity : TAssetQuantity;
begin
  NewAssetQuantity := TAssetQuantity.Create;
  NewAssetQuantity.Amount := Amount;
  NewAssetQuantity.Units.Name := UnitsName;
  Result := NewAssetQuantity;
end;


function TAssetManager.Get_Trigger(
  const Code: WideString): IAssetTrigger;
var
  TriggerIndex : Integer;
  NewTriggerWrap  : TAssetTriggerWrap;
begin
  TriggerIndex := Triggers.IndexOf(Code);
  If TriggerIndex >= 0 then
  begin
    Result := (Triggers.Objects[TriggerIndex] As TAssetTriggerWrap).AssetTrigger;
  end
  else
  begin
    NewTriggerWrap := TAssetTriggerWrap.Create;
    NewTriggerWrap.AssetTrigger := CreateComObject(ProgIDToClassID('AssetTrigger.' + Code)) As IAssetTrigger;
    Triggers.AddObject(Code, NewTriggerWrap);
    Result := NewTriggerWrap.AssetTrigger;
  end;
end;

function TAssetManager.CloseModel(
  const ModelFileName: WideString): AMStatus;
var
  ModelIndex : Integer;
begin
  //delete model if it exists
  ModelIndex := Models.IndexOf(ModelFileName);
  If ModelIndex >= 0 then
  begin
    AssetModelsPaletteForm.RemoveModel(ModelFileName);
    If Models.Objects[ModelIndex] <> nil then
			(Models.Objects[ModelIndex] As TAssetModel).Free;
    Models.Delete(ModelIndex);
  end;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TAssetManager, Class_AssetManager, ciMultiInstance);
end.
