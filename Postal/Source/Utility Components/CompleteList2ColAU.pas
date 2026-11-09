unit {UName}CompleteList2ColAU;

interface

uses
  Classes,BaseProduct,GPCSBase_TLB,GPCSBaseAU,GPCSGUID,SysUtils,GPCSErrorCode,GPCSErrorLine,Domain,
  ComObj,DatabaseServer_TLB;
  
ResourceString
  ResVersion          = {Version}      '1';
  ResBarCode          = {BarCode}      '';
  ResDescription      = {Description}  'Start of Day';
  ResEndDate          = {EndDate}      '01/01/2099';
  ResHighDays         = {HighDays}     'HighDays';
  ResMaxQuantity      = {MaxQuantity}  '0';
  ResMCRCode          = {MCRCode}      '';
  ResMinQuantity      = {MinQuantity}  '0';
  ResOCRCode          = {OCRCode}      '';
  ResOtherCode        = {OtherCode}    '';
  ResPLU              = {PLU}          '0';
  ResRegulations      = {Regulations}  'Regulations';
  ResStartDate        = {StartDate}    '31/10/1995';
  ResUnitPrice        = {UnitPrice}    '0.00';
  ResUnitQuantity     = {UnitQuantity} '1';
  ResUseDays          = {UseDays}      'UseDays';
  ResCaption          = {Caption}      'Start of Day';
  ResTitle            = {Title}        'Start of Day';
  ResPrompt           = {Prompt}       '';
  ResHint             = {Hint}         '';
  {BMPStart}
   BMPRes00 = ',4,P4C<%/$ %5$)-1@@  !)V & H $!+ $ R $ ! $ O! !@  #0!P  $@L 0Q !( !! a  ,!a#@    #  @(  <P!@ +  P,#  3 !D1aD_P   #  __\ <P!@ +  \/\    5[N  __@bCP  !.XbCP  !NXbCP  !NXbCP  !NXbCP  !NXbCP  !NXbC^[N[GG^'+
              'O@   NXbCP*/ 2#NX!0/!0\bD */   &[@*/   &[@*/[@^_Z[N[NP   >XbCP)@ # /,.L)<  V HL!X0)0 #aaSPSL HOK[NLb00!b!+8 D@*+[NXb,@!2!< b(O_K %,bC 3W#,PbCP[b P$$DP!D HPa(+X 0+L 40>:[W\bBP1Q$/+K *$$M !R H_N!0(bCS2)'+
              ' >$b<0!#!)+^/@!4!0Lb P!EbADbCP)EN[N^!,0 <0*/ H\bC.M^a[L,,@*( 2 b00!!!0Z^[NN[&,$ 4 >/ R$ 0;W/ =#K%D$6< +@ H_N !0bCP&4[N TB@12 % >0/_Q S b10b! HXb   U @$ 10*/ F4,T0)E[N[@!XK/_Q&:#aGNX *+b<$%%037 * bCP)U'+
              '#, b   U HPaF)/_!WKNX >+[NL$]RL2!0\!(0&P I4 \ 4I!0L!H?__!1, H0*P #8bBP%R!2$   aN H\   ;N H\   ;N H\aP G= 3#F3P*/ 5 bC^[@% Pb8.[N H_NX */   %[@*/   &[O@  H\   ;N H\   ;N H @';
  {BMPEnd}
const
  CompStr='$%+ -./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  
type
  {PClass}TComplListProduct = class(TBaseProduct,IEventSink)
  private
     FQuantity:Integer;
     FUIEventSink:IUIEventSink;
     FItemList:TItemList;
  protected
    function GetResourceString(Index:Integer):String; override;
    procedure Execute(Quantity, MaxItems: Integer; NoRedraw: WordBool; 
                      const UIEventSink: IUIEventSink;
                      const TxnLog: ITransactionLog);                 override;
    procedure TerminateExecute(const TxnLog: ITransactionLog);        override;
    procedure CompleteExecute(const TxnLog: ITransactionLog);         override;
    procedure Complete(const EventSource: IExecComponent);            safecall;
    procedure DesignComplete(const EventSource: IExecComponent);      safecall;
    function  GetExecData: WideString;                                override;
    function  SetExecData(const Value: WideString;var FlagError:WordBool): WideString;       override;
    procedure NotifyChildClick(const Name: WideString; Index: Integer); override;
//    function Get_NeedsWeight: WordBool; override;
    procedure TriggerValue(Source: TriggerSource; const Value: WideString); override;
  end;    
                                   
implementation
uses
  CompleteList2ColFU;

function {PClass}TComplListProduct.GetResourceString(Index:Integer):String;
begin
    case Index of
       riVersion      : Result:=ResVersion       ;
       riBarCode      : Result:=ResBarCode       ;
       riDescription  : Result:=ResDescription   ;
       riEndDate      : Result:=ResEndDate       ;
       riHighDays     : Result:=ResHighDays      ;
       riMaxQuantity  : Result:=ResMaxQuantity   ;
       riMCRCode      : Result:=ResMCRCode       ;
       riMinQuantity  : Result:=ResMinQuantity   ;
       riOCRCode      : Result:=ResOCRCode       ;
       riOtherCode    : Result:=ResOtherCode     ;
       riPLU          : Result:=ResPLU           ;
       riRegulations  : Result:=ResRegulations   ;
       riStartDate    : Result:=ResStartDate     ;
       riUnitPrice    : Result:=ResUnitPrice     ;
       riUnitQuantity : Result:=ResUnitQuantity  ;
       riUseDays      : Result:=ResUseDays       ;
       riCaption      : Result:=ResCaption       ;
       {BMPResStart}
       riBitMap       : Result:=BMPRes00;
       {BMPResEnd}
       riCount        : Result:='1';
       riItemBase     : Result:='Complete';
       
       riTitle        : Result:=ResTitle;
       riPrompt       : Result:=ResPrompt;
       riPMessage     : Result:=ResHint;
       else Result:='';
    end;
end;
procedure {PClass}TComplListProduct.Execute(Quantity, MaxItems: Integer; NoRedraw: WordBool; 
                  const UIEventSink: IUIEventSink;const TxnLog:ITransactionLog);
var
   I,J:Integer;
   CompMan:ICompMan;
   CurrentItem:IExecComponent;
   S:String;
begin
   if UIEventSink = nil then Exit;
   FUIEventSink:=UIEventSink;
   FQuantity:=Quantity;
   
   if FItemList <> nil then FItemList.Free;
   FItemList:=TItemList.Create;
   
   CompMan:=CreateCompMan;
   for I:=0 to Get_Count-1 do
   begin
      S:=Get_Item(I);
      if Copy(S,1,8) = 'Product.' then
         FItemList.Add(CompMan.LoadComponent(S) as IExecComponent,S);
   end;
   CompMan:=nil;
   
   if ProdForm = nil then 
   begin
      ProdForm:=TProdForm.Create(nil);
   end;
   I:=0;
   J:=0;
   while (I < MaxItems) and (I < Get_Count) do
   begin
      S:=Get_Item(I);
      if Copy(S,1,8) = 'Product.' then
      begin
         CurrentItem:=FItemList[J].Instance;
         if not NoRedraw then
            FUIEventSink.DisplayItemInfo(Self,I,CurrentItem.Bitmap,
                                                CurrentItem.Caption,
                                                CurrentItem.Price[0],0,False);
         Inc(J);
         Inc(I);
         CurrentItem.EventSink:=Self;
      end
      else
      begin
         if not NoRedraw then
            FUIEventSink.DisplayItemInfo(Self,I,'',S,0,0,False);
         Inc(I);
      end;
   end;
   if not NoRedraw then
   begin
      while (I < MaxItems) do
      begin
         FUIEventSink.DisplayItemInfo(Self,I,'','',0,0,False);
         Inc(I);
      end;
   end;
end;
procedure {PClass}TComplListProduct.TerminateExecute(const TxnLog:ITransactionLog);          
begin
   try
      if FItemList <> nil then 
         FItemList.Free;
      FItemList:=nil;
      FUIEventSink:=nil;
      if ProdForm <> nil then 
      begin
         ProdForm.Free;
         ProdForm:=nil;
      end;
   except
      on E:Exception do RaiseException(EC_Group_TBaseGroup_TerminateExecute+1,E);
   end;
end;
procedure {PClass}TComplListProduct.CompleteExecute(const TxnLog:ITransactionLog);
begin
   // Send to BO
   TerminateExecute(TxnLog);
end;
procedure {PClass}TComplListProduct.Complete(const EventSource: IExecComponent);
begin     
end;
procedure {PClass}TComplListProduct.DesignComplete(const EventSource: IExecComponent);
begin
end;
function {PClass}TComplListProduct.GetExecData: WideString;
begin
   Result:='';
   Try
      if ProdForm <> nil then 
         Result:=ProdForm.EnqList.LineEditData;
   except
      // set error value !!!
      on E:Exception do RaiseException(EC_Group_TBaseGroup_TerminateExecute+1,E);
   end;
end;
function {PClass}TComplListProduct.SetExecData(const Value: WideString;var FlagError:WordBool):WideString;
begin
   Try
      if ProdForm <> nil then 
      begin
         ProdForm.EnqList.SetLineEditData(Value);
         if not ProdForm.Validate then FlagError:=True;
         Result:=ProdForm.EnqList.LineEditData;
      end;                                         
   except
      on E:Exception do RaiseException(EC_Group_TBaseGroup_TerminateExecute+1,E);
   end;
end;
procedure {PClass}TComplListProduct.NotifyChildClick(const Name: WideString; Index: Integer);
begin
end;
procedure {PClass}TComplListProduct.TriggerValue(Source: TriggerSource; const Value: WideString);
begin            
   case Source of
      tsKeyboard       : ;
      tsBarCode        : ;
      tsMCRReader      : ;
      tsScale          : ;
      tsOtherReader    : ;
      tsStatusDevice0  : if ProdForm <> nil then
                          begin
                             ProdForm.EnqList.Items.Clear;
                             try
                                ProdForm.EnqList.Items.LoadFromFile(Value);
                             except
                             end;
                          end;
      tsStatusDevice1  : ;   
      tsStatusDevice2  : ;
      tsStatusDevice3  : ;
      tsStatusDevice4  : ;
      tsStatusDevice5  : ;
      tsStatusDevice6  : ;
      tsStatusDevice7  : ;
      tsStatusDevice8  : ;
      tsStatusDevice9  : ;
   end;
end;

end.
