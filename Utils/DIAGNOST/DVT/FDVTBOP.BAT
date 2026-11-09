ECHO OFF
goto begin
REM ----------------------------------------------------------------------
REM 
REM     File:           fdvtbop.bat
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
REM     $Log:   Z:\CM\F\BPO\DVT\VCS\FDVTBOP.BAV  $
REM  
REM     Rev 1.2   01 Feb 1991 16:32:54   PJE
REM  Added copy of $KBUK.SYS to the target floppy.
REM  
REM     Rev 1.1   24 Jan 1991 11:57:24   PJE
REM  Added copy of additional files to floppy required for doing the
REM  low-level format, partitioning and high-level format of the hard
REM  disk.
REM  
REM     Rev 1.0   11 Jan 1991 18:21:08   AJW
REM  Initial revision.
REM 
REM ----------------------------------------------------------------------
:begin
CLS
ECHO UK DVT BOP Disk Generation (Factory)
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
COPY ..\PC_MOS\FORMAT.COM %1
COPY ..\PC_MOS\MSYS.COM %1
COPY ..\PC_MOS\HDSETUP.COM %1
COPY ..\PC_MOS\$KBUK.SYS %1
COPY M80.COM %1
COPY C40.COM %1
COPY DDI10.SYS %1
COPY AUTOEXEC.FBO %1\AUTOEXEC.BAT
COPY CONFIG.BOP %1\CONFIG.SYS
COPY FDVT.EXE %1DVT.EXE
COPY DTCFMT.* %1
COPY RESPONSE.YES %1
@ECHO UK DVT BOP Generation Complete
