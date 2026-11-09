.AUTODEPEND

#		*Translator Definitions*
CC = bcc +CONVHPGL.CFG
TASM = tasm
TLIB = tlib
TLINK = tlink


#		*Implicit Rules*
.c.obj:
  $(CC) -c {$< }

.cpp.obj:
  $(CC) -c {$< }

#		*List Macros*


EXE_dependencies =  \
 convhpgl.obj \
 graphics.lib \
 lansintr.obj \
 calcu.obj \
 getvals.obj \
 setchr.obj \
 setdef.obj \
 comms.obj

#		*Explicit Rules*
convhpgl.exe: convhpgl.cfg $(EXE_dependencies)
  $(TLINK)  @&&|
c0s.obj+
convhpgl.obj+
lansintr.obj+
calcu.obj+
getvals.obj+
setchr.obj+
setdef.obj+
comms.obj
convhpgl,convhpgl
graphics.lib+
emu.lib+
maths.lib+
cs.lib
|


#		*Individual File Dependencies*
convhpgl.obj: convhpgl.cfg convhpgl.c 

lansintr.obj: convhpgl.cfg lansintr.c 

calcu.obj: convhpgl.cfg calcu.c 

getvals.obj: convhpgl.cfg getvals.c 

setchr.obj: convhpgl.cfg setchr.c 

setdef.obj: convhpgl.cfg setdef.c 

comms.obj: convhpgl.cfg comms.c 

#		*Compiler Configuration File*
convhpgl.cfg: convhpgl.mak
  copy &&|
| convhpgl.cfg


