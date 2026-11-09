unit FrontFU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AppEvnts, StdCtrls, ExtCtrls, OleCtrls, SHDocVw;

type
  TFront = class(TForm)
    ApplicationEvents1: TApplicationEvents;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure ApplicationEvents1Deactivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Front1:TFront;

implementation

{$R *.dfm}

procedure TFront.ApplicationEvents1Deactivate(Sender: TObject);
begin
   FormDeactivate(nil);
end;

procedure TFront.FormDeactivate(Sender: TObject);
begin
  if (Timer1.Tag and 1)=0 then
    SetForegroundWindow(Handle);
end;

procedure TFront.Timer1Timer(Sender: TObject);
var
  WebBrowser1:TWebBrowser;
begin
  Timer1.Interval:=1000;
  if (Timer1.Tag and 1)=0 then
  begin
    //Beep;
    Show();
    SetForegroundWindow(Handle);
  end
  else
  begin
    //Hide();
  end;
  if Timer1.Tag = 0 then
  begin
    WebBrowser1:=TWebBrowser.Create(nil);
    InsertControl(WebBrowser1);
    WebBrowser1.Align:=alClient;
    WebBrowser1.Navigate('http://www.proiam.com/demonstration/index.html');
  end;
  Timer1.Tag:=Timer1.Tag+1;
//  Application.BringToFront;
//  BringWindowToTop(Handle);
//  SetFocus;

end;

end.
