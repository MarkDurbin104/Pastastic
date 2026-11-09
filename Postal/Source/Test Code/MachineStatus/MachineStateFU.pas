unit MachineStateFU;

interface

uses
  Windows,Messages,SysUtils,Classes,Graphics,Controls,Forms, 
  Dialogs,Registry,ComCtrls,StdCtrls,DirectoryU,TLHelp32,Printers,
  WinExecU,Compress,GPCSGUID, ExtCtrls,FileCtrl,StringUtil;
  
const
   WM_STARTED = WM_USER+1;
   StatusFile = 'C:\StatusData.ful';
   CompStatusFile = 'C:\StatusData.log';
   InfoFile   = 'C:\StatusData.nfo';
type
  TForm1 = class(TForm)
    Panel1: TPanel;
    PB: TProgressBar;
    Button1: TButton;
    Label2: TLabel;
    Label1: TLabel;
    Panel2: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    IPFile: TEdit;
    OPDir: TEdit;
    ChangeFile: TButton;
    ChangeDir: TButton;
    Extract: TButton;
    OD: TOpenDialog;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ChangeFileClick(Sender: TObject);
    procedure ChangeDirClick(Sender: TObject);
    procedure ExtractClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  public
     procedure WMStarted(var Msg:TMessage); message WM_STARTED;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
function MinSysInfo:String;
var
  MySystem: TSystemInfo;
  Info: TOSVersionInfoA;
  PWindowsDir: array [0..255] of Char;
  MyStatus: TMemoryStatus;
  CompName: array[0..256] of Char;
  i: Integer;
  StrUserName: PChar;
//  MyHandle: THandle;
//  Struct: TProcessEntry32;
  MyPrinter, MyDriver, MyPort: array[0..100] of Char;
  DevMode: THandle;
  ResultLines:TStringList;
const
  Size: Integer = 250;
begin
  ResultLines:=TStringList.Create;
  ResultLines.Add('Names -------------------------------------------');
  i:=256;
  GetComputerName(CompName,i);
  ResultLines.Add('Computer name '+StrPas(CompName));
  
  GetMem(StrUserName, Size);
  GetUserName(StrUserName, Size);
  ResultLines.Add('User name '+StrPas(StrUserName));
  FreeMem(StrUserName);
  
  ResultLines.Add('Directories -------------------------------------');
  GetWindowsDirectory(PWindowsDir,255);
  ResultLines.Add('Windows Dir: '+StrPas(PWindowsDir));
  
  ResultLines.Add('Operating System --------------------------------');
  Info.dwOSVersionInfoSize:=sizeof(Info);                            
  GetVersionEx(Info);
  ResultLines.Add('MajorVersion - '+IntToStr(Info.dwMajorVersion));
  ResultLines.Add('MinorVersion - '+IntToStr(Info.dwMinorVersion));
  ResultLines.Add('BuildNumber - '+IntToStr(Info.dwBuildNumber));
  case Info.dwPlatformID of
    VER_PLATFORM_WIN32s:        ResultLines.Add('Win32 on Windows 3.1');
    VER_PLATFORM_WIN32_WINDOWS: ResultLines.Add('Win32 on Windows 95/98');
    VER_PLATFORM_WIN32_NT:      ResultLines.Add('Win32 on Windows NT');
    else ResultLines.Add('Win32 on platform '+IntToStr(Info.dwPlatformID));
  end;
  ResultLines.Add('Processor --------------------------------------');
  GetSystemInfo(MySystem);          
  with ResultLines do
  begin
    if (MySystem.wProcessorArchitecture=0) then
      Add('Intel architecture');
    Add(FloatToStr(MySystem.dwPageSize)+' Kb page size');
    Add(Format(
      'Lowest memory address accessible to applications and DLLs - %p',
      [MySystem.lpMinimumApplicationAddress]));
    Add(Format(
      'Highest memory address accessible to applications and DLLs - %p',
      [MySystem.lpMaximumApplicationAddress]));
    Add(IntToStr(
      MySystem.dwNumberOfProcessors)+' - number of processors');
    Add(FloatToStr(
      MySystem.dwAllocationGranularity/1024)+
      ' Kb - virtual memory allocation granularity');
    Add('processor level '+IntToStr(MySystem.wProcessorLevel));
    case MySystem.wProcessorLevel of
      3: Add('Intel 80386 processor level');
      4: Add('Intel 80486 processor level');
      5: Add('Intel Pentium processor level');
    end;
  end;
  ResultLines.Add('Memory -----------------------------------------');
  MyStatus.dwLength:=SizeOf(MyStatus);
  GlobalmemoryStatus(MyStatus);
  with ResultLines do
  begin
    Add(FloatToStr(
      MyStatus.dwMemoryLoad)+'% memory in use');
    Add(FloatToStr(
      MyStatus.dwTotalPhys/1024)+' Kb of physical memory');
    Add(FloatToStr(
      MyStatus.dwAvailPhys/1024)+
      ' Kb of available physical memory');
    Add(FloatToStr(
      MyStatus.dwTotalPageFile/1024)+
      ' Kb that can be stored in the paging file');
    Add(FloatToStr(
      MyStatus.dwAvailPageFile/1024)+
      ' Kb available in the paging file');
  end;
//  try
//     MyHandle:=CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
//     Struct.dwSize:=Sizeof(TProcessEntry32);
//     if Process32First(MyHandle, Struct) then
//       ResultLines.Add(Struct.szExeFile);
//     while Process32Next(MyHandle, Struct) do
//       ResultLines.Add(Struct.szExeFile);
//  except
//  end;
  ResultLines.Add('Printers -----------------------------------------');
  try
     Printer.GetPrinter(MyPrinter, MyDriver, MyPort, DevMode);
     ResultLines.Add('Default Printer '+MyPrinter+' '+MyPort);
  except
  end;
  Result:=ResultLines.Text;
  ResultLines.Free;
end;
function GetProgramFilesDir:String;
begin
   Result:='';
   with TRegistry.Create do
   begin
      RootKey:=HKEY_LOCAL_MACHINE;
      if OpenKey('\Software\Microsoft\Windows\CurrentVersion',False) then
      begin
         Result:=ReadString('ProgramFilesDir');
         if Result = '' then
            Result:=ReadString('ProgramFilesPath');
         CloseKey;
      end;
      Free;
   end;
   if Result = '' then
      Result:='C:\Program Files';
end;      
function GetRegKeyData(Path:String;Registry:TRegistry):String;
var
   SL:TStringList;
   Items:TStringList;
   I:Integer;
   S:String;
begin    
   Result:='';
   with Registry do
   begin
      if OpenKey(Path,False) then
      begin
         SL:=TStringList.Create;
         Items:=TStringList.Create;
         SL.Add('['+Path+']');
         GetValueNames(Items);
         for I:=0 to Items.Count-1 do
            SL.Add('"'+Items[I]+'"="'+ReadString(Items[I])+'"');
         GetKeyNames(Items);
         CloseKey;
         for I:=0 to Items.Count-1 do
         begin
            S:=GetRegKeyData(Path+'\'+Items[I],Registry);
            if Trim(S) <> '' then
               SL.Add(S);
         end;
         Items.Free;
         Result:=SL.Text;
         SL.Free;
      end;
   end;
end;         
function GetRegKey(Root:Integer;Path:String):String;
var
   Registry:TRegistry;
begin
   Registry:=TRegistry.Create;
   Registry.RootKey:=Root;
   Result:=GetRegKeyData(Path,Registry);
   Registry.Free;
end;
procedure WriteString(Stream:TStream;Str:String);
var
   StrLength:Integer;
begin
   StrLength:=Length(Str);
   Stream.Write(StrLength,SizeOf(StrLength));
   Stream.Write((@Str[1])^,StrLength);
end;
procedure WriteFile(Stream:TStream;FileName:String);
var
   FS:TFileStream;
   StrLength:Integer;
begin            
   WriteString(Stream,'File Contents:'+FileName);
   if FileExists(FileName) then
   begin
      FS:=TFileStream.Create(FileName,fmOpenRead);
      if FS <> nil then
      begin
         FS.Position:=0;
         StrLength:=FS.Size;
         Stream.Write(StrLength,SizeOf(StrLength));
         Stream.CopyFrom(FS,StrLength);
         FS.Free;
      end;
   end;
end; 
procedure WriteDirInfo(Stream:TStream;Dir:String);
var
   List:TStringList;
   I:Integer;
begin
   WriteString(Stream,'Directory Listing:'+Dir);
   List:=TStringList.Create;   
   FillFileList(Dir,'*.*',True,List);
   for I:=0 to List.Count-1 do
      List[I]:=IntToHex(Integer(List.Objects[I]),8)+' '+List[I];
   WriteString(Stream,List.Text);
   List.Free;
end;
procedure WriteFiles(Stream:TStream;Dir:String);
var
   List:TStringList;
   I:Integer;
begin
   List:=TStringList.Create;
   FillFileList(Dir,'*.*',True,List);
   for I:=0 to List.Count-1 do
   begin
      WriteString(Stream,IntToHex(Integer(List.Objects[I]),8)+' '+List[I]);
      WriteFile(Stream,List[I]);
   end;                  
end;
procedure TForm1.WMStarted(var Msg:TMessage);
var
//   MSInfoDir:String;
   SaveStream:TFileStream;
   MemStream:TMemoryStream;
//   CurDir:String;
//   S:String;
begin
   BringToFront;
   MemStream:=TMemoryStream.Create;
   
   if FileExists(StatusFile) then DeleteFile(StatusFile);
   if FileExists(StatusFile) then 
   begin
      ShowMessage('Cannot Delete Old Status File ('+StatusFile+')'#13#10'Please Re-boot and try again');
      Close;
   end;
      
   if FileExists(CompStatusFile) then DeleteFile(CompStatusFile);
   if FileExists(CompStatusFile) then 
   begin
      ShowMessage('Cannot Delete Old Status File ('+CompStatusFile+')'#13#10'Please Re-boot and try again');
      Close;
   end;
   
   if FileExists(InfoFile) then DeleteFile(InfoFile);
   if FileExists(InfoFile) then 
   begin
      ShowMessage('Cannot Delete Old Status File ('+InfoFile+')'#13#10'Please Re-boot and try again');
      Close;
   end;

   WriteString(MemStream,'System Information:');
   WriteString(MemStream,MinSysInfo);
                                       
{   MSInfoDir:=GetProgramFilesDir+'\Common Files\Microsoft Shared\MSInfo';
   if FileExists(MSInfoDir+'\MSInfo32.exe') then
   begin
      GetDir(0,CurDir);
      ChDir(MSInfoDir);
      WinExecAndWait('MSInfo32 /nfo '+InfoFile,S,False);
      ChDir(CurDir);
      WriteFile(MemStream,InfoFile);
   end
   else
     WriteString(MemStream,'MSInfo32.exe does not exist');}
     
   PB.Position:=1;
   Application.ProcessMessages;
   
   PB.Position:=2;
   Application.ProcessMessages;
   if FileExists(InfoFile) then DeleteFile(InfoFile);
                                 
   WriteString(MemStream,'PSL Registry Entries:');
   WriteString(MemStream,GetRegKey(HKEY_LOCAL_MACHINE,'Software\PSL'));
   PB.Position:=3;
   Application.ProcessMessages;
   
   WriteFile(MemStream,'C:\GPCSErr.log');
   PB.Position:=4;
   Application.ProcessMessages;
   
   WriteDirInfo(MemStream,'C:\CorvusService');
   PB.Position:=5;
   Application.ProcessMessages;
   WriteDirInfo(MemStream,'C:\Messages');
   PB.Position:=6;
   Application.ProcessMessages;
   WriteDirInfo(MemStream,'C:\Tan');
   WriteFile(MemStream,'C:\Tan\Binary\SharedStock.dat');
   PB.Position:=7;
   Application.ProcessMessages;
   WriteDirInfo(MemStream,'C:\Botswana');
   WriteFile(MemStream,'C:\Botswana\Binary\SharedStock.dat');
   PB.Position:=8;
   Application.ProcessMessages;
   WriteDirInfo(MemStream,'C:\Bermuda');
   WriteFile(MemStream,'C:\Bermuda\Binary\SharedStock.dat');
   PB.Position:=9;         
   Application.ProcessMessages;
   WriteDirInfo(MemStream,'C:\Uganda');
   WriteFile(MemStream,'C:\Uganda\Binary\SharedStock.dat');
   PB.Position:=10;        
   Application.ProcessMessages;
   WriteDirInfo(MemStream,'C:\Swaziland');
   WriteFile(MemStream,'C:\Swaziland\Binary\SharedStock.dat');
   PB.Position:=11;        
   Application.ProcessMessages;
   WriteDirInfo(MemStream,'C:\Ghana');
   WriteFile(MemStream,'C:\Ghana\Binary\SharedStock.dat');
   PB.Position:=12;        
   Application.ProcessMessages;
   WriteDirInfo(MemStream,'C:\Oman');
   WriteFile(MemStream,'C:\Oman\Binary\SharedStock.dat');
   PB.Position:=13;        
   Application.ProcessMessages;
   WriteFiles(MemStream,'C:\Messages');
   PB.Position:=14;
   Application.ProcessMessages;
   WriteFiles(MemStream,'C:\TxnFiles');
   PB.Position:=15;
   Application.ProcessMessages;
                  
   SaveStream:=TFileStream.Create(StatusFile,fmCreate);
   MemStream.Position:=0;
   SaveStream.CopyFrom(MemStream,MemStream.Size);
   SaveStream.Free;
   
   SaveStream:=TFileStream.Create(CompStatusFile,fmCreate);
   MemStream.Position:=0;
   Compress.TCompressor.CompressStream(MemStream,SaveStream);
   SaveStream.Free;
   
   PB.Visible:=False;
   Label2.Visible:=False;
   Label1.Caption:='Information Saved to '+CompStatusFile;
   Button1.Visible:=True;
end;                           
procedure TForm1.FormShow(Sender: TObject);
begin
   if GetPSLRegString('Machine Status','Extract','0') = '1' then // extract data
   begin
      Panel1.Visible:=False;
   end
   else // normal run at customer
   begin
      Panel2.Visible:=False;
      PostMessage(Self.Handle,WM_STARTED,0,0);
   end;
end;            

procedure TForm1.Button1Click(Sender: TObject);
begin
   Close;
end;

procedure TForm1.ChangeFileClick(Sender: TObject);
begin
   if OD.Execute then
     IPFile.Text:=OD.FileName; 
end;

procedure TForm1.ChangeDirClick(Sender: TObject);
var
   Dir:String;
begin
   Dir:=OPDir.Text;
   SelectDirectory(Dir,[sdAllowCreate,sdPerformCreate,sdPrompt],0);
   OPDir.Text:=Dir;
end;               
function ReadString(Stream:TStream):String;
var
   StrLength:Integer;
begin
   Stream.Read(StrLength,SizeOf(StrLength));
   SetLength(Result,StrLength);
   Stream.Read((@Result[1])^,StrLength);
end;
procedure ExpandFileTimes(FileName:String);
var
   SL:TStringList;
   I:Integer;
   TimeVal:Integer;
   FileDate:TDateTime;
begin
   if not FileExists(FileName) then Exit;
   
   SL:=TStringList.Create;
   try
      SL.LoadFromFile(FileName);
      SL.Sort;
      for I:=0 to SL.Count-1 do
      begin
         TimeVal:=StrToIntDef('$'+Copy(SL[I],1,8),0);
         if TimeVal <> 0 then
         begin
            FileDate:=FileDateToDateTime(TimeVal);
            SL[I]:=FormatDateTime('dd/mm/yy hh:nn:ss',FileDate)+' '+Copy(SL[I],10,Length(SL[I]));
         end;
      end;
      SL.SaveToFile(FileName);
   finally
      SL.Free;
   end;
end;
procedure ReadFile(Stream:TStream;FileName:String);
var
   FS:TFileStream;
   FileLength:Integer;
   CurPos:Integer;
   S:String;
begin            
   FileLength:=0;
   try
      Stream.Read(FileLength,SizeOf(FileLength));
   except
   end;
   if FileLength > 0 then
   begin
      CurPos:=Stream.Position;
      S:='*************';
      try
         Stream.Read((@S[1])^,13);
      except
      end;
      if (S = 'File Contents') or (S = 'Directory Lis') then
      begin
         Stream.Position:=CurPos-SizeOf(FileLength);
      end
      else
      begin
         Stream.Position:=CurPos;
         ForceDirectories(ExtractFilePath(FileName));
         if FileExists(FileName) then
            FS:=TFileStream.Create(FileName,fmOpenWrite)
         else
            FS:=TFileStream.Create(FileName,fmCreate   );
         if FS <> nil then
         begin
            FS.Size:=0;
            FS.Position:=0;
            FS.CopyFrom(Stream,FileLength);
            FS.Free;
            if Pos('Directory Listing',FileName) > 0 then
               ExpandFileTimes(FileName);
         end;
      end;
   end;
end; 
function RemBadChars(S:String):String;
var
   I:Integer;
begin
   Result:='';
   for I:=1 to Length(S) do
   begin
      if not (S[I] in [':']) then
         Result:=Result+S[I];
   end;
end;
procedure TForm1.ExtractClick(Sender: TObject);
var
   FS:TFileStream;
   MS:TMemoryStream;
   FileName:String;
begin
   MS:=TMemoryStream.Create;
   FS:=TFileStream.Create(IPFile.Text,fmOpenRead);
   Compress.TCompressor.DecompressStream(FS,MS);
   FS.Free;         
   MS.Position:=0;
   try
      while MS.Position < MS.Size do
      begin
         FileName:=ReadString(MS);
         if FileName = 'PSL Registry Entries:' then
            FileName:='PSL Registry Entries.reg'
         else if Copy(FileName,1,17) = 'Directory Listing' then
            FileName:=RemBadChars(FileName)+'.lst'
         else                                            
            FileName:=RemBadChars(FileName);
         if FileName[Length(FileName)] = '_' then
            FileName:=FileName+'.txt';
         ReadFile(MS,OPDir.Text+'\'+FileName);
      end;
   finally
      MS.Position:=0;
      FileName:=OPDir.Text+'\'+ExtractFileName(IPFile.Text)+'.ful';
      if FileExists(FileName) then
         FS:=TFileStream.Create(FileName,fmOpenWrite)
      else
         FS:=TFileStream.Create(FileName,fmCreate);
      FS.CopyFrom(MS,MS.Size);
      FS.Free;         
   end;
   
   MS.Free;         
end; 

procedure TForm1.FormCreate(Sender: TObject);
begin
   OD.FileName:=IPFile.Text;
end;

end.
