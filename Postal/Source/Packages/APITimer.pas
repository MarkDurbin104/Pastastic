unit APITimer;

interface

uses
  Windows,SysUtils,Classes,Dialogs;
  
type
  
  TAPITimer = class(TComponent)
  private
    FEnabled           :Boolean     ;
    TimerDelay         :Cardinal    ;
    TimerResolution    :Cardinal    ;
    TimerHandle        :Integer     ;
    FOnTimerEvent      :TNotifyEvent;
    FOnTimerEventHandle:Integer     ;
  protected
    procedure InitTimer;
    procedure SetEnabled(Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Enabled   :Boolean      read FEnabled        write SetEnabled     ;
    property Delay     :Cardinal     read TimerDelay      write TimerDelay     ;
    property Resolution:Cardinal     read TimerResolution write TimerResolution;
    property OnTimer   :TNotifyEvent read FOnTimerEvent   write FOnTimerEvent  ;
  end;
  TAPITimerThread=class(TThread)
  public
    APITimer: TAPITimer;
    procedure Execute; override;
  end;
  TAPITimerCallBack=procedure(NA1,NA2,APITimerUser,NA3,NA4: Integer) stdcall;
  EAPITimer=class(Exception);

var
  APITimerThread: TAPITimerThread;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('System',[TAPITimer]);
end;

function KillTimer(APITimerHandle: Integer): Integer;stdcall;
                   external 'WinMM.dll' name 'timeKillEvent';

function SetTimer(TimerDelay,TimerResolution: Integer;
                  APITimerCallBack: TAPITimerCallBack;
                  APITimerUser,APITimerFlags: Integer): Integer;stdcall;
                  external 'WinMM.dll' name 'timeSetEvent';

procedure TAPITimerThread.Execute;
begin
  while not(Terminated)and Assigned(APITimer)do
  begin
    WaitForSingleObject(APITimer.FOnTimerEventHandle,INFINITE);
    if Assigned(APITimer.FOnTimerEvent)then
      APITimer.FOnTimerEvent(APITimer);
  end;
end;

constructor TAPITimer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEnabled:=False;
  TimerDelay:=100;
  TimerResolution:=10;
  FOnTimerEventHandle:=CreateEvent(nil,False,False,nil);
end;

destructor TAPITimer.Destroy;
begin
  Enabled:=False;
  KillTimer(TimerHandle);
  CloseHandle(FOnTimerEventHandle);
  inherited Destroy;
end;

procedure APITimerCallBack(NA1,NA2,APITimerUser,NA3,NA4: Integer); stdcall;
var
  APITimer: TAPITimer;
begin
  APITimer:=TAPITimer(APITimerUser);
  if Assigned(APITimer) then
     SetEvent(APITimer.FOnTimerEventHandle);
end;

procedure TAPITimer.InitTimer;
begin
  TimerHandle:=SetTimer(TimerDelay,TimerResolution,@APITimerCallBack,Integer(Self),1);
  if TimerHandle = 0 then
  begin
    FEnabled:=False;
    raise EAPITimer.Create('API timer creation error.');
  end;
end;

procedure TAPITimer.SetEnabled(Value: Boolean);
begin
  if FEnabled <> Value then
  begin
     if not (csDesigning in ComponentState) then
     begin
        if (Value) then
        begin
          APITimerThread:=TAPITimerThread.Create(True);
          APITimerThread.APITimer:=Self;
          APITimerThread.FreeOnTerminate:=True;
          APITimerThread.APITimer.InitTimer;
          APITimerThread.Resume;
        end 
        else
        begin
          KillTimer(TimerHandle);
          TerminateThread(APITimerThread.Handle,0);
          APITimerThread.Free;
        end;
     end;
     FEnabled:=Value;
   end;
end;   
end.
