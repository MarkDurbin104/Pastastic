#
# Borland C++ IDE generated makefile
#
.AUTODEPEND


#
# Borland C++ tools
#
IMPLIB  = Implib
BCCDOS  = Bcc +BccDos.cfg 
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
IDE_BFLAGS = 
LLATDOS_gpaddexe =  -c -Tde
RLATDOS_gpaddexe = 
BLATDOS_gpaddexe = 
LEAT_gpaddexe = $(LLATDOS_gpaddexe)
REAT_gpaddexe = $(RLATDOS_gpaddexe)
BEAT_gpaddexe = $(BLATDOS_gpaddexe)

#
# Dependency List
#
Dep_gpad = \
   gpad.exe

gpad : BccDos.cfg $(Dep_gpad)
  echo MakeNode gpad

Dep_gpaddexe = \
   gpad.obj

gpad.exe : $(Dep_gpaddexe)
  $(TLINK)   @&&|
 /v $(IDE_LFLAGSDOS) $(LEAT_gpaddexe) +
D:\BC4\LIB\c0l.obj+
gpad.obj
$<,$*
D:\BC4\LIB\graphics.lib+
D:\BC4\LIB\bidsl.lib+
D:\BC4\LIB\emu.lib+
D:\BC4\LIB\mathl.lib+
D:\BC4\LIB\cl.lib

|

gpad.obj :  gpad.cpp
  $(BCCDOS) -c $(CEAT_gpaddexe) -o$@ gpad.cpp

# Compiler configuration file
BccDos.cfg : 
   Copy &&|
-W-
-R
-v
-vi
-X-
-H
-ID:\BC4\INCLUDE
-H=gpad.csm
-ml
-f
| $@


