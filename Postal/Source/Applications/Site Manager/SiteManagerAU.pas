unit SiteManagerAU;

interface
uses
   GPCSBase_TLB,GPCSBaseAU,GPCSGUID,ComServ2,ComObj,SiteManagerFU;

type
   TSiteManager = class(TGPCSComponent,ISiteManager)
   protected
      function CopyFile(const FromMachine, FromPath, FromFile, ToMachine, ToPath, ToFile: WideString): WordBool; safecall;
      function WhosHere: WideString; safecall;
      function ApplyUpdate(UpdateType: SMUpdateType; const FromMachineData: WideString): WordBool; safecall;
      function CurrentVersion: WideString; safecall;
      function StartUpGPCS: WordBool; safecall;
      function ShutDownGPCS: WordBool; safecall;
      procedure ShutDownMachine; safecall;
      procedure LogOffMachine; safecall;
      procedure ReLoadComponents(const ProgIDs: WideString); safecall;
      function GetLocalFile(const Path, Name: WideString; var DateTime: TDateTime): OleVariant; safecall;
      function SetLocalFile(const Path, Name: WideString; DateTime: TDateTime; Value: OleVariant): WordBool; safecall;
   public
      procedure Initialize; override;
      destructor Destroy; override;
   end;
implementation
{TSiteManager}
procedure TSiteManager.Initialize;
begin
   inherited Initialize;
end;
destructor TSiteManager.Destroy;
begin
   inherited Destroy;
end;
function TSiteManager.CopyFile(const FromMachine, FromPath, FromFile, ToMachine, ToPath, ToFile: WideString): WordBool;
begin
end;
function TSiteManager.WhosHere: WideString;
begin
end;
function TSiteManager.ApplyUpdate(UpdateType: SMUpdateType; const FromMachineData: WideString): WordBool;
begin
end;
function TSiteManager.CurrentVersion: WideString;
begin
end;
function TSiteManager.StartUpGPCS: WordBool;
begin
end;
function TSiteManager.ShutDownGPCS: WordBool;
begin
end;
procedure TSiteManager.ShutDownMachine;
begin
end;
procedure TSiteManager.LogOffMachine; 
begin
end;
procedure TSiteManager.ReLoadComponents(const ProgIDs: WideString);
begin
end;
function TSiteManager.GetLocalFile(const Path, Name: WideString; var DateTime: TDateTime): OleVariant;
begin
end;
function TSiteManager.SetLocalFile(const Path, Name: WideString; DateTime: TDateTime; Value: OleVariant): WordBool;
begin
end;

initialization
  TGPCSCompFactory.Create(ComServer,TSiteManager,Class_SiteManager,
                          'Support.SiteManager','GPCS Site Manager',
                          ciMultiInstance);
end.
