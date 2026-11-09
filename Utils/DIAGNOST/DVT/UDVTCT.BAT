ECHO OFF
goto begin
REM ----------------------------------------------------------------------
REM 
REM     File:           udvtct.bat
REM 
REM     Purpose:        generates DVT disk for CT
REM 
REM     Author:         Paul Encarnacion
REM                     Unisys, EISG, Postal Programs
REM                     5151 Camino Ruiz
REM                     Camarillo, CA 93010
REM                     (805)987-6811 
REM 
REM     Date of Origin: 01-10-1991
REM 
REM     Copyright (c) 1991  Unisys Corp.
REM 
REM     $Log:   F:\BPO\DVT\VCS\UDVTCT.BAV  $
REM  
REM     Rev 1.0   15 Jan 1991 13:08:20   PJE
REM  Initial revision.
REM  
REM     Rev 1.0   11 Jan 1991 18:23:38   AJW
REM  
REM  
REM ----------------------------------------------------------------------
:begin
CLS
ECHO UK DVT CT Disk Generation (Utility)
ECHO -----------------------------------
ECHO Generation of TARGET DISK on drive %1
ECHO Insert a formatted disk in drive %1 and press any key to continue.
ECHO (Press ^C to abort)
ECHO ------------------------------------------------------------------
PAUSE
REM --------------------------------------------------------------
REM     Files are Copied Here
REM --------------------------------------------------------------
ECHO ON
rem ..\PC_MOS\MSYS %1
COPY ..\PC_MOS\$$MOS.SYS   %1
COPY ..\PC_MOS\$$SHELL.SYS %1
COPY ..\PC_MOS\COMMAND.COM %1
COPY DDI10.SYS %1
COPY CTKB.SYS %1
COPY M80.COM %1
COPY C40.COM %1
COPY AUTOEXEC.CT %1\AUTOEXEC.BAT
COPY CONFIG.CT %1\CONFIG.SYS
COPY PRINTER.TST %1
COPY UDVT.EXE %1DVT.EXE
copy keytest.exe %1
ECHO OFF
ECHO UK DVT CT Generation Complete
ECHO ON








