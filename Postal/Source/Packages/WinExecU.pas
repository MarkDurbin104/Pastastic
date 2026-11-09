unit WinExecU;

interface

uses
   Windows,Forms,SyncObjs,SysUtils;

function WinExecAndWait(Command:String;var Output:String;Show:Boolean):Boolean;
function WinExecAndWaitEnv(Command:String;var Output:String;Show:Boolean;EnvironmentString:String):Boolean;
function WinExecAndWaitEnvTC(Command:String;var Output:String;Show:Boolean;EnvironmentString:String;TC:TCriticalSection):Boolean;

implementation

function GetEnvVar(const EnvVarName:string):String;
begin
  SetLength(Result,1024);
  SetLength(Result,GetEnvironmentVariable(PChar(EnvVarName),PChar(Result),1024));
end;

function GetStdOut(PipeOut:THandle):String;
const 
   BufSize = 4096;
var
   Count:DWord;
   S:String;
begin
   Result:='';
   SetLength(S,BufSize);
   Count:=BufSize;
   while PeekNamedPipe(PipeOut,PChar(S),BufSize,@Count,nil,nil) do
   begin
      if Count <= 0 then Exit;
      ReadFile(PipeOut,PChar(S)^,BufSize,Count,nil);
      if Count > 0 then
      begin
         SetLength(S,Count);
         Result:=Result+S;
         Count:=BufSize;
         SetLength(S,BufSize);
      end;
   end;
end;
function WinExecAndWait(Command:String;var Output:String;Show:Boolean):Boolean;
begin
   Result:=WinExecAndWaitEnvTC(Command,Output,Show,'',nil);
end;
function WinExecAndWaitEnv(Command:String;var Output:String;Show:Boolean;EnvironmentString:String):Boolean;
begin
   Result:=WinExecAndWaitEnvTC(Command,Output,Show,EnvironmentString,nil);
end;
function WinExecAndWaitEnvTC(Command:String;var Output:String;Show:Boolean;EnvironmentString:String;TC:TCriticalSection):Boolean;
var
   ProcCmd   :String;
   SecAttrib :TSecurityAttributes;
   StartInfo :TStartUpInfo;
   ProcInfo  :TProcessInformation;
   PipeInput :THandle;
   PipeOutput:THandle;
   ExitState :DWord;
begin
   Output:='';
   Result:=False;

   ZeroMemory(@StartInfo,sizeof(StartInfo));
   StartInfo.cb:=sizeof(StartInfo);
   ZeroMemory(@SecAttrib,sizeof(SecAttrib));
   SecAttrib.nLength:=sizeof(SecAttrib);

   ProcCmd:=GetEnvVar('COMSPEC')+' /C '+Command;

   if Show then
   begin
      StartInfo.dwFlags:=STARTF_USESHOWWINDOW;
      StartInfo.wShowWindow:=SW_SHOW;
   end
   else
   begin
      SecAttrib.bInheritHandle:=True;
      if not CreatePipe(PipeOutput,PipeInput,@SecAttrib,0) then
      begin
         OutPut:='Error : '+IntToStr(GetLastError);
         Exit;
      end;
      StartInfo.dwFlags:=STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      StartInfo.wShowWindow:=SW_HIDE;
      StartInfo.hStdOutput:=PipeInput;
      StartInfo.hStdError :=PipeInput;
   end;
   try
      if CreateProcess(nil,PChar(ProcCmd),nil,nil,not Show,
                       NORMAL_PRIORITY_CLASS {or CREATE_NEW_CONSOLE},
                       PWideChar(EnvironmentString),nil,StartInfo,ProcInfo) then
      begin
         if TC <> nil then TC.Leave;
         while WaitForSingleObject(ProcInfo.hProcess,50) <> WAIT_OBJECT_0 do
         begin
            Application.ProcessMessages;
            if not Show then OutPut:=OutPut+GetStdOut(PipeOutput);
         end;
         while GetExitCodeProcess(ProcInfo.hProcess,ExitState)
         and  (ExitState = STILL_ACTIVE) do
            Application.ProcessMessages;
         if not Show then OutPut:=OutPut+GetStdOut(PipeOutput);
      end
      else
      begin
         Result:=False;
         OutPut:=OutPut+'Error : '+IntToStr(GetLastError);
      end;
   finally
      if not Show then
      begin
         CloseHandle(PipeInput);
         CloseHandle(PipeOutput);
      end;
   end;
end;

end.
