unit connect;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TConnectDlg = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    ServerEdit: TEdit;
    Button1: TButton;
    Button2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ConnectDlg: TConnectDlg;

implementation

{$R *.DFM}

end.
