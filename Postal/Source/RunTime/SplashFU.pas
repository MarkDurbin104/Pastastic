unit SplashFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TSplash = class(TForm)
    Image1: TImage;
    WarningLabel: TLabel;
  private
  public
  end;

var
  Splash: TSplash;

implementation

{$R *.DFM}

end.
