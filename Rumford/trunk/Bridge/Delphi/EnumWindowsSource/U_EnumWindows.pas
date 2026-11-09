unit U_EnumWindows;
 {Copyright  © 2003, Gary Darby,  www.DelphiForFun.org
 This program may be used or modified for any non-commercial purpose
 so long as this original notice remains in place.
 All other rights are reserved
 }

{A test program to enumerate all top level windows on the screen or
 check for a specific window}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, extctrls,TlHelp32;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    Foundlbl: TLabel;
    ListBothBtn: TButton;
    procedure ListBothBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  public
   end;

var   Form1: TForm1;

implementation

{$R *.DFM}


{****************** GetWindowExeName ***********}
function GetWindowExeName(Handle: THandle): String;
{Given a window handlew, return the program name}
var
 PE: TProcessEntry32;
 Snap: THandle;
 ProcessId: cardinal;
begin
  result:='???';
  pe.dwsize:=sizeof(PE);
 GetWindowThreadProcessId(Handle,@ProcessId);
 Snap:= CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);
 if Snap <> 0 then
 begin
   if Process32First(Snap, PE) then
     if PE.th32ProcessID = ProcessId then
       Result:= String(PE.szExeFile)
     else while Process32Next(Snap, PE) do
       if PE.th32ProcessID = ProcessId then
       begin
         Result:= String(PE.szExeFile);
         break;
       end;
   CloseHandle(Snap);
 end;
end;


      {**************** NextBoth ****************}
      function NextChild(wnd:Thandle;list:Tstringlist):boolean;  stdcall;
      {This is the callback function which is called by EnumWindows procedure for each
       top-level window.  Return "true" to keep retrieving, return "false" to stop
       EnumWindows  from calling}
      var s:string;
          title:array[0..255] of char;
          wclass:array[0..255] of char;
        WinRect: TRect;
        wi:TWindowInfo;
      begin
        wi.cbSize:=sizeof(wi);
        GetWindowInfo(wnd,wi);
        GetWindowRect(wnd, WinRect);
        GetWindowText(wnd,title,256);
        GetClassName(wnd,wclass,256);
        s:='C:'+getWindowexename(wnd)+':'+pchar(@wclass)+':'+pchar(@title)+' L:'+IntToStr(WinRect.Left)+' T:'+IntToStr(WinRect.Top)+' R:'+IntToStr(WinRect.Right)+' B:'+IntToStr(WinRect.Bottom)+' S:'+IntToHex(wi.dwStyle,8)+' ES:'+IntToHex(wi.dwExStyle,8);
        if list.indexof(s)<0 then list.add(s);
        result:=true;
      end;
            {**************** NextBoth ****************}
      function Nextboth(wnd:Thandle;list:Tstringlist):boolean;  stdcall;
      {This is the callback function which is called by EnumWindows procedure for each
       top-level window.  Return "true" to keep retrieving, return "false" to stop
       EnumWindows  from calling}
      var s:string;
          title:array[0..255] of char;
          wclass:array[0..255] of char;
        WinRect: TRect;
      begin
        GetWindowRect(wnd, WinRect);
        GetWindowText(wnd,title,256);
        GetClassName(wnd,wclass,256);
        s:='P:'+getWindowexename(wnd)+':'+pchar(@wclass)+':'+pchar(@title)+' L:'+IntToStr(WinRect.Left)+' T:'+IntToStr(WinRect.Top)+' R:'+IntToStr(WinRect.Right)+' B:'+IntToStr(WinRect.Bottom);
        if list.indexof(s)<0 then list.add(s);
        EnumChildWindows(wnd,@NextChild,lparam(list));
        result:=true;
      end;


 {************* Buttons ************}

{******************* ListBothBtnClick **********}
procedure TForm1.FormCreate(Sender: TObject);
begin
  ListBothBtnClick(nil);
end;

procedure TForm1.ListBothBtnClick(Sender: TObject);
begin
  listbox1.clear;
  enumwindows(@nextboth,lparam(listbox1.items)); {pass the list as a parameter}
  ListBox1.Items.SaveToFile(ExtractFilePath(ParamStr(0))+'\'+'Log.txt');
end;


end.
