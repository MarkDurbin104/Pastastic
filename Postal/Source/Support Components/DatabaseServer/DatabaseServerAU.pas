{ Module          Database Server
  Unit            Automation
  Copyright(c)    Postal Solutions Limited 1996..1999
  Author          ASH
  Description     Manages database access and domestic mail management (Hungary)
  Modifications   09/1998     - ASH
                                Original Release - for Hungarian Demo
                  25/01/1999  - ASH
                                Header comments and code formatting
                                HookUp Property added to allow connection in
                                new method TransferRecordsHookUp

}
unit DatabaseServerAU;

interface

uses
  Windows,
  CreateRemote,
  GPCSErrorLine,
  GPCSBase_TLB,
  Classes,
  Denom,
  DataSupportU,
  Db,
  DbTables,
  Dialogs,
  SysUtils,
  ComObj, ActiveX, DatabaseServer_TLB;

const
  TransControlOn = True;
  TransControlOff = False;

type
  TDatabaseServerAuto = class(TAutoObject, IDatabaseServerAuto)
  private
    FHookUp : IHookUp;
    TrackedItemTable: TTable;
    ReceptacleTable: TTable;
    MoneyOrderTable: TTable;
    TrackedStatusTable: TTable;
    EventTypeTable: TTable;
    TrackedEventTable: TTable;
    TrackUserTable : TTable;
    FDataAlias : WideString;
    FEventTypeList : TStringList; //for eventnumber function
    FSite : WideString;
    FPerson : WideString;
    FWorkstation : WideString;

    FDestServer     : IDatabaseServerAuto;

    CurrentSession : TSession;

    function CorrectSite(ItemId : String) : Boolean;
    function GetIndexFieldString(Table : TTable) : String; //returns index field names delimited by semicolons

    function LogEvent(TransControl : Boolean; ItemId : WideString; Event : Integer; DateTime : TDateTime;
                      Info : WideString; NextSite : WideString) : Boolean;

    function EventNumber(EventName : String) : Integer;

    function ItemExists(ItemId : String) : Boolean;
    function ItemType(ItemId : String) : ItemTypeEnum;
    function ItemStatus(ItemId : String) : OperationTypeEnum; //last operation on item
    function ValidateDeliveryPostCode(ItemId : WideString; DeliveryOffice : WideString) : Boolean;

  protected
    function Get_Site: WideString; safecall;
    procedure Set_Site(const Value: WideString); safecall;
    function Get_Person: WideString; safecall;
    procedure Set_Person(const Value: WideString); safecall;
    function Get_Workstation: WideString; safecall;
    procedure Set_Workstation(const Value: WideString); safecall;
    function Delivered(const ItemId: WideString; DateTime: TDateTime;
      const Info: WideString): OperationStatus; safecall;
    function DelyRecd(const ItemId: WideString; DateTime: TDateTime;
      const Info: WideString): OperationStatus; safecall;
    function ItemLeft(const ItemId, ReceptacleId: WideString;
      DateTime: TDateTime; const Info,
      ProcSite: WideString): OperationStatus; safecall;
    function ItemRecd(const ItemId: WideString; DateTime: TDateTime;
      const Info: WideString): OperationStatus; safecall;
    function CounterLeft(DateTime: TDateTime;
      const Unique: WideString): OperationStatus; safecall;
    function ProcLeft(const ItemId: WideString; DateTime: TDateTime;
      const Info, NextSite: WideString): OperationStatus; safecall;
    function ProcRecd(const ItemId: WideString; DateTime: TDateTime;
      const Info: WideString): OperationStatus; safecall;
    function RoundRecd(const ItemId: WideString; DateTime: TDateTime;
      const Info: WideString): OperationStatus; safecall;
    function Undelivered(const ItemId: WideString; DateTime: TDateTime;
      const Info: WideString): OperationStatus; safecall;
    function ExecSQL(const SQLText: WideString): WordBool; safecall;
    function Get_DestServer: IDatabaseServerAuto; safecall;
    function ReceiveRecords(const RecordsMessage: WideString;
      AdjustOnly: WordBool): WordBool; safecall;
    function SendRecords(const TableName, SQLQuery: WideString;
      AdjustOnly: WordBool): WordBool; safecall;
    procedure Set_DestServer(const Value: IDatabaseServerAuto); safecall;
    function ValidateItemId(const ItemId: WideString): WordBool; safecall;
    function CDV(const NumberString: WideString): Integer; safecall;
    function CustRecd(const ItemId: WideString; DateTime: TDateTime; Weight,
      Value: Double; const DestPostCode,
      Info: WideString): OperationStatus; safecall;
    function SealReceptacle(const PendingReceptacleId,
      ActualReceptacleId: WideString;
      NumberOfUntrackedMoneyOrders: Integer; DateTime: TDateTime;
      const Info, ProcSite: WideString): OperationStatus; safecall;
    function QueryCurrentStatus(const ItemId: WideString): WideString; safecall;
    procedure ClearAllTables; safecall;
    function QueryCounterLeft(const Site, Person, Workstation,
      Info: WideString): WideString; safecall;
    function ItemPrep(const ItemId, PendingReceptacleId: WideString;
      DateTime: TDateTime; const Info: WideString): OperationStatus;
      safecall;
    function CheckReceptacle(const ReceptacleId: WideString;
      var ValidItemsCommaText,
      InvalidItemsCommaText: WideString): OperationStatus; safecall;
    function Get_DataAlias: WideString; safecall;
    procedure Set_DataAlias(const Value: WideString); safecall;
    procedure Close; safecall;
    function ValidItemSiteOperation(const ItemId: WideString;
      Operation: OperationTypeEnum): OperationStatus; safecall;
    function UserNumberToId(const UserNumber: WideString): WideString; safecall;
    function QueryRoundRecd(const Site, Person: WideString): WideString;
      safecall;
    function CustPickUp(const ItemId: WideString; DateTime: TDateTime;
      const Info: WideString): OperationStatus; safecall;
    function QueryUnDelivered(const Site: WideString): WideString; safecall;
    function QueryReturnedMoney(const Site, Person: WideString): WideString;
      safecall;
    function DenomBreakDown(Total: Integer): WideString; safecall;
    function QueryToCommaText(const SQLQueryText : WideString) : WideString; safecall;
    function TransferRecords(const SourceMachineName, SourceAlias,
      DestMachineName, DestAlias, DestTable, SQLQueryText: WideString;
      AdjustOnly: WordBool): WordBool; safecall;
    function Get_HookUp: IDispatch; safecall;
    procedure Set_HookUp(Value: IDispatch); safecall;
    function TransferRecordsHookUp(const SourceAlias, DestAlias, DestTable,
      SQLQueryText: WideString; AdjustOnly: WordBool): WordBool; safecall;
  public
    destructor Destroy; override;
    procedure Initialize; override;
  end;

implementation

uses
DatabaseServerF,
ComServ2;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       Get_Site
  Description  Site property get function
  Params       None
  Result       WideString
________________________________________________________________________________}
function TDatabaseServerAuto.Get_Site: WideString;
begin
  Result := FSite;
end;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       Set_Site
  Description  Site property set function
  Params       Value : WideString - new value for Site property
  Result       None
________________________________________________________________________________}
procedure TDatabaseServerAuto.Set_Site(const Value: WideString);
begin
  If FSite <> Value then
    FSite := Value;
end;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       Get_Person
  Description  Person property get function
  Params       None
  Result       WideString
________________________________________________________________________________}
function TDatabaseServerAuto.Get_Person: WideString;
begin
  Result := FPerson;
end;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       Set_Person
  Description  Person property set function
  Params       Value : WideString - new value for Person property
  Result       None
________________________________________________________________________________}
procedure TDatabaseServerAuto.Set_Person(const Value: WideString);
begin
  If FPerson <> Value then
    FPerson := Value;
end;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       Get_Workstation
  Description  Workstation property get function
  Params       None
  Result       WideString
________________________________________________________________________________}
function TDatabaseServerAuto.Get_Workstation: WideString;
begin
  Result := FWorkstation;
end;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       Set_Workstation
  Description  Workstation property set function
  Params       Value : WideString - new value for Workstation property
  Result       None
________________________________________________________________________________}
procedure TDatabaseServerAuto.Set_Workstation(const Value: WideString);
begin
  If FWorkstation <> Value then
    FWorkstation := Value;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        CustRecd
  Description   Logs a tracked item as received from customer
  Params        const ItemId        : WideString  - Identification of item
                DateTime            : TDateTime   - Date and Time of event
                Weight              : Double      - Item Weight (if appropriate)
                Value               : Double      - Item Value (if appropriate);
                const DestPostCode  : WideString  - Item Destination PostCode
                Info                : WideString  - Additional info for event
  Result        OperationStatus                   - status information (success)
________________________________________________________________________________}
function TDatabaseServerAuto.CustRecd(const ItemId: WideString;
  DateTime: TDateTime; Weight, Value: Double; const DestPostCode,
  Info: WideString): OperationStatus;
var
  Table : TTable;
  NewFields : Variant;
begin

  try
    //check operation is valid
    Result := ValidItemSiteOperation(ItemId, otCustRecd);
    If Result <> osSuccess then
      Exit;

    With DatabaseServerForm do
    begin
      //determine item type
      Case ItemType(ItemId) of //trackeditem
        itTrackedItem :
          begin
            Table := TrackedItemTable;
            NewFields := VarArrayOf([String(ItemId), Weight, String(FSite), String(DestPostCode), '', String(Info)]);
          end;

        itMoneyOrder :
          begin
            Table := MoneyOrderTable;
            NewFields := VarArrayOf([ItemId, Value, FSite, DestPostCode, '', Info]);
          end

        else  //invalid prefix
          begin
            Result := osInvalidId;
            Exit;
          end;
      end;  //case

      //update data
      With Table do
      begin
        try
          Database.TransIsolation := tiDirtyRead;
          Database.StartTransaction;
          AppendRecord([NewFields[0],NewFields[1],NewFields[2],NewFields[3],NewFields[4],NewFields[5]]);
          //log event
          If LogEvent(TransControlOn, ItemId, EventNumber('CustRecd'), DateTime, Info, FSite) then
          begin
            Result := osSuccess;  //Committed by logevent
          end
          else
          begin
            If Database.InTransaction then
              Database.Rollback;
            Result := osDatabaseError;
          end;
        except  //key viol indicates trying same item again!
          On E : Exception do
          begin
            RaiseException($124,E);
            Result := osUnexpected;
            If Database.InTransaction then
              Database.Rollback;
            Result := osDatabaseError;
          end;
        end;
      end;  //with table
    end;  //with Form
  except
    On E : Exception do
    begin
      RaiseException($125,E);
      Result := osUnexpected;
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        Delivered
  Description   Logs a tracked item as delivered to addressee
  Params        const ItemId        : WideString  - Identification of item
                DateTime            : TDateTime   - Date and Time of event
                Info                : WideString  - Additional info for event
  Result        OperationStatus                   - status information (success)
________________________________________________________________________________}
function TDatabaseServerAuto.Delivered(const ItemId: WideString;
  DateTime: TDateTime; const Info: WideString): OperationStatus;
begin
  try
    Result := ValidItemSiteOperation(ItemId, otDelivered);
    If Result <> osSuccess then
      Exit;

    If not LogEvent(TransControlOn, ItemId, EventNumber('Delivered'), DateTime, Info, FSite) then
    begin
      Result := osDatabaseError;
    end
    else
      Result := osSuccess;
  except
    On E : Exception do
    begin
      RaiseException($126,E);
      Result := osUnexpected;
    end;
  end;

end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        DelyRecd
  Description   Logs a tracked item as received at delivery office
  Params        const ItemId        : WideString  - Identification of item
                DateTime            : TDateTime   - Date and Time of event
                Info                : WideString  - Additional info for event
  Result        OperationStatus                   - status information (success)
________________________________________________________________________________}
function TDatabaseServerAuto.DelyRecd(const ItemId: WideString;
  DateTime: TDateTime; const Info: WideString): OperationStatus;
begin

  try
    //check operation is valid
    Result := ValidItemSiteOperation(ItemId, otDelyRecd);
    If Result <> osSuccess then
      Exit;

    //update database
    If not LogEvent(TransControlOn, ItemId, EventNumber('DelyRecd'), DateTime, Info, FSite) then
    begin
      Result := osDatabaseError;
    end
    else
      Result := osSuccess;
  except
    On E : Exception do
    begin
      RaiseException($127,E);
      Result := osUnexpected;
    end;
  end;

end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        ItemLeft
  Description   Logs a tracked item as leaving the itemising station
  Params        const ItemId        : WideString  - Identification of item
                const ReceptacleId  : WideString  - Identification of item receptacle
                DateTime            : TDateTime   - Date and Time of event
                Info                : WideString  - Additional info for event
                ProcSite            : WideString  - Code of target processing site
  Result        OperationStatus                   - status information (success)
________________________________________________________________________________}
function TDatabaseServerAuto.ItemLeft(const ItemId,
  ReceptacleId: WideString; DateTime: TDateTime; const Info,
  ProcSite: WideString): OperationStatus;
begin
  try
    //update PendingReceptacle
    With DatabaseServerForm do
    begin
      //check operation is valid
      Result := ValidItemSiteOperation(ItemId, otItemLeft);
      If Result <> osSuccess then
        Exit;

      //check receptacle is valid
      If not ValidateItemId(ReceptacleId)  then
      begin
        Result := osInvalidId;
        Exit;
      end;

      try
        //update database
        With TrackedItemTable do  //transaction isolation
        begin
          If Database.InTransaction = False then
          begin
            Database.TransIsolation := tiDirtyRead;
            Database.StartTransaction;
          end;
        end;  //with TrackedItemTable

        //determine item type
        Case ItemType(ItemId) of
          itTrackedItem :
          begin
            With TrackedItemTable do
            begin
              If Locate(GetIndexFieldString(TrackedItemTable),ItemId,[]) then  //found record
              begin
                Edit;
                FieldByName('TIReceptacle').AsString := ReceptacleId;
                Post;
              end  //if locate
              else
              begin
                If Database.InTransaction then
                begin
                  Database.Rollback;
                  Result := osDatabaseError;
                  Exit;
                end;
              end;
            end;  //with TrackedItemTable
          end;  //itTrackedItem

          itMoneyOrder :
          begin
            With MoneyOrderTable do
            begin
              If Locate(GetIndexFieldString(MoneyOrderTable),ItemId,[]) then  //found record
              begin
                Edit;
                FieldByName('MOReceptacle').AsString := ReceptacleId;
                Post;
              end  //if locate
              else
              begin
                If Database.InTransaction then
                begin
                  Database.Rollback;
                  Result := osDatabaseError;
                  Exit;
                end;
              end;
            end;  //with MoneyOrderTable
          end;  //itMoneyOrder

          itReceptacle :
          begin
            With ReceptacleTable do
            begin
              If ItemExists(ItemId) then  //receptacle already used!
              begin
                Result := osInvalidId;
                If Database.InTransaction then
                begin
                  Database.Rollback;
                  Result := osDatabaseError;
                  Exit;
                end;
              end;  //if itemexists

              //add receptacle
              AppendRecord([string(ItemId), 0, 0]);
            end;  //with ReceptacleTable
          end;  //itReceptacle

          else  //from case
          begin
            Result := osInvalidId;
            If TrackedItemTable.Database.InTransaction then
              TrackedItemTable.Database.Rollback;
            Exit;
          end;
        end;  //case

        //log event
        If LogEvent(TransControlOn,ItemId, EventNumber('ItemLeft'), DateTime, Info, ProcSite) then
          //Committed by logevent
          Result := osSuccess
        else
          Result := osDatabaseError;

      except  //key viol indicates trying same item again!
        If TrackedItemTable.Database.InTransaction then
          TrackedItemTable.Database.Rollback;
        Result := osDatabaseError;
      end;
    end;  //with Form
  except
    On E : Exception do
    begin
      RaiseException($128,E);
      Result := osUnexpected;
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        ItemRecd
  Description   Logs a tracked item as received at the itemising station
  Params        const ItemId        : WideString  - Identification of item
                DateTime            : TDateTime   - Date and Time of event
                const Info          : WideString  - Additional info for event
  Result        OperationStatus                   - status information (success)
________________________________________________________________________________}
function TDatabaseServerAuto.ItemRecd(const ItemId: WideString;
  DateTime: TDateTime; const Info: WideString): OperationStatus;
begin
  try
    //check operation is valid
    Result := ValidItemSiteOperation(ItemId, otItemRecd);
    If Result <> osSuccess then
      Exit;

    //update database
    If not LogEvent(TransControlOn, ItemId, EventNumber('ItemRecd'), DateTime, Info, FSite) then
    begin
      Result := osDatabaseError;
    end
    else
      Result := osSuccess;

  except
    On E : Exception do
    begin
      RaiseException($129,E);
      Result := osUnexpected;
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        CounterLeft
  Description   Logs all pending item as leaving the counter
  Params        DateTime            : TDateTime   - Date and Time of event
                Unique              : WideString  - Unique id for this batch of items
  Result        OperationStatus                   - status information (success)
________________________________________________________________________________}
function TDatabaseServerAuto.CounterLeft(DateTime: TDateTime;
  const Unique: WideString): OperationStatus;
var
  CounterLeftQuery : TQuery;
  SQLText : String;
begin
  try
    //build query which selects all valid items for this operation
    SQLText :=   ' select TSItemId from TrackedStatus, TrackedEvents'
               + ' where '
               + ' TSEvent <= ' + IntToStr(EventNumber('CounterLeft'))  //not yet received at itemising station
               + ' and TEItemId = TSItemId '
               + ' and TEEvent = TSEvent '
               + ' and TEDateTime = TSDateTime '
               + ' and TESite = ''' + FSite + ''''                      //for this office
               + ' and TEPerson = ''' + FPerson + ''''                  //for this person
               + ' and TEWorkstation = ''' + FWorkstation + '''';       //for this workstation

    CounterLeftQuery := TQuery.Create(nil);
    //run query to get items
    With CounterLeftQuery do
    begin
      try
        Close;
        DatabaseName := FDataAlias;
        SQL.Text := SQLText;
        Open;

        //update database for each item
        With Database do
        begin
          If not Database.InTransaction then
          begin
            Database.TransIsolation := tiDirtyRead;
            StartTransaction;
          end;
          try
            Result := osSuccess;
            While (Not Eof) and (result = osSuccess) do
            begin
              If not LogEvent(TransControlOff, Fields[0].AsString, EventNumber('CounterLeft'), DateTime,Unique , FSite) then
              //'Unique' is used to identify this batch of items (printed on report barcode) when they are received at the
              //itemising station
              begin
                Result := osDatabaseError;
              end;
              Next;
            end;
            If (Result = osSuccess) then
            begin
              Commit;
            end
          except
            Rollback;
            Result := osDatabaseError;
          end;
        end;  //with database
      finally
        CounterLeftQuery.Free;
      end;
    end;
  except
    On E : Exception do
    begin
      RaiseGUIDException('{9AC66ADF-AD8C-4C6E-9D38-25ABD51ED269}',E);
      Result := osUnexpected;
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        ProcLeft
  Description   Logs a tracked item as leaving the processing site
  Params        const ItemId        : WideString  - Identification of item
                DateTime            : TDateTime   - Date and Time of event
                const Info          : WideString  - Additional info for event
                const NextSite      : WideString  - Code of target processing/delivery site
  Result        OperationStatus                   - status information (success)
________________________________________________________________________________}
function TDatabaseServerAuto.ProcLeft(const ItemId: WideString;
  DateTime: TDateTime; const Info, NextSite: WideString): OperationStatus;
begin
  Result := osUnexpected; //method not implemented (not required in Hungary)
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        ProcRecd
  Description   Logs a tracked item as received at the processing site
  Params        const ItemId        : WideString  - Identification of item
                DateTime            : TDateTime   - Date and Time of event
                const Info          : WideString  - Additional info for event
  Result        OperationStatus                   - status information (success)
________________________________________________________________________________}
function TDatabaseServerAuto.ProcRecd(const ItemId: WideString;
  DateTime: TDateTime; const Info: WideString): OperationStatus;
begin
  Result := osUnexpected;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        RoundRecd
  Description   Logs a tracked item as received by the round delivery person
  Params        const ItemId        : WideString  - Identification of item
                DateTime            : TDateTime   - Date and Time of event
                const Info          : WideString  - Additional info for event
  Result        OperationStatus                   - status information (success)
________________________________________________________________________________}
function TDatabaseServerAuto.RoundRecd(const ItemId: WideString;
  DateTime: TDateTime; const Info: WideString): OperationStatus;
begin
  try
    //check operation is valid
    Result := ValidItemSiteOperation(ItemId, otRoundRecd);
    If Result <> osSuccess then
      Exit;

    //update database
    If not LogEvent(TransControlOn, ItemId, EventNumber('RoundRecd'), DateTime, Info, FSite) then
    begin
      Result := osDatabaseError;
    end
    else
      Result := osSuccess;
  except
    On E : Exception do
    begin
      RaiseException($12B,E);
      Result := osUnexpected;
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        Undelivered
  Description   Logs a tracked item as undelievered by the round delivery person
  Params        const ItemId        : WideString  - Identification of item
                DateTime            : TDateTime   - Date and Time of event
                const Info          : WideString  - Additional info for event
  Result        OperationStatus                   - status information (success)
________________________________________________________________________________}
function TDatabaseServerAuto.Undelivered(const ItemId: WideString;
  DateTime: TDateTime; const Info: WideString): OperationStatus;
begin
  try
    //check operation is valid
    Result := ValidItemSiteOperation(ItemId, otUnDelivered);
    If Result <> osSuccess then
      Exit;

    //update database
    If not LogEvent(TransControlOn, ItemId, EventNumber('UnDelivered'), DateTime, Info, FSite) then
    begin
      Result := osDatabaseError;
    end
    else
      Result := osSuccess;
  except
    On E : Exception do
    begin
      RaiseException($12C,E);
      Result := osUnexpected;
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        RoundRecd
  Description   Logs Events - internal used by other methods
  Params        TransControl        : Boolean     - TRUE : use transaction control in the function
                                                    FALSE: transaction control is performed by the
                                                            calling procedure
                ItemId              : WideString  - Identification of item
                Event               : Integer     - Code number of event
                DateTime            : TDateTime   - Date and Time of event
                const Info          : WideString  - Additional info for event
                NextSite            : WideString  - Code of target office for the item
  Result        Boolean                           - status information (success)
________________________________________________________________________________}
function TDatabaseServerAuto.LogEvent(TransControl : Boolean;
              ItemId : WideString; Event : Integer; DateTime : TDateTime;
              Info : WideString; NextSite : WideString) : Boolean;

begin
  try
    With DatabaseServerForm do
    begin
      With TrackedEventTable.Database do
      begin
        try
          //establish transaction
          If TransControl
          and not TrackedEventTable.Database.InTransaction then
          begin
            TransIsolation := tiDirtyRead;
            StartTransaction;
          end;

          //check for same event for this item (same time?!)
          If TrackedEventTable.Locate('TEItemId;TEEvent;TEDateTime',VarArrayOf([ItemId,Event,DateTime]),[loCaseInsensitive]) then
          begin
            TrackedEventTable.Edit;
            TrackedEventTable.SetFields([String(ItemId), Event, DateTime, String(FSite), String(FPerson), String(FWorkstation), String(Info)]);
            TrackedEventTable.Post;
          end
          else  //event not logged yet
          begin
            TrackedEventTable.AppendRecord([String(ItemId), Event, DateTime, String(FSite), String(FPerson), String(FWorkstation), String(Info)]);
          end;

          //check for same status for this item (and update with latest time)
          If TrackedStatusTable.Locate('TSItemId',ItemId,[]) then
          begin
            TrackedStatusTable.Edit;
            TrackedStatusTable.SetFields([String(ItemId), Event, DateTime, String(NextSite)]);
            TrackedStatusTable.Post;
          end
          else  //status not logged yet
          begin
            TrackedStatusTable.AppendRecord([String(ItemId), Event, DateTime, String(NextSite)]);
          end;
          If TransControl then
            Commit;
          Result := True;
        except
          On E : Exception do
          begin
            RaiseException($12D,E);
            TrackedEventTable.Cancel;
            TrackedStatusTable.Cancel;
            If TransControl and TrackedEventTable.Database.InTransaction then
              Rollback;
            Result := False;
          end;
        end;  //try
      end;  //with Database
    end; //with Form
  except
    On E : Exception do
    begin
      RaiseException($12E,E);
      Result := False;
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        Destroy
  Description   Frees internal structures, closes and frees tables
  Params        None
  Result        Boolean                           - status information (success)
________________________________________________________________________________}
destructor TDatabaseServerAuto.Destroy;
begin

  try
    try
      If FEventTypeList <> nil then
      begin
        FEventTypeList.Free;
      end;
    //  FDestServer := nil;

      //free tables
      
     if TrackedItemTable   <> nil then TrackedItemTable   .Active := False  ;
     if ReceptacleTable    <> nil then ReceptacleTable    .Active := False    ;
     if MoneyOrderTable    <> nil then MoneyOrderTable    .Active := False    ;
     if TrackedStatusTable <> nil then TrackedStatusTable .Active := False ;
     if EventTypeTable     <> nil then EventTypeTable     .Active := False     ;
     if TrackedEventTable  <> nil then TrackedEventTable  .Active := False  ;
     if TrackUserTable     <> nil then TrackUserTable     .Active := False;

      DatabaseServerForm.LogMemo.Lines.Add('Close Session ' + CurrentSession.SessionName);
      CurrentSession.Close;

      //  Query.Active := False              ;
      if TrackedItemTable   <> nil then TrackedItemTable.Free;
      if ReceptacleTable    <> nil then ReceptacleTable.Free;
      if MoneyOrderTable    <> nil then MoneyOrderTable.Free;
      if TrackedStatusTable <> nil then TrackedStatusTable.Free;
      if EventTypeTable     <> nil then EventTypeTable.Free;
      if TrackedEventTable  <> nil then TrackedEventTable.Free;
      if TrackUserTable     <> nil then TrackUserTable.Free;
    //  Query.Free;
    except
      On E : Exception do
      begin
        RaiseException($12F,E);
      end;
    end;
  finally
    inherited Destroy;
  end;

end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        SendRecords
  Description   Sends records to another machine
  Params        const TableName   : WideString  - Table to update
                SQLQuery          : WideString  - Query to select records
                AdjustOnly        : WordBool    - Whether numerical values are added to current records
  Result        WordBool                        - status information (success)
________________________________________________________________________________}
function TDatabaseServerAuto.SendRecords(const TableName,
  SQLQuery: WideString; AdjustOnly: WordBool): WordBool;
var
  RecordStringList : TStringList;
begin
  try
    Result := False;
    If FDestServer <> nil then
    begin
      //build message stringlist
      RecordStringList := TStringList.Create;
      With RecordStringList do
      begin
        try
          CommaText := QueryToCommaText(SQLQuery);
          Insert(0,TableName);
          Result := FDestServer.ReceiveRecords(CommaText,AdjustOnly);  //overwrite
        finally
          Free;
        end;
      end;
    end
    else
    begin
      //error here for server not set
    end;
  except
    On E : Exception do
    begin
      RaiseException($130,E);
      Result := False;
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        ReceiveRecords
  Description   Receives records sent from another machine
  Params        const RecordsMessage  : WideString  - Packed records message
                AdjustOnly            : WordBool    - Whether numerical values are added to current records
  Result        WordBool                            - status information (success)
________________________________________________________________________________}
function TDatabaseServerAuto.ReceiveRecords(
  const RecordsMessage: WideString; AdjustOnly: WordBool): WordBool;
const
  HeaderStrings = 1;
  eKeyViol = 9729;  //key violation
var
  IndexArray            : Variant;      //index field values
  CurrentField          : TField;       //current field in record
  DestTableName         : String;       //detination table
  FieldIndex            : Integer;      //field iterator
  IndexFieldString      : String;       //string containing list of index fields
  LocateSuccess         : Boolean;      //whether search succeeded
  MessageStringList     : TStringList;  //reconstituted message
  RecordStringList      : TStringList;  //each record
  RecordIndex           : Integer;      //record iterator
  ReceiveTable          : TTable;       //table to receive records
  TableFieldCount       : Integer;      //count of fields in table
begin
  try
    Result := False;

    //rebuild message stringlist
    MessageStringList := TStringList.Create;
    RecordStringList  := TStringList.Create;
    try
      MessageStringList.CommaText := RecordsMessage;
      DestTableName := MessageStringList[0];
      MessageStringList.Delete(0);  //delete table name
      //add/update records
      ReceiveTable := TTable.Create(nil);
      With ReceiveTable do
      begin
        try
          //connect to correct table
          Active := False;
          DatabaseName := FDataAlias;
          TableName := DestTableName;
          Active := True;
          //build string of fields
          IndexFieldString := GetIndexFieldString(ReceiveTable);
          TableFieldCount := FieldCount;
          //create array to hold search values
          IndexArray := VarArrayCreate([0, IndexFieldCount-1], varVariant);

          //append records
          For RecordIndex := 0 to MessageStringList.Count-1  do
          begin
            RecordStringList.CommaText := MessageStringList[RecordIndex];
            Append;
            For FieldIndex := 0 to (TableFieldCount - 1) do
            begin
              Fields[FieldIndex].AsString := RecordStringList.Strings[FieldIndex];
            end;
            try
              Post;
            except  //maybe key violation
              On E : EDBEngineError do
              begin
                if (E as EDBEngineError).Errors[0].Errorcode = eKeyViol then
                begin
                  try
                    Cancel; //stops record being posted
                    //build array of search values
                    For FieldIndex := 0 to (IndexFieldCount - 1) do
                    begin
                       //grab value of index field from record strings
                      IndexArray[FieldIndex] := RecordStringList[IndexFields[FieldIndex].Index];
                    end;
                    //locate
                    If (IndexFieldCount = 1) then //cannot use variant arrays
                      LocateSuccess := Locate(IndexFieldString,VarToStr(IndexArray[0]),[])
                    else
                      LocateSuccess := Locate(IndexFieldString,IndexArray,[]);
                    If LocateSuccess then
                    begin
                      Edit; //update
                      For FieldIndex := 0 to (TableFieldCount - 1) do
                      begin
                        CurrentField := Fields[FieldIndex];
                        If AdjustOnly then
                        begin
                          If (CurrentField.DataType in  [ftSmallint, ftInteger, ftWord]) then
                            CurrentField.AsInteger := CurrentField.AsInteger
                              + StrToIntDef(RecordStringList[FieldIndex],0)
                          else if (CurrentField.DataType in  [ftFloat, ftCurrency]) then
                            CurrentField.AsCurrency := CurrentField.AsCurrency
                              + StrToCurr(RecordStringList[FieldIndex])
                          else if (CurrentField.DataType in  [ftDate, ftTime, ftDateTime]) then
                            Fields[FieldIndex].AsDateTime := Fields[FieldIndex].AsDateTime
                              + StrToDateTime(RecordStringList[FieldIndex]);
                        end
                        else
                        begin
                            Fields[FieldIndex].AsString := RecordStringList[FieldIndex];
                        end;  //Adjust
                      end;
                      Post;
                    end;  //if locate

                  except
                    on E : Exception do
                      RaiseGUIDException('{9EC5F71A-E649-45C0-9608-68AAEEAF8FFB}',E);
                  end;

                end  //If Key Violation
                else
                begin
                  raise;  //reraise if not key violation
                end;
              end;  //On EDbEngineError
            end;  //Post try
          end;  //For RecordIndex
          Result := True;
        finally
          ReceiveTable.Free;
        end;
      end;  //with ReceiveRecordsTable
    finally
      MessageStringList.Free;
    end;  //MessageStringList try
  except
    On E : Exception do
    begin
      RaiseGUIDException('{B382F398-CB9E-4806-92EC-227DAC27064E}',E);
      Result := False;
    end;
  end;
end;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       Get_DestServer
  Description  DestServer property get function
  Params       None
  Result       IDatabaseServerAuto - reference to remote automation server object
________________________________________________________________________________}
function TDatabaseServerAuto.Get_DestServer: IDatabaseServerAuto;
begin
  Result := FDestServer;
end;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       Set_DestServer
  Description  DestServer property set function
  Params       Value : IDatabaseServerAuto - reference to remote new value for Site property
  Result       None
________________________________________________________________________________}
procedure TDatabaseServerAuto.Set_DestServer(const Value: IDatabaseServerAuto);
begin
  If FDestServer <> Value then
    FDestServer := Value;
end;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       GetIndexFieldString
  Description  Returns index field names delimited by semicolons for a table
  Params       Table : TTable - Table find index fields of
  Result       String         - semicolon delimited list of index fields
________________________________________________________________________________}
function TDatabaseServerAuto.GetIndexFieldString(Table : TTable) : String;
var
  FieldIndex : Integer;
begin
  try
    //build list of index fields
    With Table do
    begin
      Result := '';
      For FieldIndex := 0 to IndexFieldCount - 1 do
      begin
        Result := Result + IndexFields[FieldIndex].FieldName + ';';
      end;
      //remove last semicoln
      Result := Copy(Result,0,Length(Result)-1);
    end;
  except
    On E : Exception do
    begin
      RaiseException($132,E);
      Result := '';
    end;
  end;

end;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       ExecSQL
  Description  Executes a functional (non-SELECT) SQL statement
  Params       const SQLText : WideString - SQL statement to execute
  Result       WordBool                   - success indicator
________________________________________________________________________________}
function TDatabaseServerAuto.ExecSQL(const SQLText: WideString): WordBool;
var
  SQLQuery : TQuery;
begin
  try
    Result := False;
    SQLQuery := TQuery.Create(nil);
    With  SQLQuery do
    begin
      try
        SQLQuery.DatabaseName := FDataAlias;
        Close;
        SQL.Clear;
        SQL.Add(SQLText);
        SQLQuery.ExecSQL;
        Result := True;
      finally
        SQLQuery.Free;
      end;
    end;
  except
    On E : Exception do
    begin
      RaiseGUIDException('{BEE5EED6-BDD8-42FE-BE92-ED753E71D572}',E);
      Result := False;
    end;
  end;

end;


{===============================================================================
  Class        TDatabaseServerAuto
  Method       Initialize
  Description  Executes a functional (non-SELECT) SQL statement
  Params       const SQLText : WideString - SQL statement to execute
  Result       WordBool                   - success indicator
________________________________________________________________________________}
procedure TDatabaseServerAuto.Initialize;
begin

  try
    Inherited Initialize;

    CurrentSession := Sessions.OpenSession('Session' + DateTimeToStr(Now));
    DatabaseServerForm.LogMemo.Lines.Add('Start Session ' + CurrentSession.SessionName);


    //create tables
    //if mail management is required
    {
    TrackedItemTable  := TTable.Create(nil);
    ReceptacleTable   := TTable.Create(nil);
    MoneyOrderTable   := TTable.Create(nil);
    TrackedStatusTable:= TTable.Create(nil);
    EventTypeTable    := TTable.Create(nil);
    TrackedEventTable := TTable.Create(nil);
    TrackUserTable    := TTable.Create(nil);
  //  Query             := TQuery.Create(nil);

    //set database
    TrackedItemTable.DatabaseName := 'PSLTrack';
    ReceptacleTable.DatabaseName := 'PSLTrack';
    MoneyOrderTable.DatabaseName := 'PSLTrack';
    TrackedStatusTable.DatabaseName := 'PSLTrack';
    EventTypeTable.DatabaseName := 'PSLTrack';
    TrackedEventTable.DatabaseName := 'PSLTrack';
    TrackUserTable.DatabaseName := 'PSLTrack';
  //  Query.DatabaseName := 'PSLTrack';


    TrackedItemTable.TableName := 'TrackedItem';
    ReceptacleTable.TableName := 'Receptacle';
    MoneyOrderTable.TableName := 'MoneyOrders';
    TrackedStatusTable.TableName := 'TrackedStatus';
    EventTypeTable.TableName := 'EventType';
    TrackedEventTable.TableName := 'TrackedEvents';
    TrackUserTable.TableName := 'TrackUsers';

    TrackedItemTable.Active := True;
    ReceptacleTable.Active := True;
    MoneyOrderTable.Active := True;
    TrackedStatusTable.Active := True;
    EventTypeTable.Active := True;
    TrackedEventTable.Active := True;
    TrackUserTable.Active := True;

   // TrackedItemTable.Database.KeepConnection := False;
    //Query.Active := True;

    FEventTypeList := TStringList.Create;
    //default alias
    FDataAlias := 'PSLTrack';

    With DatabaseServerForm, FEventTypeList, EventTypeTable do
    begin
      First;
      While not EOF do
      begin
        FEventTypeList.Add(EventTypeTable.FieldByName('ETName').AsString
                            + '='
                            + EventTypeTable.FieldByName('ETOrder').AsString);
        Next;
      end;
    end;
    }
  except
    On E : Exception do
    begin
      RaiseException($134,E);
      FEventTypeList.Free;
      FEventTypeList := nil;
      CurrentSession.Close;
      TrackedItemTable.Free;
      ReceptacleTable.Free;
      MoneyOrderTable.Free;
      TrackedStatusTable.Free;
      EventTypeTable.Free;
      TrackedEventTable.Free;
      TrackUserTable.Free;
    end;
  end;
end;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       EventNumber
  Description  Returns the tracking event code of a named event
  Params       EventName : WideString - Name of the event ,eg, 'CustRecd'
  Result       Integer                - Event number code
________________________________________________________________________________}
function TDatabaseServerAuto.EventNumber(EventName : String) : Integer;
begin
  With FEventTypeList do
    Result := StrToIntDef(Values[EventName],0);
end;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       ItemExists
  Description  Determines whether the tracked item exists in the tracking system
  Params       ItemId : WideString  - Identification of tracked item
  Result       Boolean              - Whether item exists in tracking system
________________________________________________________________________________}
function TDatabaseServerAuto.ItemExists(ItemId : String) : Boolean;
var
  Prefix : String;
  Table  : TTable;
begin
  try
    //determine table to use
    With DatabaseServerForm do
    begin
      Prefix := Copy(ItemId,1,2);
      If Prefix = 'TI' then
      begin
        Table := TrackedItemTable;
      end
      else If Prefix = 'RC' then
      begin
        Table := ReceptacleTable;
      end
      else
      begin
        Table := MoneyOrderTable;
      end;

      //locate item
      If Table.Locate(GetIndexFieldString(Table),ItemId,[loCaseInsensitive]) then
        Result := True
      else
        Result := False;
    end;  //with DatabaseServerForm
  except
    On E : Exception do
    begin
      RaiseException($135,E);
      Result := False;
    end;
  end;
end;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       ItemType
  Description  Returns the type of the tracked item
  Params       ItemId : String  - Identification of tracked item
  Result       ItemTypeEnum     - Item Type code
________________________________________________________________________________}
function TDatabaseServerAuto.ItemType(ItemId : String) : ItemTypeEnum;
var
  Prefix : String;
begin

  try
    //first 2 chars determines item type
    Prefix := Copy(ItemId,1,2);
    If Prefix = 'TI' then
    begin
      Result := itTrackedItem;
    end
    else If Prefix = 'RC' then
    begin
      Result := itReceptacle;
    end
    else If (Length(ItemId) = 13) and (CDV(ItemId) <> -1) then
    begin
      Result := itMoneyOrder;
    end
    else
    begin
      Result := itUnknown;
    end;

  except
    On E : Exception do
    begin
      RaiseException($136,E);
      Result := itUnKnown;
    end;
  end;
end;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       ItemStatus
  Description  Returns the status of the tracked item
  Params       ItemId : String    - Identification of tracked item
  Result       OperationTypeEnum  - Code of item status
________________________________________________________________________________}
function TDatabaseServerAuto.ItemStatus(ItemId : String) : OperationTypeEnum; //last operation on item
begin
  Result :=  TrackedStatusTable.LookUp('TSItemId',ItemId,'TSEvent');
end;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       ValidateItemId
  Description  Validate the item identification
  Params       const ItemId : WideString  - WordBool
  Result       WordBool                   - whether id is valid
________________________________________________________________________________}
function TDatabaseServerAuto.ValidateItemId(const ItemId: WideString): WordBool;
var
  Suffix : String;
begin

  try
    Case ItemType(ItemId) of
      //tracked items and receptacles
      itTrackedItem, itReceptacle :
      begin
        Suffix := Copy(ItemId,Length(ItemId)-1,2);
        If Length(ItemId) = 18 then //correct length
          If  Suffix = 'HU' then
            If CDV(Copy(ItemId,3,13)) = StrToInt(Copy(ItemId,16,1)) then //correct checksum
            begin
              Result := True;
              Exit;
            end;
      end;

      itMoneyOrder :
      begin
        //money orders
        If Length(ItemId) = 13 then //correct length
          If CDV(ItemId) <> -1 then //all digits
          begin
            Result := True;
            Exit;
          end;

      end;

      else
      begin
        Result := False;
      end;

    end;  //case
  except
    On E : Exception do
    begin
      RaiseException($137,E);
      Result := False;
    end;
  end;

end;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       CDV
  Description  Returns the check digit verification number for a number-string
  Params       const NumberString : WideString  - number string
  Result       Integer                          - Check digit
________________________________________________________________________________}
function TDatabaseServerAuto.CDV(const NumberString: WideString): Integer;
var
  BaseValue : Integer;
  Index : Integer;
  Total : Integer;
begin
  try
    //build total
    BaseValue  := Ord('0');
    Total := 0;
    For Index := 1 to Length(NumberString) do
    begin
      Inc(Total, Ord(NumberString[Index]) - BaseValue );
    end;
    //return check digit
    Result := Total mod 10;
  except  //may have found a non-digit
    On E : Exception do
    begin
      RaiseException($138,E);
      Result := -1;
    end;
  end;
end;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       CorrectSite
  Description  Determines whether item is at correct site
  Params       ItemId : String    - Identification of tracked item
  Result       Boolean            - Whether item is at correct site
________________________________________________________________________________}
function TDatabaseServerAuto.CorrectSite(ItemId : String) : Boolean;
var
  NextDest : String;
begin
  try
    //get stored target site
    NextDest := TrackedStatusTable.Lookup('TSItemId',ItemId,'TSNextDest');
    //compare with this site
    If FSite = NextDest then
        Result := True
    else
        Result := False;
  except
    On E : Exception do
    begin
      RaiseException($139,E);
      Result := False;
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        SealReceptacle
  Description   Seals a prepared receptacle and updates items therein
  Params        PendingReceptacleId           : WideString  - prepared receptacle id
                ActualReceptacleId            : WideString  - real receptacle id
                NumberOfUntrackedMoneyOrders  : Integer     - also in receptacle
                DateTime                      : TDateTime   - date and time of event
                Info                          : WideString  - extra event info
                ProcSite                      : WideString  - site code for target processing site
  Result        OperationStatus                             - status information (success)
________________________________________________________________________________}
function TDatabaseServerAuto.SealReceptacle(const PendingReceptacleId,
  ActualReceptacleId: WideString; NumberOfUntrackedMoneyOrders: Integer;
  DateTime: TDateTime; const Info, ProcSite: WideString): OperationStatus;
var
  ItemCount : Integer;
  ItemId : String;
  ReceptacleField : String;
  SealReceptacleQuery : TQuery;
  SQLText : String;
  Table : TTable;
  ReceptacleWeight : Double;
begin

  try
    //create receptacle
    If not ValidateItemId(ActualReceptacleId)  then //invalid receptacle
    begin
      Result := osInvalidId;
      Exit;
    end;

    If ItemExists(ActualReceptacleId) then  //receptacle already used!
    begin
      Result := osInvalidId;
      Exit;
    end;  //if itemexists

    //build query which gets items in prepared receptacle
    SQLText :=   ' select TIBarcode As ItemId, TIWeight as Weight from TrackedItem, TrackedStatus'
               + ' where '
               + ' TIReceptacle = ''' + PendingReceptacleId + ''''  //find items in receptacle
               + ' and TSItemId = TIBarcode '                           //join to status
               + ' and TSEvent = ' + IntToStr(EventNumber('ItemPrep'))  //prepared items
               + ' '
               + ' union '
               + ' select MOBarcode As ItemId, 0 As Weight from MoneyOrders, TrackedStatus'
               + ' where '
               + ' MOReceptacle = ''' + PendingReceptacleId + ''''  //find items in receptacle
               + ' and TSItemId = MOBarcode '
               + ' and TSEvent = ' + IntToStr(EventNumber('ItemPrep'));  //prepared items

    //open query and start transaction control
    SealReceptacleQuery := TQuery.Create(nil);
    With SealReceptacleQuery do
    begin
      try
        Close;
        DatabaseName := FDataAlias;
        SQL.Text := SQLText;
        Open;

        With Database, DatabaseServerForm do
        begin
          try //database
            If not InTransaction then
            begin
              Database.TransIsolation := tiDirtyRead;
              StartTransaction;
            end;
            First;
            Result := osSuccess;  //assume Success
            ItemCount := 0;
            ReceptacleWeight := 0;
            While (Not Eof) and (Result = osSuccess) do
            begin
              //update receptacle and logevent for each item
              //determine item type
              ItemId := FieldByName('ItemId').AsString;
              Case ItemType(ItemId) of

                itTrackedItem :
                begin
                  Table := TrackedItemTable;
                  ReceptacleField := 'TIReceptacle';
                end;  //itTrackedItem

                itMoneyOrder :
                begin
                  Table := MoneyOrderTable;
                  ReceptacleField := 'MOReceptacle';
                end;  //itMoneyOrder

                else  //from case
                begin
                  Table := nil;
                  Result := osInvalidId;
                end;
              end;  //item type case

              If (Result = osSuccess) then //valid id
              begin
                With Table do
                begin
                  Result := osDatabaseError;  //assume will be an error
                  If Locate(GetIndexFieldString(Table),ItemId,[]) then  //found record
                  begin
                    Edit;
                    FieldByName(ReceptacleField).AsString := ActualReceptacleId;
                    Post;
                    //log event
                    If LogEvent(TransControlOff, ItemId, EventNumber('ItemLeft'), DateTime, Info, ProcSite) then
                    begin
                      Result := osSuccess;
                      ReceptacleWeight := ReceptacleWeight + SealReceptacleQuery.FieldByName('Weight').AsFloat;
                      Inc(ItemCount);
                    end
                    else
                      Result := osDatabaseError;
                  end;//  //if locate
                end;  //with Table
              end;  //if success
              SealReceptacleQuery.Next;
            end;  //while

            //create actual receptacle
            With ReceptacleTable do
            begin
              If ItemExists(ActualReceptacleId) then  //receptacle already used!
                Result := osInvalidId
              else if ItemCount > 0 then
              begin  //if itemsexistedsxists
                //add receptacle
                AppendRecord([string(ActualReceptacleId), ReceptacleWeight, ItemCount + NumberOfUntrackedMoneyOrders]);
                //update receptacle status
                If LogEvent(TransControlOff, ActualReceptacleId, EventNumber('ItemLeft'), DateTime, Info, ProcSite) then
                  Result := osSuccess
                else
                  Result := osDatabaseError;

              end
              else
                Result := osNotFound;
            end;  //with ReceptacleTable

            //check success and commit
            if Result <> osSuccess then //problem
            begin
              If Database.InTransaction then
                Database.Rollback;
              Result := osDatabaseError;
            end
            else
              Commit;
          except
            On E : Exception do
            begin
              RaiseException($13A,E);
              If Database.InTransaction then
                Database.Rollback;
              Result := osDatabaseError;
            end;
          end;  //try database
        end;  //with database, form
      finally
        SealReceptacleQuery.Free;
      end;
    end;  //with Query
  except
    On E : Exception do
    begin
      RaiseGUIDException('{6F5F4154-64C9-46AA-8D67-A745E2988654}',E);
      Result := osUnexpected;
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        QueryToCommaText
  Description   Returns the results of a query back in nested commatext
  Params        SQLQueryText  : WideString  - query to run
  Result        WideString                  - nested commatext fields
________________________________________________________________________________}
function TDatabaseServerAuto.QueryToCommaText(const SQLQueryText : WideString) : WideString;
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
            DatabaseName := FDataAlias;
            SQL.Text := SQLQueryText;
            Open;
            First;
            While not EOF do
            begin
              For FieldIndex := 0 to FieldCount - 1 do
              begin
{                If Fields[FieldIndex].AsString = '' then
                  FieldStringList.Add('""')
                else
}
                  FieldStringList.Add(Fields[FieldIndex].AsString);

              end;
              FieldStringList.Add(','); //ensure a blank is not at end of line
              RecordStringList.Add(FieldStringList.CommaText);  //add each record
              FieldStringList.Clear;
              Next;
            end;
            Close;
            Result := RecordStringList.CommaText;
          finally
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
      RaiseGUIDException('{C28700B4-A155-460A-9B7F-C60882111772}' + SQLQueryText,E);
      Result := '';
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        QueryCurrentStatus
  Description   Returns full tracking history of item
  Params        ItemId : WideString  - item identification
  Result        WideString           - item status
________________________________________________________________________________}
function TDatabaseServerAuto.QueryCurrentStatus(
  const ItemId: WideString): WideString;
var
  QueryItemType : ItemTypeEnum;
  SQLText : WideString;
begin

  try
    SQLText := '';
    QueryItemType := ItemType(ItemId);

    //build query depending on item type
    Case QueryItemType of
      itTrackedItem:
        SQLText :=
            ' select ETDescription, TESite, TEDateTime, TEPerson, TEWorkstation, TEInfo, TIWeight, 0, 0, ETOrder'
          + ' from'
          + ' TrackedItem, TrackedEvents, EventType'
          + ' where'
          + ' TIBarcode = ''' + ItemId + ''''
          + ' and'
          + ' TEItemId = TIBarcode'
          + ' and'
          + ' ETOrder = TEEvent'
          + ' '
          + ' order by'
          + ' TEDateTime DESC';

      itMoneyOrder:
        SQLText :=
           ' select ETDescription, TESite, TEDateTime, TEPerson, TEWorkstation, TEInfo, 0, MOValue, 0, ETOrder'
          + ' from'
          + ' MoneyOrders, TrackedEvents, EventType'
          + ' where'
          + ' MOBarcode = ''' + ItemId + ''''
          + ' and'
          + ' TEItemId = MOBarcode'
          + ' and'
          + ' ETOrder = TEEvent'
          + ' '
          + ' order by'
          + ' TEDateTime DESC';

      itReceptacle:
        SQLText :=
            ' select ETDescription, TESite, TEDateTime, TEPerson, TEWorkstation, TEInfo, RCWeight, 0, RCNumItems, ETOrder'
          + ' from'
          + ' Receptacle, TrackedEvents, EventType'
          + ' where'
          + ' RCBarcode = ''' + ItemId + ''''
          + ' and'
          + ' TEItemId = RCBarcode'
          + ' and'
          + ' ETOrder = TEEvent'
          + ' '
          + ' order by'
          + ' TEDateTime DESC';

      else
        SQLText := ''
    end;  //case

    If SQLText <> '' then
      Result := QueryToCommaText(SQLText)
    else
      Result := '';
  except
    On E : Exception do
    begin
      RaiseException($13D,E);
      Result := '';
    end;
  end;
end;


{===============================================================================
  Class         TDatabaseServerAuto
  Method        ClearAllTables
  Description   Clears all tracking tables (for demo systems only!)
  Params        None
  Result        None
________________________________________________________________________________}
procedure TDatabaseServerAuto.ClearAllTables;
var
  DeleteQuery : TQuery;
begin
  try
    DeleteQuery := TQuery.Create(nil);
    With DeleteQuery do
    begin
      try
        Close;
        DatabaseName := FDataAlias;

        SQL.Text := 'delete from MoneyOrders';
        ExecSQL;
        Close;

        SQL.Text := 'delete from Receptacle';
        ExecSQL;
        Close;

        SQL.Text := 'delete from TrackedItem';
        ExecSQL;
        Close;

        SQL.Text := 'delete from TrackedEvents';
        ExecSQL;
        Close;

        SQL.Text := 'delete from TrackedStatus';
        ExecSQL;
        Close;

      finally
        DeleteQuery.Free;
      end;
    end;  //with Query
  except
    On E : Exception do
      RaiseGUIDException('{06605F27-E008-4B43-B7D2-CE761F67C9C5}',E);
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        QueryCounterLeft
  Description   Returns list of items that have been looged as leaving the counter
  Params        const Site        : WideString - Site where items left counter
                const Person      : WideString - Person who logged items left counter
                const Workstation : WideString - Workstation that items left counter
                Info              : WideString - unique id of counter left batch
  Result        WideString                     - Commatext of item records
________________________________________________________________________________}
function TDatabaseServerAuto.QueryCounterLeft(const Site, Person,
  Workstation, Info: WideString): WideString;
var
SQLText : WideString;
begin
  //build query
  try
    SQLText :=
      ' select TIBarcode As Barcode'
    + ' from'
    + ' TrackedItem, TrackedEvents, EventType, TrackedStatus'
    + ' where'
    + ' TSItemId = TIBarcode'
    + ' and'
    + ' TEItemId = TIBarcode'
    + ' and'
    + ' TSEvent = TEEvent'
    + ' and'
    + ' ETOrder = TSEvent'
    + ' and'
    + ' ETName = ''CounterLeft'''
    + ' and'
    + ' TEInfo = ''' + Info + ''''

    + ' '
    + ' union'
    + ' select MOBarcode As Barcode'
    + ' from'
    + ' MoneyOrders, TrackedEvents, EventType, TrackedStatus'
    + ' where'
    + ' TSItemId = MOBarcode'
    + ' and'
    + ' TEItemId = MOBarcode'
    + ' and'
    + ' TSEvent = TEEvent'
    + ' and'
    + ' ETOrder = TSEvent'
    + ' and'
    + ' ETName = ''CounterLeft'''
    + ' and'
    + ' TEInfo = ''' + Info + '''';

    Result := QueryToCommaText(SQLText);
  except
    On E : Exception do
    begin
      RaiseException($13F,E);
      Result := '';
    end;
  end;

end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        ItemPrep
  Description   Logs a tracked item as placed in a prepared receptalce
  Params        const ItemId              : WideString - Item identification
                const PendingReceptacleId : WideString - Temporary i of receptacle being prepapred
                DateTime                  : TDateTime  - Date and Time of event
                Info                      : WideString - extra info for event
  Result        OperationStatus                        - status information (success)
________________________________________________________________________________}
function TDatabaseServerAuto.ItemPrep(const ItemId,
  PendingReceptacleId: WideString; DateTime: TDateTime;
  const Info: WideString): OperationStatus;
var
  Table : TTable;
  ReceptacleField : String;
begin
  try
    //update PendingReceptacle
    With DatabaseServerForm do
    begin
      Result := ValidItemSiteOperation(ItemId, otItemPrep);
      If Result <> osSuccess then
        Exit;
      try
        //determine item type
        Result := osSuccess;
        Case ItemType(ItemId) of
          itTrackedItem :
          begin
            Table := TrackedItemTable;
            ReceptacleField := 'TIReceptacle';
          end;

          itMoneyOrder :
          begin
            Table := MoneyOrderTable;
            ReceptacleField := 'MOReceptacle';
          end;

          else  //from case
          begin
            Table := nil;
            Result := osInvalidId;
          end;
        end;  //case

        //start a db transaction
        If Result = osSuccess then
        begin
          With Table do  //transaction isolation
          begin
            If Database.InTransaction = False then
            begin
              Database.TransIsolation := tiDirtyRead;
              Database.StartTransaction;
            end;

            //update pending receptacle id to item record
            Result := osDatabaseError;  //assume will be an error
            If Locate(GetIndexFieldString(Table),ItemId,[]) then  //found record
            begin
              Edit;
              FieldByName(ReceptacleField).AsString := PendingReceptacleId;
              Post;
              //log event
              If LogEvent(TransControlOff, ItemId, EventNumber('ItemPrep'), DateTime, Info, FSite) then
              begin
                Result := osSuccess
              end
              else
                Result := osDatabaseError;
            end;//  //if locate

            //commit transaction
            if Result = osSuccess then
            begin
              If Database.InTransaction then
                Database.Commit;
            end
            else
            begin
              If Database.InTransaction then
                Database.Rollback;
              Result := osDatabaseError;
            end;
          end;  //with Table
        end;  //if success

      except  //key viol indicates trying same item again!
        On E : Exception do
        begin
          RaiseException($140,E);
          If TrackedItemTable.Database.InTransaction then
            TrackedItemTable.Database.Rollback;
          Result := osDatabaseError;
        end;
      end;
    end;  //with Form
  except
    On E : Exception do
    begin
      RaiseException($141,E);
      Result := osUnexpected;
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        CheckReceptacle
  Description   Returns 2 lists of valid/invalid items for this site in a receptacle
  Params        const ReceptacleId        : WideString - Receptacle to check contents of
                var ValidItemsCommaText   : WideString - Nested commatext of item records (valid for this site)
                var InValidItemsCommaText : WideString - Nested commatext of item records (invalid for this site)
  Result        OperationStatus                        - status information (success)
________________________________________________________________________________}
function TDatabaseServerAuto.CheckReceptacle(
  const ReceptacleId: WideString; var ValidItemsCommaText,
  InvalidItemsCommaText: WideString): OperationStatus;
var
  CheckReceptacleQuery : TQuery;
  InvalidItems : TStringList;
  ValidItems : TStringList;
  SQLtext : String;
begin
  try
    ValidItems    := TStringList.Create;
    InvalidItems  := TStringList.Create;
    //build selection query
    CheckReceptacleQuery := TQuery.Create(nil);
    try
      SQLText := 'select TIBarCode As ItemId, TIDestPostCode As DestPostCode, TIReceptacle As Receptacle'
               + ' from TrackedItem, TrackedStatus, EventType'
               + ' where'
               + ' ETName = ''ItemLeft'''
               + ' and'
               + ' TSEvent = ETOrder'
               + ' and'
               + ' TSItemId = TIBarCode'
               + ' and'
               + ' TIReceptacle = ''' + ReceptacleId + ''''
               + ' '
               + ' union'
               + ' select MOBarCode As ItemId, MODestPostCode As DestPostCode, MOReceptacle'
               + ' from MoneyOrders, TrackedStatus, EventType'
               + ' where'
               + ' ETName = ''ItemLeft'''
               + ' and'
               + ' TSEvent = ETOrder'
               + ' and'
               + ' TSItemId = MOBarCode'
               + ' and'
               + ' MOReceptacle = ''' + ReceptacleId + '''';

      With CheckReceptacleQuery do
      begin
        Close;
        DatabaseName := FDataAlias;
        SQL.Text := SQLText;
        Open;
        First;
        //add to valid/invalid lists depending on Delivery PostCode
        While (not EOF) do
        begin
          If ValidateDeliveryPostCode(FieldByName('ItemId').AsString, FSite) then
          begin
            ValidItems.Add(FieldByName('ItemId').AsString);
          end
          else
          begin
            InvalidItems.Add(FieldByName('ItemId').AsString);
          end;  //if validatedeliverypostcode
          Next;
        end;  //while not eof
      end;  //with query

      ValidItemsCommaText := ValidItems.CommaText;
      InvalidItemsCommaText := InvalidItems.CommaText;

    finally
      ValidItems.Free;
      InvalidItems.Free;
      CheckReceptacleQuery.Free;
    end;
  except
    On E : Exception do
    begin
      RaiseGUIDException('{862FADFA-E307-4400-BF44-5E69E2D63FBF}',E);
      Result := osUnexpected;
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        ValidateDeliveryPostCode
  Description   Determines whether a delivery office is correct for a tracked item
  Params        ItemId          : WideString - Item identification
                DeliveryOffice  : WideString - Office Code
  Result        Boolean                      - office is correct
________________________________________________________________________________}
function TDatabaseServerAuto.ValidateDeliveryPostCode(ItemId : WideString; DeliveryOffice : WideString) : Boolean;
begin
  Result := True; //no rules implemented - assume correct office
end;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       Get_DataAlias
  Description  DataAlias property get function
  Params       None
  Result       WideString
________________________________________________________________________________}
function TDatabaseServerAuto.Get_DataAlias: WideString;
begin
  Result := FDataAlias;
end;

{===============================================================================
  Class        TDatabaseServerAuto
  Method       Set_DataAlias
  Description  DataAlias property set function
  Params       Value : WideString - new value for DataAlias property
  Result       None
________________________________________________________________________________}
procedure TDatabaseServerAuto.Set_DataAlias(const Value: WideString);
//var
//  OrigActive : Boolean;
begin
  try
    If FDataAlias <> Value then
    begin
      FDataAlias := Value;

      //Tracking tables
{      OrigActive := TrackedItemTable.Active;
      TrackedItemTable.Active := False;
      TrackedItemTable.DatabaseName := FDataAlias;
      TrackedItemTable.Active := OrigActive;

      OrigActive := ReceptacleTable.Active;
      ReceptacleTable.Active := False;
      ReceptacleTable.DatabaseName := FDataAlias;
      ReceptacleTable.Active := OrigActive;

      OrigActive := MoneyOrderTable.Active;
      MoneyOrderTable.Active := False;
      MoneyOrderTable.DatabaseName := FDataAlias;
      MoneyOrderTable.Active := OrigActive;

      OrigActive := TrackedStatusTable.Active;
      TrackedStatusTable.Active := False;
      TrackedStatusTable.DatabaseName := FDataAlias;
      TrackedStatusTable.Active := OrigActive;

      OrigActive := EventTypeTable.Active;
      EventTypeTable.Active := False;
      EventTypeTable.DatabaseName := FDataAlias;
      EventTypeTable.Active := OrigActive;

      OrigActive := TrackedEventTable.Active;
      TrackedEventTable.Active := False;
      TrackedEventTable.DatabaseName := FDataAlias;
      TrackedEventTable.Active := OrigActive;
}
    end;  //Alias changed
  except
    On E : Exception do
      RaiseGUIDException('{5A61A79D-601F-426A-AC6A-34A83C67B757}',E);
  end;
end;


{===============================================================================
  Class        TDatabaseServerAuto
  Method       Close
  Description  Closes active database tables
  Params       None
  Result       None
________________________________________________________________________________}
procedure TDatabaseServerAuto.Close;
begin
{  //free tables
  TrackedItemTable.Active := False  ;
  ReceptacleTable.Active := False    ;
  MoneyOrderTable.Active := False    ;
  TrackedStatusTable.Active := False ;
  EventTypeTable.Active := False     ;
  TrackedEventTable.Active := False  ;


  DatabaseServerForm.LogMemo.Lines.Add('Close Session ' + CurrentSession.SessionName);
  CurrentSession.Close;
}
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        ValidItemSiteOperation
  Description   Validates an event for a specific item and site
  Params        const ItemId  : WideString        - Item identification
                Operation     : OperationTypeEnum - Operation code
  Result        OPerationStatus                   - valid operation (osSuccess)
________________________________________________________________________________}
function TDatabaseServerAuto.ValidItemSiteOperation(
  const ItemId: WideString; Operation: OperationTypeEnum): OperationStatus;
begin

  try
    Result := osUnexpected;

    //run checks for each event and return result
    Case Operation Of
      otCustRecd :
      begin
        If not  ValidateItemId(ItemId)
        or not (ItemType(ItemId) in [itTrackedItem,itMoneyOrder] ) then Result := osInvalidId
        else If ItemExists(ItemId) then Result := osInvalidOperation //cant receive again
        else Result := osSuccess;
      end;  //custrecd

      otCounterLeft :
      begin
        If not (ItemStatus(ItemId) in [otCustRecd, otCounterLeft]) then Result := osInvalidOperation
        else Result := osSuccess
      end;

      otItemRecd :
      begin
        If not ValidateItemId(ItemId)
        or not (ItemType(ItemId)  in [itTrackedItem, itMoneyOrder]) then Result := osInvalidId
        else If not ItemExists(ItemId) then Result := osNotFound
        else If not (ItemStatus(ItemId) in [otCounterLeft]) then Result := osInvalidOperation
        else If not CorrectSite(ItemId) then Result := osInvalidSite
        else Result := osSuccess;
      end;

      otItemPrep :
      begin
        If not ValidateItemId(ItemId)
        or not (ItemType(ItemId) in [itTrackedItem, itMoneyOrder]) then Result := osInvalidId
        else If not ItemExists(ItemId) then Result := osNotFound
        else If not (ItemStatus(ItemId) in [otItemRecd, otItemPrep]) then Result := osInvalidOperation
        else If not CorrectSite(ItemId) then Result := osInvalidSite
        else Result := osSuccess;
      end;

      otItemLeft :
      begin
        If not ValidateItemId(ItemId)
        or not (ItemType(ItemId) in [itTrackedItem, itMoneyOrder]) then Result := osInvalidId
        else If not ItemExists(ItemId) then Result := osNotFound
        else If not (ItemStatus(ItemId) in [otItemPrep]) then  Result := osInvalidOperation
        else If not CorrectSite(ItemId) then Result := osInvalidSite
        else Result := osSuccess;
      end;

      otDelyRecd :
      begin
        If not ValidateItemId(ItemId) then Result := osInvalidId
        else If not ItemExists(ItemId) then Result := osNotFound
        else If  not  (ItemStatus(ItemId) in [otItemLeft, otProcLeft]) then  Result := osInvalidOperation
        else If not CorrectSite(ItemId)
        or not ValidateDeliveryPostCode(ItemId, FSite) then Result := osInvalidSite
        else Result := osSuccess;
      end;

      otRoundRecd :
      begin
        If not ValidateItemId(ItemId)
        or not (ItemType(ItemId) in [itTrackedItem, itMoneyOrder]) then Result := osInvalidId
        else If not ItemExists(ItemId) then Result := osNotFound
        else If  not (ItemStatus(ItemId) in [otDelyRecd, otUndelivered]) then Result := osInvalidOperation
        else If not CorrectSite(ItemId)
        or not ValidateDeliveryPostCode(ItemId, FSite) then Result := osInvalidSite
        else Result := osSuccess;
      end;

      otUnDelivered :
      begin
        If not ValidateItemId(ItemId)
        or not (ItemType(ItemId) in [itTrackedItem, itMoneyOrder]) then Result := osInvalidId
        else If not ItemExists(ItemId) then Result := osNotFound
        else If  not (ItemStatus(ItemId) in [otRoundRecd]) then Result := osInvalidOperation
        else If not CorrectSite(ItemId)
        or not ValidateDeliveryPostCode(ItemId, FSite) then Result := osInvalidSite
        else Result := osSuccess;
      end;

      otCustPickUp :
      begin
        If not ValidateItemId(ItemId)
        or not (ItemType(ItemId) in [itTrackedItem, itMoneyOrder]) then Result := osInvalidId
        else If not ItemExists(ItemId) then Result := osNotFound
        else If  not (ItemStatus(ItemId) in [otUnDelivered]) then Result := osInvalidOperation
        else If not CorrectSite(ItemId)
        or not ValidateDeliveryPostCode(ItemId, FSite) then Result := osInvalidSite
        else Result := osSuccess;
      end;

      otDelivered :
      begin
        If not ValidateItemId(ItemId)
        or not (ItemType(ItemId) in [itTrackedItem, itMoneyOrder]) then Result := osInvalidId
        else If not ItemExists(ItemId) then Result := osNotFound
        else If  not (ItemStatus(ItemId) in [otRoundRecd]) then Result := osInvalidOperation
        else If not CorrectSite(ItemId)
        or not ValidateDeliveryPostCode(ItemId, FSite) then Result := osInvalidSite
        else Result := osSuccess;
      end;

    else
      Result := osInvalidOperation;
    end;
  except
    On E : Exception do
    begin
      RaiseGUIDException('{A5A8FBD9-CDD2-47A2-A457-4C3DC91E6E18}',E);
      Result := osUnexpected;
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        UserNumberToId
  Description   Converts a user number to textual name
  Params        const UserNumber  : WideString  - User number identification
  Result        WideString                      - valid operation (osSuccess)
________________________________________________________________________________}
function TDatabaseServerAuto.UserNumberToId(
  const UserNumber: WideString): WideString;
//returns user name from id
var
  UserId          : Variant;
begin
  try
    //lookup user number
    With TrackUserTable do
    begin
      UserId := TrackUserTable.Lookup('TUUserNumber', UserNumber, 'TUUserId');
      If VarIsEmpty(UserId) then
        Result := UserNumber  //return user number if no name exists
      else
        Result := String(UserId);
    end;
  except
    On E : Exception do
    begin
      RaiseException($145,E);
      Result :='';
    end;
  end;

end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        QueryRoundRecd
  Description   Returns commatext of items received by round delivery person
  Params        const Site    : WideString - Site code of delivery office
                const Person  : WideString - Delivery person name
  Result        WideString                 - items id commtext
________________________________________________________________________________}
function TDatabaseServerAuto.QueryRoundRecd(const Site,
  Person: WideString): WideString;
var
  SQLText : WideString;
begin
  try
    //build query for the site and person
    SQLText :=
    ' select TIBarcode As Barcode'
    + ' from'
    + ' TrackedItem, TrackedEvents, EventType, TrackedStatus'
    + ' where'
    + ' TSItemId = TIBarcode'
    + ' and'
    + ' TEItemId = TIBarcode'
    + ' and'
    + ' TSEvent = TEEvent'
    + ' and'
    + ' TSDateTime = TEDateTime'
    + ' and'
    + ' ETOrder = TSEvent'
    + ' and'
    + ' ETName = ''RoundRecd'''
    + ' and'
    + ' TESite = ''' + Site + ''''
    + ' and'
    + ' TEPerson = ''' + Person + ''''
    + ' '
    + ' union'
    + ' select MOBarcode As Barcode'
    + ' from'
    + ' MoneyOrders, TrackedEvents, EventType, TrackedStatus'
    + ' where'
    + ' TSItemId = MOBarcode'
    + ' and'
    + ' TEItemId = MOBarcode'
    + ' and'
    + ' TSEvent = TEEvent'
    + ' and'
    + ' TSDateTime = TEDateTime'
    + ' and'
    + ' ETOrder = TSEvent'
    + ' and'
    + ' ETName = ''RoundRecd'''
    + ' and'
    + ' TESite = ''' + Site + ''''
    + ' and'
    + ' TEPerson = ''' + Person + '''';

    //return commatext
    Result := QueryToCommaText(SQLText);
  except
    On E : Exception do
    begin
      RaiseException($146,E);
      Result := '';
    end;
  end;

end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        CustPickUp
  Description   Logs item as help for customer pickup
  Params        const ItemId  : WideString  - Item identification
                DateTime      : TDateTime   - Date and Time of event
                Info          : WideString  - extra event info
  Result        OperationStatus             - status indicator (success)
________________________________________________________________________________}
function TDatabaseServerAuto.CustPickUp(const ItemId: WideString;
  DateTime: TDateTime; const Info: WideString): OperationStatus;
begin
  try
    Result := ValidItemSiteOperation(ItemId, otCustPickUp);
    If Result <> osSuccess then
      Exit;

    If not LogEvent(TransControlOn, ItemId, EventNumber('CustPickUp'), DateTime, Info, FSite) then
      Result := osDatabaseError
    else
      Result := osSuccess;
  except
    On E : Exception do
    begin
      RaiseException($147,E);
      Result := osUnexpected;
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        QueryUnDelivered
  Description   Returns commatext of item ids which are undelivered at a site
  Params        const Site : WideString  - Site code
  Result        WideString               - commatext list of undelivered items
________________________________________________________________________________}
function TDatabaseServerAuto.QueryUnDelivered(
  const Site: WideString): WideString;
var
  SQLText : WideString;
begin
  try
    //build query for site
    SQLText :=
    ' select TIBarcode As Barcode'
    + ' from'
    + ' TrackedItem, TrackedEvents, EventType, TrackedStatus'
    + ' where'
    + ' TSItemId = TIBarcode'
    + ' and'
    + ' TEItemId = TIBarcode'
    + ' and'
    + ' TSEvent = TEEvent'
    + ' and'
    + ' TSDateTime = TEDateTime'
    + ' and'
    + ' ETOrder = TSEvent'
    + ' and'
    + ' ETName = ''Undelivered'''
    + ' and'
    + ' TESite = ''' + Site + ''''
    + ' '
    + ' union'
    + ' select MOBarcode As Barcode'
    + ' from'
    + ' MoneyOrders, TrackedEvents, EventType, TrackedStatus'
    + ' where'
    + ' TSItemId = MOBarcode'
    + ' and'
    + ' TEItemId = MOBarcode'
    + ' and'
    + ' TSEvent = TEEvent'
    + ' and'
    + ' TSDateTime = TEDateTime'
    + ' and'
    + ' ETOrder = TSEvent'
    + ' and'
    + ' ETName = ''Undelivered'''
    + ' and'
    + ' TESite = ''' + Site + '''';

    //return commatext
    Result := QueryToCommaText(SQLText);
  except
    On E : Exception do
    begin
      RaiseException($148,E);
      Result := '';
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        QueryReturnedMoney
  Description   Returns commatext (single field) of money returned from a person for today
  Params        const Site    : WideString  - Site code
                const Person  : WideString  - Person name
  Result        WideString                  - single field commatext of money undelivered
________________________________________________________________________________}
function TDatabaseServerAuto.QueryReturnedMoney(const Site,
  Person: WideString): WideString;
var
  SQLText : String;
  Year    : Word;
  Month   : Word;
  Day     : Word;
begin
  try
    //get todays date into separate variables
    DecodeDate(Now,Year,Month,Day);
    //build query for the person at this site for today
    SQLText :=
       'select'
     + ' Sum(MOValue) As TotalAmount'
     + ' from'
     + ' MoneyOrders, TrackedStatus, TrackedEvents, EventType'
     + ' where'
     + ' TSItemId  = MOBarCode'
     + ' and'
     + ' TEItemId = TSItemId'
     + ' and'
     + ' TEEvent = TSEvent'
     + ' and'
     + ' TEDateTime = TSDateTime'
     + ' and'
     + ' TSEvent = ETOrder'
     + ' and'
     + ' ETName = ''Undelivered'''
     + ' and'
     + ' TESite = ''' + Site + ''''
     + ' and'
     + ' TEPerson = ''' + Person + ''''
     + ' and'
     + ' EXTRACT(YEAR FROM TSDateTime) = ' + IntToStr(Year)
     + ' and'
     + ' EXTRACT(MONTH FROM TSDateTime) = ' + IntToStr(Month)
     + ' and'
     + ' EXTRACT(Day FROM TSDateTime) = ' + IntToStr(Day)
     + ' group by TESite, TEPerson';

    //return money total
    Result := QueryToCommaText(SQLText);
  except
    On E : Exception do
    begin
      RaiseException($149,E);
      Result := '';
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        DenomBreakdown
  Description   Returns commatext of money denomination breakdown for given total
                Denominations defined in Denom.pas
  Params        Total : Integer   - total to be broken down into denominations
  Result        WideString        - commatext of denomination breakdown
________________________________________________________________________________}
function TDatabaseServerAuto.DenomBreakDown(Total: Integer): WideString;
var
  DenomIndex  : TDenom;
  DenomArray  : Array[dn1..dn10000] of Integer;
  DenomStringList : TStringList;
begin

  try
    If Total = 0 then
    begin
      Result := '';
    end
    else
    begin
      DenomStringList := TStringList.Create;
      try
        //zero array
        For DenomIndex := dn1 to dn10000 do
        begin
          DenomArray[DenomIndex] := DenomValues[DenomIndex];
        end;

        //calc denoms reqd for total
        CalcDenoms(Total,DenomArray);

        //build stringlist for commatext
        DenomStringList.Clear;
        For DenomIndex := High(DenomArray) downto Low(DenomArray) do
        begin
          If DenomArray[DenomIndex] <> -1 then
          begin
            DenomStringList.Add(IntToStr(DenomArray[DenomIndex]));
          end
          else
          begin
            DenomStringList.Add('');
          end;
        end;
        //return commatext
        Result := DenomStringList.CommaText;
      finally
        DenomStringList.Free;
      end;
    end;
  except
    On E : Exception do
    begin
      RaiseException($14A,E);
      Result := '';
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        TransferRecords
  Description   Transfers records from one machine to another
  Params        const SourceMachineName : WideString  - name of source machine, eg, '\\MACH1'
                const SourceAlias       : WideString  - name of source database alias
                const DestMachineName   : WideString  - nane of destination machine
                const DestAlias         : WideString  - name of destination datasbase alias
                DestTable               : WideString  - name of destination table
                SQLQueryText            : WideString  - SQL to select records on source machine
                AdjustOnly              : Boolean     - True  if destination records are adjusted/added by value of source records
                                                      - False if destination records are overwritten or added
  Result        WordBool                              - success indicator
________________________________________________________________________________}
function TDatabaseServerAuto.TransferRecords(const SourceMachineName,
  SourceAlias, DestMachineName, DestAlias, DestTable,
  SQLQueryText: WideString; AdjustOnly: WordBool): WordBool;
var
  SourceDatabaseServer, DestDatabaseServer : IDatabaseServerAuto;
begin
  try
    //creates (D)COM objects (forces creation from server on named machine
    //- does NOT use a local server even if one is already initialised (as per CreateRemote
    SourceDatabaseServer := CreateActualRemoteComObject(SourceMachineName,Class_DatabaseServerAuto) As IDatabaseServerAuto;
    DestDatabaseServer := CreateActualRemoteComObject(DestMachineName, Class_DatabaseServerAuto) As IDatabaseServerAuto ;
    try
      //setup alias
      SourceDatabaseServer.DataAlias := SourceAlias;
      DestDatabaseServer.DataAlias := DestAlias;
      SourceDatabaseServer.DestServer := DestDatabaseServer;
      Result := SourceDatabaseServer.SendRecords(DestTable,SQLQueryText,AdjustOnly);
    finally
      SourceDatabaseServer  := nil;
      DestDatabaseServer    := nil;
    end;
  except
    On E : Exception do
    begin
      RaiseException($14B,E);
      Result := False;
    end;
  end;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        Get_HookUp
  Description   HookUp property get function
  Params        None
  Result        IDispatch - reference to hookup instance
________________________________________________________________________________}
function TDatabaseServerAuto.Get_HookUp: IDispatch;
begin
  Result := FHookUp AS IDispatch;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        Set_HookUp
  Description   HookUp property set function
  Params        Value : IDispatch - reference to hookup instance
  Result        None
________________________________________________________________________________}
procedure TDatabaseServerAuto.Set_HookUp(Value: IDispatch);
begin
  FHookUp := Value AS IHookUp;
end;

{===============================================================================
  Class         TDatabaseServerAuto
  Method        TransferRecordsHookUp
  Description   Transfers records to server using hookup
  Params        const SourceAlias       : WideString  - name of source database alias
                const DestAlias         : WideString  - name of destination datasbase alias
                DestTable               : WideString  - name of destination table
                SQLQueryText            : WideString  - SQL to select records on source machine
                AdjustOnly              : Boolean     - True  if destination records are adjusted/added by value of source records
                                                      - False if destination records are overwritten or added
  Result        WordBool                              - success indicator
________________________________________________________________________________}
function TDatabaseServerAuto.TransferRecordsHookUp(const SourceAlias,
  DestAlias, DestTable, SQLQueryText: WideString;
  AdjustOnly: WordBool): WordBool;
var
  SourceDatabaseServer, DestDatabaseServer : IDatabaseServerAuto;
begin
  try
    //creates (D)COM objects (forces creation from server on named machine
    //- does NOT use a local server even if one is already initialised (as per CreateRemote
    If FHookUp = nil then Exit;

    SourceDatabaseServer := CreateComObject(Class_DatabaseServerAuto) As IDatabaseServerAuto;
    DestDatabaseServer := FHookUp.DatabaseServer As IDatabaseServerAuto;
    try
      //setup alias
      SourceDatabaseServer.DataAlias := SourceAlias;
      DestDatabaseServer.DataAlias := DestAlias;
      SourceDatabaseServer.DestServer := DestDatabaseServer;
      Result := SourceDatabaseServer.SendRecords(DestTable,SQLQueryText,AdjustOnly);
    finally
      SourceDatabaseServer  := nil;
      DestDatabaseServer    := nil;
    end;
  except
    On E : Exception do
    begin
      RaiseException($14C,E);
      Result := False;
    end;
  end;
end;

Initialization
  TAutoObjectFactory.Create(ComServer, TDatabaseServerAuto, Class_DatabaseServerAuto, ciMultiInstance);
end.
