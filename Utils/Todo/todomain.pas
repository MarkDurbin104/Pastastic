unit todomain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, Calendar;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Memo2: TMemo;
    Calendar1: TCalendar;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
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
    Button1.Caption:=IntToStr(Calendar1.Year-1);
    Button2.Caption:=IntToStr(Calendar1.Year+1);
    Button3.Caption:=IntToStr(Calendar1.Month-1);
    Button4.Caption:=IntToStr(Calendar1.Month+1);
    Memo1.Lines.LoadFromFile('TODO.TXT');
    Memo2.Lines.LoadFromFile('INFO.TXT');
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Memo1.Lines.SaveToFile('TODO.TXT');
    Memo2.Lines.SaveToFile('INFO.TXT');
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
     Calendar1.Month:=Calendar1.Month-1;
    Button1.Caption:=IntToStr(Calendar1.Year-1);
    Button2.Caption:=IntToStr(Calendar1.Year+1);
    Button3.Caption:=IntToStr(Calendar1.Month-1);
    Button4.Caption:=IntToStr(Calendar1.Month+1);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
     Calendar1.Month:=Calendar1.Month+1;
    Button1.Caption:=IntToStr(Calendar1.Year-1);
    Button2.Caption:=IntToStr(Calendar1.Year+1);
    Button3.Caption:=IntToStr(Calendar1.Month-1);
    Button4.Caption:=IntToStr(Calendar1.Month+1);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
    Calendar1.Year:=Calendar1.Year+1;
    Button1.Caption:=IntToStr(Calendar1.Year-1);
    Button2.Caption:=IntToStr(Calendar1.Year+1);
    Button3.Caption:=IntToStr(Calendar1.Month-1);
    Button4.Caption:=IntToStr(Calendar1.Month+1);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
    Calendar1.Year:=Calendar1.Year-1;
    Button1.Caption:=IntToStr(Calendar1.Year-1);
    Button2.Caption:=IntToStr(Calendar1.Year+1);
    Button3.Caption:=IntToStr(Calendar1.Month-1);
    Button4.Caption:=IntToStr(Calendar1.Month+1);
end;

end.
