@ECHO OFF
TASM /M /MX /T /D__TINY__ stub;
bcc -c -mt -DDRIVER_CODE %1.c 
tlink /m/c stub+%1,TEMPDRIV,TEMPDRIV,emu+maths+cs
exe2bin TEMPDRIV %1.sys < respfile.key
overload %1.sys %1 
copy tempdriv.map %1.map > NUL
del TEMPDRIV.* > NUL
echo PRESS ^C TO STOP COPY TO A:
pause
copy %1.sys a:
