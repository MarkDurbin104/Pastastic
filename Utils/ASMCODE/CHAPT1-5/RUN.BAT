@Echo Off
Set Work1=
Set Work2=
Set _Path_=%Path%
Path %LnkPath%;%DebPath%;%_Path_%
If %tmp%. == . set tmp=c:\tmp
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
If %comp%. == clip. GoTo EngDebC
If %comp%. == CLIP. GoTo EngDebC
Echo Flag /d was specified - CodeView debugger will be used
GoTo ContDeb1
:EngDebC
Echo Flag /d was specified - Clipper debugger will be attached
:ContDeb1
Set DebMode=Y
GoTo Working
:NoParm
Echo.
Echo No parameters specified - last compiled module will be linked
GoTo Working
:Help
Echo.
Echo %0 - command to object module linking and execution
Echo.
Echo Usage:  %0 object [[executable] map-listing]] [/d]
Echo.
Echo Parameters:
Echo.
Echo object      - object module name (without "OBJ" extension)
Echo               Default : %tmp%\obj.obj
Echo executable  - executable programm name (without "EXE" extension)
Echo               Default : go.exe (if %%TMP%% environment variable was
Echo                       defined - %tmp%\go.exe
Echo map-listing - linker listing file name (without "MAP" extension)
Echo               Default : map.map (if %%TMP%% environment variable was
Echo                         defined - %tmp%\lst.lst
Echo /d          - flag to setting "debugging" LINKER option
Echo.
Echo Example:
Echo.
Echo %0 c:\myprog\kwakwa,c:\myexec\kwakwa
GoTo Exit
:Working
Set Work1=%1
If %Work1%. == . Set Work1=%tmp%\Obj
:NoPrm1
DEL %tmp%\go.* > nul
DEL %tmp%\map.map > nul
Echo.
Echo Linking OBJECT program %Work1%.obj
Echo.
If %DebMode%. == Y. GoTo DebComp
%LnkPath%\%LnkPg% %Work1%,%tmp%\Go,%tmp%\Map.Map,%prlib% %PrmLnk% ;
GoTo EndComp
:DebComp
If %comp%. == clip. GoTo ClipDeb1
If %comp%. == CLIP. GoTo ClipDeb1
%LnkPath%\%LnkPg% %Work1%,%tmp%\Go,%tmp%\Map.Map,%prlib% %PrmLnk% %SetDeb% ;
GoTo EndComp
:ClipDeb1
Set Work1=%Work1%+%ClipDeb%
%LnkPath%\%LnkPg% %Work1%,%tmp%\Go,%tmp%\Map.Map,%prlib% /Noe %PrmLnk% ;
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
Echo Use "ESC" key to exit from "BROWSE" command
Echo after end of linkage editing.
Echo.
Echo Linkage editing complete.
Set Work2=.Exe
If Exist %tmp%\Go.Com Set Work2=.Com
IF %1. == . GOTO NoObjCp
IF %1. == .. GOTO NoObjCp
Echo.
Echo Executable programm will be named %1%Work2%
COPY %tmp%\Go.* %1.* > nul
GoTo :NoObjCp
:Err
Echo INVALID OBJECT MODULE - EXECUTABLE PROGRAMM NOT CREATED
:NoObjCp
Shift
If %1. == /d. GoTo Deb3
If %1. == /D. GoTo Deb3
GoTo NoDeb3
:Deb3
Shift
:NoDeb3
IF %1. == . GOTO NoLstCp
IF %1 ==  GOTO NoLstCp
Echo Map listing file will be named %1.map
:NOLST
COPY %tmp%\map.map %1.MAP > nul
:NoLstCp
:FINIS
Rem Browse %tmp%\map.map
If Not Exist %tmp%\Go.* GoTo NoExec
Echo.
Echo Results of program's running:
Echo.
If %DebMode%. == Y. GoTo ExeDeb
%tmp%\Go
GoTo Exit
:ExeDeb
If %comp%. == clip. GoTo ClipExe
If %comp%. == CLIP. GoTo ClipExe
%DebPath%\%DebPg% %tmp%\Go%Work2%
GoTo Exit
:ClipExe
%tmp%\Go
:Exit
:NoExec
Set Work1=
Set Work2=
Path %_Path_%
Set _Path_=