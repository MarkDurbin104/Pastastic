unit SchedulerFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, SchedulerU;
const
   ScheduleFile = 'C:\Schedule.dat';
type
  TBackup = class(TObject)
     Interval:Integer;
     Path:String;
  end;
  TExchange = class(TObject)
     Name:String;
     DUNEntry:String;
     Interval:Integer;
  end;
  TForm1 = class(TForm)
    ScheduleItems: TListBox;
    Splitter1: TSplitter;
    Panel1: TPanel;
    PageControl1: TPageControl;
    BackupSheet: TTabSheet;
    ExchangeSheet: TTabSheet;
    Panel2: TPanel;
    BKPath: TEdit;
    Label1: TLabel;
    BKType: TRadioGroup;
    EntryName: TEdit;
    DUNName: TEdit;
    ExchangeInterval: TRadioGroup;
    Label2: TLabel;
    Label3: TLabel;
    DelButton: TButton;
    NewButton: TButton;
    PostButton: TButton;
    procedure ScheduleItemsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BKTypeClick(Sender: TObject);
    procedure BKPathChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EntryNameChange(Sender: TObject);
    procedure DUNNameChange(Sender: TObject);
    procedure ExchangeIntervalClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure PostButtonClick(Sender: TObject);
    procedure DelButtonClick(Sender: TObject);
    procedure NewButtonClick(Sender: TObject);
  private
     Modified:Boolean;
     isLoading:Boolean;
     procedure SaveSchedule;
     procedure LoadSchedule;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.SaveSchedule;
var
   SL:TStringlist;
   I:Integer;
   Exchange:TExchange;
   BKP:TBackup;
   Schedule:TSchedule;
begin        
   SL:=TStringList.Create;
   for I:=0 to ScheduleItems.Items.Count-1 do
   begin
      Schedule:=TSchedule.Create(nil,'"'+ScheduleItems.Items[I]+'"');
      if ScheduleItems.Items[I] = 'Backup' then
      begin
         BKP:=TBackup(ScheduleItems.Items.Objects[I]);
         Schedule.Execute:=BKP.Path;
         Schedule.Enabled:=BKP.Interval = 0;
         Schedule.Interval:=Interval1Second;
      end
      else
      begin
         Exchange:=TExchange(ScheduleItems.Items.Objects[I]);
         Schedule.Execute:='Exchange '+Exchange.DUNEntry;
         Schedule.Enabled:=True;
         Schedule.Interval:=Interval1Second;
         case Exchange.Interval of
            0 : Schedule.Interval:=Interval1Minute*10;
            1 : Schedule.Interval:=Interval1Minute*20;
            2 : Schedule.Interval:=Interval1Minute*30;
            3 : Schedule.Interval:=Interval1Hour;
            4 : Schedule.Interval:=Interval1Hour*2;
            5 : Schedule.Interval:=Interval1Hour*4;
            6 : Schedule.Interval:=Interval1Hour*8;
            7 : Schedule.Enabled:=False;
         end;
      end;
      SL.Add(Schedule.AsString);
      Schedule.Free;
   end;
   SL.SaveToFile(ScheduleFile);
   SL.Free;
   Modified:=False;        
end;
procedure TForm1.LoadSchedule;
var
   SL:TStringList;
   I:Integer;
   Schedule:TSchedule;
   Exchange:TExchange;
   BKP:TBackup;
   h,m,s:Word;
begin           
   isLoading:=True;
   ScheduleItems.Items.Clear;
   SL:=TStringList.Create;
   if FileExists(ScheduleFile) then
      SL.LoadFromFile(ScheduleFile);
   for I:=0 to SL.Count-1 do
   begin
      if Trim(SL[I]) <> '' then
      begin
         Schedule:=TSchedule.Create(nil,SL[I]);
         if Schedule.Name = 'Backup' then
         begin
            BKP:=TBackup.Create;
            BKP.Path:=Schedule.Execute;
            if Schedule.Enabled then
               BKP.Interval:=0
            else
               BKP.Interval:=1;
            ScheduleItems.Items.AddObject(Schedule.Name,BKP);
         end
         else
         begin
            Exchange:=TExchange.Create;
            Exchange.Name:=Schedule.Name;
            Exchange.DUNEntry:=Copy(Schedule.Execute,10,Length(Schedule.Execute));
            if not Schedule.Enabled then
            begin
               Exchange.Interval:=7;
            end
            else
            begin
               DecodeTime(Schedule.Interval,h,m,s,s);
               case ((h*60)+m) of
                  10   : Exchange.Interval:=0;
                  20   : Exchange.Interval:=1;
                  30   : Exchange.Interval:=2;
                  60   : Exchange.Interval:=3;
                  120  : Exchange.Interval:=4;
                  240  : Exchange.Interval:=5;
                  else   Exchange.Interval:=6;
               end;
            end;                
            ScheduleItems.Items.AddObject(Schedule.Name,Exchange);
         end;
         Schedule.Free;
      end;
   end;  
   if ScheduleItems.Items.IndexOf('Backup') = -1 then
   begin
      BKP:=TBackup.Create;
      BKP.Path:='C:\Backup';
      ScheduleItems.Items.AddObject('Backup',BKP);
   end;
   
   SL.Free;
   Modified:=False;
   isLoading:=False;
end;
procedure TForm1.ScheduleItemsClick(Sender: TObject);
var
   BKP:TBackup;
   Exchange:TExchange;
begin
   if isLoading then Exit;
   if ScheduleItems.ItemIndex = -1 then 
      ScheduleItems.ItemIndex:=0;
   
   if ScheduleItems.Items[ScheduleItems.ItemIndex] = 'Backup' then
   begin
      PageControl1.ActivePage:=BackupSheet;
      BKP:=TBackup(ScheduleItems.Items.Objects[ScheduleItems.ItemIndex]);
      if BKP <> nil then
      begin
         BKType.ItemIndex:=BKP.Interval;
         BKPath.Text:=BKP.Path;
      end;
   end
   else
   begin
      PageControl1.ActivePage:=ExchangeSheet;
      EntryName.Text:=ScheduleItems.Items[ScheduleItems.ItemIndex];
      Exchange:=TExchange(ScheduleItems.Items.Objects[ScheduleItems.ItemIndex]);
      if Exchange <> nil then
      begin
         EntryName.Text:=Exchange.Name;
         DUNName.Text:=Exchange.DUNEntry;
         ExchangeInterval.ItemIndex:=Exchange.Interval;
      end;               
   end;                            
end;   

procedure TForm1.FormShow(Sender: TObject);
begin
   ScheduleItemsClick(ScheduleItems);
end;

procedure TForm1.BKTypeClick(Sender: TObject);
var
   BKP:TBackup;
begin
   if isLoading or (ScheduleItems.ItemIndex < 0 ) then Exit;
   BKP:=TBackup(ScheduleItems.Items.Objects[ScheduleItems.ItemIndex]);
   if (BKP <> nil) and (BKP.Interval <> BKType.ItemIndex) then
   begin
      BKP.Interval:=BKType.ItemIndex;
      Modified:=True;
   end;
end;

procedure TForm1.BKPathChange(Sender: TObject);
var
   BKP:TBackup;
begin
   if isLoading or (ScheduleItems.ItemIndex < 0 ) then Exit;
   BKP:=TBackup(ScheduleItems.Items.Objects[ScheduleItems.ItemIndex]);
   if (BKP <> nil) and (BKP.Path <> BKPath.Text) then
   begin
      BKP.Path:=BKPath.Text;
      Modified:=True;
   end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   LoadSchedule;
end;

procedure TForm1.EntryNameChange(Sender: TObject);
var
   Exchange:TExchange;
begin
   if isLoading or (ScheduleItems.ItemIndex < 0 ) then Exit;
   Exchange:=TExchange(ScheduleItems.Items.Objects[ScheduleItems.ItemIndex]);
   if (Exchange <> nil) and (Exchange.Name <> EntryName.Text) then
   begin
      ScheduleItems.Items[ScheduleItems.ItemIndex]:=EntryName.Text;
      Exchange.Name:=EntryName.Text;
      Modified:=True;
   end;
end;

procedure TForm1.DUNNameChange(Sender: TObject);
var
   Exchange:TExchange;
begin
   if isLoading or (ScheduleItems.ItemIndex < 0 ) then Exit;
   Exchange:=TExchange(ScheduleItems.Items.Objects[ScheduleItems.ItemIndex]);
   if (Exchange <> nil) and (Exchange.DUNEntry <> DUNName.Text) then
   begin
      Exchange.DUNEntry:=DUNName.Text;
      Modified:=True;
   end;
end;

procedure TForm1.ExchangeIntervalClick(Sender: TObject);
var
   Exchange:TExchange;
begin
   if isLoading or (ScheduleItems.ItemIndex < 0 ) then Exit;
   Exchange:=TExchange(ScheduleItems.Items.Objects[ScheduleItems.ItemIndex]);
   if (Exchange <> nil) and (Exchange.Interval <> ExchangeInterval.ItemIndex) then
   begin
      Exchange.Interval:=ExchangeInterval.ItemIndex;
      Modified:=True;
   end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  MR:TModalResult;
begin
   CanClose:=True;
   if Modified then
   begin
      MR:=MessageDlg('The Schedule has changed, do you wish to Save?',mtConfirmation,[mbYes,mbNo,mbCancel],0);
      if MR = mrYes then
      begin
         SaveSchedule;
      end
      else if MR = mrCancel then
      begin
         CanClose:=False;
      end;
   end;  
end;

procedure TForm1.PostButtonClick(Sender: TObject);
begin
   SaveSchedule;
end;

procedure TForm1.DelButtonClick(Sender: TObject);
begin
   if ScheduleItems.ItemIndex >= 0 then
   begin
      ScheduleItems.Items.Delete(ScheduleItems.ItemIndex);
      Modified:=True;
   end;
end;

procedure TForm1.NewButtonClick(Sender: TObject);
begin
   Modified:=True;
   ScheduleItems.ItemIndex:=ScheduleItems.Items.AddObject('NewEntry',TExchange.Create);
   ScheduleItemsClick(ScheduleItems);
   EntryName.SetFocus;
end;

end.
