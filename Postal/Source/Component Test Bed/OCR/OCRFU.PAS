unit OCRFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask,SavePosFormU;

type
  TForm1 = class(TSavePosForm)
    MaskEdit1: TMaskEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    DataAvailable:String;
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
   DataAvailable:=MaskEdit1.Text;
end;

end.
