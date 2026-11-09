unit gec10;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GeckoBrowser, StdCtrls;

type
  TForm1 = class(TForm)
    GeckoBrowser1: TGeckoBrowser;
    ListBox1: TListBox;
    lblProg: TLabel;
    lblProgMax: TLabel;
    procedure GeckoBrowser1LocationChange(Sender: TObject; const uri: string);
    procedure GeckoBrowser1ProgressChange(Sender: TObject; Progress,
      ProgressMax: Integer);
    procedure GeckoBrowser1StatusTextChange(Sender: TObject;
      aMessage: WideString);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormShow(Sender: TObject);
begin
  GeckoBrowser1.LoadURI('http://www.proiam.com', 0, '', '',  '');
end;

procedure TForm1.GeckoBrowser1StatusTextChange(Sender: TObject;
  aMessage: WideString);
begin
  ListBox1.Items.Add(aMessage);
  Application.ProcessMessages;
end;

procedure TForm1.GeckoBrowser1ProgressChange(Sender: TObject; Progress,
  ProgressMax: Integer);
begin
  lblProg.Caption := IntToStr(Progress);
  lblProgMax.Caption := IntToStr(ProgressMax);
  Application.ProcessMessages;
end;

procedure TForm1.GeckoBrowser1LocationChange(Sender: TObject;
  const uri: string);
begin
 showmessage(uri);
end;

end.
