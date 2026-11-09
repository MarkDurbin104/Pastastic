unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  StdCtrls,Inifiles,strutils, IdTCPServer, ExtCtrls, XPMan, Menus;

type
  TForm1 = class(TForm)
    EdHost: TEdit;
    EdPort: TEdit;
    BtConnect: TButton;
    LaStatus: TLabel;
    MemoLog: TMemo;
    IdTCPClient1: TIdTCPClient;
    LbCommands: TListBox;
    EdCurrentCommand: TEdit;
    BtSend: TButton;
    BtAddToMemo: TButton;
    BtSendNext: TButton;
    BtSendMemo: TButton;
    BtCopy: TButton;
    BtDel: TButton;
    EdTag: TEdit;
    BtStart: TButton;
    BtClear: TButton;
    edToolC: TEdit;
    EdToolF: TEdit;
    BtEnum: TButton;
    BtGet: TButton;
    BtChange: TButton;
    BtFind: TButton;
    lbFiles: TListBox;
    BtLoad: TButton;
    BtSave: TButton;
    BtRestore: TButton;
    BtClearLog: TButton;
    BtSaveLog: TButton;
    BtUp: TButton;
    BtDwn: TButton;
    IdTCPServer1: TIdTCPServer;
    LaServerStatus: TLabel;
    BtGCTA: TButton;
    BtAltChange: TButton;
    BtCopyProbe: TButton;
    EdExclude: TEdit;
    CbExclude: TCheckBox;
    CbFreeze: TCheckBox;
    Timer1: TTimer;
    Timer2: TTimer;
    XPManifest1: TXPManifest;
    cbMultiple: TCheckBox;
    TimerCTS: TTimer;
    CBStay: TCheckBox;
    CBWithRT: TCheckBox;
    CBWrist: TCheckBox;
    BtEnableUser: TButton;
    BTAbortE: TButton;
    cbError: TCheckBox;
    EdNewTool: TEdit;
    BtNewTool: TButton;
    cbToolError: TCheckBox;
    cbIncrementTool: TCheckBox;
    edListenPort: TEdit;
    BtF1: TButton;
    btFakeClose: TButton;
    BtF2: TButton;
    BtF3: TButton;
    BtF4: TButton;
    btFakeXon: TButton;
    btPCDMIS: TButton;
    btMetrolog: TButton;
    btError9: TButton;
    cbCircularMove: TCheckBox;
    cbModusFilter: TCheckBox;
    btQuartis: TButton;
    btLoop: TButton;
    la1: TLabel;
    edLoopTime: TEdit;
    TimerLoop: TTimer;
    la2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtConnectClick(Sender: TObject);
    procedure IdTCPClient1Connected(Sender: TObject);
    procedure IdTCPClient1Disconnected(Sender: TObject);
    procedure IdTCPClient1Status(ASender: TObject;
      const AStatus: TIdStatus; const AStatusText: String);
    procedure BtSendClick(Sender: TObject);
    procedure SendToIpp(MyMessage: string);
    function AddTag(base:String):String;
    procedure BtStartClick(Sender: TObject);
    procedure BtClearClick(Sender: TObject);
    procedure BtEnumClick(Sender: TObject);
    procedure BtGetClick(Sender: TObject);
    procedure BtSendMemoClick(Sender: TObject);
    procedure BtSendNextClick(Sender: TObject);
    procedure BtClearLogClick(Sender: TObject);
    procedure LbCommandsDblClick(Sender: TObject);
    procedure BtCopyClick(Sender: TObject);
    procedure BtAddToMemoClick(Sender: TObject);
    procedure BtDelClick(Sender: TObject);
    procedure BtUpClick(Sender: TObject);
    procedure BtDwnClick(Sender: TObject);
    procedure BtChangeClick(Sender: TObject);
    procedure BtFindClick(Sender: TObject);
    procedure MemoLogDblClick(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtRestoreClick(Sender: TObject);
    procedure BtSaveClick(Sender: TObject);
    procedure BtLoadClick(Sender: TObject);
    procedure lbFilesDblClick(Sender: TObject);
    procedure LbCommandsClick(Sender: TObject);
    procedure lbFilesClick(Sender: TObject);
    procedure EdCurrentCommandKeyPress(Sender: TObject; var Key: Char);
    procedure LbCommandsKeyPress(Sender: TObject; var Key: Char);
    procedure BtSaveLogClick(Sender: TObject);
    procedure IdTCPServer1Execute(AThread: TIdPeerThread);
    procedure IdTCPServer1Connect(AThread: TIdPeerThread);
    procedure IdTCPServer1Disconnect(AThread: TIdPeerThread);
    function  GetTag(s:string):string;
    function  GetType(s:string):char;
    procedure LbCommandsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtCTAClick(Sender: TObject);
    procedure BBtChange2Click(Sender: TObject);
    procedure BtCopyProbeClick(Sender: TObject);
    procedure CbFreezeClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure cbMultipleClick(Sender: TObject);
    procedure TimerCTSTimer(Sender: TObject);
    procedure CBStayClick(Sender: TObject);
    procedure BtEnableUserClick(Sender: TObject);
    procedure BTAbortEClick(Sender: TObject);
    procedure BtNewToolClick(Sender: TObject);
    procedure cbToolErrorClick(Sender: TObject);
    procedure cbErrorClick(Sender: TObject);
    procedure edListenPortExit(Sender: TObject);
    procedure BtF1Click(Sender: TObject);
    procedure btFakeCloseClick(Sender: TObject);
    procedure FakeXonClick(Sender: TObject);
    procedure BtError9Click(Sender: TObject);
    procedure BtF2Click(Sender: TObject);
    procedure BtF3Click(Sender: TObject);
    procedure BtF4Click(Sender: TObject);
    procedure btMetrologClick(Sender: TObject);
    procedure btPCDMISClick(Sender: TObject);
    procedure btQuartisClick(Sender: TObject);
    procedure btLoopClick(Sender: TObject);
    procedure TimerLoopTimer(Sender: TObject);

  private
    procedure SetStartCaption;
    procedure SetConnectCaption;
    procedure CommandInsert;
    function  CmdExtract(s:string):string;
    function  DoLog(s:string):Boolean;
    procedure Freeze(value:boolean);
    procedure LogIt(s:string);
    function  CheckForAmpersand: boolean;
    function  GetTimeStamp:string;
    procedure UpdateAdvanced;
    Procedure FakeAnswer(Answer:String);
    Procedure DecrementTag;
    procedure SendEMessage(WhatToSend:String;TypeString:String);
    procedure ExcludeFromLog(what:string);
    procedure  RemoveComment(var source:string);
    procedure FakeCompleteAnswer(var sTag:string; sWhat: string);
    procedure FakeProbeType(var sTag:string;sWhat:string);
    procedure FakeIgnoreAnswer(var sTag:string);
    procedure replaceCircularMoveByStraight(var s:string);
    procedure LogFake(what : string; prompt :string);
    procedure ApplyProtectedMode;

  public
    procedure SetServerStatus();
    procedure AnalyseAndWriteToIp(s:string; bFromServer:Boolean = false);
    procedure receive();
    procedure persist();
    procedure reload();
  end;

  TClientThread = class(TThread)
  private
  protected
     procedure Execute; override;
  end;

var
  Form1: TForm1;
  ClientThread: TClientThread;
  bConnected: Boolean;
  bSessionStarted: Boolean;
  ReceiveBuffer : string;
  IniFile:TInifile;
  SavedCmds :TStringList;
  ServerStatus: string;
  bAlreadyConnected: Boolean;
  ServerConnection: TiDTcpConnection;
  ReceivePrompt:string;
  CurrentTags:TStrings;
  LastCmdDeleted: string;
  LogFrozen: Boolean;
  ClearToSend:Boolean;
  CtsTimout  :Boolean;
  NoTimout  : Boolean;
  NoTimeStamp: Boolean;
  sErrorTag: string;
  bAdvanced:boolean;
  MemoTop,MemoHeight: integer;
  bMinimizeDone: boolean;
  hasFileBeenLoaded: boolean;
  bProtected: Boolean;
  bInLoop:Boolean;

  //bFakeProbeType: boolean;
  bCommandAdded: boolean;
  const
  AdvancedTop = 170;



implementation

{$R *.dfm}
function CtrlDown : Boolean;
var
   State : TKeyboardState;
begin
   GetKeyboardState(State) ;
   Result := ((State[vk_Control] And 128) <> 0) ;
end;

function ShiftDown : Boolean;
var
   State : TKeyboardState;
begin
   GetKeyboardState(State) ;
   Result := ((State[vk_Shift] and 128) <> 0) ;
end;

function AltDown : Boolean;
var
   State : TKeyboardState;
begin
   GetKeyboardState(State) ;
   Result := ((State[vk_Menu] and 128) <> 0) ;
end;

procedure TForm1.CommandInsert;
begin
lbCommands.Items.Insert(Lbcommands.ItemIndex,LastCmdDeleted);
end;

procedure TClientThread.Execute;
var a:integer;
begin
  while not Terminated do
  begin
    if not bConnected then
      Terminate
    else begin
    try
      if (form1.IdTCPClient1.Connected) then begin
        ReceiveBuffer := Form1.IdTCPClient1.ReadLn();
        Synchronize(Form1.Receive);
        end;
    except
    on EAccessViolation do a:=a+1;
    on EIdNotConnected do a:=a+1;
    on E : Exception do a:=a+1;
    end;
    end;
  end;
end;

function  TForm1.GetTag(s:string):string;
begin
s:= Trim(s);
result := LeftStr(s,5);
end;

function  TForm1.GetType(s:string): char;
begin
s:=Trim(s);
result := s[7];
end;

procedure Tform1.receive;
var
MyBuffer : string;
sTag : string;
TypeChar : char;
index: integer;
sTime:string;
bFaked:boolean;
sPrompt:string;
begin
bFaked := False;
MyBuffer := ReceiveBuffer;
 sTime := GetTimeStamp;
 if MyBuffer[7] = '&' then begin
   ClearToSend := True;
   TimerCts.Enabled := False;
 end;
 if MyBuffer[7] = '!' then begin
  if bInLoop  then btLoopClick(nil); // stop sending in loop
 end;

  if ServerConnection<>nil then begin
  sTag := GetTag(MyBuffer);
  TypeChar := GetType(MyBuffer);
  //new, V2.11
  if (sErrorTag <> '') and (TypeChar = '#')then begin

    if(sTag = sErrorTag) then begin
    if (cbError.Checked) then
      MyBuffer := sTag+' ! Error(2, 1006, PtMeas,"no Touch")'
      else if (cbToolError.Checked) then
      MyBuffer := sTag+' ! Error(2, 2100, PtMeas,"Tool not appropriate, Server initiated Tool Change")';

    bFaked := true;
    sErrorTag := '';
    cbError.Checked := false;
    cbToolError.Checked := false;
    end;
  end;
  ///////////////////////////////////////////////////////////
  index := CurrentTags.IndexOf(sTag);
  if (index = -1) then begin // not a current one
    ServerConnection.WriteLn(MyBuffer);
    if bFaked then sPrompt := '<F< ' else sPrompt := '<$< ';
    if DoLog(MyBuffer) then Logit(sTime+sPrompt+ MyBuffer);
    end else begin
    // this was sent by main form, do not send to our client !
    if TypeChar = '%' then begin // end of this current tag life ...
      CurrentTags.Delete(index);
      end;
    if DoLog(MyBuffer)then LogIt(sTime+'<<< '+ MyBuffer);
    end;
  end else begin
    if DoLog(MyBuffer)then LogIt(sTime+'<<< '+ MyBuffer);
    end;
end;

procedure Tform1.SetServerStatus;
begin
  LaServerStatus.Caption:=ServerStatus;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
i : integer;
begin
// init global vars
Application.NormalizeTopMosts;
//SetWindowPos(Form1.Handle,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE+SWP_NOSIZE);
SetWindowPos(Form1.Handle,0,0,0,0,0,SWP_NOMOVE+SWP_NOSIZE);

SavedCmds := TstringList.Create;
CurrentTags := TstringList.Create;
MemoTop := MemoLog.Top;
MemoHeight := MemoLog.Height;

reload; //get back persisted settings ....

//for i := 1 to  LbCommands.Count do begin  // save the internal buffer....
//  SavedCmds.Add(LbCommands.Items[i-1]);
//end;
bConnected := FALSE;
bSessionStarted := FALSE;
SetConnectCaption;
SetStartCaption;
ServerConnection := nil;
IdTcpServer1.Active := true;
ClearToSend := false;
UpdateAdvanced;

end;

procedure TForm1.reload();
var
i,count:integer;
s:string;

begin
IniFile := TInifile.Create('.//IppDiag.ini');
EdHost.Text := IniFile.ReadString('TCP/IP','Host','127.0.0.1');
EdPort.Text := IniFile.ReadString('TCP/IP','Port','1294');
EdCurrentCommand.Text := IniFile.ReadString('CurrentCommand','cmd','EnableUser()');
EdToolC.Text := IniFile.ReadString('Tool','C','Probe1');
EdToolF.Text := IniFile.ReadString('Tool','F','');
//misc
i := IniFile.ReadInteger('Misc','Advanced',0);
 if i=1 then bAdvanced := True else bAdvanced := false;
i := IniFile.ReadInteger('Misc','NoTimout',1);
 if i=1 then NoTimout := True else NoTimout := false;
i := IniFile.ReadInteger('Misc','NoTimeStamp',0);
 if i=1 then NoTimeStamp := True else NoTimeStamp := false;
i:= IniFile.ReadInteger('Misc','ModusFilter',0);
 if i=1 then cbModusFilter.Checked := True else cbModusFilter.Checked := false;
 i:= IniFile.ReadInteger('Misc','ReplaceCircularMoves',0);
 if i=1 then cbCircularMove.Checked := True else cbCircularMove.Checked := false;
i := IniFile.ReadInteger('Misc','Protected',0);
 if i=1 then bProtected := True else bProtected := false;
// comands
count := IniFile.ReadInteger('Commands','Count',0);
for i:=0 to Count -1 do begin
  str(i,s);
  trimleft(s);
  s := IniFile.ReadString('Commands',s,'');
  if s<>'' then SavedCmds.Add(s);
  end;
if count<>0 then BtRestoreClick(nil);
 // files
 count := IniFile.ReadInteger('CmdFiles','Count',0);
if count<>0 then lbFiles.Items.Clear;
for i:=0 to Count -1 do begin
  str(i,s);
  trimleft(s);
  s := IniFile.ReadString('CmdFiles',s,'');
  if s<>'' then LbFiles.Items.Add(s);
  end;
// window
Top := IniFile.ReadInteger('Window','Top',Top);
Left := IniFile.ReadInteger('Window','Left',Left);
Width :=  IniFile.ReadInteger('Window','Width',Width);
Height :=  IniFile.ReadInteger('Window','Height',Height);
// Server
i := IniFile.ReadInteger('RelayServer','Port',1295);
if (i = strtoint(edPort.Text)) then begin // prob: server and listen port cannot be the same
  i := i+1; // take next port then
  end;
edListenPort.Text := inttostr(i);
IdTcpServer1.DefaultPort := i;
// exclude zone
  EdExclude.Text := IniFile.ReadString('Exclude','String','');
  i:= IniFile.ReadInteger('Exclude','Enabled',0);
  if i=1 then CbExclude.Checked := True else cbExclude.Checked := false;

  ApplyProtectedMode;
end;

procedure TForm1.persist();
var
i:integer;
s:string;
begin
IniFile.WriteString('TCP/IP','Host',EdHost.Text);
IniFile.WriteString('TCP/IP','Port',EdPort.Text);
IniFile.WriteString('CurrentCommand','cmd',EdCurrentCommand.Text);
IniFile.WriteString('Tool','C',EdToolC.Text);
IniFile.WriteString('Tool','F',EdToolF.Text);
// cmd list zone
IniFile.EraseSection('Commands');
IniFile.WriteInteger('Commands','Count',lbCommands.Items.Count);
for i:=0 to lbCommands.Items.Count -1 do begin
  str(i,s);
  trimleft(s);
  IniFile.WriteString('Commands',s,lbCommands.Items[i]);
  end;
// files list zone

IniFile.EraseSection('CmdFiles');
IniFile.WriteInteger('CmdFiles','Count',LbFiles.items.Count);
for i:=0 to lbFiles.Items.Count -1 do begin
  str(i,s);
  trimleft(s);
  IniFile.WriteString('CmdFiles',s,lbFiles.Items[i]);
  end;
// window position/size

  IniFile.WriteInteger('Window','Top',Top);
  IniFile.WriteInteger('Window','Left',Left);
  IniFile.WriteInteger('Window','Width',Width);
  IniFile.WriteInteger('Window','Height',Height);
//relay server
  IniFile.WriteInteger('RelayServer','Port',IdTcpServer1.DefaultPort);
// exclude zone
  IniFile.WriteString('Exclude','String',EdExclude.Text);
  if CbExclude.Checked then i:=1 else i:=0;
  IniFile.WriteInteger('Exclude','Enabled',i);
// misc
  if NoTimout then i:=1 else i:=0;
  IniFile.WriteInteger('Misc','NoTimout',i);
  if NoTimeStamp then i:=1 else i:=0;
  IniFile.WriteInteger('Misc','NoTimeStamp',i);
  if bAdvanced then i:=1 else i:=0;
  IniFile.WriteInteger('Misc','Advanced',i);
   if cbModusFilter .Checked then i:=1 else i:=0;
  IniFile.WriteInteger('Misc','ModusFilter',i);
    if cbCircularMove .Checked then i:=1 else i:=0;
  IniFile.WriteInteger('Misc','ReplaceCircularMoves',i);
  IniFile.UpdateFile;
  sleep(200);
end;


procedure TForm1.BtConnectClick(Sender: TObject);
var
nPort, pos: Integer;

begin
if bConnected then begin
if bSessionStarted then begin
  BtStart.Click;
  sleep(900);
  end;
IdTCPClient1.Disconnect;
end else begin
// load IP and port then connect
IdTCPClient1.Host := EdHost.Text;
val(EdPort.Text,nPort,pos);
IdTCPClient1.Port := nPort;
try
IdTCPClient1.Connect(500);
ClientThread := TClientThread.Create(True);
ClientThread.FreeOnTerminate:=True;
ClientThread.Resume;

except
LaStatus.Caption := 'Error: Cannot connect ...';
ClearToSend := False;
end;
end;
end;

procedure TForm1.IdTCPClient1Connected(Sender: TObject);
var
state: String;
sTime:string;
begin
sTime := FormatDateTime('  dd.mmm.yyyy - hh.nn.ss.zzz',now);
state := 'Connected';
MemoLog.Lines.Add('---------- '+state+sTime );
bConnected := TRUE;
SetConnectCaption;
CbFreeze.Checked := False;
freeze(False);
ClearToSend := True;
end;

procedure TForm1.IdTCPClient1Disconnected(Sender: TObject);
var
state: String;
sTime:string;
begin
sTime := FormatDateTime('  dd.mmm.yyyy - hh.nn.ss.zzz',now);
state := 'Disconnected';
MemoLog.Lines.Add('---------- '+state+sTime);
bConnected := FALSE;
bSessionStarted := FALSE;
SetStartCaption;
SetConnectCaption;
if ServerConnection <>nil then begin
  ServerConnection.Disconnect;
  end;
ClearToSend := False;
end;



procedure TForm1.IdTCPClient1Status(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: String);
begin
 LaStatus.Caption:= AStatusText;
end;

procedure TForm1.BtSendClick(Sender: TObject);
var
sCommand:string;
begin
sCommand :=  EdCurrentCommand.Text;
RemoveComment(sCommand);
SendToIpp(sCommand);
end;

procedure TForm1.SendToIpp(MyMessage:String);
var
sToSend:string;
sTime:string;
begin
sToSend := AddTag(MyMessage);
 sTime:=GetTimeStamp;
LogIt(sTime+'>>> '+sToSend);
// now send to server
AnalyseAndWriteToIp(sToSend);

end;

function TForm1.AddTag(base:String):String;
var
sTag,sNewTag:string;
i,dummy:integer;
begin
val(EdTag.Text,i,dummy);
str(i,sTag);
//update field
str(i+1,sNewTag);
EdTag.Text := sNewTag;

sTag := trim(sTag);
base:= trim(base);

if (base[length(base)] = 'E') or (pos('E(',base)<>0) then begin
for i:=1 to 4-length(sTag) do sTag:='0'+sTag;
sTag:='E'+sTag;
end else begin
for i:=1 to 5-length(sTag) do sTag:='0'+sTag;
end;

Result := sTag +' '+base;

end;

procedure TForm1.BtStartClick(Sender: TObject);
begin
if bSessionStarted then begin
SendToIpp('EndSession()');
bSessionStarted := FALSE;
end else begin
SendToIpp('StartSession()');
bSessionStarted := TRUE;
end;
SetStartCaption;
end;

procedure TForm1.SetStartCaption;
begin
if bSessionStarted then begin
  BtStart.Caption := 'EndSession()';
  end else begin
  BtStart.Caption := 'StartSession()';
  end;
    BtSend.Enabled := bSessionStarted;
//    BtAddToMemo.Enabled:= bSessionStarted;
    BtSendNext.Enabled:= bSessionStarted and not cbMultiple.checked;
    BtSendMemo.Enabled:= bSessionStarted;
//    BtCopy.Enabled:= bSessionStarted;
//    BtDel.Enabled:= bSessionStarted;
    BtClear.Enabled:= bSessionStarted;
    BtEnum.Enabled:= bSessionStarted;
    BtGet.Enabled:= bSessionStarted;
    BtChange.Enabled:= bSessionStarted;
    BtFind.Enabled:= bSessionStarted;
    BtGCTA.Enabled:= bSessionStarted;
    BtAltChange.Enabled :=  bSessionStarted;
    BtEnableUser.Enabled := bSessionStarted;
    btAbortE.Enabled := bSessionStarted;
    btNewTool.Enabled := bSessionStarted;
    EdNewTool.Enabled := bSessionStarted;

end;

procedure TForm1.SetConnectCaption;

begin
if bConnected then begin
  BtConnect.Caption := 'Disconnect';
  end else begin
  BtConnect.Caption := 'Connect';
  end;
// now, set buttons active f(connect)
    BtStart.Enabled:= bConnected;
 
end;

procedure TForm1.BtClearClick(Sender: TObject);
begin
SendToIpp('ClearAllErrors()');
end;

procedure TForm1.BtEnumClick(Sender: TObject);
begin
SendToIpp('EnumTools()');
end;

procedure TForm1.BtGetClick(Sender: TObject);
  var
  command:string;
  begin

  command := 'Get(X(),Y(),Z()';
  if CBWithRT.Checked then begin
    command := command + ', R()';
    end;
  if CBWrist.Checked  then begin
    command := command + ', Tool.A(), Tool.B()';
    end;

command := Command +')';

SendToIpp(command)
end;

procedure TForm1.BtSendMemoClick(Sender: TObject);
var
command:string;
i:integer;
bOk :boolean;
label loop1;
begin
if cbMultiple.Checked then begin
  for i:=0 to lbCommands.Items.Count-1 do begin
    if lbCommands.Selected[i] then begin
loop1:
      bOK := CheckForAmpersand;
      if bOK then begin
         command := LbCommands.Items[i];
         RemoveComment(command);
         sendtoipp(command);
      end else begin
      //Application.MessageBox('Multiple sending interrupted','Error', MB_OK);
      //Break;
      sleep(100);
      Goto loop1;
      end;
    end;
  end;
end else begin
  i:= lbCommands.ItemIndex;
  if (i>=0) then begin
    command := LbCommands.Items[lbCommands.itemindex];
    RemoveComment(command);
    sendtoipp(command);
  end;
end;
end;

procedure TForm1.BtSendNextClick(Sender: TObject);
begin
BtSendMemoClick(sender);
lbCommands.ItemIndex := lbCommands.ItemIndex +1;
end;

procedure TForm1.BtClearLogClick(Sender: TObject);
begin
memolog.Clear;
cbFreeze.checked := False;
Freeze(False);
end;

procedure TForm1.LbCommandsDblClick(Sender: TObject);
begin
if (Ctrldown and BtCopy.Enabled) then BtCopyClick(Sender) else begin
if BtSendMemo.Enabled and not cbMultiple.Checked then BtSendMemoClick(Sender);
end;
end;

procedure TForm1.BtCopyClick(Sender: TObject);
var command:string;
i:integer;
begin
i:= lbCommands.ItemIndex;
if (i>=0) then begin
  command := LbCommands.Items[i];
  RemoveComment(command);
  edCurrentCommand.Text := command;
  end;
end;

procedure TForm1.BtAddToMemoClick(Sender: TObject);
begin
if Shiftdown then begin
  LastCmdDeleted := edCurrentCommand.Text;
  CommandInsert;
  end else begin
  LbCommands.Items.Add(edCurrentCommand.Text);
  bCommandAdded := true;
end
end;

procedure TForm1.BtDelClick(Sender: TObject);
var
i,j:integer;
begin
i := lbCommands.ItemIndex;
j := lbFiles.ItemIndex;
if (i>=0) and (j=-1) then begin
LastCmdDeleted := LbCommands.Items[i];
lbCommands.Items.Delete(i);
lbCommands.ItemIndex := i-1;
bCommandAdded := true;
end else if (j>=0) and (i=-1) then begin
lbFiles.Items.Delete(j);
lbFiles.ItemIndex := j-1;
end else begin
lbCommands.ItemIndex := -1;
lbFiles.ItemIndex := -1;
end;


end;

procedure TForm1.BtUpClick(Sender: TObject);
var
buffer: string;
i:integer;
begin
i := lbCommands.ItemIndex;
  if i>0 then begin
  LastCmdDeleted:= lbCommands.Items[i];
  buffer := lbCommands.Items[i-1];
  lbCommands.Items[i-1] := lbCommands.Items[i];
  lbCommands.Items[i] := buffer;
  lbCommands.ItemIndex := i-1;
  end;
end;

procedure TForm1.BtDwnClick(Sender: TObject);
var
buffer: string;
i,j:integer;
begin
j := lbCommands.Items.Count-1;
i := lbCommands.ItemIndex;
  if i<j then begin
  buffer := lbCommands.Items[i+1];
  lbCommands.Items[i+1] := lbCommands.Items[i];
  lbCommands.Items[i] := buffer;
  lbCommands.ItemIndex := i+1;
  end;
end;

procedure TForm1.BtChangeClick(Sender: TObject);
var
cmd,probe, probe2:string;
i:integer;
c:char;
begin
probe := edToolC.Text;
for i:=1 to length(probe) do begin
c:=probe[i];
if (c<>'"') and (c<>' ') then probe2 := probe2 + c;
end;
edToolC.Text := probe2;
cmd := 'ChangeTool("'+probe2+'")';
sendtoipp(cmd);
end;

procedure TForm1.BtFindClick(Sender: TObject);
var
cmd,probe, probe2:string;
i:integer;
c:char;
begin
probe := edToolF.Text;
for i:=1 to length(probe) do begin
c:=probe[i];
if (c<>'"') and (c<>' ') then probe2 := probe2 + c;
end;
edToolF.Text := probe2;
cmd := 'FindTool("'+probe2+'")';
sendtoipp(cmd);
end;

procedure TForm1.MemoLogDblClick(Sender: TObject);
var s, ToolName : string;
 LineNumber:integer;
 CopyStart:integer;
begin

LineNumber := memolog.Perform(EM_LINEFROMCHAR,-1,0);
s:= memolog.lines[LineNumber];

if (length(s)>27) then begin
  if( (s[27]='"') and (s[25] = '#') )then begin
    ToolName := RightStr(s,length(s)-26);
    if Ctrldown then
      edToolF.Text := ToolName
    else
      edToolC.Text := ToolName
  end
  else if (CtrlDown) then begin
    if s[25] = '#' then CopyStart := 25 else CopyStart := 24;
    edCurrentCommand.Text := RightStr(s, length(s)-CopyStart);
    if (AltDown) then
      BtAddToMemo.Click;
    end;
  end;
end;

procedure TForm1.FormClick(Sender: TObject);
begin
if not bProtected then begin

if ShiftDown and CtrlDown then begin
bAdvanced := not(bAdvanced);
UpdateAdvanced;
end;

lbCommands.ItemIndex := -1;
lbFiles.ItemIndex := -1;
Invalidate;
if (not bMinimizeDone) or ShiftDown then begin
  windowState := wsMinimized;
 // sleep(10);
  WindowState := wsNormal;
   bMinimizeDone :=True;
   end;
end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
IdTcpServer1.Active := False;
if not bCommandAdded then BtRestoreClick(Sender);
persist;
SavedCmds.Free;
CurrentTags.Free;
end;

procedure TForm1.BtRestoreClick(Sender: TObject);
begin
// sends the SavedCmds list to the cmdlist
lbCommands.Clear;
lbCommands.Items := SavedCmds;
hasFileBeenLoaded := false;
bCommandAdded := false;
end;

procedure TForm1.BtSaveClick(Sender: TObject);
var
count,i:integer;
openDialog : TOpenDialog;
myFile : TextFile;
sFile:String;
confirmationAnswer: integer;
begin
count := lbCommands.Items.Count;
if Shiftdown then begin
  openDialog := TOpenDialog.Create(self);
  openDialog.InitialDir := GetCurrentDir;
  openDialog.Title := 'Write Command List to file';
  openDialog.Filter :=
    'Text files|*.txt';
  if openDialog.Execute then sFile := openDialog.FileName;
try
  if sFile <> '' then begin
     if not AnsiContainsStr(UpperCase(sFile),'.TXT') then begin
      sFile := sFile+'.txt';
      end;
   AssignFile(myFile,sFile);
   ReWrite(myFile);
   for i:=0 to count -1 do begin
    writeln(myFile,lbCommands.Items[i]);
    end;
   CloseFile(myFile);
  end;
except
end;
end else begin
if hasFileBeenLoaded then begin
  confirmationAnswer := MessageDlg('Really want to replace previous command list by current one ?',mtConfirmation,mbOkCancel ,0);
  end;
  if ((confirmationAnswer = 1) or (hasFileBeenLoaded  = false)) then begin
    SavedCmds.Clear;
    hasFileBeenLoaded := FALSE;
    for i:=0 to count-1 do
      SavedCmds.Add(lbCommands.Items[i]);
    end;
end;
end;

procedure TForm1.BtLoadClick(Sender: TObject);
var
  openDialog : TOpenDialog;
  myFile : TextFile;
  s:string;
  sFile:String;
  i: integer;
  label
  skip;
begin
  i:=lbFiles.ItemIndex;
  if(i <>-1) then begin
    sFile := lbFiles.Items[i];
  end else begin
  openDialog := TOpenDialog.Create(self);
  openDialog.InitialDir := GetCurrentDir;
  openDialog.Options := [ofFileMustExist];
  openDialog.Title := 'Commands file to open';
  openDialog.Filter :=
    'Text files|*.txt;*.log|*.*|*.*';
  if openDialog.Execute then sFile := openDialog.FileName;
  end;
try
  if sFile <> '' then begin
   if not (AnsiContainsStr(UpperCase(sFile),'.TXT') or
     AnsiContainsStr(UpperCase(sFile),'.LOG')) then begin
    sFile := sFile+'.txt';
    end;
   AssignFile(myFile,sFile);
   Reset(myFile);
   lbCommands.Clear;
   hasFileBeenLoaded := True;
   while not Eof(myFile) do
   begin
     ReadLn(myFile,s);
     s := CmdExtract(s);
     if s<>'' then begin
      if AnsiContainsStr(s,'Session') then goto skip;
      lbCommands.Items.add(s);
      skip:
     end;
   end;
   CloseFile(myFile);
   if lbFiles.Items.IndexOf(sFile)= -1  then begin
    lbFiles.Items.Add(sFile);
    end;
  end;
except

end;
end;

procedure  TForm1.RemoveComment(var source:string);
var
semicPosition : integer;
begin
semicPosition := AnsiPos(';',source);
if semicPosition >0 then
  source := AnsiLeftStr(source,semicPosition-1);
end;

function TForm1.CmdExtract(s:String): String;
var
retstr: String;
i: integer;
InCmd: boolean;
PassedTimeStamp: boolean;
c:char;
TagStarted: boolean;
label
CmdExtEnd, Skip;
begin
retstr := '';
TagStarted := false;
PassedTimeStamp := false;
trim(s);
if s= '' then goto CmdExtEnd;
if (s[1] = ';') or (s[1] = #39)or (s[1] = '/') then goto CmdExtEnd; //skip comments
if AnsiContainsStr(s, '<<<')  then  goto CmdExtEnd;
if AnsiContainsStr(s, '<$<')  then  goto CmdExtEnd;
if AnsiContainsStr(s, '<F<')  then  goto CmdExtEnd;
if AnsiContainsStr(s, '>R>')  then  goto CmdExtEnd;
if AnsiContainsStr(s, '--')  then  goto CmdExtEnd;
//we have a valid string now, skip blanks,pass the '>', skip the tag and space
//and keep the rest .... done via a state machine.

// case of just commands: skip the following process if we have no '>'
if ((s[1] <> '>') and (s[15] <> '>')) then begin
retstr := s;
goto CmdExtEnd;
end;
// regular log file ....

InCmd :=False;
for i:=1 to length(s) do begin
  c := s[i];
  if InCmd then begin
    retstr := retstr+c;
    goto skip;
    end;
  if (c = ' ') or (c = #9) then goto skip;
  if (c = '>') or (c = '$') then begin
    PassedTimeStamp := true;
    goto skip;
    end;
  if (PassedTimeStamp and (c in ['0','1','2','3','4','5','6','7','8','9'])) then
    begin
    TagStarted := true;
    goto skip
    end;
  if (not TagStarted) and (c = 'E') then goto skip;
  if (not PassedTimeStamp) then goto skip;
  retstr := c; //1st real char of a cmd, start copying ....
  InCmd := true;
  skip:
  end; //of for loop
CmdExtEnd :
Result := retstr;
end;
procedure TForm1.lbFilesDblClick(Sender: TObject);
begin
btLoadClick(Sender);
end;

procedure TForm1.LbCommandsClick(Sender: TObject);
begin
lbFiles.ItemIndex := -1;
end;

procedure TForm1.lbFilesClick(Sender: TObject);
begin
lbCommands.ItemIndex := -1;
end;

procedure TForm1.EdCurrentCommandKeyPress(Sender: TObject; var Key: Char);
begin
if key=#13 then btSendClick(Sender)
end;


procedure TForm1.LbCommandsKeyPress(Sender: TObject; var Key: Char);
begin
if key=#13 then btSendNextClick(Sender)
end;

procedure TForm1.BtSaveLogClick(Sender: TObject);
 var
  saveDialog : TSaveDialog;
  myFile : TextFile;
  sFile:String;
  i: integer;
begin
  saveDialog := TSaveDialog.Create(self);
  saveDialog.InitialDir := GetCurrentDir;
//  openDialog.Options := [ofFileMustExist];
  saveDialog.Title := 'Write log to file';
  saveDialog.Filter := 'Text files|*.txt';
//  openDialog.Options :=
  if saveDialog.Execute then sFile := saveDialog.FileName;
try
  if sFile <> '' then begin
   if not AnsiContainsStr(UpperCase(sFile),'.TXT') then begin
      sFile := sFile+'.txt';
      end;
   AssignFile(myFile,sFile);
   ReWrite(myFile);
   for i:=0 to memolog.Lines.Count-1 do begin
    writeln(myFile,memolog.lines[i]);
    end;
   CloseFile(myFile);
  end;
except

end;
end;


procedure TForm1.IdTCPServer1Execute(AThread: TIdPeerThread);

var
s,s2: String;
i: Integer;
c:char;
sTime :string;
begin
ServerConnection := Athread.Connection;
while (true) do begin
  with AThread.Connection do begin
//    Athread.Connection.
    try
    s := ReadLn; //LF termin, 20ms timout
    if s<>'' then begin
       sTime:=GetTimeStamp;
    // now send to server
      if bConnected then begin
        s2:=''; // remove the backspaces - possible telnet client!
        for i:=1 to length(s) do begin
        c:= s[i];
        if c= #8 then begin
          if length(s2)>0 then begin
            s2 := AnsiLeftStr(s2,length(s2)-1); //remove left char
          end
        end else begin
          s2 := s2 + c;
        end;
        end;
      LogIt(sTime+'>$> '+s2);
      AnalyseAndWriteToIp(s2,true);
      end;
      end else begin
      LogIt('>$> ---------- timeout');
    end;
  finally
  end; //try
end; //with
end; //while
end;




procedure TForm1.IdTCPServer1Connect(AThread: TIdPeerThread);
var
  stime:string;
begin
sTime := FormatDateTime('  dd.mmm.yyyy - hh.nn.ss.zzz',now);
memolog.Lines.Add('---------- Client connected to our server'+stime);
CurrentTags.Clear;
if not bConnected then btConnect.Click
else bAlreadyConnected := True;
ServerStatus := 'Relaying from client';
SetServerStatus;
CbFreeze.Checked := False;
Freeze(False);
end;

procedure TForm1.IdTCPServer1Disconnect(AThread: TIdPeerThread);
var
  stime:string;
begin
sTime := FormatDateTime('  dd.mmm.yyyy - hh.nn.ss.zzz',now);
memolog.Lines.Add('---------- Client disconnected to our server'+Stime);
if (not bAlreadyConnected) and bConnected then btConnect.Click;
bAlreadyConnected := False;
ServerStatus := '';
SetServerStatus;
ServerConnection := nil;
CurrentTags.Clear;
end;

procedure TForm1.AnalyseAndWriteToIp(s:string;bFromServer:boolean);
var
sTag :string;
bHadGetType : boolean;
bHadSetAccel : boolean;
upcaseS: string;
begin
   bHadGetType := False;
   bHadSetAccel := False;
//if bFromServer then begin
   upcaseS := UpperCase(s);

  if AnsiContainsStr(upcaseS, 'STARTSESSION()')  then begin
    bSessionStarted := true;
    SetStartCaption;
    end;
  if AnsiContainsStr(upcaseS, 'ENDSESSION()')  then begin
    bSessionStarted := false;
    SetStartCaption;
   end;

  if (cbError.Checked or cbToolError.Checked) and AnsiContainsStr(upcaseS, 'PTMEAS(')  then begin
    sErrorTag := GetTag(s);
    end;
  if cbModusFilter.checked and AnsiContainsStr(upcaseS,'PROBETYPE') then begin
    sErrorTag := GetTag(s);
    bHadGetType := True;
    end;
  if cbModusFilter.checked and  AnsiContainsStr(upcaseS,'ACCEL') and AnsiContainsStr(upcaseS,'SETPROP') then begin
    sErrorTag := GetTag(s);
    bHadSetAccel := True;
    end;

  if (cbCircularMove.Checked) and (AnsiContainsStr(upcaseS, 'CZPOSITIONONSPHERE(') or AnsiContainsStr(upcaseS,'ARCPOINT'))  then begin
    replaceCircularMoveByStraight(s);
    logFake(s,'>R>');
    end;




    //end else begin  // here we have cmds sent internal.
  // in case we have a client, put the tags in list to avoid fwding answers to client
   if (ServerConnection <> nil) and not bFromServer then begin
    sTag := GetTag(s);
    if CurrentTags.IndexOf(s)=-1 then begin
        CurrentTags.Add(sTag);
        end;
    end;
//  end;
ClearToSend := False;
CtsTimout := False;


if bHadGetType then begin
  FakeProbeType(sErrorTag,s);
end
else if bHadSetAccel then begin
  FakeIgnoreAnswer(sErrorTag);
end
else begin
TimerCTS.Enabled := true;
IdTCPClient1.WriteLn(s);
end;
end;

procedure TForm1.LbCommandsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = 46) then btDelClick(Sender);
  if (key = 45) and (LastCmdDeleted<>'') then begin
    lbCommands.Items.Insert(Lbcommands.ItemIndex,LastCmdDeleted);
    end;
end;

procedure TForm1.BtCTAClick(Sender: TObject);
var
cmd,probe, probe2:string;
i:integer;
c:char;
begin
probe := edToolF.Text;
for i:=1 to length(probe) do begin
c:=probe[i];
if (c<>'"') and (c<>' ') then probe2 := probe2 + c;
end;
edToolF.Text := probe2;
cmd := 'GetChangeToolAction("'+probe2+'")';
sendtoipp(cmd);
end;

procedure TForm1.BBtChange2Click(Sender: TObject);
var
cmd,probe, probe2:string;
i:integer;
c:char;
begin
probe := edToolF.Text;
for i:=1 to length(probe) do begin
c:=probe[i];
if (c<>'"') and (c<>' ') then probe2 := probe2 + c;
end;
edToolF.Text := probe2;
cmd := 'ChangeTool("'+probe2+'")';
sendtoipp(cmd);
end;

procedure TForm1.BtCopyProbeClick(Sender: TObject);
var dummy: String;
begin
   if ShiftDown then
    if CtrlDown then begin //exchange
    dummy := EdToolF.Text;
    EdToolF.Text := EdToolC.Text;
    EdToolC.Text := dummy;
    end else
    EdToolC.Text := EdToolF.Text
   else
   EdToolF.Text := EdToolC.Text;
end;

procedure TForm1.CbFreezeClick(Sender: TObject);
begin
Freeze(CbFreeze.checked);
end;

function TForm1.DoLog(s:string):Boolean;
Var
Res : boolean;
begin
res := True;
if CbExclude.Checked then begin
  if AnsiContainsStr(s,trim(edExclude.text)) then begin
    res := False;
    Timer1.Enabled := True;
    CbExclude.Color := clRed;
    end;
end;
DoLog := Res;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
CbExclude.Color := clBtnFace;
end;

procedure TForm1.Freeze(value:boolean);
begin
LogFrozen := value;
if value then memoLog.color := clMoneyGreen
 else memoLog.color := clWindow;
end;

procedure TForm1.LogIt(s:string);
begin
if not LogFrozen then begin
  memolog.Lines.Add(s);
end else begin
  cbFreeze.Color := clRed;
  Timer2.Enabled := True;
end;

end;

function TForm1.GetTimeStamp:string;
var
stamp:string;
begin
stamp :='';
if (not NoTimeStamp)then
  stamp := FormatDateTime('hh.nn.ss:zzz  ',Now);

GetTimeStamp:=stamp;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
CbFreeze.color := clBtnFace;
end;



procedure TForm1.cbMultipleClick(Sender: TObject);
begin
lbcommands.MultiSelect := cbMultiple.Checked;
lbcommands.ExtendedSelect := cbMultiple.Checked;
btCopy.Enabled := not cbMultiple.Checked;
if not cbMultiple.Checked then btSendNext.enabled := btSend.Enabled
 else btSendNext.Enabled := False;
end;

function TForm1.CheckForAmpersand : boolean;
var
CheckResult:Boolean ;
begin
  CheckResult := False;
  if ClearToSend then CheckResult := true
  else begin
  while not (ClearToSend) and (not CtsTimout)do begin
    Application.ProcessMessages;
    end;
    CheckResult := ClearToSend;
  end;
CheckForAmpersand := CheckResult;
end;

procedure TForm1.TimerCTSTimer(Sender: TObject);
begin
if (not NoTimout) then begin
  CtsTimout := True;
  TimerCTS.Enabled := False;
  Application.messagebox('Timout sending command','Error',MB_OK);
end;
end;

procedure TForm1.CBStayClick(Sender: TObject);
begin
if CBStay.Checked then begin
    Application.NormalizeTopMosts;
SetWindowPos(Form1.Handle,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE+SWP_NOSIZE);
end else begin
SetWindowPos(Form1.Handle,HWND_NOTOPMOST,0,0,0,0,SWP_NOMOVE+SWP_NOSIZE);
end;

end;

procedure TForm1.BtEnableUserClick(Sender: TObject);
begin
SendToIpp('EnableUser()');
end;

procedure TForm1.BTAbortEClick(Sender: TObject);
begin
SendToIpp('AbortE()');
end;

procedure TForm1.BtNewToolClick(Sender: TObject);
var
MyBuffer,probe, probe2,Stime,sPrompt:string;
i:integer;
c:char;
root_s:string;
index_i:integer;

begin
sTime := GetTimeStamp;
probe := edNewTool.Text;

for i:=1 to length(probe) do begin
  c:=probe[i];
  if (c<>'"') and (c<>' ') then probe2 := probe2 + c;
  end;

edToolC.Text := probe2;

if ServerConnection<>nil then begin
  MyBuffer := 'E0000 # ChangeTool("'+probe2+'")';
  ServerConnection.WriteLn(MyBuffer);
  sPrompt := '<F< ';
  if DoLog(MyBuffer) then Logit(sTime+sPrompt+ MyBuffer);
  // now increment tool# if needed ....
  if(cbIncrementTool.Checked)then begin
    //split number after '_'
    i:= AnsiPos('_',probe2);
    if (i>0) then begin
      root_s := LeftStr(probe2,i);
      index_i:= StrToInt(RightStr(probe2,(Length(probe2)-i)))+1;
      edToolC.Text := root_s+IntToStr(index_i);
      edNewTool.Text := edToolC.Text;
      end;
    end;
  end;
end;

procedure TForm1.cbToolErrorClick(Sender: TObject);
begin
if (cbToolError.Checked) then cbError.Checked := false; // mutually exclusive errors
end;

procedure TForm1.cbErrorClick(Sender: TObject);
begin
if (cbError.Checked) then cbToolError.Checked := false; // mutually exclusive errors
end;

procedure TForm1.ApplyProtectedMode;
begin
if (bProtected  )then  begin // disable all controls short of savelog / clear log
 bAdvanced := False;
 UpdateAdvanced ;
    BtSend.Enabled := false;
    BtAddToMemo.Enabled:= false;
    BtSendNext.Enabled:= false;
    BtSendMemo.Enabled:= false;
    BtCopy.Enabled:= false;
    BtDel.Enabled:= false;
    BtClear.Enabled:= false;
    BtEnum.Enabled:= false;
    BtGet.Enabled:= false;
    BtChange.Enabled:= false;
    BtFind.Enabled:= false;
    BtGCTA.Enabled:= false;
    BtAltChange.Enabled :=  false;
    BtEnableUser.Enabled := false;
    btAbortE.Enabled := false;
    btNewTool.Enabled := false;
    EdNewTool.Enabled := false;
    btConnect.Enabled := false;
    btAbortE.Enabled  :=False ;
    BtUp.Enabled := false;
    BtDwn.Enabled := false;
    BtSave.Enabled := False;
    BtRestore.Enabled := False;
    BtCopyProbe.Enabled := False;
    BtLoad.Enabled := False;
    btPCDMIS.Enabled := False;
    btMetrolog.Enabled := False;
    btQuartis.Enabled := False;

    EdHost.Enabled := False;
    EdPort.Enabled := False;
    EdCurrentCommand.Enabled := False;
    EdTag.Enabled := False;
    edToolC.Enabled := False;
    EdToolF.Enabled := False;

    LbCommands.Enabled := False;

    CbFreeze.Enabled := False;
    cbMultiple.Enabled := False;
    CbExclude.Enabled := False;
    CBWithRT.Enabled := False;
    CBWrist.Enabled := False;

    CBStay.Checked := false; // risk of file save dialog hidden !
    CBStay.Enabled := False;

    Form1.Caption := form1.Caption + '   *** PROTECTED MODE ***';

end

end;

procedure TForm1.UpdateAdvanced;
//var
begin
btF1.Visible:=bAdvanced;
btF2.Visible:=bAdvanced;
btF3.Visible:=bAdvanced;
btF4.Visible:=bAdvanced;
cbError.Visible:= bAdvanced;
cbToolError.Visible:= bAdvanced;
edNewTool.Visible:= bAdvanced;
btNewTool.Visible:= bAdvanced;
cbIncrementTool.Visible := bAdvanced;
edListenPort.Visible := bAdvanced;
btFakeClose.Visible := bAdvanced;
btFakeXon.Visible := bAdvanced;
btError9.Visible := bAdvanced;
cbCircularMove.Visible  := bAdvanced;
cbModusFilter.Visible  := bAdvanced;
btLoop.Visible := bAdvanced;
edLoopTime.Visible := bAdvanced;

if (not bAdvanced) then begin //dynamic change ....
  MemoLog.Top := MemoTop;
  MemoLog.Height := MemoHeight;

end else begin //adavanced
  MemoLog.Top := AdvancedTop;
  MemoLog.Height := MemoHeight + (MemoTop - AdvancedTop); // keep bottom constant
end;
Form1.Repaint;
end;


procedure TForm1.edListenPortExit(Sender: TObject);
var
st_saved:String;
begin
st_saved := LaStatus.Caption;
if (strtoint(edListenPort.Text) = strtoint(EdPort.Text)) then begin
  LaStatus.Caption:='Err: PORT #';
  end else
if(trim(ServerStatus) = '') then begin
  LaStatus.Caption:='Server Reset';
  IdTcpServer1.Active := false;
  IdTcpServer1.Bindings.Clear;
  IdTcpServer1.DefaultPort := strtoint(edListenPort.Text);
  IdTcpServer1.Active := true;
end else begin
  LaStatus.Caption:='Err: Server Connected';
end;
form1.Repaint;
sleep(800);
LaStatus.Caption:=st_saved;
EdListenPort.text := inttostr(IdTcpServer1.DefaultPort);
end;

procedure TForm1.SendEMessage(WhatToSend:String;TypeString:String);
var
MyBuffer,Stime,sPrompt:string;
begin
sTime := GetTimeStamp;
 if ServerConnection<>nil then begin
  MyBuffer := 'E0000 '+TypeString+' '+ WhatToSend;
  ServerConnection.WriteLn(MyBuffer);
  sPrompt := '<F< ';
  if DoLog(MyBuffer) then Logit(sTime+sPrompt+ MyBuffer);
  end;
end;


procedure TForm1.BtF1Click(Sender: TObject);
begin
SendEMessage('KeyPress("F1")','#');
end;

Procedure TForm1.FakeAnswer(Answer:String);
var
MyBuffer,sPrompt:string;
begin
 if ServerConnection<>nil then begin
  MyBuffer := AddTag(Answer);
  ServerConnection.WriteLn(MyBuffer);
  LogFake(MyBuffer, '<F<')
//  sPrompt := '<F< ';
//  if DoLog(MyBuffer) then Logit(sTime+sPrompt+ MyBuffer);
  end;
end;

procedure TForm1.LogFake(what : string; prompt :string);
var
Stime : string;
begin
sTime := GetTimeStamp;
if DoLog(what) then begin
  Logit(sTime+prompt+what)
  end;
end;


procedure TForm1.replaceCircularMoveByStraight(var s:string);
var x_pos:integer;
lastCommaPos : Integer;
arc_pos:Integer;
startArcArgPos : integer;
endArcArgPosition : integer;
endPositionStr: string;
sTag : string;
noflags : TReplaceFlags;
begin

sTag := GetTag(s);
if AnsiContainsStr(s,'ArcPoint') then begin
// find ArcPoint previous comma
arc_pos := Pos('Arc',s);
startArcArgPos := LastDelimiter(',',LeftStr (s,arc_pos));
endArcArgPosition := arc_pos + Pos(')',RightStr(s,Length(s)-arc_pos)) ;
s:=leftstr(s,startArcArgPos-1)+ rightstr(s,length(s)-endArcArgPosition);
end else begin
// get the x y z end positions
x_pos := pos('x',s);
if x_pos > 0 then begin
  endPositionStr := RightStr(s,(length(s) - x_pos)+1);
// remove the last bit ",R(x))"
lastCommaPos :=  lastDelimiter(',',endPositionStr) -1 ;
if lastCommaPos >0 then begin
    endPositionStr := leftStr(endPositionStr,lastCommaPos);
    endPositionStr := StringReplace(endPositionStr,'x','X',noflags);
    endPositionStr := StringReplace(endPositionStr,'y','Y',noflags);
    endPositionStr := StringReplace(endPositionStr,'z','Z',noflags);
    s:= sTag+ ' GoTo('+EndPositionStr+')';
    end;
  end;
end;
end;

procedure TForm1.FakeCompleteAnswer(var sTag:string; sWhat:string);
begin
  EdTag.Text := sTag;
  FakeAnswer('&');
  DecrementTag();
  FakeAnswer(sWhat);
  DecrementTag();
  FakeAnswer('%');
end;

procedure TForm1.FakeIgnoreAnswer(var sTag:string);
begin
  EdTag.Text := sTag;
  FakeAnswer('&');
  DecrementTag();
  FakeAnswer('%');
end;

procedure TForm1.FakeProbeType(var sTag:string; sWhat: String);
begin
  if pos(sWhat,'Found')>0 then begin
  FakeCompleteAnswer(sTag,'# FoundTool.ProbeType(-1)');
  end else begin
  FakeCompleteAnswer(sTag,'# Tool.ProbeType(-1)');
  end;
end;

procedure Tform1.DecrementTag;
var
i,dummy:integer;
sTag,sNewTag:string;
begin
 val(EdTag.Text,i,dummy);
 str(i,sTag);
 str(i-1,sNewTag);
 EdTag.Text := sNewTag;
end;

procedure TForm1.btFakeCloseClick(Sender: TObject);
begin
 FakeAnswer('%');
 DecrementTag;
end;

procedure TForm1.FakeXonClick(Sender: TObject);
begin
 FakeAnswer('&');
 DecrementTag;
end;


procedure TForm1.btError9Click(Sender: TObject);
begin
 SendEMessage('Error(9, 0503, ,"Controller E-STOP Fatal Error")','!');
end;

procedure TForm1.BtF2Click(Sender: TObject);
begin
SendEMessage('KeyPress("F2")','#');
end;

procedure TForm1.BtF3Click(Sender: TObject);
begin
SendEMessage('KeyPress("F3")','#');
end;

procedure TForm1.BtF4Click(Sender: TObject);
begin
SendEMessage('KeyPress("F4")','#');
end;

procedure TForm1.ExcludeFromLog(what:String);
begin
EdExclude.Text:= what;
cbExclude.Checked := True;
end;

procedure TForm1.btMetrologClick(Sender: TObject);
begin
ExcludeFromLog('E0908 #');
end;

procedure TForm1.btPCDMISClick(Sender: TObject);
begin
ExcludeFromLog('E9003 #');
end;


procedure TForm1.btQuartisClick(Sender: TObject);
begin
ExcludeFromLog('E0001 #');
end;

procedure TForm1.btLoopClick(Sender: TObject);
begin
  if bSessionStarted then begin
  TimerLoop.Interval := StrToInt(edLoopTime.Text);
  if bInLoop  then begin
    TimerLoop.Enabled:=false;
    edLoopTime.Color:=clWindow  ;
    bInLoop := False;
    end else begin
     TimerLoopTimer(nil);
     TimerLoop.Enabled := True;
     edLoopTime.Color := clRed;
     bInLoop:=True;
    end;
  end;
 
end;

procedure TForm1.TimerLoopTimer(Sender: TObject);
begin
  if bConnected then BtSend.Click;
end;

end.
