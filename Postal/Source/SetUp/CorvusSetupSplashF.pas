unit CorvusSetupSplashF;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TCorvusSetupSplashForm = class(TForm)
    CorvusImage: TImage;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CorvusSetupSplashForm: TCorvusSetupSplashForm;

implementation

{$R *.DFM}

procedure TCorvusSetupSplashForm.FormCreate(Sender: TObject);
begin
  Caption := Caption + ' - ' + Application.ExeName;
end;

end.
