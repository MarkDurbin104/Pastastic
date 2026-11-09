library TBuilder;

uses
  Classes,ComObj,ComServ,SysUtils,DB,DBTables,StringUtil,FileCtrl,
  StringWrapperU,ParseNodeU,TableParserU,GPCSErrorLine,GPCSBaseAU,GPCSGUID,PackStrListU;
  
procedure CreateNewTable(DBName:String;TNode:TTableNode);
var
   Table:TTable;
   DatabaseType:String;
   Node:TCorvusNode;
   I,Len:Integer;
begin
   DatabaseType:=GetGPCSRegString('Workstation','DBType','Paradox');
   if DatabaseType = 'Paradox' then
   begin
      Table:=TTable.Create(nil);
      with Table do
      begin
         try
            Active:=False;
            DatabaseName:=DBName;
            TableType:=ttParadox;
            TableName:=TNode.Name;
            FieldDefs.Clear;
            for I:=0 to TNode.ColumnCount-1 do
            begin
               case TNode.Column[I].ColType of
                  ctText     : begin
                                  Len:=100;
                                  Node:=TNode.Column[I].NodeNamed('ColType');
                                  if Node <> nil then
                                  begin
                                     Node:=Node.NodeNamed('Text');
                                     if (Node <> nil) and (Node.Count > 0) then
                                        Len:=StrToIntDef(Node[0],100);
                                  end;
                                  FieldDefs.Add(TNode.Column[I].ColName,ftString  ,Len,TNode.Column[I].Key);
                               end;
                  ctDateTime : FieldDefs.Add(TNode.Column[I].ColName,ftDateTime,0  ,TNode.Column[I].Key);
                  ctMoney    : FieldDefs.Add(TNode.Column[I].ColName,ftCurrency,0  ,TNode.Column[I].Key);
                  ctNumber   : FieldDefs.Add(TNode.Column[I].ColName,ftInteger ,0  ,TNode.Column[I].Key);
                   
               end;
            end;
            IndexDefs.Clear;
            if TNode.KeyColumns <> '' then
               IndexDefs.Add('',TNode.KeyColumns,[ixPrimary,ixUnique]);
            CreateTable;
         except
            on E:Exception do
               RaiseGUIDException('{4B910737-DE24-4EC2-9D75-D6ED3A1B72D3}',E);
         end;
      end;
   end
end;
procedure AddDomInfo(TxnDomInfoLine:String;CmpList:TStrings);
var
  DomInfoLine:TDomInfoLine;
  SL:TPackStringList;
  Name:String;
  I:Integer;
begin
  SL:=TPackStringList.Create;
  DomInfoLine:=TDomInfoLine.Create;
  SL.PackText:=TxnDomInfoLine;
  for I:=0 to SL.Count-1 do
  begin
     DomInfoLine.PackText:=SL[I];
     Name:=Replace(DomInfoLine.Prompt, ' ', '');
     CmpList.AddObject(Name,TStringObject.Create(DomInfoLine.Text));
  end;
  SL.Free;
end;
procedure PopulateCmpList(UpdateLines:TTxnLogLines;CmpList:TStrings);
var
   TLine:TTxnLogLine;
   I:Integer;
begin
   while CmpList.Count > 0 do
   begin
      if CmpList.Objects[0] <> nil then
         TStringObject(CmpList.Objects[0]).Free;
      CmpList.Delete(0);
   end;
   if UpdateLines.Count > 0 then
   begin
      TLine:=TTxnLogLine.Create;
      TLine.Packtext:=UpdateLines[0];
      CmpList.AddObject('RecordID',        TStringObject.Create(TLine.RecordID   ));
      CmpList.AddObject('WSNumber',        TStringObject.Create(TLine.WSNumber   ));
      CmpList.AddObject('OfficeCode',      TStringObject.Create(TLine.Office     ));
      CmpList.AddObject('AccountingPeriod',TStringObject.Create(TLine.Period     ));
      CmpList.AddObject('TransactionType', TStringObject.Create(TLine.RecType    ));
      CmpList.AddObject('TxnDateTime',     TStringObject.Create(DateTimeToStr(TLine.DateTime)));
      CmpList.AddObject('DateTime',        TStringObject.Create(DateTimeToStr(TLine.DateTime)));
      CmpList.AddObject('Teller',          TStringObject.Create(TLine.Teller     ));
      CmpList.AddObject('ProgramID',       TStringObject.Create(TLine.Prod       ));
      CmpList.AddObject('PLU',             TStringObject.Create(TLine.PLU        ));
      CmpList.AddObject('ItemPrice',       TStringObject.Create(TLine.Price      ));
      CmpList.AddObject('TxnIdent',        TStringObject.Create(TLine.Ident      ));
      CmpList.AddObject('ItemQuantity',    TStringObject.Create(TLine.Quantity   ));
      CmpList.AddObject('ItemValue',       TStringObject.Create(TLine.TxnValue   ));
      CmpList.AddObject('Description',     TStringObject.Create(TLine.Description));
      for I:=0 to UpdateLines.Count-1 do
      begin
         TLine.Packtext:=UpdateLines[I];
         if TLine.DomInfo <> '' then
            AddDomInfo(TLine.DomInfo,CmpList);
      end;
      TLine.Free;
   end;
end;
procedure AppendToFile(FileName,S:String);
var
   FileStream:TFileStream;
begin
   FileStream:=nil;
   try
      if FileExists(FileName) then
         FileStream:=TFileStream.Create(FileName,fmOpenReadWrite or fmShareExclusive);
   except
      FileStream:=nil;
   end;
   
   try
      if FileStream = nil then 
      begin
         ForceDirectories(ExtractFilePath(FileName));
         FileStream:=TFileStream.Create(FileName,fmCreate or fmShareExclusive);
      end;
   except
      FileStream:=nil;
   end;
      
   if FileStream = nil then Exit;
   
   try
      FileStream.Position:=FileStream.Size; 
      S:=S+#13#10;
      FileStream.Write(Pointer(S)^,Length(S));
   except;
      ;
   end;
   try
      FileStream.Free;
   except;
      ;
   end;
end;
procedure AppendToFiles(Date:TDateTime;FileName,S,SubDir,Duplicate:String;Yearly,Monthly,Daily:Boolean);
var
   Path,Name,JName,Ext:String;
begin
   Path:=ExtractFilePath(FileName);
   Name:=ExtractFileName(FileName);
   Ext:=ExtractFileExt(FileName);
   JName:=Copy(Name,1,Length(Name)-(Length(Ext)));
   if SubDir <> '' then
      Path:=Path+SubDir+'\';
      
   AppendToFile(Path+Name,S);
   if Yearly  then AppendToFile(Path+FormatDateTime('yyyy',Date)+'\'+Name,S);
   if Monthly then AppendToFile(Path+FormatDateTime('yyyy',Date)+'\'+FormatDateTime('yyyy.mm',Date)+'\'+Name,S);
   if Daily   then AppendToFile(Path+FormatDateTime('yyyy',Date)+'\'+FormatDateTime('yyyy.mm',Date)+'\'+FormatDateTime('yyyy.mm.dd',Date)+'\'+Name,S);
   if Duplicate <> '' then
   begin
      AppendToFile(Duplicate+'\'+Name,S);
      if Yearly  then AppendToFile(Duplicate+'\'+FormatDateTime('yyyy',Date)+'\'+Name,S);
      if Monthly then AppendToFile(Duplicate+'\'+FormatDateTime('yyyy',Date)+'\'+FormatDateTime('yyyy.mm',Date)+'\'+Name,S);
      if Daily   then AppendToFile(Duplicate+'\'+FormatDateTime('yyyy',Date)+'\'+FormatDateTime('yyyy.mm',Date)+'\'+FormatDateTime('yyyy.mm.dd',Date)+'\'+Name,S);
   end;
end;
procedure UpdateTable(TNode:TTableNode;UpdateLines:TTxnLogLines;TableList:TStrings);
var
   Table:TTable;
   I:Integer;
   Idx:Integer;
   CmpList:TStringList;
   SL:TPackStringList;
   CSVPath,FileName:String;
   Date:TDateTime;
begin
   Table:=nil;
   if TNode.Table then
   begin
      I:=TableList.IndexOf(TNode.Name);
      if I <> -1 then
      begin
         Table:=TTable(TableList.Objects[I]);
      end
      else
      begin
         Table:=TTable.Create(nil);
         Table.DatabaseName:='PSL';
         Table.TableName:=TNode.Name;
         try
            Table.Active:=True;
         except
            Table.Active:=False;
            CreateNewTable('PSL',TNode);
         end;
         TableList.AddObject(TNode.Name,Table);
      end;
   end;

   try
      CmpList:=TStringList.Create;
      PopulateCmpList(UpdateLines,CmpList);
      if TNode.Table and (Table <> nil) then
      begin
         Table.Active:=True;
         try
            Table.Append; 
            for I:=0 to TNode.ColumnCount-1 do
            begin
               Idx:=CmpList.IndexOf(TNode.Column[I].Name);
               if Idx <> -1 then
                  Table.FieldByName(TNode.Column[I].ColName).AsString:=TStringObject(CmpList.Objects[Idx]).Value
               else
                  Table.FieldByName(TNode.Column[I].ColName).AsString:='0';
            end;
            Table.Post;
         except
            // key violation
         end;
      end;
     
      if TNode.CSV then
      begin
         try
            CSVPath:=GetPSLRegString('Table Builder','CSV Path','C:\CSVs');
            Date:=DaysUntil_010198+(StrToInt(TStringObject(CmpList.Objects[CmpList.IndexOf('AccountingPeriod')]).Value));
            SL:=TPackStringList.Create;
            FileName:=CSVPath+'\'+TNode.Name+'.csv';
            if not FileExists(FileName) then
            begin
               for I:=0 to TNode.ColumnCount-1 do
                  SL.Add(TNode.Column[I].ColName);
               AppendToFiles(Date,FileName,SL.CommaText,TNode.SubDirectory,TNode.Duplicate,TNode.Yearly,TNode.Monthly,TNode.Daily);
               SL.Clear;
            end;
            for I:=0 to TNode.ColumnCount-1 do
            begin
               Idx:=CmpList.IndexOf(TNode.Column[I].Name);
               if Idx <> -1 then
                  SL.Add(TStringObject(CmpList.Objects[Idx]).Value)
               else
                  SL.Add('0')
            end;
            AppendToFiles(Date,FileName,SL.CommaText,TNode.SubDirectory,TNode.Duplicate,TNode.Yearly,TNode.Monthly,TNode.Daily);
            SL.Free;
         except
            on E:Exception do
               RaiseGUIDException('{C474782D-337C-4639-836D-0FF81F5F8D92}',E);
         end;
      end;
      
      while CmpList.Count > 0 do
      begin
         if CmpList.Objects[0] <> nil then
            TStringObject(CmpList.Objects[0]).Free;
         CmpList.Delete(0);
      end;
      CmpList.Free;
   except
      on E:Exception do
         RaiseGUIDException('{5FF191FB-2BC7-4CE4-881F-36286DF33AB3}',E);
   end;
end;
procedure ProcessBlock(TablesNode:TTablesNode;TableList:TStringList;UpdateLines:TTxnLogLines);
var
   TNode:TTableNode;
   TLine:TTxnLogLine;
   TableNames:TStringList;
   J:Integer;
begin
    if UpdateLines.Count > 0 then
    begin
       TLine:=TTxnLogLine.Create;
       TLine.PackText:=UpdateLines[0];
       TableNames:=TStringList.Create;
       TableNames.CommaText:=TablesNode.TablesUsingPLU(TLine.PLU);
       for J:=0 to TableNames.Count-1 do
       begin
          TNode:=TablesNode.TableNamed(TableNames[J]);
          if (TNode <> nil) and (Pos(TLine.RecType,TNode.RequiredTxnTypes) <> 0) then
             UpdateTable(TNode,UpdateLines,TableList);
       end;
       TLine.Free;
    end;
end;
procedure CheckData(MessageData:String);
var
   TLines:TTxnLogLines;
   UpdateLines:TTxnLogLines;
   SingleLines:TTxnLogLines;
   TLine:TTxnLogLine;
   TableNames:TStringList;
   I:Integer;
   TableDefinitionFile:String;
const
   TablesNode:TTablesNode = nil;
   TableList:TStringList = nil;
begin
   TableDefinitionFile:=GetPSLRegString('Table Builder','Definition File','');
   if not FileExists(TableDefinitionFile) then Exit;
   if TablesNode = nil then
   begin
      try
         TablesNode:=TTablesNode.Create('Tables',TableDefinitionFile,1);
         TablesNode.ParseFile(ExtractFilePath(TableDefinitionFile),TableDefinitionFile,1);
      except
         on E:Exception do
         begin
            RaiseGUIDException('{F344D1DE-F9D7-4F6B-A14E-73BDF12400E6}',E);
         end;
      end;
   end;
   if TableList = nil then
   begin
      TableList:=TStringList.Create;
   end;
   if MessageData = 'Complete' then
   begin
      TablesNode.Free;
      TablesNode:=nil;
      while TableList.Count > 0 do
      begin
         TTable(TableList.Objects[0]).Free;
         TableList.Delete(0);
      end;
      TableList.Free;
      TableList:=nil;
   end;
   if (TablesNode <> nil) and (TablesNode.Count > 0) then
   begin
      TLines:=TTxnLogLines.Create;    
      UpdateLines:=TTxnLogLines.Create;    
      SingleLines:=TTxnLogLines.Create;    
      TLine:=TTxnLogLine.Create;    
      TableNames:=TStringList.Create;
      try
         TLines.PackText:=MessageData;
         for I:=0 to TLines.Count-1 do
         begin
            TLine.PackText:=TLines[I];
            if Pos(' '+TLine.RecType+' ',' TxnLine StartDay ') <> 0 then
            begin
               UpdateLines.Add(TLines[I]);
            end
            else 
            begin
               if TLine.RecType = 'TxnTotal' then
               begin
                  if UpdateLines.Count > 0 then
                  begin
                     UpdateLines.Add(TLines[I]);
                     ProcessBlock(TablesNode,TableList,UpdateLines);
                  end;
                  UpdateLines.Clear;
               end
               else
               begin
                  SingleLines.Add(TLines[I]);
                  ProcessBlock(TablesNode,TableList,SingleLines);
                  SingleLines.Clear;
               end;                         
            end;
         end;
         if UpdateLines.Count > 0 then
            ProcessBlock(TablesNode,TableList,UpdateLines);
      except
         on E:Exception do
            RaiseGUIDException('{49830E19-729F-440D-B37D-7F4A05FBAD4A}',E);
      end;
      UpdateLines.Free;
      SingleLines.Free;
      TableNames.Free;
      TLines.Free;
      TLine.Free;
   end; 
end;

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer,
  CheckData;
  
type
  TTableBuilder = class(TAutoObject)
  end;
begin
  TGPCSCompFactory.Create(ComServer,TTableBuilder,StringToGUID('{D2D12798-D96E-4E6F-A22F-178AEACAEB3F}'),
                          'Utility.TBuilder','CORVUS Table Builder',
                          ciMultiInstance);
end. 
