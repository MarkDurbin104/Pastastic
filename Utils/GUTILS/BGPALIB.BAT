@echo off
del gpa.lib
bcc @gpa1.lst
tlib gpa @gpa2.lst
del GPAMAIN.OBJ 
del CONTROL.OBJ 
del DBM.OBJ 
del TRANSLOG.OBJ 
del FUNCTION.OBJ 
del MONEY.OBJ 
del DST.OBJ 
del ARITH.OBJ 
del NEWACT.OBJ 
del CONFIG.OBJ 
del CALC.OBJ
del MENUPROC.OBJ 
del FORMPROC.OBJ 
del TABPROC.OBJ 
del FLDPROC.OBJ 
del FORMHAND.OBJ 
del KBDDEV.OBJ 
del SCRDEV.OBJ 
del PRNDEV.OBJ 
del DISKDEV.OBJ 
del SCALEDEV.OBJ 
del NETDEV.OBJ

