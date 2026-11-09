unit UsersF;

interface

uses
  SavePosFormEx, StringUtil,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TUsersForm = class(TSavePosForm)
    UsersListBox: TListBox;
    BottomPanel: TPanel;
    GroupCheckBox: TCheckBox;
    SelectButton: TButton;
    Button1: TButton;
    procedure GroupCheckBoxClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure UsersListBoxDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  UsersForm: TUsersForm;

implementation

{$R *.DFM}
uses
  MainFU;

procedure TUsersForm.GroupCheckBoxClick(Sender: TObject);
var
  RealUserName : String;
  UserName : String;
  UserIndex : Integer;
  UserGroup : String;
  Workstation, Office : String;
  ClerkCode,ClerkOfficeCode,ClerkLevel:Integer;
begin
  For UserIndex := 0 to UsersListBox.Items.Count-1 do
  begin
    If GroupCheckBox.Checked  then
    begin
      UserName := UsersListBox.Items[UserIndex];
      Mainform.GetUserDetails(UserName,RealUserName,UserGroup,WorkStation,Office,ClerkCode,ClerkOfficeCode,ClerkLevel);
      UsersListBox.Items[UserIndex] := UsersListBox.Items[UserIndex] + ' - ' + UserGroup;
    end
    else
      If Pos(' - ', UsersListBox.Items[UserIndex]) > 0 then
        UsersListBox.Items[UserIndex] := DelimitedString(UsersListBox.Items[UserIndex],' - ', False);
  end;  //for
end;

procedure TUsersForm.FormShow(Sender: TObject);
begin
  GroupCheckBox.Checked := False;
end;

procedure TUsersForm.UsersListBoxDblClick(Sender: TObject);
begin
   ModalResult:=mrOK;
end;

end.

