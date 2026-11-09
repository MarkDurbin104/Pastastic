unit SchedulerU;

interface

uses
  Windows,Forms,Classes,Controls,SysUtils,FileCtrl,
  WinExecU,PackStrListU,GPCSGUID,RASDialer,TxnTranslateU,MesQueueU,StringUtil;
  
const
   Interval1Week   = 7;
   Interval1Day    = 1;
   Interval1Hour   = (Interval1Day / 24);
   Interval1Minute = (Interval1Hour / 60);
   Interval1Second = (Interval1Minute / 60);

        
type
  TSchedule = class;
  TScheduler = class;
  TScheduleThread = class(TThread)
  public
     Schedule:TSchedule;
     procedure Execute; override;
  end;
  TSchedule = class(TObject)
   private
      FName           :String;
      FExecute        :String;
      FInterval       :TTime;
      FFromDT         :TDateTime;
      FToDT           :TDateTime;
      FLastRun        :TDateTime;
      FRelativeToLast :Boolean;
      FSkipMissed     :Boolean;
      FMustRunAll     :Boolean;
      FEnabled        :Boolean;
      FRunning        :Boolean;
      FOutput         :String;
      FRunError       :String;
      FScheduler      :TScheduler;
   public      
      constructor Create(Scheduler:TScheduler;Schedule:String);
      function AsString:String;
      procedure Run;
      property Name           :String    read FName           write FName          ;
      property Execute        :String    read FExecute        write FExecute       ;
      property Interval       :TTime     read FInterval       write FInterval      ;
      property FromDT         :TDateTime read FFromDT         write FFromDT        ;
      property ToDT           :TDateTime read FToDT           write FToDT          ;
      property LastRun        :TDateTime read FLastRun        write FLastRun       ;
      property RelativeToLast :Boolean   read FRelativeToLast write FRelativeToLast;
      property SkipMissed     :Boolean   read FSkipMissed     write FSkipMissed    ;
      property MustRunAll     :Boolean   read FMustRunAll     write FMustRunAll    ;
      property Enabled        :Boolean   read FEnabled        write FEnabled       ;
      property Running        :Boolean   read FRunning        write FRunning       ;
      property Output         :String    read FOutput         write FOutput        ;
      property RunError       :String    read FRunError       write FRunError      ;
  end;                                                   
  TExchanger = class(TObject)
    private
      RASDialer:TRASDialer;
      FConnecting:Boolean;
      FExchangeStatus:String;
      FHadReply:Boolean;
      function IsIPAddress(Value:String):Boolean;
      function Dial(DUNEntry:String):String;
      function ExchangeData(IPAddress:String;CommsLink:TCommsLink):Boolean;
      procedure SetStatus(Sender:TObject;Event:String);
      procedure OnConnect(Sender:TObject;Event:String);
      procedure OnDisConnect(Sender:TObject;Event:String);
      procedure RxCommand(CommandType:TCommandType;From,Data:String;var CanProcess:Boolean);
    public
      destructor Destroy; override;
      function ExchangeWith(DUNEntry:String;CommsLink:TCommsLink):Boolean;
      property ExchangeStatus:String read FExchangeStatus write FExchangeStatus;
  end;                          
  TScheduler = class(TObject)
   private
      FScheduleFile:String;
      FSchedules:TStringList;
      FCommsLink:TCommsLink;
   public
      constructor Create(ScheduleFile:String);
      destructor Destroy; override;
      procedure Check;
      function AsString:String;
      procedure Changed;
      procedure Add(Schedule:TSchedule);
      property CommsLink:TCommsLink read FCommsLink write FCommsLink;
  end;                
              
implementation
procedure LogError(GUID,E:String);
var
  SL:TStringList;
begin
  SL:=TStringList.Create;
  if FileExists('C:\Comms.log') then
     SL.LoadFromFile('C:\Comms.log');
  while SL.Count > 1000 do SL.Delete(SL.Count-1);
  SL.Insert(0,DateTimeToStr(Now)+' '+GUID+' '+E);
  SL.SaveToFile('C:\Comms.log');
  SL.Free;  
end;
procedure LogEvent(E:String);
begin
   LogError(E,'');
end;
procedure LogException(E:Exception;GUID:String);
begin 
   LogError('Exception:'+E.Message,GUID);
end;

destructor TExchanger.Destroy;
begin
   RASDialer.Free;
   RASDialer:=nil;
   inherited Destroy;
end;
procedure TExchanger.SetStatus(Sender:TObject;Event:String);
begin
   FExchangeStatus:=FExchangeStatus+Event+#13#10;
end;
procedure TExchanger.OnConnect(Sender:TObject;Event:String);
begin
   FConnecting:=False;
end;
procedure TExchanger.OnDisConnect(Sender:TObject;Event:String);
begin
   FConnecting:=False;
end;
procedure TExchanger.RxCommand(CommandType:TCommandType;From,Data:String;var CanProcess:Boolean);
begin
   case CommandType of
      ctGetData : CanProcess:=True;
   end;   
   CanProcess:=True;
   FHadReply:=True;
end;
function TExchanger.ExchangeData(IPAddress:String;CommsLink:TCommsLink):Boolean;
var
   TimeLimit:TTime;
begin
   Result:=False;
   if IPAddress = '' then Exit;
   CommsLink.OnRxCommand:=RxCommand;
   if StrToInt(GetGPCSRegString('OfficeInfo','Office ID','9999')) = 0 then
      CommsLink.Send(ctGetData,IPAddress,'')
   else
      CommsLink.Send(ctSetData,IPAddress,GetTransferData(''));
   TimeLimit:=Now+(Interval1Minute*10);
   if RASDialer.Connected then
   begin
      while (not FHadReply) and (not (Application.Terminated)) and (RASDialer.Connected) do
      begin
         RASDialer.CheckConnectStatus;
         Sleep(1);
         Application.ProcessMessages;
         if TimeLimit <= Now then 
            break;
      end;
   end
   else
   begin
      while (not FHadReply) and (not (Application.Terminated)) do
      begin
         Sleep(1);
         Application.ProcessMessages;
         if TimeLimit <= Now then                
            break;
      end;
   end;
   Result:=FHadReply;
end;
function TExchanger.Dial(DUNEntry:String):String;
var
   SL:TStringList;
   User,Pass,Phone,Dom:String;
begin
   Result:='';
   SL:=TStringList.Create;
   SL.CommaText:=RASDialer.GetPhoneBookEntries;
   if SL.IndexOf(DUNEntry) <> -1 then
   begin
      RasDialer.GetEntry(DUNEntry,User,Pass,Phone,Dom);
      RASDialer.OnConnectEvent:=SetStatus   ;
      RASDialer.OnConnected   :=OnConnect   ;
      RASDialer.OnDisConnected:=OnDisConnect;
      FConnecting:=True;
      RASDialer.Phone(DUNEntry);
      while FConnecting and (not Application.Terminated) do
      begin
         Sleep(1);
         Application.ProcessMessages;
      end;
      if RASDialer.Connected then
         Result:=RASDialer.ServerIPAddress;
   end;
end;
function TExchanger.IsIPAddress(Value:String):Boolean;
var
   I,DC:Integer;
begin
   Result:=False;
   DC:=0;
   for I:=1 to Length(Value) do
   begin
      if not (Value[I] in ['0'..'9','.']) then Exit;
      if Value[I] = '.' then Inc(DC);
   end;
   Result:=DC=3;
end;
function TExchanger.ExchangeWith(DUNEntry:String;CommsLink:TCommsLink):Boolean;
var
   IPAddress:String;
begin
   if RASDialer = nil then
      RASDialer:=TRASDialer.Create;
   FExchangeStatus:='';
   if IsIPAddress(DUNEntry) then
      IPAddress:=DUNEntry
   else
      IPAddress:=Dial(DUNEntry);
   Result:=ExchangeData(IPAddress,CommsLink);
end;
procedure CopyAFile(FileName,FromPath,ToPath:String);
begin
   if not FileExists(ExtractFilePath(ToPath+'\'+FileName)) then
      ForceDirectories(ExtractFilePath(ToPath+'\'+FileName));
   CopyFile(PChar(FromPath+'\'+FileName),PChar(ToPath+'\'+FileName),False);
end;
procedure PerformBackup;
var
   Day:Integer;
   ToPath:String;
   FromPath:String;
   I:Integer;
const
   Days:Array[0..6] of String = ('Saturday','Sunday','Monday','Tuesday','Wedensday','Thursday','Friday');
   FileCount = 26;
   Files:Array[0..FileCount-1] of String = ('Database\Txnlog.db','Database\Txnlog.mb',
                                  'Database\Txnlog.px',          'Database\Txnlog.xg1',
                                  'Database\Txnlog.yg1',         'Database\Txnlog.xg0',
                                  'Database\Txnlog.yg0',         'Binary\Stock.dat',
                                  'Database\MOIssue.DB',         'Database\MOPaid.DB',
                                  'Database\MOStatus.DB',        'Database\MOStatusChange.DB',
                                  'Database\CustomerDetails.DB', 'Database\CustomerTransactions.DB',
                                  'Database\MOIssue.PX',         'Database\MOPaid.PX',
                                  'Database\MOStatus.PX',        'Database\MOStatusChange.PX',
                                  'Database\CustomerDetails.PX', 'Database\CustomerTransactions.PX',
                                  'Database\MOIssue.VAL',        'Database\MOPaid.VAL',
                                  'Database\MOStatus.VAL',       'Database\MOStatusChange.VAL',
                                  'Database\CustomerDetails.VAL','Database\CustomerTransactions.VAL');
begin
   try
      FromPath:=GetGPCSRegString('Backup','From','C:\Tan');
      SetGPCSRegString('Backup','From',FromPath);
      Day:=Trunc(Now);
      Day:=Day mod 7;
      ToPath:=GetGPCSRegString('Backup','Path A','C:\Backup');
      if ToPath <> '' then
      begin
         SetGPCSRegString('Backup','Path A',ToPath);
         ToPath:=ToPath+'\'+Days[Day];
         if not FileExists(ToPath) then ForceDirectories(ToPath);
         for I:=0 to FileCount-1 do
         begin
            CopyAFile(Files[I],FromPath,ToPath);
            Windows.Beep(3000,100);
         end;
      end;
      ToPath:=GetGPCSRegString('Backup','Path B','');
      if ToPath <> '' then
      begin
         ToPath:=ToPath+'\'+Days[Day];
         if not FileExists(ToPath) then ForceDirectories(ToPath);
         for I:=0 to FileCount-1 do
         begin
            CopyAFile(Files[I],FromPath,ToPath);
            Windows.Beep(3000,100);
         end;
      end;
      SetGPCSRegString('Backup','Last Performed',DateToStr(Now));
   except
      on E:Exception do
      begin
         LogException(E,'{57517FA8-B8DD-4506-BB89-D8B3224CA138}');
         SetGPCSRegString('Backup','Last Performed','Error on '+DateToStr(Now));
      end;
   end;
   Windows.Beep(500,200);
end;
{TScheduleThread}
procedure TScheduleThread.Execute;
var
   S:String;
   SL:TPackStringList;
   Exchanger:TExchanger;
begin
   Schedule.Running:=True;
   Schedule.RunError:='';
   try
      if UpperCase(Schedule.Execute) = 'BACKUP' then
      begin
         Schedule.FFromDT:=Trunc(Now)+1;
         Schedule.LastRun:=Now;
         Schedule.FScheduler.Changed;
         PerformBackup;
         Schedule.Output:='';
         Schedule.Running:=False;
         LogEvent('Backup Performed');
         Exit;
      end            
      else if UpperCase(Copy(Schedule.Execute,1,8)) = 'EXCHANGE' then
      begin
         Schedule.FFromDT:=Now+Schedule.Interval;
         Schedule.LastRun:=Now;
         Schedule.FScheduler.Changed;
         Exchanger:=TExchanger.Create;
         if not Exchanger.ExchangeWith(Copy(Schedule.Execute,10,Length(Schedule.Execute)),Schedule.FScheduler.CommsLink) then
         begin
           SL:=TPackStringList.Create;
           SL.Text:='Error Connecting with '+Copy(Schedule.Execute,10,Length(Schedule.Execute))+#13#10+Exchanger.ExchangeStatus;
           Schedule.RunError:=SL.PackText;
           LogEvent(SL.PackText);
           SL.Free;
//           Schedule.FFromDT:=Now+Interval1Minute*2; // try again in 2 Minutes
           Schedule.FFromDT:=Now+Interval1Minute; // try again in 1 Minute
           Schedule.LastRun:=0;
           Schedule.FScheduler.Changed;
           Exchanger.Free;
           Schedule.Running:=False;
           Exit;
         end
         else
           LogEvent('Exchange with '+Copy(Schedule.Execute,10,Length(Schedule.Execute))+' complete');
            
         Exchanger.Free;
      end
      else
      begin
         WinExecAndWait(Schedule.Execute,S,False);
         LogEvent('Executed '+Schedule.Execute);
      end;
   except
      on E:Exception do
      begin
         Schedule.RunError:=E.Message;
         LogException(E,'{E41691D8-B6F4-48F9-AD6E-C254CFC09CB4}');
      end;
   end;
   Schedule.Running:=False;
   if S <> '' then
   begin
     SL:=TPackStringList.Create;
     SL.Text:=S;
     Schedule.Output:=SL.PackText;
     LogEvent('Execute Output '+SL.PackText);
     SL.Free;
   end              
   else 
   begin
      Schedule.Output:='';
   end;
   Schedule.LastRun:=Now;
   Schedule.FScheduler.Changed;
end;
{TSchedule}
function StringToDT(Str:String):TDateTime;
var
   d,m,y,h,n,s:Word;
begin
   Result:=0;
   if Str = '0' then Exit;
   y :=StrToInt(Copy(Str,1,2))+2000;
   m :=StrToInt(Copy(Str,3,2));
   d :=StrToInt(Copy(Str,5,2));
   h :=StrToInt(Copy(Str,7,2));
   n :=StrToInt(Copy(Str,9,2));
   s :=StrToInt(Copy(Str,11,2));
   Result:=EncodeDate(y,m,d)+EncodeTime(h,n,s,0);
end;
function PadIntToStr(I:Integer):String;
begin
   Result:=IntToStr(I);
   if Length(Result) < 2 then 
      Result:='0'+Result;
end;
function DTToString(DT:TDateTime):String;
var
   d,m,y,h,n,s,ms:Word;
begin
   Result:='0';
   if DT = 0 then Exit;
   DecodeDate(DT,y,m,d);
   DecodeTime(DT,h,n,s,ms);
   Result:=PadIntToStr(y-2000)+PadIntToStr(m)+PadIntToStr(d)+
           PadIntToStr(h)+PadIntToStr(n)+PadIntToStr(s);
end;
function TToString(T:TTime):String;
var
   h,n,s,ms:Word;
begin
   Result:='0';
   if T = 0 then Exit;
   DecodeTime(T,h,n,s,ms);
   Result:=PadIntToStr(h)+PadIntToStr(n)+PadIntToStr(s);
end;
function StringToT(Str:String):TTime;
var
   h,n,s:Word;
begin
   Result:=0;
   if Str = '0' then Exit;
   h :=StrToInt(Copy(Str,1,2));
   n :=StrToInt(Copy(Str,3,2));
   s :=StrToInt(Copy(Str,5,2));
   Result:=EncodeTime(h,n,s,0);
end;
constructor TSchedule.Create(Scheduler:TScheduler;Schedule:String);
var
   SL:TStringList;
begin
   inherited Create;
   FScheduler:=Scheduler;
   SL:=TStringList.Create;
   SL.CommaText:=Schedule;
   if SL.Count >  0 then FName          :=SL[0]                          else FName          :='';
   if SL.Count >  1 then FExecute       :=SL[1]                          else FExecute       :='';
   if SL.Count >  2 then FInterval      :=StringToT(SL[2])               else FInterval      :=0;
   if SL.Count >  3 then FFromDT        :=StringToDT(SL[3])              else FFromDT        :=0;
   if SL.Count >  4 then FToDT          :=StringToDT(SL[4])              else FToDT          :=0;
   if SL.Count >  5 then FLastRun       :=StringToDT(SL[5])              else FLastRun       :=0;
   if SL.Count >  6 then FRelativeToLast:=WordBool(StrToIntDef(SL[6],0)) else FRelativeToLast:=False;
   if SL.Count >  7 then FSkipMissed    :=WordBool(StrToIntDef(SL[7],0)) else FSkipMissed    :=False;
   if SL.Count >  8 then FMustRunAll    :=WordBool(StrToIntDef(SL[8],0)) else FMustRunAll    :=False;
   if SL.Count >  9 then FEnabled       :=WordBool(StrToIntDef(SL[9],0)) else FEnabled       :=True;
   if SL.Count > 10 then FOutput        :=SL[10]                         else FOutput        :='';
   if SL.Count > 11 then FRunError      :=SL[11]                         else FRunError      :='';
   FRunning:=False;                                                                            
   SL.Free;                                                                                    
end;
procedure TSchedule.Run;
begin
   with TScheduleThread.Create(True) do
   begin
      Schedule:=Self;
      FreeOnTerminate:=True;
      Resume;
   end;
end;      
function TSchedule.AsString:String;
var
   SL:TStringList;
begin
   SL:=TStringList.Create;
   SL.Add(FName                );
   SL.Add(FExecute             );
   SL.Add(TToString(FInterval));  
   SL.Add(DTToString(FFromDT  ));    
   SL.Add(DTToString(FToDT    ));    
   SL.Add(DTToString(FLastRun ));    
   SL.Add(IntToStr(Integer(FRelativeToLast)));
   SL.Add(IntToStr(Integer(FSkipMissed    ))); 
   SL.Add(IntToStr(Integer(FMustRunAll    ))); 
   SL.Add(IntToStr(Integer(FEnabled       )));
   SL.Add(FOutput  );
   SL.Add(FRunError);
   Result:=SL.CommaText;
   SL.Free;
end;       
{TScheduler}
constructor TScheduler.Create(ScheduleFile:String);
var
   I:Integer;
   MutexHandle:THandle;
   WRes:Integer;
begin
   inherited Create;
   MutexHandle:=OpenMutex(MUTEX_ALL_ACCESS,True,PChar('ShedulerFile'));
   if MutexHandle = 0 then
      MutexHandle:=CreateMutex(nil,True,PChar('ShedulerFile'));
   try
      WRes:=WAIT_TIMEOUT;
      if MutexHandle <> 0 then
      begin
         WRes:=WaitForSingleObject(MutexHandle,200);
         while (WRes = WAIT_TIMEOUT) and (not Application.Terminated) do
         begin
            Sleep(1);
            Application.ProcessMessages;
            WRes:=WaitForSingleObject(MutexHandle,200);
         end;
      end;
      if WRes <> WAIT_TIMEOUT then
      begin
         FScheduleFile:=ScheduleFile;
         FSchedules:=TStringList.Create;
         try
            if FileExists(FScheduleFile) then
            begin
               FSchedules.LoadFromFile(FScheduleFile);
               I:=0;
               while I < FSchedules.Count do
               begin
                  if Trim(FSchedules[I]) = '' then
                  begin
                     FSchedules.Delete(I);
                  end
                  else
                  begin
                     FSchedules.Objects[I]:=TSchedule.Create(Self,FSchedules[I]);
                     Inc(I);
                  end;
               end;
            end;
         except
            on E:Exception do LogException(E,'{EC74A4A7-BA76-43B9-8BB5-B79273C53897}');
         end;
      end;
  except
     on E:Exception do LogException(E,'{81A97003-4B7F-43F2-8033-EA91E65C6637}');
  end;
  if MutexHandle <> 0 then
     ReleaseMutex(MutexHandle);
end;                
procedure TScheduler.Changed;
var
   MutexHandle:THandle;
   WRes:Integer;
   I:Integer;
begin
   if FScheduleFile <> '' then
   begin
      MutexHandle:=OpenMutex(MUTEX_ALL_ACCESS,True,PChar('ShedulerFile'));
      if MutexHandle = 0 then
         MutexHandle:=CreateMutex(nil,True,PChar('ShedulerFile'));
      try
         WRes:=WAIT_TIMEOUT;
         if MutexHandle <> 0 then
         begin
            WRes:=WaitForSingleObject(MutexHandle,200);
            while (WRes = WAIT_TIMEOUT) and (not Application.Terminated) do
            begin
               Sleep(1);
               Application.ProcessMessages;
               WRes:=WaitForSingleObject(MutexHandle,200);
            end;
         end;
         if WRes <> WAIT_TIMEOUT then
         begin
            for I:=0 to FSchedules.Count-1 do
                FSchedules[I]:=TSchedule(FSchedules.Objects[I]).AsString;
            FSchedules.SaveToFile(FScheduleFile);
         end;
      except
         on E:Exception do LogException(E,'{1A4F9552-0D51-49EC-8EB2-9DD2777C1ABB}');
      end;
      if MutexHandle <> 0 then
         ReleaseMutex(MutexHandle);
   end;
end;             
destructor TScheduler.Destroy;
begin
   while FSchedules.Count > 0 do
   begin
      TSchedule(FSchedules.Objects[0]).Free;
      FSchedules.Delete(0);
   end;
   FSchedules.Free;
   inherited Destroy;
end;                
procedure TScheduler.Check;
var
   I:Integer;
   Schedule:TSchedule;
   CurrentTime:TDateTime;
   DueToRun:TDateTime;
   h,m,s,ms:Word;
const
   Last:Integer = 0;
begin
   DecodeTime(Now,h,m,s,ms);
   if Last <> s then
   begin
      CurrentTime:=Now;
      for I:=0 to FSchedules.Count-1 do
      begin
         Schedule:=TSchedule(FSchedules.Objects[I]);
         if (Schedule.Enabled) and (not Schedule.Running) then 
         begin
            if ((Schedule.FromDT <= CurrentTime) or (Schedule.FromDT = 0)) and 
               ((Schedule.ToDT   >= CurrentTime) or (Schedule.ToDT   = 0)) then
            begin
               if Schedule.LastRun = 0 then
               begin
                  Schedule.Run;
               end
               else
               begin
                  DueToRun:=Schedule.Interval+Schedule.LastRun;
                  if (DueToRun <= CurrentTime) then
                  begin
                     Schedule.Run;
                  end;
               end;
            end;
         end;
      end;
   end;
end;                
function TScheduler.AsString:String;
begin
   Result:=FSchedules.Text;
end;                
procedure TScheduler.Add(Schedule:TSchedule);
begin
   FSchedules.AddObject(Schedule.AsString,Schedule);
end;                
{
HANDLE CreateEvent(
   LPSECURITY_ATTRIBUTES lpsa, // security privileges (default = NULL)
   BOOL bManualReset,          // TRUE if event must be reset manually
   BOOL bInitialState,         // TRUE to create event in signaled state
   LPTSTR lpszEventName );     // name of event (may be NULL)
BOOL SetEvent( HANDLE hEvent );
BOOL ResetEvent( HANDLE hEvent );

}
end.
