unit UserFormFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TUserForm = class(TForm)
    NameL: TLabel;
    PasswordL: TLabel;
    UserName: TEdit;
    Password: TEdit;
    OKButton: TButton;
    Image1: TImage;
    Title: TLabel;
    procedure OKButtonClick(Sender: TObject);
  private
  public
    UserGroup:String;
  end;

var
  UserForm: TUserForm;

implementation

{$R *.DFM}

procedure TUserForm.OKButtonClick(Sender: TObject);
begin
   ModalResult:=mrOK;
   if (UserName.Text = 'EMS') and (Password.Text = 'EMS') then
      UserGroup:='UGroup.EMS'
   else if (UserName.Text = 'REG') and (Password.Text = 'REG') then
      UserGroup:='UGroup.REG'
   else if (UserName.Text = 'CLK') and (Password.Text = 'CLK') then
      UserGroup:='UGroup.Clerk'
   else if (UserName.Text = 'SUP') and (Password.Text = 'SUP') then
      UserGroup:='UGroup.Supervisor'
   else
      ModalResult:=mrNone;
end;

end.
