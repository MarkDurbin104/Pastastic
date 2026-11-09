unit SystemInfoFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,TLHelp32,Printers;

type
  TForm1 = class(TForm)
    sysinfo: TButton;
    Memo1: TMemo;
    MemoryStatus: TButton;
    Button1: TButton;
    procedure sysinfoClick(Sender: TObject);
    procedure MemoryStatusClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.sysinfoClick(Sender: TObject);
var
  MySystem: TSystemInfo;
  Info: TOSVersionInfoA;
  PWindowsDir: array [0..255] of Char;
  MyStatus: TMemoryStatus;
  CompName: array[0..256] of Char;
  i: Integer;
  StrUserName: PChar;
  MyHandle: THandle;
  Struct: TProcessEntry32;
  MyPrinter, MyDriver, MyPort: array[0..100] of Char;
  DevMode: THandle;
const
  Size: Integer = 250;
begin
  Memo1.Lines.Add('Names -------------------------------------------');
  i:=256;
  GetComputerName(CompName,i);
  Memo1.Lines.Add('Computer name '+StrPas(CompName));
  
  GetMem(StrUserName, Size);
  GetUserName(StrUserName, Size);
  Memo1.Lines.Add('User name '+StrPas(StrUserName));
  FreeMem(StrUserName);
  
  Memo1.Lines.Add('Directories -------------------------------------');
  GetWindowsDirectory(PWindowsDir,255);
  Memo1.Lines.Add('Windows Dir: '+StrPas(PWindowsDir));
  
  Memo1.Lines.Add('Operating System --------------------------------');
  Info.dwOSVersionInfoSize:=sizeof(Info);                            
  GetVersionEx(Info);
  Memo1.Lines.Add('MajorVersion - '+IntToStr(Info.dwMajorVersion));
  Memo1.Lines.Add('MinorVersion - '+IntToStr(Info.dwMinorVersion));
  Memo1.Lines.Add('BuildNumber - '+IntToStr(Info.dwBuildNumber));
  case Info.dwPlatformID of
    VER_PLATFORM_WIN32s:        Memo1.Lines.Add('Win32 on Windows 3.1');
    VER_PLATFORM_WIN32_WINDOWS: Memo1.Lines.Add('Win32 on Windows 95/98');
    VER_PLATFORM_WIN32_NT:      Memo1.Lines.Add('Win32 on Windows NT');
    else Memo1.Lines.Add('Win32 on platform '+IntToStr(Info.dwPlatformID));
  end;
  Memo1.Lines.Add('Processor --------------------------------------');
  GetSystemInfo(MySystem);          
  with Memo1.Lines do
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
  Memo1.Lines.Add('Memory -----------------------------------------');
  MyStatus.dwLength:=SizeOf(MyStatus);
  GlobalmemoryStatus(MyStatus);
  with Memo1.Lines do
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
  MyHandle:=CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
  Struct.dwSize:=Sizeof(TProcessEntry32);
  if Process32First(MyHandle, Struct) then
    Memo1.Lines.Add(Struct.szExeFile);
  while Process32Next(MyHandle, Struct) do
    Memo1.Lines.Add(Struct.szExeFile);
  Memo1.Lines.Add('Printers -----------------------------------------');
  Printer.GetPrinter(MyPrinter, MyDriver, MyPort, DevMode);
  Memo1.Lines.Add('Default Printer '+MyPrinter+' '+MyPort);
end;

procedure TForm1.MemoryStatusClick(Sender: TObject);
var
  MyStatus: TMemoryStatus;
begin
  MyStatus.dwLength:=SizeOf(MyStatus);
  GlobalmemoryStatus(MyStatus);
  with Memo1.Lines do
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
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  MyPrinter, MyDriver, MyPort: array[0..100] of Char;
  DevMode: THandle;
begin
  Printer.GetPrinter(MyPrinter, MyDriver, MyPort, DevMode);
  Memo1.Lines.Add(MyPrinter);
  Memo1.Lines.Add(MyPort);
end;

end.
