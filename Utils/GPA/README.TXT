                                        3/2/95
Mark,

the enclosed DEF file is for use with GPA.BIN (add GPA.DEF to your makefile
as per below). I haven't taken STKLEN out of the C code yet.


GPA.BIN:      GPA.H CAPGPA.OBJ $(OBJS) GPA.LIB $(DEVS:,=DEV.OBJ ) $(GOBJS)
	      TLINK $(LINKPARMS) @&&!
	      C0X CAPGPA.OBJ $(OBJS) $(DEVS:,=DEV.OBJ ) $(GOBJS),GPA.BIN,GPABIN.MAP,$(GPALIBS)+PXENGWIN,GPA.DEF




PP.C.  I've made PRINTER a special case in the STATIC maintaining code. The
code now resets PRINTER (if it exists) to a 0 length string on a PP. We need
to do this to allow the default name in CAP.ENG to work.  Really the GPA
code should error at run-time if it is given a PRD name it cannot find. I
haven't done that because error handling throughout GPA is so weak it all
needs looking at, not just piecemeal - do you agree?


Tom
