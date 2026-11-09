unit Print;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TForm2 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    SEdit: TEdit;
    PEdit: TEdit;
    DMemo: TMemo;
    PMemo: TMemo;
    REdit: TEdit;
    CEdit: TEdit;
    UEdit: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.DFM}

procedure TForm2.Button1Click(Sender: TObject);
begin
    Visible:=False;
end;

end.
 