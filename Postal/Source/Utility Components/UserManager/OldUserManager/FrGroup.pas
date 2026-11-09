{  Module          Manager NETAPI32
   Unit            Form
   Copyright(c)    Postal Solutions Limited 1998..1998
   Author          DDB
   Description     Create easy access to NETAPI32.DLL .
                              Original Release
}
unit FrGroup;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TGroupsForm = class(TForm)
    btnOK: TButton;                // Button to confirm information
    btnCancel: TButton;            // Button to cancel  and not save information
    MembersMemo: TMemo;            // To Edit information of members of the group
    Label1: TLabel;                // Lable
    DescriptionEdit: TEdit;        // Description of the group
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GroupsForm: TGroupsForm;

implementation

{$R *.DFM}
  Uses FrmMan;
{===============================================================================

<Synopsis>        Create and initialize the form.

<Description>     Create the form and initialize MembersMemo with
                  LocalGroupMember or GlobalGroupMember property of
                  UserMan component.

<Post state>      MembersMemo will be with information from UserMan component.

________________________________________________________________________________}
procedure TGroupsForm.FormCreate(Sender: TObject);
begin
  with ServerForm do
    begin
    { UserMan component has all information like LocalGroupMembers
      or GlobalGroupMembers }
    Self.Caption := Self.Caption + ' '+ GroupsListBox.Items[GroupsListBox.ItemIndex];
    if LocalRadioButton.Checked then
      begin
      MembersMemo.Lines.Assign(UserMan.LocalGroupMembers);
      DescriptionEdit.Text := UserMan.LocalGroupComment;
      end;
    if GlobalRadioButton.Checked then
      begin
      MembersMemo.Lines.Assign(UserMan.GlobalGroupMembers);
      DescriptionEdit.Text := UserMan.GlobalGroupComment;
      end;
    end;
end;
{===============================================================================

<Synopsis>        Save group information

<Description>     Save the information in MembersMemo and DescriptionEdit
                  using UserMan.

<Post State>      If confirm the operation will save the information of groups.

________________________________________________________________________________}
procedure TGroupsForm.btnOKClick(Sender: TObject);
begin
    { UserMan component will send the information to the network
      or GlobalGroupMembers }

  with ServerForm do
    begin
    if LocalRadioButton.Checked then
      begin
      UserMan.LocalGroupComment := DescriptionEdit.Text;
      UserMan.LocalGroupMembers := MembersMemo.Lines;
      end;
    if GlobalRadioButton.Checked then
      begin
      UserMan.GlobalGroupComment := DescriptionEdit.Text;
      UserMan.GlobalGroupMembers := MembersMemo.Lines;
      end;
    end;
end;

end.
