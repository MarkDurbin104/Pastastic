@echo off
rem COMPKEY.EXE takes care of the files PLU_COMP.XMT, DEP_COMP.XMT, POST.DAT
rem This file expects one parameter i.e. control_centre [XX]
rem
copy \keymaint\%1\store.dat \omcom\omrondat\*.*     > nul
copy \keymaint\compass.seq \omcom\omronseq\last.seq > nul
cd \omcom
OC09A
OC01D

