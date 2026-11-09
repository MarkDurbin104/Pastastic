unit Shutform;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls,Lastscr;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    RebootNext:Boolean;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
procedure Cleanup; far; external 'SHUTDLL';
function NeedShut: Integer; far; external 'SHUTDLL';
function DoneExec: Integer; far; external 'SHUTDLL';

procedure TForm1.Timer1Timer(Sender: TObject);
begin
    if RebootNext = True then
    begin
       RebootNext:=False;
       Cleanup;
       LastForm.ShowModal;
    end;
    if NeedShut = 1 then  
        RebootNext:=True
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
    RebootNext:=False;
    Cleanup;
end;

end.
                                      