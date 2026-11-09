#ifndef PRNDEV_H

#define PRNDEV_H

#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef PRNDEV_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S
#ifdef PRNDEV_C
LONG prn_control0(INT type,va_list ap);
LONG prn_control1(INT type,va_list ap);
LONG prn_control2(INT type,va_list ap);
LONG prn_control3(INT type,va_list ap);
LONG prn_control4(INT type,va_list ap);
LONG prn_control5(INT type,va_list ap);
LONG prn_control6(INT type,va_list ap);
LONG prn_control7(INT type,va_list ap);
#endif

PUBLIC DEVHEADER dev_prn 
#if INIT
= {
	DEVSIG,
    "Printer Device Copyright (c) Unisys Ltd 1992 Version 1.01",
    "OUTPUT02","PRN","IOCR",NULL,NULL,(DFPTR)prn_control0,NULL,
	DEVSIG
}
#endif
;
PUBLIC DEVHEADER dev_prn2 
#if INIT
= {
	DEVSIG,
    "Printer Device Copyright (c) Unisys Ltd 1992 Version 1.01",
    "OUTPUT02","PRN2","IOCR",NULL,NULL,(DFPTR)prn_control1,NULL,
	DEVSIG
}
#endif
;
PUBLIC DEVHEADER dev_prn3 
#if INIT
= {
	DEVSIG,
    "Printer Device Copyright (c) Unisys Ltd 1992 Version 1.01",
    "OUTPUT02","PRN3","IOCR",NULL,NULL,(DFPTR)prn_control2,NULL,
	DEVSIG
}
#endif
;
PUBLIC DEVHEADER dev_prn4 
#if INIT
= {
	DEVSIG,
    "Printer Device Copyright (c) Unisys Ltd 1992 Version 1.01",
    "OUTPUT02","PRN4","IOCR",NULL,NULL,(DFPTR)prn_control3,NULL,
	DEVSIG
}
#endif
;
PUBLIC DEVHEADER dev_prn5 
#if INIT
= {
	DEVSIG,
    "Printer Device Copyright (c) Unisys Ltd 1992 Version 1.01",
    "OUTPUT02","COM1","IOCR",NULL,NULL,(DFPTR)prn_control4,NULL,
	DEVSIG
}
#endif
;
PUBLIC DEVHEADER dev_prn6 
#if INIT
= {
	DEVSIG,
    "Printer Device Copyright (c) Unisys Ltd 1992 Version 1.01",
    "OUTPUT02","COM2","IOCR",NULL,NULL,(DFPTR)prn_control5,NULL,
	DEVSIG
}
#endif
;
PUBLIC DEVHEADER dev_prn7 
#if INIT
= {
	DEVSIG,
    "Printer Device Copyright (c) Unisys Ltd 1992 Version 1.01",
    "OUTPUT02","COM3","IOCR",NULL,NULL,(DFPTR)prn_control6,NULL,
	DEVSIG
}
#endif
;
PUBLIC DEVHEADER dev_prn8
#if INIT
= {
	DEVSIG,
    "Printer Device Copyright (c) Unisys Ltd 1992 Version 1.01",
    "OUTPUT02","COM4","IOCR",NULL,NULL,(DFPTR)prn_control7,NULL,
	DEVSIG
}
#endif
;

#define PP_DRAFT       0
#define PP_LETTER      1
#define PP_GRAPH       2
#define PP_HIGHG       3

// PUBLIC SYMBOLS E
#ifdef PRNDEV_C



INT             G_ppcurx=0;
INT             G_ppcury=0;
INT             G_ppmaxx=80;
INT             G_ppmaxy=66;
INT             G_pprnsize=1;
INT             G_pprnattr=1;
INT             G_pprnmode=0;

INT             prn_shutdown    (void);
INT             prn_startup     (INT type);
LONG 			prn_control		(INT type,va_list ap);

#endif  //  def PRNDEVICE

#endif  //  ndef PRNDEV_H

