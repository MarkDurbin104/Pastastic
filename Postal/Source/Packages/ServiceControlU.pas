unit ServiceControlU;

interface

uses
  Windows,WinSvc;
  
type
  TControlType = (ctStart,ctStop,ctPause,ctContinue,ctStatus);

procedure InstallService;
procedure RemoveService;
function CtrlService(ControlType:TControlType):TServiceStatus;

const
   ServiceName = 'CorvusService';
   DisplayName = 'Corvus Service';
   ModuleName  = 'C:\CorvusService\CorvusService.exe';

implementation

const
  SERVICE_KERNEL_DRIVER          = $00000001;
  SERVICE_FILE_SYSTEM_DRIVER     = $00000002;
  SERVICE_ADAPTER                = $00000004;
  SERVICE_RECOGNIZER_DRIVER      = $00000008;

  SERVICE_DRIVER                 = SERVICE_KERNEL_DRIVER or
                                   SERVICE_FILE_SYSTEM_DRIVER or
                                   SERVICE_RECOGNIZER_DRIVER;

  SERVICE_WIN32_OWN_PROCESS      = $00000010;
  SERVICE_WIN32_SHARE_PROCESS    = $00000020;
  SERVICE_WIN32                  = SERVICE_WIN32_OWN_PROCESS or
                                   SERVICE_WIN32_SHARE_PROCESS;

  SERVICE_INTERACTIVE_PROCESS    = $00000100;

  SERVICE_TYPE_ALL               = SERVICE_WIN32 or
                                   SERVICE_ADAPTER or
                                   SERVICE_DRIVER or
                                   SERVICE_INTERACTIVE_PROCESS;
//
// Start Type
//
  SERVICE_BOOT_START             = 00000000;
  SERVICE_SYSTEM_START           = 00000001;
  SERVICE_AUTO_START             = 00000002;
  SERVICE_DEMAND_START           = 00000003;
  SERVICE_DISABLED               = 00000004;

//
// Error control type
//
  SERVICE_ERROR_IGNORE           = $00000000;
  SERVICE_ERROR_NORMAL           = $00000001;
  SERVICE_ERROR_SEVERE           = $00000002;
  SERVICE_ERROR_CRITICAL         = $00000003;
  
function GetErrorMessage(Code:Integer):String;
var
  hErrLib:THandle;
  msg : PChar;
  flags : Integer;
begin
  hErrLib:=LoadLibraryEx ('netmsg.dll',0,LOAD_LIBRARY_AS_DATAFILE);
  try
     flags:=FORMAT_MESSAGE_ALLOCATE_BUFFER or
            FORMAT_MESSAGE_IGNORE_INSERTS or
            FORMAT_MESSAGE_FROM_SYSTEM;
     if hErrLib <> 0 then
        flags := flags or FORMAT_MESSAGE_FROM_HMODULE;
     try
        if FormatMessage(flags,Pointer(hErrLib),Code,
                       (SUBLANG_DEFAULT shl 10) or LANG_NEUTRAL,
                       @msg,0,Nil) <> 0 then
           Result:=msg;
     finally
       LocalFree(Integer(msg));
     end
  finally
     if hErrLib <> 0 then FreeLibrary (hErrLib)
  end
end;
procedure ShowError;
begin
//   Form1.ErrorPanel.Caption:=GetErrorMessage(GetLastError);
end;
procedure InstallService;
var
  machineName : array [0..MAX_COMPUTERNAME_LENGTH] of char;
  size : Integer;
  serviceDatabaseHandle : SC_HANDLE;
  serviceHandle : SC_HANDLE;
  serviceDatabaseLock : SC_LOCK;
begin
  size := sizeof (machineName);
  GetComputerName (machineName, size);

  // Open the NT Service Control Manager

  serviceDatabaseHandle := OpenSCManager (machineName, Nil, SC_MANAGER_CREATE_SERVICE or SC_MANAGER_LOCK);
  if serviceDatabaseHandle = 0 then
    ShowError;

  try
  // Lock the NT service database.
    serviceDatabaseLock := LockServiceDatabase (serviceDatabaseHandle);
    if serviceDatabaseLock = Nil then
      ShowError;
    try

  // Register the service with NT

      serviceHandle := CreateService (serviceDatabaseHandle, pChar (ServiceName), pChar (DisplayName),
                                      SERVICE_START or SERVICE_ALL_ACCESS, 
                                      SERVICE_WIN32_OWN_PROCESS, 
                                      SERVICE_AUTO_START, 
                                      SERVICE_ERROR_NORMAL,
                                      PChar(ModuleName), Nil, Nil, Nil, Nil, Nil);
      if serviceHandle = 0 then
        ShowError;
        
      CloseServiceHandle (serviceHandle);
    finally
      UnlockServiceDatabase (serviceDatabaseLock);
    end;
  finally
    CloseServiceHandle (serviceDatabaseHandle)
  end
end;

procedure RemoveService;
var
  machineName : array [0..MAX_COMPUTERNAME_LENGTH] of char;
  size : Integer;
  serviceDatabaseHandle, serviceHandle : SC_HANDLE;
  serviceDatabaseLock : SC_LOCK;

begin
  size := sizeof (machineName);
  GetComputerName (machineName, size);

  // Open the NT Service Control Manager
  serviceDatabaseHandle := OpenSCManager (machineName, Nil, SC_MANAGER_CREATE_SERVICE or SC_MANAGER_LOCK);

  if serviceDatabaseHandle = 0 then
    ShowError;

  try
  // Lock the NT service database.
    serviceDatabaseLock := LockServiceDatabase (serviceDatabaseHandle);
    if serviceDatabaseLock = Nil then
      ShowError;

    try

  // Open the service
      serviceHandle := OpenService (serviceDatabaseHandle, PChar (ServiceName), SERVICE_ALL_ACCESS);

      if serviceHandle = 0 then
        ShowError;

      try

  // Delete the service

        if not DeleteService (serviceHandle) then
          ShowError;

      finally
        CloseServiceHandle (serviceHandle);
      end;

    finally
      UnlockServiceDatabase (serviceDatabaseLock)
    end;

  finally
    CloseServiceHandle (serviceDatabaseHandle);
  end
end;
function CtrlService(ControlType:TControlType):TServiceStatus;
var
  machineName : array [0..MAX_COMPUTERNAME_LENGTH] of char;
  size : Integer;
  serviceDatabaseHandle, serviceHandle : SC_HANDLE;
//  ServiceStatus:TServiceStatus;
  Res:Boolean;
  DummyParam:PChar;
begin
  DummyParam:=nil;
  size := sizeof (machineName);
  GetComputerName (machineName, size);
  Result.dwCurrentState:=0;

  // Open the NT Service Control Manager
  serviceDatabaseHandle := OpenSCManager (machineName, Nil, SC_MANAGER_CREATE_SERVICE or SC_MANAGER_LOCK);

  if serviceDatabaseHandle = 0 then
    ShowError;

  try

  // Open the service
      serviceHandle := OpenService (serviceDatabaseHandle, PChar (ServiceName),SERVICE_ALL_ACCESS);

      if serviceHandle = 0 then
      begin
        if ControlType <> ctStatus then
           ShowError;
        Result.dwCurrentState:=0;
        Exit;
      end;
      try

  // Control the service
     Res:=True;
     case ControlType of
        ctStart    : begin
                        Res:=StartService(serviceHandle,0,DummyParam);
                     end;
        ctStop     : begin
                        Res:=ControlService(serviceHandle,SERVICE_CONTROL_STOP,Result);
                     end;
        ctPause    : begin
                        Res:=ControlService(serviceHandle,SERVICE_CONTROL_PAUSE,Result);
                     end;
        ctContinue : begin
                        Res:=ControlService(serviceHandle,SERVICE_CONTROL_CONTINUE,Result);
                     end;     
        ctStatus   : begin
                        Res:=ControlService(serviceHandle,SERVICE_CONTROL_INTERROGATE,Result);
                     end;     
      end;
      if (not Res) and (ControlType <> ctStatus) then
        ShowError;
      finally        
        CloseServiceHandle (serviceHandle);
      end;

  finally
    CloseServiceHandle (serviceDatabaseHandle);
  end
end;

end.
