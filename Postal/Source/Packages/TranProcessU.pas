unit TranProcessU;

interface

uses
    Windows,Messages,Classes,Forms,SysUtils,Db,DBUtil,DBTables,
    MOSupportU,MODefinitionsU,CustomerListU,TaskKillerU,
    FileTxStatusU,MsgFileAccessU,PackStrListU,StringWrapperU,
    GPCSErrorLine,GPCSGUID,GPCSBase_TLB,UIDllSupportU,I3UIParseU;
    
const
   AliasName = 'PSL';
   TableName = 'TXNLOG';
   WM_WRITENOW = WM_USER+5;
   SendUpdate:Boolean = True;
            
type
  TBlockPos = (bpFirst,bpMiddle,bpLast);
  TTxnDomInfoLine = class(TObject)
   private
     FEnabled   :Boolean;
     FFocused   :Boolean;
     FDomType   :String;
     FName      :String;
     FPrompt    :String;
     FText      :String;
     FHint      :String;
     FError     :String;
     FValidation:String;
     FAddtional :String;
   public
     property Enabled   :Boolean read FEnabled    write FEnabled   ;
     property Focused   :Boolean read FFocused    write FFocused   ; 
     property DomType   :String  read FDomType    write FDomType   ;
     property Name      :String  read FName       write FName      ;
     property Prompt    :String  read FPrompt     write FPrompt    ;
     property Text      :String  read FText       write FText      ;
     property Hint      :String  read FHint       write FHint      ;
     property Error     :String  read FError      write FError     ;
     property Validation:String  read FValidation write FValidation;
     property Addtional :String  read FAddtional  write FAddtional ;
  end;
  TTxnDomInfoLines = class(TList)
    private
      function GetItem(Index:Integer):TTxnDomInfoLine;
      procedure SetItem(Index:Integer;Value:TTxnDomInfoLine);
    public
      destructor Destroy; override;
      function AddFromPackText(TxnDomInfoLine:String):Integer;
      property Item[Index:Integer]:TTxnDomInfoLine read GetItem write SetItem; default;
  end;
  TTxnProcessor = class(TObject)
  private
     PSLDatabase:TDatabase;
     WindowHandle:THandle;
  public
     StatsList:TPackStringList;
     TxnList:TPackStringList;
     TxnLogTable:TTable;
     constructor Create(DBName:String);
     destructor Destroy; override;
     procedure WndProc(var Message: TMessage);
     procedure WMWriteNow(var Msg:TMessage); message WM_WRITENOW;
     procedure WriteTransactions(PackText:String);
     procedure CheckTxns(Sender:TObject);
     procedure CheckTxnList;
     procedure RestoreLostTxns;
  end;

          
implementation

{TTxnProcessor}
constructor TTxnProcessor.Create;
begin
   inherited Create;
   
   WindowHandle:=AllocateHWnd(WndProc);
   
   TxnList:=TPackStringList.Create;
   StatsList:=TPackStringList.Create;
      
   PSLDatabase:=TDatabase.Create(nil);
   PSLDatabase.AliasName   :=AliasName;
   PSLDatabase.DatabaseName:=DBName;
   PSLDatabase.LoginPrompt :=False;
   PSLDatabase.SessionName :='Default';
   
   TxnLogTable:=TTable.Create(nil);
   TxnLogTable.DatabaseName:=DBName;
   TxnLogTable.TableName   :=TableName;
   
   if GetGPCSRegString('WorkStation','DBType','Paradox') <> 'Paradox' then
      TxnLogTable.IndexName:='TXNLOG_PINDEX';
      
   if GetGPCSRegString('WorkStation','DBType','Paradox') = 'SQLServer' then
      TxnLogTable.TableName   :='dbo.TXNLOG';
                                                                          
   PSLDataBase.Params.Add('USER NAME='+GetGPCSRegString('','UserName','psl'   ));
   PSLDataBase.Params.Add('PASSWORD=' +GetGPCSRegString('','Password','suvroc'));
   
end;
destructor TTxnProcessor.Destroy;
begin
   GetUserNumber('*DestroyList');
   TxnLogTable.Free;
   PSLDatabase.Free;
   TxnList.Free;
   StatsList.Free;
   DeAllocateHWnd(WindowHandle);
   inherited Destroy;
end;
procedure TTxnProcessor.WndProc(var Message: TMessage);
begin
  try             
    Dispatch(Message);
  except
      on E:Exception do RaiseException(8,E);
  end;
end;

procedure TTxnProcessor.WriteTransactions(PackText:String);
var
   SL:TTxnLogLine;
   FSL:TTxnLogLines;
   I:Integer;
begin                              
   if not SendServiceMessage(dtTransaction,0,5000,Now+1,Now+500,'Data','Data',mtTransaction,0,'',PackText) then
      RaiseGUIDError('{ACA65411-61EA-41A8-A293-55788359527F}','Critical Failure while Writing Transactions');
   Exit;
   SL:=TTxnLogLine.Create;
   FSL:=TTxnLogLines.Create;
   FSL.PackText:=PackText;
   I:=0;
   while I < FSL.Count do
   begin
      SL.PackText:=FSL[I];
      if SL.RecType = 'MBlkStart' then
         SendUpdate:=False
      else if SL.RecType = 'MBlkEnd' then
         SendUpdate:=True;
      Inc(I);
   end;
   TxnList.Add(FSL.PackText);
   FSL.Free;
   SL.Free;
   if SendUpdate then
      PostMessage(WindowHandle,WM_WRITENOW,0,0);
end;

procedure TTxnProcessor.WMWriteNow(var Msg:TMessage);
var
   SL:TTxnLogLines;
   FSL:TTxnLogLines;
   I:Integer;
begin
   FSL:=TTxnLogLines.Create;
   SL:=TTxnLogLines.Create;
   while TxnList.Count > 0 do
   begin
      FSL.PackText:=TxnList[0];
      TxnList.Delete(0);
      for I:=0 to FSL.Count-1 do
         SL.Add(FSL[I])
   end;
   TxnList.Add(SL.PackText);
   SL.Free;
   FSL.Free;
   CheckTxnList;
end;

procedure TTxnProcessor.CheckTxnList;
var
   SL:TTxnLogLine;
   FSL:TTxnLogLines;
   I:Integer;
const
   NextIdent:Integer = -1;
   Incheck:Boolean = False;
begin
   if Incheck then Exit;
   if TxnList.Count = 0 then Exit;
   Incheck:=True;
   try
   FSL:=TTxnLogLines.Create;
   while TxnList.Count > 0 do
   begin
      FSL.PackText:=TxnList[0];
      TxnList.Delete(0);
      if not SendServiceMessage(dtTransaction,0,5000,Now+1,Now+500,'Data','Data',mtTransaction,0,'',FSL.PackText) then
         RaiseGUIDError('{E1ECA096-E762-4D19-8148-9D7C3CB015D0}','Critical Failure while Writing Transactions');
   end;
   FSL.Free;
   finally
      Incheck:=False;
   end;
   Exit;
   
   try            
      FSL:=TTxnLogLines.Create;
      SL:=TTxnLogLine.Create;
      if not TxnlogTable.Active then
         TxnlogTable.Active:=True;
      while TxnList.Count > 0 do
      begin
         FSL.PackText:=TxnList[0];
         TxnList.Delete(0);
         try
            for I:=0 to FSL.Count-1 do
            begin
               //ensure NextIdent is valid for this WS
               If NextIdent = -1 then
               begin
                 SL.PackText:=FSL[I];
                 try
                   SL.PackText := QueryToPackText('select max(RECORDID) from txnlog where wsnumber = ' + IntToStr(SL.WSNumber));
                   SL.PackText := SL[0];
                   NextIdent := 1+StrToIntDef(SL[0],-1);
                 except
                   NextIdent := 0;
                 end;
               end;
               SL.PackText:=FSL[I];
               SL.RecordID:=NextIdent; Inc(NextIdent);
               TxnlogTable.Append;
               TxnlogTable.FieldByName('RECORDID')   .value:=SL.RecordID   ;
               TxnlogTable.FieldByName('WSNUMBER')   .value:=SL.WSNumber   ;
               TxnlogTable.FieldByName('DATETIME')   .value:=TDateTime(SL.DateTime);
               TxnlogTable.FieldByName('RECTYPE')    .value:=SL.RecType    ;
               TxnlogTable.FieldByName('PERIOD')     .value:=SL.Period     ;
               TxnlogTable.FieldByName('RECINDEX')   .value:=SL.RecIndex   ;
               TxnlogTable.FieldByName('OFFICE')     .value:=SL.Office     ;
               TxnlogTable.FieldByName('TELLER')     .value:=SL.Teller     ;
               TxnlogTable.FieldByName('PLU')        .value:=SL.PLU        ;
               TxnlogTable.FieldByName('PROD')       .value:=SL.Prod       ;
               TxnlogTable.FieldByName('PRICE')      .value:=SL.Price      ;
               TxnlogTable.FieldByName('QUANTITY')   .value:=SL.Quantity   ;
               TxnlogTable.FieldByName('TXNVALUE')   .value:=SL.TxnValue   ;
               TxnlogTable.FieldByName('DESCRIPTION').value:=SL.Description;
               TxnlogTable.FieldByName('INFO')       .value:=SL.Info       ;
               TxnlogTable.FieldByName('IDENT')      .value:=SL.Ident      ;
               TxnlogTable.FieldByName('DOMINFO')    .value:=SL.DomInfo    ;
               TxnLogTable.Post;
               FSL[I]:=SL.PackText;
            end;
         except
            On E : Exception do
               RaiseGUIDException('{80B5B7D2-75AF-40DB-A720-4F71C74CE4AF}', E);
         end;
         if not SendServiceMessage(dtTransaction,0,5000,Now+1,Now+500,'Data','Data',mtTransaction,0,'',FSL.PackText) then
         begin
            TxnlogTable.Active:=False;
            TxnList.Insert(0,FSL.PackText);
            I:=0;
            while FileExists('C:\TxnBak'+IntToHex(I,2)) do Inc(I);
            TxnList.SaveToFile('C:\TxnBak'+IntToHex(I,2));
            RaiseGUIDError('{E1ECA096-E762-4D19-8148-9D7C3CB015D0}','Critical Failure while Writing Transactions');
            FSL.Free;
            SL.Free;
            Restart;
            KillCorvus;
            Application.MainForm.Close;
            Exit;
         end;
      end;
      UpdateStatus;
      TxnlogTable.Active:=False;
      FSL.Free;
      SL.Free;
   except
      On E : Exception do
        RaiseGUIDException('{C0DC5387-4927-4B36-B8D0-79D85C1E1425}', E);
   end;
   Incheck:=False;
end;
procedure TTxnProcessor.RestoreLostTxns;
var
   NextIdent:Integer;
   SL:TTxnLogLine;
   FSL:TTxnLogLines;
   I:Integer;
   FileNumb:Integer;
   TxnList:TStringList;
   FirstLine:Boolean;
begin
   FileNumb:=0;
   TxnList:=TStringList.Create;
   while FileNumb < 255 do
   begin
      if FileExists('C:\TxnBak'+IntToHex(FileNumb,2)) then
      begin
         TxnList.LoadFromFile('C:\TxnBak'+IntToHex(FileNumb,2));
         DeleteFile('C:\TxnBak'+IntToHex(FileNumb,2));
         if TxnList.Count > 0 then
         try
            FirstLine:=True;
            FSL:=TTxnLogLines.Create;
            SL:=TTxnLogLine.Create;
            if not TxnlogTable.Active then
               TxnlogTable.Active:=True;
            TxnlogTable.Last;
            try
               NextIdent:=TxnlogTable.FieldByName('RECORDID').value+1
            except
               NextIdent:=0;
            end;
            while TxnList.Count > 0 do
            begin
               FSL.PackText:=TxnList[0];
               TxnList.Delete(0);
               try
                  if not FirstLine then // first line already written to txnlog
                  begin
                     for I:=0 to FSL.Count-1 do
                     begin
                        SL.PackText:=FSL[I];
                        SL.RecordID:=NextIdent; Inc(NextIdent);
                        TxnlogTable.Append;
                        TxnlogTable.FieldByName('RECORDID')   .value:=SL.RecordID   ;
                        TxnlogTable.FieldByName('WSNUMBER')   .value:=SL.WSNumber   ;
                        TxnlogTable.FieldByName('DATETIME')   .value:=TDateTime(SL.DateTime);
                        TxnlogTable.FieldByName('RECTYPE')    .value:=SL.RecType    ;
                        TxnlogTable.FieldByName('PERIOD')     .value:=SL.Period     ;
                        TxnlogTable.FieldByName('RECINDEX')   .value:=SL.RecIndex   ;
                        TxnlogTable.FieldByName('OFFICE')     .value:=SL.Office     ;
                        TxnlogTable.FieldByName('TELLER')     .value:=SL.Teller     ;
                        TxnlogTable.FieldByName('PLU')        .value:=SL.PLU        ;
                        TxnlogTable.FieldByName('PROD')       .value:=SL.Prod       ;
                        TxnlogTable.FieldByName('PRICE')      .value:=SL.Price      ;
                        TxnlogTable.FieldByName('QUANTITY')   .value:=SL.Quantity   ;
                        TxnlogTable.FieldByName('TXNVALUE')   .value:=SL.TxnValue   ;
                        TxnlogTable.FieldByName('DESCRIPTION').value:=SL.Description;
                        TxnlogTable.FieldByName('INFO')       .value:=SL.Info       ;
                        TxnlogTable.FieldByName('IDENT')      .value:=SL.Ident      ;
                        TxnlogTable.FieldByName('DOMINFO')    .value:=SL.DomInfo    ;
                        TxnLogTable.Post;
                        FSL[I]:=SL.PackText;
                     end;
                  end;
               except
               end;
               FirstLine:=False;
               if not SendServiceMessage(dtTransaction,0,5000,Now+1,Now+500,'Data','Data',mtTransaction,0,'',FSL.PackText) then
               begin
                  TxnlogTable.Active:=False;
                  RaiseGUIDError('{E1ECA096-E762-4D19-8148-9D7C3CB015D0}','Critical Failure while re-Writing Transactions');
                  TxnList.Insert(0,FSL.PackText);
                  TxnList.SaveToFile('C:\TxnBak'+IntToHex(FileNumb,2));
                  FSL.Free;
                  SL.Free;
                  Restart;
                  KillCorvus;
                  Application.MainForm.Close;
                  Exit;
               end;
            end;
            UpdateStatus;
            TxnlogTable.Active:=False;
            FSL.Free;
            SL.Free;
         except
            On E : Exception do
              RaiseGUIDException('{C0DC5387-4927-4B36-B8D0-79D85C1E1425}', E);
         end;
      end;
      Inc(FileNumb);
   end;
   TxnList.Free;
end;
procedure TTxnProcessor.CheckTxns(Sender:TObject);
const
   CheckIng:Boolean = False;
   LastSendCount:Integer = 0;
begin
   if Checking then Exit;
   Checking:=True;
   if TxnList.Count <> 0 then
   begin
      if SendUpdate then
      begin
         CheckTxnList;
         LastSendCount:=0;
      end                 
      else
      begin
         Inc(LastSendCount);
         if LastSendCount >= 5 then
         begin
            CheckTxnList;
            LastSendCount:=0;
         end;
      end;                 
   end;                 
   Checking:=False;
end;

{TTxnDomInfoLines}
function TTxnDomInfoLines.GetItem(Index:Integer):TTxnDomInfoLine;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=TTxnDomInfoLine(Get(Index))
   else
      Result:=nil;
end;
procedure TTxnDomInfoLines.SetItem(Index:Integer;Value:TTxnDomInfoLine);
begin
   if (Index >= 0) and (Index < Count) then
      Put(Index,Value);
end;       
destructor TTxnDomInfoLines.Destroy;
var
   I:Integer;
begin
   for I:=0 to Count-1 do
      TTxnDomInfoLine(Get(I)).Free;
   inherited Destroy;
end;
function TTxnDomInfoLines.AddFromPackText(TxnDomInfoLine:String):Integer;
var
  OldTxnDomInfoLine:TTxnDomInfoLine;
  OSL:TPackStringList;
  SL:TPackStringList;
  I:Integer;
begin
  SL:=TPackStringList.Create;
  OSL:=TPackStringList.Create;
  OSL.PackText:=TxnDomInfoLine;
  for I:=0 to OSL.Count-1 do
  begin
     SL.PackText:=OSL[I];
     OldTxnDomInfoLine:=TTxnDomInfoLine.Create;
     try
        with OldTxnDomInfoLine do
        begin
           if SL.Count > 0 then if SL[0] = '1' then Enabled:=True else Enabled:=False;
           if SL.Count > 1 then if SL[1] = '1' then Focused:=True else Focused:=False;
           if SL.Count > 2 then DomType   :=SL[2];
           if SL.Count > 3 then Name      :=SL[3];
           if SL.Count > 4 then Prompt    :=SL[4];
           if SL.Count > 5 then Text      :=SL[5];
           if SL.Count > 6 then Hint      :=SL[6];
           if SL.Count > 7 then Error     :=SL[7];
           if SL.Count > 8 then Validation:=SL[8];
           if SL.Count > 9 then Addtional :=SL[9];
        end;                         
     except                          
        // ??
     end;
     Add(OldTxnDomInfoLine);
  end;
  Result:=Count;
  SL.Free;
  OSL.Free;
end;

end.
