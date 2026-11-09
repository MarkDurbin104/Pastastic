unit StringWrapperU;

interface

uses 
    PackStrListU,SysUtils;

type
   TStringWrapper = class(TPackStringList)
     protected
        function  GetElement(Index:Integer):Variant;
        procedure SetElement(Index:Integer;Value:Variant);
   end;
   T2DStringWrapper = class(TPackStringList)
     protected
        function GetElement(Index:Integer):TStringWrapper;
     public 
        property Element[Index:Integer]:TStringWrapper read GetElement;
   end;

   TStockLine = class(TStringWrapper)
     public
      property Description         :Variant Index 0 read GetElement write SetElement;
      property InputQuantity       :Variant Index 1 read GetElement write SetElement;
      property Focused             :Variant Index 2 read GetElement write SetElement;
      property Enabled             :Variant Index 3 read GetElement write SetElement;
      property Price               :Variant Index 4 read GetElement write SetElement;
      property ProgID              :Variant Index 5 read GetElement write SetElement;
      property StockQ              :Variant Index 6 read GetElement write SetElement;
      property Declared            :Variant Index 7 read GetElement write SetElement;
      property PLU                 :Variant Index 8 read GetElement write SetElement;
      property OriginalDescription :Variant Index 9 read GetElement write SetElement;
   end;

  TNetUserStringWrapper = class (TStringWrapper)
    public
      property UserName         :Variant Index 0 read GetElement write SetElement;
      property FullName         :Variant Index 1 read GetElement write SetElement;
      property Password         :Variant Index 2 read GetElement write SetElement;
      property Description      :Variant Index 3 read GetElement write SetElement;
      property Groups           :Variant Index 4 read GetElement write SetElement;
  end;
   
  TTxnLogLine = class(TStringWrapper)
    public
     property RecordID    :Variant Index  0 read GetElement write SetElement;
     property WSNumber    :Variant Index  1 read GetElement write SetElement;
     property DateTime    :Variant Index  2 read GetElement write SetElement;
     property RecType     :Variant Index  3 read GetElement write SetElement;
     property Period      :Variant Index  4 read GetElement write SetElement;
     property RecIndex    :Variant Index  5 read GetElement write SetElement;
     property Office      :Variant Index  6 read GetElement write SetElement;
     property Teller      :Variant Index  7 read GetElement write SetElement;
     property PLU         :Variant Index  8 read GetElement write SetElement;
     property Prod        :Variant Index  9 read GetElement write SetElement;
     property Price       :Variant Index 10 read GetElement write SetElement;
     property Quantity    :Variant Index 11 read GetElement write SetElement;
     property TxnValue    :Variant Index 12 read GetElement write SetElement;
     property Description :Variant Index 13 read GetElement write SetElement;
     property Info        :Variant Index 14 read GetElement write SetElement;
     property Ident       :Variant Index 15 read GetElement write SetElement;
     property DomInfo     :Variant Index 16 read GetElement write SetElement;
  end;
   
  TTxnLogLines = class(T2DStringWrapper)
    protected
       function GetElement(Index:Integer):TTxnLogLine;
    public 
       property Element[Index:Integer]:TTxnLogLine read GetElement;
  end;

  TDomInfoLine = class(TStringWrapper)
    public
     property Enabled   :Variant Index 0 read GetElement write SetElement;
     property Focused   :Variant Index 1 read GetElement write SetElement;
     property DomType   :Variant Index 2 read GetElement write SetElement;
     property Name      :Variant Index 3 read GetElement write SetElement;
     property Prompt    :Variant Index 4 read GetElement write SetElement;
     property Text      :Variant Index 5 read GetElement write SetElement;
     property Hint      :Variant Index 6 read GetElement write SetElement;
     property ErrorLine :Variant Index 7 read GetElement write SetElement;
     property Validation:Variant Index 8 read GetElement write SetElement;
     property Addtional :Variant Index 9 read GetElement write SetElement;
  end; 
  TDomInfoLines = class(T2DStringWrapper)
    protected
       function GetElement(Index:Integer):TDomInfoLine;
    public 
       property Element[Index:Integer]:TDomInfoLine read GetElement;
  end;
  TTxCompBlock = class(TStringWrapper)
    public
     property OfficeNo   :Variant Index 0 read GetElement write SetElement;
     property Workstation:Variant Index 1 read GetElement write SetElement;
     property MessageNo  :Variant Index 2 read GetElement write SetElement;
  end;
  TContactInfo = class(TStringWrapper)
    public
     property OfficeName  :Variant Index 0 read GetElement write SetElement;
     property OfficeCode  :Variant Index 1 read GetElement write SetElement;
     property TimeInterval:Variant Index 2 read GetElement write SetElement;
     property AccessVia   :Variant Index 3 read GetElement write SetElement;
     property LastContact :Variant Index 4 read GetElement write SetElement;
  end;
  
   TMODetails = class(TStringWrapper)
     public                            
      property IssuePay:Variant Index  0 read GetElement write SetElement;
      property Series  :Variant Index  1 read GetElement write SetElement;
      property SerialNo:Variant Index  2 read GetElement write SetElement;
      property IOffice :Variant Index  3 read GetElement write SetElement;
      property IClerk  :Variant Index  4 read GetElement write SetElement;
      property IDate   :Variant Index  5 read GetElement write SetElement;
      property IName   :Variant Index  6 read GetElement write SetElement;
      property Value   :Variant Index  7 read GetElement write SetElement;
      property MOType  :Variant Index  8 read GetElement write SetElement;
      property POffice :Variant Index  9 read GetElement write SetElement;
      property PName   :Variant Index 10 read GetElement write SetElement;
      property PPOBox  :Variant Index 11 read GetElement write SetElement;
      property PMessage:Variant Index 12 read GetElement write SetElement;
   end;
   TUserMessage = class(TStringWrapper)
     public                            
      property DestinationHost:Variant Index  0 read GetElement write SetElement;
      property TimeOut        :Variant Index  1 read GetElement write SetElement;
      property CommandType    :Variant Index  2 read GetElement write SetElement;
      property Data           :Variant Index  3 read GetElement write SetElement;
      property HangUpAfter    :Variant Index  4 read GetElement write SetElement;
   end;
   TQueryParams = class(TStringWrapper)
     public                            
      property UserName       :Variant Index  0 read GetElement write SetElement;
      property Password       :Variant Index  1 read GetElement write SetElement;
      property Alias          :Variant Index  2 read GetElement write SetElement;
      property Query          :Variant Index  3 read GetElement write SetElement;
   end;
   TEWBillPayment = class(TStringWrapper)
     public                            
      property CustomerNumber    :Variant Index  0 read GetElement write SetElement;
      property CheckDigit        :Variant Index  1 read GetElement write SetElement;
      property AreaNumber        :Variant Index  2 read GetElement write SetElement;
      property ElectricityAmount :Variant Index  3 read GetElement write SetElement;
      property WaterAmount       :Variant Index  4 read GetElement write SetElement;
      property TotalAmount       :Variant Index  5 read GetElement write SetElement;
      property PaymentDay        :Variant Index  6 read GetElement write SetElement;
      property PaymentMonth      :Variant Index  7 read GetElement write SetElement;
      property PaymentYear       :Variant Index  8 read GetElement write SetElement;
      property BillPeriod        :Variant Index  9 read GetElement write SetElement;
      property EWReference       :Variant Index 10 read GetElement write SetElement;
      property CustomerName      :Variant Index 11 read GetElement write SetElement;
      property PaymentMethod     :Variant Index 12 read GetElement write SetElement;
      property QPostReference    :Variant Index 13 read GetElement write SetElement;
      property TrailerIndicator  :Variant Index 14 read GetElement write SetElement;
      property RecordCount       :Variant Index 15 read GetElement write SetElement;
      property SummaryEAmount    :Variant Index 16 read GetElement write SetElement;
      property SummaryWAmount    :Variant Index 17 read GetElement write SetElement;
      property SummaryTAmount    :Variant Index 18 read GetElement write SetElement;
      property UpdateSent        :Variant Index 19 read GetElement write SetElement;
      property InvoiceSent       :Variant Index 20 read GetElement write SetElement;
      property Cancelled         :Variant Index 21 read GetElement write SetElement; 
      property OpID              :Variant Index 22 read GetElement write SetElement;
      property OfficeCode        :Variant Index 23 read GetElement write SetElement;
      property WorkStation       :Variant Index 24 read GetElement write SetElement;
    end;

                                  
implementation
{TStringWrapper}
function TStringWrapper.GetElement(Index:Integer):Variant;
begin
   try
      if (Index >= 0) and (Index < Count) then
         Result:=Get(Index)
      else
         Result:=''
   except 
         Result:=''
   end;
end;                  
procedure TStringWrapper.SetElement(Index:Integer;Value:Variant);
begin
   if (Index >= 0) then
   begin
      while (Index >= Count) do Add('');
      if VarType(Value) = varDate then
      begin
         Put(Index,FloatToStr(Value));
      end
      else
         Put(Index,Value);  
   end;
end;
{T2DStringWrapper}
function T2DStringWrapper.GetElement(Index:Integer):TStringWrapper;
const
   Wrapper:TStringWrapper = nil;
begin
   if Wrapper = nil then
      Wrapper:=TStringWrapper.Create;
   Wrapper.Clear;
   if (Index >= 0) and (Index < Count) then
      Wrapper.PackText:=Get(Index);
   Result:=Wrapper;
end;
{TTxnLogLines}
function TTxnLogLines.GetElement(Index:Integer):TTxnLogLine;
begin
   Result:=TTxnLogLine(Inherited GetElement(Index));
end;
{TDomInfoLines}
function TDomInfoLines.GetElement(Index:Integer):TDomInfoLine;
begin
   Result:=TDomInfoLine(Inherited GetElement(Index));
end;
end.
