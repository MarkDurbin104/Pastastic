unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,IPCThrd,
  StdCtrls;

type
  TForm1 = class(TForm)
    SActvate: TButton;
    SMemo: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    CMemo: TMemo;
    CActivate: TButton;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SActvateClick(Sender: TObject);
    procedure CActivateClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  public
    IPCMonitor:TIPCMonitor;
    IPCClient:TIPCClient;
    procedure IPCMonitorConnect(Sender:TIPCThread;Connecting:Boolean);
    procedure IPCMonitorSignal(Sender:TIPCThread;Data:TEventData);
    procedure DirectoryUpdate(Sender: TIPCThread);
    procedure IPCClientConnect(Sender:TIPCThread;Connecting:Boolean);
    procedure IPCClientSignal(Sender:TIPCThread;Data:TEventData);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
procedure TForm1.IPCMonitorConnect(Sender:TIPCThread;Connecting:Boolean);
begin
   if Connecting then 
      SMemo.Lines.Add('Connected')
   else
      SMemo.Lines.Add('Disconnected');
end;
procedure TForm1.IPCMonitorSignal(Sender:TIPCThread;Data:TEventData);
begin
   SMemo.Lines.Add('Signal')
end;  
procedure TForm1.DirectoryUpdate(Sender: TIPCThread);
begin
   IPCMonitor.GetClientNames(SMemo.Lines);
end;
procedure TForm1.IPCClientConnect(Sender:TIPCThread;Connecting:Boolean);
begin
   if Connecting then 
      CMemo.Lines.Add('Connected')
   else
      CMemo.Lines.Add('Disconnected');
end;
procedure TForm1.IPCClientSignal(Sender:TIPCThread;Data:TEventData);
begin
   CMemo.Lines.Add('Signal')
end;                
procedure TForm1.FormCreate(Sender: TObject);
begin
   IPCMonitor:=TIPCMonitor.Create(100,'Main');
   IPCMonitor.OnSignal:=IPCMonitorSignal;
   IPCMonitor.OnConnect:=IPCMonitorConnect;
   IPCMonitor.OnDirectoryUpdate:=DirectoryUpdate;
   IPCMonitor.AutoSwitch:=True;
   IPCClient:=TIPCClient.Create(90,'Client');
   IPCClient.OnSignal:=IPCClientSignal;
   IPCClient.OnConnect:=IPCClientConnect;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
   IPCClient.Free;
   IPCMonitor.Free;
end;

procedure TForm1.SActvateClick(Sender: TObject);
begin
   IPCMonitor.Activate;
   IPCMonitor.ClientID:=90;
end;

procedure TForm1.CActivateClick(Sender: TObject);
begin
   IPCClient.Activate;
   IPCClient.MakeCurrent;
end;                       

procedure TForm1.Button1Click(Sender: TObject);
begin
   IPCMonitor.Deactivate;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
   IPCClient.Deactivate;
end;

end.
