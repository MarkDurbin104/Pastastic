unit ResetTransmitStatusFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FileTxStatusU, StdCtrls,DTSocketU;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    SendRSHost: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
   FileTxStatus:TFileTxStatus;
   S:String;
begin
   Button1.Enabled:=False;
   FileTxStatus:=TFileTxStatus.Create(nil);
   FileTxStatus.Active:=False;
   S:=FileTxStatus.SendCommand(SendRSHost.Text,60000,ctClearTxState,nil,True);
   if S = '' then
      ShowMessage('Remote machine Transmit Status has been reset.')
   else
      ShowMessage(S);
   FileTxStatus.Free;
   Button1.Enabled:=True;
end;

end.
