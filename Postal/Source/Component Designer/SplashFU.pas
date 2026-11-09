unit SplashFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TSplash = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Splash: TSplash;

implementation
uses
   CDMain;
{$R *.DFM}

procedure TSplash.FormCreate(Sender: TObject);
begin
   Width:=Image1.Width;
   Height:=Image1.Height;
end;

procedure TSplash.FormActivate(Sender: TObject);
begin
   MainForm.SetFocus;
end;

end.
