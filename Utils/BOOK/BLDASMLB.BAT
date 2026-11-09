@echo off
echo --------------------------------------------------
echo   Graphic File Formats - Assembler Library Build
echo --------------------------------------------------

if %1. == . goto start
goto %1

:start

:ati62
tasm /m /mx ati62
if errorlevel 1 goto assemble_err

:dist3
tasm /m /mx dist3
if errorlevel 1 goto assemble_err

:ems
tasm /m /mx ems
if errorlevel 1 goto assemble_err

:iscale
tasm /m /mx iscale
if errorlevel 1 goto assemble_err

:revword
tasm /m /mx revword
if errorlevel 1 goto assemble_err

:setbinio
tasm /m /mx setbinio
if errorlevel 1 goto assemble_err

:tse2e
tasm /m /mx tse2e
if errorlevel 1 goto assemble_err

:vga12
tasm /m /mx vga12
if errorlevel 1 goto assemble_err

:vga13
tasm /m /mx vga13
if errorlevel 1 goto assemble_err

:vgapal
tasm /m /mx vgapal
if errorlevel 1 goto assemble_err

:vgaquery
tasm /m /mx vgaquery
if errorlevel 1 goto assemble_err

:vmode
tasm /m /mx vmode
if errorlevel 1 goto assemble_err

:xms
tasm /m /mx xms
if errorlevel 1 goto assemble_err

:bldlib
erase gffasm.lib
tlib  gffasm /c @gffasm.rsp
goto the_end

:assemble_err
echo **** Assemble Failed! ****

:the_end
