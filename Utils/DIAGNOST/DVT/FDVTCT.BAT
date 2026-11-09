ECHO OFF
goto begin
REM ----------------------------------------------------------------------
REM 
REM     File:           fdvtct.bat
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
REM     $Log:   Z:\CM\F\BPO\DVT\VCS\FDVTCT.BAV  $
REM  
REM     Rev 1.0   14 Jan 1991 10:38:20   AJW
REM  Initial revision.
REM 
REM ----------------------------------------------------------------------
:begin
CLS
ECHO UK DVT CT Disk Generation (Factory)
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
..\PC_MOS\MSYS %1
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
COPY FDVT.EXE %1DVT.EXE
ECHO OFF
ECHO UK DVT CT Generation Complete
ECHO ON








