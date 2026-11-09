#ifndef FRDGFX_H

#define FRDGFX_H

#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef FRDGFX_C
#define PUBLIC 
#define INIT(a) = a
#else
#define PUBLIC extern
#define INIT(a) 
#endif

typedef unsigned int  UINT;
typedef unsigned char UCHAR;

// PUBLIC SYMBOLS S
PUBLIC void  downscr    (void);
PUBLIC void  drawbox    (int x,int y,int x1,int y1,int c);
PUBLIC void  drawline   (int x,int y,int x1,int y1,int c);
PUBLIC int   grafix     (void);
PUBLIC UINT  highn      (UINT a);
PUBLIC UINT  lown       (UINT a);
PUBLIC void  opln       (int x,int y,int s,int l,int c);
PUBLIC void  outxy      (int x,int y,int col,int siz,char *fmt,...);
PUBLIC void  putlntoscr (int c,UCHAR *sp,UCHAR lm,UCHAR rm,int bp,UCHAR *ol,int siz);
PUBLIC void  setvp      (int x,int y,int x1,int y1);
PUBLIC void  unpack     (int fd,UINT *buf);
PUBLIC void  upscr      (void);

PUBLIC int     G_maxx;
PUBLIC int     G_maxy;

// PUBLIC SYMBOLS E

#ifdef FRDGFX_C

UCHAR   G_ol[320],*G_fp[160];
int     G_vpx,G_vpy,G_vpx1,G_vpy1;

#endif

#endif
