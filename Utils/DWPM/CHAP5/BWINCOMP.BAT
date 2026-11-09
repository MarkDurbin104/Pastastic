@echo off
REM Compile PMWIN applications with Borland
if .%1==. goto help
if NOT EXIST %1.c goto help
set LIBS=mathws import cws
bcc -WE -2 -v -w-par -c -DTITLE=%1 %1.c pmwin.c
if ERRORLEVEL 1 goto err
tlink -v -x -c -P- -Twe c0ws %1 pmwin,%1,,%LIBS%,pmwin.def
if ERRORLEVEL 1 goto err
set LIBS=
rc -t pmwin.rc %1.exe
if ERRORLEVEL 1 goto err
goto end
:help
echo Usage: BWINCOMP fname
echo Do not include the extension for fname
goto end
:err
echo An error occured
:end
