rem testcomp.bat
rem
rem Test compilation of a single file

BCC -WX -ml -O2 -Ot -Ox -Oi -G -d -w -v -c %1.c >%1.err
type %1.err

