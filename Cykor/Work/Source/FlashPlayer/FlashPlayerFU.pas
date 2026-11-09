unit FlashPlayerFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OleCtrls, ShockwaveFlashObjects_TLB;

type
  TForm1 = class(TForm)
    ShockwaveFlash1: TShockwaveFlash;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormShow(Sender: TObject);
begin
   ShockwaveFlash1.AllowFullScreen:='true';
end;

end.
