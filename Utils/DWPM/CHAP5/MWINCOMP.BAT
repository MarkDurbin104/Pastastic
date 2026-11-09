@echo off
REM Compile PMWIN applicaitons with Microsoft
if .%1==. goto help
if NOT EXIST %1.c goto help
cl -Zi -c -GA -G2 -DTITLE=%1 -Zp %1.c pmwin.c mscint.c
if ERRORLEVEL 1 goto err
link /CO %1 pmwin mscint,,,slibcew libw toolhelp,pmwin.def
if ERRORLEVEL 1 goto err
rc -t pmwin.rc %1.exe
if ERRORLEVEL 1 goto err
goto end
:help
echo Usage: MWINCOMP fname
echo Do not include the extension for fname
goto end
:err
echo An error occured
:end
