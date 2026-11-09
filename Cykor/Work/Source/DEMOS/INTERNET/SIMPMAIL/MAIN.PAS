unit Main;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls, OleCtrls, 
  ISP3;

type

  TMainForm = class(TForm)
    OpenDialog: TOpenDialog;
    SMTP1: TSMTP;
    POP1: TPOP;
    PageControl1: TPageControl;
    SendPage: TTabSheet;
    RecvPage: TTabSheet;
    ConPage: TTabSheet;
    Panel1: TPanel;
    Label1: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    eTo: TEdit;
    eCC: TEdit;
    eSubject: TEdit;
    SendBtn: TButton;
    ClearBtn: TButton;
    reMessageText: TRichEdit;
    SMTPStatus: TStatusBar;
    Panel3: TPanel;
    mReadMessage: TMemo;
    POPStatus: TStatusBar;
    cbSendFile: TCheckBox;
    GroupBox1: TGroupBox;
    ePOPServer: TEdit;
    Label6: TLabel;
    Label5: TLabel;
    eUserName: TEdit;
    ePassword: TEdit;
    Label4: TLabel;
    GroupBox2: TGroupBox;
    Label7: TLabel;
    eSMTPServer: TEdit;
    SMTPConnectBtn: TButton;
    POPConnectBtn: TButton;
    eHomeAddr: TEdit;
    Label8: TLabel;
    Panel2: TPanel;
    Label9: TLabel;
    lMessageCount: TLabel;
    Label10: TLabel;
    eCurMessage: TEdit;
    udCurMessage: TUpDown;
    ConnectStatus: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure POP1StateChanged(Sender: TObject; State: Smallint);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SMTP1StateChanged(Sender: TObject; State: Smallint);
    procedure FormResize(Sender: TObject);
    procedure ClearBtnClick(Sender: TObject);
    procedure SMTP1Verify(Sender: TObject);
    procedure SendBtnClick(Sender: TObject);
    procedure POP1ProtocolStateChanged(Sender: TObject;
      ProtocolState: Smallint);
    procedure SMTPConnectBtnClick(Sender: TObject);
    procedure POPConnectBtnClick(Sender: TObject);
    procedure eSMTPServerChange(Sender: TObject);
    procedure ePOPServerChange(Sender: TObject);
    procedure cbSendFileClick(Sender: TObject);
    procedure udCurMessageClick(Sender: TObject; Button: TUDBtnType);
    procedure POP1RefreshMessageCount(Sender: TObject; Number: Integer);
    procedure POP1DocOutput(Sender: TObject; const DocOutput: DocOutput);
    procedure POP1Error(Sender: TObject; Number: Smallint;
      var Description: WideString; Scode: Integer; const Source,
      HelpFile: WideString; HelpContext: Integer;
      var CancelDisplay: WordBool);
    procedure SMTP1DocInput(Sender: TObject; const DocInput: DocInput);
    procedure SMTP1Error(Sender: TObject; Number: Smallint;
      var Description: WideString; Scode: Integer; const Source,
      HelpFile: WideString; HelpContext: Integer;
      var CancelDisplay: WordBool);
  private
    RecvVerified,
    SMTPError,
    POPError: Boolean;
    FMessageCount: Integer;
    procedure SendFile(Filename: string);
    procedure SendMessage;
    procedure CreateHeaders;
  end;

var
  MainForm: TMainForm;
 
implementation

{$R *.DFM}


const 
  icDocBegin = 1;
  icDocHeaders = 2;
  icDocData = 3;
  icDocEnd = 5;

{When calling a component method which maps onto an OLE call, NoParam substitutes 
for an optional parameter. As an alternative to calling the component method, you 
may access the component's OLEObject directly - 
i.e., Component.OLEObject.MethodName(,Foo,,Bar)}
function NoParam: Variant;
begin
  TVarData(Result).VType := varError;
  TVarData(Result).VError := DISP_E_PARAMNOTFOUND;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  SMTPError := False;
  POPError := False;
  FMessageCount := 0;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if POP1.State = prcConnected then POP1.Quit;
  if SMTP1.State = prcConnected then SMTP1.Quit;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  SendBtn.Left := ClientWidth - SendBtn.Width - 10;
  ClearBtn.Left := ClientWidth - ClearBtn.Width - 10;
  cbSendFile.Left := ClientWidth - cbSendFile.Width - 10;
  eTo.Width := SendBtn.Left - eTo.Left - 10;
  eCC.Width := SendBtn.Left - eCC.Left - 10;
  eSubject.Width := SendBtn.Left - eSubject.Left - 10;
end;

procedure TMainForm.ClearBtnClick(Sender: TObject);
begin
  eTo.Text := '';
  eCC.Text := '';
  eSubject.Text := '';
  OpenDialog.Filename := '';
  reMessageText.Lines.Clear;
end;

procedure TMainForm.eSMTPServerChange(Sender: TObject);
begin
  SMTPConnectBtn.Enabled := (eSMTPServer.Text <> '') and (eHomeAddr.Text <> '');
end;

procedure TMainForm.ePOPServerChange(Sender: TObject);
begin
  POPConnectBtn.Enabled := (ePOPServer.Text <> '') and (eUsername.Text <> '')
    and (ePassword.Text <> '');
end;

procedure TMainForm.cbSendFileClick(Sender: TObject);
begin
  if cbSendFile.Checked then
  begin
    if OpenDialog.Execute then
      cbSendFile.Caption := cbSendFile.Caption + ': '+OpenDialog.Filename
    else
      cbSendFile.Checked := False;
  end else 
    cbSendFile.Caption := '&Attach Text File';
end;

{Clear and repopulate MIME headers, using the component's DocInput property. A 
separate DocInput OLE object could also be used. See RFC1521/1522 for complete
information on MIME types.}
procedure TMainForm.CreateHeaders;
begin
  with SMTP1 do
  begin
    DocInput.Headers.Clear;
    DocInput.Headers.Add('To', eTo.Text);
    DocInput.Headers.Add('From', eHomeAddr.Text);
    DocInput.Headers.Add('CC', eCC.Text);
    DocInput.Headers.Add('Subject', eSubject.Text);
    DocInput.Headers.Add('Message-Id', Format('%s_%s_%s', [Application.Title,
      DateTimeToStr(Now), eHomeAddr.Text]));
    DocInput.Headers.Add('Content-Type', 'TEXT/PLAIN charset=US-ASCII');
  end; 
end;

{Send a simple mail message}
procedure TMainForm.SendMessage;
begin
  CreateHeaders;
  with SMTP1 do
    SendDoc(NoParam, DocInput.Headers, reMessageText.Text, '', '');
end;

{Send a disk file. Leave SendDoc's InputData parameter blank and 
specify a filename for InputFile to send the contents of a disk file. You can
use the DocInput event and GetData methods to do custom encoding (Base64, UUEncode, etc.) }
procedure TMainForm.SendFile(Filename: string);
begin
  CreateHeaders;
  with SMTP1 do
  begin
    DocInput.Filename := FileName;
    SendDoc(NoParam, DocInput.Headers, NoParam, DocInput.FileName, '');
  end;
end;

{Set global flag indicating recipients are addressable (this only ensures that the
address is in the correct format, not that it exists and is deliverable), then
send the text part of the message}
procedure TMainForm.SMTP1Verify(Sender: TObject);
begin
  SendMessage;
  RecvVerified := True;
end;

{Verify addressees, send text message in the Verify event, and if an attachment is 
specified, send it}
procedure TMainForm.SendBtnClick(Sender: TObject);
var
  Addressees: string;
begin
  if SMTP1.State = prcConnected then 
  begin
    RecvVerified := False;
    SMTPError := False;
    Addressees := eTo.Text;
  
    if eCC.Text <> '' then
      Addressees := Addressees + ', '+ eCC.Text;
    SMTP1.Verify(Addressees);

    {wait for completion of Verify-Text message send}
    while SMTP1.Busy do 
      Application.ProcessMessages;
    
    {Check global flag indicating addresses are in the correct format - if true,
    the text part of the message has been sent}
    if not RecvVerified then
    begin
      MessageDlg('Incorrect address format', mtError, [mbOK], 0);
      Exit;
    end
    else 
      if cbSendFile.Checked then 
        SendFile(OpenDialog.Filename);
  end
  else 
    MessageDlg('Not connected to SMTP server', mtError, [mbOK], 0);
end;

{SMTP component will call this event every time its connection state changes}
procedure TMainForm.SMTP1StateChanged(Sender: TObject; State: Smallint);
begin
  case State of
    prcConnecting:
      ConnectStatus.SimpleText := 'Connecting to SMTP server: '+SMTP1.RemoteHost+'...';
    prcResolvingHost:
      ConnectStatus.SimpleText := 'Resolving Host';
    prcHostResolved:
      ConnectStatus.SimpleText := 'Host Resolved';
    prcConnected:
      begin
        ConnectStatus.SimpleText := 'Connected to SMTP server: '+SMTP1.RemoteHost;
        SMTPConnectBtn.Caption := 'Disconnect';
      end;
    prcDisconnecting:
      ConnectStatus.SimpleText := 'Disconnecting from SMTP server: '+SMTP1.RemoteHost+'...';
    prcDisconnected:
      begin
        ConnectStatus.SimpleText := 'Disconnected from SMTP server: '+SMTP1.RemoteHost;
        SMTPConnectBtn.Caption := 'Connect';
      end;
   end;   
   eSMTPServer.Enabled := not (State = prcConnected);
   eHomeAddr.Enabled := not (State = prcConnected);
end;

{The DocInput event is called each time the DocInput state changes during a mail transfer. 
DocInput holds all the information about the current transfer, including the headers, the 
number of bytes transferred, and the message data itself. Although not shown in this example,
you may call DocInput's SetData method if DocInput.State = icDocData to encode the data before
each block is sent.}
procedure TMainForm.SMTP1DocInput(Sender: TObject;
  const DocInput: DocInput);
begin
  case DocInput.State of
    icDocBegin:
      SMTPStatus.SimpleText := 'Initiating document transfer';
    icDocHeaders:
      SMTPStatus.SimpleText := 'Sending headers';
    icDocData:
      if DocInput.BytesTotal > 0 then
        SMTPStatus.SimpleText := Format('Sending data: %d of %d bytes (%d%%)',
          [Trunc(DocInput.BytesTransferred), Trunc(DocInput.BytesTotal), 
           Trunc(DocInput.BytesTransferred/DocInput.BytesTotal*100)])
      else 
        SMTPStatus.SimpleText := 'Sending...';
    icDocEnd:
      if SMTPError then 
        SMTPStatus.SimpleText := 'Transfer aborted'
      else 
        SMTPStatus.SimpleText := Format('Mail sent to %s (%d bytes data)', [eTo.Text,
          Trunc(DocInput.BytesTransferred)]);
  end;
  SMTPStatus.Update;
end;

{The Error event is called whenever an error occurs in the background processing. In
addition to providing an error code and brief description, you can also access the SMTP
component's Errors property (of type icErrors, an OLE object) to get more detailed
information}
procedure TMainForm.SMTP1Error(Sender: TObject; Number: Smallint;
  var Description: WideString; Scode: Integer; const Source,
  HelpFile: WideString; HelpContext: Integer; var CancelDisplay: WordBool);
var
  I: Integer;  
  ErrorStr: string;
begin
  SMTPError := True;
  CancelDisplay := True;
  {Get extended error information}
  for I := 1 to SMTP1.Errors.Count do
    ErrorStr := Format(#13'(%s)', [SMTP1.Errors.Item(I).Description]);
  {Display error code, short and long error description}
  MessageDlg(Format('%d - %s%s', [Number, Description, Trim(ErrorStr)]), mtError, [mbOK], 0);
end;
  
{Unlike POP, SMTP does not require a user account on the host machine, so no user
authorization is necessary}
procedure TMainForm.SMTPConnectBtnClick(Sender: TObject);
begin
  if SMTP1.State = prcConnected then 
    SMTP1.Quit
  else 
  if SMTP1.State = prcDisconnected then
    begin
      SMTP1.RemoteHost := eSMTPServer.Text;  
      SMTPError := False; 
      SMTP1.Connect(NoParam, NoParam); 
   end;
end;

{Unlike SMTP, users must be authorized on the POP server. The component defines 
a special protocol state, popAuthorization, when it requests authorization. If 
authorization is successful, the protocol state changes to popTransaction and 
POP commands can be issued. Note that server connection is independent of the 
authorization state.}
procedure TMainForm.POP1ProtocolStateChanged(Sender: TObject;
  ProtocolState: Smallint);
begin
  case ProtocolState of
    popAuthorization:
      POP1.Authenticate(POP1.UserID, POP1.Password);
    popTransaction:
      ConnectStatus.SimpleText := Format('User %s authorized on server %s', [eUsername.Text,
        ePOPServer.Text]);
  end;
end;

{This event is called every time the connection status of the POP server changes}
procedure TMainForm.POP1StateChanged(Sender: TObject; State: Smallint);
begin
  case State of
    prcConnecting:
      ConnectStatus.SimpleText := 'Connecting to POP server: '+POP1.RemoteHost+'...';
    prcResolvingHost:
      ConnectStatus.SimpleText := 'Resolving Host';
    prcHostResolved:
      ConnectStatus.SimpleText := 'Host Resolved';
    prcConnected:
      begin
        ConnectStatus.SimpleText := 'Connected to POP server: '+POP1.RemoteHost;
        POPConnectBtn.Caption := 'Disconnect';
      end;        
    prcDisconnecting:                 
      ConnectStatus.SimpleText := 'Disconnecting from POP server: '+POP1.RemoteHost+'...';
    prcDisconnected:
      begin
        ConnectStatus.SimpleText := 'Disconnected from POP server: '+POP1.RemoteHost;
        POPConnectBtn.Caption := 'Connect';
      end;
   end;   
   ePOPServer.Enabled := not (State = prcConnected);
   eUsername.Enabled := not (State = prcConnected);
   ePassword.Enabled := not (State = prcConnected);
end;

{The Error event is called whenever an error occurs in the background processing. In
addition to providing an error code and brief description, you can also access the POP
component's Errors property (of type icErrors, an OLE object) to get more detailed
information}
procedure TMainForm.POP1Error(Sender: TObject; Number: Smallint;
  var Description: WideString; Scode: Integer; const Source,
  HelpFile: WideString; HelpContext: Integer; var CancelDisplay: WordBool);
var
  I: Integer;  
  ErrorStr: string;
begin
  POPError := True;
  CancelDisplay := True;
  if POP1.ProtocolState = popAuthorization then
    ConnectStatus.SimpleText := 'Authorization error';
  {Get extended error information}
  for I := 1 to POP1.Errors.Count do
    ErrorStr := Format(#13'(%s)', [POP1.Errors.Item(I).Description]);
  {Display error code, short and long error description}  
  MessageDlg(Format('%d - %s%s', [Number, Description, Trim(ErrorStr)]), mtError, [mbOK], 0);
end;

{POP requires a valid user account on the host machine}
procedure TMainForm.POPConnectBtnClick(Sender: TObject);
begin
  if (POP1.State = prcConnected) and (POP1.ProtocolState = popTransaction)
  and not POP1.Busy then 
  begin
    mReadMessage.Lines.Clear;
    POP1.Quit;
  end
  else 
    if POP1.State = prcDisconnected then
    begin
      POP1.RemoteHost := ePOPServer.Text;
      POP1.UserID := eUserName.Text;
      POP1.Password := ePassword.Text;
      POP1.Connect(NoParam, NoParam);
    end;
end;

{The DocOutput event is the just like the DocInput event in 'reverse'. It is called each time
the component's DocOutput state changes during retrieval of mail from the server. When the
state = icDocData, you can call DocOutput.GetData to decode each data block based on the MIME 
content type specified in the headers.}
procedure TMainForm.POP1DocOutput(Sender: TObject; const DocOutput: DocOutput);
var
  Buffer: WideString;
  I: Integer;
begin
  case DocOutput.State of
    icDocBegin:
      POPStatus.SimpleText := 'Initiating document transfer';
    icDocHeaders:
      begin
        POPStatus.SimpleText := 'Retrieving headers';
        for I := 1 to DocOutput.Headers.Count do
          mReadMessage.Lines.Add(DocOutput.Headers.Item(I).Name+': '+
            DocOutput.Headers.Item(I).Value);
      end;
    icDocData:
      begin
        POPStatus.SimpleText := Format('Retrieving data - %d bytes',
            [Trunc(DocOutput.BytesTransferred)]);
        Buffer := DocOutput.DataString;
        mReadMessage.Text := mReadMessage.Text + Buffer;
      end;
    icDocEnd:
      if POPError then 
        POPStatus.SimpleText := 'Transfer aborted'
      else
        POPStatus.SimpleText := Format('Retrieval complete (%d bytes data)',
          [Trunc(DocOutput.BytesTransferred)]);
  end;
  POPStatus.Update;
end;

{Retrieve message from the server}
procedure TMainForm.udCurMessageClick(Sender: TObject; Button: TUDBtnType);
begin
  if (POP1.State = prcConnected) and (POP1.ProtocolState = popTransaction) then
  begin
    POPError := False;
    mReadMessage.Lines.Clear;
    POP1.RetrieveMessage(udCurMessage.Position);
  end;
end;

{The RefreshMessageCount event is called whenever the RefreshMessageCount method is 
called, and also when a connection to the POP server is first made}
procedure TMainForm.POP1RefreshMessageCount(Sender: TObject;
  Number: Integer);
begin
  FMessageCount := Number;
  udCurMessage.Max := Number;
  udCurMessage.Enabled := Number <> 0;
  lMessageCount.Caption := IntToStr(Number);
  if Number > 0 then
  begin
    udCurMessage.Min := 1;
    udCurMessage.Position := 1;
    POP1.RetrieveMessage(udCurMessage.Position);
  end;
end;

end.
