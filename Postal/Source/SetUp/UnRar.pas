unit UnRar;
{===========================================================================
 <Synopsis> Contains class TUnRAR which implements Methods for UnRARing *.RAR files.

 <Description> Makes use of the 'UnRAR.dll' library which contains various functions
               and procedures for extracting *.RAR files. These are then made availble
               through clients of the

 <Author>  Nick Tsirides
____________________________________________________________________________}

interface
uses
  Stringutil,
  Windows, Dialogs, Stdctrls, SysUtils, Classes;

type
{============================================================================
   <Synopsis>  Holds the header data for each item in the RAR file

   <Description> Each Data item within the RAR file is stored with a header of
                 the format of TRARHeader data.  It is necessary for the header
                 to be read before extraction of each data item.
_____________________________________________________________________________}
  TRARHeaderData = record
    ArcName     : Array[0..259] of Char;
    FileName    : Array[0..259] of Char;
    Flags       : UINT;
    PackSize    : UINT;
    UnpSize     : UINT;
    HostOS      : UINT;
    FileCRC     : UINT;
    FileTime    : UINT;
    UnpVer      : UINT;
    Method      : UINT;
    FileAttr    : UINT;
    CmtBuf      : PChar;
    CmtBufSize  : UINT;
    CmtSize     : UINT;
    CmtState    : UINT;
  end;
  PRARHeaderData = ^TRARHeaderData;


{============================================================================
   <Synopsis> Holds Archive Data for RAR file

   <Description> A record of this type must be passed as a parameter when opening
                 a RAR file.  It is then populated with the relevant data about the
                 archive.
_____________________________________________________________________________}
  TRAROpenArchiveData = record
    ArcName     : PChar;
    OpenMode    : UINT;
    OpenResult  : UINT;
    CmtBuf      : PChar;
    CmtBufSize  : UINT;
    CmtSize     : UINT;
    CmtState    : UINT;
  end;
  PRAROpenArchiveData = ^TRAROpenArchiveData;


{============================================================================
   <Synopsis>  Class for extracting data from *.RAR files

   <Description>  This class contains various Methods for opening/closing RAR
                  files and extracting the data from them.  These methods are
                  implemented through the use of the external dll file - 'UnRAR.dll'
_____________________________________________________________________________}
  TUnRAR = Class
  protected
    FDLLhandle        : HModule; { Storage for the Handle of UnRAR.dll }
  public
    BaseDirectory     : String;  { Installation Root Path eg 'C:\Bermuda' }
    BinaryDirectory   : String;  { Path for the Binary DIR eg 'C:\Bermuda\Binary' }
    LinkName          : String;  { FileName for the StartMenu Shortcut eg 'BermudaPost.lnk }
    ErrorLog          : TStringList;
    constructor Create(DllPath : String);
    destructor Destroy; override;
    procedure LogError (ErrorCode:Integer; FileName:String);
    function Open(FileName : String; var FileHandle:THandle) : Integer;
    function CountFiles (FileHandle : THandle) : Integer;
    function ExtractDataItem (FileHandle : THandle; UnRARPath : PChar) : Integer;
    function GetFileList(FileName : String) : String;
    procedure Close(FileHandle:THandle);
  end;

  TChangeVol       = function (ArcName:PChar;Mode:Integer):Integer; cdecl export;
  TProcessDataProc = function (Addr:PChar;Size:Integer):Integer; cdecl export;

const
  ERAR_END_ARCHIVE    = 10;    { Return - Use to terminate Extract Loop }
  ERAR_NO_MEMORY      = 11;    { Return - Not enough memory to extract comments }
  ERAR_BAD_DATA       = 12;    { Return - Bad Data in File }
  ERAR_BAD_ARCHIVE    = 13;    { Return - Volume is not valid RAR archive }
  ERAR_UNKNOWN_FORMAT = 14;    { Return - Unknown format }
  ERAR_EOPEN          = 15;    { Return - Volume open error }
  ERAR_ECREATE        = 16;    { Return - File create error }
  ERAR_ECLOSE         = 17;    { Return - File close error }
  ERAR_EREAD          = 18;    { Return - Read error }
  ERAR_EWRITE         = 19;    { Return - Write error }
  ERAR_SMALL_BUF      = 20;    { Return - Buffer too small, comments not completely read }

  E_FILEDELETION      = 21;

  RAR_OM_LIST         =  0;    { Open RAR File in List mode - Faster but cant extract }
  RAR_OM_EXTRACT      =  1;    { Open RAR File in Extract Mode - Slower Skip than List Mode }

  RAR_SKIP            =  0;    { Skip Data Item - Dont Extract }
  RAR_TEST            =  1;    { Test Data Item - Check Validity }
  RAR_EXTRACT         =  2;    { Extract Data Item - UnRAR }

  RAR_VOL_ASK         =  0;    { Return - Required Volume is absent }
  RAR_VOL_NOTIFY      =  1;    { Return - Required Volume is Sucessfully opened }

implementation

uses
 CorvusSetupFU;

var
  RAROPenArchiveFunc  : function (ArchiveData : PRAROpenArchiveData) : THandle; stdcall;
  RARCloseArchiveFunc : function (hArcData : THandle) : Integer; stdcall;
  RARReadHeaderFunc   : function (hArcData : THandle; HeaderData : PRARHeaderData) : Integer; stdcall;
  RARProcessFileFunc  : function (hArcData : THandle; Operation : Integer; DestPath, DestName : PChar): Integer; stdcall;
  RARSetChangeVol     : procedure (hArcData : THandle; ChangeVol:TChangeVol); stdcall;
  RARSetProcessData   : procedure (hArcData:THandle; ProcessDataProc:TProcessDataProc); stdcall;
  RARSetPass          : procedure (hArcData:THandle; Password:PChar); stdcall;


function ShouldExtractThisFile(FullFileName : String) : Boolean;
var
  FileName : String;
begin
  Result    := True;
  FileName  := UpperCase(ExtractFileName(FullFileName));

  //txnlog database
  if  (LeftOf( FileName,'TXNLOG') and (FileName <> 'TXNLOG.EXE')) //txnlog database
  and (SetupForm.KeepTransactionsCheckBox.Checked)                //want to keep existing database
  and FileExists(FullFileName) then                   //there IS an existing txnlog database
  begin
    Result := False
  end;

  //stock
  if  (FileName = 'STOCK.DAT')                                    //stock file
  and (SetupForm.KeepStockCheckBox.Checked)                       //want to keep stock
  and FileExists(FullFileName) then                   //there IS an existing stock file
  begin
    Result := False;
  end;

  //customers
  if  (LeftOf( FileName,'CUSTOMER') )                             //customer database
  and (SetupForm.KeepCustomersCheckBox.Checked)                   //want to keep existing database
  and FileExists(FullFileName) then                   //there IS an existing customer database
  begin
    Result := False
  end;

  //MoneyOrders
  if  (LeftOf( FileName,'MO') )                                   //customer database
  and (SetupForm.KeepMoneyOrdersCheckBox.Checked)                 //want to keep existing database
  and FileExists(FullFileName) then                   //there IS an existing customer database
  begin
    Result := False
  end;

end;

//function RAROpenArchive(ArchiveData : PRAROpenArchiveData) : THandle; stdcall; external UnRARdll;
//function RARCloseArchive(hArcData : THandle) : Integer; stdcall; external UnRARdll;
//function RARReadHeader(hArcData : THandle; HeaderData : PRARHeaderData) : Integer; stdcall; external UnRARdll;
//function RARProcessFile(hArcData : THandle; Operation : Integer; DestPath, DestName : PChar): Integer; stdcall; external UnRARdll;
//procedure RARSetChangeVolProc(hArcData : THandle; ChangeVol:TChangeVol); stdcall; external UnRARdll;
//procedure RARSetProcessDataProc(hArcData:THandle; ProcessDataProc:TProcessDataProc); stdcall; external UnRARdll;
//procedure RARSetPassword(hArcData:THandle; Password:PChar); stdcall; external UnRARdll;

{============================================================================
   <Synopsis>  Constructor method for TUnRAR class

   <Description>  This constructor calls the inherited create, loads the
                  DLL library and references the the external functions to
                  variables defined within this unit

   <DllPath>      Parameter which contains the path where UnRAR.dll is located
_____________________________________________________________________________}
constructor TUnRAR.Create(DllPath : String);
begin
  inherited Create;
  // Loading the dll Library
  FDLLHandle := LoadLibrary(PChar(DllPath));
  //Referencing UnRAR.dll function and procedure calls
  RAROpenArchiveFunc  := GetProcAddress(FDLLHandle, 'RAROpenArchive');
  RARCloseArchiveFunc := GetProcAddress(FDLLHandle, 'RARCloseArchive');
  RARReadHeaderFunc   := GetProcAddress(FDLLHandle, 'RARReadHeader');
  RARProcessFileFunc  := GetProcAddress(FDLLHandle, 'RARProcessFile');
  RARSetChangeVol     := GetProcAddress(FDLLHandle, 'RARSetChangeVol');
  RARSetProcessData   := GetProcAddress(FDLLHandle, 'RAROpenArchive');
  RARSetPass          := GetProcAddress(FDLLHandle, 'RAROpenArchive');
  LinkName:='';
  ErrorLog:=TStringList.Create;
end;


{============================================================================
   <Synopsis>  Destructor method for TUnRAR class

   <Description>  Frees the DLL library then calls the inherited Destroy.
_____________________________________________________________________________}
Destructor TUnRAR.Destroy;
begin
  FreeLibrary(FDllHandle);
  ErrorLog.Free;
  inherited Destroy;
end;


{============================================================================
   <Synopsis>    Opens the RAR file for Extraction

   <Description> Opens the RAR file through the use of the External function
                 'RAROpenArchive' and sets the Open Mode as EXTRACT

   <FileName>    Full path and FileName of the .RAR file

   <FileHandle>  This parameter will be set with a Handle to the RAR file which
                 will then be used by the program to access the archive

   <Result>      Integer value which returns an error code for the open function.
                 0 = sucessful open
_____________________________________________________________________________}
function TUnRAR.Open(FileName : String; var FileHandle:THandle) : Integer;
var
  ArchiveData : TRAROpenArchiveData;  { Record Type - used to read and set archive values }
begin
  with ArchiveData do
  begin
    ArcName := PChar(FileName);
    OpenMode:= RAR_OM_EXTRACT;
    CmtBuf  := nil;
  end;
  FileHandle:=RAROpenArchiveFunc(@ArchiveData);
  Result:=ArchiveData.OpenResult;
end;



{============================================================================
   <Synopsis>     Closes the Archive File

   <Description>  Closes the archive file and outputs an error message
                  if CloseStatus <> 0

   <FileHandle>   Windows Reference to the RAR file

   <PreCondition> Archive is open
_____________________________________________________________________________}
procedure TUnRAR.Close(FileHandle:THandle);
var
  CloseStatus : Integer;  { Return value External Close Function - 0 = good close }
begin
  CloseStatus:=RARCloseArchiveFunc(FileHandle);
  if CloseStatus = ERAR_ECLOSE then
    showmessage ('Archive Close Error');
end;


{============================================================================
   <Synopsis>     Counts the Files (Data Items) in the RAR file

   <Description>  Seeks through the currently opened RAR file and counts the
                  number of items that it contains.

   <PreCondition> Archive is open
_____________________________________________________________________________}
function TUnRAR.CountFiles (FileHandle : THandle) : Integer;
var
  ArchiveHeaderData : TRARHeaderData; { Header Record type which holds Data item header values }
  FileCount         : Integer;        { Integer couter for Data Items }
  HeaderStatus      : Integer;        { Result value for a Header Read }
  ProcessStatus     : Integer;        { Result value for a Data Item Read}
begin
  FileCount:=0;
  HeaderStatus:=RARReadHeaderFunc(FileHandle, @ArchiveHeaderData);
  while HeaderStatus = 0 do
  begin
    Inc(FileCount);
    ProcessStatus:=RARProcessFileFunc(FileHandle, RAR_SKIP, nil, nil);
    if ProcessStatus = 0 then
       HeaderStatus:=RARReadHeaderFunc(FileHandle, @ArchiveHeaderData);
  end;
  Result:=FileCount;
  Close(FileHandle);
end;


{============================================================================
   <Synopsis>     Extracts a Data Item from the RAR file

   <Description>  Extracts the current data item from the RAR file.  The binary
                  file path is stored when Compman.exe is found also, if the current
                  item is a shortcut then its filename is saved.

   <FileHandle>   Windows Reference to the RAR file

   <UnRARPath>    Pointer to a string which contains the path for the RAR
                  file to be extracted to.

   <PreCondition> Archive is open.

   <Result>       Integer return value which holds the value of the Data Item
                  Header Status, 0=good header read
_____________________________________________________________________________}
function TUnRAR.ExtractDataItem (FileHandle : THandle; UnRARPath : PChar) : Integer;
var
  ArchiveHeaderData : TRARHeaderData; { Header Record type which holds Data item header values }
  HeaderStatus      : Integer;        { Result value for a Header Read }
  CurrentFileName   : String ;        { Pathname of the Current File being Extracted }
  FileNameBufferPtr : PChar  ;        { Pointer to the FileName in the Header Data Record }
  P                 : PChar  ;        { FileName from the Header (without the garbage at the end }
  NameLength        : Integer;        { Number of Characters that make up the FileName pointed to by 'P' }

begin
  HeaderStatus:=RARReadHeaderFunc(FileHandle, @ArchiveHeaderData);
  if HeaderStatus = 0 then
  begin
    FileNameBufferPtr:=ArchiveHeaderData.FileName;
    P:=FileNameBufferPtr;
    while P^ <> #0 do
      Inc(P);
    NameLength:=P-FileNameBufferPtr;
    SetString(CurrentFileName,ArchiveHeaderData.FileName,NameLength);
    // search for specific files
    if UpperCase(ExtractFileName(CurrentFileName)) = 'COMPMAN.EXE' then
      BinaryDirectory:=ExtractFilePath(CurrentFileName);
    if UpperCase(ExtractFileExt(CurrentFileName)) = '.LNK' then
      LinkName:=ExtractFileName(CurrentFileName);

    //check this file should be extracted
    If ShouldExtractThisFile(UnRarPath + CurrentFileName) then
    begin
      if FileExists(UnRarPath + CurrentFileName) then
      begin
        FileSetAttr(UnRarPath + CurrentFileName,
                    FileGetAttr(UnRarPath + CurrentFileName) and (not faReadOnly));
        if not(DeleteFILE(UnRarPath + CurrentFileName)) then
          LogError(21,UnRarPath + CurrentFileName);
      end;
      Result:=RARProcessFileFunc(FileHandle, RAR_EXTRACT, UnRARPath, nil)
    end
    else { extract to rubbish directory }
      Result:=RARProcessFileFunc(FileHandle, RAR_EXTRACT, 'C:\CorvTemp', nil)

  end
  else
    Result:=HeaderStatus;
  if Result <> 0 then
    LogError(Result,CurrentFileName);
end;


procedure TUnRAR.LogError (ErrorCode:Integer; FileName:String);
begin
  case ErrorCode of
    {File Extract Errors}
   // ERAR_END_ARCHIVE    : ErrorLog.Add('End of Archive Reached');
    ERAR_UNKNOWN_FORMAT : ErrorLog.Add('ERROR '+FileName+' : Unknown Archive format');
    ERAR_EOPEN          : ErrorLog.Add('ERROR '+FileName+' : Volume open error');
    ERAR_ECREATE        : ErrorLog.Add('ERROR '+FileName+' : File create error');
    ERAR_ECLOSE         : ErrorLog.Add('ERROR '+FileName+' : File close error');
    ERAR_EREAD          : ErrorLog.Add('ERROR '+FileName+' : Read error');
    ERAR_EWRITE         : ErrorLog.Add('ERROR '+FileName+' : Write error');

    E_FILEDELETION      : ErrorLog.Add('Unable To Delete : '+FileName);
    {Open Archive Errors}
    ERAR_BAD_DATA       : ErrorLog.Add('ERROR '+FileName+' : Bad Data in File (CRC Error)');
    ERAR_BAD_ARCHIVE    : ErrorLog.Add('ERROR '+FileName+' : Volume is not valid RAR archive');
    ERAR_NO_MEMORY      : ErrorLog.Add('ERROR '+FileName+' : Not enough memory to extract comments');
    ERAR_SMALL_BUF      : ErrorLog.Add('ERROR '+FileName+' : Buffer too small, comments not completely read');
  end;
end;

{ PRE : Archive is not already open
 POST : StringList is returned containg all the filepaths within the archive }
function TUnRAR.GetFileList(FileName : String) : String;
var
  ArchiveHeaderData : TRARHeaderData; { Header Record type which holds Data item header values }
  HeaderStatus      : Integer;        { Result value for a Header Read }
  CurrentFileName   : String ;        { Pathname of the Current File being Extracted }
  FileNameBufferPtr : PChar  ;        { Pointer to the FileName in the Header Data Record }
  P                 : PChar  ;        { FileName from the Header (without the garbage at the end }
  NameLength        : Integer;        { Number of Characters that make up the FileName pointed to by 'P' }
  FileList          : TStringList;
  FileHandle        : THandle;

begin
  Open(FileName, FileHandle);
  HeaderStatus:=0;
  FileList:=TStringList.Create;
  while not(HeaderStatus = 10){EOF} do
  begin
    HeaderStatus:=RARReadHeaderFunc(FileHandle, @ArchiveHeaderData);
    if HeaderStatus = 0 then
    begin
      FileNameBufferPtr:=ArchiveHeaderData.FileName;
      P:=FileNameBufferPtr;
      while P^ <> #0 do
        Inc(P);
      NameLength:=P-FileNameBufferPtr;
      SetString(CurrentFileName,ArchiveHeaderData.FileName,NameLength);
      FileList.Add(CurrentFileName);
    end;
    RARProcessFileFunc(FileHandle, RAR_SKIP, nil, nil);
  end;
  Result:=FileList.CommaText;
  FileList.Free;
  Close(FileHandle);
end;


end.
