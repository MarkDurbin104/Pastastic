unit AssetManagerDM;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables;

type
  TAssetManagerDataModule = class(TDataModule)
    AssetDescriptionTable: TTable;
    AssetDescriptionTableADDisplayOrder: TIntegerField;
    AssetDescriptionTableADAsset: TStringField;
    AssetDescriptionTableADDescription: TStringField;
    AssetDescriptionDataSource: TDataSource;
    AssetGroupTable: TTable;
    AssetGroupTableAGIdentifier: TStringField;
    AssetGroupTableGroupDescription: TStringField;
    AssetGroupTableAGParent: TStringField;
    AssetGroupTableParentDescription: TStringField;
    AssetGroupTableAGMultiplier: TFloatField;
    AssetGroupDataSource: TDataSource;
    AssetBalanceDataSource: TDataSource;
    AssetBalanceTable: TTable;
    AssetUnitTable: TTable;
    AssetUnitDataSource: TDataSource;
    AssetUnitTableAUName: TStringField;
    AssetUnitTableAUExchange: TCurrencyField;
    AssetDatabase: TDatabase;
    AssetBalanceTableABSite: TStringField;
    AssetBalanceTableABOwner: TStringField;
    AssetBalanceTableABPeriod: TStringField;
    AssetBalanceTableABCode: TStringField;
    AssetBalanceTableABUnit: TStringField;
    AssetBalanceTableABAmount: TCurrencyField;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AssetManagerDataModule: TAssetManagerDataModule;

implementation

{$R *.DFM}

end.
