unit TaskKillerU;

// unit dependant on PSAPI.DLL (available on NT and XP [NOT 2000])
// copying NT's version to a Windows 2000 Machine works fine
// need to add Windows 2000 routines:
// i.e.
//uses TLHelp32
//
//  Info: TOSVersionInfoA;
//
//  Info.dwOSVersionInfoSize:=sizeof(Info);
//  GetVersionEx(Info);
//  ResultLines.Add('MajorVersion - '+IntToStr(Info.dwMajorVersion));
//  ResultLines.Add('MinorVersion - '+IntToStr(Info.dwMinorVersion));
//  ResultLines.Add('BuildNumber - '+IntToStr(Info.dwBuildNumber));
//  case Info.dwPlatformID of
//    VER_PLATFORM_WIN32s:        ResultLines.Add('Win32 on Windows 3.1');
//    VER_PLATFORM_WIN32_WINDOWS: ResultLines.Add('Win32 on Windows 95/98');
//    VER_PLATFORM_WIN32_NT:      ResultLines.Add('Win32 on Windows NT');
//    else ResultLines.Add('Win32 on platform '+IntToStr(Info.dwPlatformID));
//  end;
//
//proocedure FillList(ResultLines:TStrings);
//var
//  MyHandle: THandle;
//  Struct: TProcessEntry32;
//begin
//  try
//     MyHandle:=CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
//     Struct.dwSize:=Sizeof(TProcessEntry32);
//     if Process32First(MyHandle, Struct) then
//       ResultLines.Add(Struct.szExeFile);
//     while Process32Next(MyHandle, Struct) do
//       ResultLines.Add(Struct.szExeFile);
//  except
//  end;
//end;


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;
type
   TEnumProcesses      = function (lpidProcess:PDWORD;cb:DWORD;cbNeeded:PDWORD):BOOL; stdcall;
   TEnumProcessModules = function (hProcess:THandle;hModule:PHandle;sizeofhModule:Integer;cbReturned:PInteger):BOOL; stdcall;
   TGetModuleBaseName  = function (hProcess:THandle;hModule:THandle;ProcessName:PChar;Length:PDWORD):DWORD; stdcall;

const
   NumbCorvusProcesses = 27;
   CorvusProcesses:Array[0..NumbCorvusProcesses-1] of String = (
     'Accounts'    ,'BotswanaPost','BermudaPost'   ,'CompMan'   ,
     'CompLoad'    ,'Counters'    ,'DatabaseServer','ErrHand'   ,
     'GhanaPost'   ,'GuernseyPost','HookUp'        ,'Hotkeys'   ,
     'PakistanPost','Period'      ,'PictureServer' , 'QatarPost',
     'RefServer'   ,'Stock'       ,'TanzaniaPost','Transact'    ,
     'Translator'  ,'TxnLog'      ,'UgandaPost'  ,'SwazilandPost' ,'Umanager'  ,
     'Usermanager' ,'OmanPost'
   );
   NumbSubProcesses = 17;
   CorvusSubProcesses:Array[0..NumbSubProcesses-1] of String = (
     'Accounts'      ,'CompMan'   ,'CompLoad' ,'Counters',
     'DatabaseServer','ErrHand'   ,'HookUp'   ,'Hotkeys' ,
     'PictureServer' ,'Period'    ,'RefServer','Stock'   ,
     'Transact'      ,'Translator','TxnLog'   ,'Umanager',
     'Usermanager'
   );

var
  LibHandle         :THandle;
  EnumProcesses     :TEnumProcesses     ;
  EnumProcessModules:TEnumProcessModules;
  GetModuleBaseName :TGetModuleBaseName ;

procedure KillCorvus;
procedure KillCorvusSubs;
procedure KillApp(ProcName:String);
procedure FillList(List:TStrings);
procedure TerminateCorvusServiceProcess;
function GetProcessIDOfCorvusService:Integer;
function CountOfThisProcess:Integer;

implementation

procedure TerminateCorvusServiceProcess;
var
   ProcessIDS,P:PDWORD;
   hProcess:THandle;
   hModule:THandle;
   RetSize:DWORD;
   ProcCount:DWORD;
   I:Integer;
   Name:String;
   NameLen:Integer;
   Done:Boolean;
begin
   if @EnumProcesses = nil then
   begin
      Exit;
   end;
   Done:=False;
   GetMem(ProcessIDS,SizeOf(DWORD)*1024);
   EnumProcesses(ProcessIDS,SizeOf(DWORD)*1024,@ProcCount);
   P:=ProcessIDS;
   for I:=0 to ProcCount-1 do
   begin
      hProcess:=OpenProcess(PROCESS_ALL_ACCESS,False,P^);
      if hProcess <> 0 then
      begin
         if (EnumProcessModules(hProcess,@hModule,sizeof(hModule),@RetSize)) then
         begin
            NameLen:=MAX_PATH;
            SetLength(Name,NameLen);
            GetModuleBaseName(hProcess,hModule,PChar(Name),@NameLen);
            Name:=UpperCase(StrPas(PChar(Name)));
            if Name = 'CORVUSSERVICE.EXE' then
            begin
               TerminateProcess(hProcess,0);
               Done:=True;
            end;
         end;
         CloseHandle(hProcess);
      end;
      Inc(P);
      if Done then Break;
   end;
   FreeMem(ProcessIDS);
end;

function GetProcessIDOfCorvusService:Integer;
var
   ProcessIDS,P:PDWORD;
   hProcess:THandle;
   hModule:THandle;
   RetSize:DWORD;
   ProcCount:DWORD;
   I:Integer;
   Name:String;
   NameLen:Integer;
begin
   Result:=0;
   if @EnumProcesses = nil then
   begin
      Exit;
   end;
   GetMem(ProcessIDS,SizeOf(DWORD)*1024);
   EnumProcesses(ProcessIDS,SizeOf(DWORD)*1024,@ProcCount);
   P:=ProcessIDS;
   for I:=0 to ProcCount-1 do
   begin
      hProcess:=OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False,P^);
      if hProcess <> 0 then
      begin
         if (EnumProcessModules(hProcess,@hModule,sizeof(hModule),@RetSize)) then
         begin
            NameLen:=MAX_PATH;
            SetLength(Name,NameLen);
            GetModuleBaseName(hProcess,hModule,PChar(Name),@NameLen);
            Name:=UpperCase(StrPas(PChar(Name)));
            if Name = 'CORVUSSERVICE.EXE' then
               Result:=P^;
         end;
         CloseHandle(hProcess);
      end;
      Inc(P);
      if Result <> 0 then Break;
   end;
   FreeMem(ProcessIDS);
end;

procedure KillApp(ProcName:String);
var
   ProcessIDS,P:PDWORD;
   hProcess:THandle;
   hModule:THandle;
   RetSize:DWORD;
   ProcCount:DWORD;
   I:Integer;
   Name:String;
   NameLen:Integer;
begin
   if @EnumProcesses = nil then
   begin
      Exit;
   end;
   GetMem(ProcessIDS,SizeOf(DWORD)*1024);
   EnumProcesses(ProcessIDS,SizeOf(DWORD)*1024,@ProcCount);
   P:=ProcessIDS;
   for I:=0 to ProcCount-1 do
   begin
      hProcess:=OpenProcess(PROCESS_ALL_ACCESS, False,P^);
      if hProcess <> 0 then
      begin
         if (EnumProcessModules(hProcess,@hModule,sizeof(hModule),@RetSize)) then
         begin
            NameLen:=MAX_PATH;
            SetLength(Name,NameLen);
            GetModuleBaseName(hProcess,hModule,PChar(Name),@NameLen);
            Name:=UpperCase(StrPas(PChar(Name)));
            if Name = UpperCase(ProcName) then
            begin
               TerminateProcess(hProcess,0);
               break;
            end;
         end;
         CloseHandle(hProcess);
      end;
      Inc(P);
   end;
   FreeMem(ProcessIDS);
end;
procedure KillCorvus;
var
   ProcessIDS,P:PDWORD;
   hProcess:THandle;
   hModule:THandle;
   RetSize:DWORD;
   ProcCount:DWORD;
   I,J:Integer;
   Name:String;
   NameLen:Integer;
begin
   if @EnumProcesses = nil then
   begin
      Exit;
   end;
   GetMem(ProcessIDS,SizeOf(DWORD)*1024);
   EnumProcesses(ProcessIDS,SizeOf(DWORD)*1024,@ProcCount);
   P:=ProcessIDS;
   for I:=0 to ProcCount-1 do
   begin
      hProcess:=OpenProcess(PROCESS_ALL_ACCESS, False,P^);
      if hProcess <> 0 then
      begin
         if (EnumProcessModules(hProcess,@hModule,sizeof(hModule),@RetSize)) then
         begin
            NameLen:=MAX_PATH;
            SetLength(Name,NameLen);
            GetModuleBaseName(hProcess,hModule,PChar(Name),@NameLen);
            Name:=UpperCase(StrPas(PChar(Name)));
            for J:=0 to NumbCorvusProcesses-1 do
            begin
               if Name = UpperCase(CorvusProcesses[J]+'.EXE') then
               begin
                  TerminateProcess(hProcess,0);
                  break;
               end;
            end;
         end;
         CloseHandle(hProcess);
      end;
      Inc(P);
   end;
   FreeMem(ProcessIDS);
end;
procedure KillCorvusSubs;
var
   ProcessIDS,P:PDWORD;
   hProcess:THandle;
   hModule:THandle;
   RetSize:DWORD;
   ProcCount:DWORD;
   I,J:Integer;
   Name:String;
   NameLen:Integer;
begin
   if @EnumProcesses = nil then
   begin
      Exit;
   end;
   GetMem(ProcessIDS,SizeOf(DWORD)*1024);
   EnumProcesses(ProcessIDS,SizeOf(DWORD)*1024,@ProcCount);
   P:=ProcessIDS;
   for I:=0 to ProcCount-1 do
   begin
      hProcess:=OpenProcess(PROCESS_ALL_ACCESS, False,P^);
      if hProcess <> 0 then
      begin
         if (EnumProcessModules(hProcess,@hModule,sizeof(hModule),@RetSize)) then
         begin
            NameLen:=MAX_PATH;
            SetLength(Name,NameLen);
            GetModuleBaseName(hProcess,hModule,PChar(Name),@NameLen);
            Name:=UpperCase(StrPas(PChar(Name)));
            for J:=0 to NumbSubProcesses-1 do
            begin
               if Name = UpperCase(CorvusSubProcesses[J]+'.EXE') then
               begin
                  TerminateProcess(hProcess,0);
                  break;
               end;
            end;
         end;
         CloseHandle(hProcess);
      end;
      Inc(P);
   end;
   FreeMem(ProcessIDS);
end;
function CountOfThisProcess:Integer;
var
   ProcessIDS,P:PDWORD;
   hProcess:THandle;
   hModule:THandle;
   RetSize:DWORD;
   ProcCount:DWORD;
   I:Integer;
   Name:String;
   NameLen:Integer;
begin
   Result:=0;
   if @EnumProcesses = nil then
   begin
      Exit;
   end;
   GetMem(ProcessIDS,SizeOf(DWORD)*1024);
   EnumProcesses(ProcessIDS,SizeOf(DWORD)*1024,@ProcCount);
   P:=ProcessIDS;
   for I:=0 to ProcCount-1 do
   begin
      hProcess:=OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False,P^);
      if hProcess <> 0 then
      begin
         if (EnumProcessModules(hProcess,@hModule,sizeof(hModule),@RetSize)) then
         begin
            NameLen:=MAX_PATH;
            SetLength(Name,NameLen);
            GetModuleBaseName(hProcess,hModule,PChar(Name),@NameLen);
            Name:=UpperCase(StrPas(PChar(Name)));
            if Name = UpperCase(ExtractFileName(ParamStr(0))) then
               Result:=Result+1;
         end;
         CloseHandle(hProcess);
      end;
      Inc(P);
   end;
   FreeMem(ProcessIDS);
end;
procedure FillList(List:TStrings);
var
   ProcessIDS,P:PDWORD;
   hProcess:THandle;
   hModule:THandle;
   RetSize:DWORD;
   ProcCount:DWORD;
   I:Integer;
   Name:String;
   NameLen:Integer;
   J:Integer;
begin
   List.Clear;
   if @EnumProcesses = nil then
   begin
      Exit;
   end;
   GetMem(ProcessIDS,SizeOf(DWORD)*1024);
   EnumProcesses(ProcessIDS,SizeOf(DWORD)*1024,@ProcCount);
   P:=ProcessIDS;
   for I:=0 to ProcCount-1 do
   begin
      hProcess:=OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False,P^);
      if hProcess <> 0 then
      begin
         if (EnumProcessModules(hProcess,@hModule,sizeof(hModule),@RetSize)) then
         begin
            NameLen:=MAX_PATH;
            SetLength(Name,NameLen);
            GetModuleBaseName(hProcess,hModule,PChar(Name),@NameLen);
            Name:=UpperCase(StrPas(PChar(Name)));
            for J:=0 to NumbCorvusProcesses-1 do
            begin
               if Name = UpperCase(CorvusProcesses[J]+'.EXE') then
               begin
                  Name:='*'+Name;
                  break;
               end;
            end;
            if Name <> '' then
            begin
               if List.IndexOf(Name) = -1 then
                  List.Add(Name);
            end;
         end;
         CloseHandle(hProcess);
      end;
      Inc(P);
   end;
   FreeMem(ProcessIDS);
end;
initialization
   LibHandle:=LoadLibrary('PSAPI.DLL');
   if LibHandle <> 0 then
   begin
      @EnumProcesses     :=GetProcAddress(LibHandle,'EnumProcesses'     );
      @EnumProcessModules:=GetProcAddress(LibHandle,'EnumProcessModules');
      @GetModuleBaseName :=GetProcAddress(LibHandle,'GetModuleBaseNameA');
   end;

finalization
   if LibHandle <> 0 then
      FreeLibrary(LibHandle);
end.
