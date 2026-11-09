unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, OleCtrls, StdCtrls, ComCtrls, ExtCtrls, Buttons, ActiveX, isp3;

const
  efListGroups = 0;
  efGetArticleHeaders = 1;
  efGetArticleNumbers = 2;
  efGetArticle = 3;

type
  TNewsForm = class(TForm)
    NNTP1: TNNTP;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    FileDisconnectItem: TMenuItem;
    FileConnectItem: TMenuItem;
    Panel1: TPanel;
    Bevel1: TBevel;
    StatusBar: TStatusBar;
    SmallImages: TImageList;
    Panel2: TPanel;
    NewsGroups: TTreeView;
    Bevel2: TBevel;
    Panel3: TPanel;
    Memo1: TMemo;
    Panel5: TPanel;
    Panel4: TPanel;
    ConnectBtn: TSpeedButton;
    RefreshBtn: TSpeedButton;
    Bevel3: TBevel;
    MsgHeaders: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    procedure FileConnectItemClick(Sender: TObject);
    procedure NNTP1ProtocolStateChanged(Sender: TObject;
      ProtocolState: Smallint);
    procedure NNTP1StateChanged(Sender: TObject; State: Smallint);
    procedure Exit1Click(Sender: TObject);
    procedure MsgHeadersDblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure NewsGroupsChange(Sender: TObject; Node: TTreeNode);
    procedure RefreshBtnClick(Sender: TObject);
    procedure FileDisconnectItemClick(Sender: TObject);
    procedure NNTP1Banner(Sender: TObject; const Banner: WideString);
    procedure NNTP1DocOutput(Sender: TObject; const DocOutput: DocOutput);
    procedure NNTP1Error(Sender: TObject; Number: Smallint;
      var Description: WideString; Scode: Integer; const Source,
      HelpFile: WideString; HelpContext: Integer;
      var CancelDisplay: WordBool);
    procedure NNTP1SelectGroup(Sender: TObject;
      const groupName: WideString; firstMessage, lastMessage,
      msgCount: Integer);
  private
    EventFlag: Integer;
    function NodePath(Node: TTreeNode): String;
  public
    Data: String;
  end;

var
  NewsForm: TNewsForm;
  Remainder: String;
  Nodes: TStringList;
  CurrentGroup: String;
  GroupCount: Integer;

implementation

uses Connect;

{$R *.DFM}

{ TParser }

type

  TToken = (etEnd, etSymbol, etName, etLiteral);

  TParser = class
  private
    FFlags: Integer;
    FText: string;
    FSourcePtr: PChar;
    FSourceLine: Integer;
    FTokenPtr: PChar;
    FTokenString: string;
    FToken: TToken;
    procedure SkipBlanks;
    procedure NextToken;
  public
    constructor Create(const Text: string; Groups: Boolean);
  end;

const
  sfAllowSpaces = 1;

constructor TParser.Create(const Text: string; Groups: Boolean);
begin
  FText := Text;
  FSourceLine := 1;
  FSourcePtr := PChar(Text);
  if Groups then
    FFlags := sfAllowSpaces
  else
    FFlags := 0;
  NextToken;
end;

procedure TParser.SkipBlanks;
begin
  while True do
  begin
    case FSourcePtr^ of
      #0:
        begin
          if FSourcePtr^ = #0 then Exit;
          Continue;
        end;
      #10:
        Inc(FSourceLine);
      #33..#255:
        Exit;
    end;
    Inc(FSourcePtr);
  end;
end;

procedure TParser.NextToken;
var
  P, TokenStart: PChar;
begin
  SkipBlanks;
  FTokenString := '';
  P := FSourcePtr;
  while (P^ <> #0) and (P^ <= ' ') do Inc(P);
  FTokenPtr := P;
  case P^ of
    '0'..'9':
      begin
        TokenStart := P;
        Inc(P);
        while P^ in ['0'..'9'] do Inc(P);
        SetString(FTokenString, TokenStart, P - TokenStart);
        FToken := etLiteral;
      end;
    #13: Inc(FSourceLine);
    #0:
      FToken := etEnd;
  else
    begin
      TokenStart := P;
      Inc(P);
      if FFlags = sfAllowSpaces then
        while not (P^ in [#0, #13, ' ']) do Inc(P)
      else
        while not (P^ in [#0, #13]) do Inc(P);
      SetString(FTokenString, TokenStart, P - TokenStart);
      FToken := etSymbol;
    end;
  end;
  FSourcePtr := P;
end;

function FirstItem(var ItemList: ShortString): ShortString;
var
  P: Integer;
begin
  P := AnsiPos('.', ItemList);
  if P = 0 then
  begin
    Result := ItemList;
    P := Length(ItemList);
  end
  else
    Result := Copy(ItemList, 1, P - 1);
  Delete(ItemList, 1, P);
end;

procedure AddItem(GroupName: ShortString);
var
  Index, i: Integer;
  Groups: Integer;
  Item: ShortString;
  TheNodes: TStringList;
begin
  Groups := 1;
  for i := 0 to Length(GroupName) do
    if GroupName[i] = '.' then
      Inc(Groups);
  TheNodes := Nodes;
  for i := 0 to Groups - 1 do
  begin
    Item := FirstItem(GroupName);
    Index := TheNodes.IndexOf(Item);
    if Index = -1 then
    begin
      Index := TheNodes.AddObject(Item, TStringList.Create);
      TheNodes := TStringList(TheNodes.Objects[Index]);
      TheNodes.Sorted := True;
    end
    else
      TheNodes := TStringList(TheNodes.Objects[Index]);
  end;
  Inc(GroupCount);
end;

procedure ParseGroups(Data: String);
var
  Parser: TParser;
  OldSrcLine: Integer;
begin
  Parser := TParser.Create(Data, True);
  OldSrcLine := 0;
  while Parser.FToken <> etEnd do
  begin
    if Parser.FSourceLine <> OldSrcLine then
    begin
      AddItem(Parser.FTokenString);
      OldSrcLine := Parser.FSourceLine;
    end;
    Parser.NextToken;
  end;
end;

procedure ParseHeaders(Data: String);
var
  Parser: TParser;
  MsgNo: LongInt;
  Header: String;
  OldSrcLine: Integer;
begin
  Parser := TParser.Create(Data, False);
  while Parser.FToken <> etEnd do
  begin
    MsgNo := StrToInt(Parser.FTokenString);
    OldSrcLine := Parser.FSourceLine;
    Parser.NextToken;
    Header := '';
    while (OldSrcLine = Parser.FSourceLine) do
    begin
      Header := Header + ' ' + Parser.FTokenString;
      Parser.NextToken;
      if Parser.FToken = etEnd then
        Break;
    end;
    NewsForm.MsgHeaders.Items.AddObject(Header, Pointer(MsgNo));
  end;
end;

procedure DestroyList(AList: TStringList);
var
  i: Integer;
begin
  for i := 0 to AList.Count - 1 do
    if AList.Objects[i] <> nil then
      DestroyList(TStringList(AList.Objects[i]));
  AList.Free;
end;

procedure BuildTree(Parent: TTreeNode; List: TStrings);
var
  i: Integer;
  Node: TTreeNode;
begin
  for i := 0 to List.Count - 1 do
    if List.Objects[i] <> nil then
    begin
      Node := NewsForm.NewsGroups.Items.AddChild(Parent, List[i]);
      Node.ImageIndex := 0;
      Node.SelectedIndex := 1;
      BuildTree(Node, TStrings(List.Objects[i]));
    end
    else
      NewsForm.NewsGroups.Items.AddChild(Parent, List[i]);
end;

function TNewsForm.NodePath(Node: TTreeNode): String;
begin
  if Node.Parent = nil then
    Result := Node.Text
  else
    Result := NodePath(Node.Parent) + '.' + Node.Text;
end;

procedure TNewsForm.FileConnectItemClick(Sender: TObject);
begin
  ConnectDlg := TConnectDlg.Create(Self);
  try
    if ConnectDlg.ShowModal = mrOk then
      with NNTP1 do
        Connect(ConnectDlg.ServerEdit.Text, RemotePort);
  finally
    ConnectDlg.Free;
  end;
end;

procedure TNewsForm.NNTP1ProtocolStateChanged(Sender: TObject;
  ProtocolState: Smallint);
begin
  case ProtocolState of
    nntpBase: ;
    nntpTransaction:
      begin
        EventFlag := efListGroups;
        Nodes := TStringList.Create;
        Nodes.Sorted := True;
        NNTP1.ListGroups;
      end;
  end;
end;

procedure TNewsForm.NNTP1StateChanged(Sender: TObject; State: Smallint);
begin
  with Memo1.Lines do
    case NNTP1.State of
      prcConnecting   : Add('Connecting');
      prcResolvingHost: Add('Resolving Host: ' + NNTP1.RemoteHost);
      prcHostResolved : Add('Host resolved');
      prcConnected    :
        begin
          Add('Connected to: ' + NNTP1.RemoteHost);
          Statusbar.Panels[0].Text := 'Connected to: ' + NNTP1.RemoteHost;
          ConnectBtn.Enabled := False;
          FileConnectItem.Enabled := False;
          RefreshBtn.Enabled := True;
        end;
      prcDisconnecting: Text := NNTP1.ReplyString;
      prcDisconnected :
        begin
          Statusbar.Panels[0].Text := 'Disconnected';
          Caption := 'News Reader';
          Label1.Caption := '';
          ConnectBtn.Enabled := True;
          FileConnectItem.Enabled := True;
          RefreshBtn.Enabled := False;
        end;
    end;
end;

procedure TNewsForm.Exit1Click(Sender: TObject);
begin
  if NNTP1.State <> prcDisconnected then
  begin
    if NNTP1.Busy then NNTP1.Cancel;
    NNTP1.Quit;
    while NNTP1.State <> prcDisconnected do
      Application.ProcessMessages;
  end;
  Close;
end;

procedure TNewsForm.MsgHeadersDblClick(Sender: TObject);
var
  Article: Integer;
begin
  if NNTP1.Busy then exit;
  EventFlag := efGetArticle;
  Memo1.Clear;
  if MsgHeaders.ItemIndex = -1 then exit;
  Caption := 'News Reader: ' + MsgHeaders.Items[MsgHeaders.ItemIndex];
  Article := Integer(MsgHeaders.Items.Objects[MsgHeaders.ItemIndex]);
  NNTP1.GetArticlebyArticleNumber(Article);
end;

procedure TNewsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if NNTP1.State <> prcDisconnected then
  begin
    if NNTP1.Busy then NNTP1.Cancel;  
    NNTP1.Quit;
    while NNTP1.State <> prcDisconnected do
      Application.ProcessMessages;
  end;
end;

procedure TNewsForm.NewsGroupsChange(Sender: TObject; Node: TTreeNode);
var
  NP: String;
begin
  if (NNTP1.State = prcConnected) and not NNTP1.Busy then
    with MsgHeaders do
    begin
      Items.BeginUpdate;
      try
        Items.Clear;
        Memo1.Lines.Clear;
        NP := NodePath(NewsGroups.Selected);
        Statusbar.Panels[2].Text := 'Bytes: 0';
        Statusbar.Panels[1].Text := '0 Article(s)';
        if NNTP1.Busy then
          NNTP1.Cancel;
        NNTP1.SelectGroup(NP);
        Label1.Caption := 'Contents of ''' + NP + '''';
      finally
        Items.EndUpdate;
      end;
    end;
end;

procedure TNewsForm.RefreshBtnClick(Sender: TObject);
begin
  if NewsGroups.Selected <> nil then
    NewsGroupsChange(nil, NewsGroups.Selected);
end;

procedure TNewsForm.FileDisconnectItemClick(Sender: TObject);
begin
  if NNTP1.Busy then NNTP1.Cancel;
  NNTP1.Quit;
  while NNTP1.Busy do
    Application.ProcessMessages;
  with NewsGroups.Items do
  begin
    BeginUpdate;
    Clear;
    EndUpdate;
  end;
  MsgHeaders.Items.Clear;
  Memo1.Lines.Clear;
end;

procedure TNewsForm.NNTP1Banner(Sender: TObject; const Banner: WideString);
begin
  Memo1.Lines.Add(Banner);
end;

procedure TNewsForm.NNTP1DocOutput(Sender: TObject;
  const DocOutput: DocOutput);
begin
  Statusbar.Panels[2].Text := Format('Bytes: %d',[DocOutput.BytesTransferred]);
  case DocOutput.State of
    icDocBegin:
      begin
        if EventFlag = efListGroups then
          Memo1.Lines.Add('Retrieving news groups...');
        Data := '';
        GroupCount := 0;
      end;
    icDocData:
      begin
        Data := Data + DocOutput.DataString;
        if EventFlag = efGetArticle then
          Memo1.Lines.Add(Data);
      end;
    icDocEnd:
      begin
        case EventFlag of
          efListGroups:
            begin
              ParseGroups(Data);
              Memo1.Lines.Add('Done.'#13#10'Building news group tree...');
              NewsGroups.Items.BeginUpdate;
              try
                BuildTree(nil, Nodes);
                DestroyList(Nodes);
                Statusbar.Panels[1].Text := Format('%d Groups',[GroupCount]);
              finally
                NewsGroups.Items.EndUpdate;
                Memo1.Lines.Add('Done.');
              end;
            end;
          efGetArticleHeaders: ParseHeaders(Data);
          efGetArticle:
            begin
              Memo1.SelStart := 0;
              SendMessage(Memo1.Handle, EM_ScrollCaret, 0, 0);
            end;
        end;
        SetLength(Data, 0);
      end;
  end;
  Refresh;
end;

procedure TNewsForm.NNTP1Error(Sender: TObject; Number: Smallint;
  var Description: WideString; Scode: Integer; const Source,
  HelpFile: WideString; HelpContext: Integer; var CancelDisplay: WordBool);
begin
//  MessageDlg(Description, mtError, [mbOk], 0);
end;

procedure TNewsForm.NNTP1SelectGroup(Sender: TObject;
  const groupName: WideString; firstMessage, lastMessage,
  msgCount: Integer);
begin
  EventFlag := efGetArticleHeaders;
  Statusbar.Panels[1].Text := Format('%d Article(s)',[msgCount]);
  NNTP1.GetArticleHeaders('subject', FirstMessage, lastMessage);
end;

end.
