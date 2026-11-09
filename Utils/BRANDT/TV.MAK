.AUTODEPEND

#		*Translator Definitions*
CC = bcc +TV.CFG
TASM = tasm
TLIB = tlib
TLINK = tlink -L\bc45\lib 


#		*Implicit Rules*
.c.obj:
  $(CC) -c {$< }

.cpp.obj:
  $(CC) -c {$< }

#		*List Macros*


EXE_dependencies =  \
 tv.obj \
 taskfile.obj \
 taskgraf.obj \
 taskdiag.obj \
 taskterm.obj \
 comms.obj

#		*Explicit Rules*
tv.exe: tv.cfg $(EXE_dependencies)
  $(TLINK)  @&&|
c0s.obj+
tv.obj+
taskfile.obj+
taskgraf.obj+
taskdiag.obj+
taskterm.obj+
comms.obj
tv,tv
emu.lib+
maths.lib+
cs.lib+
bgi16.lib
|


#		*Individual File Dependencies*
tv.obj: tv.cfg tv.c 

taskfile.obj: tv.cfg taskfile.c 

taskgraf.obj: tv.cfg taskgraf.c 

taskdiag.obj: tv.cfg taskdiag.c 

taskterm.obj: tv.cfg taskterm.c 

comms.obj: tv.cfg comms.c 

#		*Compiler Configuration File*
tv.cfg: tv.mak
  copy &&|
-DM_DEBUG=0
-3 -v
-ml -WX
-Id:\BC45\INCLUDE
-Ld:\BC45\LIB
| tv.cfg


