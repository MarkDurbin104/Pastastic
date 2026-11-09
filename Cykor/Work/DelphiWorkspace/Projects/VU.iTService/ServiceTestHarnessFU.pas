unit ServiceTestHarnessFU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,CommsControllerFU;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    CommsController:TCommsController;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  CommsController:=TCommsController.Create(nil);
  CommsController.Active:=True;
  Visible:=False;
  CommsController.Visible:=True;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  CommsController.Active:=false;
end;

end.
