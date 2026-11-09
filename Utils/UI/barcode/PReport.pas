unit PReport;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Quickrep, ExtCtrls;

type
  TByVol = class(TForm)
    QuickReport1: TQuickReport;
    QRBand1: TQRBand;
    QRBand2: TQRBand;
    QRLabel1: TQRLabel;
    QRLabel2: TQRLabel;
    procedure QRBand2BeforePrint(var PrintBand: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ByVol: TByVol;

implementation

{$R *.DFM}

procedure TByVol.QRBand2BeforePrint(var PrintBand: Boolean);
begin
    QRLabel1.Caption:='Page '+IntToStr(QuickReport1.PageNumber);
end;

end.
 