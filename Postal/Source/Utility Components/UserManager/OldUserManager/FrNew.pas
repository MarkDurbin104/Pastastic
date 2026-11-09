{  Module          Manager NETAPI32
   Unit            Form
   Copyright(c)    Postal Solutions Limited 1998..1998
   Author          DDB
   Description     Create easy access to NETAPI32.DLL .
                              Original Release
}
unit FrNew;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TNewForm = class(TForm)
    btnOk: TButton;
    NameEdit: TEdit;
    Label1: TLabel;
    procedure NameEditChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NewForm: TNewForm;

implementation

{$R *.DFM}
{===============================================================================

<Synopsis>        Enable Ok button if information has been entered.

<Description>     Enable Ok button if information has been entered.

<Post state>      State of NameEdit.Text will change the state of btnok.Enabled.

________________________________________________________________________________}
procedure TNewForm.NameEditChange(Sender: TObject);
begin
  btnOk.Enabled := Trim(NameEdit.Text) <> '';
end;

end.
