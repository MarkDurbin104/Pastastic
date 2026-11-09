unit DialFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Ras, RASDialU ;

type
  TFormDial = class(TForm)
    Panel1: TPanel;
    EditPhoneNumber: TEdit;
    EditUserName: TEdit;
    EditPassword: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ButtonDial: TButton;
    ButtonStop: TButton;
    EditIP: TEdit;
    ButtonPing: TButton;
    Panel2: TPanel;
    MemoResult: TMemo;
    procedure ButtonDialClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure ButtonPingClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
     RASConnection : TRASConnection ;
  public
    { Public declarations }
  end;

var
  FormDial: TFormDial;

implementation

uses WinExecU ;

{$R *.DFM}

procedure RasDialFunc(unMsg:DWORD;RasConnState:TRASCONNSTATE;dwError:DWORD); stdcall;
begin
   FormDial.MemoResult.Lines.Add(IntToHex(unMsg,8)+' '+RasConnectionStateToString(RasConnState)+' '+RasErrorStateToString(dwError)+' '+FormDial.RASConnection.IPAddress);
end;
procedure TFormDial.ButtonDialClick(Sender: TObject);
var
   StrStatus : String ;
begin
   RASConnection.Dial(EditPhoneNumber.Text,EditUserName.Text,EditPassword.Text);
   if StrStatus <> '' then
     MemoResult.Lines.Add(StrStatus) ;
end;

procedure TFormDial.ButtonStopClick(Sender: TObject);
begin
   RASConnection.Disconnect;
end;


procedure TFormDial.ButtonPingClick(Sender: TObject);
var
   s: string ;
   CompilerOutput : String ;
begin
   ButtonPing.Enabled := FALSE ;
   s:= 'PING '+ EditIP.Text ;
   WinExecAndWait( s ,CompilerOutput,False);
   MemoResult.Lines.Add('------------------------------');
   MemoResult.Lines.Add( CompilerOutput );
   MemoResult.Lines.Add('------------------------------');
   ButtonPing.Enabled := TRUE ;

end;

procedure TFormDial.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   RASConnection.Free ;
   Application.ProcessMessages ;
end;

procedure TFormDial.FormCreate(Sender: TObject);
begin
   RASConnection := TRASConnection.Create ;
   RASConnection.OnRasDialFunc:=RasDialFunc;
end;

end.
