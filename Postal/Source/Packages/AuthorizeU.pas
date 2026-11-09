unit  AuthorizeU;

interface

uses
  GPCSBase_TLB,
  SysUtils,
  QueryMapU;

function Request(TxnLog : ITransactionLog; PLU : Integer; Ident, Description : String; Amount : Currency) : Boolean;
//makes a request for authorization

function IsRequest(User : String; Period : Integer; PLU : Integer; Ident : String; Amount  : Currency) : Boolean;
//checks to see whether there is a request outstanding

function Accept(TxnLog : ITransactionLog; PLU : Integer; Ident, Description : String; Amount : Currency) : Boolean;
//accepts (completes) a previous request

implementation

function Request(TxnLog : ITransactionLog; PLU : Integer; Ident, Description : String; Amount : Currency) : Boolean;
//makes a request for authorization
begin
  TxnLog.WriteTransaction(
         '*BankReq',                // Type
         0,                         // Index
         1,                         // Quantity
         PLU,                       // plu
         Amount,                    // Value
         Amount,                    // Price
         Description,               // Description
         Ident,                     // Additional
         Ident,                     // ProgID
         '');                       // DomInfo
  Result := True;

end;

function Accept(TxnLog : ITransactionLog; PLU : Integer; Ident, Description : String; Amount : Currency) : Boolean;
//accepts (completes) a previous request
begin
  TxnLog.WriteTransaction(
        'BankTxn',                  // Type
        0,                          // Index
        1,                          // Quantity
        PLU,                        // plu
        Amount,                     // Value
        Amount,                     // Price
        Description,                // Description
        Ident,                      // Additional
        Ident,                      // ProgID
        '');                        // DomInfo
  Result := True;


end;


function IsRequest(User : String; Period : Integer; PLU : Integer; Ident : String; Amount  : Currency) : Boolean;
//checks to see whether there is a request outstanding
begin
  With TQueryMap.Create do
  begin
    try
      DataAlias := 'PSL';
      SelectFields        := 'RecType,TxnValue';
      ResultFields        := 'RecType,TxnValue';
      SQL                 :=
          ' select RecType, TxnValue from TxnLog'
        + ' where RecType = ''BankReq'''
        + ' and PLU = ' + IntToStr(PLU)
        + ' and Prod = ''' + Ident + ''''
        + ' and Teller = ''' + User + ''''
        + ' and TxnValue = ' + CurrToStr(Amount)
        + ' and datetime = ('
        + '     select max(datetime) from txnlog  '
        + '     where RecType IN (''BankReq'', ''BankTxn'')'
        + '     and Period = ' + IntToStr(Period)
        + '     and PLU = ' + IntToStr(PLU)
        + '     and Prod = ''' + Ident + ''''
        + '     and Teller = ''' + User + ''''
        + ' )';
      IsRequest := (Execute = '');
    finally
      Free; //TQueryMap;
    end;
  end;  //with TQueryMap

end;


end.
