unit MsgConfigU;

interface
uses
    Messages,Windows,Registry,SysUtils,Classes,FileCtrl,GPCSGUID;
    
const   
   NormalPensionPLU  = '50040001';
   ArrearsPensionPLU = '50040002';
   MOIssueType       = 'MOIssue' ;
   MFIssueType       = 'MFIssue' ;
   MOPaidType        = 'MOPaid'  ;
   MFPaidType        = 'MFPaid'  ;
   MOIInfoType       = 'MOIInfo' ;
   MOPInfoType       = 'MOPInfo' ;
                        
   EventID:Integer = 0;

   NextProcess:Integer=0;
   NextMonitor:Integer=0;
   NextFind   :Integer=0;

   AliasName = 'PSL';
   TableName = 'TXNLOG';

   OneHour   = (1/24);
   OneMinute = (OneHour  /60);
   OneSecond = (OneMinute/60);
   
   WM_RXDATAGRAM     = WM_USER+1;   // datagram received event message
   INADDR_BROADCAST  = -1;          // send to all addresses
   MaxDGramLength    = 1400;        // maximum length of a datagram (XP limit)
                                    
   MessageDayMarker  = $00000001;   // this bit is set to Today mod 2 to stop the processing yesterdays data
   TransactionMsg    = $00000002;   // this message contains transaction data
   ConfigurationMsg  = $00000004;   // this message contains configuration information
   StatusMsg         = $00000008;   // this message contains status information
   StockMsg          = $00000010;   // this message contains stock information
   RegistryMsg       = $00000020;   // this message contains registry information
   MessageProcessed  = $00000040;   // this message has been processed into txnlog stock etc.
   MessageCompressed = $00000080;   // this message/block is compressed
   MessageTransfered = $00000100;   // this message has been transfered to another office 
   TransferMsg       = $00000200;   // this message is to move between 2 offices
   MessageHasGoodCRC = $00000400;   // this message's CRC had been checked and is correct 
   BadMessageBlock   = $00000800;   // this message's CRC had been checked and is incorrect
   PensionMsg        = $00001000;   // this message contains pension data
   MoneyOrderMsg     = $00002000;   // this message contains money order data
   POBoxMsg          = $00004000;   // this message contains POBox data
   PhilMsg           = $00008000;   // this message contains Philatelic data
   UserMsg           = $00010000;   // this message contains User data
   MailEventMsg      = $00020000;   // this message contains Mail Event data
   PenDataProcessed  = $00040000;   // this is a pension txn that has been processed into the Osmium database
   MODataProcessed   = $00080000;   // this is a Money Order txn that has been processed into the Indigo3 database
   PBoxDataProcessed = $00100000;   // this is a P.O. Box txn that has been processed into the Pyxis database
                                    
   DaysUntil_010198  = 35796;       // for period calculation
   IndexSize         = 255;         // file index block size 
   MutexName         = 'Idx_Mutex'; // name of file access mutex
   
   // the following consts can be overriden in the registry
   OfficeRoutesInfo        :String = 'C:\CorvusService\Offices.ori'; // office and route information file
   MessageDir              :String = 'C:\Messages'; // base directory for Messages
   SendStatementDelay      :Integer = 3;      // time in seconds between transmit statement
   ListTimeOut             :Integer = 3;      // number of CheckTimeOutDelay seconds to keep Previous requests etc.
   CheckTimeOutDelay       :Integer = 1;      // number of seconds to wait before checking ListTimeOut
   DatagramSendDelay       :Integer = 50;     // number of milli seconds to wait between datagram sends
   MaxSendNumber           :Integer = 50;     // number of datagrams to send in one batch
   DGBlockTxMaxLimit       :Integer = 2048;   // maximum number of 1K to transmit in one go 0 = all
   DGPortNumberValue       :Integer = 62111;  // default UDP/IP port number as integer
   DGPortNumber            :String = '62111'; // default UDP/IP port number
   DataTransferSocketPort  :Integer = 62000;  // default TCP/IP port number
   RemoteTransferSocketPort:Integer = 62001;  // Remote default TCP/IP port number
   DataTransferTimeOut     :Integer = 60000;  // 60 seconds
   DataTransferBufferLen   :Integer = $10000; // buffer length for TCP/IP transfers
   CompressingData         :Boolean = False;  // Compress each transaction line
   LargeDataBlockSize      :Integer = 200000; // oversize message
   CompressLargeDataBlock  :Boolean = False;  // Compress message if oversize
   CompressingBlocks       :Boolean = True;   // Compress index Block once complete
   CleanTransactions       :Boolean = True;   // remove extra DomInfo before save
   RequestLastRecordFirst  :Boolean = False;  // request transactions in reverse order
   SendFileIfOverBitCount  :Integer = 100;    // if over this number of messages are requested, the whole WS File is send
   SendMessagemsTimeOut    :Integer = 5000;   // Time in ms to wait for service to write a message to store
   CanSendWholeFiles       :Boolean = False;  // Can Send Whole Files if requested
   MaxTxnProcessPerInterval:Integer = 250;    // number of received transaction records to write per interval below 
   MaxPenProcessPerInterval:Integer = 250;    // number of received pension records to write per interval below 
   MaxMOProcessPerInterval :Integer = 250;    // number of received Money Order records to write per interval below 
   ProcessTxnTimeInterval  :Integer = 5;      // time between processing each batch of txns/pensions/moneyorders
   FindTxnTimeInterval     :Integer = 30*60;  // seconds between checking if any missed processing
   MaxCountOverWAN         :Integer = 1000;   // maximum number of messages sent for each request over WAN
   TxnlogMonitorTimeOut    :Integer = 120;    // number of seconds between reads of txnlog ONLY USED WHEN "Monitor Txnlog" is 'Y' in registry
   ContactSubOffices       :Integer = 0;      // number of seconds between requests from sub office
   ContactTimeOut          :Integer = 60000;  // number of ms to wait for response from sub
   CentralSystemDatabase   :Boolean = False;  // true if Primary key should contain OFFICE along with RecordID+WSNumber
   MonitorTxnlog           :Boolean = False;  // true if Service should drip feed transactions into the message store
   RunningAtPSL            :Boolean = False;  // Running at PSL
   AutoReplaceOld          :Boolean = True;   // Replace remote DLL if older than current
   SendReplaceOnRequest    :Boolean = True;   // Replace remote DLL if older than current
   BeepOnTransComplete     :Boolean = False;  // Replace remote DLL if older than current
   AutoRestartMinutes      :Integer = 30;     // automatically restart service every n min 0=don't
   AutoRepairMinutes       :Integer = 0;      // automatically repair a damaged MsgStore 0=don't
   WaitAfterConnectSeconds :Integer = 0;      // Time in Seconds to Wait After Connecting to a Remote Client via TCP/IP befor data transfer starts
   LoggingProgress         :Integer = 0;      // > 0 if Logging Progress
   LogFileDirectory        :String  = 'C:\LogFiles'; // directory for logfiles
   ValidWorkstationList    :String  = '';     // Valid Workstation List
   TransactionFilesDir     :String  = 'C:\TxnFiles'; // where to keep transaction sent to Service
   DistributionFilesDir    :String  = 'C:\Distribution'; // where to keep distribution sent via Floppy
   CanRebuildTxnlog        :Boolean = True;   // True if daily rebuild should happen i.e. not onSQLServer
   ProcessingPensions      :Boolean = True;   // True if this post office organisation processes pensions
   ProcessingMoneyOrders   :Boolean = True;   // True if this post office organisation processes Money Orders
   MaxFilesToProcess       :Integer = 100;    // Maximum number of files to process per interval
   UpdateOsmiumDBHere      :Boolean = False;  // True if this machine adds pension payments to the Osmium database
   UpdateIndigo3DBHere     :Boolean = False;  // True if this machine adds Money Order transactions to the Indigo3 database
   UpdatePyxisDBHere       :Boolean = False;  // True if this machine adds P.O.Box transactions to the Pyxis database
   WriteDataForOtherOffices:Boolean = False;  // True if this machine writes transactions for other offices to it's database (SQLServer or Oracle)
   StatusFile              :String  = 'Status.txt'; // current status
   ContactFile             :String  = 'Contact.txt'; // current status
   PeriodsInPayList        :Integer = 14;       // Maximum number days to show MoneyOrders for payment
   DatabaseOwner           :String = 'dbo'; //Database owner for SQL Database
   
procedure ReadConfig;
procedure LogProgress(Level:Integer;S:String);

implementation

function ReadRegVal(Reg:TRegistry;Name:String;Value:Variant):Variant;
begin
   Result:=Reg.ReadString(Name);
   if Result = '' then
      Result:=Value;
end;
procedure WriteRegVal(Reg:TRegistry;Name:String;Value:Variant);
begin
   Reg.WriteString(Name,Value);
end;
function ReadRegBool(Reg:TRegistry;Name:String;Value:Boolean):Boolean;
var
   S:String;
begin
   S:=Reg.ReadString(Name);
   if S = '' then
      Result:=Value
   else if S = 'Y' then
      Result:=True
   else
      Result:=False;
end;
procedure WriteRegBool(Reg:TRegistry;Name:String;Value:Boolean);
begin
   if Value then
      Reg.WriteString(Name,'Y')
   else
      Reg.WriteString(Name,'N');
end;
procedure DeleteOldLogFiles;
var
  SearchRec:TSearchRec;
  Period:Integer;
  Res,I:Integer;
  DeleteList:TStringList;
begin
   // files named C:\LogFiles\$Msg[Period].log i.e. $Msg2001.log
   Res:=FindFirst(LogFileDirectory+'\$*.log',$FFFF,SearchRec);
   if Res = 0 then
   begin
      DeleteList:=TStringList.Create;
      while Res = 0 do
      begin
         if Length(Copy(SearchRec.Name,Length(SearchRec.Name)-7,4)) = 4 then
         begin
            Period:=StrToInt(Copy(SearchRec.Name,Length(SearchRec.Name)-7,4));
            if (Period+7) < GetTodayasPeriod then
               DeleteList.Add(SearchRec.Name);
         end;
         Res:=FindNext(SearchRec);
      end;
      FindClose(SearchRec);
      for I:=0 to DeleteList.Count-1 do
         DeleteFile(LogFileDirectory+'\'+DeleteList[I]);
      DeleteList.Free;
   end;
end;
function GetFileStream(FileName:String):TFileStream;
var
   I:Integer;
begin
   Result:=nil;
   for I:=1 to 50 do // try to get the log file 50 times - someone else may be logging
   begin
      try
         if FileExists(FileName) then
            Result:=TFileStream.Create(FileName,fmOpenReadWrite or fmShareExclusive)
         else 
            Result:=TFileStream.Create(FileName,fmCreate or fmShareExclusive);
      except
      end;
      if Result <> nil then 
         break
      else
         Sleep(100); // failed - wait a little
   end;
end;
procedure LogProgress(Level:Integer;S:String);
var
   FileName:String;
   FS:TFileStream;
const
   ThisWorkstation:String = '';
   ThisOffice     :String = '';
   ProcessID      :Integer = 0;
begin
   if (LoggingProgress > 0) and (LoggingProgress >= Level) then
   begin
      ForceDirectories(LogFileDirectory);
      if ThisWorkstation = '' then
      begin
         ThisWorkstation:=GetGPCSRegString('Workstation','Ident','0');
         ThisOffice:=GetGPCSRegString('OfficeInfo','Office ID','0');
         ProcessID:=GetCurrentProcessId;
      end;
      DeleteOldLogFiles;      
      FileName:=LogFileDirectory+'\$'+ThisOffice+'_'+ThisWorkstation+'_'+IntToStr(GetTodayasPeriod)+'.log';
      S:=FormatDateTime('yy/dd/mm hh:nn:ss',Now)+' '+IntToStr(ProcessID)+' '+S+#13#10;
      FS:=GetFileStream(FileName);
      if FS <> nil then
      begin
         FS.Position:=FS.Size;
         FS.Write((@S[1])^,Length(S));
         FS.Free;
      end;
   end;  
end;
procedure ReadConfig;
var
   Reg:TRegistry;
begin
   Reg:=TRegistry.Create;
   Reg.RootKey:=HKEY_LOCAL_MACHINE;
   if Reg.OpenKey('SOFTWARE\PSL\Message Transfer',False) then
   begin
      OfficeRoutesInfo        :=ReadRegVal (Reg,'Office Routes Info'          ,OfficeRoutesInfo        );
      MessageDir              :=ReadRegVal (Reg,'Message Dir'                 ,MessageDir              );
      SendStatementDelay      :=ReadRegVal (Reg,'Send Statement Delay'        ,SendStatementDelay      );
      ListTimeOut             :=ReadRegVal (Reg,'List Time Out'               ,ListTimeOut             );
      CheckTimeOutDelay       :=ReadRegVal (Reg,'Check Time Out Delay'        ,CheckTimeOutDelay       );
      DatagramSendDelay       :=ReadRegVal (Reg,'Datagram Send Delay'         ,DatagramSendDelay       );
      MaxSendNumber           :=ReadRegVal (Reg,'Max Send Number'             ,MaxSendNumber           );
      DGBlockTxMaxLimit       :=ReadRegVal (Reg,'DG Block Tx Max Limit'       ,DGBlockTxMaxLimit       );
      DGPortNumber            :=ReadRegVal (Reg,'DG Port Number'              ,DGPortNumber            );
      DataTransferSocketPort  :=ReadRegVal (Reg,'Data Transfer Socket Port'   ,DataTransferSocketPort  );
      RemoteTransferSocketPort:=ReadRegVal (Reg,'Remote Transfer Socket Port' ,RemoteTransferSocketPort);
      DataTransferTimeOut     :=ReadRegVal (Reg,'Data Transfer Time Out'      ,DataTransferTimeOut     );
      DataTransferBufferLen   :=ReadRegVal (Reg,'Data Transfer Buffer Len'    ,DataTransferBufferLen   );
      CompressingData         :=ReadRegBool(Reg,'Compressing Data'            ,CompressingData         );
      LargeDataBlockSize      :=ReadRegVal (Reg,'Large Data Block Size'       ,LargeDataBlockSize      );
      CompressLargeDataBlock  :=ReadRegBool(Reg,'Compress Large Data Block'   ,CompressLargeDataBlock  );
      CompressingBlocks       :=ReadRegBool(Reg,'Compressing Blocks'          ,CompressingBlocks       );
      CleanTransactions       :=ReadRegBool(Reg,'Clean Transactions'          ,CleanTransactions       );
      RequestLastRecordFirst  :=ReadRegBool(Reg,'Request Last Record First'   ,RequestLastRecordFirst  );
      SendFileIfOverBitCount  :=ReadRegVal (Reg,'Send File If Over Bit Count' ,SendFileIfOverBitCount  );
      SendMessagemsTimeOut    :=ReadRegVal (Reg,'Send Message ms Time Out'    ,SendMessagemsTimeOut    );
      FindTxnTimeInterval     :=ReadRegVal (Reg,'Find Txn Time Interval'      ,FindTxnTimeInterval     );
      MaxCountOverWAN         :=ReadRegVal (Reg,'Max Count Over WAN'          ,MaxCountOverWAN         );
      TxnlogMonitorTimeOut    :=ReadRegVal (Reg,'Txnlog Monitor Time Out'     ,TxnlogMonitorTimeOut    );
      ContactSubOffices       :=ReadRegVal (Reg,'Contact Sub Offices'         ,ContactSubOffices       );
      ContactTimeOut          :=ReadRegVal (Reg,'Contact Time Out'            ,ContactTimeOut          );
      CentralSystemDatabase   :=ReadRegBool(Reg,'Central System Database'     ,CentralSystemDatabase   );
      MonitorTxnlog           :=ReadRegBool(Reg,'Monitor Txnlog'              ,MonitorTxnlog           );
      RunningAtPSL            :=ReadRegBool(Reg,'Running At PSL'              ,RunningAtPSL            );
      BeepOnTransComplete     :=ReadRegBool(Reg,'Beep On Transfer Complete'   ,BeepOnTransComplete     );
      AutoRestartMinutes      :=ReadRegVal (Reg,'Auto Restart Minutes'        ,AutoRestartMinutes      );
      AutoRepairMinutes       :=ReadRegVal (Reg,'Auto Repair Minutes'         ,AutoRepairMinutes       );
      WaitAfterConnectSeconds :=ReadRegVal (Reg,'Wait After Connect Seconds'  ,WaitAfterConnectSeconds );
      LoggingProgress         :=ReadRegVal (Reg,'Logging Progress'            ,LoggingProgress         );
      LogFileDirectory        :=ReadRegVal (Reg,'Log File Directory'          ,LogFileDirectory        );
      StatusFile              :=ReadRegVal (Reg,'Status File'                 ,StatusFile              );
      ContactFile             :=ReadRegVal (Reg,'Contact File'                ,ContactFile             );
      DatabaseOwner           :=ReadRegVal (Reg,'Database Owner'              ,DatabaseOwner           );
      ValidWorkstationList    :=ReadRegVal (Reg,'Valid Workstation List'      ,ValidWorkstationList    );
      TransactionFilesDir     :=ReadRegVal (Reg,'Transaction Files Dir'       ,TransactionFilesDir     );
      DistributionFilesDir    :=ReadRegVal (Reg,'Distribution Files Dir'      ,DistributionFilesDir    );
      CanRebuildTxnlog        :=ReadRegBool(Reg,'Can Rebuild Txnlog'          ,CanRebuildTxnlog        );
      CanSendWholeFiles       :=ReadRegBool(Reg,'Can Send Whole Files'        ,CanSendWholeFiles       );
      MaxTxnProcessPerInterval:=ReadRegVal (Reg,'Max Txn Process Per Interval',MaxTxnProcessPerInterval);
      MaxPenProcessPerInterval:=ReadRegVal (Reg,'Max Pen Process Per Interval',MaxPenProcessPerInterval);
      MaxMOProcessPerInterval :=ReadRegVal (Reg,'Max MO Process Per Interval' ,MaxMOProcessPerInterval );
      ProcessTxnTimeInterval  :=ReadRegVal (Reg,'Process Txn Time Interval'   ,ProcessTxnTimeInterval  );
      AutoReplaceOld          :=ReadRegBool(Reg,'Auto Replace Old'            ,AutoReplaceOld          );
      ProcessingPensions      :=ReadRegBool(Reg,'Processing Pensions'         ,ProcessingPensions      );
      ProcessingMoneyOrders   :=ReadRegBool(Reg,'Processing Money Orders'     ,ProcessingMoneyOrders   );
      MaxFilesToProcess       :=ReadRegVal (Reg,'Max Files To Process'        ,MaxFilesToProcess       );
      PeriodsInPayList        :=ReadRegVal (Reg,'Periods In Pay List '        ,PeriodsInPayList        );
      UpdateOsmiumDBHere      :=ReadRegBool(Reg,'Update Osmium DB Here'       ,UpdateOsmiumDBHere      );
      UpdateIndigo3DBHere     :=ReadRegBool(Reg,'Update Indigo3 DB Here'      ,UpdateIndigo3DBHere     );
      UpdatePyxisDBHere       :=ReadRegBool(Reg,'Update Pyxis DB Here'        ,UpdatePyxisDBHere       );
      WriteDataForOtherOffices:=ReadRegBool(Reg,'Write Data For Other Offices',WriteDataForOtherOffices);
   end;
   Reg.CloseKey;
   if Reg.OpenKey('SOFTWARE\PSL\Message Transfer',True) then
   begin
      WriteRegVal (Reg,'Office Routes Info'          ,OfficeRoutesInfo        );
      WriteRegVal (Reg,'Message Dir'                 ,MessageDir              );
      WriteRegVal (Reg,'Send Statement Delay'        ,SendStatementDelay      );
      WriteRegVal (Reg,'List Time Out'               ,ListTimeOut             );
      WriteRegVal (Reg,'Check Time Out Delay'        ,CheckTimeOutDelay       );
      WriteRegVal (Reg,'Datagram Send Delay'         ,DatagramSendDelay       );
      WriteRegVal (Reg,'Max Send Number'             ,MaxSendNumber           );
      WriteRegVal (Reg,'DG Block Tx Max Limit'       ,DGBlockTxMaxLimit       );
      WriteRegVal (Reg,'DG Port Number'              ,DGPortNumber            );
      WriteRegVal (Reg,'Data Transfer Socket Port'   ,DataTransferSocketPort  );
      WriteRegVal (Reg,'Remote Transfer Socket Port' ,RemoteTransferSocketPort);
      WriteRegVal (Reg,'Data Transfer Time Out'      ,DataTransferTimeOut     );
      WriteRegVal (Reg,'Data Transfer Buffer Len'    ,DataTransferBufferLen   );
      WriteRegBool(Reg,'Compressing Data'            ,CompressingData         );
      WriteRegVal (Reg,'Large Data Block Size'       ,LargeDataBlockSize      );
      WriteRegBool(Reg,'Compress Large Data Block'   ,CompressLargeDataBlock  );
      WriteRegBool(Reg,'Compressing Blocks'          ,CompressingBlocks       );
      WriteRegBool(Reg,'Clean Transactions'          ,CleanTransactions       );
      WriteRegBool(Reg,'Request Last Record First'   ,RequestLastRecordFirst  );
      WriteRegVal (Reg,'Send File If Over Bit Count' ,SendFileIfOverBitCount  );
      WriteRegVal (Reg,'Send Message ms Time Out'    ,SendMessagemsTimeOut    );
      WriteRegBool(Reg,'Can Send Whole Files'        ,CanSendWholeFiles       );
      WriteRegVal (Reg,'Max Txn Process Per Interval',MaxTxnProcessPerInterval);
      WriteRegVal (Reg,'Max Pen Process Per Interval',MaxPenProcessPerInterval);
      WriteRegVal (Reg,'Max MO Process Per Interval' ,MaxMOProcessPerInterval );
      WriteRegVal (Reg,'Process Txn Time Interval'   ,ProcessTxnTimeInterval  );
      WriteRegVal (Reg,'Find Txn Time Interval'      ,FindTxnTimeInterval     );
      WriteRegVal (Reg,'Max Count Over WAN'          ,MaxCountOverWAN         );
      WriteRegVal (Reg,'Txnlog Monitor Time Out'     ,TxnlogMonitorTimeOut    );
      WriteRegVal (Reg,'Contact Sub Offices'         ,ContactSubOffices       );
      WriteRegVal (Reg,'Contact Time Out'            ,ContactTimeOut          );
      WriteRegBool(Reg,'Central System Database'     ,CentralSystemDatabase   );
      WriteRegBool(Reg,'Monitor Txnlog'              ,MonitorTxnlog           );
      WriteRegBool(Reg,'Auto Replace Old'            ,AutoReplaceOld          );
      WriteRegBool(Reg,'Beep On Transfer Complete'   ,BeepOnTransComplete     );
      WriteRegVal (Reg,'Auto Restart Minutes'        ,AutoRestartMinutes      );
      WriteRegVal (Reg,'Auto Repair Minutes'         ,AutoRepairMinutes       );
      WriteRegVal (Reg,'Wait After Connect Seconds'  ,WaitAfterConnectSeconds );
      WriteRegVal (Reg,'Logging Progress'            ,LoggingProgress         );
      WriteRegVal (Reg,'Log File Directory'          ,LogFileDirectory        );
      WriteRegVal (Reg,'Status File'                 ,StatusFile              );
      WriteRegVal (Reg,'Contact File'                ,ContactFile             );
      WriteRegVal (Reg,'Database Owner'              ,DatabaseOwner           );
      WriteRegVal (Reg,'Valid Workstation List'      ,ValidWorkstationList    );
      WriteRegVal (Reg,'Transaction Files Dir'       ,TransactionFilesDir     );
      WriteRegVal (Reg,'Distribution Files Dir'      ,DistributionFilesDir    );
      WriteRegBool(Reg,'Can Rebuild Txnlog'          ,CanRebuildTxnlog        );
      WriteRegBool(Reg,'Processing Pensions'         ,ProcessingPensions      );
      WriteRegBool(Reg,'Processing Money Orders'     ,ProcessingMoneyOrders   );
      WriteRegVal (Reg,'Max Files To Process'        ,MaxFilesToProcess       );
      WriteRegVal (Reg,'Periods In Pay List '        ,PeriodsInPayList        );
      WriteRegBool(Reg,'Update Osmium DB Here'       ,UpdateOsmiumDBHere      );
      WriteRegBool(Reg,'Update Indigo3 DB Here'      ,UpdateIndigo3DBHere     );
      WriteRegBool(Reg,'Update Pyxis DB Here'        ,UpdatePyxisDBHere       );
      WriteRegBool(Reg,'Write Data For Other Offices',WriteDataForOtherOffices);
   end;
   Reg.CloseKey;
   Reg.Free;
end;

initialization
   ReadConfig;

end.

