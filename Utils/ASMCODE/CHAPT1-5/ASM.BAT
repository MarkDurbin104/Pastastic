@Echo Off
Set _SavPath_=%path%
Path %AsmPath%;%_SavPath_%
Set Comp=ASM
Set DebMode=N
If %1. == . GoTo Noparm
If %1. == ?. GoTo Help
If %1. == /H. GoTo Help
If %1. == /h. GoTo Help
If %1. == /d. GoTo Debug1
If %1. == /D. GoTo Debug1
If %2. == /d. GoTo DebOth
If %2. == /D. GoTo DebOth
If %3. == /d. GoTo DebOth
If %3. == /D. GoTo DebOth
If %4. == /d. GoTo DebOth
If %4. == /D. GoTo DebOth
GoTo Working
:Debug1
Shift
:DebOth
Echo.
Echo Flag /d was specified - module %1.asm is being prepared for debugging
Set debmode=Y
GoTo Working
:NoParm
Echo.
Echo No parameters specified - "HELP" action assumed
Echo To standard HELP function type "%0 /h" or "%0 ?"
Echo.
Echo %0 - command to ASSEMBLY programm(s) compilation
Echo.
Echo Usage:  %0 source [object] [listing] [/d]
Echo.
Echo Parameters:
Echo.
Echo source  - source module name (without "ASM" extension)
Echo           Default : NONE (parameter needed)
Echo object  - object module name (without "OBJ" extension)
Echo           Default : obj.obj (if %%TMP%% environment variable was
Echo                       defined - %tmp%\obj.obj
Echo listing - compiler listing file name (without "LST" extension)
Echo           Default : lst.lst (if %%TMP%% environment variable was
Echo                       defined - %tmp%\lst.lst
Echo /d      - flag to setting "debugging" compiler option
Echo.
Echo Example:
Echo.
Echo %0 c:\myprog\kwakwa,,c:\mylist\kwakwa
GoTo Exit
:Working
If %tmp%. == . set tmp=c:\tmp
Del %tmp%\obj.obj > nul
Del %tmp%\lst.lst > nul
Echo.
Echo Compilation ASSEMBLY program %1.asm
Echo.
Echo Use "ESC" key to exit from "BROWSE" command
Echo after end of compilation.
Echo.
Set Options=%AsmOpt%
If %DebMode%. == Y. Set Options=%Options% %AsmOptD%
%AsmPg% %Options% %PrmAsm% %AsmListF6% %1.asm%AsmListF5%%AsmListFT%
Set Options=
:EndComp
Shift
If %1. == /d. GoTo Deb2
If %1. == /D. GoTo Deb2
GoTo NoDeb2
:Deb2
Shift
:NoDeb2
IF ERRORLEVEL 1 GOTO ERR
Echo.
Echo Successful compilation
IF %1. == . GOTO NoObjCp
IF %1. == .. GOTO NoObjCp
Echo.
Echo Object module file will be named %1.obj
COPY %tmp%\obj.obj %1.OBJ > nul
GoTo :NoObjCp
:Err
Echo INVALID PROGRAM - COMPILATION DELETED
:NoObjCp
Shift
If %1. == /d. GoTo Deb3
If %1. == /D. GoTo Deb3
GoTo NoDeb3
:Deb3
Shift
:NoDeb3
IF %1. == . GOTO NoLstCp
Echo Source listing file will be named %1.lst
:NOLST
COPY %tmp%\lst.lst %1.LST > nul
:NoLstCp
:FINIS
BROWSE %tmp%\lst.lst
:Exit
Path %_SavPath_%
Set _SavPath_=