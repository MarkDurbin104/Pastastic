#
# Borland C++ IDE generated makefile
# Generated 26/06/96 at 17:08:43 
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
IDE_LinkFLAGSDOS =  -LC:\BC5\LIB
IDE_BFLAGS = 
LinkerLocalOptsAtDOS_compkeydexe =  -c -Tde
ResLocalOptsAtDOS_compkeydexe = 
BLocalOptsAtDOS_compkeydexe = 
CompInheritOptsAt_compkeydexe = -IC:\BC5\INCLUDE 
LinkerInheritOptsAt_compkeydexe = -x
LinkerOptsAt_compkeydexe = $(LinkerLocalOptsAtDOS_compkeydexe)
ResOptsAt_compkeydexe = $(ResLocalOptsAtDOS_compkeydexe)
BOptsAt_compkeydexe = $(BLocalOptsAtDOS_compkeydexe)

#
# Dependency List
#
Dep_compkey = \
   compkey.exe

compkey : BccDos.cfg $(Dep_compkey)
  echo MakeNode

Dep_compkeydexe = \
   compkey.res\
   videokbd.obj\
   fileio.obj\
   config.obj\
   compkey.obj

compkey.exe : $(Dep_compkeydexe)
  $(TLINK)   @&&|
 /v $(IDE_LinkFLAGSDOS) $(LinkerOptsAt_compkeydexe) $(LinkerInheritOptsAt_compkeydexe) +
C:\BC5\LIB\c0l.obj+
videokbd.obj+
fileio.obj+
config.obj+
compkey.obj
$<,$*
C:\BC5\LIB\emu.lib+
C:\BC5\LIB\mathl.lib+
C:\BC5\LIB\cl.lib

|
   $(BRC) compkey.res $<

compkey.res :  compkey.rc
  $(BRC) -R @&&|
 $(IDE_ResFLAGS) $(ROptsAt_compkeydexe) $(CompInheritOptsAt_compkeydexe)  -FO$@ compkey.rc
|
Dep_videokbddobj = \
   videokbd.h\
   videokbd.c

videokbd.obj : $(Dep_videokbddobj)
  $(BCCDOS) -P- -c @&&|
 $(CompOptsAt_compkeydexe) $(CompInheritOptsAt_compkeydexe) -o$@ videokbd.c
|

Dep_fileiodobj = \
   fileio.h\
   fileio.c

fileio.obj : $(Dep_fileiodobj)
  $(BCCDOS) -P- -c @&&|
 $(CompOptsAt_compkeydexe) $(CompInheritOptsAt_compkeydexe) -o$@ fileio.c
|

Dep_configdobj = \
   config.h\
   config.c

config.obj : $(Dep_configdobj)
  $(BCCDOS) -P- -c @&&|
 $(CompOptsAt_compkeydexe) $(CompInheritOptsAt_compkeydexe) -o$@ config.c
|

Dep_compkeydobj = \
   compkey.h\
   keydef.h\
   defines.h\
   types.h\
   compkey.c

compkey.obj : $(Dep_compkeydobj)
  $(BCCDOS) -P- -c @&&|
 $(CompOptsAt_compkeydexe) $(CompInheritOptsAt_compkeydexe) -o$@ compkey.c
|

# Compiler configuration file
BccDos.cfg : 
   Copy &&|
-W-
-w
-R
-v
-vi
-ml
-f
| $@


