


.c.obj:
	bcc32 -v -c $*.c

test32.exe: test32.obj
	tlink32 -v -Tpe -ap c0x32.obj+test32,test32,,.\cw32.lib+\
		import32.lib,test32.def

