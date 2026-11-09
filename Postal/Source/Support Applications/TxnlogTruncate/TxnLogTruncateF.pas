unit TxnLogTruncateF;

interface

uses
	Db,DBTables, StringUtil, SavePosFormEx, Restruct,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Spin, ComCtrls;

type
  TTxnlogTruncateForm = class(TForm)

    TxnLogQuery: TQuery;
    TxnLogQueryperiod: TIntegerField;
    LogGroupBox: TGroupBox;
    BottomPanel: TPanel;
    PeriodGroupBox: TGroupBox;
    FirstPeriodLabel: TLabel;
    LastPeriodLabel: TLabel;
    KeepPeriodLabel: TLabel;
    FirstPeriodEdit: TEdit;
    LastPeriodEdit: TEdit;
    KeepPeriodSpinEdit: TSpinEdit;
    LogMemo: TMemo;
    RightPanel: TPanel;
    TruncateButton: TButton;
    CloseButton: TButton;
    StatusBar: TStatusBar;
		procedure AppException(Sender: TObject; E: Exception);
    procedure TruncateButtonClick(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TScanThread = class(TThread)
  private
  	procedure ReadyToTruncate;
  public
    FirstPeriod, LastPeriod : Integer;
	  procedure Execute; override;
  end;

  TTruncateThread = class(TThread)
  private
    RecordIndex       : Integer;
    RecordCount       : Integer;

    procedure CompactTable(SourceTableFileName, DestTableFileName, Filter : String);
  	procedure FinishedTruncate;
    procedure UpdateProgress;
  public
	  procedure Execute; override;
  end;


var
  TxnlogTruncateForm: TTxnlogTruncateForm;
  AliasPath : String;

implementation

{$R *.DFM}

function SizeFiles(FilePathMask : String) : Integer;
var
  SearchRec : TSearchRec;
  FileSizeTotal : Integer;
begin
  FileSizeTotal := 0;
  try
    If 0 = FindFirst(FilePathMask,faAnyFile, SearchRec) then
    begin

      repeat
        Inc(FileSizeTotal, SearchRec.Size);
      until 0 <> FindNext(SearchRec)
    end;
  finally
    FindClose(SearchRec);
  end;
  Result := FileSizeTotal;

end;


procedure UpdateStatus(Status : String);
var
  StatusStrings : TStringList;
  FirstLine : Boolean;
begin
  StatusStrings := TStringList.Create;
  try
    FirstLine := True;
    StatusStrings.Text := Status; //handle multi line strings
    While StatusStrings.Count > 0 do
    begin
      If FirstLine then
      begin
        TxnlogTruncateForm.LogMemo.Lines.Add(DateTimeToStr(Now) + ' - ' + StatusStrings[0]);
        TxnlogTruncateForm.StatusBar.Panels[0].Text := DateTimeToStr(Now) + ' - ' + StatusStrings[0];
        FirstLine := False
      end
      else
      begin
        TxnlogTruncateForm.LogMemo.Lines.Add(LeftPad('', Length(DateTimeToStr(Now)), ' ') + '   ' + StatusStrings[0]);
      end;
      StatusStrings.Delete(0);
    end;
    TxnlogTruncateForm.LogMemo.Lines.SaveToFile(ExtractFilePath(Application.ExeName) + '\Corvus Truncate TxnLog.Log');
  finally
    StatusStrings.Free;
  end;
end;


procedure TTxnlogTruncateForm.AppException(Sender: TObject; E: Exception);
begin
	try
  	UpdateStatus(E.Message);
    Screen.Cursor := crDefault;
  except
  end;
end;

procedure DeleteFiles(FilePathMask : String);
var
	SearchRec : TSearchRec;
  FilePath : String;
begin
  //delete files
  try
    If 0 = FindFirst(FilePathMask,faAnyFile, SearchRec) then
    begin
      repeat
        FilePath 	:= ExtractFilePath(FilePathMask)+SearchRec.Name;
        If not DeleteFile(FilePath) then
          UpdateStatus('Unable to delete file <' + FilePath + '>')
        else
          UpdateStatus('Deleted file <' + FilePath + '>');

      until 0 <> FindNext(SearchRec)
    end;
  finally
  	FindClose(SearchRec);
  end;

end;

procedure CopyFiles(SourceFilePathMask, DestFilePathMask : String);
var
	SearchRec : TSearchRec;
  SourceFilePath, DestFilePath : String;

begin
  //copy files
  try
    If 0 = FindFirst(SourceFilePathMask,faAnyFile, SearchRec) then
    begin
      repeat
        SourceFilePath 	:= ExtractFilePath(SourceFilePathMask)+SearchRec.Name;
        DestFilePath		:= ExtractFilePath(DestFilePathMask)
                          + DelimitedString(ExtractFileName(DestFilePathMask), '.', False)	//filename
                          + '.'
                          + DelimitedString(SearchRec.Name, '.', True); //extension
        If not CopyFile(PChar(SourceFilePath), PChar(DestFilePath), False) then
          UpdateStatus('Unable to copy file <' + SourceFilePath + '>')
        else
          UpdateStatus('Copied <' + SourceFilePath + '> to <' + DestFilePath + '>');

      until 0 <> FindNext(SearchRec)
    end;
  finally
  	FindClose(SearchRec);
  end;

end;

procedure TTruncateThread.CompactTable(SourceTableFileName, DestTableFileName, Filter : String);
var
	SourceTable       : TTable;
  DestTable		      : TTable;
  FieldIndex        : Integer;
  FieldCount        : Integer;
begin
  //backup existing txnlog
  UpdateStatus('Txnlog backup started');
  CopyFiles(ExtractFilePath(SourceTableFileName)+'txnlog.*',
  					ExtractFilePath(SourceTableFileName)+'Bak_txnlog.*');
  UpdateStatus('Txnlog backup complete');

  //connect source table
  SourceTable 							:= TTable.Create(nil);
  SourceTable.DatabaseName 	:= ExtractFilePath(SourceTableFileName);
  SourceTable.TableName			:= ExtractFileName(SourceTableFileName);
  SourceTable.Filter				:= Filter;
  SourceTable.Filtered			:= True;
  SourceTable.Open;
  SourceTable.IndexDefs.Update;

  //create destination table
  UpdateStatus('Creating table <' + DestTableFileName + '>');
  DestTable := TTable.Create(nil);
  DestTable.DatabaseName 	  := ExtractFilePath(DestTableFileName);
  DestTable.TableName			  := ExtractFileName(DestTableFileName);
  DestTable.FieldDefs.Assign(SourceTable.FieldDefs);
  DestTable.IndexDefs.Assign(SourceTable.IndexDefs);
  DestTable.CreateTable;
  UpdateStatus('Created table <' + DestTableFileName + '>');
  DestTable.Exclusive := True;
  DestTable.Open;
  UpdateStatus('Altering Table parameters <' + DestTableFileName + '>');
  Restruct.AlterVersion(DestTable, 7);
  Restruct.AlterBlockSize(DestTable, 32768);
  UpdateStatus('Altered Table parameters <' + DestTableFileName + '>');

  //peform data transfer
  UpdateStatus('Transferring data');
  Application.ProcessMessages;
  SourceTable.First;
  FieldCount := SourceTable.FieldCount;
  RecordCount := SourceTable.RecordCount;
  Application.ProcessMessages;
  RecordIndex := 0;
  While not SourceTable.EOF do
  begin
    DestTable.Append;
    For FieldIndex := 0 to FieldCount-1 do
      DestTable.Fields[FieldIndex].Value :=
        SourceTable.Fields[FieldIndex].Value;
    DestTable.Post;
    SourceTable.Next;
    Inc(RecordIndex);
    Synchronize(UpdateProgress);
    Application.ProcessMessages;
  end;

  DestTable.Close;
  DestTable.Exclusive := True;
  SourceTable.Close;
  UpdateStatus('Transfer complete');

  //rename (by copy with force) newtxnlog
  UpdateStatus('Renaming files');
  CopyFiles(ExtractFilePath(SourceTableFileName)+'newtxnlog.*',
  					ExtractFilePath(SourceTableFileName)+'txnlog.*');

	//delete new txnlog
	DeleteFiles(ExtractFilePath(SourceTableFileName)+'newtxnlog.*');

  SourceTable.Free;
  DestTable.Free;
end;


procedure TTruncateThread.UpdateProgress();
const
  TimeStarted : TDateTime = 0;
var
  TimeLeft    : TDateTime;
  TimeElapsed : TDateTime;
  Hour, Min, Sec, MSec : Word;
begin
  If RecordIndex <= 1 then TimeStarted := Now;
  If RecordIndex Mod 100 = 0 then //only update every 100 records
  begin
    TimeElapsed := (Now -TimeStarted);
    TimeLeft    := (RecordCount - RecordIndex) * TimeElapsed / RecordIndex;
    DecodeTime(TimeLeft, Hour, Min, Sec, MSec);
    TxnlogTruncateForm.StatusBar.Panels[0].Text := Format('Processing record %d of %d - estimated time left %2.2d:%2.2d:%2.2d',
                                                    [RecordIndex, RecordCount, Hour, Min, Sec]);
  end;

end;


procedure TTruncateThread.Execute;
var
	AliasParams : TStringList;
begin
  try
    FreeOnTerminate := True;
    AliasParams := TStringList.Create;
    try
      Session.GetAliasParams('PSL', AliasParams);
      AliasPath  := AliasParams.Values['PATH'];
      UpdateStatus('Path <' + AliasPath + '>');
      CompactTable(	AliasPath + '\txnlog', AliasPath + '\newtxnlog',
                  'period > ' + IntToStr(
                              StrToIntDef(TxnlogTruncateForm.LastPeriodEdit.Text,0)
                              - StrToIntDef(TxnlogTruncateForm.KeepPeriodSpinEdit.Text,0)
                  ));
      Synchronize(FinishedTruncate);
    finally
      AliasParams.Free;
    end;
  except
    On E : Exception do
      TxnlogTruncateForm.AppException(self, E);

  end;

end;


procedure TTruncateThread.FinishedTruncate;
var
  BeforeSize, AfterSize : Integer;

begin
  try
    Screen.Cursor := crDefault;
    TxnlogTruncateForm.TruncateButton.Enabled := True;
    BeforeSize := SizeFiles(AliasPath + '\Bak_txnlog.*') div 1024;
    AfterSize  := SizeFiles(AliasPath + '\txnlog.*') div 1024;
    UpdateStatus(Format('Truncate complete - database size changed from %dk to %dk ',
                        [BeforeSize ,AfterSize ])
                   );
    TScanThread.Create(False);
  except
    On E : Exception do
      TxnlogTruncateForm.AppException(self, E);

  end;

end;

procedure TScanThread.Execute;
begin
  try
   FreeOnTerminate := True;
   TxnlogTruncateForm.TxnLogQuery.Active := True;
   TxnlogTruncateForm.TxnLogQuery.First;
   FirstPeriod 											:= TxnlogTruncateForm.TxnLogQueryPeriod.Value;
   TxnlogTruncateForm.TxnLogQuery.Last;
   LastPeriod 												:= TxnlogTruncateForm.TxnLogQueryPeriod.Value;
   TxnlogTruncateForm.TxnLogQuery.Active := False;
   Synchronize(ReadyToTruncate);
  except
    On E : Exception do
      TxnlogTruncateForm.AppException(self, E);

  end;
end;

procedure TScanThread.ReadyToTruncate;
begin
  try
    TxnlogTruncateForm.FirstPeriodEdit.Text := IntToStr(FirstPeriod);
    TxnlogTruncateForm.LastPeriodEdit.Text 	:= IntToStr(LastPeriod);
    TxnlogTruncateForm.KeepPeriodSpinEdit.Value := LastPeriod - FirstPeriod  +1;	//default to no truncate
    UpdateStatus('Ready to Truncate - backup Txnlog before proceeding');
    TxnlogTruncateForm.TruncateButton.Enabled := True;
  except
    On E : Exception do
      TxnlogTruncateForm.AppException(self, E);

  end;

end;


procedure TTxnlogTruncateForm.TruncateButtonClick(Sender: TObject);
begin
	Screen.Cursor := crHourGlass;
  TruncateButton.Enabled := False;
  UpdateStatus(Format('Truncating - First period <%s>, Last Period <%s>, Number Periods to Keep <%s>',
                                  [FirstPeriodEdit.Text, LastPeriodEdit.Text, KeepPeriodSpinEdit.Text]));
  TTruncateThread.Create(False);
end;

procedure TTxnlogTruncateForm.CloseButtonClick(Sender: TObject);
begin
	Close;
end;

procedure TTxnlogTruncateForm.FormCreate(Sender: TObject);
begin
  Application.OnException := AppException;
	Screen.Cursor := crHourGlass;
  try
		UpdateStatus('Scanning TxnLog - please wait');
    TScanThread.Create(False);
  finally
  	Screen.Cursor := crDefault;
  end;

end;

end.
