{  Module          Corvus Transaction Log
   Unit            Form
   Copyright(c)    Postal Solutions Limited 1996..1998
   Author          MJD
   Description




   Modifications   06/01/98 - MJD
                              Original Release
}
unit TxnlogFU;

interface

uses
  ActiveX,ComObj,Windows,Forms, Classes, Controls, StdCtrls, TxnlogU, Db, DBTables,
  SysUtils,GPCSBase_TLB,GPCSGUID, DGramU,Dialogs,PackStrListU,
  ExtCtrls,ShareDataU,StringUtil,TCPIPCU, I3UIParseU, MOSupportU,StringWrapperU;

const
   UsingService : Boolean = False;

type
  TTxnForm = class(TForm)
    TxnLog: TTxnLog;
    Panel1: TPanel;
    Button1: TButton;
    PSLDatabase: TDatabase;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FParentHandle:THandle;
    Transact:ITableMonitor;
    procedure ExceptionEvent(Sender: TObject;E:Exception);
  public
    WSNumber:Integer;
    TCPIPC:TTCPIPC;
    TransactionData:TPackStringList;
    ShareData:TSharedData;
    I3UINode:TI3UINode;
    procedure RxCommand(FromProc,Command,Data:String);
    procedure Transaction(Index,Quantity,PLU,Workstation,Office,Period:Integer;
                          Value,Price:Currency;const User,TxnType,Ident,Description,
                          Additional,ProgID,DomInfo:WideString);
    procedure WriteTransactions;
  protected
    procedure SetParentHandle(ParentHandle:THandle); virtual;
    procedure CreateParams(var Params:TCreateParams); override;  public
    property Parent:THandle read FParentHandle write SetParentHandle;
  end;

var
  TxnForm: TTxnForm;

implementation

{$R *.DFM}
procedure TTxnForm.CreateParams(var Params:TCreateParams);
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
procedure TTxnForm.RxCommand(FromProc,Command,Data:String);
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   try
      SL.PackText:=Data;
      if Command = 'AreYouThere' then
      begin
         TCPIPC.SendCommand(FromProc,Command,'Yes');
      end
      else if (Command = 'Transaction') and (SL.Count > 9) then
      begin
         Transaction(StrToIntDef (SL[ 0],0), // Index
                     StrToIntDef (SL[ 1],0), // Quantity
                     StrToIntDef (SL[ 2],0), // PLU
                     StrToIntDef (SL[ 3],0), // Workstation
                     StrToIntDef (SL[ 4],0), // Office
                     StrToIntDef (SL[ 5],0), // Period
                     StrToCurrDef(SL[ 6],0), // Value
                     StrToCurrDef(SL[ 7],0), // Price
                                  SL[ 8]   , // User
                                  SL[ 9]   , // TxnType
                                  SL[10]   , // Ident
                                  SL[11]   , // Description
                                  SL[12]   , // Additional
                                 SL[13]   , // ProgID
                                  SL[14]   );// DomInfo
          WriteTransactions;
          TCPIPC.SendCommand(FromProc,Command,'OK');
      end;
   except
      on E:Exception do
         TCPIPC.SendCommand(FromProc,Command,'Falied '+E.Message);
   end;
   SL.Free;
end;

procedure TTxnForm.SetParentHandle(ParentHandle:THandle);
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

procedure TTxnForm.ExceptionEvent(Sender: TObject;E:Exception);
begin
   GPCSGUID.GlobalExceptionEvent(Sender,E);
end;
procedure TTxnForm.FormCreate(Sender: TObject);
begin
   Application.OnException:=ExceptionEvent;
   PSLDatabase.DatabaseName:='PSL';
   PSLDataBase.Params.Add('USER NAME=' + GetGPCSRegString('','UserName','psl'));
   PSLDataBase.Params.Add('PASSWORD='  + GetGPCSRegString('','Password','suvroc'));
   WSNumber:=StrToInt(GetGPCSRegString('Workstation','Ident','0'));
   TransactionData:=TPackStringList.Create;
   ShareData:=TSharedData.Create('CorvusReportShare',False);
   I3UINode:=CreateI3UINode('');
   TCPIPC:=TTCPIPC.Create;
   TCPIPC.ThisProcess:='TxnLog';
   TCPIPC.OnRxCommand:=RxCommand;
   UsingService:=GetGPCSRegString('','Using Service','0') = '1';
   if (not UsingService) and (Transact = nil) then
      Transact:=CreateTableMonitor;
end;
procedure TTxnForm.Transaction(Index,Quantity,PLU,Workstation,Office,Period:Integer;
                               Value,Price:Currency;const User,TxnType,Ident,Description,
                               Additional,ProgID,DomInfo:WideString);
var
   SL:TTxnLogLine;
begin
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
procedure TTxnForm.WriteTransactions;
begin
   if Transact <> nil then
      Transact.WriteTransactions(TransactionData.PackText);
   TransactionData.Clear;
end;

procedure TTxnForm.Button1Click(Sender: TObject);
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

procedure TTxnForm.FormDestroy(Sender: TObject);
begin
   TCPIPC.Free;
   if ShareData <> nil then ShareData.Free;
   ShareData:=nil;
   if Assigned(I3UINode) then
      I3UINode.Free;
   TransactionData.Free;
   Transact:=nil;
end;

procedure TTxnForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   CanClose:=True;
//   WriteTransactions;
end;

end.
