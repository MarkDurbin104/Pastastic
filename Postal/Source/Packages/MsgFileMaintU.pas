unit MsgFileMaintU;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls,PackStrListU,GPCSGUID,StringUtil,DirectoryU,
  MsgConfigU,StringWrapperU,MsgFileAccessU,StatusMonitorU,FileTxStatusU,OsmiumSupportU,
  checklst,DB,DBTables,Utils,FileCtrl,GPCSErrorLine;
type
   TPBarProc = procedure (PhaseNo,PhaseOf,Max,Pos:Integer) of object;
  
function GetMergeDataFrom(Path:String):TPackStringList;
procedure BackupMessages(Path:String);
procedure CopyMessages(FromPath,ToPath:String);
procedure EraseMessages(Path:String);
function Check(Path:String):Boolean;
function Fix(OrigPath,FinalPath:String;OfficeCode:Integer):Boolean;
procedure RebuildTxnlogAndStock(PBarProc:TPBarProc);
procedure Merge(IntoPath,FromPath:String;WSNumber:Integer);
procedure Repair(OfficeCode:Integer);

implementation

procedure Repair(OfficeCode:Integer);
begin
   ForceDirectories(MessageDir+'\Repaired');
   if Fix(MessageDir,MessageDir+'\Repaired',OfficeCode) then
   begin
      BackupMessages(MessageDir);
      CopyMessages(MessageDir+'\Repaired',MessageDir);
   end;
end;
   
function GetMergeDataFrom(Path:String):TPackStringList;
var                                                                                                                    
   MsgIndex:Integer;
   I,Off,WS,WSIdx:Integer;
   Status:TStatusBits;
   MessageData:TMessageAccess;
   TxnLines:TTxnLogLines;
   TxnLine:TTxnLogLine;
   Flags:Integer;       
   S:String;
   FSMon:TFileStatusMon;
   TempMessageDir:String;
begin
   TempMessageDir:=MessageDir;
   MessageDir:=Path;
   FSMon:=TFileStatusMon.Create(nil);
   Status:=TStatusBits.Create;
   Result:=TPackStringList.Create;
   TxnLines:=TTxnLogLines.Create;
   TxnLine:=TTxnLogLine.Create;
   try
      Status.State:=FSMon.FileBlockMgr.GetStatus;
      for WSIdx:=0 to Status.Count-1 do
      begin
         Off:=Status.OfficeCode(WSIdx);
         WS:=Status.WSNumber(WSIdx);
         for MsgIndex:=0 to Status.Size(Off,WS)-1 do
         begin
            if Status.Bit[Off,WS,MsgIndex] then
            begin
               Flags:=FSMon.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
               // is it a transaction message
               if (Flags and TransactionMsg) = TransactionMsg then
               begin
                  try
                     MessageData:=FSMon.FileBlockMgr.GetMessage(Off,WS,MsgIndex);
                     if  (MessageData <> nil) and MessageData.GoodCRC then
                     begin
                        TxnLines.PackText:=MessageData.MessageData;
                        if TxnLines.Count > 0 then
                        begin
                           for I:=0 to TxnLines.Count-1 do
                           begin
                              try
                                 TxnLine.PackText:=TxnLines[I];
                                 S:=IntToHex(TxnLine.WSNumber,2);
                                 S:=S+FormatDateTime('yymmddhhnnss',TDateTime(TxnLine.DateTime));
                                 S:=S+IntToHex(TxnLine.RecordID,8);
                                 Result.AddObject(S,TStringObject.Create(TxnLine.PackText));
                              except
                                 ShowMessage(TxnLine.WSNumber+' '+FormatDateTime('yymmddhhnnss',TDateTime(TxnLine.DateTime))+' '+TxnLine.RecordID);
                              end;
                           end;
                        end;
                     end;
                  except
                     ShowMessage(TxnLine.WSNumber+' '+FormatDateTime('yymmddhhnnss',TDateTime(TxnLine.DateTime))+' '+TxnLine.RecordID);
                  end;  
               end;
            end;
         end;
      end;
   finally
      MessageDir:=TempMessageDir;
      Result.Sort;
      TxnLine.Free;
      TxnLines.Free;
      Status.Free;
      FSMon.Free;
   end;
end;   
procedure BackupMessages(Path:String);
var
   FileList:TStringList;
   FileName:String;
begin
   FileList:=TStringList.Create;
   FillFileList(Path,'*.WSD',False,FileList);
   While FileList.Count > 0 do
   begin
      FileName:=Path+'\o'+ExtractFileName(FileList[0]);
      CopyFile(PChar(FileList[0]),PChar(FileName),False);
      FileList.Delete(0);
   end;
end;
procedure CopyMessages(FromPath,ToPath:String);
var
   FileList:TStringList;
   FileName:String;
begin
   FileList:=TStringList.Create;
   FillFileList(FromPath,'*.WSD',False,FileList);
   While FileList.Count > 0 do
   begin
      if Copy(ExtractFileName(FileList[0]),1,1) <> 'o' then // don't copy 'old' files
      begin
         FileName:=ToPath+'\'+ExtractFileName(FileList[0]);
         CopyFile(PChar(FileList[0]),PChar(FileName),False);
      end;
      FileList.Delete(0);
   end;
end;
procedure EraseMessages(Path:String);
var
   FileList:TStringList;
   FileName:String;
begin
   FileList:=TStringList.Create;
   FillFileList(Path,'*.WSD',False,FileList);
   While FileList.Count > 0 do
   begin
      FileName:=ExtractFilePath(FileList[0])+'o'+ExtractFileName(FileList[0]);
      RenameFile(FileList[0],FileName);
      FileList.Delete(0);
   end;
end;
function Check(Path:String):Boolean;
var                                                                                                                    
   MsgIndex:Integer;
   Flags:Integer;
   Off,WS,WSIdx:Integer;
   Status:TStatusBits;
   MessageData:TMessageAccess;
   Data:TFileStatusMon;
   TempMessageDir:String;
begin
   TempMessageDir:=MessageDir;
   MessageDir:=Path;
   Data:=TFileStatusMon.Create(nil);
   MessageDir:=TempMessageDir;
   Result:=True;
   Status:=TStatusBits.Create;
   try
      Status.State:=Data.FileBlockMgr.GetStatus;
      for WSIdx:=0 to Status.Count-1 do
      begin
         Off:=Status.OfficeCode(WSIdx);
         WS:=Status.WSNumber(WSIdx);
         for MsgIndex:=0 to Status.Size(Off,WS)-1 do
         begin
            if Status.Bit[Off,WS,MsgIndex] then
            begin
               Flags:=Data.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
               if  (Flags and MessageHasGoodCRC) = 0 then // not marked as good
               begin
                  MessageData:=Data.FileBlockMgr.GetMessage(Off,WS,MsgIndex);
                  if (MessageData = nil) or (not MessageData.GoodCRC) then
                  begin
                     Result:=False;
                     break;
                  end;
               end; 
               Application.ProcessMessages;
            end;
         end;
         if (Application.Terminated) or (not Result) then Break;
      end;
   finally
      Status.Free;
      Data.Free;
   end;
end;                    
function FixOfficeCode(MessageData:TMessageAccess;OfficeCode:Integer;var RunningRecordID:Integer):TMessageAccess;
var
   TxnLines:TTxnLogLines;
   TxnLine:TTxnLogLine;
   I:Integer;
begin                   
   Result:=MessageData;
   try
      if OfficeCode <> 0 then
         MessageData.Office:=OfficeCode;
      if (MessageData.MessageData <> '') and ((MessageData.Flags and TransactionMsg) <> 0) then
      begin
         TxnLines:=TTxnLogLines.Create;
         TxnLines.PackText:=MessageData.MessageData;
         if TxnLines.Count > 0 then
         begin
            TxnLine:=TTxnLogLine.Create;
            for I:=0 to TxnLines.Count-1 do
            begin
               TxnLine.PackText:=TxnLines[I];
               if OfficeCode <> 0 then
                  TxnLine.Office:=OfficeCode;
               TxnLine.RecordID:=RunningRecordID;
               Inc(RunningRecordID);
               TxnLines[I]:=TxnLine.PackText;
            end;
            TxnLine.Free;
            MessageData.MessageData:=TxnLines.PackText;
            MessageData.SetCRCFromData;
            Result:=MessageData;
         end;   
         TxnLines.Free;
      end;
   except
      on E:Exception do
         RaiseGUIDException('{3A0F9EE6-023A-49F0-A71F-A14C4D98AC7C}',E);
   end; 
end;
function Fix(OrigPath,FinalPath:String;OfficeCode:Integer):Boolean;
var                                                                                                                    
   MsgIndex:Integer;
   RunningRecordID,Off,WS,WSIdx:Integer;
   Status:TStatusBits;
   MessageData:TMessageAccess;
   OrigData:TFileStatusMon;
   FinalData:TFileStatusMonW;
   TempMessageDir:String;
begin
   Result:=False;
   EraseMessages(FinalPath);
   
   TempMessageDir:=MessageDir;
   MessageDir:=OrigPath;
   OrigData:=TFileStatusMon.Create(nil);
   MessageDir:=FinalPath;
   FinalData:=TFileStatusMonW.Create(nil);
   MessageDir:=TempMessageDir;
   
   Status:=TStatusBits.Create;
   try
      Status.State:=OrigData.FileBlockMgr.GetStatus;
      for WSIdx:=0 to Status.Count-1 do
      begin
         Off:=Status.OfficeCode(WSIdx);
         WS:=Status.WSNumber(WSIdx);
         RunningRecordID:=1;
         for MsgIndex:=0 to Status.Size(Off,WS)-1 do
         begin
            if Status.Bit[Off,WS,MsgIndex] then
            begin
               MessageData:=OrigData.FileBlockMgr.GetMessage(Off,WS,MsgIndex);
               if (MessageData <> nil) and MessageData.GoodCRC then
               begin
                  FinalData.FileBlockMgr.SetMessage(FixOfficeCode(MessageData,OfficeCode,RunningRecordID));
               end
               else
                   LogProgress(1,'Bad CRC Found at O'+IntToStr(Off)+' W'+IntToStr(WS)+' I'+IntToStr(MsgIndex));
               if (MessageData <> nil) then
                  MessageData.Free;
            end;   
            Application.ProcessMessages;
            if (Application.Terminated) then Break;
         end;
      end;
   finally
      Status.Free;
      OrigData.Free;
      FinalData.Free;
   end;
   if not (Application.Terminated) then 
      Result:=True;
end;                    
procedure RebuildTxnlogAndStock(PBarProc:TPBarProc);
var
   StatusMon:TFileStatusMonW;
   Table:TTable;
   Database:TDatabase;
begin
   DeleteFile(ExtractFilePath(ParamStr(0))+'SharedStock.dat');
   GetTxnlogDB(Database,Table,'PSL','RBSDatabase');
   if Table <> nil then Table.Free;
   if Database <> nil then
   begin
      Table:=TTxnTransfer.CreateTxnlog(Database,'TxnLog');
      Database.Free;
      if Table <> nil then
      begin
         Table.Free;
         StatusMon:=TFileStatusMonW.Create(nil);
         TTxnTransfer.MarkAsUnProcessed(PBarProc,StatusMon);
         StartupProcessing:=True;
         TTxnTransfer.FindPensionMessages(StatusMon);
         TTxnTransfer.ProcessUnProcessedPensions(PBarProc,StatusMon);
//         TTxnTransfer.FindMOMessages;
         TTxnTransfer.FindUnProcessedMessages(PBarProc,StatusMon);
         TTxnTransfer.ProcessUnProcessedMessages(PBarProc,StatusMon);
         StatusMon.Free;
      end;
   end;
end;
procedure Merge(IntoPath,FromPath:String;WSNumber:Integer);
var                                                                                                                    
   MsgIndex:Integer;
   Off,WS,WSIdx:Integer;
   IntoStatus:TStatusBits;
   FromStatus:TStatusBits;
   MessageData:TMessageAccess;
   IntoData:TFileStatusMonW;
   FromData:TFileStatusMon;
   TxnLines:TTxnLogLines;
   TxnLine:TTxnLogLine;
   I,WriteMessageNo,RunningRecordID:Integer;
   TempMessageDir:String;
begin
   TempMessageDir:=MessageDir;
   MessageDir:=IntoPath;
   IntoData:=TFileStatusMonW.Create(nil);
   MessageDir:=FromPath;
   FromData:=TFileStatusMon.Create(nil);
   MessageDir:=TempMessageDir;
   
   IntoStatus:=TStatusBits.Create;
   FromStatus:=TStatusBits.Create;
   try
      IntoStatus.State:=IntoData.FileBlockMgr.GetStatus;
      FromStatus.State:=FromData.FileBlockMgr.GetStatus;
      TxnLines:=TTxnLogLines.Create;
      TxnLine:=TTxnLogLine.Create;
      if WSNumber <> 0 then              
         WriteMessageNo:=IntoStatus.Size(IntoData.ThisOfficeID,WSNumber)+1
      else
         WriteMessageNo:=0;
      RunningRecordID:=1;
      for WSIdx:=0 to FromStatus.Count-1 do
      begin
         if WSNumber = 0 then RunningRecordID:=1;
         Off:=FromStatus.OfficeCode(WSIdx);
         WS:=FromStatus.WSNumber(WSIdx);
         for MsgIndex:=0 to FromStatus.Size(Off,WS)-1 do
         begin
            if (FromStatus.Bit[Off,WS,MsgIndex]     )
            and (not IntoStatus.Bit[Off,WS,MsgIndex]) then
            begin
               MessageData:=FromData.FileBlockMgr.GetMessage(Off,WS,MsgIndex);
               if (MessageData <> nil) and MessageData.GoodCRC then
               begin
                   if WSNumber <> 0 then 
                   begin
                      if MessageData.MessageType = mtTransaction then
                      begin
                         MessageData.Identifier:=WriteMessageNo;
                         MessageData.Office:=IntoData.ThisOfficeID;
                         MessageData.WorkStation:=WSNumber;
                         TxnLines.PackText:=MessageData.MessageData;
                         I:=0;
                         while I < TxnLines.Count do
                         begin
                            TxnLine.PackText:=TxnLines[I];
                            if  (TxnLine.RecType <> 'StockTx'  )
                            and (TxnLine.RecType <> 'TxStkTo'  )
                            and (TxnLine.RecType <> 'TxStkFrom')
                            and (TxnLine.RecType <> 'StockDec' )
                            and (TxnLine.RecType <> 'StockUsed' )
                            and (TxnLine.RecType <> 'AppStart' )
                            and (TxnLine.RecType <> 'AppEnd' )
                            and (TxnLine.RecType <> 'MBlkStart')
                            and (TxnLine.RecType <> 'StartDay')
                            and (TxnLine.RecType <> 'EndDay')
                            and (TxnLine.RecType <> 'MBlkEnd'  ) then
                            begin
                               TxnLine.WSNumber:=WSNumber;
                               TxnLine.RecordID:=RunningRecordID;
                               Inc(RunningRecordID);
                               TxnLines[I]:=TxnLine.PackText;
                               Inc(I);
                            end
                            else
                               TxnLines.Delete(I);
                         end;
                         if TxnLines.Count > 0 then
                         begin
                            MessageData.MessageData:=TxnLines.PackText;
                            MessageData.SetCRCFromData;
                            IntoData.FileBlockMgr.SetMessage(MessageData);
                            Inc(WriteMessageNo);
                         end;
                      end;
                   end
                   else
                      IntoData.FileBlockMgr.SetMessage(MessageData);
               end;
               if MessageData <> nil then
                  MessageData.Free;
            end;
         end;
      end;
      TxnLines.Free;
      TxnLine.Free;
   finally
      FromStatus.Free;
      IntoStatus.Free;
      FromData.Free;
      IntoData.Free;
   end;
end;   

end.
