#ifndef MOUSEDEV_H
#define MOUSEDEV_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef MOUSEDEV_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif


#ifdef MOUSEDEV_C
PUBLIC INT mouse_control(INT type,va_list ap);
PUBLIC INT mousecur_control(INT type,va_list ap);
#endif

// PUBLIC SYMBOLS S
PUBLIC DEVHEADER dev_mouse
#if INIT
= {
    DEVSIG,
    "Mouse Device Copyright (c) Unisys 1994 Version 1.00",
    "INPUT 03",
    "MOUSE",
    "IECi",
    NULL,
    NULL,
    (DFPTR)mouse_control,
    NULL,
    DEVSIG
}
#endif
;

PUBLIC DEVHEADER dev_mousecur
#if INIT
= {
    DEVSIG,
    "Mouse Device Copyright (c) Unisys 1994 Version 1.00",
    "INPUT 03",
    "MOUSECUR",
    "IECi",
    NULL,
    NULL,
    (DFPTR)mousecur_control,
    NULL,
    DEVSIG
}
#endif
;
// PUBLIC SYMBOLS E

#ifdef MOUSEDEV_C

#define MAXNUMAR 100

typedef struct {
	INT x;
	INT y;
	INT x1;
	INT y1;
	INT k;
} ACTR;

INT		G_mouseok=0;
INT		G_msex=0;
INT		G_msey=0;
INT		G_mseb=0;
INT		G_curarray[32];
INT 	G_rotate=0;
INT 	G_maxmx=0;
INT 	G_maxmy=0;
INT 	G_numar=0;
ACTR	*G_ar=NULL;

INT     mousein			(INT x,INT y,INT x1,INT y1);
void	setmousexto		(INT newx);
void	setmouseyto		(INT newy);
void    setmousebto		(INT newb);
INT		mousecur		(INT onoff);
INT		setupmouse		(INT x,INT y,INT xmin,INT xmax,INT ymin,INT ymax,INT r);
INT		mousetrap		(INT step);
INT		mousestat		(INT step);
void	mousecuroffin	(INT x,INT y,INT x1,INT y1);
void	setmcurto		(INT type);
INT 	setupar			(void);
INT 	freear			(void);
INT 	clearar			(void);
INT 	aregion			(INT x,INT y,INT x1,INT y1,INT key);
INT 	checkmouse		(void);

#endif  //  def MOUSEDEV_C

#endif  //  ndef MOUSEDEV_H
