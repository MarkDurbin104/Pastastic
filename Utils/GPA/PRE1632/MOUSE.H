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

PUBLIC int		G_msex;
PUBLIC int		G_msey;
PUBLIC int		G_mseb;
PUBLIC int		G_curarray[32];

PUBLIC  int     mousein(int x,int y,int x1,int y1);
PUBLIC  void	setmousexto(int newx);
PUBLIC  void	setmouseyto(int newy);
PUBLIC  void    setmousebto(int newb);
PUBLIC  int		mousecur(int onoff);
PUBLIC  int		setupmouse(int x,int y,int xmin,int xmax,int ymin,int ymax,int r);
PUBLIC  int		mousetrap(int step);
PUBLIC  int		mousestat(int step);
PUBLIC	void	mousecuroffin(int x,int y,int x1,int y1);
PUBLIC	void	setmcurto(int type);

#ifdef MOUSE_C

//------------------------PRIVATE Prototypes & Variables-------------------
int G_rotate=0;
int G_maxmx;
int G_maxmy;
#endif  //  def MOUSE_C

#endif  //  ndef MOUSE_H

