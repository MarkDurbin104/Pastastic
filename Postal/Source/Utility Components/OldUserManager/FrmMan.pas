{  Module          Manager NETAPI32
   Unit            Form
   Copyright(c)    Postal Solutions Limited 1998..1998
   Author          DDB
   Description     Create easy access to NETAPI32.DLL .
                              Original Release
}
unit FrmMan;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UserMan, StdCtrls, NetApi32, AdvApi32, NTCommon, Menus, FrNew, FrGroup;

type
  TServerForm = class(TForm)
    UserMan: TUserMan;                 // UserMan component
    ComputersComboBox: TComboBox;      // List of connected computers
    Label1: TLabel;                    // Lable
    LocalRadioButton: TRadioButton;    // RadioButton for local groups
    GlobalRadioButton: TRadioButton;   // RadioButton for global groups
    GroupsListBox: TListBox;           // ListBox with names of groups
    Label2: TLabel;                    // Lable
    UsersListBox: TListBox;            // ListBox with names of users
    MainMenu1: TMainMenu;              // Main menu
    Menu1: TMenuItem;                  // Item of main menu
    NewUser1: TMenuItem;               // Item of main menu for new users
    NewGroup1: TMenuItem;              // Item of main menu for new groups
    N1: TMenuItem;                     // Line in main menu
    mniDelete: TMenuItem;              // Item of main menu to delte
    Propertiy1: TMenuItem;             // Item of main menu to access properties
    N2: TMenuItem;                     // Line of main menu
    Exit1: TMenuItem;                  // Item of main menu to exit
    procedure FormCreate(Sender: TObject);
    procedure LocalRadioButtonClick(Sender: TObject);
    procedure NewUser1Click(Sender: TObject);
    procedure NewGroup1Click(Sender: TObject);
    procedure GroupsListBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure Menu1Click(Sender: TObject);
    procedure mniDeleteClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Propertiy1Click(Sender: TObject);
    procedure UsersListBoxClick(Sender: TObject);
    procedure GroupsListBoxClick(Sender: TObject);
    procedure ComputersComboBoxChange(Sender: TObject);
    procedure ComputersComboBoxExit(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ServerForm: TServerForm;

implementation

uses FrProper;

{$R *.DFM}
{===============================================================================

<Synopsis>        Create the form

<Description>     Create, Initialize servers and users in main form

<Post state>      ComputerComboBox will be full of server's names
                  And all the information such as users and groups

________________________________________________________________________________}
procedure TServerForm.FormCreate(Sender: TObject);
var
  List: TStringList;
begin
           { Get the computer names accessible from the
                              computer which run the application --------------}

  List :=  UserMan.GetServers('');
  try
  ComputersComboBox.Items.Assign(List);
  finally
  List.Free;
  end;
  LocalRadioButtonClick(nil);
end;
{===============================================================================

<Synopsis>        Actualiz the informaton in the main form.

<Description>     Actualiz the informaton in GroupsListBox and UserListBox,
                     using UserMan component.

<Post state>      Change GroupListBox and UserListBox.

________________________________________________________________________________}
procedure TServerForm.LocalRadioButtonClick(Sender: TObject);
begin
   UserMan.MachineName := Trim(ComputersComboBox.Text);


   if LocalRadioButton.Checked then       // local groups from UserMan component
      GroupsListBox.Items.Assign(UserMan.LocalGroups)
   else
      if GlobalRadioButton.Checked then // globlal groups from UserMan component
         GroupsListBox.Items.Assign(UserMan.GlobalGroups);

   if GroupsListBox.Items.Count > 0 then     // Start position in GroupListbox -
      GroupsListBox.ItemIndex := 0;
   UsersListBox.Items.Assign(UserMan.Users); // Start position in UsersListbox -
   if UsersListBox.Items.Count > 0 then
      UsersListBox.ItemIndex := 0;
end;
{===============================================================================

<Synopsis>        Add a new user

<Description>     Create a form to enter the name of a new user

<Post state>      If the procedure has been successful, it will add a new user

________________________________________________________________________________}
procedure TServerForm.NewUser1Click(Sender: TObject);
begin
  with TNewForm.Create(nil) do
    try
    Caption := 'New user';
    if ShowModal = mrOk then
      begin
      UserMan.Users.Add(NameEdit.Text);
      LocalRadioButtonClick(nil);
      end;
    finally
    Free;
    end;
end;
{===============================================================================

<Synopsis>        Add a new group

<Description>     Create a form to enter the name of a new group.
                  The procedure will check the Local and Global radiobutton in
                  order to access to local or global groups.

<Post state>      if the procedure has been successful, it will add a new gruop

________________________________________________________________________________}
procedure TServerForm.NewGroup1Click(Sender: TObject);
begin
  with TNewForm.Create(nil) do
    try
      Caption := 'New user';
      if ShowModal = mrOk then
      begin
        if LocalRadioButton.Checked then UserMan.LocalGroups.Add(NameEdit.Text);
        if GlobalRadioButton.Checked then UserMan.GlobalGroups.Add(NameEdit.Text);
        LocalRadioButtonClick(nil);
      end;
    finally
      Free;
    end;

end;
{===============================================================================

<Synopsis>        Change the colors of the items in GroupList.

<Description>     Draw different colors for different states in GroupList.

<Post state>      Change the colors in GroupList.

________________________________________________________________________________}
procedure TServerForm.GroupsListBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  S: string;
begin
  with Control as TListBox do
    begin
    Canvas.Font.Assign(Font);
    with Canvas do
      if (odFocused in State) then
        begin Brush.Color := clActiveCaption; Font.Color   := clWhite end
      else
      if (odSelected in State) then
        begin Brush.Color := clGray; Font.Color   := clWhite end
      else begin Brush.Color := clWindow;   Font.Color   := clBlack; end;
    Canvas.FillRect(Rect);
    S := Items[Index];
    Canvas.TextRect(Rect, Rect.Left+1, Rect.Top, S);
    end;
end;
{===============================================================================

<Synopsis>        Enable or Disable propertis in main menu.

<Description>     Change enable Delete and property propertis checking
                  if GroupListBox or UserListBox have the focus.

<Post state>      Enable propertis of the main menu.

________________________________________________________________________________}
procedure TServerForm.Menu1Click(Sender: TObject);
begin
  mniDelete.Enabled := (ActiveControl = GroupsListBox) or (ActiveControl = UsersListBox);
  Propertiy1.Enabled := mniDelete.Enabled;
end;
{===============================================================================

<Synopsis>        Delete a user or a group, depence of the Radiobutton.

<Description>     Check the local and global radiobutton and the activecontrol
                     and once found the item then, delete it.

<Post state>      Actualiz the information in the form.

________________________________________________________________________________}
procedure TServerForm.mniDeleteClick(Sender: TObject);
begin
  if (ActiveControl = UsersListBox) and (UsersListBox.Items.Count > 0) then
    UserMan.Users.Delete(UsersListBox.ItemIndex)
  else
  if (ActiveControl = GroupsListBox) and (GroupsListBox.Items.Count > 0) then
    begin
    if LocalRadioButton.Checked then UserMan.LocalGroups.Delete(GroupsListBox.ItemIndex);
    if GlobalRadioButton.Checked then UserMan.GlobalGroups.Delete(GroupsListBox.ItemIndex);
    end;
  LocalRadioButtonClick(nil);
end;
{===============================================================================

<Synopsis>        Close the application.

<Description>     Close the application.

________________________________________________________________________________}
procedure TServerForm.Exit1Click(Sender: TObject);
begin
  Close;
end;
{===============================================================================

<Synopsis>        Show the propertis of Groups or users.

<Description>     Check the active control userlistbox and grouplistbox.
                     Access to all properties of users or groups depend
                     where the focus is.

<Post state>      Will open a form to access propertis where,
                     they can be changed.

________________________________________________________________________________}
procedure TServerForm.Propertiy1Click(Sender: TObject);
begin
 if (ActiveControl = UsersListBox) then
  with TPropertyForm.Create(nil) do
    try
    ShowModal;
    finally
    Free;
    end;

 if (ActiveControl = GroupsListBox) then
  with TGroupsForm.Create(nil) do
    try
    ShowModal;
    finally
    Free;
    end;
end;
{===============================================================================

<Synopsis>        Get The user name from the ListBox.

<Description>     Actualiz UserMan component getting the user name from the
                     listbox

<Post state>      Modify the value of UserName in UserMan component
                  with the Item selected in userlistbox.

________________________________________________________________________________}
procedure TServerForm.UsersListBoxClick(Sender: TObject);
begin
  UserMan.UserName := UsersListBox.Items[UsersListBox.ItemIndex];
end;
{===============================================================================

<Synopsis>        Select a local group name

<Description>     Set the local or global group name in UserMan component
                  Checking local and global radiobutton.

________________________________________________________________________________}
procedure TServerForm.GroupsListBoxClick(Sender: TObject);
begin
   if LocalRadioButton.Checked then
      UserMan.LocalGroupName := GroupsListBox.Items[GroupsListBox.ItemIndex];
   if GlobalRadioButton.Checked then
      UserMan.GlobalGroupName := GroupsListBox.Items[GroupsListBox.ItemIndex];
end;
{===============================================================================

<Synopsis>     Control if ComputersComboBox has change the information.

<Description>  Set tag to 1 if has been changed ComputersComboBox information.

________________________________________________________________________________}
procedure TServerForm.ComputersComboBoxChange(Sender: TObject);
begin
  (Sender as TControl).Tag := 1;
end;
{===============================================================================

<Synopsis>     Actualiz the information in the form and in UserMan component.

<Description>  if computer name has been change
               it would execute LocalRadioButtonClick procedure where,
               would refresh the form and Userman component.

<Post state>   UserMan component will be actuliz and the form information.

________________________________________________________________________________}
procedure TServerForm.ComputersComboBoxExit(Sender: TObject);
begin
  if ComputersComboBox.Tag > 0 then
    begin
    ComputersComboBox.Tag := 0;
    LocalRadioButtonClick(nil);
    end;
end;

end.
