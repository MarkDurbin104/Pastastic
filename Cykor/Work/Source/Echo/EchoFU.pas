unit EchoFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OleCtrls, isp3;

type
  TForm1 = class(TForm)
    TCP1: TTCP;
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure TCP1Connect(Sender: TObject);
    procedure TCP1ConnectionRequest(Sender: TObject; requestID: Integer);
    procedure TCP1DataArrival(Sender: TObject; bytesTotal: Integer);
    procedure TCP1Error(Sender: TObject; Number: Smallint;
      var Description: WideString; Scode: Integer; const Source,
      HelpFile: WideString; HelpContext: Integer;
      var CancelDisplay: WordBool);
    procedure TCP1SendComplete(Sender: TObject);
    procedure TCP1SendProgress(Sender: TObject; bytesSent,
      bytesRemaining: Integer);
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
begin
   TCP1.Listen;
   Memo1.Lines.add('Listening...');
end;

procedure TForm1.TCP1Connect(Sender: TObject);
begin
   Memo1.Lines.add('Connect');
end;

procedure TForm1.TCP1ConnectionRequest(Sender: TObject;
  requestID: Integer);
begin
   TCP1.Accept(requestID);
   Memo1.Lines.add('Connect Request');
end;

procedure TForm1.TCP1DataArrival(Sender: TObject; bytesTotal: Integer);
begin
   Memo1.Lines.add('Data');
end;

procedure TForm1.TCP1Error(Sender: TObject; Number: Smallint;
  var Description: WideString; Scode: Integer; const Source,
  HelpFile: WideString; HelpContext: Integer; var CancelDisplay: WordBool);
begin
   Memo1.Lines.add('Error '+Description);
end;

procedure TForm1.TCP1SendComplete(Sender: TObject);
begin
   Memo1.Lines.add('Send Complete');
end;

procedure TForm1.TCP1SendProgress(Sender: TObject; bytesSent,
  bytesRemaining: Integer);
begin
   Memo1.Lines.add('Send Progress');
end;

end.
