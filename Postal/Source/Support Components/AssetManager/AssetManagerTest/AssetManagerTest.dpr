program AssetManagerTest;

uses
  Forms,
  AssetManagerTestF in 'AssetManagerTestF.pas' {AssetManagerTestForm},
  SavePosFormU in '..\..\..\..\..\MyStuff\Common\SavePosFormU.pas',
  AssetManager_TLB in '..\AssetManager_TLB.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TAssetManagerTestForm, AssetManagerTestForm);
  Application.Run;
end.
