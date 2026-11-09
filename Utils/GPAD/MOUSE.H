#ifndef MOUSE_H    // stop multiple includes

#define MOUSE_H

#ifdef PUBLIC
#undef PUBLIC
#endif

#ifdef MOUSE_C
#define PUBLIC 
#define INIT(a) = a;
#else
#define PUBLIC extern
#define INIT(a) ;
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------

PUBLIC INT		G_msex;
PUBLIC INT		G_msey;
PUBLIC INT		G_mseb;
PUBLIC INT		G_curarray[32];

PUBLIC  INT     mousein(INT x,INT y,INT x1,INT y1);
PUBLIC  void	setmousexto(INT newx);
PUBLIC  void	setmouseyto(INT newy);
PUBLIC  void    setmousebto(INT newb);
PUBLIC  INT		mousecur(INT onoff);
PUBLIC  INT		setupmouse(INT x,INT y,INT xmin,INT xmax,INT ymin,INT ymax,INT r);
PUBLIC  INT		mousetrap(INT step);
PUBLIC  INT		mousestat(INT step);
PUBLIC	void	mousecuroffin(INT x,INT y,INT x1,INT y1);
PUBLIC	void	setmcurto(INT type);

#ifdef MOUSE_C

//------------------------PRIVATE Prototypes & Variables-------------------
INT G_rotate=0;
INT G_maxmx;
INT G_maxmy;
#endif  //  def MOUSE_C

#endif  //  ndef MOUSE_H

