unit SendMsgFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,FileTxStatusU, Db, Grids, DBGrids, DBTables,Registry,
  PackStrListU,StringWrapperU,DirectoryU,MsgConfigU,GPCSGUID,ActiveX,
  ComCtrls,StatusMonitorU,MsgFileAccessU,DTSocketU;
  
type
  TMainForm = class(TForm)
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    Button1: TButton;
    SendMsgButton: TButton;
    ProgressBar1: TProgressBar;
    TxnLog: TQuery;
    Button2: TButton;
    TxnLogTable: TTable;
    Button4: TButton;
    SB: TStatusBar;
    Button3: TButton;
    PSLDatabase: TDatabase;
    Button5: TButton;
    Button6: TButton;
    MarkAsUnproc: TButton;
    ScrollBox1: TScrollBox;
    Splitter1: TSplitter;
    Button7: TButton;
    Button8: TButton;
    CheckBox1: TCheckBox;
    Button9: TButton;
    SendRSHost: TComboBox;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    procedure SendMsgButtonClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure MarkAsUnprocClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
  public
    FileTxStatus:TFileTxStatus;
    procedure ProgCB  (PhaseNo,PhaseOf,Max,Pos:Integer);
    procedure ProgProc(PhaseNo,PhaseOf,Max,Pos:Integer);
    procedure ProgTxFL(PhaseNo,PhaseOf,Max,Pos:Integer);
  end;
  
var                            
  MainForm: TMainForm;
  
implementation

{$R *.DFM}

{TMainForm}
procedure TMainForm.SendMsgButtonClick(Sender: TObject);
var
   FS:TFileStream;
   SS:TStringStream;
   FileList:TStringList;
   I:Integer;
begin
   FileList:=TStringList.Create;
   FillFileList('C:\Tan','*.*',False,FileList);
   if FileTxStatus <> nil then
      FileTxStatus.StatusMonitor.Active:=False;
   for I:=0 to FileList.Count-1 do
   begin
      FS:=TFileStream.Create(FileList[I],fmOpenRead or fmShareDenyNone);
      SS:=TStringStream.Create('');
      SS.CopyFrom(FS,FS.Size);
      FS.Free;
      if FileTxStatus <> nil then
         FileTxStatus.FileBlockMgr.AppendMessage(3201,9,dtAdministration,0,Now+1,0,'Data','Data',
                  mtConfiguration,Integer(FileList.Objects[I]),FileList[I],SS.DataString,False)
      else
         SendServiceMessage(dtAdministration,0,SendMessagemsTimeOut,Now+1,0,'Data','Data',
                  mtConfiguration,Integer(FileList.Objects[I]),FileList[I],SS.DataString);
                  
         
      SS.Free;
      Application.ProcessMessages;
      if Application.Terminated then Break;
   end;
   if FileTxStatus <> nil then
      FileTxStatus.StatusMonitor.SetStatus(FileTxStatus.FileBlockMgr.GetStatus)
   else
      UpdateStatus;
   if FileTxStatus <> nil then
      FileTxStatus.StatusMonitor.Active:=True;
   FileList.Free;                         
end;                          

procedure TMainForm.ProgTxFL(PhaseNo,PhaseOf,Max,Pos:Integer);
begin
   try
      if Pos = 0 then 
      begin
         ProgressBar1.Min:=0;              
         ProgressBar1.Max:=Max;
         ProgressBar1.Visible:=True;
      end
      else if Max = Pos+1 then 
      begin
         ProgressBar1.Visible:=False;
         SB.SimpleText:='';
      end;
      
      if Pos mod 200 = 0 then
      begin
         ProgressBar1.Position:=Pos;
         case PhaseNo of
            1 : SB.SimpleText:='Opening Query...';
            2 : SB.SimpleText:='Transfering Data...';
            3 : SB.SimpleText:='Flushing Files...';
         end;      
         Application.ProcessMessages;
      end;
   except
   end;
end;
procedure TMainForm.Button1Click(Sender: TObject);
begin
   if FileTxStatus <> nil then
   begin
      DataSource1.Enabled:=False;
      FileTxStatus.StatusMonitor.Active:=False;
      TTxnTransfer.BuildStoreFromTxnLog(TxnLog,FileTxStatus,ProgTxFL);
      FileTxStatus.StatusMonitor.Active:=True;
      DataSource1.Enabled:=True;
      FileTxStatus.StatusMonitor.SetStatus(FileTxStatus.FileBlockMgr.GetStatus);
   end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
   CoInitialize(nil);
   PSLDataBase.Params.Add('USER NAME=' + GetGPCSRegString('','UserName','psl'));
   PSLDataBase.Params.Add('PASSWORD='  + GetGPCSRegString('','Password','suvroc'));
   PSLDataBase.LoginPrompt:=False;
   
   if GetGPCSRegString('WorkStation','DBType','Paradox') = 'SQLServer' then
      TxnLogTable.TableName   :='dbo.TXNLOG';
   if GetGPCSRegString('WorkStation','DBType','Paradox') <> 'Paradox' then
      TxnLogTable.IndexName:='TXNLOG_PINDEX';
          
   if IsServiceRunning then 
   begin
      ShowMessage('Service is Running');
      // don't start up our own FileTxStatus
   end
   else
   begin
      FileTxStatus:=TFileTxStatus.Create(nil);
      FileTxStatus.DisableAutoProcess:=True;
      Caption:=FileTxStatus.OfficeInfo;
      ScrollBox1.InsertControl(FileTxStatus);
   end;
end;                       

procedure TMainForm.Button2Click(Sender: TObject);
begin
   TxnLog.SQL.Text:='select * from Txnlog order by WSNumber,RecordID';
   if TxnLog.Active then TxnLog.Active:=False;
   TxnLog.Active:=True;
end;

procedure TMainForm.ProgCB(PhaseNo,PhaseOf,Max,Pos:Integer);
begin
   if Pos = 0 then 
   begin
      ProgressBar1.Min:=0;              
      ProgressBar1.Max:=Max;
      ProgressBar1.Visible:=True;
   end
   else if Max = Pos+1 then 
   begin
      ProgressBar1.Visible:=False;
      SB.SimpleText:='';
   end;   
   if Pos mod 200 = 0 then
   begin
      ProgressBar1.Position:=Pos;
      case PhaseNo of
         1 : SB.SimpleText:='Getting Transaction Data...';
         2 : SB.SimpleText:='Finding Valid Periods...';
         3 : SB.SimpleText:='Writing Data to Txnlog...';
      end;      
      Application.ProcessMessages;
   end;
end;
procedure TMainForm.ProgProc(PhaseNo,PhaseOf,Max,Pos:Integer);
begin
   if Pos = 0 then 
   begin
      ProgressBar1.Min:=0;              
      ProgressBar1.Max:=Max;
      ProgressBar1.Visible:=True;
   end
   else if Max = Pos+1 then 
   begin
      ProgressBar1.Visible:=False;
      SB.SimpleText:='';
   end
   else
       SB.SimpleText:='Building Transactions ...';
       
   ProgressBar1.Position:=Pos;
   Application.ProcessMessages;
end;
procedure TMainForm.Button4Click(Sender: TObject);
begin
   Button4.Enabled:=False;       
   if TxnLog.Active then TxnLog.Active:=False;
   if FileTxStatus <> nil then
      TTxnTransfer.RebuildTxnLog(ProgCB,FileTxStatus);
   Button4.Enabled:=True;
   SB.SimpleText:='';
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
   if FileTxStatus <> nil then
   begin
      ScrollBox1.RemoveControl(FileTxStatus);
      FileTxStatus.Free;
      FileTxStatus:=nil;
   end;
   PSLDataBase.Free;
   CoUnInitialize;
end;
procedure TMainForm.Button3Click(Sender: TObject);
begin              
   if FileTxStatus <> nil then
      TTxnTransfer.SendReplaceSelfTo(SendRSHost.Text,FileTxStatus);
end;

procedure TMainForm.Button5Click(Sender: TObject);
begin
   if (FileTxStatus <> nil) then
      FileTxStatus.SendCommand(SendRSHost.Text,ContactTimeOut,ctRebuildTxnLog,nil,True);
end;

procedure TMainForm.Button6Click(Sender: TObject);
begin
   Button4.Enabled:=False;       
   if TxnLog.Active then TxnLog.Active:=False;
   if FileTxStatus <> nil then
   begin
      MaxTxnProcessPerInterval:=0;
      TTxnTransfer.ProcessUnProcessedMessages(ProgProc,FileTxStatus);
      ReadConfig;
   end;
   Button4.Enabled:=True;
   SB.SimpleText:='';
end;

procedure TMainForm.MarkAsUnprocClick(Sender: TObject);
begin
   if TxnLog.Active then TxnLog.Active:=False;
   if FileTxStatus <> nil then
       TTxnTransfer.MarkAsUnProcessed(FileTxStatus);
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
   if FileTxStatus <> nil then
   begin
      FileTxStatus.Width:=ScrollBox1.ClientWidth;
   end;
end;

procedure TMainForm.Button7Click(Sender: TObject);
begin
   if TxnLog.Active then TxnLog.Active:=False;
   if FileTxStatus <> nil then
       TTxnTransfer.MarkAsProcessed(FileTxStatus);
end;

procedure TMainForm.Button8Click(Sender: TObject);
var
   Table:TTable;
   Database:TDatabase;
begin
   Button8.Enabled:=False;       
   if TxnLog.Active then TxnLog.Active:=False;
   Database:=TDatabase.Create(nil);
   Table:=TTxnTransfer.CreateTxnlog(Database,TableName);
   if Table <> nil then
      Table.Free;
   if Database <> nil then
      Database.Free;
   Button8.Enabled:=True;
   SB.SimpleText:='';
end;

procedure TMainForm.CheckBox1Click(Sender: TObject);
begin
   if FileTxStatus <> nil then
      FileTxStatus.DisableAutoProcess:=not CheckBox1.Checked;
end;

procedure TMainForm.Button9Click(Sender: TObject);
begin
   if FileTxStatus <> nil then
      ShowMessage(FileTxStatus.RequestDataFromOffice(SendRSHost.Text,ContactTimeOut));
end;

procedure TMainForm.Button10Click(Sender: TObject);
begin
   if (FileTxStatus <> nil) then
      ShowMessage(FileTxStatus.SendCommand(SendRSHost.Text,ContactTimeOut,ctClearTxState,nil,True));
end;

procedure TMainForm.Button11Click(Sender: TObject);
begin
   if (FileTxStatus <> nil) then
      ShowMessage(FileTxStatus.SendCommand(SendRSHost.Text,ContactTimeOut,ctWho,nil,True));
end;

procedure TMainForm.Button12Click(Sender: TObject);
begin
   if (FileTxStatus <> nil) then
      FileTxStatus.SendCommand(SendRSHost.Text,ContactTimeOut,ctRestart,nil,True);
end;

end.
 