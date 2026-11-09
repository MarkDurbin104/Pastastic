unit FormDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TDetailForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Bevel1: TBevel;
    Label5: TLabel;
    Label6: TLabel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    edtUserName: TEdit;
    edtDomain: TEdit;
    edtFullName: TEdit;
    edtComment: TEdit;
    edtPassword: TEdit;
    edtConfirm: TEdit;
    cbxScript: TCheckBox;
    cbxAccountDisabled: TCheckBox;
    cbxHomDirReq: TCheckBox;
    cbxLocked: TCheckBox;
    cbxPasswordNotReq: TCheckBox;
    cbxCannotChange: TCheckBox;
    cbxNeverExpired: TCheckBox;
    edtLogonCount: TEdit;
    edtBadCount: TEdit;
    edtLastLogon: TEdit;
    edtLastLogoff: TEdit;
    edtHomeDir: TEdit;
    edtWorkstations: TEdit;
    lbxMemberOf: TListBox;
    lbxNotMemberOf: TListBox;
    btnToRight: TButton;
    btnToLeft: TButton;
    rgrLoc_Glob: TRadioGroup;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DetailForm: TDetailForm;

implementation

{$R *.DFM}

end.
