unit MigrateToShirikaFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,FileTxStatusU,
  StdCtrls, ComCtrls, Db, DBTables,GPCSGUID,SharedStockU;

type
  TForm1 = class(TForm)
    Button1: TButton;
    SB: TStatusBar;
    ProgressBar1: TProgressBar;
    TxnLog: TQuery;
    Label1: TLabel;
    Edit1: TEdit;
    Query1: TQuery;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  public
     procedure ProgTxFL(PhaseNo,PhaseOf,Max,Pos:Integer);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.ProgTxFL(PhaseNo,PhaseOf,Max,Pos:Integer);
begin
   try
      if Pos = 0 then
      begin
         ProgressBar1.Min:=0;
         ProgressBar1.Max:=Max;
         ProgressBar1.Visible:=True;
      end
      else if Max = Pos+1 then
      begin
         ProgressBar1.Visible:=False;
         SB.SimpleText:='';
      end;

      if Pos mod 200 = 0 then
      begin
         ProgressBar1.Position:=Pos;
         case PhaseNo of
            1 : SB.SimpleText:='Opening Query...';
            2 : SB.SimpleText:='Transfering Data...';
            3 : SB.SimpleText:='Flushing Files...';
         end;      
         Application.ProcessMessages;
      end;
   except
   end;
end;
procedure TForm1.Button1Click(Sender: TObject);
var
  FileTxStatus:TFileTxStatus;
begin
   Button1.Enabled:=False;
   try
      SB.SimpleText:='Updating Office Code...';
      SB.Repaint;
      Application.ProcessMessages;
      Query1.SQL.Text:='UPDATE TXNLOG SET OFFICE = '''+Edit1.Text+'''';
      Query1.ExecSQL;
      SetGPCSRegString('OfficeInfo','Office Id',Edit1.Text);
   except
      on E:Exception do ShowMessage(E.Message);
   end;
   try
      SB.SimpleText:='Migrating Stock...';
      SB.Repaint;
      Application.ProcessMessages;
      with TSiteStock.Create do Free;
   except
      on E:Exception do ShowMessage(E.Message);
   end;
   FileTxStatus:=TFileTxStatus.Create(nil);
   try
      FileTxStatus.Active:=False;
      TTxnTransfer.BuildStoreFromTxnLog(TxnLog,FileTxStatus,ProgTxFL);
   except
      on E:Exception do ShowMessage(E.Message);
   end;
   FileTxStatus.Free;
   Caption:='Complete';
   ShowMessage('Migration Complete!');
end;
procedure TForm1.FormCreate(Sender: TObject);
begin
   Edit1.Text:=GetGPCSRegString('OfficeInfo','Office Id','1000');
end;

end.
