{  Module          Corvus Transaction Log
   Unit            Form
   Copyright(c)    Postal Solutions Limited 1996..1998
   Author          MJD
   Description




   Modifications   06/01/98 - MJD
                              Original Release
}
unit NewTxnlogFU;

interface

uses
  ActiveX,ComObj,Windows,Forms, Classes, Controls, StdCtrls, TxnlogU, Db, DBTables,
  SysUtils,GPCSBase_TLB,GPCSGUID, DGramU,Dialogs,PackStrListU,
  MsgConfigU,MsgFileAccessU,FileTxStatusU,
  ExtCtrls,StringUtil,StringWrapperU,GPCSErrorLine;

const
   UsingService : Boolean = False;

type
  TNewTxnForm = class(TForm)
    TxnLog: TTxnLog;
    Panel1: TPanel;
    Button1: TButton;
    PSLDatabase: TDatabase;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Timer1Timer(Sender: TObject);
  private
    FParentHandle:THandle;
    procedure ExceptionEvent(Sender: TObject;E:Exception);
  public
    WSNumber:Integer;
    TransactionData:TPackStringList;
    procedure Transaction(Index,Quantity,PLU,Workstation,Office,Period:Integer;
                          Value,Price:Currency;const User,TxnType,Ident,Description,
                          Additional,ProgID,DomInfo:WideString);
    procedure WriteTransactions;
  protected
    HoldUntil:TDateTime;
    procedure SetParentHandle(ParentHandle:THandle); virtual;
    procedure CreateParams(var Params:TCreateParams); override;  public
    property Parent:THandle read FParentHandle write SetParentHandle;
  end;

var
  NewTxnForm: TNewTxnForm;

implementation

{$R *.DFM}
procedure TNewTxnForm.CreateParams(var Params:TCreateParams);
begin
   inherited CreateParams(Params);
   with Params do
   begin
      if FParentHandle = 0 then
         FParentHandle:=Application.Handle;
      WndParent:=FParentHandle;
      if FParentHandle <> Application.Handle then
         Style:=(Style or WS_CHILD) and (not WS_POPUP);
   end;
end;

procedure TNewTxnForm.SetParentHandle(ParentHandle:THandle);
var
   WindowRect:TRect;
begin
   FParentHandle:=ParentHandle;
   RecreateWnd;
   if FParentHandle <> 0 then
   begin
      GetWindowRect(FParentHandle,WindowRect);
      Left:=0;
      Top:=0;
      with WindowRect do
      begin
         Width:=Right-Left;
         Height:=Bottom-Top;
      end;
   end;
end;

procedure TNewTxnForm.ExceptionEvent(Sender: TObject;E:Exception);
begin
   GPCSGUID.GlobalExceptionEvent(Sender,E);
end;
procedure TNewTxnForm.FormCreate(Sender: TObject);
begin
   HoldUntil:=0;
   Application.OnException:=ExceptionEvent;
   PSLDatabase.DatabaseName:='PSL';
   PSLDataBase.Params.Add('USER NAME=' + GetGPCSRegString('','UserName','psl'));
   PSLDataBase.Params.Add('PASSWORD='  + GetGPCSRegString('','Password','suvroc'));
   WSNumber:=StrToInt(GetGPCSRegString('Workstation','Ident','0'));
   TransactionData:=TPackStringList.Create;
end;
procedure TNewTxnForm.Transaction(Index,Quantity,PLU,Workstation,Office,Period:Integer;
                               Value,Price:Currency;const User,TxnType,Ident,Description,
                               Additional,ProgID,DomInfo:WideString);
var
   SL:TTxnLogLine;
begin
   if TxnType = 'MBlkStart' then 
      HoldUntil:=Now+10*OneSecond
   else if (TxnType = 'MBlkEnd') or (TxnType = 'StartDay') then 
      HoldUntil:=0;
   SL:=TTxnLogLine.Create;   
   SL.RecordID   :=0          ; // filled in when written to db
   SL.WSNumber   :=Workstation;
   SL.DateTime   :=Now        ;
   SL.RecType    :=TxnType    ;
   SL.Period     :=Period     ;
   SL.RecIndex   :=Index      ;
   SL.Office     :=Office     ;
   SL.Teller     :=User       ;
   SL.PLU        :=PLU        ;
   SL.Prod       :=ProgID     ;
   SL.Price      :=Price      ;
   SL.Quantity   :=Quantity   ;
   SL.TxnValue   :=Value      ;
   SL.Description:=Description;
   SL.Info       :=Additional ;
   SL.Ident      :=Ident      ;
   SL.DomInfo    :=DomInfo    ;
   TransactionData.Add(SL.PackText);
   SL.Free;
end;
procedure TNewTxnForm.WriteTransactions;
var
   S:String;
begin
   if (HoldUntil = 0) or (HoldUntil < Now) then
   begin
      if HoldUntil <> 0 then HoldUntil:=Now+2*OneSecond;
      S:=TransactionData.PackText;
      TransactionData.Clear;
      if S <> '' then
         if not SendServiceMessage(dtTransaction,0,5000,Now+1,Now+500,'Data','Data',mtTransaction,0,'',S) then
            RaiseGUIDError('{86428824-69A4-4509-B4A2-5E7EFF627365}','Critical Failure while Writing Transactions');
   end;
end;    

procedure TNewTxnForm.Button1Click(Sender: TObject);
var
   I:Integer;
begin
   for I:=0 to 9 do
   begin
      Transaction(0,1,1,WSNumber,3211,GetTodayasPeriod,
                 I*10,I*10,'Fred','TxnLine','1234','Dummy Transaction line',
                 '','','');
      WriteTransactions;
   end;
end;

procedure TNewTxnForm.FormDestroy(Sender: TObject);
begin
   TransactionData.Free;
end;

procedure TNewTxnForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   CanClose:=True;
   HoldUntil:=0;
   WriteTransactions;
end;

procedure TNewTxnForm.Timer1Timer(Sender: TObject);
begin
   WriteTransactions;
end;

end.
