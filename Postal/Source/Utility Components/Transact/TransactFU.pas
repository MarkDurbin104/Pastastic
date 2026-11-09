unit TransactFU;

interface

uses
  GPCSErrorLine, Math,
  MOItemsU,CustomerListU,FileTxStatusU,
  BitmapbarChart, RegistryEx,SchedulerU,TranProcessU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,Grids, ComCtrls,GPCSGUID,GPCSBase_TLB,PackStrListU, Db, DBTables,
  UDPMessageU,ExtCtrls, StringUtil,TxnTxU,ShareDataU,I3UIParseU,UIDllSupportU,MOSupportU;

const
   CheckMOInfo:Integer = 60;
   Logging:Boolean = False;

type
  TTxnForm = class(TForm)
    PageControl: TPageControl;
    MonitorTabSheet: TTabSheet;
    UpdateTimer: TTimer;
    LogTabSheet: TTabSheet;
    LogMemo: TMemo;
    TabSheet1: TTabSheet;
    StatsList: TListBox;
    MOCheck: TTabSheet;
    Memo1: TMemo;
    CheckMOInfoQuery: TQuery;
    Panel1: TPanel;
    CheckMOStatus: TCheckBox;
    CheckBox1: TCheckBox;
    ScrollBox: TScrollBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StatsListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure CheckMOStatusClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    SharedData:TSharedData;
    procedure AppException(Sender: TObject; E: Exception);
  public
    I3UINode:TI3UINode;
    TxnProcessor:TTxnProcessor;
    procedure LogEvent(Event : String);
  end;

var
   TxnForm:TTxnForm;

implementation

{$R *.DFM}
uses
   ComServ2;

procedure TTxnForm.LogEvent(Event : String);
begin
   LogMemo.Lines.Add(TimeToStr(Now) + ' - ' + Event);
end;

procedure TTxnForm.AppException(Sender: TObject; E: Exception);
begin
   LogEvent(E.Message);
   GPCSErrorline.RaiseGUIDException('{BCCF2CF7-16CE-41F6-8579-629B5D3C777A}', E);
end;

procedure TTxnForm.FormCreate(Sender: TObject);
begin
   TxnProcessor:=TTxnProcessor.Create('FMCreatePSL');
   Application.OnException := AppException;
   PageControl.ActivePage := MonitorTabSheet;

   if not IsServiceRunning then
   begin
       TempFileTxStatus:=TFileTxStatus.Create(nil);
       ScrollBox.InsertControl(TempFileTxStatus);
       TempFileTxStatus.OnChange:=FormResize;
   end;

   SharedData:=TSharedData.Create('CorvusReportShare',False);
   I3UINode:=CreateI3UINode('');  //Also calls OfficeCodeMapping

   TxnProcessor.RestoreLostTxns;

   if GetGPCSRegString('','Check MO Status','0') = '1' then
      CheckMOStatus.Checked:=True;
   if GetGPCSRegString('','Check MO Clear Log','0') = '1' then
      CheckBox1.Checked:=True;
end;

procedure TTxnForm.FormDestroy(Sender: TObject);
begin
   if Logging then
   begin
      RaiseGUIDError('Transact','Release Control');
      Windows.Beep(5000,50);
   end;
   if Assigned(I3UINode) then
      I3UINode.Free;
   SharedData.Free;
   TxnProcessor.Free;
   if not IsServiceRunning then 
   begin
      ScrollBox.RemoveControl(TempFileTxStatus);
      TempFileTxStatus.Free;
   end;
end;


procedure TTxnForm.StatsListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
   with StatsList.Canvas do
   begin
      FillRect(Rect);
      DrawText(Handle,PChar(StatsList.Items[Index]+' ('+IntToStr(Integer(StatsList.Items.Objects[Index]))+')'),-1,Rect,DT_WORDBREAK);
   end;
end;

procedure TTxnForm.CheckMOStatusClick(Sender: TObject);
begin
   CheckMOInfo:=60;
   if CheckMOStatus.Checked then
      SetGPCSRegString('','Check MO Status','1')
   else
      SetGPCSRegString('','Check MO Status','0');
end;

procedure TTxnForm.CheckBox1Click(Sender: TObject);
begin
   if CheckBox1.Checked then
      SetGPCSRegString('','Check MO Clear Log','1')
   else
      SetGPCSRegString('','Check MO Clear Log','0');
end;

procedure TTxnForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   CanClose:=True;
end;

procedure TTxnForm.FormResize(Sender: TObject);
var
   I,MaxW:Integer;
begin
   MaxW:=1;
   if TempFileTxStatus <> nil then
   begin
      for I:=0 to TempFileTxStatus.StatusMonitor.CurrentStatus.Count-1 do
      begin
         if TempFileTxStatus.StatusMonitor.CurrentStatus.WSNumber(I) > MaxW then
            MaxW:=TempFileTxStatus.StatusMonitor.CurrentStatus.WSNumber(I);
      end;
      Inc(MaxW);
      TempFileTxStatus.Align:=alNone;
      TempFileTxStatus.Top:=0;
      TempFileTxStatus.Left:=0;
      TempFileTxStatus.Width:=ScrollBox.ClientWidth;
      TempFileTxStatus.Height:=MaxW*Canvas.TextHeight('Wg');
   end; 
end;

procedure TTxnForm.FormShow(Sender: TObject);
begin
   FormResize(Self);
end;

end.
