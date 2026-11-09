/* DISPLAY.H header for DISPLAY.C, a text display library
   See also DISPLAY.C DIRPICK.C, and HISTO.C
*/

#ifndef DISPLAY_HEADER
#define DISPLAY_HEADER 1

/* global variables */
extern int colors[];  /* color set */
extern int color;     /* current color */
extern int mono;      /* mono monitor detected */

/* defines for color values */
#define TEXTCOLOR colors[0]   /* normal */
#define SOCOLOR colors[1]     /* stand out */
#define ERRCOLOR colors[2]    /* error color */
#define HELPCOLOR colors[3]   /* help color */

/* shortcut defines */
/* write 1 character */
#define writec(a) writecc(a,1)
/* clear entire screen */
#define cls() clears(0,0,79,24)
/* clear to end of line */
#define clreol() writecc(' ',80)
/* hide cursor */
#define curshide() goxy(255,255)
/* advisiory (error message) */
#define advise_at(x,y,msg) prompt_at(x,y,msg,"",ERRCOLOR)
/* ask_at bottom line */
#define ask(p,v,c,l,b,h) ask_at(0,24,p,v,c,l,b,h)
/* prompt_at bottom line */
#define prompt(p,r,c) prompt_at(0,24,p,r,c)
/* advisory (error) message at bottom line */
#define advise(m) advise_at(0,24,m)
/* get a file name on bottom line */
#define getfilen(f,l) getfilen_at(0,24,f,l)


/* prototypes */
/* set video mode (do this 1st) */
void vidmode(void);
/* printf using writec */
int printfc(char *fmt,...);
/* clear screen region */
void clears(int x0, int y0,int x1,int y1);
/* goto xy */
void goxy(int x,int y);
/* get xy */
void getxy(int *x,int *y);
/* write mutliple characters (handles \a\n\r, backspace */
void writecc(int c,int count);
/* write string */
void writes(char *s);
/* prompt for a key */
int prompt_at(int x, int y, char *str,
               char *resp,int pcolor);
/* ask for input */
int ask_at(int x, int y, char *promptstr,char *valid,
      int clr,int len,char *buf,char *help);
/* save video */
void vidsave(void);
/* restore video */
void vidrestore(void);
/* get a file name w/menu pick */
int getfilen_at(int x, int y,char *fn,int len);
/* menu pick directory */
char *dirpick(char *spec);
/* save current drive/directory */
void cdsave(void);
/* restore current drive/directory */
void cdrestore(void);
/* draw histograms */
void histogram(int n,int maxm);
#endif




