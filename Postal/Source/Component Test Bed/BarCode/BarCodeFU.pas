unit BarCodeFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask,SavePosFormU;
const
   SM_XVIRTUALSCREEN       = 76;
   SM_YVIRTUALSCREEN       = 77; 
   SM_CXVIRTUALSCREEN      = 78;
   SM_CYVIRTUALSCREEN      = 79;
   SM_CMONITORS            = 80;
   SM_SAMEDISPLAYFORMAT    = 81;
   
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
