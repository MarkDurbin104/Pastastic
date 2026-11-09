@echo off
rem bcc -N -k -ml -Od -G -d -w -v -DDEBUG=3 compkey.c fileio.c videokbd.c config.c deballoc.c
bcc -ml -Od -G -d -w compkey.c fileio.c videokbd.c config.c
rem bcc -v -ml -w -WX -IL:\bc45\include -LL:\bc45\lib compkey.c fileio.c config.c videokbd.c
rem bcc -v -ml -w -WX -DDEBUG=3 -IL:\bc45\include -LL:\bc45\lib compkey.c fileio.c config.c videokbd.c deballoc.c
