unit MODefinitionsU;

interface

uses
   Windows,Classes,SysUtils,Dialogs,DB,DBCreateU,DBTables,
   GPCSGUID,GPCSErrorLine,PackStrListU,DBUtil,FileTxStatusU;

const
   DaysUntil_010198 = 35796;
   StringsInPack:Boolean = True;
   MOSeriesLength = 20;
   
type
   TMOEventType = (evIssued,evIssueLodged,evAt,evPrinted,evPaid,evPayLodged,evDispatched);
   TMOType    = (moNone, moNormal, moFax, moCompany, moService, moType5, moType6, moJournal);
   TMOFeeType = (ftCommission,ftTransmission,ftDeliveryAdvice,
                 ftPhoneNotifyPayee,ftFaxNotifyPayee,ftEmailNotifyPayee,
                 ftPhoneNotifySender,ftFaxNotifySender,ftEmailNotifySender);
   TMOEvent = class(TObject)
    private
      FEvType :Integer;
      FEvWho  :Integer;
      FEvWhen :Integer;
      FEvWhere:Integer;
    public
      property EvType :Integer read FEvType  write FEvType ;
      property EvWho  :Integer read FEvWho   write FEvWho  ;
      property EvWhen :Integer read FEvWhen  write FEvWhen ;
      property EvWhere:Integer read FEvWhere write FEvWhere;
      procedure SaveToTable(Series,Alias:String);
      procedure LoadFromTable(Series,Alias:String);
   end;
   TMOEvents = class(TList)
    private
      function GetEvent(Index:Integer):TMOEvent;
    public
      property Event[Index:Integer]:TMOEvent read GetEvent; default;
   end;
   
   TMOFee = class(TObject)
    private
       FFeeType:TMOFeeType; 
       FValue  :Currency;
    public
      property FeeType:TMOFeeType read FFeeType write FFeeType;
      property Value  :Currency read FValue   write FValue  ;
      procedure SaveToTable(Series,Alias:String);
      procedure LoadFromTable(Series,Alias:String);
   end;               
   TMOFees = class(TList)
    private
      function GetFee(Index:Integer):TMOFee;
    public
      property Fee[Index:Integer]:TMOFee read GetFee; default;
   end;
   
   TName = class(TObject)
    private
      FGiven :String;
      FFamily:String;
      FOthers:String;
      function GetFull:String;
      function GetAsString:String;
      procedure SetAsString(Value:String);
    public
      property AsString:String read GetAsString write SetAsString;
      property Given   :String read FGiven      write FGiven     ;
      property Family  :String read FFamily     write FFamily    ;
      property Others  :String read FOthers     write FOthers    ;
      property Full    :String read GetFull;
   end;
   TAddress = class(TObject)
    private
      FMainLine :String ;
      FOtherLine:String ;
      FTelephone:String ;
      FPOBox    :Integer;
      FEMail    :String ;
      function GetAsString:String;
      procedure SetAsString(Value:String);
    public
      property AsString :String  read GetAsString write SetAsString;
      property MainLine :String  read FMainLine   write FMainLine  ;
      property OtherLine:String  read FOtherLine  write FOtherLine ;
      property Telephone:String  read FTelephone  write FTelephone ;
      property POBox    :Integer read FPOBox      write FPOBox     ;
      property EMail    :String  read FEMail      write FEMail     ;
   end;
   TPerson = class(TObject)
    private
      FName   :TName   ;
      FAddress:TAddress;
      function GetAsString:String;
      procedure SetAsString(Value:String);
    public
      property AsString:String   read GetAsString write SetAsString;
      property Name    :TName    read FName       write FName      ;
      property Address :TAddress read FAddress    write FAddress   ;
   end;
   
   TMODetail = class(TObject)
    private
       FSender   :TPerson;
       FRecipient:TPerson;
       FInfo     :String ;
    public
      destructor Destroy; override;
      property Sender   :TPerson read FSender    write FSender   ;
      property Recipient:TPerson read FRecipient write FRecipient;
      property Info     :String  read FInfo      write FInfo     ;
      function IsEmpty:Boolean;
      procedure SaveToTable(Series,Alias:String);
      procedure LoadFromTable(Series,Alias:String);
   end;              
   TMOPosition = class(TObject)
    private
       FCurrentOffice:Integer;
       FNextOffice:Integer;
       FWhen      :Integer;
       FDispatched:Integer;
    public             
      property CurrentOffice:Integer read FCurrentOffice write FCurrentOffice;
      property NextOffice   :Integer read FNextOffice    write FNextOffice   ;
      property When         :Integer read FWhen          write FWhen         ;
      property Dispatched   :Integer read FDispatched    write FDispatched   ;
      procedure SaveToTable(Series,Alias:String);
      procedure LoadFromTable(Series,Alias:String);
   end;              
   TMoneyOrder = class(TObject)
    private
      FSeries      :String   ;
      FSerial      :String   ;
      FValue       :Currency ;
      FIssuePeriod :Integer  ;
      FIssueOffice :Integer  ;
      FIssueClerk  :Integer  ;
      FPayPeriod   :Integer  ;
      FPayOffice   :Integer  ;
      FPayClerk    :Integer  ;
      FMOType      :TMOType  ;
      FEvents      :TMOEvents;
      FDetails     :TMODetail;
      FPosition    :TMOPosition;
      FFees        :TMOFees  ;
      procedure SetSeries(Series:String);
      function  GetSeries:String;
      function GetPackedString:String;
      procedure SetPackedString(Value:String);
    public
      constructor Create;
      destructor Destroy; override;
      function Exists(Alias : String) : Boolean;
      property Series      : String       read GetSeries    write SetSeries   ;
      property Serial      : String       read FSerial      write FSerial     ;
      property Value       : Currency     read FValue       write FValue      ;
      property IssuePeriod : Integer      read FIssuePeriod write FIssuePeriod;
      property IssueOffice : Integer      read FIssueOffice write FIssueOffice;
      property IssueClerk  : Integer      read FIssueClerk  write FIssueClerk ;
      property PayPeriod   : Integer      read FPayPeriod   write FPayPeriod  ;
      property PayOffice   : Integer      read FPayOffice   write FPayOffice  ;
      property PayClerk    : Integer      read FPayClerk    write FPayClerk   ;
      property MOType      : TMOType      read FMOType      write FMOType     ;
      property Events      : TMOEvents    read FEvents      write FEvents     ;
      property Details     : TMODetail    read FDetails     write FDetails    ;
      property Position    : TMOPosition  read FPosition    write FPosition   ;
      property Fees        : TMOFees      read FFees        write FFees       ;
      property PackedString:String        read GetPackedString write SetPackedString;
      procedure SaveToTable(Alias:String);
      procedure ReplaceList(PackList:String);
      procedure SaveToList(ThisOffice:Integer);
      procedure RemFromList(ThisOffice:Integer);
      function ListFileContents(SerialNo:String;MOTypes:Integer):String;
      function FindInList(Value:String):String;
      procedure LoadFromTable(Alias:String);
      function LoadFees(Alias,Series:String):TMOFees;
      function LoadEvents(Alias,Series:String):TMOEvents;
      function LoadDetails(Alias,Series:String):TMODetail;
      function LoadPosition(Alias,Series:String):TMOPosition;
   end;
   TMoneyOrders = class(TList)
    private
      function GetMoneyOrder(Index:Integer):TMoneyOrder;
    public
      destructor Destroy; override;
      function CheckTables(Alias:String):Boolean;
      procedure CheckIndex(Alias:String);
      procedure AddFromQuery(Alias,SQL:String);
      procedure FillFromQuery(Alias,SQL:String);
      function GetDispatchOffices(Alias:String):String;
      function GetDispatchItemCount(Alias:String):Integer;
      function MarkDispatch(Alias:String;ToOfficeCode:Integer):String;
      function PrepareDispatches(Alias:String):String;
      property MoneyOrder[Index:Integer]:TMoneyOrder read GetMoneyOrder; default;
   end;


implementation
uses
   MOSupportU;

{TName}
function TName.GetFull:String;
begin
   Result:=FGiven+FOthers+FFamily;
end;
function TName.GetAsString:String;
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Add(FGiven );
   SL.Add(FFamily);
   SL.Add(FOthers);
   Result:=SL.Packtext;
   SL.Free;
end;
procedure TName.SetAsString(Value:String);
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   if (Value <> '') and (Integer(Value[1]) < 32) then
      SL.PackText:=Value
   else
      SL.Text:=Value;
   if SL.Count > 0 then FGiven :=SL[0];
   if SL.Count > 1 then FFamily:=SL[1];
   if SL.Count > 2 then FOthers:=SL[2];
   SL.Free;
end;
{TAddress}
function TAddress.GetAsString:String;
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Add(FMainLine       );
   SL.Add(FOtherLine      );
   SL.Add(FTelephone      );
   SL.Add(IntToStr(FPOBox));
   SL.Add(FEMail          );
   Result:=SL.Packtext;
   SL.Free;
end;
procedure TAddress.SetAsString(Value:String);
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   if (Value <> '') and (Integer(Value[1]) < 32) then
      SL.PackText:=Value
   else
      SL.Text:=Value;
   if SL.Count > 0 then FMainLine       :=SL[0];
   if SL.Count > 1 then FOtherLine      :=SL[1];
   if SL.Count > 2 then FTelephone      :=SL[2];
   if SL.Count > 3 then FPOBox:=StrToIntDef(SL[3],0);
   if SL.Count > 4 then FEMail          :=SL[4];
   SL.Free;
end;
{TPerson}
function TPerson.GetAsString:String;
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   if FName    <> nil then SL.Add(FName   .AsString) else SL.Add('');
   if FAddress <> nil then SL.Add(FAddress.AsString) else SL.Add('');
   Result:=SL.Packtext;
   SL.Free;
end;
procedure TPerson.SetAsString(Value:String);
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   if (Value <> '') and (Integer(Value[1]) < 32) then
      SL.PackText:=Value
   else
      SL.Text:=Value;
   if (SL.Count > 0) and (SL[0] <> '') then
   begin
      if FName = nil then FName:=TName.Create;
      FName.AsString:=SL[0];
   end;
   if (SL.Count > 1) and (SL[1] <> '') then
   begin
      if FAddress = nil then FAddress:=TAddress.Create;
      FAddress.AsString:=SL[1];
   end;
   SL.Free;
end;
{TMOEvents}
function TMOEvents.GetEvent(Index:Integer):TMOEvent;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=Get(Index)
   else
      Result:=nil;
end;
{TMOFees}
function TMOFees.GetFee(Index:Integer):TMOFee;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=Get(Index)
   else
      Result:=nil;
end;              
{TMOEvent}
procedure TMOEvent.LoadFromTable(Series,Alias:String);
begin
end;
procedure TMOEvent.SaveToTable(Series,Alias:String);
var
   Table:TTable;
begin
   Table:=TTable.Create(nil);
   Table.Active:=False;
   Table.DatabaseName:=Alias;
   if GetGPCSRegString('Workstation','DBType','Paradox') = 'SQLServer' then
      Table.TableName:='dbo.MOEVENT'
   else
      Table.TableName:='MOEVENT';
   try
      Table.Active:=True;
      If Table.Locate('MOSeries;MOEvType;MOEvWhere', VarArrayOf([Series,EvType,EvWhere]), []) then Table.Edit
      else Table.Append;
      Table.FieldByName('MOSERIES' ).AsString:=Series ;
      Table.FieldByName('MOEVTYPE' ).Value:=EvType ;
      Table.FieldByName('MOEVWHO'  ).Value:=EvWho  ;
      Table.FieldByName('MOEVWHEN' ).Value:=EvWhen ;
      Table.FieldByName('MOEVWHERE').Value:=EvWhere;
      Table.Post;
      Table.Active:=False;
   except
      on E:Exception do RaiseGUIDException('{D9E180A9-810F-4213-9B8E-0B0CE0F21996}',E);
   end;
   Table.Free;
end;                       
{TMOFee}
procedure TMOFee.LoadFromTable(Series,Alias:String);
begin
end;
procedure TMOFee.SaveToTable(Series,Alias:String);
var
   Table:TTable;
begin
   Table:=TTable.Create(nil);
   Table.Active:=False;
   Table.DatabaseName:=Alias;
   if GetGPCSRegString('Workstation','DBType','Paradox') = 'SQLServer' then
      Table.TableName:='dbo.MOFEE'
   else
      Table.TableName:='MOFEE';
   try
      Table.Active:=True;
      Table.EditKey;
      Table.FieldByName('MOSERIES').AsString:=Series;
      Table.FieldByName('MOFEETYPE').Value:=FeeType;
      if Table.GotoKey then
         Table.Edit
      else
         Table.Append;
      Table.FieldByName('MOSERIES'  ).AsString:=Series ;
      Table.FieldByName('MOFEETYPE' ).Value:=FeeType;
      Table.FieldByName('MOFEEVALUE').Value:=Value  ;
      Table.Post;
      Table.Active:=False;
   except
      on E:Exception do RaiseGUIDException('{DA69E9CB-AC8F-4036-A8C0-FA269E3F115E}',E);
   end;
   Table.Free;
end;        
{TMOPosition}
procedure TMOPosition.SaveToTable(Series,Alias:String);
var
   Table:TTable;
begin
   Table:=TTable.Create(nil);
   Table.Active:=False;
   Table.DatabaseName:=Alias;
   if GetGPCSRegString('Workstation','DBType','Paradox') = 'SQLServer' then
      Table.TableName:='dbo.MOPOSITION'
   else
      Table.TableName:='MOPOSITION';
   try
      Table.Active:=True;
      If Table.Locate('MOSERIES', Series, []) then
        Table.Edit
      else
        Table.Append;
      Table.FieldByName('MOSERIES'       ).AsString:=Series;
      Table.FieldByName('MOWHEN'         ).Value:=When;
      Table.FieldByName('MODISPATCHED'   ).Value:=Dispatched;
      Table.FieldByName('MONEXTOFFICE'   ).Value:=NextOffice   ;
      Table.FieldByName('MOCURRENTOFFICE').Value:=CurrentOffice;
      Table.Post;
      Table.Active:=False;
   except
      on E:Exception do RaiseGUIDException('{5815B50B-F1E9-4B10-998B-0143B815584C}',E);
   end;
   Table.Free;
end;
procedure TMOPosition.LoadFromTable(Series,Alias:String);
var
   Table:TTable;
begin
   Table:=TTable.Create(nil);
   Table.Active:=False;
   Table.DatabaseName:=Alias;
   if GetGPCSRegString('Workstation','DBType','Paradox') = 'SQLServer' then
      Table.TableName:='dbo.MOPOSITION'
   else
      Table.TableName:='MOPOSITION';
   try
      Table.Active:=True;
      Table.EditKey;
      Table.FieldByName('MOSERIES').AsString:=Series;
      if Table.GotoKey then                     
      begin
         FWhen         :=Table.FieldByName('MOWHEN'         ).Value;
         FDispatched   :=Table.FieldByName('MODISPATCHED'   ).Value;
         FNextOffice   :=Table.FieldByName('MONEXTOFFICE'   ).Value;
         FCurrentOffice:=Table.FieldByName('MOCURRENTOFFICE').Value;
      end;
      Table.Active:=False;
   except
      on E:Exception do RaiseGUIDException('{4436F89A-FCD4-470E-89C7-F8F626532935}',E);
   end;
   Table.Free;
end;
{TMODetail}

destructor TMODetail.Destroy;
begin
   if Sender <> nil then
   begin
      if Sender.FName    <> nil then Sender.FName.Free;
      if Sender.FAddress <> nil then Sender.FAddress.Free;
   end;
   if Recipient <> nil then
   begin
      if Recipient.FName    <> nil then Recipient.FName.Free;
      if Recipient.FAddress <> nil then Recipient.FAddress.Free;
   end;
   inherited Destroy;
end;


function TMODetail.IsEmpty:Boolean;
begin
   Result:=False;
   if Sender <> nil then
   begin
      if Sender.Name <> nil then
         with Sender.Name do
            if (Given  <> '') or (Family <> '') or (Others <> '') then Exit;
      if Sender.Address <> nil then
         with Sender.Address do
            if (MainLine  <> '') or (OtherLine <> '')
            or (Telephone <> '') or (POBox     <> 0 ) then Exit;
      if Recipient.Name <> nil then
         with Recipient.Name do
            if (Given  <> '') or (Family <> '') or (Others <> '') then Exit;
      if Recipient.Address <> nil then
         with Recipient.Address do
            if (MainLine  <> '') or (OtherLine <> '')
            or (Telephone <> '') or (POBox     <> 0 ) then Exit;
      if Info <> '' then Exit;
   end;
   Result:=True;
end;

procedure TMODetail.LoadFromTable(Series,Alias:String);
var
   Table:TTable;
   S:String;
begin
   Table:=TTable.Create(nil);
   Table.Active:=False;
   Table.DatabaseName:=Alias;
   if GetGPCSRegString('Workstation','DBType','Paradox') = 'SQLServer' then
      Table.TableName:='dbo.MODETAIL'
   else
      Table.TableName:='MODETAIL';
   try
      Table.Active:=True;
      Table.EditKey;
      Table.FieldByName('MOSERIES').AsString:=Series;
      if Table.GotoKey then
      begin
         S:=Table.FieldByName('MOSENDER').AsString;
         if S <> '' then
         begin
            Sender:=TPerson.Create;
            Sender.AsString:=S;
         end;
         S:=Table.FieldByName('MOPAYEE' ).AsString;
         if S <> '' then
         begin
            Recipient:=TPerson.Create;
            Recipient.AsString:=S;
         end;
         Info:=Table.FieldByName('MOINFO'  ).AsString;
      end;
      Table.Active:=False;
   except
      on E:Exception do RaiseGUIDException('{2CA493CB-D501-4A30-A04C-34CF40A979C0}',E);
   end;
   Table.Free;
end;
procedure TMODetail.SaveToTable(Series,Alias:String);
var
   Table:TTable;
begin
   Table:=TTable.Create(nil);
   Table.Active:=False;
   Table.DatabaseName:=Alias;
   if GetGPCSRegString('Workstation','DBType','Paradox') = 'SQLServer' then
      Table.TableName:='dbo.MODETAIL'
   else
      Table.TableName:='MODETAIL';
   try
      Table.Active:=True;
      Table.EditKey;
      Table.FieldByName('MOSERIES').AsString:=Series;
      if Table.GotoKey then
         Table.Edit
      else
         Table.Append;
      Table.FieldByName('MOSERIES').AsString:=Series;
      if Sender <> nil then
      begin
//         ShowMessage(Sender.AsString);
         Table.FieldByName('MOSENDER').AsString:=Sender.AsString;
      end;
      if Recipient <> nil then
      begin
//         ShowMessage(Recipient.AsString);
         Table.FieldByName('MOPAYEE').AsString:=Recipient.AsString;
      end;
      Table.FieldByName('MOINFO').AsString:=Info;
      Table.Post;
      Table.Active:=False;
   except
      on E:Exception do RaiseGUIDException('{188AD84A-3997-4F22-90C1-CD98CA2A2EB5}',E);
   end;
   Table.Free;
end;

{TMoneyOrder}
constructor TMoneyOrder.Create;
begin
   inherited Create;
   FFees:=nil;
   FEvents:=nil;
   FDetails:=nil;
   FPosition:=nil;
end;

destructor TMoneyOrder.Destroy;
begin
   if FEvents <> nil then
   begin
      while FEvents.Count > 0 do
      begin
         FEvents[0].Free;
         FEvents.Delete(0);
      end;
   end;
   if FFees <> nil then
   begin
      while FFees.Count > 0 do
      begin
         FFees[0].Free;
         FFees.Delete(0);
      end;
   end;
   if FPosition <> nil then
      FPosition.Free;
   if FDetails <> nil then
      FDetails.Free;
   inherited Destroy;
end;

function TMoneyOrder.Exists(Alias : String) :Boolean;
begin
  Result := False;
  try
    With TTable.Create(nil) do
    begin
      try
        Databasename := Alias;
        TableName := DBTypePrefix + 'MONEYORDER';
        Open;
        Result := Locate('MOSerial', FSerial, []);
      finally
        Free;
      end;
    end;
  except
    On E : Exception do RaiseGUIDException('{334E2042-DF83-44FD-973D-5CAEB3B2B0B4}', E);
  end;
end;

procedure TMoneyOrder.LoadFromTable(Alias:String);
var
   Table:TTable;
begin
   Table:=TTable.Create(nil);
   Table.Active:=False;
   Table.DatabaseName:=Alias;
   if GetGPCSRegString('Workstation','DBType','Paradox') = 'SQLServer' then
      Table.TableName:='dbo.MONEYORDER'
   else
      Table.TableName:='MONEYORDER';
   try
      Table.Active:=True;
      Table.EditKey;
      Table.FieldByName('MOSERIES').AsString:=Series;
      if Table.GotoKey then
      begin
         FPayPeriod:=Table.FieldByName('MOPAYPERIOD'  ).Value;
         FPayClerk :=Table.FieldByName('MOPAYCLERK'   ).Value;
      end;
      Table.Active:=False;
      Fees    :=LoadFees    (Alias,Series);
      Events  :=LoadEvents  (Alias,Series);
      Details :=LoadDetails (Alias,Series);
      Position:=LoadPosition(Alias,Series);
   except
      on E:Exception do RaiseGUIDException('{FC77DFBB-8225-493C-BB88-9CB053CB9295}',E);
   end;
   Table.Free;
end;
procedure TMoneyOrder.SaveToTable(Alias:String);
var
   Table:TTable;
   I:Integer;
begin
   if GetGPCSRegString('Indigo3','Money Order Database Here','No') = 'No' then Exit;
   
   Table:=TTable.Create(nil);
   Table.Active:=False;
   Table.DatabaseName:=Alias;
   if GetGPCSRegString('Workstation','DBType','Paradox') = 'SQLServer' then
      Table.TableName:='dbo.MONEYORDER'
   else
      Table.TableName:='MONEYORDER';
   try
      Table.Active:=True;
      Table.EditKey;
      Table.FieldByName('MOSERIES').AsString:=Series;
      if Table.GotoKey then
         Table.Edit
      else
         Table.Append;
      Table.FieldByName('MOSERIES'     ).AsString:=Series;
      Table.FieldByName('MOSERIAL'     ).AsString:=FSerial     ;
      Table.FieldByName('MOVALUE'      ).Value:=FValue      ;
      Table.FieldByName('MOISSUEPERIOD').Value:=FIssuePeriod;
      Table.FieldByName('MOISSUEOFFICE').Value:=FIssueOffice;
      Table.FieldByName('MOISSUECLERK' ).Value:=FIssueClerk ;
      Table.FieldByName('MOPAYOFFICE'  ).Value:=FPayOffice  ;
      Table.FieldByName('MOTYPE'       ).Value:=FMOType     ;
      Table.FieldByName('MOPAYPERIOD'  ).Value:=FPayPeriod  ;
      Table.FieldByName('MOPAYCLERK'   ).Value:=FPayClerk   ;
      Table.Post;
      Table.Active:=False;

      try
         if (Details <> nil) and (not Details.IsEmpty) then
            Details.SaveToTable(Series,Alias);
      except
         on E:Exception do RaiseGUIDException('{7C990CCF-12F8-4E68-A5CD-316BE8083225}',E);
      end;
      
      try
         if (Position <> nil) then
            Position.SaveToTable(Series,Alias);
      except
         on E:Exception do RaiseGUIDException('{0E742F39-AF1C-4376-865E-E3168639D0A0}',E);
      end;
      
      try
         if (Events <> nil) and (Events.Count <> 0) then
         begin
            for I:=0 to Events.Count-1 do
               Events[I].SaveToTable(Series,Alias);
         end;
      except
         on E:Exception do RaiseGUIDException('{6C8B6235-5870-4359-A500-896DB9E3826A}',E);
      end;
      
      try
         if (Fees <> nil) and (Fees.Count <> 0) then
         begin
            for I:=0 to Fees.Count-1 do
               Fees[I].SaveToTable(Series,Alias);
         end;
      except
         on E:Exception do RaiseGUIDException('{17A6A095-6F76-40ED-84D9-32DE6E3C9578}',E);
      end;
      
   except
      on E:Exception do RaiseGUIDException('{03153064-D206-429E-AE45-E0673C369ACA}',E);
   end;
   Table.Free;
end;
procedure TMoneyOrder.SetSeries(Series:String);
var
   IssueDate:TDateTime;
begin
   FSeries:=Series;
   DecodeMoneyOrder(Series,FSerial,FValue,FIssueOffice,FPayOffice,FIssueClerk,FMOType,IssueDate);
   FIssuePeriod:=DateToPeriod(IssueDate);
end;
function TMoneyOrder.GetSeries:String;
var
   IssueDate:TDateTime;
begin       
   if FSeries = '' then
   begin
      IssueDate:=PeriodToDate(FIssuePeriod);
      FSeries:=EncodeMoneyOrder(FSerial,FValue,FIssueOffice,FPayOffice,FIssueClerk,FMOType,IssueDate,False);
   end;
   Result:=FSeries;
end;

procedure WriteInt(Value:Integer;Stream:TStream);
begin
   Stream.WriteBuffer(Pointer(@Value)^,SizeOf(Value));
end;
function ReadInt(Stream:TStream):Integer;
begin
   Stream.ReadBuffer(Pointer(@Result)^,SizeOf(Result));
end;
procedure WriteStr(Value:String;Stream:TStream);
begin
   WriteInt(Length(Value),Stream);
   if Length(Value) <> 0 then
      Stream.WriteBuffer(Pointer(@Value[1])^,Length(Value));
end;               
function ReadStr(Stream:TStream):String;
var
   Len:Integer;
begin
   Len:=ReadInt(Stream);
   SetLength(Result,Len);
   if Len <> 0 then
      Stream.ReadBuffer(Pointer(@Result[1])^,Len);
end;
    
function TMoneyOrder.GetPackedString:String;
var
   I:Integer;
   I32:Integer;
   SS:TStringStream;
   SL:TPackStringList;
begin
   if StringsInPack then
   begin
      SL:=TPackStringList.Create;
      SL.Add(Series);
      SL.Add(IntToStr(FPayPeriod));
      SL.Add(IntToStr(FPayClerk ));
      if Events = nil then
      begin
        SL.Add('0');
      end
      else
      begin
        SL.Add(IntToStr(Events.Count));
        for I:=0 to Events.Count-1 do
        begin
           SL.Add(IntToStr(Events[I].FEvType ));
           SL.Add(IntToStr(Events[I].FEvWho  ));
           SL.Add(IntToStr(Events[I].FEvWhen ));
           SL.Add(IntToStr(Events[I].FEvWhere));
        end;                          
      end;
      if Fees = nil then
      begin
        SL.Add('0');
      end
      else
      begin
        SL.Add(IntToStr(Fees.Count));
        for I:=0 to Fees.Count-1 do
        begin
           SL.Add(CurrToStr(        Fees[I].Value  ) );
           SL.Add(IntToStr (Integer(Fees[I].FeeType)));
        end;                          
      end;
      if FPosition = nil then
      begin
        SL.Add('0');
      end
      else
      begin
        SL.Add(IntToStr(FPosition.CurrentOffice));
        SL.Add(IntToStr(FPosition.NextOffice   ));
        SL.Add(IntToStr(FPosition.When         ));
        SL.Add(IntToStr(FPosition.Dispatched   ));
      end;
      if (Details = nil) or (Details.IsEmpty) then
      begin
        SL.Add('0');
      end
      else
      begin
        SL.Add('1');
        if Details.Sender <> nil then
           SL.Add(Details.Sender.AsString)
        else
           SL.Add('');
        if Details.Recipient <> nil then
           SL.Add(Details.Recipient.AsString)
        else
           SL.Add('');
        SL.Add(Details.Info);
      end;
      Result:=SL.PackText;
      SL.Free;
      Exit;
   end;
   SS:=TStringStream.Create('');
   I32 :=((Trunc(FValue) and $FFFFFFF) shl 3) or (Integer(MOType) and 7);
   WriteInt(I32,SS);
   I32:=((StrToInt(FSerial) and $FFFFFF) shl 7) or (FIssueClerk and $7F);
   WriteInt(I32,SS);
   I32:=((PackDate(PeriodToDate(FIssuePeriod)) and $7FF) shl 20)  
      or ((IndexFromOffice(FIssueOffice) and $3FF) shl 10) 
      or  (IndexFromOffice(FPayOffice) and $3FF);
   WriteInt(I32,SS);
   I32:=((FPayPeriod and $FFFF) shl 16) or (FPayClerk and $FFFF);
   WriteInt(I32,SS);
   if Events <> nil then
   begin
      WriteInt(Events.Count,SS);
      for I:=0 to Events.Count-1 do
      begin
         WriteInt(Events[I].FEvType ,SS);
         WriteInt(Events[I].FEvWho  ,SS);
         WriteInt(Events[I].FEvWhen ,SS);
         WriteInt(Events[I].FEvWhere,SS);
      end;                          
   end
   else
      WriteInt(0,SS);
      
   if FPosition <> nil then
   begin
      WriteInt(1,SS);
      WriteInt(FPosition.CurrentOffice,SS);
      WriteInt(FPosition.NextOffice   ,SS);
      WriteInt(FPosition.When         ,SS);
      WriteInt(FPosition.Dispatched   ,SS);
   end
   else
      WriteInt(0,SS);

   if Fees <> nil then
   begin
      WriteInt(Fees.Count,SS);
      for I:=0 to Fees.Count-1 do
      begin
         WriteInt(Trunc(Fees[I].Value),SS);
         WriteInt(Integer(Fees[I].FeeType),SS);
      end;
   end
   else
      WriteInt(0,SS);
   if (Details <> nil) and (not Details.IsEmpty) then
   begin
      WriteInt(1,SS);
      if Details.Sender <> nil then
         WriteStr(Details.Sender.AsString,SS)
      else
         WriteStr('',SS);
      if Details.Recipient <> nil then
         WriteStr(Details.Recipient.AsString,SS)
      else
         WriteStr('',SS);
      WriteStr(Details.Info,SS);
   end
   else
      WriteInt(0,SS);
   Result:=SS.DataString;
   SS.Free;
end;
procedure TMoneyOrder.SetPackedString(Value:String);
var
   I:Integer;
   I32:Integer;
   Count:Integer;
   S:String;
   SL:TPackStringList;
   SS:TStringStream;
   Event:TMOEvent;
   Fee:TMOFee;
   Pos:Integer;
begin
   if StringsInPack then
   begin
      SL:=TPackStringList.Create;
      SL.PackText:=Value;
      Pos:=0;
      if SL.Count > Pos then Series:=SL[Pos]; Inc(Pos);
      if SL.Count > Pos then FPayPeriod:=StrToIntDef(SL[Pos],0); Inc(Pos);
      if SL.Count > Pos then FPayClerk :=StrToIntDef(SL[Pos],0); Inc(Pos);
      
      if SL.Count > Pos then Count     :=StrToIntDef(SL[Pos],0) else Count:=0; Inc(Pos);
      if Count > 0 then
      begin
         Events:=TMOEvents.Create;
         for I:=0 to Count-1 do
         begin
            Event:=TMOEvent.Create;
            if SL.Count > Pos then Event.FEvType :=StrToIntDef(SL[Pos],0); Inc(Pos);
            if SL.Count > Pos then Event.FEvWho  :=StrToIntDef(SL[Pos],0); Inc(Pos);
            if SL.Count > Pos then Event.FEvWhen :=StrToIntDef(SL[Pos],0); Inc(Pos);
            if SL.Count > Pos then Event.FEvWhere:=StrToIntDef(SL[Pos],0); Inc(Pos);
            Events.Add(Event);
         end;
      end;
      if SL.Count > Pos then Count     :=StrToIntDef(SL[Pos],0) else Count:=0; Inc(Pos);
      if Count > 0 then
      begin
         Fees:=TMOFees.Create;
         for I:=0 to Count-1 do
         begin
            Fee:=TMOFee.Create;
            if SL.Count > Pos then Fee.Value  :=StrToCurrDef(SL[Pos],0); Inc(Pos);
            if SL.Count > Pos then Fee.FeeType:=TMOFeeType(StrToIntDef (SL[Pos],0)); Inc(Pos);
            Fees.Add(Fee);
         end;
      end;
      if SL.Count > Pos then Count     :=StrToIntDef(SL[Pos],0) else Count:=0; 
      // Inc(Pos);
      // error in original encode, count is CurrentOffice  or 0
      if Count > 0 then
      begin
         Position:=TMOPosition.Create;
         if SL.Count > Pos then Position.CurrentOffice:=StrToIntDef (SL[Pos],0); Inc(Pos);
         if SL.Count > Pos then Position.NextOffice   :=StrToIntDef (SL[Pos],0); Inc(Pos);
         if SL.Count > Pos then Position.When         :=StrToIntDef (SL[Pos],0); Inc(Pos);
         if SL.Count > Pos then Position.Dispatched   :=StrToIntDef (SL[Pos],0); Inc(Pos);
      end
      else
         Inc(Pos);
      if SL.Count > Pos then Count     :=StrToIntDef(SL[Pos],0) else Count:=0; Inc(Pos);
      if Count > 0 then    
      begin
         Details:=TMODetail.Create;
//         if SL.Count > Pos then Count     :=StrToIntDef(SL[Pos],0) else Count:=0; Inc(Pos);
//         if Count > 0 then
         if SL.Count > Pos then 
         begin
            Details.Sender:=TPerson.Create;
            Details.Sender.AsString:=SL[Pos];
            Inc(Pos);
         end;
//         if SL.Count > Pos then Count     :=StrToIntDef(SL[Pos],0) else Count:=0; Inc(Pos);
//         if Count > 0 then
         if SL.Count > Pos then 
         begin
            Details.Recipient:=TPerson.Create;
            Details.Recipient.AsString:=SL[Pos];
            Inc(Pos);
         end;
         if SL.Count > Pos then 
            Details.Info:=SL[Pos];
      end;
      SL.Free;
      Exit;
   end;

   SS:=TStringStream.Create(Value);
   I32:=ReadInt(SS);
   FValue:=(I32 shr 3) and $FFFFFFF;
   FMOType:=TMOType(I32 and 7);

   I32:=ReadInt(SS);
   FSerial:=IntToStr((I32 shr 7) and $FFFFFF);
   FIssueClerk:=I32 and $7F;
   
   I32:=ReadInt(SS);
   FIssuePeriod:=DateToPeriod(UnPackDate((I32 shr 20) and $7FF));
   FIssueOffice:=OfficeFromIndex((I32 shr 10)and $3FF);
   FPayOffice:=OfficeFromIndex(I32 and $3FF);
   
   I32:=ReadInt(SS);
   FPayPeriod:=(I32 shr 16)and $FFFF;
   FPayClerk:=I32 and $FFFF;
   Series:=EncodeMoneyOrder(FSerial,FValue,FIssueOffice,FPayOffice,FIssueClerk,FMOType,PeriodToDate(FIssuePeriod),False);
   I32:=ReadInt(SS);
   if I32 <> 0 then
   begin
      Events:=TMOEvents.Create;
      for I:=0 to I32-1 do
      begin
         Event:=TMOEvent.Create;
         Event.EvType :=ReadInt(SS);
         Event.EvWho  :=ReadInt(SS);
         Event.EvWhen :=ReadInt(SS);
         Event.EvWhere:=ReadInt(SS);
         Events.Add(Event);
      end;
   end
   else
      Events:=nil;
      
   I32:=ReadInt(SS);
   if I32 <> 0 then
   begin
      Position:=TMOPosition.Create;
      Position.CurrentOffice:=ReadInt(SS);
      Position.NextOffice   :=ReadInt(SS);
      Position.When         :=ReadInt(SS);
      Position.Dispatched   :=ReadInt(SS);
   end
   else
      Position:=nil;
      
   I32:=ReadInt(SS);
   if I32 <> 0 then
   begin
      Fees:=TMOFees.Create;
      for I:=0 to I32-1 do
      begin
         Fee:=TMOFee.Create;
         Fee.Value  :=ReadInt(SS);
         Fee.FeeType:=TMOFeeType(ReadInt(SS));
         Fees.Add(Fee);
      end;
   end
   else
      Fees:=nil;
      
   I32:=ReadInt(SS);
   if I32 <> 0 then
   begin
      Details:=TMODetail.Create;
      S:=ReadStr(SS);
      if S <> '' then
      begin
         Details.Sender:=TPerson.Create;
         Details.Sender.AsString:=S;
      end
      else
         Details.Sender:=nil;
      S:=ReadStr(SS);
      if S <> '' then
      begin
         Details.Recipient:=TPerson.Create;
         Details.Recipient.AsString:=S;
      end
      else
         Details.Recipient:=nil;
      Details.Info:=ReadStr(SS);
   end
   else
      Details:=nil;
   SS.Free;
end;
procedure TMoneyOrder.RemFromList(ThisOffice:Integer);
//var
//   SL:TStringList;
//   FileName:String;
//   I:Integer;
begin
//   if ThisOffice = 0 then
//      ThisOffice:=StrToIntDef(GetGPCSRegString('OfficeInfo','Office ID','0'),0);
//   if ThisOffice <> PayOffice then Exit;
//   FileName:=GetGPCSRegString(SystemType,'Local List File','');
//   if FileName = '' then Exit;
//   SL:=TStringList.Create;
//   if FileExists(FileName) then
//   begin
//      SL.LoadFromFile(FileName);
//      I:=SL.IndexOf(Series);
//      if I <> -1 then
//      begin
//         SL.Delete(I);
//         SL.SaveToFile(FileName);
//      end;
//   end;
//   SL.Free;
end;                
procedure TMoneyOrder.ReplaceList(PackList:String);
//var
//   SL:TPackStringList;
//   FileName:String;
begin
//   FileName:=GetGPCSRegString(SystemType,'Local List File','');
//   if FileName = '' then Exit;
//   SL:=TPackStringList.Create;
//   SL.PackText:=PackList;
//   SL.SaveToFile(FileName);
//   SL.Free;
end;                
procedure TMoneyOrder.SaveToList(ThisOffice:Integer);
//var
//   SL:TStringList;
//   FileName:String;
begin
//   if ThisOffice = 0 then
//      ThisOffice:=StrToIntDef(GetGPCSRegString('OfficeInfo','Office ID','0'),0);
//   if ThisOffice <> PayOffice then Exit;
//   FileName:=GetGPCSRegString(SystemType,'Local List File','');
//   if FileName = '' then Exit;
//   SL:=TStringList.Create;
//   if FileExists(FileName) then
//      SL.LoadFromFile(FileName);
//   SL.Add(Series);
//   SL.SaveToFile(FileName);
//   SL.Free;
end;
function FormatMOStr(SerialNo:String;Value:Currency;Office:String):String;
begin
   Result:='No. '+SerialNo+' for '+CurrToStrF(Value,ffNumber,2)+' from '+Office;
end;
function TMoneyOrder.FindInList(Value:String):String;
var
   SL:TPackStringList;
   TmpMO:TMoneyOrder;
   I:Integer;
   FileStatusMon:TFileStatusMon;
   OName:String;
begin  
   Result:='';
   SL:=TPackStringList.Create;                              
   TmpMO:=TMoneyOrder.Create;
   FileStatusMon:=TFileStatusMon.Create(nil);
//   SL.PackText:=FileStatusMon.MoneyOrderPayList(0,0);
   SL.PackText:=RequestServiceData('MoneyOrderPayList','0');
   for I:=0 to SL.Count-1 do
   begin
      TmpMO.Series:=SL[I];
//      if TmpMO.MOType = MOType then
      begin
         OName:=FileStatusMon.OfficeNameFromCode(TmpMO.IssueOffice);
         if Value = FormatMOStr(TmpMO.Serial,TmpMO.Value,OName) then
         begin
            Result:=SL[I];
            break;
         end;
      end;
   end;
   FileStatusMon.Free;
   TmpMO.Free;
   SL.Free;
end;

function TMoneyOrder.ListFileContents(SerialNo:String;MOTypes:Integer):String;
var
   SL:TPackStringList;
   TmpMO:TMoneyOrder;
   I:Integer;
   FileStatusMon:TFileStatusMon;
   OName:String;
const
   OfficeCode:Integer=0;
begin  
   if OfficeCode = 0 then
      OfficeCode:=StrToIntDef(GetGPCSRegString('OfficeInfo','Office ID','0'),0);
   Result:='';
   SL:=TPackStringList.Create;                              
   TmpMO:=TMoneyOrder.Create;
   I:=0;
   FileStatusMon:=TFileStatusMon.Create(nil);
   SL.PackText:=RequestServiceData('MoneyOrderPayList',IntToStr(MoTypes));
//   SL.PackText:=FileStatusMon.MoneyOrderPayList(OfficeCode,MoTypes);
   while I < SL.Count do
   begin
      TmpMO.Series:=SL[I];
//      if TmpMO.MOType = MOType then
//      begin
         OName:=FileStatusMon.OfficeNameFromCode(TmpMO.IssueOffice);
         if SerialNo <> '' then
         begin
            if SerialNo  = TmpMO.Serial then
            begin
               SL[I]:=FormatMOStr(TmpMO.Serial,TmpMO.Value,OName);
               Inc(I);
            end
            else
            begin
               SL.Delete(I);
            end;
         end    
         else
         begin
            SL[I]:=FormatMOStr(TmpMO.Serial,TmpMO.Value,OName);
            Inc(I);
         end;
//      end
//      else
//      begin
//         SL.Delete(I);
//      end;
   end;
   FileStatusMon.Free;
   TmpMO.Free;
   Result:=SL.CommaText;
   SL.Free;
end;

{TMoneyOrders}
destructor TMoneyOrders.Destroy;
begin
   While Count > 0 do
   begin
      if GetMoneyOrder(0) <> nil then 
         GetMoneyOrder(0).Free;
      Delete(0);
   end;
   inherited Destroy;
end;
function TMoneyOrders.GetMoneyOrder(Index:Integer):TMoneyOrder;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=Get(Index)
   else
      Result:=nil;
end;
procedure TMoneyOrders.CheckIndex(Alias:String);
var
   MOTable:TTable;
   IndexDef:TIndexDef;
begin
   MOTable:=TTable.Create(nil);
   MOTable.DatabaseName:=Alias;
   with MOTable do
   begin
      TableName:='MONEYORDER';
      IndexDefs.Update;  
      IndexDef:=nil;
      try
         IndexDef:=IndexDefs.FindIndexForFields('MOSERIES');
      except
         on E:Exception do
            RaiseGUIDException('{FB85195F-FF62-4ABD-9937-ADC2724CAC84}',E);
      end;
      if ((IndexDef <> nil) and (UpperCase(IndexDef.Fields) <> 'MOSERIES')) or
         (IndexDef = nil)  then
         AddIndex('PriIdx', 'MOSERIES', [ixPrimary, ixUnique]);
        
      TableName:='MOPOSITION';
      IndexDefs.Update;  
      IndexDef:=nil;
      try
         IndexDef:=IndexDefs.FindIndexForFields('MOSERIES');
      except
         on E:Exception do
            RaiseGUIDException('{FB85195F-FF62-4ABD-9937-ADC2724CAC84}',E);
      end;
      if ((IndexDef <> nil) and (UpperCase(IndexDef.Fields) <> 'MOSERIES')) or
         (IndexDef = nil)  then
         AddIndex('PriIdx', 'MOSERIES', [ixPrimary, ixUnique]);
        
      TableName:='MOFEE';
      IndexDefs.Update;  
      IndexDef:=nil;
      try
         IndexDef:=IndexDefs.FindIndexForFields('MOSERIES;MOFEETYPE');
      except
         on E:Exception do
            RaiseGUIDException('{FB85195F-FF62-4ABD-9937-ADC2724CAC84}',E);
      end;
      if ((IndexDef <> nil) and (UpperCase(IndexDef.Fields) <> 'MOSERIES;MOFEETYPE')) or
         (IndexDef = nil)  then
         AddIndex('PriIdx', 'MOSERIES;MOFEETYPE', [ixPrimary, ixUnique]);
        
      TableName:='MODETAIL';
      IndexDefs.Update;  
      IndexDef:=nil;
      try
         IndexDef:=IndexDefs.FindIndexForFields('MOSERIES');
      except
         on E:Exception do
            RaiseGUIDException('{FB85195F-FF62-4ABD-9937-ADC2724CAC84}',E);
      end;
      if ((IndexDef <> nil) and (UpperCase(IndexDef.Fields) <> 'MOSERIES')) or
         (IndexDef = nil)  then
         AddIndex('PriIdx', 'MOSERIES', [ixPrimary, ixUnique]);
        
      TableName:='MOEVENT';
      IndexDefs.Update;  
      IndexDef:=nil;
      try
         IndexDef:=IndexDefs.FindIndexForFields('MOSERIES;MOEVTYPE;MOEVWHERE;MOEVWHEN');
      except
         on E:Exception do
            RaiseGUIDException('{FB85195F-FF62-4ABD-9937-ADC2724CAC84}',E);
      end;
      if ((IndexDef <> nil) and (UpperCase(IndexDef.Fields) <> 'MOSERIES;MOEVTYPE;MOEVWHERE;MOEVWHEN')) or
         (IndexDef = nil)  then
         AddIndex('PriIdx', 'MOSERIES;MOEVTYPE;MOEVWHERE;MOEVWHEN', [ixPrimary, ixUnique]);
   end;
end;
function TMoneyOrders.CheckTables(Alias:String):Boolean;
begin
   Result:=True;
   if GetGPCSRegString('WorkStation','DBType','') = 'SQLServer' then
   begin
      with TQuery.Create(nil) do
      begin
         DatabaseName:=Alias;

         SQL.Text:='DROP TABLE MOISSUE';        try ExecSQL; except end;
         SQL.Text:='DROP TABLE MOPAID';         try ExecSQL; except end;
         SQL.Text:='DROP TABLE MOSTATUS';       try ExecSQL; except end;
         SQL.Text:='DROP TABLE MOSTATUSCHANGE'; try ExecSQL; except end;

         SQL.Text:='DROP TABLE MODETAIL'; try ExecSQL; except end;
         SQL.Text:='CREATE TABLE MODETAIL ('+
                   '  MOSERIES CHAR(20) NOT NULL,  '+
                   '  MOSENDER TEXT ,              '+
                   '  MOPAYEE TEXT ,               '+
                   '  MOINFO TEXT ,                '+
                   ' CONSTRAINT MODETAIL_PINDEX PRIMARY KEY(MOSERIES));';
         try
            ExecSQL;
         except
            On E : Exception do
            begin
              RaiseGUIDException('{E188CB81-B82E-4419-A28B-51C09370786A}',E);
            end;
         end;
         SQL.Text:='DROP TABLE MOEVENT'; try ExecSQL; except end;
         SQL.Text:='CREATE TABLE MOEVENT ('+
                   '  MOSERIES CHAR(20) NOT NULL, '+
                   '  MOEVTYPE INT ,              '+
                   '  MOEVWHERE INT ,             '+
                   '  MOEVWHEN INT ,                '+
                   '  MOEVWHO INT ,               '+
                   ' CONSTRAINT MOEVENT_PINDEX PRIMARY KEY(MOSERIES,MOEVTYPE,MOEVWHERE,MOEVWHEN));';
         try
            ExecSQL;
         except
            On E : Exception do
            begin
              RaiseGUIDException('{577109DF-BD59-47E7-8056-78386E8B274D}',E);
            end;
         end;

         SQL.Text:='DROP TABLE MOFEE'; try ExecSQL; except end;
         SQL.Text:='CREATE TABLE MOFEE ( '+
                   '  MOSERIES CHAR(20) NOT NULL,'+
                   '  MOFEETYPE INT,             '+
                   '  MOFEEVALUE FLOAT           '+
                   ' CONSTRAINT MOFEE_PINDEX PRIMARY KEY(MOSERIES,MOFEETYPE));';
         try
            ExecSQL;
         except
            On E : Exception do
            begin
              RaiseGUIDException('{898474F0-689E-4459-866B-133DC2A11C47}',E);
            end;
         end;

         SQL.Text:='DROP TABLE MONEYORDER'; try ExecSQL; except end;
         SQL.Text:='CREATE TABLE MONEYORDER ('+
                   '  MOSERIES CHAR(20) NOT NULL,    '+
                   '  MOSERIAL CHAR(7) ,             '+
                   '  MOVALUE FLOAT ,                '+
                   '  MOISSUEPERIOD INT ,            '+
                   '  MOISSUEOFFICE INT ,            '+
                   '  MOISSUECLERK INT ,             '+
                   '  MOPAYOFFICE INT ,              '+
                   '  MOTYPE INT ,                   '+
                   '  MOPAYPERIOD INT ,              '+
                   '  MOPAYCLERK INT                 '+
                   ' CONSTRAINT MONEYORDER_PINDEX PRIMARY KEY(MOSERIES));';
         try
            ExecSQL;
         except
            On E : Exception do
            begin
              RaiseGUIDException('{E55B5CEB-1B27-4AF4-94FA-1214B2AB675E}',E);
            end;
         end;


         SQL.Text:='DROP TABLE MOPOSITION'; try ExecSQL; except end;
         SQL.Text:='CREATE TABLE MOPOSITION ('+
                   '  MOSERIES CHAR(20) NOT NULL,    '+
                   '  MOCURRENTOFFICE INT ,          '+
                   '  MONEXTOFFICE INT ,             '+
                   '  MOWHEN INT ,                   '+
                   '  MODISPATCHED INT               '+
                   ' CONSTRAINT MOPOSITION_PINDEX PRIMARY KEY(MOSERIES,MOCURRENTOFFICE,MOWHEN));';
         try
            ExecSQL;
         except
            On E : Exception do
            begin
              RaiseGUIDException('{9E653337-87C1-44C6-AE89-DFEF7D828AE4}',E);
            end;
         end;
         Free;
      end;
      Exit;
   end;

   try
      with TTable.Create(nil) do
      begin
        Active:=False;
        DatabaseName:=Alias;
        TableName:='MONEYORDER';
        with FieldDefs do
        begin
           Clear; // clear the current field definitions
           Add('MOSERIES'        ,ftString  , 20,True );
           Add('MOSERIAL'        ,ftString  ,  7,True );
           Add('MOVALUE'         ,ftCurrency,  0,True );
           Add('MOISSUEPERIOD'   ,ftInteger ,  0,True );
           Add('MOISSUEOFFICE'   ,ftInteger ,  0,True );
           Add('MOISSUECLERK'    ,ftInteger ,  0,True );
           Add('MOPAYOFFICE'     ,ftInteger ,  0,True );
           Add('MOTYPE'          ,ftInteger ,  0,True );
           Add('MOPAYPERIOD'     ,ftInteger ,  0,False);
           Add('MOPAYCLERK'      ,ftInteger ,  0,False);
        end;

        with IndexDefs do // create the index
        begin
           Clear;
           Add('','MOSERIES',[ixPrimary,ixUnique]);
        end;
        CreateTable;
        Free;
      end;
      with TTable.Create(nil) do
      begin
        Active:=False;
        DatabaseName:=Alias;
        TableName:='MOPOSITION';
        with FieldDefs do
        begin
           Clear; // clear the current field definitions
           Add('MOSERIES'       ,ftString  , 20,True );
           Add('MOCURRENTOFFICE',ftInteger ,  0,True );
           Add('MONEXTOFFICE'   ,ftInteger ,  0,True );
           Add('MOWHEN'         ,ftInteger ,  0,True );
           Add('MODISPATCHED'   ,ftInteger ,  0,True );
        end;

        with IndexDefs do // create the index
        begin
           Clear;
           Add('','MOSERIES',[ixPrimary,ixUnique]);
        end;
        CreateTable;
        Free;
      end;
      with TTable.Create(nil) do
      begin
        Active:=False;
        DatabaseName:=Alias;
        TableName:='MODETAIL';
        with FieldDefs do
        begin
           Clear; // clear the current field definitions
           Add('MOSERIES',ftString, 20,True );
           Add('MOSENDER',ftMemo  ,240,False);
           Add('MOPAYEE' ,ftMemo  ,240,False);
           Add('MOINFO'  ,ftMemo  ,240,False);
        end;

        with IndexDefs do // create the index
        begin
           Clear;
           Add('','MOSERIES',[ixPrimary,ixUnique]);
        end;
        CreateTable;
        Free;
      end;
      with TTable.Create(nil) do
      begin
        Active:=False;
        DatabaseName:=Alias;
        TableName:='MOFEE';
        with FieldDefs do
        begin
           Clear; // clear the current field definitions
           Add('MOSERIES'  ,ftString  , 20,True );
           Add('MOFEETYPE' ,ftInteger ,  0,True );
           Add('MOFEEVALUE',ftCurrency,  0,False);
        end;
        with IndexDefs do // create the index
        begin
           Clear;
           Add('','MOSERIES;MOFEETYPE',[ixPrimary,ixUnique]);
        end;
        CreateTable;
        Free;
      end;
      with TTable.Create(nil) do
      begin
        Active:=False;
        DatabaseName:=Alias;
        TableName:='MOEVENT';
        with FieldDefs do
        begin
           Clear; // clear the current field definitions
           Add('MOSERIES' ,ftString  , 20,True );
           Add('MOEVTYPE' ,ftInteger ,  0,True );
           Add('MOEVWHERE',ftInteger ,  0,True );
           Add('MOEVWHEN' ,ftInteger ,  0,True );
           Add('MOEVWHO'  ,ftInteger ,  0,False);
        end;
        with IndexDefs do // create the index
        begin
           Clear;
           Add('','MOSERIES;MOEVTYPE;MOEVWHERE;MOEVWHEN',[ixPrimary,ixUnique]);
        end;
        CreateTable;
        Free;
      end;
   except
      on E:Exception do
      begin
         RaiseGUIDException('{DAFCB4D3-097D-43D0-96D4-4E27FB599C68}',E);
         Result:=False;
      end;
   end;
end;
procedure TMoneyOrders.AddFromQuery(Alias,SQL:String);
var
   Query:TQuery;
   MO:TMoneyOrder;
begin
   Query:=TQuery.Create(nil);
   Query.DatabaseName:=Alias;
   Query.SQL.Text:=SQL;
   try
      Query.Active:=True;
      while not Query.EOF do
      begin
         MO:=TMoneyOrder.Create;
         MO.Series   :=Query.FieldByName('MOSERIES'   ).AsString;
         MO.PayPeriod:=Query.FieldByName('MOPAYPERIOD').Value;
         MO.PayClerk :=Query.FieldByName('MOPAYCLERK' ).Value;
         MO.Fees    :=MO.LoadFees    (Alias,MO.Series);
         MO.Events  :=MO.LoadEvents  (Alias,MO.Series);
         MO.Details :=MO.LoadDetails (Alias,MO.Series);
         MO.Position:=MO.LoadPosition(Alias,MO.Series);
         Add(MO);
         Query.Next;
      end;
      Query.Active:=False;
   except
      on E:Exception do RaiseGUIDException('{BA01D3BA-D68A-4DAB-B8B7-07C6D43EB5BD}',E);
   end;
   Query.Free;
end;
function TMoneyOrder.LoadFees(Alias,Series:String):TMOFees;
var
   Query:TQuery;
   MOFee:TMOFee;
begin
   Result:=nil;
   Query:=TQuery.Create(nil);
   try
      Query.DatabaseName:=Alias;
      Query.SQL.Text:='Select * from MOFEE where MOSERIES = '''+Series+'''';
      Query.Active:=True;
      if not Query.EOF then
      begin
         Result:=TMOFees.Create;
         while not Query.EOF do
         begin
            MOFee:=TMOFee.Create;
            MOFee.FeeType:=Query.FieldByName('MOFEETYPE' ).Value;
            MOFee.Value  :=Query.FieldByName('MOFEEVALUE').Value;
            Result.Add(MOFee);
            Query.Next;
         end;
      end;
      Query.Active:=False;
   except
      on E:Exception do RaiseGUIDException('{990AED1F-0894-4C7F-94DB-558C63C7725D}',E);
   end;
   Query.Free;
end;
function TMoneyOrder.LoadEvents(Alias,Series:String):TMOEvents;
var
   Query:TQuery;
   MOEvent:TMOEvent;
begin
   Result:=nil;
   Query:=TQuery.Create(nil);
   try
      Query.DatabaseName:=Alias;
      Query.SQL.Text:='Select * from MOEVENT where MOSERIES = '''+Series+'''';
      Query.Active:=True;
      if not Query.EOF then
      begin
         Result:=TMOEvents.Create;
         while not Query.EOF do
         begin
            MOEvent:=TMOEvent.Create;
            MOEvent.EvType :=Query.FieldByName('MOEVTYPE' ).Value;
            MOEvent.EvWho  :=Query.FieldByName('MOEVWHO'  ).Value;
            MOEvent.EvWhen :=Query.FieldByName('MOEVWHEN' ).Value;
            MOEvent.EvWhere:=Query.FieldByName('MOEVWHERE').Value;
            Result.Add(MOEvent);
            Query.Next;
         end;
      end;
      Query.Active:=False;
   except
      on E:Exception do RaiseGUIDException('{80F4422D-3C10-4882-AB28-BB83F8A2BEDC}',E);
   end;
   Query.Free;
end;
function TMoneyOrder.LoadDetails(Alias,Series:String):TMODetail;
var
   Query:TQuery;
   S:String;
begin
   Result:=nil;
   Query:=TQuery.Create(nil);
   try
      Query.DatabaseName:=Alias;
      Query.SQL.Text:='Select * from MODETAIL where MOSERIES = '''+Series+'''';
      Query.Active:=True;
      if not Query.EOF then
      begin
         Result:=TMODetail.Create;
         S:=Query.FieldByName('MOSENDER').AsString;
         if S <> '' then
         begin
            Result.Sender:=TPerson.Create;
            Result.Sender.AsString:=S;
         end;
         S:=Query.FieldByName('MOPAYEE' ).AsString;
         if S <> '' then
         begin
            Result.Recipient:=TPerson.Create;
            Result.Recipient.AsString:=S;
         end;
         Result.Info              :=Query.FieldByName('MOINFO'  ).AsString;
      end;
      Query.Active:=False;
   except
      on E:Exception do RaiseGUIDException('{97738874-5D7E-4240-B4DF-2406E6DC78E2}',E);
   end;
   Query.Free;
end;
function TMoneyOrder.LoadPosition(Alias,Series:String):TMOPosition;
var
   Query:TQuery;
begin
   Result:=nil;
   Query:=TQuery.Create(nil);
   try
      Query.DatabaseName:=Alias;
      Query.SQL.Text:='Select * from MOPOSITION where MOSERIES = '''+Series+'''';
      Query.Active:=True;
      if not Query.EOF then
      begin
         Result:=TMOPosition.Create;
         Result.CurrentOffice:=Query.FieldByName('MOCURRENTOFFICE').Value;
         Result.NextOffice   :=Query.FieldByName('MONEXTOFFICE'   ).Value;
         Result.When         :=Query.FieldByName('MOWHEN'         ).Value;
         Result.Dispatched   :=Query.FieldByName('MODISPATCHED'   ).Value;
      end;
      Query.Active:=False;
   except
      on E:Exception do RaiseGUIDException('{DCFB8580-64B0-44D1-B4A5-A840CF54B309}',E);
   end;
   Query.Free;
end;
procedure TMoneyOrders.FillFromQuery(Alias,SQL:String);
var
   I:Integer;
begin
   for I:=0 to Count-1 do
      if GetMoneyOrder(I) <> nil then 
         GetMoneyOrder(I).Free;
   Clear;
   AddFromQuery(Alias,SQL);
end;
function TMoneyOrders.PrepareDispatches(Alias:String):String;
var
   Query:TQuery;
begin
   Query:=TQuery.Create(nil);
   Query.DatabaseName:=Alias;
   Query.SQL.Text:='Update MOPOSITION Set MOWHEN = '+IntToStr(TodayAsPeriod)+' where MODISPATCHED = 0';
   Query.ExecSQL;
   Query.Free;
end;
function TMoneyOrders.GetDispatchOffices(Alias:String):String;
var
   SQLText:String;
begin            
   PrepareDispatches(Alias);
   SQLText:='Select Distinct(MONEXTOFFICE) from MOPOSITION where MOWHEN = '+IntToStr(TodayAsPeriod);
   Result:=QueryToPackText(SQLText);
end;
function TMoneyOrders.GetDispatchItemCount(Alias:String):Integer;
var
   SQLText:String;
   SL:TPackStringList;
begin            
   Result:=0;
   PrepareDispatches(Alias);
   SL:=TPackStringList.Create;
   SQLText:='Select Count(MONEXTOFFICE) from MOPOSITION where MOWHEN = '+IntToStr(TodayAsPeriod);
   SL.PackText:=QueryToPackText(SQLText);
   if SL.Count > 0 then
   begin
      SL.PackText:=SL[0];
      if SL.Count > 0 then
         Result:=StrToIntdef(SL[0],0);
   end;                  
   SL.Free;
end;
function TMoneyOrders.MarkDispatch(Alias:String;ToOfficeCode:Integer):String;
var
   Query:TQuery;
   SQLText:String;
begin
   Query:=TQuery.Create(nil);
   Query.DatabaseName:=Alias;
   Query.SQL.Text:='Update MOPOSITION Set MODISPATCHED = 1 where MONEXTOFFICE = '+IntToStr(ToOfficeCode);
   Query.ExecSQL;
   Query.Free;
   SQLText:='Select MOSERIES from MOPOSITION where MODISPATCHED = 1 and MOWHEN = '+IntToStr(TodayAsPeriod)+' and MONEXTOFFICE = '+IntToStr(ToOfficeCode);
   Result:=QueryToPackText(SQLText);
end;
      
end.
