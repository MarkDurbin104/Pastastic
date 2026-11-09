unit RouterMonitorF;

interface

uses
  StringUtil,
  Masks,
  DateTimeUtil,
  SavePosTrayFormU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TnCnx, Emulvt, TnEmulvt, TnScript, StdCtrls, ExtCtrls, ComCtrls, MPlayer,
  TeeProcs, TeEngine, Chart, Series;

type
  TISDNLine = class(TObject)
  private
    CallStart  : TDateTime;
    FLineUp     : Boolean;
    FLine       : Integer;
    procedure SetLineUp(Value : Boolean);
  public
    ReceivePercent  : Integer;
    TransmitPercent : Integer;

    constructor Create;
    property Line   : Integer read FLine write FLine;
    property LineUp : Boolean read FLineUp write SetLineUp;
  end;

  TRouterMonitorForm = class(TSavePosTrayForm)
    TopPanel: TPanel;
    BottomSplitter: TSplitter;
    ISDN1Label: TLabel;
    ISDN2Label: TLabel;
    KeepAliveTimer: TTimer;
    PageControl: TPageControl;
    EmulTabSheet: TTabSheet;
    TnScript: TTnScript;
    StatusTabSheet: TTabSheet;
    ISDN2StatusPanel: TPanel;
    ISDN1StatusPanel: TPanel;
    RouterIpEdit: TEdit;
    IconImageList: TImageList;
    RightPanel: TPanel;
    ConnectButton: TButton;
    DisconnectButton: TButton;
    ExitButton: TButton;
    KeepAliveCheckBox: TCheckBox;
    LogTabSheet: TTabSheet;
    BufferMemo: TMemo;
    CancelButton: TButton;
    GraphTabSheet: TTabSheet;
    Chart: TChart;
    Series1: TLineSeries;
    Series2: TLineSeries;
    Series3: TLineSeries;
    Series4: TLineSeries;

    procedure TnScriptDataAvailable(Sender: TObject; Buffer: PChar;
      var Len: Integer);
    procedure ConnectButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DisconnectButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TnScriptSessionClosed(Sender: TObject);
    procedure KeepAliveTimerTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure RouterIpEditChange(Sender: TObject);
    procedure ExitButtonClick(Sender: TObject);
    procedure PageControlEnter(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure ChartAfterDraw(Sender: TObject);
  private
    { Private declarations }
    ISDNLine1 : TISDNLine;
    ISDNLine2 : TISDNLine;
    ISDN1Series, ISDN2Series : TChartSeries;
    procedure Connect;
    procedure PasswordEvent (Sender : TObject; ID : Integer);
    procedure UpdateChart;
  public
    { Public declarations }
  end;


var
  RouterMonitorForm: TRouterMonitorForm;
  LogFileStream     : TFileStream;

implementation

{$R *.DFM}

procedure TRouterMonitorForm.UpdateChart;
const
  LastSec : Word = 0;
var
  CurrDateTime : TDateTime;
  SeriesIndex : Integer;

begin
  //update chart
  CurrDateTime := Now;
  Chart.Series[0].AddXY(CurrDateTime, ISDNLine1.TransmitPercent, '', Chart.Series[0].SeriesColor);
  Chart.Series[1].AddXY(CurrDateTime, ISDNLine2.TransmitPercent,  '', Chart.Series[1].SeriesColor);
  Chart.Series[2].AddXY(CurrDateTime, ISDNLine1.ReceivePercent, '', Chart.Series[2].SeriesColor);
  Chart.Series[3].AddXY(CurrDateTime, ISDNLine2.ReceivePercent, '', Chart.Series[3].SeriesColor);

  //keep 200 values per series
  For SeriesIndex := 0 to Chart.SeriesCount -1 do
    While Chart.Series[SeriesIndex].Count > 500 do
      Chart.Series[SeriesIndex].Delete(0);

  Chart.BottomAxis.Maximum := CurrDateTime;
  Chart.BottomAxis.Minimum := CurrDateTime - 120/SecsPerDay;;

end;

constructor TISDNLine.Create;
begin
  Inherited;
  FLineUp := False;
end;

procedure TISDNLine.SetLineUp(Value : Boolean);
var
  LogLine : String;
  PLogLine : PChar;
begin
  If FLineUp <> Value then
  begin
    FLineUp := Value;
    If Value = True then //line up
    begin
      Windows.Beep(1000,500);
      Windows.Beep(2000,200);
//      RouterMonitorForm.MediaPlayer.FileName := '\\Backup\Utils\Check Email.wav';
//      RouterMonitorForm.MediaPlayer.Open;
//      RouterMonitorForm.MediaPlayer.Play;
      CallStart := Now;
      LogLine := 'ISDN ' + IntToStr(FLine) + ' up   at ' + DateTimeToStr(CallStart) + #13 + #10;;
      PLogLine := PChar(LogLine);
      LogFileStream.Write(PLogLine^, Length(LogLine) );
    end
    else
    begin
      Windows.Beep(2000,500);
      Windows.Beep(1000,200);
//      RouterMonitorForm.MediaPlayer.FileName := '\\Backup\Utils\Sweet Like Chocolate.wav';
//      RouterMonitorForm.MediaPlayer.Open;
//      RouterMonitorForm.MediaPlayer.Play;
      LogLine := 'ISDN ' + IntToStr(FLine) + ' down at ' + DateTimeToStr(Now)
                + ' duration ' + TimeToStr(Now-CallStart) + #13 + #10;
      PLogLine := PChar(LogLine);
      LogFileStream.Write(PLogLine^, Length(LogLine) );
    end;
  end;
end;

procedure TRouterMonitorForm.TnScriptDataAvailable(Sender: TObject; Buffer: PChar;
  var Len: Integer);
var
  ISDN1Line, ISDN2Line : String;
begin
  //telnet examples
  //ISDN1  AUTO FAST/PPP 1      ISDN         ISDN      00     00             DOWN
  //ISDN2  GlobalNet            PPP          ISDN      00     00             UP

  ISDN1Line := SubString(Buffer,'ISDN1','[0m');
  ISDN2Line := SubString(Buffer,'ISDN2','[0m');
//  If (Pos('ISDN1                                           IDLE', Buffer) > 0) then
  If (Pos('DOWN',ISDN1Line) > 0) then
  begin
    ISDNLine1.LineUp := False;
    ISDN1Label.Font.Color := clBlack;
    ISDN1Label.CAption := 'ISDN1';
    ISDNLine1.ReceivePercent := 0;
    ISDNLine1.TransmitPercent := 0;
  end;

//  if (Pos('ISDN2                                           IDLE', Buffer) > 0) then
  if (Pos('DOWN',ISDN2Line) > 0) then
  begin
    ISDNLine2.LineUp := False;
    ISDN2Label.Font.Color := clBlack;
    ISDN2Label.Caption := 'ISDN2';
    ISDNLine2.ReceivePercent := 0;
    ISDNLine2.TransmitPercent := 0;

  end;
{
  If (Pos('ISDN1  GlobalNet                                CALL', Buffer) > 0) then
  begin
    ISDNLine1.LineUp := True;
    ISDN1Label.Font.Color := clBlue;
  end;

  If (Pos('ISDN2  GlobalNet                                CALL', Buffer) > 0) then
  begin
    ISDNLine2.LineUp := True;
    ISDN2Label.Font.Color := clBlue;
  end;
}
//  If (Pos('ISDN1  GlobalNet                                CONN', Buffer) > 0) then
  If (Pos('UP', ISDN1Line) > 0) then
  begin

    ISDNLine1.LineUp := True;
    ISDN1Label.Font.Color := clGreen;
    ISDNLine1.ReceivePercent := StrToInt(Trim(Copy(ISDN1Line,47,3)));
    ISDNLine1.TransmitPercent := StrToInt(Trim(Copy(ISDN1Line,54,3)));
    ISDN1Label.CAption := IntToStr(ISDNLine1.ReceivePercent)
                          + '-' + IntToStr(ISDNLine1.TransmitPercent)
  end;

//  If (Pos('ISDN2  GlobalNet                                CONN', Buffer) > 0) then
  If (Pos('UP', ISDN2Line) > 0) then
  begin
    ISDNLine2.LineUp := True;
    ISDN2Label.Font.Color := clGreen;
    ISDNLine2.ReceivePercent := StrToInt(Trim(Copy(ISDN2Line,47,3)));
    ISDNLine2.TransmitPercent := StrToInt(Trim(Copy(ISDN2Line,54,3)));
    ISDN2Label.Caption := IntToStr(ISDNLine2.ReceivePercent)
                          + '-' + IntToStr(ISDNLine2.TransmitPercent)

  end;

  UpdateChart;

  If (Pos('Server has closed', Buffer) > 0) then
  begin
    Connect;
  end;

  ISDN1StatusPanel.Color := ISDN1Label.Font.Color;
  ISDN2StatusPanel.Color := ISDN2Label.Font.Color;

  BufferMemo.Lines.Add(String(Buffer));
  //clear surplus lines
  While BufferMemo.Lines.Count > 200 do
    BufferMemo.Lines.Delete(0);
end;

procedure TRouterMonitorForm.ConnectButtonClick(Sender: TObject);
begin
  Connect;
end;

procedure TRouterMonitorForm.Connect;
begin
  If TnScript.IsConnected then
     TnScript.Disconnect;
  TnScript.RemoveAllEvents;
  TnScript.AddEvent(1, 'Password[', 'suvroc' + #13 , [efIgnoreCase], PasswordEvent);
  try
    TnScript.Connect;
  except
    ;
  end;
  DisconnectButton.Enabled := True;
end;

procedure TRouterMonitorForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TnScript.Disconnect;
  LogFileStream.Free;
  ISDNLine1.Free;
  ISDNLine2.Free;
  ISDN1Series.Free;
  ISDN2Series.Free;
end;

procedure TRouterMonitorForm.PasswordEvent (Sender : TObject; ID : Integer);
begin
end;

procedure TRouterMonitorForm.DisconnectButtonClick(Sender: TObject);
begin
  TnScript.Disconnect;
  DisconnectButton.Enabled := False;
end;

procedure TRouterMonitorForm.FormCreate(Sender: TObject);
begin
  ISDNLine1 := TISDNLine.Create;
  ISDNLine1.Line := 1;
  ISDNLine2 := TISDNLine.Create;
  ISDNLine2.Line := 2;
  TrayIcon := Application.Icon;
  ShowOnClick := True;
  HideOnDeactivate := False;
  try
    If FileExists('RouterMonitor.Log') then
      LogFileStream := TFileStream.Create('RouterMonitor.Log', fmOpenReadWrite or fmShareDenyWrite)
    else
      LogFileStream := TFileStream.Create('RouterMonitor.Log', fmCreate or fmShareDenyWrite);
  except
    ;
  end;

  //init chart
  ISDN1Series := TChartSeries.Create(self);
  ISDN2Series := TChartSeries.Create(self);

  LogFileStream.Position := LogFileStream.Size;
  TnScript.HostName := RouterIpEdit.Text;
  If not TnScript.IsConnected then
    Connect;
  BufferMemo.Clear;

end;

procedure TRouterMonitorForm.TnScriptSessionClosed(Sender: TObject);
const
  SessionClosing : Boolean = False;
begin
  If not SessionClosing then
  begin
//    SessionClosing := True;
//    TnScript.Disconnect;
//    Sleep(2000);
//    Connect;
//    SessionClosing := False;
  end;
end;

procedure TRouterMonitorForm.KeepAliveTimerTimer(Sender: TObject);

begin
//  KeepAliveTimer.Enabled := False;

  If (TnScript.IsConnected) and (KeepAliveCheckBox.Checked) then
  begin
    TnScript.SendStr('co' + #13);
    TnScript.SendStr('co po' + #13);

  end;

  IconImageList.GetIcon(0, Application.Icon);

  UpdateChart;

  If (ISDNLine1.LineUp) and (ISDNLine2.LineUp) then
  begin
    IconImageList.GetIcon(3, Application.Icon);
    TrayHint := ' 1 - 1 ';
  end

  else If (ISDNLine1.LineUp) then
  begin
    IconImageList.GetIcon(1, Application.Icon);
    TrayHint := ' 1 - 0 ';
  end

  else If (ISDNLine2.LineUp) then
  begin
    IconImageList.GetIcon(2, Application.Icon);
    TrayHint := ' 0 - 1 ';
  end;

  TrayHint := IntToStr(ISDNLine1.ReceivePercent)
              + '-' + IntToStr(ISDNLine1.TransmitPercent)
              + '-' + IntToStr(ISDNLine2.ReceivePercent)
              + '-' + IntToStr(ISDNLine2.TransmitPercent);
              
  TrayIcon := Application.Icon;
//  KeepAliveTimer.Enabled := True;

end;

procedure TRouterMonitorForm.FormResize(Sender: TObject);
begin
  ISDN1StatusPanel.Height := ISDN1StatusPanel.Parent.Height;
  ISDN1StatusPanel.Width := ISDN1StatusPanel.Parent.Width div 2;
  ISDN2StatusPanel.Height := ISDN2StatusPanel.Parent.Height;
  ISDN2StatusPanel.Left := ISDN2StatusPanel.Parent.Width div 2;
  ISDN2StatusPanel.Width := ISDN2StatusPanel.Parent.Width div 2;
end;

procedure TRouterMonitorForm.RouterIpEditChange(Sender: TObject);
begin
  TnScript.HostName := RouterIpEdit.Text;
end;

procedure TRouterMonitorForm.ExitButtonClick(Sender: TObject);
begin
  TrayClose;
end;

procedure TRouterMonitorForm.PageControlEnter(Sender: TObject);
begin
  self.refresh;
end;

procedure TRouterMonitorForm.CancelButtonClick(Sender: TObject);
begin
  If (TnScript.IsConnected) then
  begin
    TnScript.SendStr('co is nu' + #13);
    TnScript.SendStr('canc' + #13);
  end;

end;

procedure TRouterMonitorForm.ChartAfterDraw(Sender: TObject);
begin
  Chart.Canvas.Pen.Color := clGreen;
  Chart.Canvas.Brush.Color := clGreen;
//  Chart.Canvas.Rectangle(0,0,Chart.Width-1, Chart.Height-1);
end;

end.
