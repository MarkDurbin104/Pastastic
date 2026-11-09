#
# Borland C++ IDE generated makefile
#
.AUTODEPEND


#
# Borland C++ tools
#
IMPLIB  = Implib
BCCDOS  = Bcc +BccDos.cfg 
BCCD16     = Bcc +BccD16.cfg
TLINK   = TLink
TLIB    = TLib
TASM    = Tasm
#
# IDE macros
#


#
# Options
#
IDE_LFLAGSDOS =  -LD:\BC4\LIB
IDE_LFLAGSD16 =  -LD:\BC4\LIB
IDE_BFLAGS = 
CLATD16_gpad16dexe =  -WX -f-
LLATD16_gpad16dexe =  -Txe -LD:\BC4\LIB;D:\BC4\LIB
RLATD16_gpad16dexe = 
BLATD16_gpad16dexe = 
CEAT_gpad16dexe = $(CLATD16_gpad16dexe)
CNIEAT_gpad16dexe = -ID:\BC4\INCLUDE;D:\BC4\INCLUDE -D
LNIEAT_gpad16dexe = -s
LEAT_gpad16dexe = $(LLATD16_gpad16dexe)
REAT_gpad16dexe = $(RLATD16_gpad16dexe)
BEAT_gpad16dexe = $(BLATD16_gpad16dexe)
CLATDOS_gpadrdexe =  -ml -f-
LLATDOS_gpadrdexe =  -c -Tde -LD:\BC4\LIB;D:\BC4\LIB
RLATDOS_gpadrdexe = 
BLATDOS_gpadrdexe = 
CEAT_gpadrdexe = $(CLATDOS_gpadrdexe)
CNIEAT_gpadrdexe = -ID:\BC4\INCLUDE;D:\BC4\INCLUDE -D
LNIEAT_gpadrdexe = -s
LEAT_gpadrdexe = $(LLATDOS_gpadrdexe)
REAT_gpadrdexe = $(RLATDOS_gpadrdexe)
BEAT_gpadrdexe = $(BLATDOS_gpadrdexe)

#
# Dependency List
#
Dep_gpad32 = \
   gpad16.exe\
   gpadr.exe

gpad32 : BccDos.cfg BccD16.cfg $(Dep_gpad32)
  echo MakeNode 

Dep_gpad16dexe = \
   mouse.obj\
   win.obj\
   config.obj\
   control.obj\
   dst.obj\
   frdgfx.obj\
   frdscr.obj\
   frdwin.obj\
   gpad.obj\
   gscracc.obj\
   newformh.obj

gpad16.exe : $(Dep_gpad16dexe)
  $(TLINK) @&&|
 /v $(IDE_LFLAGSD16) $(LEAT_gpad16dexe) $(LNIEAT_gpad16dexe) +
D:\BC4\LIB\c0x.obj+
mouse.obj+
win.obj+
config.obj+
control.obj+
dst.obj+
frdgfx.obj+
frdscr.obj+
frdwin.obj+
gpad.obj+
gscracc.obj+
newformh.obj
$<,$*
D:\BC4\LIB\dpmi16.lib+
D:\BC4\LIB\bgi16.lib+
D:\BC4\LIB\cwl.lib

|

mouse.obj :  mouse.c
  $(BCCD16) -P- -c @&&|
 $(CEAT_gpad16dexe) $(CNIEAT_gpad16dexe) -o$@ mouse.c
|

win.obj :  win.c
  $(BCCD16) -P- -c @&&|
 $(CEAT_gpad16dexe) $(CNIEAT_gpad16dexe) -o$@ win.c
|

config.obj :  config.c
  $(BCCD16) -P- -c @&&|
 $(CEAT_gpad16dexe) $(CNIEAT_gpad16dexe) -o$@ config.c
|

control.obj :  control.c
  $(BCCD16) -P- -c @&&|
 $(CEAT_gpad16dexe) $(CNIEAT_gpad16dexe) -o$@ control.c
|

dst.obj :  dst.c
  $(BCCD16) -P- -c @&&|
 $(CEAT_gpad16dexe) $(CNIEAT_gpad16dexe) -o$@ dst.c
|

frdgfx.obj :  frdgfx.c
  $(BCCD16) -P- -c @&&|
 $(CEAT_gpad16dexe) $(CNIEAT_gpad16dexe) -o$@ frdgfx.c
|

frdscr.obj :  frdscr.c
  $(BCCD16) -P- -c @&&|
 $(CEAT_gpad16dexe) $(CNIEAT_gpad16dexe) -o$@ frdscr.c
|

frdwin.obj :  frdwin.c
  $(BCCD16) -P- -c @&&|
 $(CEAT_gpad16dexe) $(CNIEAT_gpad16dexe) -o$@ frdwin.c
|

gpad.obj :  gpad.c
  $(BCCD16) -P- -c @&&|
 $(CEAT_gpad16dexe) $(CNIEAT_gpad16dexe) -o$@ gpad.c
|

gscracc.obj :  gscracc.c
  $(BCCD16) -P- -c @&&|
 $(CEAT_gpad16dexe) $(CNIEAT_gpad16dexe) -o$@ gscracc.c
|

newformh.obj :  newformh.c
  $(BCCD16) -P- -c @&&|
 $(CEAT_gpad16dexe) $(CNIEAT_gpad16dexe) -o$@ newformh.c
|

Dep_gpadrdexe = \
   start.obj\
   mouser.obj

gpadr.exe : $(Dep_gpadrdexe)
  $(TLINK)   @&&|
 /v $(IDE_LFLAGSDOS) $(LEAT_gpadrdexe) $(LNIEAT_gpadrdexe) +
D:\BC4\LIB\c0l.obj+
start.obj+
mouser.obj
$<,$*
D:\BC4\LIB\cl.lib

|

start.obj :  start.c
  $(BCCDOS) -P- -c @&&|
 $(CEAT_gpadrdexe) $(CNIEAT_gpadrdexe) -o$@ start.c
|

mouser.obj :  mouser.c
  $(BCCDOS) -P- -c @&&|
 $(CEAT_gpadrdexe) $(CNIEAT_gpadrdexe) -o$@ mouser.c
|

# Compiler configuration file
BccDos.cfg : 
   Copy &&|
-W-
-R
-v
-vi
-H
-H=gpad32.csm
-wsig
-H-
| $@


# Compiler configuration file
BccD16.cfg : 
   Copy &&|
-ml
-R
-v
-vi
-H
-H=gpad32.csm
-wsig
-H-
| $@


