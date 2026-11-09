{  Module          Manager NETAPI32
   Unit            Form
   Copyright(c)    Postal Solutions Limited 1998..1998
   Author          DDB
   Description     Create easy access to NETAPI32.DLL .
                              Original Release
}
unit FrProper;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, UserMan, NTCommon;

const
   K_PASSWORD = '********' ;
type
  TPropertyForm = class(TForm)
    UserNameEdit: TEdit;               // User Name.
    Label1: TLabel;                    // Lable.
    DomainEdit: TEdit;                 // User's Domain.
    Label2: TLabel;                    // Lable.
    FullNameEdit: TEdit;               // User's Full Name.
    Label3: TLabel;                    // Lable.
    CommentEdit: TEdit;                // User's Comment.
    Label4: TLabel;                    // Lable.
    Bevel1: TBevel;                    // Bevel.
    PasswordEdit: TEdit;               // User's password ( write only ).
    Label5: TLabel;                    // Lable.
    ConfirmEdit: TEdit;                // Confirm password.
    Label6: TLabel;                    // Label6.
    Bevel2: TBevel;                    // Bevel2.
    ScripComboBox: TCheckBox;          // State use user's Scrip ( Real only ).
    AccountDisabledComboBox: TCheckBox;// State user's account disabled.
    HomDirReqComboBox: TCheckBox;      // State user's home dir required.
    LockedComboBox: TCheckBox;         // State user's Lock out.
    PasswordNotReqComboBox: TCheckBox; // State user's password not required.
    CannotChangeComboBox: TCheckBox;   // State user's cannot change.
    NeverExpiredComboBox: TCheckBox;   // State user's never expired password.
    Bevel3: TBevel;                    // Bevel.
    LogonCountEdit: TEdit;             // Many times the user has log on.
    Label7: TLabel;                    // Label.
    BadCountEdit: TEdit;               // Many times the user fail the log on.
    Label8: TLabel;                    // Label.
    LastLogonEdit: TEdit;              // Last time user has logged on.
    Label9: TLabel;                    // Label.
    LastLogoffEdit: TEdit;             // Last time the user has logged off.
    Label10: TLabel;                   // Label.
    HomeDirEdit: TEdit;                // User's home path directory.
    WorkstationsEdit: TEdit;      //work station from which,the user can log on.
    Label11: TLabel;                   // Label.
    Label12: TLabel;                   // Label.
    OkButton: TButton;                 // Button to confirm the information.
    CancelButton: TButton;             // Button to cancel the operation.
    MemberOfListBox: TListBox;         // Member of groups that the user belong.
    NotMemberOfListBox: TListBox;   // Member of no groups that the user belong.
    ToRightButton: TButton;            // Button to pass groups to no member of.
    ToLeftButton: TButton;             // Button to pass groups to member of.
    Label13: TLabel;                   // Label.
    Label14: TLabel;                   // Label.
    Loc_GlobRadioGroup: TRadioGroup;   // To select local or global groups
    procedure OkButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ToRightButtonClick(Sender: TObject);
    procedure ToLeftButtonClick(Sender: TObject);
    procedure NotMemberOfListBoxClick(Sender: TObject);
    procedure OnControlChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure MoveItems(LBXSource, LBXDest: TListBox);
  end;

var
  PropertyForm: TPropertyForm;

implementation

{$R *.DFM}

Uses FrmMan;
{===============================================================================

<Synopsis>        Confirm information.

<Description>     Confirmation of the whole confirmation entered and save using
                  UserMan component.

<Post state>      if the password validation is alright it will save the
                  information entered.

________________________________________________________________________________}
procedure TPropertyForm.OkButtonClick(Sender: TObject);
var
  Opt: TUserFlags;
begin

  { PasswordEdit.Tag will be 1 if has been modified, in that case the program
      will validate than PasswordEdit.Text and ConfirmEdit.Text are equals }
  if ((PasswordEdit.Tag > 0) or (ConfirmEdit.Tag > 0)) and
     (PasswordEdit.Text <> ConfirmEdit.Text) then
       begin ShowMessage('Password and confirmation do not match !'); Exit; end;


  // Using UserMan component will actualiz the information ---------------------
  with ServerForm.UserMan do
    begin
    UserInfo.FullName := FullNameEdit.Text;
    UserInfo.Comment  := CommentEdit.Text;
    if PasswordEdit.Text <> K_PASSWORD then
      UserInfo.Password := PasswordEdit.Text;
    Opt := [];
    if  ScripComboBox.Checked then Opt := Opt + [F_SCRIPT];
    if  AccountDisabledComboBox.Checked then Opt := Opt + [F_ACCOUNTDISABLE];
    if  HomDirReqComboBox.Checked then Opt := Opt + [F_HOMEDIR_REQUIRED];
    if  LockedComboBox.Checked then Opt := Opt + [F_LOCKOUT];
    if  PasswordNotReqComboBox.Checked then Opt := Opt + [F_PASSWD_NOTREQD];
    if  CannotChangeComboBox.Checked then Opt := Opt + [F_PASSWD_CANT_CHANGE];
    if  NeverExpiredComboBox.Checked then Opt := Opt + [F_DONT_EXPIRE_PASSWD];
    UserInfo.Options := Opt;
    UserInfo.HomeDir := HomeDirEdit.Text;
    UserInfo.Workstations := WorkstationsEdit.Text;
    if ServerForm.LocalRadioButton.Checked then
      begin
      MemberOfLocal := MemberOfListBox.Items;
      end else
      begin
      MemberOfGlob := MemberOfListBox.Items;
      end;
    end;
  ModalResult := mrOk;
end;
{===============================================================================

<Synopsis>        Create and initialize the form.

<Description>     Create the form and initialize form properties using UserMan
                  component.

<Post state>      Fill information in from properties.

________________________________________________________________________________}
procedure TPropertyForm.FormCreate(Sender: TObject);
var
  i: integer;
begin
  with ServerForm.UserMan do
    begin
    UserNameEdit.Text  := UserName;
    DomainEdit.Text    := UserInfo.Domain;
    FullNameEdit.Text  := UserInfo.FullName;
    CommentEdit.Text   := UserInfo.Comment;
    PasswordEdit.Text  := K_PASSWORD;
    ConfirmEdit.Text   := K_PASSWORD;
    ScripComboBox.Checked          := F_SCRIPT in UserInfo.Options;
    AccountDisabledComboBox.Checked := F_ACCOUNTDISABLE in UserInfo.Options;
    HomDirReqComboBox.Checked       := F_HOMEDIR_REQUIRED in UserInfo.Options;
    LockedComboBox.Checked          := F_LOCKOUT in UserInfo.Options;
    PasswordNotReqComboBox.Checked  := F_PASSWD_NOTREQD in UserInfo.Options;
    CannotChangeComboBox.Checked    := F_PASSWD_CANT_CHANGE in UserInfo.Options;
    NeverExpiredComboBox.Checked    := F_DONT_EXPIRE_PASSWD in UserInfo.Options;
    LogonCountEdit.Text := IntToStr(UserInfo.LogonCount);
    BadCountEdit.Text   := IntToStr(UserInfo.BadPasswordCount);
    if UserInfo.LastLogon = cnst1970 then LastLogonEdit.Text := 'never'
      else LastLogonEdit.Text  := DateTimeToStr(UserInfo.LastLogon);
    if UserInfo.LastLogOff = cnst1970 then LastLogOffEdit.Text := 'never'
      else LastLogOffEdit.Text  := DateTimeToStr(UserInfo.LastLogoff);
    HomeDirEdit.Text      := UserInfo.HomeDir;
    WorkstationsEdit.Text := UserInfo.Workstations;

    // Assign both MemberOfListBox with the member
    // Assign NotMemberOfListBox with all of them.
    if ServerForm.LocalRadioButton.Checked then
      begin
      Loc_GlobRadioGroup.ItemIndex := 0;
      MemberOfListBox.Items.Assign(MemberOfLocal);
      NotMemberOfListBox.Items.Assign(LocalGroups);
      end else
      begin
      Loc_GlobRadioGroup.ItemIndex := 1;
      MemberOfListBox.Items.Assign(MemberOfGlob);
      NotMemberOfListBox.Items.Assign(GlobalGroups);
      end;
    end;

  // Delete from NotMemberOfListBox every group of MemberOfListBox.

  for i := 0 to MemberOfListBox.Items.Count - 1 do
    if NotMemberOfListBox.Items.IndexOf(MemberOfListBox.Items[i]) <> -1 then
      NotMemberOfListBox.Items.Delete(NotMemberOfListBox.Items.IndexOf(MemberOfListBox.Items[i]));
end;
{===============================================================================

<Synopsis>       Move Items between MemberOf and NotMemberOf.

<Description>    This procedure is using to move items between MemberOf and
                 NotMemberOf the procedure can be called swapping LBXSource
                 and LBXDest.

<Post state>     Will move one item From/To MemberOf To/From NotMemberOf.


<LBXSource>      TlistBox with  original source.

<LBXDest>        TListBox with destination source.


________________________________________________________________________________}
procedure TPropertyForm.MoveItems(LBXSource, LBXDest: TListBox);
var
  i, index: integer;
begin
  // Find the selected item and move it to destination source.
  for i := 0 to LBXSource.Items.Count - 1 do
    if LBXSource.Selected[i] then
      begin
      LBXDest.Items.AddObject(LBXSource.Items[i],LBXSource.Items.Objects[i]);
      end;
  // Delete the Item selected from the original source.
  for i := 0 to LBXDest.Items.Count - 1 do
    begin
    index := LBXSource.Items.IndexOf(LBXDest.Items[i]);
    if index <> -1 then LBXSource.Items.Delete(index);
    end;
  NotMemberOfListBoxClick(nil);
end;
{===============================================================================

<Synopsis>        Move items from MemberOf to NotMemberOf.

<Description>     Move Items from MemberOf to NotMemberOf using MoveItems
                  procedure.

<Post state>      Move the item selected from MemberOf to NotMemberOf.

________________________________________________________________________________}
procedure TPropertyForm.ToRightButtonClick(Sender: TObject);
begin
  MoveItems(MemberOfListBox, NotMemberOfListBox);
end;
{===============================================================================

<Synopsis>        Move Items from NotMemberOf to MemberOf.

<Description>     Move Items from NotMemberOf to MemberOf using MoveItems
                  procedure.

<Post state>      Move the item selected from NotMemberOf to MemberOf.

________________________________________________________________________________}
procedure TPropertyForm.ToLeftButtonClick(Sender: TObject);
begin
  MoveItems(NotMemberOfListBox, MemberOfListBox);
end;
{===============================================================================

<Synopsis>        Enable or disable right and left button.

<Description>     Enable or disable right and left button depended of
                  MemberOfListBox and NotMemberOfListBox.

<Post state>      Will set up ToRightButton.Enabled and ToLeftButton.Enabled.

________________________________________________________________________________}
procedure TPropertyForm.NotMemberOfListBoxClick(Sender: TObject);
begin
  ToRightButton.Enabled :=  MemberOfListBox.SelCount > 0;
  ToLeftButton.Enabled :=  NotMemberOfListBox.SelCount > 0;
end;
{===============================================================================

<Synopsis>       Set component property tag to know if has been changed.

<Description>    Tag property will be used with component such as password
                  and confirmation before saving.

<Post state>     Set Tag property to 1.

________________________________________________________________________________}
procedure TPropertyForm.OnControlChange(Sender: TObject);
begin
  (Sender as TComponent).Tag := 1;
end;

end.
