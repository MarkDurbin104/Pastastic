unit CreateRemote;

interface


function CreateActualRemoteComObject(const MachineName: WideString;
  const ClassID: TGUID): IUnknown;
implementation

uses SysUtils,Windows,ActiveX,ComObj;

type
  TCoCreateInstanceExProc = function (const clsid: TCLSID;
    unkOuter: IUnknown; dwClsCtx: Longint; ServerInfo: PCoServerInfo;
    dwCount: Longint; rgmqResults: PMultiQIArray): HResult stdcall;

var
  CoCreateInstanceEx: TCoCreateInstanceExProc = nil;
  
function GetLocalMachineName:String;
var
   Length:DWord;
begin
   Length:=MAX_COMPUTERNAME_LENGTH+1;
   SetLength(Result,Length);
   GetComputerName(PChar(Result),Length);
   SetLength(Result,Length);
   Result:='\\'+Result;
end;

function CreateActualRemoteComObject(const MachineName: WideString;
  const ClassID: TGUID): IUnknown;
var
  MQI: TMultiQI;
  Ole32: HModule;
  ServerInfo: TCoServerInfo;
  IID_IUnknown: TGuid;
begin
  if MachineName = GetLocalMachineName then
  begin
     Result:=CreateComObject(ClassID);
     Exit;
  end;
  if @CoCreateInstanceEx = nil then
  begin
    Ole32 := GetModuleHandle('ole32.dll');
    Win32Check(Ole32 > HINSTANCE_ERROR);
    @CoCreateInstanceEx := GetProcAddress(Ole32, 'CoCreateInstanceEx');
//    if @CoCreateInstanceEx = nil then
//      raise Exception.Create(SDCOMNotInstalled);
  end;
  FillChar(ServerInfo, sizeof(ServerInfo), 0);
  ServerInfo.pwszName := PWideChar(MachineName);
  IID_IUnknown := IUnknown;
  MQI.IID := @IID_IUnknown;
  MQI.itf := nil;
  MQI.hr := 0;
  OleCheck(CoCreateInstanceEx(ClassID, nil,
    CLSCTX_REMOTE_SERVER,
    @ServerInfo, 1, @MQI));
  OleCheck(MQI.HR);
  Result := MQI.itf;
end;

end.
 