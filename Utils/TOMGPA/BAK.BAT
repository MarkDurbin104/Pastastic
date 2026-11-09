@echo off
pkzip -u -sjohne -x@gpaxclud.lst gpa
copy gpa.zip \bak
cpnew gpa.zip a: 

