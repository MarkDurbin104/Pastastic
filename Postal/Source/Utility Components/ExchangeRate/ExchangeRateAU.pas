unit ExchangeRateAU;

interface

uses
  Windows,Graphics,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Registry;
  
type
  TRate = class(TObject)
     Value:Currency;
  end;
  TExchangeRateServer = class(TBaseExchangeRateServer,IExchangeRateServer)
  private
     FRateList:TStringList;
  protected
    function RateFor(const Country: WideString): Currency; override;
    function Exchange(const Country: WideString; Amount: Currency): Currency; override;
    procedure SetRateFor(const Country: WideString; NewRate: Currency); override;
    function GetRatesAsCommaText: WideString; override;
  public  
     procedure Initialize; override;
     destructor Destroy; override;
  end;                  
  
implementation
uses
   ComServ2;
procedure TExchangeRateServer.Initialize;
var
  Rate:TRate;
  I:Integer;
begin
   FRateList:=TStringList.Create;
   try
      with TRegistry.Create do
      begin
         RootKey:=HKEY_LOCAL_MACHINE;
         if OpenKey('Software\PSL\GPCS\ExchangeRates',False) then
         begin
            GetValueNames(FRateList);
            for I:=0 to FRateList.Count-1 do
            begin
               Rate:=TRate.Create;
               try
                  Rate.Value:=StrToCurr(ReadString(FRateList[I]));
               except
                  Rate.Value:=0;
               end;
               FRateList.Objects[I]:=Rate;
            end;
            CloseKey;
         end;
      end;
   except
   end;
   inherited Initialize;
end;
destructor TExchangeRateServer.Destroy;
var
   I:Integer;
begin
   if FRateList <> nil then
   begin
      for I:=0 to FRateList.Count-1 do
      begin
         if FRateList.Objects[I] <> nil then 
            TRate(FRateList.Objects[I]).Free;
      end;
      FRateList.Free;
      FRateList:=nil;
   end;
   inherited Destroy;
end;
function TExchangeRateServer.RateFor(const Country: WideString): Currency;
var
   Index:Integer;
begin
   Result:=0;
   if FRateList <> nil then
   begin
      Index:=FRateList.IndexOf(Country);
      if Index <> -1 then
         Result:=TRate(FRateList.Objects[Index]).Value;
   end;
end; 
function TExchangeRateServer.Exchange(const Country: WideString; Amount: Currency): Currency;
var
   Index:Integer;
   Rate:Currency;
begin
   Result:=0;
   if FRateList <> nil then
   begin
      Index:=FRateList.IndexOf(Country);
      if Index <> -1 then
      begin
         Rate:=TRate(FRateList.Objects[Index]).Value;
         Result:=Amount*Rate;
      end;
   end;    
end; 
procedure TExchangeRateServer.SetRateFor(const Country: WideString; NewRate: Currency);
var
   Rate:TRate;
   Index:Integer;
begin
   if FRateList <> nil then
   begin
      Index:=FRateList.IndexOf(Country);
      if Index <> -1 then
      begin
         TRate(FRateList.Objects[Index]).Value:=NewRate;
      end
      else
      begin
         Rate:=TRate.Create;
         Rate.Value:=NewRate;
         FRateList.AddObject(Country,Rate);
      end;
      with TRegistry.Create do
      begin
         RootKey:=HKEY_LOCAL_MACHINE;
         if OpenKey('Software\PSL\GPCS\ExchangeRates',True) then
         begin
            WriteString(Country,CurrToStr(NewRate));
            CloseKey;
         end;
      end;
   end;    
end;
function TExchangeRateServer.GetRatesAsCommaText: WideString;
var
   SL:TStringList;
   I:Integer; 
begin
   SL:=TStringList.Create;
   for I:=0 to FRateList.Count-1 do
      SL.Add('"'+FRateList[I]+'","'+CurrToStr(TRate(FRateList.Objects[I]).Value)+'"');
   Result:=Sl.CommaText;
   SL.Free;
end;
   
initialization
  TGPCSCompFactory.Create(ComServer,TExchangeRateServer,Class_ExchangeRateServer,
                          'Support.ExchangeRate','GPCS Exchange Rate Server',
                          ciMultiInstance);
end.