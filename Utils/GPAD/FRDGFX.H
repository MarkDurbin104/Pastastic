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

// PUBLIC SYMBOLS S
PUBLIC void  downscr    (void);
PUBLIC void  drawbox    (INT x,INT y,INT x1,INT y1,INT c);
PUBLIC void  drawline   (INT x,INT y,INT x1,INT y1,INT c);
PUBLIC INT   grafix     (void);
PUBLIC UINT  highn      (UINT a);
PUBLIC UINT  lown       (UINT a);
PUBLIC void  opln       (INT x,INT y,INT s,INT l,INT c);
PUBLIC void  outxy      (INT x,INT y,INT col,INT siz,CHAR *fmt,...);
PUBLIC void  putlntoscr (INT c,UCHAR *sp,UCHAR lm,UCHAR rm,INT bp,UCHAR *ol,INT siz);
PUBLIC void  setvp      (INT x,INT y,INT x1,INT y1);
PUBLIC void  unpack     (INT fd,UINT *buf);
PUBLIC void  upscr      (void);

PUBLIC INT     G_maxx;
PUBLIC INT     G_maxy;

// PUBLIC SYMBOLS E

#ifdef FRDGFX_C

UCHAR   G_ol[320],*G_fp[160];
INT     G_vpx,G_vpy,G_vpx1,G_vpy1;

#endif

#endif

