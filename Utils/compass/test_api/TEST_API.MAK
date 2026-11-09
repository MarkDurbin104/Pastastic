#
# Makefile for the Test API Program (Microsoft C)
#

# Defines      

MODEL   = L

OBJS    = test_api.obj
LIBS    = rwnwapi $(MODEL)libcew libw commdlg

# Production Flags

CFLAGS  = -A$(MODEL) -G2sw -Zp $(WINDEFS) -W3 -Ox
LFLAGS  = /Align:16 /NoDef /NoExt
RFLAGS  = -v

# Debug Flags

#CFLAGS  = -A$(MODEL) -G2sw -Zp $(WINDEFS) -W4 -Od -Zi
#LFLAGS  = /Align:16 /NoDef /NoExt /CodeView /Map
#RFLAGS  = -v

# Rules for Compiling and Linking

.c.obj:
	cl $(CFLAGS) -c $<

.obj.exe:
	link $(LFLAGS) $(OBJS),, $*, $(LIBS), $* ;
	$(RC) $(RFLAGS) $*.res

# Dependencies

TARGET:          test_api.exe test_api.def

test_api.res:    test_api.rc test_api.h

test_api.obj:    test_api.c test_api.h

test_api.exe:    test_api.obj test_api.res