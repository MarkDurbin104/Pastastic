unit Countdn;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls;

type
  TCountForm = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Label2: TLabel;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    Count:Integer;
  public
    { Public declarations }
  end;

var
  CountForm: TCountForm;

implementation

{$R *.DFM}

procedure TCountForm.Timer1Timer(Sender: TObject);
begin
    Dec(Count);
    Label2.caption:=IntToStr(Count)+' Seconds remaining';
    if Count <= 0 then ModalResult:=mrOK;
end;

procedure TCountForm.FormShow(Sender: TObject);
begin
   Count:=5;
end;

end.
 