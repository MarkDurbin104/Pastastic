@echo off
pkzip -u -sdvt dvt *.c *.h makefile *.inc *.asm *.tst *.ct *.bop *.bat *.fbo *.fct 
cpnew dvt.zip a: 
