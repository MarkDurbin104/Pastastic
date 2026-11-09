program Reboot;

uses
  Windows;

{$R *.res}

function GetOS:Integer;
var
  Info: TOSVersionInfoA;
begin
   Info.dwOSVersionInfoSize:=sizeof(Info);
   GetVersionEx(Info);
   Result:=Info.dwMajorVersion*100 + (Info.dwMinorVersion mod 100);
end;
procedure SetShutdownPrivilege;
var
   ProcHandle:THandle;
   TokHandle:THandle;
   TmpLUID:TLargeInteger;
   TokPriv:TTokenPrivileges;
   TokNew:TTokenPrivileges;
   BufferNeeded:DWord;
begin
   ProcHandle:=GetCurrentProcess;
   OpenProcessToken(ProcHandle,TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,TokHandle);
   LookupPrivilegeValue('','SeShutdownPrivilege',TmpLUID);
   TokPriv.PrivilegeCount:=1;
   TokPriv.Privileges[0].LUID:=TmpLUID;
   TokPriv.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED;
   AdjustTokenPrivileges(TokHandle,False,TokPriv,Sizeof(TokNew),TokNew,BufferNeeded);
end;
procedure Restart;
begin
   SetShutdownPrivilege;
   ExitWindowsEx(EWX_REBOOT,0)
end;
procedure Shutdown;
begin
   SetShutdownPrivilege;
   if GetOS < 500  then // NT does not support POWER OFF.
      ExitWindowsEx(EWX_SHUTDOWN,0)
   else
      ExitWindowsEx(EWX_SHUTDOWN or EWX_POWEROFF,0);
end;

begin
  Restart;
end.
