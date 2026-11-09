unit CorvusServiceU;

interface
uses
	afpEventLog,
   SysUtils,Registry,Classes,
   Forms,Windows,ActiveX,ComObj,ComServ,
   NTService,GPCSGUID,GPCSBase_TLB,GPCSBaseAU;

type
   TDllFunc = procedure;
   TCorvusService = class(TNTService)
   protected
     procedure RunCorvusService;
     function StartUpFunction(DLLFileName:String):TDllFunc;
     function GetDllPath(var Restart:Boolean):String;
   public
     procedure Log(Msg:String);
     function Execute:Integer; override;
   end;

procedure StartUpService(ServiceName,DisplayName:String);
procedure ServiceError(E:Exception;EMessage:String);

implementation

procedure StartUpService(ServiceName,DisplayName:String);
var
   CorvusService:TCorvusService;
begin
   CorvusService:=TCorvusService.Create(ServiceName,DisplayName);
   CorvusService.Run;
   CorvusService.Free;
end;
{TCorvusService}

procedure TCorvusService.Log(Msg:String);
begin
  if FLogging then 
  begin
     if fNonServiceMode then 
        WriteLn(Msg)
     else
        LogMessage(Msg);
  end;
end;
function TCorvusService.GetDllPath(var Restart:Boolean):String;
var
   CLSID:String;
   SL:TStringList;
begin
   try
      CLSID:='';
      Result:='';
      with TRegistry.Create do
      begin
         RootKey:=HKEY_LOCAL_MACHINE;
         if OpenKey('SOFTWARE\PSL\CorvusService',False) then
         begin
            Result:=ReadString('DLLName');
            if ReadString('Restart DLL') = '1' then
               Restart:=True;
            Log('DLL ='+Result);
            CloseKey;
         end;
         if Restart and OpenKey('SOFTWARE\PSL\CorvusService',True) then
         begin
            WriteString('Restart DLL','0');
            CloseKey;
         end;
         Free;
      end;
      if Result <> '' then
      begin
         if FileExists(Result+'.Replace') then
         begin
             SL:=TStringList.Create;
             SL.LoadFromFile(Result+'.Replace');
             DeleteFile(PChar(Result+'.Replace'));
             Log('Replace File Found ='+Result+'.Replace');
             if (SL.Count > 0) and (SL[0] <> '') then
             begin
                Result:=Trim(SL[0]);
                with TRegistry.Create do
                try
                   RootKey:=HKEY_LOCAL_MACHINE;
                   if OpenKey('SOFTWARE\PSL\CorvusService',True) then
                   begin
                      WriteString('DLLName',Result);
                      Log('New Reg Entry ='+Result);
                      CloseKey;
                   end;
                   Free;
                except
                   on E : Exception do
                      ServiceError(E,'{BD10C1B0-05BD-4F5B-97F9-0AF92020DCDE}');
                end;
             end;
             SL.Free;
         end;
      end;
   except
      on E : Exception do
         ServiceError(E,'{214EBF47-EF47-439F-92B2-245EEBA6C0FB}');
   end;  
end;
function TCorvusService.StartUpFunction(DLLFileName:String):TDllFunc;
var
   DLLFunc:TDllFunc;
const
   DLLHandle:THandle = 0;
begin
   Result:=nil;
   try
      if DLLFileName = '' then Exit;
      if (DLLFileName = 'Release') and (DLLHandle <> 0) then
      begin
         Log('Running Shutdown');
         @DLLFunc:=GetProcAddress(DLLHandle,'ShutDown');
         if @DLLFunc <> nil then
            DLLFunc;
         FreeLibrary(DLLHandle);
         DLLHandle:=0;
         Exit;
      end;
      if (DLLFileName = 'Timer') and (DLLHandle <> 0) then
      begin
         @DLLFunc:=GetProcAddress(DLLHandle,'Timer');
         if @DLLFunc <> nil then
            DLLFunc;
         Exit;
      end;
      DLLHandle:=LoadLibrary(PChar(DLLFileName));
      if DLLHandle <> 0 then
      begin
         Log('LoadLibrary '+DLLFileName);
         @Result:=GetProcAddress(DLLHandle,PChar('StartUp'));
      end;
   except
      on E : Exception do
         ServiceError(E,'{41DBA8EE-8337-42F7-9C72-5F29D1FC7F86}');
   end;  
end;

procedure TCorvusService.RunCorvusService;
var
   DLLFileName:String;
   DllFunc:TDllFunc;
   Restart:Boolean;
const
    OldDLLFileName:String = '';
begin
   try
      DLLFileName:=GetDllPath(Restart);
      if (OldDLLFileName <> DLLFileName) or Restart then
      begin
         if Restart or (OldDLLFileName <> '') then
         begin
            StartUpFunction('Release');
         end;
         OldDLLFileName:=DLLFileName;

         if DLLFileName <> '' then
         begin
            if Restart then
               ExecuteDelay(1000);
            DllFunc:=StartUpFunction(DLLFileName);
            if @DllFunc <> nil then
            begin
               DllFunc;
            end;
         end;
      end;
   except
      on E : Exception do
         ServiceError(E,'{63C33C33-2B08-49DD-9D60-01AF82A5330C}');
   end;
end;
procedure ServiceError(E:Exception;EMessage:String);
var
	EventLog : TafpEventLog;
begin
   EventLog:= TafpEventLog.Create(nil);
   try
     EventLog.ApplicationName    :='Corvus Service';
     EventLog.RegisterApplication:=True;
     EventLog.IncludeUserName    :=True;
     EventLog.EventType          :=etError;
     EventLog.EventID            :=0;
     EventLog.EventCategory      :=0;
     EventLog.LogEvent(EMessage+''+E.Message);
   finally
   	EventLog.Free;
   end;
end;

function TCorvusService.Execute:Integer;
var
   CheckDll:Integer;
const
   CheckLimit = 20;
begin
   try
      Log('Exceute');
      Result:=0;
      CheckDll:=0;
      while ExecuteDelay(50) do
      begin
         try
            Dec(CheckDll);
            if CheckDll <= 0 then
            begin
               CheckDll:=CheckLimit;
               RunCorvusService;
            end;
            StartUpFunction('Timer');
         except
            on E : Exception do
               ServiceError(E,'{F688439A-5A60-4C5A-AAE1-49EC569456D8}');
         end;
      end;
      StartUpFunction('Release');
    except
   	On E : Exception do
      begin
         ServiceError(E,'{26534CEC-AD8F-458E-8CAE-6B422EC9DA56}');
         Result:=1;
      end;
   end;
   Log('Exit');
end;
end.
 