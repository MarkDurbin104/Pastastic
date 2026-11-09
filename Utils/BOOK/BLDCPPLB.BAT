@echo off
echo ------------------------------------------
echo   Graphic File Formats - C++ Library Build
echo ------------------------------------------

if %1. == . goto start
goto %1

:start

:bmp
bcc -c bmp
if errorlevel 1 goto compile_err

:color
bcc -c color
if errorlevel 1 goto compile_err

:colormap
bcc -c colormap
if errorlevel 1 goto compile_err

:display
bcc -c display
if errorlevel 1 goto compile_err

:dither
bcc -c dither
if errorlevel 1 goto compile_err

:epjx80
bcc -c epjx80
if errorlevel 1 goto compile_err

:eplq24
bcc -c eplq24
if errorlevel 1 goto compile_err

:giflzw
bcc -c giflzw
if errorlevel 1 goto compile_err

:group3
bcc -c group3
if errorlevel 1 goto compile_err

:imgprntr
bcc -c imgprntr
if errorlevel 1 goto compile_err

:imgstore
bcc -c imgstore
if errorlevel 1 goto compile_err

:imgviewr
bcc -c imgviewr
if errorlevel 1 goto compile_err

:intenmap
bcc -c intenmap
if errorlevel 1 goto compile_err

:laserjet
bcc -c laserjet
if errorlevel 1 goto compile_err

:packbits
bcc -c packbits
if errorlevel 1 goto compile_err

:paintjet
bcc -c paintjet
if errorlevel 1 goto compile_err

:pcx
bcc -c pcx
if errorlevel 1 goto compile_err

:printer
bcc -c printer
if errorlevel 1 goto compile_err

:pscript
bcc -c pscript
if errorlevel 1 goto compile_err

:revbyte
bcc -c revbyte
if errorlevel 1 goto compile_err

:bldlib
erase gffcpp.lib
tlib  gffcpp /c @gffcpp.rsp
goto the_end

:compile_err
echo **** Compile Failed! ****

:the_end
