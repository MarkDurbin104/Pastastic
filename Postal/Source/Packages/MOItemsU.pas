//==============================================================================
//  Type          | Unit
//  Name          | MOItemsU
//  Description   | Support Classes for each of the Money order tables
//                | so that data from those table may be passed over an
//                | Ole interface as Variant Arrays
//------------------------------------------------------------------------------
// Date     | Who | Comments
//------------------------------------------------------------------------------
// 26/01/01 | MJD | Initial Release
//==============================================================================

unit MOItemsU;

interface

uses
   Classes,DBTables,TxDataU,PackStrListU;

const
   DBPass = 'INDIGOTHREEMO';

type
  // base class for Money order item
  TMOItem = class(TTxData)
  private
     FIdentifier:       String   ;
     FIssueNumber:      Integer  ;
     FDateTime:         TDateTime;
  public
     procedure LoadFromRecord(DataSet:TDBDataSet); virtual;
  published
     property Identifier       :String    read FIdentifier        write FIdentifier       ;
     property IssueNumber      :Integer   read FIssueNumber       write FIssueNumber      ;
     property DateTime         :TDateTime read FDateTime          write FDateTime         ;
  end;
  TMOItemClass = class of TMOItem;
  // List of Money order items
  TMOItemList = class(TTxListData)
  public
     constructor Create(AOwner:TComponent); override;
     function IndexOf(MOItem:TMOItem):Integer;
     procedure LoadFromDataSet(DataSet:TDBDataSet;ClassType:TMOItemClass);
     procedure LoadFromQuery(Alias,SQL:String;ClassType:TMOItemClass);
  end;
  // Issued Money order item
  TMOIssued = class(TMOItem)
  private
     FValue:            Currency ;
     FCommission:       Currency ;
     FTax:              Currency ;
     FSSIndicator:      String   ;
     FSSFee:            Currency ;
     FIssuingOffice:    Integer  ;
     FIssuingClerk:     Integer  ;
     FPayingOffice:     Integer  ;
     FPayByDateTime:    TDateTime;
     FRContact1        :String   ;
     FRContact2        :String   ;
     FSendersName:      String   ;
     FSendersAddress:   String   ;
     FRecipientsName:   String   ;
     FRecipientsAddress:String   ;
     FInformation      :String   ;
  public
     procedure LoadFromRecord(DataSet:TDBDataSet); override;
  published
     property Value            :Currency  read FValue             write FValue            ;
     property Commission       :Currency  read FCommission        write FCommission       ;
     property Tax              :Currency  read FTax               write FTax              ;
     property SSIndicator      :String    read FSSIndicator       write FSSIndicator      ;
     property SSFee            :Currency  read FSSFee             write FSSFee            ;
     property IssuingOffice    :Integer   read FIssuingOffice     write FIssuingOffice    ;
     property IssuingClerk     :Integer   read FIssuingClerk      write FIssuingClerk     ;
     property PayingOffice     :Integer   read FPayingOffice      write FPayingOffice     ;
     property PayByDateTime    :TDateTime read FPayByDateTime     write FPayByDateTime    ;
     property SendersName      :String    read FSendersName       write FSendersName      ;
     property SendersAddress   :String    read FSendersAddress    write FSendersAddress   ;
     property RContact1        :String    read FRContact1         write FRContact1        ;
     property RContact2        :String    read FRContact2         write FRContact2        ;
     property RecipientsName   :String    read FRecipientsName    write FRecipientsName   ;
     property RecipientsAddress:String    read FRecipientsAddress write FRecipientsAddress;
     property Information      :String    read FInformation       write FInformation      ;
  end;
  // Paid Money order item
  TMOPaid = class(TMOItem)
  private
     FCommission     :Currency ;
     FPaidOffice     :Integer  ;
     FPaidClerk      :Integer  ;
     FInformation    :String   ;
     FForcePayDetails:String   ;
  public
     procedure LoadFromRecord(DataSet:TDBDataSet); override;
  published
     property Commission     :Currency  read FCommission      write FCommission     ;
     property PaidOffice     :Integer   read FPaidOffice      write FPaidOffice     ;
     property PaidClerk      :Integer   read FPaidClerk       write FPaidClerk      ;
     property Information    :String    read FInformation     write FInformation    ;
     property ForcePayDetails:String    read FForcePayDetails write FForcePayDetails;
  end;
  // Money order item Status
  TMOStatus = class(TMOItem)
  private
     FStatusValue:Integer  ;
  public
     procedure LoadFromRecord(DataSet:TDBDataSet); override;
  published
     property StatusValue:Integer   read FStatusValue write FStatusValue;
  end;
  // Money order item Error
  TMOError = class(TMOItem)
  private
     FStatusFrom :Integer  ;
     FStatusTo   :Integer  ;
     FReason     :String   ;
  public
     procedure LoadFromRecord(DataSet:TDBDataSet); override;
  published
     property StatusFrom :Integer   read FStatusFrom  write FStatusFrom ;
     property StatusTo   :Integer   read FStatusTo    write FStatusTo   ;
     property Reason     :String    read FReason      write FReason     ;
  end;
  // Personal details i.e. name and address
  TPersonDetails = class(TTxData)
  private
     FSearchName:String;
     FAddName1:String;
     FAddName2:String;
     FAddName3:String;
     FAddName4:String;
     FAddressLine1:String;
     FAddressLine2:String;
     FAddressLine3:String;
     FAddressLine4:String;
     function GetPName   :String;
     function GetPAddress:String;
     procedure SetPName   (Value:String);
     procedure SetPAddress(Value:String);
  public
     property PName        :String read GetPName    write SetPName   ;
     property PAddress     :String read GetPAddress write SetPAddress;
  published
     property SearchName  :String read FSearchName   write FSearchName  ;
     property AddName1    :String read FAddName1     write FAddName1    ;
     property AddName2    :String read FAddName2     write FAddName2    ;
     property AddName3    :String read FAddName3     write FAddName3    ;
     property AddName4    :String read FAddName4     write FAddName4    ;
     property AddressLine1:String read FAddressLine1 write FAddressLine1;
     property AddressLine2:String read FAddressLine2 write FAddressLine2;
     property AddressLine3:String read FAddressLine3 write FAddressLine3;
     property AddressLine4:String read FAddressLine4 write FAddressLine4;
  end;

function DatabasePassword:String;

implementation

function DatabasePassword:String;
//var
//   I:Integer;
const
   Enc = 'TIBCKEROAQUWNFAZROHEWHGMPQXJMPSVLYDUBZYNDGTIFXJSVLCK';
begin
   Result:=DBPass;
//   Result:='';
//   for I:=Length(DBPass) downto 1 do
//      Result:=Result+Char(Integer(Enc[(Integer(DBPass[I])+I)-64]) or ((I and 1)*$20))
end;

{TMOItem}
//==============================================================================
//  Method      : LoadFromRecord
//  Description : Populate the class properies from current record in dataset
//  Parameters  : DataSet - Query or table
//  Result      : None
//==============================================================================
procedure TMOItem.LoadFromRecord(DataSet:TDBDataSet);
begin

   FIdentifier :=DataSet['MOIdentifier' ];
   FIssueNumber:=DataSet['MOIssueNumber'];
   FDateTime   :=DataSet['MODateTime'   ];
end;
{TMOItemList}
//==============================================================================
//  Method      : Create
//  Description : Create - Just calling base class !!
//              : NO NOT REMOVE, DOES NOT CALL BASE CLASS IF REMOVED !
//  Parameters  : AOwner the owing component
//  Result      : None
//==============================================================================
constructor TMOItemList.Create(AOwner:TComponent);
begin
   inherited Create(AOwner);
end;
//==============================================================================
//  Method      : LoadFromDataSet
//  Description : Traverse entire dataset creating items of "ClassType" type
//              : and calling their LoadFromRecord to populate
//  Parameters  : DataSet - Query or table
//              : ClassType - the type of class to create for each record
//  Result      : None
//==============================================================================
procedure TMOItemList.LoadFromDataSet(DataSet:TDBDataSet;ClassType:TMOItemClass);
var
   MOItem:TMOItem;
begin
   while not DataSet.EOF do
   begin
      MOItem:=ClassType.Create(nil);
      MOItem.LoadFromRecord(DataSet);
      Add(MOItem);
      DataSet.Next;
   end;
end;
//==============================================================================
//  Method      : LoadFromQuery
//  Description : Traverse entire dataset creating items of "ClassType" type
//              : and calling their LoadFromRecord to populate
//  Parameters  : Alias     - Database Path or Paradox Alias
//              : SQL       - Query to execute
//              : ClassType - the type of class to create for each record
//  Result      : None
//==============================================================================
procedure TMOItemList.LoadFromQuery(Alias,SQL:String;ClassType:TMOItemClass);
var
   Query:TQuery;
begin
   Query:=TQuery.Create(nil);
   Query.DatabaseName:=Alias;
   Query.SQL.Text:=SQL;
   Query.DBSession.AddPassword(DatabasePassword);
   Query.Active:=True;
   LoadFromDataSet(Query,ClassType);
   Query.DBSession.RemoveAllPasswords;
   Query.Free;
end;
//==============================================================================
//  Method      : IndexOf
//  Description : Find the index of an Item in this list
//              : using the Identifier and Issue number
//  Parameters  : MOItem - Item to find
//  Result      : Zero based Index in list or -1 if not found
//==============================================================================
function TMOItemList.IndexOf(MOItem:TMOItem):Integer;
var
   I:Integer;
begin
   Result:=-1;
   for I:=0 to ListCount-1 do
   begin
      if  (TMOItem(Item[I]).Identifier  = MOItem.Identifier )
      and (TMOItem(Item[I]).IssueNumber = MOItem.IssueNumber) then
      begin
         Result:=I;
         Exit;
      end;
   end;
end;

{TMOIssued}
//==============================================================================
//  Method      : LoadFromRecord
//  Description : Populate the class properies from current record in dataset
//  Parameters  : DataSet - Query or table
//  Result      : None
//==============================================================================
procedure TMOIssued.LoadFromRecord(DataSet:TDBDataSet);
begin
   inherited LoadFromRecord(DataSet);
   FValue            :=DataSet['MOValue'            ];
   FCommission       :=DataSet['MOCommission'       ];
   FTax              :=DataSet['MOTax'              ];
   FSSIndicator      :=DataSet.FieldByName('MOSSIndicator').AsString;
   FSSFee            :=DataSet['MOSSFee'            ];
   FIssuingOffice    :=DataSet['MOIssuingOffice'    ];
   FRContact1        :=DataSet.FieldByName('MORContact1').AsString;
   FRContact2        :=DataSet.FieldByName('MORContact2').AsString;
   FIssuingClerk     :=DataSet['MOIssuingClerk'     ];
   FPayingOffice     :=DataSet['MOPayingOffice'     ];
   FPayByDateTime    :=DataSet['MOPayByDateTime'    ];
   FSendersName      :=DataSet.FieldByName('MOSendersName'      ).AsString;
   FSendersAddress   :=DataSet.FieldByName('MOSendersAddress'   ).AsString;
   FRecipientsName   :=DataSet.FieldByName('MORecipientsName'   ).AsString;
   FRecipientsAddress:=DataSet.FieldByName('MORecipientsAddress').AsString;
   FInformation      :=DataSet.FieldByName('MOInformation'      ).AsString;
end;
{TMOPaid}
//==============================================================================
//  Method      : LoadFromRecord
//  Description : Populate the class properies from current record in dataset
//  Parameters  : DataSet - Query or table
//  Result      : None
//==============================================================================
procedure TMOPaid.LoadFromRecord(DataSet:TDBDataSet);
begin
   inherited LoadFromRecord(DataSet);
   FCommission     :=DataSet['MOCommission'     ];
   FPaidOffice     :=DataSet['MOPaidOffice'     ];
   FPaidClerk      :=DataSet['MOPaidClerk'      ];
   FInformation    :=DataSet.FieldByName('MOInformation'    ).AsString;
   FForcePayDetails:=DataSet.FieldByName('MOForcePayDetails').AsString;
end;
{TMOStatus}
//==============================================================================
//  Method      : LoadFromRecord
//  Description : Populate the class properies from current record in dataset
//  Parameters  : DataSet - Query or table
//  Result      : None
//==============================================================================
procedure TMOStatus.LoadFromRecord(DataSet:TDBDataSet);
begin
   inherited LoadFromRecord(DataSet);
   FStatusValue:=DataSet['MOStatusValue'];
end;
{TMOError}
//==============================================================================
//  Method      : LoadFromRecord
//  Description : Populate the class properies from current record in dataset
//  Parameters  : DataSet - Query or table
//  Result      : None
//==============================================================================
procedure TMOError.LoadFromRecord(DataSet:TDBDataSet);
begin
   inherited LoadFromRecord(DataSet);
   FStatusFrom:=DataSet['MOStatusFrom'];
   FStatusTo  :=DataSet['MOStatusTo'  ];
   FReason    :=DataSet.FieldByName('MOReason').AsString;
end;
{TPersonDetails}
procedure TPersonDetails.SetPName   (Value:String);
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.PackText:=Value;
   if SL.Count > 0 then FSearchName:=SL[0];
   if SL.Count > 1 then FAddName1  :=SL[1];
   if SL.Count > 2 then FAddName2  :=SL[2];
   if SL.Count > 3 then FAddName3  :=SL[3];
   if SL.Count > 4 then FAddName4  :=SL[4];
   SL.Free;
end;
procedure TPersonDetails.SetPAddress(Value:String);
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.PackText:=Value;
   if SL.Count > 0 then FAddressLine1:=SL[0];
   if SL.Count > 1 then FAddressLine2:=SL[1];
   if SL.Count > 2 then FAddressLine3:=SL[2];
   if SL.Count > 3 then FAddressLine4:=SL[3];
   SL.Free;
end;
//==============================================================================
//  Method      : GetPName
//  Description : Construct a person's name from Searchname AddName1,2,3,4
//  Parameters  : None
//  Result      : PackText of Name
//==============================================================================
function TPersonDetails.GetPName:String;
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Add(FSearchName);
   SL.Add(FAddName1  );
   SL.Add(FAddName2  );
   SL.Add(FAddName3  );
   SL.Add(FAddName4  );
   Result:=SL.PackText;
   SL.Free;
end;
//==============================================================================
//  Method      : GetPAddress
//  Description : Construct a person's Address from AddressLine1,2,3,4
//  Parameters  : None
//  Result      : PackText of Address
//==============================================================================
function TPersonDetails.GetPAddress:String;
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Add(FAddressLine1);
   SL.Add(FAddressLine2);
   SL.Add(FAddressLine3);
   SL.Add(FAddressLine4);
   Result:=SL.PackText;
   SL.Free;
end;
// Register Money order classes for streaming into/out of the Details property
initialization
   try
      RegisterClasses([TMOIssued,TMOPaid,TMOStatus,TMOError,TPersonDetails]);
   except
      // sometimes there is an error when a component is loaded in to the 
      // same process space as another and runs through this process for a 
      // second time. A bug in delphi's dpl loading mechanism.
   end;
end.
