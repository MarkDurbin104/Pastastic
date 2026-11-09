unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ComCtrls, OleCtrls, Menus, ExtCtrls, isp3;

const
  FTPServer = 0;
  Folder = 1;
  OpenFolder = 2;

type
  TMainForm = class(TForm)
    Bevel1: TBevel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    StatusBar: TStatusBar;
    FileList: TListView;
    DirTree: TTreeView;
    ConnectBtn: TSpeedButton;
    FTP: TFTP;
    RefreshBtn: TSpeedButton;
    MainMenu1: TMainMenu;
    FileMenu: TMenuItem;
    FileNewItem: TMenuItem;
    FileDeleteItem: TMenuItem;
    FileRenameItem: TMenuItem;
    N2: TMenuItem;
    FileExitItem: TMenuItem;
    View1: TMenuItem;
    ViewLargeItem: TMenuItem;
    ViewSmallItem: TMenuItem;
    ViewListItem: TMenuItem;
    ViewDetailsItem: TMenuItem;
    N1: TMenuItem;
    ViewRefreshItem: TMenuItem;
    FilePopup: TPopupMenu;
    DeleteItem: TMenuItem;
    RenameItem: TMenuItem;
    CopyItem: TMenuItem;
    Bevel2: TBevel;
    Label1: TLabel;
    Bevel3: TBevel;
    Bevel5: TBevel;
    Label2: TLabel;
    SaveDialog1: TSaveDialog;
    CopyButton: TSpeedButton;
    LargeBtn: TSpeedButton;
    SmallBtn: TSpeedButton;
    ListBtn: TSpeedButton;
    DetailsBtn: TSpeedButton;
    Tools1: TMenuItem;
    ToolsConnectItem: TMenuItem;
    ToolsDisconnectItem: TMenuItem;
    FileCopyItem: TMenuItem;
    PasteFromItem: TMenuItem;
    OpenDialog1: TOpenDialog;
    SmallImages: TImageList;
    procedure ConnectBtnClick(Sender: TObject);
    procedure FTPProtocolStateChanged(Sender: TObject;
      ProtocolState: Smallint);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FTPBusy(Sender: TObject; isBusy: Wordbool);
    procedure DirTreeChange(Sender: TObject; Node: TTreeNode);
    procedure RefreshBtnClick(Sender: TObject);
    procedure DirTreeChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure FTPStateChanged(Sender: TObject; State: Smallint);
    procedure Open1Click(Sender: TObject);
    procedure FileExitItemClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ViewLargeItemClick(Sender: TObject);
    procedure ViewSmallItemClick(Sender: TObject);
    procedure ViewListItemClick(Sender: TObject);
    procedure ViewDetailsItemClick(Sender: TObject);
    procedure ViewRefreshItemClick(Sender: TObject);
    procedure CopyItemClick(Sender: TObject);
    procedure ToolsDisconnectItemClick(Sender: TObject);
    procedure FileNewItemClick(Sender: TObject);
    procedure DeleteItemClick(Sender: TObject);
    procedure PasteFromItemClick(Sender: TObject);
    procedure FilePopupPopup(Sender: TObject);
    procedure FileMenuClick(Sender: TObject);
    procedure FileDeleteItemClick(Sender: TObject);
    procedure FTPListItem(Sender: TObject; const Item: FTPDirItem);
  private
    Root: TTreeNode;
    function CreateItem(const FileName, Attributes, Size, Date: Variant): TListItem;
    procedure Disconnect;
  public
    function NodePath(Node: TTreeNode): String;
  end;

var
  MainForm: TMainForm;
  UserName,
  Pwd: String;

implementation

{$R *.DFM}

uses ShellAPI, UsrInfo;

function FixCase(Path: String): String;
var
  OrdValue: byte;
begin
  if Length(Path) = 0 then exit;
  OrdValue := Ord(Path[1]);
  if (OrdValue >= Ord('a')) and (OrdValue <= Ord('z')) then
    Result := Path
  else
  begin
    Result := AnsiLowerCaseFileName(Path);
    Result[1] := UpCase(Result[1]);
  end;
end;

procedure TMainForm.ConnectBtnClick(Sender: TObject);
begin
  if FTP.State = prcConnected then
    Disconnect;
  ConnectForm := TConnectForm.Create(Self);
  try
    if ConnectForm.ShowModal = mrOk then
      with FTP, ConnectForm do
      begin
        UserName := UserNameEdit.Text;
        Pwd := PasswordEdit.Text;
        RemoteHost := RemoteHostEdit.Text;
        RemotePort := StrToInt(RemotePortEdit.Text);
        Connect(RemoteHost, RemotePort);
        Root := DirTree.Items.AddChild(nil, RemoteHost);
        Root.ImageIndex := FTPServer;
        Root.SelectedIndex := FTPServer;
        DirTree.Selected := Root;
      end;
  finally
    ConnectForm.Free;
  end;
end;

procedure TMainForm.FTPProtocolStateChanged(Sender: TObject;
  ProtocolState: Smallint);
begin
  case ProtocolState of
    ftpAuthentication: FTP.Authenticate(UserName, Pwd);
    ftpTransaction: FTP.List('/');
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FTP.Busy then
  begin
    FTP.Cancel;
    FTP.Quit;
    while FTP.Busy do
      Application.ProcessMessages;
  end;
end;

function TMainForm.CreateItem(const FileName, Attributes, Size, Date: Variant): TListItem;
var
  Ext: String;
  ShFileInfo: TSHFILEINFO;
begin
  Result := FileList.Items.Add;
  with Result do
  begin
    Caption := FixCase(Trim(FileName));
    if Size > 0 then
    begin
      if Size div 1024 <> 0 then
      begin
        SubItems.Add(IntToStr(Size div 1024));
        SubItems[0] := SubItems[0] + 'KB';
      end
      else
        SubItems.Add(Size);
    end
    else
      SubItems.Add('');
    if Attributes = '1' then
    begin
      SubItems.Add('File Folder');
      ImageIndex := 3;
    end
    else
    begin
      Ext := ExtractFileExt(FileName);
      ShGetFileInfo(PChar('c:\*' + Ext), 0, SHFileInfo, SizeOf(SHFileInfo),
        SHGFI_SMALLICON or SHGFI_SYSICONINDEX or SHGFI_TYPENAME);
      if Length(SHFileInfo.szTypeName) = 0 then
      begin
        if Length(Ext) > 0 then
        begin
          System.Delete(Ext, 1, 1);
          SubItems.Add(Ext + ' File');
        end
        else
          SubItems.Add('File');
      end
      else
        SubItems.Add(SHFileInfo.szTypeName);
      ImageIndex := SHFileInfo.iIcon;
    end;
    SubItems.Add(Date);
  end;
end;

procedure TMainForm.Disconnect;
begin
  FTP.Quit;
  Application.ProcessMessages;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  SHFileInfo: TSHFileInfo;
begin
  with DirTree do
  begin
    DirTree.Images := SmallImages;
    SmallImages.ResourceLoad(rtBitmap, 'IMAGES', clOlive);
  end;
  with FileList do
  begin
    SmallImages := TImageList.CreateSize(16,16);
    SmallImages.ShareImages := True;
    SmallImages.Handle := ShGetFileInfo('*.*', 0, SHFileInfo,
      SizeOf(SHFileInfo), SHGFI_SMALLICON or SHGFI_ICON or SHGFI_SYSICONINDEX);
    LargeImages := TImageList.Create(nil);
    LargeImages.ShareImages := True;
    LargeImages.Handle := ShGetFileInfo('*.*', 0, SHFileInfo,
      SizeOf(SHFileInfo), SHGFI_LARGEICON or SHGFI_ICON or SHGFI_SYSICONINDEX);
  end;
end;

procedure TMainForm.FTPBusy(Sender: TObject; isBusy: Wordbool);
begin
  if isBusy then
  begin
    Screen.Cursor := crHourGlass;
    FileList.Items.BeginUpdate;
    FileList.Items.Clear;
  end
  else
  begin
    Screen.Cursor := crDefault;
    FileList.Items.EndUpdate;
  end;
end;

function TMainForm.NodePath(Node: TTreeNode): String;
begin
  if Node = Root then
    Result := '.'
  else
    Result := NodePath(Node.Parent) + '/' + Node.Text;
end;

procedure TMainForm.DirTreeChange(Sender: TObject; Node: TTreeNode);
var
  NP: String;
begin
  if (FTP.State <> prcConnected) or FTP.Busy then exit;
  if Node <> nil then
  begin
    NP := NodePath(DirTree.Selected);
    FTP.List(NP);
    Label2.Caption := Format('Contents of: ''%s/''',[NP]);
  end;
end;

procedure TMainForm.RefreshBtnClick(Sender: TObject);
begin
  FTP.List(NodePath(DirTree.Selected));
end;

procedure TMainForm.DirTreeChanging(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
begin
  AllowChange := not FTP.Busy;
end;

procedure TMainForm.FTPStateChanged(Sender: TObject; State: Smallint);
begin
  with FTP, Statusbar.Panels[0] do
    case State of
      prcConnecting   : Text := 'Connecting';
      prcResolvingHost: Text := 'Connecting';
      prcHostResolved : Text := 'Host resolved';
      prcConnected    :
        begin
          Text := 'Connected to: ' + RemoteHost;
          ConnectBtn.Hint := 'Disconnect';
          FileNewItem.Enabled := True;
          ViewLargeItem.Enabled := True;
          ViewSmallItem.Enabled := True;
          ViewListItem.Enabled := True;
          ViewDetailsItem.Enabled := True;
          ViewRefreshItem.Enabled := True;
          ToolsDisconnectItem.Enabled := True;
          LargeBtn.Enabled := True;
          SmallBtn.Enabled := True;
          ListBtn.Enabled := True;
          DetailsBtn.Enabled := True;
          RefreshBtn.Enabled := True;
        end;
      prcDisconnecting: Text := 'Disconnecting';
      prcDisconnected :
        begin
          Text := 'Disconnected';
          ConnectBtn.Hint := 'Connect';
          DirTree.Items.Clear;
          FileNewItem.Enabled := False;
          ViewLargeItem.Enabled := False;
          ViewSmallItem.Enabled := False;
          ViewListItem.Enabled := False;
          ViewDetailsItem.Enabled := False;
          ViewRefreshItem.Enabled := False;
          ToolsDisconnectItem.Enabled := False;
          LargeBtn.Enabled := False;
          SmallBtn.Enabled := False;
          ListBtn.Enabled := False;
          DetailsBtn.Enabled := False;
          RefreshBtn.Enabled := False;
        end;
    end;
end;

procedure TMainForm.Open1Click(Sender: TObject);
begin
  FTP.Quit;
  DirTree.Items.BeginUpdate;
  try
    DirTree.Items.Clear;
  finally
    DirTree.Items.EndUpdate;
  end;
end;

procedure TMainForm.FileExitItemClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  Statusbar.Panels[0].Width := Width - 150;
end;

procedure TMainForm.ViewLargeItemClick(Sender: TObject);
begin
  FileList.ViewStyle := vsIcon;
end;

procedure TMainForm.ViewSmallItemClick(Sender: TObject);
begin
  FileList.ViewStyle := vsSmallIcon;
end;

procedure TMainForm.ViewListItemClick(Sender: TObject);
begin
  FileList.ViewStyle := vsList;
end;

procedure TMainForm.ViewDetailsItemClick(Sender: TObject);
begin
  FileList.ViewStyle := vsReport;
end;

procedure TMainForm.ViewRefreshItemClick(Sender: TObject);
begin
  DirTreeChange(nil, DirTree.Selected);
end;

procedure TMainForm.CopyItemClick(Sender: TObject);
begin
  SaveDialog1.FileName := FileList.Selected.Caption;
  if SaveDialog1.Execute then
    FTP.GetFile(NodePath(DirTree.Selected) + '/' + FileList.Selected.Caption,
      SaveDialog1.FileName);
end;

procedure TMainForm.ToolsDisconnectItemClick(Sender: TObject);
begin
  DisConnect;
end;

procedure TMainForm.FileNewItemClick(Sender: TObject);
var
  DirName: String;
begin
  if InputQuery('Input Box', 'Prompt', DirName) then
    FTP.CreateDir(NodePath(DirTree.Selected) + '/' + DirName);
end;

procedure TMainForm.DeleteItemClick(Sender: TObject);
begin
  if ActiveControl = DirTree then
    FTP.DeleteDir(NodePath(DirTree.Selected));
  if ActiveControl = FileList then
    FTP.DeleteFile(NodePath(DirTree.Selected) + '/' + FileList.Selected.Caption);
end;

procedure TMainForm.PasteFromItemClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    FTP.PutFile(OpenDialog1.FileName, NodePath(DirTree.Selected));
end;

procedure TMainForm.FilePopupPopup(Sender: TObject);
begin
  CopyItem.Enabled := (ActiveControl = FileList) and (FileList.Selected <> nil);
  PasteFromItem.Enabled := (ActiveControl = DirTree) and (DirTree.Selected <> nil);
  DeleteItem.Enabled := (ActiveControl = FileList) and (FileList.Selected <> nil);
  RenameItem.Enabled := (ActiveControl = FileList) and (FileList.Selected <> nil);
end;

procedure TMainForm.FileMenuClick(Sender: TObject);
begin
  FileCopyItem.Enabled := (ActiveControl = FileList) and (FileList.Selected <> nil);
  FileDeleteItem.Enabled := (ActiveControl = FileList) and (FileList.Selected <> nil);
  FileRenameItem.Enabled := (ActiveControl = FileList) and (FileList.Selected <> nil);
end;

procedure TMainForm.FileDeleteItemClick(Sender: TObject);
begin
  if (DirTree.Selected <> nil) and (FileList.Selected <> nil) then
    FTP.DeleteFile(FileList.Selected.Caption);
end;

procedure TMainForm.FTPListItem(Sender: TObject; const Item: FTPDirItem);
var
  Node: TTreeNode;
begin
  CreateItem(Item.FileName, Item.Attributes, Item.Size, Item.Date);
  if Item.Attributes = 1 then
    if DirTree.Selected <> nil then
     begin
       if DirTree.Selected <> nil then
         Node := DirTree.Selected.GetFirstChild
       else
         Node := nil;
       while Node <> nil do
         if AnsiCompareFileName(Node.Text, Item.FileName) = 0 then
           exit
         else
           Node := DirTree.Selected.GetNextChild(Node);
       if Node = nil then
       begin
         Node := DirTree.Items.AddChild(DirTree.Selected,
           Item.FileName);
         Node.ImageIndex := Folder;
         Node.SelectedIndex := OpenFolder;
       end;
     end
     else
       DirTree.Items.AddChild(Root, Item.FileName);
end;

end.
