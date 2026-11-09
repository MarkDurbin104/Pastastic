unit TransparentFU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, OleCtrls, SHDocVw;

type
  TBGForm = class(TForm)
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    function SystemIsIdle:Boolean;
  public
    IdleTime:Integer;
    procedure WndProc(var Message: TMessage); override;
  end;

var
  BGForm: TBGForm;

implementation

uses TransparentMainFU;

{$R *.dfm}

function LastWork: DWord;
var
  LInput: TLastInputInfo;
begin
  LInput.cbSize := SizeOf(TLastInputInfo);
  GetLastInputInfo(LInput);
  Result := GetTickCount - LInput.dwTime;
end;
function TBGForm.SystemIsIdle:Boolean;
begin
  Result:=LastWork > IdleTime;
end;
procedure TBGForm.Timer1Timer(Sender: TObject);
begin
   if SystemIsIdle() then
   begin
      Show;
      Timer1.Enabled:=False;
   end;
end;

procedure TBGForm.WndProc(var Message: TMessage);
begin
   if Application.Terminated then Exit;
   try
      inherited WndProc(Message);
      if Visible and (Message.Msg = $001C) then
      begin
         if (Message.WParam = $0001) then
         begin
         end else if (Message.WParam = $0000) then
         begin
            Hide;
            MainForm.Hide;
            Timer1.Enabled:=True;
         end;
      end;
   except

   end;
end;
procedure TBGForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action:=caFree;
   MainForm.Close;
end;

procedure TBGForm.FormCreate(Sender: TObject);
begin
  IdleTime:=10000;
end;

procedure TBGForm.FormShow(Sender: TObject);
begin
  SetForegroundWindow(Handle);
  MainForm.Show;
end;

end.
