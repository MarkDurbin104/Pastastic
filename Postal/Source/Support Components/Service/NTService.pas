unit NTService;

interface
uses Windows, SysUtils, WinSvc;

type
  argArray = ^PChar;
  TControlType = (ctStart,ctStop,ctPause,ctContinue);
  TNTService = class(TObject)
  private
     FTerminated : boolean;
     FServiceName : string;
     FDisplayName : string;
     FServiceStatus : TServiceStatus;
     FStatusEvent : THandle;
     FTerminateEvent : THandle;
     FExecuteThread : THandle;
     FStatusHandle : SERVICE_STATUS_HANDLE;
     procedure InstallService;
     procedure UninstallService;
     procedure CtrlService(ControlType:TControlType);
     function GetRegistryRoot : string;
     procedure ServiceMain (dwNumServiceArgs : LongInt; argVectors : argArray);
     procedure HandlerFunction (dwControl : Integer);
     procedure SetStatus (waitHint : Integer);
   protected
     FLogging : boolean;
     FNonServiceMode : boolean;
     function PreRegisterInitialize : boolean; virtual;
     function PostRegisterInitialize : boolean; virtual;
     function Execute : Integer; virtual;
     procedure Installed; virtual;
     procedure Deleted; virtual;
     procedure Started; virtual;
     procedure Stopped; virtual;
     property Terminated : boolean read fTerminated;
     property TerminateEvent : THandle read fTerminateEvent;
     property RegistryRoot : string read GetRegistryRoot;
     function ExecuteDelay (nMilliseconds : Integer) : boolean;
   public
     constructor Create(ServiceName,DisplayName:string);
     procedure Run;
   end;

procedure LogMessage (const msg : string);

implementation

uses unitNTException;

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

var
  currentService : TNTService;

(*------------------------------------------------------------------------*
 | procedure LogMessage                                                   |
 |                                                                        |
 | Provide rudimentary logging by appending a message to c:\svc.log       |
 |                                                                        |
 | Parameters:                                                            |
 |   msg : string              The message to log.                        |
 *------------------------------------------------------------------------*)
procedure LogMessage (const Msg:String);
var 
   F:Text;
begin
   AssignFile(F,'c:\svc.log');
   try
      Append(F);
   except
      Rewrite(F)
   end;
   WriteLn(F,Msg);
   CloseFile(F);
end;

(*------------------------------------------------------------------------*
 | procedure ServiceMain                                                  |
 |                                                                        |
 | Main service entry point.  This is called by the NT service controller |
 | when the service is started.                                           |
 |                                                                        |
 | Parameters:                                                            |
 |   dwNumServiceArgs : LongInt    The number of entries in the           |
 |                                 'Startup Parameters'.  The first       |
 |                                 parameter is always the service name   |
 *------------------------------------------------------------------------*)
procedure ServiceMain (dwNumServiceArgs : LongInt; argVectors : argArray); stdcall;
begin
  CurrentService.ServiceMain (dwNumServiceArgs, argVectors);
end;

(*------------------------------------------------------------------------*
 | procedure HandlerFunction                                              |
 |                                                                        |
 | Service request handler function.  Called by the NT service            |
 | to start/stop/pause/continue the service.                              |
 |                                                                        |
 | Parameters:                                                            |
 |   dwControl : LongInt;       The control request.                      |
 *------------------------------------------------------------------------*)
procedure HandlerFunction (dwControl : LongInt); stdcall;
begin
  CurrentService.HandlerFunction (dwControl);
end;

(*------------------------------------------------------------------------*
 | function ExecuteHandler : Integer;                                     |
 |                                                                        |
 | Entry point for the service 'execute' thread.                          |
 |                                                                        |
 | Parameters:                                                            |
 |   param : pointer.            Pointer to the TNTService object.        |
 |                                                                        |
 | The function returns the thread exit code.                             |
 *------------------------------------------------------------------------*)
function ExecuteHandler (param : pointer) : Integer; stdcall;
begin
  result := TNTService (param).Execute;
end;

(*------------------------------------------------------------------------*
 | constructor TNTService.Create;                                         |
 |                                                                        |
 | Constructor for the TNTService class                                   |
 |                                                                        |
 | Parameters:                                                            |
 |   AServiceName : string             The service name                   |
 |   ADisplayName : string             'Display name' to apperar in the   |
 |                                     service manager.                   |
 *------------------------------------------------------------------------*)
constructor TNTService.Create (ServiceName,DisplayName:String);
begin
  inherited Create;
  FServiceName:=ServiceName;
  FDisplayName:=DisplayName;
  CurrentService:=self;
end;

(*------------------------------------------------------------------------*
 | procedure TNTService                                                   |
 |                                                                        |
 | Public function to run the service.  Processes command line parameters |
 | and starts the service.                                                |
 *------------------------------------------------------------------------*)
procedure TNTService.Run;
var
  i : Integer;
  serviceTable : array [0..1] of TServiceTableEntry;
  moduleName : array [0..MAX_PATH] of char;
  args : array [0..0] of PChar;
begin
  if ParamCount > 0 then
    for i := 1 to ParamCount do
      if (ParamStr (i) [1] in ['-', '/']) and (Length (ParamStr (i)) = 2) then
      case UpCase (ParamStr (i) [2]) of
        '?' : begin
                 Writeln('Corvus Service Usage:');
                 Writeln('  -I : Install Service');
                 Writeln('  -S : Install and Start Service');
                 Writeln('  -U : Un-install Service');
                 Writeln('  -X : Stop and Un-install Service');
                 Writeln('  -B : Begin Service Execution');
                 Writeln('  -E : End Service Execution');
                 Writeln('  -P : Pause Service Execution');
                 Writeln('  -C : Continue Service Execution');
                 Writeln('  -N : Non Service Mode');
                 Writeln('  -L : Turn on logging in non-service mode');
              end;
        'N' : begin                       // Start in non-service mode
                 fNonServiceMode := True;
                 GetModuleFileName (0, moduleName, sizeof (moduleName));
                 args [0] := moduleName;
                 ServiceMain (1, ArgArray (@args))
              end;
        'I' : InstallService; // Install the service
        'S' : begin
                 InstallService;  // Install and Start the service
                 CtrlService(ctStart);
              end;         
        'B' : CtrlService(ctStart);        // Begin Service Execution
        'E' : CtrlService(ctStop);         // End Service Execution
        'P' : CtrlService(ctPause   );     // Pause Service Execution
        'C' : CtrlService(ctContinue);     // Continue Service Execution
        'X' : begin
                 CtrlService(ctStop);      // End Service Execution
                 UninstallService;         // Un-install the service
              end;
        'U' : UninstallService;         // Un-install the service
        'L' : fLogging := True;      // Turn on logging in non-service mode.
         else
            raise Exception.CreateFmt ('Unknown switch %s', [ParamStr (i)])
      end
      else
        raise Exception.CreateFmt ('Invalid parameter %s', [ParamStr (i)])
  else
    begin

                                  // No parameters.  The service is being
                                  // run as a 'service' - ie. from the NT
                                  // service controller.

      serviceTable [0].lpServiceName := PChar (fServiceName);
      serviceTable [0].lpServiceProc := @NTService.serviceMain;
      serviceTable [1].lpServiceName := Nil;
      serviceTable [1].lpServiceProc := Nil;
      if not StartServiceCtrlDispatcher (serviceTable [0]) then
        raise ENTException.CreateLastError;
    end
end;

(*------------------------------------------------------------------------*
 | procedure TNTService.HandlerFunction                                   |
 |                                                                        |
 | Handle control requests from the NT service controller.  All requests  |
 | must be acknowleged with a SetStatus, whether or not we no anything    |
 | with them.                                                             |
 |                                                                        |
 | Parameters:                                                            |
 |   dwControl : LongInt        The control request                       |
 *------------------------------------------------------------------------*)
procedure TNTService.HandlerFunction (dwControl : LongInt);
begin
  case dwControl of
    SERVICE_CONTROL_STOP,            // Stop the service, or system-shutdown.
    SERVICE_CONTROL_SHUTDOWN:
      begin
        fServiceStatus.dwCurrentState := SERVICE_STOP_PENDING;
        fServiceStatus.dwControlsAccepted := 0;
        SetStatus (1000);
        SetEvent (fStatusEvent);
      end;

    SERVICE_CONTROL_PAUSE:           // Pause the service
      begin
        fServiceStatus.dwCurrentState := SERVICE_PAUSE_PENDING;
        fServiceStatus.dwControlsAccepted := 0;
        SetStatus (1000);
        SetEvent (fStatusEvent);
      end;

    SERVICE_CONTROL_CONTINUE:        // Resume the service
      begin
        fServiceStatus.dwCurrentState := SERVICE_CONTINUE_PENDING;
        fServiceStatus.dwControlsAccepted := 0;
        SetStatus (1000);
        SetEvent (fStatusEvent);
      end

                                     // Unknown request.  Aknowledge it anyway.
    else SetStatus (fServiceStatus.dwWaitHint);
  end
end;

(*------------------------------------------------------------------------*
 | procedure TNTService.SetStatus                                         |
 |                                                                        |
 | Set the service status.  Indicate how long to wait until it receives   |
 | another status update.                                                 |
 |                                                                        |
 | Parameters:                                                            |
 |   waitHint : Integer       How long to wait until another status is    |
 |                            due.                                        |
 *------------------------------------------------------------------------*)
procedure TNTService.SetStatus (waitHint : Integer);
begin
  fServiceStatus.dwWaitHint := waitHint;
  if waitHint = 0 then
    fServiceStatus.dwCheckPoint := 0
  else
    Inc (fServiceStatus.dwCheckPoint);

  if not fNonServiceMode then
    SetServiceStatus (fStatusHandle, fServiceStatus);
end;

(*------------------------------------------------------------------------*
 | procedure TNTService.ServiceMain                                       |
 |                                                                        |
 | Main entry point for the service                                       |
 |                                                                        |
 | Parameters:                                                            |
 |   dwNumServiceArgs : LongInt   Number of parameters passed by the NT   |
 |                                service manager.                        |
 |                                                                        |
 |   argVectors : argArray        Parameters, from the NT service manager |
 *------------------------------------------------------------------------*)
procedure TNTService.ServiceMain (dwNumServiceArgs : LongInt; argVectors : argArray);
var
  threadID : Integer;
  waitObjects : array [0..1] of THandle;
  objectNo : Integer;
  arg : string;
begin

                                        // Turn on logging if necessary
  for objectNo := 0 to dwNumServiceArgs - 1 do
  begin
    arg := argVectors^;
    if (Length (arg) = 2) and (arg [1] in ['-', '/']) then
      if UpCase (arg [2]) = 'L' then
        fLogging := True;
    Inc (argVectors);
  end;

  if fLogging then
    LogMessage ('Service Main Here');

  // Set up the service status record.

  fServiceStatus.dwServiceType := SERVICE_WIN32_OWN_PROCESS or SERVICE_INTERACTIVE_PROCESS;
  fServiceStatus.dwCurrentState := SERVICE_START_PENDING;
  fServiceStatus.dwControlsAccepted := 0;
  fServiceStatus.dwWin32ExitCode := 0;
  fServiceStatus.dwServiceSpecificExitCode := 0;
  fServiceStatus.dwCheckPoint := 0;
  fServiceStatus.dwWaitHint := 0;

 // Start with the status event signalled, sothat the 'START_PENDING' status get's
 // processed.

  fStatusEvent := CreateEvent (Nil, False, True, Nil);

  fTerminateEvent := CreateEvent (Nil, False, False, Nil);
  fExecuteThread := CreateThread (Nil, 0, @ExecuteHandler, self, CREATE_SUSPENDED, threadID);

  waitObjects [0] := fStatusEvent;
  waitObjects [1] := fExecuteThread;

  // Perform pre-registration initialization.  This *must* be very quick.
  if PreRegisterInitialize then
  begin
    if not fNonServiceMode then
    begin
         // Register the service with NT
      fStatusHandle := RegisterServiceCtrlHandler (PChar (fServiceName), @NTService.HandlerFunction);
      SetStatus (1000);
    end
  end;

  // Perform post-registration.  This can take as long as is required, because
  // checkpointed status acknowledgements will take place.

  if PostRegisterInitialize then
  begin
    repeat

  // Wait for the 'execute' thread to finish, or a 'status' event to happen
      objectNo := WaitForMultipleObjects (2, @waitObjects [0], False, INFINITE);

      if objectNo = 1 then          // The execute thread finished.  Terminate.
        fTerminated := True;

      if not fTerminated then
      begin
        if fLogging then
          LogMessage ('Control request received ' + IntToHex (fServiceStatus.dwCurrentState, 8));

        case fServiceStatus.dwCurrentState of
          SERVICE_STOP_PENDING :
          begin
            fTerminated := True;
                                     // Thaw the execute thread (if it's frozen)
                                     // so it can terminate.
            ResumeThread (fExecuteThread);
                                     // Don't set status to 'STOPPED' until the
                                     // execute thread finishes (below)
          end;

          SERVICE_PAUSE_PENDING :    // Suspend the execute thread.
          begin
            SuspendThread (fExecuteThread);
            fServiceStatus.dwCurrentState := SERVICE_PAUSED;
            fServiceStatus.dwControlsAccepted := SERVICE_ACCEPT_STOP or SERVICE_ACCEPT_PAUSE_CONTINUE or SERVICE_ACCEPT_SHUTDOWN;
            SetStatus (0);
          end;

          SERVICE_CONTINUE_PENDING,   // Thaw the execute thread.
          SERVICE_START_PENDING:
          begin
            ResumeThread (fExecuteThread);
            fServiceStatus.dwCurrentState := SERVICE_RUNNING;
            fServiceStatus.dwControlsAccepted := SERVICE_ACCEPT_STOP or SERVICE_ACCEPT_PAUSE_CONTINUE or SERVICE_ACCEPT_SHUTDOWN;
            SetStatus (0);
          end
        end
      end
    until fTerminated;

    fServiceStatus.dwCurrentState := SERVICE_STOP_PENDING;
    SetStatus (1000);
  end;
                                     // Wait for the execute thread to terminate.

  WaitForSingleObject (fExecuteThread, INFINITE);
  fServiceStatus.dwCurrentState := SERVICE_STOPPED;
  SetStatus (0);

  CloseHandle (fStatusEvent);
  CloseHandle (fExecuteThread);
  CloseHandle (fTerminateEvent);
end;

(*------------------------------------------------------------------------*
 | function TNTService.GetRegistryRoot : string                           |
 |                                                                        |
 | Gets the registry key for the service                                  |
 *------------------------------------------------------------------------*)
function TNTService.GetRegistryRoot : string;
begin
  result := 'SYSTEM\CurrentControlSet\Services\' + fServiceName
end;

(*------------------------------------------------------------------------*
 | procedure TNTService.PreRegisterInitisilize                            |
 |                                                                        |
 | Stub function.  Can be overridden if required.                         |
 *------------------------------------------------------------------------*)
function TNTService.PreRegisterInitialize : boolean;
begin
  result := True;
end;

(*------------------------------------------------------------------------*
 | procedure TNTService.PostRegisterInitisilize                           |
 |                                                                        |
 | Stub function.  Can be overridden if required.                         |
 *------------------------------------------------------------------------*)
function TNTService.PostRegisterInitialize : boolean;
begin
  result := True;
end;

(*------------------------------------------------------------------------*
 | procedure TNTService.Execute                                           |
 |                                                                        |
 | Stub function.  Beeps every two seconds. Will (usually!) be overridden.|
 *------------------------------------------------------------------------*)
function TNTService.Execute : Integer;
begin
  while ExecuteDelay (2000) do windows.Beep (440, 100);
  result := 0;
end;

(*------------------------------------------------------------------------*
 | procedure TNTService.Installed                                         |
 |                                                                        |
 | Stub function.  Can be overridden if required (eg. to set initial      |
 | default registry entries.)                                             |
 *------------------------------------------------------------------------*)
procedure TNTService.Installed;
begin
end;

(*------------------------------------------------------------------------*
 | procedure TNTService.Deleted                                           |
 |                                                                        |
 | Stub function.  Can be overridden if required (eg. to remove registry  |
 | entries.)                                                              |
 *------------------------------------------------------------------------*)
procedure TNTService.Deleted;
begin
end;
procedure TNTService.Stopped;
begin
end;
procedure TNTService.Started;
begin
end;

(*------------------------------------------------------------------------*
 | procedure TNTService.InstallService                                    |
 |                                                                        |
 | This is called when the program is run with a -i parameter to install  |
 | the service with NT.                                                   |
 *------------------------------------------------------------------------*)
procedure TNTService.InstallService;
var
  moduleName : array [0..MAX_PATH] of char;
  machineName : array [0..MAX_COMPUTERNAME_LENGTH] of char;
  size : Integer;
  serviceDatabaseHandle : SC_HANDLE;
  serviceHandle : SC_HANDLE;
  serviceDatabaseLock : SC_LOCK;
begin
  GetModuleFileName (0, moduleName, sizeof (moduleName));
  size := sizeof (machineName);
  GetComputerName (machineName, size);

  // Open the NT Service Control Manager

  serviceDatabaseHandle := OpenSCManager (machineName, Nil, SC_MANAGER_CREATE_SERVICE or SC_MANAGER_LOCK);
  if serviceDatabaseHandle = 0 then
    raise ENTException.CreateLastError;

  try
  // Lock the NT service database.
    serviceDatabaseLock := LockServiceDatabase (serviceDatabaseHandle);
    if serviceDatabaseLock = Nil then
      raise ENTException.CreateLastError;
    try

  // Register the service with NT

      serviceHandle := CreateService (serviceDatabaseHandle, pChar (fServiceName), pChar (fDisplayName),
                                      SERVICE_START or SERVICE_ALL_ACCESS, SERVICE_WIN32_OWN_PROCESS or SERVICE_INTERACTIVE_PROCESS , SERVICE_AUTO_START, SERVICE_ERROR_NORMAL,
                                      moduleName, Nil, Nil, Nil, Nil, Nil);

      if serviceHandle = 0 then
        raise ENTException.CreateLastError
      else 
         Installed;    // Perform user-defined post-installation stuff.
      CloseServiceHandle (serviceHandle);
    finally
      UnlockServiceDatabase (serviceDatabaseLock);
    end;
  finally
    CloseServiceHandle (serviceDatabaseHandle)
  end
end;

(*------------------------------------------------------------------------*
 | procedure TNTService.UninstallService                                  |
 |                                                                        |
 | Uninstall the service (from NT)                                        |
 *------------------------------------------------------------------------*)
procedure TNTService.UninstallService;
var
  moduleName : array [0..MAX_PATH] of char;
  machineName : array [0..MAX_COMPUTERNAME_LENGTH] of char;
  size : Integer;
  serviceDatabaseHandle, serviceHandle : SC_HANDLE;
  serviceDatabaseLock : SC_LOCK;

begin
  GetModuleFileName (0, moduleName, sizeof (moduleName));
  size := sizeof (machineName);
  GetComputerName (machineName, size);

  // Open the NT Service Control Manager
  serviceDatabaseHandle := OpenSCManager (machineName, Nil, SC_MANAGER_CREATE_SERVICE or SC_MANAGER_LOCK);

  if serviceDatabaseHandle = 0 then
    raise ENTException.CreateLastError;

  try
  // Lock the NT service database.
    serviceDatabaseLock := LockServiceDatabase (serviceDatabaseHandle);
    if serviceDatabaseLock = Nil then
      raise ENTException.CreateLastError;

    try

  // Open the service
      serviceHandle := OpenService (serviceDatabaseHandle, PChar (fServiceName), SERVICE_ALL_ACCESS);

      if serviceHandle = 0 then
        raise ENTException.CreateLastError;

      try

  // Delete the service

        if not DeleteService (serviceHandle) then
          raise ENTException.CreateLastError;

        Deleted;                             // Perform user-defined post deletion processing

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
procedure TNTService.CtrlService(ControlType:TControlType);
var
  moduleName : array [0..MAX_PATH] of char;
  machineName : array [0..MAX_COMPUTERNAME_LENGTH] of char;
  size : Integer;
  serviceDatabaseHandle, serviceHandle : SC_HANDLE;
  ServiceStatus:TServiceStatus;
  Res:Boolean;
  DummyParam:PChar;
begin
  DummyParam:=nil;
  GetModuleFileName (0, moduleName, sizeof (moduleName));
  size := sizeof (machineName);
  GetComputerName (machineName, size);

  // Open the NT Service Control Manager
  serviceDatabaseHandle := OpenSCManager (machineName, Nil, SC_MANAGER_CREATE_SERVICE or SC_MANAGER_LOCK);

  if serviceDatabaseHandle = 0 then
    raise ENTException.CreateLastError;

  try

  // Open the service
      serviceHandle := OpenService (serviceDatabaseHandle, PChar (fServiceName),SERVICE_START or SERVICE_ALL_ACCESS);

      if serviceHandle = 0 then
        raise ENTException.CreateLastError;
      try

  // Start the service
     Res:=True;
     case ControlType of
        ctStart    : begin
                        Res:=StartService(serviceHandle,0,DummyParam);
                        Started;
                     end;
        ctStop     : begin
                        Res:=ControlService(serviceHandle,SERVICE_CONTROL_STOP,ServiceStatus);
                        Stopped;
                     end;
        ctPause    : begin
                        Res:=ControlService(serviceHandle,SERVICE_CONTROL_PAUSE,ServiceStatus);
                     end;
        ctContinue : begin
                        Res:=ControlService(serviceHandle,SERVICE_CONTROL_CONTINUE,ServiceStatus);
                     end;     
      end;
      if not Res then
        raise ENTException.CreateLastError;
      finally        
        CloseServiceHandle (serviceHandle);
      end;

  finally
    CloseServiceHandle (serviceDatabaseHandle);
  end
end;
(*------------------------------------------------------------------------*
 | procedure TNTService.ExecuteDelay                                      |
 |                                                                        |
 | Delay for a specified number of milliseconds, or   until the service   |
 | terminated.                                                            |
 |                                                                        |
 | Parameters:                                                            |
 |   nMilliseconds : Integer   The time to delay                          |
 |                                                                        |
 | The function returns FALSE if the service should be terminated.        |
 *------------------------------------------------------------------------*)
function TNTService.ExecuteDelay (nMilliseconds : Integer) : boolean;
begin
  WaitForSingleObject (fTerminateEvent, nMilliseconds);
  result := not fTerminated;
end;

end.
