unit AssetManager_TLB;

{ This file contains pascal declarations imported from a type library.
  This file will be written during each import or refresh of the type
  library editor.  Changes to this file will be discarded during the
  refresh process. }

{ AssetManager Library }
{ Version 1.0 }

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

const
  LIBID_AssetManager: TGUID = '{EDDDF122-59C4-11D2-8A2F-00A024B01373}';

const

{ AMStatus }

  amSuccess = 0;
  amDuplicate = 1;
  amUnexpected = 2;
  amCircular = 3;

const

{ Component class GUIDs }
  Class_AssetManager: TGUID = '{EDDDF124-59C4-11D2-8A2F-00A024B01373}';
  Class_Asset: TGUID = '{A9431892-2D64-11D3-8C19-00A024B01373}';
  Class_AssetEntry: TGUID = '{A9431893-2D64-11D3-8C19-00A024B01373}';
  Class_AssetQuantity: TGUID = '{A9431894-2D64-11D3-8C19-00A024B01373}';
  Class_AssetUnit: TGUID = '{A9431895-2D64-11D3-8C19-00A024B01373}';
  Class_AssetOwner: TGUID = '{A9431896-2D64-11D3-8C19-00A024B01373}';
  Class_AssetModel: TGUID = '{A9431897-2D64-11D3-8C19-00A024B01373}';
  Class_AssetTrigger: TGUID = '{7B5B4612-2308-11D3-8BFD-00A024B01373}';

type

{ Forward declarations: Interfaces }
  IAssetManager = interface;
  IAssetManagerDisp = dispinterface;
  IAssetManaged = interface;
  IAssetManagedDisp = dispinterface;
  IAssetBase = interface;
  IAssetBaseDisp = dispinterface;
  IAsset = interface;
  IAssetDisp = dispinterface;
  IAssetEntry = interface;
  IAssetEntryDisp = dispinterface;
  IAssetQuantity = interface;
  IAssetQuantityDisp = dispinterface;
  IAssetUnit = interface;
  IAssetUnitDisp = dispinterface;
  IAssetOwner = interface;
  IAssetOwnerDisp = dispinterface;
  IAssetModel = interface;
  IAssetModelDisp = dispinterface;
  IAssetTimePoint = interface;
  IAssetTimePointDisp = dispinterface;
  IAssetTrigger = interface;
  IAssetTriggerDisp = dispinterface;

{ Forward declarations: CoClasses }
  AssetManager = IAssetManager;
  Asset = IAsset;
  AssetEntry = IAssetEntry;
  AssetQuantity = IAssetQuantity;
  AssetUnit = IAssetUnit;
  AssetOwner = IAssetOwner;
  AssetModel = IAssetModel;
  AssetTrigger = IAssetTrigger;

{ Forward declarations: Enums }
  AMStatus = TOleEnum;

{ Dispatch interface for GPCSAccountManager Object }

  IAssetManager = interface(IDispatch)
    ['{EDDDF123-59C4-11D2-8A2F-00A024B01373}']
    function Get_Asset(const AssetCode: WideString): IAsset; safecall;
    function Get_Alias: WideString; safecall;
    procedure Set_Alias(const Value: WideString); safecall;
    function Get_Site: WideString; safecall;
    procedure Set_Site(const Value: WideString); safecall;
    function Get_Workstation: WideString; safecall;
    procedure Set_Workstation(const Value: WideString); safecall;
    function Get_AssetModels(const ModelName: WideString): IAssetModel; safecall;
    function Get_Owners(const OwnerName: WideString): IAssetOwner; safecall;
    function Get_Person: IAssetOwner; safecall;
    procedure Set_Person(const Value: IAssetOwner); safecall;
    function Get_Period: Integer; safecall;
    procedure Set_Period(Value: Integer); safecall;
    function Get_Trigger(const Code: WideString): IAssetTrigger; safecall;
    function AddAssetEntry(const Asset: WideString; const Quantity: IAssetQuantity): AMStatus; safecall;
    function AdjustSingleAsset(const Asset: IAsset; const Quantity: IAssetQuantity): AMStatus; safecall;
    function AssetByCode(const Code: WideString): IAsset; safecall;
    function AssetChildren(const AccountGroup: WideString): WideString; safecall;
    function AssetParents(const Asset: WideString): WideString; safecall;
    function AssetParentHierarchy(const Asset: IAsset): WideString; safecall;
    function AssetTotalCommaText(const ParentGroup: WideString): WideString; safecall;
    function CloseModel(const ModelFileName: WideString): AMStatus; safecall;
    function CreateAssetQuantity(Amount: Currency; const UnitsName: WideString): IAssetQuantity; safecall;
    function IsAParent(const ParentCandidate: WideString): WordBool; safecall;
    function OpenModel(const ModelFileName: WideString): AMStatus; safecall;
    function QueryToCommaText(const SQLQueryText: WideString): WideString; safecall;
    function Reset: AMStatus; safecall;
    function TransferStock(const SourceStockUnit, DestStockUnit, StockCommaTExt: WideString): AMStatus; safecall;
    property Asset[const AssetCode: WideString]: IAsset read Get_Asset;
    property Alias: WideString read Get_Alias write Set_Alias;
    property Site: WideString read Get_Site write Set_Site;
    property Workstation: WideString read Get_Workstation write Set_Workstation;
    property AssetModels[const ModelName: WideString]: IAssetModel read Get_AssetModels;
    property Owners[const OwnerName: WideString]: IAssetOwner read Get_Owners;
    property Person: IAssetOwner read Get_Person write Set_Person;
    property Period: Integer read Get_Period write Set_Period;
    property Trigger[const Code: WideString]: IAssetTrigger read Get_Trigger;
  end;

{ DispInterface declaration for Dual Interface IAssetManager }

  IAssetManagerDisp = dispinterface
    ['{EDDDF123-59C4-11D2-8A2F-00A024B01373}']
    property Asset[const AssetCode: WideString]: IAsset readonly dispid 18;
    property Alias: WideString dispid 9;
    property Site: WideString dispid 2;
    property Workstation: WideString dispid 3;
    property AssetModels[const ModelName: WideString]: IAssetModel readonly dispid 23;
    property Owners[const OwnerName: WideString]: IAssetOwner readonly dispid 20;
    property Person: IAssetOwner dispid 4;
    property Period: Integer dispid 8;
    property Trigger[const Code: WideString]: IAssetTrigger readonly dispid 19;
    function AddAssetEntry(const Asset: WideString; const Quantity: IAssetQuantity): AMStatus; dispid 6;
    function AdjustSingleAsset(const Asset: IAsset; const Quantity: IAssetQuantity): AMStatus; dispid 5;
    function AssetByCode(const Code: WideString): IAsset; dispid 17;
    function AssetChildren(const AccountGroup: WideString): WideString; dispid 14;
    function AssetParents(const Asset: WideString): WideString; dispid 12;
    function AssetParentHierarchy(const Asset: IAsset): WideString; dispid 1;
    function AssetTotalCommaText(const ParentGroup: WideString): WideString; dispid 13;
    function CloseModel(const ModelFileName: WideString): AMStatus; dispid 21;
    function CreateAssetQuantity(Amount: Currency; const UnitsName: WideString): IAssetQuantity; dispid 22;
    function IsAParent(const ParentCandidate: WideString): WordBool; dispid 16;
    function OpenModel(const ModelFileName: WideString): AMStatus; dispid 15;
    function QueryToCommaText(const SQLQueryText: WideString): WideString; dispid 11;
    function Reset: AMStatus; dispid 7;
    function TransferStock(const SourceStockUnit, DestStockUnit, StockCommaTExt: WideString): AMStatus; dispid 10;
  end;

{ Asset Managed objects }

  IAssetManaged = interface(IDispatch)
    ['{895B8EB2-27B9-11D3-8C0C-00A024B01373}']
    function Get_Manager: IAssetManager; safecall;
    procedure Set_Manager(const Value: IAssetManager); safecall;
    property Manager: IAssetManager read Get_Manager write Set_Manager;
  end;

{ DispInterface declaration for Dual Interface IAssetManaged }

  IAssetManagedDisp = dispinterface
    ['{895B8EB2-27B9-11D3-8C0C-00A024B01373}']
    property Manager: IAssetManager dispid 6;
  end;

{ Base for Assets, AssetEntries }

  IAssetBase = interface(IAssetManaged)
    ['{895B8EB3-27B9-11D3-8C0C-00A024B01373}']
    function Get_Code: WideString; safecall;
    procedure Set_Code(const Value: WideString); safecall;
    function Get_Description: WideString; safecall;
    procedure Set_Description(const Value: WideString); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    property Code: WideString read Get_Code write Set_Code;
    property Description: WideString read Get_Description write Set_Description;
    property Name: WideString read Get_Name write Set_Name;
  end;

{ DispInterface declaration for Dual Interface IAssetBase }

  IAssetBaseDisp = dispinterface
    ['{895B8EB3-27B9-11D3-8C0C-00A024B01373}']
    property Manager: IAssetManager dispid 6;
    property Code: WideString dispid 8;
    property Description: WideString dispid 9;
    property Name: WideString dispid 10;
  end;

{ Asset article }

  IAsset = interface(IAssetBase)
    ['{01065D02-2558-11D3-8C06-00A024B01373}']
    function Get_Balance: IAssetQuantity; safecall;
    procedure Set_Balance(const Value: IAssetQuantity); safecall;
    function Get_Owner: IAssetOwner; safecall;
    procedure Set_Owner(const Value: IAssetOwner); safecall;
    property Balance: IAssetQuantity read Get_Balance write Set_Balance;
    property Owner: IAssetOwner read Get_Owner write Set_Owner;
  end;

{ DispInterface declaration for Dual Interface IAsset }

  IAssetDisp = dispinterface
    ['{01065D02-2558-11D3-8C06-00A024B01373}']
    property Manager: IAssetManager dispid 6;
    property Code: WideString dispid 8;
    property Description: WideString dispid 9;
    property Name: WideString dispid 10;
    property Balance: IAssetQuantity dispid 3;
    property Owner: IAssetOwner dispid 4;
  end;

{ Individual Asset entry }

  IAssetEntry = interface(IAssetBase)
    ['{01065D05-2558-11D3-8C06-00A024B01373}']
    function Get_AssetQuantity: IAssetQuantity; safecall;
    procedure Set_AssetQuantity(const Value: IAssetQuantity); safecall;
    function Get_Creator: IAssetOwner; safecall;
    procedure Set_Creator(const Value: IAssetOwner); safecall;
    function Get_Person: IAssetOwner; safecall;
    procedure Set_Person(const Value: IAssetOwner); safecall;
    function Get_Period: Integer; safecall;
    procedure Set_Period(Value: Integer); safecall;
    function Get_Site: WideString; safecall;
    procedure Set_Site(const Value: WideString); safecall;
    function Get_Workstation: WideString; safecall;
    procedure Set_Workstation(const Value: WideString); safecall;
    function Log: AMStatus; safecall;
    property AssetQuantity: IAssetQuantity read Get_AssetQuantity write Set_AssetQuantity;
    property Creator: IAssetOwner read Get_Creator write Set_Creator;
    property Person: IAssetOwner read Get_Person write Set_Person;
    property Period: Integer read Get_Period write Set_Period;
    property Site: WideString read Get_Site write Set_Site;
    property Workstation: WideString read Get_Workstation write Set_Workstation;
  end;

{ DispInterface declaration for Dual Interface IAssetEntry }

  IAssetEntryDisp = dispinterface
    ['{01065D05-2558-11D3-8C06-00A024B01373}']
    property Manager: IAssetManager dispid 6;
    property Code: WideString dispid 8;
    property Description: WideString dispid 9;
    property Name: WideString dispid 10;
    property AssetQuantity: IAssetQuantity dispid 13;
    property Creator: IAssetOwner dispid 14;
    property Person: IAssetOwner dispid 15;
    property Period: Integer dispid 16;
    property Site: WideString dispid 17;
    property Workstation: WideString dispid 18;
    function Log: AMStatus; dispid 19;
  end;

{ Asset level measurement }

  IAssetQuantity = interface(IDispatch)
    ['{01065D03-2558-11D3-8C06-00A024B01373}']
    function Get_Amount: Currency; safecall;
    procedure Set_Amount(Value: Currency); safecall;
    function Get_Units: IAssetUnit; safecall;
    procedure Set_Units(const Value: IAssetUnit); safecall;
    function ConvertTo(const AssetUnit: IAssetUnit): Currency; safecall;
    property Amount: Currency read Get_Amount write Set_Amount;
    property Units: IAssetUnit read Get_Units write Set_Units;
  end;

{ DispInterface declaration for Dual Interface IAssetQuantity }

  IAssetQuantityDisp = dispinterface
    ['{01065D03-2558-11D3-8C06-00A024B01373}']
    property Amount: Currency dispid 1;
    property Units: IAssetUnit dispid 2;
    function ConvertTo(const AssetUnit: IAssetUnit): Currency; dispid 3;
  end;

{ Asset measurement units }

  IAssetUnit = interface(IDispatch)
    ['{01065D04-2558-11D3-8C06-00A024B01373}']
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function Get_Exchange: Currency; safecall;
    procedure Set_Exchange(Value: Currency); safecall;
    property Name: WideString read Get_Name write Set_Name;
    property Exchange: Currency read Get_Exchange write Set_Exchange;
  end;

{ DispInterface declaration for Dual Interface IAssetUnit }

  IAssetUnitDisp = dispinterface
    ['{01065D04-2558-11D3-8C06-00A024B01373}']
    property Name: WideString dispid 1;
    property Exchange: Currency dispid 2;
  end;

{ Owner of assets }

  IAssetOwner = interface(IDispatch)
    ['{01065D06-2558-11D3-8C06-00A024B01373}']
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function Get_Parent: IAssetOwner; safecall;
    procedure Set_Parent(const Value: IAssetOwner); safecall;
    function Get_Site: WideString; safecall;
    procedure Set_Site(const Value: WideString); safecall;
    property Name: WideString read Get_Name write Set_Name;
    property Parent: IAssetOwner read Get_Parent write Set_Parent;
    property Site: WideString read Get_Site write Set_Site;
  end;

{ DispInterface declaration for Dual Interface IAssetOwner }

  IAssetOwnerDisp = dispinterface
    ['{01065D06-2558-11D3-8C06-00A024B01373}']
    property Name: WideString dispid 1;
    property Parent: IAssetOwner dispid 2;
    property Site: WideString dispid 3;
  end;

  IAssetModel = interface(IAssetManaged)
    ['{50B5DF42-256D-11D3-8C06-00A024B01373}']
    function Get_FileName: WideString; safecall;
    procedure LoadFromFile(const FileName: WideString); safecall;
    function LogAssetEntry(const AssetEntry: IAssetEntry): AMStatus; safecall;
    procedure SaveToFile(const FileName: WideString); safecall;
    property FileName: WideString read Get_FileName;
  end;

{ DispInterface declaration for Dual Interface IAssetModel }

  IAssetModelDisp = dispinterface
    ['{50B5DF42-256D-11D3-8C06-00A024B01373}']
    property Manager: IAssetManager dispid 6;
    property FileName: WideString readonly dispid 1;
    procedure LoadFromFile(const FileName: WideString); dispid 2;
    function LogAssetEntry(const AssetEntry: IAssetEntry): AMStatus; dispid 3;
    procedure SaveToFile(const FileName: WideString); dispid 4;
  end;

  IAssetTimePoint = interface(IDispatch)
    ['{69276692-258A-11D3-8C09-00A024B01373}']
  end;

{ DispInterface declaration for Dual Interface IAssetTimePoint }

  IAssetTimePointDisp = dispinterface
    ['{69276692-258A-11D3-8C09-00A024B01373}']
  end;

{ Dispatch interface for AssetTrigger Object }

  IAssetTrigger = interface(IDispatch)
    ['{7B5B4611-2308-11D3-8BFD-00A024B01373}']
    procedure AddParam(const ParamName: WideString; ParamValue: OleVariant); safecall;
    function TriggerValue(Value: Double): Double; safecall;
    function Get_TriggerCode: WideString; safecall;
    function Get_Code: WideString; safecall;
    property TriggerCode: WideString read Get_TriggerCode;
    property Code: WideString read Get_Code;
  end;

{ DispInterface declaration for Dual Interface IAssetTrigger }

  IAssetTriggerDisp = dispinterface
    ['{7B5B4611-2308-11D3-8BFD-00A024B01373}']
    procedure AddParam(const ParamName: WideString; ParamValue: OleVariant); dispid 1;
    function TriggerValue(Value: Double): Double; dispid 2;
    property TriggerCode: WideString readonly dispid 3;
    property Code: WideString readonly dispid 4;
  end;

{ GPCS Account Manager Object }

  CoAssetManager = class
    class function Create: IAssetManager;
    class function CreateRemote(const MachineName: string): IAssetManager;
  end;

  CoAsset = class
    class function Create: IAsset;
    class function CreateRemote(const MachineName: string): IAsset;
  end;

  CoAssetEntry = class
    class function Create: IAssetEntry;
    class function CreateRemote(const MachineName: string): IAssetEntry;
  end;

  CoAssetQuantity = class
    class function Create: IAssetQuantity;
    class function CreateRemote(const MachineName: string): IAssetQuantity;
  end;

  CoAssetUnit = class
    class function Create: IAssetUnit;
    class function CreateRemote(const MachineName: string): IAssetUnit;
  end;

  CoAssetOwner = class
    class function Create: IAssetOwner;
    class function CreateRemote(const MachineName: string): IAssetOwner;
  end;

  CoAssetModel = class
    class function Create: IAssetModel;
    class function CreateRemote(const MachineName: string): IAssetModel;
  end;

{ AssetTriggerObject }

  CoAssetTrigger = class
    class function Create: IAssetTrigger;
    class function CreateRemote(const MachineName: string): IAssetTrigger;
  end;



implementation

uses ComObj;

class function CoAssetManager.Create: IAssetManager;
begin
  Result := CreateComObject(Class_AssetManager) as IAssetManager;
end;

class function CoAssetManager.CreateRemote(const MachineName: string): IAssetManager;
begin
  Result := CreateRemoteComObject(MachineName, Class_AssetManager) as IAssetManager;
end;

class function CoAsset.Create: IAsset;
begin
  Result := CreateComObject(Class_Asset) as IAsset;
end;

class function CoAsset.CreateRemote(const MachineName: string): IAsset;
begin
  Result := CreateRemoteComObject(MachineName, Class_Asset) as IAsset;
end;

class function CoAssetEntry.Create: IAssetEntry;
begin
  Result := CreateComObject(Class_AssetEntry) as IAssetEntry;
end;

class function CoAssetEntry.CreateRemote(const MachineName: string): IAssetEntry;
begin
  Result := CreateRemoteComObject(MachineName, Class_AssetEntry) as IAssetEntry;
end;

class function CoAssetQuantity.Create: IAssetQuantity;
begin
  Result := CreateComObject(Class_AssetQuantity) as IAssetQuantity;
end;

class function CoAssetQuantity.CreateRemote(const MachineName: string): IAssetQuantity;
begin
  Result := CreateRemoteComObject(MachineName, Class_AssetQuantity) as IAssetQuantity;
end;

class function CoAssetUnit.Create: IAssetUnit;
begin
  Result := CreateComObject(Class_AssetUnit) as IAssetUnit;
end;

class function CoAssetUnit.CreateRemote(const MachineName: string): IAssetUnit;
begin
  Result := CreateRemoteComObject(MachineName, Class_AssetUnit) as IAssetUnit;
end;

class function CoAssetOwner.Create: IAssetOwner;
begin
  Result := CreateComObject(Class_AssetOwner) as IAssetOwner;
end;

class function CoAssetOwner.CreateRemote(const MachineName: string): IAssetOwner;
begin
  Result := CreateRemoteComObject(MachineName, Class_AssetOwner) as IAssetOwner;
end;

class function CoAssetModel.Create: IAssetModel;
begin
  Result := CreateComObject(Class_AssetModel) as IAssetModel;
end;

class function CoAssetModel.CreateRemote(const MachineName: string): IAssetModel;
begin
  Result := CreateRemoteComObject(MachineName, Class_AssetModel) as IAssetModel;
end;

class function CoAssetTrigger.Create: IAssetTrigger;
begin
  Result := CreateComObject(Class_AssetTrigger) as IAssetTrigger;
end;

class function CoAssetTrigger.CreateRemote(const MachineName: string): IAssetTrigger;
begin
  Result := CreateRemoteComObject(MachineName, Class_AssetTrigger) as IAssetTrigger;
end;


end.
