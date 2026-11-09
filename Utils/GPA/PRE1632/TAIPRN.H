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
int prn_control(int type,va_list ap);
#endif

PUBLIC DEVHEADER dev_prn 
#if INIT
= {
	DEVSIG,
    "Printer Device Copyright (c) Unisys Ltd 1992 Version 1.01",
    "OUTPUT02","PRN","IOCR",NULL,NULL,(DFPTR)prn_control,NULL,
	DEVSIG
}
#endif
;

// PUBLIC SYMBOLS E
#ifdef PRNDEV_C

int             G_ppcurx=0;
int             G_ppcury=0;
int             G_ppmaxx=2;
int             G_ppmaxy=2;

#endif  //  def PRNDEVICE

#endif  //  ndef PRNDEV_H


