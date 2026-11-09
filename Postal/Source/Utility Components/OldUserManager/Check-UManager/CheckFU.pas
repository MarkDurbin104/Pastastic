unit CheckFU;

interface

uses
  ComObj,
  UManager_TLB,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;


type
  LPCWSTR = PWideChar;
  LPBYTE = ^Byte;
  PPointer = ^Pointer;

  TForm1 = class(TForm)
    Panel1: TPanel;
    CreateButton: TButton;
    DestroyButton: TButton;
    ManagerPanel: TPanel;
    ServerButton: TButton;
    ServerListBox: TListBox;
    UserButton: TButton;
    UserListBox: TListBox;
    ServerEdit: TEdit;
    ServerLable: TLabel;
    Panel2: TPanel;
    UserEdit: TEdit;
    Label1: TLabel;
    SaveUserButton: TButton;
    Bevel1: TBevel;
    ServerNameEdit: TEdit;
    ChgPasswordEdit: TEdit;
    FullNameEdit: TEdit;
    CommentEdit: TEdit;
    PassWordEdit: TEdit;
    LookOutEdit: TEdit;
    PasswordExpireEdit: TEdit;
    AccountDisableEdit: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    PDCButton: TButton;
    PDCEdit: TEdit;
    AddUserButton: TButton;
    DeleteUserButton: TButton;
    GetUserButton: TButton;
    Label10: TLabel;
    Label11: TLabel;
    PasswordNotRqrEdit: TEdit;
    HomeDirRqrEdit: TEdit;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    LogonEdit: TEdit;
    WrongLogOnEdit: TEdit;
    LastLogOnEdit: TEdit;
    LastLogOffEdit: TEdit;
    HomeDirEdit: TEdit;
    WorkStationEdit: TEdit;
    ScriptEdit: TEdit;
    DomainEdit: TEdit;
    StatusEdit: TEdit;
    LocalListBox: TListBox;
    GlobalListBox: TListBox;
    Button1: TButton;
    OldPasswordEdit: TEdit;
    NewPasswordEdit: TEdit;
    Label23: TLabel;
    Label24: TLabel;
    procedure CreateButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DestroyButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ServerButtonClick(Sender: TObject);
    procedure UserButtonClick(Sender: TObject);
    procedure ServerListBoxClick(Sender: TObject);
    procedure UserListBoxClick(Sender: TObject);
    procedure PDCButtonClick(Sender: TObject);
    procedure GetUserButtonClick(Sender: TObject);
    procedure SaveUserButtonClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FNetUser    : INetUser ;
    FNetManager : INetManager ;

  public
    { Public declarations }
  end;

var
  Form1: TForm1;



implementation


{$R *.DFM}

procedure TForm1.CreateButtonClick(Sender: TObject);
begin

    if FNetUser = nil then
      FNetUser := CreateOleObject( 'Umanager.NetUser' ) as INetUser ;
    if FNetManager = nil then
      FNetManager := CreateOleObject( 'Umanager.NetManager' ) as INetManager ;

   CreateButton.Enabled := FALSE ;
   DestroyButton.Enabled := TRUE ;   
   ManagerPanel.Enabled := TRUE ;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   DestroyButton.Enabled := FALSE ;
   ManagerPanel.Enabled  := FALSE ;
end;

procedure TForm1.DestroyButtonClick(Sender: TObject);
begin
   CreateButton.Enabled  := TRUE ;
   DestroyButton.Enabled := FALSE ;
   ManagerPanel.Enabled  := FALSE ;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin

   if FNetUser <> nil then
      FNetUser := nil ;

   if FNetManager <> nil then
      FNetManager := nil ;

end;

procedure TForm1.ServerButtonClick(Sender: TObject);
begin
   ServerListBox.Items.Commatext := FNetManager.GetServers ;
end;

{
GetUsers(const ServerName: WideString): WideString; safecall;
GetLocalGroups(const ServerName: WideString): WideString; safecall;
GetGlobalGroups(const ServerName: WideString): WideString; safecall;

GetUser(const ServerName, UserName: WideString): INetUser; safecall;
}
procedure TForm1.UserButtonClick(Sender: TObject);
begin

   UserListBox.Items.CommaText := FNetManager.GetUsers( ServerEdit.Text );

end;

procedure TForm1.ServerListBoxClick(Sender: TObject);
begin
   if ServerListBox.ItemIndex >= 0 then
   begin
      ServerEdit.Text := ServerListBox.Items[ ServerListBox.ItemIndex ] ;
      ServerNameEdit.Text := ServerEdit.Text  ;
   end ;

end;

procedure TForm1.UserListBoxClick(Sender: TObject);
begin
   if UserListBox.ItemIndex >= 0 then
      UserEdit.Text := UserListBox.Items[ UserListBox.ItemIndex ] ;

end;

procedure TForm1.PDCButtonClick(Sender: TObject);
begin
   PDCEdit.Text := FNetManager.GetPDC ; ;
end;

procedure TForm1.GetUserButtonClick(Sender: TObject);
begin

   with FNetUser do
   begin
      SetUser( ServerNameEdit.Text , UserEdit.Text );

      GetUserInformation ;

      ServerNameEdit.Text    := ServerName ;
      if CannotChangePassword then
        ChgPasswordEdit.Text := 'Y'
      else
        ChgPasswordEdit.Text := 'N';
      FullNameEdit.Text  := FullName ;
      CommentEdit.Text   := Comment ;
      PassWordEdit.Text  := '' ;
      if Lockout then
        LookOutEdit.Text := 'Y'
      else
        LookOutEdit.Text := 'N';

      if PasswordNeverExpired then
         PasswordExpireEdit.Text := 'Y'
      else
         PasswordExpireEdit.Text := 'N';

      if AccountDisable then
         AccountDisableEdit.Text := 'Y'
      else
         AccountDisableEdit.Text := 'N';

      if PasswordNotRequired then
         PasswordNotRqrEdit.Text := 'Y'
      else
         PasswordNotRqrEdit.Text := 'N';

      if HomeDirRequired then
         HomeDirRqrEdit.Text := 'Y'
      else
         HomeDirRqrEdit.Text := 'N' ;

      LogonEdit.Text      := IntToStr( LogonCount );
      WrongLogOnEdit.Text := IntToStr( WrongLogonCount );
      LastLogOnEdit.Text  := DateTimeToStr( LastLogon );
      LastLogOffEdit.Text := DateTimeToStr( LastLogOff );
      HomeDirEdit.Text    := HomeDir ;
      WorkStationEdit.Text:= WorkStation ;

      if Script then
        ScriptEdit.Text   := 'Y'
      else
        ScriptEdit.Text   := 'N';

      GlobalListBox.Items.CommaText := MemberOfGlobal ;
      LocalListBox.Items.CommaText  := MemberOfLocal  ;


   end ;

end;

procedure TForm1.SaveUserButtonClick(Sender: TObject);
begin

   with FNetUser do
   begin
      SetUser( ServerNameEdit.Text, UserEdit.Text );

      CannotChangePassword := ( ChgPasswordEdit.Text = 'Y' ) ;
      FullName := FullNameEdit.Text ;
      Comment := CommentEdit.Text   ;
      if PassWordEdit.Text <> '' then
         Password := PassWordEdit.Text ;
      Lockout := ( LookOutEdit.Text = 'Y' ) ;
      PasswordNeverExpired := ( PasswordExpireEdit.Text = 'Y' );
      AccountDisable       := ( AccountDisableEdit.Text = 'Y');
      PasswordNotRequired  := ( PasswordNotRqrEdit.Text = 'Y' );
      HomeDirRequired      := ( HomeDirRqrEdit.Text = 'Y' ) ;
      HomeDir              := HomeDirEdit.Text ;
      WorkStation          := WorkStationEdit.Text ;
      MemberOfGlobal       := LocalListBox.Items.CommaText ;
      MemberOfLocal        := GlobalListBox.Items.CommaText ;

   end ;


end;


procedure TForm1.Button1Click(Sender: TObject);
begin
   if FNetManager.ChangePassword( ServerNameEdit.Text, UserEdit.Text, OldPasswordEdit.Text, NewPasswordEdit.text ) then
      ShowMessage('Ok')
   else
      ShowMessage('Error changing password');
end;

end.



