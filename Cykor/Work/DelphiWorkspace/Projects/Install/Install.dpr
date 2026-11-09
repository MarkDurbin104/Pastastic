program Install;

uses
  Windows;

{$R *.res}

begin
  WinExec(PChar('RegEdit /s C:\VU.iT\Service\Service.reg'),SW_HIDE);
  WinExec(PChar('C:\VU.iT\Service\VUiTServiceController.exe'),SW_HIDE);
  CopyFile(PChar('C:\VU.iT\HTML\Test\Vuit_Output.txt'),PChar('C:\Vuit_Output.txt'),False);
  CopyFile(PChar('C:\VU.iT\HTML\Test\Vuit_Capture.jpg'),PChar('C:\Vuit_Capture.jpg'),False);
end.
