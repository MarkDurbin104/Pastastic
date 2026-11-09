unit DatabaseServer_TLB;

{ This file contains pascal declarations imported from a type library.
  This file will be written during each import or refresh of the type
  library editor.  Changes to this file will be discarded during the
  refresh process. }

{ GPCS DatabaseServer Library }
{ Version 1.0 }

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

const
  LIBID_DatabaseServer: TGUID = '{A214D344-3848-11D2-8590-00A024B01373}';

const

{ Status code from operation }

{ OperationStatus }

  osSuccess = 0;
  osDatabaseError = 1;
  osNotFound = 2;
  osInvalidOperation = 3;
  osInvalidSite = 4;
  osInvalidId = 5;
  osUnexpected = 999;

{ Tracked item types }

{ ItemTypeEnum }

  itTrackedItem = 0;
  itMoneyOrder = 1;
  itReceptacle = 2;
  itUnknown = 999;

{ Operation Types }

{ OperationTypeEnum }

  otCustRecd = 10;
  otCounterLeft = 20;
  otItemRecd = 30;
  otItemPrep = 35;
  otItemLeft = 40;
  otProcRecd = 50;
  otProcLeft = 60;
  otDelyRecd = 70;
  otRoundRecd = 80;
  otUnDelivered = 90;
  otCustPickUp = 95;
  otDelivered = 100;

const

{ Component class GUIDs }
  Class_DatabaseServerAuto: TGUID = '{A214D346-3848-11D2-8590-00A024B01373}';

type

{ Forward declarations: Interfaces }
  IDatabaseServerAuto = interface;
  IDatabaseServerAutoDisp = dispinterface;

{ Forward declarations: CoClasses }
  DatabaseServerAuto = IDatabaseServerAuto;

{ Forward declarations: Enums }
  OperationStatus = TOleEnum;
  ItemTypeEnum = TOleEnum;
  OperationTypeEnum = TOleEnum;

{ Dispatch interface for DatabaseServerAuto Object }

  IDatabaseServerAuto = interface(IDispatch)
    ['{A214D345-3848-11D2-8590-00A024B01373}']
    function Get_DataAlias: WideString; safecall;
    procedure Set_DataAlias(const Value: WideString); safecall;
    function Get_Site: WideString; safecall;
    procedure Set_Site(const Value: WideString); safecall;
    function Get_Person: WideString; safecall;
    procedure Set_Person(const Value: WideString); safecall;
    function Get_Workstation: WideString; safecall;
    procedure Set_Workstation(const Value: WideString); safecall;
    function Get_DestServer: IDatabaseServerAuto; safecall;
    procedure Set_DestServer(const Value: IDatabaseServerAuto); safecall;
    function CustRecd(const ItemId: WideString; DateTime: TDateTime; Weight, Value: Double; const DestPostCode, Info: WideString): OperationStatus; safecall;
    function CounterLeft(DateTime: TDateTime; const Unique: WideString): OperationStatus; safecall;
    function ItemRecd(const ItemId: WideString; DateTime: TDateTime; const Info: WideString): OperationStatus; safecall;
    function ItemPrep(const ItemId, PendingReceptacleId: WideString; DateTime: TDateTime; const Info: WideString): OperationStatus; safecall;
    function SealReceptacle(const PendingReceptacleId, ActualReceptacleId: WideString; NumberOfUntrackedMoneyOrders: Integer; DateTime: TDateTime; const Info, ProcSite: WideString): OperationStatus; safecall;
    function ProcRecd(const ItemId: WideString; DateTime: TDateTime; const Info: WideString): OperationStatus; safecall;
    function ProcLeft(const ItemId: WideString; DateTime: TDateTime; const Info, NextSite: WideString): OperationStatus; safecall;
    function DelyRecd(const ItemId: WideString; DateTime: TDateTime; const Info: WideString): OperationStatus; safecall;
    function RoundRecd(const ItemId: WideString; DateTime: TDateTime; const Info: WideString): OperationStatus; safecall;
    function Undelivered(const ItemId: WideString; DateTime: TDateTime; const Info: WideString): OperationStatus; safecall;
    function CustPickUp(const ItemId: WideString; DateTime: TDateTime; const Info: WideString): OperationStatus; safecall;
    function Delivered(const ItemId: WideString; DateTime: TDateTime; const Info: WideString): OperationStatus; safecall;
    function CDV(const NumberString: WideString): Integer; safecall;
    function ValidateItemId(const ItemId: WideString): WordBool; safecall;
    function ValidItemSiteOperation(const ItemId: WideString; Operation: OperationTypeEnum): OperationStatus; safecall;
    function QueryCurrentStatus(const ItemId: WideString): WideString; safecall;
    function QueryCounterLeft(const Site, Person, Workstation, Info: WideString): WideString; safecall;
    function QueryRoundRecd(const Site, Person: WideString): WideString; safecall;
    function QueryUnDelivered(const Site: WideString): WideString; safecall;
    function QueryReturnedMoney(const Site, Person: WideString): WideString; safecall;
    function QueryToCommaText(const SQLQueryText: WideString): WideString; safecall;
    function DenomBreakDown(Total: Integer): WideString; safecall;
    function SendRecords(const TableName, SQLQuery: WideString; AdjustOnly: WordBool): WordBool; safecall;
    function ReceiveRecords(const RecordsMessage: WideString; AdjustOnly: WordBool): WordBool; safecall;
    function ExecSQL(const SQLText: WideString): WordBool; safecall;
    procedure ClearAllTables; safecall;
    function CheckReceptacle(const ReceptacleId: WideString; var ValidItemsCommaText, InvalidItemsCommaText: WideString): OperationStatus; safecall;
    procedure Close; safecall;
    function UserNumberToId(const UserNumber: WideString): WideString; safecall;
    function TransferRecords(const SourceMachineName, SourceAlias, DestMachineName, DestAlias, DestTable, SQLQueryText: WideString; AdjustOnly: WordBool): WordBool; safecall;
    function TransferRecordsHookUp(const SourceAlias, DestAlias, DestTable, SQLQueryText: WideString; AdjustOnly: WordBool): WordBool; safecall;
    function Get_HookUp: IDispatch; safecall;
    procedure Set_HookUp(Value: IDispatch); safecall;
    property DataAlias: WideString read Get_DataAlias write Set_DataAlias;
    property Site: WideString read Get_Site write Set_Site;
    property Person: WideString read Get_Person write Set_Person;
    property Workstation: WideString read Get_Workstation write Set_Workstation;
    property DestServer: IDatabaseServerAuto read Get_DestServer write Set_DestServer;
    property HookUp: IDispatch read Get_HookUp write Set_HookUp;
  end;

{ DispInterface declaration for Dual Interface IDatabaseServerAuto }

  IDatabaseServerAutoDisp = dispinterface
    ['{A214D345-3848-11D2-8590-00A024B01373}']
    property DataAlias: WideString dispid 5;
    property Site: WideString dispid 6;
    property Person: WideString dispid 7;
    property Workstation: WideString dispid 8;
    property DestServer: IDatabaseServerAuto dispid 9;
    function CustRecd(const ItemId: WideString; DateTime: TDateTime; Weight, Value: Double; const DestPostCode, Info: WideString): OperationStatus; dispid 10;
    function CounterLeft(DateTime: TDateTime; const Unique: WideString): OperationStatus; dispid 11;
    function ItemRecd(const ItemId: WideString; DateTime: TDateTime; const Info: WideString): OperationStatus; dispid 12;
    function ItemPrep(const ItemId, PendingReceptacleId: WideString; DateTime: TDateTime; const Info: WideString): OperationStatus; dispid 13;
    function SealReceptacle(const PendingReceptacleId, ActualReceptacleId: WideString; NumberOfUntrackedMoneyOrders: Integer; DateTime: TDateTime; const Info, ProcSite: WideString): OperationStatus; dispid 14;
    function ProcRecd(const ItemId: WideString; DateTime: TDateTime; const Info: WideString): OperationStatus; dispid 15;
    function ProcLeft(const ItemId: WideString; DateTime: TDateTime; const Info, NextSite: WideString): OperationStatus; dispid 16;
    function DelyRecd(const ItemId: WideString; DateTime: TDateTime; const Info: WideString): OperationStatus; dispid 17;
    function RoundRecd(const ItemId: WideString; DateTime: TDateTime; const Info: WideString): OperationStatus; dispid 18;
    function Undelivered(const ItemId: WideString; DateTime: TDateTime; const Info: WideString): OperationStatus; dispid 20;
    function CustPickUp(const ItemId: WideString; DateTime: TDateTime; const Info: WideString): OperationStatus; dispid 4;
    function Delivered(const ItemId: WideString; DateTime: TDateTime; const Info: WideString): OperationStatus; dispid 19;
    function CDV(const NumberString: WideString): Integer; dispid 21;
    function ValidateItemId(const ItemId: WideString): WordBool; dispid 22;
    function ValidItemSiteOperation(const ItemId: WideString; Operation: OperationTypeEnum): OperationStatus; dispid 1;
    function QueryCurrentStatus(const ItemId: WideString): WideString; dispid 23;
    function QueryCounterLeft(const Site, Person, Workstation, Info: WideString): WideString; dispid 24;
    function QueryRoundRecd(const Site, Person: WideString): WideString; dispid 3;
    function QueryUnDelivered(const Site: WideString): WideString; dispid 31;
    function QueryReturnedMoney(const Site, Person: WideString): WideString; dispid 32;
    function QueryToCommaText(const SQLQueryText: WideString): WideString; dispid 34;
    function DenomBreakDown(Total: Integer): WideString; dispid 33;
    function SendRecords(const TableName, SQLQuery: WideString; AdjustOnly: WordBool): WordBool; dispid 25;
    function ReceiveRecords(const RecordsMessage: WideString; AdjustOnly: WordBool): WordBool; dispid 26;
    function ExecSQL(const SQLText: WideString): WordBool; dispid 27;
    procedure ClearAllTables; dispid 28;
    function CheckReceptacle(const ReceptacleId: WideString; var ValidItemsCommaText, InvalidItemsCommaText: WideString): OperationStatus; dispid 29;
    procedure Close; dispid 30;
    function UserNumberToId(const UserNumber: WideString): WideString; dispid 2;
    function TransferRecords(const SourceMachineName, SourceAlias, DestMachineName, DestAlias, DestTable, SQLQueryText: WideString; AdjustOnly: WordBool): WordBool; dispid 35;
    function TransferRecordsHookUp(const SourceAlias, DestAlias, DestTable, SQLQueryText: WideString; AdjustOnly: WordBool): WordBool; dispid 36;
    property HookUp: IDispatch dispid 37;
  end;

{ GPCS DatabaseServerAutoObject }

  CoDatabaseServerAuto = class
    class function Create: IDatabaseServerAuto;
    class function CreateRemote(const MachineName: string): IDatabaseServerAuto;
  end;



implementation

uses ComObj;

class function CoDatabaseServerAuto.Create: IDatabaseServerAuto;
begin
  Result := CreateComObject(Class_DatabaseServerAuto) as IDatabaseServerAuto;
end;

class function CoDatabaseServerAuto.CreateRemote(const MachineName: string): IDatabaseServerAuto;
begin
  Result := CreateRemoteComObject(MachineName, Class_DatabaseServerAuto) as IDatabaseServerAuto;
end;


end.
