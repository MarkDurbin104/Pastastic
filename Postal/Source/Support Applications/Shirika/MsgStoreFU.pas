unit MsgStoreFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,FileTxStatusU,ShareDataU,Menus,
  StatusMonitorU,MsgConfigU, ComCtrls,StringWrapperU,PackStrListU,GPCSErrorLine,
  Grids, DBGrids, Db, DBTables,RASDialer,GPCSGUID,WinExecU,
  MsgFileMaintU;
    
type
  TStatusString = class(TStringWrapper)
     public
      property Host           :Variant Index 0 read GetElement write SetElement;
      property BytesSend      :Variant Index 1 read GetElement write SetElement;
      property BytesReceived  :Variant Index 2 read GetElement write SetElement;
      property DGReceived     :Variant Index 3 read GetElement write SetElement;
      property SendErrors     :Variant Index 4 read GetElement write SetElement;
      property ReceiveErrors  :Variant Index 5 read GetElement write SetElement;
      property TimeSend       :Variant Index 6 read GetElement write SetElement;
      property TimeReceived   :Variant Index 7 read GetElement write SetElement;
  end;                      
  TMainForm = class(TForm)
    Image1: TImage;
    Timer1: TTimer;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
  public
    FileTxStatus:TFileTxStatus;
    StatusLines:TStringList;
    procedure TransferStatus(Status:String);
    procedure DataSend       (Host:String;Size:Integer);
    procedure DataConnectTime(Host:String;Time:TTime);
    procedure UpdateUserInterface;
    procedure Disable;
    procedure Enable;
  end;
var
  MainForm: TMainForm;

implementation

{$R *.DFM}

{TServiceApplication}

{TMainForm}
procedure TMainForm.FormCreate(Sender: TObject);
begin
   LogProgress(2,'TMainForm.FormCreate start' +ParamStr(0));
   FileTxStatus:=TFileTxStatus.Create(nil);
   FileTxStatus.RunningAsService:=True;
   FileTxStatus.OnContactStatus:=TransferStatus;
   FileTxStatus.OnContactError:=TransferStatus;
   FileTxStatus.OnDataSend       :=DataSend       ;
   FileTxStatus.OnDataConnectTime:=DataConnectTime;
   FileTxStatus.OnUpdateUI       :=UpdateUserInterface;
   StatusLines:=TStringList.Create;
   
   Memo1.Lines.Text:='Shirika Version '+DateTimeToStr(FileDateToDateTime(FileTxStatus.ThisVersion))+' ('+IntToStr(FileTxStatus.ThisVersion)+')';
   if ContactSubOffices = 0 then
      Memo1.Lines.Add('Not contacting sub offices.');
   LogProgress(2,'TMainForm.FormCreate end');
end;              

procedure TMainForm.TransferStatus(Status:String);
begin
   if  (Status <> 'Datacomm'    )
   and (Status <> 'Internal'    )
   and (Status <> 'Signal'      )
   and (Status <> 'Execute'     )
   and (Status <> 'MessageData' )
   and (Status <> 'UpdateStatus')
   and (Status <> 'Exclaim'     )
   and (Status <> 'ServiceBusy' ) then 
      StatusLines.Add(FormatDateTime('dd/mm/yy hh:nn:ss',Now)+' '+Status);
end;
procedure TMainForm.UpdateUserInterface;
const
  State:Integer = 0;
begin
   Memo1.Lines.BeginUpdate;
   try
      while Memo1.Lines.Count > 200 do Memo1.Lines.Delete(1);
      if (FileTxStatus <> nil) then
      begin
         if (Memo1.Lines.Count > 0) and (Memo1.Lines[0] <> '') and (Memo1.Lines[0][1] = '*') then
            Memo1.Lines.Delete(0);
         if (FileTxStatus <> nil) then
            Memo1.Lines.Insert(0,'*'+IntToHex(FileTxStatus.CurrentStatus,8));
      end;
      if ((StatusLines <> nil) and (Trim(StatusLines.Text) <> '')) then
      begin
         Memo1.Lines.Add(Trim(StatusLines.Text));
         StatusLines.Clear;
      end;
   finally
      Memo1.Lines.EndUpdate;
   end;
end;
procedure TMainForm.DataSend(Host:String;Size:Integer);
begin
   StatusLines.Add('Sending '+IntToStr(Size)+' bytes to '+Host);
end;
procedure TMainForm.DataConnectTime(Host:String;Time:TTime);
begin
  StatusLines.Add('Connected to '+Host+' for '+IntToStr(Trunc(Time / OneSecond))+' Seconds');
end;
procedure TMainForm.Disable;
begin
   if FileTxStatus <> nil then
   begin
      LogProgress(2,'TMainForm.Disable start');
      FileTxStatus.Active:=False;
      FileTxStatus.Free;
      FileTxStatus:=nil;
      LogProgress(2,'TMainForm.Disable end');
   end;
end;

procedure TMainForm.Enable;
begin
   if FileTxStatus = nil then
   begin
      LogProgress(2,'TMainForm.Enable start');
      ReadConfig;                         
      FileTxStatus:=TFileTxStatus.Create(nil);
      FileTxStatus.Active:=False;
      FileTxStatus.RunningAsService:=True;
      FileTxStatus.OnContactStatus:=TransferStatus;
      FileTxStatus.OnContactError:=TransferStatus;
      FileTxStatus.OnDataSend       :=DataSend       ;
      FileTxStatus.OnDataConnectTime:=DataConnectTime;
      FileTxStatus.OnUpdateUI       :=UpdateUserInterface;
      FileTxStatus.Active:=True;
      LogProgress(2,'TMainForm.Enable end');
   end;                               
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
   LogProgress(2,'TMainForm.FormDestroy start');
   StatusLines.Free;
   StatusLines:=nil;
   if FileTxStatus <> nil then
   begin
      FileTxStatus.Active:=False;
      FileTxStatus.Free;
      FileTxStatus:=nil;
   end;
   LogProgress(2,'TMainForm.FormDestroy end');
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
const
   ST:TDateTime=0;
   AR:TDateTime=0;
begin
   
   UpdateUserInterface;
   
   if StartUpProcessing then Exit;
   
   if AutoRepairMinutes > 0 then
   begin
      if AR = 0 then
         AR:=Now;
     
      if Now > (AR+(AutoRepairMinutes*OneMinute)) then // Repair check every 10 minutes
      begin
         AR:=Now;
         LogProgress(2,'Check(MessageDir) start');
         if (FileTxStatus <> nil) and (FileTxStatus.FileBlockMgr <> nil) then
            FileTxStatus.FileBlockMgr.Flush;
         if not Check(MessageDir) then
         begin
            LogProgress(2,'Repair Required !!!');
            Disable;         
            LogProgress(2,'Repair start');
            Repair(0);              
            LogProgress(2,'Repair end');
            Enable;        
         end;
         LogProgress(2,'Check(MessageDir) end');
      end;
   end;
   if AutoRestartMinutes > 0 then
   begin
      if ST = 0 then
      begin
         SetPSLRegString('CorvusService','Start Silently','0');
         ST:=Now;
      end;
      if Now > (ST+(AutoRestartMinutes*OneMinute)) then // maintenance restart every n minutes
      begin
         LogProgress(2,'TMainForm.AutoRestart');
         ST:=Now;
         SetPSLRegString('CorvusService','Start Silently','1');
         try Disable; except end;
         if FileExists('C:\CorvusService\RestartService.exe') then
         begin
            WinExec('C:\CorvusService\RestartService.exe',SW_HIDE);
            Application.Terminate;
         end              
         else
         begin
            SetPSLRegString('CorvusService','Restart DLL','1');
         end;
      end;                
   end;
end;

procedure TMainForm.Memo1Change(Sender: TObject);
begin
   try
      Memo1.Lines.SaveToFile(LogFileDirectory+'\'+ContactFile);
   except
   end;
end;

end.
