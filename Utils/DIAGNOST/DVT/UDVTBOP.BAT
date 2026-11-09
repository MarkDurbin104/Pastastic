ECHO OFF
goto begin
REM ----------------------------------------------------------------------
REM 
REM     File:           udvtbop.bat
REM 
REM     Purpose:        generates DVT disk for BOP
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
REM     $Log:   Z:\CM\F\BPO\DVT\VCS\UDVTBOP.BAV  $
REM  
REM     Rev 1.1   01 Feb 1991 16:34:22   PJE
REM  Added copy of $KBUK.SYS to target diskette.
REM  
REM     Rev 1.0   11 Jan 1991 18:22:22   AJW
REM  Initial revision.
REM 
REM ----------------------------------------------------------------------
:begin
CLS
ECHO UK DVT BOP Disk Generation (Utility)
ECHO ------------------------------------
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
COPY ..\PC_MOS\$KBUK.SYS   %1
COPY M80.COM %1
COPY C40.COM %1
COPY DDI10.SYS %1
COPY AUTOEXEC.BOP %1\AUTOEXEC.BAT
COPY CONFIG.BOP %1\CONFIG.SYS
COPY UDVT.EXE %1DVT.EXE
ECHO OFF
ECHO UK DVT BOP Generation Complete
ECHO ON








