unit UsrInfo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TConnectForm = class(TForm)
    Label1: TLabel;
    RemoteHostEdit: TEdit;
    Label2: TLabel;
    UserNameEdit: TEdit;
    PasswordEdit: TEdit;
    Label3: TLabel;
    RemotePortEdit: TEdit;
    Label4: TLabel;
    OkBtn: TButton;
    CancelBtn: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ConnectForm: TConnectForm;

implementation

{$R *.DFM}

end.

