program StartOutlook;

uses
  Windows;

{$R *.res}

begin
  Sleep(70000);
  WinExec('C:\Program Files\Microsoft Office\OFFICE11\OUTLOOK.EXE /recycle',SW_SHOW);
end.
