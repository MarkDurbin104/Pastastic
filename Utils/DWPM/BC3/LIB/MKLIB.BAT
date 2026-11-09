@echo off
rem $Id: mklib.bat 1.5 92/07/15 16:26:29 rob Exp $
set PLLPTH=%2
rem if "%1" == "s" goto valid_model
rem if "%1" == "m" goto valid_model
if "%1" == "l" goto valid_model
if "%1" == "h" goto valid_model
rem if "%1" == "c" goto valid_model
goto usage
:valid_model
if "%PLLPTH%" == "" goto no_path
goto path_supplied
:no_path
set PLLPTH=.
:path_supplied
if exist %PLLPTH%\c%1.lib goto lib_exists
goto error1
:lib_exists
if not exist bc%1286.lib goto targ_no_exist
echo * Warning: File "bc%1286.lib" already exists and will be overwritten.
echo *          Press Ctrl-C to Abort ...
pause
:targ_no_exist
echo * Copying c%1.lib to bc%1286.lib
copy %PLLPTH%\c%1.lib bc%1286.lib
rem
rem Extract OBJs from Phar Lap libraries
rem
echo * Extracting object files from tmp%1.lib
tlib tmp%1.lib @extmods.lbc > nul
if errorlevel 1 goto error2
rem
rem Add modules into new library.
rem
echo * Replacing objects in bc%1286.lib
tlib bc%1286.lib @insmods.lbc > nul
if errorlevel 1 goto error3
rem
rem Delete intermediate object files
rem
echo * Cleaning up.
call remobjs.bat
del bc%1286.bak
echo *
echo *	Library "bc%1286.lib" created successfully.
echo *
goto end
:usage
echo Usage: MKLIB l [dir path]
echo The first parameter determines that a LARGE model library is to
echo be created.  The second parameter is the path to the DIRECTORY that
echo contains the Borland C++ 3.0 library files. The new library
echo will be created in the current directory.
echo Sample Usage:
echo MKLIB l c:\bc\lib      (creates library BCL286.LIB)
goto end
:error1
echo *
echo *  ERROR: Library "%PLLPTH%\c%1.lib" Not Found.
echo *
goto end
:error2
echo *
echo *	ERROR: Could Not Extract Modules from library "tmp%1.lib".
echo *
goto end
:error3
echo *
echo *	ERROR: Could Not Create New Library "bc%1286.lib".
echo *
goto end
:end
set PLLPTH=
rem Borland C++ 3.0 is a trademark of Borland International, Inc.
