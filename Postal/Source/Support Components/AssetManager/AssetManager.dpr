program AssetManager;

uses
	SysUtils,
  Forms,
  ComServ2,
  AssetManager_TLB in 'AssetManager_TLB.pas',
  AssetManagerAU in 'AssetManagerAU.pas' {GPCSAssetManager: CoClass},
  AssetBalanceF in 'AssetBalanceF.pas' {AssetBalanceForm},
  AssetUnitPaletteF in 'AssetUnitPaletteF.pas' {AssetUnitPaletteForm},
  AssetManagerDM in 'AssetManagerDM.pas' {AssetManagerDataModule: TDataModule},
  AssetQuantityU in 'AssetQuantityU.pas',
  AssetUnitU in 'AssetUnitU.pas',
  AssetPaletteF in 'AssetPaletteF.pas' {AssetPaletteForm},
  AssetU in 'AssetU.pas',
  AssetOwnerU in 'AssetOwnerU.pas',
  AssetFilterU in 'AssetFilterU.pas',
  AssetEntryU in 'AssetEntryU.pas',
  AssetTimePointU in 'AssetTimePointU.pas',
  AssetNodeU in 'StructureNodes\AssetNodeU.pas',
  AssetModelsF in 'AssetModelsF.pas' {AssetModelsForm},
  StructureNodeU in '..\..\..\..\..\MyStuff\StructureNode\StructureNodeU.pas',
  AssetDropF in 'StructureNodes\AssetDropF.pas' {AssetDropForm},
  AssetTriggerNodeU in 'StructureNodes\AssetTriggerNodeU.pas',
  AssetTriggerDropF in 'StructureNodes\AssetTriggerDropF.pas' {AssetTriggerDropForm},
  AssetTriggerPaletteF in 'AssetTriggerPaletteF.pas' {AssetTriggerPaletteForm},
  StructureNodeButtonU in '..\..\..\..\..\MyStuff\StructureNode\StructureNodeButtonU.pas',
  ObjectBinary_TLB in '..\..\..\..\..\MyStuff\ObjectBinary\ObjectBinary_TLB.pas',
  GPCSRegistry in 'GPCSRegistry\GPCSRegistry.pas',
  DropDownStructureNodeU in '..\..\..\..\..\MyStuff\StructureNode\DropDownStructureNodeU.pas',
  AssetTriggerF in 'AssetTrigger\AssetTriggerF.pas' {AssetTriggerForm},
  AssetModelF in 'AssetModelF.pas' {AssetModelForm},
  AssetBaseU in 'AssetBaseU.pas',
  AssetManagedU in 'AssetManagedU.pas',
  MainF in 'MainF.pas' {MainForm},
  AssetTriggerAU in 'AssetTrigger\AssetTriggerAU.pas',
  UserF in 'UserF.pas' {UserForm},
  AssetManagerStructureNodeU in 'AssetManagerStructureNodeU.pas',
  AssetModelNodeU in 'AssetModelNodeU.pas',
  AssetModelNodeDropF in 'AssetModelNodeDropF.pas' {AssetModelNodeDropForm},
  AssetModelsPaletteF in 'AssetModelsPaletteF.pas' {AssetModelsPaletteForm},
  AssetManagedF in 'AssetManagedF.pas' {AssetManagedForm},
  AssetManagedPaletteF in 'AssetManagedPaletteF.pas' {AssetManagedPaletteForm},
  TypedListU in 'TypedListU.pas';

{$R *.TLB}
{$R *.RES}

var
  AssetMgr : TAssetManager;

begin
  Application.Initialize;
  Application.Title := 'GPCS Asset Manager';
  If ComServer.StartMode <> smStandAlone then
    Application.ShowMainForm := False
  else
  begin
    AssetMgr := TAssetManager.Create;

    Application.CreateForm(TMainForm, MainForm);
  MainForm.AssetManager := AssetMgr;

    Application.CreateForm(TAssetModelsPaletteForm, AssetModelsPaletteForm);
		AssetModelsPaletteForm.AssetManager := AssetMgr;

    Application.CreateForm(TAssetModelsForm, AssetModelsForm);
    AssetModelsForm.AssetManager := AssetMgr;

		//connect data
    Application.CreateForm(TAssetManagerDataModule, AssetManagerDataModule);
		AssetManagerDataModule.AssetDatabase.DatabaseName 				:= ExtractFilePath(Application.ExeName) + '..\database';
		AssetManagerDataModule.AssetDescriptionTable.DatabaseName := AssetManagerDataModule.AssetDatabase.DatabaseName;
    AssetManagerDataModule.AssetGroupTable.DatabaseName 			:= AssetManagerDataModule.AssetDatabase.DatabaseName;
    AssetManagerDataModule.AssetBalanceTable.DatabaseName 		:= AssetManagerDataModule.AssetDatabase.DatabaseName;
    AssetManagerDataModule.AssetUnitTable.DatabaseName 				:= AssetManagerDataModule.AssetDatabase.DatabaseName;

    Application.CreateForm(TAssetUnitPaletteForm, AssetUnitPaletteForm);
    Application.CreateForm(TAssetPaletteForm, AssetPaletteForm);
    AssetPaletteForm.AssetManager := AssetMgr;

    Application.CreateForm(TAssetBalanceForm, AssetBalanceForm);

    Application.CreateForm(TAssetTriggerPaletteForm, AssetTriggerPaletteForm);
    AssetTriggerPaletteForm.AssetManager := AssetMgr;

    Application.CreateForm(TUserForm, UserForm);
    UserForm.AssetManager := AssetMgr;

  end;
  Application.Run;
end.
