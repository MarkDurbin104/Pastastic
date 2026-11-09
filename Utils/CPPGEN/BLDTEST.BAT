rem bcc32 -v -WX -DTESTING -DDEBUG=3 cppgutil.c deballoc.c 
bcc -v -DTESTING -DDEBUG=3 cppgutil.c deballoc.c 
del cppgutil.obj
del deballoc.obj
