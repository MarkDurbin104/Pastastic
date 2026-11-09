unit VUiTServiceControllerFU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus, Winsvc, ServiceControlU, ImgList;

type
  TMainForm = class(TForm)
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    exit: TMenuItem;
    Install: TMenuItem;
    Remove: TMenuItem;
    Start: TMenuItem;
    stop: TMenuItem;
    N1: TMenuItem;
    Timer1: TTimer;
    BImage: TImage;
    YImage: TImage;
    GImage: TImage;
    RImage: TImage;
    ImageList1: TImageList;
    procedure exitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure InstallClick(Sender: TObject);
    procedure RemoveClick(Sender: TObject);
    procedure StartClick(Sender: TObject);
    procedure stopClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.exitClick(Sender: TObject);
begin
  Application.Terminate;
  Close;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Visible:=false;
   Action:=caNone;
   if Application.Terminated then
      Action:=caFree;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
   Application.Title:='VU.iT Service Controller';
   Width:=200;
   Height:=150;
   Top:=Screen.Height-200;
   Left:=Screen.Width-250;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
var
   ServiceStatus:TServiceStatus;
   SStat:String;
const
   LastStatus   :Integer = -1;
   CallCounter  :Integer = -1;
   LastStatusStr:String  = '';
begin
  Timer1.Interval:=1000;
  ServiceStatus:=CtrlService(ctStatus);
  case ServiceStatus.dwCurrentState of
     0                        : begin
                                   SStat:='VU.iT Service is not installed.';
                                   Install.Enabled:=True;
                                   Start  .Enabled:=False;
                                   Stop   .Enabled:=False;
                                   Remove .Enabled:=False;
                                   TrayIcon1.IconIndex:=0;
                                end;
     SERVICE_STOPPED	       : begin
                                   SStat:='VU.iT Service is not running.';
                                   Install.Enabled:=False;
                                   Start  .Enabled:=True;
                                   Stop   .Enabled:=False;
                                   Remove .Enabled:=True;
                                   TrayIcon1.IconIndex:=3;
                                end;
     SERVICE_START_PENDING	 : begin
                                   SStat:='VU.iT Service is starting.';
                                   Install.Enabled:=False;
                                   Start  .Enabled:=False;
                                   Stop   .Enabled:=False;
                                   Remove .Enabled:=False;
                                   TrayIcon1.IconIndex:=2;
                                end;
     SERVICE_STOP_PENDING	    : begin
                                   SStat:='VU.iT Service is stopping.';
                                   Install.Enabled:=False;
                                   Start  .Enabled:=False;
                                   Stop   .Enabled:=False;
                                   Remove .Enabled:=False;
                                   TrayIcon1.IconIndex:=2;
                                end;
     SERVICE_RUNNING	       : begin
                                   SStat:='VU.iT Service is running.';
                                   Install.Enabled:=False;
                                   Start  .Enabled:=False;
                                   Stop   .Enabled:=True;
                                   Remove .Enabled:=False;
                                   TrayIcon1.IconIndex:=1;
                                end;
     SERVICE_CONTINUE_PENDING : begin
                                   SStat:='VU.iT Service continue is pending.';
                                   TrayIcon1.IconIndex:=2;
                                end;
     SERVICE_PAUSE_PENDING	 : begin
                                   SStat:='VU.iT Service pause is pending.';
                                   TrayIcon1.IconIndex:=2;
                                end;
     SERVICE_PAUSED	          : begin
                                   SStat:='VU.iT Service is paused.';
                                   TrayIcon1.IconIndex:=2;
                                end;
     else	                     begin
                                   SStat:='VU.iT Service Stopped '+IntToHex(ServiceStatus.dwCurrentState,8);
                                   Install.Enabled:=False;
                                   Start  .Enabled:=True;
                                   Stop   .Enabled:=False;
                                   Remove .Enabled:=True;
                                   TrayIcon1.IconIndex:=3;
                                end;
  end;
   Application.Title:=SStat;
   TrayIcon1.Hint:=SStat;
end;

procedure TMainForm.TrayIcon1Click(Sender: TObject);
begin
  if Install.Enabled then
    InstallService
  else if Start.Enabled then
   CtrlService(ctStart)
  else if Stop.Enabled then
   CtrlService(ctStop)
  else
    RemoveService;
end;

procedure TMainForm.InstallClick(Sender: TObject);
begin
   InstallService;
end;

procedure TMainForm.StartClick(Sender: TObject);
begin
   CtrlService(ctStart);
end;

procedure TMainForm.StopClick(Sender: TObject);
begin
   CtrlService(ctStop);
end;

procedure TMainForm.RemoveClick(Sender: TObject);
begin
   RemoveService;
end;

end.
