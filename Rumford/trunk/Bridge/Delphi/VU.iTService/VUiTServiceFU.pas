unit VUiTServiceFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  CommsControllerFU,FrontFU;

type

  TVUiTService = class(TService)
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
    CommsController:TCommsController;
    Front:TFront;
  public
    function GetServiceController: TServiceController; override;
  end;

var
  VUiTService: TVUiTService;

implementation

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  VUiTService.Controller(CtrlCode);
end;

function TVUiTService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TVUiTService.ServiceContinue(Sender: TService; var Continued: Boolean);
begin
  CommsController.Active:=True;
  Continued := True;
end;

procedure TVUiTService.ServicePause(Sender: TService; var Paused: Boolean);
begin
  CommsController.Active:=False;
  Paused := True;
end;

procedure TVUiTService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  CommsController:=TCommsController.Create(nil);
  CommsController.Active:=True;
  CommsController.Visible:=True;
  Front:=TFront.Create(nil);
  SetForegroundWindow(Front.Handle);
  Started := True;
end;

procedure TVUiTService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  CommsController.Active:=False;
  Stopped := True;
end;


end.
