#ifndef FARSIDEV_H

#define FARSIDEV_H

#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef FARSIDEV_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif


#ifdef FARSIDEV_C
int	fscr_control	(int type,va_list ap);
#endif

// PUBLIC SYMBOLS S
PUBLIC DEVHEADER dev_farsi 
#if INIT
= {
	DEVSIG,
    "FARSI Device Copyright (c) Unisys Ltd 1993 Version 1.00",
    "OUTPUT01",
    "FARSI",
    "ioRACBLXSlIEDsr",
    NULL,
    NULL,
    (DFPTR)fscr_control,
    NULL,
	DEVSIG
}
#endif
;

#ifdef FARSIDEV_C

// PUBLIC SYMBOLS E

int G_maxx=79;
int G_size=1;
/*
int 		   state	(unsigned char c);
unsigned char *normal	(unsigned char *s,unsigned char *d,int mask);
unsigned char *reflect	(unsigned char *s,unsigned char *d,int mask);
unsigned char *convstr	(unsigned char *p);
*/
#endif  //  def FARSIDEV_C

#endif  //  ndef FARSIDEV_H


