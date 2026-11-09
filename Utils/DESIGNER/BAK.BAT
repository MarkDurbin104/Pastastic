@echo off
pkzip -u -sgpad gpad *.cpp *.c *.h *.prj *.def *.rc *.bmp *.ico
cpnew gpad.zip a: 
