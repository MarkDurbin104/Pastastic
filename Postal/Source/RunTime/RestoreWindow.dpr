program RestoreWindow;

uses
  Windows;

var
  OldVal:LongInt;
  hTaskBar:THandle;
begin
  SystemParametersInfo(SPI_SCREENSAVERRUNNING,Word(False),@OldVal,0);
  hTaskBar:=FindWindow('Shell_TrayWnd', nil);
  ShowWindow(hTaskBar,SW_SHOW);
end.
