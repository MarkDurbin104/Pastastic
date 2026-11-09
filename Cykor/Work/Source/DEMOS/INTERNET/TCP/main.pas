unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OleCtrls, ExtCtrls, ComCtrls, Menus, ActiveX, StdCtrls, Buttons, isp3;

type
  TChatForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    FileListenItem: TMenuItem;
    StatusBar1: TStatusBar;
    Bevel1: TBevel;
    Panel1: TPanel;
    TCP1: TTCP;
    Memo1: TMemo;
    Memo2: TMemo;
    N1: TMenuItem;
    procedure FileListenItemClick(Sender: TObject);
    procedure TCP1ConnectionRequest(Sender: TObject; requestID: Integer);
    procedure TCP1DataArrival(Sender: TObject; bytesTotal: Integer);
    procedure Exit1Click(Sender: TObject);
    procedure TCP1Close(Sender: TObject);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Disconnect1Click(Sender: TObject);
    procedure TCP1Connect(Sender: TObject);
    procedure TCP1Error(Sender: TObject; Number: Smallint;
      var Description: WideString; Scode: Integer; const Source,
      HelpFile: WideString; HelpContext: Integer;
      var CancelDisplay: WordBool);
  end;

var
  ChatForm: TChatForm;
  Server: String;
  N: Integer;

implementation

{$R *.DFM}

procedure TChatForm.FileListenItemClick(Sender: TObject);
begin
  FileListenItem.Checked := not FileListenItem.Checked;
  if FileListenItem.Checked then
  begin
    TCP1.Listen;
    Statusbar1.Panels[0].Text := 'Listening...'
  end
  else
  begin
    if TCP1.State <> sckClosed then
      TCP1.Close;
    Statusbar1.Panels[0].Text := 'Not Listening';
  end;
end;

procedure TChatForm.TCP1ConnectionRequest(Sender: TObject;
  requestID: Integer);
begin
//  FileListenItemClick(nil);
  TCP1.Accept(requestID);
  Statusbar1.Panels[0].Text := 'Connected to: ' + TCP1.RemoteHostIP;
end;

procedure TChatForm.TCP1DataArrival(Sender: TObject; bytesTotal: Integer);
var
  Data: OleVariant;
begin
  TCP1.GetData(Data, VT_BSTR, bytesTotal);
  TCP1.SendData(Data);
  Memo2.Lines.Add('RxTx:'+Data);
end;

procedure TChatForm.Exit1Click(Sender: TObject);
begin
  TCP1.Close;
  Close;
end;

procedure TChatForm.TCP1Close(Sender: TObject);
begin
  ShowMessage('TCP1.Close');
  Statusbar1.Panels[0].Text := 'Disconnected';
end;

procedure TChatForm.Memo1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_Return then
  begin
    Memo2.Lines.Add('Sending');
    TCP1.SendData(Memo1.Lines[Memo1.Lines.Count - 1]);
  end;
end;

procedure TChatForm.Disconnect1Click(Sender: TObject);
begin
  TCP1.Close;
  FileListenItemClick(nil);
end;

procedure TChatForm.TCP1Connect(Sender: TObject);
begin
   memo2.lines.Add('connected');
end;

procedure TChatForm.TCP1Error(Sender: TObject; Number: Smallint;
  var Description: WideString; Scode: Integer; const Source,
  HelpFile: WideString; HelpContext: Integer; var CancelDisplay: WordBool);
begin
  ShowMessage(Description);
end;

end.
