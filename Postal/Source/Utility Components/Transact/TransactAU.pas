unit TransactAU;

interface

uses
  Forms,ActiveX,Windows,Graphics,Classes,SysUtils,ComObj,
  PackStrListU,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,ExtCtrls,DB,
  MOItemsU,GPCSErrorLine;

type
  TTransact = class(TGPCSBaseComponent,ITableMonitor)
  private
    Timer:TTimer;
  public
    procedure Initialize; override;
    destructor Destroy; override;
  protected
    procedure WriteTransactions(const PackText: WideString); safecall;
    procedure Attach; safecall;
end;

function GetInterface:IDispatch;

implementation

uses
   ComServ2,TransactFU;

procedure TTransact.Attach;
begin
end;

procedure TTransact.WriteTransactions(const PackText: WideString);
begin
   TxnForm.TxnProcessor.WriteTransactions(PackText);
end;

const
   GPCSCompFactory  :TGPCSCompFactory = nil;
   GettingInterface :Boolean          = False;

procedure TTransact.Initialize;
begin
   try
      inherited Initialize;
      if GettingInterface then
      begin
         _AddRef;
         TxnForm:=TTxnForm.Create(Application);
         TxnForm.Visible:=False;
      end;
      Timer:=TTimer.Create(nil);
      Timer.Enabled:=False;
      Timer.Interval:=1000;
      Timer.OnTimer:=TxnForm.TxnProcessor.CheckTxns;
      Timer.Enabled:=True;
   except
      On E : Exception do
        RaiseGUIDException('{CCB80783-0BA5-45D3-9A9D-355BF6FE1190}', E);
   end;
end;
destructor TTransact.Destroy;
begin
   Timer.Enabled:=False;
   Timer.Free;
   inherited Destroy;
end;

function GetInterface:IDispatch;
begin
   try
      GettingInterface:=True;
      if GPCSCompFactory = nil then
      begin
         GPCSCompFactory:=
         TGPCSCompFactory.Create(ComServer,TTransact,Class_GPCSTableMonitor,
                             'Support.Transact','GPCS Transact Table Monitor',
                             ciMultiInstance);
      end;
      Result:={PClass}TTransact.Create;
   except
      On E : Exception do
        RaiseGUIDException('{CD4A5C42-43D0-48C9-8C4E-FE2CA1728258}', E);
   end;
end;

initialization
  GPCSCompFactory:=TGPCSCompFactory.Create(ComServer,TTransact,Class_GPCSTableMonitor,
                          'Support.Transact','GPCS Transact Table Monitor',
                          ciMultiInstance);
end.
