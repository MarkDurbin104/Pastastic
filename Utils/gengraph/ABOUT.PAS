unit About;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    AboutForm: TPanel;
    Panel3: TPanel;
    ProductName: TLabel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    OKButton: TBitBtn;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.DFM}

procedure TAboutBox.Timer1Timer(Sender: TObject);
begin
    ModalResult:=mrOK;
end;

end.
 
