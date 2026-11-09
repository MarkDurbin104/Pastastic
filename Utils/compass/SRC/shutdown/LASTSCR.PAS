unit Lastscr;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls;

type
  TLastForm = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    Count:Integer;
  public
    { Public declarations }
  end;

var
  LastForm: TLastForm;

implementation

{$R *.DFM}

procedure TLastForm.Timer1Timer(Sender: TObject);
begin
   if Count < 0 then
   begin
      Label1.Caption:='Close Other Applications and then press SHUTDOWN';
      Button1.Caption:='SHUTDOWN';
      Button1.Enabled:=True;
   end
   else
   begin
      Label1.Caption:='Windows will Shutdown in ' + IntToStr(Count-1) + ' Seconds';
      Button1.Caption:='Abort SHUTDOWN';
      if CmdLine[0] <> 'S' then Button1.Enabled:=False;
   end;                         
   Dec(Count);
   if Count = 0 then
      ExitWindows(EW_REBOOTSYSTEM,0);
end;

procedure TLastForm.Button1Click(Sender: TObject);
begin
   if Count < 0 then
   begin
      ExitWindows(EW_REBOOTSYSTEM,0);
   end
   else
   begin
      Close;
      Timer1.Interval:=0;
      Count:=6;
   end;
end;

procedure TLastForm.FormShow(Sender: TObject);
begin
    Count:=6;
    Label1.Caption:='Windows will Shutdown in ' + IntToStr(Count-1) + ' Seconds';
    Button1.Caption:='Abort SHUTDOWN';
    if CmdLine[0] <> 'S' then Button1.Enabled:=False;
    Timer1.Interval:=1000;
end;

procedure TLastForm.FormCreate(Sender: TObject);
begin
    Label1.Caption:='Windows will Shutdown in 5 Seconds';
    Button1.Caption:='Abort SHUTDOWN';
    if CmdLine[0] <> 'S' then Button1.Enabled:=False;
end;

end.
 