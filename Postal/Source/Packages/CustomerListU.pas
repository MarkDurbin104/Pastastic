unit CustomerListU;

interface
uses
   Classes,SysUtils,DB,DBTables,FileCtrl,
   GPCSGUID,PackStrListU, GPCSErrorLine, StringUtil;
type
   TCustomerTransaction = class(TObject)
     private
        FTxnDate:TDateTime;
        FTxnType:String;
        FTxnValue:Currency;
     public
        property TxnDate :TDateTime read FTxnDate  write FTxnDate ;
        property TxnType :String    read FTxnType  write FTxnType ;
        property TxnValue:Currency  read FTxnValue write FTxnValue;
   end;
   TCustomerTransactions = class(TList)
     protected
        function  GetObject(Index:Integer):TCustomerTransaction;
        procedure SetObject(Index:Integer;Value:TCustomerTransaction);
     public
        function Add(Value:TCustomerTransaction):Integer;
        property Items[Index:Integer]:TCustomerTransaction read GetObject write SetObject; default;
   end;
   TCustomerDetails = class(TObject)
   private
     FIdentifier    :Integer;
     FCustName      :String;
     FCustType      :String;
     FCustNumber    :String;
     FCustAddress1  :String;
     FCustAddress2  :String;
     FCustPOBox     :String;
     FCustTelNo     :String;
     FCurrentBalance:Currency;
     FTxns:TCustomerTransactions;
   public
     constructor Create;
     destructor Destroy; override;
     property Identifier    :Integer  read FIdentifier     write FIdentifier    ;
     property CustName      :String   read FCustName       write FCustName      ;
     property CustType      :String   read FCustType       write FCustType      ;
     property CustNumber    :String   read FCustNumber     write FCustNumber    ;
     property CustAddress1  :String   read FCustAddress1   write FCustAddress1  ;
     property CustAddress2  :String   read FCustAddress2   write FCustAddress2  ;
     property CustPOBox     :String   read FCustPOBox      write FCustPOBox     ;
     property CustTelNo     :String   read FCustTelNo      write FCustTelNo     ;
     property CurrentBalance:Currency read FCurrentBalance write FCurrentBalance;
     property Txns:TCustomerTransactions read FTxns write FTxns;
   end;

   TCustomerGroups = class ( TObject )
   private
      FGroupList :TPackStringList;
      function  GetItem(Index:Integer):String;
      function  GetItemIden(Index:integer):integer;
   public
      constructor create ;
      destructor  destroy ; override ;
      procedure Add( Group: String; iden:integer );
      procedure CommaText( GroupsCommaText:String );
      function  Groups : String ;
      function  IsInGroups( Groups: string ) : boolean ;
      function  Count : integer;
      function  GetIden( Group:string ):integer;
      property  Iden [Index:Integer]:integer read GetItemIden ;
      property  Items[Index:Integer]:String  read GetItem ;
   end ;

   TCustomers = class(TObject)
     //private
        //FListNames : TPackStringList ;
     public
       //constructor Create ;
       //destructor  Destroy ; override ;
       class function  ListNamesInGroups( Groups: String ): string ;
       class function  ListNames:String;
       class function  GetCustomerDetails(Value:String;IncludeTxns:Boolean):TCustomerDetails;
       class function  GetCustomerTypeDetails(Value,CustType:String;IncludeTxns:Boolean):TCustomerDetails;
       class procedure SetCustomerDetails(Value:TCustomerDetails);
       class procedure SetCustomerDetailsInGroups(Value:TCustomerDetails;Groups:String);
       class procedure DelCustomerDetails(Value:String);
       class procedure DelCustomerTypeDetails(CustName,CustType:String);
       class function  CustomerStatement(Title,Name,DateRangeFrom,DateRangeTo:String):String;
       class function  CustomerTypeStatement(Title,Name,CustType,DateRangeFrom,DateRangeTo:String):String;
       class procedure CreateTables(OverwriteIfExists:Boolean);
       class procedure WriteCustTxn(Identifier:Integer;TxnType:String;Value:Currency);
       class procedure CustomerTransaction(Name,TxnType:String;Value:Currency);
       class procedure CustomerTypeTransaction(CustName,CustType,TxnType:String;Value:Currency);
   end;

implementation
{TCustomerDetails}
constructor TCustomerDetails.Create;
begin
   inherited Create;
   FTxns:=TCustomerTransactions.Create;
end;
destructor TCustomerDetails.Destroy;
begin
   while Txns.Count > 0 do
   begin
      Txns[0].Free;
      Txns.Delete(0);
   end;
   FTxns.Free;
   inherited Destroy;
end;
{TCustomerTransactions}
function  TCustomerTransactions.GetObject(Index:Integer):TCustomerTransaction;
begin
   Result:=inherited Items[Index];
end;
procedure TCustomerTransactions.SetObject(Index:Integer;Value:TCustomerTransaction);
begin
   inherited Items[Index]:=Value;
end;
function TCustomerTransactions.Add(Value:TCustomerTransaction):Integer;
begin
   Result:=inherited Add(Value);
end;

{TCustomerGroups}
constructor TCustomerGroups.Create ;
begin
   FGroupList :=TPackStringList.Create;
end ;
destructor TCustomerGroups.destroy ;
begin
   FGroupList.Free ;
   inherited destroy ;
end ;
procedure TCustomerGroups.Add( Group: String; Iden:integer );
begin
   if (FGroupList.IndexOf( Group )< 0) then FGroupList.AddObject( Group, TObject(Iden) );
end ;
procedure TCustomerGroups.CommaText( GroupsCommaText:String );
begin
   FGroupList.CommaText := GroupsCommaText;
end ;
function TCustomerGroups.Groups : String ;
begin
   result := FGroupList.Commatext ;
end ;
function TCustomerGroups.IsInGroups( Groups: string ) : boolean ;
var
   StringGroups:TPackStringList;
   I : integer ;
begin
   StringGroups:=TPackStringList.Create;
   StringGroups.CommaText := Groups ;
   i := 0 ;
   result := false ;
   while (i <= StringGroups.Count -1) and not result do
   begin
      result :=(FGroupList.IndexOf( StringGroups[i] )>= 0) ;
      Inc( i );
   end ;
   StringGroups.free;
end ;
function TCustomerGroups.GetIden( Group:string ):integer;
begin
   if (FGroupList.IndexOf( Group )>= 0) then
      result := Integer( FGroupList.Objects[FGroupList.IndexOf( Group )])
   else
      result:=0;
end ;
function TCustomerGroups.GetItem(Index:Integer):String;
begin
   if Index <= FGroupList.Count -1 then
      Result := FGroupList[ Index ]
   else
      Result := '';
end ;
function TCustomerGroups.GetItemIden(Index:Integer):integer;
begin
   if Index <= FGroupList.Count -1 then
      Result := Integer(FGroupList.Objects[ Index ])
   else
      Result := 0;
end ;

function TCustomerGroups.Count:integer;
begin
   Result := FGroupList.Count;
end ;

{TCustomers}
//constructor TCustomers.Create ;
//begin
//   FListNames := TPackStringList.Create ;
//end ;
//destructor  TCustomers.Destroy ;
//var
//   i : integer ;
//begin
//   for I := 0 to FListNames.Count  -1 do
//      TCustomerGroups( FListNames.Objects[ i ] ).Free ;
//   FListNames.Free ;
//   inherited destroy ;
//end ;
class function TCustomers.GetCustomerTypeDetails(Value,CustType:String;IncludeTxns:Boolean):TCustomerDetails;
var
   CDTable:TQuery;
   DBPath:String;
   CT:TCustomerTransaction;
begin
   CustType := Replace( CustType,'"','''' );
   DBPath:=GetGPCSRegString('Customers','DatabasePath',ExtractFilePath(ParamStr(0))+'Database');
   Result:=TCustomerDetails.Create;
   CDTable:=TQuery.Create(nil);
   CDTable.DatabaseName:=DBPath;
   CDTable.SQL.Text:='Select * from CustomerDetails where CDName = '''+Value+''' and CDType in ('+CustType+')';
   try
      CDTable.Active:=True;
      CDTable.First;
      if not CDTable.EOF then
      begin
         Result.CustName      :=CDTable.FieldByName('CDName'      ).AsString;
         Result.Identifier    :=CDTable.FieldByName('CDIdentifier').AsInteger;
         Result.CustType      :=CDTable.FieldByName('CDType'      ).AsString;
         Result.CustNumber    :=CDTable.FieldByName('CDNumber'    ).AsString;
         Result.CustAddress1  :=CDTable.FieldByName('CDAddress1'  ).AsString;
         Result.CustAddress2  :=CDTable.FieldByName('CDAddress2'  ).AsString;
         Result.CustPOBox     :=CDTable.FieldByName('CDPOBox'     ).AsString;
         Result.CustTelNo     :=CDTable.FieldByName('CDTelNo'     ).AsString;
//         Result.CurrentBalance:=999.99;
      end;
      CDTable.Active:=False;
   except
      on E : Exception do RaiseGUIDException('{2A23DAA5-EEE2-4C83-B34B-377CAE5374AE}',E);
   end;
   if IncludeTxns then
   begin
      CDTable.SQL.Text:='Select * from CustomerTransactions where CDIdentifier = '+IntToStr(Result.Identifier)+'';
      try
         CDTable.Active:=True;
         CDTable.First;
         while not CDTable.EOF do
         begin
            CT:=TCustomerTransaction.Create;
            CT.TxnDate :=CDTable.FieldByName('CDDateTime').Value;
            CT.TxnType :=CDTable.FieldByName('CDType'    ).Value;
            CT.TxnValue:=CDTable.FieldByName('CDValue'   ).Value;
            Result.Txns.Add(CT);
            CDTable.Next;
         end;
         CDTable.Active:=False;
      except
      on E : Exception do RaiseGUIDException('{246CB9C8-B90B-4DDA-A909-001D105A4526}',E);
      end;
   end;
   CDTable.Free;
end ;
class function TCustomers.GetCustomerDetails(Value:String;IncludeTxns:Boolean):TCustomerDetails;
var
   CDTable:TQuery;
   DBPath:String;
   CT:TCustomerTransaction;
begin
   DBPath:=GetGPCSRegString('Customers','DatabasePath',ExtractFilePath(ParamStr(0))+'Database');
   Result:=TCustomerDetails.Create;
   CDTable:=TQuery.Create(nil);
   CDTable.DatabaseName:=DBPath;
   CDTable.SQL.Text:='Select * from CustomerDetails where CDName = '''+Value+'''';
   try
      CDTable.Active:=True;
      CDTable.First;
      if not CDTable.EOF then
      begin
         Result.CustName      :=CDTable.FieldByName('CDName'      ).Value;
         Result.Identifier    :=CDTable.FieldByName('CDIdentifier').Value;
         Result.CustType      :=CDTable.FieldByName('CDType'      ).Value;
         Result.CustNumber    :=CDTable.FieldByName('CDNumber'    ).Value;
         Result.CustAddress1  :=CDTable.FieldByName('CDAddress1'  ).Value;
         Result.CustAddress2  :=CDTable.FieldByName('CDAddress2'  ).Value;
         Result.CustPOBox     :=CDTable.FieldByName('CDPOBox'     ).Value;
         Result.CustTelNo     :=CDTable.FieldByName('CDTelNo'     ).Value;
//         Result.CurrentBalance:=999.99;
      end;
      CDTable.Active:=False;
   except
      on E : Exception do RaiseGUIDException('{2A23DAA5-EEE2-4C83-B34B-377CAE5374AE}',E);
   end;
   if IncludeTxns then
   begin
      CDTable.SQL.Text:='Select * from CustomerTransactions where CDIdentifier = '+IntToStr(Result.Identifier)+'';
      try
         CDTable.Active:=True;
         CDTable.First;
         while not CDTable.EOF do
         begin
            CT:=TCustomerTransaction.Create;
            CT.TxnDate :=CDTable.FieldByName('CDDateTime').Value;
            CT.TxnType :=CDTable.FieldByName('CDType'    ).Value;
            CT.TxnValue:=CDTable.FieldByName('CDValue'   ).Value;
            Result.Txns.Add(CT);
            CDTable.Next;
         end;
         CDTable.Active:=False;
      except
      on E : Exception do RaiseGUIDException('{246CB9C8-B90B-4DDA-A909-001D105A4526}',E);
      end;
   end;
   CDTable.Free;
end;
class procedure TCustomers.WriteCustTxn(Identifier:Integer;TxnType:String;Value:Currency);
var
   CDTable:TTable;
   DBPath:String;
begin
   DBPath:=GetGPCSRegString('Customers','DatabasePath',ExtractFilePath(ParamStr(0))+'Database');
   CDTable:=TTable.Create(nil);
   CDTable.DatabaseName:=DBPath;
   CDTable.TableName:='CustomerTransactions';
   try
      CDTable.Active:=True;
      CDTable.Append;
      CDTable.FieldByName('CDIdentifier').Value:=Identifier;
      CDTable.FieldByName('CDDateTime'  ).Value:=Now;
      CDTable.FieldByName('CDType'      ).Value:=TxnType;
      CDTable.FieldByName('CDValue'     ).Value:=Value;
      CDTable.Post;
      CDTable.Active:=False;
   except
      on E : Exception do RaiseGUIDException('{3B764900-AE80-4485-BDC9-3C1CCCFE1CCC}',E);
   end;
   CDTable.Free;
end;
class procedure TCustomers.CustomerTypeTransaction(CustName,CustType,TxnType:String;Value:Currency);
var
   CDTable:TQuery;
   DBPath:String;
   Identifier:Integer;
begin
   DBPath:=GetGPCSRegString('Customers','DatabasePath',ExtractFilePath(ParamStr(0))+'Database');
   CDTable:=TQuery.Create(nil);
   CDTable.DatabaseName:=DBPath;
   CDTable.SQL.Text:='Select CDIdentifier from CustomerDetails where CDName = '''+CustName+''' and CDType in ('+CustType+')';
   try
      CDTable.Active:=True;
      CDTable.First;
      if not CDTable.EOF then
      begin
         Identifier:=CDTable.FieldByName('CDIdentifier').Value;
         WriteCustTxn(Identifier,TxnType,Value);
      end
      else
      begin
        raise EDatabaseError.Create('No Customer Details Found');
      end;
      CDTable.Active:=False;
   except
      on E : Exception do RaiseGUIDException('{378011E1-2FF0-4359-94C8-9F2BB134886E}',E);
   end;
   CDTable.Free;
end ;
class procedure TCustomers.CustomerTransaction(Name,TxnType:String;Value:Currency);
var
   CDTable:TQuery;
   DBPath:String;
   Identifier:Integer;
begin
   DBPath:=GetGPCSRegString('Customers','DatabasePath',ExtractFilePath(ParamStr(0))+'Database');
   CDTable:=TQuery.Create(nil);
   CDTable.DatabaseName:=DBPath;
   CDTable.SQL.Text:='Select CDIdentifier from CustomerDetails where CDName = '''+Name+'''';
   try
      CDTable.Active:=True;
      CDTable.First;
      if not CDTable.EOF then
      begin
         Identifier:=CDTable.FieldByName('CDIdentifier').Value;
         WriteCustTxn(Identifier,TxnType,Value);
      end
      else
      begin
        raise EDatabaseError.Create('No Customer Details Found');
      end;
      CDTable.Active:=False;
   except
      on E : Exception do RaiseGUIDException('{378011E1-2FF0-4359-94C8-9F2BB134886E}',E);
   end;
   CDTable.Free;
end;
class procedure TCustomers.DelCustomerTypeDetails(CustName,CustType:String);
var
   CDTable:TQuery;
   DBPath:String;
//   Iden:integer;
begin
   DBPath:=GetGPCSRegString('Customers','DatabasePath',ExtractFilePath(ParamStr(0))+'Database');
   CDTable:=TQuery.Create(nil);
   CDTable.DatabaseName:=DBPath;
   CDTable.SQL.Text:='Delete from CustomerDetails where CDName = '''+CustName+''' and CDType in ('+CustType+')';
   try
      CDTable.ExecSQL;
   except
      on E : Exception do RaiseGUIDException('{184017CC-CE00-4197-A635-B1D679F9B094}',E);
   end;
   CDTable.Free;
end;
class procedure TCustomers.DelCustomerDetails(Value:String);
var
   CDTable:TQuery;
   DBPath:String;
begin
   DBPath:=GetGPCSRegString('Customers','DatabasePath',ExtractFilePath(ParamStr(0))+'Database');
   CDTable:=TQuery.Create(nil);
   CDTable.DatabaseName:=DBPath;
   CDTable.SQL.Text:='Delete from CustomerDetails where CDName = "'+Value+'"';
   try
      CDTable.ExecSQL;
   except
      on E : Exception do RaiseGUIDException('{184017CC-CE00-4197-A635-B1D679F9B094}',E);
   end;
   CDTable.Free;
end;
class procedure TCustomers.SetCustomerDetailsInGroups(Value:TCustomerDetails;Groups:String);
var
   CDTable:TTable;
   DBPath:String;
   //LGroups:TPackStringList;
   //I:integer;
   //Found:boolean;
begin

   if Pos( Value.CustType, Groups )>0 then
   begin
      DBPath:=GetGPCSRegString('Customers','DatabasePath',ExtractFilePath(ParamStr(0))+'Database');
      CDTable:=TTable.Create(nil);
      CDTable.DatabaseName:=DBPath;
      CDTable.TableName:='CustomerDetails';
      try
         CDTable.Active:=True;
         // Also check for the current Customer with a posible different CDTpes
         //LGroups:=TPackStringList.Create;
         //LGroups.CommaText := Groups;
         if (Value.Identifier <> -1) then
         begin
            if CDTable.FindKey([Value.Identifier]) then
               if Pos( CDTable.FieldByName('CDType').Value, Groups ) = 0 then
                  Value.Identifier:= -1;

            //Found := False ;
            //i := 0 ;
            //while (i <= LGroups.count-1 ) and ( Not Found ) do
            //begin
            //   if CDTable.Locate( 'CDName;CDType', VarArrayOf([ Value.CustName, LGroups[i] ]), [] ) then
            //   begin
            //      Value.Identifier:=CDTable.FieldByName('CDIdentifier').Value;
            //      Value.CustType  :=LGroups[i];
            //      Found := True ;
            //   end
            //   else
            //      Value.Identifier:= -1;
            //   Inc( I )
            //end ;
         end ;

         //LGroups.Free ;

         if Value.Identifier = -1 then
         begin
            CDTable.Append;
            CDTable.FieldByName('CDName'      ).Value:=Value.CustName      ;
            CDTable.FieldByName('CDType'      ).Value:=Value.CustType      ;
            CDTable.FieldByName('CDNumber'    ).Value:=Value.CustNumber    ;
            CDTable.FieldByName('CDAddress1'  ).Value:=Value.CustAddress1  ;
            CDTable.FieldByName('CDAddress2'  ).Value:=Value.CustAddress2  ;
            CDTable.FieldByName('CDPOBox'     ).Value:=Value.CustPOBox     ;
            CDTable.FieldByName('CDTelNo'     ).Value:=Value.CustTelNo     ;
            CDTable.Post;
         end
         else if CDTable.FindKey([Value.Identifier]) then
         begin
            CDTable.Edit;
            CDTable.FieldByName('CDName'      ).Value:=Value.CustName      ;
            CDTable.FieldByName('CDType'      ).Value:=Value.CustType      ;
            CDTable.FieldByName('CDNumber'    ).Value:=Value.CustNumber    ;
            CDTable.FieldByName('CDAddress1'  ).Value:=Value.CustAddress1  ;
            CDTable.FieldByName('CDAddress2'  ).Value:=Value.CustAddress2  ;
            CDTable.FieldByName('CDPOBox'     ).Value:=Value.CustPOBox     ;
            CDTable.FieldByName('CDTelNo'     ).Value:=Value.CustTelNo     ;
            CDTable.Post;
         end;
         CDTable.Active:=False;
      except
         on E : Exception do RaiseGUIDException('{A077C1D6-72ED-4CED-BA63-E4A73114D323}',E);
      end;
      CDTable.Free;
   end ;
end ;

class procedure TCustomers.SetCustomerDetails(Value:TCustomerDetails);
var
   CDTable:TTable;
   DBPath:String;
begin
   DBPath:=GetGPCSRegString('Customers','DatabasePath',ExtractFilePath(ParamStr(0))+'Database');
   CDTable:=TTable.Create(nil);
   CDTable.DatabaseName:=DBPath;
   CDTable.TableName:='CustomerDetails';
   try
      CDTable.Active:=True;
      if Value.Identifier = -1 then
      begin
         CDTable.Append;
         CDTable.FieldByName('CDName'      ).Value:=Value.CustName      ;
         CDTable.FieldByName('CDType'      ).Value:=Value.CustType      ;
         CDTable.FieldByName('CDNumber'    ).Value:=Value.CustNumber    ;
         CDTable.FieldByName('CDAddress1'  ).Value:=Value.CustAddress1  ;
         CDTable.FieldByName('CDAddress2'  ).Value:=Value.CustAddress2  ;
         CDTable.FieldByName('CDPOBox'     ).Value:=Value.CustPOBox     ;
         CDTable.FieldByName('CDTelNo'     ).Value:=Value.CustTelNo     ;
         CDTable.Post;
      end
      else if CDTable.FindKey([Value.Identifier]) then
      begin
         CDTable.Edit;
         CDTable.FieldByName('CDName'      ).Value:=Value.CustName      ;
         CDTable.FieldByName('CDType'      ).Value:=Value.CustType      ;
         CDTable.FieldByName('CDNumber'    ).Value:=Value.CustNumber    ;
         CDTable.FieldByName('CDAddress1'  ).Value:=Value.CustAddress1  ;
         CDTable.FieldByName('CDAddress2'  ).Value:=Value.CustAddress2  ;
         CDTable.FieldByName('CDPOBox'     ).Value:=Value.CustPOBox     ;
         CDTable.FieldByName('CDTelNo'     ).Value:=Value.CustTelNo     ;
         CDTable.Post;
      end;
      CDTable.Active:=False;
   except
      on E : Exception do RaiseGUIDException('{A077C1D6-72ED-4CED-BA63-E4A73114D323}',E);
   end;
   CDTable.Free;
end;
function StrToDate(DateS:String):TDateTime;
var
   Y:Word;
   M:Word;
   D:Word;
begin
   D:=StrToIntDef(Copy(DateS,1,2),1);
   M:=StrToIntDef(Copy(DateS,4,2),1);
   Y:=StrToIntDef(Copy(DateS,7,2),98);
   if Y < 80 then Inc(Y,100);
   Inc(Y,1900);
   Result:=EncodeDate(Y,M,D);
end;
class function TCustomers.CustomerTypeStatement(Title,Name,CustType,DateRangeFrom,DateRangeTo:String):String;
var
   SL:TPackStringList;
   CustDet:TCustomerDetails;
   I:Integer;
   DFrom,DTo:TDateTime;
   CT:TCustomerTransaction;
   Balance:Currency;
   Running:Currency;
begin
   SL:=TPackStringList.Create;
   CustDet:=GetCustomerTypeDetails(Name,CustType,True);

   DFrom:=StrToDate(DateRangeFrom);
   DTo  :=StrToDate(DateRangeTo  );
   if DFrom > DTo then // specified in wrong order !
   begin
      DFrom:=DTo;
      DTo  :=StrToDate(DateRangeFrom);
   end;

   SL.Add('"'+Title+'",""');
   SL.Add('"From:'+DateRangeFrom+'",""');
   SL.Add('"To:  '+DateRangeTo  +'",""');
   SL.Add('"Customer Details:'+'",""');
   SL.Add('"Name:    '+CustDet.CustName    +'",""');
   SL.Add('"Number:  '+CustDet.CustNumber  +'",""');
   SL.Add('"Address: '+CustDet.CustAddress1+'",""');
   if Trim(CustDet.CustAddress2) <> '' then
      SL.Add('"         '+CustDet.CustAddress2+'",""');
   SL.Add('"P.O.Box: '+CustDet.CustPOBox   +'",""');
   SL.Add('"Tel:     '+CustDet.CustTelNo   +'",""');
   SL.Add('"",""');
   Balance:=0;
   Running:=0;
   for I:=0 to CustDet.Txns.Count-1 do
   begin
      CT:=CustDet.Txns[I];
      if CT.TxnDate < DFrom then // before start date
      begin
         Balance:=Balance+CT.TxnValue;
         Running:=Balance;
      end
      else if CT.TxnDate < (DTo+1) then
      begin
         if Balance <> 0 then
         begin
            SL.Add('"'+FormatDateTime('dd/mm/yy',CT.TxnDate)+' Balance B/Fwd","'+CurrToStrF(Balance,ffNumber,2)+'"');
            Balance:=0;
         end;
         SL.Add('"'+FormatDateTime('dd/mm/yy',CT.TxnDate)+' '+CT.TxnType+'","'+CurrToStrF(CT.TxnValue,ffNumber,2)+'"');
         Running:=Running+CT.TxnValue;
      end;
   end;
   SL.Add('"",""');
   SL.Add('"'+FormatDateTime('dd/mm/yy',DTo)+' Final Balance","'+CurrToStrF(Running,ffNumber,2)+'"');
   Result:=SL.PackText;
   SL.Free;
   CustDet.Free;
end;

class function TCustomers.CustomerStatement(Title,Name,DateRangeFrom,DateRangeTo:String):String;
var
   SL:TPackStringList;
   CustDet:TCustomerDetails;
   I:Integer;
   DFrom,DTo:TDateTime;
   CT:TCustomerTransaction;
   Balance:Currency;
   Running:Currency;
begin
   SL:=TPackStringList.Create;
   CustDet:=GetCustomerDetails(Name,True);

   DFrom:=StrToDate(DateRangeFrom);
   DTo  :=StrToDate(DateRangeTo  );
   if DFrom > DTo then // specified in wrong order !
   begin
      DFrom:=DTo;
      DTo  :=StrToDate(DateRangeFrom);
   end;

   SL.Add('"'+Title+'",""');
   SL.Add('"From:'+DateRangeFrom+'",""');
   SL.Add('"To:  '+DateRangeTo  +'",""');
   SL.Add('"Customer Details:'+'",""');
   SL.Add('"Name:    '+CustDet.CustName    +'",""');
   SL.Add('"Number:  '+CustDet.CustNumber  +'",""');
   SL.Add('"Address: '+CustDet.CustAddress1+'",""');
   if Trim(CustDet.CustAddress2) <> '' then
      SL.Add('"         '+CustDet.CustAddress2+'",""');
   SL.Add('"P.O.Box: '+CustDet.CustPOBox   +'",""');
   SL.Add('"Tel:     '+CustDet.CustTelNo   +'",""');
   SL.Add('"",""');
   Balance:=0;
   Running:=0;
   for I:=0 to CustDet.Txns.Count-1 do
   begin
      CT:=CustDet.Txns[I];
      if CT.TxnDate < DFrom then // before start date
      begin
         Balance:=Balance+CT.TxnValue;
         Running:=Balance;
      end
      else if CT.TxnDate < (DTo+1) then
      begin
         if Balance <> 0 then
         begin
            SL.Add('"'+FormatDateTime('dd/mm/yy',CT.TxnDate)+' Balance B/Fwd","'+CurrToStrF(Balance,ffNumber,2)+'"');
            Balance:=0;
         end;
         SL.Add('"'+FormatDateTime('dd/mm/yy',CT.TxnDate)+' '+CT.TxnType+'","'+CurrToStrF(CT.TxnValue,ffNumber,2)+'"');
         Running:=Running+CT.TxnValue;
      end;
   end;
   SL.Add('"",""');
   SL.Add('"'+FormatDateTime('dd/mm/yy',DTo)+' Final Balance","'+CurrToStrF(Running,ffNumber,2)+'"');
   Result:=SL.PackText;
   SL.Free;
   CustDet.Free;
end;
class procedure TCustomers.CreateTables(OverwriteIfExists:Boolean);
var
   DBPath:String;
begin
   DBPath:=GetGPCSRegString('Customers','DatabasePath',ExtractFilePath(ParamStr(0))+'Database');
   if not FileExists(DBPath) then
      ForceDirectories(DBPath);
   if (not FileExists(DBPath+'\CustomerDetails.db')) or OverwriteIfExists then
   begin
      with TTable.Create(nil) do
      begin
         try
            Active:=False;
            DatabaseName:=DBPath;
            TableType:=ttParadox;
            TableName:='CustomerDetails';
            with FieldDefs do
            begin
               Clear; // clear the current field definitions
               Add('CDIdentifier',ftAutoInc ,  0,True );
               Add('CDName'      ,ftString  , 50,True );
               Add('CDNumber'    ,ftInteger ,  0,True );
               Add('CDType'      ,ftString  , 50,True );
               Add('CDAddress1'  ,ftString  ,255,False);
               Add('CDAddress2'  ,ftString  ,255,False);
               Add('CDPOBox'     ,ftString  ,255,False);
               Add('CDTelNo'     ,ftString  ,255,False);
            end;
            with IndexDefs do // create the index
            begin
               Clear;
               Add('','CDIdentifier' , [ixPrimary, ixUnique]);
            end;
            CreateTable;
         finally
            Free;
         end;
      end;
   end;
   if (not FileExists(DBPath+'\CustomerTransactions.db')) or OverwriteIfExists then
   begin
      with TTable.Create(nil) do
      begin
         try
            Active:=False;
            DatabaseName:=DBPath;
            TableType:=ttParadox;
            TableName:='CustomerTransactions';
            with FieldDefs do
            begin
               Clear; // clear the current field definitions
               Add('CDIdentifier',ftInteger ,  0,True );
               Add('CDDateTime'  ,ftDateTime,  0,True );
               Add('CDType'      ,ftString  , 20,True );
               Add('CDValue'     ,ftCurrency,  0,True );
            end;
            with IndexDefs do // create the index
            begin
               Clear;
               Add('','CDIdentifier;CDDateTime' , [ixPrimary, ixUnique]);
            end;
            CreateTable;
         finally
            Free;
         end;
      end;
   end;
end;
class function TCustomers.ListNamesInGroups( Groups: String ): string ;
var
   p, i, j : integer ;
   CDTable:TQuery;
   DBPath:String;
   CustTypes :TCustomerGroups ;
   ResultList:TPackStringList;
   FListNames : TPackStringList ;
begin
   FListNames := TPackStringList.Create ;
   if FListNames.Count = 0  then
   begin

      DBPath:=GetGPCSRegString('Customers','DatabasePath',ExtractFilePath(ParamStr(0))+'Database');
      CDTable:=TQuery.Create(nil);
      CDTable.DatabaseName:=DBPath;
      CDTable.SQL.Text:='Select CDName, CDType, CDIdentifier from CustomerDetails';
      try
         CDTable.Active:=True;
         CDTable.First;
         while not CDTable.EOF do
         begin
            P := FListNames.IndexOf( CDTable.FieldByName('CDName').Value ) ;
            if p < 0 then
            begin
               CustTypes:=TCustomerGroups.Create;
               CustTypes.Add( CDTable.FieldByName('CDType' ).Value,CDTable.FieldByName('CDIdentifier' ).Value );
               FListNames.AddObject(CDTable.FieldByName('CDName').Value, CustTypes );
            end
            else
               TCustomerGroups( FListNames.Objects[p] ).Add( CDTable.FieldByName('CDType' ).Value,
                                                             CDTable.FieldByName('CDIdentifier' ).Value ) ;

            CDTable.Next;
         end;
         CDTable.Active:=False;
      except
         on E : Exception do RaiseGUIDException('{CA53234F-FB80-4441-B939-62A58ABD3B67}',E);
      end;
      CDTable.Free;
   end ;

   ResultList := TPackStringList.Create ;
   for i := 0 to FListNames.Count-1 do
   begin
      if (Groups = '') then
      begin
         for j := 0 to TCustomerGroups( FListNames.Objects[i] ).Count-1 do
            ResultList.Add( TCustomerGroups(FListNames.Objects[i]).Items[j] +'  -  '+FListNames[i])
            //ResultList.Add( FListNames[i]+','+TCustomerGroups(FListNames.Objects[i]).Items[j] ) ;
      end
      else if  TCustomerGroups(FListNames.Objects[i]).IsInGroups( Groups ) then
         ResultList.Add( FListNames[i] );
   end ;

   result := ResultList.CommaText ;
   ResultList.Free;

   for I := 0 to FListNames.Count  -1 do
      TCustomerGroups( FListNames.Objects[ i ] ).Free ;
   FListNames.Free ;

end ;

class function TCustomers.ListNames:String;
var
   CDTable:TQuery;
   DBPath:String;
   ResultsSL:TPackStringList;
begin
   ResultsSL:=TPackStringList.Create;
   DBPath:=GetGPCSRegString('Customers','DatabasePath',ExtractFilePath(ParamStr(0))+'Database');
   CDTable:=TQuery.Create(nil);
   CDTable.DatabaseName:=DBPath;
   CDTable.SQL.Text:='Select CDName from CustomerDetails';
   try
      CDTable.Active:=True;
      CDTable.First;
      while not CDTable.EOF do
      begin
         ResultsSL.Add(CDTable.FieldByName('CDName').Value);
         CDTable.Next;
      end;
      CDTable.Active:=False;
   except
      on E : Exception do RaiseGUIDException('{CA53234F-FB80-4441-B939-62A58ABD3B67}',E);
   end;
   Result:=ResultsSL.CommaText;
   CDTable.Free;
   ResultsSL.Free;

end;

end.

