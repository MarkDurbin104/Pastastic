#
# Borland C++ IDE generated makefile
#
.AUTODEPEND


#
# Borland C++ tools
#
IMPLIB  = Implib
BCCD32     = Bcc32 +BccD32.cfg
TLINK32 = TLink32
TLIB    = TLib
TASM32  = Tasm32
#
# IDE macros
#


#
# Options
#
IDE_LFLAGSD32 =  -LD:\BC4\LIB
LLATD32_timetestdexe =  -Tpe -ax -LD:\BC4\LIB;D:\BC4\LIB
RLATD32_timetestdexe = 
BLATD32_timetestdexe = 
CNIEAT_timetestdexe = -ID:\BC4\INCLUDE;D:\BC4\INCLUDE -D
LNIEAT_timetestdexe = -x
LEAT_timetestdexe = $(LLATD32_timetestdexe)
REAT_timetestdexe = $(RLATD32_timetestdexe)
BEAT_timetestdexe = $(BLATD32_timetestdexe)

#
# Dependency List
#
Dep_timetest = \
   timetest.exe

timetest : BccD32.cfg $(Dep_timetest)
  echo MakeNode 

Dep_timetestdexe = \
   timetest.obj

timetest.exe : $(Dep_timetestdexe)
  $(TLINK32) @&&|
 /v $(IDE_LFLAGSD32) $(LEAT_timetestdexe) $(LNIEAT_timetestdexe) +
D:\BC4\LIB\c0x32.obj+
timetest.obj
$<,$*
D:\BC4\LIB\dpmi32.lib

|

timetest.obj :  timetest.c
  $(BCCD32) -P- -c @&&|
 $(CEAT_timetestdexe) $(CNIEAT_timetestdexe) -o$@ timetest.c
|

# Compiler configuration file
BccD32.cfg : 
   Copy &&|
-R
-v
-vi
-H
-H=timetest.csm
-WX
| $@


