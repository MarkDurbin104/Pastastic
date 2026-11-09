unit StockData;

interface

uses
  GPCSErrorLine,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables;

type
  TStockDataModule = class(TDataModule)
    StockItemTable: TTable;
    StockItemTableSIIdentifier: TIntegerField;
    StockItemTableSIDescription: TStringField;
    StockItemTableSIPrice: TFloatField;
    StockItemTableSIPLU: TIntegerField;
    StockItemTableSIProgID: TStringField;
    StockItemTableSIAccountID: TStringField;
    StockItemTableSIGroup: TStringField;
    StockItemTableSIAgency: TStringField;
    StockItemTableSIReportLine: TStringField;
    StockUnitItemTable: TTable;
    StockUnitItemTableSUIIdentifier: TIntegerField;
    StockUnitItemTableSUITempAdjust: TIntegerField;
    StockUnitItemTableSUIQuantity: TIntegerField;
    StockUnitItemTableSUIMinLevel: TIntegerField;
    StockUnitItemTableSUIMaxLevel: TIntegerField;
    StockUnitItemTableSUINomLevel: TIntegerField;
    StockUnitItemTableSUIItemIndex: TIntegerField;
    StockUnitItemTableSUITQuantity: TIntegerField;
    StockUnitItemTableSUIOwner: TStringField;
    StockUnitItemTableSUITransferTo: TStringField;
    StockUnitItemTableSUIDescription: TStringField;
    procedure StockUnitItemTableCalcFields(DataSet: TDataSet);
  private
    { Private declarations }
    FFlagFileItem     : Boolean ;
    FFlagFileUnitItem : Boolean ;
    FFlagLeaveItemOpen    : Boolean ;
    FFlagLeaveUnitItemOpen : Boolean ;
    procedure SetFlagLeaveItemOpen( Value : Boolean );
    procedure SetFlagLeaveUnitItemOpen( Value : Boolean );

    function GetDataBasePath : String ;
  public
    { Public declarations }
    procedure OpenStockItem ;
    procedure OpenStockUnitItem ;
    procedure CloseStockItem ;
    procedure CloseStockUnitItem ;
    procedure CheckIndex ;
    procedure OpenTables ;
    procedure CloseTables ;
    procedure DeleteIndexes ;
    Procedure BuildIndexes ;
    procedure EmptyDataBases ;
    procedure CheckTables ;
    property  DataBasePath : String read GetDataBasePath ;
    property  FlagLeaveItemOpen : Boolean     read FFlagLeaveItemOpen       write SetFlagLeaveItemOpen ;
    property  FlagLeaveUnitItemOpen : Boolean read FFlagLeaveUnitItemOpen   write SetFlagLeaveUnitItemOpen ;

  end;

var
  StockDataModule: TStockDataModule;

implementation

{$R *.DFM}
procedure TStockDataModule.StockUnitItemTableCalcFields(DataSet: TDataSet);
begin


   if StockItemTable.State = dsBrowse then
      if StockUnitItemTableSUIIdentifier.Value <> StockItemTableSIIdentifier.Value then
      begin
         if StockItemTable.Locate( 'SIIdentifier', StockUnitItemTableSUIIdentifier.Value , [] ) then
         begin
            StockUnitItemTableSUIDescription.Text := StockItemTableSIDescription.Value;
         end;
      end
      else
         StockUnitItemTableSUIDescription.Text := StockItemTableSIDescription.Value ;

end;

procedure TStockDataModule.CheckIndex ;
var
  IndexDef :TIndexDef ;
  IndFound : Boolean ;
  TempTable : TTable ;
begin
   IndexDef := nil ;

   TempTable := TTable.Create(nil) ;
   TempTable.DataBaseName := 'PSL' ;
   TempTable.TableName := StockItemTable.TableName ;
   TempTable.Exclusive := True;

   try
      try

         //Ensure Indexes exists in StockItem
         TempTable.IndexDefs.Update;
          // ---------------------------- primary index -------------------------
         try
          // If TxnLogTable.IndexDefs.IndexOf('RecordID;WSNumber') < 0 then
            IndFound := True;
            IndexDef := TempTable.IndexDefs.FindIndexForFields('SIIdentifier');
         except
            //On E : Exception do
               IndFound := False ;
            //end;
         end;
         if not IndFound or ( IndexDef.Fields <> 'SIIdentifier' ) then
             TempTable.AddIndex('', 'SIIdentifier', [ixPrimary, ixUnique]);


         //check office field type
         TempTable.Open;
         TempTable.FieldDefs.Update;
      finally
         TempTable.Close;
      end;

   except
      On E : Exception do
        RaiseGUIDException('{98717035-602F-475C-97C9-5D7E8E345E67}', E);
   end;

   TempTable.TableName := StockUnitItemTable.TableName ;

   try

      try

         //Ensure Indexes exists in StockItem
         TempTable.IndexDefs.Update;
        // ---------------------------- primary index -------------------------
         try
            IndFound := True ;
            IndexDef:= nil;
            IndexDef := TempTable.IndexDefs.FindIndexForFields('SUIIdentifier;SUIOwner');
         except
            IndFound := False ;
         end;
         if not IndFound or ( IndexDef.Fields <> 'SUIIdentifier;SUIOwner' ) then
            TempTable.AddIndex('', 'SUIIdentifier;SUIOwner', [ixPrimary, ixUnique]);

         // ---------------------------- PeriodTellerType --------------------------------
         try
           IndFound := True ;
           IndexDef := TempTable.IndexDefs.FindIndexForFields('SUIOwner;SUIIdentifier');
         except
            IndFound := False;
         end;
         if not IndFound or ( IndexDef.Fields <> 'SUIOwner;SUIIdentifier' ) then
            TempTable.AddIndex('Owner', 'SUIOwner;SUIIdentifier', [ixCaseInsensitive	]);

         //check office field type
         TempTable.Exclusive := True;
         TempTable.Open;
         TempTable.FieldDefs.Update;

      finally
         TempTable.Close;
      end;

   except
      On E : Exception do
      RaiseGUIDException('{A0B408E5-8568-4BEE-9F5A-B32C5EE87842}', E);
   end;

   TempTable.Free ;

end ;

procedure TStockDataModule.OpenTables ;
begin
   FFlagFileItem     := False ;
   FFlagFileUnitItem := False ;
   FFlagLeaveItemOpen      := False ;
   FFlagLeaveUnitItemOpen  := False ;

   CheckTables ;
   CheckIndex ;
   try
      if FileExists( DataBasePath +'\'+ StockUnitItemTable.TableName ) and
         FileExists( DataBasePath +'\'+ StockItemTable.TableName ) then
      begin
         StockItemTable.Open ;
         StockUnitItemTable.Open ;
         FFlagFileItem     := True ;
         FFlagFileUnitItem := True ;
      end;
   except
      On E : Exception do
      RaiseGUIDException('{DE57F2A5-B5EF-4B5C-B3A0-D2FC0E300B28}', E);
   end ;
end;

procedure TStockDataModule.CloseTables ;
begin
   StockItemTable.Close ;
   StockUnitItemTable.Close ;
end ;
procedure TStockDataModule.DeleteIndexes ;
var
   TablePath : String ;
begin
   if ( StockItemTable.State = dsInactive ) and
      ( StockUnitItemTable.State = dsInactive ) then
   begin
      TablePath := GetDataBasePath ;
      DeleteFile ( TablePath + '\StockUnitItem.XG0' );
      DeleteFile ( TablePath + '\StockUnitItem.YG0' );
      DeleteFile ( TablePath + '\StockUnitItem.PX'  );
      DeleteFile ( TablePath + '\StockItem.PX' );

   end ;
end ;

Procedure TStockDataModule.BuildIndexes ;
begin
   CloseTables ;
   DeleteIndexes ;
   OpenTables ;

end ;

function TStockDataModule.GetDataBasePath : String ;
var
   InfoStrings : TStringList ;
begin
   InfoStrings := TStringList.Create ;
   Session.GetAliasParams( 'PSL',InfoStrings );
   result := InfoStrings.Values['Path'] ;
   InfoStrings.Free ;
end ;

Procedure TStockDataModule.CheckTables ;
var
   TempTable : TTable ;
begin

   if not FileExists( DataBasePath +'\'+ StockUnitItemTable.TableName ) then
   begin
      TempTable := TTable.Create( nil ) ;
      TempTable.TableType := ttParadox;
      TempTable.DataBaseName := 'PSL' ;
      TempTable.TableName := StockUnitItemTable.TableName ;
      with TempTable.FieldDefs do
      begin
         Clear;
         Add('SUIIdentifier', ftInteger, 0, True);
         Add('SUIOwner', ftString, 30, True);
         Add('SUITransferTo', ftString, 30, False);
         Add('SUITempAdjust', ftInteger, 0, True);
         Add('SUIQuantity', ftInteger, 0, True);
         Add('SUIMinLevel', ftInteger, 0, True);
         Add('SUIMaxLevel', ftInteger, 0, True);
         Add('SUINomLevel', ftInteger, 0, True);
         Add('SUIItemIndex', ftInteger, 0, True);
         Add('SUITQuantity', ftInteger, 0, True);
      end;

      { Now that we have specified what we want, create the table }
      TempTable.CreateTable;
      TempTable.Free ;
   end;

   if not FileExists( DataBasePath +'\'+ StockItemTable.TableName ) then
   begin
      TempTable := TTable.Create( nil ) ;
      TempTable.TableType := ttParadox;
      TempTable.DataBaseName := 'PSL' ;
      TempTable.TableName := StockItemTable.TableName ;
      with TempTable.FieldDefs do
      begin
         Clear;
         Add('SIIdentifier',  ftInteger,  0, True);
         Add('SIDescription', ftString,   50, False);
         Add('SIPrice',       ftFloat,    0, False);
         Add('SIPLU',         ftInteger,  0, False);
         Add('SIProgID',      ftString,   20, False);
         Add('SIAccountID',   ftString,   40, False);
         Add('SIGroup',       ftString,   40, False);
         Add('SIAgency',      ftString,   40, False);
         Add('SIReportLine',  ftString,   40, False);
      end;

      TempTable.CreateTable;
      TempTable.Free ;

   end;


end ;

procedure TStockDataModule.EmptyDataBases ;
begin
   if ( StockItemTable.State <> dsInactive ) and
      ( StockUnitItemTable.State <> dsInactive ) then
   begin
      while not StockUnitItemTable.Eof do
         StockUnitItemTable.Delete ;

      while not StockItemTable.Eof do
         StockItemTable.Delete ;


   end ;
end ;

procedure TStockDataModule.OpenStockItem ;
begin

   if ( StockItemTable.State = dsInactive ) and FFlagFileItem then
      StockItemTable.Open ;

end ;
procedure TStockDataModule.OpenStockUnitItem ;
begin
   if( StockUnitItemTable.State = dsInactive ) and  FFlagFileUnitItem  then
      StockUnitItemTable.Open ;
end ;
procedure TStockDataModule.CloseStockItem ;
begin
   if ( StockItemTable.State = dsBrowse ) and not FFlagLeaveItemOpen then
      StockItemTable.Close ;

end ;
procedure TStockDataModule.CloseStockUnitItem ;
begin
   if ( StockUnitItemTable.State = dsBrowse ) and not FFlagLeaveUnitItemOpen then
      StockUnitItemTable.Close ;
end ;

procedure TStockDataModule.SetFlagLeaveItemOpen( Value : Boolean );
begin
   FFlagLeaveItemOpen := Value ;
end ;

procedure TStockDataModule.SetFlagLeaveUnitItemOpen( Value : Boolean );
begin
   FFlagLeaveUnitItemOpen := Value ;
end ;


end.






