unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Panel1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   if X <= 200 then
   begin
      if Panel1.Width <> 200 then
      begin
         Panel1.Width:=200;
         SetCaptureControl(Panel1);   
      end;
   end
   else
   begin
      Panel1.Width:=30;
      ReleaseCapture;      
   end;
end;                         

procedure TForm1.Panel1Click(Sender: TObject);
begin
   Panel1.Width:=30;
   ReleaseCapture;      
end;

end.
