del *.ob?

CL /c /AL /Zp /Ot /nologo DVT.C 
CL /c /AL /Zp /Ot /nologo DVTWN.C 
CL /c /AL /Zp /Ot /nologo DVTUTILS.C
CL /c /AL /Zp /Ot /nologo DVTROM.C 
CL /c /AL /Zp /Ot /nologo DVTRAM.C 
CL /c /AL /Zp /Ot /nologo EXTMEM.C
CL /c /AL /Zp /Ot /nologo DVTCMOS.C 
CL /c /AL /Zp /Ot /nologo DISK.C 
CL /c /AL /Zp /Ot /nologo DVTFLOPY.C 
CL /c /AL /Zp /Ot /nologo DVTCLOCK.C 
CL /c /AL /Zp /Ot /nologo DVTCOMM.C 
CL /c /AL /Zp /Ot /nologo DVTPRINT.C 
CL /c /AL /Zp /Ot /nologo DVTPPRN.C 
CL /c /AL /Zp /Ot /nologo DVTFIXED.C 
CL /c /AL /Zp /Ot /nologo DVTKB.C 
CL /c /AL /Zp /Ot /nologo VMKBMCR.C
CL /c /AL /Zp /Ot /nologo DVTVIDEO.C
CL /c /AL /Zp /Ot /nologo DVTLOG.C
CL /c /AL /Zp /Ot /nologo DVTUTILS.C
CL /c /AL /Zp /Ot /nologo DVTFMT.C
copy *.obj *.obu

MASM RAMTEST.ASM /MX /B63;
MASM CMOS.ASM /MX /B63;
MASM KEYBOARD.ASM /MX /B63;
MASM VIDEO.ASM /MX /B63;

LINK @FDVT.LNK
LINK @UDVT.LNK

MASM CTKB;
LINK CTKB;
EXE2BIN CTKB CTKB.SYS

MASM M80;
LINK M80;
EXE2BIN M80 M80.SYS

MASM C40;
LINK C40;
EXE2BIN C40 C40.SYS

MASM SETWDT;
LINK SETWDT;
EXE2BIN SETWDT SETWDT.SYS

MASM DDI10;
LINK DDI10;
EXE2BIN DDI10 DDI10.SYS

