unit CorvusSetupFU;
{===========================================================================
 <Synopsis> Extracts the RAR file and installs the application to the 'c:\'

 <Description> The RAR file is extracted from the binary resource and stored in
               'C:\CorvTemp' along with the 'UnRAR.dll'.  The RAR file is then
               extracted and 'C:\CorvTemp' is Deleted. Finally '...\Binary\install.bat'
               is executed, calling compman and registering the rgl file.

 <Author>  Nick Tsirides
____________________________________________________________________________}

interface        
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,GPCSGUID,WinExecU,ComServ2, UnRAR, ComCtrls, FileCtrl,
  MPDelTreeU, ExtCtrls,FileTxStatusU;

type
{============================================================================
  <Synopsis>  Used to execute RAR file extraction within a thread

  <Description> Overrides and defines an 'Execute' procedure which extracts
                files within a thread but also frees some processor time in
                order for the progress bar to be updated
_____________________________________________________________________________}
  TCopyThread = class (TThread)
  public
    Complete:Boolean;   { Set to true once extraction is complete }
    procedure Execute; override;
  end;


{============================================================================
  <Synopsis>  The main Form class

  <Description> Definition class for the main form 'SetupForm'
_____________________________________________________________________________}
  TSetupForm = class(TForm)
    Timer: TTimer;
    BottomPanel: TPanel;
    MainPanel: TPanel;
    MainPageControl: TPageControl;
    ConfigTabSheet: TTabSheet;
    KeepTransactionsDaysLabel: TLabel;
    WSIdentLabel: TLabel;
    DaysToKeep: TEdit;
    CustDisp: TCheckBox;
    WSIdent: TEdit;
    KeepTransactionsCheckBox: TCheckBox;
    CorvusImage: TImage;
    InstallTabSheet: TTabSheet;
    DecompProgress: TProgressBar;
    InstallProgressTitlePanel: TPanel;
    ErrorLogTabSheet: TTabSheet;
    ErrorLogTitlePanel: TPanel;
    InstallMemo: TMemo;
    ErrLogMemo: TMemo;
    DeCompLabel: TLabel;
    KeepStockCheckBox: TCheckBox;
    KeepCustomersCheckBox: TCheckBox;
    KeepMoneyOrdersCheckBox: TCheckBox;
    ButtonPanel: TPanel;
    NextButton: TButton;
    CancelButton: TButton;
    BackButton: TButton;
    ConfigTitlePanel: TPanel;
    Label1: TLabel;
    OfficeCode: TEdit;
    KeepDevSettings: TCheckBox;
    KeepExcngRates: TCheckBox;       { Corvus Logo }
    procedure NextButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure BackButtonClick(Sender: TObject);
  protected
  private
    { Private declarations }
  public
    { Public declarations }
    DelTree        : TMPDelTree;
    procedure InstallFiles;
    procedure NavButtonClick(Sender: TObject);
  end;

const
  EXTRACTION_PATH = 'C:\';
  TEMPORARY_PATH  = 'C:\CorvTemp';
  ARCHIVE_PATH    = 'C:\CorvTemp\Corvus.RAR';
  UNRARDLL_PATH   = 'C:\CorvTemp\UnRAR.dll';
  REGBAT_PATH     = 'Install.bat';

var
  SetupForm     : TSetupForm;  { Main form 'SetupForm' }
  KeepList      : TStringList;

implementation

var
  Stop          : Boolean;     { Determines whether installation has been cancelled }
  CopyThread    : TCopyThread; { Used to execute the thread for progress bar update }
  Archive       : TUnRAR;      { Used for checking and extraction of the *.RAR file }

{$R *.DFM}

{============================================================================
  <Synopsis> Deletes the Temporary Files Directory

  <Description>  Deletes the Temporary Files Directory 'CorvTemp'
                 (whether it exists or not)
_____________________________________________________________________________}
procedure DelTempFiles;
begin
  SetupForm.DelTree.Path:=TEMPORARY_PATH;
  SetupForm.DelTree.Execute;
end;

{============================================================================
  <Synopsis> Checks PSL registry to see if Customer Display is enabled

  <Description> If Customer Display is enabled in the registrys configuration then
                the checkbox is set to TRUE.  Also the WorkStation ID is set to
                the equivalent registry value.
_____________________________________________________________________________}
procedure TSetupForm.FormCreate(Sender: TObject);
var
  Resource      : TResourceStream;{ Extracts Binary Resources of RAR file and UnRAR.dll }

begin
  Caption := Caption + ' - ' + Application.ExeName;
  DelTree:=TMPDelTree.Create(nil);
  InsertComponent(DelTree);
  DelTree.Path:='<..>';
  DelTree.Verbose:=False;
  DaysToKeep.Text:=GetGPCSRegString('','Transaction Periods To Keep','7');
  if DaysToKeep.Text = '0' then DaysToKeep.Text:='All';
  OfficeCode.Text:=GetGPCSRegString('OfficeInfo','Office ID','1000');
  WSIdent.Text:=GetGPCSRegString('WorkStation','Ident','1');
  if GetGPCSRegString('DeviceEnabled','CustDisp','1') = '1' then
    CustDisp.Checked:=True
  else
    CustDisp.Checked:=False;

  // Extracting Resource Data and Saving it to Disk
  try
    DelTempFiles;
    ForceDirectories(TEMPORARY_PATH);

    Resource:=TResourceStream.Create(HInstance, 'RARFILE' , RT_RCDATA);
    Resource.Position:=0;
    Resource.SaveToFile(ARCHIVE_PATH);
    Resource.Free;

    Resource:=TResourceStream.Create(HInstance, 'RARDLL' , RT_RCDATA);
    Resource.Position:=0;
    Resource.SaveToFile(UNRARDLL_PATH);
    Resource.Free;
  except
    ShowMessage('Error extracting Setup Resource Files');
  end;

  MainPageControl.ActivePage := ConfigTabSheet;
end;



{============================================================================
  <Synopsis> Calls 'Install Files' and allocates processor time for the Timer

  <Description> Calls the main procedure of the program 'Install Files' and allocates
            processor time for the Timer
_____________________________________________________________________________}
procedure TCopyThread.Execute;
begin
  while not(Complete) do
  begin
    try
      CopyThread.Synchronize(SetUpForm.InstallFiles);
      Application.ProcessMessages
    except
    end;
  end;
end;


{============================================================================
  <Synopsis> Increments the progress bar appropriately - for every timer interval

  <Description> Increments the progress bar by different amounts - depending on
                 which part of the installation process it is at.

  <Sender>     Detects which object called the procedure
_____________________________________________________________________________}
procedure TSetupForm.TimerTimer(Sender: TObject);
begin
  if SetUpForm.DeCompLabel.Caption = 'Extracting Archive File' then
    SetUpForm.DeCompProgress.Position:=SetUpForm.DeCompProgress.Position+4;

  if SetUpForm.DeCompLabel.Caption = 'Registering Corvus Components' then
    SetUpForm.DeCompProgress.Position:=SetUpForm.DeCompProgress.Position+2;
end;


{============================================================================
   <Synopsis> Creates and Resumes CopyThread's 'Execute' procedure

   <Description> The Thread CopyThread is Created and executed.  The Boolean
                 complete is set to FALSE

   <Sender>     Detects which object called the procedure
_____________________________________________________________________________}
procedure TSetupForm.NextButtonClick(Sender: TObject);
var
   S:String;
begin
  If MainPageControl.ActivePage = ConfigTabSheet then
  begin
    BackButton.Visible := True;
    InstallMemo.Lines.Clear;
    InstallMemo.Lines.Add('Install:');
    InstallMemo.Lines.Add('  Office Code '+OfficeCode.Text);
    InstallMemo.Lines.Add('  Workstation Number '+WSIdent.Text);
    InstallMemo.Lines.Add('  Keep Transactions for '+DaysToKeep.Text+' days.');
    if not KeepTransactionsCheckBox.Checked then
       InstallMemo.Lines.Add('  Delete all transactions');
    if not KeepStockCheckBox       .Checked then
       InstallMemo.Lines.Add('  Delete all Stock');
    if not KeepCustomersCheckBox   .Checked then
       InstallMemo.Lines.Add('  Delete all Customers');
    if not KeepMoneyOrdersCheckBox .Checked then
       InstallMemo.Lines.Add('  Delete all MoneyOrders');
    if KeepDevSettings.Checked then
       InstallMemo.Lines.Add('  Keep Current Device Settings');
    if KeepExcngRates.Checked then
       InstallMemo.Lines.Add('  Keep Current Exchange Rates');
       
    InstallMemo.Lines.Add(' ');
    InstallMemo.Lines.Add('      PRESS "INSTALL" TO PROCEED');
    MainPageControl.ActivePage := InstallTabSheet;
    NextButton.caption := '&Install';
  end
  else If MainPageControl.ActivePage = InstallTabSheet then
  begin
    if FileExists('C:\CorvusService\CorvusService.exe') then
       WinExecAndWait('C:\CorvusService\CorvusService.exe -E',S,False);
    NextButton.Enabled:=FALSE;
    BackButton.Enabled := False;
  //  SetUpForm.InstallFiles;
    CopyThread:=TCopyThread.Create(True);
    CopyThread.Complete:=FALSE;
    CopyThread.Resume;
  end;  //case
end;


{============================================================================
   <Synopsis> Asks user for confirmation of cancelation and quits on 'Yes'

   <Description> Shows a MessageDlg box asking the user to confirm whether or
                 not they wish to quit.  If it Returns 'Yes' then the Install
                 and temp file directories are deleted

   <Sender>     Detects which object called the procedure
_____________________________________________________________________________}
procedure TSetupForm.CancelButtonClick(Sender: TObject);
begin
  if MessageDlg('Are you sure you want to Cancel the Installation ?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      Stop:=TRUE;
      // Deletion of Installed Files
      if Archive <> nil then
      begin
         DelTree.Path:=Archive.BaseDirectory;
         DelTree.Execute;
      end;
      if ComServer.StartMode = smRegServer then
         ModalResult:=mrCancel
      else
         Close;
    end;
end;


{============================================================================
  <Synopsis> Called by 'TCopyThread.Execute' and Executes the main program content

  <Description> Called by 'TCopyThread.Execute' and Executes the main program content,
                eg Extraction and unRARing of files.
_____________________________________________________________________________}
procedure TSetUpForm.InstallFiles;
var
  FileHandle    : THandle;        { Holds the Handle for the RAR file - passed on RAR Open }
  OpenStatus    : Integer;        { Validation return for file open - 0=good open }
  ArchiveStatus : Integer;        { Validation return for the RAR data item Header - 0=good }
  CurrDir       : String;         { Stores current DIR before the app changes Directory }
  s             : String;         { Screen output from Executing ..\binary\install.bat }
  i             : Integer;        { iterative counter }
  LnkSource     : String;         { Holds the source path and filename for the App Shortcut }
  LnkDest       : String;         { Holds the dest path and filename for the App Shortcut }
  FileList      : TStringList;
  FileStatusMon : TFileStatusMon; { for Address details from Office.ori }
  Office        :Integer;
  ReportsFile:String;
  ER,DS:String;
begin
  DeCompLabel.Caption:='Extracting Archive File';
  DeCompLabel.Refresh;
  Application.ProcessMessages;

  DeCompProgress.Position:=0;
  DeCompProgress.Max:=100;

  DeCompProgress.Position:=0;

  // Counting Data Items in Archive
  Archive := TUnRar.Create(UNRARDLL_PATH);
  Archive.BinaryDirectory:='';
  DeCompLabel.Caption:='Removing Existing Files';
  FileList:=TStringList.Create;
  FileList.CommaText:=Archive.GetFileList(ARCHIVE_PATH);
  SetupForm.DecompProgress.Max:=FileList.Count-1;

  // Extracting Data Items from Archive
  CopyThread.Complete:=TRUE;
  DeCompLabel.Caption:='Extracting files...';
  Application.ProcessMessages;
  OpenStatus:=Archive.Open(ARCHIVE_PATH, FileHandle);
  if OpenStatus = 0 then
  begin
    Stop:=FALSE;
    ArchiveStatus:=0;
    DeCompProgress.Position:=0;
    while not(ArchiveStatus = 10){EOF} and not(Stop) do
    begin
      ArchiveStatus:=Archive.ExtractDataItem(FileHandle, PChar(EXTRACTION_PATH));
      DeCompProgress.Position:=DeCompProgress.Position+1;
      Application.ProcessMessages;
      if SetupForm.ErrLogMemo.Lines.Count <> Archive.ErrorLog.Count then
        SetupForm.ErrLogMemo.Lines:=Archive.ErrorLog;
      InstallMemo.Lines.Add(FileList.Strings[SetupForm.DecompProgress.Position])
    end;
    DeCompProgress.Position:=0;
    Archive.Close(FileHandle);
  end
  else
    ShowMessage('Error ' + IntTOStr(OpenStatus) + ' Unable to open Archive ');

  // Derive install path from RAR and store in string eg 'C:\Bermuda'
  Archive.BinaryDirectory:=EXTRACTION_PATH + Archive.BinaryDirectory;
  Archive.BaseDirectory:='C:\OhBugger';
  for I:=4 to Length(Archive.BinaryDirectory) do
  begin
    if Archive.BinaryDirectory[I] = '\' then
    begin
      Archive.BaseDirectory:=Copy(Archive.BinaryDirectory,1,I-1);
      break;
    end;
  end;

  if not(Stop) then
    DeCompLabel.Caption:='Registering Corvus Components';
  Application.ProcessMessages;

  GetDir(0,CurrDir); // Save current Directory
  // Change to Application Root Path Directory
  ChDir(Copy(Archive.BinaryDirectory,1,Length(Archive.BinaryDirectory)-1));
  
  if KeepExcngRates.Checked then
     ER:=GetPSLNamesValues('GPCS\ExchangeRates');
  if KeepDevSettings.Checked then
     DS:=GetPSLNamesValues('GPCS\DeviceSetup');
     
  // Run the install batch file
  if not(Stop) then
    if FileExists(REGBAT_PATH) then
      WinExecAndWait(REGBAT_PATH,S,False);
      
  if KeepExcngRates.Checked then
     SetPSLNamesValues('GPCS\ExchangeRates',ER);
  if KeepDevSettings.Checked then
     SetPSLNamesValues('GPCS\DeviceSetup',DS);
     
  With TStringList.Create do
  begin
    try
      Text := S;
      SaveToFile(REGBAT_PATH + '.log');
    finally
      Free;
    end;
  end;

  // Set the Workstation Ident
  SetGPCSRegString('WorkStation','Ident',WSIdent.Text);
  
  try
     if FileExists(ExtractFilePath(ParamStr(0))+'Offices.ori.replace') then
        CopyFile(PChar(ExtractFilePath(ParamStr(0))+'Offices.ori.replace'),PChar('C:\CorvusService\Offices.ori'),False);
  except
     on E:Exception do ShowMessage('Could not replace Offices.ori - '+E.Message);
  end;   

  ReportsFile:=GetGPCSRegString('Reports','Definition File','C:\General Report Formats.ids');
  try
     if FileExists(ExtractFilePath(ParamStr(0))+ExtractFileName(ReportsFile)+'.replace') then
        CopyFile(PChar(ExtractFilePath(ParamStr(0))+ExtractFileName(ReportsFile)+'.replace'),PChar(ReportsFile),False);
  except
     on E:Exception do ShowMessage('Could not replace '+ExtractFileName(ReportsFile)+' - '+E.Message);
  end;   
  
  SetGPCSRegString('OfficeInfo','Office ID',OfficeCode.Text);
  
  try
     Office:=StrToIntDef(OfficeCode.Text,1000);
     FileStatusMon:=TFileStatusMon.Create(nil);
     SetGPCSRegString('OfficeInfo','Office Name'   ,FileStatusMon.OfficeTitleFromCode  (Office));
     SetGPCSRegString('OfficeInfo','Office Address',FileStatusMon.OfficeAddressFromCode(Office));
     SetGPCSRegString('OfficeInfo','Address Line 1',FileStatusMon.OfficeAddressFromCode(Office));
     SetGPCSRegString('OfficeInfo','Address Line 2',FileStatusMon.OfficePhoneFromCode  (Office));
     FileStatusMon.Free;
  except
     on E:Exception do ShowMessage('Could not setup OfficeInfo - '+E.Message);
  end;   
     
  // Set the Transaction Periods To Keep
  SetGPCSRegString('','Transaction Periods To Keep',IntToStr(StrToIntDef(DaysToKeep.Text,0)));

  // Set the Customer Display Enable Flag
  if CustDisp.Checked then
    SetGPCSRegString('DeviceEnabled','CustDisp','1')
  else
    SetGPCSRegString('DeviceEnabled','CustDisp','0');

  // Restore Directory + copy shortcut to Start Menu
  ChDir(CurrDir);
  LnkSource:=Archive.BinaryDirectory + Archive.LinkName;
  // FIND SYSTEM PATH FOR FOLLOWING LINE !!!!!
  LnkDest:='C:\WinNT\Profiles\All Users\Start Menu\Programs\' + Archive.LinkName;
  CopyFile(PCHAR(LnkSource), PCHAR(LnkDest), FALSE);

  // Exit
  SetUpForm.DeCompProgress.Position:=SetUpForm.DeCompProgress.Max;
  if ErrLogMemo.Lines.Count <> 0 then
  begin
    MainPageControl.ActivePage := ErrorLogTabSheet;
    CancelButton.Enabled:=FALSE;
    Application.ProcessMessages;
  end
  else
    Application.Terminate;
  FileList.Free;
end;


{============================================================================
  <Synopsis>  Frees up Resources

  <Description>  Frees up un-needed objects and deletes the Tempory Files
                 Directory 'C:\CorvTemp'

  <Sender>     Detects which object called the procedure
_____________________________________________________________________________}
procedure TSetupForm.FormDestroy(Sender: TObject);
begin
  CopyThread.Free;
  Archive.Free;
  DelTempFiles;
end;

procedure TSetupForm.PageControl1Change(Sender: TObject);
begin
  ErrLogMemo.Refresh;
  Application.ProcessMessages;
end;

procedure TSetupForm.NavButtonClick(Sender: TObject);
begin

end;

procedure TSetupForm.BackButtonClick(Sender: TObject);
begin
  If MainPageControl.ActivePage.PageIndex > 0 then MainPageControl.ActivePage := MainPageControl.Pages[MainPageControl.ActivePage.PageIndex -1];
  BackButton.Visible := (MainPageControl.ActivePage.PageIndex > 0);
  If MainPageControl.ActivePage = ConfigTabSheet then  NextButton.caption := '&Next';
end;

end.
